NormalGuideView = NormalGuideView or BaseClass(BaseView)

NormalGuideView.GuideDir = {
	["left"] = 1,
	["right"] = 2,
	["top"] = 3,
	["bottom"] = 4,
}

function NormalGuideView:__init()
	self.ui_config = {"uis/views/guideview_prefab","NormalGuideView"}
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
	if self.size_tween then
		self.size_tween:Kill()
		self.size_tween = nil
	end

	if self.other_size_tween then
		self.other_size_tween:Kill()
		self.other_size_tween = nil
	end

	self:StopFixTimeQuest()

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
	self.guide_text_arrow = nil
	
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
	self.show_text:SetValue(true)
	self.show_arrow = self:FindVariable("ShowArrow")					--是否展示箭头
	self.show_block = self:FindVariable("ShowBlock")					--阻挡界面（防止重复点击）
	self.show_block:SetValue(true)

	--获取组件
	self.kuang = self:FindObj("Kuang")									--指引框
	self.other_kuang = self:FindObj("OtherKuang")						--指引框(提示用)

	self.guide_text_arrow = self:FindObj("GuideTextArrow")				--文字强指引
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
	self.click_obj = obj
	self.click_rect = self.click_obj:GetComponent(typeof(UnityEngine.RectTransform))
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
		if self.other_size_tween then
			self.other_size_tween:Kill()
			self.other_size_tween = nil
		end
		self.show_other_kuang:SetValue(true)
		self.other_kuang.rect.localPosition = Vector2(self.obj_pos_x, self.obj_pos_y)
		self.other_kuang.rect.sizeDelta = Vector2(self.obj_width + 1000, self.obj_height + 1000)
		self.other_size_tween = self.other_kuang.rect:DOSizeDelta(Vector2(self.obj_width + 20, self.obj_height + 20), 0.5)
		self.other_size_tween:SetEase(DG.Tweening.Ease.OutQuad)
		self.other_size_tween:OnComplete(function()
			self.show_other_kuang:SetValue(false)
		end)
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

--初始化界面（这时候暂时隐藏所有东西）
function NormalGuideView:InitView()
	self.show_other_kuang:SetValue(false)
	self.is_strong:SetValue(false)
	self.show_arrow:SetValue(false)
	self.show_guide_num:SetValue(0)
	self.show_block:SetValue(true)

	--重置黑幕位置
	self:ReSetStrongGuide()
end

function NormalGuideView:FlushOneView()
	self:StopFixTimeQuest()

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

		--设置描述
		-- if not self.step_cfg.arrow_tip or self.step_cfg.arrow_tip == "" then
		-- 	self.show_text:SetValue(false)
		-- else
		-- 	self.show_text:SetValue(true)
		-- 	self.normal_des:SetValue(self.step_cfg.arrow_tip)
		-- end

		self:FlushStrong()
	else
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
		self:FlushWeak()
	end
end

function NormalGuideView:StopFixTimeQuest()
	if self.fix_time_quest then
		GlobalTimerQuest:CancelQuest(self.fix_time_quest)
		self.fix_time_quest = nil
	end
end

function NormalGuideView:OpenCallBack()
	self:InitView()

	self.is_first = true

	self.bottom_right_complete = true
	self.top_right_complete = true
	local last_step_info = FunctionGuide.Instance:GetLastGuideStepCfg()
	if last_step_info and last_step_info.unuseful ~= 1 and last_step_info.step_type ~= GuideStepType.AutoCloseView then
		--如果上一个引导是这两个的按钮的话就要等待动画完毕再指引按钮（并且不是关闭操作）
		--由于两个动画的时候可能不统一，所以分开监听
		if last_step_info.ui_name == GuideUIName.MainUIRoleHead then
			self.bottom_right_complete = false
		elseif last_step_info.ui_name == GuideUIName.MainUIRightShrink then
			self.top_right_complete = false
		end
	end

	-- 容错: 加一个倒计时，防止引导失效导致游戏无法进行
	self.fix_time_quest = GlobalTimerQuest:AddDelayTimer(function()
		self:Close()
		FunctionGuide.Instance:StartNextStep()
	end, 2)
end

function NormalGuideView:ReSetStrongGuide()
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height

	self.left.rect.offsetMin = Vector2(0, 0)
	self.left.rect.offsetMax = Vector2(0, 0)

	self.right.rect.offsetMin = Vector2(0, 0)
	self.right.rect.offsetMax = Vector2(0, 0)

	self.top.rect.offsetMin = Vector2(0, 0)
	self.top.rect.offsetMax = Vector2(0, 0)

	self.bottom.rect.offsetMin = Vector2(0, 0)
	self.bottom.rect.offsetMax = Vector2(0, 0)
end

function NormalGuideView:FlushNow()
	if next(self.step_cfg) then
		local player_button_ani_state = MainUICtrl.Instance.view:GetPlayerButtonAniState()
		local top_right_button_ani_state = MainUICtrl.Instance.view:GetTopRightButtonAniState()
		if not self.bottom_right_complete then
			self.bottom_right_complete = player_button_ani_state == 1
		end
		if not self.top_right_complete then
			self.top_right_complete = top_right_button_ani_state == 1
		end

		if self.is_first and self.bottom_right_complete and self.top_right_complete then
			self:FlushOneView()
			self.is_first = false
		end

		if self.step_cfg.is_modal == 1 then
			self:FlushStrong()
		else
			self:FlushWeak()
		end
	end
end

function NormalGuideView:FlushStrong()
	local player_button_ani_state = MainUICtrl.Instance.view:GetPlayerButtonAniState()
	local top_right_button_ani_state = MainUICtrl.Instance.view:GetTopRightButtonAniState()
	if not self.bottom_right_complete then
		self.bottom_right_complete = player_button_ani_state == 1
	end
	if not self.top_right_complete then
		self.top_right_complete = top_right_button_ani_state == 1
	end

	if not self.bottom_right_complete or not self.top_right_complete then
		return
	end

	if not self.click_rect or not next(self.step_cfg) then
		return
	end

	self.show_block:SetValue(false)
	self.is_strong:SetValue(true)

	self:ReSetStrongGuide()

	--获取指引按钮的屏幕坐标
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uicamera, self.click_rect.position)

	--转换屏幕坐标为本地坐标
	local rect = self.root_node:GetComponent(typeof(UnityEngine.RectTransform))
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, self.uicamera, Vector2(0, 0))

	--计算高亮框的位置
	local height = rect.rect.height
	local width = rect.rect.width

	local click_real_rect = self.click_rect.rect
	local btn_height = click_real_rect.height
	local btn_width = click_real_rect.width
	local pos_x = local_pos_tbl.x
	local pos_y = local_pos_tbl.y

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
	local strong_guide = self.guide_text_arrow
	local guide_x = 0
	local guide_y = 0
	local rotarion = -1
	if arrow_dir == "left" then
		-- strong_guide = self.left_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 180
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x - btn_width/2
		guide_y = pos_y
	elseif arrow_dir == "right" then
		-- strong_guide = self.right_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 0
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x + btn_width/2
		guide_y = pos_y
	elseif arrow_dir == "top" then
		-- strong_guide = self.top_strong_guide
		if self.step_cfg.step_type == GuideStepType.GirlGuide then
			rotarion = 90
			strong_guide = self.girl_arrow
		end
		guide_x = pos_x
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "bottom" then
		-- strong_guide = self.bottom_strong_guide
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

	--用DoTween实现缩放效果
	if nil == self.size_tween then
		self.is_end_ani = false
		self.kuang.rect.sizeDelta = Vector2(btn_width + 600, btn_height + 600)
		self.size_tween = self.kuang.rect:DOSizeDelta(Vector2(btn_width + 10, btn_height + 10), 0.7)
		self.size_tween:SetEase(DG.Tweening.Ease.OutQuart)
		-- self.size_tween:SetUpdate(true)			--按真实时间执行
		self.size_tween:OnComplete(function()
			self.is_end_ani = true
			self.size_tween = self.kuang.rect:DOSizeDelta(Vector2(btn_width + 20, btn_height + 20), 0.5)
			self.size_tween:SetEase(DG.Tweening.Ease.Linear)
			self.size_tween:SetLoops(-1, DG.Tweening.LoopType.Yoyo)
		end)
	end

	--记录指引按钮的大小
	if btn_height ~= self.obj_height or btn_width ~= self.obj_width then
		self.obj_height = btn_height
		self.obj_width = btn_width
	end
	self.obj_pos_x = pos_x
	self.obj_pos_y = pos_y

	--设置框
	self.kuang.rect.localPosition = Vector2(pos_x, pos_y)

	local left_width = (width/2 + pos_x - btn_width/2) + 5
	local right_width = (width/2 - (pos_x + btn_width/2)) + 5
	local top_height = (height/2 - (pos_y + btn_height/2)) + 5
	local bottom_height = (height/2 + pos_y - btn_height/2) + 5

	self.left.rect.offsetMin = Vector2(0, 0)
	self.left.rect.offsetMax = Vector2(-(width - left_width), 0)

	self.right.rect.offsetMin = Vector2(width - right_width, 0)
	self.right.rect.offsetMax = Vector2(0, 0)

	self.top.rect.offsetMin = Vector2(left_width, height-top_height)
	self.top.rect.offsetMax = Vector2(-right_width, 0)

	self.bottom.rect.offsetMin = Vector2(left_width, 0)
	self.bottom.rect.offsetMax = Vector2(-right_width, -(height-bottom_height))
end

function NormalGuideView:FlushWeak()
	if not self.click_rect or not next(self.step_cfg) then
		return
	end

	self.show_block:SetValue(false)
	self.is_strong:SetValue(false)

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
	local dir_obj = self.guide_text_arrow
	local is_special_arrow = false
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
		is_special_arrow = true
		dir_obj = self.girl_arrow
		rotarion = 135
		guide_x = pos_x - btn_width/2
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "top_right" then
		is_special_arrow = true
		dir_obj = self.girl_arrow
		rotarion = 45
		guide_x = pos_x + btn_width/2
		guide_y = pos_y + btn_height/2
	elseif arrow_dir == "bottom_left" then
		is_special_arrow = true
		dir_obj = self.girl_arrow
		rotarion = 225
		guide_x = pos_x - btn_width/2
		guide_y = pos_y - btn_height/2
	elseif arrow_dir == "bottom_right" then
		is_special_arrow = true
		dir_obj = self.girl_arrow
		rotarion = 315
		guide_x = pos_x + btn_width/2
		guide_y = pos_y - btn_height/2
	end

	dir_obj.rect.localPosition = Vector2(guide_x, guide_y)
	if is_special_arrow then
		dir_obj.rect.localEulerAngles = Vector3(0, 0, rotarion)
	end
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

	if self.size_tween then
		self.size_tween:Kill()
		self.size_tween = nil
	end

	if self.other_size_tween then
		self.other_size_tween:Kill()
		self.other_size_tween = nil
	end

	self.uicamera = nil

	self:StopFixTimeQuest()
end

function NormalGuideView:SetArrowTips(des)
	if self.normal_des then
		self.normal_des:SetValue(des)
	end
end