require "ui.dialog"

PetOperateDlg = {}
setmetatable(PetOperateDlg, Dialog)
PetOperateDlg.__index = PetOperateDlg

------------------------public:----------------------------
----------------singleton //////////////////////////-------
local _instance 
function PetOperateDlg.getInstance()
	LogInfo("enter get PetOperateDlg instance")

	if not _instance then
		_instance = PetOperateDlg.new()
		_instance:OnCreate()
	end

	return _instance
end

function PetOperateDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function PetOperateDlg.GetSingletonDialogAndShowIt()
	
	if not _instance then
        _instance = PetOperateDlg.new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function PetOperateDlg.getInstanceNotCreate()
    return _instance
end

------------------------//////////////////////////----------------------

function PetOperateDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, PetOperateDlg)
	self.m_bEscClose = false;
	self.m_eDialogType = {};
	return self
end

function PetOperateDlg.GetLayoutFileName()
	return "PetOperateDlg.layout"
end

function PetOperateDlg:OnCreate()
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	
	self:GetWindow():setMousePassThroughEnabled(true)
	self:GetWindow():SetHandleDragMove(true)
	
	self.m_pSkillBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill"))
	self.m_pPackBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill1"))
	self.m_pDefenceBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill2"))
	self.m_pProtectdBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill3"))
	self.m_pEscapeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill7"))    
	self.m_pCancelBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/cancel"))
	self.m_pAttackBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetOperateDlg/back/skill5"))
	
	self.m_pSkillBtn:subscribeEvent("Clicked", PetOperateDlg.HandleSkillBtnClicked, self)
	self.m_pPackBtn:subscribeEvent("Clicked", PetOperateDlg.HandlePackBtnClicked, self)
	self.m_pDefenceBtn:subscribeEvent("Clicked", PetOperateDlg.HandleDefenceBtnClicked, self)
	self.m_pProtectdBtn:subscribeEvent("Clicked", PetOperateDlg.HandleProtectBtnClicked, self)
	self.m_pEscapeBtn:subscribeEvent("Clicked", PetOperateDlg.HandleEscapeBtnClicked, self)
	self.m_pCancelBtn:subscribeEvent("Clicked", PetOperateDlg.HandleCancelBtnClicked, self)
	self.m_pAttackBtn:subscribeEvent("Clicked", PetOperateDlg.HandleAttackBtnClicked, self)
	
	if GetDataManager():GetMainCharacterLevel() < 20 then
		self:GetWindow():subscribeEvent("Hidden", PetOperateDlg.HandleHide, self)
	end
	
	self:ShowCancel(false)
	self.m_OperateType = 0  --eNone
	self.m_pPackBtn:setEnabled(false)
	self.m_pProtectdBtn:setEnabled(false)

end

function PetOperateDlg:ShowCancel(bShow)
	self.m_pSkillBtn:setVisible(not bShow)
	self.m_pPackBtn:setVisible(not bShow)
	self.m_pDefenceBtn:setVisible(not bShow)
	self.m_pProtectdBtn:setVisible(not bShow)
	self.m_pEscapeBtn:setVisible(not bShow)
	self.m_pAttackBtn:setVisible(not bShow)
	self.m_pCancelBtn:setVisible(bShow)
end

function PetOperateDlg:HandleAttackBtnClicked(args)
	self.m_OperateType = 6  --eAttack
	GetGameOperateState():ChangeGameCursorType(eCursorBattleAttack);
	self:ShowCancel(true)
	return true
end

function PetOperateDlg:HandleCancelBtnClicked(args)	
	if self.m_OperateType == 1 then  --eSkill
		BattleSkillPanel:ToggleOpenHide()
	elseif self.m_OperateType == 2 then  --eItem
		if CBattleBagDialog:GetSingleton() then
			if CBattleBagDialog:GetSingleton():IsVisible() then
				CBattleBagDialog:GetSingleton():SetVisible(false)
			end
		end
	end
    self:ShowCancel(false)
    return true
end

function PetOperateDlg:HandleSkillBtnClicked(args)
	CBattleSkillPanel:ToggleOpenHide()
	return true
end

function PetOperateDlg:HandlePackBtnClicked(args)
--	未使用代码
--	self.m_OperateType = 2  --eItem
--
--	if CBattleBagDialog:GetSingleton() == nil then
--		CBattleBagDialog:GetSingletonDialog():OpenDialogByPet()
--		self:ShowCancel(true)
--	else
--		if CBattleBagDialog:GetSingleton():IsVisible() then
--			CBattleBagDialog:GetSingleton():SetVisible(false)
--			self:ShowCancel(false)
--		else 
--			CBattleBagDialog:GetSingleton():SetVisible(true)
--			CBattleBagDialog:GetSingleton():UpdateItemCellState(false)
--			self:ShowCancel(true)
--		end
--	end	

	return true
end

function PetOperateDlg:HandleDefenceBtnClicked(args)
	GetBattleManager():SendBattleCommand(0, eDefenceOperate)
	return true
end

function PetOperateDlg:HandleProtectBtnClicked(args)
--	未使用代码	
--	self.m_OperateType = 4  --eProtect
    
--	GetGameOperateState():ChangeGameCursorType(eCursorForbid)
--	GetGameOperateState():SetOperateState(eCursorStateProtect)
	
--	self.ShowCancel(true)
	return true
end

function PetOperateDlg:HandleEscapeBtnClicked(args)
	self.m_OperateType = 5  --eEscape

	GetBattleManager():SendBattleCommand(0, eRunawayOperate)
	return true
end

function PetOperateDlg:HandleHide(args)
	return true
end

function PetOperateDlg.CSetVisible(b)
	if _instance then
		_instance:SetVisible(b)
	end
end

return PetOperateDlg 