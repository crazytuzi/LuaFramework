--[[封妖界面：奖励面板
]]
_G.UIFengyaoGetTask = BaseUI:new("UIFengyaoGetTask");
function UIFengyaoGetTask:Create()
	self:AddSWF("fengyaoGetTaskPanel.swf", true, "bottom")
end

function UIFengyaoGetTask:OnLoaded(objSwf, name)
	objSwf.btnClose.click = function() self:OnBtnMoneyClick() end--银两领取
	objSwf.toTumo.click = function() self:OnToTumoClick() end
	objSwf.btnmoney.click = function() self:OnBtnMoneyClick() end--银两领取
	objSwf.btnyuanbaoGet.click = function() self:OnBtnYuanBaoClick() end--元宝领取
	objSwf.btnmoney.rollOver = function() self:OnBtnMoneyOver(); end
	objSwf.btnmoney.rollOut = function() TipsManager:Hide(); end
	objSwf.btnyuanbaoGet.rollOver = function() self:OnBtnYuanbaoGetOver(); end
	objSwf.btnyuanbaoGet.rollOut = function() TipsManager:Hide(); end
end
function UIFengyaoGetTask:OnShow(name)

	self:UpdateShow();
	self:StopTimer();
	self:StartTimer();
end
function UIFengyaoGetTask:OnBtnMoneyOver()
	TipsManager:ShowBtnTips(string.format(StrConfig['fengyao311']),TipsConsts.Dir_RightDown);
end
function UIFengyaoGetTask:OnBtnYuanbaoGetOver()
	TipsManager:ShowBtnTips(string.format(StrConfig['fengyao312']),TipsConsts.Dir_RightDown);
end
function UIFengyaoGetTask:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end

	-- 文本显示
	objSwf.toTumo.htmlLabel = string.format(StrConfig['fengyao314']);
	objSwf.txtPrompt.htmlText = string.format( StrConfig['quest111'], FengYaoModel.fengyaoinfo.finishCount+1 )
	objSwf.txtInfo.htmlText = string.format( StrConfig['fengyao313'])
	
end
-------------------事件------------------
function UIFengyaoGetTask:OnToTumoClick()
	UIFengYao:Show();
end
function UIFengyaoGetTask:OnBtnMoneyClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
		--判断银两够不够
	if FengYaoUtil:IsHaveGoldRefresh() == false then
		FloatManager:AddNormal( StrConfig["fengyao5"], objSwf.btnmoney);
		return;
	end
	FengYaoController:ReqFengYaoLvlRefresh(1);
end
function UIFengyaoGetTask:OnBtnYuanBaoClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	--判断元宝够不够
	if FengYaoUtil:IsHaveMoneyRefresh() == false then
		FloatManager:AddNormal( StrConfig["fengyao6"], objSwf.btnyuanbao);
		return;
	end
	FengYaoController:ReqFengYaoLvlRefresh(2);
end
---------------------------------倒计时处理--------------------------------
local time;
local timerKey;
function UIFengyaoGetTask:StartTimer()
	time = 15;
	local func = function() self:OnTimer(); end
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 );
	self:UpdateCountDown();
end

function UIFengyaoGetTask:OnTimer()
	time = time - 1;
	if time <= 0 then
		self:StopTimer();
		self:OnTimeUp();
		return;
	end
	self:UpdateCountDown();
end

function UIFengyaoGetTask:OnTimeUp()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	 
	self:OnBtnMoneyClick()
end

function UIFengyaoGetTask:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
		self:HideCountDown();
	end
end

function UIFengyaoGetTask:HideCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime._visible = false;
end

function UIFengyaoGetTask:UpdateCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local txtTime = objSwf.txtTime;
	if not txtTime._visible then
		txtTime._visible = true;
	end
	-- WriteLog(LogType.Normal,true,'---------------------UIFengyaoGetTask:UpdateCountDown()',time)
	objSwf.txtTime.htmlText = string.format( StrConfig['quest111112'], time );
end
function UIFengyaoGetTask:HideSlef()
	local state = FengYaoModel.fengyaoinfo.curState;
	if state == FengYaoConsts.ShowType_Accepted then
		self:Hide()
	end
	
end
function UIFengyaoGetTask:OnHide()
	self:StopTimer();
end
--监听消息
function UIFengyaoGetTask:ListNotificationInterests()
	return {
		NotifyConsts.FengYaoStateChanged,
		NotifyConsts.FengYaoLevelRefresh
	};
end

--消息处理
function UIFengyaoGetTask:HandleNotification( name, body )
	if name == NotifyConsts.FengYaoStateChanged or
		name == NotifyConsts.FengYaoLevelRefresh then
		self:HideSlef()
	end
end