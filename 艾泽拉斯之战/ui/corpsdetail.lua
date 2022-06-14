local corpsdetail = class( "corpsdetail", layout );

global_event.CORPSDETAIL_SHOW = "CORPSDETAIL_SHOW";
global_event.CORPSDETAIL_HIDE = "CORPSDETAIL_HIDE";

function corpsdetail:ctor( id )
	corpsdetail.super.ctor( self, id );
	self:addEvent({ name = global_event.CORPSDETAIL_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CORPSDETAIL_HIDE, eventHandler = self.onHide});
	
end

function corpsdetail:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	function onTouchDownBuff(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
		local userdata = clickImage:GetUserData();
		local buffInstance = self.buffList[userdata];
		
		if buffInstance then
			local rect = clickImage:GetUnclippedOuterRect();
			eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "buff", id = buffInstance.buffID, buffInstance = buffInstance, force = self.force, windowRect = rect, dir = "top"});
		end
	end

	function onCorpsDetailTouchDownUnitSkill(args)
	  local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData();
 		
 		local rect = clickImage:GetUnclippedOuterRect();
 		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "skill", id = userdata, tipXPosition = rect.left, tipYBottom = rect.top});
	end
		
	function onCorpsDetailTouchUpUnitSkill()
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
	
	function onTouchUpBuff()
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
	 
	self.corpsdetail_actor = LORD.toStaticImage(self:Child( "corpsdetail-actor" ));
	self.corpsdetail_equity = LORD.toStaticImage(self:Child( "corpsdetail-equity" ));
	
	self.corpsdetail_actor_star = {};
	for i=1, 6 do
		self.corpsdetail_actor_star[i] = LORD.toStaticImage(self:Child( "corpsdetail-actor-star"..i ));
	end

	-- 攻击方式
	self.corpsdetail_rangetype = LORD.toStaticImage(self:Child("corpsdetail-rangetype"));
	self.corpsdetail_atktype = LORD.toStaticImage(self:Child("corpsdetail-atktype"));
	self.corpsdetail_movetype = LORD.toStaticImage(self:Child("corpsdetail-movetype"));
	
	self.corpsdetail_actor_name = self:Child( "corpsdetail-actor-name" );
	self.corpsdetail_ship = LORD.toStaticImage(self:Child( "corpsdetail-ship" ));
	self.corpsdetail_race = self:Child( "corpsdetail-race" );
	self.corpsdetail__range_num = self:Child( "corpsdetail-range-num" );
	self.corpsdetail_num = self:Child( "corpsdetail-num" );
	self.corpsdetail_att_num = self:Child( "corpsdetail-att-num" );
	self.corpsdetail_def_num = self:Child( "corpsdetail-def-num" );
	self.corpsdetail_hit_num = self:Child( "corpsdetail-hit-num" );
	self.corpsdetail_speed_num = self:Child( "corpsdetail-speed-num" );
	self.corpsdetail_move_num = self:Child( "corpsdetail-move-num" );
	self.corpsdetail_attlv_num = self:Child( "corpsdetail-attlv-num" );
	self.corpsdetail_deflv_num = self:Child( "corpsdetail-deflv-num" );
	self.corpsdetail_crit_num = self:Child( "corpsdetail-crit-num" );
	self.corpsdetail_ten_num = self:Child( "corpsdetail-ten-num" );
	
	-- buff附加信息
	self.corpsdetail_hit_arrow = LORD.toStaticImage(self:Child("corpsdetail-hit-arrow"));
	self.corpsdetail_att_arrow = LORD.toStaticImage(self:Child("corpsdetail-att-arrow"));
	self.corpsdetail_def_arrow = LORD.toStaticImage(self:Child("corpsdetail-def-arrow"));
	self.corpsdetail_speed_arrow = LORD.toStaticImage(self:Child("corpsdetail-speed-arrow"));
	self.corpsdetail_move_arrow = LORD.toStaticImage(self:Child("corpsdetail-move-arrow"));
	self.corpsdetail_range_arrow = LORD.toStaticImage(self:Child("corpsdetail-range-arrow"));
	
	self.corpsdetail_hit_arrow_num = self:Child("corpsdetail-hit-arrow-num");
	self.corpsdetail_att_arrow_num = self:Child("corpsdetail-att-arrow-num");
	self.corpsdetail_def_arrow_num = self:Child("corpsdetail-def-arrow-num");
	self.corpsdetail_speed_arrow_num = self:Child("corpsdetail-speed-arrow-num");
	self.corpsdetail_move_arrow_num = self:Child("corpsdetail-move-arrow-num");
	self.corpsdetail_range_arrow_num = self:Child("corpsdetail-range-arrow-num");
	
	self.corpsdetail_power_num = self:Child( "corpsdetail-power-num" );
	self.corpsdetail_life_bar = self:Child( "corpsdetail-life-bar" );
	
	self.corpsdetail_skill = {};
	self.corpsdetail_skill_item = {};
	
	self.corpsdetail_skill = LORD.toScrollPane(self:Child("corpsdetail-skill"));
	self.corpsdetail_skill:init();
		
	self.corpsdetail_buff = LORD.toScrollPane(self:Child("corpsdetail-buff"));
	self.corpsdetail_buff:init();
	
	--[[ 
	for i=1, 4 do
		self.corpsdetail_skill[i] = LORD.toStaticImage(self:Child( "corpsdetail-skill"..i ));
		self.corpsdetail_skill_item[i] = LORD.toStaticImage(self:Child( "corpsdetail-skill"..i.."-item" ));
		--self.corpsdetail_skill_item[i]:subscribeEvent("WindowTouchDown", "onCorpsDetailTouchDownUnitSkill");
		--self.corpsdetail_skill_item[i]:subscribeEvent("WindowTouchUp", "onCorpsDetailTouchUpUnitSkill");
		--self.corpsdetail_skill_item[i]:subscribeEvent("MotionRelease", "onCorpsDetailTouchUpUnitSkill");
		global.onSkillTipsShow(self.corpsdetail_skill_item[i], "skill", "top");
		global.onTipsHide(self.corpsdetail_skill_item[i]);
	end
	--]]
	
	self.corpsdetail_close = self:Child( "corpsdetail-close" );
	
	self.corpsdetail_close:subscribeEvent( "ButtonClick", "oncorpsdetailClose" );
	
	--self.shipIndex = event.shipIndex;
	self.buffList = event.buffList;
	--print("event.unitID "..event.unitID);
	self.force = event.force;
	self.force = self.force or enum.FORCE.FORCE_ATTACK;
	
	self:onUpdateUnitInfo(event);
	
	function oncorpsdetailClose()
		self:onHide();
	end
	
end

function corpsdetail:onHide(event)
	
	if sceneManager.battlePlayer() then
		sceneManager.battlePlayer():pauseGame(false);
	end
	self:Close();
	--新手引导事件：关闭信息界面
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_CORPSDETAIL_CLOSE})
end

function corpsdetail:onUpdateUnitInfo(event)
	
	local unitID = event.unitID;
	local curUnitNum = event.curUnitNum;
	local totalUnitNum = event.totalUnitNum;
	local shipAttr = event.shipAttr;
	local unitAttr = event.unitAttr;
	local hp = event.hp;
	local maxHp = event.maxHp;
	
	local unitInfo = dataConfig.configs.unitConfig[unitID];
	if not unitInfo then
		return;
	end
	
	local raceMap = {
		[0] = "人类",
		[1] = "兽族",
		[2] = "暗夜",
		[3] = "不死",
		[4] = "特殊",
	};


	local isRange = 0;
	if unitInfo.isRange == true then
		isRange = 1;
	end
		
	self.corpsdetail_rangetype:SetImage(enum.unitIsRangeImageMap[isRange]);
	self.corpsdetail_atktype:SetImage(enum.unitDamageTypeImageMap[unitInfo.damageType]);
	self.corpsdetail_movetype:SetImage(enum.unitMoveTypeImageMap[unitInfo.moveType]);
		
	self.corpsdetail_race:SetText(raceMap[unitInfo.race]);

	-- 星级
	for i=1, 6 do
		self.corpsdetail_actor_star[i]:SetVisible(false);
	end
	
	for i=1, unitInfo.starLevel do
		self.corpsdetail_actor_star[i]:SetVisible(true);
	end
	
	--self.corpsdetail_actor:SetActor(unitInfo.resourceName, "idle");
	self.corpsdetail_actor:SetImage(unitInfo.icon);
	self.corpsdetail_equity:SetImage(itemManager.getImageWithStar(unitInfo.starLevel));
	
	self.corpsdetail_actor_name:SetText(unitInfo.name);
	
	self.corpsdetail_num:SetText(curUnitNum.."/"..totalUnitNum);
	
	if hp and maxHp then
		self.corpsdetail_life_bar:SetProperty("Progress", hp/maxHp);
	end
	
	if unitAttr then
		
		--dump(unitAttr);
		
		function corpsdetailUnitAttrCalc(windowArrow, windowText, value1, value2)
			if windowArrow and windowText and value1 and value2 then
				if value1 > value2 then
					windowArrow:SetVisible(true);
					windowText:SetText(value1-value2);
					windowArrow:SetImage("set:common.xml image:jiantou1");
				elseif value1 < value2 then
					windowArrow:SetVisible(true);
					windowText:SetText(value2-value1);
					windowArrow:SetImage("set:common.xml image:jiantou2");
				else
					windowArrow:SetVisible(false);
				end
			end
		end
		
		function corpsDetailAttrCalc(window, value1, value2)
			
			if value1 > value2 then
				window:SetText("^00FF00"..value1);
			elseif value1 < value2 then
				window:SetText("^FF0000"..value1);
			else
				window:SetText(value1);
			end
			
		end
		
		
		unitAttr.soldierDamage = unitAttr.soldierDamage or unitInfo.soldierDamage;
		unitAttr.defence = unitAttr.defence or unitInfo.defence;
		unitAttr.soldierHP = unitAttr.soldierHP or unitInfo.soldierHP;
		unitAttr.actionSpeed = unitAttr.actionSpeed or unitInfo.actionSpeed;
		unitAttr.moveRange = unitAttr.moveRange or unitInfo.moveRange;
		unitAttr.attackRange = unitAttr.attackRange or unitInfo.attackRange;
		
		--self.corpsdetail_att_num:SetText(unitAttr.soldierDamage);
		--self.corpsdetail_def_num:SetText(unitAttr.defence);
		--self.corpsdetail_hit_num:SetText(unitAttr.soldierHP);
		--self.corpsdetail_speed_num:SetText(unitAttr.actionSpeed);
		--self.corpsdetail_move_num:SetText(unitAttr.moveRange);
		--self.corpsdetail__range_num:SetText(unitAttr.attackRange);
		
		--corpsdetailUnitAttrCalc(self.corpsdetail_hit_arrow, self.corpsdetail_hit_arrow_num, unitAttr.soldierHP, unitInfo.soldierHP);
		--corpsdetailUnitAttrCalc(self.corpsdetail_att_arrow, self.corpsdetail_att_arrow_num, unitAttr.soldierDamage, unitInfo.soldierDamage);
		--corpsdetailUnitAttrCalc(self.corpsdetail_def_arrow, self.corpsdetail_def_arrow_num, unitAttr.defence, unitInfo.defence);
		--corpsdetailUnitAttrCalc(self.corpsdetail_speed_arrow, self.corpsdetail_speed_arrow_num, unitAttr.actionSpeed, unitInfo.actionSpeed);
		--corpsdetailUnitAttrCalc(self.corpsdetail_move_arrow, self.corpsdetail_move_arrow_num, unitAttr.moveRange, unitInfo.moveRange);
		--corpsdetailUnitAttrCalc(self.corpsdetail_range_arrow, self.corpsdetail_range_arrow_num, unitAttr.attackRange, unitInfo.attackRange);
		corpsDetailAttrCalc(self.corpsdetail_att_num, unitAttr.soldierDamage, unitInfo.soldierDamage);
		corpsDetailAttrCalc(self.corpsdetail_def_num, unitAttr.defence, unitInfo.defence);
		corpsDetailAttrCalc(self.corpsdetail_hit_num, unitAttr.soldierHP, unitInfo.soldierHP);
		
		corpsDetailAttrCalc(self.corpsdetail_speed_num, unitAttr.actionSpeed, unitInfo.actionSpeed);
		corpsDetailAttrCalc(self.corpsdetail_move_num, unitAttr.moveRange, unitInfo.moveRange);
		corpsDetailAttrCalc(self.corpsdetail__range_num, unitAttr.attackRange, unitInfo.attackRange);
		
	else
		self.corpsdetail_att_num:SetText(unitInfo.soldierDamage);
		self.corpsdetail_def_num:SetText(unitInfo.defence);
		self.corpsdetail_hit_num:SetText(unitInfo.soldierHP);
		self.corpsdetail_speed_num:SetText(unitInfo.actionSpeed);
		self.corpsdetail_move_num:SetText(unitInfo.moveRange);
		self.corpsdetail__range_num:SetText(unitInfo.attackRange);
		
		self.corpsdetail_hit_arrow:SetVisible(false);
		self.corpsdetail_att_arrow:SetVisible(false);
		self.corpsdetail_def_arrow:SetVisible(false);
		self.corpsdetail_speed_arrow:SetVisible(false);
		self.corpsdetail_move_arrow:SetVisible(false);
		self.corpsdetail_range_arrow:SetVisible(false);
	end
	
	if(unitID == dataManager.hurtRankData:getBossId())then
		if(shipAttr and battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE)then
			shipAttr.attack =   dataManager.hurtRankData:getBossAttChallengeDamageDefence()
		end
		if(shipAttr and battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE)then
			shipAttr.defence =   dataManager.hurtRankData:getBossAttChallengeDamageDefence()
		end
		
		if(shipAttr and battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE)then
			shipAttr.critical =   dataManager.hurtRankData:getBossAttChallengeDamageResilience()
		end
		if(shipAttr and battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE)then
			shipAttr.resilience =   dataManager.hurtRankData:getBossAttChallengeDamageResilience()
		end
	end
	
	
	if shipAttr and shipAttr.attack and shipAttr.attack > 0 then
		self.corpsdetail_attlv_num:SetText(shipAttr.attack);
	else
		self.corpsdetail_attlv_num:SetText(0);		
	end

	if shipAttr and shipAttr.defence and shipAttr.defence > 0 then
		self.corpsdetail_deflv_num:SetText(shipAttr.defence);
	else
		self.corpsdetail_deflv_num:SetText(0);		
	end
	
	if shipAttr and shipAttr.critical and shipAttr.critical > 0 then
		self.corpsdetail_crit_num:SetText(shipAttr.critical);
	else
		self.corpsdetail_crit_num:SetText(0);		
	end
	
	if shipAttr and shipAttr.resilience and shipAttr.resilience > 0 then
		self.corpsdetail_ten_num:SetText(shipAttr.resilience);
	else
		self.corpsdetail_ten_num:SetText(0);		
	end
	
	
	-- 技能
	self.corpsdetail_skill:ClearAllItem();
	
	local xpos = LORD.UDim(0, 0);
	local ypos = LORD.UDim(0, 0);
			
	for k, v in ipairs(unitInfo.skill) do
		local skillitem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("corpsdetail-skill-"..k, "skillitem.dlg");
		local skillitem_head = LORD.toStaticImage(self:Child("corpsdetail-skill-"..k.."_skillitem-head"));
		local skillitem_name = self:Child("corpsdetail-skill-"..k.."_skillitem-name");
		local skillitem_back = LORD.toStaticImage(self:Child("corpsdetail-skill-"..k.."_skillitem-back"));

		local skillInfo = dataConfig.configs.skillConfig[v];
		skillitem_head:SetImage(skillInfo.icon);
		skillitem_name:SetText(skillInfo.name);
		skillitem_head:SetUserData(skillInfo.id);
					
		skillitem:SetPosition(LORD.UVector2(xpos, ypos));
		
		self.corpsdetail_skill:additem(skillitem);
		
		xpos =  xpos + skillitem:GetWidth();
		
		global.onSkillTipsShow(skillitem_head, "skill", "top");
		global.onTipsHide(skillitem_head);
				
	end
 
	local star = unitInfo.starLevel
	local quality = unitInfo.quality
	local count = curUnitNum
	count = unitInfo.food * count 
	local 	power =  global.getOneShipPower( star,quality,count,shipAttr.attack ,shipAttr.defence,shipAttr.critical,shipAttr.resilience)
	power =  math.ceil(power)
	self.corpsdetail_power_num:SetText(power)
	
	
	-- buff info 
	self:updateBuffList();
	
  --新手引导事件：打开信息界面
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_CORPSDETAIL_OPEN ,arg1 = event.unitID })
end

function corpsdetail:updateBuffList()
	
	if self.buffList then
		-- buff list
		local xpos = LORD.UDim(0, 0);
		local ypos = LORD.UDim(0, 0);
		for k,v in ipairs(self.buffList) do
			
			local buffInfo = dataConfig.configs.buffConfig[v.buffID];
			local notGM = (string.find(buffInfo.name, "gm")~=1 and string.find(buffInfo.name, "GM")~=1 and
										string.find(buffInfo.name, "Gm")~=1 and string.find(buffInfo.name, "gM")~=1 );
			
			if buffInfo and buffInfo.hideIcon == false and notGM then
			 	local buffIcon = LORD.GUIWindowManager:Instance():GetGUIWindow("corpsdetail-buff-"..k.."_buff");
			 	if buffIcon == nil then
			 		buffIcon = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("corpsdetail-buff-"..k, "buff.dlg");
			 	end
			 	
			 	buffIcon:SetPosition(LORD.UVector2(xpos, ypos));
			 	self.corpsdetail_buff:additem(buffIcon);
			 	local width = buffIcon:GetWidth();
			 	xpos = xpos + width;
			 	
			 	local buffIconImage = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("corpsdetail-buff-"..k.."_buff-tubiao"));
			 	local buffNum = LORD.GUIWindowManager:Instance():GetGUIWindow("corpsdetail-buff-"..k.."_buff-num");
			
			 	if buffInfo then
			 		buffIconImage:SetImage(buffInfo.icon);
			 		buffIconImage:subscribeEvent("WindowTouchDown", "onTouchDownBuff");
					buffIconImage:subscribeEvent("WindowTouchUp", "onTouchUpBuff");
					buffIconImage:subscribeEvent("MotionRelease", "onTouchUpBuff");
					buffIconImage:SetUserData(k);
			 	end
			 	
			 	buffNum:SetText(v.buffLayer);
			 	
			 	if v.buffLayer == 1 or buffInfo.hideLayer == true then
			 		buffNum:SetVisible(false);
			 	else
			 		buffNum:SetVisible(true);
			 	end
			 	
			end
		end
	end
end

return corpsdetail;
