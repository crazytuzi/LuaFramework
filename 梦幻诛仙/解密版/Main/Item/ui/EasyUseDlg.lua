local Lplus = require("Lplus")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local Vector = require("Types.Vector")
local EasyUseDlg = Lplus.Extend(ECPanelBase, "EasyUseDlg")
local def = EasyUseDlg.define
local queue = {}
local showed = false
local blocked = false
def.static("boolean").Block = function(b)
  blocked = b
  if not blocked and showed == false and #queue > 0 then
    GameUtil.AddGlobalLateTimer(0, true, function()
      local tbl = queue[1]
      EasyUseDlg.ShowEasyUse(tbl[1], tbl[2], tbl[3], tbl[4], tbl[5])
      table.remove(queue, 1)
    end)
  end
end
local current
def.static().CloseAll = function()
  queue = {}
  if current then
    current:DestroyPanel()
    current = nil
  end
end
def.static("table", "number", OperationBase, "boolean", "number").ShowEasyUse = function(item, itemKey, operation, light, time)
  if not _G.IsEnteredWorld() then
    queue = {}
    showed = false
    return
  end
  if blocked then
    print("EasyUse Blocked")
    table.insert(queue, {
      item,
      itemKey,
      operation,
      light,
      time
    })
    return
  end
  if showed then
    print("EasyUse in queuue")
    table.insert(queue, {
      item,
      itemKey,
      operation,
      light,
      time
    })
    return
  end
  showed = true
  local easyUseDlg = EasyUseDlg()
  easyUseDlg.item = item
  easyUseDlg.itemKey = itemKey
  easyUseDlg.operation = operation
  easyUseDlg.light = light
  easyUseDlg.time = time
  easyUseDlg:CreatePanel(RESPATH.DLG_EASYUSE, 0)
  current = easyUseDlg
end
def.field("table").item = nil
def.field("number").itemKey = -1
def.field(OperationBase).operation = nil
def.field("boolean").light = false
def.field("number").time = 0
def.field("number").timer = 0
def.field("function").SetVisible = nil
def.field("function").SetInvisible = nil
def.override().OnCreate = function(self)
  self:UpdateInfo()
  self:SetLightAndTime()
  local EasyUseOn = function(p1, p2)
    if p1 then
      local self = p1[1]
      self:SetLayer(ClientDef_Layer.UI)
    end
  end
  local EasyUseOff = function(p1, p2)
    if p1 then
      local self = p1[1]
      self:SetLayer(ClientDef_Layer.Invisible)
    end
  end
  self.SetVisible = EasyUseOn
  self.SetInvisible = EasyUseOff
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, self.SetInvisible, {self})
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, self.SetVisible, {self})
  Event.RegisterEventWithContext(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, self.SetInvisible, {self})
  Event.RegisterEventWithContext(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, self.SetVisible, {self})
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, EasyUseDlg.CheckItemExist, {self})
end
def.static("table", "table").CheckItemExist = function(param, tbl)
  local self = param[1]
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, self.itemKey)
  if item == nil then
    self:DestroyPanel()
  elseif self.item.id ~= item.id then
    self:DestroyPanel()
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, self.SetInvisible)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, self.SetVisible)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, self.SetInvisible)
  Event.UnregisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaOver, self.SetVisible)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, EasyUseDlg.CheckItemExist)
  GameUtil.RemoveGlobalTimer(self.timer)
  current = nil
  showed = false
  if #queue > 0 then
    GameUtil.AddGlobalLateTimer(0, true, function()
      if #queue > 0 then
        local tbl = queue[1]
        EasyUseDlg.ShowEasyUse(tbl[1], tbl[2], tbl[3], tbl[4], tbl[5])
        table.remove(queue, 1)
      end
    end)
  end
end
def.method().UpdateInfo = function(self)
  local itemBase = ItemUtils.GetItemBase(self.item.id)
  local title = self.m_panel:FindDirect("Img_Bg/Label_Name"):GetComponent("UILabel")
  title:set_text(itemBase.name)
  local uiTexture = self.m_panel:FindDirect("Img_Bg/Img_Item/Icon_Item"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
end
def.method().SetLightAndTime = function(self)
  local buttonSprite = self.m_panel:FindDirect("Img_Bg/Btn_Use")
  local button = buttonSprite:FindDirect("Label_Use")
  local buttonLabel = button:GetComponent("UILabel")
  local opeName = self.operation:GetOperationName()
  if self.light then
    GUIUtils.SetLightEffect(buttonSprite, GUIUtils.Light.Square)
  end
  if self.time > 0 then
    buttonLabel:set_text(string.format(textRes.Item[163], opeName, self.time))
    self.timer = GameUtil.AddGlobalTimer(1, false, function()
      self.time = self.time - 1
      warn("LeftTime", self.time)
      if self.time > 0 then
        buttonLabel:set_text(string.format(textRes.Item[163], opeName, self.time))
      else
        buttonLabel:set_text(opeName)
        self:onClick("Btn_Use")
      end
    end)
  else
    buttonLabel:set_text(opeName)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
    self = nil
  elseif id == "Btn_Use" then
    if self:validata() then
      ItemModule.Instance():SetItemNew(self.itemKey, false)
      if ItemModule.Instance()._dlg.m_panel ~= nil then
        ItemModule.Instance()._dlg:UpdateAutomatic()
      end
      self.operation:Operate(ItemModule.BAG, self.itemKey, self.m_panel, nil)
      self:DestroyPanel()
      self = nil
    else
      Toast(textRes.Item[212])
      self:DestroyPanel()
      self = nil
    end
  elseif id == "Img_Item" then
    ItemModule.Instance():SetItemNew(self.itemKey, false)
    if ItemModule.Instance()._dlg.m_panel ~= nil then
      ItemModule.Instance()._dlg:UpdateAutomatic()
    end
    local source = self.m_panel:FindDirect("Img_Bg/Img_Item")
    local position = source:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local sprite = self.m_panel:FindDirect("Img_Bg/Img_Item"):GetComponent("UISprite")
    ItemTipsMgr.Instance():ShowTips(self.item, ItemModule.BAG, self.itemKey, ItemTipsMgr.Source.Other, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0)
  end
end
def.method("=>", "boolean").validata = function(self)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, self.itemKey)
  if item == nil then
    return false
  elseif self.item.id == item.id then
    return true
  else
    return false
  end
end
EasyUseDlg.Commit()
return EasyUseDlg
