local noticeDiamond = class( "noticeDiamond", layout );

global_event.NOTICEDIAMOND_SHOW = "NOTICEDIAMOND_SHOW";
global_event.NOTICEDIAMOND_HIDE = "NOTICEDIAMOND_HIDE";

function noticeDiamond:ctor( id )
	noticeDiamond.super.ctor( self, id );
	self:addEvent({ name = global_event.NOTICEDIAMOND_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.NOTICEDIAMOND_HIDE, eventHandler = self.onHide});
 
end

function noticeDiamond:onShow(event)
	if self._show then
		return;
	end

	--print("noticeDiamond   ");
	self:Show();

	self.noticeDiamond_close = self:Child( "noticeDiamond-close" );
	self.noticeDiamond_button_OK = self:Child( "noticeDiamond-button-OK" );
	self.noticeDiamond_root = self:Child( "noticeDiamond-root" );
	self.noticeDiamond_diamond = LORD.toStaticImage(self:Child( "noticeDiamond-diamond" ));
	self.noticeDiamond_text1 = self:Child( "noticeDiamond-text1" );
	self.noticeDiamond_text2 = self:Child( "noticeDiamond-text2" );
	self.noticeDiamond_text3 = self:Child( "noticeDiamond-text3" );
	self.noticeDiamond_text4 = self:Child( "noticeDiamond-text4" );

	self.noticeDiamond_close:subscribeEvent("ButtonClick", "onClickNoticeDiamondClose");
	self.noticeDiamond_button_OK:subscribeEvent("ButtonClick", "onClicNoticeDiamondOK");
	self.buildImTimeTick = -1;
	
	function onClickNoticeDiamondClose()
		self:onHide();
	end
	
	function onClicNoticeDiamondOK()
		self:noticeDiamondOK();
	end
	
	self:updateNoticeInfo(event);
	
end

function noticeDiamond:onHide(event)
	
	if self.buildImTimeTick and self.buildImTimeTick > 0 then
		scheduler.unscheduleGlobal(self.buildImTimeTick);
		self.buildImTimeTick = -1;
	end
	
	self:Close();
end

function noticeDiamond:noticeDiamondOK()

	if self.messageType == enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE then
		-- 立即升级
		local levelupBuildType = dataManager.build.getCurrentLevelUpBuild();
		local requireDiamond = dataManager.build.getLevelUpNeedDiamond(levelupBuildType);
		local player  = dataManager.playerData;
		if player:getGem() < requireDiamond then
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });	
				return		
		end
		
		if levelupBuildType >= 0 then
			sendUpgradeBuild(2, levelupBuildType);
		end
	elseif self.messageType == enum.MESSAGE_DIAMOND_TYPE.LACK_OF_SWEEP_TICKET then
		-- 使用钻石兑换扫荡券,直接进行扫荡
		local player  = dataManager.playerData;
		if player:getGem() >= self.data.count then
			-- 处理扫荡的逻辑			
			if(global.tipBagFull())then
				self:onHide();
				return
			end		
			sendSweep(self.data.stage:getAdventureID(), self.data.stage:getServerType(),self.data.count)
		else
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });	
		end
	elseif self.messageType == enum.MESSAGE_DIAMOND_TYPE.REFRESH_SHOP then	
		local player  = dataManager.playerData;
		if player:getGem() >= self.data.count then
			 sendShopRefresh(self.data.reFreshType, self.data.shopType)
			---sendSweep(self.data.stage:getAdventureID(), self.data.stage:getServerType(),self.data.count)
		else
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });	
		end
	elseif self.messageType == enum.MESSAGE_DIAMOND_TYPE.CLEAN_CD then		
	 	local player  = dataManager.playerData;
		if player:getGem() >= self.data.count then
			if(self.data.func)then
				self.data.func()
			end 
		else
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });	
		end
	elseif self.messageType == enum.MESSAGE_DIAMOND_TYPE.RESET_NUM then		
	 	local player  = dataManager.playerData;
		if player:getGem() >= self.data.count then
			if(self.data.func)then
				self.data.func()
			end 
		else
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });	
		end		
		
	elseif self.messageType == enum.MESSAGE_DIAMOND_TYPE.CHANGENAME then		
	 	local player  = dataManager.playerData;
		if player:getGem() >= self.data.count then
			if(self.data.func)then
				self.data.func()
			end 
		else
			eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.LACK_OF_DIMOND, data = -1, 
				text = "当前钻石不足，是否充值？" });	
		end			
  			
	end
	
	self:onHide();
end

function noticeDiamond:updateNoticeInfo(event)
	
	self.messageType = event.messageType;
	self.data = event.data;
		
	if self.messageType == enum.MESSAGE_DIAMOND_TYPE.BUILD_LEVEL_UP_IMMEDIATE then
		self.noticeDiamond_text1:SetText(event.textInfo);
		self.noticeDiamond_button_OK:SetText("立刻完成");
		function buildImTimeTickFunction()
			self:updateDiamondBuildLevelUp();
		end
		
		self.buildImTimeTick = scheduler.scheduleGlobal(buildImTimeTickFunction, 1);
		
		self:updateDiamondBuildLevelUp();
				
	elseif self.messageType == enum.MESSAGE_DIAMOND_TYPE.LACK_OF_SWEEP_TICKET then
		
		self.noticeDiamond_text1:SetText("扫荡卷不足");
		self.noticeDiamond_text4:SetText("兑换扫荡卷");
		
		-- self.data 是需要的钻石

		local player  = dataManager.playerData;
		if player:getGem() < self.data.count then
			self.noticeDiamond_text3:SetText("^FF0000"..self.data.count);		
		else
			self.noticeDiamond_text3:SetText(self.data.count);
		end			

		self.noticeDiamond_button_OK:SetText("确  定");
	elseif self.messageType == enum.MESSAGE_DIAMOND_TYPE.REFRESH_SHOP then	
		self.noticeDiamond_text1:SetText("^FF3F26注*刷新价格将在每日5:00重置");
		self.noticeDiamond_text1:SetProperty("TextBorder" , "true");
		self.noticeDiamond_text4:SetText("刷新商店");
		
		local player  = dataManager.playerData;
		if player:getGem() < self.data.count then
			self.noticeDiamond_text3:SetText("^FF0000"..self.data.count);		
		else
			self.noticeDiamond_text3:SetText(self.data.count);
		end			

		self.noticeDiamond_button_OK:SetText("确  定");
	elseif self.messageType == enum.MESSAGE_DIAMOND_TYPE.CLEAN_CD then	
		self.noticeDiamond_text1:SetText("");
		self.noticeDiamond_text4:SetText("清除cd");
	
		local player  = dataManager.playerData;
		if player:getGem() < self.data.count then
			self.noticeDiamond_text3:SetText("^FF0000"..self.data.count);		
		else
			self.noticeDiamond_text3:SetText(self.data.count);
		end					
		self.noticeDiamond_button_OK:SetText("确  定");
	elseif self.messageType == enum.MESSAGE_DIAMOND_TYPE.RESET_NUM then	
		self.noticeDiamond_text1:SetText("");
		self.noticeDiamond_text4:SetText("重置数量为"..self.data.num);
	
		local player  = dataManager.playerData;
		if player:getGem() < self.data.count then
			self.noticeDiamond_text3:SetText("^FF0000"..self.data.count);		
		else
			self.noticeDiamond_text3:SetText(self.data.count);
		end					
		self.noticeDiamond_button_OK:SetText("确  定");		
		
	elseif self.messageType == enum.MESSAGE_DIAMOND_TYPE.CHANGENAME then		
		self.noticeDiamond_text1:SetText("更换名称");
		self.noticeDiamond_text2:SetText("需要扣除");
	
		local player  = dataManager.playerData;
		if player:getGem() < self.data.count then
			self.noticeDiamond_text3:SetText("^FF0000"..self.data.count);		
		else
			self.noticeDiamond_text3:SetText(self.data.count);
		end				
		self.noticeDiamond_text4:SetText(",是否继续?");	
		self.noticeDiamond_button_OK:SetText("确  定");
 
	end
	
end

function noticeDiamond:updateDiamondBuildLevelUp()
	local levelupBuildType = dataManager.build.getCurrentLevelUpBuild();
	
	if levelupBuildType >=0 then
		local buildText = enum.BUILD_TYPE_TEXT[levelupBuildType];
		local remineTime = dataManager.build.getLevelUpRemainTime(levelupBuildType);
		local timeText = formatTime(remineTime, true);
		local requireDiamond = dataManager.build.getLevelUpNeedDiamond(levelupBuildType);
		
		if remineTime > 0 then
			self.noticeDiamond_text1:SetText("工人正在建造"..buildText..", 剩余时间"..timeText);
			local player  = dataManager.playerData;
			if player:getGem() < requireDiamond then
				self.noticeDiamond_text3:SetText("^FF0000"..requireDiamond);
			else
				self.noticeDiamond_text3:SetText(requireDiamond);
			end		
		else
			self:onHide();
		end
		
	end

end

return noticeDiamond;
