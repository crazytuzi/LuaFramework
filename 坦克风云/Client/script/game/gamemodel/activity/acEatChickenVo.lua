acEatChickenVo=activityVo:new()
function acEatChickenVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acEatChickenVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
   
    	if data.t then
    		self.lastTime =data.t
    	end

        if data.f then
            self.firstFree = data.f
        end
        if data.rd and data.rd.allipoint then--军团总积分
            self.legionMembersScores = data.rd.allipoint
        end

        if data.rd and data.rd.perlist then
            self.pScoresGetedTb = data.rd.perlist
        end

        if self.oldPerPoint == nil then
            self.oldPerPoint = 0
        end
        if data.rd and data.rd.perpoint then--个人积分
            if self.singleScores then
                self.oldPerPoint = self.singleScores
            end
            self.singleScores = data.rd.perpoint

            if data.rd.first then-- 1 未加入,2 非初始军团 3 是初始军团
                self.first = data.rd.first
            end
        end


        if data.rd and data.rd.allilist then
            self.aScoresGetedTb = data.rd.allilist
        end

        if data.rd and data.rd.flag then
            self.flag = data.rd.flag
        end

        if data.infolist then
            self.aRankList = data.infolist
        end

        if data.drawlist then
            self.rewardLog = data.drawlist
        end

        if data.v and type(data.v)~="table" then
            self.rechargeNums = data.v
        end
    end

end