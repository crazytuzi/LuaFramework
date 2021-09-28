
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local KnightTransformConst = require("app.const.KnightTransformConst")
local KnightTransformPreviewLayer = class("KnightTransformPreviewLayer", UFCCSModelLayer)

function KnightTransformPreviewLayer.create(nSourceKnightId, nTargetKnightBaseId, ...)
	return KnightTransformPreviewLayer.new("ui_layout/KnightTransform_PreviewLayer.json", Colors.modelColor, nSourceKnightId, nTargetKnightBaseId, ...)
end

function KnightTransformPreviewLayer:ctor(json, param, nSourceKnightId, nTargetKnightBaseId, ...)
	self.super.ctor(self, json, param, ...)

	self._nDevelopType = KnightTransformConst.DEVELOP_TYPE.LEVELUP
	self._nSourceKnightId = nSourceKnightId
	self._nTargetKnightBaseId = nTargetKnightBaseId

	self:_initTabs()
	self:_initWidgets()

	for i=1, 4 do
		self:_initDevelopInfo(i)
	end

	self:_initAwakeInfo()
	self:_initDevelopInfo(6)
end

function KnightTransformPreviewLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

function KnightTransformPreviewLayer:onLayerExit()
	
end

function KnightTransformPreviewLayer:_initTabs()
	self._tabs = require("app.common.tools.Tabs").new(1, self, self._checkedCallBack, self._uncheckedCallBack) 
    self._tabs:add("CheckBox_1", self:getPanelByName("Panel_Develop1"), "Label_Levelup") 
    self._tabs:add("CheckBox_2", self:getPanelByName("Panel_Develop2"), "Label_Break") 
    self._tabs:add("CheckBox_3", self:getPanelByName("Panel_Develop3"), "Label_Foster") 
    self._tabs:add("CheckBox_4", self:getPanelByName("Panel_Develop4"), "Label_Destiny") 
    self._tabs:add("CheckBox_5", self:getPanelByName("Panel_Develop5"), "Label_Awake") 
    self._tabs:add("CheckBox_6", self:getPanelByName("Panel_Develop6"), "Label_God") 


    self._tabs:checked("CheckBox_" .. self._nDevelopType)
end

function KnightTransformPreviewLayer:_checkedCallBack(szCheckBoxName)
	if szCheckBoxName == "CheckBox_1" then
		self._nDevelopType = KnightTransformConst.DEVELOP_TYPE.LEVELUP
	elseif szCheckBoxName == "CheckBox_2" then
		self._nDevelopType = KnightTransformConst.DEVELOP_TYPE.BREAK
	elseif szCheckBoxName == "CheckBox_3" then
		self._nDevelopType = KnightTransformConst.DEVELOP_TYPE.FOSTER
	elseif szCheckBoxName == "CheckBox_4" then
		self._nDevelopType = KnightTransformConst.DEVELOP_TYPE.DESTINY
	elseif szCheckBoxName == "CheckBox_5" then
		self._nDevelopType = KnightTransformConst.DEVELOP_TYPE.AWAKE
	elseif szCheckBoxName == "CheckBox_6" then
		self._nDevelopType = KnightTransformConst.DEVELOP_TYPE.GOD
	end

end

function KnightTransformPreviewLayer:_uncheckedCallBack()
	
end

function KnightTransformPreviewLayer:_initWidgets()
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseWindow))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onCloseWindow))
end

function KnightTransformPreviewLayer:_onCloseWindow()
	self:animationToClose()
end

function KnightTransformPreviewLayer:_initDevelopInfo(nIndex)
	local nOffsetX = 3
	local nOffsetY = -3

	local leftItem = require("app.scenes.knighttransform.KnightTransformDevelopItem1").create(nIndex, self._nSourceKnightId)
	local imgBoard = self:getImageViewByName("Image_Board"..nIndex)
	local size1 = imgBoard:getSize()
	local size2 = leftItem:getSize()
	local nSpaceX = (size1.width - 2 * size2.width) / 3
	local posX1 = - (nSpaceX/2 + size2.width) + nOffsetX
	local posY1 = - size2.height/2 + nOffsetY
	leftItem:setPosition(ccp(posX1, posY1))
	imgBoard:addNode(leftItem)

	local rightItem = require("app.scenes.knighttransform.KnightTransformDevelopItem1").create(nIndex, self._nSourceKnightId, self._nTargetKnightBaseId)
	local posX2 = nSpaceX/2 + 2
	local posY2 = - size2.height/2  + nOffsetY
	rightItem:setPosition(ccp(posX2, posY2))
	imgBoard:addNode(rightItem)
end

function KnightTransformPreviewLayer:_initAwakeInfo()
	local nOffsetX = 3
	local nOffsetY = -3

	local leftItem = require("app.scenes.knighttransform.KnightTransformDevelopItem2").create(KnightTransformConst.DEVELOP_TYPE.AWAKE, self._nSourceKnightId)
	local imgBoard = self:getImageViewByName("Image_Board5")
	local size1 = imgBoard:getSize()
	local size2 = leftItem:getSize()
	local nSpaceX = (size1.width - 2 * size2.width) / 3
	local posX1 = - (nSpaceX/2 + size2.width) + nOffsetX
	local posY1 = - size2.height/2 + nOffsetY
	leftItem:setPosition(ccp(posX1, posY1))
	imgBoard:addNode(leftItem)

	local rightItem = require("app.scenes.knighttransform.KnightTransformDevelopItem2").create(KnightTransformConst.DEVELOP_TYPE.AWAKE, self._nSourceKnightId, self._nTargetKnightBaseId)
	local posX2 = nSpaceX/2 + 2
	local posY2 = - size2.height/2 + nOffsetY
	rightItem:setPosition(ccp(posX2, posY2))
	imgBoard:addNode(rightItem)

end

return KnightTransformPreviewLayer