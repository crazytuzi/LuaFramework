local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BandstandJoinPanel = Lplus.Extend(ECPanelBase, "BandstandJoinPanel")
local BandstandMgr = require("Main.activity.Bandstand.BandstandMgr")
local NPCInterface = require("Main.npc.NPCInterface")
local UIModelWrap = require("Model.UIModelWrap")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local TokenType = require("consts.mzm.gsp.item.confbean.TokenType")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local def = BandstandJoinPanel.define
local instance
def.field("number").activityId = 0
def.field(UIModelWrap)._UIModelWrap = nil
def.static("=>", BandstandJoinPanel).Instance = function()
  if instance == nil then
    instance = BandstandJoinPanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, activityId)
  if self:IsShow() then
    return
  end
  self.activityId = activityId
  self:CreatePanel(RESPATH.PREFAB_MUSIC_STATION_JOIN, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
end
def.override().OnDestroy = function(self)
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setActivityInfo()
  else
  end
end
def.method().Hide = function(self)
  if self._UIModelWrap then
    self._UIModelWrap:Destroy()
    self._UIModelWrap = nil
  end
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("------BandstandJoinPanel onClick:", id)
  if id == "Btn_Close" then
    self:Hide()
  elseif string.find(id, "Img_Gift0") then
    local idx = tonumber(string.sub(id, #"Img_Gift0" + 1))
    if idx then
      local bandstandCfg = BandstandMgr.GetBandstandActivityCfg(self.activityId)
      local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(bandstandCfg.awardId)
      if awardCfg then
        local itemInfo = awardCfg.itemList[idx]
        if itemInfo then
          ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemInfo.itemId, clickObj, 0, false)
        end
      end
    end
  elseif id == "Btn_PointsShop" or id == "Btn_JoinActivity" then
    local bandstandCfg = BandstandMgr.GetBandstandActivityCfg(self.activityId)
    if bandstandCfg then
      local activityId = self.activityId
      self:Hide()
      Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
        bandstandCfg.npcId
      })
    end
  end
end
def.method().setActivityInfo = function(self)
  local score = ItemModule.Instance():GetCredits(TokenType.BANDSTAND_SCORE) or Int64.new(0)
  local Label_Points = self.m_panel:FindDirect("Img_Bg0/Group_Points/Label_Points")
  Label_Points:GetComponent("UILabel"):set_text(tostring(score))
  local bandstandCfg = BandstandMgr.GetBandstandActivityCfg(self.activityId)
  if bandstandCfg then
    if self._UIModelWrap == nil then
      local Model = self.m_panel:FindDirect("Img_Bg0/Model")
      local uiModel = Model:GetComponent("UIModel")
      uiModel.mCanOverflow = true
      self._UIModelWrap = UIModelWrap.new(uiModel)
    end
    local npcCfg = NPCInterface.GetNPCCfg(bandstandCfg.npcId)
    local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, npcCfg.monsterModelTableId)
    local headidx = DynamicRecord.GetIntValue(modelinfo, "halfBodyIconId")
    local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, headidx)
    if iconRecord == nil then
      warn("Icon res get nil record for id: ", headidx)
      return
    end
    local resourceType = iconRecord:GetIntValue("iconType")
    if resourceType == 1 then
      local resourcePath = iconRecord:GetStringValue("path")
      if resourcePath and resourcePath ~= "" then
        self._UIModelWrap:Load(resourcePath .. ".u3dext")
      else
        warn(" resourcePath == \"\" iconId = " .. headidx)
      end
    end
    local Group_Gift = self.m_panel:FindDirect("Img_Bg0/Group_Gift")
    local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(bandstandCfg.awardId)
    for i = 1, 3 do
      local Img_Gift = Group_Gift:FindDirect("Img_Gift0" .. i)
      if awardCfg == nil then
        warn("------BandstandJoinPanel awardCfg isnil:", bandstandCfg.awardId)
        Img_Gift:SetActive(false)
      else
        local itemInfo = awardCfg.itemList[i]
        if itemInfo then
          Img_Gift:SetActive(true)
          local itemId = itemInfo.itemId
          local itemBase = ItemUtils.GetItemBase(itemId)
          local Img_Texture = Img_Gift:FindDirect("Img_Texture")
          GUIUtils.FillIcon(Img_Texture:GetComponent("UITexture"), itemBase.icon)
        else
          Img_Gift:SetActive(false)
        end
      end
    end
  end
end
return BandstandJoinPanel.Commit()
