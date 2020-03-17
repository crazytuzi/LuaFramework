--[[
任务Util
lizhuangzhuang
2014年8月12日10:12:24
]]

_G.QuestUtil = {};

--获取任务坐标点
function QuestUtil:GetQuestPos(posId)
	if not t_position[posId] then return; end
	local t = split(t_position[posId].pos,"|");
	if #t<=0 then return; end
	local random = math.random(1,#t);
	local posTable = split(t[random],",");
	local vo = {};
	vo.mapId = tonumber(posTable[1]);
	vo.x = tonumber(posTable[2]);
	vo.y = tonumber(posTable[3]);
	if posTable[4] then
		vo.range = tonumber(posTable[4]);
	else
		vo.range = 0;
	end
	return vo;
end

--根据ID获取任务类型
function QuestUtil:GetQuestTypeById(questId)
	local questCfg = t_quest[questId];
	if not questCfg then return; end
	return questCfg.type;
end

--根据ID判断是否是日环任务
function QuestUtil:IsDailyQuest( questId )
	return t_dailyquest[questId] ~= nil;
end
--判断某一个主线任务是否完成了
function QuestUtil:IsTrunkFinished(questId)
	local questVO = QuestModel:GetTrunkQuest();
	if not questVO then return false; end
    if questId < questVO:GetId() then
		return true;
	else
		return false;
	end
end

-- 获取日环任务单环奖励列表UIData Provider
function QuestUtil:GetQuestDayRoundRewardProvider( questDailyVO )
	questDailyVO = questDailyVO or QuestModel:GetDailyQuest();
	local rewardExp, rewardMoney, rewardZhenqi, itemReward, jingyuan = questDailyVO:GetRewards();
	local rewardExpStr    = rewardExp and enAttrType.eaExp..","..rewardExp;
	local rewardMoneyStr  = rewardMoney and enAttrType.eaBindGold..","..rewardMoney;
	-- local rewardZhenqiStr = rewardZhenqi and enAttrType.eaZhenQi..","..rewardZhenqi;
--	local  rewardJingYuanStr = jingyuan and enAttrType.eaTianShen .. "," .. jingyuan;
	local rewardList = RewardManager:Parse( rewardExpStr, rewardMoneyStr,itemReward );
	return rewardList;
end

-- 获取日环任务全部完成奖励列表UIData Provider
function QuestUtil:GetQuestDayRewardProvider(sendLevel)
	local level = 0;
	if not sendLevel or sendLevel == 0 then
		print('not a sendLevel!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
		level = MainPlayerModel.humanDetailInfo.eaLevel;
	else
		print('每日完成日环奖励等级----',sendLevel)
		level = sendLevel;
	end
	local cfg = t_dailygroup[level];
	if not cfg then return; end
	-- local rewardExpStr = enAttrType.eaExp..","..cfg.reward_exp;
	-- local rewardMoneyStr = enAttrType.eaBindGold..","..cfg.reward_money;
	-- local rewardZhenqiStr = enAttrType.eaZhenQi..","..cfg.reward_zhenqi;
	local rewardItemStr = cfg.reward_item;
	local rewardList = RewardManager:Parse(rewardItemStr );
	return rewardList;
end

-- 获取主线任务奖励rewardList
-- parseToVO false:返回UIData, true:返回VO (分别对应RewardManager:Parse & ParseToVO)
function QuestUtil:GetTrunkRewardList(questId, parseToVO)
	local rewardList = {};
	local questCfg = t_quest[questId];
	if questCfg then
		local strExp, strMoney, strZhenqi  = "", "", "";
		local exp    = questCfg.expReward;
		local money  = questCfg.moneyReward;
		local zhenqi = questCfg.zhenqiReward;
		if exp > 0 then
			strExp = string.format( "%s,%s", enAttrType.eaExp, exp );
		end
		if money > 0 then
			strMoney = string.format( "%s,%s", enAttrType.eaBindGold, money );
		end
		if zhenqi > 0 then
			strZhenqi = string.format( "%s,%s", enAttrType.eaZhenQi, zhenqi );
		end

		local myProf = MainPlayerModel.humanDetailInfo.eaProf;

		local cfgKey = string.format( "prof%sReward", myProf );
		local strProfReward = questCfg[cfgKey];
		local otherReward = questCfg.otherReward;
		if not parseToVO then
			rewardList = RewardManager:Parse( strExp, strMoney, strZhenqi, strProfReward, otherReward );
		else
			rewardList = RewardManager:ParseToVO( strExp, strMoney, strZhenqi, strProfReward, otherReward );
		end
	end
	return rewardList;
end

function QuestUtil:GetLevelRewardList(rewareExp, rewareMoney, rewareZhenqi, otherReward, yuanbao)
	local expStr    = rewareExp > 0 and enAttrType.eaExp ..",".. rewareExp or ""
	local moneyStr  = rewareMoney > 0 and enAttrType.eaBindGold ..",".. rewareMoney or ""
	local zhenqiStr = rewareZhenqi > 0 and enAttrType.eaZhenQi ..",".. rewareZhenqi or ""
	local yuanbaoStr = yuanbao > 0 and enAttrType.eaBindMoney .. "," .. yuanbao or ""
	local rewardList = RewardManager:Parse( expStr, moneyStr, zhenqiStr, otherReward, yuanbaoStr )
	return rewardList;
end

-- 任务id生成，避免与其他任务id重合(奇遇)
function QuestUtil:GenerateQuestId( questType, tid )
	local prefix = ""
	if questType == QuestConsts.Type_Random then
		prefix = QuestConsts.RandomQuestPrefix
	elseif questType == QuestConsts.Type_WaBao then
		prefix = QuestConsts.WaBaoQuestPrefix
	elseif questType == QuestConsts.Type_FengYao then
		prefix = QuestConsts.FengYaoQuestPrefix
	elseif questType == QuestConsts.Type_Super then
		prefix = QuestConsts.SuperQuestPrefix
	elseif questType == QuestConsts.Type_HuoYueDu then
		prefix = QuestConsts.HuoYueDuQuestPrefix
	elseif questType == QuestConsts.Type_EXP_Dungeon then
		prefix = QuestConsts.ExpDungeonQuestPrefix
	elseif questType == QuestConsts.Type_Single_Dungeon then
		prefix = QuestConsts.SingleDungeonQuestPrefix
	elseif questType == QuestConsts.Type_Team_Dungeon then
		prefix = QuestConsts.TeamDungeonQuestPrefix
	elseif questType == QuestConsts.Type_Team_EXP_Dungeon then
		prefix = QuestConsts.TeamExpDungeonQuestPrefix
	elseif questType == QuestConsts.Type_TaoFa then
		prefix = QuestConsts.TaoFaQuestPrefix
	elseif questType == QuestConsts.Type_Agora then
		prefix = QuestConsts.AgoraQuestPrefix
	elseif questType == QuestConsts.Type_XianYuanCave then
		prefix = QuestConsts.XianYuanCaveQuestPrefix
	elseif questType == QuestConsts.Type_Babel then
		prefix = QuestConsts.BabelQuestPrefix
	elseif questType == QuestConsts.Type_GodDynasty then
		prefix = QuestConsts.GodDynastyQuestPrefix
	elseif questType == QuestConsts.Type_BXDG then
		prefix = QuestConsts.BXDGQuestPrefix
	elseif questType == QuestConsts.Type_SGZC then
		prefix = QuestConsts.SGZCQuestPrefix
	elseif questType == QuestConsts.Type_UnionJoin then
		prefix = QuestConsts.UnionJoinQuestPrefix
	elseif questType == QuestConsts.Type_Arena then
		prefix = QuestConsts.ArenaQuestPrefix
	elseif questType == QuestConsts.Type_Hang then
		prefix = QuestConsts.HangQuestPrefix
	end
	return prefix .. tid
end