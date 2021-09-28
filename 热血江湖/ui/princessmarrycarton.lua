
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_princessMarryCarton = i3k_class("wnd_princessMarryCarton", ui.wnd_base)
local CARTONS_CFG = {
	[g_plot_cartoon_princess_marry] = i3k_db_princess_marry.cartoonImages,
	[g_plot_cartoon_longevity_pavilion] = i3k_db_longevity_pavilion.cartoonImages,
	[g_plot_cartoon_longevity_pavilion_map] = {9821},
	[g_plot_cartoon_shenjicanghai_manhua]=i3k_db_magic_machine.manhua
}

function wnd_princessMarryCarton:ctor()
	self._cartons = {}
end

function wnd_princessMarryCarton:configure()
	local widgets = self._layout.vars
	widgets.next:onClick(self, self.onNextCartonBtn)
	widgets.close:onClick(self, self.onNextCartonBtn)	
end

function wnd_princessMarryCarton:refresh(state)
	self._cartons = clone(CARTONS_CFG[state])
	self:onNextCartonBtn()
end

function wnd_princessMarryCarton:onNextCartonBtn()
	local count = #self._cartons
	if count > 0 then
		local widgets = self._layout.vars
		widgets.carton:setImage(g_i3k_db.i3k_db_get_icon_path(self._cartons[1]))
		table.remove(self._cartons, 1)
		count = count - 1
		
		if count > 0 then
			widgets.next:show()
			widgets.close:hide()
		else
			widgets.next:hide()
			widgets.close:show()
		end
	else
		self:onCloseUI()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_princessMarryCarton.new()
	wnd:create(layout, ...)
	return wnd;
end

