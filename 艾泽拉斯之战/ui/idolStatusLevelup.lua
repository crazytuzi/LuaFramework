local idolStatusLevelup = class( "idolStatusLevelup", layout );

global_event.IDOLSTATUSLEVELUP_SHOW = "IDOLSTATUSLEVELUP_SHOW";
global_event.IDOLSTATUSLEVELUP_HIDE = "IDOLSTATUSLEVELUP_HIDE";
global_event.IDOLSTATUSLEVELUP_UPDATE = "IDOLSTATUSLEVELUP_UPDATE";

function idolStatusLevelup:ctor( id )
	idolStatusLevelup.super.ctor( self, id );
	self:addEvent({ name = global_event.IDOLSTATUSLEVELUP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.IDOLSTATUSLEVELUP_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.IDOLSTATUSLEVELUP_UPDATE, eventHandler = self.updateInfo});
	
end

function idolStatusLevelup:onShow(event)
	
	if self._show then
		return;
	end
	
	self:Show();
	
	function onIdolStatusLevelUpClose()
		self:flyaway();
	end
	
	function onIdoStatusLevelUpClickBuild()
		
		dataManager.idolBuildData:onClickLevelupConfirm();
		
	end
	
	local idolStatusLevelup_close = self:Child( "idolStatusLevelup-close" );
	idolStatusLevelup_close:subscribeEvent("ButtonClick", "onIdolStatusLevelUpClose");
	
	local idolStatusLevelup_jianzao = self:Child("idolStatusLevelup-jianzao");
	idolStatusLevelup_jianzao:subscribeEvent("ButtonClick", "onIdoStatusLevelUpClickBuild");
	
	self:updateInfo();
	
	self:flyout();
	
	--触发引导
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_IDOLSTATUSLEVELUP_OPEN}) 
	--
end

-- 更新ui信息
function idolStatusLevelup:updateInfo()
	
	if not self._show then
		return;
	end
	
	if dataManager.idolBuildData:isMaxLevel() then
		self:flyaway();
		return;
	end
	
	local level_num = self:Child("idolStatusLevelup-level-num");
	local level_nextnum = self:Child("idolStatusLevelup-level-nextnum");
	local num_arrow = self:Child("idolStatusLevelup-num-arrow");
	
	level_num:SetText("Lv"..dataManager.idolBuildData:getLevel());
	if dataManager.idolBuildData:isMaxLevel() then
		level_nextnum:SetText("");
		num_arrow:SetVisible(false);
	else
		level_nextnum:SetText("Lv"..(dataManager.idolBuildData:getLevel()+1));
		num_arrow:SetVisible(true);
	end
	
	local soldier_num = self:Child("idolStatusLevelup-soldier-num");
	local soldier_nextnum = self:Child("idolStatusLevelup-soldier-nextnum");
	local atk_num = self:Child("idolStatusLevelup-atk-num");
	local atk_nextnum = self:Child("idolStatusLevelup-atk-nextnum");
	local def_num = self:Child("idolStatusLevelup-def-num");
	local def_nextnum = self:Child("idolStatusLevelup-def-nextnum");
	local crit_num = self:Child("idolStatusLevelup-crit-num");
	local crit_nextnum = self:Child("idolStatusLevelup-crit-nextnum");
	local ten_num = self:Child("idolStatusLevelup-ten-num");
	local ten_nextnum = self:Child("idolStatusLevelup-ten-nextnum");
	
	local soldier_arrow = self:Child("idolStatusLevelup-soldier-arrow");
	local atk_arrow = self:Child("idolStatusLevelup-atk-arrow");
	local def_arrow = self:Child("idolStatusLevelup-def-arrow");
	local crit_arrow = self:Child("idolStatusLevelup-crit-arrow");
	local ten_arrow = self:Child("idolStatusLevelup-ten-arrow");
	
	local nowConfig = dataManager.idolBuildData:getConfig();
	
	if not dataManager.idolBuildData:isMaxLevel() then
	
		local nextConfig = dataManager.idolBuildData:getConfig(dataManager.idolBuildData:getLevel() + 1);
		
		soldier_num:SetText(nowConfig.soldier);
		soldier_nextnum:SetText(nextConfig.soldier - nowConfig.soldier);
		
		atk_num:SetText(nowConfig.shipAttrBase[1].attack);
		atk_nextnum:SetText(nextConfig.shipAttrBase[1].attack - nowConfig.shipAttrBase[1].attack);

		def_num:SetText(nowConfig.shipAttrBase[1].defence);
		def_nextnum:SetText(nextConfig.shipAttrBase[1].defence - nowConfig.shipAttrBase[1].defence);

		crit_num:SetText(nowConfig.shipAttrBase[1].critical);
		crit_nextnum:SetText(nextConfig.shipAttrBase[1].critical - nowConfig.shipAttrBase[1].critical);

		ten_num:SetText(nowConfig.shipAttrBase[1].resilience);
		ten_nextnum:SetText(nextConfig.shipAttrBase[1].resilience - nowConfig.shipAttrBase[1].resilience);
		
		soldier_arrow:SetVisible(nextConfig.soldier > nowConfig.soldier);
		atk_arrow:SetVisible(nextConfig.shipAttrBase[1].attack > nowConfig.shipAttrBase[1].attack);
		def_arrow:SetVisible(nextConfig.shipAttrBase[1].defence > nowConfig.shipAttrBase[1].defence);
		crit_arrow:SetVisible(nextConfig.shipAttrBase[1].critical > nowConfig.shipAttrBase[1].critical);
		ten_arrow:SetVisible(nextConfig.shipAttrBase[1].resilience > nowConfig.shipAttrBase[1].resilience);
		
		soldier_nextnum:SetVisible(nextConfig.soldier > nowConfig.soldier);
		atk_nextnum:SetVisible(nextConfig.shipAttrBase[1].attack > nowConfig.shipAttrBase[1].attack);
		def_nextnum:SetVisible(nextConfig.shipAttrBase[1].defence > nowConfig.shipAttrBase[1].defence);
		crit_nextnum:SetVisible(nextConfig.shipAttrBase[1].critical > nowConfig.shipAttrBase[1].critical);
		ten_nextnum:SetVisible(nextConfig.shipAttrBase[1].resilience > nowConfig.shipAttrBase[1].resilience);
				
	end
	
	for i=1, 4 do
		
		local robthing_num = self:Child("idolStatusLevelup-robthing"..i.."-num");

		local itemCount = dataManager.idolBuildData:getPrimalItemCount(i-1);
		local needCount = nowConfig.retuireItemCount;

		local robthing_image = LORD.toStaticImage(self:Child("idolStatusLevelup-robthing"..i.."-image"));
		
		local primalItemInfo = dataManager.idolBuildData:getPrimalItemInfo(i-1);
		robthing_image:SetImage(primalItemInfo.icon);
		-- tips
		robthing_image:SetUserData(i-1);
		global.onItemTipsShow(robthing_image, enum.REWARD_TYPE.REWARD_TYPE_PRIMAL, "top");
		global.onItemTipsHide(robthing_image);
		
		if dataManager.idolBuildData:isMaxLevel() then
			robthing_num:SetText(itemCount);
		else
			if itemCount >= needCount then
				robthing_num:SetText(itemCount.."/"..needCount);
			else
				robthing_num:SetText("^FF0000"..itemCount.."/"..needCount);
			end
		end	

	end
	
	local zhucheng_num = self:Child("idolStatusLevelup-zhucheng-num");
	local mucai_num = self:Child("idolStatusLevelup-mucai-num");
	
	if dataManager.idolBuildData:isEnoughGold() then
		zhucheng_num:SetText(nowConfig.goldCost);
	else
		zhucheng_num:SetText("^FF0000"..nowConfig.goldCost);
	end

	if dataManager.idolBuildData:isEnoughWood() then
		mucai_num:SetText(nowConfig.lumberCost);
	else
		mucai_num:SetText("^FF0000"..nowConfig.lumberCost);
	end
	
	
end

function idolStatusLevelup:flyout()
	
	if not self._show then
		return;
	end
	
	-- 左边的
	local idolStatusLevelup_title = self:Child("idolStatusLevelup-title");
	local idolStatusLevelup_container = self:Child("idolStatusLevelup-container");
	local idolStatusLevelup_xiaohao = self:Child("idolStatusLevelup-xiaohao");
	local idolStatusLevelup_shengjixiaoguo = self:Child("idolStatusLevelup-shengjixiaoguo");
	local idolStatusLevelup_anniu = self:Child("idolStatusLevelup-anniu");
	
	local action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatusLevelup_title:playAction(action);	

	action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatusLevelup_container:playAction(action);

	action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatusLevelup_xiaohao:playAction(action);
	
	action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatusLevelup_shengjixiaoguo:playAction(action);

	action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatusLevelup_anniu:playAction(action);
						
end

function idolStatusLevelup:flyaway()
	
	if not self._show then
		return;
	end
	
	self:onHide();
	
	eventManager.dispatchEvent({name = global_event.IDOLSTATUS_ONQUIT_LEVEL_UP});

	--[[
	
	function onIdolStatusLevelupQuitEnd()
		self:onHide();
	end
	
	-- 左边的
	local idolStatusLevelup_title = self:Child("idolStatusLevelup-title");
	local idolStatusLevelup_container = self:Child("idolStatusLevelup-container");
	local idolStatusLevelup_xiaohao = self:Child("idolStatusLevelup-xiaohao");
	local idolStatusLevelup_shengjixiaoguo = self:Child("idolStatusLevelup-shengjixiaoguo");
	local idolStatusLevelup_anniu = self:Child("idolStatusLevelup-anniu");
	
	local action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	
	idolStatusLevelup_title:removeEvent("UIActionEnd");
	idolStatusLevelup_title:subscribeEvent("UIActionEnd", "onIdolStatusLevelupQuitEnd");
	idolStatusLevelup_title:playAction(action);	
	
	action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatusLevelup_container:playAction(action);

	action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatusLevelup_xiaohao:playAction(action);
	
	action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatusLevelup_shengjixiaoguo:playAction(action);

	action = LORD.GUIAction:new();
	action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
	action:addKeyFrame(LORD.Vector3(-500, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
	idolStatusLevelup_anniu:playAction(action);
	--]]
		
end

function idolStatusLevelup:onHide(event)
	self:Close();
end

return idolStatusLevelup;
