acHljbVo=activityVo:new()
function acHljbVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function acHljbVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        
        if self.activeCfg then
            local acCfg = self.activeCfg

            if acCfg.jubaoTime then
                self.acTime = acCfg.jubaoTime--聚宝时间 
            end

            if acCfg.startRate then
                self.startRate = acCfg.startRate
            end
            if acCfg.dailyAddRate then
                self.dailyAddRate = acCfg.dailyAddRate
            end

            if acCfg.dailyChargeAddRate then
                self.dailyChargeAddRate = acCfg.dailyChargeAddRate
            end

            if acCfg.exchangeList then
                self.exchangeList = acCfg.exchangeList
            end

            if acCfg.activeItemFront then--存入的物品名称
                self.acName = acCfg.activeItemFront
            end
            if acCfg.dailyLimit then--存入的物品数量上限（每天）
                self.dailyLimit = acCfg.dailyLimit
            end
            if acCfg.dailyChargeAddLimit then--充值添加的物品数量上限（每天）
                self.dailyChargeAddLimit = acCfg.dailyChargeAddLimit
            end
            if acCfg.dailyCharge then -- 每日充值的金币数
                self.dailyRecharge = acCfg.dailyCharge
            end

            if acCfg.point then--每1个物品对应获得积分
                self.usePointNum = acCfg.point
            end

            --liuning修改
            if acCfg.FristAddRate then
                self.FristAddRate=acCfg.FristAddRate
            end


        end

        if data.f then
            self.firstFree = data.f
        end
        if data.t then --上次抽奖的时间，用于跨天重置免费次数
            self.lastTime=data.t
        end

        if data.rtb then--已兑换表
            self.hadExTb = data.rtb
        end
        if not self.hadExTb then
            self.hadExTb = {}
        end

        if data.p then--当前积分
            self.point = data.p
        end
        if not self.point then
            self.point = 0
        end

        if data.log then
            self.log = data.log
        end
        if not self.log then
            self.log = {}
        end

        if data.htb then--操作表，1 存入 2 取出；没有数据表示没有操作
            self.htb = data.htb
        end
        if not self.htb then
            self.htb = {}
        end

        if data.gtb then
           --[[ print("gtb的数据")

            for k , v in pairs(data.gtb) do
                print(k)
            end--]]
            self.gtb = data.gtb
        end
        if not self.gtb then--{}, 金币充值表 d1 = 180 第一天冲了180金币
            self.gtb = {}
        end

        if data.gAddRate then
            self.gAddRate = data.gAddRate
        end
        if not self.gAddRate then--金币增加的比率
            self.gAddRate = 0
        end

        if data.res then--已存物品的列表
            self.keepTb = data.res
        end
        if not self.keepTb then
            self.keepTb = {}
        end
    end
end