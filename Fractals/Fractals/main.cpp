//Fractal generator
//Copyright (C) <2013> Bernacchia Matteo <mailto://dev@kikijiki.com>

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <Windows.h>
#include <string>
#include <vector>
#include <memory>
#include <fstream>
#include <wrl/client.h>
#include <iostream>
#include <sstream>

#include <dxgi.h>
#include <d3dcommon.h>
#include <d3d11.h>
#include <d3dcompiler.h>

#pragma comment(lib, "dxgi.lib")
#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "d3dcompiler.lib")

using namespace Microsoft::WRL;
//using namespace DirectX;

std::wstring window_title = L"Fractals";

double scale_factor = 1.5;
int window_size = 720;

int mousex = 0;
int mousey = 0;
bool right_button = false;

D3D_FEATURE_LEVEL current_feature_level;
bool double_precision_support;

double max_iter;

HANDLE hStdOut;
DWORD cellCount;

template<typename unit>
struct __declspec(align(16)) shader_data
{
    int max_iterations;
    unit center_x;
    unit center_y;
    unit scale;
    unit c_x;
    unit c_y;
    unit square_radius;
    unit t;
    int type;
};

shader_data<double> settings = {0};
shader_data<double> settings_int = {0};

shader_data<float> fsettings = {0};

template<typename T>
T smooth(T a, T b, T t, T tolerance)
{
    T diff = b - a;

    if(abs(diff) > tolerance)
        return a + diff / t;
    else
        return b;
}

void ClearScreen()
{
    COORD homeCoords = {0, 0};
    DWORD count;	

    FillConsoleOutputCharacter(hStdOut, (TCHAR) ' ', cellCount, homeCoords, &count);
    SetConsoleCursorPosition( hStdOut, homeCoords );
}

void printInfo()
{
    ClearScreen();
    std::cout << "Directx11 feature level:";

    switch(current_feature_level)
    {
    case D3D_FEATURE_LEVEL_11_1:
        std::cout << "11.1" << std::endl;
        break;
    case D3D_FEATURE_LEVEL_11_0:
        std::cout << "11.0" << std::endl;
        break;
    case D3D_FEATURE_LEVEL_10_1:
        std::cout << "10.1" << std::endl;
        break;
    }

    if(double_precision_support)
    {
        std::cout << "Shader model version      [x]5.0" << std::endl;
        std::cout << "                          [ ]4.1" << std::endl;
        std::cout << "Floating point precision  [x]double (magnification up to x10^10�j" << std::endl;
        std::cout << "                          [ ]single (magnification up to x40.000�j" << std::endl;
    }
    else
    {
        std::cout << "Shader model version      [ ]5.0" << std::endl;
        std::cout << "                          [x]4.1" << std::endl;
        std::cout << "Floating point precision  [ ]double (magnification up to x10^10�j" << std::endl;
        std::cout << "                          [x]single (magnification up to x40.000�j" << std::endl;
    }

    std::cout << std::endl;
    if(settings.type == 1)
    {
        std::cout << "Fractal [x]mandelbrot" << std::endl;
        std::cout << "        [ ]julia" << std::endl;
    }
    else
    {
        std::cout << "Fractal [ ]mandelbrot" << std::endl;
        std::cout << "        [x]julia" << std::endl;
    }

    std::cout << "Iteration limit: " << settings_int.max_iterations << std::endl;
    std::cout << "Constant: " << settings.c_x << "," << settings.c_y << std::endl;
    std::cout << "Radius(squared): " << settings_int.square_radius << std::endl;
    std::cout << "Magnification: x" << 1.0 / settings_int.scale << std::endl;
    std::cout << std::endl;
    std::cout << "Commands�F" << std::endl;
    std::cout << "�y�����z\t\tradius" << std::endl;
    std::cout << "�y�����z\t\titerations" << std::endl;
    std::cout << "�yleft click + drag�z\tscroll" << std::endl;
    std::cout << "�yright click + drag�z\tconstant" << std::endl;
    std::cout << "�ymouse wheel�z\t\tscale" << std::endl;
    std::cout << "�yspace�z\t\tswitch between mandelbrot/julia sets" << std::endl;
    std::cout << "�yesc�z\t\t\tquit application" << std::endl;
}

void errorMsgBox(const std::wstring& msg)
{
    std::wstringstream ss;
    ss << msg << L" @" << __FILE__ << L"(" << __LINE__ << L")";
    MessageBox(NULL,
        ss.str().c_str(),
        window_title.c_str(),
        NULL); 
}

void errorMsgBox(const std::wstring& msg, HRESULT hr)
{
    std::wstringstream ss;
    switch(hr)
    {
    case E_INVALIDARG:
         ss << msg << L" error�yinvalid argument�z @" << __FILE__ << L"(" << std::dec << __LINE__ << L")";
         break;
    //case D3DERR_INVALIDCALL:
    //    ss << msg << L" error�yinvalid call�z @" << __FILE__ << L"(" << std::dec << __LINE__ << L")";
    //   break;
    case E_OUTOFMEMORY:
        ss << msg << L" error�yout of memory�z @" << __FILE__ << L"(" << std::dec << __LINE__ << L")";
        break;
    default:
        ss << msg << L" error�ycode:" << std::hex << hr << L"�z @" << __FILE__ << L"(" << std::dec << __LINE__ << L")";
    }
    
    
    MessageBox(NULL,
        ss.str().c_str(),
        window_title.c_str(),
        NULL);
}

#define check(x, y) if(!(x)){errorMsgBox(y);return 1;}
#define hcheck(x, y) if(FAILED(x)){errorMsgBox(y, x);return 1;}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)
    {
    case WM_DESTROY:
        PostQuitMessage(0);
        break;

    case WM_KEYDOWN:
        switch(wParam)
        {
            case VK_ESCAPE:
                PostQuitMessage(0);
                break;

            case VK_UP:
                settings_int.max_iterations += 10;
                printInfo();
                break;

            case VK_DOWN:
                settings_int.max_iterations -= 10;
                if(settings_int.max_iterations <= 0)
                    settings_int.max_iterations = 10;
                printInfo();
                break;

            case VK_LEFT:
                settings_int.square_radius /= 1.5;
                printInfo();
                break;

            case VK_RIGHT:
                settings_int.square_radius *= 1.5;
                printInfo();
                break;
        }
        break;

    case WM_KEYUP:
        switch(wParam)
        {
        case VK_SPACE:
            if(settings.type == 0)
            {
                settings.type = 1;
                printInfo();
            }
            else
            {
                settings.type = 0;
                printInfo();
            }
            break;
        }

        break;

    case WM_MOUSEMOVE:
    {
        int x = (short)LOWORD(lParam);
        int y = (short)HIWORD(lParam);

        int dx = x - mousex; mousex = x;
        int dy = y - mousey; mousey = y;

        bool leftButtonDown = ((wParam & MK_LBUTTON) != 0);
        bool rightButtonDown = ((wParam & MK_RBUTTON) != 0);

        if(leftButtonDown)
        {
            settings.center_x += static_cast<double>(dx) / static_cast<double>(window_size) * settings.scale;
            settings.center_y += static_cast<double>(dy) / static_cast<double>(window_size) * settings.scale;
        }

        if(rightButtonDown)
        {
            settings.c_x += static_cast<double>(dx) / static_cast<double>(window_size) * settings.scale * 0.2;
            settings.c_y += static_cast<double>(dy) / static_cast<double>(window_size) * settings.scale * 0.2;
            right_button = true;
        }
        else
        {
            if(right_button)
            {
                right_button = false;
                printInfo();
            }
        }
    }
        break;

    case WM_MOUSEWHEEL:
    {
        int w = GET_WHEEL_DELTA_WPARAM(wParam) / WHEEL_DELTA;

        if(w < 0) {settings_int.scale *= scale_factor;}
            else{settings_int.scale /= scale_factor;}

        printInfo();
    }
        break;

    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    }

    return 0;
}

int WINAPI wWinMain(HINSTANCE hInstance,
                    HINSTANCE hPrevInstance,
                    LPWSTR lpCmdLine,
                    int nCmdShow)
{
    ::AllocConsole();
    FILE *fp;
    ::SetConsoleTitle(L"Fractal - CONSOLE");
    freopen_s(&fp, "CON", "w", stdout);

    hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);

    CONSOLE_SCREEN_BUFFER_INFO csbi;

    GetConsoleScreenBufferInfo( hStdOut, &csbi );
    cellCount = csbi.dwSize.X * csbi.dwSize.Y;

    std::wstring window_class = L"Fractal";

    WNDCLASSEX wcex;

    wcex.cbSize = sizeof(WNDCLASSEX);
    wcex.style          = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc    = WndProc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = hInstance;
    wcex.hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_APPLICATION));
    wcex.hCursor        = LoadCursor(NULL, IDC_ARROW);
    wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
    wcex.lpszMenuName   = NULL;
    wcex.lpszClassName  = window_class.c_str();
    wcex.hIconSm        = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_APPLICATION));

    check(RegisterClassEx(&wcex), L"Could not create the window.");

    HWND hWnd = CreateWindow(
        window_class.c_str(),
        window_title.c_str(),
        WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX,
        CW_USEDEFAULT, CW_USEDEFAULT,
        window_size, window_size,
        NULL,
        NULL,
        hInstance,
        NULL
    );
    
    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);

    RECT wndrect;
    GetWindowRect(hWnd, &wndrect);
    MoveWindow(hWnd, 0, 0, wndrect.right - wndrect.left, wndrect.bottom - wndrect.top, true);

    HWND console = GetConsoleWindow();
    GetWindowRect(hWnd, &wndrect);
    MoveWindow(console, window_size, 0, wndrect.right - wndrect.left, wndrect.bottom - wndrect.top, true);

    ComPtr<IDXGISwapChain> swapChain;
    ComPtr<ID3D11Device> device;
    ComPtr<ID3D11DeviceContext> deviceContext;
    ComPtr<ID3D11RenderTargetView> renderTargetView;

    D3D_FEATURE_LEVEL featureLevels[] =
    {
        D3D_FEATURE_LEVEL_11_1,
        D3D_FEATURE_LEVEL_11_0,
        D3D_FEATURE_LEVEL_10_1,
        D3D_FEATURE_LEVEL_10_0,
        D3D_FEATURE_LEVEL_9_3,
        D3D_FEATURE_LEVEL_9_1
    };

    HRESULT hr = S_OK;

    DXGI_SWAP_CHAIN_DESC swapChainDesc = {0};

    swapChainDesc.BufferCount = 1;
    swapChainDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
    swapChainDesc.Flags = 0;
    swapChainDesc.OutputWindow = hWnd;
    swapChainDesc.SampleDesc.Count = 1;
    swapChainDesc.SampleDesc.Quality = 0;
    swapChainDesc.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;
    swapChainDesc.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;
    swapChainDesc.BufferDesc.Height = window_size;
    swapChainDesc.BufferDesc.Width = window_size;
    swapChainDesc.BufferDesc.Scaling = DXGI_MODE_SCALING_UNSPECIFIED; 
    swapChainDesc.BufferDesc.ScanlineOrdering = DXGI_MODE_SCANLINE_ORDER_UNSPECIFIED;
    swapChainDesc.BufferDesc.RefreshRate.Numerator = 0;
    swapChainDesc.BufferDesc.RefreshRate.Denominator = 0;
    swapChainDesc.Windowed = true;

    hr = D3D11CreateDeviceAndSwapChain(
        nullptr,
        D3D_DRIVER_TYPE_HARDWARE,
        nullptr,
        0L,
        featureLevels,
        0,//ARRAYSIZE(featureLevels),
        D3D11_SDK_VERSION,
        &swapChainDesc,
        &swapChain,
        &device,
        &current_feature_level,
        &deviceContext);

    hcheck(hr, L"Could not create the d3d device and swap chain.");       
    check(!(current_feature_level < D3D_FEATURE_LEVEL_10_1), L"Directx 10.1 or higher required.");

    ComPtr<ID3D11Texture2D> bb;
    hr = swapChain->GetBuffer(0, IID_PPV_ARGS(&bb));
    hr = device->CreateRenderTargetView(bb.Get(), nullptr, &renderTargetView);
    hcheck(hr, L"Error creating the render target view.");

    D3D11_VIEWPORT viewport = {0};

    viewport.TopLeftX = 0.0f;
    viewport.TopLeftY = 0.0f;
    viewport.Width = static_cast<float>(window_size);
    viewport.Height = static_cast<float>(window_size);
    viewport.MinDepth = D3D11_MIN_DEPTH;
    viewport.MaxDepth = D3D11_MAX_DEPTH;

    deviceContext->RSSetViewports(1, &viewport);

    ComPtr<ID3D11VertexShader> vs;
    ComPtr<ID3D11PixelShader> ps;

    D3D11_FEATURE_DATA_DOUBLES doubles = {0};
    hr = device->CheckFeatureSupport(D3D11_FEATURE_DOUBLES, &doubles, sizeof(D3D11_FEATURE_DATA_DOUBLES));
    hcheck(hr, L"Error while checking for double precision support.");

    double_precision_support = doubles.DoublePrecisionFloatShaderOps == 1 && current_feature_level >= D3D_FEATURE_LEVEL_11_0;

    ComPtr<ID3DBlob> vsblob;
    ComPtr<ID3DBlob> psblob;

    D3D11_BUFFER_DESC bd = {0};

    if(double_precision_support)
    {
        hr = D3DReadFileToBlob(L"VertexShader.cso", &vsblob);
        hcheck(hr, L"Error reading the vertex shader.");
        hr = D3DReadFileToBlob(L"PixelShader.cso", &psblob);
        hcheck(hr, L"Error reading the pixel shader (double).");

        bd.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
        bd.ByteWidth = sizeof(shader_data<double>);
        bd.Usage = D3D11_USAGE_DEFAULT;
    }
    else
    {
        hr = D3DReadFileToBlob(L"VertexShader.cso", &vsblob);
        hcheck(hr, L"Error reading the vertex shader.");
        hr = D3DReadFileToBlob(L"PixelShader_float.cso", &psblob);
        hcheck(hr, L"Error reading the pixel shader (float).");

        bd.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
        bd.ByteWidth = sizeof(shader_data<float>);
        bd.Usage = D3D11_USAGE_DEFAULT;
    }

    hr = device->CreateVertexShader(vsblob->GetBufferPointer(), vsblob->GetBufferSize(), nullptr, &vs);
    hcheck(hr, L"Error creating the vertex shader.");
    hr = device->CreatePixelShader(psblob->GetBufferPointer(), psblob->GetBufferSize(), nullptr, &ps);
    hcheck(hr, L"Error creating the pixel shader.");

    vsblob = nullptr;
    psblob = nullptr;

    ComPtr<ID3D11Buffer> settings_buffer;
    hr = device->CreateBuffer(&bd, 0, &settings_buffer);
    hcheck(hr, L"Error creating the shader constant buffer.");

    settings.max_iterations = 200;
    settings.center_x = 0.0;
    settings.center_y = 0.0;
    settings.scale = 4.0;
    settings.c_x = 0.0;
    settings.c_y = 0.0;
    settings.square_radius = 40.0;
    settings.t = 0.0;
    settings.type = 1;

    memcpy(&settings_int, &settings, sizeof(shader_data<double>));

    printInfo();

    MSG msg = {0};

    while(msg.message != WM_QUIT)
    {
        if(PeekMessage(&msg, NULL, 0U, 0U, PM_REMOVE))
        {
            TranslateMessage( &msg );
            DispatchMessage( &msg );
        }
        else
        {
            settings.t = static_cast<double>(GetTickCount());

            settings.square_radius = smooth<double>(settings.square_radius, settings_int.square_radius, 5.0, 0.01);
            settings.scale = smooth<double>(settings.scale, settings_int.scale, 5.0, 0.01 * settings_int.scale);
            settings.max_iterations = smooth<int>(settings.max_iterations, settings_int.max_iterations, 2, 2);

            static const float clearColor[4] = {.8f, .2f, .4f, 1.0f};
            deviceContext->ClearRenderTargetView(renderTargetView.Get(), clearColor);
            deviceContext->OMSetRenderTargets(1, renderTargetView.GetAddressOf(), nullptr);

            if(double_precision_support)
            {
                deviceContext->UpdateSubresource(settings_buffer.Get(), 0, nullptr, &settings, 0, 0);
            }
            else
            {
                fsettings.center_x = static_cast<float>(settings.center_x);
                fsettings.center_y = static_cast<float>(settings.center_y);
                fsettings.scale = static_cast<float>(settings.scale);
                fsettings.c_x = static_cast<float>(settings.c_x);
                fsettings.c_y = static_cast<float>(settings.c_y);
                fsettings.square_radius = static_cast<float>(settings.square_radius);
                fsettings.t = static_cast<float>(settings.t);
                fsettings.type = settings.type;
                fsettings.max_iterations = settings.max_iterations;

                deviceContext->UpdateSubresource(settings_buffer.Get(), 0, nullptr, &fsettings, 0, 0);
            }

            deviceContext->IASetVertexBuffers(0, 0, nullptr, nullptr, nullptr);
            deviceContext->IASetIndexBuffer(nullptr, DXGI_FORMAT_UNKNOWN, 0U);
            deviceContext->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
            deviceContext->VSSetShader(vs.Get(), nullptr, 0);
            //deviceContext->VSSetConstantBuffers(0, 1, settings_buffer.GetAddressOf());
            deviceContext->PSSetShader(ps.Get(), nullptr, 0);
            deviceContext->PSSetConstantBuffers(0, 1, settings_buffer.GetAddressOf());
            deviceContext->Draw(3, 0);

            hr = swapChain->Present(0, 0);
            hcheck(hr, L"Error: swapChain->Present(0, 0).");
        }
    }

    fclose(fp);
    ::FreeConsole();

    return (int) msg.wParam;
}