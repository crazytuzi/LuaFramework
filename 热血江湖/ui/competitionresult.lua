module(..., package.seeall)
local require = require
require('ui/map_set_funcs')
local ui = require('ui/mapUIBase')
---------------------------------------------------------------------
wnd_competitionResult = i3k_class('wnd_competitionResult', ui.wnd_MapBase)

local PLAYER_WIDGETS = 'ui/widgets/yyqcsjst'
local ROW_COUNT = 2
local SHOW_MAX_PLAYER   = i3k_db_dual_meet.showPlayerNumber
local AUTO_EXIT_TIME    = i3k_db_dual_meet.battleCfg.autoExitTime

function wnd_competitionResult:ctor()
    self._timer = 0
end

function wnd_competitionResult:configure()
    local widgets = self._layout.vars
    widgets.close_btn:onClick(self, self.onClose)
end

function wnd_competitionResult:refresh(winSide, guardNumber, teams)
    self._layout.vars.guardTxt:setText(i3k_get_string(18873, guardNumber))
    self:refreshScroll(winSide, teams)
end

function wnd_competitionResult:refreshScroll(winSide, teams)
    self._layout.vars.scroll:removeAllChildren()
    local all_layer = self._layout.vars.scroll:addItemAndChild(PLAYER_WIDGETS, ROW_COUNT, ROW_COUNT * SHOW_MAX_PLAYER)
    --遍历各队信息
    table.sort(teams, function(a, b) --蓝方在左 红方在右
        return a.force > b.force 
    end)
    for i, e in ipairs(teams) do
        --winside胜利表示与队伍标识相同队伍胜利
        local iconID = winSide == e.force and 9923 or 9924
        self._layout.vars['ResultImg' .. i]:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
        self._layout.vars['ResultScore' .. i]:setText(e.scoreTotal)
        --队伍中角色信息
        for j = 1, SHOW_MAX_PLAYER do
            self:SetItem(all_layer[i + (j - 1) * 2], e.ranks[j], j)
        end
    end
end

function wnd_competitionResult:SetItem(node, playerInfo, rank)
    if not playerInfo then
        --没有角色信息隐藏此格子
        node.vars.root:setVisible(false)
        return
    end
    node.vars.rank_image:setImage(g_i3k_db.i3k_db_get_icon_path(9919 + rank))
    node.vars.rank_image:setVisible(true)
    node.vars.name_label:setText(playerInfo.name) --玩家名
    node.vars.lvl_label:setText(playerInfo.level) --等级
    node.vars.kill_label:setText(string.format('%s/%s', playerInfo.killTotal, playerInfo.deadTotal)) --击杀战绩
    --高亮
	if g_i3k_game_context:GetRoleId() ==  playerInfo.id then
        node.vars.light:setVisible(true)
    end
end

function wnd_competitionResult:onUpdate(dTime)
    self._timer = self._timer + dTime
    if self._timer < AUTO_EXIT_TIME then
        self._layout.vars.daojishi:setText(i3k_get_string(18854, math.floor(AUTO_EXIT_TIME - self._timer)))
    else
        i3k_sbean.mapcopy_leave()
    end
end

function wnd_competitionResult:onClose(sender)
    i3k_sbean.mapcopy_leave()
end

function wnd_create(layout, ...)
    local wnd = wnd_competitionResult.new()
    wnd:create(layout, ...)
    return wnd
end
