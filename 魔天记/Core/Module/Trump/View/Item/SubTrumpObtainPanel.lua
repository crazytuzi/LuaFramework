require "Core.Module.Common.UIComponent"
require "Core.Module.Trump.View.Item.SubFusionSelectItem"
require "Core.Module.Trump.View.Item.TrumpObtainItem"
require "Core.Module.Trump.View.Item.CauldronItem"
require "Core.Module.Trump.View.Item.SubCollectTrumpSelectItem"

SubTrumpObtainPanel = class("SubTrumpObtainPanel", UIComponent);
function SubTrumpObtainPanel:New(transform)
    self = { };
    setmetatable(self, { __index = SubTrumpObtainPanel });
    if (transform) then
        self:Init(transform);
    end
    return self
end 

function SubTrumpObtainPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self._isSelectActive = false
    self._trsSelect.gameObject:SetActive(self._isSelectActive)
    self._cauldronConfig = TrumpManager.GetCauldronConfig()
    self:TrumpCoinChange()
end

function SubTrumpObtainPanel:_InitReference()
    self._btnTrumpStore = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnTrumpStore");
    self._btnOneKeyGetTrump = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnOneKeyGetTrump");
    self._btnOneKeyCollect = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnOneKeyCollect");
    self._btnQualitySelect = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnQualitySelect");

    self._containerPhalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "phalanx")
    self._containerPhalanx = Phalanx:New()
    self._containerPhalanx:Init(self._containerPhalanxInfo, TrumpObtainItem, true)
    self._txtTrumpCoin = UIUtil.GetChildByName(self._gameObject, "UILabel", "trumpCoin/txtTrumpChip")

    self._cauldronPhalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "cauldronPhalanx");
    self._cauldronPhalanx = Phalanx:New()
    self._cauldronPhalanx:Init(self._cauldronPhalanxInfo, CauldronItem)

    self._trsSelect = UIUtil.GetChildByName(self._gameObject, "trsSelect")
    self._selectPhalanxInfo = UIUtil.GetChildByName(self._trsSelect.gameObject, "LuaAsynPhalanx", "selectPhalanx")
    self._selectPhalanx = Phalanx:New()
    self._selectPhalanx:Init(self._selectPhalanxInfo, SubCollectTrumpSelectItem)
    -- 品质数据
    local data = { 0, 1, 2, 3, 4 }
    self._selectPhalanx:Build(table.getCount(data), 1, data)
end

function SubTrumpObtainPanel:_InitListener()
    self._onClickBtnTrumpStore = function(go) self:_OnClickBtnTrumpStore(self) end
    UIUtil.GetComponent(self._btnTrumpStore, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTrumpStore);
    self._onClickBtnOneKeyGetTrump = function(go) self:_OnClickBtnOneKeyGetTrump(self) end
    UIUtil.GetComponent(self._btnOneKeyGetTrump, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOneKeyGetTrump);
    self._onClickBtnOneKeyCollect = function(go) self:_OnClickBtnOneKeyCollect(self) end
    UIUtil.GetComponent(self._btnOneKeyCollect, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOneKeyCollect);
    self._onClickBtnQualitySelect = function(go) self:_OnClickBtnQualitySelect(self) end
    UIUtil.GetComponent(self._btnQualitySelect, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnQualitySelect);

    MessageManager.AddListener(TrumpManager, TrumpManager.TRUMPCOINCHANGE, SubTrumpObtainPanel.TrumpCoinChange, self)
end

function SubTrumpObtainPanel:TrumpCoinChange()
    self._txtTrumpCoin.text = tostring(TrumpManager.GetTrumpCoin())
end

function SubTrumpObtainPanel:_OnClickBtnTrumpStore()
    ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, {type = TShopNotes.Shop_type_trump})
end

function SubTrumpObtainPanel:_OnClickBtnOneKeyGetTrump()
    TrumpProxy.SendGetTrumpByType(1)
end

function SubTrumpObtainPanel:_OnClickBtnOneKeyCollect()
    TrumpProxy.SendOneKeyCollect()
end

function SubTrumpObtainPanel:OnClickBtnQualitySelect()
    self:_OnClickBtnQualitySelect()
end

function SubTrumpObtainPanel:_OnClickBtnQualitySelect()
    self._isSelectActive = not self._isSelectActive
    self._trsSelect.gameObject:SetActive(self._isSelectActive)
    local data = { 0, 1, 2, 3, 4 }
    self._selectPhalanx:Build(table.getCount(data), 1, data)
end

function SubTrumpObtainPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
    self._selectPhalanx:Dispose()
    self._cauldronPhalanx:Dispose()
    self._containerPhalanx:Dispose()
end

function SubTrumpObtainPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnTrumpStore, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTrumpStore = nil;
    UIUtil.GetComponent(self._btnOneKeyGetTrump, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnOneKeyGetTrump = nil;
    UIUtil.GetComponent(self._btnOneKeyCollect, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnOneKeyCollect = nil;
    UIUtil.GetComponent(self._btnQualitySelect, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnQualitySelect = nil;
    MessageManager.RemoveListener(TrumpManager, TrumpManager.TRUMPCOINCHANGE, SubTrumpObtainPanel.TrumpCoinChange)
end

function SubTrumpObtainPanel:_DisposeReference()
    self._btnTrumpStore = nil;
    self._btnOneKeyGetTrump = nil;
    self._btnOneKeyCollect = nil;
    self._btnQualitySelect = nil;
end

function SubTrumpObtainPanel:UpdatePanel()
    self._cauldronPhalanx:Build(1, table.getCount(self._cauldronConfig), self._cauldronConfig)
    local obtainItem = TrumpManager.GetCollectAreaData()
    self._containerPhalanx:Build(2, 9, obtainItem)
end
 