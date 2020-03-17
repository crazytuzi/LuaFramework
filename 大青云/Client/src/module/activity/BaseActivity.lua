--[[
活动基类
lizhuangzhuang
2014年12月3日22:01:31
]]

_G.BaseActivity = {};

function BaseActivity:new(id)
	local obj = setmetatable({},{__index=self});
	obj.id = id;  --活动id
	obj.dailyTimes = 0;
	obj.isIn = false;--是否在活动中
	obj.state = 0;--状态,0关闭,1开启
	obj.nextTime = 0;--下次开启或结束时间
	obj.line = 0;--活动所在线
	obj.isNoticeClosed = false;--活动提醒是否被关闭了
	obj.activityMapID = nil;--活动所在地图
	return obj;
end

--获取活动id
function BaseActivity:GetId()
	return self.id;
end

--设置活动提醒不关闭
function BaseActivity:SetIsNoticeCloserd(isClosed)
	self.isNoticeClosed = isClosed
end

--获取活动类型
function BaseActivity:GetType()
	local cfg = self:GetCfg();
	if cfg then
		return cfg.type;
	end
	return 0;
end

--活动是否可组队进入
function BaseActivity:CanTeamIn()
	local cfg = self:GetCfg();
	if not cfg then return false; end
	local t = split(cfg.mapid,",");
	local mapId = toint(t[1]);
	local mapCfg = t_map[mapId]
	if not mapCfg then return false; end
	return mapCfg.can_team == 1;
end

--注册消息
function BaseActivity:RegisterMsg()

end

--活动今天已参加次数
function BaseActivity:SetDailyTimes(times)
	self.dailyTimes = times;
end
function BaseActivity:GetDailyTimes()
	return self.dailyTimes;
end

function BaseActivity:SetLine(line)
	self.line = line;
end
function BaseActivity:GetLine()
	return self.line;
end

--设置活动状态
function BaseActivity:SetState(state)
	if state ~= self.state then
		self.isNoticeClosed = false;--活动状态改变时,重置提醒关闭状态
	end
	self.state = state;
end
--设置下次开启或结束时间
function BaseActivity:SetNextTime(time)
	self.nextTime = time;
end

--设置活动所在地图
function BaseActivity:SetActivityMapID(mapID)
	self.activityMapID = mapID;
end

--获取活动所在地图
function BaseActivity:GetActivityMapID()
	return self.activityMapID;
end

--获取配置
function BaseActivity:GetCfg()
	return t_activity[self:GetId()];
end

--获取活动奖励列表
--@return list {id,count}
function BaseActivity:GetRewardList()
	local cfg = self:GetCfg();
	if not cfg then return; end
	if cfg.reward == "" then return; end
	local t = split(cfg.reward,"#");
	local list = {};
	for i,id in ipairs(t) do
		local vo = {};
		vo.id = toint(id);
		vo.count = 0;
		table.push(list,vo);
	end
	return list;
end

--获取活动开启时间
function BaseActivity:GetOpenTime()
	if not self.activityOpenTime then
		self.activityOpenTime = {};
		local cfg = self:GetCfg();
		if cfg then
			if cfg.openType == 1 then
				local vo = {};
				vo.startTime = 0;
				vo.endTime = 3600*24;
				table.push(self.activityOpenTime,vo);
			else
				local startT = split(cfg.openTime,"#");
				for i,startStr in ipairs(startT) do
					local vo = {};
					vo.startTime = CTimeFormat:daystr2sec(startStr);
					vo.endTime = vo.startTime + cfg.duration*60;
					table.push(self.activityOpenTime,vo);
				end
			end
		end
		table.sort( self.activityOpenTime, function(A,B) return A.startTime < B.startTime end );
	end
	return self.activityOpenTime;
end

--获取开启时间剩余时间
function BaseActivity:GetOpenLastTime()
	if self.state == 1 then return -1; end
	local now = GetServerTime();
	return self.nextTime - now;
	-- return now;
end

--获取结束剩余时间
function BaseActivity:GetEndLastTime()
	if self.state == 0 then return -1; end
	local now = GetServerTime();
	return self.nextTime - now;
end

--获取活动是否开启
function BaseActivity:IsOpen()
	local cfg = self:GetCfg();
	if not cfg then return false; end
	if cfg.openType == 1 then return true; end   --永久开启
	if self.state == 1 then
		return true;
	else
		return false;
	end
end

--获取活动是否可以进入(1可以进入,-1尚未开启,-2今天次数达到上限,-3等级不足);
function BaseActivity:CanIn()
	local cfg = self:GetCfg();
	if not cfg then return -1; end
	if cfg.needLvl > MainPlayerModel.humanDetailInfo.eaLevel then
		return -3;
	end
	if cfg.dailyJoin > 0 then
		if self.dailyTimes >= cfg.dailyJoin then
			return -2;
		end
	end
	if not self:IsOpen() then
		return -1;
	end
	return 1;
end

--获取是否在活动中
function BaseActivity:IsIn()
	return self.isIn;
end

--进入活动
function BaseActivity:Enter()
	if self.isIn then return; end
	self.isIn = true;
	-- if self:GetId() ~= ActivityConsts.RobBox then      --宝箱活动进入时不隐藏右边的任务栏信息
	-- 	 MainMenuController:HideRightTop();            --隐藏右侧和上侧(活动)
	-- end
	MainMenuController:HideRightTop();
	TimerManager:RegisterTimer(function()
		self:OnEnter();
	end,1000,1);
end

--退出活动
function BaseActivity:Quit()
	if not self.isIn then return; end
	self.isIn = false;
	TimerManager:RegisterTimer(function()
		MainMenuController:UnhideRightTop();
	end,1000,1);
	self:OnQuit();
end

--活动结束后是否立即退出
--有结算或者统计面板的,在确定退出后调用DoQuit
function BaseActivity:FinishRightQuit()
	return true;
end

function BaseActivity:DoQuit()
	ActivityController:QuitActivity(self:GetId());
end

--活动进入回调
function BaseActivity:OnEnter()
	
end

--活动到时间结束时调用
function BaseActivity:OnFinish()

end

--活动退出回调
function BaseActivity:OnQuit()

end

--活动场景改变
function BaseActivity:OnSceneChange()

end

--活动状态改变
function BaseActivity:OnStateChange()

end

--
--检查活动提醒
--@return 0不提醒,1即将开启提醒,2进行中提醒
function BaseActivity:DoNoticeCheck()
	-- WriteLog(LogType.Normal,true,'--------BaseActivity:GetId()',self:GetCfg().openType,self.isNoticeClosed,self.state,self.isIn)
	-- print("....",self.isNoticeClosed,self.state,self.isIn)
	if not FuncManager:GetFuncIsOpen(FuncConsts.Activity) then
		-- print('-----------not FuncManager:GetFuncIsOpen(FuncConsts.Activity)')
		return 0;
	end
	if self:GetCfg().openType == 1 then
		-- print('-----------self:GetCfg().openType == 1')
		return 0;
	end
	if self.isNoticeClosed then
		-- print('-----------self.isNoticeClosed')
		return 0;
	end
	--关闭时,提前5分钟提醒
	if self.state == 0 then   --0关闭,1开启
		if self:GetOpenLastTime() <= 300 and  self:GetOpenLastTime() >= 0 then
			-- print('-----------self:GetOpenLastTime():'..self:GetOpenLastTime())
			-- print('-----------self:GetOpenLastTime() <= 300')
			return 1;
		end
		return 0;
	else
		if self.isIn then
			-- print('-----------self.isIn')
			return 2;  --之前是0 changer:houxudong date:2016/8/8
		end
		return 2;
	end
end

--显示活动提醒
function BaseActivity:DoNoticeShow(uiItem)
	if self.state == 0 then
		uiItem.tf1.text = StrConfig['activity201'];
		local time = self:GetOpenLastTime();
		time = time<0 and 0 or time;
		local _,min,sec = CTimeFormat:sec2format(time);
		uiItem.tf2.text = string.format(StrConfig['activity202'],min,sec);
	else
		uiItem.tf1.text = StrConfig['activity203'];
		local time = self:GetEndLastTime();
		time = time<0 and 0 or time;
		local _,min,sec = CTimeFormat:sec2format(time);
		uiItem.tf2.text = string.format(StrConfig['activity204'],min,sec);   ---活动剩余时间
	end
	local iconUrl = ResUtil:GetActivityNoticeUrl(self:GetCfg().noticeIcon);
	if iconUrl ~= uiItem.iconLoader.source then
		if uiItem.iconLoader.initialized then
			uiItem.iconLoader.source = iconUrl;
		else
			if not uiItem.iconLoader.init then
				uiItem.iconLoader.init = function()
					uiItem.iconLoader.source = iconUrl;
				end
			end
		end
	end
end

--点击提醒 changer:houxudong
function BaseActivity:DoNoticeClick()
	--特殊处理抢宝箱活动
	local mapId = CPlayerMap:GetCurMapID();
	if self:GetId() == ActivityConsts.RobBox and self:IsOpen() and mapId == 11403001 then
		-- 自动找宝箱
		ActivityRobBox:collectNearestBox(1)
		return;
	end
	if self:GetId() == ActivityConsts.RobBox then
		if not self.isIn then                                    -- 当前未处于活动中时，点击应该打开活动列表界面	
			FuncManager:OpenFunc(FuncConsts.Activity,false,self:GetId())
			return;
		else
			if self:GetEndLastTime() > 0 and self:IsOpen() then
				-- 自动找宝箱
				ActivityRobBox:collectNearestBox(1)
				return;
			end
		end
	end
	
	--普通活动的处理
	FuncManager:OpenFunc(FuncConsts.Activity,false,self:GetId())
end

function BaseActivity:OnRollOver()
	UIActivityNoticeTips:ShowTips(self:GetId());
end

function BaseActivity:OnRollOut()
	UIActivityNoticeTips:Hide();
end;

--点击提醒关闭
function BaseActivity:DoNoticeCloseClick()
	self.isNoticeClosed = true;
	ActivityController:ShowNotice();
end

--提醒元件库链接名
function BaseActivity:NoticeLibLink()
	return "ActivityNoticeItem";
end

--获取notice tips上显示的活动时间文字描述
function BaseActivity:GetNoticeOpenTimeStr()
	local openTimeList = self:GetOpenTime();
	local str = "";
	for i,openTime in ipairs(openTimeList) do
		local startHour,startMin = CTimeFormat:sec2format(openTime.startTime);
		local endHour,endMin = CTimeFormat:sec2format(openTime.endTime);
		str = str .. string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin);
		str = str .. " ";
	end
	return string.format( StrConfig["activityNoticeTips001"], str);
end