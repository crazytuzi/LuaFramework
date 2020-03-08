local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RegisterMultiWeddingPanel = Lplus.Extend(ECPanelBase, "RegisterMultiWeddingPanel")
local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local def = RegisterMultiWeddingPanel.define
local instance
def.static("=>", RegisterMultiWeddingPanel).Instance = function()
  if instance == nil then
    instance = RegisterMultiWeddingPanel()
  end
  return instance
end
def.field("number").tipId = 0
def.field("number").rank = 0
def.field("number").price = 0
def.field("table").rankList = nil
def.field("number").lastRefresh = 0
def.field("number").endTime = 0
def.field("number").timer = 0
def.method("number", "number", "number", "number", "table").ShowRegister = function(self, tipId, rank, price, endTime, rankList)
  self.tipId = tipId
  self.rank = rank
  self.price = price
  self.endTime = endTime
  self.rankList = rankList
  if self:IsShow() then
    self:UpdateDynamic()
  else
    self:CreatePanel(RESPATH.PREFAB_REGISTERWEDDING, 1)
    self:SetModal(true)
  end
end
def.method("table").SetList = function(self, rankList)
  self.rankList = rankList
  if self:IsShow() then
    self:UpdateList()
  end
end
def.method("number", "number").SetRankAndPrice = function(self, rank, price)
  self.rank = rank
  self.price = price
  self:UpdateInfo()
  self:UpdateButton()
end
def.override().OnCreate = function(self)
  self:UpdateAll()
end
def.override().OnDestroy = function(self)
end
def.method().UpdateDynamic = function(self)
  self:UpdateInfo()
  self:UpdateList()
  self:UpdateButton()
end
def.method().UpdateAll = function(self)
  self:UpdateInfo()
  self:UpdateTip()
  self:UpdateList()
  self:UpdateButton()
  self:UpdateTime()
end
def.method().UpdateInfo = function(self)
  local price = self.m_panel:FindDirect("Img_Bg0/Label_MyPrize")
  local rank = self.m_panel:FindDirect("Img_Bg0/Label_MyRanking")
  if self.price > 0 then
    price:GetComponent("UILabel"):set_text(string.format(textRes.Marriage[60], self.price))
  else
    price:GetComponent("UILabel"):set_text(textRes.Marriage[62])
  end
  if 0 < self.rank then
    rank:GetComponent("UILabel"):set_text(string.format(textRes.Marriage[61], self.rank))
  else
    rank:GetComponent("UILabel"):set_text(string.format(textRes.Marriage[63], constant.CMassWeddingConsts.maxCouple))
  end
end
def.method().UpdateTip = function(self)
  local tipString = require("Main.Common.TipsHelper").GetHoverTip(self.tipId)
  local infoLabel = self.m_panel:FindDirect("Img_Bg0/Label_Describe")
  infoLabel:GetComponent("UILabel"):set_text(tipString)
end
def.method().UpdateList = function(self)
  local count = #self.rankList
  local bg = self.m_panel:FindDirect("Img_Bg0/Group_Detail/Group_List/Scroll View")
  local list = bg:FindDirect("List_Left")
  local listCmp = list:GetComponent("UIList")
  listCmp:set_itemCount(count)
  listCmp:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not listCmp.isnil then
      listCmp:Reposition()
    end
  end)
  GameUtil.AddGlobalLateTimer(0.01, true, function()
    if bg and not bg.isnil then
      bg:GetComponent("UIScrollView"):ResetPosition()
    end
  end)
  local items = listCmp:get_children()
  for i = 1, #items do
    local uiGo = items[i]
    local info = self.rankList[i]
    local name1 = uiGo:FindDirect("Label_1")
    local name2 = uiGo:FindDirect("Label_2")
    local price = uiGo:FindDirect("Label_3")
    local rank = uiGo:FindDirect("Label")
    name1:GetComponent("UILabel"):set_text(info.man)
    name2:GetComponent("UILabel"):set_text(info.women)
    price:GetComponent("UILabel"):set_text(info.price)
    rank:GetComponent("UILabel"):set_text(i)
    self.m_msgHandler:Touch(uiGo)
  end
end
def.method().UpdateButton = function(self)
  local btnIn = self.m_panel:FindDirect("Img_Bg0/Btn_Baoming")
  local btnAdd = self.m_panel:FindDirect("Img_Bg0/Btn_Jiajia")
  local MassWeddingConst = require("netio.protocol.mzm.gsp.masswedding.MassWeddingConst")
  if require("Main.Marriage.MultiWeddingMgr").Instance().stage == MassWeddingConst.STAGE_SIGN_UP then
    if self.price > 0 then
      btnIn:SetActive(false)
      btnAdd:SetActive(true)
    else
      btnIn:SetActive(true)
      btnAdd:SetActive(false)
    end
  else
    btnIn:SetActive(false)
    btnAdd:SetActive(false)
  end
end
def.method("number", "=>", "string").SecToText = function(self, leftTime)
  local minute = math.floor(leftTime / 60)
  local second = leftTime % 60
  local text
  if minute > 0 then
    text = string.format("%02d%s%02d%s", minute, textRes.Pitch[1], second, textRes.Pitch[2])
  else
    text = string.format("%02d%s", second, textRes.Pitch[2])
  end
  return text
end
def.method().UpdateTime = function(self)
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
  local timeLbl = self.m_panel:FindDirect("Img_Bg0/Label_Times")
  local curTime = GetServerTime()
  if curTime >= self.endTime then
    timeLbl:GetComponent("UILabel"):set_text(textRes.Marriage[110])
  else
    do
      local leftTime = self.endTime - curTime
      local text = self:SecToText(leftTime)
      timeLbl:GetComponent("UILabel"):set_text(string.format(textRes.Marriage[122], text))
      self.timer = GameUtil.AddGlobalTimer(1, false, function()
        if timeLbl.isnil then
          return
        end
        leftTime = self.endTime - GetServerTime()
        if leftTime > 0 then
          local text = self:SecToText(leftTime)
          timeLbl:GetComponent("UILabel"):set_text(string.format(textRes.Marriage[122], text))
        else
          GameUtil.RemoveGlobalTimer(self.timer)
          self.timer = 0
          timeLbl:GetComponent("UILabel"):set_text(textRes.Marriage[110])
          self:UpdateButton()
        end
      end)
    end
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Baoming" then
    if self.price == 0 then
      local CommonNumberInput = require("GUI.CommonNumberInput")
      local desc = string.format(textRes.Marriage[83], constant.CMassWeddingConsts.minPrice)
      CommonNumberInput.ShowNumberInput(constant.CMassWeddingConsts.minPrice, 1000, textRes.Marriage[82], desc, function(ret, num)
        if ret then
          if num >= constant.CMassWeddingConsts.minPrice then
            require("Main.Marriage.MultiWeddingMgr").Instance():SignUp(num)
          else
            Toast(string.format(textRes.Marriage[86], constant.CMassWeddingConsts.minPrice))
          end
        end
      end)
    end
  elseif id == "Btn_Jiajia" then
    if self.price > 0 then
      local CommonNumberInput = require("GUI.CommonNumberInput")
      local desc = string.format(textRes.Marriage[85], self.price)
      CommonNumberInput.ShowNumberInput(0, 1000, textRes.Marriage[84], desc, function(ret, num)
        if ret and num >= 0 then
          require("Main.Marriage.MultiWeddingMgr").Instance():AddPrice(num)
        end
      end)
    end
  elseif id == "Btn_Refresh" then
    local interval = os.time() - self.lastRefresh
    if interval > 4 then
      require("Main.Marriage.MultiWeddingMgr").Instance():RequestNewRank()
      self.lastRefresh = os.time()
    else
      Toast(string.format(textRes.Marriage[112], 4 - interval))
    end
  end
end
RegisterMultiWeddingPanel.Commit()
return RegisterMultiWeddingPanel
