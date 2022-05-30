local data_config_config = require("data.data_config_config")

local CardObj = class("CardObj", function()
	local proxy = CCBProxy:create()
	local rootnode = {}
	local bg = CCBuilderReaderLoad("formation/formation_cardobj.ccbi", proxy, rootnode)
	bg._rootnode = rootnode
	return bg
end)

function CardObj:ctor(param)
	local _id = param.id
	local _cls = param.cls
	local _lv = param.lv
	local _star = param.star or 1
	function self.getLv()
		return _lv
	end
	self:setDisplayFrame(display.newSpriteFrame(string.format("zhenxing_card_%d.png", tostring(ResMgr.getCardData(_id).star[_cls + 1]))))
	for i = 1, 5 do
		if _star >= i then
			self._rootnode[string.format("star%d", i)]:setVisible(true)
		else
			self._rootnode[string.format("star%d", i)]:setVisible(false)
		end
	end
	local sprite = ResMgr.getHeroMidImage(_id, _cls, param.fashionId)
	sprite:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2 + data_config_config[1].zhenxingoffy)
	self:addChild(sprite)
	local card = ResMgr.getCardData(_id)
	function self.getResId(_)
		return _id
	end
	function self.getName(_)
		return card.name
	end
	function self.getCls(_)
		return _cls
	end
	function self.getStar(_)
		return _star
	end
end

return CardObj