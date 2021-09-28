-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_bind_effect = i3k_class("wnd_bind_effect", ui.wnd_base)

function wnd_bind_effect:ctor()

end

function wnd_bind_effect:configure()
	local widgets = self._layout.vars

	self.model = widgets.model
end

function wnd_bind_effect:refresh(modelId)
	-- local modelId = 425
	--local path = "model/player/rxjh/zhujiang/bujian/quanpingguang/quanpingguang.spr";
	local path = i3k_db_models[modelId].path
	local uiscale = i3k_db_models[modelId].uiscale
	self.model:setSprite(path)
	self.model:setSprSize(uiscale)
	self.model:playAction("stand");
	self.model:setCameraAngle(-25, 0, 0)
end

function wnd_create(layout)
	local wnd = wnd_bind_effect.new()
	wnd:create(layout)
	return wnd
end
