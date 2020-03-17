--[[
	2015年1月23日, PM 04:44:29
	wangyanwei 
	通天塔结果面板
]]
_G.UIBabelResult = BaseUI:new('UIBabelResult');

function UIBabelResult:Create()
	self:AddSWF("babelResultPanel.swf",true,"center");
end

function UIBabelResult:OnLoaded(objSwf)
	objSwf.btn_1.click = function() self:BtnOneClick(); end
	objSwf.btn_2.click = function() self:BtnTwoClick(); end
	objSwf.txt_lose.htmlText = UIStrConfig['babel300'];
	objSwf.reward.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.reward.rewardList.itemRollOut = function () TipsManager:Hide(); end
end

UIBabelResult.resultState = nil;
function UIBabelResult:OnShow()
	self:TimeChangeHandler();
	if self.resultState == 0 then
		self:LoseHandler();
		return;
	end
	self:WinHandler();
end

UIBabelResult.rewardList = nil;
function UIBabelResult:OnOpen(state,rewardList)
	if UIBabelLayerInfo.timeKey then  --返回结果  先删掉计时器
		TimerManager:UnRegisterTimer(UIBabelLayerInfo.timeKey);
		UIBabelLayerInfo.timeKey = nil;
		UIBabelLayerInfo.nowTime = nil;
		UIBabelLayerInfo.secondHarm = 0;
	end
	if state == 0 then
		self.resultState = 0;
	elseif state == 1 then
		self.resultState = 1;
		self.rewardList = rewardList;
	elseif state == 2 then
		self.resultState = 2;
	end
	if UIBabelLayerInfo:IsShow() then
		UIBabelLayerInfo:Hide();
	end
	self:Show();
end

--计时退出
UIBabelResult.timeKey = nil;
UIBabelResult.nowTime = nil;
function UIBabelResult:OnTimeHandler()
	self.nowTime = 30;
	local func = function()
		local objSwf = self.objSwf;
		self.nowTime = self.nowTime - 1;
		if self.nowTime == 0 then 
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			self.nowTime = nil;
			objSwf.txt_time.text = '00000';
			BabelController:OnOutBabel(); --请求退出
			return;
		end
		objSwf.txt_time.text = self.nowTime .. '';
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	func();
end

function UIBabelResult:BtnOneClick()
	if self.resultState == 0 then
		UIBabelLayerInfo.secondHarm = 0;
		BabelController:OnOutBabel(2); --再次挑战
	else
		BabelController:OnOutBabel(0); --请求退出
	end
	UIBabelLayerInfo:OnChangeHarm();
end

function UIBabelResult:BtnTwoClick()
	if self.resultState == 0 then
		BabelController:OnOutBabel(0); --请求退出
	else
		UIBabelLayerInfo.secondHarm = 0;
		if BabelModel.nowLayer >= #t_doupocangqiong then
			FloatManager:AddNormal( StrConfig["babel500"] );
			return
		end
		BabelController:OnOutBabel(1); --领奖继续
	end
	UIBabelLayerInfo:OnChangeHarm();
end

--弹出面板计时
UIBabelResult.nowTime = 31;
function UIBabelResult:TimeChangeHandler()
	local objSwf = self.objSwf;
	local func = function()
		local objSwf = self.objSwf;
		self.nowTime = self.nowTime - 1;
		if self.nowTime == 0 then 
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
			self.nowTime = 31;
			if self.resultState == 0 then
				BabelController:OnOutBabel(0);
			else
				BabelController:OnOutBabel(1); --领奖继续
			end
			return;
		end
		if self.resultState == 2 then
			objSwf.txt_time.htmlText = string.format(StrConfig['babel001'],self.nowTime);
		else
			objSwf.txt_time.htmlText = string.format(StrConfig['babel012'],self.nowTime);
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	func();
end

--失败
function UIBabelResult:LoseHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_1.label = UIStrConfig['babel203'];
	objSwf.btn_2.label = UIStrConfig['babel204'];
	objSwf.txt_lose._visible = true;
	objSwf.reward._visible = false;
	objSwf.win._visible = false;
	objSwf.lose._visible = true;
	objSwf.bgfail._visible = true;
	objSwf.bgWin._visible = false;
	objSwf.reward.rewardList.dataProvider:cleanUp();  --list清理掉
end	

--通关
function UIBabelResult:WinHandler()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.btn_1.label = UIStrConfig['babel201'];
	objSwf.btn_2.label = UIStrConfig['babel202'];
	objSwf.reward._visible = true;
	objSwf.win._visible = true;
	objSwf.lose._visible = false;
	objSwf.txt_lose._visible = false;
	objSwf.bgfail._visible = false;
	objSwf.bgWin._visible = true;
	self:OnShowIcon();
end

--绘制奖励list
function UIBabelResult:OnShowIcon()
	local objSwf = self.objSwf;
	local cfg = t_doupocangqiong[BabelModel.nowLayer];
	local rewardCfg;
	objSwf.reward.rewardList.dataProvider:cleanUp();
	if self.resultState == 1 then
		local rewardList = self.rewardList;
		if not rewardList then rewardList = {}; end
		local rewardStr = '';
		for i , v in ipairs(rewardList) do
			if v.id ~= 0 then
				rewardStr = rewardStr .. ( i >= #rewardList and v.id .. ',' .. v.num or v.id .. ',' .. v.num .. '#'  )
			end
		end
		rewardCfg = RewardManager:Parse( rewardStr == '' and cfg.reward or rewardStr .. '#' .. cfg.reward );
	elseif self.resultState == 2 then
		rewardCfg = RewardManager:Parse(cfg.firstReward);
	end
	objSwf.reward.rewardList.dataProvider:push(unpack(rewardCfg));
	objSwf.reward.rewardList:invalidateData();
	local itemList = {};
	itemList[1] = objSwf.reward.item1;
	itemList[2] = objSwf.reward.item2;
	itemList[3] = objSwf.reward.item3;
	itemList[4] = objSwf.reward.item4;
	itemList[5] = objSwf.reward.item5;	
	UIDisplayUtil:HCenterLayout(#rewardCfg, itemList, 54, 120, 37);
	itemList = nil;	
end

function UIBabelResult:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
		self.nowTime = 31;
	end
end