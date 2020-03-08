local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MountsStarPanel = Lplus.Extend(ECPanelBase, "MountsStarPanel")
local GUIUtils = require("GUI.GUIUtils")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local MountsUIModel = require("Main.Mounts.MountsUIModel")
local MountsUtils = require("Main.Mounts.MountsUtils")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local MountsConst = require("netio.protocol.mzm.gsp.mounts.MountsConst")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = MountsStarPanel.define
local instance
def.field("table").uiObjs = nil
def.field("userdata").mountsId = nil
def.field("number").selectedStarNum = 0
def.field("boolean").hasEnoughMaterial = false
def.field("boolean").useYuanbao = false
def.field("number").needYuanbao = 0
def.field("number").needItemType = -1
def.field("number").needItemNum = 0
def.field("number").hasItemNum = 0
def.field("number").calItemId = 0
def.static("=>", MountsStarPanel).Instance = function()
  if instance == nil then
    instance = MountsStarPanel()
  end
  return instance
end
def.method("userdata").ShowPanelWithMountsId = function(self, mountsId)
  if self.m_panel ~= nil or not MountsMgr.Instance():HasMounts(mountsId) then
    return
  end
  self.mountsId = mountsId
  self:CreatePanel(RESPATH.PREFAB_MOUNTS_STAR, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitStarLiftMap()
  self:SetStarLifeMapInfo()
  self:ShowMountsStarInfo()
  self:ShowCost()
  self:MoveToNextStar()
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsActiveStartListSuccess, MountsStarPanel.OnMountsActiveStartListSuccess)
  Event.RegisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MountsStarPanel.OnMountsFunctionOpenChange)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MountsStarPanel.OnBagInfoSynchronized)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.mountsId = nil
  self:ClearData()
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsActiveStartListSuccess, MountsStarPanel.OnMountsActiveStartListSuccess)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsFunctionOpenChange, MountsStarPanel.OnMountsFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MountsStarPanel.OnBagInfoSynchronized)
end
def.method().ClearData = function(self)
  self.selectedStarNum = 0
  self.hasEnoughMaterial = false
  self.useYuanbao = false
  self.needYuanbao = 0
  self.needItemType = -1
  self.needItemNum = 0
  self.hasItemNum = 0
  self.calItemId = 0
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.starTemplate = self.uiObjs.Img_Bg0:FindDirect("Group_Shuxing")
  self.uiObjs.Img_StarBg = self.uiObjs.Img_Bg0:FindDirect("Img_StarBg")
  GUIUtils.SetActive(self.uiObjs.starTemplate, false)
end
def.method().InitStarLiftMap = function(self)
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  if mounts == nil then
    return
  end
  local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
  local mountsStartMapCfg = MountsUtils.GetMountsStartLifeMapCfg(mounts.mounts_cfg_id)
  if mountsCfg == nil or mountsStartMapCfg == nil then
    return
  end
  GUIUtils.SetTexture(self.uiObjs.Img_StarBg, mountsCfg.starLifePictureId)
  local widget = self.uiObjs.Img_StarBg:GetComponent("UIWidget")
  local mapRoot = GameObject.GameObject("StarMapRoot")
  mapRoot.parent = self.uiObjs.Img_StarBg
  mapRoot.transform.localScale = Vector3.one
  mapRoot.localPosition = Vector3.new(-widget.width / 2, widget.height / 2, 0)
  for i = 1, #mountsStartMapCfg do
    local starObj = GameObject.Instantiate(self.uiObjs.starTemplate)
    if starObj ~= nil then
      starObj:SetActive(true)
      starObj.name = "Star_" .. mountsStartMapCfg[i].starNum
      starObj.parent = mapRoot
      starObj.transform.localScale = Vector3.one
      starObj.localPosition = Vector3.new(mountsStartMapCfg[i].coordinateX, mountsStartMapCfg[i].coordinateY, 0)
      self:FillMountsStarInfo(starObj, mountsStartMapCfg[i].starNum, 0)
    end
  end
end
def.method("userdata", "number", "number").FillMountsStarInfo = function(self, starObj, starNum, starLevel)
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  if mounts == nil then
    return
  end
  local mountsStarCfg = MountsUtils.GetMountsStartLifeCfgById(mounts.mounts_cfg_id)
  if mountsStarCfg == nil then
    return
  end
  local Img_StarUnAcrived = starObj:FindDirect("Img_StarUnAcrived")
  local Img_StarActived = starObj:FindDirect("Img_StarActived")
  local Label_Shuxing_1 = starObj:FindDirect("Label_Shuxing_1")
  local Group_Star = starObj:FindDirect("Group_Star")
  local Img_Star = Group_Star:FindDirect("Img_Star")
  local Label_Star = Group_Star:FindDirect("Label_Star")
  local starWidth = Img_Star:GetComponent("UIWidget").width
  GUIUtils.SetSprite(Img_StarUnAcrived, starNum .. "")
  GUIUtils.SetSprite(Img_StarActived, starNum .. "")
  if starLevel <= 0 then
    GUIUtils.SetActive(Img_StarUnAcrived, true)
    GUIUtils.SetActive(Img_StarActived, false)
    GUIUtils.SetActive(Label_Shuxing_1, false)
    GUIUtils.SetActive(Img_Star, false)
    GUIUtils.SetText(Label_Star, "")
  else
    GUIUtils.SetActive(Img_StarUnAcrived, false)
    GUIUtils.SetActive(Img_StarActived, true)
    GUIUtils.SetActive(Label_Shuxing_1, true)
    if mountsStarCfg[starNum] ~= nil and mountsStarCfg[starNum][starLevel] ~= nil then
      local propertyList = mountsStarCfg[starNum][starLevel].propertyList
      local desc = {}
      for i = 1, #propertyList do
        local propertyCfg = _G.GetCommonPropNameCfg(propertyList[i].nameKey)
        if propertyCfg ~= nil then
          table.insert(desc, string.format("%s + %d", propertyCfg.propName, propertyList[i].value))
        end
      end
      GUIUtils.SetText(Label_Shuxing_1, table.concat(desc, "\n"))
    end
    GUIUtils.SetActive(Img_Star, true)
    GUIUtils.SetText(Label_Star, starLevel)
  end
end
def.method().SetStarLifeMapInfo = function(self)
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  if mounts == nil then
    return
  end
  local mountsStartMapCfg = MountsUtils.GetMountsStartLifeMapCfg(mounts.mounts_cfg_id)
  if mountsStartMapCfg == nil then
    return
  end
  local curStarLevel = mounts.current_star_level
  local maxActiveStartNum = mounts.current_max_active_star_num
  for i = 1, maxActiveStartNum do
    local starObj = self.uiObjs.Img_StarBg:FindDirect("StarMapRoot/Star_" .. i)
    if starObj ~= nil then
      self:FillMountsStarInfo(starObj, i, curStarLevel)
    end
  end
  for i = maxActiveStartNum + 1, #mountsStartMapCfg do
    local starObj = self.uiObjs.Img_StarBg:FindDirect("StarMapRoot/Star_" .. i)
    if starObj ~= nil then
      self:FillMountsStarInfo(starObj, i, curStarLevel - 1)
    end
  end
end
def.method().ShowMountsStarInfo = function(self)
  self:ShowBasicStarMapInfo()
  if self.selectedStarNum <= 0 then
    self:ShowMountsStarMapInfo()
  else
    self:ShowSelectedStarInfo()
  end
end
def.method().ShowBasicStarMapInfo = function(self)
  local mapName = ""
  local maxStarNum = 0
  local curActiveStarNum = 0
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  local mountsStartMapCfg, mountsCfg
  if mounts ~= nil then
    mountsStartMapCfg = MountsUtils.GetMountsStartLifeMapCfg(mounts.mounts_cfg_id)
    mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
    curActiveStarNum = mounts.current_max_active_star_num
    if mountsCfg ~= nil then
      mapName = mountsCfg.starLifePictureName
    end
    if mountsStartMapCfg ~= nil then
      maxStarNum = #mountsStartMapCfg
      if mounts.current_star_level <= 1 then
        curActiveStarNum = mounts.current_max_active_star_num
      else
        curActiveStarNum = maxStarNum
      end
    end
  end
  local Group_Right = self.uiObjs.Img_Bg0:FindDirect("Group_Right")
  local Label_Name = Group_Right:FindDirect("Label_Name")
  local Label_ActivedNumber = Group_Right:FindDirect("Label_ActivedNumber")
  GUIUtils.SetText(Label_Name, mapName)
  GUIUtils.SetText(Label_ActivedNumber, string.format("%d/%d", curActiveStarNum, maxStarNum))
end
def.method().ShowMountsStarMapInfo = function(self)
  local Group_Right = self.uiObjs.Img_Bg0:FindDirect("Group_Right")
  local Img_Bg1 = Group_Right:FindDirect("Img_Bg1")
  local Label_Weizhi = Img_Bg1:FindDirect("Label_Weizhi")
  local Label_Shuxing = Img_Bg1:FindDirect("Label_Shuxing")
  local Label_Conditions = Img_Bg1:FindDirect("Label_Conditions")
  GUIUtils.SetText(Label_Weizhi, "")
  GUIUtils.SetText(Label_Conditions, "")
  GUIUtils.SetText(Label_Shuxing, textRes.Mounts[47])
end
def.method().ShowSelectedStarInfo = function(self)
  local star = self.uiObjs.Img_StarBg:FindDirect("StarMapRoot/Star_" .. self.selectedStarNum)
  if star ~= nil then
    star:GetComponent("UIToggle").value = true
  end
  local mapName = ""
  local propertyDesc = {}
  local curStarLevel = MountsMgr.Instance():GetMountsStarLevel(self.mountsId, self.selectedStarNum)
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  local mountsCfg, mountsStarCfg
  if mounts ~= nil then
    mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
    mountsStarCfg = MountsUtils.GetMountsStartLifeCfgById(mounts.mounts_cfg_id)
  end
  if mountsCfg ~= nil then
    mapName = mountsCfg.starLifePictureName or ""
  end
  if mountsStarCfg ~= nil and mountsStarCfg[self.selectedStarNum] ~= nil then
    local starCfg = mountsStarCfg[self.selectedStarNum][curStarLevel]
    if starCfg == nil then
      starCfg = mountsStarCfg[self.selectedStarNum][curStarLevel + 1]
    end
    if starCfg ~= nil then
      local propertyList = starCfg.propertyList
      for i = 1, #propertyList do
        local propertyCfg = _G.GetCommonPropNameCfg(propertyList[i].nameKey)
        if propertyCfg ~= nil then
          table.insert(propertyDesc, string.format("%s + %d", propertyCfg.propName, propertyList[i].value))
        end
      end
    end
  end
  local Group_Right = self.uiObjs.Img_Bg0:FindDirect("Group_Right")
  local Img_Bg1 = Group_Right:FindDirect("Img_Bg1")
  local Label_Weizhi = Img_Bg1:FindDirect("Label_Weizhi")
  local Label_Shuxing = Img_Bg1:FindDirect("Label_Shuxing")
  local Label_Conditions = Img_Bg1:FindDirect("Label_Conditions")
  GUIUtils.SetText(Label_Weizhi, string.format(textRes.Mounts[48], mapName, self.selectedStarNum))
  GUIUtils.SetText(Label_Shuxing, table.concat(propertyDesc, "\n"))
  local nextStarCfg
  if mountsStarCfg[self.selectedStarNum] ~= nil then
    nextStarCfg = mountsStarCfg[self.selectedStarNum][curStarLevel + 1]
  end
  local desc = ""
  if nextStarCfg ~= nil then
    if MountsMgr.Instance():IsReachMaxStarLevel(self.mountsId, self.selectedStarNum) then
      desc = textRes.Mounts[54]
    elseif MountsMgr.Instance():IsStarReachMapLevel(self.mountsId, self.selectedStarNum) then
      desc = string.format(textRes.Mounts[49], curStarLevel, curStarLevel + 1)
    elseif MountsMgr.Instance():CanMountsActiveOrUpStar(self.mountsId, self.selectedStarNum) then
      if mounts.mounts_rank < nextStarCfg.unLockRank then
        desc = string.format(textRes.Mounts[50], nextStarCfg.unLockRank, curStarLevel + 1)
      else
        desc = ""
      end
    else
      desc = textRes.Mounts[55]
    end
  else
    desc = textRes.Mounts[54]
  end
  GUIUtils.SetText(Label_Conditions, desc)
end
def.method().ShowCost = function(self)
  local Group_Cost = self.uiObjs.Img_Bg0:FindDirect("Group_Cost")
  local Group_YS = self.uiObjs.Img_Bg0:FindDirect("Group_YS")
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  if mounts == nil or not MountsMgr.Instance():CanMountsActiveOrUpStar(self.mountsId, self.selectedStarNum) or self.selectedStarNum == 0 then
    GUIUtils.SetActive(Group_Cost, false)
    GUIUtils.SetActive(Group_YS, false)
    return
  end
  GUIUtils.SetActive(Group_Cost, true)
  GUIUtils.SetActive(Group_YS, true)
  local Img_ItemIcon = Group_Cost:FindDirect("Img_ItemIcon")
  local Label_ItemNumber = Group_Cost:FindDirect("Label_ItemNumber")
  local Label_ItemName = Group_Cost:FindDirect("Label_ItemName")
  local Group_UseYuanbao = Group_Cost:FindDirect("Group_UseYuanbao")
  local Btn_UseGold = Group_UseYuanbao:FindDirect("Btn_UseGold")
  local curStarLevel = MountsMgr.Instance():GetMountsStarLevel(self.mountsId, self.selectedStarNum)
  local mountsStarCfg = MountsUtils.GetMountsStartLifeCfgById(mounts.mounts_cfg_id)
  local unLockRank = 0
  if mountsStarCfg ~= nil and mountsStarCfg[self.selectedStarNum] ~= nil and mountsStarCfg[self.selectedStarNum][curStarLevel + 1] ~= nil then
    unLockRank = mountsStarCfg[self.selectedStarNum][curStarLevel + 1].unLockRank
  end
  self.hasEnoughMaterial = false
  if mountsStarCfg == nil or mountsStarCfg[self.selectedStarNum] == nil or mountsStarCfg[self.selectedStarNum][curStarLevel + 1] == nil or unLockRank > mounts.mounts_rank then
    GUIUtils.SetActive(Group_Cost, false)
    GUIUtils.SetActive(Group_YS, false)
  else
    local levelUpCfg = mountsStarCfg[self.selectedStarNum][curStarLevel + 1]
    local needItemType = levelUpCfg.costItemType
    local needNum = levelUpCfg.costItemNum
    local calItemId = levelUpCfg.costItemId
    local needItemList = ItemUtils.GetItemTypeRefIdList(needItemType)
    if needItemList ~= nil then
      local itemBase = ItemUtils.GetItemBase(needItemList[1])
      if itemBase ~= nil then
        GUIUtils.FillIcon(Img_ItemIcon:GetComponent("UITexture"), itemBase.icon)
        local hasNum = 0
        local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, needItemType)
        for k, v in pairs(items) do
          hasNum = hasNum + v.number
        end
        self.needItemType = needItemType
        self.needItemNum = needNum
        self.hasItemNum = hasNum
        self.calItemId = calItemId
        if needNum > hasNum then
          GUIUtils.SetText(Label_ItemNumber, string.format("[ff0000]%d/%d[-]", hasNum, needNum))
        else
          GUIUtils.SetText(Label_ItemNumber, string.format("%d/%d", hasNum, needNum))
          self.hasEnoughMaterial = true
        end
        GUIUtils.SetText(Label_ItemName, itemBase.name)
      end
    else
      GUIUtils.SetActive(Group_Cost, false)
      GUIUtils.SetActive(Group_YS, false)
    end
  end
end
def.method("number").SelectMountsStar = function(self, star)
  self.selectedStarNum = star
  self:ShowMountsStarInfo()
  self:ShowCost()
  self:SetButtonStatus()
end
def.method().ActiveSelectStar = function(self)
  if self.hasEnoughMaterial or self.useYuanbao then
    local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
    if Int64.lt(yuanBaoNum, self.needYuanbao) then
      _G.GotoBuyYuanbao()
      return
    end
    MountsMgr.Instance():MountsActiveStarLife(self.mountsId, self.useYuanbao, self.needYuanbao)
  else
    self:ConfirmUseYuanbao()
  end
end
def.method().ClickUseYuanbao = function(self)
  local Group_UseYuanbao = self.uiObjs.Img_Bg0:FindDirect("Group_Cost/Group_UseYuanbao")
  local Btn_UseGold = Group_UseYuanbao:FindDirect("Btn_UseGold")
  if not Btn_UseGold:GetComponent("UIToggle").value then
    self.useYuanbao = false
    self:SetButtonStatus()
    return
  end
  self:ConfirmUseYuanbao()
end
def.method().ConfirmUseYuanbao = function(self)
  if self.hasEnoughMaterial then
    self.useYuanbao = false
    self:SetButtonStatus()
    Toast(textRes.Mounts[42])
    return
  end
  CommonConfirmDlg.ShowConfirm("", textRes.Mounts[52], function(result)
    self.useYuanbao = result == 1
    self:SetButtonStatus()
  end, nil)
end
def.method().SetButtonStatus = function(self)
  local Group_YS = self.uiObjs.Img_Bg0:FindDirect("Group_YS")
  local Btn_Active = Group_YS:FindDirect("Btn_Active")
  local Group_Yuanbao = Btn_Active:FindDirect("Group_Yuanbao")
  local Label = Btn_Active:FindDirect("Label")
  local Label_Money = Group_Yuanbao:FindDirect("Label_Money")
  if not self.useYuanbao or self.hasEnoughMaterial then
    GUIUtils.SetActive(Label, true)
    GUIUtils.SetActive(Group_Yuanbao, false)
  else
    require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(self.calItemId, function(result)
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      self.needYuanbao = result * (self.needItemNum - self.hasItemNum)
      GUIUtils.SetActive(Label, false)
      GUIUtils.SetActive(Group_Yuanbao, true)
      GUIUtils.SetText(Label_Money, self.needYuanbao)
    end)
  end
  local Group_UseYuanbao = self.uiObjs.Img_Bg0:FindDirect("Group_Cost/Group_UseYuanbao")
  local Btn_UseGold = Group_UseYuanbao:FindDirect("Btn_UseGold")
  Btn_UseGold:GetComponent("UIToggle").value = self.useYuanbao
end
def.method("userdata").ShowMaterialTips = function(self, source)
  if self.needItemType ~= -1 then
    local needItemList = ItemUtils.GetItemTypeRefIdList(self.needItemType)
    if needItemList ~= nil then
      local needItemId = needItemList[1]
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(needItemId, source.parent, 0, true)
    end
  end
end
def.method().MoveToNextStar = function(self)
  local mounts = MountsMgr.Instance():GetMountsById(self.mountsId)
  if mounts == nil then
    return
  end
  self:SelectMountsStar(mounts.current_max_active_star_num + 1)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Sprite" then
    self:DestroyPanel()
  elseif string.find(id, "Star_") then
    local star = tonumber(string.sub(id, #"Star_" + 1))
    if star ~= nil then
      self:SelectMountsStar(star)
    end
  elseif id == "Btn_UseGold" then
    self:ClickUseYuanbao()
  elseif id == "Btn_Active" then
    self:ActiveSelectStar()
  elseif id == "Img_ItemIcon" then
    self:ShowMaterialTips(clickObj)
  elseif id == "Btn_Tips" then
    require("GUI.GUIUtils").ShowHoverTip(constant.CMountsConsts.starLifeDesTips)
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.static("table", "table").OnMountsActiveStartListSuccess = function(params, context)
  local self = instance
  if self ~= nil then
    self:SetStarLifeMapInfo()
    self:MoveToNextStar()
  end
end
def.static("table", "table").OnMountsFunctionOpenChange = function(params, context)
  local self = instance
  if self ~= nil then
    local MountsModule = require("Main.Mounts.MountsModule")
    if not MountsModule.IsFunctionOpen() then
      self:Close()
    end
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(params, context)
  local self = instance
  if self ~= nil then
    self:ShowCost()
    self:SetButtonStatus()
  end
end
MountsStarPanel.Commit()
return MountsStarPanel
