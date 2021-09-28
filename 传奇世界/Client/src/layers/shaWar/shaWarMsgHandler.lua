local removeRoleHoldBtn = function(removeFlg, index)
	if  G_ROLE_MAIN then
		G_ROLE_MAIN:updateHodeInfo(removeFlg, index)
	end
end

local updateRoldHoldBtn = function(objid, flg)
	if objid and objid ~=0 and G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.item_Node then
		local role = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(objid), "SpritePlayer")
		if role then
			role:showShaWarHoldBtn(role, flg)
		end
	end
end

local notifyShaWarStart = function (buff)
	local retTab = g_msgHandlerInst:convertBufferToTable("ShaNotifyAllProtocol", buff)
	local isOpen = retTab.isOpen
	
	G_SHAWAR_DATA.startInfo.isActive = isOpen
	G_SHAWAR_DATA.startInfo.Attack = {}
	print("notifyShaWarStart ..........." .. (isOpen and "true" or "false"))
	DATA_Battle:setRedData("SCZB", G_SHAWAR_DATA.startInfo.isActive, G_SHAWAR_DATA.startInfo.isActive)

	if isOpen then
		if checkLocalKeyTime("ShaWarStart" ..sdkGetOpenId(), 1) then
			liuAudioPlay("sounds/liuVoice/60.mp3",false)
		end
	end

	if G_SHAWAR_DATA.startInfo.isActive then
		local tempFacInfo = retTab.facInfo
		local num = tempFacInfo and tablenums(tempFacInfo) or 0
		for i = 1, num do
			local tempFacId = tempFacInfo[i].facId
			local isDef = tempFacInfo[i].isSha
			if isDef then
				G_SHAWAR_DATA.startInfo.DefenseID = tempFacId				
			end
			table.insert(G_SHAWAR_DATA.startInfo.Attack, tempFacId)
		end
		dump(G_SHAWAR_DATA.startInfo, "G_SHAWAR_DATA.startInfo")
	end

	if G_MAINSCENE and G_MAINSCENE.map_layer then
		if not G_SHAWAR_DATA.startInfo.isActive then
			if G_ROLE_MAIN then
				G_ROLE_MAIN:updateHodeInfo(true)
			end

			for i=1, 4 do
				G_SHAWAR_DATA.holdData[i] = {}
				removeRoleHoldBtn(true, i)
			end
		end
		G_MAINSCENE:changePlayColor()
		G_MAINSCENE:changePlayShaName()
		G_MAINSCENE:createShaWarNotify(G_SHAWAR_DATA.startInfo.isActive)
		G_MAINSCENE.map_layer:setShaWarTransfor()
		G_MAINSCENE.map_layer:ShaWarTransforCheck()
		if G_MAINSCENE.map_layer.setSharWarMapBlock then
			G_MAINSCENE.map_layer:setSharWarMapBlock()
		end 

		if G_MAINSCENE:checkShaWarState() then
			G_MAINSCENE:hideIcons(true)
		elseif (G_SHAWAR_DATA.mapId == G_MAINSCENE.map_layer.mapID or G_MAINSCENE.map_layer.mapID == G_SHAWAR_DATA.mapId1)  then
			G_MAINSCENE:hideIcons(false)
			G_MAINSCENE:hideTaskBtn(false)
		end

		G_MAINSCENE.map_layer:SpecTitleMap(G_MAINSCENE:checkShaWarState())
		
		if G_MAINSCENE:checkShaWarState() then
			G_MAINSCENE:removeAllACtivityIcon()
		end
	end
end

local StartCountWin = function (buff)
	local retTab = g_msgHandlerInst:convertBufferToTable("StartCountProtocol", buff)
	local time = retTab.times
	if G_MAINSCENE and G_MAINSCENE.map_layer.mapID ~= G_SHAWAR_DATA.mapId1 then
		return
	end

	print("......................StartCountWin.................." .. time)

	if not G_SHAWAR_DATA.timeCoutLayer or not tolua.cast(G_SHAWAR_DATA.timeCoutLayer, "cc.Layer") then
		G_SHAWAR_DATA.timeCoutLayer = require("src/layers/shaWar/shaWarLayer").new()
		G_MAINSCENE:addChild(G_SHAWAR_DATA.timeCoutLayer, 400)
		G_SHAWAR_DATA.timeCoutLayer:setPosition(cc.p(0, 0))
	end

	if G_SHAWAR_DATA.timeCoutLayer then
		G_SHAWAR_DATA.timeCoutLayer:update(time)
	end
end

local updateHoldState = function(buff)
	for i=1,4 do
		local tempData = G_SHAWAR_DATA.holdData[i]
		if tempData and tempData.holdID2 then
			updateRoldHoldBtn(tempData.holdID2, false)
		end
	end

	local retTab = g_msgHandlerInst:convertBufferToTable("UpdateHoldStateProtocol", buff)
	local changeData = {}
	local tempInfo = retTab.holderInfo
	for i=1, 4 do
		local holdID = tempInfo[i].holdSID
		local objId = tempInfo[i].holdID
		local name = tempInfo[i].name
		local facId = tempInfo[i].facId
		local facName = ""

		if not G_SHAWAR_DATA.holdData[i]  or (G_SHAWAR_DATA.holdData[i].holdID2 ~= objId and objId ~= 0 )then
			changeData[#changeData + 1] = { holdID2 = objId, holdIndex = i}
		end
		G_SHAWAR_DATA.holdData[i] = {HoldID = holdID, holdID2 = objId, HoldName = name, facName = facName}

		local unionID = {}
		local tempData = tempInfo[i].unionFacId
		local num = tempData and tablenums(tempData) or 0
		unionID[1] = facId
		for i=1,num do
			unionID[i + 1] = tempData[i]
		end
		G_SHAWAR_DATA.holdData[i].facID =  facId--unionID

		if holdID == 0 or holdID ~= userInfo.currRoleStaticId then
			removeRoleHoldBtn(true, i)
		elseif holdID == userInfo.currRoleStaticId then
			removeRoleHoldBtn(false, i)
		end
		updateRoldHoldBtn(objId, true)
	end
	--dump(G_SHAWAR_DATA.holdData)

	if G_MAINSCENE and G_MAINSCENE.map_layer then
		G_MAINSCENE.map_layer:ShaWarTransforCheck()
		G_MAINSCENE.map_layer:changeShaWarTransforCol()
		G_MAINSCENE:setShaWarHoldRoleDir(changeData)
	end
end

local HoldBack = function (buff)
	local retTab = g_msgHandlerInst:convertBufferToTable("DealHoldRetProtocol", buff)
	local HoldId = retTab.holeIndex
	local HoldType = retTab.dealType
	local ret = retTab.dealRet
	if ret then
		--print("............HoldBack............type:" .. HoldType .. "ret:true")
	else
		--print("............HoldBack............type:" .. HoldType .. "ret:false")
	end
	if HoldType == 2 and ret then
		removeRoleHoldBtn(false, HoldId)
	elseif HoldType == 3 and ret then
		removeRoleHoldBtn(true, HoldId)
	end
end

local onRecvDeadData = function(buff)
	log("onRecvDeadData")
	if not G_MAINSCENE:checkShaWarState() then
		return 
	end
	__removeAllLayers()
	local data = {}
	local retTab = g_msgHandlerInst:convertBufferToTable("ShaReliveInfoProtocol", buff)
	data.killerName = retTab.sourname        --杀死你的人的名字 
	data.killerFactionName = retTab.facName --类型杀死你的人的帮会名字
	data.aliveTimeLeft = retTab.remain       --类型，复活剩余时间
	data.needStoneNum = retTab.needStoneNum
	
	local node = require("src/layers/shaWar/ShaWarDeadNode").new(data)
	Manimation:transit(
	{
		ref = G_MAINSCENE,
		node = node,
		curve = "-",
		sp = cc.p(display.cx, display.cy),
		zOrder = 333,
	})
	G_MAINSCENE.map_layer:resetHangup()
	G_MAINSCENE.shaWarDeadLayer = node
end


local shaWarStartTime = function(buff)
	local retTab = g_msgHandlerInst:convertBufferToTable("ShaCountDownProtocol", buff)
	local time = retTab.num
	if G_MAINSCENE and G_MAINSCENE.shaWarTimeStart then
		G_MAINSCENE:shaWarTimeStart(time)
	end
end

local shaWarDefenseIDChange = function(buff)
	local retTab = g_msgHandlerInst:convertBufferToTable("GetShaMasterProtocol", buff)
	local id = retTab.shafactionID
	G_SHAWAR_DATA.startInfo.DefenseID = id

	g_msgHandlerInst:sendNetDataByTableExEx(SHAWAR_CS_GETLEADER, "ShaGetLeaderProtocol", {})
	dump(id, "shaWarDefenseIDChange DefenseID")
	if G_MAINSCENE then
		G_MAINSCENE:changePlayShaName()
	end	
end

local shaWarMykillNum = function(buff)
	local retTab = g_msgHandlerInst:convertBufferToTable("ShaKillNotifyProtocol", buff)
	local num = retTab.num

	if num > 0 and G_MAINSCENE and G_MAINSCENE.shaWarMykillNum and G_MAINSCENE:checkShaWarState() then
		G_MAINSCENE:shaWarMykillNum(num)
	end
end
g_msgHandlerInst:registerMsgHandler(SHAWAR_SC_RELIVEINFO, onRecvDeadData)
g_msgHandlerInst:registerMsgHandler(SHAWAR_SC_DEALHOLD_RET, HoldBack)
g_msgHandlerInst:registerMsgHandler(SHAWAR_SC_UPDATEHOLDSTATE, updateHoldState)
g_msgHandlerInst:registerMsgHandler(SHAWAR_SC_NOTIFYALL, notifyShaWarStart)
g_msgHandlerInst:registerMsgHandler(SHAWAR_SC_STARTCOUNT, StartCountWin)
g_msgHandlerInst:registerMsgHandler(SHAWAR_SC_COUNT_DOWN, shaWarStartTime)
g_msgHandlerInst:registerMsgHandler(SHAWAR_SC_PALACE_CHANGE, shaWarDefenseIDChange)
g_msgHandlerInst:registerMsgHandler(SHAWAR_SC_KILL_NOTIFY, shaWarMykillNum)