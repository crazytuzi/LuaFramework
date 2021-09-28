require "utils.mhsdutils"
require "ui.pet.petpropertydlg"
require "ui.pet.petstardlg"
require "ui.pet.petchipdlg"
require "ui.pet.pettraindlg"
require "ui.dialog"

PetLabel = {}

setmetatable(PetLabel, Dialog)
PetLabel.__index = PetLabel

local _instance;

function PetLabel.getInstance()
	if not _instance then
		_instance = PetLabel:new()
		_instance:OnCreate()
	end
	return _instance
end

function PetLabel.getInstanceNotCreate()
	return _instance
end

function PetLabel.GetLayoutFileName()
	return "Lable.layout"
end

function PetLabel:OnCreate()
	Dialog.OnCreate(self,nil, enumPetLabel)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = winMgr:getWindow(tostring(enumPetLabel) .. "Lable/button");
	self.m_pButton2 = winMgr:getWindow(tostring(enumPetLabel) .. "Lable/button1");
	self.m_pButton3 = winMgr:getWindow(tostring(enumPetLabel) .. "Lable/button2");
	self.m_pButton4 = winMgr:getWindow(tostring(enumPetLabel) .. "Lable/button3");
	self.m_pButton5 = winMgr:getWindow(tostring(enumPetLabel) .. "Lable/button4");

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(2743))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(2744))
	self.m_pButton3:setText(MHSD_UTILS.get_resstring(2746))
	self.m_pButton4:setText(MHSD_UTILS.get_resstring(2747))
	self.m_pButton5:setVisible(false);

	self.m_pButton1:subscribeEvent("Clicked", PetLabel.HandleLabel1BtnClicked, self);
	self.m_pButton2:subscribeEvent("Clicked", PetLabel.HandleLabel2BtnClicked, self);
	self.m_pButton3:subscribeEvent("Clicked", PetLabel.HandleLabel3BtnClicked, self);
	self.m_pButton4:subscribeEvent("Clicked", PetLabel.HandleLabel4BtnClicked, self);
end


function PetLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, PetLabel)
	return self
end

function PetLabel.DestroyDialog()	
	LogInfo("petlabel destroy dialog")	
	if _instance then
		--close all 
		if PetPropertyDlg.getInstanceNotCreate() then
			_instance:RemoveEvent(PetPropertyDlg.getInstanceNotCreate():GetWindow())
			PetPropertyDlg.CloseDialog()			
		end 

		if PetStarDlg.getInstanceNotCreate() then
			_instance:RemoveEvent(PetStarDlg.getInstanceNotCreate():GetWindow())
			PetStarDlg.CloseDialog()			
		end 
		if PetTrainDlg.getInstanceNotCreate() then
			_instance:RemoveEvent(PetTrainDlg.getInstanceNotCreate():GetWindow())
			PetTrainDlg.CloseDialog()			
		end 
		if PetChipDlg.getInstanceNotCreate() then
			_instance:RemoveEvent(PetChipDlg.getInstanceNotCreate():GetWindow())
			PetChipDlg.CloseDialog()			
		end 
		_instance:OnClose()
		_instance = nil
	end	
end

function PetLabel.Show(index)
	index = index or 1
	PetLabel.getInstance()
	_instance:ShowOnly(index)	
end

function PetLabel.ShowStarDlg()
	PetLabel.Show(2)
end

function PetLabel:ShowOnly(index)
	--hide all
	self.m_index = index	
	if PetPropertyDlg.getInstanceNotCreate() then
		PetPropertyDlg.getInstanceNotCreate():GetWindow():setVisible(false)
	end
	if PetStarDlg.getInstanceNotCreate() then
		PetStarDlg.getInstanceNotCreate():GetWindow():setVisible(false)
	end
	if PetTrainDlg.getInstanceNotCreate() then
		PetTrainDlg.getInstanceNotCreate():GetWindow():setVisible(false)
	end
	if PetChipDlg.getInstanceNotCreate() then
		PetChipDlg.getInstanceNotCreate():GetWindow():setVisible(false)
	end


	if index == 1 then
		if PetPropertyDlg.getInstanceNotCreate() then
			PetPropertyDlg.getInstanceAndShow():Init()
		else
			local dlg = PetPropertyDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	elseif index == 2 then
		if PetStarDlg.getInstanceNotCreate() then
			PetStarDlg.getInstanceAndShow():Init()
		else
			local dlg = PetStarDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	elseif index == 3 then
		if PetTrainDlg.getInstanceNotCreate() then
			PetTrainDlg.getInstanceAndShow():InitPetList()
			PetTrainDlg.getInstanceNotCreate():RefreshSpends()
		else
			local dlg = PetTrainDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	elseif index == 4 then
		if PetChipDlg.getInstanceNotCreate() then
			PetChipDlg.getInstanceAndShow():RefreshPaneInfo()
			PetChipDlg.getInstanceAndShow():RefreshXuemai()
		else
			local dlg = PetChipDlg.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	end	
end

function PetLabel:HandleLabel1BtnClicked(e)
	LogInfo("label 1 clicked")
	PetLabel.getInstance():ShowOnly(1)	
	return true
end
function PetLabel:HandleLabel2BtnClicked(e)
	LogInfo("label 2 clicked")
	PetLabel.getInstance():ShowOnly(2)	
	return true
end
function PetLabel:HandleLabel3BtnClicked(e)
	LogInfo("label 3 clicked")
	PetLabel.getInstance():ShowOnly(3)	
	return true
end
function PetLabel:HandleLabel4BtnClicked(e)
	LogInfo("label 4 clicked")
	PetLabel.getInstance():ShowOnly(4)	
	return true
end

function PetLabel:SubscribeEvent(pWnd)
	LogInfo("petlabel subscribe event")
	pWnd:subscribeEvent("AlphaChanged", PetLabel.HandleDlgStateChange, self)
	pWnd:subscribeEvent("Shown", PetLabel.HandleDlgStateChange, self)
	pWnd:subscribeEvent("Hidden", PetLabel.HandleDlgStateChange, self)
	pWnd:subscribeEvent("InheritAlphaChanged", PetLabel.HandleDlgStateChange, self)
	LogInfo("petlabel subscribe event end")
end

function PetLabel:RemoveEvent(pWnd)
	LogInfo("petlabel remove event")
	pWnd:removeEvent("AlphaChanged")
	pWnd:removeEvent("Shown")
	pWnd:removeEvent("Hidden")
	pWnd:removeEvent("InheritAlphaChanged")
end

function PetLabel:HandleDlgStateChange(args)
	LogInfo("petlabel handle dlg state change")
	if PetPropertyDlg.getInstanceNotCreate() then 
		local pWnd = PetPropertyDlg.getInstanceNotCreate():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end
	if PetStarDlg.getInstanceNotCreate() then 
		local pWnd = PetStarDlg.getInstanceNotCreate():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end
	if PetTrainDlg.getInstanceNotCreate() then 
		local pWnd = PetTrainDlg.getInstanceNotCreate():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end
	if PetChipDlg.getInstanceNotCreate() then 
		local pWnd = PetChipDlg.getInstanceNotCreate():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end

	self:GetWindow():setVisible(false)
	return true
end

return PetLabel
