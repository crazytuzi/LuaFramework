local _M = {}
_M.__index = _M

local Team = require "Zeus.Model.Team"
local Util = require "Zeus.Logic.Util"
local InteractiveMenu       = require "Zeus.UI.InteractiveMenu"

local _M = {
    
}
_M.__index = _M

local ui_names = {
    {name = "btn_type1"},
    {name = "btn_type2"},
    {name = "btn_type3"},
    {name = "btn_type4"},
    {name = "sp_invite_all"},
    {name = "cvs_team_single"},
    {name = "cvs_nobody"},
    {name = "lb_no_friend"},
    {name = "lb_no_union_member"},
    {name = "lb_no_myally"},
    {name = "lb_no_player"},
}

function _M.RequestList(self,type, cb)
   print("type = "..type)
   Team.RequestInviteList(type, function(data)
		print(PrintTable(data))
		self.listType = type
		self.menu.Visible = true
		self.data = data
		self.listdata = data.s2c_players
        if self.listdata == nil or #self.listdata == 0 then
            self.lb_no_friend.Visible = false
            self.lb_no_union_member.Visible = false
            self.lb_no_myally.Visible = false
            self.lb_no_player.Visible = false

            self.cvs_nobody.Visible = true
            self.sp_invite_all.Visible = false
            self.sp_invite_all.Scrollable:Reset(1,0)
            if type == 1 then
                self.lb_no_friend.Visible = true
            elseif type == 3 then
                if DataMgr.Instance.UserData.Guild then
                    self.lb_no_union_member.Text = Util.GetText(TextConfig.Type.TEAM, "noxianmengfriend")
                else
                    self.lb_no_union_member.Text = Util.GetText(TextConfig.Type.TEAM, "noxianmeng")
                end
                self.lb_no_union_member.Visible = true
            elseif type == 2 then
                self.lb_no_myally.Visible = true
            elseif type == 4 then
                self.lb_no_player.Visible = true
            end
        else
            self.cvs_nobody.Visible = false
            self.sp_invite_all.Visible = true
            self.sp_invite_all.Scrollable:Reset(1,#self.listdata)
        end
		if cb ~= nil then
			cb()
		end
	end)     
end

local function setNode(self,index,node)
    local data = self.listdata[index]
    if data then
        node.Visible = true
        local ib_player_icon = node:FindChildByEditName("ib_player_icon",true)
        local ib_rank_num = node:FindChildByEditName("ib_rank_num",true)
        local lb_player_name = node:FindChildByEditName("lb_player_name",true)
        local lb_union_name = node:FindChildByEditName("lb_union_name",true)
        local btn_invite = node:FindChildByEditName("btn_invite",true)
        local ib_invited = node:FindChildByEditName("ib_invited",true)
        ib_rank_num.Text = data.level
        lb_player_name.Text = data.name
        lb_union_name.Text = data.guildName
        Util.SetHeadImgByPro(ib_player_icon,data.pro)
        if data.isInvited == 1 then
            ib_invited.Visible = true
            btn_invite.Visible = false
        else
            ib_invited.Visible = false
            btn_invite.Visible = true
            btn_invite.event_PointerClick = function()
                local minLv = Team.TeamData.info.s2c_teamTarget.minLevel
                local maxLv = Team.TeamData.info.s2c_teamTarget.maxLevel
                local targetid = Team.TeamData.info.s2c_teamTarget.targetId

                if targetid<=1 or (data.level>=minLv and data.level <= maxLv )then
                    Team.RequestInviteTeam(data.id,function()
                        data.isInvited = 1
                        ib_invited.Visible = true
                        btn_invite.Visible = false
                    end)
                else
                    GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "cannotInvite"))
                end










            end
        end
    else
        node.Visible = false
    end
end

local function OnLoad(self, callBack)
	print("TeamInvite OnLoad", self.menu.ExtParam)

	local labelCvs = self.menu:FindChildByEditName("cvs_btn_all", true)
	local index = string.empty(self.menu.ExtParam) and '1' or string.sub(self.menu.ExtParam, -1)
	local firstRequest = true
	self.menu.InitMultiToggleButton(labelCvs, "btn_type"..index, CommonUnity3D.UGUIEditor.UI.TouchClickHandle(function(sender)
		
		self.RequestList(self,sender.UserTag, function()
			if firstRequest then
				firstRequest = false
				
				callBack:DynamicInvoke()
			end
		end)
	end))
end

function _M:OnEnter()

end

function _M:OnExit()

end

function _M:OnDestory()

end

local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create("xmds_ui/team/invite.gui.xml", GlobalHooks.UITAG.GameUITeamInvite)
    self.menu.Enable = true
    self.menu.IsInteractive = true
    self.menu.event_PointerClick = function()
        self.menu:Close()
    end
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.cvs_team_single.Visible = false
    self.sp_invite_all:Initialize(self.cvs_team_single.Width,self.cvs_team_single.Height,0,1,self.cvs_team_single,
        function(gx,gy,node)
            setNode(self,gy + 1,node)
        end,
        function()

        end
    )
    self.menu:SubscribOnLoad(function(callback)
    	OnLoad(self, callback)
    end)
    self.menu:SubscribOnExit( function()
        self:OnExit()
    end )
    self.menu:SubscribOnEnter( function()
        self:OnEnter()
    end )
    self.menu:SubscribOnDestory( function()
        self:OnDestory()
    end )
end

function _M.Create(tag)
    local self = {}
    setmetatable(self,_M)
    InitComponent(self,tag)
    return self
end

return _M
