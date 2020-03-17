--[[
	2015年8月22日, PM 01:20:32
	wangyawnei
]]
_G.WeekSignModel = Module:new();

WeekSignModel.weekSignData = {};

function WeekSignModel:UpData(result,login,reward)
	if result ~= 0 then
		return
	end
	self:OnSetData(login,reward);
end

function WeekSignModel:OnSetData(login,reward)
	self.weekSignData = {};
	for i = 1 , #t_sevenday do
		self.weekSignData[i] = {};
		if i <= login then
			self.weekSignData[i].id = i;
		end
        self.weekSignData[i].login=login;
		if bit.band(reward,math.pow(2,i)) == math.pow(2,i) then
			self.weekSignData[i].state = 1;	--可领取
		else
			self.weekSignData[i].state = 0;	--不可领取
		end
	end
    
end

function WeekSignModel:OnGetWeekSingData()
	return self.weekSignData;
end

--是否有奖励可领取  第一周
function WeekSignModel:OnIsReward()
	if not WeekSignController.inData then
		return false
	end
	local allData = self:OnGetWeekSingData();
	for i , v in ipairs(allData) do
		if i <= 7 and v.state == 1 then
			return true;
		end
	end
	return false;
end

--第二周是否有奖励可领取
function WeekSignModel:GetDoubleWeekIsReward()
	if not WeekSignController.inData then
		return false
	end
	local allData = self:OnGetWeekSingData();
	for i , v in ipairs(allData) do
		if i > 7 and v.state == 1 then
			return true;
		end
	end
	return false;
end

--最近一天的可领取七日奖励
function WeekSignModel:OnGetRewardIndex()
	if not WeekSignController.inData then
		return 1
	end
	local allData = self:OnGetWeekSingData();
	for i , v in ipairs(allData) do
		if v.state == 1 then  --可领取
			return i;
		end
	end
	local index ;
	for i , v in ipairs(allData) do
		if v.state == 0 and v.id then  --不可领取
			index = i;
		end
	end
	if index < 1 then
		return 1
	else
		if index == 7 then return 1 end
		return index
	end
	return #allData;
end

function WeekSignModel:GetProReward()
	local allData = self:OnGetWeekSingData();
	for i=#allData,1,-1 do
		if allData[i] and allData[i].id then 
		   if allData[i].state~=1 then 

		   	    return i
		   end
		end
	end
    return 1
end
--在 index 的那天是否可领取奖励
function WeekSignModel:GetIndexIsReward(index)
	if not WeekSignController.inData then
		return false
	end
	local allData = self:OnGetWeekSingData();
	for i , v in ipairs(allData) do
		if v.id == index then  --可领取
			-- return i;
			if v.state == 1 then
				return true
			else
				return false
			end
		end
	end
	return false
end

--七日奖励中是否全部领取完毕  第一周  （true 全部领取）
function WeekSignModel:GetWeekInReward()
	local allData = self:OnGetWeekSingData();
	local weekSign = false;
	if #allData < 1 then return false end
	--如果没有第七天 直接返回false
	for i , v in ipairs(allData) do
		if v then
			if v.id == 7 then
				weekSign = true;
			end
		end
	end
	if not weekSign then return false; end
	
	local rewardNum = 0;
	for i , v in ipairs(allData) do
		if v and v.id and i <= 7 then
			if v.state == 0 then
				rewardNum = rewardNum + 1;
			end
		end
	end
	return rewardNum >= 7;
end

--第二周奖励是否全部领取完毕
function WeekSignModel:GetDoubleWeekReward()
	local allData = self:OnGetWeekSingData();
	if #allData < 1 then return false end
	local weekSign = false;
	for i , v in ipairs(allData) do
		if v and i <= 7 then
			if v.state ~= 0 then
				weekSign = true;
			end
		end
	end
	if weekSign then return false end
	local num = 0;
	for i , v in ipairs(allData) do
		if i > 7 then
			if v and v.id and v.state == 0 then
				num = num + 1;
			end
		end
	end
	if num >= 7 then
		return true
	end
	return false;
end

--检测有没有可以领取的奖励
function WeekSignModel:CheckCanGetReward( )
	local isDoubleWeek = self:GetWeekInReward();
	local canGetNum1 = 0;   --可以领取的奖励数量 
	local canGetNum2 = 0;
	-- for i = 1 , 7 do 
	-- 	if isDoubleWeek then
	-- 		local isReward = self:GetIndexIsReward(i + 7);
	-- 		if not isReward then
	-- 			break;
	-- 		else
	-- 			canGetNum1 = canGetNum1 +1
	-- 			return true,canGetNum1
	-- 		end
	-- 	end
	-- end
	local result = false;
	for i = 1, 7 do
		if not isDoubleWeek then
			local isReward = self:GetIndexIsReward(i);
			if not isReward then
				-- break;
			else
				canGetNum2 = canGetNum2 +1
				result = true;
			end
		end
	end
	if result then
		return result,canGetNum2
	end
	return result,0
end