require "Core.Module.Common.Panel"

require "Core.Module.ActivityGifts.View.Item.SubItem1Panel"
require "Core.Module.ActivityGifts.View.Item.SubItem2Panel"
require "Core.Module.ActivityGifts.View.Item.SubItem3Panel"
require "Core.Module.ActivityGifts.View.Item.SubItem4Panel"
require "Core.Module.ActivityGifts.View.Item.SubItem5Panel"

require "Core.Module.ActivityGifts.View.Item.ActivityGiftsTypeItem"

require "Core.Manager.Item.ActivityGiftsDataManager"

ActivityGiftsPanel = class("ActivityGiftsPanel", Panel);

ActivityGiftsPanel.MESSAGE_ACTIVITYGIFTS_UPDATETIPSTATE = "MESSAGE_ACTIVITYGIFTS_UPDATETIPSTATE";


function ActivityGiftsPanel:New()
    self = { };
    setmetatable(self, { __index = ActivityGiftsPanel });
    return self
end


function ActivityGiftsPanel:_Init()
    self:_InitReference();
    self:_InitListener();

    self._panelIndex = 1
    self._panels = { }

    self._panels[1] = SubItem1Panel:New(self._trsItem1);
    self._panels[2] = SubItem2Panel:New(self._trsItem2);
    self._panels[3] = SubItem3Panel:New(self._trsItem3);
    self._panels[4] = SubItem4Panel:New(self._trsItem4);
    self._panels[5] = SubItem5Panel:New(self._trsItem5);


    self:BuildSignList()


    MessageManager.AddListener(ActivityGiftsTypeItem, ActivityGiftsTypeItem.MESSAGE_ACTIVITYGIFTSTYPEITEM_SELECT_CHANGE, ActivityGiftsPanel.ChangePanel, self);
    MessageManager.AddListener(ActivityGiftsPanel, ActivityGiftsPanel.MESSAGE_ACTIVITYGIFTS_UPDATETIPSTATE, ActivityGiftsPanel.UpdateTipState, self);

    self:UpdatePanel();

    ActivityGiftsProxy.GetRechageAwardLog();
end

function ActivityGiftsPanel:BuildSignList()
    local data = ActivityGiftsDataManager.GetWealTypeData()
    self._phalanx:Build(table.getCount(data), 1, data)
    local item = self._phalanx:GetItem(1)
    if (item) then
        item.itemLogic:SetToggleActive(true);
        self._panelIndex = item.itemLogic.data.code_id;

    end
    self:UpdateTipState();
end

function ActivityGiftsPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._trsItem1 = UIUtil.GetChildByName(self._trsContent, "Transform", "trsItem1");
    self._trsItem2 = UIUtil.GetChildByName(self._trsContent, "Transform", "trsItem2");
    self._trsItem3 = UIUtil.GetChildByName(self._trsContent, "Transform", "trsItem3");
    self._trsItem4 = UIUtil.GetChildByName(self._trsContent, "Transform", "trsItem4");
    self._trsItem5 = UIUtil.GetChildByName(self._trsContent, "Transform", "trsItem5");

    self.bg1 = UIUtil.GetChildByName(self._trsContent, "Transform", "bg1");
    self._coinBar = UIUtil.GetChildByName(self._trsContent, "Transform", "CoinBar");

    self._coinBarCtrl = CoinBar:New(self._coinBar);

    self._phalanxInfo = UIUtil.GetChildByName(self._trsContent, "LuaAsynPhalanx", "phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, ActivityGiftsTypeItem);

    self.hasInit = false;
end

function ActivityGiftsPanel:_Opened()

    self.hasInit = true;

    if self.data == nil then
        return;
    end

    self:DealInfo();

end

function ActivityGiftsPanel:DealInfo()

    local code_id = self.data.code_id;
    if code_id ~= nil then

        self:CheckAndSetSelect(code_id);
    end

    local other = self.data.other;
    if other ~= nil then
        self:UpdateMallSubPanel(other)
    end
end 

function ActivityGiftsPanel:UpdateMallSubPanel(otherInfo)
    if (self._panels[self._panelIndex]) then
        self._panels[self._panelIndex]:UpdatePanel(otherInfo)
    end
end

function ActivityGiftsPanel:SetData(data)
    self.data = data;

    if self.hasInit then
        self:DealInfo();
    end
end



function ActivityGiftsPanel:CheckAndSetSelect(code_id)
    local items = self._phalanx:GetItems()
    if (items) then
        for k, v in ipairs(items) do
            v.itemLogic:CheckAndSetSelect(code_id)
        end
    end
end

function ActivityGiftsPanel:UpdateTipState()

    local items = self._phalanx:GetItems()
    if (items) then
        for k, v in ipairs(items) do
            v.itemLogic:UpdateTipState()
        end
    end
end

function ActivityGiftsPanel:UpdatePanel()
    self:ChangePanel(self._panelIndex)
end

function ActivityGiftsPanel:ChangePanel(to)

    for i = 1, table.getCount(self._panels) do
        if i == to then

            self._panels[i]:SetEnable(true);
        else
            self._panels[i]:SetEnable(false);
        end
    end

    if to == 3 then
        self.bg1.gameObject:SetActive(false);
    else
        self.bg1.gameObject:SetActive(true);
    end

    self._panelIndex = to
    self:UpdateSignInSubPanel()
end

function ActivityGiftsPanel:UpdateSignInSubPanel()
    if (self._panels[self._panelIndex] ~= nil) then
        self._panels[self._panelIndex]:UpdatePanel()
    end
end



function ActivityGiftsPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function ActivityGiftsPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(ActivityGiftsNotes.CLOSE_ACTIVITYGIFTSPANEL)

end

function ActivityGiftsPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();

    if (self._phalanx) then
        self._phalanx:Dispose()
        self._phalanx = nil
    end

    if (self._panels) then
        for k, v in pairs(self._panels) do
            v:Dispose()
            self._panels[k] = nil
        end
    end

    self._panels = nil;

end

function ActivityGiftsPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

    MessageManager.RemoveListener(ActivityGiftsTypeItem, ActivityGiftsTypeItem.MESSAGE_ACTIVITYGIFTSTYPEITEM_SELECT_CHANGE, ActivityGiftsPanel.ChangePanel);
    MessageManager.RemoveListener(ActivityGiftsPanel, ActivityGiftsPanel.MESSAGE_ACTIVITYGIFTS_UPDATETIPSTATE, ActivityGiftsPanel.UpdateTipState);
end

function ActivityGiftsPanel:_DisposeReference()

    self._coinBarCtrl:Dispose();
    self._coinBarCtrl = nil;

    self._btn_close = nil;
    self._trsItem1 = nil;
    self._trsItem2 = nil;
    self._trsItem3 = nil;
    self._trsItem4 = nil;
    self._trsItem5 = nil;
end
