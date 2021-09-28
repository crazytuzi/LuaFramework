CZhaoQinLeaveWordEdit = class("CZhaoQinLeaveWordEdit", CBpEditBase)
function CZhaoQinLeaveWordEdit:ctor(txtLisener)
  CZhaoQinLeaveWordEdit.super.ctor(self, "", txtLisener)
  self:getNode("txt_name"):setText("留言板")
  self.btn_publish:setTitleText("保存留言")
  self.m_MaxInputNum = 30
  self.input_box:SetMaxInputLength(self.m_MaxInputNum)
  self:caculateCharNum()
  self.input_box:SetFiledPlaceHolder("请输入留言")
  self:setCostPrice()
end
function CZhaoQinLeaveWordEdit:OnBtn_Publish()
  local text = self.input_box:GetFieldText()
  if string.len(text) <= 0 then
    ShowNotifyTips("留言内容不能为空")
    return
  end
  local check, bword = checkText_DFAFilter(text)
  if not check then
    ShowNotifyTips(string.format("留言不能包含敏感词:#<R>%s#", bword))
    return
  end
  if self.m_OkListener then
    self.m_OkListener(text)
    self:ClearListeners()
  end
  netsend.netactivity.localLeaveMsg(text)
  self:CloseSelf()
end
function CZhaoQinLeaveWordEdit:setCostPrice()
  local costMoney = data_Variables.QixiMsgCostCoin
  local x, y = self.btn_cancel:getPosition()
  local btn_size = self.btn_cancel:getContentSize()
  local txt_label = CCLabelTTF:create("花费", ITEM_NUM_FONT, 22)
  local txt_label_size = txt_label:getContentSize()
  local txt_price = CCLabelTTF:create("", ITEM_NUM_FONT, 22)
  local bgSprite = display.newSprite("views/common/bg/bg1034.png")
  local bgSize = bgSprite:getContentSize()
  local tempImg = display.newSprite(data_getResPathByResID(RESTYPE_COIN))
  tempImg:setScale(0.7)
  self:addNode(bgSprite)
  self:addNode(txt_label)
  self:addNode(tempImg)
  self:addNode(txt_price)
  txt_label:setPosition(ccp(x - txt_label_size.width, y + 3 * btn_size.height / 2))
  txt_label:setColor(ccc3(23, 235, 219))
  bgSprite:setPosition(ccp(x + btn_size.width - txt_label_size.width, y + 3 * btn_size.height / 2))
  local Icon_x = x + btn_size.width - txt_label_size.width - bgSize.width / 2
  tempImg:setPosition(ccp(Icon_x, y + 3 * btn_size.height / 2))
  tempImg:setAnchorPoint(ccp(0.5, 0.5))
  txt_price:setPosition(ccp(x + btn_size.width - txt_label_size.width, y + 3 * btn_size.height / 2))
  txt_price:setString(tostring(costMoney))
end
