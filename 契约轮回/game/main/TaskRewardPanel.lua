--
-- @Author: LaoY
-- @Date:   2018-12-06 11:32:27
--
TaskRewardPanel = TaskRewardPanel or class("TaskRewardPanel",WindowPanel)
local TaskRewardPanel = TaskRewardPanel

function TaskRewardPanel:ctor()
	self.abName = "main"
	self.assetName = "TaskRewardPanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 4								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false						--是否显示侧边栏
	self.table_index = nil
	self.model = TaskModel:GetInstance()
	self.item_list = {}
end

function TaskRewardPanel:dctor()
	self:StopTime()

	for k,item in pairs(self.item_list) do
		item:destroy()
	end
	self.item_list = {}
end

function TaskRewardPanel:Open(task_id)
	self.task_id = task_id
	self.end_time = os.time() + 10
	TaskRewardPanel.super.Open(self)
end

function TaskRewardPanel:LoadCallBack()
	self:SetTileTextImage(self.abName .. "_image","img_text_task_title")
	
	self.nodes = {
		"btn_sure/btn_text","scroll/Viewport/Content","text_des","TaskRewardItem","scroll","btn_sure","text_des_nor"
	}
	self:GetChildren(self.nodes)
	self.btn_text_component = self.btn_text:GetComponent('Text')

	self.text_des_component = self.text_des:GetComponent('Text')
	self.text_des_nor_component = self.text_des_nor:GetComponent('Text')
	SetVisible(self.TaskRewardItem,false)
	self.TaskRewardItem_gameObject = self.TaskRewardItem.gameObject
	self:AddEvent()
end

function TaskRewardPanel:AddEvent()
	local function call_back(target,x,y)
		self:OnClick()
	end
	AddClickEvent(self.btn_sure.gameObject,call_back)
end

function TaskRewardPanel:OnClick()
	self.model:Brocast(TaskEvent.ReqTaskSubmit,self.task_id)
	self:Close()
end

function TaskRewardPanel:OpenCallBack()
	self:UpdateView()
	self:StartTime()
end

function TaskRewardPanel:StartTime()
	self:StopTime()
	local function step()
		local last_time = self.end_time - os.time()
		local str  = string.format("OK (%s)",last_time)
		self.btn_text_component.text = str
		if last_time <= 0 then
			self:StopTime()
			self:OnClick()
			return
		end
	end
	step()
	self.time_id = GlobalSchedule:Start(step,1.0)
end

function TaskRewardPanel:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
	end
end

function TaskRewardPanel:UpdateView( )
	local config = Config.db_task[self.task_id]
	local task_type = enum.TASK_TYPE.TASK_TYPE_DAILY
	if config.type == enum.TASK_TYPE.TASK_TYPE_LOOP1 then
		SetVisible(self.text_des,false)
		SetVisible(self.text_des_nor,true)
		self.text_des_nor_component.text = "Congratulations, you finished 20 Daily Loop Quests!"
	elseif config.type == enum.TASK_TYPE.TASK_TYPE_LOOP2 then
		task_type = enum.TASK_TYPE.TASK_TYPE_GUILD
		SetVisible(self.text_des,true)
		SetVisible(self.text_des_nor,false)
		local str = [[
		恭喜您ObtainedGuildQuest每10环额外Reward！  
	  	本everyFinishAttempts:10/100
	  	（每every100环GuildQuest，Monday凌晨0Points整重置）
		]]
		self.text_des_component = str
	end

	local reward_cf = TaskModel:GetInstance():GetLoopReward(task_type)
	if not reward_cf then
		return
	end
	local list = String2Table(reward_cf.extra_reward)
	for i=1, #list do
		local item = self.item_list[i]
		if not item then
			item = TaskRewardItem(self.TaskRewardItem_gameObject,self.Content,self.layer)
			self.item_list[i] = item
			local x = 0
			local y = -(i-1) * 150
		end
		item:SetData(i,list[i])
	end
end

function TaskRewardPanel:CloseCallBack(  )

end

function TaskRewardPanel:SwitchCallBack(index)
	
end