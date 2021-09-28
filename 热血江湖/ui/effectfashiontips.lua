-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_effectFashionTips = i3k_class("wnd_effectFashionTips", ui.wnd_base)

function wnd_effectFashionTips:ctor()
	
end

local tempMap = {
	[6829] = 17317,
	[6830] = 17319,
	[6831] = 17318,
}--映射表 图片 映射 文本

function wnd_effectFashionTips:configure()
	local widgets = self._layout.vars
	self.title = widgets.title
	self.desc = widgets.desc
end

function wnd_effectFashionTips:refresh(imgId)
	self.title:setImage(i3k_db.i3k_db_get_icon_path(imgId))
	self.desc:setText(i3k_db.i3k_get_string(tempMap[imgId]))
end

function wnd_create(layout)
	local wnd = wnd_effectFashionTips.new()
	wnd:create(layout)
	return wnd;
end
