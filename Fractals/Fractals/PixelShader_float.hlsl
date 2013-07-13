cbuffer Settings
{
    int max_iterations;
    float center_x;
    float center_y;
    float scale;
    float c_x;
    float c_y;
    float square_radius;
    float t;
    int type;
};

struct VS_Output
{
    float4 Pos : SV_POSITION;
    float2 Tex : TEXCOORD0;
};

float4 main(VS_Output data): SV_Target
{
    float2 center = {center_x, center_y};
    float2 z = float2(data.Tex.x - 0.5,  data.Tex.y - 0.5) * scale - center;
    float2 z2 = {c_x, c_y};

    for(int n = 0; n < max_iterations; n++)
    {
        if(type == 0)
        {
            float rez = z.x * z.x - z.y * z.y + c_x;
            float imz = z.x * z.y * 2 + c_y;

            z.x = rez;
            z.y = imz;

            if((rez * rez + imz * imz) > square_radius)
                break;
        }
        else
        {		
            float rez = z2.x * z2.x - z2.y * z2.y + z.x;
            float imz = z2.x * z2.y * 2 + z.y;

            z2.x = rez;
            z2.y = imz;

            if((rez * rez + imz * imz) > square_radius)
                break;
        }
    }

    float mag = (float)n / (float)max_iterations;

    mag = fmod(mag + (float)t / 20000, 1.0);

    float3 color;
    float step = 1.0 / 4.0;

    float3 col0 = {1, 1, 1};
    float3 col1 = float3(240, 31, 115) / 256;
    float3 col2 = float3(31, 100, 240) / 256;
    float3 col3 = float3(195, 240, 31) / 256;
    float3 col4 = {0, 0, 0};

    if(n == max_iterations)
    {
        color = col4;
    }
    else
    {
        color = lerp(col0,  col1, smoothstep(0.0,    step,   mag));
        color = lerp(color, col2, smoothstep(step,   2*step, mag));
        color = lerp(color, col3, smoothstep(2*step, 3*step, mag));
        color = lerp(color, col0, smoothstep(3*step, 1.0,    mag));
    }
    
    return float4(color, 1);
}