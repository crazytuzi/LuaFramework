acXinchunhongbaoVo=activityVo:new()
function acXinchunhongbaoVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acXinchunhongbaoVo:updateSpecialData(data)

	--[[--每日登陆赠送的勋章数
    loginGems=10000,
    --赠送小礼包得到勋章数
    smallGiftGems=1000,
    --赠送大礼包得到勋章数
    bigGiftGems=10000,
    --每日的赠送次数
    dailyTimes=10,
    --赠送小礼包消耗的金币数
    smallCost=100,
    --赠送大礼包消耗的金币数
    bigCost=400,
    --打开小礼包消耗的勋章数
    openSmall=100,
    --打开大礼包消耗的勋章数
    openBig=200,
    --广播的道具
    showlist={p={{p230=1,index=1},{p90=1,index=2}}},
    --记录显示条数 30条
    recordNum=30,
    smallPool --小型礼包奖池显示
    bigPool --大型礼包奖池显示

    --]]

    if self.smallPool ==nil then
        self.smallPool = {}
    end
    if data.smallPool then
        self.smallPool = data.smallPool
    end
    if self.bigPool ==nil then
        self.bigPool = {}
    end
    if data.bigPool then
        self.bigPool = data.bigPool
    end

    if data.loginGems then
    	self.loginGems = data.loginGems
    end

    if data.smallGiftGems then
    	self.smallGiftGems = data.smallGiftGems
    end

    if data.bigGiftGems then
    	self.bigGiftGems = data.bigGiftGems
    end

    if data.dailyTimes then
    	self.dailyTimes = data.dailyTimes
    end

    if data.smallCost then
    	self.smallCost = data.smallCost
    end

    if data.bigCost then
    	self.bigCost = data.bigCost
    end

    if data.openSmall then
    	self.openSmall = data.openSmall
    end

    if data.openBig then
    	self.openBig = data.openBig
    end

    if self.showlist ==nil then
    	self.showlist = {}
    end
    if data.showlist then
    	self.showlist = data.showlist
    end

    if data.recordNum then
    	self.recordNum = data.recordNum
    end

    --[["r": [  已经赠送的好友的列表, 已经赠送的次数数这个table的长度
      9000026,
      9000026,
      9000026,
      9000026,
      9000026,
      9000026,
      9000026,
      9000026,
      9000026
    ],
    "t": 1422720000, 每日赠送礼包免费次数是否使用
    "m": 1422720000, 每日登陆增加勋章数的标识,这个需要前台根据m时间戳自动增加勋章的数量,同时重置已经赠送的好友列表r为{}
    "p": 45500, 勋章的数量
    "q": [  红包数量
      1,   小红包
      3  大红包
    ]

    --]]

    if self.giveFriendList == nil then
    	self.giveFriendList = {}
    end
    if data.r then
    	self.giveFriendList = data.r
    end

    if self.lastTime == nil then
    	self.lastTime = 0
    end
    if data.t then
    	self.lastTime = data.t
    end

    if self.medalTime == nil then
    	self.medalTime = 0 
    end
    if data.m then
    	self.medalTime = data.m
    end

    if self.HasMedal==nil then
    	self.HasMedal = 0
    end
    if data.p then
    	self.HasMedal = data.p
    end
    if self.giftNumTb ==nil then
    	self.giftNumTb = {}
    end

    if data.q then
    	self.giftNumTb = data.q
    end
    if G_isToday(self.medalTime)==false then
    	if self.HasMedal and self.loginGems then
	    	self.giveFriendList = {}
	    	--self.HasMedal=self.HasMedal+self.loginGems
	    	self.medalTime= G_getWeeTs(base.serverTime)
	    end
    end




end