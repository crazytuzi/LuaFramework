acHuoxianmingjiangVo = activityVo:new()

function acHuoxianmingjiangVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end


function acHuoxianmingjiangVo:updateSpecialData(data)
	if data~=nil then
    	if data.cost then
    		self.cost = data.cost
    	end
    	if data.value then
    		self.value = data.value
    	end
    	if data.t then
    		self.lastTime = data.t
    	end 
        if data.mustGetHero then
            self.mustGetHero = data.mustGetHero
        end
        if data.s then 
            self.star = data.s
        end  
        
        if data.version then
            self.version =data.version
        end 	

    end
end
