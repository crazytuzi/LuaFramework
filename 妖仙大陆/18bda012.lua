local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GuildWarAPI = require "Zeus.Model.GuildWar"

local self = {
    menu = nil,
}

local nameColorIndex = {3,2,1,4,0}

local function UpdateItemCell(node, data)
    local lb_member = node:FindChildByEditName("lb_member", false)
    local lb_level = node:FindChildByEditName("lb_level", false)
    local lb_position = node:FindChildByEditName("lb_position", false)
    local lb_kill = node:FindChildByEditName("lb_kill", false)
    local lb_destoryFlag = node:FindChildByEditName("lb_destoryFlag", false)
    local lb_export = node:FindChildByEditName("lb_export", false)
    local lb_cure = node:FindChildByEditName("lb_cure", false)
    local lb_defense = node:FindChildByEditName("lb_defense", false)
    local lb_attack = node:FindChildByEditName("lb_attack", false)
    local lb_score = node:FindChildByEditName("lb_score", false)

    lb_member.Text = data.name
    lb_level.Text = data.level
    lb_position.Text = Util.getGuildPosition(data.job).position
    lb_kill.Text = data.kill
    lb_destoryFlag.Text = data.destroyFlag
    lb_export.Text = Util.NumberToShow(data.damage or 0)
    lb_cure.Text = Util.NumberToShow(data.cure or 0)
    lb_defense.Text = data.defenseScore
    lb_attack.Text = data.attackSoul
    lb_score.Text = data.totalScore
    
    lb_position.FontColor = GameUtil.RGBA2Color(Util.GetQualityColorRGBA(nameColorIndex[data.job]))
end

local function SetStatisticsDetail(data)
    self.sp_statistics_list:Initialize(self.cvs_statistics_detail.Width, self.cvs_statistics_detail.Height+5, #data, 1, self.cvs_statistics_detail, 
        LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
            local itemData = data[y+1]
            UpdateItemCell(node, itemData)
        end),
        LuaUIBinding.HZTrusteeshipChildInit(function (node)

        end)
    )
end

local function OnEnter()

end

local function OnExit()

end

local ui_names = 
{
  
    {name = 'btn_close'},

    {name = 'cvs_statistics_detail'},
    {name = 'sp_statistics_list'},
}

local function InitCompnent()
    Util.CreateHZUICompsTable(self.menu,ui_names,self)
    
    self.cvs_statistics_detail.Visible = false

    self.btn_close.TouchClick = function ()
        self.menu:Close()
    end
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/guild/guild_judian_statistics.gui.xml", GlobalHooks.UITAG.GameUIGuildWarStatistics)
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

_M.SetStatisticsDetail = SetStatisticsDetail

return {Create = Create}
