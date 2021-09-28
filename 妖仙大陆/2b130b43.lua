local _M = {}
_M.__index = _M


local cjson     = require "cjson"
local Util      = require "Zeus.Logic.Util"
local ChatUtil  = require "Zeus.UI.Chat.ChatUtil"

local function MapSend(data)
    local msg = Util.GetText(TextConfig.Type.FRIEND,'cost_complement')  
    local sdata = {}
    sdata[1] = 100
    msg = ChatUtil.HandleString(msg, sdata)
    GameAlertManager.Instance:ShowAlertDialog(
        AlertDialog.PRIORITY_NORMAL, 
        msg,
        nil,
        nil,
        Util.GetText(TextConfig.Type.FRIEND,'information_confirmation'),
        nil,
        function()
            
            FriendModel.changeAreaByPlayerIdRequest(data.id, 1, function(data)
                
            end)
        end,
        nil)
end

function _M.PathSeekAlert(data)
    
    if data.currentPos ~= nil and data.currentPos.areaId ~= 0 then
        local msg = Util.GetText(TextConfig.Type.FRIEND,'selected_mode')
        local sdata = {}
        sdata[1] = string.format("%08X",  GameUtil.RGBA_To_ARGB(ChatUtil.PorColor["PorColor" .. data.pro]))
        sdata[2] = data.name
        sdata[3] = data.currentPos.areaName .. "(" .. data.currentPos.targetX .. "," .. data.currentPos.targetY .. ")"
        msg = ChatUtil.HandleString(msg, sdata)

        GameAlertManager.Instance:ShowAlertDialog(
        AlertDialog.PRIORITY_NORMAL, 
        msg,
        nil,
        nil,
        nil,
        nil,
        function()
            
            DataMgr.Instance.UserData:Seek( data.currentPos.areaId, data.currentPos.targetX,  data.currentPos.targetY)
            EventManager.Fire("Event.Menu.CloseFuncEntryMenu",{})
            MenuMgrU.Instance:CloseAllMenu()
        end,
        nil
        )
    else
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.FRIEND,'friend_offline'))
        
    end
end

local function InitItem(ui, node)
    
    local UIName = {
        "lb_name",
        "lb_vipnum",
        "lb_rolelevelnum",
        "lb_forcename",
        "ib_headicon",
        "lb_lvnum",
        "lb_fight",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

function _M.InitHeadInfor(ui, node, data)
    InitItem(ui, node)

    ui.lb_name.Text = data.name
    ui.lb_name.FontColorRGBA = ChatUtil.PorColor["PorColor" .. data.pro]
    ui.lb_vipnum.Text = data.vip
    ui.lb_lvnum.Text = data.level
    
    
    if data.stageLevel ~= nil and data.stageLevel > 0 then
        local text, rgba = Util.GetUpLvTextAndColorRGBA(data.stageLevel)
        ui.lb_rolelevelnum.Text = text
        ui.lb_rolelevelnum.FontColorRGBA = rgba
    else
        ui.lb_rolelevelnum.Text = Util.GetText(TextConfig.Type.FRIEND,'uplv0')  
        ui.lb_rolelevelnum.FontColorRGBA = 0xffffffff
    end
    Util.HZSetImage(ui.ib_headicon, "static_n/hud/target/" .. data.pro .. ".png", false)
    ui.lb_fight.Text = data.fightPower
    

    if data.guildId == nil or string.gsub(data.guildId, " ", "") == "" then
        ui.lb_forcename.Text = "-----"
        
        
    else
        ui.lb_forcename.Visible = true
        ui.lb_forcename.Text = data.guildName
        
        
    end
end

function _M.SortFriendDataList(data)
    
    if data == nil then
        return
    end
    table.sort(data, function (aa,bb) 
        if  aa.isOnline > bb.isOnline then
            return true
        end
        return false
    end)
end

function _M.GetOnlineNumFromList(data)
    
    local online = 0
    local total = 0
    if data ~= nil then
        total = #data
        for i,v in ipairs(data) do
            if v.isOnline == 1 then
                online = online + 1
            end
        end
    end
    return online, total
end

function _M.FillSocialFriendCan(data, canvas, i)
    local nameLabel = canvas:FindChildByEditName("lb_name"..i, true)
    local levelLabel = canvas:FindChildByEditName("lb_level"..i, true)
    
    Util.SetLabelShortText(nameLabel, data.name)
    nameLabel.FontColor = GameUtil.RGBA2Color(GameUtil.GetProColor(data.pro))
    
    
    local levelText = Util.GetText(TextConfig.Type.PUBLICCFG, 'Lv.n', data.level)
    
        
    
    Util.SetLabelShortText(levelLabel, levelText)
    
        
        
    
        
    

    
    
    
end

return _M
