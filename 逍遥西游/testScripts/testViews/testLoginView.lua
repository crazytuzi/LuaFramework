CTestLoginView = class("CTestLoginView", CcsUIView)
function CTestLoginView:ctor()
  CTestLoginView.super.ctor(self, "views/testview_login.json")
  local btnBatchListener = {
    btn_login = {
      listener = handler(self, self.Btn_Login),
      variName = "m_BtnLogin"
    },
    btn_reg = {
      listener = handler(self, self.Btn_Reg),
      variName = "m_BtnReg"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  print("------------>>m_BtnLogin:", self.m_BtnLogin:getName(), self.m_BtnLogin:getWidgetType())
  print("------------>>m_BtnReg:", self.m_BtnReg:getName(), self.m_BtnReg:getWidgetType())
end
function CTestLoginView:Btn_Login(obj, t)
  print("==>>CTestLoginView:Btn_Login")
end
function CTestLoginView:Btn_Reg(obj, t)
  print("==>>CTestLoginView:Btn_Reg")
  CTestRegView:new():ShowAsScene()
end
