local skillget = class( "skillget", layout );

global_event.SKILLGET_SHOW = "SKILLGET_SHOW";
global_event.SKILLGET_HIDE = "SKILLGET_HIDE";

function skillget:ctor( id )
	skillget.super.ctor( self, id );
	self:addEvent({ name = global_event.SKILLGET_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SKILLGET_HIDE, eventHandler = self.onHide});
end

function skillget:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.skillget_name = self:Child( "skillget-name" );
	self.skillget_tu = LORD.toStaticImage(self:Child( "skillget-tu" ));
	self.skillget_skill1_new = LORD.toStaticImage(self:Child( "skillget-skill1-new" ));
	self.skillget_suipiannum = self:Child( "skillget-suipiannum" );
	self.skillget_star = {};
	for i=1, 3 do
		self.skillget_star[i] = LORD.toStaticImage(self:Child( "skillget-star"..i ));
	end
	self.skillget_button = self:Child( "skillget-button" );
	self.skillget_button:subscribeEvent( "ButtonClick", "onskillgetClickGain" );
	
	self.skillget_expnum = self:Child( "skillget-expnum" );
	
	-- 更新信息
	local chooseData = event.chooseData;
	local overflowExp = event.exp;
	
	local magicInstance = dataManager.kingMagic:getMagic(chooseData.id);
	local magicInfo = dataConfig.configs.magicConfig[chooseData.id];
	
	if magicInfo and magicInstance then
		self.skillget_name:SetText(magicInfo.name);
		self.skillget_tu:SetImage(magicInfo.icon);
		
		local magicExp = magicInstance:getExp();
		if magicExp > 0 then
			self.skillget_skill1_new:SetVisible(false);
		else
			self.skillget_skill1_new:SetVisible(true);
		end
		
		if overflowExp > 0 then
			self.skillget_suipiannum:SetText("+"..overflowExp);
		else
			self.skillget_suipiannum:SetText(0);
		end
		
		-- 星级
		for k = 1, 3 do
			if k <= chooseData.star then
				self.skillget_star[k]:SetVisible(true);
			else
				self.skillget_star[k]:SetVisible(false);
			end
		end
		
		-- 增加的经验
		local configInfo = dataConfig.configs.ConfigConfig[0].magicLevelExp;
		local addExp = configInfo[chooseData.star];
		if addExp + magicExp > configInfo[#configInfo] then
			addExp = configInfo[#configInfo] - magicExp;
		end
		
		self.skillget_expnum:SetText("+"..addExp);
	end
			
	function onskillgetClickGain()
		self:onHide();
	end
end

function skillget:onHide(event)
	self:Close();
end

return skillget;
