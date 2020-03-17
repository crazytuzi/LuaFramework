--[[
	2016年8月25日, PM 22:48:02
	houxudong
	抢宝箱活动信息界面
]]
_G.UIRobBoxInfo = BaseUI:new('UIRobBoxInfo');

function UIRobBoxInfo:Create()
	self:AddSWF("roboxInfo.swf", true, "bottom");
end

function UIRobBoxInfo:OnLoaded(objSwf)
	objSwf.smallPanel.txt_levelTime.text = UIStrConfig['lunchLevelTime'];
	objSwf.btnOpen.click = function() self:OnBtnOpenClick(e) end
	objSwf.btnCloseState.click = function() self:OnBtnCloseClick(e) end
	objSwf.btn_quit.click = function () self:QuitActivityRobBox(); end
	objSwf.btn_robBox.click = function () self:RobBox(); end
end

function UIRobBoxInfo:OnShow()
	self:InitInfo()
	self:StartTimer()
end

function UIRobBoxInfo:InitInfo( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.smallPanel._visible = true;
	objSwf.btn_quit._visible = true;
	objSwf.btn_robBox._visible = true;
	objSwf.btnCloseState._visible = false;	
	objSwf.btnCloseState._visible = false
end

-- 抢宝箱
function UIRobBoxInfo:RobBox()
	ActivityRobBox:collectNearestBox(1)
end

function UIRobBoxInfo:QuitActivityRobBox()
	local func = function ()
		local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
		if not activity then return; end
		if activity:GetType() ~= ActivityConsts.T_RobBox then return; end
		ActivityController:QuitActivity(activity:GetId());
	end
	UIConfirm:Open(UIStrConfig['lunch103'],func);
end

function UIRobBoxInfo:OnBtnOpenClick(e)
	local objSwf = self.objSwf
	if not objSwf then return; end
	objSwf.smallPanel._visible = false;
	objSwf.btn_quit._visible = false;
	objSwf.btn_robBox._visible = false;
	objSwf.btnCloseState._visible = true;	
end

function UIRobBoxInfo:OnBtnCloseClick(e)
	local objSwf = self.objSwf
	if not self then return; end
	objSwf.smallPanel._visible = true;
	objSwf.btn_quit._visible = true;
	objSwf.btn_robBox._visible = true;
	objSwf.btnCloseState._visible = false;	
end

------------------------时间处理------------------------
UIRobBoxInfo.timerKey = nil;
UIRobBoxInfo.time = 0;
function UIRobBoxInfo:StartTimer()
	local func = function() self:OnTimer() end
	local activity = ActivityModel:GetActivity(ActivityController:GetCurrId());
	self.time = activity:GetEndLastTime(); 
	-- self.time = ActivityRobBox:GetEndLastTimeOverLoad( );
	self.timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
	self:UpdateCountDown()  			--首先调用一次初始值
end

function UIRobBoxInfo:OnTimer()
	self.time = self.time - 1
	if self.time <= 0 then
		self:StopTimer()
		return
	end
	self:UpdateCountDown()
end

function UIRobBoxInfo:UpdateCountDown()
	local objSwf = self.objSwf
	local panel = objSwf and objSwf.smallPanel
	if not panel then return end
	local textField = panel.levelTime
	textField.htmlText = ActivityLunchUtil:ParseTime( self.time )
end

function UIRobBoxInfo:StopTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey )
		self.timerKey = nil
		self:UpdateCountDown()
	end
end

--------------------------------------------------------
function UIRobBoxInfo:OnHide()
	self:StopTimer()
end