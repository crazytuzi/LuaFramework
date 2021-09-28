TthjPlayerPro = class("TthjPlayerPro", CcsSubView)
function TthjPlayerPro:ctor(param, itemheight, height_hj)
  TthjPlayerPro.super.ctor(self, "views/fb_tthj_playpro.csb", {isAutoCenter = true, opacityBg = 100})
  self.m_param = param or {}
  self.m_itemheight = itemheight or 44
  self.m_hj = height_hj or 5
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.txt_title = self:getNode("txt_title")
  self.img_tips = self:getNode("img_tips")
  self.txt_tips = self:getNode("txt_tips")
  self.p_content = self:getNode("p_content")
  self.p_content:setVisible(false)
  self:initList(param)
end
function TthjPlayerPro:initList(mparam)
  local px, py = self.p_content:getPosition()
  px, py = px + self.m_itemheight / 2, py + self.m_itemheight / 4
  local isTeamIndex = true
  for ind = 1, #mparam - 1 do
    if mparam[ind] and mparam[ind + 1] and mparam[ind].progress ~= mparam[ind + 1].progress then
      isTeamIndex = false
      break
    end
  end
  if isTeamIndex == false then
    table.sort(mparam, function(va, vb)
      if va == nil and vb == nil then
        return false
      end
      if va == nil and vb ~= nil then
        return true
      end
      if va ~= nil and vb == nil then
        return false
      end
      if va.progress == nil or vb.progress == nil then
        return false
      end
      return va.progress < vb.progress
    end)
  end
  for k, v in pairs(mparam) do
    local cury = py - (k - 1) * (self.m_itemheight + self.m_hj)
    local headicon = createWidgetFrameHeadIconByRoleTypeID(v.rtype, CCSizeMake(self.m_itemheight, self.m_itemheight), false, {x = 0, y = -5})
    headicon:setPosition(ccp(px, cury))
    self:addChild(headicon)
    local player = g_DataMgr:getPlayer(v.pid)
    local zs = 1
    if player then
      local hero = player:getMainHero()
      if hero then
        zs = hero:getProperty(PROPERTY_ZHUANSHENG)
      end
    end
    local ncolor = NameColor_MainHero[zs] or ccc3(255, 150, 0)
    local pname = ui.newTTFLabel({
      text = v.name,
      fontSize = 18,
      font = "Arial-BoldMT",
      color = ncolor,
      align = CRichText_AlignType_Left
    })
    pname:setAnchorPoint(ccp(0, 0.5))
    pname:setPosition(ccp(px + self.m_itemheight, cury))
    self:addNode(pname)
    local gq = v.progress + 1
    if gq > 6 then
      gq = 6
    end
    local showStr = string.format("第%d关", gq)
    if 0 >= v.leftcnt then
      showStr = "已通关"
    end
    local txtpro = ui.newTTFLabel({
      text = showStr,
      fontSize = 18,
      font = "Arial-BoldMT",
      color = ccc3(255, 255, 255),
      align = CRichText_AlignType_Left
    })
    txtpro:setAnchorPoint(ccp(0, 0.5))
    txtpro:setPosition(ccp(px + self.m_itemheight + pname:getFontSize() * 5 + 20, cury))
    self:addNode(txtpro)
  end
end
function TthjPlayerPro:OnBtn_Close()
  self:CloseSelf()
end
