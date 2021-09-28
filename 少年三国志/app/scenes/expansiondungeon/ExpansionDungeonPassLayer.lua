local ExpansionDungeonConst = require("app.const.ExpansionDungeonConst")
local ExpansionDungeonPassLayer = class("ExpansionDungeonPassLayer", UFCCSModelLayer)

function ExpansionDungeonPassLayer.create(nPassType, nResId, szName, nQuality, ...)
	return ExpansionDungeonPassLayer.new("ui_layout/expansiondungeon_PassLayer.json", Colors.modelColor, nPassType, nResId, szName, nQuality, ...)
end

function ExpansionDungeonPassLayer:ctor(json, param, nPassType, nResId, szName, nQuality, ...)
	self._nPassType = nPassType or 1
	self._nResId = nResId
	self._szName = szName
	self._nQuality = nQuality
	
	self.super.ctor(self, json, param, ...)
end

function ExpansionDungeonPassLayer:onLayerLoad()
	self:_initView()
	self:_initWidgets()
	self:_addHead()
end

function ExpansionDungeonPassLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)
	self:registerTouchEvent(false,true,0)

	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

function ExpansionDungeonPassLayer:onLayerExit()
	
end

function ExpansionDungeonPassLayer:onLayerUnload()
	
end

function ExpansionDungeonPassLayer:_initView()
	
end

function ExpansionDungeonPassLayer:_initWidgets()
	G_GlobalFunc.updateLabel(self, "Label_Name", {text=self._szName, color=Colors.qualityColors[self._nQuality], stroke=Colors.strokeBrown})

	local szDesc = ""
	if self._nPassType == ExpansionDungeonConst.PASS_TYPE.MAX_FIGHT_VALUE then
		szDesc = G_lang:get("LANG_EX_DUNGEON_MAX_PASS_DESC")
	elseif self._nPassType == ExpansionDungeonConst.PASS_TYPE.MIN_FIGHT_VALUE then
		szDesc = G_lang:get("LANG_EX_DUNGEON_MIN_PASS_DESC")
	end
	G_GlobalFunc.updateLabel(self, "Label_Desc", {text=szDesc, stroke=Colors.strokeBrown})

	G_GlobalFunc.updateImageView(self, "Image_Title", {texture=G_Path.getExDungeonPassType(self._nPassType), texType=UI_TEX_TYPE_LOCAL})
end

function ExpansionDungeonPassLayer:_addHead()
	local head = require("app.scenes.common.KnightPic").getHalfNode(self._nResId,0, true)
	local bottomPanel = self:getPanelByName("Panel_Knight")
	if bottomPanel then
	    bottomPanel:addNode(head)
	    head:setPositionX(bottomPanel:getContentSize().width*0.4)
	    head:setPositionY(bottomPanel:getContentSize().height*0.57)
	end
end

function ExpansionDungeonPassLayer:onTouchEnd(xPos,yPos)
    self:animationToClose()
end

return ExpansionDungeonPassLayer