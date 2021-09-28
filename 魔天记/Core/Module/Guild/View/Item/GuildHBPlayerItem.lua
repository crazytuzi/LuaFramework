require "Core.Module.Common.UIItem"

GuildHBPlayerItem = UIItem:New();

function GuildHBPlayerItem:_Init()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "imgIcon");
    self._imgFlag = UIUtil.GetChildByName(self.transform, "UISprite", "imgFlag");
    self._txtMoney = UIUtil.GetChildByName(self.transform, "UILabel", "txtMoney");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "txtLevel");
    self:UpdateItem(self.data);
end

function GuildHBPlayerItem:_Dispose()
    self._imgIcon = nil;
    self._imgFlag = nil;
    self._txtMoney = nil;
    self._txtName = nil;
    self._txtLevel = nil;
end

function GuildHBPlayerItem:UpdateItem(data)
    self.data = data;
    if (data) then
        self._imgFlag.gameObject:SetActive(data.best == true)
        self._imgIcon.spriteName = data.pkind .. "";
        self._txtMoney.text = data.bgold
        self._txtName.text = data.pn
        self._txtLevel.text = data.plv
    end
end