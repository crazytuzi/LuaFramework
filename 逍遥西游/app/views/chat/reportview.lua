JuBaoItemId_ZangHua = 1
JuBaoItemId_NickName = 2
JuBaoItemId_WaiGua = 3
JuBaoItemId_ZhaPian = 4
JuBaoItemId_GuangGao = 5
JuBaoItemId_QiTa = 6
CJuBaoView = class("CJuBaoView", CcsSubView)
function CJuBaoView:ctor(pid, name, msg)
  CJuBaoView.super.ctor(self, "views/jubao_view.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_quxiao = {
      listener = handler(self, self.Btn_QuXiao),
      variName = "btn_quxiao"
    },
    btn_jubao = {
      listener = handler(self, self.Btn_JuBao),
      variName = "btn_jubao"
    },
    btn_nickname = {
      listener = handler(self, self.Btn_NickName),
      variName = "btn_nickname"
    },
    btn_zanghua = {
      listener = handler(self, self.Btn_ZangHua),
      variName = "btn_zanghua"
    },
    btn_waigua = {
      listener = handler(self, self.Btn_WaiGua),
      variName = "btn_waigua"
    },
    btn_zhapian = {
      listener = handler(self, self.Btn_ZhaPian),
      variName = "btn_zhapian"
    },
    btn_guanggao = {
      listener = handler(self, self.Btn_GuangGao),
      variName = "btn_guanggao"
    },
    btn_qita = {
      listener = handler(self, self.Btn_QiTa),
      variName = "btn_qita"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_PlayerId = pid
  self.m_JBMsg = msg or ""
  local playername = self:getNode("player_name")
  if self.m_PlayerId == nil or name == nil then
    self:CloseSelf()
    return
  end
  local name = name .. "？"
  playername:setText(name)
  self.sel_nickname = self:getNode("sel_nickname")
  self.sel_zanghua = self:getNode("sel_zanghua")
  self.sel_waigua = self:getNode("sel_waigua")
  self.sel_zhapian = self:getNode("sel_zhapian")
  self.sel_guanggao = self:getNode("sel_guanggao")
  self.sel_qita = self:getNode("sel_qita")
  self.input_box = self:getNode("input_txt")
  self.m_showItem = JuBaoItemId_GuangGao
  self:ListenMessage(MsgID_Message)
  self.m_MaxInputNum = 100
  local size = self.input_box:getContentSize()
  TextFieldEmoteExtend.extend(self.input_box, self.m_UINode, {
    width = size.width,
    align = CRichText_AlignType_Left
  })
  self.input_box:setMaxLengthEnabled(false)
  self.input_box:SetMaxInputLength(self.m_MaxInputNum)
  self.input_box:SetKeyBoardListener(handler(self, self.onKeyBoardListener))
  self.input_box:SetEnableMulti(true)
  self:ShowSelectItem(self.m_showItem)
end
function CJuBaoView:onKeyBoardListener(event)
  if event == TEXTFIELDEXTEND_EVENT_TEXT_CHANGE then
  end
end
function CJuBaoView:OnBtn_Close()
  self:CloseSelf()
end
function CJuBaoView:Btn_QuXiao()
  self:CloseSelf()
end
function CJuBaoView:Btn_JuBao()
  local msg = self.input_box:GetFieldText()
  if self.m_showItem ~= nil and self.m_PlayerId ~= nil then
    if self.m_showItem == JuBaoItemId_QiTa and msg == "" then
      ShowNotifyTips("请输入举报内容")
      return
    end
    netsend.netbaseptc.reportPlayer(self.m_PlayerId, self.m_showItem, msg, self.m_JBMsg)
  else
    ShowNotifyTips("请选择举报内容")
  end
end
function CJuBaoView:Btn_NickName()
  self:ShowSelectItem(JuBaoItemId_NickName)
  self.input_box:SetFieldText("")
end
function CJuBaoView:Btn_ZangHua()
  self:ShowSelectItem(JuBaoItemId_ZangHua)
  self.input_box:SetFieldText("")
end
function CJuBaoView:Btn_WaiGua()
  self:ShowSelectItem(JuBaoItemId_WaiGua)
  self.input_box:SetFieldText("")
end
function CJuBaoView:Btn_ZhaPian()
  self:ShowSelectItem(JuBaoItemId_ZhaPian)
  self.input_box:SetFieldText("")
end
function CJuBaoView:Btn_GuangGao()
  self:ShowSelectItem(JuBaoItemId_GuangGao)
  self.input_box:SetFieldText("")
end
function CJuBaoView:Btn_QiTa()
  self:ShowSelectItem(JuBaoItemId_QiTa)
end
function CJuBaoView:OnMessage(msgSID, ...)
  local arg = {
    ...
  }
  if msgSID == MsgID_Message_JuBaoWanJia then
    ShowNotifyTips("举报成功")
    g_MissionMgr:setCurTimePoint()
    self:CloseSelf()
  end
end
function CJuBaoView:ShowSelectItem(showitem)
  self.sel_nickname:setVisible(showitem == JuBaoItemId_NickName)
  self.sel_zanghua:setVisible(showitem == JuBaoItemId_ZangHua)
  self.sel_waigua:setVisible(showitem == JuBaoItemId_WaiGua)
  self.sel_zhapian:setVisible(showitem == JuBaoItemId_ZhaPian)
  self.sel_guanggao:setVisible(showitem == JuBaoItemId_GuangGao)
  self.sel_qita:setVisible(showitem == JuBaoItemId_QiTa)
  self.input_box:setTouchEnabled(showitem == JuBaoItemId_QiTa)
  self.m_showItem = showitem
end
function CJuBaoView:Clear()
  if self.input_box ~= nil then
    self.input_box:CloseTheKeyBoard()
    self.input_box:ClearTextFieldExtend()
  end
end
