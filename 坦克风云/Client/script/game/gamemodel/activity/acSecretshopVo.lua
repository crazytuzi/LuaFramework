acSecretshopVo=activityVo:new()
function acSecretshopVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acSecretshopVo:updateSpecialData(data)
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
        if data.rd then -- 购买刷新信息
            self.rd=data.rd
        end
        if data.list then
            self.changeList=data.list
        end
    end

end