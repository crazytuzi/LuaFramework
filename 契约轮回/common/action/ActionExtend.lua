--非cocos自带的扩展action统一放这里
cc = cc or {}

cc.NumberBy = cc.NumberBy or class("NumberBy",cc.ActionInterval)

--isInteger表示数字是否以整数改变 
function cc.NumberBy:ctor(duration, start_num,deltaNum, isInteger,fmt,real_target)
    self:initWithDuration(duration,start_num,deltaNum, isInteger,fmt,real_target)
end

function cc.NumberBy:initWithDuration(duration,start_num,deltaNum, isInteger,fmt,real_target)
    cc.ActionInterval.initWithDuration(self, duration,real_target)
    if isInteger == nil then
    	isInteger = true
    end
    self.start_num = start_num
    self.deltaNum = deltaNum
    self.isInteger = isInteger
    self.fmt = fmt
    self.cur_num = start_num or 0
end

function cc.NumberBy:clone()
    return cc.NumberBy(self._duration, self.deltaNum, self.isInteger)
end

function cc.NumberBy:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    if self.start_num then
        self.previousNum =  self.start_num
    elseif isClass(self._target) then
        if self._target.GetNumber then
            self.previousNum = self._target:GetNumber()
        end
    else
        self.previousNum = tonumber(self._target.text)
    end
    if not self.previousNum then
        self.previousNum = 0
    end
    self.cur_num = self.previousNum
end

function cc.NumberBy:reverse()
    return cc.NumberBy(self._duration, -self.deltaNum, self.isInteger)
end

function cc.NumberBy:update(t)
    if (self._target) then
    	local newNum = self.previousNum + self.deltaNum * t
        self.cur_num = newNum
        if self.isInteger then
            newNum = math.floor(newNum)
        end
        if self.fmt then
            newNum = string.format(self.fmt,newNum)
        end
        -- print("Cat:CCActionExtend.lua [36] newNum,self.isInteger,self.previousNum,self.deltaNum: ",newNum,self.isInteger,self.previousNum,self.deltaNum)
        if isClass(self._target) then
            if self._target.SetNumber then
                self._target:SetNumber(newNum)
            end
        else
            self._target.text = newNum
        end
    end
end


cc.NumberTo = cc.NumberTo or class("NumberTo",cc.NumberBy)

--isInteger表示数字是否以整数改变 
function cc.NumberTo:ctor(duration,start_num, targetNum, isInteger,fmt,real_target)
    self:initWithDuration(duration,start_num,targetNum, isInteger,fmt,real_target)
end

function cc.NumberTo:initWithDuration(duration,start_num,targetNum, isInteger,fmt,real_target)
    cc.ActionInterval.initWithDuration(self, duration,real_target)
    if isInteger == nil then
    	isInteger = true
    end
    self.start_num = start_num
    self.isInteger = isInteger
    self.targetNum = targetNum
    self.fmt = fmt
    self.cur_num = start_num or 0
end

function cc.NumberTo:clone()
    return cc.NumberTo(self._duration, self.targetNum, self.isInteger)
end

function cc.NumberTo:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    if self.start_num then
        self.previousNum =  self.start_num
    elseif isClass(self._target) then
        if self._target.GetNumber then
            self.previousNum = self._target:GetNumber()
        end
    else
        self.previousNum = tonumber(self._target.text)
    end
    if not self.previousNum then
        self.previousNum = 0
    end
    self.cur_num = self.previousNum
    self.deltaNum = self.targetNum-self.previousNum
end

function cc.NumberTo:reverse()
    return nil
end

--Value start
--Slider等属性
cc.ValueBy = cc.ValueBy or class("ValueBy",cc.ActionInterval)

function cc.ValueBy:ctor(duration, deltaValue,real_target,key)
    self:initWithDuration(duration, deltaValue,real_target,key)
end

function cc.ValueBy:initWithDuration(duration, deltaValue,real_target,key)
    cc.ActionInterval.initWithDuration(self, duration,real_target)
    self.deltaValue = deltaValue
    self.key = key or "value"
    -- self.fmt = fmt
end

function cc.ValueBy:clone()
    return cc.ValueBy(self._duration, self.deltaValue)
end

function cc.ValueBy:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    self.previousValue = self._target[self.key]
end

function cc.ValueBy:reverse()
    return cc.ValueBy(self._duration, -self.deltaValue)
end

function cc.ValueBy:update(t)
    if (self._target) then
        local newValue = self.previousValue + self.deltaValue * t
        self._target[self.key] = newValue
    end
end


cc.ValueTo = cc.ValueTo or class("ValueTo",cc.ValueBy)
function cc.ValueTo:ctor(duration,targetValue,real_target,key)
    self:initWithDuration(duration,targetValue,real_target,key)
end

function cc.ValueTo:initWithDuration(duration,targetValue,real_target,key)
    cc.ActionInterval.initWithDuration(self,duration,real_target)
    self.targetValue = targetValue
    self.key = key or "value"
end

function cc.ValueTo:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
    self.previousValue = self._target[self.key]
    self.deltaValue = self.targetValue - self.previousValue
end
--Value end

--[[
    @author LaoY
    @des    闪烁 时间，次数
    @param1 时间 总时间，如果次数大于等于999，表示单次闪烁的时间
    @param2 次数 大于等于999表示无限闪烁
    @param3 指定对象，可不填
    @return action
--]]
cc.Blink = cc.Blink or class("Blink")
function cc.Blink:Create(duration,count,target)
    if not count or count <= 0 then
        return
    end
    if count == 1 then
        return  cc.Sequence(cc.Hide(target),cc.DelayTime(duration),cc.Show(target))
    elseif count >= 999 then
        local per_time = duration/(2)
        local action = cc.Sequence(cc.Hide(target),cc.DelayTime(per_time),cc.Show(target),cc.DelayTime(per_time))
        return cc.RepeatForever(action)
    else
        local per_time = duration/(count*2)
        local action = cc.Sequence(cc.Hide(target),cc.DelayTime(per_time),cc.Show(target),cc.DelayTime(per_time))
        return cc.Repeat(action,count)
    end
end

--不断地移动并渐现的动作
cc.FloatFadeIn = cc.FloatFadeIn or {}
function cc.FloatFadeIn.New(start_x, start_y, offset_x, offset_y, float_duration, stay_duration)
    float_duration = float_duration or 1.0
    stay_duration = stay_duration or 1.0
    start_x = start_x or 0
    start_y = start_y or 0
    offset_x = offset_x or 0
    offset_y = offset_y or -50

    local move_up = cc.MoveBy.New(float_duration, offset_x, offset_y)
	local fadIn = cc.FadeIn.New(float_duration)
	local action = cc.Spawn.New(move_up, fadIn)
	action = cc.Sequence.New(action, cc.DelayTime.New(stay_duration), cc.Place.New(start_x, start_y), cc.Alpha.New(0.0))
	action = cc.RepeatForever.New(action)
    return action
end

--[[
<*
    @Author:        LaoY
    @Description:   获取通用scale运动 支持普通widget
    @param:         pos 初始坐标 格式[x,y]
    @param:         size 初始大小 格式[x,y]
    @param:         scale 缩放值
    @param:         time 运动时间
    @return:        action
*>
]]
cc.Scale = cc.Scale or {}
function cc.Scale.New(pos,size,scale,time)
    local x,y = pos.x,pos.y
    local offx = (size.x - size.x * scale)/2
    local offy = (size.y - size.y * scale)/2
    local to_x,to_y = x + offx,y + offy
    local size_action = cc.SizeTo.New(time,size.x * scale , size.y * scale)
    local move_action = cc.MoveTo.New(time,to_x , to_y)
    return cc.Spawn.New(size_action , move_action)
end

cc.ScaleX = cc.ScaleX or {}
function cc.ScaleX.New(pos,size,scale,time)
    local x,y = pos.x,pos.y
    local offx = (size.x - size.x * scale)/2
    local offy = (size.y - size.y * scale)/2
    local to_x,to_y = x + offx,y
    local size_action = cc.SizeTo.New(time,size.x * scale , size.y)
    local move_action = cc.MoveTo.New(time,to_x ,y)
    return cc.Spawn.New(size_action , move_action)
end

--[[
<*
    @Author:        LaoY
    @Description:   宝箱抖动效果
    @param:         time 运动时间
    @param:         node 运动节点
    @param:         rotation 旋转角度
    @param:         height 浮动高度
    @param:         count  运动次数
    @return:        action
*>
]]
cc.Shake = cc.Shake or {}
function cc.Shake.New(time ,node, rotation , height , count)
    local x,y = node:GetVectorValue(WidgetProperty.Position)
    local rotation_r = cc.RotateTo.New(time,rotation)
    local move_up    = cc.MoveTo.New(time,x,y-height)
    local action_1   = cc.Spawn.New(rotation_r,move_up)
    local rotation_l = cc.RotateTo.New(time,-rotation)
    local move_down  = cc.MoveTo.New(time,x,y+height)
    local action_2   = cc.Spawn.New(rotation_l,move_down)
    local action = cc.Sequence.New(action_1,action_2)
    return count and cc.Repeat.New(action,count) or cc.RepeatForever.New(action)
end

cc.FlyToRandom = cc.FlyToRandom or {}
--optional里面有好几个参数可配置，不填的话就用默认的
function cc.FlyToRandom.New(start_pos, end_pos, optional)
    optional = optional or {}
    local min_duration = optional.min_duration or 0.5
    local rand_duration = optional.rand_duration or 0.8
    local duration = min_duration + math.random()*rand_duration
    local stay_duration = optional.stop_duration or 0.5--飞到背包后停留多久
    local is_auto_delete = optional.auto_delete or true
    local need_flash_on_end = optional.need_flash_on_end or true--到背包后需要闪一下
    --需要在开始和终点算出随机的中间点，使其成为曲线
    local middlePos = GameMath.GetVecLerp(start_pos, end_pos, 0.5)
    local rotate_angle = 90
    local add_or_minus = math.random(1,2)
    if add_or_minus <= 1 then
        rotate_angle = -rotate_angle
    end
    local controlPos = GameMath.RotateByAngle(start_pos, middlePos, rotate_angle)
    local randNum = 0.7*math.random()+0.1
    controlPos = GameMath.GetVecLerp(middlePos, controlPos, randNum)

    local action = cc.BezierTo.New(duration, {end_pos=end_pos,control_1=controlPos,control_2=controlPos})
    -- action = cc.EaseQuadraticActionIn.New(action)
    action = cc.EaseQuarticActionIn.New(action)
    -- action = cc.EaseQuinticActionIn.New(action)
    -- action = cc.EaseQuarticActionIn.New(action)
    if need_flash_on_end then
        local function on_end_callback(  )
            GlobalEventSystem:Fire(EventName.BASE_WEALTH_ADD_AFTER, "good")
        end
        local move_end_action = cc.CallFunc.New(on_end_callback)
        action = cc.Sequence.New(action, move_end_action)
    end
    action = cc.Sequence.New(action, cc.DelayTime.New(stay_duration))
    if is_auto_delete then
        action = cc.Sequence.New(action, cc.Delete.New())
    end

    return action
end

cc.FlyToBgRandom = cc.FlyToBgRandom or {}
function cc.FlyToBgRandom.New(start_pos, optional)
    local view_size = Game.UI:GetScreenView()
    local end_pos = {x=view_size.x-177, y=view_size.y-383}--背包坐标
    return cc.FlyToRandom.New(start_pos, end_pos, optional)
end

--ScrollBy start
cc.ScrollBy = cc.ScrollBy or class("ScrollBy",cc.ActionInterval)

function cc.ScrollBy:ctor(duration, delta_x,delta_y)
    self:initWithDuration(duration, delta_x,delta_y)
end

function cc.ScrollBy:clone()
    return cc.ScrollBy.New(self._duration, self._positionDeltaX,self._positionDeltaY)
end

function cc.ScrollBy:reverse()
    return cc.ScrollBy.New(self._duration, -self._positionDeltaX,-self._positionDeltaY)
end

function cc.ScrollBy:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)

    if target.GetVectorValue then
        self._previousPositionX,self._previousPositionY = target:GetVectorValue(ScrollViewProperty.CanvasPosition)
    end
    -- print("Cat:ActionInterval [128] self._previousPositionX,self._previousPositionY: ",self._previousPositionX,self._previousPositionY,target.GetVectorValue,target.getPositionValue,target.getPosition)
    self._startPositionX,self._startPositionY = self._previousPositionX,self._previousPositionY
end

function cc.ScrollBy:update(t)
   if self._target then
        local currentPosX,currentPosY = 0, 0
        if self._target.GetVectorValue then
            currentPosX,currentPosY = self._target:GetVectorValue(ScrollViewProperty.CanvasPosition)
        end
        local diffX = currentPosX - self._previousPositionX
        local diffY = currentPosY - self._previousPositionY
        local newPosX = self._startPositionX + (self._positionDeltaX * t)
        local newPosY = self._startPositionY + (self._positionDeltaY * t)
        -- self._target:SetVectorValue(WidgetProperty.Position,newPosX,newPosY)
        if self._target.SetVectorValue then
            self._target:SetVectorValue(ScrollViewProperty.CanvasPosition, newPosX, newPosY)
        end
        self._previousPositionX = newPosX
        self._previousPositionY = newPosY
    end
end

function cc.ScrollBy:initWithDuration(duration,delta_x,delta_y)
    cc.ActionInterval.initWithDuration(self,duration)
    self._positionDeltaX = delta_x
    self._positionDeltaY = delta_y
end

--ScrollBy end

--ScrollTo start
cc.ScrollTo = cc.ScrollTo or class("ScrollTo",cc.ScrollBy)
function cc.ScrollTo:ctor(duration, x, y)
    self:initWithPos(duration, x, y)
end

function cc.ScrollTo:initWithPos(duration, x, y)
    cc.ActionInterval.initWithDuration(self, duration)
    self._endPositionX = x
    self._endPositionY = y
end

function cc.ScrollTo:clone()
    return cc.ScrollTo.New(self._duration, self._endPositionX, self._endPositionY)
end

function cc.ScrollTo:startWithTarget(target)
    cc.ScrollBy.startWithTarget(self, target)
    local oldX,oldY = target:GetVectorValue(ScrollViewProperty.CanvasPosition)
    self._positionDeltaX = self._endPositionX - oldX
    self._positionDeltaY = self._endPositionY - oldY
end

function cc.ScrollTo:reverse()
    print("reverse() not supported in ScrollTo")
    return nil
end
--ScrollTo end


--FontBy start
cc.FontBy = cc.FontBy or class("FontBy",cc.ActionInterval)

function cc.FontBy:ctor(duration, font)
    self:initWithDuration(duration, font)
end

function cc.FontBy:clone()
    return cc.FontBy.New(self._duration, font)
end

function cc.FontBy:reverse()
    return cc.FontBy.New(self._duration, -self._positionDeltaX,-self._positionDeltaY)
end

function cc.FontBy:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)

    if target.GetInt then
        self._prefont = target:GetInt(TextBoxProperty.FontSize)
    end
    self._start_font = self._prefont
end

function cc.FontBy:update(t)
   if self._target then
        local cut_font = 0
        if self._target.GetInt then
            cut_font = self._target:GetInt(TextBoxProperty.FontSize)
        end
        local new_font = self._start_font + (self._font * t)
        if self._target.SetInt then
            self._target:SetInt(TextBoxProperty.FontSize, new_font)
        end
        self._prefont = new_font
    end
end

function cc.FontBy:initWithDuration(duration,font)
    cc.ActionInterval.initWithDuration(self,duration)
    self._font = font
end

--FontBy end

--FontTo start
cc.FontTo = cc.FontTo or class("FontTo",cc.FontBy)
function cc.FontTo:ctor(duration, font)
    self:initWithFont(duration, font)
end

function cc.FontTo:initWithFont(duration, font)
    cc.ActionInterval.initWithDuration(self, duration)
    self._end_font = font
end

function cc.FontTo:clone()
    return cc.FontTo.New(duration, font)
end

function cc.FontTo:startWithTarget(target)
    cc.FontBy.startWithTarget(self, target)

    local old_font = target:GetInt(TextBoxProperty.FontSize)
    self._font = self._end_font - old_font
end

function cc.FontTo:reverse()
    print("reverse() not supported in FontTo")
    return nil
end
--FontTo end

cc.FontToAction = cc.FontToAction or {}
function cc.FontToAction.New(pos,cur_font,font,time)
    local x,y = pos.x,pos.y
    local offx = (cur_font - font)
    local offy = (cur_font - font)
    local to_x,to_y = x + offx,y + offy
    local size_action = cc.FontTo.New(time,font)
    local move_action = cc.MoveTo.New(time,to_x , to_y)
    return cc.Spawn.New(size_action , move_action)
end

--[[
Author:LZR
Description:短距离滑入动画
parameters
    [1] = 时间
    [2] = 节点
    [3] = 移动方式
    [4] = 偏移值
    ]]
--SweepAction start
cc.SweepAction = cc.SweepAction or {}
function cc.SweepAction.New(time,obj,move_type,offset,fadein)
    time = time or 1
    offset = offset or 100
    move_type = move_type or "down"
    if fadein then
        obj:SetFloat(WidgetProperty.Alpha, 0)
    end
    local endx,endy = obj:GetVectorValue(WidgetProperty.Position)
    local start_x,start_y = endx,endy

    if move_type == "down" then
        start_y = start_y - offset
    elseif move_type == "up" then
        start_y = start_y + offset
    elseif move_type == "left" then
        start_x = start_x + offset
    else
        start_x = start_x - offset
    end
    obj:SetVectorValue(WidgetProperty.Position,start_x,start_y)

    local action = cc.MoveTo.New(time,endx, endy)
    if fadein then
        action = cc.Spawn.New(action, cc.FadeIn.New(time/2))
    end
    local elastic_in_time = 3
    local elastic_out_time = 5
    action = cc.EaseElasticIn.New(action,elastic_in_time)
    action = cc.EaseElasticOut.New(action,elastic_out_time)
    local call_func = cc.CallFunc.New(cc.ActionManager:getInstance():removeAllActionsFromTarget(obj))
    action = cc.Sequence.New(action, call_func)
    return action
end
--SweepAction end

--[[
Author:LZR
Description:虎躯一震(心跳效果)
parameters
    [1] = 时间
    [2] = 对象
    [3] = 延迟时间
    [3] = 收缩比例
    [4] = 放大比例
    [5] = 行为时间比例{收缩时长，放大时长，复原时长}
    ]]
--HeartBeat start
cc.HeartBeat = cc.HeartBeat or {}
function cc.HeartBeat.New(time,obj,delay_time,scaleInfo1,scaleInfo2,time_auto)
    if obj == nil then return end
    delay_time = delay_time or 0
    time = time or 1
    scaleInfo = scaleInfo or 0.9
    scaleInfo2 = scaleInfo2 or 1.1
    time_auto = time_auto or {30,20,40}
    local scaleNum = scaleInfo
    local x,y = obj:GetVectorValue(WidgetProperty.Position)
    local sx,sy = obj:GetVectorValue(WidgetProperty.Size)

    local function getmovepos(scale)
        local _sx,_sy = obj:GetVectorValue(WidgetProperty.Size)
        local new_sx,new_sy = _sx * scale, _sy * scale
        local mx,my = (_sx - new_sx)/2, (_sy - new_sy)/2
        return mx,my
    end
    local action1,action2,action3
    local action1_1 = cc.SizeTo.New(time*(time_auto[1]/100), sx*scaleNum,sy*scaleNum)
    local _x,_y = getmovepos(scaleNum)
    local action1_2 = cc.MoveTo.New(time*(time_auto[1]/100), x+_x,y+_y)
    action1 = cc.Spawn.New(action1_1, action1_2)
    action1 = cc.EaseSineIn.New(action1)

    scaleNum2 = (1/scaleInfo * scaleInfo2)
    local action2_1 = cc.SizeTo.New(time*(time_auto[2]/100), sx*scaleNum2,sy*scaleNum2)
    _x,_y = getmovepos(scaleNum2)
    local action2_2 = cc.MoveTo.New(time*(time_auto[2]/100), x+_x,y+_y )
    action2 = cc.Spawn.New(action2_1, action2_2)
    action2 = cc.EaseSineOut.New(action2)

    scaleNum3 = (1/(1/scaleInfo * scaleInfo2))
    local action_3_1 = cc.SizeTo.New(time*(time_auto[3]/100), sx,sy)
    local action_3_2 = cc.MoveTo.New(time*(time_auto[3]/100), x,y)
    action3 = cc.Spawn.New(action_3_1, action_3_2)
    action3 = cc.EaseSineOut.New(action3)

    local action = cc.Sequence.New(cc.DelayTime.New(delay_time),action1, action2, action3)
    return action
end
--HeartBeat end

--暂时废弃
--Ellipse 椭圆运动
cc.Ellipse = cc.Ellipse or class("Ellipse",cc.ActionInterval)
function cc.Ellipse:ctor(config)
    self.config = config
    self:initWithDuration(config.time)
end

function cc.Ellipse:clone()
    return cc.Ellipse.New(self.config)
end

function cc.Ellipse:reverse()
    self.config.moveInAnticlockwise = not self.config.moveInAnticlockwise
    return cc.Ellipse.New(self.config)
end

function cc.Ellipse:startWithTarget(target)
    cc.ActionInterval.startWithTarget(self, target)
end

function cc.Ellipse:update(t)
   if self._target then
        local p = self._target.ellipse_p or 0
        local x = self.config:GetPositionXAtOval(t + p)
        local y = self.config:GetPositionYAtOval(t + p)
        cc.Wrapper.SetLocalPosition(self._target,x,y)
   end
end

function cc.Ellipse:initWithDuration(duration)
    cc.ActionInterval.initWithDuration(self,duration)
end