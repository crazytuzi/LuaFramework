local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TeenInterestPanel = Lplus.Extend(ECPanelBase, "TeenInterestPanel")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local TeenData = require("Main.Children.data.TeenData")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local PropType = require("consts.mzm.gsp.children.confbean.InterestType")
local def = TeenInterestPanel.define
local instance
def.static("=>", TeenInterestPanel).Instance = function()
  if instance == nil then
    instance = TeenInterestPanel()
  end
  return instance
end
def.field("userdata").childId = nil
def.method("userdata").ShowChooseInterest = function(self, cid)
  local teenData = ChildrenDataMgr.Instance():GetChildById(cid)
  if teenData and teenData:IsTeen() then
    local dlg = TeenInterestPanel.Instance()
    dlg.childId = cid
    if dlg:IsShow() then
      dlg:UpdateUI(teenData)
    else
      dlg:CreatePanel(RESPATH.PREFAB_TEEN_CHOOSE_INTEREST, 2)
      dlg:SetModal(true)
    end
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.CHILDREN, gmodule.notifyId.Children.Interest_Update, TeenInterestPanel.OnInterestChange, self)
  self:UpdateUI(nil)
  self:UpdateDesc()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Interest_Update, TeenInterestPanel.OnInterestChange)
  self.childId = nil
end
def.method("table").OnInterestChange = function(self, param)
  local childId = param[1]
  if self.childId == childId then
    self:UpdateUI(nil)
  end
end
def.method("=>", TeenData).GetData = function(self)
  if self.childId then
    local teenData = ChildrenDataMgr.Instance():GetChildById(self.childId)
    if teenData and teenData:IsTeen() then
      return teenData
    else
      return nil
    end
  else
    return nil
  end
end
def.method().UpdateDesc = function(self)
  local desc = require("Main.Common.TipsHelper").GetHoverTip(constant.CChildHoodConst.UI_CHOOSE_INTEREST_TIPS)
  local descLbl = self.m_panel:FindDirect("Img_Bg0/Label_Tips")
  descLbl:GetComponent("UILabel"):set_text(desc)
end
def.method(TeenData).UpdateUI = function(self, teenData)
  if teenData == nil then
    teenData = self:GetData()
  end
  if teenData == nil then
    return
  end
  local list = self.m_panel:FindDirect("Img_Bg0/Label_Attribute/Img_Bg/List_Prop")
  if teenData:GetInterest() > 0 then
    list:SetActive(true)
    do
      local interestProp = teenData:GetInterestProps()
      local sortProp = {}
      for k, v in pairs(interestProp) do
        if v > 0 then
          table.insert(sortProp, {prop = k, value = v})
        end
      end
      table.sort(sortProp, function(a, b)
        return a.prop < b.prop
      end)
      local listCmp = list:GetComponent("UIList")
      local count = #sortProp
      local listCmp = list:GetComponent("UIList")
      listCmp:set_itemCount(count)
      listCmp:Resize()
      GameUtil.AddGlobalLateTimer(0, true, function()
        if not listCmp.isnil then
          listCmp:Reposition()
        end
      end)
      local items = listCmp:get_children()
      for i = 1, #items do
        local uiGo = items[i]
        local prop = sortProp[i]
        local nameSpr = uiGo:FindDirect("Sprite_Item")
        local sprName = textRes.Children.PropSpriteName[prop.prop] or ""
        nameSpr:GetComponent("UISprite"):set_spriteName(sprName)
        local valueText = string.format("+%d", prop.value)
        uiGo:GetComponent("UILabel"):set_text(valueText)
      end
    end
  else
    list:SetActive(false)
  end
  local cost = self.m_panel:FindDirect("Img_Bg0/Btn_Start/Group_Cost")
  local noCost = self.m_panel:FindDirect("Img_Bg0/Btn_Start/Label")
  if teenData:GetInterest() > 0 then
    cost:SetActive(true)
    noCost:SetActive(false)
    local numLbl = cost:FindDirect("Img_Icon/Label_Num")
    numLbl:GetComponent("UILabel"):set_text(constant.CChildHoodConst.RESET_INTEREST_COST)
  else
    cost:SetActive(false)
    noCost:SetActive(true)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Start" then
    require("Main.Children.mgr.TeenMgr").Instance():ChooseInterest(self.childId)
  end
end
return TeenInterestPanel.Commit()
