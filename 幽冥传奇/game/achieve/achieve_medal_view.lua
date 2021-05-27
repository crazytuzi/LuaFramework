-- 勋章界面
--暂时系统界面合并到神炉页面2017/9/18
AchieveView = AchieveView or BaseClass()


-- 初始化事件
function AchieveView:MedalInit()
	
	self:CreateViewElement()
	XUI.AddClickEventListener(self.node_t_list.layout_jihuo.active_btn.node, BindTool.Bind1(self.EquipUpgrade, self), true)
	XUI.AddClickEventListener(self.node_t_list.componment3.uplevelBtn.node, BindTool.Bind1(self.OnClickUpLevel, self), true)
	XUI.AddClickEventListener(self.node_t_list.componment3.lookseeBtn.node, BindTool.Bind1(self.OnLook, self), true)
	XUI.AddClickEventListener(self.node_t_list.componment3.questBtn.node, BindTool.Bind1(self.OnHelp, self), true)

	ClientCommonButtonDic[CommonButtonType.COMPOSE_XZ_ACTIVATE_BTN] = self.node_t_list.layout_jihuo.active_btn.node
end


-- 移除事件
function AchieveView:MedalDelete()
	Runner.Instance:RemoveRunObj(self)
	ClientCommonButtonDic[CommonButtonType.COMPOSE_XZ_ACTIVATE_BTN] = nil
	self.effec = nil
	self.effec_1 = nil 
end



function AchieveView:CreateViewElement()

	self.innerContainer = self.node_t_list.innerContainer.node
	self.innerContainerY = self.innerContainer:getPositionY()
	self.actionDir = 1

	Runner.Instance:AddRunObj(self)
end	

function AchieveView:SelectShopCallBack(item, index)
	if item == nil and item:GetData() == nil then return end
	local data = item:GetData()

end

--更新视图界面
function AchieveView:MedalOnFlush(param_t, index)
	local equip = EquipData.Instance:GetEquipByType(ItemData.ItemType.itDecoration) --检测是否有勋章装备
	if equip then
		self.node_t_list.layout_jihuo.node:setVisible(false)
		self:UpdataAttr(equip)
		if not self.effec then
			self.effec = RenderUnit.CreateEffect(43, self.node_t_list.img_layout.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
			self.effec:setLocalZOrder(-10)
		end
		if not self.effec_1 then
			self.effec_1 = RenderUnit.CreateEffect(43, self.node_t_list.img_layout_1.node, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS)
			self.effec_1:setLocalZOrder(109)
			self.effec_1:setOpacity(90)
		end
	else
		self:Clear()
		self.node_t_list.layout_jihuo.node:setVisible(true)
		self:UpdateConsume(0)
	end
end

function AchieveView:Update(now_time, elapse_time)
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

function AchieveView:UpdataAttr(equip)
	local level = equip.compose_level
	local attrs_t = AchieveData.Instance:GetAttr(level)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local title_attrs = RoleData.FormatRoleAttrStr(attrs_t, is_range)
	for i = 1, 4 do
		self.node_t_list["attr_title" .. i].node:setString(title_attrs[i] and title_attrs[i].type_str .. "：" or "")
		self.node_t_list["cur_attr" .. i].node:setString(title_attrs[i] and title_attrs[i].value_str or "")
		if title_attrs[i] == nil then
			self.node_t_list["layout_bg" .. i].node:setVisible(false)
		end
	end	
		
	local nexLevel = level + 1
	local attrs_t = AchieveData.Instance:GetAttr(nexLevel)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local title_attrs_1 = RoleData.FormatRoleAttrStr(attrs_t, {value_str_color = COLOR3B.GREEN})
	for i = 1, 4 do
		if nexLevel ~= 100 then
			self.node_t_list["nex_attr" .. i].node:setString(title_attrs_1[i] and title_attrs_1[i].value_str or "")
		else
			self.node_t_list["nex_attr" .. i].node:setString("")
		end
	end

	--RichTextUtil.ParseRichText(self.node_t_list.rich_next_text.node, title_attrs_1, 22, COLOR3B.OLIVE)

	local step, star = AchieveData.Instance:GetStepStar(level)
	self.node_t_list.img_level.node:loadTexture(ResPath.GetCommon("step_" .. step))
	local config = AchieveData.Instance:GetStepStarConfig(step)
	if config then
		local itemCfg = ItemData.Instance:GetItemConfig(config.itemId)
		self.node_t_list.txt_name.node:setString(Language.Achieve.StepName[step])

		self.innerContainer:setVisible(true)
		self.node_t_list.innerContainer.innerImg.node:loadTexture(ResPath.GetComposeInner(config.icon or 1))
	else
		self.node_t_list.txt_name.node:setString("")
	end
	self:UpdateConsume(level)
	for i = 1, 10 do
		self.node_t_list.componment3["starImg" .. i].node:setVisible(false)
	end

	for i = 1, star do 
		self.node_t_list.componment3["starImg" .. i].node:setVisible(true)
		self.node_t_list.componment3["starImg" .. i].node:loadTexture(ResPath.GetCommon("star_0_select"))
	end

	for i = star + 1,10 do
		self.node_t_list.componment3["starImg" .. i].node:setVisible(true)
		self.node_t_list.componment3["starImg" .. i].node:loadTexture(ResPath.GetCommon("star_0_lock"))
	end	
end


function AchieveView:Clear()
	for i = 1, 10 do 
		self.node_t_list.componment3["starImg" .. i].node:setVisible(false)
	end
	self.node_t_list.layout_medal.txt_name.node:setString("")
	self.innerContainer:setVisible(false)
end

function AchieveView:UpdateConsume(level)
	local step, star = AchieveData.Instance:GetStepStar(level)
	local consume = AchieveData.Instance:GetConsume(5, level + 1)
	if consume then
		local consume_num = consume[1]
		local result = string.format(Language.Achieve.ConsumeFormatTip, star, "", consume_num.count)
		self.node_t_list.componment3.txt_level.node:setString(result)

		local roleValue = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ACHIEVE_VALUE)
		self.node_t_list.componment3.progress_bar.node:setPercent(roleValue / consume_num.count * 100)
		self.node_t_list.componment3.progress_text.node:setString(roleValue .. "/" .. consume_num.count)
	else
		self.node_t_list.componment3.txt_level.node:setString(Language.Compose.Top_level)
		self.node_t_list.componment3.progress_bar.node:setPercent(0)
		self.node_t_list.componment3.progress_text.node:setString("")
		--RichTextUtil.ParseRichText(self.node_t_list.rich_next_text.node, Language.Compose.Top_level, 22, COLOR3B.RED)

	end
end

--激活
function AchieveView:EquipUpgrade()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	ComposeCtrl.Instance:SendActiveReq(5)
end

--升级点击
function AchieveView:OnClickUpLevel()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	ComposeCtrl.Instance:SendUpLevelReq(5)
end

--预览点击
function AchieveView:OnLook()
	ViewManager.Instance:Open(ViewName.ComposeBroswer)
	ViewManager.Instance:FlushView(ViewName.ComposeBroswer,0,"type",{type = ItemData.ItemType.itDecoration})
end

--帮助点击
function AchieveView:OnHelp()
	DescTip.Instance:SetContent(Language.Compose.Content[ItemData.ItemType.itDecoration],Language.Compose.Title[ItemData.ItemType.itDecoration])
end


