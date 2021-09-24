acHeroGiftVo=activityVo:new()

function acHeroGiftVo:updateSpecialData( data )
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

    	if data.showhero then
    		self.showList =data.showhero
    	end
    	if data.v then
    		self.score=data.v
    	end
    	if data.rankpoint then
    		self.scoreFloor =data.rankpoint
    	end
    	if data.rankReward then
    		self.awardList = data.rankReward
    	end
    	if self.score ==nil then
    		self.score =0
    	end
    	if data.mulCost then
    		self.mulCost =data.mulCost
    	end

    	if self.playerList ==nil then
    		self.playerList ={}
    	end
    	if data.r then
    		self.getedBigAward=data.r
    	end

        -- if not self.tipKeyInteger then
        --     local dataKey = 
        --     self.tipKeyInteger = CCUserDefault:sharedUserDefault():getIntegerForKey()
        -- end
        
        -- if data.mustGetHero then
        --     self.mustGetHero = data.mustGetHero
        -- end
        -- if data.s then 
        --     self.star = data.s
        -- end  
        
        -- if data.version then
        --     self.version =data.version
        -- end 	

    end

	self.acEt = self.acEt - 86400								--是否需要减去一天时间(86400)
	
	self.refreshTs = self.et - 86400 -- 刷新时间（比如排行结束时间）

end

-- function acHeroGiftVo:initRefresh( )
-- 	self.needRefresh=true
-- 	self.refresh =false 
-- end