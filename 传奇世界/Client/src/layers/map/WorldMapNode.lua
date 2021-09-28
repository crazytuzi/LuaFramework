local WorldMapNode = class("WorldMapNode", function() return cc.Node:create() end )

function WorldMapNode:ctor(parent)
	local addSprite = createSprite
	local addLabel = createLabel
	self.parent = parent
	self.getString = game.getStrByKey

	local path = "res/mapui/"

	--大地图
	local bg = addSprite(self, "res/common/bg/bg.png", cc.p(0, 0), cc.p(0.5, 0.5))
	--bg:setScale(1.018,1.025)
	local map = addSprite(self, path.."17.jpg", cc.p(0, 3), cc.p(0.5, 0.5))
	--addSprite(map, path.."38.png", cc.p(map:getContentSize().width/2, map:getContentSize().height/2), cc.p(0.5, 0.5), -1)

	local mapSub3 = addSprite(map, path.."mapSub/mapSub3.png", cc.p(154, 328), cc.p(0.5, 0.5))
	
	self.locationNodes = {}
	self.locationToMapId = {}
	self.locationToMapId[2] = 3120 --禁地魔穴
--	self.locationToMapId[3] = 3130 --红名村
	self.locationToMapId[4] = 3110 --逆魔古刹
	self.locationToMapId[5] = 4130 --修罗天
	self.locationToMapId[6] = 4120 --铁血魔城
	self.locationToMapId[7] = 4110 --通天塔
	self.locationToMapId[8] = 4100 --跃马平原
	self.locationToMapId[9] = 2120 --蛇魔谷
	self.locationToMapId[10] = 2100 --中州
	self.locationToMapId[11] = 2110 --将军坟
	self.locationToMapId[12] = 3100 --热砂荒漠
	self.locationToMapId[13] = 2130 --机关洞
	self.locationToMapId[14] = 1100 --落霞岛
	self.locationToMapId[15] = 8100 --禁地
	self.locationToMapId[16] = 9100 --死水沼泽
	self.locationToMapId[17] = 2126 --矿区入口

	local goToDetailMap = function(mapId)
		log("goToDetailMap mapId="..mapId)
		-- local detailMapLayer = require("src/layers/map/DetailMapLayer").new(mapId)
		-- self:addChild(detailMapLayer)
		self.parent:goToDetailMap(mapId)
	end

	local touchLocation = function(id, node)
		-- for i,v in ipairs(self.locationNodes) do
		-- 	if node == v then
		-- 		local mapId = self.locationToMapId[i + 1]
				goToDetailMap(self.locationToMapId[id])
		-- 	end
		-- end
	end

	-- local addLocationName = function(parent, id, pos)
	-- 	local nameBg = createTouchItem(parent, path.."15.png", pos, touchLocation)
	-- 	local name = getConfigItemByKey("MapInfo", "q_map_id", self.locationToMapId[id], "q_map_name")
	-- 	if name then
	-- 		addLabel(nameBg, name, getCenterPos(nameBg), cc.p(0.5, 0.5), 20, true)
	-- 	end
	-- 	self.locationNodes[#self.locationNodes + 1] = nameBg

	-- 	if self.locationToMapId[id] == G_MAINSCENE.mapId then
	-- 		addSprite(nameBg, path.."18.png", cc.p(nameBg:getContentSize().width/2, nameBg:getContentSize().height + 5), cc.p(0.5, 0))
	-- 	end
	-- end

	local addLocationName = function(parent, id, pos)
		local strLabBack = "15.png"
		if id == 2 or id == 4 or id == 5 or id == 6 or id == 7 or id == 9 or id == 11 or id == 13 or id == 17 then
			strLabBack = "15-2.png"
		end

		local nameSpr = createTouchItem(parent, path..strLabBack, pos, function() touchLocation(id) end)
		nameSpr:setAnchorPoint(cc.p(0, 0))
		--nameSpr:setScale(0.8)
		--nameSpr:registerScriptTapHandler(touchLocation)
		addSprite(nameSpr, path.."world/"..id..".png", getCenterPos(nameSpr), cc.p(0.5, 0.5), nil, 0.8)
		self.locationNodes[#self.locationNodes + 1] = nameSpr

		-- if self.locationToMapId[id] == G_MAINSCENE.mapId then
		-- 	addSprite(nameSpr, path.."18.png", cc.p(nameSpr:getContentSize().width/2, nameSpr:getContentSize().height + 5), cc.p(0.5, 0))
		-- end
	end

	--大地图上位置图标
	addLocationName(map, 2, cc.p(539, 200))--禁地魔穴
--	addLocationName(map, 3, cc.p(63, 383))--红名村
	addLocationName(map, 4, cc.p(777, 133))--逆魔古刹
	addLocationName(map, 5, cc.p(225, 439))--修罗天
	addLocationName(map, 6, cc.p(455, 460))--铁血魔城
	addLocationName(map, 7, cc.p(697, 414))--通天塔
	addLocationName(map, 8, cc.p(690, 285))--跃马平原
	addLocationName(map, 9, cc.p(553, 107))--蛇魔谷
	addLocationName(map, 10, cc.p(377, 38))--中州
	addLocationName(map, 11, cc.p(138, 82))--将军坟
	addLocationName(map, 12, cc.p(370, 140))--热砂荒漠
	addLocationName(map, 13, cc.p(270, 255))--机关洞
	addLocationName(map, 14, cc.p(60, 200))--落霞岛
	addLocationName(map, 15, cc.p(470, 306))--禁地
	addLocationName(map, 16, cc.p(290, 350))--死水沼泽
	addLocationName(map, 17, cc.p(150, 140))--矿区入口

	createMenuItem(map, path.."16-1.png", cc.p(50, 30), function() goToDetailMap(G_MAINSCENE.mapId) end)

	self:setScale(0.01)
    self:runAction(cc.ScaleTo:create(0.2, 1))
end

return WorldMapNode