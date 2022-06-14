local redEnvelope = class( "redEnvelope", layout );

global_event.REDENVELOPE_SHOW = "REDENVELOPE_SHOW";
global_event.REDENVELOPE_HIDE = "REDENVELOPE_HIDE";
global_event.REDENVELOPE_UPDATE = "REDENVELOPE_UPDATE";



function redEnvelope:ctor( id )
	redEnvelope.super.ctor( self, id );
	self:addEvent({ name = global_event.REDENVELOPE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.REDENVELOPE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.REDENVELOPE_UPDATE, eventHandler = self.OnUpdate});
	 
end

function redEnvelope:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.redEnvelope_rank = self:Child( "redEnvelope-rank" );
	self.redEnvelope_share = self:Child( "redEnvelope-share" );
	self.redEnvelope_tixian = self:Child( "redEnvelope-tixian" );
	self.redEnvelope_day = self:Child( "redEnvelope-day" );
	self.redEnvelope_money = self:Child( "redEnvelope-money" );
	self.redEnvelope_once = self:Child( "redEnvelope-once" );
	self.redEnvelope_close = self:Child( "redEnvelope-close" );
	self.redEnvelope_yaogift_totalmoney = self:Child( "redEnvelope-yaogift-totalmoney" );
	self.redEnvelope_yaogift_shadowdown_1 = self:Child( "redEnvelope-yaogift-shadowdown_1" );
	
	
	function onClickCloseRedEnvelope()	
		self:onHide()
	end	
	self.redEnvelope_close:subscribeEvent("ButtonClick", "onClickCloseRedEnvelope")
	
	---排行榜
	function onClickCloseRedEnvelopeRank()	
			 dataManager.redEnvelopeData:sendAskShakeRank()
	end	
	self.redEnvelope_rank:subscribeEvent("ButtonClick", "onClickCloseRedEnvelopeRank")
	
	
	function onClickCloseRedEnvelopeShare()	
		dataManager.redEnvelopeData:shareToWeiXin()
	end	
	
	self.redEnvelope_share:subscribeEvent("ButtonClick", "onClickCloseRedEnvelopeShare")
	 
	function onClickCloseRedEnvelopeTiXian()	
		if(dataManager.redEnvelopeData:getNowGetMoney() > 0 ) then
			dataManager.redEnvelopeData:askTiXian()
		end
	end	
	self.redEnvelope_tixian:subscribeEvent("ButtonClick", "onClickCloseRedEnvelopeTiXian")	
	
	function onClickCloseRedEnvelopeShake()	
			redEnvelopeData_onshakeToClient()
	end	
	self.redEnvelope_yaogift_shadowdown_1:subscribeEvent("WindowTouchUp", "onClickCloseRedEnvelopeShake") 
	
	self:update()
end

function redEnvelope:update()
	if not self._show then
		return;
	end

	self.redEnvelope_day:SetText(dataManager.redEnvelopeData:getOpenDay())
	self.redEnvelope_money:SetText(dataManager.redEnvelopeData:getNowGetMoney())
	self.redEnvelope_yaogift_totalmoney:SetText("总奖金："..dataManager.redEnvelopeData:getTotalMoney())
	self.redEnvelope_once:SetText("剩余次数："..dataManager.redEnvelopeData:getCanShakeNum())
end


function redEnvelope:onGetMoney()
		 eventManager.dispatchEvent({name = global_event.REDENVELOPERESULT_SHOW})
	
end	
	
function redEnvelope:OnUpdate(event)
	self:update();
end	
	
function redEnvelope:onHide(event)
	self:Close();
	dataManager.redEnvelopeData.shakeStatus = nil
end

return redEnvelope;
