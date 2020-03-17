--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/10/22
    Time: 16:32
   ]]

_G.AgoraUtils = {};


function AgoraUtils:ConvertQuestListToUIList(questList)
	local uiList = {};
	for k, v in pairs(questList) do
		table.push(uiList, AgoraUtils:ConvertItemVOToUI(v));
	end
	return uiList;
end

function AgoraUtils:ConvertItemVOToUI(v)
	local vo = {};
	vo.questId = v.questId;
	vo.quality = t_questagora[vo.questId].quality;
	vo.qualityStr = AgoraUtils:GetQualityStr(vo.quality);
	if _G.isDebug then
		vo.qualityStr = vo.qualityStr .. " questId:" .. vo.questId .. " kind:" .. t_questagora[vo.questId].kind;
	end
	vo.qualityStr = "" --暂时把品质屏蔽 @chenyujia
	vo.rewardType = v.rewardType;
	vo.questGoal = AgoraUtils:GetGoalStr(vo.questId, v.taofaId, v.npcId);
	vo.state = v.state;
	return vo;
end

function AgoraUtils:GetQualityStr(quality)
	local result = ""
	if quality == AgoraConsts.QUALITY_BLUE then -- 蓝
	result = StrConfig["agora4"];
	elseif quality == AgoraConsts.QUALITY_PURPLE then -- 紫
	result = StrConfig["agora5"];
	elseif quality == AgoraConsts.QUALITY_ORANGE then -- 橙
	result = StrConfig["agora6"];
	end
	return result
end

function AgoraUtils:GetGoalStr(questId, taofaId, npcId)
	local cfg = t_questagora[questId];
	if not cfg then return; end
	local kind = cfg.kind
	local strTemp = cfg.finishLink;
	local questGoals = cfg.questGoals;
	if kind == AgoraConsts.KIND_MONSTER then
		local monsterID = toint(GetCommaTable(questGoals)[1]);
		local monsterCFG = t_monster[monsterID];
		if not monsterCFG then return; end
		return string.format(strTemp, monsterCFG.name);
	elseif kind == AgoraConsts.KIND_COLLECTION then
		local collID = toint(GetCommaTable(questGoals)[1]);
		local collCFG = t_collection[collID];
		if not collCFG then return; end
		return string.format(strTemp, collCFG.name);
	elseif kind == AgoraConsts.KIND_TAOFA then
		local name, position = AgoraUtils:GetTaoFaNPCNameAndPosition(taofaId, npcId)
		return string.format(StrConfig["quest925"], name);
	elseif kind == AgoraConsts.KIND_BOX then
		return "not kind 4";
	elseif kind == AgoraConsts.KIND_NPC_TALK then
		local goal_npcID = toint(GetCommaTable(questGoals)[1]);
		local npcCFG = t_npc[goal_npcID];
		if not npcCFG then return; end
		return string.format(strTemp, npcCFG.name)
	end
end

function AgoraUtils:GetTaoFaNPCNameAndPosition(taofaId, npcId)
	local taofaCFG = t_taofa[taofaId];
	if not taofaCFG then
		WriteLog(LogType.Normal, true, "AgoraUtils.lua<AgoraUtils:GetTaoFaNPCNameAndPosition> : ", taofaId)
		return "";
	end
	local npcstr = taofaCFG.npc;
	if not npcstr then return "" end
	local npcArr = GetPoundTable(npcstr)
	local name = ""
	local resultK = 0;
	for k, v in pairs(npcArr) do
		if toint(v) == npcId then
			resultK = k;
			name = t_npc[npcId].name
			break;
		end
	end
	local position = 0;
	if resultK > 0 then
		local posArr = GetPoundTable(t_taofa[taofaId].postion);
		position = toint(posArr[resultK]);
	end
	return name, position;
end

function AgoraUtils:GetRewardExpStrFromTable(lv, quality)
	local cfg = t_questagora_exp[lv];
	if not cfg then return; end
	local fieldName = "";
	if quality == AgoraConsts.QUALITY_BLUE then
		fieldName = "reward3";
	elseif quality == AgoraConsts.QUALITY_PURPLE then
		fieldName = "reward2";
	elseif quality == AgoraConsts.QUALITY_ORANGE then
		fieldName = "reward1";
	end
	return cfg[fieldName];
end

function AgoraUtils:GetRewardStrFromTable(rewardID, lv, quality)
	local rewardItem = t_questagora_rewards[rewardID].reward;
	local rewardExp = AgoraUtils:GetRewardExpStrFromTable(lv, quality);
	local result = {rewardItem,  rewardExp};
	return table.concat(result, "#")
end