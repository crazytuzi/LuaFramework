TaskActiveZhanChongView = TaskActiveZhanChongView or BaseClass(BaseView)
function TaskActiveZhanChongView:__init( ... )
	self:SetModal(true)
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"mainui_task_effect_ui_cfg", 1, {0}},
		--{"team_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}},
	}
end

function TaskActiveZhanChongView:__delete( ... )
	-- body
end

function TaskActiveZhanChongView:ReleaseCallBack( ... )
	if self.progress then
		self.progress:DeleteMe()
		self.progress = nil 
	end
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil
	end
end

function TaskActiveZhanChongView:LoadCallBack( ... )
	-- print("???????????", self.node_t_list.prog9_val.node)
	self.progress = ProgressBar.New()
    self.progress:SetView(self.node_t_list.prog9_val.node)
    self.progress:SetTotalTime(3)
    self.progress:SetPercent(0)

    if nil == self.effect_show1 then
		local ph = self.ph_list.ph_effect
	 	self.effect_show1 = AnimateSprite:create()
	 	self.effect_show1:setPosition(ph.x + 15, ph.y + 5)
	 	 self.node_t_list.layout_effect.node:addChild(self.effect_show1, 999)
	end
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1160)
	self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

end


function TaskActiveZhanChongView:OpenCallBack()
	-- override
end

function TaskActiveZhanChongView:ShowIndexCallBack(index)
	self:Flush(index)
end

function TaskActiveZhanChongView:CloseCallBack(...)
	
end


function TaskActiveZhanChongView:OnFlush(param_list, index)
	local data = {}
	for k, v in pairs(param_list) do
		if k == "param1" then
			data = v
			self.progress:SetPercent(100, true)
			if self.delay_timer then
				GlobalTimerQuest:CancelQuest(self.delay_timer)
				self.delay_timer = nil
			end
			self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ( ... )
					-- RemindManager.Instance:DoRemindDelayTime(RemindName.BagCompose)
					if self.delay_timer then
						GlobalTimerQuest:CancelQuest(self.delay_timer)
						self.delay_timer = nil
					end
					--print(data.view_link1)
					ViewManager.Instance:OpenViewByStr(data.view_link1)
					ViewManager.Instance:FlushViewByStr(data.view_link1, 0, "param1", data)
					ViewManager.Instance:CloseViewByDef(ViewDef.TaskZhanChongEffect)

					ZhanjiangCtrl.HeroActivateReq(1)
			end, 3)
		end
	end
	
end