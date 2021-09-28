


local Util = require 'Zeus.Logic.Util'
local Team = require "Zeus.Model.Team"
local InteractiveMenu       = require "Zeus.UI.InteractiveMenu"
local _M = {}
_M.__index = _M







local Icon = {
    92,94,95,90,91
}

local ui_names = {
    {name = "btn_nearby_team"},
    {name = "btn_nearby_player"},
    {name = "btn_refresh",click = function(self)
        if self.cvs_team_detail.Visible then
            self:requestNearTeams()    
        else
            self:openNearPerson()
        end
    end},
    {name = "btn_create_team",click = function(self)
        
        self.teamMain:setIsSwitchToMine(false)
        if DataMgr.Instance.TeamData.HasTeam then
        
             Team.RequestLeaveTeam(function()
                 self.teamMain:setIsSwitchToMine(true)
                 self.btn_create_team.Text = Util.GetText(TextConfig.Type.TEAM, "createteam")
                 if self.tabType == 1 then
                    self.sp_team_detail:RefreshShowCell()
                else
                    self:openNearPerson()
                end
             end)
        else
            Team.RequestCreateTeamAndSetTarget(1,1, function()
                 self.teamMain:setIsSwitchToMine(true)
                 self.btn_create_team.Text = Util.GetText(TextConfig.Type.TEAM, "exitteam")
                 if self.tabType == 1 then
                    self.sp_team_detail:RefreshShowCell()
                
                end
            end)
        end
        
        
    end},
    {name = "btn_apply_all",click = function(self)
        if self.tabType == 1 then
            if self.nearTeams==nil or #self.nearTeams <= 0 then
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "noteam"))
            else
                if self.cvs_team_detail.Visible then
                    self:requestJoinAllTeams()
                else

                end
            end
        else
            if self.nearPlayers==nil or #self.nearPlayers ==0 then
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "noplayer"))
                return
            end
            local inviteAllPlayer = function ( ... )
                for i,v in ipairs(self.nearPlayers) do
                    if v.isInvited ~= 1 then
                        Team.RequestInviteTeam(v.id,function()
                            v.isInvited = 1
                            if v.node ~= nil then
                                self:setPersonValue(i,v.node)
                            end
                        end)
                    end
                end
            end

            if not DataMgr.Instance.TeamData.HasTeam then
                self.teamMain:setIsSwitchToMine(false)
                Team.RequestCreateTeamAndSetTarget(1,1, function()
                     self.teamMain:setIsSwitchToMine(true)
                     inviteAllPlayer()
                    self.btn_create_team.Text = Util.GetText(TextConfig.Type.TEAM, "exitteam")
                end)
            else
                inviteAllPlayer()
            end

        end
    end},
    {name = "cvs_nobody"},
    {name = "cvs_team_detail1"},
    {name = "cvs_team_detail"},
    {name = "sp_team_detail"},
    {name = "sp_team_detail1"},
    {name = "cvs_team_single"},
    {name = "cvs_team_single1"}

}

function _M:requestJoinAllTeams()
    if self.nearTeams and #self.nearTeams then
        local function handler(teamId)
            for i = 1,#self.nearTeams,1 do
                if self.nearTeams[i].teamId == teamId then
                    self.nearTeams[i].apply = 1
                    for k,v in pairs(self.teamNodes) do
                        if v == i then
                            self:setTeamValue(i,k)
                            break;
                        end
                    end                    
                    break
                end
            end

        end
        for i = 1,#self.nearTeams,1 do
            if self.nearTeams[i].apply ~= 1 then
                local teamId = self.nearTeams[i].teamId
                Team.RequestApplyTeamByTeamId(teamId,handler)
            end
        end
    end
end

function _M:requestNearTeams()
    local lb_no_team1 = self.cvs_nobody:FindChildByEditName("lb_no_team1",true)
    local lb_no_man = self.cvs_nobody:FindChildByEditName("lb_no_man",true)
    lb_no_team1.Visible = true
    lb_no_man.Visible = false
    Team.RequestNearTeams(
        function(data)
            
            self.nearTeams = data.teams
            if self.nearTeams and #self.nearTeams > 0 then
                self.cvs_nobody.Visible = false
                lb_no_team1.Visible = false
                self.sp_team_detail.Scrollable:Reset(1, #self.nearTeams)
            else
                self.cvs_nobody.Visible = true
                lb_no_team1.Visible = true
                self.sp_team_detail.Scrollable:Reset(1, 0)
            end
            self.cvs_team_detail.Visible = true
        end
    )
end

function _M:openNearTeam()
    self.cvs_team_detail1.Visible = false
    self.cvs_team_detail.Visible = false
    self.cvs_nobody.Visible = false
    self:requestNearTeams()
end

function _M:openNearPerson()
    self.cvs_team_detail1.Visible = false
    self.cvs_team_detail.Visible = false
    Team.RequestNearPlayers( function(data)
        
        self.nearPlayers = data.s2c_players
        if self.nearPlayers == nil or #self.nearPlayers == 0 then
            self.sp_team_detail1.Visible = false
            self.cvs_nobody.Visible = true
            local lb_no_team1 = self.cvs_nobody:FindChildByEditName("lb_no_team1",true)
            local lb_no_man = self.cvs_nobody:FindChildByEditName("lb_no_man",true)
            lb_no_team1.Visible = false
            lb_no_man.Visible = true
        else
            self.sp_team_detail1.Visible = true
            self.cvs_nobody.Visible = false
            local row = math.floor(#self.nearPlayers / 2) + 1
            self.sp_team_detail1.Scrollable:Reset(2, row)
        end
        self.cvs_team_detail1.Visible = true
    end , true)
end

local function requestApplyTeam(self,team,callback)
	Team.RequestApplyTeamByTeamId(team.teamId,callback)
end

function _M:setTeamValue(index,node)
    local teamValue = self.nearTeams[index]
    if (teamValue) then
        node.Visible = true
        local ib_player_icon = node:FindChildByEditName("ib_player_icon",false)
        local ib_rank_num = node:FindChildByEditName("ib_rank_num",false)
        local lb_player_name = node:FindChildByEditName("lb_player_name",false)
        
        local lb_union_name = node:FindChildByEditName("lb_union_name",false)
        for i = 1,5,1 do
            local cvs_job = node:FindChildByEditName("cvs_job"..i,true)
            cvs_job.Visible = false
        end
        for i = 1,#teamValue.members,1 do
            local cvs_job = node:FindChildByEditName("cvs_job"..i,true)
            local ib_job = cvs_job:FindChildByEditName("ib_job",true)
            local lb_job_level = cvs_job:FindChildByEditName("lb_job_level",true)
            local member = teamValue.members[i]
            Util.HZSetImage(ib_job, "#static_n/func/maininterface.xml|maininterface|"..Icon[member.pro])
            lb_job_level.Text = member.lv
            cvs_job.Visible = true
        end
        ib_rank_num.Text = teamValue.leader.lv
        lb_player_name.Text = teamValue.leader.name
        lb_union_name.Text = teamValue.leader.guildName
        Util.SetHeadImgByPro(ib_player_icon,teamValue.leader.pro)
        local btn_apply1 = node:FindChildByEditName("btn_apply1",true)
        local ib_applied = node:FindChildByEditName("ib_applied",true)
        if DataMgr.Instance.TeamData.HasTeam then
            btn_apply1.Visible = false
            ib_applied.Visible = false
        else
            btn_apply1.Visible = (teamValue.apply ~= 1)
            ib_applied.Visible = (teamValue.apply == 1)
        end
        local function callback()
            btn_apply1.Visible = false
            ib_applied.Visible = true
            teamValue.apply = 1
        end
        btn_apply1.event_PointerClick = function()
            
            requestApplyTeam(self,teamValue,callback)
        end
    else
        node.Visible = false
    end
end

function _M:setPersonValue(index,node)
    local personValue = self.nearPlayers[index]
    if personValue then
        personValue.node = node
        node.Visible = true
        local ib_player_icon1 = node:FindChildByEditName("ib_player_icon1",true)
        local ib_rank_num1 = node:FindChildByEditName("ib_rank_num1",true)
        local lb_player_name1 = node:FindChildByEditName("lb_player_name1",true)
        local lb_union_name1 = node:FindChildByEditName("lb_union_name1",true)
        local btn_invite = node:FindChildByEditName("btn_invite",true)
        local ib_invited = node:FindChildByEditName("ib_invited",true)
        lb_player_name1.Text = personValue.name
        lb_union_name1.Text = personValue.guildName
        ib_rank_num1.Text = personValue.level
        Util.SetHeadImgByPro(ib_player_icon1,personValue.pro)
        if personValue.isInvited == 1 then
            ib_invited.Visible = true
            btn_invite.Enable = false
            btn_invite.Visible = false
        else
            ib_invited.Visible = false
            btn_invite.Enable = true
            btn_invite.Visible = true
            
            
            
            
            
            
            
            local function activeMenuCb()
                personValue.isInvited = 1
                self:setPersonValue(index,node)
                self.teamMain:setIsSwitchToMine(true)
            end
            btn_invite.event_PointerClick = function()
                if DataMgr.Instance.TeamData.HasTeam then
                    Team.RequestInviteTeam(personValue.id,activeMenuCb)
                else
                    self.teamMain:setIsSwitchToMine(false)
                    Team.RequestCreateTeamAndSetTarget(1,1, function()
                        self.btn_create_team.Text = "离开队伍"

                        Team.RequestInviteTeam(personValue.id,activeMenuCb)
                    end)
                end











            end
        end
    else
        node.Visible = false
    end
end

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.TouchClick = function()
                    ui.click(tbl)
                end
            end
        end
    end
end

local function OnFuncBtnChecked(self,sender)
    if sender == self.btn_nearby_team then
        self:openNearTeam()
        self.btn_apply_all.Text = Util.GetText(TextConfig.Type.TEAM, "shenqing")
        self.tabType = 1
    elseif sender == self.btn_nearby_player then
        self:openNearPerson()
        self.btn_apply_all.Text = Util.GetText(TextConfig.Type.TEAM, "yaoqing")
        self.tabType = 2
    end
end

local function InitComponent(self,parent)
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/team/nearby.gui.xml')
    self.menu.Enable = false
    initControls(self.menu,ui_names,self)
    self.cvs_team_single.Visible = false
    self.cvs_team_single1.Visible = false
    self.cvs_nobody.Visible = false
    
    local cellW = self.cvs_team_single.Width
    self.teamNodes = {}
    self.sp_team_detail:Initialize(cellW, self.cvs_team_single.Height, 0, 1, self.cvs_team_single,
    function(gx, gy, node)
        
        local index = gy + 1
        self:setTeamValue(index,node)
        self.teamNodes[node] = index
    end , function()

    end )

    cellW = self.cvs_team_single1.Width
    self.sp_team_detail1:Initialize(cellW, self.cvs_team_single1.Height, 0, 2, self.cvs_team_single1,
    function(gx, gy, node)
        
        local index = gx + gy*2 + 1
        self:setPersonValue(index,node)
    end , function()
        
    end )

    parent:AddChild(self.menu)
    self.func_btns = {self.btn_nearby_team,self.btn_nearby_player}
    Util.InitMultiToggleButton( function(sender)
        OnFuncBtnChecked(self, sender)
    end , self.btn_nearby_team, self.func_btns)  
end

function _M:Open()
    self.menu.Visible = true
    self.btn_nearby_team.Visible = true
    self.btn_nearby_player.Visible = true
    self.btn_create_team.Visible = true
    self.btn_apply_all.Visible = true
    self.tabType = 1
     if DataMgr.Instance.TeamData.HasTeam then
         self.btn_create_team.Text = Util.GetText(TextConfig.Type.TEAM, "exitteam")
    else
        self.btn_create_team.Text = Util.GetText(TextConfig.Type.TEAM, "createteam")
    end
    Util.ChangeMultiToggleButtonSelect(self.btn_nearby_team,self.func_btns)
end

function _M:Exit()
    self.menu.Visible = false
    self.teamNodes = {}
end

function _M.Create(parent,teamMain)
    local ret = {}
    setmetatable(ret,_M)
    ret.teamMain = teamMain
    InitComponent(ret,parent)
    return ret
end

return _M



