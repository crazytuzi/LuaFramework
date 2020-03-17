--[[
    Created by IntelliJ IDEA.
    单人副本   --废弃 暂时不开放显示
    User: Hongbin Yang
    Date: 2016/8/23
    Time: 20:19
   ]]


_G.QuestSingleDungeonVO = setmetatable( {}, {__index = QuestVO} )

function QuestSingleDungeonVO:GetType()
	return QuestConsts.Type_Single_Dungeon;
end

--任务目标类型
function QuestSingleDungeonVO:GetGoalType()
	return QuestConsts.GoalType_Dungeon;
end
--[[
--策划要求不再显示3个奖励内容图标了 yanghongbin/jianghaoran   2016-8-23
function QuestSingleDungeonVO:GetRewardUIData()
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
]]
function QuestSingleDungeonVO:GetId()
	return self.id;
end

function QuestSingleDungeonVO:ParseFlag(flag)

end

function QuestSingleDungeonVO:GetState()
	return self.state;
end

-- factory method 建立任务目标
function QuestSingleDungeonVO:CreateQuestGoal()
	local class = QuestVO.GoalClassMap[ QuestConsts.GoalType_Dungeon ]
	return class and class:new( self )
end

function QuestSingleDungeonVO:GetTitleLabel()
	--local restFreeTimes = dungeonGroup:GetRestFreeTimes()
	local leftTimes = string.format(StrConfig["quest912"], restFreeTimes);
	local txtTitle = string.format("<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>", StrConfig["quest918"]) -- 中间的空格是留给任务图标的
	return txtTitle;
end

function QuestSingleDungeonVO:GetContentLabel(fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE end;
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
	return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest90006"] );
	-- elseif state == FengYaoConsts.ShowType_Accepted then
	-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest906"] );
	-- elseif state == FengYaoConsts.ShowType_NoAward then
	-- return string.format( "<u><font size='%s' color='#42db62'>%s</font></u>", fontSize, StrConfig["quest907"] );
	-- end
	-- return "";
end

-- 独有节点数组(在内容节点之上)
--[[策划要求不再显示3个奖励内容图标了 yanghongbin/jianghaoran   2016-8-23
function QuestSingleDungeonVO:CreateUpperNodes()
	-- 封妖 显示奖励节点
	local nodes = {};
	local node1 = QuestNodeNormalReward:new()
	node1:SetContent( self )
	table.push( nodes, node1 )
	return nodes;
end
]]
function QuestSingleDungeonVO:GetPlayRefresh()
	return false;
end

function QuestSingleDungeonVO:GetPlayRewardEffect()
	-- local state = FengYaoModel.fengyaoinfo.curState;
	-- if state == FengYaoConsts.ShowType_NoAward then
	-- return true;
	-- end
	return false;
end