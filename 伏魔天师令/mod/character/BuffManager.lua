local Buff = classGc(function(self)
	
end)

Buff.isBuff=true

function Buff.init( self, _data, _skillId )
	for k,v in pairs(_data) do
		local t = v
		if t ~= nil then
			self[k] = t
			local function get( self )
				return self[k]
			end
			self["get"..k] = get

			local function set( self, _setData )
				self[k] = _setData
			end
			self["set"..k] = set
		end
	end
	self.m_nSkillId = _skillId
	if  self.duration== nil then -- 删除函数 Buff.update
		self.update = nil
	else
		self.m_fDuration = 0
	end
	
end

function Buff.update( self, _duration )
	if self.duration == nil then
		return
	end
	self.m_fDuration = self.m_fDuration + _duration
end
function Buff.isTimeOut( self )
	if self.duration == nil then
		return false
	end
	if self.m_fDuration >= self.duration then
		return true
	end
	return false
end

function Buff.getSkillId(self)
	return self.m_nSkillId
end

_G.GBuffManager = _G.GBuffManager or {}
function GBuffManager.getBuffNewObject( self, _buffID, _skillId )
	local newObject = Buff()
	local skill_buff=_G.Cfg.skill_buff[_buffID]

	if skill_buff==nil then
		return nil
	end

	newObject:init(skill_buff, _skillId )
	newObject.m_buffId=_buffID
	return newObject
end