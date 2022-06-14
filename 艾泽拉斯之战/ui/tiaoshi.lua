
local tiaoshi = class("tiaoshi",layout)

global_event.BATTLE_DEBUG_SHOW = "BATTLE_DEBUG_SHOW"
global_event.BATTLE_DEBUG_HIDE = "BATTLE_DEBUG_HIDE"

function tiaoshi:ctor( id )
	 tiaoshi.super.ctor(self,id)	
	 self:addEvent({ name = global_event.BATTLE_DEBUG_SHOW, eventHandler = self.onShow})				
	 self:addEvent({ name = global_event.BATTLE_DEBUG_HIDE, eventHandler = self.onHide})
end	

function tiaoshi:onShow(event)

	 function onClickClose()
	 	self:onHide();
	 end
	 
	 function onRenderQueueStateChange(args)
	 	local check = LORD.toCheckBox(LORD.toWindowEventArgs(args).window);
	 	local queueID = check:GetUserData();
	 	if check:GetChecked() then
	 		for k, v in ipairs(self.renderQueueMap[queueID]) do
	 			self:enableRenderQueue(v);
	 		end
	 	else
	 		for k, v in ipairs(self.renderQueueMap[queueID]) do
	 			self:disableRenderQueue(v);
	 		end
	 	end
	 end
	 
	 self:Show();
	 
	 sceneManager.battlePlayer():pauseGame(true);
	 self.recordBox = LORD.toInputBox(self:Child("tiaoshi-box"));
	 self:Child("tiaoshi-close"):subscribeEvent("ButtonClick", "onClickClose");
	 
	 self.tiaoshi_renderTerrain = LORD.toCheckBox(self:Child("tiaoshi-renderTerrain"));
	 self.tiaoshi_renderStaticMesh = LORD.toCheckBox(self:Child("tiaoshi-renderStaticMesh"));
	 self.tiaoshi_renderUI = LORD.toCheckBox(self:Child("tiaoshi-renderUI"));
	 self.tiaoshi_renderActor = LORD.toCheckBox(self:Child("tiaoshi-renderActor"));
	 self.tiaoshi_renderEffect = LORD.toCheckBox(self:Child("tiaoshi-renderEffect"));
	 
	 self.tiaoshi_renderTerrain:subscribeEvent("CheckStateChanged", "onRenderQueueStateChange");
	 self.tiaoshi_renderStaticMesh:subscribeEvent("CheckStateChanged", "onRenderQueueStateChange");
	 self.tiaoshi_renderUI:subscribeEvent("CheckStateChanged", "onRenderQueueStateChange");
	 self.tiaoshi_renderActor:subscribeEvent("CheckStateChanged", "onRenderQueueStateChange");
	 self.tiaoshi_renderEffect:subscribeEvent("CheckStateChanged", "onRenderQueueStateChange");
	 
	 self.renderQueueMap = {
	 	{2,3,4,5,6}, -- static mesh
	 	{7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22}, -- actor
	 	{23, 24}, -- terrain
	 	{27}, -- effect
	 	{32}, -- ui
	 };
	 self.tiaoshi_renderTerrain:SetUserData(3);
	 self.tiaoshi_renderStaticMesh:SetUserData(1);
	 self.tiaoshi_renderUI:SetUserData(5);
	 self.tiaoshi_renderActor:SetUserData(2);
	 self.tiaoshi_renderEffect:SetUserData(4);
	 
	 self.tiaoshi_renderTerrain:SetChecked(true);
	 self.tiaoshi_renderStaticMesh:SetChecked(true);
	 self.tiaoshi_renderUI:SetChecked(true);
	 self.tiaoshi_renderActor:SetChecked(true);
	 self.tiaoshi_renderEffect:SetChecked(true);
	 
	 for k, v in ipairs(battleRecord.records) do
	 	self.recordBox:ADDText(v);
	 end
	 
end

function tiaoshi:onHide(event)
	sceneManager.battlePlayer():pauseGame(false);
	self:Close();
end

function tiaoshi:enableRenderQueue(queueID)
	LORD.Root:Instance():enableRenderQueue(queueID);
end

function tiaoshi:disableRenderQueue(queueID)
	LORD.Root:Instance():disableRenderQueue(queueID);
end

return tiaoshi