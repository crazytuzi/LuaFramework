BjXiangqianView = BjXiangqianView or BaseClass(BaseRender)

-- 宝甲-镶嵌
function BjXiangqianView:__init()
	self.cell_list = {}			-- 神器cell列表
	self.select_index = 1       -- 默认选中第1种神兵

	self.model = nil
	self.material_image_list = {}
	self.material_obj_list = {}

	self.show_arrow = {}
	self.image_active_text = {}
	self.item_cell = {}
	self.is_show_icon = {}
end

function BjXiangqianView:__delete()
	 for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k,v in pairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {} 
end

function BjXiangqianView:LoadCallBack(instance)
	-- 神兵-镶嵌Item列表
	self.baojia_list_view = self:FindObj("BaojiaItemList")
	local list_delegate = self.baojia_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.baojia_list_view.scroller:ReloadData(0)

	-- 宝甲模型
	self.model_display = self:FindObj("ModelDisplay")
	if self.model_display then
		self.model = RoleModel.New("baojia_xiangqian_panel", 200)
		self.model:SetDisplay(self.model_display.ui3d_display)
	end

	self:SetModel()

	for i = 1, 4 do
		self.material_image_list[i]= self:FindVariable("Icon_"..i)    -- 可镶嵌材料icon
		self.is_show_icon[i]= self:FindVariable("IsShowPic_"..i)      -- 是否显示icon
		self.material_obj_list[i] = self:FindObj("IconObj"..i)
		self.item_cell[i] = ItemCell.New(self:FindObj("ItemCell"..i))

		self.show_arrow[i] = self:FindVariable("ShowArrow_"..i)       -- 是否显示上升箭头
		self:ListenEvent("OnClickMaterial_" .. i, BindTool.Bind(self.OnClickMaterial, self, i))

		self.image_active_text[i] = self:FindVariable("ImageActiveText_"..i)    -- 形象激活条件
	end

	-- 总战力
	self.power_value = self:FindVariable("PowerValue")
	-- 属性
	self.hp = self:FindVariable("Hp")
	self.gongji = self:FindVariable("Gongji")
	self.fangyu = self:FindVariable("Fangyu")
	self.zaoxing = self:FindVariable("IsActiveZaoxing")
	self.shanbi = self:FindVariable("Shanbi")
	self.jianren = self:FindVariable("Jianren")
	self.quanjingtong = self:FindVariable("Quanjingtong")

	-- 特效激活条件
	self.qiling_level = self:FindVariable("QilingLevel")
	
	-- 所有宝甲的总属性
	self.all_hp = self:FindVariable("AllHp")
	self.all_gongji = self:FindVariable("AllGongji")
	self.all_fangyu = self:FindVariable("AllFangyu")
	self.all_shanbi = self:FindVariable("AllShanbi")
	self.all_jianren = self:FindVariable("AllJianren")
	self.image_active_num = self:FindVariable("ImageActiveNum")
	self.texiao_active_num = self:FindVariable("TexiaoActiveNum")
	self:ListenEvent("OnClickDress", BindTool.Bind(self.OnClickDress, self))    
	self.dress_button = self:FindObj("DressButton")
	self.dress_text = self:FindVariable("DressText")
	--神器名字
	self.name_image = self:FindVariable("NameImage")

	self.jiacheng_tip = self:FindVariable("BaoJiaChenTips")
	self.jiacheng_baoshi = self:FindVariable("BaoJiaChenBaoshi")

	self:ListenEvent("OnClickShow", BindTool.Bind(self.OnClickShow, self))


	self:Flush()
end

function BjXiangqianView:OpenCallBack()
	if ShenqiCtrl.Instance.view.qiling_view then
		self:SetSelectIndex(ShenqiCtrl.Instance.view.qiling_view.select_index)
	end
	self:SetModel()
end

-- 点击材料
function BjXiangqianView:OnClickMaterial(i)
	local baojia_info =  ShenqiData.Instance:GetBaojiaInfo(self.select_index)
	local baojia_cfg = ShenqiData.Instance:GetBaojiaInlayAllCfg()
	local can_xiangqian_list = ShenqiData.Instance:GetIsCanXiangQian(self.select_index, baojia_info, baojia_cfg)
	for k,v in pairs(can_xiangqian_list) do
		if  k == i then
			if v  then
				local quality = ShenqiData.Instance:GetMaxQualityStuff(self.select_index, i - 1, baojia_cfg, baojia_info)
				ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_INLAY,self.select_index, i - 1, quality)
			else
				if self.select_index == 1 then
					ViewManager.Instance:Open(ViewName.FuBen, nil, "phase", {index = 3})
				else
					local cfg = ShenqiData.Instance:GetSingleXiangQianCfg(self.select_index, i - 1, 1, baojia_cfg)
					TipsCtrl.Instance:ShowPowerPropTip({item_id = cfg.inlay_stuff_id}, nil, nil, nil, SHOW_POWER_PROP_TYPE.SHENQI)
				end
			end
		end
	end
end

function BjXiangqianView:OnClickShow()
	if self.select_index ~= nil then
		ShenqiCtrl.Instance:OpenShenQiTip(SHENQI_TIP_TYPE.BAOJIA, self.select_index)
	end
end

-- 获得cell的数量
function BjXiangqianView:GetNumberOfCells()
	return #ShenqiData.Instance:GetBaojiaInlayCfg()
end

-- 刷新cell
function BjXiangqianView:RefreshCell(cell, cell_index)
	local cur_cell = self.cell_list[cell]
	local data_list = ShenqiData.Instance:GetBaojiaInlayCfg()
	if cur_cell == nil then
		cur_cell = ShenbingItem.New(cell.gameObject, self, ShenqiView.TabDef.BaoJiaXiangQian)
		self.cell_list[cell] = cur_cell
	end
	cell_index = cell_index + 1
	cur_cell:SetIndex(cell_index)
	cur_cell:SetData(data_list[cell_index])
end

function BjXiangqianView:OnFlush()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end

	self:FlushStuff()
	self:FlushAttrData(self.select_index)
	self:FlushButtonState()
	self:FlushNameImage()

	if self.baojia_list_view.scroller.isActiveAndEnabled then
		self.baojia_list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function BjXiangqianView:FlushNameImage()
	local bundle, asset = ResPath.GetShenqiIcon(string.format("shenqi_%s", self.select_index))
	if bundle and asset then
		self.name_image:SetAsset(bundle, asset)
	end
end

function BjXiangqianView:FlushButtonState()
	local data = ShenqiData.Instance:GetShenqiAllInfo()
	if data.baojia_cur_image_id == self.select_index then
		self.dress_text:SetValue(Language.Shenqi.RestoreText)
	else
		self.dress_text:SetValue(Language.Shenqi.DressText)
	end
end

function BjXiangqianView:FlushStuff()
	local baojia_info = ShenqiData.Instance:GetBaojiaInfo(self.select_index)
	local baojia_cfg = ShenqiData.Instance:GetBaojiaInlayAllCfg()
	local can_xiangqian_list = ShenqiData.Instance:GetIsCanXiangQian(self.select_index, baojia_info, baojia_cfg)
	local other_cfg = ShenqiData.Instance:GetShenqiOtherCfg()
	-- 可镶嵌材料icon
	local data_list = ShenqiData.Instance:GetXiangQianStuffListById(self.select_index, baojia_info, baojia_cfg)
	for i = 1, 4 do
		local quality = baojia_info.quality_list[i - 1]
		local bundle, asset
		if quality > 0 then
			if data_list[i] then
				self.is_show_icon[i]:SetValue(false)
			end
		else
			self.is_show_icon[i]:SetValue(true)
			bundle, asset = ResPath.GetItemIcon(other_cfg["baojia_" .. i])
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
	local add_per = ShenqiData.Instance:GetJiaChengPer(SHENBING_ADDPER.BAOJIA_TYPE)
	local act_num = (ShenqiData.Instance:GetBaoJiaActvityNum() * add_per) / 100
	self.jiacheng_tip:SetValue(act_num)
	self.jiacheng_baoshi:SetValue(Language.ShenQiAddPer[SHENBING_ADDPER.BAOJIA_TYPE])
end

--宝甲-镶嵌 属性
function BjXiangqianView:FlushAttrData(id)
	-- 镶嵌材料ID列表
	local  attr_data = CommonStruct.Attribute()

	local baojia_info = ShenqiData.Instance:GetBaojiaInfo(id)
	local baojia_cfg = ShenqiData.Instance:GetBaojiaInlayAllCfg()
	local XiangQianStuffList = ShenqiData.Instance:GetXiangQianStuffListById(id, baojia_info, baojia_cfg)
	local quanjingtong = 0

	for k,v in pairs(XiangQianStuffList) do
		local cfg = ShenqiData.Instance:GetSingleXiangQianCfgByStuff(v, baojia_cfg)
		if next(cfg) then

			local data = CommonDataManager.GetAttributteByClass(cfg)
			attr_data = CommonDataManager.AddAttributeAttr(attr_data, CommonDataManager.GetAttributteByClass(cfg))
			quanjingtong = quanjingtong + data.ice_master
		end
	end

	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	local cur_level = shenqi_all_info.baojia_list[self.select_index].level
	local baojia_upgrade = ShenqiData.Instance:GetBaojiaUpgradeCfg()
	local qiling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level,baojia_upgrade)

	if next(qiling_cfg) then
		attr_data = CommonDataManager.AddAttributeAttr(attr_data, CommonDataManager.GetAttributteByClass(qiling_cfg))
	end

	-- 当前宝甲的属性
	self.hp:SetValue(attr_data.max_hp)
	self.gongji:SetValue(attr_data.gong_ji)
	self.fangyu:SetValue(attr_data.fang_yu)
	self.quanjingtong:SetValue(quanjingtong)

	-- 器灵的属性
	local cur_qilingling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level,baojia_upgrade)
	if next(cur_qilingling_cfg) then
		self.shanbi:SetValue(cur_qilingling_cfg.shanbi)
		self.jianren:SetValue(cur_qilingling_cfg.jianren)
	else
		self.shanbi:SetValue(0)
		self.jianren:SetValue(0)
	end

	-- 造型
	if shenqi_all_info.baojia_image_flag then
		local is_active = bit:_and(1, bit:_rshift(shenqi_all_info.baojia_image_flag , self.select_index))
		self.zaoxing:SetValue(is_active == 1)
	end

	-- 形象激活条件
	local baojia_inlay_cfg = ShenqiData.Instance:GetBaojiaInlayCfg()
	local baojia_info = ShenqiData.Instance:GetBaojiaInfo(self.select_index)
	for i = 1, 4 do
		local quality = baojia_info.quality_list[i - 1]
		local sub_name = string.sub(baojia_inlay_cfg[id].name, 1, 6)
		local str_name = sub_name .. Language.Shenqi.BaojiaPartTypeName[i - 1] .. "-" .. Language.Shenqi.QualityColor[ACTIVE_IMAGE_CONDITION]
		local str = quality >= ACTIVE_IMAGE_CONDITION and ToColorStr(str_name,TEXT_COLOR.GREEN) or ToColorStr(str_name,COLOR.RED)
		self.image_active_text[i]:SetValue(str)
	end

	-- 器灵等级
	local qiling_active_state = ShenqiData.Instance:GetStuffActiveState(QILING_TAB,self.select_index,baojia_upgrade)
	self.qiling_level:SetValue(qiling_active_state)

	-- 所有神兵的总属性
	local  all_baojia_data = {hp = 0,gongji = 0,fangyu = 0,shanbi = 0,jianren = 0}
	for k , v in ipairs(shenqi_all_info.baojia_list) do
		local baojia_info = ShenqiData.Instance:GetBaojiaInfo(k)
		local XiangQianStuffList = ShenqiData.Instance:GetXiangQianStuffListById(k, baojia_info, baojia_cfg)
		local cur_level = shenqi_all_info.baojia_list[k].level
		local qiling_cfg = ShenqiData.Instance:GetCfgByLevel(cur_level,baojia_upgrade)
		if next(qiling_cfg) then
			all_baojia_data.hp = all_baojia_data.hp + qiling_cfg.maxhp
			all_baojia_data.gongji = all_baojia_data.gongji + qiling_cfg.gongji
			all_baojia_data.fangyu = all_baojia_data.fangyu + qiling_cfg.fangyu
			all_baojia_data.shanbi = all_baojia_data.shanbi + qiling_cfg.shanbi
			all_baojia_data.jianren = all_baojia_data.jianren + qiling_cfg.jianren

		end
		for k,v in pairs(XiangQianStuffList) do
			local cfg = ShenqiData.Instance:GetSingleXiangQianCfgByStuff(v, baojia_cfg)
			if next(cfg) then
				all_baojia_data.hp = all_baojia_data.hp + cfg.maxhp
				all_baojia_data.gongji = all_baojia_data.gongji + cfg.gongji
				all_baojia_data.fangyu = all_baojia_data.fangyu + cfg.fangyu
			 end
		end
	end
	self.all_hp:SetValue(all_baojia_data.hp)
	self.all_gongji:SetValue(all_baojia_data.gongji)
	self.all_fangyu:SetValue(all_baojia_data.fangyu)
	self.all_shanbi:SetValue(all_baojia_data.shanbi)
	self.all_jianren:SetValue(all_baojia_data.jianren)
	
	-- 战力
	local baojia_all_power = CommonDataManager.GetCapabilityCalculation(attr_data)
	self.power_value:SetValue(baojia_all_power or 0)

	local iamge_total = #ShenqiData.Instance:GetBaojiaImageCfg()
	local active_num = ShenqiData.Instance:GetActiveNum(shenqi_all_info.baojia_image_flag)
	self.image_active_num:SetValue(active_num.."/"..iamge_total)

	local texiao_total = #ShenqiData.Instance:GetBaojiaTexiaoCfg()
	local active_num2 = ShenqiData.Instance:GetActiveNum(shenqi_all_info.baojia_image_flag)
	self.texiao_active_num:SetValue(active_num2.."/"..texiao_total)

end

function BjXiangqianView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BjXiangqianView:GetSelectIndex()
	return self.select_index
end

function BjXiangqianView:SetModel()
	--设置宝甲模型
	if self.model then
		self.model:SetModelResInfo(GameVoManager.Instance:GetMainRoleVo(), false, true, true, false, true, true, true, false)
		local res_id = ShenqiData.Instance:GetBaojiaResCfgByIamgeID(self.select_index)
		self.model:SetRoleResid(res_id)

		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		--self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.JUN], "120".. main_role_vo.prof .. "001", DISPLAY_PANEL.JUN)
	end
end

function BjXiangqianView:OnClickDress()
	local shenqi_all_info = ShenqiData.Instance:GetShenqiAllInfo()
	if shenqi_all_info.baojia_cur_image_id ~= self.select_index then
		 ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_USE_IMAGE,self.select_index)
	else
		ShenqiCtrl.Instance:SendReqShenqiAllInfo(SHENQI_OPERA_REQ_TYPE.SHENQI_OPERA_REQ_TYPE_BAOJIA_USE_IMAGE,0)
	end
end