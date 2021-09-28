FlushSpiriLittleSkillView = FlushSpiriLittleSkillView or BaseClass(BaseView)

function FlushSpiriLittleSkillView:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "FlsuhSpriteSkillLittleView"}
	self.play_audio = true
end

function FlushSpiriLittleSkillView:__delete()

end

function FlushSpiriLittleSkillView:CloseCallBack()
end

function FlushSpiriLittleSkillView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("FlsuhSkill", BindTool.Bind(self.FlsuhSkill, self))
	self:ListenEvent("FlsuhManySkill", BindTool.Bind(self.FlsuhManySkill, self))
	self:ListenEvent("LearnSkill", BindTool.Bind(self.LearnSkill, self))

	self.text_skill_name = self:FindVariable("text_skill_name")
	-- self.image_icon = self:FindVariable("image_icon")
	self.text_stage_desc = self:FindVariable("text_stage_desc")
	self.text_flsuh_cost = self:FindVariable("text_flsuh_cost")
	self.text_many_flsuh_cost = self:FindVariable("text_many_flsuh_cost")
	self.text_free_refresh_tiems = self:FindVariable("text_free_refresh_tiems")
	self.is_show_red_point = self:FindVariable("is_show_red_point")

	self.diamond_icon = self:FindObj("DiamondIcon")
	self.image_star_list = {}
	for i = 1, 8 do
		self.image_star_list[i] = self:FindObj("star" .. i)
	end

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
	self.item:SetData(nil)
end

function FlushSpiriLittleSkillView:ReleaseCallBack()
	self.image_star_list = {}
	self.text_skill_name = nil
	self.image_icon = nil
	self.text_stage_desc = nil
	self.text_flsuh_cost = nil
	self.text_many_flsuh_cost = nil
	self.diamond_icon = nil
	self.text_free_refresh_tiems = nil
	self.is_show_red_point = nil
	
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function FlushSpiriLittleSkillView:ShowIndexCallBack(index)
	self:Flush()
end

function FlushSpiriLittleSkillView:OnFlush(param_list)

	local sprite_info = SpiritData.Instance:GetSpiritInfo()
	-- 根据格子找技能的，不理解的问光展(其实格子相当于一个宝箱)
	local cur_cell_index = SpiritData.Instance:GetSkillViewCurCellIndex()
	local cell_info = sprite_info.skill_refresh_item_list[cur_cell_index]
	if nil == cell_info then
		print_error("cell_info is nil !!!")
		return
	end

	-- 阶段描述处理
	local refresh_count = cell_info.refresh_count
	local skill_refresh_cfg = SpiritData.Instance:GetSkliiFlsuhStageByTimes(refresh_count)
	self.text_stage_desc:SetValue(skill_refresh_cfg.desc or "")
	self.text_many_flsuh_cost:SetValue(skill_refresh_cfg.ten_gold or "")
	self.text_flsuh_cost:SetValue(skill_refresh_cfg.once_gold or "")

	-- 星星处理
	local stage = skill_refresh_cfg.stage or 0
	local show_star = stage + 1

	local star_width = 41
	local star_height = 39
	local max_count = skill_refresh_cfg.max_count or 0
	local min_count = skill_refresh_cfg.min_count or 0
	local cur_star_full_times = max_count - min_count
	local cur_star_flush_times = refresh_count - min_count
	local star_percent = cur_star_flush_times / cur_star_full_times
	local cur_star_width = star_width * star_percent

	for i, v in ipairs(self.image_star_list) do
		if i <= show_star then
			v:SetActive(true)
			if i == show_star then
				-- 当前的星星要做遮罩显示处理
				v.rect.sizeDelta = Vector2(cur_star_width, star_height)
			else
				v.rect.sizeDelta = Vector2(star_width, star_height)
			end
		else
			v:SetActive(false)
		end
	end

	-- 免费次数刷新
	local free_refresh_times = SpiritData.Instance:GetFreeFlushLeftTimes()
	if free_refresh_times > 0 then
		local desc = string.format(Language.JingLing.FreeRefreshTimes, free_refresh_times)
		self.text_free_refresh_tiems:SetValue(desc)
		self.diamond_icon:SetActive(false)
		self.text_flsuh_cost:SetValue("")
	else
		self.text_free_refresh_tiems:SetValue("")
		self.diamond_icon:SetActive(true)
		self.text_flsuh_cost:SetValue(skill_refresh_cfg.once_gold or "")
	end

	-- 图标处理
	-- 取第一个
	local skill_id = cell_info.skill_list[0]
	local skill_icon_bundle, skill_icon_asset = ResPath.GetSpiritSkillIcon("skill_" .. skill_id)
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	if nil ~= one_skill_cfg then
		local color = SOUL_NAME_COLOR[one_skill_cfg.skill_level]
		if color == "#00ff06" then
			color = "#00842c"
		end
		local skill_name = ToColorStr(one_skill_cfg.skill_name, color)
		self.text_skill_name:SetValue(skill_name)
		-- self.image_icon:SetAsset(skill_icon_bundle, skill_icon_asset)
		self.item:SetData({["item_id"] = one_skill_cfg.book_id})
	else
		self.text_skill_name:SetValue("")
		self.item:SetData(nil)
	end
	
	self.is_show_red_point:SetValue(free_refresh_times > 0)
end

function FlushSpiriLittleSkillView:FlsuhSkill()
	local cur_select_cell_index = SpiritData.Instance:GetSkillViewCurCellIndex()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, cur_select_cell_index, 0)
end

function FlushSpiriLittleSkillView:FlsuhManySkill()
	SpiritCtrl.Instance:OpenFlsuhSkillBigView()
	self:Close()
end

function FlushSpiriLittleSkillView:LearnSkill()
	-- local skill_index = 1
	local sprite_info = SpiritData.Instance:GetSpiritInfo()
	local cur_cell_index = SpiritData.Instance:GetSkillViewCurCellIndex()
	local cell_info = sprite_info.skill_refresh_item_list[cur_cell_index]
	local skill_id = cell_info.skill_list[0]
	if skill_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseFlushSkill)
		return
	end
	
	local cur_select_cell_index = SpiritData.Instance:GetSkillViewCurCellIndex()
	-- 技能 获取,param1 刷新索引,param2 技能索引
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_GET, cur_select_cell_index, 0)
	self:Close()
end