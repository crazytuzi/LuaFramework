require "Core.Module.Activity.View.item.ActivityBottomItem"

ActivityBottomPanelCtr = class("ActivityBottomPanelCtr");

function ActivityBottomPanelCtr:New()
    self = { };
    setmetatable(self, { __index = ActivityBottomPanelCtr });
    return self
end


function ActivityBottomPanelCtr:Init(gameObject)
    self.gameObject = gameObject;

    self.progress = UIUtil.GetChildByName(self.gameObject, "UISprite", "progress");

    for i = 1, 5 do
        self["gift" .. i] = UIUtil.GetChildByName(self.gameObject, "Transform", "gift" .. i);
        self["giftCtr" .. i] = ActivityBottomItem:New();
        self["giftCtr" .. i]:Init(self["gift" .. i], i);

        self["avTxt" .. i] = UIUtil.GetChildByName(self.gameObject, "UILabel", "avTxt" .. i);
    end


    MessageManager.AddListener(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_AV_CHANGE, ActivityBottomPanelCtr.ServerDataChange, self);

end

function ActivityBottomPanelCtr:ServerDataChange()

    local curr_av = ActivityDataManager.GetAv();

    local active_condition = ActivityDataManager.Get_activity_reward_lvs();
    local id = ActivityDataManager.Get_activity_reward_id();

    for i = 1, 5 do
        self["avTxt" .. i].text = "" .. active_condition[i];
        self["giftCtr" .. i]:UpInfo(id, curr_av, active_condition[i]);
    end

    if curr_av <= 0 then
        self.progress.gameObject:SetActive(false);

    else
        self.progress.gameObject:SetActive(true);
        self.progress.width = 940 *(curr_av *(1 / active_condition[5]));
    end

end

function ActivityBottomPanelCtr:Show()


    self.gameObject.gameObject:SetActive(true);
end

function ActivityBottomPanelCtr:Hide()


    self.gameObject.gameObject:SetActive(false);
end

function ActivityBottomPanelCtr:Dispose()

    MessageManager.RemoveListener(ActivityDataManager, ActivityDataManager.MESSAGE_SERVERDATA_AV_CHANGE, ActivityBottomPanelCtr.ServerAvDataChange);

    for i = 1, 5 do
        self["giftCtr" .. i]:Dispose()
    end

    self.gameObject = nil;
    self.progress = nil;

    for i = 1, 5 do
        self["gift" .. i] = nil;
        self["giftCtr" .. i] = nil;
    end


end