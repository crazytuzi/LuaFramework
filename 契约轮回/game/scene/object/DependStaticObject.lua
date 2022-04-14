--
-- @Author: LaoY
-- @Date:   2019-10-08 10:05:17
-- 附属对象基 静止的对象 比如翅膀 神兵 神灵 等挂在人身上的
-- 不需要跟随 不需要旋转

DependStaticObject = DependStaticObject or class("DependStaticObject",DependObjcet)

function DependStaticObject:ctor()

	-- self.check_follow_range_square = 100 * 100
	-- self.smooth_time = 0.45
	-- self.stop_check_offset_time = 5
	-- self.follow_angle = 135


	self:SetPosition()
	self:SetBodyPosition(0,0)
	self:ResetParent()
	SetLocalRotation(self.model_parent, 0, 0, 0)
	SetLocalPosition(self.model_parent,0,0,0)
	SetLocalPosition(self.parent_transform,0,0,0)

	self:ChangeBody()
end

function DependStaticObject:ResetParent()
end

function DependStaticObject:dctor()
end

function DependStaticObject:SetRotateX()
end

function DependStaticObject:SetRotateY()
end

function DependStaticObject:SetRotateZ()
end

function DependStaticObject:SetBodyPosition()
end

function DependStaticObject:UpdatePosition()
end

function DependStaticObject:CheckAngle()
end

function DependStaticObject:SetPosition()
	if self.position.x == 0 and self.position.y == 0 then
		return
	end
	self.position.x = 0
	self.position.y = 0
	self.position.z = 0
	SetLocalPosition(self.parent_transform,0,0,0)
end