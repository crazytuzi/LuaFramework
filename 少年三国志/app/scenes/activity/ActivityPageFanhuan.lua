local ActivityPageFanhuan = class("ActivityPageFanhuan", UFCCSNormalLayer )
KnightPic = require("app.scenes.common.KnightPic")

function ActivityPageFanhuan.create(...)
    return ActivityPageFanhuan.new("ui_layout/activity_ActivityFanhuan.json")
end


function ActivityPageFanhuan:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GETRECHARGEBACK, self._onGetRechargeBack, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECHARGEBACKGOLD, self._onRechargeBackGold, self) 

end

function ActivityPageFanhuan:onLayerExit()
   uf_eventManager:removeListenerWithTarget(self)
end

function ActivityPageFanhuan:ctor(...)
    self.super.ctor(self, ...)
    self:setMeinv()
    self._yuanLabel = self:getLabelByName("Label_value1")
    self._yuanLabel:createStroke(Colors.strokeBrown, 1)
    self._yuanbaoLabel = self:getLabelByName("Label_value2")
    self._yuanLabel:createStroke(Colors.strokeBrown, 1)
    self._expLabel = self:getLabelByName("Label_value3")
    self._yuanLabel:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_title1"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_title2"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_title3"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_add2"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_add2"):setText(G_lang:get("LANG_ACTIVITY_FANHUAN_ADD"))

    self:attachImageTextForBtn("Button_getAward","Image_getAward")

    self:registerBtnClickEvent("Button_getAward", function()
        G_HandlersManager.activityHandler:sendRechargeBackGold()
    end)
end

function ActivityPageFanhuan:setMeinv()
    local GlobalConst = require("app.const.GlobalConst")
    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    local knight = nil
    if appstoreVersion or IS_HEXIE_VERSION  then 
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
    else
        knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
    end
    if knight then
        local hero = KnightPic.createKnightPic( knight.res_id, self:getPanelByName("Panel_hero"), "meinv",true )
        hero:setScale(0.8)
        -- local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        -- self._bossEffect = EffectSingleMoving.run(hero, "smoving_idle", nil, {})
    end
end

function ActivityPageFanhuan:adapterLayer()
    
end

function ActivityPageFanhuan:showPage()   
    --进界面的时候强刷一次数据
    G_HandlersManager.activityHandler:sendGetRechargeBack()
end

function ActivityPageFanhuan:_onGetRechargeBack(data)
    if data.ret == 1 then
        self:updateView()
    end
end

function ActivityPageFanhuan:_onRechargeBackGold(data)
    if data.ret == 1 then
        -- G_MovingTip:showMovingTip(G_lang:get("LANG_SYSTEM_GOODS"))
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create({{type=G_Goods.TYPE_GOLD, value=0, size=G_Me.activityData.fanhuan._gold},{type=G_Goods.TYPE_VIP_EXP, value=0, size=G_Me.activityData.fanhuan._vip_exp}})
        uf_notifyLayer:getModelNode():addChild(_layer)
        self:getButtonByName("Button_getAward"):setTouchEnabled(false)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
    end
end

function ActivityPageFanhuan:updateView()
    -- print("updateView")
    self._yuanLabel:setText(G_lang:get("LANG_PRICE_TAG",{price= G_Me.activityData.fanhuan._money})) 
    self._yuanbaoLabel:setText(G_Me.activityData.fanhuan._gold..G_lang:get("LANG_GOLDEN")) 
    self._expLabel:setText(G_Me.activityData.fanhuan._vip_exp) 

    if G_Me.activityData.fanhuan._has_recharge then
        self:getButtonByName("Button_getAward"):setTouchEnabled(true)
    else
        self:getButtonByName("Button_getAward"):setTouchEnabled(false)
    end
end

return ActivityPageFanhuan
