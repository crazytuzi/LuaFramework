CUseChengZhangDan = class("CUseChengZhangDan", CcsSubView)
function CUseChengZhangDan:ctor(params, data)
  CUseChengZhangDan.super.ctor(self, "views/use_chengzhandan.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local confirmFunc = params.confirmFunc
  local confirmFlag = params.confirmFlag
  local title = params.title or ""
  local dec = params.dec or ""
  local btnBatchListener = {
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:getNode("title"):setText(title)
  if confirmFlag == nil then
    confirmFlag = true
  end
  self.m_confirmFlag = confirmFlag
  self.m_confirmFunc = confirmFunc
  self:resetText(dec)
  local scene = getCurSceneView()
  if scene then
    scene:addSubView({
      subView = self,
      zOrder = MainUISceneZOrder.menuView
    })
  end
  self:setViewData(data)
end
function CUseChengZhangDan:OnBtn_Confirm()
  if self.m_confirmFunc ~= nil then
    self.m_confirmFunc(obj, t)
  end
  if self.m_confirmFlag == true then
    self:CloseSelf()
  end
end
function CUseChengZhangDan:OnBtn_Close()
  self:CloseSelf()
end
function CUseChengZhangDan:resetText(text, emptyLineH)
  local textSize = self:getNode("txt_dec"):getSize()
  local x, y = self:getNode("txt_dec"):getPosition()
  if text == nil then
    self:getNode("txt_dec"):setVisible(false)
  else
    local textBox = CRichText.new({
      width = textSize.width,
      verticalSpace = 0,
      font = KANG_TTF_FONT,
      fontSize = 22,
      color = ccc3(255, 255, 255),
      align = self.m_Align,
      emptyLineH = emptyLineH
    })
    textBox:addRichText(text)
    self:addChild(textBox)
    textBox:setPosition(ccp(x, y))
    textBox:setAnchorPoint(ccp(0.5, 0.5))
  end
end
function CUseChengZhangDan:setViewData(params)
  local grow = params.grow
  local qixue = params.bhp
  local fali = params.bmp
  local gongji = params.bap
  local sudu = params.bsp
  local txt_qx = self:getNode("txt_qx")
  local txt_qx_num = self:getNode("txt_qx_num")
  local txt_fl = self:getNode("txt_fl")
  local txt_fl_num = self:getNode("txt_fl_num")
  local txt_gj = self:getNode("txt_gj")
  local txt_gj_num = self:getNode("txt_gj_num")
  local txt_sd = self:getNode("txt_sd")
  local txt_sd_num = self:getNode("txt_sd_num")
  local txt_czl = self:getNode("txt_czl")
  local txt_czl_num = self:getNode("txt_czl_num")
  txt_czl_num:setText(string.format("+%f", grow))
  txt_qx:setVisible(qixue ~= nil)
  txt_qx_num:setVisible(qixue ~= nil)
  if qixue ~= nil then
    txt_qx_num:setText(string.format("+%d", qixue))
  end
  txt_fl:setVisible(fali ~= nil)
  txt_fl_num:setVisible(fali ~= nil)
  if fali ~= nil then
    txt_fl_num:setText(string.format("+%d", fali))
  end
  txt_gj:setVisible(gongji ~= nil)
  txt_gj_num:setVisible(gongji ~= nil)
  if gongji ~= nil then
    txt_gj_num:setText(string.format("+%d", gongji))
  end
  txt_sd:setVisible(sudu ~= nil)
  txt_sd_num:setVisible(sudu ~= nil)
  if sudu ~= nil then
    txt_sd_num:setText(string.format("+%d", sudu))
  end
  if qixue ~= nil and fali == nil and gongji == nil and sudu == nil then
    txt_qx:setText("气血初值：")
    txt_qx:setVisible(qixue ~= nil)
    txt_qx_num:setVisible(qixue ~= nil)
    txt_qx_num:setText(string.format("+%d", qixue))
  elseif qixue == nil and fali ~= nil and gongji == nil and sudu == nil then
    txt_qx:setText("法力初值：")
    txt_qx:setVisible(fali ~= nil)
    txt_qx_num:setVisible(fali ~= nil)
    txt_qx_num:setText(string.format("+%d", fali))
    txt_fl:setVisible(false)
    txt_fl_num:setVisible(false)
  elseif qixue == nil and fali == nil and gongji ~= nil and sudu == nil then
    txt_qx:setText("攻击初值：")
    txt_qx:setVisible(gongji ~= nil)
    txt_qx_num:setVisible(gongji ~= nil)
    txt_qx_num:setText(string.format("+%d", gongji))
    txt_gj:setVisible(false)
    txt_gj_num:setVisible(false)
  elseif qixue == nil and fali == nil and gongji == nil and sudu ~= nil then
    txt_qx:setText("速度初值：")
    txt_qx:setVisible(sudu ~= nil)
    txt_qx_num:setVisible(sudu ~= nil)
    txt_qx_num:setText(string.format("+%d", sudu))
    txt_sd:setVisible(false)
    txt_sd_num:setVisible(false)
  end
end
function CUseChengZhangDan:Clear()
  self.m_confirmFunc = nil
end
