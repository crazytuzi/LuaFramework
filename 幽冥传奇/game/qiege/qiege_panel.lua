QieGePanel = QieGePanel or BaseClass(SubView)

function QieGePanel:__init()
	self.texture_path_list = {
		'res/xui/qiege.png',
		
	}
	self.config_tab = {
		{"qiege_ui_cfg", 1, {0}},
		-- {"common_ui_cfg", 2, {0}, nil, 999},

	}
	self.effect = nil
	self.door = DoorModal.New()
    self.door:BindClickActBtnFunc(BindTool.Bind(self.BtnUpgrade, self))
end

function QieGePanel:__delete( ... )
	-- body
end

function QieGePanel:ReleaseCallBack( ... )
	if self.effect then
		self.effect:setStop()
		self.effect = nil
	end
	if self.cur_attr_list then
		self.cur_attr_list:DeleteMe()
		self.cur_attr_list = nil
	end

	if self.next_attr_list then
		self.next_attr_list:DeleteMe()
		self.next_attr_list = nil
	end

	if self.task_list then
		self.task_list:DeleteMe()
		self.task_list = nil 
	end
	if self.level_change then
		GlobalEventSystem:UnBind(self.level_change)
		self.level_change = nil
	end

	if self.info_change then
		GlobalEventSystem:UnBind(self.info_change)
		self.info_change = nil
	end

	if self.cell_list then
		for k, v in pairs( self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end 

	if self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil
	end
	self.star_list = {}
	self.door:Release()
end

function QieGePanel:LoadCallBack(loaded_times, index)
	self.node_t_list.layout_task.node:setVisible(false)
	self.node_t_list.layout_step2.node:setVisible(false)
	local ph = self.ph_list.ph_eff
	if self.effect == nil then
		self.effect = AnimateSprite:create()
		self.node_t_list.layout_left_show.node:addChild(self.effect,3)
		self.effect:setPosition(265, 295)
	end
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1107)

	self.effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		

	self:CreateCurAttrList()
	self:CreatenextAttrList()
	self:CreateTaskList()
	self:CreateStar()
	self:CreateCells()
	XUI.AddClickEventListener(self.node_t_list.layout_task_btn.node, BindTool.Bind1(self.OpenTaskView, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_return.node, BindTool.Bind1(self.OpenQieGeView, self), true)
	XUI.AddClickEventListener(self.node_t_list.Btn_up.node, BindTool.Bind1(self.BtnUpgrade, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_ques.node, BindTool.Bind1(self.OpenTips, self), true)
	

	self.link_stuff = RichTextUtil.CreateLinkText("领取材料", 20, COLOR3B.GREEN)
	self.link_stuff:setPosition(300, 30)
	self.node_t_list.layout_attr_show.node:addChild(self.link_stuff, 99)
	XUI.AddClickEventListener(self.link_stuff, function()
			self:OpenTaskView()
	end, true)

	self.level_change = GlobalEventSystem:Bind(QIEGE_EVENT.UpGrade_Result, BindTool.Bind1(self.FlushRight, self))
	
	self.info_change = GlobalEventSystem:Bind(QIEGE_EVENT.GetRewardInfo, BindTool.Bind1(self.Flushleft, self))
	for i = 1, 3 do
		-- XUI.AddClickEventListener(self.node_t_list["img_cell"..i].node, BindTool.Bind2(self.OpenItemShow, self, i), true)
		self.node_t_list["layout_show"..i].node:setVisible(false)
	end
	for i = 1, 3 do 
		XUI.AddClickEventListener(self.node_t_list["layout_had"..i].node, BindTool.Bind2(self.OpenAlertView, self, i), true)
	end
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function QieGePanel:ItemDataListChangeCallback( ... )
	self:FlushRight()
	self:Flushleft()
end

function QieGePanel:OpenItemShow(index)
	local config = QieGeData.Instance:GetQieGeEffectData()
	local level = QieGeData.Instance:GetLevel()
	--local cur_config = config[]
	local data = {}
	for k, v in pairs(config) do
		if v.id == index then
			data = {item_id = v.reward[1].id, num = 1, is_bind = 0}
		end
	end
	TipCtrl.Instance:OpenItem(data)
end

function QieGePanel:OpenTips( ... )
	DescTip.Instance:SetContent(Language.QieGe.showContent, Language.QieGe.showTitle)
end

function QieGePanel:OpenAlertView(index)
	local data = QieGeData.Instance:GetQieGeEffectData()
	-- local level =  QieGeData.Instance:GetLevel()
	local cur_data = data[index] or {}
	-- if (level < cur_data.need_level) then
	-- 	SysMsgCtrl.Instance:FloatingTopRightText("该效果未激活")
	-- 	return 
	-- end

	-- if (cur_data.item_num <= 0) then
	-- 	SysMsgCtrl.Instance:FloatingTopRightText("没有物品可领取")
	-- 	return 
	-- end

	-- if self.alert_view == nil then
	-- 	self.alert_view = Alert.New()
	-- end
	-- local item_cfg = ItemData.Instance:GetItemConfig(cur_data.reward[1].id)
	-- local str = string.format(Language.QieGe.showdesc3, cur_data.name, item_cfg.name, cur_data.item_num)
	-- self.alert_view:SetLableString(str)
	-- self.alert_view:SetOkFunc(function()
	-- 	--QieGeCtrl.Instance:SendGetQieGeReweardReq(cur_data.key)
	-- end)
	-- self.alert_view:Open()
	QieGeCtrl.Instance:OpenSkillTipView(cur_data.id)
end

function QieGePanel:BtnUpgrade()
	QieGeCtrl.Instance:SendQieGeUpgradeReq()
end

function QieGePanel:OpenTaskView( ... )
	self.node_t_list.layout_task.node:setVisible(true)
	self.node_t_list.layout_left_show.node:setVisible(false)
end

function QieGePanel:OpenQieGeView( ... )
	self.node_t_list.layout_task.node:setVisible(false)
	self.node_t_list.layout_left_show.node:setVisible(true)
end

function QieGePanel:CreateCurAttrList(  )
	if nil == self.cur_attr_list then
		local ph = self.ph_list.ph_cur_attr_list--获取区间列表
		self.cur_attr_list = ListView.New()
		self.cur_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, QieGeAttrItem, nil, nil, self.ph_list.ph_attr_item1)
		self.cur_attr_list:SetItemsInterval(5)--格子间距
		self.cur_attr_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_attr_show.node:addChild(self.cur_attr_list:GetView(), 20)
		self.cur_attr_list:GetView():setAnchorPoint(0, 0)
	end
end

function QieGePanel:CreatenextAttrList( ... )
	if nil == self.next_attr_list then
		local ph = self.ph_list.ph_next_attr_list--获取区间列表
		self.next_attr_list = ListView.New()
		self.next_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, QieGeAttrItem, nil, nil, self.ph_list.ph_attr_item2)
		self.next_attr_list:SetItemsInterval(5)--格子间距
		self.next_attr_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_attr_show.node:addChild(self.next_attr_list:GetView(), 20)
		self.next_attr_list:GetView():setAnchorPoint(0, 0)
	end
end

function QieGePanel:CreateTaskList( ... )
	
	if nil == self.task_list then
		local ph = self.ph_list.ph_task_list--获取区间列表
		self.task_list = ListView.New()
		self.task_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, QieGeTaskRender, nil, nil, self.ph_list.ph_list_item)
		self.task_list:SetItemsInterval(0)--格子间距
		self.task_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_task.node:addChild(self.task_list:GetView(), 999)
		self.task_list:GetView():setAnchorPoint(0, 0)
	end
end

function QieGePanel:CreateStar()
	self.satr_list = {}
	local ph = self.ph_list.ph_star
	for i = 1, 10 do
		local star = XUI.CreateImageView(ph.x + (i - 1) * 30 + 22, ph.y +10, ResPath.GetCommon("star_1_lock"), true)
		self.node_t_list.layout_attr_show.node:addChild(star, 99)
		self.satr_list[i] = star
	end
end


function QieGePanel:CreateCells( ... )
	self.cell_list = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:GetView():setPosition(ph.x, ph.y)
		self.node_t_list.layout_attr_show.node:addChild(cell:GetView(), 99)
		table.insert(self.cell_list, cell)
	end
end

-- layout_attr_show

function QieGePanel:FlushRight( ... )
	self:FlushRightView(true)
	self:FlushTaskView()
	self:FlushEffect()
	 self.door:OpenTheDoor()
end

function QieGePanel:Flushleft( ... )
	self:FlushRightView()
	self:FlushleftView()
	self:FlushEffect()
end


function QieGePanel:OpenCallBack()
	local level = QieGeData.Instance:GetLevel()
    self.door:SetVis(level == 0, self.root_node)
    if level == 0 then
        self.door:CloseTheDoor()
    else
        self.door:OpenTheDoor()
    end
end


function QieGePanel:ShowIndexCallBack(index)
	self:Flush(index)
end

function QieGePanel:OnFlush(param_t, index)
	self:FlushRightView()
	self:FlushleftView()
	self:FlushEffect()
	self:FlushDesc()
end


function QieGePanel:FlushDesc()
	 RichTextUtil.ParseRichText(self.node_t_list.ricn_text_desc.node, Language.QieGe.showdesc4)
	 XUI.RichTextSetCenter(self.node_t_list.ricn_text_desc.node)
end


function QieGePanel:FlushTaskView()
	local data = QieGeData.Instance:GetTaskConfig()
	self.task_list:SetDataList(data)

	local vis = QieGeData.Instance:OnQieGeTaskCanGet()
	self.node_t_list.img_red_point.node:setVisible(vis)
end


function QieGePanel:FlushleftView()
	--self:FlushEffect()
	self:FlushTaskView()
end
	

function QieGePanel:FlushRightView(bool)
	local level = QieGeData.Instance:GetLevel()
	local step, star = QieGeData.Instance:GetLevelAndStep(level)
	self:SetStarShow(star)
	self:SetStepShow(step)

	local cur_config = QieGeData.Instance:GetUpGradeConfigLevel(level)
	if (cur_config) then
		local attr = cur_config.attrs
		local cur_attr_list = RoleData.FormatRoleAttrStr(attr)
		for k, v in pairs(cur_attr_list) do
			v.is_show = bool or false
		end
		self.cur_attr_list:SetDataList(cur_attr_list)
	else
		self.cur_attr_list:SetDataList({})
	end

	local next_config = QieGeData.Instance:GetUpGradeConfigLevel(level+1)
	if (next_config) then
		local attr = next_config.attrs
		local next_attr_list = RoleData.FormatRoleAttrStr(attr)
		self.next_attr_list:SetDataList(next_attr_list)
		self.node_t_list.text_max_level.node:setVisible(false)
	else
		self.next_attr_list:SetDataList({})
		self.node_t_list.text_max_level.node:setVisible(true)
	end
	local isCan = QieGeData.Instance:GetCanUpQieGe()
	XUI.SetButtonEnabled(self.node_t_list.Btn_up.node, isCan)
	self.node_t_list.img_red.node:setVisible(isCan)

	local text = level == 0 and "激活" or "升级"
	self.node_t_list.Btn_up.node:setTitleText(text)
	for i = 1, 4 do
		RichTextUtil.ParseRichText(self.node_t_list["txet_consume"..i].node, "")
	end
	for k, v in pairs(self.cell_list) do
		v:GetView():setVisible(false)
	end
	if (next_config) then
		for i, v in ipairs(next_config.consumes) do
			local cell = self.cell_list[i]
			if cell then
				cell:GetView():setVisible(true)
				cell:SetData({item_id = v.id, num = 1, is_bind = 0})
				local had_item_num = BagData.Instance:GetItemNumInBagById(v.id, nil)
				local color2 = had_item_num >= v.count and "00ff00" or "ff0000"
				local color = Str2C3b(color2)
				local text = string.format("%d/%d", had_item_num, v.count)
				cell:SetRightBottomText(text, color)
			end
		end
		local offest = 0
		if #next_config.consumes == 1 then
			offest = 120
		elseif #next_config.consumes == 2 then
			offest = 80
		elseif  #next_config.consumes == 3 then
			offest = 40
		else
			offest = 0
		end
		local ph = self.ph_list.ph_cell_1
		for k, v in pairs(self.cell_list) do
			v:GetView():setPosition(ph.x + (k -1) * 80 + offest, ph.y)
		end
	end
	
end


function QieGePanel:SetStepShow(step)
	local bool = false
	local bool1 = false
	local bool2 = false

	local s = math.floor(step/10) <= 1 and 0 or  math.floor(step/10)
	local y = step%10 == 0 and 0 or step%10
	if step  >= 11  and step <= 20 or step%10 == 0 then
		bool = true
		bool1 = true
		self.node_t_list.img_step3.node:loadTexture(ResPath.GetCommon("daxie_".. s))
		self.node_t_list.img_step2.node:loadTexture(ResPath.GetCommon("daxie_".. y))
	elseif step >= 21 and step%10 ~= 0 then
		bool = true
		bool2 = true
		self.node_t_list.img_step4.node:loadTexture(ResPath.GetCommon("daxie_".. s))
		self.node_t_list.img_step5.node:loadTexture(ResPath.GetCommon("daxie_".. y))
	else
		local step1 = step == 10 and 0 or step == 0 and 1 or step
		self.node_t_list.img_step.node:loadTexture(ResPath.GetCommon("daxie_".. step1))
	end

	self.node_t_list.layout_step2.node:setVisible(bool1)
	self.node_t_list.layout_step.node:setVisible(not bool)
	self.node_t_list.layout_step3.node:setVisible(bool2)
end

function QieGePanel:SetStarShow(star)
	for k, v in pairs(self.satr_list) do
		if star >= k then
			v:loadTexture(ResPath.GetCommon("star_1_select"))
		else
			v:loadTexture(ResPath.GetCommon("star_1_lock"))
		end
	end
end


function QieGePanel:FlushEffect( )
	local config = QieGeData.Instance:GetQieGeEffectData()
	local level = QieGeData.Instance:GetLevel()
	for k, v in pairs(config) do
		local id = v.id
		-- self.node_t_list["txt_name"..id].node:setString(v.name)
		-- self.node_t_list["img_cell"..id].node:setGrey(level < v.need_level)
		self.node_t_list["txt_had_item"..id].node:setString(v.item_num)
		local item_config = ItemData.Instance:GetItemConfig(v.reward[1].id)
		local icon = ResPath.GetItem(item_config.icon)
		self.node_t_list["img_icon"..id].node:loadTexture(icon)
		self.node_t_list["img_icon"..id].node:setScale(0.8)
		self.node_t_list["point"..id].node:setVisible(v.item_num > 0)
	end

end


QieGeAttrItem = QieGeAttrItem or BaseClass(BaseRender)
function QieGeAttrItem:__init()
	-- body
end

function QieGeAttrItem:__delete()
	-- body
end

function QieGeAttrItem:CreateChild()
	BaseRender.CreateChild(self)
end

function QieGeAttrItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str.."：")
	self.node_tree.lbl_attr_value.node:setString(self.data.value_str)

	 if self.data.is_show then
        if nil == self.select_effect then
            local size = self.node_tree.img9_bg.node:getContentSize()
            self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_292"), true)
            self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
            self.select_effect:setOpacity(0)
        end

        local fade_out = cc.FadeTo:create(0.2, 140)
        local fade_in = cc.FadeTo:create(0.3, 80)
        local fade_in2 = cc.FadeTo:create(0.2, 0)
        local action = cc.Sequence:create(fade_out, fade_in, fade_out, fade_in2)
        self.select_effect:runAction(action)
    end
end

function QieGeAttrItem:CreateSelectEffect()
	
end

QieGeTaskRender = QieGeTaskRender or BaseClass(BaseRender)
function QieGeTaskRender:__init()
	-- body
end

function QieGeTaskRender:__delete()
	-- body
end

function QieGeTaskRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_duihuan.node, BindTool.Bind1(self.OnGetTaskReward, self), true)
end

function QieGeTaskRender:OnFlush()
	if self.data == nil then
		return
	end
	self.node_tree.img_bg.node:setVisible(self.index % 2 ~= 1 )
	local text = Language.QieGe.BtnText[self.data.can_get]
	self.node_tree.btn_duihuan.node:setTitleText(text)
	XUI.SetButtonEnabled(self.node_tree.btn_duihuan.node, self.data.can_get == 2)

	--had_skill_count >= v.skill_con
	local color = self.data.can_get == 2 and "00ff00" or "ff0000"

	local text1 = string.format(Language.QieGe.showdesc1, self.data.name, color, self.data.had_skill_count, self.data.skill_con)
	RichTextUtil.ParseRichText(self.node_tree.rich_desc.node, text1)

	local reward = self.data.reward[1]

	local item_cfg = ItemData.Instance:GetItemConfig(reward.id)
	local text2 = string.format(Language.QieGe.showdesc2, item_cfg.name or "", reward.count)
	--rich_get

	RichTextUtil.ParseRichText(self.node_tree.rich_get.node, text2)

end

function QieGeTaskRender:OnGetTaskReward()
	
	QieGeCtrl.Instance:SendGetTaskReward(self.data.key)
end

function QieGeTaskRender:CreateSelectEffect()
	
end