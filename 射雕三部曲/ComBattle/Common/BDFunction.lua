--[[
    filename: ComBattle.BattleDefineConfig.BDFunction.lua
    description: 战斗模块功能函数
    date: 2016.08.12

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

require("ComLogic.common_func")
require("ComLogic.jsonlua")

local ipairs = ipairs
local pairs = pairs
local math_floor = math.floor
local table_insert = table.insert

local BDFunction = {
    random               = math.random,
    split                = ld.split,
    performWithDelay     = function(...)
        params = {...}
        local node, cb, delay
        if #params == 3 then
            node, cb, delay = unpack(params)
        else
            node = bd.layer
            cb, delay = unpack(params)
        end
        if not tolua.isnull(node) then
            Utility.performWithDelay(node, cb, delay)
        else
            bd.log.error(TR("找不到[node]"))
        end
    end,
    registerSwallowTouch = ui.registerSwallowTouch,
    isFileExist          = Utility.isFileExist,
    isDirectoryExist     = function(dir)
        cc.FileUtils:getInstance():isDirectoryExist(dir)
    end,
}

-- @bindProperty
--      将 properties 里的属性绑定到 obj 对象上（设置setter/getter）
--      添加属性变化通知
--  properties:
--  {
--      val1 = true,
--      t = {
--          val2 = false, -- false 只绑定 setter/getter，属性修改不会触发事件
--      },
--  }
function BDFunction.bindProperty(obj, properties)
    local function get_parent(meta, needCreate)
        local parent = obj
        for _, k in ipairs (meta) do
            if not parent[k] then
                if needCreate then
                    parent[k] = {}
                else
                    return nil
                end
            end
            parent = parent[k]
        end

        return parent
    end
    local function doBind(meta, prefix, properties)
        for property, needEvent in pairs(properties) do
            local curKey = prefix .. "_" .. property
            local eventName = string.sub(curKey, 2)
            -- bind时判断，不在setter里判断
            if type(needEvent) ~= "table" and needEvent then
                -- setter
                obj["set" .. curKey] = function(self, val)
                    local parent = get_parent(meta, true)
                    if parent[property] ~= val then
                        parent[property] = val
                        self:emit(eventName, val)
                    end
                    return self
                end
            else
                -- setter
                obj["set" .. curKey] = function(self, val)
                    local parent = get_parent(meta, true)
                    if parent[property] ~= val then
                        parent[property] = val
                    end
                    return self
                end
            end

            -- getter
            obj["get" .. curKey] = function(self, val)
                local parent = get_parent(meta)
                return parent and parent[property]
            end

            if type(needEvent) == "table" then
                property = property .. "_"
                local t = clone(meta)
                table_insert(t, property)
                doBind(t, curKey, needEvent)
            end
        end
    end
    -- 为属性 添加 setter/getter
    doBind({}, "", properties)

    bd.func.bindEvent(obj)

    return obj
end


function BDFunction.bindEvent(obj)
    -- 监听消息，触发消息时，所有listener一起执行
    obj.on = function(self, event, listener)
        if not self.listeners_ then
            self.listeners_ = {}
        end

        if not self.listeners_[event] then
            self.listeners_[event] = {}
        end
        table_insert(self.listeners_[event], listener)

        return self
    end

    -- 取消监听
    obj.off = function(self, event, listener)
        local all_cb = self.listeners_ and self.listeners_[event]
        if all_cb then
            for k, v in pairs(all_cb) do
                if v == listener then
                    table.remove(all_cb, k)
                    break
                end
            end
        end
    end

    -- 触发消息
    obj.emit = function(self, event, ...)
        self:dispatchEvent_(event, ...)
    end

    -- 分发消息
    obj.dispatchEvent_ = function(self, event, ...)
        local listeners = self.listeners_ and self.listeners_[event]
        if listeners then
            for _, cb in ipairs(listeners) do
                cb(...)
            end
        end
    end

    return obj
end


-- clone table except functions
function BDFunction.dumptable(t)
    if type(t) ~= "table" then
        return nil
    end
    local ret = {}

    for k, v in pairs(t) do
        local typeof = type(v)
        if typeof == "table" then
            ret[k] = bd.func.dumptable(v)
        elseif typeof ~= "function" then
            ret[k] = v
        end
    end
end


-- @对array各项调用fn
--
-- fn: (cont, item, key, array)
--     cont: 回调函数，用于表示fn执行完成
--     item: 列表项的值
--     key:  列表项的键
--     array:列表
--
--     fn执行完成后必须调用cont(err)
--     cont: (err) err表示fn是否出错，无错时传nil
--
-- cb: (err)
--     所有fn执行完成或者fn出错时调用
--     注: cb只会调用一次
function BDFunction.each(array, fn, cb)
    if (not array) or (next(array) == nil) then
        return cb and cb("array is empty")
    end

    local doneCnt, totalCnt = 0, #array

    local waiting_ = {}
    for i, v in ipairs(array) do
        waiting_[i] = true
        fn(function(err)
            if waiting_[i] then
                waiting_[i] = nil

                if (err ~= nil) then
                    waiting_ = {}
                    return cb and cb(err, v, i, array)
                end

                doneCnt = doneCnt + 1
                if (doneCnt == totalCnt) then
                    waiting_ = {}
                    return cb and cb()
                end
            end
        end, v, i, array)
    end
end



-- @对dict各项调用fn，与each类似
--
-- fn: (cont, item, key, dict)
--     cont: 回调函数，用于表示fn执行完成
--     item: 哈希表项的值
--     key:  哈希表项的键
--     dict: 哈希表
--
--     fn执行完成后必须调用cont(err)
--     cont: (err) err表示fn是否出错，无错时传nil
--
-- cb: (err)
--     所有fn执行完成或者fn出错时调用
--     注: cb只会调用一次
function BDFunction.foreach(dict, fn, cb)
    if (not dict) or (next(dict)) == nil then
        return cb and cb("dict is empty")
    end

    local doneCnt, totalCnt = 0, table.nums(dict)

    local waiting_ = {}
    for k, v in pairs(dict) do
        waiting_[k] = true
        fn(function(err)
            if waiting_[k] then
                waiting_[k] = nil

                if (err ~= nil) then
                    waiting_ = {}
                    return cb and cb(err, v, i, dict)
                end

                doneCnt = doneCnt + 1
                if (doneCnt == totalCnt) then
                    waiting_ = {}
                    return cb and cb()
                end
            end
        end, v, k, dict)
    end
end


-- @对dict各项逐个调用fn
--
-- fn: (cont, item, key, array)
--     cont: 回调函数，用于表示fn执行完成
--     item: 列表项的值
--     key:  列表项的键
--     array:列表
--
--     fn执行完成后必须调用cont(err)
--     cont: (err) err表示fn是否出错，无错时传nil
--     无错时，才会调用下一项
--
-- cb: (err)
--     所有fn执行完成或者fn出错时调用
--     注: cb只会调用一次
function BDFunction.foreachSeries(dict, fn, cb)
    if (not dict) or (next(dict) == nil) then
        return cb and cb("dict is empty")
    end

    local keys = bd.func.getKey(dict)
    bd.func.eachSeries(keys, function(cont, k)
        local v = dict[k]
        fn(cont, v, k, dict)
    end, cb)
end


-- @对array各项顺序调用fn
--
-- fn: (cont, item, key, array)
--     cont: 回调函数，用于表示fn执行完成
--     item: 列表项的值
--     key:  列表项的键
--     array:列表
--
--     fn执行完成后必须调用cont(err)
--     cont: (err) err表示fn是否出错，无错时传nil
--     无错时，才会调用下一项
--
-- cb: (err)
--     所有fn执行完成或者fn出错时调用
--     注: cb只会调用一次
function BDFunction.eachSeries(array, fn, cb)
    if (not array) or (next(array) == nil) then
        return cb and cb("array is empty")
    end

    local exec_
    local waiting_ = {}
    exec_ = function(i)
        local v = array[i]
        if not v then
            return cb and cb()
        end

        waiting_[i] = true
        fn(function(err)
            if waiting_[i] then
                waiting_[i] = nil

                if err ~= nil then
                    return cb and cb(err, v, i, array)
                else
                    exec_(i + 1)
                end
            end
        end, v, i, array)
    end

    exec_(1)
end


-- @序列化table
BDFunction.serialize = serialize


-- @反序列化
BDFunction.unseri = unseri

-- @json序列化
BDFunction.jsonEncode = _json._encode

-- @json反序列化
BDFunction.jsonDecode = _json._decode


function BDFunction.getRow(pos)
    local base = math_floor((pos - 1) / 3) * 3
    return base + 1, base + 2, base + 3
end


function BDFunction.getCol(pos)
    local base = ((pos - 1) % 3) + 1

    if pos >= 7 then
        base = base + 6
    end

    return base, base + 3
end


-- @获取key
function BDFunction.getKey(t)
    if not t then
        return
    end

    local k = {}
    for key in pairs(t) do
        table_insert(k, key)
    end

    return k
end


-- @调用次数达到X次后调用传入的回调
function BDFunction.getChecker(func, x)
    local cnt = 0
    bd.assert(func, "[func] invalid")
    return function()
        cnt = cnt + 1
        if cnt == x then
            return func()
        end
    end
end


return BDFunction
