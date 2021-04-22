
local QELoginScene = class("QELoginScene", function()
    return display.newScene("QELoginScene")
end)

local QESkeletonViewer = import(".QESkeletonViewer")

local textFieldWidth = 360
local textFieldHeight = 60
local textFieldOffsetX = 80
local textFieldOffsetY = 8
local loginButtonWidth = 160
local loginButtonHeight = 60

function QELoginScene:ctor(options)
	-- background
	self._root = CCLayerColor:create(ccc4(128, 128, 128, 255), display.width, display.height)
	self:addChild(self._root)

    self._layerBottom = CCNode:create()
    self._root:addChild(self._layerBottom)
    self._layerBottom:setPosition(0, 0)

    self._menu = CCMenu:create();
    self._root:addChild(self._menu)
    self._menu:setPosition(0, 0)

    self._layerTop = CCNode:create()
    self._root:addChild(self._layerTop)
    self._layerTop:setPosition(0, 0)

	-- address text field
	self._addressColorLayer = CCLayerColor:create(display.COLOR_WHITE_C4, textFieldWidth, textFieldHeight)
	self._layerBottom:addChild(self._addressColorLayer)
	self._addressColorLayer:setPosition(display.cx - textFieldWidth * 0.5 - textFieldOffsetX, display.cy + textFieldOffsetY)
	self._addressColorLayer:setOpacity(0)

	self._addressEditBox = ui.newEditBox( {
        image = "ui/none.png",
        listener = handler(self, QELoginScene.onAddressEdit),
        size = CCSize(textFieldWidth - 5, textFieldHeight)} )
	self._layerTop:addChild(self._addressEditBox)
	self._addressEditBox:setFontColor(display.COLOR_MAGENTA)
	self._addressEditBox:setPosition(display.cx - textFieldOffsetX + 5, display.cy + textFieldHeight * 0.5)
	self._addressEditBox:setEnabled(false)
	self._addressEditBox:setText("127.0.0.1")
    self._addressEditBox:setFont(global.font_name, 26)

    -- connect menu
    self._loginColorLayer = CCLayerColor:create(display.COLOR_ORANGE_C4, loginButtonWidth, loginButtonHeight)
    self._layerBottom:addChild(self._loginColorLayer)
    self._loginColorLayer:setPosition(display.cx + textFieldWidth * 0.3 + 10, display.cy + textFieldOffsetY)
    self._loginColorLayer:setOpacity(0)

	self._loginButton = ui.newTTFLabelMenuItem( {
		text = "Connect",
		font = global.font_monaco,
		size = 30,
		listener = handler(self, QELoginScene.onLogin),
		} )
	self._menu:addChild(self._loginButton)
	self._loginButton:setPosition(display.cx + textFieldWidth * 0.5 + 20, display.cy + loginButtonHeight * 0.5 + 5)
	self._loginButton:setEnabled(false)

    -- effect view
    self._effectColorLayer = CCLayerColor:create(display.COLOR_ORANGE_C4, loginButtonWidth, loginButtonHeight)
    self._layerBottom:addChild(self._effectColorLayer)
    self._effectColorLayer:setPosition(display.cx - loginButtonWidth * 0.5, display.cy - loginButtonHeight * 1.2)
    self._effectColorLayer:setOpacity(0)

    self._effectButton = ui.newTTFLabelMenuItem( {
        text = "Effect",
        font = global.font_monaco,
        size = 30,
        listener = handler(self, QELoginScene.onEffectClick),
        } )
    self._menu:addChild(self._effectButton)
    self._effectButton:setPosition(display.cx, display.cy - loginButtonHeight * 0.75)
    self._effectButton:setEnabled(false)

    -- animation view
    self._animationColorLayer = CCLayerColor:create(display.COLOR_ORANGE_C4, loginButtonWidth, loginButtonHeight)
    self._layerBottom:addChild(self._animationColorLayer)
    self._animationColorLayer:setPosition(display.cx - loginButtonWidth * 0.5, display.cy - loginButtonHeight * 1.2 - 100)
    self._animationColorLayer:setOpacity(0)

    self._animationButton = ui.newTTFLabelMenuItem( {
        text = "Animation",
        font = global.font_monaco,
        size = 30,
        listener = handler(self, QELoginScene.onAnimationClick),
        } )
    self._menu:addChild(self._animationButton)
    self._animationButton:setPosition(display.cx, display.cy - loginButtonHeight * 0.75 - 100)
    self._animationButton:setEnabled(false)

    -- prologue view
    -- self._prologueColorLayer = CCLayerColor:create(display.COLOR_ORANGE_C4, loginButtonWidth, loginButtonHeight)
    -- self._layerBottom:addChild(self._prologueColorLayer)
    -- self._prologueColorLayer:setPosition(display.cx - loginButtonWidth * 0.5, display.cy - loginButtonHeight * 1.2 - 200)
    -- self._prologueColorLayer:setOpacity(0)

    -- self._prologueButton = ui.newTTFLabelMenuItem( {
    --     text = "Prologue",
    --     font = global.font_monaco,
    --     size = 30,
    --     listener = handler(self, QELoginScene.onPrologueClick),
    --     } )
    -- self._menu:addChild(self._prologueButton)
    -- self._prologueButton:setPosition(display.cx, display.cy - loginButtonHeight * 0.75 - 200)
    -- self._prologueButton:setEnabled(false)

    self._easyEffectEditorColorLayer = CCLayerColor:create(display.COLOR_ORANGE_C4, loginButtonWidth, loginButtonHeight)
    self._layerBottom:addChild(self._easyEffectEditorColorLayer)
    self._easyEffectEditorColorLayer:setPosition(display.cx - loginButtonWidth * 0.5, display.cy - loginButtonHeight * 1.2 - 200)
    self._easyEffectEditorColorLayer:setOpacity(0)

    self._easyEffectEditorButton = ui.newTTFLabelMenuItem( {
        text = "easyEffectEditor",
        font = global.font_monaco,
        size = 30,
        listener = handler(self, QELoginScene.onEasyEffectEditorClick),
        } )
    self._menu:addChild(self._easyEffectEditorButton)
    self._easyEffectEditorButton:setPosition(display.cx, display.cy - loginButtonHeight * 0.75 - 200)
    self._easyEffectEditorButton:setEnabled(false)

	-- connect error info
	self._loginFaildInfo = ui.newTTFLabel( {
		text = "",
		font = global.font_monaco,
		size = 35,
		color = display.COLOR_GREEN,
		} )
	self._layerTop:addChild(self._loginFaildInfo)
	self._loginFaildInfo:setPosition(display.cx, display.cy - 50)

	-- connect animation
	local ccbFile = "ccb/Widget_Loading.ccbi"
	local ccbOwner = {}
	local proxy = CCBProxy:create()
    self._loadingView = CCBuilderReaderLoad(ccbFile, proxy, ccbOwner)
    self._layerTop:addChild(self._loadingView)
    self._loadingView:setPosition(display.cx, display.cy - 60)
    self._loadingView:setVisible(false)
end

function QELoginScene:onEnter()
	-- enter with fade in 
	local fadeInTime = 0.6
	self._addressColorLayer:runAction(CCFadeIn:create(fadeInTime))
	self._loginColorLayer:runAction(CCFadeIn:create(fadeInTime))
	self._addressEditBox:runAction(CCFadeIn:create(fadeInTime))
    self._effectColorLayer:runAction(CCFadeIn:create(fadeInTime))
    self._animationColorLayer:runAction(CCFadeIn:create(fadeInTime))
    -- self._prologueColorLayer:runAction(CCFadeIn:create(fadeInTime))
    self._easyEffectEditorColorLayer:runAction(CCFadeIn:create(fadeInTime))

	scheduler.performWithDelayGlobal(function()
        self._addressEditBox:setEnabled(true)
        self._loginButton:setEnabled(true)
        self._effectButton:setEnabled(true)
        self._animationButton:setEnabled(true)
        -- self._prologueButton:setEnabled(true)
        self._easyEffectEditorButton:setEnabled(true)
    end, 1)
end

function QELoginScene:onExit()

end

function QELoginScene:onAddressEdit(editbox)
    
end

function QELoginScene:onLogin(tag)
	local host = self._addressEditBox:getText()
	if host == nil or string.len(host) == 0 then
		return
	end

	scheduler.performWithDelayGlobal(function()
		app.editor:connect(host, handler(self, self.onConnectCallBack))
    end, 0.6)

    self._loadingView:setVisible(true)
    self._addressEditBox:setEnabled(false)
    self._loginButton:setEnabled(false)
    self._loginFaildInfo:stopAllActions()
    self._loginFaildInfo:runAction(CCFadeOut:create(0))
end

function QELoginScene:onConnectCallBack(isSuccess)
	self._loginButton:setEnabled(true)
	self._addressEditBox:setEnabled(true)
	self._loadingView:setVisible(false)

	if isSuccess == true then
		app.editor:onConnect()
	else
		self._loginFaildInfo:stopAllActions()
		self._loginFaildInfo:setString("cannot connect server: " .. self._addressEditBox:getText())

		local arr = CCArray:create()
        arr:addObject(CCFadeIn:create(0.01))
        arr:addObject(CCDelayTime:create(2.5))
        arr:addObject(CCFadeOut:create(1.5))
        self._loginFaildInfo:runAction(CCSequence:create(arr))
	end
end

function QELoginScene:onEffectClick()
    app.editor:onDisplayBrowerScene("effect")
end

function QELoginScene:onAnimationClick()
	app.editor:onDisplayBrowerScene("animation")
end

function QELoginScene:onPrologueClick()
    app.editor:onDisplayBrowerScene("prologue")
end

function QELoginScene:onEasyEffectEditorClick()
    app.editor:onDisplayBrowerScene("easy_effect_editor")
end

return QELoginScene