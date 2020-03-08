local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MournPanel = Lplus.Extend(ECPanelBase, "MournPanel")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local UIModelWrap = require("Model.UIModelWrap")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local MTaskInfo = require("netio.protocol.mzm.gsp.mourn.MTaskInfo")
local MournMgr = require("Main.activity.Mourn.MournMgr")
local mournMgr = MournMgr.Instance()
local def = MournPanel.define
def.field("table")._modleTable = nil
def.field("number").timerId = 0
def.field("table").mournCfgList = nil
local instance
def.static("=>", MournPanel).Instance = function()
  if instance == nil then
    instance = MournPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_ACTIVITY_QINGMING, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Mourn_Info_Change, MournPanel.OnMournInfoChange)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, MournPanel.OnNewDay)
  self._modleTable = {}
end
def.override().OnDestroy = function(self)
  for k, v in pairs(self._modleTable) do
    v:Destroy()
  end
  self._modleTable = {}
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Mourn_Info_Change, MournPanel.OnMournInfoChange)
  Event.UnregisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, MournPanel.OnNewDay)
end
def.static("table", "table").OnMournInfoChange = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setMournInfo()
  end
end
def.static("table", "table").OnNewDay = function(p1, p2)
  if instance and instance:IsShow() then
    local p = require("netio.protocol.mzm.gsp.mourn.CGetMournReq").new()
    gmodule.network.sendProtocol(p)
  end
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self:setMournInfo()
    self:setAwardInfo()
    if self.timerId == 0 then
      self.timerId = GameUtil.AddGlobalTimer(1, false, function()
        self:setRefreshTime()
      end)
    end
    local mournList = MournMgr.GetAllMournCfg()
    if mournMgr.isNeedRefresh or #mournList == 0 then
      local p = require("netio.protocol.mzm.gsp.mourn.CGetMournReq").new()
      gmodule.network.sendProtocol(p)
    end
  else
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("-------Mourn clickObj:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Btn_Light" then
    if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MOURN) then
      Toast(textRes.activity[407])
      return
    end
    local curNum = mournMgr:getMournNum()
    if curNum >= constant.CMournConsts.countMax then
      if mournMgr.questionTaskState == MTaskInfo.UN_ACCEPTED then
        self:Hide()
        Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_GotoNPC, {
          constant.CMournConsts.npcId
        })
      elseif mournMgr.questionTaskState == MTaskInfo.ALREADY_ACCEPTED then
        Toast(textRes.activity[606])
      elseif mournMgr.questionTaskState == MTaskInfo.FINISHED then
        Toast(textRes.activity[602])
      end
    else
      Toast(textRes.activity[601])
    end
  elseif strs[1] == "Btn" and strs[2] == "Fete" then
    if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MOURN) then
      Toast(textRes.activity[407])
      return
    end
    local taskInterface = require("Main.task.TaskInterface").Instance()
    for i, v in pairs(self.mournCfgList) do
      if taskInterface:isOwnTaskByGraphId(v.graphId) then
        Toast(textRes.activity[605])
        return
      end
    end
    local idx = tonumber(strs[3])
    if idx then
      local mournCfg = self.mournCfgList[idx]
      if mournCfg then
        local p = require("netio.protocol.mzm.gsp.mourn.CMournReq").new(mournCfg.id)
        gmodule.network.sendProtocol(p)
        warn("--------Mourn Id:", mournCfg.id)
        self:Hide()
      end
    end
  elseif strs[1] == "item" then
    local idx = tonumber(strs[2])
    if idx then
      local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(constant.CMournConsts.questionAwardId)
      local itemInfo = awardCfg.itemList[idx]
      if itemInfo then
        self:ShowTipsEx(itemInfo.itemId, clickObj)
      end
    end
  end
end
def.method("number", "userdata").ShowTipsEx = function(self, itemId, obj)
  local position = obj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local com = obj:GetComponent("UIWidget")
  if com == nil then
    return
  end
  ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, com:get_width(), com:get_height(), 0, true)
end
def.method().setRefreshTime = function(self)
  local Label_Time = self.m_panel:FindDirect("Img_Bg0/Label_Time")
  Label_Time:GetComponent("UILabel"):set_text(mournMgr:getRefreshTimeStr())
end
def.method().setMournInfo = function(self)
  self:setRefreshTime()
  local Label_Num = self.m_panel:FindDirect("Img_Bg0/Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(mournMgr:getMournNum())
  local Btn_Light = self.m_panel:FindDirect("Img_Bg0/Btn_Light")
  local curNum = mournMgr:getMournNum()
  if curNum >= constant.CMournConsts.countMax and mournMgr.questionTaskState == MTaskInfo.UN_ACCEPTED then
    GUIUtils.SetLightEffect(Btn_Light, GUIUtils.Light.Round)
  else
    GUIUtils.SetLightEffect(Btn_Light, GUIUtils.Light.None)
  end
  local mournList = MournMgr.GetAllMournCfg()
  self.mournCfgList = mournList
  local list = self.m_panel:FindDirect("Img_Bg0/List")
  local uiList = list:GetComponent("UIList")
  uiList.itemCount = #mournList
  uiList:Resize()
  for i, v in ipairs(mournList) do
    local Img_BgChar = list:FindDirect("Img_BgChar_" .. i)
    local Label_Title = Img_BgChar:FindDirect(string.format("Img_Cover_%d/Label_Title_%d", i, i))
    local Label_Intro = Img_BgChar:FindDirect("Label_Intro_" .. i)
    Label_Title:GetComponent("UILabel"):set_text(v.deadName)
    Label_Intro:GetComponent("UILabel"):set_text(v.story)
    local Btn_Fete = Img_BgChar:FindDirect("Btn_Fete_" .. i)
    local uiBtnFete = Btn_Fete:GetComponent("UIButton")
    local label_State = Img_BgChar:FindDirect("label_State_" .. i)
    local curState = mournMgr:getMournState(v.id)
    if curState == MTaskInfo.UN_ACCEPTED then
      uiBtnFete.isEnabled = true
      Btn_Fete:SetActive(true)
      label_State:SetActive(false)
    else
      Btn_Fete:SetActive(false)
      label_State:SetActive(true)
      if curState == MTaskInfo.ALREADY_ACCEPTED then
        label_State:GetComponent("UILabel"):set_text(textRes.activity[607])
      else
        label_State:GetComponent("UILabel"):set_text(textRes.activity[50])
      end
    end
    local wrap = self._modleTable[i]
    if wrap == nil or wrap._theUIModle.isnil then
      local uiModel = Img_BgChar:FindDirect("Model_" .. i):GetComponent("UIModel")
      wrap = UIModelWrap.new(uiModel)
      self._modleTable[i] = wrap
    end
    local modelinfo = DynamicData.GetRecord(CFG_PATH.DATA_MODEL_CONFIG, v.modelId)
    local headidx = DynamicRecord.GetIntValue(modelinfo, "halfBodyIconId")
    local iconRecord = DynamicData.GetRecord(CFG_PATH.DATA_ICONRES, headidx)
    if iconRecord then
      local resourcePath = iconRecord:GetStringValue("path")
      if resourcePath and resourcePath ~= "" then
        wrap:Load(resourcePath .. ".u3dext")
      else
        warn("---------model resourcePath no exit:", v.modelId)
      end
    end
  end
end
def.method().setAwardInfo = function(self)
  local awardCfg = ItemUtils.GetGiftAwardCfgByAwardId(constant.CMournConsts.questionAwardId)
  local List_Item = self.m_panel:FindDirect("Img_Bg0/List_Item")
  local uiList = List_Item:GetComponent("UIList")
  uiList.itemCount = #awardCfg.itemList
  uiList:Resize()
  for i, v in ipairs(awardCfg.itemList) do
    local Item = List_Item:FindDirect("item_" .. i)
    local Img_Icon = Item:FindDirect("Img_Icon")
    local uiTexture = Img_Icon:GetComponent("UITexture")
    local itemBase = ItemUtils.GetItemBase(v.itemId)
    GUIUtils.FillIcon(uiTexture, itemBase.icon)
    local Label_Num = Item:FindDirect("Label_Num")
    Label_Num:GetComponent("UILabel"):set_text(v.num)
  end
end
return MournPanel.Commit()
