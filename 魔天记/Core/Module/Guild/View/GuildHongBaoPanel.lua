require "Core.Module.Common.Panel"
require "Core.Module.Guild.View.Item.GuildSelfHBItem"
require "Core.Module.Guild.View.Item.GuildHBItem"

GuildHongBaoPanel = class("GuildHongBaoPanel", Panel);

function GuildHongBaoPanel:New()
    self = { };
    setmetatable(self, { __index = GuildHongBaoPanel });
    return self
end

function GuildHongBaoPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    --self:_Test();
    GuildProxy.ReqGetGuildHongBaoData();
end

-- function GuildHongBaoPanel:_Test()
--     local data = {
--         ml =
--         {
--             { rpid = "0", rptid = 1, bgold = 500, st = 0, f = 0 },
--             { rpid = "0", rptid = 2, bgold = 500, st = 1, f = 0 },
--             { rpid = "0", rptid = 3, bgold = 500, st = 1, f = 1 },
--             { rpid = "0", rptid = 4, bgold = 500, st = 0, f = 0 },
--             { rpid = "0", rptid = 5, bgold = 500, st = 0, f = 0 },
--             { rpid = "0", rptid = 6, bgold = 500, st = 0, f = 0 },
--             { rpid = "0", rptid = 7, bgold = 500, st = 0, f = 0 }
--         },
--         tl =
--         {
--             { rpid = "0", rptid = 1, bgold = 500, st = 1, f = 1, on = "玩家名字1" },
--             { rpid = "0", rptid = 2, bgold = 500, st = 1, f = 1, on = "玩家名字1" },
--             { rpid = "0", rptid = 3, bgold = 500, st = 1, f = 0, on = "玩家名字1" },
--             { rpid = "0", rptid = 4, bgold = 500, st = 1, f = 0, on = "玩家名字1" },
--             { rpid = "0", rptid = 5, bgold = 500, st = 0, f = 0, on = "玩家名字1" },
--             { rpid = "0", rptid = 6, bgold = 500, st = 0, f = 0, on = "玩家名字1" },
--             { rpid = "0", rptid = 7, bgold = 500, st = 0, f = 0, on = "玩家名字1" }
--         }
--     }
--     self:OnDataResult(data);
-- end

function GuildHongBaoPanel:_InitReference()
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");

    self._trsSelfList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsLeft/trsList");
    self._selfScrollView = UIUtil.GetComponent(self._trsSelfList, "UIScrollView");
    self._selfScrollPanel = UIUtil.GetComponent(self._trsSelfList, "UIPanel");
    self._selfPhalanxInfo = UIUtil.GetChildByName(self._trsSelfList, "LuaAsynPhalanx", "phalanx");
    self._selfPhalanx = Phalanx:New();
    self._selfPhalanx:Init(self._selfPhalanxInfo, GuildSelfHBItem);

    self._trsGuildList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsRight/trsList");
    self._guildScrollView = UIUtil.GetComponent(self._trsGuildList, "UIScrollView");
    self._guildScrollPanel = UIUtil.GetComponent(self._trsGuildList, "UIPanel");
    self._guildPhalanxInfo = UIUtil.GetChildByName(self._trsGuildList, "LuaAsynPhalanx", "phalanx");
    self._guildPhalanx = Phalanx:New();
    self._guildPhalanx:Init(self._guildPhalanxInfo, GuildHBItem);
end

function GuildHongBaoPanel:_InitListener()
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_GUILD_HONGBAO_DATA, GuildHongBaoPanel.OnDataResult, self);

    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

function GuildHongBaoPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function GuildHongBaoPanel:_DisposeReference()
    self._btnClose = nil;

    self._trsSelfList = nil;
    self._selfScrollView = nil;
    self._selfScrollPanel = nil;
    self._selfPhalanxInfo = nil;
    self._selfPhalanx:Dispose();
    self._selfPhalanx = nil;

    self._trsGuildList = nil;
    self._guildScrollView = nil;
    self._guildScrollPanel = nil;
    self._guildPhalanxInfo = nil;
    self._guildPhalanx:Dispose();
    self._guildPhalanx = nil;
end

function GuildHongBaoPanel:_DisposeListener()
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_GUILD_HONGBAO_DATA, GuildHongBaoPanel.OnDataResult);

    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function GuildHongBaoPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDHONGBAOPANEL);
end

function GuildHongBaoPanel:OnDataResult(data)
    if (data) then
        local slen = table.getCount(data.ml);
        local tlen = table.getCount(data.tl);
        self._selfPhalanx:Build(slen, 3, data.ml)
        self._selfScrollView:ResetPosition();
        table.sort(data.tl, function(a, b)
            if (a.st == b.st) then
                return a.f < b.f;
            end
            return a.st > b.st
        end)
        self._guildPhalanx:Build(tlen, 1, data.tl)
        self._guildScrollView:ResetPosition();
    end
end
