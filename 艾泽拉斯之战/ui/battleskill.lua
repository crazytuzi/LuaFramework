local battleskill = class( "battleskill", layout );

global_event.BATTLESKILL_SHOW = "BATTLESKILL_SHOW";
global_event.BATTLESKILL_HIDE = "BATTLESKILL_HIDE";

function battleskill:ctor( id )
	battleskill.super.ctor( self, id );
	self:addEvent({ name = global_event.BATTLESKILL_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.BATTLESKILL_HIDE, eventHandler = self.onHide});
end

function battleskill:onShow(event)
	if self._show then
		return;
	end
	self.firstUnSelWinName = nil
		 
	self:Show();

	--self.battleskill_peizhibutton = self:Child( "battleskill-peizhibutton" );
	self.battleskill_huadong = LORD.toScrollPane(self:Child( "battleskill-huadong" ));
	self.battleskill_close = self:Child( "battleskill-close" );
	
	self.battleskill_close:subscribeEvent("ButtonClick", "onClickClose");
	self.battleskill_huadong:init();
	
	self.battleskillitem = {};
	self.battleskillitem_icon = {};
	self.battleskillitem_name = {};
	self.battleskillitem_xuanzhong = {};
	self.battleskillitem_star = {};
	self.battleskill_skillitem_item = {};
	self.battleskill_skillitem_name = {};
	self.battleskill_skillitem_num = {};
	self.battleskill_skillitem_time = {};
	self.battleskill_skillitem_xuanzhong = {};
	self.battleskillitem_fake = {};
	self.battleskillitem_tab = {};
	self.battleskill_tab_new_text = {};
	self.battleskill_tab_new = {};
	self.selectNewMagicFlag = {};
	
	local itemSize = LORD.Vector2(0, 0);
	
	for i=1, 7 do
		self.battleskill_skillitem_item[i] = LORD.toStaticImage(self:Child("battleskill-skillitem"..i.."-item"));
		self.battleskill_skillitem_item[i]:SetImage("");
		
		if(i ~= 7)then
		self.battleskill_skillitem_item[i]:subscribeEvent("WindowTouchUp", "onClickRemoveOrDropMagic");
		
		self.battleskill_skillitem_item[i]:setEnableDrag(true);
		self.battleskill_skillitem_item[i]:subscribeEvent("WindowDragStart", "onDragMagic");
		self.battleskill_skillitem_item[i]:subscribeEvent("WindowDragging", "onBattleSkillDraggingMagic");
		self.battleskill_skillitem_item[i]:subscribeEvent("WindowDragEnd", "onBattleSkillDragMagicEnd");
		end

		self.battleskill_skillitem_item[i]:SetProperty("EnableLongTouch", "true");		
		self.battleskill_skillitem_item[i]:subscribeEvent("WindowLongTouch", "onBattleSkillShowPlanTips");
		self.battleskill_skillitem_item[i]:subscribeEvent("WindowLongTouchCancel", "onBattleSkillHidePlanTips");
		self.battleskill_skillitem_item[i]:subscribeEvent("MotionRelease", "onBattleSkillHidePlanTips");
		
		self.battleskill_skillitem_item[i]:SetUserData(i);
		
		self.battleskill_skillitem_name[i] = self:Child("battleskill-skillitem"..i.."-name");
		self.battleskill_skillitem_name[i]:SetText("");
		self.battleskill_skillitem_num[i] = self:Child("battleskill-skillitem"..i.."-num");
		self.battleskill_skillitem_num[i]:SetText("");
		
		self.battleskill_skillitem_time[i] = self:Child("battleskill-skillitem"..i.."-time");
		self.battleskill_skillitem_time[i]:SetText("");
		
		self.battleskill_skillitem_xuanzhong[i] = self:Child("battleskill-skillitem"..i.."-xuanzhong");
		self.battleskill_skillitem_xuanzhong[i]:SetVisible(false);
		
		itemSize = self.battleskill_skillitem_item[i]:GetPixelSize();
	end
	
	-- 筛选的标签
	for i=1, 5 do
		self.battleskillitem_tab[i] = LORD.toRadioButton(self:Child("battleskill-tab"..i));
		-- 类型
		self.battleskillitem_tab[i]:SetUserData(i-2);
		self.battleskillitem_tab[i]:subscribeEvent("RadioStateChanged", "onMagicTabChange");
		
		if i == 1 then
			self.battleskill_tab_new_text[i] = false;
			self.battleskill_tab_new[i] = false;
		else
			self.battleskill_tab_new_text[i] = self:Child("battleskill-tab"..i.."-new-text");
			self.battleskill_tab_new[i] = self:Child("battleskill-tab"..i.."-new");
			
			local count = dataManager.kingMagic:getNewGainedMagicCountByType(i-2);
			self.battleskill_tab_new[i]:SetVisible(count > 0 );
			self.battleskill_tab_new_text[i]:SetText(count);		
		end
		
		self.selectNewMagicFlag[i-2] = false;
	end
	
	self.saveConfig = {};
	
	self.saveConfig = self:getSaveConfig();
	
	if self.saveConfig.selectTab == nil then
		self.saveConfig.selectTab = 1;
	end
	
	if self.saveConfig.vertScrollPos == nil then
		self.saveConfig.vertScrollPos = 0;
	end
	
	-- 创建一个拖拽的window
	self.draggingWindow = (LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("battleskill", "dragmagic.dlg"));
	engine.uiRoot:AddChildWindow(self.draggingWindow);
	self.draggingWindow:SetVisible(false);
		
	function onClickClose()
		self:onHide();
	end
	
	function onMagicTabChange(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		local userdata =  window:GetUserData();
		if window:IsSelected() then
			self.saveConfig.selectTab = userdata + 2;
			self:initAllMagicInfo(userdata);
			--window:SetProperty("BtnTextColor", "0 0 0 1");
			self.selectNewMagicFlag[userdata] = true;
			
			if(self.battleskill_tab_new[self.saveConfig.selectTab]) then
				self.battleskill_tab_new[self.saveConfig.selectTab]:SetVisible(false);	
			end
			
			for i=1, 5 do
				
				local normal = self:Child("battleskill-tab"..i.."-text");
				local choose = self:Child("battleskill-tab"..i.."-text-chose");
				
				normal:SetVisible(self.saveConfig.selectTab ~= i);
				choose:SetVisible(self.saveConfig.selectTab == i);
				
			end
			
		else
			--window:SetProperty("BtnTextColor", "0.152941 0.372471 0.592157 1");
		end
	end
	
	function onShowMagicTips(args)
		local window = LORD.toWindowEventArgs(args).window;
		local userdata =  window:GetUserData();
		local rect = window:GetUnclippedOuterRect();
		local magicInstance = dataManager.kingMagic:getMagic(userdata);
		
 		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "magic", id = userdata, windowRect = rect, dir = "free",
 																magicLevel = magicInstance:getStar(), intelligence = dataManager.playerData:getIntelligence()});
	end
		
	function onHideMagicTips(args)
		local window = LORD.toWindowEventArgs(args).window;
		local id =  window:GetUserData();
		
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
	
	function onClickMagic(args)
		local window = LORD.toWindowEventArgs(args).window;
		local id =  window:GetUserData();
		self:onMagic(id);

		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
	
	function onClickFakeMagic(args)
		local window = LORD.toWindowEventArgs(args).window;
		local id =  window:GetUserData();
		self:onFakeMagic(id);
		
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
	
	function onClickRemoveOrDropMagic(args)
		local window = LORD.toWindowEventArgs(args).window;
		local index =  window:GetUserData();
		
		if self.draggingMagicIndex > 0 then
			self:onDropDragMagic(index);
		else
			self:onRemoveMagic(index);		
		end

	end
	
	function onDragMagic(args)
		local window = LORD.toWindowEventArgs(args).window;
		local touchpos = LORD.toMouseEventArgs(args).position;
		local index =  window:GetUserData();
		self:onStartDragMagic(touchpos, index);
	end
	
	-- dragging
	function onBattleSkillDraggingMagic(args)
		local window = LORD.toWindowEventArgs(args).window;
		local touchpos = LORD.toMouseEventArgs(args).position;
		local moveDelta = LORD.toMouseEventArgs(args).moveDelta;
		local index =  window:GetUserData();
		
		local position = self.draggingWindow:GetPosition();
		position.x = position.x + LORD.UDim(0, moveDelta.x);
		position.y = position.y + LORD.UDim(0, moveDelta.y);
		self.draggingWindow:SetPosition(position);
	end
	
	function onBattleSkillDragMagicEnd(args)
		self.draggingMagicIndex = -1;
		if self.draggingWindow then
			self.draggingWindow:SetVisible(false);
		end
	end
	
	-- 快捷栏上的tips
	function onBattleSkillShowPlanTips(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local index =  window:GetUserData();

		local magicID = getEquipedMagicData(index).id;
		print("magicID "..magicID);
		if magicID > 0 then
			local magicInstance = dataManager.kingMagic:getMagic(magicID);
			local rect = window:GetUnclippedOuterRect();
 			eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "magic", id = magicID, windowRect = rect, dir = "top",
 																	magicLevel = magicInstance:getStar(), intelligence = dataManager.playerData:getIntelligence()});		
		end
	end

	function onBattleSkillHidePlanTips(args)
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
		
	self:updateMagic();
	--self:initAllMagicInfo(-1);
	self.battleskillitem_tab[self.saveConfig.selectTab]:SetSelected(true);
	self.battleskill_huadong:SetVertScrollOffset(self.saveConfig.vertScrollPos);
	--dump(self.battleskill_huadong);
	self.draggingMagicIndex = -1;

	eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_BATTLESKILL})
end

function battleskill:onHide(event)
	
	if not self._show then
		return;
	end
	
	self.firstUnSelWinName = nil
	self.draggingWindow:SetVisible(false);
	LORD.GUIWindowManager:Instance():DestroyGUIWindow(self.draggingWindow);
	self.draggingWindow = nil;
	
	--保存配置信息
	--dump(self.battleskill_huadong);
	self.saveConfig.vertScrollPos = self.battleskill_huadong:GetVertScrollOffset();	
	self:setSaveConfig(self.saveConfig);
	
	self:Close();
	
	self.battleskill_huadong = nil;
		
	--dump(self.selectNewMagicFlag);
	
	for k,v in pairs(self.selectNewMagicFlag) do
		if v then
			--print("setNewGainedMagicByType "..k);
			dataManager.kingMagic:setNewGainedMagicByType(k);
		end
	end
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_CLOSE_BATTLESKILL})
	
	
		 
	self.saveConfig.selectTab = nil
	self.saveConfig.vertScrollPos = nil
end

function battleskill:onMagic(id)
	local equipedIndex = getMagicEquipedIndex(id);
	if equipedIndex >0 then
		return;
	end
	
	-- 找个空的
	local pos = 0
	for i=1, 7 do
		local magicID = getEquipedMagicData(i).id;
		if magicID <= 0 then
			setEquipedMagicData(i, id);
			self:updateMagic();
			self:updateMagicState();
			pos = i
			break;
		end
	end
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_BATTLESKILL_CLICK,arg1 = pos });
 
	eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_UPDATE_MAGIC });

end

function battleskill:onFakeMagic(id)

	local equipedIndex = getMagicEquipedIndex(id);
	self:onRemoveMagic(equipedIndex);
	
end

function battleskill:onStartDragMagic(touchpos, index)	
	local magicID = getEquipedMagicData(index).id;
	local magicInfo = dataConfig.configs.magicConfig[magicID];
	if magicID > 0 and magicInfo and magicInfo.icon then
		self.draggingMagicIndex = index;

		LORD.toStaticImage(self:Child("battleskill_dragmagic-item-item")):SetImage(magicInfo.icon);
		--[[local cost = dataManager.kingMagic:getMagic(magicID):getMpCost();
		self:Child("battleskill_dragmagic-item-num"):SetText(tostring(cost));

		if magicInfo.castTimes < 0 then
			self:Child("battleskill_dragmagic-item-time"):SetText("∞");
		else
			self:Child("battleskill_dragmagic-item-time"):SetText("X"..magicInfo.castTimes);
		end--]]
					
		local pixelsize = self.draggingWindow:GetPixelSize();
		self.draggingWindow:SetVisible(true);
		self.draggingWindow:SetPosition(LORD.UVector2(LORD.UDim(0, touchpos.x-pixelsize.x/2), LORD.UDim(0, touchpos.y-pixelsize.y/2)));
	end
end

function battleskill:onDropDragMagic(index)
	
	local dropMagicID = getEquipedMagicData(index).id;
	local draggingMagicID = getEquipedMagicData(self.draggingMagicIndex).id;
	if dropMagicID > 0 then
		-- 交换
		setEquipedMagicData(self.draggingMagicIndex, dropMagicID);
		setEquipedMagicData(index, draggingMagicID);
	else
		-- 直接放上
		setEquipedMagicData(index, draggingMagicID);
		setEquipedMagicData(self.draggingMagicIndex, -1);
	end
	
	self:updateMagic();
	self:updateMagicState();
	
	self.draggingMagicIndex = -1;
	self.draggingWindow:SetVisible(false);
	
	eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_UPDATE_MAGIC });
end

function battleskill:onRemoveMagic(index)
	
	if index == 7 then
		return;
	end
	
	local magicID = getEquipedMagicData(index).id;

	if magicID > 0 then
		setEquipedMagicData(index, 0);
		self:updateMagic();
		self:updateMagicState();
	end
	
	eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_UPDATE_MAGIC });
end

function battleskill:updateMagic()
	for i=1, 7 do
		local magicID = getEquipedMagicData(i).id;
		if magicID > 0 then
			local magicInfo = dataConfig.configs.magicConfig[magicID];
			if magicInfo then
				local cost = dataManager.kingMagic:getMagic(magicID):getMpCost()
				self.battleskill_skillitem_item[i]:SetImage(magicInfo.icon);
				self.battleskill_skillitem_name[i]:SetText(magicInfo.name);
				self.battleskill_skillitem_num[i]:SetText(cost);
				
				if magicInfo.castTimes < 0 then
					self.battleskill_skillitem_time[i]:SetText("∞");
				else
					self.battleskill_skillitem_time[i]:SetText("X"..magicInfo.castTimes);
				end
				
			end
		else
				self.battleskill_skillitem_item[i]:SetImage("");
				self.battleskill_skillitem_name[i]:SetText("");
				self.battleskill_skillitem_num[i]:SetText("");
				self.battleskill_skillitem_time[i]:SetText("");
		end
	end
end

function battleskill:addMagicItem(index, xPos, yPos,wNameIndex)
	local k = index;
	local v = dataConfig.configs.magicConfig[k];
	local magicInstance = dataManager.kingMagic:getMagic(v.id);
	
	local equipedIndex = getMagicEquipedIndex(v.id);
	local isMagicEquip = equipedIndex > 0;
		
	self.battleskillitem[k] = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("battleskill_"..wNameIndex, "battleskillitem.dlg");
	self.battleskillitem[k]:SetXPosition(xPos);
	self.battleskillitem[k]:SetYPosition(yPos);
	self.battleskill_huadong:additem(self.battleskillitem[k]);
	
	local battleskillitem_equity = LORD.toStaticImage(self:Child("battleskill_"..wNameIndex.."_battleskillitem-equity"));
	battleskillitem_equity:SetImage(itemManager.getImageWithStar(magicInstance:getStar()));
	
	self.battleskillitem_icon[k] = LORD.toStaticImage(self:Child("battleskill_"..wNameIndex.."_battleskillitem-item"));
	self.battleskillitem_icon[k].back = LORD.toStaticImage(self:Child("battleskill_"..wNameIndex.."_battleskillitem-back"));
	self.battleskillitem_icon[k]:SetImage(v.icon);
	self.battleskillitem_icon[k]:SetUserData(k);
	self.battleskillitem_fake[k] = self:Child("battleskill_"..wNameIndex.."_battleskillitem-fake");
	self.battleskillitem_fake[k]:SetUserData(k);
	
	self.battleskillitem_icon[k]:SetProperty("EnableLongTouch", "true");		
	self.battleskillitem_fake[k]:SetProperty("EnableLongTouch", "true");
	
	self.battleskillitem_icon[k]:subscribeEvent("WindowTouchUp", "onClickMagic");	
	self.battleskillitem_fake[k]:subscribeEvent("WindowTouchUp", "onClickFakeMagic");
	self.battleskillitem_icon[k]:subscribeEvent("WindowLongTouch", "onShowMagicTips");
	self.battleskillitem_fake[k]:subscribeEvent("WindowLongTouch", "onShowMagicTips");
	self.battleskillitem_icon[k]:subscribeEvent("MotionRelease", "onHideMagicTips");
	self.battleskillitem_fake[k]:subscribeEvent("MotionRelease", "onHideMagicTips");
	self.battleskillitem_icon[k]:subscribeEvent("WindowLongTouchCancel", "onHideMagicTips");
	self.battleskillitem_fake[k]:subscribeEvent("WindowLongTouchCancel", "onHideMagicTips");	
	-- 因为关闭的事件还要处理别的事情所以不用通用接口
	--global.onSkillTipsShow(self.battleskillitem_icon[k], "magic", "bottom");
	--global.onSkillTipsShow(self.battleskillitem_fake[k], "magic", "bottom");
	
	self.battleskillitem_name[k] = self:Child("battleskill_"..wNameIndex.."_battleskillitem-name");
	self.battleskillitem_name[k]:SetText(v.name);
	self.battleskillitem_xuanzhong[k] = LORD.toStaticImage(self:Child("battleskill_"..wNameIndex.."_battleskillitem-xuanzhong"));
	
	local newFlag = self:Child("battleskill_"..wNameIndex.."_battleskillitem-new");
	if newFlag then
		newFlag:SetVisible(magicInstance:getNewGainedFlag() > 0);
	end
	
	-- 根据是否装备了来显示位置
	
	if isMagicEquip then
		-- 已经装备了
		self.battleskillitem_icon[k]:SetEnabled(false);
		self.battleskillitem_fake[k]:SetVisible(true);
		self.battleskillitem_xuanzhong[k]:SetVisible(true);
	else
		self.battleskillitem_icon[k]:SetEnabled(true);
		self.battleskillitem_fake[k]:SetVisible(false);
		self.battleskillitem_xuanzhong[k]:SetVisible(false);
		
		if(self.firstUnSelWinName == nil)then
			self.firstUnSelWinName = 	self.battleskillitem_icon[k].back:GetName();
		end
		
	end
	
	-- 星级显示,根据魔法等级
	self.battleskillitem_star[k] = {};
	for i=1, 5 do
		self.battleskillitem_star[k][i] = self:Child("battleskill_"..wNameIndex.."_battleskillitem1-star"..i);
		if i <= magicInstance:getStar() then
			self.battleskillitem_star[k][i]:SetVisible(true);
		else
			self.battleskillitem_star[k][i]:SetVisible(false);
		end
		
	end			
end

function battleskill:initAllMagicInfo(magicType)

	self.battleskillitem = {};
	self.battleskillitem_icon = {};
	self.battleskillitem_name = {};
	self.battleskillitem_xuanzhong = {};
	self.battleskillitem_star = {};
		
	self.battleskill_huadong:ClearAllItem();
	self.battleskill_huadong:InitializePos();
	
	local xEdge = LORD.UDim(0, 15);
	local yEdge = LORD.UDim(0, 20);
	
	local xPos = LORD.UDim(0, xEdge.offset);
	local yPos = LORD.UDim(0, yEdge.offset);
	
	local scrollPanelSize = self.battleskill_huadong:GetPixelSize();
	local wNameIndex = 1
	if battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED then
	-- 首先是大力魔法
		local greatMagic = dataManager.kingMagic:getGreatMagic();
		
		local itemHeight = nil;
		for k,v in ipairs(greatMagic) do
		
			local magicInstance = dataManager.kingMagic:getMagic(v);
			local config = dataConfig.configs.magicConfig[v];
			
			if magicInstance and magicInstance:getExp() > 0 and (magicType < 0 or magicType == config.magicLabel) then
				self:addMagicItem(v, xPos, yPos,wNameIndex);
				wNameIndex = wNameIndex + 1
				xPos = xPos + xEdge + self.battleskillitem[v]:GetWidth();
				
				itemHeight = self.battleskillitem[v]:GetHeight();
				
				local xRightPosition = xPos + self.battleskillitem[v]:GetWidth();
				if xRightPosition.offset > scrollPanelSize.x then
					-- 行尾
					xPos = xEdge;
					yPos = yPos + yEdge + self.battleskillitem[v]:GetHeight();
				end			
			end
		end
		
		if itemHeight then
			-- 换行
			xPos = xEdge;
			yPos = yPos + yEdge + itemHeight;
		end
	end
	
	-- 星级排序

	--for k,v in ipairs(dataConfig.configs.magicConfig) do
	for key, value in ipairs(dataManager.kingMagic:getSortMagicIDList()) do
		
		-- k是魔法id， v是表格data
		local k = value.magicID;
		local v = dataConfig.configs.magicConfig[k];
		local magicInstance = dataManager.kingMagic:getMagic(v.id);
		
		if (not dataManager.kingMagic:isGreatMagic(v.id)) and v.id ~= 1 and magicInstance and magicInstance:getExp() > 0 and (magicType < 0 or magicType == v.magicLabel ) then
			
			--print("addMagicItem "..v.id);
			self:addMagicItem(k, xPos, yPos,wNameIndex);
			wNameIndex = wNameIndex + 1
			xPos = xPos + xEdge + self.battleskillitem[k]:GetWidth();
			
			local xRightPosition = xPos + self.battleskillitem[k]:GetWidth();
			if xRightPosition.offset > scrollPanelSize.x then
				-- 行尾
				xPos = xEdge;
				yPos = yPos + yEdge + self.battleskillitem[k]:GetHeight();
			end
		end
	end
end

function battleskill:updateMagicState()

	self.firstUnSelWinName = nil

	for k,v in ipairs(dataConfig.configs.magicConfig) do
		
		local magicInstance = dataManager.kingMagic:getMagic(v.id);
		local equipedIndex = getMagicEquipedIndex(v.id);

		if magicInstance and magicInstance:getExp() > 0 and self.battleskillitem_icon[k] and self.battleskillitem_fake[k] then
		
			if equipedIndex >0 then
				-- 已经装备了
				self.battleskillitem_icon[k]:SetEnabled(false);
				self.battleskillitem_fake[k]:SetVisible(true);
				self.battleskillitem_xuanzhong[k]:SetVisible(true);
			else
				self.battleskillitem_icon[k]:SetEnabled(true);
				self.battleskillitem_fake[k]:SetVisible(false);
				self.battleskillitem_xuanzhong[k]:SetVisible(false);
				
				if(self.firstUnSelWinName == nil)then
					self.firstUnSelWinName = 	self.battleskillitem_icon[k].back:GetName();
				end
			end

		end
	end
end

function battleskill:getfirstUnSelWinNameIndex()
	return self.firstUnSelWinName 
end

 

return battleskill;
