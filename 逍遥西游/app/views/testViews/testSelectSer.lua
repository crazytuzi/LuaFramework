CTestSelectSerView = class("CTestSelectSerView", CcsSceneView)
function CTestSelectSerView:ctor(ip, port)
  CTestSelectSerView.super.ctor(self, "views/testview_selectser.json")
  local btnBatchListener = {
    btn_select = {
      listener = handler(self, self.Btn_Select),
      variName = "m_BtnSelect"
    },
    btn_login_nmg = {
      listener = handler(self, self.Btn_LoginNmg),
      variName = "btn_login_nmg"
    },
    btn_login_mm = {
      listener = handler(self, self.Btn_LoginMomo),
      variName = "btn_login_mm"
    },
    btn_logout = {
      listener = handler(self, self.Btn_Logout),
      variName = "btn_logout"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:getNode("pic_bg"):setSize(CCSize(display.width, display.height))
  self:getUINode():setSize(CCSize(display.width, display.height))
  self.m_SerList = channel.serverList
  for _, data in ipairs(self.m_SerList) do
    local serItem = CSerItem.new(data.name, data.ip, data.port)
    self:getNode("setlist"):pushBackCustomItem(serItem:getUINode())
  end
  self:getNode("setlist"):addTouchItemListenerListView(handler(self, self.onSelected))
  soundManager.playLoginMusic()
  if false then
    do
      local function clickListener()
        print("-->>:", clickListener)
        require("app.views.commonviews.ShowMomoTest")
        self:getUINode():addChild(ShowMomoTest.new(), 99999)
      end
      local clickObj = TestcreateTxtClickObj(self:getUINode(), 100, 100, "测试陌陌", clickListener, ccc3(255, 0, 0), 255, 9999)
    end
  end
  self.btn_login_nmg:setEnabled(false)
  self.btn_login_mm:setEnabled(false)
  self.btn_logout:setEnabled(false)
  local ip = getConfigByName("lastSerIp")
  local port = getConfigByName("lastSerPort")
  for _, data in ipairs(self.m_SerList) do
    if ip == data.ip and port == data.port then
      self:SetIpAndPort(data.ip, data.port, data.name)
      return
    end
  end
  self:SetIpAndPort()
end
function CTestSelectSerView:SetIpAndPort(ip, port, name)
  self.m_Ip = ip
  self.m_Port = port
  if self.m_Ip == nil or self.m_Port == nil then
    self:getNode("ipTxt"):setText("请选择服务器")
  elseif name ~= nil then
    self:getNode("ipTxt"):setText(name)
  else
    self:getNode("ipTxt"):setText("")
  end
end
function CTestSelectSerView:onSelected(item, index, listObj)
  print("CTestSelectSerView:onSelected(item, index, listObj)", item, index, listObj)
  local tempItem = item.m_UIViewParent
  local ip = tempItem:getIp()
  local port = tempItem:getPort()
  local name = tempItem:getName()
  self:SetIpAndPort(ip, port, name)
end
function CTestSelectSerView:Btn_Select(obj, t)
  print("==>>CTestSelectSerView:Btn_Select")
  if self.m_Ip == nil or self.m_Port == nil then
    ShowNotifyTips("请先选择服务器")
    return
  end
  setConfigData("lastSerIp", self.m_Ip)
  setConfigData("lastSerPort", self.m_Port)
  CTestLoginView.new(false):Show()
end
function CTestSelectSerView:Btn_LoginNmg(obj, t)
  print("==>>CTestSelectSerView:Btn_LoginNmg")
end
function CTestSelectSerView:Btn_LoginMomo(obj, t)
  print("==>>CTestSelectSerView:Btn_LoginMomo")
end
function CTestSelectSerView:Btn_Logout(obj, t)
  print("==>>CTestSelectSerView:Btn_Logout")
end
CSerItem = class("CSerItem", CcsSubView)
function CSerItem:ctor(name, ip, port)
  CSerItem.super.ctor(self, "views/testview_selectser_item.json")
  self.m_Name = name
  self.m_Ip = ip
  self.m_Port = port
  self:getNode("txt"):setText(name)
end
function CSerItem:getIp()
  return self.m_Ip
end
function CSerItem:getPort()
  return self.m_Port
end
function CSerItem:getName()
  return self.m_Name
end
