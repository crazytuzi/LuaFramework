require "Core.Module.Common.UIItem"

MailListItem = UIItem:New(); 
 
function MailListItem:_Init()
    local txts = UIUtil.GetComponentsInChildren(self.transform, "UILabel");
    self._txtMailName = UIUtil.GetChildInComponents(txts, "txtMailName");
    self._txtMailType = UIUtil.GetChildInComponents(txts, "txtMailType");
    self._txtMailDate = UIUtil.GetChildInComponents(txts, "txtMailDate");

    self._imgAnnex = UIUtil.GetChildByName(self.transform, "UISprite", "imgAnnex");
    self._imgHighLight = UIUtil.GetChildByName(self.transform, "UISprite", "imgHighLight");
    self._imgHighLight.gameObject:SetActive(false);
    self._onClickBtnIcon = function(go) self:_OnClickBtnIcon(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnIcon);
    self:UpdateItem(self.data);
end

function MailListItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnIcon = nil;
end

function MailListItem:UpdateItem(data)
    self.data = data
    if (data ~= nil) then
        self._imgAnnex.gameObject:SetActive(data.status ~= 2 and data.annex > 0);
        self._txtMailName.text = data.title;
        self._txtMailType.text = LanguageMgr.Get("mail/st/"..data.status);
        self._txtMailDate.text = os.date('%Y-%m-%d', tonumber(data.time) / 1000); -- %H:%M:%S
        --self:UpdateSelected();
    else
        self._imgAnnex.gameObject:SetActive(false);
    end
end

function MailListItem:UpdateSelected(data)
    if self.data then
        local selected = self.data.id == data.id;
        self._imgHighLight.gameObject:SetActive(selected);
    end
end

function MailListItem:_OnClickBtnIcon()
    if (self.data == nil) then return end
    MessageManager.Dispatch(MailManager, MailNotes.MAIL_SELECTID_CHANGE, self.data);
end

