--TreasureExpMessage.lua

local TreasureExpMessage = class ("TreasureExpMessage", UFCCSMessageBox)

TreasureExpMessage.CustomButton = {
	CustomButton_Default = 1,
	CustomButton_Pay = 2,
	CustomButton_MainDugeon = 3,
}

        
function TreasureExpMessage:ctor( ... )
	self._richText = nil
	self._labelClr = ccc3(255, 255, 255)
	self._defaultTitle = nil
	self.super.ctor(self, ...)
end

function TreasureExpMessage:onLayerLoad( ... )
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
	local parent = label:getParent()
	if parent then
		parent:addChild(self._richText, 5)
	end
end

function TreasureExpMessage:onLayerEnter( ... )
	self:showAtCenter(true)
end

function TreasureExpMessage:setCustomButton( customBtnId )
	customBtnId = customBtnId or TreasureExpMessage.CustomButton.CustomButton_Default
	local btnPath, imgType = G_Path.getCustomButtonPath(customBtnId)
	local image = self:getImageViewByName("ImageView_yes")
	if image then
		image:loadTexture(btnPath, imgType)
	end
end

function TreasureExpMessage:setContent( content )
	if self._richText ~= nil then
		self._richText:appendContent(content, self._labelClr)
		self._richText:reloadData()
	end
end

function TreasureExpMessage:setTitle( title )
	if title then
		self.super.setTitle(self, title)
		if self._defaultTitle then
			self._defaultTitle:setVisible(false)
		end
	end
end

function TreasureExpMessage.showYesNoMessage( title, expNeed,expGet,content, sysMsg, yes_handler, no_handler, target )
	local msgbox = TreasureExpMessage.new("ui_layout/treasure_TreasureExpMessage.json", Colors.modelColor)
	msgbox:setContent(content)
	msgbox:setTitle(title)
	msgbox:setYesCallback(yes_handler, target)
	msgbox:setNoCallback(no_handler, target)

	msgbox:getLabelByName("Label_expNeedTxt"):setText(G_lang:get("LANG_STREAGTH_NEED_EXP"))
	msgbox:getLabelByName("Label_expGetTxt"):setText(G_lang:get("LANG_STREAGTH_CURRENT_EXP"))
	msgbox:getLabelByName("Label_expNeed"):setText(""..expNeed)
	msgbox:getLabelByName("Label_expGet"):setText(""..expGet)

	msgbox:show(false, sysMsg or false)
end

return TreasureExpMessage

