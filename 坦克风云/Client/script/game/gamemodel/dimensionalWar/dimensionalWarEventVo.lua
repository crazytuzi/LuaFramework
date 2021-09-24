dimensionalWarEventVo={}
function dimensionalWarEventVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end


function dimensionalWarEventVo:initWithData(id,bid,time,eType,content)
	self.id=tonumber(id) or 0
	self.bid=tonumber(bid) or 0
	self.time=tonumber(update_at) or 0
	self.type=tonumber(eType) or 0
	self.oldStatus=0
	if content then
		if type(content)=="string" then
			content=G_Json.decode(content) or {}
		end
		-- content={
		-- 	1,		--aType：1.行为，2.事件
		-- 	0,		--status：0.生存，1.亡者，2.死亡
		-- 	0,		--action：行动力减少值
		-- 	0,		--point：积分变化
		-- 	1,		--subType：小类型
		-- 	{},		--param：参数
		-- 	1,		--round：回合数
		-- 	0,		--isHigh：是否高级，0不是，1是
		-- }
		if content then
			self.aType=tonumber(content[1]) or 1
			self.status=tonumber(content[2]) or 0
			self.action=tonumber(content[3]) or 0
			self.point=tonumber(content[4]) or 0
			self.subType=tonumber(content[5]) or 1
			self.param=content[6] or {}
			self.round=tonumber(content[7]) or 0
			self.isHigh=tonumber(content[8]) or 0
			self.gold=0
			self.isDie=0
			if self.type==3 and self.aType~=1 and self.subType~=3 then
				self.isBattle=1
			else
				self.isBattle=0
			end
		    if self.param and self.param.point then
		    	self.point=tonumber(self.param.point) or 0
		    elseif self.param and SizeOfTable(self.param)>0 then
		    	for k,v in pairs(self.param) do
		    		if v and type(v)=="table" then
		    			if v.point then
			    			self.point=tonumber(v.point) or 0
		    			else
		    				for m,n in pairs(v) do
		    					if n and type(n)=="table" and n.point then
		    						self.point=tonumber(n.point) or 0
		    					end
		    				end
		    			end
		    		end
		    	end
		    end
		    if self.param and SizeOfTable(self.param)>0 then
				self.oldStatus=self.param[SizeOfTable(self.param)] or 0
				if self.type==5 then
	                self.gold=tonumber(self.param[2]) or 0
	            elseif (self.type==1 or self.type==2) and self.isHigh==1 then
	                self.gold=tonumber(self.param[3]) or 0
	            end
	            local parm=self.param
	            if self.type==1 then
	            	if parm[2] then
	            		self.isDie=tonumber(parm[2]) or 0
	            	end
	            elseif self.type==2 then
	            	if parm and parm[2] then
				    	self.isDie=tonumber(parm[2]) or 0
				    end
				elseif self.type==3 then
					if self.aType==1 then
			    		if parm and parm[1] then
					    	self.isDie=tonumber(parm[1]) or 0
					    end
					else
						if parm and parm[2] then
					    	self.isDie=tonumber(parm[2]) or 0
					    end
					end
				elseif self.type==4 then
			    	if self.subType==1 then
			    		if parm and parm[1] then
					    	self.isDie=tonumber(parm[1]) or 0
					    end
					end
				elseif self.type==5 then
			    	if parm and parm[1] then
				    	self.isDie=tonumber(parm[1]) or 0
				    end
				elseif self.type==6 then
					if self.subType==1 then
				    	if parm and parm[2] then
					    	self.isDie=tonumber(parm[2]) or 0
					    end
					end
	            end
			end
		end
	end
	self.showRound=0
	self.report=nil
end