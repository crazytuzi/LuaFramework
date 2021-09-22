-- 右上角小地图模块
local GUIMapMin = {}
local var = {}


local function mapPosToMini(mapPos)
	--local miniSize = cc.size(512,512)
	--local mPixesMap = NetCC:getMap()
	local targetX = mapPos.x * (512 / NetCC:getMap():LogicWidth())
	local targetY = mapPos.y * (512 / NetCC:getMap():LogicHeight())
	return cc.p(targetX,targetY)
end

local function updateGhost()
	if not var.mapImg then return end
	if not var.addGhostPoint then
		-- for i=1,20 do
		-- 	ccui.ImageView:create()
		-- 		:addTo(var.mapImg)
		-- 		:setScale(0.4)
		-- 		:setTag(i)
		-- end
		-- var.addGhostPoint = true
	end

	if GameCharacter._mainAvatar then
		var.miniPos = mapPosToMini(cc.p(GameCharacter._mainAvatar:NetAttr(GameConst.net_x),GameCharacter._mainAvatar:NetAttr(GameConst.net_y)))
		-- local mainPoint = var.mapImg:getChildByTag(1):loadTexture("img_expbar_green", ccui.TextureResType.plistType)
		-- 	:align(display.CENTER, var.miniPos.x, 512- var.miniPos.y )
	end
	-- local ghosts = NetCC:getNearGhost(0, true)
	-- for i = 1, 19 do
	-- 	local ghostPoint = var.mapImg:getChildByTag(i + 1)
	-- 	if ghostPoint then
	-- 		ghostPoint:hide()
	-- 		if ghosts[i] then
	-- 			local mGhost = NetCC:getGhostByID(ghosts[i])
	-- 			if mGhost then
	-- 				var.miniPos = mapPosToMini(cc.p(mGhost:NetAttr(GameConst.net_x),mGhost:NetAttr(GameConst.net_y)))
	-- 				if mGhost:NetAttr(GameConst.net_type) == GameConst.GHOST_MONSTER then
	-- 					ghostPoint:loadTexture("img_expbar_red", ccui.TextureResType.plistType)
	-- 						:align(display.CENTER, var.miniPos.x, 512- var.miniPos.y )
	-- 						:show()
	-- 				elseif mGhost:NetAttr(GameConst.net_type) == GameConst.GHOST_NPC then
	-- 					ghostPoint:loadTexture("img_expbar_yellow", ccui.TextureResType.plistType)
	-- 						:align(display.CENTER, var.miniPos.x, 512- var.miniPos.y )
	-- 						:show()
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
end

local function handleMapEnter(event)
	local minimap = GameSocket.mNetMap.mMiniMapID
	if minimap  then
		if var.lblMapName then
			local strMapName = GameSocket.mNetMap.mName
			local pos = string.find(strMapName,"%[")
			if pos and pos > 0 then
				strMapName = string.sub(strMapName, 0, pos - 1)
			end
			var.lblMapName:setString(strMapName)
		end

	-- 	if not var.mapImg then
	-- 		local stencil = cc.Sprite:createWithSpriteFrameName("btn_map")
	-- 		stencil:setScale(1.75)
	-- 		local clipper = cc.ClippingNode:create(stencil)
	-- 			:align(display.CENTER, var.boxMiniMap:getContentSize().width * 0.5 - 15,  var.boxMiniMap:getContentSize().height * 0.5)
	-- 			:addTo(var.boxMiniMap, 1)
	-- 		clipper:setInverted(false)
	-- 		clipper:setAlphaThreshold(0)

	-- 		var.mapImg = ccui.ImageView:create()
	-- 			:align(display.LEFT_TOP, 0,  0)
	-- 			:addTo(clipper)
			
	-- 	end
	-- 	var.mapImg:loadTexture(string.format("map/preview/%05d.jpg",minimap))
	end
end

local function initBoxMiniMap()
	var.lblMapName = var.boxMiniMap:getWidgetByName("lbl_map_name2"):setLocalZOrder(2)
	var.lblMapPos = var.boxMiniMap:getWidgetByName("lbl_map_pos2"):setLocalZOrder(2)
	-- var.boxMiniMap:getWidgetByName("mini_map_bg"):setLocalZOrder(2)
	GUIFocusPoint.addUIPoint(var.boxMiniMap:setTouchEnabled(true), function (pSender)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_minimap" ,startPos = pSender:getWorldPosition() ,noBg=false} )
	end)
end


function GUIMapMin.init(boxMiniMap)
	var = {
		boxMiniMap,
		lblMapName,
		lblMapPos,
	}
	var.boxMiniMap = boxMiniMap

	if var.boxMiniMap then
		initBoxMiniMap()
		handleMapEnter()

		cc.EventProxy.new(GameSocket, boxMiniMap)
			:addEventListener(GameMessageCode.EVENT_MAP_ENTER, handleMapEnter)
	end
end

function GUIMapMin.update()
	if not var.boxMiniMap then return end
	if not GameCharacter._mainAvatar then return end
	
	if var.lblMapPos then 
		var.lblMapPos:setString("当前坐标 "..GameCharacter._mainAvatar:NetAttr(GameConst.net_x)..","..GameCharacter._mainAvatar:NetAttr(GameConst.net_y))
	end

	local miniPos = mapPosToMini(cc.p(GameCharacter._mainAvatar:NetAttr(GameConst.net_x),GameCharacter._mainAvatar:NetAttr(GameConst.net_y)))

	-- local rect_size = var.boxMiniMap:getWidgetByName("mini_map_bg"):getContentSize()
	-- if miniPos.x <= rect_size.width/2 then
	-- 	miniPos.x = rect_size.width/2
	-- elseif miniPos.x >= 512 - rect_size.width/2 then
	-- 	miniPos.x = 512 - rect_size.width/2
	-- end
	-- if miniPos.y <= rect_size.height/2 then
	-- 	miniPos.y = rect_size.height/2
	-- elseif miniPos.y >= 512 - rect_size.height/2 then
	-- 	miniPos.y = 512 - rect_size.height/2
	-- end
	-- if var.mapImg then
	-- 	var.mapImg:setPosition(cc.p( -miniPos.x, miniPos.y))
	-- end
	-- TODO 此处要review代码，防止有效率坑
	-- updateGhost()
end

return GUIMapMin