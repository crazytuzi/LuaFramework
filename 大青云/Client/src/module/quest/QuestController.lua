
_G.QuestController = setmetatable({}, {__index = IController})
QuestController.name = "QuestController"

-- 切换场景后回调
QuestController.afterSceneChange = nil;
--需要任务特殊处理的Npc,Monster
QuestController.QuestNpcMap = {};
QuestController.QuestMonsterMap = {};
QuestController.QuestConllectMap = {};


QuestController.FinishedQuestMap = {}--需要特殊处理的已完成任务列表
QuestController.unlockNpcMap = {}--每个地图中的已解锁npc
QuestController.unlockJiguanMap = {}--每个地图中的已解锁机关

function QuestController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_FinishedQuestList,self,self.OnFinishedQuestListResult);--返回需要特殊处理的已完成任务列表
	MsgManager:RegisterCallBack(MsgType.SC_QueryQuestResult,self,self.OnQueryQuestResult);
	MsgManager:RegisterCallBack(MsgType.SC_QuestAdd,self,self.OnQuestAdd);
	MsgManager:RegisterCallBack(MsgType.SC_QuestUpdate,self,self.OnQuestUpdate);
	MsgManager:RegisterCallBack(MsgType.SC_AcceptQuestResult,self,self.OnAcceptQuestResult);
	MsgManager:RegisterCallBack(MsgType.SC_GiveupQuestResult,self,self.OnGiveupQuestResult);
	MsgManager:RegisterCallBack(MsgType.SC_FinishQuestResult,self,self.OnFinishQuestResult);
	MsgManager:RegisterCallBack(MsgType.SC_QuestDel,self,self.OnQuestDel);

	--以下日环协议处理
	MsgManager:RegisterCallBack(MsgType.SC_DailyQuestFinish,self,self.OnDailyQuestOneKeyFinish);
	MsgManager:RegisterCallBack(MsgType.SC_DailyQuestResult,self,self.OnDailyQuestResultRsv);
	MsgManager:RegisterCallBack(MsgType.SC_DailyQuestSkipResult,self,self.OnQuestSkipResultRsv);
	MsgManager:RegisterCallBack(MsgType.SC_DQDrawNotice,self,self.OnDQDrawNoticeRsv);
	-- MsgManager:RegisterCallBack(MsgType.SC_DQDraw,self,self.OnDQDrawResultRsv);
	MsgManager:RegisterCallBack(MsgType.SC_DailyQuestStar,self,self.OnDailyQuestStarResultRsv);
	-- MsgManager:RegisterCallBack(MsgType.SC_GetDQSkipReward,self,self.OnGetDQSkipRewardResult);
	--任务装备提升
	MsgManager:RegisterCallBack(MsgType.SC_QuestEquipPromote,self,self.OnQuestEquipPromoteRsv);

	--猎魔任务相关 Today新日环或新讨伐 yanghongbin  2016-11-12
	MsgManager:RegisterCallBack(MsgType.SC_TodayQuestFinish,self,self.OnLieMoQuestOneKeyFinish);
	MsgManager:RegisterCallBack(MsgType.SC_TodayQuestResult,self,self.OnLieMoQuestResultRsv);

	self:InitNpcMonsterState();

end

function QuestController:Update(interval)
	QuestGuideManager:OnUpdate(interval);
end

function QuestController:OnEnterGame()
	for k, v in pairs(QuestConsts.MainPageQuestOrder) do
		QuestConsts.MainPageQuestIndex[v] = k;
	end
	QuestModel:CheckHangQuest();
end

function QuestController:OnChangeSceneMap()
	if self.afterSceneChange then
		self.afterSceneChange();
		self.afterSceneChange = nil;
	else
		QuestGuideManager:OnChangeMap();
	end

	self:UnlockCurrentMapJiguan()
	-- 日环领奖界面该关闭的要关闭
	UIQuestDayReward:OnChangeScene()
	UIQuestDayMultipleReward:OnChangeScene()
	UIWuhunDungeonExit:Hide();
	if UITimeTopSec:IsShow() then
		UITimeTopSec:Hide();
	end
end

function QuestController:SetSceneChangeCallBack( cb )
	self.afterSceneChange = cb
end

--任务指引
function QuestController:DoGuide(questId)
	local questVO = QuestModel:GetQuest(questId);
	if not questVO then return end;
	questVO:Proceed(); -- 进行任务
end

--跑向NPC
function QuestController:DoRunToNpc(point,npcId)
	if not point then return; end
	local completeFuc = function()
		NpcController:ShowDialog(npcId);
	end
	MainPlayerController:DoAutoRun( point.mapId, _Vector3.new(point.x + 2,point.y + 2,0), completeFuc, nil, nil, nil, t_npc[npcId].open_dis);
end

--请求接受任务
function QuestController:AcceptQuest(questId)
	if (not t_quest[questId]) and (not t_questrandom[questId]) then return; end

	local msg = ReqAcceptQuestMsg:new();
	msg.id = questId;
	MsgManager:Send(msg);
	SoundManager:PlaySfx(2026);
end

--提交任务点击
function QuestController:TryQuestClick( clickQuestId )
	local questId, _ = QuestModel:GetCurrentClickQuest()
	if clickQuestId ~= questId then return end
	local msg = ReqQuestClickMsg:new();
	msg.id = questId;
	MsgManager:Send(msg);
	self:TestTrace( "--发送任务点击" )
end

--请求放弃任务
function QuestController:GiveUpQuest(questId)
	local msg = ReqGiveupQuestMsg:new();
		msg.id = questId;
		MsgManager:Send(msg);
	end

	--请求完成任务
	function QuestController:FinishQuest(questId, multiple, opertype)
		local msg = ReqFinishQuestMsg:new();
		msg.id = questId;
		msg.multiple = multiple or 1; -- 默认一倍
		msg.opertype = opertype or 0; -- 0默认正常完成，1为一键完成
		-- WriteLog(LogType.Normal,true,'---------------------FinishQuest',multiple)
		MsgManager:Send(msg);
		SoundManager:PlaySfx(2025)
	end

	--退出兽魄副本
	function QuestController:ExitWuhunDungeon()
		local currentMapId = CPlayerMap:GetCurMapID()
		if currentMapId ~= QuestConsts.WuhunDungeonMap then
		return
	end
	local msg = ReqExitWuhunDungeonMsg:new()
	msg.id = 1;
	MsgManager:Send(msg)
	UIWuhunDungeonExit:Hide();
end

--退出兽魄副本2
function QuestController:ExitWuhunDungeonTwo()
	local currentMapId = CPlayerMap:GetCurMapID()
	if currentMapId ~= QuestConsts.WuhunDungeonMapTwo then
		return
	end
	local msg = ReqExitWuhunDungeonMsg:new();
	msg.id = 2;
	MsgManager:Send(msg)
	UIWuhunDungeonExit:Hide();
end

--退出兽魄副本3
function QuestController:ExitWuhunDungeonThree()
	local currentMapId = CPlayerMap:GetCurMapID()
	if currentMapId ~= QuestConsts.WuhunDungeonMapThree then
		return
	end
	local msg = ReqExitWuhunDungeonMsg:new();
	msg.id = 3;
	MsgManager:Send(msg)
	UIWuhunDungeonExit:Hide();
end

--退出兽魄副本4
function QuestController:ExitWuhunDungeonFour()
	local currentMapId = CPlayerMap:GetCurMapID()
	if currentMapId ~= QuestConsts.WuhunDungeonMapFour then
		return
	end
	local msg = ReqExitWuhunDungeonMsg:new();
	msg.id = 4;
	MsgManager:Send(msg)
	UIWuhunDungeonExit:Hide();
end

--退出兽魄副本5
function QuestController:ExitWuhunDungeonFive()
	local currentMapId = CPlayerMap:GetCurMapID()
	if currentMapId ~= QuestConsts.WuhunDungeonMapFive then
		return
	end
	local msg = ReqExitWuhunDungeonMsg:new();
	msg.id = 5;
	MsgManager:Send(msg)
	UIWuhunDungeonExit:Hide();
end

--一键完成日环任务
function QuestController:ReqOneKeyFinish(multiple)
	local msg = ReqDailyQuestFinishMsg:new();
	msg.multiple = multiple or 1;
	MsgManager:Send( msg );
end

--日环任务升到5星
function QuestController:ReqAddStar( questId )
	-- 判断任务状态，已完成的任务不可升星
	local quest = QuestModel:GetQuest(questId);
	if not quest then return end
	if quest:GetState() == QuestConsts.State_CanFinish then
		FloatManager:AddNormal( StrConfig['quest403'] )
		return;
	end
	-- 判断afford
	local playerInfo = MainPlayerModel.humanDetailInfo;
	local availableMoeny = playerInfo.eaUnBindMoney + playerInfo.eaBindMoney;
	if availableMoeny < QuestConsts:GetAddStarCost() then
		FloatManager:AddNormal( StrConfig['quest146'] );
		return;
	end
	local msg = ReqDailyQuestStarMsg:new();
	msg.id = questId;
	MsgManager:Send( msg );
end

-- 请求今日日环任务完成结果信息
function QuestController:ReqDailyFinishInfo()
	MsgManager:Send( ReqDailyQuestResultMsg:new() );
end

-- 请求按指定倍数领取跳环奖励
function QuestController:ReqGetDailySkipReward(multiple)
	local msg = ReqGetDQSkipRewardMsg:new();
	msg.multiple = multiple;
	MsgManager:Send( msg );
end

-- 日环任务抽奖
-- function QuestController:ReqDailyDraw()
	-- MsgManager:Send( ReqDailyQuestDrawMsg:new() );
-- end

-- 日环任务抽奖确认领奖
function QuestController:ReqDailyDrawConfirm()
	-- WriteLog(LogType.Normal,true,'---------------------ReqDailyQuestDrawConfirmMsg')
	MsgManager:Send( ReqDailyQuestDrawConfirmMsg:new() );
end

---------------------------以下为处理服务器返回消息-----------------------------
-- 返回需要特殊处理的已完成任务列表
function QuestController:OnFinishedQuestListResult(msg)
	FTrace(msg, '返回需要特殊处理的已完成任务列表')
	self:InitFinishedQuestList(msg.QuestIds)
	-- --转生显示功能按钮
	-- if self:IsShowZhuanShen() then
	-- 	ZhuanContoller:ShowOpenView(true)
	-- end
	self:CheckSpecialBingHun();
	self:CalcRandomQuestFinishedCount(msg.QuestIds);
	self:sendNotification( NotifyConsts.QuestRefreshList );
end

function QuestController:CheckSpecialBingHun()
	if not MainPlayerController.isEnter then return; end
	if self:IsShowSpecailBingHun() and not FuncManager:GetFuncIsOpen(FuncConsts.BingHun) then
		MainPlayerController:AddBinghun(999)
		local cfg = t_binghun[999];
		if cfg then
			local skillId = cfg.skill
			local skillVO = SkillVO:new( skillId )
			SkillModel:AddSkill(skillVO)
			SkillModel:SetShortCut(18, skillId)
			self:sendNotification( NotifyConsts.SkillShortCutChange,{ pos = 18, skillId = skillId } )
			AutoBattleModel:AddSkill(skillId)
		end
	end
end
--计算奇遇任务完成数量
function QuestController:CalcRandomQuestFinishedCount(idslist)
	local count = 0;
	for k,v in pairs(idslist) do
		if t_questrandom[v.id] then
			count = count + v.count;
		end
	end
	QuestModel.randomQuestFinishedCount = count;
end

--返回任务列表
function QuestController:OnQueryQuestResult(msg)
	-- trace("返回任务列表")
	-- trace(msg)
	QuestModel:AddQuests( msg.quests )
	-- QuestModel:SetDailyAutoStar( msg.dailyAutoStar == 1 ); -- 1:true
end

function QuestController:TestTrace( info )
	if _G.isDebug then
		trace(info)
	end
end

--返回添加任务
function QuestController:OnQuestAdd(msg)
	self:TestTrace(msg)
	local quest = QuestModel:AddQuest( msg.id, msg.flag, msg.state, msg.goals )
	if not quest then return; end
	self:UpdateNpcQuestState( quest:GetCurrNPC() )
	self:UpdateCollectState( quest )
	QuestGuideManager:OnNewQuest( quest );
	SkillGuideManager:OnNewQuest( quest );
	self:ShowNpcWhenQ(msg.id);
	self:ShowMonsterWhenQ(msg.id);
	self:ShowConllectWhenQ(msg.id);

	--- 检测是否需要任务提示
	UIQuestNotice:CheckQuestNotice(quest, true)

	ClickLog:Send(ClickLog.T_QuestAdd,msg.id);
end

--返回更新任务
function QuestController:OnQuestUpdate(msg)
	self:TestTrace(msg)

	local quest, newNpc, oldNpc = QuestModel:UpdateQuest( msg.id, msg.flag, msg.state, msg.goals )
	if not quest then
		Debug( string.format("quest cannot find when resieve update quest msg.ID:%s", msg.id) )
		return
	end
	if newNpc ~= oldNpc then
		self:UpdateNpcQuestState( oldNpc );
	end
	self:UpdateNpcQuestState( newNpc );
	self:UpdateCollectState( quest );
	QuestGuideManager:OnQuestUpdate( quest );
	SkillGuideManager:OnQuestUpdate( quest );
	UIQuestNotice:CheckQuestNotice(quest)
	-- 如果是日环任务，状态变成可交时，弹出交任务领奖面板，因为日环任务没有npc
	if quest:GetState() == QuestConsts.State_CanFinish and quest:GetType() == QuestConsts.Type_Day then
		local multiple = quest:GetMultiple();
		local rewardPanel = multiple > 1 and UIQuestDayMultipleReward or UIQuestDayReward;
		rewardPanel:Open( quest ); -- 打开日环多倍奖励面板
	end
	-- 如果是猎魔任务，状态变成可交时，自动进行下一环
	if quest:GetState() == QuestConsts.State_CanFinish and quest:GetType() == QuestConsts.Type_LieMo then
		local questId = quest:GetId();
		LieMoRewardView:Show(questId, quest:GetShowRewards(), true)
	end
	--如果是历练任务，那么更新历练面板
	if quest:GetType() == QuestConsts.Type_Random then
		if UIHoneView:IsShow() then
			UIHoneView:Show(quest:GetId());
		end
	end
end

--返回删除任务
function QuestController:OnQuestDel(msg)
	self:TestTrace("任务删除")
	self:TestTrace(msg)
	self:TestTrace("任务删除")
	local questId = msg.id;
	local questVO = QuestModel:Remove( questId );
	if not questVO then return end
	local npcId = questVO:GetCurrNPC();
	self:UpdateNpcQuestState( npcId );
	self:UpdateCollectState( questVO , true);
	self:HideMonsterWhenQ(questId);
	self:HideNpcWhenQ(questId);
	self:HideConllectWhenQ(questId);
	questVO:Destroy()
	ClickLog:Send(ClickLog.T_QuestRemove,msg.id);
end

--返回接受任务结果
function QuestController:OnAcceptQuestResult(msg)
	Debug('接受任务反馈:' .. msg.result);
	if msg.result == 0 then
		return;
	end
end

--返回放弃任务结果
function QuestController:OnGiveupQuestResult(msg)
	Debug('放弃任务反馈:' .. msg.result);
	if msg.result == 0 then
		return;
	end
end

--返回完成任务结果
function QuestController:OnFinishQuestResult(msg)
	self:TestTrace("返回完成任务结果")
	self:TestTrace(msg)
	self:TestTrace("返回完成任务结果")
	local questId = msg.id;

	if msg.result == 0 then -- 0为成功
		QuestModel:FinishQuest( questId )
		self:AddFinishedQuestList(questId)
		--剧情的特效
		self:ShowStoryEffect( msg.id )
		MainPlayerController:ChangeMesh(msg.id, 0)
		QuestGuideManager:OnQuestFinish(questId);
		NpcController:AddQuestNpcByQuestId(questId, 0)

		if t_questrandom[questId] then
			QuestModel.randomQuestFinishedCount = QuestModel.randomQuestFinishedCount + 1;
		end
	end
end

-- 剧情特效
local storyEffectStr = 'storyEffect'
function QuestController:ShowStoryEffect(questId)
	local cfg = t_quest[questId]
	if not cfg then return end
	if cfg.storyEffect then  
		local storyEffect = cfg.storyEffect
		if storyEffect and storyEffect ~= "" then 
			local effectTable = GetPoundTable(storyEffect)
			if effectTable and #effectTable > 1 then
				for index, effectVO in pairs(effectTable) do
					local effectCfg = GetCommaTable(effectVO)
					self:PlayStoryEffect(effectCfg)
				end
			else 
				local effectCfg = GetCommaTable(storyEffect)
				self:PlayStoryEffect(effectCfg)
			end
		end
	end
	
	if cfg.jiguan then
		if cfg.jiguan and cfg.jiguan ~= "" then
			local list = split(cfg.jiguan, "#")
			if #list == 2 then
				CPlayerMap.objSceneMap:PlayTaskAnima(list[1],list[2])
			end
		end
	end
	
	if cfg.delEffectId then  
		local delEffect = cfg.delEffectId
		if delEffect and delEffect ~= "" then 
			local effectTable = split(delEffect, '#')
			if effectTable then
				for index, effect in pairs(effectTable) do
					CPlayerMap:GetSceneMap():StopPfxByName(storyEffectStr..effect)
				end
			end
		end
	end
end

local mat =_Matrix3D.new()

function QuestController:PlayStoryEffect(effectCfg)
	if not t_position[toint(effectCfg[2])] then return; end
	local t = split(t_position[toint(effectCfg[2])].pos,"|");
	if #t<=0 then return; end
	for index, posVO in pairs(t) do
		local pos = split(posVO,",");
		local eName = storyEffectStr..effectCfg[1]
		local offsetZ = CPlayerMap:GetSceneMap():getSceneHeight(tonumber(pos[2]), tonumber(pos[3]))
		mat:setTranslation(_Vector3.new(tonumber(pos[2]), tonumber(pos[3]), offsetZ))
		local scenePfx = CPlayerMap:GetSceneMap():PlayerPfxByMat(eName, effectCfg[1], mat)
	end
end

--返回一键完成日环任务结果
function QuestController:OnDailyQuestOneKeyFinish( msg )
	local oneKeyFinishRewardInfo = msg;
	local result = msg.result;
	if result == 0 then -- 成功
		UIQuestDayMultipleOption:Hide();
--		UIQuestDayOneKeyFinish:Open( oneKeyFinishRewardInfo );
		QuestModel:SetDQState( QuestConsts.QuestDailyStateFinish );
	elseif result == 1 then
		FloatManager:AddCenter( StrConfig['quest110'] );
	elseif result == 2 then
		FloatManager:AddCenter( StrConfig['quest162'] );
	end
end

--返回日环任务已完成结果
function QuestController:OnDailyQuestResultRsv( msg )
	local finishInfo = msg;
	QuestModel:SetDailyFinishInfo(finishInfo);
end

-- 日环任务：服务器通知跳环抽取结果
function QuestController:OnQuestSkipResultRsv( msg )
	local skipInfo = msg;
	QuestDayFlow:OnDailyQuestSkipRsv( skipInfo );
end

function QuestController:OnDQDrawNoticeRsv(msg)
	-- WriteLog(LogType.Normal,true,'---------------------------QuestController:OnDQDrawNoticeRsv(msg)')
	local draw = msg.draw == 0;
	QuestDayFlow:OnDQDrawNoticeRsv(draw);
	if draw then -- 如果本轮抽奖：变更日环状态
		local state = QuestConsts.QuestDailyStateDrawing;
		QuestModel:SetDQState(state);
	end
end

--日环任务：服务器通知转盘抽奖结果
-- function QuestController:OnDQDrawResultRsv( msg )
	-- local drawInfo = msg;
	-- QuestDayFlow:OnDQDrawResultRsv( drawInfo.rewardIndex );
	-- UIQuestDayDraw:JudgeToFinishRoll(drawInfo);
-- end

--日环任务：服务器通知升星结果
function QuestController:OnDailyQuestStarResultRsv( msg )
	local result = msg.result;
	if result == 0 then
		QuestModel:SetDailyStarFull();
	elseif result == 1 then -- 钱不够
		FloatManager:AddCenter( StrConfig['quest404'] );
	elseif result == 2 then -- 任务目标不存在
		Debug("the goal of daily quest not find");
	end
end

function QuestController:OnGetDQSkipRewardResult( msg )
	local result = msg.result;
	if result == 0 then
		UIQuestDailySkipReward:Hide();
	end
end

--任务装备：服务器通知任务奖励装备获得提升
function QuestController:OnQuestEquipPromoteRsv( msg )
	-- 任务装备奖励几率升品已去掉--2015年7月4日11:23:27
end
----------------------------------任务传送-------------------------------------


function QuestController:OnTeleportDone( teleportType )
	local quest
	if teleportType == MapConsts.Teleport_QuestFree then
		quest = QuestModel:GetTrunkQuest()
		if not quest then return end
		quest:OnFreeTeleportDone()
		return
	end
	
	if teleportType == MapConsts.Teleport_DailyQuest then
		quest = QuestModel:GetDailyQuest()
	elseif teleportType == MapConsts.Teleport_TrunkQuest then
		quest = QuestModel:GetTrunkQuest()
	elseif teleportType == MapConsts.Teleport_RandomQuest then
		quest = QuestModel:GetRandomQuest()
	elseif teleportType == MapConsts.Teleport_TaoFa then
		quest = QuestModel:GetTaoFaQuest()
	elseif teleportType == MapConsts.Teleport_Agora then
		quest = QuestModel:GetAgoraQuest()
	elseif teleportType == MapConsts.Teleport_Recommend_Hang then
		quest = QuestModel:GetTrunkQuest()
		if not quest then return end
		quest = quest:GetRecommend(QuestConsts.RecommendType_Hang)
	elseif teleportType == MapConsts.Teleport_LieMo then
		quest = QuestModel:GetLieMoQuest()
	elseif teleportType == MapConsts.Teleport_Hang then
		quest = QuestModel:GetHangQuest()
	end
	if not quest then return end
	quest:OnTeleportDone()
end

---------------------------以下处理和任务相关的NPC状态-------------------------------
--更新NPC任务状态
function QuestController:UpdateNpcQuestState(npcId)
	if npcId == nil or npcId == 0 then return end
	local state = self:GetNpcQuestState(npcId);
	NpcController:UpdateQuestIcon(npcId, state);
end

--获取NPC的任务状态(没有返回nil)
function QuestController:GetNpcQuestState(npcId)
	local list = self:GetNpcQuestStateList( npcId );
	return list[1] and list[1]:GetState();
end

--获取NPC的任务状态列表
function QuestController:GetNpcQuestStateList(npcId)
	local list = {};
	local questList = QuestModel:GetAllQuest()
	for _, questVO in pairs( questList ) do
		if questVO:GetCurrNPC() == npcId then
			table.push(list, questVO);
		end
	end
	table.sort(list, self.NpcQuestListSortFuc);
	return list;
end

--任务列表排序
--主线可交付》支线可交付》奇遇可交付》支线的未接取》奇遇未接取》主线的已接取》支线的已接取》奇遇已接取
function QuestController.NpcQuestListSortFuc(A, B)
	local AState = A:GetState();
	local BState = B:GetState();
	--状态相同的按类型排序
	if AState == BState then
		return A:GetType() < B:GetType()
	end
	--状态权重
	local weight = {
		[QuestConsts.State_Finished] = 0,
		[QuestConsts.State_CanFinish] = 0,
		[QuestConsts.State_CannotAccept] = 1,
		[QuestConsts.State_CanAccept] = 1,
		[QuestConsts.State_Going] = 2,
	}
	return weight[AState] < weight[BState]
end

-------------------------------------和任务相关的采集物处理-----------------------------------
--检查是否有该采集物的任务
function QuestController:CheckCollect(id)
	for i,questVO in pairs(QuestModel.questList) do
		if questVO:GetGoalType() == QuestConsts.GoalType_CollectItem then
			for i,goalVO in pairs(questVO.goalList) do
				if not goalVO.GetCollectId then
					print("collectId = ", id, "questID = ", questVO:GetId())
				elseif goalVO:GetCollectId()==id and goalVO:GetCurrCount()<goalVO:GetTotalCount() then
					return true;
				end
			end
		end
	end
	return false;
end

--更新采集物状态
function QuestController:UpdateCollectState(questVO, isdel)
	-- FPrint("更新采集物状态")
	if not questVO then return; end
	if questVO:GetGoalType() ~= QuestConsts.GoalType_CollectItem and questVO:GetGoalType() ~= QuestConsts.GoalType_AgoraCollection then
		return;
	end
	-- FPrint("更新采集物状态1")
	local goalVO = questVO:GetGoal();
	if not goalVO then return; end
	-- FPrint("更新采集物状态2"..goalVO:GetTotalCount()..">="..goalVO:GetCurrCount())
	local state = false
	if isdel then
		state = false 
	else
		state = ( goalVO:GetTotalCount() >= goalVO:GetCurrCount() ) 
	end
	CollectionController:UpdateCollectionState( goalVO:GetCollectId(), state )
end

--初始化需要特殊处理的Npc,Monster
function QuestController:InitNpcMonsterState()
	for id,npcCfg in pairs(t_npc) do
		if npcCfg.defHide and npcCfg.showWhenQ ~= "" then
			local t = split(npcCfg.showWhenQ,",");
			for i,s in ipairs(t) do
				local questId = tonumber(s);
				if not self.QuestNpcMap[questId] then
					self.QuestNpcMap[questId] = {id};
				else
					table.push(self.QuestNpcMap[questId],id);
				end
			end
		end
	end
	--
	for id,monsterCfg in pairs(t_monster) do
		if monsterCfg.defHide and monsterCfg.showWhenQ ~= "" then
			local t = split(monsterCfg.showWhenQ,",");
			for i,s in ipairs(t) do
				local questId = tonumber(s);
				if not self.QuestMonsterMap[questId] then
					self.QuestMonsterMap[questId] = {id};
				else
					table.push(self.QuestMonsterMap[questId],id);
				end
			end
		end
	end
	
	--采集物
	for id,conllectCfg in pairs(t_collection) do
		if conllectCfg.defHide and conllectCfg.showWhenQ ~= "" then
			local t = split(conllectCfg.showWhenQ,",");
			for i,s in ipairs(t) do
				local questId = tonumber(s);
				if not self.QuestConllectMap[questId] then
					self.QuestConllectMap[questId] = {id};
				else
					table.push(self.QuestConllectMap[questId],id);
				end
			end
		end
	end
end

--NPC,Monster默认隐藏,有指定任务时显示,过了指定任务再隐藏
--显示NPC
function QuestController:ShowNpcWhenQ(questId)
	if not self.QuestNpcMap[questId] then return; end
	--从场景中显示
	local npcList = NpcModel:GetNpcList();
	local mapNpcList = NpcModel:GetCurMapNpcList();
	for i,npcId in ipairs(self.QuestNpcMap[questId]) do
		for k,npc in pairs(npcList) do
			if npcId == npc:GetNpcId() then
				if not StoryController:IsStorying() then
					npc:HideSelf(false);
				else
					npc:ShowSelfByStory()
				end
			end
		end
		for k,npc in pairs(mapNpcList) do
			if npcId == npc:GetNpcId() then
				npc:HideSelf(false);	
			end
		end
	end
	--从地图上显示
	for i,npcId in ipairs(self.QuestNpcMap[questId]) do
		MapController:AddNpcById(npcId);
	end
end

--显示采集物
function QuestController:ShowConllectWhenQ(questId)
	if not self.QuestConllectMap[questId] then return; end
	--从场景中显示
	local conllectList = CollectionModel:GetCollectionList()
	for i,conllectId in ipairs(self.QuestConllectMap[questId]) do
		for k,conllect in pairs(conllectList) do
			if conllectId == conllect:GetconfigId() then
				conllect:HideSelf(false);
			end
		end		
	end
end

--显示怪物
function QuestController:ShowMonsterWhenQ(questId)
	if not self.QuestMonsterMap[questId] then return; end
	--从场景中显示
	local monsterList = MonsterModel:GetMonsterList();
	for i,monsterId in ipairs(self.QuestMonsterMap[questId]) do
		for k,monster in pairs(monsterList) do
			if monsterId == monster:GetMonsterId() then
				if not StoryController:IsStorying() then
					monster:HideSelf(false);
				else
					monster:ShowSelfByStory()
				end
			end
		end
	end
	--显示怪区
	for i,monsterId in ipairs(self.QuestMonsterMap[questId]) do
		MapController:AddMonsterAreaById(monsterId);
	end
end

--隐藏怪物
function QuestController:HideMonsterWhenQ(questId)
	if not self.QuestMonsterMap[questId] then return; end
	--从场景中隐藏
	local monsterList = MonsterModel:GetMonsterList();
	for i,monsterId in ipairs(self.QuestMonsterMap[questId]) do
		for k,monster in pairs(monsterList) do
			if monsterId == monster:GetMonsterId() then
				monster:HideSelf(true, true);
			end
		end
	end
	--隐藏怪区
	for i,monsterId in ipairs(self.QuestMonsterMap[questId]) do
		MapController:RemoveMonsterAreaById(monsterId);
	end
end

--隐藏NPC
function QuestController:HideNpcWhenQ(questId)
	if not self.QuestNpcMap[questId] then return; end
	--从场景中隐藏
	local npcList = NpcModel:GetNpcList();
	local mapNpcList = NpcModel:GetCurMapNpcList();
	for i,npcId in ipairs(self.QuestNpcMap[questId]) do
		for k,npc in pairs(npcList) do
			if npcId == npc:GetNpcId() then
				npc:HideSelf(true);
			end
		end
		for k,npc in pairs(mapNpcList) do
			if npcId == npc:GetNpcId() then
				npc:HideSelf(true);
			end
		end
	end
	--从地图中隐藏
	for i,npcId in ipairs(self.QuestNpcMap[questId]) do
		MapController:RemoveNpcById(npcId)
	end
end

--隐藏采集物
function QuestController:HideConllectWhenQ(questId)
	if not self.QuestConllectMap[questId] then return; end
	--从场景中隐藏
	local conllectList = CollectionModel:GetCollectionList()
	for i,conllectId in ipairs(self.QuestConllectMap[questId]) do
		for k,conllect in pairs(conllectList) do
			if conllectId == conllect:GetconfigId() then
				conllect:HideSelf(true);
			end
		end		
	end	
end


--获取NPC是否应该显示
function QuestController:GetNpcNeedShow(id)
	if self:GetNpcIsUnlock(id) then
		return true
	end

	local cfg = t_npc[id];
	if cfg and cfg.defHide then
		local questVO = QuestModel:GetTrunkQuest();
		if not questVO then return false; end
		local t = split(cfg.showWhenQ,",");
		for i,questId in ipairs(t) do
			if tonumber(questId) == questVO:GetId() then
				return true;
			end
		end
		return false;
	end
	return true;
end

--QuestController
function QuestController:GetMonsterNeedShow(id)
	local cfg = t_monster[id];
	if cfg and cfg.defHide then
		local questVO = QuestModel:GetTrunkQuest();
		if not questVO then return false; end
		local t = split(cfg.showWhenQ,",");
		for i,questId in ipairs(t) do
			if tonumber(questId) == questVO:GetId() then
				return true;
			end
		end
		return false;
	end
	return true;
end

--获取采集物是否应该显示
function QuestController:GetConllectNeedShow(id)
	local cfg = t_collection[id];
	if cfg and cfg.defHide then
		local questVO = QuestModel:GetTrunkQuest();
		if not questVO then return false; end
		local t = split(cfg.showWhenQ,",");
		for i,questId in ipairs(t) do
			if tonumber(questId) == questVO:GetId() then
				return true;
			end
		end
		return false;
	end
	return true;
end

---------------------------------需要特殊处理的已完成任务列表----------------------------------

-- 已完成的任务列表
function QuestController:InitFinishedQuestList(idslist)
	self.FinishedQuestMap = {}
	for k,v in pairs(idslist) do
		-- FTrace(idslist, '初始化已完成任务列表')
		table.insert(self.FinishedQuestMap, v.id)
		self:AddUnlockNpc(v.id)
		-- self:ShowUnlockNpcById(npcId)
		self:AddUnlockJiguan(v.id)
	end
end

-- 完成任务
function QuestController:AddFinishedQuestList(questId)
	local cfg = t_quest[questId]
	if not cfg then return end
	
	if cfg.unlockNpc and cfg.unlockNpc ~= "" then
		table.insert(self.FinishedQuestMap, questId)	
		local npcId = self:AddUnlockNpc(questId)
		self:ShowUnlockNpcById(npcId)
	end
	
	if cfg.unlockJiguan and cfg.unlockJiguan ~= "" then
		table.insert(self.FinishedQuestMap, questId)
		self:AddUnlockJiguan(questId)
	end
end

-- 根据地图id保存已解锁npc
function QuestController:AddUnlockNpc(questId)
	local cfg = t_quest[questId]
	if not cfg then return nil end
	-- FTrace(cfg, questId)
	if cfg.unlockNpc and cfg.unlockNpc ~= "" and cfg.unlockNpc~="special" then
		local unLockNpcList = split(cfg.unlockNpc, ",")
		local mapId = toint(unLockNpcList[1])
		if not self.unlockNpcMap[mapId] then
			self.unlockNpcMap[mapId] = {}
		end
		local npcId = toint(unLockNpcList[2])
		table.insert(self.unlockNpcMap[mapId], npcId)
		-- FTrace(self.unlockNpcMap, '已解锁npc')
		return npcId
	end
	
	-- FTrace(self.unlockNpcMap, '已解锁npc')
	return nil
end

-- 根据地图id保存已解锁机关
function QuestController:AddUnlockJiguan(questId)
	local cfg = t_quest[questId]
	if not cfg then return end
	
	if cfg.unlockJiguan and cfg.unlockJiguan ~= "" then
		local unLockJiguanList = split(cfg.unlockJiguan, "#")
		local mapId = toint(unLockJiguanList[1])
		if not self.unlockJiguanMap[mapId] then
			self.unlockJiguanMap[mapId] = {}
		end
		
		for i=2,#unLockJiguanList do
			local jiguanList = split(unLockJiguanList[i], ",")
			if jiguanList[1] and jiguanList[2] then
				local jiguanVO = {}
				jiguanVO.jiguanName = jiguanList[1]
				jiguanVO.jiguanAct = jiguanList[2]
				table.insert(self.unlockJiguanMap[mapId], jiguanVO)
			end
		end
	end
	
	-- FTrace(self.unlockJiguanMap, '已解锁机关')
end

--显示npc
function QuestController:ShowUnlockNpcById(npcId)
	if not npcId then return end
	local npc = NpcModel:GetCurrNpcByNpcId(npcId)
	local mapNpc = NpcModel:GetNpcByNpcId(npcId)
	if not npc then return end
	if not mapNpc then return end
	
	if not StoryController:IsStorying() then
		npc:HideSelf(false);
	else
		npc:ShowSelfByStory()
	end
	mapNpc:HideSelf(false);
	
	--从地图上显示
	MapController:AddNpcById(npcId);
end

-- 得到npc是否解锁
function QuestController:GetNpcIsUnlock(npcId)
	if not self.unlockNpcMap then return false end
	local npcList = self.unlockNpcMap[CPlayerMap:GetCurMapID()]
	if not npcList then return false end
	
	for k,v in pairs (npcList) do
		if npcId == v then
			return true
		end
	end
	return false
end

--显示当前底图中解锁的机关的动作
function QuestController:UnlockCurrentMapJiguan()
	if not self.unlockJiguanMap then return end
	local jiguanList = self.unlockJiguanMap[CPlayerMap:GetCurMapID()]
	if not jiguanList then return false end
	for k,v in pairs (jiguanList) do
		CPlayerMap.objSceneMap:PlayTaskAnima(v.jiguanName,v.jiguanAct,nil,true)
	end
end

--是否显示假兵魂
function QuestController:IsShowSpecailBingHun()
	local get = false;
	local unget = false;
	for _,id in ipairs(self.FinishedQuestMap) do
		if id == QuestConsts.BingHunGet then
			get = true;
		elseif id == QuestConsts.BingHunUnGet then
			unget = true;
		end
	end
	if get and not unget then return true; end
	return false;
end

--是否显示转生
function QuestController:IsShowZhuanShen()
	for _,id in ipairs(self.FinishedQuestMap) do
		if id == QuestConsts.BingHunUnGet then
			return true;
		end
	end
	if MainPlayerModel.humanDetailInfo.eaZhuansheng and MainPlayerModel.humanDetailInfo.eaZhuansheng > 0 then 
		return true;
	end;
	return false;
end

--------------------猎魔 新日环或讨伐相关----------------
--返回一键完成日环任务结果
function QuestController:OnLieMoQuestOneKeyFinish( msg )
	-- trace(msg)
	local oneKeyFinishRewardInfo = msg;
	local result = msg.result;
	if result == 0 then -- 成功
	QuestModel:SetLMState( QuestLieMoConsts.QuestLieMoStateFinish );
	elseif result == 1 then
		FloatManager:AddCenter( StrConfig['quest110'] );
	elseif result == 2 then
		FloatManager:AddCenter( StrConfig['quest162'] );
	end
end

--返回日环任务已完成结果
function QuestController:OnLieMoQuestResultRsv( msg )
	local finishInfo = msg;
	QuestModel:SetLieMoFinishInfo(finishInfo);
end

function QuestController:ReqLieMoOneKeyFinish(multiple)
	local msg = ReqTodayQuestFinishMsg:new();
	msg.multiple = multiple or 1;
	MsgManager:Send( msg );
end