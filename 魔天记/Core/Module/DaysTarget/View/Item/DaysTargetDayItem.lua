require "Core.Module.Common.UIItem"

DaysTargetDayItem = UIItem:New();

function DaysTargetDayItem:_Init()

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

function DaysTargetDayItem:SetSelect(v)
    local b = self.data == v
	self._icon_select.gameObject:SetActive(b);
end

function DaysTargetDayItem:_Dispose()
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
end

function DaysTargetDayItem:_OnClickBtn()
    if self.data then
        MessageManager.Dispatch(DaysTargetNotes, DaysTargetNotes.ENV_DAYS_SELECT, self.data);
    end
end

function DaysTargetDayItem:UpdateItem(data)
    self.data = data;
    
    if data then

        self._icoLock.alpha = 0;

        local toDay = DaysTargetProxy.GetCacheDay();
        if data.type <= toDay then
            self._txtName.text = data.name;
            self._txtDayName.text = "";
            self._txtDay.text = "";
        else
            self._txtName.text = "";
            self._txtDayName.text = data.name;
            if toDay > 0 and toDay < data.type then
                self._txtDay.text = LanguageMgr.Get("daysRank/list/day/1", {day = data.type - toDay});
                self._icoLock.alpha = 1;
            end
        end

        self:UpdateRedPoint();
    else
    	self._txtName.text = "";
        self._txtDay.text = "";
        self._txtDayName.text = "";
    end
end

function DaysTargetDayItem:UpdateRedPoint()
    local b = false;
    if self.data then
        b = DaysTargetProxy.GetDayRedPoint(self.data.type);
    end
    self._icoRedPoint.alpha = b and 1 or 0;
end