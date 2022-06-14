local task = class( "task", layout );

global_event.TASK_SHOW = "TASK_SHOW";
global_event.TASK_HIDE = "TASK_HIDE";
global_event.TASK_UPDATE_LIST = "TASK_UPDATE_LIST";
global_event.TASK_UPDATE_FREE_VIGOR = "TASK_UPDATE_FREE_VIGOR";

local CLICK_AWARD_SCALE = 0.8;

function task:ctor( id )
	task.super.ctor( self, id );
	self:addEvent({ name = global_event.TASK_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.TASK_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.TASK_UPDATE_LIST, eventHandler = self.onUpdateList});
	self:addEvent({ name = global_event.TASK_UPDATE_FREE_VIGOR, eventHandler = self.updateVigorState});
end

function task:onShow(event)
	if self._show then
		return;
	end
	
	function onClickTaskClose()
		self:onHide();
	end
	
	function onClickTaskClaimVigor()
		local player = dataManager.playerData;
		player:getFreeVigor();
	end
	
	function onClickTaskTab(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		
		if window:IsSelected() then
			local userdata = window:GetUserData();
			
			local tabIndex = 1;
			if enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_DAILY_TASK == userdata then
				self:updateTaskDailyTask();
				tabIndex = 1;
			elseif enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_LEVEL_UP == userdata then
				self:updateTaskLevelUp();
				tabIndex = 2;
			elseif enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_SIGN_IN == userdata then
				self:updateTaskLoginReward();
				tabIndex = 3;
			end
			
			for i=1, 3 do
				self.task_tab_textimage[i]:SetVisible(i~=tabIndex);
				self.task_tab_textimage_n[i]:SetVisible(i==tabIndex);
			end
			
		end
		
	end
	
	self:Show();
	
	function onClickTaskExpBack()
		eventManager.dispatchEvent({name = global_event.EXPBUYBACK_SHOW});
	end
	
	local task_buyexpback = self:Child("task-buyexpback");
	task_buyexpback:subscribeEvent("ButtonClick", "onClickTaskExpBack");
	
	self.task_tab1 = LORD.toRadioButton(self:Child( "task-tab1" ));
	self.task_tab1:subscribeEvent("RadioStateChanged", "onClickTaskTab");
	self.task_tab1:SetUserData(enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_DAILY_TASK);
	
	self.task_tab2 = LORD.toRadioButton(self:Child( "task-tab2" ));
	self.task_tab2:subscribeEvent("RadioStateChanged", "onClickTaskTab");
	self.task_tab2:SetUserData(enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_LEVEL_UP);
	
	self.task_tab3 = LORD.toRadioButton(self:Child( "task-tab3" ));
	self.task_tab3:subscribeEvent("RadioStateChanged", "onClickTaskTab");
	self.task_tab3:SetUserData(enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_SIGN_IN);
	
	self.task_tab_textimage_n = {};
	self.task_tab_textimage = {};
	for i=1, 3 do
		self.task_tab_textimage_n[i] = self:Child( "task-tab"..i.."-textimage-n" );
		self.task_tab_textimage[i] = self:Child( "task-tab"..i.."-textimage" );
	end
	
	self.task_scroll = LORD.toScrollPane(self:Child( "task-scroll" ));
	self.task_scroll:init();
	
	self.task_tab1_tip = self:Child("task-tab1-tip");
	self.task_tab2_tip = self:Child("task-tab2-tip");
	self.task_tab3_tip = self:Child("task-tab3-tip");
	
	self.task_close = self:Child( "task-close" );
	self.task_button = self:Child( "task-button" );
	self.task_close:subscribeEvent("ButtonClick", "onClickTaskClose");
	self.task_button:subscribeEvent("ButtonClick", "onClickTaskClaimVigor");
	
	self.task_button_tip = self:Child( "task-button-tip" );
	
	self.task_timenotice = self:Child( "task-timenotice" );
	

	self:updateVigorState();
	
	
	
	if(event.showType == nil ) then
		local playerData = dataManager.playerData;
		if(playerData:isHaveCanGainedDailyTaskReward()) then
			event.showType = enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_DAILY_TASK
		elseif(playerData:isHaveCanGainedLevelReward()) then
			event.showType = enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_LEVEL_UP
		elseif(playerData:isCanGetLoginReward()) then
			event.showType = enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_SIGN_IN
		end
 
	end
	 
	
	if event.showType == enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_DAILY_TASK then
		self.task_tab1:SetSelected(true);
	elseif event.showType == enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_LEVEL_UP then
		self.task_tab2:SetSelected(true);
	elseif event.showType == enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_SIGN_IN then
		self.task_tab3:SetSelected(true);
	else
		self.task_tab1:SetSelected(true);
	end
	
	
	-- test action
	--[[
	if self._view then
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, -180, 0), LORD.Vector3(0, 0, 0), 0, 0);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, -90, 0), LORD.Vector3(0.5, 0.5, 0.5), 1, 250);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 500);
		self._view:playAction(action);
	end
	--]]
	
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_TASK})
end

function task:onHide(event)
	
	function onTaskActionEnd()
		self:Close();
	end
	-- test action
	--[[
	if self._view then
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 90, 0), LORD.Vector3(0.5, 0.5, 0.5), 1, 250);
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 180, 0), LORD.Vector3(0, 0, 0), 0, 500);
		self._view:playAction(action);
		self._view:subscribeEvent("UIActionEnd", "onTaskActionEnd");
	end
	--]]
	
	self:Close();
end

function task:updateVigorState()
	local playerData = dataManager.playerData;
	local can, id = playerData:isCanGetFreeVigor();
	self.task_button_tip:SetVisible(can);
	self.task_timenotice:SetText( playerData:GetNextFreeVigorTime())
end

function task:updateTaskState()
	local playerData = dataManager.playerData;
	self.task_tab1_tip:SetVisible(playerData:isHaveCanGainedDailyTaskReward());
	self.task_tab2_tip:SetVisible(playerData:isHaveCanGainedLevelReward());
	self.task_tab3_tip:SetVisible(playerData:isCanGetLoginReward());
end

function task:updateTaskDailyTaskItem(taskID, config, unfinished, levellimit)
	
	function onClickTaskDailyTaskGoto(args)
		local window = LORD.toWindowEventArgs(args).window;
		local taskID = window:GetUserData();
		
		local config = dataManager.playerData:getDailyTaskConfig(taskID);
		local finishType = config.finishType;
		
		if finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_ADVENTURE or 
			finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_NORMAL then
			local zones = dataManager.instanceZonesData;
			local stage = zones:getNewInstance(enum.Adventure_TYPE.NORMAL);
			eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW, stage = stage});
			
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_ELITE then
			local zones = dataManager.instanceZonesData;
			--print("setAdventureEliteProcess "..id);
			local stage = zones:getNewInstance(enum.Adventure_TYPE.ELITE);
			eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW, stage = stage});
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PVP_ONLINE then
			--todo
			local day = dataManager.getServerOpenDay()
			if(day < 1)then
					eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
						messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
						textInfo = "开服第一天不开放同步PVP活动" });
				return
			end
					homeland.arenaHandle()
			---eventManager.dispatchEvent({name = global_event.ARENA_SHOW});
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PVP_OFFLINE then
			--todo
			--eventManager.dispatchEvent({name = global_event.ARENA_SHOW});
			homeland.arenaHandle()
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PURCHASE_GOLD then
			eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", 
							resType = enum.BUY_RESOURCE_TYPE.GOLD, copyType = -1, copyID = -1, });
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PURCHASE_LUMBER then
			eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", 
							resType = enum.BUY_RESOURCE_TYPE.WOOD, copyType = -1, copyID = -1, });
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_MEDITATION then
			
			homeland.magicTowerHandle();
			
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_MONTH_RIGHT then
			eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_SWIEEP_TICKET then
		
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_CHALLENGE_STAGE then
			
			homeland.shipHandle();
			
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_CHALLENGE_DAMAGE then
			homeland.shipHandle()
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_CHALLENGE_SPEED then
			homeland.shipHandle()
    
    elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_FRIENDS_PLAY then
    
      eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_SHOW});
    
    elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PLUNDER then
    	
    	homeland.shenXiangHandle();
		
		elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_CHALLENGE_CRUSADE then
  		
  		homeland.shipHandle()
  		
  	elseif finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_GIFTS_VIGOR then
			
			eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_SHOW});
			
		end
		
		self:onHide();
	end
	
	local playerData = dataManager.playerData;
	local k = taskID;
	local taskaward_icon = LORD.toStaticImage(self:Child("task-"..k.."_taskaward-item-image"));
	local taskaward_name = self:Child("task-"..k.."_taskaward-name");
	local taskaward_infor = self:Child("task-"..k.."_taskaward-infor");
	local taskaward_award_money_num = {};
	local taskaward_award_money = {};
	taskaward_award_money_num[1] = self:Child("task-"..k.."_taskaward-award-money1-num");
	taskaward_award_money_num[2] = self:Child("task-"..k.."_taskaward-award-money2-num");
	taskaward_award_money_num[3] = self:Child("task-"..k.."_taskaward-award-money3-num");
	taskaward_award_money[1] = LORD.toStaticImage(self:Child("task-"..k.."_taskaward-award-money1"));
	taskaward_award_money[2] = LORD.toStaticImage(self:Child("task-"..k.."_taskaward-award-money2"));
	taskaward_award_money[3] = LORD.toStaticImage(self:Child("task-"..k.."_taskaward-award-money3"));
	
	-- item 图标
	local taskaward_award_item = {};
	local taskaward_award_item_icon = {};
	local taskaward_award_item_num = {};
	for i=1, 3 do
		taskaward_award_item[i] = LORD.toStaticImage(self:Child("task-"..k.."_taskaward-award-item"..i));
		taskaward_award_item_icon[i] = LORD.toStaticImage(self:Child("task-"..k.."_taskaward-award-item"..i.."-icon"));
		taskaward_award_item_num[i] = self:Child("task-"..k.."_taskaward-award-item"..i.."-num");
		taskaward_award_item_icon[i]:SetImage("");
		taskaward_award_item[i]:SetImage("");
		taskaward_award_item_num[i]:SetText("");
	end
	
	local taskaward_num = self:Child("task-"..k.."_taskaward-num");
	local taskaward_complete = self:Child("task-"..k.."_taskaward-complete");
	local taskaward_go = self:Child("task-"..k.."_taskaward-go");
	taskaward_go:SetUserData(taskID);
	taskaward_go:subscribeEvent("ButtonClick", "onClickTaskDailyTaskGoto");
	
	
	for k,v in ipairs(taskaward_award_money) do
		taskaward_award_money[k]:SetImage("");
		taskaward_award_money_num[k]:SetText("");		
	end
	
	-- 奖励信息
	local pos = 1;
	if config.exp > 0 then
		taskaward_award_money[1]:SetImage(enum.EXP_ICON_STRING);
		taskaward_award_money_num[1]:SetText(config.exp);
		pos = 2;
	end
	
	for k, v in ipairs(config.rewardType) do
		if taskaward_award_money[pos] and taskaward_award_money_num[pos] then
			local rewardInfo = playerData:getRewardInfo(v, config.rewardID[k], config.rewardCount[k]);
			taskaward_award_money[pos]:SetImage(rewardInfo.icon);
			taskaward_award_money_num[pos]:SetText(rewardInfo.count);			
			pos = pos + 1;
		end
	end
	
	-- 如果类型是扫荡券，特殊处理
	if config.finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_SWIEEP_TICKET then
		local itemConfig = itemManager.getConfig(dataConfig.configs.ConfigConfig[0].sweepScrollID);
		if itemConfig then
			taskaward_award_item_icon[1]:SetImage(itemConfig.icon);
			taskaward_award_item[1]:SetImage(itemManager.getImageWithStar(itemConfig.star));
		end
		
		local vipConfig = playerData:getVipConfig();
		if vipConfig then
			taskaward_award_item_num[1]:SetText(vipConfig.sweepScrollCount);
		end
	end
	
	-- 奖励信息
	
	if unfinished or levellimit then
		taskaward_go:SetVisible(true);
		taskaward_complete:SetVisible(false);
		taskaward_num:SetVisible(true);
	else
		taskaward_go:SetVisible(false);
		taskaward_complete:SetVisible(true);
		taskaward_num:SetVisible(false);	
	end
		
	taskaward_icon:SetImage(config.icon);
	taskaward_name:SetText(config.name);
	taskaward_infor:SetText(config.description);
	
	
	local currentProgress = playerData:getDailyTaskCurrentProgress(taskID);
	taskaward_num:SetText(currentProgress.."/"..config.finishParam);
	
	if config.finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_MONTH_RIGHT then
		if unfinished == true then
			taskaward_num:SetText("未购买");
		else
			taskaward_name:SetText(config.name.."（剩余"..currentProgress.."天）");
		end
	else
		taskaward_num:SetText(currentProgress.."/"..config.finishParam);
		
		if config.finishType == enum.DAILY_TASK_TYPE.DAILY_TASK_TYPE_PVP_ONLINE then
			local day = dataManager.getServerOpenDay()
			if(day < 1)then
				taskaward_num:SetText("明日解锁");
			end		
		end
		
	end


	if levellimit then
		taskaward_num:SetText("^FF0000"..config.level.."级解锁");
		taskaward_go:SetVisible(false);
	end
		
end

function task:updateTaskDailyTask()
	
	self:updateTaskState();
	self.task_scroll:ClearAllItem();
	
	local playerData = dataManager.playerData;
	local canAwardList = playerData:getDailyTaskCanAwardedList();
	local unfinishedList = playerData:getDailyTaskUnfinishedList();
	local levellimitList = playerData:getDailyTaskLevelLimitAwardedList();
	
	local xpos = LORD.UDim(0,0);
	local ypos = LORD.UDim(0,0);

	function onClickTaskDailyTaskSendGet(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		uiaction.scale(window, CLICK_AWARD_SCALE);
		
		scheduler.performWithDelayGlobal(function() 
			
			if global.tipBagFull() then
				return;
			end
		
			local taskID = window:GetUserData();
		
			sendSystemReward(enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_DAILY_TASK, taskID);
		
		end, 0.2)
		--print("onClickTaskDailyTaskSendGet")
	end
	
	function onClickTaskDailyTaskSelect(args)
		local window = LORD.toWindowEventArgs(args).window;
		local taskID = window:GetUserData();
		
		for k,v in ipairs(canAwardList) do
			if taskID == v.taskID then
				self:Child("task-"..v.taskID.."_taskaward-back"):SetVisible(true);
			else
				self:Child("task-"..v.taskID.."_taskaward-back"):SetVisible(false);
			end
		end
		
		for k,v in ipairs(unfinishedList) do
			if taskID == v.taskID then
				self:Child("task-"..v.taskID.."_taskaward-back"):SetVisible(true);
			else
				self:Child("task-"..v.taskID.."_taskaward-back"):SetVisible(false);
			end		
		end
		
		for k,v in ipairs(levellimitList) do
			if taskID == v.taskID then
				self:Child("task-"..v.taskID.."_taskaward-back"):SetVisible(true);
			else
				self:Child("task-"..v.taskID.."_taskaward-back"):SetVisible(false);
			end
		end
	end
	
	local count = 0;
		
	-- 可以领取的奖励
	for k,v in ipairs(canAwardList) do
		local taskID = v.taskID;
		local config = playerData:getDailyTaskConfig(taskID);
		if config then
			local taskawardItem = LORD.toStaticImage(LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("task-"..taskID, "taskaward.dlg"));
			
			local taskback = self:Child("task-"..taskID.."_taskaward-back");
			taskback:SetVisible(true);
						
			taskawardItem:SetXPosition(xpos);
			taskawardItem:SetYPosition(ypos);
			
			count = count + 1;

			self.task_scroll:additem(taskawardItem);
			
			taskawardItem:SetUserData(taskID);
			taskawardItem:subscribeEvent("WindowTouchUp", "onClickTaskDailyTaskSendGet");
			--taskawardItem:subscribeEvent("WindowTouchDown", "onClickTaskDailyTaskSelect");
			
			self:updateTaskDailyTaskItem(taskID, config, false);
			
			if math.fmod(count, 3) == 0 then
				ypos = ypos + taskawardItem:GetHeight();
				xpos = LORD.UDim(0,0);
			else
				xpos = xpos + taskawardItem:GetWidth();
			end
		end
	end
	
	-- 不可领取的奖励
	for k,v in ipairs(unfinishedList) do
		local taskID = v.taskID;
		local config = playerData:getDailyTaskConfig(taskID);
		if config then
			
			count = count + 1;
			
			local taskawardItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("task-"..taskID, "taskaward.dlg");
			local taskback = self:Child("task-"..taskID.."_taskaward-back");
			taskback:SetVisible(false);
			
			taskawardItem:SetXPosition(xpos);
			taskawardItem:SetYPosition(ypos);
			self.task_scroll:additem(taskawardItem);
			
			taskawardItem:SetUserData(taskID);
			--taskawardItem:subscribeEvent("WindowTouchDown", "onClickTaskDailyTaskSelect");
			
			self:updateTaskDailyTaskItem(taskID, config, true);

			if math.fmod(count, 3) == 0 then
				ypos = ypos + taskawardItem:GetHeight();
				xpos = LORD.UDim(0,0);
			else
				xpos = xpos + taskawardItem:GetWidth();
			end

		end
	end
		
	-- 等级限制的奖励

	for k,v in ipairs(levellimitList) do
		local taskID = v.taskID;
		local config = playerData:getDailyTaskConfig(taskID);
		if config then
		
			count = count + 1;
			
			local taskawardItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("task-"..taskID, "taskaward.dlg");
			
			local taskback = self:Child("task-"..taskID.."_taskaward-back");
			taskback:SetVisible(false);
			
			taskawardItem:SetXPosition(xpos);
			taskawardItem:SetYPosition(ypos);
			self.task_scroll:additem(taskawardItem);
			
			self:updateTaskDailyTaskItem(taskID, config, true, true);

			taskawardItem:SetUserData(taskID);
			--taskawardItem:subscribeEvent("WindowTouchDown", "onClickTaskDailyTaskSelect");
						
			if math.fmod(count, 3) == 0 then
				ypos = ypos + taskawardItem:GetHeight();
				xpos = LORD.UDim(0,0);
			else
				xpos = xpos + taskawardItem:GetWidth();
			end
			
		end
	end
		
end

-- 等级奖励
function task:updateTaskLevelUp()
	
	self:updateTaskState();
		
	-- 领取处理函数
	function onClickTaskLevelReward(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		uiaction.scale(window, CLICK_AWARD_SCALE);
		
		scheduler.performWithDelayGlobal(function() 
			if global.tipBagFull() then
				return;
			end
			local rewardID = window:GetUserData();
			sendSystemReward(enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_LEVEL_UP, rewardID);		
		end, 0.2);
		
	end
	
	function onClickTaskLevelRewardSelect(args)
		local window = LORD.toWindowEventArgs(args).window;
		local rewardID = window:GetUserData();
		
		local rewardList = dataManager.playerData:getLevelRewardList();
		for k,v in ipairs(rewardList) do
			local config = dataManager.playerData:getLevelRewardConfig(v);
			local hasGained = dataManager.playerData:hasLevelRewardGained(v);
			local hasFinished = dataManager.playerData:hasLevelRewardFinished(v);
			
			if config and (not hasGained) then
			
				if v == rewardID then
					self:Child("task-l-"..v.."_loginaward-back"):SetVisible(true);
				else
					self:Child("task-l-"..v.."_loginaward-back"):SetVisible(false);
				end
			end
		end
	end
	
	self.task_scroll:ClearAllItem();
	
	local playerData = dataManager.playerData;
	local xpos = LORD.UDim(0,0);
	local ypos = LORD.UDim(0,0);
	
	local count = 0;
	
	local rewardList = playerData:getLevelRewardList();
	for k,v in ipairs(rewardList) do
		local config = playerData:getLevelRewardConfig(v);
		local hasGained = playerData:hasLevelRewardGained(v);
		local hasFinished = playerData:hasLevelRewardFinished(v);
		
		if config and (not hasGained) then
			
			count = count + 1;
			local levelRewardItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("task-l-"..v, "loginaward.dlg");
			levelRewardItem:SetXPosition(xpos);
			levelRewardItem:SetYPosition(ypos);
			self.task_scroll:additem(levelRewardItem);
			
			local levelaward_name = self:Child("task-l-"..v.."_loginaward-name");
			local levelaward_go = self:Child("task-l-"..v.."_loginaward-go");
			--local levelaward_infor = self:Child("task-l-"..v.."_loginaward-infor");
			local levelaward_finish = self:Child("task-l-"..v.."_loginaward-finish");
			
			self:Child("task-l-"..v.."_loginaward-back"):SetVisible(false);
			-- levelaward_go
			levelaward_finish:SetVisible(hasFinished);
			self:Child("task-l-"..v.."_loginaward-back"):SetVisible(hasFinished);
			
			levelRewardItem:SetUserData(v);
			
			if hasFinished then
				levelRewardItem:subscribeEvent("WindowTouchUp", "onClickTaskLevelReward");
			end
			--levelRewardItem:subscribeEvent("WindowTouchDown", "onClickTaskLevelRewardSelect");
			
			levelaward_name:SetText(config.level.."级奖励");
			--levelaward_infor:SetText("等级达到"..config.level.."后可领取");
			
			--金钱奖励
			local levelaward_money_icon = {};
			local levelaward_money_num = {};
			
			for i=1, 3 do
				levelaward_money_icon[i] = LORD.toStaticImage(self:Child("task-l-"..v.."_loginaward-award-money"..i));
				levelaward_money_num[i] = self:Child("task-l-"..v.."_loginaward-award-money"..i.."-num");
				levelaward_money_icon[i]:SetVisible(false);
			end
			
			--物品奖励
			local levelaward_item = {};
			local levelaward_item_image = {};
			local levelaward_item_num = {};
			local levelaward_item_dw = {};
			local levelaward_item_container = {};
			local levelaward_item_star = {};
			
			for i=1, 4 do
				levelaward_item[i] = LORD.toStaticImage(self:Child("task-l-"..v.."_loginaward-item"..i));
				levelaward_item_image[i] = LORD.toStaticImage(self:Child("task-l-"..v.."_loginaward-item"..i.."-image"));
				levelaward_item_container[i] = LORD.toStaticImage(self:Child("task-l-"..v.."_loginaward-item"..i.."-container"));
				levelaward_item_num[i] = self:Child("task-l-"..v.."_loginaward-item"..i.."-num");
				levelaward_item[i]:SetVisible(false);
				
				levelaward_item_dw[i] = self:Child("task-l-"..v.."_loginaward-item"..i.."-dw");
				levelaward_item_dw[i]:SetVisible(false);
				
				levelaward_item_star[i] = {};
				
				for j=1,5 do
					levelaward_item_star[i][j] = self:Child("task-l-"..v.."_loginaward-item"..i.."-star"..j);
				end
				
			end
			
			local moneyIndex = 1;
			local itemIndex = 1;
			
			for typeKey, typeValue in ipairs(config.rewardType) do
				local rewardInfo = playerData:getRewardInfo(typeValue, config.rewardID[typeKey], config.rewardCount[typeKey]);
				if rewardInfo then
					if typeValue == enum.REWARD_TYPE.REWARD_TYPE_MONEY and levelaward_money_icon[moneyIndex] then
						levelaward_money_icon[moneyIndex]:SetVisible(true);
						levelaward_money_icon[moneyIndex]:SetImage(rewardInfo.icon);
						levelaward_money_num[moneyIndex]:SetText(rewardInfo.count);
						
						moneyIndex = moneyIndex + 1;
					elseif levelaward_item[itemIndex] then
						levelaward_item_dw[itemIndex]:SetVisible(true);
						levelaward_item[itemIndex]:SetVisible(true);
						levelaward_item_image[itemIndex]:SetImage(rewardInfo.icon);
						levelaward_item_container[itemIndex]:SetImage(rewardInfo.backImage);
						
						levelaward_item[itemIndex]:SetImage(itemManager.getImageWithStar(rewardInfo.star, rewardInfo.isDebris));
						if rewardInfo.count > 1 then
							levelaward_item_num[itemIndex]:SetText(rewardInfo.count);
						else
							levelaward_item_num[itemIndex]:SetText("");
						end
						
						global.setMaskIcon(levelaward_item_image[itemIndex], rewardInfo.maskicon);

						-- 绑定tips事件
						levelaward_item_image[itemIndex]:SetUserData(config.rewardID[typeKey]);

						if typeValue == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
							levelaward_item_image[itemIndex]:SetUserData(dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star));
						end
													
						global.onItemTipsShow(levelaward_item_image[itemIndex], typeValue, "top");
						global.onItemTipsHide(levelaward_item_image[itemIndex]);

						for j =1 ,5 do
							levelaward_item_star[itemIndex][j]:SetVisible( j <= rewardInfo.showstar);
						end
																			
						itemIndex = itemIndex + 1;
					end
				end
			end
						
			if math.fmod(count, 3) == 0 then
				ypos = ypos + levelRewardItem:GetHeight();
				xpos = LORD.UDim(0,0);
			else
				xpos = xpos + levelRewardItem:GetWidth();
			end
						
		end
	end
	
end

-- 登录奖励
function task:updateTaskLoginReward()
	self:updateTaskState();
	
	-- 领取处理函数
	function onClickTaskLoginReward(args)
		
		local window = LORD.toWindowEventArgs(args).window;
				
		uiaction.scale(window, CLICK_AWARD_SCALE);
		
		local playerData = dataManager.playerData;
		local gainedDays = playerData:getPlayerAttr(enum.PLAYER_ATTR.PLAYER_ATTR_LOGIN_REWARD);
		
		if global.tipBagFull() then
			return;
		end
		
		sendSystemReward(enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_SIGN_IN, gainedDays+1);
								
		if gainedDays == 0 then
			
			self:onHide();
								
			scheduler.performWithDelayGlobal(function() 
				
					local displayFuliObject = displayFuli.new();
					
					displayFuliObject:setCameraParams(LORD.Vector3(homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].pos.x, homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].pos.y, homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].pos.z), LORD.Vector3(homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].dir.x, homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].dir.y, homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].dir.z));
																									
					displayFuliObject:setActorParams("cirijiangli.actor", "skill", LORD.Vector3(homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].x, homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].y+1.5 , homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].z), LORD.Quaternion(1, 0, 0.4, -0.1), 4);
					
					displayFuliObject:setDarkParam(0.2);
					
					displayFuliObject:start();
										
			end, 0.2);			
		end
		
	end
	
	function onClickTaskLoginRewardSelect(args)
		
		local playerData = dataManager.playerData;
		
		local window = LORD.toWindowEventArgs(args).window;
		local rewardID = window:GetUserData();
				
		local rewardList = playerData:getLoginRewardList();
		for k,v in ipairs(rewardList) do
			local config = playerData:getLoginRewardConfig(v);
			local hasGained = playerData:hasLoginRewardGained(v);
			local hasFinished = playerData:hasLoginRewardFinished(v);
			
			if config and (not hasGained) then
				local loginaward_back = self:Child("task-"..v.."_loginaward-back");
				
				if v == rewardID then
					loginaward_back:SetVisible(true);
				else
					loginaward_back:SetVisible(false);
				end
			end
		end
	end
	
	self.task_scroll:ClearAllItem();
	
	local playerData = dataManager.playerData;
	local xpos = LORD.UDim(0,0);
	local ypos = LORD.UDim(0,0);
	
	local count = 0;
	
	local rewardList = playerData:getLoginRewardList();
	for k,v in ipairs(rewardList) do
		local config = playerData:getLoginRewardConfig(v);
		local hasGained = playerData:hasLoginRewardGained(v);
		local hasFinished = playerData:hasLoginRewardFinished(v);
		
		--print(tostring(hasGained).." hasGained ".." k "..k);
		if config and (not hasGained) then
			
			count = count + 1;
			local loginRewardItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("task-"..v, "loginaward.dlg");
			loginRewardItem:SetXPosition(xpos);
			loginRewardItem:SetYPosition(ypos);
			self.task_scroll:additem(loginRewardItem);
			
			local loginaward_back = self:Child("task-"..v.."_loginaward-back");
			loginaward_back:SetVisible(hasFinished);
			local loginaward_finish = self:Child("task-"..v.."_loginaward-finish");
			
			local loginaward_name = self:Child("task-"..v.."_loginaward-name");
			local loginaward_go = self:Child("task-"..v.."_loginaward-go");
			
			-- loginaward_go
			loginaward_finish:SetVisible(hasFinished);
			loginRewardItem:SetUserData(v);
			
			if hasFinished then
				loginRewardItem:subscribeEvent("WindowTouchUp", "onClickTaskLoginReward");				
			end
			
			--loginRewardItem:subscribeEvent("WindowTouchUp", "onClickTaskLoginRewardSelect");				
			
			if k == #rewardList then
				loginaward_name:SetText("每日登录奖励");
			else
				loginaward_name:SetText("第"..config.id.."天");
			end
			
			--金钱奖励
			local loginaward_money_icon = {};
			local loginaward_money_num = {};
			
			for i=1, 3 do
				loginaward_money_icon[i] = LORD.toStaticImage(self:Child("task-"..v.."_loginaward-award-money"..i));
				loginaward_money_num[i] = self:Child("task-"..v.."_loginaward-award-money"..i.."-num");
				loginaward_money_icon[i]:SetVisible(false);
			end
			
			--物品奖励
			local loginaward_item = {};
			local loginaward_item_image = {};
			local loginaward_item_num = {};
			local loginaward_item_dw = {};
			local loginaward_item_container = {};
			local loginaward_item_star = {};
			
			for i=1, 4 do
				loginaward_item[i] = LORD.toStaticImage(self:Child("task-"..v.."_loginaward-item"..i));
				loginaward_item_image[i] = LORD.toStaticImage(self:Child("task-"..v.."_loginaward-item"..i.."-image"));
				loginaward_item_container[i] = LORD.toStaticImage(self:Child("task-"..v.."_loginaward-item"..i.."-container"));
				loginaward_item_num[i] = self:Child("task-"..v.."_loginaward-item"..i.."-num");
				loginaward_item[i]:SetVisible(false);
				
				loginaward_item_dw[i] = self:Child("task-"..v.."_loginaward-item"..i.."-dw");
				loginaward_item_dw[i]:SetVisible(false);
				
				loginaward_item_star[i] = {};
				
				for j=1,5 do
					loginaward_item_star[i][j] = self:Child("task-"..v.."_loginaward-item"..i.."-star"..j);
				end
				
			end
			
			local moneyIndex = 1;
			local itemIndex = 1;
			
			for typeKey, typeValue in ipairs(config.rewardType) do
				local rewardInfo = playerData:getRewardInfo(typeValue, config.rewardID[typeKey], config.rewardCount[typeKey]);
				if rewardInfo then
					if typeValue == enum.REWARD_TYPE.REWARD_TYPE_MONEY and loginaward_money_icon[moneyIndex] then
						loginaward_money_icon[moneyIndex]:SetVisible(true);
						loginaward_money_icon[moneyIndex]:SetImage(rewardInfo.icon);
						loginaward_money_num[moneyIndex]:SetText(rewardInfo.count);
						
						moneyIndex = moneyIndex + 1;
					elseif loginaward_item[itemIndex] then
						loginaward_item_dw[itemIndex]:SetVisible(true);
						loginaward_item[itemIndex]:SetVisible(true);
						loginaward_item_image[itemIndex]:SetImage(rewardInfo.icon);
						loginaward_item_container[itemIndex]:SetImage(rewardInfo.backImage);
						loginaward_item[itemIndex]:SetImage(itemManager.getImageWithStar(rewardInfo.star, rewardInfo.isDebris));
						
						if rewardInfo.count > 1 then
							loginaward_item_num[itemIndex]:SetText(rewardInfo.count);
						else
							loginaward_item_num[itemIndex]:SetText("");
						end
						
						global.setMaskIcon(loginaward_item_image[itemIndex], rewardInfo.maskicon);

						-- 绑定tips事件
						loginaward_item_image[itemIndex]:SetUserData(config.rewardID[typeKey]);

						if typeValue == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
							loginaward_item_image[itemIndex]:SetUserData(dataManager.kingMagic:mergeIDLevel(rewardInfo.id, rewardInfo.star));
						end
																
						global.onItemTipsShow(loginaward_item_image[itemIndex], typeValue, "top");
						global.onItemTipsHide(loginaward_item_image[itemIndex]);
						
						for j =1 ,5 do
							loginaward_item_star[itemIndex][j]:SetVisible( j <= rewardInfo.showstar);
						end 
												
						itemIndex = itemIndex + 1;
					end
				end
			end
			
			if math.fmod(count, 3) == 0 then
				ypos = ypos + loginRewardItem:GetHeight();
				xpos = LORD.UDim(0,0);
			else
				xpos = xpos + loginRewardItem:GetWidth();
			end
						
		end
	end
		
end

function task:onUpdateList()

	if not self._show then
		return;
	end	
	
	if self.task_tab1:IsSelected() then
		self:updateTaskDailyTask();
	elseif self.task_tab2:IsSelected() then
		self:updateTaskLevelUp();
	elseif self.task_tab3:IsSelected() then
		self:updateTaskLoginReward();
	end
end

return task;
