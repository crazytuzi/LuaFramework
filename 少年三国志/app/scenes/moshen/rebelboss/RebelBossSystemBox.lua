-- create a rich-text from a normal template label
local function createRichTextFromTemplate(template, parent, content, align)
	local posX, posY = template:getPositionX(), template:getPositionY()
    local anchorX, anchorY = template:getAnchorPointXY()
    local anchor
    local size = template:getSize()
    local richText = CCSRichText:create(size.width, size.height)
    richText:setFontName(template:getFontName())
    richText:setFontSize(template:getFontSize())
    richText:setPosition(ccp(posX, posY))
    richText:setAnchorPoint(ccp(anchorX, anchorY))
    richText:setShowTextFromTop(true)

    richText:appendContent(content, Colors.uiColors.WHITE)
    richText:setTextAlignment(align or kCCTextAlignmentCenter)
    richText:reloadData()
    parent:addChild(richText)

    return richText
end

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local RebelBossSystemBox = class("RebelBossSystemBox", UFCCSModelLayer)

function RebelBossSystemBox.show(nGroup, confirmCallback, cancelCallback, ...)
	local box = RebelBossSystemBox.new("ui_layout/moshen_RebelBossMessageBox.json", Colors.modelColor, nGroup, confirmCallback, cancelCallback, ...)
	uf_sceneManager:getCurScene():addChild(box)
	return box
end

function RebelBossSystemBox:ctor(json, param, nGroup, confirmCallback, cancelCallback, ...)
	self.super.ctor(self, json, param, ...)

	self._nGroup = nGroup
	self._confirmCallback = confirmCallback
	self._cancelCallback = cancelCallback

	self:_initWidgets()
end

function RebelBossSystemBox:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

function RebelBossSystemBox:onLayerExit()
	
end

function RebelBossSystemBox:_initWidgets()
	local tGroupTmpl = rebel_boss_buff_info.get(self._nGroup)
	assert(tGroupTmpl)

	local panelGroup = self:getPanelByName("Panel_JoinGroup")
	local labelGroup = self:getLabelByName("Label_JoinGroup")
	local content = GlobalFunc.formatText(G_lang:get("LANG_REBEL_BOSS_JOIN_GROUP_TIP"),
											  {
											   group = tGroupTmpl.name,
											   desc = tGroupTmpl.tips .. "%" --前面一句话最后一个字符是%，所以要多加一个%
											  })
	createRichTextFromTemplate(labelGroup, panelGroup, content)
	
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onConfirm))
	self:registerBtnClickEvent("Button_Cancel", handler(self, self._onCancel))
end

function RebelBossSystemBox:_onConfirm(sender)
	if self._confirmCallback then
        self._confirmCallback()
        self:animationToClose()
	end
end

function RebelBossSystemBox:_onCancel(sender)
	if self._cancelCallback then
        self._cancelCallback()
        self:animationToClose()
	end
end


return RebelBossSystemBox