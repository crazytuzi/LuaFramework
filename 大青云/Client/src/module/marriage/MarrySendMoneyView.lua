--[[结婚发送红包和宝箱按钮界面
zhangshuhui
]]

_G.UIMarrySendMoneyView = BaseUI:new("UIMarrySendMoneyView")

--剩余的秒数
UIMarrySendMoneyView.timelast = 0;
--cd时间定时器key
UIMarrySendMoneyView.lastTimerKey = nil;

function UIMarrySendMoneyView:Create()
	self:AddSWF("marrySendMoneyPanel.swf", true, "bottom2")
end

function UIMarrySendMoneyView:OnLoaded(objSwf,name)
	objSwf.btnredpacket.click = function() self:OnBtnSendRedpacketClick(); end;
	objSwf.btnBox.click = function() self:OnBtnSendBoxClick(); end;
	
	objSwf.btnredpacket.rollOver = function() self:OnBtnSendRedpacketOver(); end
	objSwf.btnredpacket.rollOut = function() TipsManager:Hide(); end
	objSwf.btnBox.rollOver = function() self:OnBtnSendBoxOver(); end
	objSwf.btnBox.rollOut = function() TipsManager:Hide(); end
end

-- function UIMarrySendMoneyView:GetWidth()
	-- return xxxx;
-- end

-- function UIMarrySendMoneyView:GetHeight()
	-- return xxxx;
-- end

--点击红包按钮
function UIMarrySendMoneyView:OnBtnSendRedpacketClick()
	if not MarryGiveAllFive:IsShow() then 
		MarryGiveAllFive:Show();
	end;
end

--点击宝箱按钮
function UIMarrySendMoneyView:OnBtnSendBoxClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.timelast > 0 then
		FloatManager:AddNormal( StrConfig["marriage905"], objSwf.btnBox);
		return;
	end
	MarriagController:ReqSendMarryBox();
end

function UIMarrySendMoneyView:OnBtnSendRedpacketOver()
	TipsManager:ShowBtnTips(StrConfig['marriage906'],TipsConsts.Dir_RightDown);
end

function UIMarrySendMoneyView:OnBtnSendBoxOver()
	TipsManager:ShowBtnTips(string.format(StrConfig['marriage907'],t_consts[189] and t_consts[189].val2 or 30),TipsConsts.Dir_RightDown);
end

function UIMarrySendMoneyView:OnShow(name)
	self:InitData();
	self:StartTimer();
end
function UIMarrySendMoneyView:OnHide()
	self:DelTimerKey();
end

function UIMarrySendMoneyView:InitData()
	self.timelast = 0;
end

function UIMarrySendMoneyView:ReSetData()
	self.timelast = t_consts[189] and t_consts[189].val2 or 30;
end

function UIMarrySendMoneyView:StartTimer()
	if self.lastTimerKey then
		TimerManager:UnRegisterTimer(self.lastTimerKey);
		self.lastTimerKey = nil;
	end
	
	self.lastTimerKey = TimerManager:RegisterTimer( self.DecreaseTimeLast, 1000, 0 );
end

--倒计时自动
function UIMarrySendMoneyView.DecreaseTimeLast( count )
	local objSwf = UIMarrySendMoneyView.objSwf;
	if not objSwf then return; end
	
	UIMarrySendMoneyView.timelast = UIMarrySendMoneyView.timelast - 1;
	
	--时间到了
	if UIMarrySendMoneyView.timelast <= 0 then
		objSwf.btnBox.tfnum.text = "";
		return
	else
		objSwf.btnBox.tfnum.text = UIMarrySendMoneyView.timelast;
	end
end

function UIMarrySendMoneyView:DelTimerKey()
	if self.lastTimerKey then
		TimerManager:UnRegisterTimer( self.lastTimerKey );
		self.lastTimerKey = nil;
	end
end