module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_jinlanAchi = i3k_class("wnd_jinlanAchi", ui.wnd_base)

function wnd_jinlanAchi:ctor()
	
end

function wnd_jinlanAchi:configure()
	self.ui = self._layout.vars
	self.ui.close:onClick(self, self.onCloseUI)
end

function wnd_jinlanAchi:refresh()
	local swornMgr = g_i3k_game_context
	self:setAchiPointReward(swornMgr)
	self:setTask(swornMgr)
end

function wnd_jinlanAchi:setAchiPointReward(swornMgr)
	self.ui.achiPoint:setText(swornMgr._achiPoint)
	local destIndex
	for k, v in ipairs(i3k_db_achi_point_reward) do
		local index = k * 2 - 1
		local aniIndex = index
		if index == 1 then aniIndex = "" end
		local ani = self._layout.anis["c_bx"..aniIndex]
		
		self.ui["reward_txt"..index]:setText(v.objective)
		if swornMgr._achiPointRewardArchived[v.objective] then
			ani:stop()
			self.ui["reward_get_icon"..index]:setVisible(true)
			self.ui["reward_icon"..index]:setVisible(false)
			self.ui["reward_btn"..index]:onClick(self, function() end)
		elseif swornMgr._achiPoint >= v.objective then
			self.ui["reward_get_icon"..index]:setVisible(false)
			self.ui["reward_icon"..index]:setVisible(true)
			self.ui["reward_btn"..index]:onClick(self, self.acpt, v)
			ani:play()
		else
			self.ui["reward_get_icon"..index]:setVisible(false)
			self.ui["reward_icon"..index]:setVisible(true)
			self.ui["reward_btn"..index]:onTouchEvent(self, self.touchbtn, k)
					
			if not destIndex then destIndex = k end
			ani:stop()
		end
	end
	
	self.ui.schedule1:setPercent(g_i3k_db.getBarPerc(destIndex, swornMgr._achiPoint))
end

function wnd_jinlanAchi:acpt(_, cfg)
	local item = i3k_game_context:IsFemaleRole() and cfg.girl or cfg.boy
	if g_i3k_game_context:checkBagCanAddCell(1, true) then
		i3k_sbean.get_achi_point_reward(cfg.objective, {{id = item.rewardID, count = item.rewardCount}})
		end
end
function wnd_jinlanAchi:touchbtn(sender, eventType, k)
	local c = i3k_db_achi_point_reward[k]
	local item = i3k_game_context:IsFemaleRole() and c.girl or c.boy
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_JinlanAchiPointRwdTips, item.rewardID, item.rewardCount, c.objective)
	elseif eventType == ccui.TouchEventType.moved then
		
	else
		g_i3k_ui_mgr:CloseUI(eUIID_JinlanAchiPointRwdTips)
	end
end

function wnd_jinlanAchi:setTask(swornMgr)
	local top = {}	--置顶
	local normal = {}
	local progress = {swornMgr._selfJinlanValue, swornMgr._mapTime, swornMgr._swornSuperAurenaTimes}
	--local objectives = {swornMgr._taskArchived, swornMgr._achiPointRewardArchived}
	
	for tp, tasks in ipairs(i3k_db_sworn_task) do
		for k, v in ipairs(tasks) do
			if not swornMgr._taskArchived[v.id] then
				local wg = require("ui/widgets/jinlancjt")()
				local finished
				if progress[tp] >= v.objective then
					local id = v.id
					local achiPoint = v.achiPoint
					finished = true
					wg.vars.noFinish:setImage(g_i3k_db.i3k_db_get_icon_path(8861))
					wg.vars.take:onClick(self, i3k_sbean.get_achi_reward, {id = id, acp = achiPoint})
					table.insert(top, wg)
				else
					finished = false
					wg.vars.noFinish:setImage(g_i3k_db.i3k_db_get_icon_path(8860))
					wg.vars.take:setVisible(false)
					wg.vars.complete:setVisible(false)
					wg.vars.notCanJump:setVisible(true)
					table.insert(normal, wg)
				end
				local color = g_i3k_get_cond_color(finished)
				wg.vars.taskName:setText(v.name)
				local desc = string.format(v.desc, color)
				wg.vars.condition:setText(string.format("%s<c=%s>(%d/%d)</c>", desc, color, progress[tp], v.objective))
				wg.vars.taskIcon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
				wg.vars.achPoint:setText(v.achiPoint) --(string.format("<c=%s>成就点数: %d</c>", color, v.achiPoint))
				break
			end
		end
	end
	
	self.ui.plate:removeAllChildren()
	for _, v in ipairs(top) do 
		self.ui.plate:addItem(v) 
	end
	for _, v in ipairs(normal) do 
		self.ui.plate:addItem(v) 
	end
	if #top == 0 and #normal == 0 then
		self.ui.allFinished:setVisible(true)
		self.ui.allFinished:setText(i3k_get_string(5525))
	else
		self.ui.allFinished:setVisible(false)
	end
end

function wnd_create(layout)
	local wnd = wnd_jinlanAchi.new()
	wnd:create(layout)
	return wnd
end
