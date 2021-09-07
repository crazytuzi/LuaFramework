PlayerForgeView = PlayerForgeView or BaseClass(BaseRender)


function PlayerForgeView:__init(instance)
	self.item_list = {}
	self.is_check = true
end

function PlayerForgeView:__delete()

	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	-- if self.effect_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.effect_quest)
	-- 	self.effect_quest = nil
	-- end
end

function PlayerForgeView:LoadCallBack(instance)
	self:ListenEvent("OnClickForgeButton", BindTool.Bind(self.OnClickForgeButton, self))
	self:ListenEvent("OnClickAutoSelect", BindTool.Bind(self.OnClickAutoSelect, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	
	self.gong_ji = self:FindVariable("GongJi")
	self.bao_ji = self:FindVariable("BaoJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.kang_bao = self:FindVariable("KangBao")
	self.hp_value = self:FindVariable("HP")
	self.ming_zhong = self:FindVariable("MingZhong")
	self.po_jia = self:FindVariable("PoJia")
	self.shan_bi = self:FindVariable("ShanBi")

	self.next_gong_ji = self:FindVariable("NextGongJi")
	self.next_hp = self:FindVariable("NextHp")
	self.next_fang_yu = self:FindVariable("NextFangYu")

	self.exp_radio = self:FindVariable("ExpRadio")
	self.level= self:FindVariable("Level")
	self.poew_value = self:FindVariable("PowerValue")
	self.show_tips = self:FindVariable("ShowTips")

	self.prog_curr_value = self:FindVariable("ProgCurrValue")
	self.prog_next_value = self:FindVariable("ProgNextValue")
	self.max_level = self:FindVariable("MaxLevel")
	self.show_effect = self:FindVariable("ShowEffect")
	self.effect = self:FindVariable("Effect")
	self.effect:SetAsset("effects2/prefab/ui/jiaose_rongkin_prefab","jiaose_rongkin")
	self.show_effect:SetValue(true)
	self.is_check = PlayerForgeData.Instance:GetCheck()
	self.auto_check = self:FindObj("ToggleAutoSelect").toggle
	self.auto_check.isOn = self.is_check

	for i=1,8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("ItemCell"..i))
		self.item_list[i] = item
	end
	self:FlushForgeListData()
end

function PlayerForgeView:OnFlush(key)
	self:SetAttrData()
	self:FlushForgeListData()
end

-- 刷新可熔炼装备
function PlayerForgeView:UpItemCellData()
	local equip_list, count = PlayerForgeData.Instance:GetCurForgeEquipList()
	for i,v in ipairs(self.item_list) do
		v:SetData(equip_list[i])
		v:ListenClick(BindTool.Bind(self.OnClickEquipItem, self, i, equip_list[i], v))
	end
end

function PlayerForgeView:OnClickEquipItem(index, data, cell)
	if nil ~= data and nil ~= data.item_id then 
		TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_PLAYER_FORGE)
	end
	cell:SetHighLight(false)
end

function PlayerForgeView:OnClickForgeButton()
	if PlayerForgeData.Instance:GetIsMaxLevel() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.YiManJi)
		return
	end
	local equip_list, count = PlayerForgeData.Instance:GetCurForgeEquipList()
	if count > 0 then
		PlayerForgeCtrl.Instance:SendRonglianReq(count, equip_list)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoInputEquip)
	end
	-- self.show_effect:SetValue(true)
	-- if self.effect_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.effect_quest)
	-- 	self.effect_quest = nil
	-- end
	-- self.effect_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.EffectChangeTime, self), 3)
end

-- function PlayerForgeView:EffectChangeTime()
-- 	self.show_effect:SetValue(false)
-- 	if self.effect_quest then
-- 		GlobalTimerQuest:CancelQuest(self.effect_quest)
-- 		self.effect_quest = nil
-- 	end
-- end
function PlayerForgeView:OnClickAutoSelect()
	PlayerForgeData.Instance:SetCheck(self.auto_check.isOn)
	self:FlushForgeListData()
end

function PlayerForgeView:SetAttrData()
	self.max_level:SetValue(GameVoManager.Instance:GetMainRoleVo().level)
	local is_max_level = false
	local ronglu_info = PlayerForgeData.Instance:GetRongluInfo()
	if ronglu_info and ronglu_info.ronglu_level then
		local next_level = ronglu_info.ronglu_level + 1

		if PlayerForgeData.Instance:GetIsMaxLevel() then
			is_max_level = true
			next_level = ronglu_info.ronglu_level
		end
		local attr_cfg = PlayerForgeData.Instance:GetRongluAttrCfg(ronglu_info.ronglu_level)
		local next_attr_cfg = PlayerForgeData.Instance:GetRongluAttrCfg(next_level)


		if is_max_level then
			self.prog_curr_value:SetValue("-")
			self.prog_next_value:SetValue("-")
			self.exp_radio:InitValue(1 / 1)
		else
			if next_attr_cfg and next(next_attr_cfg) then
				self.prog_curr_value:SetValue(ronglu_info.ronglu_jingyan)
				self.prog_next_value:SetValue(next_attr_cfg.upgrade_need_jingyan)
				self.exp_radio:InitValue(ronglu_info.ronglu_jingyan / next_attr_cfg.upgrade_need_jingyan)
			end	
		end
		if next_attr_cfg then
			self.gong_ji:SetValue(attr_cfg and attr_cfg.c_gongji or 0)
			self.bao_ji:SetValue(attr_cfg and attr_cfg.c_baoji or 0)
			self.fang_yu:SetValue(attr_cfg and attr_cfg.c_fangyu or 0)
			self.kang_bao:SetValue(attr_cfg and attr_cfg.c_jianren or 0)
			self.hp_value:SetValue(attr_cfg and attr_cfg.c_maxhp or 0)
			self.ming_zhong:SetValue(attr_cfg and attr_cfg.c_mingzhong or 0)
			self.po_jia:SetValue("0")
			self.shan_bi:SetValue(attr_cfg and attr_cfg.c_shanbi or 0)

			self.next_gong_ji:SetValue(next_attr_cfg.c_gongji or 0)
			self.next_hp:SetValue(next_attr_cfg.c_maxhp or 0)
			self.next_fang_yu:SetValue(next_attr_cfg.c_fangyu or 0)

			self.level:SetValue(ronglu_info.ronglu_level)
			self.show_tips:SetValue(ronglu_info.ronglu_level >= GameVoManager.Instance:GetMainRoleVo().level)
			local attr = PlayerForgeData.Instance:GetForgeAttr(attr_cfg)
			local grade_power = CommonDataManager.GetCapabilityCalculation(attr)
			self.poew_value:SetValue(grade_power or 0)
		end
		
	end
end

function PlayerForgeView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(193)
end

function PlayerForgeView:FlushForgeListData()
	PlayerForgeData.Instance:GetForgeItemDataList()
	self:UpItemCellData()
end

function PlayerForgeView:ShowaddExp(info)
	local add_exp = info.delta
	if info.change_type == RONGLU_ADDEXP_TYPE.RONGLU_ADDEXP_TYPE_ROLE_EXP then
	elseif info.change_type == RONGLU_ADDEXP_TYPE.RONGLU_ADDEXP_TYPE_RONGLU then
	end
	if info.delta > 0 then
		TipsCtrl.Instance:ShowFloatingLabel(ToColorStr("+" .. add_exp, TEXT_COLOR.GOLD), 450, 75)
	end
end