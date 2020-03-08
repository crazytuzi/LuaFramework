local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local RobWomenDlg = Lplus.Extend(ECPanelBase, "RobWomenDlg")
local ECUIModel = require("Model.ECUIModel")
local EC = require("Types.Vector3")
local def = RobWomenDlg.define
local instance
def.static("=>", RobWomenDlg).Instance = function()
  if instance == nil then
    instance = RobWomenDlg()
  end
  return instance
end
def.field("number").goodNum = 0
def.field("number").badNum = 0
def.field("number").endTime = 0
def.field("table").badModel = nil
def.field("table").goodModel = nil
def.field("table").girlModel = nil
def.field("string").badName = ""
def.field("string").girlName = ""
def.field("string").goodName = ""
def.field("userdata").id1 = nil
def.field("userdata").id2 = nil
def.field("number").timer = 0
def.method("number", "number", "number", "string", "string", "string", "userdata", "userdata").ShowRobWomen = function(self, good, bad, endTime, goodName, girlName, badName, id1, id2)
  self.goodNum = good
  self.badNum = bad
  self.endTime = endTime
  self.goodName = goodName
  self.girlName = girlName
  self.badName = badName
  self.id1 = id1
  self.id2 = id2
  if self:IsShow() then
    self:UpdateAll()
  else
    self:CreatePanel(RESPATH.PREFAB_ROBWOMEN, 1)
  end
end
def.method("number", "number", "userdata").SetRobWomenNum = function(self, good, bad, id)
  if self:IsShow() and (id == self.id1 or id == self.id2) then
    self.goodNum = good
    self.badNum = bad
    self:TweenPos()
    self:UpdateNum()
    self:UpdateBtn()
    if math.abs(self.goodNum - self.badNum) >= constant.CMassWeddingConsts.supportSub then
      self:UpdateTime()
    end
  end
end
def.override().OnCreate = function(self)
  self:CreateModel()
  self:UpdateAll()
end
def.override().OnDestroy = function(self)
  self:DestroyModel()
  GameUtil.RemoveGlobalTimer(self.timer)
  self.timer = 0
  require("Main.Marriage.MultiWeddingMgr").Instance():CancelRobWomen(self.id1)
end
def.method().CreateModel = function(self)
  if self.badModel == nil then
    local modelId = 700301011
    self.badModel = ECUIModel.new(modelId)
    local modelPath = GetModelPath(modelId)
    self.badModel:LoadUIModel(modelPath, function(ret)
      if ret == nil then
        return
      end
      if self:IsShow() then
        local uiModel = self.m_panel:FindDirect("Img_bg0/Group_Model/Model_Player"):GetComponent("UIModel")
        uiModel.modelGameObject = self.badModel.m_model
        uiModel.mCanOverflow = true
        local camera = uiModel:get_modelCamera()
        if camera then
          camera:set_orthographic(true)
        end
      end
    end)
  end
  if self.goodModel == nil then
    local modelId = 700300129
    self.goodModel = ECUIModel.new(modelId)
    local modelPath = GetModelPath(modelId)
    self.goodModel:LoadUIModel(modelPath, function(ret)
      if ret == nil then
        return
      end
      if self:IsShow() then
        local uiModel = self.m_panel:FindDirect("Img_bg0/Group_Model/Model_Husband"):GetComponent("UIModel")
        uiModel.modelGameObject = self.goodModel.m_model
        uiModel.mCanOverflow = true
        local camera = uiModel:get_modelCamera()
        if camera then
          camera:set_orthographic(true)
        end
      end
    end)
  end
  if self.girlModel == nil then
    local modelId = 700300130
    self.girlModel = ECUIModel.new(modelId)
    local modelPath = GetModelPath(modelId)
    self.girlModel:LoadUIModel(modelPath, function(ret)
      if ret == nil then
        return
      end
      if self:IsShow() then
        local uiModel = self.m_panel:FindDirect("Img_bg0/Group_Model/Model_Wife"):GetComponent("UIModel")
        uiModel.modelGameObject = self.girlModel.m_model
        uiModel.mCanOverflow = true
        local camera = uiModel:get_modelCamera()
        if camera then
          camera:set_orthographic(true)
        end
      end
    end)
  end
end
def.method().DestroyModel = function(self)
  if self.badModel ~= nil then
    self.badModel:Destroy()
    self.badModel = nil
  end
  if self.goodModel ~= nil then
    self.goodModel:Destroy()
    self.goodModel = nil
  end
  if self.girlModel ~= nil then
    self.girlModel:Destroy()
    self.girlModel = nil
  end
end
def.method().UpdateAll = function(self)
  self:UpdateTime()
  self:UpdateNum()
  self:UpdateBtn()
  self:UpdateName()
  self:UpdatePos()
end
def.method().UpdateName = function(self)
  local name1 = self.m_panel:FindDirect("Img_bg0/Group_Model/Label")
  local name2 = self.m_panel:FindDirect("Img_bg0/Group_Model/Model_Wife/Label_WifeName")
  local name3 = self.m_panel:FindDirect("Img_bg0/Group_Model/Label_HusbandName")
  name1:GetComponent("UILabel"):set_text(self.badName)
  name2:GetComponent("UILabel"):set_text(self.girlName)
  name3:GetComponent("UILabel"):set_text(self.goodName)
end
def.method().UpdateTime = function(self)
  if self.timer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timer)
    self.timer = 0
  end
  local time = self.m_panel:FindDirect("Img_bg0/Label_Time")
  local timeLbl = time:GetComponent("UILabel")
  if self.goodNum - self.badNum >= constant.CMassWeddingConsts.supportSub then
    timeLbl:set_text(textRes.Marriage[124])
  elseif self.badNum - self.goodNum >= constant.CMassWeddingConsts.supportSub then
    timeLbl:set_text(textRes.Marriage[123])
  else
    local left = self.endTime - GetServerTime()
    if not (left > 0) or not left then
      left = 0
    end
    timeLbl:set_text(string.format(textRes.Marriage[64], left))
    self.timer = GameUtil.AddGlobalTimer(1, false, function()
      local left = self.endTime - GetServerTime()
      if not (left > 0) or not left then
        left = 0
      end
      if timeLbl and not timeLbl.isnil then
        timeLbl:set_text(string.format(textRes.Marriage[64], left))
      end
      if left <= 0 then
        GameUtil.RemoveGlobalTimer(self.timer)
        self.timer = 0
      end
    end)
  end
end
def.method().UpdateNum = function(self)
  local num1 = self.m_panel:FindDirect("Img_bg0/Label_Number_1")
  local lbl1 = num1:GetComponent("UILabel")
  lbl1:set_text(tostring(self.badNum))
  local num2 = self.m_panel:FindDirect("Img_bg0/Label_Number_2")
  local lbl2 = num2:GetComponent("UILabel")
  lbl2:set_text(tostring(self.goodNum))
end
def.method().UpdateBtn = function(self)
  local btnLeft = self.m_panel:FindDirect("Img_bg0/Btn_Qiang")
  local btnRight = self.m_panel:FindDirect("Img_bg0/Btn_Bang")
  local MultiWeddingMgr = require("Main.Marriage.MultiWeddingMgr")
  local leftSupported = MultiWeddingMgr.Instance():HasSupperted(self.id2)
  local rightSupported = MultiWeddingMgr.Instance():HasSupperted(self.id1)
  warn("leftSupported", leftSupported, "rightSupported", rightSupported)
  if leftSupported and rightSupported then
    btnLeft:SetActive(true)
    btnLeft:FindDirect("Img_Open"):SetActive(true)
    btnRight:SetActive(true)
    btnRight:FindDirect("Img_Open"):SetActive(true)
  elseif leftSupported then
    btnLeft:SetActive(true)
    btnLeft:FindDirect("Img_Open"):SetActive(true)
    btnRight:SetActive(false)
    btnRight:FindDirect("Img_Open"):SetActive(false)
  elseif rightSupported then
    btnLeft:SetActive(false)
    btnLeft:FindDirect("Img_Open"):SetActive(false)
    btnRight:SetActive(true)
    btnRight:FindDirect("Img_Open"):SetActive(true)
  else
    btnLeft:SetActive(true)
    btnLeft:FindDirect("Img_Open"):SetActive(false)
    btnRight:SetActive(true)
    btnRight:FindDirect("Img_Open"):SetActive(false)
  end
end
def.method().UpdatePos = function(self)
  local fullNumber = constant.CMassWeddingConsts.supportSub
  local left = self.m_panel:FindDirect("Img_bg0/Group_Model/Model_Player")
  local right = self.m_panel:FindDirect("Img_bg0/Group_Model/Model_Husband")
  local center = self.m_panel:FindDirect("Img_bg0/Group_Model/Model_Wife")
  local leftX = left.localPosition.x + 64
  local rightX = right.localPosition.x - 64
  local diff = self.goodNum - self.badNum
  diff = math.max(-fullNumber, diff)
  diff = math.min(fullNumber, diff)
  local half = (rightX - leftX) / 2
  local offset = half * diff / fullNumber
  local centerX = (rightX + leftX) / 2 + offset
  local centerPos = center.localPosition
  center.localPosition = EC.Vector3.new(centerX, centerPos.y, centerPos.z)
end
def.method().TweenPos = function(self)
  local fullNumber = constant.CMassWeddingConsts.supportSub
  local left = self.m_panel:FindDirect("Img_bg0/Group_Model/Model_Player")
  local right = self.m_panel:FindDirect("Img_bg0/Group_Model/Model_Husband")
  local center = self.m_panel:FindDirect("Img_bg0/Group_Model/Model_Wife")
  local leftX = left.localPosition.x + 64
  local rightX = right.localPosition.x - 64
  local diff = self.goodNum - self.badNum
  diff = math.max(-fullNumber, diff)
  diff = math.min(fullNumber, diff)
  local half = (rightX - leftX) / 2
  local offset = half * diff / fullNumber
  local centerX = (rightX + leftX) / 2 + offset
  local centerPos = center.localPosition
  local tarPos = EC.Vector3.new(centerX, centerPos.y, centerPos.z)
  local time = math.abs(centerX - centerPos.x) / 128
  TweenPosition.Begin(center, time, tarPos)
end
def.method("=>", "number").CheckFinish = function(self)
  if self.goodNum - self.badNum >= constant.CMassWeddingConsts.supportSub then
    return 1
  elseif self.badNum - self.goodNum >= constant.CMassWeddingConsts.supportSub then
    return -1
  else
    return 0
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Tips" then
    local tmpPosition = {x = 0, y = 0}
    local CommonDescDlg = require("GUI.CommonUITipsDlg")
    local tipString = require("Main.Common.TipsHelper").GetHoverTip(constant.CMassWeddingConsts.robBrideTips)
    if tipString == "" then
      return
    end
    CommonDescDlg.ShowCommonTip(tipString, tmpPosition)
  elseif id == "Btn_Qiang" then
    local checkRes = self:CheckFinish()
    if checkRes > 0 then
      Toast(textRes.Marriage[125])
    elseif checkRes < 0 then
      Toast(textRes.Marriage[126])
    else
      require("Main.Marriage.MultiWeddingMgr").Instance():RobWomen(self.id2)
    end
  elseif id == "Btn_Bang" then
    local checkRes = self:CheckFinish()
    if checkRes > 0 then
      Toast(textRes.Marriage[125])
    elseif checkRes < 0 then
      Toast(textRes.Marriage[126])
    else
      require("Main.Marriage.MultiWeddingMgr").Instance():RobWomen(self.id1)
    end
  end
end
RobWomenDlg.Commit()
return RobWomenDlg
