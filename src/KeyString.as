const string GetKeyStr(VirtualKey k) {
    if (k == VirtualKey::Menu) return "Alt";
    if (k == VirtualKey::Capital) return "Caps Lock";
    if (k == VirtualKey::Oem3) return "`";
    if (k == VirtualKey::Oem2) return "?";
    if (k == VirtualKey::Oem7) return "'";
    if (k == VirtualKey::Oem1) return ";";
    if (k == VirtualKey::Oem4) return "[";
    if (k == VirtualKey::Oem6) return "]";
    if (k == VirtualKey::Oem5) return "\\";
    if (k == VirtualKey::OemPlus) return "+";
    if (k == VirtualKey::OemMinus) return "-";
    if (k == VirtualKey::OemPeriod) return ".";
    if (k == VirtualKey::OemComma) return ",";
    return tostring(k);
}
