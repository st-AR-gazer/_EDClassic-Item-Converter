#include <Windows.h>
#include "pch.h"

// Vec2 used for mouse movement
struct vec2 {
    int x;
    int y;

    vec2(int _x, int _y) : x(_x), y(_y) {}
};

// VK_NUMPAD is generally the numpad3 key
const int SAFE_KEY = VK_NUMPAD3;

bool IsSafeKeyPressed() {
    return (GetAsyncKeyState(SAFE_KEY) & 0x8000) != 0;
}

// Move the mouse cursor to an absolute position
extern "C" __declspec(dllexport) void Move(int x, int y) {
    if (IsSafeKeyPressed()) {
        SetCursorPos(x, y);
    }
}

// Move the mouse cursor relative to its current position
extern "C" __declspec(dllexport) void MoveRelative(int dx, int dy) {
    if (IsSafeKeyPressed()) {
        POINT p;
        if (GetCursorPos(&p)) {
            SetCursorPos(p.x + dx, p.y + dy);
        }
    }
}

// Helper func
void ClickInternal(DWORD buttonDown, DWORD buttonUp) {
    if (IsSafeKeyPressed()) {
        INPUT inputs[2] = {};

        inputs[0].type = INPUT_MOUSE;
        inputs[0].mi.dwFlags = buttonDown;

        inputs[1].type = INPUT_MOUSE;
        inputs[1].mi.dwFlags = buttonUp;

        SendInput(2, inputs, sizeof(INPUT));
    }
}

// Left click at the current cursor position
extern "C" __declspec(dllexport) void Click() {
    ClickInternal(MOUSEEVENTF_LEFTDOWN, MOUSEEVENTF_LEFTUP);
}

// Right click at the current cursor position
extern "C" __declspec(dllexport) void RClick() {
    ClickInternal(MOUSEEVENTF_RIGHTDOWN, MOUSEEVENTF_RIGHTUP);
}

// Hold or release the left mouse button
extern "C" __declspec(dllexport) void MouseDown(bool hold) {
    if (IsSafeKeyPressed()) {
        INPUT input = {};
        input.type = INPUT_MOUSE;
        input.mi.dwFlags = hold ? MOUSEEVENTF_LEFTDOWN : MOUSEEVENTF_LEFTUP;
        SendInput(1, &input, sizeof(INPUT));
    }
}

// Hold or release the right mouse button
extern "C" __declspec(dllexport) void RMouseDown(bool hold) {
    if (IsSafeKeyPressed()) {
        INPUT input = {};
        input.type = INPUT_MOUSE;
        input.mi.dwFlags = hold ? MOUSEEVENTF_RIGHTDOWN : MOUSEEVENTF_RIGHTUP;
        SendInput(1, &input, sizeof(INPUT));
    }
}

// Get the current mouse position
extern "C" __declspec(dllexport) vec2 GetPosition() {
    POINT p;
    if (GetCursorPos(&p)) {
        return vec2(p.x, p.y);
    }
    return vec2(0, 0);
}