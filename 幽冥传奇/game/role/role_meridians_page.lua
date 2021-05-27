--角色经脉页面
RoleMeridiansPage = RoleMeridiansPage or BaseClass()


function RoleMeridiansPage:__init()
	self.view = nil
end	

function RoleMeridiansPage:__delete()

	self:RemoveEvent()
	self.view = nil
	if self.cur_attr_list then
		self.cur_attr_list:DeleteMe()
		self.cur_attr_list = nil
	end
	if self.attr_list then
		self.attr_list:DeleteMe()
		self.attr_list = nil
	end

	ClientCommonButtonDic[CommonButtonType.ROLE_MERIDIAN_ACTIVATE_BTN] = nil
end	

--初始化页面接口
function RoleMeridiansPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:InitEvent()
	self:CreteBeadList()
	self:CreateCurAttrList()
	self:CreateAttrList()
	XUI.AddClickEventListener(self.view.node_t_list.btn_left.node, BindTool.Bind(self.OnMoveLeftHandler, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_right.node, BindTool.Bind(self.OnMoveRightHandler, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_jihuo.node, BindTool.Bind2(self.UpLvClicked, self))
	XUI.AddClickEventListener(self.view.node_t_list.helpBtn.node, BindTool.Bind2(self.OnHelp, self))
	self.view.node_t_list.btn_left.node:setVisible(false)
	self.cur_index = 1
	RoleData.Instance:SetCurPageIndex(self.cur_index)
	self.view.node_t_list.layout_meridians_tips.node:setVisible(false)

	ClientCommonButtonDic[CommonButtonType.ROLE_MERIDIAN_ACTIVATE_BTN] = self.view.node_t_list.btn_jihuo.node
end	

--初始化事件
function RoleMeridiansPage:InitEvent()
	self.role_data_event = BindTool.Bind(self.RoleDataChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)

end

--移除事件
function RoleMeridiansPage:RemoveEvent()
	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end	
end
--更新视图界面
function RoleMeridiansPage:UpdateData(data)
	self:FlushInfo()
	self:FlushGridData()
	local meridian_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERIDIAND_LEVEL)
	local step, star = RoleData.GetMeridianStepStar(meridian_lv+1)
	self.grid_list:ChangeToPage(step+1)
end	

function RoleMeridiansPage:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.ACTOR_MERIDIAND_LEVEL then
		self:FlushInfo()
		self:FlushGridData()
	end
end	

function RoleMeridiansPage:FlushInfo()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
	local meridian_soul= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERIDIAN_SOUL) --经脉修为
	self.view.node_t_list.xiuwei_value.node:setString(meridian_soul)
	-- local coin = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN)
	-- self.view.node_t_list.money_value.node:setString(coin)
	local meridian_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERIDIAND_LEVEL)
	local info = RoleData.GetMeridianConfig(meridian_lv)
	local step_1, star_1 = RoleData.GetMeridianStepStar(meridian_lv+1)
	if RoleData.Instance:GetCurpageIndex() < step_1+1 then
		XUI.SetButtonEnabled(self.view.node_t_list.btn_right.node, true)
		self.view.node_t_list.btn_jihuo.node:setVisible(false)
		self.view.node_t_list.txt_jihuo.node:setVisible(false)
	else
		XUI.SetButtonEnabled(self.view.node_t_list.btn_right.node, false)
		self.view.node_t_list.btn_jihuo.node:setVisible(true)
		self.view.node_t_list.txt_jihuo.node:setVisible(true)
	end
	-- local step, star = RoleData.GetMeridianStepStar(meridian_lv+2)
	-- if step > 19 then
	-- 	-- local ph = self.view.ph_list.ph_img_meridian_lv
	-- 	-- self.view.node_t_list.img_meridian_lv.node:setPosition(ph.x, ph.y)
	-- 	self.grid_list:ExtendGrid(step)
	-- else
	-- 	self.grid_list:ExtendGrid(step+1)
	-- end
	self.view.node_t_list.img_meridian_lv.node:loadTexture(ResPath.GetRole("step_" .. self.cur_index))
	self.view.node_t_list.btn_right.node:setVisible(self.cur_index < 20)
	local meridian_consume_cfg = RoleData.GetMeridianConsumeCfgByLv(meridian_lv+1)
	if meridian_consume_cfg then
		local step, star = RoleData.GetMeridianStepStar(meridian_lv+1)
		-- local ph = self.view.ph_list["ph_cosume_" .. star]
		self.view.node_t_list.layout_cosume.node:setVisible((step+1) == self.cur_index)
		-- if ph then
		-- 	self.view.node_t_list.layout_cosume.node:setPosition(ph.x, ph.y)
		-- end
		if meridian_soul >= meridian_consume_cfg.consumes[1].count then
			RichTextUtil.ParseRichText(self.view.node_t_list.layout_cosume.txt_xiuwei.node, meridian_consume_cfg.consumes[1].count, 20, COLOR3B.GREEN)
		else	
			RichTextUtil.ParseRichText(self.view.node_t_list.layout_cosume.txt_xiuwei.node, meridian_consume_cfg.consumes[1].count, 20, COLOR3B.RED)
		end
	else 
		self.view.node_t_list.layout_cosume.node:setVisible(false)
	end		
	-- self.grid_list:SetDataList(info)

	
	-- local nxt_add_attr_str_t = RoleData.GetMeridianAddAttrByLv(meridian_lv)
	-- self.cur_attr_list:SetDataList(nxt_add_attr_str_t)
end

function RoleMeridiansPage:FlushGridData()
	local meridian_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERIDIAND_LEVEL)
	local info = RoleData.GetMeridianConfig(meridian_lv)
	local step, star = RoleData.GetMeridianStepStar(meridian_lv+2)
	if step > 19 then
		self.grid_list:ExtendGrid(step)
	else
		self.grid_list:ExtendGrid(step+1)
	end
	self.grid_list:SetDataList(info)
	
	local nxt_add_attr_str_t = RoleData.GetMeridianAddAttrByLv(meridian_lv)
	self.cur_attr_list:SetDataList(nxt_add_attr_str_t)
end

function RoleMeridiansPage:CreteBeadList()
	local ph = self.view.ph_list.ph_list_meridian
	self.grid_list = BaseGrid.New()
	local grid_node = self.grid_list:CreateCells({w = ph.w, h = ph.h, cell_count = 1, col = 1, row = 1, itemRender = MeridianBeadItem, direction = ScrollDir.Horizontal, ui_config = self.view.ph_list.ph_meridian_item})
	grid_node:setPosition(ph.x-19, ph.y-41)
	grid_node:setAnchorPoint(0.0, 0.0)
	grid_node:setTouchEnabled(false)
	self.view.node_t_list.layout_meridians.node:addChild(grid_node, 1)
	self.cur_index = self.grid_list:GetCurPageIndex()
	self.max_page_idx = 20--self.grid_list:GetPageCount()
	self.grid_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))

end

function RoleMeridiansPage:OnPageChangeCallBack(grid, page_index, prve_page_index)
	self.cur_index = page_index
	RoleData.Instance:SetCurPageIndex(self.cur_index)
	local meridian_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERIDIAND_LEVEL)
	local step, star = RoleData.GetMeridianStepStar(meridian_lv+1)
	self:FlushBtns()
	self:FlushInfo()
	local cur_item = self.grid_list:GetCell(page_index - 1)
	if cur_item and cur_item.beads_list then
		RoleCtrl.Instance:OpenShowRewardView(star, cur_item.beads_list[star], is_click)
	end	
end

function RoleMeridiansPage:OnMoveLeftHandler()
	if self.cur_index > 1 then
		self.cur_index = self.cur_index - 1
		self.grid_list:ChangeToPage(self.cur_index)
		RoleData.Instance:SetCurPageIndex(self.cur_index)
	end
end

function RoleMeridiansPage:OnMoveRightHandler()
	if self.cur_index < self.max_page_idx then
		self.cur_index = self.cur_index + 1
		self.grid_list:ChangeToPage(self.cur_index)
		RoleData.Instance:SetCurPageIndex(self.cur_index)
	end
end

function RoleMeridiansPage:FlushBtns()
	self.view.node_t_list.btn_left.node:setVisible(self.cur_index ~= 1)
	self.view.node_t_list.btn_right.node:setVisible(self.cur_index ~= self.max_page_idx)
end


function RoleMeridiansPage:CreateCurAttrList()
	self.cur_attr_list = ListView.New()
	local ph = self.view.ph_list.ph_shuxing_list
	self.cur_attr_list:Create(ph.x, ph.y, ph.w, ph.h, nil, MeridianAttrRender, nil, nil, self.view.ph_list.ph_shuxing_item)
	self.view.node_t_list.layout_meridians.node:addChild(self.cur_attr_list:GetView(), 100, 100)
	-- self.cur_attr_list:GetView():setAnchorPoint(0,0)
	self.cur_attr_list:SetItemsInterval(8)
	self.cur_attr_list:SetMargin(5)
	self.cur_attr_list:JumpToTop(true)
end

function RoleMeridiansPage:UpLvClicked()
	local meri_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERIDIAND_LEVEL) + 1
	RoleCtrl.Instance:SendMerdian(meri_lv)
	local meridian_soul= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERIDIAN_SOUL) --经脉修为
	local meridian_consume_cfg = RoleData.GetMeridianConsumeCfgByLv(meri_lv)
	if meridian_consume_cfg then
		if meridian_soul >= meridian_consume_cfg.consumes[1].count then
			local step, star = RoleData.GetMeridianStepStar(meri_lv+1)
			local end_step = step + 1
			self.grid_list:ChangeToPage(end_step)
		end	
	end	
end

function RoleMeridiansPage:OnHelp()
	DescTip.Instance:SetContent(Language.Role.MeridianDesc,Language.Role.MeridianDescTitle)
end


function RoleMeridiansPage:CreateAttrList()
	self.attr_list = ListView.New()
	local ph = self.view.ph_list.ph_meridian_info_list
	self.attr_list:Create(ph.x, ph.y, ph.w, ph.h, nil, MeriAttrRender, nil, nil, self.view.ph_list.ph_meridian_info_item)
	self.view.node_t_list.layout_meridians_tips.node:addChild(self.attr_list:GetView(), 100, 100)
	-- self.attr_list:GetView():setAnchorPoint(0,0)
	self.attr_list:SetItemsInterval(8)
	self.attr_list:SetMargin(5)
	self.attr_list:JumpToTop(true)
end

function RoleMeridiansPage:SetData(index, cur_view, is_click)
	self.bead_index = index
	self.cur_bead = cur_view
	-- self.is_click = is_click
	self:FlushSmallPanel(is_click)
end

function RoleMeridiansPage:FlushSmallPanel(is_click)
	if not is_click then
		local meridian_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERIDIAND_LEVEL)
		local step, star = RoleData.GetMeridianStepStar(meridian_lv+1)
		if step+1 == self.cur_index then
			self.view.node_t_list.layout_meridians_tips.node:setVisible(true)
		else	
			self.view.node_t_list.layout_meridians_tips.node:setVisible(false)
		end
	else	
		self.view.node_t_list.layout_meridians_tips.node:setVisible(true)
	end
	local cur_index = self.cur_index -- RoleData.Instance:GetCurpageIndex()
	if self.cur_bead then
		local ph = self.view.ph_list["ph_cosume_" .. self.bead_index]
		if ph then
			self.view.node_t_list.layout_meridians_tips.node:setPosition(ph.x, ph.y - 50)
		end
	end
	if self.bead_index then
		local end_index = (cur_index - 1) * 9 +self.bead_index
		local attr = RoleData.GetMeridianAttrCfgByLv(end_index)
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		end_attr = CommonDataManager.DelAttrByProf(prof, attr)
		attr_str = RoleData.FormatRoleAttrStr(end_attr, is_range, item_cfg, out_prof)
		
		self.attr_list:SetDataList(attr_str)
		local meridian_consume_cfg = RoleData.GetMeridianConsumeCfgByLv(end_index)
		self.view.node_t_list.layout_meridians_tips.txt_index_name.node:setString(meridian_consume_cfg.name)
	end
end

MeriAttrRender = MeriAttrRender or BaseClass(BaseRender)
function MeriAttrRender:__init()
end

function MeriAttrRender:__delete()
end

function MeriAttrRender:CreateChild()
	BaseRender.CreateChild(self)
end
function MeriAttrRender:OnFlush()
	if not self.data then return end
		local type_str = self.data.type_str
		local value_str = self.data.value_str
		self.node_tree.meridian_shuxing_value.node:setString(value_str)
		self.node_tree.meridian_shuxing_name.node:setString(type_str.."：")
end
function MeriAttrRender:CreateSelectEffect() 
end

MeridianBeadItem = MeridianBeadItem or BaseClass(BaseRender)
function MeridianBeadItem:__init()
end

function MeridianBeadItem:__delete()
	
end

function MeridianBeadItem:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateLine()
	self:CreateBeads()
	self:CreateLingtRow()
end

function MeridianBeadItem:CreateBeads()
	self.beads_list = {}
	for i = 1, 9 do
		local ph = self.ph_list["ph_img_bead_" .. i]
		if i == 9 then
		    bead_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_bead_1"), true)
		else
			bead_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_bead_2"), true)
		end	
		self.view:addChild(bead_img, 20)
		self.beads_list[i] = bead_img
		bead_img:setPropagateTouchEvent(false)
		XUI.AddClickEventListener(bead_img, BindTool.Bind(self.OnClickShuXing, self, i, true), true)
	end
end
function MeridianBeadItem:CreateLingtRow()
	self.lingtrows_list = {}
	for i = 1, 9 do
		local ph = self.ph_list["ph_img_lightrow_" .. i]
		if i == 9 then
		    lingtrow_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_bead_3"), true)
		else
			lingtrow_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_bead_4"), true)
		end	
		self.view:addChild(lingtrow_img, 20)
		self.lingtrows_list[i] = lingtrow_img
	end
end
function MeridianBeadItem:CreateLine()
	self.lines_list = {}
	for i = 1, 8 do
		local ph = self.ph_list["ph_img_line_" .. i]
		if i == 1 then
		    line_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_line_1"), true)
		elseif i == 2 then
			line_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_line_2"), true)
		elseif i == 3 then
			line_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_line_3"), true)
		elseif i == 4 then
			line_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_line_4"), true)
		elseif i == 5 then
			line_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_line_5"), true)
		elseif i == 6 then
			line_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_line_6"), true)
		elseif i == 7 then
			line_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_line_7"), true)
		else
			line_img = XUI.CreateImageView(ph.x, ph.y, ResPath.GetRole("meridians_line_8"), true)
		end	
		self.view:addChild(line_img, 20)
		self.lines_list[i] = line_img
	end
end


function MeridianBeadItem:OnClickShuXing(index, is_click)
	RoleCtrl.Instance:OpenShowRewardView(index, self.beads_list[index], is_click)
end


function MeridianBeadItem:OnFlush()
	if nil == self.data then return end
	local meridian_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_MERIDIAND_LEVEL)
	local step, star = RoleData.GetMeridianStepStar(meridian_lv)
	local step_1, star_1 = RoleData.GetMeridianStepStar(meridian_lv+1)
	self:OnClickShuXing(star_1)
	for i, v in ipairs(self.beads_list) do
		if step > self.index then
			v:setGrey(false)
		elseif step == self.index then
			if i <= star then
				v:setGrey(false)
			else
				v:setGrey(true)
			end
		else	
			v:setGrey(true)
		end
	end
	for i, v in ipairs(self.lingtrows_list) do
		if step > self.index then
			v:setGrey(false)
		elseif step == self.index then
			if i <= star then
				v:setGrey(false)
			else
				v:setGrey(true)
			end
		else	
			v:setGrey(true)
		end
	end
	for i, v in ipairs(self.lines_list) do
		if step > self.index then
			v:setGrey(false)
		elseif step == self.index then
			if i <= star then
				v:setGrey(false)
			else
				v:setGrey(true)
			end
		else	
			v:setGrey(true)
		end	
	end
end

function MeridianBeadItem:CreateSelectEffect()

end

MeridianAttrRender = MeridianAttrRender or BaseClass(BaseRender)
function MeridianAttrRender:__init()
end

function MeridianAttrRender:__delete()
end

function MeridianAttrRender:CreateChild()
	BaseRender.CreateChild(self)
end


function MeridianAttrRender:OnFlush()
	if not self.data then return end
		local type_str = self.data.type_str
		local value_str = self.data.value_str
		self.node_tree.shuxing_value.node:setString(value_str)
		self.node_tree.shuxing_name.node:setString(type_str)
end
function MeridianAttrRender:CreateSelectEffect() 
end