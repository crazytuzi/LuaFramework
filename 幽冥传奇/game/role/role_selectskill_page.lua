--角色技能选择页面
RoleSkillSelectPage = RoleSkillSelectPage or BaseClass()


function RoleSkillSelectPage:__init()
	self.view = nil
	self.skill_index = 1
end	

function RoleSkillSelectPage:__delete()

	self:RemoveEvent()
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

	if self.tabbar_skill then
		self.tabbar_skill:DeleteMe()
		self.tabbar_skill = nil 
	end
	self.view = nil
end	

--初始化页面接口
function RoleSkillSelectPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitSkillTabbar()
	self:UpdateSelectSkillView()
	self.show_skill_List = {}
	self:CreateShowSkillList()
	self.skill_select_bag_grid:GetView():setVisible(false)
	self.view.node_t_list.btn_skill_return.node:addClickEventListener(BindTool.Bind1(self.OnToSkillView, self))
	self.view.node_t_list.btn_skill_select.node:setVisible(false)
	self.view.node_t_list.btn_skill_bag.node:setVisible(false)
	self.view.node_t_list.btn_skill_select.node:addClickEventListener(BindTool.Bind1(self.ClickToSelectSkill, self))
	self.view.node_t_list.btn_skill_bag.node:addClickEventListener(BindTool.Bind1(self.ClickToSelectBag, self))
	self.view.node_t_list.btn_skill_clearset.node:addClickEventListener(BindTool.Bind1(self.ClickSkillClear, self))
	XUI.RichTextSetCenter(self.view.node_t_list.rich_skill_select_tips.node)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_skill_select_tips.node, Language.Role.SelectSkillTips, 24, COLOR3B.OLIVE)
	self:InitEvent()
	
end	

--初始化事件
function RoleSkillSelectPage:InitEvent()
	
	self.item_list_event = BindTool.Bind1(self.ItemDataListChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event, true)

	self.skill_bar_event = GlobalEventSystem:Bind(SettingEventType.SKILL_BAR_CHANGE, BindTool.Bind1(self.SkillBarChangeCallBack, self))
end

--移除事件
function RoleSkillSelectPage:RemoveEvent()
	if self.item_list_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_list_event)
		self.item_list_event = nil
	end

	if self.skill_bar_event then
		GlobalEventSystem:UnBind(self.skill_bar_event)
		self.skill_bar_event = nil
	end	
end

--更新视图界面
function RoleSkillSelectPage:UpdateData(data)
	for k,v in pairs(data) do
		if k == "all" then
			if self.skill_select_skill_list then
				local act_skill_list = SkillData.Instance:GetActSkillList()
				self.skill_select_skill_list:SetDataList(act_skill_list)
			end
		end
	end
end	

function RoleSkillSelectPage:SkillBarChangeCallBack()
	for k1,v1 in pairs(self.show_skill_List) do
		v1:SetData(SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. k1]))
	end
end

function RoleSkillSelectPage:ItemDataListChangeCallback()
	if self.skill_select_bag_grid then
		self.skill_select_bag_grid:SetDataList(SkillData.Instance:GetSkillBarItemList())
	end
end



function RoleSkillSelectPage:CreateShowSkillList()
	local ph = self.view.ph_list.ph_show_skill
	local radius = 160
	local angle = 360 / SKILL_BAR_COUNT
	for i = 1, SKILL_BAR_COUNT do
		local child = ShowSkillItem.New()
		child.index = i
		table.insert(self.show_skill_List, child)
		child:SetUiConfig(ph, true)
		local rad = (90 + angle * (i - 1)) / 180 * math.pi
		local x = (radius * math.cos(rad)) + ph.x
		local y = radius * math.sin(rad) + ph.y
		self.view.node_t_list.layout_show_skill.node:addChild(child:GetView(), 100, 100)
		child.view:setPosition(x, y)
		child:SetData(SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. i]))
	end


	-- local child = ShowYaoItem.New()
	-- child:SetUiConfig(ph, true)
	-- child.view:setPosition(ph.x, ph.y)
	-- self.view.node_t_list.layout_show_skill.node:addChild(child:GetView(), 100, 100)
	-- table.insert(self.show_skill_List, child)
	-- child.index = #self.show_skill_List
	-- child:SetData(SettingData.Instance:GetOneShowSkill(HOT_KEY["SKILL_BAR_" .. #self.show_skill_List]))
	
end

function RoleSkillSelectPage:InitSkillTabbar()
	if self.tabbar_skill ~= nil then return end
	self.tabbar_skill = Tabbar.New()
	self.tabbar_skill:CreateWithNameList(self.view.node_t_list["layout_skill_select"].node, 3, 555,
		BindTool.Bind1(self.SelectSkillCallback, self), 
		Language.Role.TabGroup3, false, ResPath.GetCommon("toggle_104_normal"))
	self.tabbar_skill:SetSpaceInterval(5)
end

function RoleSkillSelectPage:SelectSkillCallback(index)
	self.skill_index = index
	self:FlushSkillTabble()
end

function RoleSkillSelectPage:ClickToSelectSkill()
	self.is_on_select_bag = false
	self:UpdateSelectSkillView()
end

function RoleSkillSelectPage:ClickToSelectBag()
	self.is_on_select_bag = true
	self:UpdateSelectSkillView()
end

function RoleSkillSelectPage:ClickSkillClear()
	for i = 1, SKILL_BAR_COUNT do
		SettingCtrl.Instance:SetOneShowSkill(nil, HOT_KEY["SKILL_BAR_" .. i])
	end
end

function RoleSkillSelectPage:UpdateSelectSkillView()
	if nil == self.skill_select_bag_grid then
		self.skill_select_bag_grid = BaseGrid.New()
		self.skill_select_bag_grid:SetGridName(GRID_TYPE_BAG)
		local ph_baggrid = self.view.ph_list.ph_skill_select_list
		local grid_node = self.skill_select_bag_grid:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count=25, col=5, row=5, itemRender = SkillBagCell})
		self.view.node_t_list.layout_skill_select.node:addChild(grid_node, 100)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.skill_select_bag_grid:SetIsShowTips(false)
		self.skill_select_bag_grid:SetDataList(SkillData.Instance:GetSkillBarItemList())
	end

	if nil == self.skill_select_skill_list then
		local ph = self.view.ph_list.ph_skill_select_list
		self.skill_select_skill_list = GridScroll.New()
		self.skill_select_skill_list:Create(ph.x, ph.y, ph.w, ph.h, 3, 130, CanSelectSkillItem, nil, nil, self.view.ph_list.ph_canselect_skill)
		self.view.node_t_list.layout_skill_select.node:addChild(self.skill_select_skill_list:GetView(), 100)
		self.skill_select_skill_list:GetView():setAnchorPoint(0.0, 0.0)
	end
end

function RoleSkillSelectPage:FlushSkillTabble()
	if self.skill_index == 2 then
		self.skill_select_bag_grid:GetView():setVisible(true)
		self.skill_select_skill_list:GetView():setVisible(false)
	else
		self.skill_select_skill_list:GetView():setVisible(true)
		self.skill_select_bag_grid:GetView():setVisible(false)
	end
end

function RoleSkillSelectPage:OnToSkillView()
	self.view:ChangeToIndex(TabIndex.role_skill)
end
