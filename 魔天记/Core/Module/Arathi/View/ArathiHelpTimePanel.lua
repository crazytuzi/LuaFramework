require "Core.Module.Common.UISubPanel";
require "Core.Module.Arathi.View.Item.ArathiHelpTimeListItem"

local timeCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_TIME);

ArathiHelpTimePanel = class("ArathiHelpTimePanel", UISubPanel)

function ArathiHelpTimePanel:New(transform)
    if (transform) then
        self = { };
        setmetatable(self, { __index = ArathiHelpTimePanel });
        self:Init(transform)
        return self;
    end
    return nil;
end

function ArathiHelpTimePanel:_InitReference()
    self._trsList = UIUtil.GetChildByName(self._transform, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, ArathiHelpTimeListItem);

    self._phalanx:Build(table.getCount(timeCfg), 1, timeCfg);
end

function ArathiHelpTimePanel:_InitListener()

end

function ArathiHelpTimePanel:_DisposeListener()

end

function ArathiHelpTimePanel:_DisposeReference()
    self._trsList = nil;
    self._scrollView = nil;
    self._phalanxInfo = nil;
    self._phalanx:Dispose()
    self._phalanx = nil;
end