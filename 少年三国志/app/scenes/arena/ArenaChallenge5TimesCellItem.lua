-- 竞技场连续挑战五次

local ArenaChallenge5TimesCellItem = class("ArenaChallenge5TimesCellItem", function()
    return CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/arena_Challenge5TimesResultItem.json")
end)


-- @ data 	战报数据
function ArenaChallenge5TimesCellItem:ctor( data, index, ... )

	-- dump(data)

	local moneyAmountLabel = UIHelper:seekWidgetByName(self, "Label_MoneyAmount")
	moneyAmountLabel = tolua.cast(moneyAmountLabel, "Label")

	local expAmountLabel = UIHelper:seekWidgetByName(self, "Label_ExpAmount")
	expAmountLabel = tolua.cast(expAmountLabel, "Label")

	local prestigeAmountLabel = UIHelper:seekWidgetByName(self, "Label_PrestigeAmount")
	prestigeAmountLabel = tolua.cast(prestigeAmountLabel, "Label")

	local prestigeDoubleLabel = UIHelper:seekWidgetByName(self, "Label_Prestige_Double")
	prestigeDoubleLabel = tolua.cast(prestigeDoubleLabel, "Label")
	prestigeDoubleLabel:setVisible(G_Me.activityData.custom:isShengwangActive())

	local awardMoney = 0
    local awardExp = 0
    local awardPrestige = 0

    for i,v in ipairs(data.rewards) do 
        if v.type == G_Goods.TYPE_MONEY then
            awardMoney = v.size
        elseif v.type == G_Goods.TYPE_EXP then
            awardExp = v.size
        elseif v.type == G_Goods.TYPE_SHENGWANG then
            awardPrestige = v.size
        end
    end

    --新手光环经验
	local rookieBuffLabel = UIHelper:seekWidgetByName(self, "Label_rookieBuffValue")
	rookieBuffLabel = tolua.cast(rookieBuffLabel, "Label")
    rookieBuffLabel:setText(G_Me.userData:getExpAdd(awardExp))
    
    moneyAmountLabel:setText(awardMoney)
    expAmountLabel:setText(awardExp)
    prestigeAmountLabel:setText(awardPrestige)

    local indexLabel = UIHelper:seekWidgetByName(self, "Label_Index")
	indexLabel = tolua.cast(indexLabel, "Label")
	indexLabel:createStroke(Colors.strokeBrown, 1)
	indexLabel:setText(G_lang:get("LANG_DUNGEON_GATENUM", {num = index}))

	if data.battle_report.is_win == false then
		local loseImage = UIHelper:seekWidgetByName(self, "Image_Fail")
		-- loseImage = tolua.cast(loseImage, "Image")
		loseImage:setVisible(true)

		local cardAwardPanel = UIHelper:seekWidgetByName(self, "Panel_Card_Award")
		cardAwardPanel:setVisible(false)
	else 
		local goods = G_Goods.convert(data.turnover_rewards.rewards[1].type,
									data.turnover_rewards.rewards[1].value,
									data.turnover_rewards.rewards[1].size)

		local nameLabel = UIHelper:seekWidgetByName(self, "Label_Name")
		nameLabel = tolua.cast(nameLabel, "Label")
		nameLabel:setText(goods.name)
		nameLabel:setColor(Colors.qualityColors[goods.quality])
		nameLabel:createStroke(Colors.strokeBrown, 1)

		local sizeLabel = UIHelper:seekWidgetByName(self, "Label_Size")
		sizeLabel = tolua.cast(sizeLabel, "Label")
		sizeLabel:setText("x" .. goods.size)
		sizeLabel:createStroke(Colors.strokeBrown, 1)

		local itemBgImage = UIHelper:seekWidgetByName(self, "Image_Item_Bg")
		itemBgImage = tolua.cast(itemBgImage, "ImageView")
		itemBgImage:loadTexture(G_Path.getEquipIconBack(goods.quality))

		local itemImage = UIHelper:seekWidgetByName(self, "Image_Item")
		itemImage = tolua.cast(itemImage, "ImageView")
		itemImage:loadTexture(goods.icon)

		local itemBtn = UIHelper:seekWidgetByName(self, "Button_Item")
		itemBtn = tolua.cast(itemBtn, "Button")
		itemBtn:loadTextureNormal(G_Path.getEquipColorImage(goods.quality, goods.type))
		itemBtn:loadTextureNormal(G_Path.getEquipColorImage(goods.quality, goods.type))
		
	end

end


return ArenaChallenge5TimesCellItem