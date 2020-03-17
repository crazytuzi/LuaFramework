--[[
	2015年12月21日11:02:21
	wangyanwei
]]
_G.ChristamsModel = Module:new();


ChristamsModel.donateRewardList = nil
ChristamsModel.donateValue = 0
function ChristamsModel:SetDonateData(allprogress,rewardstate)
	
	local cfg = t_consts[177];
	if not cfg then return end
	local maxValue = cfg.val1;
	
	local list = {};
	for i = 1 , #t_chjuanxianreward do
		list[i] = {};
		if bit.band(rewardstate,math.pow(2,i)) == math.pow(2,i) then
			list[i].isReward = false;
			list[i].isOpen = true;
		else
			local rewardValue = math.floor( t_chjuanxianreward[i].percent * maxValue / 100 );
			list[i].isOpen = rewardValue <= allprogress ;
			list[i].isReward = rewardValue <= allprogress;
		end
	end
	self.donateRewardList = list;
	self.donateValue = allprogress;
end

function ChristamsModel:GetDonateList()
	return self.donateRewardList;
end

function ChristamsModel:GetDonateValue()
	return self.donateValue;
end

--捐献返回 增加进度
function ChristamsModel:ChangeDonateList(_type,progress)
	if not self:GetDonateList() then return end
	self.donateValue = progress;
	
	local cfg = t_consts[177];
	if not cfg then return end
	local maxValue = cfg.val1;
	
	for i = 1 , #self.donateRewardList do
		local rewardValue = math.floor( t_chjuanxianreward[i].percent * maxValue / 100 );
		local isOpen = rewardValue <= self.donateValue;
		if self.donateRewardList[i].isOpen ~= isOpen then
			self.donateRewardList[i].isOpen = isOpen ;
			self.donateRewardList[i].isReward = isOpen;
		end
	end
end

--领奖返回  改变奖励状态
function ChristamsModel:ChangeDonateRewardState(_type)
	if not self:GetDonateList() then return end
	local cfg = t_chjuanxian[_type];
	if not cfg then return end
	if not self.donateRewardList[_type] then return end
	self.donateRewardList[_type].isReward = false;
end