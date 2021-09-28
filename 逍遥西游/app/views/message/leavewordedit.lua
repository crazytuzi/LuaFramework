CLeaveWordEdit = class("CLeaveWordEdit", CBpEditBase)
function CLeaveWordEdit:ctor(txtLisener)
  CLeaveWordEdit.super.ctor(self, "", txtLisener)
  self:getNode("txt_name"):setText("留言板")
  self.btn_publish:setTitleText("保存留言")
  self.m_MaxInputNum = 30
  self.input_box:SetMaxInputLength(self.m_MaxInputNum)
  self:caculateCharNum()
  self.input_box:SetFiledPlaceHolder("请输入留言")
end
function CLeaveWordEdit:OnBtn_Publish()
  if activity.leaveword:getStatus() == 1 then
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
    netsend.netmessage.writeLeaveWord(text)
  end
  self:CloseSelf()
end
