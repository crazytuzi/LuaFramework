require "Core.Module.Common.UIComponent"
require "Core.Module.Trump.View.Item.TrumpItem"
require "Core.Module.Trump.View.Item.TrumpContainerItem"

SubTrumpPanel = class("SubTrumpPanel", UIComponent);

function SubTrumpPanel:New(transform)
    self = { };
    setmetatable(self, { __index = SubTrumpPanel });
    if (transform) then
        self:Init(transform);
    end
    return self
end

function SubTrumpPanel:_Init()
    self._btnOneKeyFusion = UIUtil.GetChildByName(self._transform, "UIButton", "btnOneKeyFusion");
    --    self._btnTrumpExChange = UIUtil.GetChildByName(self._transform, "UIButton", "btnTrumpExChange");
    --    self._btnGetTrump = UIUtil.GetChildByName(self._transform, "UIButton", "btnGetTrump");
    self._txtPower = UIUtil.GetChildByName(self._transform, "UILabel", "txtPower")
    self._trumpPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "phalanx");
    self._trumpPhalanx = Phalanx:New()
    self._trumpPhalanx:Init(self._trumpPhalanxInfo, TrumpItem)

    self._trumpContainerPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "containerPhalanx");
    self._trumpContainerPhalanx = Phalanx:New()
    self._trumpContainerPhalanx:Init(self._trumpContainerPhalanxInfo, TrumpContainerItem, true)
    self._imgBig = UIUtil.GetChildByName(self._gameObject, "UITexture", "imgBigIcon")

    self._onClickBtnOneKeyFusion = function(go) self:_OnClickBtnOneKeyFusion(self) end
    UIUtil.GetComponent(self._btnOneKeyFusion, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnOneKeyFusion);
    --    self._onClickBtnTrumpExChange = function(go) self:_OnClickBtnTrumpExChange(self) end
    --    UIUtil.GetComponent(self._btnTrumpExChange, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTrumpExChange);
    --    self._onClickBtnGetTrump = function(go) self:_OnClickBtnGetTrump(self) end
    --    UIUtil.GetComponent(self._btnGetTrump, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnGetTrump);
end

function SubTrumpPanel:_Dispose()
    UIUtil.GetComponent(self._btnOneKeyFusion, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnOneKeyFusion = nil;
    --    UIUtil.GetComponent(self._btnTrumpExChange, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --    self._onClickBtnTrumpExChange = nil;
    --    UIUtil.GetComponent(self._btnGetTrump, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --    self._onClickBtnGetTrump = nil;

    self._btnOneKeyFusion = nil;
    --    self._btnTrumpExChange = nil;
    --    self._btnGetTrump = nil;
    if (self._imgBig.mainTexture) then
        if self._mainTexturePath then UIUtil.RecycleTexture(self._mainTexturePath) end
        -- self._imgBig.mainTexture = nil
    end
    self._trumpPhalanx:Dispose()
    self._trumpPhalanx = nil
    self._trumpContainerPhalanx:Dispose()
    self._trumpContainerPhalanx = nil
end

function SubTrumpPanel:UpdatePanel()
    local data = TrumpManager.GetMainTrumpData()
    if (self._imgBig.mainTexture) then
        if self._mainTexturePath then UIUtil.RecycleTexture(self._mainTexturePath) end
        -- self._imgBig.mainTexture = nil
    end

    if (data) then
        self._mainTexturePath = "trump/" .. data.info.configData.big_picture
        self._imgBig.mainTexture = UIUtil.GetTexture(self._mainTexturePath)
    end

    local trumpEquipData = TrumpManager.GetTrumpEquipData()
    self._trumpPhalanx:BuildSphere(table.getCount(trumpEquipData), 230, trumpEquipData)
    local bagData = TrumpManager.GetTrumpBagData()
    self._trumpContainerPhalanx:Build(5, 5, bagData)
    self._txtPower.text = PlayerManager.GetSelfFightPower()
end


function SubTrumpPanel:_OnClickBtnOneKeyFusion()
    TrumpProxy.SendOneKeyFunsion()
end

-- function SubTrumpPanel:_OnClickBtnTrumpExChange()
--    ModuleManager.SendNotification(TShopNotes.OPEN_TSHOP, {type = TShopNotes.Shop_type_trump})
-- end

-- function SubTrumpPanel:_OnClickBtnGetTrump()
--    ModuleManager.SendNotification(TrumpNotes.OPEN_TRUMPOBTAINPANEL)
-- end