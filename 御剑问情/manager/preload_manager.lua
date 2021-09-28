
-- 预加载

PreloadManager = PreloadManager or BaseClass()

function PreloadManager:__init()
	if PreloadManager.Instance ~= nil then
		print_error("PreloadManager to create singleton twice!")
	end
	PreloadManager.Instance = self

	self.complete = false
	self.loadcfg = {
		{"uis/views/miscpreload_prefab", "FollowUi"},
		{"uis/views/miscpreload_prefab", "SceneObjName"},
		{"uis/views/miscpreload_prefab", "MonsterHP"},
		{"uis/views/miscpreload_prefab", "RoleHP"},
		{"uis/views/miscpreload_prefab", "RichButton"},				--聊天有点击事件的按钮
		{"uis/views/miscpreload_prefab", "RichButton2"},				--聊天有点击事件的按钮(下划线)
		{"uis/views/miscpreload_prefab", "RichButtonNotTarget"},		--聊天无点击事件的按钮
		{"uis/views/miscpreload_prefab", "RichButtonNotTarget2"},		--聊天无点击事件的按钮(下划线)
		{"uis/views/miscpreload_prefab", "RichImage"},
		{"uis/views/miscpreload_prefab", "RichImage_Small"},
		{"uis/views/miscpreload_prefab", "BigfaceSlot"},				-- 大表情容器
		{"uis/views/miscpreload_prefab", "BigfaceSlotSmall"},			-- 大表情容器
		{"uis/views/miscpreload_prefab", "NormalfaceSlot"},			-- 普通表情容器
		{"uis/views/miscpreload_prefab", "NormalfaceSlotSmall"},	    -- 普通表情容器
		{"uis/views/miscpreload_prefab", "VioceButtonLeft"},			-- 语音左按钮
		{"uis/views/miscpreload_prefab", "VioceButtonRight"},			-- 语音右按钮
		{"uis/views/miscpreload_prefab", "LeisureBubble"},				-- 预加载场景框
		{"uis/views/miscpreload_prefab", "BubbleSlotRight"},			-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "BubbleSlotLeft"},			-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "GuildMazeBubbleSlotLeft"},	-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "GuildMazeBubbleSlotRight"},	-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "ContentLeft"},				-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "ContentRight"},				-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "GuildMazeContentLeft"},		-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "GuildMazeContentRight"},		-- 预加载聊天框
		{"uis/views/miscpreload_prefab", "ItemCell"},					-- 预加载格子
		{"uis/views/miscpreload_prefab", "PieceItem"},					-- 预加载格子
		{"uis/views/miscpreload_prefab", "ChatCell"},					-- 预加载聊天cell
		{"uis/views/miscpreload_prefab", "PaintingEffect"},				-- 预加载名将变身
		{"uis/views/miscpreload_prefab","TianshenhutiEquip"},			-- 预加载名周末装备
	}

	self.load_index = 0
	self.complete_index = 0
	self.loaded_list = {}
	self.loaded_callback = nil
end

function PreloadManager:__delete()
	if self.main_open_event then
		GlobalEventSystem:UnBind(self.main_open_event)
		self.main_open_event = nil
	end
	PreloadManager.Instance = nil
	self.loaded_callback = nil
end

function PreloadManager:GetLoadListCfg()
	return self.loadcfg
end

function PreloadManager:SetLoadList(loaded_list)
	self.loaded_list = loaded_list
end

function PreloadManager:Start()
	self.complete = false
	self.total_count = #self.loadcfg
	PushCtrl(self)
end

function PreloadManager:WaitComplete(loaded_callback)
	if self.complete then
		loaded_callback(1)
	else
		self.loaded_callback = loaded_callback
	end
end

function PreloadManager:Update()
	if self.load_index < #self.loadcfg then
		for i=1,5 do
			self.load_index = self.load_index + 1
			if self.load_index <= #self.loadcfg then
				local cfg = self.loadcfg[self.load_index]
				PrefabPool.Instance:Load(AssetID(cfg[1], cfg[2]),
					BindTool.Bind(self.OnLoadComplete, self, self.load_index), true)
			end
		end
	else
		PopCtrl(self)
	end
end

function PreloadManager:OnLoadComplete(load_index, prefab)
	self.complete_index = self.complete_index + 1
	local cfg = self.loadcfg[load_index]
	self.loaded_list[cfg[1]] = self.loaded_list[cfg[1]] or {}
	self.loaded_list[cfg[1]][cfg[2]] = prefab

	if nil ~= self.loaded_callback then
		self.loaded_callback(self.complete_index / self.total_count)
	end

	if self.complete_index >= self.total_count then
		self.complete = true
		self.loaded_callback = nil
	end
end

function PreloadManager:GetPrefab(path, name)
	if nil == self.loaded_list[path] then
		return nil
	end
	return self.loaded_list[path][name]
end