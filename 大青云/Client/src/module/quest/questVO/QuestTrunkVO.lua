--[[
主线任务
2015年5月14日20:38:55
haohu
]]

_G.QuestTrunkVO = setmetatable( {}, {__index = QuestVO} );

QuestTrunkVO.sNumber = 0 -- 本次登录第n个任务
QuestTrunkVO.teleportConfirmUID = nil
QuestTrunkVO.teleportTimerKey = nil
QuestTrunkVO.currentRecommends = {};
--任务类型
function QuestTrunkVO:GetType()
	return QuestConsts.Type_Trunk
end

--获取任务配表
function QuestTrunkVO:GetCfg()
	local cfg = t_quest[self.id]
	if not cfg then
		Debug('error:cannot find trunk quest in table.id:'..self.id);
		return;
	end
	return cfg;
end

function QuestTrunkVO:GetRewards()
	-- return QuestUtil:GetTrunkRewardList( self.id )
end

function QuestTrunkVO:GetShowRewards()
	return QuestUtil:GetTrunkRewardList( self.id )
end

-- 延迟5秒打开结算界面
function QuestTrunkVO:OnPlayTimeDown(dealyTime)
	local num = 5
	local func = function ( )
		if num == 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			if CPlayerMap:GetCurMapID() == QuestConsts.WuhunDungeonMap or CPlayerMap:GetCurMapID() == QuestConsts.WuhunDungeonMapTwo or CPlayerMap:GetCurMapID() == QuestConsts.WuhunDungeonMapThree or 
				CPlayerMap:GetCurMapID() == QuestConsts.WuhunDungeonMapFour or CPlayerMap:GetCurMapID() == QuestConsts.WuhunDungeonMapFive then
				UIWuhunDungeonExit:Show(); 
			end
		end
		if num == 5 then
			UITimeTopSec:Open(2); 
			UIQiZhanDungeonInfo:ONCloseTimer()
		end
		num = num - 1
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,dealyTime)
end

function QuestTrunkVO:OnAdded()
	self:SetSequenceNum()
	self:SetQuestChapter()
	self:TryFreeTeleport()
	local questId = self.id
	CPlayerMap:SetCamera(questId)
	MainPlayerController:ChangeMesh(questId, 1)
	NpcController:AddQuestNpcByQuestId(questId, 1)
	--兽魄副本
	 -- WriteLog(LogType.Normal,true,'-------------houxudong',questId,CPlayerMap:GetCurMapID())
	--第一个独立副本
	if questId == QuestConsts.ExitWuhunDungeonQuest then
		local currentMapId = CPlayerMap:GetCurMapID()
		if currentMapId == QuestConsts.WuhunDungeonMap then
			-- local openDungeonFirst = function()
				self:OnPlayTimeDown(1000)
			-- end
			-- TimerManager:RegisterTimer( openDungeonFirst, 5000, 1 )
		end
	end

	--第二个独立副本
	if questId == QuestConsts.ExitWuhunDungeonQuestTwo then
		local currentMapId = CPlayerMap:GetCurMapID()
		if currentMapId == QuestConsts.WuhunDungeonMapTwo then
			self:OnPlayTimeDown(1000)
		end
	end

	--第三个独立副本
	if questId == QuestConsts.ExitWuhunDungeonQuestThree then
		local currentMapId = CPlayerMap:GetCurMapID()
		if currentMapId == QuestConsts.WuhunDungeonMapThree then
			self:OnPlayTimeDown(1000)
		end
	end
	
	--第四个独立副本
	if questId == QuestConsts.ExitWuhunDungeonQuestFour then
		local currentMapId = CPlayerMap:GetCurMapID()
		if currentMapId == QuestConsts.WuhunDungeonMapFour then
			self:OnPlayTimeDown(1000)
		end
	end
	
	--第五个独立副本
	if questId == QuestConsts.ExitWuhunDungeonQuestFive then
		local currentMapId = CPlayerMap:GetCurMapID()
		if currentMapId == QuestConsts.WuhunDungeonMapFive then
			self:OnPlayTimeDown(1000)
		end
	end
	
end

function QuestTrunkVO:SetSequenceNum()
	self.sNumber = QuestModel:CountTrunk()
end

function QuestTrunkVO:TryFreeTeleport()
	-- 是上线收到的第一个任务
	if self.sNumber == 1 then
		return
	end
	-- 断档任务不传
	local state = self:GetState()
	if state == QuestConsts.State_CannotAccept then
		return
	end
	-- 未配地图的不传
	local cfg = self:GetCfg()
	local teleportMap = cfg.teleportMap --任务要去的地图
	if teleportMap == nil or teleportMap == 0 then 
		return
	end
	-- self:OpenQuestFreeTeleportConfirm( teleportMap )
	local teleportType = MapConsts.Teleport_QuestFree
	MapController:Teleport( teleportType, nil, teleportMap )
	Debug("选择是否传送,停止引导")
end

function QuestTrunkVO:SetQuestChapter()
	local cfg = self:GetCfg();
	if not cfg then return end;
	local chapter = cfg.chapter;
	if not chapter then
		Error( string.format( "cannot find quest chapter config in t_quest, quest id:%s", self:GetId() ) );
	end
	local index = cfg.chapterIndex;
	if not index then
		Error( string.format( "cannot find quest chapterIndex config in t_quest, quest id:%s", self:GetId() ) );
	end
	QuestModel:SetChapter( chapter, index );
end

function QuestTrunkVO:OnFinished()
	
end

--[[
-- function QuestTrunkVO:OpenQuestFreeTeleportConfirm( teleportMap )
-- 	QuestGuideManager:StopGuide()
-- 	local confirmFunc = function()
-- 		local teleportType = MapConsts.Teleport_QuestFree
-- 		MapController:Teleport( teleportType, nil, teleportMap )
-- 		self:CloseTeleportConfirm()
-- 		self:StopTeleportTimer()
-- 	end
-- 	local cancelFunc = function()
-- 		QuestGuideManager:RecoverGuide()
-- 		self:CloseTeleportConfirm()
-- 		self:StopTeleportTimer()
-- 	end
	-- self.teleportConfirmUID = UIConfirm:Open( StrConfig['quest801'], confirmFunc, cancelFunc )
	-- self.teleportTimerKey = TimerManager:RegisterTimer( cancelFunc, 15000, 1)
-- end

-- function QuestTrunkVO:CloseTeleportConfirm()
	-- if self.teleportConfirmUID then
	-- 	UIConfirm:Close(self.teleportConfirmUID)
	-- 	self.teleportConfirmUID = nil
	-- end
-- end

-- function QuestTrunkVO:StopTeleportTimer()
	-- if self.teleportTimerKey then
	-- 	TimerManager:UnRegisterTimer(self.teleportTimerKey)
	-- 	self.teleportTimerKey = nil
	-- end
-- end
]]

function QuestTrunkVO:OnFreeTeleportDone()
	QuestController:SetSceneChangeCallBack( function()
		Debug("传送完成,恢复引导")
		QuestGuideManager:RecoverGuide()
	end )
end

--获取任务当前的NPC ID
function QuestTrunkVO:GetCurrNPC()
	local cfg = self:GetCfg();
	if not cfg then return; end
	if self.state == QuestConsts.State_UnAccept then
		return cfg.acceptNpc;
	else
		return cfg.finishNpc;
	end
end

--获取任务接取点
function QuestTrunkVO:GetAcceptPoint()
	local cfg = self:GetCfg();
	if not cfg then return; end
	local t = split(cfg.acceptLink,'#');
	if #t > 1 then
		return QuestUtil:GetQuestPos(tonumber(t[2]))
	end
end

--获取任务完成点
function QuestTrunkVO:GetFinishPoint()
	local cfg = self:GetCfg();
	if not cfg then return; end
	local t = split(cfg.finishLink,'#');
	if #t > 1 then
		return QuestUtil:GetQuestPos(tonumber(t[2]))
	end
end

-- 接受任务
function QuestTrunkVO:Accept()
	QuestController:DoRunToNpc( self:GetAcceptPoint(), self:GetCurrNPC() );
	MainPlayerController:GetPlayer():DoNpcGuildMoveToPos(self:GetAcceptPoint());
end

-- 交任务
function QuestTrunkVO:Submit()
	QuestController:DoRunToNpc( self:GetFinishPoint(), self:GetCurrNPC() );
	MainPlayerController:GetPlayer():DoNpcGuildMoveToPos(self:GetFinishPoint());
end

-- 发送接受任务
function QuestTrunkVO:SendAccept()
	local questState = self:GetState();
	if questState == QuestConsts.State_CanAccept then
		QuestController:AcceptQuest(self.id);
		return true;
	end
	return false
end

-- 发送交任务
function QuestTrunkVO:SendSubmit()
	local questState = self:GetState();
	if questState == QuestConsts.State_CanFinish then
		QuestController:FinishQuest(self.id);
		return true;
	end
	return false
end

--npc语音
function QuestTrunkVO:PlaySound()
	local cfg = self:GetCfg()
	local voice = cfg.questsound
	if not voice then return end
	local t = split(voice, "#")
	local sound = tonumber( t[math.random(1, #t)] )
	if sound then
		SoundManager:PlaySfx( sound , true)
		return true
	end
	return false
end

-- 是否可传送
function QuestTrunkVO:CanTeleport()
	local state = self:GetState()
	if state == QuestConsts.State_CanAccept then
		return true
	elseif state == QuestConsts.State_CanFinish then
		return true
	elseif state == QuestConsts.State_Going then
		local goal = self:GetGoal()
		return goal ~= nil and goal:CanTeleport()
	end
	return false
end

function QuestTrunkVO:GetTeleportType()
	return MapConsts.Teleport_TrunkQuest -- 主线传送
end

function QuestTrunkVO:IsShowNode()
	local state = self:GetState()
	-- 断档且有日环任务时，不显示主线节点
	--[[
	--根据策划的修改，主线任务不可接的时候还是显示，所以下面的注释掉 yanghongbin/jianghaoran   2016-7-22
	if state == QuestConsts.State_CannotAccept then -- 主线断档时，根据日环状态判断是否显示主线追踪树节点
		local dailyQuestState = QuestModel:GetDQState()
		if dailyQuestState == QuestConsts.QuestDailyStateGoing or --日环任务进行中
			dailyQuestState == QuestConsts.QuestDailyStateDrawing then --日环任务抽奖中
			return false
		end
	end
	]]
	return true
end

-- 独有节点数组(在内容节点之下)
function QuestTrunkVO:CreateLowerNodes()
	-- 任务不可接时增加显示推荐挂机节点
	local recommendNodes = {}
	if self:GetState() == QuestConsts.State_CannotAccept then
		recommendNodes = self:GetRecommendNodes()
	end

	return recommendNodes
end

-- 获取任务断档推荐节点
function QuestTrunkVO:GetRecommendNodes()
	self.currentRecommends = {};
	local nodes = {}
	local cfg = self:GetCfg()
	if not cfg then return end
	local recommendTab = split( cfg.cannotAcceptRecommend, "#" )
	local first = QuestRecommendFactory:AutoCreateRecommend()
	if first then
		local node = QuestNodeRecommend:new()
		node:SetContent( first )
		table.push( nodes, node )
		first:OnAdded()
		table.push( self.currentRecommends, first);
		return nodes;
	else
		for _, recommendStr in ipairs( recommendTab ) do
			local recommend = QuestRecommendFactory:CreateRecommend( recommendStr )
			-- 如果不止一条推荐内容，那么隐藏掉推荐挂机。
			--[[
			--策划说去掉这个机制 不显示推荐挂机  yanghongbin/jianghaoran 2016-7-25
			if recommend:GetType() == QuestConsts.RecommendType_Hang and #nodes > 1 then
				recommend.isAvailable = false
			end
			]]

			if recommend and recommend:IsAvailable() then
				local node = QuestNodeRecommend:new()
				node:SetContent( recommend )
				table.push( nodes, node )
				recommend:OnAdded()
				table.push( self.currentRecommends, recommend);
			end
		end
		return nodes
	end

end

function QuestTrunkVO:GetRecommend(type)
	if not self.currentRecommends then return; end
	for k, v in pairs(self.currentRecommends) do
		if v:GetType() == type then
			return v;
		end
	end
end

--获取快捷任务任务标题文本
function QuestTrunkVO:GetTitleLabel()
	local state = self:GetState();
	local cfg = self:GetCfg();
	local titleFormat = "<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>"; -- 中间的空格是留给任务图标的
	local stateFormat = "<font size='"..QuestColor.TITLE_FONTSIZE.."' color='%s'>%s</font>"
	--local txtTitle = string.format( titleFormat, cfg.minLevel, cfg.name ); --根据策划需求，不显示主线任务等级 yanghongbin/jianghaoran/2016-7-22
	local txtTitle = string.format( titleFormat, cfg.name );
	local labelStateColor = QuestConsts:GetStateLabelColor(state);
	local labelState = self:GetTrunkStateLabel(state);
	local txtState = string.format( stateFormat, labelStateColor, labelState );
	return string.format( "%s%s", txtTitle, txtState );
end

function QuestTrunkVO:GetTrunkStateLabel(state)
	if state == QuestConsts.State_CannotAccept then
		local cfg = self:GetCfg();
		return string.format(StrConfig["quest917"], cfg.minLevel);
	else
		return QuestConsts:GetStateLabel(state);
	end
end

-- 对应npc对话面板显示谈话内容
function QuestTrunkVO:GetNpcTalk()
	local cfg = self:GetCfg()
	local questState  = self:GetState();
	local npcTalk     = cfg.acceptTalk
	local btnLabel    = StrConfig['quest6']
	local btnDisabled = true
	if questState == QuestConsts.State_Going then
		btnLabel    = StrConfig['quest7']
		btnDisabled = true
		npcTalk     = cfg.goingTalk
	elseif questState == QuestConsts.State_CanFinish then
		btnLabel    = StrConfig['quest7']
		btnDisabled = false
		npcTalk     = cfg.finishTalk
	elseif questState == QuestConsts.State_CanAccept then
		btnLabel    = StrConfig['quest6']
		btnDisabled = false
		npcTalk     = cfg.acceptTalk
	end
	return npcTalk, btnLabel, btnDisabled
end

function QuestTrunkVO:ShowTips()
	local questId   = self:GetId()
	local questCfg  = self:GetCfg()
	local rewardList = QuestUtil:GetTrunkRewardList(questId);
	UIQuestTips:Show(questCfg.name, rewardList);
end
function QuestTrunkVO:OnStateChange()
	if self:GetState() == QuestConsts.State_CanAccept then
		UIMainQuestTrunk:PlayNewTrunkEffect();
	end

	if not MainPlayerController:GetPlayer() then return; end

	local questCfg  = self:GetCfg()
	local questState  = self:GetState();
	local npcGuildContent = "";
	if questState == QuestConsts.State_CanAccept then
		npcGuildContent = questCfg.npcTalk_1;
	elseif questState == QuestConsts.State_Going then
		npcGuildContent = questCfg.npcTalk_2;
	elseif questState == QuestConsts.State_CanFinish then
		npcGuildContent = questCfg.npcTalk_3;
	end
	MainPlayerController:GetPlayer():NpcGuildTalk(npcGuildContent, toint(questCfg.talkTime));
end

--销毁
function QuestTrunkVO:Destroy()
	-- self:CloseTeleportConfirm()
	-- self:StopTeleportTimer()
	for i,goalVO in ipairs(self.goalList) do
		goalVO:Destroy()
	end
	self.__index = nil
	self.goalList = nil
	self.currentRecommends = nil;
end

function QuestTrunkVO:OnTitleClick()
	if not QuestConsts.IsOpenTrunk then	return; end
	UIQuest:Open( self:GetType())
end