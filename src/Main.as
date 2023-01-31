void Main() {
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

// show the window immediately upon installation
[Setting category="General" name="Enabled?"]
bool ShowWindow = true;

/** Render function called every frame intended only for menu items in `UI`. */
void RenderMenu() {
    if (UI::MenuItem(MenuTitle, "", ShowWindow)) {
        ShowWindow = !ShowWindow;
    }
}

/** Render function called every frame.
*/
void Render() {
    if (!ShowWindow || GetApp().Editor is null) return;
    DrawKeyPresses();
}

/** Called whenever a key is pressed on the keyboard. See the documentation for the [`VirtualKey` enum](https://openplanet.dev/docs/api/global/VirtualKey).
*/
UI::InputBlocking OnKeyPress(bool down, VirtualKey key) {
    // print(tostring(key));
    if (down) AddKey(key);
    else RemoveKey(key);
    return UI::InputBlocking::DoNothing;
}

int[] mouseWheelLastActive = {0, 0};

/** Called whenever the mouse wheel is scrolled. `x` and `y` are the scroll delta values.
*/
UI::InputBlocking OnMouseWheel(int x, int y) {
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
    activeMouseButtons[button] = down;
    return UI::InputBlocking::DoNothing;
}

VirtualKey[] activeKeys;
// virtualkey max number is 254, so make an array of length 256 (it's neat) and we'll use this as a lookup for whether keys are active. -1 means not active
int[] activeKeyIndexes = array<int>(256);
int[] keysLastActive = array<int>(256);

void AddKey(VirtualKey key) {
    // offset the index by 1 so default value of 0 is 'off'
    keysLastActive[int(key)] = Time::Now;
    if (activeKeyIndexes[int(key)] == 0) {
        // insert then take length b/c of offset
        activeKeys.InsertLast(key);
        activeKeyIndexes[int(key)] = activeKeys.Length;
    }
}

void RemoveKey(VirtualKey key) {
    keysLastActive[int(key)] = Time::Now;
    startnew(RemoveSoon, cast<ref>(array<VirtualKey> = {key}));
}

// in ms
int _RemoveDelay = 125;
void RemoveSoon(ref@ keyBox) {
    auto @kb = cast<VirtualKey[]>(keyBox);
    if (kb is null || kb.Length == 0) return;
    sleep(_RemoveDelay);
    VirtualKey key = kb[0];
    if (keysLastActive[int(key)] + _RemoveDelay > int(Time::Now)) return;
    // subtract offset when we retrive ix
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

/** Called every frame. `dt` is the delta time (milliseconds since last frame).
*/
void Update(float dt) {
    // if (activeKeys.Length == 0) return;
    // string active = "(" + activeKeys.Length + "): ";
    // for (uint i = 0; i < activeKeys.Length; i++) {
    //     active += (i > 0 ? ", " : "") + activeKeys[i];
    // }
    // print(active);
}

// void AddSimpleTooltip(const string &in msg) {
//     if (UI::IsItemHovered()) {
//         UI::BeginTooltip();
//         UI::Text(msg);
//         UI::EndTooltip();
//     }
// }
