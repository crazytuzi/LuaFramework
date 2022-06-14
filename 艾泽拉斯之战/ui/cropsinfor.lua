local cropsinfor = class( "cropsinfor", layout );

global_event.CROPSINFOR_SHOW = "CROPSINFOR_SHOW";
global_event.CROPSINFOR_HIDE = "CROPSINFOR_HIDE";

function cropsinfor:ctor( id )
	cropsinfor.super.ctor( self, id );
	self:addEvent({ name = global_event.CROPSINFOR_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CROPSINFOR_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.ENTER_GAME_STATE_INSTANCE, eventHandler = self.onHide})	
end

function cropsinfor:onShow(event)
	if self._show then
		return;
	end
	
	function onClickCropsInfoClose()
		self:onHide();
	end
	self:Show();
	self.cropsinfor_model1 = LORD.toActorWindow(self:Child( "cropsinfor-model1" ));
	self.cropsinfor_model2 = LORD.toActorWindow(self:Child( "cropsinfor-model2" ));
	self.cropsinfor_name = self:Child( "cropsinfor-name" );
	self.cropsinfor_renkou = self:Child( "cropsinfor-renkou" );

	self.cropsinfor_gongji_num = self:Child( "cropsinfor-gongji-num" );
	self.cropsinfor_fangyu_num = self:Child( "cropsinfor-fangyu-num" );
	self.cropsinfor_shengming_num = self:Child( "cropsinfor-shengming-num" );
	self.cropsinfor_sudu_num = self:Child( "cropsinfor-sudu-num" );
	self.cropsinfor_yidongli_num = self:Child( "cropsinfor-yidongli-num" );
	self.cropsinfor_shecheng_num = self:Child( "cropsinfor-shecheng-num" );
	self.cropsinfor_patch_bar_image = self:Child("cropsinfor-patch-bar-image");
	self.cropsinfor_patch_text = self:Child("cropsinfor-patch-text");
	
	self.cropsinfor_gongji_type	= self:Child("cropsinfor-gongji-type");
	self.cropsinfor_shecheng_type	= self:Child("cropsinfor-shecheng-type");
	self.cropsinfor_yidongli_type	= self:Child("cropsinfor-yidongli-type");
	
	self.cropsinfor_rangetype = LORD.toStaticImage(self:Child("cropsinfor-rangetype"));
	self.cropsinfor_atktype = LORD.toStaticImage(self:Child("cropsinfor-atktype"));
	self.cropsinfor_movetype = LORD.toStaticImage(self:Child("cropsinfor-movetype"));
	self.cropsinfor_own = LORD.toStaticImage(self:Child("cropsinfor-own"));

 
	function oncropsinfor_patchTouchDown()	
		eventManager.dispatchEvent({name = global_event.ITEMACQUIRE_SHOW,_type = "crops",selId = self._cardType })	
	end	
	
	self.cropsinfor_patch_get = self:Child( "cropsinfor-patch-get" );
 	self.cropsinfor_patch_get:subscribeEvent("ButtonClick", "oncropsinfor_patchTouchDown")
	
	self.cropsinfor_patch = self:Child( "cropsinfor-patch" );
 	self.cropsinfor_patch:subscribeEvent("WindowTouchUp", "oncropsinfor_patchTouchDown")
	
	self.cropsinfor_changebutton = self:Child( "cropsinfor-model-changebutton" );
 	self.cropsinfor_changebutton:subscribeEvent("ButtonClick", "oncropsinfor_cropsinfor_changebuttonTouchDown")
	
	function oncropsinfor_cropsinfor_changebuttonTouchDown()
			self:updateInfo(self._cardType,true);
	end	
	
	
	self.cropsinfor_skill_item = {};
	self.cropsinfor_skill_text = {};
	self.cropsinfor_skill_infor = {};
	self.cropsinfor_skill = {};
	self.cropsinfor_skill_dw = {};
	for i=1, 3 do
		self.cropsinfor_skill_item[i] = LORD.toStaticImage(self:Child( "cropsinfor-skill"..i.."-item" ));
		self.cropsinfor_skill_text[i] = self:Child( "cropsinfor-skill"..i.."-text" );
		self.cropsinfor_skill_infor[i] = self:Child( "cropsinfor-skill"..i.."-infor" );
		self.cropsinfor_skill[i] = self:Child("cropsinfor-skill"..i);
	 
		self.cropsinfor_skill_dw[i] = self:Child("cropsinfor-skill"..i.."-dw");
		global.onSkillTipsShow(self.cropsinfor_skill_item[i], "skill", "top");
		global.onTipsHide(self.cropsinfor_skill_item[i]);
	end
	
	self.cropsinfor_star = {};
	
	for i=1, 5 do
		self.cropsinfor_star[i] = self:Child("cropsinfor-star"..i);
	end
	
	self.cropsinfor_close = self:Child( "cropsinfor-close" );
	self.cropsinfor_close:subscribeEvent("ButtonClick", "onClickCropsInfoClose");
	
	self.corpsbag_tab = {};
	self.corpsbag_tab_new = {};
	self.corpsbag_tab_new_n = {};
	self.selectTabFlag = {};
	self.corpsbag_imgUnit = {};
	
	-- 种族映射表
	local raceMap = {
		[1] = 0,
		[2] = 1,
		[3] = 2,
		[4] = 3,
	};
	
	for i=1, 4 do
		self.corpsbag_tab[i] = LORD.toRadioButton(self:Child( "cropsinfor-tab"..i ));
		self.corpsbag_tab[i]:SetUserData(raceMap[i]);
		self.corpsbag_tab[i]:subscribeEvent("RadioStateChanged", "onSelectRace");
		self.corpsbag_tab_new[i] = self:Child("cropsinfor-tab"..i.."-new");
		--self.corpsbag_tab_new_n[i] = self:Child("cropsinfor-tab"..i.."-new-n");
		local count = cardData.getNewGainedCountByRace(raceMap[i]);
		self.corpsbag_tab_new[i]:SetVisible(count > 0);
		--self.corpsbag_tab_new_n[i]:SetText(count);
		self.selectTabFlag[raceMap[i]] = false;
		self.corpsbag_imgUnit[raceMap[i]] = self:Child("cropsinfor-tab"..i.."-textimage_n");
		self.corpsbag_imgUnit[raceMap[i]]:SetVisible(false)	 
	end
	
	self.corpsbag_scroll = LORD.toScrollPane(self:Child( "cropsinfor-tab-scroll" ));
	self.corpsbag_scroll:init();
	
 	function onSelectRace(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		if window:IsSelected() then
			local race = window:GetUserData();
			self.selectTabFlag[race] = true;
			self:onUpdateRace(race);
			local index = table.keyOfItem(raceMap,race)	
			if(self.corpsbag_tab_new[index] )then
				self.corpsbag_tab_new[index]:SetVisible(false)	
			end
		end
	end
	
	function onClickCorpsBagUnit(args)
		local window = LORD.toWindowEventArgs(args).window;
		local id = window:GetUserData();
		self._cardType = id
		self.chageStatus  = nil
		self:updateInfo(id);
		
		local cardInstance = cardData.getCardInstance(id);
		if cardInstance then
			cardData.playVoiceByUnitID(cardInstance:getUnitID());
		end
		
	end
	
	self.corpsbag_tab[1]:SetSelected(true);
	self._cardType = event.displayCardType or self._cardType
	self:updateInfo(self._cardType);
  
end



function cropsinfor:onUpdateRace(race)
	
	
	for i, v in pairs (self.corpsbag_imgUnit) do
		v:SetVisible(false)	 
	end
	
	self.corpsbag_imgUnit[race]:SetVisible(true)
		 
	self.corpsbag_scroll:ClearAllItem();
	self.corpsbag_scroll:InitializePos();
	local scrollPanelSize = self.corpsbag_scroll:GetPixelSize();
	
	local index = 1;
	local xPosition = LORD.UDim(0, -10);
	local yPosition = LORD.UDim(0,-10);
	self.selUnitWnd = {}
	for k,v in ipairs(cardData.cardlist) do
		
		if race == dataConfig.configs.unitConfig[v.cardType].race or race < 0 then
						
			local item = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("cropsinfor-"..index, "shipitem.dlg");

			item:SetXPosition(xPosition);
			item:SetYPosition(yPosition);				
			self.corpsbag_scroll:additem(item);
			
			local icon = LORD.toStaticImage(self:Child("cropsinfor-"..index.."_shipitem-head"));
			local shipIcon = LORD.toStaticImage(self:Child("cropsinfor-"..index.."_shipitem-ship"));
			local selectFrame = LORD.toStaticImage(self:Child("cropsinfor-"..index.."_shipitem-chose"));
			local fakeWindow = self:Child("cropsinfor-"..index.."_shipitem-fake");
			local expBar = self:Child("cropsinfor-"..index.."_shipitem-bar-back");
			local expProgress = self:Child("cropsinfor-"..index.."_shipitem-bar");
			local expPorgressText = self:Child("cropsinfor-"..index.."_shipitem-bar-text");
			local newCard = self:Child("cropsinfor-"..index.."_shipitem-new");
			local equity = LORD.toStaticImage(self:Child("cropsinfor-"..index.."_shipitem-equity"));
			local shadow = LORD.toStaticImage(self:Child("cropsinfor-"..index.."_shipitem-shadow"));
			
			local name = self:Child("cropsinfor-"..index.."_shipitem-name");
			name:SetVisible(false);
			
			equity:SetImage(itemManager.getImageWithStar(0));
			
			newCard:SetVisible(v:getNewGainedFlagInBag() > 0);			
		
			-- 接收事件
			fakeWindow:SetVisible(true);
			fakeWindow:subscribeEvent("WindowTouchUp", "onClickCorpsBagUnit");
			
			local starImage = {};
			for i=1, 6 do
				starImage[i] = self:Child("cropsinfor-"..index.."_shipitem-star"..i);
				starImage[i]:SetVisible(false);
			end
			
			local unitInfo = {};
			if v.star > 0 then
				unitInfo = dataConfig.configs.unitConfig[v.unitID];
				
				equity:SetImage(itemManager.getImageWithStar(unitInfo.starLevel));
				
				item:SetEnabled(true);
				icon:SetEnabled(true);
				shadow:SetVisible(false);
				expBar:SetVisible(false);
				
				for i=1, v.star do
					starImage[i]:SetVisible(true);
				end
				
				fakeWindow:SetUserData(v.cardType);
			else
				unitInfo = dataConfig.configs.unitConfig[v.cardType];
				item:SetEnabled(true);
				icon:SetEnabled(true);
				shadow:SetVisible(true);
				
				--fakeWindow:SetVisible(false);
				expBar:SetVisible(true);
				local currentExp = v:getCurrentExp();
				local nextExp = v:getNextExp();
				local percent = currentExp / nextExp;
				expProgress:SetProperty("Progress", percent);
				expPorgressText:SetText(currentExp.."/"..nextExp);
				
				fakeWindow:SetUserData(v.cardType);
			end
			self._cardType = self._cardType or v.cardType
			icon:SetImage(unitInfo.icon);
			shipIcon:SetVisible(false);
			selectFrame:SetVisible(false);
			selectFrame:SetUserData(v.cardType);
			self.selUnitWnd[v.cardType] = selectFrame

			xPosition = xPosition + item:GetWidth()* LORD.UDim(0, 0.7) + LORD.UDim(0, 3);
			local xRightPosition = xPosition + item:GetWidth()* LORD.UDim(0, 0.7);
			if xRightPosition.offset > scrollPanelSize.x then
				xPosition = LORD.UDim(0,-10);
				yPosition = yPosition + item:GetHeight()* LORD.UDim(0, 1)  + LORD.UDim(0, 3);
			end		
			
			index = index + 1;
		end
		
	end
	
end


function cropsinfor:updateInfo(cardType,changeModel)
	
	
	for i,v in pairs(self.selUnitWnd)do
		if(v)then
			v:SetVisible(false);
		end	
	end
	if(self.selUnitWnd[cardType])then
		self.selUnitWnd[cardType]:SetVisible(true);
	end
 
	
	local cardInstance = cardData.getCardInstance(cardType);
	
	local backunitID = cardData.cardlist[cardType].unitID;
	
	local unitID = cardData.cardlist[cardType].unitID;
	local star = cardInstance:getStar()
	local showstar = star  
	
	if(star <=0)then
		showstar = 1
	end	
	
	if(star < 3) then
		star =  3
	else
		star =  1
	end	
	backunitID = cardData.getUnitIDByTypeAndStar(cardType, star) 
 
	if(changeModel)then
		if(self.chageStatus ~= true )then
		  unitID , backunitID = backunitID , unitID
		  showstar = star
		end
		 self.chageStatus  = not self.chageStatus 
	end
	local backunitInfo = dataConfig.configs.unitConfig[backunitID];
	local unitInfo = dataConfig.configs.unitConfig[unitID];
	
	
	self.cropsinfor_own:SetVisible(cardInstance:getStar() <  showstar);
	
	if unitInfo then
		
		self.cropsinfor_name:SetText(unitInfo.name);
		--self.cropsinfor_renkou_num:SetText(unitInfo.food);
		--self.cropsinfor_bingliangnum:SetText(unitInfo.foodRatio);
		
		self.cropsinfor_gongji_num:SetText(unitInfo.soldierDamage);
		self.cropsinfor_fangyu_num:SetText(unitInfo.defence);
		self.cropsinfor_shengming_num:SetText(unitInfo.soldierHP);
		
		self.cropsinfor_sudu_num:SetText(unitInfo.actionSpeed);
		self.cropsinfor_yidongli_num:SetText(unitInfo.moveRange);
		self.cropsinfor_shecheng_num:SetText(unitInfo.attackRange);
		
		local isRange = 0;
		if unitInfo.isRange == true then
			isRange = 1;
		end
			
		self.cropsinfor_rangetype:SetImage(enum.unitIsRangeImageMap[isRange]);
		self.cropsinfor_atktype:SetImage(enum.unitDamageTypeImageMap[unitInfo.damageType]);
		self.cropsinfor_movetype:SetImage(enum.unitMoveTypeImageMap[unitInfo.moveType]);
	
		local currentExp = cardInstance:getCurrentExp();
		local nextExp = cardInstance:getNextExp();
		local percent = currentExp / nextExp;
		if not cardInstance:isMaxStar() then
			self.cropsinfor_patch_bar_image:SetProperty("Progress", percent);
			self.cropsinfor_patch_text:SetText(currentExp.."/"..nextExp);
		else
			self.cropsinfor_patch_bar_image:SetProperty("Progress", 1.0);
			self.cropsinfor_patch_text:SetText("已满级");		
		end
	
		for i=1, 3 do
			if unitInfo.skill[i] then
				self.cropsinfor_skill[i]:SetVisible(true);
				self.cropsinfor_skill_dw[i]:SetVisible(true);
				local skillInfo = dataConfig.configs.skillConfig[unitInfo.skill[i]];
				if skillInfo then
					self.cropsinfor_skill_item[i]:SetImage(skillInfo.icon);
					self.cropsinfor_skill_text[i]:SetText(skillInfo.name);
					self.cropsinfor_skill_item[i]:SetUserData(skillInfo.id);
					self.cropsinfor_skill_infor[i]:SetText(skillInfo.text);
				end
			else
				self.cropsinfor_skill_dw[i]:SetVisible(false);
				self.cropsinfor_skill[i]:SetVisible(false);
				self.cropsinfor_skill_item[i]:SetImage("");
				self.cropsinfor_skill_text[i]:SetText("");
			end
		end
		
		for i=1, 5 do

			self.cropsinfor_star[i]:SetVisible(i <= unitInfo.starLevel);

		end
		
		self.cropsinfor_model1:SetActor(unitInfo.resourceName,"idle");
		
		self.cropsinfor_model1:SetRotateX(10);
		self.cropsinfor_model1:SetRotateY(50);
		self.cropsinfor_model1:SetRotateZ(0);
		
		if(backunitInfo)then
			self.cropsinfor_model2:SetActor(backunitInfo.resourceName,"idle");
		end
		
		-- 1 星 和 4星 的actor
		--local compatableInfo = dataConfig.configs.unitCompatableConfig[cardType];
		--local oneStarUnitID = compatableInfo.starLevel[1];
		--local oneStarUnitInfo = dataConfig.configs.unitConfig[oneStarUnitID];
		
		--local fourStarUnitID = compatableInfo.starLevel[4];
		--local fourStarUnitInfo = dataConfig.configs.unitConfig[fourStarUnitID];

		
		--style 1
		--self.cropsinfor_style1:SetText(enum.unitMoveTypeMap[unitInfo.moveType]);
		local isRange = 0;
		if unitInfo.isRange == true then
			isRange = 1;
		end
		
		--self.cropsinfor_style2:SetText(enum.unitDamageTypeMap[unitInfo.damageType]..enum.unitIsRangeMap[isRange]);

		self.cropsinfor_gongji_type:SetText(enum.unitDamageTypeMap[unitInfo.damageType]);
		self.cropsinfor_shecheng_type:SetText(enum.unitIsRangeMap[isRange]);
		self.cropsinfor_yidongli_type:SetText(enum.unitMoveTypeMap[unitInfo.moveType]);
			
	end
end
function cropsinfor:onHide(event)
	self:Close();
	self._cardType  = nil
	if(self.selectTabFlag)then
		for k,v in pairs(self.selectTabFlag) do
			if v then
				cardData.setNewGainedByRace(k);
			end
		end
	end
	self.selUnitWnd = nil
end
return cropsinfor;
