-------------------------------------------------------
module(..., package.seeall)
local require = require
local ui = require("ui/explainPanel")
-------------------------------------------------------
wnd_baguaGuide = i3k_class("wnd_baguaGuide", ui.wnd_ExplainPanel)

function wnd_baguaGuide:ctor()
    self.icons = i3k_db_maze_battle.guideIcon
    self.desc  = i3k_db_maze_battle.guideText
end

function wnd_create(layout, ...)
    local wnd = wnd_baguaGuide.new()
    wnd:create(layout, ...)
    return wnd
end
