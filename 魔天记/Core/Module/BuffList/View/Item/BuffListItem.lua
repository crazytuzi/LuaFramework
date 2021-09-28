require "Core.Module.Common.UIItem"

BuffListItem = UIItem:New();

function BuffListItem:_Init()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "imgIcon");
    self._txtValue = UIUtil.GetChildByName(self.transform, "UILabel", "txtValue");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
    self._txtTime = UIUtil.GetChildByName(self.transform, "UILabel", "txtTime");
    self:UpdateItem(self.data);
    self:Update();
end

function BuffListItem:_Dispose()
    self._imgIcon = nil;
    self._txtValue = nil;
    self._txtName = nil;
    self._txtTime = nil;
end

function BuffListItem:UpdateItem(data)
    self.data = data;
    if (data) then
        self._txtName.text = data.info.name;
        self._txtValue.text = data.info.buff_desc;
        self._imgIcon.spriteName = data.info.icon_id;
    end
end
local  timeTranlateFun = GetTimeByStr3
function BuffListItem:Update()
    if (self.data) then
        self._txtTime.text = "[94ade7]剩余时间：[-][9cff8b]" ..timeTranlateFun(self.data.curCoolTime) .. "[-]";
    end
end