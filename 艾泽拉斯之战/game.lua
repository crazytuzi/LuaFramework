

--wz

game = {}

game.GAME_STATE_LOADING = 1
game.GAME_STATE_MAIN = 2
game.GAME_STATE_BATTLE = 3
game.GAME_STATE_SHIP = 4
game.GAME_STATE_BATTLE_PREPARE = 5
game.GAME_STATE_INSTANCE = 6


game.state = nil

game.touchHandle = nil;
game.multiTouchHandle = nil;
game.logicTickFun = nil;
game.uiWorldPosHandle = nil;

function onTouchEvent( _type, touch)
	
	
	--print(_type)
	--print(index)
	--print(pos.x)
	--print(pos.y)
	
	if game.touchHandle then
		game.touchHandle(_type, touch:getTouchPoint(), touch);
	end
		
end

function onMultiTouchEvent(touchType, touch1, touch2)
	if game.multiTouchHandle then
		game.multiTouchHandle(touchType, touch1, touch2);
	end
end

function exceptionHandler(msg, file, linenum)
	print("exception message: "..msg);
	print("exception filename: "..file);
	print("exception linenum: "..linenum);
	
	eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
		messageType = enum.MESSAGE_BOX_TYPE.ERROR, data = "", 
		textInfo = msg.."\n"..file.."\n"..linenum });
end

function netExceptionHandler()

	--[[
	function netExceptionCallBack()
		GameClient.NetworkEngine:Instance():networkExceptionHandle();
	end
	
	eventManager.dispatchEvent({name = global_event.MESSAGEBOX_SHOW, 
			textInfo = "网络异常， 点击确定重新登录!", callBack = netExceptionCallBack });
		
	--]]

	dataManager.loginData:setLogin(false);
	
	--print("--------------netExceptionHandler---------");
				
	-- 如果是战斗就退出 悟    空 源 码 网 ww w . w k ym w .com
	if game.state == game.GAME_STATE_BATTLE then
		sceneManager.battlePlayer():QuitBattle();
		
		eventManager.dispatchEvent({name = global_event.BATTLELOSE_HIDE });
		eventManager.dispatchEvent({name = global_event.INSTANCEJIESUAN_UI_HIDE });
	end
	
	-- 清理数据，目前只有背包是需要清理的
	dataManager.bagData:clear();
	dataManager.shopData:clearAllitem();
	eventManager.dispatchEvent({name = global_event.SHOP_UPDATE});
	
	-- 重新登录	
	game.__________ENTER_GAME = false	
	
	if not dataManager.loginData:isShouldReconnect() then
		dataManager.loginData:setDisconectType(enum.LOGIN_RESULT.LOGIN_RESULT_INVALID);
		return;
	end
	   
	dataManager.loginData:login(true);
	eventManager.dispatchEvent({name = global_event.LOADING_SHOW, notAutoHide = true});
end

function onAppDidEnterBackground()
	print("onAppDidEnterBackground")
	
	if not dataManager.playerData.login then
		return;
	end
	
	local shellInterface = GameClient.CGame:Instance():getShellInterface();
	if shellInterface then
		
		local pushInfoTabel = global.getPushInfo();
		
		local pushInfo = json.encode(pushInfoTabel);
		
		print(pushInfo);
		shellInterface:onUpdatePushInfo(pushInfo);
	end
	
	-- 记录时间，判断下次回来是不是重新登录
	dataManager.loginData:recordEnterBackgroudTime();
	
end

function onAppBecameActive()
	print("onAppBecameActive")

	if not dataManager.playerData.login then
		return;
	end
	
	local shellInterface = GameClient.CGame:Instance():getShellInterface();
	if shellInterface then
		shellInterface:onClearPushInfo();
	end
	
	dataManager.loginData:checkShouldGoBackLogin();
		
end

function netSendOK(id)
	print("netSendOK  "..id);
	global.OnPacketSend(id)
end

function networkTickHandle()
	sendTick(147);
end

--globleLoginResult = "";

-- 登录成功回调
function onSDKLoginSuccess(resultString)
	--sendLogin2(resultString);
	
	--globleLoginResult = resultString;
	dataManager.loginData:setLoginJson(resultString);
end

-- 交易成功回调
function onTransactionComplete(resultString)

	dataManager.transactionData:addTransaction(resultString);
	
end

-- 摇一摇回调
function handleMotionBegin()

end

function handleMotionCancelled()

end

function handleMotionEnded()
	
	-- 摇一摇红包
	redEnvelopeData_onshakeToClient();
	
end

-- ui的世界空间的位置需要在摄像机更新了之后更新
-- 所以在一个单独的tick里处理
function handleUIWorldPosTick(dt)
	if game.uiWorldPosHandle then
		game.uiWorldPosHandle(dt);
	end
end

function MainTick(detal)
    --echoInfo("MainTick -- :"..detal)	
	 dataManager.logic_tick(detal);
	 instanceScene.tick(detal)
	 dataManager.moneyFlyManager:tick(detal);
	 
	 if game.logicTickFun then
	 	game.logicTickFun(detal);
	 end
end	

function RenderTick(detal)
	detal = detal * 1000;
	-- 目前只有格子需要处理渲染，场景应该只处理逻辑
	-- 应该放到逻辑tick
	battlePrepareScene.renderTick(detal);	
	sceneManager.OnTick(detal);
end	


function game.Init()
	skillSys.Init()
	bufferSys.Init()
	layoutManager.loadView()
	instanceScene.build()
	-- 初始化
	LORD.ActorManager:Instance():SetAttackScale(dataConfig.configs.ConfigConfig[0].attScale);
	
	local sound = fio.readIni("system", "sound", "on");
	LORD.SoundSystem:Instance():setSoundOn(sound == "on");
	
	-- 启动就是一倍速
	--setClientVariable( "gameSpeed",	SPEED_UP_GAME[1]);		
end	
	
function game.Go()

  --scheduler.scheduleGlobal(MainTick, MAIN_TICK_INTERVAL)
  --scheduler.scheduleUpdateGlobal(RenderTick)
  game.__________ENTER_GAME = false
  game.EnterProcess( game.GAME_STATE_LOADING)
  scheduler.scheduleGlobal(MainTick,0 )--MAIN_TICK_INTERVAL
  scheduler.scheduleUpdateGlobal(RenderTick,MAIN_TICK_INTERVAL)
end		

function game.isLoginStates()
	if(game.state == game.GAME_STATE_LOADING)then
		return true
	end
	return false
end	
			
		
function game.EnterProcess(state, param)
		
		local oldState = 	game.state
		game.state = state	
		Guide.onChangeScene()
		-- 清理上一个状态的各种handle
		game.logicTickFun = nil;
		game.uiWorldPosHandle = nil;
		game.touchHandle = nil;
		game.multiTouchHandle = nil;
		
		-- do old state clear
		--if oldState ~= game.state then
		if oldState == game.GAME_STATE_MAIN then
			homeland.sceneDestroy();
		elseif oldState == game.GAME_STATE_INSTANCE then
			instanceScene.release();
		elseif oldState == game.GAME_STATE_BATTLE_PREPARE and game.state ~= game.GAME_STATE_BATTLE then
			battlePrepareScene.closePrepareScene();
		elseif oldState == game.GAME_STATE_BATTLE and game.state ~= game.GAME_STATE_BATTLE then
			if sceneManager.battlePlayer() then
				sceneManager.battlePlayer():onQuitBattle();
			end
			LORD.SoundSystem:Instance():stopBackgroundMusic();
		end
		--end
		
		if(game.state == game.GAME_STATE_LOADING)then
			
			engine.playBackgroundMusic("Login.mp3", true);
      --eventManager.dispatchEvent({name = global_event.LOGIN_UI_SHOW})
			eventManager.dispatchEvent({name = global_event.LOGIN_WIN_UI_SHOW, autologin = param });
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			eventManager.dispatchEvent({name = global_event.GAMENOTICE_SHOW});
			
		elseif(game.state == game.GAME_STATE_MAIN)then
			engine.playBackgroundMusic("home.mp3", true);
			if param then
				if param.returnType ~= enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE and
					param.returnType ~= enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE and
			  		 param.returnType ~= enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT then	 
					
					-- 推图和领地事件不进入家园
					homeland.sceneInit();
				end
			else
				homeland.sceneInit();
			end
			
			-- 各种事件的handle
			game.touchHandle = homeland.touchHandle;
			game.multiTouchHandle = homeland.multiTouchHandle;
			game.logicTickFun = homeland.logicTickFun;
			game.uiWorldPosHandle = homeland.handleUIWolrdPos;

			local gotoInstance = false
		  if param then
		  	if param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_STAGE or
		  		 param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_PVE_ELITE then
		  		eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW, showStageInfo = false});
				gotoInstance = true  			
		  	elseif param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_INCIDENT then
		  		
		  		local mainBaseData = dataManager.mainBase;
					local win = mainBaseData:isStageWin();
		  		-- 返回类型，有可能是战斗胜利，也有可能是失败，还有可能是在战斗准备界面直接返回了
		  		eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW, showStageInfo = false});
				gotoInstance = true
									  
		  		if global.getFlag("incidentAward") then
		  			dataManager.mainBase:claimAward();
		  			
		  			global.setFlag("incidentAward", nil);
		  		end
		  		
		  	elseif param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE then
		  		--eventManager.dispatchEvent({name = global_event.ARENA_SHOW});
		  		--global.gotoarena_pvpOnline()
		  	elseif param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_OFFLINE then
		  	 
					if(battlePlayer.rePlayStatus == false) then 
						homeland.arenaHandle()
						global.openOfflinePvp(  oldState == game.GAME_STATE_BATTLE )
					else
						eventManager.dispatchEvent({name = global_event.MAIN_UI_SHOW});	
					end
		 
					return
		  	elseif param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_SPEED then
		  		
		  		eventManager.dispatchEvent({name = global_event.ACTIVITY_SHOW});
		  		eventManager.dispatchEvent({name = global_event.ACTIVITYSPEED_SHOW});

		  		-- 判断是否弹出最终奖励界面
		  		if dataManager.playerData:isSpeedChallegeSuccess() then
		  			eventManager.dispatchEvent({name = global_event.SPEEDREWARD_SHOW});
		  		end

		  	elseif param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_CRUSADE then
		  		
		  		-- 远征活动
		  		eventManager.dispatchEvent({name = global_event.ACTIVITY_SHOW});
		  		eventManager.dispatchEvent({name = global_event.CRUSADE_SHOW});

				elseif param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_PLUNDER or 
							param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_REVENGE then
					
					if(battlePlayer.rePlayStatus == false) then
						
						homeland.shenXiangHandle();

						if battlePlayer.win ~= nil then
							-- 掠夺和复仇
							eventManager.dispatchEvent({name = global_event.ROBRESULT_SHOW, });
						end
											
						return;
					end
					--eventManager.dispatchEvent({name = global_event.IDOLSTATUS_SHOW});
					
		  	elseif param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_NORMAL or
		  				param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_ELITE or
		  				param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_STAGE_HELL then
		  		
		  		eventManager.dispatchEvent({name = global_event.ACTIVITY_SHOW});
		  		eventManager.dispatchEvent({name = global_event.ACTIVITYCOPY_SHOW});
		  		
		  	elseif param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_CHALLENGE_DAMAGE	then
		  		
		  		eventManager.dispatchEvent({name = global_event.ACTIVITY_SHOW});
		  		eventManager.dispatchEvent({name = global_event.ACTIVITYDAMAGE_SHOW});
		  	
		  	elseif param.returnType == enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR then
		  		
		  		dataManager.guildData:onHandleClickGuildButton();
		  		dataManager.guildWarData:onHandleEnterGuildWarMap();
		  		dataManager.guildWarData:onHandleClickSpot(dataManager.guildWarData:getSelectSpotIndex());
		  		dataManager.guildWarData:onHandleClickAttackAskDefenceInfo(dataManager.guildWarData:getSelectSpotIndex());
		  		
		  	end
		  			  	
		  end
			if(gotoInstance == false)then
				eventManager.dispatchEvent({name = global_event.MAIN_UI_SHOW});
				--eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_MAIN_STATE});
			end						
		elseif(game.state == game.GAME_STATE_BATTLE)then
			
			sceneManager.runBattle();
			game.touchHandle = game.battleTouchHandle;
			game.uiWorldPosHandle = battleText.handleUIWorldPos;
			
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			eventManager.dispatchEvent({name = global_event.ENTER_GAME_STATE_BATTLE});
		elseif(game.state == game.GAME_STATE_SHIP)then
			
			shiplogic.sceneInit();
			game.touchHandle = shiplogic.touchHandle;
			eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
			eventManager.dispatchEvent({name = global_event.SHIPCHOICE_SHOW});
		
		elseif(game.state == game.GAME_STATE_BATTLE_PREPARE )then
		
			battlePrepareScene.sceneInit(param.battleType, param.planType);
			game.touchHandle = battlePrepareScene.touchHandler;
			
		elseif(game.state == game.GAME_STATE_INSTANCE )then
			-- 请求一次领地事件
			sendIncident(-1);
			instanceScene.sceneInit()
			game.touchHandle = instanceScene.touchHandle;
			game.uiWorldPosHandle = instanceScene.handleUIWorldPos;
			eventManager.dispatchEvent({name = global_event.ENTER_GAME_STATE_INSTANCE});
			game.multiTouchHandle = instanceScene.multiTouchHandle;
		end
end	

function game.battleTouchHandle(touchType, touchPosition)
	
	if "TouchUp" == touchType and LORD.SceneManager:Instance():isPlayingCameraAnimate() then
		LORD.SceneManager:Instance():stopCameraAnimations();

		-- 初始化场景
		local sceneID = battlePrepareScene.sceneID;
		local sceneInfo = dataConfig.configs.sceneConfig[sceneID];
		local cameraPos = LORD.Vector3(sceneInfo.cameraPosition[1], sceneInfo.cameraPosition[2], sceneInfo.cameraPosition[3]);
		local cameraDir = LORD.Vector3(sceneInfo.cameraDriection[1], sceneInfo.cameraDriection[2], sceneInfo.cameraDriection[3]);
		
		local camera = LORD.SceneManager:Instance():getMainCamera();	
		camera:setPosition(cameraPos);
		camera:setDirection(cameraDir);
		camera:setNearClip(1);
		camera:setFarClip(300);
			
		return;
	end
	
	local selecMagicNil =  (sceneManager.battlePlayer().selecMagic == nil)
	
	
	
	if sceneManager.battlePlayer().wait_action == true and not selecMagicNil then
			-- 处理国王魔法的释放
		if("TouchDown" == touchType )then
			
			castMagic.SelectTarget(touchPosition);
			castMagic.triggerClickMoveEffect(touchPosition);
			
		elseif("TouchUp" == touchType )then
			
			castMagic.cancelClickMoveEffect();
			-- 点击反馈
			castMagic.triggerClickEffect(touchPosition);
			
			castMagic.sendMagic();
			
		elseif("TouchMove" == touchType )then
		
			castMagic.SelectTarget(touchPosition);
			castMagic.triggerClickMoveEffect(touchPosition);
			
		end
		
	else

		-- 镜头过程中不处理
		local isPlayingCamera = LORD.SceneManager:Instance():isPlayingCameraAnimate();
		if isPlayingCamera then
			return;
		end
			
		if("TouchUp" == touchType )then
				-- 非国王魔法释放的时候处理点击
				-- 清除所有高亮
				sceneManager.battlePlayer():setAllGridNormal();
				
				if sceneManager.battlePlayer().wait_action == false  or selecMagicNil then
					 if sceneManager.battlePlayer() and battlePrepareScene.grid then		
					 	local ishit = battlePrepareScene.grid:isHitGrid(touchPosition);
					 	if ishit then
					 		local gridX = battlePrepareScene.grid:getHitX();
					 		local gridY = battlePrepareScene.grid:getHitY();
							if gridX ~= -1 and gridY ~= -1 then
								eventManager.dispatchEvent( {name = global_event.GUIDE_ON_BATTLE_CLICK_GRID ,arg1 = gridX,arg2 = gridY} )
							end
					 		local selectUnit = sceneManager.battlePlayer():GetCropsByPosition(gridX, gridY);
					 		if selectUnit and (battlePlayer.rePlayStatus == false)  then
					 			print("selectUnit "..selectUnit:getUnitID());
					 			sceneManager.battlePlayer():pauseGame(true);
		 						
		 						local shipAttr = {};
		 						shipAttr.attack = selectUnit:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK);
		 						shipAttr.defence = selectUnit:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE);
		 						shipAttr.critical = selectUnit:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL);
		 						shipAttr.resilience = selectUnit:getShipAttr(enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE);
		 						
		 						local unitAttr = {};
		 						unitAttr.soldierDamage = selectUnit:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_DAMAGE);
		 						unitAttr.defence = selectUnit:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_DEFENCE);
		 						unitAttr.soldierHP = selectUnit:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SOLDIER_HP);
		 						unitAttr.actionSpeed = selectUnit:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_SPEED);
		 						unitAttr.moveRange = selectUnit:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_MOVE_RANGE);
								unitAttr.attackRange = selectUnit:getAttribute(enum.UNIT_ATTR.UNIT_ATTR_ATTACK_RANGE);
								
		 						-- 战斗中查看军团信息
								
		 						eventManager.dispatchEvent({name = "CORPSDETAIL_SHOW", unitID = selectUnit:getUnitID(), curUnitNum = selectUnit.m_CropsNum, 
		 																			totalUnitNum = selectUnit.m_TotalCropsNum, buffList = selectUnit:getBuffList(), force = selectUnit:getForces(), shipAttr = shipAttr,
		 																			unitAttr = unitAttr, hp = selectUnit:getTotalHP(), maxHp = selectUnit:getMaxHP()});
		 						sceneManager.battlePlayer():signGrid(gridX, gridY, "r");
					 		end
					 	end
					 end
				end
		end
	end
	
end

