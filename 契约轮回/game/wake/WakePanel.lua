WakePanel = WakePanel or class("WakePanel",BasePanel)
local WakePanel = WakePanel
local tableInsert = table.insert

function WakePanel:ctor()
	self.abName = "wake"
	self.assetName = "WakePanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置

	self.is_show_money = { Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }    --是否显示钱

	self.win_type = 1								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.is_hide_other_panel = true
	self.model = WakeModel:GetInstance()

	self.attrib_list = {}
	self.task_list = {}
	self.ball_2_grid = {}
	self.pre_bg = ""
	self.ball_select = nil
	self.all_task_finish = false  --所有任务是否已完成
	self.equip_list = {}
end

function WakePanel:dctor()
end

function WakePanel:Open( )
	WakePanel.super.Open(self)
end

function WakePanel:LoadCallBack()
	self.nodes = {
		"bg",
		"right/TaskInfo","right/TaskInfo/steptitle","right/TaskInfo/TaskScrollView/Viewport/TaskContent",
		"model_img","right/TaskInfo/bottom/btnwakequick","right/TaskInfo/bottom/btnwake",
		"right/TaskInfo/bottom/btnnextstep","right/btn_close",
		"balls","title_img",
		"balls/ball_1","balls/ball_2","balls/ball_3","balls/ball_4","balls/ball_5","balls/ball_6","balls/ball_7","balls/ball_8",
		"balls/ball_9","balls/ball_10","balls/ball_11","balls/ball_12","balls/line_2","balls/line_3","balls/line_4","balls/line_5",
		"balls/line_6","balls/line_7","balls/line_8","balls/line_9","balls/line_10","balls/line_11","balls/line_12",
		"balls/bg/equip_tip",
		"bottom/ScrollView/Viewport/AttribContent","right",
		"right/InfoContent2","right/InfoContent2/heads/improve/head1","right/InfoContent2/heads/improve/head2",
		"right/InfoContent2/avatars/avatar_items/Viewport/AvatarContent",
		"right/InfoContent2/funs/fun_opens","right/InfoContent2/limits/all_desc/grid_title/open_grids",
		"right/InfoContent2/limits/all_desc/openleveltitle/openlevel2",
		"right/InfoContent2/limits/all_desc/limit_desc","right/InfoContent2/limits/wakebtn","right/InfoContent2/limits",
		"right/InfoContent2/wake_success2", "right/InfoContent2/avatars/avatar_items/Viewport/AvatarContent/WakeEquipItem",
		"right/InfoContent2/limits/all_desc","left", "left/left_content",
		"left/left_content/n1/item_title1","left/left_content/n1/item_icon1","left/left_content/n1/skill_name1",
		"left/left_content/n2/item_title2","left/left_content/n2/item_icon2","left/left_content/n2/skill_name2",
		"left/left_content/n3/item_title3","left/left_content/n3/item_icon3","left/left_content/n3/skill_name3",
		"left/left_content/n4/item_title4","left/left_content/n4/item_icon4","left/left_content/n4/skill_name4",
		"model_chenghao","bottom","left/left_content/wake_times",
		"money_con","right/TaskInfo/bottom/btnnextstep/Text",
		"title_img/effect",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	self.steptitle = GetText(self.steptitle)
	self.title_img = GetImage(self.title_img)
	self.btnnextstep = GetButton(self.btnnextstep)
	self.btnwake = GetButton(self.btnwake)
	self.equip_tip = GetText(self.equip_tip)
	self.NextText = GetText(self.Text)
	self.bg = GetImage(self.bg)
	self.item_title1 = GetImage(self.item_title1)
	self.item_title2 = GetImage(self.item_title2)
	self.item_title3 = GetImage(self.item_title3)
	self.item_title4 = GetImage(self.item_title4)
	self.item_icon1 = GetImage(self.item_icon1)
	self.item_icon2 = GetImage(self.item_icon2)
	self.item_icon3 = GetImage(self.item_icon3)
	self.item_icon4 = GetImage(self.item_icon4)
	self.skill_name1 = GetText(self.skill_name1)
	self.skill_name2 = GetText(self.skill_name2)
	self.skill_name3 = GetText(self.skill_name3)
	self.skill_name4 = GetText(self.skill_name4)
	self.wake_times = GetImage(self.wake_times)
	self.WakeEquipItem_gameobject = self.WakeEquipItem.gameObject
	SetVisible(self.WakeEquipItem_gameobject, false)
	self.fun_opens = GetText(self.fun_opens)
	self.limit_desc = GetText(self.limit_desc)
	self.open_grids = GetText(self.open_grids)
	self.openlevel2 = GetText(self.openlevel2)

	WakeController:GetInstance():RequestWakeTask()
	WakeController:GetInstance():RequestWakeGrid()
	--self:SetTileTextImage("wake_image", "img_title")
	self.ball_array = {self.ball_1,self.ball_2,self.ball_3,self.ball_4,self.ball_5,self.ball_6,self.ball_7,self.ball_8,self.ball_9,self.ball_10,self.ball_11,self.ball_12}
	self.line_array = {0,self.line_2,self.line_3,self.line_4,self.line_5,self.line_6,self.line_7,self.line_8,self.line_9,self.line_10,self.line_11,self.line_12}
	self:InitBalls()
	self.equip_tip.text = "It will have chance to get <color=#ded832>Sage Stone</color> by defeating and loot Lv.<color=#ded832>350</color> and above monsters"
	self.ball_effects = {}
	self:SetMoney(self.is_show_money)
	self.ui_effect = UIEffect(self.effect, 10311)
	self.textlayer = LayerManager:GetInstance():AddOrderIndexByCls(self,self.bottom.transform,nil,true,nil,nil,4)
	self.textlayer2 = LayerManager:GetInstance():AddOrderIndexByCls(self,self.model_img.transform,nil,true,nil,nil,4)
	self.textlayer3 = LayerManager:GetInstance():AddOrderIndexByCls(self,self.model_chenghao.transform,nil,true,nil,nil,4)

	SetAlignType(self.left.transform, bit.bor(AlignType.Left, AlignType.Null))
	SetAlignType(self.right.transform, bit.bor(AlignType.Right, AlignType.Null))
end

function WakePanel:InitBalls()
	for i=1, #self.ball_array do
		self.ball_2_grid[self.ball_array[i].transform] = i
		self.ball_array[i] = GetImage(self.ball_array[i])
	end
end

function WakePanel:SetMoney(list)
    if table.isempty(list) then
        return
    end

    if(#list > 3) then
        SetAnchoredPosition(self.money_con, 350, self.money_con_defaultPos.y )
    end

    self.money_list = {}
    local offx = 220
    for i = 1, #list do
        local item = MoneyItem(self.money_con, nil, list[i])
        local x = (i - #list) * offx
        local y = 0
        item:SetPosition(x, y)
        self.money_list[i] = item
    end
end

local lastX = 0
function WakePanel:AddEvent()

	local function call_back()
		self:UpdateTaskInfo()
	end
	self.event_id3 = self.model:AddListener(WakeEvent.UpdateWakeTasks, call_back)

	local function call_back(skill_id)
		--[[if FightConfig.SkillConfig[skill_id] then
			local action_name = FightConfig.SkillConfig[skill_id].action_name
			self.role_model:SetAnimation({action_name,"idle"},false,"idle",0)
		end--]]
	end
	self.event_id4 = self.model:AddListener(WakeEvent.ClickSkill, call_back)

	local function call_back()
		self:Close()
	end
	self.event_id5 = self.model:AddListener(WakeEvent.DoTask, call_back)

	local function call_back()
		--WakeController:GetInstance():RequestWakeTask()
		self:Close()
	end
	self.event_id6 = self.model:AddListener(WakeEvent.WakeSuccess, call_back)

	local function call_back()
		self:UpdateGrids()
	end
	self.event_id7 = self.model:AddListener(WakeEvent.UpdateWakeGrid, call_back)

	local function call_back(target,x,y)
		local key = self.model:GetWakeKey()
		local wakeitem = Config.db_wake[key]
		if RoleInfoModel:GetInstance():GetMainRoleLevel() < wakeitem.level then
			Notify.ShowText(ConfigLanguage.Wake.LevelNotEnough)
		else
			local wake = RoleInfoModel:GetInstance():GetRoleValue("wake")
			local cost = String2Table(Config.db_game["wake_cost"].val)[1][wake+1]
			local message = string.format(ConfigLanguage.Wake.WakeSureMessage, cost)
			Dialog.ShowTwo(ConfigLanguage.Wake.WakeSureTitle, message, nil, handler(self,self.WakeQuickly))
		end
	end
	AddButtonEvent(self.btnwakequick.gameObject,call_back)

	local function call_back(target,x,y)
		if not self.all_task_finish then
			Notify.ShowText(ConfigLanguage.Wake.TaskNotFinish)
		else
			WakeController:GetInstance():RequestWakeStart()
		end
	end
	AddButtonEvent(self.btnwake.gameObject,call_back)

	local function call_back(target,x,y)
		if not self.all_task_finish then
			Notify.ShowText(ConfigLanguage.Wake.TaskNotFinish)
		else
			WakeController:GetInstance():RequestGoNextStep()
		end
	end
	AddButtonEvent(self.btnnextstep.gameObject,call_back)

	local function call_back(target,x,y)
		self:Close()
	end
	AddButtonEvent(self.btn_close.gameObject,call_back)

	local function call_back(target,x,y)
		local level = RoleInfoModel:GetInstance():GetRoleValue("level")
		if level < 350 then
			return Notify.ShowText("This function unlocks at Lv.350")
		end
		local grid_id = self.ball_2_grid[target.transform]
		local grid_item = Config.db_wake_grid[grid_id]
		local panel = lua_panelMgr:GetPanelOrCreate(WakeGridTipsPanel)
		panel:SetData(grid_item)
		panel:Open(target)
	end
	AddClickEvent(self.ball_1.gameObject,call_back)
	AddClickEvent(self.ball_2.gameObject,call_back)
	AddClickEvent(self.ball_3.gameObject,call_back)
	AddClickEvent(self.ball_4.gameObject,call_back)
	AddClickEvent(self.ball_5.gameObject,call_back)
	AddClickEvent(self.ball_6.gameObject,call_back)
	AddClickEvent(self.ball_7.gameObject,call_back)
	AddClickEvent(self.ball_8.gameObject,call_back)
	AddClickEvent(self.ball_9.gameObject,call_back)
	AddClickEvent(self.ball_10.gameObject,call_back)
	AddClickEvent(self.ball_11.gameObject,call_back)
	AddClickEvent(self.ball_12.gameObject,call_back)

	local function call_back(target,x,y)
		WakeController:GetInstance():RequestWakeStart()
	end
	AddButtonEvent(self.wakebtn.gameObject,call_back)
end

function WakePanel:OpenCallBack()
	self:UpdateView()
end

function WakePanel:LoadModelCallBack()
	--[[SetLocalPosition(self.role_model.transform, -2012, -93, 320)
    local v3 = self.role_model.transform.localScale;
    --SetLocalScale(self.role_model.transform, 320, 320, 320);
    SetLocalRotation(self.role_model.transform, 3, 180, 1);--]]
end

--一键觉醒
function WakePanel:WakeQuickly()
	local wake = RoleInfoModel:GetInstance():GetRoleValue("wake")
	local cost = String2Table(Config.db_game["wake_cost"].val)[1][wake+1]
	local bo = RoleInfoModel:GetInstance():CheckGold(cost, Constant.GoldType.Gold)
	if not bo then
		return
	end
	WakeController:GetInstance():RequestWakeStart(1)
end

function WakePanel:UpdateView( )
	self:UpdateInfo()
end

function WakePanel:CloseCallBack(  )
	if self.role_model then
		self.role_model:destroy()
		self.role_model = nil
	end

	if self.textlayer then
		self.textlayer:destroy()
		self.textlayer = nil
	end
	if self.textlayer2 then
		self.textlayer2:destroy()
		self.textlayer2 = nil
	end
	if self.textlayer3 then
		self.textlayer3:destroy()
		self.textlayer3 = nil
	end

	for i=1, #self.money_list do
		self.money_list[i]:destroy()
	end
	self.money_list = nil

	for _, item in ipairs(self.attrib_list) do
		item:destroy()
	end
	for _, item in ipairs(self.task_list) do
		item:destroy()
	end
	if self.ui_effect then
		self.ui_effect:destroy()
		self.ui_effect = nil
	end

	for k, v in pairs(self.equip_list) do
		v:destroy()
	end
	self.equip_list = nil

	if self.goodsitem then
		self.goodsitem:destroy()
		self.goodsitem = nil
	end
	if self.goodsitem1 then
		self.goodsitem1:destroy()
		self.goodsitem1 = nil
	end

	if self.goodsitem2 then
		self.goodsitem2:destroy()
		self.goodsitem2 = nil
	end

	if self.skillitem then
		self.skillitem:destroy()
		self.skillitem = nil
	end
	if self.skillitem2 then
		self.skillitem2:destroy()
		self.skillitem2 = nil
	end
	if self.skillitem3 then
		self.skillitem3:destroy()
		self.skillitem3 = nil
	end

	if self.head_item1 then
		self.head_item1:destroy()
	end
	self.head_item1 = nil

	if self.head_item2 then
		self.head_item2:destroy()
	end
	self.head_item2 = nil

	if self.event_id then
		self.model:RemoveListener(self.event_id)
	end
	if self.event_id2 then
		self.model:RemoveListener(self.event_id2)
	end
	if self.event_id3 then
		self.model:RemoveListener(self.event_id3)
	end
	if self.event_id4 then
		self.model:RemoveListener(self.event_id4)
	end
	if self.event_id5 then
		self.model:RemoveListener(self.event_id5)
	end
	if self.event_id6 then
		self.model:RemoveListener(self.event_id6)
	end
	if self.event_id7 then
		self.model:RemoveListener(self.event_id7)
	end

	if self.reddot then
		self.reddot:destroy()
	end
	self.reddot = nil
	if self.reddot_next then
		self.reddot_next:destroy()
	end
	self.reddot_next = nil
	if self.reddot_wake then
		self.reddot_wake:destroy()
	end
	self.reddot_wake = nil

	if self.reddot_wake2 then
		self.reddot_wake2:destroy()
	end
	self.reddot_wake2 = nil

	if self.ball_select then
		self.ball_select:destroy()
	end
	self.ball_select = nil

	for k, v in pairs(self.ball_effects) do
		v:destroy()
	end
	self.ball_effects = nil
	self.ball_array = nil
	self.line_array = nil
end

function WakePanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
	--if self.table_index == 1 then
		-- if not self.show_panel then
		-- 	self.show_panel = ChildPanel(self.transform)
		-- end
		-- self:PopUpChild(self.show_panel)
	--end
end

function WakePanel:UpdateInfo()
	local wake = RoleInfoModel:GetInstance():GetRoleValue("wake")
	local role_level = RoleInfoModel:GetInstance():GetMainRoleLevel()
	local key = self.model:GetWakeKey()
	local wakeitem = Config.db_wake[key]
	local pre_key = self.model.GetWakeNowKey()
	local pre_attribs = String2Table(Config.db_wake[pre_key].attribs)

	lua_resMgr:SetImageTexture(self,self.title_img, 'wake_image', string.format("wake_title%s", wake+1))
	lua_resMgr:SetImageTexture(self,self.wake_times, 'wake_image', string.format("wake%s", wake+1))
	for k, attrib in ipairs(String2Table(wakeitem.attribs)) do
		local item = self.attrib_list[k] or WakeAttribItem(self.AttribContent)
		item:SetData(pre_attribs[k] or {}, attrib)
		self.attrib_list[k] = item
	end

	SetVisible(self.taskinfo, true)
	if wake == 0 then
		SetVisible(self.model_img, false)
		SetVisible(self.model_chenghao, true)
		SetVisible(self.title_img, true)
		local skill = String2Table(wakeitem.skills)[1]
		local skill_id = skill[1]
		if not self.skillitem then
			self.skillitem = WakeSkillItem(self.item_icon1.transform)
		end
		self.skillitem:SetData(skill_id, skill[2])
		self.skill_name2.text = "T5 T6"
		lua_resMgr:SetImageTexture(self,self.item_icon2, 'wake_image', 'wake_zhuangbei')
		local shows = String2Table(wakeitem.show)
		local show1 = shows[1]
		local show2 = shows[2]
		local param = {}
		param["item_id"] = show1[1]
		param["can_click"] = true
		param["bind"] = 2
		if not self.goodsitem1 then
			self.goodsitem1 = GoodsIconSettorTwo(self.item_icon3.transform)
		end
		self.goodsitem1:SetIcon(param)
		self.skill_name3.text = Config.db_item[show1[1]].name
		param = {}
		param["item_id"] = show2[1]
		param["can_click"] = true
		param["bind"] = 2
		if not self.goodsitem2 then
			self.goodsitem2 = GoodsIconSettorTwo(self.item_icon4.transform)
		end
		self.goodsitem2:SetIcon(param)
		self.skill_name4.text = Config.db_item[show2[1]].name
		self:PlayAni()
	elseif wake == 1 then
		SetVisible(self.model_img, true)
		SetVisible(self.model_chenghao, false)
		SetVisible(self.title_img, true)
		if self.role_model then
			self.role_model:destroy()
		end
		local cfg = {}
	    cfg.pos = {x = -2001, y = -322, z = 300}
	    cfg.carmera_size = 5
	    cfg.trans_x = 1000
	    cfg.trans_y = 1000
	    self.role_model = UIModelCommonCamera(self.model_img, nil, wakeitem.res, nil, false)
	    self.role_model:SetConfig(cfg)
	    lua_resMgr:SetImageTexture(self,self.item_title1, 'wake_image', 'open_sys')
	    lua_resMgr:SetImageTexture(self,self.item_title2, 'wake_image', 'open_skill')
	    lua_resMgr:SetImageTexture(self,self.item_title3, 'wake_image', 'skill_strong')
	    lua_resMgr:SetImageTexture(self,self.item_title4, 'wake_image', 'open_skill')
	    lua_resMgr:SetImageTexture(self,self.item_icon1, 'main_image', 'btn_main_god')
	    self.skill_name1.text = "Assisting Avatar"

	    local skills = String2Table(wakeitem.skills)
	    if not self.skillitem then
	    	self.skillitem = WakeSkillItem(self.item_icon2.transform)
	    end
	    self.skillitem:SetData(skills[1][1], skills[1][2])
	    if not self.skillitem2 then
	    	self.skillitem2 = WakeSkillItem(self.item_icon3.transform)
	    end
	    self.skillitem2:SetData(skills[2][1], skills[2][2])
	    if not self.skillitem3 then
	    	self.skillitem3 = WakeSkillItem(self.item_icon4.transform)
	    end
	    self.skillitem3:SetData(skills[3][1], skills[3][2])
	elseif wake == 2 then
		SetVisible(self.model_img, true)
		SetVisible(self.model_chenghao, false)
		SetVisible(self.title_img, true)
		if self.role_model then
			self.role_model:destroy()
		end
		local cfg = {}
	    cfg.pos = {x = -2001, y = -241.7, z = 300}
	    cfg.carmera_size = 2.2
	    self.role_model = UIModelCommonCamera(self.model_img, nil, wakeitem.res, nil, false)
	    self.role_model:SetConfig(cfg)
	    lua_resMgr:SetImageTexture(self,self.item_title1, 'wake_image', 'open_god')
	    lua_resMgr:SetImageTexture(self,self.item_title2, 'wake_image', 'open_skill')
	    lua_resMgr:SetImageTexture(self,self.item_title3, 'wake_image', 'open_skill')
	    lua_resMgr:SetImageTexture(self,self.item_title4, 'wake_image', 'skill_strong')
	    param = {}
		param["item_id"] = 55402
		param["can_click"] = true
		param["bind"] = 2
	    if not self.goodsitem then
	    	self.goodsitem = GoodsIconSettorTwo(self.item_icon1.transform)
	    end
	    self.goodsitem:SetIcon(param)
	    self.skill_name1.text = Config.db_item[55402].name
	    local skills = String2Table(wakeitem.skills)
	    if not self.skillitem then
	    	self.skillitem = WakeSkillItem(self.item_icon2.transform)
	    end
	    self.skillitem:SetData(skills[1][1], skills[1][2])
	    if not self.skillitem2 then
	    	self.skillitem2 = WakeSkillItem(self.item_icon3.transform)
	    end
	    self.skillitem2:SetData(skills[2][1], skills[2][2])
	    if not self.skillitem3 then
	    	self.skillitem3 = WakeSkillItem(self.item_icon4.transform)
	    end
	    self.skillitem3:SetData(skills[3][1], skills[3][2])
	elseif wake == 3 then
		SetVisible(self.model_img, false)
		SetVisible(self.model_chenghao, false)
		SetVisible(self.title_img, false)
		SetVisible(self.bottom, false)
		SetVisible(self.left_content, false)
	end
	self:ShowModelGrid(wakeitem.wake_times)
end

function WakePanel:PlayAni()
    local action = cc.MoveTo(1, -130.1, 16.91)
    action = cc.Sequence(action, cc.MoveTo(1, -130.1, -23.3))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.model_chenghao.transform)
end

function WakePanel:UpdateTaskInfo()
	local waketimes = RoleInfoModel:GetInstance():GetRoleValue("wake") + 1
	if waketimes >= 4 then
		return
	end
	local career = RoleInfoModel:GetInstance():GetRoleValue("career")
	local key = career .. "@" .. waketimes
	local wakeitem = Config.db_wake[key]
	if not wakeitem then
		return
	end
	local cur_step = self.model:GetWakeStep()
	self.steptitle.text = string.format(ConfigLanguage.Wake.StepTitle, cur_step, wakeitem.step)
	local tasks = self.model:GetWakeTasks()
	local key2 = waketimes .. "@" .. cur_step
	local wakestep = Config.db_wake_step[key2]
	local step_task_ids = String2Table(wakestep.tasks)
	local function sort_task(a, b)
		local status1 = self.model:GetTaskStatus(a) or 0
		local status2 = self.model:GetTaskStatus(b) or 0
		return status1 < status2
	end
	table.sort(step_task_ids, sort_task)
	--显示任务
	local flag = true
	local finish_count = 0
	for k, id in ipairs(step_task_ids) do
		local item = self.task_list[k] or WakeTaskItem(self.TaskContent)
		local status = tasks[id] or 0
		item:SetData(id, status)
		if flag and status ~= 1 then
			flag = false
		end
		if status == 1 then
			finish_count = finish_count + 1
		end
		self.task_list[k] = item
	end
	if #self.task_list > #step_task_ids then
		for i=#self.task_list, #step_task_ids+1, -1 do
			self.task_list[i]:destroy()
		end
	end
	self.NextText.text = string.format("Next phase (%s/%s)", finish_count, #step_task_ids)
	self.all_task_finish = flag
	if cur_step < wakeitem.step then
		SetVisible(self.btnnextstep, true)
		SetVisible(self.btnwake, false)
	else
		SetVisible(self.btnnextstep, false)
		SetVisible(self.btnwake, true)
	end
	if self.all_task_finish then
		self.btnnextstep.interactable = true
		self.btnwake.interactable = true
		if not self.reddot_next then
			self.reddot_next = RedDot(self.btnnextstep.transform)
			self:SetRedDot(self.reddot_next, 55, 14)
		end
		if not self.reddot_wake then
			self.reddot_wake = RedDot(self.btnwake.transform)
			self:SetRedDot(self.reddot_wake, 55, 14)
		end
	else
		self.btnnextstep.interactable = disable
		self.btnwake.interactable = disable
		if self.reddot_next then
			SetVisible(self.reddot_next, false)
		end
		if self.reddot_wake then
			SetVisible(self.reddot_wake, false)
		end
	end
end

function WakePanel:ShowModelGrid(wake_times)
	if wake_times <= 3 then
		SetVisible(self.model_img, true)
		SetVisible(self.balls, false)
	else
		SetVisible(self.model_img, false)
		SetVisible(self.balls, true)
	end
	self:UpdateBg()
	self:ShowInfoContent()
end

function WakePanel:ShowInfoContent()
	local wake = RoleInfoModel:GetInstance():GetRoleValue("wake")
	if wake < 3 then
		SetVisible(self.TaskInfo, true)
		SetVisible(self.InfoContent2, false)
	else
		SetVisible(self.InfoContent2, true)
		SetVisible(self.TaskInfo, false)
		self:UpdateInfoContent2()
	end
end

function WakePanel:UpdateBg()
	local key = self.model:GetWakeKey()
	local wakeitem = Config.db_wake[key]
	local res = wakeitem.background
	if self.pre_bg ~= res then
		self.pre_bg = res
		lua_resMgr:SetImageTexture(self,self.bg, "iconasset/icon_big_bg_"..res, res)
	end
end

function WakePanel:UpdateGrids()
	for i=2, #self.line_array do
		SetVisible(self.line_array[i], false)
	end
	if self.model.grid_id > 0 then
		for i=1, self.model.grid_id do
			lua_resMgr:SetImageTexture(self,self.ball_array[i], 'wake_image', 'ball')
			if not self.ball_effects[i] then
				self.ball_effects[i] = UIEffect(self.ball_array[i].transform, 10122)
			end
			if i >= 2 then
				SetVisible(self.line_array[i], true)
			end
		end
	end
	if self.ball_select then
		self.ball_select:destroy()
	end
	if self.model.grid_id + 1 <= 12 then
		self.ball_select = WakeBallSelectItem(self.ball_array[self.model.grid_id+1].transform)
	end
	self:UpdateInfoContent2()
end

--更新4觉界面
function WakePanel:UpdateInfoContent2()
	local key = self.model:GetWakeKey()
	local wakeitem = Config.db_wake[key]
	if wakeitem.wake_times < 4 then
		return
	end
	if not self.head_item1 then
		self.head_item1 = WakeHeadItem(self.head1)
		local arr = string.split(key,"@")
		local key = arr[1] .. "@" .. (tonumber(arr[2]) -1)
		self.head_item1:SetData(Config.db_wake[key])
	end
	if not self.head_item2 then
		self.head_item2 = WakeHeadItem(self.head2)
		self.head_item2:SetData(Config.db_wake[key])
	end
	local equips = String2Table(wakeitem.show)
	for i=1, #self.equip_list do
		self.equip_list[i]:destroy()
	end
	self.equip_list = {}
	for i=1, #equips do
		local equip = equips[i]
		local item_id = equip[1]
		local item = WakeEquipItem(self.WakeEquipItem_gameobject, self.AvatarContent)
		item:SetData(item_id)
		self.equip_list[i] = item
	end
	self.fun_opens.text = wakeitem.desc
	local waketimes = RoleInfoModel:GetInstance():GetRoleValue("wake")
	if waketimes >= wakeitem.wake_times then
		SetVisible(self.limits, false)
		SetVisible(self.wake_success2, true)
	else
		SetVisible(self.limits, true)
		SetVisible(self.wake_success2, false)
		if self.model.grid_id >= 12 then
			self.open_grids.text = string.format(ConfigLanguage.Wake.EnoughTwo, self.model.grid_id, 12)
		else
			self.open_grids.text = string.format(ConfigLanguage.Wake.NotEnoughTwo, self.model.grid_id, 12)
		end
		local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
		if level >= wakeitem.level then
			self.openlevel2.text = string.format(ConfigLanguage.Wake.EnoughTwo, level, wakeitem.level)
		else
			self.openlevel2.text = string.format(ConfigLanguage.Wake.NotEnoughTwo, level, wakeitem.level)
		end
		self.limit_desc.text = "The level limit before the 4th awakening is" .. wakeitem.level
		if self.model.grid_id >= 12 and level >= wakeitem.level then
			SetVisible(self.wakebtn, true)
			SetVisible(self.all_desc, false)
			if not self.reddot_wake2 then
				self.reddot_wake2 = RedDot(self.wakebtn)
				self:SetRedDot(self.reddot_wake2, 55, 14)
			end
		else
			SetVisible(self.wakebtn, false)
			SetVisible(self.all_desc, true)
		end
	end
end

function WakePanel:SetRedDot(reddot, x, y)
	SetLocalPosition(reddot.transform, x, y)
	SetVisible(reddot, true)
end

