-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dungeon_schedule = i3k_class("wnd_faction_dungeon_schedule", ui.wnd_base)

local LAYER_ZDBPFBT1 = "ui/widgets/zdbpfbt1"
local LAYER_ZDBPFBT2 = "ui/widgets/zdbpfbt2"
local LABEL_COLOR = "FF634624"
function wnd_faction_dungeon_schedule:ctor()
	self._mapId = 0
	self._schedule = {}
	self._damage = {}
	self._timeCounter = 0
end

function wnd_faction_dungeon_schedule:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onClose)
	self.dungeon_title = self._layout.vars.dungeon_title
	--self.scroll_list = self._layout.vars.scroll_list

	self.scroll_damage = self._layout.vars.scroll_damage
	self.scroll_schedule = self._layout.vars.scroll_schedule

	self.dungeon_bar = self._layout.vars.dungeon_bar
	self.dungeon_bar_lable = self._layout.vars.dungeon_bar_lable
	self.c_ru = self._layout.anis.c_ru
end

function wnd_faction_dungeon_schedule:onShow()
	i3k_sbean.syncSectGroupMapInfo()
end

function wnd_faction_dungeon_schedule:onClose(sender)
	self:closeAnimation()
end



function wnd_faction_dungeon_schedule:closeAnimation()
	self.c_ru.play(function ()
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonSchedule)
	end)
end

function wnd_faction_dungeon_schedule:refresh(mapId,killNum,damageRank)
	self._mapId = mapId
	self:updateDungeonTile(mapId)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeonSchedule,"updateSchedule",killNum)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeonSchedule,"updateIntegral",damageRank)
end


function wnd_faction_dungeon_schedule:updateDungeonTile(mapId)
	self.dungeon_title:setText(i3k_db_dungeon_base[mapId].desc)
end

function wnd_faction_dungeon_schedule:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 5 then -- 5秒请求一次
		i3k_sbean.syncSectGroupMapInfo()
		self._timeCounter = 0
	end
end

function wnd_faction_dungeon_schedule:updateSchedule(data)

	local monsters = i3k_db_faction_team_dungeon[self._mapId].refreshMonster
	self.scroll_schedule:removeAllChildren()
	local schedule = 0
	local is_ok = 0
	local index = 0
	for i=1,#monsters ,2 do
		local id = monsters[i]
		local count = monsters[i+1]

		local _layer = require(LAYER_ZDBPFBT1)()
		local desc = _layer.vars.desc
		local state = _layer.vars.state
		local count_label = _layer.vars.count
		local bg = _layer.vars.bg
		local cfg = i3k_db_monsters[id]
		index = index + 1
		bg:setVisible(index%2 == 0)
		local tmp_str = string.format("%s.击败%s个%s",index,count,cfg.name)
		local tmp_count
		if next(data) then
			if data[id] then
				if data[id] >= count then

					tmp_count = string.format("%s/%s",count,count)
					state:setText("完成")
					count_label:setTextColor(g_i3k_get_green_color())
					state:setTextColor(g_i3k_get_green_color())
					schedule = schedule + 1
				else
					is_ok = is_ok + 1
					tmp_count = string.format("%s/%s",data[id],count)
					state:setText("进行中")
					count_label:setTextColor(g_i3k_get_red_color())
					state:setTextColor(g_i3k_get_red_color())
				end
			else
				if is_ok == 1 then
					tmp_count = string.format("%s/%s",0,count)
					state:setText("未出现")
					state:setTextColor(LABEL_COLOR)
					count_label:setTextColor(LABEL_COLOR)
				else
					is_ok = is_ok + 1
					tmp_count = string.format("%s/%s",0,count)
					state:setText("进行中")
					count_label:setTextColor(g_i3k_get_red_color())
					state:setTextColor(g_i3k_get_red_color())
				end
			end

		else
			is_ok = is_ok +1

			if is_ok == 1 then
				tmp_count = string.format("%s/%s",0,count)
				state:setText("进行中")
				count_label:setTextColor(g_i3k_get_red_color())
				state:setTextColor(g_i3k_get_red_color())
			else
				tmp_count = string.format("%s/%s",0,count)
				state:setText("未出现")
				state:setTextColor(LABEL_COLOR)
				count_label:setTextColor(LABEL_COLOR)
			end
		end

		desc:setText(tmp_str)
		count_label:setText(tmp_count)

		self.scroll_schedule:addItem(_layer)
	end
	self.dungeon_bar:setPercent(schedule/(#monsters/2)*100)
	local tmp_count = math.modf(schedule/(#monsters/2)*100)
	self.dungeon_bar_lable:setText(string.format("%s%%",tmp_count))
	self.scroll_schedule:jumpToChildWithIndex(schedule+1)
end

function wnd_faction_dungeon_schedule:updateIntegral(data)

	local data = self:sortDamge(data)
	self.scroll_damage:removeAllChildren()
	local max_damage = 0
	for i,v in ipairs(data) do
		local _layer = require(LAYER_ZDBPFBT2)()
		local rank = _layer.vars.rank
		local name = _layer.vars.name
		local damage = _layer.vars.damage
		local bar = _layer.vars.bar
		local head_bg = _layer.vars.head_bg
		local head_icon = _layer.vars.head_icon
		if i == 1 then
			max_damage = v.damage
		end
		local member_headIcon = v.role.headIcon or 0
		local hicon = g_i3k_db.i3k_db_get_head_icon_ex(member_headIcon,g_i3k_db.eHeadShapeQuadrate)
		if hicon and hicon > 0 then
			head_icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
		end
		local bwType = v.role.bwType or 0
		local headBorder = v.role.headBorder or 0
		head_bg:setImage(g_i3k_get_head_bg_path(bwType, headBorder))
		rank:setText(i)
		name:setText(v.role.name)
		bar:setPercent(v.damage/max_damage*100)
		local tmp_str
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
		self.scroll_damage:addItem(_layer)
	end

end



function wnd_faction_dungeon_schedule:sortDamge(data)
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
	local wnd = wnd_faction_dungeon_schedule.new();
		wnd:create(layout, ...);

	return wnd;
end
