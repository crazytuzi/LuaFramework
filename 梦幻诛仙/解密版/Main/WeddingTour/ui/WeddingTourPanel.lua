local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local WeddingTourPanel = Lplus.Extend(ECPanelBase, "WeddingTourPanel")
local ItemModule = require("Main.Item.ItemModule")
local WeddingTourUtils = require("Main.WeddingTour.WeddingTourUtils")
local ECUIModel = require("Model.ECUIModel")
local Vector = require("Types.Vector")
local def = WeddingTourPanel.define
local instance
def.field("number")._selectMode = 0
def.field("userdata")._flowerCarModel = nil
def.field("userdata")._flowerCarDescription = nil
def.field("userdata")._labelOwnMoney = nil
def.field("table")._tourModes = nil
def.field("table").model = nil
def.static("=>", WeddingTourPanel).Instance = function()
  if instance == nil then
    instance = WeddingTourPanel()
  end
  return instance
end
def.method().ShowWeddingTourOptions = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_WEDDINGTOUR, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ChooseTourMode(1)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, WeddingTourPanel.OnMoneyChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, WeddingTourPanel.OnMoneyChanged)
end
def.method().InitUI = function(self)
  self._tourModes = WeddingTourUtils.GetAllWeddingTourModes()
  local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
  local yuanbaoStr = yuanbaoNum ~= nil and yuanbaoNum:tostring() or 0
  local groupChoose = self.m_panel:FindDirect("Img_bg001/Group_Choose")
  self._labelOwnMoney = groupChoose:FindDirect("Ownedmoney/Label_Money"):GetComponent("UILabel")
  self._labelOwnMoney:set_text(yuanbaoStr)
  local firstTour = groupChoose:FindDirect("Object_1")
  local firstTourName = firstTour:FindDirect("Img_Bg1/Label_Name1"):GetComponent("UILabel")
  local fisrtTourCost = firstTour:FindDirect("Img_Bg2/Label_Money"):GetComponent("UILabel")
  firstTourName:set_text(self._tourModes[1].titleName)
  fisrtTourCost:set_text(self._tourModes[1].cost)
  local secondTour = groupChoose:FindDirect("Object_2")
  local secondTourName = secondTour:FindDirect("Img_Namebg/Label_Name2"):GetComponent("UILabel")
  local secondTourCost = secondTour:FindDirect("Img_Bg2/Label_Money"):GetComponent("UILabel")
  local secondTourCheck = secondTour:FindDirect("Btn_Choose2")
  secondTourName:set_text(self._tourModes[2].titleName)
  secondTourCost:set_text(self._tourModes[2].cost)
  secondTourCheck:SetActive(true)
  self._flowerCarModel = self.m_panel:FindDirect("Img_bg001/Model_Huache"):GetComponent("UIModel")
  self._flowerCarDescription = self.m_panel:FindDirect("Img_bg001/Label_Describe"):GetComponent("UILabel")
  self._flowerCarModel.transform.localPosition = Vector.Vector3.new(145, 0, 0)
  self._flowerCarModel.transform.localScale = Vector.Vector3.new(1, 0.4, 1)
end
def.method("number").ChooseTourMode = function(self, modeIdx)
  if self._selectMode == modeIdx then
    return
  end
  self._selectMode = modeIdx
  local modelInfo = self._tourModes[modeIdx]
  if self._flowerCarDescription ~= nil then
    self._flowerCarDescription:set_text(modelInfo.desc)
  end
  if self.model then
    self.model:Destroy()
    self.model = nil
  end
  if modelInfo then
    do
      local uiModel = self._flowerCarModel
      local modelPath, colorId = GetModelPath(modelInfo.modelDisplayId)
      if modelPath and modelPath ~= "" then
        self.model = ECUIModel.new(modelInfo.modelDisplayId)
        self.model:LoadUIModel(modelPath, function(ret)
          if ret == nil or self.model == nil then
            return
          end
          uiModel.modelGameObject = self.model.m_model
          if uiModel.mCanOverflow ~= nil then
            uiModel.mCanOverflow = true
            local camera = uiModel:get_modelCamera()
            camera:set_orthographic(true)
          end
          self.model:SetDir(-130)
        end)
      end
    end
  end
end
def.method().StartTour = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_MARRIAGE_PARADE) then
    Toast(textRes.WeddingTour[16])
    return
  end
  local selectMode = self._tourModes[self._selectMode]
  local needYuanbao = selectMode.cost
  local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
  if Int64.lt(yuanbaoNum, needYuanbao) then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm("", textRes.WeddingTour[5], WeddingTourPanel.BuyYuanbaoCallback, nil)
  else
    local tourReq = require("netio.protocol.mzm.gsp.marriage.CMarrigeParadeReq").new(selectMode.id)
    gmodule.network.sendProtocol(tourReq)
  end
end
def.static("number", "table").BuyYuanbaoCallback = function(i, tag)
  if i == 1 then
    local MallPanel = require("Main.Mall.ui.MallPanel")
    require("Main.Mall.MallModule").RequireToShowMallPanel(MallPanel.StateConst.Pay, 0, 0)
  end
end
def.static("table", "table").OnMoneyChanged = function(p1, p2)
  local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
  local yuanbaoStr = yuanbaoNum ~= nil and yuanbaoNum:tostring() or 0
  if WeddingTourPanel.Instance()._labelOwnMoney ~= nil then
    WeddingTourPanel.Instance()._labelOwnMoney:set_text(yuanbaoStr)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:Close()
  elseif id == "Btn_bg1" then
    self:ChooseTourMode(1)
  elseif id == "Btn_Choose2" then
    self:ChooseTourMode(2)
  elseif id == "Btn_Starttour" then
    self:StartTour()
  end
end
def.method().Close = function(self)
  if self.model then
    self.model:Destroy()
  end
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  self._flowerCarDescription = nil
  self._flowerCarModel = nil
  self._labelOwnMoney = nil
  self.model = nil
  self._tourModes = nil
  self._selectMode = 0
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, WeddingTourPanel.OnMoneyChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, WeddingTourPanel.OnMoneyChanged)
end
WeddingTourPanel.Commit()
return WeddingTourPanel
