--[[
	登录奖励
	2014年12月16日, PM 02:45:50
	wangyanwei
]]

_G.RegisterAwardModel=Module:new();

RegisterAwardModel.oldSignList = {};  --签到list

RegisterAwardModel.oldSignVipList = {}; --奖励list

RegisterAwardModel.RewardNum = 0;         --还可以抽取奖励的次数

RegisterAwardModel.oldRewardList = {};   --已经获取到的奖励列表

RegisterAwardModel.levelawardlist = {};  --等级奖励信息

RegisterAwardModel.outlinetime = 0;  --当前离线时间
RegisterAwardModel.outlineawardtype = 0;  --获取离线奖励类型

--玩家已签到列表
RegisterAwardModel.vipTiqianNum = 0;
RegisterAwardModel.vipBuqianNum = 0;

RegisterAwardModel.getAServerTime = 0;
function RegisterAwardModel:OnUpDataMySignReward(msg)
	self.oldSignList = {};
	self.vipBuqianNum = msg.lastNum;
	self.vipTiqianNum = msg.nextNum;
	for i = 1 , 31 do
		if bit.rshift(bit.lshift(msg.day,32-i-1),31) ~= 0 then
			self.oldSignList[i] = {};
		end
	end
	self:sendNotification(NotifyConsts.UpdataSignState);
	self:GetIsNowDayNum();
end

--玩家领取奖励列表                                         ==签到
function RegisterAwardModel:OnUpDataMySignVipReward(SignvipList)
	self.oldSignVipList = {};
	for j , g in pairs(SignvipList) do
		if not self.oldSignVipList[g.day] then
			self.oldSignVipList[g.day] = {};
			self.oldSignVipList[g.day].state = g.state;
			self.oldSignVipList[g.day].day = g.day;
			--self:sendNotification(NotifyConsts.SignRewardUpData,{index = g.day});
		else
			self.oldSignVipList[g.day].state = g.state;
			self.oldSignVipList[g.day].day = g.day;
		end
	end
end

--返回最近可领取的如果都领完显示最后一条
function RegisterAwardModel:OnBackSignReward()
	for index = 1 , 5 do
		local num = 0;
		for i , v in pairs(t_signreward) do
			if v.id == index then
				num = v.day;
			end
		end
		if not self.oldSignVipList[num] then return index end
		if self.oldSignVipList[num].state == 0 then return index end
	end
	return 5;
end

--玩家领奖返回
function RegisterAwardModel:OnSignRewardUpData(day)
	if not self.oldSignVipList[day] then
		self.oldSignVipList[day] = {};
	end
	self.oldSignVipList[day].state = 1;
	--self:sendNotification(NotifyConsts.UpdataSignState);
	self:sendNotification(NotifyConsts.SignRewardUpData,{index = day});
end

--今日是否已签到
RegisterAwardModel.nowDayNum = 0;
function RegisterAwardModel:GetIsNowDayNum()
	local timeData = CTimeFormat:todate(GetServerTime(), false);
	local yearData = split(timeData," ");  --得到现在服务器日期，并取到现在年月日
	local dayData = split(yearData[1],"-");   --得到年月日
	self.nowDayNum = tonumber(dayData[3]);
end

--是否有签到奖励可领取
function RegisterAwardModel:GetRewardIsDraw()
	for i = 1 , 5 do
		if not UISignPanel:OnGetIsReward(i,1) then
			return true;
		end
	end
	return false;
end

-----------------------------在线奖励--------------------------------

--返回奖励索引
RegisterAwardModel.rewardList = {};

--返回今日在线奖励的信息
function RegisterAwardModel:OnBackLineInfo(msg)
	if msg.indexString == '0,0,0#0,0,0#0,0,0#0,0,0' then
		self.rewardList = {};
		self.rewardIndex = 1;
		--self:OnStartTime(msg.time);
		---return;
	end
	local list = split(msg.indexString,'#');
	for i , v in ipairs(list) do
		local cfg = split(v,',');
		self.rewardList[i] = {};
		self.rewardList[i].level = tonumber(cfg[2]);
		self.rewardList[i].index = tonumber(cfg[3]);
	end
	self:OnStartTime(msg.time);
	
end

--开始计时
RegisterAwardModel.rewardIndex = 0;
RegisterAwardModel.timeNum = 0;
RegisterAwardModel.timeNum1 = 0;

function RegisterAwardModel:OnStartTime(num)
	for i , v in ipairs (t_onlinetimes) do
		if num < (v.id * 60) and not RegisterAwardModel:GetIndexRewardBoolean(i) then
			self.rewardIndex = v.index;
			break;
		else
			self.rewardIndex = v.index;
			if self.rewardList[i].level == 0 then
				self.rewardList[i].level = -1;
			end
		end		
	end
	if self.rewardIndex == 0 then self.rewardIndex = #self.rewardList end
	if self.rewardIndex == #self.rewardList and self.rewardList[#self.rewardList].level ~= -1 then
		if self.rewardList[#self.rewardList].level == 0 then
			self.rewardIndex = #self.rewardList;
		else
			self.rewardIndex = #self.rewardList + 1;
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeNum1 = num;
	self.getAServerTime = GetServerTime();
	-- WriteLog(LogType.Normal,true,'------------------num  self.getAServerTime',num,self.getAServerTime)
	
	local func = function ()
		self.timeNum = GetServerTime()-self.getAServerTime+self.timeNum1
		-- WriteLog(LogType.Normal,true,'------------------self.timeNum',self.timeNum)
		-- WriteLog(LogType.Normal,true,'------------------GetServerTime()',GetServerTime())
		self:sendNotification(NotifyConsts.TimeNumUpData);
		
		local cfg = t_onlinetimes[self.rewardIndex];
		if cfg then
			if self.timeNum >= t_onlinetimes[self.rewardIndex].id * 60 then
				if self.rewardIndex <= #t_onlinetimes then 
					self.rewardList[self.rewardIndex].level = -1;
					self.rewardIndex  = self.rewardIndex + 1;
				end
				self:sendNotification(NotifyConsts.UpdataTimeRewardNum);
				Notifier:sendNotification( NotifyConsts.UpDataEffect,{state = 2} );
			end
		end
		local indexNum = self.rewardIndex;
		if indexNum > #self.rewardList then indexNum = #self.rewardList end
		for i = 1 , indexNum do
			if self.rewardList[i].level == -1 then
				self.isOperation = true;return;
			end
		end
		self.isOperation = false;
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function RegisterAwardModel:OnBackNowLeaveTime()
	local hour,min,sec = CTimeFormat:sec2format(GetDayTime());
	return hour,min,sec
end

--是否可抽奖
RegisterAwardModel.isOperation = false;
function RegisterAwardModel:GetIsOperation()
	local indexNum = self.rewardIndex;
	-- print("--------------indexNum",indexNum)   --当前的一个阶段
	if indexNum > #self.rewardList then indexNum = #self.rewardList end
	for i = 1 , indexNum do
		if self.rewardList[i].level == -1 then
			self.isOperation = true;
			return self.isOperation
		end
	end
	self.isOperation = false;
	return self.isOperation;
end

--获得可以抽奖的数量
--adder:houxudong
--date:2016/8/2
function RegisterAwardModel:GetIsOperationNum()
	local indexNum = self.rewardIndex;
	local canGetNum = 0;
	if indexNum > #self.rewardList then indexNum = #self.rewardList end
	for i = 1 , indexNum do
		if self.rewardList[i].level == -1 then
			canGetNum = canGetNum +1;
		end
	end
	-- print("--------------canGetNum",canGetNum)
	return canGetNum;
end


--得到我抽中的位置 
function RegisterAwardModel:GetLineRewardIndex(msg)
	self.rewardList[msg.timeIndex] = {};
	self.rewardList[msg.timeIndex].level = MainPlayerModel.humanDetailInfo.eaLevel;
	self.rewardList[msg.timeIndex].index = msg.index;
	self:sendNotification(NotifyConsts.GetRewardIndex,msg);
end

--获取当前阶段是否已经抽过将
function RegisterAwardModel:GetIndexRewardBoolean(index)
	for i , v in pairs(self.rewardList) do
		if i == index then
			if v.level > 0 then
				return true;
			end
		end
	end
	return false;
end

--获取是否已开启当前阶段
function RegisterAwardModel:GetIndexIsOpen(index)
	local cfg = t_onlinetimes[index];
	if not cfg then return 1 end
	if self.timeNum >= cfg.id * 60 then
		return true;
	end
	return false;
end

--获取每个阶段的等级
function RegisterAwardModel:GetRewardLevel()
	local obj = {};
	for i = 1 , 4 do
		for j , k in pairs(self.rewardList) do
			if i == k.index then
				obj[i] = k.level;
			end
		end
		if not obj[i] or obj[i] < 0 then 
			obj[i] = MainPlayerModel.humanDetailInfo.eaLevel;
		end
	end
	return obj;
end

--获取所有阶段的时间
function RegisterAwardModel:GetTimeInfo()
	local obj = {};
	for i , v in ipairs (t_onlinetimes) do
		obj[i] = v.id;
	end
	return obj;
end	

--每个阶段抽中的物品
function RegisterAwardModel:GetItemIndex()
	local obj = {};
	for i , v in ipairs (self.rewardList) do
		if v.level < 1 then
			obj[i] = 0;
		else
			obj[i] = v.index + 1;
		end
	end
	return obj;
end

-----------------------------------------------------------------------------
--获取index天是否已经签到
function RegisterAwardModel:GetIndexSign(index)
	if not self.oldSignList[index] then return false end;
	return true;
end

--一共签到多少天
function RegisterAwardModel:GetSignDayNum()
	local num = 0;
	for i , v in pairs (self.oldSignList) do
		if v ~= nil then
			num = num + 1;
		end
	end
	return num;
end

--获取index天的奖励是否已经领取
function RegisterAwardModel:GetIndexSignReward(index)
	if not self.oldSignVipList[index] then return nil end --说明已经领取或者时间还没到
	local obj = {};
	obj.vipState = self.oldSignVipList[index].vipState;
	obj.state = self.oldSignVipList[index].state;
	return obj;
end

--判断签到补签 
function RegisterAwardModel:GetSignData(index,state)
	if not self.oldSignList[index] then 
		local obj = {};
		obj.day = index;
		obj.state = state;
		RegisterAwardController:OnSendSignHandler(obj);
	end;  --这个是签到
end

----------------------------等级奖励----------------------------------
--设置等级奖励信息
function RegisterAwardModel:SetLevelAwardList(levelawardlist)
	self.levelawardlist  = levelawardlist;
end

--添加一个已领取奖励等级
function RegisterAwardModel:AddGetedAwardlvl(lvl)
	local vo = {};
	vo.lvl = lvl;
	table.push(self.levelawardlist,vo);
	
	self:sendNotification(NotifyConsts.LevelAwardChange,{lvl=lvl});
	self:sendNotification(NotifyConsts.UpDataEffect,{state=4});
end

-----------------------------离线奖励----------------------------------
--设置离线时间
function RegisterAwardModel:SetOutLineTime(time, type)
	local oldtime = self.outlinetime;
	self.outlinetime  = time;
	self.outlineawardtype = type;
	
	self:sendNotification(NotifyConsts.OutLineExpUpdata,{type=type, newtime=time, oldtime=oldtime});
	self:sendNotification(NotifyConsts.UpDataEffect,{state=3});
end