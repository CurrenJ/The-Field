using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

public class GrassController : MonoBehaviour
{
    // How many meshes to draw.'
    public List<InstancedMeshBatch> allBatches;
    public int[] materialPopulations;
    public Vector3[] materialScales;
    public float[] materialCustomColorLevel;
    public int batches;
    // Range to draw meshes within.
    public float range;

    // Material to use for drawing the meshes.
    public Material[] materials;

    private Mesh mesh;

    [SerializeField]
    private Terrain terrain;
    [SerializeField]
    private CameraController cameraController;
    private Vector3 lastUpdatePosition;
    private List<FlowerPatch> patches;
    private FlowerMap flowerMap;
    [SerializeField]
    private Gradient flowerColor;
    public TreeLeafController[] treeLeafControllers;
    [SerializeField]
    private GameObject environmentGO;
    public List<InstancedMeshBatch> bushBatches;
    public Transform seaLevel;

    IEnumerator SetupBatch(InstancedMeshBatch batch, int numInstancestoProcess = -1, bool firstRun = false, int meshesPerBatchPerCall = 64, float timeBetweenCalls = 0)
    {
        float startTime = Time.time;

        int remaining = numInstancestoProcess >= 0 ? numInstancestoProcess : batch.population;
        int meshesPositioned = 0;

        while (remaining > 0)
        {
            Vector3 oldPos = (Vector3)batch.GetCurrentMatrix().GetColumn(3);
            float distToOldPos = Vector3.Distance(oldPos, cameraController.focus.transform.position);
            //Dunno if that / 2f hurts or helps performance but I think? it look sbetter
            if (firstRun || distToOldPos > range / 2f)
            {
                // Build matrix.
                Matrix4x4 mat = Matrix4x4.identity;
                Vector3 position = Vector3.zero;
                Vector2 terrainSpacePos = Vector2.zero;

                bool validPosition = false;
                while (!validPosition)
                {
                    position = new Vector3(UnityEngine.Random.Range(-range, range), 0, UnityEngine.Random.Range(-range, range)) + cameraController.focus.transform.position;
                    terrainSpacePos = new Vector2((position.x - terrain.transform.position.x) / terrain.terrainData.size.x, (position.z - terrain.transform.position.z) / terrain.terrainData.size.z);
                    position.y = terrain.terrainData.GetInterpolatedHeight(terrainSpacePos.x, terrainSpacePos.y);

                    if((seaLevel == null || position.y > seaLevel.transform.position.y))
                        validPosition = true;
                }
                batch.SetCurrentTSP(terrainSpacePos);

                //Debug.Log(terrainSpacePos + " | "  + position.y);

                Quaternion rotation = Quaternion.Euler(0, 0, 0); //Quaternion.Euler(Random.Range(-180, 180), Random.Range(-180, 180), Random.Range(-180, 180));
                Vector3 scale = batch.GetScale();

                mat = Matrix4x4.TRS(position, rotation, scale);

                batch.SetCurrentMatrix(mat);

                batch.SetCurrentColorStrength(flowerMap.GetInterpolatedStrength(new Vector3(terrainSpacePos.x, 0, terrainSpacePos.y)) * batch.GetCustomColorFactor());
                batch.SetCurrentColor(flowerMap.GetInterpolatedColor(new Vector3(terrainSpacePos.x, 0, terrainSpacePos.y)));
            }
            //Dynamic color assignment stuff can go here, if we need it done to every grass, not just the far-recalc ones.


            meshesPositioned++;
            remaining--;
            batch.NextMesh();
            if (meshesPositioned >= meshesPerBatchPerCall)
            {
                meshesPositioned = 0;
                if (timeBetweenCalls > 0)
                    yield return new WaitForSeconds(timeBetweenCalls);
                else yield return null;
            }
        }

        yield break;
    }

    private Mesh CreateQuad(float width = 1f, float height = 1f)
    {
        // Create a quad mesh.
        var mesh = new Mesh();

        float w = width * .5f;
        float h = height * .5f;
        var vertices = new Vector3[4] {
            new Vector3(-w, 0, 0),
            new Vector3(w, 0, 0),
            new Vector3(-w, height, 0),
            new Vector3(w, height, 0)
        };

        var tris = new int[6] {
            // lower left tri.
            0, 2, 1,
            // lower right tri
            2, 3, 1
        };

        var normals = new Vector3[4] {
            -Vector3.forward,
            -Vector3.forward,
            -Vector3.forward,
            -Vector3.forward,
        };

        var uv = new Vector2[4] {
            new Vector2(0, 0),
            new Vector2(1, 0),
            new Vector2(0, 1),
            new Vector2(1, 1),
        };

        mesh.vertices = vertices;
        mesh.triangles = tris;
        mesh.normals = normals;
        mesh.uv = uv;

        return mesh;
    }

    private void Start()
    {
        allBatches = new List<InstancedMeshBatch>();
        patches = new List<FlowerPatch>();
        treeLeafControllers = environmentGO.GetComponentsInChildren<TreeLeafController>();
        bushBatches = GetTreeLeafMatrices();

        InitBatches();
        GenerateFlowers();

        lastUpdatePosition = cameraController.focus.transform.position;
        mesh = CreateQuad(0.25f, 0.25f);
        updateMeshes(-1, true);
        //StartCoroutine(UpdateAfterTime(10, 0.1f));
        //StartCoroutine(GenerateOverTime(100, 2f, true));
    }

    private void InitBatches()
    {
        for (int b = 0; b < batches; b++)
        {
            int materialIndex = b % materials.Length;
            allBatches.Add(new InstancedMeshBatch(materials[materialIndex], materialPopulations[materialIndex], materialScales[materialIndex], materialCustomColorLevel[materialIndex]));
        }
    }

    private void GenerateFlowers()
    {
        for (int s = 0; s < 32; s++)
        {
            Vector3 position = new Vector3(UnityEngine.Random.Range(-range, range), 0, UnityEngine.Random.Range(-range, range));
            Vector2 terrainSpacePos = new Vector2((position.x - terrain.transform.position.x) / terrain.terrainData.size.x, (position.z - terrain.transform.position.z) / terrain.terrainData.size.z);
            patches.Add(new FlowerPatch(
                new Vector3(position.x, terrain.terrainData.GetInterpolatedHeight(terrainSpacePos.x, terrainSpacePos.y), position.z),
                RandomColor(),
                UnityEngine.Random.Range(1f, 3f)
            ));
        }
        flowerMap = new FlowerMap(patches, terrain, 32);
    }

    public void updateMeshes(int batchSize = -1, bool firstRun = false, int meshesPerCall = 16)
    {
        StopAllCoroutines();
        foreach (InstancedMeshBatch batch in allBatches)
            StartCoroutine(SetupBatch(batch, batchSize, firstRun, meshesPerCall, 0.05f));

        bushBatches = GetTreeLeafMatrices();
    }

    private List<InstancedMeshBatch> GetTreeLeafMatrices()
    {
        Dictionary<Material, List<Matrix4x4[]>> list = new Dictionary<Material, List<Matrix4x4[]>>();
        Dictionary<Material, int> currentIndex = new Dictionary<Material, int>();
        Dictionary<Material, int> currentIndexInList = new Dictionary<Material, int>();
        foreach (TreeLeafController tlc in treeLeafControllers)
        {
            if (!currentIndex.ContainsKey(tlc.leafMaterial))
                currentIndex.Add(tlc.leafMaterial, 0);
            if (!list.ContainsKey(tlc.leafMaterial))
                list.Add(tlc.leafMaterial, new List<Matrix4x4[]>());
            if (!currentIndexInList.ContainsKey(tlc.leafMaterial))
                currentIndexInList.Add(tlc.leafMaterial, 0);

            Matrix4x4[] mat = tlc.GetMatrices();
            int amtLeftToCopy = mat.Length;
            while (amtLeftToCopy > 0)
            {
                if (currentIndex[tlc.leafMaterial] >= list[tlc.leafMaterial].Count)
                    list[tlc.leafMaterial].Add(new Matrix4x4[1023]);

                int spaceLeft = list[tlc.leafMaterial][currentIndex[tlc.leafMaterial]].Length - currentIndexInList[tlc.leafMaterial];
                int amtToCopy = Mathf.Min(amtLeftToCopy, spaceLeft);
                Array.Copy(mat, (mat.Length - amtLeftToCopy), list[tlc.leafMaterial][currentIndex[tlc.leafMaterial]], currentIndexInList[tlc.leafMaterial], amtToCopy);
                currentIndexInList[tlc.leafMaterial] += amtToCopy;
                amtLeftToCopy -= amtToCopy;


                if (currentIndexInList[tlc.leafMaterial] >= list[tlc.leafMaterial][currentIndex[tlc.leafMaterial]].Length)
                {
                    currentIndexInList[tlc.leafMaterial] = 0;
                    currentIndex[tlc.leafMaterial]++;
                }
            }
        }

        List<InstancedMeshBatch> bushBatches = new List<InstancedMeshBatch>();
        foreach (KeyValuePair<Material, List<Matrix4x4[]>> entry in list)
        {
            foreach (Matrix4x4[] positions in entry.Value)
            {
                InstancedMeshBatch newBatch = new InstancedMeshBatch(entry.Key, positions.Length, new Vector3(0.5f, 0.5f, 0.5f), 1);
                newBatch.matrices = positions;
                bushBatches.Add(newBatch);
            }
        }

        return bushBatches;
    }

    private void Update()
    {
        if (Vector3.Distance(cameraController.focus.transform.position, lastUpdatePosition) > 1f)
        {
            lastUpdatePosition = cameraController.focus.transform.position;
            updateMeshes(-1, false, 256);
            Debug.Log("MOVING  GRASS");
            ParticleSystem p = GetComponent<ParticleSystem>();
        }

        foreach (InstancedMeshBatch batch in allBatches)
        {
            batch.block.SetVectorArray("_Color_Array", batch.colors);
            batch.block.SetFloatArray("_ColorBool_Array", batch.colorStrengths);
            batch.block.SetVectorArray("_TerrainUV_Array", batch.terrainSpacePositions);
            Graphics.DrawMeshInstanced(mesh, 0, batch.GetMaterial(), batch.matrices, batch.population, batch.block, UnityEngine.Rendering.ShadowCastingMode.On, false, LayerMask.NameToLayer("Grass"), Camera.main);
        }

        foreach (InstancedMeshBatch batch in bushBatches)
        {
            Graphics.DrawMeshInstanced(mesh, 0, batch.GetMaterial(), batch.matrices, batch.population, batch.block, UnityEngine.Rendering.ShadowCastingMode.On, false, LayerMask.NameToLayer("Grass"), Camera.main);
        }
    }

    private int GetMaterialRefIndex(int b)
    {
        return b % materials.Length;
    }

    private Material GetMatFromBatchIndex(int b)
    {
        Material batchMat = materials[GetMaterialRefIndex(b)];
        return batchMat;
    }

    private int GetBatchPopulation(int b)
    {
        return materialPopulations[GetMaterialRefIndex(b)];
    }
    private float GetBatchCustomColorLevel(int b)
    {
        return materialCustomColorLevel[GetMaterialRefIndex(b)];
    }

    private Vector3 GetBatchScale(int b)
    {
        return materialScales[GetMaterialRefIndex(b)];
    }

    IEnumerator UpdateAfterTime(int batchSize, float t, bool repeat = false)
    {
        yield return new WaitForSeconds(t);
        updateMeshes(batchSize);
        if (repeat)
            yield return UpdateAfterTime(batchSize, t);
        else yield break;
    }

    IEnumerator GenerateOverTime(int total, float time, bool repeat = false)
    {
        int count = 0;
        while (count < total)
        {
            count++;
            yield return UpdateAfterTime(1, 1 / (total / time));
        }
        if (repeat)
            yield return GenerateOverTime(total, time, repeat);
        yield break;
    }

    public Color RandomColor()
    {
        return flowerColor.Evaluate(UnityEngine.Random.Range(0f, 1f));
    }
}

public class FlowerPatch
{
    private Vector3 position;
    private Color color;
    private float radius;

    public FlowerPatch(Vector3 pos, Color col, float rad)
    {
        this.position = pos;
        this.color = col;
        this.radius = rad;
    }

    public Vector2 GetPosition()
    {
        return position;
    }

    public Color GetColor()
    {
        return color;
    }

    public float GetRadius()
    {
        return radius;
    }

    public float GetStrengthAtPos(Vector3 inPos)
    {
        return Mathf.Clamp01(1 - (Vector3.Distance(inPos, this.position) / this.radius));
    }

    public float GetClampedDistAtPos(Vector3 inPos)
    {
        return Mathf.Clamp01((Vector3.Distance(inPos, this.position) / this.radius));
    }
}

public class FlowerMap
{
    private List<FlowerPatch> patches;
    private int divisions;
    public Color[][] colors;
    public float[][] strengths;
    public Terrain terrain;
    public FlowerMap(List<FlowerPatch> patches, Terrain terrain, int divisions)
    {
        this.patches = patches;
        this.terrain = terrain;
        this.divisions = divisions;
        colors = new Color[divisions][];
        strengths = new float[divisions][];
        this.GenerateMap();
    }

    private void GenerateMap()
    {
        for (int x = 0; x < divisions; x++)
        {
            if (colors[x] == null)
                colors[x] = new Color[divisions];
            if (strengths[x] == null)
                strengths[x] = new float[divisions];
            for (int y = 0; y < divisions; y++)
            {
                Vector3 pos = new Vector3((1f / divisions * x * terrain.terrainData.size.x), 0, (1f / divisions * y * terrain.terrainData.size.z)) + terrain.transform.position;

                Color color = new Color(0, 0, 0, 0);
                float strength = 0;
                bool firstPatch = true;
                foreach (FlowerPatch p in patches)
                {
                    float temp = p.GetStrengthAtPos(pos);
                    if (firstPatch)
                    {
                        color = p.GetColor();
                        firstPatch = false;
                    }
                    else color = Color.Lerp(color, p.GetColor(), temp);

                    if (temp > strength)
                    {
                        strength = temp;
                    }
                }
                colors[x][y] = color;
                strengths[x][y] = strength;
                //Debug.Log(x + ", " + y + " | " + strength + ", " + pos);
            }
        }
    }

    public Color GetInterpolatedColor(Vector3 position)
    {
        position.x = Mathf.Clamp01(position.x);
        position.z = Mathf.Clamp01(position.z);
        int l = Mathf.FloorToInt(position.x * (divisions - 1));
        int r = Mathf.CeilToInt(position.x * (divisions - 1));
        int b = Mathf.FloorToInt(position.z * (divisions - 1));
        int u = Mathf.CeilToInt(position.z * (divisions - 1));
        Color bl = colors[l][b];
        Color br = colors[r][b];
        Color ul = colors[l][u];
        Color ur = colors[r][u];
        return Color.Lerp(Color.Lerp(bl, br, position.x - l), Color.Lerp(ul, ur, position.x - l), position.z - b);
    }

    public float GetInterpolatedStrength(Vector3 position)
    {
        position.x = Mathf.Clamp01(position.x);
        position.z = Mathf.Clamp01(position.z);
        int l = Mathf.FloorToInt(position.x * (divisions - 1));
        int r = Mathf.CeilToInt(position.x * (divisions - 1));
        int b = Mathf.FloorToInt(position.z * (divisions - 1));
        int u = Mathf.CeilToInt(position.z * (divisions - 1));
        float bl = strengths[l][b];
        float br = strengths[r][b];
        float ul = strengths[l][u];
        float ur = strengths[r][u];
        return Mathf.Lerp(Mathf.Lerp(bl, br, position.x - l), Mathf.Lerp(ul, ur, position.x - l), position.z - b);
    }
}

public class InstancedMeshBatch
{
    public int population;
    public Material material;
    public Vector3 scale;
    public float customColorFactor;
    public Matrix4x4[] matrices;
    public MaterialPropertyBlock block;
    public Vector4[] colors;
    public float[] colorStrengths;
    public Vector4[] terrainSpacePositions;
    public int currentIndexInBatch;
    public InstancedMeshBatch(Material material, int population, Vector3 scale, float customColorFactor)
    {
        this.material = material;
        this.population = population;
        this.scale = scale;
        this.customColorFactor = customColorFactor;
        matrices = new Matrix4x4[population];
        block = new MaterialPropertyBlock();
        colors = new Vector4[population];
        colorStrengths = new float[population];
        terrainSpacePositions = new Vector4[population];
        currentIndexInBatch = 0;
    }

    public Matrix4x4 GetCurrentMatrix()
    {
        return matrices[currentIndexInBatch];
    }

    public void SetCurrentMatrix(Matrix4x4 matrix)
    {
        matrices[currentIndexInBatch] = matrix;
    }

    public Vector4 GetCurrentColor()
    {
        return colors[currentIndexInBatch];
    }

    public void SetCurrentColor(Vector4 color)
    {
        colors[currentIndexInBatch] = color;
    }

    public float GetCurrentColorStrength()
    {
        return colorStrengths[currentIndexInBatch];
    }

    public void SetCurrentColorStrength(float strength)
    {
        colorStrengths[currentIndexInBatch] = strength;
    }

    public Vector4 GetCurrentTSP()
    {
        return terrainSpacePositions[currentIndexInBatch];
    }

    public void SetCurrentTSP(Vector2 tsp)
    {
        terrainSpacePositions[currentIndexInBatch] = tsp;
    }

    public Vector3 GetScale()
    {
        return scale;
    }

    public float GetCustomColorFactor()
    {
        return customColorFactor;
    }

    public Material GetMaterial()
    {
        return material;
    }

    public void NextMesh()
    {
        currentIndexInBatch++;
        if (currentIndexInBatch >= population)
            currentIndexInBatch = 0;
    }
}
