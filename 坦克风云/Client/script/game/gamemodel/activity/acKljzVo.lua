acKljzVo=activityVo:new()

function acKljzVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acKljzVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        if self.activeCfg then

            if self.activeCfg.maxmovetimes then
                self.maxmovetimes = self.activeCfg.maxmovetimes
            end
        	if self.activeCfg.inimovetimes then
        		self.inimovetimes = self.activeCfg.inimovetimes
        	end
            if self.activeCfg.inimedallist then
                self.inimedallist = self.activeCfg.inimedallist
            end
            if self.inimedallist == nil then
                self.inimedallist = {}
            end
        	if self.activeCfg.questlist then
        		self.taskListTb = self.activeCfg.questlist
        	end
            if self.activeCfg.flickerlist then
                self.flickList = self.activeCfg.flickerlist
            end
            if self.activeCfg.rewardlist then--pool:红 绿 蓝 杂
                self.poolList,self.bigAwardTb = {},{}
                for i=1,SizeOfTable(self.activeCfg.rewardlist) do
                    if i%2 == 0 then
                        table.insert(self.poolList,self.activeCfg.rewardlist["pool"..i])
                    elseif i> 1 then
                        table.insert(self.bigAwardTb,self.activeCfg.rewardlist["pool"..i])
                    end
                end
                table.insert(self.poolList,self.activeCfg.rewardlist["pool1"])
            end
        end

        if data.v then--当前获得总次数（包括使用和未使用的）

            self.allSteps = data.v
        end
        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            -- print("data.t----acKljzVo---->>>>>>>>>",data.t)
            self.lastTime=data.t
        end
        if self.allSteps == nil then
            self.allSteps = 0
        end

        if data.c then--使用的步数
            self.usedStep = data.c
        end
        if self.usedStep == nil then
            self.usedStep = 0
        end

        if data.dt then--当前完成的任务
            self.curTaskedTb = data.dt
        end
        if self.curTaskedTb == nil then
            self.curTaskedTb = {}
        end
    end
end