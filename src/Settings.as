[Setting category="General" name="Font Size" min=16 max=200]
float S_FontSize = 30.;

[Setting category="General" name="Key Shape Padding (% Font Size)" min=1 max=50]
float S_KeyPadding = 33.;

[Setting category="General" name="Y Offset % (Dist from top of screen)" min=0 max=100]
float S_YOffset = 10.;

[Setting category="General" name="X Offset % (Dist from side of screen)" min=0 max=100]
float S_XOffset = 2.;

enum XAlign {
    Left = 0, Right = 1
}

[Setting category="General" name="X Alignment"]
XAlign S_XAlign = XAlign::Right;
