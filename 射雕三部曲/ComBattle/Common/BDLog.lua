--错误类型
--[[
    1.spine资源缺失
    2.服务器端反馈spine形象缺失
    3.服务器端反馈战斗数据错误
    4.技能配置缺失
    5.技能特效缺失

]]

local ERROR_TYPE = {
    [1] = TR("错误测试！"),
}

local function p_info_tail(text)
    print("--------------------------------------------------------------------------------")
    -- local len = string.utf8len(text)
    -- if len > 80 then
    --     print(text)
    -- elseif len > 0 then
    --     local s1 = ""
    --     local s2 = ""
    --     for i = 1, (80 - len) / 4 do
    --         s1 = s1 .. "^ "
    --         s2 = s2 .. "--"
    --     end

    --     s1 = s1 .. text
    --     for i = 1, len do
    --         s2 = s2 .. "="
    --     end

    --     for i = 1, (80 - len) / 4 do
    --         s1 = s1 .. " ^"
    --         s2 = s2 .. "--"
    --     end

    --     print(s1)
    --     print(s2)
    -- end
end


local function p_info_title(text)
    local len = string.utf8len(text)
    if len > 80 then
        print(text)
    elseif len > 0 then
        local fix = (80 - len) / 4
        local s1 = ""
        local s2 = ""
        for i = 1, math.floor(fix) do
            s1 = s1 .. "--"
            s2 = s2 .. "v "
        end

        for i = 1, len do
            s1 = s1 .. "="
        end
        s2 = s2 .. text

        for i = 1, math.ceil(fix) do
            s1 = s1 .. "--"
            s2 = s2 .. " v"
        end

        print(s1)
        print(s2)
    end
end

local function make_log_lv(name, trace)
    -- local header = string.format("---------------------------%s---------------------------", name)
    return function(data, title)
        if title then
            p_info_title(string.format("[%s] %s", name, title))
        else
            p_info_title(name)
        end
        if type(data) == "table" then
            dump(data, title)
        elseif title then
            print(string.format("### %s: %s ###", title , data))
        else
            print(string.format("### %s ###" , data))
        end
        if trace then
            print(debug.traceback())
        end
        p_info_tail("end end end")
    end
end

local BDLog
BDLog = {
    dump = function()end,

    lv_ = 30,
    level = {
        eDebug     = 10,
        eInfo      = 20,
        eWarnning  = 30,
        eDataError = 40,
        eError     = 50,
        eNoLog     = 99999,
    },

    do_nothing = function(...) end,

    setLevel = function(lv)
        BDLog.lv_ = lv

        local log_2_lv = {
            ["debug"]    = BDLog.level.eDebug,
            ["info"]     = BDLog.level.eInfo,
            ["warnning"] = BDLog.level.eWarnning,
            ["dataerr"]  = BDLog.level.eDataError,
            -- ["error"]    = BDLog.level.eError,
        }

        for k, l in pairs(log_2_lv) do
            if lv > l then
                BDLog[k] = BDLog.do_nothing
            else
                BDLog[k] = make_log_lv(string.upper(k), l >= BDLog.level.eError)
            end
        end
    end,

    assert = function(v, ...)
        return (not v) and BDLog.error(...)
    end,

    error = function(data, title)
        if BDLog.lv_ > BDLog.level.eError then
            return
        end

        if title then
            title = string.format("[ERROR] %s", title)
        else
            title = "ERROR"
        end

        if type(data) == "table" then
            dump(data, title)
            error(title)
        elseif title then
            error(string.format("### %s: %s ###", title , data))
        else
            error(string.format("### %s ###", data))
        end
    end,
}

BDLog.setLevel(BDLog.level.eWarnning)

return BDLog
