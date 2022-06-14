local rewardguide = class( "rewardguide", layout );

global_event.REWARDGUIDE_SHOW = "REWARDGUIDE_SHOW";
global_event.REWARDGUIDE_HIDE = "REWARDGUIDE_HIDE";

function rewardguide:ctor( id )
	rewardguide.super.ctor( self, id );
	self:addEvent({ name = global_event.REWARDGUIDE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.REWARDGUIDE_HIDE, eventHandler = self.onHide});
end

function rewardguide:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	self.rewardguide_skill_item = {}
	self.rewardguide_skill_item_dw = {}
	
	self.rewardguide_text1 = self:Child( "rewardguide-text1" );
	self.rewardguide_text2 = self:Child( "rewardguide-text2" );
	self.rewardguide_skill_item[1] = LORD.toStaticImage(self:Child( "rewardguide-skill1-image" ));
	self.rewardguide_skill_item[2]  = LORD.toStaticImage(self:Child( "rewardguide-skill2-image" ));
	self.rewardguide_skill_item[3]  = LORD.toStaticImage(self:Child( "rewardguide-skill3-image" ));
	
	
	self.rewardguide_skill_item_dw[1] = LORD.toStaticImage(self:Child( "rewardguide-skill1" ));
	self.rewardguide_skill_item_dw[2]  = LORD.toStaticImage(self:Child( "rewardguide-skill2" ));
	self.rewardguide_skill_item_dw[3]  = LORD.toStaticImage(self:Child( "rewardguide-skill3" ));
	
 
	self.rewardguide_actor = LORD.toActorWindow(self:Child( "rewardguide-actor" ));
	self.rewardguide_title_name = self:Child( "rewardguide-title-name" );
	self.rewardguide_close = self:Child( "rewardguide-close" );
	
	local unitID = event.unitID or 1
	local text = event.text or ""
	self.callFun = event.func
	local unitInfo = dataConfig.configs.unitConfig[unitID];
	if( not unitID)then
		return 
	end
	
	self.rewardguide_text1:SetText(text);
	local text2 = "--"..unitInfo.name
	self.rewardguide_text2:SetText(text2);
	self.rewardguide_title_name:SetText(unitInfo.name);
	
	self.rewardguide_actor:SetActor(unitInfo.resourceName,"idle");
	self.rewardguide_actor:SetRotateX(10);
	self.rewardguide_actor:SetRotateY(50);
	self.rewardguide_actor:SetRotateZ(0);
 
		for i=1, 3 do
			if unitInfo.skill[i] then
				self.rewardguide_skill_item[i]:SetVisible(true);
				self.rewardguide_skill_item[i]:SetVisible(true);
				local skillInfo = dataConfig.configs.skillConfig[unitInfo.skill[i]];
				if skillInfo then
					self.rewardguide_skill_item[i]:SetImage(skillInfo.icon);
					self.rewardguide_skill_item[i]:SetUserData(skillInfo.id);
					self.rewardguide_skill_item_dw[i]:SetVisible(true); 
					
					global.onSkillTipsShow(self.rewardguide_skill_item[i], "skill", "top");
					global.onTipsHide(self.rewardguide_skill_item[i]);
					
				end
			else
				self.rewardguide_skill_item_dw[i]:SetVisible(false); 
			end
		end	
	
	
	
	
	
	
	
	
	
	
	
	
	function rewardguideClose()
		self:onHide()
			if(	self.callFun)then
				self.callFun()
			end
	end
	
	self.rewardguide_close:subscribeEvent("ButtonClick", "rewardguideClose");
	
	
end

function rewardguide:onHide(event)
	self:Close();
end

return rewardguide;
