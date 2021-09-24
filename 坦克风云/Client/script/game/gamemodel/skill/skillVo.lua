--指挥官技能的数据vo
skillVo={}
function skillVo:new(sid)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.sid=sid
	nc.cfg=playerSkillCfg.skillList[sid]
	return nc
end

function skillVo:initWithData(lv)
	self.lv=tonumber(lv) or 0
end