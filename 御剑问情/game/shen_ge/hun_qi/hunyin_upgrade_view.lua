HunYinUpGradeView = HunYinUpGradeView or BaseClass(BaseRender)

local NumOfHunyinCells = 12
function HunYinUpGradeView:__init()
	self.model_display = self:FindObj("ModelDisplay")		-- 3D模型显示
	self.effect_obj = self:FindObj("EffectObj")				-- 特效显示

	self.tab_inlay = self:FindObj("tab_inlay")
	self.tab_uplevel = self:FindObj("tab_uplevel")

	self.hunqi_btn_list = {}								-- 魂器按钮
	self.hunqi_list_obj = self:FindObj("HunqiListView")		-- 魂器按钮列表
	self.hunqi_list_obj.scroll_rect.horizontalNormalizedPosition = 0
	for i = 0, 5 do
		local hunqi_btn_obj =  self:FindObj("hunqi_"..(i+1))
		local hunqi_btn = HunQiBtn.New(hunqi_btn_obj)
		hunqi_btn:SetIndex(i+1)
		hunqi_btn:Flush()
		hunqi_btn:SetClickCallBack(BindTool.Bind(self.HunQiBtnClick, self))
		table.insert(self.hunqi_btn_list, hunqi_btn)
	end

	self.shengling_inlay_list = {}
	self.shengling_list_obj = self:FindObj("ShenglingList")		-- 圣灵镶嵌列表
	for i = 0, 7 do
		local inlay_obj = self.shengling_list_obj.transform:GetChild(i).gameObject
		local inlay_cell = ShenglingInlayCell.New(inlay_obj)
		inlay_cell:SetIndex(i+1)
		inlay_cell:SetClickCallBack(BindTool.Bind(self.InlayClick, self))
		table.insert(self.shengling_inlay_list, inlay_cell)
	end

	self.stars_list = {}										-- 星星列表
	for i=1,5 do
		self.stars_list[i] = self:FindObj("start_"..i)
	end
	self.show_stars_list = {}									--星星背景列表
	for i=1,5 do
		self.show_stars_list[i] = self:FindVariable("show_start_bg_"..i)
	end

	self:ListenEvent("OnClickSuit", BindTool.Bind(self.OnClickSuit, self))				--点击套装
	self:ListenEvent("OnClickAllAttr", BindTool.Bind(self.OnClickAllAttr, self))		--点击魂印总览	--点击灵枢升级
	self:ListenEvent("OnClickActivity1", BindTool.Bind(self.OnClickActivity1, self))	--活动1
	self:ListenEvent("OnClickActivity2", BindTool.Bind(self.OnClickActivity2, self))	--活动2
	self:ListenEvent("OnClickActivity3", BindTool.Bind(self.OnClickActivity3, self))	--活动3
	self:ListenEvent("OnClickRight", BindTool.Bind(self.OnClickRight, self))			--点击右滑
	self:ListenEvent("OnClickLeft", BindTool.Bind(self.OnClickLeft, self))				--点击左滑
	self:ListenEvent("ClickResolve", BindTool.Bind(self.ClickResolve, self))			--跳转分解
	self:ListenEvent("OnShenglingUpdate", BindTool.Bind(self.OnShenglingUpdate, self))	--圣灵升级
	self:ListenEvent("ClickExchange", BindTool.Bind(self.ClickExchange, self))			--兑换
	self:ListenEvent("ClickRule", BindTool.Bind(self.ClickRule, self))

	self:ListenEvent("OnClickTotalInlay", BindTool.Bind(self.OnClickTotalInlay, self))
	self:ListenEvent("OnClickLingshuUpdate", BindTool.Bind(self.OnClickLingshuUpdate, self))
	self:ListenEvent("OnClickGetWay", BindTool.Bind(self.OnClickGetWay, self))

	self.current_hunqi_name = self:FindVariable("HunYinName")							--当前魂印名称
	self.lingshu_power = self:FindVariable("power")										--当前加的战力
	self.hunyin_power = self:FindVariable("hunyin_power")								--当前加的战力
	self.all_lingshu_power = self:FindVariable("all_lingshu_power") 					--当前魂器的所有灵枢战力
	self.hp = self:FindVariable("hp")													--血量数据
	self.fangyu = self:FindVariable("fangyu")											--防御数据
	self.mingzhong = self:FindVariable("mingzhong")										--命中数据
	self.gongji = self:FindVariable("gongji")											--攻击数据
	self.baoji = self:FindVariable("baoji")												-- 暴击
	self.jianren = self:FindVariable("jianren")											-- 坚韧
	self.shanbi = self:FindVariable("shanbi")											-- 闪避
	self.amp = self:FindVariable("amp")													-- 加成

	self.hunyin_mingzhong = self:FindVariable("hunyin_mingzhong")						-- 魂印命中
	self.hunyin_gongji = self:FindVariable("hunyin_gongji")								-- 魂印攻击
	self.hunyin_baoji = self:FindVariable("hunyin_baoji")								-- 魂印暴击
	self.hunyin_jianren = self:FindVariable("hunyin_jianren")							-- 魂印坚韧
	self.hunyin_shanbi = self:FindVariable("hunyin_shanbi")								-- 魂印闪避
	self.hunyin_addper = self:FindVariable("hunyin_addper")								-- 魂印加成
	self.hunyin_hp = self:FindVariable("hunyin_hp")										-- 魂印血量
	self.hunyin_fangyu = self:FindVariable("hunyin_fangyu")								-- 魂印防御
	self.exp_cost = self:FindVariable("exp_cost")										-- 灵性值消耗
	self.show_get_way1 = self:FindVariable("show_get_way1")								--
	self.show_get_way2 = self:FindVariable("show_get_way2")										--

	self.hunqi_image = self:FindVariable("HunYin")										--右侧魂器图片
	self.hunyin_effect = self:FindVariable("hunyin_effect")
	self.is_show_effect = self:FindVariable("is_show_effect")
	self.is_show_hunyin = self:FindVariable("is_show_hunyin")

	self.is_show_active_1 = self:FindVariable("is_show_active_1")
	self.is_show_active_1:SetValue(true)
	self.is_show_active_2 = self:FindVariable("is_show_active_2")
	self.is_show_active_2:SetValue(true)
	self.is_show_active_3 = self:FindVariable("is_show_active_3")
	self.is_show_active_3:SetValue(true)

	self.show_update_rdp = self:FindVariable("show_update_rdp")							--红点
	self.is_max_levle = self:FindVariable("IsMaxLevel")

	self.hunyin_inlay = self:FindVariable("HunYinInlayRemind")
	self.hunyin_lingshu = self:FindVariable("LingShuUpdateRemind")

	self.activity_1 = self:FindVariable("activity_1")									--活动1
	self.activity_2 = self:FindVariable("activity_2")									--活动2
	self.activity_3 = self:FindVariable("activity_3")									--活动3

	self.show_inlay_or_upadte = self:FindVariable("ShowInlayOrUpdate")					--显示镶嵌或升级
	self.show_contain_or_none = self:FindVariable("ContainOrNone")						--用于是否有魂器界面的显示

	-- 魂印背包
    self.hunyin_cell_list = {}
    self.hunyin_cell_list_view = self:FindObj("HunYinCells")
    local page_simple_delegate = self.hunyin_cell_list_view.page_simple_delegate
    page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
    page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

	self.hunyin_get_info = HunQiData.Instance:GetHunYinGet()
	self.getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way

    self.current_select_hunqi = 1
    self.current_selcet_shengling = 1
    self.curren_click_cell_index = -1
    self.all_hunyin_info = {}
    self.current_hunyin_list_info = HunQiData.Instance:GetHunYinListByIndex(self.current_select_hunqi) or {}
    self.hunyin_info = HunQiData.Instance:GetHunQiInfo()							-- 魂印ID对应魂器信息
    self.item_id_list = {}
	for k,v in pairs(self.hunyin_info) do
		table.insert(self.item_id_list, k)
	end
end

function HunYinUpGradeView:__delete()
    if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k,v in pairs(self.hunqi_btn_list) do
		v:DeleteMe()
	end
	self.hunqi_btn_list = {}

	for k, v in pairs(self.hunyin_cell_list) do
		v:DeleteMe()
	end
	self.hunyin_cell_list = {}

	for k,v in pairs(self.shengling_inlay_list) do
		v:DeleteMe()
	end
	self.shengling_inlay_list = {}
	self.stars_list = {}
	self.show_stars_list = {}
	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.HunYinUpGradeView)
	self.hunyin_inlay = nil
	self.hunyin_lingshu = nil
end

function HunYinUpGradeView:InitView(is_inlay)
	self.current_select_hunqi = 1
	self.current_selcet_shengling = 1
	self.curren_click_cell_index = -1
	HunQiData.Instance:SetCurrenSelectHunqi(self.current_select_hunqi)

	self.tab_inlay.toggle.isOn = is_inlay
	self.tab_uplevel.toggle.isOn = not is_inlay
	HunQiData.Instance:SetIsInlayOrUpdate(is_inlay)
	self.show_inlay_or_upadte:SetValue(is_inlay)

	self:FlushModel()
	self.hunqi_name_table = HunQiData.Instance:GetHunQiNameTable()
	self:FlushAttrAndActivityBtn()

	if is_inlay then
		--总览镶嵌
		self.hunyin_cell_list_view.list_view:JumpToIndex(0)

		--刷新背包
		--self.current_selcet_shengling = 1
		self:FlushTotalInlayBag()
		--刷新默认魂器的圣灵信息
		self:FlushCurrentShenglingList(self.current_hunyin_list_info)
	else
		--灵枢升级
		self:OnClickLingshuUpate()
	end
	self.hunyin_inlay:SetValue(HunQiData.Instance:CalcHunYinInlayRedPoint())
	self.hunyin_lingshu:SetValue(HunQiData.Instance:CalcHunYinLingShuRedPoint())
	self:FlushAllInfo()
end

-- 刷新右侧icon 名称 及特效
function HunYinUpGradeView:FlushRightIcon()
	local current_hunyin = self.current_hunyin_list_info[self.current_selcet_shengling]
	local hunyin_id = current_hunyin.hunyin_id
	local hunyin_info = {}
	if 0 ~= hunyin_id then
		local lingshu_level = self.current_hunyin_list_info[self.current_selcet_shengling].lingshu_level
		local lingshu_info = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1, lingshu_level)
		if lingshu_info.effect ~= 0 then
			-- self.is_show_effect:SetValue(true)
			self.hunyin_effect:SetAsset(ResPath.GetEffect(lingshu_info.effect))
		else
			self.is_show_effect:SetValue(false)
		end
		self.is_show_hunyin:SetValue(true)
		hunyin_info = self.hunyin_info[hunyin_id][1]
		self.hunqi_image:SetAsset(ResPath.GetHunYinIcon(self.current_selcet_shengling - 1, hunyin_info.hunyin_color))

		--设置icon名称
		if self.show_inlay_or_upadte:GetBoolean() then
			self.current_hunqi_name:SetValue(Language.HunYinSuitName["color_"..hunyin_info.hunyin_color]..hunyin_info.name.."</color>")
		else
			local color_id = 0
			local left = 0
			if 0 ~= lingshu_level then
				color_id, left = math.modf((lingshu_level - 1) / 25)
				color_id = color_id + 1
			end
			self.current_hunqi_name:SetValue(Language.HunYinSuitName["color_"..color_id]..lingshu_info.name.."</color>")
		end
	else
		--无物品
		self.is_show_effect:SetValue(false)
		self.is_show_hunyin:SetValue(false)
		if self.show_inlay_or_upadte:GetBoolean() then
			--镶嵌界面
			self.current_hunqi_name:SetValue(Language.HunQi.HunYinName[self.current_selcet_shengling].."·"..Language.HunQi.HunYin)
		else
			--升级界面
			local lingshu_level = self.current_hunyin_list_info[self.current_selcet_shengling].lingshu_level
			local lingshu_info = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1, lingshu_level)
			local color_id = 0
			local left = 0
			if 0 ~= lingshu_level then
				color_id, left = math.modf((lingshu_level - 1) / 5)
				color_id = color_id + 1
			end
			self.current_hunqi_name:SetValue(Language.HunYinSuit["color_"..color_id]..lingshu_info.name.."</color>")
		end
	end
	--属性icon名称
end

-- 刷新右侧属性和活动按钮
function HunYinUpGradeView:FlushAttrAndActivityBtn()
	local hunyin_id = self.current_hunyin_list_info[self.current_selcet_shengling].hunyin_id
	if 0 == hunyin_id then
		self.show_contain_or_none:SetValue(false)
		self:SetHunYinPower()
		self:FlushActivityBtns()
		self:FlushRightIcon()
	else
		self.show_contain_or_none:SetValue(true)
		--刷新当前魂器的属性数据
		self:FlushHunYinAttr()
	end
end

function HunYinUpGradeView:OnClickTotalInlay()
	self:InitView(true)
end

function HunYinUpGradeView:OnClickLingshuUpdate()
	self:InitView(false)
end

--镶嵌后刷新
function HunYinUpGradeView:FlushView()
	--刷新魂印
	self.current_hunyin_list_info = HunQiData.Instance:GetHunYinListByIndex(self.current_select_hunqi)
	--刷新背包
	if self.show_inlay_or_upadte:GetBoolean() then
		self:FlushCurrentShenglingList(self.current_hunyin_list_info)
		self:FlushTotalInlayBag()
		--刷新数据
		self.show_contain_or_none:SetValue(true)
		self:FlushHunYinAttr()
		self.curren_click_cell_index = -1
	else
		--灵枢升级右边数据
		self:FlushLingShuInfo(true)
	end
	self:FlushHunQiBtn()
	RemindManager.Instance:Fire(RemindName.HunYin_LingShu)
	self:FlushAllInfo()
end

function HunYinUpGradeView:FlushAllInfo()
	--刷新魂印
	self.current_hunyin_list_info = HunQiData.Instance:GetHunYinListByIndex(self.current_select_hunqi)
	--刷新背包
	if self.show_inlay_or_upadte:GetBoolean() then
		self:FlushCurrentShenglingList(self.current_hunyin_list_info)
		self:FlushTotalInlayBag()
		--刷新数据
		self:FlushHunYinAttr()
		self.curren_click_cell_index = -1
	else
		--灵枢升级右边数据
		self:FlushLingShuInfo(true)
	end
	self:FlushHunQiBtn()
	RemindManager.Instance:Fire(RemindName.HunYin_LingShu)
	self.hunyin_inlay:SetValue(HunQiData.Instance:CalcHunYinInlayRedPoint())
	self.hunyin_lingshu:SetValue(HunQiData.Instance:CalcHunYinLingShuRedPoint())
end
--获取当前魂印属性信息
function HunYinUpGradeView:GetCurrentShengLingInfo()
	local current_hunyin_id = self.current_hunyin_list_info[self.current_selcet_shengling].hunyin_id
	local all_attr_info = {}
	if 0 ~= current_hunyin_id then
		local current_hunyi_info = self.hunyin_info[self.current_hunyin_list_info[self.current_selcet_shengling].hunyin_id][1]
		all_attr_info = CommonStruct.AttributeNoUnderline()
		all_attr_info.fangyu = current_hunyi_info.fangyu + all_attr_info.fangyu
		all_attr_info.baoji = current_hunyi_info.baoji + all_attr_info.baoji
		all_attr_info.jianren = current_hunyi_info.jianren + all_attr_info.jianren
		all_attr_info.mingzhong = current_hunyi_info.mingzhong + all_attr_info.mingzhong
		all_attr_info.maxhp = current_hunyi_info.maxhp + all_attr_info.maxhp
		all_attr_info.gongji = current_hunyi_info.gongji + all_attr_info.gongji
		all_attr_info.shanbi = current_hunyi_info.shanbi + all_attr_info.shanbi
	end
	return all_attr_info
end

--刷新魂印战力
function HunYinUpGradeView:SetHunYinPower(lingshu_info_addper)
	--当前魂印的属性+加灵枢的加成
	if nil == lingshu_info_addper then
		lingshu_info_addper = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1,
		self.current_hunyin_list_info[self.current_selcet_shengling].lingshu_level).add_per * 0.0001
	end
	local all_attr_info = self:GetCurrentShengLingInfo()
	local power = 0
	power = math.ceil(CommonDataManager.GetCapability(all_attr_info) * (1 + lingshu_info_addper))
	self.hunyin_power:SetValue(power)
end

--刷新魂印属性数据
function HunYinUpGradeView:FlushHunYinAttr()
	--当前魂印的属性+加灵枢的加成
	local all_attr_info = self:GetCurrentShengLingInfo()
	if nil == next(all_attr_info) then
		all_attr_info = CommonStruct.AttributeNoUnderline()
	end
	local lingshu_info_addper = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1,
		self.current_hunyin_list_info[self.current_selcet_shengling].lingshu_level).add_per * 0.0001
	self.amp:SetValue((lingshu_info_addper * 100).."%")

	self.hp:SetValue(math.floor(all_attr_info.maxhp * (1 + lingshu_info_addper)))
	self.fangyu:SetValue(math.floor(all_attr_info.fangyu * (1 + lingshu_info_addper)))
	self.mingzhong:SetValue(math.floor(all_attr_info.mingzhong * (1 + lingshu_info_addper)))
	self.gongji:SetValue(math.floor(all_attr_info.gongji * (1 + lingshu_info_addper)))
	self.baoji:SetValue(math.floor(all_attr_info.baoji * (1 + lingshu_info_addper)))
	self.jianren:SetValue(math.floor(all_attr_info.jianren * (1 + lingshu_info_addper)))
	self.shanbi:SetValue(math.floor(all_attr_info.shanbi * (1 + lingshu_info_addper)))

	self:FlushRightIcon()
	--刷新战力
	self:SetHunYinPower(lingshu_info_addper)
end

function HunYinUpGradeView:FlushActivityBtns()
	-- local str = self.hunyin_get_info[self.current_selcet_shengling].get_way
	local get_way_cfg = HunQiData.Instance:GetHunYinCfg(self.current_selcet_shengling - 1)
	if get_way_cfg then
		self.show_get_way1:SetValue(get_way_cfg.get_way1 > 0)
		self.show_get_way2:SetValue(get_way_cfg.get_way2 > 0)
	end
	-- if str then
	-- 	local activ_1_id = tonumber(Split(str,',')[1])
	-- 	local activ_2_id = tonumber(Split(str,',')[2])
	-- 	local activ_3_id = tonumber(Split(str,',')[3])
	-- 	if nil ~= activ_1_id then
	-- 		self.activity_1_cfg = self.getway_cfg[activ_1_id]
	-- 		-- self.activity_1:SetAsset(ResPath.GetMainUI(self.activity_1_cfg.icon))
	-- 	else
	-- 		self.is_show_active_1:SetValue(false)
	-- 	end
	-- 	if nil ~= activ_2_id then
	-- 		self.activity_2_cfg = self.getway_cfg[activ_2_id]
	-- 		self.activity_2:SetAsset(ResPath.GetMainUI(self.activity_2_cfg.icon))
	-- 	else
	-- 		self.is_show_active_2:SetValue(false)
	-- 	end
	-- 	if nil ~= activ_3_id then
	-- 		self.is_show_active_3:SetValue(false)
	-- 		self.activity_3_cfg = self.getway_cfg[activ_3_id]
	-- 		self.activity_3:SetAsset(ResPath.GetMainUI(self.activity_3_cfg.icon))
	-- 	else
	-- 		self.is_show_active_3:SetValue(false)
	-- 	end
	-- end
end

function HunYinUpGradeView:FlushModel()
	if nil == self.model then
		self.model = RoleModel.New("hunqi_content_panel")
		self.model:SetDisplay(self.model_display.ui3d_display)
	end
	if self.current_select_hunqi > 0 then
		self.is_model_change = true
		local res_id = HunQiData.Instance:GetHunQiResIdByIndex(self.current_select_hunqi - 1)
		local asset, bundle = ResPath.GetHunQiModel(res_id)
		local function complete_callback()
			self.is_model_change = false
			if self.model then
				local is_active_special = HunQiData.Instance:IsActiveSpecial(self.current_select_hunqi)
				self.model:ShowAttachPoint(AttachPoint.Weapon, not is_active_special)
				self.model:ShowAttachPoint(AttachPoint.Weapon2, is_active_special)
			end
		end
		self.model:SetPanelName(HunQiData.Instance:SetSpecialModle(res_id))
		self.model:SetMainAsset(asset, bundle, complete_callback)
	else
		self.model:ClearModel()
	end
end

-- 刷新左边魂器按钮
function HunYinUpGradeView:FlushHunQiBtn()
	for k,v in pairs(self.hunqi_name_table) do
		--设置图标
		local parma = self.hunqi_name_table[k].res_id - 17000
		local hunqi_btn = self.hunqi_btn_list[k]
		hunqi_btn.icon_res:SetAsset(ResPath.GetHunQiImg("HunQi_"..parma))
		hunqi_btn.is_active:SetValue(false)
		hunqi_btn:OnFlush()
	end
	local level = 0
	local open_level = 0
	for i=0, HunQiData.SHENZHOU_WEAPON_COUNT-1  do
		level = HunQiData.Instance:GetHunQiLevelByIndex(i)
		--拥有的魂器
		open_level = HunQiData.Instance:GetHunQiHunYinOpenLevel(i)
		self.hunqi_btn_list[i+1]:SetLevel(level)
		if open_level <= level then
			--点亮图标
			local hunqi_btn = self.hunqi_btn_list[i+1]
			hunqi_btn.is_active:SetValue(true)
		end
	end
end

-- 刷新镶嵌背包部分
function HunYinUpGradeView:FlushTotalInlayBag()
	self:GetAllItemInfo(self.item_id_list)
	self.hunyin_cell_list_view.list_view:Reload()
end

-- 根据魂器索引刷新对应的魂印
function HunYinUpGradeView:FlushCurrentShenglingList(hunyin_list_info, is_reflush)
	--初始化圣灵选择索引
	is_reflush = is_reflush or false
	if is_reflush then
		self.current_selcet_shengling = 1
	end
	self.shengling_inlay_list[self.current_selcet_shengling].root_node.toggle.isOn = true
	--获取当前魂器对应的圣灵列表
	for k,v in pairs(self.shengling_inlay_list) do
		local hunyin_id = hunyin_list_info[k].hunyin_id
		local is_lock, need_level = HunQiData.Instance:IsHunYinLockAndNeedLevel(self.current_select_hunqi, k)
		if hunyin_id == 0 then
			v:SetData({
					solt_index = k - 1,
					hunqi_index = self.current_select_hunqi,
					is_lock = is_lock,
					inlay_or_update = self.show_inlay_or_upadte,
					is_bind =  hunyin_list_info[k].is_bind,
					hunyin_id = hunyin_id,
					lingshu_level = hunyin_list_info[k].lingshu_level,
					})
		else
			local hunyin_data = self.hunyin_info[hunyin_id][1]
			v:SetData({
					solt_index = k - 1,
					hunqi_index = self.current_select_hunqi,
					is_lock = is_lock,
					name = hunyin_data.name,
					hunyin_color = hunyin_data.hunyin_color,
					inlay_or_update = self.show_inlay_or_upadte,
					is_bind =  hunyin_list_info[k].is_bind,
					hunyin_id = hunyin_id,
					lingshu_level = hunyin_list_info[k].lingshu_level,
					})
		end
	end
end

function HunYinUpGradeView:OnClickGetWay()
	ViewManager.Instance:Open(ViewName.HunQiView,TabIndex.hunqi_bao)
end

-- 刷新当前灵枢信息
function HunYinUpGradeView:FlushLingShuInfo(is_update)
	--如果是灵枢升级
	if not self.show_inlay_or_upadte:GetBoolean() then
		local current_lingshu_info = self.current_hunyin_list_info[self.current_selcet_shengling]
		if true ~= is_update then
			is_update = false
		end
		self:FlushStars(current_lingshu_info.lingshu_level, is_update)
		self:FlushHunLingShuAttr(current_lingshu_info)
		self:FlushCurrentShenglingList(self.current_hunyin_list_info)
		self.show_update_rdp:SetValue(HunQiData.Instance:ShowLingShuUpdateRep(self.current_selcet_shengling))
		self:FlushAllLingShuPower()
	end
	self:FlushLevel()
	self:FlushRightIcon()
	self.hunyin_inlay:SetValue(HunQiData.Instance:CalcHunYinInlayRedPoint())
	self.hunyin_lingshu:SetValue(HunQiData.Instance:CalcHunYinLingShuRedPoint())
end

--刷新当前灵枢属性
function HunYinUpGradeView:FlushHunLingShuAttr(current_lingshu_info)
	local data = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, self.current_selcet_shengling - 1, current_lingshu_info.lingshu_level)
	self.hunyin_mingzhong:SetValue(data.mingzhong)
	self.hunyin_gongji:SetValue(data.gongji)
	self.hunyin_baoji:SetValue(data.baoji)
	self.hunyin_jianren:SetValue(data.jianren)
	self.hunyin_shanbi:SetValue(data.shanbi)
	self.hunyin_addper:SetValue((data.add_per * 0.01).."%")
	self.hunyin_hp:SetValue(data.maxhp)
	self.hunyin_fangyu:SetValue(data.fangyu)

	HunQiData.Instance:SetLingShuExpAndCurrentNeed(current_lingzhi,data.up_level_exp)

	local current_lingzhi = HunQiData.Instance:GetLingshuExp()
	if current_lingshu_info.lingshu_level == HunQiData.Instance:GetLingshuAttrMaxLevel(self.current_select_hunqi - 1, self.current_selcet_shengling - 1) then
		self.is_max_levle:SetValue(true)
		self.exp_cost:SetValue("--/--")
	else
		self.is_max_levle:SetValue(false)
		if current_lingzhi < data.up_level_exp then
			self.exp_cost:SetValue("<color=#fe3030>"..current_lingzhi.."</color>".. " / " ..data.up_level_exp)
		else
			self.exp_cost:SetValue(string.format(Language.Common.ShowBlueNum, current_lingzhi) .." / "..data.up_level_exp)
		end
	end
	self:SetLingShuPower(data)
end

function HunYinUpGradeView:SetLingShuPower(data)
	local lingshu_attr = CommonStruct.AttributeNoUnderline()
	lingshu_attr.fangyu = data.fangyu
	lingshu_attr.baoji = data.baoji
	lingshu_attr.gongji = data.gongji
	lingshu_attr.jianren = data.jianren
	lingshu_attr.mingzhong = data.mingzhong
	lingshu_attr.maxhp = data.maxhp
	lingshu_attr.shanbi = data.shanbi
	local power = 0
	power = CommonDataManager.GetCapability(lingshu_attr)
	self.lingshu_power:SetValue(power)
end

--刷新当前魂器的所有灵枢的战力加成
function HunYinUpGradeView:FlushAllLingShuPower()
	local power = 0
	for i = 1, #self.shengling_inlay_list do --所有灵枢
		local current_lingshu_info = self.current_hunyin_list_info[i]
		local data = nil
		if current_lingshu_info then
			data = HunQiData.Instance:GetLingshuAttrByIndex(self.current_select_hunqi - 1, i - 1, current_lingshu_info.lingshu_level)
		end
		if data then
			local lingshu_attr = CommonStruct.AttributeNoUnderline()
			lingshu_attr.fangyu = data.fangyu
			lingshu_attr.baoji = data.baoji
			lingshu_attr.gongji = data.gongji
			lingshu_attr.jianren = data.jianren
			lingshu_attr.mingzhong = data.mingzhong
			lingshu_attr.maxhp = data.maxhp
			lingshu_attr.shanbi = data.shanbi
			power = power + CommonDataManager.GetCapability(lingshu_attr)
		end
	end
	self.all_lingshu_power:SetValue(power)
end

--刷新所有灵枢的等级
function HunYinUpGradeView:FlushLevel()
	for i = 1,#self.shengling_inlay_list do
		self.shengling_inlay_list[i].level:SetValue(self.current_hunyin_list_info[i].lingshu_level)
	end
end

--刷新所有星星
function HunYinUpGradeView:FlushStars(index, isUpdate)
	--获取当前圣灵等级
	if 0 ~= index then
		index = index % 5
		if index == 0 then
			index = 5
		end
	end
	for i = 1, index do
		local bundle, asset = ResPath.GetStarImages("star_front_img")
		self.stars_list[i].grayscale.GrayScale = 0
		--self.show_stars_list[i]:SetValue(false)  --设置星星背景，如果该星星激活则不显示星星背景
	end
	for i = index + 1, 5 do
		local bundle, asset = ResPath.GetStarImages("star_background_img")
		self.stars_list[i].grayscale.GrayScale = 255
		--self.show_stars_list[i]:SetValue(true)
	end
	if 0 ~= index then
		if isUpdate then
			--EffectManager.Instance:PlayAtTransform("effects/prefabs", "Effect_baodian", self.stars_list[index].transform, 1.0, nil, nil)
		end
	end
end

-- 刷新
function HunYinUpGradeView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "resolve" then
			local current_lingshu_info = self.current_hunyin_list_info[self.current_selcet_shengling]
			self:FlushHunLingShuAttr(current_lingshu_info)
			self:FlushAllLingShuPower()
			self.show_update_rdp:SetValue(HunQiData.Instance:ShowLingShuUpdateRep(self.current_selcet_shengling))
			for k,v in pairs(self.hunqi_btn_list) do
				v:Flush()
			end
			for k,v in pairs(self.shengling_inlay_list) do
				v:Flush()
			end
		end
	end
end

function HunYinUpGradeView:NumberOfCellsDel()
	return NumOfHunyinCells
end

-- 获取背包中所有魂印配置信息
function HunYinUpGradeView:GetAllItemInfo(item_id_list)
	self.all_hunyin_info = {}
	for k, v in pairs(item_id_list) do
		local count = ItemData.Instance:GetItemNumInBagById(v)
		local solt_index = self.hunyin_info[v][1].inlay_slot + 1
		if count > 0 and solt_index == self.current_selcet_shengling then
			local group_count = math.ceil(count / 999)
			if group_count > 1 then
				for i=1, group_count - 1 do
					table.insert(self.all_hunyin_info, {item_id = v, num = 999, is_bind = 0 })
				end
				count = count % 999
				table.insert(self.all_hunyin_info, {item_id = v, num = count, is_bind = 0 })
			else
				table.insert(self.all_hunyin_info, {item_id = v, num = count, is_bind = 0 })
			end
		end
	end
end
-- cell刷新 每个进入一次
function HunYinUpGradeView:CellRefreshDel(data_index, cell)
	--每次进入前清空数据
	data_index = data_index + 1

	local item_cell = self.hunyin_cell_list[cell]
	if nil == item_cell then
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(cell.gameObject)
		item_cell:SetToggleGroup(self.hunyin_cell_list_view.toggle_group)
		self.hunyin_cell_list[cell] = item_cell
	end
	item_cell.root_node.toggle.isOn = false
	-- item_cell.root_node.toggle.isOn = false
	--有数据插入数据 没数据设置nil
	if data_index % 6 == 2 then
		data_index = data_index + 2
	elseif data_index % 6 == 3 then
		data_index = data_index - 1
	elseif data_index % 6 == 4 then
		data_index = data_index + 1
	elseif data_index % 6 == 5 then
		data_index = data_index - 2
	end
	local current_data = self.all_hunyin_info[data_index]
	item_cell:SetData(current_data)
	item_cell:SetIndex(data_index)
	if current_data then
		item_cell:ListenClick(BindTool.Bind(self.OnClickItem, self, item_cell))
		item_cell:SetInteractable(true)
		item_cell.icon:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(current_data.item_id)))
		if current_data.num > 1 then
			item_cell.show_number:SetValue(true)
			item_cell.number:SetValue(current_data.num)
		end
	else
		item_cell:SetInteractable(false)
	end
end

--点击背包格子
function HunYinUpGradeView:OnClickItem(item_cell)
	local function close_call_back()
		item_cell:SetHighLight(false)
		self.curren_click_cell_index = -1
	end
	local function replace_open_call_back()
		return self.current_hunyin_list_info[self.current_selcet_shengling].hunyin_id, item_cell:GetData().item_id,
			self.current_select_hunqi, self.current_selcet_shengling
	end
	HunQiCtrl.Instance:SetReplaceCallBack(close_call_back)
	HunQiCtrl.Instance:SetInlayCallBack(close_call_back)

	local cell_hunyin_info = HunQiData.Instance:GetHunQiInfo()[item_cell:GetData().item_id][1]
	local bag_inlay_slot = cell_hunyin_info.inlay_slot

	for k,v in pairs(self.shengling_inlay_list) do
		local inlay_data = v:GetData()
		if inlay_data.solt_index == bag_inlay_slot then
			if inlay_data.hunyin_id == 0 then
				--如果未镶嵌 --镶嵌界面
				local function open_call_back()
					return self.current_select_hunqi, bag_inlay_slot + 1, item_cell:GetData().item_id
				end
				HunQiCtrl.Instance:SetInlayOpenCallBack(open_call_back)
				ViewManager.Instance:Open(ViewName.HunYinInlayTips)
			else
				--如果已经镶嵌	--可替换
			 	if inlay_data.hunyin_color <= cell_hunyin_info.hunyin_color then
			 		if inlay_data.hunyin_id == cell_hunyin_info.hunyin_id then
			 			SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.HunYinIsSame)
			 		else
				 		local function replace_open_call_back()
		 					return inlay_data.hunyin_id, cell_hunyin_info.hunyin_id,
							self.current_select_hunqi, bag_inlay_slot + 1
						end
				 		HunQiCtrl.Instance:SetReplaceOpenCallBack(replace_open_call_back)
				 		ViewManager.Instance:Open(ViewName.HunYinReplaceTipsView)
				 	end
			 	else
			 		--id相同 相同魂印
			 		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.HunYinLowLevel)
			 		item_cell.root_node.toggle.isOn = false
				end
			end
		end
	end
end

-- 圣灵镶嵌格子点击事件
function HunYinUpGradeView:InlayClick(inlay_cell)
	self.current_selcet_shengling =	inlay_cell:GetIndex()
	if not inlay_cell.root_node.toggle.isOn then
		inlay_cell.root_node.toggle.isOn = true
		return
	end
	local is_inlay = self.show_inlay_or_upadte:GetBoolean()
	-- 如果当前魂器等级不足 返回
	local is_lock, need_level = HunQiData.Instance:IsHunYinLockAndNeedLevel(self.current_select_hunqi, self.current_selcet_shengling)
	local get_way_cfg = HunQiData.Instance:GetHunYinCfg(self.current_selcet_shengling - 1)
	if get_way_cfg then
		self.show_get_way1:SetValue(get_way_cfg.get_way1 > 0)
		self.show_get_way2:SetValue(get_way_cfg.get_way2 > 0)
	end
	if is_lock then
		local des = ""
		if is_inlay then
			des = string.format(Language.HunQi.HunYinLock, need_level)
		else
			des = string.format(Language.HunQi.LingShuLock, need_level)
		end
		SysMsgCtrl.Instance:ErrorRemind(des)
	end
	self:FlushAttrAndActivityBtn()
	if is_inlay then
	--当前为镶嵌界面
		self:FlushTotalInlayBag()
		self:FlushHunYinAttr()
	else
	--当前为升级界面
		self:FlushLingShuInfo()
	end
end

-- 魂器按钮点击事件
function HunYinUpGradeView:HunQiBtnClick(hunqi_btn)
	if not hunqi_btn.root_node.toggle.isOn then
		hunqi_btn.root_node.toggle.isOn = true
		return
	end
	self.current_select_hunqi = hunqi_btn:GetIndex()
	HunQiData.Instance:SetCurrenSelectHunqi(self.current_select_hunqi)
	self.current_hunyin_list_info = HunQiData.Instance:GetHunYinListByIndex(self.current_select_hunqi)
	self:FlushCurrentShenglingList(self.current_hunyin_list_info)
	self:FlushLingShuInfo()
	self:FlushModel()
	self:FlushAttrAndActivityBtn()
	self:FlushAllLingShuPower()
end

function HunYinUpGradeView:GetCurrentSelectHunQi()
	return self.current_select_hunqi
end

-- 点击魂印总览
function HunYinUpGradeView:OnClickAllAttr()
	ViewManager.Instance:Open(ViewName.HunYinAllView)
end

-- 点击灵枢升级
function HunYinUpGradeView:OnClickLingshuUpate()
	--刷新数据
	self:FlushLingShuInfo()
	self.show_update_rdp:SetValue(HunQiData.Instance:ShowLingShuUpdateRep(self.current_selcet_shengling))
	self:FlushHunQiBtn()
end

-- 点击右滑
function HunYinUpGradeView:OnClickRight()
	self.hunqi_list_obj.scroll_rect.horizontalNormalizedPosition = 1
end

-- 点击左滑
function HunYinUpGradeView:OnClickLeft()
	self.hunqi_list_obj.scroll_rect.horizontalNormalizedPosition = 0
end

-- 点击套装
function HunYinUpGradeView:OnClickSuit()
	local function open_call_back()
		return self.current_select_hunqi, self.current_hunyin_list_info
	end
	HunQiCtrl.Instance:SetSuitOpenCallBack(open_call_back)
	ViewManager.Instance:Open(ViewName.HunYinSuitView)
end

-- 点击活动1
function HunYinUpGradeView:OnClickActivity1()
	local view_Name = Split(self.activity_1_cfg.open_panel, '#')[1]
	local table_index= Split(self.activity_1_cfg.open_panel, '#')[2]
	ViewManager.Instance:Open(view_Name, TabIndex[table_index])

end

-- 点击活动2
function HunYinUpGradeView:OnClickActivity2()
	local view_Name = Split(self.activity_2_cfg.open_panel, '#')[1]
	local table_index= Split(self.activity_2_cfg.open_panel, '#')[2]
	ViewManager.Instance:Open(view_Name, TabIndex[table_index])
end

-- 点击活动3
function HunYinUpGradeView:OnClickActivity3()
 	local view_Name = Split(self.activity_3_cfg.open_panel, '#')[1]
	local table_index= Split(self.activity_3_cfg.open_panel, '#')[2]
	ViewManager.Instance:Open(view_Name, TabIndex[table_index])
end

-- 分解
function HunYinUpGradeView:ClickResolve()
	ViewManager.Instance:Open(ViewName.HunYinResolve)
end

function HunYinUpGradeView:ClickExchange()
	ViewManager.Instance:Open(ViewName.HunYinExchangView)
end

-- 注灵
function HunYinUpGradeView:OnShenglingUpdate()
	local is_lock, need_level = HunQiData.Instance:IsHunYinLockAndNeedLevel(self.current_select_hunqi, self.current_selcet_shengling)
	if is_lock then
		local des = string.format(Language.HunQi.LingShuLock, need_level)
		SysMsgCtrl.Instance:ErrorRemind(des)
		return
	end
	HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_UPLEVEL_LINGSHU,
		self.current_select_hunqi - 1, self.current_selcet_shengling - 1)
end

function HunYinUpGradeView:ClickRule()
	if self.show_inlay_or_upadte:GetBoolean() then
		TipsCtrl.Instance:ShowHelpTipView(195)
	else
		TipsCtrl.Instance:ShowHelpTipView(196)
	end
end