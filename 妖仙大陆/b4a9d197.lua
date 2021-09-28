local Util = require 'Zeus.Logic.Util'
local TeamUtil = {}


function TeamUtil.makeTeamTargetList()
    local list = GlobalHooks.DB.Find("TeamTarget", {})
    local dataList = {}
    local map = {}
    for _,v in ipairs(list) do
        if v.TabIndex == 0 then
            local item = {name = v.TargetName, items = {}, data = v}
            table.insert(dataList, item)
            map[v.TabType] = item
        end
    end
    table.sort(dataList, function(a, b) return a.data.TabType < b.data.TabType end)
    for _,v in ipairs(list) do
        if v.TabIndex ~= 0 then
            local item = {name = v.TargetName, items = {}, data = v}
            if tonumber(v.OpenLv) <= tonumber(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)) then
                table.insert(map[v.TabType].items, item)
            end
        end
    end
    local function typeIndexSortComp(a, b) return a.data.TabIndex < b.data.TabIndex end

    local num = #dataList
    for i=num,1,-1 do
        local v = dataList[i]

        if #(v.items) ==0 then
            table.remove(dataList,i)
        else
            table.sort(v.items, typeIndexSortComp)
        end
    end

    return dataList
end

function TeamUtil.findTeamTargetProp(targetID)
    local list = TeamUtil.makeTeamTargetList()
    for k,v in pairs(list) do
        for m,n in pairs(v.items) do
            if n.data.ID == targetID then
                local prop = {}
                prop.name = v.name
                prop.prop = n.data
                return prop
            end
        end
    end
    return nil
end

function TeamUtil.findTargetIdByMapId(mapId)
    
    local list = TeamUtil.makeTeamTargetList()
    for k,v in pairs(list) do
        for m,n in pairs(v.items) do
            
            if n.data.NormalMapID == mapId or n.data.EliteMapID == mapId or n.data.HeroMapID == mapId then
                return n.data.ID
            end
        end
    end
    return nil
end

function TeamUtil.getTeamTargetIdxs(list, targetId)
    for i,v in ipairs(list) do
        if v.data.ID == targetId then
            return i, nil
        end
        for ii,vv in ipairs(v.items) do
            if vv.data.ID == targetId then
                return i, ii
            end
        end
    end
    return nil, nil
end

function TeamUtil.queryTeamTargetId(mapid, difficulty)
    local targetId = 0
    local mapType = {"NormalMapID","EliteMapID","HeroMapID"}
    local db = unpack(GlobalHooks.DB.Find('TeamTarget', { [mapType[difficulty]]=mapid } ))
    if db ~= nil then
        targetId = db.ID
    end
    return targetId
end

local stringformat_unLimit = ""
local stringformat_lv = Util.GetText(TextConfig.Type.TEAM,'levelLimit')
local stringformat_final = Util.GetText(TextConfig.Type.TEAM,'textLv')

function TeamUtil.getTargetLvText(lvLeast, lvMax)
    if lvLeast == 0 and lvMax == 0 then
        return stringformat_unLimit
    end
    local lea = ""
    if lvLeast == 0 then
        lea = stringformat_unLimit
    else
        lea = string.format(stringformat_lv, lvLeast)
    end
    local max = ""
    if lvMax == 0 then
        max = stringformat_unLimit
    else
        max = string.format(stringformat_lv, lvMax)
    end
    return string.format(stringformat_final, lea, max)
end

function TeamUtil.getTargetAllText(targetid)
    
end

return TeamUtil
