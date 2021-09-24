acXlpdVo=activityVo:new()
function acXlpdVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acXlpdVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg

            if self.activeCfg.Lv then
                self.openLv = self.activeCfg.Lv
            end
        end

        if data.f then
            self.firstFree = data.f
        end
        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime = data.t == 0 and G_getWeeTs(base.serverTime) or data.t
        end

        if data.coin then--当前的攀登币
            self.pdCoin = data.coin
        end

        if data.exp then--当前的攀登经验
            self.coinExp = data.exp
        end

        if data.team then--自己的每天组队凌晨时间戳
            self.teamTtb = data.team
        end

        if data.shop then--已兑换表
            self.exchangedTb = data.shop
        end

        if data.bx then--任务宝箱 已领表
            self.bxTaskedTb = data.bx
        end

        if data.zn then--组队次数
            self.teamNum = data.zn
        end

        if data.tc then--更换队伍次数
            self.chngeNum = data.tc
        end

        if data.tr then--每日任务完成次数 {num,max}
            self.taskedTb = data.tr
        end

        if data.teamData then --自己的队伍
            self.teams = {}
            self.ispoolTb = {}
            for i=1,2 do
                if data.teamData[i] and next(data.teamData[i]) then
                    self.teams[i] = data.teamData[i][1]--队伍信息
                    self.ispoolTb[i] = data.teamData[i][2]--是否自由编队的标示 1 已开启 0 未开启
                elseif not data.teamData[i] or not next(data.teamData[i]) then
                    self.teams[i] = {}
                end
            end
        end

        if self.ispoolTb and next(self.ispoolTb) then--自由组队状态 1 已开启 0 未开启
            self.ispool = self.ispoolTb[1]
        end

        if data.flist then-- 好友列表
            self.flist = data.flist
        end

        if data.clist then--请求结算的数据
            self.clist = data.clist
        end
    end
end