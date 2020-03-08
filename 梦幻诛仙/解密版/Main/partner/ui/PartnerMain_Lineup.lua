local Lplus = require("Lplus")
local ECGUIMan = require("GUI.ECGUIMan")
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local PartnerMain = Lplus.ForwardDeclare("PartnerMain")
local PartnerMain_Lineup = Lplus.Class("PartnerMain_Lineup")
local def = PartnerMain_Lineup.define
local inst
local ECModel = require("Model.ECModel")
local UIModelWrap = require("Model.UIModelWrap")
local LV1Property = require("consts.mzm.gsp.partner.confbean.LV1Property")
local LV2Property = require("consts.mzm.gsp.partner.confbean.LV2Property")
local PartnerFaction = require("consts.mzm.gsp.partner.confbean.PartnerFaction")
local PartnerSex = require("consts.mzm.gsp.partner.confbean.PartnerSex")
local PartnerType = require("consts.mzm.gsp.partner.confbean.PartnerType")
local UnlockItem = require("consts.mzm.gsp.partner.confbean.UnlockItem")
local ItemUtils = require("Main.Item.ItemUtils")
local ECUIModel = require("Model.ECUIModel")
local PubroleInterface = require("Main.Pubrole.PubroleInterface")
local PartnerInterface = require("Main.partner.PartnerInterface")
local partnerInterface = PartnerInterface.Instance()
local PersonalHelper = require("Main.Chat.PersonalHelper")
def.field(PartnerMain)._partnerMain = nil
def.static(PartnerMain, "=>", PartnerMain_Lineup).New = function(panel)
  if inst == nil then
    inst = PartnerMain_Lineup()
    inst._partnerMain = panel
    inst:Init()
  end
  return inst
end
def.static("=>", PartnerMain_Lineup).Instance = function()
  return inst
end
def.field("number")._SelectLineupPosition = 0
def.field("table")._modleTable = nil
def.field("boolean")._isShow = false
def.method().Init = function(self)
  self._modleTable = {}
end
def.method().OnCreate = function(self)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Group_Right = panel:FindDirect("Group_Right")
  local Table = Group_Right:FindDirect("Table")
  local Img_BgOpen = Table:FindDirect("Img_BgOpen1")
  local Tab_1 = Img_BgOpen:FindDirect("Tab_1")
  local Tab_2 = Img_BgOpen:FindDirect("Tab_2")
  local Tab_3 = Img_BgOpen:FindDirect("Tab_3")
  Tab_1:set_name("Tab_Zhen_1")
  Tab_2:set_name("Tab_Zhen_2")
  Tab_3:set_name("Tab_Zhen_3")
  self._modleTable = {}
  local Img_BgOpen = Table:FindDirect("Img_BgOpen1")
  local Img_BgPreview = Img_BgOpen:FindDirect("Img_BgPreview")
  for j = 1, 5 do
    local Img_Member = Img_BgPreview:FindDirect(string.format("Img_Member_%d", j))
    local Model = Img_Member:FindDirect(string.format("Model_%d", j))
    local uiModel = Model:GetComponent("UIModel")
    uiModel.mCanOverflow = true
    if j == 1 then
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      local modelID = PubroleInterface.FindModelIDByOccupationId(heroProp.occupation, heroProp.gender)
      self._modleTable[j] = ECUIModel.new(modelID)
    else
      self._modleTable[j] = UIModelWrap.new(uiModel)
    end
  end
  local Btn_Zhenfa = Img_BgOpen:FindDirect("Img_BgPreview/Label_Tips/Btn_Zhenfa")
  Btn_Zhenfa:set_name("Btn_Zhenfa_MakeEnable")
  for j = 1, 5 do
    local Img_Member = Img_BgPreview:FindDirect(string.format("Img_Member_%d", j))
    local Img_Grey = Img_Member:FindDirect("Img_Grey")
    Img_Grey:SetActive(false)
  end
  local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
  local index = defaultLineUpNum + 1
  self:_SetCurrEditLineup(index)
end
def.method().OnDestroy = function(self)
  self:DestroyZhenModel()
  self._isShow = false
end
def.method().DestroyZhenModel = function(self)
  if self._partnerMain.m_panel then
    local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
    local Table = panel:FindDirect("Group_Right/Table")
    local Img_BgOpen = Table:FindDirect("Img_BgOpen1")
    local Img_BgPreview = Img_BgOpen:FindDirect("Img_BgPreview")
    for k, v in pairs(self._modleTable) do
      local Img_Member = Img_BgPreview:FindDirect(string.format("Img_Member_%d", k))
      local Label_MemberNum = Img_Member:FindDirect("Label_MemberNum")
      local Model = Img_Member:FindDirect(string.format("Model_%d", k))
      local uiModel = Model:GetComponent("UIModel")
      uiModel.modelGameObject = nil
      v:Destroy()
    end
  end
end
def.method("=>", "boolean").IsShow = function(self)
  if self._partnerMain == nil or self._partnerMain.m_panel == nil or self._partnerMain.m_panel.isnil or self._partnerMain:IsShow() == false then
    return false
  end
  local Table = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Table")
  local ret = Table:get_activeInHierarchy() == true
  return ret
end
def.method("boolean").OnShow = function(self, s)
  if self._isShow == s then
    return
  end
  self._isShow = s
  if s == true then
    self:_FillLineup()
    self:_ClearSwapLineupPosition()
    Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupChanged, PartnerMain_Lineup.OnPartnerLineupChanged)
    Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupCurrChanged, PartnerMain_Lineup.OnPartnerLineupCurrChanged)
    Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupZhenfaChanged, PartnerMain_Lineup.OnPartnerLineupZhenfaChanged)
    Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LovesDataChanged, PartnerMain_Lineup.OnPartnerLovesDataChanged)
    Event.RegisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_PropertyChanged, PartnerMain_Lineup.OnPartnerPropertyChanged)
  else
    self:DestroyZhenModel()
    Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupChanged, PartnerMain_Lineup.OnPartnerLineupChanged)
    Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupCurrChanged, PartnerMain_Lineup.OnPartnerLineupCurrChanged)
    Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LineupZhenfaChanged, PartnerMain_Lineup.OnPartnerLineupZhenfaChanged)
    Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_LovesDataChanged, PartnerMain_Lineup.OnPartnerLovesDataChanged)
    Event.UnregisterEvent(ModuleId.PARTNER, gmodule.notifyId.partner.Partner_PropertyChanged, PartnerMain_Lineup.OnPartnerPropertyChanged)
  end
end
def.static("table", "table").OnPartnerLineupChanged = function(p1, p2)
  local self = inst
  self:_FillModel()
  self:_SetCurrLineupCheckBox()
  self:_ClearSwapLineupPosition()
end
def.static("table", "table").OnPartnerLineupCurrChanged = function(p1, p2)
  local self = inst
  self:_SetCurrLineupCheckBox()
end
def.static("table", "table").OnPartnerLineupZhenfaChanged = function(p1, p2)
  local self = inst
  self:_FillZhenFa()
  local Table = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Table")
  local lineupNum = 0
  for i = 1, 2 do
    local Img_BgOpen = Table:FindDirect(string.format("Img_BgOpen%d", i))
    if Img_BgOpen ~= nil and Img_BgOpen:get_activeSelf() == true then
      lineupNum = i
    end
  end
  if lineupNum == 0 then
    return
  end
  local Img_BgOpen = Table:FindDirect(string.format("Img_BgOpen%d", lineupNum))
  self:_FillZhenListBuff(lineupNum, Img_BgOpen)
end
def.static("table", "table").OnPartnerLovesDataChanged = function(p1, p2)
  local self = inst
  local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
  self:_FillSelectedLoveProp(cfg)
end
def.static("table", "table").OnPartnerPropertyChanged = function(p1, p2)
  local self = inst
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Group_Info = panel:FindDirect("Group_Right/Group_Info")
  local activeSelf = Group_Info:get_activeSelf()
  if activeSelf == true then
    local cfg = self._partnerMain._partnerList[self._partnerMain._selectedIndex]
    local invited = partnerInterface:HasThePartner(cfg.id)
    self:_FillSelectedProp(self._partnerMain._selectedIndex, cfg)
    self:_FillSelectedAttrib(cfg, invited)
    self:_FillSelectedSkill(cfg, invited)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:HideDlg()
    return
  end
  local fnTable = {}
  fnTable.Btn_Zhenfa = PartnerMain_Lineup.OnBtn_Zhenfa
  fnTable.Btn_Zhenfa_MakeEnable = PartnerMain_Lineup.OnBtn_Zhenfa_MakeEnable
  local fn = fnTable[id]
  if fn ~= nil then
    fn(self)
  end
  local strs = string.split(id, "_")
  if strs[1] == "Model" then
    local index = tonumber(strs[2])
    if index ~= nil then
      self:_SwapLineupPosition(index)
    end
  elseif strs[1] == "Img" and strs[2] == "Member" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:_SwapLineupPosition(index)
    end
  elseif strs[1] == "Tab" and strs[2] == "Zhen" then
    local index = tonumber(strs[3])
    if index ~= nil then
      self:_ClearSwapLineupPosition()
      self:_SetCurrEditLineup(index)
      self:_FillLineup()
      self._partnerMain:FillListGrid()
    end
  elseif strs[1] == "Img" and strs[2] == "Minus" then
    local index = tonumber(strs[3])
    self:_Unbattle(index)
  end
end
def.method().OnGroupZhen = function(self)
  local index = self._partnerMain._selectedIndex
  local cfg = self._partnerMain._partnerList[index]
  local invited = partnerInterface:HasThePartner(cfg.id)
  if invited ~= true then
    return
  end
  local Group_Right = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right")
  local Group_Info = Group_Right:FindDirect("Group_Info")
  local Table = Group_Right:FindDirect("Table")
  Group_Info:SetActive(false)
  self._UIModelWrap:Destroy()
  Table:SetActive(true)
  self:_FillZhenList()
  self:_SetCurrLineupCheckBox()
end
def.method().OnBtn_Zhenfa = function(self)
  local LineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
  local FormationModule = gmodule.moduleMgr:GetModule(ModuleId.FORMATION)
  FormationModule:ShowFormationDlg(LineUp.zhenFaId, LineUp.zhenFaId, PartnerMain_Lineup.OnZhenfaSelectedCallback)
end
def.static("number").OnZhenfaSelectedCallback = function(id)
  local self = inst
  local CChangeZhenFaReq = require("netio.protocol.mzm.gsp.partner.CChangeZhenFaReq").new(self._partnerMain._editZhenfaIndex - 1, id)
  gmodule.network.sendProtocol(CChangeZhenFaReq)
end
def.method()._FillZhenFa = function(self)
  local lineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
  local zhenfaName = textRes.Partner[8]
  if lineUp.zhenFaId > 0 then
    local FormationUtils = require("Main.Formation.FormationUtils")
    local formationModule = gmodule.moduleMgr:GetModule(ModuleId.FORMATION)
    local formationLevel = formationModule:GetFormationLevel(lineUp.zhenFaId)
    local zhenfaCfg = FormationUtils.GetFormationCfg(lineUp.zhenFaId)
    zhenfaName = string.format(textRes.Partner[2], formationLevel) .. zhenfaCfg.name
  end
  local Group_Right = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right")
  local Table = Group_Right:FindDirect("Table")
  local Btn_Zhenfa = Table:FindDirect("Img_BgOpen1/Btn_Zhenfa")
  local Label = Btn_Zhenfa:FindDirect("Label")
  Label:GetComponent("UILabel"):set_text(zhenfaName)
end
def.method()._FillZhenYuan = function(self)
  local lineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Table = panel:FindDirect("Group_Right/Table")
  local Img_BgOpen = Table:FindDirect("Img_BgOpen1")
  local memberHasLoves = {}
  for k, partnerID in pairs(lineUp.positions) do
    if partnerInterface:IsPartnerJoinedBattle(partnerID) == true then
      local LoveInfo = partnerInterface:GetPartnerLoveInfos(partnerID)
      if LoveInfo ~= nil then
        for k, loveID in pairs(LoveInfo) do
          local LoveDataCfg = PartnerInterface.GetPartnerLoveDataCfg(loveID)
          if LoveDataCfg ~= nil then
            if LoveDataCfg.toPartner1 ~= partnerID and partnerInterface:IsPartnerJoinedBattle(LoveDataCfg.toPartner1) == true then
              memberHasLoves[partnerID] = true
              memberHasLoves[LoveDataCfg.toPartner1] = true
            end
            if LoveDataCfg.toPartner2 ~= partnerID and partnerInterface:IsPartnerJoinedBattle(LoveDataCfg.toPartner2) == true then
              memberHasLoves[partnerID] = true
              memberHasLoves[LoveDataCfg.toPartner2] = true
            end
            if LoveDataCfg.toPartner3 ~= partnerID and partnerInterface:IsPartnerJoinedBattle(LoveDataCfg.toPartner3) == true then
              memberHasLoves[partnerID] = true
              memberHasLoves[LoveDataCfg.toPartner3] = true
            end
          end
        end
      end
    end
  end
  local Img_BgPreview = Img_BgOpen:FindDirect("Img_BgPreview")
  for idx = 0, 4 do
    local partnerID = lineUp.positions[idx]
    local Img_BgIcon = Img_BgPreview:FindDirect(string.format("Img_Member_%d", idx + 1))
    local Img_Yuan = Img_BgIcon:FindDirect("Img_Yuan")
    local Img_Minus = Img_BgIcon:FindDirect(string.format("Img_Minus_%d", idx + 1))
    if partnerID ~= nil and partnerID > 0 then
      local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, partnerID)
      local modelId = record:GetIntValue("modelId")
      local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
      local icon = DynamicRecord.GetIntValue(modelinfo, "headerIconId")
      if icon == 0 then
        icon = 3002
      end
      Img_Yuan:SetActive(memberHasLoves[partnerID] == true)
      Img_Minus:SetActive(true)
    else
      Img_Yuan:SetActive(false)
      Img_Minus:SetActive(false)
    end
  end
end
def.method("number")._SetCurrEditLineup = function(self, index)
  self._partnerMain._editZhenfaIndex = index
  local Table = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Table")
  local Img_BgOpen = Table:FindDirect("Img_BgOpen1")
  local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
  for i = 1, 3 do
    local active = index == i
    local Tab_Zhen = Img_BgOpen:FindDirect(string.format("Tab_Zhen_%d", i))
    local Img_Select = Tab_Zhen:FindDirect("Img_Select")
    Img_Select:SetActive(active)
  end
end
def.method().OnBtn_Zhenfa_MakeEnable = function(self)
  self:_SetCurrLineup(self._partnerMain._editZhenfaIndex)
end
def.method("number")._SetCurrLineup = function(self, index)
  index = index - 1
  local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
  if index == defaultLineUpNum then
    return
  end
  local CChangeDefaultLinupReq = require("netio.protocol.mzm.gsp.partner.CChangeDefaultLinupReq").new(index)
  gmodule.network.sendProtocol(CChangeDefaultLinupReq)
end
def.method()._SetCurrLineupCheckBox = function(self)
  local Table = self._partnerMain.m_panel:FindDirect("Img_Bg0/Group_Right/Table")
  local Img_BgOpen = Table:FindDirect("Img_BgOpen1")
  local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
  for i = 1, 3 do
    local active = defaultLineUpNum + 1 == i
    local Tab_Zhen = Img_BgOpen:FindDirect(string.format("Tab_Zhen_%d", i))
    local Img_Choose = Tab_Zhen:FindDirect("Img_Choose")
    Img_Choose:SetActive(active)
  end
  local Btn_Zhenfa_MakeEnable = Img_BgOpen:FindDirect("Img_BgPreview/Label_Tips/Btn_Zhenfa_MakeEnable")
  Btn_Zhenfa_MakeEnable:SetActive(defaultLineUpNum + 1 ~= self._partnerMain._editZhenfaIndex)
end
def.method("number", "userdata", "userdata")._FillZhenListItemMember = function(self, index, Group_Shut_Zhen, Img_BgOpen)
  local lineUp = partnerInterface:GetLineup(index - 1)
  local memberHasLoves = {}
  for k, partnerID in pairs(lineUp.positions) do
    if partnerInterface:IsPartnerInLineup(partnerID, index - 1) == true then
      local LoveInfo = partnerInterface:GetPartnerLoveInfos(partnerID)
      if LoveInfo ~= nil then
        for k, loveID in pairs(LoveInfo) do
          local LoveDataCfg = PartnerInterface.GetPartnerLoveDataCfg(loveID)
          if LoveDataCfg ~= nil then
            if LoveDataCfg.toPartner1 ~= partnerID and partnerInterface:IsPartnerInLineup(LoveDataCfg.toPartner1, index - 1) == true then
              memberHasLoves[partnerID] = true
              memberHasLoves[LoveDataCfg.toPartner1] = true
            end
            if LoveDataCfg.toPartner2 ~= partnerID and partnerInterface:IsPartnerInLineup(LoveDataCfg.toPartner2, index - 1) == true then
              memberHasLoves[partnerID] = true
              memberHasLoves[LoveDataCfg.toPartner2] = true
            end
            if LoveDataCfg.toPartner3 ~= partnerID and partnerInterface:IsPartnerInLineup(LoveDataCfg.toPartner3, index - 1) == true then
              memberHasLoves[partnerID] = true
              memberHasLoves[LoveDataCfg.toPartner2] = true
            end
          end
        end
      end
    end
  end
  for i = 1, 4 do
    local partnerID = lineUp.positions[i]
    local Img_BgIcon = Group_Shut_Zhen:FindDirect(string.format("Img_BgIcon%d", i))
    local Tex_Icon = Img_BgIcon:FindDirect("Tex_Icon")
    local Img_YuanSign = Img_BgIcon:FindDirect("Img_YuanSign")
    if partnerID ~= nil and partnerID > 0 then
      local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, partnerID)
      local modelId = record:GetIntValue("modelId")
      local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
      local icon = DynamicRecord.GetIntValue(modelinfo, "headerIconId")
      if icon == 0 then
        icon = 3002
      end
      Tex_Icon:SetActive(true)
      local uiTexture = Tex_Icon:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, icon)
      Img_YuanSign:SetActive(memberHasLoves[partnerID] == true)
    else
      Tex_Icon:SetActive(false)
      Img_YuanSign:SetActive(false)
    end
  end
  for i = 1, 4 do
    local partnerID = lineUp.positions[i]
    local Group_Zhen = Img_BgOpen:FindDirect(string.format("Group_Zhen%d", index))
    local Img_BgIcon = Group_Zhen:FindDirect(string.format("Img_BgIcon%d", i))
    local Tex_Icon = Img_BgIcon:FindDirect("Tex_Icon")
    local Img_YuanSign = Img_BgIcon:FindDirect("Img_YuanSign")
    if partnerID ~= nil and partnerID > 0 then
      local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, partnerID)
      local modelId = record:GetIntValue("modelId")
      local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
      local icon = DynamicRecord.GetIntValue(modelinfo, "headerIconId")
      if icon == 0 then
        icon = 3002
      end
      Tex_Icon:SetActive(true)
      local uiTexture = Tex_Icon:GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, icon)
      Img_YuanSign:SetActive(memberHasLoves[partnerID] == true)
    else
      Tex_Icon:SetActive(false)
      Img_YuanSign:SetActive(false)
    end
  end
end
def.method()._FillModel = function(self)
  local lineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Table = panel:FindDirect("Group_Right/Table")
  local Img_BgOpen = Table:FindDirect("Img_BgOpen1")
  local Img_BgPreview = Img_BgOpen:FindDirect("Img_BgPreview")
  Img_BgOpen:SetActive(true)
  for i = 0, 4 do
    do
      local j = i + 1
      local partnerID = lineUp.positions[i]
      local Img_Member = Img_BgPreview:FindDirect(string.format("Img_Member_%d", j))
      local Label_MemberNum = Img_Member:FindDirect("Label_MemberNum")
      local Model = Img_Member:FindDirect(string.format("Model_%d", j))
      local uiModel = Model:GetComponent("UIModel")
      Label_MemberNum:GetComponent("UILabel"):set_text(tostring(j))
      if partnerID ~= nil and partnerID > 0 or i == 0 then
        local resourcePath = ""
        if i == 0 then
          do
            local heroProp = require("Main.Hero.Interface").GetHeroProp()
            local modelID = PubroleInterface.FindModelIDByOccupationId(heroProp.occupation, heroProp.gender)
            local myModel = self._modleTable[j]
            if myModel then
              myModel:Destroy()
            end
            myModel = ECUIModel.new(modelID)
            myModel.m_bUncache = true
            local modelInfo = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE):GetRoleModelInfo(gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId)
            myModel:AddOnLoadCallback("lineUp_panel", function()
              if self._partnerMain.m_panel == nil or self._partnerMain.m_panel.isnil then
                myModel:Destroy()
                myModel = nil
                return
              end
              if myModel == nil or myModel.m_model == nil or myModel.m_model.isnil then
                return
              end
              uiModel.modelGameObject = myModel.m_model
              if uiModel.mCanOverflow ~= nil then
                uiModel.mCanOverflow = true
                local camera = uiModel:get_modelCamera()
                if camera then
                  camera:set_orthographic(true)
                end
              end
            end)
            _G.LoadModel(myModel, modelInfo, 0, 0, 180, false, false)
            self._modleTable[j] = myModel
          end
        else
          local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, partnerID)
          local modelId = record:GetIntValue("modelId")
          local faction = record:GetIntValue("faction")
          local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, modelId)
          resourcePath = DynamicRecord.GetStringValue(modelinfo, "modelResPath")
          if resourcePath == "" or resourcePath == nil then
            warn(" resourcePath == \"\" modelId = " .. modelId)
          end
          local wrap = self._modleTable[j]
          wrap._defaultDir = 180
          if resourcePath and resourcePath ~= "" then
            wrap:Load(resourcePath .. ".u3dext")
          else
            warn("[PartnerMain_Lineup]resourcePath is nil or empty")
          end
        end
      else
        local wrap = self._modleTable[j]
        wrap:Destroy()
      end
    end
  end
  self:_FillBuff(Img_BgOpen)
  self:_FillZhenYuan()
end
def.method("userdata")._FillBuff = function(self, Img_BgOpen)
  local lineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
  local BuffArea = Img_BgOpen:FindDirect("BuffArea")
  local formationModule = gmodule.moduleMgr:GetModule(ModuleId.FORMATION)
  local formationInfo = formationModule:GetFormationInfo(lineUp.zhenFaId)
  for i = 0, 4 do
    local j = i + 1
    local partnerID = lineUp.positions[i]
    local Img_BgMember = BuffArea:FindDirect(string.format("Img_BgMember%02d", j))
    local Img_Num = Img_BgMember:FindDirect("Img_Num")
    Img_Num:GetComponent("UILabel"):set_text(tostring(j))
    local Label_Name = Img_BgMember:FindDirect("Label_Name")
    local Label_Buff1 = Img_BgMember:FindDirect("Label_Buff1")
    local Label_Buff2 = Img_BgMember:FindDirect("Label_Buff2")
    local Img_Arrow1 = Img_BgMember:FindDirect("Img_Arrow1")
    local Img_Arrow2 = Img_BgMember:FindDirect("Img_Arrow2")
    if partnerID ~= nil and partnerID > 0 or i == 0 then
      if i == 0 then
        local heroProp = require("Main.Hero.Interface").GetHeroProp()
        Label_Name:GetComponent("UILabel"):set_text(heroProp.name)
      else
        local record = DynamicData.GetRecord(CFG_PATH.DATA_PARTNER_PARTNER_CFG, partnerID)
        local name = record:GetStringValue("name")
        Label_Name:GetComponent("UILabel"):set_text(name)
      end
      Label_Name:SetActive(true)
      Label_Buff1:SetActive(false)
      Label_Buff2:SetActive(false)
      Img_Arrow1:SetActive(false)
      Img_Arrow2:SetActive(false)
      if formationInfo ~= nil then
        local eff = formationInfo.Effect[j]
        if eff.EffectA ~= nil then
          Label_Buff1:SetActive(true)
          Label_Buff1:GetComponent("UILabel"):set_text(eff.EffectA.str)
          Img_Arrow1:SetActive(true)
          if 0 <= eff.EffectA.value then
            Img_Arrow1:GetComponent("UISprite"):set_spriteName("Img_Up")
          else
            Img_Arrow1:GetComponent("UISprite"):set_spriteName("Img_Down")
          end
        end
        if eff.EffectB ~= nil then
          Label_Buff2:SetActive(true)
          Label_Buff2:GetComponent("UILabel"):set_text(eff.EffectB.str)
          Img_Arrow2:SetActive(true)
          if 0 <= eff.EffectB.value then
            Img_Arrow2:GetComponent("UISprite"):set_spriteName("Img_Up")
          else
            Img_Arrow2:GetComponent("UISprite"):set_spriteName("Img_Down")
          end
        end
      end
    else
      Label_Name:SetActive(false)
      Label_Buff1:SetActive(false)
      Label_Buff2:SetActive(false)
      Img_Arrow1:SetActive(false)
      Img_Arrow2:SetActive(false)
    end
  end
end
def.method()._ClearSwapLineupPosition = function(self)
  self._SelectLineupPosition = 0
  self:SetSelectLightRound()
  self._partnerMain._panelListGrid:changeLineUpStatus(false, 0)
end
def.method("number")._SwapLineupPosition = function(self, index)
  if index == 1 then
    Toast(textRes.Partner[20])
    return
  end
  if index == self._SelectLineupPosition then
    self:_ClearSwapLineupPosition()
    return
  end
  local lineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
  if lineUp.positions[index - 1] == 0 or lineUp.positions[index - 1] == nil then
    self:_ClearSwapLineupPosition()
    return
  end
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Table = panel:FindDirect("Group_Right/Table")
  if self._SelectLineupPosition ~= 0 then
    local CChangeZhanWeiReq = require("netio.protocol.mzm.gsp.partner.CChangeZhanWeiReq").new(self._partnerMain._editZhenfaIndex - 1, self._SelectLineupPosition - 1, index - 1)
    gmodule.network.sendProtocol(CChangeZhanWeiReq)
    self:_ClearSwapLineupPosition()
    return
  end
  self._SelectLineupPosition = index
  self:SetSelectLightRound()
  self._partnerMain._panelListGrid:changeLineUpStatus(true, lineUp.positions[index - 1])
end
def.method().SetSelectLightRound = function(self)
  local panel = self._partnerMain.m_panel:FindDirect("Img_Bg0")
  local Table = panel:FindDirect("Group_Right/Table")
  local Img_BgOpen = Table:FindDirect("Img_BgOpen1")
  local Img_BgPreview = Img_BgOpen:FindDirect("Img_BgPreview")
  local lineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
  for j = 2, 5 do
    local Img_Member = Img_BgPreview:FindDirect(string.format("Img_Member_%d", j))
    local pos = j - 1
    local spos = pos + 1
    local bright = lineUp ~= nil and lineUp.positions[pos] ~= nil and lineUp.positions[pos] ~= 0 and self._SelectLineupPosition ~= 0 and self._SelectLineupPosition ~= spos
    local Img_Grey = Img_Member:FindDirect("Img_Grey")
    Img_Grey:SetActive(bright)
  end
end
def.method()._FillLineup = function(self)
  self:_SetCurrLineupCheckBox()
  self:_FillModel()
  self:_FillZhenFa()
end
def.method().FillLineup = function(self)
  local defaultLineUpNum = partnerInterface:GetDefaultLineUpNum()
  local index = defaultLineUpNum + 1
  self:_SetCurrEditLineup(index)
  self:_FillLineup()
end
def.method("number")._Unbattle = function(self, index)
  local lineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
  local partnerID = lineUp.positions[index - 1]
  if partnerID and partnerID ~= 0 then
    local editZhenfaIndex = self._partnerMain._editZhenfaIndex
    local CRemoveLineUpPartnerReq = require("netio.protocol.mzm.gsp.partner.CRemoveLineUpPartnerReq").new(editZhenfaIndex - 1, partnerID)
    gmodule.network.sendProtocol(CRemoveLineUpPartnerReq)
  end
end
def.method("=>", "number").getSelectedLineupPartnerId = function(self)
  if self._SelectLineupPosition ~= 0 then
    local lineUp = partnerInterface:GetLineup(self._partnerMain._editZhenfaIndex - 1)
    local partnerID = lineUp.positions[self._SelectLineupPosition - 1]
    return partnerID
  end
  return 0
end
PartnerMain_Lineup.Commit()
return PartnerMain_Lineup
