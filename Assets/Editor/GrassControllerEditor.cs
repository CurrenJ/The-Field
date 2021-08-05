using UnityEditor;
using UnityEngine;
[CustomEditor(typeof(GrassController))]
[CanEditMultipleObjects]
public class GrassControllerEditor : Editor
{
    SerializedProperty materials;
    SerializedProperty materialPopulations;
    SerializedProperty materialScales;
    SerializedProperty materialCustomColorLevel;
    SerializedProperty batches;
    SerializedProperty range;
    SerializedProperty terrain;
    SerializedProperty cameraController;
    SerializedProperty flowerColor;
    SerializedProperty treeLeafControllers;
    SerializedProperty environmentGO;
    SerializedProperty seaLevel;

    void OnEnable()
    {
        // Setup the SerializedProperties.
        materials = serializedObject.FindProperty("materials");
        materialPopulations = serializedObject.FindProperty("materialPopulations");
        materialScales = serializedObject.FindProperty("materialScales");
        materialCustomColorLevel = serializedObject.FindProperty("materialCustomColorLevel");
        batches = serializedObject.FindProperty("batches");
        range = serializedObject.FindProperty("range");
        terrain = serializedObject.FindProperty("terrain");
        cameraController = serializedObject.FindProperty("cameraController");
        flowerColor = serializedObject.FindProperty("flowerColor");
        treeLeafControllers = serializedObject.FindProperty("treeLeafControllers");
        environmentGO = serializedObject.FindProperty("environmentGO");
        seaLevel = serializedObject.FindProperty("seaLevel");
    }

    public override void OnInspectorGUI()
    {
        // Update the serializedProperty - always do this in the beginning of OnInspectorGUI.
        serializedObject.Update();

        EditorGUILayout.LabelField("Basic Grass Settings", EditorStyles.centeredGreyMiniLabel);
        EditorGUILayout.PropertyField(materials);
        EditorGUILayout.PropertyField(materialPopulations);
        EditorGUILayout.PropertyField(materialScales);
        EditorGUILayout.PropertyField(materialCustomColorLevel);
        EditorGUILayout.IntSlider(batches, 1, 50, new GUIContent("Batches"));
        EditorGUILayout.Slider(range, 1, 20, new GUIContent("Range"));
        EditorGUILayout.PropertyField(terrain);
        EditorGUILayout.PropertyField(cameraController);
        EditorGUILayout.LabelField("Bush Mesh Settings", EditorStyles.centeredGreyMiniLabel);
        EditorGUILayout.PropertyField(treeLeafControllers);
        EditorGUILayout.PropertyField(environmentGO);
        EditorGUILayout.PropertyField(seaLevel);

        // Apply changes to the serializedProperty - always do this in the end of OnInspectorGUI.
        serializedObject.ApplyModifiedProperties();
    }

    // Custom GUILayout progress bar.
    void ProgressBar(float value, string label)
    {
        // Get a rect for the progress bar using the same margins as a textfield:
        Rect rect = GUILayoutUtility.GetRect(18, 18, "TextField");
        EditorGUI.ProgressBar(rect, value, label);
        EditorGUILayout.Space();
    }
}