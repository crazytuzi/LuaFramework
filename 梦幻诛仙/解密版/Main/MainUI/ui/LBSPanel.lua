local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local ECMSDK = require("ProxySDK.ECMSDK")
local LBSWaitingPanel = require("Main.MainUI.ui.LBSWaitingPanel")
local Vector = require("Types.Vector3")
local ECLuaString = require("Utility.ECFilter")
local LBSPanel = Lplus.Extend(ECPanelBase, "LBSPanel")
local def = LBSPanel.define
def.field("number").m_CurrentIndex = 0
def.field("number").m_ThetaOffset = 0
def.field("table").m_Data = nil
def.field("table").m_TextureData = function()
  return {}
end
def.field("table").m_UIGO = nil
local instance
def.static("=>", LBSPanel).Instance = function()
  if not instance then
    instance = LBSPanel()
  end
  return instance
end
def.static("table", "table").OnLBSNotify = function(p1, p2)
  warn("OnLBSNotify", p1.data)
  if instance.m_panel and not instance.m_panel.isnil then
    instance.m_Data = p1.data
    instance.m_ThetaOffset = instance.m_ThetaOffset + 20
    instance:DestroyPersonObject(false)
    instance:UpdateUI()
  end
  LBSWaitingPanel.Instance():DestroyPanel()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_LBS_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateUI()
  self:UpdateMySelf()
  LBSWaitingPanel.Instance():ShowPanel()
  Event.RegisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.LBSNotify, LBSPanel.OnLBSNotify)
end
def.override().OnDestroy = function(self)
  for k, v in pairs(self.m_TextureData) do
    if v then
      v:Destroy()
    end
    self.m_TextureData[k] = nil
  end
  self:DestroyPersonObject(true)
  self.m_CurrentIndex = 0
  self.m_Data = nil
  self.m_UIGO = nil
  Event.UnregisterEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.LBSNotify, LBSPanel.OnLBSNotify)
end
local multiClick = false
def.method().GetPersonInfo = function(self)
  if multiClick then
    Toast(textRes.RelationShipChain[14])
    return
  end
  multiClick = true
  GameUtil.AddGlobalTimer(5, true, function()
    multiClick = false
  end)
  ECMSDK.GetNearbyPersonInfo()
end
def.method().ShowTip = function(self)
  local index = self.m_CurrentIndex
  local data = self.m_Data[index]
  if not data then
    warn("NO NearBy Player Data", index)
    return
  end
  local personObj = self.m_UIGO.newObj[index]
  if not personObj then
    warn("NO NearBy Player GameObject", index)
    return
  end
  local tipGO = self.m_UIGO.Img_TipBg
  local numGO = tipGO:FindDirect("Label_Nmuber")
  local statusGO = tipGO:FindDirect("Label_Status")
  local distanceGO = tipGO:FindDirect("Label_Distance")
  tipGO.localPosition = personObj.localPosition + Vector.Vector3.new(150, 0, 0)
  local fateValue = data.fateValue
  local status = textRes.RelationShipChain[45]
  if fateValue > 30 and fateValue < 51 then
    status = textRes.RelationShipChain[46]
  elseif fateValue > 50 and fateValue < 81 then
    status = textRes.RelationShipChain[47]
  elseif fateValue > 80 and fateValue < 101 then
    status = textRes.RelationShipChain[48]
  end
  GUIUtils.SetText(numGO, tostring(data.fateValue or 1))
  GUIUtils.SetText(statusGO, status)
  GUIUtils.SetText(distanceGO, textRes.RelationShipChain[51]:format(data.distance))
  GUIUtils.SetActive(tipGO, true)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Change" then
    self:GetPersonInfo()
    LBSWaitingPanel.Instance():ShowPanel()
  elseif id == "Btn_Chengjiu" then
  elseif id:find("Person") == 1 then
    local _, lastIndex = id:find("Person")
    local index = tonumber(id:sub(lastIndex + 1, id:len()))
    self.m_CurrentIndex = index
    self:ShowTip()
  elseif id == "Btn_AddQQ" then
    local data = self.m_Data[self.m_CurrentIndex]
    if not data then
      return
    end
    local desc = textRes.RelationShipChain[49]
    local message = textRes.RelationShipChain[50]
    ECMSDK.AddGameFriendToQQ(data.openId, desc, message)
  elseif id == "Btn_AddFriend" then
  end
  if not id:find("Person") and self.m_UIGO then
    GUIUtils.SetActive(self.m_UIGO.Img_TipBg, false)
  end
end
def.method().InitData = function(self)
end
def.method().InitUI = function(self)
  self.m_UIGO = {}
  self.m_UIGO.newObj = {}
  self.m_UIGO.Img_Other = self.m_panel:FindDirect("Img_Bg0/Img_Other")
  self.m_UIGO.Img_Myself = self.m_panel:FindDirect("Img_Bg0/Img_Myself")
  self.m_UIGO.Btn_Chengjiu = self.m_panel:FindDirect("Img_Bg0/Btn_Chengjiu")
  self.m_UIGO.Img_TipBg = self.m_panel:FindDirect("Img_Bg0/Img_TipBg")
  self.m_UIGO.Btn_AddQQ = self.m_UIGO.Img_TipBg:FindDirect("Btn_AddQQ")
  GUIUtils.SetActive(self.m_UIGO.Img_TipBg, false)
  GUIUtils.SetActive(self.m_UIGO.Img_Other, false)
  local showAddQQFriendBtn = ECMSDK.IsAddGameFriendToQQAvailable()
  GUIUtils.SetActive(self.m_UIGO.Btn_AddQQ, showAddQQFriendBtn)
end
def.method("boolean").DestroyPersonObject = function(self, destroyAll)
  if not self.m_UIGO.newObj then
    return
  end
  if destroyAll then
    for k, v in pairs(self.m_UIGO.newObj) do
      if v and not v.isnil then
        v:Destroy()
      end
    end
  else
    local curNum = self.m_Data and #self.m_Data or 0
    local childGONum = #self.m_UIGO.newObj
    if curNum < childGONum then
      for i = curNum + 1, childGONum do
        local go = self.m_UIGO.newObj[i]
        if go and not go.isnil then
          go:Destroy()
          self.m_UIGO.newObj[i] = nil
        end
      end
    end
  end
end
def.method("number", "number", "=>", "table").CalcRelatePosition = function(self, index, distance)
  local offsetX = math.random(150, 350)
  local offsetY = math.random(150, 200)
  local count = 360 / (#self.m_Data > 10 and 10 or #self.m_Data)
  local theta = index * count
  local targetX = offsetX * math.sin(math.rad(theta + self.m_ThetaOffset))
  local targetY = offsetY * math.cos(math.rad(theta + self.m_ThetaOffset))
  return Vector.Vector3.new(targetX, targetY, 0)
end
def.method().UpdateMySelf = function(self)
  local friendData = require("Main.RelationShipChain.data.RelationShipChainData").Instance():GetFriendData()
  local sdkInfo = ECMSDK.GetMSDKInfo()
  if not sdkInfo then
    return
  end
  local openid = sdkInfo.openId
  local myInfo = friendData[openid]
  if myInfo then
    local mySelfGO = self.m_UIGO.Img_Myself
    local iconGO = mySelfGO:FindDirect("Img_TouXiangIcon")
    local nameGO = mySelfGO:FindDirect("Label_Name")
    local nickname = GetStringFromOcts(myInfo.nickname)
    local strLen, aNum, hNum = ECLuaString.Len(nickname or "")
    if aNum + hNum * 2 > 12 then
      local len = aNum / 2 + hNum > 6 and 6 or aNum / 2 + hNum
      nickname = ECLuaString.SubStr(nickname, 1, len) .. "..."
    end
    local url = require("Main.RelationShipChain.RelationShipChainMgr").ProcessHeadImgURL(myInfo.figure_url)
    GUIUtils.FillTextureFromURL(iconGO, url, function(tex2d)
      self.m_TextureData[0] = tex2d
    end)
    GUIUtils.SetText(nameGO, nickname)
  end
end
def.method().UpdateUI = function(self)
  if not self.m_Data then
    return
  end
  local centerGO = self.m_UIGO.Img_Myself
  local template = self.m_UIGO.Img_Other
  for k, v in pairs(self.m_Data) do
    if k > 10 then
      break
    end
    do
      local personObj = self.m_UIGO.newObj[k]
      if not personObj then
        warn(k, "Instantiate New Object")
        personObj = GameObject.Instantiate(template)
        personObj.name = ("Person%02d"):format(k)
        personObj.parent = template.parent
        personObj.localScale = Vector.Vector3.new(1, 1, 1)
      end
      personObj.localPosition = self:CalcRelatePosition(k, v.distance) + centerGO.localPosition
      self.m_UIGO.newObj[k] = personObj
      local fateValue = math.random(1, 100)
      local iconGO = personObj:FindDirect("Img_TouXiangIcon")
      local nameGO = personObj:FindDirect("Label_Name")
      local numberGO = personObj:FindDirect("Label_Nmuber")
      local nickName = v.nickName
      local strLen, aNum, hNum = ECLuaString.Len(nickName or "")
      if aNum + hNum * 2 > 12 then
        local len = aNum / 2 + hNum > 6 and 6 or aNum / 2 + hNum
        nickName = ECLuaString.SubStr(nickName, 1, len) .. "..."
      end
      GUIUtils.FillTextureFromURL(iconGO, v.pictureSmall, function(tex2d)
        self.m_TextureData[k] = tex2d
      end)
      GUIUtils.SetText(nameGO, nickName)
      GUIUtils.SetText(numberGO, tostring(fateValue))
      GUIUtils.SetActive(personObj, true)
      v.fateValue = fateValue
    end
  end
end
return LBSPanel.Commit()
