local CrossPVPTopButtonsSub = class("CrossPVPTopButtonsSub", UFCCSModelLayer)

local CrossPVPConst = require("app.const.CrossPVPConst")

function CrossPVPTopButtonsSub.show(pos)
	local layer = CrossPVPTopButtonsSub.new("ui_layout/crosspvp_TopButtons_Sub.json", nil, pos)
	uf_sceneManager:getCurScene():addChild(layer)

	return layer
end

function CrossPVPTopButtonsSub:ctor(json, color, pos)
	self._bg = self:getImageViewByName("Image_SubBtnBg")
	self._bg:setPosition(pos)
	self.super.ctor(self, json, color)

	self:registerTouchEvent(false,true,0)
    self:adapterWithScreen()  
end

function CrossPVPTopButtonsSub:onLayerLoad()
	-- pop up effect
	self._bg:setScale(0)
	self._bg:runAction(CCScaleTo:create(0.2, 1))

	self:registerBtnClickEvent("Button_ViewWinAward", handler(self, self._onClickViewWin))
	self:registerBtnClickEvent("Button_ViewJoinAward", handler(self, self._onClickViewJoin))
end

function CrossPVPTopButtonsSub:onLayerEnter()
	uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._close, self)
end

function CrossPVPTopButtonsSub:onTouchBegin(x, y)
	local touchPos = self._bg:getParent():convertToNodeSpace(ccp(x,y))
	local renderer = self._bg:getVirtualRenderer()
	renderer = tolua.cast(renderer, SCALE9SPRITE)

	local anchor = self._bg:getAnchorPoint()
	local size = renderer:getPreferredSize()
	local origin = self._bg:boundingBox().origin

	local rect = CCRect(origin.x - size.width * anchor.x, origin.y - size.height, size.width, size.height)
	if not G_WP8.CCRectContainPt(rect, touchPos) then
		self:removeFromParentAndCleanup(true)
	end
end

function CrossPVPTopButtonsSub:_onClickViewWin()
	require("app.scenes.crosspvp.CrossPVPPromotedAwardLayer").show(G_Me.crossPVPData:getBattlefield(), true)
end

function CrossPVPTopButtonsSub:_onClickViewJoin()
	require("app.scenes.crosspvp.CrossPVPPromotedAwardLayer").show(G_Me.crossPVPData:getBattlefield(), false)
end

function CrossPVPTopButtonsSub:_close()
	self:removeFromParentAndCleanup(true)
end

return CrossPVPTopButtonsSub