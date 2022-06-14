local idolStatusRob = class( "idolStatusRob", layout );

global_event.IDOLSTATUSROB_SHOW = "IDOLSTATUSROB_SHOW";
global_event.IDOLSTATUSROB_HIDE = "IDOLSTATUSROB_HIDE";
global_event.IDOLSTATUSROB_UPDATE = "IDOLSTATUSROB_UPDATE";

function idolStatusRob:ctor( id )
	idolStatusRob.super.ctor( self, id );
	self:addEvent({ name = global_event.IDOLSTATUSROB_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.IDOLSTATUSROB_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.IDOLSTATUSROB_UPDATE, eventHandler = self.onUpdate});
end

function idolStatusRob:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onIdolStatusRobClickClose()
		
		self:onHide();
		
	end
	
	function onIdolStatusRobClickRefresh()
		
		dataManager.idolBuildData:onClickRefeshPlunder();
		
	end
	
	local idolStatusRob_close = self:Child("idolStatusRob-close");
	local reset_button = self:Child("idolStatusRob-reset-button");
	
	idolStatusRob_close:subscribeEvent("ButtonClick", "onIdolStatusRobClickClose");
	reset_button:subscribeEvent("ButtonClick", "onIdolStatusRobClickRefresh");
	
	self:onUpdate();
	--触发引导
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_IDOLSTATUSROB_OPEN}) 
	--
end

function idolStatusRob:onHide(event)
	self:Close();
end

function idolStatusRob:onUpdate()
	
	if not self._show then
	
		return;
		
	end
	
	function onClickIdolStatusRobFight(args)
		local window = LORD.toWindowEventArgs(args).window;
		local difficulty = window:GetUserData();
		
		dataManager.idolBuildData:onEnterBattlePrepare(difficulty);
		
	end
	
	
	local idolStatusRob_sp = LORD.toScrollPane(self:Child("idolStatusRob-sp"));
	idolStatusRob_sp:init();
	
	idolStatusRob_sp:ClearAllItem();
	
	local plunderTargets = dataManager.idolBuildData:getPlunderTargets();
	
	local xpos = LORD.UDim(0,5);
	local ypos = LORD.UDim(0,0);
	
	for i=1, 3 do
	
		local target = plunderTargets[i];
		
		local idolStatusRobItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("idolStatusRob"..i, "idolStatusRobItem.dlg");
		
		idolStatusRobItem:SetXPosition(xpos);
		idolStatusRobItem:SetYPosition(ypos);
		idolStatusRob_sp:additem(idolStatusRobItem);
		
		xpos = xpos + idolStatusRobItem:GetWidth()+LORD.UDim(0,5);
		

			-- update info 
		local head = LORD.toStaticImage(self:Child("idolStatusRob"..i.."_idolStatusRobItem-playerhead"));
		local lv = self:Child("idolStatusRob"..i.."_idolStatusRobItem-lv");
		local name = self:Child("idolStatusRob"..i.."_idolStatusRobItem-name");
		local power_num = self:Child("idolStatusRob"..i.."_idolStatusRobItem-power-num");
		local giftname = self:Child("idolStatusRob"..i.."_idolStatusRobItem-giftname");
		local idolStatusRobItem_fight = self:Child("idolStatusRob"..i.."_idolStatusRobItem-fight");
		
		if target then			
			name:SetText(target.name);
			power_num:SetText("战斗力："..target.playerPower);
			lv:SetText("Lv "..target.kingInfo.level);
			head:SetImage(global.getHeadIcon(target.icon));
			
			if target.difficulty == enum.PLUNDER_DIFFICULTY.PLUNDER_DIFFICULTY_HARD then
				
				giftname:SetText("^62009B高概率获得材料");
			
			elseif target.difficulty == enum.PLUNDER_DIFFICULTY.PLUNDER_DIFFICULTY_MEDIUM then
				
				giftname:SetText("^0021C5中概率获得材料");
				
			elseif target.difficulty == enum.PLUNDER_DIFFICULTY.PLUNDER_DIFFICULTY_EASY then
				
				giftname:SetText("^14A800低概率获得材料");
			
			end
			
			idolStatusRobItem_fight:SetUserData(target.difficulty);
			idolStatusRobItem_fight:SetVisible(true);
			idolStatusRobItem_fight:subscribeEvent("ButtonClick", "onClickIdolStatusRobFight");
			
		else			
			
			head:SetImage("");
			lv:SetText("");
			name:SetText("");
			power_num:SetText("");
			giftname:SetText("");
			idolStatusRobItem_fight:SetVisible(false);
			
		end
		
	end
	
end

return idolStatusRob;
