--[[
	2015年10月9日, PM 06:15:24
	wangyanwei
	升阶石礼包
]]

_G.UIUpgradeStone = BaseUI:new('UIUpgradeStone');

function UIUpgradeStone:Create()
	self:AddSWF('upgradeStonePanel.swf',true,'center');
end

function UIUpgradeStone:OnLoaded(objSwf)
	objSwf.btn_start.click = function () self:OnOpenBox(); end
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.btn_openVip.click = function () UIVip:Show(); end
	objSwf.upgradeStoneList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.upgradeStoneList.itemRollOut = function () TipsManager:Hide(); end
end

--检测背包是否有此物品检测是否可使用
function UIUpgradeStone:OnOpenBox()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local itemId = GiftsConsts.GiftsBoxID;
	if BagModel:GetItemNumInBag(itemId) <= 0 then
		FloatManager:AddNormal(StrConfig['stone003']);
		return
	end
	
	local canUseNum = BagModel:GetItemCanUseNum(itemId);
	if canUseNum <= 0 then 
		FloatManager:AddNormal(StrConfig['stone004']);
		return
	end
	
	local item = BagModel:GetItemInBag(itemId);
	if not item then print(itemId,'no item -----')return end
	BagController:SplitUseItem(BagConsts.BagType_Bag, item:GetPos(), 1);
	objSwf.btn_start.disabled = true;
	objSwf.effect_start._visible = false;
	if self.timeKey then return end
	
	self.timeKey = TimerManager:RegisterTimer(function()
		if self.tweening == false then
			objSwf.btn_start.disabled = false;
			local id = GiftsConsts.GiftsBoxID;
			local useNum = BagModel:GetItemCanUseNum(id);
			objSwf.effect_start._visible = useNum > 0;
		end
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end,2000,1);
end

function UIUpgradeStone:OnShow()
	self:InitEffectPos();
	self:ShowEffect();
	self:ShowTxt();
	self:OnDrawStoneList();
end

function UIUpgradeStone:ShowTxt()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local id = GiftsConsts.GiftsBoxID;
	local useNum = BagModel:GetItemCanUseNum(id);
	local vipUseNum = BagModel:GetDailyExtraNum(id);
	local maxUseNum = BagModel:GetDailyTotalNum(id);
	
	local useNum1 = useNum - vipUseNum > 0 and useNum - vipUseNum or 0;
	local vipUseNum1 = useNum > vipUseNum and vipUseNum or useNum;
	
	objSwf.txt_openNum.htmlText = useNum1 .. '/' .. (maxUseNum - vipUseNum);
	objSwf.txt_vipNum.htmlText = vipUseNum1 .. '/' .. vipUseNum;
	
	local vipLevel = MainPlayerModel.humanDetailInfo.eaVIPLevel;
	local byVip = VipController:IsSupremeVip();
	objSwf.btn_openVip.htmlLabel = byVip and UIStrConfig['stone3'] or UIStrConfig['stone1'];
	if byVip and vipLevel > 0 then return end
	local zsVip1Cfg = t_vippower[10318];
	local zs1UseNum = zsVip1Cfg.c_v1;
	objSwf.txt_vipNum.htmlText = zs1UseNum .. '/' .. zs1UseNum;
end

function UIUpgradeStone:ShowEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.effect_reward:stopEffect();
	local id = GiftsConsts.GiftsBoxID;
	local useNum = BagModel:GetItemCanUseNum(id);
	objSwf.effect_start._visible = useNum > 0;
end

function UIUpgradeStone:InitEffectPos()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.mc_bgEffect._x = objSwf.stone1._x;
	objSwf.mc_bgEffect._y = objSwf.stone1._y;
end

function UIUpgradeStone:OnDrawStoneList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.upgradeStoneList.dataProvider:cleanUp();
	local UpgradsStoneListStr = GiftsConsts.UpgradsStoneConsts;
	local stoneCfg = RewardManager:Parse(UpgradsStoneListStr);
	objSwf.upgradeStoneList.dataProvider:push(unpack(stoneCfg));
	objSwf.upgradeStoneList:invalidateData();
end

function UIUpgradeStone:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.endV = 48;
	self.runTime = 0; 
	objSwf.mc_bgEffect._x = objSwf.stone1._x;
	objSwf.mc_bgEffect._y = objSwf.stone1._y;
	self.ease = nil;
	objSwf.btn_start.disabled = false;
	self.tweening = false;
	objSwf.effect_reward:stopEffect();
end

UIUpgradeStone.tweening = false;
UIUpgradeStone.stoneNumConsts = 12;
UIUpgradeStone.stoneTimeNum = 6;
function UIUpgradeStone:Update(dwInterval)
	-- print(dwInterval)
	if not self.tweening then
		return
	end
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_start.disabled = true;
	objSwf.effect_start._visible = false;
	if not self.runTime then 
		self.runTime = 0; 
		objSwf.mc_bgEffect._x = objSwf.stone1._x;
		objSwf.mc_bgEffect._y = objSwf.stone1._y;
		self.ease = nil
	end
	if self.runTime >= self.stoneTimeNum then self:OnInitDate(); self:PlayStoneEffect(); return end
	self.runTime = self.runTime + dwInterval/1000;
	if not self.ease then self.ease = Cubic.easeInOut; end
	local ratio = self.ease:GetRatio(self.runTime/self.stoneTimeNum);
	
	local v = (self.endV-self.startV) * ratio + self.startV;
	local index = toint(v) % self.stoneNumConsts;
	index = index > 0 and index or self.stoneNumConsts;
	objSwf.mc_bgEffect._x = objSwf['stone' ..  index]._x;
	objSwf.mc_bgEffect._y = objSwf['stone' ..  index]._y;
end

function UIUpgradeStone:PlayStoneEffect()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.effect_reward._x = objSwf.mc_bgEffect._x;
	objSwf.effect_reward._y = objSwf.mc_bgEffect._y;
	objSwf.effect_reward:playEffect(2);
	objSwf.effect_reward.complete = function() 
		objSwf.effect_reward:stopEffect(); 
		objSwf.btn_start.disabled = false; 
		self:ShowEffect();
	end
end

function UIUpgradeStone:OnInitDate()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.tweening = false;
	self.runTime = nil;
	self.endV = 48;
	self:ShowTxt();
end

UIUpgradeStone.smallSpeed = 1;

UIUpgradeStone.startV = 1;
UIUpgradeStone.endV = 48;
function UIUpgradeStone:OnTweenStone(rewardStr)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local rewardCfg = split(rewardStr,'#');
	if #rewardCfg > 1 then return end
	local id = toint(split(rewardCfg[1],',')[1]);
	local num = toint(split(rewardCfg[1],',')[2]);
	local rewardList = split(GiftsConsts.UpgradsStoneConsts,'#');
	local index = 0;
	for i , reward in ipairs(rewardList) do
		local itemId = toint(split(reward,',')[1]);
		local itemNum = toint(split(reward,',')[2]);
		if itemId == id and itemNum == num then
			index = i;
		end
	end
	if index == 0 then return end
	self:OnInitDate();
	self.endV = self.endV + index;
	self.smallSpeed = 1;
	self.tweening = true;
end

function UIUpgradeStone:IsTween()
	return true;
end

function UIUpgradeStone:GetPanelType()
	return 1;
end

function UIUpgradeStone:IsShowSound()
	return true;
end

function UIUpgradeStone:IsShowLoading()
	return true;
end

function UIUpgradeStone:HandleNotification(name,body)
	if name == NotifyConsts.UpgradeStoneResult then
		self:OnTweenStone(body.rewardStr);
	end
end
function UIUpgradeStone:ListNotificationInterests()
	return {
		NotifyConsts.UpgradeStoneResult,
	}
end