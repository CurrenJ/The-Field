#ifdef UNITY_INSTANCING_ENABLED


float4 _Colors[1023];   // Max instanced batch size.
void InstColor_float(out float4 Out)
{
        Out = _Colors[instanceID];
=}