local DetailMapNode = class("DetailMapNode", function() return cc.Node:create() end )

local DetailListViewType = {}
DetailListViewType.NpcType = 1
DetailListViewType.MonsterType = 2
DetailMap = {}
local path = "res/mapui/"

function DetailMapNode:ctor(parent,mapId)
	self:createNode(mapId)
	self.parent = parent
	local msgids = {TEAM_SC_GETTEAMPOSINFO,MANORWAR_SC_GETOWNFACTION}
	require("src/MsgHandler").new(self,msgids)
	-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_CHANGEPOSMAPID, "ii", G_ROLE_MAIN.obj_id, mapId)
	g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGEPOSMAPID, "TeamChangePosMapIdProtocol", {["curMapId"] = mapId})

	G_DETAIL_MAP_NODE = self
	self:registerScriptHandler(function(event)
									if event == "enter" then
									elseif event == "exit" then
										G_DETAIL_MAP_NODE = nil
									end
								end)

	 if mapId == 2100 then
	 	local dartScheduler = function()
 			local m_teamId = MRoleStruct:getAttr(PLAYER_TEAMID)
			if G_MAINSCENE and G_MAINSCENE.map_layer and m_teamId and m_teamId > 0 then
				if G_MAINSCENE.dart_objid then
					local dart_obj = tolua.cast(G_MAINSCENE.map_layer.item_Node:getChildByTag(G_MAINSCENE.dart_objid),"SpriteMonster")
					if dart_obj then
						G_MAINSCENE.dart_pos = dart_obj:getTilePoint()
					elseif not G_MAINSCENE.dart_pos then
						g_msgHandlerInst:sendNetDataByTableExEx(DART_CS_POSITION, "DartPositionProtocol", {} )
					end
				elseif not G_MAINSCENE.dart_pos then
					g_msgHandlerInst:sendNetDataByTableExEx(DART_CS_POSITION, "DartPositionProtocol", {} )
				end
				if G_MAINSCENE.dart_pos and G_DETAIL_MAP_NODE then
					self:dart_goTo(G_MAINSCENE.dart_pos)
					G_MAINSCENE.dart_pos = nil
				end
			end
	 	end
	 	schedule(self, dartScheduler , 1)
	 elseif G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.mapID and G_MAINSCENE.task_escort_pos  then
	 	local escortScheduler = function()
			G_MAINSCENE.map_layer:escortAsk()
			if G_MAINSCENE.task_escort_pos and G_DETAIL_MAP_NODE then
				self:escortGoto( G_MAINSCENE.task_escort_pos )
				G_MAINSCENE.task_escort_pos = nil
			end
		end
		schedule( self, escortScheduler , 1)
	 else
	 	if self.dartNode and self.dartNode.refreshLayer then
			removeFromParent(self.dartNode.refreshLayer)
			self.dartNode.refreshLayer = nil
		end
	 	if self.escortNode and self.escortNode.refreshLayer then
			removeFromParent(self.escortNode.refreshLayer)
			self.escortNode.refreshLayer = nil
		end 
	 end
end

function DetailMapNode:setDetailMapInfo(info)
	DetailMap = info or {}
end

function DetailMapNode:getDetailMapInfo(info)
	return DetailMap
end

function DetailMapNode:createNode(mapId)
	self:removeAllChildren()
	self.pathNode = nil
	self.roleNode = nil
	self.bannerNode = nil
	self.teamData = nil
	self.fbMonsterData = nil

	local addSprite = createSprite
	local addLabel = createLabel
	
	self.getString = game.getStrByKey
	self.mapId = mapId

	self.scheduler = cc.Director:getInstance():getScheduler()


	local goToWorldMap = function() 
	   	self.parent:goToWorldMap()
	end

	-- local bg = addSprite(self, "res/common/bg/bg17.png", cc.p(5, 0), cc.p(0.0, 0.5))-------
	local bg =  createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(22, 3.5),
        cc.size(602, 501),
        4,
        cc.p(0,0.5)
    )
	self.bg = bg

	createScale9Sprite(bg,"res/common/scalable/scale15.png",cc.p(301,480),cc.size(600,38),nil,nil,nil,3)
	-- createSprite(self,"res/map/smallmap/frame.png",cc.p(301,230),nil)
	-- 地图名称
	local mapInf = getConfigItemByKey("MapInfo", "q_map_id", mapId) 
	local mapname = require("src/layers/buff/ChangeLineLayer"):getMapName(nil,mapId) 
	createLabel(bg, mapname, cc.p(301, 480), cc.p(0.5, 0.5), 24, true, 4, nil, MColor.yellow)
	-- local factionBg = addSprite(bg, path.."infobg1.png", cc.p(772, 443), cc.p(0.5, 0.5))------------
	local factionBg =  createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(752, 446),
        cc.size(288, 111),
        4,
        cc.p(0.5,0.5)
    )
	self.factionBg = factionBg

	--本地图产出
	--createLabel(factionBg, game.getStrByKey("map_produce"), cc.p(20, 50), cc.p(0, 0), 20, nil, nil, nil, MColor.yellow_gray)
	--createLabel(factionBg, getConfigItemByKey("MapInfo", "q_map_id", mapId, "dtcc") or "", cc.p(20, 20), cc.p(0, 0), 20, true, nil, nil, MColor.yellow_gray)	
	local richText = require("src/RichText").new(factionBg, getCenterPos(factionBg) , cc.size(265 ,30) , cc.p(0.5, 0.5), 30, 20, MColor.lable_yellow)
  	richText:addText(getConfigItemByKey("MapInfo", "q_map_id", mapId, "dtcc") or "", MColor.lable_yellow, true)
  	richText:format()

	local switchFun = function(id, node)
		log("switchFun")
		if node == self.npcBtn then
			log("switchFun 1")
			self.npcBtnOn = true
			self.monsterBtnOn = false
		elseif node == self.monsterBtn then
			log("switchFun 2")
			self.npcBtnOn = false
			self.monsterBtnOn = true
		end
		
		if self.npcBtnOn then
			self.npcBtn:setImages("res/component/TabControl/".."2.png")
		else
			self.npcBtn:setImages("res/component/TabControl/".."1.png")
		end

		if self.monsterBtnOn then
			self.monsterBtn:setImages("res/component/TabControl/".."2.png")
		else
			self.monsterBtn:setImages("res/component/TabControl/".."1.png")
		end
		
		self.npcListView:setVisible(self.npcBtnOn)
		self.npcListView.touched = self.npcBtnOn
		self.monsterListView:setVisible(self.monsterBtnOn)
		self.monsterListView.touched = self.monsterBtnOn

		self.npcBtn:removeChildByTag(10)
		self.monsterBtn:removeChildByTag(10)
		createLabel(self.npcBtn, self.getString("map_detail_npc"), cc.p(65, 26), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.green, 10)
		createLabel(self.monsterBtn, self.getString("map_detail_monster"), cc.p(65, 26), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.red, 10)
	end	

	--self.npcBtn = createMenuItem(bg, "res/component/TabControl/".."2.png", cc.p(710, 315), switchFun)
	--self.npcBtn:registerScriptTapHandler(switchFun)
	--createLabel(self.npcBtn, self.getString("map_detail_npc"), cc.p(65, 26), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.green, 10)
	self.npcBtnOn = true
	--self.monsterBtn = createMenuItem(bg, "res/component/TabControl/".."1.png", cc.p(850, 315), switchFun)
	--self.monsterBtn:registerScriptTapHandler(switchFun)
	--createLabel(self.monsterBtn, self.getString("map_detail_monster"), cc.p(65, 26), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.red, 10)
	self.monsterBtnOn = false
	log("mapId="..mapId)
	self.npcDataTab = {}
	self.monsterDataTab = {}
	self.hotDataTab = {}

	local cfgTab = getConfigItemByKey("NPC","q_id") 
	for k,v in pairs(cfgTab) do
		if v.q_map == mapId and not v.q_collect and ( k < 10456 or k > 10460 ) and ( k < 10469 or k > 10473 ) then
			local record = {}
			record.id = v.q_id
			record.name = v.q_name
			record.x = v.q_x
			record.y = v.q_y
			--log("insert npc record")
			table.insert(self.npcDataTab, #self.npcDataTab + 1, record)
		end
	end

	cfgTab = getConfigItemByKey("monsterUpdate","q_id") 
	for i,v in pairs(cfgTab) do
		if v.q_mapid == mapId then
			-- if v.q_id >= 1600 and  v.q_id <= 1602 then

			-- elseif i >= 2 then
			-- 	if v.q_id >= 335 and  v.q_id <= 367 then

			-- 	elseif not cfgTab[i-1] or v.q_monster_model ~= cfgTab[i-1].q_monster_model then
			-- 		log("11111111111111111")
			-- 		--这两个字段没配表明策划不需要该点位显示在小地图上
			-- 		local monsterCfg = getConfigItemByKey("monster", "q_id", v.q_monster_model)
			-- 		if cfgTab[i].q_mapid >= 7000 and cfgTab[i].q_mapid <= 7003 and monsterCfg.q_type ~= 3 then
			-- 			log("22222222222222222222")
			-- 		elseif v.q_monster_model and v.F5 and cfgTab.q_mapid ~= 7000 and cfgTab.q_mapid ~= 7001 and cfgTab.q_mapid ~= 7002 and cfgTab.q_mapid ~= 7003 then
			-- 			log("33333333333333333333")
			-- 			local record = {}
			-- 			record.id = v.q_id
			-- 			record.name = monsterCfg.q_name --string.gsub(v.F5, "%d", "")
			-- 			record.x = v.q_center_x
			-- 			record.y = v.q_center_y
			-- 			--print("v.q_monster_model = "..v.q_monster_model)
			-- 			--dump(getConfigItemByKey("monster", "q_id", v.q_monster_model, "q_lvl"))
			-- 			record.lv = getConfigItemByKey("monster", "q_id", v.q_monster_model, "q_lvl") 
			-- 			record.q_monster_model = v.q_monster_model
			-- 			--log("insert monster record")
			-- 			table.insert(self.monsterDataTab, #self.monsterDataTab + 1, record)
			-- 		end
			-- 	end
			-- else
			--dump(v)
				if v and v.q_show == 1 then
					if v.q_monster_model then
						local record = {}
						record.id = v.q_id
						record.name = getConfigItemByKey("monster", "q_id", v.q_monster_model, "q_name")
						record.x = v.q_center_x
						record.y = v.q_center_y
						record.lv = getConfigItemByKey("monster", "q_id", v.q_monster_model, "q_lvl")
						if record.name and record.lv then
							--record.name = record.name.."("..game.getStrByKey("level").."："..record.lv..")"
							record.name = record.name.."(Lv."..record.lv..")"
						end
						record.q_monster_model = v.q_monster_model
						table.insert(self.monsterDataTab, #self.monsterDataTab + 1, record)
					end
				end
			-- end
		end
	end
	--过滤相同数据
	local function filterRepeatData( tempData , key , sortKey , isUp )
		local nameTab = {}
		for i = 1 , #tempData do
			local key = tempData[i][key .."" ]
			if nameTab[key] then
				nameTab[key][ #nameTab[key] + 1 ] = tempData[i]
			else
				nameTab[key] = { tempData[i] }
			end
		end
		local newMonster = {}
		for key , v in pairs( nameTab ) do

			local function sortFun( a , b )
				local _b = a[sortKey] < b[sortKey]
				if not isUp then
					_b = a[sortKey] > b[sortKey]
				end
				return _b
			end
			table.sort( v , sortFun )

			newMonster[ #newMonster + 1 ] = v[1]
		end
		return newMonster
	end

	self.monsterDataTab = filterRepeatData( self.monsterDataTab , "q_monster_model" , "id" , true )
	table.sort(self.monsterDataTab, function(a, b) return a.id < b.id end)

	cfgTab = getConfigItemByKey("HotAreaDB","q_id") 
	for k,v in pairs(cfgTab) do
		if v.q_mapid == mapId then
			local record = {}
			record.id = v.q_id
			record.name = v.F8
			record.x = v.q_x
			record.y = v.q_y
			record.lv_min = getConfigItemByKey("MapInfo", "q_map_id", v.q_tar_mapid, "q_map_min_level")
			record.lv_max = "级以上"--getConfigItemByKey("MapInfo", "q_map_id", v.q_tar_mapid, "q_map_max_level")
			record.show_side = v.side or 1
			--log("insert monster record")
			table.insert(self.hotDataTab, #self.hotDataTab + 1, record)
		end
	end
	--dump(self.hotDataTab)
	
	-- createSprite(bg, "res/mapui/infobg2.png", cc.p(772, 180), cc.p(0.5, 0.5))---------------
	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(752, 192),
        cc.size(288, 384),
        4,
        cc.p(0.5,0.5)
    )
    createScale9Sprite(bg,"res/common/scalable/scale15.png",cc.p(752,363),cc.size(286,38))
	createLabel(bg, self.getString("auto_find_way"), cc.p(752, 365), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.yellow)

	for k,v in ipairs(self.monsterDataTab)do
		table.insert(self.npcDataTab, #self.npcDataTab + 1, v)
	end
	self.npcListView = require("src/layers/map/DetailListView").new(bg, cc.size(310, 335), cc.p(615, 6), DetailListViewType.NpcType, self.npcDataTab)
	self.npcListView:reloadData()
	self.npcListView:setVisible(self.npcBtnOn)
	self.npcListView.touched = self.npcBtnOn
	--[[
	self.monsterListView = require("src/layers/map/DetailListView").new(bg, cc.size(300, 260), cc.p(640, 10), DetailListViewType.MonsterType, self.monsterDataTab)
	self.monsterListView:reloadData()
	self.monsterListView:setVisible(self.monsterBtnOn)
	self.monsterListView.touched = self.monsterBtnOn
	]]
	self:createMap(mapId)
	self:createMapInfo()

	if G_MAINSCENE.mapId == mapId then
		self.path = G_MAINSCENE.map_layer:getRolePath()
		if #self.path > 1 then
			self.pathEnd = self.path[#self.path]
		end
		--dump(self.path)
	end

	--dump(G_MAINSCENE.mapId)
	if tonumber(getConfigItemByKey("MapInfo", "q_map_id", G_MAINSCENE.mapId, "xianzhi")) ~= 1 then
		createMenuItem(bg, path.."16.png", cc.p(50, 30), goToWorldMap, 99)
	end

	--SwallowTouches(self)
    if self.mapNode ~= nil then
	    local  listenner = cc.EventListenerTouchOneByOne:create()
        listenner:setSwallowTouches(false)
        listenner:registerScriptHandler(function(touch, event)
       		    return true
            end,cc.Handler.EVENT_TOUCH_BEGAN )
        listenner:registerScriptHandler(function(touch, event)
 
       		    local touchPos = self.bg:convertTouchToNodeSpace(touch)
                cclog("onTouchEnded: %0.2f, %0.2f", touchPos.x, touchPos.y)
                if cc.rectContainsPoint(self.mapNode:getBoundingBox(), touchPos) then
        		    log("boundingBox")
        		    local posEnd = self:convertMapPos(cc.p(self.mapNode:convertTouchToNodeSpace(touch)))
				    log("posEnd.x"..posEnd.x)
				    log("posEnd.y"..posEnd.y)
				    --DetailMap.touch_pos = posEnd
        		    self:goTo(posEnd)
        		    return 
        	    end
            
            end,cc.Handler.EVENT_TOUCH_ENDED )
        local eventDispatcher = self.mapNode:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listenner,self.mapNode)
    end

	schedule(self,function() self:updateMapInfo() end,0.1)
	--self:setScale(0.01)
   -- self:runAction(cc.ScaleTo:create(0.2, 1))

    if G_MAINSCENE.mapId == 2100 and self.mapId == 2100 then 
    	self.dartNode = nil
    end
end

function DetailMapNode:convertMapPos(src_pos) 
	--log("convertMapPos")
	--log("src_pos.x"..src_pos.x)
	--log("src_pos.y"..src_pos.y)
	local _pos = cc.p((src_pos.x/self.mapNode:getContentSize().width * self.blockLayerSize.width), 
			((self.mapNode:getContentSize().height - src_pos.y)/self.mapNode:getContentSize().height * self.blockLayerSize.height))
	return cc.p(math.floor(_pos.x),math.floor(_pos.y))
end

function DetailMapNode:createMap(mapId)

	-- local mapTmxPath = "res/map/xinshoucun.tmx"
	-- local mapPath = "res/map/xinshoucun/"
	-- local map = cc.TMXTiledMap:create(mapTmxPath)
	-- self.mapNode = cc.Node:create()

	-- local blockLayer = map:getLayer("blockLayer")
	-- local blockLayerSize = blockLayer:getLayerSize()
	-- local tileSize = blockLayer:getMapTileSize()
	-- self.tileSize = tileSize
	-- local nodeSizeWidth = 0
	-- local nodeSizeHeight = 0
	-- local nodeSizeHeightTemp = 0
	-- local nodeSizeMaxWidth = 0
	-- local nodeSizeMaxHeight = 0
	-- for i=0, blockLayerSize.width, 40 do
	-- 	nodeSizeMaxWidth = 0
	-- 	nodeSizeMaxHeight = 0
	-- 	for j=0, blockLayerSize.height, 40 do
	-- 		local image = string.format("%sx%d_%d.jpg", mapPath, i/40, j/40)
	-- 		local texture = cc.Director:getInstance():getTextureCache():addImage(image)
 --    		local imageSpr = cc.Sprite:createWithTexture(texture)
 --   			--local imageSpr = cc.Sprite:create(image)
	-- 		if imageSpr then
	-- 			log("add imageSpr")
	-- 			imageSpr:setAnchorPoint(cc.p(0,1));
	-- 			imageSpr:setPosition(cc.p(i * tileSize.width, (blockLayerSize.height - j) * tileSize.height));
	-- 			self.mapNode:addChild(imageSpr, 10);				
	-- 		end
	-- 		cc.Director:getInstance():getTextureCache():removeTexture(texture)

	-- 		if imageSpr:getContentSize().width > nodeSizeMaxWidth then
	-- 			nodeSizeMaxWidth = imageSpr:getContentSize().width
	-- 		end

	-- 		nodeSizeMaxHeight = nodeSizeMaxHeight + imageSpr:getContentSize().height
	-- 	end
	-- 	nodeSizeWidth = nodeSizeWidth + nodeSizeMaxWidth
	-- 	if nodeSizeHeight < nodeSizeMaxHeight then
	-- 		nodeSizeHeight = nodeSizeMaxHeight
	-- 	end
	-- end

	-- log("nodeSizeWidth = "..nodeSizeWidth)
	-- log("nodeSizeHeight = "..nodeSizeHeight)

	-- local visibleWidth = 570
	-- local visibleHeight = 480

	-- if nodeSizeWidth/nodeSizeHeight > visibleWidth/visibleHeight then
	-- 	self.mapScale = visibleWidth / nodeSizeWidth
	-- else
	-- 	self.mapScale = visibleHeight / nodeSizeHeight
	-- end

	-- log("self.mapScale"..self.mapScale)
	-- self.bg:addChild(self.mapNode, 1)
	-- self.mapNode:setContentSize(cc.size(nodeSizeWidth, nodeSizeHeight))
	-- self.mapNode:setAnchorPoint(cc.p(0.5, 0.5))
	-- self.mapNode:setPosition(cc.p(307, 330))
	-- self.mapNode:setScale(self.mapScale)

	
	-- self.mapNode = cc.Node:create()

	-- local blockLayer = map:getLayer("blockLayer")
	-- local blockLayerSize = blockLayer:getLayerSize()
	-- local tileSize = blockLayer:getMapTileSize()
	-- self.tileSize = tileSize

	log("DetailMapLayer:createMap")
	local mapName = getConfigItemByKey("MapInfo", "q_map_id", mapId, "q_mapresid") 
	self.mapScale = getConfigItemByKey("MapInfo", "q_map_id", mapId, "dtsfbl") 

	--local map = cc.TMXTiledMap:create("res/map/"..mapName..".tmx")
	--local blockLayer = map:getLayer("blockLayer")
	local block_str = cc.FileUtils:getInstance():getStringFromFile("res/map/block/"..mapName..".tmx")
	local sub_str_tab = stringsplit(block_str,"\n")
	print(sub_str_tab[1],sub_str_tab[2])
	self.blockLayerSize = cc.size(tonumber(sub_str_tab[1]),tonumber(sub_str_tab[2]))
	self.tileSize = cc.size(48,32)
	
	log("mapName"..mapName)
	if mapName then
		log("create sprite")
		self.mapNode = createSprite(self.bg, "res/map/smallmap/"..mapName..".jpg", cc.p(301, 230), cc.p(0.5, 0.5))
		if mapName == "lxd" then
			-- self.mapNode:setScaleY(0.9)
		end
	end

	-- local function onTouchEvent(eventType, x, y)
 --        if eventType == "began" then
 --            return true
 --        elseif  eventType == "moved" then

 --        else
 --        	log("onTouchEvent"..eventType)
 --        	log("x"..x)
 --        	log("y"..y)
 --        	if self.mapNode:boundingBox():containsPoint(cc.p(x, y)) then
 --        		log("boundingBox")
 --        		local paths = G_MAINSCENE.map_layer:getPathByPos(r_tile_pos,cc.p(px,py))
	-- 			for k,v in pairs(paths)do
	-- 				print("paths:k:"..k)
	-- 				print("paths:v:"..v.x.."//"..v.y)
	-- 				self.path = paths
	-- 			end
 --        	end
 --        end
 --    end
	-- self:registerScriptTouchHandler(onTouchEvent)
end

function DetailMapNode:createMapInfo()
	self.mapInfoNode = cc.Node:create()
	self.bg:addChild(self.mapInfoNode, 2)
	createSprite(self.bg,"res/mapui/frame.png",cc.p(301,230),cc.p(0.5,0.5))
	if self.mapNode then
		self.mapInfoNode:setPosition(cc.p(self.mapNode:getPositionX() - self.mapNode:getContentSize().width/2, 
			self.mapNode:getPositionY() - self.mapNode:getContentSize().height/2))--307-self.mapNode:getContentSize().width/2, 297-self.mapNode:getContentSize().height/2
	end
	local lab_ttf = {}
    lab_ttf.fontFilePath = g_font_path
    lab_ttf.fontSize = 16
    lab_ttf.outlineSize = 1
    self.item_batchlabel = MirBatchDrawLabel:createWithTTF(lab_ttf)
	self.item_batchlabel:setPosition(cc.p(0, 0))
	self.mapInfoNode:addChild(self.item_batchlabel,4)
	--log("mapInfoNode x = "..307-self.mapNode:getContentSize().width/2)
	--log("mapInfoNode y = "..330-self.mapNode:getContentSize().height/2)
	self:addMapInfo()
end

function DetailMapNode:addMapInfo()
	self:clearMapInfo()
	self:addPath()
	self:addNpcInfo()
	self:addRole()
	self:addBanner()
	self:addTeamInfo()
	self:addFbMonsterInfo()
	self:addHotInfo()
	--self:addMonsterInfo()	
end

function DetailMapNode:updateMapInfo()
	self:addPath()
	self:addRole()
end

function DetailMapNode:clearMapInfo()
	if self.mapNpcNode then
		self.mapInfoNode:removeChild(self.mapNpcNode)
	end
	if self.mapMonsterNode then
		self.mapInfoNode:removeChild(self.mapMonsterNode)
	end
	if self.mapHotNode then
		self.mapInfoNode:removeChild(self.mapHotNode)
	end
	if self.mapRoleNode then
		self.mapInfoNode:removeChild(self.roleNode)
	end
	if self.pathNode then
		self.pathNode:removeChild(self.roleNode)
	end
	if self.mapBannerNode then
		self.mapInfoNode:removeChild(self.mapBannerNode)
	end
	if self.item_batchlabel then
		self.item_batchlabel:removeAllChildren()
		self.path_end_str = nil
		self.role_pos_str = nil
	end
end

function DetailMapNode:addNpcInfo()
	log("DetailMapLayer:addNpcInfo")
	self.mapNpcNode = cc.Node:create()
	self.mapInfoNode:addChild(self.mapNpcNode)
	--dump(DATA_Mission)
	if DATA_Mission then
		local curTask = DATA_Mission:getLastTaskData()
		local taskNpcId,taskNpcState
		if curTask then
			taskNpcId,taskNpcState = curTask.q_endnpc , curTask.finished 
		end

		if taskNpcId and taskNpcState then
			for k,v in pairs(self.npcDataTab) do
				local spr = cc.Sprite:create(path.."31-1.png")
				spr:setAnchorPoint(0.5, 0.5)
				self.mapNpcNode:addChild(spr)
				spr:setTag(v.id)
				spr:setPosition(cc.p(v.x*self.tileSize.width*self.mapScale, self.mapNode:getContentSize().height - v.y*self.tileSize.height*self.mapScale))
				if taskNpcId == v.id then
					if taskNpcState == 2 or  taskNpcState == 4 then
						createSprite(spr, path.."32-1.png", cc.p(spr:getContentSize().width/2, spr:getContentSize().height), cc.p(0.5, 0), nil, 0.5)
					elseif taskNpcState == 3 then
						createSprite(spr, path.."32.png", cc.p(spr:getContentSize().width/2, spr:getContentSize().height), cc.p(0.5, 0), nil, 0.5)
					end
				end 
			end
		end
	end
end

function DetailMapNode:addMonsterInfo()
	log("DetailMapLayer:addMonsterInfo")
	self.mapMonsterNode = cc.Node:create()
	self.mapInfoNode:addChild(self.mapMonsterNode)

	for k,v in pairs(self.monsterDataTab) do
		local spr = cc.Sprite:create(path.."31.png")
		spr:setAnchorPoint(0.5, 0.5)
		self.mapMonsterNode:addChild(spr)
		spr:setTag(v.id)
		local m_pos = cc.p(v.x*self.tileSize.width*self.mapScale, self.mapNode:getContentSize().height - v.y*self.tileSize.height*self.mapScale)
		spr:setPosition(m_pos)
		-- log("x = "..v.x*self.tileSize.width*self.mapScale)
		-- log("y = "..v.y*self.tileSize.height*self.mapScale)

		local MRoleStruct = require("src/layers/role/RoleStruct")
		local roleLv = MRoleStruct:getAttr(ROLE_LEVEL)
		local color = MColor.white

		local nameStr = v.name
		if v.lv then
			if v.lv-roleLv  < 0 then
				color = MColor.gray
			elseif v.lv-roleLv < 5 then
				color = MColor.green
			else
				color = MColor.red
			end
			nameStr = nameStr.." ("..v.lv..")"
		end

		createBatchLabel(self.item_batchlabel, nameStr, cc.p(m_pos.x, m_pos.y+15), cc.p(0.5, 0), 16, true, nil, nil, color)
	end
end

function DetailMapNode:addHotInfo()
	log("DetailMapLayer:addHotInfo")
	self.mapHotNode = cc.Node:create()
	self.mapInfoNode:addChild(self.mapHotNode)

	for k,v in pairs(self.hotDataTab) do
		local spr = cc.Sprite:create(path.."30.png")
		spr:setAnchorPoint(0.5, 0.5)
		self.mapHotNode:addChild(spr)
		spr:setTag(v.id)
		local m_pos = cc.p(v.x*self.tileSize.width*self.mapScale, self.mapNode:getContentSize().height - v.y*self.tileSize.height*self.mapScale)
		spr:setPosition(m_pos)
		-- log("x = "..v.x*self.tileSize.width*self.mapScale)
		-- log("y = "..v.y*self.tileSize.height*self.mapScale) 

		local MRoleStruct = require("src/layers/role/RoleStruct")
		local roleLv = MRoleStruct:getAttr(ROLE_LEVEL)
		local color
		local spr_size = spr:getContentSize()
		local show_poss = {cc.p(m_pos.x+5,m_pos.y+15),cc.p(m_pos.x+5,m_pos.y-15),cc.p(m_pos.x-spr_size.width/2,m_pos.y),cc.p(m_pos.x+spr_size.width/2,m_pos.y)}
		local show_anp = {cc.p(0.5,0.0),cc.p(0.5,1.0),cc.p(1.0,0.5),cc.p(0.0,0.5)}
		if v.lv_min then
			if roleLv >= v.lv_min then
				color = MColor.green
			else
				color = MColor.red
			end
			createBatchLabel(self.item_batchlabel, v.name.."\n".."("..v.lv_min..v.lv_max..")",show_poss[v.show_side],show_anp[v.show_side], 16, true, nil, nil, color)
		else
			spr:setColor(MColor.green)
			createBatchLabel(self.item_batchlabel, v.name, show_poss[v.show_side],show_anp[v.show_side], 16, true, nil, nil, MColor.green)
		end
	end
end

function DetailMapNode:addTeamInfo()
	log("DetailMapLayer:addTeamInfo")
	self.mapTeamNode = cc.Node:create()
	self.mapInfoNode:addChild(self.mapTeamNode)
end

function DetailMapNode:addFbMonsterInfo()
	log("DetailMapLayer:addFbMonsterInfo")
	self.mapfbMonsterNode = cc.Node:create()
	self.mapInfoNode:addChild(self.mapfbMonsterNode)
end

function DetailMapNode:updateTeamInfo()
	log("DetailMapLayer:updateTeamInfo")
	if self.mapTeamNode then
		self.mapTeamNode:removeAllChildren()
	end

	for k,v in pairs(self.teamData) do
		local spr = cc.Sprite:create(path.."29-1.png")
		spr:setAnchorPoint(0.5, 0.5)
		self.mapTeamNode:addChild(spr)
		--spr:setTag(v.id)
		--spr:setScale(0.5)
		local m_pos = cc.p(v.x*self.tileSize.width*self.mapScale, self.mapNode:getContentSize().height - v.y*self.tileSize.height*self.mapScale + 15)
		spr:setPosition(m_pos)
		--spr:setPosition(cc.p(0, 0))
		-- log("x = "..v.x*self.tileSize.width*self.mapScale)
		-- log("y = "..v.y*self.tileSize.height*self.mapScale)
		createLabel(self.mapTeamNode, v.name, cc.p(m_pos.x, m_pos.y+spr:getContentSize().height/2), cc.p(0.5, 0), 16, true, nil, nil, color)
		--createBatchLabel(self.mapTeamNode, v.name, cc.p(m_pos.x, m_pos.y+spr:getContentSize().height/2), cc.p(0.5, 0), 16, true, nil, nil, color)
	end
end

function DetailMapNode:updateFbMonsterInfo()
	log("DetailMapLayer:updateMonsterInfo")
	if self.mapfbMonsterNode then
		self.mapfbMonsterNode:removeAllChildren()
	end

	for k,v in pairs(self.fbMonsterData) do
		local spr = cc.Sprite:create(path.."31.png")
		spr:setColor(MColor.red)
		spr:setAnchorPoint(0.5, 0.5)
		self.mapfbMonsterNode:addChild(spr)
		--spr:setTag(v.id)
		--spr:setScale(0.5)
		local m_pos = cc.p(v.x*self.tileSize.width*self.mapScale, self.mapNode:getContentSize().height - v.y*self.tileSize.height*self.mapScale)
		spr:setPosition(m_pos)
		--spr:setPosition(cc.p(0, 0))
		-- log("x = "..v.x*self.tileSize.width*self.mapScale)
		-- log("y = "..v.y*self.tileSize.height*self.mapScale)
		createBatchLabel(self.item_batchlabel, v.name, cc.p(m_pos.x, m_pos.y+spr:getContentSize().height/2), cc.p(0.5, 0), 16, true, nil, nil, color)
	end
end

-- function DetailMapNode:updateRole()
-- 	if self.roleNode then
-- 		local spr = self.roleNode:getChildByTag(G_ROLE_MAIN.obj_id)
-- 		if spr then
-- 			local x,y = G_ROLE_MAIN:getPosition()
-- 			spr:setPosition(cc.p(x*self.mapScale, y*self.mapScale))
-- 		end
-- 	end
-- end

function DetailMapNode:addRole()
	if self.roleNode == nil then
		self.roleNode = cc.Node:create()
		self.mapInfoNode:addChild(self.roleNode,100)
	else
		self.roleNode:removeAllChildren()
	end

	if G_MAINSCENE and G_MAINSCENE.mapId == self.mapId then
		local spr = cc.Sprite:create(path.."29.png")
		spr:setAnchorPoint(0.5, 0.5)
		self.roleNode:addChild(spr)
		spr:setTag(G_ROLE_MAIN.obj_id)
		local x,y = G_ROLE_MAIN:getPosition()
		local m_pos = cc.p(x*self.mapScale, y*self.mapScale + 15)
		spr:setPosition(m_pos)
		--spr:setScale(0.5)
		if G_MAINSCENE.map_layer then
			local tilePos = G_MAINSCENE.map_layer:space2Tile(cc.p(x, y))
			if self.role_pos_str then
				self.role_pos_str:setString("("..tilePos.x..","..tilePos.y..")")
				self.role_pos_str:setPosition(cc.p(m_pos.x, m_pos.y+spr:getContentSize().height/2))
			else
				self.role_pos_str = createBatchLabel(self.item_batchlabel, "("..tilePos.x..","..tilePos.y..")", cc.p(m_pos.x, m_pos.y+spr:getContentSize().height/2), cc.p(0.5, 0), 16, true, nil, nil, MColor.white)
			end
		end
	end
end

function DetailMapNode:fixPos(pos)
	pos.x = pos.x - pos.x%1
	pos.y = pos.y - pos.y%1
	return pos
end

-- function DetailMapNode:updatePath()
-- 	if self.pathEnd then
-- 		local x,y = G_ROLE_MAIN:getPosition()
-- 		x = x*self.mapScale
-- 		y = y*self.mapScale
-- 		local posStart = cc.p((x/self.mapNode:getContentSize().width * self.blockLayerSize.width), 
-- 			((self.mapNode:getContentSize().height - y)/self.mapNode:getContentSize().height * self.blockLayerSize.height))
-- 		posStart = self:fixPos(posStart)
-- 		self.pathEnd = self:fixPos(self.pathEnd)
-- 		self.path = G_MAINSCENE.map_layer:getPathByPos(posStart, self.pathEnd)
-- 		self:addPath()
-- 		G_MAINSCENE.map_layer:moveMapByPos(self.pathEnd, true)
		
-- 		log("posStart.x = "..posStart.x.." self.pathEnd.x"..self.pathEnd.x)
-- 		log("posStart.y = "..posStart.y.." self.pathEnd.y"..self.pathEnd.y)

-- 		if math.abs(posStart.x - self.pathEnd.x) <=1 and math.abs(posStart.y - self.pathEnd.y) <=1 then
-- 			self.pathEnd = nil
-- 		end
-- 	end
-- end

function DetailMapNode:addPath()
	--log("DetailMapNode:addPath")
	if self.pathNode == nil then
		self.pathNode = cc.Node:create()
		self.mapInfoNode:addChild(self.pathNode)
	else
		self.pathNode:removeAllChildren()
	end

	if self.path == nil or self.pathEnd == nil then
		if self.path_end_str then
			removeFromParent(self.path_end_str)
			self.path_end_str = nil
		end
		--log("error:path info error !!!!!!!!")
		return
	end

	if not G_ROLE_MAIN then
		--log("error: G_ROLE_MAIN is nil !!!!!!!!")
		return 
	end

	local x,y = G_ROLE_MAIN:getPosition()
	x = x*self.mapScale
	y = y*self.mapScale
	local posNow = cc.p((x/self.mapNode:getContentSize().width * self.blockLayerSize.width), 
		((self.mapNode:getContentSize().height - y)/self.mapNode:getContentSize().height * self.blockLayerSize.height))
	posNow = self:fixPos(posNow)

	if math.abs(posNow.x - self.pathEnd.x) <=3 and math.abs(posNow.y - self.pathEnd.y) <=3 then
		self.path = nil
		self.pathEnd = nil
		if self.path_end_str then
			removeFromParent(self.path_end_str)
			self.path_end_str = nil
		end
		--log("error:no self.path or self.pathEnd")
		return
	end 

	local isDraw = false
	for k,v in pairs(self.path) do
		-- if v.x == posNow.x and v.y == posNow.y then
		-- 	isDraw = true
		-- end
		if math.abs(posNow.x - v.x) <=3 and math.abs(posNow.y - v.y) <=3 then
			isDraw = true
		end

		--log("isDraw = "..tostring(isDraw))
		if isDraw then
			local spr = cc.Sprite:create(path.."33.png")
			spr:setAnchorPoint(0.5, 0.5)
			self.pathNode:addChild(spr)
			spr:setPosition(cc.p(v.x*self.tileSize.width*self.mapScale, self.mapNode:getContentSize().height - v.y*self.tileSize.height*self.mapScale))
		end
	end

	if self.pathEnd then
		local spr = cc.Sprite:create(path.."44.png")
		spr:setAnchorPoint(0.5, 0)
		self.pathNode:addChild(spr)
		local m_pos = cc.p(self.pathEnd.x*self.tileSize.width*self.mapScale, self.mapNode:getContentSize().height - self.pathEnd.y*self.tileSize.height*self.mapScale)
		spr:setPosition(m_pos)
		if self.path_end_str then
			self.path_end_str:setString( "("..self.pathEnd.x..","..self.pathEnd.y..")")
			self.path_end_str:setPosition(cc.p(m_pos.x, m_pos.y+spr:getContentSize().height))
		else
			self.path_end_str = createBatchLabel(self.item_batchlabel, "("..self.pathEnd.x..","..self.pathEnd.y..")", cc.p(m_pos.x, m_pos.y+spr:getContentSize().height), cc.p(0.5, 0), 16, true, nil, nil, MColor.green)
		end
	else
		if self.path_end_str then
			removeFromParent(self.path_end_str)
			self.path_end_str = nil
		end
		--log("error:no pathEnd")
	end
end

function DetailMapNode:addPoint(choseType, idx)
	--log("DetailMapLayer:addPoint")
	--log("choseType = ".. choseType)
	--log("idx = ".. idx)
	-- if self.point == nil then
	-- 	self.point = cc.Sprite:create(path.."18.png")
	-- 	self.point:setAnchorPoint(cc.p(0.5, 0))
	-- 	self.mapInfoNode:addChild(self.point)
	-- 	self.point:setPosition(cc.p(display.width*2, display.height*2))
	-- end

	if choseType == DetailListViewType.NpcType then
		self.point:setPosition(cc.p(self.npcDataTab[idx].x*self.tileSize.width*self.mapScale, 
			self.mapNode:getContentSize().height - self.npcDataTab[idx].y*self.tileSize.height*self.mapScale + 10))
	elseif choseType == DetailListViewType.MonsterType then
		self.point:setPosition(cc.p(self.monsterDataTab[idx].x*self.tileSize.width*self.mapScale, 
			self.mapNode:getContentSize().height - self.monsterDataTab[idx].y*self.tileSize.height*self.mapScale + 10))
	end
end

function DetailMapNode:goToSomeOne(choseType, idx)
	--log("DetailMapLayer:goToSomeOne")
	--log("choseType = ".. choseType)
	--log("idx = ".. idx)
	local pos
	-- if self.point == nil then
	-- 	self.point = cc.Sprite:create(path.."18.png")
	-- 	self.point:setAnchorPoint(cc.p(0.5, 0))
	-- 	self.mapInfoNode:addChild(self.point)
	-- 	self.point:setPosition(cc.p(display.width*2, display.height*2))
	-- end

	if choseType == DetailListViewType.NpcType then
		-- self.point:setPosition(cc.p(self.npcDataTab[idx].x*self.tileSize.width*self.mapScale, 
		-- self.mapNode:getContentSize().height - self.npcDataTab[idx].y*self.tileSize.height*self.mapScale + 10))
		pos = cc.p(self.npcDataTab[idx].x, self.npcDataTab[idx].y)
		if (self.npcDataTab[idx].id == 51100 or self.npcDataTab[idx].id == 51101) and self.npcDataTab[idx].x1 then
			pos = cc.p(self.npcDataTab[idx].x1, self.npcDataTab[idx].y1)
		end
	elseif choseType == DetailListViewType.MonsterType then
		-- self.point:setPosition(cc.p(self.monsterDataTab[idx].x*self.tileSize.width*self.mapScale, 
		-- self.mapNode:getContentSize().height - self.monsterDataTab[idx].y*self.tileSize.height*self.mapScale + 10))
		pos = cc.p(self.monsterDataTab[idx].x, self.monsterDataTab[idx].y)
	end
	--DetailMap.touch_pos = pos
	self:goTo(pos,self.mapId,true)
end

function DetailMapNode:goTo(pos,map_id,isnear)
	log("DetailMapNode:goTo")
	game.setAutoStatus(AUTO_PATH_MAP) 
	if DATA_Mission then 
		DATA_Mission:setTempFindPath()
		DATA_Mission:setLastFind()
		DATA_Mission.isStopFind = true
		DATA_Mission:setLastTarget()
	end
	if G_MAINSCENE and G_MAINSCENE.map_layer and G_MAINSCENE.map_layer.removeWalkCb then
		G_MAINSCENE.map_layer:removeWalkCb()
	end
	--DetailMap.map_id = self.mapId
	local posEnd = pos
	DetailMap.target_pos = posEnd
	self.pathEnd = posEnd
	--log("33333333333333333333333333333333")
	if G_MAINSCENE.mapId == self.mapId then
			local callback = function()
				G_MAINSCENE.map_layer:removeWalkCb()
				game.setAutoStatus(0)
			end
			G_MAINSCENE.map_layer:registerWalkCb(callback)
			G_MAINSCENE.map_layer:moveMapByPos(posEnd, not not isnear)
			self.path = {}
			DetailMap.map_id = self.mapId
			startTimerAction(G_MAINSCENE, 0.3, false, function()
					local paths = G_MAINSCENE.map_layer:getRolePath() 
					if #paths > 1 then
						DetailMap.curmap_tarpos = DetailMap.target_pos
						G_MAINSCENE.map_layer.on_attack = nil
						if self and self.path then
							self.path = paths
							self:addPath()
						end
					else
						G_MAINSCENE.map_layer:removeWalkCb()
						self.pathEnd = nil
					end
				end)
	else
		local lv_min = getConfigItemByKey("MapInfo", "q_map_id", self.mapId, "q_map_min_level")
		if MRoleStruct:getAttr(ROLE_LEVEL) < lv_min then
			local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{17000,-8})
			local msgStr = string.format( msg_item.msg , tostring(lv_min) )
			TIPS( { type = msg_item.tswz , str = msgStr } )
			return
		end
		DetailMap.map_id = self.mapId
		DetailMap.curmap_tarpos = findTarMap(self.mapId,G_MAINSCENE.mapId)
		--self:createNode(G_MAINSCENE.mapId)
		--self.parent:goToDetailMap(G_MAINSCENE.mapId)
		G_MAINSCENE.map_layer.on_attack = nil
		performWithDelay(self,function() __RemoveTargetTab("a44") end,0.1)	
	end
end

function DetailMapNode:goToMapPos(map_id,pos,is_near)
	DetailMap.map_id = map_id
	DetailMap.target_pos = pos
	game.setAutoStatus(AUTO_PATH_MAP) 
	if DATA_Mission then 
		DATA_Mission:setTempFindPath()
		DATA_Mission:setLastFind()
		DATA_Mission.isStopFind = true
		DATA_Mission:setLastTarget()
	end
	--G_MAINSCENE.map_layer:removeWalkCb()
	if G_MAINSCENE.mapId == DetailMap.map_id then
		G_MAINSCENE.map_layer:moveMapByPos(pos, is_near)
	else 
		DetailMap.curmap_tarpos = findTarMap(DetailMap.map_id,G_MAINSCENE.mapId)
	end
end

function DetailMapNode:networkHander(buff,msgid)
	local switch = {
		[TEAM_SC_GETTEAMPOSINFO] = function() 
			log("get TEAM_SC_GETTEAMPOSINFO"..msgid)
			local t = g_msgHandlerInst:convertBufferToTable("TeamGetTeamPosInfoProtocol", buff)
			local isTeam = t.bTag
			local count = t.num

			if isTeam then
				self.teamData = {}
			else
                -- 多人守卫 怪物密集，不显示
                if self.mapId == 5104 then return end

				self.fbMonsterData = {}
			end

			for i=1,count do
				local record = {}
				record.x = t.infos[i].posX
				record.y = t.infos[i].posY
				record.roleId = t.infos[i].mapId
				record.name = t.infos[i].name
				if isTeam then
					table.insert(self.teamData, record)
				else
					table.insert(self.fbMonsterData, record)
				end
			end

			if isTeam then
				self:updateTeamInfo()
			else
				self:updateFbMonsterInfo()
			end
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end


--写死的路线 顺序不可更改

function DetailMapNode:getDartPath( _mapid )
	local pathCfg = {
						["2100"] = { 
										{ x = 193 , y = 32 }, { x = 189 , y = 36 }, { x = 185 , y = 40 }, { x = 181 , y = 44 }, { x = 177 , y = 48 }, { x = 173 , y = 44 }, { x = 169 , y = 40 }, 
										{ x = 165 , y = 40 }, { x = 161 , y = 40 }, { x = 157 , y = 36 }, { x = 153 , y = 32 }, { x = 149 , y = 32 }, { x = 145 , y = 32 }, { x = 141 , y = 28 }, 
										{ x = 137 , y = 28 }, { x = 133 , y = 32 }, { x = 129 , y = 36 }, { x = 125 , y = 36 }, { x = 121 , y = 36 }, { x = 117 , y = 36 }, { x = 113 , y = 36 }, 
										{ x = 109 , y = 40 }, { x = 105 , y = 44 }, { x = 101 , y = 48 }, { x = 97 , y = 52 }, { x = 93 , y = 56 }, { x = 89 , y = 60 }, { x = 85 , y = 64 },
										{ x = 81 , y = 68 }, { x = 77 , y = 72 }, { x = 73 , y = 76 }, { x = 69 , y = 80 }, { x = 65 , y = 84 }, { x = 61 , y = 84 }, { x = 57 , y = 84 }, 
										{ x = 53 , y = 88 }, { x = 49 , y = 92 }, { x = 45 , y = 96 }, { x = 41 , y = 100}, { x = 37 , y = 104 }, { x = 33 , y = 108 }, { x = 29 , y = 112 }, 
										{ x = 25 , y = 112 }, { x = 21 , y = 112 }, { x = 17 , y = 116 }, { x = 13 , y = 120 }, { x = 13 , y = 124 }, { x = 13 , y = 128 }, { x = 13 , y = 132 }, 
										{ x = 17 , y = 136 }, { x = 21 , y = 140 }, { x = 25 , y = 144 }, { x = 29 , y = 148 }, { x = 33 , y = 152 }, { x = 37 , y = 156 }, { x = 41 , y = 160 }, 
										{ x = 45 , y = 164 }, { x = 49 , y = 168 }, { x = 53 , y = 172 }, { x = 57 , y = 176 }, { x = 61 , y = 180 }, { x = 65 , y = 184 }, { x = 69 , y = 188 }, 
							            { x = 73 , y = 192 }, { x = 77 , y = 192 }, { x = 81 , y = 192 }, { x = 85 , y = 192 }, { x = 89 , y = 192 }, { x = 93 , y = 192 }, { x = 97 , y = 189 },
									} ,

					}
	local mapid = G_MAINSCENE.mapId
	if _mapid then return pathCfg[ _mapid .. "" ] end
	return mapid and pathCfg[ mapid .. "" ] or {}
end

--护送路线
function DetailMapNode:escortGoto( pos )
	if pos == nil then return end
	
	local mappathCfg = nil
	local nowTask = DATA_Mission:getLastTaskData() 
	local eventCfg = stringsplit( nowTask.q_done_event , "_" ) 
	if tonumber( eventCfg[1] ) == 56 then
		mappathCfg = getConfigItemByKey( "ConvoyDB" , "q_id" , tonumber(eventCfg[2]) )
	end
	local str = ""
	if mappathCfg and mappathCfg.q_path then
		str = mappathCfg.q_path
	end

	local pathCfg = unserialize( str )

	if str == "" or tablenums(pathCfg) == 0 then
		return
	end

	if pos.x == -1 and pos.y == -1  then 
		self.escortScheduler = nil
		if self.escortNode and self.escortNode.refreshLayer then
			self.escortNode.refreshLayer:removeAllChildren()
			if self.escortNode.dartFlag then
				removeFromParent( self.escortNode.dartFlag )
			end
		end 
		return 
	end

	local function convertPos( pos )
		pos = pos or pathCfg[1]
		return cc.p(pos.x*self.tileSize.width*self.mapScale, self.mapNode:getContentSize().height -  pos.y*self.tileSize.height*self.mapScale)
	end

	if self.escortNode == nil then
		self.escortNode = cc.Node:create()
		self.mapInfoNode:addChild(self.escortNode)
		self.escortNode.saveLayer = cc.Node:create()
		self.escortNode:addChild( self.escortNode.saveLayer,1)

		self.escortNode.escort_path = {}
		for i=1 , #pathCfg-1 do
			local tempPath = G_MAINSCENE.map_layer:getPathByPos( pathCfg[i] ,  pathCfg[i+1])
			for i = 1 , #tempPath do
				self.escortNode.escort_path[#self.escortNode.escort_path+1] = tempPath[i]
			end
		end
		self.escortNode.dartFlag = createSprite( self.escortNode.saveLayer , path.."28.png" , convertPos( pos ) , cc.p( 0.5 , 0.5 ) , 20 )
		local targetSp = createSprite( self.escortNode.saveLayer , path.."31-1.png" , convertPos( pathCfg[#pathCfg] ) , cc.p( 0.5 , 0.5 ))
		targetSp:setScale( 2 )
		local targetSp = createSprite( self.escortNode.saveLayer , path.."31.png" , convertPos( pathCfg[#pathCfg] ) , cc.p( 0.5 , 0.5 ))
	else
		self.escortNode.dartFlag:stopAllActions()

		local acts = {}
		acts[#acts+1] = cc.MoveTo:create( 0.3 , convertPos( pos ) )
		acts[#acts+1] = cc.CallFunc:create(function() end )
		self.sp_nodes = self.sp_nodes or {}
		self.escortNode.dartFlag:runAction(cc.Sequence:create(acts))	
		if not self.escortNode.refreshLayer then
			self.escortNode.refreshLayer = cc.Node:create()
			self.escortNode:addChild( self.escortNode.refreshLayer )
		end
		local smallValue , smallIndex = 999999 , 0
		for i = 1 , #self.escortNode.escort_path do
			local value = cc.pGetDistance( convertPos( self.escortNode.escort_path[ i ] ) , cc.p( self.escortNode.dartFlag:getPosition() ) )
			if smallValue>value then
				smallValue = value 
				smallIndex = i
				if value < 2 then
					break
				end
			end
		end
		if self.smallIndex and self.sp_nodes[self.smallIndex] then
			for i = self.smallIndex,smallIndex do
				if self.sp_nodes[i] then
					removeFromParent(self.sp_nodes[i])
				end
			end
		else
			for i = smallIndex , #self.escortNode.escort_path do
				local tempSp = createSprite( self.escortNode.refreshLayer , path.."31-1.png" , convertPos( self.escortNode.escort_path[i] )  , cc.p( 0.5 , 0.5 ))
				tempSp:setScale( 0.5 )
				self.sp_nodes[i] = tempSp
			end
		end
		self.smallIndex = smallIndex
	end
end

--镖车路线
function DetailMapNode:dart_goTo( pos )
	local pathCfg = self:getDartPath()
	if pos.x == -1 and pos.y == -1  then 
		self.dartScheduler = nil
		if self.dartNode and self.dartNode.refreshLayer then
			self.dartNode.refreshLayer:removeAllChildren()
		end 
		return 
	end

	local function convertPos( pos )
		pos = pos or pathCfg[1]
		return cc.p(pos.x*self.tileSize.width*self.mapScale, self.mapNode:getContentSize().height -  pos.y*self.tileSize.height*self.mapScale)
	end

	if self.dartNode == nil then
		self.dartNode = cc.Node:create()
		self.mapInfoNode:addChild(self.dartNode)
		self.dartNode.saveLayer = cc.Node:create()
		self.dartNode:addChild( self.dartNode.saveLayer,1)

		self.dartNode.dart_path = {}
		for i=1 , #pathCfg-1 do
			local tempPath = G_MAINSCENE.map_layer:getPathByPos(pathCfg[i], pathCfg[i+1] )
			for i = 1 , #tempPath do
				self.dartNode.dart_path[#self.dartNode.dart_path+1] = tempPath[i]
			end
		end
		self.dartNode.dartFlag = createSprite( self.dartNode.saveLayer , path.."dart_flag.png" , convertPos( pos ) , cc.p( 0.5 , 0.5 ) , 20 )
		local targetSp = createSprite( self.dartNode.saveLayer , path.."31-1.png" , convertPos( pathCfg[#pathCfg] ) , cc.p( 0.5 , 0.5 ))
		targetSp:setScale( 2 )
		local targetSp = createSprite( self.dartNode.saveLayer , path.."31.png" , convertPos( pathCfg[#pathCfg] ) , cc.p( 0.5 , 0.5 ))
	else
		self.dartNode.dartFlag:stopAllActions()

		local acts = {}
		acts[#acts+1] = cc.MoveTo:create( 0.3 , convertPos( pos ) )
		acts[#acts+1] = cc.CallFunc:create(function() end )
		self.sp_nodes = self.sp_nodes or {}
		self.dartNode.dartFlag:runAction(cc.Sequence:create(acts))	
		if not self.dartNode.refreshLayer then
			self.dartNode.refreshLayer = cc.Node:create()
			self.dartNode:addChild( self.dartNode.refreshLayer )
		end
		local smallValue , smallIndex = 999999 , 0
		for i = 1 , #self.dartNode.dart_path do
			local value = cc.pGetDistance( convertPos( self.dartNode.dart_path[ i ] ) , cc.p( self.dartNode.dartFlag:getPosition() ) )
			if smallValue>value then
				smallValue = value 
				smallIndex = i
				if value < 2 then
					break
				end
			end
		end
		if self.smallIndex and self.sp_nodes[self.smallIndex] then
			for i = self.smallIndex,smallIndex do
				if self.sp_nodes[i] then
					removeFromParent(self.sp_nodes[i])
				end
			end
		else
			for i = smallIndex , #self.dartNode.dart_path do
				local tempSp = createSprite( self.dartNode.refreshLayer , path.."31-1.png" , convertPos( self.dartNode.dart_path[i] )  , cc.p( 0.5 , 0.5 ))
				tempSp:setScale( 0.5 )
				self.sp_nodes[i] = tempSp
			end
		end
		self.smallIndex = smallIndex
	end
end

function DetailMapNode:addBanner()
	self.mapBannerNode = cc.Node:create()
	self.mapInfoNode:addChild(self.mapBannerNode)

	local itemdate, defPos = getBattleAreaInfo(self.mapId)
	if itemdate then
		local function refreshData()
			local bannerPos = defPos
			if itemdate.manorID == G_EMPIRE_INFO.BATTLE_INFO.manorID and G_EMPIRE_INFO.BATTLE_INFO.bannerX and G_EMPIRE_INFO.BATTLE_INFO.bannerY then
				bannerPos = cc.p(G_EMPIRE_INFO.BATTLE_INFO.bannerX, G_EMPIRE_INFO.BATTLE_INFO.bannerY)
			end
			self.mapBannerNode:removeChildByTag(100)

			if bannerPos then
				local spr = cc.Sprite:create("res/mapui/28.png")
				spr:setAnchorPoint(0.5, 0.5)
				self.mapBannerNode:addChild(spr)
				spr:setTag(100)
				local pos = G_MAINSCENE.map_layer:tile2Space(cc.p(bannerPos.x, bannerPos.y))
				spr:setPosition(cc.p(pos.x*self.mapScale, 15 + pos.y*self.mapScale))
			end
		end

		if itemdate.manorID == G_EMPIRE_INFO.BATTLE_INFO.manorID then
			startTimerAction(self.mapBannerNode, 2, true, refreshData)
		end
		refreshData()
	end
end

return DetailMapNode