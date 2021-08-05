using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlowerController : MonoBehaviour
{
    public ParticleSystem flowerSpawner;
    public Terrain terrain;
    public float range;
    public CameraController cameraController;
    [Range(0.01f, 1f)]
    public float interval;
    [Range(1, 120)]
    public int count;
    public Vector2[] timesActive;
    public DaylightLightController daylightLightController;
    // Start is called before the first frame update
    void Start()
    {
        //Debug.Log(flowerSpawner.main.startLifetime.constant);
        StartCoroutine(SpawnFlowers(interval, count));   
    }

    // Update is called once per frame
    void Update()
    {
    }

    private void spawnFlower(int count, float lifetime){
        for(int c = 0; c < count; c++){
            Vector3 position = new Vector3(Random.Range(-range, range), 0, Random.Range(-range, range)) + cameraController.focus.transform.position;
            Vector2 terrainSpacePos = new Vector2((position.x - terrain.transform.position.x) / terrain.terrainData.size.x, (position.z - terrain.transform.position.z) / terrain.terrainData.size.z);
            position.y = terrain.terrainData.GetInterpolatedHeight(terrainSpacePos.x, terrainSpacePos.y) + 0.15f;
            ParticleSystem.EmitParams emitParams = new ParticleSystem.EmitParams();
            emitParams.position = position;
            emitParams.startLifetime = lifetime;
            flowerSpawner.Emit(emitParams, 1);
        }
        Debug.Log("Spawned " + count + " flowers :)");
    }

    IEnumerator SpawnFlowers(float interval, int count){
        while(true){
            if(daylightLightController != null){
                float scaledTime = daylightLightController.GetScaledTime();
                bool found = false;
                for(int i = 0; i < timesActive.Length && !found; i++){
                    if(scaledTime >= timesActive[i].x && scaledTime < timesActive[i].y){
                        found = true;
                    }
                }
                
                if(found)
                    spawnFlower(count, interval / count * flowerSpawner.main.maxParticles);
            } else {
            spawnFlower(count, interval / count * flowerSpawner.main.maxParticles);
            }
            yield return new WaitForSeconds(interval);
        }
    }
}
