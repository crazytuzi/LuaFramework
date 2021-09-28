 


require "Core.Module.Common.UIComponent"
require "Core.Module.Trump.View.Item.SubFusionSelectItem"
require "Core.Module.Trump.View.Item.SubFusionBagItem"
require "Core.Module.Trump.View.Item.SubFusionEquipItem"



SubFusionPanel = class("SubFusionPanel", UIComponent);
function SubFusionPanel:New(transform)
    self = { };
    setmetatable(self, { __index = SubFusionPanel });
    if (transform) then
        self:Init(transform);
    end
    return self
end

function SubFusionPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self._isSelectActive = false
    self._isInit = false
    self._trsSelect.gameObject:SetActive(self._isSelectActive)
end

function SubFusionPanel:_InitReference()
    self._txtTrumpName = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTrumpName");
    self._txtTrumpSkillNameAndLevel = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTrumpSkillNameAndLevel");
    self._txtTrumpSkillDes = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTrumpSkillDes");
    self._txtTrumpProperty = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTrumpProperty");
    self._txtExp = UIUtil.GetChildByName(self._gameObject, "UILabel", "slider_exp/txtExp")

    self._txtTrumpCount = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTrumpCount");
    self._btnFunsionTrump = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnFunsionTrump");
    self._btnSelect = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnSelect");
    self._trsSelect = UIUtil.GetChildByName(self._gameObject, "Transform", "trsSelect");
    self._dressToggle = UIUtil.GetChildByName(self._gameObject, "UIToggle", "dressToggle")
    self._btnDress = UIUtil.GetChildByName(self._gameObject, "UIButton", "dressToggle")

    self._sliderExp = UIUtil.GetChildByName(self._gameObject, "UISlider", "slider_exp")
    self._imgBig = UIUtil.GetChildByName(self._gameObject, "UITexture", "imgBigIcon")

    self._trumpEquipPhalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "trumpEquip")
    self._trumpEquipPhalanx = Phalanx:New()
    self._trumpEquipPhalanx:Init(self._trumpEquipPhalanxInfo, SubFusionEquipItem, true)


    self._trumpBagPhalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "scrollView/trumpBag")
    self._trumpBagPhalanx = Phalanx:New()
    self._trumpBagPhalanx:Init(self._trumpBagPhalanxInfo, SubFusionBagItem, true)

    self._selectPhalanxInfo = UIUtil.GetChildByName(self._trsSelect.gameObject, "LuaAsynPhalanx", "selectPhalanx")
    self._selectPhalanx = Phalanx:New()
    self._selectPhalanx:Init(self._selectPhalanxInfo, SubFusionSelectItem)
    -- 品质数据
    local data = { 0, 1, 2, 3, 4 }
    self._selectPhalanx:Build(table.getCount(data), 1, data)
end

function SubFusionPanel:_InitListener()
    self._onClickBtnFunsionTrump = function(go) self:_OnClickBtnFunsionTrump(self) end
    UIUtil.GetComponent(self._btnFunsionTrump, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFunsionTrump);
    self._onClickBtnSelect = function(go) self:_OnClickBtnSelect(self) end
    UIUtil.GetComponent(self._btnSelect, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSelect);
    self._onClickBtnDress = function(go) self:_OnClickBtnDress(self) end
    UIUtil.GetComponent(self._btnDress, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDress);
end

function SubFusionPanel:_OnClickBtnFunsionTrump()
    TrumpProxy.SendFunsion()
end

function SubFusionPanel:_OnClickBtnDress()
    if (self._dressToggle.value) then
        TrumpProxy.SendTrumpOnDress()
    else
        TrumpProxy.SendTrumpUnDress()
    end
end

function SubFusionPanel:_OnClickBtnSelect()
    self:SetSelectPanelActive()
end

function SubFusionPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    TrumpProxy.ResetTrumpMaterials()
    TrumpProxy.ResetSelectTrump()
    self._trumpEquipPhalanx:Dispose()
    self._trumpEquipPhalanx = nil
    self._trumpBagPhalanx:Dispose()
    self._trumpBagPhalanx = nil
    self._selectPhalanx:Dispose()
    self._selectPhalanx = nil
    self._isInit = false
end

function SubFusionPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnFunsionTrump, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnFunsionTrump = nil;
    UIUtil.GetComponent(self._btnSelect, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnSelect = nil;
    UIUtil.GetComponent(self._btnDress, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnDress = nil;
end

function SubFusionPanel:_DisposeReference()
    self._btnFunsionTrump = nil;
    self._btnSelect = nil;
    if (self._imgBig.mainTexture) then
        if self._mainTexturePath then UIUtil.RecycleTexture(self._mainTexturePath) end
        -- self._imgBig.mainTexture = nil
    end
end

function SubFusionPanel:UpdatePanel()
    local trumpEquipData = TrumpManager.GetTrumpEquipData()
    self._trumpEquipPhalanx:Build(2, 4, trumpEquipData)
    local trumpBagData = TrumpManager.GetTrumpBagData()
    self._trumpBagPhalanx:Build(5, 4, trumpBagData)
    TrumpProxy.SetSelectTrumpData()
    self._txtTrumpCount.text = string.format("%s/%s", table.getCount(trumpBagData), TrumpManager.TRUMPBAGMAXCOUNT)
    self:UpdateSelectMaterial()
end

function SubFusionPanel:UpdateSelectMaterial()
    local selctData = TrumpProxy.GetTrumpMaterials()
    local items = self._trumpBagPhalanx:GetItems()
    local count = table.getCount(items)
    for k, v in pairs(items) do
        v.itemLogic:SetToggleValue(false)
    end

    if (selctData and table.getCount(selctData) > 0) then
        for k, v in pairs(selctData) do
            if (v.info) then
                self._trumpBagPhalanx:GetItem(v.info.idx + 1).itemLogic:SetToggleValue(true)
            end
        end
    end
end
  
function SubFusionPanel:UpdateTrumpData(data)
    if (self._imgBig.mainTexture) then
        if self._mainTexturePath then UIUtil.RecycleTexture(self._mainTexturePath) end
        -- self._imgBig.mainTexture = nil
    end
    if (data and data.info) then
        if (not self._isInit) then
            self._trumpEquipPhalanx:GetItem(data.info.idx + 1).itemLogic:SetToggleValue(true)
        end
        self._isInit = true
        self._mainTexturePath = "trump/" .. data.info.configData.big_picture
        self._imgBig.mainTexture = UIUtil.GetTexture(self._mainTexturePath)
        self._txtTrumpName.text = data.info.configData.name
--        local trumpSkillInfo = data.info:GetTrumpSkillInfo()
--        self._txtTrumpSkillNameAndLevel.text = string.format("%s:%s", trumpSkillInfo.name, GetLvDes(trumpSkillInfo.skill_lv))
--        self._txtTrumpSkillDes.text = trumpSkillInfo.skill_desc
        self._txtTrumpProperty.text = data.info:GetTrumpPropertyDes()
        --        self._btnDress.gameObject:SetActive(data.info.configData.quality == ProductManager.MAXQUALITY)
        self._dressToggle.value =(TrumpManager.GetMainTrumpId() == data.info.id)
        self._sliderExp.value = data.info.exp / data.info.maxExp
        self._txtExp.text = string.format("%s/%s", data.info.exp, data.info.maxExp)
    else
        self._isInit = false
        local items = self._trumpEquipPhalanx:GetItems()
        self._txtTrumpName.text = ""
        self._txtTrumpSkillNameAndLevel.text = ""
        self._txtTrumpSkillDes.text = ""
        self._txtTrumpProperty.text = ""
        self._btnDress.gameObject:SetActive(false)
        self._sliderExp.value = 0
        self._txtExp.text = "0/0"
    end


end

function SubFusionPanel:SetSelectPanelActive()
    self._isSelectActive = not self._isSelectActive
    self._trsSelect.gameObject:SetActive(self._isSelectActive)
end

 