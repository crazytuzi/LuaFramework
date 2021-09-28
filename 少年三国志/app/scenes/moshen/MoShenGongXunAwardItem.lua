local MoShenGongXunAwardItem = class("MoShenGongXunAwardItem",function()
    --记得修改json
    return CCSItemCellBase:create("ui_layout/moshen_MoShenGongXunAwardItem.json")
end)



function MoShenGongXunAwardItem:ctor(...)
    self._onClickFunc = nil
    self._headImage = self:getImageViewByName("ImageView_item")
    self._nameLabel = self:getLabelByName("Label_name")
    self._countLabel = self:getLabelByName("Label_count")
    self._conditionLabel = self:getLabelByName("Label_condition")
    self._progressLabel = self:getLabelByName("Label_progress")
    self._itemButton = self:getButtonByName("Button_item")
    self._activityImg = self:getImageViewByName("Image_activity")

    self._statusImage = self:getImageViewByName("Image_status")  --领取状态
    self._nameLabel:createStroke(Colors.strokeBrown,1)
    self._countLabel:createStroke(Colors.strokeBrown,1)
    self:registerWidgetClickEvent("ImageView_bg",function()
        if self._onClickFunc ~= nil then
            self._onClickFunc()
        end
        end)
end

--[[
    exploit 功勋对象
]]
function MoShenGongXunAwardItem:updateItem(exploit)
    local awardItem = G_Goods.convert(exploit.type,exploit.value)
    self._itemButton:loadTextureNormal(G_Path.getEquipColorImage(awardItem.quality,awardItem.type))
    self._itemButton:loadTexturePressed(G_Path.getEquipColorImage(awardItem.quality,awardItem.type))

    self._headImage:loadTexture(awardItem.icon,UI_TEX_TYPE_LOCAL)
    self._nameLabel:setColor(Colors.qualityColors[awardItem.quality])
    self._nameLabel:setText(awardItem.name)
    self._countLabel:setText("x" .. G_GlobalFunc.ConvertNumToCharacter3(exploit.size))

    self._activityImg:setVisible(exploit.holiday>0)
    -- 
    self._conditionLabel:setText(G_lang:get("LANG_MOSHEN_GONGXUN_AWARD_PROGRESS_TIPS",{gongxun=exploit.exploit}))
    self._progressLabel:setText(string.format("%s/%s",G_Me.moshenData:getGongXun(),exploit.exploit))
    -- if exploit.hasAward then
    if G_Me.moshenData:checkAwardSign(exploit.id) then
        self._statusImage:setVisible(true)
        self._statusImage:loadTexture(G_Path.getTextPath("jqfb_yilingqu.png"))
    else
        if G_Me.moshenData:getGongXun() < exploit.exploit then
            -- self._awardBtn:setTitleText("未达成")
            self._statusImage:setVisible(false)
        else 
            self._statusImage:setVisible(true)
            self._statusImage:loadTexture(G_Path.getTextPath("jqfb_dianjilingqu.png"))
            -- self._awardBtn:setTitleText("领取")
        end
    end
end


function MoShenGongXunAwardItem:setOnClick(listener)
    self._onClickFunc = listener
end


return MoShenGongXunAwardItem

