--[[
	BOSS提示信息面板
	2015年5月6日, PM 05:39:22
	王艳伟
]]
_G.UICaveBossTip = BaseUI:new('UICaveBossTip');

function UICaveBossTip:Create()
	self:AddSWF("xuanyUpdataTips.swf",true,'bottom');
end

function UICaveBossTip:OnLoaded(objSwf)
	objSwf.item.btnClose.click = function () self:Hide(); end
	objSwf.item.button.click = function () self:Hide() UIActivityNoticeTips:Hide() FuncManager:OpenFunc(FuncConsts.DaBaoMiJing); end
	objSwf.item.button.rollOver = function () UIActivityNoticeTips:ShowTips(ActivityConsts.T_DaBaoMiJing); end
	objSwf.item.button.rollOut = function () UIActivityNoticeTips:Hide(); end
	self:OnLoadBGPic();
end

function UICaveBossTip:OnShow()
	self:OnTimeChange();
end

--加载背景图片
function UICaveBossTip:OnLoadBGPic()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local activityID = 10008;
	local activityCfg = t_activity[activityID];
	if not activityCfg then print('activity ID Error:XuanYuanCave') self:Hide(); return end
	local picUrl = ResUtil:GetActivityNoticeUrl(activityCfg.noticeIcon);
	objSwf.item.iconLoader.source = picUrl;
end

--半个小时倒计时
UICaveBossTip.TimeNum = 600;
UICaveBossTip.PanelTimeNum = 300;
function UICaveBossTip:OnTimeChange()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	local timeNum = self.TimeNum;
	local func = function ()
		-- print('timeNum----------------------------      ',timeNum)
		timeNum = timeNum - 1;
		local panelTimeNum = timeNum - self.PanelTimeNum;
		if panelTimeNum > 0 then
			local min,sec = self:OnBackNowLeaveTime2(panelTimeNum);
			objSwf.item.tf2.text = string.format(StrConfig['activityNoticeTips003'],min .. ':' .. sec) ;
		else
			objSwf.item.tf2.text = StrConfig['activityNoticeTips002'];
		end
		if timeNum == 0 then
			self:Hide();
		end
	end
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000);
	func();
end

function UICaveBossTip:OnBackNowLeaveTime2(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return min,sec
end

UICaveBossTip.StartHour = 7;
UICaveBossTip.EndHour = 24;
function UICaveBossTip:ShowXYCNotice()
	if UIXianYuanCave.onLineTimeData and UIXianYuanCave.onLineTimeData ~= {} and UIXianYuanCave.onLineTimeData[ActivityConsts.T_DaBaoMiJing].timeNum <= 90 then
		return
	end
	local startHour = self.StartHour;
	local endHour = self.EndHour;
	local hour,min,sec = self:OnBackNowLeaveTime();
	--print('hour,min,sec',hour,min,sec)
	if hour >= startHour and hour < endHour then
		if (min == 25 or min == 55) and sec == 1 then
			if min == 55 and hour == (endHour - 1) then
				return						--23点55分不刷新
			end
			if min == 25 and hour == startHour then
				return						--7点25分不刷新
			end
			
			local mapId = MainPlayerController:GetMapId();
			local mapCfg = t_map[mapId];
			if mapCfg then
				if mapCfg.unActivityNotice then
					return
				end
			end
			
			if MainPlayerModel.humanDetailInfo.eaLevel >= t_funcOpen[FuncConsts.DaBaoMiJing].open_prama then
				if self:IsShow() then
					self:OnShow();
				else
					self:Show();
				end
			end
		end
	end
end

function UICaveBossTip:OnBackNowLeaveTime()
	local hour,min,sec = CTimeFormat:sec2format(GetDayTime());
	return hour,min,sec
end

function UICaveBossTip:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	UIActivityNoticeTips:Hide()
end

function UICaveBossTip:GetWidth()
	return 166;
end

function UICaveBossTip:GetHeight()
	return 116;
end

-- function UICaveBossTip:HandleNotification(name,body)
	-- if name == NotifyConsts.StageMove then
		
	-- end
-- end

-- function UICaveBossTip:ListNotificationInterests()
	-- return {
		-- NotifyConsts.StageMove,
	-- }
-- end