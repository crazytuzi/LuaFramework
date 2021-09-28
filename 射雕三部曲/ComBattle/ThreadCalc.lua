if TR == nil then
    function TR(srcStr)
        return srcStr
    end
end

local CORE = nil

require("ComLogic.common_func")
dump = function(obj)
    print(serialize(obj))
    print(debug.traceback())
end

function logic_init(string)
    CORE = require("ComLogic.LogicInterface").new()
    if not CORE then
        return "error -1"
    end

    local result = CORE:init(unseri(string))
    if result then
        return serialize(result)
    else
        return "error -2"
    end
end

function logic_calc(string)
    local result = CORE and CORE:calc(unseri(string))
    if result then
        return serialize(result)
    end

    return ""
end

function logic_release()
    CORE = nil
end
