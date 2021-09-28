module(..., package.seeall)

local require = require
local ui = require("ui/base")

-------------------------------------------------------
wnd_xinghun_sub_star = i3k_class("wnd_xinghun_sub_star", ui.wnd_base)

function wnd_xinghun_sub_star:ctor()
end

function wnd_xinghun_sub_star:configure()
    local widgets = self._layout.vars
    widgets.close_btn:onClick(self, self.onCloseUI)

    self.name = widgets.name
    self.fightPower = widgets.fightPower
    self.level = widgets.level
    self.expbar = widgets.expbar
    self.expbarCount = widgets.expbarCount
    self.nowEffect = widgets.nowEffect
    self.nextEffect = widgets.nextEffect
end

function wnd_xinghun_sub_star:refresh(id, lvl, now, total)
    local cfg = g_i3k_db.xinghun_getSubStarConfig(id, lvl)
    if cfg then
        self.name:setText(cfg.name)
        self.level:setText("等级" .. lvl .. "/" .. g_i3k_db.xinghun_getSubStarMaxLevel())

        self:setFightPower(cfg.props)
        self:updateExpBar(now, total)

        self:setNowProps(cfg.props)
        self:setNextProps(id, lvl + 1)
    end
end

function wnd_xinghun_sub_star:setFightPower(props)
    local tmp = {}
    for _, v in ipairs(props) do
        if v.id > 0 then
            tmp[v.id] = (tmp[v.id] or 0) + v.value
        end
    end
    local power = g_i3k_db.i3k_db_get_battle_power(tmp, true)
    self.fightPower:setText(power)
end

function wnd_xinghun_sub_star:setNowProps(props)
    self.nowEffect:removeAllChildren()
    local itemTb = g_i3k_game_context:xingHunSetProps(props)
    for _, v in ipairs(itemTb) do
        self.nowEffect:addItem(v)
    end
end

function wnd_xinghun_sub_star:setNextProps(id, lvl)
    self.nextEffect:removeAllChildren()
    local maxLvl = g_i3k_db.i3k_db_get_sub_star_up_cfg_num(id)
    if lvl <= maxLvl then
        local cfg = g_i3k_db.xinghun_getSubStarConfig(id, lvl)
        local itemTb = g_i3k_game_context:xingHunSetProps(cfg.props)
        for _, v in ipairs(itemTb) do
            self.nextEffect:addItem(v)
        end
    end
end

function wnd_xinghun_sub_star:updateExpBar(now, total)
    if not total then
        self.expbar:setPercent(0)
        self.expbarCount:setText("满级")
    else
        self.expbar:setPercent(now / total * 100)
        self.expbarCount:setText(string.format("%s/%s", now, total))
    end
end

function wnd_create(layout, ...)
    local wnd = wnd_xinghun_sub_star.new()
    wnd:create(layout, ...)
    return wnd
end
