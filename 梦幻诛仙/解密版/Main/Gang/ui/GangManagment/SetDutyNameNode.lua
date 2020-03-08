local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local SetDutyNameNode = Lplus.Extend(TabNode, "SetDutyNameNode")
local GangUtility = require("Main.Gang.GangUtility")
local GangData = require("Main.Gang.data.GangData")
local def = SetDutyNameNode.define
def.field("table").dutyNameTbl = nil
def.field("table").nameTbl = nil
def.field("number").curNameIndex = 1
def.field("number").designDutyNameId = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.dutyNameTbl = nil
end
def.override().OnShow = function(self)
  self.designDutyNameId = GangData.Instance():GetDesignDutyNamId()
  self.dutyNameTbl, self.nameTbl = self:GetDutyNameTbl()
  local popList = self.m_node:FindDirect("Btn_List"):GetComponent("UIPopupList")
  if 0 ~= #self.dutyNameTbl then
    popList:set_items(self.nameTbl)
    popList:set_selectIndex(self.curNameIndex)
    popList:set_value(self.nameTbl[self.curNameIndex + 1])
    self:UnFoldList()
  else
    popList:SetActive(false)
  end
  self:FillGangDutyNameList()
  self:UpdateCost()
end
def.method().UpdateCost = function(self)
  local dutyNameList = self.dutyNameTbl[self.curNameIndex + 1]
  if nil == dutyNameList then
    return
  end
  local Btn_Modify = self.m_node:FindDirect("Btn_Modify")
  local Group_Cost = Btn_Modify:FindDirect("Group_Cost")
  local Label_Num = Group_Cost:FindDirect("Label_Num"):GetComponent("UILabel")
  Label_Num:set_text(dutyNameList.costYuanBao)
end
def.method("=>", "table", "table").GetDutyNameTbl = function(self)
  local list = {}
  local names = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GANG_DUTY_NAME_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local dutyNameList = {}
    dutyNameList.id = DynamicRecord.GetIntValue(entry, "id")
    dutyNameList.caseName = DynamicRecord.GetStringValue(entry, "caseName")
    dutyNameList.costYuanBao = DynamicRecord.GetIntValue(entry, "costYuanBao")
    dutyNameList.levelUpNeedMoney = DynamicRecord.GetIntValue(entry, "levelUpNeedMoney")
    dutyNameList.levelUpNeedLively = DynamicRecord.GetIntValue(entry, "levelUpNeedLively")
    dutyNameList.levelUpNeedTimeD = DynamicRecord.GetIntValue(entry, "levelUpNeedTimeD")
    dutyNameList.levelUpNeedSilver = DynamicRecord.GetIntValue(entry, "levelUpNeedSilver")
    if self.designDutyNameId == dutyNameList.id then
      self.curNameIndex = i
    end
    dutyNameList.names = {}
    local dutyStruct = DynamicRecord.GetStructValue(entry, "dutyStruct")
    local dutyNameAmount = DynamicRecord.GetVectorSize(dutyStruct, "dutyVector")
    for i = 0, dutyNameAmount - 1 do
      local nameRecord = DynamicRecord.GetVectorValueByIdx(dutyStruct, "dutyVector", i)
      local dutyName = nameRecord:GetStringValue("dutyName")
      table.insert(dutyNameList.names, dutyName)
    end
    table.insert(list, dutyNameList)
    table.insert(names, dutyNameList.caseName)
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  return list, names
end
def.override().OnHide = function(self)
end
def.method().FillGangDutyNameList = function(self)
  local dutyNameList = self.dutyNameTbl[self.curNameIndex + 1]
  if nil == dutyNameList then
    return
  end
  local Grid = self.m_node:FindDirect("Img_Bg/Grid")
  for i = 1, #dutyNameList.names do
    local Group = Grid:FindDirect(string.format("Group%d", i))
    local Label2 = Group:FindDirect("Label2"):GetComponent("UILabel")
    Label2:set_text(dutyNameList.names[i])
  end
  local popList = self.m_node:FindDirect("Btn_List"):GetComponent("UIPopupList")
  if #self.nameTbl >= self.curNameIndex then
    popList:set_selectIndex(self.curNameIndex)
    popList:set_value(self.nameTbl[self.curNameIndex + 1])
  end
end
def.method().OnPopupListChange = function(self)
  self:FillGangDutyNameList()
  self:UpdateCost()
end
def.override("string", "string", "number").onSelect = function(self, id, selected, index)
  if "Btn_List" == id and index ~= -1 then
    self.curNameIndex = index
    self:UnFoldList()
    self:OnPopupListChange()
  end
end
def.static("number", "table").BuyYuanbaoCallback = function(i, tag)
  if i == 1 then
    local dlg = tag.id
    local MallPanel = require("Main.Mall.ui.MallPanel")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
  end
end
def.static("number", "table").MakeSureToChangeCallback = function(i, tag)
  if i == 1 then
    local listId = tag.listId
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gang.CDesignDutyNameReq").new(listId))
  end
end
def.method().OnModityDutyNameClick = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local memberInfo = GangData.Instance():GetMemberInfoByRoleId(heroProp.id)
  if memberInfo == nil then
    return
  end
  local tbl = GangUtility.GetAuthority(memberInfo.duty)
  if tbl.isCanDesignDutyName then
    local dutyNameList = self.dutyNameTbl[self.curNameIndex + 1]
    if nil == dutyNameList then
      return
    end
    if GangData.Instance():GetDesignDutyNamId() == dutyNameList.id then
      Toast(textRes.Gang[180])
      return
    end
    local ItemModule = require("Main.Item.ItemModule")
    local yuanbao = ItemModule.Instance():GetAllYuanBao()
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    if Int64.lt(yuanbao, dutyNameList.costYuanBao) then
      local tag = {id = self}
      CommonConfirmDlg.ShowConfirm("", textRes.Gang[59], SetDutyNameNode.BuyYuanbaoCallback, tag)
      return
    end
    local tag = {
      listId = dutyNameList.id
    }
    CommonConfirmDlg.ShowConfirm("", textRes.Gang[136], SetDutyNameNode.MakeSureToChangeCallback, tag)
  else
    Toast(textRes.Gang[79])
  end
end
def.method().OnTipsClick = function(self)
  local tipsId = 701602011
  local GUIUtils = require("GUI.GUIUtils")
  GUIUtils.ShowHoverTip(tipsId, 0, 0)
end
def.method().OnBtnListClick = function(self)
  if not self.m_node then
    return
  end
  if self.m_node:FindDirect("Btn_List/Img_Up"):get_activeInHierarchy() == true and self.m_node:FindDirect("Btn_List/Img_Down"):get_activeInHierarchy() == false then
    self:UnFoldList()
  else
    self:FoldList()
  end
end
def.method().FoldList = function(self)
  if not self.m_node then
    return
  end
  self.m_node:FindDirect("Btn_List/Img_Up"):SetActive(true)
  self.m_node:FindDirect("Btn_List/Img_Down"):SetActive(false)
end
def.method().UnFoldList = function(self)
  if not self.m_node then
    return
  end
  self.m_node:FindDirect("Btn_List/Img_Up"):SetActive(false)
  self.m_node:FindDirect("Btn_List/Img_Down"):SetActive(true)
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id ~= "Btn_List" then
    self:UnFoldList()
  end
  if id == "Btn_Modify" then
    self:OnModityDutyNameClick()
  elseif id == "Btn_Tips" then
    self:OnTipsClick()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_node.name
    })
  elseif id == "Btn_List" then
    self:OnBtnListClick()
  end
end
SetDutyNameNode.Commit()
return SetDutyNameNode
