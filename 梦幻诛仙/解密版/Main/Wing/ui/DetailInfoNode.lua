local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local DetailInfoNode = Lplus.Extend(TabNode, "DetailInfoNode")
local ECPanelBase = require("GUI.ECPanelBase")
local WingModule = require("Main.Wing.WingModule")
local GUIUtils = require("GUI.GUIUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local WingUtils = require("Main.Wing.WingUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local WingModel = require("Main.Wing.ui.WingModel")
local WingOutlookType = require("consts.mzm.gsp.wing.confbean.WingOutlookType")
local def = DetailInfoNode.define
def.const("number").ONEPAGE = 3
def.field("table").wings = nil
def.field("number").curType = 1
def.field("number").currentPage = 1
def.field("table").models = nil
def.field("number").dragIndex = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self:InitUI()
end
def.override().OnShow = function(self)
  Event.RegisterEventWithContext(ModuleId.WING, gmodule.notifyId.Wing.WINGS_CHANGE, DetailInfoNode.OnWingChange, self)
  Event.RegisterEventWithContext(ModuleId.WING, gmodule.notifyId.Wing.WINGS_PHASE_CHANGE, DetailInfoNode.OnPhaseChange, self)
  Event.RegisterEventWithContext(ModuleId.WING, gmodule.notifyId.Wing.WINGS_DATA_CHANGE, DetailInfoNode.OnWingChange, self)
  Event.RegisterEventWithContext(ModuleId.IDIP, gmodule.notifyId.IDIP.ITEM_IDIP_INFO_CHANGE, DetailInfoNode.OnIDIPInfoChg, self)
  self:Reposition()
  self.models = {}
  for i = 1, DetailInfoNode.ONEPAGE do
    self.models[i] = WingModel()
  end
  self:SelectTypeAndPage(self.curType, self.currentPage, true)
  self:setCurOccName()
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_CHANGE, DetailInfoNode.OnWingChange)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_DATA_CHANGE, DetailInfoNode.OnWingChange)
  Event.UnregisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_PHASE_CHANGE, DetailInfoNode.OnPhaseChange)
  Event.UnregisterEvent(ModuleId.IDIP, gmodule.notifyId.IDIP.ITEM_IDIP_INFO_CHANGE, DetailInfoNode.OnIDIPInfoChg)
  if self.models then
    for k, v in ipairs(self.models) do
      v:Destroy()
    end
  end
end
def.method().setCurOccName = function(self)
  local Group_PlanWing = self.m_node:FindDirect("Group_PlanWing")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_WING_OCC_PLAN) then
    Group_PlanWing:SetActive(false)
    return
  end
  local wingData = WingModule.Instance():GetWingData()
  local Label_PlanName = self.m_node:FindDirect("Group_PlanWing/Label_PlanName")
  Label_PlanName:GetComponent("UILabel"):set_text(wingData:GetOccNameById(wingData:GetCurOccupationId()))
end
def.method("table").OnPhaseChange = function(self, params)
  self:SelectTypeAndPage(self.curType, self.currentPage, true)
end
def.method("table").OnWingChange = function(self, params)
  self:UpdateWing()
end
local ItemSwitchInfo = require("netio.protocol.mzm.gsp.idip.ItemSwitchInfo")
local IDIPInterface = require("Main.IDIP.IDIPInterface")
def.method("table", "=>", "table")._filteOpenedWings = function(self, wings)
  if wings == nil then
    return nil
  end
  local retData = {}
  for k, wingId in ipairs(wings) do
    local wingCfg = WingUtils.GetWingCfg(wingId)
    local wingOutlook = WingUtils.GetWingViewCfg(wingCfg.outlook)
    local bOpen = IDIPInterface.IsItemIDIPOpen(ItemSwitchInfo.WING, wingOutlook.id)
    local wingData = WingModule.Instance():GetWingData()
    local wingInfo = wingData:GetWingByWingId(wingId)
    if wingInfo ~= nil or bOpen then
      table.insert(retData, wingId)
    end
  end
  return retData
end
def.method("number", "number", "boolean").SelectTypeAndPage = function(self, type, page, forceUpdate)
  local wingData = WingModule.Instance():GetWingData()
  local typeChange = false
  local pageChange = false
  if forceUpdate then
    if type == WingOutlookType.TY_SJ then
      self.curType = type
      typeChange = true
      self.wings = WingUtils.GetAllPromoteWingWithRank(wingData:GetPhase())
    elseif type == WingOutlookType.TY_WG then
      self.curType = type
      typeChange = true
      local wings = WingUtils.GetAllOtherWing()
      self.wings = self:_filteOpenedWings(wings) or {}
      table.sort(self.wings, function(a, b)
        if wingData:GetWingByWingId(a) and wingData:GetWingByWingId(b) then
          return a < b
        elseif wingData:GetWingByWingId(a) then
          return true
        elseif wingData:GetWingByWingId(b) then
          return false
        else
          return a < b
        end
      end)
    end
  elseif type > 0 and type ~= self.curType then
    if type == WingOutlookType.TY_SJ then
      self.curType = type
      typeChange = true
      self.wings = WingUtils.GetAllPromoteWingWithRank(wingData:GetPhase())
    elseif type == WingOutlookType.TY_WG then
      self.curType = type
      typeChange = true
      local wings = WingUtils.GetAllOtherWing()
      self.wings = self:_filteOpenedWings(wings) or {}
      table.sort(self.wings, function(a, b)
        if wingData:GetWingByWingId(a) and wingData:GetWingByWingId(b) then
          return a < b
        elseif wingData:GetWingByWingId(a) then
          return true
        elseif wingData:GetWingByWingId(b) then
          return false
        else
          return a < b
        end
      end)
    end
  end
  local pageCount = math.ceil(#self.wings / DetailInfoNode.ONEPAGE)
  page = math.min(math.max(1, page), pageCount)
  if self.currentPage ~= page then
    self.currentPage = page
    pageChange = true
  end
  if typeChange then
    self:UpdateTab()
  end
  if typeChange or pageChange then
    self:UpdateArrowAndPoint()
    self:UpdateWing()
  end
end
def.method().InitUI = function(self)
  local list = self.m_node:FindDirect("Scroll View/List")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(DetailInfoNode.ONEPAGE)
  listCmp:Resize()
end
def.method().Reposition = function(self)
  local list = self.m_node:FindDirect("Scroll View/List")
  local listCmp = list:GetComponent("UIList")
  listCmp:Reposition()
end
def.method().UpdateTab = function(self)
  if self.curType == WingOutlookType.TY_SJ then
    local normal = self.m_node:FindDirect("Btn_Normal")
    normal:GetComponent("UIToggle"):set_value(true)
  elseif self.curType == WingOutlookType.TY_WG then
    local special = self.m_node:FindDirect("Btn_Special")
    special:GetComponent("UIToggle"):set_value(true)
  end
end
def.method().UpdateArrowAndPoint = function(self)
  local pageCount = math.ceil(#self.wings / DetailInfoNode.ONEPAGE)
  local pointList = self.m_node:FindDirect("List_Point")
  local listCmp = pointList:GetComponent("UIList")
  listCmp:set_itemCount(pageCount)
  listCmp:Resize()
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    if i == self.currentPage then
      uiGo:GetComponent("UIToggle"):set_value(true)
    end
  end
  local leftArrow = self.m_node:FindDirect("Btn_Left")
  local rightArrow = self.m_node:FindDirect("Btn_Right")
  if 1 >= self.currentPage then
    leftArrow:SetActive(false)
  else
    leftArrow:SetActive(true)
  end
  if pageCount <= self.currentPage then
    rightArrow:SetActive(false)
  else
    rightArrow:SetActive(true)
  end
end
def.method().UpdateWing = function(self)
  local curWingData = {}
  local start = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + 1
  for i = start, start + DetailInfoNode.ONEPAGE - 1 do
    table.insert(curWingData, self.wings[i])
  end
  local list = self.m_node:FindDirect("Scroll View/List")
  for i = 1, DetailInfoNode.ONEPAGE do
    local wingUI = list:FindDirect("wing_" .. i)
    local wingId = curWingData[i] or 0
    if wingUI then
      self:FillWing(wingUI, wingId, i)
    end
  end
end
def.method("userdata", "number", "number").FillWing = function(self, wingUI, wingId, index)
  if wingId > 0 then
    wingUI:SetActive(true)
    local wingData = WingModule.Instance():GetWingData()
    local wingCfg = WingUtils.GetWingCfg(wingId)
    local wingOutlook = WingUtils.GetWingViewCfg(wingCfg.outlook)
    local wingItem = ItemUtils.GetItemBase(wingOutlook.fakeItemId)
    local wingInfo = wingData:GetWingByWingId(wingId)
    local bOpen = IDIPInterface.IsItemIDIPOpen(ItemSwitchInfo.WING, wingOutlook.id)
    local childCount = wingUI.childCount
    if wingInfo == nil and not bOpen then
      for i = 0, childCount - 1 do
        wingUI:GetChild(i):SetActive(false)
      end
      local obtainDesc = wingUI:FindDirect(string.format("Label_Get_%d", index))
      obtainDesc:SetActive(true)
      GUIUtils.SetText(obtainDesc, textRes.Wing[51])
      return
    end
    for i = 0, childCount - 1 do
      wingUI:GetChild(i):SetActive(true)
    end
    local m = self.models[index]
    local uiModel = wingUI:FindDirect(string.format("Model_Wing_%d", index))
    self:FillWingModel(uiModel, m, wingCfg.outlook, wingInfo and wingInfo.colorId or 0)
    local nameLabel = wingUI:FindDirect(string.format("Label_WingName_%d", index))
    nameLabel:GetComponent("UILabel"):set_text(wingItem.name)
    local obtainDesc = wingUI:FindDirect(string.format("Label_Get_%d", index))
    obtainDesc:GetComponent("UILabel"):set_text(wingCfg.gainDes)
    local colorBtn = wingUI:FindDirect(string.format("Btn_Color_%d", index))
    colorBtn:SetActive(wingInfo ~= nil)
    local dressBtn = wingUI:FindDirect(string.format("Btn_Dress_%d", index))
    local undressBtn = wingUI:FindDirect(string.format("Btn_Undress_%d", index))
    local dressedBtn = wingUI:FindDirect(string.format("Img_Dressed_%d", index))
    local tryBtn = wingUI:FindDirect(string.format("Btn_Try_%d", index))
    local previewBtn = wingUI:FindDirect(string.format("Group_Btn_%d", index))
    if wingInfo then
      if wingData:GetCurWingId() == wingId then
        dressBtn:SetActive(false)
        undressBtn:SetActive(true)
        dressedBtn:SetActive(true)
        tryBtn:SetActive(false)
      else
        dressBtn:SetActive(true)
        undressBtn:SetActive(false)
        dressedBtn:SetActive(false)
        tryBtn:SetActive(false)
      end
      previewBtn:SetActive(false)
    else
      dressBtn:SetActive(false)
      undressBtn:SetActive(false)
      dressedBtn:SetActive(false)
      tryBtn:SetActive(true)
      previewBtn:SetActive(true)
      local propPreview = previewBtn:FindDirect(string.format("Img_AttPre_%d", index))
      local skillPreview = previewBtn:FindDirect(string.format("Img_SkillPre_%d", index))
      if 0 < wingCfg.initProId then
        propPreview:SetActive(true)
      else
        propPreview:SetActive(false)
      end
      if 0 < wingCfg.initSkillLib then
        skillPreview:SetActive(true)
      else
        skillPreview:SetActive(false)
      end
    end
    local gray = wingUI:FindDirect(string.format("Gray_%d", index))
    gray:SetActive(wingInfo == nil)
    local lockLabel = wingUI:FindDirect(string.format("Label_Lock_%d", index))
    local unlockGroup = wingUI:FindDirect(string.format("Group_Unlocked_%d", index))
    if wingInfo then
      unlockGroup:SetActive(true)
      lockLabel:SetActive(false)
      local propLabel = unlockGroup:FindDirect(string.format("Label_Shuxing_%d", index))
      local skill1 = unlockGroup:FindDirect(string.format("Img_SkillBg1_%d", index))
      local skill2 = unlockGroup:FindDirect(string.format("Img_SkillBg2_%d", index))
      local props = wingInfo.props
      local skills = wingInfo.skills
      if props then
        local prefix = skills and "" or "        "
        propLabel:SetActive(true)
        local propStr = WingUtils.PropsToString(wingInfo.id, props, prefix)
        propLabel:GetComponent("UILabel"):set_text(propStr)
      else
        propLabel:SetActive(false)
      end
      if skills then
        local skillIcon
        if props then
          skill1:SetActive(false)
          skill2:SetActive(true)
          skillIcon = skill2
        else
          skill1:SetActive(true)
          skill2:SetActive(false)
          skillIcon = skill1
        end
        self:FillSkillIcon(skillIcon, skills[1], index)
      else
        skill1:SetActive(false)
        skill2:SetActive(false)
      end
      local reset0 = unlockGroup:FindDirect(string.format("Btn_Reset_%d", index))
      local reset1 = unlockGroup:FindDirect(string.format("Btn_ResetProperty_%d", index))
      local reset2 = unlockGroup:FindDirect(string.format("Btn_ResetSkill_%d", index))
      local resetType = WingUtils.GetResetType(wingCfg)
      if resetType == 3 then
        reset0:SetActive(false)
        reset1:SetActive(true)
        reset2:SetActive(true)
      elseif resetType == 2 then
        reset0:SetActive(true)
        reset1:SetActive(false)
        reset2:SetActive(false)
      elseif resetType == 1 then
        reset0:SetActive(true)
        reset1:SetActive(false)
        reset2:SetActive(false)
      elseif resetType == 0 then
        reset0:SetActive(false)
        reset1:SetActive(false)
        reset2:SetActive(false)
      end
    else
      unlockGroup:SetActive(false)
      lockLabel:SetActive(true)
      local unlockType = WingUtils.GetUnlockType(wingCfg)
      local text = textRes.Wing.UnlockDesc[unlockType]
      lockLabel:GetComponent("UILabel"):set_text(text)
    end
  else
    wingUI:SetActive(false)
  end
end
def.method("userdata", "table", "number", "number").FillWingModel = function(self, uiModel, model, outlookId, wingDyeId)
  if uiModel == nil or model == nil then
    return
  end
  local uiModelCmp = uiModel:GetComponent("UIModel")
  if outlookId > 0 then
    model:Create(outlookId, wingDyeId, function()
      if uiModelCmp.isnil then
        return
      end
      uiModelCmp.mCanOverflow = true
      local camera = uiModelCmp:get_modelCamera()
      camera:set_orthographic(true)
      uiModelCmp.modelGameObject = model:GetModelGameObject()
    end)
  else
    model:Destroy()
  end
end
def.method("userdata", "number", "number").FillSkillIcon = function(self, uiGo, skillId, index)
  local tex = uiGo:FindDirect(string.format("Texture_%d", index))
  local skillCfg = skillId > 0 and SkillUtility.GetSkillCfg(skillId) or nil
  if skillCfg then
    tex:SetActive(true)
    local texCmp = tex:GetComponent("UITexture")
    GUIUtils.FillIcon(texCmp, skillCfg.iconId)
  else
    tex:SetActive(false)
  end
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Normal" then
    self:SelectTypeAndPage(WingOutlookType.TY_SJ, 1, false)
  elseif id == "Btn_Tips" then
    WingUtils.ShowQA(constant.WingConsts.OUT_LOOK_TIP_ID)
  elseif id == "Btn_Special" then
    self:SelectTypeAndPage(WingOutlookType.TY_WG, 1, false)
  elseif id == "Btn_Right" then
    self:SelectTypeAndPage(self.curType, self.currentPage + 1, false)
  elseif id == "Btn_Left" then
    self:SelectTypeAndPage(self.curType, self.currentPage - 1, false)
  elseif string.sub(id, 1, 10) == "Btn_Reset_" then
    local index = tonumber(string.sub(id, 11))
    local wingIndex = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + index
    local wing = self.wings[wingIndex]
    if wing then
      local wingCfg = WingUtils.GetWingCfg(wing)
      local type = WingUtils.GetResetType(wingCfg)
      if type == 1 then
        WingModule.Instance():ShowResetAttr(wing, false)
      elseif type == 2 then
        WingModule.Instance():ShowResetSkill(wing, false)
      end
    end
  elseif string.sub(id, 1, 18) == "Btn_ResetProperty_" then
    local index = tonumber(string.sub(id, 19))
    local wingIndex = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + index
    local wing = self.wings[wingIndex]
    if wing then
      WingModule.Instance():ShowResetAttr(wing, false)
    end
  elseif string.sub(id, 1, 15) == "Btn_ResetSkill_" then
    local index = tonumber(string.sub(id, 16))
    local wingIndex = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + index
    local wing = self.wings[wingIndex]
    warn("Btn_ResetSkill_", wingIndex, wing)
    if wing then
      WingModule.Instance():ShowResetSkill(wing, false)
    end
  elseif string.sub(id, 1, 10) == "Btn_Color_" then
    local index = tonumber(string.sub(id, 11))
    local wingIndex = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + index
    local wing = self.wings[wingIndex]
    if wing then
      WingModule.Instance():ShowDyeWingPanel(wing)
    end
  elseif string.sub(id, 1, 10) == "Btn_Dress_" then
    local index = tonumber(string.sub(id, 11))
    local wingIndex = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + index
    local wing = self.wings[wingIndex]
    if wing then
      WingModule.Instance():ChangCurWing(wing)
    end
  elseif string.sub(id, 1, 8) == "Btn_Try_" then
    local index = tonumber(string.sub(id, 9))
    local wingIndex = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + index
    local wing = self.wings[wingIndex]
    if wing then
      local wingViewCfg = WingUtils.GetWingOutlookCfgByWingId(wing)
      if wingViewCfg then
        require("Main.Wing.ui.WingPanel").Instance():Show(false)
        require("Main.Item.ui.FittingRoomPanel").Instance():ShowWingsPanel(wingViewCfg.id, wingViewCfg.dyeId, function()
          require("Main.Wing.ui.WingPanel").Instance():Show(true)
        end)
      end
    end
  elseif string.sub(id, 1, 11) == "Img_AttPre_" then
    local index = tonumber(string.sub(id, 12))
    local wingIndex = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + index
    local wing = self.wings[wingIndex]
    if wing then
      WingUtils.ShowPropPreView(wing)
    end
  elseif string.sub(id, 1, 13) == "Img_SkillPre_" then
    local index = tonumber(string.sub(id, 14))
    local wingIndex = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + index
    local wing = self.wings[wingIndex]
    if wing then
      local phase = WingUtils.WingIdToPhase(wing)
      if phase >= 0 then
        require("Main.Wing.ui.WingSkillGallery").ShowWingSkills(phase)
      else
        require("Main.Wing.ui.WingSkillGallery").ShowOneWingSkills(wing)
      end
    end
  elseif string.sub(id, 1, 12) == "Btn_Undress_" then
    local index = tonumber(string.sub(id, 13))
    local wingIndex = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + index
    local wing = self.wings[wingIndex]
    if wing then
      WingModule.Instance():ChangCurWing(0)
    end
  elseif string.sub(id, 1, 13) == "Img_SkillBg1_" or string.sub(id, 1, 13) == "Img_SkillBg2_" then
    local index = tonumber(string.sub(id, 14))
    local wingIndex = (self.currentPage - 1) * DetailInfoNode.ONEPAGE + index
    local wingId = self.wings[wingIndex]
    if wingId then
      local wing = WingModule.Instance():GetWingData():GetWingByWingId(wingId)
      local skillId = wing.skills and wing.skills[1] or 0
      if skillId > 0 then
        local cell = self.m_node:FindDirect(string.format("Scroll View/List/wing_%d/Group_Unlocked_%d/%s", index, index, id))
        if cell then
          require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillId, cell, 0)
        end
      end
    end
  end
end
def.override("string").onDragStart = function(self, id)
  if string.sub(id, 1, 11) == "Model_Wing_" then
    self.dragIndex = tonumber(string.sub(id, 12))
  end
end
def.override("string").onDragEnd = function(self, id)
  self.dragIndex = 0
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.dragIndex > 0 then
    local wingModel = self.models[self.dragIndex]
    wingModel:SetDir(wingModel:GetDir() - dx / 2)
  end
end
def.method("table").OnIDIPInfoChg = function(self, p)
  if ItemSwitchInfo.WING == p.type then
    self:OnPhaseChange(nil)
    self:UpdateArrowAndPoint()
    self:UpdateWing()
  end
end
DetailInfoNode.Commit()
return DetailInfoNode
