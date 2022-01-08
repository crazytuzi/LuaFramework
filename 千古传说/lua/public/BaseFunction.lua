--
-- Author: Zippo
-- Date: 2013-12-10 09:56:42
--

function CreatEnumTable( tbl,index )
    assert(type(tbl) == "table")
    local enumTbl   = {}
    local enumIndex = index or 0
    for i,v in ipairs(tbl) do
        enumTbl[v] = enumIndex + i
    end
    return enumTbl
end


