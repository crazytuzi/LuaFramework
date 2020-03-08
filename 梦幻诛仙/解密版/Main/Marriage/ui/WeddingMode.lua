local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WeddingMode = Lplus.Extend(ECPanelBase, "WeddingMode")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local def = WeddingMode.define
local instance
def.static("=>", WeddingMode).Instance = function()
  if instance == nil then
    instance = WeddingMode()
  end
  return instance
end
def.field("table").data = nil
def.field("number").select = 1
def.field("boolean").useYB = false
def.static("table").ShowModelSelect = function(info)
  local dlg = WeddingMode.Instance()
  dlg.data = info
  dlg:CreatePanel(RESPATH.PREFAB_MARRY_MODE, 1)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WeddingMode.OnBagInfoSynchronized)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, WeddingMode.OnBagInfoSynchronized)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdateList()
    self:UpdateYunbao()
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  WeddingMode.Instance():UpdateList()
end
def.method().UpdateList = function(self)
  local modeList = self.m_panel:FindDirect("Img_Bg/Group_ModeList/Scroll View/List_Mode")
  local uiList = modeList:GetComponent("UIList")
  uiList:set_itemCount(#self.data)
  uiList:Resize()
  for i = 1, #self.data do
    local item = modeList:FindDirect(string.format("Template_%d", i))
    local nameLabel = item:FindDirect(string.format("Label_Mode_%d", i, i)):GetComponent("UILabel")
    nameLabel:set_text(self.data[i].name)
    if i == self.select then
      local selectToggle = item:FindDirect(string.format("Btn_Select_%d", i)):GetComponent("UIToggle")
      selectToggle:set_value(true)
    end
    local icon = item:FindDirect(string.format("Img_Item_%d", i))
    if self.data[i].item ~= nil then
      icon:SetActive(true)
      local itemBase = ItemUtils.GetItemBase(self.data[i].item)
      if itemBase ~= nil then
        local tex = icon:FindDirect(string.format("Icon_Item_%d", i)):GetComponent("UITexture")
        GUIUtils.FillIcon(tex, itemBase.icon)
        local numLbl = icon:FindDirect(string.format("Label_Item_%d", i)):GetComponent("UILabel")
        local numIHave = ItemModule.Instance():GetItemCountById(self.data[i].item)
        numLbl:set_text(string.format("%d/%d", numIHave, self.data[i].number))
      end
    elseif self.data[i].money ~= nil then
      icon:SetActive(true)
      local tex = icon:FindDirect(string.format("Icon_Item_%d", i)):GetComponent("UITexture")
      local iconId = 0
      if self.data[i].money == MoneyType.GOLD then
        iconId = GUIUtils.GetIconIdGold()
      elseif self.data[i].money == MoneyType.SILVER then
        iconId = GUIUtils.GetIconIdSilver()
      end
      GUIUtils.FillIcon(tex, iconId)
      local numLbl = icon:FindDirect(string.format("Label_Item_%d", i)):GetComponent("UILabel")
      numLbl:set_text(string.format("%d", self.data[i].number))
    else
      icon:SetActive(false)
    end
  end
  self.m_msgHandler:Touch(modeList)
end
def.method().UpdateYunbao = function(self)
  local toggle = self.m_panel:FindDirect("Img_Bg/Group_Btn/Btn_YBSelect")
  local yb = self.m_panel:FindDirect("Img_Bg/Group_Btn/Img_Money")
  local num = self.m_panel:FindDirect("Img_Bg/Group_Btn/Label_Money")
  if self.data[self.select].yuanbao then
    if self.useYB then
      toggle:SetActive(true)
      toggle:GetComponent("UIToggle"):set_value(true)
      yb:SetActive(true)
      num:SetActive(true)
      local numIHave = ItemModule.Instance():GetItemCountById(self.data[self.select].item)
      local yuanbaoNum = (self.data[self.select].yuanbao or 0) * (self.data[self.select].number - numIHave)
      if not (yuanbaoNum >= 0) or not yuanbaoNum then
        yuanbaoNum = 0
      end
      num:GetComponent("UILabel"):set_text(string.format("%d", yuanbaoNum))
    else
      toggle:SetActive(true)
      toggle:GetComponent("UIToggle"):set_value(false)
      yb:SetActive(false)
      num:SetActive(false)
    end
  else
    toggle:SetActive(false)
    yb:SetActive(false)
    num:SetActive(false)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 9) == "Img_Item_" then
    local index = tonumber(string.sub(id, 10))
    local info = self.data[index]
    if info and info.item then
      local go = self.m_panel:FindDirect(string.format("Img_Bg/Group_ModeList/Scroll View/List_Mode/Template_%d/Img_Item_%d", index, index))
      require("Main.Item.ItemTipsMgr").Instance():ShowBasicTipsWithGO(info.item, go, 0, true)
    end
  elseif id == "Btn_Start" then
    do
      local info = self.data[self.select]
      if info then
        if info.yuanbao then
          if self.useYB then
            local numIHave = ItemModule.Instance():GetItemCountById(info.item)
            local yuanbaoNum = info.yuanbao * (info.number - numIHave)
            if not (yuanbaoNum >= 0) or not yuanbaoNum then
              yuanbaoNum = 0
            end
            local myyuanbao = ItemModule.Instance():GetAllYuanBao()
            if Int64.new(yuanbaoNum):gt(myyuanbao) then
              _G.GotoBuyYuanbao()
              return
            end
          elseif info.item ~= nil then
            local count = ItemModule.Instance():GetItemCountById(info.item)
            if count < info.number then
              Toast(textRes.Marriage[28])
              return
            end
          elseif info.money ~= nil then
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
            end
          end
          local str = string.format(textRes.Marriage[40], info.name)
          local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
          CommonConfirmDlg.ShowConfirm(textRes.Marriage[41], str, function(select)
            if select == 1 then
              require("Main.Marriage.MarriageModule").Instance():C2SMarry(info.id, self.useYB)
              self:DestroyPanel()
            end
          end, nil)
        else
          if info.item ~= nil then
            local count = ItemModule.Instance():GetItemCountById(info.item)
            if count < info.number then
              Toast(textRes.Marriage[28])
              return
            end
          elseif info.money ~= nil then
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
            end
          end
          local str = string.format(textRes.Marriage[40], info.name)
          local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
          CommonConfirmDlg.ShowConfirm(textRes.Marriage[41], str, function(select)
            if select == 1 then
              require("Main.Marriage.MarriageModule").Instance():C2SMarry(info.id, false)
              self:DestroyPanel()
            end
          end, nil)
        end
      end
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if string.sub(id, 1, 11) == "Btn_Select_" then
    if active then
      local index = tonumber(string.sub(id, 12))
      self.select = index
      self.useYB = false
      self:UpdateYunbao()
    end
  elseif id == "Btn_YBSelect" then
    self.useYB = active
    self:UpdateYunbao()
  end
end
WeddingMode.Commit()
return WeddingMode
