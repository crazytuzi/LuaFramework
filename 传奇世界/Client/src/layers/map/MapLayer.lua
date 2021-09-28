local WorldMapLayer = class("WorldMapLayer", function() return cc.Layer:create() end )

function WorldMapLayer:ctor(parent)
	local addSprite = createSprite
	local addLabel = createLabel
	
	self.getString = game.getStrByKey
	self.bg = self
	self:goToDetailMap(id)
	self:setPosition(cc.p(0,0))
    self:registerScriptHandler(function(event)
		if event == "enter" then
			--G_TUTO_NODE:setShowNode(root, SHOW_MAP)
		elseif event == "exit" then
			--G_TUTO_NODE:setShowNode(root, SHOW_MAIN)
			if G_ROLE_MAIN then
				-- g_msgHandlerInst:sendNetDataByFmtExEx(TEAM_CS_CHANGEPOSMAPID, "ii", G_ROLE_MAIN.obj_id, 0)
				g_msgHandlerInst:sendNetDataByTableExEx(TEAM_CS_CHANGEPOSMAPID, "TeamChangePosMapIdProtocol", {["curMapId"] = 0})
			end
		end
	end)
end

function WorldMapLayer:goToWorldMap()
	if self.detailMapNode then
		--self.detailMapNode:setPosition(cc.p(display.width*2, display.height*2))
		removeFromParent(self.detailMapNode)
		self.detailMapNode = nil 
	end

	if self.worldMapNode == nil then
		self.worldMapNode = require("src/layers/map/WorldMapNode").new(self)
	end
	self:addChild(self.worldMapNode)
	self.worldMapNode:setPosition(cc.p(480, 285))
end

function WorldMapLayer:goToDetailMap(id)
	if self.worldMapNode then
		removeFromParent(self.worldMapNode)
		self.worldMapNode = nil
	end

	if self.detailMapNode then

		self.detailMapNodeToDelete = self.detailMapNode
		self.detailMapNode = nil 
		performWithDelay(self, function() removeFromParent(self.detailMapNodeToDelete) self.detailMapNodeToDelete = nil end, 1)
	end

	if id == nil then
		id = G_MAINSCENE.mapId
	end
	local cb = function()
		if self.detailMapNode == nil then
			self.detailMapNode = require("src/layers/map/DetailMapNode").new(self,id)
		end

		self.bg:addChild(self.detailMapNode)
		self.detailMapNode:setPosition(cc.p(10, 285))
	end
	cb()
end

return WorldMapLayer