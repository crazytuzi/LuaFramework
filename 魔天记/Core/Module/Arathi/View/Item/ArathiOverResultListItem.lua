require "Core.Module.Common.UIItem"
require "Core.Module.Arathi.View.Item.ArathiAwardItem"

ArathiOverResultListItem = UIItem:New();

function ArathiOverResultListItem:_Init()
    self._awards = { };
    self._icoRank = UIUtil.GetChildByName(self.transform, "UISprite", "icoRank");
    self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "txtRank");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtPower = UIUtil.GetChildByName(self.transform, "UILabel", "txtPower");
    self._txtKHD = UIUtil.GetChildByName(self.transform, "UILabel", "txtKHD");
    self._txtHurt = UIUtil.GetChildByName(self.transform, "UILabel", "txtHurt");
    self._txtHonor = UIUtil.GetChildByName(self.transform, "UILabel", "txtHonor");
    for i = 1, 3 do
        local tran = UIUtil.GetChildByName(self.transform, "Transform", "award" .. i);
        local item = ArathiAwardItem:New(tran);
        self._awards[i] = item
    end

    self:UpdateItem(self.data);
end

function ArathiOverResultListItem:_Dispose()
    for i, v in pairs(self._awards) do
        v:Dispose()
    end
    self._awards = nil;
    self._icoRank = nil;
    self._txtRank = nil;
    self._txtName = nil;
    self._txtPower = nil;
    self._txtKHD = nil;
    self._txtHurt = nil;
    self._txtHonor = nil;
end

function ArathiOverResultListItem:UpdateItem(data)
    self.data = data;
    if (data and self._icoRank) then
        if (data.id > 3) then
            self._txtRank = data.id
            self._icoRank.gameObject:SetActive(false);
        else
            self._txtRank = "";
            self._icoRank.spriteName = "no" .. data.id;
            self._icoRank.gameObject:SetActive(true);
        end
        self._txtName.text = data.pn;
        self._txtPower.text = data.ft;
        self._txtKHD.text = data.kc .. "/" .. data.ac .. "/" .. data.dc;
        self._txtHurt.text = data.cb;
        self._txtHonor.text = data.h;
        if (data.raw) then
            local index = 1;
            for i, v in pairs(data.raw) do
                if (index <= 3) then
                    self._awards[i]:SetProductId(v.spId, v.am);
                    index = index + 1
                end
            end
        end
    end
end
