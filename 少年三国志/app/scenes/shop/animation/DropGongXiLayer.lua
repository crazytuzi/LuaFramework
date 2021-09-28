local DropGongXiLayer =  class("DropGongXiLayer",UFCCSNormalLayer)

function DropGongXiLayer.create(knight, num)
    local layer = DropGongXiLayer.new("ui_layout/shop_ShopDropGongxiLayer.json",knight,num)
    return layer
end

function DropGongXiLayer:ctor(json,info,num,...)
    self.super.ctor(self,...)
    if not info then
        return
    end
    self:showWidgetByName("Button_share",G_ShareService:canShareImage())
    self:getImageViewByName("ImageView_knightQuality"):loadTexture(G_Path.getDropKnightQualityImage(info.quality))
    self:getImageViewByName("Image_group"):loadTexture(G_Path.getJobTipsIcon(info.character_tips))
    self:getImageViewByName("Image_country"):loadTexture(G_Path.getKnightGroupIcon(info.group))
    self:setClickSwallow(true)
    local label = self:getLabelByName("Label_name")
    label:setColor(Colors.qualityColors[info.quality])
    label:setText(info.name)
    self:getLabelByName("Label_gongxi"):createStroke(Colors.strokeBrown,1)

    self:registerBtnClickEvent("Button_share",function()
        --点这里分享
        local SharingLayer = require("app.scenes.mainscene.SharingLayer")
        local detailLayer = SharingLayer.create(SharingLayer.LAYOUT_SETTING_STYLE, Colors.modelColor, {
            {"Label_share_content", {text=G_lang:get("LANG_DROP_SHARE_CONTENT_DESC")}}
        })
        uf_sceneManager:getCurScene():addChild(detailLayer)

        detailLayer:registerBtnClickEvent("Button_to_weibo", function()
            detailLayer:close()
            uf_funcCallHelper:callAfterFrameCount(2, function()
                G_ShareService:weiboShareScreen()
            end)
        end)

        detailLayer:registerBtnClickEvent("Button_to_wechat", function()
            detailLayer:close()
            uf_funcCallHelper:callAfterFrameCount(2, function()
                G_ShareService:weixinShareScreen()
            end)
        end)

    end)

    -- 武将合成时
    if num and type(num) == "number" and num > 1 then
        self:showWidgetByName("Panel_Multi_Compose", true)

        self:getLabelByName("Label_Compose_Tag"):createStroke(Colors.strokeBrown, 1)

        local composeName = self:getLabelByName("Label_Compose_Name")
        composeName:createStroke(Colors.strokeBrown, 1)
        composeName:setText(info.name)
        composeName:setColor(Colors.qualityColors[info.quality])

        local composeNum = self:getLabelByName("Label_Compose_Num")
        composeNum:createStroke(Colors.strokeBrown, 1)
        composeNum:setText("x" .. num)
    else
        self:showWidgetByName("Panel_Multi_Compose", false)
    end
end


return DropGongXiLayer