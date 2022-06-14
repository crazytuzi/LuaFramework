local heroname = class( "heroname", layout );

global_event.HERONAME_SHOW = "HERONAME_SHOW";
global_event.HERONAME_HIDE = "HERONAME_HIDE";

function heroname:ctor( id )
	heroname.super.ctor( self, id );
	self:addEvent({ name = global_event.HERONAME_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.HERONAME_HIDE, eventHandler = self.onHide});
end

function heroname:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.heroname_input_account = self:Child( "heroname-input-account" );
	self.heroname_rondom = self:Child( "heroname-rondom" );
	
	self.heroname_confirm = self:Child( "heroname-confirm" );
	self.heroname_cancel = self:Child( "heroname-cancel" );
	self.heroname_tip = self:Child( "heroname-tip" );
	
	 local changeNum = dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_CHANGE_NAME_TIMES )
	 self.heroname_tip:SetVisible(changeNum <=0)  
		
	function onClickCloseHeroname()
		self:onHide()		
	end
		
	self.heroname_cancel:subscribeEvent("ButtonClick", "onClickCloseHeroname")	  
	
	
	function onClickSureHeroname()
		
		self.name = self.heroname_input_account:GetText()
		if(self.name and self.name ~= "" )then
		
			if(math.getStrByte(self.name) > PLAYER_NAME_MAX_SIZE)then
				eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo ="名字过长" });
				return
			end
			if( global.hasfilterText(self.name))then
				eventManager.dispatchEvent({name = global_event.TIP_INFO_SHOW,tip = "名称中包含不当内容，请重新输入！"});			
				return
			end
			
			function heroname_gotoChangeName()
					if(self.name)then
						sendChangeName(self.name)
					end
			end			
				
		    local changeNum = dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_CHANGE_NAME_TIMES )
			if(changeNum >=1 )then
			local cost  = dataConfig.configs.ConfigConfig[0].pvpOfflineResetTimes
					eventManager.dispatchEvent({name = global_event.NOTICEDIAMOND_SHOW, 
								messageType = enum.MESSAGE_DIAMOND_TYPE.CHANGENAME, data = { count = dataConfig.configs.ConfigConfig[0].renameCost ,func =  heroname_gotoChangeName }, 
								textInfo = "" });	
			else
				heroname_gotoChangeName()
			end
			---self:onHide()	
		end
	end
	
	self.heroname_confirm:subscribeEvent("ButtonClick", "onClickSureHeroname")	  
	
	function onClickRandomHeroname()
		self.name = global.randomPlayerName(true)
		self.heroname_input_account:SetText(self.name )
	
	end
	
	self.heroname_rondom:subscribeEvent("ButtonClick", "onClickRandomHeroname")	  
	
end

function heroname:onHide(event)
	self:Close();
	self.name  = nil
end

return heroname;
