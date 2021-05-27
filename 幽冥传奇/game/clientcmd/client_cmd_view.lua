
ClientCmdView = ClientCmdView or BaseClass(BaseView)

function ClientCmdView:__init()
	self.zorder = COMMON_CONSTS.ZORDER_AGENT_LOGIN
	self.open_mode = OpenMode.OpenToggle
	self.close_mode = CloseMode.CloseDestroy
	self.can_penetrate = true

	self.btn_list = {"Close", "Block", "AddChat", "CopyMainRole"}
	local windows_list = {"PlayRecord", "XunboaCount", "BossZhiJia", "YeWaiBoss", "WeiZhiAnDian", "ChuMo", "CaiLiao", "Task", "PersonalBoss", "RecycleEquip", "SPID"}
	if PLATFORM == cc.PLATFORM_OS_WINDOWS then
		for k, v in pairs(windows_list) do
			table.insert(self.btn_list, v)
		end
	end

	self.btn_node_list = {}
	self.block_show_node = nil
end

function ClientCmdView:__delete()
	
end

function ClientCmdView:OnChangeScene(scene_id)
	if self.block_show_node then
		self.block_show_node:removeFromParent(true)
		self.block_show_node = nil
	end
end

function ClientCmdView:LoadCallBack(index, loaded_times)
	local width = HandleRenderUnit:GetWidth() - 90
	local height = HandleRenderUnit:GetHeight() - 0
	self.root_node:setContentWH(width, height)

	local btn_width = 120
	local btn_heiht = 40
	local row_count = 8
	-- local row_count = math.floor(width / (btn_width + 10))

	for i, v in ipairs(self.btn_list) do
		local x = 30 + (i - 1) % row_count * (btn_width + 7)
		local y = height - 30 - math.floor((i - 1) / row_count) * (btn_heiht + 7)

		local layout_bg = XUI.CreateLayout(x, y, btn_width, btn_heiht)
		layout_bg:setBackGroundColor(COLOR3B.BLACK)
		layout_bg:setOpacity(180)
		self.root_node:addChild(layout_bg)

		local text = XUI.CreateText(btn_width / 2, btn_heiht / 2, 0, 0, nil, v, nil, 22, nil, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		layout_bg:addChild(text)

		XUI.AddClickEventListener(layout_bg, BindTool.Bind(self["OnClickBtn" .. v], self), true)
		self.btn_node_list[v] = layout_bg

		-- 输入框
		if v == "SPID" then
			local node = XUI.CreateEditBox(btn_width / 2, btn_heiht / 2, btn_width, btn_heiht, nil, nil, nil, ResPath.GetCommon("img9_transparent"), true, nil)
			layout_bg:addChild(node)
			local edit_event = self["OnEditBox" .. v]
			if edit_event then
				node:registerScriptEditBoxHandler(BindTool.Bind(edit_event, self))
			end
			text:setString(AgentAdapter and AgentAdapter:GetSpid() or "")
		end
	end

	self:FlushBtnsState()
end

function ClientCmdView:OnFlush()
	self:FlushBtnsState()
end

function ClientCmdView:OnClickBtnClose()
	self:Close()
end

function ClientCmdView:FlushBtnsState()
	for k, v in pairs(self.btn_node_list) do
		if k == "BossZhiJia" then
			if ReloadScriptManager.Instance then
				local color = (ReloadScriptManager.Instance.auto_kill_boss and ReloadScriptManager.Instance.kill_boss_type == 1) and COLOR3B.RED or COLOR3B.BLACK
				v:setBackGroundColor(color)
			end
		elseif k == "YeWaiBoss" then
			if ReloadScriptManager.Instance then
				local color = (ReloadScriptManager.Instance.auto_kill_boss and ReloadScriptManager.Instance.kill_boss_type == 2) and COLOR3B.RED or COLOR3B.BLACK
				v:setBackGroundColor(color)
			end
		elseif k == "WeiZhiAnDian" then
			if ReloadScriptManager.Instance then
				local color = (ReloadScriptManager.Instance.auto_kill_boss and ReloadScriptManager.Instance.kill_boss_type == 3) and COLOR3B.RED or COLOR3B.BLACK
				v:setBackGroundColor(color)
			end
		elseif k == "ChuMo" then
			if ReloadScriptManager.Instance then
				local color = (ReloadScriptManager.Instance.auto_kill_boss and ReloadScriptManager.Instance.kill_boss_type == 4) and COLOR3B.RED or COLOR3B.BLACK
				v:setBackGroundColor(color)
			end
		elseif k == "CaiLiao" then
			if ReloadScriptManager.Instance then
				local color = (ReloadScriptManager.Instance.auto_kill_boss and ReloadScriptManager.Instance.kill_boss_type == 5) and COLOR3B.RED or COLOR3B.BLACK
				v:setBackGroundColor(color)
			end
		elseif k == "Task" then
			if ReloadScriptManager.Instance then
				local color = (ReloadScriptManager.Instance.auto_kill_boss and ReloadScriptManager.Instance.kill_boss_type == 6) and COLOR3B.RED or COLOR3B.BLACK
				v:setBackGroundColor(color)
			end
		elseif k == "PersonalBoss" then
			if ReloadScriptManager.Instance then
				local color = (ReloadScriptManager.Instance.auto_kill_boss and ReloadScriptManager.Instance.kill_boss_type == 7) and COLOR3B.RED or COLOR3B.BLACK
				v:setBackGroundColor(color)
			end
		elseif k == "RecycleEquip" then
			if ReloadScriptManager.Instance then
				local color = ReloadScriptManager.Instance.auto_recycle_equip and COLOR3B.RED or COLOR3B.BLACK
				v:setBackGroundColor(color)
			end
		end
	end
end

function ClientCmdView:OnClickBtnBlock()
	if nil == self.block_show_node then
		self.block_show_node = cc.Node:create()
		self.block_show_node:setPosition(0, 0)
		HandleRenderUnit:GetCoreScene():addChildToRenderGroup(self.block_show_node, GRQ_BLOCK)

		local map = HandleGameMapHandler:GetGameMap()
		local width = HandleRenderUnit:GetLogicWidth()
		local height = HandleRenderUnit:GetLogicHeight()

		local y = 0
		local function timer_callback()
			for i = 1, 10 do
				if y >= height then
					break
				end
				local begin_i, end_i = -1, -1
				local is_block = true
				for x = 0, width - 1 do
					is_block = GameMapHelper.IsBlock(x, y)
					if is_block then
						if begin_i < 0 then begin_i = x end
						end_i = x
					end

					if HandleGameMapHandler:GetGameMap():getZoneInfo(x, y) == ZONE_TYPE_BLOCK + ZoneType.ShadowDelta then
						local layout = XLayout:create(Config.SCENE_TILE_WIDTH, Config.SCENE_TILE_HEIGHT)
						local pos_x, pos_y = HandleRenderUnit:LogicToWorldEx(begin_i, y)
						layout:setPosition(pos_x, pos_y)
						layout:setOpacity(127)
						self.block_show_node:addChild(layout)
						layout:setBackGroundColor(COLOR3B.GREEN)
					end

					if begin_i >= 0 and end_i >= begin_i and (x == width - 1 or not is_block) then
						local layout = XLayout:create(Config.SCENE_TILE_WIDTH * (end_i - begin_i + 1), Config.SCENE_TILE_HEIGHT)
						local pos_x, pos_y = HandleRenderUnit:LogicToWorldEx(begin_i, y)
						layout:setPosition(pos_x, pos_y)
						layout:setBackGroundColor(COLOR3B.RED)
						layout:setOpacity(127)
						self.block_show_node:addChild(layout)
						begin_i = -1
					end
				end
				y = y + 1
			end
		end

		GlobalTimerQuest:AddTimesTimer(timer_callback, 0.01, height / 10 + 1)
		return
	end

	self.block_show_node:setVisible(not self.block_show_node:isVisible())
end

function ClientCmdView:OnClickBtnAddChat( ... )
	-- ChatCtrl.Instance:AddSystemMsg("天降异象，宝物出世！{r;1057191;养眼★妖精;1} 前往绝地寻宝，发现了" .. 
	-- 	"{i;26196}x1 {i;26196}x1 {i;26196}x1 {i;26196}x1 {i;26196}x1 {i;26196}x1 ，让人羡慕不已！" .. math.random(1, 1000))
	ChatCtrl.Instance:AddSystemMsg("{viewLink;Role#RoleInfoList#GodEquip;神装}")
end

function ClientCmdView:OnClickBtnCopyMainRole()
	local vo = TableCopy(Scene.Instance:GetMainRole().vo)
	vo.obj_id = 0
	local role = Scene.Instance:CreateRole(vo)
	role:SetDirNumber(1)
	role:SetRealPos(Scene.Instance:GetMainRole().real_pos.x, Scene.Instance:GetMainRole().real_pos.y)
	role:DoStand()
end

function ClientCmdView:OnClickBtnTask()
	if ReloadScriptManager.Instance then
		ReloadScriptManager.Instance:AutoDoTask()
	end
end

function ClientCmdView:OnClickBtnPlayRecord()
	if ReloadScriptManager.Instance then
		ReloadScriptManager.Instance:PlayRecord()
	end
end

function ClientCmdView:OnClickBtnCaiLiao()
	if ReloadScriptManager.Instance then
		if 5 == ReloadScriptManager.Instance.kill_boss_type and ReloadScriptManager.Instance.auto_kill_boss then
			ReloadScriptManager.Instance:AutoKillBoss(false)
		else
			ReloadScriptManager.Instance:AutoKillBoss(true, 5)
		end
	end
end

function ClientCmdView:OnClickBtnChuMo()
	if ReloadScriptManager.Instance then
		if 4 == ReloadScriptManager.Instance.kill_boss_type and ReloadScriptManager.Instance.auto_kill_boss then
			ReloadScriptManager.Instance:AutoKillBoss(false)
		else
			ReloadScriptManager.Instance:AutoKillBoss(true, 4)
		end
	end
end

function ClientCmdView:OnClickBtnYeWaiBoss()
	if ReloadScriptManager.Instance then
		if 2 == ReloadScriptManager.Instance.kill_boss_type and ReloadScriptManager.Instance.auto_kill_boss then
			ReloadScriptManager.Instance:AutoKillBoss(false)
		else
			ReloadScriptManager.Instance:AutoKillBoss(true, 2)
		end
	end
end

function ClientCmdView:OnClickBtnBossZhiJia()
	if ReloadScriptManager.Instance then
		if 1 == ReloadScriptManager.Instance.kill_boss_type and ReloadScriptManager.Instance.auto_kill_boss then
			ReloadScriptManager.Instance:AutoKillBoss(false)
		else
			ReloadScriptManager.Instance:AutoKillBoss(true, 1)
		end
	end
end

function ClientCmdView:OnClickBtnWeiZhiAnDian()
	if ReloadScriptManager.Instance then
		if 3 == ReloadScriptManager.Instance.kill_boss_type and ReloadScriptManager.Instance.auto_kill_boss then
			ReloadScriptManager.Instance:AutoKillBoss(false)
		else
			ReloadScriptManager.Instance:AutoKillBoss(true, 3)
		end
	end
end

function ClientCmdView:OnClickBtnPersonalBoss()
	if ReloadScriptManager.Instance then
		if 7 == ReloadScriptManager.Instance.kill_boss_type and ReloadScriptManager.Instance.auto_kill_boss then
			ReloadScriptManager.Instance:AutoKillBoss(false)
		else
			ReloadScriptManager.Instance:AutoKillBoss(true, 7)
		end
	end
end

function ClientCmdView:OnClickBtnRecycleEquip()
	if ReloadScriptManager.Instance then
		ReloadScriptManager.Instance:SetIsAutoRecycleEquip(not ReloadScriptManager.Instance.auto_recycle_equip)
		self:Flush()
	end
end

function ClientCmdView:OnEditBoxSPID(event_type, sender)
	if "began" == event_type then
	elseif "changed" == event_type then
	elseif "ended" == event_type then
		local text = sender:getText()
		sender:setText("")
		
		if text ~= "" then
			if text == "local" then
				local path = "../assets/scripts/"
				io.popen(string.format("TortoiseProc.exe /command:revert /path:\"%s\" /closeonend:2", path))
				return
			end

			if ReloadScriptManager.Instance then
				ReloadScriptManager.Instance:SetClientEnvironment(text)
				local text_node = sender:getParent():getChildByTag(9)
				if text_node then
					text_node:setString(text)
				end
			end
		end
	end
end

function ClientCmdView:OnClickBtnSPID()
	if ReloadScriptManager.Instance then
		-- ReloadScriptManager.Instance:SetClientEnvironment()
	end
end

function ClientCmdView:OnClickBtnXunboaCount()
	self:WriteCountItemsToFile(ExploreData.Instance:GetWearHouseAllData())
end

-- 统计物品数量
function ClientCmdView:WriteCountItemsToFile(item_list)
	local path = DESKTOP_PATH
	local str_buffer = {}

	local error_times = 0
	local equip_data = {}
	local rune_data = {}
	local other_data = {}
	local peerless_data = {}
	for k, v in pairs(item_list) do
		local level, zhuan_lv = ItemData.GetItemLevel(v.item_id)
		if v.type and v.type >= ItemData.ItemType.itWeapon and v.type <= ItemData.ItemType.itShoes then	-- 普通装备
			if equip_data[zhuan_lv] == nil then
				equip_data[zhuan_lv] = {}
			end
			if equip_data[zhuan_lv][level] == nil then
				equip_data[zhuan_lv][level] = 1
			else
				equip_data[zhuan_lv][level] = equip_data[zhuan_lv][level] + 1
			end
		elseif v.type and v.type == ItemData.ItemType.itRune then	-- 符文
			if rune_data[zhuan_lv] == nil then
				rune_data[zhuan_lv] = {}
			end
			if rune_data[zhuan_lv][level] == nil then
				rune_data[zhuan_lv][level] = 1
			else
				rune_data[zhuan_lv][level] = rune_data[zhuan_lv][level] + 1
			end
		elseif v.type and v.type >= ItemData.ItemType.itPeerlessWeapon and v.type <= ItemData.ItemType.itPeerlessShoes then	-- 传世装备
			if peerless_data[zhuan_lv] == nil then
				peerless_data[zhuan_lv] = {}
			end
			if peerless_data[zhuan_lv][level] == nil then
				peerless_data[zhuan_lv][level] = 1
			else
				peerless_data[zhuan_lv][level] = peerless_data[zhuan_lv][level] + 1
			end
		else		-- 其他物品
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg then
				if other_data[item_cfg.name] == nil then
					other_data[item_cfg.name] = v.num
				else
					other_data[item_cfg.name] = other_data[item_cfg.name] + v.num
				end
			else
				error_times = error_times + 1
			end
		end
	end
	
	table.insert(str_buffer, "传世装备：")
	for k, v in pairs(peerless_data) do
		for k1, v1 in pairs(v) do
			table.insert(str_buffer, string.format( "%d转%d级传世x%d", k, k1, v1))
		end
	end
	-- 拼接装备数据
	table.insert(str_buffer, "\r\n装备：")
	for k, v in pairs(equip_data) do
		for k1, v1 in pairs(v) do
			table.insert(str_buffer, string.format( "%d转%d级装备x%d", k, k1, v1))
		end
	end

	-- 符文
	table.insert(str_buffer, "\r\n符文：")
	for k, v in pairs(rune_data) do
		for k1, v1 in pairs(v) do
			table.insert(str_buffer, string.format( "%d转%d级符文x%d", k, k1, v1))
		end
	end

	-- 其他物品
	table.insert(str_buffer, "\r\n其他物品：")
	for k, v in pairs(other_data) do
		table.insert(str_buffer, string.format( "%sx%d", k, v))
	end

	local file = io.open(path .. "list.txt", "w")
	if file then
		local str = table.concat(str_buffer, "\r\n")
		file:write(str)
		file:close()
	end

	SysMsgCtrl.Instance:ErrorRemind("物品统计文件成功生成：" .. path .. "list.txt")
end