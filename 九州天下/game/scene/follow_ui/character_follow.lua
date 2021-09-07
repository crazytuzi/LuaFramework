CharacterFollow = CharacterFollow or BaseClass(FollowUi)

function CharacterFollow:__init()
	self.hp_bar = nil
	self.hp_slider_top = nil
	self.hp_slider_bottom = nil
	self.title_list = {}

	self.is_show_title = true
	self.is_show_special_title = false
	self.special_title = 0
	self.has_guild = false
	self.has_lover = false
	self.banzhuan_color = -1
	self.citan_color = -1

	self.title_switch = false
end

function CharacterFollow:__delete()
	self:RemoveTitleList()
	-- if nil ~= self.root_obj then
	-- 	GameObject.Destroy(self.root_obj)
	-- 	self.root_obj = nil
	-- end
end

-- function CharacterFollow:Create(obj_type)
-- 	FollowUi.Create(self, obj_type or 0)


-- 	self.hp_bar = self:CreateHpBar()
-- 	local the_follow = self.root_obj.transform:Find("Follow").transform
-- 	if nil ~= self.hp_bar then
-- 		self.hp_bar.transform:SetParent(the_follow, false)
-- 		--self.hp_bar.transform:SetLocalPosition(0,5,0)
-- 	end
-- end

function CharacterFollow:Create(obj_type)
	FollowUi.Create(self, obj_type or 0)
end

function CharacterFollow:SetHpBarLocalPosition(x,y,z)
	self.hp_bar.transform:SetLocalPosition(x,y,z)
end

function CharacterFollow:CreateHpBar()
	-- return GameObject.Instantiate(
	-- 	PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "MonsterHP"))
end

function CharacterFollow:SetNameLocalPosition(x,y,z)
	local temp_transform = self.name.transform:Find("GameObject").transform
	local temp_transform_name = temp_transform:Find("SceneObjName").transform
	temp_transform_name.transform:SetLocalPosition(x,y,z)
end

function CharacterFollow:SetHpPercent(percent)
	-- if nil == self.hp_bar then
	-- 	return
	-- end

	-- if nil == self.hp_slider_top then
	-- 	self.hp_slider_top = self.hp_bar.transform:Find("MonsterHPTop"):GetComponent(typeof(UnityEngine.UI.Slider))
	-- end
	-- self.hp_slider_top.value = percent

	-- if nil == self.hp_slider_bottom then
	-- 	self.hp_slider_bottom = self.hp_bar.transform:Find("MonsterHPBottom"):GetComponent(typeof(UnityEngine.UI.Slider))
	-- 	self.hp_slider_bottom.value = percent
	-- else
	-- 	self.hp_slider_bottom:DOValue(percent, 0.5, false)
	-- end
end

function CharacterFollow:SetTitle(index, title_id)
	if index > 1 then
		return
	end
	if self.title_list[index] ~= nil then
		GameObjectPool.Instance:Free(self.title_list[index].gameObject)
		self.title_list[index] = nil
	end
	if title_id == nil or title_id == 0 then return end
	local asset_bundle, asset_name = ResPath.GetTitleModel(title_id)
	if not asset_bundle or not asset_name then
		return
	end
	GameObjectPool.Instance:SpawnAsset(
			asset_bundle,
			asset_name,
			BindTool.Bind(self.OnTitleLoadComplete, self, index))
end

function CharacterFollow:OnTitleLoadComplete(index, obj)
	if IsNil(obj) or not self.root_obj then return end
	if self.title_list[index] ~= nil then
		GameObjectPool.Instance:Free(self.title_list[index].gameObject)
		self.title_list[index] = nil
	end
	self.title_list[index] = U3DObject(obj)

	if nil ~= self.title_list[index] then
		local the_follow = self.root_obj.transform:Find("Follow").transform
		self.title_list[index].gameObject.transform:SetParent(the_follow, false)
		local temp = index
		if temp == 0 then temp = 1 end
		local space = 30
		if self.has_guild then
			space = space + 30
		end
		if self.has_lover and self.banzhuan_color <= 0 and self.citan_color <= 0 then
			space = space + 30
		end

		self.title_list[index].gameObject.transform:SetLocalPosition(0, temp * 50 + space, 0)
		if self.scale then
			self.title_list[index].gameObject.transform:SetLocalScale(self.scale[1], self.scale[2], self.scale[3])
		end
		-- local image_height = 0
		-- local temp_y = self.title_list[index].gameObject.transform.localPosition.y

		-- if self.is_show_special_imag then
		-- 	if self.special_image_obj:GetComponent(typeof(UnityEngine.RectTransform)) then
		-- 		image_height = self.special_image_obj:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.y
		-- 	end

		-- 	self.title_list[index].gameObject.transform:SetLocalPosition(0, image_height + temp_y, 0)
		-- end
	end
	local switch = self:IsNeedVisible(index)
	self.title_list[index].gameObject:SetActive(switch)
	self.title_switch = switch
end

function CharacterFollow:SetLocalScale(scale)
	self.scale = scale
	for k,v in pairs(self.title_list) do
		v.gameObject.transform:SetLocalScale(self.scale[1], self.scale[2], self.scale[3])
	end
end

function CharacterFollow:CreateTitleEffect(vo)
	if nil == vo then return end
	self.vo = vo
	local selected_title = self:FilterTitle(self.vo.used_title_list)
	self.has_guild = (vo.guild_id > 0) or (vo.touxian_level > 0)
	self.has_lover = vo.lover_name and  vo.lover_name ~= ""

	local mainrole_vo =  GameVoManager.Instance:GetMainRoleVo()
	local banzhuan_list = NationalWarfareData.Instance:GetCampBanzhuanStatus()
	local temp_banzhuan_color = banzhuan_list.cur_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
					banzhuan_list.cur_color or banzhuan_list.get_color
	self.banzhuan_color = mainrole_vo.role_id == vo.role_id and temp_banzhuan_color or vo.banzhuan_color

	local citan_list = NationalWarfareData.Instance:GetCampCitanStatus()
	local temp_citan_color = citan_list.cur_qingbao_color ~= CAMP_TASK_BANZHUAN_COLOR.CAMP_TASK_BANZHUAN_COLOR_INVALID and 
					citan_list.cur_qingbao_color or citan_list.get_qingbao_color
	self.citan_color = mainrole_vo.role_id == vo.role_id and temp_citan_color or vo.citan_color

	-- self.is_banzhuan = vo.banzhuan_color and vo.banzhuan_color > 0
	-- self.is_citan = vo.citan_color and vo.citan_color > 0
	if not selected_title then return end
	table.sort(selected_title, function(x,y)
			local a = TitleData.Instance:GetTitleCfg(x)
			local b = TitleData.Instance:GetTitleCfg(y)
			if a ~= nil and b ~= nil then
				return a.title_show_level < b.title_show_level
			end
		end)

	-- self:EvilTitleFilter(selected_title, vo.name_color)
	-- self:AchieveTitleFilter(selected_title, vo.chengjiu_title_level)
	-- self:RemoveTitleList()
	for i = 1, 4 do
		self:SetTitle(i, selected_title[i] or 0)
	end

	if self.is_show_special_title then
		self:SetTitle(0, self.special_title)
	end
end

-- 过滤称号
function CharacterFollow:FilterTitle(used_title_list)
	-- local selected_title = {}
	-- for k,v in pairs(used_title_list) do
	-- 	if not TitleData.IsJingLingTitle(v) then  -- 暂时没有精灵称号
	-- 		selected_title[#selected_title + 1] = v
	-- 	end
	-- end

	-- return selected_title

	return used_title_list
end

-- 恶名称号过滤
-- function CharacterFollow:EvilTitleFilter(selected_title, name_color)
-- 	local evil_title = 0
-- 	if name_color > EvilColorList.NAME_COLOR_RED_1 then
-- 		if name_color == EvilColorList.NAME_COLOR_RED_2 then
-- 			evil_title = COMMON_CONSTS.EVIL_TITLE_1
-- 		elseif name_color == EvilColorList.NAME_COLOR_RED_3 then
-- 			evil_title = COMMON_CONSTS.EVIL_TITLE_2
-- 		end
-- 	end
-- 	if evil_title > 0 then
-- 		local title_count = 0
-- 		for k, v in pairs(selected_title) do
-- 			if v > 0 then
-- 				title_count = title_count + 1
-- 			end
-- 		end
-- 		if title_count == 3 or nil == selected_title[1] or selected_title[1] == COMMON_CONSTS.EVIL_TITLE_1 or selected_title[1] == COMMON_CONSTS.EVIL_TITLE_2 then
-- 			selected_title[1] = evil_title
-- 		else
-- 			table.insert(selected_title, 1, evil_title)
-- 		end
-- 	end
-- end

function CharacterFollow:AchieveTitleFilter(selected_title, chengjiu_title_level)
	local chengjiu_title = 10000 + chengjiu_title_level - 1
	if chengjiu_title < 10000 then
		return
	end
	table.insert(selected_title, 1, chengjiu_title)
end

function CharacterFollow:RemoveTitleList()
	-- for i = 1, 4 do
	-- 	if self.title_list[i] then
	-- 		GameObjectPool.Instance:Free(self.title_list[i].gameObject)
	-- 		self.title_list[i] = nil
	-- 	end
	-- end
	for k,v in pairs(self.title_list) do
		if v then
			GameObjectPool.Instance:Free(v.gameObject)
		end
	end

	self.title_list = {}
end

function CharacterFollow:SetTitleVisible(is_visible)
	self.is_show_title = is_visible
	for k,v in pairs(self.title_list) do
		if v then
			local switch = self:IsNeedVisible(k)
			v.gameObject:SetActive(switch)
		end
	end
end

function CharacterFollow:ChangeSpecailTitle(res_id)
	if not res_id or res_id == 0 then
		self.is_show_special_title = false
		self.special_title = 0
	else
		self.is_show_special_title = true
		self.special_title = res_id
		self:SetTitle(0, res_id)
	end
	self:SetTitleVisible(self.is_show_title)
end

function CharacterFollow:IsNeedVisible(index)
	if index == 0 then
		if self.is_show_special_title then
			return true
		end
	else
		if self.is_show_title and not self.is_show_special_title then
			return true
		end
	end
	return false
end

function CharacterFollow:SetHpVisiable(value)
	if not self.hp_bar then return end
	self.hp_bar:SetActive(value)
end

function CharacterFollow:GetTitleObj()
	return self.title_list
end

function CharacterFollow:GetHpObj()
	if not self.hp_bar then return end
	return self.hp_bar
end
