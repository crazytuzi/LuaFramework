BaoJiaView = BaoJiaView or BaseClass(BaseRender)
--提示文字的Id
local des_id = 262
local ITEM_NUM = 4
local COUNT_NUM = 1
function BaoJiaView:__init()
	--默认值
	self.select_index = 1
	self.last_index = -1
	self.left_item_list = {}
	self.is_auto = false
	self.item_id = 0
	self.now_level = 0
	self.total_num = 0
	self.next_time = 0
	--variable值
	self.name = self:FindVariable("EquipName")
	self.hp = self:FindVariable("HpValue")
	self.fangyu = self:FindVariable("FangYuValue")
	self.kangbao = self:FindVariable("KangBaoValue")
	self.shanbi = self:FindVariable("ShanBiValue")
	self.next_hp = self:FindVariable("Next_Hp")
	self.next_fangyu = self:FindVariable("Next_FangYu")
	self.next_kangbao = self:FindVariable("Next_KangBao")
	self.next_shanbi = self:FindVariable("Next_ShanBi")
	self.fightnumber = self:FindVariable("FightNumber")
	self.slider = self:FindVariable("SliderValue")
	self.now_exp = self:FindVariable("NowExp")
	self.cell_num = self:FindVariable("Cell_Num")
	self.level = self:FindVariable("Level")
	self.click_text = self:FindVariable("ClickText")
	self.show_cell_num = self:FindVariable("ShowCellNum")
	self.is_active = self:FindVariable("Is_Active")
	self.is_max = self:FindVariable("Is_Max")
	self.can_click = self:FindVariable("CanClick")
	self.show_active_rp = self:FindVariable("ShowActiveRedPoint")
	self.show_effect = self:FindVariable("ShowEffect")
	self.show_effect_inlay = self:FindVariable("ShowEffectXiangQian")

	--初始化的变量
	self.click_text:SetValue(Language.ShenQi.BaoJiaUpLevel)
	--obj值
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.item_cell_list = {}
	self.show_up = {}
	for i = 1, ITEM_NUM do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("ItemCell_" .. i))
		self.show_up[i] = self:FindVariable("Show_Up_" .. i)
	end

	self.model = RoleModel.New()
	self.model:SetDisplay(self:FindObj("Display").ui3d_display)

	self.left_list = self:FindObj("ListView")
	local list_temp = self.left_list.list_simple_delegate
	list_temp.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCell, self)
	list_temp.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.left_list.scroller:ReloadData(0)
	--listen
	self:ListenEvent("ClickUpLevel", BindTool.Bind(self.ClickUpLevel, self))
	self:ListenEvent("ClickTips", BindTool.Bind(self.OnClickShenqiTip, self))
	self:ListenEvent("ClickShowEffect", BindTool.Bind(self.ClickShowEffect, self))
	self:ListenEvent("ClickGo", BindTool.Bind(self.ClickGo, self))
	

end

function BaoJiaView:__delete()

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell_list then
		for k,_ in pairs(self.item_cell_list) do
			if self.item_cell_list[k] then
				self.item_cell_list[k]:DeleteMe()
				self.item_cell_list[k] = nil
			end
		end
		self.item_cell_list = nil
	end

	if self.show_up then
		for k,_ in pairs(self.show_up) do
			if self.show_up[k] then
				self.show_up[k] = nil
			end
		end
		self.show_up = nil
	end

	if self.left_item_list then
		for k,_ in pairs(self.left_item_list) do
			if self.left_item_list[k] then
				self.left_item_list[k]:DeleteMe()
				self.left_item_list[k] = nil
			end
		end
		self.left_item_list = nil
	end

	self.show_effect:SetValue(false)
	self.now_level = 0
	self.can_click = nil
	self.show_cell_num = nil
	self.click_text = nil
	self.now_exp = nil
	self.level = nil
	self.cell_num = nil
	self.left_list = nil
	self.name = nil
	self.hp = nil
	self.fangyu = nil
	self.baoji = nil
	self.mingzhong = nil
	self.next_hp = nil
	self.next_fangyu = nil
	self.next_kangbao = nil
	self.next_shanbi = nil	
	self.fightnumber = nil
	self.slider = nil
	self.is_active = nil
	self.is_max = nil
	self.is_auto = false
	self.show_active_rp = nil
	self.show_effect = nil
	self.show_effect_inlay = nil	
end

function BaoJiaView:OnFlush()
	self:ClearEffect()
	self:FlushModel()
	self:FlushAttribute()
	self:FlushItemCell()
	self:FlushMaterialItem()
	self:FlushLeftItemHL()
	self:FlushItemCellNum()
	self:FlushItemUpState()
	self:FlushActiveRedPoint()
	self:FlushInlaySuccess()
end

function BaoJiaView:FlushAttribute()
	local data = ShenqiData.Instance:GetAllBaoJiaAttributeByIndex(self.select_index)

	self.hp:SetValue(data.maxhp)
	self.fangyu:SetValue(data.fangyu)
	self.kangbao:SetValue(data.jianren)
	self.shanbi:SetValue(data.shanbi)

	self.next_hp:SetValue(data.next_maxhp)
	self.next_fangyu:SetValue(data.next_fangyu)
	self.next_kangbao:SetValue(data.next_jianren)
	self.next_shanbi:SetValue(data.next_shanbi)	

	if -1 == data.need_exp then
		self.now_exp:SetValue(Language.ShenQi.IsMax)
		self.slider:SetValue(1)
		self.is_max:SetValue(true)
	else
		self.now_exp:SetValue(data.exp .. " / " .. data.need_exp)
		self.slider:SetValue(data.exp / data.need_exp)
		self.is_max:SetValue(false)
	end

	local count = CommonDataManager.GetCapabilityCalculation(data)
	self.fightnumber:SetValue(count)

	if 0 == self.now_level then
		self.now_level = data.level
	end

	if self.now_level ~= data.level then
		self.show_effect:SetValue(false)
		self.show_effect:SetValue(true)
		self.now_level = data.level
	end

	self.level:SetValue(data.level)

end

function BaoJiaView:FlushModel()
	--设置保甲模型
	if self.model then
		if self.select_index == self.last_index then 
			return 
		end

		self.last_index = self.select_index
		
		local main_vo = GameVoManager.Instance:GetMainRoleVo()
		local info = {}
		info.prof = main_vo.prof
		info.sex = main_vo.sex
		info.appearance = {}
		info.appearance.fashion_wuqi = main_vo.appearance.fashion_wuqi
		self.model:SetModelResInfo(info, false, true, true, false, false, true, false, false)
		local res_id = ShenqiData.Instance:GetBaojiaResCfgByIamgeID(self.select_index)
		self.model:SetPanelName("shenqi_baojia_" .. main_vo.prof)
		self.model:SetRoleResid(res_id)
	end
end

--刷新下方的装备格子
function BaoJiaView:FlushItemCell()
	local data = ShenqiData.Instance:GetBaojiaInfo(self.select_index)
	if nil == data then
		return
	end

	--设置品质颜色
	for i = 1, ITEM_NUM do
		local list = ShenqiData.Instance:GetBaoJiaList(self.select_index, i, data.quality_list[i])
		if nil ~= list then
			self.item_cell_list[i]:SetData({item_id = list.inlay_stuff_id})
		end

		if 0 == data.quality_list[i] then
			self.item_cell_list[i]:SetQualityGray(true)
			self.item_cell_list[i]:SetIconGrayScale(true)
		else
			self.item_cell_list[i]:SetQualityGray(false)
			self.item_cell_list[i]:SetIconGrayScale(false)
		end
	end
end
function BaoJiaView:FlushMaterialItem()
	local shenqi_other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()
	if nil == shenqi_other_cfg then
		return
	end

	local baojia_uplevel_stuff_num = ItemData.Instance:GetItemNumInBagById(shenqi_other_cfg.baojia_uplevel_stuff_id)
	self.item_cell:SetData({item_id = shenqi_other_cfg.baojia_uplevel_stuff_id})
	self.item_id = shenqi_other_cfg.baojia_uplevel_stuff_id
end

function BaoJiaView:FlushItemCellNum()
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local can_click = ShenqiData.Instance:IsCanGo(self.select_index, ShenqiData.ChooseType.BaoJia)
	self.is_active:SetValue(shenqi_all_info.baojia_cur_image_id == self.select_index)
	self.can_click:SetValue(can_click)

	local temp_data = shenqi_all_info.baojia_list[self.select_index]
	if nil == temp_data then
		return
	end

	local cur_level = temp_data.level
	local baojia_upgrade_cfg = ShenqiData.Instance:GetBaojiaUpgradeCfg()
	local num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	local next_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level + 1, baojia_upgrade_cfg)
	if nil == next_jianling_cfg then
		return
	end

	local taotal_num = 0
	for k,v in pairs(baojia_upgrade_cfg) do
		taotal_num = taotal_num + 1
	end

	if cur_level == taotal_num then
		self.show_cell_num:SetValue(false)
	else
		self.show_cell_num:SetValue(true)
	end

	local str = ""
	if 0 == num then
		str = ToColorStr(num, TEXT_COLOR.RED)
	else
		str = ToColorStr(num, TEXT_COLOR.YELLOW)
	end
	self.cell_num:SetValue(str .. " / " .. ToColorStr(COUNT_NUM, TEXT_COLOR.WHITE))
end

function BaoJiaView:FlushLeftItemHL()
	self.left_list.scroller:RefreshActiveCellViews()
end

function BaoJiaView:FlushItemUpState()
	local baojia = ShenqiData.Instance:GetBaoJiaUpLevelList(self.select_index)
	self:ReleaseUpLevel()

	for i = 1, ITEM_NUM do
		if baojia[i] then
			self.item_cell_list[i]:ListenClick(BindTool.Bind(self.ClickItemCell, self, i))
			self.show_up[i]:SetValue(baojia[i])
		else
			self.item_cell_list[i]:ListenClick(nil)
			self.show_up[i]:SetValue(false)
		end
	end
end

function BaoJiaView:FlushLeftRedPoint()
	for k,v in pairs(self.left_item_list) do
		if v then
			v:FlushRedPoint()
		end
	end
end

function BaoJiaView:FlushActiveRedPoint()
	self.show_active_rp:SetValue(ShenqiData.Instance:GetBaoJiaActiveByIndex(self.select_index))
end

function BaoJiaView:FlushInlaySuccess()
	local is_success = ShenqiData.Instance:GetInlaySuccess()
	if is_success then
		self.show_effect_inlay:SetValue(false)
		self.show_effect_inlay:SetValue(true)
		ShenqiData.Instance:SetInlaySuccess(false)
	end
end
------------------------点击事件begin-----------------------
-- 自动升级
function BaoJiaView:ClickUpLevel()
	self.is_auto = not self.is_auto
	ShenqiData.Instance:ChangeBaoJiaClickList(self.select_index)
	local can_up = ShenqiData.Instance:IsCanUpLevel(self.select_index, ShenqiData.ChooseType.BaoJia)
	if not can_up then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenQi.NoEnoughItem, 2)
		return
	end

	--数量为0，发送一次，服务器传回提示
	local num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	if 0 == num then
		self:UpdateOcne()
		return
	end

	if self.is_auto then
		self.click_text:SetValue(Language.ShenQi.StopUplevel)
		self:UpdateOcne()
	else
		self.click_text:SetValue(Language.ShenQi.BaoJiaUpLevel)
	end
end

function BaoJiaView:ClickGo()
	local can_click = ShenqiData.Instance:IsCanGo(self.select_index, ShenqiData.ChooseType.BaoJia)
	if not can_click then

		TipsCtrl.Instance:ShowSystemMsg(Language.ShenQi.NoEnoughQuality, 4)
		return
	end

	--发送出战请求
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_USE_IMAGE, self.select_index)
end

function BaoJiaView:OnClickShenqiTip()
	TipsCtrl.Instance:ShowHelpTipView(des_id)
end

function BaoJiaView:ClickShowEffect()
	local cfg = ShenqiData.Instance:GetBaojiaTexiaoCfg()

	TipsCtrl.Instance:ShowShenQiEffectTips(self.select_index, cfg, ShenqiData.ChooseType.BaoJia)
end

function BaoJiaView:ClickItemCell(index)
	local data = ShenqiData.Instance:GetBaojiaInfo(self.select_index)
	if nil == data then
		return
	end
	
	local cfg = ShenqiData.Instance:GetBaojiaInlayAllCfg()
	if nil == cfg then
		return
	end

	--不设置高亮
	for k,v in pairs(self.item_cell_list) do
		if v then
			v:SetHighLight(false)
		end
	end

	local quality = ShenqiData.Instance:GetMaxQualityStuff(self.select_index, index, cfg, data)
	if quality > data.quality_list[index] then
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_INLAY, self.select_index, index - 1, quality)
	end
end

------------------------点击事件end-----------------------

function BaoJiaView:UpdateOcne()
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local cur_level = shenqi_all_info.baojia_list[self.select_index].level
	local baojia_upgrade_cfg = ShenqiData.Instance:GetBaojiaUpgradeCfg()

	local level_num = 0
	for k, v in pairs(baojia_upgrade_cfg) do
		level_num = level_num + 1
	end

	local num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	local next_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level + 1, baojia_upgrade_cfg)
	
	if cur_level == level_num or nil == next_jianling_cfg then 
		self.is_auto = false
		self.show_cell_num:SetValue(false)
		self.click_text:SetValue(Language.ShenQi.BaoJiaUpLevel)
		return 
	end
	self.next_time = next_jianling_cfg.next_time

	self:FlushItemCellNum()
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_UPLEVEL, self.select_index, 1, next_jianling_cfg.send_pack_num)
end

function BaoJiaView:ReleaseUpLevel()
	for k,v in pairs(self.show_up) do
		v:SetValue(false)
	end
end

function BaoJiaView:FlushUpgradeOptResult(result)
	if 0 == result then
		self.click_text:SetValue(Language.ShenQi.ShenQiUpLevel)
		self.is_auto = false
		self:FlushLeftRedPoint()
	elseif 1 == result then
		self:UpdateOcne()
	end
end

--------------------listview刷新-----------------
function BaoJiaView:GetNumOfCell()
	return GetListNum(ShenqiData.Instance:GetBaojiaInlayCfg())
end

function BaoJiaView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local left_cell = self.left_item_list[cell]
	if nil == left_cell then
		left_cell = ShenQiBaoJiaLeftItem.New(cell.gameObject)
		left_cell.parent_view = self
		self.left_item_list[cell] = left_cell
	end

	local data = ShenqiData.Instance:GetBaojiaInfo(data_index)
	left_cell:SetIndex(data_index)
	left_cell:SetData(data)
end
--------------------listview刷新-----------------

--------------------内部使用交互-----------------
function BaoJiaView:GetSelectIndex()
	return self.select_index
end

function BaoJiaView:SetSelectIndex(index)
	self.select_index = index
end

function BaoJiaView:SetName(str)
	self.name:SetValue(str)
end

function BaoJiaView:SetLevel(level)
	self.now_level = level
end

function BaoJiaView:ClearEffect()
	self.show_effect:SetValue(false)
	self.show_effect_inlay:SetValue(false)
end
--------------------内部使用交互-----------------
--------------------左侧显示List-----------------
ShenQiBaoJiaLeftItem = ShenQiBaoJiaLeftItem or BaseClass(BaseCell)

function ShenQiBaoJiaLeftItem:__init()
	self.name = self:FindVariable("Name")
	self.show_hl = self:FindVariable("ShowHL")
	self.red_point = self:FindVariable("ShowRedPoint")
		
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function ShenQiBaoJiaLeftItem:__delete()

end

function ShenQiBaoJiaLeftItem:OnFlush()
	if nil == self.data then
		return
	end

	local str = ShenqiData.Instance:GetBaojiaNameByIndex(self.index)
	
	self.name:SetValue(ToColorStr(str, TEXT_COLOR.WHITE))
	local index = self.parent_view:GetSelectIndex()
	if index == self.index then
		self.parent_view:SetName(str)
		self.name:SetValue(ToColorStr(str, TEXT_COLOR.YELLOW))
	end
	self:FlushHL(index)
	self:FlushRedPoint()
end

function ShenQiBaoJiaLeftItem:ClickItem()
	self.parent_view:SetSelectIndex(self.index)
	self.parent_view:SetLevel(0)
	ShenqiData.Instance:ChangeBaoJiaClickList(self.index)
	self:FlushRedPoint()
	self.parent_view:Flush()
end

function ShenQiBaoJiaLeftItem:FlushHL(index)
	self.show_hl:SetValue(index == self.index)
end

function ShenQiBaoJiaLeftItem:FlushRedPoint()
	local can_update = ShenqiData.Instance:GetBaoJiaUpdateRedPoint(self.index)
	local can_inlay = ShenqiData.Instance:GetIsShowBjXiangQiangRpByIndex(self.index)
	local can_active = ShenqiData.Instance:GetBaoJiaActiveByIndex(self.index)
	local is_open = ShenqiData.Instance:GetOpenBaoJia()

	if can_inlay then
		self.red_point:SetValue(true)
	elseif not ShenqiData.Instance:GetBaoJiaClickList(self.index) then
		self.red_point:SetValue(can_update or can_active)
	else
		self.red_point:SetValue(false)
	end
end