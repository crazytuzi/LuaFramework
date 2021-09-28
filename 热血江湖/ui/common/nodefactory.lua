
local UIDefault = require "ui/common/DefaultValue"

local UICommon = require "ui/common/UICommon"

local NodeFactory = { }

local NodeLayer = {}
local NodeGrid = {}
local NodeLabel = require "ui/common/NodeLabel"
local NodeRichText = require "ui/common/NodeRichText"
local NodeButton = {}
local NodeImage = {}
local NodeImageOptim = {}
local NodeImageLite = {}
local NodeLoadingBar = {}
local NodeScroll = {}
local NodeEditBox = {}
local NodeSlider = {}
local NodeSprite3D = {}
local NodeParticle = require "ui/common/NodeParticle"
local NodeCanvas = {}
local NodeFrameAni = require "ui/common/NodeFrameAni"
local NodeCooler = {}
local NodeClipnode = {}
local NodeMutiTouch = {}

function ccui.Widget:setEnableControl(enable)
end

function cc.Layer:setEnableControl(enable)
end

function cc.Layer:setEnabled(enable)
end

function cc.ClippingNode:setEnableControl(enable)
end

function cc.ClippingNode:setEnabled(enable)
end

function cc.ParticleSystemQuad:setEnableControl(enable)
end

function cc.ParticleSystemQuad:setEnabled(enable)
end

function ccui.Button:setEnableControl(enable)
	self:setBright(enable)
end

function ccui.ImageView:setEnableControl(enable)
	self:setColorState(enable and UI_COLOR_STATE_NORMAL or UI_COLOR_STATE_GRAY)
end

----------------------------------------------------------------------------------------------

function ccui.Widget:initSizeAndPosition(prop)
	local x = prop.posX or 0
	local y = prop.posY or 0
	local sizeX = prop.sizeX or 0
	local sizeY = prop.sizeY or 0
	
	self:setSizeType(ccui.SizeType.percent)
	self:setSizePercent(cc.p(sizeX, sizeY))
	self:setPositionType(ccui.PositionType.percent)
	self:setPositionPercent(cc.p(x, y))
	self:ignoreContentAdaptWithSize(false)

	if prop.alphaCascade then
		self:setCascadeOpacityEnabled(true)
	end

	if prop.alpha then
		local opacity = prop.alpha * 255
		if opacity > 255 then opacity = 255 end
		if opacity < 0 then opacity = 0 end
		self:setOpacity(opacity)
	end
end

function cc.Layer:initSizeAndPosition(prop)
	self:setNormalizedPosition(cc.p(prop.posX or 0, prop.posY or 0))
end

function cc.ClippingNode:initSizeAndPosition(prop)
	self:setNormalizedPosition(cc.p(prop.posX or 0, prop.posY or 0))
end

----------------------------------------------------------------------------------------------

function ccui.Widget:initialize(prop)
end

function cc.Layer:initialize(prop)
end

function cc.ClippingNode:initialize(prop)
end

local function calcScal9Rect(prop, rc)
	local sc9Left = prop.scale9Left or 0
	local sc9Right = prop.scale9Right or 0
	local sc9Top = prop.scale9Top or 0
	local sc9Bottom = prop.scale9Bottom or 0
	prop.scale9Rect = cc.rect(rc.width * sc9Left, rc.height * sc9Top, rc.width * ( 1 - sc9Left - sc9Right), rc.height * ( 1- sc9Top - sc9Bottom))
end

local function ImageLoadingBarInitialize(self, prop)
	if prop.scale9 then
		self:setScale9Enabled(true)
		local rc = self:getContentSize()
		calcScal9Rect(prop, rc)
		self:setCapInsets(prop.scale9Rect)
	end
end

ccui.ImageView.initialize = ImageLoadingBarInitialize
ccui.LoadingBar.initialize = ImageLoadingBarInitialize

function ccui.Slider:initialize(prop)
	if prop.scale9 then
		self:setScale9Enabled(true)
		local rc = self:getVirtualRendererSize()
		calcScal9Rect(prop, rc)
		self:setCapInsetsBarRenderer(prop.scale9Rect)
	end
end

function ccui.ProgressTimer:initialize(prop)
	local pro = self:getVirtualRenderer()
	if pro then
		pro:setType(prop.progressType or 0)
		pro:setReverseDirection(prop.reverse or false)
		pro:setPercentage(prop.percent or 100)
	end
end

function ccui.Button:initialize(prop)
	if prop.scale9 then
		self:setScale9Enabled(true)
		local rc = self:getVirtualRendererSize()
		calcScal9Rect(prop, rc)
		self:setCapInsets(prop.scale9Rect)
	end
end

----------------------------------------------------------------------------------------------

function NodeLayer.createNode(prop)
	local nodeCreate = cc.Layer:create()
	nodeCreate.soundEffectOpen = prop.soundEffectOpen
	nodeCreate.closeAfterOpenAni = prop.closeAfterOpenAni
	return nodeCreate
end

function NodeGrid.createNode(prop)
	return ccui.Widget:create()
end

function NodeCanvas.createNode(prop)
	local nodeCreate = ccui.Canvas:create()
	nodeCreate:setFillColor(UICommon.getColorC4BByStr(prop.fillColor or UIDefault.DefCanvas.fillColor))
	nodeCreate:setLineColor(UICommon.getColorC4BByStr(prop.lineColor or UIDefault.DefCanvas.lineColor))
	nodeCreate:setFloatParam(0, prop.p1 or UIDefault.DefCanvas.scale)
	nodeCreate:setFloatParam(1, prop.p2 or UIDefault.DefCanvas.scale)
	nodeCreate:setFloatParam(2, prop.p3 or UIDefault.DefCanvas.scale)
	nodeCreate:setFloatParam(3, prop.p4 or UIDefault.DefCanvas.scale)
	nodeCreate:setFloatParam(4, prop.p5 or UIDefault.DefCanvas.scale)
	nodeCreate:setFloatParam(5, prop.p6 or UIDefault.DefCanvas.scale)
	local angle = prop.angle or UIDefault.DefCanvas.angle;
	nodeCreate:setAngle(angle)
	nodeCreate:setDrawType(prop.drawType or UIDefault.DefCanvas.drawType)
	return nodeCreate
end

function NodeMutiTouch.createNode(prop)
	return ccui.MTouchWidget:create()
end

local function setNodeImage(prop, nodeCreate)
	if prop.flippedX then
		nodeCreate:getVirtualRenderer():setFlippedX(true)
	end
	if prop.flippedY then
		nodeCreate:getVirtualRenderer():setFlippedY(true)
	end
	if prop.rotation or prop.rotationX or prop.rotationY then
		nodeCreate:setRotation3D(cc.vec3(prop.rotationX or 0, prop.rotationY or 0, prop.rotation or 0))
	end
	if prop.blendFunc and prop.blendFunc == 1 then
		nodeCreate:setBlendAdditive(true)
	end
end

function NodeImage.createNode(prop)
	prop.filename, prop.texType = i3k_checkPList(prop.image or UIDefault.DefImage.image)
	prop.cache_time = g_i3k_last_clear_ui_tex_cache_time;--i3k_game_get_logic_tick()
	if prop.isLite then
		prop.etype = "ImageLite"
		return NodeImageLite.createNode(prop)
	else
		prop.etype = "ImageOptim"
		return NodeImageOptim.createNode(prop)
	end
end

function NodeImageOptim.createNode(prop)
	if prop.cache_time < g_i3k_last_clear_ui_tex_cache_time then
		return NodeImage.createNode(prop)
	end
	local nodeCreate = ccui.ImageView:create(prop.filename, prop.texType)
	setNodeImage(prop, nodeCreate)
	return nodeCreate
end

function NodeImageLite.createNode(prop)
	if prop.cache_time < g_i3k_last_clear_ui_tex_cache_time then
		return NodeImage.createNode(prop)
	end
	prop._ccParent:addScale9SpriteChild(prop);
	return 1
end


function NodeCooler.createNode(prop)
	return ccui.ProgressTimer:create(i3k_checkPList(prop.image or UIDefault.DefProgressTimer.image))
end

function NodeLoadingBar.createNode(prop)
	local img, imgt = i3k_checkPList(prop.image or UIDefault.DefLoadingBar.image)
	return ccui.LoadingBar:create(img, imgt, prop.percent or UIDefault.DefLoadingBar.percent, prop.barDirection or UIDefault.DefLoadingBar.barDirection)
end

function NodeEditBox.createNode(prop)
	local nodeCreate = ccui.EditBox:create(cc.size(prop.sizeXAB or UIDefault.DefEditBox.sizeXAB, prop.sizeYAB or UIDefault.DefEditBox.sizeYAB), prop.image or UIDefault.DefEditBox.image--[[ccui.Scale9Sprite:create()]])
	if prop.phText then
		nodeCreate:setPlaceHolder(prop.phText)
	end
	nodeCreate:setInputMode(6) --默认是single line
	local color = prop.phColor or UIDefault.DefEditBox.color
	nodeCreate:setPlaceholderFontColor(UICommon.getColorC4BByStr(color))
	local fontName = prop.phFontName or UIDefault.DefEditBox.fontName
	local fontSize = prop.phFontSize or UIDefault.DefEditBox.fontSize
	nodeCreate:setPlaceholderFont(fontName, fontSize)
	color = prop.color or UIDefault.DefEditBox.color
	nodeCreate:setFontColor(UICommon.getColorC3BByStr(color))
	if prop.text then
		nodeCreate:setText(prop.text)
	end
	if prop.fontSize then
		nodeCreate:setFontSize(prop.fontSize)
	end
	--nodeCreate:setFontName("fzy4k")
	if prop.fontName then
		nodeCreate:setFontName(prop.fontName)
	end
	if prop.autoWrap == false then
		nodeCreate:setAutoWrap(false)
	end
	nodeCreate:setTextVerticalAlignment(prop.vTextAlign or UIDefault.DefLabelRichText.vTextAlign)
	return nodeCreate
end

function NodeButton.createNode(prop)
	local nodeCreate = ccui.Button:create("")
	nodeCreate:loadTextureNormal(i3k_checkPList(prop.imageNormal or UIDefault.DefButton.imageNormal))
	if prop.imagePressed then
		nodeCreate:loadTexturePressed(i3k_checkPList(prop.imagePressed or UIDefault.DefButton.imagePressed))
	end
	if prop.imageDisable then
		nodeCreate:loadTextureDisabled(i3k_checkPList(prop.imageDisable or UIDefault.DefButton.imageDisable))
	end
	if prop.propagateToChildren then
		nodeCreate:setPropagateTouchEventsToChildren(true)
	end
	if prop.disableClick then
		nodeCreate:setTouchEnabled(false)
	end
	if prop.flippedX then
		nodeCreate:setRendererFlippedX(true)
	end
	if prop.flippedY then
		nodeCreate:setRendererFlippedY(true)
	end
	return nodeCreate
end

function NodeScroll.createNode(prop)
	local nodeCreate = ccui.ScrollView:create()
	if prop.horizontal then
		nodeCreate:setDirection(0)
	end
	return nodeCreate
end

function NodeSprite3D.createNode(prop)
	return ccui.Sprite3D:create()
end

function NodeSlider.createNode(prop)
	local nodeCreate = ccui.Slider:create()
	nodeCreate:loadBarTexture(i3k_checkPList(prop.imageBar or UIDefault.DefSlider.imageBar))
	nodeCreate:loadSlidBallTextureNormal(i3k_checkPList(prop.imageBallNormal or UIDefault.DefSlider.imageBallNormal))
	if prop.imageBallPressed then
		nodeCreate:loadSlidBallTexturePressed(i3k_checkPList(prop.imageBallPressed))
	end
	if prop.imageBarDisable then
		nodeCreate:loadSlidBallTextureDisabled(i3k_checkPList(prop.imageBarDisable))
	end
	nodeCreate:setPercent(prop.percent or 1)
	return nodeCreate
end

function NodeClipnode.createNode(prop)
	local nodeCreate = cc.ClippingNode:create()
	return nodeCreate
end

----------------------------------------------------------------------------------------------

local nodeTable = {
	Layer = NodeLayer,
	Grid = NodeGrid,
	Label = NodeLabel,
	RichText = NodeRichText,
	Button = NodeButton,
	Image = NodeImage,
	ImageOptim = NodeImageOptim,
	ImageLite = NodeImageLite,
	LoadingBar = NodeLoadingBar,
	Scroll = NodeScroll,	--Scroll和ScrollView是同一个ccNode类
	ScrollView= NodeScroll,
	EditBox = NodeEditBox,
	Slider = NodeSlider,
	Sprite3D = NodeSprite3D,
	Particle = NodeParticle,
	Canvas = NodeCanvas,
	FrameAni = NodeFrameAni,
	ProgressTimer = NodeCooler,
	Clipnode = NodeClipnode,
	MutiTouch = NodeMutiTouch,
}

function NodeFactory.createNode(propConfig)
    local factory = nodeTable[propConfig.etype]
	if not factory then
		return nil
	end
	return factory.createNode(propConfig)
end

return NodeFactory
