local enemyinformation = class( "enemyinformation", layout );

global_event.ENEMYINFORMATION_SHOW = "ENEMYINFORMATION_SHOW";
global_event.ENEMYINFORMATION_HIDE = "ENEMYINFORMATION_HIDE";

function enemyinformation:ctor( id )
	enemyinformation.super.ctor( self, id );
	self:addEvent({ name = global_event.ENEMYINFORMATION_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.ENEMYINFORMATION_HIDE, eventHandler = self.onHide});
end

function enemyinformation:onShow(event)
	if self._show then
		return;
	end
	
	self.event = event;
	
	self:Show();


 
	self.enemyinformation_king_container = LORD.toStaticImage(self:Child( "enemyinformation-king-container" ));
	self.enemyinformation_king_image = LORD.toStaticImage(self:Child( "enemyinformation-king-image" ));
	

	self.enemyinformation_king_name = self:Child( "enemyinformation-king-name" );
 
	self.enemyinformation_lv = self:Child( "enemyinformation-lv" );
	self.enemyinformation_lv_num = self:Child( "enemyinformation-lv-num" );
	self.enemyinformation_magic_num = self:Child( "enemyinformation-magic-num" );
	self.enemyinformation_magicpower_num = self:Child( "enemyinformation-magicpower-num" );
	self.enemyinformation_corpsscrol = LORD.toScrollPane(self:Child( "enemyinformation-corpsscrol" ));
	self.enemyinformation_corpsscrol:init();

	self.enemyinformation_skillscrol = LORD.toScrollPane(self:Child( "enemyinformation-skillscrol" ));
	self.enemyinformation_skillscrol:init();
		
	self.enemyinformation_skill = {};
	self.enemyinformation_skill_item = {};
	self.enemyinformation_skill_name = {};
	self.enemyinformation_skill_star = {};
	
	--[[
	for i=1, 7 do
		self.enemyinformation_skill[i] = LORD.toStaticImage(self:Child( "enemyinformation-skill"..i ));
		self.enemyinformation_skill_item[i] = LORD.toStaticImage(self:Child( "enemyinformation-skill"..i.."-item" ));
		self.enemyinformation_skill_name[i] = self:Child( "enemyinformation-skill"..i.."-name" );
		self.enemyinformation_skill_star[i] = {};
		for j=1,5 do
			self.enemyinformation_skill_star[i][j] = LORD.toStaticImage(self:Child( "enemyinformation-skill"..i.."-star"..j ));
		end
		
		global.onSkillTipsShow(self.enemyinformation_skill_item[i], "magic", "top");
		global.onTipsHide(self.enemyinformation_skill_item[i]);
	end
	--]]
	
	self.enemyinformation_power_num = self:Child( "enemyinformation-power-num" );
	self.enemyinformation_close = self:Child( "enemyinformation-close" );
	
	self.enemyinformation_close:subscribeEvent( "ButtonClick", "onClose" );
	
	self:onUpdateInfo(event);
	
	function onClose()
		self:onHide();
	end
	
end

function enemyinformation:onHide(event)
	self:Close();
	
	if sceneManager.battlePlayer() then
		sceneManager.battlePlayer():pauseGame(false);
	end
end

function enemyinformation:updateEnemyInfo(enemyData)
		
	--刷新界面
	self.enemyinformation_lv_num:SetText(enemyData.heroLevel);
	self.enemyinformation_magicpower_num:SetText(enemyData.intelligence);

	self.enemyinformation_king_name:SetText(enemyData.kingName)
	self.enemyinformation_king_image:SetImage( global.getHeadIcon (enemyData.kingIcon))
	
	self.enemyinformation_king_container:SetImage(global.getMythsIcon(enemyData.kingMythIcon))
	
	self.enemyinformation_magic_num:SetText(enemyData.mp);
	
	-- 国王技能
	--[==[
	for i=1,7 do
		
		if enemyData.magics[i] and dataConfig.configs.magicConfig[enemyData.magics[i]] then
			local magicInfo = dataConfig.configs.magicConfig[enemyData.magics[i]];
			self.enemyinformation_skill[i]:SetVisible(true);
			self.enemyinformation_skill_item[i]:SetImage(magicInfo.icon);
			self.enemyinformation_skill_name[i]:SetText(magicInfo.name);
			
			self.enemyinformation_skill_item[i]:SetUserData(magicInfo.id);
			
			local userdata2 = dataManager.kingMagic:mergeLevelIntelligence(enemyData.magicLevels[i], enemyData.intelligence);
			self.enemyinformation_skill_item[i]:SetUserData2(userdata2);
			
			for j=1, 5 do
				if enemyData.magicLevels[i] >= j then
					self.enemyinformation_skill_star[i][j]:SetVisible(true);
				else
					self.enemyinformation_skill_star[i][j]:SetVisible(false);
				end
			end
		else
			self.enemyinformation_skill[i]:SetVisible(false);
		end
	end
	--]==]
	
	local xPos = LORD.UDim(0, 0);
	
	for k, v in ipairs(enemyData.magics) do
	
		if v and dataConfig.configs.magicConfig[v] then
			local magicInfo = dataConfig.configs.magicConfig[v];
			
			local magicItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("enemyinformation-"..k,"battleskillitem.dlg");
			local icon = LORD.toStaticImage(self:Child("enemyinformation-"..k.."_battleskillitem-item"));
			local battleskillitem_equity = LORD.toStaticImage(self:Child("enemyinformation-"..k.."_battleskillitem-equity"));
			local name = self:Child("enemyinformation-"..k.."_battleskillitem-name");
			local mask = self:Child("enemyinformation-"..k.."_battleskillitem-xuanzhong");
			local fake = self:Child("enemyinformation-"..k.."_battleskillitem-fake");
			
			fake:SetVisible(false);
			mask:SetVisible(false);
			
			icon:SetImage(magicInfo.icon);
			name:SetText(magicInfo.name);
			
			icon:SetUserData(magicInfo.id);
			
			local userdata2 = dataManager.kingMagic:mergeLevelIntelligence(enemyData.magicLevels[k], enemyData.intelligence);
			icon:SetUserData2(userdata2);
			battleskillitem_equity:SetImage(itemManager.getImageWithStar(enemyData.magicLevels[k]));
			
			for j=1, 5 do
				
				local star = self:Child("enemyinformation-"..k.."_battleskillitem1-star"..j);
				star:SetVisible(enemyData.magicLevels[k] >= j);

			end
			
			magicItem:SetXPosition(xPos);
			magicItem:SetYPosition(LORD.UDim(0, 0));
			
			xPos = xPos + magicItem:GetWidth()+ LORD.UDim(0, 5);
			
			self.enemyinformation_skillscrol:additem(magicItem);

			global.onSkillTipsShow(icon, "magic", "top");
			global.onTipsHide(icon);
			
		end
		
	end

	
	self.corpsitem = {};
	self.corpsitem_icon = {};
	self.corpsitem_name = {};
	self.corpsitem_star = {};
	
	local xPosition = LORD.UDim(0, 5);
	local yPosition = LORD.UDim(0, 5);
	
	
	function onEnemyInfoClickUnit(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local userdata = window:GetUserData();
		
		self:onClickUnitInfo(userdata);
		
	end
	
	-- 军团信息
	for k,v in ipairs(enemyData.units) do
		self.corpsitem[k] = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("enemyinformation-"..k,"corpsitem.dlg");
		self.corpsitem_icon[k] = LORD.toStaticImage(self:Child("enemyinformation-"..k.."_corpsitem-head"));
		self.corpsitem_name[k] = self:Child("enemyinformation-"..k.."_corpsitem-name");
		self.corpsitem_star[k] = {};
		self.corpsitem[k]:SetXPosition(xPosition);
		self.corpsitem[k]:SetYPosition(yPosition);
		
		local corpsitem_equity = LORD.toStaticImage(self:Child("enemyinformation-"..k.."_corpsitem-equity"));
		
		self.corpsitem_icon[k]:subscribeEvent("WindowTouchUp", "onEnemyInfoClickUnit");
		self.corpsitem_icon[k]:SetUserData(k);
		
		self.enemyinformation_corpsscrol:additem(self.corpsitem[k]);
		
		xPosition = xPosition + self.corpsitem[k]:GetWidth() + LORD.UDim(0, -10);
		
		local unitInfo = dataConfig.configs.unitConfig[v];
		self.corpsitem_icon[k]:SetImage(unitInfo.icon);
		self.corpsitem_name[k]:SetText(unitInfo.name);
		
		corpsitem_equity:SetImage(itemManager.getImageWithStar(unitInfo.starLevel));
		
		-- star
		for i=1, 6 do
			self.corpsitem_star[k][i] = self:Child("enemyinformation-"..k.."_corpsitem-star"..i);
			if unitInfo.starLevel >= i then
				self.corpsitem_star[k][i]:SetVisible(true);
			else
				self.corpsitem_star[k][i]:SetVisible(false);
			end
		end
	end
end

function enemyinformation:onUpdateInfo(event)

	-- enemyData 
	--[[
		{
			heroLevel
			mp
			intelligence
			magics = {}
			magicLevels = {}
			units = {}
			playerPower
		}
	--]]
	self.useServerData  = event.useServerData
	self.viewforce = event.force or enum.FORCE.FORCE_GUARD
	
	if(self.useServerData)then
		
		self.enemyinformation_lv:SetText("国王等级:")
		
		if(self.viewforce == battlePlayer.force )then
			self.enemyinformation_lv:SetText("国王等级:")	
		end
		
		
		local enemyData = {};
		local power = 0	
		local enemyData = {};
			  enemyData.magics = {};
			  enemyData.magicLevels = {};
			  enemyData.units = {};
			
		local config = battlePlayer.other_config
		if(self.viewforce == battlePlayer.force )then
			   config = battlePlayer.self_config	
		end
		
		for i,k in ipairs(config)do
			local v = k.id
			local star = dataConfig.configs.unitConfig[v].starLevel
			local quality = dataConfig.configs.unitConfig[v].quality
			local count = k.soldierCount
			enemyData.units[i] = v ;
			local attack = k.shipAttr.attack
			local defence = k.shipAttr.defence
			local critical = k.shipAttr.critical
			local resilience = k.shipAttr.resilience
			power = power +  global.getOneShipPower( star,quality,count,attack,defence,critical,resilience)
		end
		local magicStars = {}
		local m = {}	
		
	 
		if(self.viewforce ==  enum.FORCE.FORCE_ATTACK)then
			m = battlePlayer.attackMagics 
		else
			m = battlePlayer.guardMagics 
		end
 
			
		for i,v in ipairs(m)do
			if(v.id > 0 )then
				table.insert(magicStars,v.level)
			end
			enemyData.magics[i] = v.id
			enemyData.magicLevels[i] = v.level
		end	
		
		local king = dataManager.battleKing[self.viewforce]
		intelligence = 	king:getIntelligence()
		power = power + global.getAllMagicPower(magicStars, intelligence)	
		power =  math.ceil(power)
		self.enemyinformation_power_num:SetText(power)
		enemyData.heroLevel = king:getLevel()
		enemyData.mp = king:getMpMax()
		enemyData.intelligence = intelligence
		enemyData.kingName = king:getName()
		enemyData.kingIcon = king:getHeadIcon()
		enemyData.kingMythIcon = king:getMyths()
		self:updateEnemyInfo(enemyData);
		 
	else
		if event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
			event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE or
			event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT or
			event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED or
			event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE or
			event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE or
			event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
			event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
			event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then
	 
		
			-- 敌人信息从stage表
			local stageInfo = dataConfig.configs.stageConfig[battlePrepareScene.copyID];
			if not stageInfo then
				return;
			end
		 
			local config = clone(stageInfo);
			local power = 0	
			
			local countRate = 1
			if stageInfo.needAdjust and dataManager.playerData:getPlayerConfig() then
			
				local levelAfterAdjust = dataManager.playerData:getLevel() + stageInfo.adjustLevel;
				
				local numberRatio = dataManager.playerData:getPlayerConfig(levelAfterAdjust).numberRatio;
				countRate = numberRatio / 60
				
				config.heroLevel = levelAfterAdjust;
				config.mp = dataManager.playerData:getPlayerConfig(levelAfterAdjust).maxMP;
				config.intelligence = dataManager.playerData:getPlayerConfig(levelAfterAdjust).intelligence
		
			end
	 
			self:updateEnemyInfo(config);
						
			for i,v in ipairs(config.units)do
				local star = dataConfig.configs.unitConfig[v].starLevel
				local quality = dataConfig.configs.unitConfig[v].quality
				local count = math.floor(config.unitCount[i] * countRate) ;
				count = dataConfig.configs.unitConfig[v].food * count 
				
				local attack = config['shipAttrBase'][1].attack
				local defence = config['shipAttrBase'][1].defence
				local critical = config['shipAttrBase'][1].critical
				local resilience = config['shipAttrBase'][1].resilience
				if(battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE)then
					attack = dataManager.hurtRankData:getBossAttChallengeDamageDefence()
					defence = attack
					critical = dataManager.hurtRankData:getBossAttChallengeDamageResilience()
					resilience = critical
				end
				power = power +  global.getOneShipPower( star,quality,count,attack,defence,critical,resilience)
			end
			local magicStars = {}
			for i,v in ipairs(config.magics)do
				if(v > 0 )then
					table.insert(magicStars,config.magicLevels[i])
				end
			end	
			power = power + global.getAllMagicPower(magicStars,config.intelligence)	
			power =  math.ceil(power)
			self.enemyinformation_power_num:SetText(power)
			
		elseif event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE then
			-- 敌人信息从pvp数据
			local adversary = dataManager.pvpData:getSelectPlayer();
			
			if(dataManager.pvpData:getOfflineFuchouFlag())then
				adversary = dataManager.pvpData:getFuchouSelectPlayer();
			end	
			
			local enemyData = {};
			if adversary then
				enemyData.heroLevel = adversary.kingInfo.level;
				enemyData.mp = adversary.kingInfo.maxMP;
				enemyData.intelligence = adversary.kingInfo.intelligence;
				enemyData.magics = {};
				enemyData.magicLevels = {};
				enemyData.units = {};
				enemyData.kingName = adversary:getName()
				enemyData.kingIcon =  adversary:getHeadId()
				enemyData.kingMythIcon = adversary:getMyths()
				for k,v in ipairs(adversary.kingInfo.magics) do
					enemyData.magics[k] = v.id;
					enemyData.magicLevels[k] = v.level;
				end
				
				for k,v in ipairs(adversary.units) do
					enemyData.units[k] =  v.id;
				end
				
				self:updateEnemyInfo(enemyData);
				
				-- playerpower
				self.enemyinformation_power_num:SetText(adversary:playerPower());
			end
		 elseif event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_FIGHT then
			 
			local adversary = dataManager.pvpData:getAskedLadderDetail();
	 
			local enemyData = {};
			if adversary then
				enemyData.heroLevel = adversary.kingInfo.level;
				enemyData.mp = adversary.kingInfo.maxMP;
				enemyData.intelligence = adversary.kingInfo.intelligence;
				enemyData.magics = {};
				enemyData.magicLevels = {};
				enemyData.units = {};
				enemyData.kingName = adversary:getName()
				enemyData.kingIcon =  adversary:getHeadId()
				enemyData.kingMythIcon = adversary:getMyths()
				for k,v in ipairs(adversary.kingInfo.magics) do
					enemyData.magics[k] = v.id;
					enemyData.magicLevels[k] = v.level;
				end
				
				for k,v in ipairs(adversary.units) do
					enemyData.units[k] =  v.id;
				end
				
				self:updateEnemyInfo(enemyData);
				
				-- playerpower
				self.enemyinformation_power_num:SetText(adversary:playerPower());
			end
		
		elseif event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PLUNDER or
						event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_REVENGE then
						
			local targetInfo = dataManager.idolBuildData:getCurrentSelectTargetInfo();
			
			local enemyData = {};
			if targetInfo then
			
				dump(targetInfo);
				
				enemyData.heroLevel = targetInfo.kingInfo.level;
				enemyData.mp = targetInfo.kingInfo.maxMP;
				enemyData.intelligence = targetInfo.kingInfo.intelligence;
				enemyData.magics = {};
				enemyData.magicLevels = {};
				enemyData.units = {};
				enemyData.kingName = targetInfo.name;
				enemyData.kingIcon = targetInfo.icon;
				enemyData.kingMythIcon = 0
				for k,v in ipairs(targetInfo.kingInfo.magics) do
					enemyData.magics[k] = v.id;
					enemyData.magicLevels[k] = v.level;
				end
				
				for k,v in ipairs(targetInfo.units) do
					enemyData.units[k] =  v.id;
				end
				
				self:updateEnemyInfo(enemyData);
				
				-- playerpower
				self.enemyinformation_power_num:SetText(targetInfo.playerPower);
			end			

		elseif event.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR then
						
			local targetInfo = dataManager.guildWarData:getCurrentSelectTargetInfo();
			
			local enemyData = {};
			if targetInfo then
			
				enemyData.heroLevel = targetInfo.kingInfo.level;
				enemyData.mp = targetInfo.kingInfo.maxMP;
				enemyData.intelligence = targetInfo.kingInfo.intelligence;
				enemyData.magics = {};
				enemyData.magicLevels = {};
				enemyData.units = {};
				enemyData.kingName = targetInfo.name;
				enemyData.kingIcon = targetInfo.icon;
				enemyData.kingMythIcon = 0
				for k,v in ipairs(targetInfo.kingInfo.magics) do
					enemyData.magics[k] = v.id;
					enemyData.magicLevels[k] = v.level;
				end
				
				for k,v in ipairs(targetInfo.units) do
					enemyData.units[k] =  v.id;
				end
				
				self:updateEnemyInfo(enemyData);
				
				-- playerpower
				self.enemyinformation_power_num:SetText(targetInfo.playerPower);
			end			
						
		else
		
		end
	end	
end

function enemyinformation:onClickUnitInfo(index)

		
	-- 是否是战斗准备
	if self.event.source == "prepare" then		
		battlePrepareScene.onClickEnemy(6+index);
	else
 
		local space = #battlePlayer.self_config
		if(self.viewforce == enum.FORCE.FORCE_GUARD )then
			    space = #battlePlayer.self_config
		elseif(self.viewforce == enum.FORCE.FORCE_ATTACK )then  
			    space = 0 
		end
		local unitData = sceneManager.battlePlayer().m_AllCrops[space+index-1];
 		
 		if unitData then
 		
 			sceneManager.battlePlayer():pauseGame(true);
 			
 			-- 战斗中通过点击头像查看军团信息
			local shipAttr = {};
			shipAttr.attack = unitData:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK);
			shipAttr.defence = unitData:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE);
			shipAttr.critical = unitData:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL);
			shipAttr.resilience = unitData:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE);
			
			local unitAttr = {};
			unitAttr.soldierDamage = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_DAMAGE);
			unitAttr.defence = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_DEFENCE);
			unitAttr.soldierHP = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_HP);
			unitAttr.actionSpeed = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SPEED);
			unitAttr.moveRange = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_MOVE_RANGE);
		 	unitAttr.attackRange = unitData:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_ATTACK_RANGE);
		 												
 			eventManager.dispatchEvent({name = "CORPSDETAIL_SHOW", unitID = unitData:getUnitID(), 
														 			curUnitNum = unitData.m_CropsNum, totalUnitNum = unitData.m_TotalCropsNum, 
														 			buffList = unitData:getBuffList(), force = unitData:getForces(), shipAttr = shipAttr, unitAttr = unitAttr,
														 			hp = unitData:getTotalHP(), maxHp = unitData:getMaxHP()});
		end
									 						
	end


end

return enemyinformation;
