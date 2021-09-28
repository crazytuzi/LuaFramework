-- LegionNewRollBackChooseLayer
local LegionNewRollBackChooseLayer = class("LegionNewRollBackChooseLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function LegionNewRollBackChooseLayer.show( ... )
	print("show")
	local targetLayer = LegionNewRollBackChooseLayer.new("ui_layout/legion_RollBackLayer.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(targetLayer)
end

function LegionNewRollBackChooseLayer:ctor( ... )
	self.super.ctor(self, ...)
	self:showAtCenter(true)
	self:setClickClose(true)

	self:getLabelByName("Label_title1"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_title2"):createStroke(Colors.strokeBrown, 1)
	-- G_Me.legionData:getCorpDetail() 
	self:registerWidgetClickEvent("Image_left",function (  )
		self:clickBtn(false)
	end)
	self:registerWidgetClickEvent("Image_right",function (  )
		self:clickBtn(true)
	end)
end

function LegionNewRollBackChooseLayer:clickBtn( state )
	if G_Me.legionData:getCorpDetail().position ~= 1 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_NEW_LEGION_CANNOT_CALLBACK"))
		return
	end 
	G_HandlersManager.legionHandler:sendSetNewCorpRollbackChapter(state)
end

function LegionNewRollBackChooseLayer:onLayerEnter( ... )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_ROLLBACK, self.updateBox, self)
	self:updateView()

	EffectSingleMoving.run(self:getImageViewByName("Image_close"), "smoving_wait", nil , {position = true} )
end

function LegionNewRollBackChooseLayer:updateView( )
	local chapterId = G_Me.legionData:getNextChapter()
	self:getLabelByName("Label_target1"):setText(G_lang:get("LANG_NEW_LEGION_TO_CHAPTER",{id=chapterId+1}))
	self:getLabelByName("Label_target2"):setText(G_lang:get("LANG_NEW_LEGION_TO_CHAPTER",{id=chapterId}))
	self:getLabelByName("Label_max"):setText(G_lang:get("LANG_NEW_LEGION_CHAPTER",{id=chapterId+1}))
	self:updateBox()
end

function LegionNewRollBackChooseLayer:updateBox( )
	local state = G_Me.legionData:getRollBack()
	self:getImageViewByName("Image_gou1"):setVisible(not state)
	self:getImageViewByName("Image_gou2"):setVisible(state)
end

return LegionNewRollBackChooseLayer