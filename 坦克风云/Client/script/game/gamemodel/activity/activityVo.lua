activityVo={}
function activityVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function activityVo:init(type)
	self.type=type
    self.canRewardFlag = false -- 是否有可领取的奖励
    self.stateChanged = false  -- 可领取奖励状态是否发生了改变
    self.over = false -- 是否活动结束（不是活动时间到，是活动的所有操作完成导致的）
    self.hasData=false --useractive里是否返回了该活动的用户数据

    self.initCfg=false --activelist里是否返回了该活动的用户数据,配置数据
    self.isShow=1		--是否显示面板，默认1是显示

    self:initRefresh()
end

function activityVo:initRefresh()
	-- 以下三个变量一起使用
    self.needRefresh = false -- 排行榜结束排名后是否需要刷新数据（比如排行结束后）
    self.refresh = false --排行榜结束排名后是否已刷新过数据
    self.refreshTs = 0  -- 刷新时间（比如排行结束时间，可能与st 或 et 有关系 ，所以有可能写到updateData里)
end

function activityVo:updateData(data)
	if self.st == nil then
		self.st = 0
	end
	if data.st ~= nil then
		self.st = tonumber(data.st)
	end
    
    -- et  活动的最终结束时间
	if self.et == nil then
		self.et = 0
	end
	if data.et ~= nil then
		self.et = tonumber(data.et)
	end
    -- acEt 活动排名名次最终确定的时间等领奖条件最终确定不变的时间
    self.acEt = self.et

    if self.sortId == nil then
    	self.sortId = 0
    end

    if data.sortId ~= nil then
    	self.sortId = tonumber(data.sortId)
    elseif data._activeCfg ~= nil and data._activeCfg.sortId ~= nil then
    	self.sortId = tonumber(data._activeCfg.sortId)
    end

	if self.t == nil then
		self.t = 0
	end
	if data.t ~= nil then
		self.t = data.t
	end

	if self.c == nil then
		self.c = 0
	end
	if data.c ~= nil then
		self.c = data.c
	end

	if self.v == nil then
		self.v = 0
	end
	if data.v ~= nil then
		self.v = data.v
	end

	if self.id == nil then
		self.id = 0
	end
	if data.type ~= nil then
		self.id = data.type
	end

	if self.reward == nil then
		self.reward = {}
	end
	if data.reward ~= nil then
		self.reward = data.reward
	end

    if self.otherData == nil then
        self.otherData = {}
    end
    if data.data ~= nil then
        self.otherData = data.data
    end
    if data.isShow ~= nil then
        self.isShow = data.isShow
    end
    self:updateSpecialData(data)
end

function activityVo:updateSpecialData(data)
	-- 处理跟某个活动相关的数据
end