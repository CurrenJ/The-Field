using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine.UIElements;

public class CameraController : MonoBehaviour
{
    [SerializeField]
    private float startTime;
    [SerializeField]
    private float duration = 0.5f;
    [SerializeField]
    private Vector3 startRot;
    [SerializeField]
    private Vector3 endRot;
    [SerializeField]
    private float increment = 45;

    private float zoomVelocity;
    [SerializeField]
    private float zoomAmount;
    private float fovDefault;
    public GameObject focus;
    private Vector3 initPosition;
    private Quaternion initRot;
    private Vector3 movementVelocity;
    private float angularVelocity;

    private float startCamPitch;
    private float endCamPitch;
    private float startTimeCamPitch;
    private bool lookAtSun;
    private Volume volume;
    [SerializeField]
    private Terrain terrain;
    // Start is called before the first frame update
    [SerializeField]
    private DaylightLightController daylightLightController;
    private float PivotCooldown = 0.25f;
    private float lastPivot;

    public bool cameraSwayEnabled;
    private Vector3 cameraSway;
    public float cameraSwayRange;
    private float lastSwayTime;
    private Vector3 lastSwayPos;
    private float nextSwayInterval;
    public Vector2 swayIntervalRange;
    public float rotationControlSpeed = 1f;
    public float movementControlSpeed = 1f;
    void Start()
    {
        fovDefault = Camera.main.fieldOfView;
        initPosition = Camera.main.transform.position;
        initRot = Camera.main.transform.rotation;
        volume = Camera.main.GetComponent<Volume>();
        startCamPitch = 30;
        endCamPitch = 30;
    }

    // Update is called once per frame
    void Update()
    {
        cameraControl();

        this.transform.localEulerAngles = new Vector3(this.transform.localEulerAngles.x, Mathf.LerpAngle(startRot.y, endRot.y + focus.transform.eulerAngles.y, sinEase((Time.time - startTime) / duration)), this.transform.localEulerAngles.z);
        Camera.main.transform.localEulerAngles = new Vector3(Mathf.LerpAngle(startCamPitch, endCamPitch, sinEase((Time.time - startTimeCamPitch) / duration)), 0, 0);

        Camera.main.fieldOfView += zoomVelocity * 0.2f;
        zoomAmount += zoomVelocity * 0.1f;
        Camera.main.transform.position = focus.transform.position + Camera.main.transform.forward * zoomAmount;
        float terrainHeight = getTerrainHeight(Camera.main.transform.position, terrain);
        if (terrainHeight + 0.25f >= Camera.main.transform.position.y)
            Camera.main.transform.position = new Vector3(Camera.main.transform.position.x, terrainHeight + 0.5f, Camera.main.transform.position.z);

        if (volume.profile.TryGet<UnityEngine.Rendering.Universal.DepthOfField>(out var dof))
        {
            if (lookAtSun)
            {
                dof.active = false;
            }
            else
            {
                dof.active = true;
                dof.gaussianStart.Override(-zoomAmount * 2);
                dof.gaussianEnd.Override(-zoomAmount * 12);
            }
        }

        foreach (Camera cam in this.GetComponentsInChildren<Camera>())
        {
            cam.fieldOfView = Camera.main.fieldOfView;
        }
        zoomVelocity /= 1.1f;

        if (cameraSwayEnabled)
        {
            if (Time.time - lastSwayTime >= nextSwayInterval)
            {
                nextSwayInterval = Random.Range(swayIntervalRange.x, swayIntervalRange.y);
                lastSwayPos = cameraSway;
                cameraSway = new Vector3(Random.Range(-1f, 1f), Random.Range(-1f, 1f), Random.Range(-1f, 1f)) * cameraSwayRange;
                lastSwayTime = Time.time;
            }
            Camera.main.transform.localEulerAngles = LerpAngleV3(lastSwayPos + Camera.main.transform.localEulerAngles, cameraSway + Camera.main.transform.localEulerAngles, (Time.time - lastSwayTime) / nextSwayInterval);
            //cameraSway /= 1.1f;
        }

        playerControl();

        if (Input.GetKey(KeyCode.C))
        {
            Camera.main.transform.LookAt(daylightLightController.getSun().transform);
            lookAtSun = true;
        }
        else
        {
            lookAtSun = false;
        }
    }

    private void cameraControl()
    {
        if (Input.GetKeyDown(KeyCode.E))
        {
            startRot = this.transform.localEulerAngles;
            endRot = new Vector3(startRot.x, ((int)(endRot.y / increment) + 1) * increment, startRot.z);
            startTime = Time.time;
        }
        else if (Input.GetKeyDown(KeyCode.Q))
        {
            startRot = this.transform.localEulerAngles;
            endRot = new Vector3(startRot.x, ((int)(endRot.y / increment) - 1) * increment, startRot.z);
            startTime = Time.time;
        }
        else if (Input.GetKeyDown(KeyCode.X))
        {
            startCamPitch = Camera.main.transform.localEulerAngles.x;
            endCamPitch = 10;
            startTimeCamPitch = Time.time;
        }
        else if (Input.GetKeyUp(KeyCode.X))
        {
            startCamPitch = Camera.main.transform.localEulerAngles.x;
            endCamPitch = 30;
            startTimeCamPitch = Time.time;
        }
        else if (Input.GetKey(KeyCode.W))
        {
            zoomVelocity += 0.025f * movementControlSpeed;
        }
        else if (Input.GetKey(KeyCode.S))
        {
            zoomVelocity -= 0.025f * movementControlSpeed;
        }
        else if (Input.GetKeyDown(KeyCode.Space))
        {
            Camera.main.fieldOfView = fovDefault;
            Camera.main.transform.rotation = initRot;
            foreach (Camera cam in this.GetComponentsInChildren<Camera>())
            {
                cam.fieldOfView = fovDefault;
            }
        }
    }

    private void playerControl()
    {
        if (Input.GetKey(KeyCode.LeftArrow))
        {
            angularVelocity += -2f * Time.deltaTime * rotationControlSpeed;
        }
        else if (Input.GetKey(KeyCode.RightArrow))
        {
            angularVelocity += 2f * Time.deltaTime * rotationControlSpeed;
        }
        Vector3 oldEuler = focus.transform.localEulerAngles;
        oldEuler.y += angularVelocity;
        angularVelocity /= 1.1f;
        if (Input.GetKey(KeyCode.UpArrow))
        {
            movementVelocity += focus.transform.forward * 0.15f * Time.deltaTime * movementControlSpeed;
        }
        else if (Input.GetKey(KeyCode.DownArrow))
        {
            movementVelocity += -focus.transform.forward * 0.15f * Time.deltaTime * movementControlSpeed;
        }

        if (Input.touchCount > 0)
        {
            TouchPosition(Input.GetTouch(0).position);
        }
        else if (Input.GetMouseButton(0))
        {
            TouchPosition(Input.mousePosition);
        }
        focus.transform.position += movementVelocity;
        movementVelocity /= 1.1f;

        Vector3 focusPos = focus.transform.position;
        Vector4 data = get4PtAvgTerrainHeightAndNormal(focus.transform.position, terrain, 0.2f);
        Quaternion targetRot = Quaternion.FromToRotation(focus.transform.up, (Vector3)data) * focus.transform.rotation;
        focusPos.y = data.w;

        Vector3 finalEulerAngles = LerpAngleV3(focus.transform.localEulerAngles, targetRot.eulerAngles, Time.deltaTime / 0.15f, true);
        finalEulerAngles.y = oldEuler.y;
        focus.transform.localEulerAngles = finalEulerAngles;
        focus.transform.localPosition = focusPos;
    }

    private void TouchPosition(Vector2 touch)
    {
        if (touch.y >= 2 * Screen.height / 3)
            MoveForward();
        else if (touch.y <= Screen.height / 3)
            MoveBackward();
        if (touch.x >= 2 * Screen.width / 3)
            angularVelocity += 2f * Time.deltaTime;
        else if (touch.x <= Screen.width / 3)
            angularVelocity += -2f * Time.deltaTime;
    }

    private void MoveForward()
    {
        movementVelocity += focus.transform.forward * 0.15f * Time.deltaTime;
    }

    private void MoveBackward()
    {
        movementVelocity += -focus.transform.forward * 0.15f * Time.deltaTime;
    }

    private static float sinEase(float x)
    {
        float t = Mathf.Clamp(x, 0, 1);
        return Mathf.Sin(Mathf.PI * (t - 0.5f)) / 2f + 0.5f;
    }

    private static Vector3 LerpAngleV3(Vector3 from, Vector3 to, float t, bool sinEasing = false)
    {
        float time = t;
        if (sinEasing)
            time = sinEase(t);

        return new Vector3(
                Mathf.LerpAngle(from.x, to.x, time),
                Mathf.LerpAngle(from.y, to.y, time),
                Mathf.LerpAngle(from.z, to.z, time)
            );

    }

    private static float getTerrainHeight(Vector3 position, Terrain terrain)
    {
        Vector2 relative = new Vector2((position.x - terrain.transform.position.x) / terrain.terrainData.size.x, (position.z - terrain.transform.position.z) / terrain.terrainData.size.z);
        return terrain.terrainData.GetInterpolatedHeight(relative.x, relative.y);
    }

    private static Vector4 getTerrainHeightAndNormal(Vector3 position, Terrain terrain)
    {
        Vector2 relative = new Vector2((position.x - terrain.transform.position.x) / terrain.terrainData.size.x, (position.z - terrain.transform.position.z) / terrain.terrainData.size.z);
        Vector3 normal = terrain.terrainData.GetInterpolatedNormal(relative.x, relative.y);
        return new Vector4(normal.x, normal.y, normal.z, terrain.terrainData.GetInterpolatedHeight(relative.x, relative.y));
    }

    private static Vector4 getTerrainHeightAndParallelPlane(Transform focus, Terrain terrain, float interval)
    {
        Plane plane = new Plane();
        Vector3[] points = new Vector3[3];
        for (int i = 0; i < 3; i++)
        {
            Vector3 position = focus.position;
            switch (i)
            {
                case 0:
                    position += focus.forward * interval;
                    break;
                case 1:
                    position += focus.right * interval;
                    break;
                case 2:
                    position += -focus.right * interval;
                    break;
                default:
                    break;
            }
            Vector2 relative = new Vector2((position.x - terrain.transform.position.x) / terrain.terrainData.size.x, (position.z - terrain.transform.position.z) / terrain.terrainData.size.z);
            points[i] = new Vector3(position.x, terrain.terrainData.GetInterpolatedHeight(relative.x, relative.y), position.z);
        }
        plane.Set3Points(points[0], points[1], points[2]);
        Vector2 originRelative = new Vector2((focus.transform.position.x - terrain.transform.position.x) / terrain.terrainData.size.x, (focus.transform.position.z - terrain.transform.position.z) / terrain.terrainData.size.z);
        Vector3 planeNormal = plane.normal;
        return new Vector4(planeNormal.x, planeNormal.y, planeNormal.z, terrain.terrainData.GetInterpolatedHeight(originRelative.x, originRelative.y));
    }

    private static Vector4 get4PtAvgTerrainHeightAndNormal(Vector3 origin, Terrain terrain, float interval)
    {
        Vector4 normals = Vector3.zero;
        for (int i = 0; i < 5; i++)
        {
            Vector3 position = origin;
            switch (i)
            {
                case 0:
                    position += new Vector3(interval, 0, 0);
                    break;
                case 1:
                    position += new Vector3(-interval, 0, 0);
                    break;
                case 2:
                    position += new Vector3(0, 0, interval);
                    break;
                case 3:
                    position += new Vector3(0, 0, -interval);
                    break;
            }

            Vector2 relative = new Vector2((position.x - terrain.transform.position.x) / terrain.terrainData.size.x, (position.z - terrain.transform.position.z) / terrain.terrainData.size.z);
            Vector4 normal = terrain.terrainData.GetInterpolatedNormal(relative.x, relative.y);
            normals += new Vector4(normal.x, normal.y, normal.z, terrain.terrainData.GetInterpolatedHeight(relative.x, relative.y));
        }
        return normals / 5;
    }

    // private static float[] getTerrainHeights(Vector3 position, float range, Terrain terrain){
    //     Vector2 relative = new Vector2((position.x - terrain.transform.position.x) / terrain.terrainData.size.x, (position.z - terrain.transform.position.z) / terrain.terrainData.size.z);
    //     terrain.terrainData.GetInterpolatedNormal
    //     return terrain.terrainData.GetInterpolatedHeight(relative.x, relative.y);
    // }

    public void RotateCW()
    {
        if (Time.time - lastPivot >= PivotCooldown)
        {
            lastPivot = Time.time;
            startRot = this.transform.localEulerAngles;
            endRot = new Vector3(startRot.x, ((int)(endRot.y / increment) + 1) * increment, startRot.z);
            startTime = Time.time;
        }

    }

    public void RotateCCW()
    {
        if (Time.time - lastPivot >= PivotCooldown)
        {
            lastPivot = Time.time;
            startRot = this.transform.localEulerAngles;
            endRot = new Vector3(startRot.x, ((int)(endRot.y / increment) - 1) * increment, startRot.z);
            startTime = Time.time;
        }
    }
}