require "Core.Module.Common.Panel"

require "Core.Module.Yaoyuan.View.item.YaoYuanLogItem"

YaoYuanJiLuPanel = class("YaoYuanJiLuPanel", Panel);
function YaoYuanJiLuPanel:New()
    self = { };
    setmetatable(self, { __index = YaoYuanJiLuPanel });
    return self
end


function YaoYuanJiLuPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function YaoYuanJiLuPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btn_clean = UIUtil.GetChildInComponents(btns, "btn_clean");
    self._trsMask = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMask");


    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self.listPanel = UIUtil.GetChildByName(self.mainView, "Transform", "listPanel");
    self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");
    self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");


    MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_XIANMEN_LOG_COMPLETE, YaoYuanJiLuPanel.GetLogHandler, self);
     MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_CLEANALLYAOYUANLOG_COMPLETE, YaoYuanJiLuPanel.CleanLogComplete, self);

    YaoyuanProxy.TryGetXianMenLog();
end

function YaoYuanJiLuPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_clean = function(go) self:_OnClickBtn_clean(self) end
    UIUtil.GetComponent(self._btn_clean, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_clean);
end

function YaoYuanJiLuPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(YaoyuanNotes.CLOSE_YAOYUANJILUPANEL);
end

function YaoYuanJiLuPanel:GetLogHandler(data)

    local l = data.l;
    local len = table.getn(l);
    local curr_t = os.time();

    for i = 1, len do
        l[i].passTime = curr_t - math.floor(l[i].t / 1000);
    end

    if self.product_phalanx == nil then
        self.product_phalanx = Phalanx:New();
        self.product_phalanx:Init(self._item_phalanx, YaoYuanLogItem);
        self.product_phalanx:Build(len, 1, l);
    end

end

function YaoYuanJiLuPanel:CleanLogComplete()

 if self.product_phalanx ~= nil then
        local items = self.product_phalanx._items;
        len = table.getn(items);

        for i = 1, len do
            items[i].itemLogic:SetActive(false);
        end
    end


end

function YaoYuanJiLuPanel:_OnClickBtn_clean()

    YaoyuanProxy.TryCleanAllYaoYuanLog();

end

function YaoYuanJiLuPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function YaoYuanJiLuPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_clean, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_clean = nil;
end

function YaoYuanJiLuPanel:_DisposeReference()

    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_XIANMEN_LOG_COMPLETE, YaoYuanJiLuPanel.GetLogHandler);
    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_CLEANALLYAOYUANLOG_COMPLETE, YaoYuanJiLuPanel.CleanLogComplete);

    self._btn_close = nil;
    self._btn_clean = nil;
    self._trsMask = nil;

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;



    self.mainView = nil;

    self.listPanel = nil;
    self.subPanel = nil;
    self._item_phalanx = nil;

end
