--[[
顺网平台
wangshuai
2015年11月12日15:15:54
]]

_G.ShunwangModel = Module:new()

ShunwangModel.rewardlist = {};--奖励状态 0=可领取，1=不能
ShunwangModel.mylvl = 0;

function ShunwangModel:SetRewardState(list)
	for i,info in ipairs(list) do 
		self.rewardlist[info.swlvl] = info.state;
	end;
end

--返回true。可领取
function ShunwangModel:GetRewardState(lvl)
	if not self.rewardlist then return 0 end; --都没有数据，尝试给服务器发信息，
	if not self.rewardlist[lvl] then return 0 end;
	return self.rewardlist[lvl] == 0 or self.rewardlist[lvl] == 1  and  true or false ;
end;

function ShunwangModel:SetSwMyVipLvl(lvl)
	self.mylvl =  lvl;
end;

function ShunwangModel:GetSwMyVipLvl()
	return self.mylvl or 0;
end;

--返回显示按钮状态 
function ShunwangModel:GetIsShowIcon()
	local cfg = t_shunwangvip;
	for i,info in ipairs(cfg) do 
		local isCan = ShunwangModel:GetRewardState(info.id)
		if isCan then 
			return true
		end;	
	end;
	return false;
end;

