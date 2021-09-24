acOlympicVo=activityVo:new()

function acOlympicVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acOlympicVo:updateSpecialData(data)
    if data then
    	if data.version then
    		self.version =data.version
    	end
    	if self.reStartTime ==nil then
			self.reStartTime =0
		end
		if data.t then
			self.lastTime =data.t
		end
    	if data.freeNum then--每日免费次数
    		self.freeNum =data.freeNum
    	end

    	if data.cost then
    		self.cost1 =data.cost
    	end
    	if self.cost1 ==nil then
    		self.cost1 =50
    	end

    	if data.value then     --10倍打折
    		self.cost2 =self.cost1*10*data.value
    	end
    	if self.cost2==nil then
    		self.cost2 =self.cost1*10
    	end

        if self.seeRecord ==nil then
            self.seeRecord =true
        end

        if data.reward then
            self.awardAllTb = data.reward
        end
        if self.awardAllTb ==nil then
            self.awardAllTb ={}
        end

        if self.awardAllTbRecord ==nil then
            self.awardAllTbRecord = {}
        end

        if data.score then
            self.scoreTb = data.score
        end
        if data.scoreLimit then
            self.scoreLimit = data.scoreLimit
        end

        if self.scoreTb ==nil then
            self.scoreTb ={}
        end

        if self.curCellTimeRecord ==nil then
            self.curCellTimeRecord ={}
        end
        if self.curCellAwardTb ==nil then--用于记录展示用的
            self.curCellAwardTb ={}
        end
        if self.curAwardTb ==nil then--当前得到的奖励
            self.curAwardTb ={}
        end

        if data.point then
            self.pointTb =data.point
        end
        if self.pointTb ==nil then
            self.pointTb ={}
        end

        if self.curAllScores == nil then
            self.curAllScores = 0
        end

        if self.curReport == nil then --当前中奖的对应信息
            self.curReport ={}
        end

        if self.allColors ==nil then  --蓝 黑 红 黄 绿 紫
            self.allColors = {ccc3(0,126,202),ccc3(53,53,53),ccc3(255,18,31),ccc3(254,175,56),ccc3(0,167,82),ccc3(117,57,147)}
        end

        if self.isagainBuyNum ==nil then
            self.isagainBuyNum =0
        end

        if self.acIdx ==nil then
            self.acIdx =0 
        end
        if self.needSubCost ==nil then
            self.needSubCost =0
        end
        if self.curGetSocresTb == nil then
            self.curGetSocresTb ={}
        end

        if self.curEachAwardScoresTb == nil then
            self.curEachAwardScoresTb = {0,0,0}
        end

        if self.isTen ==nil then
            self.isTen =false
        end
    end
end