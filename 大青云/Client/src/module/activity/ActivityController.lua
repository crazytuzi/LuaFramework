--[[
活动主控制
lizhuangzhuang
2014年12月3日16:33:19
]]

_G.ActivityController = setmetatable({},{__index=IController});
ActivityController.name = "ActivityController";

--等待进入的活动
ActivityController.waitActivity = nil;
--等待进入的活动的参数
ActivityController.waitActivityParams = nil;
--进入活动前的线
ActivityController.oldLine = 0;

function ActivityController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_Activity,self,self.OnActivityList);
	MsgManager:RegisterCallBack(MsgType.SC_ActivityEnter,self,self.OnActivityEnter);    --返回进入活动
	MsgManager:RegisterCallBack(MsgType.SC_ActivityQuit,self,self.OnActivityQuit);
	MsgManager:RegisterCallBack(MsgType.SC_ActivityFinish,self,self.OnActivityFinish);
	MsgManager:RegisterCallBack(MsgType.SC_ActivityOnlineTime,self,self.OnActivityOnlineTime);
	MsgManager:RegisterCallBack(MsgType.WC_ActivityState,self,self.OnActivityState);    --返回活动状态
	--初始化活动,并注册活动消息
	--一类活动的用父类去注册消息(消息不要多处注册)
	for k,clz in pairs(ActivityModel.classMap) do
		clz:RegisterMsg();
	end
	for k,cfg in pairs(t_activity) do
		local activity = ActivityModel:GetActivity(cfg.id);
		if activity then
			--单例活动直接注册消息
			activity:RegisterMsg();
		else
			local clz = ActivityModel:GetActivityClass(cfg.type);
			if clz then
				local activity = clz:new(cfg.id);
				ActivityModel:RegisterActivity(activity);
			end		
		end
	end
end

--返回活动列表
function ActivityController:OnActivityList(msg)
	for i,vo in ipairs(msg.list) do
		local activity = ActivityModel:GetActivity(vo.id);
		if activity then
			activity:SetDailyTimes(vo.dailyTimes);
		end
	end
end

--返回活动状态
function ActivityController:OnActivityState(msg)
	for i,vo in ipairs(msg.list) do
		local activity = ActivityModel:GetActivity(vo.id);
		if activity then
			activity:SetState(vo.state);    --0关闭,1开启
			activity:SetNextTime(vo.time);
			activity:SetLine(vo.line);
			activity:SetActivityMapID(vo.mapID);
			activity:OnStateChange();
			self:sendNotification(NotifyConsts.ActivityState,{id=vo.id});
		end
	end
end

function ActivityController:OnEnterGame()
	--请求世界Boss列表
	local msg = ReqWorldBossMsg:new();
	MsgManager:Send(msg);
	--启动定时器,每秒检测一次活动提醒
	TimerManager:RegisterTimer(function()
		UICaveBossTip:ShowXYCNotice()
		self:ShowNotice();
	end,1000,0);
end

function ActivityController:ShowNotice()
	local noticelist = {};
	-- print("------------------分割线------------------")
	for k,activity in pairs(ActivityModel.list) do
		--boss大暴乱 不显示图标
		if activity:GetId() ~= ActivityConsts.BossBaoDong then
			local check = activity:DoNoticeCheck();
			-- print("--------检测：",check)
			-- WriteLog(LogType.Normal,true,'--------ActivityController:ShowNotice() check:',check)
			-- WriteLog(LogType.Normal,true,'--------ActivityController:ShowNotice() activity:GetId():',activity:GetId())
			if check == 1 then     --即将开启提醒
				if t_activity[activity:GetId()].show then
					table.push(noticelist,activity:GetId());
				end
			elseif check == 2 then  --进行中提醒
				if t_activity[activity:GetId()].show then
					table.insert(noticelist,1,activity:GetId());
				end
			end
		end
	end
	UIActivityNotice:ShowNoticeList(noticelist);
	-- chenyujia 这里注释掉 屏蔽活动提示
end

function ActivityController:OnChangeSceneMap()
	for k,activity in pairs(ActivityModel.list) do
		if activity:IsIn() then
			activity:OnSceneChange();
		end
	end
end

--获取是否在活动中
function ActivityController:InActivity()
	for k,activity in pairs(ActivityModel.list) do
		if activity:IsIn() then
			return true;
		end
	end
	return false;
end

--获取当前活动id
function ActivityController:GetCurrId()
	for k,activity in pairs(ActivityModel.list) do
		if activity:IsIn() then
			return activity:GetId();
		end
	end
	return 0;
end

--请求在活动时长
function ActivityController:SendActivityOnLineTime(id)
	local msg = ReqActivityOnlineTimeMsg:new();
	msg.id = id;
	MsgManager:Send(msg);
end

--进入活动
function ActivityController:EnterActivity(id,params)
	Debug('调用进入活动');
	local mapId = CPlayerMap:GetCurMapID();
	local mapCfg = t_map[mapId];

	if id == ActivityConsts.XianYuan and ActivityUtils:IsYaotaMap(mapId) then

	elseif not (mapCfg.type==1 or mapCfg.type==2) then
		FloatManager:AddCenter(StrConfig['activity105']);
		return;
	end
	for k,activity in pairs(ActivityModel.list) do
		if id == ActivityConsts.XianYuan and activity:GetId() == ActivityConsts.XianYuan then

		elseif activity:IsIn() then
			if t_activity[activity:GetId()].maincity == 0 then
				print("请求进入活动,有未退出的活动.Id:",activity:GetId());
				FloatManager:AddCenter(StrConfig['activity100']);  --您正在活动中
				return;
			end	
		end
	end
	--
	local activity = ActivityModel:GetActivity(id);

	if not activity then
		Debug('不存在的活动');
		return;
	end
	local canIn = activity:CanIn();
	if canIn == -3 then--等级不足
		local cfg = activity:GetCfg();
		if cfg then
			FloatManager:AddCenter(string.format(StrConfig['activity101'],cfg.needLvl));
		end
		return;
	end
	if canIn == -1 then--尚未开启
		FloatManager:AddCenter(StrConfig['activity102']);
		return;
	end
	if canIn == -2 then--今日进入次数已用光
		FloatManager:AddCenter(StrConfig['activity103']);
		return;
	end

	if not activity:CanTeamIn() then 
		local fun = function() 
			self.oldLine = CPlayerMap:GetCurLineID();
			if activity:GetLine() == CPlayerMap:GetCurLineID() then
				self:DoEnterActivity(id,params);
			elseif activity:GetLine() == 0 then
				FloatManager:AddCenter(StrConfig['activity102']);
			else
				Debug('活动,请求换线',activity:GetLine());
				self.waitActivity = activity;
				self.waitActivityParams = params;
				MainPlayerController:ReqChangeLine(activity:GetLine());
			end
		end;
		if TeamUtils:RegisterNotice(UIActivity,fun) then 
			return
		end;
	end;

	self.oldLine = CPlayerMap:GetCurLineID();
	if activity:GetLine() == CPlayerMap:GetCurLineID() then
		self:DoEnterActivity(id,params);
	elseif activity:GetLine() == 0 then
		FloatManager:AddCenter(StrConfig['activity102']);
	else
		Debug('活动,请求换线',activity:GetLine());
		self.waitActivity = activity;
		self.waitActivityParams = params;
		MainPlayerController:ReqChangeLine(activity:GetLine());
	end
end

--换线后进入活动
function ActivityController:OnLineChange()
	if not self.waitActivity then return; end
	if self.waitActivity:IsIn() then return; end
	Debug('换线成功,准备进入活动');
	self:DoEnterActivity(self.waitActivity:GetId(),self.waitActivityParams);
	self.waitActivity = nil;
	self.waitActivityParams = nil;
end

--换线失败
function ActivityController:OnLineChangeFail()
	self.waitActivity = nil;
	self.waitActivityParams = nil;
end

--执行进入活动,真正的进入活动
function ActivityController:DoEnterActivity(id,params)
	local cfg = t_activity[id];
	if not cfg then return; end
	local msg = ReqActivityEnterMsg:new();
	msg.id = id;
	if params and params.param1 then
		msg.param1 = params.param1;
	else
		msg.param1 = 0;
	end
	MsgManager:Send(msg);
end

--返回进入活动
function ActivityController:OnActivityEnter(msg)
	if self.waitActivity then
		self.waitActivity = nil;
		self.waitActivityParams = nil;
	end
	if msg.result == 0 then
		Debug('-------------进入活动成功.....')
		if msg.worldLevel >= 0 then ActivityModel.worldLevel = msg.worldLevel; end
		for k,activity in pairs(ActivityModel.list) do
			if activity:GetId() ~= ActivityConsts.XianYuan and activity:IsIn() then
				print("Error严重:服务器返回进入活动,当前有活动未退出.Id:",activity:GetId());
				activity:DoQuit();
			end
		end
		--
		local activity = ActivityModel:GetActivity(msg.id);
		if activity then
			if activity:GetType() == ActivityConsts.T_Lunch then
				ActivityLunchModel:SetChooseState(msg.mealType)  
			end
			activity:Enter();
		end
	else
		Debug('进入活动失败');
		Debug(msg.result);   -- -3
		local activity = ActivityModel:GetActivity(msg.id);
		if not activity then
			return
		end
		if activity:GetType() == ActivityConsts.T_MascotCome then
			if msg.result == -2 then
				FloatManager:AddCenter(StrConfig['activity101']);
			elseif msg.result == -3 then
				FloatManager:AddCenter(StrConfig['activity103']);
			elseif msg.result == -5 then
				FloatManager:AddCenter(StrConfig['activity104']);
			elseif msg.result == -7 then
				FloatManager:AddCenter(StrConfig['activity107']);
			end
		end
	end
end

--退出活动
function ActivityController:QuitActivity(id)
	local activity = ActivityModel:GetActivity(id);
	if not activity then return; end
	if not activity:IsIn() then
		print("Error:退出活动失败,当前不在该活动中.Id:",id);
		return;
	end
	local msg = ReqActivityQuitMsg:new();
	msg.id = id;
	MsgManager:Send(msg);
end

--返回退出活动
function ActivityController:OnActivityQuit(msg)
	if msg.result == 0 then
		local activity = ActivityModel:GetActivity(msg.id);
		if activity then
			if activity:IsIn() then
				activity:Quit();
			else
				print("Error:服务器返回退出活动,当前未在活动中.Id:",msg.id);
			end
		end
	else
		Debug('退出活动失败');
	end
end

--返回活动结束
function ActivityController:OnActivityFinish(msg)
	local activity = ActivityModel:GetActivity(msg.id);
	if activity then
		if activity:IsIn() then
			activity:OnFinish();
			if activity:FinishRightQuit() then
				activity:DoQuit();
			end
		else
			print("Error:服务器返回活动结束,当前未在活动中.Id:",msg.id);
		
		end
	end
	if activity:GetType() == ActivityConsts.T_MascotCome then
		MascotComeNoticeManager:CloseCfg();
	end
end


---返回在活动已使用时间
function ActivityController:OnActivityOnlineTime(msg)
	if msg.id == ActivityConsts.XianYuan then
		UIYaota:SaveInfo(msg.time, msg.param1)
		self:sendNotification(NotifyConsts.ActivityOnLineTime, {id = msg.id , timeNum = msg.time})
	else
		UIXianYuanCave:SaveOnLineTime(msg.id,msg.time)
		self:sendNotification(NotifyConsts.ActivityOnLineTime,{id=msg.id,timeNum=msg.time});
		XianYuanUtil:UpdateToQuest()
	end
end

function ActivityController:Update()
	for k,activity in pairs(ActivityModel.list) do
		if activity:GetId() == ActivityConsts.T_DaBaoMiJing then
			if activity:IsIn() then
				ActivityDIFXuanYuanCave:Update()
			end
			break
		end
	end
end
