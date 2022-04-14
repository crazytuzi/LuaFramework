-- 
-- @Author: LaoY
-- @Date:   2018-09-11 10:46:20
-- 
MainCollectPanel = MainCollectPanel or class("MainCollectPanel",BasePanel)
local MainCollectPanel = MainCollectPanel
local math_min = math.min
function MainCollectPanel:ctor()
	self.abName = "main"
	self.assetName = "MainCollectPanel"
	self.layer = LayerManager.LayerNameList.Bottom

	self.use_background = false
	self.change_scene_close = false

	self.last_check = Time.time

	self:AddEvent()
end

function MainCollectPanel:dctor()
	self:StopTime()

	if self.event_id_1 then
		GlobalEvent:RemoveListener(self.event_id_1)
		self.event_id_1 = nil
	end

	if self.event_id_2 then
		GlobalEvent:RemoveListener(self.event_id_2)
		self.event_id_2 = nil
	end
end

function MainCollectPanel:Open(uid,total_time)
	self.total_time = total_time
	self.target_id = uid
	if not self.target_id then
		return
	end
	-- Yzprint('--LaoY MainCollectPanel.lua,line 37-- data=',data)

	-- 改为服务端返回后才开始采集
	-- GlobalEvent:Brocast(FightEvent.ReqCollect,self.target_id,1)
	MainCollectPanel.super.Open(self)
end

function MainCollectPanel:LoadCallBack()
	self.nodes = {
		"img_text_bg/text_collect_name","img_bar",
	}
	self:GetChildren(self.nodes)
	self.img_bar_component = self.img_bar:GetComponent('Image')
	self.img_bar_component.fillAmount = 0

	self.text_collect_name_component = self.text_collect_name:GetComponent('Text')
end

function MainCollectPanel:AddEvent()
	local function call_back()
		if self.cur_time and self.total_time and self.cur_time >= self.total_time then
			GlobalEvent:Brocast(FightEvent.ReqCollect,self.target_id,2)
		end
		self:Close()
	end
	self.event_id_1 = GlobalEvent:AddListener(FightEvent.EndPickUp, call_back)

	local function call_back(cur_time)
		self:UpdateView(cur_time)
	end
	self.event_id_2 = GlobalEvent:AddListener(FightEvent.UpdatePickUp, call_back)
end

function MainCollectPanel:OpenCallBack()
	self:UpdateInfo()
	self:UpdateView(self.cur_time)
	self:StartTime()
end

function MainCollectPanel:StartTime()
	self:StopTime()
	local function step()
		if Time.time - self.last_check > 1.0 then
			self:Close()
		end
	end
	self.time_id = GlobalSchedule:Start(step,1.0)
end

function MainCollectPanel:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.time_id = nil
	end
end

function MainCollectPanel:UpdateInfo()
	local target_object = SceneManager:GetInstance():GetObject(self.target_id)
	if target_object and target_object.object_info then
		self.text_collect_name_component.text = string.format("Collect %s",target_object.object_info.name)
	end
end

function MainCollectPanel:UpdateView(cur_time)
	self.last_check = Time.time
	if not self.total_time then
		return
	end
	self.cur_time = cur_time or 0
	if not self.is_loaded then
		return
	end
	local percent = math_min(self.cur_time/self.total_time,1)
	self.img_bar_component.fillAmount = percent
end

function MainCollectPanel:CloseCallBack(  )

end