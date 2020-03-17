--[[
	360卫士
	wangshuai
]]

_G.Weishi360Model = Module:new()

Weishi360Model.curDayReward = 0; --0未领取，1=已领取， 游戏特权
Weishi360Model.curLvlReward = 0; -- 卫士特权

Weishi360Model.RewardListstate = {};
Weishi360Model.YouxiRewardListstate = {};
Weishi360Model.WeiShiRewardListstate = {};

Weishi360Model.curDayQuickReward = 0; --0未领取，1=已领取， 游戏特权加速礼包

---游戏
function Weishi360Model:SetCurDataState(bo)
	self.curDayReward = bo;
	--约定，从0开始
	for i=1,31 do
		local v = bit.rshift(bit.lshift(bo,32-i),31);
		self:SetYouxiLvlState(i,v)
	end
end;

---游戏
function Weishi360Model:SetYouxiLvlState(type,v)
	if type <= 7 then 
		self.YouxiRewardListstate[type] = v;
	end;
end;

---游戏(奖励领取状态)
function Weishi360Model:GetCurDatState()
	local serverData = MainPlayerController:GetServerOpenDay();
	if self.YouxiRewardListstate[serverData] == 0 then 
		return true;
	end;
	return false
end;

---游戏
function Weishi360Model:GetRewardList()
	local num = 0;
	for i,info in ipairs(self.YouxiRewardListstate) do 
		if info ~= 0 then 
			num = num + 1;
		end;
	end;
	return num;
end;



---卫士
function Weishi360Model:SetCurLvlState(flag)
	self.curLvlReward = flag;
	for i=1,31 do
		local v = bit.rshift(bit.lshift(flag,32-i-1),31);
		self:SetLvlState(i,v)
	end
end;

---卫士
function Weishi360Model:SetLvlState(type,v)
	if type <= 7 then 
		self.RewardListstate[type] = v;
	end;
end;

--true 未领取
function Weishi360Model:GetCurLvlState(type)
	if self.RewardListstate[type] then 
		return self.RewardListstate[type] == 0
	end;
	return true; --如果取不到，就默认可以领取
end;

---游戏特权加速礼包
function Weishi360Model:SetCurDayQuickReward(flag)
	self.curDayQuickReward = flag;
end

---游戏特权加速礼包
function Weishi360Model:GetCurDayQuickReward()
	return self.curDayQuickReward;
end

---wan平台特殊渠道天数礼包领取状态
function Weishi360Model:SetWanChannelReward(type,v)
	self.WeiShiRewardListstate[type] = v;
end

-- 获取wan平台特殊渠道天数礼包领取状态
function Weishi360Model:GetWanChannelReward(type)
	return self.WeiShiRewardListstate[type];
end

-- 获取wan指定渠道进入的奖励
function Weishi360Model:GetWanChannelRewardData( )
	if not t_weishilogin then
		Debug("not find t_weishilogin,checkout......")
		return
	end
	table.sort( t_weishilogin, function( A,B )
		return A.id < B.id
	end )
	local rewardData = {}
	for i=1,#t_weishilogin do
		local vo = {}
		vo.num = t_weishilogin[i].level
		vo.rewardOne = t_weishilogin[i].reward
		vo.state =  self:GetWanChannelReward(i)
		table.push(rewardData,vo)
	end
	return rewardData
end
