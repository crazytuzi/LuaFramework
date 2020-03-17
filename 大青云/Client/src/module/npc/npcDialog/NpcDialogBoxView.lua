--[[
Npc对话界面
haohu
2014年7月24日21:47:26
]]
_G.UINpcDialogBox = UINpcDialogBase:new("UINpcDialogBox")


UINpcDialogBox.objUIDraw = nil; -- 3d渲染器
UINpcDialogBox.npc       = nil; -- NPC对象
UINpcDialogBox.questList = nil; -- 任务列表

--打开面板
--@param npcId NPCID
function UINpcDialogBox:Open(npcId)
	local npc = NpcModel:GetCurrNpcByNpcId(npcId);
	if not npc then return; end
	self.npc = npc;
	--判断任务状态,如果只有一个任务,直接打开任务对话
	self.questList = QuestController:GetNpcQuestStateList(self.npc.npcId);
	-- 主线NPC对话
	for _, quest in ipairs( self.questList ) do
		if quest:GetType() == QuestConsts.Type_Trunk then
			self:DoShowNpcQuest( quest:GetId() )
			return
		end
	end
	npc:DialogSound()
	-- 副本NPC对话
	if DungeonModel:IsDungeonDialog() then
		UIDungeonDialogBox:Open(self.npc.npcId, DungeonModel:GetDungeonStep())
		return
	end
	-- 奇遇副本NPC对话
	if RandomQuestModel:IsInDungeon() then
		UIRandomDungeonNpc:Open(npcId)
		return
	end
	-- 奇遇任务NPC对话
	local randomQuest = RandomQuestModel:GetQuest()
	if randomQuest and randomQuest:ShowNpcDialog( npcId ) then
		return
	end
	--讨伐
	local taofaQuest = QuestModel:GetTaoFaQuest()
	if taofaQuest and taofaQuest:ShowNpcDialog( npcId ) then
		return
	end
	--集会所 新悬赏
	local agoraQuest = QuestModel:GetAgoraQuest()
	if agoraQuest and agoraQuest:ShowNpcDialog( npcId ) then
		return
	end
	-- 转生
	if ZhuanModel:GetZhuanActState() then
		UIDungeonDialogBox:Open(self.npc.npcId, ZhuanModel:GetZhuanCopyid())
		return
	end
	-- 死亡遗迹
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	if activity and activity:GetType() == ActivityConsts.T_SiWangYiJi then
		UISWYJNpc:Open(self.npc.npcId);
		return;
	end
	--婚礼副本；
	if self.npc.npcId == MarriageConsts.NpcYuelao 
		or self.npc.npcId == MarriageConsts.NpcSiyi 
		or self.npc.npcId == MarriageConsts.NpcHuatong  then
		--结婚是否开启
		if not FuncManager:GetFuncIsOpen(FuncConsts.Marry) then
			FloatManager:AddNormal(StrConfig['marriage217'])
			return 
		end;
		UIMarryNpcBox:Open(self.npc.npcId)
		return
	end;
	self:Show();
end

--去显示NPC任务对话面板
function UINpcDialogBox:DoShowNpcQuest(questId)
	UINpcQuestPanel:Open( self.npc.npcId, questId );
end

function UINpcDialogBox:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = self.npc:GetCfg();
	if cfg then
		objSwf.labelNpcName.text = cfg.name;
		objSwf.tfTalk.text = cfg.talk;
	end
	--draw 3D
	self:DrawNpc();

	--显示列表,功能
	local optionList = {};
	--功能
	if cfg.func ~= "" then
		local funcTable = split( cfg.func, "," );
		for i = 1, #funcTable do
			local listVO = {};
			listVO.itemType = 2;
			local id = tonumber( funcTable[i] )
			local cfg = UINpcDialogBox.NpcFuncConfig[id]
			local label = cfg and cfg.label or "missing"
			listVO.id = id
			listVO.label = string.format( "<u><font color='#00FF00'>%s</font></u>", label );
			table.push( optionList, listVO );
		end
	end
	--刷新列表
	objSwf.optionList.dataProvider:cleanUp();
	for i = 1, #optionList do
		objSwf.optionList.dataProvider:push( UIData.encode( optionList[i] ) );
	end
	objSwf.optionList:invalidateData();
end

function UINpcDialogBox:OnItemClick(e)
	if not e.item.itemType then	return; end
	--点击任务
	if e.item.itemType == 1 then
		self:Hide();
		self:DoShowNpcQuest(e.item.id);
		return;
	end
	--点击NPC功能,根据索引执行相应脚本
	if e.item.itemType == 2 then
		local id = e.item.id
		if not id then return end
		local cfg = UINpcDialogBox.NpcFuncConfig[id]
		local func = cfg and cfg.func
		if func then func() end
	end
end

UINpcDialogBox.NpcFuncConfig = {
	[1] = {
		label = StrConfig["npcDialog002"],
		func = function()
			if YunYingController:GetReward(YunYingConsts.RT_TitleZiTao) then
				UINpcDialogBox:Hide();
			end
		end
	},
	[2] = {
		label = StrConfig["npcDialog003"],
		func = function()
			if not UIRegisterAward:IsShow() then
				UIRegisterAward:SetPanelName("code")
				UIRegisterAward:Show();
			else
				UIRegisterAward:OnTabButtonClick("code")
			end
		end
	},
	[3] = {
		label = StrConfig["npcDialog004"],
		func = function()
			if YunYingController:GetReward(YunYingConsts.RT_TitleYangMi) then
				UINpcDialogBox:Hide();
			end
		end
	},
	[4] = {
		label = StrConfig["npcDialog005"],
		func = function()
			UIShopExchange:Show()
		end
	},
	[5] = {
		label = StrConfig["npcDialog007"],
		func = function()
			UIShopXmasExchange:Show()
		end
	},
	[6] = {
		label = StrConfig['npcDialog009'],
		func = function()
			local okfun = function()
				UnionDiGongController:ReqEnterGuildDiGong()
				if BagModel:GetItemNumInBag(180500401) < 1 then
					UIQuickBuyConfirm:Open(self,180500401)
				end
			end
			local color = BagModel:GetItemNumInBag(180500401) > 0 and TipsConsts:GetItemQualityColor(t_item[180500401].quality) or "#ff0000"
			UIConfirm:Open(string.format(StrConfig["npcDialog008"], color), okfun)
			return 
		end
	},
}