local loader_view = {}
loader_view.is_show_title = false

local ui = {}
function ui:AddLayout(list, parent, name, x, y, w, h)
	local node = XLayout:create(w, h)
	if nil == node then return end
	node:setAnchorPoint(0.5, 0.5)
	node:setPosition(x, y)

	if nil ~= parent then parent:addChild(node) end
	if nil ~= list then list[name] = node end
	return node
end

function ui:AddImage(list, parent, name, image, x, y, is_plist)
	if nil == is_plist then is_plist = false end
	local node = XImage:create(image, is_plist)
	if nil == node then return end
	node:setPosition(x, y)

	if nil ~= parent then parent:addChild(node) end
	if nil ~= list then list[name] = node end
	return node
end

function ui:AddText(list, parent, name, text, x, y, w, h, ha)
	local node = XText:create(text, "res/fonts/MNJCY.ttf", 28, cc.size(w, h), ha, cc.VERTICAL_TEXT_ALIGNMENT_TOP)
	if nil == node then return end
	node:setPosition(x, y)
	node:setColor(cc.c3b(0xff, 0xff, 0x00))
	node:enableOutline(cc.c4b(0, 0, 0, 255), 1)

	if nil ~= parent then parent:addChild(node) end
	if nil ~= list then list[name] = node end
	return node
end

function ui:AddProgress(list, parent, name, texture, x, y)
	local node = XLoadingBar:create()
	if nil == node then return end
	node:setPosition(x, y)
	node:loadTexture(texture)
	node:setPercent(0)

	if nil ~= parent then parent:addChild(node) end
	if nil ~= list then list[name] = node end
	return node
end

function ui:AddAnimate(list, parent, name, effect_path, effect_id, x, y)
	local node = AnimateSprite:create(effect_path, effect_id, 99999999, 0.17, false)
	node:setPosition(x, y)

	if nil ~= parent then parent:addChild(node) end
	if nil ~= list then list[name] = node end
	return node
end

---------------------------------------------------------------------------------------------------
-- init_query_view
---------------------------------------------------------------------------------------------------
local init_query_view = {}
function init_query_view:Start(task)
	if nil == task or "init_query" ~= task.Name() then return false end

	self.net_state = -1
	self.retry_count = 0
	self.task = task

	loader_view.prog.duration = 10
	loader_view:SetProgWeight("init_query", self.task.MAX_RETRY * 1)
	loader_view:SetProgPosition("init_query", 1 / self.task.MAX_RETRY)
	self:FlushNote("获取配置 ... ")

	return true
end
function init_query_view:Update()
	if nil == self.task then return end

	local task = self.task

	loader_view:SetProgPosition("init_query", task.retry_count / self.task.MAX_RETRY)

	if task.retry_count >= task.MAX_RETRY then
		self:FlushNote("连接失败，请检查网络是否正常 ")
		return
	end

	if task.retry_count ~= self.retry_count then
		self.retry_count = task.retry_count
		self:FlushNote()
	end

	if task.net_state ~= self.net_state then
		if  task.net_state < 1 then
			self:FlushNote("网络未连接，请开启网络 ")
		else
			self:FlushNote()
		end
		self.net_state = task.net_state
	end
end
function init_query_view:Stop()
	self:Update()
	loader_view:SetProgPosition("init_query", 1)

	self.task = nil
	self.net_state = -1
	self.retry_count = 0
end
function init_query_view:FlushNote(note)
	if nil ~= note then
		loader_view.node_list.lb_note:setString(note)
	else
		if self.retry_count > 1 then
			loader_view.node_list.lb_note:setString("获取配置[" .. self.retry_count .. "/" .. self.task.MAX_RETRY .. "] ... ")
		else
			loader_view.node_list.lb_note:setString("获取配置 ... ")
		end
	end
end

---------------------------------------------------------------------------------------------------
-- asset_update_view
---------------------------------------------------------------------------------------------------
local asset_update_view = {}
function asset_update_view:Start(task)
	if nil == task or "asset_update" ~= task.Name() then return false end

	self.task = task
	self.node_list = {}
	self.state = 0
	self.speed = 0
	self.speed_last_update = 0
	self.net_state = -1
	self.wifi_flag = -1
	self.dlg_open = false

	local lo_text = ui:AddLayout(self.node_list, loader_view.node_list.lo_scene, "lo_text", loader_view.size.width / 2, 170, 768, 48)
	local x1, x2, x3 = 0, 768 / 2 - 70, 768
	local node = ui:AddText(self.node_list, lo_text, "st_speed", "下载速度：", x1, 2, 200, 36, cc.TEXT_ALIGNMENT_RIGHT)
	node:setAnchorPoint(1, 0.5)
	node = ui:AddText(self.node_list, lo_text, "lb_speed", "", x1 + 5, 2, 200, 36, cc.TEXT_ALIGNMENT_LEFT)
	node:setAnchorPoint(0, 0.5)
	node = ui:AddText(self.node_list, lo_text, "st_size", "当前更新：", x2, 2, 200, 36, cc.TEXT_ALIGNMENT_RIGHT)
	node:setAnchorPoint(1, 0.5)
	node = ui:AddText(self.node_list, lo_text, "lb_size", "", x2 + 5, 2, 420, 36, cc.TEXT_ALIGNMENT_LEFT)
	node:setAnchorPoint(0, 0.5)
	node = ui:AddText(self.node_list, lo_text, "st_prog", "总进度：", x3, 2, 200, 36, cc.TEXT_ALIGNMENT_RIGHT)
	node:setAnchorPoint(1, 0.5)
	node = ui:AddText(self.node_list, lo_text, "lb_prog", "", x3 + 5, 2, 200, 36, cc.TEXT_ALIGNMENT_LEFT)
	node:setAnchorPoint(0, 0.5)
	lo_text:setVisible(false)

	local prog_weight = 50
	if task.size_total < 1000000 then
		prog_weight = task.size_total * 1000000
	end
	loader_view:SetProgWeight("asset_update", prog_weight)
	if task.file_total > 0 then
		loader_view:SetProgWeight("asset_update_move", 10)
	end

	-- loader_view.prog.duration = 3
	self:FlushNote("获取配置 ... ")

	return true
end

function asset_update_view:Update()
	if nil == self.task then return end

	local task = self.task

	if task.state ~= self.state or task.net_state ~= self.net_state or task.wifi_flag ~= self.wifi_flag then
		self.state = task.state
		self.net_state = task.net_state
		self.wifi_flag = task.wifi_flag	

		self:UpdateState(task.state)
		self:UpdateNetState(task.state, task.net_state, task.wifi_flag)
	end

	if nil == loader_view.prog then return end

	if 0 == self.speed or task.speed > (self.speed + 150000) or 0 == self.speed_last_update or NOW_TIME - self.speed_last_update > 3 then
		self.speed = task.speed * 0.7 + self.speed * 0.3
		self.speed_last_update = NOW_TIME
	end

	if nil ~= self.node_list.lb_speed then
		if self.speed > 1000000 then
			self.node_list.lb_speed:setString(string.format("%.1fMB/s", self.speed / 1000000))
		else
			self.node_list.lb_speed:setString(string.format("%.1fKB/s", self.speed / 1000))
		end
	end

	if nil ~= self.node_list.lb_size then
		self.node_list.lb_size:setString(string.format("%.1fMB / %.1fMB", (task.size_done + task.size_pend) / 1000000, task.size_total / 1000000))
	end

	if task.STATE_FETCH_FILE == task.state then
		local prog_done = 0.0
		if task.size_total > 0 then
			prog_done = (task.size_done + task.size_pend) / task.size_total 
		end
		if nil ~= self.node_list.lb_prog then	
			self.node_list.lb_prog:setString(string.format("%.1f%%", prog_done * 100))
		end

		loader_view:SetProgPosition("asset_update", prog_done)

	elseif task.STATE_MOVE == task.state then
		if task.file_total > 0 then
			loader_view:SetProgPosition("asset_update_move", task.file_moved / task.file_total)
		end
	end
end

function asset_update_view:Stop()
	self:Update()
	self.node_list.lo_text:setVisible(false)
	loader_view:SetProgPosition("asset_update", 1)
	loader_view:SetProgPosition("asset_update_move", 1)

	self.task = nil
	self.node_list = nil
	self.net_state = -1
	self.wifi_flag = -1
	self.dlg_open = false
end

function asset_update_view:UpdateState(new_state)
	if self.task.STATE_FETCH_INFO == new_state then
		print("asset_update_view:Update fetch_info")
		self.node_list.lo_text:setVisible(false)
		self:FlushNote("获取配置 ... ")
	elseif self.task.STATE_FETCH_FILE == new_state then
		print("asset_update_view:Update fetch_file")
		self.node_list.lo_text:setVisible(true)
		self:FlushNote("正在下载资源 ... ")
	elseif self.task.STATE_MOVE == new_state then
		self.node_list.lo_text:setVisible(false)
		self:FlushNote("正在拷贝资源 ... ")
	elseif self.task.STATE_ERROR == new_state then
		self.node_list.lo_text:setVisible(false)
		self:FlushNote("更新失败，请检查网络是否正常 ")
	elseif self.task.STATE_FATAL == new_state then
		self.node_list.lo_text:setVisible(false)
		self:FlushNote("文件错误，请重新安装游戏 ")
	else
		self.node_list.lo_text:setVisible(false)
	end
end

function asset_update_view:UpdateNetState(new_state, new_net_state, new_wifi_flag)
	print("asset_update_view:UpdateNetState " .. new_state .. " " .. new_net_state .. " " .. new_wifi_flag)

	if new_net_state < 1 then
		self:FlushNote("网络未连接，请检查网络是否正常 ")
		return
	end

	if self.task.STATE_FETCH_FILE ~= new_state then
		return
	end

	if new_net_state > 1 then
		return
	end

	if 0 == new_wifi_flag then
		self:FlushNote("WIFI未开启，请开启WIFI ")
	elseif 1 ~= new_wifi_flag then
		self:FlushNote("准备下载更新 ... ")
		self:CheckWifiDialog()
	end
end

function asset_update_view:CheckWifiDialog()
	if self.dlg_open then return end

	self.dlg_open = true
	local dlg_format = { cancelable = false, title = "更新提示", message = "WIFI未开启，确定更新?", positive = "确定", negative = "取消", }

	PlatformAdapter:OpenAlertDialog(dlg_format, 
		function (result) 
			if nil == loader_view or nil == loader_view.view then
				return
			end

			local task = loader_view.view.task
			if nil == task or "asset_update" ~= task.Name() then
				return
			end

			if "positive" == result then
				task:SetWifiFlag(1)
			else
				task:SetWifiFlag(0)
			end

			loader_view.view.wifi_flag = -1
			loader_view.view.dlg_open = false
		end
		)
end

function asset_update_view:FlushNote(note)
	if nil ~= note then
		loader_view.node_list.lb_note:setString(note)
	end
end

---------------------------------------------------------------------------------------------------
-- load_script_view
---------------------------------------------------------------------------------------------------
local load_script_view = {}
function load_script_view:Start(task)
	if nil == task or "load_script" ~= task.Name() then return false end

	self.task = task

	local left_w = loader_view:GetProgressLeftW()
	loader_view:SetProgWeight("load_script", left_w - 10)

	loader_view.prog.duration = 3
	loader_view.node_list.lb_note:setString("正在加载资源(不耗流量) ... ")

	return true
end

function load_script_view:Update()
	if nil == self.task then return end

	local task = self.task

	if MainLoader.TASK_STATUS_EXIT == task.task_status then
		loader_view.node_list.lb_note:setString("加载资源失败，请重新启动游戏 ")
	end

	if task.load_total > 0 then
		loader_view:SetProgPosition("load_script", task.load_done / task.load_total)
	end
end

function load_script_view:Stop()
	self:Update()
	loader_view.prog.duration = 1
	loader_view:SetProgPosition("load_script", 1)

	self.task = nil
end

---------------------------------------------------------------------------------------------------
-- player_view
---------------------------------------------------------------------------------------------------
local player_view = {}
function player_view:Start(task)
	if nil == task or "player" ~= task.Name() then return false end

	self.task = task

	local left_w = loader_view:GetProgressLeftW()
	loader_view:SetProgWeight("player", left_w)

	loader_view.prog.duration = 3
	loader_view.node_list.lb_note:setString("游戏启动中 ... ")

	return true
end

function player_view:Update()
	if nil == self.task then return end

	local task = self.task

	if task.STATE_INIT_FAILD == task.state then
		loader_view.node_list.lb_note:setString("游戏启动失败，请重新启动游戏 ")
	elseif task.STATE_INIT == task.state then
		-- loader_view.node_list.lb_note:setString(string.format("游戏启动中[%d/%d]", task.load_done, task.load_total))
		loader_view:SetProgPosition("player", task.load_done / task.load_total)
	end
end

function player_view:Stop()
	self:Update()
	loader_view.prog.duration = 1
	loader_view:SetProgPosition("player", 1)

	self.task = nil
end


---------------------------------------------------------------------------------------------------
-- loader_view
---------------------------------------------------------------------------------------------------
function loader_view:Create()
	print("loader_view:Create")
	self.scene = nil
	self.size = nil
	self.node_list = {}
	self.view = nil
	self.view_list = { ["init_query"] = init_query_view, ["asset_update"] = asset_update_view, ["load_script"] = load_script_view, ["player"] = player_view}
	self.prog = { target = 0, delay = 0, last_set = 0, width = 0, tail_pos = { x = 0, y = 0 }, duration = 2, total_w = 100}
	self.prog_list = {}

	self.scene = AdapterToLua:GetGameScene()
	if nil == self.scene then return end

	self.size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
	local scene_x, scene_y = self.size.width / 2, self.size.height / 2

	local lo_scene = ui:AddLayout(self.node_list, nil, "lo_scene", scene_x, scene_y, self.size.width, self.size.height)
	self.scene:addChildToRenderGroup(lo_scene, GRQ_UI_UP)

	local loading_bg_path = "agentres/loading_bg.jpg"
	if not cc.FileUtils:getInstance():isFileExist(loading_bg_path) then
		loading_bg_path = "res/xui/login/loading_bg_first.jpg"
	end

	local scene_bg = ui:AddImage(self.node_list, lo_scene, "bg_scene", loading_bg_path, scene_x, scene_y)
	--self:ZoomScene(scene_bg)
	
	--主界面logo显示
	if loader_view.is_show_title then	
		local logo_path = "res/xui/painting/loading_bg_first.png"
		ui:AddImage(self.node_list, lo_scene, "bg_logo", logo_path, scene_x + 250, scene_y + 100)
	end

	ui:AddImage(self.node_list, lo_scene, "bg_loading", "res/xui/login/loading.png", scene_x, 114)

	local pg_loading = ui:AddProgress(self.node_list, lo_scene, "pg_loading", "res/xui/login/loading_progress.png", scene_x, 110)
	-- ui:AddImage(self.node_list, lo_scene, "loading_up", "res/xui/login/loading_up.png", scene_x, 113)
	

	if nil ~= pg_loading then
		self.prog.width = pg_loading:getContentSize().width
		self.prog.tail_pos = { x = scene_x - (self.prog.width / 2), y = 112 }
		local effect = ui:AddAnimate(self.node_list, lo_scene, "sp_tail", "res/effect_ui/990.png", "effect_ui_990", self.prog.tail_pos.x, self.prog.tail_pos.y)
		effect:setScale(1.5)
	end
	ui:AddText(self.node_list, lo_scene, "lb_note", "", scene_x + 60, 70, 600, 32, cc.TEXT_ALIGNMENT_CENTER)

	-- 创建事件layer
	local event_layer = cc.Layer:create()
	self.scene:addChildToRenderGroup(event_layer, GRQ_UI_UP)

	local keyboard_listener = cc.EventListenerKeyboard:create()
	keyboard_listener:registerScriptHandler(function(key_code, event)
		if 6 == key_code then
			PlatformAdapter:OpenExitDialog()
		end
	end, cc.Handler.EVENT_KEYBOARD_RELEASED)

	event_layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(keyboard_listener, event_layer)
	local quick_reconnect = AdapterToLua:getInstance():getDataCache("QUICK_RECONNECT")
	if quick_reconnect == "true" then
		for k,v in pairs(self.node_list) do
		 	if v.setVisible then
		 		v:setVisible(false)
		 	end
		end 
	end
end

function loader_view:GetProgressLeftW()
	local now_w = 0
	for k, v in pairs(loader_view.prog_list) do
		now_w = now_w + v.w
	end
	return loader_view.prog.total_w - now_w
end

local point_bg_t = {}
local point_bg_vis_index = 0

function loader_view:AuditVersionChanged()
	if IS_AUDIT_VERSION then
		self.node_list.bg_loading:setVisible(false)
		self.node_list.pg_loading:setVisible(false)
		self.node_list.sp_tail:setVisible(false)
		self.node_list.lb_note:setString("登陆中, 请稍后。。")
	end

end

function loader_view:OpenReconnectView()
	if self.layout_net_unstable or nil == AdapterToLua:GetGameScene() then return end

	self.size = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
	local scene_x, scene_y = self.size.width / 2, self.size.height / 2
	self.layout_net_unstable = ui:AddLayout(nil, nil, nil, scene_x, scene_y, self.size.width, self.size.height)
	AdapterToLua:GetGameScene():addChildToRenderGroup(self.layout_net_unstable, GRQ_UI_UP)
	self.layout_net_unstable:setBackGroundColor(cc.c3b(0x00, 0x00, 0x00))
		self.layout_net_unstable:setBackGroundColorOpacity(128)
	self.layout_net_unstable:setTouchEnabled(true)

	local img_bg = ui:AddImage(nil, self.layout_net_unstable, nil, "res/xui/painting/re_connect_bg.png", self.size.width / 2, self.size.height / 2)

	local point_path = "res/xui/login/orn_103.png"
	local point_bg = ui:AddImage(nil, img_bg, nil, point_path, 312, 145)
	point_bg_t = {}
	for i = 1, 4 do
		point_bg_t[i] = ui:AddImage(nil, img_bg, nil, point_path, 312 + i * 17, 145)
		point_bg_t[i]:setVisible(false)
	end
	local delay_time = cc.DelayTime:create(1)
	local time = 0
	local func = function()
		time = time + 1
		if time > 30 then
			AdapterToLua:getInstance():setDataCache("IS_RECONNECT_ING", "false")
			AdapterToLua:getInstance():setDataCache("QUICK_RECONNECT", "false")
			GlobalEventSystem:Fire(LoginEventType.GAME_SERVER_DISCONNECTED, GameNet.DISCONNECT_REASON_NORMAL, true)
			self:CloseReconnectView()
			return
		end
		point_bg_vis_index = point_bg_vis_index + 1
		if point_bg_vis_index > 4 then
			for k,v in pairs(point_bg_t) do
				if v.setVisible then
					v:setVisible(false)
				end
			end
			point_bg_vis_index = 0
		elseif point_bg_t[point_bg_vis_index] and point_bg_t[point_bg_vis_index].setVisible then
			point_bg_t[point_bg_vis_index]:setVisible(true)
		end
	end
	local call_back = cc.CallFunc:create(func)
	local action = cc.Sequence:create(delay_time, call_back)
	local forever = cc.RepeatForever:create(action)
	self.layout_net_unstable:stopAllActions()
	self.layout_net_unstable:runAction(forever)
end

function loader_view:CloseReconnectView()
	if self.layout_net_unstable and self.layout_net_unstable.removeFromParent then
		point_bg_t = {}
		self.layout_net_unstable:stopAllActions()
		self.layout_net_unstable:removeFromParent()
		self.layout_net_unstable = nil
	end
end
function loader_view:ZoomScene(scene_bg)
	if nil == scene_bg then return end

	scene_bg:stopAllActions()
	local scale_act = cc.ScaleTo:create(7, 1.1)
	scene_bg:runAction(scale_act)
end

function loader_view:Destroy()
	print("loader_view:Destroy")

	if nil ~= self.view then
		self.view:Stop()
		self.view = nil
	end
	self.view_list = nil
	self.node_list = nil
	self.size = nil
	self.scene = nil
	self.prog = nil
	self.prog_list = nil
end

function loader_view:Update(dt)
	if nil == self.scene then return end

	if nil ~= self.view then
		self.view:Update()
	end

	local prog = self.prog
	local pg_loading = self.node_list.pg_loading
	local sp_tail = self.node_list.sp_tail

	if self.prog and nil ~= pg_loading and prog.delay < prog.target then
		prog.delay = prog.target

		if nil ~= sp_tail then
			local x = prog.tail_pos.x + (prog.width * (prog.delay / 100))
			sp_tail:setPosition(x, prog.tail_pos.y)
		end

		pg_loading:setPercent(prog.delay)
	end
end

function loader_view:SetProgPosition(t, p)
	local prog = self.prog_list[t]
	if nil ~= prog then 
		prog.p = p
	end
	self:UpdateProgress()
end

function loader_view:SetProgWeight(t, w)
	if w <= 0 then
		self.prog_list[t] = nil
	else
		if nil == self.prog_list[t] then 
			self.prog_list[t] = {w = 1, p = 0}
		end
		self.prog_list[t].w = w
	end

	self:UpdateProgress()
end

function loader_view:UpdateProgress()
	local now_w = 0 
	for _, v in pairs(self.prog_list) do
		now_w = now_w + v.w * v.p
	end
	if now_w > 0 then
		local target_p = now_w / self.prog.total_w * 100
		if target_p < self.prog.delay then
			target_p = self.prog.delay
		end

		self.prog.target = target_p
	end
end

function loader_view:StartTask(task)
	if nil == self.scene or nil ~= self.view then return end

	if nil ~= task and nil ~= task.Name then
		local view = self.view_list[task.Name()]
		if nil ~= view and view:Start(task) then
			self.view = view
		end
	end
end

function loader_view:StopTask(task)
	if nil == self.scene or nil == self.view then return end

	self.view:Stop()
	self.view = nil
end

return loader_view
