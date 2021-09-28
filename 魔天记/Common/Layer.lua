
Layer =
{
    ["Default"] = 0,
    ["TransparentFX"] = 1,
    ["Ignore Raycast"] = 2,
    ["Water"] = 4,
    ["UI"] = 5,
    ["Phy"] = 10,
    ["Monster"] = 11,
    ["NPC"] = 12,
    ["Player"] = 13,
    ["Hero"] = 14,
    ["UIModel"] = 15,
    ["Effect"] = 16,
    ["ReceiveShadow"] = 17,
    ["UnActiveUI"] = 18,
}

LayerMask =
{
    value = 0,
}

setmetatable(LayerMask, LayerMask)

LayerMask.__call = function(t, v)
    return LayerMask.New(v)
end

function LayerMask.New(value)
    local layer = { value = 0 }
    layer.value = value and value or 0
    setmetatable(layer, LayerMask)
    return layer
end

function LayerMask.NameToLayer(name)
    return Layer[name]
end

function LayerMask.MultiLayer(...)
    local arg = { ...}
    local value = 0

    for i = 1, #arg do
        value = value + bit.lshift(1, LayerMask.NameToLayer(arg[i]))
    end

    return value
end
function LayerMask.GetMask(...)
    local arg = { ...}
    local value = 0

    for i = 1, #arg do
        local n = arg[i]
        -- LayerMask.NameToLayer(arg[i])
        -- logTrace(arg[i] .. "___" .. tostring(n))
        if n ~= 0 then
            value = value + 2 ^ n
        else
            value = value + 1
        end
    end

    return value
end


function LayerMask.HasMask(mask, targetMask)
    -- Warning(mask .."___" .. targetMask .."___" .. bit:_and(mask , targetMask))
    -- Warning(bit:d2b(mask) .."___" .. bit:d2b(targetMask) .."___" .. bit:d2b(bit:_and(mask , targetMask)))
    return bit:_and(mask, targetMask) == mask
end
