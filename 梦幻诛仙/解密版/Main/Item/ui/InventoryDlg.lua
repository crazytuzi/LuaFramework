local Lplus = require("Lplus")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local EquipUtils = require("Main.Equip.EquipUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local ItemTips = require("Main.Item.ui.ItemTips")
local EasyUseDlg = require("Main.Item.ui.EasyUseDlg")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local WingInterface = require("Main.Wing.WingInterface")
local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
local ECUIModel = require("Model.ECUIModel")
local Vector = require("Types.Vector")
local InventoryDlg = Lplus.Extend(ECPanelBase, "InventoryDlg")
local def = InventoryDlg.define
local s_dlg
def.const("table").ShowState = {
  Bag = 1,
  Task = 2,
  Storage = 3,
  JewelBag = 4,
  TreasureBag = 5
}
def.const("number").TOGGLEGROUP = 465
def.const("string").SETTLESOUND = RESPATH.SOUND_SETTLE
def.field(ItemModule)._itemModule = nil
def.field("table")._viewModel = nil
def.field("number")._state = 1
def.field("table").model = nil
def.field("boolean").isDrag = false
def.field("number").selectItem = -1
def.field("number").storageIndex = 1
def.field("boolean").isArrangingBag = false
def.field("boolean").isArrangingStorage = false
def.field("table").allQilingList = nil
def.field("number").selOcp = 0
def.static("=>", InventoryDlg).new = function(self)
  local dlg = InventoryDlg()
  dlg._itemModule = ItemModule.Instance()
  local InventoryDlgViewModel = require("Main.Item.viewmodel.InventoryDlgViewModel")
  dlg._viewModel = InventoryDlgViewModel.Instance()
  return dlg
end
def.static("=>", InventoryDlg).Instance = function(self)
  if s_dlg == nil then
    s_dlg = InventoryDlg.new()
    s_dlg.m_TrigGC = true
    s_dlg.m_HideOnDestroy = true
  end
  return s_dlg
end
def.method().Clear = function(self)
  self.storageIndex = 1
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MODEL_CHANGED, InventoryDlg.UpdateModelEvent, self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, InventoryDlg.UpdateFashionStatus, self)
  Event.RegisterEventWithContext(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, InventoryDlg.UpdateFashionStatus, self)
  Event.RegisterEventWithContext(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_DISPLAY_CHANGE, InventoryDlg.OnFabaoDisplayChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_World_Goal_Item, InventoryDlg.OnUseWorldGoal, self)
  Event.RegisterEventWithContext(ModuleId.EQUIP, gmodule.notifyId.Equip.Ocp_Equipment_Change, InventoryDlg.OnOcpEquipmentChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_LingWu, InventoryDlg.OnUseLingWu, self)
  Event.RegisterEventWithContext(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_BAG_FEATURE_CHG, InventoryDlg.OnJewelBagFeatureChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, InventoryDlg.OnJewelBagChange, self)
  Event.RegisterEventWithContext(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_MOUNT_CHANGE, InventoryDlg.OnAircraftMountChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Treasure_Bag_Change, InventoryDlg.OnTreasureBagChange, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_Treasure_Bag_Notify_Change, InventoryDlg.OnTreasureBagNotifyChange, self)
  self._state = InventoryDlg.ShowState.Bag
  self.isDrag = false
  self.isArrangingBag = false
  self.isArrangingStorage = false
  local bagToggle1 = self.m_panel:FindDirect("Img_Bg0/Tap_Bag"):GetComponent("UIToggle")
  bagToggle1:set_isChecked(true)
  local bagToggle2 = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Tab_Item"):GetComponent("UIToggle")
  bagToggle2:set_isChecked(true)
  self:CheckGodWeaponFeature()
  self:UpdateHeroInfo()
  self:UpdateCurrency()
  self:UpdateEquips()
  self:ResetBagCapacity()
  self:ResetTreasureBagCapacity()
  self:UpdateBag()
  self:ToggleBtns(true)
  self:ResetTaskCapacity()
  self:UpdateTaskBag()
  local items = self._itemModule:GetStorages(self.storageIndex)
  if items and items.cap ~= nil and items.cap > 0 then
    self:ResetStorageCapacity(items.cap)
  end
  self:UpdateStorage()
  local bagScroll = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item")
  bagScroll:GetComponent("UIScrollView"):ResetPosition()
  self:UpdateHeroInfo()
  self:UpdateEquips()
  self:UpdateFashion()
  self:UpdateOcpEquipGroup()
  self:UpdateTreasureBagNotify()
  local IsCrossingServer = IsCrossingServer()
  self.m_panel:FindDirect("Img_Bg0/Tap_Storage"):SetActive(not IsCrossingServer)
  self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Tab_Task"):SetActive(not IsCrossingServer)
  self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_Task"):SetActive(false)
  self.m_panel:FindDirect("Img_Bg0/Img_BgStorage"):SetActive(false)
end
def.override().OnDestroy = function(self)
  self.selOcp = 0
  self._viewModel:Clear()
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_MODEL_CHANGED, InventoryDlg.UpdateModelEvent)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, InventoryDlg.UpdateFashionStatus)
  Event.UnregisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionNotifyChanged, InventoryDlg.UpdateFashionStatus)
  Event.UnregisterEvent(ModuleId.FABAO, gmodule.notifyId.Fabao.FABAO_DISPLAY_CHANGE, InventoryDlg.OnFabaoDisplayChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_World_Goal_Item, InventoryDlg.OnUseWorldGoal)
  Event.UnregisterEvent(ModuleId.EQUIP, gmodule.notifyId.Equip.Ocp_Equipment_Change, InventoryDlg.OnOcpEquipmentChange)
  Event.UnregisterEvent(ModuleId.GOD_WEAPON, gmodule.notifyId.GodWeapon.JEWEL_BAG_FEATURE_CHG, InventoryDlg.OnJewelBagFeatureChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, InventoryDlg.OnJewelBagChange)
  Event.UnregisterEvent(ModuleId.AIRCRAFT, gmodule.notifyId.Aircraft.AIRCRAFT_MOUNT_CHANGE, InventoryDlg.OnAircraftMountChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Treasure_Bag_Change, InventoryDlg.OnTreasureBagChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Treasure_Bag_Notify_Change, InventoryDlg.OnTreasureBagNotifyChange)
end
def.method("table").UpdateModelEvent = function(self, params)
  if self:IsShow() then
    self:UpdateModel()
  end
end
def.method("table").OnFabaoDisplayChange = function(self, params)
  self:UpdateEquips()
end
def.method("table").OnAircraftMountChange = function(self, params)
  self:UpdateEquips()
end
def.method("table").OnUseWorldGoal = function(self, params)
  self:DestroyPanel()
end
def.method("table").OnOcpEquipmentChange = function(self, params)
  if self._state == InventoryDlg.ShowState.Bag or self._state == InventoryDlg.ShowState.Task then
    self:UpdateEquips()
    self:UpdateModel()
  end
end
def.method("table").OnUseLingWu = function(self, params)
  self:DestroyPanel()
end
def.method().DestroyModel = function(self)
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self:UpdateModel()
    self:SelectItem(self.selectItem)
    self:Reposition()
  else
    self:DestroyModel()
  end
end
def.method("number").SelectItem = function(self, itemKey)
  if itemKey < 0 then
    return
  end
  if self.m_panel then
    GameUtil.AddGlobalTimer(0.1, true, function()
      self:onClick(string.format("Item_%03d", itemKey))
      self.selectItem = -1
    end)
  else
    self.selectItem = itemKey
  end
end
def.method().OpenRepairEquipPanel = function(self)
  local panel = require("Main.Item.ui.RepairEquipPanel")
  panel.Instance():ShowPanel()
end
def.method().Reposition = function(self)
  local GroupQL = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_BgLeft/Group_QL")
  if GroupQL:get_activeInHierarchy() then
    local uiGrid = GroupQL:GetComponent("UIGrid")
    uiGrid:Reposition()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Item" and string.find(obj.parent.name, "item_") then
    local Label_Name = obj:GetChild(0)
    local ocp = tonumber(string.split(Label_Name.name, "_")[3])
    self:SelectEquipmentOcp(ocp)
  else
    self:onClick(id)
  end
end
def.method("string").onClick = function(self, id)
  warn("Bag Click ", id)
  local activeToggle = UIToggle.GetActiveToggle(InventoryDlg.TOGGLEGROUP)
  if activeToggle then
    activeToggle:set_isChecked(false)
  end
  if self._state == 3 then
    if id ~= "Btn_StorageMenu" then
      self:SetStorageSelect(false)
    end
  elseif id ~= "Btn_Item" then
    self:CloseOcpChooseList()
  end
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, 8) == "QL_Item_" then
    local strenLevel = tonumber(string.sub(id, 9))
    self:OnQilingBtn(strenLevel)
  elseif string.find(id, "zilock_") then
    if CheckCrossServerAndToast() then
      return
    end
    if self._state == 4 then
      self._itemModule:TryExtendBag(ItemModule.GOD_WEAPON_JEWEL_BAG, nil)
      self.m_panel:FindDirect("Img_Bg0/Img_LingShi/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(false)
    elseif self._state == InventoryDlg.ShowState.TreasureBag then
      self._itemModule:TryExtendBag(ItemModule.TREASURE_BAG, nil)
      self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_ZhenPin/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(false)
    else
      self._itemModule:TryExtendBag(ItemModule.BAG, nil)
      self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(false)
    end
  elseif string.find(id, "Item_") then
    local indexStr = string.sub(id, 6)
    local index = tonumber(indexStr)
    if index then
      local key, item = self._itemModule:GetItemByPosition(ItemModule.BAG, index - 1)
      if key == -1 then
        self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(false)
        return
      else
        self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(true)
      end
      self._itemModule:SetItemNew(key, false)
      self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item/" .. id .. "/Img_New"):SetActive(false)
      if self._state == InventoryDlg.ShowState.Bag then
        self:CheckToRemoveItemRedPoint(id, key)
        self:OnClickBagItem(key, item)
      elseif self._state == InventoryDlg.ShowState.Storage then
        ItemTipsMgr.Instance():ShowTips(item, ItemModule.BAG, key, ItemTipsMgr.Source.StorageBag, 0, 0, 0, 0, 0)
      end
    end
  elseif string.find(id, "Img_Equip") then
    local indexStr = string.sub(id, 10)
    local index = tonumber(indexStr)
    if index then
      if index == WearPos.WING then
        local fakeWingId = WingInterface.GetCurWingItemId()
        if fakeWingId <= 0 then
          local GuideUtils = require("Main.Guide.GuideUtils")
          local FunType = require("consts.mzm.gsp.guide.confbean.FunType")
          local lv = GuideUtils.GetFunctionOpenLvByType(FunType.WING)
          local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
          if lv > myLv then
            Toast(string.format(textRes.Item[203], lv))
          else
            Toast(textRes.Item[204])
          end
        else
          local level = WingInterface.GetCurWingLevel()
          local phase = WingInterface.GetCurWingPhase()
          local fakeId = fakeWingId
          ItemTipsMgr.Instance():ShowWingItemTip(fakeId, level, phase, 0, 0, 0, 0, 0, true, true)
        end
      elseif index == WearPos.AIRCRAFT then
        local aircraftItemId = require("Main.Aircraft.AircraftInterface").GetCurAircraftItemId()
        if aircraftItemId <= 0 then
          local lv = constant.CFeijianConsts.fei_jian_open_level
          local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
          if lv > myLv then
            Toast(string.format(textRes.Item[205], lv))
          else
            Toast(textRes.Item[206])
          end
        else
          self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_BgLeft/" .. id):GetComponent("UIToggle"):set_value(true)
          ItemTipsMgr.Instance():ShowAircraftTip(aircraftItemId, true)
        end
      elseif index == 7 then
        local GuideUtils = require("Main.Guide.GuideUtils")
        local FunType = require("consts.mzm.gsp.guide.confbean.FunType")
        local lv = GuideUtils.GetFunctionOpenLvByType(FunType.FABAO)
        local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
        if lv > myLv then
          Toast(string.format(textRes.Item[207], lv))
        else
          local displayFabao = require("Main.Fabao.data.FabaoData").Instance():GetCurDisplayFabao()
          local bShowFabao = false
          if displayFabao then
            local fabaoType = displayFabao.fabaoType
            local fabaoData = displayFabao.fabaoData
            if fabaoType and fabaoType > 0 then
              local fabaoItemBase = require("Main.Item.ItemUtils").GetItemBase(fabaoData.id)
              ItemTipsMgr.Instance():ShowFabaoWearTips(fabaoData, fabaoItemBase, ItemTipsMgr.Source.Equip, 0, 0, 0, 0, 0, false)
              bShowFabao = true
            end
          end
          if not bShowFabao then
            local FabaoSpiritModule = require("Main.FabaoSpirit.FabaoSpiritModule")
            local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
            local equipLQClsId = FabaoSpiritModule.GetEquipedLQClsId()
            warn("equipLQClsId", equipLQClsId)
            if equipLQClsId and equipLQClsId > 0 then
              local ownedLQInfo = FabaoSpiritModule.GetOwnedLQInfos()[equipLQClsId]
              local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(equipLQClsId)
              local lv = 1
              if #LQClsCfg.arrCfgId ~= 1 then
                lv = ownedLQInfo.level
              end
              local cfgId = LQClsCfg.arrCfgId[lv]
              local itemId = FabaoSpiritUtils.GetItemIdByCfgId(cfgId)
              local itemBase = ItemUtils.GetItemBase(itemId)
              ItemTipsMgr.Instance():ShowFabaoLQWearTips(ownedLQInfo, itemBase, ItemTipsMgr.Source.Equip, 0, 0, 0, 0, 0, false)
            end
          end
        end
      else
        local ocp = self:GetSelectedOccupation()
        local key, item = self._viewModel:GetEquipmentByPosition(ocp, index)
        if key == -1 then
          self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_BgLeft/" .. id):GetComponent("UIToggle"):set_value(false)
          local GuideUtils = require("Main.Guide.GuideUtils")
          local FunType = require("consts.mzm.gsp.guide.confbean.FunType")
          if index == WearPos.FABAO then
          end
          return
        else
          self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_BgLeft/" .. id):GetComponent("UIToggle"):set_value(true)
          local tips = ItemTipsMgr.Instance():ShowTips(item, ItemModule.EQUIPBAG, key, ItemTipsMgr.Source.Equip, 0, 0, 0, 0, 0)
          tips:SetOperateContext({ocp = ocp})
        end
      end
    end
  elseif string.find(id, "Task_") then
    local index = tonumber(string.sub(id, 6))
    local TaskInterface = require("Main.task.TaskInterface")
    local taskItems = TaskInterface.Instance():GetTaskItemBag()
    local taskItem = taskItems[index]
    if taskItem then
      local tip = ItemTipsMgr.Instance():ShowTaskItemTip(taskItem.itemID, 0, 0, 0, 0, 0, true, taskItem.canBeUsed)
      tip:SetOperateContext(taskItem.param)
      self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_Task/Scroll View_Task/Grid_Task/" .. id):GetComponent("UIToggle"):set_value(false)
    else
      self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_Task/Scroll View_Task/Grid_Task/" .. id):GetComponent("UIToggle"):set_value(true)
    end
  elseif string.find(id, "RepoStorage_") then
    local indexStr = string.sub(id, 13)
    local index = tonumber(indexStr)
    if index then
      local key, item = self._itemModule:GetItemByPosition(ItemModule.STORAGEBAGS[self.storageIndex], index - 1)
      if key == -1 then
        self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Img_RepoStorage/Scroll View_RepoStorage/Grid_RepoStorage/" .. id):GetComponent("UIToggle"):set_value(false)
        return
      else
        self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Img_RepoStorage/Scroll View_RepoStorage/Grid_RepoStorage/" .. id):GetComponent("UIToggle"):set_value(true)
        ItemTipsMgr.Instance():ShowTips(item, ItemModule.STORAGEBAGS[self.storageIndex], key, ItemTipsMgr.Source.Storage, 0, 0, 0, 0, 0)
      end
    end
  elseif id == "Tab_Item" then
    if self._state ~= 1 then
      self:ToggleBtns(true)
      self:UpdateBag()
      self:UpdateCurrency()
      local bagScroll = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item")
      bagScroll:GetComponent("UIScrollView"):ResetPosition()
      self._state = 1
    end
  elseif id == "Tab_Task" then
    if CheckCrossServerAndToast() then
      return
    end
    self:ToggleBtns(true)
    if self._state ~= 2 then
      self:UpdateTaskBag()
      self:UpdateCurrency()
      local taskScroll = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_Task/Scroll View_Task")
      taskScroll:GetComponent("UIScrollView"):ResetPosition()
      self._state = 2
    end
  elseif id == "Tap_Bag" then
    if self._state ~= 1 or self._state ~= 2 then
      local bagToggle = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Tab_Item"):GetComponent("UIToggle")
      bagToggle:set_isChecked(true)
      self:UpdateHeroInfo()
      self:UpdateEquips()
      self:UpdateModel()
      self:UpdateCurrency()
      self:ToggleBtns(true)
      self._state = 1
    end
  elseif id == "Tap_Storage" then
    if CheckCrossServerAndToast() then
      return
    end
    if self._state ~= 3 then
      self._state = 3
      local items = self.m_panel:FindDirect("Img_Bg0/Img_Item")
      local jewels = self.m_panel:FindDirect("Img_Bg0/Img_LingShi")
      items:SetActive(true)
      jewels:SetActive(false)
      self:SetStorageSelect(false)
      self:UpdateStorage()
      self:UpdateCurrency()
      self:ToggleBtns(false)
      self:DestroyModel()
    end
  elseif id == "Btn_Settle" then
    if CheckCrossServerAndToast() then
      return
    end
    if self.isArrangingBag then
      Toast(textRes.Item[154])
      return
    end
    if self._state == 4 then
      ItemModule.ArrangeBag(ItemModule.GOD_WEAPON_JEWEL_BAG)
    elseif self._state == InventoryDlg.ShowState.TreasureBag then
      self._itemModule:ClearBagItemNew(ItemModule.TREASURE_BAG)
      self:UpdateUITreasureBag()
      ItemModule.ArrangeBag(ItemModule.TREASURE_BAG)
    else
      ItemModule.ArrangeBag(ItemModule.BAG)
    end
    self._itemModule:ClearItemNew()
    GameUtil.AddGlobalTimer(3, true, function()
      self.isArrangingBag = false
    end)
    self.isArrangingBag = true
    local ECSoundMan = require("Sound.ECSoundMan")
    ECSoundMan.Instance():Play2DInterruptSound(InventoryDlg.SETTLESOUND)
  elseif id == "Btn_RepoStorageSettle" then
    if self.isArrangingStorage then
      Toast(textRes.Item[154])
      return
    end
    ItemModule.ArrangeStorage(0)
    GameUtil.AddGlobalTimer(3, true, function()
      self.isArrangingStorage = false
    end)
    self.isArrangingStorage = true
    local ECSoundMan = require("Sound.ECSoundMan")
    ECSoundMan.Instance():Play2DInterruptSound(InventoryDlg.SETTLESOUND)
  elseif id == "Btn_Add1" then
    if CheckCrossServerAndToast() then
      return
    end
    GoToBuyGold(false)
  elseif id == "Btn_Add2" then
    if CheckCrossServerAndToast() then
      return
    end
    GoToBuySilver(false)
  elseif id == "Btn_Add3" then
    if CheckCrossServerAndToast() then
      return
    end
    local MallPanel = require("Main.Mall.ui.MallPanel")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
  elseif id == "Img_Coin3" then
    self._itemModule:ShowYuanbaoDetail(-1)
  elseif string.find(id, "storagetoggle_") then
    local index = tonumber(string.sub(id, 15))
    if index ~= self.storageIndex then
      self.storageIndex = index
      self:UpdateStorage()
      self:SetStorageSelect(false)
    end
  elseif id == "Btn_Next" then
    local next = self.storageIndex + 1
    local bag = self._itemModule:GetStorages(next)
    if bag then
      self.storageIndex = next
    else
      self.storageIndex = 1
    end
    self:UpdateStorage()
  elseif id == "Btn_Back" then
    local back = self.storageIndex - 1
    local bag = self._itemModule:GetStorages(back)
    if bag then
      self.storageIndex = back
      self:UpdateStorage()
    else
      for i = #ItemModule.STORAGEBAGS, 1, -1 do
        local bag = self._itemModule:GetStorages(i)
        if bag then
          self.storageIndex = i
          self:UpdateStorage()
          break
        end
      end
    end
  elseif string.find(id, "unlockStorage_") then
    local index = tonumber(string.sub(id, 15))
    self._itemModule:ExtendStorage(index)
  elseif id == "Btn_Change" then
    do
      local storageId = ItemModule.STORAGEBAGS[self.storageIndex]
      if storageId then
        require("GUI.CommonRenamePanel").Instance():ShowPanel(textRes.Item[147], false, function(newName, tag)
          if SensitiveWordsFilter.ContainsSensitiveWord(newName) then
            Toast(textRes.Item[9550])
            return true
          end
          local maxlen = 4
          local _, zh, en = Strlen(newName)
          local len = zh * 0.5 + en
          if len > 0 then
            if maxlen < len then
              Toast(string.format(textRes.Item[149], maxlen))
              return true
            else
              ItemModule.RenameStorage(storageId, newName)
              return false
            end
          else
            Toast(textRes.Item[148])
            return true
          end
        end, nil)
      end
    end
  elseif id == "Btn_StorageMenu" then
    local btnPanel = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Panel_Menu")
    if btnPanel:get_activeInHierarchy() then
      self:SetStorageSelect(false)
    else
      self:SetStorageSelect(true)
    end
  elseif id == "Btn_Recycle" then
    if CheckCrossServerAndToast() then
      return
    end
    require("Main.Item.ui.SellBatchPanel").ShowSellBatch()
  elseif id == "Btn_Repair" then
    if CheckCrossServerAndToast() then
      return
    end
    self:OpenRepairEquipPanel()
  elseif id == "Btn_Promote" then
    self:OnPromoteButtonClicked()
  elseif id == "Btn_Fashion" then
    self:OnFashionButtonClicked()
  elseif id == "Btn_Fashion" then
    self:OnFashionButtonClicked()
  elseif id == "Btn_Open" then
    self:OpenOcpChooseList()
  elseif id == "Tab_LingShi" then
    if self._state ~= 4 then
      self:ToggleBtns(false)
      self:UpdateUIJewelBag()
      self._state = 4
      local JewelBagScroll = self.m_panel:FindDirect("Img_Bg0/Img_LingShi/Scroll View_Item")
      JewelBagScroll:GetComponent("UIScrollView"):ResetPosition()
    end
  elseif string.find(id, "ItemL_") then
    local strIdx = string.sub(id, 7)
    local idx = tonumber(strIdx)
    if idx then
      local key, item = self._itemModule:GetItemByPosition(ItemModule.GOD_WEAPON_JEWEL_BAG, idx - 1)
      if key == -1 then
        self.m_panel:FindDirect("Img_Bg0/Img_LingShi/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(false)
        return
      else
        self.m_panel:FindDirect("Img_Bg0/Img_LingShi/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(true)
      end
      self._itemModule:SetItemNew(key, false)
      self.m_panel:FindDirect("Img_Bg0/Img_LingShi/Scroll View_Item/Grid_Item/" .. id .. "/Img_New"):SetActive(false)
      self:OnClickJewelBagItem(key, item)
    end
  elseif id == "Tab_Treasure" then
    if self._state ~= InventoryDlg.ShowState.TreasureBag then
      self:ToggleBtns(false)
      self:UpdateUITreasureBag()
      self._state = InventoryDlg.ShowState.TreasureBag
      local TreasureBagScroll = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_ZhenPin/Scroll View_Item")
      TreasureBagScroll:GetComponent("UIScrollView"):ResetPosition()
      self:CheckToRemoveTreasureBagNotify()
    end
  elseif string.find(id, "ItemZ_") then
    local strIdx = string.sub(id, 7)
    local idx = tonumber(strIdx)
    if idx then
      local key, item = self._itemModule:GetItemByPosition(ItemModule.TREASURE_BAG, idx - 1)
      if key == -1 then
        self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_ZhenPin/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(false)
        return
      else
        self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_ZhenPin/Scroll View_Item/Grid_Item/" .. id):GetComponent("UIToggle"):set_value(true)
      end
      self._itemModule:SetBagItemNew(ItemModule.TREASURE_BAG, key, false)
      self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_ZhenPin/Scroll View_Item/Grid_Item/" .. id .. "/Img_New"):SetActive(false)
      self:OnClickTreasureBagItem(key, item)
    end
  end
end
def.method("number", "table").OnClickJewelBagItem = function(self, key, item)
  if ItemModule.Instance():IsBagItemCanClickToRemove(key) then
    ItemModule.ItemClickRemove(item.uuid[1])
  else
    local tips = ItemTipsMgr.Instance():ShowTips(item, ItemModule.GOD_WEAPON_JEWEL_BAG, key, ItemTipsMgr.Source.Bag, 0, 0, 0, 0, 0)
    local ocp = self:GetSelectedOccupation()
    tips:SetOperateContext({ocp = ocp})
  end
end
def.method("number", "table").OnClickTreasureBagItem = function(self, key, item)
  if ItemModule.Instance():IsBagItemCanClickToRemove(key) then
    ItemModule.ItemClickRemove(item.uuid[1])
  else
    local tips = ItemTipsMgr.Instance():ShowTips(item, ItemModule.TREASURE_BAG, key, ItemTipsMgr.Source.Bag, 0, 0, 0, 0, 0)
    local ocp = self:GetSelectedOccupation()
    tips:SetOperateContext({ocp = ocp})
  end
end
def.method("number", "table").OnClickBagItem = function(self, key, item)
  if ItemModule.Instance():IsBagItemCanClickToRemove(key) then
    ItemModule.ItemClickRemove(item.uuid[1])
  else
    local tips = ItemTipsMgr.Instance():ShowTips(item, ItemModule.BAG, key, ItemTipsMgr.Source.Bag, 0, 0, 0, 0, 0)
    local ocp = self:GetSelectedOccupation()
    tips:SetOperateContext({ocp = ocp})
  end
end
def.method("string", "number").CheckToRemoveItemRedPoint = function(self, gridItem, itemKey)
  if ItemModule.Instance():IsItemInRedPointState(itemKey) then
    local red = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item/" .. gridItem .. "/Img_Red")
    if red and red.activeSelf then
      GUIUtils.SetActive(red, false)
      ItemModule.Instance():MarkItemRedPointViewed(itemKey)
    end
  end
end
def.method("string").onDragStart = function(self, id)
  if id == "Model" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true then
    self.model:SetDir(self.model.m_ang - dx / 2)
  end
end
def.method("string").onDoubleClick = function(self, id)
  if string.find(id, "Item_") then
    local indexStr = string.sub(id, 6)
    local index = tonumber(indexStr)
    if index then
      local key, item = self._itemModule:GetItemByPosition(ItemModule.BAG, index - 1)
      if key == -1 then
        return
      end
      if self._state == InventoryDlg.ShowState.Storage then
        local storageId = ItemModule.STORAGEBAGS[self.storageIndex]
        if storageId then
          ItemModule.MoveItemToStorage(key, storageId)
        end
      elseif self._state == InventoryDlg.ShowState.Bag then
        if ItemModule.Instance():IsBagItemCanClickToRemove(key) then
          ItemModule.ItemClickRemove(item.uuid[1])
          return
        end
        local itemBase = ItemUtils.GetItemBase(item.id)
        local ope = ItemTipsMgr.Instance():GetFirstOperation(ItemTipsMgr.Source.Bag, item, itemBase)
        local ocp = self:GetSelectedOccupation()
        local context = {ocp = ocp}
        if ope then
          ope:Operate(ItemModule.BAG, key, nil, context)
        end
      end
    end
  elseif string.find(id, "RepoStorage_") then
    local indexStr = string.sub(id, 13)
    local index = tonumber(indexStr)
    if index then
      local key, item = self._itemModule:GetItemByPosition(ItemModule.STORAGEBAGS[self.storageIndex], index - 1)
      if key == -1 then
        return
      end
      local storageId = ItemModule.STORAGEBAGS[self.storageIndex]
      if storageId then
        ItemModule.MoveItemToBag(key, storageId)
      end
    end
  elseif string.find(id, "Img_Equip") then
    local indexStr = string.sub(id, 10)
    local index = tonumber(indexStr)
    if index then
      local ocp = self:GetSelectedOccupation()
      local key, item = self._viewModel:GetEquipmentByPosition(ocp, index)
      if key == -1 then
        return
      end
      if self._state == InventoryDlg.ShowState.Bag then
        local itemBase = ItemUtils.GetItemBase(item.id)
        if itemBase.itemType == ItemType.EQUIP or itemBase.itemType == ItemType.WING_ITEM or itemBase.itemType == ItemType.FABAO_ITEM then
          local UnEquipOpe = require("Main.Item.Operations.OperationUnequip")
          local ope = UnEquipOpe()
          local context = {ocp = ocp}
          ope:Operate(ItemModule.EQUIPBAG, key, nil, context)
        end
      end
    end
  end
end
def.static("table").EasyUseCallback = function(tag)
  InventoryDlg.Instance()._itemModule:OnBagItemUse(tag.type, tag.key, 1)
end
def.static("number", "table").ExtendBagCallback = function(select, tag)
  if select == 1 then
    ItemModule.ExtendBag(tag.bagId)
  else
    print("Give up extend bag")
  end
end
def.method().UpdateAutomatic = function(self)
  if self._state == 1 then
    self:UpdateEquips()
    self:UpdateBag()
    self:UpdateHeroInfo()
    self:UpdateCurrency()
  elseif self._state == 2 then
    self:UpdateEquips()
    self:UpdateTaskBag()
    self:UpdateCurrency()
  elseif self._state == 3 then
    self:UpdateBag()
    self:UpdateCurrency()
  end
end
def.method().UpdateModel = function(self)
  if self.m_panel == nil and self.m_panel.isnil then
    return
  end
  local uiModel = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_BgLeft/Img_BgCharacter/Model"):GetComponent("UIModel")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local ocp = self:GetSelectedOccupation()
  local modelId = self._viewModel:GetOccupationModelId(ocp)
  if self.model ~= nil then
    self.model:Destroy()
  end
  self.model = ECUIModel.new(modelId)
  local modelInfo = self._viewModel:GetOccupationModelInfo(ocp)
  modelInfo.modelid = modelId
  _G.LoadModelWithCallBack(self.model, modelInfo, false, false, function()
    if self.m_panel == nil or self.m_panel.isnil then
      if self.model then
        self.model:Destroy()
        self.model = nil
      end
      return
    end
    if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil or uiModel == nil or uiModel.isnil then
      return
    end
    self.model:SetDir(180)
    self.model:Play(ActionName.Stand)
    uiModel.modelGameObject = self.model:GetMainModel()
    if uiModel.mCanOverflow ~= nil then
      uiModel.mCanOverflow = true
      local camera = uiModel:get_modelCamera()
      if camera then
        camera:set_orthographic(true)
      end
    end
  end)
end
def.method().UpdateModelExtra = function(self)
  if self.model == nil or self.model.m_model == nil or self.model.m_model.isnil then
    return
  end
  local DyeingMgr = require("Main.Dyeing.DyeingMgr")
  local dyeData = DyeingMgr.GetCurClothData()
  if dyeData then
    if dyeData.hairid then
      local hairColor = DyeingMgr.GetColorFormula(dyeData.hairid)
      DyeingMgr.ChangeModelColor(DyeingMgr.PARTINDEX.HAIR, self.model, hairColor)
    end
    if dyeData.clothid then
      local clothColor = DyeingMgr.GetColorFormula(dyeData.clothid)
      DyeingMgr.ChangeModelColor(DyeingMgr.PARTINDEX.CLOTH, self.model, clothColor)
    end
  end
  local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local weapon = ItemModule.Instance():GetHeroEquipmentCfg(WearPos.WEAPON)
  local strenLevel = weapon and weapon.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
  self.model:SetWeapon(weapon and weapon.id or 0, strenLevel or 0)
  local wings = require("Main.Wings.WingsInterface").GetCurrentWings()
  self.model:SetWing(wings.id, wings.dyeId)
  local fabao = ItemModule.Instance():GetHeroEquipmentCfg(WearPos.FABAO)
  self.model:SetFabao(fabao and fabao.id or 0)
end
def.method().UpdateHeroInfo = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  local infoPanel = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_BgLeft")
  local powerLabel = infoPanel:FindDirect("Label_PowerNumber"):GetComponent("UILabel")
  powerLabel:set_text(heroProp.fightValue)
  local nameLabel = infoPanel:FindDirect("Label_Name"):GetComponent("UILabel")
  nameLabel:set_text(heroProp.name)
  local menpaiSprite = infoPanel:FindDirect("Img_SX_School"):GetComponent("UISprite")
  local occupationSpriteName = GUIUtils.GetOccupationSmallIcon(heroProp.occupation)
  menpaiSprite:set_spriteName(occupationSpriteName)
end
def.method().UpdateCurrency = function(self)
  local goldLabel = self.m_panel:FindDirect("Img_Bg0/Img_BgCoin1/Label_Coin1"):GetComponent("UILabel")
  local silverLabel = self.m_panel:FindDirect("Img_Bg0/Img_BgCoin2/Label_Coin2"):GetComponent("UILabel")
  local yuanbaoLabel = self.m_panel:FindDirect("Img_Bg0/Img_BgCoin3/Label_Coin3"):GetComponent("UILabel")
  local gold = self._itemModule:GetMoney(ItemModule.MONEY_TYPE_GOLD)
  local silver = self._itemModule:GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local yuanbao = self._itemModule:GetAllYuanBao()
  if gold ~= nil then
    goldLabel:set_text(gold:tostring())
  else
    goldLabel:set_text("0")
  end
  if silver ~= nil then
    silverLabel:set_text(silver:tostring())
  else
    silverLabel:set_text("0")
  end
  if yuanbao ~= nil then
    yuanbaoLabel:set_text(yuanbao:tostring())
  else
    yuanbaoLabel:set_text("0")
  end
end
def.method().UpdateEquips = function(self)
  local equipments = self:GetSelectedOcpEquipments()
  local equipIcons = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_BgLeft")
  for i = 0, 8 do
    local icon = equipIcons:FindDirect(string.format("Img_Equip%d/Item_%d", i, i))
    icon:SetActive(false)
    local empty = equipIcons:FindDirect(string.format("Img_Equip%d/Img_Empty", i))
    empty:SetActive(true)
  end
  for k, v in pairs(equipments) do
    local index = v.position
    local equip = self.m_panel:FindDirect(string.format("Img_Bg0/Img_BgBag/Img_BgLeft/Img_Equip%d/Item_%d", index, index))
    equip:SetActive(true)
    self:SetIcon(equip, k, v, false)
    local empty = self.m_panel:FindDirect(string.format("Img_Bg0/Img_BgBag/Img_BgLeft/Img_Equip%d/Img_Empty", index))
    empty:SetActive(false)
  end
  local wingItemId = WingInterface.GetCurWingItemId()
  local equip = self.m_panel:FindDirect(string.format("Img_Bg0/Img_BgBag/Img_BgLeft/Img_Equip%d/Item_%d", WearPos.WING, WearPos.WING))
  if wingItemId > 0 then
    equip:SetActive(true)
    self:SetIconBase(equip, wingItemId)
  end
  local displayFabao = require("Main.Fabao.data.FabaoData").Instance():GetCurDisplayFabao()
  if displayFabao then
    local fabaoType = displayFabao.fabaoType
    local fabaoData = displayFabao.fabaoData
    if fabaoType and fabaoType > 0 then
      local fabaoPos = WearPos.FABAO or 7
      local equip = self.m_panel:FindDirect(string.format("Img_Bg0/Img_BgBag/Img_BgLeft/Img_Equip%d/Item_%d", fabaoPos, fabaoPos))
      self:SetIconBase(equip, fabaoData.id)
      equip:SetActive(true)
    end
  end
  local FabaoSpiritModule = require("Main.FabaoSpirit.FabaoSpiritModule")
  local FabaoSpiritUtils = require("Main.FabaoSpirit.FabaoSpiritUtils")
  local equipLQClsId = FabaoSpiritModule.GetEquipedLQClsId()
  if equipLQClsId and equipLQClsId > 0 then
    local fabaoPos = WearPos.FABAO or 7
    local equip = self.m_panel:FindDirect(string.format("Img_Bg0/Img_BgBag/Img_BgLeft/Img_Equip%d/Item_%d", fabaoPos, fabaoPos))
    local ownedLQInfo = FabaoSpiritModule.GetOwnedLQInfos()[equipLQClsId]
    local LQClsCfg = FabaoSpiritUtils.GetLQClsCfgByClsId(equipLQClsId)
    local lv = 1
    if 1 < #LQClsCfg.arrCfgId then
      lv = ownedLQInfo.level
    end
    local cfgId = LQClsCfg.arrCfgId[lv]
    local LQBaseCfg = FabaoSpiritUtils.GetFabaoLQCfg(cfgId or 0)
    if LQBaseCfg ~= nil then
      local icon = equip:FindDirect("Img_Icon")
      equip:SetActive(true)
      local icon = equip:FindDirect("Img_Icon")
      local uiTexture = icon:GetComponent("UITexture")
      icon:SetActive(true)
      GUIUtils.FillIcon(uiTexture, LQBaseCfg.icon)
    end
  end
  local aircraftItemId = require("Main.Aircraft.AircraftInterface").GetCurAircraftItemId()
  local equip = self.m_panel:FindDirect(string.format("Img_Bg0/Img_BgBag/Img_BgLeft/Img_Equip%d/Item_%d", WearPos.AIRCRAFT, WearPos.AIRCRAFT))
  local empty = self.m_panel:FindDirect(string.format("Img_Bg0/Img_BgBag/Img_BgLeft/Img_Equip%d/Img_Empty", WearPos.AIRCRAFT))
  if aircraftItemId > 0 then
    equip:SetActive(true)
    empty:SetActive(false)
    self:SetIconBase(equip, aircraftItemId)
  else
    equip:SetActive(false)
    empty:SetActive(true)
  end
  self:UpateQilingInfo()
end
def.method().UpateQilingInfo = function(self)
  local QLGroup = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_BgLeft/Group_QL")
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  local openLevel = EquipUtils.GetEquipOpenMinLevel()
  if heroLevel < openLevel then
    QLGroup:SetActive(false)
    return
  end
  QLGroup:SetActive(true)
  while QLGroup:get_childCount() > 1 do
    local childCount = QLGroup:get_childCount()
    local childObj = QLGroup:GetChild(childCount - 1)
    Object.DestroyImmediate(childObj)
  end
  local template = QLGroup:FindDirect("QL_Item")
  template:SetActive(false)
  local equipments = self:GetSelectedOcpEquipments()
  local isMin, isMax, curLevel, nextLevel = EquipUtils.GetAllQiLinInfoEx(equipments)
  local minLevel, maxLevel = EquipUtils.GetAllQiLinMaxAndMinLevel()
  if isMin then
    local itemObj = Object.Instantiate(template)
    itemObj.parent = QLGroup
    itemObj:set_localScale(Vector.Vector3.one)
    itemObj.name = string.format("QL_Item_%d", minLevel)
    local Label = itemObj:FindDirect("Label_Number")
    local selectImg = itemObj:FindDirect("Img_Selected")
    Label:GetComponent("UILabel"):set_text(string.format("+%d", minLevel))
    selectImg:SetActive(false)
    itemObj:SetActive(true)
  elseif isMax then
    local itemObj = Object.Instantiate(template)
    itemObj.parent = QLGroup
    itemObj:set_localScale(Vector.Vector3.one)
    itemObj.name = string.format("QL_Item_%d", maxLevel)
    local Label = itemObj:FindDirect("Label_Number")
    local selectImg = itemObj:FindDirect("Img_Selected")
    Label:GetComponent("UILabel"):set_text(string.format("+%d", maxLevel))
    selectImg:SetActive(true)
    itemObj:SetActive(true)
  else
    local itemObj1 = Object.Instantiate(template)
    local itemObj2 = Object.Instantiate(template)
    itemObj1.parent = QLGroup
    itemObj2.parent = QLGroup
    itemObj1:set_localScale(Vector.Vector3.one)
    itemObj2:set_localScale(Vector.Vector3.one)
    itemObj1.name = string.format("QL_Item_%d", curLevel)
    local Label1 = itemObj1:FindDirect("Label_Number")
    local selectImg1 = itemObj1:FindDirect("Img_Selected")
    Label1:GetComponent("UILabel"):set_text(string.format("+%d", curLevel))
    selectImg1:SetActive(true)
    itemObj1:SetActive(true)
    itemObj2.name = string.format("QL_Item_%d", nextLevel)
    local Label2 = itemObj2:FindDirect("Label_Number")
    local selectImg2 = itemObj2:FindDirect("Img_Selected")
    Label2:GetComponent("UILabel"):set_text(string.format("+%d", nextLevel))
    selectImg2:SetActive(false)
    itemObj2:SetActive(true)
  end
  local uiGrid = QLGroup:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method().UpdateBag = function(self)
  local items = self._itemModule:GetItems()
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item")
  local childCount = bagGrid:get_childCount()
  for i = 0, childCount - 1 do
    local item = bagGrid:GetChild(i)
    if string.sub(item.name, 1, 5) ~= "Item_" then
      break
    end
    local info = items[i]
    if info then
      self:SetIcon(item, i, info, true)
    else
      self:ClearIcon(item)
    end
  end
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method().ClearBag = function(self)
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item")
  local cap = self._itemModule:GetBagCapacity()
  for i = 1, cap do
    local item = bagGrid:FindDirect(string.format("Item_%03d", i))
    if item then
      self:ClearIcon(item)
    end
  end
end
def.method().UpdateTaskBag = function(self)
  self:ClearTaskBag()
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_Task/Scroll View_Task/Grid_Task")
  local TaskInterface = require("Main.task.TaskInterface")
  local taskItems = TaskInterface.Instance():GetTaskItemBag()
  for k, v in ipairs(taskItems) do
    local item = bagGrid:FindDirect(string.format("Task_%03d", k))
    self:SetTaskIcon(item, v.itemID, v.count)
  end
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method("userdata", "number", "number").SetTaskIcon = function(self, item, itemId, count)
  local itemBase = ItemUtils.GetItemBase(itemId)
  local icon = item:FindDirect("Img_Icon")
  local uiTexture = icon:GetComponent("UITexture")
  icon:SetActive(true)
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local num = item:FindDirect("Label_Num")
  if count > 1 then
    num:SetActive(true)
    num:GetComponent("UILabel"):set_text(string.format("%2d", count))
  else
    num:SetActive(false)
  end
  item:FindDirect("Img_New"):SetActive(false)
  item:FindDirect("Img_Select"):SetActive(true)
  local bg = item:FindDirect("Img_Bg")
  local quality = itemBase.namecolor
  bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", quality))
  local broken = item:FindDirect("Img_EquipBroken")
  broken:SetActive(false)
end
def.method().ClearTaskBag = function(self)
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_Task/Scroll View_Task/Grid_Task")
  local childenCount = bagGrid:get_childCount()
  for i = 0, childenCount - 1 do
    local item = bagGrid:GetChild(i)
    self:ClearIcon(item)
  end
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method("boolean").ToggleBtns = function(self, bag)
  local repair = self.m_panel:FindDirect("Img_Bg0/Btn_Repair")
  local recyle = self.m_panel:FindDirect("Img_Bg0/Btn_Recycle")
  local settle = self.m_panel:FindDirect("Img_Bg0/Btn_Settle/Label_Settle")
  local settleLabel = settle:GetComponent("UILabel")
  if bag then
    repair:SetActive(true)
    recyle:SetActive(true)
    settleLabel:set_text(textRes.Item[152])
  else
    repair:SetActive(false)
    recyle:SetActive(false)
    settleLabel:set_text(textRes.Item[153])
  end
end
def.method().SetMenu = function(self)
  local bag = self._itemModule:GetStorages(self.storageIndex)
  local name = bag and bag.name or tostring(ItemModule.STORAGEBAGS[self.storageIndex])
  local nameLabel = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Btn_StorageMenu/Label_Menu"):GetComponent("UILabel")
  nameLabel:set_text(name)
  local storageCount = 0
  for k, v in ipairs(ItemModule.STORAGEBAGS) do
    local bag = self._itemModule:GetStorages(k)
    if bag then
      storageCount = storageCount + 1
    else
      break
    end
  end
  local pageStr = string.format("%d/%d", self.storageIndex, storageCount)
  local pageLabel = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Img_BgPage/Label_Page"):GetComponent("UILabel")
  pageLabel:set_text(pageStr)
end
def.method("boolean").SetStorageSelect = function(self, show)
  if show then
    local bagList = {}
    for k, v in ipairs(ItemModule.STORAGEBAGS) do
      local bag = self._itemModule:GetStorages(k)
      if bag then
        local bagInfo = {
          index = k,
          name = bag.name,
          id = v
        }
        table.insert(bagList, bagInfo)
      else
        local storageCfg = ItemUtils.GetStorageCfg(v)
        local extendInfo = {
          extend = true,
          moneyType = storageCfg.moneyType,
          num = storageCfg.num,
          id = v,
          index = k
        }
        table.insert(bagList, extendInfo)
        break
      end
    end
    local btnPanel = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Panel_Menu")
    btnPanel:SetActive(true)
    local btnTbl = btnPanel:FindDirect("Table_MenuBtn")
    local uiTable = btnTbl:GetComponent("UITableResizeBackground")
    local template = btnTbl:FindDirect("MenuBtn")
    template:SetActive(false)
    self:DeleteChildExcept(btnTbl, {SpaceHolder = true, MenuBtn = true})
    for k, v in ipairs(bagList) do
      if v.extend then
        local itemNew = Object.Instantiate(template)
        itemNew:set_name(string.format("unlockStorage_%d", v.index))
        itemNew:FindDirect("Label_Btn"):SetActive(false)
        local groupExtend = itemNew:FindDirect("Group_UnLock")
        local typeSprite = groupExtend:FindDirect("Img_Money"):GetComponent("UISprite")
        local type = v.moneyType
        if type == MoneyType.YUANBAO then
          typeSprite:set_spriteName("Img_Money")
        elseif type == MoneyType.GOLD then
          typeSprite:set_spriteName("Icon_Gold")
        elseif type == MoneyType.SILVER then
          typeSprite:set_spriteName("Icon_Silver")
        elseif type == MoneyType.GANGCONTRIBUTE then
          typeSprite:set_spriteName("Icon_Bang")
        else
          typeSprite:set_spriteName("")
        end
        itemNew.parent = btnTbl
        itemNew:set_localScale(Vector.Vector3.one)
        itemNew:SetActive(true)
        self.m_msgHandler:Touch(itemNew)
      else
        local itemNew = Object.Instantiate(template)
        itemNew:set_name(string.format("storagetoggle_%d", v.index))
        local nameLabel = itemNew:FindDirect("Label_Btn")
        nameLabel:SetActive(true)
        nameLabel:GetComponent("UILabel"):set_text(v.name)
        itemNew:FindDirect("Group_UnLock"):SetActive(false)
        itemNew.parent = btnTbl
        itemNew:set_localScale(Vector.Vector3.one)
        itemNew:SetActive(true)
        self.m_msgHandler:Touch(itemNew)
      end
    end
    if btnTbl:get_childCount() % 2 == 0 then
      local SpaceHolder = btnTbl:FindDirect("SpaceHolder")
      local temp = Object.Instantiate(SpaceHolder)
      temp:set_name("TempHolder")
      temp.parent = btnTbl
      temp:set_localScale(Vector.Vector3.one)
    end
    uiTable:Reposition()
    local up = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Btn_StorageMenu/Img_Up")
    local down = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Btn_StorageMenu/Img_Down")
    up:SetActive(true)
    down:SetActive(false)
  else
    local btnPanel = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Panel_Menu")
    btnPanel:SetActive(false)
    local up = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Btn_StorageMenu/Img_Up")
    local down = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Btn_StorageMenu/Img_Down")
    up:SetActive(false)
    down:SetActive(true)
  end
end
def.method().UpdateStorage = function(self)
  if self._state ~= 3 then
    return
  end
  self:SetMenu()
  local bag = self._itemModule:GetStorages(self.storageIndex)
  if bag == nil or bag.cap == nil or bag.cap <= 0 then
    return
  end
  local items = bag.items
  self:ResetStorageCapacity(bag.cap)
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Img_RepoStorage/Scroll View_RepoStorage/Grid_RepoStorage")
  local childCount = bagGrid:get_childCount()
  for i = 0, childCount - 1 do
    local item = bagGrid:GetChild(i)
    local info = items[i]
    if info then
      self:SetIcon(item, info.id, info, true)
    else
      self:ClearIcon(item)
    end
  end
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method("userdata").ClearIcon = function(self, icon)
  local bg = icon:FindDirect("Img_Bg")
  bg:GetComponent("UISprite"):set_spriteName("Cell_00")
  icon:FindDirect("Label_Num"):SetActive(false)
  icon:FindDirect("Img_Icon"):SetActive(false)
  icon:FindDirect("Img_New"):SetActive(false)
  icon:FindDirect("Img_Select"):SetActive(false)
  icon:FindDirect("Img_EquipBroken"):SetActive(false)
  local bang = icon:FindDirect("Img_Bang")
  if bang then
    bang:SetActive(false)
  end
  local zhuan = icon:FindDirect("Img_Zhuan")
  if zhuan then
    zhuan:SetActive(false)
  end
  local rarity = icon:FindDirect("Img_Xiyou")
  if rarity then
    rarity:SetActive(false)
  end
  local red = icon:FindDirect("Img_Red")
  if red then
    red:SetActive(false)
  end
end
def.method("userdata", "number").SetIconBase = function(self, item, itemId)
  local icon = item:FindDirect("Img_Icon")
  local uiTexture = icon:GetComponent("UITexture")
  local itemBase = ItemUtils.GetItemBase(itemId)
  icon:SetActive(true)
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local num = item:FindDirect("Label_Num")
  num:SetActive(false)
  item:FindDirect("Img_New"):SetActive(false)
  item:FindDirect("Img_Select"):SetActive(true)
  local bg = item:FindDirect("Img_Bg")
  local quality = itemBase.namecolor
  bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", quality))
  local broken = item:FindDirect("Img_EquipBroken")
  broken:SetActive(false)
end
def.method("userdata", "number", "table", "boolean").SetIcon = function(self, item, itemKey, itemInfo, showNew)
  local icon = item:FindDirect("Img_Icon")
  local uiTexture = icon:GetComponent("UITexture")
  local itemBase = ItemUtils.GetItemBase(itemInfo.id)
  icon:SetActive(true)
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local num = item:FindDirect("Label_Num")
  if itemInfo.number > 1 then
    num:SetActive(true)
    num:GetComponent("UILabel"):set_text(string.format("%2d", itemInfo.number))
  else
    num:SetActive(false)
  end
  local bagId = self._itemModule:GetBagIdByItemId(itemInfo.id)
  if showNew and (self._itemModule:GetItemNew(itemKey) or self._itemModule:GetBagItemNew(bagId, itemKey)) then
    item:FindDirect("Img_New"):SetActive(true)
  else
    item:FindDirect("Img_New"):SetActive(false)
  end
  item:FindDirect("Img_Select"):SetActive(true)
  local bg = item:FindDirect("Img_Bg")
  GUIUtils.SetSprite(bg, ItemUtils.GetItemFrame(itemInfo, itemBase))
  local broken = item:FindDirect("Img_EquipBroken")
  if itemBase.itemType == ItemType.EQUIP and itemInfo.extraMap[ItemXStoreType.USE_POINT_VALUE] <= 50 then
    broken:SetActive(true)
  else
    broken:SetActive(false)
  end
  local bang = item:FindDirect("Img_Bang")
  local zhuan = item:FindDirect("Img_Zhuan")
  local rarity = item:FindDirect("Img_Xiyou")
  if bang and zhuan then
    if itemBase.isProprietary then
      bang:SetActive(false)
      zhuan:SetActive(true)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsItemBind(itemInfo) then
      bang:SetActive(true)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    elseif ItemUtils.IsRarity(itemInfo.id) then
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, true)
    else
      bang:SetActive(false)
      zhuan:SetActive(false)
      GUIUtils.SetActive(rarity, false)
    end
  end
  local red = item:FindDirect("Img_Red")
  if red then
    local needRedPoint = self._itemModule:IsItemInRedPointState(itemKey)
    red:SetActive(needRedPoint)
  end
end
def.method("userdata").DisableIcon = function(self, icon)
  local bg = icon:FindDirect("Img_Bg")
  bg:GetComponent("UISprite"):set_spriteName("Cell_06")
  icon:FindDirect("Label_Num"):SetActive(false)
  icon:FindDirect("Img_Icon"):SetActive(false)
  icon:FindDirect("Img_New"):SetActive(false)
  icon:GetComponent("UIToggle"):set_enabled(false)
  icon:FindDirect("Img_Select"):SetActive(false)
  icon:FindDirect("Img_EquipBroken"):SetActive(false)
  local bang = icon:FindDirect("Img_Bang")
  if bang then
    bang:SetActive(false)
  end
  local zhuan = icon:FindDirect("Img_Zhuan")
  if zhuan then
    zhuan:SetActive(false)
  end
  local rarity = icon:FindDirect("Img_Xiyou")
  GUIUtils.SetActive(rarity, false)
  local red = icon:FindDirect("Img_Red")
  GUIUtils.SetActive(red, false)
end
def.method().ResetBagLock = function(self)
  local bagCfg = DynamicData.GetRecord(CFG_PATH.DATA_BAGCFG, ItemModule.BAG)
  local max = bagCfg:GetIntValue("maxcapacity")
  local cap = self._itemModule:GetBagCapacity()
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item")
  if max <= cap then
    return
  end
  local item001 = bagGrid:FindDirect("Item_001")
  for i = 1, 5 do
    local itemNew = Object.Instantiate(item001)
    itemNew:set_name(string.format("zilock_%d", i))
    itemNew.parent = bagGrid
    itemNew:set_localScale(Vector.Vector3.one)
    self:DisableIcon(itemNew)
    self.m_msgHandler:Touch(itemNew)
  end
end
def.method().ResetBagCapacity = function(self)
  local cap = self._itemModule:GetBagCapacity()
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item/Grid_Item")
  local itemCount = self:GetNumberOfChildrenWithName(bagGrid, "Item_")
  if itemCount == cap then
    return
  end
  self:DeleteChildExcept(bagGrid, {Item_001 = true})
  local item001 = bagGrid:FindDirect("Item_001")
  for i = 2, cap do
    local item = bagGrid:FindDirect(string.format("Item_%03d", i))
    if item == nil then
      local itemNew = Object.Instantiate(item001)
      itemNew:set_name(string.format("Item_%03d", i))
      itemNew.parent = bagGrid
      itemNew:set_localScale(Vector.Vector3.one)
      self:ClearIcon(itemNew)
      self.m_msgHandler:Touch(itemNew)
    end
  end
  self:ResetBagLock()
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method().ResetStorageLock = function(self)
end
def.method("number").ResetStorageCapacity = function(self, cap)
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_BgStorage/Img_RepoStorageBg/Img_RepoStorage/Scroll View_RepoStorage/Grid_RepoStorage")
  local itemCount = self:GetNumberOfChildrenWithName(bagGrid, "RepoStorage_")
  if itemCount == cap then
    return
  end
  self:DeleteChildExcept(bagGrid, {RepoStorage_001 = true})
  local item001 = bagGrid:FindDirect("RepoStorage_001")
  for i = 2, cap do
    local item = bagGrid:FindDirect(string.format("RepoStorage_%03d", i))
    if item == nil then
      local itemNew = Object.Instantiate(item001)
      itemNew:set_name(string.format("RepoStorage_%03d", i))
      itemNew.parent = bagGrid
      itemNew:set_localScale(Vector.Vector3.one)
      self:ClearIcon(itemNew)
      self.m_msgHandler:Touch(itemNew)
    end
  end
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method().ResetTaskCapacity = function(self)
  local cap = ItemModule.Instance():GetTaskItemCapacity()
  local taskBagGrid = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_Task/Scroll View_Task/Grid_Task")
  local itemCount = self:GetNumberOfChildrenWithName(taskBagGrid, "Task_")
  if itemCount == cap then
    return
  end
  self:DeleteChildExcept(taskBagGrid, {Task_001 = true})
  local taskItem = taskBagGrid:FindDirect("Task_001")
  for i = 2, cap do
    local itemNew = Object.Instantiate(taskItem)
    itemNew:set_name(string.format("Task_%03d", i))
    itemNew.parent = taskBagGrid
    itemNew:set_localScale(Vector.Vector3.one)
    self:ClearIcon(itemNew)
    self.m_msgHandler:Touch(itemNew)
  end
  local uiGrid = taskBagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method("userdata", "table").DeleteChildExcept = function(self, obj, undead)
  local destroyList = {}
  local count = obj:get_childCount()
  for i = 0, count - 1 do
    local child = obj:GetChild(i)
    if undead[child.name] == nil then
      table.insert(destroyList, child)
    end
  end
  for k, v in ipairs(destroyList) do
    Object.DestroyImmediate(v)
  end
end
def.method("userdata", "string", "=>", "number").GetNumberOfChildrenWithName = function(self, obj, txt)
  local count = obj:get_childCount()
  local res = 0
  for i = 0, count - 1 do
    local child = obj:GetChild(i)
    if string.find(child.name, txt) then
      res = res + 1
    end
  end
  return res
end
def.method("=>", "number").GetCurrentStorageIndex = function(self)
  if self._state == 3 then
    return self.storageIndex
  else
    return 0
  end
end
def.method().OnPromoteButtonClicked = function(self)
  require("Main.Hero.HeroUIMgr").OpenHeroBianqingDlg()
end
def.method("table").UpdateFashionStatus = function(self, params)
  self:UpdateFashion()
end
def.method().UpdateFashion = function(self)
  local btnFation = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_BgLeft/Btn_Fashion")
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_FASHION_DRESS) and not require("Main.Aircraft.AircraftModule").Instance():IsOpen(false) then
    btnFation:SetActive(false)
    return
  end
  local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local unlockLevel = math.min(constant.FashionDressConsts.openLevel, constant.CFeijianConsts.fei_jian_open_level)
  if myLv >= unlockLevel then
    btnFation:SetActive(true)
  else
    btnFation:SetActive(false)
  end
  local red = btnFation:FindDirect("Img_Red")
  GUIUtils.SetActive(red, require("Main.Fashion.FashionModule").Instance():IsFashionModuleHasNotify())
end
def.method().UpdateOcpEquipGroup = function(self)
  local Group_Zhiye = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Group_Zhiye")
  if Group_Zhiye == nil then
    warn("\"Img_Bg0/Img_BgBag/Group_Zhiye\" not found!")
    return
  end
  local ownedOccupations = self._viewModel:GetOwnedOccupations()
  local isOpen = self._viewModel:IsMultiOccupationOpen() and #ownedOccupations > 1
  if not isOpen then
    GUIUtils.SetActive(Group_Zhiye, false)
    return
  end
  GUIUtils.SetActive(Group_Zhiye, true)
  local Label_Current = Group_Zhiye:FindDirect("Label_Current")
  local selOcp = self:GetSelectedOccupation()
  local occupationName = _G.GetOccupationName(selOcp)
  GUIUtils.SetText(Label_Current, occupationName)
  self:CloseOcpChooseList()
end
def.method().OpenOcpChooseList = function(self)
  local Group_ChooseType = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Group_Zhiye/Group_ChooseType")
  GUIUtils.SetActive(Group_ChooseType, true)
  local ownedOccupationInfos = self._viewModel:GetOwnedOccupationInfos()
  local Img_Bg2 = Group_ChooseType:FindDirect("Img_Bg2")
  local List_Item = Img_Bg2:FindDirect("Scroll View/List_Item")
  local uiList = List_Item:GetComponent("UIList")
  local itemCount = #ownedOccupationInfos
  uiList.itemCount = itemCount
  uiList:Resize()
  uiList:Reposition()
  GameUtil.AddGlobalTimer(0, true, function()
    GameUtil.AddGlobalTimer(0, true, function()
      if List_Item.isnil then
        return
      end
      local uiScrollView = List_Item.parent:GetComponent("UIScrollView")
      uiScrollView:ResetPosition()
    end)
  end)
  local childGOs = uiList.children
  for i, childGO in ipairs(childGOs) do
    local occupationInfo = ownedOccupationInfos[i]
    local Btn_Item = childGO:FindDirect("Btn_Item")
    local Label_Name = Btn_Item:GetChild(0)
    Label_Name.name = "Label_Name_" .. occupationInfo.ocp
    local occupationName = occupationInfo.name
    GUIUtils.SetText(Label_Name, occupationName)
  end
end
def.method().CloseOcpChooseList = function(self)
  local Group_ChooseType = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Group_Zhiye/Group_ChooseType")
  GUIUtils.SetActive(Group_ChooseType, false)
end
def.method("number").SelectEquipmentOcp = function(self, ocp)
  local selOcp = self:GetSelectedOccupation()
  if selOcp == ocp then
    self:CloseOcpChooseList()
    return
  end
  self._viewModel:AsyncLoadOccupationEquipments(ocp, function(equipments)
    if self.m_panel == nil then
      return
    end
    self.selOcp = ocp
    if self._state == InventoryDlg.ShowState.Storage then
      return
    end
    if ocp ~= _G.GetHeroProp().occupation then
      Toast(textRes.Equip.OcpEquipment[4])
    end
    self:UpdateAutomatic()
    self:UpdateOcpEquipGroup()
    self:UpdateModel()
  end)
end
def.method("number").OnQilingBtn = function(self, strenLevel)
  local Btn = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_BgLeft/Group_QL/QL_Item_" .. strenLevel)
  if Btn then
    local position = Btn.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local equipments = self:GetSelectedOcpEquipments()
    EquipUtils.ShowAllQiLingTipEx(equipments, strenLevel, screenPos.x, screenPos.y + 32)
  end
end
def.method().OnFashionButtonClicked = function(self)
  local myLv = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local unlockLevel = math.min(constant.FashionDressConsts.openLevel, constant.CFeijianConsts.fei_jian_open_level)
  if myLv >= unlockLevel then
    require("Main.Fashion.FashionModule").OpenFashionPanel()
  else
    Toast(textRes.Fashion[1])
  end
end
def.method("=>", "boolean").ScrollToEnd = function(self)
  if self:IsShow() then
    local Scroll = self.m_panel:FindDirect("Img_Bg0/Img_Item/Scroll View_Item")
    Scroll:GetComponent("UIScrollView"):SetDragAmount(0, 1, false)
    return true
  else
    return false
  end
end
def.method("=>", "number").GetSelectedOccupation = function(self)
  if self.selOcp == 0 then
    self.selOcp = _G.GetHeroProp().occupation
  end
  return self.selOcp
end
def.method("=>", "table").GetSelectedOcpEquipments = function(self)
  local occupation = self:GetSelectedOccupation()
  return self._viewModel:GetOccupationEquipments(occupation) or {}
end
local EC = require("Types.Vector")
def.method().CheckGodWeaponFeature = function(self)
  local JewelMgr = require("Main.GodWeapon.JewelMgr")
  local ctrlRoot = self.m_panel:FindDirect("Img_Bg0/Img_BgBag")
  local btnTabLS = ctrlRoot:FindDirect("Tab_LingShi")
  local btnTabItem = ctrlRoot:FindDirect("Tab_Item")
  local btnTabTask = ctrlRoot:FindDirect("Tab_Task")
  local btnTabTreasure = ctrlRoot:FindDirect("Tab_Treasure")
  local imgLS = self.m_panel:FindDirect("Img_Bg0/Img_LingShi")
  local comItem = btnTabItem:GetComponent("UIWidget")
  local comSelItem = btnTabItem:FindDirect("Img_BgBagSelet"):GetComponent("UIWidget")
  local comLS = btnTabLS:GetComponent("UIWidget")
  local comSelLS = btnTabLS:FindDirect("Img_BgLingShiSelet"):GetComponent("UIWidget")
  local comTask = btnTabTask:GetComponent("UIWidget")
  local comSelTask = btnTabTask:FindDirect("Img_BgTaskSelet"):GetComponent("UIWidget")
  local comTreasure = btnTabTreasure:GetComponent("UIWidget")
  local comSelTreasure = btnTabTreasure:FindDirect("Img_BgTaskSelet"):GetComponent("UIWidget")
  if JewelMgr.IsJewelBagFeatureOpen() then
    btnTabLS:SetActive(true)
    comItem.width = 100
    comSelItem.width = 100
    comLS.width = 100
    comLS.width = 100
    comTask.width = 100
    comSelTask.width = 100
    comTreasure.width = 100
    comSelTreasure.width = 100
    btnTabItem.transform.localPosition = EC.Vector3.new(55, 176, 0)
    btnTabLS.transform.localPosition = EC.Vector3.new(155, 176, 0)
    btnTabTreasure.transform.localPosition = EC.Vector3.new(255, 176, 0)
    btnTabTask.transform.localPosition = EC.Vector3.new(355, 176, 0)
    self:ResetJewelBagCapacity()
    self:UpdateUIJewelBag()
    imgLS:SetActive(false)
  else
    btnTabItem.transform.localPosition = EC.Vector3.new(70, 176, 0)
    btnTabTreasure.transform.localPosition = EC.Vector3.new(202.5, 176, 0)
    btnTabTask.transform.localPosition = EC.Vector3.new(335, 176, 0)
    btnTabLS:SetActive(false)
    imgLS:SetActive(false)
    comItem.width = 130
    comSelItem.width = 130
    comTask.width = 130
    comSelTask.width = 130
    comTreasure.width = 130
    comSelTreasure.width = 130
    if self._state == 4 then
      self.m_panel:FindDirect("Img_Bg0/Img_Item"):SetActive(true)
      self:onClick("Tab_Item")
    end
  end
  if self._state == 1 then
    btnTabItem:GetComponent("UIToggle").value = true
  elseif self._state == 2 then
    btnTabTask:GetComponent("UIToggle").value = true
  elseif self._state == InventoryDlg.ShowState.TreasureBag then
    btnTabTreasure:GetComponent("UIToggle").value = true
  end
end
def.method("table").OnJewelBagFeatureChange = function(self, p)
  self:CheckGodWeaponFeature()
end
def.method().UpdateUIJewelBag = function(self)
  local items = require("Main.GodWeapon.JewelMgr").Instance()._data:GetJewelBag()
  local ctrlRoot = self.m_panel:FindDirect("Img_Bg0/Img_LingShi")
  ctrlRoot:SetActive(true)
  local bagGrid = ctrlRoot:FindDirect("Scroll View_Item/Grid_Item")
  local childCount = bagGrid:get_childCount()
  for i = 0, childCount - 1 do
    local item = bagGrid:GetChild(i)
    if string.sub(item.name, 1, 6) ~= "ItemL_" then
      break
    end
    local info = items[i]
    if info then
      self:SetIcon(item, i, info, true)
    else
      self:ClearIcon(item)
    end
  end
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method().ResetJewelBagCapacity = function(self)
  local cap = self._itemModule:GetJewelBagCapacity()
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_LingShi/Scroll View_Item/Grid_Item")
  local itemCount = self:GetNumberOfChildrenWithName(bagGrid, "ItemL_")
  if itemCount == cap then
    return
  end
  self:DeleteChildExcept(bagGrid, {ItemL_001 = true})
  local item001 = bagGrid:FindDirect("ItemL_001")
  for i = 2, cap do
    local item = bagGrid:FindDirect(string.format("ItemL_%03d", i))
    if item == nil then
      local itemNew = Object.Instantiate(item001)
      itemNew:set_name(string.format("ItemL_%03d", i))
      itemNew.parent = bagGrid
      itemNew:set_localScale(Vector.Vector3.one)
      self:ClearIcon(itemNew)
      self.m_msgHandler:Touch(itemNew)
    end
  end
  self:ResetJewelBagLock()
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method().ResetJewelBagLock = function(self)
  local bagCfg = DynamicData.GetRecord(CFG_PATH.DATA_BAGCFG, ItemModule.GOD_WEAPON_JEWEL_BAG)
  local max = bagCfg:GetIntValue("maxcapacity")
  local cap = self._itemModule:GetJewelBagCapacity()
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_LingShi/Scroll View_Item/Grid_Item")
  if max <= cap then
    return
  end
  local item001 = bagGrid:FindDirect("ItemL_001")
  for i = 1, 5 do
    local itemNew = Object.Instantiate(item001)
    itemNew:set_name(string.format("zilock_%d", i))
    itemNew.parent = bagGrid
    itemNew:set_localScale(Vector.Vector3.one)
    self:DisableIcon(itemNew)
    self.m_msgHandler:Touch(itemNew)
  end
end
def.method("table").OnJewelBagChange = function(self, p)
  if self._state == 4 then
    self:UpdateUIJewelBag()
  end
end
def.method().UpdateUITreasureBag = function(self)
  local items = self._itemModule:GetItemsByBagId(ItemModule.TREASURE_BAG)
  local ctrlRoot = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_ZhenPin")
  ctrlRoot:SetActive(true)
  local bagGrid = ctrlRoot:FindDirect("Scroll View_Item/Grid_Item")
  local childCount = bagGrid:get_childCount()
  for i = 0, childCount - 1 do
    local item = bagGrid:GetChild(i)
    if string.sub(item.name, 1, 6) ~= "ItemZ_" then
      break
    end
    local info = items[i]
    if info then
      self:SetIcon(item, i, info, true)
    else
      self:ClearIcon(item)
    end
  end
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method().ResetTreasureBagCapacity = function(self)
  local cap = self._itemModule:GetTreasureBagCapacity()
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_ZhenPin/Scroll View_Item/Grid_Item")
  local itemCount = self:GetNumberOfChildrenWithName(bagGrid, "ItemZ_")
  if itemCount == cap then
    return
  end
  self:DeleteChildExcept(bagGrid, {ItemZ_001 = true})
  local item001 = bagGrid:FindDirect("ItemZ_001")
  for i = 2, cap do
    local item = bagGrid:FindDirect(string.format("ItemZ_%03d", i))
    if item == nil then
      local itemNew = Object.Instantiate(item001)
      itemNew:set_name(string.format("ItemZ_%03d", i))
      itemNew.parent = bagGrid
      itemNew:set_localScale(Vector.Vector3.one)
      self:ClearIcon(itemNew)
      self.m_msgHandler:Touch(itemNew)
    end
  end
  self:ResetTreasureBagLock()
  local uiGrid = bagGrid:GetComponent("UIGrid")
  uiGrid:Reposition()
end
def.method().ResetTreasureBagLock = function(self)
  local bagCfg = DynamicData.GetRecord(CFG_PATH.DATA_BAGCFG, ItemModule.TREASURE_BAG)
  local max = bagCfg:GetIntValue("maxcapacity")
  local cap = self._itemModule:GetTreasureBagCapacity()
  local bagGrid = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Img_ZhenPin/Scroll View_Item/Grid_Item")
  if max <= cap then
    return
  end
  local item001 = bagGrid:FindDirect("ItemZ_001")
  for i = 1, 5 do
    local itemNew = Object.Instantiate(item001)
    itemNew:set_name(string.format("zilock_%d", i))
    itemNew.parent = bagGrid
    itemNew:set_localScale(Vector.Vector3.one)
    self:DisableIcon(itemNew)
    self.m_msgHandler:Touch(itemNew)
  end
end
def.method("table").OnTreasureBagChange = function(self, p)
  if self._state == InventoryDlg.ShowState.TreasureBag then
    self:UpdateUITreasureBag()
  end
end
def.method().UpdateTreasureBagNotify = function(self)
  local Tab_Treasure = self.m_panel:FindDirect("Img_Bg0/Img_BgBag/Tab_Treasure")
  local Img_Red = Tab_Treasure:FindDirect("Img_Red")
  GUIUtils.SetActive(Img_Red, ItemModule.Instance():HasTreasureBagNotify())
end
def.method().CheckToRemoveTreasureBagNotify = function(self)
  if not ItemModule.Instance():HasViewTreasureBagNotify() and ItemModule.Instance():HasTreasureBagNotify() then
    ItemModule.Instance():SetTreasureBagNotify(false)
    self:UpdateTreasureBagNotify()
  end
end
def.method("table").OnTreasureBagNotifyChange = function(self, params)
  self:UpdateTreasureBagNotify()
end
InventoryDlg.Commit()
return InventoryDlg
