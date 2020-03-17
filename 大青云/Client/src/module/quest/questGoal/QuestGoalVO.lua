--[[
任务目标VO
lizhuangzhuang
2014年8月8日18:45:46
]]

_G.QuestGoalVO = {};

QuestGoalVO.linkColor = "#00FF00";--

--任务目标
--@param questVO 归属的任务
--@param index 目标索引
--@param goalStr	目标参数
--@param guideStr	指引参数
function QuestGoalVO:new(questVO)
	local obj = setmetatable( {}, {__index = self} );
	obj.questVO = questVO;
	obj:Init()
	obj:OnCreate();
	return obj;
end

function QuestGoalVO:Init()
	self.index      = 1 --索引
	self.currCount  = 0 --当前进度
	self.goalParam  = self:CreateGoalParam()
	self.guideParam = self:CreateGuideParam()
	self.goalInfo = nil;
end

function QuestGoalVO:CreateGoalParam()
	local questVO = self.questVO
	if not questVO then return end
	local cfg = questVO:GetCfg()
	return split( cfg.questGoals, "," )
end

function QuestGoalVO:CreateGuideParam()
	local questVO = self.questVO
	if not questVO then return end
	local cfg = questVO:GetCfg()
	return split( cfg.guideParam, "," )
end

--创建时调用
function QuestGoalVO:OnCreate()

end

--任务状态改变时调用
function QuestGoalVO:OnStateChange()
	
end

--任务目标id,任务目标的第一个字段
function QuestGoalVO:GetId()
	return tonumber(self.goalParam[1]);
end

function QuestGoalVO:GetIndex()
	return self.index;
end

--任务目标类型
function QuestGoalVO:GetType()
	return 0;
end

--任务目标需要完成的总数量
function QuestGoalVO:GetTotalCount()
	return 0;
end

function QuestGoalVO:SetGoalInfo(info)
	self.goalInfo = info;
end

--设置进度
function QuestGoalVO:SetCurrCount(count)
	self.currCount = count;
end
function QuestGoalVO:GetCurrCount()
	return self.currCount;
end

--执行目标指引
--@param auto 是否是任务引导的调用
function QuestGoalVO:DoGoalGuide(auto)
	self:DoGoal(auto)
	self:OnDoGoalGuide()
end

function QuestGoalVO:DoGoal()
	
end

-- 是否可传送
function QuestGoalVO:CanTeleport()
	return false
end

function QuestGoalVO:OnDoGoalGuide()
	
end

--获取任务位置信息
-- @return {mapId, x, y};
function QuestGoalVO:GetPos()
	-- override
end

--销毁
function QuestGoalVO:Destroy()
	self.questVO = nil;
	self.goalInfo = nil;
end

--获取在快捷任务显示的信息
function QuestGoalVO:GetGoalLabel(size, color)
	local format = "<font size='%s' color='%s'>%s%s</font>";
	if not size then size = 14 end;
	if not color then color = "#ffffff" end;
	local strSize = tostring( size );
	local name = self:GetLabelContent();
	local count = self:GetTreeDataCount();
	return string.format( format, strSize, color, name, count );
end

function QuestGoalVO:GetLabelContent()
	return "";
end

function QuestGoalVO:GetTreeDataCount()
	local totalCount = self:GetTotalCount();
	if totalCount <= 1 then
		return "";
	end
	local format = (self.currCount < totalCount) and "%s" or "<font color='"..QuestColor.COLOR_GREEN.."'>%s</font>";
	local countStr = string.format( "(%s/%s)", self.currCount, totalCount );
	return string.format( format, countStr );
end

function QuestGoalVO:OpenFuncByClientParam()
	local questVO = self.questVO;
	local questType = questVO:GetType();
	if questType == QuestConsts.Type_Level then
		--当点击了等级任务（目标任务）
		local questID = questVO:GetId();
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
	end
end