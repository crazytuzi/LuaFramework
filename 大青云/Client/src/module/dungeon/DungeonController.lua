_G.DungeonController = setmetatable({},{__index=IController})

DungeonController.name = "DungeonController"
-- 换线后回调函数
DungeonController.afterLineChange = nil
-- 换场景后回调函数
DungeonController.afterSceneChange = nil

function DungeonController:Create()
	MsgManager:RegisterCallBack( MsgType.SC_StoryStartResult, self, self.OnStoryStartResult )-- 服务端通知: 播放剧情返回结果
	MsgManager:RegisterCallBack( MsgType.SC_StoryStep, self, self.OnStoryStepResult )-- 服务端通知: 剧情步骤
	MsgManager:RegisterCallBack( MsgType.SC_EnterDungeonResult, self, self.OnEnterDungeonResult )-- 服务端通知: 进入副本
	MsgManager:RegisterCallBack( MsgType.SC_LeaveDungeonResult, self, self.OnLeaveDungeonResult )-- 服务端通知: 强制离开副本
	MsgManager:RegisterCallBack( MsgType.SC_StoryEndResult, self, self.OnStoryEndResult )-- 服务端通知: 完成副本
	MsgManager:RegisterCallBack( MsgType.WC_TeamDungeonUpdate, self, self.OnTeamDungeonUpdate )-- 服务端通知: 更新组队副本成员列表
	MsgManager:RegisterCallBack( MsgType.SC_DungeonTeamDamage, self, self.OnDungeonTeamDamage )-- 服务端通知: 组队副本伤害统计

	MsgManager:RegisterCallBack( MsgType.SC_DungeonGroupUpdate, self, self.OnDungeonGroupUpdate )-- 服务端通知: 更新副本组列表(同一地图不同难度为一组)
	MsgManager:RegisterCallBack( MsgType.SC_DungeonCountDown, self, self.OnDungeonCountDownStart )-- 服务端通知: 开始副本关闭倒计时
	MsgManager:RegisterCallBack( MsgType.SC_DungeonPassResult, self, self.OnDungeonPassResultRsv )-- 服务端通知: 副本过关结果
	MsgManager:RegisterCallBack( MsgType.SC_DungeonRandomEvent, self, self.OnDungeonRandomEventRsv )-- 服务端通知: 副本随机事件
	MsgManager:RegisterCallBack( MsgType.SC_RandomBossStar, self, self.OnRandomBossStarRsv )-- 服务端通知: 返回boss星级结果
	MsgManager:RegisterCallBack( MsgType.SC_DungeonRank, self, self.OnDungeonRankRsv )-- 服务端通知: 返回副本神话难度排行结果
	MsgManager:RegisterCallBack( MsgType.SC_MonsterSpawn, self, self.OnDungeonMonsterSpawn)--副本杀怪
	
	CControlBase:RegControl(self, false)
	DungeonModel:Init();
	DungeonModel:InitInterDungeon();
end

function DungeonController.OnMouseDown(nButton,nXPos,nYPos)
	--FPrint('中断')
	if UIDungeonStory:IsShow() then
		UIDungeonStory:ResetCheckState()
	end
end

function DungeonController.OnKeyDown(dwKeyCode)  
	--FPrint('中断')
	if UIDungeonStory:IsShow() then
		UIDungeonStory:ResetCheckState()
	end
end

--切换场景完成后的回调
function DungeonController:OnChangeSceneMap()
	if self.afterSceneChange then
		self.afterSceneChange()
		self.afterSceneChange = nil
	end
end

function DungeonController:OnLineChange()
	if self.afterLineChange then
		self.afterLineChange()
		self.afterLineChange = nil
	end
end

function DungeonController:OnLineChangeFail()
	if self.afterLineChange then
		self.afterLineChange = nil
	end
	Debug( "换线失败" )
end

---------------------------------服务器返回----------------------------------------------------------------------------

-- 服务端通知: 播放剧情返回结果
function DungeonController:OnStoryStartResult(msg)
	FTrace(msg, '服务端通知: 播放剧情返回结果')
	if msg.type and msg.type == 1 then
		StoryController:ShowStoryDialog(msg.storyId)
	elseif msg.type and msg.type == 3 then
		StoryController:PlayNpcPatrolStory(msg.storyId)
	else
		StoryController:StoryStartMsg(msg.storyId, function()
			self:ReqStoryPlayEnd(msg.id, msg.type)
		end)
	end
end

-- 服务端通知: 剧情副本	剧情步骤
function DungeonController:OnStoryStepResult(msg)
	FTrace(msg, '服务端通知: 剧情副本	剧情步骤')
	DungeonModel.currentStep = msg.stepId
	DungeonController:CurrStepChange()
	UIDungeonStory:UpdateStepInfo(msg.dungeonId, msg.stepId)
end

-- 服务端通知: 剧情副本	进入副本
function DungeonController:OnEnterDungeonResult(msg)
	-- WriteLog(LogType.Normal,true,'---------------------收到服务器消息',result)
	local result = msg.result
	if result == 0 then
		UIDungeonMain:Hide()
		UIDungeonMain:OnBtnCloseClick()
		UIDungeon:Hide()
		UIDungeonTeamPrepare:Hide();
		UIDungeonCountDown:Hide();
		if TeamModel:IsInTeam() and TeamModel:GetMemberNum() > 1 then
			UIDungeonTeamDamage:Show();
		end
		DungeonModel.isInDungeon = true
		DungeonModel.currentDungeonId = msg.dungeonId;
		DungeonModel.currentStep = msg.stepId
		DungeonController:CurrStepChange()
		FTrace(msg, '服务端通知: 剧情副本	进入副本')
		UIDungeonStory:Open( msg.dungeonId, msg.stepId, msg.dungeonTime, msg.Id, msg.star )
		self.bIsUsable = true
	elseif result == -2 then
		FloatManager:AddCenter( StrConfig['dungeon7'] )
	elseif result == -3 then
		FloatManager:AddCenter( StrConfig['dungeon8'] )
	elseif result == -4 then
		FloatManager:AddCenter( StrConfig['map207'] )
	else
		Debug( string.format( "进入副本失败.错误码：%s", result ) )
	end
end

-- 服务端通知: 剧情副本	强制退出
function DungeonController:OnLeaveDungeonResult(msg)
	FTrace(msg,'服务端通知: 剧情副本	强制退出')
	self:OnLeaveDungeon();
end

-- 服务端通知: 完成副本
function DungeonController:OnStoryEndResult(msg)
	FTrace(msg,'服务端通知: 完成副本')
	self:OnLeaveDungeon();
end

function DungeonController:OnLeaveDungeon()
	DungeonModel.isInDungeon = false
	DungeonModel.currentDungeonId = nil;
	UIDungeonStory:Hide()
	UIDungeonEvent:Hide()
	UIDungeonTeamDamage:Hide();
	UIDungeonDialogBox:Hide();
	self.afterSceneChange = function() MainMenuController:UnhideRight() end
	self.bIsUsable = false
	self:ReqDungeonUpdate();
end

-- 服务端通知: 更新(未打开面板则打开)组队副本列表
function DungeonController:OnTeamDungeonUpdate(msg)
	local dungeonTeamInfo = msg
	-- if QiZhanDungeonUtil:GetInQiZhanDungeon() then
		-- DungeonController:ReqReplyTeamDungeon(1);
		-- return
	-- end
	UIDungeonTeamPrepare:TryOpen(dungeonTeamInfo)
end

-- 服务端返回结果:组队副本伤害统计
function DungeonController:OnDungeonTeamDamage(msg)
	local damageInfo = msg.damageInfo;
	UIDungeonTeamDamage:Refresh(damageInfo);
end

-- 更新副本组列表
function DungeonController:OnDungeonGroupUpdate(msg)
	DungeonModel:UpdateDungeonGroupList( msg.dungeonGroupList,msg.vipTimes)
end

function DungeonController:OnDungeonCountDownStart(msg)
	-- UIDungeonCountDown:Open( msg.tid, msg.time, msg.line )   --关闭副本倒计时功能
end

function DungeonController:OnDungeonPassResultRsv(msg)
	self:OnPlayTimeDown(1000,msg)
end

function DungeonController:OnPlayTimeDown(dealyTime,msg)
	local num = 5
	local func = function ( )
		if num == 0 then
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
				local result = msg.result
				local openResultUI
				if result == DungeonConsts.Pass then   --- pass == 1 通过
					SoundManager:PlaySfx(2019); -- sfx
					openResultUI = function() UIDungeonSuccess:Open( msg.tid,msg.time) end
				elseif result == DungeonConsts.Failed then
					SoundManager:PlaySfx(2020); -- sfx
					openResultUI = function() UIDungeonFail:Show() end
				end
				openResultUI()
				UIDungeonStory:Hide()   
		end
		if num == 5 then
			UITimeTopSec:Open(2);  
		end
		num = num - 1
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,dealyTime)
end

function DungeonController:OnDungeonRandomEventRsv(msg)
	local eventInfo = msg;
	UIDungeonEvent:HandleEvent(eventInfo);
end

-- 返回boss星级结果
function DungeonController:OnRandomBossStarRsv(msg)
	FTrace(msg,'服务端通知: 返回boss变异星级结果')
	Notifier:sendNotification(NotifyConsts.DungeonBossBianyi, {bianyiId=msg.Id,bianyiStar=msg.star});
end

-- 返回副本难度排行结果
function DungeonController:OnDungeonRankRsv(msg)
	local dungeonId = msg.dungeonId;
	local rankList = msg.rankList;
	local championIcon = msg.icon;
	DungeonModel:SetRank( dungeonId, rankList, championIcon );
end

---------------------------------客户端请求----------------------------------------------------------------------------
	
-- 剧情副本	请求进入副本
-- @flag 1：从新开始，2：继续上次一中途退出的副本,默认为1
function DungeonController:ReqEnterDungeon(dungeonId, flag)
	-- WriteLog(LogType.Normal,true,'---------------------进入副本',dungeonId)
	print("------进入副本",dungeonId)
	local msg = ReqEnterDungeonMsg:new()
	msg.dungeonId = dungeonId
	msg.flag = flag or 1
	MsgManager:Send(msg)
end

-- 剧情副本	请求退出副本
function DungeonController:ReqLeaveDungeon(dungeonId)
	FPrint('剧情副本	请求退出副本')
	local msg = ReqCS_LeaveDungeon:new()
	msg.dungeonId = dungeonId
	FTrace(msg)
	MsgManager:Send(msg)
end

-- 请求剧情播放完成
function DungeonController:ReqStoryPlayEnd(storyId, storytype)
	FPrint('请求剧情播放完成')
	local msg = ReqStoryEndMsg:new()
	msg.id = storyId
	msg.type = storytype
	FTrace(msg)
	MsgManager:Send(msg)
	--debug.debug()
	--转生mv播放完毕，执行自动逻辑
	ZhuanContoller:StoryPlayOver()
end

-- 剧情副本	请求副本npc对话播放完成
function DungeonController:ReqDungeonNpCTalkEnd()
	FPrint('剧情副本	请求副本npc对话播放完成stepID:'..UIDungeonStory.stepId)
	local msg = ReqDungeonNpcTalkEndMsg:new()
	msg.step = UIDungeonStory.stepId
	MsgManager:Send(msg)
end

--组队副本确认是否同意加入
function DungeonController:ReqReplyTeamDungeon(reply)
	local msg = ReqReplyTeamDungeonMsg:new()
	msg.reply = reply
	MsgManager:Send(msg)
end

--请求更新副本信息
function DungeonController:ReqDungeonUpdate()
	MsgManager:Send( ReqDungeonGroupMsg:new() )
end

--放弃副本(副本进行中退出后倒计时，点击确认放弃)
function DungeonController:ReqAbstainDungeon( dungeonId )
	local msg = ReqDungeonAbstainMsg:new()
	msg.tid = dungeonId
	MsgManager:Send(msg)
end

--领奖
function DungeonController:ReqGetAward()
	MsgManager:Send( ReqDungeonGetAwardMsg:new() )
end

--boss变异
function DungeonController:ReqBossBianyi(bossId)
	local msg = ReqBossFallStarMsg:new()
	msg.Id = bossId
	FTrace(msg,'请求boss变异')
	MsgManager:Send(msg)
end

-- 请求副本难度排行
function DungeonController:ReqDungeonRank(dungeonId)
	local msg = ReqDungeonRankMsg:new();
	msg.dungeonId = dungeonId;
	MsgManager:Send(msg)
end
----------------------------指引------------------------------------------www

--寻路
function DungeonController:goToTarget(stepCfg)
	local posId = toint(self:GetGoal(stepCfg))
	local point = QuestUtil:GetQuestPos(posId)
	if not point then return end
	
	local completeFuc = function()
		if stepCfg.auto_fight and stepCfg.auto_fight == 1 then
			AutoBattleController:OpenAutoBattle()
		end
	end
	if not MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc) then
		FPrint('FFFFFFFFFFFFFFF')
	end
end

--杀怪
function DungeonController:goToKillMonster(stepCfg)
	local goalsList = split(self:GetGoal(stepCfg),",")
	if not goalsList then return end
	if not goalsList[3] then return end
	local point = QuestUtil:GetQuestPos(toint(goalsList[3]))
	if not point then return end
	--FPrint('杀怪')
	local completeFuc = function()
		AutoBattleController:OpenAutoBattle()
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc)
end

--对话
function DungeonController:goToTalk(stepCfg)
	local goalsList = split(self:GetGoal(stepCfg),",")
	if not goalsList then return end
	if not goalsList[2] then return end
	local point = QuestUtil:GetQuestPos(toint(goalsList[2]))
	local acceptNpcId = toint(goalsList[1])
	if not point then return end
	--FPrint('对话')
	local completeFuc = function()
		--FPrint('对话寻路完成')
		self:AutoAcceptQuest(acceptNpcId, stepCfg.id)
	end
	
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc)
end

--寻路到NPC后自动打开任务对话
function DungeonController:AutoAcceptQuest(npcId, stepId)
	if not UIDungeonDialogBox:IsShow() then
		UIDungeonDialogBox:Open(npcId, stepId)
	end
end

--采集
function DungeonController:gotoCollect(stepCfg)
	local goalParams = split(self:GetGoal(stepCfg),",")--任务目标
	-- SpiritsUtil:Trace(goalParams)
	if not goalParams then return end
	-- SpiritsUtil:Print(goalParams[3])
	-- WriteLog(LogType.Normal,true,'-------------采集位置',goalParams[1],goalParams[2],goalParams[3])
	if not goalParams[3] then return end
	local point = QuestUtil:GetQuestPos(toint(goalParams[3]))
	-- WriteLog(LogType.Normal,true,'-------------采集point',point)
	-- SpiritsUtil:Trace(point)
	if not point then return end
	--FPrint('采集')
	local completeFuc = function()
		CollectionController:Collect(toint(goalParams[1]))
	end
	MainPlayerController:DoAutoRun(point.mapId,_Vector3.new(point.x,point.y,0),completeFuc)
end

--使用物品
function DungeonController:useItem(stepCfg)
	--FPrint('使用物品')
	BagController:UseItemByTid(BagConsts.BagType_Bag,toint(self:GetGoal(stepCfg)),1)
end

function DungeonController:GetGoal(stepCfg)
	local diffi = DungeonModel:GetDungeonDifficulty()
	local list = split(stepCfg.goals1, "#")
	if diffi then
		return list[diffi] --stepCfg['goals'..diffi]
	else
		return list[1]
	end
end

function DungeonController:CurrStepChange()
	DungeonController:UpdateNpcQuestState()
	DungeonController:UpdateCollectionState()
end

function DungeonController:UpdateNpcQuestState()
	local stepId = DungeonModel.currentStep
	if not stepId then
		NpcController:SetCurrDungeonNpcId(0)
		return
	end
	local cfg = t_dunstep[stepId]
	if not cfg then
		NpcController:SetCurrDungeonNpcId(0)
		return
	end
	if cfg.type == 3 then
		local npcCfg = split(cfg.goals1, ",")
		local npcConfigId = tonumber(npcCfg[1])
		NpcController:SetCurrDungeonNpcId(npcConfigId)
	else
		NpcController:SetCurrDungeonNpcId(0)
	end
end

function DungeonController:UpdateCollectionState()
	local stepId = DungeonModel.currentStep
	if not stepId then
		return
	end
	local cfg = t_dunstep[stepId]
	if not cfg then
		return
	end
	if cfg.type == 4 then
		local collectionCfg = split(cfg.goals1, ",")
		local collectionConfigId = tonumber(collectionCfg[1])
		CollectionController:UpdateCollectionState(collectionConfigId, true)
	end
end
	

function DungeonController:CheckCollect(configId)
	local stepId = DungeonModel.currentStep
	if not stepId then
		return false
	end
	local cfg = t_dunstep[stepId]
	if not cfg then
		return false
	end
	if cfg.type == 4 then
		local collectionCfg = split(cfg.goals1, ",")
		local collectionConfigId = tonumber(collectionCfg[1])
		if collectionConfigId == configId then
			return true
		end
	end
	return false
end

function DungeonController:OnDungeonMonsterSpawn(msg)
	--[[if not DungeonModel.IsInDungeon() then
		return;
	end--]]
	
	if not CPlayerMap.objSceneMap then
		return;
	end
	
	--临时用地图配置ID
	local config = t_map[CPlayerMap:GetCurMapID()];
	if not config then
		return;
	end
	
	local param = config.monster_effect;
	if not param then
		return;
	end
	
	local ps = GetPoundTable(param);
	if not ps or #ps==0 then
		return;
	end
	
	for i,ips in ipairs(ps) do
		local effect =  GetVerticalTable(ips);
		local tid = toint(effect[1]);
		if tid == msg.tid then
			CPlayerMap.objSceneMap:PlayPfxByMarker(effect[3],effect[2],effect[3]);
		end
	end
end

