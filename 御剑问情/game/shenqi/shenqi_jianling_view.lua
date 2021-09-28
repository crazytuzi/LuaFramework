JianLingView = JianLingView or BaseClass(BaseRender)
--提示文字的Id
local des_id = 262
local ITEM_NUM = 4
local COUNT_NUM = 1
function JianLingView:__init()
	--
	self.select_index = 1
	self.last_index = 0
	self.left_item_list = {}
	self.is_auto = false
	self.item_id = 0
	self.total_num = 0
	self.next_time = 0
	self.now_level = 0
	--variable值
	self.name = self:FindVariable("EquipName")
	self.hp = self:FindVariable("HpValue")
	self.gongji = self:FindVariable("GongJiValue")
	self.baoji = self:FindVariable("BaoJiValue")
	self.mingzhong = self:FindVariable("MingZhongValue")
	self.next_hp = self:FindVariable("Next_Hp")
	self.next_gongji = self:FindVariable("Next_GongJi")
	self.next_baoji = self:FindVariable("Next_BaoJi")
	self.next_mingzhong = self:FindVariable("Next_MingZhong")
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
	--需要初始化的绑定变量
	self.click_text:SetValue(Language.ShenQi.ShenQiUpLevel)
	
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

	--listen
	self:ListenEvent("ClickUpLevel", BindTool.Bind(self.ClickUpLevel, self))
	self:ListenEvent("ClickTips", BindTool.Bind(self.OnClickShenqiTip, self))
	self:ListenEvent("ClickShowEffect", BindTool.Bind(self.ClickShowEffect, self))
	self:ListenEvent("ClickGo", BindTool.Bind(self.ClickGo, self))
end

function JianLingView:__delete()

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

	self.show_cell_num = nil
	self.click_text = nil
	self.now_exp = nil
	self.level = nil
	self.cell_num = nil
	self.left_list = nil
	self.name = nil
	self.hp = nil
	self.gongji = nil
	self.baoji = nil
	self.mingzhong = nil
	self.next_hp = nil
	self.next_gongji = nil
	self.next_baoji = nil
	self.next_mingzhong = nil
	self.fightnumber = nil
	self.slider = nil
	self.is_active = nil
	self.is_max = nil
	self.can_click = nil
	self.is_auto = false
	self.show_active_rp = nil
	self.show_effect = nil
	self.show_effect_inlay = nil
end

function JianLingView:OnFlush()
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

function JianLingView:FlushAttribute()
	local data = ShenqiData.Instance:GetAllJiangLingAttributeByIndex(self.select_index)

	--当前属性
	self.hp:SetValue(data.maxhp)
	self.gongji:SetValue(data.gongji)
	self.baoji:SetValue(data.baoji)
	self.mingzhong:SetValue(data.mingzhong)

	--下级属性
	self.next_hp:SetValue(data.next_maxhp)
	self.next_gongji:SetValue(data.next_gongji)
	self.next_baoji:SetValue(data.next_baoji)
	self.next_mingzhong:SetValue(data.next_mingzhong)
	
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

function JianLingView:FlushModel()
	--设置神兵模型
	if self.model then
		if self.select_index == self.last_index then 
			return 
		end

		self.last_index = self.select_index
		local res_id = ShenqiData.Instance:GetResCfgByIamgeID(self.select_index)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.model:SetPanelName("shenqi_shengbing_" .. main_role_vo.prof)
		self.model:SetMainAsset(ResPath.GetShenQiWeaponModel(res_id))
	end
end

--刷新下方的装备格子
function JianLingView:FlushItemCell()
	local data = ShenqiData.Instance:GetJianLingInfo(self.select_index)
	if nil == data then
		return
	end

	--设置品质颜色
	for i = 1, ITEM_NUM do
		local list = ShenqiData.Instance:GetJianLingList(self.select_index, i, data.quality_list[i])
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

function JianLingView:FlushMaterialItem()
	local shenqi_other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()
	if nil == shenqi_other_cfg then
		return
	end

	self.item_cell:SetData({item_id = shenqi_other_cfg.shenbing_uplevel_stuff})
	self.item_id = shenqi_other_cfg.shenbing_uplevel_stuff
end

function JianLingView:FlushItemCellNum()
	--设置item数量
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local can_click = ShenqiData.Instance:IsCanGo(self.select_index, ShenqiData.ChooseType.JianLing)
	self.is_active:SetValue(shenqi_all_info.shenbing_cur_image_id == self.select_index)
	self.can_click:SetValue(can_click)

	local temp_data = shenqi_all_info.shenbing_list[self.select_index]
	if nil == temp_data then
		return 
	end

	local cur_level = temp_data.level
	local shenbing_upgrade_cfg = ShenqiData.Instance:GetShenbingUpgradeCfg()
	local num = ItemData.Instance:GetItemNumInBagById(self.item_id)
	local next_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level + 1, shenbing_upgrade_cfg)	
	
	if nil == next_jianling_cfg then
		return 
	end

	local taotal_num = GetListNum(shenbing_upgrade_cfg)
	if cur_level == taotal_num then
		self.show_cell_num:SetValue(false)
	else
		self.show_cell_num:SetValue(true)
	end

	local str = ""
	if 0 == num then
		self.is_auto = false
		str = ToColorStr(num, TEXT_COLOR.RED)
	else
		str = ToColorStr(num, TEXT_COLOR.YELLOW)
	end
	self.cell_num:SetValue(str .. " / " .. ToColorStr(COUNT_NUM, TEXT_COLOR.WHITE))
end

function JianLingView:FlushLeftItemHL()
	self.left_list.scroller:RefreshActiveCellViews()
end

function JianLingView:FlushItemUpState()
	local jianling = ShenqiData.Instance:GetJiangLingUpLevelList(self.select_index)
	self:ReleaseUpLevel()

	for i = 1, ITEM_NUM do
		if jianling[i] then
			self.item_cell_list[i]:ListenClick(BindTool.Bind(self.ClickItemCell, self, i))
			self.show_up[i]:SetValue(jianling[i])
		else
			self.item_cell_list[i]:ListenClick(nil)
			self.show_up[i]:SetValue(false)
		end
	end
end

function JianLingView:FlushLeftRedPoint()
	for k,v in pairs(self.left_item_list) do
		if v then
			v:FlushRedPoint()
		end
	end
end

function JianLingView:FlushActiveRedPoint()
	self.show_active_rp:SetValue(ShenqiData.Instance:GetJianLingActiveByIndex(self.select_index))
end

function JianLingView:FlushInlaySuccess()
	local is_success = ShenqiData.Instance:GetInlaySuccess()
	if is_success then
		self.show_effect_inlay:SetValue(false)
		self.show_effect_inlay:SetValue(true)
		ShenqiData.Instance:SetInlaySuccess(false)
	end
end

------------------------点击事件-----------------------
-- 自动升级
function JianLingView:ClickUpLevel()
	self.is_auto = not self.is_auto
	ShenqiData.Instance:ChangeJiangLingClickList(self.select_index)
	local can_up = ShenqiData.Instance:IsCanUpLevel(self.select_index, ShenqiData.ChooseType.JianLing)
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
		self.click_text:SetValue(Language.ShenQi.ShenQiUpLevel)
	end	
	
end

function JianLingView:OnClickShenqiTip()
	TipsCtrl.Instance:ShowHelpTipView(des_id)
end

function JianLingView:ClickShowEffect()
	local cfg = ShenqiData.Instance:GetShenbingTexiaoCfg()

	TipsCtrl.Instance:ShowShenQiEffectTips(self.select_index, cfg, ShenqiData.ChooseType.JianLing)
end

function JianLingView:ClickGo()
	local can_click = ShenqiData.Instance:IsCanGo(self.select_index, ShenqiData.ChooseType.JianLing)
	if not can_click then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenQi.NoEnoughQuality, 2)
		return
	end

	--发送出战请求
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_USE_IMAGE, self.select_index)
end

function JianLingView:ClickItemCell(index)
	local data = ShenqiData.Instance:GetJianLingInfo(self.select_index)
	if nil == data then
		return
	end
	
	local cfg = ShenqiData.Instance:GetShenbingInlayAllCfg()
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
		-- -1对接服务端数据
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_INLAY, self.select_index, index - 1, quality)
	end
end
------------------------点击事件-----------------------

function JianLingView:UpdateOcne()
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local cur_level = shenqi_all_info.shenbing_list[self.select_index].level
	local shenbing_upgrade_cfg = ShenqiData.Instance:GetShenbingUpgradeCfg()
	local level_num = GetListNum(shenbing_upgrade_cfg)

	local next_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level + 1, shenbing_upgrade_cfg)
	
	if cur_level == level_num or nil == next_jianling_cfg then 
		self.is_auto = false
		self.show_cell_num:SetValue(false)
		self.click_text:SetValue(Language.ShenQi.ShenQiUpLevel)
		return 
	end
	self.next_time = next_jianling_cfg.next_time

	--当前数目小于需要的 auto = false
	self:FlushItemCellNum()
	ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_UPLEVEL, self.select_index, 1, next_jianling_cfg.send_pack_num)
end

function JianLingView:ReleaseUpLevel()
	for k,v in pairs(self.show_up) do
		v:SetValue(false)
	end
end

function JianLingView:FlushUpgradeOptResult(result)
	if 0 == result then
		self.click_text:SetValue(Language.ShenQi.ShenQiUpLevel)
		self.is_auto = false
		self:FlushLeftRedPoint()
	elseif 1 == result then
		self:UpdateOcne()
	end
end
--------------------listview刷新-----------------
function JianLingView:GetNumOfCell()
	return GetListNum(ShenqiData.Instance:GetShenbingInlayCfg())
end

function JianLingView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local left_cell = self.left_item_list[cell]
	if nil == left_cell then
		left_cell = ShenQiJianLingLeftItem.New(cell.gameObject)
		left_cell.parent_view = self
		self.left_item_list[cell] = left_cell
	end

	local data = ShenqiData.Instance:GetJianLingInfo(data_index)
	left_cell:SetIndex(data_index)
	left_cell:SetData(data)
end
--------------------listview刷新-----------------

--------------------内部使用交互-----------------
function JianLingView:GetSelectIndex()
	return self.select_index
end

function JianLingView:SetSelectIndex(index)
	self.select_index = index
end

function JianLingView:SetName(str)
	self.name:SetValue(str)
end

function JianLingView:SetLevel(level)
	self.now_level = level
end

function JianLingView:ClearEffect()
	self.show_effect:SetValue(false)
	self.show_effect_inlay:SetValue(false)
end

--------------------内部使用交互-----------------
--------------------左侧显示List-----------------
ShenQiJianLingLeftItem = ShenQiJianLingLeftItem or BaseClass(BaseCell)

function ShenQiJianLingLeftItem:__init()
	self.name = self:FindVariable("Name")
	self.show_hl = self:FindVariable("ShowHL")
	self.red_point = self:FindVariable("ShowRedPoint")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function ShenQiJianLingLeftItem:__delete()

end

function ShenQiJianLingLeftItem:OnFlush()
	if nil == self.data then
		return
	end

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local str = ShenqiData.Instance:GetJianLingNameByIndex(self.index) .. Language.ShenQi.Equip[main_role_vo.prof]

	self.name:SetValue(ToColorStr(str, TEXT_COLOR.WHITE))
	local index = self.parent_view:GetSelectIndex()
	if self.index == index then
		self.parent_view:SetName(str)
		self.name:SetValue(ToColorStr(str, TEXT_COLOR.YELLOW))
	end

	self:FlushRedPoint()
	self:FlushHL(index)
end

function ShenQiJianLingLeftItem:ClickItem()
	self.parent_view:SetSelectIndex(self.index)
	self.parent_view:SetLevel(0)
	ShenqiData.Instance:ChangeJiangLingClickList(self.index)
	self:FlushRedPoint()
	self.parent_view:Flush()
end

function ShenQiJianLingLeftItem:FlushHL(index)
	self.show_hl:SetValue(index == self.index)
end

function ShenQiJianLingLeftItem:FlushRedPoint()
	local can_update = ShenqiData.Instance:GetJianLingUpdateRedPoint(self.index)
	local can_inlay = ShenqiData.Instance:GetIsShowSbXiangQiangRpByIndex(self.index)
	local can_active = ShenqiData.Instance:GetJianLingActiveByIndex(self.index)
	local is_open = ShenqiData.Instance:GetOpenJiangLing()

	if can_inlay then
		self.red_point:SetValue(true)
	elseif not ShenqiData.Instance:GetJiangLingClickList(self.index) then
		self.red_point:SetValue(can_update or can_active)
	else
		self.red_point:SetValue(false)
	end
end

