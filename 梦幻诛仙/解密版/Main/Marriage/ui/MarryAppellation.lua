local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MarryAppellation = Lplus.Extend(ECPanelBase, "MarryAppellation")
local GUIUtils = require("GUI.GUIUtils")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local ItemModule = require("Main.Item.ItemModule")
local def = MarryAppellation.define
def.field("number").select = 1
def.field("table").data = nil
def.static("table").ShowCoupleTitle = function(data)
  if data == nil then
    return
  end
  local dlg = MarryAppellation()
  dlg.data = data
  dlg:CreatePanel(RESPATH.PREFAB_MARRY_TITLE, 1)
end
def.override().OnCreate = function(self)
  self:UpdateList()
  for k, v in ipairs(self.data) do
    if v.own then
      self.select = k
      break
    end
  end
  self:UpdateContent()
  self:UpdateCost()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateList = function(self)
  local nameTbl = {}
  for k, v in ipairs(self.data) do
    table.insert(nameTbl, v.name)
  end
  local popuplist = self.m_panel:FindDirect("Img_Bg/Group_SetName/Btn_RightTitle"):GetComponent("UIPopupList")
  popuplist:set_items(nameTbl)
end
def.method().UpdateContent = function(self)
  local info = self.data[self.select]
  local popuplist = self.m_panel:FindDirect("Img_Bg/Group_SetName/Btn_RightTitle"):GetComponent("UIPopupList")
  popuplist:set_selectIndex(self.select - 1)
  popuplist:set_value(info.name)
  local nameLbl = self.m_panel:FindDirect("Img_Bg/Group_SetName/Btn_RightTitle/Label_Appellation"):GetComponent("UILabel")
  nameLbl:set_text(info.name)
  local husbandLbl = self.m_panel:FindDirect("Img_Bg/Group_SetName/Img_Content_Bg/Grid_Content/Group_Male/Label_Appellation"):GetComponent("UILabel")
  local wifeLbl = self.m_panel:FindDirect("Img_Bg/Group_SetName/Img_Content_Bg/Grid_Content/Group_Female/Label_Appellation"):GetComponent("UILabel")
  husbandLbl:set_text(info.husband)
  wifeLbl:set_text(info.wife)
end
def.method().UpdateCost = function(self)
  local info = self.data[self.select]
  local btn_modify = self.m_panel:FindDirect("Img_Bg/Group_SetName/Btn_Modify")
  local groupCost = self.m_panel:FindDirect("Img_Bg/Group_SetName/Group_Cost")
  local groupCur = self.m_panel:FindDirect("Img_Bg/Group_SetName/Label_Current")
  if info.own then
    btn_modify:SetActive(false)
    groupCost:SetActive(false)
    groupCur:SetActive(true)
  else
    btn_modify:SetActive(true)
    groupCost:SetActive(true)
    groupCur:SetActive(false)
    local spr = groupCost:FindDirect("Img_YuanBao"):GetComponent("UISprite")
    local numLbl = groupCost:FindDirect("Label_Num"):GetComponent("UILabel")
    if info.money == MoneyType.GOLD then
      spr:set_spriteName("Icon_Gold")
    elseif info.money == MoneyType.SILVER then
      spr:set_spriteName("Icon_Silver")
    elseif info.money == MoneyType.YUANBAO then
      spr:set_spriteName("Img_Money")
    end
    numLbl:set_text(info.number)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Modify" then
    do
      local info = self.data[self.select]
      if not info.own then
        if info.money == MoneyType.GOLD then
          local count = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
          if count < Int64.new(info.number) then
            Toast(textRes.Marriage[29])
            return
          end
        elseif info.money == MoneyType.SILVER then
          local count = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
          if count < Int64.new(info.number) then
            Toast(textRes.Marriage[30])
            return
          end
        elseif info.money == MoneyType.YUANBAO then
          local myyuanbao = ItemModule.Instance():GetAllYuanBao()
          if Int64.new(info.number):gt(myyuanbao) then
            Toast(textRes.Marriage[27])
            return
          end
        end
        local str = string.format(textRes.Marriage[43], info.name)
        local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
        CommonConfirmDlg.ShowConfirm(textRes.Marriage[42], str, function(select)
          if select == 1 then
            local appellation = info.id
            require("Main.Marriage.MarriageModule").Instance():C2SChangeCoupleAppellation(appellation)
            self:DestroyPanel()
          end
        end, nil)
      end
    end
  elseif id == "Btn_Tips" then
  end
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  if "Btn_RightTitle" == id and index ~= -1 then
    self.select = index + 1
    self:UpdateContent()
    self:UpdateCost()
  end
end
MarryAppellation.Commit()
return MarryAppellation
