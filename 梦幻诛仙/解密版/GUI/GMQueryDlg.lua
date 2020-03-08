local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ClientCmd = require("Main.ClientCmd")
local GMQueryDlg = Lplus.Extend(ECPanelBase, "GMQueryDlg")
local def = GMQueryDlg.define
local instance
def.field("userdata").ui_Input1 = nil
def.field("userdata").ui_Input2 = nil
def.field("userdata").ui_ListLeft = nil
def.field("userdata").ui_Label1 = nil
def.field("table").content = nil
def.static("=>", GMQueryDlg).Instance = function()
  if instance == nil then
    instance = GMQueryDlg()
  end
  return instance
end
def.override().OnCreate = function(self)
  local ui_Img0 = self.m_panel:FindDirect("Img_0")
  self.ui_Input1 = ui_Img0:FindDirect("Img_BgInput")
  self.ui_Input2 = ui_Img0:FindDirect("Img_BgInput2")
  local ui_GroupDetail = ui_Img0:FindDirect("Group_Detail")
  local ui_ScrollView = ui_GroupDetail:FindDirect("Group_List/Scroll View")
  self.ui_ListLeft = ui_ScrollView:FindDirect("List_Left")
  self.ui_Label1 = self.m_panel:FindDirect("Label1")
end
def.override().OnDestroy = function(self)
  self.ui_Input1 = nil
  self.ui_Input2 = nil
  self.ui_ListLeft = nil
  self.ui_Label1 = nil
end
def.method().ShowDlg = function(self)
  if not self.m_panel then
    self:CreatePanel(RESPATH.GM_QUERY_PANEL_RES, 0)
  end
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.method().SetListItemInfo = function(self)
  local count = #self.content
  local uiList = self.ui_ListLeft:GetComponent("UIList")
  uiList.itemCount = count
  uiList:Resize()
  for i = 1, count do
    local listItem = self.ui_ListLeft:FindDirect("item_" .. i)
    listItem:FindDirect("Label_1"):GetComponent("UILabel").text = self.content[i].name
    local strParams = {}
    if type(self.content[i]) == "table" and self.content[i].params ~= nil then
      for k, v in ipairs(self.content[i].params) do
        table.insert(strParams, v)
      end
    end
    listItem:FindDirect("Label_2"):GetComponent("UILabel").text = table.concat(strParams, " ")
  end
end
def.method("number").showItemDetail = function(self, index)
  local detail = {}
  table.insert(detail, "Name\239\188\154")
  table.insert(detail, self.content[index].name)
  table.insert(detail, "\n")
  local strParams = {}
  if type(self.content[index]) == "table" and self.content[index].params ~= nil then
    for k, v in ipairs(self.content[index].params) do
      table.insert(strParams, v)
    end
  end
  table.insert(detail, "Param\239\188\154")
  table.insert(detail, table.concat(strParams, " "))
  table.insert(detail, "\n")
  local desc = ""
  if self.content[index].desc ~= nil then
    desc = self.content[index].desc
  end
  table.insert(detail, "Description\239\188\154")
  table.insert(detail, desc)
  table.insert(detail, "\n")
  self.ui_Label1:GetComponent("UILabel").text = table.concat(detail)
end
def.method("string", "string").onTextChange = function(self, id, val)
  if id == "Img_BgInput" then
    self.content = ClientCmd.SearchCmd(val, true)
    self:SetListItemInfo()
    self.ui_Label1:GetComponent("UILabel").text = ""
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_Confirm" then
    local enterCmd = self.ui_Input1:GetComponent("UIInput"):get_value()
    ClientCmd.DoClientCmd(enterCmd)
  elseif id == "Btn_Confirm2" then
    local enterTag = self.ui_Input2:GetComponent("UIInput"):get_value()
    self.content = ClientCmd.SearchCmd(enterTag, false)
    self:SetListItemInfo()
    self.ui_Label1:GetComponent("UILabel").text = ""
  elseif string.find(id, "item_", 1) ~= nil then
    local i = tonumber(id:split("_")[2])
    self:showItemDetail(i)
  end
end
GMQueryDlg.Commit()
return GMQueryDlg
