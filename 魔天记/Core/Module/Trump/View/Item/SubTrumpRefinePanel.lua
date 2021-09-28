require "Core.Module.Common.UIComponent"
require "Core.Module.Trump.View.Item.SubRefineEquipItem"
require "Core.Module.Trump.View.Item.SubRefineMaterialItem"
require "Core.Module.Trump.View.Item.SubRefinePropertyItem"

SubTrumpRefinePanel = class("SubTrumpRefinePanel", UIComponent);
function SubTrumpRefinePanel:New(transform)
    self = { };
    setmetatable(self, { __index = SubTrumpRefinePanel });
    if (transform) then
        self:Init(transform);
    end
    return self
end


function SubTrumpRefinePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function SubTrumpRefinePanel:_InitReference()
    self._txtTrumpName = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTrumpName");
    self._imgRefineTitle = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgRefineTitle");
    self._btnRefine = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnRefine");
    self._imgBigIcon = UIUtil.GetChildByName(self._gameObject, "UITexture", "imgBigIcon")
    --    self._phalanxInfo = UIUtil.GetChildByName(self._gameObject,"phalanx")
    --    self._phalanx = Phalanx:New()
    --    self._phalanx:Init(self._phalanxInfo,,true)
    self._goMax = UIUtil.GetChildByName(self._gameObject, "trsMax").gameObject
    self._goNotMax = UIUtil.GetChildByName(self._gameObject, "trsNotMax").gameObject

    self._txtCurName = UIUtil.GetChildByName(self._goNotMax, "UILabel", "txtCurName")
    self._txtNextName = UIUtil.GetChildByName(self._goNotMax, "UILabel", "txtNextName")
    self._txtMaxName = UIUtil.GetChildByName(self._goMax, "UILabel", "txtMaxName")
    self._trumpEquipPhalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "trumpEquip")
    self._trumpEquipPhalanx = Phalanx:New()
    self._trumpEquipPhalanx:Init(self._trumpEquipPhalanxInfo, SubRefineEquipItem, true)

    self._trumpMaterialPhanlanxInfo = UIUtil.GetChildByName(self._goNotMax, "LuaAsynPhalanx", "phalanx")
    self._trumpMaterialPhanlanx = Phalanx:New()
    self._trumpMaterialPhanlanx:Init(self._trumpMaterialPhanlanxInfo, SubRefineMaterialItem, true)
    self._trumpMaterialPhanlanx:Build(1, 4, { })

    self._trumpRefinePropertyPhalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "propertyPhalanx")
    self._trumpRefinePropertyPhalanx = Phalanx:New()
    self._trumpRefinePropertyPhalanx:Init(self._trumpRefinePropertyPhalanxInfo, SubRefinePropertyItem)
end

function SubTrumpRefinePanel:_InitListener()
    self._onClickBtnRefine = function(go) self:_OnClickBtnRefine(self) end
    UIUtil.GetComponent(self._btnRefine, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRefine);
end

function SubTrumpRefinePanel:_OnClickBtnRefine()
    TrumpProxy.SendTrumpRefine()
end

function SubTrumpRefinePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    TrumpProxy.ResetSelectRefineTrump()
    self._trumpEquipPhalanx:Dispose()
    self._trumpMaterialPhanlanx:Dispose()
    self._trumpRefinePropertyPhalanx:Dispose()
    if (self._imgBigIcon.mainTexture) then
        if self._mainTexturePath then UIUtil.RecycleTexture(self._mainTexturePath) end
        -- self._imgBigIcon.mainTexture = nil
    end
end

function SubTrumpRefinePanel:_DisposeListener()
    UIUtil.GetComponent(self._btnRefine, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRefine = nil;
end

function SubTrumpRefinePanel:_DisposeReference()
    self._btnRefine = nil;
end

function SubTrumpRefinePanel:UpdatePanel()
    local trumpEquipData = TrumpManager.GetTrumpEquipData()
    self._trumpEquipPhalanx:Build(2, 4, trumpEquipData)
    TrumpProxy.SetSelectRefineTrumpData()
end

function SubTrumpRefinePanel:UpdateTrumpData(data)
    if (self._imgBigIcon.mainTexture) then
        if self._mainTexturePath then UIUtil.RecycleTexture(self._mainTexturePath) end
        -- self._imgBigIcon.mainTexture = nil
    end

    if (data and data.info) then
        if (self.green == nil) then
            self.green = ColorDataManager.Get_green()
        end
        local isMax =(data.info.refineLev == TrumpManager.GetTrumpConfig().refine_limit)

        if (not self._isInit) then
            self._trumpEquipPhalanx:GetItem(data.info.idx + 1).itemLogic:SetToggleValue(true)
        end
        self._isInit = true

        self._mainTexturePath = "trump/" .. data.info.configData.big_picture
        self._imgBigIcon.mainTexture = UIUtil.GetTexture(self._mainTexturePath)
        local name = data.info.configData.name
        if (data.info.refineLev > 0) then
            name = name .. ColorDataManager.GetColorText(self.green, "+" .. data.info.refineLev)
        end
        self._txtTrumpName.text = name
        self._imgRefineTitle.spriteName = "refine" .. data.info.refineLev


        if (isMax) then
            self._goMax:SetActive(true)
            self._goNotMax:SetActive(false)
            self._txtMaxName.text = data.info.refineConfig.name .. data.info.refineConfig.name .. ColorDataManager.GetColorText(self.green, "+" .. data.info.refineConfig.refine_lev)
        else
            self._goMax:SetActive(false)
            self._goNotMax:SetActive(true)
            self._txtCurName.text = data.info.refineConfig.name .. data.info.configData.name .. ColorDataManager.GetColorText(self.green, "+" .. data.info.refineConfig.refine_lev)
            self._txtNextName.text = data.info.nextRefineConfig.name .. data.info.configData.name .. ColorDataManager.GetColorText(self.green, "+" .. data.info.nextRefineConfig.refine_lev)
        end

        local need = data.info:GetRefineNeed()
        self._trumpMaterialPhanlanx:Build(1, 4, need)
        local refineProperty = data.info:GetRefinePropertyWithLimit()
        self._trumpRefinePropertyPhalanx:Build(table.getCount(refineProperty), 1, refineProperty)
    else
        self._goMax:SetActive(false)
        self._goNotMax:SetActive(false)
        self._isInit = false
        self._txtTrumpName.text = ""
        self._imgRefineTitle.spriteName = ""
        self._trumpMaterialPhanlanx:Build(1, 4, { })
    end
end

