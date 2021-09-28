local _M = {}
_M.__index = _M


local Util          = require "Zeus.Logic.Util"
local ServerTime    = require"Zeus.Logic.ServerTime"
local InteractiveMenu = require "Zeus.UI.InteractiveMenu"
local DaoyouModel   = require "Zeus.Model.Daoyou"

local self = {
    m_Root = nil,
}

local function DealTimeStr(time)
    if time < 60 then
        return Util.GetText(TextConfig.Type.ALLY, "Just")
    elseif time < 60*60 then
        return math.floor(time / 60) .. Util.GetText(TextConfig.Type.ALLY, "BeforeMinute")
    elseif time < 60*60*24 then
        return math.floor(time / 3600) .. Util.GetText(TextConfig.Type.ALLY, "BeforeHour")
    else
        return math.floor(time / 60 / 60 / 24) .. Util.GetText(TextConfig.Type.ALLY, "BeforeDay")
    end
end

local function DealTimeStrColor(time)
    local str = DealTimeStr(time)
    local color = nil
    if time > 60*60*24 then
        color = "ff" .. Util.GetText(TextConfig.Type.ALLY, "colour1") 
    else
        color = "ff" .. Util.GetText(TextConfig.Type.ALLY, "colour2")
    end
    return "<f color = '" .. color .. "'>(" .. str .. ")</f>"
end

local function RefreshMsgCellData(node, data, index)
    local str = ""
    if data.type == 1 then
        str = Util.GetText(TextConfig.Type.DAOYOU, "System")
    elseif data.type == 2 then
        str = Util.GetText(TextConfig.Type.DAOYOU, "Message")
    else
        str = Util.GetText(TextConfig.Type.DAOYOU, "Notice")
    end
    local time = DealTimeStrColor(ServerTime.GetServerUnixTime() - data.time)
    
    local tbh_information = node:FindChildByEditName("tbh_information", true)
    tbh_information.XmlText = "<f>" ..  str .. data.content .. time .. "</f>"
    node.Height = tbh_information.TextComponent.RichTextLayer.ContentHeight
end

local function SetDaoqunMessage()
    local msgCount = 0
    if self.DaoqunInfo.message then
        msgCount = #self.DaoqunInfo.message
    end
    self.cvs_inform:Initialize(
            self.cvs_cell.Width + 0, 
            self.cvs_cell.Height + 0, 
            msgCount,
            1,
            self.cvs_cell, 
            function(x, y, cell)
                local index = y + 1
                local data = self.DaoqunInfo.message[index]
                RefreshMsgCellData(cell, data, index)
            end,
            function() end
        )
end

local function OpenInviteUI()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialDaoyouInvite,0)
end

local function SetDaoqunNotice(string)
    self.tb_announcement.XmlText = string
end

local function ConfirmCb(id, data)
    if id == 31 then    
        DaoyouModel.KickMumberRequest(data.playerId, function()
            if #self.DaoqunInfo.dyInfo == 2 then
                MenuMgrU.Instance:CloseAllMenu()
            else
                EventManager.Fire("Event.Daoqun.NeedRefreshDaoqunUI", {})
            end
        end)
    elseif id == 32 then  
        DaoyouModel.TransferAdminRequest(data.playerId, function()
            EventManager.Fire("Event.Daoqun.NeedRefreshDaoqunUI", {})
        end)
    elseif id == 34 then  
        if not self.isAdmin then
            DaoyouModel.LeaveDaoqunRequest(function()
                MenuMgrU.Instance:CloseAllMenu()
            end)
        end
    end
end

local function InteractiveMenuCb(id, data)
    local title
    local content
    local oneButton = false
    

    if id == 31 then    
        title = Util.GetText(TextConfig.Type.DAOYOU, "IsKick")
        if #self.DaoqunInfo.dyInfo == 2 then
            content = Util.GetText(TextConfig.Type.DAOYOU, "Word1")
        else
            content = DaoyouModel.GetKickedOutAllyStr(data)
        end
    elseif id == 32 then  
        title = Util.GetText(TextConfig.Type.DAOYOU, "ChangeMaster")
        content = DaoyouModel.GetChangeAllyStr(data)
    elseif id == 34 then  
        title = Util.GetText(TextConfig.Type.DAOYOU, "IsLeave")
        if self.isAdmin then
            content = Util.GetText(TextConfig.Type.DAOYOU, "MasterLeaveNotice")
            oneButton = true
        else
            if #self.DaoqunInfo.dyInfo == 2 then
                content = Util.GetText(TextConfig.Type.DAOYOU, "Word2")
            else
                content = Util.GetText(TextConfig.Type.DAOYOU, "AskIsLeave")
            end
        end
    else
        return
    end

    if oneButton then
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            content,
            nil,
            nil,
            function()
                ConfirmCb(id, data)
            end)
    else
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            content,
            nil,
            nil,
            title,
            nil,
            function()
                ConfirmCb(id, data)
            end,
            nil)
    end
end

local function RefreshCellData(cell, data, index)
    local icon = cell:FindChildByEditName("ib_player_icon", true)
    Util.SetHeadImgByPro(icon,data.pro)
    cell:FindChildByEditName("ib_rank_num", true).Text = tostring(data.playerLvl)
    MenuBaseU.SetLabelText(cell, "lb_player_name", data.playerName, GameUtil.GetProColor(data.pro), 0)
    cell:FindChildByEditName("lb_power", true).Text = tostring(data.playerFightPower)
    
    
    
    
    
    cell:FindChildByEditName("lb_position", true).Text = data.areaName
    cell:FindChildByEditName("ib_manage", true).Visible = data.isAdmin == 1
    cell:FindChildByEditName("lb_mine", true).Visible = data.playerId == DataMgr.Instance.UserData.RoleID
    cell:FindChildByEditName("ib_choose", true).Visible = false
    cell:FindChildByEditName("img_zhezhao", true).Visible = data.onlineState == 0
    local function slectfuc()
        cell:FindChildByEditName("ib_choose",true).Visible = true
        local typestr = InteractiveMenu.DAOQUN_MASTER
        if data.playerId == DataMgr.Instance.UserData.RoleID then
            typestr = InteractiveMenu.DAOQUN_LEAVE
        else
            if self.isAdmin then
                typestr = InteractiveMenu.DAOQUN_MASTER
            else
                typestr = InteractiveMenu.DAOQUN_MEMBER
            end
        end
        
        EventManager.Fire("Event.ShowInteractive", {
            type=typestr,
            player_info={
            name=data.playerName,
            upLv = data.playerUpLvl,
            guildName = data.guildName,
            playerId = data.playerId,
            pro = data.pro,
            lv = data.playerLvl,
            activeMenuCb = function (id, data)
              cell:FindChildByEditName("ib_choose",true).Visible = false
              InteractiveMenuCb(id,data)
            end,
            }
        })
    end
    cell.TouchClick = slectfuc
end

local function OpenSetNameUI()
    local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialDaoqunSetName,0)
    obj.SetCall(function (str)
        self.lb_name.Text = str
    end)
end

local function RefreshDaoqunUI()
    self.DaoqunInfo = DaoyouModel.GetDaoqunInfo()
    self.lb_name.Text = self.DaoqunInfo.dyName
    self.lb_power_num.Text = self.DaoqunInfo.dyFightPower
    self.ib_ranking_num.Text = self.DaoqunInfo.dyRank
    self.sp_player_all:Initialize(
            self.cvs_player.Width + 0, 
            self.cvs_player.Height + 0, 
            #self.DaoqunInfo.dyInfo,
            1,
            self.cvs_player, 
            function(x, y, cell)
                local index = y + 1
                local data = self.DaoqunInfo.dyInfo[index]
                RefreshCellData(cell, data, index)
            end,
            function() end
        )
    SetDaoqunNotice(self.DaoqunInfo.dyNotice)
    SetDaoqunMessage()
    self.isAdmin = DaoyouModel.GetDaoqunAdinId() == DataMgr.Instance.UserData.RoleID
    if self.DaoqunInfo.isEditedDyName == 0 and self.isAdmin then
        OpenSetNameUI()
    end
    self.btn_modify.Visible = self.isAdmin
    self.cvs_invite.Visible = self.isAdmin
    self.btn_modify1.Visible = self.isAdmin
end

local function ReqDaoqunData()
    DaoyouModel.ReqDaoqunInfo(function ()
        RefreshDaoqunUI()
    end)
end

local function ShowPoint()
    if DataMgr.Instance.FlagPushData:GetFlagState(902) > 0 then
        self.ib_red.Visible = true
    else
        self.ib_red.Visible = false
    end
end

local function OnExit()
    EventManager.Unsubscribe("Event.Daoqun.NeedRefreshDaoqunUI", ReqDaoqunData)
    DataMgr.Instance.FlagPushData:DetachLuaObserver(GlobalHooks.UITAG.GameUISocialDaoqun)
end

local function OnEnter()
    RefreshDaoqunUI()
    EventManager.Subscribe("Event.Daoqun.NeedRefreshDaoqunUI", ReqDaoqunData)

    ShowPoint()
    DataMgr.Instance.FlagPushData:AttachLuaObserver(GlobalHooks.UITAG.GameUISocialDaoqun, {Notify = function(status, flagdate)
        
        if self.menu ~= nil then
            ShowPoint()
        end
    end})
end

local function InitUI()
    
    local UIName = {
        "lb_name",
        "btn_modify",

        "sp_player_all",
        "cvs_player",

        "cvs_invite",
        "btn_invite",

        "lb_power_num",
        "ib_ranking_num",

        "tb_announcement",
        "btn_modify1",

        "cvs_inform",
        "cvs_cell",
        "btn_write",

        "btn_rebate",
        "ib_red",
        "btn_team",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end
end

local function InitCompnent()
    InitUI()

    self.cvs_player.Visible = false
    self.cvs_cell.Visible = false

    self.btn_modify.TouchClick = function ()
        OpenSetNameUI()
    end

    self.btn_invite.TouchClick = function ()
      OpenInviteUI()
    end
    self.cvs_invite.TouchClick = function ()
      OpenInviteUI()
    end

    self.btn_modify1.TouchClick = function ()
        local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialDaoqunNotice,0)
        obj.setParams("notice", self.DaoqunInfo.dyNotice, function (str)
            if str then
                self.DaoqunInfo.dyNotice = str
                SetDaoqunNotice(self.DaoqunInfo.dyNotice)
            end
        end)
    end

    self.btn_write.TouchClick = function ()
        local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialDaoqunNotice,0)
        obj.setParams("message", "", function (str)
            EventManager.Fire("Event.Daoqun.NeedRefreshDaoqunUI", {})
        end)
    end

    self.btn_rebate.TouchClick = function ()
      GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialDaoqunRebate,0)
      DataMgr.Instance.FlagPushData:SetAttribute(902, 0, false)
    end

    self.btn_team.TouchClick = function ()
        DaoyouModel.QuickCreateTeamRequest(function ()
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.DAOYOU,'createTeamTip'))
        end)
    end

    self.m_Root:SubscribOnEnter(OnEnter)
    self.m_Root:SubscribOnExit(OnExit)
    self.m_Root:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
    self.m_Root = LuaMenuU.Create("xmds_ui/social/daoqun.gui.xml", GlobalHooks.UITAG.GameUISocialDaoqun)
    self.menu = self.m_Root
    self.menu.Enable = false
    InitCompnent()
    return self.m_Root
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end


return {Create = Create}
