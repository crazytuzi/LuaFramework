local data_card_card = require("data.data_card_card")

local FormZhuZhenItem = class("FormZhuZhenItem", function()
	return display.newNode()
end)

function FormZhuZhenItem:getContentSize()
	return cc.size(320, 320)
end

function FormZhuZhenItem:ctor(param)
	local cellPath = "formation/formation_zhuzhen_item.ccbi"
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad(cellPath, proxy, self._rootnode)
	node:setPosition(0, 0)
	self:addChild(node)
	local pageData = param.itemData
	self:refresh(pageData)
end

function FormZhuZhenItem:setHeroImgBg(imgName)
	imgName = imgName or "ui/ui_empty.png"
	if imgName ~= self.heroImgName then
		self.heroImgName = imgName
		self._rootnode.zhuZhen_ItemIcon:setDisplayFrame(display.newSprite(self.heroImgName):getDisplayFrame())
	end
	--self._rootnode.itemNode:setContentSize(self._rootnode.zhuZhen_ItemIcon_node:getContentSize())
	self._rootnode.zhuZhen_ItemIcon_node:setVisible(true)
end

function FormZhuZhenItem:getTouchNode()
	return self._rootnode.touchNode
end

function FormZhuZhenItem:refresh(pageData)
	self._rootnode.zhuZhen_ItemLabel_1:setVisible(false)
	self._rootnode.zhuZhen_ItemLabel_2:setVisible(false)
	self._rootnode.zhuZhen_ItemLabel_3:setVisible(false)
	self._rootnode.zhuZhen_ItemIcon_node:setVisible(false)
	self._rootnode.zhuzhen_info:setVisible(false)
	self._rootnode.zhuzhen_type_node:setVisible(false)
	self._rootnode.zhuzhen_open:setVisible(false)
	self._rootnode.zhuzhen_type_image:setDisplayFrame(display.newSpriteFrame("zhenrong_zhuzhen_type_" .. pageData.type .. ".png"))
	self._rootnode.zhuzhen_type:setVisible(false)
	self._rootnode.zhuzhen_type:setDisplayFrame(display.newSpriteFrame("zhenrong_zhuzhen_lable_" .. pageData.type .. ".png"))
	if pageData and pageData.data ~= nil then
		self._rootnode.zhuzhen_type_small:setDisplayFrame(display.newSpriteFrame("zhenrong_zhuzhen_lable_" .. pageData.type .. ".png"))
		if pageData.data.resId and pageData.data.resId > 0 then
			local cardData = pageData.data
			self._rootnode.zhuzhen_info:setVisible(true)
			self._rootnode.zhuZhen_ItemLabel_1:setVisible(true)
			self._rootnode.zhuZhen_ItemLabel_2:setVisible(true)
			self._rootnode.zhuZhen_ItemLabel_3:setVisible(true)
			self._rootnode.zhuZhen_ItemLabel_1:setString("LV." .. cardData.lv)
			self._rootnode.zhuZhen_ItemLabel_2:setString(data_card_card[cardData.resId].name)
			self._rootnode.zhuZhen_ItemLabel_3:setString("+ " .. cardData.cls)
			local heroPath = ResMgr.getHeroBodyName(cardData.resId, cardData.cls)
			self:setHeroImgBg(heroPath)
		else
			self._rootnode.zhuzhen_type_node:setVisible(true)
			self._rootnode.zhuzhen_type:setVisible(true)
		end
	else
		self._rootnode.zhuzhen_type:setVisible(true)
		self._rootnode.zhuzhen_open:setVisible(true)
		local goldType, expend = HelpLineModel:getCost(pageData.index)
		if goldType == 1 then
			self._rootnode.zhuzhen_open_use:setString(tostring(expend) .. common:getLanguageString("@SilverLabel"))
		else
			self._rootnode.zhuzhen_open_use:setString(common:getLanguageString("@Gold", expend))
		end
	end
end

return FormZhuZhenItem