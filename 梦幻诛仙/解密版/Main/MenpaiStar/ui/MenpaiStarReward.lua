local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MenpaiStarReward = Lplus.Extend(ECPanelBase, "MenpaiStarReward")
local MenpaiStarModule = Lplus.ForwardDeclare("MenpaiStarModule")
local def = MenpaiStarReward.define
local instance
def.static("=>", MenpaiStarReward).Instance = function()
  if instance == nil then
    instance = MenpaiStarReward()
  end
  return instance
end
def.field("number").oldAward = 0
def.field("number").oldNum = 0
def.field("number").selectAward = 0
def.field("number").selectNum = 0
def.field("table").awards = nil
def.field("table").nums = nil
def.static("table", "table", "number", "number").ShowMenpaiStarReward = function(awards, nums, oldAward, oldNum)
  if awards == nil or nums == nil then
    return
  end
  local self = MenpaiStarReward.Instance()
  self.awards = awards
  self.nums = nums
  self.oldAward = oldAward
  self.oldNum = oldNum
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PERFAB_MENPAISTAR_REWARD, 2)
end
def.override().OnCreate = function(self)
  self:UpdateAward()
  self:UpdateNum()
  self:UpdateMoney()
end
def.method().UpdateAward = function(self)
  local count = self.awards and #self.awards or 0
  local list = self.m_panel:FindDirect("Img_Bg0/Group_VoteReward/Group_Toggle")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local award = self.awards[i]
    local awardLbl = uiGo:FindDirect(string.format("Label_CostNum_%d", i))
    awardLbl:GetComponent("UILabel"):set_text(tonumber(award))
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method().UpdateNum = function(self)
  local count = self.nums and #self.nums or 0
  local list = self.m_panel:FindDirect("Img_Bg0/Group_VoteNum/Group_Toggle")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local num = self.nums[i]
    local numLbl = uiGo:FindDirect(string.format("Label_GiveNum_%d", i))
    numLbl:GetComponent("UILabel"):set_text(string.format(textRes.MenpaiStar[13], num))
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method().UpdateMoney = function(self)
  local cost = self:GetCostYuanbao()
  local yuanbaoLbl = self.m_panel:FindDirect("Img_Bg0/Group_Result/Label_Result")
  yuanbaoLbl:GetComponent("UILabel"):set_text(tonumber(cost))
end
def.method("=>", "number").GetCostYuanbao = function(self)
  local oldGold = self.oldAward * self.oldNum
  local newGold = self.selectAward * self.selectNum
  local diffGold = newGold - oldGold
  warn("GetCostYuanbao", self.selectAward, self.selectNum)
  local cost = 0
  if diffGold > 0 then
    cost = math.ceil(diffGold / constant.CMoneyExchangeCfgConsts.YUANBAO_TO_GOLD_NUM)
  end
  return cost
end
def.override().OnDestroy = function(self)
  self.oldAward = 0
  self.oldNum = 0
  self.selectAward = 0
  self.selectNum = 0
  self.awards = nil
  self.nums = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    if self.selectAward <= 0 or 0 >= self.selectNum then
      Toast(textRes.MenpaiStar[47])
      return
    end
    if self.selectAward == self.oldAward and self.selectNum == self.oldNum then
      Toast(textRes.MenpaiStar[48])
      return
    end
    local costYuanbao = self:GetCostYuanbao()
    local ItemModule = require("Main.Item.ItemModule")
    local myYuanbao = ItemModule.Instance():GetAllYuanBao()
    if myYuanbao < Int64.new(costYuanbao) then
      Toast(textRes.MenpaiStar[15])
      _G.GotoBuyYuanbao()
      return
    end
    MenpaiStarModule.Instance():SetAward(self.selectAward, self.selectNum, self.oldNum)
    self:DestroyPanel()
  elseif id == "Btn_Help" then
    require("GUI.GUIUtils").ShowHoverTip(constant.CMenPaiStarConst.CUSTOM_UI_TIP_ID, 0, 0)
  end
end
def.method("string", "boolean").onToggle = function(self, id, value)
  if value then
    if string.sub(id, 1, 10) == "Item_Cost_" then
      local index = tonumber(string.sub(id, 11))
      if index and self.awards and self.awards[index] then
        self.selectAward = self.awards[index]
        self:UpdateMoney()
      end
    elseif string.sub(id, 1, 10) == "Item_Give_" then
      local index = tonumber(string.sub(id, 11))
      if index and self.nums and self.nums[index] then
        self.selectNum = self.nums[index]
        self:UpdateMoney()
      end
    end
  end
end
return MenpaiStarReward.Commit()
