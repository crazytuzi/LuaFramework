require "Core.Module.Common.UIItem"

ArathiHelpTimeListItem = UIItem:New();

function ArathiHelpTimeListItem:_Init()
    self._txtTurn = UIUtil.GetChildByName(self.transform, "UILabel", "txtTurn");
    self._txtStart = UIUtil.GetChildByName(self.transform, "UILabel", "txtStart");
    self._txtFight = UIUtil.GetChildByName(self.transform, "UILabel", "txtFight");
    self._txtEnd = UIUtil.GetChildByName(self.transform, "UILabel", "txtEnd");

    self:UpdateItem(self.data);
end

function ArathiHelpTimeListItem:_Dispose()
    self._txtTurn = nil;
    self._txtStart = nil;
    self._txtFight = nil;
    self._txtEnd = nil;
end

function ArathiHelpTimeListItem:UpdateItem(data)
    self.data = data;
    if (data and self._txtTurn) then
        self._txtTurn.text = LanguageMgr.Get("Arathi/help/turn", { n = data.id });
        self._txtStart.text = data["enter"];
        self._txtFight.text = data["start"];
        self._txtEnd.text = data["end"];
    end
end
