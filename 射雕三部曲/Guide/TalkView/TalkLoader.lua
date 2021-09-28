--[[
    filename: TalkLoader.lua
    description: 读取新手引导对话配置数据
    date: 2015.10.10

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]
local DEF = TalkView.DEF

local TalkLoader = {}

--[[
将地图数据加载为链表格式：
{
    act_  = "model", -- 第一个动作
    data_ = {...},
    next_ = {
        act_  = "xxx", -- 第二个动作
        data_ = {...},
        next_ = {
            ...
        },
    },
}
--]]
function TalkLoader:load(map, cur_head_ptr)
    if type(map) == "string" or type(map) == "number" then
        local map_name = string.format("Guide.Talk.%s", map)
        dump(map_name, "load")
        map = clone(require(map_name))
        package.loaded[map_name] = nil
    end

    local tmpl = map["template"]
    map["template"] = nil
    return self:loadStepList(tmpl, map, cur_head_ptr)
end

-- @加载步骤列表
function TalkLoader:loadStepList(template, list, cur_head_ptr)
    -- 获取唯一字段作为事件名
    local get_action_name = next

    for i = #list, 1, -1 do
        local step = list[i]
        local act = get_action_name(step)

        local data = step[act] -- 数据

        -- 找到self.load_xxx
        local proc_name = "load_" .. act
        local proc = self[proc_name]

        if proc then
            -- 加载数据
            data = proc(self, template, data, cur_head_ptr)
        end

        if act == "insert" or act == "load" then
            cur_head_ptr = data
        else
            -- 链表节点
            local link_node = {
                act_  = act,
                data_ = data,
            }

            if act ~= "pick" then
                link_node.next_ = cur_head_ptr
            end

            cur_head_ptr = link_node
        end
    end

    return cur_head_ptr
end

-- #创建model
function TalkLoader:load_model(template, data, cur_head_ptr)
    if data.text then
        data.text = string.gsub(data.text, "@main",
            string.format("%s", PlayerAttrObj:getPlayerAttrByName("PlayerName")))
    end

    if data.name then
        data.name = string.gsub(data.name, "@main",
            string.format("%s", PlayerAttrObj:getPlayerAttrByName("PlayerName")))
    end

    -- 主角的形象特殊处理(非动画)
    if data.file == "_body_" then
        local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
        data.file = HeroModel.items[playerModelId].staticPic .. ".png"
    end

    if data.type == DEF.FIGURE then
        return self:loadModelFigure(template, data, cur_head_ptr)
    elseif data.type == DEF.ROLE then
        return self:loadModelRole(template, data, cur_head_ptr)
    elseif data.type == DEF.BUTTON then
        return self:loadModelButton(template, data, cur_head_ptr)
    elseif data.type == DEF.LABEL then
        self:loadModelLabel(template, data, cur_head_ptr)
    end

    return data
end

-- #创建动画
function TalkLoader:loadModelFigure(template, data)
    local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
    if data.file == "_lead_" then -- 主角展示动画
        data.file = HeroModel.items[playerModelId].largePic
    elseif data.file == "_run_" then -- 主角跑动动画
        data.file = HeroQimageRelation.items[playerModelId].runPic
    end

    data.animation = data.animation or "animation"
    if data.loop == nil then
        data.loop = true
    end

    return data
end

-- #创建角色
function TalkLoader:loadModelRole(template, data)
    if data.id == "_lead_" then
        data.id = FormationObj:getSlotInfoBySlotId(1).ModelId
    end

    return data
end

-- #按钮
function TalkLoader:loadModelButton(template, data, cur_head_ptr)
    data.click = self:loadStepList(template, data.click, cur_head_ptr)
    return data
end

-- #文字
function TalkLoader:loadModelLabel(template, data, cur_head_ptr)
    local sound = data.sound
    sound = Utility.getMusicFile(tonumber(sound)) or sound
    local soundTime = sound and TalkView.AudioLength[sound] or 3
    data.soundTime = soundTime

    -- 如果没有设定时长，则使用音效时长，并且显示时长多1秒
    if not data.time and soundTime then
        data.time = soundTime
        data.showTime = soundTime  -- showTime:显示时长
    elseif not data.showTime then
        data.showTime = data.time
    end

    if data.showTime and data.showTime > 0 and data.sync == nil then
        data.sync = true
    else
        data.sync = nil
    end

    local colorTag = {}
    local text = data.text
    repeat
        local i, j, clr = string.find(text, "({%x%x%x%x%x%x})")
        if not clr then
            break
        end

        local index = string.utf8len(string.sub(text, 0, i))
        table.insert(colorTag, index)

        text = string.gsub(text, string.sub(text, i, j), "")
    until false -- 死循环

    if next(colorTag) then
        data.colorTag = colorTag
        data.colorText = text
    end

    return data
end

-- #选项
function TalkLoader:load_pick(template, data, cur_head_ptr)
    for i, v in ipairs(data) do
        data[i] = self:loadModelButton(template, v, cur_head_ptr)
    end

    return data
end

-- #音效
function TalkLoader:load_sound(template, data, cur_head_ptr)
    local time = data.time or TalkView.AudioLength[data.file]
    if time and time > 0 then
        data.time = time
        if data.sync == nil then
            data.sync = true
        end
    end

    return data
end

-- #音乐
function TalkLoader:load_music(...)
    return self:load_sound(...)
end

-- #插入另外一个文件
function TalkLoader:load_insert(template, data, cur_head_ptr)
    return self:load(data.file, cur_head_ptr)
end

-- #插入模板
function TalkLoader:load_load(template, data, cur_head_ptr)
    local t = self:replaceParams(template[data.tmpl], data.params)

    if t then
        return self:loadStepList(template, t, cur_head_ptr)
    else
        return cur_head_ptr
    end
end

function TalkLoader:replaceParams(data, params)
    local function serialize(obj)
        local lua = ""
        local t = type(obj)
        if t == "number" then
            lua = lua .. obj
        elseif t == "boolean" then
            lua = lua .. tostring(obj)
        elseif t == "string" then
            lua = lua .. string.format("%q", obj)
        elseif t == "table" then
            lua = lua .. "{\n"
        for k, v in pairs(obj) do
            lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
        end
        local metatable = getmetatable(obj)
            if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"
            end
        end
            lua = lua .. "}"
        elseif t == "nil" then
            return nil
        else
            error("can not serialize a " .. t .. " type.")
        end
        return lua
    end

    local function unseri(seri_str)
        local f = load(seri_str)
        if f then
            return f()
        end
    end


    -- 序列化成字符串
    local lua = serialize(data)

    -- 替换参数
    repeat
        local i, j, num = string.find(lua, "\"@(%d+)\"")
        if num then
            local argv = params[tonumber(num)]
            lua = string.gsub(lua, string.sub(lua, i, j), string.format("\"%s\"", argv))
        end
    until num == nil

    return unseri("return " .. lua)
end


-- #执行动作
function TalkLoader:load_action(template, data, cur_head_ptr)
    if data.sync == nil and (data.what or (data.time and data.time > 0)) then
        data.sync = true
    end

    if data.what then
        local action = next(data.what)
        if not action then
            dump(data, "no action has be given")
        else
            if action == "loop" then
                if data.sync then
                    data.sync = nil
                end
            end
            data = self:loadAction(template, data, cur_head_ptr)
        end
    end

    return data
end

-- #加载单个action
function TalkLoader:loadAction(template, data, cur_head_ptr)
    local action = next(data.what)
    if action ~= "loop" then
        if action == "repeat" and #data.what["repeat"].action ==1 then
            data.what["repeat"].action
                = self:loadAction(template, data.what["repeat"].action[1], cur_head_ptr)
        elseif #data.what == 1 then
            data.what = self:loadAction(template, data.what[1], cur_head_ptr)
        end
    end

    return data
end


-- @查找tail
function TalkLoader:searchTail(p)
    if p then
        while p.next_ do
            p = p.next_
        end
    end

    return p
end


return TalkLoader
