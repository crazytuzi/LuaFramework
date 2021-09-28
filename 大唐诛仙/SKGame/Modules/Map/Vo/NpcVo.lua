NpcVo =BaseClass(PuppetVo)

function NpcVo:__init( vo )
	self.type = PuppetVo.Type.NPC
	self.isCompleted = true
	self.die = false
end

local fun = "function"
local clz = "_class_type"
--初始
function NpcVo:InitVo( attrs )
	for k, v in pairs(attrs) do
		if type(v) ~= fun and k ~= clz  then
			self[k] = v
		end
	end
end

--更新数据
function NpcVo:UpdateVo( info )
	for k,v in pairs(info) do
		if type(v) ~= fun and k ~= clz then
			if self[k] then
				self:SetValue(k,v,self[k])
			end
		end
	end
end

--设置数值
function NpcVo:SetValue( k,v,old )
	if not self.isCompleted then return end
	if v ~= old then
		self[k] = v
		self:OnChange( k, v, old )
	end
end
function NpcVo:OnChange( key, value, pre )
	if self.isCompleted then
		self:DispatchEvent(SceneConst.OBJ_UPDATE, key, value, pre)
	end
end

--获得表数据
function NpcVo.GetCfg( eid )
	return GetCfgData("npc"):Get(eid)
end

function NpcVo:__delete()
	self.isCompleted = false
	self.die=true
end


