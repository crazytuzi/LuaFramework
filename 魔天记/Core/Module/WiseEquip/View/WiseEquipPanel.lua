require "Core.Module.Common.Panel"

local WiseEquipPanel = class("WiseEquipPanel", Panel);

local ContentDuanzaoCtr = require "Core.Module.WiseEquip.trc.ContentDuanzaoCtr"
local ContentFumoCtr = require "Core.Module.WiseEquip.trc.ContentFumoCtr"
-- 380102 380172  
function WiseEquipPanel:New()
    self = { };
    setmetatable(self, { __index = WiseEquipPanel });
    return self
end


function WiseEquipPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function WiseEquipPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtLingshi = UIUtil.GetChildInComponents(txts, "txtLingshi");
    self._txtXianyu = UIUtil.GetChildInComponents(txts, "txtXianyu");
    self._txtBangdingxianyu = UIUtil.GetChildInComponents(txts, "txtBangdingxianyu");
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");

    self._btn_duanzao = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btn_duanzao");
    self._btn_fumo = UIUtil.GetChildByName(self._trsContent, "UIToggle", "btn_fumo");

    self._btn_duanzao_tip = UIUtil.GetChildByName(self._btn_duanzao, "UISprite", "tip");
    self._btn_fumo_tip = UIUtil.GetChildByName(self._btn_fumo, "UISprite", "tip");

    self._coinBar = UIUtil.GetChildByName(self._trsContent, "Transform", "CoinBar");
    self._coinBarCtrl = CoinBar:New(self._coinBar);

    self._content_duanzao = UIUtil.GetChildByName(self._trsContent, "Transform", "content_duanzao");
    self._content_fumo = UIUtil.GetChildByName(self._trsContent, "Transform", "content_fumo");

    self._contentDuanzaoCtr = ContentDuanzaoCtr:New();
    self._contentDuanzaoCtr:Init(self._content_duanzao)

    self._contentFumoCtr = ContentFumoCtr:New();
    self._contentFumoCtr:Init(self._content_fumo)

    MessageManager.AddListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2002_RESULT, WiseEquipPanel.UpTip, self);
    MessageManager.AddListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2003_RESULT, WiseEquipPanel.UpTip, self);
    MessageManager.AddListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2001_RESULT, WiseEquipPanel.UpTip, self);
    MessageManager.AddListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, WiseEquipPanel.UpTip, self);

    self:UpTip()
    self:UpTabBt()
end

function WiseEquipPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_duanzao = function(go) self:_OnClickBtn_duanzao(self) end
    UIUtil.GetComponent(self._btn_duanzao, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_duanzao);
    self._onClickBtn_fumo = function(go) self:_OnClickBtn_fumo(self) end
    UIUtil.GetComponent(self._btn_fumo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_fumo);


end



function WiseEquipPanel:UpTabBt()
    local b1 = SystemManager.IsOpen(SystemConst.Id.WiseEquip_FoMo);
    local b2 = SystemManager.IsOpen(SystemConst.Id.WiseEquip_DuanZao);


    self._btn_fumo.gameObject:SetActive(b1);
    self._btn_duanzao.gameObject:SetActive(b2);

end

function WiseEquipPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(WiseEquipPanelNotes.CLOSE_WISEEQUIPPANEL);
end

function WiseEquipPanel:UpTip()

    local b1 = EquipDataManager.IsCanFuMo();
    self._btn_fumo_tip.gameObject:SetActive(b1);

    local b2 = EquipDataManager.IsCanDuanZao();
    self._btn_duanzao_tip.gameObject:SetActive(b2);

end


--
--
function WiseEquipPanel:SetData(data)

    if data == nil then
        data = { { tabIndex = 1, eqIndex = 1, selectEqInBag = nil } };
    end

    self.data = data;
    self.setDataFirst = true;

    local tabIndex = data.tabIndex;
    local eqIndex = data.eqIndex;
    local selectEqInBag = data.selectEqInBag;

    if tabIndex == 1 then
        self._btn_duanzao.value = true
        self._btn_fumo.value = false
        self:_OnClickBtn_duanzao()
    elseif tabIndex == 2 then
        self._btn_duanzao.value = false
        self._btn_fumo.value = true
        self:_OnClickBtn_fumo()
    end

    self._contentDuanzaoCtr:SetData(eqIndex, selectEqInBag);
    self._contentFumoCtr:SetData(eqIndex, selectEqInBag);

end

function WiseEquipPanel:_OnClickBtn_duanzao()

    LogHttp.SendOperaLog("仙器锻造")

    self._contentDuanzaoCtr:Show();
    self._contentFumoCtr:Hide();



end

function WiseEquipPanel:_OnClickBtn_fumo()

    LogHttp.SendOperaLog("仙器附魔")
    self._contentDuanzaoCtr:Hide();
    self._contentFumoCtr:Show();
end



function WiseEquipPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function WiseEquipPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_duanzao, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_duanzao = nil;
    UIUtil.GetComponent(self._btn_fumo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_fumo = nil;

    MessageManager.RemoveListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2002_RESULT, WiseEquipPanel.UpTip);
    MessageManager.RemoveListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2003_RESULT, WiseEquipPanel.UpTip);
    MessageManager.RemoveListener(WiseEquipPanelProxy, WiseEquipPanelProxy.MESSAGE_0X2001_RESULT, WiseEquipPanel.UpTip);
    MessageManager.RemoveListener(BackpackDataManager, BackpackDataManager.MESSAGE_BAG_PRODUCTS_CHANGE, WiseEquipPanel.UpTip);

end

function WiseEquipPanel:_DisposeReference()

    self._coinBarCtrl:Dispose();
    self._coinBarCtrl = nil;

    self._contentDuanzaoCtr:Dispose();
    self._contentFumoCtr:Dispose();

    self._contentDuanzaoCtr = nil;
    self._contentFumoCtr = nil;


    self._btn_close = nil;
    self._btn_duanzao = nil;
    self._btn_fumo = nil;

    self._txtLingshi = nil;
    self._txtXianyu = nil;
    self._txtBangdingxianyu = nil;
end
return WiseEquipPanel