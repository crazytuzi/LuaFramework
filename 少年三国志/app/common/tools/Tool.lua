-- Help Function

-- Global Variable or Function

-- read only table
function readOnly (t)
    local proxy = {}
    local mt = { -- create metatable
    __index = t,
    __newindex = function (t,k,v)
    error("attempt to update a read-only table", 2)
    end
    }
    setmetatable(proxy, mt)
    return proxy
end

-- 解析protobuf message，因为现有的解析protobuf无法直接解析嵌套类的消息，所以这里编写一个递归方法来解析
function decodeBuf(key, buff, len)

    local function _decodeTable(t)
        local _t = {}
        if type(t[1]) == "table" then
            for i=1, #t do
                _t[i] = decodeBuf(t[i][1], t[i][2])
            end
        else
            _t = decodeBuf(t[1], t[2])
        end

        return _t
    end
    
    local decodeBuf = protobuf.decode(key, buff, len)
    for k, v in pairs(decodeBuf) do
        if type(v) == "table"  then
            decodeBuf[k] = _decodeTable(v)
        end
    end
    
    return decodeBuf
end

function decodeJsonFile(jsonFileName)
    
    local json = require "framework.json"
    local jsonString = CCFileUtils:sharedFileUtils():getEncryptFileData(jsonFileName)
    assert(jsonString, "Could not read the json file with path: "..jsonFileName)
    
    local jsonConfig = json.decode(jsonString)
    
    return jsonConfig
end

function dumpTable(k, t, blank)
    
    k = k or "message"
    
    blank = blank or ""
    if type(k) == "string" then k = "\""..k.."\"" end
    print(blank.."["..tostring(k).."]".." = {")

    local _blank = blank

    blank = blank.."    "
    
    for k, v in pairs(t) do
        if type(v) == "table" then
            dumpTable(k, v, blank)
        else
            if type(k) == "string" then k = "\""..k.."\"" end
            if type(v) == "string" then
                print(blank.."["..tostring(k).."] = \""..tostring(v).."\",")
            else
                print(blank.."["..tostring(k).."] = "..tostring(v)..",")
            end
        end
    end
        
    print(_blank.."},")
end


--想调用self._listView:reloadWithLength(#listData, startIndex)
--startIndex要保证 目标cellIndex尽量居中
function calculateListViewCenterIndex(cellHeight, listViewHeight, cellCount, cellIndex)
    --现在一页能显示几个单元格
    local pageCount = listViewHeight/cellHeight
    local halfCount = math.floor(pageCount/2)

    if cellCount < pageCount then
        --条目太少,啥都不干
        return 0
    end

    --在listview以外不显示的单元格数目
    --local maxOutsideCells = cellCount -pageCount 
    local startIndex = cellIndex - halfCount
    if startIndex <0 then
        startIndex = 0
    end

    -- --露出上面部分:
    -- local upOutsideCells = startIndex
    -- if upOutsideCells > maxOutsideCells then
    --     startIndex = math.floor(maxOutsideCells)
    --     print("startIndex2=" .. startIndex)

    -- end

    -- --露出下面部分
    -- if cellCount - startIndex - pageCount  > maxOutsideCells then
    --     startIndex = math.ceil(cellCount - maxOutsideCells - pageCount)
    --     print("startIndex3=" .. startIndex)

    -- end

    
    return startIndex


end

function shuffled(tab)
    local n, order, res = #tab, {}, {}
     
    for i=1,n do order[i] = { rnd = math.random(), idx = i } end
    table.sort(order, function(a,b) return a.rnd < b.rnd end)
    for i=1,n do res[i] = tab[order[i].idx] end
    return res
end
