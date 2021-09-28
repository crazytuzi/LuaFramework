LittlePetSpecialItemTips = LittlePetSpecialItemTips or BaseClass(BaseView)
function LittlePetSpecialItemTips:__init()
    self.ui_config = {"uis/views/littlepetview_prefab", "SpecialPetItemTips"}
    self.play_audio = true
    self.view_layer = UiLayer.Pop
end

function LittlePetSpecialItemTips:__delete()
end

function LittlePetSpecialItemTips:ReleaseCallBack()
	self:RemoveCountDown()
	self:RemoveTimerQuest()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.equip_name = nil
	for k,v in pairs(self.attr_list) do
		v = nil
	end
	self.attr_list = nil
	self.fight_power = nil
	self.free_time = nil
	self.btn_text = nil
	self.cost = nil
	self.is_active = nil
	self.require = nil
	self.quality = nil
	self.is_free = nil
	self.is_show_red = nil
	self.is_can_get = nil
	self.display = nil

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function LittlePetSpecialItemTips:LoadCallBack()
	self.equip_name = self:FindVariable("EquipName")
	self.attr_list = {}
	self.attr_list.attr_0 = self:FindVariable("AttrAtack")
	self.attr_list.attr_1 = self:FindVariable("AttrHp")
	self.attr_list.attr_2 = self:FindVariable("AttrDefence")
	self.attr_list.special_attr = self:FindVariable("SpecialEffect")
	self.fight_power = self:FindVariable("FightPower")
	self.free_time = self:FindVariable("FreeTime")
	self.btn_text = self:FindVariable("BtnText")
	self.cost = self:FindVariable("Cost")
	self.is_active = self:FindVariable("IsActive")
	self.require = self:FindVariable("Require")
	self.quality = self:FindVariable("Quality")
	self.is_free = self:FindVariable("IsFree")
	self.is_show_red = self:FindVariable("IsShowRed")
	self.is_can_get = self:FindVariable("IsCanGet")

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	self.display = self:FindObj("Display")
	self.model = RoleModel.New("little_pet_item_tips_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self:ListenEvent("ClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("ClickActive", BindTool.Bind(self.OnClickActive, self))
end

function LittlePetSpecialItemTips:SetCloseCallBack()
end

function LittlePetSpecialItemTips:OpenCallBack()
	self:Flush()
end

function LittlePetSpecialItemTips:CloseCallBack()
end

function LittlePetSpecialItemTips:OnFlush()
	self:FlushContent()
end

function LittlePetSpecialItemTips:FlushContent()
	local special_pet_all_cfg = LittlePetData.Instance:GetSpecialLittlePetAllCfg()
	if special_pet_all_cfg == nil then
		return
	end

	-- 模型显示
	self:FlushModel(special_pet_all_cfg.active_item_id)

	self.cost:SetValue(special_pet_all_cfg.buy_special_pet_need_gold)
	self.item:SetData({item_id = special_pet_all_cfg.active_item_id})
	self.item:SetInteractable(false)

	local item_cfg = ItemData.Instance:GetItemConfig(special_pet_all_cfg.active_item_id)
	if item_cfg == nil then
		return
	end
	local quality = item_cfg.color or 1
	self.equip_name:SetValue(ToColorStr(item_cfg.name, ITEM_TIP_NAME_COLOR[quality]))
	local bundle, sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	self.quality:SetAsset(bundle, sprite)

	-- 属性显示
	local attr_list = special_pet_all_cfg.attr_list
	self.attr_list.attr_0:SetValue(attr_list.attr_value_0 or 0)
	self.attr_list.attr_1:SetValue(attr_list.attr_value_1 or 0)
	self.attr_list.attr_2:SetValue(attr_list.attr_value_2 or 0)
	self.attr_list.special_attr:SetValue(attr_list.attr_addition / 100)

	-- 战力显示
	local capability = LittlePetData.Instance:GetSpecialLittlePetPower(false)
	self.fight_power:SetValue(capability)

	-- 激活状态
	local is_can_received = LittlePetData.Instance:GetIsCanReceivePetFlag(0)
	local is_got = LittlePetData.Instance:GetIsReceivedFlagFromServer()
	local is_active = LittlePetData.Instance:GetSpecialPetIsActive()
	local is_in_bag = LittlePetData.Instance:GetSpecialPetIsInBag()

	self.is_show_red:SetValue(false)
	if is_can_received == 1 and is_got ~= 1 and is_active ~= 1 then
		self.is_show_red:SetValue(true)
	end
	if is_got == 1 and is_in_bag == 1 then
		self.is_show_red:SetValue(true)
	end

	if is_active == 1 then
		self.is_active:SetValue(true)
		return
	else
		self.is_active:SetValue(false)
		if is_got == 1 then
			self.is_can_get:SetValue(true)
			self.btn_text:SetValue(Language.LittlePet.SpecialTipsBtnText3)
		elseif is_can_received == 1 then
			self.is_can_get:SetValue(true)
			self.btn_text:SetValue(Language.LittlePet.SpecialTipsBtnText2)
		else
			self.is_can_get:SetValue(false)
			self.btn_text:SetValue(Language.LittlePet.SpecialTipsBtnText1)
		end
	end

	-- 时间倒计时
	local free_remind_time = LittlePetData.Instance:GetSpecialPetRemainFreeTime()
	if free_remind_time <= 0 then
		self.is_free:SetValue(false)
	else
		self:RemoveCountDown()
		self.count_down = CountDown.Instance:AddCountDown(free_remind_time, 1, BindTool.Bind(self.FlushCountDown, self))
	end
end

function LittlePetSpecialItemTips:RemoveCountDown()
	--释放计时器
	if CountDown.Instance:HasCountDown(self.count_down) then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function LittlePetSpecialItemTips:FlushCountDown(elapse_time, total_time)
	local time_interval = total_time - elapse_time
	if time_interval > 0 then
		self:SetTime(time_interval)
	else
		self.is_free:SetValue(false)
	end
end

--设置时间
function LittlePetSpecialItemTips:SetTime(time)
	local show_time_str = ""
	if time > 3600 * 24 then
		show_time_str = TimeUtil.FormatSecond(time, 7)
	elseif time > 3600 then
		show_time_str = TimeUtil.FormatSecond(time, 1)
	else
		show_time_str = TimeUtil.FormatSecond(time, 4)
	end
	self.free_time:SetValue(show_time_str)
end

function LittlePetSpecialItemTips:FlushRightFrame()
end

function LittlePetSpecialItemTips:OnClickClose()
	self:Close()
end

function LittlePetSpecialItemTips:OnClickActive()
	local other_cfg = LittlePetData.Instance:GetOtherCfg()
	if next(other_cfg) == nil then
		return
	end

	local is_can_received = LittlePetData.Instance:GetIsCanReceivePetFlag(0)
	local is_got = LittlePetData.Instance:GetIsReceivedFlag()
	local is_active = LittlePetData.Instance:GetSpecialPetIsActive()

	-- 购买
	if is_can_received == 0 and is_got == 0 and is_active == 0 then
		local cost_gold = other_cfg[1].buy_special_pet_need_gold or 0
		local ok_fun = function ()
			local vo = GameVoManager.Instance:GetMainRoleVo()
			if vo.gold < cost_gold then
				TipsCtrl.Instance:ShowLackDiamondView()
				return
			else
				-- 购买特殊小宠物时默认param1为0，即购买index为0的小宠物，因为目前只有一个特殊小宠物，没有选择index
				LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTEL_PET_BUY_SPECIAL_PET, 0)
			end
		end
		local tips_text = string.format(Language.LittlePet.BuySpecialTips, cost_gold)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, tips_text)
		return
	end

	-- 领取
	if is_can_received == 1 and is_got == 0 and is_active == 0 then
		LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTEL_PET_RECEIVED_PET, 0)
		return
	end

	-- 激活
	if is_got == 1 and is_active == 0 then
		local item_id = LittlePetData.Instance:GetSpecialLittlePetItemID()
		local index = ItemData.Instance:GetItemIndex(item_id)
		if index < 0 then
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			if item_cfg == nil then
				return
			end
			TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Common.ActivedErrorTips, item_cfg.name))
		else
			-- 激活超级小宠物，默认放在宠物位置第6位
			LittlePetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_PUTON, GameEnum.LITTLE_PET_SPECIAL_INDEX - 1, index)
		end
	end
end

-- 刷新模型
function LittlePetSpecialItemTips:FlushModel(item_id)
	if self.display ~= nil then
		self.display.ui3d_display:ResetRotation()
	end

	local res_id = LittlePetData.Instance:GetLittlePetResIDByItemID(item_id)
	local asset, bundle = ResPath.GetLittlePetModel(res_id)
	self.model:SetMainAsset(asset, bundle)

	self.model:SetTrigger("Relax")
	self:RemoveTimerQuest()
	self.ani_quest_time = GlobalTimerQuest:AddRunQuest(function ()
		self.model:SetTrigger("Relax")
		end, 10)
end

function LittlePetSpecialItemTips:RemoveTimerQuest()
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
end