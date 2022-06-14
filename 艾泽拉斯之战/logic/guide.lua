Guide = {}

include("guide_logic")

Guide.tipId = nil
Guide.playbattleRc = nil
Guide.serverData = {}
Guide.handUi = nil
Guide.handUiTick = nil	
			

Guide._event = {}

--[[
function Guide.addEvent(event )
    Guide._event[event.name] = event
end
function Guide.RegiserEvent()
	 for k,v in pairs (Guide._event) do 			
		eventManager.addEventLister(k,Guide.onEvent)
	 end
end
function Guide.onEvent(event)
     if(nil == Guide._event[event.name]) then
        echoInfo("Guide:onEvent event.name %s not find",event.name)
     end
     local eventHandler = Guide._event[event.name].eventHandler
     if(eventHandler) then
           eventHandler(event)
     end
end

function Guide.onLogin(event)
		 	
	 
	
	
end	


Guide.addEvent({ name = global_event.GUIDE_ON_LOGIN, eventHandler = Guide.onLogin})
Guide.addEvent({ name = global_event.GUIDE_ON_BATTLE_RECORD_TURN_SELF_MAGIC, eventHandler = Guide.onTurnSelfMagic});
Guide.addEvent({ name = global_event.GUIDE_ON_BATTLE_CLICK_MAGIC_BAR, eventHandler = Guide.onClickMagicBar});
Guide.addEvent({ name = global_event.GUIDE_ON_BATTLE_CLICK_GRID, eventHandler = Guide.onClickGrid});
Guide.addEvent({ name = global_event.GUIDE_ON_BATTLE_RECORD_REPLAY_END, eventHandler = Guide.onRecordReplay});
]]--

function Guide.checkHasEvent(activeeventId,event_name)
	local evetTable = string.split(activeeventId,"|")
	for i = 1,#evetTable do
				if(evetTable[i] == event_name)then
					return true
				end
	end	
	return false
end

function Guide.clearAll()
	--清空指引
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE}) 
	Guide.hideGuidHand()
	FreeGuideUiAll()
end

function Guide.onEvent(event)

	Guide.curGuideEvent = event
	---Guide.buildGuideActiveFlag()
	local event_name = event.name
	print("事件触发 "..event_name)	
	local t = 	dataConfig.configs.guideConfig
		for i,v in ipairs(t) do
			if(Guide.checkHasEvent(v.activeeventId,event_name))then
				
				 local active = Guide.checkGuideActiveFlag(i)
				 if(active)then
					 local f = loadstring(v.activevalue)
					 Guide.curGuideEvent_data = v
					 local res = f(event)
					 if(res )then
						if(v.del )then
							Guide.clearAll()
						end
						print("-------- "..event.name)
						dump(event)
						
						---eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE}) 
						loadstring(v.display)()
						--if(v.modal)then
						--	local ui = getFreeGuideUi(Guide.curGuideEvent_data.order) 
						--	eventManager.dispatchEvent({name = global_event.MODALTIP_SHOW,ui = ui}) 
						--end
						
						
						local openId  = string.split(v.openId, "|");
						Guide.toOPENGuid(openId,v.sync)
						local closeId  = string.split(v.closeId, "|");
						Guide.toCloseGuid(closeId,v.sync)
					else
						print("事件触发-指引条件不满足"..i)	
					end
				 else
					print("未激活或者已经关闭的指引"..i)	
				 end
			end
	end
end	




function Guide.updatePos(wName,worldPos) 
		local ui = engine.GetGUIWindowWithName(wName)
		if(ui == nil)then
			return 
		end
		local initPos = LORD.Vector2(0, 0);
		initPos = LORD.GUISystem:Instance():WorldPostionToScreen(worldPos);		
 
		local x = initPos.x
		local y = initPos.y
		local rect = {}
		rect.left = x - 50
		rect.right = rect.left + 100
		rect.top = y - 80
		rect.bottom = rect.top + 100
	    ui:SetArea(  LORD.UDim(0,rect.left), LORD.UDim(0,rect.top - (rect.bottom - rect.top)*0.5), LORD.UDim(0,rect.right - rect.left ), LORD.UDim(0,rect.bottom - rect.top))
end



function Guide.findIdWithOrder(order)
		local t = 	dataConfig.configs.guideConfig
		for i,v in ipairs(t) do
			 if( tostring(v.order) == tostring(order))then
				return i
			 end
		end
	return 0
end
function Guide.toOPENGuid(openId,sync)
	
	local guides = {}
	for i, v in ipairs (openId)do
		local index = Guide.findIdWithOrder(v)
		Guide.serverData[index] = true
		if(index > 0)then
			table.insert(guides, {id = index, active = true})
		end
	end
	if(sync)then
		sendGuide(guides)
		print(" OPENGuide ")
		dump(guides)
		dump(Guide.serverData)
	end
end	

function Guide.toCloseGuid(closeId,sync)
	local guides = {}
	for i, v in ipairs (closeId)do
		local index = Guide.findIdWithOrder(v)
		Guide.serverData[index] = false
		if(index > 0)then
			table.insert(guides, {id = index, active = false})
		end
	end
	if(sync)then
		sendGuide(guides)
		print(" toCloseGuide ")
		dump(guides)
		dump(Guide.serverData)
	end
end	

function Guide.init()
		Guide.events = Guide.events or {}
		local t = 	dataConfig.configs.guideConfig
		for i,v in ipairs(t) do
			if(v.activeeventId ~= nil and table.find(Guide.events,v.activeeventId) == false )then
			
				local evetTable = string.split(v.activeeventId,"|")
				for i = 1,#evetTable do
					table.insert(Guide.events,evetTable[i])
					eventManager.addEventLister(evetTable[i],Guide.onEvent)	
				end	
	 
			end
		end
		
		for i,v in ipairs(dataConfig.configs.guideConfig) do
			Guide.serverData [i] = false --v.active
		end		
end	




function Guide.setTipId(id)
	Guide.tipId = id
	eventManager.dispatchEvent( {name = global_event.GAME_EVNET_GUIDE_SHOW } )
end


function Guide.onServerData( param)
		local nums = table.nums(param)
		for i = 1, nums	do		
			Guide.serverData[i] =  (param[i] ==1 )		
		end	
		--print("Guide.onServerData")
		--dump(param)
		
end	

--- 检查指引是否激活 
function Guide.buildGuideActiveFlag()
		local t = 	dataConfig.configs.guideConfig
		for i,v in ipairs(t) do
			 Guide.serverData[i] = Guide.serverData[i] or v.active
			 if(Guide.serverData[i] == true)then
				return true
			 end
		end
end
 
function Guide.checkGuideActiveFlag(i)
	 if(Guide.serverData[i] == true)then
		return true
	 end
	return false
end
 
function Guide.startReplayBattle()

	local  unit = '{"force":0,"attackPlan":[{"shipAttr":{"resilience":0,"critical":0,"defence":0,"attack":0},"count":600,"position":{"y":2,"x":0},"id":6,"force":0,"index":0},{"shipAttr":{"resilience":0,"critical":0,"defence":0,"attack":0},"count":600,"position":{"y":1,"x":0},"id":53,"force":0,"index":1},{"shipAttr":{"resilience":0,"critical":0,"defence":0,"attack":0},"count":600,"position":{"y":0,"x":0},"id":55,"force":0,"index":2},{"shipAttr":{"resilience":0,"critical":0,"defence":0,"attack":0},"count":600,"position":{"y":1,"x":2},"id":71,"force":0,"index":3},{"shipAttr":{"resilience":0,"critical":0,"defence":0,"attack":0},"count":600,"position":{"y":0,"x":2},"id":302,"force":0,"index":4},{"shipAttr":{"resilience":0,"critical":0,"defence":0,"attack":0},"count":600,"position":{"y":2,"x":2},"id":54,"force":0,"index":5}],"battleType":0,"guardMagics":[{"id":164,"level":4,"position":1},{"id":165,"level":3,"position":2},{"id":1,"level":1,"position":3}],"isReplay":false,"battleGuid":3,"guardPlan":[{"shipAttr":{"resilience":0,"critical":-9999,"defence":0,"attack":0},"count":1,"position":{"y":1,"x":4},"id":442,"force":0,"index":6}],"attackMagics":[{"id":156,"level":1,"position":1},{"id":72,"level":5,"position":2},{"id":1,"level":1,"position":7}]}'
	local data = json.decode(unit)
	if(data~="null" and data ~= nil)then
		SyncBattleHandler( data.battleType, data.battleGuid, data.isReplay,data.force, data.attackPlan, data.guardPlan, data.attackMagics, data.guardMagics )
	end
	local  k1 = '{"costRatio":100,"maxMP":100,"name":"银色十字军","mp":100,"level":60,"force":0,"icon":1,"intelligence":5000}'
	data = json.decode( k1 )
	 
	if(data~="null" and data ~= nil)then	
    -- 录像当时还没有myths
		SyncKingHandler( data.icon, data.name, 1, data.intelligence, data.force, data.level, data.mp, data.maxMP, data.costRatio )
	end
	local  k2 = '{"costRatio":100,"maxMP":100,"name":"阿尔萨斯","mp":100,"level":100,"force":1,"icon":11,"intelligence":5000}'
	data = json.decode( k2 )
	
	if(data~="null" and data ~= nil)then	
    -- 录像当时还没有myths
		SyncKingHandler( data.icon, data.name, 1, data.intelligence, data.force, data.level, data.mp, data.maxMP, data.costRatio )
	end
	
	local battleValue =  '[{"m_round":0,"m_caster":1,"skill":{"id":240,"sourceGUID":1},"m_type":6}]&&[{"m_round":0,"m_type":8,"m_caster":1,"buff":{"buffInnerCasterIndex":1,"source":2,"operationCode":0,"layer":1,"hp":0,"cd":999,"skillID":240,"target":1,"id":2,"addRet":8,"sourceGUID":1}},{"m_round":0,"m_caster":2,"skill":{"id":18,"sourceGUID":2},"m_type":6},{"m_round":0,"m_caster":3,"skill":{"id":121,"sourceGUID":3},"m_type":6},{"m_round":0,"m_caster":5,"skill":{"id":243,"sourceGUID":4},"m_type":6},{"m_round":0,"m_type":8,"m_caster":5,"buff":{"buffInnerCasterIndex":5,"source":2,"operationCode":0,"layer":1,"hp":0,"cd":999,"skillID":243,"target":5,"id":123,"addRet":8,"sourceGUID":4}},{"m_round":0,"m_type":8,"m_caster":5,"buff":{"buffInnerCasterIndex":5,"source":2,"operationCode":0,"layer":1,"hp":0,"cd":999,"skillID":243,"target":5,"id":124,"addRet":8,"sourceGUID":4}},{"m_round":0,"m_caster":6,"skill":{"id":239,"sourceGUID":5},"m_type":6},{"m_round":0,"m_type":8,"m_caster":6,"buff":{"buffInnerCasterIndex":6,"source":2,"operationCode":0,"layer":1,"hp":0,"cd":999,"skillID":239,"target":6,"id":2,"addRet":8,"sourceGUID":5}},{"magicOver":{"force":0},"m_round":0,"m_caster":-1,"m_type":14}]&&[{"m_round":0,"m_caster":0,"magic":{"id":156,"posy":1,"posx":4,"sourceGUID":6},"m_type":7},{"m_round":0,"m_type":10,"m_caster":0,"damage":{"damageFlag":0,"source":3,"target":6,"id":156,"value":270936,"sourceGUID":6}},{"m_round":0,"m_caster":-1,"attribute":{"attrValue":90,"id":156,"source":3,"attrType":1,"target":0,"targetType":1,"typeIndex":4,"sourceGUID":6},"m_type":12},{"magicOver":{"force":1},"m_round":0,"m_caster":-1,"m_type":14},{"m_round":0,"m_caster":1,"magic":{"id":164,"posy":0,"posx":2,"sourceGUID":7},"m_type":7},{"m_round":0,"m_type":8,"m_caster":1,"buff":{"buffInnerCasterIndex":10001,"source":3,"operationCode":0,"layer":1,"hp":0,"cd":4,"skillID":164,"target":4,"id":68,"addRet":8,"sourceGUID":7}},{"m_round":0,"m_type":8,"m_caster":1,"buff":{"buffInnerCasterIndex":10001,"source":3,"operationCode":0,"layer":1,"hp":0,"cd":4,"skillID":164,"target":4,"id":69,"addRet":8,"sourceGUID":7}},{"m_round":0,"m_caster":-1,"attribute":{"attrValue":90,"id":164,"source":3,"attrType":1,"target":1,"targetType":1,"typeIndex":4,"sourceGUID":7},"m_type":12},{"m_round":0,"m_caster":6,"m_type":0},{"m_round":0,"m_caster":6,"move":{"points":[{"y":1,"x":4},{"y":1,"x":3}],"moveFlag":0,"pointCount":2},"m_type":1},{"m_round":0,"m_type":2,"m_caster":6,"attack":{"target":3,"damageFlag":0,"value":996000}},{"m_round":0,"m_type":5,"m_caster":3,"dead":{"deadFlag":1}},{"m_round":0,"m_caster":6,"skill":{"id":94,"sourceGUID":8},"m_type":6},{"summon":{"source":2,"id":94,"shipCritical":-9999,"shipResilience":0,"shipDefence":0,"y":1,"x":2,"count":70,"target":7,"targetID":381,"shipAttack":0,"sourceGUID":8},"m_round":0,"m_caster":6,"m_type":9},{"m_round":0,"m_caster":7,"skill":{"id":29,"sourceGUID":9},"m_type":6},{"m_round":1,"m_caster":4,"m_type":0},{"m_round":1,"m_type":8,"m_caster":4,"buff":{"buffInnerCasterIndex":0,"source":0,"operationCode":1,"layer":1,"hp":0,"cd":3,"skillID":0,"target":4,"id":68,"addRet":0,"sourceGUID":10}},{"m_round":1,"m_type":8,"m_caster":4,"buff":{"buffInnerCasterIndex":0,"source":0,"operationCode":1,"layer":1,"hp":0,"cd":3,"skillID":0,"target":4,"id":69,"addRet":0,"sourceGUID":12}},{"m_round":2,"m_caster":5,"m_type":0},{"m_round":2,"m_caster":5,"skill":{"id":106,"sourceGUID":14},"m_type":6},{"m_round":2,"m_type":10,"m_caster":5,"damage":{"damageFlag":0,"source":2,"target":6,"id":106,"value":208740,"sourceGUID":14}},{"m_round":2,"m_type":10,"m_caster":5,"damage":{"damageFlag":0,"source":2,"target":7,"id":106,"value":244020,"sourceGUID":14}},{"m_round":2,"m_type":5,"m_caster":7,"dead":{"deadFlag":1}},{"m_round":2,"m_caster":5,"skill":{"id":110,"sourceGUID":15},"m_type":6},{"m_round":2,"m_type":8,"m_caster":5,"buff":{"buffInnerCasterIndex":5,"source":2,"operationCode":0,"layer":1,"hp":0,"cd":1,"skillID":110,"target":5,"id":125,"addRet":8,"sourceGUID":15}},{"m_round":2,"m_caster":6,"skill":{"id":87,"sourceGUID":16},"m_type":6},{"m_round":2,"cure":{"source":6,"target":6,"value":92120,"id":87,"sourceGUID":16},"m_caster":7,"m_type":11},{"m_round":2,"m_type":8,"m_caster":5,"buff":{"buffInnerCasterIndex":0,"source":0,"operationCode":1,"layer":1,"hp":0,"cd":0,"skillID":0,"target":5,"id":125,"addRet":0,"sourceGUID":17}},{"m_round":2,"m_type":8,"m_caster":5,"buff":{"buffInnerCasterIndex":5,"source":0,"operationCode":2,"layer":0,"hp":0,"cd":0,"skillID":0,"target":5,"id":125,"addRet":0,"sourceGUID":18}},{"m_round":2,"m_type":2,"m_caster":5,"attack":{"target":6,"damageFlag":7,"value":417480}},{"m_round":3,"m_caster":2,"m_type":0},{"m_round":3,"m_caster":2,"skill":{"id":80,"sourceGUID":19},"m_type":6},{"m_round":3,"m_type":10,"m_caster":2,"damage":{"damageFlag":0,"source":2,"target":6,"id":80,"value":57084,"sourceGUID":19}},{"m_round":3,"m_type":10,"m_caster":2,"damage":{"damageFlag":0,"source":2,"target":6,"id":80,"value":17125,"sourceGUID":19}},{"m_round":3,"m_type":10,"m_caster":2,"damage":{"damageFlag":0,"source":2,"target":6,"id":80,"value":17125,"sourceGUID":19}},{"m_round":3,"m_type":10,"m_caster":2,"damage":{"damageFlag":0,"source":2,"target":6,"id":80,"value":17125,"sourceGUID":19}},{"m_round":3,"m_type":10,"m_caster":2,"damage":{"damageFlag":7,"source":2,"target":6,"id":80,"value":34250,"sourceGUID":19}},{"m_round":3,"m_type":10,"m_caster":2,"damage":{"damageFlag":0,"source":2,"target":6,"id":80,"value":17125,"sourceGUID":19}},{"m_round":4,"m_caster":0,"m_type":0},{"m_round":4,"m_caster":0,"skill":{"id":68,"sourceGUID":20},"m_type":6},{"m_round":4,"m_type":10,"m_caster":0,"damage":{"damageFlag":0,"source":2,"target":6,"id":68,"value":46860,"sourceGUID":20}},{"m_round":4,"m_caster":6,"attribute":{"attrValue":107,"id":0,"source":2,"attrType":11,"target":6,"targetType":0,"typeIndex":0,"sourceGUID":20},"m_type":12},{"m_round":4,"m_type":8,"m_caster":0,"buff":{"buffInnerCasterIndex":0,"source":2,"operationCode":0,"layer":1,"hp":0,"cd":2,"skillID":68,"target":6,"id":28,"addRet":8,"sourceGUID":20}},{"m_round":5,"m_caster":1,"m_type":0},{"m_round":5,"m_caster":1,"skill":{"id":230,"sourceGUID":21},"m_type":6},{"m_round":5,"m_type":10,"m_caster":1,"damage":{"damageFlag":0,"source":2,"target":6,"id":230,"value":134190,"sourceGUID":21}},{"m_round":5,"m_caster":1,"attribute":{"attrValue":189,"id":1,"source":2,"attrType":10,"target":1,"targetType":0,"typeIndex":0,"sourceGUID":21},"m_type":12},{"m_round":5,"m_type":8,"m_caster":1,"buff":{"buffInnerCasterIndex":1,"source":2,"operationCode":0,"layer":1,"hp":0,"cd":2,"skillID":230,"target":1,"id":114,"addRet":8,"sourceGUID":21}},{"m_round":5,"m_type":8,"m_caster":1,"buff":{"buffInnerCasterIndex":0,"source":0,"operationCode":1,"layer":1,"hp":0,"cd":1,"skillID":0,"target":1,"id":114,"addRet":0,"sourceGUID":22}},{"m_round":6,"m_caster":6,"m_type":0},{"m_round":6,"m_type":8,"m_caster":6,"buff":{"buffInnerCasterIndex":0,"source":0,"operationCode":1,"layer":1,"hp":0,"cd":1,"skillID":0,"target":6,"id":28,"addRet":0,"sourceGUID":24}},{"m_round":6,"m_type":2,"m_caster":6,"attack":{"target":4,"damageFlag":0,"value":102960}},{"m_round":6,"m_type":8,"m_caster":4,"buff":{"buffInnerCasterIndex":10001,"source":0,"operationCode":2,"layer":0,"hp":0,"cd":0,"skillID":0,"target":4,"id":69,"addRet":0,"sourceGUID":13}},{"m_round":6,"m_type":8,"m_caster":4,"buff":{"buffInnerCasterIndex":10001,"source":0,"operationCode":2,"layer":0,"hp":0,"cd":0,"skillID":0,"target":4,"id":68,"addRet":0,"sourceGUID":11}},{"magicOver":{"force":1},"m_round":7,"m_caster":-1,"m_type":14},{"m_round":7,"m_caster":1,"magic":{"id":165,"posy":-1,"posx":-1,"sourceGUID":26},"m_type":7},{"m_round":7,"m_type":10,"m_caster":1,"damage":{"damageFlag":0,"source":3,"target":0,"id":165,"value":1944000,"sourceGUID":26}},{"m_round":7,"m_type":5,"m_caster":0,"dead":{"deadFlag":1}},{"m_round":7,"m_type":10,"m_caster":1,"damage":{"damageFlag":0,"source":3,"target":1,"id":165,"value":1846800,"sourceGUID":26}},{"m_round":7,"m_type":5,"m_caster":1,"dead":{"deadFlag":1}},{"m_round":7,"m_type":10,"m_caster":1,"damage":{"damageFlag":0,"source":3,"target":2,"id":165,"value":1200419,"sourceGUID":26}},{"m_round":7,"m_type":5,"m_caster":2,"dead":{"deadFlag":1}},{"m_round":7,"m_type":10,"m_caster":1,"damage":{"damageFlag":0,"source":3,"target":4,"id":165,"value":1283040,"sourceGUID":26}},{"m_round":7,"m_type":10,"m_caster":1,"damage":{"damageFlag":0,"source":3,"target":5,"id":165,"value":1749600,"sourceGUID":26}},{"m_round":7,"m_type":5,"m_caster":5,"dead":{"deadFlag":1}},{"m_round":7,"m_caster":-1,"attribute":{"attrValue":87,"id":165,"source":3,"attrType":1,"target":1,"targetType":1,"typeIndex":4,"sourceGUID":26},"m_type":12},{"magicOver":{"force":0},"m_round":7,"m_caster":-1,"m_type":14}]&&[{"m_round":7,"m_caster":0,"magic":{"id":72,"posy":1,"posx":3,"sourceGUID":27},"m_type":7},{"m_round":7,"m_type":10,"m_caster":0,"damage":{"damageFlag":0,"source":3,"target":6,"id":72,"value":1544335,"sourceGUID":27}},{"m_round":7,"m_type":5,"m_caster":6,"dead":{"deadFlag":1}},{"m_round":7,"m_caster":6,"attribute":{"attrValue":111,"id":0,"source":-1,"attrType":11,"target":6,"targetType":0,"typeIndex":0,"sourceGUID":25},"m_type":12},{"m_round":7,"m_type":8,"m_caster":6,"buff":{"buffInnerCasterIndex":0,"source":0,"operationCode":2,"layer":0,"hp":0,"cd":0,"skillID":0,"target":6,"id":28,"addRet":0,"sourceGUID":25}},{"m_round":7,"m_caster":-1,"attribute":{"attrValue":80,"id":72,"source":3,"attrType":1,"target":0,"targetType":1,"typeIndex":4,"sourceGUID":27},"m_type":12},{"m_round":7,"m_caster":-1,"m_type":99}]'
	local battleValue = string.split(battleValue, "&&")
	
	Guide.playbattleRc	= {}
	local step = #battleValue
	for i = 1 , step  do	
		local t = json.decode(battleValue[i])
		
		table.insert(Guide.playbattleRc,t)
	end	
	
	
		if( Guide.playbattleRc[1] ~= nil)then
			battlePlayer.rePlayStatus = true
			battlePlayer.guiderePlayStatus = true
			BattleResultHandler(Guide.playbattleRc[1])
		end
	
	eventManager.dispatchEvent({name = global_event.DIALOGUE_SHOW, dialogueType = "", 
						dialogueID = 148,	fun = Guide.nextPlayBattle })
end	


function Guide.nextPlayBattle()
	--清除斩杀等魔法的提示标记
	castMagic.cleanSign()
	--延迟清除点击格子时的光效
	scheduler.performWithDelayGlobal(function ()
		castMagic.cancelClickMoveEffect()
	end, 0.3);
	--
	local layout = layoutManager.getUI("BattleView");
	if layout and layout._view then
		layout._view:SetVisible(true);
	end
	
	local num = 0 
	if(Guide.playbattleRc)then
		num = # Guide.playbattleRc
		table.remove(Guide.playbattleRc,1)
		if ( Guide.playbattleRc[1] ~= nil) then
			battlePlayer.guiderePlayStatus = true
			BattleResultHandler(Guide.playbattleRc[1])
		end
	end
	return num >= 1 
end

function Guide.onTurnSelfMagic()
	return true
end


function Guide.onChangeScene()
	closeGuideUiInScene()
	-- 关闭引导小助手
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE, })
end


function Guide.handleUIWolrdPos(dt)
	local v = enum.HOMELAND_BUILD_TYPE.INSTANCE
	local gameobj = sceneManager.scene:getStaticMeshObjectByNote(homeland.buildNote[v]);
	local worldPos = gameobj:getPosition();
					
	if homeland.buildNotifyHeightOffset[v] then
		worldPos.y = worldPos.y + homeland.buildNotifyHeightOffset[v];
	end
					
	local screenpos = LORD.GUISystem:Instance():WorldPostionToScreen(worldPos);
					
	local uisize = homeland.buildPanels.root[v]:GetPixelSize();
	homeland.buildPanels.root[v]:SetPosition(LORD.UVector2(LORD.UDim(0, screenpos.x-uisize.x/2), LORD.UDim(0, screenpos.y - uisize.y)));

end


if(OPEN_GUIDE == true )then
	Guide.init()
end

--------
function Guide.pauseGame() --暂停游戏
	local nowStates = sceneManager.battlePlayer():isPause()
	if(nowStates == false)then
		sceneManager.battlePlayer():pauseGame(true)
	end
end	

function Guide.continueGame() --继续游戏
	--清楚强制引导
	eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE}) 
	--
	local nowStates = sceneManager.battlePlayer():isPause()
	if(nowStates == true)then
		sceneManager.battlePlayer():pauseGame(false)
	end
end

---local unit = sceneManager.battlePlayer():getCropsByIndex(unitIndex)

---unit:isFriendlyForces() == true -- 是否友军

--local skillInfo = dataConfig.configs.skillConfig[skillId];
--skillInfo.name 


--eventManager.dispatchEvent( {name = global_event.GUIDE_ON_KING_PLAY_MAGIC,arg1= skillInsatnce.caster_self_king , arg2 = skillId })	-- 是否自己的国王 魔法id

--eventManager.dispatchEvent({name = global_event.GUIDE_ON_UNIT_PLAY_SKILL,arg1 = self.index,arg2 = skillId })	 军团id 技能id

function Guide.showGuidHand(x1,y1,x2,y2)  --创建拖动指引
	
	
	local Postion1 =   battlePrepareScene.grid:getWorldPostion(x1 , y1)	
	local Postion2 =   battlePrepareScene.grid:getWorldPostion(x2 , y2)	
	
	local initPos1 = LORD.GUISystem:Instance():WorldPostionToScreen(Postion1);		
	local initPos2 = LORD.GUISystem:Instance():WorldPostionToScreen(Postion2);	
	
	
	
	local x = initPos1.x
	local y = initPos1.y
	
	initPos2.x = initPos2.x-20
	initPos2.y = initPos2.y-20
	 
		
	
	if(Guide.handUi == nil)then
			Guide.handUi = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("guide_", "guide_hand.dlg"); 
			engine.uiRoot:AddChildWindow(Guide.handUi)
			Guide.handUi:SetVisible(true)
			Guide.handUi:SetLevel(1)
			Guide.handUi:SetTouchable(false)
	end
 	if(Guide.handUiTick ~= nil)then
		scheduler.unscheduleGlobal(Guide.handUiTick)
		Guide.handUiTick = nil
	end
	
	local  moveTime = 1.5
	local  stayTime = 0.7
	function GuideHand_moveTimeTick(dt)
		
		Guide.moveTime = Guide.moveTime  or 0
		Guide.moveTime = Guide.moveTime + dt
		if  Guide.moveTime > moveTime - stayTime then
			--donothing
		else
			local  x = initPos1.x + ( initPos2.x - initPos1.x)* Guide.moveTime/(moveTime-stayTime)
			local y = initPos1.y + ( initPos2.y - initPos1.y)* Guide.moveTime/(moveTime-stayTime)
			Guide.handUi:SetPosition(LORD.UVector2(LORD.UDim(0,x), LORD.UDim(0,y)));
		end
		if(Guide.moveTime >= moveTime )then
			Guide.moveTime = 0
		end
	end	
	
	if(Guide.handUiTick == nil)then
		Guide.handUiTick = scheduler.scheduleGlobal(GuideHand_moveTimeTick,0)
	end	
	
	
end

function Guide.hideGuidHand()   --关闭拖动指引
	if(Guide.handUi ~= nil)then
		engine.DestroyWindow(Guide.handUi);
		Guide.handUi =  nil
	end
  
	if(Guide.handUiTick ~= nil)then
		scheduler.unscheduleGlobal(Guide.handUiTick)
		Guide.handUiTick = nil
	end
 

end