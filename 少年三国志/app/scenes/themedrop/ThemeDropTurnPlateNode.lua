
local EffectNode = require("app.common.effects.EffectNode")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local TurnNode = require("app.scenes.common.turnplate.TurnNode")

local ThemeDropTurnPlateNode = class("ThemeDropTurnPlateNode", TurnNode)

function ThemeDropTurnPlateNode.create(...)
	return ThemeDropTurnPlateNode.new("ui_layout/themedrop_Pedestal.json", nil, ...)
end

function ThemeDropTurnPlateNode:ctor(json, param, ...)
	self.super.ctor(self, json, param, ...)

	self._nIndex = 0
	self._nKnightBaseId = 0

	self._nEffectScale = 1

	self:_initWidgets()

end

function ThemeDropTurnPlateNode:onLayerEnter( ... )
	-- body
end

function ThemeDropTurnPlateNode:onLayerExit( ... )
	-- body
end

function ThemeDropTurnPlateNode:_initWidgets()


end

function ThemeDropTurnPlateNode:getKnightBaseId()
	return self._nKnightBaseId
end

function ThemeDropTurnPlateNode:setData(nIndex, nKnightBaseId)
	self._nIndex = nIndex or 0
	self._nKnightBaseId = nKnightBaseId or 0

	local nBaseId = self._nKnightBaseId
	if nBaseId ~= 0 then
		local tKnightTmpl = knight_info.get(nBaseId)
		if not tKnightTmpl then
			return
		end
		local nResId = tKnightTmpl.res_id

		CommonFunc._updateImageView(self, "Image_Icon", {texture=G_Path.getKnightIcon(nResId), texType=UI_TEX_TYPE_LOCAL})
		CommonFunc._updateImageView(self, "Image_Frame", {texture=G_Path.getAddtionKnightColorImage(tKnightTmpl.quality), texType=UI_TEX_TYPE_PLIST})
		CommonFunc._updateLabel(self, "Label_Name", {text=tKnightTmpl.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[tKnightTmpl.quality]})

		CommonFunc._updateLabel(self, "Label_KnightName", {text=tKnightTmpl.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[tKnightTmpl.quality]})
	end

	CommonFunc._updateLabel(self, "Label_Index", {text=self._nIndex, stroke=Colors.strokeBrown})
end

function ThemeDropTurnPlateNode:setImageScale(s)
    self:getRootWidget():setScale(s)
end

function ThemeDropTurnPlateNode:scaleStarImage(nScale)
	nScale = nScale or 1
	self:getImageViewByName("ImageView_Pedestal"):setScale(nScale)
end

function ThemeDropTurnPlateNode:adapterKinghtNamePos()
	local tSize = self:getImageViewByName("ImageView_Pedestal"):getSize()
	local labelKnightName = self:getLabelByName("Label_KnightName")
	if labelKnightName then
		labelKnightName:setPositionY(-tSize.height/2 - 35)
	end
end

function ThemeDropTurnPlateNode:changeOpacity(nOpacity)
	nOpacity = nOpacity or 255
	self:getImageViewByName("ImageView_Pedestal"):setOpacity(nOpacity)
end

function ThemeDropTurnPlateNode:getBaseImageOpacity()
	return self:getImageViewByName("ImageView_Pedestal"):getOpacity()
end

function ThemeDropTurnPlateNode:addEffect(nScale)
	nScale = nScale or 1
	self._nEffectScale = nScale
	self._tEffect = EffectNode.new("effect_xingqiu", function(event, frameIndex)
	end)
	local tParent = self:getImageViewByName("ImageView_Pedestal")
	if tParent then
	 	local tSize = tParent:getSize()
	 	self._tEffect:setScale(nScale)
		tParent:addNode(self._tEffect)
		self._tEffect:play()

	 --    local actMoveUp = CCMoveBy:create(0.9, ccp(0, 10))
		-- local actMoveDown = CCMoveBy:create(0.9, ccp(0, -10))
		-- local actSeq = CCSequence:createWithTwoActions(actMoveDown, actMoveUp)
		-- local actRep = CCRepeatForever:create(actSeq)
		-- self._tEffect:runAction(actRep)
	end
end



return ThemeDropTurnPlateNode