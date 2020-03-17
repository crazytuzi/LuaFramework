--[[
悬赏
lizhuangzhuang
2015年8月2日11:37:04
]]

_G.QuestFengYaoVO = setmetatable( {}, {__index = QuestVO} )

function QuestFengYaoVO:GetType()
	return QuestConsts.Type_FengYao;
end

--任务目标类型
function QuestFengYaoVO:GetGoalType()
	return QuestConsts.GoalType_FengYao;
end

--[[
--策划要求不再显示屠魔的3个奖励内容图标了 yanghongbin/jianghaoran   2016-7-20
function QuestFengYaoVO:GetRewardUIData()
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

function QuestFengYaoVO:GetId()
	return self.id;
end

function QuestFengYaoVO:ParseFlag(flag)

end

function QuestFengYaoVO:GetState()
	return self.state;
end

-- factory method 建立任务目标
function QuestFengYaoVO:CreateQuestGoal()
	local class = QuestVO.GoalClassMap[ QuestConsts.GoalType_FengYao ]
	return class and class:new( self )
end

function QuestFengYaoVO:GetTitleLabel()
	--local leftTimes = string.format(StrConfig["quest912"], FengYaoConsts.FengYaoMaxCount - FengYaoModel.fengyaoinfo.finishCount);
	local txtTitle = string.format("<font size='"..QuestColor.TITLE_FONTSIZE.."' color='"..QuestColor.TITLE_COLOR.."'>   %s</font>", StrConfig["quest902"]) -- 中间的空格是留给任务图标的
	return txtTitle;
end

function QuestFengYaoVO:GetContentLabel(fontSize)
	if not fontSize then fontSize = QuestColor.CONTENT_FONTSIZE; end
	local state = FengYaoModel.fengyaoinfo.curState;
	if state == FengYaoConsts.ShowType_Awarded then
		-- local istoday, remaintime = FengYaoUtil:GetTimeNextRefresh();
		local leftTime =  FengYaoModel.curHasTime - (GetServerTime()-FengYaoModel.getAServerTime)
		local min = math.ceil(leftTime/60);
		local str = string.format(StrConfig["quest903"],min);
		if min>0 then
			return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, str );
		else
			-- UIFengyaoGetTask:Show()
			return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest9005"] );
		end
	elseif state == FengYaoConsts.ShowType_NoAccept then
		
		local leftTime =  FengYaoModel.curHasTime - (GetServerTime()-FengYaoModel.getAServerTime)
		-- print('---------------------------leftTime',leftTime)
		local min = math.ceil(leftTime/60);
		if min>0 then
			local str = string.format(StrConfig["quest903"],min);
			return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, str );
		end
		-- UIFengyaoGetTask:Show()
		return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest9005"] );
	elseif state == FengYaoConsts.ShowType_Accepted then
		local level = MainPlayerModel.humanDetailInfo.eaLevel
		local lvlCfg = t_fengyaogroup[level]
		if lvlCfg then
			local monsterNum = lvlCfg.number;
			return string.format(StrConfig["quest906"], fontSize, QuestColor.COLOR_GREEN, FengYaoModel.curKillMonserNum,monsterNum);
		end
	elseif state == FengYaoConsts.ShowType_NoAward then
		-- UIFengyaoReward:Show()
		return string.format( "<u><font size='%s' color='"..QuestColor.COLOR_GREEN.."'>%s</font></u>", fontSize, StrConfig["quest907"] );
	end
	return "";
end

-- 独有节点数组(在内容节点之上)
--[[策划要求不再显示屠魔的3个奖励内容图标了 yanghongbin/jianghaoran   2016-7-20
function QuestFengYaoVO:CreateUpperNodes()
	-- 封妖 显示奖励节点
	local nodes = {};
	local node1 = QuestNodeNormalReward:new()
	node1:SetContent( self )
	table.push( nodes, node1 )
	return nodes;
end
]]
function QuestFengYaoVO:GetPlayRefresh()
	return false;
end

function QuestFengYaoVO:GetPlayRewardEffect()
	local state = FengYaoModel.fengyaoinfo.curState;
	if state == FengYaoConsts.ShowType_NoAward then
		return true;
	end
	return false;
end
-- 是否可传送
-- function QuestFengYaoVO:CanTeleport()
	-- local state = FengYaoModel.fengyaoinfo.curState;
	-- if state == FengYaoConsts.ShowType_Accepted then
		-- return true
	-- end
	-- return false
-- end
-- function QuestFengYaoVO:GetTeleportType()
	-- return MapConsts.Teleport_FengYao
-- end
-- function QuestFengYaoVO:GetTeleportPos()
	-- return UIFengYao:GetFengYaoPoint()
-- end