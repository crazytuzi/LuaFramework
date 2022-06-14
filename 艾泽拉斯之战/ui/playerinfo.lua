local playerinfo = class( "playerinfo", layout );

global_event.PLAYERINFO_SHOW = "PLAYERINFO_SHOW";
global_event.PLAYERINFO_HIDE = "PLAYERINFO_HIDE";

function playerinfo:ctor( id )
	playerinfo.super.ctor( self, id );
	self:addEvent({ name = global_event.PLAYERINFO_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.PLAYERINFO_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.PLAYER_ATTR_SYNC, eventHandler = self.onUpdate})
end

function playerinfo:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.playerinfo_head_image = LORD.toStaticImage(self:Child( "playerinfo-head-image" ));
	self.playerinfo_head_button = self:Child( "playerinfo-head-button" );
	self.playerinfo_name = self:Child( "playerinfo-name" );
	self.playerinfo_name_changebutton = self:Child( "playerinfo-name-changebutton" );
	self.playerinfo_lv_num = self:Child( "playerinfo-lv-num" );
	self.playerinfo_exp_num = self:Child( "playerinfo-exp-num" );
	self.playerinfo_magic_num = self:Child( "playerinfo-magic-num" );
	self.playerinfo_id_num = self:Child( "playerinfo-id-num" );
	self.playerinfo_code = self:Child( "playerinfo-code" );
	self.playerinfo_close = self:Child( "playerinfo-close" );
	self.playerinfo_sound_switch = self:Child( "playerinfo-sound-switch" );
	
	self.playerinfo_numid_num = self:Child( "playerinfo-numid-num" );
	
	
	self.playerinfo_gamenotice = self:Child( "playerinfo-sound-gamenotice" );
	
	local sound = fio.readIni("system", "sound", "on");
	self:updateSoundText(sound == "on");
	
	local recordSetting = fio.readIni("system", "record", "off");
	self:updateRecordState(recordSetting);
	
	function onClickPlayerInfoSound()
		local sound = fio.readIni("system", "sound", "on");
		
		if sound == "on" then
					
			LORD.SoundSystem:Instance():setSoundOn(false);
			fio.writeIni("system", "sound", "off");
			self:updateSoundText(false);
			
		else
		
			LORD.SoundSystem:Instance():setSoundOn(true);	
			fio.writeIni("system", "sound", "on");
			
			self:updateSoundText(true);
		end
	end
	
	self.playerinfo_sound_switch:subscribeEvent("ButtonClick", "onClickPlayerInfoSound");
	
	function onClickPlayerInfoRecord()
		
		local shellInterface = GameClient.CGame:Instance():getShellInterface();
		if shellInterface and shellInterface:getPlatformID() ~= "laoh" then
			eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "该功能暂未开启，敬请期待！"});
			return;
		end
		
		local sound = fio.readIni("system", "record", "off");
		
		if sound == "on" then
			fio.writeIni("system", "record", "off");

			self:updateRecordState("off");
		else
		
			fio.writeIni("system", "record", "on");
			
			self:updateRecordState("on");
		end
				
	end
	
	local rec_switch = self:Child("playerinfo-rec-switch");
	rec_switch:subscribeEvent("ButtonClick", "onClickPlayerInfoRecord");
	
	function onClickPlayerinfogamenotice(args)
		 	eventManager.dispatchEvent({name = global_event.GAMENOTICE_SHOW});
	end	
	
	self.playerinfo_gamenotice:subscribeEvent("ButtonClick", "onClickPlayerinfogamenotice");
	
	function onClickPlayerinfoClose(args)
		self:onHide();
	end	
	self.playerinfo_close:subscribeEvent("ButtonClick", "onClickPlayerinfoClose");
	
	function onClickPlayerinfoChangeName(args)
		eventManager.dispatchEvent({name = global_event.HERONAME_SHOW});
	end	
	
	self.playerinfo_name_changebutton:subscribeEvent("ButtonClick", "onClickPlayerinfoChangeName");

	function onClickPlayerinfoChangeIcon(args)
		eventManager.dispatchEvent({name = global_event.CHANGEPLAYERICON_SHOW});
	end	
	self.playerinfo_head_button:subscribeEvent("ButtonClick", "onClickPlayerinfoChangeIcon");
  
  function onPlayerInfoExchangeCode()
  	eventManager.dispatchEvent({name = global_event.EXCHANGEAWARDS_SHOW});
  end
  
  self.playerinfo_code:subscribeEvent("ButtonClick", "onPlayerInfoExchangeCode");
  
	self:Update();
 
end

function playerinfo:updateSoundText(setting)
	if setting then
		self.playerinfo_sound_switch:SetText("已开启");
		self.playerinfo_sound_switch:SetProperty("NormalImage","set:common.xml image:button2");
		self.playerinfo_sound_switch:SetProperty("PushedImage","set:common.xml image:button2");
		self.playerinfo_sound_switch:SetProperty("TextBorderColor","0.184314 0.290196 0.0705882 1");
		
	else
		self.playerinfo_sound_switch:SetText("已关闭");
		self.playerinfo_sound_switch:SetProperty("NormalImage","set:common.xml image:redbutton");
		self.playerinfo_sound_switch:SetProperty("PushedImage","set:common.xml image:redbutton");
		self.playerinfo_sound_switch:SetProperty("TextBorderColor","0.309804 0.0588235 0.054902 1");
	end
end

function playerinfo:updateRecordState(config)
	
	if not self._show then
		return;
	end
	
	local flag = false;
	if config == "on" then
		flag = true;
	end
		
	local rec_switch = self:Child("playerinfo-rec-switch");
	
	if flag then
		rec_switch:SetText("已开启");
		rec_switch:SetProperty("NormalImage","set:common.xml image:button2");
		rec_switch:SetProperty("PushedImage","set:common.xml image:button2");
		rec_switch:SetProperty("TextBorderColor","0.184314 0.290196 0.0705882 1");		
	else
		rec_switch:SetText("已关闭");
		rec_switch:SetProperty("NormalImage","set:common.xml image:redbutton");
		rec_switch:SetProperty("PushedImage","set:common.xml image:redbutton");
		rec_switch:SetProperty("TextBorderColor","0.309804 0.0588235 0.054902 1");	
	end
	
	local shellInterface = GameClient.CGame:Instance():getShellInterface();
	if shellInterface then
		shellInterface:enableRecord(flag);
	end
	
end

function playerinfo:Update()
	if not self._show then
		return;
	end
	self.playerinfo_name:SetText(dataManager.playerData:getName())	
	self.playerinfo_lv_num:SetText(dataManager.playerData:getLevel() )	
    self.playerinfo_exp_num:SetText( dataManager.playerData:getExp().."/"..dataManager.playerData:getLevelupExp())
	self.playerinfo_magic_num:SetText(dataManager.playerData:getIntelligence())	
	self.playerinfo_id_num:SetText(dataManager.playerData:getPlayerId())	
	self.playerinfo_head_image:SetImage(global.getHalfBodyImage(dataManager.playerData:getHeadIcon()))
	self.playerinfo_numid_num:SetText(dataManager.playerData:getPlayerStringAttr(enum.PLAYER_ATTR_STRING.PLAYER_ATTR_STRING_ACCOUNT))	
	
end


function playerinfo:onUpdate(event)
	self:Update();
end


function playerinfo:onHide(event)
	self:Close();
end

return playerinfo;
