
function split(s, delim)
    local start = 1  local t = {}
    while true do
        local pos = string.find (s, delim, start, true)
        if not pos then
            break
        end
        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))
    return t
end

function getTableLen(input)
	local ret = 0
    for i, v in pairs(input) do
        ret = ret + 1
    end
    return ret
end

function random_table(input, count)
    local temp = {}
    for k,v in pairs(input) do
        table.insert(temp, v)
    end
    local selected={}
    math.randomseed(os.time())
    if #input<=count then return temp end

    while #selected < count do
        local bingo = math.random(#temp)
        table.insert(selected,table.remove(temp, bingo))
    end
    return selected
end

