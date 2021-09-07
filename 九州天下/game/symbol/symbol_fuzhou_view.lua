-- 附纹界面
SymbolFuzhouView = SymbolFuzhouView or BaseClass(BaseRender)

local SHEN_EQUIP_NUM = 10						-- 神装部位数量

function SymbolFuzhouView:__init()
	--变量
	self.cur_equip_index = 1						--当前所选择装备 从1开始
	self.attribute_list_data = {}					--属性Item的数据
	self.cur_consume_select = 0 					--当前消耗品所选择的
	self.select_sonsume_cell_data = nil				--选中消耗品格子
	self.consume_list_data = {}						--消耗品的数据
	self.cur_wuxing_type = 0 						--当前五行
	self.wuxing_jihuo_list = {} 					--是否已激活五行之灵
	self.jinjie_next_time = 0
	self.upgrade_timer_quest = nil
	self.is_auto = false
	self.is_can_auto = true
	self.is_can_jinjie = true
	self.add_percent = 0 							--进阶的加成的百分比
	self.one_youxian_show = false					--最优先显示
	self.two_youxian_show = false

	self.equip_cell_list = {}						--装备下的ItemCell的list
	self.consume_cell_list = {}						--消耗品下的ItemCell的list
	self.attribute_cell_list = {}					--属性值下的AttributeCell的list
	self.show_line_list = {}						--显示线条的list

	self.last_model_index = -1 						--上一个模型的索引
	self.last_show_line_index = 1   				--上一条line的索引

	self.equip_toggle_group = self:FindObj("EquipToggleGroup")
	self.consume_toggle_group = self:FindObj("ConsumeToggleGroup")
	self.center_display = self:FindObj("CenterDisplay")
	self:InitSymbolModel()

	for i=1,SHEN_EQUIP_NUM do
		self.equip_cell_list[i] = ItemCell.New()
		self.equip_cell_list[i]:SetInstanceParent(self:FindObj("EquipItem_"..i))
		self.equip_cell_list[i]:SetToggleGroup(self.equip_toggle_group.toggle_group)
		self.equip_cell_list[i]:ListenClick(BindTool.Bind(self.OnClickEquipItem,self,i))
		self.equip_cell_list[i]:SetInteractable(true)
		self.show_line_list[i] = self:FindVariable("ShowLine_"..i)
	end

	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))
	self.equip_item:SetInteractable(false)

	self:ListenEvent("ClickJinjie",BindTool.Bind(self.OnClickJinjie,self))
	self:ListenEvent("ClickYijian",BindTool.Bind(self.OnClickYijian,self))
	self:ListenEvent("ClickHelp",BindTool.Bind(self.OnClickHelp))

	self.name_text = self:FindVariable("NameText")
	self.jinjie_slide_value = self:FindVariable("JinjieSlideValue")
	self.jinjie_slide_value_text = self:FindVariable("JinjieSlideValueText")
	self.show_jihuo = self:FindVariable("ShowJiHuo")
	self.auto_btn_text = self:FindVariable("AutoBtnText")
	self.show_model = self:FindVariable("ShowModel")
	self.jihuo_text = self:FindVariable("JihuoText")
	self.equip_name = self:FindVariable("EquipNameText")
	self.zhanli_text = self:FindVariable("Zhanli_Text")
	self.all_zhanli_text = self:FindVariable("AllZhanli_Text")
	self.can_jinjie = self:FindVariable("CanJinJie")
	self.can_auto_jinjie = self:FindVariable("CanAutoJinJie")
end

function SymbolFuzhouView:__delete()
	if self.equip_item then
		self.equip_item:DeleteMe()
		self.equip_item = nil
	end

	for i,v in ipairs(self.equip_cell_list) do
		v:DeleteMe()
	end
	self.equip_cell_list = {}

	for i,v in ipairs(self.consume_cell_list) do
		v:DeleteMe()
	end
	self.consume_cell_list = {}

	for i,v in ipairs(self.attribute_cell_list) do
		v:DeleteMe()
	end
	self.attribute_cell_list = {}

	if self.symbol_model then
		self.symbol_model:DeleteMe()
		self.symbol_model = nil
	end

	--清理对象和变量
	self.equip_toggle_group = nil
	self.consume_toggle_group = nil
	self.attribute_list_view = nil
	self.consume_list_view = nil
	self.last_model_index = -1
	self.cur_wuxing_type = 0
	self.select_sonsume_cell_data = nil
	self.attribute_list_data = {}
	self.consume_list_data = {}
	self.wuxing_jihuo_list = {}
end

function SymbolFuzhouView:InitAttributeListView()
	self.attribute_list_view = self:FindObj("AttributeListView")
	local attribute_list_delegate = self.attribute_list_view.list_simple_delegate
	local wuxing_type = SymbolData.Instance:GetEquipByWuxing(self.cur_equip_index - 1)
	if self.wuxing_jihuo_list[wuxing_type] ==nil then
		self.attribute_list_data[self.cur_equip_index] = {}
	end
	attribute_list_delegate.NumberOfCellsDel = function ( )
		return #self.attribute_list_data[self.cur_equip_index]
	end

	attribute_list_delegate.CellRefreshDel = function ( cell_obj,index )
		index = index + 1
		local cell = self.attribute_cell_list[cell_obj]
		if nil == cell then
			cell = AttributeCell.New(cell_obj.gameObject)

			self.attribute_cell_list[cell_obj] = cell
		end
		cell:SetData(self.attribute_list_data[self.cur_equip_index][index])
	end

end

function SymbolFuzhouView:InitConsumeListView()
	self.consume_list_view = self:FindObj("ConsumeListView")
	self.consume_list_data = SymbolData.Instance:GetYSStuffCfg(self.cur_wuxing_type) or {}			--消耗品的数据
	local consume_list_delegate = self.consume_list_view.list_simple_delegate
	consume_list_delegate.NumberOfCellsDel = function ()
		return #self.consume_list_data
	end

	consume_list_delegate.CellRefreshDel = function (cell_obj,index)
		index = index + 1
		local cell = self.consume_cell_list[cell_obj]
		if nil == cell then		--在判断是否为nil再设置数据，否则数据会错误引用
			cell = ConsumeCell.New(cell_obj.gameObject)
			self.consume_cell_list[cell_obj] = cell
		end
		cell:SetData(self.consume_list_data[index])
		cell:SetClickCallBack(BindTool.Bind(self.OnClickConsumeItem,self,index,cell))
		cell:SetToggleGroup(self.consume_toggle_group.toggle_group)

		cell:GetToggle().isOn = self.cur_consume_select == index or false
	end
end

function SymbolFuzhouView:OpenCallBack()
	self.is_first = true

	local data = SymbolData.Instance:GetElementList()
	if nil == data then return end

	local jihuo_wuxing = 0
	self.add_percent = 0
	local wuxing_list = {}
	for k,v in pairs(data) do
		wuxing_list[k+1] = {wuxing_type = v.wuxing_type,is_jihuo = v.grade >= 1 or false}
		if v.grade >=1 then
			jihuo_wuxing = v.wuxing_type
			--进阶的百分比加成
			local cfg = SymbolData.Instance:GetElementHeartCfgByGrade(v.grade)
			if cfg then
				self.add_percent = self.add_percent + (cfg.add_texture_percent_attr/10000)
			end
		end

	end
	self.wuxing_jihuo_list = ListToMapList(wuxing_list,"wuxing_type")
	--判断默认选择符合条件的第一个
	self.jihuo_text:SetValue("未穿戴大天使装备")
	self.show_jihuo:SetValue(true)

	for k,v in pairs(SymbolData.Instance:GetElementTextureInfoList()) do
		if v.grade > 0 then
			self:OnClickEquipItem(k+1)
			if self.one_youxian_show then
				break
			end
		end
	end

	self:InitAttributeListView()
	self:InitConsumeListView()

	self:Flush()
end

function SymbolFuzhouView:CloseCallBack()
	self:CancelTheQuest()
	self.one_youxian_show = false
	self.two_youxian_show = false
end

function SymbolFuzhouView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "texture_upgrade_result" then
			self:ElementTextureUpgradeResult(v[1])
		else
			self:LeftFlush()
			self:RightFlush()
		end
	end
end

--左边面板刷新
function SymbolFuzhouView:LeftFlush()
	local all_zhanli = 0
	for i=1,SHEN_EQUIP_NUM do
		local index = i - 1
		if self.equip_cell_list[i] then
			--根据大天使装备赋值或上锁
			local info = SymbolData.Instance:GetElementTextureInfo(index)
			if nil == info then return end

			local equip_info = SymbolData.Instance:GetEquipInfoByEquipIndex(index)
			if equip_info then
				self.equip_cell_list[i]:SetAsset(ResPath.GetItemIcon(equip_info.wuxing_pic))
				self.equip_cell_list[i]:ShowQuality(true)
				if self.wuxing_jihuo_list[equip_info.wuxing_type] ~= nil and self.wuxing_jihuo_list[equip_info.wuxing_type][1].is_jihuo then
					self.equip_cell_list[i]:SetIconGrayScale(false)
					local color = math.ceil((info.grade) / 5)
					color = color < 6 and color or 6
					self.equip_cell_list[i]:SetQualityGray(false)
					self.equip_cell_list[i]:QualityColor(color > 0 and color or 1)
					self.equip_cell_list[i]:SetInteractable(true)
					self.equip_cell_list[i]:ShowStrengthLable(info.grade > 0 and info.grade-1 or 0)
					self.equip_cell_list[i]:SetStrength(info.grade)
					--1.
					local cfg = SymbolData.Instance:GetElementTextureLevel(equip_info.wuxing_type,info.grade)
					if cfg then
						local attr = CommonDataManager.GetAttributteNoUnderline(cfg)
						local capability = CommonDataManager.GetCapabilityCalculation(attr)
						all_zhanli = all_zhanli + (capability * (1 + self.add_percent))
					end
				else
					self.equip_cell_list[i]:SetIconGrayScale(true)
					self.equip_cell_list[i]:QualityColor(1)
					self.equip_cell_list[i]:SetQualityGray(true)
					self.equip_cell_list[i]:SetInteractable(false)
					self.equip_cell_list[i]:ShowStrengthLable(false)
				end
			end
		end
	end

	self.all_zhanli_text:SetValue(math.ceil(all_zhanli))

	self:UpdataEquiptRedmin()
end

--右边面板刷新
function SymbolFuzhouView:RightFlush()
	local info = SymbolData.Instance:GetElementTextureInfo(self.cur_equip_index-1)
	if info == nil then
		return
	end

	--当前的属性
	local cur_cfg = SymbolData.Instance:GetElementTextureLevel(info.wuxing_type,info.grade)
	if cur_cfg == nil then return end

	local cur_attr = CommonDataManager.GetAttributteNoUnderline(cur_cfg)

	--下一级的属性
	local next_cfg = SymbolData.Instance:GetElementTextureLevel(info.wuxing_type,info.grade + 1)
	local next_attr = CommonDataManager.GetAttributteNoUnderline(next_cfg)

	self.attribute_list_data[self.cur_equip_index] = {}
	local attr = next_attr
	if info.grade >= SymbolData.Instance:GetElementTextureMaxLevel() then
		attr = cur_attr
	end

	for k,v in pairs(attr) do
		if v > 0  then
			local attr = {} 		--有效的属性
			attr.cur_attr = cur_attr[k]
			attr.next_attr = next_attr[k]
			attr.attr_name = k
			table.insert(self.attribute_list_data[self.cur_equip_index],attr)
		end
	end

	--判断等级是否为最高等级
	if info.grade >= SymbolData.Instance:GetElementTextureMaxLevel() then
		self.jinjie_slide_value:InitValue(1)
		self.jinjie_slide_value_text:SetValue(Language.Common.YiMan)
	else
		if self.is_first then
			self.is_first = false
			self.jinjie_slide_value:InitValue(info.exp/cur_cfg.exp_limit)
		else
			self.jinjie_slide_value:SetValue(info.exp/cur_cfg.exp_limit)
		end
		self.jinjie_slide_value_text:SetValue(info.exp.."/"..cur_cfg.exp_limit)
	end

	self.name_text:SetValue(Language.Symbol.ElementsName[info.wuxing_type])
	local name = "SHZYJ"
	local equip_info = SymbolData.Instance:GetEquipInfoByEquipIndex(self.cur_equip_index - 1)
	if equip_info then
		name = equip_info.wuxing_name
	end
	self.equip_name:SetValue(name)

	self.zhanli_text:SetValue(0)

	local capability = CommonDataManager.GetCapabilityCalculation(cur_attr)
	capability = capability * (1 + self.add_percent)
	self.zhanli_text:SetValue(math.ceil(capability))

	self:SetAutoButtonGray()
	self.attribute_list_view.scroller:RefreshAndReloadActiveCellViews(true)

	self.consume_list_data = SymbolData.Instance:GetYSStuffCfg(self.cur_wuxing_type) or {}			--消耗品的数据
	self.consume_list_view.scroller:RefreshActiveCellViews()

	self:FlushRightEquipItem()
end

function SymbolFuzhouView:FlushRightEquipItem()
	local info = SymbolData.Instance:GetElementTextureInfo(self.cur_equip_index - 1)
	if nil == info then
		return
	end

	local equip_info = SymbolData.Instance:GetEquipInfoByEquipIndex(self.cur_equip_index - 1)
	if nil == equip_info then
		return
	end

	self.equip_item:SetAsset(ResPath.GetItemIcon(equip_info.wuxing_pic))
	self.equip_item:ShowQuality(true)
	if self.wuxing_jihuo_list[equip_info.wuxing_type] ~= nil and self.wuxing_jihuo_list[equip_info.wuxing_type][1].is_jihuo then
		self.equip_item:SetIconGrayScale(false)
		local color = math.ceil((info.grade) / 5)
		color = color < 6 and color or 6
		self.equip_item:SetQualityGray(false)
		self.equip_item:QualityColor(color > 0 and color or 1)
		self.equip_item:ShowStrengthLable(info.grade > 0 and info.grade-1 or 0)
		self.equip_item:SetStrength(info.grade)
	else
		self.equip_item:SetIconGrayScale(true)
		self.equip_item:QualityColor(1)
		self.equip_item:SetQualityGray(true)
		self.equip_item:SetInteractable(false)
		self.equip_item:ShowStrengthLable(false)
	end
end

--初始化模型
function SymbolFuzhouView:InitSymbolModel()
	if not self.symbol_model then
		self.symbol_model = RoleModel.New("symbol_panel")
		self.symbol_model:SetDisplay(self.center_display.ui3d_display)
	end
end

--设置模型数据
function SymbolFuzhouView:SetSymbolModelData(index)
	if self.last_model_index == index then return end
	self.last_model_index = index

	local model_res = SymbolData.Instance:GetModelResIdByElementId(index)
	local asset, bundle = ResPath.GetWuXinZhiLingModel(model_res)
	self.symbol_model:SetMainAsset(asset, bundle)
	self.symbol_model:SetModelScale(Vector3(1.5, 1.5, 1.5))
end

--初始化高亮
function SymbolFuzhouView:InitToggleIsOn()
	for k, v in pairs(self.equip_cell_list) do
		if k == self.cur_equip_index then
			v:SetToggle(true)
		else
			v:SetToggle(false)
		end
	end
end

--点击装备
function SymbolFuzhouView:OnClickEquipItem(index)
	for k, v in pairs(self.consume_cell_list) do
		v:ShowHighLight(false)
	end

	self.cur_consume_select = 0
	self.select_sonsume_cell_data = nil

	self.one_youxian_show = false
	self.two_youxian_show = false
	self:CancelTheQuest()			--取消自动进阶
	--切换装备刷新右边面板
	local wuxing_type = SymbolData.Instance:GetEquipByWuxing(index-1)

	self.show_line_list[self.last_show_line_index]:SetValue(false)
	if self.wuxing_jihuo_list[wuxing_type] ~= nil then
		for k,v in pairs(self.wuxing_jihuo_list[wuxing_type]) do
			if v.wuxing_type == wuxing_type and v.is_jihuo then
				--1.大天使装备激活 对应的五行之灵也激活
				self.one_youxian_show = true
				self.show_model:SetValue(v.is_jihuo)
				self.is_can_jinjie = true
				self.cur_equip_index = index
				self.cur_wuxing_type = wuxing_type
				self:SetSymbolModelData(wuxing_type)
				self.last_show_line_index = index
				self.show_line_list[index]:SetValue(true)
				self.jihuo_text:SetValue("")
				self.show_jihuo:SetValue(false)
				self.is_first = true
				self:InitToggleIsOn()
				self:Flush()
				return
			end

		end
	end

	--3. 大天使装备激活  对应的五行之灵未激活
	if not self.one_youxian_show then
		self.two_youxian_show = true
		self.is_can_jinjie = false
		self.jihuo_text:SetValue(Language.Symbol.NoActived,Language.Symbol.ElementsName[wuxing_type])
		self.show_jihuo:SetValue(true)
		self.cur_equip_index = index
		self.cur_wuxing_type = wuxing_type
		self.is_first = true
		self:InitToggleIsOn()
		self:Flush()
		return
	end

	--4. 大天使装备未激活  对应的五行之灵未激活
	if not self.one_youxian_show and not self.two_youxian_show then
		self.jihuo_text:SetValue(Language.Symbol.NoDress)
		self.show_jihuo:SetValue(true)
		self.is_can_jinjie = false
		self.is_first = true
		self:Flush()
		return
	end
end

--点击消耗品
function SymbolFuzhouView:OnClickConsumeItem(index,cell)
	self.cur_consume_select = index
	--如果是传递cell，滑动滚动条就会更变cell的数据，因此会出现数据变化
	self.select_sonsume_cell_data = cell.data 			--选中消耗品格子data
	cell:ShowHighLight(true)
end

--点击进阶
function SymbolFuzhouView:OnClickJinjie()
	if self.select_sonsume_cell_data ~= nil then
		local item_id = self.select_sonsume_cell_data.item_id
		self:SendJinjie()
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Symbol.PleaseSelect)
	end

	self:Flush()
end

function SymbolFuzhouView:SendJinjie()
	local item_id = self.select_sonsume_cell_data.item_id
	self:SendUpgradeCharmReq(item_id)

end

function SymbolFuzhouView:SendAllJinjie()
	local data = SymbolData.Instance:GetYSStuffCfg(self.cur_wuxing_type) or {}
	local num = 0
	local item_id = 0
	for k,v in pairs(data) do
		num = ItemData.Instance:GetItemNumInBagById(v.item_id)
		item_id = v.item_id
		if num > 0 then break end
	end
	self:SendUpgradeCharmReq(item_id)

end

function SymbolFuzhouView:SendUpgradeCharmReq(item_id)
	local index = ItemData.Instance:GetItemIndex(item_id)
	local num = ItemData.Instance:GetItemNumInBagById(item_id)

	if num <=0 then
		-- 物品不足，弹出TIP框
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end

		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(item_id, 2)
		end

		local func = function ( item_id2,item_num,is_bind,is_use,is_buy_quick )
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.toggle.isOn = true
			end
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)

		return
	end
	SymbolCtrl.Instance:SendUpgradeCharmReq(self.cur_equip_index - 1, index)
end

--自动进阶
function SymbolFuzhouView:OnClickYijian()
	local info = SymbolData.Instance:GetElementTextureInfo(self.cur_equip_index - 1)
	if info == nil or info.grade == 0 then
		return
	end

	if not self.is_can_auto then
		return
	end

	self.is_auto = self.is_auto == false
	self.is_can_auto = false
	self:AutoUpGradeOnce()
	self:SetAutoButtonGray()

	self:Flush()
end

function SymbolFuzhouView:SetAutoButtonGray()
	local info = SymbolData.Instance:GetElementTextureInfo(self.cur_equip_index - 1)
	self.can_jinjie:SetValue(false)
	self.can_auto_jinjie:SetValue(false)
	if info == nil or info.grade == nil then return end

	local max_grade = SymbolData.Instance:GetElementTextureMaxLevel()

	if not info or not info.grade or info.grade <= 0
		or info.grade >= max_grade or not self.is_can_jinjie then
		self.auto_btn_text:SetValue(Language.Symbol.AutoUpgrade)
		self.can_jinjie:SetValue(false)
		self.can_auto_jinjie:SetValue(false)
		return
	end
	if self.is_auto then
		self.auto_btn_text:SetValue(Language.Common.Stop)
		self.can_jinjie:SetValue(false)
		self.can_auto_jinjie:SetValue(true)
	else
		self.auto_btn_text:SetValue(Language.Symbol.AutoUpgrade)
		self.can_jinjie:SetValue(true)
		self.can_auto_jinjie:SetValue(true)
	end

end

--时间监听 自动进阶一次
function SymbolFuzhouView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.is_auto then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.SendAllJinjie, self), jinjie_next_time)
	end

end

function SymbolFuzhouView:CancelTheQuest()
	if self.upgrade_timer_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
	self.is_auto = false
	self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
end

--服务端 升级返回结果
function SymbolFuzhouView:ElementTextureUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

--更新装备上的红点
function SymbolFuzhouView:UpdataEquiptRedmin()
	for k,v in pairs(self.equip_cell_list) do
		v:SetRedPoint(false)
		local wuxing_type = SymbolData.Instance:GetEquipByWuxing(k-1)
		local num = 0
		local stuff_cfg_info = SymbolData.Instance:GetYSStuffCfg(wuxing_type) or {}
		for k1,v1 in pairs(stuff_cfg_info) do
			num = num + ItemData.Instance:GetItemNumInBagById(v1.item_id)
			if num > 0 then break end
		end

		local texture_info = SymbolData.Instance:GetElementTextureInfo(k-1)
		if texture_info then
			local info_grade = texture_info.grade
			if self.wuxing_jihuo_list[wuxing_type] ~= nil then
				for k1,v1 in pairs(self.wuxing_jihuo_list[wuxing_type]) do
					if num > 0 and v1.wuxing_type == wuxing_type and v1.is_jihuo
						and info_grade < SymbolData.Instance:GetElementTextureMaxLevel() then
						v:SetRedPoint(true)
					end
				end
			end
		end
	end
end

function SymbolFuzhouView:OnClickHelp()
	local tip_id = 268
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

----------------------属性的Item格子----------------------
AttributeCell = AttributeCell or BaseClass(BaseCell)

function AttributeCell:__init()
	-- self.attr_icon = self:FindVariable("attrIcon")
	self.attr_name = self:FindVariable("AttrName")
	self.attr = self:FindVariable("Attr")
	self.attr_add = self:FindVariable("AttrAdd")
	self.have_add = self:FindVariable("HaveAdd")
end

function AttributeCell:__delete()

end

function AttributeCell:OnFlush()
	if nil == self.data then return end
	self.attr:SetValue(ToColorStr(self.data.cur_attr, TEXT_COLOR.GRAY_2))
	self.attr_add:SetValue(self.data.next_attr or 0)
	local name = Language.Common.AttrNameNoUnderline[self.data.attr_name]
	name = ToColorStr(name, TEXT_COLOR.GRAY_3)
	self.attr_name:SetValue(name)
	-- self.attr_icon:SetAsset(ResPath.GetBaseAttrIcon(self.data.attr_name))
	self.have_add:SetValue(self.data.next_attr and self.data.next_attr > 0)
end

-----------------------消耗品格子-------------------------
ConsumeCell = ConsumeCell or BaseClass(BaseCell)

function ConsumeCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.root_node)
end

function ConsumeCell:__delete()
	self.item_cell:DeleteMe()
end

function ConsumeCell:SetData(data)

	self.data = data

	self:Flush()
end

function ConsumeCell:SetItemNum(str)
	self.item_cell:SetItemNum(str)
end

function ConsumeCell:SetToggleGroup(toggle_group)
	self.item_cell:SetToggleGroup(toggle_group)
end

function ConsumeCell:GetToggle()
	return self.item_cell.root_node.toggle
end

function ConsumeCell:SetClickCallBack(callback)
	self.item_cell:ListenClick(callback)
end

function ConsumeCell:OnFlush()
	if self.data == nil then
		return
	end

	local cell_data = {}
	cell_data.item_id = self.data.item_id
	cell_data.num = ItemData.Instance:GetItemNumInBagById(cell_data.item_id)
	self.item_cell:SetData(cell_data)


	self.item_cell:ShowQuality(true)
	if cell_data.num == 0 or cell_data.num == nil then
		self.item_cell:SetQualityGray(true)
		self.item_cell:SetInteractable(false)
		self.item_cell:QualityColor(1)
		self.item_cell:SetIconGrayScale(true)
	else
		self.item_cell:SetQualityGray(false)
		self.item_cell:SetInteractable(true)
		self.item_cell:SetIconGrayScale(false)
	end
end

function ConsumeCell:ShowHighLight(vis)
	self.item_cell:ShowHighLight(vis)
end