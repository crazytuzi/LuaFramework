-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_battle_4v4 = i3k_class("wnd_battle_4v4", ui.wnd_base)

function wnd_battle_4v4:ctor()
	
end

function wnd_battle_4v4:configure()
	local widget = self._layout.vars
	local team = {}
	for i=1, 4 do
		team[i] = {}
		team[i].root = widget["root"..i]
		team[i].blood = widget["blood"..i]
		team[i].nameLabel = widget["nameLabel"..i]
		team[i].iconType = widget["iconType"..i]
		team[i].life = {
			[1] = widget["life"..i.."1"],
			[2] = widget["life"..i.."2"],
		}
		team[i].icon = widget["icon"..i]
		team[i].root:hide()
	end
	self._widgets = team
	self._teamInfo = nil
end

function wnd_battle_4v4:onShow()
	
end

function wnd_battle_4v4:refresh()
	
end

function wnd_battle_4v4:loadData(enemies)
	local enemiesTable = {}
	self._teamInfo = enemies
	for i,v in pairs(enemies) do
		table.insert(enemiesTable, v)
	end
	for i,v in ipairs(enemiesTable) do
		local node = self._widgets[i]
		node.nameLabel:setText(v.name)
		node.blood:setPercent(v.hp/v.maxHP*100)
		node.iconType:setImage(g_i3k_get_head_bg_path(v.bwType, v.headBorder))
		node.icon:setImage(g_i3k_db.i3k_db_get_role_head_icon(v.id,v.headIcon))
		node.lifeNumber = v.lives
		for j,t in ipairs(node.life) do
			t:setVisible(j<=node.lifeNumber)
		end
		node.root:setTag(v.id)
		node.root:show()
	end
end

--刷新所有头像
function wnd_battle_4v4:updataHeadIcon()
	if self._teamInfo then
		for i,v in ipairs(self._widgets) do
			local roleId = v.root:getTag()
			if self._teamInfo[roleId] then
				v.icon:setImage(g_i3k_db.i3k_db_get_role_head_icon(roleId, self._teamInfo[roleId].headIcon))
			end
		end
	end
end

function wnd_battle_4v4:onHpChanged(roleId, curHp, maxHp)
	local widget = self:getWidget(roleId)
	if widget then
		widget.blood:setPercent(curHp/maxHp*100)
		if curHp<=0 then
			widget.lifeNumber = widget.lifeNumber - 1
			for i,v in ipairs(widget.life) do
				v:setVisible(i<=widget.lifeNumber)
			end
		end
	end
end

function wnd_battle_4v4:getWidget(roleId)
	for i,v in ipairs(self._widgets) do
		if v.root:getTag()==roleId then
			return v
		end
	end
	return nil
end


function wnd_create(layout, ...)
	local wnd = wnd_battle_4v4.new()
	wnd:create(layout, ...)
	return wnd;
end
