--MessageBoxEx.lua


local MessageBoxEx = class ("MessageBoxEx", UFCCSMessageBox)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

MessageBoxEx.CustomButton = {
	CustomButton_Default = 1,
	CustomButton_Pay = 2,
	CustomButton_MainDugeon = 3,
}

MessageBoxEx.OKNOButton = {
	OKNOBtn_Default = 1,
	OKNOBtn_Vip = 2,
	OKNOBtn_Richman = 3,
}
        
function MessageBoxEx:ctor( ... )
	self._richText = nil
	self._labelClr = ccc3(255, 255, 255)
	self._defaultTitle = nil
	self.super.ctor(self, ...)

	self:showAtCenter(true)
end

function MessageBoxEx:onLayerEnter( ... )
	self:registerKeypadEvent(true, false)
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_back"), "smoving_bounce")
end

function MessageBoxEx:onBackKeyEvent( ... )
    return true
end

function MessageBoxEx:onLayerLoad( ... )
	self.super.onLayerLoad(self, ...)

	self:registerOkBtn("Button_ok")
	self:registerYesBtn("Button_yes")
	self:registerNoBtn("Button_no")

	self:registerTitleLabel("Label_title")
	self:registerContentLabel("Label_content")

	self._defaultTitle = self:getWidgetByName("ImageView_title")

	local label = self:getLabelByName("Label_content")
	local size = label:getSize()
	local clr = label:getColor()
	self._labelClr = ccc3(clr.r, clr.g, clr.b)
	self._richText = CCSRichText:create(size.width, size.height)
	self._richText:setFontName(label:getFontName())
	self._richText:setFontSize(label:getFontSize())
	local x, y = label:getPosition()
	self._richText:setPosition(ccp(x, y))
	self._richText:setShowTextFromTop(true)
	self._richText:setTextAlignment(kCCTextAlignmentCenter)
	--local parent = label:getParent()
	local parent = self:getWidgetByName("ImageView_back")
	if parent then
		parent:addChild(self._richText, 5)
	end

	-- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
	-- if appstoreVersion or IS_HEXIE_VERSION  then 
	-- 	local img = self:getImageViewByName("Image_mm")
	-- 	if img then
	-- 		img:loadTexture("ui/arena/xiaozhushou_hexie.png")
	-- 	end
	-- end
	GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_mm"))
end

function MessageBoxEx:setCustomButton( customBtnId )
	customBtnId = customBtnId or MessageBoxEx.CustomButton.CustomButton_Default
	local btnPath, imgType = G_Path.getCustomButtonPath(customBtnId)
	local image = self:getImageViewByName("ImageView_yes")
	if image then
		image:loadTexture(btnPath, imgType)
	end
end

function MessageBoxEx:setOKNOButton( OKNOBtnId )
	OKNOBtnId = OKNOBtnId or MessageBoxEx.OKNOButton.OKNOBtn_Default
	local OKbtnPath,NObtnPath, imgType = G_Path.getOKNOButtonPath(OKNOBtnId)
	local okimage = self:getImageViewByName("ImageView_yes")
	local noimage = self:getImageViewByName("ImageView_no")
	if okimage then
		okimage:loadTexture(OKbtnPath, imgType)
	end
	if noimage then
		noimage:loadTexture(NObtnPath, imgType)
	end
end

function MessageBoxEx:setContent( content )
	if self._richText ~= nil then
		self._richText:appendContent(content, self._labelClr)
		self._richText:reloadData()
	end
end

function MessageBoxEx:setTitle( title )
	if title then
		self.super.setTitle(self, title)
		if self._defaultTitle then
			self._defaultTitle:setVisible(false)
		end
	end
end

function MessageBoxEx:onClickClose( ... )
	if self._clickImg then 
		self._clickImg:setVisible(false)
	end

	return false
end

function MessageBoxEx:showClickCloseFlag( ... )
	if self._clickImg then
		return 
	end

	self._clickImg = ImageView:create()
	self._clickImg:loadTexture("ui/text/txt/dianjijixu.png", UI_TEX_TYPE_LOCAL)
	self:addChild(self._clickImg)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local size = self:getSize()

	self._clickImg:setPosition(ccp(winSize.width/2, winSize.height/2 - size.height/2 - 30))
	self:setClickClose(true)
	EffectSingleMoving.run(self._clickImg, "smoving_wait", nil , {position = true} )
end

function MessageBoxEx.showOkMessage( title, content, sysMsg, handler, target )
	local msgbox = MessageBoxEx.new("ui_layout/common_NewMessageBox.json", Colors.modelColor)
	msgbox:setContent(content)
	msgbox:setTitle(title)
	msgbox:setOkCallback(handler, target)
	msgbox:show(true, sysMsg or false)
end

function MessageBoxEx.showYesNoMessage( title, content, sysMsg, yes_handler, no_handler, target ,OKNOBtnId)
	local msgbox = MessageBoxEx.new("ui_layout/common_NewMessageBox.json", Colors.modelColor)
	msgbox:setContent(content)
	msgbox:setTitle(title)
	msgbox:setOKNOButton(OKNOBtnId)
	msgbox:setYesCallback(yes_handler, target)
	msgbox:setNoCallback(no_handler, target)
	msgbox:show(false, sysMsg or false)
end

function MessageBoxEx.showCustomMessage( title, content, customBtnId, yes_handler, no_handler, target )
	local msgbox = MessageBoxEx.new("ui_layout/common_NewMessageBox.json", Colors.modelColor)
	msgbox:setContent(content)
	msgbox:setTitle(title)
	msgbox:setCustomButton(customBtnId)
	msgbox:setYesCallback(yes_handler, target)
	msgbox:setNoCallback(no_handler, target)
	msgbox:show(false, sysMsg or false)
end

function MessageBoxEx.showSellTip( title, content, yes_handler, no_handler, target )
	local msgbox = MessageBoxEx.new("ui_layout/common_SellKnightAndEquip.json", Colors.modelColor)
	msgbox:setContent(content)
	msgbox:setTitle(title)
	msgbox:setYesCallback(yes_handler, target)
	msgbox:setNoCallback(no_handler, target)

	msgbox:show(false, sysMsg or false)

	msgbox:showClickCloseFlag()

	-- 出售碎片时不出售就按钮文字需要变一下
	if not no_handler then
		msgbox:getImageViewByName("ImageView_5335"):loadTexture("ui/text/txt-middle-btn/zaixiangxiang.png")
	end

	-- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
	-- if appstoreVersion or IS_HEXIE_VERSION  then 
	-- 	local img = msgbox:getImageViewByName("Image_23")
	-- 	if img then
	-- 		img:loadTexture("ui/arena/xiaozhushou_hexie.png")
	-- 	end
	-- end
	GlobalFunc.replaceForAppVersion(msgbox:getImageViewByName("Image_23"))
end

return MessageBoxEx
