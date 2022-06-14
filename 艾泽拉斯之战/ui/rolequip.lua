--wz

local  rolequip= class("rolequip",layout)

global_event.ROLE_EQUIP_SHIP_UPDATE = "ROLE_EQUIP_SHIP_UPDATE";
global_event.ROLE_EQUIP_CLOSE = "ROLE_EQUIP_CLOSE";
global_event.ROLE_EQUIP_LEVELUP_OK = "ROLE_EQUIP_LEVELUP_OK";
global_event.ROLE_EQUIP_REMOULD_OK = "ROLE_EQUIP_REMOULD_OK";
global_event.ROLE_EQUIP_ENHANCE_RESULT = "ROLE_EQUIP_ENHANCE_RESULT";



	local rolequip_levellimit = {
		[enum.EQUIP_PART.EQUIP_PART_WEAPON] = 1,
		[enum.EQUIP_PART.EQUIP_PART_GLOVE] = 16,
		[enum.EQUIP_PART.EQUIP_PART_BREASTPLATE] = 1,
		[enum.EQUIP_PART.EQUIP_PART_LEGGINGS] = 16,
		[enum.EQUIP_PART.EQUIP_PART_HELMENT] = 22,
		[enum.EQUIP_PART.EQUIP_PART_SHOES] = 28,
	};
	
	
function rolequip:ctor( id )
	 rolequip.super.ctor(self,id)	
	 self:addEvent({ name = global_event.ROLE_EQUIP_SHOW, eventHandler = self.onSHOW})	
	 self:addEvent({ name = global_event.ROLE_EQUIP_UPDATE, eventHandler = self.onUpdateEquip})
	 self:addEvent({ name = global_event.ROLE_EQUIP_SHIP_UPDATE, eventHandler = self.updateUnitInfo})
	 self:addEvent({ name = global_event.ROLE_EQUIP_CLOSE, eventHandler = self.onHide});
	 self:addEvent({ name = global_event.ROLE_EQUIP_LEVELUP_OK, eventHandler = self.onLevelUpOK});
	 self:addEvent({ name = global_event.ROLE_EQUIP_REMOULD_OK, eventHandler = self.onRemouldOK});
	 self:addEvent({ name = global_event.ROLE_EQUIP_ENHANCE_RESULT, eventHandler = self.onEnhanceResult});
	 self:addEvent({ name = global_event.PLAYER_ATTR_SYNC, eventHandler = self.onUpdateCurrentPageInfo});
	 
end	

 
function rolequip:onSHOW(event)

	self:Show();
	self.ship = event.ship;
	self.event = event;
	
	PLAN_CONFIG.currentPlanType = enum.PLAN_TYPE.PLAN_TYPE_PVE;
	
	-- 装备相关
	-- 当前选中的装备栏类型
	self.currrentSelectEquip = enum.EQUIP_PART.EQUIP_PART_INVALID;
	self.isAutoEnhancing = false;
	self.autoSendTimer = -1;
	
	self.lastEquipInfo = {};
	
	-- init 
	self:init()

	-- 默认初始化军团页
	self:onSelectShip();
		
	scheduler.performWithDelayGlobal(function ()
				eventManager.dispatchEvent( {name = global_event.GUIDE_ON_ENTER_ROLE_RQUIP})
				eventManager.dispatchEvent( {name = global_event.GUIDE_ON_ENTER_SHIP})
	end, 0.1);
 
	
	
	

end

function rolequip:init()
	
	function onClickRoleequipBack()
		self:updateUnitInfo();
		self:showPage(self.rolequip_infor);
	end
	
	-- 切换页的按钮	
	function onRoleEquipStrengthen()
	
		local equipPart = self.currrentSelectEquip or enum.EQUIP_PART.EQUIP_PART_WEAPON;
		
		-- 默认选中第一件装备，没有的话，就选中空的
		
		
		local itemInstance = dataManager.bagData:getItem(equipPart, self.ship)
		
		if(itemInstance == nil  ) then
			for i = enum.EQUIP_PART.EQUIP_PART_WEAPON, enum.EQUIP_PART.EQUIP_PART_COUNT -1 do
				
				local itemInstance = dataManager.bagData:getItem(i, self.ship);
				if itemInstance and itemInstance:isEquip() then
					equipPart = i;
					break;
				end
					
			end
		end
		
		self:showPage(self.rolequip_strengthen);
		self:onSelectStrengthenEquip(equipPart);
		--触发引导
		eventManager.dispatchEvent( {name = global_event.GUIDE_ON_ENTER_STRENGTHEN})
	end
	
	function onRoleEquipAttr()
		self:updateUnitInfo();
		self:showPage(self.rolequip_infor);
	end
	
	
	-- 新的军团属性信息
	self:initUnitInfoUIWindow();
	
	self.rolequip_infor_corps_head = self:Child("rolequip-infor-corps-head");
	self.rolequip_infor_corps_head:subscribeEvent("ButtonClick", "onClickRoleEquipChangeUnit");
	
	self.rolequip_attri_button = self:Child("rolequip-attri-button");
	self.rolequip_attri_button:subscribeEvent("ButtonClick", "onRoleEquipAttr");
	
	self.rolequip_strengthen_button = self:Child("rolequip-strengthen-button");
	self.rolequip_strengthen_button:subscribeEvent("ButtonClick", "onRoleEquipStrengthen");
	
	self.rolequip_strengthen_percent_num = self:Child("rolequip-strengthen-percent-num");
	self.rolequip_strengthen_tips = self:Child("rolequip-strengthen-tips");
	
	self.rolequip_bag_from = self:Child("rolequip-bag-from");
	
	function onRoleEquipBagFrom(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()			
		if(userdata ~= -1)then
			eventManager.dispatchEvent({name = global_event.ITEMACQUIRE_SHOW,_type = "item",selId = userdata })	
		end
		
	end	
	
	self.rolequip_bag_from:subscribeEvent("ButtonClick", "onRoleEquipBagFrom");
	self.rolequip_bag_from:SetVisible(false)	
	
	--一键最强
	function onRoleEquipOneKeyEquip()
		self:onOneKeyEquip();
	end
	
	self.rolequip_most_equip = self:Child("rolequip-most-equip");
	self.rolequip_most_equip:subscribeEvent("ButtonClick", "onRoleEquipOneKeyEquip");
	
	-- 特效界面
	self.rolequip_levelupEffect = self:Child("rolequip-levelupEffect");
	
	self.rolequip_classupEffect = self:Child("rolequip-classupEffect");
	
	-- 背景空界面
	self.rolequipBlackBack = self:Child("rolequip");
	self.rolequipBlackBack:subscribeEvent("WindowTouchUp", "onClickRoleequipBack");
	-- 装备界面
	
	self.rolequip_bag = self:Child("rolequip-bag");
	self.rolequip_bag:SetUserData(2);
	
	function onClickCloseRolEquip()	
		self:onHide()
	end	

	self.rolequip_close = self:Child("rolequip-close")	
	self.rolequip_close:subscribeEvent("ButtonClick", "onClickCloseRolEquip")

		
	self.rolequip_bag_huadong =  LORD.toScrollPane (self:Child("rolequip-bag-huadong"))	
	self.rolequip_bag_huadong:init();
	
	self.equip = {}	
	self.equip[enum.EQUIP_PART.EQUIP_PART_WEAPON] ={ star = LORD.toStaticImage(self:Child("rolequip-wuqi")),icon = LORD.toStaticImage(self:Child("rolequip-wuqi-tubiao")),  exp =  self:Child("rolequip-wuqi-qianghua") }
	self.equip[enum.EQUIP_PART.EQUIP_PART_GLOVE]  ={ star = LORD.toStaticImage(self:Child("rolequip-shoutao")),icon = LORD.toStaticImage(self:Child("rolequip-shoutao-tubiao")),  exp =  self:Child("rolequip-shoutao-qianghua") }
	self.equip[enum.EQUIP_PART.EQUIP_PART_BREASTPLATE]  ={ star = LORD.toStaticImage(self:Child("rolequip-shangyi")),icon = LORD.toStaticImage(self:Child("rolequip-shangyi-tubiao")),  exp =  self:Child("rolequip-shangyi-qianghua") }
	self.equip[enum.EQUIP_PART.EQUIP_PART_LEGGINGS]  ={ star = LORD.toStaticImage(self:Child("rolequip-kuzi")),icon = LORD.toStaticImage(self:Child("rolequip-kuzi-tubiao")),  exp =  self:Child("rolequip-kuzi-qianghua") }
	self.equip[enum.EQUIP_PART.EQUIP_PART_HELMENT]  ={ star = LORD.toStaticImage(self:Child("rolequip-toukui")), icon = LORD.toStaticImage(self:Child("rolequip-toukui-tubiao")),  exp =  self:Child("rolequip-toukui-qianghua") }	
	self.equip[enum.EQUIP_PART.EQUIP_PART_SHOES]  ={ star = LORD.toStaticImage(self:Child("rolequip-xiezi")),icon = LORD.toStaticImage(self:Child("rolequip-xiezi-tubiao")),  exp =  self:Child("rolequip-xiezi-qianghua") }	
 
 
	
	for i = enum.EQUIP_PART.EQUIP_PART_WEAPON, enum.EQUIP_PART.EQUIP_PART_SHOES  do
		self.equip[i].greenFlag = LORD.toStaticImage(self:Child("rolequip-green"..i))	
		self.equip[i].choose = LORD.toStaticImage(self:Child("rolequip-choose"..i))	
	 	self.equip[i].choose:SetVisible(false)		
	end	
		
	self.select_rolequip_equipname = (self:Child("rolequip-equipname"))	
	self.select_rolequip_equipLevel =  (self:Child("rolequip-bag-xinxi-level-num"))	
	self.rolequip_bag_xinxi_level =  (self:Child("rolequip-bag-xinxi-level"))
	
	self.select_rolequip_gongjilv =  (self:Child("rolequip-gongjilv-num_10"))	
	self.select_rolequip_fangyulv =  (self:Child("rolequip-fangyulv-num_14"))	
	
	
	self.select_rolequip_gongjilv_icon =   (self:Child("rolequip-gongjilv_10"))	
	self.select_rolequip_fangyulv_icon =   (self:Child("rolequip-fangyulv_14"))
	
	self.rolequip_gongjilv_arrow = LORD.toStaticImage(self:Child("rolequip-gongjilv-arrow"));
	self.rolequip_fangyulv_arrow = LORD.toStaticImage(self:Child("rolequip-fangyulv-arrow"));
	self.rolequip_gongjilv_addnum = self:Child("rolequip-gongjilv-addnum");
	self.rolequip_fangyulv_addnum = self:Child("rolequip-fangyulv-addnum");
	
	self.select_rolequip_equipname:SetText("")	
	self.select_rolequip_equipLevel:SetText("")
	self.select_rolequip_gongjilv:SetText("")
	self.select_rolequip_fangyulv:SetText("")
	self.rolequip_bag_xinxi_level:SetVisible(false);
	
	-- 新的事件处理
	-- 装备栏上的点击处理
	function onClickRoleEquipFilter(args)
		
		local clickImage = LORD.toWindowEventArgs(args).window		
 		local userdata = clickImage:GetUserData();
			
		self:onClickEquipInShip(userdata);
		
	end
	
	for i = enum.EQUIP_PART.EQUIP_PART_WEAPON, enum.EQUIP_PART.EQUIP_PART_COUNT-1 do
			--self.equip[i].icon:subscribeEvent("WindowTouchUp", "onClickRoleEquipFilter")
			self.equip[i].icon:SetUserData(i);
			self.equip[i].star:SetUserData(i);
			--self.equip[i].icon.item_chose = self.equip[i].choose;
	end

	-- 信息页
	self.rolequip_infor = self:Child("rolequip-infor");
	self.rolequip_infor:SetUserData(1);
	
	self.rolequip_infor_shipnumber = LORD.toStaticImage(self:Child("rolequip-infor-shipnumber"));
	--self.rolequip_infor_corps_head = LORD.toStaticImage(self:Child("rolequip-infor-corps-head"));
	
	function onClickRoleEquipChangeUnit()

		if shipData.shiplist[self.ship] then
			-- 显示选择上阵的界面
			local cardType = PLAN_CONFIG.getShipCardType(self.ship, enum.PLAN_TYPE.PLAN_TYPE_PVE);
			local cardInstance = cardData.getCardInstance(cardType);
			if cardInstance then
				local race = cardInstance:getConfig().race;
				if self.rolequip_tab[race+1] then
					-- 按照船上的军团种族选中
					self.rolequip_tab[race+1]:SetSelected(false);
					self.rolequip_tab[race+1]:SetSelected(true);
				end
			else
				-- 船上没有卡牌，默认选中第一页
				self.rolequip_tab[1]:SetSelected(false);
				self.rolequip_tab[1]:SetSelected(true);		
			end
		end	
	
		self:showPage(self.rolequip_cropschose);
		
	end
	
	--self.rolequip_infor_corps_head_image = LORD.toStaticImage(self:Child("rolequip-infor-corps-head-image"));
	--self.rolequip_infor_corps_head_image:subscribeEvent("WindowTouchUp", "onClickRoleEquipChangeUnit");
	--self.rolequip_infor_corps_name = self:Child("rolequip-infor-corps-name");
	--self.rolequip_infor_corps_star = {};
	--for i=1, 6 do
	--	self.rolequip_infor_corps_star[i] = LORD.toStaticImage(self:Child("rolequip-infor-corps-star"..i));
	--end
	
	self.rolequip_infor_attlv_num = self:Child("rolequip-infor-attlv-num");
	self.rolequip_infor_deflv_num = self:Child("rolequip-infor-deflv-num");
	self.rolequip_infor_dog_num = self:Child("rolequip-infor-dog-num");
	self.rolequip_infor_ten_num = self:Child("rolequip-infor-ten-num");
	
	--升阶
	function onClickRoleEquipShipRemould()
		--eventManager.dispatchEvent({name = global_event.SHIPREMOULD_SHOW, shipIndex = self.ship});
		self:onShipRemould();
		
	end
	
	self.rolequip_infor_ship_star = self:Child("rolequip-infor-ship-star");
	self.rolequip_infor_ship_star_button = self:Child("rolequip-infor-ship-star-button");
	self.rolequip_infor_ship_star_button:subscribeEvent("ButtonClick", "onClickRoleEquipShipRemould");
	
	--升级
	self.rolequip_infor_ship_lv_num = self:Child("rolequip-infor-ship-lv-num");
	self.rolequip_infor_soldier_num = self:Child("rolequip-infor-soldier-num");
	
	-- 改造相关数据
	self.rolequip_infor_ship_star_num = self:Child("rolequip-infor-ship-star-num");
	self.rolequip_infor_ship_star_add_num = self:Child("rolequip-infor-ship-star-add-num");
	
	function onClickRoleEquipShipLevelUp()
		--eventManager.dispatchEvent({name = global_event.SHIPLEVELUP_SHOW, shipIndex = self.ship});	
		self:onLevelUp();	
	end
	
	self.rolequip_lv_button = self:Child("rolequip-lv-button");
	self.rolequip_lv_button:subscribeEvent("ButtonClick", "onClickRoleEquipShipLevelUp");
	
	-- 下一级
	self.rolequip_infor_lv = self:Child("rolequip-infor-lv");
	self.rolequip_infor_herolv_image = LORD.toStaticImage(self:Child("rolequip-infor-herolv-image"));
	self.rolequip_infor_herolv_num = self:Child("rolequip-infor-herolv-num");
	self.rolequip_infor_money2_num = self:Child("rolequip-infor-money2-num");
	self.rolequip_infor_money1_num = self:Child("rolequip-infor-money1-num");
	
	self.rolequip_infor_item = {};
	self.rolequip_infor_item_item = {};
	self.rolequip_infor_item_num = {};
	self.rolequip_item_back = {};
	
	self.rolequip_infor_ship_lv_add_num = self:Child("rolequip-infor-ship-lv-add-num");
	self.rolequip_actor = LORD.toActorWindow(self:Child("rolequip-actor"));

	function onRoleEquipShipRemouldItem(args)
		local window = (LORD.toWindowEventArgs(args)).window;
		local userdata = window:GetUserData();
		
		--print(userdata);
		if userdata > 0 then
			eventManager.dispatchEvent({name = global_event.ITEMACQUIRE_SHOW,_type = "item",selTableId = userdata, source = self.event.source });
		end
	end
		
	for i=1, 3 do
		self.rolequip_infor_item[i] = LORD.toStaticImage(self:Child("rolequip-infor-item"..i));
		self.rolequip_infor_item_item[i] = LORD.toStaticImage(self:Child("rolequip-infor-item"..i.."-item"));
		self.rolequip_infor_item_num[i] = self:Child("rolequip-infor-item"..i.."-num");
		self.rolequip_infor_item[i]:SetTouchable(false)
		self.rolequip_infor_item_item[i]:subscribeEvent("WindowTouchUp", "onRoleEquipShipRemouldItem");		
		self.rolequip_item_back[i] = self:Child("rolequip-item"..i.."-back");
	end
	
	-- 军团选择页
	self.rolequip_cropschose = LORD.toStaticImage(self:Child("rolequip-cropschose"));
	self.rolequip_cropschose:SetUserData(3);
	local rect = self.rolequip_cropschose:GetUnclippedOuterRect();
	global.tipsPositionX = rect.left;
		
	function onSelectRoleEquipRace(args)
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
		if window:IsSelected() then
			local race = window:GetUserData();
			self:refreshSelectCardUI(race);
			
			-- 刷新文本的颜色
			local textIndex = race + 1;
			for i=1, 4 do
				
				local selectText = self:Child("rolequip-tab"..i.."-textimg-n");
				local textimg = self:Child("rolequip-tab"..i.."-textimg");
				selectText:SetVisible(textIndex == i);
				textimg:SetVisible(textIndex ~= i);
				
				if textIndex == i then
					--self.rolequip_tab_text[i]:SetProperty("TextColor", self.selectTabTextColor);
				else
					--self.rolequip_tab_text[i]:SetProperty("TextColor", self.unselectTabTextColor);
				end
			end
		end		
	end
	
	self.rolequip_tab = {};
	self.rolequip_tab_text = {};
	for i=1, 4 do
		self.rolequip_tab[i] = LORD.toRadioButton(self:Child("rolequip-tab"..i));
		self.rolequip_tab[i]:SetUserData(i-1);
		self.rolequip_tab[i]:subscribeEvent("RadioStateChanged", "onSelectRoleEquipRace");
		
		self.rolequip_tab_text[i] = self:Child("rolequip-tab"..i.."-text");
	end

	--self.selectTabTextColor = "0 0 0 1";
	--self.unselectTabTextColor = "0.145098 0.376471 0.596078 1";
	 
	self.rolequip_scroll = LORD.toScrollPane(self:Child("rolequip-scroll"));
	self.rolequip_scroll:init();
	
	-- ship
	function onRoleEquipShipClick(args)
		local window = LORD.toWindowEventArgs(args).window;
		self.ship = window:GetUserData();
		eventManager.dispatchEvent({name = global_event.GUIDE_ON_ROLEEQUIP_CHANGE_SHIP,arg1 = self.ship })
		self:onSelectShip();		
	end
	
	self.rolequip_ship = {};
	self.rolequip_ship_notice = {};
	self.rolequip_ship_image = {};
	self.rolequip_ship_chose = {};
	self.rolequip_ship_star = {};
	self.rolequip_ship_equity = {};
	
	for i=1, 6 do
		self.rolequip_ship[i] = LORD.toStaticImage(self:Child("rolequip-ship"..i));
		self.rolequip_ship_notice[i] = LORD.toStaticImage(self:Child("rolequip-ship"..i.."-notice"));
		self.rolequip_ship[i]:subscribeEvent("WindowTouchUp", "onRoleEquipShipClick");
		self.rolequip_ship[i]:SetUserData(i);
		self.rolequip_ship_image[i] = LORD.toStaticImage(self:Child("rolequip-ship"..i.."-image"));
		self.rolequip_ship_chose[i] = LORD.toStaticImage(self:Child("rolequip-ship"..i.."-chose"));

		
		self.rolequip_ship[i]:SetEnabled(shipData.getShipInstance(i):isActive());
		self.rolequip_ship_image[i]:SetEnabled(shipData.getShipInstance(i):isActive());
		
		self.rolequip_ship_equity[i] = LORD.toStaticImage(self:Child("rolequip-ship"..i.."-equity"));
		
		self.rolequip_ship_star[i] = {};
		
		for j = 1, 5 do
			self.rolequip_ship_star[i][j] = self:Child("rolequip-ship"..i.."-star"..j);
		end
		
	end

	-- 装备强化页
	self.rolequip_strengthen = self:Child("rolequip-strengthen");
	self.rolequip_strengthen:SetUserData(4);
	self.rolequip_strengthen_item_image = LORD.toStaticImage(self:Child("rolequip-strengthen-item-image"));
	self.rolequip_strengthen_item_equlity = LORD.toStaticImage(self:Child("rolequip-strengthen-item-equlity"));
	self.rolequip_strengthen_item_level = (self:Child("rolequip-toukui-qianghua_3"));
	
	self.rolequip_strengthen_name_text = self:Child("rolequip-strengthen-name-text");
	self.rolequip_strengthen_lv_text = self:Child("rolequip-strengthen-lv-text");
	self.rolequip_strengthen_lv_num = self:Child("rolequip-strengthen-lv-num");
	self.rolequip_strengthen_bar = self:Child("rolequip-strengthen-bar");
	self.rolequip_strengthen_next_text = self:Child("rolequip-strengthen-next-text");
	
	self.rolequip_strengthen_attri1 = self:Child("rolequip-strengthen-attri1");
	self.rolequip_strengthen_attri1_num = self:Child("rolequip-strengthen-attri1-num");
	self.rolequip_strengthen_attri1_sarrow = LORD.toStaticImage(self:Child("rolequip-strengthen-attri1-sarrow"));
	self.rolequip_strengthen_attri1_addnum = self:Child("rolequip-strengthen-attri1-addnum");

	self.rolequip_strengthen_attri2 = self:Child("rolequip-strengthen-attri2");
	self.rolequip_strengthen_attri2_num = self:Child("rolequip-strengthen-attri2-num");
	self.rolequip_strengthen_attri2_sarrow = LORD.toStaticImage(self:Child("rolequip-strengthen-attri2-sarrow"));
	self.rolequip_strengthen_attri2_addnum = self:Child("rolequip-strengthen-attri2-addnum");
	
	self.rolequip_strengthen_attri1_next = self:Child("rolequip-strengthen-attri1-next");
	self.rolequip_strengthen_attri1_next_num = self:Child("rolequip-strengthen-attri1-next-num");
	
	self.rolequip_strengthen_attri2_next = self:Child("rolequip-strengthen-attri2-next");
	self.rolequip_strengthen_attri2_next_num = self:Child("rolequip-strengthen-attri2-next-num");
		
	self.rolequip_strengthen_cost_num = self:Child("rolequip-strengthen-cost-num");
	
	self.rolequip_strengthen_button1 = self:Child("rolequip-strengthen-button1");
	self.rolequip_strengthen_button2 = self:Child("rolequip-strengthen-button2");
	self.rolequip_strengthen_button3 = self:Child("rolequip-strengthen-button3");
	self.rolequip_strengthen_button4 = self:Child("rolequip-strengthen-button4");
	
	function onRoleEquipStrengthenConfirm()
		self:strengthenConfirm();
	end
	
	function onRoleEquipStrengthenConfirmAuto()
		self:strengthenConfirmAuto();
	end
	
	function onRoleEquipStrengthenChangeEquip()
		self:onClickEquipInShip(self.selectItemPos, true);
	end
	
	function onRoleEquipStrengthenCancel()
		self:strengthenCancel();
	end
	
	self.rolequip_strengthen_button1:subscribeEvent("ButtonClick", "onRoleEquipStrengthenConfirm");
	self.rolequip_strengthen_button2:subscribeEvent("ButtonClick", "onRoleEquipStrengthenConfirmAuto");
	self.rolequip_strengthen_button3:subscribeEvent("ButtonClick", "onRoleEquipStrengthenChangeEquip");
	self.rolequip_strengthen_button4:subscribeEvent("ButtonClick", "onRoleEquipStrengthenCancel");
	
	-- 默认先显示信息页
	self.rolequip_cropschose:SetVisible(false);
	self.rolequip_bag:SetVisible(false);
	self.rolequip_infor:SetVisible(true);
	self.rolequip_strengthen:SetVisible(false);
	
	self:updateShipCardHeadIcon();
end

function rolequip:onHide(event)	
	
	if not self._show then
		return;
	end
	
	self:strengthenCancel();
	
	--eventManager.dispatchEvent({name = global_event.MAIN_UI_SHOW});
	global.tipsPositionX = 0;
	
	
	PLAN_CONFIG.sendPlan(enum.PLAN_TYPE.PLAN_TYPE_PVE);
	
	if self.event.source ~= "instance" then
		--homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.SHIP);
		homeland.onCheckUnitChange();
		
	else
		
		local layout = layoutManager.getUI("instanceinfor");
		if layout and layout._view then
			layout._view:SetVisible(true);
		end	
	end
	eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE, })	
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_CLOSE_ROLE_RQUIP})
	
	self:Close();
end

function rolequip:updateUnitInfo()

	if false == self._show then 
		return; 
	end
	
	self:updateShipCardHeadIcon();
			
	local cardType = PLAN_CONFIG.getShipCardType(self.ship, enum.PLAN_TYPE.PLAN_TYPE_PVE);
	local cardInstance = cardData.getCardInstance(cardType);
	
	self.rolequip_infor_shipnumber:SetImage(shipData.shipNumberIcon[self.ship]);

	if cardInstance then
		local configData = cardInstance:getConfig();
		local starCount = cardInstance:getStar();	
		--self.rolequip_infor_corps_head:SetImage(itemManager.getImageWithStar(starCount));
		--self.rolequip_infor_corps_head_image:SetImage(configData.icon);
		--self.rolequip_infor_corps_name:SetText(configData.name);
		
		self.rolequip_actor:SetActor(configData.resourceName, "idle");
		
		
		--for i=1, 6 do
		--	if i <= starCount then
		--		self.rolequip_infor_corps_star[i]:SetVisible(true);
		--	else
		--		self.rolequip_infor_corps_star[i]:SetVisible(false);
		--	end
		--end
	else
		--self.rolequip_infor_corps_head:SetImage(itemManager.getImageWithStar(1));
		--self.rolequip_infor_corps_head_image:SetImage("");
		--self.rolequip_infor_corps_name:SetText("");
		self.rolequip_actor:SetActor("", "");
		
		--for i=1, 6 do
		--	self.rolequip_infor_corps_star[i]:SetVisible(false);
		--end
				
	end
	
	--ship attr
	local shipInstance = shipData.getShipInstance(self.ship);
	
	-- 船的模型
	if self.rolequip_actor and shipInstance then
			--self.rolequip_actor:SetActor(shipInstance:getActorName(), "idle");
			self.rolequip_actor:SetRotateX(20);
			self.rolequip_actor:SetRotateY(35);
	end
	
	if shipInstance then
	
		-- 改造相关数据
		self.rolequip_infor_ship_star_num:SetText(shipInstance:getRemouldLevel());
		
		if shipInstance:isMaxRemouldLevel() then
			self.rolequip_infor_ship_star_button:SetEnabled(false);
			self.rolequip_infor_ship_star_num:SetText("Max");
			self.rolequip_infor_ship_star_add_num:SetText("");
		else
			self.rolequip_infor_ship_star_button:SetEnabled(true);
			if shipInstance:getRemouldConfig(shipInstance:getRemouldLevel()+1) and shipInstance:getRemouldConfig() then
				self.rolequip_infor_ship_star_add_num:SetText("+"..shipInstance:getRemouldConfig(shipInstance:getRemouldLevel()+1).soldier - shipInstance:getRemouldConfig().soldier);
			else
				self.rolequip_infor_ship_star_add_num:SetText("");
			end
		end
	end
	
	if shipInstance and not shipInstance:isMaxLevel() then
		self.rolequip_infor_attlv_num:SetText(shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK));
		self.rolequip_infor_deflv_num:SetText(shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE));
		self.rolequip_infor_dog_num:SetText(shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL));
		self.rolequip_infor_ten_num:SetText(shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE));
				
		if not shipInstance:isEnoughPlayerLevel() then
			self.rolequip_infor_ship_lv_num:SetText(shipInstance:getLevel().."^FF0000   (国王等级不足)");
		else
			self.rolequip_infor_ship_lv_num:SetText(shipInstance:getLevel());
		end
		
		self.rolequip_infor_soldier_num:SetText(shipInstance:getSoldier());
		
		self.rolequip_infor_herolv_image:SetImage(dataManager.playerData:getHeadIconImage());
		
		local needLevel = shipInstance:getConfig().id + 1;
		local redColor = "^FF0000";
		if not shipInstance:isEnoughPlayerLevel() then
			self.rolequip_infor_herolv_num:SetText(redColor..needLevel.."^FF0000   (英雄等级不足)");
			self.rolequip_lv_button:SetEnabled(false);
		else
			self.rolequip_infor_herolv_num:SetText(needLevel);
			self.rolequip_lv_button:SetEnabled(true);
		end

		-- 金币
		local needGold = shipInstance:getConfig().money;
		if not shipInstance:isEnoughGood() then
			self.rolequip_infor_money2_num:SetText(redColor..needGold);
		else
			self.rolequip_infor_money2_num:SetText(needGold);
		end
		
		-- 木材
		local needWood = shipInstance:getConfig().wood;
		if not shipInstance:isEnoughWood() then
			self.rolequip_infor_money1_num:SetText(redColor..needWood);
		else
			self.rolequip_infor_money1_num:SetText(needWood);
		end		
		
		-- 人口
		if self.rolequip_infor_ship_lv_add_num then
			if shipInstance:isMaxLevel() then
				self.rolequip_infor_ship_lv_add_num:SetText("");
			else
				local nextConfig = shipInstance:getConfig(shipInstance:getLevel()+1);
				if nextConfig then
					self.rolequip_infor_ship_lv_add_num:SetText("+"..nextConfig.soldier - shipInstance:getConfig().soldier);
				end
			end
		end
				
		-- 升阶道具
		local needItem = shipInstance:getRemouldConfig().requireItem;
		local needItemCount = shipInstance:getRemouldConfig().retuireItemCount;
		
		for i=1, 3 do
			local itemInfo = itemManager.getConfig(needItem[i]);
			if itemInfo then
				local itemCount = dataManager.bagData:getItemNums(enum.BAG_TYPE.BAG_TYPE_BAG, needItem[i]);
				local needItemCount = needItemCount[i];
				
				self.rolequip_infor_item[i]:SetImage(itemManager.getImageWithStar(itemInfo.star));
				
				self.rolequip_infor_item_item[i]:SetImage(itemInfo.icon);
				if itemCount < needItemCount then
					self.rolequip_infor_item_num[i]:SetText(redColor..itemCount.."/"..needItemCount);
					--self.rolequip_infor_item_item[i]:SetEnabled(false);
				else
					self.rolequip_infor_item_num[i]:SetText(itemCount.."/"..needItemCount);
					--self.rolequip_infor_item_item[i]:SetEnabled(true);
				end
				
				self.rolequip_infor_item_item[i]:SetUserData(needItem[i]);
				global.onItemTipsShow(self.rolequip_infor_item_item[i], enum.REWARD_TYPE.REWARD_TYPE_ITEM, "top");
				global.onItemTipsHide(self.rolequip_infor_item_item[i]);
				
				self.rolequip_item_back[i]:SetVisible(true);
								
			else
				-- 没有道具的隐藏
				self.rolequip_infor_item_num[i]:SetText("");
				self.rolequip_infor_item_item[i]:SetImage("");
				self.rolequip_item_back[i]:SetVisible(false);
			end
		end
		
		self.rolequip_infor_lv:SetVisible(true);
	else
		self.rolequip_infor_lv:SetVisible(false);
	end
	self:updateShipEquipStrongerInfo();
end

-- 展示某一页，军团信息，装备，或者选军团上阵页
function rolequip:showPage(window)

	self:strengthenCancel();
	
	window:SetVisible(true);
	
	--uiaction.turnaround(window, 0);
	
	if self.rolequip_cropschose:IsVisible() and self.rolequip_cropschose:GetUserData() ~= window:GetUserData() then
		--uiaction.turnback(self.rolequip_cropschose, 0);
		self.rolequip_cropschose:SetVisible(false);
	end

	if self.rolequip_bag:IsVisible() and self.rolequip_bag:GetUserData() ~= window:GetUserData() then
		--uiaction.turnback(self.rolequip_bag, 0);
		self.rolequip_bag:SetVisible(false);
		
		-- 隐藏以后要清理数据
		self.currrentSelectEquip = enum.EQUIP_PART.EQUIP_PART_INVALID;
		-- 选中框
		for i = enum.EQUIP_PART.EQUIP_PART_WEAPON, enum.EQUIP_PART.EQUIP_PART_COUNT -1 do
			self.equip[i].choose:SetVisible(i == self.currrentSelectEquip);
		end
			
	end
	
	if self.rolequip_infor:IsVisible() and self.rolequip_infor:GetUserData() ~= window:GetUserData() then
		--uiaction.turnback(self.rolequip_infor, 0);
		self.rolequip_infor:SetVisible(false);
	end
	
	if self.rolequip_strengthen:IsVisible() and self.rolequip_strengthen:GetUserData() ~= window:GetUserData() then
		--uiaction.turnback(self.rolequip_strengthen, 0);				
		self.rolequip_strengthen:SetVisible(false);
	end
	
	if self.rolequip_heroinfo:IsVisible() and self.rolequip_heroinfo:GetUserData() ~= window:GetUserData() then
		self.rolequip_heroinfo:SetVisible(false);
	end
	
end

-- 更新装备栏的信息
function rolequip:updateEquipedInfo()
	
	function onClickRoleEquipLock(args)
		
		local clickImage = LORD.toWindowEventArgs(args).window		
 		local userdata = clickImage:GetUserData(); --equipPart
		if(rolequip_levellimit[userdata])then
			eventManager.dispatchEvent({name  =  global_event.WARNINGHINT_SHOW,tip = "国王等级达到"..rolequip_levellimit[userdata].."级，开启该装备位"})
		end
		
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1.5, 1.5, 1.5), 1, 0);				
		action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
		clickImage:playAction(action);
		clickImage:removeEvent("UIActionEnd");
		
	end
	
	local playerLevel = dataManager.playerData:getLevel();
	
	if(self.ship ~= nil)then	
		local hasStrongEquip = false
		for i = enum.EQUIP_PART.EQUIP_PART_WEAPON, enum.EQUIP_PART.EQUIP_PART_COUNT -1 do
			local item = dataManager.bagData:getItem(i, self.ship);
	 	
			if item then		
				self.equip[i].star:SetImage(item:getImageWithStar())	
				self.equip[i].icon:SetImage(item:getIcon())
				self.equip[i].exp:SetText(item:getEnhanceLevelStr())					
			else
				self.equip[i].icon:SetImage("")
				self.equip[i].star:SetImage("")						
				self.equip[i].exp:SetText("")	
			end				
			
			self.equip[i].icon:removeEvent("WindowTouchUp");
			if playerLevel < rolequip_levellimit[i] then
				self.equip[i].star:SetImage("set:ship.xml image:lock");
				self.equip[i].star:removeEvent("WindowTouchUp");
				self.equip[i].star:subscribeEvent("WindowTouchUp", "onClickRoleEquipLock");
				self.equip[i].star:SetTouchable(true)
				self.equip[i].icon:SetTouchable(false)
			else
				self.equip[i].icon:removeEvent("WindowTouchUp");
				self.equip[i].icon:subscribeEvent("WindowTouchUp", "onClickRoleEquipFilter");
				self.equip[i].star:SetTouchable(false)
				self.equip[i].icon:SetTouchable(true)
			end
			
			self.equip[i].choose:SetVisible(i == self.currrentSelectEquip);
			
			local _hasStrongEquip =  dataManager.bagData:hasEquippedStronger(item, i)
			self.equip[i].greenFlag:SetVisible(_hasStrongEquip);
			
			if(_hasStrongEquip)then
				hasStrongEquip = _hasStrongEquip
			end
		end
		self.hasStrongEquip = hasStrongEquip
	end
	eventManager.dispatchEvent({name = global_event.MAIN_UI_ACTIVITY_STATE})
 
end

-- onSelectShip
function rolequip:onSelectShip()
	
	self:strengthenCancel();
	
	-- 船的选中状态
	for i=1, 6 do
		if i == self.ship then
			self.rolequip_ship_image[i]:SetVisible(true);
			self.rolequip_ship_chose[i]:SetVisible(true);
			self.rolequip_shipnum:SetProperty("ImageName" , "set:ship.xml image:ship"..i.."");
		else
			self.rolequip_ship_image[i]:SetVisible(true);
			self.rolequip_ship_chose[i]:SetVisible(false);		
		end
	end
		
	self:updateUnitInfo();
	self:updateEquipedInfo();
	self:updateShipEquipStrongerInfo();
	
	if not self.rolequip_strengthen:IsVisible() then
		self:showPage(self.rolequip_infor);	
	else
		onRoleEquipStrengthen();
	end
	
end

-- 刷新筛选背包数据
function rolequip:updateEquipBagData()
	
	self.rolequip_bag_huadong:ClearAllItem();
	
	if self.currrentSelectEquip ~= enum.EQUIP_PART.EQUIP_PART_INVALID then

		local xpos = LORD.UDim(0, 0);
		local ypos = LORD.UDim(0, 0);
		
		local __items = dataManager.bagData:getEquipSortListByEquipPoint(self.currrentSelectEquip);
		local itemIndex = 0;
		
		local kingLevel = dataManager.playerData:getLevel();
		
		local currentItemInShip = dataManager.bagData:getItem(self.currrentSelectEquip, self.ship);
		local currentItemAtr1 = 0;
		local currentItemAtr2 = 0;
		
		if currentItemInShip and currentItemInShip:getFirstAttr() then
			if currentItemInShip:getFirstAttr() then
				currentItemAtr1 = currentItemInShip:getFirstAttr().attvalue;
			end
			if currentItemInShip:getSecondAttr() then
				currentItemAtr2 = currentItemInShip:getSecondAttr().attvalue;
			end			
		end
		
		function onClickRoleEquipInBag(args)
			local window = LORD.toWindowEventArgs(args).window;
			uiaction.scale(window, 0.9);
			scheduler.performWithDelayGlobal(function()
			local userdata = window:GetUserData()		
			self:onClickEquipInBag(userdata);
		    end, 0.15)
	 		
		end
		
		nums  = #__items;
		local bagItems = {};
				
		for i=1 , nums  do	
		 	local item = __items[i]
		 	if item then		
				bagItems[i] = {}
			 	bagItems[i].itemWind = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("equip_item"..i, "rolequipitem.dlg");
				bagItems[i].equipitem = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("equip_item"..i.."_rolequipitem-item-qulity"));
				
				--bagItems[i].item_chose = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("equip_item"..i.."_rolequipitem-item"));
				bagItems[i].itemIcon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("equip_item"..i.."_rolequipitem-item-image"));	
				bagItems[i].itemExp = (LORD.GUIWindowManager:Instance():GetGUIWindow("equip_item"..i.."_rolequipitem-Lv-num"));
				--bagItems[i].itemred = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("equip_item"..i.."_equipitem-red"));
			 	bagItems[i].itemName = self:Child("equip_item"..i.."_rolequipitem-name");
			 	
			 	bagItems[i].rolequipitem_attri1 = self:Child("equip_item"..i.."_rolequipitem-attri1");
			 	bagItems[i].rolequipitem_attri1_num = self:Child("equip_item"..i.."_rolequipitem-attri1-num");
			 	bagItems[i].rolequipitem_attri1_sarrow = LORD.toStaticImage(self:Child("equip_item"..i.."_rolequipitem-attri1-sarrow"));
			 	bagItems[i].rolequipitem_attri1_addnum = self:Child("equip_item"..i.."_rolequipitem-attri1-addnum");

			 	bagItems[i].rolequipitem_attri2 = self:Child("equip_item"..i.."_rolequipitem-attri2");
			 	bagItems[i].rolequipitem_attri2_num = self:Child("equip_item"..i.."_rolequipitem-attri2-num");
			 	bagItems[i].rolequipitem_attri2_sarrow = LORD.toStaticImage(self:Child("equip_item"..i.."_rolequipitem-attri2-sarrow"));
			 	bagItems[i].rolequipitem_attri2_addnum = self:Child("equip_item"..i.."_rolequipitem-attri2-addnum");
			 	bagItems[i].rolequipitem_item_dis = self:Child("equip_item"..i.."_rolequipitem-item-dis");
			 	bagItems[i].rolequipitem_strengthen = self:Child("equip_item"..i.."_rolequipitem-strengthen");
			 	
			 				 	
			 	bagItems[i].itemWind:SetPosition(LORD.UVector2(xpos, ypos));
			 	self.rolequip_bag_huadong:additem(bagItems[i].itemWind);
				--bagItems[i].itemIcon.item_chose = bagItems[i].item_chose	
				--bagItems[i].itemIcon.item_chose:SetVisible(false)
								
				ypos = ypos + bagItems[i].itemWind:GetHeight() + LORD.UDim(0, 5)

		 		bagItems[i].itemWind:subscribeEvent("WindowTouchUp", "onClickRoleEquipInBag")
		 		bagItems[i].itemWind:SetUserData(item:getIndex())
		 							
			 	if bagItems[i].itemIcon then
			 		bagItems[i].itemIcon:SetImage(item:getIcon())
		 			bagItems[i].itemIcon:subscribeEvent("WindowTouchUp", "onClickRoleEquipInBag")
		 			bagItems[i].itemIcon:SetUserData(item:getIndex())
			 	end
				
				if(bagItems[i].equipitem)then
					bagItems[i].equipitem:SetImage(item:getImageWithStar())
				end
				
				if bagItems[i].itemExp then
					if item:getUseLevel() > kingLevel then
						bagItems[i].itemExp:SetText("^FF0000"..item:getNeedKingLevel())	
					else
						bagItems[i].itemExp:SetText(item:getNeedKingLevel())	
					end
				end		
				
				bagItems[i].itemName:SetText(item:getName());
				bagItems[i].rolequipitem_item_dis:SetVisible(item:getUseLevel() > kingLevel );
				bagItems[i].rolequipitem_strengthen:SetText(item:getEnhanceLevelStr());
				
				-- 与身上的装备比较属性
								
				local firstEquipAttr = item:getFirstAttr();
				if firstEquipAttr then
		
					bagItems[i].rolequipitem_attri1:SetVisible(true);
					bagItems[i].rolequipitem_attri1_num:SetText(firstEquipAttr.attvalue);
					bagItems[i].rolequipitem_attri1:SetText(enum.EQUIP_ATTR_TEXT[firstEquipAttr.attid]);
					
					if firstEquipAttr.attvalue > currentItemAtr1 then
						
						bagItems[i].rolequipitem_attri1_addnum:SetText("^00FF00"..(firstEquipAttr.attvalue - currentItemAtr1));
						bagItems[i].rolequipitem_attri1_sarrow:SetImage("set:common.xml image:zhiyin3");
						
					elseif firstEquipAttr.attvalue < currentItemAtr1 then
						
						bagItems[i].rolequipitem_attri1_addnum:SetText("^FF0000"..(currentItemAtr1 - firstEquipAttr.attvalue));
						bagItems[i].rolequipitem_attri1_sarrow:SetImage("set:common.xml image:zhiyin2");
						
					else
						bagItems[i].rolequipitem_attri1_addnum:SetText("");
						bagItems[i].rolequipitem_attri1_sarrow:SetImage("");
					end
										
				else
					bagItems[i].rolequipitem_attri1:SetVisible(false);
				end

				local secondEquipAttr = item:getSecondAttr();
				if secondEquipAttr then
										
					bagItems[i].rolequipitem_attri2:SetVisible(true);
					bagItems[i].rolequipitem_attri2_num:SetText(secondEquipAttr.attvalue);
					bagItems[i].rolequipitem_attri2:SetText(enum.EQUIP_ATTR_TEXT[secondEquipAttr.attid]);
					
					if secondEquipAttr.attvalue > currentItemAtr2 then
						
						bagItems[i].rolequipitem_attri2_addnum:SetText("^00FF00"..(secondEquipAttr.attvalue - currentItemAtr2));
						bagItems[i].rolequipitem_attri2_sarrow:SetImage("set:common.xml image:zhiyin3");
						
					elseif secondEquipAttr.attvalue < currentItemAtr2 then
						
						bagItems[i].rolequipitem_attri2_addnum:SetText("^FF0000"..(currentItemAtr2 - secondEquipAttr.attvalue));
						bagItems[i].rolequipitem_attri2_sarrow:SetImage("set:common.xml image:zhiyin2");
						
					else
						bagItems[i].rolequipitem_attri2_addnum:SetText("");
						bagItems[i].rolequipitem_attri2_sarrow:SetImage("");
					end
										
				else
					bagItems[i].rolequipitem_attri2:SetVisible(false);
				end
										
		 	end
		 	
		end
			
	end
end

-- 点击船上装备的处理
function rolequip:onClickEquipInShip(equipPart, isSwitchPage)
	
	self:strengthenCancel();
	
	--print("onClickEquipInShip 1 self.currrentSelectEquip equipPart "..equipPart);
	
	-- 选中框
	for i = enum.EQUIP_PART.EQUIP_PART_WEAPON, enum.EQUIP_PART.EQUIP_PART_COUNT -1 do
		self.equip[i].choose:SetVisible(i == equipPart);
	end
	
	--if(clickImage and clickImage.item_chose)then
	--	clickImage.item_chose:SetVisible(true)		
	--end
	
	
	-- 这里需要区分当前是不是正在强化，如果正在强化，就只是选择强化的装备
	-- 如果是其他的话，就是进入装备界面
	if self.rolequip_strengthen:IsVisible() and not isSwitchPage then
		
		self:onSelectStrengthenEquip(equipPart);
		
		return;
	end
	
		
	if self.currrentSelectEquip == equipPart then
		-- 之前已经选中
		local equipItem = dataManager.bagData:getItem(self.currrentSelectEquip, self.ship);
					
		if equipItem then
			-- 如果当前位置有装备
			if not global.tipBagFull("仓库已满，请清理仓库后再尝试") then
				sendEquip(enum.EQUIP_OPERATION.EQUIP_OPERATION_UNEQUIP, equipItem:getVec(), equipItem:getPos(),enum.BAG_TYPE.BAG_TYPE_BAG,-1);
			end		
					
		else
			-- 没有装备
			 	
		end
		
	else
		-- 不一样，新的选中
		self.currrentSelectEquip = equipPart;
		self:updateEquipBagData();
				
		-- 筛选背包
		self:showPage(self.rolequip_bag);
			scheduler.performWithDelayGlobal(function ()
				eventManager.dispatchEvent( {name = global_event.GUIDE_ON_ENTER_ROLE_RQUIP_BAGSHOW})
			 
		end, 0.1);
		
	end
	
	local equipItem = dataManager.bagData:getItem(self.currrentSelectEquip, self.ship);
	self:updateCurrentEquipInfo(equipItem);	
end

-- 点击背包装备的处理
function rolequip:onClickEquipInBag(itemIndex)
	local item = itemManager.getItem(itemIndex);
	local playerLevel = dataManager.playerData:getLevel();
	if item and playerLevel >= item:getUseLevel() then
		sendEquip(enum.EQUIP_OPERATION.EQUIP_OPERATION_EQUIP, item:getVec(), item:getPos(), self.ship, -1);
		
		-- 保存换装备前的属性信息
		local equipItem = dataManager.bagData:getItem(self.currrentSelectEquip, self.ship);
		--print("currrentSelectEquip "..self.currrentSelectEquip);
		if equipItem then
			--print(" onClickEquipInBag ");
			self.lastEquipInfo.firstAttr = equipItem:getFirstAttr();
			self.lastEquipInfo.secondAttr = equipItem:getSecondAttr();
			--dump(self.lastEquipInfo)
		end
	else
		if(item)then
			eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "等级不足，无法装备！"})
		end
		--self:updateCurrentEquipInfo(item);
		
	end
	
end

-- 刷新当前选中装备的属性信息
function rolequip:updateCurrentEquipInfo(itemInstance, isCompare)
	
	self:Child("rolequip-bag-noone"):SetVisible(itemInstance == nil);
	self.rolequip_bag_from:SetVisible(itemInstance ~= nil);		
	if(itemInstance)then
		self.rolequip_bag_from:SetUserData(itemInstance:getIndex());
	else
		self.rolequip_bag_from:SetUserData(-1);
	end		
	if itemInstance then
	
		self.select_rolequip_equipname:SetText(itemInstance:getName());
		local playerLevel = dataManager.playerData:getLevel();
		local level = itemInstance:getUseLevel()
		local color = ""
		if(level > playerLevel )then
			color =  "^FF0000";	
		end
		self.select_rolequip_equipLevel:SetText(color..level);
		
		-- 属性
		local firstEquipAttr = itemInstance:getFirstAttr();
		if firstEquipAttr then
			self.select_rolequip_gongjilv:SetVisible(true);
			self.select_rolequip_gongjilv_icon:SetVisible(true);
			self.select_rolequip_gongjilv:SetText(firstEquipAttr.attvalue);
			self.select_rolequip_gongjilv_icon:SetText(enum.EQUIP_ATTR_TEXT[firstEquipAttr.attid]);
		else
			self.select_rolequip_gongjilv:SetVisible(false);
			self.select_rolequip_gongjilv_icon:SetVisible(false);			
		end
		
		local secondEquipAttr = itemInstance:getSecondAttr();
		if secondEquipAttr then
			self.select_rolequip_fangyulv:SetVisible(true);
			self.select_rolequip_fangyulv_icon:SetVisible(true);
			self.select_rolequip_fangyulv:SetText(secondEquipAttr.attvalue);
			self.select_rolequip_fangyulv_icon:SetText(enum.EQUIP_ATTR_TEXT[secondEquipAttr.attid]);
		else
			self.select_rolequip_fangyulv:SetVisible(false);
			self.select_rolequip_fangyulv_icon:SetVisible(false);		
		end
					
		self.select_rolequip_equipname:SetVisible(true);
		self.select_rolequip_equipLevel:SetVisible(true);
		self.rolequip_bag_xinxi_level:SetVisible(true);
		
		--print("isCompare "..tostring(isCompare).." self.lastEquipInfo ");
		--dump(self.lastEquipInfo);
		
		if isCompare then
			-- 和上一次的属性比较
			local oldAttr1Value = 0;
			if self.lastEquipInfo.firstAttr then
				oldAttr1Value = self.lastEquipInfo.firstAttr.attvalue;			
			end
			
			local oldAttr2Value = 0;
			if self.lastEquipInfo.secondAttr  then
				oldAttr2Value = self.lastEquipInfo.secondAttr.attvalue;
			end
			
			--print("self.rolequip_gongjilv_arrow-------------1 ");
			
			if firstEquipAttr then
				--print("self.rolequip_gongjilv_arrow-------------2 ");
				if  firstEquipAttr.attvalue > oldAttr1Value then
					self.rolequip_gongjilv_arrow:SetImage("set:common.xml image:zhiyin3");
					self.rolequip_gongjilv_addnum:SetText("^00FF00"..(firstEquipAttr.attvalue - oldAttr1Value));
				--print("self.rolequip_gongjilv_arrow-------------3 ");
				elseif firstEquipAttr.attvalue < oldAttr1Value then
					self.rolequip_gongjilv_arrow:SetImage("set:common.xml image:zhiyin2");
					self.rolequip_gongjilv_addnum:SetText("^FF0000"..(oldAttr1Value - firstEquipAttr.attvalue));
				--print("self.rolequip_gongjilv_arrow-------------4 ");
				else
				--print("self.rolequip_gongjilv_arrow-------------5 ");
					self.rolequip_gongjilv_arrow:SetImage("");
					self.rolequip_gongjilv_addnum:SetText("");
				end
			else
				if oldAttr1Value > 0 then
					self.rolequip_gongjilv_arrow:SetImage("set:common.xml image:zhiyin2");
					self.rolequip_gongjilv_addnum:SetText("^FF0000"..oldAttr1Value);
				else
					self.rolequip_gongjilv_arrow:SetImage("");
					self.rolequip_gongjilv_addnum:SetText("");
				end
			end
	
			if secondEquipAttr then
				
				if secondEquipAttr.attvalue > oldAttr2Value then
					self.rolequip_fangyulv_arrow:SetImage("set:common.xml image:zhiyin3");
					self.rolequip_fangyulv_addnum:SetText("^00FF00"..(secondEquipAttr.attvalue - oldAttr2Value));
				elseif secondEquipAttr.attvalue < oldAttr2Value then
					self.rolequip_fangyulv_arrow:SetImage("set:common.xml image:zhiyin2");
					self.rolequip_fangyulv_addnum:SetText("^FF0000"..(oldAttr1Value - firstEquipAttr.attvalue));
				else
					self.rolequip_fangyulv_arrow:SetImage("");
					self.rolequip_fangyulv_addnum:SetText("");
				end
				
			else
				if oldAttr2Value > 0 then
					self.rolequip_fangyulv_arrow:SetImage("set:common.xml image:zhiyin2");
					self.rolequip_fangyulv_addnum:SetText("^FF0000"..oldAttr2Value);
				else
					self.rolequip_fangyulv_arrow:SetImage("");
					self.rolequip_fangyulv_addnum:SetText("");			
				end
			end
		else
			self.rolequip_gongjilv_arrow:SetImage("");
			self.rolequip_fangyulv_arrow:SetImage("");
			self.rolequip_gongjilv_addnum:SetText("");
			self.rolequip_fangyulv_addnum:SetText("");
		end
		
	else
		self.select_rolequip_equipname:SetVisible(false);
		self.select_rolequip_equipLevel:SetVisible(false);
		self.rolequip_bag_xinxi_level:SetVisible(false);
		self.select_rolequip_gongjilv:SetVisible(false);
		self.select_rolequip_fangyulv:SetVisible(false);
		self.select_rolequip_gongjilv_icon:SetVisible(false);
		self.select_rolequip_fangyulv_icon:SetVisible(false);
		self.rolequip_gongjilv_arrow:SetImage("");
		self.rolequip_fangyulv_arrow:SetImage("");
		self.rolequip_gongjilv_addnum:SetText("");
		self.rolequip_fangyulv_addnum:SetText("");
	end
	
end

-- 服务器穿卸装备的消息通知以后刷新界面
function rolequip:onUpdateEquip(event)

	if false == self._show then 
		return; 
	end
	
	self:updateEquipedInfo();
	self:updateShipEquipStrongerInfo();
	
	local equipItem = dataManager.bagData:getItem(self.currrentSelectEquip, self.ship);
	self:updateCurrentEquipInfo(equipItem);	
	
	if self.rolequip_cropschose:IsVisible() then
		
	end

	if self.rolequip_bag:IsVisible() then
		self:updateEquipBagData();
	end
	
	if self.rolequip_infor:IsVisible() then
		self:updateUnitInfo();
	end
	eventManager.dispatchEvent( {name = global_event.GUIDE_ON_ENTER_ROLE_RQUIP_FINISH})	
end

function rolequip:updateShipEquipStrongerInfo()
	
	for i=1, 6 do
		local shipInstance = shipData.getShipInstance(i);
		local cardType = PLAN_CONFIG.getShipCardType(i, enum.PLAN_TYPE.PLAN_TYPE_PVE);
		if shipInstance and shipInstance:isActive() and shipInstance:hasEquippedStronger() and cardType and cardType > 0 then
			self.rolequip_ship_notice[i]:SetVisible(true);
		else
			self.rolequip_ship_notice[i]:SetVisible(false);
		end
	end
end


function rolequip:refreshSelectCardUI(race)
	
	print("rolequip:refreshSelectCardUI(race)"..race);
	
	self.rolequip_units = {};
	self.rolequip_units.icon = {};
	self.rolequip_units.shipIcon = {};
	self.rolequip_units.star = {};
	self.rolequip_units.name = {};
	self.rolequip_units.skill = {};
		
	self.rolequip_scroll:ClearAllItem();
	
	local xpos = LORD.UDim(0, 0);
	local ypos = LORD.UDim(0, 0);
	
	local index = 1;
	
	-- 还是排列到原来的位置，但是要滚动到相应的位置
	local cardType = PLAN_CONFIG.getShipCardType(self.ship, enum.PLAN_TYPE.PLAN_TYPE_PVE);
	
	local scrollSize = self.rolequip_scroll:GetPixelSize();
	
	local scrollOffset = 0;
	for k,v in ipairs(cardData.cardlist) do
		if v.exp >= 10 then
			local unitRace = dataConfig.configs.unitConfig[v.unitID].race;
			local unitInfo = dataConfig.configs.unitConfig[v.unitID];
			
			-- 如果是当前装备的就记录一下位置
			if cardType == k then
				scrollOffset = -ypos.offset;
			end
			
			if unitRace == race then
				
				self:updateChooseCardUnitInfo(index, v.cardType, unitInfo, xpos, ypos);
				
				xpos = xpos + self.rolequip_units[index]:GetWidth() + LORD.UDim(0, 10);
				
				local rightEdge = xpos + self.rolequip_units[index]:GetWidth();
				if rightEdge.offset > scrollSize.x then
					xpos = LORD.UDim(0, 0);
					ypos = ypos + self.rolequip_units[index]:GetHeight();
				end
				index = index + 1;
			end
			
		end		
	end
	
	local scrollBottomWindow = LORD.GUIWindowManager:Instance():CreateGUIWindow("DefaultWindow", "rolequip_scrollBottomWindow");
	scrollBottomWindow:SetSize(LORD.UVector2(LORD.UDim(0, scrollSize.x), LORD.UDim(0, 30)));
	scrollBottomWindow:SetPosition(LORD.UVector2(LORD.UDim(0, 0), ypos));
	self.rolequip_scroll:additem(scrollBottomWindow);
	
	self.rolequip_scroll:SetVertScrollOffset(scrollOffset);

end

function rolequip:loadCard(cardType)
	PLAN_CONFIG.loadCard(self.ship, cardType, enum.PLAN_TYPE.PLAN_TYPE_PVE);
end

function rolequip:updateChooseCardUnitInfo(index, cardType, unitInfo, xpos, ypos)
	
	function onClickRoleEquipLoadCard(args)
		local window = LORD.toWindowEventArgs(args).window;
		local cardType = window:GetUserData();
		self:loadCard(cardType);
		self:updateUnitInfo();	
		self:updateUnitAttrInfo();
		self:showPage(self.rolequip_heroinfo);
	end

	self.rolequip_units[index] = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("rolequip_"..index, "corpsitem.dlg");
	self.rolequip_units.icon[index] = LORD.toStaticImage(self:Child("rolequip_"..index.."_corpsitem-head"));
	self.rolequip_units.icon[index]:subscribeEvent("WindowTouchUp", "onClickRoleEquipLoadCard");
	self.rolequip_units.icon[index]:SetImage(unitInfo.icon);
	self.rolequip_units.icon[index]:SetUserData(cardType);
	
	self.rolequip_units.name[index] = self:Child("rolequip_"..index.."_corpsitem-name");
	self.rolequip_units.name[index]:SetText(unitInfo.name);

	local corpsitem_equity = LORD.toStaticImage(self:Child("rolequip_"..index.."_corpsitem-equity"));
		
	corpsitem_equity:SetImage(itemManager.getImageWithStar(unitInfo.starLevel));
			
	self.rolequip_units.shipIcon[index] = LORD.toStaticImage(self:Child("rolequip_"..index.."_corpsitem-ship"));
	
	local shipIndex = PLAN_CONFIG.getShipEquipedCard(cardType, enum.PLAN_TYPE.PLAN_TYPE_PVE);
	if shipIndex > 0 and shipIndex <=6 then
		self.rolequip_units.shipIcon[index]:SetVisible(true);
		self.rolequip_units.shipIcon[index]:SetImage(shipData.shipNumberIcon[shipIndex]);
	else
		self.rolequip_units.shipIcon[index]:SetVisible(false);
	end
	
	self.rolequip_units.star[index] = {};
	-- star
	for i=1, 6 do
		self.rolequip_units.star[index][i] = LORD.toStaticImage(self:Child("rolequip_"..index.."_corpsitem-star"..i));
		if i <= unitInfo.starLevel then
			self.rolequip_units.star[index][i]:SetVisible(true);
		else
			self.rolequip_units.star[index][i]:SetVisible(false);
		end
	end
		
	self.rolequip_units[index]:SetXPosition(xpos);
	self.rolequip_units[index]:SetYPosition(ypos);				
	self.rolequip_scroll:additem(self.rolequip_units[index]);
				
end


function rolequip:onLevelUp()
	
	local ship = shipData.getShipInstance(self.ship);
	
	if not ship:isEnoughPlayerLevel() then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
				textInfo = "请提升英雄等级再进行升级！" });
		return;
	elseif not ship:isEnoughItems() then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
				textInfo = "请获得足够的物品再进行升级！" });
		return;		
	elseif not ship:isEnoughGood() then
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.GOLD, copyType = -1, copyID = -1, });
		return;
	elseif not ship:isEnoughWood() then
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.WOOD, copyType = -1, copyID = -1, });
		return;
	end
	
	sendShipUpgrade(self.ship-1);
	eventManager.dispatchEvent( { name  = global_event.GUIDE_ON_ENTER_SHIP_FINISH})
	LORD.SoundSystem:Instance():playEffect("shengji.mp3");
end

function rolequip:onShipRemould()
	local ship = shipData.getShipInstance(self.ship);
	
	if not ship:isEnoughRemouldItems() then

		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
				textInfo = "请获得足够的物品再进行进阶！#n#n友情提示：#n#n点击物品图标可以查看获取方式" });
		return;
	end
	LORD.SoundSystem:Instance():playEffect("shengji.mp3");
	sendShipRemould(self.ship-1);
	
end

function rolequip:onLevelUpOK()
	if false == self._show then 
		return; 
	end
	
	self.rolequip_levelupEffect:SetEffectName("juntuanshengji03.effect");
end

function rolequip:onRemouldOK()
	if false == self._show then 
		return; 
	end
	
	self.rolequip_levelupEffect:SetEffectName("juntuanshengji04.effect");
end

function rolequip:updateShipCardHeadIcon()
	--self.rolequip_ship_image 
	--self.rolequip_ship_star
	
	for i=1, 6 do
		
		local cardType = PLAN_CONFIG.getShipCardType(i, enum.PLAN_TYPE.PLAN_TYPE_PVE);
		local cardInstance = cardData.getCardInstance(cardType);
		self.rolequip_shipnum = LORD.toStaticImage(self:Child("rolequip-shipnum"));

		
		if cardInstance then
			self.rolequip_ship_image[i]:SetImage(cardInstance:getConfig().icon);
			self.rolequip_ship_equity[i]:SetImage(itemManager.getImageWithStar(cardInstance:getConfig().starLevel));
			
			
			for j=1, 5 do
				self.rolequip_ship_star[i][j]:SetVisible(j<=cardInstance:getConfig().starLevel);
			end			
		else
			self.rolequip_ship_image[i]:SetImage("");
			self.rolequip_ship_equity[i]:SetImage("");
			
			for j=1, 5 do
				self.rolequip_ship_star[i][j]:SetVisible(false);
			end
		end
	end
	
end

function rolequip:onOneKeyEquip()
	
	if(self.hasStrongEquip)then
		eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "已使用最强装备" })
	else
		eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "没有可以更换的装备"})
	end
	
	for i = enum.EQUIP_PART.EQUIP_PART_WEAPON, enum.EQUIP_PART.EQUIP_PART_COUNT -1 do
		local sortList = dataManager.bagData:getEquipSortListByEquipPoint(i);
		
		for k,v in ipairs(sortList) do
			
			if dataManager.playerData:getLevel() >= v:getUseLevel() then
				
				local currentItem = dataManager.bagData:getItem(i, self.ship);
				
				if currentItem then
				
					local 	equipAttValue1,equipAttValue2 = v:getFeatureMaxEquipAtt();
					local 	_equipAttValue1,_equipAttValue2 = currentItem:getFeatureMaxEquipAtt();					
					
					if equipAttValue1 > _equipAttValue1 then
						self:onClickEquipInBag(v:getIndex());		
					end
				else
					self:onClickEquipInBag(v:getIndex());	
				end
						
				break;
			end
			
		end
		
	end
	
end

function rolequip:onSelectStrengthenEquip(equipPart)

	-- 选中框
	for i = enum.EQUIP_PART.EQUIP_PART_WEAPON, enum.EQUIP_PART.EQUIP_PART_COUNT -1 do
		self.equip[i].choose:SetVisible(i == equipPart);
	end
			
	local itemInstance = dataManager.bagData:getItem(equipPart, self.ship);
	if not itemInstance or not itemInstance:isEquip() then
		-- 没有信息的话也要刷成空

		self.rolequip_strengthen_item_image:SetImage("");
		self.rolequip_strengthen_item_equlity:SetImage(itemManager.getImageWithStar());
		self.rolequip_strengthen_name_text:SetText("该位置无可强化装备");
		self.rolequip_strengthen_lv_text:SetText("0");
		self.rolequip_strengthen_lv_num:SetText("");
		self.rolequip_strengthen_bar:SetProperty("Progress", 0);
		self.rolequip_strengthen_percent_num:SetText("0%");
		self.rolequip_strengthen_attri1:SetVisible(true);
		self.rolequip_strengthen_attri1:SetText("无");
		self.rolequip_strengthen_attri1_num:SetText("");
		self.rolequip_strengthen_attri2:SetVisible(false);
		
		self.rolequip_strengthen_attri1_next:SetVisible(true);
		self.rolequip_strengthen_attri1_next:SetText("无");
		self.rolequip_strengthen_attri1_next_num:SetText("");
		
		self.rolequip_strengthen_attri2_next:SetVisible(false);
	
		self.rolequip_strengthen_cost_num:SetText("0");
		--self.rolequip_strengthen_next_text:SetText("无");
		self.rolequip_strengthen_item_level:SetText("");
		
		self.selectItemPos  = equipPart;
		
		self:refreshButtonState();
		return;
	end
	
	self.selectItemPos = equipPart;
	
	self.rolequip_strengthen_item_image:SetImage(itemInstance:getIcon());
	self.rolequip_strengthen_item_equlity:SetImage(itemInstance:getImageWithStar());
	local level = itemInstance:getEnhanceLevelStr();
	 
	-- 强化等级 
	--self.strengthen_item_strengthen:SetText(level);
	
	
	self.rolequip_strengthen_name_text:SetText(itemInstance:getName());
	self.rolequip_strengthen_lv_text:SetText("Lv");
	self.rolequip_strengthen_lv_num:SetText(itemInstance:getNeedKingLevel());
	self.rolequip_strengthen_item_level:SetText(itemInstance:getEnhanceLevelStr());
	
	local isMaxLevel = itemInstance:isMaxEnhance();
	
	self.rolequip_strengthen_tips:SetVisible(not isMaxLevel);
			
	-- 属性的显示
	local firstEquipAttr = itemInstance:getFirstAttr();
	
	if firstEquipAttr then
		local firstAttrAdd = itemInstance:getNextFirstAttr() - firstEquipAttr.attvalue;

		
		self.rolequip_strengthen_attri1:SetText(enum.EQUIP_ATTR_TEXT[firstEquipAttr.attid]);
		self.rolequip_strengthen_attri1_num:SetText(firstEquipAttr.attvalue);
		self.rolequip_strengthen_attri1_addnum:SetText(firstAttrAdd);
		self.rolequip_strengthen_attri1:SetVisible(true);
		self.rolequip_strengthen_attri1_next:SetVisible(true);
		self.rolequip_strengthen_attri1_next:SetText(enum.EQUIP_ATTR_TEXT[firstEquipAttr.attid]);
		self.rolequip_strengthen_attri1_next_num:SetText(itemInstance:getNextFirstAttr());
	else
		self.rolequip_strengthen_attri1:SetVisible(false);
		self.rolequip_strengthen_attri1_next:SetVisible(false);
	end
	
	local secondEquipAttr = itemInstance:getSecondAttr();
	
	if secondEquipAttr then
		local secondAttrAdd = itemInstance:getNextSecondAttr() - secondEquipAttr.attvalue;

		self.rolequip_strengthen_attri2:SetText(enum.EQUIP_ATTR_TEXT[secondEquipAttr.attid]);
		self.rolequip_strengthen_attri2_num:SetText(secondEquipAttr.attvalue);
		self.rolequip_strengthen_attri2_addnum:SetText(secondAttrAdd);
		self.rolequip_strengthen_attri2:SetVisible(true);

		self.rolequip_strengthen_attri2_next:SetVisible(true);
		self.rolequip_strengthen_attri2_next:SetText(enum.EQUIP_ATTR_TEXT[secondEquipAttr.attid]);
		self.rolequip_strengthen_attri2_next_num:SetText(itemInstance:getNextSecondAttr());		
		
	else
		self.rolequip_strengthen_attri2:SetVisible(false);
		self.rolequip_strengthen_attri2_next:SetVisible(false);
	end
	
	-- 完成度
	local currentExp = itemInstance:getCurrentExp();
	local nextExp = itemInstance:getNextExp();
	self.rolequip_strengthen_bar:SetProperty("Progress", currentExp/nextExp);
	self.rolequip_strengthen_percent_num:SetText(math.floor(100 * currentExp/nextExp).."%");
	
	-- 金币消耗
	local costGold = itemInstance:getNextEnhanceCost();
	self.rolequip_strengthen_cost_num:SetText(costGold);

	-- 如果满级了显示的信息不一样
	if isMaxLevel then

		self.rolequip_strengthen_attri1_addnum:SetText("已满");
		self.rolequip_strengthen_attri2_addnum:SetText("已满");
		self.rolequip_strengthen_attri1_next_num:SetText("已达最高");
		self.rolequip_strengthen_attri2_next_num:SetText("已达最高");	
		self.isAutoEnhancing = false
	end
		
	self:refreshButtonState();
	
		
end

function rolequip:refreshButtonState()
	
	if not self._show then
		return;
	end
	
	local isEnhancing = itemManager.isEnhancingEquip();
	local itemInstance = dataManager.bagData:getItem(self.selectItemPos, self.ship);
	local canEnhance = false;
	if itemInstance then
		canEnhance = itemInstance:canEnhance();		
	end
	
	local button1 = self:Child("rolequip-strengthen-button1");
	local button2 = self:Child("rolequip-strengthen-button2");
	local button4 = self:Child("rolequip-strengthen-button4");
	
	if button1 then
		button1:SetEnabled(canEnhance and not isEnhancing);	
	end
	
	if button2 then
		button2:SetEnabled(canEnhance and not isEnhancing);
		button2:SetVisible(not self.isAutoEnhancing);
	end
	
	if button4 then
		button4:SetVisible(self.isAutoEnhancing);
	end
	
end

function rolequip:strengthenConfirm()
	self:sendStrength();
end

function rolequip:strengthenConfirmAuto()
	
	-- 自动强化改为一键强化
	self:sendStrength(true);
	
	--[[
	self.isAutoEnhancing = true;
	self:sendStrength();
	
	function autoSendTimerFun()
		--print("autoSendTimerFun");
		local itemInstance = dataManager.bagData:getItem(self.selectItemPos, self.ship);
		local isEnhancing = itemManager.isEnhancingEquip();
		if itemInstance and itemInstance:canEnhance() and not isEnhancing and self.isAutoEnhancing then
			-- 时间到了，而且也没有在强化状态，就再次发送
			-- 否则的话，说明还没返回结果，那么在返回结果的时候就再次发送
			self:sendStrength();			
		end
		
		self:refreshButtonState();
		
	end
	
	if self.autoSendTimer > 0 then
		print("strengthen:strengthenConfirmAuto() autoSendTimer error ");
		scheduler.unscheduleGlobal(self.autoSendTimer);
		self.autoSendTimer = -1;
	end
	
	self.autoSendTimer = scheduler.scheduleGlobal(autoSendTimerFun, 0.5);
	--]]

end

function rolequip:sendStrength(isOneKey)
	
	local itemInstance = dataManager.bagData:getItem(self.selectItemPos, self.ship);
	if itemInstance and itemInstance:isEnoughGoldEnhance() then
		itemManager.setEnhancingEquip(true);
		self:refreshButtonState();
		local pos = itemInstance:getPos();
		local vec = itemInstance:getVec();
		
		if isOneKey then
			sendEquipEnhance(vec, pos, enum.ENHANCE_TYPE.ENHANCE_TYPE_TO_MAX)
		else
			sendEquipEnhance(vec, pos, enum.ENHANCE_TYPE.ENHANCE_TYPE_ONCE)
		end
		
	else
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "lackofresource", resType = enum.BUY_RESOURCE_TYPE.GOLD, copyType = -1, copyID = -1, });
		self:strengthenCancel();
	end
	LORD.SoundSystem:Instance():playEffect("datie03.mp3");
end

function rolequip:strengthenCancel()
	self.isAutoEnhancing = false;
	self:refreshButtonState();
	
	if self.autoSendTimer > 0 then
		scheduler.unscheduleGlobal(self.autoSendTimer);
		self.autoSendTimer = -1;
	end
end

function rolequip:onEnhanceResult(event)
	
	if not self._show then
		return;
	end
	
	-- 成功的话, 刷新信息
	self:updateEquipedInfo();
	
	-- 刷新当前装备的数值
	self:onSelectStrengthenEquip(self.selectItemPos);
	
	-- 播放特效
	--[[
	-- 1倍，2倍，3倍，进阶成功
	if event.ratio == 0 then
		self.rolequip_classupEffect:SetEffectName("qianghua0.effect");
	elseif event.ratio == 1 then
		self.rolequip_classupEffect:SetEffectName("qianghua1.effect");
	elseif event.ratio == 2 then
		self.rolequip_classupEffect:SetEffectName("qianghua2.effect");
	end
	--]]
	
	self.rolequip_classupEffect:SetEffectName("qianghua0.effect");
	
	self:refreshButtonState();
	eventManager.dispatchEvent( {name = global_event.GUIDE_ON_ENTER_STRENGTHEN_FINISH})
end

function rolequip:initUnitInfoUIWindow()
	
	self.rolequip_heroinfo = self:Child("rolequip-heroinfo");
	self.rolequip_heroinfo:SetUserData(5);
	
	self.rolequip_hinfo_name = self:Child( "rolequip-hinfo-name" );
	self.rolequip_hinfo_shengming_num = self:Child( "rolequip-hinfo-shengming-num" );
	self.rolequip_hinfo_gongji_num = self:Child( "rolequip-hinfo-gongji-num" );
	self.rolequip_hinfo_fangyu_num = self:Child( "rolequip-hinfo-fangyu-num" );
	self.rolequip_hinfo_sudu_num = self:Child( "rolequip-hinfo-sudu-num" );
	self.rolequip_hinfo_shecheng_num = self:Child( "rolequip-hinfo-shecheng-num" );
	self.rolequip_hinfo_yidongli_num = self:Child( "rolequip-hinfo-yidongli-num" );
	self.rolequip_hinfo_rangetype = LORD.toStaticImage(self:Child( "rolequip-hinfo-rangetype" ));
	self.rolequip_hinfo_atktype = LORD.toStaticImage(self:Child( "rolequip-hinfo-atktype" ));
	self.rolequip_hinfo_movetype = LORD.toStaticImage(self:Child( "rolequip-hinfo-movetype" ));
	
	self.rolequip_skill = {};
	self.rolequip_hskill_item = {};
	self.rolequip_hskill_dw = {};
	
	function onClickRoleEquipUnitAttrInfo()
		self:updateUnitAttrInfo();
		self:showPage(self.rolequip_heroinfo);
	end
	
	self.rolequip_infor_corps_info = self:Child("rolequip-infor-corps-info");
	
	self.rolequip_infor_corps_info:subscribeEvent("ButtonClick", "onClickRoleEquipUnitAttrInfo");
	
	for i=1, 3 do
		
		self.rolequip_skill[i] = LORD.toStaticImage(self:Child( "rolequip-skill"..i ));
		self.rolequip_hskill_item[i] = LORD.toStaticImage(self:Child( "rolequip-hskill"..i.."-item" ));
		self.rolequip_hskill_dw[i] = self:Child("rolequip-hskill"..i.."-dw");
		
		global.onSkillTipsShow(self.rolequip_hskill_item[i], "skill", "top");
		global.onTipsHide(self.rolequip_hskill_item[i]);
				
	end
	
end

-- 更新新的军团的属性信息界面
function rolequip:updateUnitAttrInfo()
	
	if not self._show then
		return;
	end
	
	local cardType = PLAN_CONFIG.getShipCardType(self.ship, enum.PLAN_TYPE.PLAN_TYPE_PVE);
	local cardInstance = cardData.getCardInstance(cardType);
	
	if cardInstance then
		
		self:Child("rolequip-hinfor"):SetVisible(true);
		self:Child("rolequip-hskill"):SetVisible(true);
		self:Child("rolequip-hinfo-noone"):SetVisible(false);
		
		local unitInfo = cardInstance:getConfig();

		self.rolequip_hinfo_name:SetText(unitInfo.name);
			
		self.rolequip_hinfo_shecheng_num:SetText(unitInfo.attackRange);
		self.rolequip_hinfo_gongji_num:SetText(unitInfo.soldierDamage);
		self.rolequip_hinfo_fangyu_num:SetText(unitInfo.defence);
		self.rolequip_hinfo_shengming_num:SetText(unitInfo.soldierHP);
		self.rolequip_hinfo_sudu_num:SetText(unitInfo.actionSpeed);
		self.rolequip_hinfo_yidongli_num:SetText(unitInfo.moveRange);
		
		local isRange = 0;
		if unitInfo.isRange == true then
			isRange = 1;
		end
		
		self.rolequip_hinfo_rangetype:SetImage(enum.unitIsRangeImageMap[isRange]);
		self.rolequip_hinfo_atktype:SetImage(enum.unitDamageTypeImageMap[unitInfo.damageType]);
		self.rolequip_hinfo_movetype:SetImage(enum.unitMoveTypeImageMap[unitInfo.moveType]);
				
		for i=1, 3 do
			if unitInfo.skill[i] then
				
				self.rolequip_hskill_item[i]:SetVisible(true);
				self.rolequip_skill[i]:SetVisible(true);
				self.rolequip_hskill_dw[i]:SetVisible(true);
				
				self.rolequip_hskill_item[i]:SetUserData(unitInfo.skill[i]);
				
				self.rolequip_hskill_item[i]:SetImage(dataConfig.configs.skillConfig[unitInfo.skill[i]].icon);
				
				
			else
				
				self.rolequip_hskill_item[i]:SetVisible(false);
				self.rolequip_skill[i]:SetVisible(false);
				self.rolequip_hskill_dw[i]:SetVisible(false);
				
			end
		end
			
	else
		-- 没有军团的话，隐藏相关的界面
		
		self:Child("rolequip-hinfor"):SetVisible(false);
		self:Child("rolequip-hskill"):SetVisible(false);
		self:Child("rolequip-hinfo-noone"):SetVisible(true);
	end
			
end


function rolequip:onUpdateCurrentPageInfo()
	
	if not self._show then
		return;
	end

	if self.rolequip_cropschose:IsVisible() then

	end

	if self.rolequip_bag:IsVisible() then
		self:updateEquipBagData();
	end
	
	if self.rolequip_infor:IsVisible() then
		self:updateUnitInfo();
	end
	
	if self.rolequip_strengthen:IsVisible() then
		
	end
	
	if self.rolequip_heroinfo:IsVisible() then
		self:updateUnitAttrInfo();
	end
		
end

return rolequip;