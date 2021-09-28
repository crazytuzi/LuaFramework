


local Util = require 'Zeus.Logic.Util'
local Team = require "Zeus.Model.Team"
local TeamInvite = require "Zeus.UI.XmasterTeam.TeamInvite"
local TeamUtil = require "Zeus.UI.XmasterTeam.TeamUtil"
local InteractiveMenu       = require "Zeus.UI.InteractiveMenu"
local _M = {}
_M.__index = _M

local RefreshList = nil

local ui_names = {
    {name = "cvs_member1"},
    {name = "cvs_member2"},
    {name = "cvs_member3"},
    {name = "cvs_member4"},
    {name = "cvs_member5"},
    {name = "ib_choose_back",click = function(self)
        
    end},
    {name = "lb_target_deatil"},
    {name = "lb_target_level"},
    {name = "ib_choose"},
    {name = "btn_gotarget",click = function(self)
        EventManager.Fire("Event.TeamGoTarget",{})
    end},
    {name = "btn_shout",click = function(self)
        local node, luaobj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamRecruit, 0, 0)
		local data = {}
		local info = self.TargetInfo
		local db = GlobalHooks.DB.Find('TeamTarget', info.targetId)
		if db ~= nil then
			data.targetName = db.TargetName
		end
	    data.diffcult = info.difficulty
	    data.needlv = info.minLevel
	    data.needuplv = info.minUpLevel         
	    data.needpower = info.minFightPower  
	    data.curNum = #self.listdata
	    data.maxNum = 5
	    data.teamId = DataMgr.Instance.TeamData.TeamId
	    luaobj:SetInfo(data)
    end},
    {name = "btn_apply",click = function(self)
        
        self:openApplyMenu()
    end},
    {name = "btn_leave_team",click = function(self)
        local content = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "leaveConfirm")
	    GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, nil, nil, nil, function()
		    Team.RequestLeaveTeam(function()
	    	    
                self.teamMain:Close()
		    end)
	    end, nil)
        end},
    {name = "btn_automatic_fit",click = function(self)
        if self.TargetInfo and self.TargetInfo.targetId == 1 then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "changetarget"))
            self.btn_automatic_fit.IsChecked = false
            return
        end
        if not DataMgr.Instance.TeamData:IsLeader() then
            self.btn_automatic_fit.IsChecked = not self.btn_automatic_fit.IsChecked
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "onlyLeaderDo")) 
            return
        end

        local isAuto = self.btn_automatic_fit.IsChecked and 1 or 0
        local function handler(param)
            
            self:refrehBtnAutomaticFit(param == 1)
        end
        self:RequestAutoAccept(handler)
    end},
    {name = "btn_follow",click = function(self)
        self.teamMain:setIsSwitchToMine(false)
        local value = DataMgr.Instance.TeamData.TeamFollow == 1 and 0 or 1;
        local function callback(param)
            
            if value == 0 then
                self.btn_follow.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "followState")
                self.btn_follow.IsChecked = false
            else
                self.btn_follow.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "unFollowState")
                self.btn_follow.IsChecked = true
            end
            EventManager.Fire("Event.TeamSetFollowLeaderOK",{follow = value})
            self.teamMain:setIsSwitchToMine(true)
        end
        Team.RequestTeamSetFollowLeader(value,callback)
    end},
    {name = "lb_bj_apply"},
}

function _M:openApplyMenu()
     GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamApply, -1)
end

function _M:openInviteMenu()
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamInvite, 0)
end


function _M:refreshBtnFollowLeader()
    if DataMgr.Instance.TeamData.HasTeam then
        if DataMgr.Instance.TeamData:IsLeader() then
            self.btn_automatic_fit.Visible = true
            self.btn_follow.Visible = false
        else
            self.btn_automatic_fit.Visible = false
            self.btn_follow.Visible = true
            local value = DataMgr.Instance.TeamData.TeamFollow
            if value == 0 then
                self.btn_follow.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "followState")
                self.btn_follow.IsChecked = false
            else
                self.btn_follow.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "unFollowState")
                self.btn_follow.IsChecked = true
            end
        end
    end


end

function _M:refrehBtnAutomaticFit(isAuto)
    if isAuto then
        self.btn_automatic_fit.IsChecked = true
        self.btn_automatic_fit.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "cancelFit")
    else
        self.btn_automatic_fit.IsChecked = false
        self.btn_automatic_fit.Text = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "autoFit")
    end
    if(DataMgr.Instance.TeamData.IsTeamFull) then
        self.btn_automatic_fit.IsGray = true
        self.btn_automatic_fit.Enable = false
    else
        self.btn_automatic_fit.IsGray = false
        self.btn_automatic_fit.Enable = true
    end

    self:refreshBtnFollowLeader()
end

function _M:Release3DModel()
	if self.model ~= nil then
		for key, obj in pairs(self.model) do
	        GameObject.Destroy(obj)
	        IconGenerator.instance:ReleaseTexture(key)
		end
	end
	self.model = {}
end


local function cleanRoleNode(self,cvs)
    local ib_captain = cvs:FindChildByEditName("ib_captain",true)
    local ib_follow = cvs:FindChildByEditName("ib_follow",true)
    local lb_player_name = cvs:FindChildByEditName("lb_player_name",true)
    local lb_level = cvs:FindChildByEditName("lb_level",true)
    local lb_server = cvs:FindChildByEditName("lb_server",true)
    local lb_FC = cvs:FindChildByEditName("lb_FC",true)
    local ib_FC = cvs:FindChildByEditName("ib_FC",true)
    local lb_zhan = cvs:FindChildByEditName("lb_zhan",true)

    ib_captain.Visible = false
    ib_follow.Visible = false
    lb_player_name.Text = ""
    lb_level.Text = ""
    lb_server.Text = ""

    lb_FC.Visible = false
    ib_FC.Visible = false
    lb_zhan.Visible = false

    local btn_add = cvs:FindChildByEditName("btn_invite",true)
    btn_add.Visible = true
    btn_add.event_PointerClick = function()
        self:openInviteMenu()
    end
end

local function setRoleNode(self, cvs, index)
    local roleData = self.listdata[index]
    local ib_captain = cvs:FindChildByEditName("ib_captain", true)
    local ib_follow = cvs:FindChildByEditName("ib_follow", true)
    local lb_player_name = cvs:FindChildByEditName("lb_player_name", true)
    local lb_level = cvs:FindChildByEditName("lb_level", true)
    local ib_model = cvs:FindChildByEditName("ib_model", true)
    local btn_add = cvs:FindChildByEditName("btn_invite",true)
    local lb_server = cvs:FindChildByEditName("lb_server",true)
    local lb_FC = cvs:FindChildByEditName("lb_FC",true)
    local ib_FC = cvs:FindChildByEditName("ib_FC",true)
    local lb_zhan = cvs:FindChildByEditName("lb_zhan",true)

    lb_FC.Visible = true
    ib_FC.Visible = true
    lb_zhan.Visible = true


    btn_add.Visible = false
    lb_player_name.Text = roleData.name
    lb_level.Text =  string.format(ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.TEAM, "levelLimit"),roleData.level)
    lb_server.Text = "(服：" ..roleData.areaDes .. ")"  
    lb_server.Visible = false
    
    lb_FC.Text = roleData.fightPower  
    if self.model[ib_model.UserData] == nil then
        local filter = bit.lshift(1, GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))
        local obj, key = GameUtil.Add3DModelLua(ib_model, nil, roleData.avatars, nil, filter, true)
        IconGenerator.instance:SetModelPos(key, Vector3.New(0.1, -1.1, 5.3))
	    IconGenerator.instance:SetCameraParam(key, 0.3, 10, 2)
        IconGenerator.instance:SetLoadOKCallback(key, function(k)
            IconGenerator.instance:PlayUnitAnimation(key, 'n_show', WrapMode.Loop, -1, 1, 0, nil, 0)
            
        end )
        self.model[key] = obj
        ib_model.UserData = key
        obj.transform.sizeDelta = UnityEngine.Vector2.New(320, 640)
        local rawImage = obj:GetComponent("UnityEngine.UI.RawImage")
        rawImage.uvRect = UnityEngine.Rect.New(0.25, 0, 0.5, 1)
        rawImage.raycastTarget = false
        IconGenerator.instance:SetGray(rawImage, roleData.status == 3)
    end
    ib_captain.Visible = (roleData.isLeader == 1)
    ib_follow.Visible = (roleData.follow == 1)
    cvs.Enable = true
    cvs.IsInteractive = true
    local function interactiveCallback(id, player_info)
        if id == 10 then 
            
        elseif id == 11 then 
            
        end
    end
    cvs.UserTag = index
    cvs.event_PointerClick = function(sender)
        
        local roleData = self.listdata[sender.UserTag]

        if roleData == nil or roleData.id == DataMgr.Instance.UserData.RoleID then
            return
        end
        local info = {}
        if DataMgr.Instance.TeamData.HasTeam then
            if DataMgr.Instance.TeamData:IsLeader() then
                info.type = InteractiveMenu.TYPE_TEAM_LEADER
            else
                info.type = InteractiveMenu.TYPE_TEAM
            end
        end
        info.player_info = {
            name = roleData.name,
            lv = roleData.level,
            playerId = roleData.id,
            pro = roleData.pro,
            guildName = roleData.guildName,
            upLv = roleData.upLevel,
            activeMenuCb = interactiveCallback,
        }
        EventManager.Fire("Event.ShowInteractive", info )
    end
end

local function cleanRoleNodes(self)
    self:Release3DModel()
    for i = 1,5,1 do
        local cvs = self["cvs_member"..i]
        cleanRoleNode(self,cvs)
    end
end

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.Enable = true
                ctrl.IsInteractive = true
                ctrl.TouchClick = function()
                    ui.click(tbl)
                end
            end
        end
    end
end

local function RequestTargetSet(self,targetID,diff,leastLv,maxLv,autoAccept)
    
    if targetID == 1 then
        autoAccept = 0
    end
	Team.RequestSetTarget(targetID, diff, leastLv, maxLv, autoAccept, 0, function()
		
	end)
    local function handler(isAuto)
        self:refrehBtnAutomaticFit(isAuto == 1)
    end
    Team.RequestAutoAccept(autoAccept, handler)
end

function _M:OpenTeamSet()
    if not DataMgr.Instance.TeamData:IsLeader() then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.TEAM, "leaderOnly")) 
        return
    end
    local node, luaObj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamTargetSet, 0,"team")
    local function callback(data,itemIndex,diff,leastLv,maxLv,lvText,autoAccept)
        local name = data.data.TargetName
        local itemName = ""
        local diffName = ""
        if itemIndex > 0 then
            local item = data.items[itemIndex]
            itemName = item.data.TargetName
            if item.data.HardChange ~= 0 then
                diffName = "--" .. self.teamMain.TargetDiffText[diff+1]
            end
        end
        self.lb_target_deatil.Text = itemName .. diffName
        self.lb_target_level.Text = " ["..lvText.."]"
        
        local targetID = data.data.ID
        if itemIndex > 0 then
            local item = data.items[itemIndex]
            targetID = item.data.ID
            
            
            
        end
        RequestTargetSet(self,targetID, diff~=nil and diff + 1 or 1,leastLv,maxLv,autoAccept)
    end
    luaObj:setCallbackConfirm(callback)
end

local function InitComponent(self,parent)
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/team/mine.gui.xml')
    self.menu.Enable = false
    initControls(self.menu,ui_names,self)
    parent:AddChild(self.menu)
    self.model = {}
    self.lb_target_deatil.Enable = true
    self.lb_target_deatil.IsInteractive = true
    self.lb_target_deatil.event_PointerClick = function()
        self:OpenTeamSet()
    end
    self.ib_choose.Enable = true
    self.ib_choose.IsInteractive = true
    self.ib_choose.event_PointerClick = function()
        self:OpenTeamSet()
    end
end

function _M:RequestAutoAccept(handler)
    if DataMgr.Instance.TeamData.HasTeam then
        if DataMgr.Instance.TeamData:IsLeader() then
            local value = self.btn_automatic_fit.IsChecked and 1 or 0
            
                self.isAcceptAutoTeam = value
                Team.RequestAutoAccept(value,handler)
            
        end
    end
end

function _M:RefreshListData(data)
    self.listdata = data.s2c_teamMembers
    
    if self.listdata == nil then
        return
    end
    if data.s2c_teamTarget.targetId == 0 then
        data.s2c_teamTarget.targetId = 1
    end
    self.isAcceptAutoTeam = data.s2c_isAcceptAutoTeam and data.s2c_isAcceptAutoTeam or 0
    self.btn_automatic_fit.Enable = false
    if DataMgr.Instance.TeamData.HasTeam then
        if DataMgr.Instance.TeamData:IsLeader() then
            self.btn_automatic_fit.Enable = true
            self.btn_automatic_fit.IsGray = false
        end
    end
    self:refrehBtnAutomaticFit(self.isAcceptAutoTeam == 1)
	
	self.TargetInfo = data.s2c_teamTarget
    self.teamMain.targetInfo = self.TargetInfo
    self.teamMain.memberCount = #self.listdata
    cleanRoleNodes(self)
    if self.listdata then
        for i = 1,#self.listdata,1 do
            local cvs = self["cvs_member"..i]
            setRoleNode(self,cvs,i)
        end
    end
    
    local targetDatas = TeamUtil.makeTeamTargetList()
    local titleData = nil
    local data = nil
    if self.TargetInfo.targetId == 0 then
        data = targetDatas[1]
        self.lb_target_deatil.Text = data.name
    else
        for i = 1,#targetDatas,1 do
            local items = targetDatas[i].items
            for j = 1,#items,1 do
                if(items[j].data.ID == self.TargetInfo.targetId ) then
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
            diffName = "--" .. self.teamMain.TargetDiffText[self.TargetInfo.difficulty]
        end
        local text = TeamUtil.getTargetLvText(self.TargetInfo.minLevel, self.TargetInfo.maxLevel)
        self.teamMain.targetInfo = self.TargetInfo
        self.lb_target_deatil.Text = data.TargetName .. diffName
        if text~= "" then
            self.lb_target_level.Text = " ["..text.."]"
        end
    end
end

local function Notify(status, userdata, opt)
    
	RefreshList()
end

function _M:Open(param)
    self.btn_apply.Visible = false
    self.btn_shout.Visible = false
    
    

    RefreshList = function(cb)
	    Team.RequestTeamMembers(function(data)
            
		    self:RefreshListData(data)
		    if cb ~= nil then
			    cb()
		    end
            if DataMgr.Instance.TeamData.HasTeam then
                if DataMgr.Instance.TeamData:IsLeader() then
                    self.btn_apply.Visible = true
                    self.btn_shout.Visible = true
                    
                end
            end

            if self.btn_apply.Visible then
                if data.haveApply ==nil or data.haveApply <= 0 then
                    self.lb_bj_apply.Visible = false
                else
                    self.lb_bj_apply.Visible = true
                end
            end
	    end)
    end

    self.menu.Visible = true
    if param == "createTeam" then
        Team.RequestCreateTeamAndSetTarget(1,1, function(data)
	    	RefreshList(function()
				
	    	end)
    	end, true)
    else
        RefreshList()
    end
    self:refreshBtnFollowLeader()
    DataMgr.Instance.TeamData:AttachLuaObserver(GlobalHooks.UITAG.GameUITeamInfo, {Notify = Notify})
     
    local function handler_RefreshApply(evtName,param)
        if self.btn_apply.Visible then
            if param.applyNum > 0 then
                self.lb_bj_apply.Visible = true
            else
                self.lb_bj_apply.Visible = false
            end
        end
    end

    self.refreshApply = handler_RefreshApply

    EventManager.Subscribe("Event.RefreshTeamApply",handler_RefreshApply)
end

function _M:CloseMineTeam()
    EventManager.Unsubscribe("Event.RefreshTeamApply",self.refreshApply)
end

function _M:Exit()
    self.menu.Visible = false
    cleanRoleNodes(self)
    DataMgr.Instance.TeamData:DetachLuaObserver(GlobalHooks.UITAG.GameUITeamInfo)
end

function _M.Create(parent,teamMainUI)
    local ret = {}
    setmetatable(ret,_M)
    ret.teamMain = teamMainUI
    InitComponent(ret,parent)
    return ret
end

return _M

