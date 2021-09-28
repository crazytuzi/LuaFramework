GoddessGongMingView = GoddessGongMingView or BaseClass(BaseRender)
local GONGMING_GRID_NUMBER = 28
function GoddessGongMingView:__init(instance)
	for i=0,3 do
		self["gongming_shengwu_icon" .. i] = GoddessGongMingShengWuIconItem.New(self:FindObj("GoddessGongMingShengWuIcon_" .. i))
		-- self["gongming_shengwu_icon" .. i]:SetShengWuId(i)
	end

	for i=0,GONGMING_GRID_NUMBER do
		self["gongming_icon" .. i] = GoddessGongMingIconItem.New(self:FindObj("GoddessGongMingIcon" .. i))
		self["gongming_icon" .. i]:SetGridId(i)
	end

	for i=0,GONGMING_GRID_NUMBER do
		self:ListenEvent("OnClickGongMingIcon" .. i,BindTool.Bind(self.OnClickGongMingIcon, self, i))
	end

	self.show_gongming_text = self:FindVariable("ShowGongMingText")
	self:InitLine()

	self:ListenEvent("OnClickBtnMingLing",BindTool.Bind(self.OnClickBtnMingLing, self))
	self:ListenEvent("OnClickGongMingTip",BindTool.Bind(self.OnClickGongMingTip, self))
	self:ListenEvent("EventTip", BindTool.Bind(self.OnClickTip, self))

	self.isQuick = true
	self.quick_toggle = self:FindObj("QuickToggle")
	self.quick_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnQuickToggleChange, self))

	self.totalPower = self:FindVariable("TotalPower")
end

function GoddessGongMingView:InitLine()
	local line_cfg = GoddessData.Instance:GetGridLineAllCfg()
	for k, v in pairs(line_cfg) do
		local grid_id = tonumber(v.grid_id)
		local grid_y_id_1 = tonumber(v.grid_y_id_1)
		local grid_y_id_2 = tonumber(v.grid_y_id_2)
		if grid_y_id_1 then
			self["line" .. grid_id .. "_" .. grid_y_id_1] = GoddessGongMingLineItem.New(self:FindObj("line" .. grid_id .. "_1"))
			self["line" .. grid_id .. "_" .. grid_y_id_1]:SetGridId(grid_id)
			self["line" .. grid_id .. "_" .. grid_y_id_1]:SetGridShowId(grid_y_id_1)
		end
		if grid_y_id_2 then
			self["line" .. grid_id .. "_" .. grid_y_id_2] = GoddessGongMingLineItem.New(self:FindObj("line" .. grid_id .. "_2"))
			self["line" .. grid_id .. "_" .. grid_y_id_2]:SetGridId(grid_id)
			self["line" .. grid_id .. "_" .. grid_y_id_2]:SetGridShowId(grid_y_id_2)
		end
	end

	self.red_point = self:FindVariable("ShowRedPoint")
end

function GoddessGongMingView:UpdateTotalPower()
	local total = 0
	for i=0,GONGMING_GRID_NUMBER do
		local level = GoddessData.Instance:GetXiannvShengwuGridLevel(i)
		local data_cfg = GoddessData.Instance:GetXianNvGongMingCfg(i, level)
		local attr_list = CommonDataManager.GetGoddessAttributteNoUnderline(data_cfg)
		total = total + CommonDataManager.GetCapability(attr_list) + data_cfg.capbility
	end
	self.totalPower:SetValue(total)
end

function GoddessGongMingView:UpdataLine()
	local line_cfg = GoddessData.Instance:GetGridLineAllCfg()
	for k, v in pairs(line_cfg) do
		local grid_id = tonumber(v.grid_id)
		local grid_y_id_1 = tonumber(v.grid_y_id_1)
		local grid_y_id_2 = tonumber(v.grid_y_id_2)
		if grid_y_id_1 and self["line" .. grid_id .. "_" .. grid_y_id_1] then
			self["line" .. grid_id .. "_" .. grid_y_id_1]:SetGridShowId(grid_y_id_1)
		end
		if grid_y_id_2 and self["line" .. grid_id .. "_" .. grid_y_id_2] then
			self["line" .. grid_id .. "_" .. grid_y_id_2]:SetGridShowId(grid_y_id_2)
		end
	end
end

function GoddessGongMingView:DeleteLine()
	local line_cfg = GoddessData.Instance:GetGridLineAllCfg()
	for k, v in pairs(line_cfg) do
		local grid_id = tonumber(v.grid_id)
		local grid_y_id_1 = tonumber(v.grid_y_id_1)
		local grid_y_id_2 = tonumber(v.grid_y_id_2)
		if grid_y_id_1 and self["line" .. grid_id .. "_" .. grid_y_id_1] then
			self["line" .. grid_id .. "_" .. grid_y_id_1]:DeleteMe()
			self["line" .. grid_id .. "_" .. grid_y_id_1] = nil
		end
		if grid_y_id_2 and self["line" .. grid_id .. "_" .. grid_y_id_2] then
			self["line" .. grid_id .. "_" .. grid_y_id_2]:DeleteMe()
			self["line" .. grid_id .. "_" .. grid_y_id_2] = nil

		end
	end
end

function GoddessGongMingView:UpdataGongMingGrid()
	for i = 0, 28 do
		if self["gongming_icon" .. i] then
			self["gongming_icon" .. i]:SetGridId(i)
		end
	end
	self:UpdataLine()
	self:UpdataGongMingLingYe()
	self:FlushRedPoint()
end

function GoddessGongMingView:__delete()
	for i=0,3 do
		if nil ~= self["gongming_shengwu_icon" .. i] then
			self["gongming_shengwu_icon" .. i]:DeleteMe()
			self["gongming_shengwu_icon" .. i] = nil
		end
	end

	for i=0,28 do
		if nil ~= self["gongming_icon" .. i] then
			self["gongming_icon" .. i]:DeleteMe()
			self["gongming_icon" .. i] = nil
		end
	end

	self:DeleteLine()
	self.show_gongming_text = nil
	self.red_point = nil
end

function GoddessGongMingView:OnFlush()
	for i = 0, 28 do
		if self["gongming_icon" .. i] then
			self["gongming_icon" .. i]:SetGridId(i)
		end
	end
	self:UpdataLine()
	self:UpdataGongMingShengWu()
	self:UpdataGongMingLingYe()
	self:FlushRedPoint()
	self:UpdateTotalPower()
	RemindManager.Instance:Fire(RemindName.Goddess_GongMing_Grid)
end

function GoddessGongMingView:FlushRedPoint()
	if self.red_point ~= nil then
		self.red_point:SetValue(GoddessData.Instance:GetGongMingRed())
	end
end

function GoddessGongMingView:UpdataGongMingShengWu()
	for i = 0, 3 do
		if nil ~= self["gongming_shengwu_icon" .. i] then
			self["gongming_shengwu_icon" .. i]:SetShengWuId(i)
		end
	end
end

function GoddessGongMingView:UpdataGongMingLingYe()
	self.show_gongming_text:SetValue(GoddessData.Instance:GetShengWuLingYeValue())
end

function GoddessGongMingView:OnClickBtnMingLing()
   ViewManager.Instance:Open(ViewName.GoddessSearchAuraView)
end

function GoddessGongMingView:OnClickGongMingTip()
	local total_attr = GoddessData.Instance:GetXiannvGridTotalAttr()
	TipsCtrl.Instance:ShowAttrAllView(total_attr)
end

function GoddessGongMingView:OnClickGongMingIcon(index)
	if self.isQuick then
		self:UpgradeGrid(index)
	else
		GoddessCtrl.Instance:OpenGoddessGongMingUpView(index)
	end
end

function GoddessGongMingView:OnQuickToggleChange(isOn)
	self.isQuick = isOn
end

function GoddessGongMingView:UpgradeGrid(grid_id)
	local level = GoddessData.Instance:GetXiannvShengwuGridLevel(grid_id)
	local info_data = GoddessData.Instance:GetXianNvGridIconCfg(grid_id)
	local can_click = true
	if info_data then
		can_click = GoddessData.Instance:GetXianNvGridIconIsCan(info_data)
	end

	local next_data = GoddessData.Instance:GetXianNvGongMingCfg(grid_id, level)
	if next_data == nil then
		info_data = nil
		return
	end

	if next(next_data) then
		local cur_lingye = GoddessData.Instance:GetShengWuLingYeValue()
		if cur_lingye >= next_data.upgrade_need_ling and can_click then
			GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.UPGRADE_GRID, grid_id)
		elseif can_click == false then
			TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.GoddessUpTextNoClick)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.GoddessUpTextNo)
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.GoddessUpTextManJi)
	end
	info_data = nil
end

function GoddessGongMingView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(207)
end

-------------------------------------------共鸣icon
GoddessGongMingIconItem = GoddessGongMingIconItem or BaseClass(BaseRender)
function GoddessGongMingIconItem:__init()
	self.img_icon = self:FindVariable("Icon")
	self.level_text = self:FindVariable("IconLevel")
	self.grid_id = 0
	self.grid_level = 1
	self.grid_color = 1
	self.effect = nil

	self:Flush()
end

function GoddessGongMingIconItem:__delete()
	if self.effect then
		GameObject.Destroy(self.effect)
		self.effect = nil
	end
end

function GoddessGongMingIconItem:CreateEffect()
	if self.effect then
		self.effect:SetActive(true)
	 	return
	end

	PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_kuoquan_prefab", "UI_kuoquan"), function (prefab)
		if not prefab then return end

		local obj = GameObject.Instantiate(prefab)
		PrefabPool.Instance:Free(prefab)
		local transform = obj.transform
		transform:SetParent(self.root_node.transform, false)
		self.effect = obj.gameObject
		if self.grid_id == GODDRESS_XIANNV_GRID_ID_12 then
			obj.transform.localScale = Vector3(0.6, 0.6, 0.6)
		elseif self.grid_id == GODDRESS_XIANNV_GRID_ID_25 or
			self.grid_id == GODDRESS_XIANNV_GRID_ID_26 or
			self.grid_id == GODDRESS_XIANNV_GRID_ID_27 or
			self.grid_id == GODDRESS_XIANNV_GRID_ID_28 then
			obj.transform.localScale = Vector3(0.6, 0.6, 0.6)
		else
			obj.transform.localScale = Vector3(0.5, 0.5, 0.5)
		end
	end)
end

function GoddessGongMingIconItem:OnFlush()
	local info_data = GoddessData.Instance:GetXianNvGridIconCfg(self.grid_id)
	local level = GoddessData.Instance:GetXiannvShengwuGridLevel(self.grid_id)
	local info_cfg = GoddessData.Instance:GetXianNvGongMingCfg(self.grid_id, level)
	self.grid_color = info_cfg.color

	if GoddessData.Instance:GetXianNvGridIconIsCanUp(self.grid_id) then
		self:CreateEffect()
	else
		if self.effect ~= nil then
			self.effect:SetActive(false)
		end
	end

	local img_str = "gongming_"

	if self.grid_id == GODDRESS_XIANNV_GRID_ID_12 then
		img_str = "gongming_s_"
	elseif self.grid_id == GODDRESS_XIANNV_GRID_ID_25 or
		self.grid_id == GODDRESS_XIANNV_GRID_ID_26 or
		self.grid_id == GODDRESS_XIANNV_GRID_ID_27 or
		self.grid_id == GODDRESS_XIANNV_GRID_ID_28 then
		img_str = "gongming_t_"
	else
		img_str = "gongming_"
	end

	local color = self.grid_color
	if level == 0 then
		color = 0
	end
	self.img_icon:SetAsset(ResPath.GetGoddessRes(img_str .. color))
	self.level_text:SetValue(tostring(level))
	info_data = nil
end

function GoddessGongMingIconItem:UpdataView()
	self:Flush()
end

function GoddessGongMingIconItem:SetGridId(grid_id)
	self.grid_id = grid_id
	self:Flush()
end

----------------------------------------圣物icon
GoddessGongMingShengWuIconItem = GoddessGongMingShengWuIconItem or BaseClass(BaseRender)
function GoddessGongMingShengWuIconItem:__init()
	self.shengwu_id = 0
	self.shengwu_level = 0
	self.icon_level = self:FindVariable("icon_level")

	self.display = self:FindObj("display")
	self.model = RoleModel.New("goddess_gongming_panel")
	self.model:SetDisplay(self.display.ui3d_display)
	self.model_id = nil
end

function GoddessGongMingShengWuIconItem:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.model_id = nil
end

function GoddessGongMingShengWuIconItem:OnFlush()
	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.shengwu_id)
	self.shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level)
	if info_data == nil then
		return
	end
	-- if self.model then
	-- 	self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.GATHER], info_data.display_id, DISPLAY_PANEL.XIAN_NV)
	-- 	local asset, bundle = ResPath.GetGatherModel(info_data.display_id)
	-- 	self.model:SetMainAsset(asset, bundle)
	-- end

	if self.model then
		local need_change = false
		if self.model_id == nil then
			self.model_id = info_data.display_id
			need_change = true
		else
			if self.model_id ~= info_data.display_id then
				need_change = true
				self.model_id = info_data.display_id
			end
		end

		if need_change then
			self.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.HUNQI], info_data.display_id, DISPLAY_PANEL.XIAN_NV)
			local asset, bundle = ResPath.GetHunQiModel(info_data.display_id)
			self.model:SetMainAsset(asset, bundle)
			self.model_id  = info_data.display_id
		end
	end

	self.icon_level:SetValue(string.format(Language.Goddess.GoddessShengWuName, info_data.name, info_data.level))
end


function GoddessGongMingShengWuIconItem:SetShengWuId(index)
	self.shengwu_id = index
	self:Flush()
end

----------------------------------------共鸣line icon
GoddessGongMingLineItem = GoddessGongMingLineItem or BaseClass(BaseRender)
function GoddessGongMingLineItem:__init()
	self.grid_id = 0
	self.grid_show_id = 0
	self.line_bg = self:FindVariable("line_bg")
	self.line_show = self:FindVariable("line_show")
	self.line_show_res = nil
	self:Flush()
end

function GoddessGongMingLineItem:__delete()
	self.line_show_res = nil
end

function GoddessGongMingLineItem:OnFlush()
	-- local level = GoddessData.Instance:GetXiannvShengwuGridLevel(self.grid_show_id)
	local now_level = GoddessData.Instance:GetXiannvShengwuGridLevel(self.grid_id)
	local line_data = GoddessData.Instance:GetGridLineCfg(self.grid_id)
	-- local line_show_data = GoddessData.Instance:GetXianNvGongMingCfg(self.grid_show_id, level)
	local now_line_show_data = GoddessData.Instance:GetXianNvGongMingCfg(self.grid_id, now_level)

	if line_data and now_line_show_data then
		self.line_bg:SetAsset(ResPath.GetGoddessRes("shengwu_line_" .. line_data.line_1 .. "_" .. now_line_show_data.color))

		if GoddessData.Instance:GetGridLineShowByGrid(self.grid_show_id) then
			self.line_show:SetAsset(ResPath.GetGoddessRes("shengwu_line_" .. line_data.line_2 .. "_" .. now_line_show_data.color))
		else
			self.line_show:SetAsset(nil, nil)
		end
	end
end

function GoddessGongMingLineItem:SetGridId(index)
	self.grid_id = index
end

function GoddessGongMingLineItem:SetGridShowId(index)
	self.grid_show_id = index
	self:Flush()
end