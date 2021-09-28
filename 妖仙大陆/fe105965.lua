local _M = {}
_M.__index = _M


local Util          = require "Zeus.Logic.Util"
local DaoyouModel   = require "Zeus.Model.Daoyou"
local FriendModel   = require "Zeus.Model.Friend"

local self = {
    menu = nil,
}

local function RefreshCellData(cell, data, index)
    local hasDaoyou = data.isHaveDaoYou == 1
    local icon = cell:FindChildByEditName("ib_player_icon", true)
    Util.HZSetImage(icon, "static_n/hud/target/" ..data.pro.. ".png", false)
    cell:FindChildByEditName("ib_rank_num", true).Text = tostring(data.level)
    MenuBaseU.SetLabelText(cell, "lb_player_name", data.name, GameUtil.GetProColor(data.pro), 0)
    cell:FindChildByEditName("lb_power", true).Text = tostring(data.fightPower)
    local vo = GlobalHooks.DB.Find("UpLevelExp", {UpOrder=data.stageLevel})[1]
    local name = ""
    if vo then
        name = vo.ClassName..vo.UPName
    end
    cell:FindChildByEditName("lb_union_name", true).Text = name
    cell:FindChildByEditName("btn_invite", true).Visible = not hasDaoyou
    cell:FindChildByEditName("btn_invite", true).TouchClick = function (sender)
        DaoyouModel.InviteDaoYouRequest(data.id,function ()
            self.hasInvite = true
            local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.DAOYOU, "daoyouAdd")
            GameAlertManager.Instance:ShowNotify(tips)
            for k,v in pairs(self.FriendList) do
            if v.id == data.id then
              table.remove(self.FriendList,k)
              self.sp_invite_all:ResetRowsAndColumns(#self.FriendList,1)
            end
          end
        end)
    end

    cell:FindChildByEditName("lb_tip", true).Visible = hasDaoyou
    cell.IsGray = hasDaoyou
    cell.Enable = hasDaoyou
    cell.TouchClick = function (sender)
        local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.DAOYOU, "friendHasDaoqun")
        GameAlertManager.Instance:ShowNotify(tips)
    end
end

local function OnExit()
    if self.hasInvite == true then
        EventManager.Fire("Event.Daoqun.NeedRefreshDaoqunUI", {})
    end
end

local function function_name()
    
end

local function OnEnter()
    self.hasInvite = false
    FriendModel.GetAllSocialList(function()
        self.FriendList = FriendModel.GetDaoyouInviteList()
        self.sp_invite_all:Initialize(
            self.cvs_single.Width + 0, 
            self.cvs_single.Height + 0, 
            #self.FriendList,
            1,
            self.cvs_single, 
            function(x, y, cell)
                local index = y + 1
                local data = self.FriendList[index]
                RefreshCellData(cell, data, index)
            end,
            function() end
        )
        self.tbx_tips.Visible = #self.FriendList == 0
        self.btn_addfriend.Visible = #self.FriendList == 0
        self.btn_addfriend.TouchClick = function (sender)
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialFriendAdd, 0)
            self.menu:Close()
        end
    end)
end

local function InitCompnent()
    local UIName = {
        "sp_invite_all",
        "cvs_single",
        "tbx_tips",
        "btn_addfriend",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.cvs_single.Visible = false

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
    self.menu = LuaMenuU.Create("xmds_ui/social/dao_invite.gui.xml", GlobalHooks.UITAG.GameUISocialDaoyouInvite)
    self.menu.Enable = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    self.menu.mRoot.IsInteractive = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function (sender)
        self.menu:Close()
    end})

    InitCompnent()
    return self.menu
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end


return {Create = Create}
