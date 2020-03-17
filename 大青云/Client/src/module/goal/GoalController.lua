_G.GoalController = setmetatable({},{__index=IController});
GoalController.name = "GoalController";
GoalController.timer = nil;
function GoalController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_FirstDayGoal,self,self.OnFirstDayGoal);
	MsgManager:RegisterCallBack(MsgType.SC_GetFirstDayGoalReward,self,self.OnGetFirstDayGoalReward);
end
function GoalController:OnFirstDayGoal(msg)
	GoalModel.onlineTime = msg.onlineTime;
	GoalModel.getAServerTime = GetServerTime();
	GoalModel.onlineDay = msg.loginDay;
	GoalModel.normalDay = msg.normalDay;
		-- WriteLog(LogType.Normal,true,'---------------------msg.normalDay',msg.normalDay)
	for i,vo in ipairs(msg.list) do
		GoalModel:AddGoal(vo);
	end
	
	-- self.timer = TimerManager:RegisterTimer( function()
		
		-- if GoalModel:CheckAllOver() then
			-- TimerManager:UnRegisterTimer(self.timer,true);
			-- self.timer = nil;
			-- return;
		-- end
	
		-- if GoalModel:GoalChanged(GoalModel.onlineTime,1) then
			-- self:sendNotification(NotifyConsts.GoalListChange);
		-- end
	-- end, 1000, 0 );
	
	-- GoalModel:GoalChanged(msg.loginDay,3)
	-- GoalModel:GoalChanged(GoalModel.onlineTime,1)
	self:sendNotification(NotifyConsts.GoalListChange);
	
	
end
function GoalController:SendGoalReward(id)
	-- local goal = GoalModel:GetShowing()
	-- if not goal then
		-- WriteLog(LogType.Normal,true,'---------------------not goal')
		-- return;
	-- end
	
	-- if not id then
		-- id = goal.id;
	-- end
	--判断是否符合领取目标条件
	-- local result= self:IsCanRewardGoal(id)
	-- if result ~= 0 then
		-- WriteLog(LogType.Normal,true,'---------------------result ~= 0')
		-- return;
	-- end
	local msg = ReqGetFirstDayGoalRewardMsg:new();
	msg.id =id;
	-- WriteLog(LogType.Normal,true,'---------------------rmsg.id',msg.id)
	MsgManager:Send(msg);
	
	-- ClickLog:Send(ClickLog.T_ObtainReward,id);
	
end

function GoalController:OnGetFirstDayGoalReward(msg)
	if msg.result == 0 then
		-- WriteLog(LogType.Normal,true,'---------------------msg.id')
		local goal = GoalModel:GetGoalById(msg.id);
		if goal then
			goal.state = 2;
		end
		-- if msg.id==1001 then
			-- BagController:UseItemByTid(BagConsts.BagType_Bag,150050001,1);
			-- QuestScriptManager:DoScript("yuanBaofuncguide")
		-- elseif msg.id==1002 then
			-- QuestScriptManager:DoScript("wuqifuncguide")
		-- if msg.id==1003 then--宠物领取界面
			-- LovelyPetController:ReqActiveLovelyPet(1);
		-- elseif msg.id==1004 then
			-- local paramlist = split(goal.cnf.clientParam,",");
			-- NoticeScriptManager:DoScript(goal.cnf.script,paramlist);
		-- end
		self:sendNotification(NotifyConsts.GoalListChange);
	else
		
	end
end

function GoalController:CheckGoalOpen()
	-- local level = MainPlayerModel.humanDetailInfo.eaLevel;
	-- WriteLog(LogType.Normal,true,'---------------------GoalController:CheckGoalOpen()',level)
	-- if GoalModel:GoalChanged(level,2) then
		-- self:sendNotification(NotifyConsts.GoalListChange);
	-- end
end
