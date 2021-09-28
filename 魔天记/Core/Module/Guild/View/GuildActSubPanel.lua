require "Core.Module.Common.UISubPanel";
require "Core.Module.Common.ScrollPageList";
-- require "Core.Module.Guild.View.Item.GuildActPage";

require "Core.Module.Guild.View.Item.GuildActListItem";



GuildActSubPanel = class("GuildActSubPanel", UISubPanel);
local _sortfunc = table.sort 

function GuildActSubPanel:_InitReference()

    self._pageListTr = UIUtil.GetChildByName(self._transform, "Transform", "trsPageList")

    --[[
    self.list = ScrollPageList.New();
    self.list:Init(self._pageListTr);
    self.list:SetItemClass(ResID.UI_GUILDACTPAGE, GuildActPage);
    ]]

    self._phalanxInfo = UIUtil.GetChildByName(self._pageListTr, "LuaAsynPhalanx", "scrollView/phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, GuildActListItem);
end

function GuildActSubPanel:_DisposeReference()
    -- self.list:Dispose();
    self._phalanx:Dispose();
end

function GuildActSubPanel:_InitListener()
    MessageManager.AddListener(GuildNotes, GuildNotes.ENV_GUILD_ACT_SELECT, GuildActSubPanel.OnItemClick, self);
    MessageManager.AddListener(GuildNotes, GuildNotes.RSP_ACTINFO, GuildActSubPanel.UpdateDisplay, self);

end

function GuildActSubPanel:_DisposeListener()
    MessageManager.RemoveListener(GuildNotes, GuildNotes.ENV_GUILD_ACT_SELECT, GuildActSubPanel.OnItemClick);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_ACTINFO, GuildActSubPanel.UpdateDisplay);
end

function GuildActSubPanel:_OnEnable()
    GuildProxy.ReqGuildActInfo();
    -- self:UpdateDisplay();
end

function GuildActSubPanel:UpdateDisplay() 
  
    local list = GuildDataManager.GetExtends(1);

    _sortfunc(list, function(a, b)
        if a.level == b.level then
            return a.sort < b.sort;
        end
        return a.level < b.level;
    end );

    -- self.list:Build(list, 5, 2);
    self._phalanx:Build(2, 5, list);
end

-- 点击活动接口
function GuildActSubPanel:OnItemClick(data)

    if data.id == GuildDataManager.Open.TASK then
        ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_OTHER_PANEL, GuildNotes.OTHER.TASK);
    elseif data.id == GuildDataManager.Open.MOBAI then
        ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_OTHER_PANEL, GuildNotes.OTHER.MOBAI);
    elseif data.id == GuildDataManager.Open.BOSS then
        self:CheckBossIn(data)
    elseif data.id == GuildDataManager.Open.WAR then
        ModuleManager.SendNotification(GuildWarNotes.OPEN_PANEL);
    elseif data.id == GuildDataManager.Open.YaoYuan then
        local lev = PlayerManager.hero.info.level;
        if PlayerManager.hero.info.level >= 29 then
            if AppSplitDownProxy.SysCheckLoad(nil, lev) then
                ModuleManager.SendNotification(YaoyuanNotes.OPEN_YAOYUANROOTPANEL);
            end
        else
            MsgUtils.ShowTips("Guild/GuildActListItem/NoLevel");
        end

    elseif data.id == GuildDataManager.Open.MINZU then
        MsgUtils.ShowConfirm(GuildActSubPanel, "guild/act/openComfirm/4", nil, GuildActSubPanel.OnClickComfirm, GuildActSubPanel.OnClickCancel, data);


    elseif data.id == GuildDataManager.Open.XM_JuYin then

        -- ModuleManager.SendNotification(GuildJuYingNotes.OPEN_GUILDJUYINGPANEL);

    elseif data.id == GuildDataManager.Open.XMJuHui then

        GuildProxy.ReqEnterZone();
        ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDPANEL);

    end
end

function GuildActSubPanel:OnClickComfirm(data)
    if data.id == GuildDataManager.Open.MINZU then
        GuildProxy.ReqEnterZone();
    end
    ModuleManager.SendNotification(GuildNotes.CLOSE_GUILDPANEL);
end

function GuildActSubPanel:OnClickCancel(data)

end


function GuildActSubPanel:CheckBossIn(data)



    local tbs = GuildDataManager.act.tbs;

    -- tbs:帮会boss活动状态（1：没开启，2：进心中，3：已结束）
    if tbs == 1 then
        ModuleManager.SendNotification(XMBossNotes.OPEN_XMBOSSPANEL);
    elseif tbs == 3 then
        --[[
        MsgUtils.ShowTips("Guild/GuildActListItem/label1");
        ]]
        ModuleManager.SendNotification(XMBossNotes.OPEN_XMBOSSPANEL);
    else
        if GuildDataManager.info.identity == GuildInfo.Identity.Trainee then
            MsgUtils.ShowTips("Guild/GuildActSubPanel/label1");
        else
            ModuleManager.SendNotification(XMBossNotes.OPEN_XMBOSSPANEL);
        end

    end




end


