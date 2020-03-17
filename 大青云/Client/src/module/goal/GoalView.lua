_G.UIGoal = BaseUI:new("UIGoal");
UIGoal.currShow = nil;
UIGoal.getCurrServerTime = nil;
UIGoal.funcID = 0
function UIGoal:Create()
	self:AddSWF("GoalPanel.swf",true,"center");
end

function UIGoal:OnLoaded(objSwf)
	-- objSwf.tfName.text = '';
	objSwf.tfCondition.text = '';
	objSwf.btnGet._visible = false;
	objSwf.btnGet.click = function() self:OnGetClick(); end
	objSwf.getEffect._visible = false;
	objSwf.effect._visible = false;
	self.objSwf.btnJihuo._visible = false;
	self.objSwf.btnJihuo.click = function() self:OnBtnJiHuoClick(); end;
	-- objSwf.bearEffect._visible = true;
	objSwf.touch.rollOver = function() self:OnTouchrollOver(); end
	objSwf.touch.rollOut = function() self:OnTouchRollOut(); end
end
function UIGoal:OnShow()
	if self.timerKey1 then
		TimerManager:UnRegisterTimer(self.timerKey1)
		self.timerKey1 = nil;
	end
	self:SetInfo();
end
function UIGoal:OnTouchrollOver()
	-- print('--------------UIGoal:OnTouchrollOver()-')
	if self.currShow then
		-- print('-----------------UIGoal:OnTouchrollOver()-self:SetInfo();',self.currShow.id)
		TipsManager:ShowGoalTips(self.currShow);
	end
end

function UIGoal:OnTouchRollOut()
	TipsManager:Hide();
end
function UIGoal:OnBtnJiHuoClick()
	if not self.currShow then
		return;
	end	
	self.funcID = toint(self.currShow.cnf.funcOpen)
	UIOpenFunInfo:ShowInfo(self.funcID,OpenFunByDayConst.showJihuo)
end
function UIGoal:ShowTouch()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.touch._visible = true;
	UIGoalTuiSong:Hide()
end
function UIGoal:showTips(lv)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.currShow.id == 1001 then
		if lv==10 then
			objSwf.touch._visible =false;
			UIGoalTuiSong:ShowTips(self.currShow);
		end
	end
end

function UIGoal:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then 
	   return; 
	end
	self:DisposeDummy();
	self.currShow = nil;
	self.model = nil
end
function UIGoal:ListNotificationInterests()
	return {NotifyConsts.GoalListChange,
		NotifyConsts.PlayerAttrChange};
end

function UIGoal:HandleNotification(name,body)
	if name == NotifyConsts.GoalListChange then
		self:SetInfo();
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then  -- 10
			-- self:showTips(body.val);--去掉十级推送
			self:SetInfo();
		end
	end
end

function UIGoal:SetInfo()
	self:StopTimer()
	self.currShow = nil;
	local goal = GoalModel:GetShowing()
	if GoalModel:CheckAllOver() then
		self:Hide();
		return;
	end
	self.objSwf.tfCondition.text = '';
	self.objSwf.btnGet._visible = false;
	self.objSwf.getEffect._visible = false;
	self.objSwf.effect._visible = false;
	self.currShow = goal;
	-- self.objSwf.tfName.text = self.currShow.cnf.name_icon;
	if self.objSwf.nameLoader.source ~= ResUtil:GetGoalName(self.currShow.cnf.name_icon) then
		self.objSwf.nameLoader.source = ResUtil:GetGoalName(self.currShow.cnf.name_icon)
	end

	self:DrawDummy();
	self:SetCondition();
end
function UIGoal:SetCondition()
	if self.currShow.cnf.condition==5 then
		self:IsToTask();
		return;
	end
	if self.currShow.cnf.condition==3 then
		self:IsToTrueDay();
		return;
	end
	if self.currShow.cnf.time and self.currShow.cnf.time~=0 then
		self:StartTimer();
		return;
	end
	if self.currShow.cnf.day and self.currShow.cnf.day~=0 then
		self:IsToDay();
		return;
	end
	if self.currShow.cnf.level and self.currShow.cnf.level~=0 then
		self:IsToLevel();
		return;
	end
end
function UIGoal:IsToTrueDay()
	if not self.currShow then
		return;
	end
	self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal008'], self.currShow.cnf.quest_display);
end
function UIGoal:IsToTask()
	if not self.currShow then
		return;
	end
	self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal008'], self.currShow.cnf.quest_display);
end
function UIGoal:IsToLevel()
	if not self.currShow then
		return;
	end

	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	if self.currShow.cnf.item == 0 then
		self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal0002'], self.currShow.cnf.level);
	else
		self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal002'], self.currShow.cnf.level);
	end
	-- if playerinfo.eaLevel >= self.currShow.cnf.level then
	if self.currShow.state ==1 then
		self.objSwf.btnGet._visible = true;
		self.objSwf.getEffect._visible = true;
		self.objSwf.effect._visible = true;
		if self.currShow.cnf.item == 0 then
			self.objSwf.tfCondition.htmlText = StrConfig['goal0005'];
		else
			self.objSwf.tfCondition.htmlText = StrConfig['goal005'];
		end
	else
		self.objSwf.btnGet._visible = false;
		self.objSwf.getEffect._visible = false;
		self.objSwf.effect._visible = false;
	end
end
function UIGoal:IsToDay()
	if not self.currShow then
		return;
	end	
	-- self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal003'], self.currShow.cnf.day);
	self.objSwf.btnJihuo._visible = false;
	if self.currShow.cnf.condition == 4 then
		if self.currShow.state == 1 then
			self.objSwf.btnGet._visible = false;
			self.funcID = toint(self.currShow.cnf.funcOpen)
			if MainPlayerModel.humanDetailInfo.eaLevel>=self.currShow.cnf.level then
				self.objSwf.tfCondition.text = StrConfig['goal0005'];
				self.objSwf.effect._visible = true;
				self.objSwf.btnJihuo._visible = true;
			else
				self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal0002'], self.currShow.cnf.level);
			end
			return
		end
		if GoalModel.normalDay<self.currShow.cnf.day then
			self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal003'], self.currShow.cnf.day);
			return
		end
		if MainPlayerModel.humanDetailInfo.eaLevel<self.currShow.cnf.level then
			self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal0002'], self.currShow.cnf.level);
			return
		end
	-- elseif GoalModel.onlineDay >= self.currShow.cnf.day then
		-- self.objSwf.btnGet._visible = false;
		-- self.funcID = toint(self.currShow.cnf.funcOpen)
		-- if MainPlayerModel.humanDetailInfo.eaLevel>=self.currShow.cnf.level then
			-- self.objSwf.tfCondition.text = StrConfig['goal0005'];
			-- self.objSwf.effect._visible = true;
			-- self.objSwf.btnJihuo._visible = true;
		-- else
			-- self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal0002'], self.currShow.cnf.level);
			
		-- end
	end
end
local timerKey;
local time;
function UIGoal:StartTimer()
	time =self.currShow.cnf.time - (GetServerTime()-GoalModel.getAServerTime+GoalModel.onlineTime) ;
	local cb = function(count)
		self:OnTimer(count);
	end
	timerKey = TimerManager:RegisterTimer( cb, 1000, 0 );
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local hour,min,sec = self:OnBackNowLeaveTime(time);
	self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal001'], min ,sec);
	self.objSwf.btnGet._visible = false;
	self.objSwf.getEffect._visible = false;
	self.objSwf.effect._visible = false;

end
function UIGoal:OnBackNowLeaveTime(num)
	local hour,min,sec = CTimeFormat:sec2format(num);
	if hour < 10 then hour = '0' .. hour; end
	if min < 10 then min = '0' .. min; end 
	if sec < 10 then sec = '0' .. sec; end 
	return hour,min,sec
end

function UIGoal:OnTimer(count)
	time = self.currShow.cnf.time - (GetServerTime()-GoalModel.getAServerTime+GoalModel.onlineTime);
	if time < 0 then
		
		self:OnTimeUp();
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local hour,min,sec = self:OnBackNowLeaveTime(time);
	self.objSwf.tfCondition.htmlText = string.format( StrConfig['goal001'], min,sec );
end
function UIGoal:OnTimeUp()
	if self.currShow.state==1 then
		self.objSwf.tfCondition.text = StrConfig['goal005'];
		self:StopTimer();
		self.objSwf.btnGet._visible = true;
		self.objSwf.getEffect._visible = true;
		self.objSwf.effect._visible = true;
	end
end

function UIGoal:getTime()
	return time;
end
function UIGoal:GetWidth()
	return 302;
end

function UIGoal:GetHeight()
	return 318;
end
UIGoal.timerKey1 = nil;
function UIGoal:OnGetClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.currShow then
		return;
	end	
	
	
	GoalController:SendGoalReward(self.currShow.id);
	-- if self.currShow.id==1002 then
		-- QuestScriptManager:DoScript("wuqifuncguide")
	-- end
	-- if self.currShow.id==1002 then
		-- LovelyPetController:ReqActiveLovelyPet(1);
	-- end
	-- if self.currShow.id==1004 then
		-- local paramlist = split(self.currShow.cnf.clientParam,",");
		-- NoticeScriptManager:DoScript(self.currShow.cnf.script,paramlist);
	-- end
	objSwf.btnGet._visible = false;
	objSwf.getEffect._visible = false;
	objSwf.effect._visible = false;
	
	self.timerKey1 = TimerManager:RegisterTimer(function()
			UIGoalTuiSong:ShowTips(self.currShow);
			local objSwf = self.objSwf;
			if not objSwf then return; end
			objSwf.touch._visible =false;
			if self.timerKey1 then
				TimerManager:UnRegisterTimer(self.timerKey1)
				self.timerKey1 = nil;
			end
		end,10000,1);
end

function UIGoal:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer(timerKey,true);
		timerKey = nil;
	end
end


local viewPort = nil;
function UIGoal:DrawDummy()
	local config = self.currShow.cnf;
	if not config then
		return;
	end	
	if self.model and self.model == config.model then
		return
	end
	
	self:DisposeDummy();
	self.model = config.model
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(350, 173); end
		self.objUIDraw = UISceneDraw:new( "GoalModelUI", self.objSwf.avatarLoader, viewPort );
	end
	self.objUIDraw:SetUILoader(self.objSwf.avatarLoader);

	self.objUIDraw:SetScene( self.model );
	self.objUIDraw:SetDraw( true );
end
function UIGoal:getModel()
	local cfg = {};
	cfg = t_mubiao[1002];
	if not cfg then
		return;
	end
	if cfg.model == "" then return; end
	local t = split(cfg.model,"#");
	local model =t[MainPlayerModel.humanDetailInfo.eaProf];	
	return model;
end
function UIGoal:getModelId()
	local cfg = {};
	cfg = t_mubiao[1002];
	if not cfg then
		return;
	end
	if cfg.equip == "" then return; end
	local t = split(cfg.equip,"#");
	local modelId =toint(t[MainPlayerModel.humanDetailInfo.eaProf]);	
	return modelId;
end
function UIGoal:DisposeDummy()
	-- print('------------------UIGoal:DisposeDummy()')
	if self.objUIDraw then
	   self.objUIDraw:SetDraw(false);
	end
end
function UIGoal:GetTouchPos()
	local objSwf = self.objSwf;
	if not objSwf then return {x=0,y=0}; end
	return UIManager:PosLtoG(objSwf.touch,0,0);
end