useEnergy = class("CcsSubView", CcsSubView)
function useEnergy:ctor()
  useEnergy.super.ctor(self, "views/use_huoli.csb", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_ownnum = self:getNode("txt_own")
  self:addEnergyIcon()
  self:setInfo()
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_PlayerInfo)
end
function useEnergy:OnBtn_Close()
  self:CloseSelf()
end
function useEnergy:setInfo()
  local huoli = 0
  if g_LocalPlayer then
    huoli = g_LocalPlayer:getHuoli()
  end
  local limit = data_Variables.Player_Max_Huoli_Value or 1000
  local energyforflower = data_Variables.ProduceFlowerCostHuoli or 100
  local energyforcoin = data_Variables.ExchangeCoinCostHuoli or 100
  local txt_ownnum = self:getNode("txt_own")
  txt_ownnum:setText(string.format("%d/%d", huoli, limit))
  local txt_neednum = self:getNode("txt_neednum")
  txt_neednum:setText(tostring(energyforflower))
  local txt_neednumc = self:getNode("txt_neednumc")
  txt_neednumc:setText(tostring(energyforcoin))
  local img_item_bg = self:getNode("img_item_bg")
  local img_item_bgc = self:getNode("img_item_bgc")
  local img_item_bgl = self:getNode("img_item_bgl")
  if g_LocalPlayer then
    local skillitem = self:getNode("ly_item_life")
    skillitem:setEnabled(true)
    skillitem:setVisible(true)
    local skillid, _ = g_LocalPlayer:getBaseLifeSkill()
    local haslifeskill = false
    if skillid == LIFESKILL_NO or skillid == nil then
      haslifeskill = false
    else
      haslifeskill = true
    end
    local txt_item_titlel = self:getNode("txt_item_titlel")
    if haslifeskill then
      txt_item_titlel:setText("生活技能")
    else
      txt_item_titlel:setText("学习生活技能")
    end
  else
    local skillitem = self:getNode("ly_item_life")
    skillitem:setEnabled(false)
    skillitem:setVisible(false)
  end
  img_item_bg:setTouchEnabled(true)
  img_item_bg:addTouchEventListener(handler(self, self.OnBtn_Flower))
  img_item_bgc:setTouchEnabled(true)
  img_item_bgc:addTouchEventListener(handler(self, self.OnBtn_Coin))
  img_item_bgl:setTouchEnabled(true)
  img_item_bgl:addTouchEventListener(handler(self, self.OnBtn_LifeSkill))
end
function useEnergy:OnMessage(msgSID, ...)
  if msgSID == MsgID_HouliUpdate then
    local huoli = 0
    if g_LocalPlayer then
      huoli = g_LocalPlayer:getHuoli()
    end
    local limit = data_Variables.Player_Max_Huoli_Value or 1000
    local txt_ownnum = self:getNode("txt_own")
    txt_ownnum:setText(string.format("%d/%d", huoli, limit))
  end
end
function useEnergy:OnBtn_Coin(obj, t)
  if t == TOUCH_EVENT_BEGAN then
    if obj then
      obj:setColor(ccc3(200, 200, 200))
    end
  elseif t == TOUCH_EVENT_ENDED then
    if obj then
      obj:setColor(ccc3(255, 255, 255))
    end
    local energyforcoin = data_Variables.ExchangeCoinCostHuoli or 100
    local dlg = CPopWarning.new({
      title = "提示",
      text = string.format("你确定要花费%d#<K,>活力#来完成活力打工吗？", energyforcoin),
      confirmFunc = function(...)
        netsend.netlifeskill.huoLiForCoin()
      end,
      confirmText = "确定",
      cancelText = "取消"
    })
    dlg:ShowCloseBtn(false)
  elseif t == TOUCH_EVENT_CANCELED and obj then
    obj:setColor(ccc3(255, 255, 255))
  end
end
function useEnergy:OnBtn_Flower(obj, t)
  if t == TOUCH_EVENT_BEGAN then
    if obj then
      obj:setColor(ccc3(200, 200, 200))
    end
  elseif t == TOUCH_EVENT_ENDED then
    if obj then
      obj:setColor(ccc3(255, 255, 255))
    end
    local energyforflower = data_Variables.ProduceFlowerCostHuoli or 100
    local dlg = CPopWarning.new({
      title = "提示",
      text = string.format("你确定要花费%d#<K,>活力#来培植鲜花吗？", energyforflower),
      confirmFunc = function(...)
        netsend.netlifeskill.huoLiForFlower()
      end,
      confirmText = "确定",
      cancelText = "取消"
    })
    dlg:ShowCloseBtn(false)
  elseif t == TOUCH_EVENT_CANCELED and obj then
    obj:setColor(ccc3(255, 255, 255))
  end
end
function useEnergy:OnBtn_LifeSkill(obj, t)
  if t == TOUCH_EVENT_BEGAN then
    if obj then
      obj:setColor(ccc3(200, 200, 200))
    end
  elseif t == TOUCH_EVENT_ENDED then
    if obj then
      obj:setColor(ccc3(255, 255, 255))
    end
    local skillid, _ = g_LocalPlayer:getBaseLifeSkill()
    if skillid == LIFESKILL_NO or skillid == nil then
      g_MapMgr:AutoRouteToNpc(90027, function(isSucceed)
        if isSucceed and CMainUIScene.Ins then
          CMainUIScene.Ins:ShowNormalNpcViewById(90027)
        end
      end)
    else
      local tempView = CSkillShow.new({InitSkillShow = SkillShow_LifeView})
      getCurSceneView():addSubView({
        subView = tempView,
        zOrder = MainUISceneZOrder.menuView
      })
    end
    self:OnBtn_Close()
    if g_SettingDlg then
      g_SettingDlg:CloseSelf()
    end
  elseif t == TOUCH_EVENT_CANCELED and obj then
    obj:setColor(ccc3(255, 255, 255))
  end
end
function useEnergy:addEnergyIcon()
  local huolipath = data_getResPathByResID(RESTYPE_HUOLI)
  if huolipath == nil then
    return
  end
  local function addicon(obj)
    local hlsp = display.newSprite(huolipath)
    hlsp:setAnchorPoint(ccp(0.5, 0.5))
    obj:addNode(hlsp)
  end
  local img_ownbg = self:getNode("img_own_bg")
  local img_sbg = self:getNode("img_sbg")
  local img_sbgc = self:getNode("img_sbgc")
  addicon(img_ownbg)
  addicon(img_sbg)
  addicon(img_sbgc)
  local flowerpath = data_getItemPathByShape(93011)
  local coinpath = "xiyou/pic/pic_moneypoke.png"
  local lifeskillpath = data_getLifeSkillIconPath(3)
  local ly_item_icon = self:getNode("ly_item_icon")
  local ly_item_iconc = self:getNode("ly_item_iconc")
  local bg_item = self:getNode("img_item_bgl")
  local bgsize = bg_item:getContentSize()
  local function addbigicon(obj, path, scale)
    if obj == nil or path == nil then
      return
    end
    obj:setVisible(false)
    local px, py = obj:getPosition()
    local parent = obj:getParent()
    local sp = display.newSprite(path)
    local spsize = sp:getContentSize()
    if scale then
      sp:setScale(scale * bgsize.height / spsize.height)
    end
    sp:setPosition(ccp(px, py))
    sp:setAnchorPoint(ccp(0.5, 0.5))
    parent:addNode(sp)
  end
  addbigicon(ly_item_icon, flowerpath)
  addbigicon(ly_item_iconc, coinpath)
end
function openUseEnergyView()
  if g_LocalPlayer == nil then
    return
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isNpcOptionUnlock(OPEN_Func_HuoLi)
  if openFlag == false then
    ShowNotifyTips(tips)
    return
  end
  local museEnergy = useEnergy.new()
  getCurSceneView():addSubView({
    subView = museEnergy,
    zOrder = MainUISceneZOrder.menuView
  })
end
