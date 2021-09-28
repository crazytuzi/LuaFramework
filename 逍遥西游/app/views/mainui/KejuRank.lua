KejuRank = class("KejuRank", CcsSubView)
function KejuRank:ctor()
  KejuRank.super.ctor(self, "views/kejurank.csb", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:ListenMessage(MsgID_Keju)
  self:getNode("txt_loading"):setEnabled(false)
end
function KejuRank:OnMessage(msgSID, ...)
  if msgSID == MsgID_Keju_HadGetRank then
    local arg = {
      ...
    }
    self:Load(arg[1])
  end
end
function KejuRank:Load(data)
  if data == nil or #data == 0 then
    self:getNode("txt_loading"):setEnabled(true)
    self:getNode("txt_loading"):setText("科举成绩还没有出来")
    return
  end
  self:getNode("txt_loading"):setEnabled(false)
  self.list_obj = self:getNode("scroller_content")
  local listSize = self.list_obj:getInnerContainerSize()
  local txt_des = CRichText.new({
    width = listSize.width - 4,
    verticalSpace = 0,
    font = KANG_TTF_FONT,
    fontSize = 28,
    color = ccc3(255, 196, 98),
    align = CRichText_AlignType_Left
  })
  self.list_obj:addChild(txt_des)
  for i, d in ipairs(data) do
    local txt = string.format("%d  %s", i, d.name)
    txt_des:addRichText(txt)
    txt_des:newLine()
  end
  local desTxtSize = txt_des:getRichTextSize()
  totalH = desTxtSize.height
  if totalH > listSize.height then
    self.list_obj:setInnerContainerSize(CCSize(listSize.width, totalH))
  else
    txt_des:setPosition(ccp(0, listSize.height - totalH))
  end
end
function KejuRank:OnBtn_Close(btnObj, touchType)
  self:CloseSelf()
end
function KejuRank:Clear()
end
