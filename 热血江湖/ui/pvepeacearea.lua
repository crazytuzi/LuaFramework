module(..., package.seeall)

local require = require;

local ui = require("ui/base")

wnd_pvePeaceArea = i3k_class("wnd_pvePeaceArea", ui.wnd_base)

local BOSSCFG = i3k_db_peaceMapMonster
local MAPID = i3k_db_crossRealmPVE_cfg.peaceMapID


function wnd_pvePeaceArea:ctor()
	self._battleKey = 0			--幽冥密令数量Z
	self._aliveInfo = {}		--已刷新boss的上次刷新时间信息
	self._deadInfo = {}		--死亡boss的上次刷新时间信息
	self._orderBossId = {}     --按刷新死亡排好序的ID数组
	self._notReborn = false		--boss刷新的控制
	self._notdead = false		--boss死亡的控制
	self._nextTimePoint = {}   --记录死亡boss下次刷新时间点
end

function wnd_pvePeaceArea:configure()

end

function wnd_pvePeaceArea:refresh()
	local widgets = self._layout.vars
	widgets.sectRoot:hide()
	widgets.scrollRoot:hide()
	widgets.battleZone:onClick(self, self.showLineInfo)
	self:showBattleKeys()
end

function wnd_pvePeaceArea:onUpdate(dTime)
	if self:ifBossExist() then
		self._layout.vars.scrollRoot:show()
		if self._notReborn and self._notdead then
			local children = self._layout.vars.bossScroll:getAllChildren()
			local bossChange = {}
			for i, v in ipairs(children) do
				if self._deadInfo[self._orderBossId[i]] then
					local nextTimePoint = self._nextTimePoint[self._orderBossId[i]]
					if nextTimePoint - i3k_game_get_time() > 0 then
						v.vars.leftTime:setText(self:formatTime(nextTimePoint - i3k_game_get_time()))
						v.vars.leftTime:setTextColor("ffff0000")
					else
						bossChange[self._orderBossId[i]] = nextTimePoint
					end
				else
					v.vars.leftTime:setText("已刷新")
				end
			end
			if next(bossChange) then
				self._notReborn = false
				self:bossReborn(bossChange)
			end
		end
	end
end

--同步boss信息时执行（InvokeUIFunction）
function wnd_pvePeaceArea:setBossInfo(aliveInfo, deadInfo)
	self._notReborn = false
	self._notdead = false
	self._aliveInfo = aliveInfo
	self._deadInfo = deadInfo
	self._orderBossId ={}
	table.insertto(self._orderBossId, self:getOrderID(self._aliveInfo))
	table.insertto(self._orderBossId, self:getOrderID(self._deadInfo))
	self:getBossNextRefreshTime()
	self:setBossScroll()
	self._notReborn = true
	self._notdead = true
end

--将ID排序
function wnd_pvePeaceArea:getOrderID(IdTable)
	local order = {}
	for i, v in pairs(IdTable) do
		table.insert(order, i)
	end
	table.sort(order)
	return order
end

-- 显示boss列表
function wnd_pvePeaceArea:setBossScroll()
	local scroll = self._layout.vars.bossScroll
	scroll:removeAllChildren()
	for i, v in ipairs(self._orderBossId) do
		local node = require("ui/widgets/zdsdymjt")()
		node.vars.bossName:setText(i3k_db_monsters[BOSSCFG[v].monsterID].name)
		node.vars.btn:onClick(self, self.bossTransfer, v)
		scroll:addItem(node)
	end
end

--计算boss下次刷新时间
function wnd_pvePeaceArea:getBossNextRefreshTime()
	for i,v in pairs(self._deadInfo) do
		local intervals = math.floor((i3k_game_get_time() - v) / BOSSCFG[i].refreshTime)
		self._nextTimePoint[i] = v + (intervals + 1) * BOSSCFG[i].refreshTime
	end
end

--格式化时间输出
function wnd_pvePeaceArea:formatTime(time)
	local tm = time;
	local h = i3k_integer(tm / (60 * 60));
	tm = tm - h * 60 * 60;

	local m = i3k_integer(tm / 60);
	tm = tm - m * 60;

	local s = tm;
	return string.format("%02d:%02d", m, s);
end

--boss刷新
function wnd_pvePeaceArea:bossReborn(bossChange)
	self._notReborn = false
	for i, v in pairs(bossChange) do
		self._deadInfo[i] = nil
		self._aliveInfo[i] = v
	end
	self._orderBossId ={}
	table.insertto(self._orderBossId, self:getOrderID(self._aliveInfo))
	table.insertto(self._orderBossId, self:getOrderID(self._deadInfo))
	self:getBossNextRefreshTime()
	self:setBossScroll()
	self._notReborn = true
end

--boss死亡 (InvokeUIFunction)
function wnd_pvePeaceArea:bossDie(bossID, lastRefreshTime)
	self._notdead = false
	self._deadInfo[bossID] = lastRefreshTime
	self._aliveInfo[bossID] = nil
	self._orderBossId ={}
	table.insertto(self._orderBossId, self:getOrderID(self._aliveInfo))
	table.insertto(self._orderBossId, self:getOrderID(self._deadInfo))
	self:getBossNextRefreshTime()
	self:setBossScroll()
	self._notdead = true
end

--传送至boss
function wnd_pvePeaceArea:bossTransfer(sender, bossID)
	local callback = function(ok)
			if ok then
				g_i3k_game_context:ClearFindWayStatus()
				i3k_sbean.peaceAreaBoss_transfer(MAPID, bossID)
			else
			    --self:onCloseUI(eUIID_MessageBox2)
			end
		end
	if g_i3k_ui_mgr:GetUI(eUIID_MessageBox2) then
		g_i3k_ui_mgr:CloseUI(eUIID_MessageBox2)
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1326), callback)
end

--显示幽冥密令信息
function wnd_pvePeaceArea:showBattleKeys()
	self._layout.vars.battleKeys:setText("幽冥密令："..g_i3k_game_context:getPveBattleKey().."/"..i3k_db_crossRealmPVE_cfg.needBattleCoin)
end

--显示线路信息
function wnd_pvePeaceArea:showLineInfo(sender)
	i3k_sbean.showPveBattle_lineInfo()
end

--判断boss是否开始刷新
function wnd_pvePeaceArea:ifBossExist()
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local open = string.split(i3k_db_crossRealmPVE_cfg.bossRefreshTime, ":")
	openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})  -- boss开始刷新的时间
	if g_i3k_get_GMTtime(i3k_game_get_time()) > openTimeStamp then
		return true
	else
		return false
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_pvePeaceArea.new();
	wnd:create(layout, ...);
	return wnd;
end
