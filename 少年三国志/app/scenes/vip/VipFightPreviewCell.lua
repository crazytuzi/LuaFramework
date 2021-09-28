
require("app.cfg.dungeon_daily_info")


local VipFightPreviewCell = class ("VipFightPreviewCellLayer", function (  )
	return CCSItemCellBase:create("ui_layout/vip_hardLevelChooseCell.json")
end)

function VipFightPreviewCell:ctor(list, index)     
    self._itemNumLabel = self:getLabelByName("Label_Item_Num")
    self._itemNumLabel:createStroke(Colors.strokeBrown, 1)
    self._lockedLabel = self:getLabelByName("Label_Locked")
    self._fightValueLabel = self:getLabelByName("Label_Fight_Value")

    self._flagImageResList = {
                                    "ui/vip/qizhi_putong.png", 
                                    "ui/vip/qizhi_jingying.png", 
                                    "ui/vip/qizhi_yingxiong.png", 
                                    "ui/vip/qizhi_shishi.png", 
                                    "ui/vip/qizhi_chuanqi.png",
                                    "ui/vip/qizhi_shenhua.png"
                                 }
    self._flagImageTxtResList = {
                                    "ui/text/txt/rcfb_putong.png",
                                    "ui/text/txt/rcfb_jingying.png",
                                    "ui/text/txt/rcfb_yingxiong.png",
                                    "ui/text/txt/rcfb_shishi.png",
                                    "ui/text/txt/rcfb_chuanqi.png",
                                    "ui/text/txt/rcfb_shenhua.png"
                                }

end

function VipFightPreviewCell:updateData( list, index, dungeonId, btnCallback )
    local dungeonInfo = dungeon_daily_info.get(dungeonId)
    
    if dungeonInfo then
        -- 蛋疼。。。
        local minNum = 0
        local maxNum = 0
        local unlockLevel = 0
        local fightValue = 0
        local flagImageRes = ""
        local flagImageTxtRes = ""
        local item = G_Goods.convert(dungeonInfo.type, dungeonInfo.value)

        -- 转换成lua表中的索引
        local idx = index + 1
                                    
        minNum = dungeonInfo["min_size_" .. idx]
        maxNum = dungeonInfo["max_size_" .. idx]
        unlockLevel = dungeonInfo["level_" .. idx]
        fightValue = dungeonInfo["monster_fight_" .. idx]
        flagImageRes = self._flagImageResList[idx]
        flagImageTxtRes = self._flagImageTxtResList[idx]

        if minNum ~= maxNum then
            self._itemNumLabel:setText("x" .. minNum .. "~" .. maxNum)
        else
            if item.type == G_Goods.TYPE_MONEY then
                if minNum % 10000 == 0 then
                    minNum = minNum/10000 .. G_lang:get("LANG_WAN")
                end
            end
            self._itemNumLabel:setText("x" .. minNum)
        end

        self:getImageViewByName("Image_Level_Flag"):loadTexture(flagImageRes)
        self:getImageViewByName("Image_Flag_Txt"):loadTexture(flagImageTxtRes)

        if item.type == G_Goods.TYPE_TREASURE then
            self:getImageViewByName("Image_Item_Bg"):loadTexture(G_Path.getEquipIconBack(item.quality))
            self:getImageViewByName("Image_Item_Border_2"):loadTexture(G_Path.getEquipColorImage(item.quality, G_Goods.TYPE_TREASURE))
        elseif item.type == G_Goods.TYPE_KNIGHT then
            self:getImageViewByName("Image_Item_Bg"):loadTexture(G_Path.getEquipIconBack(item.quality))
            self:getImageViewByName("Image_Item_Border_2"):loadTexture(G_Path.getEquipColorImage(item.quality, G_Goods.TYPE_KNIGHT))
        else
            self:getImageViewByName("Image_Item_Bg"):loadTexture(G_Path.getEquipColorImage(item.quality, G_Goods.TYPE_ITEM))
        end

        self:getImageViewByName("Image_Item_Icon"):loadTexture(item.icon)
        self:registerWidgetClickEvent("Image_Item_Icon", function (  )
            require("app.scenes.common.dropinfo.DropInfo").show(dungeonInfo.type, dungeonInfo.value) 
        end)
        
        if G_Me.userData.level >= unlockLevel then
            -- 已解锁
            self:showWidgetByName("Panel_Unlocked", true)
            self:showWidgetByName("Panel_Locked", false)
            self._fightValueLabel:setText(G_GlobalFunc.ConvertNumToCharacter4(tonumber(fightValue)))

            self:registerBtnClickEvent("Button_Challenge", function (  )
                if btnCallback then
                    btnCallback()
                end
            end)
        else
            -- 未解锁
            self:showWidgetByName("Panel_Unlocked", false)
            self:showWidgetByName("Panel_Locked", true)
            self._lockedLabel:createStroke(Colors.strokeBrown, 1)
            self._lockedLabel:setText(G_lang:get("LANG_DAILY_DUNGEON_UNLOCK_LEVEL_TEXT", {num = unlockLevel}))
        end
    end
end

return VipFightPreviewCell


