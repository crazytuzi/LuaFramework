--[[
v计划
wangshuai
]]

_G.VplanModel = Module:new()
VplanModel.VplanInfo ={}; -- v计划信息
VplanModel.VplanGiftState = {}; --  礼包领取状态
VplanModel.VplanMyinfo = {};

--自身V状态
function VplanModel:upDataVflag()
	local player = MainPlayerController:GetPlayer();
	if not player then return end
	player:SetVTitle(self:GetVFlag());
end

---------------------------------- set
-- 设置V计划信息
function VplanModel:SetVplaninfo(msg)
	self.VplanInfo = {};
	self.VplanInfo.type = msg.type;
	self.VplanInfo.level = msg.level;
	self:upDataVflag();
end;
--  设置礼包领取状态
function VplanModel:SetVplanGift(msg)
	local vo = {};
	
	local voc = {};
	for i,info in ipairs(msg.levelGift) do 
		local vo = {};
		vo.id  =  info.id;
		table.push(voc,vo)
	end;
	vo.levelGift = voc;
	--vo.levelGift = msg.levelGift;
	vo.dayGiftM	 = msg.dayGiftM;
	vo.dayGiftY	 = msg.dayGiftY;
	vo.vGift 	 = msg.vGift;
	vo.vYearGift = msg.vYearGift;
	-- vo.mTitle	 = msg.mTitle;
	-- vo.yTitle	 = msg.yTitle;
	-- 新增称号规则
	vo.vLowTitle = msg.vLowTitle
	vo.vMidTitle = msg.vMidTitle
	vo.vHighTitle = msg.vHighTitle
	self.VplanGiftState = vo
end;

-- 等级礼包领取结果
function VplanModel:SetvplanLvlGift(id,result)

end;

-- 首冲礼包领取结果
function VplanModel:SetvplanVGift(result)
	local list = self.VplanGiftState.vGift;
	if result == 0 then -- 领取成功
		list = 1;
	elseif result == 2 then -- 领取过了
		list = 1;
	elseif resule == 1 then  --条件不足，无法领取
		list = 0;
	end;

end;

-- 年费礼包结果
function VplanModel:SetVYearGift(result)
	local list = self.VplanGiftState.vGift;
		if result == 0 then -- 领取成功
		list = 1;
	elseif result == 2 then -- 领取过了
		list = 1;
	elseif resule == 1 then  --条件不足，无法领取
		list = 0;
	end;

end;

--我的信息
function VplanModel:SetMyVinfo(exp,allexp,speed,time)
	local vo = {};
	vo.vlvl = self:GetVPlanLevel()
	vo.exp = exp;
	vo.allexp = allexp;
	vo.speed = speed;
	vo.time = time;
	self.VplanMyinfo = vo
end;

--消费信息
VplanModel.buyGiftInfo = {};

function VplanModel:VplanBuyGiftInfo(giftList,restTime,xnum)
	self.buyGiftInfo = {};
	self.buyGiftInfo.giftList = {};
	for index,giftVO in ipairs(giftList) do
		local vo = {};
		vo.id = giftVO.id;
		vo.sate = giftVO.state; --领取状态，0=未领取，1=已领取 , 2=达到
		table.push(self.buyGiftInfo.giftList,vo);
	end
	
	self.buyGiftInfo.restTime = restTime;		--剩余时间
	self.buyGiftInfo.xnum 	  = xnum;				--本期累计消费
	-- self:BuyGiftTime();
end

--开始计时
-- function VplanModel:BuyGiftTime()
	-- if self.timeKey then
		-- TimerManager:UnRegisterTimer(self.timeKey);
		-- self.timeKey = nil;
	-- end
	-- local func = function ()
		-- self.buyGiftInfo.restTime = self.buyGiftInfo.restTime - 1;
	-- end
	-- self.timeKey = TimerManager:RegisterTimer(func,1000);
-- end

function VplanModel:GetBuyGiftListInfo()
	return self.buyGiftInfo.giftList;
end

function VplanModel:GetBuyGiftRestTime()
	return self.buyGiftInfo.restTime;
end

function VplanModel:GetBuyGiftXnum()
	return self.buyGiftInfo.xnum;
end

----------------------------------get
--获取我的v信息
function VplanModel:GEtMyVInfo()
	return self.VplanMyinfo;
end;

--获取自己的VFlag
function VplanModel:GetVFlag()
	local vtype = self:GetVPlanType();
	local vlevel = self:GetVPlanLevel();
	return vtype*1000 + vlevel;
end

--get是否是V会员
function VplanModel:GetIsVplan()
	local vtype = self:GetVPlanType();
	if vtype == VplanConsts.Type_M or vtype == VplanConsts.Type_Y then 
		return true;
	end;
	return false;
end

-- get是否V年费会员
function VplanModel:GetYearVplan()
	local v = self:GetVPlanType();
	if v == VplanConsts.Type_Y then 
		return true;
	end;
	return false;
end;

--get是否是月费
function VplanModel:GetMonVplan()
	local vtype = self:GetVPlanType();
	return vtype == VplanConsts.Type_M;
end

-- 得到会员类型
function VplanModel:GetVPlanType()
	return self.VplanInfo.type or VplanConsts.Type_N;
end;

-- 得到会员等级	
function VplanModel:GetVPlanLevel()
	return self.VplanInfo.level or 0
end;

-- 领取月费每日日礼包
-- 返回true，未领取
function VplanModel:GetDayMGiftState()
	if self.VplanGiftState.dayGiftM == 0 then 
		return true;
	end
	return false
end;

-- 领取年费每日日礼包
-- 返回true，未领取
function VplanModel:GetDayYGiftState()
	if self.VplanGiftState.dayGiftY == 0 then 
		return true;
	end
	return false
end;

-- 领取首冲礼包
-- 返回true，未领取
function VplanModel:GetVGiftState()
	--trace(self.VplanGiftState)
	if self.VplanGiftState.vGift == 0 then 
		return true
	end;
	return false;
end;

-- 领取年费礼包
-- 返回true，未领取
function VplanModel:GetYearGiftState()
	if self.VplanGiftState.vYearGift == 0 then 
		return true
	end;
	return false;
end;

-- 领取月称号
-- 返回true，未领取
function VplanModel:GetmTitleState()
	-- if self.VplanGiftState.mTitle == 0 then 
	-- 	return true
	-- end;
	return false;
end;

-- 领取年称号
-- 返回true，未领取
function VplanModel:GetyTitleState()
	-- if self.VplanGiftState.yTitle == 0 then 
	-- 	return true;
	-- end;
	return false;
end;

-- 领取v1称号
-- 返回true，未领取
function VplanModel:GetLowTitle( )
	if self.VplanGiftState.vLowTitle == 0 then 
		return true
	end
	return false
end

-- 领取v23称号
-- 返回true，未领取
function VplanModel:GetMidTitle( )
	if self.VplanGiftState.vMidTitle == 0 then 
		return true
	end
	return false
end

-- 领取v45称号
-- 返回true，未领取
function VplanModel:GetHighTitle( )
	if self.VplanGiftState.vHighTitle == 0 then 
		return true
	end
	return false
end


--获取已经领取的等级礼包
function VplanModel:GetLevelGift()
	local list = {};
	if not self.VplanGiftState.levelGift then return end;
	--trace(self.VplanGiftState.levelGift)
	for i,info in ipairs(self.VplanGiftState.levelGift) do 
		--trace(info)
		if not info then break end;
		if not info.id then break end;
		list[info.id] = info.id;
	end;
	return list;
end;