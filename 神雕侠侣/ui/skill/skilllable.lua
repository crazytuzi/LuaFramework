require "utils.mhsdutils"
require "ui.skill.qijingbamaidlg"
require "ui.skill.wulinmijidlg"
require "ui.dialog"
local NuQiSkillXiuLianDlg = require "ui.skill.nuqiskillxiuliandlg"

SkillLable = {}

setmetatable(SkillLable, Dialog)
SkillLable.__index = SkillLable

local _instance

function SkillLable.getInstance()
	if not _instance then
		_instance = SkillLable:new()
		_instance:OnCreate()
	end
	return _instance
end

function SkillLable.getInstanceNotCreate()
	return _instance
end

function SkillLable.GetLayoutFileName()
	return "Lable.layout"
end

function SkillLable:OnCreate()
	Dialog.OnCreate(self,nil, "skill")

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = winMgr:getWindow( "skillLable/button")
	self.m_pButton2 = winMgr:getWindow( "skillLable/button1")
	self.m_pButton3 = winMgr:getWindow( "skillLable/button2")
	self.m_pButton4 = winMgr:getWindow( "skillLable/button3")
	self.m_pButton5 = winMgr:getWindow( "skillLable/button4")

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(3014))

	if GetDataManager():GetMainCharacterLevel() >= 80 then
		self.m_pButton2:setText(MHSD_UTILS.get_resstring(3039))
	else
		self.m_pButton2:setVisible(false)
	end

	if GetDataManager():GetMainCharacterLevel() >= 95 then
		self.m_pButton3:setText(MHSD_UTILS.get_resstring(3015))
	else
		self.m_pButton3:setVisible(false)
	end

	if GetDataManager():GetMainCharacterLevel() >= 70 then
		self.m_pButton4:setText(MHSD_UTILS.get_resstring(3137))
	else
		self.m_pButton4:setVisible(false)
	end

	self.m_pButton5:setVisible(false)

	self.m_pButton1:subscribeEvent("Clicked", SkillLable.HandleLabel1BtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", SkillLable.HandleLabel2BtnClicked, self)
	self.m_pButton3:subscribeEvent("Clicked", SkillLable.HandleLabel3BtnClicked, self)
	self.m_pButton4:subscribeEvent("Clicked", SkillLable.HandleLabel4BtnClicked, self)
end


function SkillLable:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, SkillLable)
	return self
end

function SkillLable.DestroyDialog()	
	LogInfo("SkillLable destroy dialog")	
	if _instance then
		--close all 
		if CAcupointLevelupDlg:GetSingleton() then
			_instance:RemoveEvent(CAcupointLevelupDlg:GetSingleton():GetWindow())
			CAcupointLevelupDlg:GetSingleton():CloseDialogForLable()
		end
		if WulinmijiDlg.getInstanceNotCreate() then
			_instance:RemoveEvent(WulinmijiDlg.getInstanceNotCreate():GetWindow())
			WulinmijiDlg.CloseDialog()
		end
		if QijingbamaiDlg.getInstanceNotCreate() then
			_instance:RemoveEvent(QijingbamaiDlg.getInstanceNotCreate():GetWindow())
			QijingbamaiDlg.CloseDialog()
		end
		if NuQiSkillXiuLianDlg.getInstanceNotCreate() then
			_instance:RemoveEvent(NuQiSkillXiuLianDlg.getInstanceNotCreate():GetWindow())
			NuQiSkillXiuLianDlg.CloseDialog()
		end

		_instance:OnClose()
		_instance = nil
	end	
end

function SkillLable.Show(index)
	index = index or 1
	SkillLable.getInstance()
	_instance:ShowOnly(index)	
end

function SkillLable:ShowOnly(index)
	--hide all
	self.m_index = index	
	if CAcupointLevelupDlg:GetSingleton() then
		CAcupointLevelupDlg:GetSingleton():GetWindow():setVisible(false)
	end

	if WulinmijiDlg.getInstanceNotCreate() then
		WulinmijiDlg:getInstanceNotCreate():GetWindow():setVisible(false)
	end

	if index == 1 then
		if CAcupointLevelupDlg:GetSingleton() then
			CAcupointLevelupDlg:GetSingleton():GetWindow():setVisible(true)
		else
			CAcupointLevelupDlg:GetSingletonDialogAndShowIt()
			local pWnd = CAcupointLevelupDlg:GetSingleton():GetWindow()
			self:SubscribeEvent(pWnd)
		end	
	elseif index == 2 then
		if WulinmijiDlg.getInstanceNotCreate() then
			WulinmijiDlg.getInstanceAndShow()
		else
			local dlg = WulinmijiDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	elseif index == 3 then
		if QijingbamaiDlg.getInstanceNotCreate() then
			QijingbamaiDlg.getInstanceAndShow()
		else
			local dlg = QijingbamaiDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	elseif index == 4 then
		if not NuQiSkillXiuLianDlg.getInstanceNotCreate() then
			local dlg = NuQiSkillXiuLianDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
		NuQiSkillXiuLianDlg.getInstanceAndShow():ShowSkill()
		NuQiSkillXiuLianDlg.getInstanceAndShow():RefreshPoints()
	end
end

function SkillLable:HandleLabel1BtnClicked(e)
	LogInfo("label 1 clicked")
	SkillLable.getInstance():ShowOnly(1)	
	return true
end

function SkillLable:HandleLabel2BtnClicked(e)
	LogInfo("label 2 clicked")
	SkillLable.getInstance():ShowOnly(2)	
	return true
end

function SkillLable:HandleLabel3BtnClicked(e)
	LogInfo("label 3 clicked")
	SkillLable.getInstance():ShowOnly(3)	
	return true
end

function SkillLable:HandleLabel4BtnClicked(e)
	LogInfo("label 4 clicked")
	SkillLable.getInstance():ShowOnly(4)
	return true
end

function SkillLable:SubscribeEvent(pWnd)
	LogInfo("SkillLable subscribe event")
	pWnd:subscribeEvent("AlphaChanged", SkillLable.HandleDlgStateChange, self)
	pWnd:subscribeEvent("Shown", SkillLable.HandleDlgStateChange, self)
	pWnd:subscribeEvent("Hidden", SkillLable.HandleDlgStateChange, self)
	pWnd:subscribeEvent("InheritAlphaChanged", SkillLable.HandleDlgStateChange, self)
	LogInfo("SkillLable subscribe event end")
end

function SkillLable:RemoveEvent(pWnd)
	LogInfo("SkillLable remove event")
	pWnd:removeEvent("AlphaChanged")
	pWnd:removeEvent("Shown")
	pWnd:removeEvent("Hidden")
	pWnd:removeEvent("InheritAlphaChanged")
end

function SkillLable:HandleDlgStateChange(args)
	LogInfo("SkillLable handle dlg state change")
	if CAcupointLevelupDlg:GetSingleton() then 
		local pWnd = CAcupointLevelupDlg:GetSingleton():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end

	if WulinmijiDlg.getInstanceNotCreate() then
		local pWnd = WulinmijiDlg.getInstanceNotCreate():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end

	if QijingbamaiDlg.getInstanceNotCreate() then
		local pWnd = QijingbamaiDlg.getInstanceNotCreate():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end

	if NuQiSkillXiuLianDlg.getInstanceNotCreate() then
		local pWnd = NuQiSkillXiuLianDlg.getInstanceNotCreate():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end

	self:GetWindow():setVisible(false)
	return true
end

return SkillLable
