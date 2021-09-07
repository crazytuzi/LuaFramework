local attr_order = {
	[1] = "gongji",
	[2] = "fangyu",
	[3] = "maxhp",
	-- [4] = "mingzhong",
	-- [5] = "shanbi",
	-- [6] = "baoji",
	-- [7] = "jianren",
}
local attr_img = {
	[1] = "gj",
	[2] = "fy",
	[3] = "hp",
}
local EFFECT_CD = 1
local CENTER_POINT_OFFSET = 60

ZhiBaoView = ZhiBaoView or BaseClass(BaseRender)
function ZhiBaoView:__init(instance)
	ZhiBaoView.Instance = self
	self.cell_position_list = {}
	self.activedegree_data = ZhiBaoData.Instance:GetActiveDegreeScrollerData()[1]
	self.use_image = ZhiBaoData.Instance:GetJsByLevel(ZhiBaoData.Instance:GetZhiBaoLevel())
	self.cur_select_index = 1
end

function ZhiBaoView:LoadCallBack(instance)
	--六个属性
	self.attr_list = {}
	local obj_group = self:FindObj("ObjGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "AttrGroup") ~= nil then
			self.attr_list[count] = ZhiBaoUpgradeAttrGroup.New(obj)
			self.attr_list[count]:SetIndex(count)
			count = count + 1
		end
	end
	--阶级
	self.class_value = -1
	--等级
	self.current_level = self:FindVariable("CurrentLevel")
	self.next_level = self:FindVariable("NextLevel")
	self.level_text = self:FindVariable("LevelText")
	--显示图片
	self.show_image = self:FindVariable("ShowImage")
	self.show_name_image = self:FindVariable("ShowImageName")
	self.preview_name = self:FindVariable("PreviewName")
	self.image_effect = self:FindVariable("Effect")
	--战力
	self.power = self:FindVariable("Power")
	self.enter_btn = self:FindObj("EntetBtn")


	--经验条
	self.slider_value = self:FindVariable("SliderValue")
	self.slider_text = self:FindVariable("SliderText")
	--升级红点
	self.show_upgrade_red_point = self:FindVariable("ShowUpgradeRedPoint")

	self:ListenEvent("ClickLeftArrow", BindTool.Bind(self.OnLeftArrowClick, self))		-- 点击左箭头
	self:ListenEvent("ClickRightArrow", BindTool.Bind(self.OnRightArrowClick, self))		-- 点击右箭头
	self:ListenEvent("UpgradeClick", BindTool.Bind(self.OnUpgradeClick, self))
	-- self:ListenEvent("HuanHuaClick", BindTool.Bind(self.HuanHuaClick, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.HelpClick, self))
	self:ListenEvent("GoClick", BindTool.Bind(self.OnGoClick, self))
	self.selet_data_index = ZhiBaoData.Instance:GetJsByLevel(ZhiBaoData.Instance:GetZhiBaoLevel())
	self:AniFinish()
	self:InitScroller()
end

function ZhiBaoView:__delete()
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
end

function ZhiBaoView:OpenCallBack()

end

function ZhiBaoView:CloseCallBack()
end

function ZhiBaoView:InitScroller()
	self.cell_list = {}
	self.scroller_data = ZhiBaoData.Instance:GetActiveDegreeScrollerData()
	self.scroller = self:FindObj("Scroller")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		if nil == self.cell_list[cell] then
			self.cell_list[cell] = ActiveDegreeScrollCell.New(cell.gameObject)
			self.cell_list[cell]:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		end
		self.cell_list[cell]:SetIndex(data_index)
		self.cell_list[cell]:SetSelect(self.cur_select_index)
		self.cell_list[cell]:SetData(self.scroller_data[data_index])
	end
end

function ZhiBaoView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data then return end
	self.cur_select_index = cell.index
	self.activedegree_data = cell.data
	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
end

function ZhiBaoView:SetModelData()
	if 0 >= self.selet_data_index then
		self.selet_data_index = 1
	end
	local bundle, asset = ResPath.GetRawImage("jun_0" .. self.selet_data_index)
	if self.show_image then
		self.show_image:SetAsset(bundle, asset)
	end
	local bundle, asset = ResPath.GetActiveDegreeIcon("jun_name_" .. self.selet_data_index)
	if self.show_name_image then
		self.show_name_image:SetAsset(bundle, asset)
	end

	local eff_name = "UI_jun_0" .. self.selet_data_index
	self.image_effect:SetAsset("effects2/prefab/ui/" .. string.lower(eff_name) .. "_prefab", eff_name)
end

function ZhiBaoView:OnLeftArrowClick()
	self.selet_data_index = self.selet_data_index - 1
	if self.selet_data_index < 1 then
		self.selet_data_index = 1
	end
	self:AniFinish()
end

function ZhiBaoView:OnRightArrowClick()
	self.selet_data_index = self.selet_data_index + 1
	if self.selet_data_index > 5 then
		self.selet_data_index = 5
	end
	self:AniFinish()
end

function ZhiBaoView:AniFinish()
	local level_cfg = ZhiBaoData.Instance:GetLevelImageCfg(self.selet_data_index < 1 and 1 or self.selet_data_index)
	local max_image = ZhiBaoData.Instance:GetMaxImageNum()
	local active_index = ZhiBaoData.Instance:GetJsByLevel(ZhiBaoData.Instance:GetZhiBaoLevel())
	local right_arrow = self:FindObj("RightArrow")
	local left_arrow = self:FindObj("LeftArrow")
	if not level_cfg then
		return
	end
	left_arrow:SetActive(self.selet_data_index > 1)
	right_arrow:SetActive(self.selet_data_index < max_image and active_index > self.selet_data_index)
	self.preview_name:SetValue(string.format(Language.BaoJu.Medaljie, Language.Common.NumToChs[level_cfg.image_id]) .. level_cfg.name)
	-- self.preview_class:SetValue(level_cfg.image_id)
	if self.selet_data_index > max_image then
		self.selet_data_index = max_image
	end
	self:SetModelData()
end


function ZhiBaoView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "all" then
			self:FlushZhaiBaoData()
		end
	end
end

function ZhiBaoView:FlushZhaiBaoData()
	local zhibao_level = ZhiBaoData.Instance:GetZhiBaoLevel()
	if zhibao_level == nil then
		return
	end

	self.show_upgrade_red_point:SetValue(ZhiBaoData.Instance:CheckZhiBaoCanUpgrade())

	local cu_cfg = ZhiBaoData.Instance:GetLevelCfgByLevel(zhibao_level)
	local next_cfg = ZhiBaoData.Instance:GetLevelCfgByLevel(zhibao_level + 1)
	-- self.is_max_level:SetValue((next_cfg==nil))
	self.level_text:SetValue(next_cfg == nil and Language.Common.YiManJi or Language.Common.UpGrade)
	--普通属性对
	local attrs = CommonDataManager.GetAttributteNoUnderline(cu_cfg)
	local next_attrs = CommonDataManager.GetAttributteNoUnderline(next_cfg)
	for k,v in pairs(self.attr_list) do
		v:SetActive(false)
	end
	local count = 1
	for i=1,#attr_order do
		local key = attr_order[i]
		-- if attrs[key] > 0 then
			local name = CommonDataManager.GetAttrName(key)
			local next_attr_text = nil
			if next_cfg ~= nil then
				next_attr_text = next_attrs[key]
			end
			count = self:AttrSetData(name, attrs[key], count, next_attr_text)
		-- end
	end
	--坐骑羽翼属性对
	--当前
	local mount_add = 0
	local wing_add = 0

	mount_add = cu_cfg.mount_attr_add
	wing_add = cu_cfg.wing_attr_add
	--下一
	local next_mount_cfg, next_wing_cfg = ZhiBaoData.Instance:GetNextAdditionCfg(mount_add, wing_add)
	--下一坐骑
	local m_name = Language.Common.AdvanceAttrName.mount_attr
	local m_value = '+'..(mount_add / 100)..'%'
	local m_next_value = nil
	if next_mount_cfg ~= nil then
		m_next_value = (next_mount_cfg.mount_attr_add / 100)..'%'..'('..next_mount_cfg.level..Language.Common.Ji..')'
	end
	count = self:AttrSetData(m_name, m_value, count, m_next_value)
	--下一羽翼
	local w_name = Language.Common.AdvanceAttrName.wing_attr
	local w_value = '+'..(wing_add / 100)..'%'
	local w_next_value = nil
	if next_wing_cfg ~= nil then
		w_next_value = (next_wing_cfg.wing_attr_add / 100)..'%'..'('..next_wing_cfg.level..Language.Common.Ji..')'
	end
	count = self:AttrSetData(w_name, w_value, count, w_next_value)
	--经验
	local playr_zhibao_exp = ZhiBaoData.Instance:GetZhiBaoExp()
	local next_level_text = ""
	local slider_value = 0
	local slider_text = ""
	if next_cfg ~= nil then
		slider_value = playr_zhibao_exp / cu_cfg.uplevel_exp
		next_level_text = 'Lv.'..zhibao_level + 1
		slider_text = playr_zhibao_exp..' / '..cu_cfg.uplevel_exp
	else
		slider_value = 100
		next_level_text = ""
		slider_text = "-/-"
	end
	--等级
	self.current_level:SetValue("Lv"..zhibao_level)
	self.next_level:SetValue(next_level_text)
	--经验进度条
	self.slider_value:SetValue(slider_value)
	self.slider_text:SetValue(slider_text)
	--战斗力
	self.power:SetValue(CommonDataManager.GetCapabilityCalculation(attrs))

	if self.use_image ~= ZhiBaoData.Instance:GetJsByLevel(ZhiBaoData.Instance:GetZhiBaoLevel()) then
		self.use_image = ZhiBaoData.Instance:GetJsByLevel(ZhiBaoData.Instance:GetZhiBaoLevel())
		self.selet_data_index = ZhiBaoData.Instance:GetJsByLevel(ZhiBaoData.Instance:GetZhiBaoLevel())
		self:AniFinish()
	end
end

function ZhiBaoView:AttrSetData(name, now_value, count, next_value)
	if count > #self.attr_list then
		return count
	end
	local data = {}
	local name_txt = name..": "
	local value_txt = now_value
	data.now_attr_text = name_txt..ToColorStr(now_value, "#ffffff")
	if next_value ~= nil then
		data.next_attr_text = next_value
	end
	self.attr_list[count]:SetActive(true)
	self.attr_list[count]:SetData(data)
	count = count + 1
	return count
end

function ZhiBaoView:HelpClick()
	local tips_id = 20    -- 宝具tips
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ZhiBaoView:OnUpgradeClick()
	if ZhiBaoData.Instance:GetZhiBaoCanUpgrade() then
		ZhiBaoCtrl.Instance:SendZhiBaoUpgrade()
		AudioService.Instance:PlayAdvancedAudio()
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotEnoughZhiBaoExp)
	end
end

function ZhiBaoView:OnGoClick()
	if nil == self.activedegree_data then return end

	if self.activedegree_data.goto_panel ~= "" then
		if self.activedegree_data.goto_panel == "GuildTask" then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.GUILD)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotGuildTask)
				return
			end
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.BaoJu)
			return
		elseif self.activedegree_data.goto_panel == "DailyTask"then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
			print("task_id:  "..task_id)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotDailyTask)
				return
			end
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.BaoJu)
			return
		elseif self.activedegree_data.goto_panel == "HuSong"then
			ViewManager.Instance:Close(ViewName.BaoJu)
			YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
			return
		end
		ViewManager.Instance:Close(ViewName.BaoJu)
		local t = Split(self.activedegree_data.goto_panel, "#")
		local view_name = t[1]
		local tab_index = t[2]
		if view_name == "FuBen" then
			FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
			FuBenCtrl.Instance:SendGetExpFBInfoReq()
			FuBenCtrl.Instance:SendGetStoryFBGetInfo()
			FuBenCtrl.Instance:SendGetVipFBGetInfo()
			FuBenCtrl.Instance:SendGetTowerFBGetInfo()
		elseif view_name == "Activity" then
			ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE[tab_index])
			return
		end
		ViewManager.Instance:Open(view_name, TabIndex[tab_index])
	end
end

function ZhiBaoView:GetEnterBtn()
	return self.enter_btn
end

function ZhiBaoView:GetEnterCallBack()
	return BindTool.Bind(self.OnGoClick, self)
end


ZhiBaoUpgradeAttrGroup = ZhiBaoUpgradeAttrGroup or BaseClass(BaseCell)
function ZhiBaoUpgradeAttrGroup:__init()
	self.now_attr = self:FindVariable("NowAttr")
	self.next_attr = self:FindVariable("NextAttr")
	self.show_next = self:FindVariable("ShowNext")
	self.attr_icon = self:FindVariable("Icon")
end

function ZhiBaoUpgradeAttrGroup:__delete()
end

function ZhiBaoUpgradeAttrGroup:OnFlush()
	self.now_attr:SetValue(self.data.now_attr_text)
	if self.data.next_attr_text ~= nil then
		-- self.show_next:SetValue(true)
		self.next_attr:SetValue(self.data.next_attr_text)
	else
		self.show_next:SetValue(false)
	end
	local path_name = attr_img[self.index] and "icon_info_" .. attr_img[self.index] or "icon_info_gj"
	if self.attr_icon then
		local bundle, asset = ResPath.GetImages(path_name)
		self.attr_icon:SetAsset(bundle, asset)
	end
end



----------------------------------------------------------------------------
--ActiveDegreeScrollCell 		活跃滚动条格子
----------------------------------------------------------------------------
ActiveDegreeScrollCell = ActiveDegreeScrollCell or BaseClass(BaseCell)
function ActiveDegreeScrollCell:__init(instance)
	self.exp = self:FindVariable("Exp")
	self.item_name = self:FindVariable("Name")
	self.icon = self:FindVariable("Icon")
	self.times = self:FindVariable("Times")
	self:ListenEvent("AddButtonClick", BindTool.Bind(self.OnAddClick, self))
	self:ListenEvent("GoClick", BindTool.Bind(self.OnClick, self))
	self.have_go_to = self:FindVariable("HaveGoTo")
	self.is_grey = self:FindVariable("is_grey")
	self.is_show_time = self:FindVariable("is_show_time")
	self.time = self:FindVariable("time")
	self.show_arrow = self:FindVariable("show_arrow")
	self.show_select = self:FindVariable("ShowSelect")
	self.show_red = self:FindVariable("ShowRed")

	--引导用按钮
	self.btn_go = self:FindObj("BtnGo")
	
	self.active_degree_item = self:FindObj("ActiveDegreeItem")

	self.activity_time_change_callback = BindTool.Bind(self.HandleTime, self)
	WelfareData.Instance:NotifyWhenTimeChange(self.activity_time_change_callback)
end

function ActiveDegreeScrollCell:__delete()
	if WelfareData.Instance ~= nil then
		WelfareData.Instance:UnNotifyWhenTimeChange(self.activity_time_change_callback)
	end
end

function ActiveDegreeScrollCell:OnFlush()
	local degree = ZhiBaoData.Instance:GetActiveDegreeListBySeq(self.data.show_seq) or 0
	self.exp:SetValue(self.data.once_add_degree)
	self.item_name:SetValue(self.data.act_name)
	self.icon:SetAsset(ResPath.GetBaojuImage(self.data.pic_id))
	self.times:SetValue(degree..' / '..self.data.max_times)
	self.show_red:SetValue(degree < self.data.max_times)
	if self.data.type == 0 then
		if degree >= self.data.max_times then
			self.is_show_time:SetValue(false)
		else
			self.is_show_time:SetValue(true)
		end
	else
		self.is_show_time:SetValue(false)
	end

	if degree >= self.data.max_times then
		self.is_grey:SetValue(true)
	else
		self.is_grey:SetValue(false)
	end

	if self.data.goto_panel ~= nil and self.data.goto_panel ~= "" then
		self.have_go_to:SetValue(false)
	else
		self.have_go_to:SetValue(false)
	end
end

function ActiveDegreeScrollCell:SetSelect(index)
	self.show_select:SetValue(index == self.index)
end

function ActiveDegreeScrollCell:HandleTime()
	local hour, min, sec = WelfareData.Instance:GetOnlineTime()
	self.time:SetValue(string.format("%s:%s:%s",hour,min,sec))
end

function ActiveDegreeScrollCell:OnAddClick()

end

--引导用
function ActiveDegreeScrollCell:GetDailyName()
	local data = self.data or {}
	return data.act_name
end

function ActiveDegreeScrollCell:GetGotoPanel()
	local data = self.data or {}
	return data.goto_panel
end

function ActiveDegreeScrollCell:ShowArrow(is_show)
	local degree = ZhiBaoData.Instance:GetActiveDegreeListBySeq(self.data.show_seq) or 0
	local is_show = is_show and degree < self.data.max_times and self.data.act_name ~= "在线小时"
	self.show_arrow:SetValue(false)
end

function ActiveDegreeScrollCell:GetHeight()
	return self.root_node.rect.rect.height
end

function ActiveDegreeScrollCell:GetActiveDegreeItem()
	return self.active_degree_item
end