require "Core.Module.Common.UIItem"

WildBossVipTabItem = UIItem:New();

function WildBossVipTabItem:_Init()
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._icoSelected = UIUtil.GetChildByName(self.transform, "UISprite", "icoSelected");
    self._icoSelected.alpha = 0;

    self._onClick = function(go) self:_OnClick() end
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

    self:UpdateItem(self.data);
end

function WildBossVipTabItem:_Dispose()
    self._txtName = nil;
    self._icoSelected = nil;

    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;
end

function WildBossVipTabItem:_OnClick()
    if self.data then
        MessageManager.Dispatch(WildBossNotes, WildBossNotes.EVENT_VIP_TAB_CHG, self.index);
    end
end

function WildBossVipTabItem:UpdateItem(data)
    self.data = data;
    if (data) then
        self._txtName.text = LanguageMgr.Get("WildBossVip/tab/" .. data);
    end
end

function WildBossVipTabItem:SetSelected(v)
	self._icoSelected.alpha = v and 1 or 0;
end
