vec2 currPos = vec2();

int g_Font = nvg::LoadFont("DroidSans.ttf", true);

float _KeyPadding;
float _FontSize;

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
    nvg::FillColor(vec4(1, 1, 1, 1));
    float _sizeOfPlus = SizeOfPlus(gap);
    for (uint i = 0; i < activeKeys.Length; i++) {
        auto key = activeKeys[i];
        if (i > 0) width += _sizeOfPlus;
        width += SizeOfKey(activeKeys[i]);
    }

    currPos = vec2((S_XAlign > 0 ? Draw::GetWidth() : gap), S_YOffset / 100.0 * Draw::GetHeight());
    currPos.x += S_XOffset / 100.0 * Draw::GetWidth() * (S_XAlign > 0 ? -1 : 1);
    currPos.x -= S_XAlign > 0 ? width : 0;


    for (uint i = 0; i < activeKeys.Length; i++) {
        auto item = activeKeys[i];
        if (i > 0) DrawPlus(gap);
        DrawKey(GetKeyStr(activeKeys[i]));
    }

    float mouseIconSize = _FontSize * 1.3 + _KeyPadding * 2. + gap;
    currPos = vec2((S_XAlign > 0 ? Draw::GetWidth() : gap), currPos.y + _FontSize + _KeyPadding * 3. + gap * 2.);
    currPos.x += S_XOffset / 100.0 * Draw::GetWidth() * (S_XAlign > 0 ? -1 : 1);
    // scroll, LMB, MMB, RMB
    currPos.x -= S_XAlign > 0 ? (mouseIconSize * 4.) : 0;
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
    nvg::StrokeColor(vec4(1, 1, 1, 1));
    nvg::StrokeWidth(_FontSize / 10.);
    nvg::Stroke();
    nvg::FillColor(vec4(0, 0, 0, .5));
    nvg::Fill();
    nvg::FillColor(vec4(1, 1, 1, 1));
    nvg::Text(currPos + vec2(0, vOffset) + bounds / 2., key);
    nvg::ClosePath();
    currPos.x += (fixedSize < 0 ? _KeyPadding + bounds.x : fixedSize - _KeyPadding);
}

void DrawMouseButtons(float mouseIconSize) {
    // nvg::TextAlign(nvg::Align::Top | nvg::Align::Center);
    float vOff = _FontSize * 0.25;
    if (Math::Max(mouseWheelLastActive[0], mouseWheelLastActive[1]) + 500 > int(Time::Now)) {
        DrawKey(Icons::Arrows, mouseIconSize, vOff / 2.0);
    }
    else currPos.x += mouseIconSize;
    if (activeMouseButtons[MouseButton::Left]) DrawKey(Icons::Kenney::MouseLeftButton, mouseIconSize, vOff);
    else currPos.x += mouseIconSize;
    if (activeMouseButtons[MouseButton::Middle]) DrawKey(Icons::Kenney::MouseAlt, mouseIconSize, vOff);
    else currPos.x += mouseIconSize;
    if (activeMouseButtons[MouseButton::Right]) DrawKey(Icons::Kenney::MouseRightButton, mouseIconSize, vOff);
    else currPos.x += mouseIconSize;
}
