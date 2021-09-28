SpiritSkillCopy = SpiritSkillCopy or BaseClass(BaseView)

function SpiritSkillCopy:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "SkillCopyView"}
	self.play_audio = true
end

function SpiritSkillCopy:__delete()

end

function SpiritSkillCopy:ReleaseCallBack()
	self.image_skill_icon = nil
	self.text_item_cost = nil
	self.text_skill_name = nil

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	self.item_data_event = nil
end

function SpiritSkillCopy:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnOkFunc", BindTool.Bind(self.OnOkFunc, self))

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self.image_skill_icon = self:FindVariable("image_skill_icon")
	self.text_item_cost = self:FindVariable("text_item_cost")
	self.text_skill_name = self:FindVariable("text_skill_name")
end

function SpiritSkillCopy:ShowIndexCallBack(index)
	self:Flush()
end

function SpiritSkillCopy:OnFlush()
	-- 从不同的地方打开 表内的数据是不一样的
	local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()
	local skill_id = cur_select_cell_data.skill_id
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	if nil == one_skill_cfg then
		return
	end
	-- 图标设置
	local skill_icon_bundle, skill_icon_asset = "", ""
	if skill_id > 0 then
		skill_icon_bundle, skill_icon_asset = ResPath.GetSpiritSkillIcon("skill_" .. skill_id)
	end
	self.image_skill_icon:SetAsset(skill_icon_bundle, skill_icon_asset)

	-- 物品文本显示
	local desc = ""
	if cur_select_cell_data.can_move == 0 then
		local copy_item_id = one_skill_cfg.move_stuff_id
		local copy_item_cfg = ItemData.Instance:GetItemConfig(copy_item_id)
		local have_num = ItemData.Instance:GetItemNumInBagById(copy_item_id)
		local color = have_num >= 1 and TEXT_COLOR.BULE_NORMAL or TEXT_COLOR.RED_4
		des = string.format(Language.JingLing.CopyItemCost, color, have_num)
	else
		des = Language.JingLing.HasCopy
	end
	self.text_item_cost:SetValue(des)
	-- 技能名字显示
	local color = SPRITE_SKILL_LEVEL_COLOR[one_skill_cfg.skill_level]
	local copy_item_name = ToColorStr(one_skill_cfg.skill_name, color)
	self.text_skill_name:SetValue(copy_item_name)

end

function SpiritSkillCopy:OnOkFunc()
	local cur_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex()
	local cur_select_cell_data = SpiritData.Instance:GetSpiritSkillViewCellData()

	local skill_id = cur_select_cell_data.skill_id
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	local copy_item_id = one_skill_cfg.move_stuff_id
	local have_num = ItemData.Instance:GetItemNumInBagById(copy_item_id)
	
	if have_num >= 1 then
		SpiritCtrl.Instance:CloseSkillInfoView()
		self:Close()
	end

	-- 技能 变成可移动,param1 精灵索引,param2 技能索引,param3 是否自动购买
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_CHANGE_MOVE, cur_sprite_index, cur_select_cell_data.index, 0)
end

-- 物品不足，购买成功后刷新物品数量
function SpiritSkillCopy:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:Flush()
end