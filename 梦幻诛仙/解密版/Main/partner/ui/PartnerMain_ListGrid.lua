local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local PartnerMain = Lplus.ForwardDeclare("PartnerMain")
local PartnerMain_ListGrid = Lplus.Class("PartnerMain_ListGrid")
local def = PartnerMain_ListGrid.define
local inst
local PartnerSex = require("consts.mzm.gsp.partner.confbean.PartnerSex")
local PartnerType = require("consts.mzm.gsp.partner.confbean.PartnerType")
local PubroleInterface = require("Main.Pubrole.PubroleInterface")
local PartnerInterface = require("Main.partner.PartnerInterface")
local partnerInterface = PartnerInterface.Instance()
local PartnerYuanShenMgr = require("Main.partner.PartnerYuanShenMgr")
def.field(PartnerMain)._partnerMain = nil
def.field("table").scrollListCells = nil
def.static(PartnerMain, "=>", PartnerMain_ListGrid).New = function(panel)
  if inst == nil then
    inst = PartnerMain_ListGrid()
    inst._partnerMain = panel
    inst:Init()
  end
  return inst
end
def.static("=>", PartnerMain_ListGrid).Instance = function()
  return inst
end
def.method().Init = function(self)
end
def.method().OnCreate = function(self)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Scroll_View = panel:FindDirect("Group_List/Scroll_View")
  local Grid_Gird = Scroll_View:FindDirect("Grid_Gird")
  local Img_BgMap01 = Grid_Gird:FindDirect("Img_BgMap01")
  Img_BgMap01:set_name("Img_BgMap_Partner_Grid_01")
  local Grid_List = Scroll_View:FindDirect("Grid_List")
  local Img_BgMap01 = Grid_List:FindDirect("Img_BgMap01")
  Img_BgMap01:set_name("Img_BgMap_Partner_List_01")
  local Group_Have = Img_BgMap01:FindDirect("Group_Have")
  local Btn_Zhan = Group_Have:FindDirect("Btn_Zhan")
  local Btn_Rest = Group_Have:FindDirect("Btn_Rest")
  local Img_Toggle = Group_Have:FindDirect("Img_Toggle")
  local Img_Grey = Img_BgMap01:FindDirect("Img_Grey")
  Btn_Zhan:set_name("Btn_Zhan_01")
  Btn_Rest:set_name("Btn_Rest_01")
  Img_Toggle:set_name("Img_Toggle_01")
  Img_Grey:set_name("Img_Grey_01")
  local Img_BgTitle = panel:FindDirect("Group_List/Img_BgTitle")
  local Img_Grid = Img_BgTitle:FindDirect("Img_Grid")
  local Img_List = Img_BgTitle:FindDirect("Img_List")
  local Scroll_View = panel:FindDirect("Group_List/Scroll_View")
  local Grid_List = Scroll_View:FindDirect("Grid_List")
  local Grid_Gird = Scroll_View:FindDirect("Grid_Gird")
  Img_Grid:SetActive(false)
  Img_List:SetActive(true)
  Grid_Gird:SetActive(false)
  Grid_List:SetActive(true)
end
def.method().OnDestroy = function(self)
  self.scrollListCells = nil
end
def.method("boolean").OnShow = function(self, s)
  if s == true then
  else
  end
end
def.method("userdata", "=>", "boolean").onClickObj = function(self, clickobj)
  local name = clickobj.name
  local strs = string.split(name, "_")
  if strs[1] == "Img" and strs[2] == "BgMap" and strs[3] == "Partner" and strs[4] == "List" then
    local item, idx = ScrollList_getItem(clickobj)
    self._partnerMain:SetSelected(idx)
    return true
  elseif strs[1] == "Img" and strs[2] == "Toggle" then
    local item, idx = ScrollList_getItem(clickobj.parent)
    local isSelected = clickobj:GetComponent("UIToggle"):get_value()
    if isSelected then
      self:_PartnerJoinBattle(idx)
      return true
    else
      self:_PartnerLeaveBattle(idx)
      return true
    end
  elseif strs[1] == "Img" and strs[2] == "Grey" then
    local item, idx = ScrollList_getItem(clickobj.parent)
    local partnerInfo = self._partnerMain._partnerList[idx]
    local joined = partnerInterface:IsPartnerInLineup(partnerInfo.id, self._partnerMain._editZhenfaIndex - 1)
    local invited = partnerInterface:HasThePartner(partnerInfo.id)
    if invited then
      local selectedPos = self._partnerMain._panelLineup._SelectLineupPosition
      if selectedPos ~= 0 then
        local lineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
        local selectedPartnerId = lineUp.positions[selectedPos - 1]
        if joined then
          if selectedPartnerId == partnerInfo.id then
            self:_PartnerLeaveBattle(idx)
          else
            local changePos = partnerInterface:GetLineupPosById(self._partnerMain._editZhenfaIndex - 1, partnerInfo.id)
            if changePos >= 0 then
              self._partnerMain._panelLineup:_SwapLineupPosition(changePos + 1)
            end
          end
          return true
        else
          self._partnerMain._panelLineup:_Unbattle(selectedPos)
          self:_PartnerJoinBattle(idx)
          return true
        end
      end
    end
    return true
  end
  return false
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  local fnTable = {}
  fnTable.Img_BgTitle = PartnerMain_ListGrid.SwitchListGrid
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
    return true
  end
  local strs = string.split(id, "_")
  if strs[1] == "Img" and strs[2] == "BgMap" and strs[3] == "Partner" then
    local index = tonumber(strs[5])
    if index ~= nil then
      self._partnerMain._selectedIndex = index
      if strs[4] == "Grid" then
        self._partnerMain:SetSelected(index)
        return true
      elseif strs[4] == "List" then
        self._partnerMain:SetSelected(index)
        return true
      end
    end
  elseif strs[1] == "Btn" and strs[2] == "Zhan" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:_PartnerJoinBattle(index)
      return true
    end
  elseif strs[1] == "Btn" and strs[2] == "Rest" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:_PartnerLeaveBattle(index)
      return true
    end
  elseif strs[1] == "Img" and strs[2] == "Toggle" then
    local index = tonumber(strs[3])
    if index ~= nil then
      local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
      local Scroll_View = panel:FindDirect("Group_List/Scroll_View")
      local Grid_List = Scroll_View:FindDirect("Grid_List")
      local Img_BgMap_Partner_List = Grid_List:FindDirect(string.format("Img_BgMap_Partner_List_%02d", index))
      local Group_Have = Img_BgMap_Partner_List:FindDirect("Group_Have")
      local img_toggle = Group_Have:FindDirect(string.format("Img_Toggle_%02d", index))
      local isSelected = img_toggle:GetComponent("UIToggle"):get_value()
      if isSelected then
        self:_PartnerJoinBattle(index)
        return true
      else
        self:_PartnerLeaveBattle(index)
        return true
      end
    end
  elseif strs[1] == "Img" and strs[2] == "Grey" then
    local index = tonumber(strs[3])
    local partnerInfo = self._partnerMain._partnerList[index]
    local joined = partnerInterface:IsPartnerInLineup(partnerInfo.id, self._partnerMain._editZhenfaIndex - 1)
    local invited = partnerInterface:HasThePartner(partnerInfo.id)
    if invited then
      local selectedPos = self._partnerMain._panelLineup._SelectLineupPosition
      if selectedPos ~= 0 then
        local lineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
        local selectedPartnerId = lineUp.positions[selectedPos - 1]
        if joined then
          if selectedPartnerId == partnerInfo.id then
            self:_PartnerLeaveBattle(index)
          else
            local changePos = partnerInterface:GetLineupPosById(self._partnerMain._editZhenfaIndex - 1, partnerInfo.id)
            if changePos >= 0 then
              self._partnerMain._panelLineup:_SwapLineupPosition(changePos + 1)
            end
          end
          return true
        else
          self._partnerMain._panelLineup:_Unbattle(selectedPos)
          self:_PartnerJoinBattle(index)
          return true
        end
      end
    end
  end
  return false
end
def.method("string", "=>", "boolean").onDoubleClick = function(self, id)
  local strs = string.split(id, "_")
  if strs[1] == "Img" and strs[2] == "BgMap" and strs[3] == "Partner" and strs[4] == "Grid" then
    local index = tonumber(strs[5])
    if index ~= nil then
      local SelectedCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
      local joined = partnerInterface:IsPartnerInLineup(SelectedCfg.id, self._partnerMain._editZhenfaIndex - 1)
      local invited = partnerInterface:HasThePartner(SelectedCfg.id)
      if invited == false then
        Toast(textRes.Partner[35])
      elseif joined == true then
        self:_PartnerLeaveBattle(index)
      else
        self:_PartnerJoinBattle(index)
      end
      return true
    end
  end
  return false
end
def.method().SwitchListGrid = function(self)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Img_BgTitle = panel:FindDirect("Group_List/Img_BgTitle")
  local Img_Grid = Img_BgTitle:FindDirect("Img_Grid")
  local Img_List = Img_BgTitle:FindDirect("Img_List")
  local Scroll_View = panel:FindDirect("Group_List/Scroll_View")
  local Grid_List = Scroll_View:FindDirect("Grid_List")
  local Grid_Gird = Scroll_View:FindDirect("Grid_Gird")
  local gridActive = Grid_Gird:get_activeSelf()
  Img_Grid:SetActive(gridActive == false)
  Img_List:SetActive(gridActive == true)
  Grid_Gird:SetActive(gridActive == false)
  Grid_List:SetActive(gridActive == true)
  Scroll_View:GetComponent("UIScrollView"):ResetPosition()
end
def.method()._FillListGrid = function(self)
  local partnerCfgsList = partnerInterface:GetPartnerCfgsList()
  local oldSelectedCfg
  if self._partnerMain._partnerList[self._partnerMain._selectedIndex] ~= nil then
    oldSelectedCfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  end
  self._partnerMain._partnerList = {}
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local oldSelectedIndex = self._partnerMain._selectedIndex
  self._partnerMain._selectedIndex = 1
  for index, v in pairs(partnerCfgsList) do
    table.insert(self._partnerMain._partnerList, v)
  end
  table.sort(self._partnerMain._partnerList, function(l, r)
    local lineupIndex = self._partnerMain._editZhenfaIndex - 1
    local hasl = partnerInterface:HasThePartner(l.id)
    local hasr = partnerInterface:HasThePartner(r.id)
    local lJoined = partnerInterface:IsPartnerInLineup(l.id, lineupIndex)
    local rJoined = partnerInterface:IsPartnerInLineup(r.id, lineupIndex)
    if hasl == true and hasr == true then
      if lJoined == rJoined then
        return l.unlockLevel < r.unlockLevel
      end
      return lJoined == true and rJoined == false
    end
    if hasl == false and hasr == false then
      return l.unlockLevel < r.unlockLevel
    end
    return hasl
  end)
  local partnersInfo = {}
  for index, v in pairs(self._partnerMain._partnerList) do
    local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, v.modelId)
    local headidx = DynamicRecord.GetIntValue(modelinfo, "headerIconId")
    if headidx == 0 then
      headidx = 3002
    end
    local joined = partnerInterface:IsPartnerInLineup(v.id, self._partnerMain._editZhenfaIndex - 1)
    local special = v.partnerType == PartnerType.TYPE_SPECIAL
    local lock = heroProp.level < v.unlockLevel
    local invited = partnerInterface:HasThePartner(v.id)
    self:_AddGridItem(index, headidx, joined, special, lock, invited)
    local info = {
      info = v,
      level = heroProp.level,
      headidx = headidx,
      joined = joined,
      special = special,
      lock = lock,
      invited = invited
    }
    table.insert(partnersInfo, info)
    if oldSelectedCfg ~= nil and oldSelectedCfg.id == v.id then
      self._partnerMain._selectedIndex = index
    end
  end
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Scroll_View = panel:FindDirect("Group_List/Scroll_View")
  local Grid_List = Scroll_View:FindDirect("Grid_List")
  local GUIScrollList = Grid_List:GetComponent("GUIScrollList")
  if not GUIScrollList then
    Grid_List:AddComponent("GUIScrollList")
  end
  local uiScrollList = Grid_List:GetComponent("UIScrollList")
  self.scrollListCells = {}
  ScrollList_setUpdateFunc(uiScrollList, function(cellUI, index)
    local parent = cellUI.parent
    self.scrollListCells[parent.name] = cellUI
    local info = partnersInfo[index]
    local v = info.info
    self:_AddListItem(cellUI, index, v.name, v.faction, heroProp.level, v.unlockLevel, info.headidx, info.joined, info.special, info.lock, info.invited, v)
  end)
  ScrollList_setCount(uiScrollList, #partnersInfo)
  GUIUtils.ResetPosition(Scroll_View, 0.1)
  self._partnerMain:TouchGameObject(self._partnerMain.m_panel, self._partnerMain.m_parent)
  self:_SetSelectedGrid(self._partnerMain._selectedIndex)
  self:_SetSelectedList(self._partnerMain._selectedIndex)
end
def.method().refreshCurSelectedPartnerInfo = function(self)
  local index = self._partnerMain._selectedIndex
  local partnerCfg = self._partnerMain._partnerList[index]
  if partnerCfg then
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, partnerCfg.modelId)
    local headidx = DynamicRecord.GetIntValue(modelinfo, "headerIconId")
    if headidx == 0 then
      headidx = 3002
    end
    local joined = partnerInterface:IsPartnerInLineup(partnerCfg.id, self._partnerMain._editZhenfaIndex - 1)
    local special = partnerCfg.partnerType == PartnerType.TYPE_SPECIAL
    local lock = heroProp.level < partnerCfg.unlockLevel
    local invited = partnerInterface:HasThePartner(partnerCfg.id)
    local cellUI = self:getScrollListCell(index)
    if cellUI then
      self:_AddListItem(cellUI, index, partnerCfg.name, partnerCfg.faction, heroProp.level, partnerCfg.unlockLevel, headidx, joined, special, lock, invited, partnerCfg)
    end
  end
end
def.method("number", "number", "boolean", "boolean", "boolean", "boolean")._AddGridItem = function(self, index, icon, joined, special, lock, invited)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Scroll_View = panel:FindDirect("Group_List/Scroll_View")
  local Grid_Gird = Scroll_View:FindDirect("Grid_Gird")
  local grid = Grid_Gird:GetComponent("UIGrid")
  local Img_BgMap_Partner_Grid_01 = Grid_Gird:FindDirect("Img_BgMap_Partner_Grid_01")
  local Img_BgMap_Partner_Grid = Grid_Gird:FindDirect(string.format("Img_BgMap_Partner_Grid_%02d", index))
  local parent = Img_BgMap_Partner_Grid_01.parent
  if Img_BgMap_Partner_Grid == nil then
    Img_BgMap_Partner_Grid = Object.Instantiate(Img_BgMap_Partner_Grid_01)
    Img_BgMap_Partner_Grid:set_name(string.format("Img_BgMap_Partner_Grid_%02d", index))
    Img_BgMap_Partner_Grid.parent = parent
    Img_BgMap_Partner_Grid:set_localScale(Vector.Vector3.one)
    grid:Reposition()
  else
    Img_BgMap_Partner_Grid:SetActive(true)
  end
  local Img_Lock = Img_BgMap_Partner_Grid:FindDirect("Img_Lock")
  Img_Lock:SetActive(lock)
  local Img_SignZhan = Img_BgMap_Partner_Grid:FindDirect("Img_SignZhan")
  Img_SignZhan:SetActive(joined)
  local Img_Invite = Img_BgMap_Partner_Grid:FindDirect("Img_Invite")
  Img_Invite:SetActive(invited == false and lock == false)
  local Img_unusual = Img_BgMap_Partner_Grid:FindDirect("Img_unusual")
  Img_unusual:SetActive(special == false)
  local Txt_Head = Img_BgMap_Partner_Grid:FindDirect("Txt_Head")
  local uiTexture = Txt_Head:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, icon)
  if lock == true then
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
  else
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
  end
end
def.method("userdata", "number", "string", "number", "number", "number", "number", "boolean", "boolean", "boolean", "boolean", "table")._AddListItem = function(self, Img_BgMap_Partner_List, index, partnerName, school, level, unlockLevel, icon, joined, special, lock, invited, partnerCfg)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  if Img_BgMap_Partner_List == nil then
    Img_BgMap_Partner_List:set_name(string.format("Img_BgMap_Partner_List_%02d", index))
    Img_BgMap_Partner_List:set_localScale(Vector.Vector3.one)
    local Btn_Zhan = Img_BgMap_Partner_List:FindDirect("Group_Have/Btn_Zhan_01")
    local Btn_Rest = Img_BgMap_Partner_List:FindDirect("Group_Have/Btn_Rest_01")
    local Img_Toggle = Img_BgMap_Partner_List:FindDirect("Group_Have/Img_Toggle_01")
    local Img_Grey = Img_BgMap_Partner_List:FindDirect("Img_Grey_01")
    Img_Grey:set_name(string.format("Img_Grey_%02d", index))
    Btn_Zhan:set_name(string.format("Btn_Zhan_%02d", index))
    Btn_Rest:set_name(string.format("Btn_Rest_%02d", index))
    Img_Toggle:set_name(string.format("Img_Toggle_%02d", index))
  else
    Img_BgMap_Partner_List:SetActive(true)
  end
  local Img_BgSelect = Img_BgMap_Partner_List:FindDirect("Img_BgSelect")
  Img_BgSelect:SetActive(self._partnerMain._selectedIndex == index)
  local Btn_Zhan = Img_BgMap_Partner_List:FindDirect("Group_Have/Btn_Zhan_01")
  local Btn_Rest = Img_BgMap_Partner_List:FindDirect("Group_Have/Btn_Rest_01")
  local Img_Toggle = Img_BgMap_Partner_List:FindDirect("Group_Have/Img_Toggle_01")
  local Img_Grey = Img_BgMap_Partner_List:FindDirect("Img_Grey_01")
  local Label_FightLevel = Img_BgMap_Partner_List:FindDirect("Label_FightLevel")
  local Label_Name = Img_BgMap_Partner_List:FindDirect("Label_Name")
  Label_Name:GetComponent("UILabel"):set_text(partnerName)
  local rankInfoId = partnerInterface:getPartnerInfoCfgId(partnerCfg.id)
  local Img_unusual = Img_BgMap_Partner_List:FindDirect("Img_BgHead/Img_unusual")
  if rankInfoId > 0 then
    local rankInfoCfg = PartnerInterface.GetRankInfoCfg(rankInfoId)
    local rankEnum = rankInfoCfg.rankEnum
    local color = rankInfoCfg.color
    local rankLvStr = partnerInterface:getRankLevelStr(rankEnum)
    if rankLvStr then
      Label_FightLevel:GetComponent("UILabel"):set_text(rankLvStr)
    else
      Label_FightLevel:GetComponent("UILabel"):set_text(partnerCfg.rank)
    end
    local bg = Img_BgMap_Partner_List:FindDirect("Img_BgHead")
    local quality = color
    bg:GetComponent("UISprite"):set_spriteName(string.format("Cell_%02d", quality))
    Img_unusual:SetActive(false)
  else
    Img_unusual:SetActive(true)
    Label_FightLevel:GetComponent("UILabel"):set_text(partnerCfg.rank)
    Img_unusual:GetComponent("UISprite"):set_color(Color.Color(1, 1, 1, 1))
  end
  local Label_Yuanshen = Img_BgMap_Partner_List:FindDirect("Label")
  if invited == true then
    local yuanshenLv = partnerInterface:getYuanshenLevel(partnerCfg.id)
    Label_Yuanshen:GetComponent("UILabel"):set_text(textRes.Partner[60] .. "+" .. yuanshenLv)
  else
    Label_Yuanshen:GetComponent("UILabel"):set_text("")
  end
  local Label_Lv = Img_BgMap_Partner_List:FindDirect("Label_Lv")
  if lock == true then
    Label_Lv:GetComponent("UILabel"):set_text(string.format(textRes.Partner[1], unlockLevel))
  else
    Label_Lv:GetComponent("UILabel"):set_text(string.format(textRes.Partner[2], level))
  end
  local Img_Lock = Img_BgMap_Partner_List:FindDirect("Group_Lock/Img_Lock")
  Img_Lock:SetActive(lock)
  local Img_SignZhan = Img_BgMap_Partner_List:FindDirect("Group_Have/Img_SignZhan")
  Img_SignZhan:SetActive(joined)
  local Group_NotHave = Img_BgMap_Partner_List:FindDirect("Group_NotHave")
  Group_NotHave:SetActive(lock == false and invited == false)
  Btn_Zhan:SetActive(invited == true and joined == false)
  Btn_Rest:SetActive(invited == true and joined == true)
  local Img_BgSelect = Img_BgMap_Partner_List:FindDirect("Img_BgSelect")
  local Txt_Head = Img_BgMap_Partner_List:FindDirect("Img_BgHead/Txt_Head")
  local uiTexture = Txt_Head:GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, icon)
  if lock == true then
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
  else
    GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Normal)
  end
  local Img_School = Img_BgMap_Partner_List:FindDirect("Img_School")
  local sprite = Img_School:GetComponent("UISprite")
  sprite:set_spriteName(string.format("%d-8", school))
  local Tab_BZ = panel:FindDirect("Tab_BZ")
  local Img_TabBZSelect = Tab_BZ:FindDirect("Img_TabBZSelect")
  local isLineUp = Img_TabBZSelect:get_activeSelf()
  local Group_Have = Img_BgMap_Partner_List:FindDirect("Group_Have")
  local isYuanShenOpen = PartnerYuanShenMgr.Instance():IsFeatureOpen()
  local Group_YuanShen = Img_BgMap_Partner_List:FindDirect("Group_YuanShen")
  GUIUtils.SetActive(Group_YuanShen, isYuanShenOpen)
  if isYuanShenOpen and Group_YuanShen then
    local Label_Lv = Group_YuanShen:FindDirect("Label_Lv")
    local Img_Icon = Group_YuanShen:FindDirect("Img_Icon")
    local positionText = ""
    local position = PartnerYuanShenMgr.Instance():GetYuanShenByPartnerId(partnerCfg.id)
    if position ~= 0 then
      local positionCfg = PartnerInterface.GetPartnerYuanShenPositionCfg(position)
      local positionName = positionCfg and positionCfg.name
      local displayInfo = PartnerYuanShenMgr.Instance():GetYuanShenPosDisplayInfo(position)
      local level = displayInfo.level
      GUIUtils.SetText(Label_Lv, level)
      local spriteName = positionCfg and positionCfg.spriteName or "nil"
      GUIUtils.SetSprite(Img_Icon, spriteName)
    else
      GUIUtils.SetActive(Group_YuanShen, false)
    end
  end
  if not isLineUp then
  end
  Btn_Zhan:SetActive(false)
  Btn_Rest:SetActive(false)
  Img_Toggle:SetActive(invited)
  Img_Toggle:GetComponent("UIToggle").value = joined
  do break end
  Img_Toggle:SetActive(false)
  self:setLineUpStatus(Img_BgMap_Partner_List, index)
end
def.method("number")._SetSelectedGrid = function(self, index)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Scroll_View = panel:FindDirect("Group_List/Scroll_View")
  local Grid_Gird = Scroll_View:FindDirect("Grid_Gird")
  local grid = Grid_Gird:GetComponent("UIGrid")
  local count = Grid_Gird:get_childCount()
  for i = 1, count do
    local Img_BgMap_Partner_Grid = Grid_Gird:FindDirect(string.format("Img_BgMap_Partner_Grid_%02d", i))
    local Img_BgSelect = Img_BgMap_Partner_Grid:FindDirect("Img_BgSelect")
    Img_BgSelect:SetActive(i == index)
  end
end
def.method("number")._SetSelectedList = function(self, index)
  if self.scrollListCells then
    for i, cellUI in pairs(self.scrollListCells) do
      local item, idx = ScrollList_getItem(cellUI)
      local Img_BgSelect = cellUI:FindDirect("Img_BgSelect")
      Img_BgSelect:SetActive(idx == index)
    end
  end
end
def.method("number").ScrollSelectedIndex = function(self, index)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Scroll_View = panel:FindDirect("Group_List/Scroll_View")
  local Grid_List = Scroll_View:FindDirect("Grid_List")
  local GUIScrollList = Grid_List:GetComponent("GUIScrollList")
  if not GUIScrollList then
    Grid_List:AddComponent("GUIScrollList")
  end
  local uiScrollList = Grid_List:GetComponent("UIScrollList")
  ScrollList_setFirstIndex(uiScrollList, index)
  local len = -1
  if self._partnerMain._partnerList then
    len = #self._partnerMain._partnerList
  end
  if index == len then
    GameUtil.AddGlobalTimer(0.5, true, function()
      if _G.IsNil(Scroll_View) then
        return
      end
      local ScrollView = Scroll_View:GetComponent("UIScrollView")
      local uiPanel = Scroll_View:GetComponent("UIPanel")
      local offset = uiPanel:get_clipOffset()
      offset.y = offset.y - 110
      local pos = Scroll_View.transform.localPosition
      pos.y = -offset.y
      Scroll_View.transform.localPosition = pos
      uiPanel:set_clipOffset(offset)
      warn("-------offset:", offset.x, offset.y)
    end)
  end
  self:_SetSelectedList(index)
end
def.method("userdata", "number").setLineUpStatus = function(self, cellUI, idx)
  local partnerID = self._partnerMain._panelLineup:getSelectedLineupPartnerId()
  local Img_Grey = cellUI:FindDirect("Img_Grey_01")
  if Img_Grey.activeSelf then
    local partnerInfo = self._partnerMain._partnerList[idx]
    local label = Img_Grey:FindDirect("Label"):GetComponent("UILabel")
    local joined = partnerInterface:IsPartnerInLineup(partnerInfo.id, self._partnerMain._editZhenfaIndex - 1)
    local invited = partnerInterface:HasThePartner(partnerInfo.id)
    if partnerInfo.id == partnerID then
      label:set_text(textRes.Partner[54])
    elseif joined then
      label:set_text(textRes.Partner[53])
    elseif invited then
      label:set_text(textRes.Partner[55])
    else
      label:set_text("")
    end
  end
end
def.method("boolean", "number").changeLineUpStatus = function(self, isShow, partnerID)
  if self.scrollListCells == nil then
    return
  end
  for i, cellUI in pairs(self.scrollListCells) do
    local Img_Grey = cellUI:FindDirect("Img_Grey_01")
    Img_Grey:SetActive(isShow)
    local item, idx = ScrollList_getItem(cellUI)
    self:setLineUpStatus(cellUI, idx)
  end
end
def.method("number", "=>", "userdata").getScrollListCell = function(self, index)
  if self.scrollListCells then
    for _, v in pairs(self.scrollListCells) do
      local item, idx = ScrollList_getItem(v)
      if idx == index then
        return v
      end
    end
  end
  return nil
end
def.method("number")._PartnerJoinBattle = function(self, index)
  local cfg = self._partnerMain._partnerList[index]
  local editZhenfaIndex = self._partnerMain._editZhenfaIndex
  local lineUp = partnerInterface:GetLineup(editZhenfaIndex - 1)
  local full = true
  for idx = 1, 4 do
    local partnerID = lineUp.positions[idx]
    if partnerID == 0 then
      full = false
    end
  end
  if full == true then
    local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
    local Scroll_View = panel:FindDirect("Group_List/Scroll_View")
    local Grid_List = Scroll_View:FindDirect("Grid_List")
    local cellUI = self:getScrollListCell(index)
    local img_toggle = cellUI:FindDirect("Group_Have/Img_Toggle_01")
    img_toggle:GetComponent("UIToggle").value = false
    Toast(textRes.Partner[21])
    return
  end
  local editZhenfaIndex = self._partnerMain._editZhenfaIndex
  local CAddLineUpPartnerReq = require("netio.protocol.mzm.gsp.partner.CAddLineUpPartnerReq").new(editZhenfaIndex - 1, cfg.id)
  gmodule.network.sendProtocol(CAddLineUpPartnerReq)
end
def.method("number")._PartnerLeaveBattle = function(self, index)
  local cfg = self._partnerMain._partnerList[index]
  local editZhenfaIndex = self._partnerMain._editZhenfaIndex
  local CRemoveLineUpPartnerReq = require("netio.protocol.mzm.gsp.partner.CRemoveLineUpPartnerReq").new(editZhenfaIndex - 1, cfg.id)
  gmodule.network.sendProtocol(CRemoveLineUpPartnerReq)
end
PartnerMain_ListGrid.Commit()
return PartnerMain_ListGrid
