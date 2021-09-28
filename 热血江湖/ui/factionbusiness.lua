
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_factionBusiness = i3k_class("wnd_factionBusiness",ui.wnd_base)

function wnd_factionBusiness:ctor()
	self.stageAllStar = 0
	self.taskId = 0
	self.curStar = 0
end

function wnd_factionBusiness:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.helpBtn:onClick(self, self.onHelp)
end

function wnd_factionBusiness:refresh(info)
	local quickCfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_BUSINESS)
	self.taskId = info.curTask
	self.curStar = info.curStar
	self:createItem(info.curRefreshTasks, info.curTask, info.curValue)
	local widgets = self._layout.vars
	local cfg = i3k_db_factionBusiness.schedule[info.lvl]

	self.stageAllStar = cfg.starNum
	
	--widgets.stageTxt:setText(string.format("本阶段完成进度：%s/%s", info.curStar, cfg.starNum))
	widgets.scheduleTxt:setText(string.format("%s%s/%s", i3k_get_string(17113), info.lvl, #i3k_db_factionBusiness.schedule))
	widgets.honor:setText(i3k_get_string(17114)..info.lvl)
	widgets.taskPartDesc:setText(cfg.desc)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconId))
	local ltime = info.refreshTime - i3k_game_get_time()
	local day = math.modf(ltime/86400)
	local hours = math.modf((ltime%86400)/3600)
	local sec = math.modf(math.modf(ltime%3600)/60)
	local timestr = ""
	if day > 0 then
		timestr = timestr..day.."天"
	end
	if hours > 0 then
		timestr = timestr..hours.."时"
	end
	if sec > 0 then
		timestr = timestr..sec.."分"
	end
	widgets.timeTxt:setText(i3k_get_string(17116, timestr))
	widgets.quickDesc:setText(i3k_get_string(5484, quickCfg.needActivity, quickCfg.needItemCount))
	self:updateBuystar()
end

function wnd_factionBusiness:updateBuystar()
	self.curStar = self.curStar or self.stageAllStar
	local widgets = self._layout.vars
	widgets.stageTxt:setText(string.format("%s%s/%s",i3k_get_string(17115), self.curStar, self.stageAllStar))
	--[[if self.stageAllStar > self.curStar then
		widgets.otherDoBtn:onClick(self, self.buyStar, self.stageAllStar - self.curStar)
	else
		widgets.otherDoBtn:disable()
	end--]]
	widgets.otherDoBtn:hide()
end

function wnd_factionBusiness:createItem(tasks, taskId, value)

	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	local finished = false
	if taskId > 0 then
		local cfg = i3k_db_factionBusiness_task[taskId]
		if cfg then
			finished = g_i3k_game_context:IsTaskFinished(cfg.type, cfg.arg1, cfg.arg2, value)
		end
	end
	
	local scheduleInfo = g_i3k_game_context:GetScheduleInfo()
	local active = scheduleInfo.activity
	local quickCfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_BUSINESS)
	local index = 1
	for i , id in ipairs(tasks) do
		local cfg = i3k_db_factionBusiness_task[id]
		if cfg then
			local node = require("ui/widgets/bpslt2")()
			local vars = node.vars
			vars.taskIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
			if cfg.awardID1 ~= 0 and cfg.awardCount1 ~= 0 then
				vars.awdIcon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.awardID1, g_i3k_game_context:IsFemaleRole()))
				vars.awdNum1:setText(string.format("x%s", cfg.awardCount1))
			else
				vars.awdIcon1:hide()
				vars.awdNum1:hide()
			end
			vars.taskName:setText(cfg.name)
			vars.exp:setText(string.format("x%s", cfg.exp))
			
			for i = 1 , 5 do
				if i <= cfg.starLvl then
					vars["star"..i]:show()
				else
					vars["star"..i]:hide()
				end
			end
	
			vars.quick_btn:setVisible(active >= quickCfg.needActivity)
			vars.quick_btn:onClick(self, self.onQuickFinishTask, id)
			if id == taskId then
				scroll:insertChildToIndex(node,1)
				vars.is_starting:show()
				vars.go_btn:hide()
				vars.get_btn:onClick(self, self.finisheTask, finished)
				if not finished then
					vars.getTxt:setText("放弃")
				else
					vars.quick_btn:hide()
					vars.getTxt:setText("领奖")
				end
				vars.highRoot:show()
			else
				scroll:addItem(node)
				vars.get_btn:hide()
				vars.is_starting:hide()
				vars.go_btn:onClick(self, self.getTask, id)
				--vars.quick_btn:hide()
				vars.getTxt:setText("领取")
			end
			if active < quickCfg.needActivity then
				local percent_go_btn = vars.go_btn:getPositionPercent()
				vars.go_btn:setPositionPercent(percent_go_btn.x, 0.5)
				local percent_get_btn = vars.get_btn:getPositionPercent()
				vars.get_btn:setPositionPercent(percent_get_btn.x, 0.5)
			end
		end
	end
end

function wnd_factionBusiness:getTask(sender, taskID)
	local data = g_i3k_game_context:getFactionBusinessTask()
	if data.id > 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17118))
	end
	if self.stageAllStar <= self.curStar then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17127))
		return
	end
	i3k_sbean.sect_trade_route_receiveReq(taskID)
end
--快速完成
function wnd_factionBusiness:onQuickFinishTask(sender, taskId)
	local data = g_i3k_game_context:getFactionBusinessTask()
	if data.id > 0 and data.id ~=  taskId then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17118))
	end
	if self.stageAllStar <= self.curStar then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17127))
		return
	end
	local quickCfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_BUSINESS)
	if g_i3k_game_context:GetCommonItemCanUseCount(quickCfg.needItemId) < quickCfg.needItemCount then
		--g_i3k_db.i3k_db_get_common_item_name(quickCfg.needItemId)
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5486))
	end
	if g_i3k_game_context:IsExcNeedShowTip(g_FACTION_BUSINESS_TASK) then
		local cfg = g_i3k_game_context:GetUserCfg()
		local function callbackRadioButton(randioButton,yesButton,noButton)
		end
		local callback = function(btn, state) 
			if btn then
				if state then
					cfg:SetTipNotShowDay(g_FACTION_BUSINESS_TASK, g_i3k_get_day(i3k_game_get_time()))
				end
				local data
				i3k_sbean.sect_trade_route_one_key_finish(taskId)
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
			else
				if state then
					cfg:SetTipNotShowDay(g_FACTION_BUSINESS_TASK, g_i3k_get_day(i3k_game_get_time()))
				end
				g_i3k_ui_mgr:CloseUI(eUIID_MessageBox3)
			end
		end
		g_i3k_ui_mgr:ShowMidCustomMessageBox2Ex(i3k_get_string(1139), i3k_get_string(1140), i3k_get_string(5485, quickCfg.needItemCount), i3k_get_string(16975), callback, callbackRadioButton)
	else
		i3k_sbean.sect_trade_route_one_key_finish(taskId)
	end
end

function wnd_factionBusiness:finisheTask(sender, finished)
	if finished then
		i3k_sbean.sect_trade_route_finishReq(self.taskId)
	else
		i3k_sbean.sect_trade_route_cancelReq(self.taskId)
	end
end

function wnd_factionBusiness:buyStar(sender, buyCnt)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyBusinessStars)
	g_i3k_ui_mgr:RefreshUI(eUIID_BuyBusinessStars, buyCnt)
end

function wnd_factionBusiness:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17117))
end

function wnd_create(layout, ...)
	local wnd = wnd_factionBusiness.new()
	wnd:create(layout, ...)
	return wnd;
end

