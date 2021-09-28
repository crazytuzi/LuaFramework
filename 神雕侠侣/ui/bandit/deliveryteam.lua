require "ui.dialog"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.faction.cstartbiaoche"
require "protocoldef.knight.gsp.faction.cleavebiaoche"
require "utils.tableutil"

DeliveryTeam = {}
setmetatable(DeliveryTeam, Dialog)
DeliveryTeam.__index = DeliveryTeam

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------


function DeliveryTeam.CreateNewDlg(pParentDlg)
	LogInfo("enter DeliveryTeam.CreateNewDlg")
	local newDlg = DeliveryTeam:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end

----/////////////////////////////////////////------

function DeliveryTeam.GetLayoutFileName()
    return "bandititem.layout"
end

function DeliveryTeam:OnCreate(pParentDlg)
	LogInfo("DeliveryTeam oncreate begin")
    Dialog.OnCreate(self, pParentDlg)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pMember1Wnd = winMgr:getWindow("bandititem/back/biaoshi")
	self.m_pMember2Wnd = winMgr:getWindow("bandititem/back/biaoshi1")
	self.m_pLeaderName = winMgr:getWindow("bandititem/name2")
	self.m_pTypeName = winMgr:getWindow("bandititem/name1")
	self.m_pMemberNumber = winMgr:getWindow("bandititem/main/TXT1")
	self.m_pBtnGo = CEGUI.toPushButton(winMgr:getWindow("bandititem/main/go"))
	self.m_pLeaderBackBtn = CEGUI.toPushButton(winMgr:getWindow("bandititem/main/go1"))
	self.m_pMember1Name = winMgr:getWindow("bandititem/name31")
	self.m_pExit1Btn = CEGUI.toPushButton(winMgr:getWindow("bandititem/main/go111"))
	self.m_pRemind1Btn = CEGUI.toPushButton(winMgr:getWindow("bandititem/main/go11"))
	self.m_pMember1Level = winMgr:getWindow("bandititem/name321")
	self.m_pMember1School = winMgr:getWindow("bandititem/name322")	
	self.m_pKick1Btn = CEGUI.toPushButton(winMgr:getWindow("bandititem/main/go1112"))
	self.m_pMember2Name = winMgr:getWindow("bandititem/name311")
	self.m_pExit2Btn = CEGUI.toPushButton(winMgr:getWindow("bandititem/main/go1111"))
	self.m_pRemind2Btn = CEGUI.toPushButton(winMgr:getWindow("bandititem/main/go112"))
	self.m_pMember2Level = winMgr:getWindow("bandititem/name3211")
	self.m_pMember2School = winMgr:getWindow("bandititem/name3221")
	self.m_pKick2Btn = CEGUI.toPushButton(winMgr:getWindow("bandititem/main/go11121"))
	self.m_pStatusLeader = winMgr:getWindow("bandititem/name2/lixian1")
	self.m_pStatus1 = winMgr:getWindow("bandititem/name2/lixian11")
	self.m_pStatus2 = winMgr:getWindow("bandititem/name2/lixian111")
	self.m_pPic = winMgr:getWindow("bandititem/main/tubiao")	
	self.m_pBack1Btn = CEGUI.toPushButton(winMgr:getWindow("bandititem/main/go1131"))
	self.m_pBack2Btn = CEGUI.toPushButton(winMgr:getWindow("bandititem/main/go11211"))


	-- subscribe event
    self.m_pBtnGo:subscribeEvent("Clicked", DeliveryTeam.HandleGoBtnClicked, self) 
	self.m_pExit1Btn:subscribeEvent("Clicked", DeliveryTeam.HandleExitBtnClicked, self)
	self.m_pExit2Btn:subscribeEvent("Clicked", DeliveryTeam.HandleExitBtnClicked, self)
	self.m_pRemind1Btn:subscribeEvent("Clicked", DeliveryTeam.HandleRemindBtnClicked, self)
	self.m_pRemind2Btn:subscribeEvent("Clicked", DeliveryTeam.HandleRemindBtnClicked, self)
	self.m_pKick1Btn:subscribeEvent("Clicked", DeliveryTeam.HandleKickBtnClicked, self)
	self.m_pKick2Btn:subscribeEvent("Clicked", DeliveryTeam.HandleKickBtnClicked, self)
	self.m_pLeaderBackBtn:subscribeEvent("Clicked", DeliveryTeam.HandleBackBtnClicked, self)
	self.m_pBack1Btn:subscribeEvent("Clicked", DeliveryTeam.HandleBackBtnClicked, self)
	self.m_pBack2Btn:subscribeEvent("Clicked", DeliveryTeam.HandleBackBtnClicked, self)

	self.m_pLeaderBackBtn:setVisible(false)
	self.m_pBack1Btn:setVisible(false)
	self.m_pBack2Btn:setVisible(false)
	self.m_pStatusLeader:setVisible(false)
	self.m_pStatus1:setVisible(false)
	self.m_pStatus2:setVisible(false)
	
	self.m_pMember1Wnd:setVisible(false)
	self.m_pMember2Wnd:setVisible(false)

	LogInfo("DeliveryTeam oncreate end")
end

------------------- private: -----------------------------------


function DeliveryTeam:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, DeliveryTeam)
    return self
end

function DeliveryTeam:HandleGoBtnClicked(args)
	LogInfo("DeliveryTeam handle go button clicked")
    local start = CStartBiaoChe.Create()
	start.flag = 0
    LuaProtocolManager.getInstance():send(start)
end

function DeliveryTeam:HandleExitBtnClicked(args)
	LogInfo("DeliveryTeam handle exit button clicked")
    local leave = CLeaveBiaoChe.Create()
	leave.roleid = 0
    LuaProtocolManager.getInstance():send(leave)
end

function DeliveryTeam:HandleRemindBtnClicked(args)
	LogInfo("DeliveryTeam handle remind button clicked")
    local start = CStartBiaoChe.Create()
	start.flag = 1
    LuaProtocolManager.getInstance():send(start)
end

function DeliveryTeam:HandleKickBtnClicked(args)
	LogInfo("DeliveryTeam handle kick button clicked")
    local leave = CLeaveBiaoChe.Create()
	local e = CEGUI.toWindowEventArgs(args)
	leave.roleid = e.window:getID()
    LuaProtocolManager.getInstance():send(leave)
	
end

function DeliveryTeam:HandleBackBtnClicked(args)
	LogInfo("DeliveryTeam handle back button clicked")
	GetTeamManager():RequestAbsentReturnTeam(false)
end

function DeliveryTeam:freshBiaocheTeam(leader, biaochetype, biaoches)
	LogInfo("DeliveryTeam freshBiaocheTeam")
	self.m_iLeaderID = leader
	self.m_iType = biaochetype
	self.m_lBiaoches = biaoches
	self.m_pMemberNumber:setText(tostring(TableUtil.tablelength(biaoches)) .. "/3")
	if biaochetype == 0 then
		self.m_pPic:setProperty("Image", "set:MainControl16 image:yibanbiaoche")
		self.m_pTypeName:setText(MHSD_UTILS.get_resstring(2908))
	elseif biaochetype == 1 then
		self.m_pPic:setProperty("Image", "set:MainControl16 image:zhenbaobiaoche")
		self.m_pTypeName:setText(MHSD_UTILS.get_resstring(2909))
	end

	self.m_pMember1Wnd:setVisible(false)
	self.m_pMember2Wnd:setVisible(false)

	local num = 1
	for i,v in pairs(biaoches) do 
		if v.memberid == leader then
			if GetMainCharacter():GetID() == leader then
				self.m_iMyPos = 0
				self.m_bMyselfLeader = true
			end 
			self.m_pLeaderName:setText(v.rolename)
			if Bandit.getInstanceNotCreate().m_stat == 2 then
				self.m_pLeaderBackBtn:setVisible(false)
				if self.m_bMyselfLeader then
					self.m_pBtnGo:setVisible(true)
				else
					self.m_pBtnGo:setVisible(false)
				end
			else
				self.m_pLeaderBackBtn:setVisible(false)
				self.m_pBtnGo:setVisible(false)
			end
			self.m_pStatusLeader:setVisible(false)
		elseif num == 1 then
			num = 2
			self.m_pMember1Wnd:setVisible(true)
			self.m_pMember1Name:setText(v.rolename)
			self.m_pMember1Level:setText(tostring(v.level))
			self.m_pMember1School:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(v.school).name)
			self.m_pKick1Btn:setID(v.memberid)
			if v.memberid == GetMainCharacter():GetID() then
				self.m_iMyPos = 1
			end
			if Bandit.getInstanceNotCreate().m_stat == 2 then
				if v.memberid == GetMainCharacter():GetID() then
					self.m_pExit1Btn:setVisible(true)
					self.m_pRemind1Btn:setVisible(true)
					self.m_pKick1Btn:setVisible(false)
					self.m_pBack1Btn:setVisible(false)	
				elseif GetMainCharacter():GetID() == leader then
					self.m_pExit1Btn:setVisible(false)
					self.m_pRemind1Btn:setVisible(false)
					self.m_pKick1Btn:setVisible(true)
					self.m_pBack1Btn:setVisible(false)
				else
					self.m_pExit1Btn:setVisible(false)
					self.m_pRemind1Btn:setVisible(false)
					self.m_pKick1Btn:setVisible(false)
					self.m_pBack1Btn:setVisible(false)
				end
			else
				self.m_pExit1Btn:setVisible(false)
				self.m_pRemind1Btn:setVisible(false)
				self.m_pKick1Btn:setVisible(false)
				self.m_pBack1Btn:setVisible(false)
			end
			self.m_pStatus1:setVisible(false)
		elseif num == 2 then
			num = 3 
			self.m_pMember2Wnd:setVisible(true)
			self.m_pMember2Name:setText(v.rolename)
			self.m_pMember2Level:setText(tostring(v.level))
			self.m_pMember2School:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(v.school).name)
			self.m_pKick2Btn:setID(v.memberid)
			if v.memberid == GetMainCharacter():GetID() then
				self.m_iMyPos = 2
			end
			if Bandit.getInstanceNotCreate().m_stat == 2 then
				if v.memberid == GetMainCharacter():GetID() then
					self.m_pExit2Btn:setVisible(true)
					self.m_pRemind2Btn:setVisible(true)
					self.m_pKick2Btn:setVisible(false)
					self.m_pBack2Btn:setVisible(false)	
				elseif GetMainCharacter():GetID() == leader then
					self.m_pExit2Btn:setVisible(false)
					self.m_pRemind2Btn:setVisible(false)
					self.m_pKick2Btn:setVisible(true)
					self.m_pBack2Btn:setVisible(false)
				else
					self.m_pExit2Btn:setVisible(false)
					self.m_pRemind2Btn:setVisible(false)
					self.m_pKick2Btn:setVisible(false)
					self.m_pBack2Btn:setVisible(false)
				end
			else
				self.m_pExit2Btn:setVisible(false)
				self.m_pRemind2Btn:setVisible(false)
				self.m_pKick2Btn:setVisible(false)
				self.m_pBack2Btn:setVisible(false)
			end
			self.m_pStatus2:setVisible(false)
		end
	end
	self:freshMemberState()
end

function DeliveryTeam:freshMemberState()
	LogInfo("DeliveryTeam freshMemberState")
	self.m_pStatusLeader:setVisible(false)
	self.m_pStatus1:setVisible(false)
	self.m_pStatus2:setVisible(false)

	if GetTeamManager():IsOnTeam() and GetTeamManager():GetTeamMemberByID(self.m_iLeaderID) and GetTeamManager():GetTeamMemberByID(self.m_iLeaderID).eMemberState == 4 then
		self.m_pStatusLeader:setVisible(true)
	end 
	local num = TableUtil.tablelength(self.m_lBiaoches)
	if num >= 2 then
		if GetTeamManager():GetTeamMemberByID(self.m_pKick1Btn:getID()) and GetTeamManager():GetTeamMemberByID(self.m_pKick1Btn:getID()).eMemberState == 4 then
			self.m_pStatus1:setVisible(true)
		end 
		if num >= 3 then
			if GetTeamManager():GetTeamMemberByID(self.m_pKick2Btn:getID()) and GetTeamManager():GetTeamMemberByID(self.m_pKick2Btn:getID()).eMemberState == 4 then
				self.m_pStatus2:setVisible(true)
			end 
		end
	end
	
	self.m_pBack1Btn:setVisible(false)
	self.m_pBack2Btn:setVisible(false)
	self.m_pLeaderBackBtn:setVisible(false)
		
	if GetTeamManager():IsOnTeam() and GetTeamManager():GetTeamMemberByID(GetMainCharacter():GetID()) and GetTeamManager():GetTeamMemberByID(GetMainCharacter():GetID()).eMemberState == 2 then
		if self.m_iMyPos == 0 then
			self.m_pLeaderBackBtn:setVisible(true)
		elseif self.m_iMyPos == 1 then
			self.m_pBack1Btn:setVisible(true)
		elseif self.m_iMyPos == 2 then
			self.m_pBack2Btn:setVisible(true)
		end
	--elseif not GetTeamManager():IsOnTeam() then
	--	self.m_pLeaderBackBtn:setVisible(true)
	end


end

return DeliveryTeam
