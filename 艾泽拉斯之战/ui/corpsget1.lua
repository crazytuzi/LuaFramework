local corpsget1 = class( "corpsget1", layout );

global_event.CORPSGET1_SHOW = "CORPSGET1_SHOW";
global_event.CORPSGET1_HIDE = "CORPSGET1_HIDE";

function corpsget1:ctor( id )
	corpsget1.super.ctor( self, id );
	self:addEvent({ name = global_event.CORPSGET1_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CORPSGET1_HIDE, eventHandler = self.onHide});
end

function corpsget1:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onClickCardOneOK()
		self:cardOneOK();
	end
	
	function onClickCardTenOK()
		self:cardTenOK();
	end
	
	function onClickCardGet1Skip()
		self:cardSkip();
	end
	
	self.corpsget1_model = LORD.toActorWindow(self:Child( "corpsget1-model" ));
	self.corps_star = {};
	self.corps_star_effect = {};
	
	for i=1, 6 do
		self.corps_star[i] = LORD.toStaticImage(self:Child( "corps-star"..i ));
		self.corps_star_effect[i] = LORD.toStaticImage(self:Child( "corps-star-effect"..i ));
		self.corps_star_effect[i]:SetVisible(false);
	end

	self.cropsget1_name = self:Child( "cropsget1-name" );
	self.corpsget1_button1 = self:Child( "corpsget1-button1" );
	self.corpsget1_button1_get = self:Child( "corpsget1-button1-get" );
	self.corpsget1_button1_get:subscribeEvent( "ButtonClick", "onClickCardOneOK");
	self.corpsget1_button2 = self:Child( "corpsget1-button2" );
	self.corpsget1_button2_get = self:Child( "corpsget1-button2-get" );
	self.corpsget1_button2_get:subscribeEvent( "ButtonClick", "onClickCardTenOK");
	self.corpsget1_button2_skip = self:Child( "corpsget1-button2-skip" );
	self.corpsget1_button2_skip:subscribeEvent( "ButtonClick", "onClickCardGet1Skip");
	self.corpsget1_count = self:Child("corpsget1-count");

	local times = dataManager.playerData:getNextDrawCardLuckyTimes();
	
	if times ~= 0 then
		self.corpsget1_count:SetText("^FF0000"..times.."次^FFFFFF后必得3星军团");
	
	else
		self.corpsget1_count:SetText("本次必得3星军团");
	end
	
	function onCardOneMore()
		
		--self:onHide();
		
		local player  = dataManager.playerData;
	
		player:drawOneCard();
		
	end
	
	function onCardTenMore()
		
		--self:onHide();
		
		local player  = dataManager.playerData;
	
		player:drawTenCard();	
	end
	
	self.corpsget1_button1_onemore = self:Child("corpsget1-button1-onemore");
	self.corpsget1_button1_onemore:subscribeEvent( "ButtonClick", "onCardOneMore");
	self.corpsget1_button1_tenmore = self:Child("corpsget1-button1-tenmore");
	self.corpsget1_button1_tenmore:subscribeEvent( "ButtonClick", "onCardTenMore");
	self.corpsget1_text = self:Child("corpsget1-text");
	self.corpsget1_fragment = self:Child("corpsget1-fragment");
	self.corpsget1_fragment_number = self:Child("corpsget1-fragment-number");
	
	self.resultData = event.resultData;
	self.resultType = event.resultType;
	
	self.currentIndex = event.index;
	
	if self.resultType ~= enum.CARD_RESULT_TYPE.CARD_RESULT_TYPE_DRAW_TEN then
		-- 单抽判断升星
		global.triggerNewCardAndMagic();
	end
	
	self:updateInfo();
	--触发引导
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_CORPGET_OPEN})
end

function corpsget1:onHide(event)
	
	self.corps_star = nil;
	self.corps_star_effect = nil;
	
	self:Close();
end

function corpsget1:updateInfo()
	
	function corpsget1FlyStar(window)

		function corpsget1StarFlyEndFunc()
			uiaction.shake(self._view);
			
			if layoutManager.getUI("card") and layoutManager.getUI("card")._view then
				uiaction.shake(layoutManager.getUI("card")._view);
			end
			
			LORD.SoundSystem:Instance():playEffect("star.mp3");
			LORD.SceneManager:Instance():addCameraShake(0, 0.8, 0.07, 2);
			
			if self.corps_star_effect and self.corps_star_effect[self.showStarEffectIndex] then
				self.corps_star_effect[self.showStarEffectIndex]:SetVisible(true);
				self.showStarEffectIndex = self.showStarEffectIndex + 1;
			end

		end
	
		if window then
			local action = LORD.GUIAction:new();

			action:addKeyFrame(LORD.Vector3(-300, 100, 0), LORD.Vector3(0, 0, 720), LORD.Vector3(5, 5, 0), 1, 0);
			action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
			window:playAction(action);
			
			window:removeEvent("UIActionEnd");
			window:subscribeEvent("UIActionEnd", "corpsget1StarFlyEndFunc");

		end
	end
	
	if self.resultType == enum.CARD_RESULT_TYPE.CARD_RESULT_TYPE_DRAW_TEN then
		-- 十连抽
		self.corpsget1_button1:SetVisible(false);
		self.corpsget1_button2:SetVisible(true);
	else
		-- 抽一次
		self.corpsget1_button1:SetVisible(true);
		self.corpsget1_button2:SetVisible(false);
	end
	
	local nowCardData = self.resultData[self.currentIndex];
	
	--dump(nowCardData);
	
	if nowCardData then
		-- 刷新当前的界面
		local cardType = nowCardData.cardID;
		local cardExp = nowCardData.cardExp;
		local star = cardData.getStarByExp(cardExp);
		local unitID = cardData.getUnitIDByTypeAndStar(cardType, star);
		
		local unitInfo = dataConfig.configs.unitConfig[unitID];
		
		self.corpsget1_text:SetVisible(nowCardData.firstGain);
		self.corpsget1_fragment:SetVisible(not nowCardData.firstGain);
		self.corpsget1_fragment_number:SetText("+"..cardExp);
		
		if unitInfo then
			self.cropsget1_name:SetText(unitInfo.name);

			self.flyIndex = 1;
			self.showStarEffectIndex = 1;
			
			function delayFlyFunc(dt)
				if self.corps_star and self.corps_star[self.flyIndex] then
					self.corps_star[self.flyIndex]:SetVisible(true);
					corpsget1FlyStar(self.corps_star[self.flyIndex]);
					
					self.flyIndex = self.flyIndex + 1;

				end
			end
					
			for i=1, 6 do
				if i <= star then
					self.corps_star[i]:SetVisible(false);
					scheduler.performWithDelayGlobal(delayFlyFunc, i*0.1);
				else
					self.corps_star[i]:SetVisible(false);
				end
			end
			
			--print("unitInfo.resourceName "..unitInfo.resourceName);
			--self.corpsget1_model:SetActor(unitInfo.resourceName, "idle");
			self.corpsget1_model:SetActor("", "idle");
		end
	end
	
end

function corpsget1:cardOneOK()
	self:onHide();
	
	displayCardLogic.desstroyActor();
		
	eventManager.dispatchEvent({ name = global_event.CARD_HIDE });
	
end

function corpsget1:cardTenOK()
	
	displayCardLogic.startNextDisplay();
	
	if self.currentIndex == 10 then
		-- 没有下一个了
		self:onHide();
		eventManager.dispatchEvent({name = global_event.CORPSGET2_SHOW, tenCardData = self.resultData });
	else
		--self.currentIndex = self.currentIndex + 1;
		--self:updateInfo();
	end
	
end

function corpsget1:cardSkip()
	-- 直接跳到最终
	eventManager.dispatchEvent({name = global_event.CORPSGET2_SHOW, tenCardData = self.resultData });
	self:onHide();
	
	displayCardLogic.desstroyActor();
end

return corpsget1;