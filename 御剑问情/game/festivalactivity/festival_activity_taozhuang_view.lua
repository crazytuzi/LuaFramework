FestivalequipmentView = FestivalequipmentView or BaseClass(BaseRender)

function FestivalequipmentView:__init()
	self.display_1 = self:FindObj("DisPlay1")
	self.display_2 = self:FindObj("DisPlay2")
	self.num = self:FindVariable("num")
	self.flush_time = self:FindVariable("time")

	self.item_list = {}
	for i = 1, 5 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_cell_" .. i))
	end

	self:ListenEvent("ButtonClick", BindTool.Bind(self.ButtonClick,self))
	self:ListenEvent("ClickOpen", BindTool.Bind(self.ClickOpen,self))

	self.seq = 0
	self.model_1 = RoleModel.New("jieri_taozhuang_panel_special_1")
	self.model_2 = RoleModel.New("jieri_taozhuang_panel_special_2")
	self.model_1:SetDisplay(self.display_1.ui3d_display)
	self.model_2:SetDisplay(self.display_2.ui3d_display)
end

function FestivalequipmentView:__delete()
	self.display_1 = nil
	self.display_2 = nil
	self.num = nil
	self.flush_time = nil

	if nil ~= self.model_1 then
		self.model_1:DeleteMe()
		self.model_1 = nil
	end

	if nil ~= self.model_2 then
		self.model_2:DeleteMe()
		self.model_2 = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if self.least_time_timer then
	    CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    self.least_time_timer = nil
	end
end

function FestivalequipmentView:OpenCallBack()
	self:Flush()
end

function FestivalequipmentView:ButtonClick()
	ClothespressCtrl.Instance:ShowSuitAttrTipView(2)
	-- FestivalActivityCtrl.Instance:SendEquipSeq(self.seq)
end

function FestivalequipmentView:ClickOpen()
	ViewManager.Instance:Open(ViewName.ClothespressView)
end

function FestivalequipmentView:OnFlush()
	self:ShowModelPlay()
	self:ShowItemList()
	local info = FestivalActivityData.Instance:GetActivityOpenListByActId(FESTIVAL_ACTIVITY_ID.ACTIVITY_TYPE_EQUIPMENT)

	if nil == info or nil == next(info) or nil == info.time_data or nil == info.time_data.end_time then
		return
	end

	local end_time = info.time_data.end_time
	local svr_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = math.floor(end_time - svr_time)

	if self.least_time_timer then
	    CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    self.least_time_timer = nil
	end

	if rest_time > 0 then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function (elapse_time, total_time)
			local left_time = total_time - elapse_time

			if left_time <= 0 then
				left_time = 0
				if self.least_time_timer then
	    			CountDown.Instance:RemoveCountDown(self.least_time_timer)
	    			self.least_time_timer = nil
	   			end

	   			self.flush_time:SetValue("")
	   		else
				local time = TimeUtil.FormatSecond(left_time, 7)
		        self.flush_time:SetValue(string.format(Language.Activity.FestivalActivityShowTime, time))

		    end
	    end)
	end
end

function FestivalequipmentView:ShowItemList()
	local num = 0
	local model_cfg = FestivalActivityData.Instance:GetHolidayCfg()

	if nil == model_cfg or nil == next(model_cfg) then
		return
	end

	self.item_list[1]:SetData({item_id = model_cfg.display_shizhuang or 0, is_bind = 0})		-- 时装
	self.item_list[2]:SetData({item_id = model_cfg.display_mount or 0, is_bind = 0})			-- 坐骑
	self.item_list[3]:SetData({item_id = model_cfg.display_wing or 0, is_bind = 0})				-- 羽翼
	self.item_list[4]:SetData({item_id = model_cfg.display_weapon or 0, is_bind = 0})			-- 武器时装
	self.item_list[5]:SetData({item_id = model_cfg.display_xiannv or 0, is_bind = 0})			-- 战骑

	-- 检测是否拥有该时装/武器
	local shizhuang_number = model_cfg.special_img_suit_shizhuang_img_1_id
	local shizhuang_state = FashionData.Instance:CheckIsActive(SHIZHUANG_TYPE.BODY, shizhuang_number) or 0
	local wuqi_number = model_cfg.special_img_suit_shizhuang_img_0_id
	local wuqi_state = FashionData.Instance:CheckIsActive(SHIZHUANG_TYPE.WUQI, shizhuang_number) or 0

	if shizhuang_state == 0 then
		self.item_list[1]:SetIconGrayScale(true)
		self.item_list[1]:SetQualityGray(true)
	else
		num = num + 1
		self.item_list[1]:SetIconGrayScale(false)
		self.item_list[1]:SetQualityGray(false)
	end

	if wuqi_state == 0 then
		self.item_list[4]:SetIconGrayScale(true)
		self.item_list[4]:SetQualityGray(true)
	else
		num = num + 1
		self.item_list[4]:SetIconGrayScale(false)
		self.item_list[4]:SetQualityGray(false)
	end


	-- 检测是否拥有该仙女/伙伴
	local active_flag = GoddessData.Instance:GetXianNvHuanHuaFlag()
	local bit_list = bit:d2b(active_flag)
	if bit_list[32 - model_cfg.special_img_suit_xiannv_img_id] == 0 then
		self.item_list[5]:SetIconGrayScale(true)
		self.item_list[5]:SetQualityGray(true)
	else
		num = num + 1
		self.item_list[5]:SetIconGrayScale(false)
		self.item_list[5]:SetQualityGray(false)
	end

	-- 检测是否拥有该坐骑
	local mount_info_list = MountData.Instance:GetMountInfo()
	local mount_active_flag = mount_info_list.active_special_image_flag
	local mount_active_flag2 = mount_info_list.active_special_image_flag2
	local mount_bit_list = bit:d2b(mount_active_flag2)
	local mount_bit_list2 = bit:d2b(mount_active_flag)
	for i,v in ipairs(mount_bit_list2) do
		table.insert(mount_bit_list, v)
	end
	if mount_bit_list[64 - model_cfg.special_img_suit_mount_img_id] == 0 then
		self.item_list[2]:SetIconGrayScale(true)
		self.item_list[2]:SetQualityGray(true)
	else
		num = num + 1
		self.item_list[2]:SetIconGrayScale(false)
		self.item_list[2]:SetQualityGray(false)
	end

	-- 检测是否拥有该羽翼
	local wing_info_list = WingData.Instance:GetWingInfo()
	local wing_active_flag = wing_info_list.active_special_image_flag
	local wing_active_flag2 = wing_info_list.active_special_image_flag2
	local wing_bit_list = bit:d2b(wing_active_flag2)
	local wing_bit_list2 = bit:d2b(wing_active_flag)
	for i,v in ipairs(wing_bit_list2) do
		table.insert(wing_bit_list, v)
	end
	if wing_bit_list[64 - model_cfg.special_img_suit_wing_img_id] == 0 then
		self.item_list[3]:SetIconGrayScale(true)
		self.item_list[3]:SetQualityGray(true)
	else
		num = num + 1
		self.item_list[3]:SetIconGrayScale(false)
		self.item_list[3]:SetQualityGray(false)
	end

	-- -- 检测是否有该战骑
	-- local zhanqi_info_list = FightMountData.Instance:GetFightMountInfo()
	-- local zhanqi_active_flag = zhanqi_info_list.active_special_image_flag
	-- local zhanqi_active_flag2 = zhanqi_info_list.active_special_image_flag2
	-- local zhanqi_bit_list = bit:d2b(zhanqi_active_flag2)
	-- local zhanqi_bit_list2 = bit:d2b(zhanqi_active_flag)
	-- for i,v in ipairs(zhanqi_bit_list2) do
	-- 	table.insert(zhanqi_bit_list, v)
	-- end

	-- if zhanqi_bit_list[64 - model_cfg.special_img_suit_fight_mount_img_id] == 0 then
	-- 	self.item_list[5]:SetIconGrayScale(true)
	-- 	self.item_list[5]:SetQualityGray(true)
	-- else
	-- 	num = num + 1
	-- 	self.item_list[5]:SetIconGrayScale(false)
	-- 	self.item_list[5]:SetQualityGray(false)
	-- end

	-- 检测是否拥有该精灵
	-- local spirit_info_list = SpiritData.Instance:GetSpiritInfo()
	-- local spirit_active_flag = spirit_info_list.special_img_active_flag
	-- local spirit_bit_list = bit:d2b(spirit_active_flag)
	-- if spirit_bit_list[32 - model_cfg.special_img_suit_jingling_img_id] == 0 then
	-- 	self.item_list[5]:SetIconGrayScale(true)
	-- else
	-- 	num = num + 1
	-- 	self.item_list[5]:SetIconGrayScale(false)
	-- end

	self.seq = num or 0
	self.num:SetValue(string.format(Language.Activity.TaoZhuangNum, num))

end

function FestivalequipmentView:ShowModelPlay()
	local model_cfg = FestivalActivityData.Instance:GetHolidayCfg()
	local mount_res_id = 0
	local wing_res_id = 0
	if nil == model_cfg or nil == next(model_cfg) then
		return
	end

	for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
		if v.item_id == model_cfg.display_mount then
			mount_res_id = v.res_id
			break
		end
	end

	for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
		if v.item_id == model_cfg.display_wing then
			wing_res_id = v.res_id
			break
		end
	end

	-- for k, v in pairs(SpiritData.Instance:GetSpiritResourceCfg()) do
	-- 	if v.id == model_cfg.display_jingling then
	-- 		spirit_res_id = v.res_id
	-- 		break
	-- 	end
	-- end

	-- for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
	-- 	if v.item_id == model_cfg.display_fight then
	-- 		zhanqi_res_id = v.res_id
	-- 		break
	-- 	end
	-- end

	-- self.model_1:SetDisplay(self.display_1.ui3d_display)
	ItemData.ChangeModel(self.model_1, model_cfg.display_shizhuang, model_cfg.display_weapon)
	-- ItemData.ChangeModel(self.model_1, model_cfg.display_mount)
	-- ItemData.ChangeModel(self.model_1, model_cfg.display_wing)
	self.model_1:RemoveMount()
	self.model_1:SetMountResid(mount_res_id)
	self.model_1:SetWingResid(wing_res_id)

	-- self.model_2:SetDisplay(self.display_2.ui3d_display)
	ItemData.ChangeModel(self.model_2, model_cfg.display_xiannv)

end