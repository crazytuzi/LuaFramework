ReloadScriptManager = ReloadScriptManager or BaseClass()

local reload_file_list = {
	"scripts/game/clientcmd/reload_script",
	"scripts/language/language",
	"scripts/game/activity/activity_guide_ctrl",
	"scripts/game/fuben/fuben_ctrl",
	"scripts/game/fuben/fuben_data",
	"scripts/game/bag/bag_controller",
	"scripts/game/bag/item_data",
}

local reload_ui_file_list = {
	"scripts/config/auto_new/story_auto",
}

DESKTOP_PATH = "C:/Users/Administrator/Desktop/"
local BOSS_FILE_NAME = "cq12_kill_boss"
local GUAJI_ITEMS_FILE_NAME = "cq12_guaji_items"
local PARSE_ITEM_FILE_NAME = "cq12_items_statistics"
local PARSE_BOSS_FILE_NAME = "cq12_boss_statistics"

function ReloadScriptManager:__init()
	if nil ~= ReloadScriptManager.Instance then
		ErrorLog("[ReloadScriptManager]:Attempt to create singleton twice!")
	end

	ReloadScriptManager.Instance = self

	cc.Director:getInstance():setDisplayStats(true)
	Runner.Instance:AddRunObj(self, 10)

	self.rect_list = {}
	self.point_list = {}
	self.cache_key_list = {}

	GlobalEventSystem:Bind(LayerEventType.KEYBOARD_RELEASED, BindTool.Bind(self.OnKeypad, self))
	self.item_change_callback = BindTool.Bind(self.ItemChange, self)
	self.obj_create_bind = GlobalEventSystem:Bind(ObjectEventType.OBJ_ATTR_CHANGE, BindTool.Bind(self.OnObjAttrChange, self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.SceneChange, self))
	GlobalEventSystem:Bind(LoginEventType.GAME_SERVER_DISCONNECTED, BindTool.Bind(self.OnDisconnectGameServer, self))

	self.auto_recycle_equip = false
	self.auto_kill_boss = false
	self.kill_boss_type = 1
	self.have_sky_boss_id = 0
	self.auto_kill_boss_update_time = 0
	self.cur_wild_boss_t = {boss_id = 0, has_chuansong = 0, cfg = nil}

	self.guajictrl_onoperatefight_func = GuajiCtrl.OnOperateFight
	self.guajictrl_canautoboss_func = GuajiCtrl.CanAutoBoss
	self.scene_getmindisboss_func = Scene.GetMinDisBoss
	self.scene_isenemy_func = Scene.IsEnemy
	self.bossctrl_onskybossawake_func = BossCtrl.OnSkyBossAwake

	if "dev" == AgentAdapter:GetSpid() then
		PLAT_ACCOUNT_TYPE_COMMON = -1
		AdapterToLua:getInstance():setDataCache("HAS_OPEN_NOTICE", "true")
	end

	--keytest
	local num = 0
	GlobalEventSystem:Bind(LayerEventType.KEYBOARD_RELEASED, function (key_code, event)
		if cc.KeyCode.KEY_T == key_code and event == cc.Handler.EVENT_KEYBOARD_PRESSED then
			--ViewManager.Instance:OpenViewByDef(ViewDef.ShenqiView)
		end
	end)
end

function ReloadScriptManager:__delete()
	ReloadScriptManager.Instance = nil
	if Runner.Instance then
		Runner.Instance:RemoveRunObj(self)
	end
end

function ReloadScriptManager:DoKeyF()
	local main_role = Scene.Instance:GetMainRole()
end

function ReloadScriptManager:DoKeyS()
end

function ReloadScriptManager:SwitchUpdate()
	-- GodFurnaceCtrl.SendGodFurnaceUpReq(3)

	-- WingCtrl.SendWingUpGradeReq(1,1)

	-- 内功提升
	-- ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@addmoney 0 2222222")
	-- InnerCtrl.SendInnerUpReq()

	-- 神炉
	-- for i = 2, 5 do
	-- 	GodFurnaceCtrl.SendGodFurnaceUpReq(i)
	-- end
end

function ReloadScriptManager:Update()
	self:UpdateMainRoleMove()
	self:UpdateKey()
	-- self:UpdateDoTask()

	-- if self.switch then
	-- 	self:SwitchUpdate()
	-- end
end

function ReloadScriptManager:IsHodeOnKey(key_code_name)
	for k, v in pairs(self.cache_key_list) do
		if v == cc.KeyCode[key_code_name] then
			return true
		end
	end

	return false
end

function ReloadScriptManager:OnKeypad(key_code, event)
	if cc.Handler.EVENT_KEYBOARD_PRESSED == event then
		table.insert(self.cache_key_list, 1, key_code)
	else
		for k, v in pairs(self.cache_key_list) do
			if key_code == v then
				table.remove(self.cache_key_list, k)
				break
			end
		end
	end

	if cc.KeyCode.KEY_W == key_code then
		self:DoKeyMove(key_code, event, GameMath.DirUp)
	elseif cc.KeyCode.KEY_S == key_code then
		self:DoKeyMove(key_code, event, GameMath.DirDown)
	elseif cc.KeyCode.KEY_A == key_code then
		self:DoKeyMove(key_code, event, GameMath.DirLeft)
	elseif cc.KeyCode.KEY_D == key_code then
		self:DoKeyMove(key_code, event, GameMath.DirRight)
	elseif cc.KeyCode.KEY_SPACE == key_code and event == cc.Handler.EVENT_KEYBOARD_PRESSED then
		self:DoKeyAttack(0)
	elseif cc.KeyCode.KEY_0 <= key_code and cc.KeyCode.KEY_7 >= key_code and event == cc.Handler.EVENT_KEYBOARD_PRESSED then
		self:DoKeyAttack(key_code - cc.KeyCode.KEY_0)
	end

	self:DoKey(key_code, event)

	self:DoGmKey(key_code, event)
end

--------------------------------------------
-- 普通键盘事件 begin
--------------------------------------------
local cache_key_t = {}
local last_on_key_time = 0
local one_key_pressed = false
function ReloadScriptManager:DoKey(key_code, event)
	if cc.Handler.EVENT_KEYBOARD_PRESSED == event then
		table.insert(cache_key_t, key_code)
		one_key_pressed = true
	else
		one_key_pressed = false
		if self:OnKey(cache_key_t) then
			last_on_key_time = 0
			cache_key_t = {}
		end
	end
	last_on_key_time = NOW_TIME
end

function ReloadScriptManager:UpdateKey()
	if not one_key_pressed and (0.5 < (NOW_TIME - last_on_key_time)) then
		cache_key_t = {}
	end
end

function ReloadScriptManager:OnKey(key_t)
	local num = #key_t
	if 0 == num then
		return false
	end

	local function compareKey(order, key_code_name)
		if nil == key_t[order] or nil == cc.KeyCode[key_code_name] then
			return false
		end
		return key_t[order] == cc.KeyCode[key_code_name]
	end

	local function compareKeys(key_str)
		local param = {}
		for i = 1, string.len(key_str) do
			param[i] = string.sub(key_str, i, i)
		end

		for i = 1, #param do
			if not compareKey(i, "KEY_" .. string.upper(param[i])) then
				return false
			end
		end
		return true
	end

	local trigger = true
	if compareKey(1, "KEY_ALT") then
		if compareKey(2, "KEY_R") then
			self:DoReloadScript()
			self:LoadTestStoryCfg()
		elseif compareKey(2, "KEY_F") then
			self:DoKeyF()
			
		elseif compareKey(2, "KEY_S") then
			self.switch = not self.switch
			self:DoKeyS()

		elseif compareKey(2, "KEY_G") then
			self:CreateTestStoryRealCfg()
		elseif compareKey(2, "KEY_W") and compareKey(3, "KEY_W") then
			-- 修改连接外网文件脚本
			-- self:SetClientEnvironment("att")
		else
			trigger = false
		end

	elseif compareKey(1, "KEY_CTRL") then
		if compareKey(2, "KEY_V") then
			local content = self:GetSysClipContent()
			content = string.gsub(content, "\n", " ")
			if self.gm_text and self.gm_text:isVisible() then
				self.gm_text:deleteOneChar()
				self.gm_text:addString(content)
				self.gm_text:flushView()
			end
		end

	elseif compareKey(1, "KEY_DELETE") then
		self:SetNodeVisible()

	elseif compareKey(1, "KEY_G") and compareKey(2, "KEY_M") then
		self:StartGm()

	elseif compareKeys("exit") then
		-- 退出游戏
		AdapterToLua:endGame()
	elseif compareKeys("srole") then
		-- 返回选择角色界面
		AdapterToLua:getInstance():setDataCache("IS_RECONNECT_ING", "true")
		AdapterToLua:getInstance():setDataCache("IS_RESELECTROLE", "true")
		ReStart()
	elseif compareKeys("cav") then
		ViewManager.Instance:CloseAllView()
	elseif compareKeys("cs") then
		-- 传到炎龙城
		Scene.SendQuicklyTransportReqByNpcId(CLIENT_GAME_GLOBAL_CFG.chuansong_npc_id)
	elseif compareKeys("boss") then
		-- 自动刷boss
		-- self:AutoKillBoss()
	elseif compareKeys("parse") then
		self:ParseStoryRealCfg()
	elseif compareKeys("r1") then
		-- 解析物品
		self:ParseItemByitemIdFile()
	elseif compareKeys("r2") then
		-- 解析boss
		self:ParseBossByBossNameFile()
	elseif compareKeys("lgn") then
		-- 返回登陆界面
		ReStart()
	elseif compareKeys("rs") then
		-- 快速重新加载游戏
		if not IS_ON_CROSSSERVER then
			AdapterToLua:getInstance():setDataCache("GUA_JI_TYPE", GuajiCache.guaji_type)
			AdapterToLua:getInstance():setDataCache("SCENE_ID", Scene.Instance:GetSceneId())
			AdapterToLua:getInstance():setDataCache("IS_RECONNECT_ING", "true")
			AdapterToLua:getInstance():setDataCache("QUICK_RECONNECT", "true")
			LoginController.Instance:OnDisconnectGameServer(GameNet.DISCONNECT_REASON_NORMAL)
			ReStart()
		else
			CrossServerCtrl.SentQuitCrossServerReq(CROSS_SERVER_TYPE.FUBEN, 0)
		end

	elseif compareKeys("m") then
		-- 加绑金
		-- ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@addmoney 0 22222222222222")

	elseif compareKeys("res") then
		io.popen("explorer ..\\assets")
	elseif compareKeys("uir") then
		io.popen("explorer ..\\..\\tools\\uieditor\\ui_res")
	elseif compareKeys("vs") then
		io.popen("\"D:\\Program Files (x86)\\VSCode\\Code.exe\"")
	elseif compareKeys("st") then
		io.popen("\"D:\\Program Files\\sublime text 3\\sublime_text.exe\"")
	elseif compareKeys("dsn") then
		-- 进入设计模式
		self:ChangeDesignState()
	elseif compareKeys("ap") then
		-- 屏幕点
		self:AddPoint()
	elseif compareKeys("cap") then
		-- 清除所有屏幕点
		self:ClearAllPoint()
	elseif compareKeys("ar") then
		-- 屏幕矩形
		self:AddRect()
	elseif compareKeys("car") then
		-- 清除所有屏幕矩形
		self:ClearAllRect()
	elseif compareKeys("qv") then
		-- 打开上一次存储的视图
		self:OpenQuickView()
	elseif compareKeys("qs") then
		-- 存储当前的视图信息
		self:SetViewMarkData()
	elseif compareKeys("cmd") then
		if ViewManager.Instance:IsOpen(ViewDef.ClientCmd) then
			ViewManager.Instance:CloseViewByDef(ViewDef.ClientCmd)
		else
			ViewManager.Instance:OpenViewByDef(ViewDef.ClientCmd)
		end
	elseif compareKeys("gjl") then
		-- 增加攻击力
		self:AddPower()
	elseif compareKeys("ts") then
		-- 进入调试模式
		self:EnterDebug()
	elseif compareKeys("open") then
		ViewManager.Instance:OpenViewByDef(ViewDef.Equipment.Fusion)
	elseif compareKeys("zb") then
		self:EnterAddItem()
	else
		trigger = false
	end

	return trigger
end

function ReloadScriptManager:DoReloadScript()
	Language = nil
	ConfigManager.Instance.cfg_list = {}

	for _, filename in pairs(reload_file_list) do
		package.loaded[filename] = nil
		require(filename)
	end

	for _, filename in pairs(reload_ui_file_list) do
		package.loaded[filename] = nil
	end

	for k, v in pairs(ViewManager.Instance.view_list) do
		v.is_loaded_config = false
	end

	SysMsgCtrl.Instance:ErrorRemind("刷新客户端脚本成功", true)
end
--------------------------------------------
-- 普通键盘事件 end
--------------------------------------------

--------------------------------------------
-- Gm命令 begin
--------------------------------------------
function ReloadScriptManager:StartGm()
	self.gm_text_str = ""
	if nil == self.gm_text then
		self.gm_text = XUI.CreateLayout(3, 206, 450, 35)
		self.gm_text:setAnchorPoint(0, 0)
		HandleRenderUnit:AddUi(self.gm_text, COMMON_CONSTS.ZORDER_ERROR)
		-- local text = XUI.CreateText(5, 0, 500, 35, cc.TEXT_ALIGNMENT_LEFT, "", nil, 30, COLOR3B.GREEN)
		local text = XUI.CreateRichText(5, 0, 500, 35, true)
		text:setAnchorPoint(0, 0)
		self.gm_text:addChild(text)
		self.gm_text:setBackGroundColor(COLOR3B.BLACK)
		self.gm_text:setBackGroundColorOpacity(120)
		self.gm_text.deleteOneChar = function(s)
			local len = string.len(self.gm_text_str)
			if len > 0 and self.gm_text.pointer_pos > 1 then
				local lstr = string.sub(self.gm_text_str, 1, self.gm_text.pointer_pos)

				local rstr = (len - self.gm_text.pointer_pos > 0) and string.sub(self.gm_text_str, - (len - self.gm_text.pointer_pos)) or ""

				self.gm_text_str = string.sub(lstr, 1, string.len(lstr) - 1) .. rstr
				self.gm_text.pointer_pos = self.gm_text.pointer_pos - 1
			end
		end
		self.gm_text.addString = function(s, str)
			self.gm_text_str = self.gm_text_str
			local len = string.len(self.gm_text_str)
			local lstr = string.sub(self.gm_text_str, 1, s.pointer_pos)
			local rstr = ""
			if s.pointer_pos > len then
				s.pointer_pos = len
			end
			if len > s.pointer_pos then
				rstr = string.sub(self.gm_text_str, - (len - s.pointer_pos))
			end
			self.gm_text_str = lstr .. str .. rstr
			s.pointer_pos = s.pointer_pos + string.len(str)
		end
		self.gm_text.flushView = function(s)
			local str = self.gm_text_str
			text:removeAllElements()
			local len = string.len(str)
			local lstr = string.sub(str, 1, s.pointer_pos)
			local rstr = ""
			if s.pointer_pos > len then
				s.pointer_pos = len
			end
			if len > s.pointer_pos then
				rstr = string.sub(str, - (len - s.pointer_pos))
			end

			XUI.RichTextAddText(text, lstr, nil, 30, COLOR3B.GREEN)

			local pointer_node = cc.Node:create()
			pointer_node:setContentSize(cc.size(2, 25))
			-- local pointer_img = XUI.CreateImageView(5, 12.5, ResPath.GetCommon("line_103"))
			local pointer_img = XUI.CreateText(1, 23, 1, 25, nil, "|", nil, 42, COLOR3B.GREEN, nil)
			-- pointer_img:setColor(COLOR3B.GREEN)
			CommonAction.ShowRemindBlinkAction(pointer_img)
			pointer_node:addChild(pointer_img)
			XUI.RichTextAddElement(text, pointer_node)

			XUI.RichTextAddText(text, rstr, nil, 30, COLOR3B.GREEN)
		end
	end
	self.gm_text:setVisible(true)
	self.gm_text.pointer_pos = 0
	self.gm_text_str = ""
	self.gm_text:addString("@")
	-- self.gm_text:deleteOneChar()
	self.gm_text:flushView()

	self.cache_gm_str_index = 0
	if nil == self.cache_gm_text_str_t then
		self.cache_gm_text_str_t = {}
	end
end

function ReloadScriptManager:DoGmKey(key_code, event)
	if nil ~= self.gm_text and self.gm_text:isVisible() and event == cc.Handler.EVENT_KEYBOARD_PRESSED then

		-- a-z  0-9
		if (key_code >= cc.KeyCode.KEY_A and key_code <= cc.KeyCode.KEY_Z) or (key_code >= cc.KeyCode.KEY_0 and key_code <= cc.KeyCode.KEY_9) then
			self.gm_text:addString(string.lower(string.sub(cc.KeyCodeKey[key_code + 1], 5, 5)))

		-- "-"
		elseif key_code == cc.KeyCode.KEY_MINUS or key_code == cc.KeyCode.KEY_KP_MINUS then
			self.gm_text:addString("-")
		end

		-- 删除
		if key_code == cc.KeyCode.KEY_BACKSPACE then
			self.gm_text:deleteOneChar()
		end

		-- 空格
		if key_code == cc.KeyCode.KEY_SPACE then
			self.gm_text:addString(" ")
		end

		-- 关闭
		if key_code == cc.KeyCode.KEY_ESCAPE then
			self.gm_text:setVisible(false)
			self.gm_text_str = ""
		end

		-- 指针左移
		if key_code == cc.KeyCode.KEY_LEFT_ARROW then
			local pos = self.gm_text.pointer_pos - 1
			if pos >= 1 then
				self.gm_text.pointer_pos = pos
			end
		end

		-- 指针右移
		if key_code == cc.KeyCode.KEY_RIGHT_ARROW then
			local len = string.len(self.gm_text_str)
			local pos = self.gm_text.pointer_pos + 1
			if pos <= len then
				self.gm_text.pointer_pos = pos
			end
		end

		-- 指针上一个记录
		if key_code == cc.KeyCode.KEY_UP_ARROW then
			local index = self.cache_gm_str_index + 1
			local str = self.cache_gm_text_str_t[index]
			if str then
				self.gm_text_str = str
				self.gm_text.pointer_pos = string.len(self.gm_text_str)
				self.cache_gm_str_index = index
			end
		end

		-- 指针下一个记录
		if key_code == cc.KeyCode.KEY_DOWN_ARROW then
			self.cache_gm_str_index = self.cache_gm_str_index - 1
			if self.cache_gm_str_index < 1 then
				self.cache_gm_str_index = 0
			end

			self.gm_text_str = self.cache_gm_text_str_t[self.cache_gm_str_index] or "@"
			self.gm_text.pointer_pos = string.len(self.gm_text_str)
		end

		-- 执行
		if key_code == cc.KeyCode.KEY_KP_ENTER then
			for k, v in pairs(self:ParseClientGmCmmond(self.gm_text_str)) do
				ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, v)
			end
			self.cache_gm_str_index = 0
			if "" ~= self.gm_text_str and "@" ~= self.gm_text_str then
				table.insert(self.cache_gm_text_str_t, 1, self.gm_text_str)
			end
			self.gm_text:setVisible(false)
			self.gm_text_str = ""
		end

		self.gm_text:flushView()
	end
end

local gm_map = {
	["@max lv"] = "@level 150",
	["@max cl"] = "@circle 12",
	["@best equip"] = {
		{1499, 1559, 1560, 1911, 1912, 1913, 1913, 1914, 1914, 1915, 1916, },
		{1500, 1561, 1562, 1917, 1918, 1919, 1919, 1920, 1920, 1921, 1922, },
		{1501, 1563, 1564, 1923, 1924, 1925, 1925, 1926, 1926, 1927, 1928, },
	},
	["@need chs"] = {2129, 2130, 2131, 2132, 2133, 2134, 2134, 2135, 2135, 2136, 2137, },

}

function ReloadScriptManager:ParseClientGmCmmond(client_gm_commond)
	local raw_gm_commond = {}
	if string.match(client_gm_commond, "(additem %d+-%d+)") ~= nil then
		local min_id, max_id, num = string.match(client_gm_commond, "(%d+)-(%d+)%s*(%d+)")
		for id = min_id, max_id do
			local additem_gm = string.format( "@additem %d %d", id, num)
			table.insert(raw_gm_commond, additem_gm)
		end
	elseif gm_map[client_gm_commond] ~= nil then
		if client_gm_commond == "@max lv" then
			table.insert(raw_gm_commond, gm_map[client_gm_commond])
		elseif client_gm_commond == "@max cl" then
			table.insert(raw_gm_commond,  gm_map[client_gm_commond])
		elseif client_gm_commond == "@best equip" then
			local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
			for _, id in pairs(gm_map[client_gm_commond][prof] or {}) do
				table.insert(raw_gm_commond, string.format("@additem %d", id))
			end
		elseif client_gm_commond == "@need chs" then
			for _, id in pairs(gm_map[client_gm_commond] or {}) do
				table.insert(raw_gm_commond, string.format("@additem %d", id))
			end
		end
	else
		table.insert(raw_gm_commond, client_gm_commond)
	end
	return raw_gm_commond
end

--------------------------------------------
-- Gm命令 end
--------------------------------------------

--------------------------------------------
-- 主角攻击 begin
--------------------------------------------
function ReloadScriptManager:DoKeyAttack(mainui_skill_index)
	if false == MainuiCtrl.Instance.view:IsOpen() then
		return
	end
	
	local data = SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. mainui_skill_index])
	if data then
		local skill_id = data.id
		MainuiCtrl.Instance.view.skill_bar:OnUseSkill(skill_id)
		-- GlobalTimerQuest:AddDelayTimer(function()
		-- 	MainuiCtrl.Instance.view:GetSkillbar():OnUseSkill(skill_id)
		-- 	GlobalTimerQuest:AddDelayTimer(function()
		-- 		MainuiCtrl.Instance.view:GetSkillbar():OnUseSkill(skill_id)
		-- 	end, 0)
		-- end, 0)
	end
end
--------------------------------------------
-- 主角攻击 end
--------------------------------------------

--------------------------------------------
-- 主角移动 begin
--------------------------------------------
local NO_IDR = -1
local update_move_time = NOW_TIME
local cache_move_key_list = {}
function ReloadScriptManager:UpdateMainRoleMove()
	if 0.05 > (NOW_TIME - update_move_time) then
		return
	end
	update_move_time = NOW_TIME

	local current_dir = cache_move_key_list[1] or NO_IDR
	local last_dir = cache_move_key_list[2] or NO_IDR
	local dir = NO_IDR
	if (NO_IDR ~= current_dir and NO_IDR == last_dir) then
		dir = current_dir
	elseif (GameMath.DirUp == current_dir and GameMath.DirLeft == last_dir) or (GameMath.DirUp == last_dir and GameMath.DirLeft == current_dir) then
		dir = GameMath.DirUpLeft
	elseif (GameMath.DirUp == current_dir and GameMath.DirRight == last_dir) or (GameMath.DirUp == last_dir and GameMath.DirRight == current_dir) then
		dir = GameMath.DirUpRight
	elseif (GameMath.DirDown == current_dir and GameMath.DirLeft == last_dir) or (GameMath.DirDown == last_dir and GameMath.DirLeft == current_dir) then
		dir = GameMath.DirDownLeft
	elseif (GameMath.DirDown == current_dir and GameMath.DirRight == last_dir) or (GameMath.DirDown == last_dir and GameMath.DirRight == current_dir) then
		dir = GameMath.DirDownRight
	elseif NO_IDR ~= current_dir and NO_IDR ~= last_dir then
		dir = current_dir
	end

	local main_role = Scene.Instance:GetMainRole()
	if dir >= 0 then
		local step = self:IsHodeOnKey("KEY_ALT") and 1 or 2
		main_role:DoMoveByDir(dir, step)
	elseif GuajiCache.guaji_type ~= GuajiType.Auto and main_role.auto_type ~= AutoType.FindPath then
		-- main_role:StopMove()
	end
end

function ReloadScriptManager:DoKeyMove(keycode, event, key_dir)
	if cc.Handler.EVENT_KEYBOARD_PRESSED == event then	-- 按下
		table.insert(cache_move_key_list, 1, key_dir)
		GuajiCtrl.Instance:SetPlayerOptState(true)
	else				-- 松开
		for k, v in pairs(cache_move_key_list) do
			if key_dir == v then
				table.remove(cache_move_key_list, k)
				break
			end
		end

		-- 没有任何移动键被按下
		if nil == cache_move_key_list[1] then
			GuajiCtrl.Instance:SetPlayerOptState(false)
		end
	end
end
--------------------------------------------
-- 主角移动 end
--------------------------------------------
--------------------------------------------
-- 自动刷boss begin
--------------------------------------------

function ReloadScriptManager:OnObjAttrChange(obj, index, value)
	if self.auto_kill_boss then
		-- 记录已自动刷boss的boss名字
		if obj.IsBoss and obj:IsBoss() and OBJ_ATTR.CREATURE_HP == index and value <= 0 then
			local name = obj:GetName()
			local f = io.open(DESKTOP_PATH .. BOSS_FILE_NAME .. ".lua", "a")
			f:write(name .. "\n")
			f:close()
		end
	end
end

function ReloadScriptManager:SetIsAutoRecycleEquip(bool)
	self.auto_recycle_equip = bool
	if self.auto_recycle_equip then
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	else
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
	end
end

local recycle_t = {}
function ReloadScriptManager:ItemChange()
	if self.auto_recycle_equip then
		-- 拾取装备后回收装备，如果回收成功记录到文件中
		local item_list = BagData.Instance:GetItemDataList()
		for k, v in pairs(item_list) do
			if ItemData.GetIsEquip(v.item_id) then
				local item = TableCopy(v)
				if nil ~= recycle_t[item.item_id] then
					item.cfg_index = recycle_t[item.item_id]
				else
					for type, equip_list in pairs(BagData.Instance.NewEquipRecoveryCfg) do
						if nil ~= equip_list.equips[item.item_id] then
							item.cfg_index = type
							recycle_t[item.item_id] = type
							break
						end
					end
				end
				if nil ~= item.cfg_index then
					local beishu = 2 -- 回收倍数
					if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD) < 1000 then
						beishu = 1
					end
					BagCtrl.Instance:SendBagRecycleRewardReq(1, 1, beishu, {item})
					local f = io.open(DESKTOP_PATH .. GUAJI_ITEMS_FILE_NAME .. ".lua", "a")
					f:write(v.item_id .. "\n")
					f:close()
				end
			end
		end
	end
end

local boss_chat_str = {
	-- {str = "%s这个boss就让给你了，下次就没你份了！"},
	-- {str = "%s大哥，你怎么这么有空，天天中蹲点打boss吗？算了算了，让你"},
	-- {str = "%s加油吧，哥是有素质的男人，不抢boss"},
}
function ReloadScriptManager:SentBossIgonreChat(obj_ascription)
	local index = 1
	index = math.random(#boss_chat_str)
	if boss_chat_str[index] then
		local chat_str = string.format(boss_chat_str[index].str, obj_ascription)
		ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.NEAR, chat_str)
	end
end

--检测是否需要引导
-- guidectrl:CheckFuncGuide(FuncGuideTriggerType.AddTask, task_info)
local function get_task_step_cfg()
	local task_info = TaskData.Instance:GetMainTaskInfo()
	local trigger_type = FuncGuideType.OnClick
	for k, v in pairs(GuideData.Instance:GetGuideCfg()) do
		if v.trigger_type == trigger_type and v.trigger_param == task_info.task_id then
			last_guide_id = task_info.task_id
			return v.step_list
		end
	end
end

local is_guide = false
function ReloadScriptManager:AutoCheckItem()
	--背包多余熔炼
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) < 30 then return end
	local list = {}
	BagData.Instance:InitRecycleList()
	for k,v in pairs(BagData.Instance:GetRecycleList()) do
		if v.series then
			list[v.series] = true
		end
	end

	-- if next(list) then
	-- 	RecycleView.SendBagRecycleReq(list)
	-- end
end

function ReloadScriptManager:UpdateDoTask()
	if not self.is_auto_da_task then return end
	if FubenData.Instance:IsInFuben() then
		GuajiCtrl:SetGuajiType(GuajiType.Auto)
		return 
	end

	--跳过20级boss
	if Scene.Instance:GetSceneId() == 61 then
		FubenCtrl.OutFubenReq(1)
	end

	if is_guide then return end

	--检测物品相关
	self:AutoCheckItem()

	local task_info = TaskData.Instance:GetMainTaskInfo()
	local task_config = TaskConfig[task_info.task_id]
	local task_state = TaskData.Instance:GetTaskState(task_info)
	local command = task_config.touch_command[task_state] or task_config.touch_command[-1]
	if nil == command then
		Log(string.format("[MainuiTask]:无配置点击命令 任务id:%d", task_info.task_id))
		return
	end


	local ignore_view_link = param and param.ignore_view_link -- 忽略界面链接
	local ignore_submit_task = param and param.ignore_submit_task -- 忽略提交任务

	if get_task_step_cfg() then
		self:AutoDoGuide()
		is_guide = true
	end

	-- command.view_link and not ignore_view_link then
	if command.monster then
		MainuiTask.OnTaskMonster(task_info)
	elseif command.npc then
		MainuiTask.OnTaskTalkToNpc(task_info)
	elseif command.submit_task and not ignore_submit_task then
		TaskCtrl.SendCompleteTaskReq(task_info.task_id)
	elseif command.transfer then
		Scene.SendQuicklyTransportReqByNpcId(command.transfer)
	end
end

function ReloadScriptManager:AutoDoGuide()
	--更新引导面板
	local step_num = 0
	local cfg = get_task_step_cfg()

	local time = 2
	for i, step_cfg in ipairs(cfg) do
		time = time + 1
		GlobalTimerQuest:AddDelayTimer(function ()
			local node, is_next = ViewManager.Instance:GetUiNode(step_cfg.view_name, 
					step_cfg.node_name)

			--调用控件回调
			if step_cfg.node_name == "MainuiTaskBar" then
				MainuiTask.HandleTask(TaskData.Instance:GetMainTaskInfo())
			elseif step_cfg.node_name == "btn_close_window" then
				ViewManager.Instance:CloseAllView()
			else
				GlobalTimerQuest:AddDelayTimer(function ()
					if node and node.click_callback then
						node.click_callback()
					end
				end, 1)
			end
		end, time)
	end

	GlobalTimerQuest:AddDelayTimer(function ()
		is_guide = false
	end, time + 1)
end

function ReloadScriptManager:AutoDoTask()
	self.is_auto_da_task = true

	--自动操作面板
	function NpcDialogView:OpenCallBack()
		GlobalTimerQuest:AddDelayTimer(function()
			self:OnClickView()
			self:Close()
		end, 0.2)
	end
end

function ReloadScriptManager:PlayRecord()
	print("cd------------>PlayRecord",what) 
end

function ReloadScriptManager:AutoKillBoss(switch, skill_type)
	if nil ~= switch then
		self.auto_kill_boss = switch
	else
		self.auto_kill_boss = not self.auto_kill_boss
	end
	self.kill_boss_type = skill_type and skill_type or self.kill_boss_type

	Scene.Instance:GetMainRole():StopMove()
	self:CancelChuansongDelayTimer()
	-- ViewManager.Instance:FlushView(ViewName.ClientCmd)
	self.cur_wild_boss_t = {boss_id = 0, has_chuansong = 0, cfg = nil}

	if self.auto_kill_boss then
	end

	if 6 == self.kill_boss_type and self.auto_kill_boss then
		function NpcDialogView:OpenCallBack()
			GlobalTimerQuest:AddDelayTimer(function()
				self:OnClickView()
				self:Close()
			end, 0.2)
		end

		function GuideCtrl:OnAutoTask(now_time, elapse_time)
			if now_time >= self.last_task_update_time + 0.5 then
				-- if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) > GuideCtrl.AutoTaskLevel then
				-- 	self.is_auto_task = false
				-- 	return
				-- end

				self.last_task_update_time = now_time

				if self.guide_view:IsOpen() or not Scene.Instance:GetMainRole():IsStand() then
					return
				end

				if ViewManager.Instance:IsOpen(ViewName.NpcDialog) 
					or ViewManager.Instance:IsOpen(ViewName.SpecialNpcDialog)
					or ViewManager.Instance:IsOpen(ViewName.SpecialSpecialDialog)
					or ViewManager.Instance:IsOpen(ViewName.TransmitNpcDialog) then
					return
				end

				local task_info = TaskData.Instance:GetMainTaskInfo()
				if nil ~= task_info and not Scene.Instance:CanPickFallItem() then
					if task_info.target and task_info.target.target_type == TaskTarget.ActorLevel and task_info.target.cur_value < task_info.target.target_value then
						return
					end
					MainuiTaskItemReander.OnClickTask(task_info)
				end
			end
		end

		local npc_dialog_view = ViewManager.Instance:GetView(ViewName.NpcDialog)
		if npc_dialog_view and npc_dialog_view:IsOpen() then
			npc_dialog_view:OnClickView()
			npc_dialog_view:Close()
		end

		GuideCtrl.TaskGuideLevel = 150		-- 任务引导等级(自动继续下一步)
		GuideCtrl.AutoTaskLevel = 150		-- 自动任务等级(站着不动会自动做任务)
	else
		function NpcDialogView:OpenCallBack()
		end

		function GuideCtrl:OnAutoTask(now_time, elapse_time)
			if now_time >= self.last_task_update_time + 0.5 then
				if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) > GuideCtrl.AutoTaskLevel then
					self.is_auto_task = false
					return
				end

				self.last_task_update_time = now_time

				if self.guide_view:IsOpen() or not Scene.Instance:GetMainRole():IsStand() then
					return
				end

				if ViewManager.Instance:IsOpen(ViewName.NpcDialog) 
					or ViewManager.Instance:IsOpen(ViewName.SpecialNpcDialog)
					or ViewManager.Instance:IsOpen(ViewName.SpecialSpecialDialog)
					or ViewManager.Instance:IsOpen(ViewName.TransmitNpcDialog) then
					return
				end

				local task_info = TaskData.Instance:GetMainTaskInfo()
				if nil ~= task_info and not Scene.Instance:CanPickFallItem() then
					if task_info.target and task_info.target.target_type == TaskTarget.ActorLevel and task_info.target.cur_value < task_info.target.target_value then
						return
					end
					MainuiTaskItemReander.OnClickTask(task_info)
				end
			end
		end

		GuideCtrl.TaskGuideLevel = 75		-- 任务引导等级(自动继续下一步)
		GuideCtrl.AutoTaskLevel = 70		-- 自动任务等级(站着不动会自动做任务)
	end

	SysMsgCtrl.Instance:ErrorRemind("自动刷boss:" .. (self.auto_kill_boss and "开启" or "关闭"), true)
end

function ReloadScriptManager:CancelChuansongDelayTimer()
	if nil ~= self.chuansong_to_scene_timer then
		GlobalTimerQuest:CancelQuest(self.chuansong_to_scene_timer)
		self.chuansong_to_scene_timer = nil
	end
end

function ReloadScriptManager:SceneChange()
	self:CancelChuansongDelayTimer()

	local last_auto_kill_boss_type = AdapterToLua:getInstance():getDataCache("LAST_AUTO_KILL_BOSS_TYPE")
	if nil ~= last_auto_kill_boss_type and "" ~= last_auto_kill_boss_type then
		AdapterToLua:getInstance():setDataCache("LAST_AUTO_KILL_BOSS_TYPE", "")
		self:AutoKillBoss(true, tonumber(last_auto_kill_boss_type))
	end
end

-- 移动到某个点，并与最近的npc对话
function ReloadScriptManager:ActToNPC(act_t)
	local function Talk()
		local scene = Scene.Instance
		local target_obj = nil
		for _, v in pairs(scene:GetNpcList()) do
			local target_x, target_y = v:GetLogicPos()
			local distance = GameMath.GetDistance(act_t.x, act_t.y, target_x, target_y, false)
			if distance < 4 then
				if v:IsInBlock() then
					if nil == target_obj then
						target_obj = v
					end
				else
					target_obj = v
				end
			end
		end

		if nil ~= target_obj then
			for k, v in ipairs(act_t.talk_params) do
				TaskCtrl.SendNpcTalkReq(target_obj:GetObjId(), v)	
			end
		end
	end
	MoveCache.end_type = MoveEndType.OtherOpt
	MoveCache.param1 = Talk

	if nil == self.chuansong_to_scene_timer then
		self.chuansong_to_scene_timer = GlobalTimerQuest:AddDelayTimer(function()
			self:CancelChuansongDelayTimer()
			if 2 == act_t.scene_id and 2 ~= Scene.Instance:GetSceneId() and not Scene.Instance:CanPickFallItem() then
				Scene.SendQuicklyTransportReq(6)
			end
		end, 2)
	end

	GuajiCtrl.Instance:MoveToPos(act_t.scene_id, act_t.x, act_t.y, 0)
end

-- boos之家 刷boss引导信息
local boss_home_scene = {
	[56] = {scene_id = 2, x = 63, y = 52, talk_params = {"", "VipYuanBaoScene"}},
	[57] = {scene_id = 56, x = 106, y = 111, talk_params = {"", "VipYuanBaoScene"}},
	-- [58] = {scene_id = 57, x = 106, y = 111, talk_params = {"", "VipYuanBaoScene"}},
}
function ReloadScriptManager.IsBossHomeHaveBoss()
	for s_id, _ in pairs (boss_home_scene) do
		local refresh_boss_list = BossData.Instance:GetOneSceneBossList(s_id)
		for k, v in pairs(refresh_boss_list) do
			if nil == BossData.GetRefreshBossCfgByBossId(v) then
				refresh_boss_list[k] = nil
			end
		end
		if nil ~= next(refresh_boss_list) then
			return true
		end
	end
	return false
end

function ReloadScriptManager:OnDisconnectGameServer()
	if self.auto_kill_boss then
		AdapterToLua:getInstance():setDataCache("LAST_AUTO_KILL_BOSS_TYPE", self.kill_boss_type)
	end
end

function ReloadScriptManager:AutoSkyBoss()
	local num = BossData.Instance:GetSkyBossKillCount(self.have_sky_boss_id)
	if num > 10 then
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		BossCtrl.Instance:GetSkyBossKillCount(self.have_sky_boss_id)
	else
		self.have_sky_boss_id = 0
	end
end

function ReloadScriptManager:AutoAndianBoss()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local scene_id = Scene.Instance:GetSceneId()

	if nil == self.andian_scene_list then
		self.andian_scene_list = {}
		for k, v in pairs(ModBossConfig) do
			for _, v1 in pairs(v) do
				if BossData.IsValidBossType(ANDIAN_BOSS_TYPE, v1.type) then
					self.andian_scene_list[v1.SceneId] = 1
				end
			end
		end
	end

	if nil == self.andian_scene_list[scene_id] then
		self:ActToNPC({scene_id = 2, x = 58, y = 52, talk_params = {"", "BinYuanBaoScene"}})
	else
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	end
end

function ReloadScriptManager:AutoDoMainTask()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local scene_id = Scene.Instance:GetSceneId()

	local guide_ctrl = GuideCtrl.Instance
	if guide_ctrl.is_guideing then
		guide_ctrl.first_nil_time = 0
		guide_ctrl:EndGuide()
	end

	if guide_ctrl.foreshow_view and guide_ctrl.foreshow_view:IsOpen() then
		local foreshow_view_param = guide_ctrl.foreshow_view.cur_foreshow_obj.foreshow_view_param
		if foreshow_view_param.btn_func then
			foreshow_view_param.btn_func(guide_ctrl.foreshow_view)
		end
	end

	if guide_ctrl.story and guide_ctrl.story.is_storing then
		guide_ctrl.story:EndStory()
	end

	local scene_id = Scene.Instance:GetSceneId()
	local main_task = TaskData.Instance:GetMainTaskInfo()
	if scene_id == 68 or scene_id == 6 then
	elseif main_task and main_task.task_state == TaskState.Unacceptable then
		self:AutoChuMo()
	else
		if ViewManager.Instance:IsOpen(ViewName.SpecialNpcDialog) then
			ViewManager.Instance:Close(ViewName.SpecialNpcDialog)
		end

		if MoveCache.task_id and MoveCache.task_id > 0 then
			local protocol = ProtocolPool.Instance:GetProtocol(CSTaskTransmitReq)
			protocol.task_id = MoveCache.task_id
			protocol:EncodeAndSend()
			protocol.task_id = 0
		end
	end
end

function ReloadScriptManager:AutoCaiLiao()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local scene_id = Scene.Instance:GetSceneId()

	if Scene.Instance:GetSceneLogic():GetFubenType() > 0 then
		if FubenData.Instance.is_finish and not Scene.Instance:CanPickFallItem() then
			if not self.finish_cailiao_timer then
				self.finish_cailiao_timer = GlobalTimerQuest:AddDelayTimer(function()
					self.finish_cailiao_timer = nil
					if FubenData.Instance.is_finish and not Scene.Instance:CanPickFallItem() then
						FubenCtrl.RecMaterialFubenReward(2)					
					end
				end, 1.5)
			end
		else
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end
	else
		if not ViewManager.Instance:IsOpen(ViewName.FubenCL) then
			self:ActToNPC({scene_id = 2, x = 47, y = 65, talk_params = {""}})
		else
			local cl_view = ViewManager.Instance:GetView(ViewName.FubenCL)
			if cl_view.cailiao_fuben_list then
				local cl_data = cl_view.cailiao_fuben_list:GetData()
				for k, v in pairs(cl_data) do
					if v.time and tonumber(v.time) > 0 then
						local item_id = 678
						local bag_num = BagData.Instance:GetItemNumInBagById(item_id)
						if bag_num > 1 then
							-- FubenCLCtrl.Instance:EnterFubenReq(k)
						else
							ShopCtrl.BuyItemFromStore(40001, 1, item_id, 0)
						end
						break
					end
				end
			end
		end
	end
end

function ReloadScriptManager:AutoWildBoss()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local scene_id = Scene.Instance:GetSceneId()

	if nil == self.wild_boss_id or not BossData.Instance:GetBossIsRefresh(self.wild_boss_id) then
		self.wild_boss_id = nil
		local boss_list = BossData.Instance:GetSceneBossList(-1)
		for k, v in pairs(boss_list) do
			local cfg = BossData.GetRefreshBossCfgByBossId(v.boss_id)
			if cfg and role_circle >= cfg.circle and role_level >= cfg.level and cfg.NpcId == 0 and (v.refresh_time - (Status.NowTime - v.now_time)) <= 0
				and BossData.IsValidBossType(WILD_BOSS_TYPE, v.boss_type) then
				self.wild_boss_id = v.boss_id
			end
		end
	end

	if nil ~= self.wild_boss_id then
		if self.cur_wild_boss_t.boss_id ~= self.wild_boss_id then
			self.cur_wild_boss_t.boss_id = self.wild_boss_id
			self.cur_wild_boss_t.has_chuansong = 0
			self.cur_wild_boss_t.cfg = BossData.GetRefreshBossCfgByBossId(self.wild_boss_id)
		end
		
		if not (scene_id == self.cur_wild_boss_t.cfg.SceneId or scene_id == self.cur_wild_boss_t.cfg.TeleportSceneId) then
			if not Scene.Instance:CanPickFallItem() and nil == self.chuansong_to_scene_timer then
				self.chuansong_to_scene_timer = GlobalTimerQuest:AddDelayTimer(function()
					self:CancelChuansongDelayTimer()
					if not Scene.Instance:CanPickFallItem() then
						BossCtrl.CSChuanSongBossScene(self.cur_wild_boss_t.cfg.type, self.wild_boss_id)
						self.cur_wild_boss_t.has_chuansong = 1
					end
				end, 2)
			end
		end

		if not Scene.Instance:CanPickFallItem() and scene_id ~= self.cur_wild_boss_t.cfg.SceneId then
			local x, y = MapData.GetMapBossPos(self.cur_wild_boss_t.cfg.SceneId, self.wild_boss_id)
			MoveCache.param1 = self.wild_boss_id
			MoveCache.end_type = MoveEndType.FightByMonsterId
			GuajiCtrl.Instance:MoveToPos(self.cur_wild_boss_t.cfg.SceneId, x, y, 1)
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		else
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end
	else
		-- 野外boss已刷完 刷boss之家
		self:AutoKillBoss(true, 1)
	end
end

function ReloadScriptManager:AutoPersonalBoss()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local scene_id = Scene.Instance:GetSceneId()

	if nil == self.personal_fuben_id then
		local boss_list = BossData.Instance:GetPersonalBossList()
		local fuben_list = FubenData.Instance:GetFubenEnterInfo()
		local now_time = TimeCtrl.Instance:GetServerTime()
		for k, v in pairs(boss_list) do
			local is_enough = BossData.Instance:PerBossIsEnoughAndTip(v)
			local enter_time = fuben_list[v.index] and fuben_list[v.index].enter_time or 0
			local time = enter_time + COMMON_CONSTS.SERVER_TIME_OFFSET + v.interval - now_time
			if time <= 0 and is_enough then
				self.personal_fuben_id = v.fubenId
			end
		end
	end

	if Scene.Instance:GetSceneLogic():GetFubenType() > 0 then
		if FubenData.Instance.is_finish and not Scene.Instance:CanPickFallItem() then
			if not self.finish_personal_timer then
				self.finish_personal_timer = GlobalTimerQuest:AddDelayTimer(function()
					self.finish_personal_timer = nil
					if FubenData.Instance.is_finish and not Scene.Instance:CanPickFallItem() then
						FubenCtrl.RecFubenReward(1)					
					end
				end, 1.5)
			end
		else
			GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		end
	else 
		if self.personal_fuben_id then
			local item_id = 678
			local bag_num = BagData.Instance:GetItemNumInBagById(item_id)
			if bag_num > 3 then
				FubenCtrl.EnterFubenReq(self.personal_fuben_id)
				self.personal_fuben_id = nil
			else
				ShopCtrl.BuyItemFromStore(40001, 1, item_id, 0)
			end
		else 
			self:AutoKillBoss(false)
			Scene.SendQuicklyTransportReq(6)
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
			return
		end
	end
end

function ReloadScriptManager:AutoBossHome()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local scene_id = Scene.Instance:GetSceneId()

	if nil == boss_home_scene[scene_id] and self.IsBossHomeHaveBoss() then
		local act_t = boss_home_scene[56]
		self:ActToNPC(act_t)
	------------------------------------------------
	-- 自动刷下一层的boss start
	elseif Scene.Instance:GetMinDisBoss() <= 0 and not Scene.Instance:CanPickFallItem() then
		local act_t = boss_home_scene[scene_id + 1]
		if nil == act_t then
			if self.IsBossHomeHaveBoss() then
				-- 其它boss之家层有boss已刷新，原路返回去刷
				self:ActToNPC(boss_home_scene[56])
			else
				-- 所有boss之家boss已刷完，刷野外boss
				if nil == self.chuansong_to_scene_timer then
					self.chuansong_to_scene_timer = GlobalTimerQuest:AddDelayTimer(function()
						self:CancelChuansongDelayTimer()
						if not Scene.Instance:CanPickFallItem() then
							Scene.SendQuicklyTransportReq(6)
							self:AutoKillBoss(true, 2)
						end
					end, 0)
				end
			end
		else
			self:ActToNPC(act_t)
		end
	-- 自动刷下一层的boss end
	------------------------------------------------
	else
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
		-- self:AddPower()
	end
end

function ReloadScriptManager:AutoChuMo()
	local task = TaskData.Instance:GetTaskByTaskId(DailyTaskType.TYPE_XYCM)
	local acc_task = TaskData.Instance:GetAcceptTaskList()[DailyTaskType.TYPE_XYCM]
	if task then
		if task.targets[1].cur_value == task.targets[1].target_value then
			-- 除魔任务完成 去领取3倍奖励
			self:ActToNPC({scene_id = 2, x = 43, y = 86, talk_params = {"", "WanChengRw100,3,0"}})
		else
			if task.target and task.target.scene_id ~= Scene.Instance:GetSceneId() then
				GuajiCtrl.Instance:MoveToPos(task.target.scene_id, task.target.x, task.target.y, 1)
			else
				GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
			end
		end
	end
	if acc_task then
		local npc_dialog_view = ViewManager.Instance:GetView(ViewName.SpecialNpcDialog)
		if npc_dialog_view and npc_dialog_view:IsOpen() then
			if npc_dialog_view.btn_list and #npc_dialog_view.btn_list == 3 then
				self:AutoKillBoss(false)
				Scene.SendQuicklyTransportReq(6)
				GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
				return
			end
		end

		-- 可接收除魔 先刷新10次星级再接受任务
		local talk_params = {""}
		for i = 1, 10 do
			table.insert(talk_params, "ShuaXinRW")
		end
		table.insert(talk_params, "JieShouRW")
		self:ActToNPC({scene_id = 2, x = 43, y = 86, talk_params = talk_params})
	end
end

-- 统计BOSS数量
function ReloadScriptManager:ParseBossByBossNameFile()
	local boss_f = DESKTOP_PATH .. BOSS_FILE_NAME .. ".lua"
	local f = io.open(boss_f, "r")
	if nil == f then
		SysMsgCtrl.Instance:ErrorRemind(boss_f .. " 未找到", true)
		return
	end
	local file_str = f:read("*all")
	f:close()

	local boss_t = Split(file_str, "\n")
	local boss_l = {}
	for k, v in pairs(boss_t) do
		if nil == boss_l[v] then
			boss_l[v] = 1
		else
			boss_l[v] = boss_l[v] + 1
		end
	end

	f = io.open(DESKTOP_PATH .. PARSE_BOSS_FILE_NAME .. ".lua", "w")
	if nil == f then
		SysMsgCtrl.Instance:ErrorRemind("未知错误，解析物品失败", true)
		return
	end

	f:write(string.format("\n	共解析%d个BOSS，有%d个错误\n", #boss_t, 0))
	for name, num in pairs(boss_l) do
		local str = string.format("\n	%s：%d", name, num)
		f:write(str .. "\n")
	end

	f:close()
	SysMsgCtrl.Instance:ErrorRemind("解析BOSS成功", true)
end


-- 统计装备数量
function ReloadScriptManager:ParseItemByitemIdFile()
	local open_f = DESKTOP_PATH .. GUAJI_ITEMS_FILE_NAME .. ".lua"
	local f = io.open(open_f, "r")
	if nil == f then
		SysMsgCtrl.Instance:ErrorRemind(open_f .. " 未找到", true)
		return
	end
	local file_str = f:read("*all")
	f:close()
	local items = Split(file_str, "\n")
	for k, v in pairs(items) do
		items[k] = tonumber(v)
		ItemData.Instance:GetItemConfig(items[k])
	end

	SysMsgCtrl.Instance:ErrorRemind("开始解析物品", true)
	GlobalTimerQuest:AddDelayTimer(function()
		self:WirteItemsInfo(items)
	end, 5)
end

function ReloadScriptManager:WirteItemsInfo(items)
	local error_num = 0
	local item_info = {}
	for k, v in pairs(items) do
		local cfg = ItemData.Instance:GetItemConfig(v)
		if cfg then
			local level, zhuan = ItemData.GetItemLevel(v)
			if nil == item_info[zhuan] then
				item_info[zhuan] = {}
			end
			if nil == item_info[zhuan][level] then
				item_info[zhuan][level] = 0
			end
			item_info[zhuan][level] = item_info[zhuan][level] + 1
		else
			error_num = error_num + 1
		end
	end

	local f = io.open(DESKTOP_PATH .. PARSE_ITEM_FILE_NAME .. ".lua", "w")
	if nil == f then
		SysMsgCtrl.Instance:ErrorRemind("未知错误，解析物品失败", true)
		return
	end

	f:write(string.format("\n	共解析%d件装备，有%d个错误\n", #items, error_num))
	for zhuan, v in pairs(item_info) do
		for level, num in pairs(v) do
			local str = string.format("\n	%d转%d级装备：%d件", zhuan, level, num)
			f:write(str .. "\n")
		end
	end

	f:close()
	SysMsgCtrl.Instance:ErrorRemind("解析物品成功", true)
end
--------------------------------------------
-- 自动刷boss end
--------------------------------------------

--------------------------------------------
-- 剧情 being
--------------------------------------------
-- 生成测试剧情配置
function ReloadScriptManager:CreateTestStoryRealCfg()
	local f = io.open("C:/Users/Administrator/Desktop/story_list.lua", "w")

	for _, story_cfg in pairs(Story.Instance.story_list) do
		local filename = story_cfg.cfg_filename
		if nil ~= filename then
			f:write(filename .. " = \n[[\n")
			for k, v in ipairs(story_cfg.show_list) do
				local str = v.next_time .. "::" .. v.actor .. ":" .. v.action .. "::"
				if k > 1 then
					str = "," .. str
				end
				str = string.gsub(str, "\n", "\\n")
				f:write(str)
			end
			f:write("\n]]\n\n")
			SysMsgCtrl.Instance:ErrorRemind("生成测试剧情配置:" .. filename, true)
		end
	end

	f:close()
end

-- 解析剧情配置
function ReloadScriptManager:ParseStoryRealCfg()
	local f = io.open("C:/Users/Administrator/Desktop/story_list.lua", "r")
	if nil == f then
		SysMsgCtrl.Instance:ErrorRemind("请将要解析的剧情配置存放在\"C:/Users/Administrator/Desktop/\"目录下，并命名为\"story_list.lua\"", true)
		return
	end
	local all_s = f:read("*a")

	local list = Split(all_s, ",")
	local f = io.open("C:/Users/Administrator/Desktop/parse_story_cfg.lua", "w")
	f:write("return {")
	local str
	for k, v in ipairs(list) do
		local next_time, actor, action = string.match(v, "(.-)::(.-):(.-)::")
		if nil ~= next_time then
			str = "\n	{next_time = " .. next_time .. ", actor = \"" .. actor .. "\", action = \"" .. action .. "\"},"
			f:write(str)
		end
	end
	f:write("\n}")
	f:close()

	SysMsgCtrl.Instance:ErrorRemind("解析剧情配置成功", true)
end

-- 加载测试剧情配置
local story_list_cfg = {
    {
        id = 1,
        trigger_type = 1,			--1接任务 2完成任务 3交任务 4升级 5进入场景 6开场 7剧情结束
        trigger_param = 9999,
        show_list = {},
        story_type = 1,				--1大剧情 2小剧情
        cfg_filename = "story_2",
        -- cfg_filename = "story",
    },
    {
        id = 2,
        trigger_type = 7,
        trigger_param = 1,
        show_list = {},
        story_type = 2,
        -- cfg_filename = "city 2",
    },
    {
        id = 3,
        trigger_type = 7,
        trigger_param = 2,
        show_list = {},
        story_type = 2,
        -- cfg_filename = "city 2",
    },
}
function ReloadScriptManager:LoadTestStoryCfg()
	local story_list = {}
	for k, v in pairs(story_list_cfg) do
		if nil ~= v.cfg_filename and "" ~= v.cfg_filename then
			local t = nil
			local test_story_cfg_path = "scripts/game/clientcmd/test_story_cfgs/" .. v.cfg_filename
			if cc.FileUtils:getInstance():isFileExist(test_story_cfg_path .. ".lua") then
				package.loaded[test_story_cfg_path] = nil
				t = require(test_story_cfg_path)
			end

			if nil == t then
				SysMsgCtrl.Instance:ErrorRemind("无法找到测试剧情配置:" .. v.cfg_filename, true)
			else
				for k1, v1 in ipairs(t) do
				    v1.show_id = k1
				    v1.unuseful = ""
				    v1.audio = ""
				    v1.next_show = ""
				end

				v.show_list = t
				story_list[#story_list + 1] = TableCopy(v)
				SysMsgCtrl.Instance:ErrorRemind("已加载测试剧情配置:" .. v.cfg_filename, true)
			end
		end
	end

	if nil ~= next(story_list) then
		Story.Instance.story_list = story_list
	end
end

-- 开始测试剧情
function ReloadScriptManager:StartTestStory()
	local t = Story.Instance
	t.story_played_list = {}
	t:OnOneTaskDataChange("add", 9999)

	SysMsgCtrl.Instance:ErrorRemind("开始测试剧情", true)
end
--------------------------------------------
-- 剧情 end
--------------------------------------------

--------------------------------------------
-- 辅助点 end
--------------------------------------------
function ReloadScriptManager:AddRect()
	if self.point_list[1] and self.point_list[2] then
		local x1, y1 = self.point_list[1].move_mark:getPosition()
		local x2, y2 = self.point_list[2].move_mark:getPosition()
		local x, y = 0, 0
		local w, h = 0, 0

		if 0 == (x1 - x2) and 0 == (y1 - y2) then
			return
		end

		if x1 >= x2 and y1 >= y2 then
			x, y = (x1 + x2) / 2, (y1 + y2) / 2
			w, h = (x1 - x2) / 1, (y1 - y2) / 1
		else
			x, y = (x2 + x1) / 2, (y2 + y1) / 2
			w, h = (x2 - x1) / 1, (y2 - y1) / 1
		end

		local rect = XUI.CreateLayout(x, y, w, h)
		HandleRenderUnit:AddUi(rect, COMMON_CONSTS.ZORDER_MAX)
		rect:setBackGroundColor(COLOR3B.BLUE)
		rect:setBackGroundColorOpacity(100)
		rect:setTouchEnabled(true)
		local pos_info_text = XUI.CreateText(w / 2, h / 2, 400, 20, nil, "", nil, 20, COLOR3B.RED)
		pos_info_text:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		rect:addChild(pos_info_text)
		local rect_obj = {rect = rect, pos_info_text = pos_info_text}
		rect:addTouchEventListener(BindTool.Bind(self.TouchRectEventCallback, self, rect_obj))
		table.insert(self.rect_list, rect_obj)
		self:UpdateRectInfo(rect_obj)
	end
end

function ReloadScriptManager:AddPoint()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local point_root = XUI.CreateLayout(screen_w / 2, screen_h / 2, screen_w, screen_h)
	local move_mark = XUI.CreateLayout(screen_w / 2, screen_h / 2, 12, 12)
	move_mark:setBackGroundColor(COLOR3B.RED)
	move_mark:setBackGroundColorOpacity(200)
	local mark_pos_text = XUI.CreateText(62, 22, 200, 20, nil, "", nil, 20, COLOR3B.RED)
	mark_pos_text:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	move_mark:addChild(mark_pos_text)
	local row_line = XUI.CreateLayout(screen_w / 2, screen_h / 2, screen_w, 3)
	row_line:setBackGroundColor(COLOR3B.GREEN)
	row_line:setBackGroundColorOpacity(150)
	local column_line = XUI.CreateLayout(screen_w / 2, screen_h / 2, 3, screen_h)
	column_line:setBackGroundColor(COLOR3B.GREEN)
	column_line:setBackGroundColorOpacity(150)
	HandleRenderUnit:AddUi(point_root, COMMON_CONSTS.ZORDER_MAX)
	point_root:addChild(row_line)
	point_root:addChild(column_line)
	point_root:addChild(move_mark)
	move_mark:setTouchEnabled(true)
	local point_obj = {point_root = point_root, move_mark = move_mark, mark_pos_text = mark_pos_text, row_line = row_line, column_line = column_line}
	move_mark:addTouchEventListener(BindTool.Bind(self.TouchEventCallback, self, point_obj))
	table.insert(self.point_list, point_obj)
	self:UpdateLineMarkPos(point_obj)
end

function ReloadScriptManager:ClearAllPoint()
	for k, v in pairs(self.point_list) do
		v.point_root:removeFromParent()
	end
	self.point_list = {}
end

function ReloadScriptManager:ClearAllRect()
	for k, v in pairs(self.rect_list) do
		v.rect:removeFromParent()
	end
	self.rect_list = {}
end

function ReloadScriptManager:UpdateLineMarkPos(point_obj)
	if nil == point_obj then
		for k, v in pairs(self.point_list) do
			self:UpdateLineMarkPos(v)
		end
		return
	end

	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local x, y = point_obj.move_mark:getPosition()
	x = x - screen_w / 2
	y = y - screen_h / 2
	point_obj.mark_pos_text:setString(string.format("(%d , %d)", x, y))
end

function ReloadScriptManager:TouchEventCallback(point_obj, sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
	elseif event_type == XuiTouchEventType.Moved then
		local p = touch:getLocation()
		point_obj.move_mark:setPosition(p.x, p.y)
		point_obj.column_line:setPositionX(p.x)
		point_obj.row_line:setPositionY(p.y)
		self:UpdateLineMarkPos(point_obj)
	elseif event_type == XuiTouchEventType.Ended then
	end
end

function ReloadScriptManager:TouchRectEventCallback(rect_obj, sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
	elseif event_type == XuiTouchEventType.Moved then
		local p = touch:getLocation()
		rect_obj.rect:setPosition(p.x, p.y)
		self:UpdateRectInfo(rect_obj)
	elseif event_type == XuiTouchEventType.Ended then
	end
end

function ReloadScriptManager:UpdateRectInfo(rect_obj)
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local x, y = rect_obj.rect:getPosition()
	local size = rect_obj.rect:getContentSize()
	x = x - screen_w / 2
	y = y - screen_h / 2
	rect_obj.pos_info_text:setString(string.format("(x=%d , y=%d, w=%d, h=%d)", x, y, size.width, size.height))
end
--------------------------------------------
-- 辅助点 end
--------------------------------------------
--------------------------------------------
-- 触摸事件 end
--------------------------------------------
function ReloadScriptManager:ChangeDesignState()
	if nil == self.design_layout then
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()
		self.design_layout = XUI.CreateLayout(screen_w / 2, screen_h / 2, screen_w, screen_h)
		self.design_layout:setBackGroundColorOpacity(10)
		self.design_layout:setBackGroundColor(COLOR3B.BLUE)
		HandleRenderUnit:AddUi(self.design_layout, COMMON_CONSTS.ZORDER_ERROR)
		self.design_layout:setTouchEnabled(true)
		self.design_layout:addTouchEventListener(BindTool.Bind(self.DesignTouchEvent, self))
		self.design_layout:setVisible(false)
	end
	self.design_layout:setVisible(not self.design_layout:isVisible())
end

function ReloadScriptManager:SetNodeVisible()
	if nil ~= self.select_node and self.select_node.setVisible then
		self.select_node:setVisible(not self.select_node:isVisible())
	end
end

function ReloadScriptManager:OpenQuickView()
	local view_name
	local view_index
	local f = io.open("files/temp/quick_open_view.lua", "r")
	if nil ~= f then
		f:close()
		package.loaded["files/temp/quick_open_view"] = nil
		local data = require("files/temp/quick_open_view")
		for k, v in pairs(data) do
			ViewManager.Instance:OpenViewByKeyT(v)
		end
	end
end

function ReloadScriptManager:SetViewMarkData()
	local view_list = {}
	local function walk(def)
		if nil == ViewManager.Instance:GetView(def) or not ViewManager.Instance:IsOpen(def) then
			return
		end

		view_list[def.view_key_t[1]] = def.view_key_t

		for k, v in pairs(def.child_group) do
			walk(v)
		end
	end
	for k, v in pairs(ViewDef) do
		walk(v)
	end

	view_list["MainUi"] = nil
	local str = ""
	for k, v in pairs(view_list) do
		str = str .. string.format("%s = {\"%s\"},", k, table.concat(v, "\",\""))
	end
	str = string.format("return {%s}", str)
	SysMsgCtrl.Instance:ErrorRemind(string.format("设置快速打开界面为:\n%s", ChatData.Instance:FormattingMsg(str)), true)
	local f = io.open("files/temp/quick_open_view.lua", "w")
	f:write(str)
	f:close()
end

function ReloadScriptManager:DesignTouchBegan(sender, event_type, touch)
	self.is_start = false
	self.began_time = Status.NowTime
	self.began_point = touch:getLocation()

	self.ignore_view = {
		["MainUi"] = 1,
		["ActOpenRemind"] = 1,
	}
	local open_view_t = {}
	for k, v in pairs(ViewManager.Instance.view_list) do
		if v:IsOpen() then
			local show_index = v:GetShowIndex()
			local view_name = v:GetViewName()
			local index_name = ""
			local view_prefix = string.lower(view_name) .. "_"
			for k, v in pairs(TabIndex) do
				if v == show_index and string.find(k, view_prefix) then
					index_name = k
				end
			end

			if nil == self.ignore_view[view_name] then
				open_view_t[#open_view_t + 1] = {view = v, view_name = view_name, index_name = index_name, show_index = show_index}
			end
			-- print(string.format("--->>>view_name:%s  index_name:%s", view_name, index_name))
		end
	end

	self.select_node = nil

	local select_type = {
		["XImage"] = true,
		["XButton"] = true,
		["XText"] = true,
		["XRichText"] = true,
		["XLoadingBar"] = true,
		["XScale9Sprite"] = true,
		["XWidget"] = true,
	}
	local search_type = {
		["XLayout"] = true,
		["XListView"] = true,
		["XSrollView"] = true,
		["XPageView"] = true,
	}
	local show_name_type = {
		["XButton"] = true,
		["XLayout"] = true,
		["XRichText"] = true,
		["XText"] = true,
	}
	local layout_type = {
		["XLayout"] = true,
		["XListView"] = true,
		["XSrollView"] = true,
		["XPageView"] = true,
	}
	local text_type = {
		["XRichText"] = true,
		["XText"] = true,
	}
	local function show_node(t, name)
		name = name or ""
		for k, v in pairs(t) do
			if k == "node" and nil == v.client_name and show_name_type[v:getDescription()] then
				local w, h = 0, 0
				if v.getContentSize and v.getDescription and v.getPosition then
					w = v:getContentSize().width
					h = v:getContentSize().height
				end
				local text = XUI.CreateText(w / 2, h, 500, 35, cc.TEXT_ALIGNMENT_CENTER, name, nil, 19, COLOR3B.GREEN)
				v:addChild(text, 999)
				v.client_name = text
			end

			if "table" == type(v) then
				show_node(v, k)
			end
		end
	end
	local function can_select(node)
		local select_t = self:IsHodeOnKey("KEY_ALT") and layout_type or select_type
		return (nil == node.isFamilyVisible or node:isFamilyVisible()) and select_t[node:getDescription()]
	end
	local function get_node(root_node)
		local child_list = root_node:getChildren()
		for k, v in ipairs(child_list) do
			local w, h = 0, 0
			if v.getContentSize and v.getDescription and v.getPosition then
				w = v:getContentSize().width
				h = v:getContentSize().height
				if can_select(v) then
					local p = v:convertToNodeSpace(self.began_point)
					if p.x >= 0 and p.y >= 0 and p.x <= w and p.y <= h then
						self.select_node = v
						v.getNodeName = function() return "name" end
					end

					if text_type[v:getDescription()] and nil == v.wh_frame_node then
						v.wh_frame_node = XUI.CreateLayout(w / 2, h / 2, w, h)
						v.wh_frame_node:setBackGroundColor(COLOR3B.GREEN)
						v.wh_frame_node:setBackGroundColorOpacity(30)
						v:addChild(v.wh_frame_node)
					end
				end
			end

			if search_type[v:getDescription()] then
				get_node(v)
			end
		end
	end

	for k, v in ipairs(open_view_t) do
		local node_tree = v.view.node_tree
		show_node(node_tree)
		get_node(v.view.root_node)
	end

	if nil ~= self.select_node then
		print("HAO--->>>self.select_node", self.select_node:getDescription())
		self.node_began_x, self.node_began_y = self.select_node:getPosition()
	end
end

function ReloadScriptManager:DesignTouchEvent(sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		self:DesignTouchBegan(sender, event_type, touch)
	elseif event_type == XuiTouchEventType.Moved then
		if nil ~= self.select_node then
			local p = touch:getLocation()
			local offset_x = p.x - self.began_point.x
			local offset_y = p.y - self.began_point.y
			self.select_node:setPosition(self.node_began_x + offset_x, self.node_began_y + offset_y)

			local w, h = 0, 0
			if self.select_node.getContentSize then
				w, h = self.select_node:getContentSize().width, self.select_node:getContentSize().height
			end
			if nil == self.select_node.xywh_text then
				self.select_node.xywh_text = XUI.CreateText(w / 2, h / 2, 500, 35, cc.TEXT_ALIGNMENT_CENTER, "", nil, 19, COLOR3B.RED)
				self.select_node:addChild(self.select_node.xywh_text, 999)
			end
			self.select_node.xywh_text:setString(string.format("x:%d y:%d w:%d h:%d", self.node_began_x + offset_x, self.node_began_y + offset_y, w, h))
		end
	elseif event_type == XuiTouchEventType.Ended then
	end	
end
--------------------------------------------
-- 触摸事件 end
--------------------------------------------

-- 获取win上剪贴板内容
function ReloadScriptManager:GetSysClipContent()
	local bat_name = "cqgame_get_clip.bat"
	local exec_str = [[
	@echo off
	setlocal enabledelayedexpansion
	set ms=mshta vbscript:CreateObject("Scripting.FileSystemObject").GetStandardStream(1).Write(clipboardData.getData("text"))(close)
	for /f "delims=" %%i in ('!ms!') do (
	  set a=%%i
	  echo !a!
	)
	]]
	local wr_f = io.open(bat_name, "w")
	if wr_f then
		wr_f:write(exec_str)
		wr_f:close()
	end
	local get_clip = io.popen(bat_name, "r")
	local clip_content = ""
	if get_clip then
		clip_content = get_clip:read("*all")
		get_clip:close()
	end
	os.remove(bat_name)
	return clip_content
end

-- 增加攻击力
function ReloadScriptManager:AddPower()
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local gm_str = string.format("@intpro %d %d", 14 + 2 * (prof - 1), 22222222222)
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, gm_str)
	SysMsgCtrl.Instance:ErrorRemind(gm_str, true)
end

-- 进入调试模式
function ReloadScriptManager:EnterDebug()
	local gm_str
	if self.ts == nil then
		
		-- 控制台输出
		function RichTextUtil.ParsePirnt(rich_text, params, font_size, color, ignored_link, text_attr)
			local f = loadstring(string.format("Print('%s = ', %s)", params[2], params[2]))
			if f == nil then Log("输出参数错误或不存在", params[2]) return end
			f()
		end
		RichTextUtil.parse_func_list["p"] = RichTextUtil.ParsePirnt

		-- 替换"FormattingMsg"方法
		function ChatData.Instance:FormattingMsg(msg, content_type)
			if content_type == CHAT_CONTENT_TYPE.AUDIO then
				return msg
			end
			local str = self:CheckFaceAndItem(msg)
			return str
		end

		-- 替换"LogT"方法
		function LogT(...)
			print(...)
		end
		
		self.ts = true
		gm_str = "成功进入调试模式"
	else 
		gm_str = "已关闭接口打印"

		-- 替换"LogT"方法
		function LogT(...)
			-- print(...)
		end
	end
	 
	SysMsgCtrl.Instance:ErrorRemind(gm_str, true)
end

function ReloadScriptManager:EnterAddItem()
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@addmoney 1 100000000") -- 1亿金币
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@paymoney 100000000") -- 充值1亿元宝
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@circle 16 2000") -- 16转 2000级
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 693-698 1") -- 装备
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 695-696 1")
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 595 1")
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 596 1")
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 562 1")
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 440 10") -- 镶嵌宝石
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 425 10")
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 410 10")
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 395 10")
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 380 10")
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 365 10")
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 323 9999") -- vip经验卡
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1479 999") -- 守护神装兑换卷
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1063 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1078 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1093 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1108 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1123 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1138 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1153 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1168 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1183 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1198 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1213 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1228 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1243 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1258 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1273 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1288 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1303 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1318 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1333 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1348 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1363 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1378 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1393 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1408 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1423 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1438 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1453 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1468 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1453 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1468 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1498 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1513 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1528 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1543 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1558 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1573 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 1588 1") -- 守护神装15阶
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 244-252 1") -- 
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 311-313 1") -- 
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 25 999") -- 超级转生丹
	ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@additem 305 1") -- 
end

-- 配置连接外网环境,会自动修改客户端连接配置
function ReloadScriptManager:SetClientEnvironment(spid)
	if nil ~= self.spid_restart_timer then
		return
	end
	spid = spid or "dev"
	local path = "../assets/scripts/agent/dev/agent_adapter2.lua"
	local f = assert(io.open(path, "r"))
	local f_str = f:read("*a")
	f_str = string.gsub(f_str, "function AgentAdapter:GetSpid%(%)(.-)end", "function AgentAdapter:GetSpid%(%)\n	return \"" .. spid .. "\"\nend")
	f_str = string.gsub(f_str, "function AgentAdapter:GetPlatName%(%)(.-)end", "function AgentAdapter:GetPlatName%(%)\n	return GameVoManager.Instance:GetUserVo().plat_name\nend")
	-- f = assert(io.open("C:/Users/Administrator/Desktop/agent_adapter2.lua", "w"))
	f = assert(io.open(path, "w"))
	f:write(f_str)

	path = "../assets/scripts/platform/windows/platform_adapter.lua"
	f = assert(io.open(path, "r"))
	f_str = f:read("*a")

	local init_url = "l.cqtest.jianguogame.com:88"
	if "att" == spid
		or "at1" == spid
		then
		init_url = "l.cqtest.jianguogame.com:88"
	end
	f_str = string.gsub(f_str, "pkg_info = self:GetPackageInfo%(%)(.-)}", "pkg_info = self:GetPackageInfo()\n	return {\n		init_url = \"http://" .. init_url .. "/" .. spid .. "/query.php\"\n	}")
	f = assert(io.open(path, "w"))
	f:write(f_str)

	path = "../assets/scripts/preload/init_query.lua"
	f = assert(io.open(path, "r"))
	f_str = f:read("*a")
	f_str, num = string.gsub(f_str, "server,\n			(.-)GLOBAL_CONFIG.package_info.version", "server,\n			\"" .. spid .. "\",\n			GLOBAL_CONFIG.package_info.version")
	-- f_str, num = string.gsub(f_str, "MainLoader:PushTask%(updater%)", "MainLoader:PushTask(require(\"scripts/preload/load_script\"))")
	f = assert(io.open(path, "w"))
	f:write(f_str)

	path = "../assets/scripts/agent/dev/agent_login_view.lua"
	f = assert(io.open(path, "r"))
	f_str = f:read("*a")
	f_str, num = string.gsub(f_str, "if len <= 0 or len > 20 then", "if len <= 0 or len > 1000 then")
	f = assert(io.open(path, "w"))
	f:write(f_str)

	path = "../../runtime/win_local_server_list.lua"
	f = assert(io.open(path, "r"))
	f_str = f:read("*a")
	f_str, num = string.gsub(f_str, "use_local_server_list = true", "use_local_server_list = false")
	f = assert(io.open(path, "w"))
	f:write(f_str)

	f:close()

	SysMsgCtrl.Instance:ErrorRemind("配置连接外网环境成功 SPID: " .. spid .. " ，请等待一会，游戏自动重启后生效", true)
	self.spid_restart_timer = GlobalTimerQuest:AddDelayTimer(function()
		self.spid_restart_timer = nil
		ReStart()
	end, 5)
end
