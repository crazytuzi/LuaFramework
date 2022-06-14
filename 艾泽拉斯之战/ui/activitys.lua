local activitys = class( "activitys", layout );

global_event.ACTIVITYS_SHOW = "ACTIVITYS_SHOW";
global_event.ACTIVITYS_HIDE = "ACTIVITYS_HIDE";
global_event.ACTIVITYS_UPDATE = "ACTIVITYS_UPDATE";

function activitys:ctor( id )
	activitys.super.ctor( self, id );
	self:addEvent({ name = global_event.ACTIVITYS_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ACTIVITYS_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.ACTIVITYS_UPDATE, eventHandler = self.onUpdate});
end

function activitys:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	---self.activitys_name = self:Child( "activitys-name" );
	--self.activitys_text_detail = self:Child( "activitys-text-detail" );
	self.activitys_list = LORD.toScrollPane(self:Child( "activitys-list" ));
	self.activitys_list:init();

	--self.activitys_name:SetText("");
	--self.activitys_text_detail:SetText("");
		
		
	self.activitys_textsp = LORD.toScrollPane(self:Child( "activitys-textsp" ));
	self.activitys_textsp:init();	
		
		
	self.activitys_gift = LORD.toScrollPane(self:Child( "activitys-gift" ));
	self.activitys_gift:init();
	
	self.activitys_close = self:Child( "activitys-close" );
	
	function onActivitysClose()
		self:onHide();
	end
	
	self.activitys_close:subscribeEvent("ButtonClick", "onActivitysClose");
	
	self:initTabList();
	
	
	local firstSelect = 0;
	local tabData = dataManager.limitedActivity:getTabData();
	
	for k,v in ipairs(tabData) do
		
		if v:shouldShow() then
			firstSelect = k;
			
			break;
		end
		
	end
	
	if firstSelect > 0 then	
		self:onSelectTab(firstSelect);
	end
	
end

function activitys:onHide(event)
	self:Close();
end

function activitys:initTabList()
	
	function onActivitysSelectTab(args)
		local window = LORD.toWindowEventArgs(args).window;
		local index = window:GetUserData();
		
		self:onSelectTab(index);
		
	end
	
	self.activitys_list:ClearAllItem();
	
	local tabData = dataManager.limitedActivity:getTabData();
	
	local xPosition = LORD.UDim(0, 0);
	local yPosition = LORD.UDim(0, 0);
	
	for k,v in ipairs(tabData) do
		
		if v:shouldShow() then
		
			local item = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("activitys"..k, "activitysitemlist.dlg");
			local background = self:Child("activitys"..k.."_activitysitemlist-background");
			local image = LORD.toStaticImage(self:Child("activitys"..k.."_activitysitemlist-image"));
			local name = self:Child("activitys"..k.."_activitysitemlist-name");
			local chose = self:Child("activitys"..k.."_activitysitemlist-chose");
			local point = self:Child("activitys"..k.."_activitysitemlist-point");
			
			point:SetVisible(v:hasNotifyPoint());
			item:SetUserData(k);
			item:subscribeEvent("WindowTouchUp", "onActivitysSelectTab");
			
			item:SetXPosition(xPosition);
			item:SetYPosition(yPosition);
			
			self.activitys_list:additem(item);
			
			name:SetText(v:getName());
			image:SetImage(v:getIcon());
			
			yPosition = yPosition + item:GetHeight();
		end
		
	end
	
end

function activitys:onSelectTab(index)
	
	self.selectTab = index;
	
	function onActivitysClickGetReward(args)
		local window = LORD.toWindowEventArgs(args).window;
		local id = window:GetUserData();
		
		sendSystemReward(enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_LIMIT_ACTIVITY, id);
		
	end
	
	-- 前往按钮的处理
	function onActivitysClickGoto(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local id = window:GetUserData();
		
		local instance = dataManager.limitedActivity:getActivityByID(id);
		if instance then
			instance:onClickGoto();
		end
	end
	
	-- 显示隐藏choose 悟    空 源 码 网 ww w . w k ym w .com
	local tabData = dataManager.limitedActivity:getTabData();
	for k,v in ipairs(tabData) do
		local choose = self:Child("activitys"..k.."_activitysitemlist-chose");
		if choose then
			choose:SetVisible(k == index);
		end
	end
	
	local tabInstance = tabData[index];
	
	self.activitys_gift:ClearAllItem();
	self.activitys_textsp:ClearAllItem();	
	--self.activitys_name:SetText(tabInstance:getName());
	--self.activitys_text_detail:SetText(tabInstance:getDesc());
	
	
	
	local activitysruleitem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("activitys", "activitysrule.dlg");
	local activitysruleName = self:Child("activitys".."_activitysrule-name");
	local activitysruleDetail = self:Child("activitys".."_activitysrule-text-detail");	
	
	activitysruleName:SetText(tabInstance:getName());
	activitysruleDetail:SetText(tabInstance:getDesc());
	activitysruleitem:SetXPosition(LORD.UDim(0, 0));
	activitysruleitem:SetYPosition(LORD.UDim(0, 0));
	self.activitys_textsp:additem(activitysruleitem);	

	
	local xPosition = LORD.UDim(0, 0);
	local yPosition = LORD.UDim(0, 0);
	
	-- init activity
	local childActivity = tabInstance:getChildActivity();
	
	
	for k,v in ipairs(childActivity) do
		
		--print("-------------------"..tostring(v:shouldShow()))
		
		if v:shouldShow() then
		
			local item = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("activitys"..k, "activitysgiftitem.dlg");
			local name = self:Child("activitys"..k.."_activitysgiftitem-name");
			local button = self:Child("activitys"..k.."_activitysgiftitem-button");
			--local text = self:Child("activitys"..k.."_activitysgiftitem-text");
			--local remain_num = self:Child("activitys"..k.."_activitysgiftitem-remain-num");
			local remain = self:Child("activitys"..k.."_activitysgiftitem-remain");
			
			local image = LORD.toStaticImage(self:Child("activitys"..k.."_activitysgiftitem-textimage"));
			
			local button_goto = self:Child("activitys"..k.."_activitysgiftitem-button-goto");
			
			-- 是否显示可领取按钮
			button:SetVisible(v:isCanGained());
			-- 是否显示前往按钮
			button_goto:SetVisible(v:isShowGotoButton());
			
			button:SetUserData(v:getID());
			button:subscribeEvent("ButtonClick", "onActivitysClickGetReward");
			button_goto:SetUserData(v:getID());
			button_goto:subscribeEvent("ButtonClick", "onActivitysClickGoto");
			button_goto:SetText(v:getGotoButtonText());
			
			local _text,_image = v:getStateText()
			--text:SetText(v:getStateText());
			image:SetImage(_image);
	 
			name:SetText(v:getName());
			
			local gift = {};
			local gift_containier = {};
			local gift_image = {};
			local gift_equity = {};
			local gift_num = {};
			local gift_star = {};
			local rewards = v:getRewards();
			local rewardCount = #rewards;
			
			--remain:SetVisible(v:getLimitAmount()>0);
			--remain_num:SetText(v:getLimitAmount());
			remain:SetText(v:getProgressText());
			
			for i=1, 5 do
				gift_star[i] = {}
				gift[i] = self:Child("activitys"..k.."_activitysgiftitem-gift"..i);	
				gift_containier[i] = LORD.toStaticImage(self:Child("activitys"..k.."_activitysgiftitem-gift"..i.."-containier"));
				gift_image[i] = LORD.toStaticImage(self:Child("activitys"..k.."_activitysgiftitem-gift"..i.."-image"));
				gift_equity[i] = LORD.toStaticImage(self:Child("activitys"..k.."_activitysgiftitem-gift"..i.."-equity"));
				gift_num[i] = self:Child("activitys"..k.."_activitysgiftitem-gift"..i.."-num");
				
				gift[i]:SetVisible(i <= rewardCount);
			 
				for j =1 ,5 do
					gift_star[i][j] = LORD.toStaticImage(self:Child("activitys"..k.."_activitysgiftitem--gift"..i.."-star"..j));
				end	
				
				if rewards[i] then
					
					gift_containier[i]:SetImage(rewards[i].backImage);
					gift_image[i]:SetImage(rewards[i].icon);
					gift_equity[i]:SetImage(rewards[i].qualityImage);
					gift_image[i]:SetUserData(rewards[i].userdata);
					global.setMaskIcon(gift_image[i], rewards[i].maskicon);
					gift_equity[i]:SetProperty("Touchable", "false");
					
					global.onItemTipsShow(gift_image[i], rewards[i].type, "top");
					global.onItemTipsHide(gift_image[i]);
						
					if rewards[i].count > 1 then
						gift_num[i]:SetText(rewards[i].count);
					else
						gift_num[i]:SetText("");
					end
					
					for j =1 ,5 do
						gift_star[i][j]:SetVisible( j <= rewards[i].showstar)
					end 
					
					
				end 
			end
				
			item:SetXPosition(xPosition);
			item:SetYPosition(yPosition);
			self.activitys_gift:additem(item);
			yPosition = yPosition + item:GetHeight();
		end
		
	end
	
end

function activitys:onUpdate()
	
	if self._show then
		
		-- update point
		local tabData = dataManager.limitedActivity:getTabData();
		for k,v in ipairs(tabData) do
			
			local point = self:Child("activitys"..k.."_activitysitemlist-point");
			
			if point then
				point:SetVisible(v:hasNotifyPoint());
			end
		end
		
		self:onSelectTab(self.selectTab);
	
	end
end

return activitys;
