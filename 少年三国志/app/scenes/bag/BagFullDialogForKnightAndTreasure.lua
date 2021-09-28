-- 1.7.0版本开始武将和宝物的背包容量与VIP等级相关
-- 故从BagFullDialogForKnightAndTreasure中分离出来

local BagFullDialogForKnightAndTreasure = class("BagFullDialogForKnightAndTreasure",UFCCSModelLayer)

--注意添加json文件
--[[
    _type  
]]
function BagFullDialogForKnightAndTreasure.show(_type, scenePack)
    local layer = BagFullDialogForKnightAndTreasure.new("ui_layout/bag_BagFullDialogForKnightAndTreasure.json", Colors.modeColor, _type, scenePack)
    uf_sceneManager:getCurScene():addChild(layer)
end

function BagFullDialogForKnightAndTreasure:ctor(json,color,_type,scenePack,...)
	self.super.ctor(self,...)
    self:showAtCenter(true)
    self._type = _type
    self._scenePack = scenePack
    self:_initWidgets()
    self:_initBtnEvent()

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECHARGE_SUCCESS, self._onRechargeSuccess, self)
end

function BagFullDialogForKnightAndTreasure:_initWidgets( ... )
	local vipMaxLabel = self:getLabelByName("Label_Vip_Max")

    local line1Label = self:getLabelByName("Label_Line_1")
    local line2Label = self:getLabelByName("Label_Line_2")
    local line3Label = self:getLabelByName("Label_Line_3")
    local image01 = self:getImageViewByName("Image_Sell")
    local image02 = self:getImageViewByName("Image_Foster")

    local nextVip = 1

    if self._type == G_Goods.TYPE_KNIGHT then
    	local nextdata = G_Me.vipData:getNextWholeData(require("app.const.VipConst").KNIGHTBAGVIPEXTRA)
    	nextVip = nextdata.level
    	local nextTimes = nextdata.data

    	require("app.cfg.role_info")
        local roleInfo = role_info.get(G_Me.userData.level)
        local initialCount = roleInfo and roleInfo.knight_bag_num_client
        nextTimes = nextTimes + initialCount

    	line1Label:setText(G_lang:get("LANG_BAG_KNIGHT_IS_FULL_LINE_1"))
        line2Label:setText(G_lang:get("LANG_BAG_KNIGHT_IS_FULL_LINE_2", {num = nextVip}))
        line3Label:setText(G_lang:get("LANG_BAG_KNIGHT_IS_FULL_LINE_3", {num = nextTimes}))

        image01:loadTexture(G_Path.getMiddleBtnTxt("quchushou.png"))
        image02:loadTexture(G_Path.getMiddleBtnTxt("quqianghua.png"))

        vipMaxLabel:setText(G_lang:get("LANG_BAG_KNIGHT_IS_FULL_TITLE_NEW"))
    elseif self._type == G_Goods.TYPE_TREASURE then
    	local nextdata = G_Me.vipData:getNextWholeData(require("app.const.VipConst").TREASUREBAGVIPEXTRA)
    	nextVip = nextdata.level
    	local nextTimes = nextdata.data

    	require("app.cfg.role_info")
        local roleInfo = role_info.get(G_Me.userData.level)
        local initialCount = roleInfo and roleInfo.treasure_bag_num_client
        nextTimes = nextTimes + initialCount

    	line1Label:setText(G_lang:get("LANG_BAG_TREASURE_IS_FULL_LINE_1"))
        line2Label:setText(G_lang:get("LANG_BAG_KNIGHT_IS_FULL_LINE_2", {num = nextVip}))
        line3Label:setText(G_lang:get("LANG_BAG_KNIGHT_IS_FULL_LINE_3", {num = nextTimes}))

        image01:loadTexture(G_Path.getMiddleBtnTxt("chushoubaowu.png"))
        image02:loadTexture(G_Path.getMiddleBtnTxt("baowuqianghua.png"))

        vipMaxLabel:setText(G_lang:get("LANG_BAG_TREASURE_IS_FULL_TITLE_NEW"))
    else
        assert("靠,传了什么类型 _type = %s",self._type)
    end
    
    if nextVip == -1 then
        -- VIP最高之后，隐藏下一个VIP相关信息
        self:showWidgetByName("Panel_Vip_Max", true)
        self:showWidgetByName("Panel_Vip_Not_Max", false)
    end
end

function BagFullDialogForKnightAndTreasure:_initBtnEvent()
    self:registerBtnClickEvent("Button_Sell",function()
        if self._type == G_Goods.TYPE_KNIGHT then
        elseif self._type == G_Goods.TYPE_EQUIPMENT then
        elseif self._type == G_Goods.TYPE_TREASURE then
        else
            assert("靠,传了什么类型 _type = %s",self._type)
            return
        end
        uf_sceneManager:replaceScene(require("app.scenes.bag.BagSellScene").new(self._type, nil, self._scenePack))
        -- self:animationToClose()
        end)

    self:registerBtnClickEvent("Button_Foster",function()
        if self._type == G_Goods.TYPE_KNIGHT then
            uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new(nil, nil, self._scenePack))
        elseif self._type == G_Goods.TYPE_TREASURE then
            uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new(self._scenePack))
        else
            assert("靠,传了什么类型 _type = %s",self._type)
        end
        -- self:animationToClose()
        end)

    self:registerBtnClickEvent("Button_Vip_Benifit", function (  )
    	local p = require("app.scenes.vip.VipMainLayer").create()
        G_Me.shopData:setVipEnter(true)
        uf_sceneManager:getCurScene():addChild(p)
    end)

    self:registerBtnClickEvent("Button_Close", function (  )
    	self:animationToClose()
    end)
end



function BagFullDialogForKnightAndTreasure:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

function BagFullDialogForKnightAndTreasure:_onRechargeSuccess(  )
    self:removeFromParent()
end

return BagFullDialogForKnightAndTreasure
	
