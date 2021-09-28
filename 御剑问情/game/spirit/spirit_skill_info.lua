SpiritSkillInfo = SpiritSkillInfo or BaseClass(BaseView)

-- SpriteSkillView:从精灵所拥有的技能的技能网格点开
-- SpriteSkillStorageView:从精灵技能仓库点开
-- SpriteSkillView:从技能书背包网格点开
SpiritSkillInfo.FromView = {
	["SpriteSkillView"] = 1,
	["SpriteSkillStorageView"] = 2,
	["SpriteSkillBookBagView"] = 3,
}

function SpiritSkillInfo:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "SpriteSkillInfo"}
	self.play_audio = true
	self.from_view = SpiritSkillInfo.FromView.SpriteSkillView
end

function SpiritSkillInfo:__delete()

end

function SpiritSkillInfo:ReleaseCallBack()
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
	self.title = nil
	-- self.text_btn_copy = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SpiritSkillInfo:ShowIndexCallBack(index)
	self:Flush()
end

function SpiritSkillInfo:LoadCallBack()
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
	self.title = self:FindVariable("title")
	-- self.text_btn_copy = self:FindVariable("text_btn_copy")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickItemCell, self))

end

function SpiritSkillInfo:OnFlush()
	local is_show_btn_learn = self.from_view == SpiritSkillInfo.FromView.SpriteSkillBookBagView
								or self.from_view == SpiritSkillInfo.FromView.SpriteSkillStorageView

	self.bt_forget:SetActive(not is_show_btn_learn)
	self.bt_copy:SetActive(not is_show_btn_learn)
	self.bt_learn:SetActive(is_show_btn_learn)

	local is_show_item_cell = self.from_view == SpiritSkillInfo.FromView.SpriteSkillBookBagView
	self.is_show_skill_item:SetValue(not is_show_item_cell)
	self.is_show_item_cell:SetValue(is_show_item_cell)

	-- 从不同的地方打开 表内的数据是不一样的
	local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()
	if is_show_item_cell then
		self.item_cell:SetData({["item_id"] = cur_select_cell_data.item_id})
	else
		self.item_cell:SetData(nil)
	end
	self.item_cell:SetHighLight(false)

	local skill_id = 0
	local one_skill_cfg = nil
	if self.from_view == SpiritSkillInfo.FromView.SpriteSkillView or self.from_view == SpiritSkillInfo.FromView.SpriteSkillStorageView then
		skill_id = cur_select_cell_data.skill_id
		one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	elseif self.from_view == SpiritSkillInfo.FromView.SpriteSkillBookBagView then
		local item_id = cur_select_cell_data.item_id
		one_skill_cfg = SpiritData.Instance:GetOneSkillCfgByItemId(item_id)
		skill_id = one_skill_cfg.skill_id
	end

	if nil == one_skill_cfg then
		return
	end
	local skill_icon_bundle, skill_icon_asset = "", ""
	if skill_id > 0 then
		skill_icon_bundle, skill_icon_asset = ResPath.GetSpiritSkillIcon("skill_" .. skill_id)
	end
	self.image_skill_icon:SetAsset(skill_icon_bundle, skill_icon_asset)
	self.text_skill_desc:SetValue(one_skill_cfg.description or "")

	local color = ITEM_TIP_NAME_COLOR[one_skill_cfg.skill_level]
	local skill_name = ToColorStr(one_skill_cfg.skill_name, color)
	self.text_skill_name:SetValue(skill_name)

	local level_str = Language.JingLing.SkillLevel[one_skill_cfg.skill_level or 1]
	self.skill_level:SetValue(level_str)

	self.text_capacity:SetValue(one_skill_cfg.zhandouli)
	local bundle, asset = ResPath.GetTipsImageByIndex(one_skill_cfg.skill_level)
	self.title:SetAsset(bundle, asset)
end

function SpiritSkillInfo:SetFromView(view_tpye)
	self.from_view = view_tpye or SpiritSkillInfo.FromView.SpriteSkillView
end

function SpiritSkillInfo:OnForget()
	local cur_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex()
	local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()

	local skill_id = cur_select_cell_data.skill_id
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)

	local forget_item_id = one_skill_cfg.remove_stuff_id
	local forget_item_cfg = ItemData.Instance:GetItemConfig(forget_item_id)
	local have_num = ItemData.Instance:GetItemNumInBagById(forget_item_id)
	local color = have_num >= 1 and TEXT_COLOR.BLACK_1 or TEXT_COLOR.RED
	local item_color = ITEM_COLOR[forget_item_cfg.color]
	local skill_color = SPRITE_SKILL_LEVEL_COLOR[one_skill_cfg.skill_level]
	local des = string.format(Language.JingLing.IsForgetSkill,
						item_color, forget_item_cfg.name, skill_color, one_skill_cfg.skill_name, color, forget_item_cfg.name,TEXT_COLOR.BULE_NORMAL, have_num)

	if have_num > 0 then
		local function ok_callback()
			self:Close()
			-- 技能 遗忘,param1 精灵索引,param2 技能索引,param3 是否自动购买
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REMOVE_SKILL, cur_sprite_index, cur_select_cell_data.index, 0)
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, des, ok_callback)
	else
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REMOVE_SKILL, cur_sprite_index, cur_select_cell_data.index, 0)
	end
end

function SpiritSkillInfo:OnCopy()
	local cur_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex()
	local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()
	-- 这里要去拿最新的数据
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local cur_sprite_info = spirit_info.jingling_list[cur_sprite_index]
	local new_data = cur_sprite_info.param.jing_ling_skill_list[cur_select_cell_data.index]
	if new_data.can_move == 0 then
		SpiritCtrl.Instance:OpenSkillCopyView()
	else
		-- 技能 脱下,param1 精灵索引,param2 技能索引,param3 技能仓库索引
		local storage_index = SpiritData.Instance:GetStorageFirstNotSkillIndex()
		if nil == storage_index then
			SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SkillStorageFullSkill)
			return
		end
		
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_TAKE_OFF_SKILL, cur_sprite_index, new_data.index, storage_index)
		self:Close()
	end
	
end

function SpiritSkillInfo:OnLearn()
	local cur_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex()
	local sprite_skills_num = SpiritData.Instance:GetSpriteSkillNumBySpriteIndex(cur_sprite_index)
	local open_cell_num = SpiritData.Instance:GetSkillOpenNum(cur_sprite_index)
	local all_skill_num = SpiritData.Instance:GetMaxSkillCellNumByIndex(cur_sprite_index)

	if self.from_view == SpiritSkillInfo.FromView.SpriteSkillBookBagView then
		-- 技能书背包要先判断是否有前置技能
		local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()
		local stuff_item_id = cur_select_cell_data.item_id
		local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgByItemId(stuff_item_id)
		local skill_id = one_skill_cfg.skill_id

		local skill_index, has_per_skill = SpiritData.Instance:GetLearnSkillCellIndex(cur_sprite_index, skill_id)

		-- 没前置技能的话要判断下
		if not has_per_skill then
			if sprite_skills_num >= open_cell_num then
				local erro_str = sprite_skills_num < all_skill_num and Language.JingLing.SkillCellExpectOpen or Language.JingLing.SkillCellFullSkill
				SysMsgCtrl.Instance:ErrorRemind(erro_str)
				return
			end
		end

		local item_index = ItemData.Instance:GetItemIndex(stuff_item_id)
		-- param1 精灵索引,param2 技能索引,param3 物品索引
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_LEARN_SKILL, cur_sprite_index, skill_index, item_index)
	else
		if sprite_skills_num >= open_cell_num then
			local erro_str = sprite_skills_num < all_skill_num and Language.JingLing.SkillCellExpectOpen or Language.JingLing.SkillCellFullSkill
			SysMsgCtrl.Instance:ErrorRemind(erro_str)
			return
		end

		-- 技能仓库技能只需往后插
		local skill_index = SpiritData.Instance:GetFirstNotSkillCellIndex(cur_sprite_index)
		local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()
		local storage_cell_index = cur_select_cell_data.index or 0
		-- 技能 穿戴,param1 精灵索引,param2 技能索引,param3 技能仓库索引
		SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_PUT_ON_SKILL, cur_sprite_index, skill_index, storage_cell_index)
	end

	self:Close()
end

function SpiritSkillInfo:OnClickItemCell()
	self.item_cell:SetHighLight(false)
end