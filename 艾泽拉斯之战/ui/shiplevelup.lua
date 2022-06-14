local shiplevelup = class( "shiplevelup", layout );

global_event.SHIPLEVELUP_SHOW = "SHIPLEVELUP_SHOW";
global_event.SHIPLEVELUP_HIDE = "SHIPLEVELUP_HIDE";
global_event.SHIPLEVELUP_UPDATE = "SHIPLEVELUP_UPDATE";

function shiplevelup:ctor( id )
	shiplevelup.super.ctor( self, id );
	self:addEvent({ name = global_event.SHIPLEVELUP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SHIPLEVELUP_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.SHIPLEVELUP_UPDATE, eventHandler = self.updateAllInfo});
end

function shiplevelup:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.shiplevelup_shengjiqian_lv_num = self:Child( "shiplevelup-shengjiqian-lv-num" );
	self.shiplevelup_shengjiqian_renkou_num = self:Child( "shiplevelup-shengjiqian-renkou-num" );
	self.shiplevelup_shengjihou_lv_num = self:Child( "shiplevelup-shengjihou-lv-num" );
	self.shiplevelup_shengjihou_renkou_num = self:Child( "shiplevelup-shengjihou-renkou-num" );
	self.shiplevelup_jianzao = self:Child( "shiplevelup-jianzao" );
	self.shiplevelup_quxiao = self:Child( "shiplevelup-quxiao" );
	
	self.shiplevelup_jianzao:subscribeEvent("ButtonClick", "onClickLevelUp");
	self.shiplevelup_quxiao:subscribeEvent("ButtonClick", "onClickCancel");
	self.shipIndex = event.shipIndex;
	
	-- 玩家头像
	self.shiplevelup_herolv_touxiang = LORD.toStaticImage(self:Child("shiplevelup-herolv-touxiang"));
	-- 等级
	self.shiplevelup_herolv_num = self:Child("shiplevelup-herolv-num");
	-- 金币
	self.shiplevelup_jinbi_num = self:Child("shiplevelup-jinbi-num");
	--木材
	self.shiplevelup_mucai_num = self:Child("shiplevelup-mucai-num");
	
	-- 升级道具
	self.shiplevelup_wupin_item = {};
	self.shiplevelup_wupin_num = {};
	for i=1, 3 do
		self.shiplevelup_wupin_item[i] = LORD.toStaticImage(self:Child("shiplevelup-wupin"..i.."-item"));
		self.shiplevelup_wupin_num[i] = self:Child("shiplevelup-wupin"..i.."-num");
	end
	
	self:updateAllInfo();
	
	function onClickLevelUp()
		self:onLevelUp();
	end
	
	function onClickCancel()
		self:onCancel();
	end
	
end

function shiplevelup:onHide(event)
	if not self._show then
		return;
	end
		
	self:Close();
end

function shiplevelup:onLevelUp()
	
	local ship = shipData.getShipInstance(self.shipIndex);
	
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
	
	sendShipUpgrade(self.shipIndex-1);
	
end

function shiplevelup:onCancel()
	self:onHide();
end

function shiplevelup:updateAllInfo()
	
	if not self._show then
		return;
	end
	
	local ship = shipData.getShipInstance(self.shipIndex);
	if ship and ship.level > 0 then
		local shipNowInfo = dataConfig.configs.shipConfig[ship.level];
		local shipNextInfo = dataConfig.configs.shipConfig[ship.level+1];
		
		self.shiplevelup_shengjiqian_lv_num:SetText(ship.level);
		self.shiplevelup_shengjiqian_renkou_num:SetText(ship:getSoldier());
		
		if shipNextInfo then
			self.shiplevelup_shengjihou_lv_num:SetText(ship.level+1);
			self.shiplevelup_shengjihou_renkou_num:SetText(ship:getSoldier(ship.level+1));		
			
			local needLevel = shipNowInfo.id + 1;
			local needGold = shipNowInfo.money;
			local needWood = shipNowInfo.wood;
			
			local redColor = "^FF0000";
			
			if not ship:isEnoughPlayerLevel() then
				self.shiplevelup_herolv_num:SetText(redColor..needLevel);
			else
				self.shiplevelup_herolv_num:SetText(needLevel);
			end
			
			-- 金币
			if not ship:isEnoughGood() then
				self.shiplevelup_jinbi_num:SetText(redColor..needGold);
			else
				self.shiplevelup_jinbi_num:SetText(needGold);
			end
			
			-- 木材
			if not ship:isEnoughWood() then
				self.shiplevelup_mucai_num:SetText(redColor..needWood);
			else
				self.shiplevelup_mucai_num:SetText(needWood);
			end
			
			-- 升级道具
			local needItem = shipNowInfo.requireItem;
			local needItemCount = shipNowInfo.retuireItemCount;
			
			for i=1, 3 do
				local itemInfo = itemManager.getConfig(needItem[i]);
				if itemInfo then
					local itemCount = dataManager.bagData:getItemNums(enum.BAG_TYPE.BAG_TYPE_BAG, needItem[i]);
					local needItemCount = needItemCount[i];
					self.shiplevelup_wupin_item[i]:SetImage(itemInfo.icon);
					if itemCount < needItemCount then
						self.shiplevelup_wupin_num[i]:SetText(redColor..itemCount.."/"..needItemCount);
						self.shiplevelup_wupin_item[i]:SetEnabled(false);
					else
						self.shiplevelup_wupin_num[i]:SetText(itemCount.."/"..needItemCount);
						self.shiplevelup_wupin_item[i]:SetEnabled(true);
					end
				else
					-- 没有道具的隐藏
					self.shiplevelup_wupin_num[i]:SetText("");
					self.shiplevelup_wupin_item[i]:SetImage("");
				end

			end
		else
			-- 已经满级了
			self.shiplevelup_jianzao:SetEnabled(false);
			
			self.shiplevelup_shengjihou_lv_num:SetText("");
			self.shiplevelup_shengjihou_renkou_num:SetText("");		

			self.shiplevelup_herolv_num:SetText("");
			self.shiplevelup_jinbi_num:SetText("");
			self.shiplevelup_mucai_num:SetText("");

			for i=1, 3 do
				self.shiplevelup_wupin_num[i]:SetText("");
				self.shiplevelup_wupin_item[i]:SetImage("");
			end
			
			
		end
	end
end

return shiplevelup;
