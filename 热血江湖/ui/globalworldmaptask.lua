module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------

wnd_globalWorldMapTask = i3k_class("wnd_globalWorldMapTask", ui.wnd_base)

local SJJMT_WIDGET = "ui/widgets/shangjinjiemiant"
local timeCounter = 0 --计时器
local warZoneCfg = i3k_db_war_zone_map_cfg

function wnd_globalWorldMapTask:ctor()
	self.count = 0
end

function wnd_globalWorldMapTask:configure()
	local widget = self._layout.vars
	self.scroll = widget.scroll
	self._layout.vars.closeBtn:onClick(self, self.onCloseAnisBtn)
	self._layout.vars.openBtn:onClick(self, self.onOpenAnisBtn)
end

function wnd_globalWorldMapTask:refresh()
	self.count = 0 
	self.scroll:removeAllChildren()
	local data = g_i3k_game_context:GetGlobalWorldTaskSortData()
	for i,v in ipairs(data) do
		local cfg = i3k_db_war_zone_map_task[v.id]
		local isFinish = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, v.curValue)
		if g_i3k_game_context:getGoldCoastMapType() == cfg.isLuanDou and not (isFinish and v.isReward == g_GLOBAL_WORLD_TASK_HASTAKE) then
			local node = require(SJJMT_WIDGET)()
			node.vars.text:setText(g_i3k_db.i3k_db_get_task_desc(cfg.type, cfg.arg1, cfg.arg2, v.curValue, isFinish, nil))
			node.vars.taskBtn:onClick(self, self.onTaskClick, {type = TASK_CATEGORY_GLOBALWORLD, cfg = cfg, id = v.id, value = v.curValue})
			node.vars.chuanSongBtn:onClick(self, self.onFlyClick, cfg)
			self.scroll:addItem(node)
			self.count = self.count + 1
		else
			print("奖励状态："..v.isReward)
		end
		--isFinish and v.isReward == g_GLOBAL_WORLD_TASK_HASTAKE
	end
	self:setTaskOverText()
	self._layout.vars.timeTipsBg:hide()
end

function wnd_globalWorldMapTask:setTaskOverText()
	local curMapName = ""
	local otherMapName = ""
	local otherNum = 0
	local fightType = g_i3k_game_context:getGoldCoastMapType()
	if fightType == g_GOLD_COAST_PEACE then
		curMapName = i3k_get_string(5586)
		otherMapName = i3k_get_string(5587)
		otherNum = g_i3k_game_context:GetGlobalWorldTaskNotCompleteTaskNum(g_GOLD_COAST_FIGHT)
	else
		curMapName = i3k_get_string(5587)
		otherMapName = i3k_get_string(5586)
		otherNum = g_i3k_game_context:GetGlobalWorldTaskNotCompleteTaskNum(g_GOLD_COAST_PEACE)
	end
	
	if self.count == 0 then
		local node = require(SJJMT_WIDGET)()
		node.vars.image1:setVisible(false)
		if otherNum == 0 then
			node.vars.text:setText(i3k_get_string(5588))
			self.scroll:addItem(node)
		else
			node.vars.text:setText(i3k_get_string(5589,curMapName))
			self.scroll:addItem(node)
			local node2 = require(SJJMT_WIDGET)()
			node2.vars.text:setText((i3k_get_string(5590,otherNum,otherMapName)))
			node2.vars.image1:setVisible(false)
			self.scroll:addItem(node2)
		end
	end
end

function wnd_globalWorldMapTask:onTaskClick(sender, args)
	local isFinish = g_i3k_game_context:IsTaskFinished(args.cfg.type, args.cfg.arg1, args.cfg.arg2, args.value)
	if isFinish then
		g_i3k_ui_mgr:OpenUI(eUIID_Task)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Task,"initShangJinData")
	else
		g_i3k_game_context:GoingToDoTask(TASK_CATEGORY_GLOBALWORLD, args.cfg, args.id)
	end
end

function wnd_globalWorldMapTask:onFlyClick(sender, cfg)
	local tbl = { point = nil, mapId = nil, transport = nil, taskCat = TASK_CATEGORY_GLOBALWORLD}
	g_i3k_game_context:switchDoTask(tbl, cfg, otherId, taskCategory)
	local needId = i3k_db_common.activity.transNeedItemId
	local needName = g_i3k_db.i3k_db_get_common_item_name(needId)
	local descText = i3k_get_string(1491,needName, 1)
	if tbl.transport then
		if g_i3k_game_context:IsTransNeedItem() then
			local function callback(isOk)
				if isOk then
					g_i3k_game_context:TransportCallBack(tbl.transport.mapId,tbl.transport.areaId,tbl.transport.flage)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
		else
			g_i3k_game_context:TransportCallBack(tbl.transport.mapId,tbl.transport.areaId,tbl.transport.flage)
		end
	end
end

function wnd_globalWorldMapTask:onCloseAnisBtn(sender)
	self._layout.vars.closeBtn:hide()
	self._layout.anis.c_ru.play(
	function()
		self._layout.vars.openBtn:show()
	end)
end
function wnd_globalWorldMapTask:onOpenAnisBtn(sender)
	self._layout.vars.openBtn:hide()
	self._layout.anis.c_chu.play(
	function()
		self._layout.vars.closeBtn:show()
	end)
end

function wnd_globalWorldMapTask:onUpdate(dTime)
	timeCounter = timeCounter + dTime
	if timeCounter > 1 then
		timeCounter = 0
		local _, closeTime = g_i3k_db.i3k_db_get_activity_open_close_time(warZoneCfg.openTimes)
		local time = closeTime - g_i3k_get_GMTtime(i3k_game_get_time())
		local showTime = time > 0 and time <= warZoneCfg.leaveTipTime
		self._layout.vars.timeTipsBg:setVisible(showTime)
		self._layout.vars.timeTips:setVisible(showTime)
		if showTime then
			self._layout.vars.timeTips:setText(i3k_get_string(5595, i3k_get_format_time_to_show(time)))
		end
	end
end


function wnd_create(layout)
	local wnd = wnd_globalWorldMapTask.new();
		wnd:create(layout);
	return wnd;
end
