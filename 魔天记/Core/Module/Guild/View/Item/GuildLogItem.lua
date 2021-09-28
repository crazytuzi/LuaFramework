require "Core.Module.Common.UIItem"

GuildLogItem = UIItem:New();

function GuildLogItem:_Init()
    
    self._txtLog = UIUtil.GetChildByName(self.transform, "UILabel", "txtLog");

    self:UpdateItem(self.data);
end

function GuildLogItem:_Dispose()
    
end

function GuildLogItem:UpdateItem(data)
    self.data = data;
    
    if data then
        local t = data.t / 1000;
        local ts = os.date('%Y-%m-%d %H:%M', t);
        local content = ts .. " " .. data.msg;
        self._txtLog.text = content;
    else
        self._txtLog.text = "";
    end
end
