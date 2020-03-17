_G.GoalModel = Module:new();
--达到条件的奖励list
GoalModel.list = {};
GoalModel.count = 0;
GoalModel.onlineTime = 0;
GoalModel.onlineDay = 0;
GoalModel.normalDay = 0;
GoalModel.getAServerTime = 0;
function GoalModel:AddGoal(msg)
	local goal = self:GetGoalById(msg.id);
	goal.state = msg.state;	
	-- print('-----------------GoalModel:AddGoal(msg)')
	-- UILog:print_table(list)
end
function GoalModel:GetGoalById(id)
	local goal = self.list[id];
	if not goal then
		goal = self:CreateGoal(id,0);
		self.list[id] = goal;
		-- WriteLog(LogType.Normal,true,'--------------------GetGoalById',id)
	end
	
	return goal;
end

function GoalModel:CreateGoal(id,state)
	local vo = {};
	vo.id = id;
	vo.cnf = t_mubiao[vo.id];
	vo.state = state;
	return vo;	
end

function GoalModel:GetShowing()
	local vo = nil;
	local minId = 0;
	for id,goal in pairs(self.list) do
		if goal.state == 0 or  goal.state == 1 then
			if minId == 0 then
				minId = id;
			else
				if minId>id then
					minId = id;
				end
			end
		end
	end
	
	vo = self.list[minId];
	if vo and vo.id~=0 then
		-- WriteLog(LogType.Normal,true,'-------------------GoalModel:GetShowing()1',minId)
		return vo;
	end	
	
	for id,config in pairs(t_mubiao) do
		local vo = self.list[id];
		if not vo or vo.state ~= 2 then
			if minId == 0 then
				minId = id;
			else
				if minId>id then
					minId = id;
				end
			end
		end
	end
	-- WriteLog(LogType.Normal,true,'-------------------GoalModel:GetShowing()2',minId)
	return self:CreateGoal(minId,0);
end

function GoalModel:RemoveGoal(id)
	local goal = self:GetGoalById(id);
	if goal then
		self.list[id] = nil;
		self.count = self.count-1;
	end
	return goal;
end

function GoalModel:GoalChanged(data,condition)
	local has = false;
	for id,config in pairs(t_mubiao) do
		local vo = self.list[id];
		-- WriteLog(LogType.Normal,true,'-------------------11-GoalChanged',data,condition)
		if not vo then
			local temp = 0;
			if condition==2 then
				temp = config.level;
			elseif condition==1 then
				temp = config.time;
			else
				temp = config.day;
			end
			
			if temp ~= 0 then
				temp = data-temp;
				
				if temp>=0 then
					self.list[id] = self:CreateGoal(id,1);
					-- WriteLog(LogType.Normal,true,'--------------------GoalChanged',id)
					has = true
				end
			end
			
		end
	end
	return has
end

function GoalModel:CheckAllOver()
	local over = false;
	for id,config in pairs(t_mubiao) do
		local vo = self.list[id];
		if not vo then
			return over;
		else
			if vo.state ~= 2 then
				return over;
			end
		end
	end
	
	over = true;
	return over;
end