_G.UIGoalTips = BaseUI:new("UIGoalTips");
UIGoalTips.currShow = nil;
function UIGoalTips:Create()
	self:AddSWF("GoalPanelTips.swf",true,"center");
end
function UIGoalTips:OnLoaded(objSwf)
	-- objSwf.hitTestDisable = true
	-- objSwf.tfName.text = '';
	objSwf.tfCondition.text = '';
	objSwf.tfAttr.text = '';
	objSwf.tfBenefit.text = '';
	-- objSwf.btnSure.click = function() self:OnSureClick(); end
	objSwf.txtTime._visible = false
	objSwf.btnSure._visible = false
end
function UIGoalTips:OnSureClick()
	self:Hide()	
end
function UIGoalTips:SetInfo()
	self:StopTimer()
	local objSwf = self.objSwf;
	if not objSwf then
		return; 
	end
	if not self.currShow then
		return;
	end

	objSwf.tfCondition._visible = false
	-- objSwf.tfName._visible = false		
	objSwf.nameLoader._visible = false		
	objSwf.tfCondition.text = '';
	-- objSwf.tfName.text = self.currShow.cnf.name_icon;
	self.objSwf.nameLoader.source = ResUtil:GetGoalName(self.currShow.cnf.name_icon)
	objSwf.tfBenefit.htmlText = self:SetLeftMargin(self:GetPower(),9);
	objSwf.tfAttr.htmlText = self:SetLeftMargin(self:GetWord2(),9);
	objSwf.iconDes.source = ResUtil:GetGoalIcon(self.currShow.cnf.word1)
	self:SetCondition();
	self:DrawDummy();
	-- self:StartTimer1();
	
	-- local tipsX,tipsY = TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),self.tipsDir);
	-- objSwf._x = 500;
	-- objSwf._y = 500;
end
function UIGoalTips:GetWidth()
	return 921
end;
function UIGoalTips:GetHeight()
	return 417
end;
--设置行间距
--要给一段文字设置行间距,这段文字的最后不应该有换行
function UIGoalTips:SetLineSpace(text,lineSpace)
	return "<textformat leading='".. lineSpace .."'>" .. text .. "</textformat>";
end
--战力
function UIGoalTips:GetPower()
	local str = "";
	if self.currShow.cnf.power and self.currShow.cnf.power ~= "" then
		str = str .. self:GetHtmlText(self.currShow.cnf.power, "#00FF12",23,false);
	end
	str = self:SetLineSpace(str,5);
	return str;
end
--描述
function UIGoalTips:GetWord2()
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
function UIGoalTips:GetHtmlText(text,color,size,withBr,bold)
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
function UIGoalTips:SetLeftMargin(text,margin)
	return "<textformat leftmargin='".. margin .."'>" .. text .. "</textformat>";
end


function UIGoalTips:SetCondition()
	if self.currShow.cnf.time and self.currShow.cnf.time~=0 then
		self:StartTimer();
		return;
	end
	if self.currShow.cnf.level and self.currShow.cnf.level~=0 then
		self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal002'], self.currShow.cnf.level);
		if self.currShow.state ==1 then
			self.objSwf.tfCondition.text = StrConfig['goal005'];
		end
		return;
	end
	if self.currShow.cnf.day and self.currShow.cnf.day~=0 then
		self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal003'], self.currShow.cnf.day);
		if GoalModel.onlineDay >= self.currShow.cnf.day then
			self.objSwf.tfCondition.text = StrConfig['goal005'];
		end
		return;
	end
end
local timerKey;
local time;
function UIGoalTips:StartTimer()
	
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
function UIGoalTips:OnBackNowLeaveTime(num)
	if num>0 then
		local hour,min,sec = CTimeFormat:sec2format(num);
		if hour < 10 then hour = '0' .. hour; end
		if min < 10 then min = '0' .. min; end 
		if sec < 10 then sec = '0' .. sec; end 
		return hour,min,sec
	end
end

function UIGoalTips:OnTimer(count)
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
function UIGoalTips:OnTimeUp()
	local objSwf = self.objSwf;
	if not objSwf then
		return; 
	end

	self:StopTimer();
	objSwf.tfCondition.text = StrConfig['goal005'];
end
function UIGoalTips:OnShow()
	self:SetInfo();
end
function UIGoalTips:StopTimer()
	-- WriteLog(LogType.Normal,true,'---------------------UIGoal:timerKey()',timerKey)
	if timerKey then
		
		TimerManager:UnRegisterTimer(timerKey,true);
		timerKey = nil;
	end
end

function UIGoalTips:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	self:DisposeDummy();
	self.currShow = nil;
	-- if timerKey1 then
		-- TimerManager:UnRegisterTimer( timerKey1 );
		-- timerKey1 = nil;
	-- end
end

local viewPort = nil;
function UIGoalTips:DrawDummy()
	self:DisposeDummy();

	local config = self.currShow.cnf;
	if not config then
		return;
	end	
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1100, 500); end
		self.objUIDraw = UISceneDraw:new( "UIGoalTipsModelUI", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader(self.objSwf.avatarLoader);
	local model_tips = nil;
	-- if self.currShow.id==1002 then
		-- if config.model_tips == "" then return; end
		-- local t = split(config.model_tips,"#");
		-- model_tips =t[MainPlayerModel.humanDetailInfo.eaProf];
	-- else
		model_tips = config.model_tips
	-- end
	self.objUIDraw:SetScene( model_tips );
	-- print('----------------------------model_tips-',model_tips)
	self.objUIDraw:SetDraw( true );
end

function UIGoalTips:DisposeDummy()
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	end
end
function UIGoalTips:ShowTips(goal)
	-- print('------------------UIGoalTips:ShowTips(goal)')
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

function UIGoalTips:HandleNotification(name,body)
	-- if name == NotifyConsts.StageMove then
		-- local objSwf = self.objSwf;
		-- if not objSwf then return; end
		-- local tipsX,tipsY = TipsUtils:GetTipsPos(self:GetWidth(),self:GetHeight(),self.tipsDir);
		-- objSwf._x = 500;
		-- objSwf._y = 500;
	-- elseif name == NotifyConsts.StageClick then
		-- self:OnHide();
	-- end
end


function UIGoalTips:ListNotificationInterests()
	-- return {NotifyConsts.StageMove,NotifyConsts.StageClick};
end

function UIGoalTips:IsTween()
	return true;
end
--执行缓动
function UIGoalTips:DoTweenHide()
	local endX,endY;
	-- if self.tweenStartPos then
		-- endX = self.tweenStartPos.x;
		-- endY = self.tweenStartPos.y;
	-- else
	local pos = UIGoal:GetTouchPos();
	local endX = pos.x;
	local endY = pos.y;
		-- endX = 0;
		-- endY = winH/2;
	-- end
	--
	local objSwf = self.objSwf;
	if not objSwf then return; end
	-- local mc = self.swfCfg.objSwf.content;			
	Tween:To(objSwf,0.45,{_alpha=0,_width=20,_height=20,_x=endX,_y=endY},
				{onComplete=function()
					self:DoHide();
					objSwf._xscale = 100;
					objSwf._yscale = 100;
					objSwf._alpha = 100;
				end},true);
end
---------------------------------倒计时处理--------------------------------
-- local time1;
-- local timerKey1;
-- function UIGoalTips:StartTimer1()
	-- time1 = 10;
	-- local func = function() self:OnTimer1(); end
	-- timerKey1 = TimerManager:RegisterTimer( func, 1000, 0 );
	-- self:UpdateCountDown();
-- end

-- function UIGoalTips:OnTimer1()
	-- time1 = time1 - 1;
	-- if time1 <= 0 then
		-- self:StopTimer1();
		-- self:OnTimeUp1();
		-- return;
	-- end
	-- self:UpdateCountDown();
-- end

-- function UIGoalTips:OnTimeUp1()
	-- self:Hide()
-- end

-- function UIGoalTips:StopTimer1()
	-- if timerKey1 then
		-- TimerManager:UnRegisterTimer( timerKey1 );
		-- timerKey1 = nil;
		-- self:HideCountDown();
	-- end
-- end

-- function UIGoalTips:HideCountDown()
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	-- objSwf.txtTime._visible = false;
-- end

-- function UIGoalTips:UpdateCountDown()
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	-- local txtTime = objSwf.txtTime;
	-- if not txtTime._visible then
		-- txtTime._visible = true;
	-- end
	-- objSwf.txtTime.htmlText = string.format( StrConfig['goal006'], time1);
-- end

-- function UIGoalTips:UpdateCountDown()
	-- local objSwf = self.objSwf;
	-- if not objSwf then return; end
	-- local txtTime = objSwf.txtTime;
	-- if not txtTime._visible then
		-- txtTime._visible = true;
	-- end
	-- objSwf.txtTime.htmlText = string.format( StrConfig['goal006'], time1 );
-- end