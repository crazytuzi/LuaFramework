local Lplus = require("Lplus")
local ECPanelBae = require("GUI.ECPanelBase")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local BabyMgr = require("Main.Children.mgr.BabyMgr")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local GUIUtils = require("GUI.GUIUtils")
local ChildrenWelfareDlg = Lplus.Extend(ECPanelBae, "ChildrenWelfareDlg")
local def = ChildrenWelfareDlg.define
local instance
def.field("userdata").ui_List = nil
def.field("table").m_childMap = nil
def.field("table").queryCallback = nil
def.static("=>", ChildrenWelfareDlg).Instance = function()
  if instance == nil then
    instance = ChildrenWelfareDlg()
  end
  return instance
end
def.override().OnCreate = function(self)
  local ui_Img0 = self.m_panel:FindDirect("Img_Bg0")
  local ui_GroupList = ui_Img0:FindDirect("Group_List")
  local ui_GroupEmpty = ui_Img0:FindDirect("Group_NoData")
  local ui_ScrollView = ui_GroupList:FindDirect("Scrollview")
  self.ui_List = ui_ScrollView:FindDirect("List")
  local discardChild = ChildrenDataMgr.Instance():GetAllDiscardChild()
  if discardChild == nil or next(discardChild) == nil then
    ui_GroupList:SetActive(false)
    ui_GroupEmpty:SetActive(true)
    return
  end
  self.m_childMap = {}
  for k, v in pairs(discardChild) do
    local childInfo = ChildrenDataMgr.Instance():GetDiscardContentById(Int64.new(k))
    if childInfo ~= nil and childInfo:IsMine() == true then
      local child = {}
      child.id = k
      child.dtime = v
      self.m_childMap[#self.m_childMap + 1] = child
    end
  end
  table.sort(self.m_childMap, function(a, b)
    return a.dtime < b.dtime
  end)
  self:SetListInfo()
end
def.override().OnDestroy = function(self)
  self.ui_List = nil
  self.m_childMap = nil
end
local conv2sec = function(time)
  local serverTime = _G.GetServerTime()
  local serverTimeScale = 10 * serverTime
  if time:gt(serverTimeScale) then
    return time / 1000
  else
    return time
  end
end
def.method().SetListInfo = function(self)
  local count = #self.m_childMap
  local uiList = self.ui_List:GetComponent("UIList")
  uiList.itemCount = count
  uiList:Resize()
  for k, v in ipairs(self.m_childMap) do
    local listItem = self.ui_List:FindDirect("Item_" .. k)
    listItem:FindDirect("Label_Date_" .. k):GetComponent("UILabel"):set_text(self:FormatTime(conv2sec(v.dtime)))
    local child = ChildrenDataMgr.Instance():GetDiscardContentById(Int64.new(v.id))
    if child ~= nil then
      local player = listItem:FindDirect("Group_Player_" .. k)
      player:FindDirect("Label_Name_" .. k):GetComponent("UILabel"):set_text(child:GetName())
      local tex = player:FindDirect(string.format("Img_BgCharacter_%d/Icon_Head_%d", k, k)):GetComponent("UITexture")
      local icon = ChildrenUtils.GetChildHeadIcon(child:GetCurModelId())
      GUIUtils.FillIcon(tex, icon)
      if k % 2 == 0 then
        GUIUtils.SetActive(listItem:FindDirect(string.format("Img_Bg01_%d", k)), false)
        GUIUtils.SetActive(listItem:FindDirect(string.format("Img_Bg02_%d", k)), true)
      else
        GUIUtils.SetActive(listItem:FindDirect(string.format("Img_Bg02_%d", k)), false)
        GUIUtils.SetActive(listItem:FindDirect(string.format("Img_Bg01_%d", k)), true)
      end
      local score = 0
      if child:IsYouth() == true then
        score = child:CalYouthChildScore()
      end
      local points = listItem:FindDirect(string.format("Group_Points_%d", k))
      points:FindDirect(string.format("Label_TimeNum_%d", k)):GetComponent("UILabel"):set_text(score)
      local headSpr = player:FindDirect(string.format("Img_Child_%d", k)):GetComponent("UISprite")
      if child:IsBaby() == true then
        headSpr:set_spriteName("Img_YingEr")
      elseif child:IsTeen() == true then
        headSpr:set_spriteName("Img_TongNian")
      elseif child:IsYouth() == true then
        headSpr:set_spriteName("Img_ZhangCheng")
      end
      local sexSpr = player:FindDirect(string.format("Img_Sex_%d", k))
      GUIUtils.SetSprite(sexSpr, GUIUtils.GetGenderSprite(child:GetGender()))
      local occupationSpr = player:FindDirect(string.format("Img_MenPai_%d", k))
      if child:IsYouth() == true then
        GUIUtils.SetSprite(occupationSpr, GUIUtils.GetOccupationSmallIcon(child:GetMenpai()))
      else
        GUIUtils.SetActive(occupationSpr, false)
      end
      local cost = listItem:FindDirect("Group_Cost_" .. k)
      local cfg = ChildrenUtils.GetRecallCfg(child:GetStatus())
      local costIconSpr = cost:FindDirect(string.format("Img_Icon_%d", k))
      local costNumLabel = cost:FindDirect(string.format("Label_Num_%d", k))
      local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
      if cfg.costCurrencyType == CurrencyType.YUAN_BAO then
        GUIUtils.SetSprite(costIconSpr, GUIUtils.GetMoneySprite(CurrencyType.YUAN_BAO))
      elseif cfg.costCurrencyType == CurrencyType.GOLD then
        GUIUtils.SetSprite(costIconSpr, GUIUtils.GetMoneySprite(CurrencyType.GOLD))
      end
      costNumLabel:GetComponent("UILabel"):set_text(cfg.costCurrencyNum)
    end
  end
end
def.method("userdata", "=>", "string").FormatTime = function(self, timestamp)
  if timestamp == nil or timestamp:eq(0) then
    return ""
  end
  timestamp = timestamp:ToNumber()
  local t = AbsoluteTimer.GetServerTimeTable(timestamp)
  return string.format(textRes.Children[6000], t.year, t.month, t.day)
end
def.method().ShowDlg = function(self)
  if not self.m_panel then
    self:CreatePanel(RESPATH.CHILDREN_WELFARE_PANEL_RES, 1)
  end
end
def.method("string").onClick = function(self, id)
  local function ChildrenCallBack(index)
    local childId = self.m_childMap[index].id
    local child = ChildrenDataMgr.Instance():GetDiscardContentById(Int64.new(childId))
    if child ~= nil then
      local cfg = ChildrenUtils.GetRecallCfg(child:GetStatus())
      local CurrencyFactory = require("Main.Currency.CurrencyFactory")
      local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
      if cfg.costCurrencyType == CurrencyType.YUAN_BAO then
        local moneyData = CurrencyFactory.Create(CurrencyType.YUAN_BAO)
        local haveNum = moneyData:GetHaveNum()
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CRecallChild").new(Int64.new(childId), Int64.new(haveNum)))
      elseif cfg.costCurrencyType == CurrencyType.GOLD then
        local moneyData = CurrencyFactory.Create(CurrencyType.GOLD)
        local haveNum = moneyData:GetHaveNum()
        gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CRecallChild").new(Int64.new(childId), Int64.new(haveNum)))
      end
    end
    self:DestroyPanel()
  end
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif string.find(id, "Btn_Info_", 1) ~= nil then
    local i = tonumber(id:split("_")[3])
    local childId = self.m_childMap[i].id
    if childId ~= nil then
      require("Main.Children.ChildrenInterface").RequestChildInfo(Int64.new(childId))
    end
  elseif string.find(id, "Btn_CallBack", 1) ~= nil then
    do
      local i = tonumber(id:split("_")[3])
      local CommonConfirm = require("GUI.CommonConfirmDlg")
      local CurrencyType = require("consts.mzm.gsp.common.confbean.CurrencyType")
      local str = ""
      local child = ChildrenDataMgr.Instance():GetDiscardContentById(Int64.new(self.m_childMap[i].id))
      local cfg = ChildrenUtils.GetRecallCfg(child:GetStatus())
      if cfg.costCurrencyType == CurrencyType.YUAN_BAO then
        str = string.format(textRes.Children[6003], cfg.costCurrencyNum, child:GetName())
      elseif cfg.costCurrencyType == CurrencyType.GOLD then
        str = string.format(textRes.Children[6002], cfg.costCurrencyNum, child:GetName())
      end
      CommonConfirm.ShowConfirm("", str, function(result)
        if result == 1 then
          ChildrenCallBack(i)
        end
      end, nil)
    end
  elseif string.find(id, "Btn_Help", 1) ~= nil then
    GUIUtils.ShowHoverTip(constant.CChildrenConsts.child_welfare_house_tips)
  end
end
ChildrenWelfareDlg.Commit()
return ChildrenWelfareDlg
