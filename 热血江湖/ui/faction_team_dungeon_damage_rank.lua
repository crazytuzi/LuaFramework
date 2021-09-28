-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_team_dungeon_damage_rank = i3k_class("wnd_faction_team_dungeon_damage_rank", ui.wnd_base)

local LAYER_BPFBPHT = "ui/widgets/bpfbpht"
local f_rankImg = {2718, 2719, 2720}
function wnd_faction_team_dungeon_damage_rank:ctor()
	
end

function wnd_faction_team_dungeon_damage_rank:configure(...)
	self._layout.vars.close:onClick(self,self.onCloseUI)
	self.scroll = self._layout.vars.scroll 
	
end

function wnd_faction_team_dungeon_damage_rank:onShow()
	
end

function wnd_faction_team_dungeon_damage_rank:refresh(data)
	self:updateList(data)
end 

function wnd_faction_team_dungeon_damage_rank:updateList(data)
	self.scroll:removeAllChildren()
	
	local data = self:sortDamge(data)
	self.scroll:removeAllChildren()
	for i,v in ipairs(data) do
		local _layer = require(LAYER_BPFBPHT)()
		local rankLabel = _layer.vars.rankLabel 
		local name = _layer.vars.name 
		local damage = _layer.vars.damage 
		local rankImg = _layer.vars.rankImg 
		if f_rankImg[i] then
			rankImg:show()
			rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(f_rankImg[i]))
			rankLabel:hide()
		else
			rankImg:hide()
			rankLabel:show()
			rankLabel:setText(i)
		end
		local tmp_str
		name:setText(v.role.name)
		if v.damage > 100000000 then
			local tmp = math.modf(v.damage/10000000)/10
			tmp_str = string.format("%s亿",tmp)
		elseif v.damage > 10000 then
			local tmp = math.modf(v.damage/1000)/10
			tmp_str = string.format("%s万",tmp)
		else
			
			tmp_str = string.format("%s",v.damage)
		end 
		damage:setText(tmp_str)
		self.scroll:addItem(_layer)
	end
end 

function wnd_faction_team_dungeon_damage_rank:sortDamge(data)
	local tmp = {}
	
	for k,v in pairs(data) do
		table.insert(tmp,v)
	end
	
	table.sort(tmp, function (a, b)
			return a.damage>b.damage
		end)
	return tmp
end 

function wnd_create(layout, ...)
	local wnd = wnd_faction_team_dungeon_damage_rank.new();
		wnd:create(layout, ...);

	return wnd;
end

