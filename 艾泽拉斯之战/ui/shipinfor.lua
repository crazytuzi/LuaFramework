local shipinfor = class( "shipinfor", layout );

global_event.SHIPINFOR_SHOW = "SHIPINFOR_SHOW";
global_event.SHIPINFOR_HIDE = "SHIPINFOR_HIDE";

function shipinfor:ctor( id )
	shipinfor.super.ctor( self, id );
	self:addEvent({ name = global_event.SHIPINFOR_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SHIPINFOR_HIDE, eventHandler = self.onHide});
end

function shipinfor:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onClickShipInfoClose()
		self:onHide();
	end
	
	self.shipinfor_close = self:Child( "shipinfor-close" );
	self.shipinfor_shipnumber = LORD.toStaticImage(self:Child( "shipinfor-shipnumber" ));
	self.shipinfor_attlv_num = self:Child( "shipinfor-attlv-num" );
	self.shipinfor_deflv_num = self:Child( "shipinfor-deflv-num" );
	self.shipinfor_dog_num = self:Child( "shipinfor-dog-num" );
	self.shipinfor_ten_num = self:Child( "shipinfor-ten-num" );
	self.shipinfor_ship_lv_num = self:Child( "shipinfor-ship-lv-num" );
	self.shipinfor_soldier_num = self:Child( "shipinfor-soldier-num" );
	
	self.shipinfor_close:subscribeEvent("ButtonClick", "onClickShipInfoClose");
	
	-- update info
	self:updateShipInfo(event.shipIndex);
end

function shipinfor:onHide(event)
	self:Close();
end

function shipinfor:updateShipInfo(shipIndex)
	local shipInstance = shipData.getShipInstance(shipIndex);
	if shipInstance then
		local attackLevel = shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK);
		local defenceLevel = shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE);
		local criticalLevel = shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL);
		local resilienceLevel = shipInstance:getEquipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE);
		
		self.shipinfor_shipnumber:SetImage(shipData.shipNumberIcon[shipIndex]);
		self.shipinfor_attlv_num:SetText(attackLevel);
		self.shipinfor_deflv_num:SetText(defenceLevel);
		self.shipinfor_dog_num:SetText(criticalLevel);
		self.shipinfor_ten_num:SetText(resilienceLevel);
		
		self.shipinfor_ship_lv_num:SetText(shipInstance:getLevel());
		if shipInstance:getConfig() then
			self.shipinfor_soldier_num:SetText(shipInstance:getSoldier());
		end
		
	end
end

return shipinfor;
