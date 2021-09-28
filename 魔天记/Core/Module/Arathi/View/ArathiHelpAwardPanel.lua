require "Core.Module.Common.UISubPanel";
require "Core.Module.Arathi.View.Item.ArathiAwardItem"

local awardCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BATTLEGROUND_AWARD);

ArathiHelpAwardPanel = class("ArathiHelpAwardPanel", UISubPanel)

function ArathiHelpAwardPanel:New(transform)
    if (transform) then
        self = { };
        setmetatable(self, { __index = ArathiHelpAwardPanel });
        self:Init(transform)
        return self;
    end
    return nil;
end

function ArathiHelpAwardPanel:_InitReference()
    local awards = self:_GetAwardByLevel();
    self._products = { }

    self:_SetAwards(awards.first_win, UIUtil.GetChildByName(self._transform, "Transform", "txtLabel1"));
    self:_SetAwards(awards.join_award, UIUtil.GetChildByName(self._transform, "Transform", "txtLabel2"));

    self:_SetAwards(awards.first, UIUtil.GetChildByName(self._transform, "Transform", "rank1"));
    self:_SetAwards(awards.second, UIUtil.GetChildByName(self._transform, "Transform", "rank2"));
    self:_SetAwards(awards.third, UIUtil.GetChildByName(self._transform, "Transform", "rank3"));
    self:_SetAwards(awards.other, UIUtil.GetChildByName(self._transform, "Transform", "rank4"));
end
local insert = table.insert

function ArathiHelpAwardPanel:_SetAwards(awards, uiParent)
    if (awards and uiParent) then
        local index = 1;
        for i, v in pairs(awards) do
            if (index <= 3) then
                local tran = UIUtil.GetChildByName(uiParent, "Transform", "award" .. index);
                local item = ArathiAwardItem:New(tran);
                local sp = string.split(v, "_");
                item:SetProductId(tonumber(sp[1]), tonumber(sp[2]));
                insert(self._products, item);
                index = index + 1;
            end
        end
    end
end

function ArathiHelpAwardPanel:_InitListener()

end

function ArathiHelpAwardPanel:_DisposeListener()

end

function ArathiHelpAwardPanel:_DisposeReference()
    for i, v in pairs(self._products) do
        v:Dispose()
    end
    self._products = { };
end

function ArathiHelpAwardPanel:_GetAwardByLevel()
    local lev = PlayerManager.hero.info.level;
    for i, v in pairs(awardCfg) do
        if (lev >= v.open_lv and lev <= v.end_lv) then
            return v;
        end
    end
    return nil;
end