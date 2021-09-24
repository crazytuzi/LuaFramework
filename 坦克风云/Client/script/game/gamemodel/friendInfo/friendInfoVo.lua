-- @Author hj
-- @Description 改版好友系统Vo数据模型
-- @Date 2018-04-18

friendInfoVo={       
         -- 好友列表
        friendTb = {},
        -- 好友申请列表
        binviteTb = {},
        -- 屏蔽列表
        shieldTb = {},
        lastGiftTime,
        -- 当前领取的好友礼物数量
        -- 三个标记位动态刷新好友列表
        friendChanegFlag = 0,
        friendbiInviteFlag = 0,
        friendGiftFlag = 0,
        giftNum = 0
    }
function friendInfoVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function friendInfoVo:initWithData(data)
    
    -- 用户的好友信息列表
    if data.info then
        self.friendTb = {}
        for k,v in pairs(data.info) do
            local friendInfo = {}
            if v[1] then
                friendInfo.uid = tonumber(v[1])
            end
            if v[2] then
                friendInfo.nickname = v[2]
            end
            if v[3] then
                friendInfo.vip = tonumber(v[3])
            end
            if v[4] then
                friendInfo.rank = tonumber(v[4])
            end
            if v[5] then
                friendInfo.alliancename = v[5]
            end
            if v[6] then
                friendInfo.title = v[6]
            end
            if v[7] then
                friendInfo.fc = tonumber(v[7])
            end
            if v[8] then
                friendInfo.level = tonumber(v[8])
            end
            if v[9] then
                friendInfo.pic = v[9]
            end
            if v[10] then
                friendInfo.bpic = v[10]
            end
            if v[11] then
                -- 是否赠送过该好友礼物 0未送过该好友，1送过该好友
                friendInfo.sendFlag = v[11][1]
                -- 是否接受过该好友礼物 0该好友未送我，1该好友送我我没接受，该好友送我且我已经接受
                friendInfo.receiveFlag = v[11][2]
            end
            table.insert(self.friendTb,friendInfo)
        end
    end
    -- 用户的被申请列表
    if data.binvites then
        self.binviteTb = {}
        for k,v in pairs(data.binvites) do
            local binvite = {}
            if v[1] then
                binvite.uid = tonumber(v[1])
            end
            if v[2] then
                binvite.nickname = v[2]
            end
            if v[3] then
                binvite.vip = tonumber(v[3])
            end
            if v[4] then
                binvite.rank = tonumber(v[4])
            end
            if v[5] then
                binvite.alliancename = v[5]
            end
            if v[6] then
                binvite.title = v[6]
            end
            if v[7] then
                binvite.fc = tonumber(v[7])
            end
            if v[8] then
                binvite.level = tonumber(v[8])
            end
            if v[9] then
                binvite.pic = v[9]
            end
            if v[10] then
                binvite.bpic = v[10]
            end
            table.insert(self.binviteTb,binvite)
        end
    end
    -- 当前好友礼物数量
    if data.rgift then
        self.giftNum = tonumber(data.rgift)
    end
end