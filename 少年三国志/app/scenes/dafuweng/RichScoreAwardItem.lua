local RichScoreAwardItem = class("RichScoreAwardItem",function()
    return CCSItemCellBase:create("ui_layout/dafuweng_AwardItem.json")
end)



function RichScoreAwardItem:ctor(...)
    self._onClickFunc = nil
    self._headImage = self:getImageViewByName("ImageView_item")
    self._nameLabel = self:getLabelByName("Label_name")
    self._countLabel = self:getLabelByName("Label_count")
    self._conditionLabel = self:getLabelByName("Label_condition")
    self._progressLabel = self:getLabelByName("Label_progress")
    self._progressTagLabel = self:getLabelByName("Label_progressTag")
    self._itemButton = self:getButtonByName("Button_item")
    self._progressTagLabel:setText(G_lang:get("LANG_FU_JINDU"))

    self._statusImage = self:getImageViewByName("Image_status")  --领取状态
    self._nameLabel:createStroke(Colors.strokeBrown,1)
    self._countLabel:createStroke(Colors.strokeBrown,1)
    self:registerWidgetClickEvent("ImageView_bg",function()
        if self._onClickFunc ~= nil then
            self._onClickFunc()
        end
        end)
end

function RichScoreAwardItem:updateItem(data)
    local awardItem = G_Goods.convert(data.type,data.value)
    self._itemButton:loadTextureNormal(G_Path.getEquipColorImage(awardItem.quality,awardItem.type))
    self._itemButton:loadTexturePressed(G_Path.getEquipColorImage(awardItem.quality,awardItem.type))

    self._headImage:loadTexture(awardItem.icon,UI_TEX_TYPE_LOCAL)
    self._nameLabel:setColor(Colors.qualityColors[awardItem.quality])
    self._nameLabel:setText(awardItem.name)
    self._countLabel:setText("x" .. data.size)
    -- 
    self._conditionLabel:setText(G_lang:get("LANG_FU_LOOP",{loop=data.turn}))
    self._progressLabel:setText(string.format("%s/%s",G_Me.richData:getLoop(),data.turn))

    if G_Me.richData:gotRoundReward(data.id) then
        self._statusImage:setVisible(true)
        self._statusImage:loadTexture(G_Path.getTextPath("jqfb_yilingqu.png"))
    else
        if G_Me.richData:getLoop() < data.turn then
            
            self._statusImage:setVisible(false)
        else 
            self._statusImage:setVisible(true)
            self._statusImage:loadTexture(G_Path.getTextPath("jqfb_dianjilingqu.png"))

        end
    end
end


function RichScoreAwardItem:setOnClick(listener)
    self._onClickFunc = listener
end


return RichScoreAwardItem

