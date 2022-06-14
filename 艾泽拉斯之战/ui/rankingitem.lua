local rankingitem = class( "rankingitem", layout );

global_event.RANKINGITEM_SHOW = "RANKINGITEM_SHOW";
global_event.RANKINGITEM_HIDE = "RANKINGITEM_HIDE";

function rankingitem:ctor( id )
	rankingitem.super.ctor( self, id );
	self:addEvent({ name = global_event.RANKINGITEM_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.RANKINGITEM_HIDE, eventHandler = self.onHide});
end

function rankingitem:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	 
	self.rankingitem_head = LORD.toStaticImage(self:Child( "rankingitem-head" ));
	self.rankingitem_head_image = LORD.toStaticImage(self:Child( "rankingitem-head-image" ));
	self.rankingitem_lv_num = self:Child( "rankingitem-lv-num" );
	self.rankingitem_name = self:Child( "rankingitem-name" );
end

function rankingitem:onHide(event)
	self:Close();
end

return rankingitem;
