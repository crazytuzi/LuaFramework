require "Core.Module.Common.Panel"

require "Core.Manager.Item.LingYaoDataManager"

require "Core.Module.LingYao.controll.LingYaoSetControll"
require "Core.Module.LingYao.controll.LingYaoHeChengControll"

LingYaoPanel = class("LingYaoPanel", Panel);
function LingYaoPanel:New()
    self = { };
    setmetatable(self, { __index = LingYaoPanel });
    return self
end


function LingYaoPanel:_Init()
    self:_InitReference();
    self:_InitListener();




end

function LingYaoPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");

    self._btn_tb1 = UIUtil.GetChildInComponents(btns, "btn_tb1");
    self._btn_tb2 = UIUtil.GetChildInComponents(btns, "btn_tb2");

    self._btn_tb1_npoint = UIUtil.GetChildByName(self._btn_tb1, "Transform", "npoint");
    self._btn_tb2_npoint = UIUtil.GetChildByName(self._btn_tb2, "Transform", "npoint");

    self.toggle1 = UIUtil.GetChildByName(self._trsContent, "UIToggle", "trsToggle/btn_tb1");
    self.toggle2 = UIUtil.GetChildByName(self._trsContent, "UIToggle", "trsToggle/btn_tb2");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self.lingyaoPanel = UIUtil.GetChildByName(self.mainView, "Transform", "lingyaoPanel");
    self.hechengPanbel = UIUtil.GetChildByName(self.mainView, "Transform", "hechengPanbel");

    self.lingYaoSetControll = LingYaoSetControll:New();
    self.lingYaoSetControll:Init(self.lingyaoPanel);

    self.lingYaoHeChengControll = LingYaoHeChengControll:New();
    self.lingYaoHeChengControll:Init(self.hechengPanbel);


    MessageManager.AddListener(LingYaoProxy, LingYaoProxy.MESSAGE_LINGYAO_COM_COMPLETE, LingYaoPanel.LingYaoComCompleteHandler, self);

    MessageManager.AddListener(LingYaoSetControll, LingYaoSetControll.MESSAGE_LINGYAOSETCONTROLL_NPOINT_CHANGE, LingYaoPanel.LingYaoSetControllTipChange, self);
    MessageManager.AddListener(LingYaoSetControll, LingYaoSetControll.MESSAGE_LINGYAOSETCONTROLL_BT_NPOINT_CHANGE, LingYaoPanel.LingYaoSetControllTBTipChange, self);

    MessageManager.AddListener(LingYaoHeChengPanelCtr, LingYaoHeChengPanelCtr.MESSAGE_LINGYAOHECHENGPANELCTR_NPOINT_CHANGE, LingYaoPanel.LingYaoHeChengPanelCtrTipChange, self);


    LingYaoSetControll.CheckNPoint()
    self.lingYaoHeChengControll:UpInfos(false);



end

function LingYaoPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

    self._onClickBtn_tb1 = function(go) self:_OnClickBtn_tb1(self) end
    UIUtil.GetComponent(self._btn_tb1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_tb1);
    self._onClickBtn_tb2 = function(go) self:_OnClickBtn_tb2(self) end
    UIUtil.GetComponent(self._btn_tb2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_tb2);



end

function LingYaoPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(LingYaoNotes.CLOSE_LINGYAOPANEL);
    PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.LingYao)
end

-- {index=index,b=true}
function LingYaoPanel:LingYaoSetControllTipChange(data)

    local tg = self.lingYaoSetControll["_btnTog_npoint" .. data.index];
    tg.gameObject:SetActive(data.b);

end

function LingYaoPanel:LingYaoSetControllTBTipChange(data)
    self._btn_tb1_npoint.gameObject:SetActive(data.b);
end


function LingYaoPanel:LingYaoHeChengPanelCtrTipChange(data)
    self._btn_tb2_npoint.gameObject:SetActive(data.b);
    self.lingYaoHeChengControll._btnTog_npoint1.gameObject:SetActive(data.b);

end



function LingYaoPanel:LingYaoComCompleteHandler()

    self.lingYaoSetControll:UpInfos()
    self.lingYaoHeChengControll:UpInfos(true)


    LingYaoSetControll.CheckNPoint()

end



function LingYaoPanel:SetSelect(index)

    if index == 1 then
        self.toggle1.value = true;
        -- self.toggle2:Set(false);

        self:_OnClickBtn_tb1()
    elseif index == 2 then

        --  self.toggle1:Set(false);
         self.toggle2.value = true;
        self:_OnClickBtn_tb2();
    end

end

function LingYaoPanel:_OnClickBtn_tb1()

    self.lingYaoSetControll:Show();
    self.lingYaoHeChengControll:Hide();
end

function LingYaoPanel:_OnClickBtn_tb2()
    self.lingYaoSetControll:Hide();
    self.lingYaoHeChengControll:Show();
end


function LingYaoPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function LingYaoPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

    UIUtil.GetComponent(self._btn_tb1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_tb1 = nil;
    UIUtil.GetComponent(self._btn_tb2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_tb2 = nil;


end

function LingYaoPanel:_DisposeReference()

    MessageManager.RemoveListener(LingYaoProxy, LingYaoProxy.MESSAGE_LINGYAO_COM_COMPLETE, LingYaoPanel.LingYaoComCompleteHandler);
    MessageManager.RemoveListener(LingYaoSetControll, LingYaoSetControll.MESSAGE_LINGYAOSETCONTROLL_NPOINT_CHANGE, LingYaoPanel.LingYaoSetControllTipChange);
    MessageManager.RemoveListener(LingYaoSetControll, LingYaoSetControll.MESSAGE_LINGYAOSETCONTROLL_BT_NPOINT_CHANGE, LingYaoPanel.LingYaoSetControllTBTipChange);
    MessageManager.RemoveListener(LingYaoHeChengPanelCtr, LingYaoHeChengPanelCtr.MESSAGE_LINGYAOHECHENGPANELCTR_NPOINT_CHANGE, LingYaoPanel.LingYaoHeChengPanelCtrTipChange);


    self.lingYaoSetControll:Dispose();
    self.lingYaoHeChengControll:Dispose();

    LingYaoHeChengTypeItem.currSelected = { };
    LingYaoHeProItem.currSelected = { };

    self._btn_close = nil;
    self._btn_tb1 = nil;
    self._btn_tb2 = nil;


    self._trsToggle = nil;
    self._trsToggle = nil;

    self.mainView = nil;

    self.lingyaoPanel = nil;
    self.hechengPanbel = nil;

    self.lingYaoSetControll = nil;
    self.lingYaoHeChengControll = nil;

end
