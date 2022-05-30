local CardLayer = class("CardLayer", function()
	return require("utility.ShadeLayer").new()
end)
function CardLayer:ctor(heroInfo)
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("shop/hero_card2.ccbi", proxy, rootnode)
	node:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	self:addChild(node, 100)
	dump(rootnode)
	local okBtn = require("utility.CommonButton").new({
	img = "#com_btn_large_red.png",
	listener = function()
		self:removeSelf()
	end
	})
	okBtn:setPosition(node:getContentSize().width * 0.8, node:getContentSize().height * 0.1)
	node:addChild(okBtn)
end

return CardLayer