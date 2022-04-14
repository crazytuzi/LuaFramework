cc = cc or {}

cc.ActionInstant = cc.ActionInstant or class("ActionInstant",cc.FiniteTimeAction)

function cc.ActionInstant:ctor()
    self._classType = "ActionInstant"
end
    
function cc.ActionInstant:isDone()
    return true
end

function cc.ActionInstant:startWithTarget(target)
    cc.FiniteTimeAction.startWithTarget(self, self.real_target or target);
end

function cc.ActionInstant:step(dt)
    self:update(1)
end

function cc.ActionInstant:update(time)
    -- nothing
end

--CallFunc start
cc.CallFunc = cc.CallFunc or class("CallFunc",cc.ActionInstant)

function cc.CallFunc:ctor(call_back)
    self:initWithFunction(call_back)
end

function cc.CallFunc:initWithFunction( call_back )
    self.call_back = call_back
end

function cc.CallFunc:clone()
    return cc.CallFunc.new(self.call_back)
end

function cc.CallFunc:reverse()
    return self:clone()
end

function cc.CallFunc:update(time)
    if self.call_back then
    	self.call_back()
    end
end
--CallFunc end


--Place start
cc.Place = cc.Place or class("Place",cc.ActionInstant)

function cc.Place:ctor(new_x, new_y, new_z)
    self:initWithPosition(new_x, new_y, new_z)
end

function cc.Place:initWithPosition( new_x, new_y, new_z )
    self.new_x = new_x
    self.new_y = new_y
    self.new_z = new_z
end

function cc.Place:clone()
    return cc.Place.new(self.new_x, self.new_y, self.new_z)
end

function cc.Place:reverse()
    return self:clone()
end

function cc.Place:update(time)
    if not self._target then return end
    cc.Wrapper.SetLocalPosition(self._target, self.new_x, self.new_y, self.new_z)
    -- if self.new_x then
    --     self._target:SetVectorL(WidgetProperty.Position, self.new_x)
    -- end

    --  if self.new_y then
    --     self._target:SetVectorR(WidgetProperty.Position, self.new_y)
    -- end
end
--Place end

--Show start
cc.Show = cc.Show or class("Show",cc.ActionInstant)

function cc.Show:ctor(real_target)
    self.real_target = real_target
end

function cc.Show:clone()
    return cc.Show.new(self.real_target)
end

function cc.Show:reverse()
    return cc.Hide.new(self.real_target)
end

function cc.Show:update(time)
    if isClass(self._target) and self._target.SetVisible then
        self._target:SetVisible(true)
    else
        cc.Wrapper.SetVisible(self._target, true)
    end
end
--Show end

--Hide start
cc.Hide = cc.Hide or class("Hide",cc.ActionInstant)

function cc.Hide:ctor(real_target)
    self.real_target = real_target
end

function cc.Hide:clone()
    return cc.Hide(self.real_target)
end

function cc.Hide:reverse()
    return cc.Show(self.real_target)
end

function cc.Hide:update(time)
    if isClass(self._target) and self._target.SetVisible then
        self._target:SetVisible(false)
    else
        cc.Wrapper.SetVisible(self._target, false)
    end
end
--Hide end

--Delete start
cc.Delete = cc.Delete or class("Delete",cc.ActionInstant)

function cc.Delete:ctor(cls)
    self.cls = cls
end

function cc.Delete:clone()
    return cc.Delete.new()
end

function cc.Delete:reverse()
end

function cc.Delete:update()
    if isClass(self.cls) then
        self.cls:destroy()
    else
        cc.Wrapper.destroy(self.cls)
    end
end
--Delete end

--Alpha start
cc.Alpha = cc.Alpha or class("Alpha",cc.ActionInstant)

function cc.Alpha:ctor(new_alpha)
    self:initWithAlpha(new_alpha)
end

function cc.Alpha:initWithAlpha( new_alpha )
    self.new_alpha = new_alpha
end

function cc.Alpha:clone()
    return cc.Alpha.new(self.new_alpha)
end

function cc.Alpha:reverse()
    return self:clone()
end

function cc.Alpha:update(time)
    if not self._target then return end
    cc.Wrapper.SetAlpha(self._target, self.new_alpha)
end
--Alpha end