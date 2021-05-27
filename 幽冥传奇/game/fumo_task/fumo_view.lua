FumoView = FumoView or BaseClass(XuiBaseView)


function FumoView:__init()
	self:SetModal(true)
	self.def_index = 1
	self.config_tab = {
		{"fumoquest_ui_config", 1, {0}},
	}

	self.awardList = {}
end	

function FumoView:__delete()
end	

function FumoView:ReleaseCallBack()

	for _,v in pairs(self.awardList) do
		v:DeleteMe()
	end	
	self.awardList = {}
	
	if self.baseInfoCallHandle then
		GlobalEventSystem:UnBind(self.baseInfoCallHandle)
		self.baseInfoCallHandle = nil
	end	

	if self.freshStateBackHandle then
		GlobalEventSystem:UnBind(self.freshStateBackHandle)
		self.freshStateBackHandle = nil
	end	

	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end	
	if self.auto_upgrade_event then
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
	end
	self.get_task_btn_eff = nil
	self.refresh_btn_eff = nil
	self.chuansong_btn_eff = nil
	self.three_get_btn_eff = nil
	self.btn_autoflush_eff = nil
	self.liji_finish_eff = nil
	
end

function FumoView:OpenCallBack()
	self:AddMoveAutoClose()
end	

function FumoView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		
		self:CreateAwardList()
		self:Clear()

		self.rich_desc = self.node_t_list.desc_rich_text.node

		self.baseInfoCallHandle = GlobalEventSystem:Bind(FumoEventType.FUMO_INFO_CHANGE_BACK,BindTool.Bind(self.OnBaseInfoChange,self))
		self.freshStateBackHandle = GlobalEventSystem:Bind(FumoEventType.FUMO_VIEW_OPERATE_BACK,BindTool.Bind(self.OnfreshStateChange,self))
		self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
		RoleData.Instance:NotifyAttrChange(self.role_data_event)

		XUI.AddClickEventListener(self.node_t_list.get_task_btn.node,BindTool.Bind(self.OnGetTask,self))
		XUI.AddClickEventListener(self.node_t_list.liji_finish_btn.node,BindTool.Bind(self.OnLijiFinish,self))
		XUI.AddClickEventListener(self.node_t_list.chuansong_btn.node,BindTool.Bind(self.OnChuansong,self))

		XUI.AddClickEventListener(self.node_t_list.refresh_btn.node,BindTool.Bind(self.OnRefreshClick,self))
		XUI.AddClickEventListener(self.node_t_list.free_get_btn.node,BindTool.Bind(self.OnFreeGet,self))
		XUI.AddClickEventListener(self.node_t_list.double_get_btn.node,BindTool.Bind(self.OnDoubleGet,self))
		XUI.AddClickEventListener(self.node_t_list.three_get_btn.node,BindTool.Bind(self.OnThreeGet,self))
		XUI.AddClickEventListener(self.node_t_list.btn_autoflush.node,BindTool.Bind(self.OnAutoRresh, self))

		self.get_task_btn_eff = RenderUnit.CreateEffect(10,self.node_t_list.get_task_btn.node,100)
		self.get_task_btn_eff:setVisible(false)
		self.get_task_btn_eff:setScale(0.85)
		self.get_task_btn_eff:setScaleX(0.55)

		self.liji_finish_eff = RenderUnit.CreateEffect(10,self.node_t_list.liji_finish_btn.node,100)
		self.liji_finish_eff:setScale(0.85)
		self.liji_finish_eff:setScaleX(0.55)

		self.refresh_btn_eff = RenderUnit.CreateEffect(10,self.node_t_list.refresh_btn.node,100)
		self.refresh_btn_eff:setScale(0.85)
		self.refresh_btn_eff:setScaleX(0.55)
		self.refresh_btn_eff:setVisible(true)

		self.chuansong_btn_eff = RenderUnit.CreateEffect(10,self.node_t_list.chuansong_btn.node,100)
		self.chuansong_btn_eff:setScale(0.85)
		self.chuansong_btn_eff:setScaleX(0.55)
		
		self.three_get_btn_eff = RenderUnit.CreateEffect(10,self.node_t_list.three_get_btn.node,100)
		self.three_get_btn_eff:setScale(0.85)
		self.three_get_btn_eff:setScaleX(0.55)

		self.btn_autoflush_eff = RenderUnit.CreateEffect(10,self.node_t_list.btn_autoflush.node,100)
		self.btn_autoflush_eff:setScale(0.85)
		self.btn_autoflush_eff:setScaleX(0.55)
		self.btn_autoflush_eff:setVisible(false)
		self.node_t_list.auto_flush_text.node:setVisible(false)
		-- self.time = 0
	end

	self:OnFlush()
end

function FumoView:OnChuansong()
	TaskCtrl.SendQuickFly(FlyType.Task,FuMoData.Instance.task_id)
end	

function FumoView:OnLijiFinish()
	if self.data then
		FoMoCtrl.Instance:SendFumoOperateReq(5,self.data.task_id,0)
	end	
end	

function FumoView:OnFreeGet()
	if self.data then
		FoMoCtrl.Instance:SendFumoOperateReq(4,self.data.task_id,1)
	end	
end	

function FumoView:OnDoubleGet()
	if self.data then
		FoMoCtrl.Instance:SendFumoOperateReq(4,self.data.task_id,2)
	end	
end	

function FumoView:OnThreeGet()
	if self.data then
		FoMoCtrl.Instance:SendFumoOperateReq(4,self.data.task_id,3)
	end	
end	

function FumoView:OnGetTask()
	if self.data then
		FoMoCtrl.Instance:SendFumoOperateReq(3,self.data.task_id,0)
	end	
end	

function FumoView:OnAutoRresh()	
	self.refresh_btn_eff:setVisible(false)
	self.btn_autoflush_eff:setVisible(true)
	self.node_t_list.auto_flush_text.node:setVisible(true)
	self:OnCheckAuto()
end

function FumoView:OnCheckAuto()
	-- self.time = self.time + 1
	if self.data ~= nil then
		local task = TaskData.Instance:GetTaskInfo(FuMoData.Instance.task_id)
		self.data = task
		local starlevel = FuMoData.Instance.level
		if self.auto_upgrade_event then
			GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
			self.auto_upgrade_event = nil
		end	
		self.auto_upgrade_event = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnCheckAuto,self), 1)
		if starlevel >= 10 or task.task_state ~= TaskState.Accept then
			if self.auto_upgrade_event then
				GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
				self.auto_upgrade_event = nil
				return
			end	
		else
			money_type , money_count = FuMoData.Instance:GetUpLevelConsume()
			self.node_t_list.level_consume_text.node:setString(Language.Task.Consume .. money_count .. ShopData.GetMoneyTypeName(money_type))
			role_money_count = RoleData.Instance:GetAttr(ShopData.GetMoneyObjAttrIndex(money_type))

			if role_money_count >= money_count then
				FoMoCtrl.Instance:SendFumoOperateReq(2,self.data.task_id,0)
			else
				self.refresh_btn_eff:setVisible(true)
				self.btn_autoflush_eff:setVisible(false)
				self.node_t_list.auto_flush_text.node:setVisible(false)
				if self.auto_upgrade_event then
					GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
					self.auto_upgrade_event = nil
					return	
				end	
			end	
		end
	end
end


function FumoView:OnRefreshClick()
	self.refresh_btn_eff:setVisible(true)
	self.btn_autoflush_eff:setVisible(false)
	self.node_t_list.auto_flush_text.node:setVisible(false)
	if self.auto_upgrade_event then
		GlobalTimerQuest:CancelQuest(self.auto_upgrade_event)
		self.auto_upgrade_event = nil
	end	
	if self.data then
		FoMoCtrl.Instance:SendFumoOperateReq(2,self.data.task_id,0)
	end	
end	

function FumoView:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.CREATURE_LEVEL 
		or key == OBJ_ATTR.ACTOR_BIND_COIN 
		or key == OBJ_ATTR.ACTOR_COIN 
		or key == OBJ_ATTR.ACTOR_BIND_GOLD
		or key == OBJ_ATTR.ACTOR_GOLD then
		self:Clear()
		self:UpdatePanel()
	end	
end	

function FumoView:CreateAwardList()
	for i = 1,5 do
		local ph = self.ph_list["ph_item_cell" .. i]
		local cell = FumoRewardRender.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.awardList[i] = cell
		self.node_t_list.layout_container.node:addChild(cell:GetView(), 100)
	end	
end	

function FumoView:OnBaseInfoChange()
	self:Clear()
	self:UpdatePanel()
	
end	

function FumoView:OnfreshStateChange()
	self:Clear()
	self:UpdatePanel()
end	

function FumoView:UpdatePanel()
	local task = TaskData.Instance:GetTaskInfo(FuMoData.Instance.task_id)
	self.data = task
	local starlevel = FuMoData.Instance.level
	local money_type,money_count = 0,0
	local role_money_count = 0
	--已接任务
	if task then
		local progress_info =task.progress_list[1] --当前进度值
		local target = task.std_task.target[progress_info.target_index] --配置目标值
		local awards = task.std_task.awards[target.rewardId + 1]
		awards = TaskData.FilterAwards(awards)
		for i, v in ipairs(awards) do
			self.awardList[i]:SetData(v)
			self.awardList[i]:SetVisible(true)
		end	
		
		self:ParseDesc()
		
		if task.task_state == TaskState.Accept then --可接

			local tick_count = FuMoData.Instance:GetRemainTick()
			self.node_t_list.layout_get_task.node:setVisible(true)
			self.node_t_list.btn_autoflush.node:setVisible(true)
			self.node_t_list.remain_tick_text.node:setString(string.format(Language.Task.RemainTickFormat,tick_count))

			if tick_count > 0 then
				self.node_t_list.remain_tick_text.node:setColor(COLOR3B.GREEN)
			else
				self.node_t_list.remain_tick_text.node:setColor(COLOR3B.RED)
			end	



			if starlevel >= 10 then
				self.node_t_list.max_level_text.node:setVisible(true)
				self.get_task_btn_eff:setVisible(true)


				self.node_t_list.btn_autoflush.node:setVisible(false)
				self.node_t_list.auto_flush_text.node:setVisible(false)
			else
				self.get_task_btn_eff:setVisible(false)
				self.node_t_list.layout_up_level.node:setVisible(true)
				--计算升星消耗
				money_type , money_count = FuMoData.Instance:GetUpLevelConsume()
				self.node_t_list.level_consume_text.node:setString(Language.Task.Consume .. money_count .. ShopData.GetMoneyTypeName(money_type))
				role_money_count = RoleData.Instance:GetAttr(ShopData.GetMoneyObjAttrIndex(money_type))
				if role_money_count >= money_count then
					self.node_t_list.level_consume_text.node:setColor(COLOR3B.GREEN)
				else
					self.node_t_list.level_consume_text.node:setColor(COLOR3B.RED)
				end	
			end
		elseif task.task_state == TaskState.Complete then --可提交
			-- self.time = 0
			self.node_t_list.btn_autoflush.node:setVisible(false)
			self.node_t_list.auto_flush_text.node:setVisible(false)
			self.node_t_list.layout_award.node:setVisible(true)

			--计算领取消耗
			money_type , money_count = FuMoData.Instance:GetDoubleGetConsume()
			self.node_t_list.double_consume_text.node:setString(Language.Task.Consume .. money_count .. ShopData.GetMoneyTypeName(money_type))
			role_money_count = RoleData.Instance:GetAttr(ShopData.GetMoneyObjAttrIndex(money_type))
			if role_money_count >= money_count then
				self.node_t_list.double_consume_text.node:setColor(COLOR3B.GREEN)
			else
				self.node_t_list.double_consume_text.node:setColor(COLOR3B.RED)
			end	

			money_type , money_count = FuMoData.Instance:GetThreeGetConsume()
			self.node_t_list.three_consume_text.node:setString(Language.Task.Consume .. money_count .. ShopData.GetMoneyTypeName(money_type))

			role_money_count = RoleData.Instance:GetAttr(ShopData.GetMoneyObjAttrIndex(money_type))
			if role_money_count >= money_count then
				self.node_t_list.three_consume_text.node:setColor(COLOR3B.GREEN)
			else
				self.node_t_list.three_consume_text.node:setColor(COLOR3B.RED)
			end	
			
		else --进行中
			self.node_t_list.chuansong_btn.node:setVisible(true)
			self.node_t_list.layout_liji_finish.node:setVisible(true)
			self.node_t_list.btn_autoflush.node:setVisible(false)
			self.node_t_list.auto_flush_text.node:setVisible(false)

			money_type , money_count = FuMoData.Instance:GetLijiFinishConsume()
			self.node_t_list.liji_finish_consume_text.node:setString(Language.Task.Consume .. money_count .. ShopData.GetMoneyTypeName(money_type))
			self.node_t_list.liji_remain_text.node:setString(Language.Task.RewaedTask)
			self.node_t_list.liji_remain_text.node:setColor(COLOR3B.GREEN)

			role_money_count = RoleData.Instance:GetAttr(ShopData.GetMoneyObjAttrIndex(money_type))
			if role_money_count >= money_count then
				self.node_t_list.liji_finish_consume_text.node:setColor(COLOR3B.GREEN)
			else
				self.node_t_list.liji_finish_consume_text.node:setColor(COLOR3B.RED)
			end	
		end	
	else	
		self:Close()
	end	


	
	for i = 1,starlevel do
		self.node_t_list["img_star" .. i].node:loadTexture(ResPath.GetCommon("star_2_1"))
	end	
	for i = starlevel + 1, 10 do
		self.node_t_list["img_star" .. i].node:loadTexture(ResPath.GetCommon("star_2_2"))
	end	

end	

function FumoView:OnFlush(param_t, index)
	self:Clear()
	self:UpdatePanel()
end	

function FumoView:Clear()
	for i = 1,5 do
		self.awardList[i]:SetVisible(false)
	end	

	for i = 1,10 do
		self.node_t_list["img_star" .. i].node:loadTexture(ResPath.GetCommon("star_2_2"))
	end	
	RichTextUtil.ParseRichText(self.node_t_list.desc_rich_text.node,"")

	self.node_t_list.layout_get_task.node:setVisible(false)
	self.node_t_list.layout_liji_finish.node:setVisible(false)
	self.node_t_list.chuansong_btn.node:setVisible(false)

	self.node_t_list.layout_up_level.node:setVisible(false)
	self.node_t_list.max_level_text.node:setVisible(false)

	self.node_t_list.layout_award.node:setVisible(false)
	
end	



function FumoView:ParseDesc()
	self.rich_desc:removeAllElements()
	self.rich_desc_mark_t = {}


	if self.data.task_state == TaskState.Accept then
		if self.data.std_task.type == TaskType.Book then --伏魔任务

			local index_target = FuMoData.Instance.target_index + 1
			local target = self.data.std_task.target[index_target]
			if target.type == TaskTarget.Monster then
				local monster_info = ConfigManager.Instance:GetMonsterConfig(target.id)
				self:SetMyRichDesc(string.format(Language.Task.Target.Monster,  DelNumByString(monster_info.name)))
			elseif target.type == TaskTarget.SceneKillAnyMon then
				local scene_info = ConfigManager.Instance:GetSceneConfig(target.id)	
				self:SetMyRichDesc(string.format(Language.Task.Target.Monster, string.format(Language.Task.KillAnyMon,scene_info.name)))
				
			elseif target.type == TaskTarget.KillLevelMonster then	
				self:SetMyRichDesc(string.format(Language.Task.Target.Monster,  string.format(Language.Task.KillLevelMon,target.id)))
			end	
			self:FormatValue(0,target.count)
		end
	else
		local progress_info = self.data.progress_list[1] --当前进度值
		local target = self.data.std_task.target[progress_info.target_index] --配置目标值
		
		if target.type == TaskTarget.Monster then
			local monster_info = ConfigManager.Instance:GetMonsterConfig(target.id)
			self:SetMyRichDesc(string.format(Language.Task.Target.Monster,  DelNumByString(monster_info.name)))
		elseif target.type == TaskTarget.SceneKillAnyMon then
			local scene_info = ConfigManager.Instance:GetSceneConfig(target.id)	
			self:SetMyRichDesc(string.format(Language.Task.Target.Monster, string.format(Language.Task.KillAnyMon,scene_info.name)))
			
		elseif target.type == TaskTarget.KillLevelMonster then	
			self:SetMyRichDesc(string.format(Language.Task.Target.Monster,  string.format(Language.Task.KillLevelMon,target.id)))
		end	


		self:FormatValue(progress_info.cur_value,target.count)
	end
end

function FumoView:FormatValue(cur_value,target_value)
	if cur_value >= target_value then
		self:AddMyRichDesc(string.format("(%d/%d)", target_value, 
			target_value), nil, 20, COLOR3B.GREEN)
	else
		self:AddMyRichDesc(string.format("(%d/%d)", cur_value, 
			target_value), nil, 20, COLOR3B.WHITE)
	end
end

function FumoView:SetMyRichDesc(text)
	if nil == self.rich_desc then return end
	RichTextUtil.ParseRichText(self.rich_desc, text)
	self:SetRichDescMarkTable("text", text)
end

function FumoView:AddMyRichDesc(text, font, font_size, color)
	if nil == self.rich_desc then return end
	XUI.RichTextAddText(self.rich_desc, text, font, font_size, color)
	
	self:SetRichDescMarkTable("add_text", text)
	self:SetRichDescMarkTable("add_font", font)
	self:SetRichDescMarkTable("add_font_size", font_size)
	self:SetRichDescMarkTable("add_color", color)
end

-- index 	"text"/"add_text"/"add_font"/"add_font_size"/"add_color"
function FumoView:SetRichDescMarkTable(index, value)
	if nil == index then return end
	value = value or ""
	if not self.rich_desc_mark_t then self.rich_desc_mark_t = {} end
	self.rich_desc_mark_t[index] = value
end



------------------------------------------------------------------------
FumoRewardRender = FumoRewardRender or BaseClass(BaseRender)
function FumoRewardRender:__init()
	self.view:setContentWH(110, 110)
	self.item_cell = nil
	-- self.view:setBackGroundColor(COLOR3B.BLUE)
end

function FumoRewardRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function FumoRewardRender:CreateChild()
	BaseRender.CreateChild(self)

	self.item_cell =  BaseCell.New()
	self.item_cell:SetPosition(55, 65)
	self.item_cell:GetView():setAnchorPoint(0.5, 0.5)
	self.view:addChild(self.item_cell:GetView())

	self.text_count = XUI.CreateText(55, 15, 100, 20, cc.TEXT_ALIGNMENT_CENTER, "", nil, 20, COLOR3B.GREEN)
	self.view:addChild(self.text_count)
end

function FumoRewardRender:OnFlush()
	if nil == self.data then
		return
	end
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local starlevel = FuMoData.Instance.level
	local count = 0 
	if self.data.type == tagAwardType.qatAddExp then
		count = self.data.count * BookQuestConfig.flushLevelExpRate[starlevel]
		count = ItemData.Instance:GetExpInExpLib(level, 1, count, 0)
	else
		count = self.data.count * BookQuestConfig.flushLevelExpRate[starlevel]
	end
	self.text_count:setString("x"..count)

	if self.data.type == tagAwardType.qatEquipment then
		self.item_cell:SetData({["item_id"] = self.data.id, ["num"] = 0})
	else
		local virtual_item_id = ItemData.Instance:GetVirtualItemId(self.data.type)
		if virtual_item_id then
			self.item_cell:SetData({["item_id"] = virtual_item_id, ["num"] = 0, is_bind = 0})
		end
	end
end
