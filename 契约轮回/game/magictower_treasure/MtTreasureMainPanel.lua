--
-- @Author: LaoY
-- @Date:   2018-12-21 21:43:43
--
MtTreasureMainPanel = MtTreasureMainPanel or class("MtTreasureMainPanel",BasePanel)

function MtTreasureMainPanel:ctor()
	self.abName = "magictower_treasure"
	self.assetName = "MtTreasureMainPanel"
	self.layer = "Bottom"

	self.use_background = false
	self.change_scene_close = true

	self.switch_state = false

	self.model = MagictowerTreasureModel:GetInstance()
	self.model_event_list = {}
	self.global_event_list = {}
	self.icon_list = {}
end

function MtTreasureMainPanel:dctor()
	self:StopTime()
	self:StopLastTime()

	if self.model_event_list then
		self.model:RemoveTabListener(self.model_event_list)
		self.model_event_list = {}
	end

	if self.global_event_list then
		GlobalEvent:RemoveTabListener(self.global_event_list)
		self.global_event_list = {}
	end

	self.icon_list = nil
end

function MtTreasureMainPanel:Open(show_type)
	self.show_type = show_type
	self.show_type = 2
	MtTreasureMainPanel.super.Open(self)
end

function MtTreasureMainPanel:LoadCallBack()
	self.nodes = {
		"right_con",
		"right_con/select_con/text_time",
		"right_con/select_con/btn_monster_2",
		"right_con/select_con/btn_monster_4",
		"right_con/select_con/btn_monster_1",
		"right_con/select_con/img_bg",
		"right_con/select_con",
		"right_con/select_con/btn_monster_3",
		"right_con/select_con/btn_switch",
		"btn_con/btn_hide","btn_con","btn_con/btn_go","btn_con/btn_go/text_last_time",

		"right_con/select_con/img_sel",
	}
	self:GetChildren(self.nodes)
	-- LayerManager:GetInstance():AddOrderIndexByCls(self,self.right_con,nil,true,nil,true,40)
	SetAlignType(self.right_con,bit.bor(AlignType.Right, AlignType.Null))
	SetAlignType(self.btn_con,bit.bor(AlignType.Bottom, AlignType.Null))

	self.btn_hide_component = self.btn_hide:GetComponent('Image')

	-- select_con
	self.text_time_component = self.text_time:GetComponent('Text')
	self.text_last_time_component = self.text_last_time:GetComponent('Text')
	self.btn_monster_1_component = self.btn_monster_1:GetComponent('Image')
	self.btn_monster_2_component = self.btn_monster_2:GetComponent('Image')
	self.btn_monster_3_component = self.btn_monster_3:GetComponent('Image')
	self.btn_monster_4_component = self.btn_monster_4:GetComponent('Image')

	-- self.text_time_1:GetComponent('Text')

	--start con
	-- self.text_start_des_1_component = self.text_start_des_1:GetComponent('Text')
	-- self.text_start_des_1_component.text = "灵魂值"

	-- self.text_start_des_2_component = self.text_start_des_2:GetComponent('Text')
	-- self.text_start_des_2_component.text = "有机会获得各种精灵碎片，必得火焰、清水、或蕴风碎片。"

	-- self.text_value_component = self.text_value:GetComponent('Text')
	-- self.scrollbar_component = self.scrollbar:GetComponent('Scrollbar')
	-- self.scrollbar_component.size = 0.5

	-- self.text_btn_1:GetComponent('Text').text = "普通狩猎"
	-- self.text_btn_10:GetComponent('Text').text = "高级狩猎"

	-- self.text_cost_1_component = self.text_cost_1:GetComponent('Text')
	-- self.text_cost_10_component = self.text_cost_10:GetComponent('Text')

	self.icon_list[1] = self.btn_monster_1
	self.icon_list[2] = self.btn_monster_2
	self.icon_list[3] = self.btn_monster_3
	self.icon_list[4] = self.btn_monster_4

	self:SetSwitchRes()

	self:AddEvent()

	if self.model.select_index ~= nil then
		self:StartAction(true)
	end

	self:UpdateBtnConVisible()
end

function MtTreasureMainPanel:AddEvent()
	local function call_back(target,x,y)
		self:StartAction(not self.switch_state)
	end
	AddClickEvent(self.btn_switch.gameObject,call_back)

	-- select con
	local function call_back(target,x,y)
		-- Notify.ShowText(1)
		if self.model:FindIndex(1) then
			
		end
	end
	AddClickEvent(self.btn_monster_1.gameObject,call_back)

	local function call_back(target,x,y)
		-- Notify.ShowText(2)
		if self.model:FindIndex(2) then
			
		end
	end
	AddClickEvent(self.btn_monster_2.gameObject,call_back)

	local function call_back(target,x,y)
		-- Notify.ShowText(3)
		if self.model:FindIndex(3) then
			
		end
	end
	AddClickEvent(self.btn_monster_3.gameObject,call_back)

	local function call_back(target,x,y)
		-- Notify.ShowText(4)
		if self.model:FindIndex(4) then
			
		end
	end
	AddClickEvent(self.btn_monster_4.gameObject,call_back)

	-- start con
	local function call_back(target,x,y)
		-- Notify.ShowText("add")
		lua_panelMgr:OpenPanel(ShopPanel)
	end
	-- AddClickEvent(self.btn_add.gameObject,call_back)

	-- local function call_back(target,x,y)
	-- 	if self.model.mt_treasure_info.dig ~= 0 then
	-- 		Dialog.ShowOne("提示","您正在魔法卡寻宝中，请先完成当前的寻宝","确定",nil,10)
	-- 		return
	-- 	end
	-- 	local function ok_func()
	-- 		self.model:Brocast(MagictowerTreasureEvent.REQ_HUNT,1)
	-- 		self:Close()
	-- 	end
	-- 	self.model:CheckGoods(self.cost_1,ok_func)
	-- end
	-- AddClickEvent(self.btn_1.gameObject,call_back)

	-- local function call_back(target,x,y)
	-- 	if self.model.mt_treasure_info.dig ~= 0 then
	-- 		Dialog.ShowOne("提示","您正在魔法卡寻宝中，请先完成当前的寻宝","确定",nil,10)
	-- 		return
	-- 	end
	-- 	local function ok_func()
	-- 		self.model:Brocast(MagictowerTreasureEvent.REQ_HUNT,2)
	-- 		self:Close()
	-- 	end
	-- 	self.model:CheckGoods(self.cost_2,ok_func)
	-- end
	-- AddClickEvent(self.btn_10.gameObject,call_back)

	local function call_back(target,x,y)
		self:StartAction(not self.switch_state)
	end
	AddClickEvent(self.btn_hide.gameObject,call_back)

	local function call_back(target,x,y)
		self.model:FindIndex(self.model.select_index or 1)
	end
	AddClickEvent(self.btn_go.gameObject,call_back)


	local function call_back(index)
		self:StartAction(true)
		self:ResetResIndex()
	end
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.SelectIndex, call_back)

	local function time_out_func()
		self:Close()
	end
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.TimeOut, time_out_func)

	local function call_back()
		self:Close()
	end
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.ACC_DIG, call_back)

	local function ON_ACC_STAT()
		self:Close()
	end
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.ACC_STAT, ON_ACC_STAT)

	local function call_back(id)
		self:SetValue()
	end
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.UpdatePower, call_back)

	local function call_back(id)
		self:SetValue()
	end
	self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MagictowerTreasureEvent.ACC_INFO, call_back)

	local function call_back()
		self:UpdateBtnConVisible()
	end
	self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
end

function MtTreasureMainPanel:SetValue()
	local id = enum.ITEM.ITEM_MC_HUNT
	if not self.model.mt_treasure_info then
		return
	end
	local value = self.model.mt_treasure_info.power
	if self.goods_value == value then
		return
	end

	self.goods_value = value
	-- local percent = math.min(self.goods_value/MtTreasureConstant.StarPowerMax,1)
	-- self.scrollbar_component.size = percent
	-- self.text_value_component.text = string.format("%s/%s",self.goods_value,MtTreasureConstant.StarPowerMax)
end

function MtTreasureMainPanel:UpdateBtnConVisible()
	local scene_id = SceneManager:GetInstance():GetSceneId()
	local cf = Config.db_scene[scene_id]
	if cf and (cf.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE or cf.type == enum.SCENE_TYPE.SCENE_TYPE_ACT) then
		SetVisible(self.btn_con,false)
	else
		SetVisible(self.btn_con,true)
	end
end

-- 设置高亮
function MtTreasureMainPanel:ResetResIndex()
	local select_index = self.model.select_index
	if not select_index then
		SetVisible(self.img_sel,false)
		return
	end
	if self.last_index == select_index then
		return
	end
	SetVisible(self.img_sel,true)
	self.last_index = self.index
	self.index = select_index
	self:SetIndexRes(self.index)
	Yzprint('--LaoY MtTreasureMainPanel.lua,line 238--',self.index,self.icon_list[self.index])
end

function MtTreasureMainPanel:SetIndexRes(index)
	-- local abName = 'magictower_treasure_image'
	-- local assetName = flag and "img_magic_monster_icon_" or "img_magic_monster_icon_"
	-- assetName = assetName .. index
	-- local key = string.format("btn_monster_%s_component",index)
	-- local component = self[key]
	-- if not component then
	-- 	return
	-- end
	-- lua_resMgr:SetImageTexture(self,component, abName, assetName,false)

	local icon = self.icon_list[index]
	if not icon then
		return
	end
	self.img_sel:SetParent(icon)

	SetLocalPosition(self.img_sel,0,0,0)
end

function MtTreasureMainPanel:SetSwitchRes()
	-- local abName = 'magictower_treasure_image'
	-- local assetName = self.switch_state and "btn_switch_2" or "btn_switch_1"
	-- if self.switch_assetName == assetName then 
	-- 	return 
	-- end
	-- self.switch_assetName = assetName
	-- lua_resMgr:SetImageTexture(self,self.btn_hide_component, abName, assetName,true)

	-- SetVisible(self.btn_hide,self.switch_state)
end

-- true 移动到屏幕外
function MtTreasureMainPanel:StartAction(flag)
	if self.switch_state == flag then
		return
	end
	self.switch_state = flag
	self:SetSwitchRes()
	local time = 0.5
	local rate = 1.0
	if self.action then
		local progress = self.action:getProgress()
		rate = progress == 0 and rate or progress
		self:RemoveAction()
	end
	time = time * rate
	local action
	local select_action
	if flag then
		action = cc.MoveTo(time,575,0)
		select_action = cc.MoveTo(time,462,0)
	else
		action = cc.MoveTo(time,0,0)
		select_action = cc.MoveTo(time,0,0)
	end
	local function call_back()
		if flag and self.show_type == 1 then
			self:Close()
		end
	end
	action = cc.Sequence(action,cc.CallFunc(call_back))
	cc.ActionManager:GetInstance():addAction(select_action,self.select_con)
	-- cc.ActionManager:GetInstance():addAction(action,self.start_con)
	self.action = action

	-- local rotate = self.switch_state and 180 or 0
	-- local switch_action = cc.RotateTo(time,rotate)
	-- cc.ActionManager:GetInstance():addAction(switch_action,self.btn_switch)
end

function MtTreasureMainPanel:RemoveAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.select_con)
	-- cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.start_con)
	-- cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.btn_switch)
end

function MtTreasureMainPanel:OpenCallBack()
	self:UpdateView()
	if self.switch_state then
		self:StartAction(not self.switch_state)
	end
end

function MtTreasureMainPanel:UpdateView()
	if not self.model.mt_treasure_info then
		return
	end
	if self.show_type == 1 then
		self:StopTime()
		SetVisible(self.select_con,false)
		SetVisible(self.start_con,false)
		self:UpdateStartInfo()
		self:SetValue()
	else
		SetVisible(self.select_con,true)
		SetVisible(self.start_con,false)
		self:StartTime()
	end

	self:StartLastTime()
	self:ResetResIndex()
end

function MtTreasureMainPanel:UpdateStartInfo()
	local cf_1 = Config.db_mchunt[1]
	local cf_2 = Config.db_mchunt[2]

	local cost_1 = String2Table(cf_1.cost)[1]
	local cost_2 = String2Table(cf_2.cost)[1]
	self.cost_1 = cost_1[2]
	self.cost_2 = cost_2[2]

	-- local item_cf = Config.db_item[cost_1[1]]
	-- local str_1 = string.format('<color=#%s>%sx%s</color>',ColorUtil.GetColor(item_cf.color),item_cf.name,cost_1[2])
	-- self.text_cost_1_component.text = str_1

	-- local item_cf = Config.db_item[cost_2[1]]
	-- local str_2 = string.format('<color=#%s>%sx%s</color>',ColorUtil.GetColor(item_cf.color),item_cf.name,cost_2[2])
	-- self.text_cost_10_component.text = str_2
end

function MtTreasureMainPanel:StartTime()
	self:StopTime()
	local end_time = self.model.mt_treasure_info.etime
	local function step()
		local cur_time = os.time()
		if end_time - cur_time >= 0 then
			local data = TimeManager:GetLastTimeData(cur_time,end_time)
			if data then
				local str = string.format(  "Please select an objective：<color=#f5792e>%02d:%02d</color>",data.min or 0,data.sec)
				self.text_time_component.text = str
			end
		else
			self:StopTime()
			-- Notify.ShowText("倒计时结束")
			-- self:Close()
		end
	end
	self.time_id = GlobalSchedule:Start(step,1.0)
	step()
end

function MtTreasureMainPanel:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.time_id = nil
	end
end

function MtTreasureMainPanel:StartLastTime()
	self:StopLastTime()
	local end_time = self.model.mt_treasure_info.etime
	local function step()
		local cur_time = os.time()
		if end_time - cur_time >= 0 then
			local data = TimeManager:GetLastTimeData(cur_time,end_time)
			if data then
				local str = string.format("%02d:%02d",data.min or 0,data.sec)
				self.text_last_time_component.text = str
			end
		else
			self:StopLastTime()
			-- self:Close()
		end
	end
	self.btn_last_time_id = GlobalSchedule:Start(step,1.0)
	step()
end

function MtTreasureMainPanel:StopLastTime()
	if self.btn_last_time_id then
		GlobalSchedule:Stop(self.btn_last_time_id)
		self.btn_last_time_id = nil
	end
end

function MtTreasureMainPanel:CloseCallBack(  )

end