local ContainerMapPreviewer={}

local var = {}
local tile_step = {[0]={0,-1},[1]={1,-1},[2]={1,0},[3]={1,1},[4]={0,1},[5]={-1,1},[6]={-1,0},[7]={-1,-1}}
local head_key ={"new_main_ui_head.png","head_fzs","head_mfs","head_ffs","head_mds","head_fds"}

local ignoreNpc = {
	["v002"] = {"传送员","每日泡点","暗殿使者","玛雅神殿","BOSS之家","转生神殿","第一男战士","第一女战士","第一男法师","第一女法师","第一男道士","第一女道士"}
}

local stretchMaps = {
	00102, 00103
}

local function isTransferMember(npcName)
	if string.find(npcName,"传送") then
		return true;
	end
end

--bossNpc名字带等级信息
local function isBossNpc(npcName)
	if string.find(npcName,"Lv:") then
		return true;
	end
end

function ContainerMapPreviewer.initView()
	var = {
		xmlPanel,
		mainRole,
		mapScroll,
		touchEndPos,
		changeRoad,
		origHeight,
		origWidth,
		imgMap,
		mapPos,
		selfImg,
		touchBeganTime,
		touchBeganPos,
		roadMarks,
		npcMarks,
		mapConMarks,--地图连接点
		target={},
		mapList={},
		mapListObject={},
		currentTabIndex=1,
		currentMapIndex=0,

		mStretch = false,
	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerMapPreviewer.uif")

	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerMapPreviewer.handlePanelData)
			
		var.mapScroll = var.xmlPanel:getWidgetByName("mapScroll")
			:setClippingEnabled(true)
		local lvContentSize = var.mapScroll:getContentSize()

		local panelBg = var.xmlPanel:getWidgetByName("panel_minimap_bg")
		panelBg:loadTexture("ContainerMapPreviewer_bg.png",ccui.TextureResType.plistType)
		
		-- minimap_bg
		--GameUtilSenior.asyncload(var.xmlPanel, "panel_minimap_bg", "ui/image/minimap_bg.png")
		--local shape4 = display.newRect(
		--	cc.rect(0, 0, lvContentSize.width, lvContentSize.height), 
		--	{
		--		fillColor = cc.c4f(0,0,0,1), borderColor = cc.c4f(0,0,0,1), 
		--		borderWidth = 0
		--	}
		--):addTo(var.mapScroll)

		var.imgMap = ccui.ImageView:create()
			:align(display.CENTER, lvContentSize.width * 0.5, lvContentSize.height * 0.5)
			:addTo(var.mapScroll)
			:setTouchEnabled(true)

		var.npcMarks = ccui.Widget:create()
			:addTo(var.imgMap, 10)

		var.mapConMarks = ccui.Widget:create()
			:addTo(var.imgMap, 10)

		var.roadMarks = ccui.Widget:create()
			:addTo(var.imgMap, 10)

		local pixesmain = GameCharacter.updateAttr()
		local job = pixesmain:NetAttr(GameConst.net_job)
		local gender = pixesmain:NetAttr(GameConst.net_gender)
		local id = (job-100) * 2 + gender - 199
		var.selfImg = ccui.ImageView:create("img_player_icon.png", ccui.TextureResType.plistType):addTo(var.imgMap, 20):align(display.CENTER)
		-- ccui.ImageView:create(head_key[id],ccui.TextureResType.plistType):addTo(var.selfImg):align(display.CENTER, 25, 26):scale(0.48)

		cc.EventProxy.new(GameSocket, var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_MAP_ENTER, ContainerMapPreviewer.handleMapEnter)
		ContainerMapPreviewer.initBtns()
		
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerMapPreviewer.pushTabButtons)
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
		var.xmlPanel:getWidgetByName("box_tab"):setItemMargin(0)
		var.xmlPanel:getWidgetByName("box_tab"):setFontSize(25)
		var.xmlPanel:getWidgetByName("box_tab"):setTabColor(GameBaseLogic.getColor(0xebb86d),GameBaseLogic.getColor(0xebb86d))
		var.xmlPanel:getWidgetByName("box_tab"):setTabRes("ContainerMapPreviewer_left_tab.png","ContainerMapPreviewer_left_tab_sel.png")
		var.xmlPanel:getWidgetByName("box_tab"):hideTab({2,3,4})

		
		var.xmlPanel:getWidgetByName("enter_map_btn"):addClickEventListener(function( sender )
			if var.currentMapIndex==0 then
				return
			end
			GameSocket:PushLuaTable("gui.ContainerMapPreviewer.handlePanelData",GameUtilSenior.encode({actionid = "enterMap",tab=var.currentTabIndex,map=var.currentMapIndex}))
		end)
		
		return var.xmlPanel
	end
end



function ContainerMapPreviewer.updateMapList(item)
	table.insert(var.mapListObject,item)
	local itemData = var.mapList[var.currentTabIndex][item.tag]
	
	item:getWidgetByName("map_name"):setText(var.mapList[var.currentTabIndex][item.tag].name)
	item:getWidgetByName("map_level"):setText(var.mapList[var.currentTabIndex][item.tag].req)
	
	local filepath = "map/minlist/"..itemData.pic..".png"
	asyncload_callback(filepath, item:getWidgetByName("map_img"), function(filepath, texture)
		item:getWidgetByName("map_img"):loadTexture(filepath)
	end)
	item:setTouchEnabled(true)
	GUIFocusPoint.addUIPoint(item , ContainerMapPreviewer.prsMapBtnItem)
end

function ContainerMapPreviewer.prsMapBtnItem(item)
	for i=1,#var.mapListObject,1 do
		var.mapListObject[i]:getWidgetByName("container_bg"):loadTexture("ContainerMapPreviewer_maplist_container_bg.png",ccui.TextureResType.plistType)
	end
	local itemData = var.mapList[var.currentTabIndex][item.tag]
	if itemData.desc~=nil then
		GameUtilSenior.print_table(itemData.desc)
		var.xmlPanel:getWidgetByName("descList"):setVisible(true)
		var.xmlPanel:getWidgetByName("dropList"):setVisible(false)
		ContainerMapPreviewer.updateList( var.xmlPanel:getWidgetByName("descList"),itemData.desc)
	else
		var.xmlPanel:getWidgetByName("descList"):setVisible(false)
		var.xmlPanel:getWidgetByName("dropList"):setVisible(true)
		var.xmlPanel:getWidgetByName("dropList"):reloadData(#itemData.items,function(subitem)
			local param={parent=subitem:getWidgetByName("iconEquip"), typeId=itemData.items[subitem.tag]}
			GUIItem.getItem(param)
		end)
	end
	item:getWidgetByName("container_bg"):loadTexture("ContainerMapPreviewer_maplist_container_bg_sel.png",ccui.TextureResType.plistType)
	
	var.currentMapIndex = item.tag
	
	var.xmlPanel:getWidgetByName("enter_map_btn"):loadTextureNormal("ContainerMapPreviewer_mapmove.png",ccui.TextureResType.plistType)
	var.xmlPanel:getWidgetByName("enter_map_btn"):loadTexturePressed("ContainerMapPreviewer_mapmove.png",ccui.TextureResType.plistType)
end

function ContainerMapPreviewer.pushTabButtons(sender)
	var.currentMapIndex = 0
	for i=1,4 do
		var.xmlPanel:getWidgetByName("container_"..i):setVisible(false)
	end
	local tag = sender:getTag()
	var.currentTabIndex=tag
	if tag==2 then
		var.xmlPanel:getWidgetByName("descList_title"):setText("描述")
	elseif tag==3 or tag==4 then
		var.xmlPanel:getWidgetByName("descList_title"):setText("极品掉落")
	end
	if tag == 1 then
		var.xmlPanel:getWidgetByName("panel_minimap_bg"):loadTexture("ContainerMapPreviewer_bg.png",ccui.TextureResType.plistType)
	else
		tag=2
		
		for i=1,#var.mapListObject,1 do
			var.mapListObject[i]:getWidgetByName("container_bg"):loadTexture("ContainerMapPreviewer_maplist_container_bg.png",ccui.TextureResType.plistType)
		end
		var.mapListObject={}
		var.xmlPanel:getWidgetByName("enter_map_btn"):loadTextureNormal("ContainerMapPreviewer_mapmove_grey.png",ccui.TextureResType.plistType)
		var.xmlPanel:getWidgetByName("enter_map_btn"):loadTexturePressed("ContainerMapPreviewer_mapmove_grey.png",ccui.TextureResType.plistType)
		var.xmlPanel:getWidgetByName("panel_minimap_bg"):loadTexture("ContainerMapPreviewer_maplist_bg.png",ccui.TextureResType.plistType)
		var.xmlPanel:getWidgetByName("descList"):setVisible(false)
		var.xmlPanel:getWidgetByName("dropList"):setVisible(false)
		var.xmlPanel:getWidgetByName("mapList"):reloadData(#var.mapList[var.currentTabIndex],ContainerMapPreviewer.updateMapList)
	end
	var.xmlPanel:getWidgetByName("container_"..tag):setVisible(true)
end


function ContainerMapPreviewer.handleMapEnter()
	var.npcMarks:removeAllChildren()
	var.mapConMarks:removeAllChildren()
	local minimap = GameSocket.mNetMap
	if minimap then
		local filepath = string.format("map/preview/%05d.jpg",minimap.mMiniMapID)
		asyncload_callback(filepath, var.imgMap, function(filepath, texture)
			var.imgMap:loadTexture(filepath)
			var.origWidth = var.imgMap:getContentSize().width

		end)
	end
end

function ContainerMapPreviewer.onPanelOpen()
	local minimap = GameSocket.mNetMap
	if minimap then 
		local filepath = string.format("map/preview/%05d.jpg",minimap.mMiniMapID)
		if table.indexof(stretchMaps, minimap.mMiniMapID) then
			var.mStretch = true
		else
			var.mStretch = false
		end
		asyncload_callback(filepath, var.imgMap, function(filepath, texture)
			var.imgMap:loadTexture(filepath)
			var.origWidth = var.imgMap:getContentSize().width
			ContainerMapPreviewer.initPanel()
			if GameBaseLogic.aimPos then
				var.touchEndPos = ContainerMapPreviewer.mapPosToMini(GameBaseLogic.aimPos)
				var.changeRoad = true
			end
		end)
	end
	GameSocket:PushLuaTable("gui.ContainerMapPreviewer.handlePanelData",GameUtilSenior.encode({actionid = "getMessage"}))
end


function ContainerMapPreviewer.handlePanelData(event)
	if event.type == "ContainerMapPreviewer" then
		local data = GameUtilSenior.decode(event.data)
		if data.cmd =="getMessage" then
			var.mapList = data.mapList
		end
	end
end

function ContainerMapPreviewer.initPanel()
	local pixesmain = GameCharacter.updateAttr()

	local minimap = GameSocket.mNetMap
	var.xmlPanel:getWidgetByName("map_name"):setString(minimap.mName)
	local lvContentSize = var.mapScroll:getContentSize()
	var.origHeight = var.imgMap:getContentSize().height
	-- local mHeight = var.imgMap:getContentSize().height
	-- local mScale = lvContentSize.height / var.origHeight
	-- print(mScale, lvContentSize.height, var.origHeight)
	-- var.imgMap:scale(mScale)
	-- var.mapScroll:setInnerContainerSize(cc.size(lvContentSize.width, mHeight * mScale))
	
	local selfPos = ContainerMapPreviewer.mapPosToMini(cc.p(pixesmain:PAttr(GameConst.AVATAR_X), pixesmain:PAttr(GameConst.AVATAR_Y)))
	local bgSize = var.imgMap:getContentSize()
	-- var.mapScroll:scrollToPercentVertical(100 - selfPos.y * 100 / bgSize.height, 0, false)
	var.selfImg:setPosition(selfPos):scale(var.origHeight/lvContentSize.height):show()
	if GameCharacter.mDir then
		var.selfImg:setRotation(45*GameCharacter.mDir-90)
	end
		
	var.pos_current = var.xmlPanel:getWidgetByName("pos_current")
	var.imgMap:addTouchEventListener(function (pSender,touch_type)
		if touch_type == ccui.TouchEventType.began then

			var.touchBeganTime = GameBaseLogic.getTime()
			var.touchBeganPos = pSender:getTouchBeganPosition()

		elseif touch_type == ccui.TouchEventType.ended then
			if GameBaseLogic.getTime() - var.touchBeganTime < 125 and cc.pDistanceSQ(var.touchBeganPos, pSender:getTouchEndPosition()) < 3*3 then
				var.touchEndPos = pSender:convertToNodeSpace(pSender:getTouchEndPosition()) 
				local mapPos = ContainerMapPreviewer.miniPosToMap(var.touchEndPos)
				if mapPos then 
					ContainerMapPreviewer.startAutoMoveToPos(mapPos.x, mapPos.y)
				end
			end
		end
	end)

	ContainerMapPreviewer.drawMiniNpc()
	ContainerMapPreviewer.drawMapConn()
	local moveStep = 0
	local function runSelfMark(dx)
		local heroPos = ContainerMapPreviewer.mapPosToMini(cc.p(pixesmain:PAttr(GameConst.AVATAR_X),pixesmain:PAttr(GameConst.AVATAR_Y)))
		if GameUtilSenior.isObjectExist(var.selfImg) then
			if var.touchEndPos and var.changeRoad then
				local posTemp = ContainerMapPreviewer.miniPosToMap(var.touchEndPos)
				var.roadMarks:removeAllChildren()
				if posTemp then 
					var.mapPos = ContainerMapPreviewer.miniPosToMap(var.touchEndPos)
					local mList = cc.AstarPath:getInstance():getStepList()
					local mPosRoad = {}
					if #mList > 0 then
						if GameUtilSenior.isObjectExist(var.roadMarks) then
							var.roadMarks:removeAllChildren()
						end
						var.changeRoad = false
						mPosRoad[0] = cc.p(pixesmain:PAttr(GameConst.AVATAR_X),pixesmain:PAttr(GameConst.AVATAR_Y))
						local childTag = 0
						for i=1,#mList do
							local dir = mList[#mList-i+1]
							mPosRoad[i] = cc.p(mPosRoad[i-1].x+ tile_step[dir][1],mPosRoad[i-1].y+ tile_step[dir][2])
							local interval = 3
							if var.mStretch then
								interval = 1
							end

							if (not var.mStretch and i%interval == 1) or (var.mStretch) then
								local mPos = ContainerMapPreviewer.mapPosToMini(cc.p(mPosRoad[i].x,mPosRoad[i].y))
								local anchor = display.CENTER
								local texture = "img_trackPoint.png"
								var.target={GameSocket.mNetMap.mMapID,mPosRoad[i].x,mPosRoad[i].y}
								if i > #mList - interval then
									anchor = display.CENTER_BOTTOM
									texture = "img_destination.png"
								end
								local image = ccui.ImageView:create(texture, ccui.TextureResType.plistType)
									:align(anchor, mPos.x, mPos.y)
									:addTo(var.roadMarks, 10, childTag)
									:scale(var.origHeight/lvContentSize.height)
									:setAnchorPoint(cc.p(0.5,0.5))
									childTag = childTag + 1
								if texture~="img_destination.png" then
									image:setRotation(45*dir-90)
								end
							end
						end
					end
				end
				moveStep = 0
			end
			if var.selfImg:getPositionX() ~= math.floor(heroPos.x) or var.selfImg:getPositionY() ~= math.floor(heroPos.y) then
				moveStep = moveStep + 1
				var.selfImg:pos(math.floor(heroPos.x), math.floor(heroPos.y))

				local mDir = pixesmain:NetAttr(GameConst.net_dir)
				if mDir then
					var.selfImg:setRotation(45*mDir-90)
				end

				var.pos_current:setString("X:"..pixesmain:PAttr(GameConst.AVATAR_X).." Y:"..pixesmain:PAttr(GameConst.AVATAR_Y))

				local isNeed2Remove = false
				local children = var.roadMarks:getChildren()
				for i,v in ipairs(children) do
					local posX,posY = v:getPosition()

					if math.abs(heroPos.x-posX) + math.abs(heroPos.y-posY)< 10 then
						if v:getTag()*2>=moveStep and v:getTag()<=moveStep then
							isNeed2Remove = i
							break
						end
					end
				end
				if isNeed2Remove and isNeed2Remove < 5 then
					for i,v in ipairs(children) do
						if i <= isNeed2Remove then
							var.roadMarks:removeChildByTag(v:getTag())
						else
							break
						end
					end
				end
			end

			if var.roadMarks:getChildrenCount() > 0 then--到达目的地删除所有的轨迹点
				local selfmappos = ContainerMapPreviewer.miniPosToMap(heroPos)
				if selfmappos then
					if math.abs(var.mapPos.x-selfmappos.x)<=1 and math.abs(var.mapPos.y-selfmappos.y)<=1 then
						var.roadMarks:removeAllChildren()
					end
				end
			end
		end
	end

	var.xmlPanel:runAction(
		cca.loop(
			cca.seq({
				cca.cb(runSelfMark),
				cca.delay(0.05)
			})
		)
	)
end

-------------------绘制NPC(含BOSS怪物，但是GS已隐藏BOSS，在PlayMap.cpp的AddObject方法中)-------------------
function ContainerMapPreviewer.drawMiniNpc()
	--列表绘制
	--按钮调用函数
	local function pushBagButton(pSender)
		print("aaa",pSender.mMapID,pSender.posX,pSender.posY)
		GameCharacter._targetNPCName = pSender.mNpcName
		GameCharacter.startAutoMoveToMap(pSender.mMapID,pSender.posX,pSender.posY,1)
	end
	var.xmlPanel:getWidgetByName("listNPC"):reloadData(#GameSocket.mMiniNpc,function (subItem)	
		subItem:getWidgetByName("object_name"):setText(GameSocket.mMiniNpc[subItem.tag].mNpcName)
		subItem.targetPos = cc.p(GameSocket.mMiniNpc[subItem.tag].mX, GameSocket.mMiniNpc[subItem.tag].mY)
		subItem:setTouchEnabled(true)
		subItem:addClickEventListener(ContainerMapPreviewer.touchTarget)
	end)
	--地图上绘制
	local lvContentSize = var.mapScroll:getContentSize()
	local scale = var.origHeight / lvContentSize.height
	var.npcMarks:removeAllChildren()
	for i,v in ipairs(GameSocket.mMiniNpc) do
		if v.mMapID == GameSocket.mNetMap.mMapID then
			if not ignoreNpc[v.mMapID] or (ignoreNpc[v.mMapID] and not table.indexof(ignoreNpc[v.mMapID], v.mNpcName)) then
				local mPos = ContainerMapPreviewer.mapPosToMini(cc.p(v.mX,v.mY))
				local path = isTransferMember(v.mNpcName) and "img_npc_transfer.png" or "img_npc_normal.png";
				local pNpcDot = ccui.Button:create(path, "", "", ccui.TextureResType.plistType)
					:align(display.CENTER, mPos.x, mPos.y)
					:addTo(var.npcMarks)
					:scale(scale)
				-- if GameSocket.mMiniNpc[i].mDirectFlyID and GameSocket.mMiniNpc[i].mDirectFlyID > 0 then
				-- 	pNpcDot.flyID = GameSocket.mMiniNpc[i].mDirectFlyID--v.mDirectFlyID
				-- else
					pNpcDot.targetPos = cc.p(v.mX,v.mY)
				-- end
				-- if v.mNum <= 0 then
				-- 	local filepath = "image/icon/mon_tombstone.png"
				-- 	asyncload_callback(filepath, pNpcDot, function(filepath, texture)
				-- 		pNpcDot:loadTextures(filepath,"","",ccui.TextureResType.localType)
				-- 	end)
				-- end
				pNpcDot:addClickEventListener(ContainerMapPreviewer.touchTarget)

				local dotSize = pNpcDot:getContentSize()
				
				local npcName = ContainerMapPreviewer.handleNpcName(v.mNpcName)
				-- local laststr = string.sub(v.mNpcName,string.len(v.mNpcName),string.len(v.mNpcName))
				-- if tonumber(laststr) and tonumber(laststr) > 0 then
				-- 	npcName = string.sub(v.mNpcName,1,string.len(v.mNpcName)-1)
				-- end

				local npc_name = ccui.Text:create()
					:align(display.BOTTOM_CENTER, dotSize.width * 0.5, dotSize.height + 5)
					:addTo(pNpcDot)
					:setName("name")
					-- :setString(npcName..(v.mNum <= 0 and "(死亡)" or ""))
					:setString(npcName)
					:setFontSize(14)
					:setFontName(FONT_NAME)
					:setColor(cc.c3b(255,255,255))
					:setTouchEnabled(true)
				npc_name.targetPos = cc.p(v.mX,v.mY)
				npc_name:addClickEventListener(ContainerMapPreviewer.touchTarget)
			end
		end
	end
end

-------------------绘制地图连接点-------------------
function ContainerMapPreviewer.drawMapConn()
	local lvContentSize = var.mapScroll:getContentSize()
	local scale = var.origHeight / lvContentSize.height
	var.mapConMarks:removeAllChildren()
	local mapCon=GameSocket.mMiniMapConn[GameSocket.mNetMap.mMapID]
	if mapCon then
		for i=1,#mapCon do
			local nmc = GameSocket.mMapConn[mapCon[i]]
			local mPos = ContainerMapPreviewer.mapPosToMini(cc.p(nmc.mFromX,nmc.mFromY))
			local pConnDot = ccui.Button:create("img_boss_icon.png","","",ccui.TextureResType.plistType)
				:align(display.CENTER, mPos.x, mPos.y)
				:addTo(var.mapConMarks)
				:scale(scale)
				:setTouchEnabled(true)
			pConnDot.targetPos = cc.p(nmc.mFromX, nmc.mFromY) 

			pConnDot:addClickEventListener(ContainerMapPreviewer.touchTarget)

			local dotSize = pConnDot:getContentSize()

			local name_mapCon = ccui.Text:create()
				:align(display.CENTER, dotSize.width * 0.5, dotSize.height + 10)
				:addTo(pConnDot)
				:setString(nmc.mDesMapName)
				:setFontSize(18)
				:setFontName(FONT_NAME)
				:setColor(cc.c3b(206,209,0))
		end
	end
end

-- 世界坐标转小地图坐标
function ContainerMapPreviewer.mapPosToMini(mpos)
	local NetMap = cc.NetClient:getInstance():getMap()
	if not NetMap then return cc.p(0,0) end
	local mapWidth = NetMap:LogicWidth()
	local mapHeight = NetMap:LogicHeight()
	return cc.p(var.origWidth / mapWidth * mpos.x, var.origHeight - var.origHeight / mapHeight * mpos.y)
end

-- 小地图坐标转世界坐标
function ContainerMapPreviewer.miniPosToMap(mpos)
	local NetMap = cc.NetClient:getInstance():getMap()
	local mapWidth = NetMap:LogicWidth()
	local mapHeight = NetMap:LogicHeight()
	return cc.p(mpos.x * mapWidth / var.origWidth, mapHeight - mpos.y * mapHeight / var.origHeight)	
end

function ContainerMapPreviewer.touchTarget(pSender)
	if pSender.flyID and pSender.flyID > 0 then
		GameSocket:DirectFly(pSender.flyID)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str="panel_minimap"})
	elseif pSender.targetPos then
		if GameCharacter._mainAvatar then
			var.touchEndPos = ContainerMapPreviewer.mapPosToMini(pSender.targetPos)
			ContainerMapPreviewer.startAutoMoveToPos(pSender.targetPos.x,pSender.targetPos.y,2)
		end
	end
end

function ContainerMapPreviewer.updateListNPC(item)

	local nmmn = GameSocket.mMiniNpc[item.tag]

	local lbl_NPC = item:getWidgetByName("lbl_NPC"):setTouchEnabled(true)
		
	local strName = ContainerMapPreviewer.handleNpcName(nmmn.mNpcName)
	local laststr = string.sub(strName,string.len(strName),string.len(strName))
	if tonumber(laststr) and tonumber(laststr) > 0 then
		strName = string.sub(strName,1,string.len(strName)-1)
	end
	local o1, o2 = string.find(strName,"】")
	
	if o2 and o2 > 0 then strName = string.sub(strName, o2 + 1) end
	local o3 = string.find(strName,"%(")
	if o3 and o3 > 0 then strName = string.sub(strName, 1, o3 - 1) end
	lbl_NPC:setString(strName)
	lbl_NPC.targetPos = cc.p(nmmn.mX, nmmn.mY)
	lbl_NPC:addClickEventListener(ContainerMapPreviewer.touchTarget)

	local lbl_NPCTransmit = item:getWidgetByName("lbl_NPCTransmit"):setTouchEnabled(true)
	lbl_NPCTransmit:addClickEventListener(ContainerMapPreviewer.touchTarget)
	if nmmn.mDirectFlyID and nmmn.mDirectFlyID > 0 then
		lbl_NPCTransmit.flyID = nmmn.mDirectFlyID
		lbl_NPCTransmit:setString(GameConst.str_transfer)
	else
		lbl_NPCTransmit.flyID = nil
		lbl_NPCTransmit.targetPos = cc.p(nmmn.mX, nmmn.mY)
		lbl_NPCTransmit:setString(GameConst.str_goto)
	end

end

function ContainerMapPreviewer.updateTransmit(item)

	local mapCon=GameSocket.mMiniMapConn[GameSocket.mNetMap.mMapID]

	local nmc = GameSocket.mMapConn[mapCon[item.tag]]

	local lbl_WayPoint = item:getWidgetByName("lbl_WayPoint")
		:setTouchEnabled(true)
		:setString(nmc.mDesMapName)
	lbl_WayPoint.targetPos = cc.p(nmc.mFromX,nmc.mFromY)
	lbl_WayPoint:addClickEventListener(ContainerMapPreviewer.touchTarget)

	local lbl_Transfer = item:getWidgetByName("lbl_Transfer")
		:setTouchEnabled(true)
		:setString(GameConst.str_goto)
	lbl_Transfer.targetPos = cc.p(nmc.mFromX,nmc.mFromY)
	lbl_Transfer:addClickEventListener(ContainerMapPreviewer.touchTarget)
end

function ContainerMapPreviewer.startAutoMoveToPos(tx, ty, flag)
	var.changeRoad = true
	GameCharacter._moveToNearAttack = false
	GameCharacter.stopAutoFight() --取消自动挂机
	GameCharacter._targetNPCName = ""
	if flag then
		GameCharacter._mainAvatar:startAutoMoveToPos(tx, ty, flag)
	else
		GameCharacter._mainAvatar:startAutoMoveToPos(tx, ty)
	end
	-- --飞鞋相关
	-- if GameSocket.mNetMap then
	-- 	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_FLY_PARAM, mapid = GameSocket.mNetMap.mMapID, x = tx, y = ty, visible = true})
	-- end
end

function ContainerMapPreviewer.handleNpcName(name)
	return string.gsub(name,"(.-)(%d-)(%(Lv:%d*%))","%1")
end

function ContainerMapPreviewer.onPanelClose()
	var.touchBeganTime = 0
	var.selfImg:hide()
	var.xmlPanel:stopAllActions()
	var.roadMarks:removeAllChildren()
end

--local btnArrs = {"btnHeCheng","btnHuiShou","btnChuanSong","btnSuiJi"}
local btnArrs = {}
function ContainerMapPreviewer.initBtns()
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btnHeCheng" then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_depot"})
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_minimap"})
			-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "menu_compose",mParam={type=1}})
			-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_minimap",})
			--local mParam = {
			--	name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "是否传送到合成使者？",
			--	btnConfirm = "是", btnCancel = "否",
			--	confirmCallBack = function ()
			--		GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "flyHeCheng",}))
			--		-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "menu_bag"})
			--		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_minimap",})
			--	end
			--}
			GameSocket:dispatchEvent(mParam)
		elseif senderName=="btnHuiShou" then
			-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_minimap",})
			local mParam = {
				name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "是否传送到回收使者？",
				btnConfirm = "是", btnCancel = "否",
				confirmCallBack = function ()
					GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "flyHuiShou",}))
					-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "menu_bag"})
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "panel_minimap",})
				end
			}
			GameSocket:dispatchEvent(mParam)
		elseif senderName=="btnChuanSong" then
			-- if #var.target == 3 then
			-- 	GameSocket:PushLuaTable("gui.ContainerVip.onPanelData",GameUtilSenior.encode({actionid = "fly",param = var.target}))
			-- 	var.roadMarks:removeAllChildren()
			-- 	var.target = {}
			-- end
			if not GameSocket:BagUseItemByType(32010001) then
				GameSocket:alertLocalMsg("背包没有传送石头，无法使用该功能！", "alert")
			end
			 -- 传送石
		elseif senderName=="btnSuiJi" then
			GameSocket:PushLuaTable("gui.ContainerBag.handlePanelData",GameUtilSenior.encode({actionid = "useRandomStone"}))
		end
	end
	for i=1,#btnArrs do
		local btn = var.xmlPanel:getWidgetByName(btnArrs[i]):setPressedActionEnabled(true)
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end


function ContainerMapPreviewer.updateList( list,strs )
	local t = {}
	if GameUtilSenior.isString(strs) then
		table.insert(t,strs)
	elseif GameUtilSenior.isTable(strs) then
		t = strs
	end
	list:removeAllItems()
	for i,v in ipairs(t) do
		local richLabel = GUIRichLabel.new({size = cc.size(list:getContentSize().width, 40), space=10,name = "hintMsg"..i})
		richLabel:setRichLabel(v,"panel_npctalk")
		list:pushBackCustomItem(richLabel)
	end
end



return ContainerMapPreviewer
