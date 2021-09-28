require "Core.Module.Common.UIItem"

ActivityGiftsTypeItem = class("ActivityGiftsTypeItem", UIItem);

ActivityGiftsTypeItem.MESSAGE_ACTIVITYGIFTSTYPEITEM_SELECT_CHANGE = "MESSAGE_ACTIVITYGIFTSTYPEITEM_SELECT_CHANGE";

function ActivityGiftsTypeItem:New()
    self = { };
    setmetatable(self, { __index = ActivityGiftsTypeItem });
    return self
end


function ActivityGiftsTypeItem:_Init()
    self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")
    self._txtTitle = UIUtil.GetChildByName(self.transform, "UILabel", "title")
    self._goTip = UIUtil.GetChildByName(self.transform, "tip").gameObject
    self._onClickItem = function(go) self:_OnClickItem() end
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
    self:UpdateItem(self.data)
end

function ActivityGiftsTypeItem:_OnClickItem()
    local str = ""
    if (self.data.code_id == 1) then
        str = "每日限购"
    elseif self.data.code_id == 2 then
        str = "月卡礼包"
    elseif self.data.code_id == 3 then
        str = "充值"
    elseif self.data.code_id == 4 then
        str = "累计充值"
    elseif self.data.code_id == 5 then
        str = "成长基金"
    end

    if (str ~= "") then
        LogHttp.SendOperaLog(str)
    end


    MessageManager.Dispatch(ActivityGiftsTypeItem, ActivityGiftsTypeItem.MESSAGE_ACTIVITYGIFTSTYPEITEM_SELECT_CHANGE, self.data.code_id)

end

function ActivityGiftsTypeItem:_Dispose()
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;

    self.data = nil;
    self._toggle = nil;
    self._txtTitle = nil;
    self._goTip = nil;
    self._onClickItem = nil;



end

function ActivityGiftsTypeItem:CheckAndSetSelect(code_id)

    if self.data ~= nil and self.data.code_id == code_id then
      self:SetToggleActive(true);

    end

end

function ActivityGiftsTypeItem:UpdateItem(data)
    self.data = data
    if (self.data) then
        self._txtTitle.text = self.data.title_name
    end
end

function ActivityGiftsTypeItem:SetToggleActive(active)
    self._toggle.value = active
    if (active) then
        self:_OnClickItem()
    end

end

function ActivityGiftsTypeItem:UpdateTipState()
    if (self.data) then
        if (self.data.code_id == 1) then
            -- ????????
            self._goTip:SetActive(false)


        elseif self.data.code_id == 2 then
            -- '????????
            local b = ActivityGiftsProxy.GetYueKaInfos_neeShowTip();
            self._goTip:SetActive(b)
        elseif self.data.code_id == 3 then
            -- ????????


            self._goTip:SetActive(false)
        elseif self.data.code_id == 4 then
            -- ????????
            local b = RechargRewardDataManager.GetIsHasAwardToGet(RechargRewardDataManager.TYPE_TOTAL_RECHARGE);

            self._goTip:SetActive(b)
        elseif self.data.code_id == 5 then
            -- ????????
            local b = ActivityGiftsProxy.GetChengZhangJiJing_needTip();
            self._goTip:SetActive(b)
        else
            self._goTip:SetActive(false)
        end
    end
end