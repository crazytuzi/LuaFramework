local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local StringListDlg = Lplus.Extend(ECPanelBase, "StringListDlg")
local def = StringListDlg.define
local instance
def.const("number").REQUESTINTERVAL = 2
def.field("table").strTbl = nil
def.field("function").onRequest = nil
def.field("userdata").scroll = nil
def.field("number").step = 1
def.field("number").lastRequest = 0
def.field("table").context = nil
def.field("number").lastIndex = 0
def.static("table", "number", "function").ShowDlg = function(context, step, onRequest)
  local dlg = StringListDlg()
  dlg.context = context
  dlg.step = step
  dlg.strTbl = {}
  dlg.onRequest = onRequest
  dlg:CreatePanel(RESPATH.PREFAB_CORPS_HISTORY, 2)
  dlg:SetModal(true)
end
def.override().OnCreate = function(self)
  self.scroll = self.m_panel:FindDirect("Img_Bg/Group_Note/Scrollview_Note"):GetComponent("UIScrollView")
  self:UpdateLabel()
  self:RequestMore()
end
def.method("number", "number", "table").AppendContent = function(self, start, lastIndex, strs)
  if self.m_panel and not self.m_panel.isnil then
    if start == 0 then
      self.strTbl = {}
      self.lastIndex = lastIndex
    elseif start == self.lastIndex then
      if lastIndex ~= 0 then
        self.lastIndex = lastIndex
      end
    else
      return
    end
    if #strs > 0 then
      for k, v in ipairs(strs) do
        table.insert(self.strTbl, v)
      end
      self:UpdateLabel()
    elseif start ~= 0 then
      Toast(textRes.Corps[68])
    end
  end
end
def.method().RequestMore = function(self)
  if self.onRequest then
    self.lastRequest = GetServerTime()
    self.onRequest(self.context, self.lastIndex, self.step, function(start, lastIndex, strs)
      self:AppendContent(start, lastIndex, strs)
    end)
  end
end
def.method().Refresh = function(self)
  if self.onRequest then
    self.lastRequest = GetServerTime()
    self.onRequest(self.context, 0, self.step, function(start, lastIndex, strs)
      self:AppendContent(start, lastIndex, strs)
    end)
  end
end
def.method().UpdateLabel = function(self)
  local label = self.m_panel:FindDirect("Img_Bg/Group_Note/Scrollview_Note/Drag_Tips"):GetComponent("UILabel")
  local content = table.concat(self.strTbl, "\n")
  label:set_text(content)
end
def.method("string").onDragEnd = function(self, id)
  warn("onDragEnd", id, self.scroll:GetDragAmount())
  if id == "Drag_Tips" then
    local dragAmount = self.scroll:GetDragAmount()
    if dragAmount.y > 1.01 then
      if GetServerTime() - self.lastRequest > StringListDlg.REQUESTINTERVAL then
        self:RequestMore()
      end
    elseif dragAmount.y < -0.01 and GetServerTime() - self.lastRequest > StringListDlg.REQUESTINTERVAL then
      self:Refresh()
    end
  end
end
def.override().OnDestroy = function(self)
  self.strTbl = nil
  self.onRequest = nil
  self.scroll = nil
  self.step = 1
  self.lastRequest = 0
  self.context = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
return StringListDlg.Commit()
