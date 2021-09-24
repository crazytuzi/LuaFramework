acYijizaitanVo=activityVo:new()
function acYijizaitanVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acYijizaitanVo:updateSpecialData(data)
    if data~=nil then
    	if data.cost then
    		self.cost = data.cost
    	end
        if data.version then
            self.version =data.version
        end
    	if data.mul then  -- 10连抽
    		self.mul = data.mul
    	end
    	if data.mulc then --9折
    		self.mulc = data.mulc
    	end
    	if data.consume then --改装需要的道具
    		self.consume = data.consume
    	end

    	if data.rewardlist then
    		self.rewardCfg = data.rewardlist
    	end
    	if data.ls~=nil then
    		self.rate= data.ls
    	end
    	if data.t then
    		self.lastTime =data.t
    	end
    	if data.v then
    		self.free= data.v
    	end

        if data.l then
            self.l = data.l 
        end
        if data.f then
            self.vipHadNum = data.f
        end


        if self.vipCfg == nil then
            self.vipCfg = {}
        end
        if data.vipCost then
            self.vipCfg = data.vipCost
        end
        if data.report then
            self.tankActionData =data.report
        end

         -- 新版需添加
        if data.mustMode then
            self.mustMode = data.mustMode
        end
        if data.mustReward1 then
            self.mustReward1 = data.mustReward1
        end
        if data.mustReward2 then
            self.mustReward2 = data.mustReward2
        end
        if data.mustReward3 then
            self.mustReward3 = data.mustReward3
        end

    end

end