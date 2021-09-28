CTestRegView = class("CTestRegView", CcsUIView)
function CTestRegView:ctor()
  CTestRegView.super.ctor(self, "views/testview_reg.json")
  local btnBatchListener = {
    btn_reg = {
      listener = handler(self, self.Btn_Reg),
      variName = "m_Btn_Reg"
    },
    btn_cancel = {
      listener = handler(self, self.Btn_Cancel),
      variName = "m_BtnCancel"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  print("------------>>m_Btn_Reg:", self.m_Btn_Reg:getName(), self.m_Btn_Reg:getWidgetType())
  print("------------>>m_BtnCancel:", self.m_BtnCancel:getName(), self.m_BtnCancel:getWidgetType())
end
function CTestRegView:Btn_Reg(obj, t)
  print("==>>CTestRegView:Btn_Reg")
end
function CTestRegView:Btn_Cancel(obj, t)
  print("==>>CTestRegView:Btn_Cancel")
  CTestLoginView:new():ShowAsScene()
end
