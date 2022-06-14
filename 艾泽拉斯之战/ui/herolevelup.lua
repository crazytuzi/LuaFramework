local herolevelup = class( "herolevelup", layout );

global_event.HEROLEVELUP_SHOW = "HEROLEVELUP_SHOW";
global_event.HEROLEVELUP_HIDE = "HEROLEVELUP_HIDE";

function herolevelup:ctor( id )
	herolevelup.super.ctor( self, id );
	self:addEvent({ name = global_event.HEROLEVELUP_SHOW, eventHandler = self.onShow});	
	self:addEvent({ name = global_event.HEROLEVELUP_HIDE, eventHandler = self.onHide});
end

function herolevelup:onShow(event)
	if self._show then
		return;
	end
	
	--print("--------------------------global_event.HEROLEVELUP_SHOW--------------------show ui ");
	
	self:Show();

	self.herolevelup_herolv_before = self:Child( "herolevelup-herolv-before" );
	self.herolevelup_herolv_after = self:Child( "herolevelup-herolv-after" );
	self.herolevelup_intelligence_before = self:Child( "herolevelup-intelligence-before" );
	self.herolevelup_intelligence_after = self:Child( "herolevelup-intelligence-after" );
	self.herolevelup_vigor_before = self:Child( "herolevelup-vigor-before" );
	self.herolevelup_vigor_after = self:Child( "herolevelup-vigor-after" );
	self.herolevelup_shiplv_before = self:Child( "herolevelup-shiplv-before" );
	self.herolevelup_shiplv_after = self:Child( "herolevelup-shiplv-after" );
	self.herolevelup_button = self:Child( "herolevelup-button" );
	
	self.herolevelup_charactor = self:Child( "herolevelup-charactor" );
	self.herolevelup_dialog_text = self:Child( "herolevelup-dialog-text" );
	
	
	function onClickCloseherolevelup()	
		
		local curLevel = dataManager.playerData:getLevel()	
		self.level = curLevel --self.level + 1 			
		if(self.level < curLevel ) then		
			self:upDate()
			return
		end			
		self:onHide()
	end			
	self.herolevelup_button:subscribeEvent("ButtonClick", "onClickCloseherolevelup")
	

	local preLevel = dataManager.playerData:getPreLevel()
	self.level = preLevel
	self:upDate(event)
end

function herolevelup:upDate(event)
	local config = dataConfig.configs.playerConfig[self.level]
	if not self._show  or config == nil  then
		return;
	end
	local curLevel = dataManager.playerData:getLevel()		
	
	
	
	self.herolevelup_intelligence_before:SetText(config.intelligence)	
	--self.herolevelup_vigor_before:SetText(dataManager.playerData:getVitality())	
	self.herolevelup_herolv_before:SetText(self.level)	
	self.herolevelup_shiplv_before:SetText(self.level)
	
	self.herolevelup_herolv_after:SetText("")
	self.herolevelup_vigor_after:SetText("")	
	self.herolevelup_shiplv_after:SetText("")
	self.herolevelup_intelligence_after:SetText("")
	
	local nextLevel = curLevel --- self.level + 1
	
	if(nextLevel > curLevel )then
		nextLevel = curLevel
	end
 	local maxLevel = #dataConfig.configs.playerConfig
 
	if(  nextLevel <= maxLevel   )then
		self.herolevelup_herolv_after:SetText(nextLevel)		
		local config = dataConfig.configs.playerConfig[nextLevel]
		if(config)then				
			self.herolevelup_intelligence_after:SetText(config.intelligence )	
			
			local preLevel = dataManager.playerData:getPreLevel()		
			local add = 0
			for i = preLevel + 1,nextLevel do			
				add = add + dataConfig.configs.playerConfig[i].vigorRegeneration				
			end
			
			if event.vigorIsBefore then 
				self.herolevelup_vigor_before:SetText(dataManager.playerData:getVitality());
				self.herolevelup_vigor_after:SetText(dataManager.playerData:getVitality()+add);	
			else
				self.herolevelup_vigor_before:SetText(dataManager.playerData:getVitality()-add);
				self.herolevelup_vigor_after:SetText(dataManager.playerData:getVitality());			
			end
			
			self.herolevelup_shiplv_after:SetText(nextLevel)
			
			if config.levelupTips then
				self.herolevelup_charactor:SetVisible(true);
				self.herolevelup_dialog_text:SetText(config.levelupTips);
			else
				self.herolevelup_charactor:SetVisible(false);
			end
		end			
	end		
end	


function herolevelup:onHide(event)
	self:Close();
	local level = dataManager.playerData:getLevel()
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_CLOSE_LEVELUP ,arg1 = level})
end

return herolevelup;
