local ActivityPageRecharge = class("ActivityPageRecharge",UFCCSNormalLayer)

--[[
  为了方便打patch
]]
ActivityPageRecharge.iconTitle = "充值送话费"

ActivityPageRecharge.text01 = "活动时间："
ActivityPageRecharge.text02 = "2月16日0时-2月23日0时"
ActivityPageRecharge.nextDay = "话费赠送仅限5万人，充值后次日可领取，2月26日截止领取"
ActivityPageRecharge.uBi = "(U币可在游族平台旗下的任意游戏中使用)"
ActivityPageRecharge.richText = "<root><text value='除此之外，活动期间的所有充\n值，全部额外赠送充值金额的\n' color='5258802'/><text value='110%的U币' color='12922112'/><text value='，多次充值有效' color='5258802'/></root>"

function ActivityPageRecharge.create()
    local layer = ActivityPageRecharge.new("ui_layout/activity_ActivityRecharge.json")
    layer:adapterLayer()
    return layer
end

function ActivityPageRecharge:ctor(...)
    self.super.ctor(self,...)
    self:_createStroke()
    self:_setText()
    self:_initCaiwenji()

    self:_createRichText()
    self:registerBtnClickEvent("Button_recharge",function()
        require("app.scenes.shop.recharge.RechargeLayer").show()
      end)
    self:registerBtnClickEvent("Button_go",function()
      local url = G_Setting:get("open_activity_recharge_url")
      if url == nil or url == "" then
        return
      end
      G_NativeProxy.openURL(url)
      end)
end


function ActivityPageRecharge:_createStroke()
  self:getLabelByName("Label_17"):createStroke(Colors.strokeBrown,1)
  self:getLabelByName("Label_17_0"):createStroke(Colors.strokeBrown,1)
  self:getLabelByName("Label_nextDay"):createStroke(Colors.strokeBrown,1)
  
end


function ActivityPageRecharge:_initCaiwenji()
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
      heroPanel:setScale(0.7)
      if self._smovingEffect == nil then
          local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
          self._smovingEffect = EffectSingleMoving.run(heroPanel, "smoving_idle", nil, {})
      end
  end
end


function ActivityPageRecharge:_setText()
  self:getLabelByName("Label_17"):setText(ActivityPageRecharge.text01)
  self:getLabelByName("Label_17_0"):setText(ActivityPageRecharge.text02)
  self:getLabelByName("Label_nextDay"):setText(ActivityPageRecharge.nextDay)
  self:getLabelByName("Label_ubi"):setText(ActivityPageRecharge.uBi)
end


function ActivityPageRecharge:_createRichText()
  local tipsLabel = self:getLabelByName("Label_richText")
  tipsLabel:setVisible(false)
  local size = tipsLabel:getContentSize()
  self._richText = CCSRichText:create(size.width+50, size.height+30)
  self._richText:setFontSize(tipsLabel:getFontSize())
  self._richText:setFontName(tipsLabel:getFontName())
  local x,y = tipsLabel:getPosition()
  local text = ActivityPageRecharge.richText
  self._richText:setPosition(ccp(x+35 + size.width/2,y + 10 + size.height/2))
 
  self._richText:appendXmlContent(text)
  self._richText:reloadData()
  tipsLabel:getParent():addChild(self._richText)
end

function ActivityPageRecharge:adapterLayer()
    self:adapterWidgetHeight("Panel_16","Image_17","",0,100)
end
return ActivityPageRecharge

