local itemacquire = class( "itemacquire", layout );

global_event.ITEMACQUIRE_SHOW = "ITEMACQUIRE_SHOW";
global_event.ITEMACQUIRE_HIDE = "ITEMACQUIRE_HIDE";

function itemacquire:ctor( id )
	itemacquire.super.ctor( self, id );
	self:addEvent({ name = global_event.ITEMACQUIRE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ITEMACQUIRE_HIDE, eventHandler = self.onHide});
end

function itemacquire:isItem()
	if(self._type == "item")then
		return true
	else
		return false
	end
end
function itemacquire:onShow(event)
	
	self._type = event._type
	self.selId = event.selId	
	
	self.event = event;
	
	if(event.selTableId	)then
		 self.item = itemManager.createItem(event.selTableId)
		 if(self.item)then
			self.selId =  self.item:getIndex()
		 end
	end	
	
	if self._show then
		return;
	end

	self:Show();
	
	function onitemacquire_TouchDown1(args)
		local clickImage = LORD.toWindowEventArgs(args).window		
 		local userdata = clickImage:GetUserData()	
		--self.itemacquire_item1_chose:SetVisible(true)	
		--self.itemacquire_item2_chose:SetVisible(false)			
		 if(userdata == -1)then return end
		 if(self:isItem())then
		  self.SelItem =  userdata
		  self:updateSelItem()
		 end
	end	
	
	function onitemacquire_TouchDown2(args)
		 local clickImage = LORD.toWindowEventArgs(args).window		
 		 local userdata = clickImage:GetUserData()
		 --self.itemacquire_item1_chose:SetVisible(false)	
		 --self.itemacquire_item2_chose:SetVisible(true)	
		 if(userdata == -1)then return end
		 if(self:isItem())then
		  self.SelItem =  userdata
		  self:updateSelItem()
		 end
	end	
	
	
	self.itemacquire_item1_back = LORD.toStaticImage(self:Child( "itemacquire-item1-back" ));
	self.itemacquire_item1_star = LORD.toStaticImage(self:Child( "itemacquire-item1" ));
	self.itemacquire_item2_star  = LORD.toStaticImage(self:Child( "itemacquire-item2" ));
	
	self.itemacquire_item1_image = LORD.toStaticImage(self:Child( "itemacquire-item1-image" ));
	self.itemacquire_item2_image = LORD.toStaticImage(self:Child( "itemacquire-item2-image" ));
	self.itemacquire_item1_image:subscribeEvent("WindowTouchDown", "onitemacquire_TouchDown1")
	self.itemacquire_item2_image:subscribeEvent("WindowTouchDown", "onitemacquire_TouchDown2")
	
	self.itemacquire_item1_chose = LORD.toStaticImage(self:Child( "itemacquire-item1-chose" ));
	self.itemacquire_item2_chose = LORD.toStaticImage(self:Child( "itemacquire-item2-chose" ));
	self.itemacquire_item1_chose:SetVisible(false)	
	self.itemacquire_item2_chose:SetVisible(false)	
		
	self.itemacquire_item2 = LORD.toStaticImage(self:Child( "itemacquire-item2-back" ));
	
	self.itemacquire_arrow = LORD.toStaticImage(self:Child( "itemacquire-arrow" ));
	self.itemacquire_name = self:Child( "itemacquire-name" );
	
	self.itemacquire_way ={}
	self.itemacquire_way_chapter = {}
	self.itemacquire_way_mode = {}
	self.itemacquire_way_unable = {}
	self.itemacquire_way_name = {}
	self.itemacquire_time = {}
	self.itemacquire_star = {}
	self.itemacquire_stageIndex = {}
		
	function on_itemacquire_way_click(args)
		 local clickImage = LORD.toWindowEventArgs(args).window		
 		 local userdata = clickImage:GetUserData()
		 local stage = self.getPath[userdata]
		
		if(not stage:isEnable())then
			--[[	eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
				textInfo = "关卡未开启" });
			return	
			--]]
			return
		else
			
			eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_CLOSE });
			
			if self.event.source == "instance" then
				instanceScene.__stage = stage;
				eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_UPDATE,})
			else
				eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW,stage = stage});		
			end
		end
		 self:onHide()
	end	
	
	for i =1 ,3 do
		self.itemacquire_way[i] =  LORD.toStaticImage(self:Child( "itemacquire-way"..i ));
		self.itemacquire_way[i]:subscribeEvent("WindowTouchDown", "on_itemacquire_way_click");	
		self.itemacquire_way_chapter[i] = self:Child( "itemacquire-way"..i.."-chapter" );
		self.itemacquire_way_mode[i] = self:Child( "itemacquire-way"..i.."-mode" );
		self.itemacquire_way_unable[i] = self:Child( "itemacquire-way"..i.."-unable" );
		self.itemacquire_way_name[i] = self:Child( "itemacquire-way"..i.."-name" );
		self.itemacquire_time[i] = self:Child( "itemacquire-time"..i );
		self.itemacquire_star[i] = self.itemacquire_star[i] or {}		
		self.itemacquire_stageIndex[i] =  LORD.toStaticImage(self:Child( "itemacquire-way"..i.."-intance-num" ));
		 
		 for k =1 ,3 do
			self.itemacquire_star[i][k] = LORD.toStaticImage(self:Child( "itemacquire-way"..i.."-star"..k ));			
		 end			
	end			
	self.itemacquire_close = self:Child( "itemacquire-close" );	
	self.itemacquire_nogetwaytip = self:Child( "itemacquire-nogetwaytip" );		
	self.itemacquire_nogetwaytip:SetVisible(true)	
	
	function on_itemacquire_close_click()
		self:onHide()
	end	
	self.itemacquire_close:subscribeEvent("ButtonClick", "on_itemacquire_close_click");	
	
	self:upDate()
end

function itemacquire:upDate()
	 local isItem = self:isItem()
	 if(isItem)	then
		self:updateItem()
	 else
		self:updateCrops()	
	 end		
end

function itemacquire:updateItem()
	
	local item = itemManager.getItem(self.selId) 	
	if(item == nil)then
		return 
	end	
	local isisDebris =  item:isDebris()
	
	self.itemacquire_item2:SetVisible(isisDebris)
	self.itemacquire_arrow:SetVisible(isisDebris)
	self.itemacquire_item1_image:SetImage(item:getIcon())
	global.setMaskIcon(self.itemacquire_item1_image, item:getMaskIcon());
	
	self.itemacquire_name:SetText(item:getName())	--getName
	self.itemacquire_item1_image:SetUserData(item:getId())  -- table id
	
	self.itemacquire_item1_star:SetImage(item:getImageWithStar(isisDebris))
	self.SelItem =  item:getId()
	local y = self.itemacquire_item1_back:GetPosition().y
	self.itemacquire_item1_back:SetPosition(LORD.UVector2(LORD.UDim(0, 25), y ));
	self.itemacquire_item1_back:SetImage(itemManager.getBackImage(isisDebris))
	self.itemacquire_item2:SetImage(itemManager.getBackImage( not isisDebris))
	if(isisDebris)then
		local pId,count = item:getProduct()
		local config = itemManager.getConfig(pId)
		if(config)then
			self.itemacquire_item2_image:SetImage(config.icon)
			self.itemacquire_item2_image:SetUserData(pId)
			self.itemacquire_item2_star:SetImage(itemManager.getImageWithStar(config.star,not isisDebris))
		else
			self.itemacquire_item2_image:SetImage("")	
			self.itemacquire_item2_star:SetImage(itemManager.getImageWithStar(0,not isisDebris))
		end		
		self.itemacquire_arrow:SetProperty("RotateY",0)		
	else
		
		--遍历碎片表格 找到合成本物品的碎片id
		local t =	dataConfig.configs.debrisConfig
		local find = -1
		for i,v in pairs(t) do
			if(v.productID == item:getId())then
				find = v.id
				break
			end				
		end
		local ifind = -1
		for i,v in pairs(dataConfig.configs.itemConfig) do
			if(v.subID == find and v.type ==  enum.ITEM_TYPE.ITEM_TYPE_DEBRIS)then
				ifind = i
				break;
		 	 	
			end
		end
		
		local config = itemManager.getConfig(ifind)
		if(config and  string.find( config.name, 'GM') == nil)then
			self.itemacquire_item2:SetVisible(true)
			self.itemacquire_arrow:SetVisible(true)
			
			self.itemacquire_item2_image:SetImage(config.icon)
			global.setMaskIcon(self.itemacquire_item2_image, itemManager.getMaskIcon(true));			
			
			self.itemacquire_item2_star:SetImage(itemManager.getImageWithStar(0,true))
			 
			self.itemacquire_item2_image:SetUserData(find)
			
			self.itemacquire_arrow:SetProperty("Rotate",180)	
		else
			self.itemacquire_item2:SetVisible(false)
			self.itemacquire_arrow:SetVisible(false)
			self.itemacquire_item2_image:SetUserData(-1)	
			local y = self.itemacquire_item1_back:GetPosition().y
			self.itemacquire_item1_back:SetPosition(LORD.UVector2(LORD.UDim(0, 159), y ));
			
			
		end			
	end		
	self:updateSelItem()
	
end	


function itemacquire:_calcGetPath(_type,id)
		self.getPath = {}	
		function _calc(mode,randomOrNormal)		
			if(#self.getPath>=3)then
				return
			end
			local zones = dataManager.instanceZonesData	
			local chapter = dataManager.instanceZonesData:getAllChapter() 	
			for i, v in ipairs (chapter) do
				local Adventure = v:getAdventure()			
				for i =1,#Adventure do  	
						local stage = zones:getStageWithAdventureID(Adventure[i],mode)
						if(stage:isExitReward(randomOrNormal,_type,id) )then
							table.insert(self.getPath,stage)
						end	
				end
			end
		end			
		_calc(enum.Adventure_TYPE.NORMAL,1)
		_calc(enum.Adventure_TYPE.ELITE,1)
		_calc(enum.Adventure_TYPE.NORMAL,2)
		_calc(enum.Adventure_TYPE.ELITE,2)	
	local num = 	#self.getPath 	
	if(num >3)then  num = 3 end	
	for i = 1 ,3 do	
		self.itemacquire_way[i]:SetVisible(num >= i)				
	end	
	for i = 1 ,num do		
		local stage = self.getPath[i]
		local chapter = stage:getChapter()
		self.itemacquire_way_chapter[i]:SetText(chapter:getName())
		if(stage:getType() == enum.Adventure_TYPE.ELITE )then
			self.itemacquire_way_mode[i]:SetText("精英")
		else
			self.itemacquire_way_mode[i]:SetText("")
		end
		self.itemacquire_way[i]:SetUserData(i)  
		self.itemacquire_way_name[i]:SetText(stage:getName())
		
		local maxCanBattle = stage:getMaxCanBattleNum()
		local canBattleNum = (maxCanBattle - stage:getBattleNum())
		if canBattleNum == 0 then
			self.itemacquire_time[i]:SetText( "^FF0000"..canBattleNum.."^FFFFFF/"..maxCanBattle) 
		else
			self.itemacquire_time[i]:SetText( canBattleNum.."/"..maxCanBattle) 
		end		
		
		if(not stage:isEnable())then
			self.itemacquire_way_unable[i]:SetText("未开启")
			self.itemacquire_time[i]:SetText("")
		else
			self.itemacquire_way_unable[i]:SetText("")
		end	
		self.itemacquire_stageIndex[i]:SetText(chapter:getId().."-"..(stage:getAdventureShowIndex()) )
		local star = stage:getVisStarNum()
		for k = 1, 3 do	
			self.itemacquire_star[i][k]:SetVisible(k <= star) 
		end

		
	end		
	if(num <= 0)then
		self.itemacquire_nogetwaytip:SetText("     物品暂无关卡产出")
	else
		self.itemacquire_nogetwaytip:SetText("")
		 
	end	
			
end	

function itemacquire:updateSelItem()
 
		local config = itemManager.getConfig(self.SelItem)
		self.itemacquire_name:SetText(config.name)
		self:_calcGetPath( enum.REWARD_TYPE.REWARD_TYPE_ITEM,self.SelItem)	
		
		--REWARD_TYPE_ITEM = 0,	--物品
 
		--REWARD_TYPE_CARD_EXP = 2,--点数	
		local item = itemManager.getItem(self.selId) 		
		if(item:getId() == self.SelItem )then
			self.itemacquire_item1_chose:SetVisible(true)	
			self.itemacquire_item2_chose:SetVisible(false)	
		else
			self.itemacquire_item1_chose:SetVisible(false)	
			self.itemacquire_item2_chose:SetVisible(true)
		end		
			
end	
 



 

function itemacquire:updateCrops()
	
	local cardInstance = cardData.getCardInstance(self.selId);
	local unitID = cardInstance.unitID;	
	local unitInfo = dataConfig.configs.unitConfig[unitID];	
	self.itemacquire_item2:SetVisible(false)
	self.itemacquire_arrow:SetVisible(false)	
	self.itemacquire_item2_image:SetUserData(-1)
	if unitInfo then	
		self.itemacquire_name:SetText(unitInfo.name.."碎片");
		self.itemacquire_item1_image:SetImage(unitInfo.icon)
		global.setMaskIcon(self.itemacquire_item1_image, itemManager.getMaskIcon(true));		
	end			
	self:_calcGetPath( enum.REWARD_TYPE.REWARD_TYPE_CARD_EXP,self.selId)	
	 
	self.itemacquire_item1_chose:SetVisible(true)	
    self.itemacquire_item2_chose:SetVisible(false)	
	
	local y = self.itemacquire_item1_back:GetPosition().y
	self.itemacquire_item1_back:SetPosition(LORD.UVector2(LORD.UDim(0, 159), y ));
	
	self.itemacquire_item1_back:SetImage(itemManager.getBackImage(true))
	self.itemacquire_item1_star:SetImage(itemManager.getImageWithStar(0,true))
end	



function itemacquire:onHide(event)
	self:Close();
	if(self.item)then
		itemManager.destroyItem(self.item:getIndex())	
	end
end

return itemacquire;
