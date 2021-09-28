require "ui.dialog"
require "ui.team.teammembermenu"
require "ui.team.teamapplycell"
require "ui.team.teamaroundcell"
require "ui.team.aroundchacell"
require "utils.mhsdutils"
require "ui.team.zhenfachoosedlg"


TeamDialog = {}
setmetatable(TeamDialog, Dialog)
TeamDialog.__index = TeamDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local MAX_TEAMMEMBER = 5
local cellPerPage = 5
function TeamDialog.getInstance()
	LogInfo("enter get teamdialog instance")
    if not _instance then
        _instance = TeamDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function TeamDialog.getInstanceAndShow()
	LogInfo("enter teamdialog instance show")
    if not _instance then
        _instance = TeamDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set teamdialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function TeamDialog.getInstanceNotCreate()
    return _instance
end


function TeamDialog.DestroyDialog()
	if TeamLabel.getInstanceNotCreate() then
		TeamLabel.getInstanceNotCreate().DestroyDialog()		
	else
		_instance:CloseDialog()
	end
end

function TeamDialog.CloseDialog()
	if _instance then 
		LogInfo("destroy teamdialog")
		_instance:ResetList()
		if GetTeamManager() then
			GetTeamManager().EventAroundTeamChange:RemoveScriptFunctor(_instance.m_hAroundTeamChange)
			GetTeamManager().EventSingleCharacterListChange:RemoveScriptFunctor(_instance.m_hSingleCharacterListChange)
			GetTeamManager().EventMemberDataRefresh:RemoveScriptFunctor(_instance.m_hMemberDataRefresh)
			GetTeamManager().EventTeamListChange:RemoveScriptFunctor(_instance.m_hTeamListChange)
			GetTeamManager().EventApplicantChange:RemoveScriptFunctor(_instance.m_hApplicantChange)
		end
		_instance:OnClose()
		_instance = nil
	end
end

function TeamDialog.ToggleOpenClose()
	if not _instance then 
		_instance = TeamDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function TeamDialog.AroundTeamChange()
	LogInfo("teamdialog around team change")
	if _instance then
		if _instance.m_iSelectWin == 0 then
			_instance:ResetList()
			_instance:UpdateAroundTeam()
		end
	end	
end

function TeamDialog.AroundChaChange()
	LogInfo("teamdialog around character change")
	if _instance then
		if _instance.m_iSelectWin == 1 then
			_instance:ResetList()		
			_instance:UpdateAroundCharacter()
		end
	end
end

function TeamDialog.MemberDataChange()
	LogInfo("teamdialog member data change")
	if _instance then
		_instance:UpdateTeamMemberList()
	end
end

function TeamDialog.ApplicationChange()
	LogInfo("teamdialog application change")
	if _instance then
		if 2== _instance.m_iSelectWin then
			_instance:ResetList()
			_instance:UpdateApplyList()
		end
	end
end

----/////////////////////////////////////////------

function TeamDialog.GetLayoutFileName()
    return "TeamDialog.layout"
end

function TeamDialog:OnCreate()
	LogInfo("teamdialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pFormationBtn = CEGUI.Window.toPushButton(winMgr:getWindow("Team/left/zhenfa"))
	self.m_pAuto = CEGUI.Window.toCheckbox(winMgr:getWindow("Team/left/auto"))
	for i = 0, MAX_TEAMMEMBER - 1 do
		if not self.m_pMemberPic then
			self.m_pMemberPic = {}
		end
		self.m_pMemberPic[i] = winMgr:getWindow("teammate/back/pic" .. tostring(i))
		self.m_pMemberPic[i]:setMousePassThroughEnabled(true)
		if not self.m_pMemberName then
			self.m_pMemberName = {}
		end
		self.m_pMemberName[i] = winMgr:getWindow("teammate/back/name" .. tostring(i))
		self.m_pMemberName[i]:setMousePassThroughEnabled(true)
		if not self.m_pMemberSchool then
			self.m_pMemberSchool = {}
		end
		self.m_pMemberSchool[i] = winMgr:getWindow("teammate/back/school" .. tostring(i))
		self.m_pMemberSchool[i]:setMousePassThroughEnabled(true)
		if not self.m_pMemberLevel then
			self.m_pMemberLevel = {}
		end
		self.m_pMemberLevel[i] = winMgr:getWindow("teammate/back/level" .. tostring(i))
		self.m_pMemberLevel[i]:setMousePassThroughEnabled(true)
		if not self.m_pMemberBtn then
			self.m_pMemberBtn = {}
		end
		self.m_pMemberBtn[i] = CEGUI.Window.toGroupButton(winMgr:getWindow("teammate/back/btn" .. tostring(i)))
		self.m_pMemberBtn[i]:setGroupID(0)
		self.m_pMemberBtn[i]:setID(i)
		self.m_pMemberBtn[i]:subscribeEvent("MouseClick", TeamDialog.HandleMemberBtnClicked, self)
		self.m_pMemberBtn[i]:setSelected(false)
		if not self.m_pTitle then
			self.m_pTitle = {}
		end
		self.m_pTitle[i] = winMgr:getWindow("teammate/back/btn/title" .. tostring(i))
		if not self.m_pCamp then
			self.m_pCamp = {}
		end
		self.m_pCamp[i] = winMgr:getWindow("teammate/back/btn/camp" .. tostring(i))
		if not self.m_pChange then
			self.m_pChange = {}
		end
		self.m_pChange[i] = winMgr:getWindow("teammate/back/change" .. tostring(i))
	end	

	self.m_pAroundTeamBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("Team/right/lable1"))
	self.m_pAroundTeamBtn:setGroupID(1)
	self.m_pAroundTeamBtn:setID(0)
	
	self.m_pAroundChaBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("Team/right/lable2"))
	self.m_pAroundChaBtn:setGroupID(1)
	self.m_pAroundChaBtn:setID(1)

	self.m_pApplyBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("Team/right/lable3"))
	self.m_pApplyBtn:setGroupID(1)
	self.m_pApplyBtn:setID(2)

	self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("Team/right/main"))

    -- subscribe event
    self.m_pFormationBtn:subscribeEvent("Clicked", TeamDialog.HandleFormationBtnClicked, self)
	self.m_pAuto:subscribeEvent("CheckStateChanged", TeamDialog.HandleAutoStateChange, self)
	self.m_pAroundTeamBtn:subscribeEvent("SelectStateChanged", TeamDialog.HandleRightSelect, self)
	self.m_pAroundChaBtn:subscribeEvent("SelectStateChanged", TeamDialog.HandleRightSelect, self)
	self.m_pApplyBtn:subscribeEvent("SelectStateChanged", TeamDialog.HandleRightSelect, self)
	self.m_pPane:subscribeEvent("NextPage", TeamDialog.HandleNextPage, self)


	self.m_pAuto:setSelected(GetTeamManager():IsAutoOn())
	self.m_pAroundTeamBtn:setSelected(false)
	self.m_pAroundChaBtn:setSelected(false)
	self.m_pApplyBtn:setSelected(false)

	self.m_bChangePos = false
	self:UpdateTeamMemberList()
	self:UpdateRightBtnState()

	local num = GetTeamManager():GetApplicationNum()
	if num ~= 0 then
		self.m_pApplyBtn:setSelected(true)
	else

		self.m_pAroundChaBtn:setSelected(true)
	end
	if GetTeamManager() then
		self.m_hAroundTeamChange = GetTeamManager().EventAroundTeamChange:InsertScriptFunctor(TeamDialog.AroundTeamChange)
		self.m_hSingleCharacterListChange = GetTeamManager().EventSingleCharacterListChange:InsertScriptFunctor(TeamDialog.AroundChaChange)
		self.m_hMemberDataRefresh = GetTeamManager().EventMemberDataRefresh:InsertScriptFunctor(TeamDialog.MemberDataChange)
		self.m_hTeamListChange = GetTeamManager().EventTeamListChange:InsertScriptFunctor(TeamDialog.MemberDataChange)
		self.m_hApplicantChange = GetTeamManager().EventApplicantChange:InsertScriptFunctor(TeamDialog.ApplicationChange)
	end
	LogInfo("teamdialog oncreate end")
end

------------------- private: -----------------------------------


function TeamDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, TeamDialog)
    return self
end

function TeamDialog:HandleFormationBtnClicked(args)
	LogInfo("teamdialog handle formation btn clicked")
	if GetTeamManager():IsOnTeam() and (not GetTeamManager():IsMyselfLeader()) then
		GetGameUIManager():AddMessageTipById(145076)	
	end
	ZhenfaChooseDlg.getInstanceAndShow()	
	return true
end

function TeamDialog:HandleAutoStateChange(args)
	LogInfo("teamdialog handle auto state change")
	if self.m_pAuto:isSelected() then
		GetGameConfigManager():SetConfigValue("teamauto", 1)
	else
		GetGameConfigManager():SetConfigValue("teamauto", 0)
	end
	GetTeamManager():SetAutoStat(self.m_pAuto:isSelected())
end

function TeamDialog:UpdateTeamMemberList()
	self:refreshFormation()
	self:refreshChangePos()
    if TeamMemberMenu.getInstanceNotCreate() then
    	TeamMemberMenu.getInstanceNotCreate():SetVisible(false)
    end
	for i = 0, MAX_TEAMMEMBER - 1 do 
		self.m_pMemberBtn[i]:setVisible(false)
	end
	
	if not GetTeamManager():IsOnTeam() then
		self.m_pMemberName[0]:setText(GetMainCharacter():GetName())
		self.m_pMemberLevel[0]:setText(tostring(GetDataManager():GetMainCharacterLevel()))
		self.m_pMemberSchool[0]:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(GetMainCharacter():GetSchool()).name)
		local config = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(GetMainCharacter():GetShapeID())
		self.m_pMemberPic[0]:setProperty("Image", GetIconManager():GetImagePathByID(config.littleheadID):c_str())
		self.m_pMemberBtn[0]:setVisible(true)
		self.m_pTitle[0]:setText(MHSD_UTILS.get_resstring(2787))
		local camp = GetMainCharacter():GetCamp()
		if camp == 1 then
			self.m_pCamp[0]:setVisible(true)
			self.m_pCamp[0]:setProperty("Image", "set:MainControl image:campred")	
		elseif camp == 2 then
			self.m_pCamp[0]:setVisible(true)
			self.m_pCamp[0]:setProperty("Image", "set:MainControl image:campblue")	
		else
			self.m_pCamp[0]:setVisible(false)
		end
	end	

	local num = GetTeamManager():GetMemberNum()
	for i = 1, num do
		local member = GetTeamManager():GetMember(i)
		self.m_pMemberName[i - 1]:setText(member.strName)
		self.m_pMemberLevel[i - 1]:setText(tostring(member.level))
		self.m_pMemberSchool[i - 1]:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(member.eSchool).name)
		local config = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(member.shapeID)
		self.m_pMemberPic[i - 1]:setProperty("Image", GetIconManager():GetImagePathByID(config.littleheadID):c_str())
		self.m_pMemberBtn[i - 1]:setVisible(true)	
		--self.m_pMemberBtn[i - 1]:setID(member.id)
		if member.id == GetTeamManager():GetTeamLeader().id then
			self.m_pTitle[i - 1]:setText(MHSD_UTILS.get_resstring(2788))
		elseif member.eMemberState == eTeamMemberAbsent then
			self.m_pTitle[i - 1]:setText(MHSD_UTILS.get_resstring(2789))
		elseif member.eMemberState == eTeamMemberFallline then
			self.m_pTitle[i - 1]:setText(MHSD_UTILS.get_resstring(2790))
		else
			self.m_pTitle[i - 1]:setText(MHSD_UTILS.get_resstring(2791))
		end
		if member.campType == 1 then
			self.m_pCamp[i - 1]:setVisible(true)
			self.m_pCamp[i - 1]:setProperty("Image", "set:MainControl image:campred")	
		elseif member.campType == 2 then
			self.m_pCamp[i - 1]:setVisible(true)
			self.m_pCamp[i - 1]:setProperty("Image", "set:MainControl image:campblue")	
		else
			self.m_pCamp[i - 1]:setVisible(false)
		end
	end
end

function TeamDialog:HandleRightSelect(args)
	LogInfo("teamdialog handle right select")
	self.m_iSelectWin = self.m_pAroundChaBtn:getSelectedButtonInGroup():getID()

	self:ResetList()
	if 0 == self.m_iSelectWin then
		GetTeamManager():RequestTeamListInfo()
	elseif 1 == self.m_iSelectWin then
		GetTeamManager():RequestSingleCharList()
	elseif 2== self.m_iSelectWin then
		self:UpdateApplyList()
	end
	return true
end

function TeamDialog:UpdateRightBtnState()
	LogInfo("teamdialog update right btn state")
	if GetTeamManager():IsMyselfLeader() then
		self.m_pAroundTeamBtn:setVisible(false)
		self.m_pAroundChaBtn:setVisible(true)
		self.m_pApplyBtn:setVisible(true)
		--0周围队伍，1周围玩家，2申请列表 
		if 0 == self.m_iSelectWin then
			self.m_iSelectWin = 2
			self.m_pAroundTeamBtn:setSelected(false)
			self.m_pApplyBtn:setSelected(true)
		end
	else
		self.m_pAroundTeamBtn:setVisible(true)
		self.m_pAroundChaBtn:setVisible(true)
		self.m_pApplyBtn:setVisible(false)
		if 2 == self.m_iSelectWin then
			self.m_iSelectWin = 0
			self.m_pApplyBtn:setSelected(false)
			self.m_pAroundTeamBtn:setSelected(true)
		end
	end
end

function TeamDialog:UpdateApplyList()
	LogInfo("teamdialog update apply list")
	local num = GetTeamManager():GetApplicationNum()
	self.m_iMaxPage = math.ceil(num / cellPerPage)
	if not self.m_iCurPage or self.m_iCurPage > self.m_iMaxPage then
		return
	end

	if not self.m_lCells then
		self.m_lCells = {}
		self.m_iCellNum = 0
	end

	if not self.m_lApply then
		self.m_lApply = {}
		for i = 1, num do
			local apply = {}
			apply.data = GetTeamManager():GetApplication(i)
			table.insert(self.m_lApply, apply)
		end
	end
	local startPos = (self.m_iCurPage - 1) * cellPerPage + 1
	local endPos = self.m_iCurPage * cellPerPage 
	if endPos > num then
		endPos = num
	end
	for i = startPos, endPos do
		if i > self.m_iCellNum then
			self.m_lCells[i] = TeamApplyCell.CreateNewDlg(self.m_pPane)
			self.m_iCellNum = i
		end
		self.m_lApply[i].cell = self.m_lCells[i] 
		self.m_lApply[i].cell:Init(self.m_lApply[i].data)
		self.m_lApply[i].cell:GetWindow():setVisible(true)
		self.m_lApply[i].cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,0), CEGUI.UDim(0, self.m_lApply[i].cell:GetWindow():getPixelSize().height * (i - 1) + 1)))
	end
	for i = endPos + 1, self.m_iCellNum do
		self.m_lCells[i]:GetWindow():setVisible(false)
		self.m_lCells[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1)))
	end
end

function TeamDialog:UpdateAroundTeam()
	LogInfo("teamdialog update around team")
	local num = GetTeamManager():GetTeamNum()
	self.m_iMaxPage = math.ceil(num / cellPerPage)
	if not self.m_iCurPage or self.m_iCurPage > self.m_iMaxPage then
		return
	end

	if not self.m_lCells then
		self.m_lCells = {}
		self.m_iCellNum = 0
	end

	if not self.m_lTeams then
		self.m_lTeams = {}
		for i = 1, num do
			local team = {}
			team.data = GetTeamManager():GetTeamInfo(i)
			table.insert(self.m_lTeams, team)
		end
		table.sort(self.m_lTeams, TeamDialog.SortTeam)	
	end

	local startPos = (self.m_iCurPage - 1) * cellPerPage + 1
	local endPos = self.m_iCurPage * cellPerPage 
	if endPos > num then
		endPos = num
	end
	for i = startPos, endPos do
		if i > self.m_iCellNum then
			self.m_lCells[i] = TeamAroundCell.CreateNewDlg(self.m_pPane)
			self.m_iCellNum = i
		end
		self.m_lTeams[i].cell = self.m_lCells[i] 
		self.m_lTeams[i].cell:Init(self.m_lTeams[i].data)
		self.m_lTeams[i].cell:GetWindow():setVisible(true)
		self.m_lTeams[i].cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,0), CEGUI.UDim(0, self.m_lTeams[i].cell:GetWindow():getPixelSize().height * (i - 1) + 1)))
	end
	for i = endPos + 1, self.m_iCellNum do
		self.m_lCells[i]:GetWindow():setVisible(false)
		self.m_lCells[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1)))
	end
end

function TeamDialog.SortTeam(team1, team2)
	if (not team1) or (not team2) then
		return false
	end
	return team1.data.membernum > team2.data.membernum
end

function TeamDialog:UpdateAroundCharacter()
	LogInfo("teamdialog update around character")
	local num = GetTeamManager():GetSingleCharacterNum()
	self.m_iMaxPage = math.ceil(num / cellPerPage)
	if not self.m_iCurPage or self.m_iCurPage > self.m_iMaxPage then
		return
	end

	if not self.m_lCells then
		self.m_lCells = {}
		self.m_iCellNum = 0
	end

	if not self.m_lChars then
		self.m_lChars = {}
		for i = 1, num do
			local character = {}
			character.data = GetTeamManager():GetSingleCharacter(i)
			table.insert(self.m_lChars, character)
		end
		table.sort(self.m_lChars, TeamDialog.SortCharacter)	
	end

	local startPos = (self.m_iCurPage - 1) * cellPerPage + 1
	local endPos = self.m_iCurPage * cellPerPage 
	if endPos > num then
		endPos = num
	end
	for i = startPos, endPos do
		if i > self.m_iCellNum then
			self.m_lCells[i] = AroundChaCell.CreateNewDlg(self.m_pPane)
			self.m_iCellNum = i
		end
		self.m_lChars[i].cell = self.m_lCells[i] 
		self.m_lChars[i].cell:Init(self.m_lChars[i].data)
		self.m_lChars[i].cell:GetWindow():setVisible(true)
		self.m_lChars[i].cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,0), CEGUI.UDim(0, self.m_lChars[i].cell:GetWindow():getPixelSize().height * (i - 1) + 1)))
	end
	for i = endPos + 1, self.m_iCellNum do
		self.m_lCells[i]:GetWindow():setVisible(false)
		self.m_lCells[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1)))
	end
end

function TeamDialog.SortCharacter(character1, character2)
	if (not character1) or (not character2) then
		return false
	end
	return XiaoPang.distance(GetMainCharacter():GetLocation():ToFPOINT(),character1.data.roleLocation:ToFPOINT()) < XiaoPang.distance(GetMainCharacter():GetLocation():ToFPOINT(),character2.data.roleLocation:ToFPOINT())
end

function TeamDialog:ResetList()
	LogInfo("teamdialog reset list")
	self.m_lCells = nil
	self.m_lApply = nil
	self.m_lTeams = nil
	self.m_lChars = nil
	self.m_iCurPage = 1
	self.m_iMaxPage = 0
	self.m_iCellNum = 0
	self.m_pPane:cleanupNonAutoChildren()
end

function TeamDialog:HandleNextPage(args)
	LogInfo("teamdialog handle next page")
	if self.m_iMaxPage and self.m_iCurPage then
		if self.m_iCurPage < self.m_iMaxPage then
			self.m_iCurPage = self.m_iCurPage + 1
			local BarPos = self.m_pPane:getHorzScrollbar():getScrollPosition()
			self.m_pPane:getHorzScrollbar():Stop()
			if 0 == self.m_iSelectWin then
				self:UpdateAroundTeam()
			elseif 1 == self.m_iSelectWin then
				self:UpdateAroundCharacter()
			elseif 2== self.m_iSelectWin then
				self:UpdateApplyList()
			end
			self.m_pPane:getHorzScrollbar():setScrollPosition(BarPos)
		end
	end	
	return true
end

function TeamDialog:HandleMemberBtnClicked(args)
	LogInfo("teamdialog handle memeber btn clicked")
	if not GetTeamManager():IsOnTeam() then
		return true
	end

	local WndArgs = CEGUI.toWindowEventArgs(args) 
	local id = WndArgs.window:getID()

	if (not self.m_bChangePos) and id > 0 then
		self.m_bChangePos = true
		self.m_iCurSelect = id
		self:refreshChangePos()
	elseif id > 0 and self.m_bChangePos and self.m_iCurSelect ~= id then
		self.m_bChangePos = false
		self:refreshChangePos()
		GetTeamManager():RequestSwapMember(id, self.m_iCurSelect)
	elseif id == self.m_iCurSelect and self.m_bChangePos then
		self.m_bChangePos = false
		self:refreshChangePos()
	end

    local state = self:getMemberMenuStat(id)
    if 5 == state then
        return true
	end

   local dlg = TeamMemberMenu.getInstanceAndShow()
   dlg:InitBtn(state, id)
end

function TeamDialog:getMemberMenuStat(index)
	LogInfo("teamdialog get member menu state")
	local id = GetTeamManager():GetMember(index + 1).id
	if GetTeamManager():IsMyselfLeader() then
        if GetMainCharacter():GetID() == id then 
            return 1           --队长点自己
        else
            return 0           --队长点别人
		end
    elseif GetTeamManager():IsOnTeam() then
        if GetMainCharacter():GetID() == id then
            return 3           --队员点自己
        else
            return 2           --队员点别人
    	end
	end
    return 5   --单身
end

function TeamDialog:refreshFormation()
	LogInfo("teamdialog refresh formation")
	local manager = FormationManager.getInstance()
	local formationID = 0
	if GetTeamManager():IsOnTeam() and (not GetTeamManager():IsMyselfLeader()) then
		formationID = manager.m_iTeamFormation
	else
		formationID = manager.m_iMyFormation
	end
	local formationConfig = knight.gsp.battle.GetCFormationbaseConfigTableInstance():getRecorder(formationID)
	self.m_pFormationBtn:setText(formationConfig.name)
end

function TeamDialog:refreshChangePos()
	LogInfo("teamdialog refresh change pos")
	if not self.m_bChangePos or GetTeamManager():GetMemberNum() <= 2 then
		self.m_bChangePos = false
		for i = 0, MAX_TEAMMEMBER - 1 do
			self.m_pChange[i]:setVisible(false)
		end 
	else
		local num = GetTeamManager():GetMemberNum()
		for i = 1, num - 1 do
			if i == self.m_iCurSelect then
				self.m_pChange[i]:setVisible(false)
			else
				self.m_pChange[i]:setVisible(true)
			end
		end
	end

end

return TeamDialog
