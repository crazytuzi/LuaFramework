local guildWarList = class( "guildWarList", layout );

global_event.GUILDWARLIST_SHOW = "GUILDWARLIST_SHOW";
global_event.GUILDWARLIST_HIDE = "GUILDWARLIST_HIDE";
global_event.GUILDWARLIST_UPDATE = "GUILDWARLIST_UPDATE";

function guildWarList:ctor( id )
	guildWarList.super.ctor( self, id );
	self:addEvent({ name = global_event.GUILDWARLIST_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.GUILDWARLIST_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.GUILDWARLIST_UPDATE, eventHandler = self.update});
end

function guildWarList:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onGuildWarListClose()
		self:onHide();
	end
	
	local guildWarList_close = self:Child("guildWarList-close");
	guildWarList_close:subscribeEvent("ButtonClick", "onGuildWarListClose");
	
	local guildWarList_editok = self:Child("guildWarList-editok");
	guildWarList_editok:subscribeEvent("ButtonClick", "onGuildWarListClose");
	
	self.event = event;

	function onGuildWarInfoGuildTips(args)
		
		local clickImage = LORD.toWindowEventArgs(args).window;
		local rect = clickImage:GetUnclippedOuterRect();
		
		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "guildWar", id = self.event.spotIndex, 
				windowRect = rect, dir = "free",});
						
	end
	
	function onGuildWarInfoGuildTipsHide()
		
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
		
	end
	
	function onGuildWarListCheckPlayerPlan(args)

		local clickImage = LORD.toWindowEventArgs(args).window;
		local rect = clickImage:GetUnclippedOuterRect();
		local data = clickImage:GetUserData();
		
		dataManager.chatData:setClickPosition(LORD.Vector2(rect.right+100, rect.top + 100 ));
		sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_INSPECT, data);
				
	end
	
	local guildWarList_buffdef = self:Child("guildWarList-buffdef");
	
	guildWarList_buffdef:subscribeEvent("WindowTouchDown", "onGuildWarInfoGuildTips");
	guildWarList_buffdef:subscribeEvent("WindowTouchUp", "onGuildWarInfoGuildTipsHide");
	guildWarList_buffdef:subscribeEvent("MotionRelease", "onGuildWarInfoGuildTipsHide");	
	
	self:update();
	
end

function guildWarList:onHide(event)
	self:Close();
end

-- 
function guildWarList:update()
	
	if not self._show then
		return;
	end

	if self.event.showType == "attack" then
		
		self:updateAttack();
		
	elseif self.event.showType == "edit" then
		
		self:updateEdit();
		
	elseif self.event.showType == "check" then
		
		self:updateCheck();
		
	end	
	
end

function guildWarList:updateAttack()

	if not self._show then
		return;
	end
		
	function onGuildWarListClickTargetPlayer(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local targetIndex = window:GetUserData();
		
		local spotIndex = self.event.spotIndex;
		
		local guildWarItem = self:Child("guildWarList"..targetIndex.."_guildWarItem");
		
		uiaction.scale(guildWarItem, 0.8);
		
		scheduler.performWithDelayGlobal(function() 
		
			dataManager.guildWarData:onHandleClickDefencePlayer(spotIndex, targetIndex);
		
		end, 0.2);
		
	end

	local guildWarList_eidtdef = self:Child("guildWarList-eidtdef");
	local guildWarList_battlezone = self:Child("guildWarList-battlezone");
	
	guildWarList_eidtdef:SetVisible(false);
	guildWarList_battlezone:SetVisible(true);
		
	local spot = dataManager.guildWarData:getSpot(self.event.spotIndex);
	
	local buffdef_dw = self:Child("guildWarList-buffdef-dw");
	local buffnum = self:Child("guildWarList-buffnum");
	local defgroup_titletext = self:Child("guildWarList-defgroup-titletext");
	local battlezone_sp = LORD.toScrollPane(self:Child("guildWarList-battlezone-sp"));
	local defgroup_deftype = self:Child("guildWarList-defgroup-deftype");
	local defgroup_defnum = self:Child("guildWarList-defgroup-defnum");
	local defgroup_atktime = self:Child("guildWarList-defgroup-atktime");
	
	battlezone_sp:init();
	battlezone_sp:ClearAllItem();
	
	if spot then
	
		buffdef_dw:SetVisible(spot:getNowDefenceBuffCount() >= 0);
		buffnum:SetText(spot:getNowDefenceBuffCount());
		
		local step = spot:getCurrentStageIndex();
		
		if step == 1 then
			
			defgroup_titletext:SetText("第一梯队");
			
		elseif step == 2 then
			
			defgroup_titletext:SetText("第二梯队");
			
		elseif step == 3 then
			
			defgroup_titletext:SetText("第三梯队");
			
		end
		
		defgroup_deftype:SetText("剩余梯队:"..spot:getRemainStage().."/"..spot:getMaxStageIndex());
		defgroup_defnum:SetText("守军数量:"..spot:getDefencePlayerCount());
		defgroup_atktime:SetText("进攻次数:"..dataManager.guildWarData:getRemainBattleTimes().."/"..dataManager.guildWarData:getMaxBattleTimes());
	
		
		local playerCount = spot:getDefencePlayerCount();
		
		local xpos = LORD.UDim(0, 0);
		local ypos = LORD.UDim(0, 0);
		
		for i=1, playerCount do
		
			local guildWarItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("guildWarList"..i, "guildWarItem.dlg");
			
			local guildWarItem_name = self:Child("guildWarList"..i.."_guildWarItem-name");
			local guildWarItem_lv = self:Child("guildWarList"..i.."_guildWarItem-lv");
			local guildWarItem_bar = self:Child("guildWarList"..i.."_guildWarItem-bar");
			local guildWarItem_bar_num = self:Child("guildWarList"..i.."_guildWarItem-bar-num");
			
			local guildWarItem_duelshadow = self:Child("guildWarList"..i.."_guildWarItem-duelshadow");
			local guildWarItem_container = LORD.toStaticImage(self:Child("guildWarList"..i.."_guildWarItem-container"));
			local guildWarItem_myhead = LORD.toStaticImage(self:Child("guildWarList"..i.."_guildWarItem-myhead"));
			
			
			
			local playerData = spot:getDefencePlayer(i);
			
			guildWarItem_duelshadow:SetVisible(spot:isFighting(i));
			
			guildWarItem_container:SetImage(itemManager.getImageWithStar(step));
			guildWarItem_container:SetUserData(i);
			
			local guildWarItem_info = self:Child("guildWarList"..i.."_guildWarItem-info");
			guildWarItem_info:SetUserData(playerData.playerID);
			guildWarItem_info:subscribeEvent("ButtonClick", "onGuildWarListCheckPlayerPlan");
			
			guildWarItem_container:subscribeEvent("WindowTouchUp", "onGuildWarListClickTargetPlayer");
			guildWarItem_myhead:SetImage(global.getHalfBodyImage(playerData.icon));
			
			if playerData.name == "" then
			
				guildWarItem_name:SetText("守护者");
			
			else
				
				guildWarItem_name:SetText(playerData.name);
				
			end
			
			guildWarItem_lv:SetText("Lv"..playerData.kingInfo.level);
			guildWarItem_bar:SetProperty("Progress", spot:getHpPercent(i));
			
			guildWarItem_bar_num:SetText(spot:getHpPercentText(i));
			
			
			guildWarItem:SetXPosition(xpos);
			guildWarItem:SetYPosition(ypos);
			
			if math.fmod(i, 2) == 0 then
				
				xpos = LORD.UDim(0, 0);
				ypos = ypos + guildWarItem:GetHeight();
				
			else
				
				xpos = xpos + guildWarItem:GetWidth();
				
			end
			
			battlezone_sp:additem(guildWarItem);
		end
		
	end
	
end

function guildWarList:updateCheck()

	if not self._show then
		return;
	end
	

	local guildWarList_eidtdef = self:Child("guildWarList-eidtdef");
	local guildWarList_battlezone = self:Child("guildWarList-battlezone");
	
	guildWarList_eidtdef:SetVisible(false);
	guildWarList_battlezone:SetVisible(true);
	
	local spot = dataManager.guildWarData:getSpot(self.event.spotIndex);
	
	local buffdef_dw = self:Child("guildWarList-buffdef-dw");
	local buffnum = self:Child("guildWarList-buffnum");
	local defgroup_titletext = self:Child("guildWarList-defgroup-titletext");
	local battlezone_sp = LORD.toScrollPane(self:Child("guildWarList-battlezone-sp"));
	local defgroup_deftype = self:Child("guildWarList-defgroup-deftype");
	local defgroup_defnum = self:Child("guildWarList-defgroup-defnum");
	local defgroup_atktime = self:Child("guildWarList-defgroup-atktime");
	
	battlezone_sp:init();
	battlezone_sp:ClearAllItem();
	
	if spot then
	
		buffdef_dw:SetVisible(spot:getNowDefenceBuffCount() > 0);
		buffnum:SetText(spot:getNowDefenceBuffCount());
		
		local step = spot:getCurrentStageIndex();
		
		if step == 1 then
			
			defgroup_titletext:SetText("第一梯队");
			
		elseif step == 2 then
			
			defgroup_titletext:SetText("第二梯队");
			
		elseif step == 3 then
			
			defgroup_titletext:SetText("第三梯队");
			
		end
		
		defgroup_deftype:SetText("剩余梯队:"..spot:getRemainStage().."/"..spot:getMaxStageIndex());
		defgroup_defnum:SetText("守军数量:"..spot:getDefencePlayerCount());
		defgroup_atktime:SetText("进攻次数:"..dataManager.guildWarData:getRemainBattleTimes().."/"..dataManager.guildWarData:getMaxBattleTimes());
	
		
		local playerCount = spot:getDefencePlayerCount();
		
		local xpos = LORD.UDim(0, 0);
		local ypos = LORD.UDim(0, 0);
		
		for i=1, playerCount do
		
			local guildWarItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("guildWarList"..i, "guildWarItem.dlg");
			
			local guildWarItem_name = self:Child("guildWarList"..i.."_guildWarItem-name");
			local guildWarItem_lv = self:Child("guildWarList"..i.."_guildWarItem-lv");
			local guildWarItem_bar = self:Child("guildWarList"..i.."_guildWarItem-bar");
			local guildWarItem_bar_num = self:Child("guildWarList"..i.."_guildWarItem-bar-num");
			
			local guildWarItem_duelshadow = self:Child("guildWarList"..i.."_guildWarItem-duelshadow");
			local guildWarItem_container = LORD.toStaticImage(self:Child("guildWarList"..i.."_guildWarItem-container"));
			local guildWarItem_myhead = LORD.toStaticImage(self:Child("guildWarList"..i.."_guildWarItem-myhead"));
			
			local playerData = spot:getDefencePlayer(i);

			local guildWarItem_info = self:Child("guildWarList"..i.."_guildWarItem-info");
			guildWarItem_info:SetUserData(playerData.playerID);
			guildWarItem_info:subscribeEvent("ButtonClick", "onGuildWarListCheckPlayerPlan");
						
			guildWarItem_duelshadow:SetVisible(spot:isFighting(i));
			
			guildWarItem_container:SetImage(itemManager.getImageWithStar(step));
			guildWarItem_container:SetUserData(i);
			--guildWarItem_container:subscribeEvent("WindowTouchUp", "onGuildWarListClickTargetPlayer");
			guildWarItem_myhead:SetImage(global.getHalfBodyImage(playerData.icon));
			
			if playerData.name == "" then
			
				guildWarItem_name:SetText("守护者");
			
			else
				
				guildWarItem_name:SetText(playerData.name);
				
			end
			
			guildWarItem_lv:SetText("Lv"..playerData.kingInfo.level);
			guildWarItem_bar:SetProperty("Progress", spot:getHpPercent(i));
			
			guildWarItem_bar_num:SetText(spot:getHpPercentText(i));
			
			
			guildWarItem:SetXPosition(xpos);
			guildWarItem:SetYPosition(ypos);
			
			if math.fmod(i, 2) == 0 then
				
				xpos = LORD.UDim(0, 0);
				ypos = ypos + guildWarItem:GetHeight();
				
			else
				
				xpos = xpos + guildWarItem:GetWidth();
				
			end
			
			battlezone_sp:additem(guildWarItem);
		end
		
	end
			
end

function guildWarList:updateEdit()

	if not self._show then
		return;
	end
	
	function onGuildWarListEditAdd(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local userdata = window:GetUserData();
		
		dataManager.guildWarData:onGuildPlanEditAdd(self.event.spotIndex, userdata);
		
	end
	
	function onGuildWarListEditRemove(args)

		local window = LORD.toWindowEventArgs(args).window;
		local userdata = window:GetUserData();
		
		dataManager.guildWarData:onGuildPlanEditRemove(self.event.spotIndex, userdata);	
	end
		
	local guildWarList_close = self:Child("guildWarList-close");
	guildWarList_close:SetVisible(false);
	
	local spot = dataManager.guildWarData:getSpot(self.event.spotIndex);
	
	local guildWarList_eidtdef = self:Child("guildWarList-eidtdef");
	local guildWarList_battlezone = self:Child("guildWarList-battlezone");
	
	guildWarList_eidtdef:SetVisible(true);
	guildWarList_battlezone:SetVisible(false);
	
	local guildinfo_sp = LORD.toScrollPane(self:Child("guildWarList-guildinfo-sp"));
	guildinfo_sp:init();
	guildinfo_sp:ClearAllItem();

	local defgroup_sp = LORD.toScrollPane(self:Child("guildWarList-defgroup-sp"));
	defgroup_sp:init();
	defgroup_sp:ClearAllItem();
	
	-- 备选
	local xpos = LORD.UDim(0, 0);
	local ypos = LORD.UDim(0, 0);
		
	local candidateList = dataManager.guildData:getCandidatePlayers();
	
	for k,v in ipairs(candidateList) do
		
		local guildWarItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("guildCandi"..k, "guildWarItem.dlg");
		
		local guildWarItem_name = self:Child("guildCandi"..k.."_guildWarItem-name");
		local guildWarItem_lv = self:Child("guildCandi"..k.."_guildWarItem-lv");
		local guildWarItem_bar = self:Child("guildCandi"..k.."_guildWarItem-bar");
		local guildWarItem_bar_num = self:Child("guildCandi"..k.."_guildWarItem-bar-num");
		
		guildWarItem_name:SetText(v:getName());
		guildWarItem_lv:SetText("Lv"..v:getLevel());
		
		local guildWarItem_duelshadow = self:Child("guildCandi"..k.."_guildWarItem-duelshadow");
		local guildWarItem_container = LORD.toStaticImage(self:Child("guildCandi"..k.."_guildWarItem-container"));
		local guildWarItem_myhead = LORD.toStaticImage(self:Child("guildCandi"..k.."_guildWarItem-myhead"));
		guildWarItem_duelshadow:SetVisible(false);
		guildWarItem_container:SetImage(itemManager.getImageWithStar(3));
		guildWarItem_myhead:SetImage(global.getHalfBodyImage(v:getHeadIcon()));
		
		local guildWarItem_info = self:Child("guildCandi"..k.."_guildWarItem-info");
		guildWarItem_info:SetUserData(v:getID());
		guildWarItem_info:subscribeEvent("ButtonClick", "onGuildWarListCheckPlayerPlan");
			
		local guildWarItem_add = self:Child("guildCandi"..k.."_guildWarItem-add");
		local guildWarItem_del = self:Child("guildCandi"..k.."_guildWarItem-del");
		guildWarItem_add:SetVisible(true);
		guildWarItem_del:SetVisible(false);
		guildWarItem_add:SetUserData(v:getID());
		guildWarItem_add:subscribeEvent("ButtonClick", "onGuildWarListEditAdd");
		
		guildWarItem:SetXPosition(xpos);
		guildWarItem:SetYPosition(ypos);
		ypos = ypos + guildWarItem:GetHeight();
		guildinfo_sp:additem(guildWarItem);
		
	end
	
	-- 已选
	local spot = dataManager.guildWarData:getSpot(self.event.spotIndex);
	local playerCount = spot:getDefencePlayerCount();
		
	local xpos = LORD.UDim(0, 0);
	local ypos = LORD.UDim(0, 0);
		
	for i=1, playerCount do
	
		local guildWarItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("guildEditCandi"..i, "guildWarItem.dlg");
		
		local guildWarItem_name = self:Child("guildEditCandi"..i.."_guildWarItem-name");
		local guildWarItem_lv = self:Child("guildEditCandi"..i.."_guildWarItem-lv");
		local guildWarItem_bar = self:Child("guildEditCandi"..i.."_guildWarItem-bar");
		local guildWarItem_bar_num = self:Child("guildEditCandi"..i.."_guildWarItem-bar-num");
		
		local guildWarItem_duelshadow = self:Child("guildEditCandi"..i.."_guildWarItem-duelshadow");
		local guildWarItem_container = LORD.toStaticImage(self:Child("guildEditCandi"..i.."_guildWarItem-container"));
		local guildWarItem_myhead = LORD.toStaticImage(self:Child("guildEditCandi"..i.."_guildWarItem-myhead"));
		
		local playerData = spot:getDefencePlayer(i);

		local guildWarItem_info = self:Child("guildEditCandi"..i.."_guildWarItem-info");
		guildWarItem_info:SetUserData(playerData.playerID);
		guildWarItem_info:subscribeEvent("ButtonClick", "onGuildWarListCheckPlayerPlan");
				
		guildWarItem_duelshadow:SetVisible(false);
		guildWarItem_container:SetImage(itemManager.getImageWithStar(3));
		guildWarItem_myhead:SetImage(global.getHalfBodyImage(playerData.icon));
		
		if playerData.name == "" then
		
			guildWarItem_name:SetText("守护者");
		
		else
			
			guildWarItem_name:SetText(playerData.name);
			
		end

		local guildWarItem_add = self:Child("guildEditCandi"..i.."_guildWarItem-add");
		local guildWarItem_del = self:Child("guildEditCandi"..i.."_guildWarItem-del");
		guildWarItem_add:SetVisible(false);
		guildWarItem_del:SetVisible(true);
		guildWarItem_del:SetUserData(playerData.playerID);
		guildWarItem_del:subscribeEvent("ButtonClick", "onGuildWarListEditRemove");
						
		guildWarItem_lv:SetText("Lv"..playerData.kingInfo.level);
		guildWarItem_bar:SetProperty("Progress",spot:getHpPercent(i));
		
		guildWarItem_bar_num:SetText(spot:getHpPercentText(i));
		
		guildWarItem:SetXPosition(xpos);
		guildWarItem:SetYPosition(ypos);
		
		ypos = ypos + guildWarItem:GetHeight();
			
		defgroup_sp:additem(guildWarItem);
	end
			
	
end


return guildWarList;
