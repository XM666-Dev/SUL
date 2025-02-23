dofile_once("data/scripts/lib/utilities.lua")

--#region

local ModTextFileSetContent = ModTextFileSetContent

NUMERIC_CHARACTERS = "0123456789"

function append_translations(filename)
    local common = "data/translations/common.csv"
    ModTextFileSetContent(common, ModTextFileGetContent(common) .. ModTextFileGetContent(filename):gsub("(.-\n)", "", 1))
end

function has_flag_run_or_add(flag)
    return GameHasFlagRun(flag) or GameAddFlagRun(flag)
end

function validate(id)
    return id and id > 0 and id or nil
end

function set_component_enabled(component, enabled)
    EntitySetComponentIsEnabled(ComponentGetEntity(component), component, enabled)
end

function remove_component(component)
    EntityRemoveComponent(ComponentGetEntity(component), component)
end

function get_children(entity, ...)
    return EntityGetAllChildren(entity, ...) or {}
end

function get_inventory_items(entity)
    return GameGetAllInventoryItems(entity) or {}
end

function get_game_effect(entity, name)
    local effect = GameGetGameEffect(entity, name)
    return validate(effect), validate(ComponentGetEntity(effect))
end

function get_frame_num_next()
    return GameGetFrameNum() + 1
end

local raw_gui

function get_resolution(gui)
    if gui == nil then
        gui = raw_gui or GuiCreate()
        raw_gui = gui
    end
    local virtual_resolution_x = tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_X"))
    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    return virtual_resolution_x, virtual_resolution_x * screen_height / screen_width
end

function get_pos_on_screen(x, y, gui)
    if gui == nil then
        gui = raw_gui or GuiCreate()
        raw_gui = gui
    end
    local camera_x, camera_y = GameGetCameraPos()
    local bounds_x, bounds_y, bounds_width, bounds_height = GameGetCameraBounds()
    local resolution_width, resolution_height = get_resolution(gui)
    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    return (x - camera_x + bounds_width / 2 + tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_OFFSET_X"))) / resolution_width * screen_width,
        (y - camera_y + bounds_height / 2 + tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_OFFSET_Y"))) / resolution_height * screen_height
end

function get_pos_in_world(x, y, gui)
    if gui == nil then
        gui = raw_gui or GuiCreate()
        raw_gui = gui
    end
    local screen_width, screen_height = GuiGetScreenDimensions(gui)
    local resolution_width, resolution_height = get_resolution(gui)
    local camera_x, camera_y = GameGetCameraPos()
    local bounds_x, bounds_y, bounds_width, bounds_height = GameGetCameraBounds()
    return x / screen_width * resolution_width + camera_x - bounds_width / 2 - tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_OFFSET_X")),
        y / screen_height * resolution_height + camera_y - bounds_height / 2 - tonumber(MagicNumbersGetValue("VIRTUAL_RESOLUTION_OFFSET_Y"))
end

function get_last_component(components)
    local index = 0
    for i, v in ipairs(components) do
        if ComponentGetIsEnabled(v) then
            index = i
        end
    end
    return index, components[index]
end

function get_attack_info(entity, ai, attacks)
    local animation_name = "attack_ranged"
    local frames_between
    local action_frame
    local entity_file
    local entity_count_min
    local entity_count_max
    local offset_x
    local offset_y
    if ai ~= nil then
        frames_between = ComponentGetValue2(ai, "attack_ranged_frames_between")
        action_frame = ComponentGetValue2(ai, "attack_ranged_action_frame")
        entity_file = ComponentGetValue2(ai, "attack_ranged_entity_file")
        entity_count_min = ComponentGetValue2(ai, "attack_ranged_entity_count_min")
        entity_count_max = ComponentGetValue2(ai, "attack_ranged_entity_count_max")
        offset_x = ComponentGetValue2(ai, "attack_ranged_offset_x")
        offset_y = ComponentGetValue2(ai, "attack_ranged_offset_y")
    end
    local x, y = EntityGetTransform(entity)
    for i, attack in ipairs(attacks) do
        SetRandomSeed(x + 0.11231 + GameGetFrameNum(), y + 0.2341)
        if Random(100) <= ComponentGetValue2(attack, "use_probability") then
            animation_name = ComponentGetValue2(attack, "animation_name")
            frames_between = ComponentGetValue2(attack, "frames_between")
            action_frame = ComponentGetValue2(attack, "attack_ranged_action_frame")
            entity_file = ComponentGetValue2(attack, "attack_ranged_entity_file")
            entity_count_min = ComponentGetValue2(attack, "attack_ranged_entity_count_min")
            entity_count_max = ComponentGetValue2(attack, "attack_ranged_entity_count_max")
            offset_x = ComponentGetValue2(attack, "attack_ranged_offset_x")
            offset_y = ComponentGetValue2(attack, "attack_ranged_offset_y")
        end
    end
    if entity_file == "data/entities/projectiles/acidshot.xml" and EntityGetFilename(entity) ~= "data/entities/animals/acidshooter.xml" then
        entity_file = nil
    end
    return {
        animation_name = animation_name,
        frames_between = frames_between,
        action_frame = action_frame,
        entity_file = entity_file,
        entity_count_min = entity_count_min,
        entity_count_max = entity_count_max,
        offset_x = offset_x,
        offset_y = offset_y,
    }
end

function get_attack_ranged_pos(entity, attack_info)
    local x, y, rotation, scale_x, scale_y = EntityGetTransform(entity)
    local pos_x, pos_y = attack_info.offset_x, attack_info.offset_y
    pos_x, pos_y = vec_rotate(pos_x, pos_y, rotation)
    pos_x, pos_y = vec_scale(pos_x, pos_y, scale_x, scale_y)
    pos_x, pos_y = vec_add(pos_x, pos_y, x, y)
    return pos_x, pos_y
end

local ids = {}
local max_id = 0x7FFFFFFF
function new_id(s)
    local id = ids[s]
    if id == nil then
        id = max_id
        ids[s] = id
        max_id = id - 1
    end
    return id
end

function serialize(v)
    local type = type(v)
    if type == "number" then
        return ("%.16a"):format(v)
    elseif type == "string" then
        return ("%q"):format(v)
    elseif type == "table" then
        local t = {"{"}
        for k, v in pairs(v) do
            table.insert(t, ("[%s]=%s,"):format(serialize(k), serialize(v)))
        end
        table.insert(t, "}")
        return table.concat(t)
    end
    return tostring(v)
end

function deserialize(s)
    ModTextFileSetContent("data/scripts/empty.lua", "return " .. s)
    local f, err = loadfile("data/scripts/empty.lua")
    if f == nil then return f, err end
    return f()
end

function get_language()
    return ({
        ["English"] = "en",
        ["русский"] = "ru",
        ["Português (Brasil)"] = "pt-br",
        ["Español"] = "es-es",
        ["Deutsch"] = "de",
        ["Français"] = "fr-fr",
        ["Italiano"] = "it",
        ["Polska"] = "pl",
        ["简体中文"] = "zh-cn",
        ["日本語"] = "jp",
        ["한국어"] = "ko",
    })[GameTextGet("$current_language")]
end

function debug_print(...)
    local t = {...}
    for i, v in ipairs(t) do
        t[i] = string.from(v)
    end
    local s = table.concat(t, ",")
    print(s)
    GamePrint(s)
end

--#endregion

--#region

function string.from(value)
    if type(value) == "table" then
        local t = {}
        for k, v in pairs(value) do
            table.insert(t, ("%s=%s"):format(string.from(k), string.from(v)))
        end
        return ("{%s}"):format(table.concat(t, ","))
    end
    return tostring(value)
end

function string.asub(s, repl)
    return s:gsub('(%g+)%s*=%s*"(.-)"', repl)
end

function string.raw(s)
    local bytes = {}
    local t = {s:byte(1, #s)}
    for i, v in ipairs(t) do
        if v < 48 or v > 57 and v < 65 or v > 90 and v < 97 or v > 122 then
            table.insert(bytes, 37)
        end
        table.insert(bytes, v)
    end
    return string.char(unpack(bytes))
end

function table.find(list, pred)
    for i, v in ipairs(list) do
        if type(pred) == "function" then
            if pred(v) then
                return v, i
            end
        elseif v == pred then
            return v, i
        end
    end
end

function table.filter(list, pred)
    local result = {}
    for i, v in ipairs(list) do
        if pred(v) then
            table.insert(result, v)
        end
    end
    return result
end

function table.iterate(list, comp)
    local value
    for i, v in ipairs(list) do
        if value == nil or comp(v, value) then
            value = v
        end
    end
    return value
end

function table.copy(t)
    local result = {}
    for k, v in pairs(t) do
        result[k] = v
    end
    return result
end

function math.round(x)
    return math.floor(x + 0.5)
end

function lerp(from, to, weight)
    return from + (to - from) * weight
end

function lerp_clamped(from, to, weight)
    return lerp(from, to, clamp(weight, 0, 1))
end

function lerp_angle(from, to, weight)
    local diff = (to - from + math.pi) % (2 * math.pi) - math.pi
    return from + diff * weight
end

function lerp_angle_vec(x1, y1, x2, y2, weight)
    local angle1 = math.atan2(y1, x1)
    local angle2 = math.atan2(y2, x2)
    local lerped_angle = lerp_angle(angle1, angle2, weight)
    local length1 = math.sqrt(x1 * x1 + y1 * y1)
    local length2 = math.sqrt(x2 * x2 + y2 * y2)
    local lerped_length = lerp(length1, length2, weight)
    return math.cos(lerped_angle) * lerped_length, math.sin(lerped_angle) * lerped_length
end

function warp(value, from, to)
    return (value - from) % (to - from) + from
end

function point_in_rectangle(x, y, left, up, right, down)
    return x >= left and x <= right and y >= up and y <= down
end

--#endregion

local null = setmetatable({}, {__index = function(t) return t end, __newindex = function() end})
local function __index(t, k)
    local conditional = false
    if k:find("_$") then
        k = k:sub(1, -2)
        conditional = true
    end
    local field = getmetatable(t)[k]
    assert(field ~= nil, "field does not exist: " .. k)
    if type(field) == "table" then
        local v = field:get(t, k)
        if v == nil and conditional then
            return null
        end
        return v
    end
    return field
end
local function __newindex(t, k, v)
    local field = getmetatable(t)[k]
    assert(field ~= nil, "field does not exist: " .. k)
    field:set(t, k, v)
end
---@class Entity
---@field id integer
---@type table|fun(fields: table): fun(entity_id: integer): Entity
Entity = setmetatable({
    __call = function(t, entity_id)
        return setmetatable({id = entity_id}, t)
    end,
}, {
    __call = function(t, fields)
        fields.__index = __index
        fields.__newindex = __newindex
        return setmetatable(fields, t)
    end,
})

local vector_metatable = {
    __call = function(self)
        return ComponentGetValue2(self.id, self.field)
    end,
    __index = function(self, k)
        return select(k, ComponentGetValue2(self.id, self.field))
    end,
    __newindex = function(self, k, v)
        local values = {ComponentGetValue2(self.id, self.field)}
        values[k] = v
        ComponentSetValue2(self.id, self.field, unpack(values))
    end,
}
local component_metatable = {
    __index = function(self, k)
        local v = {ComponentGetValue2(self._id, k)}
        if #v > 1 then
            return setmetatable({id = self._id, field = k}, vector_metatable)
        end
        return v[1]
    end,
    __newindex = function(self, k, v)
        if v ~= nil then
            if type(v) == "table" then
                if getmetatable(v) == vector_metatable then
                    ComponentSetValue2(self._id, k, ComponentGetValue2(v.id, v.field))
                    return
                end
                ComponentSetValue2(self._id, k, unpack(v))
                return
            end
            ComponentSetValue2(self._id, k, v)
        end
    end,
}
local function EntityGetFirstComponentWithTable(entity_id, t)
    local f
    for i, v in ipairs(t) do
        f = v
    end
    if type(f) ~= "function" then
        f = EntityGetFirstComponentIncludingDisabled
    end
    local component = f(entity_id, unpack(t))
    if component ~= nil then
        return component
    end
    local values = {}
    for k, v in pairs(t) do
        if type(k) == "string" then
            values[k] = v
        end
    end
    return EntityAddComponent2(entity_id, t[1], values)
end
---@class ComponentField
---@type table|fun(component_type_name: string|table, tag: string|function?, ...): ComponentField
ComponentField = setmetatable({}, {
    __call = function(t, ...)
        local f = select(-1, ...)
        if type(...) == "table" then
            f = EntityGetFirstComponentWithTable
        elseif type(f) ~= "function" then
            f = EntityGetFirstComponentIncludingDisabled
        end
        return setmetatable({f, ...}, t)
    end,
})
ComponentField.__index = ComponentField
function ComponentField:get(entity, k)
    local id = self[1](entity.id, unpack(self, 2))
    if id ~= nil then
        local v = setmetatable({_id = id}, component_metatable)
        rawset(entity, k, v)
        return v
    end
end

---@class VariableField
---@type table|fun(tag: string, field: "value_string"|"value_int"|"value_bool"|"value_float", default?: string|integer|boolean|number): VariableField
VariableField = setmetatable({}, {
    __call = function(t, tag, field, default)
        return setmetatable({tag = tag, field = field, default = default}, t)
    end,
})
VariableField.__index = VariableField
function VariableField:get(entity, k)
    local component = EntityGetFirstComponentIncludingDisabled(entity.id, "VariableStorageComponent", self.tag)
    if component ~= nil then
        return ComponentGetValue2(component, self.field)
    end
    EntityAddComponent2(entity.id, "VariableStorageComponent", {_tags = self.tag, [self.field] = self.default})
    if self.default == nil then
        if self.field == "value_string" then
            return ""
        elseif self.field == "value_int" then
            return 0
        elseif self.field == "value_bool" then
            return false
        end
        return 0
    end
    return self.default
end

function VariableField:set(entity, k, v)
    local component = EntityGetFirstComponentIncludingDisabled(entity.id, "VariableStorageComponent", self.tag)
    if component ~= nil then
        ComponentSetValue2(component, self.field, v)
        return
    end
    EntityAddComponent2(entity.id, "VariableStorageComponent", {_tags = self.tag, [self.field] = v})
end

local serialized_field = {}
serialized_field.__index = serialized_field
function serialized_field:get(entity, k)
    return deserialize(self[1]:get(entity, k))
end

function serialized_field:set(entity, k, v)
    self[1]:set(entity, k, serialize(v))
end

function SerializedField(field)
    return setmetatable({field}, serialized_field)
end

local object_metatable = {
    __call = function(t, getters)
        return setmetatable(t, {
            __index = function(t, k)
                local getter = getters[k]
                if getter ~= nil then
                    return getter(t, k)
                end
            end,
        })
    end,
}
function Object(t)
    return setmetatable(t, object_metatable)
end
