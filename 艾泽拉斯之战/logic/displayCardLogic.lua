displayCardLogic = {};
displayCardLogic.resultType = enum.CARD_RESULT_TYPE.CARD_RESULT_TYPE_INVALID;
displayCardLogic.resultData = {};
displayCardLogic.displayIndex = 1;
displayCardLogic.currentTimer = 0;
displayCardLogic.DISPLAY_WHOLE_TIME = 3.333; -- s
displayCardLogic.DISPLAY_ACTOR_TIME = 1.625; -- s
displayCardLogic.ACTOR_SCALE = LORD.Vector3(5, 5, 5);

displayCardLogic.isdisplaying = false;
displayCardLogic.currentActor = nil;

-- display结束的时候的摄像机偏移动作
displayCardLogic.endDisplayCameraTimer = -1;
displayCardLogic.endDisplayCameraHandle = -1;
displayCardLogic.DARK_MIN = 1;
displayCardLogic.DARK_MAX = 0.2;

-- 收到服务器消息
function displayCardLogic.initDisplay(cardResultType, resultCardInfo)
	
	displayCardLogic.resultType = cardResultType;
	displayCardLogic.resultData = resultCardInfo;
	
	displayCardLogic.displayIndex = 1;
	displayCardLogic.currentTimer = displayCardLogic.DISPLAY_WHOLE_TIME;
	displayCardLogic.isdisplaying = false;
	
	displayCardLogic.startNextDisplay();
	
end

function displayCardLogic.desstroyActor()
	if displayCardLogic.currentActor then
		LORD.ActorManager:Instance():DestroyActor(displayCardLogic.currentActor);
		displayCardLogic.currentActor = nil;
	end
	
	displayCardLogic.RevertLight();
	
	homeland.setCrystalVisible(true);
	
end

function displayCardLogic.startNextDisplay()
	
	displayCardLogic.desstroyActor();
	
	if displayCardLogic.displayIndex <= #displayCardLogic.resultData then
		displayCardLogic.currentTimer = displayCardLogic.DISPLAY_WHOLE_TIME;
		-- 展示下一个
		displayCardLogic.isdisplaying = true;
		eventManager.dispatchEvent({ name = global_event.CARD_HIDE_DRAW_CARD });
		eventManager.dispatchEvent({ name = global_event.CORPSGET1_HIDE });
		eventManager.dispatchEvent({ name = global_event.CORPSGET2_HIDE });
		
		-- 播特效
		homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.CARD]:AddSkillAttack("chouka01.att");
		
	else
		-- 结束
		
	end
end

function displayCardLogic.changeDarkScene(percent)
	if sceneManager.scene then
		sceneManager.scene:ChangeDark(percent);
		homeland.changeBuildDarkExcludeCard(percent);
		--print("percent  "..percent);
	end
end

function displayCardLogic.RevertLight()
	if sceneManager.scene then
		sceneManager.scene:RevertLight();
		homeland.RevertBuildLight();
	end
end

displayCardLogic.needAddAtt = false;
displayCardLogic.playwintime = 0;

function displayCardLogic.createUnitActor()
	
	if displayCardLogic.currentActor == nil then
		local cardType = displayCardLogic.resultData[displayCardLogic.displayIndex].cardID;
		local cardExp = displayCardLogic.resultData[displayCardLogic.displayIndex].cardExp
		local star = cardData.getStarByExp(cardExp);
		local unitID = cardData.getUnitIDByTypeAndStar(cardType, star);
		
		local unitInfo = dataConfig.configs.unitConfig[unitID];
	
		displayCardLogic.currentActor = LORD.ActorManager:Instance():CreateActor(unitInfo.resourceName, "win", false);
		displayCardLogic.playwintime = 0.001 * displayCardLogic.currentActor:PlaySkill("win");
		
		print("displayCardLogic.playwintime "..displayCardLogic.playwintime);
		displayCardLogic.playwintime = 2 * displayCardLogic.playwintime;
		
		cardData.playVoiceByUnitID(unitID);
	
		local position = LORD.Vector3(homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].x, 
																	homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].y, 
																	homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].z);
		
		position.y = position.y + 1.5;
		displayCardLogic.currentActor:SetPosition(position);
		displayCardLogic.currentActor:SetScale(displayCardLogic.ACTOR_SCALE);
		
		homeland.setCrystalVisible(false);
		
		displayCardLogic.needAddAtt = true;
		
		displayCardLogic.currentActor:ChangeDark(0.65);
		
	end
end

function displayCardLogic.onDisplay(dt)
	
	if displayCardLogic.isdisplaying then
		
		if displayCardLogic.displayIndex <= #displayCardLogic.resultData then
			
			displayCardLogic.cameraMove();
					
			if displayCardLogic.currentTimer <= 0 then
				
				print("displayCardLogic.displayIndex "..displayCardLogic.displayIndex);
				displayCardLogic.currentTimer = 0;
				displayCardLogic.endDisplay()
				
			else
				
				displayCardLogic.currentTimer = displayCardLogic.currentTimer - dt;
				
				if displayCardLogic.currentTimer < 0 then
					displayCardLogic.currentTimer = 0;
				end
				
				if displayCardLogic.currentActor == nil and (displayCardLogic.DISPLAY_WHOLE_TIME - displayCardLogic.currentTimer) > displayCardLogic.DISPLAY_ACTOR_TIME then
					displayCardLogic.createUnitActor();					
				end
				
				local radio = displayCardLogic.DARK_MIN + (displayCardLogic.DARK_MAX - displayCardLogic.DARK_MIN) * (1 - displayCardLogic.currentTimer / displayCardLogic.DISPLAY_WHOLE_TIME);
				displayCardLogic.changeDarkScene(radio);
				
			end
			
		end
	end

	if displayCardLogic.currentActor and displayCardLogic.currentActor:getHasInited() and displayCardLogic.needAddAtt == true then
		displayCardLogic.currentActor:AddSkillAttack("chouka02.att");
		displayCardLogic.needAddAtt = false;
	end
		
end

-- 旋转摄像机结束时候的位置
function displayCardLogic.getCameraDisplayPosition(percent)
	
	local cameraData = homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD];
	
	local initVector2 = LORD.Vector2(cameraData.pos.x - homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].x, cameraData.pos.z - homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].z);
	
	local radius = initVector2:len();
	--local rotate = (math.PI - math.PI * 0.08) * percent;
	local rotate = math.PI * percent;
	
	local x = homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].x + radius * math.cos(homeland.cameraRotate - rotate - math.PI);
	local y = homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].pos.y;
	local z = homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].z + radius * math.sin(homeland.cameraRotate - rotate - math.PI);
	
	return LORD.Vector3(x, y, z);
	
end

function displayCardLogic.getcameraMoveTarget()
	local target = LORD.Vector3(homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].x, 
															homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].y + 2.5, 
															homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].z);
	
	return target;
end

function displayCardLogic.cameraMove()
	
	local camera = LORD.SceneManager:Instance():getMainCamera();	
	local position = displayCardLogic.getCameraDisplayPosition((1 - displayCardLogic.currentTimer / displayCardLogic.DISPLAY_WHOLE_TIME));
	
	camera:setPosition(position);
	
	local target = displayCardLogic.getcameraMoveTarget();
	
	camera:setTarget(target);
end

function displayCardLogic.endDisplay()
	
	local delaychangetime = displayCardLogic.playwintime;
	
	if (displayCardLogic.DISPLAY_WHOLE_TIME - displayCardLogic.currentTimer) > displayCardLogic.DISPLAY_ACTOR_TIME then
		-- 已经创建了actor
		delaychangetime = displayCardLogic.playwintime - (displayCardLogic.DISPLAY_WHOLE_TIME 
																- displayCardLogic.currentTimer - displayCardLogic.DISPLAY_ACTOR_TIME);
	end
	
	print("end delaychangetime "..delaychangetime);
	
	scheduler.performWithDelayGlobal(function() 
		if displayCardLogic.currentActor and displayCardLogic.isdisplaying == false then
			displayCardLogic.currentActor:PlaySkill("idle");
		end	
	end, delaychangetime);
	
	displayCardLogic.changeDarkScene(displayCardLogic.DARK_MAX);
	homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.CARD]:RemoveSkillAttack("chouka01.att");
	
	
	-- 跳过有可能不创建actor
	displayCardLogic.createUnitActor();
	
	displayCardLogic.currentTimer = 0;
	displayCardLogic.isdisplaying = false;
	displayCardLogic.cameraMove();
	
	-- todo 启动一个计时器做摄像机的移动
	local camera = LORD.SceneManager:Instance():getMainCamera();
	local cameraData = homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD];
	
	if displayCardLogic.endDisplayCameraHandle >= 0 then
		print("displayCardLogic.endDisplay()");
		return;
	end
	
	local END_CAMERA_WHOLE_TIME = 0.5; -- s
	
	function endDisplayCameraFunc(dt)
		
		if displayCardLogic.endDisplayCameraTimer > END_CAMERA_WHOLE_TIME then
			scheduler.unscheduleGlobal(displayCardLogic.endDisplayCameraHandle);
			displayCardLogic.endDisplayCameraHandle = -1;
			
			camera:setPosition(cameraData.pos);
			camera:setDirection(cameraData.dir);

			-- star shake	
			eventManager.dispatchEvent({ name = global_event.CORPSGET1_SHOW, 
																	resultType = displayCardLogic.resultType, 
																	resultData = displayCardLogic.resultData, 
																	index = displayCardLogic.displayIndex });
																	
			eventManager.dispatchEvent({ name = global_event.CARD_SHOW_DRAW_CARD });
			
			displayCardLogic.displayIndex = displayCardLogic.displayIndex + 1;
		
		else
			
			displayCardLogic.endDisplayCameraTimer = displayCardLogic.endDisplayCameraTimer + dt;

			local startPosition = displayCardLogic.getCameraDisplayPosition(1);
			local startDir = displayCardLogic.getcameraMoveTarget() - startPosition;
			startDir:normalize();
						
			local percent = displayCardLogic.endDisplayCameraTimer / END_CAMERA_WHOLE_TIME;
			local nowPosition = startPosition + (cameraData.pos - startPosition) * percent;
			local nowDir = startDir + (cameraData.dir - startDir) * percent;
			
			camera:setPosition(nowPosition);
			camera:setDirection(nowDir);
			
		end
		
	end
	
	--displayCardLogic.endDisplayCameraTimer = 0;
	--displayCardLogic.endDisplayCameraHandle = scheduler.scheduleGlobal(endDisplayCameraFunc, 0);

			displayCardLogic.endDisplayCameraHandle = -1;
			
			-- star shake	
			eventManager.dispatchEvent({ name = global_event.CORPSGET1_SHOW, 
																	resultType = displayCardLogic.resultType, 
																	resultData = displayCardLogic.resultData, 
																	index = displayCardLogic.displayIndex });
																	
			eventManager.dispatchEvent({ name = global_event.CARD_SHOW_DRAW_CARD });
			
			displayCardLogic.displayIndex = displayCardLogic.displayIndex + 1;
				
end
