-- 走掉落表的道具批量使用


local BagDropMultiUseCell = class("BagDropMultiUseCell", function (  )
	return CCSItemCellBase:create("ui_layout/bag_DropMultiUseCell.json")
end)

BagDropMultiUseCell.GAP = 5
BagDropMultiUseCell.FINISH = 2
BagDropMultiUseCell.IN_USE = 1

BagDropMultiUseCell.CELL_HEIGHT_IN_USE = 220
BagDropMultiUseCell.CELL_HEIGHT_STOP_USE = 40

BagDropMultiUseCell.POSX_ITME_NUM_1 = {0}
BagDropMultiUseCell.POSX_ITME_NUM_2 = {-75, 75}
BagDropMultiUseCell.POSX_ITME_NUM_3 = {-148, 0, 148}
BagDropMultiUseCell.POSX_ITME_NUM_4 = {-189, -65, 60, 183}
BagDropMultiUseCell.POSX_ITME_NUM_5 = {-194, -98, -2, 94, 190}

function BagDropMultiUseCell:ctor( cellType, items, useCount )
	self._cellType = cellType
	self._isItemImageClickable = false
	self:_initContent(cellType, items, useCount)
end


function BagDropMultiUseCell:_initContent( cellType, items, useCount )
	if cellType == BagDropMultiUseCell.IN_USE and items then
		self:showWidgetByName("Panel_In_Use", true)
		self:showWidgetByName("Panel_Stop_Use", false)

		local countLabel = self:getLabelByName("Label_Title")
		countLabel:setText(G_lang:get("LANG_DUNGEON_GATENUM", {num = useCount}))
		countLabel:createStroke(Colors.strokeBrown, 1)

		for i=1, 5 do
			self:showWidgetByName("ImageView_Bouns" .. i, false)
		end

		for i = 1, #items do
			local posxArray = BagDropMultiUseCell["POSX_ITME_NUM_" .. (math.min(5, #items))]

			self:showWidgetByName("ImageView_Bouns" .. i, true)
			self:getImageViewByName("ImageView_Bouns" .. i):setPositionX(posxArray[i])

			local item = G_Goods.convert(items[i].type, items[i].value)

			local iconImageView = self:getImageViewByName("Ico" .. i)
			iconImageView:loadTexture(item.icon)

			local qualityBgImageView = self:getImageViewByName("Bouns" .. i)
			qualityBgImageView:loadTexture(G_Path.getEquipIconBack(item.quality))

			local itemBorderImageView = self:getImageViewByName("Image_Item_Border" .. i)
			itemBorderImageView:loadTexture(G_Path.getEquipColorImage(item.quality, item.type))

			local numLabel = self:getLabelByName("BounsNum" .. i)
			numLabel:setText("x" .. items[i].size)
			numLabel:createStroke(Colors.strokeBrown, 1)

			local nameLabel = self:getLabelByName("BounsName" .. i)
			nameLabel:setText(item.name)
			nameLabel:setColor(Colors.getColor(item.quality))
			nameLabel:createStroke(Colors.strokeBrown, 1)

			-- 点击弹出道具信息
			self:registerWidgetClickEvent("Ico" .. i, function()
				if type(items[i].type) == "number" and type(items[i].value) == "number" then
					local isClickable = self._isItemImageClickable
					if isClickable then
			    		require("app.scenes.common.dropinfo.DropInfo").show(items[i].type, items[i].value)
			    	end
				end
			end)
		end
	else
		self:showWidgetByName("Panel_In_Use", false)
		self:showWidgetByName("Panel_Stop_Use", true)
		self:getLabelByName("Label_Use_Stop"):createStroke(Colors.strokeBrown, 1)
	end
end

function BagDropMultiUseCell:setItemImageClickable(  )
	self._isItemImageClickable = true
end

function BagDropMultiUseCell:getHeight( ... )
	return self._cellType == BagDropMultiUseCell.IN_USE and BagDropMultiUseCell.CELL_HEIGHT_IN_USE or BagDropMultiUseCell.CELL_HEIGHT_STOP_USE
end


return BagDropMultiUseCell