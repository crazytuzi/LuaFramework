require "Core.Module.Common.Panel"
require "Core.Module.Common.EnterFrameRun"

require "Core.Module.Yaoyuan.View.item.YaoYuanDiDuiXMItem"

YaoYuanDiFangXianMenPanel = class("YaoYuanDiFangXianMenPanel", Panel);

YaoYuanDiFangXianMenPanel.MESSAGE_TRY_CLOSE_YAOYUANDIFANGXIANMENPANEL = "MESSAGE_TRY_CLOSE_YAOYUANDIFANGXIANMENPANEL";


function YaoYuanDiFangXianMenPanel:New()
    self = { };
    setmetatable(self, { __index = YaoYuanDiFangXianMenPanel });
    return self
end

function YaoYuanDiFangXianMenPanel:_Popup()
    Util.SetLocalPos(self._trsContent, -580, 0, 0)

    --    self._trsContent.localPosition = Vector3.New(-580, 0, 0);

    local time = 0;
    local px = -580;
    while time < self.popupTime do
        coroutine.step();
        time = time + Timer.deltaTime;
        px = EaseUtil.easeInQuad(-580, 0, time / self.popupTime)
        Util.SetLocalPos(self._trsContent, px, 0, 0)
        --        self._trsContent.localPosition = Vector3.New(px, 0, 0);
    end
    Util.SetLocalPos(self._trsContent, 0, 0, 0)
    --    self._trsContent.localPosition = Vector3.New(0, 0, 0);
    self:_OnOpened();
end

function YaoYuanDiFangXianMenPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function YaoYuanDiFangXianMenPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._trsMask = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMask");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self.toyaoTimeTxt = UIUtil.GetChildByName(self.mainView, "UILabel", "toyaoTimeTxt");

    self.listPanel = UIUtil.GetChildByName(self.mainView, "Transform", "listPanel");
    self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");
    self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");

    local temArr = { };
    for i = 1, 18 do
        temArr[i] = { };
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, YaoYuanDiDuiXMItem);
    self.product_phalanx:Build(18, 1, temArr);


    MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_DIDUI_XIANMEN_YAOQING_LIST_COMPLETE, YaoYuanDiFangXianMenPanel.ListDataChangeHandler, self);

    MessageManager.AddListener(YaoYuanDiFangXianMenPanel, YaoYuanDiFangXianMenPanel.MESSAGE_TRY_CLOSE_YAOYUANDIFANGXIANMENPANEL, YaoYuanDiFangXianMenPanel._OnClickBtn_close, self);



    YaoyuanProxy.TryGetDiDuiXianMenNembers();

end

function YaoYuanDiFangXianMenPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function YaoYuanDiFangXianMenPanel:_OnClickBtn_close()
    if self.enterFrameRun == nil then
        self.enterFrameRun = EnterFrameRun:New();

        self.enterFrameRun:AddHandler(YaoYuanDiFangXianMenPanel.MovePanel, self, 5);
        self.enterFrameRun:AddHandler(YaoYuanDiFangXianMenPanel.MoveEnd, self, 1);
        self.enterFrameRun:Start()
    end
end

--[[
 S <-- 17:42:04.877, 0x140E, 32, {"tm":[{"e":4,"n":"\u590F\u82F1\u7199","odd":0,"tId":"201010","tn":"qq","l":93,"pId":"20100007"}]}
]]
function YaoYuanDiFangXianMenPanel:ListDataChangeHandler(data)

    local tm = data.tm;
    local items = self.product_phalanx._items;

    for i = 1, 18 do
        items[i].itemLogic:SetData(tm[i]);
    end


    self.toyaoTimeTxt.text = "" .. FarmsDataManager.touyaoElseTime;

end

function YaoYuanDiFangXianMenPanel:MovePanel()

    local lx = self._trsContent.localPosition.x;
    Util.SetLocalPos(self._trsContent,lx - 580 / 5, 0, 0)

--    self._trsContent.localPosition = Vector3.New(lx - 580 / 5, 0, 0);

end

function YaoYuanDiFangXianMenPanel:MoveEnd()
    ModuleManager.SendNotification(YaoyuanNotes.CLOSE_YAOYUANDIFANGXIANMENPANEL);
end


function YaoYuanDiFangXianMenPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function YaoYuanDiFangXianMenPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function YaoYuanDiFangXianMenPanel:_DisposeReference()
    self._btn_close = nil;
    self._trsMask = nil;

    if self.product_phalanx ~= nil then
        self.product_phalanx:Dispose();
        self.product_phalanx = nil;
    end

    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_DIDUI_XIANMEN_YAOQING_LIST_COMPLETE, YaoYuanDiFangXianMenPanel.ListDataChangeHandler);
    MessageManager.RemoveListener(YaoYuanDiFangXianMenPanel, YaoYuanDiFangXianMenPanel.MESSAGE_TRY_CLOSE_YAOYUANDIFANGXIANMENPANEL, YaoYuanDiFangXianMenPanel._OnClickBtn_close);


    self.mainView = nil;

    self.toyaoTimeTxt = nil;

    self.listPanel = nil;
    self.subPanel = nil;
    self._item_phalanx = nil;

end
