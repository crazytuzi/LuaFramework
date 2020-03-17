--[[
	2015年8月29日, PM 03:46:46
	wangyanwei
	结局
]]

_G.UIMonsterSiegeResult = BaseUI:new('UIMonsterSiegeResult');

function UIMonsterSiegeResult:Create()
	self:AddSWF('monsterSiegeResult.swf',true,'center');
end

function UIMonsterSiegeResult:OnLoaded(objSwf)
	objSwf.btn_quit.click = function () ActivityMonsterSiege:OnEnterQuit(); end
	
	objSwf.rewardList1.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList1.itemRollOut = function () TipsManager:Hide(); end
	objSwf.rewardList2.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList2.itemRollOut = function () TipsManager:Hide(); end
end

function UIMonsterSiegeResult:OnShow()
	self:OnReward1();
	self:OnReward2();
	self:OnTimeTxt();
end

function UIMonsterSiegeResult:OnTimeTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local timeNum = 10;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
	end
	self.timeKey = TimerManager:RegisterTimer(function()
		objSwf.txt_time.htmlText = string.format(StrConfig['monsterSiege005'],timeNum);
		timeNum = timeNum - 1;
		if timeNum < 1 then
			ActivityMonsterSiege:OnEnterQuit();
		end
	end,1000,timeNum);
end

function UIMonsterSiegeResult:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

function UIMonsterSiegeResult:OnReward1()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local rewardCfg = ActivityMonsterSiege:GetReward();
	local str = '';
	for i , v in ipairs(rewardCfg) do
		if i >= #rewardCfg then
			str = str .. v.id .. ',' .. v.num;
		else
			str = str .. v.id .. ',' .. v.num .. '#';
		end
	end
	
	local rewardList = RewardManager:Parse(str);
	objSwf.rewardList1.dataProvider:cleanUp();
	objSwf.rewardList1.dataProvider:push(unpack(rewardList));
	objSwf.rewardList1:invalidateData();
end

function UIMonsterSiegeResult:OnReward2()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local worldLevel = ActivityMonsterSiege:GetMonsterSiegeWave();
	local cfg = t_shouweibeicang[worldLevel];
	if not cfg then return end
	
	local rewardList = RewardManager:Parse(cfg.reward);
	objSwf.rewardList2.dataProvider:cleanUp();
	objSwf.rewardList2.dataProvider:push(unpack(rewardList));
	objSwf.rewardList2:invalidateData();
end