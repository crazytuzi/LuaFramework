require "ui.label"
require "ui.workshop.workshopcxnew"
require "utils.mhsdutils"
require "ui.workshop.workshopqhnew"
require "ui.workshop.workshopxqnew"
require "ui.workshop.workshopjlnew"
WorkshopLabel = {
	ShowStatus = {}
}
local dlgs = {WorkshopQhNew, WorkshopCxNew, WorkshopXqNew, WorkshopJl}
--setmetatable(WorkshopLabel, WorkshopLabel)
--WorkshopLabel.__index = WorkshopLabel
function WorkshopLabel.new() 
	local newWsLabel = {}
	setmetatable(newWsLabel, {__index = WorkshopLabel })
--	newWsLabel.__index = WorkshopLabel
	return newWsLabel
end
--[[function WorkshopLabel.Show(showtype)
	local label = WorkshopLabel.m_Label
	if label == nil then
		label = LabelDlg.new()
	end
	if showtype == 1 then
		print("Unsupported type 1\n")
	elseif showtype == 2 then
		print("Unsupported type\n")
	end
end]]--
function WorkshopLabel.RegistFunctionForCpp()
	LogInsane("WorkshopLabel.RegistFunctionForCpp")
	CWorkshopManager:GetSingletonDialog():AddLuaFunction(CEGUI.String("WorkshopLabel.Show"), WorkshopLabel.Show)	
end

function WorkshopLabel.Show(type, bagid, itemkey)
	LogInsane("show type111111="..type)
	print(enumWorkShopLabel)
	if WorkshopLabel.m_Label then
		return
	end
	local newLabel = WorkshopLabel.new()
	WorkshopLabel.m_Label = LabelDlg.new(enumWorkShopLabel)

	newLabel.m_Label:InitButtons(MHSD_UTILS.get_resstring(2682), MHSD_UTILS.get_resstring(2683), 
		MHSD_UTILS.get_resstring(2684), MHSD_UTILS.get_resstring(2922))
	newLabel.m_Label.m_labels[1]:subscribeEvent("Clicked", WorkshopLabel.HandleLabel1BtnClicked, newLabel)
	newLabel.m_Label.m_labels[2]:subscribeEvent("Clicked", WorkshopLabel.HandleLabel2BtnClicked, newLabel)
    newLabel.m_Label.m_labels[3]:subscribeEvent("Clicked", WorkshopLabel.HandleLabel3BtnClicked, newLabel)
	newLabel.m_Label.m_labels[4]:subscribeEvent("Clicked", WorkshopLabel.HandleLabel4BtnClicked, newLabel)
	local dlg = dlgs[type]:getInstance()
	--[[
	if type == 1 then
		dlg = WorkshopQhNew.getInstance()
	elseif type == 2 then
		dlg = WorkshopCxNew.getInstance()
	elseif type == 3 then 
		dlg = WorkshopXqNew.getInstance()
	elseif type == 4 then
		dlg = :getInstance()
	end
	--]]
	dlg.m_LinkLabel = newLabel
	if dlg and itemkey ~= nil and itemkey ~= 0 then
		LogInsane("Show itemkey="..itemkey)
		dlg:SetItemSelected(bagid, itemkey)
	end
	if dlg and not dlg:IsVisible() then
		dlg:SetVisible(true)
	end
end

function WorkshopLabel:showDlg(idx)
	for i = 1, #dlgs do
		if idx == i then
			local dlg = dlgs[i]:getInstance()
			dlg.m_LinkLabel = self
			if not dlg:IsVisible() then
				dlg:SetVisible(true)
				dlg:GetWindow():setAlpha(1.0)
			end
		else
			local dlg = dlgs[i]:getInstanceOrNot()
			if dlg and dlg:IsVisible() then
				dlg:SetVisible(false)
			end
		end
	end
end

function WorkshopLabel:HandleLabel1BtnClicked(e)
	self:showDlg(1)
	--[[
	local cxdlg = WorkshopCxNew.getInstanceOrNot()
	if cxdlg and cxdlg:IsVisible() then
		cxdlg:SetVisible(false)
	end
	
	local xqdlg = WorkshopXqNew.getInstanceOrNot()
	if xqdlg and xqdlg:IsVisible() then
		xqdlg:SetVisible(false)
	end
	
	local qhdlg = WorkshopQhNew.getInstance()
	qhdlg.m_LinkLabel = self
	if not qhdlg:IsVisible() then
		qhdlg:SetVisible(true)
		qhdlg:GetWindow():setAlpha(1.0)
	end
	--]]
	return true
end

function WorkshopLabel:HandleLabel2BtnClicked(e)
	self:showDlg(2)
	--[[
	local qhdlg = WorkshopQhNew.getInstanceOrNot()
	if qhdlg and qhdlg:IsVisible() then
		qhdlg:SetVisible(false)
	end
	
	local xqdlg = WorkshopXqNew.getInstanceOrNot()
	if xqdlg and xqdlg:IsVisible() then
		xqdlg:SetVisible(false)
	end
	
	local cxdlg = WorkshopCxNew.getInstance()
	cxdlg.m_LinkLabel = self
	if not cxdlg:IsVisible() then
		cxdlg:SetVisible(true)
		cxdlg:GetWindow():setAlpha(1.0)
	end
	--]]
	return true
end
function WorkshopLabel:HandleLabel3BtnClicked(e)
	self:showDlg(3)
	--[[
	local qhdlg = WorkshopQhNew.getInstanceOrNot()
	if qhdlg and qhdlg:IsVisible() then
		qhdlg:SetVisible(false)
	end
	
	local cxdlg = WorkshopCxNew.getInstanceOrNot()
	if cxdlg and cxdlg:IsVisible() then
		cxdlg:SetVisible(false)
	end
	
	local xqdlg = WorkshopXqNew.getInstance()
	xqdlg.m_LinkLabel = self
	if not xqdlg:IsVisible() then
		xqdlg:SetVisible(true)
		xqdlg:GetWindow():setAlpha(1.0)
	end
	--]]
	return true
end
function WorkshopLabel:HandleLabel4BtnClicked(e)
	self:showDlg(4)
end
--[[function WorkshopLabel:HandleCloseBtnClick(e)
	Dialog.HandleCloseBtnClick(self, e)
	self.label = nil
	_instance = nil
end]]--
function WorkshopLabel:OnClose()
	if WorkshopLabel.m_Label then
		WorkshopLabel.m_Label:OnClose()
		WorkshopLabel.m_Label = nil
	end
	for i = 1, #dlgs do
		local dlg = dlgs[i]:getInstanceOrNot()
		if dlg then
			dlg:OnClose()
		end
	end
	--[[
	local cxdlg = WorkshopCxNew.getInstanceOrNot()
	if cxdlg then
		cxdlg:OnClose()
	end
	local qhdlg = WorkshopQhNew.getInstanceOrNot()
	if qhdlg then
		qhdlg:OnClose()
	end
	local xqdlg = WorkshopXqNew.getInstanceOrNot()
	if xqdlg then
		xqdlg:OnClose()
	end 
	--]]
end

function WorkshopLabel:RefreshItemTips(item)
	for i = 1, #dlgs do
		local dlg = dlgs[i]:getInstanceOrNot()
		if dlg then
			dlg:RefreshItemTips(item)
		end
	end
	--[[
	 local cxdlg = WorkshopCxNew.getInstanceOrNot()
	 if cxdlg then
	 	cxdlg:RefreshItemTips(item)
	 end
	 local qhdlg = WorkshopQhNew.getInstanceOrNot()
	 if qhdlg then
	 	qhdlg:RefreshItemTips(item)
	 end
	 local xqdlg = WorkshopXqNew.getInstanceOrNot()
	 if xqdlg then
	 	xqdlg:RefreshItemTips(item)
	 end
	 --]]
end

return WorkshopLabel
