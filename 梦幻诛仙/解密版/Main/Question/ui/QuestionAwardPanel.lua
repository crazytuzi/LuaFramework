local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local QuestionAwardPanel = Lplus.Extend(ECPanelBase, "QuestionAwardPanel")
local def = QuestionAwardPanel.define
local _instance
def.field("table").awardBeans = nil
def.field("string").description = ""
def.field("number").type = 1
def.field("table")._questionModule = nil
def.field("number").timer = 0
def.const("table").Type = {
  QUESTION = 1,
  DUNGEON = 2,
  EVERYNIGHT = 3
}
def.static("table", "string", "number").ShowAward = function(awards, desc, type)
  local awardPanel = QuestionAwardPanel.new()
  awardPanel.awardBeans = awards
  awardPanel.description = desc
  awardPanel.type = type
  awardPanel:CreatePanel(RESPATH.QUESTIONAWARD_PANEL, 1)
  awardPanel:SetModal(true)
end
def.static("=>", QuestionAwardPanel).new = function(self)
  local dlg = QuestionAwardPanel()
  local QuestionModule = require("Main.Question.QuestionModule")
  dlg._questionModule = QuestionModule.Instance()
  return dlg
end
def.override().OnCreate = function(self)
  self:SetTitle()
end
def.override().OnDestroy = function(self)
  require("Main.Item.ItemModule").Instance():BlockItemGetEffect(false)
  require("Main.Chat.PersonalHelper").Block(false)
  if self.type == QuestionAwardPanel.Type.DUNGEON then
    require("Main.Dungeon.DungeonModule").Instance():BossAwardFinish()
    require("Main.Dungeon.DungeonModule").Instance().soloMgr:FindMonster(true)
  elseif self.type == QuestionAwardPanel.Type.EVERYNIGHT then
    require("Main.Dungeon.DungeonModule").Instance():BossAwardFinish()
  end
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self.timer = GameUtil.AddGlobalTimer(3, true, function()
      if self.timer ~= 0 then
        self.timer = 0
        local select = math.random(1, 4)
        self:SetAward(select)
      end
    end)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Img_BgPrize") and self.timer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timer)
    self.timer = 0
    local index = tonumber(string.sub(id, 12))
    self:SetAward(index)
  end
end
def.method().SetTitle = function(self)
  local title = self.m_panel:FindDirect("Img_Bg1/Img_Bg2/Label_Tips")
  local labelTitle = title:GetComponent("UILabel")
  labelTitle:set_text(self.description)
  local banner = self.m_panel:FindDirect("Img_Bg1/Img_Title/Sprite")
  local bannerSprite = banner:GetComponent("UISprite")
  local spriteName = ""
  if self.type == QuestionAwardPanel.Type.QUESTION or self.type == QuestionAwardPanel.Type.EVERYNIGHT then
    spriteName = "Label_Quize1"
  elseif self.type == QuestionAwardPanel.Type.DUNGEON then
    spriteName = "Label_Quize3"
  end
  bannerSprite:set_spriteName(spriteName)
  local awards = self.m_panel:FindDirect("Img_Bg1/Img_Bg2")
  for i = 1, 4 do
    local nameGo = awards:FindDirect(string.format("Label%02d", i))
    nameGo:SetActive(false)
  end
end
def.method("number").SetAward = function(self, index)
  if self.m_panel == nil then
    return
  end
  local awards = self.m_panel:FindDirect("Img_Bg1/Img_Bg2")
  for i = 1, 4 do
    local awardBean
    if index == i then
      awardBean = self.awardBeans[1]
    else
      awardBean = self.awardBeans[i % #self.awardBeans + 1]
    end
    local GUIUtils = require("GUI.GUIUtils")
    local RewardItem = require("netio.protocol.mzm.gsp.question.RewardItem")
    local info = awardBean
    local type = info.rewardType
    local name = ""
    local iconId = 0
    if type == RewardItem.TYPE_ITEM then
      local itemId = info.paramMap[RewardItem.PARAM_ITEM_ID]
      local num = info.paramMap[RewardItem.PARAM_ITEM_NUM] or 1
      local itemBase = ItemUtils.GetItemBase(itemId)
      name = string.format("%sx%d", itemBase.name, num)
      iconId = itemBase.icon
    elseif type == RewardItem.TYPE_ROLE_EXP then
      local exp = info.paramMap[RewardItem.PARAM_EXP]
      name = textRes.Wabao[6] .. tostring(exp)
      iconId = GUIUtils.GetIconIdRoleExp()
    elseif type == RewardItem.TYPE_PET_EXP then
      local exp = info.paramMap[RewardItem.PARAM_EXP]
      name = textRes.Wabao[6] .. tostring(exp)
      iconId = GUIUtils.GetIconIdPetExp()
    elseif type == RewardItem.TYPE_XIULIAN_EXP then
      local exp = info.paramMap[RewardItem.PARAM_EXP]
      name = textRes.Wabao[8] .. tostring(exp)
      iconId = GUIUtils.GetIconIdXiulianExp()
    elseif type == RewardItem.TYPE_SILVER then
      local money = info.paramMap[RewardItem.PARAM_MONEY]
      name = textRes.Wabao[3] .. tostring(money)
      iconId = GUIUtils.GetIconIdSilver()
    elseif type == RewardItem.TYPE_GOLD then
      local money = info.paramMap[RewardItem.PARAM_MONEY]
      name = textRes.Wabao[2] .. tostring(money)
      iconId = GUIUtils.GetIconIdGold()
    elseif type == RewardItem.TYPE_BANGGONG then
      local money = info.paramMap[RewardItem.PARAM_MONEY]
      name = textRes.Wabao[5] .. tostring(money)
      iconId = GUIUtils.GetIconIdBanggong()
    elseif type == RewardItem.TYPE_CONTROLLER then
    elseif type == RewardItem.TYPE_YUANBAO then
      local money = info.paramMap[RewardItem.PARAM_MONEY]
      name = textRes.Wabao[4] .. tostring(money)
      iconId = GUIUtils.GetIconIdYuanbao()
    end
    local awardIcon = awards:FindDirect(string.format("Img_BgPrize%02d/Icon", i))
    local uiTexture = awardIcon:GetComponent("UITexture")
    local nameGo = awards:FindDirect(string.format("Label%02d", i))
    local nameLabel = nameGo:GetComponent("UILabel")
    nameGo:SetActive(false)
    nameLabel:set_text(name)
    GUIUtils.FillIcon(uiTexture, iconId)
    if index ~= i then
      GUIUtils.SetTextureEffect(uiTexture, GUIUtils.Effect.Gray)
    end
  end
  local awardBack = awards:FindDirect(string.format("Img_BgPrize%02d", index))
  local nameGo = awards:FindDirect(string.format("Label%02d", index))
  nameGo:SetActive(true)
  local tweenRotation = awardBack:GetComponent("TweenRotation")
  tweenRotation:set_enabled(true)
  local tweenalpha = awardBack:FindDirect("Icon"):GetComponent("TweenAlpha")
  tweenalpha:set_enabled(true)
  local gridTweenalpha = awardBack:FindDirect("Sprite"):GetComponent("TweenAlpha")
  gridTweenalpha:set_enabled(true)
  local nameTweenalpha = awardBack:FindDirect("Label"):GetComponent("TweenAlpha")
  nameTweenalpha:set_enabled(true)
  require("Fx.GUIFxMan").Instance():PlayAsChild(awardBack, RESPATH.QUESTION_AWARD, 0, 0, -1, false)
  GameUtil.AddGlobalTimer(2, true, function()
    if self.m_panel == nil or self.m_panel.isnil then
      return
    end
    for i = 1, 4 do
      if index ~= i then
        local awardother = awards:FindDirect(string.format("Img_BgPrize%02d", i))
        local nameGoother = awards:FindDirect(string.format("Label%02d", i))
        nameGoother:SetActive(true)
        local tweenRotation = awardother:GetComponent("TweenRotation")
        tweenRotation:set_enabled(true)
        local tweenalpha = awardother:FindDirect("Icon"):GetComponent("TweenAlpha")
        tweenalpha:set_enabled(true)
        local gridTweenalpha = awardother:FindDirect("Sprite"):GetComponent("TweenAlpha")
        gridTweenalpha:set_enabled(true)
        local nameTweenalpha = awardother:FindDirect("Label"):GetComponent("TweenAlpha")
        nameTweenalpha:set_enabled(true)
      end
    end
  end)
  GameUtil.AddGlobalTimer(4, true, function()
    self:DestroyPanel()
  end)
end
QuestionAwardPanel.Commit()
return QuestionAwardPanel
