local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ECMSDK = require("ProxySDK.ECMSDK")
local NewFunctionForecast = Lplus.Extend(ECPanelBase, "NewFunctionForecast")
local Vector = require("Types.Vector")
local def = NewFunctionForecast.define
local instance
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.static("=>", NewFunctionForecast).Instance = function()
  if instance == nil then
    instance = NewFunctionForecast()
    instance:Init()
  end
  return instance
end
local newFunctionData = require("Main.Grow.NewFunctionData").Instance()
local FunctionOpenInfo = require("netio.protocol.mzm.gsp.grow.FunctionOpenInfo")
def.field("table")._allcfgs = nil
def.field("table")._cfgs = nil
def.field("number")._currIndex = 0
def.method().Init = function(self)
  self.m_TrigGC = true
end
def.method("table").ShowDlg = function(self, cfgs)
  self._allcfgs = cfgs
  if self.m_panel == nil or self.m_panel.isnil then
    self:CreatePanel(RESPATH.PREFAB_NEW_FUNCTION_TIP, 1)
    self:SetOutTouchDisappear()
  end
  if self:IsShow() == true then
    self:RefreshData()
    self:Fill()
    GameUtil.AddGlobalTimer(0, true, function()
      GameUtil.AddGlobalTimer(0, true, function()
        GameUtil.AddGlobalTimer(0, true, function()
          self:_DragToMakeVisible(self._currIndex)
        end)
      end)
    end)
  end
end
def.method().HideDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.NewFunction_Changed, NewFunctionForecast.OnNewFunctionChanged)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.GROW, gmodule.notifyId.Grow.NewFunction_Changed, NewFunctionForecast.OnNewFunctionChanged)
end
def.method().RefreshData = function(self)
  if self:IsShow() == false then
    return
  end
  self._cfgs = {}
  local beginIdx = -1
  local endLevel = -1
  for idx, cfg in pairs(self._allcfgs) do
    local targetState = newFunctionData._newFunctionInfo[cfg.id]
    if targetState == nil then
      break
    end
    if targetState == FunctionOpenInfo.ST_FINISHED and beginIdx <= 0 then
      beginIdx = idx
    end
    if targetState == FunctionOpenInfo.ST_ON_GOING and endLevel <= 0 then
      endLevel = cfg.openLevel
    end
    if endLevel > 0 and endLevel < cfg.openLevel then
      break
    end
    if beginIdx > 0 or endLevel > 0 then
      table.insert(self._cfgs, cfg)
    end
  end
  if beginIdx < 0 and endLevel < 0 then
    self:HideDlg()
    return
  end
  self._currIndex = 1
  for idx, cfg in pairs(self._cfgs) do
    local targetState = newFunctionData._newFunctionInfo[cfg.id]
    if targetState == FunctionOpenInfo.ST_FINISHED then
      self._currIndex = idx
      break
    end
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == true then
    self:RefreshData()
    self:Fill()
    GameUtil.AddGlobalTimer(0, true, function()
      GameUtil.AddGlobalTimer(0, true, function()
        GameUtil.AddGlobalTimer(0, true, function()
          self:_DragToMakeVisible(self._currIndex)
        end)
      end)
    end)
  else
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Left" then
    self:_OnLeft()
    return
  elseif id == "Btn_Right" then
    self:_OnRight()
    return
  end
  local strs = string.split(id, "_")
  if strs[1] == "Btn" and strs[2] == "Confirm" and tonumber(strs[3]) ~= nil then
    local index = tonumber(strs[3])
    self:_OnConfirm(index)
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.NEWFUCNTION, {
      self._cfgs[index].id,
      1
    })
  elseif strs[1] == "Btn" and strs[2] == "Get" and tonumber(strs[3]) ~= nil then
    self:_OnBtn_Get(tonumber(strs[3]))
  elseif strs[1] == "Img" and strs[2] == "BgIcon" and tonumber(strs[3]) ~= nil then
    local idx = tonumber(strs[3])
    self:_ShowAwardTips(idx)
  else
    local index = tonumber(strs[3])
    if self._cfgs[index] and self._cfgs[index].id then
      ECMSDK.SendTLogToServer(_G.TLOGTYPE.NEWFUCNTION, {
        self._cfgs[index].id,
        0
      })
    end
  end
end
def.method().Fill = function(self)
  if self:IsShow() == false then
    return
  end
  local List = self.m_panel:FindDirect("ScrollView/List")
  local list = List:GetComponent("UIList")
  local count = #self._cfgs
  list.itemCount = count
  list:Resize()
  for i = 1, count do
    local cfg = self._cfgs[i]
    local targetState = newFunctionData._newFunctionInfo[cfg.id]
    local Img_Bg0 = List:FindDirect(string.format("Img_Bg0_%d", i))
    local Label_Tilte = Img_Bg0:FindDirect(string.format("Group_Title_%d/Label_Tilte_%d", i, i))
    Label_Tilte:GetComponent("UILabel"):set_text(cfg.title)
    local Group_Content = Img_Bg0:FindDirect(string.format("Group_Content_%d", i))
    local Label_Describe = Group_Content:FindDirect(string.format("Label_Describe_%d", i))
    Label_Describe:GetComponent("UILabel"):set_text(cfg.goalDes)
    local Texture = Group_Content:FindDirect(string.format("Img_BgIcon_%d/Texture_%d", i, i))
    local uiTexture = Texture:GetComponent("UITexture")
    local itemBase = ItemUtils.GetItemBase2(cfg.itemId)
    if itemBase ~= nil then
      GUIUtils.FillIcon(uiTexture, itemBase.icon)
    else
      local itemSiftCfg = ItemUtils.GetItemFilterCfg(cfg.itemId)
      GUIUtils.FillIcon(uiTexture, itemSiftCfg.icon)
    end
    local Label_Lv = Group_Content:FindDirect(string.format("Label_Lv_%d", i))
    if targetState == FunctionOpenInfo.ST_ON_GOING then
      Label_Lv:GetComponent("UILabel"):set_text("[e60000]" .. string.format(textRes.Grow[30], cfg.openLevel) .. "[-]")
    elseif targetState == FunctionOpenInfo.ST_FINISHED then
      Label_Lv:GetComponent("UILabel"):set_text("[009c42]" .. string.format(textRes.Grow[30], cfg.openLevel) .. "[-]")
    else
      Label_Lv:GetComponent("UILabel"):set_text("[009c42]" .. textRes.Grow[32] .. "[-]")
    end
    local Btn_Confirm = Img_Bg0:FindDirect(string.format("Btn_Confirm_%d", i))
    local Btn_Get = Img_Bg0:FindDirect(string.format("Btn_Get_%d", i))
    Btn_Confirm:SetActive(targetState ~= FunctionOpenInfo.ST_FINISHED)
    Btn_Get:SetActive(targetState == FunctionOpenInfo.ST_FINISHED)
    self.m_msgHandler:Touch(Img_Bg0)
  end
end
def.method().Refresh = function(self)
  if self:IsShow() == false then
    return
  end
  local List = self.m_panel:FindDirect("ScrollView/List")
  local list = List:GetComponent("UIList")
  local count = #self._cfgs
  for i = 1, count do
    local cfg = self._cfgs[i]
    local Img_Bg0 = List:FindDirect(string.format("Img_Bg0_%d", i))
    local Btn_Confirm = Img_Bg0:FindDirect(string.format("Btn_Confirm_%d", i))
    local Btn_Get = Img_Bg0:FindDirect(string.format("Btn_Get_%d", i))
    local targetState = newFunctionData._newFunctionInfo[cfg.id]
    Btn_Confirm:SetActive(targetState ~= FunctionOpenInfo.ST_FINISHED)
    Btn_Get:SetActive(targetState == FunctionOpenInfo.ST_FINISHED)
  end
end
def.method("number")._OnBtn_Get = function(self, idx)
  local cfg = self._cfgs[idx]
  local p = require("netio.protocol.mzm.gsp.grow.CGetFunctionOpenAwardReq").new(cfg.id)
  gmodule.network.sendProtocol(p)
end
def.method("number")._OnConfirm = function(self, idx)
  self:HideDlg()
  local cfg = self._cfgs[idx]
  local targetState = newFunctionData._newFunctionInfo[cfg.id]
  if targetState == FunctionOpenInfo.ST_ON_GOING then
    Toast(textRes.MainUI[5])
  end
end
def.method()._OnLeft = function(self)
  if self._currIndex > 1 then
    self._currIndex = self._currIndex - 1
    self:_DragToMakeVisible(self._currIndex)
  end
end
def.method()._OnRight = function(self)
  local count = #self._cfgs
  if count > self._currIndex then
    self._currIndex = self._currIndex + 1
    self:_DragToMakeVisible(self._currIndex)
  end
end
def.method("number")._DragToMakeVisible = function(self, idx)
  if self:IsShow() == false then
    return
  end
  local ScrollView = self.m_panel:FindDirect("ScrollView")
  local uiScrollView = ScrollView:GetComponent("UIScrollView")
  local List = ScrollView:FindDirect("List")
  local Img_Bg0 = List:FindDirect(string.format("Img_Bg0_%d", idx))
  uiScrollView:DragToMakeVisible(Img_Bg0.transform, 10)
end
def.static("table", "table").OnNewFunctionChanged = function(p1, p2)
  instance:RefreshData()
  instance:Fill()
end
def.method("number")._ShowAwardTips = function(self, idx)
  local cfg = self._cfgs[idx]
  local List = self.m_panel:FindDirect("ScrollView/List")
  local list = List:GetComponent("UIList")
  local Img_Bg0 = List:FindDirect(string.format("Img_Bg0_%d", idx))
  local Group_Content = Img_Bg0:FindDirect(string.format("Group_Content_%d", idx))
  local Img_BgIcon = Group_Content:FindDirect(string.format("Img_BgIcon_%d", idx))
  local position = Img_BgIcon:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local sprite = Img_BgIcon:GetComponent("UISprite")
  local itemBase = ItemUtils.GetItemBase2(cfg.itemId)
  if itemBase ~= nil then
    ItemTipsMgr.Instance():ShowBasicTips(cfg.itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
  else
    ItemTipsMgr.Instance():ShowItemFilterTips(cfg.itemId, screenPos.x, screenPos.y, sprite:get_width(), sprite:get_height(), 0, false)
  end
end
NewFunctionForecast.Commit()
return NewFunctionForecast
