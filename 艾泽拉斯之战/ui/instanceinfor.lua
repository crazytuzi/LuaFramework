local instanceinfor = class( "instanceinfor", layout );

global_event.INSTANCEINFOR_SHOW = "INSTANCEINFOR_SHOW";
global_event.INSTANCEINFOR_HIDE = "INSTANCEINFOR_HIDE";
global_event.INSTANCEINFOR_UPDATE = "INSTANCEINFOR_UPDATE";
global_event.INSTANCEINFOR_HIDE_ON_MOVE = "INSTANCEINFOR_HIDE_ON_MOVE";
global_event.SUCCESS_SYSTEM_REWARD_CHAPTER = "SUCCESS_SYSTEM_REWARD_CHAPTER";
global_event.INSTANCEINFOR_FLY_TO_STAGE = "INSTANCEINFOR_FLY_TO_STAGE"
global_event.INSTANCEINFOR_UPDATE_INCIDENT_INFO = "INSTANCEINFOR_UPDATE_INCIDENT_INFO"

function instanceinfor:ctor( id )
	instanceinfor.super.ctor( self, id );
	self:addEvent({ name = global_event.INSTANCEINFOR_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.INSTANCEINFOR_UPDATE, eventHandler = self.onUpdate});
	self:addEvent({ name = global_event.INSTANCEINFOR_HIDE, eventHandler = self.onHide});
	
	self:addEvent({ name = global_event.INSTANCEINFOR_HIDE_ON_MOVE, eventHandler = self.onActorMove});
	self:addEvent({ name = global_event.SUCCESS_SYSTEM_REWARD_CHAPTER, eventHandler = self.onChapterReward});
	
	self:addEvent({ name = global_event.INSTANCEINFOR_FLY_TO_STAGE, eventHandler = self.onFlyStageHide});
	
	self:addEvent({ name = global_event.INSTANCEINFOR_UPDATE_INCIDENT_INFO, eventHandler = self.onUpdateIncidentInfo});	
	self:addEvent({ name = global_event.RESOURCE_SCALE_ICON, eventHandler = self.onScaleMoneyIcon});	
	self:addEvent({ name = global_event.INSTANCERESOURCE_SHOWHIDE, eventHandler = self.onResBuyShowHide});	
	
	self:addEvent({ name = global_event.MAIN_UI_ACTIVITY_STATE, eventHandler = self.updateCampState});	
	
	
	self.vigorRefreshTick = nil
	
	
	
	
end

function instanceinfor:updateCampState(event)
		if self._show then
			self.instanceinfor_camp_tip:SetVisible(global:HasNewNoticeWithEquip());
		end
end
	
function instanceinfor:onResBuyShowHide(event)
	if(self._show and self.instanceinfor_resource)then
		self.instanceinfor_resource:SetVisible(event.Visible) 
	end
end	



function instanceinfor:onDiamondBuy(mType) 
	eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", resType = mType, copyType = -1, copyID = -1, });
end

function instanceinfor:onActorMove(event)
	if(self.instanceinfor_container == nil)then
		return 
	end
	local v = event.visible
	if(v == nil)then
		v = false
	end
	--print("  onActorMove ")
	--print(v)
	
	--self.instanceinfor_container:SetVisible(v) 
	
	-- 由于有个关卡指引的触发条件要求判断这个东西是false
	-- 所以false的时候不播动画，否则判断的时候就不正确了
	if v == true then
		self:onStageInfoPanelShowHideEffect(v);
	else
		local instanceinfor_container = self:Child( "instanceinfor-container" );
		if instanceinfor_container then
			instanceinfor_container:SetVisible(v);
		end
	end
	
	if(v ==false)then
		--关卡信息界面关闭指引
		eventManager.dispatchEvent({ name = global_event.GUIDE_ON_STAGE_INFO_HIDE})
	end
end	
function instanceinfor:onShow(event)
	self:onHide()
	self.stage = event.stage
	--[[if self._show then
		return;
	end		]]--   不要打开
	self:Show();

	-- 隐藏对话界面
	local layout = layoutManager.getUI("dialogue");
	if layout and layout._view then
		self._view:SetVisible(false);
	end	
	
	self.instanceinfor_chapterstar = self:Child( "instanceinfor-chapterstar" );
	function on_instanceinfor_star_up()
		eventManager.dispatchEvent( { name = global_event.CHAPTERAWARD_SHOW, chapter = self.stage:getChapter():getId() ,curSelStafeMode =   self.stage:getType()})	
	end	
 
 	
 	-- 信息页的开关
 	function onInstanceInfoClickCloseInfo()
 	
 		self:onStageInfoPanelShowHideEffect(false);
 	
 	end
 	
 	function onInstanceInfoClickOpenInfo()
 		
 		self:onStageInfoPanelShowHideEffect(true);
 		
 	end
 	
 	local instanceinfor_closeinfo = self:Child("instanceinfor-closeinfo");
 	local instanceinfor_openinfo = self:Child("instanceinfor-openinfo");
 	
 	instanceinfor_closeinfo:removeEvent("ButtonClick");
 	instanceinfor_closeinfo:subscribeEvent("ButtonClick", "onInstanceInfoClickCloseInfo");
 
  instanceinfor_openinfo:removeEvent("ButtonClick");
 	instanceinfor_openinfo:subscribeEvent("ButtonClick", "onInstanceInfoClickOpenInfo");
 		
	--self.instanceinfor_chapterstar:subscribeEvent("WindowTouchUp", "on_instanceinfor_star_up");	
	self.instanceinfor_chapterstar:subscribeEvent("WindowTouchUp", "on_instanceinfor_chapter");	
	self.instanceinfor_chapterstar_num = self:Child( "instanceinfor-chapterstar-num" );
	
	self.instanceinfor_chapterstar_box = self:Child( "instanceinfor-chapterstar-box" );
	self.instanceinfor_chapterstar_box_open = self:Child( "instanceinfor-chapterstar-box-open" );
	self.instanceinfor_chapterstar_box_open_effect = self:Child( "instanceinfor-box-open-effect" );
	self.instanceinfor_resource = self:Child( "instanceinfor-resource" );
	
	self.instanceinfor_camp_tip1 = self:Child( "instanceinfor-camp-tip1" );
	self.instanceinfor_camp_tip1:SetVisible(false);
	self.instanceinfor_chapter = self:Child( "instanceinfor-chapter" );
	self.instanceinfor_chapter:SetText("")
	
	
	self.instanceinfor_award_exp_num = self:Child( "instanceinfor--award-exp-num" );
	self.instanceinfor_award_exp_num:SetText("")
	
	
	self.instanceinfor_camp_tip = self:Child( "instanceinfor-camp-tip" );
	
	
	self.instanceinfor_award_item = self:Child( "instanceinfor-award-item" );
	self.instanceinfor_chapterstar_image = self:Child("instanceinfor-chapterstar-image");
	
 
 
	self.instanceinfor_style1_effect = self:Child("instanceinfor-style1-effect");		
	self.instanceinfor_style2_effect = self:Child("instanceinfor-style2-effect");
	
	
	self.instanceinfor_container_close = self:Child("instanceinfor-container-close");
	
	
	self.instanceinfor_MinHeigh = self:Child("instanceinfor-MinHeight");
	self.instanceinfor_MaxHeigh = self:Child("instanceinfor-MaxHeight");
	self.instanceinfor_Speed = self:Child("instanceinfor-Speed");
	self.instanceinfor_map_sure= self:Child("instanceinfor-map");
  
	self.instanceinfor_MinHeigh:SetText(INSTANCESCENE_STAGE_MAX_HEIGHT)
	self.instanceinfor_MaxHeigh:SetText(INSTANCESCENE_STAGE_MINHEIGHT)
	self.instanceinfor_Speed:SetText(INSTANCESCENE_STAGE_SCALE_RATE)
	
	 
	self.instanceinfor_MaxHeigh:SetVisible(false)
	self.instanceinfor_MinHeigh:SetVisible(false)
	self.instanceinfor_Speed:SetVisible(false)
	self:updateCampState()
	
 
	function onInstanceinforMap_____()
		
		
		INSTANCESCENE_STAGE_SCALE_RATE = tonumber(self.instanceinfor_Speed:GetText())
		INSTANCESCENE_STAGE_MAX_HEIGHT = tonumber(self.instanceinfor_MaxHeigh:GetText())
		INSTANCESCENE_STAGE_MINHEIGHT = tonumber(self.instanceinfor_MinHeigh:GetText())
				
								 
		instanceScene.NavigatePoint:setMaxHeight(INSTANCESCENE_STAGE_MAX_HEIGHT);
		instanceScene.NavigatePoint:setMinHeight(INSTANCESCENE_STAGE_MINHEIGHT);
		
		
		 
	end	
	
	
	self.instanceinfor_map_sure:subscribeEvent("ButtonClick", "onInstanceinforMap_____");
 
	self.instanceinfor_camp = self:Child("instanceinfor-camp");
	self.instanceinfor_camp:SetVisible( dataManager.playerData:getLevel()>=3  and   dataManager.playerData:getAdventureNormalProcess() >= dataConfig.configs.ConfigConfig[0].shipProcessLimit  );
	
	function onInstanceinforEquip()
		eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_SHOW, ship = 1, source = "instance"});
		
		self._view:SetVisible(false);
		
	end
	
	self.instanceinfor_camp:subscribeEvent("ButtonClick", "onInstanceinforEquip");
		
	function on_instanceinfor_container_close_click()
		eventManager.dispatchEvent( {name =  global_event.INSTANCEINFOR_HIDE_ON_MOVE,visible = false} )  
	end	
	
	self.instanceinfor_container_close:subscribeEvent("ButtonClick", "on_instanceinfor_container_close_click");	
	
 
	function on_instanceinfor_Normal(args)	
		
		if( not self.instanceinfor_style1:IsSelected())then
			return 
		end	
		self.instanceinfor_style1_effect:SetVisible(true)
		self.instanceinfor_style2_effect:SetVisible(false)
	
		self.instanceinfor_chapterstar_image:SetProperty("ImageName","set:stage.xml image:star")
	
		local curSelStafeMode =   self.stage:getType()
		if(curSelStafeMode == enum.Adventure_TYPE.NORMAL)then
			return
		end	
		local clickImage = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		if(clickImage:IsSelected())then		
			curSelStafeMode = enum.Adventure_TYPE.NORMAL -- 普通
			eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_UPDATE,toNewStage = true,curSelStafeMode = curSelStafeMode})
		end
		
	end	
	function on_instanceinfor_Elite(args)
		
			
		if( not self.instanceinfor_style2:IsSelected())then
			return 
		end	
		self.instanceinfor_chapterstar_image:SetProperty("ImageName","set:battle1.xml image:star2")
		self.instanceinfor_style1_effect:SetVisible(false)
		self.instanceinfor_style2_effect:SetVisible(true)
		local curSelStafeMode =   self.stage:getType()
		if(curSelStafeMode == enum.Adventure_TYPE.ELITE)then
			return
		end	
		local zones = dataManager.instanceZonesData
		local AllChapter = zones:getAllChapter()
		local Adventure =  AllChapter[1]:getAdventure()	
		local stage = zones:getStageWithAdventureID(Adventure[1],enum.Adventure_TYPE.ELITE)
		local level = dataManager.playerData:getLevel()
		if(level < stage:getlevelLimit() )then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
							messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
							textInfo =  stage:getlevelLimit().."级开启精英关卡"});
				return 		
			self.instanceinfor_style1:SetSelected(true)
		end

		local clickImage = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		if(clickImage:IsSelected())then		
			curSelStafeMode = enum.Adventure_TYPE.ELITE  
			eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_UPDATE,toNewStage = true,curSelStafeMode = curSelStafeMode})
		end
	end	
	
	self.instanceinfor_style1 = LORD.toRadioButton(self:Child( "instanceinfor-style1" ));
	self.instanceinfor_style2 = LORD.toRadioButton(self:Child( "instanceinfor-style2" ));
	
	self.instanceinfor_style1:subscribeEvent("RadioStateChanged", "on_instanceinfor_Normal");		
	self.instanceinfor_style2:subscribeEvent("RadioStateChanged", "on_instanceinfor_Elite");		
	
	self.instanceinfor_chapter = self:Child( "instanceinfor-chapter" );
	self.instanceinfor_left = self:Child( "instanceinfor-left" );
	self.instanceinfor_right = self:Child( "instanceinfor-right" );
	self.instanceinfor_tili = self:Child( "instanceinfor-tili" );
	self.instanceinfor_tili_add = self:Child( "instanceinfor-tili-add" );
	self.instanceinfor_mucai_add = self:Child( "instanceinfor-mucai-jiahao" );
	self.instanceinfor_tili = self:Child( "instanceinfor-mucai" );
	self.instanceinfor_money = self:Child( "instanceinfor-money" );
	
	
	function instanceinfor_onClickinstanceinfor_task(args)
		eventManager.dispatchEvent({name = "TASK_SHOW"});
	end	
	self.instanceinfor_task = self:Child( "instanceinfor-task" );
	self.instanceinfor_task:subscribeEvent("ButtonClick", "instanceinfor_onClickinstanceinfor_task");
	
	function instanceinfor_onClickDiamondBuy(args)
		local window = LORD.toWindowEventArgs(args).window;
		local moneyType = window:GetUserData();
		self:onDiamondBuy(moneyType);
	end

	self.instanceinfor_tili_add:subscribeEvent("ButtonClick", "instanceinfor_onClickDiamondBuy");
	self.instanceinfor_tili_add:SetUserData(enum.BUY_RESOURCE_TYPE.VIGOR);
	
	function oninstanceinforResourceBuyDiamond()
		eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});
	end	
	self.instanceinfor_mucai_add:subscribeEvent("ButtonClick", "oninstanceinforResourceBuyDiamond");
	
	
	self.instanceinfor_gps = self:Child("instanceinfor-gps");
	function oninstanceinfor_gps()
		 instanceScene.onGps()
	end	
	self.instanceinfor_gps:subscribeEvent("ButtonClick", "oninstanceinfor_gps");
	
	

 
	
	self.instanceinfor_tili_num = self:Child("instanceinfor-tili-num");
	self.instanceinfor_mucai_num = self:Child("instanceinfor-mucai-num");
	self.instanceinfor_money_num = self:Child("instanceinfor-money-num");
 
	
	function instanceinfor_vigorRefreshTickFunction()
		self:refreshVigor();
	end
	
			
	if self.vigorRefreshTick then
		scheduler.unscheduleGlobal(self.vigorRefreshTick);
		self.vigorRefreshTick = nil
	end
	self.vigorRefreshTick = scheduler.scheduleGlobal(instanceinfor_vigorRefreshTickFunction, 1);
	
	
	
	
	
	function instanceinfor_left_click()
		local Chapter = self.stage:getChapter():getId()
		Chapter = Chapter - 1		
		local minChapter = 1		
		if(Chapter < minChapter)then
			Chapter = minChapter
		end			
		self.instanceinfor_left:SetEnabled(Chapter > minChapter)
		eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_UPDATE, chapter = Chapter  } )				
	end

	function instanceinfor_right_click()
		local Chapter = self.stage:getChapter():getId()
		Chapter = Chapter + 1		
		local zones = dataManager.instanceZonesData
		local maxChapter = # (zones:getAllChapter() )	
		local curSelStafeMode =   self.stage:getType()
		local stage = zones:getNewInstance(curSelStafeMode)
		maxChapter = stage:getChapter():getId()
		
		if(Chapter  >    maxChapter)then
			Chapter = maxChapter
		end		
		self.instanceinfor_right:SetEnabled(Chapter < maxChapter)
		eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_UPDATE, chapter = Chapter  } )				
	end
	
	self.instanceinfor_left:subscribeEvent("ButtonClick", "instanceinfor_left_click");	
	self.instanceinfor_right:subscribeEvent("ButtonClick", "instanceinfor_right_click");	
	
	function on_instanceinfor_chapter()
		eventManager.dispatchEvent({name = global_event.QUICK_MAP_SHOW, chapter = self.stage:getChapter():getId() , curSelStafeMode =   self.stage:getType()})
	end	
	
	self.instanceinfor_chapter:subscribeEvent("ButtonClick", "on_instanceinfor_chapter");		
	
	
	
	self.instanceinfor_container = self:Child( "instanceinfor-container" );
	--self.instanceinfor_container:SetVisible(true) 
	self:onStageInfoPanelShowHideEffect(true);
	
	self.instanceinfor_star ={}
	self.instanceinfor_instancename = self:Child( "instanceinfor-instancename" );
	self.instanceinfor_star_back = self:Child( "instanceinfor-star" );
	self.instanceinfor_star[1] = LORD.toStaticImage(self:Child( "instanceinfor-star1" ));
	self.instanceinfor_star[2] = LORD.toStaticImage(self:Child( "instanceinfor-star2" ));
	self.instanceinfor_star[3] = LORD.toStaticImage(self:Child( "instanceinfor-star3" ));
	self.instanceinfor_text = self:Child( "instanceinfor-text" );
	self.instanceinfor_cost = self:Child( "instanceinfor-cost" );
	self.instanceinfor_cost_num = self:Child( "instanceinfor-cost-num" );
	self.instanceinfor_num = self:Child( "instanceinfor-num" );
	self.instanceinfor_num_num = self:Child( "instanceinfor-num-num" );
	self.instanceinfor_num_button = self:Child( "instanceinfor-num-button" );
	self.instanceinfor_num_button_text = self:Child( "instanceinfor-num-button-text" );
	self.instanceinfor_award_first = self:Child( "instanceinfor-award-first" );
	self.instanceinfor_award_first_item_image = {}
	self.instanceinfor_award_first_item_star = {}
	for i = 1,6 do
		self.instanceinfor_award_first_item_image[i] = LORD.toStaticImage(self:Child( "instanceinfor-award-first-item"..i.."-image" ));
		self.instanceinfor_award_first_item_star[i] = LORD.toStaticImage(self:Child( "instanceinfor-award-first-item"..i ));
	end
	
	self.instanceinfor_enemylv = self:Child( "instanceinfor-enemylv" );
	self.instanceinfor_enemylv_num = self:Child( "instanceinfor-enemylv-num" );
	self.instanceinfor_enemylv:SetVisible(false)

	self.instanceinfor_award_normal_item_image = {}
	self.instanceinfor_award_normal_item_star = {}
	self.instanceinfor_award_normal = self:Child( "instanceinfor-award-normal" );
	self.instanceinfor_award_normal_item_image[1] = LORD.toStaticImage(self:Child( "instanceinfor-award-normal-item1-image" ));
	 
	for i = 1,6 do
		self.instanceinfor_award_normal_item_image[i] = LORD.toStaticImage(self:Child( "instanceinfor-award-normal-item"..i.."-image" ));
		self.instanceinfor_award_normal_item_star[i] = LORD.toStaticImage(self:Child( "instanceinfor-award-normal-item"..i ));
	end	
 
	 
	self.instanceinfor_award_random_item_image ={}
	self.instanceinfor_award_random_item_star ={}
	self.instanceinfor_award_random_item_image[1] = LORD.toStaticImage(self:Child( "instanceinfor-award-random-item1-image" ));
	self.instanceinfor_award_random_item_image[2] = LORD.toStaticImage(self:Child( "instanceinfor-award-random-item2-image" ));
	
	self.instanceinfor_award_random_item_star[1] = LORD.toStaticImage(self:Child( "instanceinfor-award-random-item1" ));
	self.instanceinfor_award_random_item_star[2] = LORD.toStaticImage(self:Child( "instanceinfor-award-random-item2" ));
	self.instanceinfor_num_button_text_num  = self:Child( "instanceinfor-scroll" );
	 
	self.instanceinfor_scroll  = LORD.toScrollPane(self:Child( "instanceinfor-scroll" ))
	self.instanceinfor_scroll:init()
	self.instanceinfor_scroll:ClearAllItem()  
	
	self.instanceinfor_num_button_text_num  = self:Child( "instanceinfor-num-button-text-num" );
	self.instanceinfor_start = self:Child( "instanceinfor-start" );
	self.instanceinfor_sweep = self:Child( "instanceinfor-sweep" );
	self.instanceinfor_sweep_one = self:Child( "instanceinfor-sweep-one" );
	self.instanceinfor_sweep_ten = self:Child( "instanceinfor-sweep-ten" );
	self.instanceinfor_weeep_ten_num = self:Child( "instanceinfor-weeep-ten-num" );
	self.instanceinfor_money_num = self:Child( "instanceinfor-money-num" );
	self.instanceinfor_unable = self:Child( "instanceinfor-unable" );
	self.instanceinfor_close = self:Child( "instanceinfor-close" );
	self.instanceinfor_event = self:Child( "instanceinfor-event" );
	self.instanceinfor_event = self:Child( "instanceinfor-event" );
	self.instanceinfor_incidenttip = self:Child( "instanceinfor-incidentgps-tip" );
	
	self.instanceinfor_countdown = self:Child( "instanceinfor-countdown" );
	self.instanceinfor_countdowntime = self:Child( "instanceinfor-countdowntime" );
	
	function onInstanceInfoClickIncidentgps()
		
		-- 点击直接到可以打的关卡
		if dataManager.mainBase:hasCanDoIncident() then
			
			local position = dataManager.mainBase:getFirstCanDoIncidentPosition();		
			local stage = dataManager.instanceZonesData:getStageWithAdventureID(position+1, enum.Adventure_TYPE.NORMAL);
	
			eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_UPDATE, chapter = stage:getChapter():getId(), AdventureId = position+1 });
			
		else
			
			eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW, tip = "当前没有事件发生，请等待刷新" });
			
		end
		
	end
	
	local instanceinfor_incidentgps = self:Child("instanceinfor-incidentgps");
	instanceinfor_incidentgps:removeEvent("ButtonClick");
	instanceinfor_incidentgps:subscribeEvent("ButtonClick", "onInstanceInfoClickIncidentgps");
	
	-- 更新领地事件整体倒计时
	self:updateIncidentCoolDown();
	
	-- check event
	self:onUpdateIncidentInfo();
	
	function onClickInstanceinforEvent()
		if global.tipBagFull() then
			return;
		end
		
		local eventIndex = dataManager.mainBase:getIncidentIndexByPosition(self.stage:getAdventureID()-1);
		
		if eventIndex > 0 then
			sendIncident(eventIndex-1);
		
			local instanceinfor_event = self:Child( "instanceinfor-event" );
			if instanceinfor_event then
				instanceinfor_event:SetEnabled(false);
			end
		end
		
		self.instanceinfor_container:SetVisible(false);
		--self:onStageInfoPanelShowHideEffect(false);
	end
	
	self.instanceinfor_event:subscribeEvent( "ButtonClick", "onClickInstanceinforEvent" );
	
	self.instanceinfor_award_normal_money ={}
	self.instanceinfor_award_first_money ={}
	
	self.instanceinfor_award_normal_money_icon ={}
	self.instanceinfor_award_first_money_icon ={}
	
	for i =1 ,3 do
		self.instanceinfor_award_normal_money[i] =  self:Child("instanceinfor-award-normal-money"..i.."-num")
		self.instanceinfor_award_first_money[i] =  self:Child("instanceinfor-award-first-money"..i.."-num")	
		self.instanceinfor_award_first_money_icon[i] =  self:Child("instanceinfor-award-first-money"..i)	
		self.instanceinfor_award_normal_money_icon[i] =  LORD.toStaticImage(self:Child("instanceinfor-award-normal-money"..i));			 
	end	
	
	function instanceinfor_sweep_one()	
		self:sweep(1)			
		print("sweep ------------------------------------1")
	end	
	function instanceinfor_sweep_ten()
		print("sweep ------------------------------------")
		self:sweep(nil)
	end	
	
 	self.instanceinfor_sweep_one:subscribeEvent("ButtonClick", "instanceinfor_sweep_one");	  
	self.instanceinfor_sweep_ten:subscribeEvent("ButtonClick", "instanceinfor_sweep_ten");	
	
	
	
	
	function instanceinfor_close_click()
	
		global.changeGameState(function() 
			eventManager.dispatchEvent( { name = global_event.INSTANCEINFOR_HIDE })
			game.EnterProcess(game.GAME_STATE_MAIN)		
		end);
	end	
	self.instanceinfor_close:subscribeEvent("ButtonClick", "instanceinfor_close_click");	
	
	function instanceinfor_clickStageStat(notshowdialogue)	
		
		if self.sourceType == "challege" then
			
			if(global.tipBagFull())then
				return;
			end
			local  cd = dataManager.playerData:getTimeAttr(enum.PLAYER_ATTR64.PLAYER_ATTR64_STAGE_CHALLENGE_COOLDOWN) 
			if(cd ~= nil )then	
				if(type(cd) == "userdata")then
					cd    = cd:GetUInt() 			
				end					
			end	
			cd = cd or 0
			local detal = cd  - dataManager.getServerTime()
			if(detal > 0 )then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, textInfo = "本挑战冷却中,请等待"..formatTime(detal).."时间后再来!" });	
				
				return 	
			end		
 
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			eventManager.dispatchEvent({name = global_event.ACTIVITYCOPY_HIDE});
			eventManager.dispatchEvent({name = global_event.ACTIVITY_HIDE});
			
			game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE, planType = enum.PLAN_TYPE.PLAN_TYPE_PVE});
	
			self:onHide();
		else
		
			local level = dataManager.playerData:getLevel()
			if(level < self.stage:getlevelLimit() )then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
							messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
							textInfo =  self.stage:getlevelLimit().."级才能挑战该关卡#n#n友情提示：#n#n重复挑战关卡或完成日常任务可获得大量经验"});
				return 		
			end
				
			local maxCanBattle = self.stage:getMaxCanBattleNum()
			local canBattleNum = (maxCanBattle - self.stage:getBattleNum())
			if(canBattleNum <= 0)then		
				eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.RESET_COPY, copyType = self.stage:getServerType(), copyID = self.stage:getAdventureID()});
				return false
			end
			if(dataManager.playerData:getVitality() < self.stage:getVigourCost() )then
				eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.VIGOR,-1,-1});
				return false
			end
			if(global.tipBagFull())then
				return false
			end	
			
			dataManager.playerData.stageInfo =  self.stage
			self:onHide()	
			
			if dataManager.playerData.stageInfo:isShowDialogue() and notshowdialogue ~= true then
				eventManager.dispatchEvent({name = global_event.DIALOGUE_SHOW, dialogueType = "adventurePrepare", 
						dialogueID = dataManager.playerData.stageInfo:getPrepareDialogueID() });
			else
				battlePrepareScene.onEnter();
			end
		end
		return true		
	end
	
	self.instanceinfor_start:subscribeEvent("ButtonClick", "instanceinfor_clickStageStat");	
	
	
	function instanceinfor_clickReset(source)	
			source = source or "userclick"
			local maxReset = dataManager.playerData:getMaxBuyResourceTimes(enum.BUY_RESOURCE_TYPE.RESET_COPY)	
		    --if(self.stage:getResetNum()< maxReset)then
				eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = source, resType = enum.BUY_RESOURCE_TYPE.RESET_COPY, copyType = self.stage:getServerType(), copyID = self.stage:getAdventureID()});
			--end
	end
	
	self.instanceinfor_num_button:subscribeEvent("ButtonClick", "instanceinfor_clickReset");	
	
	self.sourceType = event.sourceType;
	if self.sourceType == "challege" then
		self.challeageStageIndex = event.challeageStageIndex;
		self:updateChallegeInfo();
	else
		self:update();
	end
	eventManager.dispatchEvent({ name = global_event.GUIDE_ON_STAGE_INFO_SHOW})
end

function instanceinfor:sweep(count)
		local maxCanBattle = self.stage:getMaxCanBattleNum()
		local canBattleNum = (maxCanBattle - self.stage:getBattleNum())
		if(canBattleNum <= 0)then		
			eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.RESET_COPY, copyType = self.stage:getServerType(), copyID = self.stage:getAdventureID()});
			return
		end	
		if(count == nil)then
			count = canBattleNum 
		end	
		if(dataManager.playerData:getVitality() < self.stage:getVigourCost() *count)then
			eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.VIGOR,-1,-1});
			return
		end
		if(global.tipBagFull())then
			return
		end	
		
		dataManager.playerData.stageInfo =  self.stage
		--扫荡券数量
		local sweepItemNum = dataManager.bagData:getItemNums(enum.BAG_TYPE.BAG_TYPE_BAG ,global.getSweepScrollID())
		if(sweepItemNum <=0)then
			----------------提示
				eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
				messageType = enum.MESSAGE_DIAMOND_TYPE.LACK_OF_SWEEP_TICKET, data = {count = count,stage = self.stage}, 
				textInfo = "" });
			return
			
		end

		dataManager.playerData.stageInfo:ClearSweepRandomReward(0)
	    sendSweep(self.stage:getAdventureID(), self.stage:getServerType(),count)
		
		--[[		
		count = 5
		dataManager.playerData.stageInfo:ClearSweepRandomReward(count)
		randomRewards= {}		
		randomRewards[1]  = {1,2}
		randomRewards[2]  = {1,1}
		randomRewards[3]  = {2,1}
		randomRewards[4]  = {1,2}
		randomRewards[5]  = {2,2}
		for i= 1, count do
			 local reward = randomRewards[i]
			-- local num = #reward['rewardList']
			-- for k = 1, num do	 ---必定是2个
				 dataManager.playerData.stageInfo:AddSweepRandomReward(i,{reward[1],reward[2]}) 	
			-- end
		end			
		eventManager.dispatchEvent( {name = global_event.SWEEP_SHOW,stage = dataManager.playerData.stageInfo })		
		]]---
end	
--self.instanceinfor_scroll:ClearAllItem()

function instanceinfor:clearItemToScroll(index,data)
	self._xpos = nil
	self.instanceinfor_scroll:ClearAllItem()
	self.instanceinfor_award_item:SetVisible(false)	
end	

function instanceinfor:addItemToScroll(index,data)
	self._xpos = self._xpos or LORD.UDim(0, -5)
	local ypos = LORD.UDim(0, -5)	
	--self.instanceinfor_scroll:ClearAllItem()
	local prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("instanceinfor_"..index, "instanceawarditem.dlg");
	local icon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instanceinfor_"..index.."_instanceawarditem-item-image"))
	local equity = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instanceinfor_"..index.."_instanceawarditem-equity"))
	local num = LORD.GUIWindowManager:Instance():GetGUIWindow("instanceinfor_"..index.."_instanceawarditem-num")
    local rate = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instanceinfor_"..index.."_instanceawarditem-rare"))
	local back = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instanceinfor_"..index.."_instanceawarditem-item"))
 
	local uistars = {};
	for i=1, 5 do
		uistars[i] = self:Child("instanceinfor_"..index.."_instanceawarditem-star"..i);
		uistars[i]:SetVisible(i<=data.showstar);
	end

	prew:SetPosition(LORD.UVector2(self._xpos , ypos));
			
	self.instanceinfor_scroll:additem(prew);
		
	self._xpos  = self._xpos  + prew:GetWidth() + LORD.UDim(0, -20)	
	
	equity:SetImage(data.equity)
	icon:SetImage(data.icon)
	back:SetImage( itemManager.getBackImage(data._isDebris)   )
	
	global.setMaskIcon(icon, data.maskicon);
	
	if(data.num <=1)then
		num:SetText("")
	else
		num:SetText(data.num)		
	end	
	rate:SetVisible(data.rate)	
	self.instanceinfor_award_item:SetVisible(true)	
	local tipsType = data._type
	prew:SetUserData(data.id);	
	if tipsType == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
		prew:SetUserData(dataManager.kingMagic:mergeIDLevel(data.id, data.star));
	end		
	global.onItemTipsShow(prew, tipsType, "top");
	global.onItemTipsHide(prew);
end					






function instanceinfor:update()
	
	if not self._show then
		return;
	end		
	
	self.instanceinfor_instancename:SetText(self.stage:getName())
	--self.instanceinfor_enemylv_num:SetText(self.stage:getHeroLevel())  
		
	
	
	local star = self.stage:getVisStarNum()
	for i = 1, 3 do	
		if(self.instanceinfor_star[i])then
			self.instanceinfor_star[i]:SetVisible(i <= star) 
		end
	end
	self.instanceinfor_text:SetText(self.stage:getDesc()) 
	
	local vig = self.stage:getVigourCost()
	self.instanceinfor_cost_num:SetText(vig)	
	self.instanceinfor_money_num:SetText(dataManager.bagData:getItemNums(enum.BAG_TYPE.BAG_TYPE_BAG ,global.getSweepScrollID())) 
	
	if(self.stage:canSweep())then
		self.instanceinfor_unable:SetVisible(false) 
		self.instanceinfor_sweep_one:SetVisible(true) 
		self.instanceinfor_sweep_ten:SetVisible(true) 
		self.instanceinfor_weeep_ten_num:SetVisible(false)  
	else
		self.instanceinfor_unable:SetVisible(true) 
		self.instanceinfor_sweep_one:SetVisible(false) 
		self.instanceinfor_sweep_ten:SetVisible(false) 
		self.instanceinfor_weeep_ten_num:SetVisible(false)  
	end		
	local maxCanBattle = self.stage:getMaxCanBattleNum()
	local canBattleNum = (maxCanBattle - self.stage:getBattleNum())
	if canBattleNum == 0 then
		self.instanceinfor_num_num:SetText( "^FF0000"..canBattleNum.."^FFFFFF/"..maxCanBattle) 
	else
		self.instanceinfor_num_num:SetText( canBattleNum.."/"..maxCanBattle) 
	end
	self.instanceinfor_sweep_ten:SetText("扫荡 "..canBattleNum.." 次")
	if canBattleNum == 0 then
	self.instanceinfor_sweep_ten:SetText("连续扫荡")	
	end
	local maxReset = dataManager.playerData:getMaxBuyResourceTimes(enum.BUY_RESOURCE_TYPE.RESET_COPY)	
	local remainReset = maxReset - self.stage:getResetNum();
	if remainReset == 0 then
		self.instanceinfor_num_button_text_num:SetText( "^FF0000"..(maxReset - self.stage:getResetNum()).."^FFFFFF/"..maxReset) 
	else
		self.instanceinfor_num_button_text_num:SetText( (maxReset - self.stage:getResetNum()).."/"..maxReset) 
	end
 
	self.instanceinfor_num_button:SetVisible(canBattleNum <= 0) 
	self.instanceinfor_award_exp_num:SetText( (self.stage:getExp()) )
	
	local _itemIndex = 1		
	self:clearItemToScroll()

	if(self.stage:isWillFirstPass())then
		self.instanceinfor_award_first:SetVisible(true)
		self.instanceinfor_award_normal:SetVisible(false)
		
		local reward = self.stage:getStageFirstMergerNormalReward()		
		
		local index = 1		
		for i ,v in ipairs (reward) do
			if(v._type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY)then
				
				if(v._type == enum.REWARD_TYPE.REWARD_TYPE_ITEM)then
				end
				self:addItemToScroll(_itemIndex,{_isDebris =v._isDebris, _type = v._type ,star = v._star, showstar = v._showstar, id =v._id, maskicon = v._maskicon, equity = itemManager.getImageWithStar(v._star, v._isDebris),icon = v._icon,num = v._num,rate = v._rate})
				_itemIndex = _itemIndex + 1
				 
			end				
		end
		
		reward = self.stage:getStageRandomReward()
		for i ,v in ipairs (reward) do
			if(v._type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY)then
				if(v._type == enum.REWARD_TYPE.REWARD_TYPE_ITEM)then
				end	 
				self:addItemToScroll(_itemIndex,{_isDebris =v._isDebris,_type = v._type,star = v._star, showstar = v._showstar, id =v._id, maskicon = v._maskicon, equity = itemManager.getImageWithStar(v._star, v._isDebris),icon = v._icon,num = v._num,rate = v._rate})
				_itemIndex = _itemIndex + 1
			end				
		end
		
		local num = self.stage:getStageRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_GOLD,true)

		self.instanceinfor_award_first_money[1]:SetText(num)
		self.instanceinfor_award_first_money_icon[1]:SetVisible(num> 0)	
		self.instanceinfor_award_first_money[1]:SetVisible(num> 0)
		
		
		num = self.stage:getStageRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_LUMBER,true)
		self.instanceinfor_award_first_money[2]:SetText(num)
		self.instanceinfor_award_first_money_icon[2]:SetVisible(num > 0)			
		self.instanceinfor_award_first_money[2]:SetVisible(num> 0)
		
		num = self.stage:getStageRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_DIAMOND,true)
		self.instanceinfor_award_first_money[3]:SetText(num) 
		self.instanceinfor_award_first_money_icon[3]:SetVisible(num > 0)
		self.instanceinfor_award_first_money[3]:SetVisible(num> 0)
 
	else
		self.instanceinfor_award_first:SetVisible(false)
		self.instanceinfor_award_normal:SetVisible(true)
		
		local reward = self.stage:getStageReward(1)
 
		for i ,v in ipairs (reward) do
			if(v._type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY)then
				if(v._type == enum.REWARD_TYPE.REWARD_TYPE_ITEM)then
 					
				end
				self:addItemToScroll(_itemIndex,{_isDebris =v._isDebris,_type = v._type,star = v._star, showstar = v._showstar, id =v._id, maskicon = v._maskicon, equity = itemManager.getImageWithStar(v._star, v._isDebris),icon = v._icon,num = v._num,rate = v._rate})
				_itemIndex = _itemIndex + 1
			end				
		end
		reward = self.stage:getStageRandomReward()
 
		for i ,v in ipairs (reward) do
			if(v._type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY)then			
				if(v._type == enum.REWARD_TYPE.REWARD_TYPE_ITEM)then
				 
				end						
				self:addItemToScroll(_itemIndex,{_isDebris =v._isDebris, _type = v._type,star = v._star, showstar = v._showstar, id =v._id, maskicon = v._maskicon, equity = itemManager.getImageWithStar(v._star, v._isDebris),icon = v._icon,num = v._num,rate = v._rate})
				_itemIndex = _itemIndex + 1	
			end				
		end
		local num = self.stage:getStageRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_GOLD,false)
		
		self.instanceinfor_award_normal_money[1]:SetText(num)
		self.instanceinfor_award_normal_money[1]:SetVisible(num > 0)
		self.instanceinfor_award_normal_money_icon[1]:SetVisible(num > 0)	
		
		num = self.stage:getStageRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_LUMBER,false)
		self.instanceinfor_award_normal_money[2]:SetText(num)
		self.instanceinfor_award_normal_money[2]:SetVisible(num > 0)
		self.instanceinfor_award_normal_money_icon[2]:SetVisible(num > 0)
		
		num = self.stage:getStageRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_DIAMOND,false)
		
	 
		self.instanceinfor_award_normal_money[3]:SetText(num) 	
		self.instanceinfor_award_normal_money[3]:SetVisible(num > 0)
	    self.instanceinfor_award_normal_money_icon[3]:SetVisible(num > 0)
 
		 				 
	end
	
	self:updateCurChapter()
	self.instanceinfor_start:SetEnabled(self.stage:isEnable())		
end

function instanceinfor:onupdateCurChapter(event)
	self:updateCurChapter()
end	
 
function instanceinfor:onChapterReward()
	if not self._show then
		return;
	end		
	
	self:updateCurChapter()
end	
function instanceinfor:updateCurChapter()
	
	local curChapter = self.stage:getChapter()
	local curSelStafeMode = self.stage:getType()
	eventManager.dispatchEvent( { name = global_event.CHAPTERAWARD_UPDATE, curChapter = curChapter:getId(),curSelStafeMode = curSelStafeMode})	
	 
	local Adventure = curChapter:getAdventure()
	
	---章节奖励领了 就不显示了
	--self.instanceinfor_chapterstar:SetVisible( not curChapter:haveAward(curSelStafeMode))
	
	self.precurChapter = self.precurChapter or curChapter:getId()
	self.instanceinfor_chapter:SetText(curChapter:getName())
	
	
	
	
		function instanceinforAnimateChapter(window)
		
				function _instanceinforAnimateChapter()
						
				end
			
				if window then
					local action = LORD.GUIAction:new();
			 
					--local _pos = window:GetPosition();
					action:addKeyFrame(LORD.Vector3(0, -120, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
					action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
					function ___playAnimateDownSoun()
							LORD.SoundSystem:Instance():playEffect("star.mp3");
					end
					scheduler.performWithDelayGlobal( ___playAnimateDownSoun  ,0.2);
					
					action:addKeyFrame(LORD.Vector3(0, -30, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
					action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 400);
					window:playAction(action);
	
					--window:removeEvent("UIActionEnd");
					--window:subscribeEvent("UIActionEnd", "_instanceinforAnimateChapter");
				end
		end
	function instanceinfordelayFlyFunc()
		instanceinforAnimateChapter(self.instanceinfor_chapter)
	end	
	if(self.precurChapter ~= curChapter:getId())then
		self.precurChapter =  curChapter:getId()
		scheduler.performWithDelayGlobal(instanceinfordelayFlyFunc,0);
	end
	
	local num ,all = curChapter:getPerfectProcess(curSelStafeMode)
	
	local VisibleOpenBox = num >= all
	self.instanceinfor_chapterstar_box:SetVisible( not VisibleOpenBox)
	self.instanceinfor_chapterstar_box_open:SetVisible(VisibleOpenBox)
	self.instanceinfor_chapterstar_box_open_effect:SetVisible(VisibleOpenBox and (not curChapter:haveAward(curSelStafeMode)))
	
	--章节奖励领了 就不显示了
	if( curChapter:haveAward(curSelStafeMode) )then
		self.instanceinfor_chapterstar_box:SetVisible( false)
		self.instanceinfor_chapterstar_box_open:SetVisible(false)
		self.instanceinfor_chapterstar_box_open_effect:SetVisible(false)
		--self.instanceinfor_chapterstar:SetTouchable(false)
	else
		--self.instanceinfor_chapterstar:SetTouchable(true)	
	end
	
	-- self update fly star
	local flyStar = global.getFlag("advertureFlyStar");
	if flyStar and flyStar > 0 then
		
		num = num - flyStar;
		
		global.setFlag("advertureFlyStar", nil);
		
		global.setFlag("advertureStarCount", num);
		
		local rect = self.instanceinfor_chapterstar_image:GetUnclippedOuterRect();
		 
		local img = nil
		if(curSelStafeMode == enum.Adventure_TYPE.NORMAL)then
			img = "set:stage.xml image:star"
		else
			img = "set:battle1.xml image:star2"
		end	
		
	
		
		
		dataManager.moneyFlyManager:createMoneyFly(img, flyStar, LORD.Vector2(640, 360), LORD.Vector2(rect.left, rect.top));
	end

	local pro =  num.."/"..all	
	self.instanceinfor_chapterstar_num:SetText(pro)
	
	
	if(curSelStafeMode == enum.Adventure_TYPE.NORMAL)then
		self.instanceinfor_style1:SetSelected(true)
	elseif(curSelStafeMode == enum.Adventure_TYPE.ELITE)then
		self.instanceinfor_style2:SetSelected(true)	
	end	
	local minChapter = 1
	self.instanceinfor_left:SetEnabled(curChapter:getId() > minChapter)
	local zones = dataManager.instanceZonesData
	local maxChapter = # (zones:getAllChapter() )	
	
	local zones = dataManager.instanceZonesData
	local stage = zones:getNewInstance(curSelStafeMode)
	maxChapter = stage:getChapter():getId()
	self.instanceinfor_right:SetEnabled(curChapter:getId() < maxChapter)
	
	self:refreshVigor()
	self:refreshGem()
	self:refreshSwapMoney()
	
	
	self.instanceinfor_camp_tip1:SetVisible(zones:haveAward(curSelStafeMode));
end

function instanceinfor:refreshGem()
	
	self.instanceinfor_mucai_num:SetText(  dataManager.playerData:getGem()   )	
end

function instanceinfor:refreshSwapMoney()
	local sweepItemNum = dataManager.bagData:getItemNums(enum.BAG_TYPE.BAG_TYPE_BAG ,global.getSweepScrollID())
	self.instanceinfor_money_num:SetText(sweepItemNum )	
end

function instanceinfor:refreshVigor()
	local isOverflow = dataManager.playerData:getVitality() >= dataManager.playerData:getVigorMax();
	if isOverflow then
		self.instanceinfor_tili_num:SetText( "^FFC124"..dataManager.playerData:getVitality().."^FFFFFF/"..dataManager.playerData:getVigorMax() )	
	else
		self.instanceinfor_tili_num:SetText( dataManager.playerData:getVitality().."/"..dataManager.playerData:getVigorMax() )	
	end
end

function instanceinfor:onUpdate(event)
	self:update();
end
function instanceinfor:onHide(event)

	self.instanceinfor_resource = nil;
	
	self:Close();
	if self.vigorRefreshTick then
		scheduler.unscheduleGlobal(self.vigorRefreshTick);
		self.vigorRefreshTick = nil
	end
	
	if self.incidentTimeTimer then
		scheduler.unscheduleGlobal(self.incidentTimeTimer);
		self.incidentTimeTimer = nil
	end
 
	eventManager.dispatchEvent({name = global_event.QUICK_MAP_HIDE})
end

function instanceinfor:onFlyStageHide(event)
	self:onHide()
end	

-- 更新领地事件状态
function instanceinfor:onUpdateIncidentInfo(event)
	if not self._show then
		return;
	end
	
	-- 什么情况下显示，什么情况下enable
	-- remaintime ? pos ? eventID ?
	local curSelStafeMode = self.stage:getType()
		
	local eventIndex = dataManager.mainBase:getIncidentIndexByPosition(self.stage:getAdventureID()-1);
	if eventIndex < 0 or curSelStafeMode ~= enum.Adventure_TYPE.NORMAL then
		self.instanceinfor_event:SetVisible(false);
		self.instanceinfor_incidenttip:SetVisible(false);
	else
		local remaintime = dataManager.mainBase:getRemineIncidentTime(eventIndex);
		local eventID = dataManager.mainBase:getPlayerIncidentIndex(eventIndex);
		if remaintime > 0 and eventID <= 0 then
			self.instanceinfor_event:SetVisible(false);
			self.instanceinfor_incidenttip:SetVisible(false);
		else
			self.instanceinfor_event:SetVisible(true);
		end
	end
	
end

function instanceinfor:updateIncidentCoolDown()
	
	function updateInstanceInfoIncidentCoolDown()
		if self.instanceinfor_countdown and self.instanceinfor_countdowntime then
		
			local remainTime, incidentIndex = dataManager.mainBase:getWholeIncidentRemainTime();
							
			if dataManager.mainBase:getActiveLingDiCount() > 0 then
				
				local instanceinfor_incidentgps = self:Child("instanceinfor-incidentgps");
				instanceinfor_incidentgps:SetVisible(true);
				
				if remainTime <= 0 then
					-- 请求一次刷新点
					sendIncident(-1);
				end
			
				self.instanceinfor_countdown:SetVisible(true);
				
				if incidentIndex < 0 then
					self.instanceinfor_countdowntime:SetText("已满");
					
					local instanceinfor_countdown = self:Child("instanceinfor-countdown");
					instanceinfor_countdown:SetVisible(false);
					
				else
					self.instanceinfor_countdowntime:SetText(formatTime(remainTime, true));
					
					local instanceinfor_countdown = self:Child("instanceinfor-countdown");
					instanceinfor_countdown:SetVisible(true);
					
				end
				
				-- 有可以打的提示
				local instanceinfor_incidentgps_tip = self:Child("instanceinfor-incidentgps-tip");
				
				instanceinfor_incidentgps_tip:SetVisible(dataManager.mainBase:hasCanDoIncident());
				
			else
				self.instanceinfor_countdown:SetVisible(false);
				
				local instanceinfor_incidentgps = self:Child("instanceinfor-incidentgps");
				instanceinfor_incidentgps:SetVisible(false);
				
			end
							
		end	
	end

	local adventureType = self.stage:getType();
	if(adventureType ~= enum.Adventure_TYPE.NORMAL)then
		
		-- 隐藏
		-- 释放计时器
		if self.incidentTimeTimer then
			scheduler.unscheduleGlobal(self.incidentTimeTimer);
			self.incidentTimeTimer = nil;
		end
	
		local instanceinfor_incidentgps = self:Child("instanceinfor-incidentgps");
		instanceinfor_incidentgps:SetVisible(false);
		local instanceinfor_countdown = self:Child("instanceinfor-countdown");
		instanceinfor_countdown:SetVisible(false);
		
		return;
	end
			
	updateInstanceInfoIncidentCoolDown();
	
	if self.incidentTimeTimer == nil then	
		self.incidentTimeTimer = scheduler.scheduleGlobal(updateInstanceInfoIncidentCoolDown, 1);
	end
		
end

function instanceinfor:updateChallegeInfo()
	self.instanceinfor_sweep:SetVisible(false);
	self.instanceinfor_cost:SetVisible(false);
	self.instanceinfor_num:SetVisible(false);
	self.instanceinfor_enemylv:SetVisible(false);
	self.instanceinfor_star_back:SetVisible(false);
	self.instanceinfor_award_first:SetVisible(false)
	self.instanceinfor_award_normal:SetVisible(true)
		
	local playerData = dataManager.playerData;
	local stageInfo = playerData:getChallegeStageInfo(self.challeageStageIndex);
	
	-- 先全都隐藏掉
	for k,v in ipairs(self.instanceinfor_award_normal_money_icon) do
		self.instanceinfor_award_normal_money_icon[k]:SetVisible(false);
		self.instanceinfor_award_normal_money[k]:SetVisible(false);
	end
	
	for k,v in ipairs(self.instanceinfor_award_normal_item_image) do
		v:SetVisible(false);
		self.instanceinfor_award_normal_item_star[k]:SetVisible(false);
	end
	
	-- 稀有
	for k,v in ipairs(self.instanceinfor_award_random_item_image) do
		v:SetVisible(false);
		self.instanceinfor_award_random_item_star[k]:SetVisible(false);
	end
	
	local moneyIndex = 1;
	local itemIndex = 1;
	if stageInfo then

		dataManager.playerData:setChallegeStageIndex(self.challeageStageIndex);
			
		--副本名称
		self.instanceinfor_instancename:SetText(stageInfo.name);
		--副本描述
		self.instanceinfor_text:SetText(stageInfo.desc);
		local rewardRatio = 1
		-- 必得奖励
		for k,v in ipairs(stageInfo.rewardType) do
			local rewardInfo = playerData:getRewardInfo(v, stageInfo.rewardID[k], stageInfo.rewardCount[k]);
			
			if v == enum.REWARD_TYPE.REWARD_TYPE_MONEY and self.instanceinfor_award_normal_money[moneyIndex] then
				self.instanceinfor_award_normal_money_icon[moneyIndex]:SetImage(rewardInfo.icon);
				if(global.needAdjustReward(stageInfo.needAdjust, v, reardInfo.id))then
					rewardRatio = dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel()).rewardRatio;
				end
				 
				self.instanceinfor_award_normal_money[moneyIndex]:SetText(math.floor(rewardInfo.count*rewardRatio));	
				self.instanceinfor_award_normal_money_icon[moneyIndex]:SetVisible(true);
				self.instanceinfor_award_normal_money[moneyIndex]:SetVisible(true);
		
				moneyIndex = moneyIndex + 1;
			else
				
				if self.instanceinfor_award_normal_item_image[itemIndex] then
					self.instanceinfor_award_normal_item_image[itemIndex]:SetImage(rewardInfo.icon);
					self.instanceinfor_award_normal_item_image[itemIndex]:SetVisible(true);			
				end
				
				if self.instanceinfor_award_normal_item_star[itemIndex] then
					self.instanceinfor_award_normal_item_star[itemIndex]:SetImage(itemManager.getImageWithStar(rewardInfo.star));		
					self.instanceinfor_award_normal_item_star[itemIndex]:SetVisible(true);
				end
				
				itemIndex = itemIndex + 1;
			end			
		end
		
		-- 稀有，random1的前两个
		for k,v in ipairs(self.instanceinfor_award_random_item_image) do
			if stageInfo.randomReward1Type[k] then
				local rewardInfo = playerData:getRewardInfo(stageInfo.randomReward1Type[k], stageInfo.randomReward1ID[k], stageInfo.randomReward1Count[k]);
				self.instanceinfor_award_random_item_image[itemIndex]:SetImage(rewardInfo.icon);
				self.instanceinfor_award_random_item_star[itemIndex]:SetImage(itemManager.getImageWithStar(rewardInfo.star));	
			end
		end
	end
	
end

function instanceinfor:onScaleMoneyIcon(event)
	if not self._show then
		return;
	end

	if event.moneyType == enum.MONEY_TYPE.MONEY_TYPE_INVALID then
	
		local curChapter = self.stage:getChapter()
		local curSelStafeMode = self.stage:getType()
		local Adventure = curChapter:getAdventure()
		
		self.instanceinfor_chapter:SetText(curChapter:getName())
		local num ,all = curChapter:getPerfectProcess(curSelStafeMode)
		
		local count = global.getFlag("advertureStarCount");
		count = count + 1;
		
		global.setFlag("advertureStarCount", count);
		
		local pro =  count.."/"..all;
		
		self.instanceinfor_chapterstar_num:SetText(pro);

		uiaction.scale(self.instanceinfor_chapterstar_image);
			
	end
end

-- 关卡信息的打开隐藏效果
function instanceinfor:onStageInfoPanelShowHideEffect(show)
	
	if not self._show then
		return;
	end
	
	--print("onStageInfoPanelShowHideEffect "..tostring(show));
	
	local instancePanel = self:Child("instanceinfor-container");
	
	local panelSize = instancePanel:GetPixelSize();
	
	--print("instancePanel:IsVisible() "..tostring(instancePanel:IsVisible()));
	
	if show == true then
		
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(panelSize.x, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
		
		instancePanel:SetVisible(true);
		instancePanel:removeEvent("UIActionEnd");
		instancePanel:playAction(action);
	
	elseif show == false and instancePanel:IsVisible() == true then

		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(panelSize.x, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
		
		function onInstanceInfoInfoPanelHideActionEnd(args)

			local panel = self:Child("instanceinfor-container");
			
			if panel then
				panel:SetVisible(false);
			end
			
		end
		
		instancePanel:SetVisible(true);
		instancePanel:removeEvent("UIActionEnd");
		instancePanel:subscribeEvent("UIActionEnd", "onInstanceInfoInfoPanelHideActionEnd");
		instancePanel:playAction(action);
			
	end
	
	--print("instancePanel:IsVisible() "..tostring(instancePanel:IsVisible()));
end

return instanceinfor;
