local miracle = class( "miracle", layout );

global_event.MIRACLE_SHOW = "MIRACLE_SHOW";
global_event.MIRACLE_HIDE = "MIRACLE_HIDE";
global_event.MIRACLE_UPDATE = "MIRACLE_UPDATE";

function miracle:ctor( id )
	miracle.super.ctor( self, id );
	self:addEvent({ name = global_event.MIRACLE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.MIRACLE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.MIRACLE_UPDATE, eventHandler = self.updateUIInfo});
end

function miracle:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.miracle_close = self:Child( "miracle-close" );
	self.miracle_jianzao = self:Child( "miracle-jianzao" );
	
	function onClickMiracleClose()
		self:onHide();
	end
	
	function onClickMiracleLevelUp()
	
		dataManager.miracleData:onHandleLevelUp();
	
	end
	
	self.miracle_close:subscribeEvent("ButtonClick", "onClickMiracleClose");
	self.miracle_jianzao:subscribeEvent("ButtonClick", "onClickMiracleLevelUp");
	
	self:updateUIInfo();
	
end

function miracle:onHide(event)
	
	self:Close();
	
	homeland.recoverCamera(enum.HOMELAND_BUILD_TYPE.EQUIP);
	
end

function miracle:updateUIInfo()

	if not self._show then
		return;
	end
	
	local nowLevel = dataManager.miracleData:getLevel();
	local nextLevel = nowLevel + 1;
	local isMaxLevel = dataManager.miracleData:isMaxLevel();
	
	local nowConfigInfo = dataManager.miracleData:getConfig();
	local nextConfigInfo = dataManager.miracleData:getConfig(nextLevel);
	
	-- level info
	local level_num = self:Child("miracle-level-num");
	local level_nextnum = self:Child("miracle-level-nextnum");
	local num_arrow = self:Child("miracle-num-arrow");
	
	level_num:SetText("Lv"..nowLevel);
	level_nextnum:SetText("Lv"..nextLevel);
	num_arrow:SetVisible(not isMaxLevel);
	level_nextnum:SetVisible(not isMaxLevel);
	
	-- cost info
	local zhucheng = self:Child("miracle-zhucheng");
	local mucai = self:Child("miracle-mucai");
	zhucheng:SetVisible(not isMaxLevel)
	mucai:SetVisible(not isMaxLevel)
	self.miracle_jianzao:SetVisible(not isMaxLevel)
	
	local miracle_container2 = self:Child("miracle-container2");
	local touxiang_now = LORD.toStaticImage(self:Child("miracle-touxiang-nowback"));
	if isMaxLevel then
		miracle_container2:SetVisible(false);
		local y = touxiang_now:GetPosition().y
	    touxiang_now:SetPosition(LORD.UVector2(LORD.UDim(0, 110), y ));
	end
	
	-- attr info
	local soldier_num = self:Child("miracle-soldier-num");
	local soldier_arrow = self:Child("miracle-soldier-arrow");
	local soldier_nextnum = self:Child("miracle-soldier-nextnum");
	
	local atk_num = self:Child("miracle-atk-num");
	local atk_arrow = self:Child("miracle-atk-arrow");
	local atk_nextnum = self:Child("miracle-atk-nextnum");
	
	local def_num = self:Child("miracle-def-num");
	local def_arrow = self:Child("miracle-def-arrow");
	local def_nextnum = self:Child("miracle-def-nextnum");
	
	local crit_num = self:Child("miracle-crit-num");
	local crit_arrow = self:Child("miracle-crit-arrow");
	local crit_nextnum = self:Child("miracle-crit-nextnum");
	
	local ten_num = self:Child("miracle-ten-num");
	local ten_arrow = self:Child("miracle-ten-arrow");
	local ten_nextnum = self:Child("miracle-ten-nextnum");
	
	
	soldier_num:SetText("+"..(nowConfigInfo.soldier*100 * 0.001).."%");
	atk_num:SetText("+"..(nowConfigInfo.shipAttrRatio[1].attack*100 * 0.001).."%");
	def_num:SetText("+"..(nowConfigInfo.shipAttrRatio[1].defence*100 * 0.001).."%");
	crit_num:SetText("+"..(nowConfigInfo.shipAttrRatio[1].critical*100 * 0.001).."%");
	ten_num:SetText("+"..(nowConfigInfo.shipAttrRatio[1].resilience*100 * 0.001).."%");
	
	soldier_arrow:SetVisible(not isMaxLevel and nextConfigInfo.soldier > nowConfigInfo.soldier);
	soldier_nextnum:SetVisible(not isMaxLevel and nextConfigInfo.soldier > nowConfigInfo.soldier);

	atk_arrow:SetVisible(not isMaxLevel and nextConfigInfo.shipAttrRatio[1].attack > nowConfigInfo.shipAttrRatio[1].attack);
	atk_nextnum:SetVisible(not isMaxLevel and nextConfigInfo.shipAttrRatio[1].attack > nowConfigInfo.shipAttrRatio[1].attack);

	def_arrow:SetVisible(not isMaxLevel and nextConfigInfo.shipAttrRatio[1].defence > nowConfigInfo.shipAttrRatio[1].defence);
	def_nextnum:SetVisible(not isMaxLevel and nextConfigInfo.shipAttrRatio[1].defence > nowConfigInfo.shipAttrRatio[1].defence);
	
	crit_arrow:SetVisible(not isMaxLevel and nextConfigInfo.shipAttrRatio[1].critical > nowConfigInfo.shipAttrRatio[1].critical);
	crit_nextnum:SetVisible(not isMaxLevel and nextConfigInfo.shipAttrRatio[1].critical > nowConfigInfo.shipAttrRatio[1].critical);
	
	ten_arrow:SetVisible(not isMaxLevel and nextConfigInfo.shipAttrRatio[1].resilience > nowConfigInfo.shipAttrRatio[1].resilience);
	ten_nextnum:SetVisible(not isMaxLevel and nextConfigInfo.shipAttrRatio[1].resilience > nowConfigInfo.shipAttrRatio[1].resilience);
				
	if not isMaxLevel then

		soldier_nextnum:SetText((nextConfigInfo.soldier*100*0.001).."%");
		atk_nextnum:SetText((nextConfigInfo.shipAttrRatio[1].attack*100 * 0.001).."%");
		def_nextnum:SetText((nextConfigInfo.shipAttrRatio[1].defence*100 * 0.001).."%");
		crit_nextnum:SetText((nextConfigInfo.shipAttrRatio[1].critical*100 * 0.001).."%");
		ten_nextnum:SetText((nextConfigInfo.shipAttrRatio[1].resilience*100 * 0.001).."%");

	end
		
	-- head info
	local touxiang_now = LORD.toStaticImage(self:Child("miracle-touxiang-now"));
	local touxiang_imagenow = LORD.toStaticImage(self:Child("miracle-touxiang-imagenow"));
	
	touxiang_now:SetImage(dataManager.miracleData:getHeadFrame(nowLevel));
	touxiang_imagenow:SetImage(dataManager.playerData:getHeadIconImage());
	
	local touxiang_arrow = self:Child("miracle-touxiang-arrow");
	touxiang_arrow:SetVisible(not isMaxLevel);
	
	local touxiang_next = LORD.toStaticImage(self:Child("miracle-touxiang-next"));
	local touxiang_imagenext = LORD.toStaticImage(self:Child("miracle-touxiang-imagenext"));
	local touxiang_imagenextback = LORD.toStaticImage(self:Child("miracle-touxiang-nextback"));
	
	touxiang_imagenextback:SetVisible(not isMaxLevel);
	
	if not isMaxLevel then
		touxiang_next:SetImage(dataManager.miracleData:getHeadFrame(nextLevel));
		touxiang_imagenext:SetImage(dataManager.playerData:getHeadIconImage());
	end
	
	--[[
	-- unit info 
	local clan_num = {};
	local clan = {};
	local clan_equity = {};
	local clan_effect = {};
	
	function onMiracleUnitTips(args)

		local clickImage = LORD.toWindowEventArgs(args).window;
		local userdata = clickImage:GetUserData();
		local rect = clickImage:GetUnclippedOuterRect();
		
		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "miracle", id = userdata, 
				windowRect = rect, dir = "free",});

				
	end
	
	for i=1, 4 do
		
		clan[i] = LORD.toStaticImage(self:Child("miracle-clan"..i));
		clan_num[i] = self:Child("miracle-clan"..i.."-num");
		clan_equity[i] = LORD.toStaticImage(self:Child("miracle-clan"..i.."-equity"));
		clan_effect[i] = self:Child("miracle-clan"..i.."-effect");
		
		local count = dataManager.miracleData:getUnitCountByRace(i-1);
		local maxCount = dataManager.miracleData:getMaxRaceCount(i-1);
		local isMaxLevel = dataManager.miracleData:isMaxLevel();
		
		if count < maxCount then
			clan_num[i]:SetText("^FF0000"..count.."/"..maxCount);
			clan_effect[i]:SetVisible(false);
		else
			clan_num[i]:SetText(count.."/"..maxCount);
			clan_effect[i]:SetVisible(true);
		end
		clan_num[i]:SetVisible(not isMaxLevel)
		if isMaxLevel then
		clan_effect[i]:SetVisible(true);
		clan_equity[i]:SetVisible(false);
		end
		
		clan_equity[i]:SetImage(dataManager.miracleData:getUnitFrameByQuality());

		clan_equity[i]:removeEvent("WindowTouchDown");
		clan_equity[i]:subscribeEvent("WindowTouchDown", "onMiracleUnitTips");
		clan_equity[i]:SetUserData(i-1);
		
		global.onTipsHide(clan_equity[i]);
		
	end
	--]]
	
	local totalstar_num = self:Child("miracle-totalstar-num");
	
	local nowStar = dataManager.miracleData:getCurrentUnitStar();
	local needStar = dataManager.miracleData:getNeedUnitStar();
	
	if nowStar < needStar then
		totalstar_num:SetText("^FF0000"..nowStar.."/"..needStar);
	else
		totalstar_num:SetText(nowStar.."/"..needStar);
	end
	
	-- level up res
	local zhucheng_num = self:Child("miracle-zhucheng-num");
	local mucai_num = self:Child("miracle-mucai-num");
	
	if dataManager.miracleData:isEnoughGold() then
		zhucheng_num:SetText(nowConfigInfo.goldCost);
	else
		zhucheng_num:SetText("^FF0000"..nowConfigInfo.goldCost);
	end

	if dataManager.miracleData:isEnoughWood() then
		mucai_num:SetText(nowConfigInfo.lumberCost);
	else
		mucai_num:SetText("^FF0000"..nowConfigInfo.lumberCost);
	end
		
end

return miracle;
