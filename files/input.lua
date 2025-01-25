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

local key_texts = {
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
    KP_DIVIDE = "/",
    KP_MULTIPLY = "*",
    KP_MINUS = "-",
    KP_PLUS = "+",
    KP_PERIOD = ".",
    NONUSBACKSLASH = "\\",
    APPLICATION = "MENU",
    POWER = "SHUTDOWN",
    KP_EQUALS = "=",
    KP_COMMA = ",",
    KP_EQUALSAS400 = "=",
    KP_LEFTPAREN = "(",
    KP_RIGHTPAREN = ")",
    KP_LEFTBRACE = "{",
    KP_RIGHTBRACE = "}",
    KP_XOR = "^",
    KP_POWER = "SHUTDOWN",
    KP_PERCENT = "%",
    KP_LESS = "<",
    KP_GREATER = ">",
    KP_AMPERSAND = "&",
    KP_DBLAMPERSAND = "&&",
    KP_VERTICALBAR = "|",
    KP_DBLVERTICALBAR = "||",
    KP_COLON = ":",
    KP_HASH = "#",
    KP_AT = "@",
    KP_EXCLAM = "!",
    KP_PLUSMINUS = "+-",
    LCTRL = "LEFT CTRL",
    LSHIFT = "LEFT SHIFT",
    LALT = "LEFT ALT",
    LGUI = "LEFT WINDOWS",
    RCTRL = "RIGHT CTRL",
    RSHIFT = "RIGHT SHIFT",
    RALT = "RIGHT ALT",
    RGUI = "RIGHT WINDOWS",
}
local joy_button_texts = {
    JOY_BUTTON_ANALOG_00_MOVED = "$input_xboxbutton_analog_00",
    JOY_BUTTON_ANALOG_01_MOVED = "$input_xboxbutton_analog_01",
    JOY_BUTTON_ANALOG_02_MOVED = "$input_xboxbutton_analog_02",
    JOY_BUTTON_ANALOG_03_MOVED = "$input_xboxbutton_analog_03",
    JOY_BUTTON_ANALOG_04_MOVED = "$input_xboxbutton_analog_04",
    JOY_BUTTON_ANALOG_05_MOVED = "$input_xboxbutton_analog_05",
    JOY_BUTTON_ANALOG_06_MOVED = "$input_xboxbutton_analog_06",
    JOY_BUTTON_ANALOG_07_MOVED = "$input_xboxbutton_analog_07",
    JOY_BUTTON_ANALOG_08_MOVED = "$input_xboxbutton_analog_08",
    JOY_BUTTON_ANALOG_09_MOVED = "$input_xboxbutton_analog_09",
    JOY_BUTTON_DPAD_UP = "$input_xboxbutton_dpad_up",
    JOY_BUTTON_DPAD_DOWN = "$input_xboxbutton_dpad_down",
    JOY_BUTTON_DPAD_LEFT = "$input_xboxbutton_dpad_left",
    JOY_BUTTON_DPAD_RIGHT = "$input_xboxbutton_dpad_right",
    JOY_BUTTON_START = "$input_xboxbutton_start",
    JOY_BUTTON_BACK = "$input_xboxbutton_select",
    JOY_BUTTON_LEFT_THUMB = "$input_xboxbutton_left_thumb",
    JOY_BUTTON_RIGHT_THUMB = "$input_xboxbutton_right_thumb",
    JOY_BUTTON_LEFT_SHOULDER = "$input_xboxbutton_left_shoulder",
    JOY_BUTTON_RIGHT_SHOULDER = "$input_xboxbutton_right_shoulder",
    JOY_BUTTON_LEFT_STICK_MOVED = "$input_xboxbutton_left_stick_moved",
    JOY_BUTTON_RIGHT_STICK_MOVED = "$input_xboxbutton_right_stick_moved",
    JOY_BUTTON_0 = "$input_xboxbutton_a",
    JOY_BUTTON_1 = "$input_xboxbutton_b",
    JOY_BUTTON_2 = "$input_xboxbutton_x",
    JOY_BUTTON_3 = "$input_xboxbutton_y",
    JOY_BUTTON_4 = "$input_xboxbutton_4",
    JOY_BUTTON_5 = "$input_xboxbutton_5",
    JOY_BUTTON_6 = "$input_xboxbutton_6",
    JOY_BUTTON_7 = "$input_xboxbutton_7",
    JOY_BUTTON_8 = "$input_xboxbutton_8",
    JOY_BUTTON_9 = "$input_xboxbutton_9",
    JOY_BUTTON_10 = "$input_xboxbutton_10",
    JOY_BUTTON_11 = "$input_xboxbutton_11",
    JOY_BUTTON_12 = "$input_xboxbutton_12",
    JOY_BUTTON_13 = "$input_xboxbutton_13",
    JOY_BUTTON_14 = "$input_xboxbutton_14",
    JOY_BUTTON_15 = "$input_xboxbutton_15",
    JOY_BUTTON_LEFT_STICK_LEFT = "$input_xboxbutton_left_stick_left",
    JOY_BUTTON_LEFT_STICK_RIGHT = "$input_xboxbutton_left_stick_right",
    JOY_BUTTON_LEFT_STICK_UP = "$input_xboxbutton_left_stick_up",
    JOY_BUTTON_LEFT_STICK_DOWN = "$input_xboxbutton_left_stick_down",
    JOY_BUTTON_RIGHT_STICK_LEFT = "$input_xboxbutton_right_stick_left",
    JOY_BUTTON_RIGHT_STICK_RIGHT = "$input_xboxbutton_right_stick_right",
    JOY_BUTTON_RIGHT_STICK_UP = "$input_xboxbutton_right_stick_up",
    JOY_BUTTON_RIGHT_STICK_DOWN = "$input_xboxbutton_right_stick_down",
    JOY_BUTTON_ANALOG_00_DOWN = "$input_xboxbutton_analog_00",
    JOY_BUTTON_ANALOG_01_DOWN = "$input_xboxbutton_analog_01",
    JOY_BUTTON_ANALOG_02_DOWN = "$input_xboxbutton_analog_02",
    JOY_BUTTON_ANALOG_03_DOWN = "$input_xboxbutton_analog_03",
    JOY_BUTTON_ANALOG_04_DOWN = "$input_xboxbutton_analog_04",
    JOY_BUTTON_ANALOG_05_DOWN = "$input_xboxbutton_analog_05",
    JOY_BUTTON_ANALOG_06_DOWN = "$input_xboxbutton_analog_06",
    JOY_BUTTON_ANALOG_07_DOWN = "$input_xboxbutton_analog_07",
    JOY_BUTTON_ANALOG_08_DOWN = "$input_xboxbutton_analog_08",
    JOY_BUTTON_ANALOG_09_DOWN = "$input_xboxbutton_analog_09",
    JOY_BUTTON_A = "$input_xboxbutton_a",
    JOY_BUTTON_B = "$input_xboxbutton_b",
    JOY_BUTTON_X = "$input_xboxbutton_x",
    JOY_BUTTON_Y = "$input_xboxbutton_y",
}
---@param input string
---@return string?
function get_input_text(input)
    if input:find("^Mouse_") then
        return GameTextGet("$input_" .. input:gsub("_", ""):lower()):upper()
    elseif input:find("^Key_") then
        local text = input:sub(5)
        local prefix = ""
        local key_text = key_texts[text]
        if text:find("^KP_") then
            text = text:sub(4)
            prefix = "KEYPAD "
        elseif text:find("^AC_") then
            text = text:sub(4)
            prefix = "AC "
        end
        if key_text ~= nil then
            text = key_text
        end
        return prefix .. text:upper()
    elseif input:find("^JOY_BUTTON_") then
        return GameTextGet(joy_button_texts[input]):upper()
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
