-------------------------------------------------------
module(..., package.seeall)
local require = require
local ui = require("ui/explainPanel")
-------------------------------------------------------
wnd_baguaGuide = i3k_class("wnd_baguaGuide", ui.wnd_ExplainPanel)

function wnd_baguaGuide:ctor()
    self.icons = i3k_db_faction_fight_cfg.guideIcon
    self.desc  = i3k_db_faction_fight_cfg.guideText
end

function wnd_create(layout, ...)
    local wnd = wnd_baguaGuide.new()
    wnd:create(layout, ...)
    return wnd
end
