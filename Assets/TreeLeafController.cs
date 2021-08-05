using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TreeLeafController : MonoBehaviour
{
    public int leafMeshPopulation = 256;
    public Vector3 scale;
    public Material leafMaterial;
    private Matrix4x4[] matrices;
    // Start is called before the first frame update
    void Start()
    {
        matrices = new Matrix4x4[leafMeshPopulation];
        for (int i = 0; i < leafMeshPopulation; i++)
        {
            Vector3 point = GetPointOnMesh().point;
            Quaternion rotation = Quaternion.Euler(0, 0, 0); //Quaternion.Euler(Random.Range(-180, 180), Random.Range(-180, 180), Random.Range(-180, 180));

            matrices[i] = Matrix4x4.TRS(point, rotation, scale);
        }
    }

    public RaycastHit GetPointOnMesh()
    {
        float length = 10f;
        Vector3 direction = Random.onUnitSphere;
        Ray ray = new Ray(transform.position + direction * length, -direction);
        RaycastHit hit;
        this.GetComponent<Collider>().Raycast(ray, out hit, length * 2);
        return hit;
    }

    public Matrix4x4[] GetMatrices(){
        return matrices;
    }
}
