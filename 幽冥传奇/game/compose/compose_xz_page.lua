--神炉勋章页面
ComposeXzPage = ComposeXzPage or BaseClass()

function ComposeXzPage:__init()
	self.view = nil
end	

function ComposeXzPage:__delete()

	self:RemoveEvent()
	ClientCommonButtonDic[CommonButtonType.COMPOSE_XZ_ACTIVATE_BTN] = nil
	self.effec = nil
	
	self.page = nil
	self.view = nil
end	

--初始化页面接口
function ComposeXzPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.page = self.view.node_t_list.layout_medal
	self:CreateViewElement()
	self:InitEvent()
	
end	

--初始化事件
function ComposeXzPage:InitEvent()
	XUI.AddClickEventListener(self.page.layout_jihuo.active_btn.node, BindTool.Bind1(self.EquipUpgrade, self), true)
	XUI.AddClickEventListener(self.page.componment3.uplevelBtn.node, BindTool.Bind1(self.OnClickUpLevel, self), true)
	XUI.AddClickEventListener(self.page.componment3.lookseeBtn.node, BindTool.Bind1(self.OnLook, self), true)
	XUI.AddClickEventListener(self.page.componment3.questBtn.node, BindTool.Bind1(self.OnHelp, self), true)

	self.item_list_event = BindTool.Bind1(self.ItemDataListChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event, true)

	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)

	self:RoleDataChangeCallback(OBJ_ATTR.ACTOR_ACHIEVE_VALUE)
end

--移除事件
function ComposeXzPage:RemoveEvent()
	Runner.Instance:RemoveRunObj(self)

	if self.item_list_event then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_list_event)
		self.item_list_event = nil
	end

	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil
	end
end

--更新视图界面
function ComposeXzPage:UpdateData(data)
	local equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itDecoration) --检测是否有勋章装备
	if equip then
		self.page.layout_jihuo.node:setVisible(false)
		self:UpdataAttr(equip)
		if not self.effec then
			self.effec = RenderUnit.CreateEffect(43, self.page.img_layout.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
			self.effec:setLocalZOrder(-10)
		end
		
	else
		self:Clear()
		self.page.layout_jihuo.node:setVisible(true)
		self:UpdateConsume(0)
	end
end	

function ComposeXzPage:RoleDataChangeCallback(key,value)
	if key == OBJ_ATTR.ACTOR_ACHIEVE_VALUE then
		local achievement_points = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ACHIEVE_VALUE) or 0
		self.view.node_t_list.txt_achieve_point.node:setString(achievement_points)
		self:UpdateData()
	end	
end	

function ComposeXzPage:Update(now_time, elapse_time)
	if self.innerContainer then
		local tempY = self.innerContainer:getPositionY()

		if tempY > self.innerContainerY + 20 then
			self.actionDir = 0
		elseif tempY < self.innerContainerY - 20 then
			self.actionDir = 1
		end	

		if self.actionDir == 1 then
			self.innerContainer:setPositionY(tempY + 1)
		else
			self.innerContainer:setPositionY(tempY - 1)
		end	
		
	end	
end	


function ComposeXzPage:CreateViewElement()
	self.innerContainer = self.page.innerContainer.node
	self.innerContainerY = self.innerContainer:getPositionY()
	self.actionDir = 1
	Runner.Instance:AddRunObj(self)
end	

function ComposeXzPage:UpdataAttr(equip)
	local level = equip.compose_level
	local attrs_t = AchieveData.Instance:GetAttr(level)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range)
	for i = 1, 4 do
		self.page.componment2["layout_bg" .. i]["attr_title" .. i].node:setString(title_attrs[i] and title_attrs[i].type_str .. "：" or "")
		self.page.componment2["layout_bg" .. i]["cur_attr" .. i].node:setString(title_attrs[i] and title_attrs[i].value_str or "")
		if title_attrs[i] == nil then
			self.page.componment2["layout_bg" .. i].node:setVisible(false)
		end
	end	
		
	local nexLevel = level + 1
	local attrs_t = AchieveData.Instance:GetAttr(nexLevel)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local title_attrs_1 = RoleData.FormatRoleAttrStr(attrs_t, {value_str_color = COLOR3B.GREEN})
	for i = 1, 4 do
		if nexLevel ~= 100 then
			self.page.componment2["layout_bg" .. i]["nex_attr" .. i].node:setString(title_attrs_1[i] and title_attrs_1[i].value_str or "")
		else
			self.page.componment2["layout_bg" .. i]["nex_attr" .. i].node:setString("")
		end
	end

	--RichTextUtil.ParseRichText(self.page.rich_next_text.node, title_attrs_1, 22, COLOR3B.OLIVE)

	local step, star = AchieveData.Instance:GetStepStar(level)
	self.page.img_level.node:loadTexture(ResPath.GetCommon("step_" .. step))
	local config = AchieveData.Instance:GetStepStarConfig(step)
	if config then
		local itemCfg = ItemData.Instance:GetItemConfig(config.itemId)
		self.page.txt_name.node:setString(Language.Achieve.StepName[step])

		self.innerContainer:setVisible(true)
		self.page.innerContainer.innerImg.node:loadTexture(ResPath.GetComposeInner(config.icon or 1))
	else
		self.page.txt_name.node:setString("")
	end
	self:UpdateConsume(level)
	for i = 1, 10 do
		self.page.componment3["starImg" .. i].node:setVisible(false)
	end

	for i = 1, star do 
		self.page.componment3["starImg" .. i].node:setVisible(true)
		self.page.componment3["starImg" .. i].node:loadTexture(ResPath.GetCommon("star_0_select"))
	end

	for i = star + 1,10 do
		self.page.componment3["starImg" .. i].node:setVisible(true)
		self.page.componment3["starImg" .. i].node:loadTexture(ResPath.GetCommon("star_0_lock"))
	end	
end


function ComposeXzPage:Clear()
	for i = 1, 10 do 
		self.page.componment3["starImg" .. i].node:setVisible(false)
	end
	self.page.txt_name.node:setString("")
	self.innerContainer:setVisible(false)
end

function ComposeXzPage:UpdateConsume(level)
	local step, star = AchieveData.Instance:GetStepStar(level)
	local consume = AchieveData.Instance:GetConsume(5, level + 1)
	if consume then
		local consume_num = consume[1]
		local result = string.format(Language.Achieve.ConsumeFormatTip, star, "", consume_num.count)
		self.page.componment3.txt_level.node:setString(result)

		local roleValue = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ACHIEVE_VALUE)
		self.page.componment3.progress_bar.node:setPercent(roleValue / consume_num.count * 100)
		self.page.componment3.progress_text.node:setString(roleValue .. "/" .. consume_num.count)
	else
		self.page.componment3.txt_level.node:setString(Language.Compose.Top_level)
		self.page.componment3.progress_bar.node:setPercent(0)
		self.page.componment3.progress_text.node:setString("")
		--RichTextUtil.ParseRichText(self.page.rich_next_text.node, Language.Compose.Top_level, 22, COLOR3B.RED)

	end
end

--物品改变
function ComposeXzPage:ItemDataListChangeCallback()
	self:UpdateData()
end

--激活
function ComposeXzPage:EquipUpgrade()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	ComposeCtrl.Instance:SendActiveReq(5)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

--升级点击
function ComposeXzPage:OnClickUpLevel()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	ComposeCtrl.Instance:SendUpLevelReq(5)
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

--预览点击
function ComposeXzPage:OnLook()
	ViewManager.Instance:Open(ViewName.ComposeBroswer)
	ViewManager.Instance:FlushView(ViewName.ComposeBroswer,0,"type",{type = ItemData.ItemType.itDecoration})
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

--帮助点击
function ComposeXzPage:OnHelp()
	DescTip.Instance:SetContent(Language.Compose.Content[ItemData.ItemType.itDecoration],Language.Compose.Title[ItemData.ItemType.itDecoration])
end
