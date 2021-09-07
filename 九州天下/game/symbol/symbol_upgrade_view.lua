-- 进阶界面
SymbolUpgradeView = SymbolUpgradeView or BaseClass(BaseRender)

local SYMBOL_COUNT = 5					-- 元素之灵的个数
local EFFECT_CD = 1.8

function SymbolUpgradeView:__init()

	self.cur_select_index = 0			--当前所选中的元素的索引 0 开始
	self.last_model_index = -1			--上一个模型的索引
	self.attribute_cell_list = {}		--属性的list表
	self.tabbar_cell_list = {}			--TabBar的格子list表
	self.wuxing_list_active = {}		--五行的激活情况
	self.attribute_list_data = {}				--属性list data数据
	self.jinjie_next_time = 0
	self.is_one_key = false
	self.is_auto_buy = false
	self.is_auto = false
	self.is_can_auto = true
	self.temp_grade = -1 				--上一等级


	self:InitSymbolModel()

	self.consume_img = ItemCell.New()
	self.consume_img:SetInstanceParent(self:FindObj("Consume_Img"))

	self.auto_btn = self:FindObj("AutoBtn")
	self.auto_buy_toggle = self:FindObj("AutoToggle")


	self.level_text = self:FindVariable("Level_Text")
	self.next_level_text = self:FindVariable("NextLevel_Text")
	self.zhanli_text = self:FindVariable("Zhanli_Text")
	self.jinjie_slider = self:FindVariable("Jinjie_Slider")
	self.consume_text = self:FindVariable("Consume_Text")
	self.show_jihuo = self:FindVariable("ShowJiHuo")
	self.show_model = self:FindVariable("ShowModel")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.jinjie_value_text = self:FindVariable("Jinjie_Value_Text")
	self.quality = self:FindVariable("QualityBG")
	self.name_text = self:FindVariable("Name_Text")
	self.percent_text = self:FindVariable("Percent_Text")

	self.hp = self:FindVariable("HP")
	self.gong_ji = self:FindVariable("Gongji")
	self.fang_yu = self:FindVariable("Fangyu")
	self.ming_zhong = self:FindVariable("Mingzhong")
	self.shan_bi = self:FindVariable("ShanBi")
	self.bao_ji = self:FindVariable("Baoji")
	self.jian_ren = self:FindVariable("Kangbao")

	self.show_effect = self:FindVariable("ShowEffect")

	self.can_jinjie = self:FindVariable("CanJinJie")

	self:ListenEvent("ClickJinjie",BindTool.Bind(self.OnStartAdvance,self))
	self:ListenEvent("ClickZidong",BindTool.Bind(self.OnAutomaticAdvance,self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.OnClickHelp))

end

function SymbolUpgradeView:__delete()

	for i,v in ipairs(self.attribute_cell_list) do
		v:DeleteMe()
	end
	self.attribute_cell_list = {}

	for i,v in ipairs(self.tabbar_cell_list) do
		v:DeleteMe()
	end
	self.tabbar_cell_list = {}

	if self.symbol_model then
		self.symbol_model:DeleteMe()
		self.symbol_model = nil
	end

	self.center_display = nil
	self.consume_img = nil
	self.tab_item_list = {}
	self.last_model_index = -1
	self.jinjie_next_time = nil
	self.temp_grade = -1
end

function SymbolUpgradeView:OpenCallBack()
	local data_list = SymbolData.Instance:GetElementList()
	if #data_list == 0 then return end
	for k,v in pairs(data_list) do
		if v.grade <= 0 then
			self.wuxing_list_active[k] = false
		else
			self.wuxing_list_active[k] = true
		end
	end

	local info = SymbolData.Instance:GetElementInfo(0)
	if info == nil then
		return
	end

	if info.grade <= 0 then
		self.show_jihuo:SetValue(true)
	else
		self.show_jihuo:SetValue(false)
		self.show_model:SetValue(true)
		self:SetSymbolModelData(info.wuxing_type)
	end
	self.cur_select_index = 0

	if self.show_effect then
		self.show_effect:SetValue(false)
	end

	self:InitTabBarListView()
	self:Flush()
end

function SymbolUpgradeView:CloseCallBack()
	self.temp_grade = -1
	self:CancelTheQuest()
end

function SymbolUpgradeView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "heart_upgrade_result" then
			self:ElementHeartUpgradeResult(v[1])
		else
			self:LeftFlush()
			self:RightFlush()
		end
	end
end

function SymbolUpgradeView:LeftFlush()
	local element_info = SymbolData.Instance:GetElementInfo(self.cur_select_index)
	if element_info == nil or element_info.grade <=0 then return end

	--当级属性
	local cur_info_cfg = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade)
	local cur_attr = CommonDataManager.GetAttributteNoUnderline(cur_info_cfg)

	self.hp:SetValue(cur_attr.maxhp)
	self.gong_ji:SetValue(cur_attr.gongji)
	self.fang_yu:SetValue(cur_attr.fangyu)
	self.ming_zhong :SetValue(cur_attr.mingzhong)
	self.shan_bi:SetValue( cur_attr.shanbi)
	self.bao_ji:SetValue(cur_attr.baoji)
	self.jian_ren:SetValue( cur_attr.jianren)

	if SymbolData.Instance:GetElementMaxGrade() <= element_info.grade then return end
	if self.temp_grade < 0 then
		self.temp_grade = element_info.grade
	else
		if self.temp_grade < element_info.grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.show_effect:SetValue(false)
				self.show_effect:SetValue(true)
				self.effect_cd = EFFECT_CD + Status.NowTime
			end
		end
		self.temp_grade = element_info.grade
	end
end

function SymbolUpgradeView:RightFlush()
	local cfg = SymbolData.Instance:GetYHStuffCfg()
	local cur_have = ItemData.Instance:GetItemNumInBagById(cfg.item_id)
	local data = {item_id = cfg.item_id}
	self.consume_img:SetData(data)

	if not self.wuxing_list_active[self.cur_select_index] then		--如果还没激活就初始化数据
		self.zhanli_text:SetValue(0)
		self.jinjie_slider:SetValue(0)
		self.level_text:SetValue("")
		self.consume_text:SetValue(cur_have.."/0")
		self.jinjie_value_text:SetValue("0/0")
		return
	end

	local element_info = SymbolData.Instance:GetElementInfo(self.cur_select_index)
	if element_info == nil then
		return
	end

	--当级属性
	local cur_info_cfg = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade)
	if cur_info_cfg == nil then
		return
	end

	local cur_attr = CommonDataManager.GetAttributteNoUnderline(cur_info_cfg)

	local show_color = TEXT_COLOR.GREEN
	if cur_have < cur_info_cfg.need_item_num then
		show_color = TEXT_COLOR.RED
	end

	local show_num = ToColorStr(cur_have, show_color)
	self.consume_text:SetValue(show_num .. "/"..cur_info_cfg.need_item_num)

	local cur_bless = element_info.bless
	local need_bless = cur_info_cfg.bless_val_limit
	local percent = 0
	local str = Language.Common.NumToChs[element_info.grade-1]
	local next_str = Language.Common.NumToChs[element_info.grade]

	if element_info.grade >= SymbolData.Instance:GetElementMaxGrade() then
		local cfg = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade)
		percent = cfg and cfg.add_texture_percent_attr/100 or 0
		self.jinjie_value_text:SetValue(Language.Common.YiMan)
		self.jinjie_slider:InitValue(1)
		self.next_level_text:SetValue(Language.Symbol.NowLevel)
	else
		local cfg = SymbolData.Instance:GetElementHeartCfgByGrade(element_info.grade+1)
		percent = cfg and cfg.add_texture_percent_attr/100 or 0
		self.jinjie_value_text:SetValue(element_info.bless.."/"..cur_info_cfg.bless_val_limit)
		self.jinjie_slider:SetValue(cur_bless/need_bless)
		self.next_level_text:SetValue(next_str)
	end
	self.percent_text:SetValue(percent)
	self.level_text:SetValue(string.format(Language.Symbol.Level,str))

	local capability = CommonDataManager.GetCapabilityCalculation(cur_attr)
	self.zhanli_text:SetValue(capability)

	local bundle, asset = nil, nil
	if math.floor(element_info.grade / 3 + 1) >= 5 then
		 bundle, asset = ResPath.GetMountGradeQualityBG(5)
	else
		 bundle, asset = ResPath.GetMountGradeQualityBG(math.floor(element_info.grade / 3 + 1))
	end
	self.quality:SetAsset(bundle, asset)

	local color = (element_info.grade / 3 + 1) >= 5 and 5 or math.floor(element_info.grade / 3 + 1)
	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..Language.Symbol.ElementsName[element_info.wuxing_type].."</color>"
	self.name_text:SetValue(name_str)


	self.tabbar_list_view.scroller:RefreshAndReloadActiveCellViews(true)

	self:SetAutoButtonGray()
end

function SymbolUpgradeView:InitTabBarListView()
	self.tabbar_list_view = self:FindObj("TabBarListView")
	self.tabbar_list_data = SymbolData.Instance:GetElementList()		--TabBar List 的 data数据
	local tabbar_list_delegate = self.tabbar_list_view.list_simple_delegate
	tabbar_list_delegate.NumberOfCellsDel = function ()
		return #self.tabbar_list_data+1
	end

	tabbar_list_delegate.CellRefreshDel = function (cell_obj,index)
		index = index + 1
		local cell = self.tabbar_cell_list[cell_obj]
		if nil == cell then
			cell = TabBarCell.New(cell_obj.gameObject)
			cell:SetToggleGroup(self.tabbar_list_view.toggle_group)
			self.tabbar_cell_list[cell_obj] = cell
		end
		cell:SetIndex(index)
		cell:SetData(self.tabbar_list_data[index-1])
		cell:IsOn(index-1 == self.cur_select_index)
		--cell:Lock(self.tabbar_list_data[index-1] ~= nil and self.tabbar_list_data[index-1].grade <= 0)
		cell:SetClickCallBack(BindTool.Bind(self.TabItemClick,self,cell))
	end
end

--初始化模型
function SymbolUpgradeView:InitSymbolModel()
	self.center_display = self:FindObj("CenterDisplay")
	if not self.symbol_model then
		self.symbol_model = RoleModel.New("symbol_panel")
		self.symbol_model:SetDisplay(self.center_display.ui3d_display)
	end
end

--设置模式数据
function SymbolUpgradeView:SetSymbolModelData(index)
	if self.last_model_index == index then return end
	self.last_model_index = index

	local model_res = SymbolData.Instance:GetModelResIdByElementId(index)
	local asset, bundle = ResPath.GetWuXinZhiLingModel(model_res)
	self.symbol_model:SetMainAsset(asset, bundle)
	self.symbol_model:SetModelScale(Vector3(1.5,1.5, 1.5))
end

--进阶一次
function SymbolUpgradeView:OnStartAdvance()
	if not self.wuxing_list_active[self.cur_select_index] then return end
	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn
	local info = SymbolData.Instance:GetElementInfo(self.cur_select_index)
	if info == nil then
		return
	end

	local cfg = SymbolData.Instance:GetYHStuffCfg()
	local item_id = cfg.item_id
	local num = ItemData.Instance:GetItemNumInBagById(item_id)

	local heart_cfg = SymbolData.Instance:GetElementHeartCfgByGrade(info.grade)
	local need_item_num = heart_cfg and heart_cfg.need_item_num or 0
	local element_info = SymbolData.Instance:GetElementInfo(self.cur_select_index)
	if element_info == nil then
		return
	end

	if num < need_item_num and not is_auto_buy_toggle then
		-- 物品不足，弹出Tip框
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end

		local func = function ( item_id2,item_num,is_bind,is_use,is_buy_quick )
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.toggle.isOn = true
			end
		end
		local need  = need_item_num - num
		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		return
	end


	local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0
	local pack_num = 1
	local next_time = 0.1

	local heart_cfg = SymbolData.Instance:GetElementHeartCfgByGrade(info.grade)
	if heart_cfg then
		pack_num = heart_cfg.need_item_num
	end

	SymbolCtrl.Instance:SendUpgradeGhostReq(info.id, self.is_one_key and pack_num or 1, is_auto_buy)
	self.jinjie_next_time = Status.NowTime + next_time

	self.tabbar_list_view.scroller:RefreshAndReloadActiveCellViews(true)
end

function SymbolUpgradeView:SetAutoButtonGray()
	local info = SymbolData.Instance:GetElementInfo(self.cur_select_index)
	if info == nil or info.grade == nil then return end

	local max_grade = SymbolData.Instance:GetElementMaxGrade()

	if not info or not info.grade or info.grade <= 0
		or info.grade >= max_grade then
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.can_jinjie:SetValue(false)
		return
	end
	if self.is_auto then
		self.auto_btn_text:SetValue(Language.Common.Stop)
		self.can_jinjie:SetValue(true)
	else
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.can_jinjie:SetValue(true)
	end
end

--自动进阶
function SymbolUpgradeView:OnAutomaticAdvance()
	if not self.wuxing_list_active[self.cur_select_index] then return end
	local info = SymbolData.Instance:GetElementInfo(self.cur_select_index)

	if info == nil or info.grade == 0 then
		return
	end

	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		self.is_auto = self.is_auto == false
		self.is_can_auto = false
		self:OnStartAdvance()
		self:SetAutoButtonGray()
	end

	ok_callback()
end

--时间延迟监听 自动进阶一次
function SymbolUpgradeView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.is_auto then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnStartAdvance, self), jinjie_next_time)
	end
end

function SymbolUpgradeView:CancelTheQuest()
	if self.upgrade_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.is_auto = false
	self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
end

--服务端自动进阶返回监听
function SymbolUpgradeView:ElementHeartUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

--根据tabitem的index来判断点击事件
function SymbolUpgradeView:TabItemClick(cell)
	self.cur_select_index = cell.index - 1
	self.temp_grade = -1
	local element_info = SymbolData.Instance:GetElementInfo(cell.index-1)
	if element_info == nil then
		return
	end

	if self.wuxing_list_active[cell.index - 1] then
		self.show_jihuo:SetValue(false)
		self.show_model:SetValue(true)
		self:SetSymbolModelData(element_info.wuxing_type)
	else
		self.show_jihuo:SetValue(true)
		self.show_model:SetValue(false)
	end
	self:Flush()
end

function SymbolUpgradeView:OnClickHelp()
	local tip_id = 269
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

----------------------元素标签头像格子-----------------------
TabBarCell = TabBarCell or BaseClass(BaseCell)

function TabBarCell:__init()
	self.model_index = 0

	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.remind = self:FindVariable("Remind")
	self.lock = self:FindVariable("Lock")
	self:ListenEvent("OnClick",
		BindTool.Bind(self.OnClick, self))
	self:ListenEvent("OnLockClick",BindTool.Bind(self.OnLockClick,self))
end

function TabBarCell:IsOn(value)
	self.root_node.toggle.isOn = value
end

function TabBarCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function TabBarCell:Lock(value)
	self.lock:SetValue(value)
end

function TabBarCell:OnLockClick()
	local cfg = SymbolData.Instance:GetUpgradeLimitById(self.data.id)
	if cfg == nil then
		return
	end

	if self.data.grade < cfg.last_element_level and self.data.grade > 0 then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Symbol.ElementLevel,cfg.last_element_level))
	end
end

function TabBarCell:SetModelIndex(index)
	self.model_index = index
end

function TabBarCell:GetModelIndex()
	return self.model_index
end

function TabBarCell:OnFlush()
	if nil == self.data then return end
	--红点提示
	self.remind:SetValue(false)
	local item_id = SymbolData.Instance:GetYHStuffCfg().item_id

	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	local need_item_num = -1

	self.icon:SetAsset(ResPath.GetSymbolImage("yuansu_icon_" .. self.data.id))
	if self.data.grade > 0 then
		local heart_cfg = SymbolData.Instance:GetElementHeartCfgByGrade(self.data.grade)
		need_item_num = heart_cfg and heart_cfg.need_item_num or 0
		self.remind:SetValue(num>=need_item_num and self.data.grade < SymbolData.Instance:GetElementMaxGrade() or false)
		local color = (self.data.grade / 3 + 1) >= 5 and 5 or math.floor(self.data.grade / 3 + 1)
		local str = "<color="..LIAN_QI_NAME_COLOR[color]..">"..Language.Common.NumToChs[self.data.grade-1].."阶".."</color>"
		self.name:SetValue(str)
	else
		self.name:SetValue("")
	end

	if self.data.id == 0 then
		if self.data.grade <= 0 then
			self:Lock(true)
		else
			self:Lock(false)
		end
		return
	end

	local limit_cfg = SymbolData.Instance:GetUpgradeLimitById(self.data.id)
	if limit_cfg == nil then
		return
	end

	local last_cfg = SymbolData.Instance:GetElementInfo(self.data.id -1)
	if last_cfg and last_cfg.grade >= limit_cfg.last_element_level +1 and self.data.grade > 0 then
		self:Lock(false)
	else
		self.remind:SetValue(false)
		self.name:SetValue("")
		self:Lock(true)
	end
end