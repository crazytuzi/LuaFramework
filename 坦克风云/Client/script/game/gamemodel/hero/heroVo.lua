heroVo={}
function heroVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.taskID=nil				--授勋任务的ID
	nc.taskProceed=0			--授勋任务的进度
	return nc
end

function heroVo:initWithData(hid,tb)
	-- 英雄的等级,英雄的等级点数,英雄的品阶，英雄的技能
	if tb~=nil then
		self.hid=hid
		self.level=tb[1]
		self.points=tb[2]
		self.productOrder=tonumber(tb[3])
		self.skill=tb[4]
		self.honorSkill={}			--当前使用的领悟技能
		if(tb[5] and type(tb[5])=="table")then
			for k,v in pairs(tb[5]) do
				if(type(v)=="table")then
					for sid,lv in pairs(v) do
						table.insert(self.honorSkill,{sid,tonumber(lv)})
					end
				else
					table.insert(self.honorSkill,{k,tonumber(v)})
				end
			end
		end
		self.realiseNum=tb[6] or 0	--领悟次数
		if(tb[7] and type(tb[7])=="table")then
			for k,v in pairs(tb[7]) do
				if(type(v)=="table")then
					for sid,lv in pairs(v) do
						table.insert(self.honorSkill,{sid,tonumber(lv)})
					end
				end
			end
		end
		self.realiseID=tb[8]	--当前领悟的备选技能是领悟的第几个授勋技能，一次授勋是nil，二次授勋是2
	end
end

soulVo={}
function soulVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function soulVo:initWithData(sid,num)
	self.sid=sid
	self.num=num
	local maxNum=heroListCfg[heroCfg.soul2hero[self.sid]].fusion.soul[self.sid]
	if self.num>=maxNum then
		self.sortId=9999
	else
		self.sortId=num
	end

end