require "ui.dialog"
FactionPosition = {}
setmetatable(FactionPosition, Dialog)
FactionPosition.__index = FactionPosition

local function createdlg(memberid)
	local self = {memberid = memberid}
	setmetatable(self, FactionPosition)
	function self.GetLayoutFileName()
		return "familyposition.layout"
	end
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()

	self.m_pMasterBtn = CEGUI.toGroupButton(winMgr:getWindow("familyposition/bangzhu"))
	self.m_pViceMasterBtn = CEGUI.toGroupButton(winMgr:getWindow("familyposition/bangzhu1"))
	self.m_pLeftElderBtn = CEGUI.toGroupButton(winMgr:getWindow("familyposition/bangzhu11"))
	self.m_pEssenceBtn = CEGUI.toGroupButton(winMgr:getWindow("familyposition/bangzhu111"))
	self.m_pRightElderBtn = CEGUI.toGroupButton(winMgr:getWindow("familyposition/bangzhu2"))
	self.m_pNormalMemberBtn = CEGUI.toGroupButton(winMgr:getWindow("familyposition/bangzhu21"))	
	self.m_pOkBtn = CEGUI.toPushButton(winMgr:getWindow("familyposition/BreakAway1"))
	self.m_pPosBtns = {	}
	self.m_pPosBtns[self.m_pMasterBtn] = 1--knight.gsp.faction.FactionPositionType2.FactionMaster
	self.m_pPosBtns[self.m_pViceMasterBtn] = 2--knight.gsp.faction.FactionPositionType2.FactionViceMaster
	self.m_pPosBtns[self.m_pLeftElderBtn] = 3--knight.gsp.faction.FactionPositionType2.FactionElder
	self.m_pPosBtns[self.m_pEssenceBtn] = 4--knight.gsp.faction.FactionPositionType2.FactionElite
	self.m_pPosBtns[self.m_pRightElderBtn] = 3--knight.gsp.faction.FactionPositionType2.FactionElder
	self.m_pPosBtns[self.m_pNormalMemberBtn] = 5--knight.gsp.faction.FactionPositionType2.FactionCommon
--	self.m_pMasterBtn:subscribeEvent("Clicked", self.HandleMasterBtnClicked, self)
--	self.m_pViceMasterBtn:subscribeEvent("Clicked", self.HandleViceMasterBtnClicked, self)
--	self.m_pLeftElderBtn:subscribeEvent("Clicked", self.HandleLeftElderBtnClicked, self)
--	self.m_pEssenceBtn:subscribeEvent("Clicked", self.HandleEssenceBtnClicked, self)
--	self.m_pRightElderBtn:subscribeEvent("Clicked", self.HandleRightElderBtnClicked, self)
--	self.m_pNormalMemberBtn:subscribeEvent("Clicked", self.HandleNormalMemberBtnClicked, self)
	
	self.m_pOkBtn:subscribeEvent("Clicked", self.HandleOkBtnClicked, self)
	return self
end

local function SetWndStatus(wnd, clickedwnd)
--	wnd:setSelected(wnd == clickedwnd)
end

function FactionPosition:OnPosBtnClicked(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	SetWndStatus(self.m_pMasterBtn, mouseArgs.window)
	SetWndStatus(self.m_pViceMasterBtn, mouseArgs.window)
	SetWndStatus(self.m_pLeftElderBtn, mouseArgs.window)
	SetWndStatus(self.m_pEssenceBtn, mouseArgs.window)
	SetWndStatus(self.m_pRightElderBtn, mouseArgs.window)
	SetWndStatus(self.m_pNormalMemberBtn, mouseArgs.window)
end

function FactionPosition:HandleMasterBtnClicked(e)
	self:OnPosBtnClicked(e)
end

function FactionPosition:HandleViceMasterBtnClicked(e)
	self:OnPosBtnClicked(e)
end

function FactionPosition:HandleLeftElderBtnClicked(e)
	self:OnPosBtnClicked(e)
end

function FactionPosition:HandleEssenceBtnClicked(e)
	self:OnPosBtnClicked(e)
end

function FactionPosition:HandleRightElderBtnClicked(e)
	self:OnPosBtnClicked(e)
end

function FactionPosition:HandleNormalMemberBtnClicked(e)
	self:OnPosBtnClicked(e)
end

function FactionPosition:HandleOkBtnClicked(e)
	for k, v in pairs(self.m_pPosBtns) do
		if k:isSelected() then
			local p = require "protocoldef.knight.gsp.faction.cchangeposition2":new()
			p.memberroleid = self.memberid
			p.position = v
			require "manager.luaprotocolmanager":send(p)
			self.DestroyDialog()
			return true
		end
	end
	return true
end

local _instance
function FactionPosition.GetSingletonDialogAndShowIt(memberid)
	if not _instance then
		_instance = createdlg(memberid)
	end
	if not _instance:IsVisible() then
		_instance:SetVisible(true)
	end
	return _instance
end

function FactionPosition.DestroyDialog()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end
end

return FactionPosition