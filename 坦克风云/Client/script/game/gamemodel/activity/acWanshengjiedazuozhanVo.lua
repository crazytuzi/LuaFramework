acWanshengjiedazuozhanVo=activityVo:new()

function acWanshengjiedazuozhanVo:updateSpecialData(data)
    --配置部分
    --[[
		{"cost":138,"map":[2,2,3,1,1,2,3,1,2],"bossLife":[100,100],"et":"1543563480","taskList":{"t1":{"reward":{"p":[{"index":1,"p20":2}]},"index":1,"conditions":[{"num":3,"type":1}]}},"st":"1443685080","type":1,"pumpkinLife":[10,10],"noticeNum":6,"version":1,"sortId":73}
    ]]

    if data.version then
        self.version=data.version
    end
    if data.cost then
    	self.cost=data.cost
    end
    if data.bossLife then
    	self.bossLife=data.bossLife
    end
    if data.taskList then
    	self.taskList=data.taskList
    end
    if data.pumpkinLife then
    	self.pumpkinLife=data.pumpkinLife
    end
    if data.noticeNum then
    	self.noticeNum=data.noticeNum
    end

    --数据部分
	--[[ 数据格式
		mUseractive.info[aname].t = weeTs -- 上次免费时间戳
		mUseractive.info[aname].l = {} -- boss血量
		mUseractive.info[aname].r = { -- 消除记录
			k1 = 0, -- 击杀南瓜1次数
			k2 = 0, -- 击杀南瓜2次数
			k3 = 0, -- 击杀南瓜3次数
			hit = 0, -- 一次性连击最大次数
		}
		mUseractive.info[aname].f = {t1=1,t2=1} -- 任务领取记录
    ]]
    if data.t then
    	self.lastTime=data.t
    end
    if data.l then
    	self.curBossLife=data.l
    end
    if data.r then
    	self.taskData=data.r
    end
    if data.f then
    	self.rewardData=data.f
    end
    if data.m then
    	self.map={}
    	for k,v in pairs(data.m) do
    		table.insert(self.map,tonumber(v))
    	end
    end
end