--[[
活跃度即当前的仙阶
]]

_G.QuestHuoYueDuVO = setmetatable( {}, {__index = QuestVO} )

function QuestHuoYueDuVO:GetType()
	return QuestConsts.Type_HuoYueDu;
end

--任务目标类型
function QuestHuoYueDuVO:GetGoalType()
	return QuestConsts.GoalType_HuoYueDu;
end

function QuestHuoYueDuVO:GetRewardUIData()
	local rewardList = nil;
	if FengYaoModel.fengyaoinfo.curState==FengYaoConsts.ShowType_Awarded or
		FengYaoModel.fengyaoinfo.curState==FengYaoConsts.ShowType_NoAccept then
		local fengyaoGroupCfg = t_fengyaogroup[MainPlayerModel.humanDetailInfo.eaLevel];
		if fengyaoGroupCfg then
			for i,cfg in pairs(t_fengyao) do
				if cfg.group_id==fengyaoGroupCfg.group and cfg.quality==5 then
					rewardList = RewardManager:Parse(enAttrType.eaExp..","..cfg.expReward,
											enAttrType.eaBindGold..","..cfg.moneyReward,
											enAttrType.eaZhenQi..","..cfg.zhenqiReward);
					break;
				end
			end
		else
			rewardList = RewardManager:Parse("110622103,0#110622099,0");--海量经验,海量灵力
		end
	else
		local cfg = t_fengyao[FengYaoModel.fengyaoinfo.fengyaoId];
		if cfg then
			rewardList = RewardManager:Parse(enAttrType.eaExp..","..cfg.expReward,
											enAttrType.eaBindGold..","..cfg.moneyReward,
											enAttrType.eaZhenQi..","..cfg.zhenqiReward);
		end
	end
	if not rewardList then return nil; end
	return table.concat( rewardList, "*" )
end

function QuestHuoYueDuVO:GetId()
	return self.id;
end

function QuestHuoYueDuVO:ParseFlag(flag)

end

function QuestHuoYueDuVO:GetState()
	return self.state;
end

-- factory method 建立任务目标
function QuestHuoYueDuVO:CreateQuestGoal()
	local class = QuestVO.GoalClassMap[ QuestConsts.GoalType_HuoYueDu ]
	return class and class:new( self )
end

function QuestHuoYueDuVO:GetTitleLabel()

	local txtTitle = string.format("<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>", StrConfig["quest90002"]) -- 中间的空格是留给任务图标的
	return txtTitle;
end

function QuestHuoYueDuVO:GetContentLabel(fontSize)
	 if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE; end
	-- local state = FengYaoModel.fengyaoinfo.curState;
	-- if state == FengYaoConsts.ShowType_Awarded then
		-- local istoday, remaintime = FengYaoUtil:GetTimeNextRefresh();
		-- if istoday then
			-- local min = math.ceil(remaintime/60);
			-- local str = string.format(StrConfig["quest903"],min);
			-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, str );
		-- else
			-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest904"] );
		-- end
	-- elseif state == FengYaoConsts.ShowType_NoAccept then
		return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest90005"] );
	-- elseif state == FengYaoConsts.ShowType_Accepted then
		-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest906"] );
	-- elseif state == FengYaoConsts.ShowType_NoAward then
		-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest907"] );
	-- end
	-- return "";
end

-- 独有节点数组(在内容节点之上)
function QuestHuoYueDuVO:CreateUpperNodes()
	-- 封妖 显示奖励节点
	local nodes = {};
	local node1 = QuestNodeNormalReward:new()
	node1:SetContent( self )
	table.push( nodes, node1 )
	return nodes;
end

function QuestHuoYueDuVO:GetPlayRefresh()
	return false;
end

function QuestHuoYueDuVO:GetPlayRewardEffect()
	-- local state = FengYaoModel.fengyaoinfo.curState;
	-- if state == FengYaoConsts.ShowType_NoAward then
		-- return true;
	-- end
	-- return false;
end