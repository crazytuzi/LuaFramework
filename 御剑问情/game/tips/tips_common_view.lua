TipsCommonView = TipsCommonView or BaseClass(BaseView)

function TipsCommonView:__init()
	self.ui_config = {"uis/views/tips/commontips_prefab", "CommonTips"}
	self.ok_func = nil
	self.view_layer = UiLayer.Pop
	self.is_show_no_tip = false
	self.no_tip_state = false
	self.is_show_time = true
	self.prefs_key = nil
	self.play_audio = true
	self.is_no_tip_toggle = true
end

function TipsCommonView:__delete()
	self.ok_func = nil
end

-- 创建完调用
function TipsCommonView:LoadCallBack()
	self.is_no_tip = self:FindVariable("IsNoTip")
	self.show_time = self:FindVariable("ShowTime")
	self.time = self:FindVariable("Time")
	self.show_recycle = self:FindVariable("IsRecycle")
	self.recycle_text = self:FindVariable("RecycleText")
	self.cancle_btn_text = self:FindVariable("CancleBtnText")
	self.show_cancel_btn = self:FindVariable("show_cancel_btn")
	self.show_monster_icon = self:FindVariable("show_monster_icon")
	self.monster_icon = self:FindVariable("monster_icon")
	self.auto_text = self:FindVariable("auto_text")
	self.tip_content = self:FindObj("TipContent")
	self.no_tip_toggle = self:FindObj("NoTips")
	self.recycle = self:FindObj("Recycle")

	self:ListenEvent("OnClickYes",
		BindTool.Bind(self.OnClickYes, self))
	self:ListenEvent("OnClickNo",
		BindTool.Bind(self.OnClickNo, self))
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("no_tips_toggle",
		BindTool.Bind(self.OnNoTipToggleClick, self))
	self:ListenEvent("OnClickBgMask",
		BindTool.Bind(self.OnClickBgMask, self))
	if self.data ~= nil or self.content ~= nil then
		self:Flush()
	end
end

function TipsCommonView:ReleaseCallBack()
	-- 清理变量和对象
	self.is_no_tip = nil
	self.show_time = nil
	self.time = nil
	self.show_recycle = nil
	self.recycle_text = nil
	self.cancle_btn_text = nil
	self.show_cancel_btn = nil
	self.show_monster_icon = nil
	self.monster_icon = nil
	self.auto_text = nil
	self.tip_content = nil
	self.no_tip_toggle = nil
	self.recycle = nil
end

function TipsCommonView:OpenCallBack()
	self.no_tip_toggle.toggle.isOn = self.is_no_tip_toggle
	self:Flush()
end

function TipsCommonView:CloseCallBack()
	self.content = nil
	self.cancle_data = nil
	self.ok_func = nil
	self.no_func = nil
	self.data = nil
	self.is_show_no_tip = nil
	self.is_show_time = nil
	self.prefs_key = nil
	self.no_btn_text = nil
	self.cal_time = nil

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.no_tip_toggle.toggle.isOn then
		self.no_tip_toggle.toggle.isOn = false
	end
	self.show_time:SetValue(false)
end

function TipsCommonView:OnClickYes()
	if self.ok_func ~= nil then
		if self.no_tip_toggle.toggle.isOn then
			if type(self.prefs_key) == "string" then
				SettingData.Instance:SetCommonTipkey(self.prefs_key, true)
			end
		end
		if self.data ~= nil then
			self.ok_func(self.data)
		elseif self.is_recycle then
			self.ok_func(self.recycle.toggle.isOn)
		else
			self.ok_func()
		end
	end
	self:Close()
end

function TipsCommonView:OnClickNo()
	if self.no_func ~= nil then
		if self.cancle_data ~= nil then
			self.no_func(self.cancle_data)
		else
			self.no_func()
		end
	end
	self:Close()
end

function TipsCommonView:OnClickBgMask()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.PataFB then
		return
	end

	if self.no_func ~= nil and not self.close_unequal_no_fun  then
		if self.cancle_data ~= nil then
			self.no_func(self.cancle_data)
		else
			self.no_func()
		end
	end
	self:Close()
end

function TipsCommonView:OnClickClose()
	if self.no_func ~= nil and not self.close_unequal_no_fun then
		if self.cancle_data ~= nil then
			self.no_func(self.cancle_data)
		else
			self.no_func()
		end
	end
	self:Close()
end

function TipsCommonView:OnNoTipToggleClick(is_click)
	self.no_tip_state = is_click
end

function TipsCommonView:SetOKCallback(func)
	self.ok_func = func
end

function TipsCommonView:SetNoCallback(func)
	self.no_func = func
end

function TipsCommonView:SetContent(content)
	self.content = content
	self:Flush()
end

function TipsCommonView:SetData(data, cancle_data, is_show_no_tip, show_time, prefs_key, is_recycle, recycle_text, auto_text_des, hide_cancel, boss_id, no_auto_click_yes, no_btn_text, cal_time, auto_click_no, is_no_tip_toggle, close_unequal_no_fun)
	self.prefs_key = prefs_key
	self.data = data
	self.is_show_no_tip = is_show_no_tip or false
	self.is_show_time = show_time or false
	self.is_recycle = is_recycle or false
	self.recycle_content = recycle_text or "自动回收紫色精灵"
	self.auto_text_des = auto_text_des or "秒后自动挑战下一关"
	self.cancle_data = cancle_data
	self.hide_cancel = hide_cancel
	self.boss_id = boss_id
	self.no_auto_click_yes = no_auto_click_yes
	self.no_btn_text = no_btn_text
	self.cal_time = cal_time
	self.auto_click_no = auto_click_no
	self.close_unequal_no_fun = close_unequal_no_fun
	self.is_no_tip_toggle = not (is_no_tip_toggle ~= nil and is_no_tip_toggle == false)
	if self.root_node ~= nil then
		self:OnFlush()
	end


end

function TipsCommonView:SetTipText(content)
	self.tip_content.text.text = content
end

function TipsCommonView:OnFlush(param_list)
	if self.content ~= nil then
		self.tip_content.text.text = self.content

		self.is_no_tip:SetValue(self.is_show_no_tip)

		-- if self.show_time then
		-- 	self.show_time:SetValue(self.is_show_time)
		-- end

		self.show_recycle:SetValue(self.is_recycle)
		if self.is_recycle then
			self.recycle_text:SetValue(self.recycle_content)
		end

		if self.is_show_time then
			self.cancle_btn_text:SetValue(self.no_btn_text or Language.Society.Leave)
			local diff_time = self.cal_time or 6
			if self.count_down == nil then
				self.count_down = CountDown.Instance:AddCountDown(
					diff_time, 1.0, function(elapse_time, total_time)
						local left_time = diff_time - elapse_time
						if left_time <= 0 then
							CountDown.Instance:RemoveCountDown(self.count_down)
							self.count_down = nil
							if self.auto_click_no == true then
								self:OnClickNo()
							else
								self:OnClickYes()
							end
							return
						end
						self.auto_text:SetValue(self.auto_text_des)
						self.time:SetValue(left_time)
						self.show_time:SetValue(true)
					end)
			end
		else
			self.cancle_btn_text:SetValue(self.no_btn_text or "取消")
			if self.count_down then
				CountDown.Instance:RemoveCountDown(self.count_down)
				self.count_down = nil
			end
		end
	end

	self.show_cancel_btn:SetValue(self.hide_cancel == nil)

	if self.boss_id then
		self.show_monster_icon:SetValue(true)
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.boss_id]
		local bundle, asset = nil, nil
		if monster_cfg then
			bundle, asset = ResPath.GetBossIcon(monster_cfg.headid)
			self.monster_icon:SetAsset(bundle, asset)
		end
	else
		self.show_monster_icon:SetValue(false)
	end
end
