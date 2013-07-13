cbuffer Settings
{
    int max_iterations;
    double center_x;
    double center_y;
    double scale;
    double c_x;
    double c_y;
    double square_radius;
    double t;
    int type;
};

struct VS_Output
{
    float4 Pos : SV_POSITION;
    float2 Tex : TEXCOORD0;
};

float4 main(VS_Output data): SV_Target
{
    double2 center = {center_x, center_y};
    double2 z = double2(data.Tex.x - 0.5,  data.Tex.y - 0.5) * scale - center;
    double2 z2 = {c_x, c_y};

    for(int n = 0; n < max_iterations; n++)
    {
        if(type == 0)
        {
            double rez = z.x * z.x - z.y * z.y + c_x;
            double imz = z.x * z.y * 2 + c_y;

            z.x = rez;
            z.y = imz;

            if((rez * rez + imz * imz) > square_radius)
                break;
        }
        else
        {		
            double rez = z2.x * z2.x - z2.y * z2.y + z.x;
            double imz = z2.x * z2.y * 2 + z.y;

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