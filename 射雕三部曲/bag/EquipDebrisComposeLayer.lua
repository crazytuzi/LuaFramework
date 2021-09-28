--[[
	文件名：EquipDebrisComposeLayer.lua
	描述：装备碎片合成结果界面
	创建人：lengjiazhi
	创建时间：2017.5.15
--]]
local EquipDebrisComposeLayer = class("EquipDebrisComposeLayer", function (params)
	return display.newLayer()
end)
function EquipDebrisComposeLayer:ctor(params)

	self.mData = params.baseGetGameResourceList[1].Equip

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()
end
function EquipDebrisComposeLayer:initUI()
	--背景
	local bgSprite = ui.newSprite("zb_01.png")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)
	--确定按钮
	local backBtn = ui.newButton({
		text = TR("确定"),
		normalImage = "c_28.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
		})
	backBtn:setPosition(320, 280)
	self.mParentLayer:addChild(backBtn)

	--名字背景
	local nameBgSprite = ui.newScale9Sprite("lt_09.png", cc.size(275, 50))
	nameBgSprite:setPosition(320, 380)
	self.mParentLayer:addChild(nameBgSprite)
	local bgSize = nameBgSprite:getContentSize()
	--名字
	local nameStr = EquipModel.items[self.mData[1].ModelId].name
	local nameLabel = ui.newLabel({
		text = string.format("%s*%s",nameStr, #self.mData),
		color = Utility.getQualityColor(EquipModel.items[self.mData[1].ModelId].quality, 1),
		size = 22,
		})
	nameLabel:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
	nameBgSprite:addChild(nameLabel)
	--装备图
	local equipSprite = ui.newSprite(EquipModel.items[self.mData[1].ModelId].pic..".png")
	equipSprite:setPosition(320, 618)
	self.mParentLayer:addChild(equipSprite)

    --星星
    local star = Figure.newEquipStarLevel({
	 	modelId = self.mData[1].ModelId,
	 	}) 
    if star then
    	star:setPosition(320, 865)
    	self.mParentLayer:addChild(star)
	 	star:setAnchorPoint(0.5, 0.5)
    end

	-- --数量背景
	-- local numBgSprite = ui.newScale9Sprite("lt_09.png", cc.size(275, 50))
	-- numBgSprite:setPosition(320, 380)
	-- self.mParentLayer:addChild(numBgSprite)
	-- local bgSize = numBgSprite:getContentSize()
	-- --数量
	-- local nameLabel = ui.newLabel({
		-- text = TR("%s*%s", nameStr, #self.mData),
	-- 	color = Enums.Color.eWhite,
	-- 	size = 22,
	-- 	})
	-- nameLabel:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
	-- numBgSprite:addChild(nameLabel)

end
return EquipDebrisComposeLayer