TipOpenFunctionFlyView = TipOpenFunctionFlyView or BaseClass(BaseView)

--主界面右上角图标大小与间距
local TopRightBtnWidth = 70
local TopRightBtnHeight = 70
local TopRightBtnScale = 0.9					--图标缩放
local TopRightBtnSpacing = 17

--主界面右下角图标大小与间距
local BottomRightBtnWidth = 90
local BottomRightBtnHeight = 90
local BottomRightBtnScale = 0.9					--图标缩放
local BottomRightBtnXSpacing = 5				--横向间距
local BottomRightBtnYSpacing = 10				--纵向间距

--纵向按钮列表
local YBtnList = {
	["forge"] = 1,
	["player"] = 1,
	["advance"] = 1,
}

local STATIC_TIME = 3							--静止时间
local MOVE_TIME = 2								--移动时间

function TipOpenFunctionFlyView:__init()
	self.ui_config = {"uis/views/tips/openfunflytips_prefab", "OpenFunctionFlyTips"}
	self.view_layer = UiLayer.Pop
	self.is_fly_ani = false						--是否在飞行中
	self.play_audio = true
end

function TipOpenFunctionFlyView:__delete()
end

--写在open中是因为需要解决打开界面时会有延迟,而导致停下任务也有延迟的问题。
function TipOpenFunctionFlyView:Open(index)
	BaseView.Open(self, index)
	TaskCtrl.Instance:SetAutoTalkState(false)
end

function TipOpenFunctionFlyView:LoadCallBack()
	self.icon_go = self:FindObj("icon_go")

	self.icon_image = self:FindVariable("icon_image")
	self.icon_text = self:FindVariable("icon_text")
	self.show_bg = self:FindVariable("show_bg")

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("Block", BindTool.Bind(self.BlockClick, self))
end

function TipOpenFunctionFlyView:ReleaseCallBack()
	-- 清理变量和对象
	self.icon_go = nil
	self.icon_image = nil
	self.icon_text = nil
	self.show_bg = nil

	self.uicamera = nil
	self.target_obj = nil
	self.target_rect = nil

	self:StopCountDown()
	self:StopTween()
	self:UnListenEvent()
end

function TipOpenFunctionFlyView:UnListenEvent()
	if self.player_button_event then
		GlobalEventSystem:UnBind(self.player_button_event)
		self.player_button_event = nil
	end

	if self.top_right_button_event then
		GlobalEventSystem:UnBind(self.top_right_button_event)
		self.top_right_button_event = nil
	end
end

function TipOpenFunctionFlyView:OpenCallBack()
	TaskCtrl.Instance:SetAutoTalkState(false)

	--显示背景
	self.show_bg:SetValue(true)

	self.uicamera = GameObject.Find("GameRoot/UICamera"):GetComponent(typeof(UnityEngine.Camera))
	self.btn_name = OpenFunData.Instance:GetName(self.cfg.open_param)
	self.is_fly_ani = true

	self.top_right_complete = true
	self.bottom_right_complete = true
	if self.cfg.with_param == OPEN_FLY_DICT_TYPE.UP then
		self.top_right_complete = false
	else
		self.bottom_right_complete = false
	end

	self:InitIcon()

	self:ChangeTargetAlpha(0)

	self:ChangeTargetSize()

	self:StartCountDown()
end

function TipOpenFunctionFlyView:CloseCallBack()
	self.cfg = nil
	self.target_obj = nil
	self.target_rect = nil
	self.uicamera = nil

	self:StopCountDown()
	self:StopTween()
	self:UnListenEvent()

	GlobalEventSystem:Fire(FinishedOpenFun, false)

	local is_wait_guide = FunctionGuide.Instance:GetIsWaitGuide()
	if not is_wait_guide then
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		GlobalEventSystem:Fire(MainUIEventType.SHOW_OR_HIDE_SHRINK_BUTTON, false)
		TaskCtrl.Instance:SetAutoTalkState(true)
	end
end

function TipOpenFunctionFlyView:SetData(cfg)
	if self.cfg and self.target_obj then
		local target_normal_width = BottomRightBtnWidth
		local target_normal_height = BottomRightBtnHeight
		if self.cfg.with_param == OPEN_FLY_DICT_TYPE.UP then
			target_normal_width = TopRightBtnWidth
			target_normal_height = TopRightBtnHeight
		end
		self.target_obj.rect.sizeDelta = Vector2(target_normal_width, target_normal_height)
		self:ChangeTargetAlpha(1)
	end
	self.cfg = cfg
end

function TipOpenFunctionFlyView:SetTargetObj(target_obj)
	self.target_obj = target_obj
	self.target_rect = self.target_obj:GetComponent(typeof(UnityEngine.RectTransform))
end

--初始化飞行图标
function TipOpenFunctionFlyView:InitIcon()
	--初始化坐标
	self.icon_go.rect.anchoredPosition = Vector2(0, 0)

	--初始化图片
	local icon = self.cfg.icon
	if icon ~= "" then
		local bundle, asset = ResPath.GetMainUI(icon)
		self.icon_image:SetAsset(bundle, asset)
	end

	--初始化文字
	self.icon_text:SetValue(self.cfg.show_tips)
end

--改变目标的大小
function TipOpenFunctionFlyView:ChangeTargetSize()
	if self.cfg.with_param == OPEN_FLY_DICT_TYPE.UP then
		--这里是改变主界面上方功能图标的大小(这里的x代表间距)
		self.target_obj.rect.sizeDelta = Vector2(-TopRightBtnSpacing, TopRightBtnHeight)
	else
		--这里是改变主界面下方功能图标的大小(这里的x代表间距)
		local vect2 = Vector2(-BottomRightBtnXSpacing, BottomRightBtnHeight)

		--纵向按钮
		if YBtnList[self.btn_name] == 1 then
			--(这里的y代表间距)
			vect2 = Vector2(BottomRightBtnWidth, -BottomRightBtnYSpacing)
		end

		self.target_obj.rect.sizeDelta = vect2
	end
end

--改变目标的透明度
function TipOpenFunctionFlyView:ChangeTargetAlpha(alpha)
	local canvas_group = self.target_obj:GetComponent(typeof(UnityEngine.CanvasGroup))
	if canvas_group ~= nil then
		canvas_group.alpha = alpha
	end
end

function TipOpenFunctionFlyView:StopTween()
	if self.sequence then
		self.sequence:Kill()
		self.sequence = nil
	end
end

--开始移动到目标
function TipOpenFunctionFlyView:MoveToTarget()
	--获取指引按钮的屏幕坐标
	local screen_pos_tbl = UnityEngine.RectTransformUtility.WorldToScreenPoint(self.uicamera, self.target_rect.position)

	--转换屏幕坐标为本地坐标
	local rect = self.icon_go.rect
	local _, local_pos_tbl = UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, screen_pos_tbl, self.uicamera, Vector2(0, 0))

	--计算偏移
	local offset_x, offset_y, scale = 0, 0, 1
	if self.cfg.with_param == OPEN_FLY_DICT_TYPE.UP then
		offset_x = -(TopRightBtnWidth/2 + TopRightBtnSpacing)
		scale = TopRightBtnScale
		if self.cfg.name == "lianhunview" then
			offset_x = 0
		end
	else
		if YBtnList[self.btn_name] == 1 then
			offset_y = BottomRightBtnHeight/2 + BottomRightBtnYSpacing/2
		else
			offset_x = -(BottomRightBtnWidth/2 + BottomRightBtnXSpacing/2)
		end
		scale = BottomRightBtnScale
	end

	--加上偏移值
	local_pos_tbl.x = local_pos_tbl.x + offset_x * scale
	local_pos_tbl.y = local_pos_tbl.y + offset_y * scale

	--获取目标原始大小
	local target_normal_width = BottomRightBtnWidth
	local target_normal_height = BottomRightBtnHeight
	if self.cfg.with_param == OPEN_FLY_DICT_TYPE.UP then
		target_normal_width = TopRightBtnWidth
		target_normal_height = TopRightBtnHeight
	end

	local move_tween = self.icon_go.rect:DOAnchorPos(local_pos_tbl, MOVE_TIME)
	move_tween:SetEase(DG.Tweening.Ease.OutCubic)

	local size_tween = self.target_rect:DOSizeDelta(Vector2(target_normal_width, target_normal_height), 1)
	size_tween:SetEase(DG.Tweening.Ease.Linear)

	--生成一个dotween队列
	self.sequence = DG.Tweening.DOTween.Sequence()
	self.sequence:Append(move_tween)
	self.sequence:Insert(0.5, size_tween)
	self.sequence:SetUpdate(true)
	self.sequence:OnComplete(function()
		self.is_fly_ani = false
		self:ChangeTargetAlpha(1)
		self:Close()
	end)
end

function TipOpenFunctionFlyView:StopCountDown()
	if self.static_count_down then
		CountDown.Instance:RemoveCountDown(self.static_count_down)
		self.static_count_down = nil
	end
end

--开始倒计时，结束后自动开始移动图标
function TipOpenFunctionFlyView:StartCountDown()
	self:StopCountDown()

	local function time_func(elapse_time, total_time)
		if elapse_time >= total_time then
			self:StartMove()
			self:StopCountDown()
			return
		end
	end

	self.static_count_down = CountDown.Instance:AddCountDown(STATIC_TIME, 1, time_func)
end

--开始移动图标
function TipOpenFunctionFlyView:StartMove()
	--隐藏背景
	self.show_bg:SetValue(false)

	self:MoveToTarget()
end

function TipOpenFunctionFlyView:CloseWindow()
	if not self.is_fly_ani then
		self:Close()
	end
end

--强制开始移动（只有主界面两个收缩动画都完成了才处理）
function TipOpenFunctionFlyView:BlockClick()
	local player_button_ani_state = MainUICtrl.Instance.view:GetPlayerButtonAniState()
	local top_right_button_ani_state = MainUICtrl.Instance.view:GetTopRightButtonAniState()
	if not self.bottom_right_complete then
		self.bottom_right_complete = player_button_ani_state == 1
	end
	if not self.top_right_complete then
		self.top_right_complete = top_right_button_ani_state == 1
	end

	if self.bottom_right_complete and self.top_right_complete then
		self:StopCountDown()
		self:StartMove()
	else
		GlobalEventSystem:Fire(MainUIEventType.CHNAGE_FIGHT_STATE_BTN, false)
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, true)
	end
end