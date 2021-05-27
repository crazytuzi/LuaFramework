--------------------------------------------------------
-- "时装-拥有" "时装-预览" "幻武-拥有" "幻武-预览"视图  配置 
--------------------------------------------------------

local FashionPossessionView = FashionPossessionView or BaseClass(SubView)

function FashionPossessionView:__init()
	self.texture_path_list[1] = 'res/xui/fashion.png'
	self:SetModal(true)
	self.config_tab = {
		{"fashion_ui_cfg", 1, {0}},
	}

end

function FashionPossessionView:__delete()
end

--释放回调
function FashionPossessionView:ReleaseCallBack()
	self.set_flag = nil
end

--加载回调
function FashionPossessionView:LoadCallBack(index, loaded_times)
	self:InitAttrTitle()
	self:CreateTabbar()
	self:CreateRoleDisPlay()
	self:CreateFashionGrid()
	self:CreateAttrList()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["layout_check"].node, BindTool.Bind(self.CheckHook, self))
	XUI.AddClickEventListener(self.node_t_list["btn_desc"].node, BindTool.Bind(self.OnDesc, self))

	-- 数据监听
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	self:BindGlobalEvent(SettingEventType.FASHION_SAVE_CHANGE, BindTool.Bind(self.ChangeState, self))
	self:BindGlobalEvent(NewFashionEvent.FaShionAdd,BindTool.Bind(self.FlushFashionGrid, self))
	self:BindGlobalEvent(NewFashionEvent.FaShionDelete,BindTool.Bind(self.FlushFashionGrid, self))
	self:BindGlobalEvent(NewFashionEvent.FaShionUpdate,BindTool.Bind(self.FlushFashionGrid, self))
end

function FashionPossessionView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function FashionPossessionView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()

	self.set_flag = nil
end

--显示指数回调
function FashionPossessionView:ShowIndexCallBack(index)
	self:ChangeState()

	self:Flush()
end

function FashionPossessionView:OnFlush(param_list)
	self:FlushFashionGrid()
	self:FlushAttrList()
	self:UpdateApperance()
end

----------视图函数----------

function FashionPossessionView:InitAttrTitle()
	local title_text = ""

	if self.view_def == ViewDef.Fashion.FashionChild.FashionPossession
	or self.view_def == ViewDef.Fashion.FashionChild.FashionPreview then
		title_text = "时装属性"
	else
		title_text = "幻武属性"
	end

	self.node_t_list["lbl_attr_title"].node:setString(title_text)
end

function FashionPossessionView:CreateTabbar()
	local parent = self.node_t_list["layout_fashion"].node
	local ph = self.ph_list["ph_tabbar"] or {x = 0, y = 0, w = 10, h = 10} -- 锚点为0,0
	local name_list = {"", ""} 	-- 标题文本
	local is_vertical = false 		-- 按钮-垂直排列
	local path = ResPath.GetCommon("toggle_102")
	local font_size = 25 			-- 标题字体大小
	local is_txt_vertical = false	-- 文本-垂直排列
	local interval = 17 			-- 间隔
	
	local callback = BindTool.Bind(self.TabbarSelectCallBack, self)   -- 点击回调
	
	local tabbar = Tabbar.New()
	tabbar:SetSpaceInterval(interval)
	tabbar:SetAlignmentType(Tabbar.AlignmentType.Center)
	tabbar:CreateWithNameList(parent, ph.x, ph.y, callback, name_list, is_vertical, path, font_size, is_txt_vertical)
	self.tabbar = tabbar
	self:AddObj("tabbar")
end

function FashionPossessionView:CreateRoleDisPlay()
	local role_display = RoleDisplay.New(self.node_t_list["layout_fashion"].node, 100, false, false, true, true)
	role_display:SetPosition(248, 295)
	role_display:SetScale(0.8)
	self.role_display = role_display
	self:AddObj("role_display")
end

function FashionPossessionView:UpdateApperance()
	if nil ~= self.role_display then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()

		self.role_display:SetRoleVo(role_vo)
	end
end

function FashionPossessionView:CreateFashionGrid()
	local ph = self.ph_list["ph_fashion_list"]
	local ph_item = {x = 0, y = 0, w = 80, h = 80}
	local parent = self.node_t_list["layout_fashion"].node
	local base_grid = BaseGrid.New()
	base_grid:SetSelectCallBack(BindTool.Bind(self.OnSelectCell, self))
	self.fashion_grid = base_grid
	self:AddObj("fashion_grid")

	local radio_btn = self.tabbar:GetRadioButton()
	base_grid:SetRadioBtn(radio_btn)

	local table ={w = ph.w,h = ph.h, cell_count = 24, col = 4, row = 3, itemRender = BaseCell, ui_config = ph_item}
	local grid_node = base_grid:CreateCells(table)
	grid_node:setPosition(ph.x, ph.y)
	parent:addChild(grid_node, 99)

	for i, cell in pairs(base_grid:GetAllCell()) do
		if self.view_def == ViewDef.Fashion.FashionChild.FashionPreview -- 装扮-时装-预览
		or self.view_def == ViewDef.Fashion.WuHuan.WuHuanPreview -- 装扮-幻武-预览
		then
			cell:SetIsShowTips(false)
		else
			cell:SetItemTipFrom(EquipTip.FROM_SHI_ZHUANG_GUI)
		end
	end
end

function FashionPossessionView:FlushFashionGrid()
	local data = {}
	if self.view_def == ViewDef.Fashion.FashionChild.FashionPossession then
		data = FashionData.Instance:GetFsahionData()
	elseif self.view_def == ViewDef.Fashion.FashionChild.FashionPreview then
		local cfg = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.fashion_preview or {}
		local cur_cfg = cfg[1] or {}
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		for i, v in ipairs(cur_cfg) do
			local item_id = 0
			if type(v) == "table" and next(v) then
				item_id = v[sex] or v[1]
			elseif type(v) == "number" then
				item_id = v
			end
			table.insert(data, {item_id = item_id, num = 1, is_bind = 0})
		end
	elseif self.view_def == ViewDef.Fashion.WuHuan.WuHuanPossession then -- 装扮-幻武-拥有
		data =  FashionData.Instance:GetHuanwuData()
	elseif self.view_def == ViewDef.Fashion.WuHuan.WuHuanPreview then-- 装扮-幻武-预览
		local cfg = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.fashion_preview or {}
		local cur_cfg = cfg[2] or {}
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		for i, v in ipairs(cur_cfg) do
			local item_id = 0
			if type(v) == "table" and next(v) then
				item_id = v[sex] or v[1]
			elseif type(v) == "number" then
				item_id = v
			end
			table.insert(data, {item_id = item_id, num = 1, is_bind = 0})
		end
	end

	local list = {}
	local index = 0
	for k, v in pairs(data) do
		list[index] = v
		index = index + 1
	end

	self.fashion_grid:SetDataList(list)
end

function FashionPossessionView:CreateAttrList()
	local ph = self.ph_list["ph_attr_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = self.ph_list["ph_attr_item"] or {x = 0, y = 0, w = 1, h = 1,}
	local parent = self.node_t_list["layout_fashion"].node
	local item_render = self.AttrTextRender
	local line_dis = ph_item.w
	local direction = ScrollDir.Vertical -- 滑动方向-横向 -- Vertical=1：竖向 Horizontal=2：横向：Both=3：横竖都可以
	
	local list = ListView.New() 
	list:Create(ph.x, ph.y, ph.w, ph.h, direction, item_render, nil, nil, ph_item)
	list:SetItemsInterval(2)
	list:SetMargin(2)
	parent:addChild(list:GetView(), 50)
	self.attr_list = list
	self:AddObj("attr_list")
end

function FashionPossessionView:FlushAttrList()
	local attr_list = {}

	if self.view_def == ViewDef.Fashion.FashionChild.FashionPossession -- 装扮-时装-拥有
	or self.view_def == ViewDef.Fashion.WuHuan.WuHuanPossession then -- 装扮-幻武-拥有
		local grid_data_list = self.fashion_grid:GetDataList()
		for i, item in pairs(grid_data_list) do
			local item_id = item.item_id
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			local cur_attr_list = ItemData.GetStaitcAttrs(item_cfg) or {}
			attr_list = CommonDataManager.AddAttr(attr_list, cur_attr_list)
		end
	elseif self.view_def == ViewDef.Fashion.FashionChild.FashionPreview -- 装扮-时装-预览
	or self.view_def == ViewDef.Fashion.WuHuan.WuHuanPreview then -- 装扮-幻武-预览
		if type(self.select_data) == "table" then
			local item_cfg = ItemData.Instance:GetItemConfig(self.select_data.item_id)
			attr_list = ItemData.GetStaitcAttrs(item_cfg) or {}
		end
	end

	attr_list = RoleData.FormatRoleAttrStr(attr_list)

	self.attr_list:SetDataList(attr_list)
end

----------end----------

-- "?"按钮点击回调
function FashionPossessionView:OnDesc()
	local language = Language or {}
	local desctip = Language.DescTip or {}
	local title = ""
	local desc = ""

	if self.view_def == ViewDef.Fashion.FashionChild.FashionPossession -- 装扮-时装-拥有
	or self.view_def == ViewDef.Fashion.FashionChild.FashionPreview -- 装扮-时装-预览
	then
		title = desctip.FashionTitle or ""
		desc = desctip.FashionContent or ""
	elseif self.view_def == ViewDef.Fashion.WuHuan.WuHuanPossession -- 装扮-幻武-拥有
	or self.view_def == ViewDef.Fashion.WuHuan.WuHuanPreview then -- 装扮-幻武-预览
		title = desctip.HuanWuTitle or ""
		desc = desctip.HuanWuContent or ""
	end

	DescTip.Instance:SetContent(desc, title)
end

function FashionPossessionView:CheckHook()
	local flag = self.node_t_list["img_hook"].node:isVisible() and 1 or 0
	self.node_t_list["img_hook"].node:setVisible(flag == 0)

	if nil == self.set_flag then
		local data = SettingData.Instance:GetDataByIndex(HOT_KEY.APPEAR_SAVE)
		local set_flag_t = bit:d2b(data)
		self.set_flag = set_flag_t
	end

	self.set_flag[33 -3] = flag
	local data = bit:b2d(self.set_flag)
	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.APPEAR_SAVE, data)
end

function FashionPossessionView:TabbarSelectCallBack(index)
	self.fashion_grid:ChangeToPage(index)
end

function FashionPossessionView:ChangeState()
	local data = SettingData.Instance:GetDataByIndex(HOT_KEY.APPEAR_SAVE)
	local set_flag_t = bit:d2b(data)
	self.set_flag = set_flag_t
	local data = {}
	for i = 1, #set_flag_t do
		data[i] =  set_flag_t[33 - i]
	end

	local flag = data[3]
	if self.node_t_list["img_hook"] then
		self.node_t_list["img_hook"].node:setVisible(flag == 0)
	end
end

function FashionPossessionView:OnSelectCell(cell)
	self.select_data = cell:GetData() or {}
	if next(self.select_data) then
		if self.view_def == ViewDef.Fashion.FashionChild.FashionPreview
		or self.view_def == ViewDef.Fashion.WuHuan.WuHuanPreview then
			self:FlushAttrList()

			local data = self.select_data
			local config = ItemData.Instance:GetItemConfig(data.item_id)

			if self.view_def == ViewDef.Fashion.FashionChild.FashionPreview then
				self.role_display:SetRoleResId(config.shape)
			elseif self.view_def == ViewDef.Fashion.WuHuan.WuHuanPreview then
				self.role_display:SetWuQiResId(config.shape)
			end
		end
	end
end


function FashionPossessionView:RoleDataChangeCallback(vo)
	if self:IsOpen() then
		if vo.key == OBJ_ATTR.ENTITY_MODEL_ID or vo.key == OBJ_ATTR.ACTOR_WEAPON_APPEARANCE then
			self:UpdateApperance()
		end
	end
end

----------------------------------------
-- 属性文本
----------------------------------------

FashionPossessionView.AttrTextRender = BaseClass(BaseRender)
local AttrTextRender = FashionPossessionView.AttrTextRender
function AttrTextRender:__init()
	
end

function AttrTextRender:__delete()

end

function AttrTextRender:CreateChild()
	BaseRender.CreateChild(self)
end

function AttrTextRender:OnFlush()
	if nil == self.data then 
		self.node_tree.lbl_attr_txt.node:setString("")
		return 
	end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. "：")
	self.node_tree.lbl_attr_txt.node:setString(self.data.value_str)
end

function AttrTextRender:CreateSelectEffect()
end


--------------------
return FashionPossessionView