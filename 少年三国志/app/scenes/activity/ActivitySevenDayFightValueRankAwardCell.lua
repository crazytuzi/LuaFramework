-- 开服7日战力榜奖励预览cell


local ActivitySevenDayFightValueRankAwardCell = class("ActivitySevenDayFightValueRankAwardCell", function (  )
	return CCSItemCellBase:create("ui_layout/activity_SevenDaysAwardPreviewItemCell.json")
end)

ActivitySevenDayFightValueRankAwardCell.AWARD_NUM = 4

function ActivitySevenDayFightValueRankAwardCell:ctor( ... )
	self._awardTagLabel = self:getLabelByName("Label_Award_Tag")
	self._awardTagLabel:createStroke(Colors.strokeBrown, 1)
	for i = 1, ActivitySevenDayFightValueRankAwardCell.AWARD_NUM do 
		self:getLabelByName("Label_Num_" .. i):createStroke(Colors.strokeBrown, 1)
	end
end


function ActivitySevenDayFightValueRankAwardCell:update( awardInfo )
	-- dump(awardInfo)
	if awardInfo then
		self._awardTagLabel:setText(awardInfo.directions)

		for i=1, ActivitySevenDayFightValueRankAwardCell.AWARD_NUM do
			local itemInfo = G_Goods.convert(awardInfo["type_" .. i], awardInfo["value_" .. i])

			local itemIconImage = self:getImageViewByName("Image_Item_Icon_" .. i)
			itemIconImage:loadTexture(itemInfo.icon)

			local itemBorderImage = self:getImageViewByName("Image_Item_Border_" .. i)
			itemBorderImage:loadTexture(G_Path.getEquipColorImage(itemInfo.quality, itemInfo.type))

			local itemNumLabel = self:getLabelByName("Label_Num_" .. i)
			-- itemNumLabel:createStroke(Colors.strokeBrown, 1)
			itemNumLabel:setText("x" .. G_GlobalFunc.ConvertNumToCharacter(awardInfo["size_" .. i]))	

			-- 点击弹出道具信息
			self:registerWidgetClickEvent("Image_Item_Icon_" .. i, function()
				if type(itemInfo.type) == "number" and type(itemInfo.value) == "number" then
		    		require("app.scenes.common.dropinfo.DropInfo").show(itemInfo.type, itemInfo.value)
				end
			end)
		end

	end
end

return ActivitySevenDayFightValueRankAwardCell