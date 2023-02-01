[Setting hidden]
bool S_FirstRun = true;

[Setting category="General" name="Enabled?"]
bool S_Enabled = true;

[Setting category="General" name="Show Preview"]
bool S_Preview = false;

[Setting category="General" name="Font Size" min=16 max=200]
float S_FontSize = 30.;

[Setting category="General" name="Key Shape Padding (% Font Size)" min=1 max=50]
float S_KeyPadding = 33.;

[Setting category="General" name="Y Offset % (Dist from top of screen)" min=0 max=100]
float S_YOffset = 5.;

[Setting category="General" name="X Offset % (Dist from side of screen)" min=0 max=50]
float S_XOffset = 2.812;

enum XAlign {
    Left = 0, Right = 1
}

[Setting category="General" name="X Alignment"]
XAlign S_XAlign = XAlign::Right;

[Setting category="General" name="Key Color" color]
vec4 S_KeyColor = vec4(1, 1, 1, 1);

[Setting category="General" name="Key BG Color" color]
vec4 S_KeyBgColor = vec4(0, 0, 0, .7);
