battlePrepareScene = {};

--地图 目前是7*3格子
battlePrepareScene.map = nil;
battlePrepareScene.grid = nil;
battlePrepareScene.centerPosition = LORD.Vector3(0,0,0);
battlePrepareScene.hexagonWidth = 2.8;
battlePrepareScene.hexagonHeight = 5.5;
-- 这个scale只是调整特效的显示比例
battlePrepareScene.hexagonScale = 2.7;
battlePrepareScene.centerX = 3;
battlePrepareScene.centerY = 1;
battlePrepareScene.unitData = {};
battlePrepareScene.copyID = -1;
battlePrepareScene.draggingShip = -1;
battlePrepareScene.preSwapShip = -1;
battlePrepareScene.battleType = enum.BATTLE_TYPE.BATTLE_TYPE_INVALID;
battlePrepareScene.sceneID = 4;
battlePrepareScene.actorYOffset = 1.5;

function battlePrepareScene.isAdventureBattleType()
	return battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
		battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE;
end

function battlePrepareScene.isPvPOnlineBattleType()
	return battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE
		 
end

function battlePrepareScene.isPvPofflineBattleType()
	return battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE
		 
end

function battlePrepareScene.getBattleType()
	return battlePrepareScene.battleType
end

function battlePrepareScene.onEnter(battleType,planType)
	
	global.changeGameState(function() 
		eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_HIDE});
		eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});		
	
		local _type =  battleType or  enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE 
		if( _type == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE and    dataManager.playerData.stageInfo and dataManager.playerData.stageInfo:getType() == enum.Adventure_TYPE.ELITE )then
			_type = enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE 
		end
				
		game.EnterProcess(game.GAME_STATE_BATTLE_PREPARE, { battleType = _type, planType = planType or enum.PLAN_TYPE.PLAN_TYPE_PVE});	
	end)
end

function battlePrepareScene.sceneInit(battleType, planType)
	
	-- 清理上一次的战斗数据
	battlePlayer.win = nil;
	battlePlayer.battleType = nil;
	
	battlePrepareScene.battleType = battleType;
	PLAN_CONFIG.currentPlanType = planType;

 	-- 需要根据类型类初始化场景的相关信息
 	-- 如果是副本，就是从stage信息里搞，
 	-- 如果是领地，就是从主基地的信息里搞
 	-- pvp的不知道
 	
 	if battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
 		 battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE then
 		if dataManager.playerData.stageInfo then
			battlePrepareScene.copyID = dataManager.playerData.stageInfo:getId();
		end
 	elseif battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT then
 		battlePrepareScene.copyID = dataManager.mainBase:getCurrentIncidentStageID();
 		print("battlePrepareScene.copyID "..battlePrepareScene.copyID);
 	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED then
		battlePrepareScene.copyID = dataManager.playerData:getSpeedChallegeStageID(dataManager.playerData:getSpeedChallengeStage());
		print("battlePrepareScene.copyID");
		print(battlePrepareScene.copyID);
		
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE then
		battlePrepareScene.copyID = dataManager.hurtRankData:getStageId();
 	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
 				battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
 				battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then
 		battlePrepareScene.copyID = dataManager.playerData:getChallegeStageInfo(battlePrepareScene.battleType, dataManager.playerData:getChallegeStageIndex()).id;
 	
 	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE then
 		-- 远征活动
 		battlePrepareScene.copyID = dataManager.crusadeActivityData:getCurrentStageID();
 		
 	else
 		battlePrepareScene.copyID = -1;
 	end
	
	print("battlePrepareScene.copyID "..battlePrepareScene.copyID);
	-- 地形信息map 相关
	-- grid 信息
	battlePrepareScene.map = HexagonMap:new()
	battlePrepareScene.map:loadFromFile("BattleBase.map")
	battlePrepareScene.grid = HexagonGrid:new();
	battlePrepareScene.centerPosition = 
										battlePrepareScene.grid:init( battlePrepareScene.map, battlePrepareScene.hexagonWidth, 
																	  battlePrepareScene.hexagonHeight, battlePrepareScene.hexagonScale, 
																	  battlePrepareScene.centerPosition, 	battlePrepareScene.centerX, battlePrepareScene.centerY );												
																			
	------------------------------------------------------------------------------------------
	
	-- 初始化场景
	local sceneID = 5;
	if battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE then
			
		local stageInfo = dataConfig.configs.stageConfig[battlePrepareScene.copyID];
		if stageInfo then
			sceneID = stageInfo.sceneID;
		end		
	 
	elseif battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE or 
				battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE or
				battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PLUNDER or
				battleType == enum.BATTLE_TYPE.BATTLE_TYPE_REVENGE then
		sceneID = enum.BATTLE_PVP_SCENE_ID;
	
	elseif battleType == enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR then
		
		local spot = dataManager.guildWarData:getSelectSpot();
		sceneID = spot:getConfig().sceneID;
		
	else
	
	end
	
	-- 备份起来，战斗的时候需要重新创建
	battlePrepareScene.sceneID = sceneID;
	
	local sceneInfo = dataConfig.configs.sceneConfig[sceneID];
	local cameraPos = LORD.Vector3(sceneInfo.cameraPosition[1], sceneInfo.cameraPosition[2], sceneInfo.cameraPosition[3]);
	local cameraDir = LORD.Vector3(sceneInfo.cameraDriection[1], sceneInfo.cameraDriection[2], sceneInfo.cameraDriection[3]);
			
	engine.playBackgroundMusic(sceneInfo.music, true);
	
	sceneManager.loadScene(sceneInfo.scene);
	
	local camera = LORD.SceneManager:Instance():getMainCamera();	
	camera:setPosition(cameraPos)
	camera:setDirection(cameraDir)
	camera:setNearClip(1);
	camera:setFarClip(300);				
	
	-- 初始化敌方军团
	if battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL or
			battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE then
			
		local stageInfo = dataConfig.configs.stageConfig[battlePrepareScene.copyID];
		if stageInfo then
			 
			-- 初始化副本actor
			for k,v in ipairs(stageInfo.units) do
				local count = stageInfo.unitCount[k];
				local positionsX = stageInfo.positionsX[k];
				local positionsY = stageInfo.positionsY[k];
				local shipAttr = {
					attack = stageInfo.shipAttrBase[1].attack or 0;
					defence = stageInfo.shipAttrBase[1].defence or 0;
					critical = stageInfo.shipAttrBase[1].critical or 0;
					resilience = stageInfo.shipAttrBase[1].resilience or 0;
				};
				
				if stageInfo.needAdjust and dataManager.playerData:getPlayerConfig() then
				 
					-- 需要乘以额外的系数
					local numberRatio = 1;
					if dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel() + stageInfo.adjustLevel) then 
						numberRatio = dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel() + stageInfo.adjustLevel).numberRatio;
					end
				 
					count = math.floor(count * numberRatio / 60);
					shipAttr.attack = dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel() + stageInfo.adjustLevel).shipAttrBase[1].attack;
					shipAttr.defence = dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel() + stageInfo.adjustLevel).shipAttrBase[1].defence;
					shipAttr.critical = dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel() + stageInfo.adjustLevel).shipAttrBase[1].critical;
					shipAttr.resilience = dataManager.playerData:getPlayerConfig(dataManager.playerData:getLevel() + stageInfo.adjustLevel).shipAttrBase[1].resilience;
				end
				
				-- 敌方的索引直接从7开始
				local unitIndex = k+6;
				-- 所有的用同一个shipAttr
				battlePrepareScene.initUnit(unitIndex, v, count, positionsX, positionsY, enum.FORCE.FORCE_GUARD, shipAttr);
			end
	  end
	
	elseif battleType == enum.BATTLE_TYPE.BATTLE_TYPE_FIGHT then --切磋
		 local  adversary = dataManager.pvpData:getAskedLadderDetail();
		 if( adversary and adversary.units )then
	
			for k,v in ipairs(adversary.units) do
				local count = v.count;
				local positionsX = v.pos.x;
				local positionsY = v.pos.y;
				local shipAttr = {
					attack = v.shipAttr.attack;
					defence = v.shipAttr.defence;
					critical = v.shipAttr.critical;
					resilience = v.shipAttr.resilience;
				};
				-- 敌方的索引直接从7开始
				local unitIndex = k+6;
				-- 所有的用同一个shipAttr
				battlePrepareScene.initUnit(unitIndex, v.id, count, positionsX, positionsY, enum.FORCE.FORCE_GUARD, shipAttr);			
			end
		end
	
	
	elseif battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE and
				planType == enum.PLAN_TYPE.PLAN_TYPE_PVE then
		
			local adversary = nil
		if(dataManager.pvpData:getOfflineFuchouFlag())then
		 	  adversary = dataManager.pvpData:getFuchouSelectPlayer();
		else 	
			-- 离线pvp，敌方数据
			  adversary = dataManager.pvpData:getSelectPlayer();
		end
		if(	adversary and adversary.units )then
	
			for k,v in ipairs(adversary.units) do
				local count = v.count;
				local positionsX = v.pos.x;
				local positionsY = v.pos.y;
				local shipAttr = {
					attack = v.shipAttr.attack;
					defence = v.shipAttr.defence;
					critical = v.shipAttr.critical;
					resilience = v.shipAttr.resilience;
				};
				-- 敌方的索引直接从7开始
				local unitIndex = k+6;
				-- 所有的用同一个shipAttr
				battlePrepareScene.initUnit(unitIndex, v.id, count, positionsX, positionsY, enum.FORCE.FORCE_GUARD, shipAttr);			
			end
		end
	
	elseif battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PLUNDER or 
					battleType == enum.BATTLE_TYPE.BATTLE_TYPE_REVENGE then
			
			local targetInfo = dataManager.idolBuildData:getCurrentSelectTargetInfo();
			
			for k,v in ipairs(targetInfo.units) do
				local count = v.count;
				local positionsX = v.position.x;
				local positionsY = v.position.y;
				local shipAttr = {
					attack = v.shipAttr.attack;
					defence = v.shipAttr.defence;
					critical = v.shipAttr.critical;
					resilience = v.shipAttr.resilience;
				};
				-- 敌方的索引直接从7开始
				local unitIndex = k+6;
				-- 所有的用同一个shipAttr
				battlePrepareScene.initUnit(unitIndex, v.id, count, positionsX, positionsY, enum.FORCE.FORCE_GUARD, shipAttr);			
			end
	
	elseif battleType == enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR then
	
		local targetInfo = dataManager.guildWarData:getCurrentSelectTargetInfo();
		
		for k,v in ipairs(targetInfo.units) do
			local count = v.count;
			local positionsX = v.position.x;
			local positionsY = v.position.y;
			local shipAttr = {
				attack = v.shipAttr.attack;
				defence = v.shipAttr.defence;
				critical = v.shipAttr.critical;
				resilience = v.shipAttr.resilience;
			};
			-- 敌方的索引直接从7开始
			local unitIndex = k+6;
			-- 所有的用同一个shipAttr
			battlePrepareScene.initUnit(unitIndex, v.id, count, positionsX, positionsY, enum.FORCE.FORCE_GUARD, shipAttr);			
		end
				
	end
			
	-- 初始化己方军团
	if PLAN_CONFIG.currentPlanType ~= enum.PLAN_TYPE.PLAN_TYPE_PVE and PLAN_CONFIG.isShipsPlanEmpty(PLAN_CONFIG.currentPlanType) then
		PLAN_CONFIG.copyPlan(enum.PLAN_TYPE.PLAN_TYPE_PVE, PLAN_CONFIG.currentPlanType);
	end
	
	local shipPlan = PLAN_CONFIG.getPlan(PLAN_CONFIG.currentPlanType).shipPlans;

	-- 从配置初始化场景
	for k, v in ipairs(shipPlan) do							
		
		if v.cardID > 0 then
		
			local unitID = cardData.getCardInstance(v.cardID):getUnitID();
			local unitX = v.x;
			local unitY = v.y;
			local unitCount = PLAN_CONFIG.getShipUnitNumber(k);
			
			battlePrepareScene.initUnit(k, unitID, unitCount, unitX, unitY, enum.FORCE.FORCE_ATTACK);
			
			if unitX == -1 or unitY == -1 then
				print("battlePrepareScene.sceneInit error unitX == -1 or unitY == -1 ");
			end
		else
			battlePrepareScene.initUnit(k, -1, 0, -1, -1, enum.FORCE.FORCE_ATTACK);
		end
			
	end
	battlePrepareScene.ReplaySummaryIndex = nil
	-- 根据类型区分
	if battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE then
		battlePrepareScene.ReplaySummaryIndex = dataManager.playerData.stageInfo:getAdventureID();
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED then
  
		battlePrepareScene.ReplaySummaryIndex = dataManager.playerData:getSpeedChallengeStage() + 1;
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE then
		battlePrepareScene.ReplaySummaryIndex = dataManager.hurtRankData:getStageId();
		
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE then
		
		battlePrepareScene.ReplaySummaryIndex = dataManager.crusadeActivityData:getCurrentStageIndex();
		
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
					battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
					battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then
		battlePrepareScene.ReplaySummaryIndex = dataManager.playerData:getChallegeStageIndex();
	 
	end
	
	-- 更新船的effect
	battlePrepareScene.updateShipGridEffect();
	
	eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_SHOW, battleType = battlePrepareScene.battleType, planType = planType });
	
	local showHint = true
	if(battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE and  planType == enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_GUARD)then
		showHint = false
	elseif(battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE )then
		showHint = false
	end
	
	if(showHint and battlePlayer.rePlayStatus ~= true )then
		eventManager.dispatchEvent({name = global_event.BATTLEHINT_SHOW, hintType = "prepare"});
	end
	
	
	
	--scheduler.performWithDelayGlobal(function() 
	--	eventManager.dispatchEvent({name = global_event.BATTLEHINT_SHOW, hintType = "prepare"});		
	--end, 2)

	-- 新手引导事件：进入备战界面
	if battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE then
		local adID = dataManager.playerData.stageInfo:getAdventureID()
		local score = dataManager.playerData.stageInfo:getScore()
		scheduler.performWithDelayGlobal(function ()
			--eventManager.dispatchEvent( {name =  global_event.GUIDE_ON_ENTER_BATTLEPREPARE, arg1 = battlePrepareScene.copyID,arg2 = score } )  
			eventManager.dispatchEvent( {name =  global_event.GUIDE_ON_ENTER_BATTLEPREPARE, arg1 = adID,arg2 = score } )  
		end, 0.2);
	end
	if battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL then
		local sID = battlePrepareScene.copyID
		--scheduler.performWithDelayGlobal(function ()
			eventManager.dispatchEvent( {name =  global_event.GUIDE_ON_ENTER_CHALLENGE_STAGE_NORMAL_BATTLEPREPARE, arg1 = sID } )  
		--end, 0.2);
	end	
	
	if battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED then
			eventManager.dispatchEvent( {name =  global_event.GUIDE_ON_ENTER_CHALLENGE_SPEED_BATTLEPREPARE } )  
	end
	--
	eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_REFRESH_UNIT,});
 
	

end

-- 关闭场景, 
function battlePrepareScene.closePrepareScene()
	
	-- 发送配置到服务器
	battlePrepareScene.destroyUnitData();
	
	sceneManager.closeScene();
	
	if battlePrepareScene.map then
		battlePrepareScene.map:delete();
		battlePrepareScene.map = nil;
	end
	
	if battlePrepareScene.grid then
		battlePrepareScene.grid:delete();
		battlePrepareScene.grid = nil;
	end

end

-- 为了回放录像，根据场景的id初始化场景
function battlePrepareScene.sceneInitBySceneID()
	
	-- 地形信息map 相关
	-- grid 信息
	local sceneID = battlePrepareScene.sceneID;
	
	if battlePrepareScene.map == nil then
		battlePrepareScene.map = HexagonMap:new()
		battlePrepareScene.map:loadFromFile("BattleBase.map")
	end
	
	if 	battlePrepareScene.grid == nil then
		battlePrepareScene.grid = HexagonGrid:new();
		battlePrepareScene.centerPosition = 
											battlePrepareScene.grid:init( battlePrepareScene.map, battlePrepareScene.hexagonWidth, 
																		  battlePrepareScene.hexagonHeight, battlePrepareScene.hexagonScale, 
																		  battlePrepareScene.centerPosition, 	battlePrepareScene.centerX, battlePrepareScene.centerY );												
	end
																			
	------------------------------------------------------------------------------------------
	
	-- 初始化场景
	local sceneInfo = dataConfig.configs.sceneConfig[sceneID];
	local cameraPos = LORD.Vector3(sceneInfo.cameraPosition[1], sceneInfo.cameraPosition[2], sceneInfo.cameraPosition[3]);
	local cameraDir = LORD.Vector3(sceneInfo.cameraDriection[1], sceneInfo.cameraDriection[2], sceneInfo.cameraDriection[3]);
	--engine.playBackgroundMusic(sceneInfo.music, true);
	sceneManager.loadScene(sceneInfo.scene);
	engine.playBackgroundMusic(sceneInfo.music, true);
	local camera = LORD.SceneManager:Instance():getMainCamera();	
	camera:setPosition(cameraPos);
	camera:setDirection(cameraDir);
	camera:setNearClip(1);
	camera:setFarClip(300);
end

function battlePrepareScene.initUnit(unitIndex, unitID, count, positionsX, positionsY, force, shipAttr)

		battlePrepareScene.unitData[unitIndex] = {
			['actor'] = nil,
			['ui'] = nil,
			['unitIndex'] = unitIndex,
			['unitID'] = unitID,
			['count'] = count,
			['x'] = positionsX,
			['y'] = positionsY,
			['force'] = force,
		};
		
		if shipAttr then
			battlePrepareScene.unitData[unitIndex].shipAttr = shipAttr;
		end
		
		--print("battlePrepareScene initUnit unitIndex "..unitIndex);
							
		battlePrepareScene.unitData[unitIndex].ui = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("battlePrepare-"..unitIndex, "soldiernum.dlg");
		battlePrepareScene.unitData[unitIndex].ui:SetVisible(false);
		battlePrepareScene.unitData[unitIndex].ui:SetLevel(100);
		engine.uiRoot:AddChildWindow(battlePrepareScene.unitData[unitIndex].ui);
		battlePrepareScene.unitData[unitIndex].ui:SetText(count);

		local unitInfo = dataConfig.configs.unitConfig[unitID];
		if not unitInfo then
			return;
		end
		
		local actorName = unitInfo.resourceName;
		local modelScaling = unitInfo.modelScaling;
		
		battlePrepareScene.unitData[unitIndex].actor = LORD.ActorManager:Instance():CreateActor(actorName, "idle", false);
		battlePrepareScene.unitData[unitIndex].actor:SetUserData(unitIndex);
							
		local position = battlePrepareScene.grid:getWorldPostion(positionsX, positionsY);

		battlePrepareScene.unitData[unitIndex].actor:SetPosition(position);
		battlePrepareScene.unitData[unitIndex].actor:SetScale(LORD.Vector3(modelScaling, modelScaling, modelScaling));

		if force == enum.FORCE.FORCE_GUARD then
			local q = LORD.Quaternion(LORD.Vector3(0,1,0), -math.PI_DIV2);
			battlePrepareScene.unitData[unitIndex].actor:SetOrientation(q);
			battlePrepareScene.unitData[unitIndex].ui:SetProperty("Font", "armynum");
		else
			local q = LORD.Quaternion(LORD.Vector3(0,1,0), math.PI_DIV2);
    	battlePrepareScene.unitData[unitIndex].actor:SetOrientation(q);
    	battlePrepareScene.unitData[unitIndex].ui:SetProperty("Font", "enemynum");	
		end
						
end


function battlePrepareScene.swapPositon(oldpositionsX,oldpositionsy,positionsX, positionsY)
	 
		local newIndex = nil
		local oldIndex = nil
		for i, v in ipairs (battlePrepareScene.unitData)do
				if(v.x == oldpositionsX and v.y == oldpositionsy)then
					oldIndex = v.unitIndex
					
				end
				if(v.x == positionsX and v.y == positionsY)then
					newIndex = v.unitIndex
				end
		end		
		battlePrepareScene.setActorInShipPos(oldIndex, positionsX, positionsY)
		battlePrepareScene.setActorInShipPos(newIndex, oldpositionsX, oldpositionsy)
		 
end
---{1,2,3,4,5,6,7}-- 技能id
function battlePrepareScene.resetAllSkillWithTables( skills )
	
	local num = #skills
	if(num > 7)then
		num = 7
	end
	for i= 1, num do
		setEquipedMagicData(i,skills[i] or 0 );
	end
	eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_UPDATE_MAGIC });
	
end	

function battlePrepareScene.resetAllUnitWithTables( index,cards,pos )
 	 	
 	-- 修改船的位置
 	for k, v in ipairs (index)do
 		PLAN_CONFIG.setShipPosition(v, pos[k].x, pos[k].y, PLAN_CONFIG.currentPlanType);
 		PLAN_CONFIG.setShipCardType(v, cards[k], PLAN_CONFIG.currentPlanType);
 	end
 	
	
	local shipPlan = PLAN_CONFIG.getPlan(PLAN_CONFIG.currentPlanType).shipPlans;
	 	
	for k, v in ipairs(shipPlan) do
		
		if battlePrepareScene.unitData[k].actor then
			LORD.ActorManager:Instance():DestroyActor(battlePrepareScene.unitData[k].actor);
		end
		
		if battlePrepareScene.unitData[k].ui then
			LORD.GUIWindowManager:Instance():DestroyGUIWindow(battlePrepareScene.unitData[k].ui);
		end
		
		battlePrepareScene.unitData[k] = {};
		
	end

	-- 从配置初始化场景
	for k, v in ipairs(shipPlan) do							
		
		if v.cardID > 0 then
		
			local unitID = cardData.getCardInstance(v.cardID):getUnitID();
			local unitX = v.x;
			local unitY = v.y;
			local unitCount = PLAN_CONFIG.getShipUnitNumber(k);
			
			battlePrepareScene.initUnit(k, unitID, unitCount, unitX, unitY, enum.FORCE.FORCE_ATTACK);
			
			if unitX == -1 or unitY == -1 then
				print("battlePrepareScene.sceneInit error unitX == -1 or unitY == -1 ");
			end
		else
			battlePrepareScene.initUnit(k, -1, 0, -1, -1, enum.FORCE.FORCE_ATTACK);
		end
			
	end
	
	
	-- 更新船的effect
	battlePrepareScene.updateShipGridEffect();
		
end


function battlePrepareScene.refreshUnitUIData()
	
	for k, v in pairs(battlePrepareScene.unitData) do
		
		if v.ui and v.actor then
			local screenpos = v.actor:GetTextScreenPosition();
			local uisize = v.ui:GetPixelSize();
			v.ui:SetVisible(true);
			v.ui:SetPosition(LORD.UVector2(LORD.UDim(0, screenpos.x-uisize.x/2), LORD.UDim(0, screenpos.y+10)));	
									
			if v.actor:getUserData() < 7 then
				--自己的
				local shipIndex = v.actor:getUserData();
				if battlePrepareScene.draggingShip == shipIndex then
					v.ui:SetText("");
				else
					local unitCount = PLAN_CONFIG.getShipUnitNumber(shipIndex);
					
					v.ui:SetText(unitCount);
					v.ui:SetProperty("Font", "armynum");				
				end
			elseif v.actor:getUserData() >= 7 then
				--对面的
				--初始化设置上了，不会变
				v.ui:SetProperty("Font", "enemynum");
			else
				v.ui:SetVisible(false);
			end		
		elseif v.ui then
			v.ui:SetVisible(false);
		end
	end				

end

function battlePrepareScene.renderTick(dt)

	local isPlayingCamera = LORD.SceneManager:Instance():isPlayingCameraAnimate();
	
	function setBattleUIVisible(setting)
		
		local battleLayout = layoutManager.getUI("BattleView");
		if battleLayout and battleLayout:isLoaded() and LORD.GUIWindowManager:Instance():GetGUIWindow("battle-allinfo") then
			LORD.GUIWindowManager:Instance():GetGUIWindow("battle-allinfo"):SetVisible(setting);
		end
		
		local corpsdetailLayout = layoutManager.getUI("corpsdetail");
		if corpsdetailLayout and corpsdetailLayout:isLoaded() and LORD.GUIWindowManager:Instance():GetGUIWindow("corpsdetail") then
			LORD.GUIWindowManager:Instance():GetGUIWindow("corpsdetail"):SetVisible(setting);
		end
	end
	
	if isPlayingCamera then
		setBattleUIVisible(false);
	else
		setBattleUIVisible(true);
		if battlePrepareScene.grid then
			battlePrepareScene.grid:update(dt);
			battlePrepareScene.grid:render();
			battlePrepareScene.refreshUnitUIData();
		end
	end

end

function battlePrepareScene.sceneDestroy()
	
	-- 发送配置到服务器
	PLAN_CONFIG.sendPlan(PLAN_CONFIG.currentPlanType);
	
	battlePrepareScene.destroyUnitData();
	
	sceneManager.closeScene();
	
	if battlePrepareScene.map then
		battlePrepareScene.map:delete();
		battlePrepareScene.map = nil;
	end
	
	if battlePrepareScene.grid then
		battlePrepareScene.grid:delete();
		battlePrepareScene.grid = nil;
	end

	battlePrepareScene.copyID = -1;
	battlePrepareScene.draggingShip = -1;
	battlePrepareScene.preSwapShip = -1;
	battlePrepareScene.battleType = enum.BATTLE_TYPE.BATTLE_TYPE_INVALID;
	
end

function battlePrepareScene.destroyUnitData(notReleaseActor)

	--dump(battlePrepareScene.unitData)
	for k, v in pairs(battlePrepareScene.unitData) do
		if v.actor and not notReleaseActor then
			LORD.ActorManager:Instance():DestroyActor(v.actor);
		end
		
		if v.ui then
			LORD.GUIWindowManager:Instance():DestroyGUIWindow(v.ui);
		end
		
	end
	
	battlePrepareScene.unitData = {};
end

function battlePrepareScene.isCanDropGrid(x, y)
	return x >= 0 and x <=2 and y >=0 and y <=2;
end

-- 获得敌方unitindex
function battlePrepareScene.getEnemyUnitIndexInGrid(x, y)
	
	for k,v in pairs(battlePrepareScene.unitData) do
		if x == v.x and y == v.y and v.force == enum.FORCE.FORCE_GUARD then
			return k;
		end
	end
	
	-- 没有的话返回-1
	return -1;
end

battlePrepareScene.preSelectX = -1;
battlePrepareScene.preSelectY = -1;
battlePrepareScene.moveShipFlag = false;

function battlePrepareScene.touchHandler(touchType, touchPosition)
	
	if("TouchUp" == touchType )then
		
		-- 必须按下的时候有选中的军团才处理
		if battlePrepareScene.draggingShip > 0 then
			battlePrepareScene.onTouchUpShip(touchPosition)
			
			eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_REFRESH_UNIT,});
			
		else
			battlePrepareScene.onTouchUpEnemyUnit(touchPosition);
		end
	 	
	elseif("TouchDown" == touchType) then
		
		battlePrepareScene.moveShipFlag = false;
		
		battlePrepareScene.onTouchDownShip(touchPosition);
	 	
	elseif("TouchMove" == touchType) then
	
		battlePrepareScene.onTouchMoveShip(touchPosition);
			
	elseif("TouchCancel" == touchType) then
	
		battlePrepareScene.onTouchCancelShip();
		
	end
end

-- touch 操作相关接口函数
function battlePrepareScene.onTouchDownShip(touchPosition)

	-- 拷贝一份到备份里，在up的时候才真正修改
	PLAN_CONFIG.copyPlan(PLAN_CONFIG.currentPlanType, 1000);
	
	battlePrepareScene.preSwapShip = -1;
	battlePrepareScene.preSelectX = -1;
	battlePrepareScene.preSelectY = -1;
	
	--先取消上次的
	battlePrepareScene.cancelSelectUnitPosition();
		
	local ishit = battlePrepareScene.grid:isHitGrid(touchPosition);
 	if ishit then
 		local gridX = battlePrepareScene.grid:getHitX();
 		local gridY = battlePrepareScene.grid:getHitY();
 		
 		battlePrepareScene.preSelectX = gridX;
		battlePrepareScene.preSelectY = gridY;
	
		local shipIndex = PLAN_CONFIG.getShipIndexByPosition(gridX, gridY);
		
		if shipIndex > 0 and shipData.getShipInstance(shipIndex):isActive() then
			battlePrepareScene.draggingShip = shipIndex;
			
			battlePrepareScene.setSelectUnitPosition(battlePrepareScene.draggingShip, gridX, gridY);
			
		end
		 
 	end
 	
end

-- 设置船上actor的位置
function battlePrepareScene.setActorInShipPos(shipIndex, gridX, gridY)
	local position = battlePrepareScene.grid:getWorldPostion(gridX, gridY);

	if battlePrepareScene.unitData[shipIndex].actor then
		battlePrepareScene.unitData[shipIndex].actor:SetPosition(position);
		battlePrepareScene.unitData[shipIndex].x = gridX;
		battlePrepareScene.unitData[shipIndex].y = gridY;
	end
	
	PLAN_CONFIG.setShipPosition(shipIndex, gridX, gridY);
	
	--eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_REFRESH_UNIT,});
end

-- 恢复到备份的状态
function battlePrepareScene.recoverShipPos()
	
	for k,v in pairs(shipData.shiplist) do
		local shipX, shipY = PLAN_CONFIG.getShipPosition(k, 1000);
		
		battlePrepareScene.setActorInShipPos(k, shipX, shipY);

	end
	
end

function battlePrepareScene.onTouchMoveShip(touchPosition)
	
	if battlePrepareScene.draggingShip <= 0 then
		return;
	end
	
	--前期禁止拖拽
	--local guideId = 99999;
	--local index = Guide.findIdWithOrder(guideId)
	local process = dataManager.playerData:getAdventureNormalProcess()
	local copyX=battlePrepareScene.copyID
	local temp = copyX*2
	local star
	local stage =  dataManager.instanceZonesData:getStageWithAdventureID( temp,enum.Adventure_TYPE.NORMAL )
	if stage then
		star = stage:getVisStarNum()
	end
	--if(Guide.serverData[index] ==true) then
	if (process <2) or (copyX>1 and copyX<=3 and star == 2) then
		return;
	end

	-- 处理拖拽
	local ishit = battlePrepareScene.grid:isHitGrid(touchPosition);
	local gridX = battlePrepareScene.grid:getHitX();
 	local gridY = battlePrepareScene.grid:getHitY();
 	
 	if battlePrepareScene.preSelectX == gridX and battlePrepareScene.preSelectY == gridY then
 		-- 没移动，不处理
 		return;
 	end
 			
 	if ishit and battlePrepareScene.isCanDropGrid(gridX, gridY) then

 		battlePrepareScene.preSelectX = gridX;
		battlePrepareScene.preSelectY = gridY;
	
		battlePrepareScene.moveShipFlag = true;
			
		-- 所有的先恢复到初始的状态
		battlePrepareScene.recoverShipPos();
		
		local shipIndex = PLAN_CONFIG.getShipIndexByPosition(gridX, gridY);
				
		if shipIndex > 0 then

				-- 交换位置
				local ship1X, ship1Y = PLAN_CONFIG.getShipPosition(battlePrepareScene.draggingShip);
				local ship2X, ship2Y = PLAN_CONFIG.getShipPosition(shipIndex);
				
				battlePrepareScene.setActorInShipPos(shipIndex, ship1X, ship1Y);
				battlePrepareScene.setActorInShipPos(battlePrepareScene.draggingShip, ship2X, ship2Y);

		else
		
			-- 放到一个新的空位置上
			battlePrepareScene.setActorInShipPos(battlePrepareScene.draggingShip, gridX, gridY);
		end
		
		-- 升起一定的高度
		battlePrepareScene.setSelectUnitPosition(battlePrepareScene.draggingShip, gridX, gridY);
		
		-- 更新船的特效
		battlePrepareScene.updateShipGridEffect();
		
		-- 关闭信息界面
		eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_UPDATE_SHIPINDEX, selectShipIndex = -1 });

 	end
end

function battlePrepareScene.onTouchUpShip(touchPosition)

	if battlePrepareScene.draggingShip > 0 and shipData.getShipInstance(battlePrepareScene.draggingShip):isActive() then

		--local ishit = battlePrepareScene.grid:isHitGrid(touchPosition);
	 	--local gridX = battlePrepareScene.grid:getHitX();
	 	--local gridY = battlePrepareScene.grid:getHitY();
	 	

		local nowX, nowY = PLAN_CONFIG.getShipPosition(battlePrepareScene.draggingShip);
		local oldX, oldY = PLAN_CONFIG.getShipPosition(battlePrepareScene.draggingShip, 1000);
		
		if nowX == oldX and nowY == oldY and battlePrepareScene.moveShipFlag == false then
			--前期禁止换兵
			local num = 2
			local process = dataManager.playerData:getAdventureNormalProcess()
			local stage =  dataManager.instanceZonesData:getStageWithAdventureID( num,enum.Adventure_TYPE.NORMAL )
			local star = stage:getVisStarNum()
			if(process >=num and star == 3) then
				-- 打开界面
				eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_UPDATE_SHIPINDEX, selectShipIndex = battlePrepareScene.draggingShip });
				
				
			end
			--
		else
			-- 拖拽引导
			eventManager.dispatchEvent({name = global_event.GUIDE_ON_TOUCH_MOVE_SHIP, arg1 = nowX, arg2 = nowY, arg3 = battlePrepareScene.draggingShip });
			--
			battlePrepareScene.cancelSelectUnitPosition();
		end
		
	end
end

function battlePrepareScene.onTouchCancelShip()
	if battlePrepareScene.draggingShip > 0 then

 		-- 回到原来的格子上
 		local gridX, gridY = PLAN_CONFIG.getShipPosition(battlePrepareScene.draggingShip);
 		
 		battlePrepareScene.cancelSelectUnitPosition();
 		
	end
end

-- 设置actor选中的位置
function battlePrepareScene.setSelectUnitPosition(shipIndex, gridX, gridY)

	local position = battlePrepareScene.grid:getWorldPostion(gridX, gridY);
	position.y = position.y + battlePrepareScene.actorYOffset;
	if battlePrepareScene.unitData[shipIndex] and battlePrepareScene.unitData[shipIndex].actor then
		battlePrepareScene.unitData[shipIndex].actor:SetPosition(position);
		battlePrepareScene.unitData[shipIndex].actor:PlaySkill("run");
		
		LORD.SoundSystem:Instance():playEffect("actorup.mp3");	
	end
	
	-- 高亮可以移动的格子	
	battlePrepareScene.highOptionalGrid(gridX, gridY);
end

-- 恢复actor的位置
function battlePrepareScene.cancelSelectUnitPosition()
	
	if battlePrepareScene.draggingShip > 0 then
		local gridX, gridY = PLAN_CONFIG.getShipPosition(battlePrepareScene.draggingShip);
		
		local position = battlePrepareScene.grid:getWorldPostion(gridX, gridY);
		if battlePrepareScene.unitData[battlePrepareScene.draggingShip].actor then
			battlePrepareScene.unitData[battlePrepareScene.draggingShip].actor:SetPosition(position);
			battlePrepareScene.unitData[battlePrepareScene.draggingShip].actor:PlaySkill("idle");
			LORD.SoundSystem:Instance():playEffect("actordown.mp3");
		end
		
		battlePrepareScene.disableAllHighlight();
		
		battlePrepareScene.draggingShip = -1;
		
	end
end

function battlePrepareScene.onTouchUpEnemyUnit(touchPosition)
	-- 处理敌方的选中处理
	local ishit = battlePrepareScene.grid:isHitGrid(touchPosition);
 	local gridX = battlePrepareScene.grid:getHitX();
 	local gridY = battlePrepareScene.grid:getHitY();
 	
 	local unitIndex = battlePrepareScene.getEnemyUnitIndexInGrid(gridX, gridY);

 	if unitIndex > 0 and battlePrepareScene.unitData[unitIndex] then
 		local unitInfo = battlePrepareScene.unitData[unitIndex];

 		local event = {
			name = global_event.CORPSDETAIL_SHOW, 
			unitID = unitInfo.unitID, 
			curUnitNum = unitInfo.count, 
			totalUnitNum = unitInfo.count,
			shipAttr = {},		
 		};
 		
 		event.shipAttr.attack = unitInfo.shipAttr.attack;
		event.shipAttr.defence = unitInfo.shipAttr.defence;
		event.shipAttr.critical = unitInfo.shipAttr.critical;
		event.shipAttr.resilience = unitInfo.shipAttr.resilience;
		
 		eventManager.dispatchEvent(event);
 	else
 		eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_UPDATE_SHIPINDEX, selectShipIndex = -1 });
 	end

end

function battlePrepareScene.onClickEnemy(unitIndex)
 	if unitIndex > 0 and battlePrepareScene.unitData[unitIndex] then
 		local unitInfo = battlePrepareScene.unitData[unitIndex];

 		local event = {
			name = global_event.CORPSDETAIL_SHOW, 
			unitID = unitInfo.unitID, 
			curUnitNum = unitInfo.count, 
			totalUnitNum = unitInfo.count,
			shipAttr = {},		
 		};
 		
 		event.shipAttr.attack = unitInfo.shipAttr.attack;
		event.shipAttr.defence = unitInfo.shipAttr.defence;
		event.shipAttr.critical = unitInfo.shipAttr.critical;
		event.shipAttr.resilience = unitInfo.shipAttr.resilience;
		
 		eventManager.dispatchEvent(event);
 	else
 		eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_UPDATE_SHIPINDEX, selectShipIndex = -1 });
 	end
end

function battlePrepareScene.updateShipActor(shipIndex, cardType)
	
	--dump(shipData.shiplist);
	local shipEquipedCard = PLAN_CONFIG.getShipEquipedCard(cardType);
	
	if shipEquipedCard == shipIndex and PLAN_CONFIG.getShipCardType(shipIndex) > 0 then
		return;
	end
	
	if shipEquipedCard <= 0 then
		-- 不是已经装备的卡，直接放上
		local unitID = cardData.cardlist[cardType].unitID;
		
		battlePrepareScene.setShipActor(shipIndex, unitID);
		
		PLAN_CONFIG.setShipCardType(shipIndex, cardType);

	else
	
		-- 已经装备的卡，并且不是同一条船，交换一下船上的卡
		local equipedCardType = PLAN_CONFIG.getShipCardType(shipEquipedCard);
		local selectCardType = PLAN_CONFIG.getShipCardType(shipIndex);
		
		PLAN_CONFIG.setShipCardType(shipEquipedCard, selectCardType);
		PLAN_CONFIG.setShipCardType(shipIndex, equipedCardType);
		
		local equipedUnitID = cardData.cardlist[equipedCardType].unitID;
		battlePrepareScene.setShipActor(shipIndex, equipedUnitID);
		
		-- 选中的可能是空船
		local selectUnitID = -1;
		if cardData.cardlist[selectCardType] then
			selectUnitID = cardData.cardlist[selectCardType].unitID;
		end
				
		battlePrepareScene.setShipActor(shipEquipedCard, selectUnitID);

	end
	
	battlePrepareScene.cancelSelectUnitPosition();
	--dump(shipData.shiplist);
	--上阵成功
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_FINISH_GOTO_INBATTLE})
end

function battlePrepareScene.setShipActor(shipIndex, unitID)
	
	if battlePrepareScene.unitData[shipIndex].actor then
		LORD.ActorManager:Instance():DestroyActor(battlePrepareScene.unitData[shipIndex].actor);
		battlePrepareScene.unitData[shipIndex].actor = nil;	
	end
	
	local unitInfo = dataConfig.configs.unitConfig[unitID];
	if unitInfo then
		local actorName = unitInfo.resourceName;
		local modelScaling = unitInfo.modelScaling;
		
		battlePrepareScene.unitData[shipIndex].actor = LORD.ActorManager:Instance():CreateActor(actorName, "idle", false);
		battlePrepareScene.unitData[shipIndex].actor:SetUserData(shipIndex);
		
		local gridX, gridY = PLAN_CONFIG.getShipPosition(shipIndex);
		local position = battlePrepareScene.grid:getWorldPostion(gridX, gridY);
 
		battlePrepareScene.unitData[shipIndex].actor:SetPosition(position);
		battlePrepareScene.unitData[shipIndex].actor:SetScale(LORD.Vector3(modelScaling, modelScaling, modelScaling));
		battlePrepareScene.unitData[shipIndex].actor:SetMirror(false);
 			 
		-- update info
		battlePrepareScene.unitData[shipIndex].unitID = unitID;
		battlePrepareScene.unitData[shipIndex].x = gridX;
		battlePrepareScene.unitData[shipIndex].y = gridY;
		
		local q = LORD.Quaternion(LORD.Vector3(0,1,0), math.PI_DIV2);
		battlePrepareScene.unitData[shipIndex].actor:SetOrientation(q);	
		
		eventManager.dispatchEvent({name = global_event.BATTLEPREPARE_REFRESH_UNIT,});
	end
	
end

function battlePrepareScene.runBattle()
	
	battlePrepareScene.disableAllHighlight();
	
	local id = -1;
	local param1 = -1;
	
	-- 根据类型区分
	if battlePrepareScene.isAdventureBattleType() then
		id = dataManager.playerData.stageInfo:getAdventureID();
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT then
		-- 领地的index
		-- 需要判断是否能开战
		if dataManager.mainBase:canRunBattle() then
			id = dataManager.mainBase:getCurrentIncidentIndex();
		else
		
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, textInfo = "条件不满足，无法挑战！" });	
			
			return;
		end
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED then
		if not dataManager.playerData:isSpeedChallegeCanStart() then
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, textInfo = "今日已挑战结束，明日再来！" });
			return;
		end
		
		id = dataManager.playerData:getSpeedChallengeStage();
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE then
		id = dataManager.hurtRankData:getStageId();
		
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE then
		
		id = dataManager.crusadeActivityData:getCurrentStageIndex() - 1;
		
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
					battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
					battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then
		id = dataManager.playerData:getChallegeStageIndex();
	
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_PLUNDER then
					
		-- 抢夺
		if not dataManager.idolBuildData:onRunBattle() then
			return;
		end
		
		id = dataManager.idolBuildData:getCurrentSelectTargetInfo().difficulty;
		
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_REVENGE then
	
		-- 复仇
		if not dataManager.idolBuildData:onRunBattle() then
			return;
		end		
		
		id = dataManager.idolBuildData:getCurrentSelectTargetInfo().primalType;
		
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_FIGHT then --切磋
  
		id =  dataManager.buddyData:getPkPlayer()
	
	elseif battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR then --切磋
	
		id = dataManager.guildWarData:getSelectSpotIndex()-1;
		local player = dataManager.guildWarData:getCurrentSelectTargetInfo();
		param1 = player.playerID;
		
	else
		id = -1;
	end
	
	
	
	battlePrepareScene.setAllGridNormal();
		
	-- 发送配置到服务器
	PLAN_CONFIG.sendPlan(PLAN_CONFIG.currentPlanType);
	
	-- 发起战斗	
	if(battlePrepareScene.isPvPofflineBattleType())	then
	
		if(dataManager.pvpData:getOfflineFuchouFlag())then
		
			dataManager.pvpData:setOfflineFuchouFlag(false)
			sendPvpRevenge(dataManager.pvpData:getSelectFuchouPlayerId())
		else
			local player = dataManager.pvpData:getSelectPlayer()	
			sendBattle(battlePrepareScene.battleType, player.posIndex, param1);
		
		end
 
		
		if(PLAN_CONFIG.isShipsPlanEmpty(enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_GUARD))then --离线PVP防守配置为空 就主动告诉服务器 防守和进攻一样。 服务器做不了，客户端来做、
			PLAN_CONFIG.copyPlan(PLAN_CONFIG.currentPlanType,enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_GUARD) --currentPlanType 为 enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_ATTACK
			PLAN_CONFIG.sendPlan(enum.PLAN_TYPE.PLAN_TYPE_PVP_OFFLINE_GUARD)
		end
 
	else
		if(battlePrepareScene.battleType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE)then
			dataManager.hurtRankData:setServerResult(false)
		end
 
		sendBattle(battlePrepareScene.battleType, id, param1);		
	end
 
	--备份一下金钱，奖励的时候需要动画表现
	dataManager.playerData:backupMoney();
end

function battlePrepareScene.signGrid(x, y, color)			
	if battlePrepareScene.grid then
		local effect = { n ="HexagonGrid.effect", r = "RedGridfingt.effect", 
										r2 = "RedGrid.effect", b = "BlueGridfingt.effect", 
										b2 = "BlueGrid.effect", b3 = "HexagonGrid_02.effect", 
										arrow = "jiayuantexiao01_jiaoxiakuang.effect" }
										
		battlePrepareScene.grid:setGridEffect(effect[color], x ,y);
		
	end
end

function battlePrepareScene.setGridShipEffect(x, y, shipIndex)
	if battlePrepareScene.grid then
		local effectName = {
			"shipGrid1.effect",
			"shipGrid2.effect",
			"shipGrid3.effect",
			"shipGrid4.effect",
			"shipGrid5.effect",
			"shipGrid6.effect",
		};
		
		--print("x "..x.." y "..y.." shipIndex "..shipIndex);
		if effectName[shipIndex] then
			battlePrepareScene.grid:setGridEffect(effectName[shipIndex], x ,y);
		end
	end
end

function battlePrepareScene.setAllGridNormal()
	if battlePrepareScene.map then
		local column = battlePrepareScene.map:getColumns();
		local row = battlePrepareScene.map:getRows();
		
		for i = 0, row-1 do
			for j = 0, column-1 do
				battlePrepareScene.signGrid(j, i, "n");
			end
		end

	end
end

-- 高亮的特效是另一个图层，需要单独设置
function battlePrepareScene.setHighlightGrid(x,y,effectname)
	if battlePrepareScene.grid and effectname then
		battlePrepareScene.grid:setHighlightEffect(effectname, x ,y);
	end
end

function battlePrepareScene.clickEffectInCastMagic(gridX, gridY, loop)
	
	if battlePrepareScene.map then
	
		local column = battlePrepareScene.map:getColumns();
		local row = battlePrepareScene.map:getRows();
		
		for i = 0, row-1 do
			for j = 0, column-1 do
				if gridX == j and gridY == i then
					if loop then
						battlePrepareScene.setHighlightGrid(j, i, "mofazhishi.effect");
					else
						battlePrepareScene.setHighlightGrid(j, i, "mofazhishi01.effect");
					end
				else
					battlePrepareScene.setHighlightGrid(j, i, "");
				end
			end
		end

	end
	
end

-- 高亮可以选择的区域, x, y的位置用箭头
function battlePrepareScene.highOptionalGrid(gridX, gridY)
	if battlePrepareScene.map then
		local column = battlePrepareScene.map:getColumns();
		local row = battlePrepareScene.map:getRows();
		
		for i = 0, row-1 do
			for j = 0, column-1 do
				if gridX == j and gridY == i then
					battlePrepareScene.setHighlightGrid(j, i, "jiayuantexiao01_jiaoxiakuang.effect");
				else
					if battlePrepareScene.isCanDropGrid(j, i) then
						battlePrepareScene.setHighlightGrid(j, i, "HexagonGrid_02.effect");
					else
						battlePrepareScene.setHighlightGrid(j, i, "");
					end
				
				end
			end
		end

	end
end

-- 取消高亮
function battlePrepareScene.disableAllHighlight()
	if battlePrepareScene.map then
		local column = battlePrepareScene.map:getColumns();
		local row = battlePrepareScene.map:getRows();
		
		for i = 0, row-1 do
			for j = 0, column-1 do
				battlePrepareScene.setHighlightGrid(j, i, "");
			end
		end

	end
end


function battlePrepareScene.updateShipGridEffect()
	
	--dump(shipData.shiplist);
	
	--battlePrepareScene.setAllGridNormal();
		
	local shipPlan = PLAN_CONFIG.getPlan(PLAN_CONFIG.currentPlanType).shipPlans;
	
	if battlePrepareScene.map then
		local column = battlePrepareScene.map:getColumns();
		local row = battlePrepareScene.map:getRows();
		
		for i = 0, row-1 do
			for j = 0, column-1 do
				
				local shipIndex = PLAN_CONFIG.getShipIndexByPosition(j, i, PLAN_CONFIG.currentPlanType);
				local ship = shipData.getShipInstance(shipIndex);
				
				if ship == nil or not ship:isActive() then
					battlePrepareScene.signGrid(j, i, "n");
				end
			end
		end

	end
		
	for k, v in ipairs(shipData.shiplist) do
		-- 标记出船的位置
		if v.actived == true then
			battlePrepareScene.setGridShipEffect(shipPlan[k].x, shipPlan[k].y, k);
		end
		
	end
end

function battlePrepareScene.playStartAnimate()
	
	local sceneIndo = dataConfig.configs.sceneConfig[battlePrepareScene.sceneID];
	if battlePlayer.rePlayStatus ~= true and sceneIndo and sceneIndo.beginCamAnim  then		
		local scene = 	sceneManager.scene 
		local ani = scene:importCameraAnimation(sceneIndo.beginCamAnim)
		local time = ani:getTotalTime()*1000
		print("------------ttt------!!!!!!!!!!!!!!!"..time)
		sceneManager.battlePlayer().m_WaitingTime =  time
		ani:play()
	end	
		 		
end

function battlePrepareScene.getMagicRound()
	
	local unitCount = 0;
	for k,v in pairs(battlePrepareScene.unitData) do
		if v.actor then
			unitCount = unitCount + 1;
		end
	end
	
	local round = 0;
	local tableRowMaxNum = table.nums(dataConfig.configs.magicRoundConfig);
	local magicRound = dataConfig.configs.magicRoundConfig[unitCount];
	if magicRound then
		round = magicRound.round;
	else
		round = dataConfig.configs.magicRoundConfig[tableRowMaxNum-1].round;
	end
	
	return round;
	
end

function battlePrepareScene.calcAllActionOrder(calcRound)
	
	calcRound = calcRound or 14;
	
	battlePrepareScene.m_ActionOrder = {};
	battlePrepareScene.m_TempUnits = {};
	battlePrepareScene.m_lastConflictForce = false;
			
	local i = 0;
	for k,v in pairs(battlePrepareScene.unitData) do

		local unitInfo = dataConfig.configs.unitConfig[v.unitID];
		
		if unitInfo then
			battlePrepareScene.m_TempUnits[i] = {
				['m_bAttacker'] = (v.force == enum.FORCE.FORCE_ATTACK),
				['m_leftTime'] = math.floor(enum.TIME_UNIT / unitInfo.actionSpeed),
				['m_bAlive'] = true,
				['m_ActionSpeed'] = unitInfo.actionSpeed,
				['m_roundTime'] = math.floor(enum.TIME_UNIT / unitInfo.actionSpeed),
				['index'] = k,
				['m_PosX'] = v.x,
				['m_PosY'] = v.y,
			};
			
			i = i + 1;
		end
	end
	
	if #battlePrepareScene.m_TempUnits == 0 then
		return;
	end
	
	dump(battlePrepareScene.m_TempUnits);
	
	local tempLastForce = battlePrepareScene.m_lastConflictForce;
	
	-- 魔法回合
	
 	-- 下一次国王魔法的剩余回合数, 变成0表示第一个该放魔法，变成-1表示第二个该放魔法
 	battlePrepareScene.nextMagicRound = 0;
 	-- 下一次国王魔法回合开始时是进攻方，还是防守方
 	battlePrepareScene.nextMagicRoundTurnForce = enum.FORCE.FORCE_ATTACK;
 		
	local magicRound = battlePrepareScene.getMagicRound();
	
	local nextFirstMagicRound = battlePrepareScene.nextMagicRound + 1;
	local nextSecondMagicRound = battlePrepareScene.nextMagicRound + 2;
	local nextFirstMagicIsFriendly = battlePrepareScene.nextMagicRoundTurnForce == enum.FORCE.FORCE_ATTACK;
	local nextSecondMagicIsFriendly = global.oppsiteForce(battlePrepareScene.nextMagicRoundTurnForce) == enum.FORCE.FORCE_ATTACK;
	
	for i=1, calcRound do
		
		--print("round "..i);
		
		if i == nextFirstMagicRound then
			-- 先手方放魔法
			battlePrepareScene.m_ActionOrder[i] = {};
			battlePrepareScene.m_ActionOrder[i].isFriendlyForce = nextFirstMagicIsFriendly;
			battlePrepareScene.m_ActionOrder[i].index = -1;

			-- 更新下一次魔法回合的数据
			nextFirstMagicRound = nextFirstMagicRound + magicRound + 1;
			nextFirstMagicIsFriendly = not nextFirstMagicIsFriendly;
			
			--print("magic-----------");
		else
			-- 计算军团的序列
			battlePrepareScene.m_ActionOrder[i], battlePrepareScene.m_lastConflictForce = battlePlayer._selectUnit(battlePrepareScene.m_TempUnits, battlePrepareScene.m_lastConflictForce);
			
			--print("selectunit ----------- "..battlePrepareScene.m_ActionOrder[i].index);
			
			-- 把临时拷贝中的时间重新计算一下
			for k,v in pairs (battlePrepareScene.m_TempUnits) do
				if( v ~= nil and v ~= battlePrepareScene.m_ActionOrder[i]) then
					v.m_leftTime = v.m_leftTime-battlePrepareScene.m_ActionOrder[i].m_leftTime;
				end
			end
			
			battlePrepareScene.m_ActionOrder[i].m_leftTime = battlePrepareScene.m_ActionOrder[i].m_roundTime;			
		end			
	end
	
	--dump(battlePrepareScene.m_ActionOrder);
end
