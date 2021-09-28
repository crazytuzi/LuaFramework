DisCountView = DisCountView or BaseClass(BaseView)

local PAGE_ROW = 2					--行
local MAX_COUNT = 2					--一个阶段最多显示个数
local DOUBLE_MOUNT = {
	[7301001] = "discount_model_panel_double_mount_1",
	[7302001] = "discount_model_panel_double_mount_2",
	[7303001] = "discount_model_panel_double_mount_3",
	[7304001] = "discount_model_panel_double_mount_4",
}


function DisCountView:__init()
	self.ui_config = {"uis/views/discount_prefab","DisCountView"}
	self.play_audio = true
	self.cur_index = 1
	self.toggle_num = 3
end

function DisCountView:__delete()

end

function DisCountView:ReleaseCallBack()
	self:ClearCountDown()
	self:RemoveDelayTime()
	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	for k,v in pairs(self.left_cell) do
		if v then
			v = nil
		end
	end
	self.left_cell = {}

	if self.model_view then
		self.model_view:DeleteMe()
	end
	self.model_view = nil
	-- 清理变量和对象
	self.list_view = nil
	self.left_list = nil
	self.page_num = nil
	self.toggle_list = nil
	-- self.show_togglelist = {}
	self.model = nil
	self.left_time_str = nil
	self.gold = nil
	self.bind_gold = nil
end

function DisCountView:LoadCallBack()
	self.left_time_str = self:FindVariable("LeftTimeStr")
	self.gold = self:FindVariable("coin_text")
	self.bind_gold = self:FindVariable("bind_coin_text")

	-- 查找组件
	self.list_view = self:FindObj("ListView")
	local toggle_list = self:FindObj("ToggleList")
	self.toggle_list = {}
	-- self.show_togglelist = {}
	for i = 1, 3 do
		-- self.show_togglelist[i] = self:FindVariable("ShowToggle"..i)
		local transform = toggle_list.transform:FindHard("Toggle" .. i)
		if transform ~= nil then
			node = U3DObject(transform.gameObject, transform)
			if node then
				self.toggle_list[i] = node
			end
		end
	end

	self.model_view = nil
	-- 查找变量
	self.page_num = self:FindVariable("PageNum")

	-- 监听
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("chongzhi",BindTool.Bind(self.ChongZhi, self))

	self.model = self:FindObj("Model")
	self.list_data = {}
	self.cell_list = {}
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshDel, self)
	self:ClearCountDown()

	self.left_cell = {}
	self.left_list = self:FindObj("LeftList")
	local scroller = self.left_list.list_simple_delegate
	scroller.NumberOfCellsDel = BindTool.Bind(self.GetLeftCellNumber, self)
	scroller.CellRefreshDel = BindTool.Bind(self.LeftRefreshDel, self)


	self.list_view_height = self.left_list.rect.rect.height
	self.tab_cell_height = scroller:GetCellViewSize(self.left_list.scroller, 0)			--单个cell的大小（根据排列顺序对应高度或宽度）
	self.tab_list_spacing = self.left_list.scroller.spacing

	if self.jump_to_index then
		self:SetCurIndex(self.jump_to_index)
		self:FlushLeft(true)
	end
	-- self.left_list.scroller:JumpToDataIndexForce(10)
	-- self.left_list.scroller:JumpToDataIndex(10)
	-- self.left_list.scroller.list_view:JumpToIndex(10)
	-- scroller.list_view:JumpToIndex(10)
end

function DisCountView:OpenCallBack()
	DisCountData.Instance:SetRefreshList()
	MainUICtrl.Instance.view:Flush(MainUIViewChat.IconList.DisCountRed, {false})
	DisCountData.Instance:SetHaveNewDiscount(false)
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	self.list_data = DisCountData.Instance:GetNewPhaseList()
	local page = 1
	local cur_list_data = self.list_data[self.cur_index]
	if cur_list_data and cur_list_data.phase_item_list then 
		page = math.ceil(#cur_list_data.phase_item_list / (PAGE_ROW * MAX_COUNT))
	end
	self.page_num:SetValue(page)
	self.list_view.list_page_scroll:SetPageCount(page)
	self.is_first = true
end

function DisCountView:FormatMoney(value)
	return CommonDataManager.ConverMoney(value)
end

-- 外部打开传过来的Index
function DisCountView:JumpToViewIndex(index)
	self.jump_to_index = index
end

function DisCountView:CloseCallBack()
	DisCountData.Instance:ClearDiscountList()
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
	GlobalTimerQuest:CancelQuest(self.timer_quest)
	self.jump_to_index = nil
end

function DisCountView:ChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function DisCountView:CloseWindow()
	self:Close()
end

function DisCountView:GetCellNumber()
	if self.list_data[self.cur_index] == nil then
		return 0
	end

	return math.ceil(#self.list_data[self.cur_index].phase_item_list / (PAGE_ROW * MAX_COUNT))
end

function DisCountView:FlushToggleHL()
	if self.list_data[self.cur_index] == nil then
		return
	end
	
	self.toggle_num = math.ceil(#self.list_data[self.cur_index].phase_item_list / (PAGE_ROW * MAX_COUNT))
	self.page_num:SetValue(self.toggle_num)
end

function DisCountView:FlushLeft(is_init)
	if is_init then
		self.tab_list_data = DisCountData.Instance:GetNewPhaseList()
		local max_hight = (self.tab_cell_height + self.tab_list_spacing) * (#self.tab_list_data) - self.tab_list_spacing
		local not_see_height = math.max(max_hight - self.list_view_height, 0)
		local bili = 0
		if not_see_height > 0 then
			bili = math.min(((self.tab_cell_height + self.tab_list_spacing) * (self.jump_to_index - 1)) / not_see_height, 1)
		end
		self.left_list.scroller:ReloadData(bili)
	else
		self.tab_list_data = DisCountData.Instance:GetRefreshList()
		self.left_list.scroller:RefreshActiveCellViews()
	end
end

function DisCountView:GetLeftCellNumber()
	return #self.list_data
end

function DisCountView:FlushModel()

	local discount_group_cell = self.model_view
	if discount_group_cell == nil then
		discount_group_cell = DisCountGroupCell.New(self.model)
		self.model_view = discount_group_cell
	end
	discount_group_cell:SetIndex(self.cur_index)
	discount_group_cell:SetData(self.list_data[self.cur_index])

end

function DisCountView:RefreshDel(cell, data_index)
	data_index = data_index + 1
	local discount_group_cell = self.cell_list[cell]
	if not discount_group_cell then
		discount_group_cell = ItemCellList.New(cell.gameObject)
		self.cell_list[cell] = discount_group_cell
	end
	discount_group_cell:SetIndex(data_index)
	local t = TableCopy(self.list_data[self.cur_index])
	t.phase_item_list = TableSortByCondition(self.list_data[self.cur_index].phase_item_list,function (p)
		if p.buy_count < p.buy_limit_count then
			return true
		else
			return false
		end
	end)
	discount_group_cell:SetData(t)
	discount_group_cell:Flush()
end

function DisCountView:SetCurIndex(index)
	self.cur_index = index
end

function DisCountView:FlushLeftList()
	for k,v in pairs(self.left_cell) do
		v:FlushHLActive(self.cur_index)
	end
end

--左边按钮刷新
function DisCountView:LeftRefreshDel(cell, data_index)
	data_index = data_index + 1
	local left_button = self.left_cell[cell]
	if not left_button then
		left_button = ButtonClickCell.New(cell.gameObject)
		self.left_cell[cell] = left_button
		left_button.view = self
	end

	left_button:SetIndex(data_index)
	left_button:FlushHLActive(self.cur_index)
	left_button:SetData(self.list_data[data_index])
	left_button:OnFlush()
end

function DisCountView:FlushRightList()
	self.left_list.scroller:RefreshActiveCellViews()
	if self.is_first then
		self.list_view.list_page_scroll:SetPageCount(self.toggle_num)
		self.list_view.scroller:ReloadData(0)
		self.list_view.list_page_scroll:JumpToPageImmidate(0)
		for k, v in ipairs(self.toggle_list) do
			if k == 1 then
				v.toggle.isOn = true
			else
				v.toggle.isOn = false
			end
		end
		self.is_first = false
	else
		self.list_view.scroller:RefreshActiveCellViews()
	end
	self:StarCountDown()
end

function DisCountView:GetPageNum()
	return math.ceil(#self.list_data[self.cur_index].phase_item_list / (PAGE_ROW * MAX_COUNT))
end

function DisCountView:StarCountDown()
	self:ClearCountDown()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_time = self.list_data[self.cur_index].close_timestamp - server_time
	local time_str = "0:0:0"
	local left_day = 0
	if left_time > 0 then
		left_day = TimeUtil.Format2TableDHM(left_time).day or 0
		time_str = TimeUtil.FormatSecond(left_time, left_day > 0 and 7 or 0)

		local function timer_func(elapse_time, total_time)
			if elapse_time >= total_time then
				self:ClearCountDown()
			end
			left_time = math.ceil(total_time - elapse_time)
			left_day = TimeUtil.Format2TableDHM(left_time).day or 0
			time_str = TimeUtil.FormatSecond(left_time, left_day > 0 and 7 or 0)
			self.left_time_str:SetValue(time_str)
		end
		self.count_down = CountDown.Instance:AddCountDown(left_time, 1, timer_func)
	end
	self.left_time_str:SetValue(time_str)
end

function DisCountView:ClearCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function DisCountView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "index" then
			self.list_data = DisCountData.Instance:GetNewPhaseList()

			local new_phase_index = v[1]
			if type(new_phase_index) == "number"  then
				self:SetCurIndex(new_phase_index)
			end
			local count = DisCountData.Instance:GetPaseCount()
			local pos = new_phase_index / count > 0.5 and 1 or 0
			self.left_list.scroller:ReloadData(pos)
		else
			self.list_data = DisCountData.Instance:GetRefreshList()
		end
	end
	if self.gold and self.bind_gold then
		self.gold:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().gold))
		self.bind_gold:SetValue(self:FormatMoney(GameVoManager.Instance:GetMainRoleVo().bind_gold))
	end
	self:FlushModel()
	self:FlushToggleHL()
	self:FlushRightList()
end

function DisCountView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "gold" then
		self.gold:SetValue(GameVoManager.Instance:GetMainRoleVo().gold)
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(GameVoManager.Instance:GetMainRoleVo().bind_gold)
	end
end

function DisCountView:JumpToPage(index, count)
	if self.toggle_num == 1 then return end
	if nil == self.toggle_list[index] or count == 1000 then return end
	if self.toggle_list[index].gameObject.activeSelf and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.list_page_scroll:JumpToPageImmidate(index-1)
		self.toggle_list[index].toggle.isOn = true
	else
		self:RemoveDelayTime()
		self.delay_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.JumpToPage, self, index, count + 1), 0)
	end
end

function DisCountView:RemoveDelayTime()
	if self.delay_timer_quest then
		GlobalTimerQuest:CancelQuest(self.delay_timer_quest)
		self.delay_timer_quest = nil
	end
end

--模型
DisCountGroupCell = DisCountGroupCell or BaseClass(BaseRender)

function DisCountGroupCell:__init()
	self.title_text = self:FindVariable("TitleText")
	self.show_effect = self:FindVariable("ShowEffect")
	self.show_rune = self:FindVariable("Show_Rune")
	self.show_display_store = self:FindVariable("ShowDisplayStore")
	self.show_model_img = self:FindVariable("ShowModelImg")
	self.model_img_res = self:FindVariable("ModelImgRes")
	self.show_point_effect_list = self:FindVariable("ShowPointEffectList")
	self.show_effect_model = self:FindVariable("ShowEffectModel")
	self.effect = self:FindVariable("effect")
	self.effect_root = self:FindObj("EffectRoot")

	--特效专用模型
	self.effect_model = self:FindVariable("EffectModel")

	--普通模型
	self.model_display = self:FindObj("DisPlay")
	self.model = RoleModel.New("discount_model_panel_person")
	self.model:SetDisplay(self.model_display.ui3d_display)

	--宝石专用模型(材质贴图不一样)
	self.model_store_display = self:FindObj("DisPlayStore")
	self.model_store = RoleModel.New("discount_store_panel")
	self.model_store:SetDisplay(self.model_store_display.ui3d_display)

end

function DisCountGroupCell:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.show_rune = nil
	if self.model_store then
		self.model_store:DeleteMe()
		self.model_store = nil
	end

end


function DisCountGroupCell:SetIndex(index)
	self.index = index
end

function DisCountGroupCell:SetModel()
	GlobalTimerQuest:CancelQuest(self.timer_quest)
	if self.model and self.model_show ~= self.data.model_show then
		self.model:ClearModel()
		self.model_store:ClearModel()
		self.show_display_store:SetValue(false)
		self.show_model_img:SetValue(false)
		self.show_point_effect_list:SetValue(false)
		self.show_effect_model:SetValue(false)
		self.model_show = self.data.model_show
		local model_show = self.model_show
		local split_tbl = Split(model_show, ",")
		--强制清楚足迹
		self.show_rune:SetValue(false)
		local num = self.model_display.transform.childCount
			for i=1,num-1,1 do
				 GameObject.Destroy(self.model_display:GetChild(i))
				end
		self.model:SetFootResid(nil)
		if string.find(model_show, "HuobanHalo") then
			--光环
			local info = {}
			local split = Split(split_tbl[2],"_")
			info.role_res_id = 11006
			info.weapon_res_id = split[2]
			self.model:SetPanelName("discount_model_panel_person")
			self.model:SetGoddessModelResInfo(info)
			self.model:SetTrigger("show_idle_1")
		elseif string.find(model_show, "Halo") then
			-- 角色光环
			local split = Split(split_tbl[2],"_")
			local halo_res_id = tonumber(split[2])
			local main_role = Scene.Instance:GetMainRole()
			self.model:SetPanelName("discount_model_panel_person")
			self.model:SetRoleResid(main_role:GetRoleResId())
			self.model:SetHaloResid(halo_res_id)
			local part = self.model.draw_obj:GetPart(SceneObjPart.Halo)
			if part then
				part:SetTrigger("action")
			end
		elseif string.find(model_show, "huobanfz") then
			--神翼
			local split = Split(split_tbl[2],"_")
			local info = {}
			info.role_res_id = 11006
			info.wing_res_id = split[2]
			self.model:SetPanelName("discount_model_panel_person")
			self.model:SetGoddessModelResInfo(info)
			self.model:SetTrigger("show_idle_1")
		elseif string.find(model_show, "goddessweapon")   then
			--神弓
			local info = {}
			info.role_res_id = 11022
			info.weapon_res_id = split_tbl[2]
			self.model:SetPanelName("discount_model_panel_person")
			self.model:SetGoddessModelResInfo(info)
			self.model:SetRotation(Vector3(0, -90, 0))
		elseif string.find(model_show, "goddess") then
			--女神
			self.model:SetPanelName("discount_model_panel_person")
			self.model:SetGoddessResid(tonumber(split_tbl[2]))
			self.model:SetTrigger("show_idle_1")
		elseif string.find(model_show, "image") then
			--图片资源
			self.show_model_img:SetValue(true)
			self.model_img_res:SetAsset(split_tbl[1], split_tbl[2])
			if string.find(model_show, "shengxiao") then
				self.show_point_effect_list:SetValue(true)
			end
		elseif string.find(model_show, "wing") then
			--羽翼
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local info = {}
			info.prof = main_vo.prof
			info.sex = main_vo.sex
			info.appearance = {}
			info.appearance.fashion_body = main_vo.appearance.fashion_body
			self.model:SetPanelName("discount_model_panel_person")
			self.model:SetModelResInfo(info)
			self.model:SetWingResid(tonumber(split_tbl[2]))
		elseif string.find(model_show, "Foot") then
			--足迹
			local main_vo = GameVoManager.Instance:GetMainRoleVo()
			local info = {}
			local split = Split(split_tbl[2],"_")
			info.prof = main_vo.prof
			info.sex = main_vo.sex
			info.appearance = {}
			info.appearance.fashion_body = main_vo.appearance.fashion_body
			self.model:SetPanelName("discount_model_panel_person")
			self.model:SetRoleResid(Scene.Instance:GetMainRole():GetRoleResId())
			self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
			self.model:SetFootResid(split_tbl[2])
			self.model.display:SetRotation(Vector3(0, -45, 0))
		elseif string.find(model_show, "effects") then
			--特效模型
			self.show_rune:SetValue(true)
			self.show_effect_model:SetValue(true)
			--self.effect_model:SetAsset(split_tbl[1], split_tbl[2])
		else
			local function SetMainAsset(model, trigger_name)
				local bunble, asset = split_tbl[1], split_tbl[2]
				model:SetMainAsset(bunble, asset)
				if trigger_name and trigger_name ~= "" then
					model:SetTrigger(trigger_name)
					if self.timer_quest == nil then
						self.timer_quest = GlobalTimerQuest:AddRunQuest(function() model:SetTrigger(trigger_name) end, 15)
					end
				end
			end
			local model = self.model
			local trigger_name = ""
			if string.find(model_show, "gather") then
				--采集物
				if tonumber(split_tbl[2]) == 6037 then
					--特殊采集物（需要更换反射贴图）
					model = self.model_store
					self.show_display_store:SetValue(true)
				else
					self.model:SetPanelName("discount_model_panel_tianming")
				end
			elseif string.find(model_show, "fightmount") then
				--战斗坐骑
				self.model:SetPanelName("discount_model_panel_fight_mount")
			elseif string.find(model_show, "linggong") then
				--灵弓
				self.model:SetPanelName("discount_linggong_panel")
			elseif string.find(model_show,"mingjiang") then 
				--天神
				self.model:SetPanelName("discount_mingjiang_panel")
			elseif string.find(model_show, "mount") then
				local display_name = "discount_model_panel_mount"
				local is_double, doule_name= self:IsDoubleMount(model_show)
				if is_double then
					display_name = doule_name
				end
				--坐骑
				self.model:SetPanelName(display_name)
				self.model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
			elseif string.find(model_show, "spirit") or string.find(model_show, "lingchong")then
				--精灵
				self.model:SetPanelName("discount_model_panel_spirit")
			elseif string.find(model_show, "forge") then
				self.model:SetPanelName("discount_model_panel_tianming")
			elseif string.find(model_show, "hunqi") then
				local function complete_callback()
					if self.model then
						self.model:ShowAttachPoint(AttachPoint.Weapon, false)
						self.model:ShowAttachPoint(AttachPoint.Weapon2, true)
					end
				end
				local bunble, asset = split_tbl[1], split_tbl[2]
				self.model:SetPanelName("discount_model_panel_lianqi")
				self.model:SetMainAsset(bunble, asset, complete_callback)
				return
			end
			SetMainAsset(model, trigger_name)
		end
		if string.find(model_show, "Foot") then
			return
		else
			if string.find(model_show, "mount") == nil then
				self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
			end
			self.model.display:SetRotation(Vector3(0, 0, 0))
		end
	end
end

function DisCountGroupCell:IsDoubleMount(model_show)
	if nil == model_show then return end
	for k,v in pairs(DOUBLE_MOUNT) do
		if string.find(model_show, k) then
			return true, v
		end
	end
	return false, nil
end

function DisCountGroupCell:SetData(data)
	if not data or not next(data) then
		return
	end
	self.data = data
	self:SetModel()
	self.title_text:SetValue(data.phase_desc)
	if data.special_show == 1 then
		self.effect:SetAsset(data.effect_bundle, data.effect_asset)
		local pos = Split(data.effect_pos, ",")
		local scale = Split(data.effect_scale, ",")
		self.effect_root.transform.localPosition = Vector3(pos[1], pos[2], pos[3])
		self.effect_root.transform.localScale = Vector3(scale[1], scale[2], scale[3])
	end
	self.show_effect:SetValue(data.special_show == 1)
	local temp_data = {}
	local phase_item_list = data.phase_item_list
	local count = 0
	for k, v in ipairs(phase_item_list) do
		if count >= MAX_COUNT then
			break
		end
		if v.buy_count < v.buy_limit_count then
			table.insert(temp_data, v)
			count = count + 1
		end
	end
	if #temp_data <= 0 then
		local count = 0
		for k, v in ipairs(phase_item_list) do
			if count >= MAX_COUNT then
				break
			end
			table.insert(temp_data, v)
			count = count + 1
		end
	elseif #temp_data <= 1 then
		for k, v in ipairs(phase_item_list) do
			if v.buy_count >= v.buy_limit_count then
				table.insert(temp_data, v)
				break
			end
		end
	end

end


-------------------------DisCountItemCell-----------------------------------------
DisCountItemCell = DisCountItemCell or BaseClass(BaseCell)

function DisCountItemCell:__init()
	self.name = self:FindVariable("Name")
	self.gold_image = self:FindVariable("GoldImage")
	self.old_price = self:FindVariable("OldPrice")
	self.new_price = self:FindVariable("NewPrice")
	self.limit_num = self:FindVariable("LimitNum")
	self.is_sell_out = self:FindVariable("IsSellOut")
	-- self.yi_shou_yao = self:FindVariable("YiShouYao")

	self:ListenEvent("ClickBuy", BindTool.Bind(self.ClickBuy, self))

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:SetData()
end

function DisCountItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function DisCountItemCell:SetData(data)
	self.data = data
end

function DisCountItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	local reward_data = self.data.reward_item
	self.item_cell:SetData(reward_data)
	local item_cfg = ItemData.Instance:GetItemConfig(reward_data.item_id)
	local item_color = item_cfg.color or GameEnum.ITEM_COLOR_WHITE
	local item_name = item_cfg.name or ""
	item_name = ToColorStr(item_name, ITEM_COLOR[item_color])
	self.name:SetValue(item_name)

	self.old_price:SetValue(self.data.show_price)
	self.new_price:SetValue(self.data.price)

	local limit_num = self.data.buy_limit_count - self.data.buy_count
	local limit_str = tostring(limit_num)
	if limit_num <= 0 then
		limit_str = ToColorStr(limit_num, TEXT_COLOR.RED)
	end
	self.limit_num:SetValue(limit_str)

	self.is_sell_out:SetValue(limit_num <= 0)
end


function DisCountItemCell:ClickBuy()
	if not self.data or not next(self.data) then
		return
	end
	local reward_data = self.data.reward_item
	local item_cfg = ItemData.Instance:GetItemConfig(reward_data.item_id)
	local item_color = GameEnum.ITEM_COLOR_WHITE
	local item_name = ""
	if item_cfg then
		item_color = item_cfg.color
		item_name = item_cfg.name
	end
	local des = string.format(Language.Common.UsedGoldToBuySomething, ToColorStr(self.data.price, TEXT_COLOR.BLUE_4), ToColorStr(item_name, ITEM_COLOR[item_color]))
	local function ok_callback()
		DisCountCtrl.Instance:SendDiscountBuyReqBuy(self.data.seq)
	end
	TipsCtrl.Instance:ShowCommonAutoView("dis_count", des, ok_callback)
end

--右边列表
ItemCellList = ItemCellList or BaseClass(BaseCell)

function ItemCellList:__init()
	self.data = {}
	self.list = {}
	for i=1,4 do
		local itemcell = self:FindObj("ListItem"..i)
		self.list[i] = DisCountItemCell.New(itemcell)
	end
end

function ItemCellList:__delete()
	for k,v in pairs(self.list) do
		v:DeleteMe()
	end
	self.data = {}
end

function ItemCellList:LoadCallBack()
end

function ItemCellList:ReleaseCallBack()
end

function ItemCellList:SetIndex(index)
	self.index = index
end

function ItemCellList:SetData(data)
	self.data = data
end

function ItemCellList:OnFlush()
	for k,v in pairs(self.list) do
		if self.data.phase_item_list[(self.index - 1) * (PAGE_ROW * MAX_COUNT) + k] then
			v:SetActive(true)
			v:SetData(self.data.phase_item_list[(self.index - 1) * (PAGE_ROW * MAX_COUNT) + k])
			v:Flush()
		else
			v:SetActive(false)
		end
	end
end

--左边列表

ButtonClickCell = ButtonClickCell or BaseClass(BaseCell)

function ButtonClickCell:__init()
	self.view = nil
	self.is_flush = false
	self.text_name = self:FindVariable("Name")
	self.show_hl = self:FindVariable("ShowHL")
	self:ListenEvent("Click", BindTool.Bind(self.Click, self))

	self.index = 1
	self.data = {}

	self.show_hl:SetValue(false)
end

function ButtonClickCell:__delete()
	self.text_name = nil
	self.show_hl = nil
	self.data = {}
end

function ButtonClickCell:LoadCallBack()
end

function ButtonClickCell:ReleaseCallBack()
end

function ButtonClickCell:Click()
	self.view.is_first = true
	self.view:SetCurIndex(self.index)
	self.view:FlushToggleHL()
	self.view:FlushRightList()
	self.view:FlushLeftList()
	self.view:Flush()
end

function ButtonClickCell:SetIndex(index)
	self.index = index
end

function ButtonClickCell:SetData(data)
	self.data = data
end

function ButtonClickCell:FlushHLActive(index)
	self.show_hl:SetValue(index == self.index)
end

function ButtonClickCell:OnFlush()
	if self.data then
		self.text_name:SetValue(self.data.phase_desc)
	end
	if self.view:IsOpen() and not self.is_flush then
		self.is_flush = true
		self.view:Flush()
	end
end
