CommonAction = CommonAction or {}

-- 迷宫寻宝
BOX_JUMP_TIME = 0.8 --宝箱跳动时间
BOX_SCALE_BIG = 2 -- 宝箱放大比例
BOX_JUMP_HEIGHT = 160 --宝箱跳动高度
BOX_SCALE_BIG_TIME = 0.5 -- 宝箱放大时间
BOX_SCALE_SMALL_TIME = 0.2 --宝箱缩小时间


function CommonAction.ShowJumpAction(sprite, height, act_time)
	if not sprite then
		return
	end
	if not sprite.temposX or not sprite.temposY then
		sprite.temposX = sprite:getPositionX()
		sprite.temposY = sprite:getPositionY()
	end

	sprite:stopAllActions()
	sprite:setPosition(cc.p(sprite.temposX, sprite.temposY))
    local actionUp = cc.JumpBy:create(act_time or 2, cc.p(0,0), height or 4, 1)
    sprite:runAction(cc.RepeatForever:create(actionUp))
end

function CommonAction.ShowScaleAction(sprite, scale)
	scale = scale or 1.1
	if not sprite then
		return
	end
	if not sprite.temScale then
		sprite.temScale = sprite:getScale()
	end

	sprite:stopAllActions()
	sprite:setScale(sprite.temScale)
	local scale_up = cc.ScaleTo:create(BOX_SCALE_BIG_TIME, scale)
    local scale_down = cc.ScaleTo:create(BOX_SCALE_BIG_TIME, sprite:getScale())
    local actionseq = cc.Sequence:create(scale_up, scale_down)
    sprite:runAction(cc.RepeatForever:create(actionseq))
end

function CommonAction.ShowMoveAction(sprite, ccp)
	if not sprite then
		return
	end
	if not sprite.temposX or not sprite.temposY then
		sprite.temposX = sprite:getPositionX()
		sprite.temposY = sprite:getPositionY()
	end
	ccp = ccp or cc.p(8, -3)
	sprite:stopAllActions()
	sprite:setPosition(cc.p(sprite.temposX, sprite.temposY))
    local actionMov = cc.MoveBy:create(1, ccp)
    local move_back = actionMov:reverse()
    local seq = cc.Sequence:create(actionMov, move_back)
    sprite:runAction(cc.RepeatForever:create(seq))
end

function CommonAction.ShowBoxJumpAction(sprite, fun)
	if not sprite then
		return
	end
	if not sprite.temposX or not sprite.temposY then
		sprite.temposX = sprite:getPositionX()
		sprite.temposY = sprite:getPositionY()
	end

	sprite:stopAllActions()
	sprite:setPosition(cc.p(sprite.temposX, sprite.temposY))

    local actionUp = cc.JumpBy:create(BOX_JUMP_TIME, cc.p(0,0), BOX_JUMP_HEIGHT, 1)
    local actionscale = cc.ScaleBy:create(BOX_SCALE_BIG_TIME, BOX_SCALE_BIG)
    local actionscale_back = cc.ScaleTo:create(BOX_SCALE_SMALL_TIME, 1)
    local seq = cc.Sequence:create(actionscale, actionscale_back)
    local actionspawn = cc.Spawn:create(actionUp, seq)
    if nil ~= fun then
		local callfun = cc.CallFunc:create(fun)
		local act1 = cc.DelayTime:create(BOX_SCALE_SMALL_TIME/2)
	    sprite:runAction(cc.Sequence:create(actionspawn, act1, callfun))
	else
	    sprite:runAction(actionspawn)
	end
end

-- 提醒闪烁动画
function CommonAction.ShowRemindBlinkAction(sprite)
	if not sprite then
		return
	end
	local fade_in = cc.FadeIn:create(0.3)
	local fade_out = cc.FadeOut:create(0.7)
	local sequence = cc.Sequence:create(fade_in, fade_out)
	local forever = cc.RepeatForever:create(sequence)
	sprite:runAction(forever)
end

function CommonAction.ShowShakeAction(sprite, time, shake_strength, shake_times, shake_frequency, fun)
	if not sprite then
		return
	end

	local pos_x, pos_y = sprite:getPosition()
	sprite.shake_data = {
		prve_shake_time = 0,
		shake_frequency = shake_frequency or 0,			-- 抖动时间间隔
		cur_shake_step = 1,
		shake_strength = shake_strength or 5,			-- 抖动强度
		shake_times = shake_times or 15,				-- 抖动次数
		shake_center = {x = pos_x, y = pos_y},
		end_time = NOW_TIME + (time or shake_times or 15),	-- 运行时长
		end_func = fun,
	}
	sprite:registerScriptHandler(function(event_text)
		if "cleanup" == event_text then
			sprite.shake_data = nil
		end
	end)
	sprite:scheduleUpdateWithPriorityLua(function(delta)
		local shake_data = sprite.shake_data
		if nil ~= shake_data and NOW_TIME - shake_data.prve_shake_time > shake_data.shake_frequency then
			shake_data.prve_shake_time = NOW_TIME

			if (shake_data.cur_shake_step > shake_data.shake_times) or (NOW_TIME > shake_data.end_time) then
				sprite:setPosition(shake_data.shake_center.x, shake_data.shake_center.y)
				if nil ~= shake_data.end_func then
					shake_data.end_func()
				end
				sprite.shake_data = nil
			else
				local x = shake_data.shake_center.x + math.random(- shake_data.shake_strength, shake_data.shake_strength)
				local y = shake_data.shake_center.y + math.random(- shake_data.shake_strength, shake_data.shake_strength)
				sprite:setPosition(x, y)
				shake_data.cur_shake_step = shake_data.cur_shake_step + 1
			end
		end
	end, 1)
end
