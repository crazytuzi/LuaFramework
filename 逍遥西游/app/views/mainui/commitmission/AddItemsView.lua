AddItemViews = class("AddItemViews", CcsSubView)
function AddItemViews:ctor(param)
  AddItemViews.super.ctor(self, "views/presentbuyview.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_left = {
      listener = handler(self, self.OnBtn_Left),
      variName = "btn_left"
    },
    btn_right = {
      listener = handler(self, self.OnBtn_Right),
      variName = "btn_right"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_ItemObjId = param.itemID
  self.m_itemIns = g_LocalPlayer:GetOneItem(self.m_ItemObjId)
  self.m_listener_RightBtn = param.listener_RightBtn
  self.m_listener_LeftBtn = param.listener_LeftBtn
  self.m_needClose = param.needClose or 1
  self.m_RightBtnTip = param.RightBtnTips
  self.m_maxNum = param.maxNum or 10
  self.m_curNum = 0
  self.m_curViewCommitNum = 0
  local txt_RightBtn = param.txt_RightBtn or "确定"
  local txt_LeftBtn = param.txt_LeftBtn or "取消"
  self.btn_left:setTitleText(txt_LeftBtn)
  self.btn_right:setTitleText(txt_RightBtn)
  local numTitle = self:getNode("txt_gmsl")
  if param.txt_numTitle and txt_numTitle ~= "" then
    numTitle:setVisible(true)
    numTitle:setText(param.txt_numTitle)
  else
    numTitle:setVisible(false)
    numTitle:setText("")
  end
  self.m_itemNum = self:getNode("text_num")
  local num = 1
  if param.initNum and 0 < param.initNum then
    num = param.initNum
  end
  self.m_curNum = num
  dump(self.m_itemIns, "self.m_itemIns")
  self.list_detail = self:getNode("list_detail")
  local x, y = self.list_detail:getPosition()
  local lSize = self.list_detail:getContentSize()
  local w, h = lSize.width, lSize.height
  self.m_ItemDetailText = CItemDetailText.new(self.m_ItemObjId, {
    width = lSize.width
  })
  self.list_detail:pushBackCustomItem(self.m_ItemDetailText)
  local paramTable = {}
  if self.m_ItemDetailHead then
    self.m_ItemDetailHead:removeFromParent()
  end
  self.m_ItemDetailHead = CItemDetailHead.new({
    width = w - 5
  })
  self:getNode("boxbg"):addChild(self.m_ItemDetailHead)
  self.m_ItemDetailHead:ShowItemDetail(self.m_ItemObjId)
  local newSize = self.m_ItemDetailHead:getContentSize()
  self.m_ItemDetailHead:setPosition(ccp(x, y + h + newSize.height))
  local addpro_bg = self:getNode("bg_num")
  local x, y = addpro_bg:getPosition()
  local p = addpro_bg:getParent()
  self.btn_addnum = createClickButton("views/rolelist/btn_addpro.png", "views/rolelist/btn_addpro_gray.png", handler(self, self.Btn_AddNum))
  self.btn_addMax = createClickButton("views/rolelist/btn_max.png", "views/rolelist/btn_maxpro_gray.png", handler(self, self.Btn_MaxNum))
  p:addChild(self.btn_addnum)
  p:addChild(self.btn_addMax)
  self.btn_addnum:setPosition(ccp(x + 37, y - 26))
  self.btn_addMax:setPosition(ccp(x + 87, y - 26))
  self.btn_subnum = createClickButton("views/rolelist/btn_subpro.png", "views/rolelist/btn_subpro_gray.png", handler(self, self.Btn_SubNum))
  p:addChild(self.btn_subnum)
  self.btn_subnum:setPosition(ccp(x - 83, y - 26))
  self.btn_addnum:setVisible(isShowAddBtn ~= false)
  self.btn_addMax:setVisible(isShowAddBtn ~= false)
  self.btn_subnum:setVisible(isShowAddBtn ~= false)
  self:setNum(self.m_curNum)
  self:ListenMessage(MsgID_ItemInfo)
end
function AddItemViews:OnBtn_Left()
  if self.m_listener_LeftBtn then
    self.m_listener_LeftBtn()
  end
  if self.m_needClose == 3 or self.m_needClose == 1 then
    self:CloseSelf()
  end
end
function AddItemViews:OnBtn_Right()
  if self.m_curNum <= 0 and self.m_RightBtnTip then
    ShowNotifyTips(self.m_RightBtnTip)
    return
  end
  if self.m_listener_RightBtn then
    self.m_listener_RightBtn(self.m_ItemObjId, self.m_curNum)
    self.m_curViewCommitNum = self.m_curViewCommitNum + self.m_curNum
  end
  local PackMaxNum = self.m_itemIns:getProperty(ITEM_PRO_NUM)
  local upLimit = math.min(self.m_maxNum, PackMaxNum - self.m_curViewCommitNum)
  self.m_maxNum = self.m_maxNum - self.m_curNum
  if 0 > self.m_maxNum then
    self.m_maxNum = 0
  end
  print("**********************************************  ", self.m_maxNum, self.m_curNum, upLimit, self.m_curViewCommitNum)
  if (self.m_needClose == 3 or self.m_needClose == 2) and upLimit < self.m_curNum or 0 >= self.m_maxNum then
    self:CloseSelf()
  else
    self.m_curNum = 1
    self:setNum(self.m_curNum)
  end
end
function AddItemViews:Btn_AddNum()
  self:setNum(self.m_curNum + 1)
end
function AddItemViews:Btn_MaxNum()
  local PackMaxNum = self.m_itemIns:getProperty(ITEM_PRO_NUM)
  local upLimit = math.min(self.m_maxNum, PackMaxNum - self.m_curViewCommitNum)
  self:setNum(upLimit)
end
function AddItemViews:Btn_SubNum()
  self:setNum(self.m_curNum - 1)
end
function AddItemViews:setNum(num)
  local PackMaxNum = self.m_itemIns:getProperty(ITEM_PRO_NUM)
  local upLimit = math.min(self.m_maxNum, PackMaxNum - self.m_curViewCommitNum)
  if num > upLimit or num < 1 then
    print("数据已经溢出 ...")
    return
  end
  if num == upLimit then
  elseif num < upLimit and num > 1 then
    self.m_itemNum:setText(tostring(num))
    self.btn_addnum:setButtonDisableState(true)
    self.btn_addMax:setButtonDisableState(true)
    self.btn_subnum:setButtonDisableState(true)
  elseif num == 1 then
    self.m_itemNum:setText(tostring(num))
    self.btn_addnum:setButtonDisableState(true)
    self.btn_addMax:setButtonDisableState(true)
    self.btn_subnum:setButtonDisableState(false)
  end
  self.m_curNum = num
  self.m_itemNum:setText(tostring(num))
  self.btn_addnum:setButtonDisableState(num < upLimit)
  self.btn_addMax:setButtonDisableState(num < upLimit)
  self.btn_subnum:setButtonDisableState(num > 1)
end
function AddItemViews:Clear()
  self.m_listener_RightBtn = nil
  self.m_listener_LeftBtn = nil
end
function ShowAddItemsView(param)
  getCurSceneView():addSubView({
    subView = AddItemViews.new(param),
    zOrder = MainUISceneZOrder.menuView
  })
end
