--[[
主界面任务追踪树节点：任务标题
2015年5月11日16:50:11
haohu
]]

_G.QuestNodeTitle = QuestNode:new( QuestNodeConst.Node_Title )

-- content = questVO;

function QuestNodeTitle:HasBtn()
	return true
end

function QuestNodeTitle:GetQuestTypeLabel()
	local quest = self:GetContent();
	if quest:GetType() == QuestConsts.Type_Level then
		--return QuestConsts:GetLvQuestTitleTypeLabel(QuestConsts:GetLvQuestRewardType(quest:GetCfg()))
		return t_questlevel[quest:GetId()].title;
	else
		return QuestConsts:GetTitleTypeLabel(quest:GetType());
	end
end

function QuestNodeTitle:GetLabel()
	local quest = self:GetContent();
	return quest:GetTitleLabel();
end

function QuestNodeTitle:GetLvQuestReward()
	local quest = self:GetContent();
	return quest:GetLvQuestReward();
end

-- 获取任务类型
function QuestNodeTitle:GetQuestType()
	local quest = self:GetContent();
	return quest:GetType()
end

function QuestNodeTitle:GetStateRefresh()
	local quest = self:GetContent();
	return quest:GetPlayRefresh();
end

function QuestNodeTitle:GetIconURL()
	local quest = self:GetContent();
	return ResUtil:GetQuestTypeIcon( quest:GetType() );
end

function QuestNodeTitle:OnRollOver()
	local quest = self:GetContent();
	quest:ShowTips()
end

function QuestNodeTitle:OnClick()
	local quest = self:GetContent()
	local questType = quest:GetType()
	if questType == QuestConsts.Type_FengYao then
		local func = FuncManager:GetFunc(FuncConsts.FengYao);
		if func then
			func:OnQuestClick();
		end
		return;
	elseif questType == QuestConsts.Type_Level then
		--当点击了等级任务（目标任务）
		local questID = quest:GetId();
		local questLevelCFG = t_questlevel[questID];
		if questLevelCFG and questLevelCFG.clientParam ~= "" then
			local params = split(questLevelCFG.clientParam, ",");
			local funcID = params[1];
			local subParams = {};
			if #params > 1 then
				subParams = table.sub(params, 2, #params);
				for k, v in pairs(subParams) do
					subParams[k] = toint(subParams[k]);
				end
			end
			FuncManager:OpenFunc(toint(funcID), true, unpack(subParams));
		end
		return;
	elseif questType == QuestConsts.Type_ZhuanZhi then
		if UIZhuanZhiView:IsShow() then
			UIZhuanZhiView:Hide()
		else
			UIZhuanZhiView:Show()
		end
		return;
	else
		quest:OnTitleClick();
		return;
	end

	if not QuestConsts.IsOpenTrunk then
		if questType == QuestConsts.Type_Trunk then
			return
		end
	end
	UIQuest:Open( questType )
end

function QuestNodeTitle:HasTeleportBtn()
	local quest = self:GetContent()
	return quest and quest:CanTitleTeleport()
end

function QuestNodeTitle:OnTeleportClick()
	local quest = self:GetContent()
	if not quest then return end
	quest:Teleport()
end

function QuestNodeTitle:OnTeleportRollOver()
	MapUtils:ShowTeleportTips()
end

function QuestNodeTitle:OnTeleportRollOut()
	TipsManager:Hide();
end
