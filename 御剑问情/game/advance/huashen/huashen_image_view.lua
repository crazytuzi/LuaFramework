HuashenImageView = HuashenImageView or BaseClass(BaseView)

function HuashenImageView:__init()
	self.ui_config = {"uis/views/advanceview_prefab","HuashenImageView"}
	self.cur_click_image = 0
	self.cur_image_level = 0
end

function HuashenImageView:LoadCallBack()
	self.cur_gongji = self:FindVariable("CurGongji")
	self.cur_fangyu = self:FindVariable("CurFangyu")
	self.cur_maxhp = self:FindVariable("CurMaxhp")
	self.cur_mingzhong = self:FindVariable("CurMingzhong")
	self.cur_shanbi = self:FindVariable("CurShanbi")

	self.next_gongji = self:FindVariable("NextGongji")
	self.next_fangyu = self:FindVariable("NextFangyu")
	self.next_maxhp = self:FindVariable("NextMaxhp")
	self.next_mingzhong = self:FindVariable("NextMingzhong")
	self.next_shanbi = self:FindVariable("NextShanbi")

	self.fight_power = self:FindVariable("FightPower")
	self.get_tujing_1 = self:FindVariable("GetTuJing1")
	self.get_tujing_2 = self:FindVariable("GetTuJing2")
	self.image_name = self:FindVariable("Name")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.bag_num = self:FindVariable("ActivateProNum")
	self.need_num = self:FindVariable("ExchangeNeedNum")

	self.show_upgrade_btn = self:FindVariable("IsShowUpGrade")
	self.show_activate_btn = self:FindVariable("IsShowActivate")
	self.show_use_ima_btn = self:FindVariable("IsShowUseImaButton")
	self.show_use_image = self:FindVariable("IsShowUseImage")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")
	self.show_next_attr = self:FindVariable("ShowNextAttr")

	self:ListenEvent("OnClickActivate",
		BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUpGrade",
		BindTool.Bind(self.OnClickUpGrade, self))
	self:ListenEvent("OnClickUseIma",
		BindTool.Bind(self.OnClickUseIma, self))
	self:ListenEvent("OnClickCanCelIamge",
		BindTool.Bind(self.OnClickCanCelIamge, self))

	self.list_view = self:FindObj("ListView")
	self.upgrade_btn = self:FindObj("UpGradeButton")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
	self.display = self:FindObj("Display")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetHuashenImageNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshHuashenImageCell, self)
	self.cell_list = {}
end

function HuashenImageView:__delete()
	self.cur_click_image = nil
	self.cur_image_level = nil

	if self.item ~= nil then
		self.item:DeleteMe()
	end
	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end
end

function HuashenImageView:OpenCallBack()
	self:Flush()
end

function HuashenImageView:GetHuashenImageNumberOfCells()
	return HuashenData.Instance:GetMaxHuashenList()
end

function HuashenImageView:RefreshHuashenImageCell(cell, cell_index)
	local image_cell = self.cell_list[cell]
	if not image_cell then
		image_cell = HuashenImageCell.New(cell.gameObject)
		image_cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cell] = image_cell
	end
	local haushen_info = HuashenData.Instance:GetHuashenInfo()
	local activie_flag = haushen_info.activie_flag
	local image_cfg = HuashenData.Instance:GetHuashenImageCfg(cell_index)
	local image_info = HuashenData.Instance:GetHuashenInfoCfg()[cell_index]
	local data = (1 == activie_flag[cell_index]) and image_cfg or image_info
	data.name = image_info.name
	local item_id = (1 == activie_flag[cell_index]) and image_cfg.stuff_id or image_info.item_id
	local need_num = (1 == activie_flag[cell_index]) and image_cfg.stuff_num or 1
	local is_show = ItemData.Instance:GetItemNumInBagById(item_id) >= need_num
	image_cell:SetHighLight(self.cur_click_image == cell_index)
	image_cell:SetData(data, is_show)
	image_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, cell_index, data, image_cell))
end

function HuashenImageView:OnClickClose()
	self:Close()
end

--点击激活按钮
function HuashenImageView:OnClickActivate()
	local data_list = ItemData.Instance:GetBagItemDataList()
	local image_info = HuashenData.Instance:GetHuashenInfoCfg()[self.cur_click_image]
	for k, v in pairs(data_list) do
		if v.item_id == image_info.item_id then
			PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
			return
		end
	end
	-- HuashenCtrl.Instance:SendHuaShenOperaReq(HUASHEN_REQ_TYPE.HUASHEN_REQ_TYPE_UP_GRADE, self.cur_click_image)
end

--点击升级按钮
function HuashenImageView:OnClickUpGrade()
	HuashenCtrl.Instance:SendHuaShenOperaReq(HUASHEN_REQ_TYPE.HUASHEN_REQ_TYPE_UP_GRADE, self.cur_click_image)
end

--点击使用当前形象
function HuashenImageView:OnClickUseIma()
	HuashenCtrl.Instance:SendHuaShenOperaReq(HUASHEN_REQ_TYPE.HUASHEN_REQ_TYPE_CHANGE_IMAGE, self.cur_click_image)
end

-- 取消形象
function HuashenImageView:OnClickCanCelIamge()
	local huashen_info = HuashenData.Instance:GetHuashenInfo()
	if not huashen_info then return end
	HuashenCtrl.Instance:SendHuaShenOperaReq(HUASHEN_REQ_TYPE.HUASHEN_REQ_TYPE_CHANGE_IMAGE, huashen_info.cur_huashen_id)
end


function HuashenImageView:OnClickListCell(cell_index, image_info, image_cell)
	self.cur_click_image = cell_index
	image_cell:SetHighLight(self.cur_click_image == cell_index)
	self:SetHuashenImageAttr()
end

--获取激活坐骑符数量
function HuashenImageView:GetHaveProNum(item_id, need_num)
	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	end
	self.bag_num:SetValue(count)
end

function HuashenImageView:SetHuashenImageAttr()
	local haushen_info = HuashenData.Instance:GetHuashenInfo()
	local grade_list = haushen_info.grade_list
	local activie_flag = haushen_info.activie_flag
	local image_info = HuashenData.Instance:GetHuashenInfoCfg()[self.cur_click_image]
	local item_id = 0
	local need_num = 0
	if not grade_list or not image_info or not activie_flag then return end

	self.cur_image_level = grade_list[self.cur_click_image] or 0
	local cur_grade_cfg = (1 == activie_flag[self.cur_click_image]) and HuashenData.Instance:GetHuashenImageCfg(self.cur_click_image, self.cur_image_level)
							or image_info
	local next_grade_cfg = HuashenData.Instance:GetHuashenImageCfg(self.cur_click_image, self.cur_image_level + 1)

	self.cur_gongji:SetValue((1 == activie_flag[self.cur_click_image]) and (cur_grade_cfg.gongji + image_info.gongji) or cur_grade_cfg.gongji)
	self.cur_maxhp:SetValue((1 == activie_flag[self.cur_click_image]) and (cur_grade_cfg.maxhp + image_info.maxhp) or cur_grade_cfg.maxhp)
	self.cur_fangyu:SetValue((1 == activie_flag[self.cur_click_image]) and (cur_grade_cfg.fangyu + image_info.fangyu) or cur_grade_cfg.fangyu)
	self.cur_shanbi:SetValue((1 == activie_flag[self.cur_click_image]) and (cur_grade_cfg.shanbi + image_info.shanbi) or cur_grade_cfg.shanbi)
	self.cur_mingzhong:SetValue((1 == activie_flag[self.cur_click_image]) and (cur_grade_cfg.mingzhong + image_info.mingzhong) or cur_grade_cfg.mingzhong)

	self.show_next_attr:SetValue(nil ~= next_grade_cfg and 1 == activie_flag[self.cur_click_image])
	self.show_cur_level:SetValue(self.cur_image_level > 0)

	if next_grade_cfg then
		self.next_gongji:SetValue(next_grade_cfg.gongji - cur_grade_cfg.gongji)
		self.next_maxhp:SetValue(next_grade_cfg.maxhp - cur_grade_cfg.maxhp)
		self.next_fangyu:SetValue(next_grade_cfg.fangyu - cur_grade_cfg.fangyu)
		self.next_shanbi:SetValue(next_grade_cfg.shanbi - cur_grade_cfg.shanbi)
		self.next_mingzhong:SetValue(next_grade_cfg.mingzhong - cur_grade_cfg.mingzhong)
	end

	if 1 == activie_flag[self.cur_click_image] then
		item_id = next_grade_cfg and next_grade_cfg.stuff_id or cur_grade_cfg.stuff_id
		need_num = next_grade_cfg and next_grade_cfg.stuff_num or cur_grade_cfg.stuff_num
	else
		item_id = image_info.item_id
		need_num = 1
	end
	self.need_num:SetValue(need_num)
	self:GetHaveProNum(item_id, need_num)
	-- self.bag_num:SetValue(ItemData.Instance:GetItemNumInBagById(item_id))
	local data = {item_id = item_id}
	self.item:SetData(data)

	self.cur_level:SetValue(self.cur_image_level)
	self.image_name:SetValue(image_info.name)

	local capability = CommonDataManager.GetCapability(cur_grade_cfg)
	self.fight_power:SetValue(capability)

	self:SetButtonsState()
	self:SetUseImageAndButtonState()
end

--设置升级按钮、激活按钮显示和隐藏
function HuashenImageView:SetButtonsState()
	local haushen_info = HuashenData.Instance:GetHuashenInfo()
	local activie_flag = haushen_info.activie_flag
	if not activie_flag then return end
	self.show_activate_btn:SetValue(0 == activie_flag[self.cur_click_image])
	self.show_upgrade_btn:SetValue(1 == activie_flag[self.cur_click_image])
	local max_grade = HuashenData.Instance:GetHuashenImageMaxGrade(self.cur_click_image)
	self.upgrade_btn.button.interactable = self.cur_image_level < max_grade
end

function HuashenImageView:SetUseImageAndButtonState()
	local haushen_info = HuashenData.Instance:GetHuashenInfo()
	local cur_huashen_id = haushen_info.cur_huashen_id
	local activie_flag = haushen_info.activie_flag
	if not cur_huashen_id or not activie_flag then return end

	self.show_use_image:SetValue(self.cur_click_image == cur_huashen_id)
	self.show_use_ima_btn:SetValue(self.cur_click_image ~= cur_huashen_id and 1 == activie_flag[self.cur_click_image])
end

function HuashenImageView:OnFlush(param_list)
	self:SetHuashenImageAttr()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

HuashenImageCell = HuashenImageCell or BaseClass(BaseRender)

function HuashenImageCell:__init()
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
end

function HuashenImageCell:SetData(data, is_show)
	if data == nil then
		return
	end
	-- local bundle, asset = ResPath.GetMountImage(data.monster_id)
	-- self.icon:SetAsset(bundle, asset)
	self.name:SetValue(data.name)
	self.show_red_ponit:SetValue(is_show)
end

function HuashenImageCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function HuashenImageCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function HuashenImageCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end
