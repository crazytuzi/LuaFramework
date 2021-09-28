require "Core.Module.Common.UIItem"

DaysRankDayItem = UIItem:New();

function DaysRankDayItem:_Init()

	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtDay = UIUtil.GetChildByName(self.transform, "UILabel", "txtDay");
    self._txtDayName = UIUtil.GetChildByName(self.transform, "UILabel", "txtDayName");

    self._icoRedPoint = UIUtil.GetChildByName(self.transform, "UISprite", "icoRedPoint");
    self._icoRedPoint.alpha = 0;

    self._icoLock = UIUtil.GetChildByName(self.transform, "UISprite", "icoLock");
    self._icoLock.alpha = 0;

	self._icon_select = UIUtil.GetChildByName(self.transform, "UISprite", "icon_select");
	self._icon_select.gameObject:SetActive(false);

	self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self:UpdateItem(self.data);
end

function DaysRankDayItem:SetSelect(v)
    --第一天判断
    local b = self.data == v or (self.data == 1 and v == 2);
	self._icon_select.gameObject:SetActive(b);
end

function DaysRankDayItem:_Dispose()
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
end

function DaysRankDayItem:_OnClickBtn()
    if self.data then
        MessageManager.Dispatch(DaysRankNotes, DaysRankNotes.ENV_DAYS_SELECT, self.data);
    end
end

function DaysRankDayItem:UpdateItem(data)
    self.data = data;
    
    if data then

        self._icoLock.alpha = 0;

        local toDay = KaiFuManager.GetKaiFuHasDate();
        --第一天判断
        if toDay == data or (toDay == 2 and data == 1) then
            self._txtName.text = LanguageMgr.Get("daysRank/type/"..data);
            self._txtDayName.text = "";
            self._txtDay.text = "";
        else
            self._txtName.text = "";
            self._txtDayName.text = LanguageMgr.Get("daysRank/type/"..data);
            if toDay < data then
                self._txtDay.text = LanguageMgr.Get("daysRank/list/day/1", {day = data - toDay});
                self._icoLock.alpha = 1;
            else
                self._txtDay.text = LanguageMgr.Get("daysRank/list/day/0");
            end
        end

        self:UpdateRedPoint();
    else
    	self._txtName.text = "";
        self._txtDay.text = "";
        self._txtDayName.text = "";
    end
end

function DaysRankDayItem:UpdateRedPoint()
    self._icoRedPoint.alpha = DaysRankProxy.GetDayRedPoint(self.data) and 1 or 0;
end