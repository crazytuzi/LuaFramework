require "ui.dialog"
require "utils.mhsdutils"
require "ui.task.taskdialog"
require "ui.systemsettingdlg"
require "ui.teamlabel"
MainControl = {}
setmetatable(MainControl, Dialog)
MainControl.__index = MainControl

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;



local unlockFlyTime = 0.8
local totalAddTime = 1.0
local downTime = 0.5
local showSpeTime = 0.3
local autoHideTime = 20.0

local State_Folded = 1
local State_Folding = 2
local State_UnFolded = 3
local State_UnFolding = 4

local State_NULL = 1
local State_StartUnLock = 2
local State_DownAdding = 3
local State_RightAdding = 4

local State_Show = 1
local State_Showing = 2
local State_Hide = 3
local State_Hiding = 4

local eProductPos = 0
local ePackPos = 1
local eRightPosMax = 2

local eTaskPos = 0
local eJewelryPos = 1
local eSkillPos = 2
local eXiakePos = 3
local eTeamPos = 4
local eFriendPos = 5
local eSystemPos = 6
local eDownPosMax = 7

local eMaincontrolTipStart = 0
local eMaincontrolPackTip = 1
local eMaincontrolTastTip = 2
--local eMaincontrolAroundTip = 3
local eMaincontrolProductTip = 3
local eMaincontrolSkillTip = 4
local eMaincontrolXiakeTip = 5
local eMaincontrolTeamTip = 6
local eMaincontrolFriendTip = 7
local eMaincontrolSystemTip = 8
local eMaincontrolTipMax = 9

function MainControl.getInstance()
	LogInfo("enter get maincontrol instance")
    if not _instance then
        _instance = MainControl:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function MainControl.getInstanceAndShow()
	LogInfo("enter maincontrol instance show")
    if not _instance then
        _instance = MainControl:new()
        _instance:OnCreate()
	else
		LogInfo("set maincontrol visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function MainControl.getInstanceNotCreate()
    return _instance
end

function MainControl.DestroyDialog()
	if _instance then 
		LogInfo("destroy maincontrol")
		if GetTeamManager() then
			GetTeamManager().EventApplicantChange:RemoveScriptFunctor(_instance.m_hApplicantChange)
		end
		_instance:OnClose()
		_instance = nil
	end
end

function MainControl.ToggleOpenClose()
	if not _instance then 
		_instance = MainControl:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function MainControl.SetPackBtnFlash()
	if _instance then
		GetGameUIManager():AddUIEffect(_instance.m_pPackBtn, MHSD_UTILS.get_effectpath(10185), false)
	end
end

function MainControl.TeamApplyChange()
	if GetTeamManager() then
		if GetTeamManager():GetApplicationNum() == 0 then
			MainControl.setTeamTip(0)
		else
			MainControl.setTeamTip(1)
		end
	end
end


----/////////////////////////////////////////------

function MainControl.GetLayoutFileName()
    return "maincontrol.layout"
end

function MainControl:OnCreate()
	LogInfo("maincontrol oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_mTipNum = {}
	self.m_mTipWnd = {}
	for i = eMaincontrolTipStart, eMaincontrolTipMax - 1 do
		self.m_mTipNum[i] = 0
	end

    -- get windows
    self.m_pPackBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/pack"))
	self.m_pTeamBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/team"))
	self.m_pXiakeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/friend"))
	self.m_pTaskBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/task"))
	self.m_pFriendBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/faction"))
	self.m_pSkillBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/skill"))
	self.m_pSystemBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/system"))
	self.m_pProductBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/production"))
 --   self.m_pAroundBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/zhouwei"));
	self.m_pJewelryBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/back/ring"))
    self.m_pDownPanel = winMgr:getWindow("MainControlDlg/down")
    self.m_pRightPanel = winMgr:getWindow("MainControlDlg/right")
    self.m_pSwitchFoldBtn = CEGUI.Window.toPushButton(winMgr:getWindow("MainControlDlg/control"))
    self.m_pFriendMsgNotify = winMgr:getWindow("MainControlDlg/back/faction/mark")
    self.m_pTeamTipWnd = winMgr:getWindow("MainControlDlg/back/team/mark")
    self.m_pSwitchTipWnd = winMgr:getWindow("MainControlDlg/control/mark")
    self.m_pXiakeTipWnd = winMgr:getWindow("MainControlDlg/back/friend/mark")
 	self.m_pFactionMark = winMgr:getWindow("MainControlDlg/back/faction/mark")
	self.m_pTemporaryPackBtn = CEGUI.toPushButton(winMgr:getWindow("MainControlDlg/teamporarybackpack"))
    -- subscribe event
--    self.m_pAroundBtn:subscribeEvent("Clicked", MainControl.HandleAroundBtnClick,self)
	self.m_pPackBtn:subscribeEvent("Clicked", MainControl.HandlePackBtnClicked, self)
	self.m_pTeamBtn:subscribeEvent("Clicked", MainControl.HandleTeamBtnClicked, self)
	self.m_pXiakeBtn:subscribeEvent("Clicked", MainControl.HandleXiakeBtnClicked, self)	
	self.m_pFriendBtn:subscribeEvent("Clicked", MainControl.HandleFriendBtnClicked, self)
	self.m_pTaskBtn:subscribeEvent("Clicked", MainControl.HandleTaskBtnClicked, self)
	self.m_pSkillBtn:subscribeEvent("Clicked", MainControl.HandleSkillBtnClicked, self)
	self.m_pSystemBtn:subscribeEvent("Clicked", MainControl.HandleSystemBtnClicked, self)
	self.m_pProductBtn:subscribeEvent("Clicked", MainControl.HandleProductBtnClicked, self)
	self.m_pSwitchFoldBtn:subscribeEvent("Clicked", MainControl.HandleSwitchFoldBtnClick, self)
	self.m_pTemporaryPackBtn:subscribeEvent("Clicked", MainControl.HandleTemporaryPackBtnClicked, self)
	self.m_pJewelryBtn:subscribeEvent("Clicked", MainControl.HandleJewelryBtnClicked, self)
	--init	
	local bVisible = GetRoleItemManager():FindItemByBagIDAndPos(knight.gsp.item.BagTypes.TEMP, 0) ~= nil 
		self.m_pTemporaryPackBtn:setVisible(bVisible)
	self.m_pFriendMsgNotify:setVisible(false)
	self.m_pFactionMark:setVisible(false)
    self.m_mTipWnd[eMaincontrolFriendTip] = self.m_pFriendMsgNotify
	self.m_mTipNum[eMaincontrolFriendTip] = 0

    self.m_pTeamTipWnd:setVisible(false)
    self.m_mTipWnd[eMaincontrolTeamTip] = self.m_pTeamTipWnd
    self.m_mTipNum[eMaincontrolTeamTip] = 0
	
	self.m_pSwitchTipWnd:setVisible(false)
	self.m_pSwitchTipNum = 0

    self.m_pXiakeTipWnd:setVisible(false)
    self.m_mTipWnd[eMaincontrolXiakeTip] = self.m_pXiakeTipWnd
    self.m_mTipNum[eMaincontrolXiakeTip] = 0 
	
	self.m_aRightWndSt = {}
	local packStat = {}
	packStat.pWnd = self.m_pPackBtn
	packStat.bUnlocked = true
	self.m_aRightWndSt[ePackPos] = packStat

	local productStat = {}
	productStat.pWnd = self.m_pProductBtn
	productStat.bUnlocked = true
	self.m_aRightWndSt[eProductPos] = productStat

	self.m_aDownWndSt = {}
	local skillStat = {}
	skillStat.pWnd = self.m_pSkillBtn
	skillStat.bUnlocked = false
	self.m_aDownWndSt[eSkillPos] = skillStat

--[[	local aroundStat = {}
	aroundStat.pWnd = self.m_pAroundBtn
	aroundStat.bUnlocked = true
	self.m_aDownWndSt[eAroundPos] = aroundStat
	]]
	local taskStat = {}
	taskStat.pWnd = self.m_pTaskBtn
	taskStat.bUnlocked = true
	self.m_aDownWndSt[eTaskPos] = taskStat

	local xiakeStat = {}
	xiakeStat.pWnd = self.m_pXiakeBtn
	xiakeStat.bUnlocked = false
	self.m_aDownWndSt[eXiakePos] = xiakeStat

	local teamStat = {}
	teamStat.pWnd = self.m_pTeamBtn
	teamStat.bUnlocked = true 
	self.m_aDownWndSt[eTeamPos] = teamStat

	local friendStat = {}
	friendStat.pWnd = self.m_pFriendBtn
	friendStat.bUnlocked = true
	self.m_aDownWndSt[eFriendPos] = friendStat

	local systemStat = {}
	systemStat.pWnd = self.m_pSystemBtn		
	systemStat.bUnlocked = true
	self.m_aDownWndSt[eSystemPos] = systemStat

	local jewelryStat = {}
	jewelryStat.pWnd = self.m_pJewelryBtn		
	jewelryStat.bUnlocked = false 
	self.m_aDownWndSt[eJewelryPos] = jewelryStat 

	self.m_pUnlockEndPos = {}
	self.m_pUnlockStartPos = {}

	self.m_aRightWnd = {}
	self.m_aDownWnd = {}
	
	self:InitBtnShowStat()
	self:InitFoldState()

	self.m_AddState = State_NULL 
	
	self.m_i10Time = -1
	self.m_i100Time = -1
	self.m_i1000Time = -1

	LogInfo("maincontrol oncreate end")
	local p = require "protocoldef.knight.gsp.faction.crequestapplicantlist2":new()
	require "manager.luaprotocolmanager":send(p)
end

------------------- private: -----------------------------------


function MainControl:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, MainControl)
    return self
end

function MainControl.setTemporaryPackBtnVisible(bVisible)
	local self = _instance
	if not self then
		return
	end
	self.m_pTemporaryPackBtn:setVisible(bVisible)
end

function MainControl:HandleTemporaryPackBtnClicked(e)
	CTemporaryPack:ToggleOpenHide()
end

function MainControl:HandlePackBtnClicked(args)
	LogInfo("maincontrol pack button clicked")
    CMainPackLabelDlg:GetSingletonDialogAndShowIt():Show()
	self.m_fAutoHideTime = 0
	return true
end

function MainControl:HandleXiakeBtnClicked(args)
	LogInfo("maincontrol xiake btn clicked")
	XiakeJiuguan.getAndShow()
	self.m_fAutoHideTime = 0
	return true
end

function MainControl:HandleTaskBtnClicked(args)
	LogInfo("maincontrol task btn clicked")
	CTaskDialog.ToggleOpenHide()		
	self.m_fAutoHideTime = 0
	return true
end

function MainControl:HandleTeamBtnClicked(args)
	LogInfo("maincontrol team btn clicked")
	self.m_mTipNum[eMaincontrolTeamTip] = 0
--	TeamDialog.getInstanceAndShow()
	TeamLabel.getInstance().ShowStarDlg()


	self.m_fAutoHideTime = 0
	return true
end

function MainControl:HandleFriendBtnClicked(args)
	LogInfo("maincontrol friend btn clicked")
	if GetFriendsManager() then
		if GetFriendsManager():HasNotShowMsg() then
			GetFriendsManager():PopChatMsg()
		else
    		FriendsDialog.getInstanceAndShow()
		end
	else	
    	FriendsDialog.getInstanceAndShow()
	end
	self.m_fAutoHideTime = 0
	return true
end

function MainControl:HandleSkillBtnClicked(args)
	LogInfo("maincontrol skill btn clicked")
	-- CAcupointLevelupDlg:GetSingletonDialogAndShowIt()
	require "ui.skill.skilllable"
	SkillLable.Show(1)
	self.m_fAutoHideTime = 0
	return true
end

function MainControl:HandleSystemBtnClicked(args)
	LogInfo("maincontrol system btn clicked")
	SystemSettingDlg.getInstanceAndShow()
	self.m_fAutoHideTime = 0
	return true
end

function MainControl.SetFriendBtnFlash(bFlash)
	if _instance then
		LogInfo("maincontrol set friend btn flash")
		if bFlash then
			_instance.m_mTipNum[eMaincontrolFriendTip] = GetFriendsManager():GetNotReadMsgNum()
		else
			_instance.m_mTipNum[eMaincontrolFriendTip] = 0
		end
        
        _instance:refreshTipInfo()
	end
end

function MainControl.RefreshFriendBtnFlashState()
	LogInfo("maincontrol refresh friend btn flash state")
	local hasFriendChatMsg = GetFriendsManager():HasNotShowMsg()
	MainControl.SetFriendBtnFlash(hasFriendChatMsg)	
end

function MainControl:HandleProductBtnClicked(args)
	LogInfo("maincontrol product btn clicked")
	WorkshopLabel.Show(1, 3, 0)
	--CWorkshopManager:GetSingletonDialog():Show()
	self.m_fAutoHideTime = 0
	return true
end

function MainControl:HandleSwitchFoldBtnClick(args)
	LogInfo("maincontrol switchfold btn clicked")
	if self.m_AddState ~= State_NULL then
		return true
	end
	print("fold state ", self.m_FoldState)
	if self.m_FoldState == State_Folded then
		LogInfo("*****************")
		self:UnFoldButton()
        if CChatOutBoxOperatelDlg:GetSingleton() then
       		CChatOutBoxOperatelDlg:GetSingleton():HideChatContent()
        end
	elseif self.m_FoldState == State_UnFolded then
		self:FoldButton()
        if CChatOutBoxOperatelDlg:GetSingleton() then
       		CChatOutBoxOperatelDlg:GetSingleton():ShowChatContent()
        end
	end
	self.m_fAutoHideTime = 0
	return true
end

function MainControl:FoldButton()
	LogInfo("maincontrol foldbutton")
	self.m_FoldState = State_Folding
	self.m_fFoldElapseTime = 0
end

function MainControl:UnFoldButton()
	LogInfo("maincontrol unfoldebutton")
	self.m_ShowSpeBtnState = State_Hiding
	self.m_fShowSpecialBtnTime = 0
end

function MainControl:InitFoldState()
	LogInfo("maincontrol initfoldstate")
	self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fSwitchBtnLeft))
	self.m_pRightPanel:setYPosition(CEGUI.UDim(0, self.m_fSwitchBtnTop))	

	self.m_pDownPanel:SetAllChildrenVis(false)
	self.m_pRightPanel:SetAllChildrenVis(false)

	self.m_pDownPanel:setVisible(false)
	self.m_pRightPanel:setVisible(false)
	self.m_fFoldElapseTime = 0
	self.m_FoldState = State_Folded

	self:EndShowSpecialBtn()
end

function MainControl:UpdateFoldState(elapse)
	if self.m_FoldState ~= State_Folding and self.m_FoldState ~= State_UnFolding then
		return 
	end
	local totaltime = 0.2
	if self.m_FoldState == State_UnFolding then
		totaltime = 0.2
	end
	local graveTime = 0.05
	self.m_fFoldElapseTime = self.m_fFoldElapseTime + elapse
	if self.m_fFoldElapseTime > totaltime then
		if self.m_FoldState == State_Folding then
			self:EndFoldButton()
		elseif self.m_FoldState == State_UnFolding then
			self:EndUnFoldButton()
		end
	end

	local v_x = math.abs(self.m_fDownPanelLeft - self.m_fSwitchBtnLeft) / totaltime
	local v_y = math.abs(self.m_fRightPanelTop - self.m_fSwitchBtnTop) / totaltime
	local DownPanelPos = self.m_pDownPanel:GetTopLeftPosOnParent().x
	local RightPanelPos = self.m_pRightPanel:GetTopLeftPosOnParent().y

	if self.m_FoldState == State_UnFolding then
		local v_x = math.abs(self.m_fDownPanelLeft - self.m_fSwitchBtnLeft) / (totaltime - graveTime)
		local v_y = math.abs(self.m_fRightPanelTop - self.m_fSwitchBtnTop) / (totaltime - graveTime)
		if self.m_fFoldElapseTime < (totaltime - graveTime) then
			DownPanelPos = DownPanelPos - v_x * elapse
			RightPanelPos = RightPanelPos - v_y * elapse
		else
			local angle = ((self.m_fFoldElapseTime - totaltime + graveTime) / graveTime) * 3.1415926
			DownPanelPos = self.m_fDownPanelLeft - 30 * math.sin(angle)
			RightPanelPos = self.m_fRightPanelTop - 30 * math.sin(angle)
		end
	elseif self.m_FoldState == State_Folding then
		DownPanelPos = DownPanelPos + v_x * elapse
		RightPanelPos = RightPanelPos + v_y * elapse
	end
	self.m_pDownPanel:setXPosition(CEGUI.UDim(0, DownPanelPos))
	self.m_pRightPanel:setYPosition(CEGUI.UDim(0, RightPanelPos))
	
	self:CheckFoldStateWndVis()
end

function MainControl:CheckFoldStateWndVis()
	local switchBtnScreenLeft = self.m_pSwitchFoldBtn:GetScreenPos().x
	local switchBtnScreenTop = self.m_pSwitchFoldBtn:GetScreenPos().y

	if self.m_FoldState == State_UnFolding then
		for i = 0, self.m_iDownNum - 1 do
			if self.m_aDownWnd[i]:GetScreenPos().x < switchBtnScreenLeft then
				self.m_aDownWnd[i]:setVisible(true)
			end
		end
		for i = 0, self.m_iRightNum - 1 do
			if self.m_aRightWnd[i]:GetScreenPos().y < switchBtnScreenTop then
				self.m_aRightWnd[i]:setVisible(true)
			end
		end
	elseif self.m_FoldState == State_Folding then
		for i = 0, self.m_iDownNum - 1 do 
			if self.m_aDownWnd[i]:GetScreenPos().x > switchBtnScreenLeft then
				self.m_aDownWnd[i]:setVisible(false)
			end
		end
		for i = 0, self.m_iRightNum - 1 do
			if self.m_aRightWnd[i]:GetScreenPos().y > switchBtnScreenTop then
				self.m_aRightWnd[i]:setVisible(false)
			end
		end
	end
end

function MainControl:EndFoldButton()
	LogInfo("maincontrol endfoldbutton")
	self.m_FoldState = State_Folded
	self.m_fFoldElapseTime = 0
	self.m_pDownPanel:SetAllChildrenVis(false)
	self.m_pDownPanel:setVisible(false)
	self.m_pRightPanel:SetAllChildrenVis(false)
	self.m_pRightPanel:setVisible(false)

	self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fSwitchBtnLeft))
	self.m_pRightPanel:setYPosition(CEGUI.UDim(0, self.m_fSwitchBtnTop))
	self.m_pSwitchFoldBtn:setProperty("NormalImage", "set:MainControl image:OpenANormal")
	self.m_pSwitchFoldBtn:setProperty("HoverImage", "set:MainControl image:OpenAPushed")
	self.m_pSwitchFoldBtn:setProperty("PushedImage", "set:MainControl image:OpenAPushed")

	self.m_ShowSpeBtnState = State_Showing
	self.m_fShowSpecialBtnTime = 0
	self.m_pProductBtn:setXPosition(CEGUI.UDim(0, self.m_pSwitchFoldBtn:getPixelSize().width))
	self.m_pProductBtn:setYPosition(CEGUI.UDim(0, -(self.m_pSwitchFoldBtn:getPixelSize().height + 1) * 2))
	self.m_pProductBtn:setVisible(self:IsBtnAlreadyExist(self.m_pProductBtn, 1))
	self.m_pPackBtn:setXPosition(CEGUI.UDim(0, self.m_pSwitchFoldBtn:getPixelSize().width))
	self.m_pPackBtn:setYPosition(CEGUI.UDim(0, -(self.m_pSwitchFoldBtn:getPixelSize().height + 1)))
	self.m_pPackBtn:setVisible(self:IsBtnAlreadyExist(self.m_pPackBtn, 1))

	self.m_pDownPanel:setVisible(true)
	self.m_pRightPanel:setVisible(true)
end

function MainControl:EndUnFoldButton()
	LogInfo("maincontrol endunfoldbutton")
	self.m_FoldState = State_UnFolded
	self.m_fFoldElapseTime = 0
	self.m_fAutoHideTime = 0
	
	for i = 0, self.m_iDownNum - 1 do
		self.m_aDownWnd[i]:setVisible(true)
	end
	self.m_pDownPanel:setVisible(true)

	for i = 0, self.m_iRightNum - 1 do
		self.m_aRightWnd[i]:setVisible(true)
	end
	self.m_pRightPanel:setVisible(true)
	
	self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fDownPanelLeft))
	self.m_pRightPanel:setYPosition(CEGUI.UDim(0, self.m_fRightPanelTop))
	self.m_pSwitchFoldBtn:setProperty("NormalImage", "set:MainControl image:ClosedNormal")
	self.m_pSwitchFoldBtn:setProperty("HoverImage", "set:MainControl image:ClosedPuShed")
	self.m_pSwitchFoldBtn:setProperty("PushedImage", "set:MainControl image:ClosedPuShed")

	if self.m_pAddWnd then
		self:AddBtn(self.m_pAddWnd, self:GetInsertPos(self.m_pAddWnd), self:GetButtonPos(self.m_pAddWnd))
		self.m_pAddWnd = nil
	end

	if self.m_iAfterShowGuideId then
		GetNewRoleGuideManager():StartGuide(self.m_iAfterShowGuideId)
		self.m_iAfterShowGuideId = nil
	end

	if GetTeamManager() then
		self.m_hApplicantChange = GetTeamManager().EventApplicantChange:InsertScriptFunctor(MainControl.TeamApplyChange)
	end
end

--根据等级初始化按钮
function MainControl:InitBtnShowStat()
	LogInfo("maincontrol init btn showstat")
	self.m_iDownNum = 0
	self.m_iRightNum = 0	
	if GetNewRoleGuideManager() then
		--skill ,unlock level 3
		if self.m_iGuideId ~= 30011 and GetNewRoleGuideManager():isGuideFinish(30011) then
			self.m_aDownWndSt[eSkillPos].bUnlocked = true
		end
		--product ,unlock by task 190105
		if self.m_iGuideId ~= 30020 and GetNewRoleGuideManager():isGuideFinish(30020) then
			self.m_aRightWndSt[eProductPos].bUnlocked = true
		end
		--team, unlock level 18
--		if self.m_iGuideId ~= 30022 and GetNewRoleGuideManager():isGuideFinish(30022) then
--			self.m_aDownWndSt[eTeamPos].bUnlocked = true
--		end
		--xiake, unlock by task 102019
		if self.m_iGuideId ~= 30025 and GetNewRoleGuideManager():isGuideFinish(30025) then
			self.m_aDownWndSt[eXiakePos].bUnlocked = true
			
			if self.m_i10Time == -1 or self.m_i100Time == -1 or self.m_i1000Time == -1 then
				GetNetConnection():send(knight.gsp.xiake.COpenXiakeJiuguan())
			end
		end
		--jewelry, unlock level 60
		if self.m_iGuideId ~= 30050 and GetNewRoleGuideManager():isGuideFinish(30050) then
			LogInfo("maincontrol guide 30050 finish")
			self.m_aDownWndSt[eJewelryPos].bUnlocked = true
		end
	end
		
	for i = 0, eRightPosMax - 1 do
		if self.m_aRightWndSt[i].bUnlocked then
			self.m_aRightWnd[self.m_iRightNum] = self.m_aRightWndSt[i].pWnd
			self.m_iRightNum = self.m_iRightNum + 1
		end
	end

	for i = 0, eDownPosMax - 1 do
		if self.m_aDownWndSt[i].bUnlocked then
			self.m_aDownWnd[self.m_iDownNum] = self.m_aDownWndSt[i].pWnd
			self.m_iDownNum = self.m_iDownNum + 1
		end
	end

	local switchBtnPos = self.m_pSwitchFoldBtn:GetTopLeftPosOnParent()
	self.m_fSwitchBtnLeft = switchBtnPos.x
	self.m_fSwitchBtnTop = switchBtnPos.y
	self.m_fDownPanelLeft = self.m_fSwitchBtnLeft - (self.m_pSwitchFoldBtn:getPixelSize().width + 1) * self.m_iDownNum
	self.m_fRightPanelTop = self.m_fSwitchBtnTop - (self.m_pSwitchFoldBtn:getPixelSize().height + 1) * self.m_iRightNum

	for i = 0, self.m_iDownNum - 1 do
		self.m_aDownWnd[i]:setXPosition(CEGUI.UDim(0, i * (self.m_pSwitchFoldBtn:getPixelSize().width + 1)))
		self.m_aDownWnd[i]:setYPosition(CEGUI.UDim(0,0))
	end

	for i = 0, self.m_iRightNum - 1 do
		print("right window name = " .. self.m_aRightWnd[i]:getName())
		self.m_aRightWnd[i]:setYPosition(CEGUI.UDim(0, i * (self.m_pSwitchFoldBtn:getPixelSize().height + 1)))
		self.m_aRightWnd[i]:setXPosition(CEGUI.UDim(0, 0))
	end

end

--最终显示按钮位置
function MainControl:ShowBtnFinish()
	LogInfo("maincontrol showbtn finish")
	self.m_pDownPanel:SetAllChildrenVis(false)
	self.m_pRightPanel:SetAllChildrenVis(false)
	
	local switchBtnPos = self.m_pSwitchFoldBtn:GetTopLeftPosOnParent()
	self.m_fSwitchBtnLeft = switchBtnPos.x
	self.m_fSwitchBtnTop = switchBtnPos.y

	self.m_fDownPanelLeft = self.m_fSwitchBtnLeft - (self.m_pSwitchFoldBtn:getPixelSize().width + 1) * self.m_iDownNum
	self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fDownPanelLeft))
	for i = 0, self.m_iDownNum - 1 do
		self.m_aDownWnd[i]:setXPosition(CEGUI.UDim(0, i * (self.m_pSwitchFoldBtn:getPixelSize().width + 1)))
		self.m_aDownWnd[i]:setYPosition(CEGUI.UDim(0, 0))
		self.m_aDownWnd[i]:setVisible(true)
	end

	self.m_fRightPanelTop = self.m_fSwitchBtnTop - (self.m_pSwitchFoldBtn:getPixelSize().height + 1) * self.m_iRightNum
	self.m_pRightPanel:setYPosition(CEGUI.UDim(0, self.m_fRightPanelTop))
	for i = 0, self.m_iRightNum - 1 do
		self.m_aRightWnd[i]:setYPosition(CEGUI.UDim(0, i * (self.m_pSwitchFoldBtn:getPixelSize().height + 1)))
		self.m_aRightWnd[i]:setXPosition(CEGUI.UDim(0, 0))
		self.m_aRightWnd[i]:setVisible(true)
	end
end

function MainControl:run(elapsed)
	local elapse = elapsed / 1000
	local xiakeTickNum = 0
	
	if self.m_i1000Time > 0 then
		self.m_i1000Time = self.m_i1000Time - elapse
		if self.m_i1000Time < 0 then
			self.m_i1000Time = 0
		end
	end	
	if self.m_i100Time > 0 then
		self.m_i100Time = self.m_i100Time - elapse
		if self.m_i100Time < 0 then
			self.m_i100Time = 0
		end
	end	
	if self.m_i10Time > 0 then
		self.m_i10Time = self.m_i10Time - elapse
		if self.m_i10Time < 0 then
			self.m_i10Time = 0
		end
	end	

	if self.m_i1000Time == 0 then
		xiakeTickNum = xiakeTickNum + 1
	end	
	if self.m_i100Time == 0 then
		xiakeTickNum = xiakeTickNum + 1
	end
	if self.m_i10Time == 0 then
		xiakeTickNum = xiakeTickNum + 1
	end
	if GetNewRoleGuideManager() then
		if GetNewRoleGuideManager():isGuideFinish(30025) and xiakeTickNum ~= self.m_mTipNum[eMaincontrolXiakeTip] then
			self.m_mTipNum[eMaincontrolXiakeTip] = xiakeTickNum
			self:refreshTipInfo()
		end
	end

	if self.m_AddState ~= State_NULL then
		self:UpdateAddBtn(elapse)
	end

	if self.m_FoldState == State_Folding or self.m_FoldState == State_UnFolding then
		self:UpdateFoldState(elapse)
	end

	if self.m_ShowSpeBtnState == State_Hiding or self.m_ShowSpeBtnState == State_Showing then
		self:UpdateSpeBtnShow(elapse)
	end
	if self.m_FoldState == State_UnFolded and self.m_AddState == State_NULL then
		if GetNewRoleGuideManager() then
			if GetNewRoleGuideManager():NeedLockScreen() then
				self.m_fAutoHideTime = 0
			else
				self.m_fAutoHideTime = self.m_fAutoHideTime + elapse
				if self.m_fAutoHideTime > autoHideTime then
					self:FoldButton()
					if CChatOutBoxOperatelDlg:GetSingleton() then
						CChatOutBoxOperatelDlg:GetSingleton():ShowChatContent()
					end
				end
			end
		else
			self.m_fAutoHideTime = self.m_fAutoHideTime + elapse
			if self.m_fAutoHideTime > autoHideTime then
				self:FoldButton()
				if CChatOutBoxOperatelDlg:GetSingleton() then
					CChatOutBoxOperatelDlg:GetSingleton():ShowChatContent()
				end
			end
		end	
	else
		self.m_fAutoHideTime = 0
	end

end

function MainControl:UpdateAddBtn(elapse)
	if not self.m_fUnlockFlyTime then
		return
	end
	self.m_fUnlockFlyTime = self.m_fUnlockFlyTime + elapse
	if self.m_fUnlockFlyTime >= unlockFlyTime then
		self.m_fAddElapseTime = self.m_fAddElapseTime + elapse
	end

	if self.m_AddState == State_DownAdding then
		if self.m_fUnlockFlyTime < unlockFlyTime then
			self.m_aDownWnd[self.m_iAddPos]:setXPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.x + (self.m_pUnlockEndPos.x - self.m_pUnlockStartPos.x) * (self.m_fUnlockFlyTime / unlockFlyTime) - self.m_aDownWnd[self.m_iAddPos]:getParent():GetScreenPos().x))
			self.m_aDownWnd[self.m_iAddPos]:setYPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.y + (self.m_pUnlockEndPos.y - self.m_pUnlockStartPos.y) * (self.m_fUnlockFlyTime / unlockFlyTime) * (self.m_fUnlockFlyTime / unlockFlyTime) - self.m_aDownWnd[self.m_iAddPos]:getParent():GetScreenPos().y))
		else
			if self.m_fAddElapseTime >= totalAddTime then
				self:ShowBtnFinish()
				self.m_AddState = State_NULL
				self.m_pAddWnd = nil
                if not self.m_iGuideId then return end
				local record = knight.gsp.task.GetCArrowEffectTableInstance():getRecorder(self.m_iGuideId)
				local winMgr = CEGUI.WindowManager:getSingleton()
				local pWnd = winMgr:getWindow(record.button)
				if pWnd then
					local pEffect = GetGameUIManager():AddUIEffect(pWnd, MHSD_UTILS.get_effectpath(10362),false)
					if pEffect then
						local notify = CGameUImanager:createNotify(self.ChangeEffect)
						pEffect:AddNotify(notify)
					end
				end
			elseif self.m_fAddElapseTime < (totalAddTime - downTime) then
				self.m_aDownWnd[self.m_iAddPos]:setYPosition(CEGUI.UDim(0, self.m_pUnlockEndPos.y - self.m_aDownWnd[self.m_iAddPos]:getParent():GetScreenPos().y))
				self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fDownPanelLeft - (self.m_fAddElapseTime / (totalAddTime - downTime)) * self.m_pSwitchFoldBtn:getPixelSize().width))
				for i = self.m_iAddPos, self.m_iDownNum - 1 do
					self.m_aDownWnd[i]:setXPosition(CEGUI.UDim(0, (i - 1) * (self.m_pSwitchFoldBtn:getPixelSize().width + 1) + (self.m_fAddElapseTime / (totalAddTime - downTime)) * self.m_pSwitchFoldBtn:getPixelSize().width))
				end
			elseif self.m_fAddElapseTime > (totalAddTime - downTime) and self.m_fAddElapseTime < totalAddTime then
				self.m_aDownWnd[self.m_iAddPos]:setYPosition(CEGUI.UDim(0, -self.m_pSwitchFoldBtn:getPixelSize().height + ((self.m_fAddElapseTime - totalAddTime + downTime) / downTime) * self.m_pSwitchFoldBtn:getPixelSize().height))
			end	
		end
	elseif self.m_AddState == State_RightAdding then
		if self.m_fUnlockFlyTime < unlockFlyTime then
			self.m_aRightWnd[self.m_iAddPos]:setXPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.x + (self.m_pUnlockEndPos.x - self.m_pUnlockStartPos.x) * (self.m_fUnlockFlyTime / unlockFlyTime) - self.m_aRightWnd[self.m_iAddPos]:getParent():GetScreenPos().x))
			self.m_aRightWnd[self.m_iAddPos]:setYPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.y + (self.m_pUnlockEndPos.y - self.m_pUnlockStartPos.y) * (self.m_fUnlockFlyTime / unlockFlyTime) * (self.m_fUnlockFlyTime / unlockFlyTime) - self.m_aRightWnd[self.m_iAddPos]:getParent():GetScreenPos().y))
		else
			if self.m_fAddElapseTime >= totalAddTime then
				self:ShowBtnFinish()
				self.m_AddState = State_NULL
				self.m_pAddWnd = nil
                if not self.m_iGuideId then return end
				local record = knight.gsp.task.GetCArrowEffectTableInstance():getRecorder(self.m_iGuideId)
				local winMgr = CEGUI.WindowManager:getSingleton()
				local pWnd = winMgr:getWindow(record.button)
				if pWnd then
					local pEffect = GetGameUIManager:AddUIEffect(pWnd, MHSD_UTILS.get_effectpath(10362))
					if pEffect then
						local notify = CGameUImanager:createNotify(self.ChangeEffect)
						pEffect:AddNotify(notify)
					end
				end
			elseif self.m_fAddElapseTime < (totalAddTime - downTime) then
				self.m_aRightWnd[self.m_iAddPos]:setXPosition(CEGUI.UDim(0, self.m_pUnlockEndPos.y - self.m_aRightWnd[self.m_iAddPos]:getParent():GetScreenPos().x))
				self.m_pRightPanel:setYPosition(CEGUI.UDim(0, self.m_fRightPanelTop - (self.m_fAddElapseTime / (totalAddTime - downTime)) * self.m_pSwitchFoldBtn:getPixelSize().height))
				for i = self.m_iAddPos, self.m_iRightNum - 1 do
					self.m_aRightWnd[i]:setYPosition(CEGUI.UDim(0, (i - 1) * (self.m_pSwitchFoldBtn:getPixelSize().height + 1) + (self.m_fAddElapseTime / (totalAddTime - downTime)) * self.m_pSwitchFoldBtn:getPixelSize().height))
				end
			elseif self.m_fAddElapseTime > (totalAddTime - downTime) and self.m_fAddElapseTime < totalAddTime then
				self.m_aRightWnd[self.m_iAddPos]:setXPosition(CEGUI.UDim(0, -self.m_pSwitchFoldBtn:getPixelSize().width + ((self.m_fAddElapseTime - totalAddTime + downTime) / downTime) * self.m_pSwitchFoldBtn:getPixelSize().width))
			end	
		end
	end
end

--解锁添加一个按钮, flag :0加在下面，1加在右边,pos从0开始
function MainControl:AddBtn(wnd, pos, flag)
	LogInfo("maincontrol addbtn")
	if self:IsBtnAlreadyExist(wnd, flag) then
		return
	end

	if flag == 0 then
		self.m_AddState = State_DownAdding
		self.m_fAddElapseTime = 0
		self.m_fUnlockFlyTime = 0
		wnd:setXPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.x - wnd:getParent():GetScreenPos().x))
		wnd:setYPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.y - wnd:getParent():GetScreenPos().y))
		wnd:setVisible(true)
		
		self.m_pUnlockEndPos.y = - self.m_pSwitchFoldBtn:getPixelSize().height + wnd:getParent():GetScreenPos().y
		if pos < 0 or pos > self.m_iDownNum then
			self.m_aDownWnd[self.m_iDownNum] = wnd
			self.m_iAddPos = self.m_iDownNum
			self.m_pUnlockEndPos.x = (self.m_iAddPos - 1) * (self.m_pSwitchFoldBtn:getPixelSize().width + 1) + wnd:getParent():GetScreenPos().x
			self.m_iDownNum = self.m_iDownNum + 1
		else
			for i = self.m_iDownNum, pos + 1, -1 do
				self.m_aDownWnd[i] = self.m_aDownWnd[i - 1]
			end
			self.m_aDownWnd[pos] = wnd
			self.m_iAddPos = pos
			self.m_iDownNum = self.m_iDownNum + 1
			if self.m_iAddPos == 0 then
				self:ShowBtnFinish()
				self.m_fAddElapseTime = totalAddTime - downTime
				self.m_pUnlockEndPos.x = self.m_iAddPos * (self.m_pSwitchFoldBtn:getPixelSize().width + 1) + wnd:getParent():GetScreenPos().x
			else
				self.m_pUnlockEndPos.x = (self.m_iAddPos - 1) * (self.m_pSwitchFoldBtn:getPixelSize().width + 1) + wnd:getParent():GetScreenPos().x
			end
		end
	elseif flag == 1 then
		self.m_AddState = State_RightAdding
		self.m_fAddElapseTime = 0
		wnd:setXPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.x - wnd:getParent():GetScreenPos().x))
		wnd:setYPosition(CEGUI.UDim(0, self.m_pUnlockStartPos.y - wnd:getParent():GetScreenPos().y))
		wnd:setVisible(true)
		self.m_pUnlockEndPos.x = - self.m_pSwitchFoldBtn:getPixelSize().width + wnd:getParent():GetScreenPos().x
		if pos > 0 or pos > self.m_iRightNum then
			self.m_aRightWnd[self.m_iRightNum] = wnd
			self.m_iAddPos = self.m_iRightNum
			self.m_pUnlockEndPos.y = (self.m_iAddPos - 1) * (self.m_pSwitchFoldBtn:getPixelSize().height + 1) + wnd:getParent():GetScreenPos().y
			self.m_iRightNum = self.m_iRightNum + 1
		else
			for i = self.m_iRightNum, pos + 1, -1 do
				self.m_aRightWnd[i] = self.m_aRightWnd[i - 1]
			end
			self.m_aRightWnd[pos] = wnd
			self.m_iAddPos = pos
			self.m_iRightNum = self.m_iRightNum + 1
			if self.m_iAddPos == 0 then
				self:ShowBtnFinish()
				self.m_fAddElapseTime = totalAddTime - downTime
				self.m_pUnlockEndPos.y = self.m_iAddPos * (self.m_pSwitchFoldBtn:getPixelSize().height + 1) + wnd:getParent():GetScreenPos().y
			else
				self.m_pUnlockEndPos.y = (self.m_iAddPos - 1) * (self.m_pSwitchFoldBtn:getPixelSize().height + 1) + wnd:getParent():GetScreenPos().y	
			end
		end
	end
end

function MainControl:IsBtnAlreadyExist(wnd, flag)
	LogInfo("maincontrol isbtn already exist")
	if flag == 0 then
		for i = 0, self.m_iDownNum - 1 do
			if wnd == self.m_aDownWnd[i] then
				return true
			end
		end
	elseif flag == 1 then
		for i = 0, self.m_iRightNum - 1 do
			if wnd == self.m_aRightWnd[i] then
				return true
			end
		end
	end
	return false
end

function MainControl:GuideBtn(guideId)
	LogInfo("maincontrol guide btn")
	self.m_iGuideId = guideId
	self:ShowUnlockDlg()

	if self.m_FoldState ~= State_UnFolded then
		self:EndFoldButton()
		self:EndShowSpecialBtn()
		self:UnFoldButton()
		if CChatOutBoxOperatelDlg:GetSingleton() then
			CChatOutBoxOperatelDlg:GetSingleton():HideChatContent()
		end
	end
	self.m_AddState = State_StartUnLock
end

function MainControl:GetButtonPos(wnd)
	if wnd == self.m_pSkillBtn or wnd == self.m_pTaskBtn or wnd == self.m_pFriendBtn or wnd == self.m_pXiakeBtn or wnd == self.m_pSystemBtn or wnd == self.m_pTeamBtn or wnd == self.m_pJewelryBtn then
		return 0
	elseif wnd == self.m_pPackBtn or wnd == self.m_pProductBtn then
		return 1
	end
	return -1
end

function MainControl:GetInsertPos(wnd)
	LogInfo("maincontrol getinsert pos")
	local pos = 0
	if self:GetButtonPos(wnd) == 1 then
		for i = 0, eRightPosMax - 1 do
			if self.m_aRightWndSt[i].pWnd == wnd then
				break
			end
			if self.m_aRightWndSt[i].bUnlocked then
				pos = pos + 1
			end
		end
		return pos
	elseif self:GetButtonPos(wnd) == 0 then
		for i = 0, eDownPosMax - 1 do
			if self.m_aDownWndSt[i].pWnd == wnd then
				break
			end
			if self.m_aDownWndSt[i].bUnlocked then
				pos = pos + 1
			end
		end
		return pos
	end
	return 0
end

function MainControl:EndShowSpecialBtn()
	self.m_pDownPanel:SetAllChildrenVis(false)
	self.m_pRightPanel:SetAllChildrenVis(false)

	self.m_pDownPanel:setXPosition(CEGUI.UDim(0, self.m_fSwitchBtnLeft))
	self.m_pRightPanel:setYPosition(CEGUI.UDim(0, self.m_fSwitchBtnTop))

	self.m_pProductBtn:setXPosition(CEGUI.UDim(0, 0))
	self.m_pProductBtn:setYPosition(CEGUI.UDim(0, -(self.m_pSwitchFoldBtn:getPixelSize().height + 1) * 2))
	self.m_pProductBtn:setVisible(self:IsBtnAlreadyExist(self.m_pProductBtn, 1))

	self.m_pPackBtn:setXPosition(CEGUI.UDim(0, 0))
	self.m_pPackBtn:setYPosition(CEGUI.UDim(0, -(self.m_pSwitchFoldBtn:getPixelSize().height + 1)))
	self.m_pPackBtn:setVisible(self:IsBtnAlreadyExist(self.m_pPackBtn, 1))

	self.m_pDownPanel:setVisible(true)
	self.m_pRightPanel:setVisible(true)

	self.m_ShowSpeBtnState = State_Show
	self.m_fShowSpecialBtnTime = 0
end

function MainControl:EndHideSpecialBtn()
	self.m_pProductBtn:setVisible(false)
	self.m_pPackBtn:setVisible(false)
	self.m_ShowSpeBtnState = State_Hide
	self.m_fShowSpecialBtnTime = 0

	self:InitBtnShowStat()
	self.m_FoldState = State_UnFolding
	self.m_fFoldElapseTime = 0
end

function MainControl:UpdateSpeBtnShow(elapse)
	LogInfo("maincontrol updatespecbtn show")
	self.m_fShowSpecialBtnTime = self.m_fShowSpecialBtnTime + elapse
	print(self.m_fShowSpecialBtnTime)
	if self.m_ShowSpeBtnState == State_Showing then
		if self.m_fShowSpecialBtnTime > showSpeTime then
			self:EndShowSpecialBtn()
		else
			self.m_pPackBtn:setXPosition(CEGUI.UDim(0, (1 - (self.m_fShowSpecialBtnTime / showSpeTime)) * self.m_pSwitchFoldBtn:getPixelSize().width))
			self.m_pProductBtn:setXPosition(CEGUI.UDim(0, (1 - (self.m_fShowSpecialBtnTime / showSpeTime)) * self.m_pSwitchFoldBtn:getPixelSize().width))
		end
	elseif self.m_ShowSpeBtnState == State_Hiding then
		if self.m_fShowSpecialBtnTime > showSpeTime then
			self:EndHideSpecialBtn()
		else
			self.m_pPackBtn:setXPosition(CEGUI.UDim(0, (self.m_fShowSpecialBtnTime / showSpeTime) * self.m_pSwitchFoldBtn:getPixelSize().width))
			self.m_pProductBtn:setXPosition(CEGUI.UDim(0, (self.m_fShowSpecialBtnTime / showSpeTime) * self.m_pSwitchFoldBtn:getPixelSize().width))
		end
	end
end

function MainControl:ShowBtnByGuide()
	if self.m_iGuideId then
		return
	end	
	self:InitBtnShowStat()
	if self.m_FoldState == State_Folded or self.m_FoldState == State_Folding then
		self:EndShowSpecialBtn()
	else
		self:EndUnFoldButton()
	end
end

--function MainControl:HandleAroundBtnClick(args)
--	AroundDialog.getInstanceAndShow()
--	self.m_fAutoHideTime = 0
--	return true
--end

function MainControl:IsInMainControl(pWnd)
	if pWnd == self.m_pSkillBtn or pWnd == self.m_pFriendBtn or pWnd == self.m_pXiakeBtn or pWnd == self.m_pProductBtn or pWnd == self.m_pTeamBtn or pWnd == self.m_pSystemBtn or pWnd == self.m_pPackBtn or pWnd == self.m_pTaskBtn or pWnd == self.m_pJewelryBtn then
--or pWnd == self.m_pAroundBtn 
		return true
	end
	return false
end

function MainControl:ShowUnlockDlg()
    ClearButtonDlg.getInstanceAndShow():setGuideID(self.m_iGuideId)
end

function MainControl:StartUnlock(x, y)
    if not self.m_iGuideId then return end
    local record=knight.gsp.task.GetCArrowEffectTableInstance():getRecorder(self.m_iGuideId)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local pWnd =winMgr:getWindow(record.button)
    self.m_pUnlockStartPos.x = x
    self.m_pUnlockStartPos.y = y
    if self.m_FoldState ~= State_UnFolded then
        self.m_pAddWnd = pWnd
        return
	end
    self:AddBtn(pWnd, self:GetInsertPos(pWnd), self:GetButtonPos(pWnd));
end

function MainControl.ChangeEffect()
	if not _instance then
		return
	end
    if not _instance.m_iGuideId then return end
	local record = knight.gsp.task.GetCArrowEffectTableInstance():getRecorder(_instance.m_iGuideId)
	if _instance.m_iGuideId == 30025 then
		GetNetConnection():send(knight.gsp.xiake.COpenXiakeJiuguan())
	end
	if record.cleareffect == 1 then
    	local winMgr = CEGUI.WindowManager:getSingleton()
		local pWnd = winMgr:getWindow(record.button)
		GetGameUIManager():RemoveUIEffect(pWnd)
		GetGameUIManager():AddUIEffect(pWnd, MHSD_UTILS.get_effectpath(10305))
		pWnd:SetGuideState(true)
		pWnd:removeEvent("GuideEnd")
		pWnd:subscribeEvent("GuideEnd", MainControl.HandleUnLockGuideEnd, _instance)
	end

	if record.step ~= 0 then
		GetNewRoleGuideManager():StartGuide(record.step)
	end
	_instance.m_iGuideId = nil
end

function MainControl:HandleUnLockGuideEnd(args)
	LogInfo("maincontrol handle unlock guide end")
	local wndArgs = CEGUI.toWindowEventArgs(args)
	if wndArgs.window then
		GetGameUIManager():RemoveUIEffect(wndArgs.window)
	end
	return true
end

--引导需要显示所有按钮
function MainControl:ShowAllBtns(guideId)
	if self.m_FoldState ~= State_UnFolded and self.m_FoldState ~= State_UnFolding then
		self:EndFoldButton()
		self:EndShowSpecialBtn()
		self:UnFoldButton()
		if CChatOutBoxOperatelDlg:GetSingleton() then
			CChatOutBoxOperatelDlg:GetSingleton():HideChatContent()
		end
	end
	self.m_iAfterShowGuideId = guideId
end

function MainControl:IsBtnShown(pWnd)
	return self:IsBtnAlreadyExist(pWnd, self:GetButtonPos(pWnd))
end

function MainControl:refreshTipInfo()
    print("____MainControl:refreshTipInfo")
    
    local num = 0

	for i = eMaincontrolTipStart, eMaincontrolTipMax - 1 do
		if self.m_mTipWnd[i] then
			if self.m_mTipNum[i] > 0 then
				self.m_mTipWnd[i]:setVisible(true)
				num = num + 1
			else
				self.m_mTipWnd[i]:setVisible(false)
			end
		end
	end	
	if num > 0 then
		self.m_pSwitchTipWnd:setVisible(true)
	else
		self.m_pSwitchTipWnd:setVisible(false)
	end
end

function MainControl.setTeamTip(num)
	if _instance then
		_instance.m_mTipNum[eMaincontrolTeamTip] = num
		_instance:refreshTipInfo();
	end
end

function MainControl:HandleJewelryBtnClicked(args)
	LogInfo("MainControl HandleJewelryBtnClicked")
	require "ui.jewelry.ringmake":GetSingletonDialogAndShowIt()	

end

return MainControl
