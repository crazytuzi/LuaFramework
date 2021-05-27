--血符页面
ComposeGodArmPage = ComposeGodArmPage or BaseClass()


function ComposeGodArmPage:__init()
	self.view = nil
	self.page = nil
	self.upLevelBtn = nil
	self.lookBtn = nil
	self.helpBtn = nil
end	

function ComposeGodArmPage:__delete()
	-- ClientCommonButtonDic[CommonButtonType.COMPOSE_XF_ACTIVATE_BTN] = nil
	self:RemoveEvent()
	if nil ~= self.god_arm_show_list then
		self.god_arm_show_list:DeleteMe()
		self.god_arm_show_list = nil
	end
	if self.big_arm_effec then	
		self.big_arm_effec:setStop()
		self.big_arm_effec = nil
	end

	self.page = nil
	self.view = nil
	self.equipIndex = 1
	self.old_index = 1
	self.cur_data = nil
	self.innerContainer = nil
end	

--初始化页面接口
function ComposeGodArmPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.page = view.node_t_list.layout_god_arm
	-- self.actionDir = 1
	self.equipIndex = 1
	self.old_index = 1
	self.cur_data = nil
	self.txt_god_arm_des_1 = self.view.node_t_list.txt_god_arm_des_1.node
	self.btn_god_arm_active = self.view.node_t_list.btn_god_arm_active.node
	self.btn_light_pic = self.view.node_t_list.btn_light_pic.node
	self.img_god_arm_actived_stamp = self.view.node_t_list.img_god_arm_actived_stamp.node
	self.consume_rich_text = self.view.node_t_list.rich_god_arm_consume.node
	self.txt_god_arm_attr_title = self.view.node_t_list.txt_god_arm_attr_title.node
	self:CreateViewElement()
	-- self:UpdateData()
	self:InitEvent()

	-- ClientCommonButtonDic[CommonButtonType.COMPOSE_XF_ACTIVATE_BTN] = self.page.componment5.active_btn.node

end	

--初始化事件
function ComposeGodArmPage:InitEvent()
	
	-- XUI.AddClickEventListener(self.page.uplevelBtn.node,BindTool.Bind(self.OnClickUpLevel,self),true)
	XUI.AddClickEventListener(self.btn_light_pic, BindTool.Bind(self.OnLightUpPic,self),true)
	XUI.AddClickEventListener(self.page.questBtn.node,BindTool.Bind(self.OnHelp,self),true)
	-- XUI.AddClickEventListener(self.page.btn_light_pic.node,BindTool.Bind(self.OnActive,self),false)
	XUI.AddClickEventListener(self.btn_god_arm_active, BindTool.Bind(self.OnActive,self),true)

	-- self.item_list_event = BindTool.Bind1(self.ItemDataListChangeCallback, self)
	-- ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event, true)

	-- self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	-- RoleData.Instance:NotifyAttrChange(self.role_data_event)

	self.god_arm_event = GlobalEventSystem:Bind(ComposeEvent.GOD_ARM_DATA_CHANGE, BindTool.Bind(self.UpdateData, self))
end

--移除事件
function ComposeGodArmPage:RemoveEvent()
	if self.item_list_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_list_event)
		self.item_list_event = nil
	end
	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end	

	if self.god_arm_event then
		GlobalEventSystem:UnBind(self.god_arm_event)
		self.god_arm_event = nil
	end

	if self.god_arm_show_list then
		self.god_arm_show_list:DeleteMe()
		self.god_arm_show_list = nil
	end

	if self.arm_attr_list then
		self.arm_attr_list:DeleteMe()
		self.arm_attr_list = nil
	end
	self:DeleteLightGrid()
end

--更新视图界面
function ComposeGodArmPage:UpdateData(data)
	self.cur_data = nil
	local data = ComposeData.Instance:GetGodArmData()
	self.god_arm_show_list:SetDataList(data)
	self.god_arm_show_list:SelectIndex(self.equipIndex)
end	

function ComposeGodArmPage:CreateViewElement()
	if nil == self.god_arm_show_list then
		local ph = self.view.ph_list.ph_god_arm_show_list
		self.god_arm_show_list = ListView.New()
		self.god_arm_show_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ComposeGodArmItemRender, nil, nil, self.view.ph_list.ph_show_god_arm_item)
		self.page.node:addChild(self.god_arm_show_list:GetView(), 100)
		self.god_arm_show_list:SetItemsInterval(5)
		self.god_arm_show_list:SetJumpDirection(ListView.Top)
		self.god_arm_show_list:SetIsUseStepCalc(false)
		self.god_arm_show_list:SetSelectCallBack(BindTool.Bind(self.GodArmSelectCallback, self))
		
		-- self.god_arm_show_list:SetDataList()
		-- self.god_arm_show_list:JumpToTop()
	end

	if nil == self.arm_attr_list then
		local ph = self.view.ph_list.ph_god_arm_attr_list
		self.arm_attr_list = ListView.New()
		self.arm_attr_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ComposeGodArmAttrRender, nil, nil, self.view.ph_list.ph_god_arm_attr_item)
		self.page.node:addChild(self.arm_attr_list:GetView(), 100)
		self.arm_attr_list:SetItemsInterval(3)
		self.arm_attr_list:SetJumpDirection(ListView.Top)
	end
	ph = self.view.ph_list.ph_god_arm_show_eff
	if nil == self.big_arm_effec then
		self.big_arm_effec = RenderUnit.CreateEffect(effect_id, self.page.node, 99, frame_interval, loops, ph.x, ph.y, callback_func)
	end
end	

function ComposeGodArmPage:GodArmSelectCallback(item, index)
	if item == nil or item:GetData() == nil then return end
	local data = item:GetData()
	if self.cur_data and self.cur_data.id == data.id then return end
	if data.can_selec then
		self.cur_data = data
		self.equipIndex = index
		self:SetLightGrid(self.old_index ~= index)
		self.old_index = index
		self:FlushShowInfo(data)
	else
		self.god_arm_show_list:ChangeToIndex(self.equipIndex)
		-- self.view.node_t_list.btn_god_arm_active.node:setVisible(false)
		-- self.view.node_t_list.btn_light_pic.node:setVisible(false)
	end
end

function ComposeGodArmPage:SetLightGrid(is_new)
	if is_new then
		self:DeleteLightGrid()
	end
	if self.cur_data.active_state == ComposeGodArmActiveState.Actived then
		self:DeleteLightGrid()
		return
	end
	self:CreateLightGrid()
	self:FlushLightGrid()
end

function ComposeGodArmPage:CreateLightGrid()
	if not self.cur_data then return end
	local num = self.cur_data.picNum
	if not self.light_grid then
		local ui_config = self.view.ph_list["ph_light_item_" .. self.equipIndex]
		local unit_cnt = math.sqrt(num)
		local ph = self.view.ph_list.ph_light_grid
		self.light_grid = BaseGrid.New()
		local grid_node = self.light_grid:CreateCells({w=ph.w, h=ph.h, cell_count = num, col= unit_cnt, row = unit_cnt, 
			itemRender = GodArmLightItem, direction = nil, ui_config = ui_config})
		grid_node:setAnchorPoint(0.5, 0.5)
		self.view.node_t_list.layout_god_arm.node:addChild(grid_node, 100)
		grid_node:setPosition(ph.x, ph.y)
	end
end

function ComposeGodArmPage:FlushLightGrid()
	if not self.cur_data then return end
	local num = self.cur_data.picNum
	local lit_num = self.cur_data.lit_num
	-- print("点亮数：", lit_num)
	local data = {}
	for i = 0, num - 1, 1 do
		local tmp = {is_lit = false}
		tmp.is_lit = lit_num > i
		data[i] = tmp
	end

	self.light_grid:SetDataList(data)
end

function ComposeGodArmPage:DeleteLightGrid()
	if self.light_grid then
		self.light_grid:DeleteMe()
		self.light_grid:GetView():removeFromParent()
		self.light_grid = nil
	end
end

function ComposeGodArmPage:FlushShowInfo(data)
	if not data then return end
	self.txt_god_arm_des_1:setVisible(data.active_state == ComposeGodArmActiveState.CanActive)
	self.btn_god_arm_active:setVisible(data.active_state == ComposeGodArmActiveState.CanActive)
	self.btn_light_pic:setVisible(data.active_state == ComposeGodArmActiveState.NoActive)
	self.img_god_arm_actived_stamp:setVisible(data.active_state == ComposeGodArmActiveState.Actived)
	self.consume_rich_text:setVisible(data.active_state == ComposeGodArmActiveState.NoActive)
	
	local str = Language.Compose.GodArmAttrTitle[1]
	local attr_content_data = ComposeData.GetOneAttrContent(data.id)
	if data.active_state == ComposeGodArmActiveState.Actived then
		str = Language.Compose.GodArmAttrTitle[2]
		attr_content_data = ComposeData.Instance:GetAllActiveGodArmAddAttrContent()
	end
	self.arm_attr_list:SetDataList(attr_content_data)
	self.txt_god_arm_attr_title:setString(str)
	self:FlushConsumeInfo()

	if self.big_arm_effec then
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(data.eff_id or 1)
		self.big_arm_effec:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
end

function ComposeGodArmPage:FlushConsumeInfo()
	if not self.cur_data then return end
	local need_cnt = self.cur_data.consumes[1].count
	local have_cnt = ItemData.Instance:GetItemNumInBagById(ComposeData.Instance:GetComsumeItemId())
	local color = need_cnt <= have_cnt and "00ff00" or "ff2828"
	local content = string.format(Language.Compose.GodArmConsume, color, need_cnt)
	RichTextUtil.ParseRichText(self.consume_rich_text, content)
end

--激活
function ComposeGodArmPage:OnActive()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	if self.equipIndex then	
		ComposeCtrl.ActiveOneGodArmReq(self.equipIndex)
	end
end	


--帮助点击
function ComposeGodArmPage:OnHelp()
	DescTip.Instance:SetContent(Language.Compose.Content[7],Language.Compose.Title[7])
end	

--点亮图鉴
function ComposeGodArmPage:OnLightUpPic()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	if self.equipIndex then	
		ComposeCtrl.LightOneGodArmReq(self.equipIndex)
	end
end	

--升级点击
function ComposeGodArmPage:OnClickUpLevel()
	-- if IS_ON_CROSSSERVER then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
	-- 	return 
	-- end	
	-- ComposeCtrl.Instance:SendUpLevelReq(self.equipIndex)
end

--物品改变
function ComposeGodArmPage:ItemDataListChangeCallback()
	self:FlushConsumeInfo()
end