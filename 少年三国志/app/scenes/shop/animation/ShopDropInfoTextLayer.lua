-- ShopDropInfoTextLayer.lua

local ShopDropInfoTextLayer =  class("ShopDropInfoTextLayer", UFCCSNormalLayer)
local OneKnightDrop = require("app.scenes.shop.animation.OneKnightDrop")

function ShopDropInfoTextLayer.create(knightInfo, Type, num, ...)
	local layer = ShopDropInfoTextLayer.new("ui_layout/shop_ShopDropInfoTextLayer.json", nil, knightInfo, Type, num, ...)
	return layer
end

function ShopDropInfoTextLayer:ctor(json, func, knightInfo, Type, num, ...)
	self._knightInfo = knightInfo
	self._type = Type
	self._num = num
	
	self:_createStorkes()
	self:_initWidgets()
end

function ShopDropInfoTextLayer:_createStorkes()
	self:getLabelByName("Label_35"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_jipinlefttime"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_36"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_37"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_41"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_42"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_zhengyingFinish"):createStroke(Colors.strokeBrown,1)
    
    self:getLabelByName("Label_zhenyingTag"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_gailvTimes"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_gailvTimes_0"):createStroke(Colors.strokeBrown,1)

    self:getLabelByName("Label_chengjiang"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_xiacibichu"):createStroke(Colors.strokeBrown,1)
end

function ShopDropInfoTextLayer:_initWidgets()
	self:setCascadeOpacityEnabled(true)
    self:setClickSwallow(true)
    self:registerBtnClickEvent("Button_knightInfo",function()
        require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT,self._knightInfo.id)
        end)
    self:getImageViewByName("Image_knightType"):loadTexture(G_Path.getJobTipsIcon(self._knightInfo.character_tips or 0))
    local label = self:getLabelByName("Label_name")
    label:createStroke(Colors.strokeBrown,1)
    label:setColor(Colors.qualityColors[self._knightInfo.quality])
    label:setText(self._knightInfo.name)
    self:getImageViewByName("Image_group"):loadTexture(G_Path.getKnightGroupIcon(self._knightInfo.group))
    self:getLabelByName("Label_35"):setText(G_lang:get("LANG_SHOP_DROP_INFO_TEXT"))
    
    -- todo ,
    if self._type == 1 then   
        --免费招将
        self:getPanelByName("Panel_must_shenjiang"):setVisible(false)
        self:showWidgetByName("Panel_must",false)

        self:showWidgetByName("Image_Tips_Bg", true)
        local buyMoneyLabel = self:getLabelByName("Label_Buy_Money_Tips")
        buyMoneyLabel:setText(G_lang:get("LANG_DROP_BUY_MONEY_TIPS", {num = OneKnightDrop.GOOD_KNIGHT_ONE_TIME_MONEY}))
        buyMoneyLabel:setColor(Colors.darkColors.DESCRIPTION)
        buyMoneyLabel:createStroke(Colors.strokeBrown, 1)

    elseif self._type==2 then  
        --元宝招将
        -- layer:getPanelByName("Panel_must_shenjiang"):setVisible(true)
        --  再招N次后可得..
        local times,isCheng = G_Me.shopData:getDropGodlyKnightLeftTime()

        if times == 1 then
            self:showWidgetByName("Panel_must_shenjiang",false)
            self:showWidgetByName("Panel_must",true)
            if isCheng == true then
                self:getLabelByName("Label_42"):setText(G_lang:get("LANG_DROP_KNIGHT_CHENG_SE_WU_JIANG"))
                self:getLabelByName("Label_42"):setColor(Colors.qualityColors[5])
            else
                self:getLabelByName("Label_42"):setText(G_lang:get("LANG_DROP_KNIGHT_ZI_JIANG_YI_SHANG"))
                self:getLabelByName("Label_42"):setColor(Colors.qualityColors[4])
            end
        else
            self:showWidgetByName("Panel_must_shenjiang",true)
            self:showWidgetByName("Panel_must",false)
            self:getLabelByName("Label_jipinlefttime"):setText(times)
            if isCheng == true then
                self:getLabelByName("Label_37"):setText(G_lang:get("LANG_DROP_KNIGHT_CHENG_SE_WU_JIANG"))
                self:getLabelByName("Label_37"):setColor(Colors.qualityColors[5])
            else
                self:getLabelByName("Label_37"):setColor(Colors.qualityColors[4])
                self:getLabelByName("Label_37"):setText(G_lang:get("LANG_DROP_KNIGHT_ZI_JIANG_YI_SHANG"))
            end
        end

        self:showWidgetByName("Image_Tips_Bg", true)
        local buyMoneyLabel = self:getLabelByName("Label_Buy_Money_Tips")
        buyMoneyLabel:setText(G_lang:get("LANG_DROP_BUY_MONEY_TIPS", {num = OneKnightDrop.GODLY_KNIGHT_ONE_TIME_MONEY}))
        buyMoneyLabel:setColor(Colors.darkColors.DESCRIPTION)
        buyMoneyLabel:createStroke(Colors.strokeBrown, 1)

    elseif self._type == 3 then
        self:showWidgetByName("Image_Tips_Bg", false)
        self:showWidgetByName("Panel_must_shenjiang",false)
        if self._num and type(self._num) == "number" and self._num >= 2 then
            self:showWidgetByName("Panel_Multi_Compose", true)
            self:getLabelByName("Label_Compose_Tag"):createStroke(Colors.strokeBrown, 1)

            local composeName = self:getLabelByName("Label_Compose_Name")
            composeName:createStroke(Colors.strokeBrown, 1)
            composeName:setText(self._knightInfo.name)
            composeName:setColor(Colors.qualityColors[self._knightInfo.quality])

            local composeNum = self:getLabelByName("Label_Compose_Num")
            composeNum:createStroke(Colors.strokeBrown, 1)
            composeNum:setText("x" .. self._num)
        else
            self:showWidgetByName("Panel_Multi_Compose", false)
        end
    elseif self._type == 4 then
        self:showWidgetByName("Image_Tips_Bg", false)
        local times = self:getLabelByName("Label_gailvTimes")
        self:showWidgetByName("Panel_zhenying",true)
        local curTimes = G_Me.shopData.dropKnightInfo.zy_recruited_times
        if curTimes == 15 then 
            self:showWidgetByName("Panel_zhenyingfinish",true)
            self:getLabelByName("Label_zhengyingFinish"):setText(G_lang:get("LANG_ZHEN_YING_CHOU_JIANG_FINISH_FOR_BUTTON"))
        else
            if curTimes == 14 then
                self:showWidgetByName("Panel_bichucheng",true)
            else
                self:showWidgetByName("Panel_zhenyingNormal",true)
            end
            require("app.cfg.camp_drop_info")
            local info = camp_drop_info.get(curTimes+1)
            if info then
                self:getLabelByName("Label_gailvTimes"):setText("x" .. tostring(info.oran_probability))
            else
                self:getLabelByName("Label_gailvTimes"):setText("")
            end
        end                    
    end
end

return ShopDropInfoTextLayer