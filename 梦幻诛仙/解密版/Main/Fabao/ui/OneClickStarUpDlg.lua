local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local OneClickStarUpDlg = Lplus.Extend(ECPanelBase, "OneClickStarUpDlg")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local OneClickStarUpEasy = require("Main.Fabao.OneClickStarUpEasy")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local EC = require("Types.Vector3")
local def = OneClickStarUpDlg.define
local instance
def.static("=>", OneClickStarUpDlg).Instance = function()
  if not instance then
    instance = OneClickStarUpDlg()
    instance.m_TrigGC = true
  end
  return instance
end
def.field("table").starUpFabao = nil
def.field("number").bagKey = -1
def.field("boolean").equiped = false
def.field("boolean").useYuanbao = false
def.field("number").yuanbaoNum = 0
def.field("number").targetFabaoId = 0
def.field("table").targetfabaos = nil
def.field("table").cost = nil
def.field("table").need = nil
def.field(OneClickStarUpEasy).calculator = nil
def.method("table", "number", "boolean").ShowPanel = function(self, fabao, bagKey, equiped)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.starUpFabao = fabao
  self.bagKey = bagKey
  self.equiped = equiped
  self.useYuanbao = false
  self.yuanbaoNum = 0
  self.targetFabaoId = 0
  self.targetfabaos = nil
  self.cost = {}
  self.need = {}
  self.calculator = OneClickStarUpEasy.new()
  self:CreatePanel(RESPATH.PANEL_FABAO_ONE_CLICK_STARUP, 0)
  self:SetModal(true)
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, OneClickStarUpDlg.OnItemChange, self)
  self:InitTitle()
  self:UpdateYuanbao()
  self:Calculate()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, OneClickStarUpDlg.OnItemChange)
  self.starUpFabao = nil
  self.bagKey = -1
  self.equiped = false
  self.useYuanbao = false
  self.yuanbaoNum = 0
  self.targetFabaoId = 0
  self.targetfabaos = nil
  self.cost = nil
  self.need = nil
end
def.method("table").OnItemChange = function(self, params)
  self:Calculate()
  if self.useYuanbao then
    self:UpdateYuanbao()
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Tips" then
    local id = FabaoUtils.GetFabaoConstValue("HOVER_TIPS_ID")
    if id > 0 then
      GUIUtils.ShowHoverTip(id, 0, 0)
    end
  elseif id == "Btn_FightMap" then
    local btns = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_BtnSelect/Table_TeamBtn")
    if btns:get_activeInHierarchy() then
      self:ShowBtns(false)
    else
      self:ShowBtns(true)
    end
  elseif string.sub(id, 1, 9) == "fabaoBtn_" then
    local index = tonumber(string.sub(id, 10))
    if index then
      self:SelectTarget(index)
    end
    self:ShowBtns(false)
  elseif id == "Btn_StarUp" then
    self:SendStarUp()
  elseif string.sub(id, 1, 9) == "ItemCost_" then
    local index = tonumber(string.sub(id, 10))
    if index then
      local info = self.cost[index]
      if info then
        local ItemModule = require("Main.Item.ItemModule")
        local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
        local itemKey = info.key
        local itemId = info.id
        local bagId = info.bagId
        local icon = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_Item/Group_Cost/Scrollview_Item/List_Item/" .. id)
        if itemKey then
          local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
          if itemInfo then
            ItemTipsMgr.Instance():ShowTipsEx(itemInfo, bagId, itemKey, ItemTipsMgr.Source.Other, icon, 0)
          end
        else
          ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, icon, 0, true)
        end
      end
    end
  elseif string.sub(id, 1, 9) == "ItemNeed_" then
    local index = tonumber(string.sub(id, 10))
    if index then
      local info = self.need[index]
      if info then
        local ItemModule = require("Main.Item.ItemModule")
        local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
        local itemKey = info.key
        local itemId = info.id
        local bagId = info.bagId
        local icon = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_Item/Group_Need/Scrollview_Item/List_Item/" .. id)
        if itemKey then
          local itemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
          if itemInfo then
            ItemTipsMgr.Instance():ShowTipsEx(itemInfo, bagId, itemKey, ItemTipsMgr.Source.Other, icon, 0)
          end
        else
          ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, icon, 0, true)
        end
      end
    end
  end
end
def.method("string", "boolean").onToggle = function(self, id, value)
  if id == "Btn_UseDep" then
    self.useYuanbao = value
    self:UpdateYuanbao()
  end
end
def.method().SendStarUp = function(self)
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  if self.useYuanbao == false and next(self.need) then
    CommonConfirmDlg.ShowConfirm(textRes.Fabao[139], textRes.Fabao[138], function(sel)
      if sel == 1 then
        self.useYuanbao = true
        self:UpdateYuanbao()
      end
    end, nil)
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
  if yuanbaoNum < Int64.new(self.yuanbaoNum) then
    GotoBuyYuanbao()
    return
  end
  local function send()
    local FaBaoConst = require("netio.protocol.mzm.gsp.fabao.FaBaoConst")
    local equiped = self.equiped and FaBaoConst.EQUIPED or FaBaoConst.UNEQUIPED
    local uuid = self.starUpFabao.uuid[1]
    local fabaoCfg = ItemUtils.GetFabaoItem(self.targetFabaoId)
    local star = fabaoCfg.rank
    local useYuanbaoNum = self.yuanbaoNum
    local costMap = {}
    for k, v in ipairs(self.cost) do
      if costMap[v.bagId] == nil then
        costMap[v.bagId] = require("netio.protocol.mzm.gsp.fabao.CostInfo").new(nil)
      end
      costMap[v.bagId].itemKey2Num[v.key] = v.num
    end
    local p = require("netio.protocol.mzm.gsp.fabao.CFaBaoAutoRankUpReq").new(equiped, uuid, star, costMap, useYuanbaoNum)
    gmodule.network.sendProtocol(p)
    self:DestroyPanel()
  end
  if self.yuanbaoNum > 0 then
    CommonConfirmDlg.ShowConfirm(textRes.Fabao[139], string.format(textRes.Fabao[141], self.yuanbaoNum), function(sel)
      if sel == 1 then
        send()
      end
    end, nil)
  else
    CommonConfirmDlg.ShowConfirm(textRes.Fabao[139], textRes.Fabao[140], function(sel)
      if sel == 1 then
        send()
      end
    end, nil)
  end
end
def.method().InitTitle = function(self)
  self.targetfabaos = self:GetStarUpFabao()
  self:InitBtns()
  self:SelectTarget(1)
  self:ShowBtns(false)
end
def.method("boolean").ShowBtns = function(self, show)
  local btns = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_BtnSelect/Table_TeamBtn")
  local upArrow = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_BtnSelect/Btn_FightMap/Img_Up")
  local downArrow = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_BtnSelect/Btn_FightMap/Img_Down")
  btns:SetActive(show)
  upArrow:SetActive(show)
  downArrow:SetActive(not show)
end
def.method().InitBtns = function(self)
  local btns = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_BtnSelect/Table_TeamBtn")
  local template = btns:FindDirect("DungeonBtn")
  template:SetActive(false)
  while btns:get_childCount() > 2 do
    local toBeDelete = btns:GetChild(btns:get_childCount() - 1)
    if toBeDelete.name ~= template.name and toBeDelete.name ~= "spaceHolder" then
      Object.DestroyImmediate(toBeDelete)
    end
  end
  for k, v in ipairs(self.targetfabaos) do
    local newBtn = Object.Instantiate(template)
    newBtn:SetActive(true)
    newBtn:FindDirect("Label_bTN"):GetComponent("UILabel"):set_text(v.name)
    newBtn.parent = btns
    newBtn.name = string.format("fabaoBtn_%d", k)
    newBtn:set_localScale(EC.Vector3.one)
    self.m_msgHandler:Touch(newBtn)
  end
  btns:GetComponent("UITableResizeBackground"):Reposition()
end
def.method("number").SelectTarget = function(self, index)
  local targetFabao = self.targetfabaos[index]
  if targetFabao and self.targetFabaoId ~= targetFabao.id then
    self.targetFabaoId = targetFabao.id
    local name = targetFabao.name
    local nameLbl = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_BtnSelect/Btn_FightMap/Label_CopyName")
    nameLbl:GetComponent("UILabel"):set_text(name)
    self:Calculate()
    self:UpdateYuanbao()
  end
end
def.method("=>", "table").GetStarUpFabao = function(self)
  local tarFabao = {}
  local fabaoId = self.starUpFabao.id
  local starUpCfg = ItemUtils.GetFabaoItem(fabaoId)
  local entrys = DynamicData.GetTable(CFG_PATH.DATA_FABAO_ITEM)
  local count = DynamicDataTable.GetRecordsCount(entrys)
  DynamicDataTable.FastGetRecordBegin(entrys)
  for i = 0, count - 1 do
    local record = DynamicDataTable.FastGetRecordByIdx(entrys, i)
    local classId = record:GetIntValue("classId")
    if starUpCfg.classId == classId then
      local star = record:GetIntValue("rank")
      if star > starUpCfg.rank then
        local id = record:GetIntValue("id")
        local cfg = OneClickStarUpEasy.GetOneClickCfg(id)
        if cfg then
          local itemBase = ItemUtils.GetItemBase(id)
          local name = itemBase.name
          table.insert(tarFabao, {
            id = id,
            name = name,
            star = star
          })
        end
      end
    end
  end
  DynamicDataTable.FastGetRecordEnd(entrys)
  table.sort(tarFabao, function(a, b)
    return a.star < b.star
  end)
  return tarFabao
end
def.method("userdata", "number", "number", "number").FillIcon = function(self, uiGo, itemId, num, index)
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase then
    local bg = uiGo:FindDirect(string.format("Img_Bg_%d", index))
    bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", itemBase.namecolor))
    local numLbl = uiGo:FindDirect(string.format("Label_Num_%d", index))
    numLbl:GetComponent("UILabel"):set_text(tonumber(num))
    local icon = uiGo:FindDirect(string.format("Img_Icon_%d", index))
    local tex = icon:GetComponent("UITexture")
    GUIUtils.FillIcon(tex, itemBase.icon)
  end
end
def.method("table").UpdateCost = function(self, items)
  local scrollView = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_Item/Group_Cost/Scrollview_Item")
  local list = scrollView:FindDirect("List_Item")
  local listCmp = list:GetComponent("UIList")
  local count = #items
  listCmp.itemCount = count
  listCmp:Resize()
  local childGOs = listCmp.children
  for i = 1, count do
    local childGO = childGOs[i]
    local itemInfo = items[i]
    self:FillIcon(childGO, itemInfo.id, itemInfo.num, i)
    self.m_msgHandler:Touch(childGO)
  end
end
def.method("table").UpdateNeed = function(self, items)
  local scrollView = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_Item/Group_Need/Scrollview_Item")
  local list = scrollView:FindDirect("List_Item")
  local listCmp = list:GetComponent("UIList")
  local count = #items
  listCmp.itemCount = count
  listCmp:Resize()
  local childGOs = listCmp.children
  for i = 1, count do
    local childGO = childGOs[i]
    local itemInfo = items[i]
    self:FillIcon(childGO, itemInfo.id, itemInfo.num, i)
    self.m_msgHandler:Touch(childGO)
  end
end
def.method().UpdateYuanbao = function(self)
  if self.useYuanbao then
    if #self.need == 0 then
      self.useYuanbao = false
      self.yuanbaoNum = 0
      Toast(textRes.Fabao[134])
    end
    if not self:CheckCanUseYuanbao() then
      self.useYuanbao = false
      self.yuanbaoNum = 0
      Toast(textRes.Fabao[135])
    end
  end
  local useYuanbaoToggle = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Group_UseDep/Btn_UseDep")
  local confirmBtn = self.m_panel:FindDirect("Img_Bg1/Group_CurrentEquip/Btn_StarUp")
  local noYuanbao = confirmBtn:FindDirect("Label_StarUp")
  local yuanbaoNum = confirmBtn:FindDirect("Group_Dep")
  useYuanbaoToggle:GetComponent("UIToggle").value = self.useYuanbao
  if self.useYuanbao then
    yuanbaoNum:FindDirect("Label_Money"):GetComponent("UILabel"):set_text("-")
    noYuanbao:SetActive(false)
    yuanbaoNum:SetActive(true)
    local needItemIds = {}
    for k, v in pairs(self.need) do
      table.insert(needItemIds, v.id)
    end
    local ItemPriceHelper = require("Main.Item.ItemPriceHelper")
    ItemPriceHelper.GetItemsYuanbaoPriceAsync(needItemIds, function(id2price)
      if not self:IsShow() then
        return
      end
      local yuanbaoCostNum = 0
      for k, v in pairs(self.need) do
        local price = id2price[v.id] or 0
        yuanbaoCostNum = yuanbaoCostNum + price * v.num
      end
      self.yuanbaoNum = yuanbaoCostNum
      yuanbaoNum:FindDirect("Label_Money"):GetComponent("UILabel"):set_text(tostring(yuanbaoCostNum))
    end)
  else
    noYuanbao:SetActive(true)
    yuanbaoNum:SetActive(false)
  end
end
def.method("=>", "boolean").CheckCanUseYuanbao = function(self)
  for k, v in pairs(self.need) do
    if ItemUtils.GetFabaoFragmentItem(v.id) then
      local composeFabaoId = FabaoUtils.GetFabaoFragmentComposeFabaoId(v.id)
      if composeFabaoId > 0 then
        local fabaoCfg = ItemUtils.GetFabaoItem(composeFabaoId)
        if not fabaoCfg.canUseYuanBao then
          return false
        end
      else
        return false
      end
    end
  end
  return true
end
def.method().Calculate = function(self)
  local cost, need = self.calculator:Calculate(self.starUpFabao, self.bagKey, self.targetFabaoId)
  self.cost = cost
  self.need = need
  self:UpdateCost(self.cost)
  self:UpdateNeed(self.need)
end
return OneClickStarUpDlg.Commit()
