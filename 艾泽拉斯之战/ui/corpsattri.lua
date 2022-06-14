local corpsattri = class( "corpsattri", layout );

global_event.CORPSATTRI_SHOW = "CORPSATTRI_SHOW";
global_event.CORPSATTRI_HIDE = "CORPSATTRI_HIDE";

function corpsattri:ctor( id )
	corpsattri.super.ctor( self, id );
	self:addEvent({ name = global_event.CORPSATTRI_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CORPSATTRI_HIDE, eventHandler = self.onHide});
end

function corpsattri:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.corpsattri__range_num = self:Child( "corpsattri--range-num" );
	self.corpsattri_att_num = self:Child( "corpsattri-att-num" );
	self.corpsattri_def_num = self:Child( "corpsattri-def-num" );
	self.corpsattri_hit_num = self:Child( "corpsattri-hit-num" );
	self.corpsattri_speed_num = self:Child( "corpsattri-speed-num" );
	self.corpsattri_move_num = self:Child( "corpsattri-move-num" );
	self.corpsattri_attlv_num = self:Child( "corpsattri-attlv-num" );
	self.corpsattri_deflv_num = self:Child( "corpsattri-deflv-num" );
	self.corpsattri_crit_num = self:Child( "corpsattri-crit-num" );
	self.corpsattri_ten_num = self:Child( "corpsattri-ten-num" );
	
	self.corpsattri_style1 = LORD.toStaticImage(self:Child("corpsattri-style1"));
	self.corpsattri_style2 = LORD.toStaticImage(self:Child("corpsattri-style2"));
	self.corpsattri_style3 = LORD.toStaticImage(self:Child("corpsattri-style3"));
	
	self:initInfo(event);
	
	local size = self._view:GetPixelSize();
		
	self._view:SetXPosition(LORD.UDim(0, event.posX - size.x));
	
	local y = event.posY;
	
	if event.posY + size.y > engine.rootUiSize.h then
		y = engine.rootUiSize.h - size.y - 5;
	end
	
	self._view:SetYPosition(LORD.UDim(0, y));
	
end

function corpsattri:onHide(event)
	self:Close();
end

function corpsattri:initInfo(event)
	local unitInfo = dataConfig.configs.unitConfig[event.unitID];
	self.corpsattri__range_num:SetText(unitInfo.attackRange);
	self.corpsattri_att_num:SetText(unitInfo.soldierDamage);
	self.corpsattri_def_num:SetText(unitInfo.defence);
	self.corpsattri_hit_num:SetText(unitInfo.soldierHP);
	self.corpsattri_speed_num:SetText(unitInfo.actionSpeed);
	self.corpsattri_move_num:SetText(unitInfo.moveRange);

	self.corpsattri_attlv_num:SetText(event.shipAttr.attack);
	self.corpsattri_deflv_num:SetText(event.shipAttr.defence);
	self.corpsattri_crit_num:SetText(event.shipAttr.critical);
	self.corpsattri_ten_num:SetText(event.shipAttr.resilience);
	
	local isRange = 0;
	if unitInfo.isRange == true then
		isRange = 1;
	end
	
	self.corpsattri_style1:SetImage(enum.unitIsRangeImageMap[isRange]);
	self.corpsattri_style2:SetImage(enum.unitDamageTypeImageMap[unitInfo.damageType]);
	self.corpsattri_style3:SetImage(enum.unitMoveTypeImageMap[unitInfo.moveType]);
	
end

return corpsattri;
