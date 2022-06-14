--wz

local  pack= class("pack",layout)

function pack:ctor( id )
	 pack.super.ctor(self,id)	
	 self:addEvent({ name = global_event.PACK_SHOW, eventHandler = self.onSHOW})	
	 self:addEvent({ name = global_event.PACK_UPDATE, eventHandler = self.onUpdate})		
	 self:addEvent({ name = global_event.ENTER_GAME_STATE_INSTANCE, eventHandler = self.onHide})	
		
end	

 
function pack:onSHOW(event)
	self:Show()
	self:init()
	self:update()	
end

function pack:onUpdate(event)
	if( false == self._show)then return end

	self.pack_iteminfor:SetVisible(false);	
	self:update()
	
end

function pack:init()
	function onClickClosePack()	
		self:onHide()
	end	
	self.tabPage = nil	
	self.pack_lose = self:Child("pack-close")	
	self.pack_lose:subscribeEvent("ButtonClick", "onClickClosePack")
	
	
	function onClickPack_sellout()	
		 eventManager.dispatchEvent({name = global_event.SELLOUT_SHOW,  filter = self.filter})
	end	
	
	self.pack_pack_sellout = self:Child("pack-pack-sellout")	
	self.pack_pack_sellout_dw = self:Child("pack-pack-sellout-dw")	
	
	self.pack_pack_sellout:subscribeEvent("ButtonClick", "onClickPack_sellout")

	self.pack_iteminfor = self:Child("pack-iteminfor")	
	self.pack_iteminfor:SetVisible(false);	
	
	self.pack_scrl =  LORD.toScrollPane (self:Child("pack-scrl"))	
	self.pack_scrl:init();
	
	self.pack_item_back = LORD.toStaticImage(self:Child("pack-item-back"))	
	
	
	
	--self.equip = {}	
	--self.equip[enum.EQUIP_PART.EQUIP_PART_WEAPON] ={ icon = LORD.toStaticImage(self:Child("rolequip-wuqi-tubiao")),  exp =  self:Child("rolequip-wuqi-qianghua") }
	--self.equip[enum.EQUIP_PART.EQUIP_PART_GLOVE]  ={ icon = LORD.toStaticImage(self:Child("rolequip-shoutao-tubiao")),  exp =  self:Child("rolequip-shoutao-qianghua") }
	--self.equip[enum.EQUIP_PART.EQUIP_PART_BREASTPLATE]  ={ icon = LORD.toStaticImage(self:Child("rolequip-shangyi-tubiao")),  exp =  self:Child("rolequip-shangyi-qianghua") }
	--self.equip[enum.EQUIP_PART.EQUIP_PART_LEGGINGS]  ={ icon = LORD.toStaticImage(self:Child("rolequip-kuzi-tubiao")),  exp =  self:Child("rolequip-kuzi-qianghua") }
	--self.equip[enum.EQUIP_PART.EQUIP_PART_HELMENT]  ={ icon = LORD.toStaticImage(self:Child("rolequip-toukui-tubiao")),  exp =  self:Child("rolequip-toukui-qianghua") }	
	--self.equip[enum.EQUIP_PART.EQUIP_PART_SHOES]  ={ icon = LORD.toStaticImage(self:Child("rolequip-xiezi-tubiao")),  exp =  self:Child("rolequip-xiezi-qianghua") }	

	self.tab = {}
	for i = 1, 5 do
		self.tab[i] =  self:Child("pack-tab"..i)			
		self.tab[i]:subscribeEvent("RadioStateChanged", "onClickTable")
		self.tab[i]:SetUserData(i)
	end	
 
	function onClickTable(args)
		local tablePage = LORD.toRadioButton(LORD.toWindowEventArgs(args).window)
		if(tablePage:IsSelected())then
			local userdata = tablePage:GetUserData()
			self.tabPage = userdata
			self.curSelItem = nil;
			self.pack_iteminfor:SetVisible(false);	
			self:updateTablePage(self.tabPage)
			--tablePage:SetProperty("BtnTextColor", "0 0 0 1");
			
			for i=1, 5 do
				local textui = self:Child("pack-tab"..i.."-text");
				local text_nui = self:Child("pack-tab"..i.."-text-n");
				
				if textui then
					textui:SetVisible(i ~= userdata);
				end
				
				if text_nui then
					text_nui:SetVisible(i == userdata);
				end
				
			end
			
		else
			--tablePage:SetProperty("BtnTextColor", "0.152941 0.372471 0.592157 1");
		end				
	end	
 
	function onClickEquip()	
		if(self.curSelItem == -1 or self.curSelItem == nil)then 	
			return
		end
		local item = itemManager.getItem(self.curSelItem)		
	end
		
	--self.rolequip_button = self:Child("rolequip-button")	
	--self.rolequip_button:subscribeEvent("ButtonClick", "onClickEquip")
 
	self.pack_item =  LORD.toStaticImage( self:Child("pack-item") )	
	self.pack_image =  LORD.toStaticImage( self:Child("pack-image") )	
	
	self.pack_name =  self:Child("pack-name")	
	self.pack_num_num =   self:Child("pack-num-num")		
	self.pack_use_level_num =   self:Child("pack-use-level-num")	
	self.pack_use_level =   self:Child("pack-use-level")	
	self.pack_use_ell_num =   self:Child("pack-use-sell-num")
	self.pack_stLevel =  self:Child("pack-stLevel")	
	self.pack_title =  self:Child("pack-title")	
	self.pack_use_sell =   self:Child("pack-use-sell")
	
	
	
	self.pack_image:SetImage("")
	self.pack_name:SetText("")
	self.pack_num_num:SetText("")
	self.pack_use_level_num:SetText("")
	self.pack_use_ell_num:SetText("")
	self.pack_stLevel:SetText("") 
	self.pack_title:SetText("")  
	
	
	self.pack_use_button1_use =   self:Child("pack-use-button1-use")
	self.pack_use_button2_sell =   self:Child("pack-use-button2-sell")
	
	self.pack_item_shuxing =   self:Child("pack-item-shuxing")
	self.pack_item_shuxing1 =   self:Child("pack-use-value1")
	self.pack_item_shuxing2 =   self:Child("pack-use-value2")
	
	self.pack_item_shuxing1_num =   self:Child("pack-use-value1-num")
	self.pack_item_shuxing2_num =   self:Child("pack-use-value2-num")
	
	
	self.pack_huoqu = self:Child("pack-huoqu")
	self.pack_use_button = self:Child("pack-use-button1")
	self.pack_buttonSell = self:Child("pack-buttonSell")
	
	
	function onClickSell(args)
	 	if(self.curSelItem == -1 or nil== self.curSelItem)then 	
			return
		end
		local item = itemManager.getItem(self.curSelItem) 		
		self.vertScrollPos = self.pack_scrl:GetVertScrollOffset();	
		if(item:canOverlap())then
			eventManager.dispatchEvent({name = global_event.ITEMSALE_SHOW,selItem = self.curSelItem })
		else
			local pos = item:getPos()
			local data = {}
			data.position = pos
			data.itemCount = item:getCount()
			sendTrade({data})
		end	
	end	 	
	function onClickUse(args)
	 	if(self.curSelItem == -1 or nil== self.curSelItem)then 	
			return
		end
		local item = itemManager.getItem(self.curSelItem) 	
		sendUseItem(enum.USE_ITEM_OPCODE.USE_ITEM_OPCODE_USE, item:getPos())		
		self.vertScrollPos = self.pack_scrl:GetVertScrollOffset();	
			
 	end	 		
	 
	self.pack_use_button2_sell:subscribeEvent("ButtonClick", "onClickSell")			
	self.pack_use_button1_use:subscribeEvent("ButtonClick", "onClickUse")	
	
 
	self.pack_use_button:SetVisible(false);	
	self.pack_buttonSell:SetVisible(false);	
 
	
	
	function onClickGetItem(args)
	 	if(self.curSelItem == -1 or nil== self.curSelItem)then 	
			return
		end
		local item = itemManager.getItem(self.curSelItem) 	
		
		eventManager.dispatchEvent({name = global_event.ITEMACQUIRE_SHOW,_type = "item",selId = self.curSelItem })	
 	end	 	
	
	
	self.pack_num_button =  self:Child("pack-num-button")
	self.pack_num_button:subscribeEvent("ButtonClick", "onClickGetItem")	
	self.oldSelWnd = nil
	self.curSelItem = nil
	
	local firstTab = LORD.toRadioButton(self:Child("pack-tab1"));
	if firstTab then
		firstTab:SetSelected(true);
	end
end

function pack:update()
	
	if(self.curSelItem ~= -1 and  self.curSelItem)then 	
		local item = itemManager.getItem(self.curSelItem) 
		if(not  item)then
			self.curSelItem = nil	
		end
	end
		
	self:updateTablePage(self.tabPage)	
	if(self.vertScrollPos ~= nil)then
		self.pack_scrl:SetVertScrollOffset(self.vertScrollPos);	
	end
	self:showSelItemEquipInfo()
end	
	
	
function pack:onHide(event)	
	self.oldSelWnd = nil
	self.curSelItem = nil
	self:Close();
end

function pack:updateTablePage(tablePage)
	
	self.oldSelWnd = nil;

	--self.curSelItem = nil;
	self.pack_scrl:ClearAllItem() 
	local filter = enum.ITEM_TYPE.ITEM_TYPE_INVALID
	if(tablePage == nil or tablePage <= 0)then
		tablePage  = 1
	end	
	self.pack_pack_sellout:SetVisible(false);
	if(self.pack_pack_sellout_dw)then
		self.pack_pack_sellout_dw:SetVisible(false);
	end
	
	if(tablePage == 1)then
	elseif(tablePage == 2)then 
		filter = enum.ITEM_TYPE.ITEM_TYPE_EQUIP
		self.pack_pack_sellout:SetVisible(true);
		if(self.pack_pack_sellout_dw)then
			self.pack_pack_sellout_dw:SetVisible(true);
		end
	elseif(tablePage == 3)then 
		filter = enum.ITEM_TYPE.ITEM_TYPE_MATERIAL
	elseif(tablePage == 4)then 
		filter = enum.ITEM_TYPE.ITEM_TYPE_DEBRIS
		self.pack_pack_sellout:SetVisible(true);
		if(self.pack_pack_sellout_dw)then
			self.pack_pack_sellout_dw:SetVisible(true);
		end
	elseif(tablePage == 5)then 
		filter = enum.ITEM_TYPE.ITEM_TYPE_USED
	end
	self.filter = filter
	function onTouchDownEquip(args)	
		if(self.oldSelWnd and self.oldSelWnd.item_chose)then
			print("self.oldSelWnd.item_chose "..self.oldSelWnd.item_chose:GetName())
			self.oldSelWnd.item_chose:SetVisible(false)		
		end
		local clickImage = LORD.toWindowEventArgs(args).window		
 		local userdata = clickImage:GetUserData()	
		if(clickImage and clickImage.item_chose)then
			clickImage.item_chose:SetVisible(true)		
		end
		self.oldSelWnd = clickImage
		if(userdata ~= -1)then
				local item = itemManager.getItem(userdata)		
				self.curSelItem = 	userdata
				--print("!!!"..userdata)
				if(item:getVec() ==  enum.BAG_TYPE.BAG_TYPE_BAG)then												
					self:showSelItemEquipInfo()
				end
		end				
 	end	 
	function onTouchReleaseEquip(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()			
		if(userdata ~= -1)then
			local item = itemManager.getItem(userdata)		
		end
 	end	 		
	function onTouchUpEquip(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()
		if(userdata == -1)then
			return
		end
		local item = itemManager.getItem(userdata)			
 	end	 	
		
	local xpos = LORD.UDim(0, 12)
	local ypos = LORD.UDim(0, 12)
	local nums = dataManager.bagData:getVecItemNums(enum.BAG_TYPE.BAG_TYPE_BAG)
	local vec = dataManager.bagData:getVec(enum.BAG_TYPE.BAG_TYPE_BAG)
	local t = table.keys(vec)
	local itemIndex = 0
	self.tmp ={}
	
	local Sortitem = {}
	for i = 1,nums do	
			local item = dataManager.bagData:getItem(t[i],enum.BAG_TYPE.BAG_TYPE_BAG)
		 	if item  and  ( (filter == enum.ITEM_TYPE.ITEM_TYPE_INVALID) or item:filter(filter) )then	
				table.insert(Sortitem,item)
			end
	end
	
	table.sort(Sortitem,pack_sort_item)
	local kingLevel = dataManager.playerData:getLevel()
	nums = #Sortitem
	for i = 1,nums do	
		self.tmp[i] = self.tmp[i] or {}
	 	--local item = dataManager.bagData:getItem(t[i],enum.BAG_TYPE.BAG_TYPE_BAG)		
		local item = Sortitem[i]	
					
	 	--if item  and  ( (filter == enum.ITEM_TYPE.ITEM_TYPE_INVALID) or item:filter(filter) )then		
		if item then		
		 	self.tmp[i].itemWind = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("item"..i, "item.dlg");
			
			self.tmp[i].itemStar = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("item"..i.."_item_item"));	
			
			self.tmp[i].itemIcon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("item"..i.."_item-image"));	
			self.tmp[i].itemName= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("item"..i.."_item-num"));				
			self.tmp[i].item_chose = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("item"..i.."_item-chose"));
			self.tmp[i].itemstLevel= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("item"..i.."_item-stLevel"));		
			self.tmp[i].itemstlevelless= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("item"..i.."_item-levelless"));		
			
			self.tmp[i].itemWind:SetProperty("ImageName",item:getBackImage())
			self.tmp[i].item_chose:SetProperty("ImageName",item:getSelectImage())	
			
			 self.tmp[i].itemStar:SetImage(item:getImageWithStar())
			 self.tmp[i].itemIcon.item_chose =  self.tmp[i].item_chose	
			 self.tmp[i].itemIcon.item_chose:SetVisible(false)
			
			self.tmp[i].itemWind:SetPosition(LORD.UVector2(xpos, ypos));
		 	self.pack_scrl:additem( self.tmp[i].itemWind);
			
		 	local width = self.tmp[i].itemWind:GetWidth()
		 	xpos = xpos + width +   LORD.UDim(0, 11)
			itemIndex = itemIndex + 1
			if(itemIndex >= 6)then
				itemIndex = 0
				xpos = LORD.UDim(0, 10)
				ypos = ypos +  self.tmp[i].itemWind:GetHeight() + LORD.UDim(0,11)
			end						
		 	if  self.tmp[i].itemIcon then
		 		 self.tmp[i].itemIcon:SetImage(item:getIcon())

				 -- 纰庣墖鐨勫鐞?
				 global.setMaskIcon(self.tmp[i].itemIcon, item:getMaskIcon());
					 		 
		 		 self.tmp[i].itemIcon:subscribeEvent("WindowTouchDown", "onTouchDownEquip")
	 			 self.tmp[i].itemIcon:subscribeEvent("WindowTouchUp", "onTouchUpEquip")
	 			 self.tmp[i].itemIcon:subscribeEvent("MotionRelease", "onTouchReleaseEquip")
	 			 self.tmp[i].itemIcon:SetUserData(item:getIndex())
				---print("000000000000---"..item:getIndex())
				self.tmp[i].itemstlevelless:SetVisible(item:getUseLevel() > kingLevel)
				--self.tmp[i].itemIcon:setGray(item:getUseLevel() > kingLevel)
		 	end				
			if  self.tmp[i].itemName then
				 --self.tmp[i].itemName:SetText(item:getCount())	--getName
				
				if item:isDebris() then
					local id, needCount = item:getProduct();
					if needCount and item:getCount() then
						self.tmp[i].itemName:SetText(item:getCount().."/"..needCount);
					end
				else
					if(item:getCount() > 1)then
						self.tmp[i].itemName:SetText(item:getCount())
					else
						self.tmp[i].itemName:SetText("")
					end
				end
			end		
			
			if self.tmp[i].itemstLevel then			
				self.tmp[i].itemstLevel:SetText(item:getEnhanceLevelStr())
			end	
						
	 	end		
	end		
end	

function pack:showSelItemEquipInfo()
	if(self.curSelItem == -1 or  nil ==  self.curSelItem)then 	
		return
	end
	local item = itemManager.getItem(self.curSelItem) 	
	self.pack_iteminfor:SetVisible(true);	
	local canScale = false
	local price = 0
	canScale,price = item:canScale()
	self.pack_item:SetImage(item:getImageWithStar())
	self.pack_image:SetImage(item:getIcon())
	
	self.pack_item_back:SetImage(item:getBackImage())
	
	-- 纰庣墖鐨勫鐞?
	global.setMaskIcon(self.pack_image, item:getMaskIcon());
						
	self.pack_name:SetText(item:getName())
 
	self.pack_num_num:SetText(item:getCount())
	self.pack_use_level_num:SetText(item:getUseLevel())
	self.pack_item_shuxing:SetVisible(false);	
	self.pack_use_level:SetText( "使用等级: ^F1DB8CLv")
	if(item:isEquip())then
		self.pack_use_level:SetText( "装备等级: ^F1DB8CLv")
		self.pack_item_shuxing:SetVisible(true);	
		
		local att1 = item:getFirstAttr()
		if(att1)then
			self.pack_item_shuxing1:SetVisible(true);	
			self.pack_item_shuxing1:SetText(item.getEquipAttDesc(att1.attid))
			self.pack_item_shuxing1_num:SetText(att1.attvalue)
		else
		
			self.pack_item_shuxing1:SetVisible(false);	
		end
		local att2 = item:getSecondAttr()
		if(att2)then
			self.pack_item_shuxing2:SetVisible(true);	
			self.pack_item_shuxing2:SetText(   item.getEquipAttDesc(att2.attid))
			self.pack_item_shuxing2_num:SetText(att2.attvalue)
		else
		
			self.pack_item_shuxing2:SetVisible(false);	
		end
 
	elseif(item:isDebris())then
	
		if(item:getProductIsEquip() )then
			self.pack_use_level:SetText( "装备等级: ^F1DB8CLv")
			self.pack_use_level_num:SetText(item:getProductUseLevel())
			self.pack_item_shuxing:SetVisible(true);	
			local att1 = item:getFirstAttr()
			if(att1)then
				self.pack_item_shuxing1:SetVisible(true);	
				self.pack_item_shuxing1:SetText(item.getEquipAttDesc(att1.attid))
				self.pack_item_shuxing1_num:SetText(att1.attvalue)
			else
			
				self.pack_item_shuxing1:SetVisible(false);	
			end
			local att2 = item:getSecondAttr()
			if(att2)then
				self.pack_item_shuxing2:SetVisible(true);	
				self.pack_item_shuxing2:SetText(  item.getEquipAttDesc(att2.attid))
				self.pack_item_shuxing2_num:SetText(att2.attvalue)
			else
				self.pack_item_shuxing2:SetVisible(false);	
			end
		elseif(item:getProductIsUsedItem())then		
			 
		elseif(item:getProductIsMatrial())then		
			self.pack_use_level:SetText( "")
			self.pack_use_level_num:SetText("")	
		end
	elseif(item:isUsedItem())then		
	
	elseif(item:isMatrial() )then		
		self.pack_use_level:SetText( "")
		self.pack_use_level_num:SetText("")	
	else 
		
	end
	 
	
	
	
	
	
	self.pack_stLevel:SetText(item:getEnhanceLevelStr())
	self.pack_title:SetText(item:getText())
	if(canScale)then
		self.pack_use_ell_num:SetText(price)
		self.pack_use_sell:SetVisible(true);	
	else
		self.pack_use_ell_num:SetText("不可以出售")
		self.pack_use_sell:SetVisible(false);	
	end
	local canuse = item:isUsedItem()
 	
	self.pack_use_button:SetVisible(false);	
	self.pack_buttonSell:SetVisible(false);	
	
	if(canuse and canScale ) then
		 
		self.pack_use_button:SetVisible(true)	
		self.pack_buttonSell:SetVisible(true);	
	else
			if(canuse)then
				self.pack_use_button:SetVisible(true)			
			elseif(canScale)then
				self.pack_buttonSell:SetVisible(true)		
			 		
			end
	end			
	

	for i,v in pairs(self.tmp) do
		if(v.itemIcon:GetUserData() == self.curSelItem)then
			v.itemIcon.item_chose:SetVisible(true)
		else
			v.itemIcon.item_chose:SetVisible(false)
		end
	
	end	
	
end


return pack