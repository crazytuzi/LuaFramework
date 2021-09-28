-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_biography_skills_unlock = i3k_class("wnd_biography_skills_unlock", ui.wnd_base)

function wnd_biography_skills_unlock:ctor()
	
end

function wnd_biography_skills_unlock:configure()
	self._layout.vars.okBtn:onClick(self, self.onCloseUI)
end

function wnd_biography_skills_unlock:onShow()
	self._layout.anis.c_juanzhou.play()
end

function wnd_biography_skills_unlock:refresh(skills, qigong)
	self._layout.vars.desc:setText("")
	self._layout.vars.scroll:removeAllChildren()
	if next(skills) then
		self._layout.vars.title:setImage(g_i3k_db.i3k_db_get_icon_path(9764))
	else
		self._layout.vars.title:setImage(g_i3k_db.i3k_db_get_icon_path(9763))
	end
	for k, v in ipairs(skills) do
		local node = require("ui/widgets/qsjnjst")()
		node.vars.title:setText(i3k_get_string(18520))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_skills[v].icon))
		node.vars.name:setText(i3k_db_skills[v].name)
		node.anis.c_jztx.play()
		self._layout.vars.scroll:addItem(node)
	end
	
	if #skills < 4 then
		for k = 1, 4 - #skills do
			if qigong[k] then
				local node = require("ui/widgets/qsjnjst")()
				node.vars.title:setText(i3k_get_string(18521))
				node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_xinfa[qigong[k]].itemID, g_i3k_game_context:IsFemaleRole()))
				node.vars.name:setText(i3k_db_xinfa[qigong[k]].name)
				node.anis.c_jztx.play()
				self._layout.vars.scroll:addItem(node)
			end
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_biography_skills_unlock.new()
	wnd:create(layout)
	return wnd
end