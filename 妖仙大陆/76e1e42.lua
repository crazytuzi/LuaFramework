local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local FubenApi = require "Zeus.Model.Fuben"

local self = {
    menu = nil,
}

local function StopGuildWarCdLabel()
    if self.GuildWarCdLabel ~= nil then
        self.GuildWarCdLabel:stop()
        self.GuildWarCdLabel = nil
    end
end

local function StartGuildWarCdLabel(countDown)
    local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)

    if sceneType ~= PublicConst.SceneType.GuildWarGather or sceneType ~= PublicConst.SceneType.GuildWarFight then
        self.btn_queding.Text = Util.GetText(TextConfig.Type.FUBEN, "ok")
        self.btn_queding.TouchClick = function()
            self.menu:Close()
        end
        return
    else
        self.btn_queding.TouchClick = function()
            FubenApi.requestLeaveFuben()
        end
    end

    local string = Util.GetText(TextConfig.Type.FUBEN, "ok")
    local function format(cd,label)
        if cd < 0 then
            StopGuildWarCdLabel()
        end
        return string.format("%s(%s))", string, cd)
    end
    self.GuildWarCdLabel = CDLabelExt.New(self.btn_queding,countDown,format)
    self.GuildWarCdLabel:start()
end

local function SetResultDetail(data)
    self.lb_win.Visible = data.result == 1
    self.lb_defeat.Visible = data.result == 0

    self.ib_result1.Visible = self.lb_win.Visible
    self.ib_result2.Visible = not self.lb_win.Visible
    self.ib_result3.Visible = self.lb_defeat.Visible
    self.ib_result4.Visible = not self.lb_defeat.Visible

    self.lb_guild1.Text = string.format("%s(LV.%s))", data.ownGuild.guildName, data.ownGuild.guildLevel)

    data.enemyGuild = data.enemyGuild or {}

    if data.enemyGuild.guildName and data.enemyGuild.guildName ~= "" then
        self.lb_guild2.Text = string.format("%s(LV.%s))", data.enemyGuild.guildName, data.enemyGuild.guildLevel)
    else
        self.lb_guild2.Text = Util.GetText(TextConfig.Type.GUILDWAR, "shouweijun")
    end

    self.lb_num1.Text = data.ownGuild.mumber or 0
    self.lb_num2.Text = data.enemyGuild.mumber or 0
    self.lb_num3.Text = data.ownGuild.defenseSoul or 0
    self.lb_num4.Text = data.enemyGuild.defenseSoul or 0
    self.lb_num5.Text = data.ownGuild.attackSoul or 0
    self.lb_num6.Text = data.enemyGuild.attackSoul or 0
    self.lb_num7.Text = data.ownGuild.attack or 0
    self.lb_num8.Text = data.enemyGuild.attack or 0
    self.lb_num9.Text = data.ownGuild.defense or 0
    self.lb_num10.Text = data.enemyGuild.defense or 0
    self.lb_num11.Text = data.ownGuild.kill or 0
    self.lb_num12.Text = data.enemyGuild.kill or 0
    self.lb_num13.Text = data.ownGuild.armyFlag or 0
    self.lb_num14.Text = data.enemyGuild.armyFlag or 0
    self.lb_num15.Text = data.ownGuild.score or 0
    self.lb_num16.Text = data.enemyGuild.score or 0

    self.lb_tips1.Text = data.mixScore or 0

    StartGuildWarCdLabel(data.countDown)
end

local function OnEnter()

end

local function OnExit()
    StopGuildWarCdLabel()
end

local ui_names = 
{
  
    {name = 'btn_close'},

    {name = 'lb_win'},
    {name = 'lb_defeat'},

    {name = 'ib_result1'},
    {name = 'ib_result2'},
    {name = 'ib_result3'},
    {name = 'ib_result4'},
    {name = 'lb_guild1'},
    {name = 'lb_guild2'},

    {name = 'lb_num1'},
    {name = 'lb_num2'},
    {name = 'lb_num3'},
    {name = 'lb_num4'},
    {name = 'lb_num5'},
    {name = 'lb_num6'},
    {name = 'lb_num7'},
    {name = 'lb_num8'},
    {name = 'lb_num9'},
    {name = 'lb_num10'},
    {name = 'lb_num11'},
    {name = 'lb_num12'},
    {name = 'lb_num13'},
    {name = 'lb_num14'},
    {name = 'lb_num15'},
    {name = 'lb_num16'},

    {name = 'lb_tips1'},
    {name = 'btn_queding'},
}

local function InitCompnent()
    Util.CreateHZUICompsTable(self.menu,ui_names,self)

    self.btn_close.TouchClick = function ()
        self.menu:Close()
    end
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/guild/guild_judian_jiesuan.gui.xml.gui.xml", GlobalHooks.UITAG.GameUIGuildWarResult)
    self.menu.Enable = true
    self.menu.mRoot.Enable = true
    self.menu.ShowType = UIShowType.HideBackHud
  
    InitCompnent()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function ()
        self = nil
    end)
    return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

_M.SetResultDetail = SetResultDetail

return {Create = Create}
