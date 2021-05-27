----------------------------------------------------
-- 进度条，对原始进度条的进一步封装，实现动画
----------------------------------------------------
ProgressBar = ProgressBar or BaseClass()
function ProgressBar:__init()
	self.zorder = -1
	self.view = nil
	self.tail_effect = nil
	self.complete_callback = nil
	self.update_callback = nil
	self.is_tween = false
	self.width = 0
	self.height = 0
	self.start_percent = 0							-- 开始百分比
	self.cur_percent = 0							-- 当前百分比
	self.target_percent = 0							-- 目标百分比
	self.distance = 0								-- target_percent - start_percent
	self.cache_target_percent = nil

	self.total_time = 1								-- 0~100 总时间
	self.effect_offset_x = -10						-- 特效偏移值
	self.effect_offset_y = 0						-- 特效偏移值
	self.tail_effect_def_hide = false
end

function ProgressBar:__delete()
	self:RemoveCountDown()
	self.tail_effect = nil
end

function ProgressBar:SetView(progress_vew)
	self.view = progress_vew
	local size = self.view:getContentSize()
	self.width = size.width
	self.height = size.height
	self:SetPercent(0)
end

function ProgressBar:GetView(view)
	return self.view
end

function ProgressBar:SetEffectOffsetX(effect_offset_x)
	self.effect_offset_x = effect_offset_x
end

function ProgressBar:SetEffectOffsetY(effect_offset_y)
	self.effect_offset_y = effect_offset_y
end

function ProgressBar:SetTailEffect(effect_id, scale, def_hide)
	if self.tail_effect == nil then
		self.tail_effect = AnimateSprite:create()
		self.view:addChild(self.tail_effect, 999, 999)
		self.tail_effect:setScale(scale or 1)
	end
	local path, name = ResPath.GetEffectUiAnimPath(effect_id)
	self.tail_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	self.tail_effect_def_hide = def_hide
	if self.tail_effect_def_hide then
		self.tail_effect:setVisible(false)
	end
end

function ProgressBar:SetTotalTime(total_time)
	self.total_time = total_time
end

function ProgressBar:GetCurPercent()
	return self.cur_percent
end

function ProgressBar:SetPercent(percent, is_tween, retreat)
	if nil == is_tween then is_tween = true end
	self.target_percent = percent

	if is_tween and self.total_time > 0 then
		self.cache_target_percent = nil
		if self.target_percent < self.cur_percent and not retreat then
			self.cache_target_percent = self.target_percent
			self.target_percent = 100
		end

		self:StartTween()
	else
		self.view:setPercent(percent)
		self.cur_percent = percent
		self:UpdateTailEffectPosition()
	end
end

function ProgressBar:SetCompleteCallback(complete_callback)
	self.complete_callback = complete_callback
end

function ProgressBar:SetUpdateCallback(update_callback)
	self.update_callback = update_callback
end

function ProgressBar:StartTween()
	if self.tail_effect and self.tail_effect_def_hide then
		self.tail_effect:setVisible(true)
		self.tail_effect_vis = true
	end
	self.start_percent = self.cur_percent
	self.distance = self.target_percent - self.cur_percent
	if math.abs(self.distance) <= 1 then	-- 间隔太小不处理处画
		self:StopTween()
	else
		local tween_time = self.distance / 100 * self.total_time
		if tween_time <= 0 then tween_time = 0.1 end

		self:RemoveCountDown()
		self.countdown_id = CountDown.Instance:AddCountDown(tween_time, 0.01, BindTool.Bind(self.OnTweening, self))
	end

	self:UpdateTailEffectPosition()
end

function ProgressBar:StopTween()
	if self.tail_effect and self.tail_effect_def_hide then
		if self.timer_quest then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
		end
		self.tail_effect_vis = false
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(function()
					if self.tail_effect then
						self.tail_effect:setVisible(self.tail_effect_vis)
					end
				end, 0.3)
	end
	self:RemoveCountDown()
	self.cur_percent = self.target_percent
	if self.cache_target_percent ~= nil then --继续从头开始
		self.cur_percent = 0
		self.target_percent = self.cache_target_percent
		self.cache_target_percent = nil
		self.view:setPercent(0)
		self:UpdateTailEffectPosition()
		if self.target_percent > 0 then
			self:StartTween()
		end
	else
		self.view:setPercent(self.target_percent)
		self:UpdateTailEffectPosition()
		if self.complete_callback then
			self.complete_callback()
		end
	end
end

function ProgressBar:RemoveCountDown()
	CountDown.Instance:RemoveCountDown(self.countdown_id)
end

function ProgressBar:OnTweening(elapse_time, total_time)
	if elapse_time >= total_time then
		self:StopTween()
	else
		self.cur_percent = self.start_percent + elapse_time / total_time * self.distance
		if (self.distance > 0 and self.cur_percent >= self.target_percent) 
			or (self.distance < 0 and self.cur_percent <= self.target_percent)  then		
			self:StopTween()
		else
			self.view:setPercent(self.cur_percent)
			self:UpdateTailEffectPosition()

			if nil ~= self.update_callback then
				self.update_callback(self.cur_percent)
			end
		end
	end
end

function ProgressBar:UpdateTailEffectPosition()
	if self.tail_effect == nil then return end
	local rate = self.cur_percent / 100
	self.tail_effect:setPosition(rate * self.width + self.effect_offset_x, self.height / 2 + self.effect_offset_y)
end

function ProgressBar:SetBothSideCoverImg(img_path, offset)
	local def_pos_left = {x = 0, y = self.height / 2}
	local img_node_left = XUI.CreateImageView(def_pos_left.x, def_pos_left.y, img_path, XUI.IS_PLIST)
	self.view:addChild(img_node_left, 888, 888)

	local def_pos_right = {x = self.width, y = self.height / 2}
	local img_node_right = XUI.CreateImageView(def_pos_right.x, def_pos_right.y, img_path, XUI.IS_PLIST)
	img_node_right:setScaleX(-1)
	self.view:addChild(img_node_right, 888, 888)

	if offset and offset.x and offset.y then
		img_node_left:setPosition(def_pos_left.x + offset.x, def_pos_left.y + offset.y)
		img_node_right:setPosition(def_pos_right.x + (- offset.x), def_pos_right.y + offset.y)
	end
end
