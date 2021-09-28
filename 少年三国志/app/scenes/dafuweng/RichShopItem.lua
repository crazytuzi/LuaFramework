local RichShopItem = class("RichShopItem",function()
    return CCSItemCellBase:create("ui_layout/dafuweng_RichShopItem.json")
end)

require("app.cfg.richman_shop_info")

function RichShopItem:ctor(...)
    self._headImage = self:getImageViewByName("ImageView_item")
    self._nameLabel = self:getLabelByName("Label_name")
    self._countLabel = self:getLabelByName("Label_count")
    self._costTitleLabel = self:getLabelByName("Label_costTitle")
    self._costNumLabel = self:getLabelByName("Label_costNum")
    self._scoreTitleLabel = self:getLabelByName("Label_scoreTitle")
    self._scoreNumLabel = self:getLabelByName("Label_scoreNum")
    self._itemButton = self:getButtonByName("Button_item")
    self._buyButton = self:getButtonByName("Button_buy")
    self._buyImg = self:getImageViewByName("Image_buy")
    self._discountLabel = self:getLabelByName("Label_discount")

    self._onlyOneLabel = self:getLabelByName("Label_buyOnly")
    self._miniImg = self:getImageViewByName("Image_miniIcon")
    self._nameLabel:createStroke(Colors.strokeBrown,1)
    self._countLabel:createStroke(Colors.strokeBrown,1)
    self._onlyOneLabel:createStroke(Colors.strokeBrown,1)
    self._discountLabel:createStroke(Colors.strokeBrown,1)
    self._costTitleLabel:setText(G_lang:get("LANG_FU_COSTTITLE2"))
    self._scoreTitleLabel:setText(G_lang:get("LANG_FU_SHOPSCORE"))
    
    self:registerBtnClickEvent("Button_item", function ( ... )
        local data = richman_shop_info.get(self._id)
        require("app.scenes.common.dropinfo.DropInfo").show(data["type"], data["value"])  
    end)
    self:registerBtnClickEvent("Button_buy", function ( ... )
        local data = richman_shop_info.get(self._id)
        -- local awardItem = G_Goods.convert(data.type,data.value,data.size)
        -- local layer = require("app.scenes.common.CommonGoldConfirmLayer").create(awardItem, data.cost_size, function(_layer)
        --     if G_Me.richData:getState() == 1 then
        --         G_HandlersManager.richHandler:sendRichBuy(self._id,1)
        --     else
        --         G_MovingTip:showMovingTip(G_lang:get("LANG_FU_TIMEOUT"))
        --     end
        --     _layer:animationToClose()
        -- end)
        -- uf_sceneManager:getCurScene():addChild(layer)
        if G_Me.userData.gold < data.cost_size then
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
        local RichShopItemSellLayer = require "app.scenes.dafuweng.RichShopItemSellLayer"
        local layer = RichShopItemSellLayer.create(
            data.type, 
            data.value,
            data.size,
            data.cost_type, 
            data.cost_size, 
            math.min(self._buyTimes,math.floor(G_Me.userData.gold/data.cost_size)), 
            function(count, layer)
                if G_Me.richData:getState() == 1 then
                        G_HandlersManager.richHandler:sendRichBuy(self._id,count)
                else
                    G_MovingTip:showMovingTip(G_lang:get("LANG_FU_TIMEOUT"))
                end
                layer:animationToClose()                            
            end)
        uf_sceneManager:getCurScene():addChild(layer)
    end)
end

function RichShopItem:updateView(id,buyTimes)
    local data = richman_shop_info.get(id)
    self._id = id
    self._buyTimes = buyTimes
    local awardItem = G_Goods.convert(data.type,data.value)
    self._itemButton:loadTextureNormal(G_Path.getEquipColorImage(awardItem.quality,awardItem.type))
    self._itemButton:loadTexturePressed(G_Path.getEquipColorImage(awardItem.quality,awardItem.type))

    self._headImage:loadTexture(awardItem.icon,UI_TEX_TYPE_LOCAL)
    self._nameLabel:setColor(Colors.qualityColors[awardItem.quality])
    self._nameLabel:setText(awardItem.name)
    self._countLabel:setText("x" .. data.size)
    self._onlyOneLabel:setText(G_lang:get("LANG_FU_ONECHANCE",{times=buyTimes}))
    -- 
    local cost = G_Goods.convert(data.cost_type,data.cost_size)
    self._costTitleLabel:setText(G_lang:get("LANG_FU_COSTTITLE"))
    self._costNumLabel:setText(data.cost_size)
    self._miniImg:loadTexture(cost.icon_mini,cost.texture_type)
    self._scoreNumLabel:setText(data.score)

    if buyTimes == 0 then
        self._buyButton:setTouchEnabled(false)
        self._buyImg:loadTexture("ui/text/txt-small-btn/yigoumai.png")
    else
        self._buyButton:setTouchEnabled(true)
        self._buyImg:loadTexture("ui/text/txt-small-btn/goumai.png")
    end

    if data.discount and data.discount > 0 then
        self._discountLabel:setVisible(true)
        self._discountLabel:setText((data.discount/10)..G_lang:get("LANG_GROUP_BUY_AWARD_OFF"))
        self._discountLabel:setColor(data.discount>=70 and Colors.qualityColors[3] or Colors.qualityColors[7])
    else
        self._discountLabel:setVisible(false)
    end
end


return RichShopItem

