DoorVo =BaseClass(PuppetVo)

function DoorVo:__init()
	self.type = PuppetVo.Type.Door
	self.objective = Vector3.zero -- 目的地
	self.toScene = 0  --目地场景
	self.toLocation = Vector3.zero --目的地位置
	self.isCompleted = true
end

-- 初始
function DoorVo:InitVo( attrs)
	for k, v in pairs(attrs) do
		if type(v) ~= "function" and k ~= "_class_type"  then
			self[k] = v
		end
	end
end

-- 更新数据
function DoorVo:UpdateVo( info )
	for k, v in pairs(info) do
		if type(v) ~= "function" and k ~= "_class_type" then
			if self[k] then
				self:SetValue( k, v, self[k] )
			end
		end
	end
end

-- 设置数值
function DoorVo:SetValue( k, v, old )
	if not self.isCompleted then return end
	if v ~= old then
		self[k] = v
		self:OnChange( k, v, old )
	end
end
function DoorVo:OnChange( key, value, pre )
	if self.isCompleted then
		self:DispatchEvent(SceneConst.OBJ_UPDATE, key, value, pre)
	end
end

-- 跳转位置
function DoorVo.SkipScene(pData)

end

function DoorVo.GetCfg( eid )
	return GetCfgData("transfer"):Get(eid)
end

function DoorVo:__delete()
	self.isCompleted = false
end

