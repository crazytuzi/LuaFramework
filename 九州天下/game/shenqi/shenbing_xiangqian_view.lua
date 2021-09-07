XiangqianView = XiangqianView or BaseClass(BaseRender)

-- 神兵-镶嵌
function XiangqianView:__init()
	self.cell_list = {}            -- 神器cell列表
	self.select_index = 1          -- 默认选中第1种神兵

	self.model = nil
	self.material_image_list = {}
	self.material_obj_list = {}

	self.show_arrow = {}
	self.image_active_text = {}

	self.item_cell = {}

	self.is_show_icon = {}
end

function XiangqianView:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k,v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function XiangqianView:LoadCallBack(instance)
	-- 神兵-镶嵌Item列表
	self.shenbing_list_view = self:FindObj("ShenqiItemList")
	local list_delegate = self.shenbing_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.shenbing_list_view.scroller:ReloadData(0)

	-- 神兵模型
	self.model_display = self:FindObj("ModelDisplay")
	if self.model_display then
		self.model = RoleModel.New("shenbing_xiangqian_panel", 500)
		self.model:SetDisplay(self.model_display.ui3d_display)
	end

	self:SetModel()

	self:ListenEvent("OnClickShenqiTip", BindTool.Bind(self.OnClickShenqiTip, self))
	self:ListenEvent("OnClickDress", BindTool.Bind(self.OnClickDress, self))      
	self:ListenEvent("OnClickShowTip", BindTool.Bind(self.OnClickShowTip, self))                   

	for i = 1, 4 do
		self.material_image_list[i]= self:FindVariable("Icon_"..i)              -- 可镶嵌材料icon
		self.is_show_icon[i]= self:FindVariable("IsShowPic_"..i)                -- 是否显示icon
		self.material_obj_list[i] = self:FindObj("IconObj"..i)
		self.item_cell[i] = ItemCell.New(self:FindObj("ItemCell"..i))

		self.show_arrow[i] = self:FindVariable("ShowArrow_"..i)                 -- 是否显示上升箭头
		self:ListenEvent("OnClickMaterial_" .. i, BindTool.Bind(self.OnClickMaterial, self, i))

		self.image_active_text[i] = self:FindVariable("ImageActiveText_"..i)    -- 形象激活条件
	end

	-- 总战力
	self.power_value = self:FindVariable("PowerValue")
	-- 当前神兵的属性
	self.hp = self:FindVariable("Hp")
	self.gongji = self:FindVariable("Gongji")
	self.fangyu = self:FindVariable("Fangyu")
	self.mingzhong = self:FindVariable("Mingzhong")
	self.baoji = self:FindVariable("Baoji")
	self.quanjingtong = self:FindVariable("Quanjingtong")
	self.zaoxing = self:FindVariable("IsActiveZaoxing")

	-- 特效激活条件
	self.jianling_level = self:FindVariable("JianlingLevel")
	
	-- 所有神兵的总属性
	self.all_hp = self:FindVariable("AllHp")
	self.all_gongji = self:FindVariable("AllGongji")
	self.all_fangyu = self:FindVariable("AllFangyu")
	self.all_mingzhong = self:FindVariable("AllMingzhong")
	self.all_baoji = self:FindVariable("AllBaoji")
	-- 形象激活数量
	self.image_active_num = self:FindVariable("ImageActiveNum")
	-- 特效激活数量
	self.texiao_active_num = self:FindVariable("TexiaoActiveNum")
	self.dress_button = self:FindObj("DressButton")
	self.dress_text = self:FindVariable("DressText")
	-- 神器名字
	self.main_role_prof = GameVoManager.Instance:GetMainRoleVo().prof
	self.name_image = self:FindVariable("NameImage")

	self.jiacheng_tip = self:FindVariable("JiachengTip")
	self.jiacheng_baoshi = self:FindVariable("JiaChengBaoshi")
	-- self.show_tip_btn = self:FindVariable("ShowTipBtn")

	self:Flush()
end

function XiangqianView:OpenCallBack()
	if ShenqiCtrl.Instance.view.jianling_view then
		self:SetSelectIndex(ShenqiCtrl.Instance.view.jianling_view.select_index)
	end
	self:SetModel()
end

function XiangqianView:OnClickShowTip()
	if self.select_index ~= nil then
		ShenqiCtrl.Instance:OpenShenQiTip(SHENQI_TIP_TYPE.SHENBING, self.select_index)
	end
end

-- 点击材料
function XiangqianView:OnClickMaterial(i)
	local shenbing_info =  ShenqiData.Instance:GetShenBingList(self.select_index)
	local shenbing_cfg = ShenqiData.Instance:GetShenbingInlayAllCfg()
	local can_xiangqian_list = ShenqiData.Instance:GetIsCanXiangQian(self.select_index, shenbing_info, shenbing_cfg)
	for k,v in pairs(can_xiangqian_list) do
		if k == i then
			if v then
				local quality = ShenqiData.Instance:GetMaxQualityStuff(self.select_index, i - 1, shenbing_cfg, shenbing_info)
				ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_INLAY,self.select_index, i - 1, quality)
			else
				if self.select_index == 1 then
					ViewManager.Instance:Open(ViewName.FuBen, nil, "phase", {index = 2})
				else
					local cfg = ShenqiData.Instance:GetSingleXiangQianCfg(self.select_index, i - 1, 1, shenbing_cfg)
					TipsCtrl.Instance:ShowPowerPropTip({item_id = cfg.inlay_stuff_id}, nil, nil, nil, SHOW_POWER_PROP_TYPE.SHENQI)
				end
			end
		end
	end
end

-- 获得cell的数量
function XiangqianView:GetNumberOfCells()
	return #ShenqiData.Instance:GetShenbingInlayCfg()
end

-- 刷新cell
function XiangqianView:RefreshCell(cell, cell_index)
	local cur_cell = self.cell_list[cell]
	local data_list = ShenqiData.Instance:GetShenbingInlayCfg()
	if cur_cell == nil then
		cur_cell = ShenbingItem.New(cell.gameObject, self, ShenqiView.TabDef.ShenBingXiangQian)
		self.cell_list[cell] = cur_cell
		-- cur_cell:SetToggleGroup(self.xiangqian_list_view.toggle_group)
	end
	cell_index = cell_index + 1
	cur_cell:SetIndex(cell_index)
	cur_cell:SetData(data_list[cell_index])
end

function XiangqianView:OnFlush()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end

	self:FlushStuff()
	self:FlushAttrData(self.select_index)
	self:FlushButtonState()
	self:FlushNameImage()

	if self.shenbing_list_view.scroller.isActiveAndEnabled then
		self.shenbing_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.shenbing_list_view.scroller:ReloadData(0)
end

function XiangqianView:FlushNameImage()
	if self.main_role_prof then
		local bundle, asset = ResPath.GetShenqiIcon(string.format("shenqi_%s_%s", self.select_index, self.main_role_prof))
		if bundle and asset then
			self.name_image:SetAsset(bundle, asset)
		end
	end
end

function XiangqianView:FlushStuff()
	local shenbing_info = ShenqiData.Instance:GetShenBingList(self.select_index)
	local shenbing_cfg = ShenqiData.Instance:GetShenbingInlayAllCfg()
	local can_xiangqian_list = ShenqiData.Instance:GetIsCanXiangQian(self.select_index, shenbing_info, shenbing_cfg)
	local other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()

	-- 可镶嵌材料icon
	local data_list = ShenqiData.Instance:GetXiangQianStuffListById(self.select_index, shenbing_info, shenbing_cfg)
	for i = 1, 4 do
		local quality = shenbing_info.quality_list[i - 1]           -- 下标是对应的部位
		local bundle, asset
		if quality > 0 then
			if data_list[i] then
				self.is_show_icon[i]:SetValue(false)
			end
		else
			self.is_show_icon[i]:SetValue(true)
			bundle, asset = ResPath.GetItemIcon(other_cfg["shenbing_" .. i])
		end
		self.material_image_list[i]:SetAsset(bundle, asset)
		self.material_obj_list[i].grayscale.GrayScale = quality > 0 and 0 or 255

		self.item_cell[i]:SetData({item_id = data_list[i]})
		self.show_arrow[i]:SetValue(can_xiangqian_list[i])
		self.item_cell[i]:SetShowUpArrow(can_xiangqian_list[i])
		if can_xiangqian_list[i] then
			self.item_cell[i]:ListenClick(function ()
				self.item_cell[i]:SetHighLight(false)
				self:OnClickMaterial(i)
			end) 
		else
			self.item_cell[i]:ShowHighLight(true)
			self.item_cell[i]:ListenClick()
		end
	end

	local add_per = ShenqiData.Instance:GetJiaChengPer(SHENBING_ADDPER.SHENBIN_TYPE)
	local act_num = (ShenqiData.Instance:GetShenBingActvityNum() * add_per) / 100
	self.jiacheng_tip:SetValue(act_num)
	self.jiacheng_baoshi:SetValue(Language.ShenQiAddPer[SHENBING_ADDPER.SHENBIN_TYPE])
end

--神兵-镶嵌 属性
function XiangqianView:FlushAttrData(id)
	-- 镶嵌材料ID列表
	local  attr_data = CommonStruct.Attribute()
	local shenbing_info = ShenqiData.Instance:GetShenBingList(id)
	local shenbing_cfg = ShenqiData.Instance:GetShenbingInlayAllCfg()
	local XiangQianStuffList = ShenqiData.Instance:GetXiangQianStuffListById(id, shenbing_info, shenbing_cfg)
	local quanjingtong = 0
	local other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()

	-- local check_flag = false
	-- if shenbing_info ~= nil and shenbing_info.quality_list ~= nil then
	-- 	for k, v in  pairs(shenbing_info.quality_list) do
	-- 		check_flag = v >= 3
	-- 		if not check_flag then
	-- 			break
	-- 		end
	-- 	end

	-- 	if shenbing_info.level ~= nil and other_cfg.shenbing_suit_trigger_level ~= nil and check_flag then
	-- 		check_flag = shenbing_info.level >= other_cfg.shenbing_suit_trigger_level
	-- 	end
	-- end

	-- if self.show_tip_btn then
	-- 	self.show_tip_btn:SetValue(check_flag)
	-- end
	-- self.show_tip_btn:SetValue(true)

	for k,v in pairs(XiangQianStuffList) do
		local cfg = ShenqiData.Instance:GetSingleXiangQianCfgByStuff(v, shenbing_cfg)
		if next(cfg) then
			local data = CommonDataManager.GetAttributteByClass(cfg)
			attr_data = CommonDataManager.AddAttributeAttr(attr_data, CommonDataManager.GetAttributteByClass(cfg))
			quanjingtong = quanjingtong + data.ice_master
		end
	end


	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local cur_level = shenqi_all_info.shenbing_list[self.select_index].level
	local shenbing_upgrade = ShenqiData.Instance:GetShenbingUpgradeCfg()
	local jianling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level,shenbing_upgrade)

	if next(jianling_cfg) then
		attr_data = CommonDataManager.AddAttributeAttr(attr_data, CommonDataManager.GetAttributteByClass(jianling_cfg))
	end

	-- 当前神兵的属性
	self.hp:SetValue(attr_data.max_hp)
	self.gongji:SetValue(attr_data.gong_ji)
	self.fangyu:SetValue(attr_data.fang_yu)
	self.quanjingtong:SetValue(quanjingtong)
	
	-- 剑灵的属性
	local cur_jianling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level,shenbing_upgrade)
	if next(cur_jianling_cfg) then
		self.mingzhong:SetValue(cur_jianling_cfg.mingzhong)
		self.baoji:SetValue(cur_jianling_cfg.baoji)
	else
		self.mingzhong:SetValue(0)
		self.baoji:SetValue(0)
	end

	-- 造型
	if shenqi_all_info.shenbing_image_flag then
		local is_active = bit:_and(1, bit:_rshift(shenqi_all_info.shenbing_image_flag , self.select_index))
		self.zaoxing:SetValue(is_active == 1)
	end

	-- 形象激活条件
	local shenbing_inlay_cfg = ShenqiData.Instance:GetShenbingInlayCfg()
	local shenbing_info = ShenqiData.Instance:GetShenBingList(self.select_index)
	for i = 1, IMAGE_ACTIVE_CONDITION do
		local quality = shenbing_info.quality_list[i - 1]
		local sub_name = string.sub(shenbing_inlay_cfg[id].name, 1, 6)
		local str_name = sub_name .. Language.Shenqi.ShenbingPartTypeName[i - 1] .. "-" .. Language.Shenqi.QualityColor[ACTIVE_IMAGE_CONDITION]
		local str = quality >= ACTIVE_IMAGE_CONDITION and ToColorStr(str_name,TEXT_COLOR.GREEN) or ToColorStr(str_name,COLOR.RED)
		self.image_active_text[i]:SetValue(str)
	end

	-- 剑灵等级
	local jianling_active_state = ShenqiData.Instance:GetStuffActiveState(JIANLING_TAB,self.select_index,shenbing_upgrade)
	self.jianling_level:SetValue(jianling_active_state)

	-- 所有神兵的总属性
	local all_shenbing_data = CommonStruct.Attribute()

	for k , v in ipairs(shenqi_all_info.shenbing_list) do
		local shenbing_info = ShenqiData.Instance:GetShenBingList(k)
		local XiangQianStuffList = ShenqiData.Instance:GetXiangQianStuffListById(k, shenbing_info, shenbing_cfg)
		local cur_level = shenqi_all_info.shenbing_list[k].level
		local jianling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level,shenbing_upgrade)
		if next(jianling_cfg) then
			all_shenbing_data = CommonDataManager.AddAttributeAttr(all_shenbing_data, CommonDataManager.GetAttributteByClass(jianling_cfg))
		end
		for k,v in pairs(XiangQianStuffList) do
			local cfg = ShenqiData.Instance:GetSingleXiangQianCfgByStuff(v, shenbing_cfg)
			if next(cfg) then
			  all_shenbing_data = CommonDataManager.AddAttributeAttr(all_shenbing_data, CommonDataManager.GetAttributteByClass(jianling_cfg))
			 end
		end
	end

	-- 所有神兵的总属性
	self.all_hp:SetValue(all_shenbing_data.max_hp)
	self.all_gongji:SetValue(all_shenbing_data.gong_ji)
	self.all_fangyu:SetValue(all_shenbing_data.fang_yu)
	self.all_mingzhong:SetValue(all_shenbing_data.ming_zhong)
	self.all_baoji:SetValue(all_shenbing_data.bao_ji)

	-- 战力
	local shenbing_all_power = CommonDataManager.GetCapabilityCalculation(attr_data)
	self.power_value:SetValue(shenbing_all_power or 0)

	local iamge_total = #ShenqiData.Instance:GetShenbingImageCfg()
	local active_num = ShenqiData.Instance:GetActiveNum(shenqi_all_info.shenbing_image_flag)
	self.image_active_num:SetValue(active_num.."/"..iamge_total)

	local texiao_total = #ShenqiData.Instance:GetShenbingTexiaoCfg()
	local active_num2 = ShenqiData.Instance:GetActiveNum(shenqi_all_info.shenbing_texiao_flag)
	self.texiao_active_num:SetValue(active_num2.."/"..texiao_total)
end

function XiangqianView:FlushButtonState()
	local data = ShenqiData.Instance:GetShenqiAllInfo()
	if data.shenbing_cur_image_id == self.select_index then
		self.dress_text:SetValue(Language.Shenqi.RestoreText)
	else
		self.dress_text:SetValue(Language.Shenqi.DressText)
	end
end

function XiangqianView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function XiangqianView:GetSelectIndex()
	return self.select_index
end

function XiangqianView:SetModel()
	--设置神兵模型
	if self.model then
		local res_id = ShenqiData.Instance:GetResCfgByIamgeID(self.select_index)
		self.model:SetMainAsset(ResPath.GetShenQiWeaponModel(res_id))
		--self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SHENQI], res_id, DISPLAY_PANEL.SHENQI_VIEW)
	end
end

function XiangqianView:OnClickShenqiTip()
	TipsCtrl.Instance:ShowHelpTipView(194)
end

function XiangqianView:OnClickDress()
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	if shenqi_all_info.shenbing_cur_image_id ~= self.select_index then
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_USE_IMAGE,self.select_index)
	else
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_SHENBING_USE_IMAGE,0)
	end
end

----------------------------- 神兵item begin-------------------------
ShenbingItem = ShenbingItem or BaseClass(BaseCell)
function ShenbingItem:__init(instance, parent, tab_index)
	self.parent = parent
	self.tab_index = tab_index
	self.index = 1
	self:ListenEvent("Click", BindTool.Bind1(self.OnClickCell, self))
	-- self.icon = self:FindVariable("Icon")       -- 神器icon
	self.show_gaoliang = self:FindVariable("ShouGaoliang")
	self.name = self:FindVariable("Name")       -- 神器name	
	self.show_coming_soon_text = self:FindVariable("ShowComingSoonText")
	self.show_red_point = self:FindVariable("ShowRedPoint")
end

function ShenbingItem:__delete()
	-- self.icon = nil
	self.show_gaoliang = nil
	self.name = nil
	self.show_coming_soon_text = nil
end

function ShenbingItem:OnFlush()
	if self.data == nil or not next(self.data) then 
		self.show_coming_soon_text:SetValue(true)
		return 
	end

	self.name:SetValue(self.data.name)

	self:FlushHL()
	if self.tab_index == ShenqiView.TabDef.ShenBingXiangQian then
		self.show_red_point:SetValue(ShenqiData.Instance:GetIsShowSbXiangQiangRpByIndex(self.data.id))
		-- local bundle, asset = ResPath.GetShenqiIcon("shenbing_"..self.data.id)
		-- self.icon:SetAsset(bundle, asset)
	-- elseif self.tab_index == ShenqiView.TabDef.ShenBingJianLing then
		-- local bundle, asset = ResPath.GetShenqiIcon("shenbing_"..self.data.id)
		-- self.icon:SetAsset(bundle, asset)
	elseif self.tab_index == ShenqiView.TabDef.BaoJiaXiangQian then
		self.show_red_point:SetValue(ShenqiData.Instance:GetIsShowBjXiangQiangRpByIndex(self.data.id))
		-- local bundle, asset = ResPath.GetShenqiIcon("baojia_"..self.data.id)
		-- self.icon:SetAsset(bundle, asset)
	elseif self.tab_index == ShenqiView.TabDef.ShenBingJianLing then
		self.show_red_point:SetValue(ShenqiData.Instance:GetJianLingUpdateRedPoint(self.data.id))
		-- local bundle, asset = ResPath.GetShenqiIcon("baojia_"..self.data.id)
		-- self.icon:SetAsset(bundle, asset)
	elseif self.tab_index == ShenqiView.TabDef.BaoJiaQiLing then
		self.show_red_point:SetValue(ShenqiData.Instance:GetBaoJiaUpdateRedPoint(self.data.id))	
	end
end

function ShenbingItem:OnClickCell()
	if self.data == nil or not next(self.data) then 
		return 
	end
	self.parent:SetSelectIndex(self.index)
	self.parent:Flush()

	self.parent:SetModel()
end

function ShenbingItem:FlushHL()
	local cur_index = self.parent:GetSelectIndex()
	self.show_gaoliang:SetValue(cur_index == self.index)
end

----------------------------- 神兵item end-------------------------
