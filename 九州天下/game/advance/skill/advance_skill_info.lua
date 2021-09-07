AdvanceSkillInfoView = AdvanceSkillInfoView or BaseClass(BaseView)

-- SpriteSkillView:从精灵所拥有的技能的技能网格点开
-- SpriteSkillStorageView:从精灵技能仓库点开
-- SpriteSkillView:从技能书背包网格点开
AdvanceSkillInfoView.FromView = {
	["SpriteSkillView"] = 1,
	["SpriteSkillStorageView"] = 2,
	["SpriteSkillBookBagView"] = 3,
}

local PER_ATTR = {
	["maxhp"] = "maxhp_per",
	["gongji"] = "gongji_per",
	["fangyu"] = "fangyu_per",
}

function AdvanceSkillInfoView:__init()
	self.ui_config = {"uis/views/advanceview", "AdvanceSkillInfo"}
	self.play_audio = true
	self:SetMaskBg()
	self.from_view = AdvanceSkillInfoView.FromView.SpriteSkillView
end

function AdvanceSkillInfoView:__delete()

end

function AdvanceSkillInfoView:ReleaseCallBack()
	self.bt_forget = nil
	self.bt_copy = nil
	self.bt_learn = nil

	self.image_skill_icon = nil
	self.text_skill_desc = nil
	self.text_skill_name = nil
	self.is_show_skill_item = nil
	self.is_show_item_cell = nil
	self.skill_level = nil
	self.text_capacity = nil
	-- self.text_btn_copy = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function AdvanceSkillInfoView:ShowIndexCallBack(index)
	self:Flush()
end

function AdvanceSkillInfoView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnForget", BindTool.Bind(self.OnForget, self))
	self:ListenEvent("OnCopy", BindTool.Bind(self.OnCopy, self))
	self:ListenEvent("OnLearn", BindTool.Bind(self.OnLearn, self))

	self.bt_forget = self:FindObj("BtForget")
	self.bt_copy = self:FindObj("BtCopy")
	self.bt_learn = self:FindObj("BtLearn")

	self.image_skill_icon = self:FindVariable("image_skill_icon")
	self.text_skill_desc = self:FindVariable("text_skill_desc")
	self.text_skill_name = self:FindVariable("text_skill_name")
	self.is_show_skill_item = self:FindVariable("is_show_skill_item")
	self.is_show_item_cell = self:FindVariable("is_show_item_cell")
	self.skill_level = self:FindVariable("skill_level")
	self.text_capacity = self:FindVariable("text_capacity")
	-- self.text_btn_copy = self:FindVariable("text_btn_copy")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickItemCell, self))
end

function AdvanceSkillInfoView:OnFlush()
	if self.from_view == nil then
		return
	end

	local is_show_btn_learn = self.from_view == AdvanceSkillInfoView.FromView.SpriteSkillBookBagView
								or self.from_view == AdvanceSkillInfoView.FromView.SpriteSkillStorageView

	self.bt_forget:SetActive(not is_show_btn_learn)
	self.bt_copy:SetActive(not is_show_btn_learn)
	self.bt_learn:SetActive(is_show_btn_learn)

	local is_show_item_cell = self.from_view == AdvanceSkillInfoView.FromView.SpriteSkillBookBagView
	self.is_show_skill_item:SetValue(not is_show_item_cell)
	self.is_show_item_cell:SetValue(is_show_item_cell)

	-- 从不同的地方打开 表内的数据是不一样的
	local cur_select_cell_data = AdvanceSkillData.Instance:GetSpiritSkillViewCellData()
	if cur_select_cell_data == nil or next(cur_select_cell_data) == nil then
		return
	end

	if is_show_item_cell then
		self.item_cell:SetData({["item_id"] = cur_select_cell_data.item_id})
	else
		self.item_cell:SetData(nil)
	end
	self.item_cell:SetHighLight(false)

	local skill_id = 0
	local one_skill_cfg = nil
	if self.from_view == AdvanceSkillInfoView.FromView.SpriteSkillView or self.from_view == AdvanceSkillInfoView.FromView.SpriteSkillStorageView then
		skill_id = cur_select_cell_data.skill_id
		one_skill_cfg = AdvanceSkillData.Instance:GetOneSkillCfgBySkillId(skill_id)
	elseif self.from_view == AdvanceSkillInfoView.FromView.SpriteSkillBookBagView then
		local item_id = cur_select_cell_data.item_id
		one_skill_cfg = AdvanceSkillData.Instance:GetOneSkillCfgByItemId(item_id)
		if one_skill_cfg ~= nil and next(one_skill_cfg) ~= nil then
			skill_id = one_skill_cfg.skill_id
		end
	end

	if nil == one_skill_cfg then
		return
	end
	local skill_icon_bundle, skill_icon_asset = "", ""
	if skill_id > 0 then
		skill_icon_bundle, skill_icon_asset = ResPath.GetAdvanceEquipIcon("skill_" .. skill_id)
	end
	self.image_skill_icon:SetAsset(skill_icon_bundle, skill_icon_asset)
	self.text_skill_desc:SetValue(one_skill_cfg.description or "")

	local color = ADVANCE_SKILL_LEVEL_COLOR[one_skill_cfg.skill_level]
	local skill_name = ToColorStr(one_skill_cfg.skill_name, color)
	self.text_skill_name:SetValue(skill_name)

	local level_str = Language.Advance.SkillLevel[one_skill_cfg.skill_level or 1]
	self.skill_level:SetValue(level_str)

	local show_type = AdvanceSkillCtrl.Instance:GetShowType()
	if show_type then
		local grade_cfg = AdvanceSkillData:GetGradeCfgByType(show_type)
		if one_skill_cfg ~= nil and grade_cfg ~= nil and next(grade_cfg) ~= nil then
			local attr = CommonDataManager.GetAttributteNoUnderline(one_skill_cfg)
			for k,v in pairs(PER_ATTR) do
				if attr[k] ~= nil and one_skill_cfg[v] ~= nil and grade_cfg[k] ~= nil then
					attr[k] = attr[k] + math.ceil(0.0001 * one_skill_cfg[v] * grade_cfg[k]) 
				end
			end

			local cap = CommonDataManager.GetCapability(attr)
			self.text_capacity:SetValue(cap)
		end
	end

	-- self.text_capacity:SetValue(one_skill_cfg.zhandouli)
end

function AdvanceSkillInfoView:SetFromView(view_tpye)
	self.from_view = view_tpye or AdvanceSkillInfoView.FromView.SpriteSkillView
end

function AdvanceSkillInfoView:OnForget()
	local cur_sprite_index = AdvanceSkillData.Instance:GetCurAdvanceType()
	local cur_select_cell_data = AdvanceSkillData.Instance:GetSpiritSkillViewCellData()
	if cur_select_cell_data == nil or next(cur_select_cell_data) == nil then
		return
	end

	local skill_id = cur_select_cell_data.skill_id
	local one_skill_cfg = AdvanceSkillData.Instance:GetOneSkillCfgBySkillId(skill_id)
	if one_skill_cfg == nil and next(one_skill_cfg) == nil then
		return
	end

	local forget_item_id = one_skill_cfg.remove_stuff_id
	local forget_item_cfg = ItemData.Instance:GetItemConfig(forget_item_id)
	local have_num = ItemData.Instance:GetItemNumInBagById(forget_item_id)
	local color = have_num >= 1 and TEXT_COLOR.GREEN or TEXT_COLOR.RED
	local item_color = ITEM_COLOR[forget_item_cfg.color]
	local skill_color = ADVANCE_SKILL_LEVEL_COLOR[one_skill_cfg.skill_level]
	local des = string.format(Language.Advance.IsForgetSkill,
						item_color, forget_item_cfg.name, skill_color, one_skill_cfg.skill_name, color, forget_item_cfg.name, have_num)

	if have_num > 0 then
		local function ok_callback()
			self:Close()
			-- 技能 遗忘,param1 精灵索引,param2 技能索引,param3 是否自动购买
			if cur_sprite_index ~= nil then
				AdvanceSkillCtrl.Instance:SendAdvanceSkillOpera(JINGLING_OPER_TYPE.JINGLING_OPER_REMOVE_SKILL, cur_sprite_index - 1, cur_select_cell_data.index, 0)
			end
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback)
	else
		if cur_sprite_index ~= nil then
			AdvanceSkillCtrl.Instance:SendAdvanceSkillOpera(JINGLING_OPER_TYPE.JINGLING_OPER_REMOVE_SKILL, cur_sprite_index - 1, cur_select_cell_data.index, 0)
		end
	end
end

function AdvanceSkillInfoView:OnCopy()
	local cur_sprite_index = AdvanceSkillData.Instance:GetCurAdvanceType()
	local cur_select_cell_data = AdvanceSkillData.Instance:GetSpiritSkillViewCellData()

	if cur_select_cell_data == nil or next(cur_select_cell_data) == nil then
		return
	end
	-- 这里要去拿最新的数据
	local spirit_info = AdvanceSkillData.Instance:GetAdvanceSkillInfo()
	if spirit_info == nil or spirit_info.image_skills == nil then
		return
	end

	local cur_info = spirit_info.image_skills[cur_sprite_index]
	if cur_info == nil or next(cur_info) == nil then
		return
	end

	local cur_sprite_info = cur_info[cur_select_cell_data.index + 1]
	if cur_sprite_info == nil or next(cur_sprite_info) == nil then
		return
	end

	if cur_sprite_info.can_move == 0 then
		--AdvanceSkillCtrl.Instance:OpenSkillCopyView()
		ViewManager.Instance:Open(ViewName.AdvanceSkillCopyView)
	else
		-- 技能 脱下,param1 精灵索引,param2 技能索引,param3 技能仓库索引
		local storage_index = AdvanceSkillData.Instance:GetStorageFirstNotSkillIndex()
		if nil == storage_index then
			SysMsgCtrl.Instance:ErrorRemind(Language.Advance.SkillStorageFullSkill)
			return
		end

		AdvanceSkillCtrl.Instance:SendAdvanceSkillOpera(JINGLING_OPER_TYPE.JINGLING_OPER_TAKE_OFF_SKILL, cur_sprite_index - 1, cur_sprite_info.index, storage_index)
		self:Close()
	end
	
end

function AdvanceSkillInfoView:OnLearn()
	local cur_sprite_index = AdvanceSkillData.Instance:GetCurAdvanceType()
	if cur_sprite_index == nil then
		return
	end

	local sprite_skills_num = AdvanceSkillData.Instance:GetAdvanceSkillNumByType(cur_sprite_index)
	local open_cell_num = AdvanceSkillData.Instance:GetSkillOpenNum(cur_sprite_index)
	local all_skill_num = AdvanceSkillData.Instance:GetMaxSkillCellNumByIndex(cur_sprite_index)

	if self.from_view == AdvanceSkillInfoView.FromView.SpriteSkillBookBagView then
		-- 技能书背包要先判断是否有前置技能
		local cur_select_cell_data = AdvanceSkillData.Instance:GetSpiritSkillViewCellData()
		if cur_select_cell_data == nil or next(cur_select_cell_data) == nil then
			return
		end

		local stuff_item_id = cur_select_cell_data.item_id
		local one_skill_cfg = AdvanceSkillData.Instance:GetOneSkillCfgByItemId(stuff_item_id)
		if one_skill_cfg == nil or one_skill_cfg.skill_id == nil then
			return
		end

		local skill_id = one_skill_cfg.skill_id
		local skill_index, has_per_skill = AdvanceSkillData.Instance:GetLearnSkillCellIndex(cur_sprite_index, skill_id)

		-- 没前置技能的话要判断下
		if not has_per_skill then
			if sprite_skills_num >= open_cell_num then
				local erro_str = sprite_skills_num < all_skill_num and Language.Advance.SkillCellExpectOpen or Language.Advance.SkillCellFullSkill
				SysMsgCtrl.Instance:ErrorRemind(erro_str)
				return
			end
		end

		local item_index = ItemData.Instance:GetItemIndex(stuff_item_id)
		-- param1 精灵索引,param2 技能索引,param3 物品索引
		AdvanceSkillCtrl.Instance:SendAdvanceSkillOpera(JINGLING_OPER_TYPE.JINGLING_OPER_LEARN_SKILL, cur_sprite_index - 1, skill_index, item_index)
	else
		if sprite_skills_num >= open_cell_num then
			local erro_str = sprite_skills_num < all_skill_num and Language.Advance.SkillCellExpectOpen or Language.Advance.SkillCellFullSkill
			SysMsgCtrl.Instance:ErrorRemind(erro_str)
			return
		end

		-- 技能仓库技能只需往后插
		local skill_index = AdvanceSkillData.Instance:GetFirstNotSkillCellIndex(cur_sprite_index)
		local cur_select_cell_data = AdvanceSkillData.Instance:GetSpiritSkillViewCellData()
		local storage_cell_index = cur_select_cell_data.index or 0
		-- 技能 穿戴,param1 精灵索引,param2 技能索引,param3 技能仓库索引
		if skill_index ~= nil then
			AdvanceSkillCtrl.Instance:SendAdvanceSkillOpera(JINGLING_OPER_TYPE.JINGLING_OPER_PUT_ON_SKILL, cur_sprite_index - 1, skill_index, storage_cell_index)
		end
	end

	self:Close()
end

function AdvanceSkillInfoView:OnClickItemCell()
	self.item_cell:SetHighLight(false)
end