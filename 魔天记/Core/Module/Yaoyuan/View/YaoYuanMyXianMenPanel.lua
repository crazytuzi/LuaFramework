require "Core.Module.Common.Panel"

require "Core.Module.Common.EnterFrameRun"

require "Core.Module.Yaoyuan.View.item.YaoYuanMyXMItem"

YaoYuanMyXianMenPanel = class("YaoYuanMyXianMenPanel", Panel);

YaoYuanMyXianMenPanel.MESSAGE_TRY_CLOSE_YAOYUANMYXIANMENPANEL = "MESSAGE_TRY_CLOSE_YAOYUANMYXIANMENPANEL";




function YaoYuanMyXianMenPanel:New()
    self = { };
    setmetatable(self, { __index = YaoYuanMyXianMenPanel });
    return self
end



function YaoYuanMyXianMenPanel:_Popup()
    Util.SetLocalPos(self._trsContent, -580, 0, 0)
    --    self._trsContent.localPosition = Vector3.New(-580, 0, 0);

    local time = 0;
    local px = -580;
    while time < self.popupTime do
        coroutine.step();
        time = time + Timer.deltaTime;
        px = EaseUtil.easeInQuad(-580, 0, time / self.popupTime)
        Util.SetLocalPos(self._trsContent, px, 0, 0)
        --       self._trsContent.localPosition = Vector3.New(px, 0, 0);
    end
    Util.SetLocalPos(self._trsContent, 0, 0, 0)
    --    self._trsContent.localPosition = Vector3.New(0, 0, 0);
    self:_OnOpened();
end

function YaoYuanMyXianMenPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function YaoYuanMyXianMenPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._trsMask = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMask");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self.jiaoshuitimeTxt = UIUtil.GetChildByName(self.mainView, "UILabel", "jiaoshuitimeTxt");

    self.listPanel = UIUtil.GetChildByName(self.mainView, "Transform", "listPanel");
    self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");
    self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");

    local temArr = { };
    for i = 1, 18 do
        temArr[i] = { };
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, YaoYuanMyXMItem);
    self.product_phalanx:Build(18, 1, temArr);

    MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_MY_XIANMEN_NUMBER_CHANGE, YaoYuanMyXianMenPanel.MyxianmenNumberChange, self);

    MessageManager.AddListener(YaoYuanMyXianMenPanel, YaoYuanMyXianMenPanel.MESSAGE_TRY_CLOSE_YAOYUANMYXIANMENPANEL, YaoYuanMyXianMenPanel._OnClickBtn_close, self);



    self.jiaoshuitimeTxt.text = LanguageMgr.Get("Yaoyuan/YaoYuanMyXianMenPanel/label1") .. FarmsDataManager.jiaoshuiElseTime .. "[-]";

    YaoyuanProxy.TryGetMyXianMenNembers();

end

function YaoYuanMyXianMenPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function YaoYuanMyXianMenPanel:_OnClickBtn_close()
    if self.enterFrameRun == nil then
        self.enterFrameRun = EnterFrameRun:New();

        self.enterFrameRun:AddHandler(YaoYuanMyXianMenPanel.MovePanel, self, 5);
        self.enterFrameRun:AddHandler(YaoYuanMyXianMenPanel.MoveEnd, self, 1);
        self.enterFrameRun:Start()
    end
end

function YaoYuanMyXianMenPanel:MyxianmenNumberChange(list)

    local item = self.product_phalanx._items;

    for i = 1, 18 do
        item[i].itemLogic:SetData(list[i]);
    end

end


function YaoYuanMyXianMenPanel:MovePanel()

    local lx = self._trsContent.localPosition.x;
    --    self._trsContent.localPosition = Vector3.New(lx - 580 / 5, 0, 0);
    Util.SetLocalPos(self._trsContent, lx - 580 / 5, 0, 0)

end

function YaoYuanMyXianMenPanel:MoveEnd()
    ModuleManager.SendNotification(YaoyuanNotes.CLOSE_YAOYUANMYXIANMENPANEL);
end



function YaoYuanMyXianMenPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function YaoYuanMyXianMenPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function YaoYuanMyXianMenPanel:_DisposeReference()
    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_MY_XIANMEN_NUMBER_CHANGE, YaoYuanMyXianMenPanel.MyxianmenNumberChange);
    MessageManager.RemoveListener(YaoYuanMyXianMenPanel, YaoYuanMyXianMenPanel.MESSAGE_TRY_CLOSE_YAOYUANMYXIANMENPANEL, YaoYuanMyXianMenPanel._OnClickBtn_close);

    self._btn_close = nil;
    self._trsMask = nil;

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;


    self.mainView = nil;

    self.jiaoshuitimeTxt = nil;

    self.listPanel = nil;
    self.subPanel = nil;
    self._item_phalanx = nil;


end
