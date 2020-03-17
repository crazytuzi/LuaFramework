--[[
任务章节开启
2015年5月7日10:40:58
haohu
]]

_G.UIQuestChapter = BaseUI:new("UIQuestChapter");

UIQuestChapter.PanelWait = 15; -- 倒计时秒数

function UIQuestChapter:Create()
	self:AddSWF( 'taskChapterPanel.swf', true, "center" );
end

function UIQuestChapter:OnLoaded( objSwf )
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick() end
end

function UIQuestChapter:OnShow()
	self:StartTimer();
	self:UpdateShow();
end

function UIQuestChapter:OnHide()
	self:StopTimer();
end

function UIQuestChapter:UpdateShow()
	-- body
end

function UIQuestChapter:OnBtnConfirmClick()
	self:Hide();
end


-------------------------------------倒计时处理------------------------------------------

local timerKey;
local time;
function UIQuestChapter:StartTimer()
	local func = function() self:OnTimer(); end
	time = UIQuestChapter.PanelWait;
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 );
	self:UpdateCountDown();
end

function UIQuestChapter:OnTimer()
	time = time - 1;
	if time <= 0 then
		self:StopTimer();
		self:OnTimeUp();
		return;
	end
	self:UpdateCountDown();
end

function UIQuestChapter:OnTimeUp()
	self:Hide();
end

function UIQuestChapter:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey );
		timerKey = nil;
		self:UpdateCountDown();
	end
end

function UIQuestChapter:UpdateCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local textField = objSwf.txtTime;
	textField._visible = timerKey ~= nil;
	textField.htmlText = string.format( StrConfig['commonCountDown001'], time );
end