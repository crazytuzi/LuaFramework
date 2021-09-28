require "Core.Module.Common.UIItem"
require "Core.Module.Guild.View.Item.GuildActListItem";

GuildActPage = UIItem:New();

function GuildActPage:_Init()
    self._phalanxInfo = UIUtil.GetChildByName(self.transform, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildActListItem);
end

function GuildActPage:_Dispose()
    self._phalanx:Dispose();
end

function GuildActPage:UpdateItem(data)
    self.data = data;
    
    if data then
        self._phalanx:Build(2, 5, data);
    else
        self._phalanx:Build(1, 1, {});
    end
end


