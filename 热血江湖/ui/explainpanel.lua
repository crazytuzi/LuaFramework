-------------------------------------------------------
module(..., package.seeall)
local require = require
local ui = require("ui/base")
-------------------------------------------------------
wnd_ExplainPanel = i3k_class("wnd_ExplainPanel", ui.wnd_base)

function wnd_ExplainPanel:ctor()
    self.index = 1
end

function wnd_ExplainPanel:configure()
    self.ui = self._layout.vars
    -- self.ui.close:onClick(self, self.onCloseUI)
    self.ui.close_btn:onClick(self, self.onCloseUI)
    self.ui.leftBtn:onClick(
        self,
        function()
            self:showIndex(self.index - 1)
        end
    )
    self.ui.rightBtn:onClick(
        self,
        function()
            self:showIndex(self.index + 1)
        end
    )

    self:showIndex(self.index)
end

function wnd_ExplainPanel:showIndex(index)
    if index < 1 or index > #self.icons or index > #self.desc  then
        return
    end
    self.index = index
    self.ui.leftBtn:setVisible(self.index ~= 1)
    self.ui.rightBtn:setVisible(self.index ~= #self.icons)
    self.ui.icon:setImage(g_i3k_db.i3k_db_get_icon_path(self.icons[self.index]))
    print(self.desc[self.index])
    self.ui.desc:setText(i3k_get_string(self.desc[self.index]))
end

function wnd_ExplainPanel:refresh()

end

function wnd_create(layout, ...)
    local wnd = wnd_ExplainPanel.new()
    wnd:create(layout, ...)
    return wnd
end
