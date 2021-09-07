HuanzhuangShopView = HuanzhuangShopView or BaseClass(BaseView)
function HuanzhuangShopView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/serveractivity/huanzhuangshop", "HuangZhuangShopView"}
	self.play_audio = true
	self.cell_list = {}
end

function HuanzhuangShopView:LoadCallBack()
	self.show_type = 1
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("OpenTab1", BindTool.Bind(self.OnClickTab, self, 1))
	self:ListenEvent("OpenTab2", BindTool.Bind(self.OnClickTab, self, 0))

	self.act_time = self:FindVariable("ActTime")
	self.red_point = self:FindVariable("red_point")
	self:InitScroller()
end

function HuanzhuangShopView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	-- 清理变量和对象
	self.scroller = nil
	self.act_time = nil
	self.red_point = nil
	
	for i,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function HuanzhuangShopView:OnClickTab(show_type)
	if self.show_type == show_type then
		return
	end
	self.show_type = show_type
	self.data = HuanzhuangShopData.Instance:GetHuanZhuangShopRewardCfgByShowType(self.show_type)
	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
end

function HuanzhuangShopView:InitScroller()
	self.scroller = self:FindObj("ListView")
	self.data = HuanzhuangShopData.Instance:GetHuanZhuangShopRewardCfgByShowType(self.show_type)
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			target_cell = HuanZhuangShopCell.New(cell.gameObject)
			self.cell_list[cell] = target_cell
			target_cell:SetFlushModelValue(true)
			target_cell:SetIndex(data_index)
		else
			target_cell:SetFlushModelValue(false)
		end
		target_cell:SetShowType(self.show_type)
		target_cell:SetData(self.data[data_index])
		target_cell:Flush()
	end
end

function HuanzhuangShopView:OpenCallBack()
	self:Flush()
	HuanzhuangShopData.Instance:HuanZhuangShopOpen()
	RemindManager.Instance:Fire(RemindName.ShowHuanZhuangShopPoint)
end

function HuanzhuangShopView:ShowIndexCallBack(index)

end

function HuanzhuangShopView:CloseCallBack()

end

function HuanzhuangShopView:OnFlush(param_t)
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	for k,v in pairs(param_t) do
		if k == "FlsuhData" then
			for k2,v2 in pairs(self.cell_list) do
				local data = HuanzhuangShopData.Instance:GetHuanZhuangShopRewardCfgByShowType(self.show_type)
				v2:SetData(data[v2:GetIndex()])
				v2:Flush("FlsuhData")
			end
		else
			if self.scroller then
				self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
			end
		end
	end
	self.red_point:SetValue(HuanzhuangShopData.Instance:ShowHuanZhuangShopPoint() > 0)
end

function HuanzhuangShopView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	if time > 3600 * 24 then
		self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond2DHMS(time, 6) .. "</color>")
	elseif time > 3600 then
		self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond2DHMS(time, 1) .. "</color>")
	else
		self.act_time:SetValue("<color='#ffffff'>" .. TimeUtil.FormatSecond2DHMS(time, 2) .. "</color>")
	end
end

---------------------------------------------------------------
--滚动条格子
local MODEL_TRANS_CFG = {
	[1] = {
		rotation = Vector3(0, 45, 0),
		scale = Vector3(0.3, 0.3, 0.3),		
	},
	[2] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(0.6, 0.6, 0.6),
	},
	[3] = {
		rotation = Vector3(0, 0, 0),
		scale = Vector3(0.8, 0.8, 0.8),
	},
}
HuanZhuangShopCell = HuanZhuangShopCell or BaseClass(BaseRender)

function HuanZhuangShopCell:__init()
	self.show_type = 0
	self.flush_model = true
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))

	self.name = self:FindVariable("name")
	self.cost_text = self:FindVariable("cost_text")
	self.power = self:FindVariable("power")
	self.show_buy = self:FindVariable("show_buy")
	self.is_show_title = self:FindVariable("is_show_title")
	self.title_id = self:FindVariable("title_id")
	self.can_click = self:FindVariable("can_click")
	self.fetch_btn_text = self:FindVariable("fetch_btn_text")
	self.recharge_num = self:FindVariable("recharge_num")
	self.display = self:FindObj("display")
	self.model = RoleModel.New("huanzhuang_shop")
	self.model:SetDisplay(self.display.ui3d_display)
	self.show_red = self:FindVariable("show_red")

	self.show_foot_camera = self:FindVariable("show_foot_camera")
	local ui_foot = self:FindObj("UI_Foot")
	local foot_camera = self:FindObj("FootCamera")
	self.foot_display = self:FindObj("foot_display")
	self.foot_parent = {}
	for i = 1, 3 do
		self.foot_parent[i] = self:FindObj("Foot_" .. i)
	end
	local camera = foot_camera:GetComponent(typeof(UnityEngine.Camera))
	self.foot_display.ui3d_display:Display(ui_foot.gameObject, camera)
	if not IsNil(camera) then
		 camera.transform.localPosition = Vector3(67.87, 5.3, -664.5)
		 ui_foot.gameObject.transform.localPosition = Vector3(68, 0, -665)
	end

	self:FlushModel()
end

function HuanZhuangShopCell:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function HuanZhuangShopCell:SetShowType(show_type)
	self.show_type = show_type		
end

function HuanZhuangShopCell:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "FlsuhData" then
			self:FlushAttr()
		else
			self:FlushAttr()
			self:FlushModel()
		end
	end
end

function HuanZhuangShopCell:FlushAttr()
	local info = HuanzhuangShopData.Instance:GetRAMagicShopAllInfo()
	local magic_shop_buy_flag = bit:d2b(info.magic_shop_buy_flag)
	local magic_shop_fetch_reward_flag = bit:d2b(info.magic_shop_fetch_reward_flag)
	local magic_shop_chongzhi_value = info.magic_shop_chongzhi_value

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	self.name:SetValue(item_cfg.name)
	self.show_buy:SetValue(self.show_type == 1)
	self.is_show_title:SetValue(self.show_type == 0)
	self.power:SetValue(self.data.power)
	if 1 == self.show_type then
		local num = 1 == magic_shop_buy_flag[32 - self.data.index] and 0 or 1
		self.can_click:SetValue(num >= 1)
		self.recharge_num:SetValue(self.data.need_gold)
		self.cost_text:SetValue(self.data.need_gold)
		self.show_red:SetValue(false)
	else
		self.title_id:SetAsset(ResPath.GetTitleIcon(item_cfg.param1))
		local str = magic_shop_chongzhi_value < self.data.need_gold and Language.Common.WEIDACHENG or (0 == magic_shop_fetch_reward_flag[32 - self.data.index] and Language.Common.LingQu or Language.Common.YiLingQu)
		self.fetch_btn_text:SetValue(str)
		self.can_click:SetValue(magic_shop_chongzhi_value >= self.data.need_gold and 0 == magic_shop_fetch_reward_flag[32 - self.data.index])
		self.recharge_num:SetValue(self.data.need_gold)
		self.show_red:SetValue(magic_shop_chongzhi_value >= self.data.need_gold and 0 == magic_shop_fetch_reward_flag[32 - self.data.index])
	end
end

function HuanZhuangShopCell:SetData(data)
	self.data = data
end

function HuanZhuangShopCell:SetIndex(index)
	self.index = index
end

function HuanZhuangShopCell:GetIndex()
	return self.index
end

function HuanZhuangShopCell:SetFlushModelValue(value)
	self.flush_model = value
end

function HuanZhuangShopCell:FlushModel()
	-- if not self.flush_model then
	-- 	return
	-- end
	self.show_foot_camera:SetValue(false)
	local info = HuanzhuangShopData.Instance:GetRAMagicShopAllInfo()
	local activity_day = info.activity_day
	if 1 == self.show_type then
		local tbl = Split(self.data.item_show, ",")
		if #tbl == 1 then
			MolongMibaoChapterView.ChangeModel(self.model, tonumber(tbl[1]))
		elseif tbl[3] then
			if tonumber(tbl[3]) == 0 then
				if self.index == 3 then
					self:SetFootModle("Foot_5")
					self.show_foot_camera:SetValue(true)
				else
					self.model:SetMainAsset(tbl[1], tbl[2])
				end
			elseif tonumber(tbl[3]) == 1 then
				self.model:ClearModel()
			end
		end
		self.model:SetTransform(MODEL_TRANS_CFG[self.index])

		-- self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.HUANZHUANG_SHOP], self.data.activity_day, self.data.index)

		-- local cfg_pos = ConfigManager.Instance:GetAutoConfig("model_display_parameter_auto").huan_zhuang_shop_model[10 * activity_day + self.data.index]
		-- if cfg_pos then
		-- 	self.model:SetTransform(cfg_pos)
		-- end
	end
end

function HuanZhuangShopCell:OnClick()
	local opera_type = 0
	if self.show_type == 0 then
		opera_type = HuanzhuangShopData.OPERATE.RECHARGE
	else
		opera_type = HuanzhuangShopData.OPERATE.BUY
	end
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MAGIC_SHOP, RA_NEW_TOTAL_CHARGE_OPERA_TYPE.RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, opera_type, self.data.index)
end

function HuanZhuangShopCell:SetFootModle(res_id)
		for i = 1, 3 do
			local bundle, asset = ResPath.GetFootEffec(res_id)
			PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
				if nil == prefab then
					return
				end
				local parent_transform = self.foot_parent[i].transform
				if parent_transform and not IsNil(parent_transform) and parent_transform.childCount then
					for j = 0, parent_transform.childCount - 1 do
						GameObject.Destroy(parent_transform:GetChild(j).gameObject)
					end
					local obj = GameObject.Instantiate(prefab)
					local obj_transform = obj.transform
					obj_transform:SetParent(parent_transform, false)
					PrefabPool.Instance:Free(prefab)
				end
			end)
		end
end