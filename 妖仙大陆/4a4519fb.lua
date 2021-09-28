


local Util = require 'Zeus.Logic.Util'
local Team = require "Zeus.Model.Team"
local TeamApply = require "Zeus.UI.XmasterTeam.TeamApply"
local TeamUtil = require "Zeus.UI.XmasterTeam.TeamUtil"
local _M = {
    selectNodeIndex = nil,nodeItems = nil,textTarget = nil
}
_M.__index = _M

local ui_names = {
    {name = "cvs_btnLeader"},
    {name = "cvs_btnMember"},
    {name = "cvs_btnNoTeam"},
    {name = "btn_refresh",click = function(self)
        self:RequestTeamList(self.selectTargetID,self.selectHardIdx,true)
    end},
    {name = "btn_create_team",click = function(self)
        self:OnCreateTeamWithTarget()
    end},
    {name = "btn_automatic_fit",click = function(self)
        self:onAutoApplyBtnClick()
    end},
    {name = "btnLeaderLeaveTeam",click = function(self)
        
        self:leaveTeam()
    end},
    {name = "btnMemberLeaveTeam",click = function(self)
        
        self:leaveTeam()
    end},
    {name = "btnLeaderAutoFit",click = function(self)
        
        self:leaderAutoFit()
    end},
    {name = "btnMemberFollow",click = function(self)
        
        self:followTeamLeader()
    end},
    {name = "btn_gotarget",click = function(self)
        
        local function handler()
            self.teamMain:Close()
        end
        if(DataMgr.Instance.TeamData.HasTeam) then
            if DataMgr.Instance.TeamData.IsLeader() then
                if self.selectTargetID > 1 then
                    Team.RequestGotoTeamTarget(self.selectTargetID,self.selectHardIdx,handler)
                else
                    GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "noTarget"))
                    self:OpenTeamSet()
                end
            else
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "onlyLeaderDo"))
            end
        else
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "noTarget"))
            self:OpenTeamSet()
        end
        
    end},
    {name = "btn_shout",click = function(self)
        
        local node, luaobj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamRecruit, 0, 0)
		local data = {}
		local info = self.teamMain.targetInfo
		local db = GlobalHooks.DB.Find('TeamTarget', info.targetId)
		if db ~= nil then
			data.targetName = db.TargetName
		end
	    data.diffcult = info.difficulty
	    data.needlv = info.minLevel
	    data.needuplv = info.minUpLevel         
	    data.needpower = info.minFightPower  
	    data.curNum = self.teamMain.memberCount
	    data.maxNum = 5
	    data.teamId = DataMgr.Instance.TeamData.TeamId
	    luaobj:SetInfo(data)
    end},
    {name = "btn_apply",click = function(self)
        
        self:clickApplyBtn()
    end},
    {name = "sp_team_detail"},
    {name = "cvs_team_single"},
    {name = "lb_target_deatil"},
    {name = "lb_target_level"},
    {name = "ib_choose"},
    {name = "ib_choose_back"},
    {name = "cvs_main"},
    {name = "cvs_no_team"},
    {name = "tbx_reward"}
}

function _M:clickApplyBtn()
    
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamApply, -1)
end

function _M:OnCreateTeamWithTarget()
    local function handler_callback()
        
    end
    Team.RequestCreateTeamAndSetTarget(self.selectTargetID, self.selectHardIdx, handler_callback, nil)
end

function _M:leaveTeam()
    local content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "leaveConfirm")
    GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, nil, nil, nil, function()
        Team.RequestLeaveTeam( function()
            self:refrehOperateBtns()
            self.lb_target_level.Text = ""
            self:RequestTeamList(self.selectTargetID,self.selectHardIdx,true)
        end )
    end , nil)
end

function _M:followTeamLeader()
    self.teamMain:setIsSwitchToMine(false)
    local value = DataMgr.Instance.TeamData.TeamFollow == 1 and 0 or 1;
    local function callback(param)
        
        if value == 0 then
            self.btnMemberFollow.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "followState")
            self.btnMemberFollow.IsChecked = false
        else
            self.btnMemberFollow.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "unFollowState")
            self.btnMemberFollow.IsChecked = true
        end
        EventManager.Fire("Event.TeamSetFollowLeaderOK",{follow = value})
        self.teamMain:setIsSwitchToMine(true)
    end
    Team.RequestTeamSetFollowLeader(value,callback)
end

function _M:refreshBtnFollowLeader()
    local value = DataMgr.Instance.TeamData.TeamFollow
    if value == 0 then
        self.btnMemberFollow.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "followState")
        self.btnMemberFollow.IsChecked = false
    else
        self.btnMemberFollow.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "unFollowState")
        self.btnMemberFollow.IsChecked = true
    end
end

function _M:refreshBtnLeaderAutoFit(isAuto)
    
    
    
    
    if isAuto then
        self.btnLeaderAutoFit.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "cancelFit")
        self.btnLeaderAutoFit.IsChecked = true
    else
        self.btnLeaderAutoFit.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "autoFit")
        self.btnLeaderAutoFit.IsChecked = false
    end
    if(DataMgr.Instance.TeamData.IsTeamFull) then
        self.btnLeaderAutoFit.IsGray = true
        self.btnLeaderAutoFit.Enable = false
    else
        self.btnLeaderAutoFit.IsGray = false
        self.btnLeaderAutoFit.Enable = true
    end
end

function _M:leaderAutoFit()
    if self.selectTargetID == 1 then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "changetarget"))
        self.btnLeaderAutoFit.IsChecked = false
    else
        local value = DataMgr.Instance.TeamData.IsTeamAutoFit and 0 or 1
        local function handler(isAuto)
             self:refreshBtnLeaderAutoFit(isAuto == 1)
             self.teamMain:setIsSwitchToMine(true)
        end
        self.teamMain:setIsSwitchToMine(false)
        Team.RequestAutoAccept(value,handler)
    end
end

function _M:refrehOperateBtns()
    self.cvs_btnLeader.Visible = false
    self.cvs_btnMember.Visible = false
    self.cvs_btnNoTeam.Visible = false
    if DataMgr.Instance.TeamData.HasTeam then
        if DataMgr.Instance.TeamData:IsLeader() then
            self.cvs_btnLeader.Visible = true
            self:refreshBtnLeaderAutoFit()
            return
        end
        self.cvs_btnMember.Visible = true
        self:refreshBtnFollowLeader()
    else
        self.cvs_btnNoTeam.Visible = true
        if DataMgr.Instance.TeamData.isAutoFit == 1 then
            self.btn_automatic_fit.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "cancelFit")
            self.btn_automatic_fit.IsChecked = true
        else
            self.btn_automatic_fit.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "autoFit")
            self.btn_automatic_fit.IsChecked = false
        end
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

local function isCanApply(data)
	local userData = DataMgr.Instance.UserData
	local lv = userData:GetAttribute(UserData.NotiFyStatus.LEVEL)
	local isOkLv = false
    isOkLv = data.minLevel <= lv
	return isOkLv 
end

local function requestTeamList(self,id,hardIdx,isForce)
	Team.RequestSearchTeam(id, hardIdx, isForce, function(data)
		self.teamList = data.s2c_teams or {}
		local isOk = false
		for _,v in ipairs(self.teamList) do
			if isCanApply(v) then
				isOk = true
				break
			end
		end


        if self.teamList then
            self.sp_team_detail.Scrollable:Reset(1,#self.teamList)
        else
            self.sp_team_detail.Scrollable:Reset(1,0)
        end
		self.cvs_no_team.Visible = #self.teamList == 0
	end)
end

function _M:RequestTeamList(id,hardIdx,isForce)
    requestTeamList(self,id,hardIdx,isForce)
end

function _M:setTeamSet(targetID, diff)
    self.selectTargetID = targetID
    self.selectHardIdx = diff
    local prop = TeamUtil.findTeamTargetProp(targetID)
    if prop then
        local diffName = ""
        if prop.prop.HardChange ~=0 then
            diffName = "--" .. self.teamMain.TargetDiffText[diff+1]
        end
        self.lb_target_deatil.Text = prop.prop.TargetName .. diffName
        diff = diff~=nil and diff + 1 or 1
        requestTeamList(self,targetID,diff,true)
    end
end

function _M:openTeamSet()
    if DataMgr.Instance.TeamData.HasTeam then
        if DataMgr.Instance.TeamData:IsLeader() then
            local node, luaObj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamTargetSet, 0,"team")
            local function callback(data,itemIndex,diff,leastLv,maxLv,lvText,autoAccept)
                local name = data.data.TargetName
                local itemName = ""
                local diffName = ""
                if itemIndex > 0 then
                    local item = data.items[itemIndex]
                    itemName = item.data.TargetName
                    if diff ~= nil then
                        diffName = "--" .. self.teamMain.TargetDiffText[diff+1]
                    end
                end
                self.lb_target_deatil.Text = itemName .. diffName
                
                local targetID = data.data.ID
                if itemIndex > 0 then
                    local item = data.items[itemIndex]
                    targetID = item.data.ID
                    
                    
                    
                end

                if targetID == 0 then
                    autoAccept = 0
                end
                diff = diff~=nil and diff + 1 or 1
	            Team.RequestSetTarget(targetID,  diff, leastLv, maxLv, autoAccept, 0, function()
                    self.teamMain.targetInfo.targetId = targetID
                    self.teamMain.targetInfo.difficulty = diff
                    self.teamMain.targetInfo.minLevel = leastLv
                    self.teamMain.targetInfo.maxLevel = maxLv
                    self.teamMain.targetInfo.isAutoTeam = autoAccept
                    self.teamMain.targetInfo.isAutoStart = 0
		            self:refreshBtnLeaderAutoFit(autoAccept == 1)
                    self:setTargetText()
                    requestTeamList(self,targetID,diff,true)
	            end)
                
                
                
                
            end
            luaObj:setCallbackConfirm(callback)
        else
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "leaderOnly")) 
        end
        return
    end
    local node, luaObj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamTargetSet, 0,"single")
    local function callback(data,itemIndex,diff,leastLv,maxLv)
        local name = data.data.TargetName
        local itemName = ""
        local diffName = ""
        if itemIndex > 0 then
            local item = data.items[itemIndex]
            itemName = item.data.TargetName
            if diff ~= nil then
                diffName = "--" .. self.teamMain.TargetDiffText[diff+1]
            end
        end
        self.lb_target_deatil.Text = itemName .. diffName
        self.lb_target_level.Text = ""
        local hardIdx = diff~=nil and diff + 1 or 1
        
        local targetID = data.data.ID
        if itemIndex > 0 then
            local item = data.items[itemIndex]
            targetID = item.data.ID
        end
        self.selectTargetID = targetID
        self.selectHardIdx = hardIdx
        self.textTarget = self.lb_target_deatil.Text
        requestTeamList(self,targetID,hardIdx,true)
    end
    luaObj:setCallbackConfirm(callback)
end







local Icon = {
    92,94,95,90,91
}

local function requestApplyTeam(self,team,callback)
	Team.RequestApplyTeamByTeamId(team.id,callback)
end

function _M:onAutoApplyBtnClick()
    if self.selectTargetID == nil or self.selectHardIdx == nil then
        return
    end
    
















    if self.btn_automatic_fit.IsChecked then
        self.btn_automatic_fit.IsChecked = false
        Team.RequestAutoApplyTeam(self.selectTargetID, self.selectHardIdx,function (targetId, diffcuilty)
            
            EventManager.Fire("Event.setAutoFit",{})
            self.setTargetId = targetId
            self.setDiff = diffcuilty
            self.btn_automatic_fit.IsChecked = true
            EventManager.Fire("Event.Team.changeAutoFit",{})
        end)
    else
        self.btn_automatic_fit.IsChecked = true
        Team.RequestCancelAuto(function ()
            EventManager.Fire("Event.cancelAutoFit",{})
            self.setTargetId = nil
            self.setDiff = nil
            self.btn_automatic_fit.IsChecked = false
            EventManager.Fire("Event.Team.changeAutoFit",{})
        end)
    end
end

local function setNode(self,index,node)
    local lb_target_detail1 = node:FindChildByEditName("lb_target_detail1",true)
    local ib_player_icon = node:FindChildByEditName("ib_player_icon",true)
    local ib_rank_num = node:FindChildByEditName("ib_rank_num",true)
    local lb_player_name = node:FindChildByEditName("lb_player_name",true)
    local lb_union_name = node:FindChildByEditName("lb_union_name",true)
    local cvs_joball = node:FindChildByEditName("cvs_joball",true)
    local btn_apply1 = node:FindChildByEditName("btn_apply1",true)
    local ib_applied = node:FindChildByEditName("ib_applied",true)
    local lb_combating = node:FindChildByEditName("lb_combating",true)
    local team = self.teamList[index]
    local teamMembers = team.teamMembers
    for i = 1,5,1 do
        local cvs = cvs_joball:FindChildByEditName("cvs_job"..i,false)
        cvs.Visible = false
    end
    ib_applied.Visible = team.isApplied == 1
    lb_combating.Visible = team.isFighting and not ib_applied.Visible
    btn_apply1.Visible = not ib_applied.Visible and not lb_combating.Visible
    
    if DataMgr.Instance.TeamData.HasTeam and team.id == DataMgr.Instance.TeamData.TeamId then
        ib_applied.Visible = false
        btn_apply1.Visible = false
    end
    local function callback()
        btn_apply1.Visible = false
        ib_applied.Visible = true
        lb_combating.Visible = false
    end
    btn_apply1.event_PointerClick = function()
        
        requestApplyTeam(self,team,callback)
    end
    for i = 1,#teamMembers,1 do
        if teamMembers[i].id == team.leaderId then
            lb_player_name.Text = teamMembers[i].name
            ib_rank_num.Text = teamMembers[i].level
            lb_union_name.Text = teamMembers[i].guildName
            Util.SetHeadImgByPro(ib_player_icon,teamMembers[i].pro)
        end
        local cvs = cvs_joball:FindChildByEditName("cvs_job"..i,false)
        cvs.Visible = true
        local ib_job = cvs:FindChildByEditName("ib_job"..i,false)
        local lb_job_level = cvs:FindChildByEditName("lb_job_level"..i,false)
        lb_job_level.Text = teamMembers[i].level
        Util.HZSetImage(ib_job, "#static_n/func/maininterface.xml|maininterface|"..Icon[teamMembers[i].pro])
    end

    if team.targetId then
        local data = GlobalHooks.DB.Find('TeamTarget',team.targetId )
        lb_target_detail1.Text = data.TargetName
    else
        lb_target_detail1.Text = self.textTarget
    end
end

local function InitComponent(self,parent)
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/team/platform.gui.xml')
    self.menu.Enable = false
    initControls(self.menu,ui_names,self)
    self.lb_target_deatil.Enable = true
    self.lb_target_deatil.IsInteractive = true
    self.lb_target_deatil.event_PointerClick = function()
        self:openTeamSet()
    end    
    self.ib_choose.Enable = true
    self.ib_choose.IsInteractive = true
    self.ib_choose.event_PointerClick = function()
        self:openTeamSet()
    end
    parent:AddChild(self.menu)
    self.nodeItems = {}
    self.selectNodeIndex = 0
    self.cvs_team_single.Visible = false
    self.cvs_no_team.Visible = false

    local text = self.tbx_reward.Text

    MenuBaseU.SetEnableUENode(self.tbx_reward,true,false)
    self.tbx_reward:DecodeAndUnderlineLink(text)
    self.tbx_reward.LinkClick = function (link_str)
        self:OnCreateTeamWithTarget()
    end

    self.sp_team_detail:Initialize(self.cvs_team_single.Width,self.cvs_team_single.Height,0,1,self.cvs_team_single,
        function(gx,gy,node)
            setNode(self,gy + 1,node)
        end,
        function()

        end
    )
    self.selectTargetID = 1
    self.selectHardIdx = 1
    local function changeAutoFit(evtName,param)
        if DataMgr.Instance.TeamData.isAutoFit == 1 then
            self.btn_automatic_fit.Text = Util.GetText(TextConfig.Type.TEAM, "quxiaopipei")
            self.btn_automatic_fit.IsChecked = true
        else
            self.btn_automatic_fit.Text = Util.GetText(TextConfig.Type.TEAM, "zidongpipei")
            self.btn_automatic_fit.IsChecked = false
        end
    end
    EventManager.Subscribe("Event.Team.changeAutoFit",changeAutoFit)
end

function _M:setTargetText()
    local targetDatas = TeamUtil.makeTeamTargetList()
    local titleData = nil
    local data = nil
    if self.teamMain.targetInfo then

        self.selectTargetID = self.teamMain.targetInfo.targetId
        self.selectHardIdx = self.teamMain.targetInfo.difficulty
        if self.teamMain.targetInfo.minLevel and self.teamMain.targetInfo.maxLevel then
            local text = TeamUtil.getTargetLvText(self.teamMain.targetInfo.minLevel, self.teamMain.targetInfo.maxLevel)
            if text~= "" then
                self.lb_target_level.Text = " ["..text.."]"
            end
        end
    else

        self.lb_target_level.Text = ""
    end
    
    
    
    
    if not self.selectTargetID or self.selectTargetID == 0 then
        self.selectTargetID = 1
    end

        for i = 1,#targetDatas,1 do
            local items = targetDatas[i].items
            for j = 1,#items,1 do
                if(items[j].data.ID == self.selectTargetID) then
                    data = items[j].data
                    titleData = targetDatas[i].data
                    break
                end
                if data ~= nil then
                    break
                end
            end
        end
        local diffName = ""
        if data.HardChange ~= 0 then
            diffName = "--" .. self.teamMain.TargetDiffText[self.selectHardIdx]
        end
        self.lb_target_deatil.Text = data.TargetName ..diffName

    
    self.textTarget = self.lb_target_deatil.Text
end

function _M:Open()
    self.menu.Visible = true
    self.btn_apply.Visible = false
    self.btn_shout.Visible = false
    if DataMgr.Instance.TeamData.HasTeam then
        if DataMgr.Instance.TeamData:IsLeader() then
            self.btn_apply.Visible = true
            self.btn_shout.Visible = true
        end
    else
        
    end
    if self.teamMain.targetInfo then
        self.selectTargetID = self.teamMain.targetInfo.targetId
        self.selectHardIdx = self.teamMain.targetInfo.difficulty
    else
        self.selectTargetID = 1
        self.selectHardIdx = 1
    end
    self:refrehOperateBtns()
    self:setTargetText()

    if DataMgr.Instance.TeamData.HasTeam then
        self:refreshBtnLeaderAutoFit(DataMgr.Instance.TeamData.IsTeamAutoFit)
    else
        self:refreshBtnLeaderAutoFit(DataMgr.Instance.TeamData.isAutoFit)
    end
    
    self.sp_team_detail.Scrollable:Reset(1,0)
    
    requestTeamList(self,self.selectTargetID,self.selectHardIdx,true)
end

function _M:Exit()
    self.menu.Visible = false
    if DataMgr.Instance.TeamData.isAutoFit == 1 then
        if self.teamMain.targetInfo == nil then
            self.teamMain.targetInfo = {}
        end
        self.teamMain.targetInfo.targetId = self.selectTargetID
        self.teamMain.targetInfo.difficulty = self.selectHardIdx
    else
        
        
        
    end
end

function _M.Create(parent,teamMain)
    local ret = {}
    setmetatable(ret,_M)
    ret.teamMain = teamMain
    InitComponent(ret,parent)
    return ret
end

return _M



