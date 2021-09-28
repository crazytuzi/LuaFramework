require "Core.Module.Common.UIItem"

local XuanBaoTypeItem = UIItem:New();

function XuanBaoTypeItem:_Init()

	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._icoLock = UIUtil.GetChildByName(self.transform, "UISprite", "icoLock");
    self._icoLock.alpha = 0;

    self._icoRedPoint = UIUtil.GetChildByName(self.transform, "UISprite", "icoRedPoint");
    self._icoRedPoint.alpha = 0;

	self._icon_select = UIUtil.GetChildByName(self.transform, "UISprite", "icon_select");
	self._icon_select.gameObject:SetActive(false);

	self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self:UpdateItem(self.data);
end

function XuanBaoTypeItem:SetSelect(v)
    local b = self.data == v
	self._icon_select.gameObject:SetActive(b);
end

function XuanBaoTypeItem:_Dispose()
    UIUtil.GetComponent(self.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
end

function XuanBaoTypeItem:_OnClickBtn()
    if self.data then
        if self._isOpen  then
            MessageManager.Dispatch(XuanBaoNotes, XuanBaoNotes.ENV_TYPE_SELECT, self.data);
        else
            MsgUtils.ShowTips("common/notOpen");
        end
    end
end

function XuanBaoTypeItem:UpdateItem(data)
    self.data = data;
    
    if data then
        self._txtName.text = data.name;
    else
    	self._txtName.text = "";
    end

    self:UpdateStatus();
end

function XuanBaoTypeItem:UpdateStatus()
    if self.data and self.data.activation <= 0 or XuanBaoManager.GetTypeAwardSt(self.data.activation) > 1 then
        self._icoLock.alpha = 0;
        self._isOpen = true;
    else
        self._icoLock.alpha = 1;
        self._isOpen = false;
    end
end

function XuanBaoTypeItem:UpdateRedPoint()
    local b = false;
    if self.data then
        b = XuanBaoManager.GetTypeRedPoint(self.data.type);
    end
    self._icoRedPoint.alpha = b and 1 or 0;
end

return XuanBaoTypeItem;