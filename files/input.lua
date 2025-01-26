local mouse_buttons = {}
local keys = {}
local joy_buttons = {}
local keycodes = {}
setfenv(loadfile("data/scripts/debug/keycodes.lua"), keycodes)()
for k, v in pairs(keycodes) do
    if k:find("^Mouse_") then
        mouse_buttons[k] = v
    elseif k:find("^Key_") then
        keys[k] = v
    elseif k:find("^JOY_BUTTON_") then
        joy_buttons[k] = v
    end
end

---@return string? input
function get_any_input()
    for k, v in pairs(mouse_buttons) do
        if InputIsMouseButtonJustDown(v) then
            return k
        end
    end
    for k, v in pairs(keys) do
        if InputIsKeyJustDown(v) then
            return k
        end
    end
    for k, v in pairs(joy_buttons) do
        for i = 0, 3 do
            if InputIsJoystickButtonJustDown(i, v) then
                return k
            end
        end
    end
end

---@param input string
function read_input(input)
    if input:find("^Mouse_") then
        return InputIsMouseButtonDown(mouse_buttons[input])
    elseif input:find("^Key_") then
        return InputIsKeyDown(keys[input])
    elseif input:find("^JOY_BUTTON_") then
        for i = 0, 3 do
            if InputIsJoystickButtonDown(i, joy_buttons[input]) then
                return true
            end
        end
        return false
    end
end

---@param input string
function read_input_down(input)
    if input:find("^Mouse_") then
        return InputIsMouseButtonJustDown(mouse_buttons[input])
    elseif input:find("^Key_") then
        return InputIsKeyJustDown(keys[input])
    elseif input:find("^JOY_BUTTON_") then
        for i = 0, 3 do
            if InputIsJoystickButtonJustDown(i, joy_buttons[input]) then
                return true
            end
        end
        return false
    end
end

---@param input string
function read_input_up(input)
    if input:find("^Mouse_") then
        return InputIsMouseButtonJustUp(mouse_buttons[input])
    elseif input:find("^Key_") then
        return InputIsKeyJustUp(keys[input])
    elseif input:find("^JOY_BUTTON_") then
        for i = 0, 3 do
            if InputIsJoystickButtonDown(i, joy_buttons[input]) then
                return false
            end
        end
        return true
    end
end

local mouse_button_texts = {
    x1 = "button4",
    x2 = "button5",
}
local key_texts = {
    TAB = "$input_tab",
    SPACE = "$input_space",
    MINUS = "-",
    EQUALS = "=",
    LEFTBRACKET = "[",
    RIGHTBRACKET = "]",
    BACKSLASH = "\\",
    NONUSHASH = "#",
    SEMICOLON = ";",
    APOSTROPHE = "'",
    GRAVE = "`",
    COMMA = ",",
    PERIOD = ".",
    SLASH = "/",
    NUMLOCKCLEAR = "NUMLOCK",
    DIVIDE = "/",
    MULTIPLY = "*",
    PLUS = "+",
    NONUSBACKSLASH = "\\",
    APPLICATION = "MENU",
    POWER = "SHUTDOWN",
    EQUALSAS400 = "=",
    LEFTPAREN = "(",
    RIGHTPAREN = ")",
    LEFTBRACE = "{",
    RIGHTBRACE = "}",
    XOR = "^",
    PERCENT = "%",
    LESS = "<",
    GREATER = ">",
    AMPERSAND = "&",
    DBLAMPERSAND = "&&",
    VERTICALBAR = "|",
    DBLVERTICALBAR = "||",
    COLON = ":",
    HASH = "#",
    AT = "@",
    EXCLAM = "!",
    PLUSMINUS = "+-",
    LCTRL = "LEFT CTRL",
    LSHIFT = "$input_leftshift",
    LALT = "LEFT ALT",
    LGUI = "LEFT WINDOWS",
    RCTRL = "RIGHT CTRL",
    RSHIFT = "$input_rightshift",
    RALT = "RIGHT ALT",
    RGUI = "RIGHT WINDOWS",
}
local joy_button_texts = {
    ANALOG_00_MOVED = "analog_00",
    ANALOG_01_MOVED = "analog_01",
    ANALOG_02_MOVED = "analog_02",
    ANALOG_03_MOVED = "analog_03",
    ANALOG_04_MOVED = "analog_04",
    ANALOG_05_MOVED = "analog_05",
    ANALOG_06_MOVED = "analog_06",
    ANALOG_07_MOVED = "analog_07",
    ANALOG_08_MOVED = "analog_08",
    ANALOG_09_MOVED = "analog_09",
    ["0"] = "a",
    ["1"] = "b",
    ["2"] = "x",
    ["3"] = "y",
    ANALOG_00_DOWN = "analog_00",
    ANALOG_01_DOWN = "analog_01",
    ANALOG_02_DOWN = "analog_02",
    ANALOG_03_DOWN = "analog_03",
    ANALOG_04_DOWN = "analog_04",
    ANALOG_05_DOWN = "analog_05",
    ANALOG_06_DOWN = "analog_06",
    ANALOG_07_DOWN = "analog_07",
    ANALOG_08_DOWN = "analog_08",
    ANALOG_09_DOWN = "analog_09",
}
---@param input string
---@return string?
function get_input_text(input)
    if input:find("^Mouse_") then
        local s = input:sub(7)
        return GameTextGet("$input_mouse" .. (mouse_button_texts[s] or s:gsub("_", ""))):upper()
    elseif input:find("^Key_") then
        local s = input:sub(5)
        local text = ""
        if s:find("^KP_") then
            s = s:sub(4)
            text = "KEYPAD "
        elseif s:find("^AC_") then
            s = s:sub(4)
            text = "AC "
        end
        text = text .. (key_texts[s] or s)
        return (text:find("^%$") and GameTextGet(text) or text):upper()
    elseif input:find("^JOY_BUTTON_") then
        local s = input:sub(12)
        return GameTextGet("$input_xboxbutton_" .. (joy_button_texts[s] or s:lower())):upper()
    end
end

local detect_key = false
local disable_button = false
function mod_setting_input(mod_id, gui, in_main_menu, im_id, setting)
    GuiColorSetForNextWidget(gui, 0.436, 0.435, 0.435, 1)
    GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
    GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name)

    local text
    if detect_key then
        text = "$menuoptions_configurecontrols_pressakey"
        local input = get_any_input()
        if input ~= nil then
            detect_key = false
            if input == "Mouse_left" or input == "Mouse_right" or input == "JOY_BUTTON_0" or input == "JOY_BUTTON_1" then
                disable_button = true
            end
            ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), input, false)
        end
    else
        text = get_input_text(ModSettingGetNextValue(mod_setting_get_id(mod_id, setting)))
    end
    if disable_button and (read_input_up("Mouse_left") or read_input_down("Mouse_right") or read_input_down("JOY_BUTTON_0") or read_input_down("JOY_BUTTON_1")) then
        disable_button = false
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.NonInteractive)
        GuiOptionsAddForNextWidget(gui, GUI_OPTION.ForceFocusable)
    end
    local clicked, right_clicked = GuiButton(gui, im_id, mod_setting_group_x_offset + GuiGetTextDimensions(gui, setting.ui_name) + 10, 0, text or "?")
    if clicked then
        detect_key = true
    elseif right_clicked then
        ModSettingSetNextValue(mod_setting_get_id(mod_id, setting), setting.value_default, false)
    end

    mod_setting_tooltip(mod_id, gui, in_main_menu, setting)
end
