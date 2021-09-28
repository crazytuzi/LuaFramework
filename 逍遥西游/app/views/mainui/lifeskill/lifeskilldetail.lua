function ShowLifeSkillDetail()
  getCurSceneView():addSubView({
    subView = CLifeSkillDetail.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
CLifeSkillDetail = class("CLifeSkillDetail", CcsSubView)
function CLifeSkillDetail:ctor(para)
  CLifeSkillDetail.super.ctor(self, "views/lifeskillshow.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_List = self:getNode("list_detail")
  local tempContent = CLifeSkillContent.new()
  self.m_List:pushBackCustomItem(tempContent.m_UINode)
end
function CLifeSkillDetail:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function CLifeSkillDetail:Clear()
end
CLifeSkillContent = class("CLifeSkillContent", CcsSubView)
function CLifeSkillContent:ctor(para)
  CLifeSkillContent.super.ctor(self, "views/lifeskilldetail.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_bsd = {
      listener = handler(self, self.OnBtn_BSD),
      variName = "btn_bsd"
    },
    btn_fuwen = {
      listener = handler(self, self.OnBtn_FW),
      variName = "btn_fuwen"
    },
    btn_wine = {
      listener = handler(self, self.OnBtn_Wine),
      variName = "btn_wine"
    },
    btn_fuwen_sub = {
      listener = handler(self, self.OnBtn_FW_sub),
      variName = "btn_fuwen_sub"
    },
    btn_wine_sub = {
      listener = handler(self, self.OnBtn_Wine_sub),
      variName = "btn_wine_sub"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:ResetData()
  self:ListenMessage(MsgID_PlayerInfo)
  self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.frameUpdate))
  self:scheduleUpdate()
  self:frameUpdate()
end
function CLifeSkillContent:ResetData()
  self:ResetBsd()
  self:ResetFw()
  self:ResetWine()
  self:ResetChengWeiDetail()
end
function CLifeSkillContent:frameUpdate(dt)
  local fuwenData = g_LocalPlayer:getLifeSkillFuData()
  local fuwenFlag = true
  if fuwenData.fid == nil or fuwenData.fid == 0 or fuwenData.v == nil or fuwenData.v == 0 then
    fuwenFlag = false
  end
  if fuwenFlag then
    if fuwenData.fid == ITEM_DEF_FU_SXF then
      local time = g_LocalPlayer:GetJiaSuFuwenRestTime()
      local h = math.floor(time / 3600)
      local m = math.floor(time % 3600 / 60)
      local s = math.floor(time % 60)
      self:getNode("txt_fuwen_2"):setText(string.format("%.2d:%.2d:%.2d", h, m, s))
    elseif fuwenData.fid == ITEM_DEF_FU_BSF then
      local time = g_LocalPlayer:GetBianShenFuwenRestTime()
      local h = math.floor(time / 3600)
      local m = math.floor(time % 3600 / 60)
      local s = math.floor(time % 60)
      self:getNode("txt_fuwen_2"):setText(string.format("%.2d:%.2d:%.2d", h, m, s))
    end
  end
end
function CLifeSkillContent:ResetBsd()
  if self.m_LifeSkillBSDImg ~= nil then
    self.m_LifeSkillBSDImg:removeFromParent()
    self.m_LifeSkillBSDImg = nil
  end
  local bsdNum = g_LocalPlayer:getLifeSkillBSD()
  local bsFlag = bsdNum > 0
  if bsFlag then
    self.m_LifeSkillBSDImg = display.newSprite("views/lifeskill/lifeskill_bsd.png")
  else
    self.m_LifeSkillBSDImg = display.newSprite("views/lifeskill/lifeskill_bsd_gray.png")
  end
  self:addNode(self.m_LifeSkillBSDImg)
  local x, y = self:getNode("box_bsd"):getPosition()
  local size = self:getNode("box_bsd"):getContentSize()
  self.m_LifeSkillBSDImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
  self:getNode("txt_bsd_2"):setText(string.format("%d场战斗", bsdNum))
end
function CLifeSkillContent:ResetFw()
  if self.m_LifeSkillFuwenImg ~= nil then
    self.m_LifeSkillFuwenImg:removeFromParent()
    self.m_LifeSkillFuwenImg = nil
  end
  local fuwenData = g_LocalPlayer:getLifeSkillFuData()
  local fuwenFlag = true
  if fuwenData.fid == nil or fuwenData.fid == 0 or fuwenData.v == nil or fuwenData.v == 0 then
    fuwenFlag = false
  end
  if fuwenFlag then
    self.m_LifeSkillFuwenImg = display.newSprite("views/lifeskill/lifeskill_fw.png")
    self:getNode("txt_fuwen_2"):setText(string.format("%d场战斗", fuwenData.v))
    self:getNode("txt_fuwen_1"):setVisible(true)
    self:getNode("txt_fuwen"):setText(data_getItemName(fuwenData.fid))
    self:getNode("txt_fuwen_eff"):setText(data_getLifeItemFuwenEff(fuwenData.fid))
    self.btn_fuwen_sub:setEnabled(true)
    AutoLimitObjSize(self:getNode("txt_fuwen_eff"), 260)
  else
    self.m_LifeSkillFuwenImg = display.newSprite("views/lifeskill/lifeskill_fw_gray.png")
    self:getNode("txt_fuwen_2"):setText("使用符文")
    self:getNode("txt_fuwen_1"):setVisible(false)
    self:getNode("txt_fuwen"):setText("当前无符文效果")
    self:getNode("txt_fuwen_eff"):setText("无")
    self.btn_fuwen_sub:setEnabled(false)
  end
  AutoLimitObjSize(self:getNode("txt_fuwen_2"), 80)
  self:addNode(self.m_LifeSkillFuwenImg)
  local x, y = self:getNode("box_fuwen"):getPosition()
  local size = self:getNode("box_fuwen"):getContentSize()
  self.m_LifeSkillFuwenImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
end
function CLifeSkillContent:ResetWine()
  if self.m_LifeSkillWineImg ~= nil then
    self.m_LifeSkillWineImg:removeFromParent()
    self.m_LifeSkillWineImg = nil
  end
  local wineData = g_LocalPlayer:getLifeSkillWineData()
  local wineFlag = true
  if wineData.wid == nil or wineData.wid == 0 or wineData.v == nil or wineData.v == 0 then
    wineFlag = false
  end
  if wineFlag then
    self.m_LifeSkillWineImg = display.newSprite("views/lifeskill/lifeskill_wine.png")
    self:getNode("txt_wine_2"):setText(string.format("%d场战斗", wineData.v))
    self:getNode("txt_wine_1"):setVisible(true)
    self:getNode("txt_wine"):setText(data_getItemName(wineData.wid))
    self:getNode("txt_wine_eff"):setText(data_getLifeItemWineEff(wineData.wid))
    AutoLimitObjSize(self:getNode("txt_wine_eff"), 260)
    self.btn_wine_sub:setEnabled(true)
  else
    self.m_LifeSkillWineImg = display.newSprite("views/lifeskill/lifeskill_wine_gray.png")
    self:getNode("txt_wine_2"):setText("使用酒")
    self:getNode("txt_wine_1"):setVisible(false)
    self:getNode("txt_wine"):setText("当前无酒效果")
    self:getNode("txt_wine_eff"):setText("无")
    self.btn_wine_sub:setEnabled(false)
  end
  AutoLimitObjSize(self:getNode("txt_wine_2"), 80)
  self:addNode(self.m_LifeSkillWineImg)
  local x, y = self:getNode("box_wine"):getPosition()
  local size = self:getNode("box_wine"):getContentSize()
  self.m_LifeSkillWineImg:setPosition(ccp(x + size.width / 2, y + size.height / 2))
end
function CLifeSkillContent:ResetChengWeiDetail()
  local allTxt = ""
  local curId, endTime, isHide = g_LocalPlayer:getCurChengwei()
  if curId ~= nil then
    local d = data_Title[curId]
    if d ~= nil then
      local showFlag = false
      if showFlag == false then
        for _, _ in pairs(d.ExpAdden or {}) do
          showFlag = true
          break
        end
      end
      if showFlag == false then
        for _, _ in pairs(d.AddKX or {}) do
          showFlag = true
          break
        end
      end
      if showFlag == false then
        for _, _ in pairs(d.AddFS or {}) do
          showFlag = true
          break
        end
      end
      if showFlag then
        local title = d.Title or "称谓标题"
        local tips = d.Tips or "称谓描述"
        allTxt = string.format("称谓#<G>%s#%s", title, tips)
      end
    end
  end
  local bgSize = self:getSize()
  if self.m_RichText == nil then
    local titleTxt = CRichText.new({
      width = bgSize.width + 10,
      verticalSpace = 1,
      font = KANG_TTF_FONT,
      fontSize = 20,
      color = ccc3(255, 255, 255)
    })
    self.m_RichText = titleTxt
    self:addChild(titleTxt, 10)
  else
    self.m_RichText:clearAll()
  end
  self.m_RichText:addRichText(allTxt)
end
function CLifeSkillContent:OnBtn_BSD(obj, t)
  ShowAddBSD()
end
function CLifeSkillContent:OnBtn_FW(obj, t)
  ShowUseLifeItem(IETM_DEF_LIFESKILL_FUWEN)
end
function CLifeSkillContent:OnBtn_Wine(obj, t)
  ShowUseLifeItem(IETM_DEF_LIFESKILL_WINE)
end
function CLifeSkillContent:OnBtn_FW_sub(obj, t)
  local fuwenData = g_LocalPlayer:getLifeSkillFuData()
  if fuwenData.fid == nil or fuwenData.fid == 0 or fuwenData.v == nil or fuwenData.v == 0 then
    return
  end
  local itemId = fuwenData.fid
  local itemName = data_getItemName(itemId)
  local tempView = CPopWarning.new({
    title = "提示",
    text = string.format("是否要清除#<CI:%d>%s#的效果", itemId, itemName),
    cancelFunc = cancelFunc,
    confirmFunc = function()
      netsend.netlifeskill.cancelLifeSkillBuff(1)
    end,
    align = CRichText_AlignType_Left
  })
  tempView:ShowCloseBtn(false)
end
function CLifeSkillContent:OnBtn_Wine_sub(obj, t)
  local wineData = g_LocalPlayer:getLifeSkillWineData()
  if wineData.wid == nil or wineData.wid == 0 or wineData.v == nil or wineData.v == 0 then
    return
  end
  local itemId = wineData.wid
  local itemName = data_getItemName(itemId)
  local tempView = CPopWarning.new({
    title = "提示",
    text = string.format("是否要清除#<CI:%d>%s#的效果", itemId, itemName),
    cancelFunc = cancelFunc,
    confirmFunc = function()
      netsend.netlifeskill.cancelLifeSkillBuff(2)
    end,
    align = CRichText_AlignType_Left
  })
  tempView:ShowCloseBtn(false)
end
function CLifeSkillContent:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_LifeSkillUpdate then
    self:ResetData()
  elseif msgSID == MsgID_LifeSkillBSDUpdate then
    self:ResetData()
  elseif msgSID == MsgID_LifeSkillFuUpdate then
    self:ResetData()
  elseif msgSID == MsgID_LifeSkillWineUpdate then
    self:ResetData()
  end
end
function CLifeSkillContent:Clear()
end
