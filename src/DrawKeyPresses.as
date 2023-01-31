vec2 currPos = vec2();

int g_Font = nvg::LoadFont("DroidSans.ttf", true);

void DrawKeyPresses() {
    // use activeKeys and activeKeyIndexes
    nvg::Reset();
    float width = 0;
    float gap = S_FontSize / 3.;
    nvg::FontFace(g_Font);
    nvg::FontSize(S_FontSize / 1080.0 * Draw::GetHeight());
    nvg::TextAlign(nvg::Align::Left | nvg::Align::Top);
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
        DrawKey(tostring(activeKeys[i]));
    }

    float mouseIconSize = S_FontSize * 1.3 + S_KeyPadding * 2. + gap;
    currPos = vec2((S_XAlign > 0 ? Draw::GetWidth() : gap), S_YOffset / 100.0 * Draw::GetHeight() + S_FontSize + S_KeyPadding + gap);
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
    nvg::Text(currPos, "+");
    currPos.x += nvg::TextBounds("+").x;
    currPos.x += gap;
}

float SizeOfKey(VirtualKey k) {
    return S_KeyPadding * 2. + nvg::TextBounds(tostring(k)).x;
}

void DrawKey(const string &in key, float fixedSize = -1.0, float vOffset = 0) {
    if (vOffset == 0) vOffset = S_FontSize * 0.1;
    auto bounds = nvg::TextBounds(key);
    currPos.x += S_KeyPadding;
    nvg::BeginPath();
    nvg::RoundedRect(currPos.x - S_KeyPadding, currPos.y - S_KeyPadding, bounds.x + S_KeyPadding * 2., bounds.y + S_KeyPadding * 2., S_FontSize / 3.);
    nvg::StrokeColor(vec4(1, 1, 1, 1));
    nvg::StrokeWidth(S_FontSize / 10.);
    nvg::Stroke();
    nvg::FillColor(vec4(0, 0, 0, .5));
    nvg::Fill();
    nvg::FillColor(vec4(1, 1, 1, 1));
    nvg::Text(currPos + vec2(0, vOffset), key);
    nvg::ClosePath();
    currPos.x += (fixedSize < 0 ? S_KeyPadding + bounds.x : fixedSize - S_KeyPadding);
}

void DrawMouseButtons(float mouseIconSize) {
    // nvg::TextAlign(nvg::Align::Top | nvg::Align::Center);
    float vOff = S_FontSize * 0.25;
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
