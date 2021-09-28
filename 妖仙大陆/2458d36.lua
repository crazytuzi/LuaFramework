local ServerTime = require "Zeus.Logic.ServerTime"
local Item = require "Zeus.Model.Item"








local Model = {}








local titleList = nil


local titleTotalAtts = nil

local titleInfo = {
    fightPower = 0,         
    hasTitle = 0,           
    hasCDTitle = false,     
    usingTitleId = -1,      
    item = nil              
}


local totalAttMap = nil




local timeTitleMap = nil
local timeTitleMapSize = 0

local titleIdList = {}

function Model.GetTitleInfo()
    return titleInfo
end

function Model.GetTitleList()
    return titleList
end

function Model.GetTotalAttMap()
    return totalAttMap
end

function Model.GetTitleIdList()
    return titleIdList
end

function Model.RequestAwardTitleInfoAsync(cb)
    Pomelo.RankHandler.getRankInfoRequest(function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb(data.s2c_awardRanks)
        titleIdList = data.s2c_awardRanks or {}
    end,XmdsNetManage.PackExtData.New(false,false))
end

function Model.requestTitleInfo(cb)
    Pomelo.RankHandler.getRankInfoRequest(function(ex, sjson)
        if ex then return end
        
        local data = sjson:ToData()
        
        titleInfo.fightPower = data.s2c_fightPower
        titleInfo.usingTitleId = data.s2c_selectedRankId
        titleInfo.item = nil
        titleInfo.hasTitle = 0
        titleInfo.hasCDTitle = false
        totalAttMap = {}
        totalAttMap[999] = {}
        titleIdList = data.s2c_awardRanks or {}
        

        local one
        local s2c_awardRanks = data.s2c_awardRanks or {}
        for i,v in ipairs(titleList) do
            _, one = table.indexOfKey(s2c_awardRanks, "id", v.RankID)
            v.isAward = one ~= nil
            v.invalidTime = (one and one.invalidTime) or 0
            if v.isAward then
                titleInfo.hasTitle = titleInfo.hasTitle + 1
                if  v.invalidTime > 0 then
                    titleInfo.hasCDTitle = true
                end
                Model._addAttr(v.attrs, totalAttMap)
            end
            if v.RankID == data.s2c_selectedRankId then
                titleInfo.item = v
            end
        end

        

        
        
        
        if cb then 
            cb() 
        end
    end, XmdsNetManage.PackExtData.New(false, true))
end

function Model.requestSaveTitle(titleId)
    titleInfo.usingTitleId = titleId
    _, titleInfo.item = table.indexOfKey(titleList, "RankID", titleId)
    Pomelo.RankHandler.saveRankNotify(titleId)
    EventManager.Fire("Event.Title.TitleChange", {titleId = titleInfo.usingTitleId})
end

function Model.getsortId(titleId)
    if titleId and titleId > 0 then
        local rankData = GlobalHooks.DB.Find("RankList", {RankID = titleId})
        if rankData then
            return rankData[1].SortID
        end
    end
    return 1
end

function Model._addAttr( attrs, map )
    for _, v in ipairs(attrs) do
        local attr  = map[v.id]
        if not attr then
            attr = {id=v.id, value=v.value, minValue=v.minValue, maxValue=v.maxValue, isFormat=v.isFormat}
            map[v.id] = attr
            table.insert(map[999],v.id)
        else
            attr.minValue = attr.minValue + v.minValue
            attr.maxValue = attr.maxValue + v.maxValue
            if attr.minValue ~= attr.maxValue then
                attr.value = -1
            else
                attr.value = attr.value + v.value
            end
        end
    end
end





local splitAttrs = nil

local function createSplitAttrs()
    if splitAttrs then return splitAttrs end

    splitAttrs = {
        {"Def", "Ac", "Resist"},
        {"Attack", "Phy", "Mag"},
    }
    for _, one in ipairs(splitAttrs) do
        for i,v in ipairs(one) do
            one[i] = GlobalHooks.DB.Find("Attribute", {attKey=one[i]})[1].ID
        end
    end
end
function Model._splitWuGongMoGong(map)
    createSplitAttrs()

    for _,one in ipairs(splitAttrs) do
        if map[one[1]] then
            local attr = map[one[1]]
            map[one[1]] = nil
            Model._addAttr({
                {id=one[2], value=attr.value, minValue=attr.minValue, maxValue=attr.maxValue},
                {id=one[3], value=attr.value, minValue=attr.minValue, maxValue=attr.maxValue},
            }, map)
        end
    end
end

function Model._sortTittleList()
    table.sort( titleList, function(a, b)
        if a.isAward ~= b.isAward then
            return a.isAward
        else
            return a.RankOrder < b.RankOrder
        end
    end)
end

function Model._onNewTitlePush(ex, sjson)
    local data = sjson:ToData()
    titleIdList = titleIdList or {}
    table.insert(titleIdList,{id = data.s2c_awardRankId,invalidTime = 0})
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRoleGotTitle,0,data.s2c_awardRankId)
end

function Model.convertTitleList(titleList)
    
    for i,v in ipairs(titleList) do
        v.attrs = Item.FormatAttribute(v)
        v.isAward = false
        v.invalidTime = 0
    end
end

function Model.initial()
    if not titleList then
        titleList = GlobalHooks.DB.Find("RankList", {
            RankID = function() return true end,
            IfAppear = 1
        })
        
        Model.convertTitleList(titleList)

        
    end
end

function Model.fin( relogin )
    if relogin then
        titleList = nil
    end
end

function Model.InitNetWork()
    ServerTime:Sync()

    Pomelo.RankHandler.onAwardRankPush(Model._onNewTitlePush)
end


return Model
