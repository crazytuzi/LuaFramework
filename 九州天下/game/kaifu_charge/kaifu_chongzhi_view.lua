KaiFuChongZhiView = KaiFuChongZhiView or BaseClass(BaseView)

function KaiFuChongZhiView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/kaifuchargeview","QiTianChongZhi"}
	self.select_seq = 0
 	self.item_list = {}
 	self.flush_list = true
end

function KaiFuChongZhiView:__delete()

end

function KaiFuChongZhiView:ReleaseCallBack()

	if self.chongzhi_cell_list then
		for k,v in pairs(self.chongzhi_cell_list) do
			v:DeleteMe()
		end
		self.chongzhi_cell_list = {}
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.reward_model ~= nil then
		self.reward_model:DeleteMe()
		self.reward_model = nil
	end

	self.money_num = nil
	self.activity_time = nil
	self.rest_hour = nil
	self.rest_min = nil
	self.rest_sec = nil
	self.rest_day = nil
	self.is_get_all_reward = nil
	self.display = nil
	self.chongzhi_scroller = nil
	self.model_bg = nil
	self.show_model_bg = nil
	self.show_reward_btn = nil
	self.get_reward = nil
	self.is_get_reward = nil
	self.cap_show = nil

	if self.equip_bg_effect_obj  ~= nil then
		GameObject.Destroy(self.equip_bg_effect_obj)
		self.equip_bg_effect_obj = nil
	end
	
	self.model_effect = nil
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.need_money = nil
	self.flush_list = true
end

function KaiFuChongZhiView:LoadCallBack()
	self:ListenEvent("ClickBuy", BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("ClickGetReward", BindTool.Bind(self.ClickGetReward, self))
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))

	self.money_num = self:FindVariable("MoneyNum")
	self.activity_time = self:FindVariable("ActivityTime")
	self.rest_hour = self:FindVariable("RestHour")
	self.rest_min = self:FindVariable("RestMin")
	self.rest_sec = self:FindVariable("RestSecond")
	self.rest_day = self:FindVariable("RestDay")
	self.is_get_all_reward = self:FindVariable("IsGetAllReward")
	self.model_bg = self:FindVariable("Model_Bg")
	self.show_model_bg = self:FindVariable("Show_Model_Bg")
	self.show_reward_btn = self:FindVariable("Show_Reward_Btn")
	self.get_reward = self:FindVariable("GetReward")
	self.is_get_reward = self:FindVariable("IsGetReward")
	self.display = self:FindObj("Display")
	self.is_get_all_reward:SetValue(false)
	self.cap_show = self:FindVariable("FightNum")
	self.model_effect = self:FindObj("model_effect")

	for i = 1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("RewardItem" .. i))
	end
	self.need_money = self:FindVariable("NeedMoney")

	self.reward_model = RoleModel.New()
	self:ChongZhiScroller()
	self:OpenCallBack()

end

function KaiFuChongZhiView:OnClickBuy()
	local money_num = KaiFuChargeData.Instance:GetSevenDayChongZhiMoney()
	local select_data = KaiFuChargeData.Instance:GetChongZhiSeqCfg(self.select_seq)
	if select_data and money_num >= select_data.need_chongzhi then
		KaiFuChargeCtrl.Instance:SendOpenGameActivityFetchReward(SUPER_REWARD_TYPE.REWARD_TYPE_SEVEN_DAY_TOTAL_CHONGZHI, self.select_seq)
	else
		MainUICtrl.Instance:OpenRecharge()
	end
end

function KaiFuChongZhiView:ClickGetReward()
	KaiFuChargeCtrl.Instance:SendOpenGameActivityFetchReward(SUPER_REWARD_TYPE.REWARD_TYPE_SEVEN_DAY_TOTAL_CHONGZHI, self.select_seq)
	self.flush_list = true
end

function KaiFuChongZhiView:CloseView()
	self:Close()
end

function KaiFuChongZhiView:OpenCallBack()
	local end_act_day = GameEnum.NEW_SERVER_DAYS - TimeCtrl.Instance:GetCurOpenServerDay() + 1
	-- if end_act_day == 0 then
		local time_table = os.date('*t',TimeCtrl.Instance:GetServerTime())
		local cur_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
		local reset_time_s = 24 * 3600 - cur_time
		local day_time_s = (24 * end_act_day) * 3600 - cur_time
		self:SetRestTime(reset_time_s,day_time_s)
	-- else
		-- self.rest_day:SetValue(end_act_day)
	-- end

	self:FlushChongZhiInfo()
	self:Flush()
	KaiFuChargeData.Instance:QiTianOpen()
	RemindManager.Instance:Fire(RemindName.KaiFuChongZhiItem)
end

function KaiFuChongZhiView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function KaiFuChongZhiView:SetRestTime(diff_time,day_time_s)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
				end
				return
			end
			local left_day = math.floor(day_time_s / 3600 / 24)
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.rest_hour:SetValue(left_hour)
			self.rest_min:SetValue(left_min)
			self.rest_sec:SetValue(left_sec)
			self.rest_day:SetValue(left_day)
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

-- 七天充值
function KaiFuChongZhiView:ChongZhiScroller()
	self.chongzhi_cell_list = {}
	self.chongzhi_scroller = self:FindObj("ChongZhiScroller")
	local delegate = self.chongzhi_scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #KaiFuChargeData.Instance:GetSevenDayChongZhiAuto()
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index)
		data_index = data_index + 1

		local target_cell = self.chongzhi_cell_list[cell]

		if nil == target_cell then
			self.chongzhi_cell_list[cell] = ChongZhiCell.New(cell.gameObject, self)
			target_cell = self.chongzhi_cell_list[cell]
			-- target_cell.mother_view = self
		end
		local data = KaiFuChargeData.Instance:GetSortSevendayConfig()
		local cell_data = data[data_index]
		target_cell:SetIndex(data_index)
		target_cell:SetData(cell_data)
		self:FlushAllHl()
	end
end

function KaiFuChongZhiView:OnFlush()
	local money_num = KaiFuChargeData.Instance:GetSevenDayChongZhiMoney()

	if money_num then
		self.money_num:SetValue(money_num)
	else
		self.is_get_all_reward:SetValue(true)
	end

	if self.chongzhi_cell_list and self.flush_list then
		local data = KaiFuChargeData.Instance:GetSortSevendayConfig()
		self.select_seq = data[1].seq
		self:FlushChongZhiInfo()
		self.chongzhi_scroller.scroller:ReloadData(0)
		self.flush_list = false
	end

	local flag = KaiFuChargeData.Instance:GetQiTianChongzhiRewardFlagByIndex(self.select_seq)
	self.get_reward:SetValue(flag == 0 and Language.Common.LingQu or Language.Common.YiLingQu)
	self.is_get_reward:SetValue(flag == 0)
	-- local chong_cfg = KaiFuChargeData.Instance:GetogaSevenTotalChongzhiNum()
	-- local c_model = KaiFuChargeData.Instance:GetModelNumBerByChongZhi(chong_cfg)
	-- local model_str = ""
	-- if c_model < 10 then
	-- 	model_str = "000" .. c_model
	-- else
	-- 	model_str = "00" .. c_model
	-- end
	-- self.reward_model:SetDisplay(self.display.ui3d_display)
	-- local bundle, asset = ResPath.GetModelAsset("item", model_str)
	-- self.reward_model:SetMainAsset(bundle, asset)
end

function KaiFuChongZhiView:SetSelectIndex(index)
	self.select_seq = index
	self:FlushChongZhiInfo()
	self:Flush()
end

function KaiFuChongZhiView:FlushAllHl()
	for k,v in pairs(self.chongzhi_cell_list) do
		v:FlushHl()
	end
end

function KaiFuChongZhiView:GetSelectIndex()
	return self.select_seq
end

function KaiFuChongZhiView:FlushChongZhiInfo()
	local chongzhi_num = KaiFuChargeData.Instance:GetogaSevenTotalChongzhiNum()
	local select_data = KaiFuChargeData.Instance:GetChongZhiSeqCfg(self.select_seq)
	--local giftItemList = ItemData.Instance:GetGiftItemList(select_data.reward_item.item_id)
	local giftItemList = select_data.reward_item
	for i = 1, 3 do
		self.item_list[i]:SetData({item_id = giftItemList[i -1].item_id , num = giftItemList[i -1].num , is_bind = giftItemList[i -1].is_bind})
		if i == 1 then
			self.item_list[i]:SetActivityEffect()
		end
	end

	self.show_reward_btn:SetValue(chongzhi_num >= select_data.need_chongzhi)
	self.cap_show:SetValue(select_data.cap_show)

	self.need_money:SetValue(select_data.need_chongzhi)
	if select_data.path ~= "" then
		local select_name = select_data.model_id
		local select_path = select_data.path
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if string.find(select_name, "#") then
			select_name = string.gsub(select_name, "#", main_role_vo.prof)
		end
		if string.find(select_path, "#") then
			select_path = string.gsub(select_path, "#", main_role_vo.prof)
		end
		self.show_model_bg:SetValue(false)
		self.reward_model:SetDisplay(self.display.ui3d_display)
		self.reward_model:ClearModel()

		if select_data.model_type == 2 then -- image类型
			self.show_model_bg:SetValue(true)
			self.model_bg:SetAsset(ResPath.GetKaiFuChargeImage(select_data.model_id))

			local eff_name = "UI_show_image_"..self.select_seq - 2
			PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/" .. string.lower(eff_name) .. "_prefab", eff_name), function(prefab)
				if prefab and self.model_effect then
					if self.equip_bg_effect_obj  ~= nil then
						GameObject.Destroy(self.equip_bg_effect_obj)
						self.equip_bg_effect_obj = nil
					end
					local obj = GameObject.Instantiate(prefab)
					PrefabPool.Instance:Free(prefab)
					local transform = obj.transform
					transform:SetParent(self.model_effect.transform, false)
					transform.localScale = Vector3(1, 1, 1)
					self.equip_bg_effect_obj = obj.gameObject
				end
			end)
			self:Flush()
			return
		end

		local camera_name = "seven_recharge_" .. select_name
		self.reward_model:SetDisplayPositionAndRotation(camera_name)
		local item_cfg = ItemData.Instance:GetItemConfig(giftItemList[0].item_id)
		local part_type = FashionData.Instance:GetFashionTypeAndIndexById(giftItemList[0].item_id)
		if item_cfg and item_cfg.is_display_role == DISPLAY_TYPE.FASHION and part_type == SHIZHUANG_TYPE.WUQI then
			self.reward_model:SetModelResInfo(main_role_vo, true, true, true, false, true, true, true)
			self.reward_model:SetWeaponResid(select_name)
		elseif item_cfg and item_cfg.is_display_role == DISPLAY_TYPE.HALO then
			self.reward_model:SetModelResInfo(main_role_vo, true, true, false, true, true, true, true)
			self.reward_model:SetHaloResid(select_name)
		else
			self.reward_model:SetMainAsset(select_path, select_name)
			if item_cfg.is_display_role == DISPLAY_TYPE.XIAN_NV then --美人
				self.reward_model:SetLayer(4, 1.0)
				self.reward_model:SetTrigger("chuchang", false)
			elseif item_cfg.is_display_role == DISPLAY_TYPE.GENERAL then
				self.reward_model:SetTrigger("attack10")
			elseif item_cfg.is_display_role == DISPLAY_TYPE.MOUNT then
				self.reward_model:SetTrigger("rest")
			elseif item_cfg.is_display_role == DISPLAY_TYPE.SPIRIT_FAZHEN then
				local scale = Vector3(1.2, 1.2, 1.2)
				self.reward_model:SetModelScale(scale)
				self.reward_model:SetLayer(1, 1.0)
			elseif item_cfg.is_display_role == DISPLAY_TYPE.WING then
				self.reward_model:SetLayer(1, 1.0)
			end
		end
		-- self.reward_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[select_data.display_type], select_data.model_id, DISPLAY_PANEL.QITIAN_CHOGNZHI)
	else
		self.show_model_bg:SetValue(true)
		self.model_bg:SetAsset(ResPath.GetKaiFuChargeImage(select_data.model_id))
	end
	self:Flush()
end


---------------------------------------------------------------
--

ChongZhiCell = ChongZhiCell or BaseClass(BaseCell)

local REWARD_ITEM_NUMBER = 4 --类充奖励每行显示物品的数量
 
function ChongZhiCell:__init(instance, parent)
	self.parent = parent
	self.need_yuanbao = self:FindVariable("NeedYuanBao")
	self.show_hl = self:FindVariable("Show_HL")
	self.Is_Show_Red = self:FindVariable("IsShowRed")
	self.is_reward = self:FindVariable("IsReward")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClickCell, self))
end

function ChongZhiCell:__delete()
	self.parent = nil
	self.need_yuanbao = nil
	self.show_hl = nil
end

function ChongZhiCell:SetIndex(index)
	self.cell_index = index
end

function ChongZhiCell:ClickLevelReward()
	if self.data == nil then return end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHIDAHUIKUI,TOUZI_JIHUA_TYPE.CHONGZHIDAHUIKUI_REQ_TYPE_FETCH_REWARD,self.data.seq)
	self:Flush()
end

function ChongZhiCell:GetChongZhIReward()
	KaiFuChargeCtrl.Instance:SendOpenGameActivityFetchReward(SUPER_REWARD_TYPE.REWARD_TYPE_SEVEN_DAY_TOTAL_CHONGZHI,self.data.seq)
end

function ChongZhiCell:ConverMoney(value)
	local result
	if value >= 100000 and value < 100000000 then
		result = math.floor(value / 10000) .. Language.Common.Wan
	else
		result = value
	end
	return result
end

function ChongZhiCell:OnFlush()
	if self.data == nil then return end
	local need_chongzhi = self:ConverMoney(self.data.need_chongzhi)
	self.need_yuanbao:SetValue(need_chongzhi)
	local chongzhi_num = KaiFuChargeData.Instance:GetogaSevenTotalChongzhiNum()
	local flag = KaiFuChargeData.Instance:GetQiTianChongzhiRewardFlagByIndex(self.data.seq)
	self.is_reward:SetValue(flag == 1)
	self.Is_Show_Red:SetValue(self.data.need_chongzhi <= chongzhi_num and flag == 0)
end

function ChongZhiCell:OnClickCell()
	self.parent:SetSelectIndex(self.data.seq)
	self.parent:FlushAllHl()
end

function ChongZhiCell:FlushHl()
	local cur_seq = self.parent:GetSelectIndex()
	self.show_hl:SetValue(cur_seq == self.data.seq)
end

