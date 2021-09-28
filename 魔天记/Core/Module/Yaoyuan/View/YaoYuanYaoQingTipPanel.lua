require "Core.Module.Common.Panel"

require "Core.Module.Yaoyuan.View.item.YaoYuanYaoQingTipItem"

YaoYuanYaoQingTipPanel = class("YaoYuanYaoQingTipPanel", Panel);
function YaoYuanYaoQingTipPanel:New()
    self = { };
    setmetatable(self, { __index = YaoYuanYaoQingTipPanel });
    return self
end


function YaoYuanYaoQingTipPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function YaoYuanYaoQingTipPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btn_clean = UIUtil.GetChildInComponents(btns, "btn_clean");
    self._trsMask = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMask");



    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self.listPanel = UIUtil.GetChildByName(self.mainView, "Transform", "listPanel");
    self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");
    self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");

    local temArr = { };
    for i = 1, 18 do
        temArr[i] = { };
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, YaoYuanYaoQingTipItem);
    self.product_phalanx:Build(18, 1, temArr);

    MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_REC_0X140ADATA, YaoYuanYaoQingTipPanel.Rec_0x140AData, self);


end

function YaoYuanYaoQingTipPanel:_Opened()
    self._trsContent.gameObject:SetActive(false);
    self._trsContent.gameObject:SetActive(true);
end

function YaoYuanYaoQingTipPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_clean = function(go) self:_OnClickBtn_clean(self) end
    UIUtil.GetComponent(self._btn_clean, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_clean);
end

function YaoYuanYaoQingTipPanel:Rec_0x140AData()

    self:NeedUpData()

end


function YaoYuanYaoQingTipPanel:NeedUpData()

    local list = YaoyuanProxy.Get0x140AData();
    local items = self.product_phalanx._items;

    for i = 1, 18 do
        items[i].itemLogic:SetData(list[i]);
    end

end

function YaoYuanYaoQingTipPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(YaoyuanNotes.CLOSE_YAOYUANYAOQINGTIPPANEL);
end

function YaoYuanYaoQingTipPanel:_OnClickBtn_clean()
    YaoyuanProxy.CleanAll0x140AData();
end

function YaoYuanYaoQingTipPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function YaoYuanYaoQingTipPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_clean, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_clean = nil;
end

function YaoYuanYaoQingTipPanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_clean = nil;
    self._trsMask = nil;


    if self.product_phalanx ~= nil then
        self.product_phalanx:Dispose();
        self.product_phalanx = nil;
    end

    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_REC_0X140ADATA, YaoYuanYaoQingTipPanel.Rec_0x140AData);


    self.mainView = nil;

    self.listPanel = nil;
    self.subPanel = nil;
    self._item_phalanx = nil;

end
