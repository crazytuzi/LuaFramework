TipPaTaView = TipPaTaView or BaseClass(BaseView)
function TipPaTaView:__init()
	self.ui_config = {"uis/views/tips/patatips", "PaTaTipsView"}
	self.view_layer = UiLayer.Pop
	self.item_cells = {}
	self.is_finish = false
	self:SetMaskBg()
end

function TipPaTaView:__delete()
	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
		v = nil
	end
	self.item_cells = {}
end

function TipPaTaView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("OkClick",BindTool.Bind(self.OnOkClick, self))
	self.desc_text = self:FindVariable("desc_text")
	self.is_btn = self:FindVariable("is_btn")
	self.finish_text = self:FindVariable("finish_text")
	for i = 1, 3 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
end

function TipPaTaView:ReleaseCallBack()
	self:ClearTimer()

	-- 清理变量和对象
	self.desc_text = nil
	self.is_btn = nil
	self.finish_text = nil

	for i = 1, 3 do
		if self.item_cells[i] then
			self.item_cells[i]:DeleteMe()
			self.item_cells[i] = nil
		end
	end
	self.item_cells = {}
end

function TipPaTaView:OpenCallBack()
	self:Flush()
end

function TipPaTaView:CloseCallBack()
	self.no_func = nil
	self.ok_func = nil
	self:ClearTimer()
end

function TipPaTaView:OnFlush()
	self:CalTime()
	local fuben_cfg = FuBenData.Instance:GetTowerFBLevelCfg()
	local tower_fb_info = FuBenData.Instance:GetTowerFBInfo()
	local max_level_cfg = FuBenData.Instance:MaxTowerFB()
	if not next(tower_fb_info) then return end

	if tower_fb_info.pass_level >= max_level_cfg then
		self.is_btn:SetValue(true)
		self.finish_text:SetValue(Language.Pata.FinishText)
		self.is_finish = true
	else
		self.finish_text:SetValue(Language.Pata.BeginText)
	end

	local today_config = fuben_cfg[tower_fb_info.today_level]
	if not next(today_config) then return end

	local reward_cfg = tower_fb_info.pass_level < tower_fb_info.today_level + 1 and today_config.first_reward or today_config.normal_reward
	local reward_count = 0
	for k, v in pairs(self.item_cells) do
		if reward_cfg[k - 1] then
			reward_count = reward_count + 1
			v:SetData(reward_cfg[k - 1])
			v:SetParentActive(true)
		else 
			v:SetParentActive(false)
		end
	end
	if self.item_cells[reward_count + 1] then
		local data = {item_id = FuBenDataExpItemId.ItemId, num = fuben_cfg[tower_fb_info.today_level].reward_exp}
		self.item_cells[reward_count + 1]:SetData(data)
		self.item_cells[reward_count + 1]:SetParentActive(true)
	end
end

function TipPaTaView:OnCloseClick()
	if self.no_func ~= nil then
		self.no_func()
	end
	self:Close()
end

function TipPaTaView:SetNoCallback(func)
	self.no_func = func
end

function TipPaTaView:SetOKCallback(func)
	self.ok_func = func
end

function TipPaTaView:SetData()
	self:Flush()
end

function TipPaTaView:OnOkClick()
	if self.ok_func then
		if self.is_finish then
			FuBenCtrl.Instance:SendExitFBReq()
		else
			self.ok_func()
		end
	end
	self:Close()
end

function TipPaTaView:CalTime()
	self:ClearTimer()

	local timer_cal = 5
	self.cal_time_quest = GlobalTimerQuest:AddRunQuest(function()
		timer_cal = timer_cal - UnityEngine.Time.deltaTime
		if timer_cal <= 0 then
			if self.is_finish then
				FuBenCtrl.Instance:SendExitFBReq()
			end
			self:OnOkClick()
		else
			self.desc_text:SetValue(math.floor(timer_cal))
		end
	end, 0)
end

function TipPaTaView:ClearTimer()
	if self.cal_time_quest then
		GlobalTimerQuest:CancelQuest(self.cal_time_quest)
		self.cal_time_quest = nil
	end
end