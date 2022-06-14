local magiclevelup = class( "magiclevelup", layout );

global_event.MAGICLEVELUP_SHOW = "MAGICLEVELUP_SHOW";
global_event.MAGICLEVELUP_HIDE = "MAGICLEVELUP_HIDE";

function magiclevelup:ctor( id )
	magiclevelup.super.ctor( self, id );
	self:addEvent({ name = global_event.MAGICLEVELUP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.MAGICLEVELUP_HIDE, eventHandler = self.onHide});
end

function magiclevelup:onShow(event)
	if self._show then
		return;
	end

	-- 升级的数据
	self.levelupData = event.data;
	
	self:Show();

	self.magiclevelup_back = LORD.toStaticImage(self:Child( "magiclevelup-back" ));
	self.magiclevelup_item = LORD.toStaticImage(self:Child( "magiclevelup-item" ));
	self.magiclevelup_name = self:Child( "magiclevelup-name" );
	self.magiclevelup_text = self:Child("magiclevelup-text");
	self.magiclevelup_cd_n = self:Child("magiclevelup-cd-n");
	self.magiclevelup_cost_n = self:Child("magiclevelup-cost-n");
	
	self.magiclevelup_star = {};
	for i=1, 5 do
		self.magiclevelup_star[i] = LORD.toStaticImage(self:Child( "magiclevelup-star"..i ));	
	end
	
	self.magiclevelup_animate = LORD.toAnimateWindow(self:Child("magiclevelup-animate"));
	
	self.magiclevelup_close = self:Child( "magiclevelup-close" );
	
	function onMagiclevelupClose()
		self:onHide();
	end
	
	self.magiclevelup_close:subscribeEvent("ButtonClick", "onMagiclevelupClose");

	if self.levelupData then
		self:updateInfo(self.levelupData);
	end
		
end

function magiclevelup:onHide(event)

		if self.expTimer and self.expTimer > 0 then
		
			scheduler.unscheduleGlobal(self.expTimer);
			self.expTimer = nil;
					
		end
				
	self.magiclevelup_back = nil;
	self.magiclevelup_item = nil;
	self.magiclevelup_name = nil;
	self.magiclevelup_text = nil;
	self.magiclevelup_star = nil;
	self.magiclevelup_animate = nil;
	
	self:Close();

	if global.newCardMagicList then
		table.remove(global.newCardMagicList, 1);
	end	
	
	global.triggerNewCardAndMagic();

		
end

function magiclevelup:updateInfo(data)
	
	function magicFlyStar(window)

		function magicStarFlyEndFunc()
			if self._show then
				uiaction.shake(self._view);
				
				LORD.SoundSystem:Instance():playEffect("star.mp3");
			end
		end
	
		if self._show and window then
			local action = LORD.GUIAction:new();

			action:addKeyFrame(LORD.Vector3(-100, 100, 0), LORD.Vector3(0, 0, 720), LORD.Vector3(5, 5, 0), 1, 0);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
			window:playAction(action);
			
			window:removeEvent("UIActionEnd");
			window:subscribeEvent("UIActionEnd", "magicStarFlyEndFunc");

		end
	end
		
	local magicInfo = dataConfig.configs.magicConfig[data.magicID];
				
	if self._show and magicInfo then

		self.magiclevelup_back:SetImage(itemManager.getImageWithStar(data.oldLevel));
		self.magiclevelup_item:SetImage(magicInfo.icon);
		self.magiclevelup_name:SetText(magicInfo.name);
		self.magiclevelup_cd_n:SetText(magicInfo.cooldown);
		self.magiclevelup_cost_n:SetText(magicInfo.cost[data.newLevel]);
		
		local desc = dataManager.playerData:parseText(magicInfo.text, data.magicID, data.newLevel, dataManager.playerData:getIntelligence());
		self.magiclevelup_text:SetText(desc);
		
		function delayFlyFunc(index)
			if self._show and self.magiclevelup_star[index] then
				self.magiclevelup_star[index]:SetVisible(true);
				magicFlyStar(self.magiclevelup_star[index]);	
			end
		end
					
		for i=1, 5 do
			if i <= data.oldLevel then
				self.magiclevelup_star[i]:SetVisible(true);
			elseif i <= data.newLevel then
				self.magiclevelup_star[i]:SetVisible(false);
				scheduler.performWithDelayGlobal(delayFlyFunc, 0.3 + i*0.1, i);
			else
				self.magiclevelup_star[i]:SetVisible(false);
			end			
		end
	
		-- 播光效
		function changeBackImage()
			if self._show then
				--self.magiclevelup_back:SetImage(itemManager.getImageWithStar(data.newLevel));
				local magiclevelup_magic_equity = LORD.toStaticImage(self:Child("magiclevelup-magic-equity"));
				if magiclevelup_magic_equity then
					magiclevelup_magic_equity:SetImage(itemManager.getImageWithStar(data.newLevel));
				end
			end
		end
		
		local topLevel = data.oldLevel == data.newLevel and data.newLevel == 5;
				
		if not topLevel then
			self.magiclevelup_animate:play();
			scheduler.performWithDelayGlobal(changeBackImage, 0.5);
		else
				
				local magiclevelup_magic_equity = LORD.toStaticImage(self:Child("magiclevelup-magic-equity"));
				if magiclevelup_magic_equity then
					magiclevelup_magic_equity:SetImage(itemManager.getImageWithStar(data.newLevel));
				end
				
		end


		-- add 0513- 新增信息
		local magiclevelup_notice = self:Child("magiclevelup-notice");
		
		if data.firstGain then
			magiclevelup_notice:SetText("恭喜获得");
		elseif data.oldLevel < data.newLevel then
			magiclevelup_notice:SetText("魔法升星");
		else
			magiclevelup_notice:SetText("熟练度提升");
		end
		
		local magiclevelup_new = self:Child("magiclevelup-new");
		magiclevelup_new:SetVisible(data.firstGain);
		if data.firstGain then
			
			local action = LORD.GUIAction:new();
			action:addKeyFrame(LORD.Vector3(200, -100, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(2, 2, 2), 1, 0);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 120);
			magiclevelup_new:playAction(action);
		
		end
		
		local magiclevelup_skill1_exp_bar = self:Child("magiclevelup-skill1-exp-bar");
		--如果熟练度增长则播放bar增长动画。当前经验可升级到下一级并有盈余，则表现为当前bar增长至满后，再从头播放盈余部分。
		magiclevelup_skill1_exp_bar:SetProperty("Progress", 0);
		
		local magiclevelup_skill1_num  = self:Child("magiclevelup-skill1-num");
		--显示熟练度进度数字，播放熟练度增长动画时该数字跟随变化。
		magiclevelup_skill1_num:SetText(0);
		
		-- 启动一个timer 用于计算熟练度增长的动画效果
		self:doExpChangeAnimate();			
		
		local magiclevelup_skill1_exp_addnum = self:Child("magiclevelup-skill1-exp-addnum");
		magiclevelup_skill1_exp_addnum:SetText("+"..(data.exp - data.preExp));
		magiclevelup_skill1_exp_addnum:SetVisible(not data.firstGain and not topLevel);
		
		local magiclevelup_magiccrack_num = self:Child("magiclevelup-magiccrack-num");
		-- 根据溢出的熟练度，换算为魔法精华数量，显示“+XXX”对应数字
		
		-- 如果魔法达到满星熟练度溢出，则让该控件向右上跳动弹出，随后消失
		local magiclevelup_magiccrack = self:Child("magiclevelup-magiccrack");
		
		magiclevelup_magiccrack:SetVisible(data.extraExp > 0);
		magiclevelup_magiccrack_num:SetText("+"..data.extraExp);
		
		print("data.extraExp "..data.extraExp);
		
		if data.extraExp > 0 then
			
			-- 播放动画
			
			uiaction.popup(magiclevelup_magiccrack);
			
		end
		
	end
	
end

function magiclevelup:doExpChangeAnimate()
		
		if self.expTimer and self.expTimer > 0 then
		
			scheduler.unscheduleGlobal(self.expTimer);
			self.expTimer = nil;
					
		end
		
		-- 启动一个timer 用于计算熟练度增长的动画效果
		function magicLevelUpExpTick(dt)
			self:updateExpTick(dt);
		end
		
		self.startExp = self.levelupData.preExp;
		self.endExp = self.levelupData.exp;
		
		self.expTimer = scheduler.scheduleGlobal(magicLevelUpExpTick, 0);
		
end

function magiclevelup:updateExpTick(dt)
	
	if not self._show then
		return;
	end
	
	self.startExp = self.startExp + dt * 40;
	
	if self.startExp >= self.endExp then
		
		self.startExp = self.endExp;
		
		-- 结束timer
		if self.expTimer and self.expTimer > 0 then
		
			scheduler.unscheduleGlobal(self.expTimer);
			self.expTimer = nil;
					
		end
				
	end
	
	-- update ui
	local currentExp, nextExp = dataManager.kingMagic:getCurrentAndNextByExp(self.startExp);

	local magiclevelup_skill1_exp_bar = self:Child("magiclevelup-skill1-exp-bar");
	if magiclevelup_skill1_exp_bar then
		magiclevelup_skill1_exp_bar:SetProperty("Progress", currentExp / nextExp);
	end
	
	local magiclevelup_skill1_num  = self:Child("magiclevelup-skill1-num");
	if magiclevelup_skill1_num then
	
		local ptext = string.format("%.0f/%.0f", currentExp, nextExp);
		magiclevelup_skill1_num:SetText(ptext);
	end

	local magiclevelup_skill1_exp_addnum = self:Child("magiclevelup-skill1-exp-addnum");
	if magiclevelup_skill1_exp_addnum then
			
		local ptext = string.format("+%.0f", self.startExp - self.levelupData.preExp);
		magiclevelup_skill1_exp_addnum:SetText(ptext);
		
	end
	
end

return magiclevelup;
