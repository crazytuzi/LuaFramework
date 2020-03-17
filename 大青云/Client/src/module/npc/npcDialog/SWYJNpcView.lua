--[[
死亡遗迹 NPC对话面板
lizhuangzhuang
2015年11月24日17:33:02
]]

_G.UISWYJNpc = UINpcDialogBase:new("UISWYJNpc")

function UISWYJNpc:Open(npcId)
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	self:SendNPCGossipMsg(npcId)
	if activity:GetStatueStat()==ActivitySiWangYiJi.StatueStat_Lock or activity:GetStatueStat()==ActivitySiWangYiJi.StatueStat_Die then
		local npc = NpcModel:GetCurrNpcByNpcId(npcId)
		if not npc then return end
		self.npc = npc
		self:Show()
	end
end

function UISWYJNpc:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local cfg = self.npc:GetCfg()
	if cfg then
		objSwf.labelNpcName.text = cfg.name
	end
	self:DrawNpc()
	--
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then return; end
	if activity:GetStatueStat() == ActivitySiWangYiJi.StatueStat_Lock then
		objSwf.tfTalk.text = string.format(StrConfig["activityswyj016"],activity:GetGuildName());
		local option = { label = StrConfig["activityswyj017"] }
		objSwf.optionList.dataProvider:cleanUp()
		objSwf.optionList.dataProvider:push(UIData.encode(option))
		objSwf.optionList:invalidateData()
	else
		objSwf.tfTalk.text = StrConfig["activityswyj018"];
		local str = string.format(StrConfig["activityswyj019"],toint(t_consts[152].val1/10000,-1));
		local option = { label = str }
		objSwf.optionList.dataProvider:cleanUp()
		objSwf.optionList.dataProvider:push(UIData.encode(option))
		objSwf.optionList:invalidateData()
	end
end

function UISWYJNpc:OnItemClick()
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if not activity then
		self:Hide();
		return; 
	end
	if activity:GetStatueStat() == ActivitySiWangYiJi.StatueStat_Lock then
		activity:StatueActive();
	else
		activity:StatueRepair();
	end
	self:Hide();
end

