module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_mapName = i3k_class("wnd_mapName", ui.wnd_base)
function wnd_mapName:ctor()
	self.deltaWidth = 0
end

function wnd_mapName:configure()

end

function wnd_mapName:refresh(data)
	local pos1 = self._layout.vars.img1:getPosition()
	local pos2 = self._layout.vars.img2:getPosition()
	self.deltaWidth = (pos1.x - pos2.x)
	self:setShowImgs(data)
	-- g_i3k_ui_mgr:PopupTipMessage(self.deltaWidth)
	self:playAnimation()
end

function wnd_mapName:playAnimation()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai
	if anis then
		anis.stop()
		anis.play(function ()
			self:onCloseUI()
		end)
	end
end

function wnd_mapName:setShowImgs(data)
	local count = #data

	if count == 5 then
		self:set5Imgs(data)
	elseif count == 4 then
		self:set4Imgs(data)
	elseif count == 3 then
		self:set3Imgs(data)
	elseif count == 2 then
		self:set2Imgs(data)
	end
end

function wnd_mapName:set5Imgs(data)
	local widget = self._layout.vars
	for i,v in ipairs(data) do
		widget["img"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(v))
	end
end

function wnd_mapName:set4Imgs(data)
	local name = {1,2,4,5}
	local widget = self._layout.vars
	for i,v in ipairs(data) do
		local w = widget["img"..name[i]]
		w:setImage(g_i3k_db.i3k_db_get_icon_path(v))
		local pos = w:getPosition()
		if name[i] == 1 or name[i] == 2 then
			w:setPosition(pos.x - self.deltaWidth/2 , pos.y )
		else
			w:setPosition(pos.x + self.deltaWidth/2 , pos.y )
		end
	end
	widget.img3:hide()

end

function wnd_mapName:set3Imgs(data)
	local name = {2,3,4}
	local widget = self._layout.vars
	for i,v in ipairs(data) do
		widget["img"..name[i]]:setImage(g_i3k_db.i3k_db_get_icon_path(v))
	end
	widget.img1:hide()
	widget.img5:hide()
end

function wnd_mapName:set2Imgs(data)
	local name = {2,4}
	local widget = self._layout.vars
	for i,v in ipairs(data) do
		local w = widget["img"..name[i]]
		w:setImage(g_i3k_db.i3k_db_get_icon_path(v))
		local pos = w:getPosition()
		if name[i] == 2 then
			w:setPosition(pos.x - self.deltaWidth/2 , pos.y )
		else
			w:setPosition(pos.x + self.deltaWidth/2 , pos.y )
		end
	end
	widget.img1:hide()
	widget.img3:hide()
	widget.img5:hide()
end


----------------------------------------
function wnd_create(layout)
	local wnd = wnd_mapName.new();
		wnd:create(layout);
	return wnd;
end
