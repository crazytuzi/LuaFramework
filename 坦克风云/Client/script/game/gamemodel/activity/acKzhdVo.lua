acKzhdVo=activityVo:new()
function acKzhdVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acKzhdVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
   
    	if data.t then
    		self.lastTime =data.t
    	end
        if data.c then
            self.c=data.c
        end
        if data.rd then
            self.rd=data.rd
        end
    end

end