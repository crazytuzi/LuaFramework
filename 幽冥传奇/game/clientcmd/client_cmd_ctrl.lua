
require("scripts/game/clientcmd/client_cmd_view")
require("scripts/game/clientcmd/reload_script")

-- 客户端命令
ClientCmdCtrl = ClientCmdCtrl or BaseClass(BaseController)

function ClientCmdCtrl:__init()
	if ClientCmdCtrl.Instance then
		ErrorLog("[ClientCmdCtrl] Attempt to create singleton twice!")
		return
	end
	ClientCmdCtrl.Instance = self

	if PLATFORM == cc.PLATFORM_OS_WINDOWS then
		self.reload_script_manager = ReloadScriptManager.New()		-- 热加载脚本
	end

	self.view = ClientCmdView.New(ViewDef.ClientCmd)
	self.end_game_alert = nil
	self.cmd_func_list = {}
	self:InitConsoleCmd()

	self.mem_info_is_open = false					-- 内存信息是否开启
	self.last_mem_info_time = 0						-- 最后显示内存信息时间
	self.memory_info = {}

	self.last_check_mem_time = 0					-- 上次检测内存时间

	self.mem_clear_value = 0						-- 内存清理阀值
	local mem_size = PlatformAdapter.GetDeviceMemSize()
	if mem_size > 0 then
		if mem_size <= 512 * 1024 * 1024 then
			self.mem_clear_value = 120 * 1024 * 1024
		elseif mem_size <= 768 * 1024 * 1024 then
			self.mem_clear_value = 200 * 1024 * 1024
		end
	end
	self.is_memory_lack = false						-- 是否内存不足

	self:RegisterAllEvents()

	Runner.Instance:AddRunObj(self, 4)
end

function ClientCmdCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil
	
	if nil ~= self.reload_script_manager then
		self.reload_script_manager:DeleteMe()
		self.reload_script_manager = nil
	end

	ClientCmdCtrl.Instance = nil

	Runner.Instance:RemoveRunObj(self)
end

function ClientCmdCtrl:RegisterAllEvents()
	self:Bind(LayerEventType.KEYBOARD_RELEASED, BindTool.Bind1(self.OnKeypad, self))
	self:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind1(self.OnLoadingSceneEnter, self))
	self:Bind(AppEventType.ENTER_BACKGROUND, BindTool.Bind1(self.EnterBackground, self))
end

function ClientCmdCtrl:OnKeypad(key_code)
	if key_code == 6 then							-- 返回按键
		if IS_IOS_OR_ANDROID then
			PlatformAdapter:OpenExitDialog()
		else
			if nil == self.end_game_alert then
			self.end_game_alert = Alert.New(Language.Common.IsEndGame, function()
				AdapterToLua:endGame()
				end)
			end
			if self.end_game_alert:IsOpen() then
				self.end_game_alert:Close()
			else
				self.end_game_alert:Open()
			end
			self.end_game_alert:GetRealRootNode():setLocalZOrder(COMMON_CONSTS.ZORDER_ENDGAME)
		end
	end
end

function ClientCmdCtrl:OnLoadingSceneEnter(scene_id)
	self.view:OnChangeScene(scene_id)
end

function ClientCmdCtrl:IsMemoryLack()
	return self.is_memory_lack
end

function ClientCmdCtrl:EnterBackground()
	self:ClearMemory()
end

-- 清理内存
function ClientCmdCtrl:ClearMemory()
	AdapterToLua:clearUnusedAnimate(false)
	ResourceMgr:getInstance():clearUnused(false)
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function ClientCmdCtrl:Update(now_time, elapse_time)
	if self.mem_info_is_open and now_time >= self.last_mem_info_time + 1 then
		self.last_mem_info_time = now_time
		self:OnMemoryInfo()
	end

	if self.mem_clear_value > 0 and now_time >= self.last_check_mem_time + 2 then
		self.last_check_mem_time = now_time

		self.is_memory_lack = cc.Director:getInstance():getTextureCache():getTotalBytes() >= self.mem_clear_value
		if self.is_memory_lack then
			self:ClearMemory()
		end
	end
end

-- 显示内存信息
function ClientCmdCtrl:OnMemoryInfo()
	if nil == self.memory_info.layout then
		local w = HandleRenderUnit:GetWidth()
		self.memory_info.layout = XUI.CreateLayout(w - 80, 30, 160, 60)
		HandleRenderUnit:GetCoreScene():addChildToRenderGroup(self.memory_info.layout, GRQ_UI_UP)

		self.memory_info.text_uss = XUI.CreateText(60, 50, 160, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 18)
		self.memory_info.layout:addChild(self.memory_info.text_uss)

		self.memory_info.text_pss = XUI.CreateText(60, 30, 160, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 18)
		self.memory_info.layout:addChild(self.memory_info.text_pss)

		self.memory_info.text_rss = XUI.CreateText(60, 10, 160, 20, cc.TEXT_ALIGNMENT_LEFT, "", nil, 18)
		self.memory_info.layout:addChild(self.memory_info.text_rss)
	end

	local mem_status = PlatformAdapter.GetMemStatus() or {}
	self.memory_info.text_uss:setString(string.format("USS: %d KB", mem_status.uss or 0))
	self.memory_info.text_pss:setString(string.format("PSS: %d KB", mem_status.pss or 0))
	self.memory_info.text_rss:setString(string.format("RSS: %d KB", mem_status.rss or 0))
end

function ClientCmdCtrl:Cmd(text)
	if nil == text or "" == text then
		return
	end
	
	local params = Split(text, " ")
	if #params < 1 then
		return
	end

	local name = params[1]

	if "texture" == name then
		Log(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	elseif "fps" == name then
		local on_off = "on" == params[2] and true or false
		cc.Director:getInstance():setDisplayStats(on_off)
	else
		local func = self.cmd_func_list[name]
		if nil ~= func then
			local str = ""
			for i = 2, #params do
				if i > 2 then
					str = str .. " " .. params[i]
				else
					str = str .. params[i]
				end
			end

			func(0, str)
		end
	end
end

function ClientCmdCtrl:RegCmdFunc(name, help, callback_func)
	self.cmd_func_list[name] = callback_func
	cc.Director:getInstance():getConsole():addCommand({["name"] = name, ["help"] = "__" .. help}, callback_func)
end

-- 初始化命令
function ClientCmdCtrl:InitConsoleCmd()
	self:RegCmdFunc("open", "open cmd view", BindTool.Bind1(self.CmdOpen, self))
	self:RegCmdFunc("disconnect", "disconnect game server", BindTool.Bind1(self.CmdDisconnect, self))
	self:RegCmdFunc("/gm", "gm command format \"/gm [type:text]\"", BindTool.Bind1(self.CmdGm, self))
	self:RegCmdFunc("pos", "show role pos [on/off]", BindTool.Bind1(self.ShowRolePos, self))
	self:RegCmdFunc("effect", "flower", BindTool.Bind1(self.ShowParticleEffect, self))
	self:RegCmdFunc("nodecount", "show all node count", BindTool.Bind1(self.ShowNodeCount, self))
	self:RegCmdFunc("refcount", "show reference count", BindTool.Bind1(self.ShowRefCount, self))
	self:RegCmdFunc("acce", "Accelerometer [on/off]", BindTool.Bind1(self.OnAccelerometer, self))
	self:RegCmdFunc("gc", "lua gc [count/collect/step]", BindTool.Bind1(self.OnLuaGC, self))
	self:RegCmdFunc("zoome", "zoome", BindTool.Bind1(self.Zoome, self))
	self:RegCmdFunc("wifi", "wifi state", BindTool.Bind1(self.OnWifi, self))
	self:RegCmdFunc("mem", "memory [on/off/cls/clsf]", BindTool.Bind1(self.OnMemoryCmd, self))
	self:RegCmdFunc("stop", "stop game", BindTool.Bind1(self.OnStop, self))
	self:RegCmdFunc("rolecount", "print role count", BindTool.Bind1(self.OnRoleCount, self))
	self:RegCmdFunc("funopen", "force funopen", BindTool.Bind1(self.FunOpen, self))
	self:RegCmdFunc("funclose", "force funclose", BindTool.Bind1(self.FunClose, self))
	self:RegCmdFunc("addchat", "add chat msg [count]", BindTool.Bind1(self.OnAddChat, self))
	self:RegCmdFunc("gmauto", "gmauto", BindTool.Bind1(self.GmAuto, self))
	self:RegCmdFunc("actedit", "actedit", BindTool.Bind1(self.ActEdit, self))
	self:RegCmdFunc("fly", "fly", BindTool.Bind1(self.Fly, self))
	self:RegCmdFunc("camera", "camera", BindTool.Bind1(self.Camera, self))
	self:RegCmdFunc("test", "test", BindTool.Bind1(self.OnTest, self))
	self:RegCmdFunc("error", "error test", BindTool.Bind1(self.OnErrorTest, self))
	self:RegCmdFunc("guide", "guide test", BindTool.Bind1(self.OnGuide, self))
	self:RegCmdFunc("exec", "execute lus", BindTool.Bind1(self.OnExecute, self))
end

function ClientCmdCtrl:CmdOpen(fd, str)
	self.view:Open()
end

function ClientCmdCtrl:CmdDisconnect(fd, str)
	GameNet.Instance:DisconnectGameServer()
end

function ClientCmdCtrl:CmdGm(fd, str)
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.WORLD, str)
end

function ClientCmdCtrl:ShowRolePos(fd, str)
	GlobalData.is_show_role_pos = ("on" == str)

	local role_list = Scene.Instance:GetObjListByType(SceneObjType.Role)
	if nil ~= role_list then
		for k, v in pairs(role_list) do
			v:UpdateNameBoard()
		end
	end
	Scene.Instance:GetMainRole():UpdateNameBoard()
end

function ClientCmdCtrl:ShowParticleEffect(fd, str)
	-- ParticleEffectSys.Instance:StopEffect("testeffect")
	print("ShowParticleEffect------", str)
	if str == "test" then
		ParticleEffectSys.Instance:PlayEffect(Effect_Test, "testeffect", nil, "testeffect")
	else
		if "Effect_Red_Flower" == str then
			ParticleEffectSys.Instance:PlayEffect(Effect_Red_Flower, "Effect_Red_Flower", nil, "Effect_Red_Flower")
		end
		if "Effect_Blue_Flower" == str then
			ParticleEffectSys.Instance:PlayEffect(Effect_Blue_Flower, "Effect_Blue_Flower", nil, "Effect_Blue_Flower")
		end
	end
end

function ClientCmdCtrl:ShowNodeCount(fd, str)
	local node_count = 1
	local function get_child_count(node)
		local node_list = node:getChildren()
		for i, v in ipairs(node_list) do
			node_count = node_count + 1
			get_child_count(v)
		end
	end
	
	get_child_count(HandleRenderUnit:GetCoreScene())

	print("all_node_count:" .. node_count)
end

-- 所有对象引用计数总和
function ClientCmdCtrl:ShowRefCount(fd, str)
	print("all_ref_count:" .. AdapterToLua:getRefCount())
end

-- 加速度计开关
function ClientCmdCtrl:OnAccelerometer(fd, str)
	if str == "on" then
		HandleRenderUnit:SetAccelerometerEnabled(true)
	else
		HandleRenderUnit:SetAccelerometerEnabled(false)
	end
end

-- lua内存查看、回收
function ClientCmdCtrl:OnLuaGC(fd, str)
	if "count" == str then
		print("lua gc count=" .. collectgarbage("count") .. "KB")
	elseif "collect" == str or "step" == str then
		collectgarbage(str)
	elseif "on" == str then
		if nil == self.gc_timer then
			self.gc_timer = GlobalTimerQuest:AddRunQuest(function()
				local mem_count = collectgarbage("count")
				self.last_mem_count = self.last_mem_count or 0
				if mem_count < self.last_mem_count then
					print("lua gc count=" .. mem_count .. "KB", "============")
				else
					print("lua gc count=" .. mem_count .. "KB")
				end
				self.last_mem_count = mem_count
			end, 0.1)
		end
	elseif "off" == str then
		if nil ~= self.gc_timer then
			GlobalTimerQuest:CancelQuest(self.gc_timer)
			self.gc_timer = nil
		end
	end
end

--镜头缩放
function ClientCmdCtrl:Zoome(fd, str)
	-- if self.scale == nil or self.scale == 1 then
	-- 	self.scale = 0.5
	-- else
	-- 	self.scale = 1
	-- end
	-- HandleGameMapHandler:SetCameaScale(self.scale)
end

function ClientCmdCtrl:OnWifi(fd, str)
	local is_open = AdapterToLua:isWifiOpen()
	Log("wifi is " .. (is_open and "open" or "close"))
end

function ClientCmdCtrl:OnMemoryCmd(fd, str)
	if "on" == str then
		self.mem_info_is_open = true
	elseif "off" == str then
		self.mem_info_is_open = false
		if nil ~= self.memory_info.layout then
			self.memory_info.layout:removeFromParent()
			self.memory_info = {}
		end
	elseif "cls" == str then
		self:ClearMemory()
	elseif "log" == str then
		self:OnLuaGC("", "collect")
		self:OnLuaGC("", "count")
		self:ShowNodeCount("", "")
		self:ShowRefCount("", "")
		local total_texture_bytes = cc.Director:getInstance():getTextureCache():getTotalBytes()
		print("texture mem:" .. total_texture_bytes / 1024 .. "KB")
	end
end

function ClientCmdCtrl:OnStop(fd, str)
	Stop()
end

function ClientCmdCtrl:OnRoleCount(fd, str)
	local total_count = 0
	local show_count = 0

	local role_list = Scene.Instance:GetRoleList()
	for k, v in pairs(role_list) do
		total_count = total_count + 1
		if v:GetModel():IsVisible() then
			show_count = show_count + 1
		end
	end

	Log("========role total_count:" .. total_count, "show_count:" .. show_count)
end

function ClientCmdCtrl:FunOpen(fd, fun_name)

end

function ClientCmdCtrl:FunClose(fd, fun_name)

end

function ClientCmdCtrl:OnAddChat(fd, str)
	-- local count = tonumber(str) or 1
	-- for i = 1, count do
	-- 	local msg = "我是一条系统消息i" .. i
	-- 	msg = msg .. "  以下是凑字数的---------------------------------------！" ..i
	-- 	if math.random(2) == 2 then
	-- 		msg = msg .. "  再凑一段-----------------------------------------！" .. i
	-- 	end
	-- 	ChatCtrl.Instance:AddSystemMsg(msg)
	-- end

	if "on" == str then
		if nil == self.chat_timer then
			self.chat_timer = GlobalTimerQuest:AddRunQuest(function()
				local msg = "我是一条系统消息:"
				msg = msg .. "  以下是凑字数的---------------------------------------！"
				if math.random(2) == 2 then
					msg = msg .. "  再凑一段-----------------------------------------！"
				end
				ChatCtrl.Instance:AddSystemMsg(msg)
			end, 0.1)
		end
	elseif "off" == str then
		if nil ~= self.chat_timer then
			GlobalTimerQuest:CancelQuest(self.chat_timer)
			self.chat_timer = nil
		end
	end
end

function ClientCmdCtrl:GmAuto()
	TaskGuide.Instance:SetGmAuto()
end

function ClientCmdCtrl:ActEdit(fd, str)

end

function ClientCmdCtrl:Camera(fd, str)
	local scale = tonumber(str or 1)
	Log("Camera-scale：", scale)
	Scene.Instance:SetSceneCameraScaleTo(scale, 1)
end

function ClientCmdCtrl:Fly(fd, str)
end

function ClientCmdCtrl:OnTest(fd, str)

end

function ClientCmdCtrl:GetAllItemConfig()
	local path = cc.FileUtils:getInstance():getWritablePath()
	for line in io.lines(path .. "guaji_items.lua") do
		local item_id = tonumber(line)
		if item_id then
			ItemData.Instance:GetItemConfig(item_id)
		end
	end
end

function ClientCmdCtrl:CollectFileInfo()
	local path = cc.FileUtils:getInstance():getWritablePath()

	local item_list = {}
	for line in io.lines(path .. "guaji_items.lua") do
		local item_id = tonumber(line)
		if item_id then
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			-- local level, circle_lv = ItemData.Instance:GetItemLevel(item_id)
			-- if item_list[circle_lv] == nil then item_list[circle_lv] = {} end
			-- if item_list[circle_lv][level] == nil then 
			-- 	item_list[circle_lv][level] = {name = item_cfg.name, count = 1}
			-- else
			-- 	item_list[circle_lv][level].count = item_list[circle_lv][level].count + 1
			-- end
		end
	end

	local sb = {}
	for k, v in pairs(item_list) do
		for k1, v1 in pairs(v) do
			table.insert(sb, string.format("%d转%d级\t%s\tX%d", k, k1, v1.name, v1.count))
		end
	end

	local str = table.concat(sb, "\r\n")
	local file = io.open(path .. "guaji_items_list.txt", "w")
	file:write(str)
	file:close()
end

function ClientCmdCtrl:OnErrorTest(fd, str)
	if "c" == str or "C" == str then
		AdapterToLua:testDump()
	else
		a.b = 0
	end
end

function ClientCmdCtrl:OnGuide(fd, str)
	GuideCtrl.Instance:StartGuide(tonumber(str))
end

function ClientCmdCtrl:OnExecute(fd, str)
	_G.package.loaded["scripts/game/clientcmd/client_cmd_script"] = nil
	require("scripts/game/clientcmd/client_cmd_script")
end
