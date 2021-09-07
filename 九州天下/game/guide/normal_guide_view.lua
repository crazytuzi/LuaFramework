NormalGuideView = NormalGuideView or BaseClass(BaseView)

NormalGuideView.GuideDir = {
	["left"] = 1,
	["right"] = 2,
	["top"] = 3,
	["bottom"] = 4,
}

function NormalGuideView:__init()
	self.ui_config = {"uis/views/guideview","NormalGuideView"}
	self.step_cfg = {}
	self.target_height = 0
	self.target_width = 0

	--是否在缩小动画中
	self.is_end_ani = false
	self.change_value = 0

	self.obj_height = 0
	self.obj_width = 0
	self.obj_pos_x = 0
	self.obj_pos_y = 0

	self.view_layer = UiLayer.Guide
end

function NormalGuideView:__delete()

end

function NormalGuideView:ReleaseCallBack()
	-- 清理变量和对象
	self.normal_des = nil
	self.is_strong = nil
	self.show_guide_num = nil
	self.show_other_kuang = nil
	self.girl_image = nil
	self.show_text = nil
	self.show_arrow = nil
	self.show_block = nil
	self.kuang = nil
	self.other_kuang = nil
	self.left_strong_guide = nil
	self.right_strong_guide = nil
	self.top_strong_guide = nil
	self.bottom_strong_guide = nil
	self.left = nil
	self.right = nil
	self.top = nil
	self.bottom = nil
	self.strong_guide = nil
	self.animator = nil
	self.girl_arrow = nil
	self.week_block = nil
	self.click_obj = nil
	self.click_rect = nil

	self.uicamera = nil
end

function NormalGuideView:LoadCallBack()
	--获取变量
	self.normal_des = self:FindVariable("NormalDes")
	self.is_strong = self:FindVariable("IsStrong")						--是否强指引
	self.show_guide_num = self:FindVariable("ShowGuideNum")				--显示对应强指引
	self.show_other_kuang = self:FindVariable("ShowOtherKuang")			--是否展示强制引导提示框(只存在一会)
	self.girl_image = self:FindVariable("GirlImage")					--美女图片
	self.show_text = self:FindVariable("ShowText")						--是否展示文字提示
	self.show_arrow = self:FindVariable("ShowArrow")					--是否展示箭头
	self.show_block = self:FindVariable("ShowBlock")					--阻挡界面（防止重复点击）
	self.show_block:SetValue(true)

	--获取组件
	self.kuang = self:FindObj("Kuang")									--指引框
	self.other_kuang = self:FindObj("OtherKuang")						--指引框(提示用)

	self.left_strong_guide = self:FindObj("LeftStrongGuide")			--左强指引
	self.right_strong_guide = self:FindObj("RightStrongGuide")			--右强指引
	self.top_strong_guide = self:FindObj("TopStrongGuide")				--上强指引
	self.bottom_strong_guide = self:FindObj("BottomStrongGuide")		--下强指引
	self.left = self:FindObj("Left")
	self.right = self:FindObj("Right")
	self.top = self:FindObj("Top")
	self.bottom = self:FindObj("Bottom")
	self.strong_guide = self:FindObj("StrongGuide")
	self.animator = self.strong_guide.animator

	self.girl_arrow = self:FindObj("GirlArrow")							--美女强指引箭头

	self.week_block = self:FindObj("WeekBlock")							--弱指引遮罩

	self:ListenEvent("OtherClick", BindTool.Bind(self.OtherClick, self))
	self:ListenEvent("StrongBlockClick", BindTool.Bind(self.StrongBlockClick, self))
	self:ListenEvent("WeekBlockClick", BindTool.Bind(self.StrongBlockClick, self))
end

function NormalGuideView:SetBtnObj(obj)
	if obj then
		self.click_obj = obj
		self.click_rect = self.click_obj:GetComponent(typeof(UnityEngine.RectTransform))
	end
end

function NormalGuideView:SetStepCfg(cfg)
	self.step_cfg = cfg
end

function NormalGuideView:SetIsFrist(state)
	self.frist_open = state
end

function NormalGuideView:OtherClick()
	--是否点击任意地方关闭界面
	local is_click_another_close = self.step_cfg.is_rect_effect
	if is_click_another_close == 1 then
		self:StrongBlockClick()
		return
	end

	if self.obj_height == 0 then
		return
	end
	if self.is_end_ani then
		self.show_other_kuang:SetValue(true)
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end

		self.other_kuang.rect.localPosition = Vector2(self.obj_pos_x, self.obj_pos_y)

		local change_height = self.obj_height + 1000
		local change_width = self.obj_width + 1000
		self.other_kuang.rect.sizeDelta = Vector2(change_width, change_height)
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			if change_height <= self.obj_height + 10 then
				if self.time_quest then
					GlobalTimerQuest:CancelQuest(self.time_quest)
					self.time_quest = nil
				end
				self.show_other_kuang:SetValue(false)
				return
			end
			change_height = change_height - 100
			change_height = change_height < (self.obj_height + 10) and (self.obj_height + 10) or change_height
			change_width = change_width - 100
			change_width = change_width < (self.obj_width + 10) and (self.obj_width + 10) or change_width
			self.other_kuang.rect.sizeDelta = Vector2(change_width, change_height)
		end, 0.03)
	end
end

function NormalGuideView:StrongBlockClick()
	self.show_block:SetValue(true)
	if self.click_call_back then
		self.click_call_back()
	end
	self:Close()
	FunctionGuide.Instance:StartNextStep()
end

function NormalGuideView:SetClickCallBack(callback)
	self.click_call_back = callback
end

function NormalGuideView:OpenCallBack()
	self.show_other_kuang:SetValue(false)
	self.show_block:SetValue(false)
	if next(self.step_cfg) then
		self.uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
		if self.click_rect then
			--重置锚点
			self.click_rect.pivot = Vector2(0.5, 0.5)
		end
		self.show_arrow:SetValue(self.step_cfg.offset_y ~= 1)

		local audio_id = self.step_cfg.offset_x
		if audio_id and audio_id ~= "" then
			local bundle, asset = ResPath.GetVoiceRes(audio_id)
			AudioManager.PlayAndForget(bundle, asset)
		end
		
		if self.step_cfg.is_modal == 1 then
			local arrow_dir = self.step_cfg.arrow_dir
			local dir_num = NormalGuideView.GuideDir[arrow_dir]
			if not dir_num then
				--1-4是带文字的箭头指引, 5-6是美女指引, 6以上的就只有箭头
				self.show_guide_num:SetValue(7)
				-- 0-3层为有文字的箭头指引, 4层为美女指引(包括只有箭头的情况)
				self.animator:SetLayerWeight(4, 1)
			else
				self.show_guide_num:SetValue(dir_num)
				self.animator:SetLayerWeight(dir_num - 1, 1)
			end

			if self.step_cfg.step_type == GuideStepType.GirlGuide then
				local bunble, asset = ResPath.GetGuideRes("GuideGirl")
				self.girl_image:SetAsset(bunble, asset)
			end
			self.is_strong:SetValue(true)

			--设置描述
			if not self.step_cfg.arrow_tip or self.step_cfg.arrow_tip == "" then
				self.show_text:SetValue(false)
			else
				self.show_text:SetValue(true)
				self.normal_des:SetValue(self.step_cfg.arrow_tip)
			end

			self:FlushStrong()
		else
			self.show_guide_num:SetValue(7)
			self.animator:SetLayerWeight(4, 1)
			self.is_strong:SetValue(false)
			self:FlushWeak()
		end
	end
end

function NormalGuideView:ReSetStrongGuide()
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height

	self.left.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Right, 0, width)
	self.right.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, 0, width)

	self.top.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Bottom, 0, height)
	self.top.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, 0, width)

	self.bottom.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Top, 0, height)
	self.bottom.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, 0, width)
end

function NormalGuideView:FlushNow()
	if next(self.step_cfg) then
		if self.step_cfg.is_modal == 1 then
			self:FlushStrong()
		else
			self:FlushWeak()
		end
	end
end

function NormalGuideView:FlushStrong()
	if not self.click_rect or not next(self.step_cfg) then
		return
	end
	self:ReSetStrongGuide()

	--获取指引按钮的屏幕坐标
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uicamera, self.click_rect.position)

	--转换屏幕坐标为本地坐标
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, self.uicamera, Vector2(0, 0))

	--计算高亮框的位置
	local height = self.left.rect.rect.height
	local width = self.left.rect.rect.width

	local click_real_rect = self.click_rect.rect
	local btn_height = click_real_rect.height
	local btn_width = click_real_rect.width
	local pos_x = local_pos_tbl.x
	local pos_y = local_pos_tbl.y

	--记录指引按钮的大小
	self.obj_height = btn_height
	self.obj_width = btn_width
	self.obj_pos_x = pos_x
	self.obj_pos_y = pos_y

	--判断显示的美女指引位置
	if self.step_cfg.step_type == GuideStepType.GirlGuide then
		if pos_x > 0 then
			self.show_guide_num:SetValue(5)
		else
			self.show_guide_num:SetValue(6)
		end
		self.animator:SetLayerWeight(4, 1)
	end

	--设置强指引的位置
	local arrow_dir = self.step_cfg.arrow_dir
	local strong_guide = self.right_strong_guide
	local guide_x = 0
	local guide_y = 0
	local rotarion = -1
	if arrow_dir == "left" then
		strong_guide = self.left_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 180
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x - btn_width/2
		guide_y = pos_y
	elseif arrow_dir == "right" then
		strong_guide = self.right_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 0
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x + btn_width/2
		guide_y = pos_y
	elseif arrow_dir == "top" then
		strong_guide = self.top_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 90
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "bottom" then
		strong_guide = self.bottom_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 270
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x
		guide_y = pos_y - btn_height/2
	elseif arrow_dir == "top_left" then
		strong_guide = self.girl_arrow
		rotarion = 135
		guide_x = pos_x - btn_width/2
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "top_right" then
		strong_guide = self.girl_arrow
		rotarion = 45
		guide_x = pos_x + btn_width/2
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "bottom_left" then
		strong_guide = self.girl_arrow
		rotarion = 225
		guide_x = pos_x - btn_width/2
		guide_y = pos_y - btn_height/2
	elseif arrow_dir == "bottom_right" then
		strong_guide = self.girl_arrow
		rotarion = 315
		guide_x = pos_x + btn_width/2
		guide_y = pos_y - btn_height/2
	end
	local normal_rect = strong_guide.rect
	normal_rect.localPosition = Vector2(guide_x, guide_y)

	if rotarion ~= -1 then
		normal_rect.localEulerAngles = Vector3(0, 0, rotarion)
	end

	local kuang_height = btn_height
	local kuang_width = btn_width
	if not self.is_end_ani then
		if self.target_height == 0 then
			--记录宽高
			self.target_width = kuang_width + 400
			self.target_height = kuang_height + 400
		end

		if self.target_width <= kuang_width then
			self.target_height = 0
			self.target_width = 0
			self.is_end_ani = true
			strong_guide.canvas_group.alpha = 1
		else
			self.target_width = self.target_width - 40
			self.target_height = self.target_height - 40
			if self.target_height > kuang_height then
				kuang_height = self.target_height
				kuang_width = self.target_width
			end
			strong_guide.canvas_group.alpha = 0
		end
	else
		local max_width = kuang_width + 13.5
		local min_width = kuang_width
		--循环变化选中框大小
		if self.target_height == 0 then
			--记录宽高
			self.target_width = kuang_width
			self.target_height = kuang_height
		end
		if self.change_value == 0 then
			self.change_value = 1.5
		end
		if self.target_width > max_width then
			self.change_value = -1.5
		elseif self.target_width < min_width then
			self.change_value = 1.5
		end
		self.target_width = self.target_width + self.change_value
		self.target_height = self.target_height + self.change_value
		kuang_height = self.target_height
		kuang_width = self.target_width
	end

	--设置框
	self.kuang.rect.localPosition = Vector2(pos_x, pos_y)
	self.kuang.rect.sizeDelta = Vector2(kuang_width + 10, kuang_height + 10)

	local left_width = width/2 + pos_x - btn_width/2
	local right_width = width/2 - (pos_x + btn_width/2)
	local top_height = height/2 - (pos_y + btn_height/2)
	local bottom_height = height/2 + pos_y - btn_height/2

	self.left.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Right, width - left_width, left_width)
	self.right.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, width - right_width, right_width)

	self.top.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Bottom, height - top_height, top_height)
	self.top.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, left_width, btn_width)

	self.bottom.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Top, height - bottom_height, bottom_height)
	self.bottom.rect:SetInsetAndSizeFromParentEdge(UnityEngine.RectTransform.Edge.Left, left_width, btn_width)
end

function NormalGuideView:FlushWeak()
	if not self.click_rect or not next(self.step_cfg) then
		return
	end

	--获取指引按钮的屏幕坐标
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uicamera, self.click_rect.position)

	--转换屏幕坐标为本地坐标
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, self.uicamera, Vector2(0, 0))

	local click_real_rect = self.click_rect.rect
	local btn_height = click_real_rect.height
	local btn_width = click_real_rect.width
	local pos_x = local_pos_tbl.x
	local pos_y = local_pos_tbl.y

	--设置弱指引遮罩的位置大小
	self.week_block.rect.localPosition = Vector2(pos_x, pos_y)
	self.week_block.rect.sizeDelta = Vector2(btn_width, btn_height)

	--设置弱指引的位置
	local arrow_dir = self.step_cfg.arrow_dir
	local guide_x = 0
	local guide_y = 0
	local rotarion = 0
	if arrow_dir == "left" then
		rotarion = 180
		guide_x = pos_x - btn_width/2
		guide_y = pos_y
	elseif arrow_dir == "right" then
		rotarion = 0
		guide_x = pos_x + btn_width/2
		guide_y = pos_y
	elseif arrow_dir == "top" then
		rotarion = 90
		guide_x = pos_x
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "bottom" then
		rotarion = 270
		guide_x = pos_x
		guide_y = pos_y - btn_height/2
	elseif arrow_dir == "top_left" then
		rotarion = 135
		guide_x = pos_x - btn_width/2
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "top_right" then
		rotarion = 45
		guide_x = pos_x + btn_width/2
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "bottom_left" then
		rotarion = 225
		guide_x = pos_x - btn_width/2
		guide_y = pos_y - btn_height/2
	elseif arrow_dir == "bottom_right" then
		rotarion = 315
		guide_x = pos_x + btn_width/2
		guide_y = pos_y - btn_height/2
	end

	self.girl_arrow.rect.localPosition = Vector2(guide_x, guide_y)
	self.girl_arrow.rect.localEulerAngles = Vector3(0, 0, rotarion)
end

function NormalGuideView:OnFlush()
	self:FlushNow()
end

function NormalGuideView:CloseCallBack()
	self.step_cfg = {}
	self.click_obj = nil
	self.click_rect = nil
	self.click_call_back = nil

	self.is_end_ani = false
	self.change_value = 0

	self.target_width = 0
	self.target_height = 0

	self.obj_height = 0
	self.obj_width = 0
	self.obj_pos_x = 0
	self.obj_pos_y = 0

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.uicamera = nil
end

function NormalGuideView:SetArrowTips(des)
	if self.normal_des then
		self.normal_des:SetValue(des)
	end
end