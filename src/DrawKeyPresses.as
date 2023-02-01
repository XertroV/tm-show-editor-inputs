vec2 currPos = vec2();

int g_Font = nvg::LoadFont("DroidSans.ttf", true);

float _KeyPadding;
float _FontSize;

VirtualKey[] activeKeysPreview = {
    VirtualKey::O,
    VirtualKey::P,
    VirtualKey::E,
    VirtualKey::N,
    VirtualKey::P,
    VirtualKey::L,
    VirtualKey::A,
    VirtualKey::N,
    VirtualKey::E,
    VirtualKey::T
};

bool[] activeMousePreview = {
    true, true, true
};

int[]@ D_MouseWheelLastActive {
    get {
        return S_Preview ? ({Time::Now, Time::Now}) : mouseWheelLastActive;
    }
}

VirtualKey[]@ D_ActiveKeys {
    get {
        return S_Preview ? activeKeysPreview : activeKeys;
    }
}

bool[]@ D_ActiveMouseButtons {
    get {
        return S_Preview ? activeMousePreview : activeMouseButtons;
    }
}

void DrawKeyPresses() {
    // use activeKeys and activeKeyIndexes
    nvg::Reset();
    float width = 0;
    _FontSize = S_FontSize / 1080.0 * Draw::GetHeight();
    float gap = _FontSize / 3.;
    _KeyPadding = _FontSize * S_KeyPadding / 100.0;
    nvg::FontFace(g_Font);
    nvg::FontSize(_FontSize);
    nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle); // nvg::Align::Left | nvg::Align::Top
    nvg::BeginPath();
    nvg::FillColor(S_KeyColor);
    float _sizeOfPlus = SizeOfPlus(gap);
    for (uint i = 0; i < D_ActiveKeys.Length; i++) {
        auto key = D_ActiveKeys[i];
        if (i > 0) width += _sizeOfPlus;
        width += SizeOfKey(D_ActiveKeys[i]);
    }

    currPos = vec2((S_XAlign > 0 ? Draw::GetWidth() : gap), S_YOffset / 100.0 * Draw::GetHeight() + _KeyPadding);
    currPos.x += S_XOffset / 100.0 * Draw::GetWidth() * (S_XAlign > 0 ? -1 : 1);
    vec2 initCornerPos = currPos;
    currPos.x -= S_XAlign > 0 ? width : 0;


    for (uint i = 0; i < D_ActiveKeys.Length; i++) {
        auto item = D_ActiveKeys[i];
        if (i > 0) DrawPlus(gap);
        DrawKey(GetKeyStr(D_ActiveKeys[i]));
    }

    float mouseIconSize = _FontSize * 1 + _KeyPadding * 2. + gap*2;
    // currPos = initCornerPos;
    // currPos = vec2((S_XAlign > 0 ? Draw::GetWidth() : gap), currPos.y + _FontSize + _KeyPadding * 3. + gap * 2.);
    // currPos.x += S_XOffset / 100.0 * Draw::GetWidth() * (S_XAlign > 0 ? -1 : 1);
    currPos = initCornerPos + vec2(0, _FontSize + _KeyPadding * 3. + gap * 2.);
    // scroll, LMB, MMB, RMB
    currPos.x -= S_XAlign > 0 ? (mouseIconSize * 4. - gap * 2.0) : 0;
    DrawMouseButtons(mouseIconSize);

    nvg::ClosePath();
}

float SizeOfPlus(float gap) {
    return gap * 2. + nvg::TextBounds("+").x;
}

void DrawPlus(float gap) {
    currPos.x += gap;
    auto bounds = nvg::TextBounds("+");
    nvg::Text(currPos + bounds / 2., "+");
    currPos.x += bounds.x;
    currPos.x += gap;
}

float SizeOfKey(VirtualKey k) {
    return _KeyPadding * 2. + Math::Max(nvg::TextBounds(GetKeyStr(k)).x, _FontSize);
}

void DrawKey(const string &in key, float fixedSize = -1.0, float vOffset = 0) {
    if (vOffset == 0) vOffset = _FontSize * 0.1;
    auto bounds = nvg::TextBounds(key);
    bounds.x = Math::Max(bounds.x, _FontSize);
    currPos.x += _KeyPadding;
    nvg::BeginPath();
    nvg::RoundedRect(currPos.x - _KeyPadding, currPos.y - _KeyPadding, bounds.x + _KeyPadding * 2., bounds.y + _KeyPadding * 2., _FontSize / 3.);
    nvg::FillColor(S_KeyBgColor);
    nvg::Fill();
    nvg::StrokeColor(S_KeyColor);
    nvg::StrokeWidth(_FontSize / 10.);
    nvg::Stroke();
    nvg::FillColor(S_KeyColor);
    nvg::Text(currPos + vec2(0, vOffset) + bounds / 2., key);
    nvg::ClosePath();
    currPos.x += (fixedSize < 0 ? _KeyPadding + bounds.x : fixedSize - _KeyPadding);
}

void DrawMouseButtons(float mouseIconSize) {
    // nvg::TextAlign(nvg::Align::Top | nvg::Align::Center);
    float vOff = _FontSize * 0.15;
    if (Math::Max(D_MouseWheelLastActive[0], D_MouseWheelLastActive[1]) + 500 > int(Time::Now)) {
        DrawKey(Icons::Arrows, mouseIconSize, vOff / 2.0);
    }
    else currPos.x += mouseIconSize;
    if (D_ActiveMouseButtons[MouseButton::Left]) DrawKey(Icons::Kenney::MouseLeftButton, mouseIconSize, vOff);
    else currPos.x += mouseIconSize;
    if (D_ActiveMouseButtons[MouseButton::Middle]) DrawKey(Icons::Kenney::MouseAlt, mouseIconSize, vOff);
    else currPos.x += mouseIconSize;
    if (D_ActiveMouseButtons[MouseButton::Right]) DrawKey(Icons::Kenney::MouseRightButton, mouseIconSize, vOff);
    else currPos.x += mouseIconSize;
}
