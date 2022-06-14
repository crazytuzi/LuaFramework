local shipremould = class( "shipremould", layout );

global_event.SHIPREMOULD_SHOW = "SHIPREMOULD_SHOW";
global_event.SHIPREMOULD_HIDE = "SHIPREMOULD_HIDE";
global_event.SHIPREMOULD_UPDATE = "SHIPREMOULD_UPDATE";

function shipremould:ctor( id )
	shipremould.super.ctor( self, id );
	self:addEvent({ name = global_event.SHIPREMOULD_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SHIPREMOULD_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.SHIPREMOULD_UPDATE, eventHandler = self.update});
end

function shipremould:onShow(event)
	if self._show then
		return;
	end

	self.shipIndex = event.shipIndex;
	
	self:Show();
	
	self.shipremould_wupin = {};
	self.shipremould_wupin_item = {};
	self.shipremould_wupin_num = {};
	
	function onClickShipRemouldItem(args)
		local window = (LORD.toWindowEventArgs(args)).window;
		local userdata = window:GetUserData();
		
		print(userdata);
		eventManager.dispatchEvent({name = global_event.ITEMACQUIRE_SHOW,_type = "item",selTableId = userdata });
	end
	
	for i=1, 3 do
		self.shipremould_wupin[i] = LORD.toStaticImage(self:Child( "shipremould-wupin"..i ));
		self.shipremould_wupin_item[i] = LORD.toStaticImage(self:Child( "shipremould-wupin"..i.."-item" ));
		self.shipremould_wupin_num[i] = self:Child( "shipremould-wupin"..i.."-num" );
		
		self.shipremould_wupin_item[i]:subscribeEvent("WindowTouchUp", "onClickShipRemouldItem");
		
	end
	
	self.shipremould_shengjiqiaoguo = self:Child( "shipremould-shengjiqiaoguo" );
	self.shipremould_shengjiqian_lv_num = self:Child( "shipremould-shengjiqian-lv-num" );
	self.shipremould_shengjiqian_renkou_num = self:Child( "shipremould-shengjiqian-renkou-num" );
	self.shipremould_shengjihou_lv_num = self:Child( "shipremould-shengjihou-lv-num" );
	self.shipremould_shengjihou_renkou_num = self:Child( "shipremould-shengjihou-renkou-num" );
	self.shipremould_jianzao = self:Child( "shipremould-jianzao" );
	self.shipremould_quxiao = self:Child( "shipremould-quxiao" );
	
	function onClickShipRemouldOK()
		sendShipRemould(self.shipIndex-1);
		self.shipremould_jianzao:SetEnabled(false);
	end
	
	function onClickShipRemouldCancel()
		self:onHide();
	end
	
	self.shipremould_jianzao:subscribeEvent("ButtonClick", "onClickShipRemouldOK");
	self.shipremould_quxiao:subscribeEvent("ButtonClick", "onClickShipRemouldCancel");
	
	self:update(event);
end

function shipremould:onHide(event)
	self:Close();
end

function shipremould:update(event)
	
	if not self._show then
		return;
	end
	
	self.shipremould_jianzao:SetEnabled(true);
	
	local shipInstance = shipData.getShipInstance(event.shipIndex);
	if shipInstance then

		-- 改装道具
		local needItem = shipInstance:getRemouldConfig().requireItem;
		local needItemCount = shipInstance:getRemouldConfig().retuireItemCount;
		local enoughItem = true;
		
		for i=1, 3 do
			local itemInfo = itemManager.getConfig(needItem[i]);
			if itemInfo then
				local itemCount = dataManager.bagData:getItemNums(enum.BAG_TYPE.BAG_TYPE_BAG, needItem[i]);
				local needItemCount = needItemCount[i];
				
				self.shipremould_wupin[i]:SetImage(itemManager.getImageWithStar(itemInfo.star));
				
				self.shipremould_wupin_item[i]:SetImage(itemInfo.icon);
				if itemCount < needItemCount then
					self.shipremould_wupin_num[i]:SetText("^FF0000"..itemCount.."/"..needItemCount);
					self.shipremould_wupin_item[i]:SetEnabled(true);
					enoughItem = false;
				else
					self.shipremould_wupin_num[i]:SetText(itemCount.."/"..needItemCount);
					self.shipremould_wupin_item[i]:SetEnabled(true);
				end
				
				self.shipremould_wupin_item[i]:SetUserData(needItem[i]);
				global.onItemTipsShow(self.shipremould_wupin_item[i], enum.REWARD_TYPE.REWARD_TYPE_ITEM, "top");
				global.onItemTipsHide(self.shipremould_wupin_item[i]);
				
				
			else
				-- 没有道具的隐藏
				self.shipremould_wupin_num[i]:SetText("");
				self.shipremould_wupin_item[i]:SetImage("");
			end
		end
		
		if not shipInstance:isMaxRemouldLevel() then
			
			self.shipremould_shengjiqiaoguo:SetVisible(true);
			self.shipremould_jianzao:SetEnabled(enoughItem);
			self.shipremould_shengjiqian_lv_num:SetText(shipInstance:getRemouldLevel());
			self.shipremould_shengjihou_lv_num:SetText(shipInstance:getRemouldLevel()+1);
			
			self.shipremould_shengjiqian_renkou_num:SetText(shipInstance:getRemouldConfig().soldier);
			self.shipremould_shengjihou_renkou_num:SetText(shipInstance:getRemouldConfig(shipInstance:getRemouldLevel()+1).soldier);

		else
			self.shipremould_shengjiqiaoguo:SetVisible(false);
			self.shipremould_jianzao:SetEnabled(false);
			
			self:onHide();
		end
	end
end

return shipremould;
