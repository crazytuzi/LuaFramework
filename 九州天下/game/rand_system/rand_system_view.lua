RandSystemView = RandSystemView or BaseClass(BaseView)

local interval = 0.1			--移动间隔
local distance = 3				--每次移动距离

function RandSystemView:__init()
	self.ui_config = {"uis/views/randsystemview","RandSystemView"}
	self.view_layer = UiLayer.Pop
end

function RandSystemView:__delete()
end

function RandSystemView:ReleaseCallBack()
	-- 清理变量和对象
	self.effect_1 = nil
	self.effect_2 = nil
	self.effect_parent = nil
	self.content_obj = nil
	self.content = nil
end

function RandSystemView:LoadCallBack()
	--获取对象
	self.effect_1 = self:FindObj("Effect1")
	self.effect_2 = self:FindObj("Effect2")
	self.effect_parent = self:FindObj("EffectParent")
	self.content_obj = self:FindObj("ContentObj")

	-- 获取变量
	self.content = self:FindVariable("Content")
end

function RandSystemView:StartDoTween()
	local parent_rect = self.effect_parent.rect.rect
	--获取特效可移动的最大宽度和最大高度
	local can_move_max_width = parent_rect.width
	local can_move_max_height = parent_rect.height

	local half_can_move_max_width = can_move_max_width/2
	local half_can_move_max_height = can_move_max_height/2

	--先初始化特效位置
	local effect_1_rect = self.effect_1.rect
	local effect_2_rect = self.effect_2.rect
	effect_1_rect.localPosition = Vector2(-half_can_move_max_width, -half_can_move_max_height)
	effect_2_rect.localPosition = Vector2(half_can_move_max_width, half_can_move_max_height)

	--现在特效所在的位置
	local function complete()
		local effect_1_position = effect_1_rect.localPosition
		local effect_2_position = effect_2_rect.localPosition

		self.tweener1 = nil
		if effect_1_position.x <= -half_can_move_max_width and effect_1_position.y <= -half_can_move_max_height then
			--左下角
			self.tweener1 = effect_1_rect:DOAnchorPosX(effect_1_position.x+can_move_max_width, 10, false)
		end
		self.tweener1:SetEase(DG.Tweening.Ease.Linear)
		self.tweener1:OnComplete(complete)
	end
	-- complete()
end

function RandSystemView:OpenCallBack()
	local show_index = RandSystemData.Instance:GetLastShowIndex()
	local notice_info = RandSystemData.Instance:GetNoticeInfoByIndex(show_index)
	local notice = notice_info.notice_dec or ""
	self.content:SetValue(notice)
	-- GlobalTimerQuest:AddDelayTimer(function()
		-- self:StartDoTween()
	-- end, 0)
end

function RandSystemView:CloseCallBack()
	if self.tweener1 then
		self.tweener1:Pause()
	end
end