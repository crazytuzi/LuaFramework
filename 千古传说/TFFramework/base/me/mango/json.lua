json = {}
local cjson = require("cjson")
cjson.encode_keep_buffer(false)

function json.encode(var)
    local status, result = pcall(cjson.encode, var)
    if status then return result end
    if DEBUG > 1 then
        echoError("json.encode() - encoding failed: %s", tostring(result))
    end
end

function json.decode(text)
    local status, result = pcall(cjson.decode, text)
    if status then return result end
    if DEBUG > 1 then
        echoError("json.decode() - decoding failed: %s", tostring(result))
    end
end

json.null = cjson.null

return json