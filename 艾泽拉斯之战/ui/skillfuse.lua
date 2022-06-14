local skillfuse = class( "skillfuse", layout );

global_event.SKILLFUSE_SHOW = "SKILLFUSE_SHOW";
global_event.SKILLFUSE_HIDE = "SKILLFUSE_HIDE";
global_event.SKILLFUSE_SHOW_MAGIC_EXP = "SKILLFUSE_SHOW_MAGIC_EXP";
global_event.SKILLFUSE_HIDE_MAGIC_EXP = "SKILLFUSE_HIDE_MAGIC_EXP";
global_event.SKILLFUSE_UPDATE = "SKILLFUSE_UPDATE";

function skillfuse:ctor( id )
	skillfuse.super.ctor( self, id );
	self:addEvent({ name = global_event.SKILLFUSE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SKILLFUSE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.SKILLFUSE_UPDATE, eventHandler = self.onUpdateInfo});
	self:addEvent({ name = global_event.SKILLFUSE_SHOW_MAGIC_EXP, eventHandler = self.showMagicExp});
	self:addEvent({ name = global_event.SKILLFUSE_HIDE_MAGIC_EXP, eventHandler = self.hideMagicExp});
end

function skillfuse:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	self.skillfuse_skill_patch_num = {};
	self.skillfuse_skill_button = {};
	
	function onClickMagicFuseClose()
		self:onHide();
	end
	
	local skillfuse_close = self:Child("skillfuse-close");
	skillfuse_close:subscribeEvent("ButtonClick", "onClickMagicFuseClose");
	
	function onClickMagicFuse(args)
	
		if dataManager.kingMagic:getMagicTowerFlag() then
			return;
		end
		
		local window = LORD.toWindowEventArgs(args).window;
		local userdata = window:GetUserData();
		
		local extraExp = dataManager.kingMagic:getExtraExp();
		local expArray = dataConfig.configs.ConfigConfig[0].magicLevelExp;
		
		if extraExp >= expArray[userdata] then
			sendFuseMagic(userdata);
			dataManager.kingMagic:setMagicTowerFlag(true);
		else
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
				textInfo = "魔法精华不足，无法进行领悟！" });
				
			self:onHide();			
		end
	end
	
	for i=1, 3 do
		self.skillfuse_skill_patch_num[i] = self:Child( "skillfuse-skill"..i.."-patch-num" );
		self.skillfuse_skill_button[i] = self:Child( "skillfuse-skill"..i.."-button" );	
		self.skillfuse_skill_button[i]:SetUserData(i);
		self.skillfuse_skill_button[i]:subscribeEvent("ButtonClick", "onClickMagicFuse");
	end
	
	self:onUpdateInfo();
end

function skillfuse:onHide(event)
	self:Close();
end

function skillfuse:onUpdateInfo()

	if not self._show then
		return;
	end
	
	local extraExp = dataManager.kingMagic:getExtraExp();
	local expArray = dataConfig.configs.ConfigConfig[0].magicLevelExp;
	
	for i=1, 3 do
		if extraExp >= expArray[i] then
			self.skillfuse_skill_patch_num[i]:SetText(expArray[i]);
		else
			self.skillfuse_skill_patch_num[i]:SetText("^FF0000"..expArray[i]);
		end
	end
	
	local skillfuse_magicnum = self:Child("skillfuse-magicnum");
	local extraExp = dataManager.kingMagic:getExtraExp();
	skillfuse_magicnum:SetText(extraExp);
	
	
	function onSkillFuseBuyMagic()
		eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", resType = enum.BUY_RESOURCE_TYPE.MAGIC, copyType = -1, copyID = -1, });
	end
	
	-- add money info
	local skillfuse_magicicon_add = self:Child("skillfuse-magicicon-add");
	skillfuse_magicicon_add:subscribeEvent("ButtonClick", "onSkillFuseBuyMagic");
		
end

function skillfuse:showMagicExp()
	
	local skillfuse_resource_shadow = self:Child("skillfuse-resource-shadow");
	
	if skillfuse_resource_shadow then
		skillfuse_resource_shadow:SetVisible(true);
	end
end

function skillfuse:hideMagicExp()

	local skillfuse_resource_shadow = self:Child("skillfuse-resource-shadow");
	
	if skillfuse_resource_shadow then
		skillfuse_resource_shadow:SetVisible(false);
	end
	
end

return skillfuse;
