local BreakAwardLayer = class("BreakAwardLayer",UFCCSModelLayer)

function BreakAwardLayer.create(...)
	return BreakAwardLayer.new("ui_layout/arena_BreakAwardLayer.json",require("app.setting.Colors").modelColor,...)
end

function BreakAwardLayer:ctor(json,color,... )
	self._okFunc = nil
	self.super.ctor(self,...)
	self:showAtCenter(true)
	self:_initWidget()
	self:_setStroke()
	self:_setWidgets(...)
    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    EffectSingleMoving.run(self:getImageViewByName("ImageView_goon"), "smoving_wait", nil, {})
	self:registerTouchEvent(false, true, 0)
end

function BreakAwardLayer:onLayerEnter()
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	-- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
	-- if appstoreVersion or IS_HEXIE_VERSION  then 
	-- 	local img = self:getImageViewByName("Image_3")
	-- 	if img then
	-- 		img:loadTexture("ui/arena/xiaozhushou_hexie.png")
	-- 	end
	-- end
	GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_3"))
end
function BreakAwardLayer:_initWidget()
	self._newRankLabel = self:getLabelByName("Label_newRank")
	self._breakRankLabel = self:getLabelByName("Label_breakRank")
	self._awardGoldLabel = self:getLabelByName("Label_breakaward")
end

function BreakAwardLayer:_setWidgets(newRank,historyRank,awardGold,callback)
	self._newRankLabel:setText(newRank)
	self._breakRankLabel:setText(G_lang:get("LANG_ARENA_RANKING_BREAK",{rank=(historyRank - newRank)}))
	self._awardGoldLabel:setText(awardGold)
	self._okFunc = callback
end

function BreakAwardLayer:_setStroke()
	self._newRankLabel:createStroke(Colors.strokeBrown,1)
	self._awardGoldLabel:createStroke(Colors.strokeBrown,1)
end

function BreakAwardLayer:onTouchEnd( xpos, ypos )
    self:animationToClose()
    if self._okFunc ~= nil then self._okFunc() end
end

function BreakAwardLayer:onTouchCancel( xpos, ypos )
    
end

return BreakAwardLayer