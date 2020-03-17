--[[
任务目标：转职任务
2016年6月28日16:45:14
chenyujia
]]

_G.ZhuanZhiGoalVO = setmetatable( {}, {__index = QuestGoalVO} )

function ZhuanZhiGoalVO:GetType()
	return QuestConsts.GoalType_Click
end

function ZhuanZhiGoalVO:GetId()
	local cfg = self.questVO:GetCfg()
	return cfg.fucid, cfg.kind
end

--任务目标需要完成的总数量
function ZhuanZhiGoalVO:GetTotalCount()
	local cfg = self.questVO:GetCfg()
	local value = split(cfg.val, ",")
	return toint(value[2] or value[1]);
end

function ZhuanZhiGoalVO:DoGoal()
	local funcId, kind = self:GetId()
	if kind == 3 then
		-- FuncManager:OpenFunc(FuncConsts.HeCheng,false,180700002)
	elseif kind == 2 then
		local lv = MainPlayerModel.humanDetailInfo.eaLevel
		if not lv then return end
		local pointid = t_positionlv[lv].position
		if not pointid then return end

		local point = split(t_position[pointid].pos, ',');
		local completeFuc = function()
			AutoBattleController:OpenAutoBattle();
		end
		MainPlayerController:DoAutoRun(tonumber(point[1]), _Vector3.new(tonumber(point[2]),tonumber(point[3]),0),completeFuc)
	elseif kind == 101 then
		ZhuanZhiController:AskToDup(self.questVO:GetCfg().id)
	elseif funcId and funcId ~= "" then
		FuncManager:OpenFunc(toint(funcId))
	end
end

function ZhuanZhiGoalVO:GetGoalLabel(size, color)
	local format = "<u><font size='%s' color='%s'>%s</font></u>"
	if not size then size = 14 end
	if not color then color = QuestColor.COLOR_GREEN end
	local strSize = tostring( size )
	local name = self:GetLabelContent()
	return string.format( format, strSize, color, name )
end

function ZhuanZhiGoalVO:GetLabelContent()
	local cfg = self.questVO:GetCfg()
	local totalCount = self:GetTotalCount();
	if totalCount <= 0 then
		return "";
	end
	return string.format( cfg.txt, self.currCount, totalCount );
end

function ZhuanZhiGoalVO:CreateGoalParam()
	return nil;
end

function ZhuanZhiGoalVO:CreateGuideParam()
	return nil;
end