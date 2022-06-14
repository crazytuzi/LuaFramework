local idolStatus = class( "idolStatus", layout );

global_event.IDOLSTATUS_SHOW = "IDOLSTATUS_SHOW";
global_event.IDOLSTATUS_HIDE = "IDOLSTATUS_HIDE";
global_event.IDOLSTATUS_ONENTER_LEVEL_UP = "IDOLSTATUS_ONENTER_LEVEL_UP";
global_event.IDOLSTATUS_ONQUIT_LEVEL_UP = "IDOLSTATUS_ONQUIT_LEVEL_UP";
global_event.IDOLSTATUS_UPDATE = "IDOLSTATUS_UPDATE";

function idolStatus:ctor( id )
	idolStatus.super.ctor( self, id );
	self:addEvent({ name = global_event.IDOLSTATUS_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.IDOLSTATUS_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.IDOLSTATUS_ONENTER_LEVEL_UP, eventHandler = self.onEnterLevelUp});
	self:addEvent({ name = global_event.IDOLSTATUS_ONQUIT_LEVEL_UP, eventHandler = self.onQuitLevelUp});
	self:addEvent({ name = global_event.IDOLSTATUS_UPDATE, eventHandler = self.onUpdateInfo});
end

function idolStatus:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onIdolStatusClickClose()
		self:onHide();
	end
	
	function onIdolStatusClickLevelUp()
		
		dataManager.idolBuildData:onClickEnterIdolLevelup();
		
	end
	
	function onIdolStatusClickBuyProtectTime()
		
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", resType = enum.BUY_RESOURCE_TYPE.PROTECT_TIME,});
		
	end
	
	local idolStatus_close = self:Child( "idolStatus-close" );
	idolStatus_close:subscribeEvent("ButtonClick", "onIdolStatusClickClose");
	
	local idolStatus_level = self:Child( "idolStatus-level" );
	idolStatus_level:subscribeEvent("ButtonClick", "onIdolStatusClickLevelUp");
	
		
	
	local idolStatus_robshell_add = self:Child("idolStatus-robshell-add");
	idolStatus_robshell_add:subscribeEvent("ButtonClick", "onIdolStatusClickBuyProtectTime");
	
	self.updateProtectTimer = scheduler.scheduleGlobal(function() 
		self:updateProtectTime();
	end, 1);
	
	function onIdolStatusClickRevenge()
		
		eventManager.dispatchEvent({name = global_event.REVENGEPLUNDERLIST_SHOW});
		
	end
	
	local idolStatus_revenge = self:Child("idolStatus-revenge");
	idolStatus_revenge:subscribeEvent("ButtonClick", "onIdolStatusClickRevenge");
	
	self:onUpdateInfo();
	--触发引导
	eventManager.dispatchEvent({ name = global_event.GUIDE_ON_IDOLSTATUS_OPEN }) 
end

function idolStatus:onHide(event)
	
	if self.updateProtectTimer then
		scheduler.unscheduleGlobal(self.updateProtectTimer);
		self.updateProtectTimer = nil;
	end
	
	self:Close();
	homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.GONGHUI);
	
end

-- 更新保护时间
function idolStatus:updateProtectTime()
	
	if not self._show then
		return;
	end
	
	local robshell_time = self:Child("idolStatus-robshell-time");
	robshell_time:SetText(formatTime(dataManager.idolBuildData:getRemainProtectTime()));
		
end

-- 进入升级界面
function idolStatus:onEnterLevelUp()
	
	if not self._show then
		return;
	end

	function onIdolEnterLevelupEnd()
		
		local idolStatus_caikuang = self:Child("idolStatus-caikuang");
		local idolStatus_anniu = self:Child("idolStatus-anniu");
		
		idolStatus_caikuang:SetVisible(false);
		idolStatus_anniu:SetVisible(false);
		
	end
				
	-- 向左移动
	local idolStatus_caikuang = self:Child("idolStatus-caikuang");
	local action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatus_caikuang:removeEvent("UIActionEnd");
	idolStatus_caikuang:subscribeEvent("UIActionEnd", "onIdolEnterLevelupEnd");
	idolStatus_caikuang:playAction(action);	
			
	
	-- 中间的隐藏
	local idolStatus_rob = self:Child("idolStatus-rob");
	local idolStatus_bigbg = self:Child( "idolStatus-bigbg" );
	idolStatus_bigbg:SetVisible(false);
	idolStatus_rob:SetVisible(false);
	
	
	-- 向右移动
	local idolStatus_anniu = self:Child("idolStatus-anniu");

	local action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatus_anniu:removeEvent("UIActionEnd");
	idolStatus_anniu:playAction(action);
		
end

-- 退出升级界面
function idolStatus:onQuitLevelUp()
	
	if not self._show then
		return;
	end

	-- 向左移动
	local idolStatus_caikuang = self:Child("idolStatus-caikuang");
	idolStatus_caikuang:SetVisible(true);
	local action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatus_caikuang:removeEvent("UIActionEnd");
	idolStatus_caikuang:playAction(action);	
			
	
	-- 中间的隐藏
	local idolStatus_rob = self:Child("idolStatus-rob");
	local idolStatus_bigbg = self:Child( "idolStatus-bigbg" );
	idolStatus_bigbg:SetVisible(true);
	idolStatus_rob:SetVisible(true);
	
	
	-- 向右移动
	local idolStatus_anniu = self:Child("idolStatus-anniu");

	local action = LORD.GUIAction:new();
	idolStatus_anniu:SetVisible(true);
	action:addKeyFrame(LORD.Vector3(500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatus_anniu:removeEvent("UIActionEnd");
	idolStatus_anniu:playAction(action);
		
end

-- 更新ui上的信息
function idolStatus:onUpdateInfo()
	
	if not self._show then
		return;
	end
	
	-- build info
	local title_lv_num = self:Child("idolStatus-title-lv-num");
	local soldier_num = self:Child("idolStatus-soldier-num");
	local atk_num = self:Child("idolStatus-atk-num");
	local def_num = self:Child("idolStatus-def-num");
	local crit_num = self:Child("idolStatus-crit-num");
	local ten_num = self:Child("idolStatus-ten-num");
	
	local idolConfig = dataManager.idolBuildData:getConfig();
	title_lv_num:SetText(dataManager.idolBuildData:getLevel());
	soldier_num:SetText("+"..idolConfig.soldier);
	atk_num:SetText("+"..idolConfig.shipAttrBase[1].attack);
	def_num:SetText("+"..idolConfig.shipAttrBase[1].defence);
	crit_num:SetText("+"..idolConfig.shipAttrBase[1].critical);
	ten_num:SetText("+"..idolConfig.shipAttrBase[1].resilience);
	
	-- plunder times
	local showtime_num = self:Child("idolStatus-showtime-num");
	showtime_num:SetText(dataManager.idolBuildData:getReminePlunderTimes().."/"..dataManager.idolBuildData:getMaxPlunderTimes());
	
	-- refresh time
	local showtime_retimenum = self:Child("idolStatus-showtime-retimenum");
	showtime_retimenum:SetText(dataManager.idolBuildData:getNextRefreshPlunderTimesTime());
	
	-- protect time
	local robshell_time = self:Child("idolStatus-robshell-time");
	robshell_time:SetText(formatTime(dataManager.idolBuildData:getRemainProtectTime()));
	
	local revenge_tishi = self:Child("idolStatus-revenge-tishi");
	revenge_tishi:SetVisible(dataManager.idolBuildData:isNeedRevenge());
	
	function onClickIdolStatusPlunder(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local primalType = window:GetUserData();
		dataManager.idolBuildData:onClickPlunder(primalType);
		
	end
	
	-- item	
	for i=1, 4 do
		
		local robthing = self:Child("idolStatus-robthing"..i);
		local robthing_num = self:Child("idolStatus-robthing"..i.."-num");
		local robthing_button = self:Child("idolStatus-robthing"..i.."-button");
		local robthing_image = LORD.toStaticImage(self:Child("idolStatus-robthing"..i.."-image"));

		-- tips
		robthing_image:SetUserData(i-1);
		global.onItemTipsShow(robthing_image, enum.REWARD_TYPE.REWARD_TYPE_PRIMAL, "top");
		global.onItemTipsHide(robthing_image);
						
		local primalItemInfo = dataManager.idolBuildData:getPrimalItemInfo(i-1);
		robthing_image:SetImage(primalItemInfo.icon);
		
		local itemCount = dataManager.idolBuildData:getPrimalItemCount(i-1);
		local needCount = idolConfig.retuireItemCount;

		if dataManager.idolBuildData:isMaxLevel() then
			robthing_num:SetText(itemCount);
		else
			if itemCount >= needCount then
				robthing_num:SetText(itemCount.."/"..needCount);
			else
				robthing_num:SetText("^FF0000"..itemCount.."/"..needCount);
			end
		end	
		
		-- userdata is primal type
		robthing_button:SetUserData(i-1);
		robthing_button:removeEvent("ButtonClick");
		robthing_button:subscribeEvent("ButtonClick", "onClickIdolStatusPlunder");
	end
	
end

return idolStatus;
