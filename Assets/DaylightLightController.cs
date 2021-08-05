using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DaylightLightController : MonoBehaviour
{
    [SerializeField]
    private Gradient lightColors;
    [SerializeField]
    private float time;
    [SerializeField]
    private float timescale = 1;
    [SerializeField]
    private Light[] directionalLight;
    private float cycleLength = 60;
    [SerializeField]
    private AnimationCurve lightIntensity;
    public Vector2 arcOrigin;
    public float arcRadius;
    public Transform focus;
    public Material bubbleMat;
    public AnimationCurve bubbleAlpha;
    public Material sunSphereMat;
    public Gradient sunColors;
    public Material crepuscularRayBlitMat;


    // Start is called before the first frame update
    void Start()
    {
        this.time = 0;
    }

    // Update is called once per frame
    void Update()
    {
        time += Time.deltaTime * timescale;
        if(time > cycleLength)
            time = 0;

        foreach(var light in directionalLight){
            //Define normalized time scaler.
            float t = time / cycleLength;
            //Directional sun light's color and intensity.
            light.color = lightColors.Evaluate(t);
            light.intensity = lightIntensity.Evaluate(t);
            //GI color and intensity
            RenderSettings.ambientIntensity = light.intensity;
            RenderSettings.ambientSkyColor = lightColors.Evaluate(t);
            //Direction sun's position and rotation
            light.transform.localPosition = arcOrigin + new Vector2(Mathf.Cos(time / cycleLength * Mathf.PI), Mathf.Sin(time / cycleLength * Mathf.PI)) * arcRadius;
            light.transform.LookAt(focus);
            Color bubOld = bubbleMat.color;
            //Bubbles opacity animation
            bubOld.a = bubbleAlpha.Evaluate(t);
            bubbleMat.color = bubOld;
            sunSphereMat.SetColor("_EmissionColor",sunColors.Evaluate(t)); 

            Vector2 screenLightPos = Camera.main.WorldToScreenPoint(light.transform.position);
            screenLightPos = new Vector2(Mathf.Clamp(screenLightPos.x, 0, 1), Mathf.Clamp(screenLightPos.y, 0, 1));
            crepuscularRayBlitMat.SetVector("_ScreenLightPos", screenLightPos);
            crepuscularRayBlitMat.SetFloat("_IlluminationDecay", lightIntensity.Evaluate(t) / 1.25F);      
            //light.transform.localEulerAngles = new Vector3(t * 360, light.transform.localEulerAngles.y, light.transform.localEulerAngles.z);
        }

        if(Input.GetKey(KeyCode.F)){
            this.timescale = 8;
        } else {
            this.timescale = 1;
        }
    }

    public Light getSun(){
        return directionalLight[0];
    }

    public float GetScaledTime(){
        return Mathf.Clamp01(time / cycleLength);
    }
}
