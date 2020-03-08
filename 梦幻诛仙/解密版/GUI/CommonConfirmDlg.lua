local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local CommonConfirmDlg = Lplus.Extend(ECPanelBase, "CommonConfirmDlg")
local EC = require("Types.Vector3")
local def = CommonConfirmDlg.define
local getPanelLevelByTag = function(tag)
  return tag and getmetatable(tag) == nil and tag.m_level or 2
end
local getUniqueByTag = function(tag)
  return tag and tag.unique or nil
end
local UniqueMap = {}
setmetatable(UniqueMap, {__mode = "kv"})
def.static("dynamic", "=>", CommonConfirmDlg).GetInstanceByUnique = function(tag)
  return UniqueMap[tag]
end
def.static("string", "string", "string", "string", "number", "number", "function", "table", "=>", ECPanelBase).ShowConfirmCoundDown = function(title, content, btn1, btn0, default, countDown, callback, tag)
  local commonConfirmDlg = CommonConfirmDlg()
  local unique = getUniqueByTag(tag)
  if unique then
    if UniqueMap[unique] and UniqueMap[unique].m_created then
      return nil
    else
      UniqueMap[unique] = commonConfirmDlg
    end
  end
  commonConfirmDlg.callback = callback
  commonConfirmDlg.callBackDone = false
  commonConfirmDlg.title = title
  commonConfirmDlg.content = content
  commonConfirmDlg.tag = tag
  commonConfirmDlg.type = 0
  commonConfirmDlg.btn1 = btn1
  commonConfirmDlg.btn0 = btn0
  commonConfirmDlg.default = default
  commonConfirmDlg.countDown = countDown
  local level = getPanelLevelByTag(tag)
  commonConfirmDlg:CreatePanel(RESPATH.DLG_COMMONCOMFIRM, level)
  commonConfirmDlg:SetModal(true)
  commonConfirmDlg:SetDepth(4)
  return commonConfirmDlg
end
def.static("string", "string", "function", "table", "=>", ECPanelBase).ShowConfirm = function(title, content, callback, tag)
  local commonConfirmDlg = CommonConfirmDlg()
  local unique = getUniqueByTag(tag)
  if unique then
    if UniqueMap[unique] and UniqueMap[unique].m_created then
      return nil
    else
      UniqueMap[unique] = commonConfirmDlg
    end
  end
  commonConfirmDlg.callback = callback
  commonConfirmDlg.callBackDone = false
  commonConfirmDlg.title = title
  commonConfirmDlg.content = content
  commonConfirmDlg.tag = tag
  commonConfirmDlg.type = 0
  local level = getPanelLevelByTag(tag)
  commonConfirmDlg:CreatePanel(RESPATH.DLG_COMMONCOMFIRM, level)
  commonConfirmDlg:SetModal(true)
  commonConfirmDlg:SetDepth(4)
  return commonConfirmDlg
end
def.static("string", "string", "string", "string", "function", "table", "=>", ECPanelBase).ShowConfirmEx = function(title, content, btn1, btn0, callback, tag)
  local commonConfirmDlg = CommonConfirmDlg()
  local unique = getUniqueByTag(tag)
  if unique then
    if UniqueMap[unique] and UniqueMap[unique].m_created then
      return nil
    else
      UniqueMap[unique] = commonConfirmDlg
    end
  end
  commonConfirmDlg.callback = callback
  commonConfirmDlg.callBackDone = true
  commonConfirmDlg.title = title
  commonConfirmDlg.content = content
  commonConfirmDlg.btn1 = btn1
  commonConfirmDlg.btn0 = btn0
  commonConfirmDlg.tag = tag
  commonConfirmDlg.type = 0
  local level = getPanelLevelByTag(tag)
  commonConfirmDlg:CreatePanel(RESPATH.DLG_COMMONCOMFIRM, level)
  commonConfirmDlg:SetModal(true)
  commonConfirmDlg:SetDepth(4)
  return commonConfirmDlg
end
def.static("string", "string", "string", "function", "table", "=>", ECPanelBase).ShowCerternConfirm = function(title, content, btn2, callback, tag)
  local commonConfirmDlg = CommonConfirmDlg()
  local unique = getUniqueByTag(tag)
  if unique then
    if UniqueMap[unique] and UniqueMap[unique].m_created then
      return nil
    else
      UniqueMap[unique] = commonConfirmDlg
    end
  end
  commonConfirmDlg.callback = callback
  commonConfirmDlg.callBackDone = false
  commonConfirmDlg.title = title
  commonConfirmDlg.content = content
  commonConfirmDlg.tag = tag
  commonConfirmDlg.type = 2
  commonConfirmDlg.btn2 = btn2
  local level = getPanelLevelByTag(tag)
  commonConfirmDlg:CreatePanel(RESPATH.DLG_COMMONCOMFIRM, level)
  commonConfirmDlg:SetModal(true)
  commonConfirmDlg:SetDepth(4)
  return commonConfirmDlg
end
def.field("function").callback = nil
def.field("number").iconId = -1
def.field("string").title = ""
def.field("string").content = ""
def.field("string").des1 = ""
def.field("string").des2 = ""
def.field("string").btn1 = ""
def.field("string").btn0 = ""
def.field("string").btn2 = ""
def.field("number").countDown = 0
def.field("number").default = 0
def.field("string").atlasName = ""
def.field("string").iconName = ""
def.field("table").tag = nil
def.field("number").type = 0
def.field("string").panelName = ""
def.field("number").countDownTimer = 0
def.field("boolean").callBackDone = false
def.field("boolean").closeBtn = false
def.override().OnCreate = function(self)
  self:UpdateText()
  if self.type ~= 0 and self.type ~= 2 then
    self:UpdateDescription()
  end
  if self.type == 1 then
    self:UpdateIcon()
  end
  self:UpdateButton()
  self:rename(self.panelName)
end
def.override().OnDestroy = function(self)
  if self.countDownTimer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.countDownTimer)
    self.countDownTimer = 0
  end
  local unique = getUniqueByTag(self.tag)
  if unique then
    UniqueMap[unique] = nil
  end
  if not self.callBackDone and self.callback then
    self.callback(-1, self.tag)
  end
end
def.method("string").rename = function(self, name)
  if name == "" then
    return
  end
  if self.m_panel ~= nil then
    self.m_panel.name = name
    self.m_panelName = name
  else
    self.panelName = name
  end
end
def.method().UpdateText = function(self)
  local title = self.m_panel:FindDirect("Img_0/Label_Title"):GetComponent("UILabel")
  title:set_text(self.title)
  local contentLabel = self.m_panel:FindDirect("Img_0/Img_BgWords/Label"):GetComponent("UILabel")
  contentLabel:set_text(self.content)
end
def.method().UpdateDescription = function(self)
  local des1 = self.m_panel:FindDirect("Img_0/Label_ItemName"):GetComponent("UILabel")
  local des2 = self.m_panel:FindDirect("Img_0/Label_ItemNum"):GetComponent("UILabel")
  des1:set_text(self.des1)
  des2:set_text(self.des2)
end
def.method().UpdateIcon = function(self)
  local uiTexture = self.m_panel:FindDirect("Img_0/Img_BgItem/Img_IconItem"):GetComponent("UITexture")
  GUIUtils.FillIcon(uiTexture, self.iconId)
end
def.method().UpdateButton = function(self)
  if self.type == 2 then
    self:UpdateCerternButton()
    return
  end
  if self.btn1 == "" then
    self.btn1 = self.m_panel:FindDirect("Img_0/Btn_Confirm/Label_Confirm"):GetComponent("UILabel"):get_text()
  elseif self.btn1 == "nil" then
    self.m_panel:FindDirect("Img_0/Btn_Confirm"):SetActive(false)
    local prePos = self.m_panel:FindDirect("Img_0/Btn_Cancel").localPosition
    self.m_panel:FindDirect("Img_0/Btn_Cancel").localPosition = EC.Vector3.new(0, prePos.y, prePos.z)
  else
    self.m_panel:FindDirect("Img_0/Btn_Confirm/Label_Confirm"):GetComponent("UILabel"):set_text(self.btn1)
  end
  if self.btn0 == "" then
    self.btn0 = self.m_panel:FindDirect("Img_0/Btn_Cancel/Label_Cancel"):GetComponent("UILabel"):get_text()
  elseif self.btn0 == "nil" then
    self.m_panel:FindDirect("Img_0/Btn_Cancel"):SetActive(false)
    local prePos = self.m_panel:FindDirect("Img_0/Btn_Confirm").localPosition
    self.m_panel:FindDirect("Img_0/Btn_Confirm").localPosition = EC.Vector3.new(0, prePos.y, prePos.z)
  else
    self.m_panel:FindDirect("Img_0/Btn_Cancel/Label_Cancel"):GetComponent("UILabel"):set_text(self.btn0)
  end
  self:UpdateCloseBtn()
  if 0 < self.countDown then
    do
      local countDown = self.countDown
      local startTime = GameUtil.GetTickCount()
      if self.default == 1 then
        self.m_panel:FindDirect("Img_0/Btn_Cancel/Label_Cancel"):GetComponent("UILabel"):set_text(self.btn0)
        do
          local btnLabel = self.m_panel:FindDirect("Img_0/Btn_Confirm/Label_Confirm"):GetComponent("UILabel")
          btnLabel:set_text(self.btn1 .. string.format("(%d)", countDown))
          self.countDownTimer = GameUtil.AddGlobalTimer(1, false, function()
            local curTime = GameUtil.GetTickCount()
            local leftSeconds = countDown - math.floor((curTime - startTime) / 1000)
            if leftSeconds < 0 then
              if self.callback ~= nil then
                self.callBackDone = true
                self.callback(1, self.tag)
              end
              GameUtil.RemoveGlobalTimer(self.countDownTimer)
              self.countDownTimer = 0
              self:DestroyPanel()
              self = nil
            else
              btnLabel:set_text(self.btn1 .. string.format("(%d)", leftSeconds))
            end
          end)
        end
      elseif self.default == 0 then
        self.m_panel:FindDirect("Img_0/Btn_Confirm/Label_Confirm"):GetComponent("UILabel"):set_text(self.btn1)
        do
          local btnLabel = self.m_panel:FindDirect("Img_0/Btn_Cancel/Label_Cancel"):GetComponent("UILabel")
          btnLabel:set_text(self.btn0 .. string.format("(%d)", countDown))
          self.countDownTimer = GameUtil.AddGlobalTimer(1, false, function()
            local curTime = GameUtil.GetTickCount()
            local leftSeconds = countDown - math.floor((curTime - startTime) / 1000)
            if leftSeconds < 0 then
              if self.callback ~= nil then
                self.callBackDone = true
                self.callback(0, self.tag)
              end
              GameUtil.RemoveGlobalTimer(self.countDownTimer)
              self.countDownTimer = 0
              self:DestroyPanel()
              self = nil
            else
              btnLabel:set_text(self.btn0 .. string.format("(%d)", leftSeconds))
            end
          end)
        end
      end
    end
  end
end
def.method().UpdateCerternButton = function(self)
  local Btn_Special = self.m_panel:FindDirect("Img_0/Btn_Special")
  local Btn_Confirm = self.m_panel:FindDirect("Img_0/Btn_Confirm")
  local Btn_Cancel = self.m_panel:FindDirect("Img_0/Btn_Cancel")
  Btn_Special:SetActive(true)
  Btn_Confirm:SetActive(false)
  Btn_Cancel:SetActive(false)
  local label = self.m_panel:FindDirect("Img_0/Btn_Special/Label_Cancel"):GetComponent("UILabel")
  if self.btn2 == "" then
    self.btn2 = label:get_text()
  end
  label:set_text(self.btn2)
end
def.method("string").onClick = function(self, id)
  print("Easy Click:", id)
  if id == "Btn_Confirm" then
    if self.callback ~= nil then
      self.callBackDone = true
      self.callback(1, self.tag)
    end
    GameUtil.RemoveGlobalTimer(self.countDownTimer)
    self.countDownTimer = 0
    self:DestroyPanel()
    self = nil
  elseif id == "Btn_Cancel" then
    if self.callback ~= nil then
      self.callBackDone = true
      self.callback(0, self.tag)
    end
    GameUtil.RemoveGlobalTimer(self.countDownTimer)
    self.countDownTimer = 0
    self:DestroyPanel()
    self = nil
  elseif id == "Btn_Special" then
    if self.callback ~= nil then
      self.callBackDone = true
      self.callback(self.tag)
    end
    self:DestroyPanel()
    self = nil
  elseif id == "Btn_Close" then
    GameUtil.RemoveGlobalTimer(self.countDownTimer)
    self.countDownTimer = 0
    self:DestroyPanel()
    self = nil
  end
end
def.method().ShowCloseBtn = function(self)
  self.closeBtn = true
  if self.m_panel and self.m_panel.isnil == false then
    self:UpdateCloseBtn()
  end
end
def.method().UpdateCloseBtn = function(self)
  local Btn_Close = self.m_panel:FindDirect("Img_0/Btn_Close")
  GUIUtils.SetActive(Btn_Close, self.closeBtn)
end
CommonConfirmDlg.Commit()
return CommonConfirmDlg
