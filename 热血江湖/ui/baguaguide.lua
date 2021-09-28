-------------------------------------------------------
module(..., package.seeall)
local require = require
local ui = require("ui/base")
-------------------------------------------------------
wnd_baguaGuide = i3k_class("wnd_baguaGuide", ui.wnd_base)

function wnd_baguaGuide:ctor()
    self.icons = i3k_db_bagua_cfg.guideIcon
    self.index = 1
end

function wnd_baguaGuide:configure()
    self.ui = self._layout.vars
    self.ui.close:onClick(self, self.onCloseUI)
    self.ui.left:onClick(
        self,
        function()
            self:showIndex(self.index - 1)
        end
    )
    self.ui.right:onClick(
        self,
        function()
            self:showIndex(self.index + 1)
        end
    )
    self:showIndex(self.index)
end

function wnd_baguaGuide:showIndex(index)
    if index < 1 or index > #self.icons then
        return
    end
    self.index = index
    self.ui.left:setVisible(self.index ~= 1)
    self.ui.right:setVisible(self.index ~= #self.icons)
    self.ui.icon:setImage(g_i3k_db.i3k_db_get_icon_path(self.icons[self.index]))
end

function wnd_baguaGuide:refresh()
end

function wnd_create(layout, ...)
    local wnd = wnd_baguaGuide.new()
    wnd:create(layout, ...)
    return wnd
end
