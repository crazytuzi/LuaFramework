--[[
任务VO
lizhuangzhuang
2014年8月8日17:46:52
]]

_G.QuestVO = {};

--任务目标映射Map
QuestVO.GoalClassMap = {
	[QuestConsts.GoalType_Talk]               = TalkQuestGoalVO,
	[QuestConsts.GoalType_KillMonster]        = MonsterQuestGoalVO,
	[QuestConsts.GoalType_KillMonsterCollect] = MonsterCollectQuestGoalVO,
	[QuestConsts.GoalType_CollectItem]        = CollectQuestGoalVO,
	[QuestConsts.GoalType_GetItem]            = GetItemQuestGoalVO,
	[QuestConsts.GoalType_PutOnEquip]         = PutOnEquipGoalVO,
	[QuestConsts.GoalType_UseItem]            = UseItemQuestGoalVO,
	[QuestConsts.GoalType_SendMail]           = SendMailQuestGoalVO,
	[QuestConsts.GoalType_GoPos]              = GoPosQuestGoalVO,
	[QuestConsts.GoalType_FuBen]              = FuBenQuestGoalVO,
	[QuestConsts.GoalType_Potral]             = PortalQuestGoalVO,
	[QuestConsts.GoalType_Click]              = ClickGoalVO,
	[QuestConsts.GoalType_SpecialMonster]     = MonsterSpecialGoalVO,
	[QuestConsts.GoalType_CompleteDungenon]   = CompleteDungenonGoalVO,
	-- 等级任务
	[QuestConsts.GoalType_Dungeon]            = DungeonGoalVO,
	[QuestConsts.GoalType_Activity]           = ActivityGoalVO,
	[QuestConsts.GoalType_Babel]              = BabelGoalVO,
	[QuestConsts.GoalType_TimeDugeon]         = TimeDungeonGoalVO,
	[QuestConsts.GoalType_ExDungeon]          = ExDungeonGoalVO,
	[QuestConsts.GoalType_RewardQuest]        = RewardQuestGoalVO,
	[QuestConsts.GoalType_EquipPro]           = EquipProductGoalVO,
	[QuestConsts.GoalType_Strengthen]         = StrengthenGoalVO,
	[QuestConsts.GoalType_MountLvlUp]         = MountLvlUpGoalVO,
	[QuestConsts.GoalType_SpiritsLvlUp]       = SpiritsLvlUpGoalVO,
	[QuestConsts.GoalType_MagicWeaponLvlUp]   = MagicWeaponLvlUpGoalVO,
	-- [QuestConsts.GoalType_RealmInject]        = RealmInjectGoalVO,
	[QuestConsts.GoalType_SkillLvlUp]         = SkillLvlUpGoalVO,
	[QuestConsts.GoalType_SuperPeel]          = SuperPeelGoalVO,
	[QuestConsts.GoalType_SuperInlay]         = SuperInlayGoalVO,
	[QuestConsts.GoalType_SuperAwaken]        = SuperAwakenGoalVO,
	[QuestConsts.GoalType_GemLvlUp]           = GemLvlUpGoalVO,
	[QuestConsts.GoalType_EquipRefin]         = EquipRefinGoalVO,
	[QuestConsts.GoalType_FeedLingshou]       = FeedLingshouGoalVO,
	[QuestConsts.GoalType_EquipBuild]         = EquipBuildGoalVO,
	[QuestConsts.GoalType_DominateRoad]       = DominateRoadGoalVO,
	[QuestConsts.GoalType_WaterDugeon]        = WaterDungeonGoalVO,
	[QuestConsts.GoalType_DailyTurn]		  = DailyTurnGoalVO,
	[QuestConsts.GoalType_AllRefinTo]		  = AllRefinToGoalVO,
	[QuestConsts.GoalType_RandomQuest]		  = RandomQuestGoalVO,
	[QuestConsts.GoalType_BabelFloor]		  = BabelFloorGoalVO,
	[QuestConsts.GoalType_WaBaoTimes]		  = WaBaoTimesGoalVO,
	[QuestConsts.GoalType_SkillLvlTo]		  = SkillLvlToGoalVO,
	[QuestConsts.GoalType_SkillAllLvlTo]	  = SkillAllLvlToGoalVO,
	[QuestConsts.GoalType_DominateRoadFloor]  = DominateRoadFloorGoalVO,
	-- [QuestConsts.GoalType_LingshoumudiFloor]  = LingshoumudiFloorGoalVO,
	[QuestConsts.GoalType_MagicWeaponLvlTo]   = MagicWeaponLvlToGoalVO,
	-- [QuestConsts.GoalType_ZhuanshengTimes]    = ZhuanshengTimesGoalVO,
	[QuestConsts.GoalType_FightTo]			  = FightToGoalVO,
	[QuestConsts.GoalType_ChargeTo]			  = ChargeToGoalVO,
	
	[QuestConsts.GoalType_CharLevelTo]		 = CharLevelToGoalVO,
	[QuestConsts.GoalType_EquipUpStar]			  = EquipUpStarGoalVO,
	[QuestConsts.GoalType_XingtuStar]			  = XingtuStarGoalVO,
	[QuestConsts.GoalType_SmithingTimes]			  = SmithingTimesGoalVO,
	[QuestConsts.GoalType_GetFabao]			  = GetFabaoGoalVO,
	[QuestConsts.GoalType_JoinUnion]			  = JoinUnionGoalVO,
	[QuestConsts.GoalType_HuoYueDuLevelTo]			  = HuoYueDuLevelToGoalVO,
	[QuestConsts.GoalType_UseDanyaoTimes]			  = UseDanyaoTimesGoalVO,
	[QuestConsts.GoalType_BaoJiaLevelTo]			  = BaoJiaLevelToGoalVO,
	[QuestConsts.GoalType_XuanBingLevelTo]			  = XuanBingLevelToGoalVO,
	[QuestConsts.GoalType_MingYuLevelTo]			  = MingYuLevelToGoalVO,
	[QuestConsts.GoalType_WorldBoss]			  = WorldBossGoalVO,
	[QuestConsts.GoalType_PersonalBoss]			  = PersonalBossGoalVO,
	[QuestConsts.GoalType_DiGongBoss]			  = DiGongBossGoalVO,
	[QuestConsts.GoalType_YeWaiBoss]			  = YeWaiBossGoalVO,
	[QuestConsts.GoalType_GoldBoss]			  = GoldBossGoalVO,
	[QuestConsts.GoalType_JinJiChang]			  = JinJiChangGoalVO,
	[QuestConsts.GoalType_DaBaoTa]			  = DaBaoTaGoalVO,
	[QuestConsts.GoalType_RingLvUp]			  = RingLvUpGoalVO,
	[QuestConsts.GoalType_SkillTotalLvTo] 	  = SkillTotalLvlToGoalVO,
	[QuestConsts.GoalType_DressEquipByID] 	  = DressEquipByIDGoalVO,
	[QuestConsts.GoalType_DressEquipByNumQuality] 	  = DressEquipByNumQualityGoalVO,
	[QuestConsts.GoalType_XingTuXTo9]			= XingTuTo9GoalVO,
	[QuestConsts.GoalType_TaoFaQuestTalk]			= TaoFaQuestTalkGoalVO,
	-- 成就任务
	[QuestConsts.GoalType_Achievement]        = AchievementGoalVO,
	-- 奇遇任务
	[QuestConsts.GoalType_RandomTalk]         = RandomTalkGoalVO,
	[QuestConsts.GoalType_RandomGoPos]        = RandomGoPosGoalVO,
	-- 新奇遇任务
	[QuestConsts.GoalType_RandomNone]  		  =	RandomQuestNoneGoalVO,
	[QuestConsts.GoalType_RandomKillMonster]  = RandomQuestKillMonsterGoalVO,
	--挖宝
	[QuestConsts.GoalType_WaBao]			  = WaBaoGoalVO,
	--封妖
	[QuestConsts.GoalType_FengYao]			  = FengYaoGoalVO,
	--卓越
	[QuestConsts.GoalType_Super]			  = SuperGoalVO,
	--活跃度	
	[QuestConsts.GoalType_HuoYueDu]			  = HuoYueDuGoalVO,
	--经验副本	
	[QuestConsts.GoalType_EXP_Dungeon]		  = ExpDungeonGoalVO,
	--组队副本
	[QuestConsts.GoalType_Team_Dungeon]		  = TeamDungeonGoalVO,
	--组队经验副本
	[QuestConsts.GoalType_Team_Exp_Dungeon]	  = TeamExpDungeonGoalVO,
	--转职任务
	[QuestConsts.GoalType_ZhuanZhi]           = ZhuanZhiGoalVO,
	--集会所 新屠魔 新悬赏
	[QuestConsts.GoalType_AgoraNone]     		= AgoraQuestNoneGoalVO,
	[QuestConsts.GoalType_AgoraKillMonster]   	= AgoraMonsterQuestGoalVO,
	[QuestConsts.GoalType_AgoraCollection]      = AgoraCollectQuestGoalVO,
	[QuestConsts.GoalType_TaoFaQuestTalk]       = TaoFaQuestTalkGoalVO,
	[QuestConsts.GoalType_AgoraQuestTalk]       = AgoraQuestTalkGoalVO,
	--帮派
	[QuestConsts.GoalType_UnionPray]			= UnionPrayGoalVO,
	[QuestConsts.GoalType_UnionDonation]		= UnionDonationGoalVO,
	[QuestConsts.GoalType_UnionAid]				= UnionAidGoalVO,
	[QuestConsts.GoalType_UnionExchange]		= UnionExchangeGoalVO,
	[QuestConsts.GoalType_NewTianShenLvUp]		= LvNewTianShenLvUpGoalVO,
	[QuestConsts.GoalType_NewTianShenUpStar]	= LvNewTianShenUpStarGoalVO,
	[QuestConsts.GoalType_NewTianShenFight]		= LvNewTianShenFightGoalVO,

};

QuestVO.playRefresh = false;
QuestVO.hasContent = true;
function QuestVO:new(id, flag)
	local obj = setmetatable( {}, {__index = self} );
	obj.id = id;
	self:ParseFlag(flag)
	obj.playRefresh = false;
	obj.state = QuestConsts.State_CanAccept;
	obj.goalList = {}
	obj.goalList[1] = obj:CreateQuestGoal();

	return obj;
end

-- 解析quest协议flag
function QuestVO:ParseFlag( flag )
	--body
end

function QuestVO:GetRewards()
	--body
end

function QuestVO:GetShowRewards()
	--body
end

function QuestVO:GetRewardUIData()
	return ""
end

function QuestVO:GetLvQuestReward()
	return "", "";
end

function QuestVO:GetId()
	return self.id;
end

--任务类型
function QuestVO:GetType()
	return -1
end

--任务目标类型
function QuestVO:GetGoalType()
	local cfg = self:GetCfg();
	if not cfg then return 0; end
	return cfg.kind;
end

function QuestVO:OnStateChange()
--override
end

-- 任务状态
--@param showRefresh: 本次添加任务是否播放刷新特效 -- 可选, 默认播放
function QuestVO:SetState( state, showRefresh )
	if self.state ~= state then
		self.state = state;
		for i,goalVO in pairs(self.goalList) do
			goalVO:OnStateChange();
		end
		self.playRefresh = showRefresh == nil and true or showRefresh
		self:OnStateChange();
	end
end

--获取任务状态(客户端自己判断任务状态是否可接)
function QuestVO:GetState()
	if self.state == QuestConsts.State_UnAccept then
		local cfg = self:GetCfg();
		if not cfg then return QuestConsts.State_CannotAccept; end
		if MainPlayerModel.humanDetailInfo.eaLevel >= cfg.minLevel then
			return QuestConsts.State_CanAccept;
		end
		return QuestConsts.State_CannotAccept;
	end
	return self.state;
end

function QuestVO:SetGoalInfo(info)
	local goal = self:GetGoal()
	if not goal then return; end
	goal:SetGoalInfo(info)
end

--根据目标id设置进度
function QuestVO:SetGoalCount( count )
	local goal = self:GetGoal()
	if not goal then return; end
	goal:SetCurrCount(count)
end

--获取任务进度
function QuestVO:GetGoal()
	local goal = self.goalList and self.goalList[1]
	if not goal then
--		Error( string.format( "cannot find quest goals. id:%s", self.id ) )
--		print(debug.traceback())
		return
	end
	return goal;
end

--获取任务配表
function QuestVO:GetCfg()
	local cfg = t_quest[self.id];
	if not cfg then
		Debug('error:cannot find quest in table.id:'..self.id);
		print(debug.traceback())
		return nil;
	end
	return cfg;
end

function QuestVO:OnAdded()
	-- override
end

function QuestVO:OnTitleClick()
	-- override
end

function QuestVO:HasContent()
	return self.hasContent;
end

function QuestVO:OnContentClick()
	self:Proceed()
end

-- 进行任务
--@param auto 是否是任务引导的调用
function QuestVO:Proceed(auto)
	----------任务指引NPC----------------
	if self:GetType() == QuestConsts.Type_Trunk then
		local questVO = QuestModel:GetTrunkQuest();
		if questVO then
			if MainPlayerController:GetPlayer() then
				local cfg = questVO:GetCfg();
				if toint(cfg.npcOccur) == 1 then
					MainPlayerController:GetPlayer().canShowNPCGuild = true;
					MainPlayerController:GetPlayer():ShowNPCGuild();
				else
					MainPlayerController:GetPlayer():HideNPCGuild();
				end
			end
		else
			return UIMainQuest.ALL;
		end
		QuestConsts.AutoLevel = 999;
	end
	------------------------------------

	local state = self:GetState()
	if state == QuestConsts.State_CanAccept then
		self:Accept();
	elseif state == QuestConsts.State_CanFinish then
		self:Submit();
	elseif state == QuestConsts.State_Finished then
		self:ReqFinish()
	elseif state == QuestConsts.State_Going then
		self:DoGoal(auto)
	end
	QuestGuideManager:OnHandGuide(self);
	-- 兽魄副本中手动点击执行任务，会立刻执行出副本。不手点则服务器计时n秒后出
	if not auto and self.id == QuestConsts.ExitWuhunDungeonQuest then
		QuestController:ExitWuhunDungeon()
	end
	if not auto and self.id == QuestConsts.ExitWuhunDungeonQuestTwo then
		QuestController:ExitWuhunDungeonTwo()
	end
	if not auto and self.id == QuestConsts.ExitWuhunDungeonQuestThree then
		QuestController:ExitWuhunDungeonThree()
	end
	if not auto and self.id == QuestConsts.ExitWuhunDungeonQuestFour then
		QuestController:ExitWuhunDungeonThree()
	end
	if not auto and self.id == QuestConsts.ExitWuhunDungeonQuestFive then
		QuestController:ExitWuhunDungeonThree()
	end
end

-- 去接受任务
function QuestVO:Accept()
	-- override
end

-- 去交任务
function QuestVO:Submit()
	-- override
end

function QuestVO:ReqFinish()
	-- override
end

function QuestVO:DoGoal(auto)
	local goal = self:GetGoal()
	if not goal then return end
	goal:DoGoalGuide(auto)
end

-- 发送接受任务
function QuestVO:SendAccept()
	-- override
end

-- 发送交任务
function QuestVO:SendSubmit()
	-- override
end

-- 完成任务
function QuestVO:Finish()
	self:SetState( QuestConsts.State_Finished )
	local cfg = self:GetCfg()
	local questType = self:GetType();
	if questType == QuestConsts.Type_Level then
		UIMainLvQuest:PlayLvNewEffect();
	else
		if not cfg.unFinishEff then
			UIMainQuest:PlayFinishEffect(); --任务完成特效
		end
	end
	if cfg.finishScript and cfg.finishScript ~= "" then
		QuestScriptManager:DoScript( cfg.finishScript );
	end
	self:OnFinished()
end

function QuestVO:OnFinished()
	-- override
end

--获取任务当前的NPC ID
function QuestVO:GetCurrNPC()
	-- override
end

--获取任务接取点
function QuestVO:GetAcceptPoint()
	-- override
end

--获取任务完成点
function QuestVO:GetFinishPoint()
	-- override
end

--npc语音
function QuestVO:PlayNpcSound()
	return false
end

--------------------------------------任务传送接口 -----------begin---------------------------------

-- 是否标题也显示传送
function QuestVO:CanTitleTeleport()
	return false
end

-- 是否可传送
function QuestVO:CanTeleport()
	return false
end

function QuestVO:GetGoalPos()
	local goal = self:GetGoal();
	if not goal then return; end
	return goal and goal:GetPos();
end

function QuestVO:GetTeleportPos()
	local state = self:GetState()
	if state == QuestConsts.State_CanAccept then
		return self:GetAcceptPoint()
	elseif state == QuestConsts.State_CanFinish then
		return self:GetFinishPoint()
	elseif state == QuestConsts.State_Going then
		return self:GetGoalPos()
	end
end

-- 传送
function QuestVO:Teleport(auto)
	if not self:CanTeleport() and not self:CanTitleTeleport() then return false end
	local point = self:GetTeleportPos()
	if not point then
		Debug("cannot find teleport terminal")
		return false
	end
	if auto then
		-- 判断vip 和 剩余免费次数
		local _, _, freeVip = MapConsts:GetTeleportCostInfo()
		local isVipFree = false
		if freeVip and freeVip == 1 then
			isVipFree = true
		end
		local hasFreeTime = MapModel:GetFreeTeleportTime() > 0
		if (not isVipFree) and (not hasFreeTime) then
			return false
		end
	end
	self:SendTeleportTo( point )
	return true
end

function QuestVO:GetTeleportType()
	-- override
end

-- 传送
function QuestVO:SendTeleportTo(point)
	local teleportType = self:GetTeleportType()
	local onfoot = function()
		self:Proceed()
	end
	MapController:Teleport( teleportType, onfoot, point.mapId, point.x, point.y )
end

-- 传送完成
function QuestVO:OnTeleportDone()
	local point = self:GetTeleportPos()
	if not point then return end
	if point.mapId ~= CPlayerMap:GetCurMapID() then
		QuestController:SetSceneChangeCallBack( function()
			self:Proceed()
		end )
	else
		self:Proceed()
	end
end

--------------------------------------任务传送接口 -----------end---------------------------------

--获取快捷任务任务标题文本
function QuestVO:GetTitleLabel()
	return ""
end

function QuestVO:GetContentLabel(fontSize)
	self.hasContent = true;
	local state = self:GetState()
	local cfg = self:GetCfg();
	local label = "";
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE end;
	local sizeStr = tostring(fontSize);
	if state == QuestConsts.State_CannotAccept then
		local cannotAcceptLink = cfg.cannotAcceptLink;
		if cannotAcceptLink and cannotAcceptLink ~= "" then
			local des = string.format( cfg.cannotAcceptLink, cfg.minLevel );
			label = string.format( "<font size='%s' color='"..QuestColor.COLOR_RED.."'>%s</font>", sizeStr, des );
		else
			self.hasContent = false;
		end
	elseif state == QuestConsts.State_CanAccept then
		local acceptLink = cfg.acceptLink
		if acceptLink then
			label = self:ParseQuestLink( cfg.acceptLink, fontSize );
		end
	elseif state == QuestConsts.State_Going then
		local goalVO = self:GetGoal();
		if goalVO then
			label = goalVO:GetGoalLabel( fontSize );
		end
	elseif state == QuestConsts.State_CanFinish then
		local finishLink = cfg.finishLink or "cfg.finishLink missing!"
		if finishLink then
			label = self:ParseQuestLink( finishLink, fontSize );
		end
	end
	return label;
end

--解析任务链接文字
--格式 %s%s%s#param1#param2#param3
function QuestVO:ParseQuestLink(str, fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE end;
	local sizeStr = tostring(fontSize);
	local parseStr = "";
	local t = split(str,"#");
	if #t <= 0 then return""; end
	parseStr = string.format( "<font size='%s' color='#ffffff'>%s</font>", sizeStr, t[1] );
	if #t > 1 then
		local posTable = {};
		for i=2,#t do
			local posId = tonumber(t[i]);
			local posCfg = t_position[posId]
			if posCfg then
				table.push( posTable, string.format( "<u><font color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", posCfg.name ) );
			else
				table.push(posTable,"");
			end
		end
		parseStr = string.format( parseStr, unpack(posTable) );
	end
	return parseStr;
end

-- 对应经验真气金钱
function QuestVO:GetNormalRewardLabel()
	return ''
end

-- 对应otherReward字段
function QuestVO:GetOtherRewardLabel()
	return ''
end

-- 对应npc对话面板显示谈话内容
function QuestVO:GetNpcTalk()
	-- override
end

-- factory method 建立任务目标
function QuestVO:CreateQuestGoal()
	local cfg = self:GetCfg();
	if not cfg then return end
	local class = QuestVO.GoalClassMap[ cfg.kind ]
	return class and class:new( self )
end

function QuestVO:IsShowNode()
	return true
end

-- factory method 建立任务树节点
function QuestVO:CreateTreeNode()
	if not self:IsShowNode() then return end
	local node        = self:CreateTitleNode() -- title node
	local upperNodes  = self:CreateUpperNodes() -- nodes above content nodes
	local contentNode = self:CreateContentNode() -- content node
	local lowerNodes  = self:CreateLowerNodes() -- nodes below content nodes
	local subNodes = {}
	for _, uNode in ipairs(upperNodes) do
		node:AddSubNode( uNode )
	end
	if self:GetType() == QuestConsts.Type_Trunk then
		self:GetContentLabel();--这里写是为了刷新下是否需要显示内容的标记
	end
	if self:HasContent() then
		node:AddSubNode( contentNode )
	end
	for _, lNode in ipairs(lowerNodes) do
		node:AddSubNode( lNode )
	end
	return node
end

-- 主要节点(标题)
function QuestVO:CreateTitleNode()
	local node = QuestNodeTitle:new()
	node:SetContent( self )
	return node;
end

-- 主要节点(内容)
function QuestVO:CreateContentNode()
	local node = QuestNodeContent:new()
	node:SetContent( self )
	return node;
end

-- 独有节点数组(在内容节点之上)
function QuestVO:CreateUpperNodes()
	return {}
end

-- 独有节点数组(在内容节点之下)
function QuestVO:CreateLowerNodes()
	return {}
end

-------------------------------用于控制下次刷新主界面人物追踪时是否播放刷新特效---------------------

function QuestVO:GetPlayRefresh()
	if self.playRefresh then
		self.playRefresh = false
		return true
	end
	return false
end
------------------------------------------------------------------------------------------------------

function QuestVO:GetPlayRewardEffect()
	return false
end

function QuestVO:ShowTips()
	-- override
end

--销毁
function QuestVO:Destroy()
	for i,goalVO in ipairs(self.goalList) do
		goalVO:Destroy()
	end
	self.__index = nil
	self.goalList = nil
end