local Team = require "Zeus.Model.Team"
local Util = require "Zeus.Logic.Util"

local _M = {}
_M.__index = _M

local ui_names = {
    {name = "sp_apply_all"},
    {name = "btn_emptied",click = function(self)
        self:clearAllApply()
    end},
    {name = "cvs_team_single"}
}

function _M:Close()
    self.menu:Close()
end

RefreshList = function(self)
	Team.RequestApplyList(function(data)
		self.menu.Visible = true
		self.data = data
		self.listdata = data.s2c_players
       if self.listdata == nil or #self.listdata == 0 then
           GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "noshenqing"))
           self:Close()
           return
       end

		if self.listdata ~= nil then
            self.sp_apply_all.Scrollable:Reset(1,#self.listdata)
		else
			 self.sp_apply_all.Scrollable:Reset(1,0)
		end
	end)
end

function _M:OnEnter()
    self.menu.Visible = false
    RefreshList(self)
end

function _M:OnExit()
    self.menu.Visible = false
     EventManager.Fire("Event.RefreshTeamApply",{applyNum = self.listdata==nil and 0 or #self.listdata})
end

function _M:OnDestory()

end

local function ApplyTeam(self,index, isAgree)
	local data = self.listdata[index]
	local result = isAgree and 1 or 2
	Team.RequestApplyResult(data.id, 3, result, function()
		RefreshList(self)
	end)
end

function _M:clearAllApply()
    if self.listdata then
        for i = 1,#self.listdata,1 do
            local data = self.listdata[i]
	        local result = 2
	        Team.RequestApplyResult(data.id, 3, result, function()
		        
	        end)
        end
        self.listdata = nil
    end
    self.sp_apply_all.Scrollable:Reset(1,0)
end

local function setNode(self,index,node)
    local data = self.listdata[index]
    if data then
        
        node.Visible = true
        local ib_player_icon = node:FindChildByEditName("ib_player_icon",true)
        local ib_rank_num = node:FindChildByEditName("ib_rank_num",true)
        local lb_player_name = node:FindChildByEditName("lb_player_name",true)
        local lb_union_name = node:FindChildByEditName("lb_union_name",true)
        local btn_agree = node:FindChildByEditName("btn_agree",true)
        local ib_agreed = node:FindChildByEditName("ib_agreed",true)
        Util.SetHeadImgByPro(ib_player_icon,data.pro)
        ib_rank_num.Text = data.level
        lb_player_name.Text = data.name
        lb_union_name.Text = data.guildName
        if data.isInvited == 1 then
            ib_agreed.Visible = true
            btn_agree.Enable = false
        else
            ib_agreed.Visible = false
            btn_agree.Enable = true
            btn_agree.event_PointerClick = function()
                ApplyTeam(self,index, true)
            end
        end
    else
        node.Visible = false
    end
end

local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create("xmds_ui/team/team_apply.gui.xml", tag)
    self.menu.Enable = true
    self.menu.IsInteractive = true
    self.menu.event_PointerClick = function()
        self:Close()
    end
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.cvs_team_single.Visible = false
    self.sp_apply_all:Initialize(self.cvs_team_single.Width,self.cvs_team_single.Height,0,1,self.cvs_team_single,
        function(gx,gy,node)
            setNode(self,gy + 1,node)
        end,
        function()

        end
    )
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
