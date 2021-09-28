require "Core.Module.Common.UIComponent"


SubItem2Panel = class("SubItem2Panel", UIComponent);


-- 月卡礼包
function SubItem2Panel:New(trs)
    self = { };
    setmetatable(self, { __index = SubItem2Panel });
    if (trs) then
        self:Init(trs)
    end
    return self
end


function SubItem2Panel:_Init()
    self._isInit = false

    self:_InitReference();
    self:_InitListener();

end

function SubItem2Panel:_InitReference()

    self.hasGetTxt = UIUtil.GetChildByName(self._transform, "UILabel", "hasGetTxt");
    self.timeTxt = UIUtil.GetChildByName(self._transform, "UILabel", "timeTxt");

    self.btncharge = UIUtil.GetChildByName(self._transform, "UIButton", "btncharge");
    self.btnchargect = UIUtil.GetChildByName(self._transform, "UIButton", "btnchargect");
    self.btngetAward = UIUtil.GetChildByName(self._transform, "UIButton", "btngetAward");

    self.btngetAwardLabel = UIUtil.GetChildByName(self._transform, "UILabel", "btngetAward/Label");

    self.hasGetTxt.gameObject:SetActive(false);

    self.btnchargect.gameObject:SetActive(false);
    self.btngetAward.gameObject:SetActive(false);
    self.timeTxt.gameObject:SetActive(false);

    self:UpdatePanel();

    self.hasGetAward = false;

    MessageManager.AddListener(ActivityGiftsProxy, ActivityGiftsProxy.MESSAGE_GETYUEKAINFOS_COMPLETE, SubItem2Panel.GetYueKaInfosHandler, self);
    MessageManager.AddListener(ActivityGiftsProxy, ActivityGiftsProxy.MESSAGE_GETYUEKAAWARDS_COMPLETE, SubItem2Panel.GetYueKaAwardsHandler, self);

    MessageManager.AddListener(MallPanel, MallPanel.MESSAGE_MALLPANEL_CLOSE, SubItem2Panel.MallPanelCloseHandler, self);

    ActivityGiftsProxy.GetYueKaInfos()
end



function SubItem2Panel:_InitListener()
    self._onClickBtncharge = function(go) self:_OnClickBtncharge() end
    UIUtil.GetComponent(self.btncharge, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtncharge);

    UIUtil.GetComponent(self.btnchargect, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtncharge);

    self._onClickBtngetAward = function(go) self:_OnClickBtngetAward() end
    UIUtil.GetComponent(self.btngetAward, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtngetAward);

end

function SubItem2Panel:_OnClickBtncharge()
    -- ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 3 })
    -- ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});
    self.chargeHandler = function()
        self:BuySuccess()
    end

    VIPManager.SendCharge(1, self.chargeHandler);

end

function SubItem2Panel:BuySuccess()

    ActivityGiftsProxy.GetYueKaInfos();

end

function SubItem2Panel:_OnClickBtngetAward()

    if self.hasGetAward then
        MsgUtils.ShowTips("ActivityGifts/SubItem2Panel/label1");
    else
        ActivityGiftsProxy.GetYueKaAwards(1)
        -- 1 是月卡  recharge.lua 的 id
    end

end


--[[
输入：
输出：
s : int 剩余次数 0：无
f : int 1:表示已领取 0： 表示未领取
]]
function SubItem2Panel:GetYueKaInfosHandler(data)


    local s = data.s;
    local f = data.f;

    if f == 1 then
        self.hasGetAward = true;
        self.btngetAwardLabel.text = LanguageMgr.Get("ActivityGifts/SubItem2Panel/label4");

    else
        self.hasGetAward = false;

        self.btngetAwardLabel.text = LanguageMgr.Get("ActivityGifts/SubItem2Panel/label3");

    end

    self.timeTxt.text = LanguageMgr.Get("ActivityGifts/SubItem2Panel/label2", { n = s });


    if s == 0 then
        self.btncharge.gameObject:SetActive(true);

        self.timeTxt.gameObject:SetActive(false);
        self.btnchargect.gameObject:SetActive(false);
        self.btngetAward.gameObject:SetActive(false);

    else
        self.btncharge.gameObject:SetActive(false);

        self.timeTxt.gameObject:SetActive(true);
        self.btnchargect.gameObject:SetActive(true);
        self.btngetAward.gameObject:SetActive(true);

    end

    MessageManager.Dispatch(ActivityGiftsPanel, ActivityGiftsPanel.MESSAGE_ACTIVITYGIFTS_UPDATETIPSTATE);


end

--[[
04 领取月卡礼包
输入：
输出：

]]
function SubItem2Panel:GetYueKaAwardsHandler(data)

    self.hasGetAward = true;

    ActivityGiftsProxy.GetYueKaInfos()


end

function SubItem2Panel:MallPanelCloseHandler()

    ActivityGiftsProxy.GetYueKaInfos()
end


function SubItem2Panel:_Dispose()

    UIUtil.GetComponent(self.btncharge, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btnchargect, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.btngetAward, "LuaUIEventListener"):RemoveDelegate("OnClick");

    MessageManager.RemoveListener(ActivityGiftsProxy, ActivityGiftsProxy.MESSAGE_GETYUEKAINFOS_COMPLETE, SubItem2Panel.GetYueKaInfosHandler);
    MessageManager.RemoveListener(ActivityGiftsProxy, ActivityGiftsProxy.MESSAGE_GETYUEKAAWARDS_COMPLETE, SubItem2Panel.GetYueKaAwardsHandler);

    MessageManager.RemoveListener(MallPanel, MallPanel.MESSAGE_MALLPANEL_CLOSE, SubItem2Panel.MallPanelCloseHandler);

    self._onClickBtncharge = nil;
    self.chargeHandler = nil;

end

function SubItem2Panel:_DisposeReference()


end

function SubItem2Panel:UpdatePanel()



end

