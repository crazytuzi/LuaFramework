local Dialog = require "ui.dialog"
local NuQiSkillManager = require "ui.skill.nuqiskillmanager"
local NuQiSkillTipsDlg = require "ui.skill.nuqiskilltipsdlg"

NuQiSkillOperateDlg = {}
setmetatable(NuQiSkillOperateDlg, Dialog)
NuQiSkillOperateDlg.__index = NuQiSkillOperateDlg

NuQiSkillOperateDlg.OP_NONE = 0
NuQiSkillOperateDlg.OP_SELECTING = 1
NuQiSkillOperateDlg.OP_SELECTED = 2

------------------------public:----------------------------
----------------singleton //////////////////////////-------
local _instance 
function NuQiSkillOperateDlg.getInstance()
	if not _instance then
		_instance = NuQiSkillOperateDlg.new()
		_instance:OnCreate()
	end
	return _instance
end

function NuQiSkillOperateDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
		NuQiSkillTipsDlg.DestroyDialog()
	end
end

function NuQiSkillOperateDlg.GetSingletonDialogAndShowIt()
	if not _instance then
        _instance = NuQiSkillOperateDlg.new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function NuQiSkillOperateDlg.getInstanceNotCreate()
    return _instance
end

------------------------//////////////////////////----------------------

function NuQiSkillOperateDlg:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, NuQiSkillOperateDlg)
	self.m_opmode = NuQiSkillOperateDlg.OP_NONE
	return self
end

function NuQiSkillOperateDlg.GetLayoutFileName()
	return "skilllistnuqi.layout"
end

function NuQiSkillOperateDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	-- get windows
	self.m_wSkills = {}
	for i=1, 6 do
		self.m_wSkills[i] = CEGUI.toSkillBox(winMgr:getWindow("SkillListnuqi/back/skill" .. tostring(i)))
		self.m_wSkills[i]:setID(i)
	end
	self.m_wCancel = CEGUI.Window.toPushButton(winMgr:getWindow("SkillListnuqi/back/cancel"))

	-- sub events
	for i=1, 6 do
		self.m_wSkills[i]:subscribeEvent("SKillBoxClick", NuQiSkillOperateDlg.HandleSkillClicked, self)
		self.m_wSkills[i]:subscribeEvent("MouseButtonUp", NuQiSkillOperateDlg.HandleSkillButtonUp, self)
		self.m_wSkills[i]:subscribeEvent("MouseLeave", NuQiSkillOperateDlg.HandleSkillLeave, self)
	end
	self.m_wCancel:subscribeEvent("Clicked", NuQiSkillOperateDlg.HandleCancelBtn, self)
	self:ShowSkills()
end

function NuQiSkillOperateDlg:ShowSkills()
	self.m_opmode = NuQiSkillOperateDlg.OP_SELECTING
	if CCharacterOperateDlg:GetSingleton() then
		CCharacterOperateDlg:GetSingleton():SetOperateDlgVisible(false)
	end
	-- 最多六个
	self.m_Skills = NuQiSkillManager.GetInUseSkills()
	for i,v in ipairs(self.m_Skills) do
		if i<=6 then
			self.m_wSkills[i]:SetImage(GetIconManager():GetImageByID(v.iconid))
			self.m_wSkills[i]:SetAshy(v.level == 0 or v.passive == 1)
		end
	end
	for i=1, 6 do
		self.m_wSkills[i]:setVisible(true)
	end
end

-- 这个事件是鼠标按下去时触发  - -
function NuQiSkillOperateDlg:HandleSkillClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	if not self.m_Skills[id] then
		NuQiSkillTipsDlg.DestroyDialog()
		return true
	end

	NuQiSkillTipsDlg.getInstanceAndShow():Refresh(self.m_Skills[id].id)
	return true
end

function NuQiSkillOperateDlg:HandleSkillButtonUp(args)
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	if not self.m_Skills[id] then
		return true
	end

	self.m_opmode = NuQiSkillOperateDlg.OP_SELECTED
	-- 设置技能id  估计是技能总表中的id
	GetBattleManager():SetCurSelectedSkillID(self.m_Skills[id].id)
	local skillusetype = GetRoleSkillManager():GetSkillUseType(self.m_Skills[id].id)
	if skillusetype == 1 then
		GetBattleManager():SendBattleCommand(GetBattleManager():GetOperateMainBatterID(),eSkillOperate);
	else
		GetGameOperateState():ChangeGameCursorType(eCursorBattleSkill)
	end

	for i=1, 6 do
		self.m_wSkills[i]:setVisible(false)
	end

	local NuQiSkillTipsDlg = require "ui.skill.nuqiskilltipsdlg"
	NuQiSkillTipsDlg.DestroyDialog()
	return true
end

function NuQiSkillOperateDlg:HandleSkillLeave(args)
	local NuQiSkillTipsDlg = require "ui.skill.nuqiskilltipsdlg"
	NuQiSkillTipsDlg.DestroyDialog()
	return true
end

function NuQiSkillOperateDlg:HandleCancelBtn(args)
	if self.m_opmode == NuQiSkillOperateDlg.OP_SELECTING then
		if CCharacterOperateDlg:GetSingleton() then
			CCharacterOperateDlg:GetSingleton():SetOperateDlgVisible(true);
		end
		NuQiSkillOperateDlg.DestroyDialog()
	elseif self.m_opmode == NuQiSkillOperateDlg.OP_SELECTED then
		self:ShowSkills()
	end
end

return NuQiSkillOperateDlg
