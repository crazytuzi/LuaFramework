StringHelper = StringHelper or BaseClass()

function StringHelper.Split(target_str, spliter)
    if target_str and spliter then
        local result = {}

        for item in (target_str .. spliter):gmatch("(.-)" .. spliter) do
            table.insert(result, item)
        end

        return result
    end
end

function StringHelper.GetRepeatStr(target_str, count)
    if target_str and count then
        local result = ""
        for index = 1, count do
            result = result .. target_str
        end
        return result
    end
end

function StringHelper.ConcatTable(target_table)
    if not target_table then
        print("[StringHelper.ConcatTable]: target_table is nil.")
        return
    end

    local result = ""
    for index = 1, #target_table do
        result = result .. target_table[index]
    end
    return result
end

--返回字符串内容中，符合 两个符号中间有内容的格式的列表
function StringHelper.MatchBetweenSymbols(str, s1, s2)
    local m = {}
    local parten = string.format("%s(.-)%s", s1, s2)
    for a in string.gmatch(str, parten) do
        table.insert(m, a)
    end
    return m
end

-- 取到带颜色标签的字符串列表
function StringHelper.GetColorString(str)
    local back = {}
    local parten = "(<color.+</color>)"
    for result in string.gmatch(str, parten) do
        table.insert(back, result)
    end
    return back
end

function StringHelper.GetColorAndString(str)
    local back = {}
    local parten = "<color='(.-)'>(.+)</color>"
    for color,str in string.gmatch(str, parten) do
        table.insert(back, {color = color, str = str})
    end
    return back
end

-- 返回按字符串一个个字符分开的列表
function StringHelper.ConvertStringTable(str)

    -- 取到带颜色的字符串,这串东西做一次显示
    local colors = StringHelper.GetColorString(str)

    -- 保存已开始位置为Key，结束位置为值
    local colorTab = {}
    for _,colorStr in ipairs(colors) do
        local startVal,endVal = string.find(str, colorStr)
        colorTab[startVal] = endVal
    end

    local back = {}
    local len = string.len(str)
    local current = 1
    local count = 0
    while current <= len do
        if colorTab[current] ~= nil then
            local one = string.sub(str, current, colorTab[current])
            table.insert(back, one)
            current = colorTab[current] + 1
        else
            local byteCount = string.byte(str, current)
            if byteCount == 194 then
                count = count + 1
                if count == 2 then
                    local one = string.sub(str, current, current + count - 1)
                    table.insert(back, one)
                    current = current + count
                    count = 0
                end
            elseif byteCount > 127 then
                count = count + 1
                if count == 3 then
                    local one = string.sub(str, current, current + count - 1)
                    table.insert(back, one)
                    current = current + count
                    count = 0
                end
            else
                local one = string.sub(str, current, current)
                table.insert(back, one)
                current = current + 1
            end
        end
    end
    return back
end