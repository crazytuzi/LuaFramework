--宠物商店
LittlePetShopView = LittlePetShopView or BaseClass(BaseRender)

local CellCount = 10							-- 转盘上面的奖励格子数量
local ModleNum = 2

function LittlePetShopView:__init()
	self.one_need_gold = 0
	self.ten_need_gold = 0
	self.choujiang_type = 0
	self.item_list = {}
	self.reward_data_list = {}
	self.is_rolling = false
	self.is_free = false
	
	self.power_right = self:FindVariable("Power1")
	self.power_left = self:FindVariable("Power2")
	self.one_time_gold = self:FindVariable("OneChouPrice")
	self.ten_time_gold = self:FindVariable("TenChouPrice")
	self.high_light_index = self:FindVariable("HightLinghtIndex")
	self.can_chou_one_times = self:FindVariable("IsCanChouJiang")
	self.show_free = self:FindVariable("ShowFreeTimes")

	self.red_point_list = {
		[RemindName.LittlePetWarehouse] = self:FindVariable("ShowWarehouseRedPoint"),
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self.center_pointer = self:FindObj("CenterPointer")
	self.play_ani_toggle = self:FindObj("PlayAniToggle").toggle
	self.play_ani_toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self))

	self:ListenEvent("OnClickOneChou", BindTool.Bind(self.OnClickOneChou, self))
	self:ListenEvent("OnClickTenChou", BindTool.Bind(self.OnClickTenChou, self))
	self:ListenEvent("OnClickHandleBook", BindTool.Bind(self.OnClickHandleBook, self))
	self:ListenEvent("OnClickWarehouse", BindTool.Bind(self.OnClickWarehouse, self))

	self:GetRewardData()
	self:InitModle()
	self:InitRewardItem()
end

function LittlePetShopView:__delete()
	if self.model_view_right ~= nil then
		self.model_view_right:DeleteMe()
		self.model_view_right = nil
	end

	if self.model_view_left ~= nil then
		self.model_view_left:DeleteMe()
		self.model_view_left = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	self.center_pointer = nil
end

function LittlePetShopView:OpenCallBack()
	self:RecoverData()
	self:GetRewardData()
	self:FlushModel()
	self:Flush()
end

function LittlePetShopView:CloseCallBack()
	self.choujiang_type = 0
	self.is_rolling = false
	
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
end

function LittlePetShopView:RemindChangeCallBack(remind_name, num)
	if self.red_point_list[remind_name] ~= nil then
		self.red_point_list[remind_name]:SetValue(num > 0)
		RemindManager.Instance:Fire(RemindName.LittlePetShop)
	end
end

function LittlePetShopView:InitModle()
	self.model_right = self:FindObj("Display1")
	self.model_view_right = RoleModel.New()
	self.model_view_right:SetDisplay(self.model_right.ui3d_display)

	self.model_left = self:FindObj("Display2")
	self.model_view_left = RoleModel.New()
	self.model_view_left:SetDisplay(self.model_left.ui3d_display)
end

function LittlePetShopView:InitRewardItem()
	for i = 1, CellCount do
		local handler = function()
			local close_call_back = function()
				self.item_list[i]:SetToggle(false)
				self.item_list[i]:ShowHighLight(false)
			end
			self.item_list[i]:SetToggle(true)
			self.item_list[i]:ShowHighLight(true)
			LittlePetCtrl.Instance:ShowShopPropTip(self.reward_data_list[i], close_call_back)
		end

		local data = {}
		data.item_id = self.reward_data_list[i] and self.reward_data_list[i].icon_pic

		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
		self.item_list[i]:SetData(data)
		self.item_list[i]:ListenClick(handler)
		table.insert(self.item_list, item)
	end
end

function LittlePetShopView:RecoverData()
	self.one_need_gold = 0
	self.ten_need_gold = 0
	self.choujiang_type = 0
	self.is_rolling = false
	self:RecoverPointer()
end

function LittlePetShopView:RecoverPointer()
	if self.center_pointer then
		self.center_pointer.transform.localRotation = Quaternion.Euler(0, 0, 0)
	end
end

function LittlePetShopView:GetRewardData()
	self.reward_data_list = LittlePetData.Instance:GetShopShowCfg() or {}
end

function LittlePetShopView:SetOneAndTenChouGold()
	local other_cfg = LittlePetData.Instance:GetOtherCfg()
	self.one_need_gold = other_cfg[1] and other_cfg[1].one_chou_consume_gold or 0
	self.ten_need_gold = other_cfg[1] and other_cfg[1].ten_chou_consume_gold or 0
	self.one_time_gold:SetValue(self.one_need_gold)
	self.ten_time_gold:SetValue(self.ten_need_gold)
end

function LittlePetShopView:FlushModel()
	local res_id_list = LittlePetData.Instance:GetShowRandomZhenXiUseImgId()
	if #res_id_list < ModleNum then return end 

	local bundle_1, asset_1 = ResPath.GetLittlePetModel(res_id_list[1].using_img_id)
	local bundle_2, asset_2 = ResPath.GetLittlePetModel(res_id_list[2].using_img_id)
	local power_1 = LittlePetData.Instance:CalPetBaseFightPower(false, res_id_list[1].active_item_id)
	local power_2 = LittlePetData.Instance:CalPetBaseFightPower(false, res_id_list[2].active_item_id)

	self.model_view_left:SetMainAsset(bundle_1, asset_1)
	self.model_view_right:SetMainAsset(bundle_2, asset_2)
	self.model_view_left:SetTrigger("rest")
	self.model_view_right:SetTrigger("rest")
	if self.ani_quest_time then
		GlobalTimerQuest:CancelQuest(self.ani_quest_time)
		self.ani_quest_time = nil
	end
	self.ani_quest_time = GlobalTimerQuest:AddRunQuest(function ()
		self.model_view_right:SetTrigger("rest")
		self.model_view_left:SetTrigger("rest")
	end, 10)

	self.power_left:SetValue(power_1)
	self.power_right:SetValue(power_2)
end

function LittlePetShopView:OnToggleChange(is_on)
	LittlePetData.Instance:SetChouJiangAniState(is_on)
end

function LittlePetShopView:GetChouJiangRewardByInfo()
	self:ClearChouJiangData()
	self:IsShowFree()
	self:TrunPointer()
end

function LittlePetShopView:ClearChouJiangData()
	self:SetHightLightState(-1)
end

function LittlePetShopView:SetHightLightState(index)
	local light_index = index or -1
	self.high_light_index:SetValue(light_index)
end

function LittlePetShopView:ShowRawardTip()
	if self.choujiang_type == LITTLE_PET_CHOUJIANG_TYPE.ONE then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_1)
	else
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_LITTLE_PET_MODE_10)
	end
end


function LittlePetShopView:IsCanChouJiang(price, choujiang_type)
	if self.is_rolling then
		TipsCtrl.Instance:ShowSystemMsg(Language.LittlePet.ShowChoujiangZhongTips)
		return false
	end

	if choujiang_type == LITTLE_PET_CHOUJIANG_TYPE.ONE and self.is_free then
		return true
	end

	local golo_enough = LittlePetData.Instance:GetChouJiangGoldIsEnough(price)
	if not golo_enough then
		TipsCtrl.Instance:ShowLackDiamondView()
		return false
	end

	return true
end

function LittlePetShopView:OnClickOneChou()
	local is_can_chou = self:IsCanChouJiang(self.one_need_gold, LITTLE_PET_CHOUJIANG_TYPE.ONE)
	if not is_can_chou then return end

	self:ClearChouJiangData()

	local chou_jiang_call_back = function()
		self.choujiang_type = LITTLE_PET_CHOUJIANG_TYPE.ONE
		LittlePetData.Instance:SetChouJiangAniState(self.play_ani_toggle.isOn)
		local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG
		local param1 = self.choujiang_type
		LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1)
	end

	if self.is_free then
		chou_jiang_call_back()
	else
		local need_gold = self.one_need_gold
		local tip_text = string.format(Language.LittlePet.TiShiOnce, need_gold)
		TipsCtrl.Instance:ShowCommonAutoView("pet_shop_chou_jiang", tip_text, chou_jiang_call_back)
	end
end

function LittlePetShopView:OnClickTenChou()
	local is_can_chou = self:IsCanChouJiang(self.ten_need_gold, LITTLE_PET_CHOUJIANG_TYPE.TEN)
	if not is_can_chou then return end

	self:ClearChouJiangData()
	local chou_jiang_call_back = function()
		self.choujiang_type = LITTLE_PET_CHOUJIANG_TYPE.TEN
		LittlePetData.Instance:SetChouJiangAniState(self.play_ani_toggle.isOn)
		local opera_type = LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_CHOUJIANG
		local param1 = self.choujiang_type
		LittlePetCtrl.Instance:SendLittlePetREQ(opera_type, param1, param2, param3)
	end
	local need_gold = self.ten_need_gold
	local tip_text = string.format(Language.LittlePet.TiShiTence, need_gold)
	TipsCtrl.Instance:ShowCommonAutoView("pet_shop_chou_jiang", tip_text, chou_jiang_call_back)

end

function LittlePetShopView:TrunPointer()
	if self.is_rolling then return end
	
	local angle_seq = LittlePetData.Instance:GetChouJiangAngleSeq()
	angle_seq = angle_seq == -1 and 0 or angle_seq
	local angle = -36 * angle_seq
	if self.play_ani_toggle.isOn then
		self.center_pointer.transform.localRotation = Quaternion.Euler(0, 0, angle)
		self:ChouJiangComplete(angle_seq)
		return
	end

	self.is_rolling = true
	local time = 0
	local tween = self.center_pointer.transform:DORotate(Vector3(0, 0, -360 * 20), 20, DG.Tweening.RotateMode.FastBeyond360)
	tween:SetEase(DG.Tweening.Ease.OutQuart)
	tween:OnUpdate(function ()
		time = time + UnityEngine.Time.deltaTime
		if time >= 1 then
			tween:Pause()
			local tween1 = self.center_pointer.transform:DORotate(Vector3(0, 0, -360 * 3 + angle), 2, DG.Tweening.RotateMode.FastBeyond360)
			tween1:OnComplete(function ()
				self:ChouJiangComplete(angle_seq)
			end)
		end
	end)
end

function LittlePetShopView:ChouJiangComplete(angle_seq)
	self.is_rolling = false
	self:SetHightLightState(angle_seq)
	self:ShowRawardTip()
end

function LittlePetShopView:OnFlush()
	self:IsShowFree()
	self:SetOneAndTenChouGold()
end

function LittlePetShopView:IsShowFree()
	self.is_free = LittlePetData.Instance:IsHaveFreeTimesByInfo()
	self.show_free:SetValue(self.is_free)
end

function LittlePetShopView:OnClickHandleBook()
	ViewManager.Instance:Open(ViewName.LittlePetHandleBookView)
end

function LittlePetShopView:OnClickWarehouse()
	ViewManager.Instance:Open(ViewName.LittlePetWarehouseView)
end