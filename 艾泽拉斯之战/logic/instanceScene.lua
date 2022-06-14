instanceScene = {}
instanceScene._event = {}
instanceScene.airshipFlyHandle = nil
instanceScene.stageOBJPos = {}
instanceScene.disToTargetScale  = 1
instanceScene.mainPointActorName         =  dataConfig.configs.stageModelConfig[1].fileName
instanceScene.pointActorName         =  "xiaotaizi.actor"    -- instanceScene.mainPointActorName   

instanceScene.StarmeshName ={}
instanceScene.StarmeshName[enum.Adventure_TYPE.NORMAL]         =  dataConfig.configs.stageModelConfig[7].fileName
instanceScene.StarmeshName[enum.Adventure_TYPE.ELITE]         =  dataConfig.configs.stageModelConfig[8].fileName

instanceScene.StarAttach ={}
instanceScene.StarAttach[1]         =  dataConfig.configs.stageModelConfig[4].fileName
instanceScene.StarAttach[2]         =  dataConfig.configs.stageModelConfig[5].fileName
instanceScene.StarAttach[3]         =  dataConfig.configs.stageModelConfig[6].fileName
instanceScene.guid_winName  = {}

instanceScene.fogFadeTimeHandle = nil
function instanceScene.build()
	instanceScene.addEvent({ name = global_event.INSTANCECHOICE_SHOW, eventHandler = instanceScene.onShow})
	instanceScene.addEvent({ name = global_event.INSTANCEINFOR_HIDE,  eventHandler =  instanceScene.onHide})
	instanceScene.addEvent({ name = global_event.INSTANCECHOICE_UPDATE, eventHandler = instanceScene.onUpdate});
	instanceScene.addEvent({ name = global_event.INSTANCECHOICE_HIDE,  eventHandler =  instanceScene.onHide})
	instanceScene.addEvent({ name = global_event.TRANSITIONSCENE_HIDE, eventHandler = instanceScene.onTransitionHide});
	instanceScene.addEvent({ name = global_event.TRANSITIONSCENE_SHOW, eventHandler = instanceScene.onTransitionShow});

	
	instanceScene.RegiserEvent()
	instanceScene.stageTipUi = {}
	instanceScene.incidentPanel = {};
	
	instanceScene.Chapter   =  nil                   
	instanceScene.AdventureIndex   =  nil
	instanceScene.oldAdventureIndex   =  nil
	instanceScene.curSelStafeMode = enum.Adventure_TYPE.NORMAL-- 普通
	
	
	instanceScene.allActor = nil
	instanceScene.initOk = false
	instanceScene.actorActionHandle = nil
	instanceScene.actorONPoint = false
end

function instanceScene.buildNMode()
	instanceScene.NMode  = {}
	local zones = dataManager.instanceZonesData
	local chapters = dataManager.instanceZonesData:getAllChapter()
	for i,v in ipairs (chapters)do
		local Adventure = v:getAdventure()
		for z = 1,#Adventure do  	
			local stage = zones:getStageWithAdventureID(Adventure[z],instanceScene.curSelStafeMode)
			--if(stage:isMissed() == false) then
				table.insert(instanceScene.NMode,Adventure[z])
			--end
		end
	end	
end

function instanceScene.tochangeMode(mode)
	
	instanceScene.curSelStafeMode  = mode
	instanceScene.buildNMode()
end




function instanceScene.findIndexWithAdventureId(AdventureId)
	local index = table.keyOfItem(instanceScene.NMode, AdventureId)
	
	if(index == nil)then
		for i ,v in ipairs (instanceScene.NMode) do
			if(AdventureId >= v)then
				return  i
			end
		end
	end
	return index  or 1
end
	


function instanceScene.onHide()
	instanceScene.release()

end
function instanceScene.release()

	instanceScene.NavigatePoint = nil;
	
	local actorManager = LORD.ActorManager:Instance()
	if(instanceScene.actor ~= nil)then
		actorManager:DestroyActor(instanceScene.actor)
		instanceScene.actor  = nil
	end
	if(instanceScene.flyactor ~= nil)then
		actorManager:DestroyActor(instanceScene.flyactor)
		instanceScene.flyactor  = nil
	end
	instanceScene.initOk = false
	
	if(instanceScene.allActor ~= nil)then
		for i ,v in pairs(instanceScene.allActor)do
			actorManager:DestroyActor(v)
		end
	end

	instanceScene.allActor = nil
	 
	instanceScene.BeginPoint = nil
	
	sceneManager.closeScene();
	
	local camera = LORD.SceneManager:Instance():getMainCamera();	
	camera:setUp(LORD.Vector3(0,1,0));
		
	if(instanceScene.stageTipUi )then
		for i,v in pairs(instanceScene.stageTipUi)do
			LORD.GUIWindowManager:Instance():DestroyGUIWindow(v.wndRoot);	
		end
	end
	instanceScene.stageTipUi = {}
	
	if instanceScene.incidentPanel then
		for k,v in pairs(instanceScene.incidentPanel) do
			LORD.GUIWindowManager:Instance():DestroyGUIWindow(v.incidentUIRoot);
		end
	end
	instanceScene.incidentPanel = {};
	
	if(instanceScene.airshipFlyHandle ~= nil)then
		scheduler.unscheduleGlobal(instanceScene.airshipFlyHandle)
		instanceScene.airshipFlyHandle = nil
	end
	instanceScene.stageOBJPos ={}
	
	if(instanceScene.actorActionHandle ~= nil)then
		scheduler.unscheduleGlobal(instanceScene.actorActionHandle)
		instanceScene.actorActionHandle = nil
	end
	
	if(instanceScene.fogFadeTimeHandle ~= nil)then
		scheduler.unscheduleGlobal(instanceScene.fogFadeTimeHandle)
		instanceScene.fogFadeTimeHandle = nil
	end
 
	 
end	
function instanceScene.onEvent(event)

     if(nil == instanceScene._event[event.name]) then
        echoInfo("instanceScene:onEvent event.name %s not find",event.name)
     end
     local eventHandler = instanceScene._event[event.name].eventHandler
     if(eventHandler) then
           eventHandler(event)
     end
end
function instanceScene.addEvent(event )
	instanceScene._event = instanceScene._event or {}
    instanceScene._event[event.name] = event
end
function instanceScene.RegiserEvent()
	 for k,v in pairs (instanceScene._event) do 			
		eventManager.addEventLister(k,instanceScene.onEvent)
	 end
end


function instanceScene.sceneInit()
	instanceScene.release()
	instanceScene.buildNMode()
	eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE })
	local scene = sceneManager.loadScene("world")
	instanceScene.actor = objectManager.CreateMainActor("guowang.actor")
	instanceScene.NavigatePoint = sceneManager.scene:GetNavigatePoint()
	instanceScene.NavigatePoint:setMainActor(instanceScene.actor,0)
	
	instanceScene.flyactor = objectManager.CreateMainActor("feiting.actor")
    instanceScene.flyactor:SetShadowVisible(false)
	instanceScene.flyactor:SetScale(LORD.Vector3(0.3,0.3,0.3))
			 
	instanceScene.NavigatePoint:setMaxHeight(INSTANCESCENE_STAGE_MAX_HEIGHT);
	instanceScene.NavigatePoint:setMinHeight(INSTANCESCENE_STAGE_MINHEIGHT);
	
	instanceScene.allActor = instanceScene.allActor or {}
	
	local zones = dataManager.instanceZonesData	
	local chapters = zones:getAllChapter()
	local actor = nil
	instanceScene.fog = {}
	for i = 2,16 do
		local name = string.format("%02d",i)	
		
		local obj = scene:getGameObject("warfog"..name)
		instanceScene.fog[i] =   tolua.cast( obj,"LORD::HazeObejct")  
		--instanceScene.fog[i]:setVisible(true)
		--instanceScene.fog[i]:setAlpha(1)
	end	
 
	for i,v in ipairs (chapters)do
			 
		local Adventure = v:getAdventure()
		for z = 1,#Adventure do	
		
			local stage = zones:getStageWithAdventureID(Adventure[z],instanceScene.curSelStafeMode)
			
			
	  --[==[
			if(stage:isMain() == true )then
				local t ={}
				t.wndRoot  = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("instanceScene-"..i.."-"..z,"instancesign.dlg");
				t.Instance_name = LORD.GUIWindowManager:Instance():GetGUIWindow("instanceScene-"..i.."-"..z.."_instancesign-name")
				t.star = {}
				for k =1 ,3 do
					t.star[k] = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("instanceScene-"..i.."-"..z.."_instancesign-star"..k))
				end
				instanceScene.stageTipUi[Adventure[z]] = t
				engine.uiRoot:AddChildWindow(t.wndRoot)
			end	
			
			
			 --]==]--			
			
			
			
			--if(stage:isMissed() == false) then
				local  aName =           instanceScene.mainPointActorName	
				if(stage:isMain() == false )then
					aName = instanceScene.pointActorName
				end
				actor = objectManager.CreateMainActor2(aName ,true)
				--actor:SetScale(LORD.Vector3(2,2,2))
				
				if(stage:isMain() == false )then
					actor:SetScale(LORD.Vector3(3.5,3.5,3.5))
				else
					
					actor:SetScale(LORD.Vector3(1.9,1.9,1.9))
				end				
				
				
				actor:SetShadowVisible(false)
				--print("actor--------------------------------------------------- Adventure[z]"..(actor:getActorNameID()).." "..Adventure[z])
				instanceScene.allActor[Adventure[z]] = actor
				instanceScene.NavigatePoint:setPointActor(actor,stage:getPoint())
			--end
		end
	end	
	
	
	
	-- 创建领地事件的ui
	local maxIncidentCount = dataManager.mainBase:getLingDiMaxCount();
	for i = 1, maxIncidentCount do
		local t = {};
		t.incidentUIRoot  = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("incident-"..i,"incidentPanel.dlg");
		t.countdown = LORD.GUIWindowManager:Instance():GetGUIWindow("incident-"..i.."_incidentPanel-countdown");
		t.countdownTime = LORD.GUIWindowManager:Instance():GetGUIWindow("incident-"..i.."_incidentPanel-countdown-time");
		t.sign = LORD.GUIWindowManager:Instance():GetGUIWindow("incident-"..i.."_incidentPanel-sign");
		instanceScene.incidentPanel[i] = t;
		
		engine.uiRoot:AddChildWindow(t.incidentUIRoot);
	end
	instanceScene.initOk = true
	
	
	if(instanceScene.actorActionHandle ~= nil)then
		scheduler.unscheduleGlobal(instanceScene.actorActionHandle)
		instanceScene.actorActionHandle = nil
	end
	
	function instanceScene_ActorActionTick(dt)
		
	
		if(instanceScene.actor == nil)then
			return 
		end
		if(instanceScene.actorONPoint == false)then
			instanceScene.m_Time = 0
			instanceScene.m_WinTime  = nil 
			return 
		end
		instanceScene.m_Time = instanceScene.m_Time or 0
		instanceScene.m_Time = instanceScene.m_Time + dt
		
		if(instanceScene.m_WinTime ~= nil)then
			instanceScene.m_WinTime  = instanceScene.m_WinTime - dt 
		end
		
		if(instanceScene.m_WinTime)then
			if(instanceScene.m_WinTime <=0)then
				instanceScene.m_WinTime  = nil 
				instanceScene.actor:PlaySkill("idle",false,false,1)	
			end
		else
			if(instanceScene.m_Time >= INSTANCESCENE_STAGE_ACTOR_ACRION_Time)then
				instanceScene.m_WinTime  = instanceScene.actor:PlaySkill("win",false,false,1)
				instanceScene.m_WinTime = INSTANCESCENE_STAGE_ACTOR_ACRION_WinTime
				instanceScene.m_Time = 0
			end
			
		end
	end
	if(instanceScene.actorActionHandle == nil)then
		instanceScene.actorActionHandle = scheduler.scheduleGlobal(instanceScene_ActorActionTick,0.5)--global.goldMineInterval
	end	
end

function instanceScene.onShow(event)

	global.changeGameState(function() 
		 instanceScene.tochangeMode(event.curSelStafeMode or  instanceScene.curSelStafeMode)
		
		game.EnterProcess(game.GAME_STATE_INSTANCE)	
		instanceScene.showStageInfo = event.showStageInfo 
		if(instanceScene.showStageInfo == nil)then
			instanceScene.showStageInfo = true
		end
		instanceScene.__stage = event.stage
		instanceScene.notips = event.notips or false
		instanceScene.toNewStage = event.toNewStage or false
		if(event.toNewStage)then
			instanceScene.Chapter   =  nil
			instanceScene.AdventureIndex   =  nil
			instanceScene.__stage = nil
		end
		instanceScene.upDate(true)
	end);


end	


function instanceScene.onUpdate(event)
	
	instanceScene.toNewStage = event.toNewStage or false
	
	if(event.toNewStage)then       -- 切换精英与普通最新关卡
		instanceScene.Chapter   =  nil
		instanceScene.AdventureIndex   =  nil
		instanceScene.__stage = nil
		instanceScene.changeMode = instanceScene.curSelStafeMode -- 切换模式
		event.curSelStafeMode = event.curSelStafeMode or  instanceScene.curSelStafeMode
		instanceScene.tochangeMode(event.curSelStafeMode)
		instanceScene.changeMode =  (instanceScene.changeMode ~= instanceScene.curSelStafeMode) 
 
	end
	if(event.chapter)then   	--- 快速选择章节 切换到章节第一关
		instanceScene.Chapter = event.chapter
		local zones = dataManager.instanceZonesData	
		local curChapter = zones:getAllChapter()[instanceScene.Chapter]	
		local Adventure = curChapter:getAdventure()
		local AdventureIndex = curChapter:getFirstMainAdventure(instanceScene.curSelStafeMode)
		if(AdventureIndex <= 0)then
			AdventureIndex = 1
		end
		local AdventureId = event.AdventureId  or  Adventure[AdventureIndex]
		local index = instanceScene.findIndexWithAdventureId(AdventureId)
		instanceScene.AdventureIndex  = index
		instanceScene.__stage = nil
	end
	instanceScene.upDate(false)
end	




function instanceScene.tick(dt)
	if(instanceScene.NavigatePoint == nil or instanceScene.actor == nil )then
		return
	end
	local result = instanceScene.NavigatePoint:update(dt*1000)
	if(result and instanceScene._startFindPath == true)then
		instanceScene.onArrivedStage() 
		instanceScene._startFindPath = false
	end

end

function instanceScene.handleUIWorldPos(dt)	
	--[==[
	if(instanceScene.stageTipUi and sceneManager.scene and instanceScene.initOk )then
		local zones = dataManager.instanceZonesData
		local AllChapter = zones:getAllChapter()
		local m = 0
		local center = sceneManager.scene:getSphereTerrainCenter()
		for k, v in ipairs (AllChapter)	do
				local Adventure =  v:getAdventure()	
				m = m + 1
				local n = 0 
				for i =1,#Adventure do  	
						local stage = zones:getStageWithAdventureID(Adventure[i],instanceScene.curSelStafeMode)
						local star = stage:getVisStarNum()
						if(stage:isMain() == true )then	
							n = n + 1;
							
							local gameobj = instanceScene.stageOBJPos[Adventure[i]]
							if(gameobj == nil )	then
								gameobj = instanceScene.allActor[Adventure[i]] --sceneManager.scene:getSMeshObjectByNoteForAll(tostring(stage:getPoint()));
								instanceScene.stageOBJPos[Adventure[i]] = gameobj
							end					
							if(gameobj and gameobj:frustumIntersects())then
								local worldPos = gameobj:GetPosition();
								
								--[[
								if(k ==1 and i ==1)then
									print("gameobj world pos ".." "..(gameobj:getActorNameID()).." "..(gameobj:getUserData()).." "..worldPos.x.." "..worldPos.y.." "..worldPos.z)
								end
								]]--
								local up  =  (gameobj:GetPosition() - center)
								up:normalize()
						
								--worldPos.x = worldPos.x + INSTANCESCENE_STAGE_OFFSET_X
								--worldPos.y = worldPos.y + INSTANCESCENE_STAGE_OFFSET_Y
								--worldPos.z = worldPos.z
								
								--worldPos = worldPos - up*0.1
								worldPos.z = worldPos.z - up.z*0.1
								worldPos.y = worldPos.y + up.y*0.1
								
							
								local initPos = LORD.Vector2(0, 0);
								initPos = LORD.GUISystem:Instance():WorldPostionToScreen(worldPos);		
								local x = initPos.x -  instanceScene.stageTipUi[Adventure[i]].wndRoot:GetPixelSize().x  /2
								local y = initPos.y - instanceScene.stageTipUi[Adventure[i]].wndRoot:GetPixelSize().y
								
								instanceScene.stageTipUi[Adventure[i]].wndRoot:SetPosition(LORD.UVector2(LORD.UDim(0, x), LORD.UDim(0, y)));
								
								instanceScene.stageTipUi[Adventure[i]].Instance_name:SetText(m.." - "..n)--stage:getName()
								
								for z =1,3  do			
									--instanceScene.stageTipUi[Adventure[i]].star[z]:SetVisible(z <= star)  
									instanceScene.stageTipUi[Adventure[i]].star[z]:SetVisible(false)  
								end								
								instanceScene.stageTipUi[Adventure[i]].wndRoot:SetVisible(true);	
							 
							else
								instanceScene.stageTipUi[Adventure[i]].wndRoot:SetVisible(false);
							end		
						end		
				end
		end	
	end
	--]==]---
	-- 更新领地事件
	
 
	
	if instanceScene.incidentPanel and sceneManager.scene then
		
			for i ,v in pairs (instanceScene.guid_winName) do
				Guide.updatePos(i,v:GetPosition()) 	
			end	
		
		
		local maxIncidentCount = dataManager.mainBase:getLingDiMaxCount();
		local zones = dataManager.instanceZonesData;
		
		for i = 1, maxIncidentCount do
			local remainTime = dataManager.mainBase:getRemineIncidentTime(i);
			local position = dataManager.mainBase:getIncidentPosition(i);
			local eventID = dataManager.mainBase:getPlayerIncidentIndex(i);
			
			-- 先判断位置，位置无效就整体隐藏
			if position < 0 or instanceScene.curSelStafeMode ~= enum.Adventure_TYPE.NORMAL then
				instanceScene.incidentPanel[i].incidentUIRoot:SetVisible(false);
			else
				local point = dataManager.mainBase:getIncidentPoint(i);
				local AdventureId = zones:serchAdventureIdWithPoint( point)
				local gameobj = instanceScene.stageOBJPos[AdventureId]
				
				if(gameobj == nil )	then
					gameobj =  instanceScene.allActor[AdventureId]   ---sceneManager.scene:getSMeshObjectByNoteForAll(point);
					instanceScene.stageOBJPos[AdventureId] = gameobj
				end	
				
				if gameobj then

					local worldPos = gameobj:GetPosition();
					local up  =  (gameobj:GetPosition() - sceneManager.scene:getSphereTerrainCenter())
					up:normalize()
					worldPos.z = worldPos.z - up.z*0.1;
					worldPos.y = worldPos.y + up.y*0.1;
					local initPos = LORD.Vector2(0, 0);
					initPos = LORD.GUISystem:Instance():WorldPostionToScreen(worldPos);		
					local uirootSize = instanceScene.incidentPanel[i].incidentUIRoot:GetPixelSize();

					local x = initPos.x - uirootSize.x/2;
					local y = initPos.y - uirootSize.y;

					-- 超出屏幕外的 如果是可以打的状态，要在屏幕上显示
					if x < 0 then
						x = 0;
					end
					
					if y < 0 then
						y = 0;
					end
					
					if x + uirootSize.x > engine.rootUiSize.w then
						x = engine.rootUiSize.w - uirootSize.x;
					end
					
					if y + uirootSize.y > engine.rootUiSize.h then
						y = engine.rootUiSize.h - uirootSize.y;
					end
					
					instanceScene.incidentPanel[i].incidentUIRoot:SetPosition(LORD.UVector2(LORD.UDim(0, x), LORD.UDim(0, y)));
																														
					if gameobj:frustumIntersects() then
						instanceScene.incidentPanel[i].incidentUIRoot:SetVisible(true);
												
						if remainTime > 0 then
							-- 打了没打过，进入倒计时
							if eventID > 0 then
								instanceScene.incidentPanel[i].countdown:SetVisible(true);
								instanceScene.incidentPanel[i].countdownTime:SetText(formatTime(remainTime, true));
							else
								instanceScene.incidentPanel[i].countdown:SetVisible(false);
							end
							
							instanceScene.incidentPanel[i].sign:SetVisible(true);
						else
							--显示能打的相关提示
							instanceScene.incidentPanel[i].countdown:SetVisible(false);
							instanceScene.incidentPanel[i].sign:SetVisible(true);
						end	
					else
						
						-- 超出屏幕外的 如果是可以打的状态，要在屏幕上显示
						if remainTime <= 0 then
							
							instanceScene.incidentPanel[i].incidentUIRoot:SetVisible(true);					
							instanceScene.incidentPanel[i].countdown:SetVisible(false);
							instanceScene.incidentPanel[i].sign:SetVisible(true);
						else
							instanceScene.incidentPanel[i].incidentUIRoot:SetVisible(false);
						end
					end
				
				else
					-- 隐藏掉
					instanceScene.incidentPanel[i].incidentUIRoot:SetVisible(false);
				end
					
			end
		end
	end
	
end

function instanceScene.onArrivedStage()
	--[[
	 instanceScene.AdventureIndex  = instanceScene.AdventureIndex  + 1
	 if(instanceScene.immediately == nil)then
		instanceScene.immediately = false
	 end
	 if(instanceScene.AdventureIndex >= #instanceScene.NMode )then
		instanceScene.AdventureIndex  = 1
		instanceScene.immediately  = not instanceScene.immediately 
	 end
	 instanceScene.upDate(instanceScene.immediately  )
	]]--
	local zones = dataManager.instanceZonesData
	local stage = zones:getStageWithAdventureID(instanceScene.NMode[instanceScene.AdventureIndex] ,instanceScene.curSelStafeMode)		
	eventManager.dispatchEvent({name = global_event.INSTANCEINFOR_SHOW,stage = stage })
	
	eventManager.dispatchEvent( {name =  global_event.INSTANCEINFOR_HIDE_ON_MOVE,visible = instanceScene.showStageInfo} )
	instanceScene.showStageInfo = true
	instanceScene.actorONPoint = true
	instanceScene.oldAdventureIndex  = instanceScene.AdventureIndex
	
	scheduler.performWithDelayGlobal(function() 
		eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_GAME_STATE_INSTANCEE,arg1 = instanceScene.curSelStafeMode});	
	end, 0);

end	

 
function instanceScene.upDate(immediately)
 
	if(instanceScene.__stage)then
		instanceScene.Chapter = instanceScene.__stage:getChapter():getId()
	 
		instanceScene.tochangeMode(instanceScene.__stage:getType())
		
		local AdventureId = instanceScene.__stage:getAdventureID()
		local index = instanceScene.findIndexWithAdventureId( AdventureId)
		instanceScene.AdventureIndex  = index
	end	

	local zones = dataManager.instanceZonesData
	if(instanceScene.AdventureIndex == nil)then instanceScene.AdventureIndex = 1 end
	
	if(instanceScene.Chapter == nil)then 
		local stage = zones:getNewInstance(instanceScene.curSelStafeMode)
		instanceScene.Chapter = stage:getChapter():getId()
		local index = instanceScene.findIndexWithAdventureId( stage:getAdventureID())
		instanceScene.AdventureIndex  = index
	end
	
	local maxChapter = # (zones:getAllChapter() )
	local minChapter = 1
	if(instanceScene.Chapter  >  maxChapter)then
		instanceScene.Chapter  = maxChapter
	end
	
	


	local newChapter = zones:getNewChapter(instanceScene.curSelStafeMode)
	local chapterId = nil
	local AllChapter = zones:getAllChapter()
	
	local timeToFade = 0.75
	function instanceScene_fogFade(dt)
		instanceScene.fogTime = instanceScene.fogTime or 0
		instanceScene.fogTime = instanceScene.fogTime + dt
		local fog = instanceScene.fog[newChapter:getId()]
		fog:setAlpha(0.9 - instanceScene.fogTime/timeToFade )
		if( instanceScene.fogTime >= timeToFade)then
			instanceScene.fogTime = 0
			fog:setVisible(false)
			if(instanceScene.fogFadeTimeHandle ~= nil)then
					scheduler.unscheduleGlobal(instanceScene.fogFadeTimeHandle)
					instanceScene.fogFadeTimeHandle = nil
			end
		end		
		
	end		

	for k, v in ipairs (AllChapter)	do
			chapterId = v:getId()
			if(chapterId <  newChapter:getId())then
				if(instanceScene.fog[chapterId] )then
					instanceScene.fog[chapterId]:setVisible(false)
				end
			elseif(chapterId == newChapter:getId())then
			--[[
				if(instanceScene.fog[chapterId] )then
					instanceScene.fog[chapterId]:setVisible(true)
					instanceScene.fog[chapterId]:setAlpha(0.9)	
					if(instanceScene.fogFadeTimeHandle ~= nil)then
						scheduler.unscheduleGlobal(instanceScene.fogFadeTimeHandle)
						instanceScene.fogFadeTimeHandle = nil
					end
					if(instanceScene.fogFadeTimeHandle == nil)then

						function dealy_instanceScene_fogFade()
								instanceScene.fogFadeTimeHandle = scheduler.scheduleGlobal(instanceScene_fogFade,0)
						end

						scheduler.performWithDelayGlobal(dealy_instanceScene_fogFade, 1.5)
					end
					
				end	
				]]--
				if(instanceScene.fog[chapterId] )then
					instanceScene.fog[chapterId]:setVisible(false)
				end
				
			else
				if(instanceScene.fog[chapterId] )then
					instanceScene.fog[chapterId]:setVisible(true)
					instanceScene.fog[chapterId]:setAlpha(0.9)
				end
			end
			local Adventure =  v:getAdventure()	
			for i =1,#Adventure do  	
					local stage = zones:getStageWithAdventureID(Adventure[i],instanceScene.curSelStafeMode)
			 
					local star = stage:getVisStarNum()
						local gameobj = instanceScene.stageOBJPos[Adventure[i]]
					
						if(gameobj == nil )	then
							gameobj =   instanceScene.allActor[Adventure[i]]                   ---sceneManager.scene:getSMeshObjectByNoteForAll(tostring(stage:getPoint()));
							instanceScene.stageOBJPos[Adventure[i]] = gameobj
						end					
						if(gameobj)then
							--sceneManager.scene:EnableStaticMeshGrayRender(gameobj,not stage:isEnable()) 
							if(not stage:isEnable()) then
								gameobj:ChangeStone()
							else
								gameobj:RevertEffectTexture()	
							end	
							gameobj:setActorHide(stage:isMissed())
							for z = 1,3 do
								gameobj:DeleteChildMesh("star"..z)
							end
							
							local Position = LORD.Vector3(0, 0, 0)
							local Quaternion = LORD.Quaternion()
							local scale = LORD.Vector3(1, 1, 1)
							for z = 1,star do
								gameobj:AddChildMesh("star"..z ,instanceScene.StarAttach[z],instanceScene.StarmeshName[instanceScene.curSelStafeMode] ,Position,Quaternion,scale)
							end
			 
						end			
			end
	end	
	
    instanceScene:updateCurChapter(immediately)
end	

--------

function instanceScene.flyDownAirship_callBack()
		   instanceScene._startFindPath = true
		   local zones = dataManager.instanceZonesData	
		   local stage = zones:getStageWithAdventureID(instanceScene.NMode[instanceScene.AdventureIndex] ,instanceScene.curSelStafeMode)	
		   instanceScene.NavigatePoint:startFindPath(stage:getPoint(),true) -- 路点序号  true就是立马到达	
			for i,v in pairs (instanceScene.stageTipUi)do
				v.wndRoot:SetVisible(true)
			end
			instanceScene.actor:setActorHide(false)
			instanceScene.flyactor:setActorHide(true)
end
function instanceScene.onTransitionHide( ) 
	
		 instanceScene._startFindPath = false
		 local zones = dataManager.instanceZonesData	
		 local stage = zones:getStageWithAdventureID(instanceScene.NMode[instanceScene.AdventureIndex] ,instanceScene.curSelStafeMode)	
		 instanceScene.NavigatePoint:startFindPath(stage:getPoint(),true) -- 路点序号  true就是立马到达	
		
		if(instanceScene.changeMode)then 
			instanceScene.flyDownAirship_callBack()
			instanceScene.changeMode = false
			return 
		end	
		instanceScene.flyDownAirship(instanceScene.flyDownAirship_callBack)		
end	


function instanceScene.onTransitionShow( ) 
		
	for i,v in pairs (instanceScene.stageTipUi)do
		 v.wndRoot:SetVisible(false)
	end
	
	-----拉回来 在起飞
	instanceScene._startFindPath = false
	local zones = dataManager.instanceZonesData	
	local stage = zones:getStageWithAdventureID(instanceScene.NMode[instanceScene.oldAdventureIndex] ,instanceScene.curSelStafeMode)	
	instanceScene.NavigatePoint:startFindPath(stage:getPoint(),true) -- 路点序号  true就是立马到达		
	if(instanceScene.changeMode)then 
		eventManager.dispatchEvent( {name = global_event.TRANSITIONSCENE_FADEOUT} )
		return 
	end	
	instanceScene.flyUpAirship()
end	


function instanceScene:updateCurChapter(immediately) 
	
	if(instanceScene.oldAdventureIndex)then
		if(math.abs(instanceScene.AdventureIndex - instanceScene.oldAdventureIndex) >= INSTANCE_JUMP_STEP)then
			immediately = true
		end
		if(instanceScene.AdventureIndex - instanceScene.oldAdventureIndex == 0)then
			instanceScene.BeginPoint = nil
		end
	end
	
	eventManager.dispatchEvent( { name = global_event.CHAPTERAWARD_UPDATE, chapter = instanceScene.Chapter,curSelStafeMode = instanceScene.curSelStafeMode})	
	local zones = dataManager.instanceZonesData	
	
	local curChapter = zones:getAllChapter()[instanceScene.Chapter]	
	if(curChapter == nil )then
		print("instanceScene.Chapter"..instanceScene.Chapter)
	end
	

	
	local stage = zones:getStageWithAdventureID(instanceScene.NMode[instanceScene.AdventureIndex] ,instanceScene.curSelStafeMode)		
	instanceScene.actorONPoint = false
	if(instanceScene.BeginPoint == nil )then
		if(self.changeMode)then
			eventManager.dispatchEvent( {name =  global_event.INSTANCEINFOR_HIDE_ON_MOVE} )
			eventManager.dispatchEvent( {name = global_event.TRANSITIONSCENE_SHOW,Alpha = 1.0})	
			eventManager.dispatchEvent( {name = global_event.INSTANCEINFOR_FLY_TO_STAGE})	 
		end	
		instanceScene.NavigatePoint:setBeginPoint(stage:getPoint())
		instanceScene.BeginPoint = true
		instanceScene._startFindPath = true
	else
		
		if(self.changeMode)then
			eventManager.dispatchEvent( {name =  global_event.INSTANCEINFOR_HIDE_ON_MOVE} )
			eventManager.dispatchEvent( {name = global_event.TRANSITIONSCENE_SHOW})	
			eventManager.dispatchEvent( {name = global_event.INSTANCEINFOR_FLY_TO_STAGE})	
			return 
		end	
		
		if(immediately)then
			eventManager.dispatchEvent( {name =  global_event.INSTANCEINFOR_HIDE_ON_MOVE} )
			eventManager.dispatchEvent( {name = global_event.TRANSITIONSCENE_SHOW})	
			eventManager.dispatchEvent( {name = global_event.INSTANCEINFOR_FLY_TO_STAGE})	
			
		else
			instanceScene._startFindPath = true
			instanceScene.NavigatePoint:startFindPath(stage:getPoint(),immediately) -- 路点序号  true就是立马到达	
			eventManager.dispatchEvent( {name =  global_event.INSTANCEINFOR_HIDE_ON_MOVE} )
			
		end
	end
	
end	

function instanceScene.flyUpAirship()
	local zones = dataManager.instanceZonesData	
	local stage = zones:getStageWithAdventureID(instanceScene.NMode[instanceScene.oldAdventureIndex] ,instanceScene.curSelStafeMode)			
	if(instanceScene.airshipFlyHandle ~= nil)then
		scheduler.unscheduleGlobal(instanceScene.airshipFlyHandle)
		instanceScene.airshipFlyHandle = nil
	end
	instanceScene.dt = 0
	instanceScene.actor:setActorHide(true)
	instanceScene.flyactor:setActorHide(false)
	function flyUpAirshipTimeTick(dt)
		if(instanceScene.flyactor)then 
			local AdventureId = stage:getAdventureID()
			local gameobj = instanceScene.stageOBJPos[AdventureId]
		if(gameobj == nil )	then
		
			
			gameobj = instanceScene.allActor[AdventureId] -- sceneManager.scene:getSMeshObjectByNoteForAll(tostring(stage:getPoint()));
			instanceScene.stageOBJPos[AdventureId] = gameobj
		end					

		if(gameobj)then
			instanceScene.flyactor:PlaySkill("run",false,false,1)	
			local up  =  (gameobj:GetPosition() - sceneManager.scene:getSphereTerrainCenter())
			up:normalize()
			local dir =  up:cross(LORD.Vector3(0,0,1))
			local xVec  = up:cross(dir)
			xVec:normalize()
			local yVec  = dir:cross(xVec)
			yVec:normalize()
			local tem = LORD.Quaternion()
			tem:fromAxes(xVec,yVec,dir)
			instanceScene.flyactor:SetOrientation(tem)	
	
			local pos =  gameobj:GetPosition()
			instanceScene.dt  = (instanceScene.dt  + dt)  
			pos = pos + up*instanceScene.dt* INSTANCESCENE_STAGE_flyUpAirshipSpeed 
			instanceScene.flyactor:SetPosition(pos);			
		end
		if(instanceScene.dt >= INSTANCESCENE_STAGE_flyUpAirshipTime)then
			eventManager.dispatchEvent( {name = global_event.TRANSITIONSCENE_FADEOUT} )
			scheduler.unscheduleGlobal(instanceScene.airshipFlyHandle)
			instanceScene.airshipFlyHandle = nil
		end
	end
	
	end	
	
	if(instanceScene.airshipFlyHandle == nil)then
		instanceScene.airshipFlyHandle = scheduler.scheduleGlobal(flyUpAirshipTimeTick,0)
	end 
end


function instanceScene.flyDownAirship(callback)
	local zones = dataManager.instanceZonesData	
	local stage = zones:getStageWithAdventureID(instanceScene.NMode[instanceScene.AdventureIndex] ,instanceScene.curSelStafeMode)			
	if(instanceScene.airshipFlyHandle ~= nil)then
		scheduler.unscheduleGlobal(instanceScene.airshipFlyHandle)
		instanceScene.airshipFlyHandle = nil
	end
	instanceScene.dt = 0
	
	
	function flyUpAirshipDownTimeTick(dt)
		if(instanceScene.flyactor)then 
		local AdventureId =  stage:getAdventureID()
		local gameobj = instanceScene.stageOBJPos[AdventureId]
		if(gameobj == nil )	then
			gameobj = instanceScene.allActor[AdventureId]  --sceneManager.scene:getSMeshObjectByNoteForAll(tostring(stage:getPoint()));
			instanceScene.stageOBJPos[AdventureId] = gameobj
		end					
		if(gameobj)then
			local up  =  (gameobj:GetPosition() - sceneManager.scene:getSphereTerrainCenter())
			up:normalize()
			--instanceScene.flyactor:SetPosition( gameobj:GetPosition() + up*INSTANCESCENE_STAGE_flyDownAirshipTime*INSTANCESCENE_STAGE_flyDownAirshipSpeed)--LORD.Vector3(0,3,0) 
			instanceScene.flyactor:PlaySkill("run",false,false,1)	
			
			--[[
			local qy = LORD.Quaternion(LORD.Vector3(0,1,0),90/180*math.PI)
			local qx = LORD.Quaternion(LORD.Vector3(1,0,0),-60/180*math.PI)	
			local qz = LORD.Quaternion(LORD.Vector3(0,1,0),0)			
			instanceScene.flyactor:SetOrientation( LORD.Quaternion.Mul(LORD.Quaternion.Mul(qx,qz),qy))	
			
			]]--
			
			 
			local dir =  up:cross(LORD.Vector3(0,0,1))
			local xVec  = up:cross(dir)
			xVec:normalize()
			local yVec  = dir:cross(xVec)
			yVec:normalize()
			local tem = LORD.Quaternion()
			tem:fromAxes(xVec,yVec,dir)
			instanceScene.flyactor:SetOrientation(tem)	
			local pos =  gameobj:GetPosition()--instanceScene.flyactor:GetPosition();	
			instanceScene.dt  = instanceScene.dt  + dt
			pos = pos +  up*(INSTANCESCENE_STAGE_flyDownAirshipTime-instanceScene.dt) * INSTANCESCENE_STAGE_flyDownAirshipSpeed	   --- LORD.Vector3(0,-instanceScene.dt*1,0)
		
			
			instanceScene.flyactor:SetPosition(pos);			
		end
		if(instanceScene.dt >= INSTANCESCENE_STAGE_flyDownAirshipTime)then
			 scheduler.unscheduleGlobal(instanceScene.airshipFlyHandle)
			instanceScene.airshipFlyHandle = nil
			instanceScene.flyactor:PlaySkill("idle",false,false,1)	
			callback()
		end
	end
	
	end	
	
	if(instanceScene.airshipFlyHandle == nil)then
		instanceScene.airshipFlyHandle = scheduler.scheduleGlobal(flyUpAirshipDownTimeTick,0)
	end 
end

 

function instanceScene.closeScene()
	sceneManager.closeScene()
end

instanceScene.touchPos = LORD.Vector2(0, 0);
instanceScene.dragging = false;

function instanceScene.touchHandle(touchType, touchPosition)
	if not sceneManager.scene then
		return 
	end
 	if(instanceScene.multiTouchMove == true)then
		return
	end		
	if(instanceScene.airshipFlyHandle ~= nil)then
		return
	end
	if(instanceScene._startFindPath == true)then
		return
	end
	if("TouchUp" == touchType )then
	
		
			instanceScene.NavigatePoint:touchup()
			if(instanceScene.dragging == true)then
				instanceScene.dragging = false
				return
			end

			local camera = LORD.SceneManager:Instance():getMainCamera();
			
			local ray = LORD.Ray();
			camera:getCameraRay(ray, touchPosition);
			
			--[[
			local object = LORD.QueryObjectManager:Instance():RayQueryObject(ray,0x0002000)
			if(object)then
				 instanceScene.NavigatePoint:editor_startFindPath(object)
				 instanceScene.upDate(false)
			end
			]]--

			
			--local gameObject = sceneManager.scene:rayFindGameObject(ray, bit._or(0X00000020,0X00000800));--
			local userdata = instanceScene.NavigatePoint:rayIntersectsPoint(ray);--   
			if userdata > 0  then
	
				local zones = dataManager.instanceZonesData	
				--local stage = zones:getStageWithAdventureID(AdventureId ,instanceScene.curSelStafeMode)	
				--local AdventureId = zones:serchAdventureIdWithPoint( tonumber(gameObject:getCustomNote()))
				
				local AdventureId = zones:serchAdventureIdWithPoint( userdata)
				local index = instanceScene.findIndexWithAdventureId( AdventureId)
				
	 
				local stage = zones:getStageWithAdventureID(AdventureId,instanceScene.curSelStafeMode)
				 
				if(stage and stage:isEnable() )then
					instanceScene.__stage = nil
					instanceScene.AdventureIndex  = index
					instanceScene.upDate(false )
				else
					
				end		
			end
		
	 
	elseif "TouchDown" == touchType then
		instanceScene.NavigatePoint:touchdown(touchPosition)
		eventManager.dispatchEvent( {name =  global_event.INSTANCEINFOR_HIDE_ON_MOVE} )
	elseif "TouchMove" == touchType then
	
		local layout1 = layoutManager.getUI("modalTip")
		if( layout1:isShow())then
			return 
		end
		instanceScene.dragging = true
		instanceScene.NavigatePoint:touchmove(touchPosition)
	 
	end
end


function instanceScene.onaddGuideWithActor( stage,wName )
	if(stage)then
		local gameobj =   instanceScene.allActor[stage:getAdventureID()]   
		local worldPos = gameobj:GetPosition();
		instanceScene.guid_winName[wName] = gameobj
	end
end


-- multi touch handle
function instanceScene.multiTouchHandle(touchType, touch1, touch2)
	--if( )
	
	--end		
	local layout1 = layoutManager.getUI("modalTip")
	if( layout1:isShow())then
		return 
	end
	
	local touchPoint1 = touch1:getTouchPoint();
	local touchPoint2 = touch2:getTouchPoint();
	
	local prePoint1 = touch1:getPrevPoint();
	local prePoint2 = touch2:getPrevPoint();
	

	if touchType == "TouchDown" then
		
	elseif touchType == "TouchUp" then
		instanceScene.multiTouchMove = false;
	elseif touchType == "TouchCancel" then
		instanceScene.multiTouchMove = false;
		
	elseif touchType == "TouchUpOne" or
		    touchType == "TouchCancelOne" then
		
		instanceScene.multiTouchMove = false;		
			
		--instanceScene.NavigatePoint:touchdown(touchPoint1)
		--eventManager.dispatchEvent( {name =  global_event.INSTANCEINFOR_HIDE_ON_MOVE} )	
			
	elseif touchType == "TouchMove" then
	 
			local camera = LORD.SceneManager:Instance():getMainCamera();
			local vector = touchPoint2 - touchPoint1;
			local preVector = prePoint2 - prePoint1;
			
			local dis = vector:len();
			local preDis = preVector:len();
			local change = preDis - dis;

			 
			 
			instanceScene.multiTouchMove = true;
			
			instanceScene.NavigatePoint:pullHeight( 0.001*change * INSTANCESCENE_STAGE_SCALE_RATE)
	end

end


function instanceScene.onGps()
	local zones = dataManager.instanceZonesData
	local stage = zones:getStageWithAdventureID(instanceScene.NMode[instanceScene.AdventureIndex] ,instanceScene.curSelStafeMode)
	if(stage and  stage:isMain() == false  and  stage:isMissed ())then 
				instanceScene.Chapter   =  nil
				instanceScene.oldAdventureIndex = nil
				instanceScene.BeginPoint  =  nil		
	end

	 instanceScene.upDate(true )	
end	
				