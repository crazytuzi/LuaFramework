require "utils.mhsdutils"
require "ui.dialog"
require "ui.arounddialog"
require	"ui.team.teamdialog"
TeamLabel = {}

setmetatable(TeamLabel, Dialog)
TeamLabel.__index = TeamLabel

local _instance;

function TeamLabel.getInstance()
	if not _instance then
		_instance = TeamLabel:new()
		_instance:OnCreate()
	end
	return _instance
end

function TeamLabel.getInstanceNotCreate()
	return _instance
end

function TeamLabel.GetLayoutFileName()
	return "Lable.layout"
end
function TeamLabel:OnCreate()
	local enumTeamLabel = "teamlabel"
	Dialog.OnCreate(self,nil, enumTeamLabel)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = winMgr:getWindow(tostring(enumTeamLabel) .. "Lable/button")
	self.m_pButton2 = winMgr:getWindow(tostring(enumTeamLabel) .. "Lable/button1")
	self.m_pButton3 = winMgr:getWindow(tostring(enumTeamLabel) .. "Lable/button2")
	self.m_pButton4 = winMgr:getWindow(tostring(enumTeamLabel) .. "Lable/button3")
	self.m_pButton5 = winMgr:getWindow(tostring(enumTeamLabel) .. "Lable/button4")

	self.m_pButton1:setText(MHSD_UTILS.get_resstring(3007))
	self.m_pButton2:setText(MHSD_UTILS.get_resstring(3008))
	self.m_pButton3:setVisible(false)
	self.m_pButton4:setVisible(false)
	self.m_pButton5:setVisible(false)

	self.m_pButton1:subscribeEvent("Clicked", TeamLabel.HandleLabel1BtnClicked, self)
	self.m_pButton2:subscribeEvent("Clicked", TeamLabel.HandleLabel2BtnClicked, self)

	end


function TeamLabel:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, TeamLabel)
	return self
end

function TeamLabel.DestroyDialog()	
	LogInfo("petlabel destroy dialog")	
	if _instance then
		--close all 
		if TeamDialog.getInstanceNotCreate() then
			_instance:RemoveEvent(TeamDialog.getInstanceNotCreate():GetWindow())
			TeamDialog.CloseDialog()			
		end 

		if AroundDialog.getInstanceNotCreate() then
			_instance:RemoveEvent(AroundDialog.getInstanceNotCreate():GetWindow())
			AroundDialog.CloseDialog()			
		end 
		_instance:OnClose()
		_instance = nil
	end	
end

function TeamLabel.Show(index)
	index = index or 1
	TeamLabel.getInstance()
	_instance:ShowOnly(index)	
end

function TeamLabel.ShowStarDlg()
	TeamLabel.Show(1)
end

function TeamLabel:ShowOnly(index)
	--hide all
	self.m_index = index	
	if TeamDialog.getInstanceNotCreate() then
		TeamDialog.getInstanceNotCreate():GetWindow():setVisible(false)
	end
	if AroundDialog.getInstanceNotCreate() then
		AroundDialog.getInstanceNotCreate():GetWindow():setVisible(false)
	end

	if index == 1 then
		if TeamDialog.getInstanceNotCreate() then
			TeamDialog.getInstanceAndShow()
		else
			local dlg = TeamDialog.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	elseif index == 2 then
		if AroundDialog.getInstanceNotCreate() then
			AroundDialog.getInstanceAndShow()
		else
			local dlg = AroundDialog.getInstanceAndShow()
			self:SubscribeEvent(dlg:GetWindow())
		end
	end
end

function TeamLabel:HandleLabel1BtnClicked(e)
	LogInfo("label 1 clicked")
	TeamLabel.getInstance():ShowOnly(1)	
	return true
end
function TeamLabel:HandleLabel2BtnClicked(e)
	LogInfo("label 2 clicked")
	TeamLabel.getInstance():ShowOnly(2)	
	return true
end
function TeamLabel:SubscribeEvent(pWnd)
	LogInfo("petlabel subscribe event")
	pWnd:subscribeEvent("AlphaChanged", TeamLabel.HandleDlgStateChange, self)
	pWnd:subscribeEvent("Shown", TeamLabel.HandleDlgStateChange, self)
	pWnd:subscribeEvent("Hidden", TeamLabel.HandleDlgStateChange, self)
	pWnd:subscribeEvent("InheritAlphaChanged", TeamLabel.HandleDlgStateChange, self)
	LogInfo("petlabel subscribe event end")
end

function TeamLabel:RemoveEvent(pWnd)
	LogInfo("petlabel remove event")
	pWnd:removeEvent("AlphaChanged")
	pWnd:removeEvent("Shown")
	pWnd:removeEvent("Hidden")
	pWnd:removeEvent("InheritAlphaChanged")
end

function TeamLabel:HandleDlgStateChange(args)
	LogInfo("petlabel handle dlg state change")
	if TeamDialog.getInstanceNotCreate() then 
		local pWnd = TeamDialog.getInstanceNotCreate():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end
	if AroundDialog.getInstanceNotCreate() then 
		local pWnd = AroundDialog.getInstanceNotCreate():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end
	self:GetWindow():setVisible(false)
	return true
end

return TeamLabel
