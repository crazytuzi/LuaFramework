local activity = class( "activity", layout );

global_event.ACTIVITY_SHOW = "ACTIVITY_SHOW";
global_event.ACTIVITY_HIDE = "ACTIVITY_HIDE";

function activity:ctor( id )
	activity.super.ctor( self, id );
	self:addEvent({ name = global_event.ACTIVITY_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ACTIVITY_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_BATTLE, eventHandler = self.onHide});
end

function activity:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onClickActivityClose()
		self:onHide();
	end
	
	-- init all activity Info
	self:initAllActivity();
	
	local activity_close = self:Child("activity-close");
	
	activity_close:subscribeEvent("ButtonClick", "onClickActivityClose");
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_ACTIVE})
end

-- 初始化所有的活动信息
function activity:initAllActivity()
	
	if not self._show then
		return;
	end
	
	function onClickActivityEnter(args)
		local window = LORD.toWindowEventArgs(args).window;
		local activityType = window:GetUserData();
		
		uiaction.scale(window, 0.8);

		scheduler.performWithDelayGlobal(function()
			dataManager.activityInfoData:enterActivityHandle(activityType);
			LORD.SoundSystem:Instance():playEffect("maoxian.mp3");
		end, 0.2)
				
		
		
	end
	
	local activity_sp = LORD.toScrollPane(self:Child("activity-sp"));
	activity_sp:init();
	activity_sp:ClearAllItem();
	
	local xpos = LORD.UDim(0,0);
	local ypos = LORD.UDim(0,20);
	
	for k,v in ipairs(dataConfig.configs.activityInfoConfig) do
		
		local activityitem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("activity"..k, "activityitem.dlg");
		activityitem:SetXPosition(xpos);
		activityitem:SetYPosition(ypos);
		activity_sp:additem(activityitem);
		
		xpos = xpos + activityitem:GetWidth();
		
		-- info init
		local activity_title = LORD.toStaticImage(self:Child("activity"..k.."_activityitem-activity-title"));
		local activity_npc = LORD.toStaticImage(self:Child("activity"..k.."_activityitem-activity-npc"));
		local activity_image = LORD.toStaticImage(self:Child("activity"..k.."_activityitem-activity-image"));
		local activity_timenum = self:Child("activity"..k.."_activityitem-activity-timenum");
		local activity_openlv = self:Child("activity"..k.."_activityitem-activity-openlv");
		local activity_detail = self:Child("activity"..k.."_activityitem-activity-detail");
		local activity_time = self:Child("activity"..k.."_activityitem-activity-time");
		local activity_dis = self:Child("activity"..k.."_activityitem-activity-dis");
		local activity_click = self:Child("activity"..k.."_activityitem-activity");
		
		activity_click:SetUserData(k);
		activity_click:removeEvent("WindowTouchUp");
		activity_click:subscribeEvent("WindowTouchUp", "onClickActivityEnter");
		
		activity_title:SetImage(v.title);
		activity_npc:SetImage(v.npcImage);
		activity_image:SetImage(v.backImage);
		activity_detail:SetText(v.desc);
		
		activity_openlv:SetText(dataManager.activityInfoData:getLevelLimitText(k));
		activity_timenum:SetText(dataManager.activityInfoData:getActivityOpenTimeText(k));
		
		local levelEnough = dataManager.playerData:getLevel() >= dataManager.activityInfoData:getActivityLevelLimit(k);
		activity_image:SetVisible(levelEnough);
		activity_npc:SetVisible(levelEnough);
		activity_detail:SetVisible(levelEnough);
		activity_timenum:SetVisible(levelEnough);
		activity_time:SetVisible(levelEnough);
		activity_dis:SetVisible(not levelEnough);
		
		if dataManager.activityInfoData:isActivityOpen(k) then
			activity_npc:SetProperty("DrawColor", "1 1 1 1");
		else
			activity_npc:SetProperty("DrawColor", "0.5 0.5 0.5 0.5");
		end
		
	end
	
end


function activity:onHide(event)
	self:Close();
	
	homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.SHIP);
end


return activity;
