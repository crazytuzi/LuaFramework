--------------------------------------------------------
-- 装扮-真气 视图  配置 ImageUpgradeCfg[suitId]
--------------------------------------------------------

-- 刷新逻辑 FlushFashionGrid - OnSelectCell - OnFlush

local FashionZhenQiView = FashionZhenQiView or BaseClass(SubView)

function FashionZhenQiView:__init()
	self.texture_path_list[1] = 'res/xui/fashion.png'
	self:SetModal(true)
	self.config_tab = {
		{"fashion_ui_cfg", 4, {0}},
	}
	self.select_data = nil
end

function FashionZhenQiView:__delete()
end

--释放回调
function FashionZhenQiView:ReleaseCallBack()
	self.set_flag = nil
	self.select_data = nil
	self.cur_zhenqi_data = nil
	self.effect = nil
	self.select_index = nil
end

--加载回调
function FashionZhenQiView:LoadCallBack(index, loaded_times)
	self:IntoLevelShow()
	self:CreateTabbar()
	self:CreateFashionGrid()
	self:CreateAttrList()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self))
	XUI.AddClickEventListener(self.node_t_list["btn_2"].node, BindTool.Bind(self.OnBtn2, self))
	XUI.AddClickEventListener(self.node_t_list["btn_desc"].node, BindTool.Bind(self.OnDesc, self))

	-- 数据监听
	self:BindGlobalEvent(NewFashionEvent.FaShionAdd,BindTool.Bind(self.OnFashionChange, self))
	self:BindGlobalEvent(NewFashionEvent.FaShionDelete,BindTool.Bind(self.OnFashionChange, self))
	self:BindGlobalEvent(NewFashionEvent.FaShionUpdate,BindTool.Bind(self.OnFashionChange, self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function FashionZhenQiView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function FashionZhenQiView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()

	self.select_data = nil
	self.select_index = nil
	self.cur_zhenqi_data = nil

	if self.effect then
		self.effect:setStop()
	end
end

--显示指数回调
function FashionZhenQiView:ShowIndexCallBack(index)
	self:FlushFashionGrid()
	self.fashion_grid:SelectCellByIndex(0)
end

function FashionZhenQiView:OnFlush(param_list)
	local select_data = self.select_data or {}
	local zhenqi_data = FashionData.Instance:GetZhenqiData() or {}
	self.cur_zhenqi_data = zhenqi_data[select_data.item_id]

	self:FlushAttrList()
	self:FlushLevelShow()

	local btn_title = self.cur_zhenqi_data and "进 阶" or "激 活"
	self.node_t_list["btn_1"].node:setTitleText(btn_title)

	local item_cfg = ItemData.Instance:GetItemConfig(select_data.item_id)
	local color = Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6))
	self.node_t_list["lbl_zhenqi_name"].node:setString(item_cfg.name)
	self.node_t_list["lbl_zhenqi_name"].node:setColor(color)

	local effect_id = item_cfg.shape or 0
	self:FlushEffect(effect_id)

	local cur_zhenqi_lv = self.cur_zhenqi_data and self.cur_zhenqi_data.zhenqi_lv or 0
	local suit_id = item_cfg.suitId or 0
	local cfg = ImageUpgradeCfg or {}
	local cur_cfg = cfg[suit_id] or {}
	local consume = nil
	if nil == self.cur_zhenqi_data then
		consume = {item_id = select_data.item_id or 0, num = 1, is_bind = 0}
	elseif (cur_zhenqi_lv + 1) <= #cur_cfg then
		local cur_consume = cur_cfg[cur_zhenqi_lv + 1] and cur_cfg[cur_zhenqi_lv + 1].consumes or {}
		consume = ItemData.InitItemDataByCfg(cur_consume[1]) or {}
	end

	local text = ""
	if consume then
		local item_cfg = ItemData.Instance:GetItemConfig(consume.item_id)
		local color = string.sub(string.format("%06x", item_cfg.color), 1, 6)
		local have_num = BagData.Instance:GetItemNumInBagById(item_cfg.item_id)
		local bool = consume.num and have_num >= consume.num
		local num_color = bool and COLORSTR.GREEN or COLORSTR.RED
		text = string.format("{color;%s;%s}{color;%s;(%s/%s)}", color, item_cfg.name, num_color, have_num, consume.num)
	else
		text = string.format("{color;%s;已达到最高阶}", COLORSTR.RED)
	end

	local rich = self.node_t_list["rich_consume"].node
	RichTextUtil.ParseRichText(rich, text, 22, COLOR3B.WHITE)
	rich:refreshView()

	self.node_t_list["btn_1"].node:setVisible(nil ~= consume)

	local path = self.cur_zhenqi_data and self.cur_zhenqi_data.zhuan_level == 1 and ResPath.GetFashion("fashion_14") or ResPath.GetFashion("fashion_5")
	self.node_t_list["btn_2"].node:loadTextures(path)
end

----------视图函数----------

function FashionZhenQiView:IntoLevelShow()
	local count = 10
	local path = ResPath.GetCommon("star")
	local parent = self.node_t_list["layout_zhenqi"].node
	local ph = self.ph_list["ph_star"] or {x = 0, y = 0, w = 10, h = 10}
	local x, y = ph.x, ph.y
	local img_width = ph.w / count or 24 -- 图标的宽
	local x_origin = x - ((count - 1) * img_width) / 2 -- 图标起点
	local img_y = y

	self.level_show_list = self.level_show_list or {}
	local list = self.level_show_list
	for i = 1, count do
		local img_x = x_origin + (i - 1) * img_width
		list[i] = XUI.CreateImageView(img_x, img_y, path, true)
		list[i]:setGrey(true)
		parent:addChild(list[i], 99)
	end
end

function FashionZhenQiView:FlushLevelShow()
	local cur_zhenqi_lv = self.cur_zhenqi_data and self.cur_zhenqi_data.zhenqi_lv or 0

	local list = self.level_show_list
	for i,v in ipairs(list) do
		list[i]:setGrey(cur_zhenqi_lv < i)
	end
end

function FashionZhenQiView:CreateTabbar()
	local parent = self.node_t_list["layout_zhenqi"].node
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

function FashionZhenQiView:CreateFashionGrid()
	local ph = self.ph_list["ph_fashion_list"]
	local ph_item = {x = 0, y = 0, w = 80, h = 80}
	local parent = self.node_t_list["layout_zhenqi"].node
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
		cell:SetIsShowTips(false)
	end
end

function FashionZhenQiView:FlushFashionGrid()
	local data = {}

	local cfg = CLIENT_GAME_GLOBAL_CFG and CLIENT_GAME_GLOBAL_CFG.fashion_preview or {}
	local cur_cfg = cfg[3] or {}
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

	local list = {}
	local index = 0
	for k, v in pairs(data) do
		list[index] = v
		index = index + 1
	end

	self.fashion_grid:SetDataList(list)
	local cur_cell = self.fashion_grid:GetCurCell()
	if cur_cell then
		cur_cell:SetSelect(true)
	end

	local cur_huanhua = FashionData.Instance:GetHadHuanhuaZhenQiData() or {}

	local cells = self.fashion_grid:GetAllCell()
	local zhenqi_data = FashionData.Instance:GetZhenqiData() or {}
	for index, cell in pairs(cells) do
		local data = cell:GetData()
		if type(data) == "table" then
			local cur_zhenqi = zhenqi_data[data.item_id]
			cell:MakeGray(nil == cur_zhenqi)
			if cur_huanhua.item_id == data.item_id then
				data.zhuan_level = 1
				cell:Flush()
			end

			self:FlushCellRemind(cell)
		end
	end
end

function FashionZhenQiView:FlushCellRemind(cell)
	local remind_num = RemindManager.Instance:GetRemind(RemindName.FashionZhenQi)
	if remind_num > 0 then
		local data = cell:GetData() or {}
		local item_id = data.item_id or 0
		local zhenqi_data = FashionData.Instance:GetZhenqiData() or {}
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local cur_zhenqi_data = zhenqi_data[item_id]
		local cur_zhenqi_lv = cur_zhenqi_data and cur_zhenqi_data.zhenqi_lv or 0
		local suit_id = item_cfg.suitId or 0
		local cfg = ImageUpgradeCfg or {}
		local cur_cfg = cfg[suit_id] or {}
		local consume = nil
		if nil == cur_zhenqi_data then
			consume = {id = item_id, count = 1}
		elseif (cur_zhenqi_lv + 1) <= #cur_cfg then
			local cur_consume = cur_cfg[cur_zhenqi_lv + 1] and cur_cfg[cur_zhenqi_lv + 1].consumes or {}
			consume = cur_consume[1]
		end

		local bool = false
		if consume then
			local have_num = BagData.Instance:GetItemNumInBagById(consume.id)
			bool = consume.count and have_num >= consume.count
		end
		cell:SetRemind(bool, nil, BaseCell.SIZE - 30, BaseCell.SIZE - 27)
	else
		cell:SetRemind(false)
	end
end

function FashionZhenQiView:CreateAttrList()
	local ph = self.ph_list["ph_attr_list"] or {x = 0, y = 0, w = 1, h = 1,}
	local ph_item = self.ph_list["ph_attr_item"] or {x = 0, y = 0, w = 1, h = 1,}
	local parent = self.node_t_list["layout_zhenqi"].node
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

function FashionZhenQiView:FlushAttrList()
	local attr_list = {}

	if type(self.select_data) == "table" then
		local item_cfg = ItemData.Instance:GetItemConfig(self.select_data.item_id)
		attr_list = ItemData.GetStaitcAttrs(item_cfg) or {}

		local suit_id = item_cfg.suitId or 0
		local cur_zhenqi_lv = self.cur_zhenqi_data and self.cur_zhenqi_data.zhenqi_lv or 0
		local cfg = ImageUpgradeCfg[suit_id] or {}
		local cur_cfg = cfg[cur_zhenqi_lv] or {}
		local attrs = cur_cfg.attrs or {}
		attr_list = CommonDataManager.AddAttr(attr_list, attrs) -- 增加真气等级属性
	end

	attr_list = RoleData.FormatRoleAttrStr(attr_list)

	self.attr_list:SetDataList(attr_list)
end

function FashionZhenQiView:FlushEffect(effect_id)
	local effect = self.effect
	local vis = true
	
	local frame_interval = nil -- 每帧间隔时间
	local loops = nil -- 播放数量
	if vis and nil == self.effect then
		local parent = self.node_t_list["layout_zhenqi"].node
		local ph = self.ph_list["ph_eff"] or {x = 0, y = 0, w = 10, h = 10}
		local zorder = 2
	
		effect = RenderUnit.CreateEffect(effect_id, parent, zorder, frame_interval, loops, ph.x, ph.y - 100)
	end
	
	if effect then
		effect:setVisible(vis)
		if vis then
			local path, name = ResPath.GetEffectUiAnimPath(effect_id)
			effect:setAnimate(path, name, loops or COMMON_CONSTS.MAX_LOOPS, frame_interval or FrameTime.Effect, false)
		end
	end
	
	self.effect = effect
end

----------end----------

function FashionZhenQiView:OnBtn()
	local bool = true
	local consume_cfg = nil
	if type(self.cur_zhenqi_data) == "table" then
		local cur_zhenqi_lv = self.cur_zhenqi_data.zhenqi_lv or 0
		local item_cfg = ItemData.Instance:GetItemConfig(self.cur_zhenqi_data.item_id) or {}
		local suit_id = item_cfg.suitId or 0
		local cfg = ImageUpgradeCfg or {}
		local cur_cfg = cfg[suit_id] or {}
		if (cur_zhenqi_lv + 1) <= #cur_cfg then
			local cur_consume = cur_cfg[cur_zhenqi_lv + 1] and cur_cfg[cur_zhenqi_lv + 1].consumes or {}
			local consume = ItemData.InitItemDataByCfg(cur_consume[1]) or {}
			consume_cfg = ItemData.Instance:GetItemConfig(consume.item_id) or {}
			local have_num = BagData.Instance:GetItemNumInBagById(consume_cfg.item_id)
			if consume.num and have_num >= consume.num then
				local series = self.cur_zhenqi_data and self.cur_zhenqi_data.series or 0
				FashionCtrl.SendZhenQiUpgrade(series)
				bool = false
			end
		else
			bool = false
			local str = "已达到最高阶"
			SysMsgCtrl.Instance:FloatingTopRightText(str)
		end
	else
		local item_id = self.select_data and self.select_data.item_id or 0
		local series_list = BagData.Instance:GetSeriesByItemId(item_id) or {}
		local series, item = next(series_list)
		if series then
			FashionCtrl.Instance:SendXingXiangGuan(series) --放入形象框的直接幻化
			FashionCtrl.Instance:SendHuanhuaEquipReq(series) --幻化
			bool = false
		else
			consume_cfg = ItemData.Instance:GetItemConfig(item_id) or {}
		end
	end

	-- 未请求激活或进阶,已满级除外
	if bool and type(consume_cfg) == "table" then
		local str = string.format("%s不足", consume_cfg.name or "材料")
		SysMsgCtrl.Instance:FloatingTopRightText(str)

		local item_id = consume_cfg.item_id
		TipCtrl.Instance:OpenGetStuffTip(item_id)
	end
end

function FashionZhenQiView:OnBtn2()
	if type(self.cur_zhenqi_data) == "table" then
		local cur_huanhua = FashionData.Instance:GetHadHuanhuaZhenQiData() or {}
		local series = self.cur_zhenqi_data.series or 0
		if cur_huanhua.series == series then
			FashionCtrl.Instance:SendCancelHuanHuaEquipReq(series) -- 取消幻化
		else
			FashionCtrl.Instance:SendHuanhuaEquipReq(series) -- 幻化
		end
	else
		local str = "请先激活"
		SysMsgCtrl.Instance:FloatingTopRightText(str)
	end
end

-- "?"按钮点击回调
function FashionZhenQiView:OnDesc()
	local language = Language or {}
	local desctip = Language.DescTip or {}
	local title = desctip.ZhenQiTitle or ""
	local desc = desctip.ZhenQiContent or ""

	DescTip.Instance:SetContent(desc, title)
end

function FashionZhenQiView:TabbarSelectCallBack(index)
	self.fashion_grid:ChangeToPage(index)
end

function FashionZhenQiView:OnSelectCell(cell)
	self.select_data = cell:GetData() or {}
	self.select_index = cell:GetIndex()
	self:Flush()
end

function FashionZhenQiView:OnBagItemChange(event)
	if self:IsOpen() then
		local need_flush = false
		for i, v in ipairs(event.GetChangeDataList()) do
			if v.change_type == ITEM_CHANGE_TYPE.LIST then
				need_flush = true
			else
				local item_data = v.data or {}
				if item_data.type == ItemData.ItemType.itGenuineQi then
					need_flush = true
				end
			end

			if need_flush then
				self:FlushFashionGrid()
				self:Flush()
				break
			end
		end
	end
end

function FashionZhenQiView:OnFashionChange()
	if self:IsOpen() then
		self:FlushFashionGrid()
		self:Flush()
	end
end

----------------------------------------
-- 属性文本
----------------------------------------

FashionZhenQiView.AttrTextRender = BaseClass(BaseRender)
local AttrTextRender = FashionZhenQiView.AttrTextRender
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
return FashionZhenQiView