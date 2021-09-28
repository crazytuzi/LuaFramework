NPCDialogView =BaseClass()

function NPCDialogView:__init()
	self:Config()
end

function NPCDialogView:Config()
	self:LayoutUI()
	self:InitData()
end

function NPCDialogView:LayoutUI()
	if self.isInited == true then return end
	resMgr:AddUIAB("NPCDialog")
	self.isInited = true
end

function NPCDialogView:InitData()
	self.isInited = false
	self.npcDialogPanel = nil
	self.npcSubmitTaskPanel = nil
	self.npcHeadUIPanel = nil
	self.curPanel = nil
end

-- function NPCDialogView:Close()
-- 	if self.curPanel then
-- 		self.curPanel:Close()
-- 		self.curPanel:Destroy()
-- 		self.curPanel = nil
-- 	end
-- end

function NPCDialogView:OpenNPCDialogPanel()
	if  not self.npcDialogPanel  or (not self.npcDialogPanel.isInited) then
		self.npcDialogPanel = NPCDialogPanel.New()
		self.npcDialogPanel:Open()
	else
		self.npcDialogPanel:Open()
		self.npcDialogPanel:SetDefaultUI()
	end

end

function NPCDialogView:NPCDialogPanelIsAlive()
	local rtnIsAlive = false
	if self.npcDialogPanel ~= nil then
		if self.npcDialogPanel.isInited then
			rtnIsAlive = true
		end
	end
	return rtnIsAlive
end

function NPCDialogView:CloseNPCDialogPanel()
	if self.npcDialogPanel then
		self.npcDialogPanel:Close()
	end
end

function NPCDialogView:OpenNPCDialogPanelByNPC(npcId, taskDataList, funId)
	if  not self.npcDialogPanel  or (not self.npcDialogPanel.isInited) then
		self.npcDialogPanel = NPCDialogPanel.New()
	end
	self.npcDialogPanel:Open()
	self.npcDialogPanel:SetNPCUI(npcId, taskDataList, funId)
end

function NPCDialogView:OpenNPCSubmitTaskPanel()
	if  not self.npcSubmitTaskPanel or (not self.npcSubmitTaskPanel.isInited) then
		self.npcSubmitTaskPanel = NPCSubmitTaskPanel.New()
		self.npcSubmitTaskPanel:Open()
	else
		self.npcSubmitTaskPanel:Open()
		self.npcSubmitTaskPanel:SetDataAndUI()
	end
end


function NPCDialogView:OpenNPCHeadUIPanel()
	local pane = self.npcHeadUIPanel
	if (not pane) or (not pane.isInited )then
		pane = NPCHeadUIPanel.New()
		self.npcHeadUIPanel=pane
	end
	if not pane then pane:Open() end
end


function NPCDialogView:__delete()
	local pane = self.npcHeadUIPanel
	if pane and pane.isInited then
		pane:Destroy()
	end
	self.npcHeadUIPanel = nil
	pane = self.npcSubmitTaskPanel
	if pane and pane.isInited then
		pane:Destroy()
	end
	self.npcSubmitTaskPanel = nil
end