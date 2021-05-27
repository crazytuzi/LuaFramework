------------------------------------------------------------
--人物技能View.升级选择相关
------------------------------------------------------------
local SelectSkillView = BaseClass(SubView)

function SelectSkillView:__init()
	self.texture_path_list = {
		-- 'res/xui/equipbg.png',
		'res/xui/role.png',
	}
	self.config_tab = {
		{"skill_ui_cfg", 2, {0}},
		{"skill_ui_cfg", 3, {0}},
	}
end

function SelectSkillView:__delete()
end

function SelectSkillView:LoadCallBack()
	self:UpdateSelectSkillView()
	self.show_skill_List = {}
	self:CreateShowSkillList()

	-- self.node_t_list.btn_skill_return.node:addClickEventListener(BindTool.Bind(self.OnToSkillView, self))
	self.node_t_list.btn_skill_select.node:addClickEventListener(BindTool.Bind(self.ClickToSelectSkill, self))
	self.node_t_list.btn_skill_bag.node:addClickEventListener(BindTool.Bind(self.ClickToSelectBag, self))
	self.node_t_list.btn_skill_clearset.node:addClickEventListener(BindTool.Bind(self.ClickSkillClear, self))

	-- XUI.RichTextSetCenter(self.node_t_list.rich_skill_select_tips.node)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_skill_select_tips.node, Language.Role.SelectSkillTips, 24, COLOR3B.OLIVE)
	self:BindGlobalEvent(SettingEventType.SKILL_BAR_CHANGE, BindTool.Bind(self.SkillBarChangeCallBack, self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(SkillData.Instance, self):AddEventListener(SkillData.SKILL_DATA_CHANGE, function ()
		self.node_t_list.img_skill_1.node:setGrey(nil == SkillData.Instance:GetSkill(122))
		self.node_t_list.img_skill_2.node:setGrey(nil == SkillData.Instance:GetSkill(123))
	end)
end

function SelectSkillView:ReleaseCallBack()
	if self.show_skill_List then
		for k,v in pairs(self.show_skill_List) do
			v:DeleteMe()
		end
		self.show_skill_List = {}
	end
	if self.skill_select_bag_grid then
		self.skill_select_bag_grid:DeleteMe()
		self.skill_select_bag_grid = nil
	end
	if self.skill_select_skill_list then
		self.skill_select_skill_list:DeleteMe()
		self.skill_select_skill_list = nil
	end
end

function SelectSkillView:ShowIndexCallBack()
	self:Flush()	
	self.node_t_list.img_skill_1.node:setGrey(nil == SkillData.Instance:GetSkill(122))
	self.node_t_list.img_skill_2.node:setGrey(nil == SkillData.Instance:GetSkill(123))			
end

function SelectSkillView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			if self.skill_select_skill_list then
				local act_skill_list = SkillData.Instance:GetAllCanSetSkillList(true)
				self.skill_select_skill_list:SetDataList(act_skill_list)
			end
		elseif k == "show_skill" then
			for k1,v1 in pairs(self.show_skill_List) do
				v1:SetData(SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. k1]))
			end
		elseif k == "itemdata_list_change" then
			if self.skill_select_bag_grid then
				self.skill_select_bag_grid:SetDataList(SkillData.Instance:GetSkillBarItemList())
			end
		end
	end

end

function SelectSkillView:OnBagItemChange()
	self:Flush(0, "itemdata_list_change")
end

function SelectSkillView:SkillBarChangeCallBack()
	self:Flush(0, "show_skill")
end

function SelectSkillView:CreateShowSkillList()
	local ph = self.ph_list.ph_show_skill
	local radius = 150
	local angle = 360 / SKILL_BAR_COUNT
	for i = 1, SKILL_BAR_COUNT do
		local child = ShowSkillItem.New()
		child.index = i
		table.insert(self.show_skill_List, child)
		child:SetUiConfig(ph, true)
		local rad = (90 + angle * (i - 1)) / 180 * math.pi
		local x = (radius * math.cos(rad)) + ph.x
		local y = radius * math.sin(rad) + ph.y
		self.node_t_list.layout_show_skill.node:addChild(child:GetView(), 100, 100)
		child.view:setPosition(x, y)
		child:SetData(SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. i]))
	end
end

function SelectSkillView:ClickToSelectSkill()
	self.is_on_select_bag = false
	self:UpdateSelectSkillView()
end

function SelectSkillView:ClickToSelectBag()
	self.is_on_select_bag = true
	self:UpdateSelectSkillView()
end

function SelectSkillView:ClickSkillClear()
	for i = 1, SKILL_BAR_COUNT do
		SettingCtrl.Instance:SetOneShowSkill(nil, HOT_KEY["SKILL_BAR_" .. i])
	end
end

function SelectSkillView:UpdateSelectSkillView()
	if self.is_on_select_bag then
		if nil == self.skill_select_bag_grid then
			self.skill_select_bag_grid = BaseGrid.New()
			self.skill_select_bag_grid:SetGridName(GRID_TYPE_BAG)
			local ph_baggrid = self.ph_list.ph_skill_select_list
			local grid_node = self.skill_select_bag_grid:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count=16, col=4, row=4, itemRender = SkillBagCell})
			self.node_t_list.layout_skill_select.node:addChild(grid_node, 100)
			grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
			self.skill_select_bag_grid:SetIsShowTips(false)
			self.skill_select_bag_grid:SetDataList(SkillData.Instance:GetSkillBarItemList())
		else
			self.skill_select_bag_grid:GetView():setVisible(true)
		end
		if self.skill_select_skill_list then
			self.skill_select_skill_list:GetView():setVisible(false)
		end
	else
		if nil == self.skill_select_skill_list then
			local ph = self.ph_list.ph_skill_select_list
			self.skill_select_skill_list = GridScroll.New()
			self.skill_select_skill_list:Create(ph.x, ph.y, ph.w, ph.h, 3, 130, CanSelectSkillItem, nil, nil, self.ph_list.ph_canselect_skill)
			self.node_t_list.layout_skill_select.node:addChild(self.skill_select_skill_list:GetView(), 1)
			self.skill_select_skill_list:GetView():setAnchorPoint(0, 0)
			local act_skill_list = SkillData.Instance:GetAllCanSetSkillList(true)
			self.skill_select_skill_list:SetDataList(act_skill_list)
		else
			self.skill_select_skill_list:GetView():setVisible(true)
		end
		if self.skill_select_bag_grid then
			self.skill_select_bag_grid:GetView():setVisible(false)
		end
	end
end

function SelectSkillView:OnToSkillView()
	ViewManager.Instance:OpenViewByDef(ViewDef.Role.Skill)
end

----------------------------------------------------------------------------------------------------
-- 选择技能item
----------------------------------------------------------------------------------------------------
CanSelectSkillItem = CanSelectSkillItem or BaseClass(BaseRender)
function CanSelectSkillItem:__init()
	
end

function CanSelectSkillItem:__delete()
	if self.ui_drag then
		self.ui_drag:DeleteMe()
		self.ui_drag = nil
	end
end

function CanSelectSkillItem:CreateChild()
	BaseRender.CreateChild(self)
end

function CanSelectSkillItem:OnFlush()
	local server_cfg = SkillData.GetSkillCfg(self.data.skill_id)
	if nil == server_cfg then return end
	-- self.node_tree.lbl_skill_name.node:setString(server_cfg.name)
	self.node_tree.img_skill_name.node:loadTexture(ResPath.GetRole(self.data.skill_id))
	if nil == self.cur_skill then
		local ph = self.ph_list.ph_cur_skill
		self.cur_skill = XUI.CreateImageView(ph.x, ph.y, ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.skill_id)))
		self.view:addChild(self.cur_skill, 10)
		self.node_tree.img_skill_light.node:setLocalZOrder(11)
		self.cur_skill:setScale(0.7)
		self:SetUiDrag()
		self.cur_skill:setPropagateTouchEvent(false)
	else
		self.cur_skill:loadTexture(ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.skill_id)))
	end

	self.cur_skill:setGrey(nil == SkillData.Instance:GetSkill(self.data.skill_id))
	self.cur_skill:setTouchEnabled(nil ~= SkillData.Instance:GetSkill(self.data.skill_id))
end

-- 创建选中特效
function CanSelectSkillItem:CreateSelectEffect()
	
end

function CanSelectSkillItem:SetUiDrag()
	if self.ui_drag == nil then
		self.ui_drag = UiDrag.New()
	end

	self.ui_drag:SetUi(self.cur_skill, self.data, "select_skill")

	function touch_began()
		if self.data ~= nil then
			local path = ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.skill_id))
			return XImage:create(path)
		end
		return nil
	end
	self.ui_drag:BindTouchBegan(touch_began)
end

----------------------------------------------------------------------------------------------------
-- 展示技能item
----------------------------------------------------------------------------------------------------
ShowSkillItem = ShowSkillItem or BaseClass(BaseRender)
function ShowSkillItem:__init()
	
end

function ShowSkillItem:__delete()
	if self.ui_drag then
		self.ui_drag:DeleteMe()
		self.ui_drag = nil
	end
end

function ShowSkillItem:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_cur_skill
	self.cur_skill = XUI.CreateImageView(ph.x, ph.y, ResPath.GetSkillIcon(1))
	self.view:addChild(self.cur_skill, 10)
	self.node_tree.img_skill_light.node:setLocalZOrder(11)
	self.cur_skill:setScale(0.8)
	self.cur_skill:setVisible(false)
	self:SetUiDrag()
end

function ShowSkillItem:OnFlush()
	self.cur_skill:setVisible(nil ~= self.data)
	if self.data then
		local path = ""
		if self.data.type == SKILL_BAR_TYPE.ITEM then
			local item_cfg = ItemData.Instance:GetItemConfig(self.data.id)
			if item_cfg then
				path = ResPath.GetItem(item_cfg.icon)
			else
				return
			end
			self.cur_skill:setScale(0.8)
		elseif self.data.type == SKILL_BAR_TYPE.SKILL then
			path = ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.id))
			self.cur_skill:setScale(0.68)
		end
		self.cur_skill:loadTexture(path)
	end
	self:SetUiDrag()
end

-- 创建选中特效
function ShowSkillItem:CreateSelectEffect()
	
end

function ShowSkillItem:SetUiDrag()
	if self.ui_drag == nil then
		self.ui_drag = UiDrag.New()
	end
	self.ui_drag:SetUi(self.cur_skill, self.data, "show_skill", false)

	function touch_began()
		if self.data ~= nil then
			local path = ""
			if self.data.type == SKILL_BAR_TYPE.ITEM then
				local item_cfg = ItemData.Instance:GetItemConfig(self.data.id)
				if item_cfg then
					path = ResPath.GetItem(item_cfg.icon)
				else
					return nil
				end
			elseif self.data.type == SKILL_BAR_TYPE.SKILL then
				path = ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(self.data.id))
			end
			return XImage:create(path)
		end
		return nil
	end

	function drag_complete(hit_ui, hit_source, hit_area_name, is_week_drag)
		if self.drag_end_callback then
			self.drag_end_callback(self)
		end
		if self.to_other_area then return end
		if hit_ui ==nil then
			if not is_week_drag then
				SettingCtrl.Instance:SetOneShowSkill(nil, HOT_KEY["SKILL_BAR_" .. self.index])
			end
		elseif hit_ui ~= nil and hit_source == nil then --移动数据
			SettingCtrl.Instance:SetOneShowSkill(nil, HOT_KEY["SKILL_BAR_" .. self.index])
		elseif hit_ui ~= nil and hit_source ~= nil then --交换数据
			SettingCtrl.Instance:SetOneShowSkill(hit_source, HOT_KEY["SKILL_BAR_" .. self.index])
		end
	end

	function onhit(hitter, hitter_source, from_area_name, touch_pos)
		if (from_area_name == "select_skill" or from_area_name == "skill_bag" or from_area_name == "show_skill") and hitter_source then
			SettingCtrl.Instance:SetOneShowSkill(hitter_source, HOT_KEY["SKILL_BAR_" .. self.index])
		end
	end
	self.ui_drag:BindTouchBegan(touch_began)
	self.ui_drag:BindDragComplete(drag_complete)
	self.ui_drag:BindOnHit(onhit)
end

SkillBagCell = SkillBagCell or BaseClass(BaseCell)

function SkillBagCell:__init()
	
end

function SkillBagCell:__delete()
	if self.ui_drag then
		self.ui_drag:DeleteMe()
		self.ui_drag = nil
	end
end

function SkillBagCell:Flush()
	BaseCell.Flush(self)
	self:SetUiDrag()
end

function SkillBagCell:SetUiDrag()
	if self.ui_drag == nil then
		self.ui_drag = UiDrag.New()
	end

	self.ui_drag:SetUi(self.view, self.data, "skill_bag")

	function touch_began()
		if self.data ~= nil then
			if self.drag_began_callback then
				self.drag_began_callback(self)
			end
			-- if self.to_other_area then return end
			local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
			if item_cfg ~= nil then
				local path = ResPath.GetItem(item_cfg.icon)
				return XImage:create(path)
			end
		end
		return nil
	end
	self.ui_drag:BindTouchBegan(touch_began)
end

return SelectSkillView