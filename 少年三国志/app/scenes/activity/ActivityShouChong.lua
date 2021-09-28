local ActivityShouChong = class("ActivityShouChong",UFCCSNormalLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local ActivityShouChongItem = require("app.scenes.activity.ActivityShouChongItem")

require("app.cfg.knight_info")
require("app.cfg.drop_info")
function ActivityShouChong.create()
    local layer = ActivityShouChong.new("ui_layout/activity_ActivityShouChong.json")
    return layer
end

--drop info中的id 19
ActivityShouChong.AWARD_ID = 19

function ActivityShouChong:ctor(...)
    self.super.ctor(self,...)
    self:_initCaiwenji()
    self:getLabelByName("Label_zengsong"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_zengsong"):setText(G_lang:get("LANG_ACTIVITY_CHONG_ZHI_ZUI_DUO_ZENG_SONG"))
    self:_createRichText()
    self:_initScrollView()
    self:_refreshBtnStatus()
    self:_initEvent()
    self:updatePage()
end



function ActivityShouChong:_initCaiwenji()
  local appstoreVersion = (G_Setting:get("appstore_version") == "1")
  local GlobalConst = require("app.const.GlobalConst")
  if appstoreVersion or IS_HEXIE_VERSION  then 
      knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
  else
      knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
  end
  if knight then
      local heroPanel = self:getPanelByName("Panel_knight")
      local KnightPic = require("app.scenes.common.KnightPic")
      KnightPic.createKnightPic( knight.res_id, heroPanel, "caiwenji",true )
      heroPanel:setScale(0.9)
      if self._smovingEffect == nil then
          local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
          self._smovingEffect = EffectSingleMoving.run(heroPanel, "smoving_idle", nil, {})
      end
  end
end

function ActivityShouChong:_createRichText()
  local tipsLabel = self:getLabelByName("Label_chongzhibide")
  tipsLabel:setVisible(false)
  local size = self:getWidgetByName("Panel_tips"):getContentSize()
  self._richText = CCSRichText:create(size.width+50, size.height+30)
  self._richText:setFontSize(tipsLabel:getFontSize())
  self._richText:setFontName(tipsLabel:getFontName())
  local x,y = tipsLabel:getPosition()
  local text = G_lang:get("LANG_ACTIVITY_CHONG_ZHI_BI_DE")
  self._richText:setPosition(ccp(x+30+size.width/2,y+20))
  self._richText:enableStroke(Colors.strokeBrown)
  self._richText:appendXmlContent(text)
  self._richText:reloadData()
  self:getWidgetByName("Panel_tips"):addChild(self._richText)
end

function ActivityShouChong:_initScrollView()
  local good = G_Drops.convert(ActivityShouChong.AWARD_ID)
  self._goodArray = {}
  if good then
    if rawget(good,"goodsArray") then
      self._goodArray = good.goodsArray
    else
      self._goodArray = {good}
    end
  end
  self._scrollView = self:getScrollViewByName("ScrollView_award")
  local space = 10
  if self._goodArray and #self._goodArray > 0 then
    for i,v in ipairs(self._goodArray) do 
      local widget = ActivityShouChongItem.new(v)
      local width = widget:getContentSize().width
      local height = widget:getContentSize().height
      widget:setPosition(ccp(space*i + (i-1)*width,(self._scrollView:getContentSize().height-height)/2))
      self._scrollView:addChild(widget)
    end
  end
end


function ActivityShouChong:_refreshBtnStatus()
  --先判断vip经验
  if G_Me.vipData:getExp() > 0 then
    local isFirstRecharge = G_Me.shopData:firstRechargeForActivity()
    if not isFirstRecharge then
      --可领取
      self:getButtonByName("Button_go"):loadTextureNormal("btn-middle-red.png",UI_TEX_TYPE_PLIST)
      self:getImageViewByName("Image_30"):loadTexture(G_Path.getMiddleBtnTxt("lingqu.png"))
      self:showWidgetByName("Image_yilingqu",false)
      self:showWidgetByName("Button_go",true)
    else
      --已领取
      self:showWidgetByName("Image_yilingqu",true)
      self:showWidgetByName("Button_go",false)
    end
  else
    --前往充值
    self:showWidgetByName("Image_yilingqu",false)
    self:showWidgetByName("Button_go",true)
    self:getButtonByName("Button_go"):loadTextureNormal("ui/activity/btn_chongzhi.png")
    self:getImageViewByName("Image_30"):loadTexture(G_Path.getTextPath("qianwangchongzhi.png"))
  end
end

function ActivityShouChong:onLayerEnter()
  uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_RECHARGE_AWARD, self._getAward, self)
  uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_RECHARGE_INFO, self._getRechargeInfo, self)
end

function ActivityShouChong:onLayerExit()
  uf_eventManager:removeListenerWithTarget(self)
end

function ActivityShouChong:_getRechargeInfo()
  self:_refreshBtnStatus()
end

--领取成功,用于提示
function ActivityShouChong:_getAward(data)
  if data.ret == 1 then
    self:_refreshBtnStatus()
    local words = G_lang:get("LANG_ACTIVITY_LING_QU_SHOU_CHONG_SUCCESS")
    local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.awards,nil,words)
    uf_notifyLayer:getModelNode():addChild(_layer)
    --红点刷新
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
  end
end

function ActivityShouChong:updatePage()
end

function ActivityShouChong:_initEvent()
  self:registerBtnClickEvent("Button_go",function()
    if G_Me.vipData:getExp() > 0 then
      local isFirstRecharge = G_Me.shopData:firstRechargeForActivity()
      if not isFirstRecharge then
        --可领取
        G_HandlersManager.shopHandler:sendFirstRechargeAward(ActivityShouChong.AWARD_ID)
      else
        --已领取
      end
    else
      --前往充值
      require("app.scenes.shop.recharge.RechargeLayer").show()
    end
    end)
end

function ActivityShouChong:adapterLayer()
    self:adapterWidgetHeight("Panel_16","","",100,0)
end
return ActivityShouChong

