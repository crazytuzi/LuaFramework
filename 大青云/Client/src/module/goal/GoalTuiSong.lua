_G.UIGoalTuiSong = BaseUI:new("UIGoalTuiSong");
UIGoalTuiSong.currShow = nil;
function UIGoalTuiSong:Create()
	self:AddSWF("GoalPanelTips.swf",true,"top");
end
function UIGoalTuiSong:OnLoaded(objSwf)
	-- objSwf.hitTestDisable = true
	-- objSwf.tfName.text = '';
	objSwf.tfCondition.text = '';
	objSwf.tfAttr.text = '';
	objSwf.tfBenefit.text = '';
	objSwf.btnSure.click = function() self:OnSureClick(); end
end
function UIGoalTuiSong:OnSureClick()
	UIGoal:ShowTouch()
	self:Hide()	
end
function UIGoalTuiSong:SetInfo()
	self:StopTimer()
	local objSwf = self.objSwf;
	if not objSwf then
		return; 
	end
	if not self.currShow then
		return;
	end

	objSwf.tfCondition.text = '';
	-- objSwf.tfName.text = self.currShow.cnf.name_icon;
	self.objSwf.nameLoader.source = ResUtil:GetGoalName(self.currShow.cnf.name_icon)
	objSwf.tfBenefit.htmlText = self:SetLeftMargin(self:GetPower(),9);
	objSwf.tfAttr.htmlText = self:SetLeftMargin(self:GetWord2(),9);
	objSwf.iconDes.source = ResUtil:GetGoalIcon(self.currShow.cnf.word1)
	self:SetCondition();
	self:DrawDummy();
	self:StartTimer1();
	
	-- local tipsX,tipsY = TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),self.tipsDir);
	-- objSwf._x = 500;
	-- objSwf._y = 500;
end
function UIGoalTuiSong:GetWidth()
	return 921
end;
function UIGoalTuiSong:GetHeight()
	return 417
end;
--设置行间距
--要给一段文字设置行间距,这段文字的最后不应该有换行
function UIGoalTuiSong:SetLineSpace(text,lineSpace)
	return "<textformat leading='".. lineSpace .."'>" .. text .. "</textformat>";
end
--战力
function UIGoalTuiSong:GetPower()
	local str = "";
	if self.currShow.cnf.power and self.currShow.cnf.power ~= "" then
		str = str .. self:GetHtmlText(self.currShow.cnf.power, "#00FF12",23,false);
	end
	str = self:SetLineSpace(str,5);
	return str;
end
--描述
function UIGoalTuiSong:GetWord2()
	local str = "";
	if self.currShow.cnf.word2 and self.currShow.cnf.word2 ~= "" then
		str = str .. self:GetHtmlText(self.currShow.cnf.word2, "#DAA400",14,false);
	end
	str = self:SetLineSpace(str,5);
	return str;
end
--获取Html文本
--@param text 显示的内容
--@param color 字体颜色
--@param size 字号
--@param withBr 是否换行,默认true
--@param bold 	是否加粗,默认false
function UIGoalTuiSong:GetHtmlText(text,color,size,withBr,bold)
	if not color then color = TipsConsts.Default_Color; end
	if not size then size = TipsConsts.Default_Size; end
	if withBr==nil then withBr = true; end
	if bold==nil then bold = false; end
	local str = "<font color='" .. color .."' size='" .. size .. "'>";
	if bold then
		str = str .. "<b>" .. text .. "</b>";
	else
		str = str .. text;
	end
	str = str .. "</font>";
	if withBr then
		str = str .. "<br/>";
	end
	return str;
end
--设置左边距
function UIGoalTuiSong:SetLeftMargin(text,margin)
	return "<textformat leftmargin='".. margin .."'>" .. text .. "</textformat>";
end


function UIGoalTuiSong:SetCondition()
	local objSwf = self.objSwf;
	if not objSwf then
		return; 
	end
	if self.currShow.cnf.time and self.currShow.cnf.time~=0 then
		self:StartTimer();
		return;
	end
	if self.currShow.cnf.level and self.currShow.cnf.level~=0 then
		objSwf.tfCondition.htmlText = string.format( StrConfig['goal002'], self.currShow.cnf.level);
		if self.currShow.state ==1 then
			objSwf.tfCondition.text = StrConfig['goal005'];
		end
		return;
	end
	if self.currShow.cnf.day and self.currShow.cnf.day~=0 then
		objSwf.tfCondition.htmlText = string.format( StrConfig['goal003'], self.currShow.cnf.day);
		if GoalModel.onlineDay >= self.currShow.cnf.day then
			objSwf.tfCondition.text = StrConfig['goal005'];
		end
		return;
	end
end
local timerKey;
local time;
function UIGoalTuiSong:StartTimer()
	
	-- time =self.currShow.cnf.time - GoalModel.onlineTime ;
	time =self.currShow.cnf.time - (GetServerTime()-GoalModel.getAServerTime+GoalModel.onlineTime) ;
	local cb = function(count)
		self:OnTimer(count);
	end
	timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if time>0 then
		local hour,min,sec = self:OnBackNowLeaveTime(time);
		self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal001'],min ,sec);
	else
		self.objSwf.tfCondition.text = string.format( StrConfig['goal005']);
	end
end
function UIGoalTuiSong:OnBackNowLeaveTime(num)
	if num>0 then
		local hour,min,sec = CTimeFormat:sec2format(num);
		if hour < 10 then hour = '0' .. hour; end
		if min < 10 then min = '0' .. min; end 
		if sec < 10 then sec = '0' .. sec; end 
		return hour,min,sec
	end
end

function UIGoalTuiSong:OnTimer(count)
	-- time = time - 1;
	if time == 0 or time < 0 then
		
		self:OnTimeUp();
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if time>0 then
		local hour,min,sec = self:OnBackNowLeaveTime(time);
		self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal001'],min,sec );
	else
		self.objSwf.tfCondition.text = string.format( StrConfig['goal005']);
	end
end
function UIGoalTuiSong:OnTimeUp()
	local objSwf = self.objSwf;
	if not objSwf then
		return; 
	end

	self:StopTimer();
	objSwf.tfCondition.text = StrConfig['goal005'];
end
function UIGoalTuiSong:OnShow()
	self:SetInfo();
end
function UIGoalTuiSong:StopTimer()
	-- WriteLog(LogType.Normal,true,'---------------------UIGoal:timerKey()',timerKey)
	if timerKey then
		
		TimerManager:UnRegisterTimer(timerKey,true);
		timerKey = nil;
	end
end

function UIGoalTuiSong:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	self:DisposeDummy();
	self.currShow = nil;
	if self.timerKey1 then
		TimerManager:UnRegisterTimer( self.timerKey1 );
		self.timerKey1 = nil;
	end
end

local viewPort = nil;
function UIGoalTuiSong:DrawDummy()
	self:DisposeDummy();

	local config = self.currShow.cnf;
	if not config then
		return;
	end	
	local objSwf = self.objSwf;
	if not objSwf then
		return; 
	end
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1100, 500); end
		self.objUIDraw = UISceneDraw:new( "UIGoalTuiSongModelUI", objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader(objSwf.avatarLoader);
	local model_tips = nil;
	if self.currShow.id==1002 then
		if config.model_tips == "" then return; end
		local t = split(config.model_tips,"#");
		model_tips =t[MainPlayerModel.humanDetailInfo.eaProf];
	else
		model_tips = config.model_tips
	end
	self.objUIDraw:SetScene( model_tips );
	-- print('----------------------------model_tips-',model_tips)
	self.objUIDraw:SetDraw( true );
end

function UIGoalTuiSong:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	end
end
function UIGoalTuiSong:ShowTips(goal)
	-- print('------------------UIGoalTuiSong:ShowTips(goal)')
	if not goal then
		return;
	end
	self.currShow = goal
	if self:IsShow() then
		self:OnShow();
	else
		self:Show();
	end
end

function UIGoalTuiSong:HandleNotification(name,body)
	-- if name == NotifyConsts.StageMove then
		-- local objSwf = self.objSwf;
		-- if not objSwf then return; end
		-- local tipsX,tipsY = TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),self.tipsDir);
		-- objSwf._x = 500 
		-- objSwf._y = 500;
	-- elseif name == NotifyConsts.StageClick then
		-- self:OnHide();
	-- end
end


function UIGoalTuiSong:ListNotificationInterests()
	-- return {NotifyConsts.StageMove,NotifyConsts.StageClick};
end

function UIGoalTuiSong:IsTween()
	return false;
end

---------------------------------倒计时处理--------------------------------
local time1;
UIGoalTuiSong.timerKey1 = nil
function UIGoalTuiSong:StartTimer1()
	time1 = 10;
	local func = function() self:OnTimer1(); end
	self.timerKey1 = TimerManager:RegisterTimer( func, 1000, 0 );
	self:UpdateCountDown();
end

function UIGoalTuiSong:OnTimer1()
	time1 = time1 - 1;
	if time1 <= 0 then
		self:StopTimer1();
		self:OnTimeUp1();
		return;
	end
	self:UpdateCountDown();
end

function UIGoalTuiSong:OnTimeUp1()
	UIGoal:ShowTouch()
	self:Hide()
end

function UIGoalTuiSong:StopTimer1()
	if self.timerKey1 then
		TimerManager:UnRegisterTimer( self.timerKey1 );
		self.timerKey1 = nil;
		self:HideCountDown();
	end
end

function UIGoalTuiSong:HideCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.txtTime._visible = false;
end

function UIGoalTuiSong:UpdateCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local txtTime = objSwf.txtTime;
	if not txtTime._visible then
		txtTime._visible = true;
	end
	objSwf.txtTime.htmlText = string.format( StrConfig['goal006'], time1);
end

function UIGoalTuiSong:UpdateCountDown()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local txtTime = objSwf.txtTime;
	if not txtTime._visible then
		txtTime._visible = true;
	end
	-- WriteLog(LogType.Normal,true,'---------------------UIQuestDayReward:UpdateCountDown()',time)
	objSwf.txtTime.htmlText = string.format( StrConfig['goal006'], time1 );
end
