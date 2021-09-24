acKhzrVo=activityVo:new()
function acKhzrVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acKhzrVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg

             if data._activeCfg.version ~= nil then
                self.version = data._activeCfg.version
            end
        end
       

    	if data.t then
    		self.lastTime =data.t
    	end
        if data.c then
            self.c=data.c
        end
        
        if data.bn then--每个礼包购买次数
            self.bn = data.bn
        end
        if self.bn == nil then
            self.bn ={}
        end

        if data.tc then--累计充值金币
            self.spendGold = data.tc
        end

        if self.spendGold ==nil then
            self.spendGold = 0
        end 
    end

end