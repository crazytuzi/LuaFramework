-- 
-- @Author: LaoY
-- @Date:   2018-08-13 20:35:56
-- 场景模型相关 action

ccm = ccm or {}


--ShaderFloatBy start
ccm.ShaderFloatBy = ccm.ShaderFloatBy or class("ShaderFloatBy",cc.ActionInterval)
function ccm.ShaderFloatBy:ctor(duration,materials,name,start_value,delta_value)
	self:initWithDuration(duration,materials,name,start_value,delta_value)
end

function ccm.ShaderFloatBy:initWithDuration(duration,materials,name,start_value,delta_value)
	ccm.ShaderFloatBy.super.initWithDuration(self, duration)
	-- c#数组转成lua table
	if materials.Length then
		self.materials = {}
		for i=0,materials.Length - 1 do
			self.materials[#self.materials+1] = materials[i]
		end
	else
		self.materials = materials
	end
	self.name = name
	self.start_value = start_value
	self.delta_value = delta_value
end

function ccm.ShaderFloatBy:clone()
	return ccm.ShaderFloatBy(self._duration,self.materials,self.start_value,self.delta_value)
end

function ccm.ShaderFloatBy:reverse()
	return ccm.ShaderFloatBy(self._duration,self.materials,self.start_value + self.delta_value,-self.delta_value)
end

function ccm.ShaderFloatBy:update(t)
	local cur_value = self.start_value + self.delta_value * t
	for k,material in pairs(self.materials) do
		material:SetFloat(self.name,cur_value)
	end
end
--ShaderFloatBy end

--ShaderFloatTo start
ccm.ShaderFloatTo = ccm.ShaderFloatTo or class("MoveTo",ccm.ShaderFloatBy)
function ccm.ShaderFloatTo:ctor(duration,materials,name,start_value,to_value)
    self:initWithPos(duration,materials,name,start_value,to_value)
end

function ccm.ShaderFloatTo:initWithPos(duration,materials,name,start_value,to_value)
    ccm.ShaderFloatTo.super.initWithPos(self,duration,materials,name,start_value,to_value - start_value)
end

function ccm.ShaderFloatTo:reverse()
    print("reverse() not supported in MoveTo")
    return nil
end
--ShaderFloatTo end