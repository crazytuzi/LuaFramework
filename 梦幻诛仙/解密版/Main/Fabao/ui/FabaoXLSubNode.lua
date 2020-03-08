local Lplus = require("Lplus")
local FabaoSubNodeBase = require("Main.Fabao.ui.FabaoSubNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ECUIModel = require("Model.ECUIModel")
local FabaoModule = Lplus.ForwardDeclare("FabaoModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local GUIUtils = require("GUI.GUIUtils")
local FabaoConst = require("netio.protocol.mzm.gsp.fabao.FaBaoConst")
local FabaoXLSubNode = Lplus.Extend(FabaoSubNodeBase, "FabaoXLSubNode")
local def = FabaoXLSubNode.define
def.field("table").m_UIObjs = nil
def.field(ECUIModel).m_UIModel = nil
def.field("boolean").m_IsWaitingYuanBaoPrice = false
def.field("boolean").m_NeedYuanBaoReplace = false
def.field("table").m_YuanBaoPriceMap = nil
def.field("number").m_NeedYuanBaoNum = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, nodeRoot)
  FabaoSubNodeBase.Init(self, base, nodeRoot)
end
def.override().OnShow = function(self)
  warn("xilian sub node on show ~~~~~~~~~~~~ ")
  self:InitData()
  self:InitUI()
  self:Update()
end
def.override().OnHide = function(self)
  self:DestroyModel()
  self.m_UIObjs = nil
  self.m_IsWaitingYuanBaoPrice = false
  self.m_NeedYuanBaoReplace = false
  self.m_YuanBaoPriceMap = nil
  self.m_NeedYuanBaoNum = 0
end
def.method().DestroyModel = function(self)
  if self.m_UIModel then
    self.m_UIModel:Destroy()
    self.m_UIModel = nil
  end
end
def.method().InitData = function(self)
  self.m_UIObjs = {}
  self.m_IsWaitingYuanBaoPrice = false
  self.m_NeedYuanBaoReplace = false
  self.m_YuanBaoPriceMap = nil
  self.m_NeedYuanBaoNum = 0
end
def.method().InitUI = function(self)
  local toggleBtn = self.m_nodeRoot:FindDirect("Img_BgItem/Btn_UseGold")
  toggleBtn:GetComponent("UIToggle").value = false
end
def.override().Update = function(self)
  self:UpdateUI()
end
def.method().UpdateUI = function(self)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  local rootGroup = self.m_nodeRoot
  if nil == rootGroup or rootGroup.isnil then
    return
  end
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local fabaoItemBase = ItemUtils.GetItemBase(fabaoItemInfo.id)
  local GroupInfo = rootGroup:FindDirect("Group_Info")
  local curFabaoLevel = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_CUR_LV]
  local curFabaoName = fabaoItemBase.name
  local nameLabel = GroupInfo:FindDirect("Label_Name"):GetComponent("UILabel")
  local levelLabel = GroupInfo:FindDirect("Label_LevelNumber"):GetComponent("UILabel")
  nameLabel:set_text(curFabaoName)
  levelLabel:set_text(curFabaoLevel)
  self:UpdateSkillView()
  self:UpdateWashReplaceBtn()
  self:UpdateNeedItemView()
  local modelRoot = self.m_nodeRoot:FindDirect("Group_Icon/Icon_Equip01")
  self:UpdateFabaoModel(modelRoot)
end
def.method().UpdateWashReplaceBtn = function(self)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  local washReplaceBtn = self.m_nodeRoot:FindDirect("Btn_Replace")
  local fabaoInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local washSkillId = fabaoInfo.extraMap[ItemXStoreType.FABAO_WASH_SKILL_ID]
  if washSkillId and 0 ~= washSkillId then
    washReplaceBtn:SetActive(true)
  else
    washReplaceBtn:SetActive(false)
  end
end
def.method().UpdateSkillView = function(self)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  local nodeRoot = self.m_nodeRoot
  if nil == nodeRoot or nodeRoot.isnil then
    return
  end
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local fabaoItemBase = ItemUtils.GetItemBase(fabaoItemInfo.id)
  local curFabaoSkillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
  local SkillUtility = require("Main.Skill.SkillUtility")
  local curSkilltexure = nodeRoot:FindDirect("Group_Skill/Img_BgSkill1/Icon_Skill")
  local curSkillNameLabel = nodeRoot:FindDirect("Group_Skill/Img_BgSkill1/Label_SkillLv")
  local replaceTexure = nodeRoot:FindDirect("Group_Skill/Img_BgSkill2/Icon_Skill")
  local replaceNameLabel = nodeRoot:FindDirect("Group_Skill/Img_BgSkill2/Label_SkillLv")
  local washSkillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_WASH_SKILL_ID]
  local curSkillCfg = SkillUtility.GetSkillCfg(curFabaoSkillId)
  warn("fabao skill is : ", curFabaoSkillId, washSkillId)
  if curSkillCfg then
    local skillIconId = curSkillCfg.iconId
    local skillName = curSkillCfg.name
    GUIUtils.FillIcon(curSkilltexure:GetComponent("UITexture"), skillIconId)
    curSkillNameLabel:GetComponent("UILabel"):set_text(skillName)
  end
  if washSkillId and 0 ~= washSkillId then
    local washSkillCfg = SkillUtility.GetSkillCfg(washSkillId)
    local washSkillIconId = washSkillCfg.iconId
    local washSkillName = washSkillCfg.name
    GUIUtils.FillIcon(replaceTexure:GetComponent("UITexture"), washSkillIconId)
    replaceNameLabel:GetComponent("UILabel"):set_text(washSkillName)
  else
    replaceTexure:GetComponent("UITexture").mainTexture = nil
    replaceNameLabel:GetComponent("UILabel"):set_text(textRes.Fabao[85])
  end
  self:UpdateWashReplaceBtn()
end
def.method("userdata").UpdateFabaoModel = function(self, modelRoot)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    return
  end
  local uiModelComponent = modelRoot:GetComponent("UIModel")
  if nil == uiModelComponent then
    return
  end
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local fabaoBase = require("Main.Item.ItemUtils").GetFabaoItem(fabaoItemInfo.id)
  local modelId = fabaoBase.modelId
  local modelPath = GetModelPath(modelId)
  if nil == modelPath then
    return
  end
  local function SetModelStatus(uiModel)
    if nil == uiModel or nil == uiModel.m_model then
      return
    end
    local offsetCfg = FabaoUtils.GetFabaoModelOffset(modelId)
    uiModelComponent:set_mOffsetX(offsetCfg.offsetX)
    uiModelComponent:set_mOffsetY(offsetCfg.offsetY)
    uiModel:SetDir(180)
    uiModel:SetScale(3)
    uiModel:SetPos(0, 150)
    uiModelComponent.modelGameObject = uiModel.m_model
    local color = FabaoUtils.GetFabaoModelColor(fabaoItemInfo.id)
    if color then
      local render = uiModel.m_model:GetComponentInChildren("SkinnedMeshRenderer")
      render.material:SetColor("_Tint", color)
    end
  end
  local function loadCallback(ret)
    if nil == self.m_UIModel or nil == self.m_UIModel.m_model then
      return
    end
    SetModelStatus(self.m_UIModel)
  end
  self:DestroyModel()
  self.m_UIModel = ECUIModel.new(modelId)
  self.m_UIModel.m_bUncache = true
  self.m_UIModel:LoadUIModel(modelPath, loadCallback)
end
def.method().UpdateNeedItemView = function(self)
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local needItemId, needItemNum = FabaoUtils.GetFabaoWashSkillNeedItemInfo(fabaoBase.rankId)
  local haveItemNum = require("Main.Item.ItemModule").Instance():GetItemCountById(needItemId)
  local needItemBase = require("Main.Item.ItemUtils").GetItemBase(needItemId)
  local needItemName = needItemBase.name
  local needItemIconId = needItemBase.icon
  local numLabel = self.m_nodeRoot:FindDirect("Img_BgItem/Label_Num")
  local itemTexture = self.m_nodeRoot:FindDirect("Img_BgItem/Icon_Item")
  local nameLabel = self.m_nodeRoot:FindDirect("Img_BgItem/Label_Name")
  local numStr = string.format("%d/%d", needItemNum, haveItemNum)
  numLabel:GetComponent("UILabel"):set_text(numStr)
  if needItemNum <= haveItemNum then
    numLabel:GetComponent("UILabel"):set_textColor(Color.green)
  else
    numLabel:GetComponent("UILabel"):set_textColor(Color.red)
  end
  nameLabel:GetComponent("UILabel"):set_text(needItemName)
  GUIUtils.FillIcon(itemTexture:GetComponent("UITexture"), needItemIconId)
  self:UpdateBtnState()
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if "Btn_UseGold" == id then
    self:OnClickYuanBaoReplace(clickObj)
  elseif "Btn_XL" == id then
    self:OnClickXLBtn(clickObj)
  elseif "Btn_Replace" == id then
    self:OnClickReplaceBtn()
  elseif "Img_BgItem" == id then
    local FabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
    local fabaoBase = ItemUtils.GetFabaoItem(FabaoItemInfo.id)
    local needItemId, needItemNum = FabaoUtils.GetFabaoWashSkillNeedItemInfo(fabaoBase.rankId)
    self:ShowGetItemTips(clickObj, "UISprite", needItemId)
  elseif string.find(id, "Img_BgSkill") then
    self:ShowSkillTip(clickObj)
  elseif "Btn_Preview" == id then
    self:OnClickShowPreViewTip(clickObj)
  elseif "Btn_Tip" == id then
    local hoverTipId = FabaoUtils.GetFabaoWashHoverTipId()
    GUIUtils.ShowHoverTip(hoverTipId, 0, 0)
  end
end
def.method("userdata").OnClickShowPreViewTip = function(self, clickObj)
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local fabaoId = fabaoItemInfo.id
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowFabaoSpecialTip(fabaoId, true, 0, 0, 0, 0, 0, false)
end
def.method("userdata").ShowSkillTip = function(self, clickObj)
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local skillId = 0
  local name = clickObj.name
  if "Img_BgSkill2" == name then
    local washSkillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_WASH_SKILL_ID]
    if washSkillId and 0 ~= washSkillId then
      skillId = washSkillId
    else
      return
    end
  elseif "Img_BgSkill1" == name then
    skillId = fabaoItemInfo.extraMap[ItemXStoreType.FABAO_OWN_SKILL_ID]
  end
  if skillId and 0 ~= skillId then
    require("Main.Skill.SkillTipMgr").Instance():ShowTipByIdEx(skillId, clickObj, 0)
  end
end
def.method().OnClickReplaceBtn = function(self)
  if nil == self.m_CurFabao then
    return
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm("", textRes.Fabao[105], function(select, tag)
    if 1 == select then
      local fabaoInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
      local equiped = FabaoConst.EQUIPED
      if not self.m_CurFabao.equiped then
        equiped = FabaoConst.UNEQUIPED
      end
      local uuid = fabaoInfo.uuid[1]
      FabaoModule.RequestReplaceFabaoWashSkill(equiped, uuid)
    end
  end, nil)
end
def.method("userdata").OnClickXLBtn = function(self, clickObj)
  local curFabao = self.m_CurFabao
  if nil == curFabao then
    warn("~~~~~~cur fabao is nil ~~~~~~ ")
    return
  end
  if _G.CheckCrossServerAndToast() then
    return
  end
  local FabaoItemInfo = FabaoModule.GetFabaoItemInfo(curFabao.key, curFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(FabaoItemInfo.id)
  local needItemId, needItemNum = FabaoUtils.GetFabaoWashSkillNeedItemInfo(fabaoBase.rankId)
  local haveItemNum = require("Main.Item.ItemModule").Instance():GetItemCountById(needItemId)
  local equiped = FabaoConst.EQUIPED
  if not self.m_CurFabao.equiped then
    equiped = FabaoConst.UNEQUIPED
  end
  local fabaouuid = FabaoItemInfo.uuid[1]
  if needItemNum > haveItemNum then
    if self.m_NeedYuanBaoReplace then
      local allYuanbao = require("Main.Item.ItemModule").Instance():GetAllYuanBao()
      if allYuanbao:lt(self.m_NeedYuanBaoNum) then
        Toast(textRes.Common[15])
        return
      end
      FabaoModule.RequestFabaoWashSkill(equiped, fabaouuid, self.m_NeedYuanBaoNum)
    else
      self:ShowGetItemTips(clickObj, "UISprite", needItemId)
    end
  else
    FabaoModule.RequestFabaoWashSkill(equiped, fabaouuid, 0)
  end
end
def.method("userdata", "string", "number").ShowGetItemTips = function(self, obj, comName, itemid)
  local position = obj.position
  local screenPosition = WorldPosToScreen(position.x, position.y)
  local sprite = obj:GetComponent(comName)
  local width = sprite:get_width()
  local height = sprite:get_height()
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  ItemTipsMgr.Instance():ShowBasicTips(itemid, screenPosition.x, screenPosition.y, width, height, 0, true)
end
def.method("userdata").OnClickYuanBaoReplace = function(self, clickObj)
  local uiToggle = clickObj:GetComponent("UIToggle")
  local curValue = uiToggle.value
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  if curValue then
    local needItemId = 0
    local needItemNum = 0
    needItemId, needItemNum = FabaoUtils.GetFabaoWashSkillNeedItemInfo(fabaoBase.rankId)
    local haveItemNum = require("Main.Item.ItemModule").Instance():GetItemCountById(needItemId)
    if needItemNum <= haveItemNum then
      uiToggle.value = false
      local needItemBase = require("Main.Item.ItemUtils").GetItemBase(needItemId)
      local needItemName = needItemBase.name
      Toast(string.format(textRes.Fabao[86], needItemName))
      self.m_IsWaitingYuanBaoPrice = false
      self.m_NeedYuanBaoReplace = false
      self.m_YuanBaoPriceMap = nil
      self.m_NeedYuanBaoNum = 0
      self:UpdateBtnState()
      return
    else
      self.m_IsWaitingYuanBaoPrice = true
      self.m_NeedYuanBaoNum = 0
      self.m_NeedYuanBaoReplace = false
      self.m_YuanBaoPriceMap = nil
      local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPriceWithId").new(self.m_CurFabao.id, {needItemId})
      gmodule.network.sendProtocol(p)
    end
  else
    self.m_IsWaitingYuanBaoPrice = false
    self.m_NeedYuanBaoReplace = false
    self.m_YuanBaoPriceMap = nil
    self.m_NeedYuanBaoNum = 0
    self:UpdateBtnState()
  end
end
def.method().UpdateBtnState = function(self)
  local toggleBtn = self.m_nodeRoot:FindDirect("Img_BgItem/Btn_UseGold")
  local uiToggle = toggleBtn:GetComponent("UIToggle")
  local XLBtnLabel = self.m_nodeRoot:FindDirect("Btn_XL/Label_XL")
  local yuanbaoGroup = self.m_nodeRoot:FindDirect("Btn_XL/Group_Yuanbao")
  local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  local needItemId, needItemNum = FabaoUtils.GetFabaoWashSkillNeedItemInfo(fabaoBase.rankId)
  local haveItemNum = require("Main.Item.ItemModule").Instance():GetItemCountById(needItemId)
  local curValue = uiToggle.value
  if curValue and self.m_NeedYuanBaoReplace and self.m_YuanBaoPriceMap and self.m_YuanBaoPriceMap[needItemId] then
    if needItemNum <= haveItemNum then
      uiToggle.value = false
      yuanbaoGroup:SetActive(false)
      XLBtnLabel:SetActive(true)
      self.m_IsWaitingYuanBaoPrice = false
      self.m_NeedYuanBaoReplace = false
      self.m_YuanBaoPriceMap = nil
      self.m_NeedYuanBaoNum = 0
      return
    end
    yuanbaoGroup:SetActive(true)
    XLBtnLabel:SetActive(false)
    local yuanbaoLabel = yuanbaoGroup:FindDirect("Label_Money")
    local price = self.m_YuanBaoPriceMap[needItemId]
    self.m_NeedYuanBaoNum = price * (needItemNum - haveItemNum)
    yuanbaoLabel:GetComponent("UILabel"):set_text(self.m_NeedYuanBaoNum)
  else
    yuanbaoGroup:SetActive(false)
    XLBtnLabel:SetActive(true)
    self.m_IsWaitingYuanBaoPrice = false
    self.m_NeedYuanBaoReplace = false
    self.m_YuanBaoPriceMap = nil
    self.m_NeedYuanBaoNum = 0
  end
end
def.method("number", "table").OnYuanBaoPriceRes = function(self, uid, itemid2yuanbao)
  if self.m_nodeRoot and not self.m_nodeRoot.isnil then
    if self.m_IsWaitingYuanBaoPrice then
      self.m_IsWaitingYuanBaoPrice = false
      local curFabaoId = self.m_CurFabao.id
      warn("OnYuanBaoPriceRes ", curFabaoId, uid)
      if curFabaoId == uid then
        local fabaoItemInfo = FabaoModule.GetFabaoItemInfo(self.m_CurFabao.key, self.m_CurFabao.fabaoType)
        local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
        local needItemId, needItemNum = FabaoUtils.GetFabaoWashSkillNeedItemInfo(fabaoBase.rankId)
        local haveItemNum = require("Main.Item.ItemModule").Instance():GetItemCountById(needItemId)
        local price = itemid2yuanbao[needItemId]
        if price then
          if nil == self.m_YuanBaoPriceMap then
            self.m_YuanBaoPriceMap = {}
          end
          self.m_YuanBaoPriceMap[needItemId] = price
          if needItemNum > haveItemNum then
            self.m_NeedYuanBaoReplace = true
            self.m_NeedYuanBaoNum = price * (needItemNum - haveItemNum)
            self:UpdateBtnState()
            return
          end
        end
      end
      self.m_NeedYuanBaoReplace = false
      self.m_YuanBaoPriceMap = nil
      self.m_NeedYuanBaoNum = 0
      self:UpdateBtnState()
    else
      self.m_NeedYuanBaoReplace = false
      self.m_YuanBaoPriceMap = nil
      self.m_NeedYuanBaoNum = 0
      self:UpdateBtnState()
    end
  end
end
def.method().OnFabaoWashSucRes = function(self)
  local fxObj = self.m_nodeRoot:FindDirect("Group_Skill/Img_BgSkill2")
  if fxObj and not fxObj.isnil then
    require("Fx.GUIFxMan").Instance():PlayAsChild(fxObj, RESPATH.EQUIP_INHERIT_HIDE_EFFECT, 0, 0, -1, false)
  end
end
def.method().OnFabaoReplaceWashSkillRes = function(self)
  local fxObj = self.m_nodeRoot:FindDirect("Group_Skill/Img_BgSkill1")
  if fxObj and not fxObj.isnil then
    require("Fx.GUIFxMan").Instance():PlayAsChild(fxObj, RESPATH.EQUIP_INHERIT_HIDE_EFFECT, 0, 0, -1, false)
  end
end
FabaoXLSubNode.Commit()
return FabaoXLSubNode
