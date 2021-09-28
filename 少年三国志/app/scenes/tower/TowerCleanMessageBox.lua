--TowerCleanMessageBoxEx.lua


local TowerCleanMessageBoxEx = class ("TowerCleanMessageBoxEx", UFCCSMessageBox)

TowerCleanMessageBoxEx.CustomButton = {
	CustomButton_Default = 1,
	CustomButton_Pay = 2,
	CustomButton_MainDugeon = 3,
}

        
function TowerCleanMessageBoxEx:ctor( ... )
	self._richText = nil
	self._labelClr = ccc3(255, 255, 255)
	self._defaultTitle = nil
	self.super.ctor(self, ...)
	self:showAtCenter(true)
end

function TowerCleanMessageBoxEx:onLayerLoad( ... )
	self.super.onLayerLoad(self, ...)

	self:registerOkBtn("Button_ok")
	self:registerYesBtn("Button_yes")
	self:registerNoBtn("Button_no")

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

function TowerCleanMessageBoxEx:specialInit( time, floor )
	self:getWidgetByName("Label_content"):setVisible(false)
	self:getLabelByName("Label_des1"):setText(G_lang:get("LANG_TOWER_CLEANUP_TIME1"))
	self:getLabelByName("Label_des2"):setText(G_lang:get("LANG_TOWER_CLEANUP_TIME2"))
	self:getLabelByName("Label_des3"):setText(G_lang:get("LANG_TOWER_CLEANUP_TIME3"))
	self:getLabelByName("Label_time"):setText(time)
	self:getLabelByName("Label_floor"):setText(floor)
end

function TowerCleanMessageBoxEx:setCustomButton( customBtnId )
	customBtnId = customBtnId or MessageBoxEx.CustomButton.CustomButton_Default
	local btnPath, imgType = G_Path.getCustomButtonPath(customBtnId)
	local image = self:getImageViewByName("ImageView_yes")
	if image then
		image:loadTexture(btnPath, imgType)
	end
end

function TowerCleanMessageBoxEx:setContent( content )
	if self._richText ~= nil then
		self._richText:appendContent(content, self._labelClr)
		self._richText:reloadData()
	end
end

function TowerCleanMessageBoxEx:setTitle( title )
	if title then
		self.super.setTitle(self, title)
		if self._defaultTitle then
			self._defaultTitle:setVisible(false)
		end
	end
end

function TowerCleanMessageBoxEx.showOkMessage( title, content, sysMsg, handler, target )
	local msgbox = require("app.scenes.tower.TowerCleanMessageBox").new("ui_layout/tower_CleanMessageBox.json", Colors.modelColor)
	msgbox:setContent(content)
	msgbox:setTitle(title)
	msgbox:setOkCallback(handler, target)
	msgbox:show(true, sysMsg or false)
end

function TowerCleanMessageBoxEx.showYesNoMessage( title, content, sysMsg, yes_handler, no_handler, target )
	local msgbox = require("app.scenes.tower.TowerCleanMessageBox").new("ui_layout/tower_CleanMessageBox.json", Colors.modelColor)
	msgbox:setContent(content)
	msgbox:setTitle(title)
	msgbox:setYesCallback(yes_handler, target)
	msgbox:setNoCallback(no_handler, target)
	msgbox:show(false, sysMsg or false)
end

function TowerCleanMessageBoxEx.showSpecialMessage( title,time, floor, content, sysMsg, yes_handler, no_handler, target )
	local msgbox = require("app.scenes.tower.TowerCleanMessageBox").new("ui_layout/tower_CleanMessageBox.json", Colors.modelColor)
	msgbox:setContent(content)
	msgbox:setTitle(title)
	msgbox:setYesCallback(yes_handler, target)
	msgbox:setNoCallback(no_handler, target)
	msgbox:show(false, sysMsg or false)
	msgbox:specialInit(time,floor)
end

function TowerCleanMessageBoxEx.showCustomMessage( title, content, customBtnId, yes_handler, no_handler, target )
	local msgbox = require("app.scenes.tower.TowerCleanMessageBox").new("ui_layout/tower_CleanMessageBox.json", Colors.modelColor)
	msgbox:setContent(content)
	msgbox:setTitle(title)
	msgbox:setCustomButton(customBtnId)
	msgbox:setYesCallback(yes_handler, target)
	msgbox:setNoCallback(no_handler, target)
	msgbox:show(false, sysMsg or false)
end

return TowerCleanMessageBoxEx
