SlaughterFBMap = SlaughterFBMap or BaseClass(BaseCell)

local number = 0

function SlaughterFBMap:__init()
	UtilU3d.PrefabLoad("uis/views/lianhun_prefab", "Map",
		function(prefab)
			if IsNil(self.root_node.transform) then
				GameObject.Destroy(prefab)
				return
			end
			prefab = U3DObject(prefab)
			prefab.transform:SetParent(self.root_node.transform, false)
			self.prefab = prefab
			self.variable_table = prefab:GetComponent(typeof(UIVariableTable))
			self.name_table = prefab:GetComponent(typeof(UINameTable))
			self.event_table = prefab:GetComponent(typeof(UIEventTable))
			self.name = self:FindVariable("Name")
			-- self.introduce = self:FindVariable("IntroduceText")
			-- self.level = self:FindVariable("level")

			self.fight_power = self:FindVariable("fight_power")
			self.star_num = self:FindVariable("star_num")
			self.level_limit = self:FindVariable("level_limit")
			self.show_level = self:FindVariable("show_level")
			self.is_cur_chapter = self:FindVariable("is_cur_chapter")
			self.level_bg = self:FindVariable("level_bg")
			
			self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
			self.prefab_load = true
			self:Flush()
		end)
	self.cur_select_index = 1
	self.init_scorller_num = 0
	self.cell_list = {}
end


function SlaughterFBMap:__delete()
end

function SlaughterFBMap:OnFlush()
	self:ConstructData()
	self:SetFlag()
	self:SetModel()
	self:SetInfo()
end

function SlaughterFBMap:ConstructData()
	if self.prefab_load and self.data then
		self.construct = true
	else
		self.construct = nil
	end
end

function SlaughterFBMap:SetFlag()	
end

function SlaughterFBMap:SetModel()
	if self.construct == nil then
		return
	end
end


function SlaughterFBMap:SetInfo()
	if self.construct == nil then	
		return
	end
	self.name:SetValue(self.data.fb_name)
	local str = Language.Common.ZhanLiText .. self.data.capability
	local fight_power_text = GetRightColor(str, function ()
		local role_cap = GameVoManager.Instance:GetMainRoleVo().capability
		if role_cap < self.data.capability then
			return false
		else
			return true
		end
	end, TEXT_COLOR.WHITE, TEXT_COLOR.RED)
	self.fight_power:SetValue(fight_power_text)
	local str = "级"
	self.level_limit:SetValue(self.data.enter_level_limit .. str)
	self.star_num:SetValue(self.data.star)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if role_level > tonumber(self.data.enter_level_limit) then
		self.show_level:SetValue(false)
	else
		self.show_level:SetValue(true)
	end
	local flag = self.data.is_cur_level and true or false
	self.is_cur_chapter:SetValue(flag)
	self.level_bg:SetAsset(ResPath.GetLevelIcon(self.data.chapter % 4 + 1))
	-- self.is_cur_level
end

function SlaughterFBMap:FlushHL()
	
end

function SlaughterFBMap:OnClick()
	if self.click_callback then
		self.click_callback(self.index)
	end
end


SlaughterFBMapChapter = SlaughterFBMapChapter or BaseClass(BaseRender)

function SlaughterFBMapChapter:__init()
	self.maps = {}
	-- for i = 1, 10 do
	-- 	local map = SlaughterFBMap.New(self:FindObj("Map" .. i))
	-- 	table.insert(self.maps, map)
	-- end
end

function SlaughterFBMapChapter:__delete()
	for k,v in pairs(self.maps) do
		v:DeleteMe()
		v = nil
	end
end

function SlaughterFBMapChapter:SetData(data)
	self.data = data
	if self.maps[1] ~= nil then
		for i=1,10 do
			self.maps[i]:SetData(data[i - 1])
			self.maps[i]:SetActive(data[i - 1].is_open)
		end
	end
end

function SlaughterFBMapChapter:SetClickCallBack(click_callback)
	self.click_callback = click_callback
	if self.maps[1] ~= nil and self.prefab then
		for i=1,10 do
			self.maps[i]:SetClickCallBack(self.click_callback)
		end
	end
end

function SlaughterFBMapChapter:SetIndex(index)
	self.index = index
	-- for i=1,3 do
	-- 	self.paths[i]:SetActive(index % 3 == i - 1)
	-- end
	local seq = index % 2 + 1
	if index == 1 then
		seq = 0
	end
	local asset = "SlaughterFBMap" .. seq
	UtilU3d.PrefabLoad("uis/views/lianhun_prefab", asset,
			function(prefab)
				if self.prefab and not IsNil(self.prefab.gameObject) then
					GameObject.Destroy(self.prefab.gameObject)
					self.prefab = nil
					for k,v in pairs(self.maps) do
						v:DeleteMe()
						v = nil
					end
					self.maps = {}
				end
				prefab = U3DObject(prefab)
				prefab.transform:SetParent(self.root_node.transform, false)
				self.prefab = prefab
				local name_table = prefab:GetComponent(typeof(UINameTable))
				for i=1,10 do
					local map = SlaughterFBMap.New(name_table:Find("Map" .. i))
					table.insert(self.maps, map)
				end
				-- self.line = self:FindObj("Line")
				for i=1,10 do
					self.maps[i]:SetIndex(i)
				end
				if self.click_callback then
					self:SetClickCallBack(self.click_callback)
				end
				if self.data then
					self:SetData(self.data)
				end
			end)
end

SlaghterMapReward = SlaghterMapReward or BaseClass(BaseCell)

function SlaghterMapReward:__init()
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.is_can_open = self:FindVariable("IsCanOpen")
	self.is_get_reward = self:FindVariable("is_get_reward")
	self.anim = self:FindObj("Icon").animator
	self.can_open = false
	self.callback = nil
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end


function SlaghterMapReward:__delete()
	if self.shake_timer then
		GlobalTimerQuest:CancelQuest(self.shake_timer)
		self.shake_timer = nil
	end
end

function SlaghterMapReward:OnFlush()
	self:ConstructData()
	self:SetFlag()
	self:SetModel()
	self:SetInfo()
end

function SlaghterMapReward:ConstructData()
	self.construct = true
	if self.shake_timer then
		GlobalTimerQuest:CancelQuest(self.shake_timer)
		self.shake_timer = nil
	end
end

function SlaghterMapReward:SetFlag()	
end

function SlaghterMapReward:SetModel()
	if self.construct == nil  then
		return
	end
end


function SlaghterMapReward:SetInfo()
	if self.construct == nil  then
		return
	end
	self.name:SetValue(self.data.star_num)
	local fb_info = SlaughterDevilData.Instance:GetViewData()
	local bundle, asset = ResPath.GetGuildBoxIcon(self.index + 1, false)
	self.icon:SetAsset(bundle, asset)
	local cur_fb_info = fb_info[self.data.chapter]
	if cur_fb_info.star_reward_flag[33 - self.index] == 0 then
		if cur_fb_info.cur_star >= self.data.star_num then
			self.shake_timer = GlobalTimerQuest:AddRunQuest(function()
				self.anim:SetTrigger("Shake")
			end,1)
			self.can_open = true
		else
			self.can_open = false
		end
		self.is_get_reward:SetValue(false)
	else
		self.can_open = false
		self.is_can_open:SetValue(false)
		self.is_get_reward:SetValue(true)
		bundle, asset = ResPath.GetGuildBoxIcon(self.index + 1, true)
		self.icon:SetAsset(bundle, asset)
	end
end

function SlaghterMapReward:SetIndex(index)
	self.index = index
end

function SlaghterMapReward:FlushHL()
	
end

function SlaghterMapReward:OnClick()
	if self.click_callback then
		self.click_callback(self.data, self.can_open)
	end
end