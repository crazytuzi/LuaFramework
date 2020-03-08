local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local ECPanelBase = require("GUI.ECPanelBase")
local Huanhun = Lplus.Extend(ECPanelBase, "Huanhun")
local def = Huanhun.define
local inst
local ItemUtils = require("Main.Item.ItemUtils")
local itemData = require("Main.Item.ItemData").Instance()
local TimeCfgUtils = require("Main.Common.TimeCfgUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemTips = require("Main.Item.ui.ItemTips")
local TaskInterface = require("Main.task.TaskInterface")
local taskInterfaceInstance = TaskInterface.Instance()
local TaskConsts = require("netio.protocol.mzm.gsp.task.TaskConsts")
local TaskConClassType = require("consts.mzm.gsp.task.confbean.TaskConClassType")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local ItemInfo = require("netio.protocol.mzm.gsp.huanhun.ItemInfo")
local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local EquipUtils = require("Main.Equip.EquipUtils")
def.static("=>", Huanhun).Instance = function()
  if inst == nil then
    inst = Huanhun()
    inst:Init()
  end
  return inst
end
def.field("number")._forceSelectedIndex = 0
def.field("number")._selectedIndex = 0
def.field("userdata")._roleIdSeekHelp = nil
def.field("table")._huanhunItemInfos = nil
def.field("number")._enddingSec = 0
def.field("boolean")._mySelf = false
def.field("number")._timerID = -1
def.field("boolean").isshowing = false
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("userdata", "table").ShowDlg = function(self, roleIdSeekHelp, huanhunItemInfos)
  self._roleIdSeekHelp = roleIdSeekHelp
  self._huanhunItemInfos = huanhunItemInfos
  local myRoleID = _G.GetMyRoleID()
  self._mySelf = myRoleID == self._roleIdSeekHelp
  if self:IsShow() == false then
    self.isshowing = true
    self:CreatePanel(RESPATH.PREFAB_UI_HUANHUN, 1)
    self:SetModal(true)
  end
end
def.method().HideDlg = function(self)
  self.isshowing = false
  self:DestroyPanel()
end
def.method("number").SetEnddingSec = function(self, enddingSec)
  self._enddingSec = enddingSec
end
def.method("=>", "userdata").GetTargetRoleID = function(self)
  return self._roleIdSeekHelp
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:HideDlg()
  end
  local fnTable = {}
  fnTable.Btn_Help = Huanhun.OnBtn_Help
  fnTable.Btn_Add = Huanhun.OnBtn_Add
  fnTable.Btn_GetWay = Huanhun.OnBtnImgItem
  fnTable.Btn_Get = Huanhun.OnBtn_Get
  fnTable.Img_Item1 = Huanhun.OnBtnImgItem
  fnTable.Img_BgPrize = Huanhun.OnImg_BgPrize
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
    return
  end
  local strs = string.split(id, "_")
  if strs[1] == "Img" and strs[2] == "BgItem" then
    local index = tonumber(strs[3])
    if index ~= nil then
      Huanhun.OnIconClick(self, index)
    end
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, Huanhun.OnBagInfoSynchronized)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, Huanhun.OnBagInfoSynchronized)
  self._forceSelectedIndex = 0
  self._selectedIndex = 0
  self._roleIdSeekHelp = nil
  self._huanhunItemInfos = nil
  self._mySelf = false
  self.isshowing = false
  if self:IsShow() == true then
    local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
    local Group_Prize = Img_Bg0:FindDirect("Group_Prize")
    local Btn_Get = Group_Prize:FindDirect("Btn_Get")
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:Fill()
    local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
    local Label_Tips = Img_Bg0:FindDirect("Label_Tips")
    local Label_TipsTime = Img_Bg0:FindDirect("Label_TipsTime")
    if self._mySelf == true then
      Huanhun.OnTimer()
      Label_Tips:SetActive(true)
      Label_TipsTime:SetActive(true)
    else
      Label_Tips:SetActive(false)
      Label_TipsTime:SetActive(false)
    end
  elseif self:IsShow() == true then
    local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
    local Group_Prize = Img_Bg0:FindDirect("Group_Prize")
    local Btn_Get = Group_Prize:FindDirect("Btn_Get")
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
  end
end
def.method().Fill = function(self)
  self:_FillItems()
  self:SelectANotFinishedItem()
  self:_FillAward()
end
def.method()._FillItems = function(self)
  if _G.IsNil(self.m_panel) then
    return
  end
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Item = Img_Bg0:FindDirect("Group_Item")
  for i = 1, 8 do
    local Img_BgItem = Group_Item:FindDirect(string.format("Img_BgItem_%d", i))
    local Texture_Icon = Img_BgItem:FindDirect("Texture_Icon")
    local Img_Select = Img_BgItem:FindDirect("Img_Select")
    local Label_Num = Img_BgItem:FindDirect("Img_BgNum/Label_Num")
    local Img_Finish = Img_BgItem:FindDirect("Img_Finish")
    local Img_Help = Img_BgItem:FindDirect("Img_Help")
    local Img_BgName = Img_BgItem:FindDirect("Img_BgName")
    local itemInfo = self._huanhunItemInfos[i]
    if itemInfo ~= nil then
      local itemBase = ItemUtils.GetItemBase2(itemInfo.itemCfgId)
      local uiTexture = Texture_Icon:GetComponent("UITexture")
      local done = itemInfo.taskState == ItemInfo.ST_TASK_DONE
      local count = self:GetOwnItemNum(itemInfo.itemCfgId)
      if count >= itemInfo.itemNum or done == true then
        Label_Num:GetComponent("UILabel"):set_text(tostring(itemInfo.itemNum))
      else
        Label_Num:GetComponent("UILabel"):set_text("[ff0000]" .. tostring(itemInfo.itemNum) .. "[-]")
      end
      if itemBase ~= nil then
        GUIUtils.FillIcon(uiTexture, itemBase.icon)
      else
        local filterCfg = ItemUtils.GetItemFilterCfg(itemInfo.itemCfgId)
        GUIUtils.FillIcon(uiTexture, filterCfg.icon)
      end
      Img_Finish:SetActive(itemInfo.taskState == ItemInfo.ST_TASK_DONE)
      Img_Help:SetActive(itemInfo.gangHelpState == ItemInfo.ST_HELP__TRUE)
      if itemInfo.roleInfo.roleId:eq(0) == false and itemInfo.roleInfo.roleId ~= self._roleIdSeekHelp then
        Img_BgName:SetActive(true)
        local Img_Head = Img_BgName:FindDirect("Img_BgHead/Img_Head")
        local sprite = Img_Head:GetComponent("UISprite")
        local spriteName = GUIUtils.GetHeadSpriteName(itemInfo.roleInfo.occupationid, itemInfo.roleInfo.gender)
        sprite:set_spriteName(spriteName)
        local Label_Name = Img_BgName:FindDirect("Label_Name")
        Label_Name:GetComponent("UILabel"):set_text(itemInfo.roleInfo.name)
      else
        Img_BgName:SetActive(false)
      end
    end
  end
end
def.method("number", "=>", "number").GetOwnItemNum = function(self, itemId)
  local itemBase = ItemUtils.GetItemBase2(itemId)
  local count = 0
  if itemBase then
    count = itemData:GetNumberByItemId(BagInfo.BAG, itemBase.itemid)
    if itemBase.itemType == ItemType.EQUIP then
      local items = itemData:GetItemsByItemID(itemId)
      for i, v in pairs(items) do
        local strenLv = EquipUtils.GetEquipStrenLevel(BagInfo.BAG, i)
        if strenLv > 0 then
          count = count - v.number
        end
      end
      if count < 0 then
        count = 0
      end
    end
    return count
  else
    local bag = itemData:GetBag(BagInfo.BAG)
    if bag then
      local itemSiftCfg = ItemUtils.GetItemFilterCfg(itemId)
      for itemKey, item in pairs(bag) do
        local itembase = ItemUtils.GetItemBase(item.id)
        local strenLv = 0
        if itembase.itemType == ItemType.EQUIP then
          strenLv = EquipUtils.GetEquipStrenLevel(BagInfo.BAG, itemKey)
        end
        if ItemUtils.FiltrateAItem(itembase, itemSiftCfg) == true and strenLv == 0 then
          count = count + item.number
        end
      end
      return count
    end
  end
  return count
end
def.method().SelectANotFinishedItem = function(self)
  if self:_SelectANotFinishedItem() == 0 then
    local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
    local Group_Single = Img_Bg0:FindDirect("Group_Single")
    local Group_Label = Img_Bg0:FindDirect("Group_Label")
    Group_Single:SetActive(false)
    Group_Label:SetActive(true)
    local Label = Group_Label:FindDirect("Label")
    local complete = true
    for k, itemInfo in pairs(self._huanhunItemInfos) do
      if itemInfo.taskState ~= ItemInfo.ST_TASK_DONE then
        complete = false
        break
      end
    end
    if complete == true then
      Label:GetComponent("UILabel"):set_text(textRes.activity[203])
    else
      Label:GetComponent("UILabel"):set_text(textRes.activity[204])
    end
  end
end
def.method("=>", "number")._SelectANotFinishedItem = function(self)
  local firstNotFinished = 0
  local firstNotFinishedAndNonHelp = 0
  if self._forceSelectedIndex ~= 0 then
    local itemInfo = self._huanhunItemInfos[self._forceSelectedIndex]
    if itemInfo ~= nil and itemInfo.taskState ~= ItemInfo.ST_TASK_DONE then
      firstNotFinished = self._forceSelectedIndex
    end
    self:_SetSelectedItem(firstNotFinished)
    self:_FillSelectedItem()
    return firstNotFinished
  end
  for i = 1, 8 do
    local itemInfo = self._huanhunItemInfos[i]
    if itemInfo ~= nil and itemInfo.taskState ~= ItemInfo.ST_TASK_DONE then
      if firstNotFinished == 0 then
        firstNotFinished = i
      end
      if firstNotFinishedAndNonHelp == 0 and itemInfo.gangHelpState ~= ItemInfo.ST_HELP__TRUE then
        firstNotFinishedAndNonHelp = i
      end
      local itemBase = ItemUtils.GetItemBase2(itemInfo.itemCfgId)
      if itemBase ~= nil then
        local count = self:GetOwnItemNum(itemBase.itemid)
        if count >= itemInfo.itemNum then
          self:_SetSelectedItem(i)
          self:_FillSelectedItem()
          return i
        end
      else
        local count = self:GetOwnItemNum(itemInfo.itemCfgId)
        if count >= itemInfo.itemNum then
          self:_SetSelectedItem(i)
          self:_FillSelectedItem()
          return i
        end
      end
    end
  end
  if firstNotFinishedAndNonHelp ~= 0 then
    firstNotFinished = firstNotFinishedAndNonHelp
  end
  self:_SetSelectedItem(firstNotFinished)
  if firstNotFinished == 0 then
    return 0
  end
  self:_FillSelectedItem()
  return firstNotFinished
end
def.method("number")._SetSelectedItem = function(self, index)
  if _G.IsNil(self.m_panel) then
    return
  end
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Item = Img_Bg0:FindDirect("Group_Item")
  for i = 1, 8 do
    local Img_BgItem = Group_Item:FindDirect(string.format("Img_BgItem_%d", i))
    local Img_Select = Img_BgItem:FindDirect("Img_Select")
    Img_Select:SetActive(index == i)
    if index == i then
      self._selectedIndex = i
    end
  end
end
def.method()._FillSelectedItem = function(self)
  if _G.IsNil(self.m_panel) then
    return
  end
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Single = Img_Bg0:FindDirect("Group_Single")
  local Group_Label = Img_Bg0:FindDirect("Group_Label")
  local index = self._selectedIndex
  if index ~= 0 then
    Group_Single:SetActive(true)
    Group_Label:SetActive(false)
    local Img_Item1 = Group_Single:FindDirect("Img_Item1")
    local Texture_Item = Img_Item1:FindDirect("Texture_Item")
    local itemInfo = self._huanhunItemInfos[index]
    local itemBase = ItemUtils.GetItemBase2(itemInfo.itemCfgId)
    local uiTexture = Texture_Item:GetComponent("UITexture")
    local enough = false
    local Label_Num = Img_Item1:FindDirect("Label_Num")
    local count = self:GetOwnItemNum(itemInfo.itemCfgId)
    if count >= itemInfo.itemNum then
      Label_Num:GetComponent("UILabel"):set_text(tostring(count) .. "/" .. tostring(itemInfo.itemNum))
      enough = true
    else
      Label_Num:GetComponent("UILabel"):set_text("[ff0000]" .. tostring(count) .. "/" .. tostring(itemInfo.itemNum) .. "[-]")
    end
    if itemBase ~= nil then
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
    else
      local filterCfg = ItemUtils.GetItemFilterCfg(itemInfo.itemCfgId)
      GUIUtils.FillIcon(uiTexture, filterCfg.icon)
    end
    local Btn_Help = Group_Single:FindDirect("Btn_Help")
    local done = itemInfo.taskState == ItemInfo.ST_TASK_DONE
    local gangeHelp = itemInfo.gangHelpState == ItemInfo.ST_HELP__TRUE
    local canHelp = self._mySelf == true and done == false and gangeHelp == false and self._forceSelectedIndex == 0
    Btn_Help:SetActive(canHelp == true)
    if canHelp == true then
      local Label = Btn_Help:FindDirect("Label")
      Label:GetComponent("UILabel"):set_text(string.format(textRes.activity[201], activityInterface._seekHelpLeftCount, constant.HuanHunMiShuConsts.HUANHUN_SEEK_HELP_NUM))
    end
    local Label_EXPNum = Group_Single:FindDirect("Label_EXPNum")
    Label_EXPNum:GetComponent("UILabel"):set_text(tostring(itemInfo.awardXiuLianExp))
    local Btn_Add = Group_Single:FindDirect("Btn_Add")
    local Btn_GetWay = Group_Single:FindDirect("Btn_GetWay")
    Btn_Add:SetActive(enough == true)
    Btn_GetWay:SetActive(enough == false)
  else
    Group_Single:SetActive(false)
    Group_Label:SetActive(true)
    local Label = Group_Label:FindDirect("Label")
  end
end
def.method()._FillAward = function(self)
  if _G.IsNil(self.m_panel) then
    return
  end
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Prize = Img_Bg0:FindDirect("Group_Prize")
  local myRoleID = _G.GetMyRoleID()
  if myRoleID == self._roleIdSeekHelp == false then
    Group_Prize:SetActive(false)
    return
  end
  Group_Prize:SetActive(true)
  local Img_BgPrize = Group_Prize:FindDirect("Img_BgPrize")
  local Texture_Prize = Img_BgPrize:FindDirect("Texture_Prize")
  local itemBase = ItemUtils.GetItemBase(constant.HuanHunMiShuConsts.HUANHUN_AWARD_ITEM_ID)
  local uiTexture = Texture_Prize:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, itemBase.icon)
  local Label_PrizeNum = Img_BgPrize:FindDirect("Label_PrizeNum")
  Label_PrizeNum:GetComponent("UILabel"):set_text(tostring(constant.HuanHunMiShuConsts.HUANHUN_AWARD_ITEM_NUM))
  local Btn_Get = Group_Prize:FindDirect("Btn_Get")
  local SSynHuanhuiInfo = require("netio.protocol.mzm.gsp.huanhun.SSynHuanhuiInfo")
  if activityInterface._huanhunStatus == SSynHuanhuiInfo.ST_HUN__FINISH then
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.Square)
  else
    GUIUtils.SetLightEffect(Btn_Get, GUIUtils.Light.None)
  end
end
def.static(Huanhun).OnBtn_Help = function(self)
  local gangModule = gmodule.moduleMgr:GetModule(ModuleId.GANG)
  local bHaveGang = gangModule:HasGang()
  if bHaveGang == false then
    Toast(textRes.activity[212])
    return
  end
  if activityInterface._seekHelpLeftCount <= 0 then
    Toast(textRes.activity[210])
    return
  end
  local completeNum = 0
  for k, itemInfo in pairs(self._huanhunItemInfos) do
    if itemInfo.taskState == ItemInfo.ST_TASK_DONE then
      completeNum = completeNum + 1
    end
  end
  if completeNum < constant.HuanHunMiShuConsts.HUANHUN_FULL_BOX_NUM_BEFORE_SEEK_HRLP then
    Toast(string.format(textRes.activity[223], constant.HuanHunMiShuConsts.HUANHUN_FULL_BOX_NUM_BEFORE_SEEK_HRLP))
    return
  end
  local selectedIndex = self._selectedIndex
  local p = require("netio.protocol.mzm.gsp.huanhun.CSeekHelpFromGangReq").new(selectedIndex)
  gmodule.network.sendProtocol(p)
end
def.static(Huanhun).OnBtn_Add = function(self)
  local selectedIndex = self._selectedIndex
  local UUIDs = {}
  local itemInfo = self._huanhunItemInfos[selectedIndex]
  local enough = false
  if itemInfo ~= nil then
    local GiveoutItemBean = require("netio.protocol.mzm.gsp.huanhun.GiveoutItemBean")
    local needCount = itemInfo.itemNum
    if itemInfo.taskState ~= ItemInfo.ST_TASK_DONE then
      local itemBase = ItemUtils.GetItemBase2(itemInfo.itemCfgId)
      local bag = itemData:GetBag(BagInfo.BAG)
      if itemBase ~= nil then
        local count = 0
        for i, v in pairs(bag) do
          if v.id == itemInfo.itemCfgId then
            local itemBase = ItemUtils.GetItemBase2(v.id)
            local strenLv = 0
            if itemBase.itemType == ItemType.EQUIP then
              strenLv = EquipUtils.GetEquipStrenLevel(BagInfo.BAG, i)
            end
            if strenLv == 0 then
              local tb = GiveoutItemBean.new()
              tb.uuid = v.uuid[1]
              tb.num = math.min(needCount - count, v.number)
              table.insert(UUIDs, tb)
              count = count + tb.num
              if needCount > 0 and needCount <= count then
                break
              end
            end
          end
        end
        if needCount <= count then
          enough = true
        end
      else
        local count = 0
        local itemSiftCfg = ItemUtils.GetItemFilterCfg(itemInfo.itemCfgId)
        for itemKey, item in pairs(bag) do
          local itembase = ItemUtils.GetItemBase(item.id)
          local strenLv = 0
          if itembase.itemType == ItemType.EQUIP then
            strenLv = EquipUtils.GetEquipStrenLevel(BagInfo.BAG, itemKey)
          end
          if ItemUtils.FiltrateAItem(itembase, itemSiftCfg) == true and strenLv == 0 then
            local tb = GiveoutItemBean.new()
            tb.uuid = item.uuid[1]
            tb.num = math.min(needCount - count, item.number)
            table.insert(UUIDs, tb)
            count = count + tb.num
            if needCount > 0 and needCount <= count then
              break
            end
          end
        end
        if needCount <= count then
          enough = true
        end
      end
    end
  end
  if enough == true then
    local roleIdSeekHelp = self._roleIdSeekHelp
    local p = require("netio.protocol.mzm.gsp.huanhun.CAddXItemInfoReq").new(roleIdSeekHelp, selectedIndex, UUIDs)
    gmodule.network.sendProtocol(p)
  else
    Toast(textRes.activity[200])
  end
end
def.static(Huanhun).OnBtn_Get = function(self)
  for k, itemInfo in pairs(self._huanhunItemInfos) do
    if itemInfo.taskState ~= ItemInfo.ST_TASK_DONE then
      Toast(textRes.activity[202])
      return
    end
  end
  local SSynHuanhuiInfo = require("netio.protocol.mzm.gsp.huanhun.SSynHuanhuiInfo")
  if activityInterface._huanhunStatus == SSynHuanhuiInfo.ST_HUN__ACCEPT then
    Toast(textRes.activity[202])
    return
  end
  if activityInterface._huanhunStatus == SSynHuanhuiInfo.ST_HUN__HAND_UP then
    Toast(textRes.activity[205])
    return
  end
  local p = require("netio.protocol.mzm.gsp.huanhun.CGetHuanhunAwardReq").new()
  gmodule.network.sendProtocol(p)
end
def.static(Huanhun).OnBtnImgItem = function(self)
  local selectedIndex = self._selectedIndex
  local itemInfo = self._huanhunItemInfos[selectedIndex]
  local itemID = itemInfo.itemCfgId
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Single = Img_Bg0:FindDirect("Group_Single")
  local Img_Item1 = Group_Single:FindDirect("Img_Item1")
  local position = Img_Item1:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = Img_Item1:GetComponent("UISprite")
  local itemBase = ItemUtils.GetItemBase2(itemID)
  if itemBase ~= nil then
    ItemTipsMgr.Instance():ShowBasicTips(itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
  else
    ItemTipsMgr.Instance():ShowItemFilterTips(itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
  end
end
def.static(Huanhun).OnImg_BgPrize = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Group_Prize = Img_Bg0:FindDirect("Group_Prize")
  local Img_BgPrize = Group_Prize:FindDirect("Img_BgPrize")
  local position = Img_BgPrize:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = Img_BgPrize:GetComponent("UISprite")
  local itemID = constant.HuanHunMiShuConsts.HUANHUN_AWARD_ITEM_ID
  local itemBase = ItemUtils.GetItemBase2(itemID)
  if itemBase ~= nil then
    ItemTipsMgr.Instance():ShowBasicTips(itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
  else
    ItemTipsMgr.Instance():ShowItemFilterTips(itemID, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, true)
  end
end
def.static().OnTimer = function()
  local self = inst
  if self:IsShow() == false then
    return
  end
  local nowSec = GetServerTime()
  local remainSec = math.max(0, self._enddingSec - nowSec)
  if remainSec == 0 then
    self:HideDlg()
    return
  end
  local hour = remainSec / 3600
  local min = remainSec % 3600 / 60
  local sec = remainSec % 60
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  local Label_TipsTime = Img_Bg0:FindDirect("Label_TipsTime")
  if hour > 0 then
    Label_TipsTime:GetComponent("UILabel"):set_text(string.format(textRes.Title[6], hour, min, sec))
  elseif min > 0 then
    Label_TipsTime:GetComponent("UILabel"):set_text(string.format(textRes.Title[7], min, sec))
  else
    Label_TipsTime:GetComponent("UILabel"):set_text(string.format(textRes.Title[8], sec))
  end
  self._timerID = GameUtil.AddGlobalTimer(1, true, Huanhun.OnTimer)
end
def.static(Huanhun, "number").OnIconClick = function(self, index)
  local itemInfo = self._huanhunItemInfos[index]
  if itemInfo ~= nil then
    if not self._mySelf and itemInfo.gangHelpState ~= ItemInfo.ST_HELP__TRUE then
      return
    end
    if itemInfo.taskState ~= ItemInfo.ST_TASK_DONE then
      self:_SetSelectedItem(index)
      self:_FillSelectedItem()
    end
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local self = inst
  if self.IsShow == false then
    return
  end
  self:Fill()
end
Huanhun.Commit()
return Huanhun
