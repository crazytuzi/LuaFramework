require "Core.Module.Common.Panel"

require "Core.Module.InstancePanel.controlls.EMengPanelCtr"
require "Core.Module.InstancePanel.controlls.PuTongPanelCtr"
require "Core.Module.InstancePanel.controlls.YingXiongPanelCtr"
require "Core.Module.InstancePanel.controlls.BottomPanelCtr"
require "Core.Module.InstancePanel.View.items.InstanceFbItem"

InstancePanel = class("InstancePanel", Panel);
function InstancePanel:New()
    self = { };
    setmetatable(self, { __index = InstancePanel });
    return self
end


function InstancePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function InstancePanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btn_putong = UIUtil.GetChildInComponents(btns, "btn_putong");
    self._btn_yingxiong = UIUtil.GetChildInComponents(btns, "btn_yingxiong");
    -- self._btn_emeng = UIUtil.GetChildInComponents(btns, "btn_emeng");
    self._trsToggle = UIUtil.GetChildByName(self._trsContent, "Transform", "trsToggle");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self._coinBar = UIUtil.GetChildByName(self._trsContent, "CoinBar");
    self._coinBarCtrl = CoinBar:New(self._coinBar);

    self.putong = UIUtil.GetChildByName(self.mainView, "Transform", "putong");
    self.yinxiong = UIUtil.GetChildByName(self.mainView, "Transform", "yinxiong");
    -- self.emeng = UIUtil.GetChildByName(self.mainView, "Transform", "emeng");

    self.bottomPanel = UIUtil.GetChildByName(self.mainView, "Transform", "bottomPanel");

    self.putongCtr = PuTongPanelCtr:New();
    self.yinxiongCtr = YingXiongPanelCtr:New();
    -- self.emengCtr = EMengPanelCtr:New();

    self.bottomPanelCtr = BottomPanelCtr:New();

    self.putongCtr:Init(self.putong)
    self.yinxiongCtr:Init(self.yinxiong)
    -- self.emengCtr:Init(self.emeng)

    self.bottomPanelCtr:Init(self.bottomPanel);



    MessageManager.AddListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_SAO_DANG_COMPLETE, InstancePanel.SaoDangComplete, self);
    MessageManager.AddListener(InstanceDataManager, InstanceDataManager.MESSAGE_0X0F01_CHANGE, InstancePanel.H0x0f01change, self);

    self:_OnClickBtn_putong();
    self.putongCtr:Hide();
    self:SaoDangComplete();


end



function InstancePanel:_Opened()

    if InstanceFbItem.currInFbData == nil then
        self:_OnClickBtn_putong();
    else

        local kind = InstanceFbItem.currInFbData.kind;


        if kind == InstanceDataManager.kind_1 then

            self:_OnClickBtn_putong();
        elseif kind == InstanceDataManager.kind_2 then

            self:_OnClickBtn_yingxiong()
        elseif kind == InstanceDataManager.kind_3 then

            --  self:_OnClickBtn_emeng()
        end

    end

    self._gameObject.gameObject:SetActive(false);
    self._gameObject.gameObject:SetActive(true);

end


function InstancePanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_putong = function(go) self:_OnClickBtn_putong(self) end
    UIUtil.GetComponent(self._btn_putong, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_putong);
    self._onClickBtn_yingxiong = function(go) self:_OnClickBtn_yingxiong(self) end
    UIUtil.GetComponent(self._btn_yingxiong, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_yingxiong);

end

function InstancePanel:SaoDangComplete()

    InstanceDataManager.UpData(InstancePanel.UpInfos, self);
end

function InstancePanel:H0x0f01change()

    self:UpInfos();

end





function InstancePanel:UpInfos()

    if self.putongCtr == nil then
        return ;
    end
    self.putongCtr:UpInfos()
    self.yinxiongCtr:UpInfos()
    -- self.emengCtr:UpInfos()

    if self.showIndex == 1 then
        self.bottomPanelCtr:setData(InstanceDataManager.InstanceType.MainInstance, InstanceDataManager.kind_1);
    elseif self.showIndex == 2 then
        self.bottomPanelCtr:setData(InstanceDataManager.InstanceType.MainInstance, InstanceDataManager.kind_2);
    elseif self.showIndex == 3 then
        self.bottomPanelCtr:setData(InstanceDataManager.InstanceType.MainInstance, InstanceDataManager.kind_3);
    end




    -- local num = InstanceDataManager.GetElsenum();
    -- self.numLabel.text = "" .. num;
end

function InstancePanel:_OnClickBtn_close()
    ModuleManager.SendNotification(InstancePanelNotes.CLOSE_INSTANCEPANEL);
end

function InstancePanel:SetBtnToggleActive(btn, bool)
    local toggle = UIUtil.GetComponent(btn, "UIToggle");
    toggle.value = bool;
end

function InstancePanel:SetData(data)

    if data ~= nil then
        self.fb_id = data.fb_id;
        local cf = InstanceDataManager.GetMapCfById(self.fb_id);

        InstanceFbItem.currInFbData = cf;


    end

end

function InstancePanel:_OnClickBtn_putong()
    self:SetBtnToggleActive(self._btn_putong, true);
    self:SetBtnToggleActive(self._btn_yingxiong, false);
    -- self:SetBtnToggleActive(self._btn_emeng, false);

    self.showIndex = 1;

    self.putongCtr:Show();
    self.yinxiongCtr:Hide();
    -- self.emengCtr:Hide();

    self.bottomPanelCtr:setData(InstanceDataManager.InstanceType.MainInstance, InstanceDataManager.kind_1);

end

function InstancePanel:_OnClickBtn_yingxiong()

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv >= 15 then
        self:SetBtnToggleActive(self._btn_putong, false);
        self:SetBtnToggleActive(self._btn_yingxiong, true);
        -- self:SetBtnToggleActive(self._btn_emeng, false);

        self.showIndex = 2;

        self.putongCtr:Hide();
        self.yinxiongCtr:Show();
        -- self.emengCtr:Hide();

        self.bottomPanelCtr:setData(InstanceDataManager.InstanceType.MainInstance, InstanceDataManager.kind_2);
    else

        self:ReSetBts();
        MsgUtils.ShowTips("InstancePanel/InstancePanel/label1");
    end



end

function InstancePanel:ReSetBts()


    if self.showIndex == 1 then
        self:SetBtnToggleActive(self._btn_putong, true);
        self:SetBtnToggleActive(self._btn_yingxiong, false);
        --  self:SetBtnToggleActive(self._btn_emeng, false);
    elseif self.showIndex == 2 then
        self:SetBtnToggleActive(self._btn_putong, false);
        self:SetBtnToggleActive(self._btn_yingxiong, true);
        --  self:SetBtnToggleActive(self._btn_emeng, false);
    end



end

--[[
function InstancePanel:_OnClickBtn_emeng()

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv >= 18 then

        self:SetBtnToggleActive(self._btn_putong, false);
        self:SetBtnToggleActive(self._btn_yingxiong, false);
        self:SetBtnToggleActive(self._btn_emeng, true);

        self.showIndex = 3;

        self.putongCtr:Hide();
        self.yinxiongCtr:Hide();
        self.emengCtr:Show();

        self.bottomPanelCtr:setData(InstanceDataManager.InstanceType.MainInstance, InstanceDataManager.kind_3);

    else
        self:ReSetBts();
        MsgUtils.ShowTips("InstancePanel/InstancePanel/label2");
    end

end
]]
function InstancePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    self.putongCtr:Dispose()
    self.yinxiongCtr:Dispose()
    -- self.emengCtr:Dispose()
    self.bottomPanelCtr:Dispose()




    self._trsToggle = nil;

    self.mainView = nil;

    self._coinBar = nil;
    self._coinBarCtrl = nil;

    self.putong = nil;
    self.yinxiong = nil;
    self.emeng = nil;

    self.bottomPanel = nil;



    self.putongCtr = nil;
    self.yinxiongCtr = nil;
    -- self.emengCtr = nil;

    self.bottomPanelCtr = nil;



end

function InstancePanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_putong, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_putong = nil;
    UIUtil.GetComponent(self._btn_yingxiong, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_yingxiong = nil;


    MessageManager.RemoveListener(InstanceDataManager, InstanceDataManager.MESSAGE_0X0F01_CHANGE, InstancePanel.H0x0f01change, self);
    MessageManager.RemoveListener(InstancePanelProxy, InstancePanelProxy.MESSAGE_SAO_DANG_COMPLETE, InstancePanel.SaoDangComplete);

end

function InstancePanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_putong = nil;
    self._btn_yingxiong = nil;
    -- self._btn_emeng = nil;

    self._coinBarCtrl:Dispose();
end
