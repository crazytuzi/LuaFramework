--[[
	主宰之路结局面板
	2015年6月6日, PM 10:43:35
	wangyanwei
]]

_G.UIDominateResult = BaseUI:new('UIDominateResult');

function UIDominateResult:Create()
	self:AddSWF('dominateRouteResult.swf',true,'center');
end

function UIDominateResult:OnLoaded(objSwf)
	objSwf.txt_lose.text = UIStrConfig['dominateRoute100'];
	objSwf.txt_lose2.text = UIStrConfig['dominateRoute100'];
	objSwf.reward.rewardList.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.reward.rewardList.itemRollOut = function() TipsManager:Hide(); end
	
	objSwf.btn_quit.click = function () DominateRouteController:SendDominateRouteQuit() end
end

function UIDominateResult:OnShow()
	self:OnChangePanel();
	self:OnTimeChange();
	self:ShowUseTimes();
end
function UIDominateResult:ShowUseTimes( )
	local min,sec = self:OnBackNowLeaveTime(self.useTime)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.reward.useTime.htmlText = string.format(StrConfig['dominateRoute019'],min..':'..sec);
end

--时间换算
function UIDominateResult:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return min,sec
end

UIDominateResult.state = 0;
UIDominateResult.id = 0;
UIDominateResult.level = 0;
UIDominateResult.rewardStr = '';
UIDominateResult.useTime = 0;
function UIDominateResult:Open(state,level,time)
	local isFirst = DominateRouteModel:GetDominateRouteIsPass(UIDominateRouteInfo:GetID());
	local cfg = t_zhuzairoad[UIDominateRouteInfo:GetID()];
	if isFirst then
		-- self.rewardStr = cfg.rewardStr;
	else
		-- self.rewardStr = cfg.firstrewardStr;
	end
	local firstRewardList = {}
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local size = split(cfg.firstrewardStr,'#')
	if #size == 1 then
		firstRewardList = size[1]
	elseif #size == 4 then
		firstRewardList = size[prof]
	end

	-- 显示全部奖励
	-- self.rewardStr = cfg.rewardStr..'#'..firstRewardList
	self.rewardStr = firstRewardList
	
	self.state = state;
	self.level = level;
	self.id = UIDominateRouteInfo:GetID();
	
	local func = function ()
		self:Show();
		TimerManager:UnRegisterTimer(self.openTimeKey);
		self.openTimeKey = nil;
	end
	if self.openTimeKey then
		TimerManager:UnRegisterTimer(self.openTimeKey);
		self.openTimeKey = nil;
	end
	self.useTime = time or 0
	self.openTimeKey = TimerManager:RegisterTimer(func,3000,1);
end

function UIDominateResult:OnChangePanel()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.win._visible = self.state == 1;
	objSwf.bgWin._visible = self.state == 1;
	objSwf.reward._visible = self.state == 1;
	objSwf.lose._visible = self.state == 0;
	objSwf.bgGray._visible = self.state == 0;
	objSwf.txt_lose._visible = self.state == 0;
	objSwf.txt_lose2._visible = self.state == 0;
	if objSwf.win._visible then
		self:OnDrawRewardList();
	end
	for i = 1 , 3 do
		objSwf.reward['star_' .. i]._visible = self.level >= i;
		objSwf.reward['star_gary_' .. i]._visible = self.level > 0;
	end
end

function UIDominateResult:OnDrawRewardList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_zhuzairoad[self.id];
	if not cfg then return end
	
	local rewardList = RewardManager:Parse(self.rewardStr);
	objSwf.reward.rewardList.dataProvider:cleanUp();
	objSwf.reward.rewardList.dataProvider:push(unpack(rewardList));
	objSwf.reward.rewardList:invalidateData();
end

function UIDominateResult:OnTimeChange()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local num = 30;
	local func = function ()
		num = num - 1;
		if self.state == 1 then
			objSwf.txt_time.htmlText = string.format(StrConfig['dominateRoute060'],num);
		else
			objSwf.txt_time.htmlText = string.format(StrConfig['dominateRoute061'],num);
		end
		if num < 1 then
			DominateRouteController:SendDominateRouteQuit()
			TimerManager:UnRegisterTimer(self.timeKey);
			self.timeKey = nil;
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
end

function UIDominateResult:CloseOpenTime()
	if self.openTimeKey then
		TimerManager:UnRegisterTimer(self.openTimeKey);
		self.openTimeKey = nil;
	end
end

function UIDominateResult:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	if self.openTimeKey then
		TimerManager:UnRegisterTimer(self.openTimeKey);
		self.openTimeKey = nil;
	end
end