
local UIBase = require "ui/common/UIBase"
local UILabel = require "ui/common/UILabel"
local UIRichText = require "ui/common/UIRichText"
local UIImage = require "ui/common/UIImage"
local UICooler = require "ui/common/UICooler"
local UIButton = require "ui/common/UIButton"
local UILoadingBar = require "ui/common/UILoadingBar"
local UIScrollList = require "ui/common/UIScrollList"
local UIScrollView = require "ui/common/UIScrollView"
local UIEditBox = require "ui/common/UIEditBox"
local UISlider = require "ui/common/UISlider"
local UISprite3D = require "ui/common/UISprite3D"
local CCParticle = require "ui/common/CCParticle"
local UICanvas = require "ui/common/UICanvas"
local UIFrameAni = require "ui/common/UIFrameAni"
local UIClipnode = require "ui/common/UIClipnode"
local UIMutiTouch = require "ui/common/UIMutiTouch"
local UIImageLite = require "ui/common/UIImageLite"
local UIFactory = { }

local uiTable = {
	Label = UILabel,
	RichText = UIRichText,
	Button = UIButton,
	Image = UIImage,
	ImageOptim = UIImage,
	ImageLite = UIImageLite,
	LoadingBar = UILoadingBar,
	Scroll = UIScrollList,
	ScrollView= UIScrollView,
	EditBox = UIEditBox,
	Slider = UISlider,
	Sprite3D = UISprite3D,
	Particle = CCParticle,
	Canvas = UICanvas,
	FrameAni = UIFrameAni,
	ProgressTimer = UICooler,
	Clipnode = UIClipnode,
	MutiTouch = UIMutiTouch,
}

function UIFactory.createUI(ccNode, propConfig)
    local cls = uiTable[propConfig.etype]
	if not cls then
		return UIBase.new(ccNode, propConfig)
	end
	return cls.new(ccNode, propConfig)
end

return UIFactory
