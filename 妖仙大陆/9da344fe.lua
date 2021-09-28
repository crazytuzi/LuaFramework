local _M = {}
_M.__index = _M


local cjson                 = require "cjson"
local Util                  = require "Zeus.Logic.Util"
local ChatUtil              = require "Zeus.UI.Chat.ChatUtil"
local ExchangeUtil          = require "Zeus.UI.ExchangeUtil"
local MapModel              = require 'Zeus.Model.Map'

_M.pointAnchor = {
    top = 1,
    center = 2,
    bottom = 3,
}

_M.chatcolor = {
    colortype1 = 0xffe7d795,     
    colortype2 = 0xffe7e5d1,     
    colortype3 = 0xff5e5e5e,     
    colortype4 = 0xff5bc61a,     
    colortype5 = 0xff68efff,     
    colortype6 = 0xffcc00ff,     
    colortype7 = 0xffef880e,     
    colortype8 = 0xfff43a1c,     
}

_M.secondMapSetting = {
    {
        {"0","1", "2", "3", "4", "5", "6", "7","8","9","10","11","12","13","14","15","16"},   
        {"ib_worldmap0", "ib_worldmap1", "ib_worldmap2", "ib_worldmap3", "ib_worldmap4", "ib_worldmap5", "ib_worldmap6", "ib_worldmap7", "ib_worldmap8"
        , "ib_worldmap9", "ib_worldmap10", "ib_worldmap11", "ib_worldmap12", "ib_worldmap13", "ib_worldmap14", "ib_worldmap15", "ib_worldmap16"}, 
        10000,                                                                                                                                   
    },
    {
        {"0","1", "2", "3", "4", "5", "6", "7","8","9","10","11","12","13","14","15","16"},
        {"ib_worldmap0", "ib_worldmap1", "ib_worldmap2", "ib_worldmap3", "ib_worldmap4", "ib_worldmap5", "ib_worldmap6", "ib_worldmap7", "ib_worldmap8"
        , "ib_worldmap9", "ib_worldmap10", "ib_worldmap11", "ib_worldmap12", "ib_worldmap13", "ib_worldmap14", "ib_worldmap15", "ib_worldmap16"},
        11000,
    },
}

local selfTime = nil

function _M.GetMapIndexBySceneId(sceneId)
    
    local btnName = "" .. sceneId
    for i = 1, #_M.secondMapSetting do
        for j = 1, #_M.secondMapSetting[i][1] do
            if _M.secondMapSetting[i][1][j] == btnName then
                return i
            end
        end
    end
    return 1
end

function _M.SetPointPos(point, x, y, anchor, mapInfo)
    
    point.X = x * mapInfo.scaleX + mapInfo.imgOffX - point.Width / 2
    point.Y = y * mapInfo.scaleY + mapInfo.imgOffY - point.Height / 2
    if anchor == _M.pointAnchor.top then
        point.Y = point.Y + point.Height / 2
    elseif anchor == _M.pointAnchor.bottom then
        point.Y = point.Y - point.Height / 2
    end
end

local function DealSnapData(regionSnapData)
    
    local itemList = {}
    itemList = Util.DictionaryToLuaTable(GameUtil.PropertiesToDictionary(regionSnapData.attributes))
    itemList.x = regionSnapData.x
    itemList.y = regionSnapData.y
    
    
    
    
    
    
    
    
    
    
    return itemList
end

function _M.GetSceneSnapData(SceneId)
    local curData = {
        npcList = {},
        monsterList = {},
        otherList = {}
    }
    local data = SceneSnapManager.LoadSceneSnapData(SceneId)
    if data.name == nil then
        curData.name = Util.GetText(TextConfig.Type.MAP, "losename")
    else
        curData.name = data.name
    end
    curData.mapW = data.width
    curData.mapH = data.height
    local list = Util.List2Luatable(data.regions)
    
    
    for i = 1, #list do
        local regionSnapData = list[i]
        local itemList = DealSnapData(regionSnapData)
        if itemList.type == "npc" then
            curData.npcList[#curData.npcList + 1] = itemList
            local state = DataMgr.Instance.QuestManager:GetNpcBehavior(itemList.id)
            
            local daily_quest = state > 10
            state = (state > 10 and (state - 10) or state)

            if state == 1 then
                if daily_quest then
                    itemList.icon = "#dynamic_ndynamic_new/map/map.xml|map|13"
                else
                    itemList.icon = "#dynamic_ndynamic_new/map/map.xml|map|4" 
                end
            elseif state == 2 then
                itemList.icon = "#dynamic_ndynamic_new/map/map.xml|map|6"
            elseif state == 3 then
                if daily_quest then
                    itemList.icon = "#dynamic_ndynamic_new/map/map.xml|map|14"
                else
                    itemList.icon = "#dynamic_ndynamic_new/map/map.xml|map|5" 
                end
            else
                if itemList.icon == "" then
                    itemList.icon = "#dynamic_ndynamic_new/map/map.xml|map|10"
                end
            end
        elseif itemList.type == "monster" then
            curData.monsterList[#curData.monsterList + 1] = itemList
        else
            curData.otherList[#curData.otherList + 1] = itemList
        end  
    end

    return curData
end

function _M.InitNodeLayout(node, pathName)
    
    local pos = string.find(pathName, "#")
    if(pos and pos == 1)then
        node.Layout = XmdsUISystem.CreateLayoutFroXml(pathName, LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    else
        node.Layout = XmdsUISystem.CreateLayoutFromFile("static_n/hud/target/" .. pathName .. ".png", LayoutStyle.IMAGE_STYLE_ALL_9, 8)
    end
end

function _M.DealIntToTime(time)
    
    local min = math.floor(time / 60) 
    local second = math.floor(time % 60)
    local minstr
    local secondstr
    if min < 10 then
        minstr = "0" .. min
    else
        minstr = "" .. min
    end

    if second < 10 then
        secondstr = "0" .. second
    else
        secondstr = "" .. second
    end
    return minstr .. ":" .. secondstr
end

function _M.DealTeamList()
    local dataList = {}
    local list = Util.List2Luatable(DataMgr.Instance.TeamData.TeamList)
    for i = 1, #list do
        table.insert(dataList, list[i])
    end
    return dataList
end

local function HandleSendMap(id, str, cb)
    GameAlertManager.Instance.AlertDialog:ShowAlertDialogWithCloseBtn(
        AlertDialog.PRIORITY_NORMAL, 
        "<f>" .. str .. "</f>",
        Util.GetText(TextConfig.Type.QUEST, 'trans_btn2'),
        Util.GetText(TextConfig.Type.QUEST, 'trans_btn1'),
        Util.GetText(TextConfig.Type.FRIEND,'delivery'),
        nil,
        function()
            if BattleClientBase.GetActor().CombatState then
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILD, "fighting"))
                return
            end
            GameSceneMgr.Instance.BattleRun.BattleClient:StopSeek()

            MapModel.transByAreaIdRequest(id, function(params)
                print("   MapModel.transByAreaIdRequest")
                DataMgr.Instance.UserData:StopSeek()
                EventManager.Fire("Event.Quest.CancelAuto", {});
                
                if cb ~= nil then
                    cb()
                end
                UnityEngine.PlayerPrefs.SetString("DateTimeChangeMap", System.DateTime.Now:ToString())
            end)
        end,
        function( ... )
            
            EventManager.Fire("Event.Quest.CancelAuto", {});
            if cb ~= nil then
                cb(1)
            end
        end
    )
end

function _M.OnMapClick(ThirdSenceId, mapdata, cb)
    
    
    
    local sceneType = tostring(DataMgr.Instance.UserData.SceneType)
    local str = split(ChatUtil.ParametersValue("Transfer.SceneType"), ",")
    local findscene = false
    if #str ~= nil then
        for i = 1, #str do
            
            if sceneType == str[i] then
                findscene = true
                break
            end
        end
    end
    if findscene == false then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP,'nochuansong'))   
        return
    end

    if mapdata.state == 1 then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP,'nowstay'))   
    elseif mapdata.state == 3 then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP,'needlv_not'))  
    elseif mapdata.state == 4 then
        GameAlertManager.Instance:ShowNotify(mapdata.ret[1].UpName .. Util.GetText(TextConfig.Type.MAP,'cangotomap')) 
    elseif mapdata.state == 5 then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.MAP,'no_open_version')) 
    else
        local time = 10000
        if selfTime ~= nil and selfTime ~= "" then
            time = (System.DateTime.Now - selfTime).TotalMilliseconds / 1000 
        end
        
        if time > 300 then
            local itemName = ExchangeUtil.GetItemNameByCode(mapdata.ret[1].CostItem)

            
            local str = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAP, "shifouchuansong")
            local data = {}
            data[1] = mapdata.ret[1].Name
            str =  ChatUtil.HandleString(str, data)
            
            if itemName ~= nil then
                str = str .. "<br/>" .. ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAP, "xiaohao") .. itemName .. "*" .. mapdata.ret[1].CostItemNum 
                local vItem = DataMgr.Instance.UserData.RoleBag:MergerTemplateItem(mapdata.ret[1].CostItem)
                local cur_num = (vItem and vItem.Num) or 0
                str = str .. Util.GetText(TextConfig.Type.MAP, "have", cur_num) .. ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAP, "vipnocost")
            end
            HandleSendMap(tonumber(ThirdSenceId), str, cb)
        else
            local str = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MAP, "chuansonglengque")
            local data = {}
            time = 300 - time
            data[1] = SceneMapUtil.DealIntToTime(time)
            str =  ChatUtil.HandleString(str, data)
            GameAlertManager.Instance:ShowAlertDialog(
                AlertDialog.PRIORITY_NORMAL, 
                "<f>" .. str .. "</f>",
                nil,
                nil,
                nil
            )
        end
    end
end

return _M
