void Main() {
    startnew(MonitorEditor);
    startnew(MonitorSystem);
    startnew(MonitorStaleKeyPresses);
    sleep(100);
    if (S_FirstRun) {
        S_FirstRun = false;
        S_XOffset = S_YOffset * Draw::GetHeight() / Draw::GetWidth();
    }
}

bool lastFocus = true;
float frameTime = 30.0;
void MonitorSystem() {
    auto app = GetApp();
    while (true) {
        yield();
        frameTime = frameTime * .9 + .1 * cast<CVisionViewport>(app.Viewport).TimeGpuMs_Total;
        // trace(frameTime);
        // when we lose focus, deactivate all inputs
        if (lastFocus != app.InputPort.IsFocused) {
            lastFocus = app.InputPort.IsFocused;
            if (!app.InputPort.IsFocused) {
                ResetState();
            }
        }
    }
}

bool lastEditor = false;
void MonitorEditor() {
    while (true) {
        yield();
        // don't count test driving as being in the editor
        if (lastEditor != (GetApp().Editor !is null && GetApp().CurrentPlayground is null)) {
            lastEditor = !lastEditor;
            ResetState();
        }
        if (!lastEditor) sleep(100);
    }
}

void MonitorStaleKeyPresses() {
    while (true) {
        yield();
        for (uint i = 0; i < activeKeys.Length; i++) {
            auto ix = int(activeKeys[i]);
            // key down events are repeated every 30-50ms after 500ms frames -- until the key is released.
            // if we miss a key up event, we know that an active key is stale if we haven't heard from it in > 500ms.
            if (keysLastActive[ix] + 520 < Time::Now) {
                RemoveKey(VirtualKey(ix), true);
            }
        }
    }
}

void ResetState() {
    uint maxIx = Math::Max(activeKeys.Length, 3) - 1;
    for (uint i = maxIx; i <= maxIx; i--) {
        if (i < 2) mouseWheelLastActive[i] = 0;
        if (i < 3) activeMouseButtons[i] = false;
        if (i < activeKeys.Length)
            RemoveKey(activeKeys[i]);
    }
}

void Notify(const string &in msg) {
    UI::ShowNotification(Meta::ExecutingPlugin().Name, msg);
    trace("Notified: " + msg);
}

void NotifyError(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Error", msg, vec4(.9, .3, .1, .3), 15000);
}

void NotifyWarning(const string &in msg) {
    warn(msg);
    UI::ShowNotification(Meta::ExecutingPlugin().Name + ": Warning", msg, vec4(.9, .6, .2, .3), 15000);
}

const string PluginIcon = Icons::KeyboardO;
const string MenuTitle = "\\$2ff" + PluginIcon + "\\$z " + Meta::ExecutingPlugin().Name;

/** Render function called every frame intended only for menu items in `UI`. */
void RenderMenu() {
    if (UI::MenuItem(MenuTitle, "", S_Enabled)) {
        S_Enabled = !S_Enabled;
    }
}

bool IsPluginEnabled {
    get {
        return S_Enabled && lastEditor;
    }
}

/** Render function called every frame.
*/
void Render() {
    if (!IsPluginEnabled && !S_Preview) return;
    DrawKeyPresses();
}

/** Called whenever a key is pressed on the keyboard. See the documentation for the [`VirtualKey` enum](https://openplanet.dev/docs/api/global/VirtualKey).
*/
UI::InputBlocking OnKeyPress(bool down, VirtualKey key) {
#if DEV
    // print(" >> " + Time::Now + " >> " + (down ? Icons::ArrowDown : Icons::ArrowUp) + " >> " + tostring(key));
#endif
    if (!lastFocus || !IsPluginEnabled) return UI::InputBlocking::DoNothing;
    // print(tostring(key));
    if (down) AddKey(key);
    else RemoveKey(key);
    return UI::InputBlocking::DoNothing;
}

int[] mouseWheelLastActive = {0, 0};

/** Called whenever the mouse wheel is scrolled. `x` and `y` are the scroll delta values.
*/
UI::InputBlocking OnMouseWheel(int x, int y) {
    if (!IsPluginEnabled) return UI::InputBlocking::DoNothing;
    if (x != 0) mouseWheelLastActive[0] = Time::Now;
    if (y != 0) mouseWheelLastActive[1] = Time::Now;
    // print('wheel: ' + x + ', ' + y);
    return UI::InputBlocking::DoNothing;
}

enum MouseButton {
    Left = 0,
    Right = 1,
    Middle = 2
}

// buttons 0,1,2
bool[] activeMouseButtons = {false, false, false};

/** Called whenever a mouse button is pressed. `x` and `y` are the viewport coordinates.
* lmb = 0; rmb = 1; mmb = 2;
*/
UI::InputBlocking OnMouseButton(bool down, int button, int x, int y) {
    if (!lastFocus || !IsPluginEnabled) return UI::InputBlocking::DoNothing;
    activeMouseButtons[button] = down;
    return UI::InputBlocking::DoNothing;
}

VirtualKey[] activeKeys;
// virtualkey max number is 254, so make an array of length 256 (it's neat) and we'll use this as a lookup for whether keys are active. -1 means not active
int[] activeKeyIndexes = array<int>(256);
int[] keysLastActive = array<int>(256);
int[] keysStartActive = array<int>(256);

void AddKey(VirtualKey key) {
    // if the last time this key was active was more than 500 ms ago (openplanet repeates keydown events after 7 frames)
    if (keysStartActive[int(key)] == 0 || keysLastActive[int(key)] + 520 < Time::Now)
        keysStartActive[int(key)] = Time::Now;
    keysLastActive[int(key)] = Time::Now;
    // offset the index by 1 so default value of 0 is 'off'
    if (activeKeyIndexes[int(key)] == 0) {
        // insert then take length b/c of +1 offset
        activeKeys.InsertLast(key);
        activeKeyIndexes[int(key)] = activeKeys.Length;
    }
}

void RemoveKey(VirtualKey key, bool immediate = false) {
    keysLastActive[int(key)] = Time::Now;
    if (!immediate) startnew(RemoveSoon, cast<ref>(array<VirtualKey> = {key}));
    else RemoveKeyNow(key);
}

// Min time to wait before removing a key, in ms
int _RemoveDelay = 100;

void RemoveSoon(ref@ keyBox) {
    auto @kb = cast<VirtualKey[]>(keyBox);
    if (kb is null || kb.Length == 0) return;
    VirtualKey key = kb[0];
    auto delay = Math::Max(0, keysStartActive[int(key)] + _RemoveDelay - keysLastActive[int(key)]);
    if (delay > 0)
        sleep(delay);
    if (keysLastActive[int(key)] + delay > int(Time::Now)) return;
    RemoveKeyNow(key);
}

void RemoveKeyNow(VirtualKey key) {
    // subtract offset when we retrive ix
    keysStartActive[int(key)] = 0;
    auto ix = activeKeyIndexes[int(key)] - 1;
    if (ix >= 0) {
        // trace('Removing: ' + ix + ' of ' + activeKeys.Length);
        activeKeys.RemoveAt(ix);
        for (uint i = ix; i < activeKeys.Length; i++) {
            activeKeyIndexes[activeKeys[i]]--;
        }
        activeKeyIndexes[int(key)] = 0;
    }
}
