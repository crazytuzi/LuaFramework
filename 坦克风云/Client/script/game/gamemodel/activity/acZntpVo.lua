acZntpVo = activityVo:new()

function acZntpVo:new()
	local nc = {}
	setmetatable(nc, self)
	self.__index = self
	return nc
end

function acZntpVo:updateSpecialData(data)
	if data == nil then
		return
	end
	if data._activeCfg then
		if data._activeCfg.task then
			self.task = data._activeCfg.task
		end
	end
	if data.bn then --任务领取状态[taskList的index,]
		self.taskStateTb = data.bn
	end
	if data.tr then --任务完成次数["t1":10,"t2":5,"t3":0,...]
		self.taskNumTb = data.tr
	end

	if self and self.task then
		self.taskList = G_clone(self.task)
		--id:配置_activeCfg.task的索引, num:当前任务完成次数, state:领取状态(1:可领取 2:未达成 3:已领取)
        for k, v in ipairs(self.taskList) do
            v["id"] = k
            v["state"] = 2
            v["num"] = 0
            --判断任务是否已领取
            if self.taskStateTb then
                for i, j in pairs(self.taskStateTb) do
                    if tonumber(k) == tonumber(j) then --任务已领取
                        v["state"] = 3
                        break
                    end
                end
            end
            --获取任务完成次数
            if self.taskNumTb then
                v["num"] = self.taskNumTb["t" .. k] or 0
            end
            --判断任务是否可领取
            if v.state ~= 3 and tonumber(v.num) >= tonumber(v.needNum) then 
                v["state"] = 1
            end
        end
        table.sort(self.taskList, function(a, b)
            if a.state == b.state then
                return a.id < b.id
            end
            return a.state < b.state
        end)
	end
end