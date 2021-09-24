acSdzsVo=activityVo:new()

function acSdzsVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acSdzsVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        if data.v then --攻打玩家或者玩家占领的矿点次数
            self.v=data.v
        end
        if data.r then --领取奖励档位信息
            self.r=data.r
        end
        if data.t then
            self.t=data.t
        end
    end
end

-- local sdzs={
--     multiSelectType=true,
--     --新手绑定活动标识
--     isBind=true,
--     [1]={
--         _activeCfg=true,
--         type=1,
--         sortId=70,
        
--         --活动持续时间
--         lastDay=3,
        
--         --每日充值所需金币额度
--         needTimes={3,5,10,15,20},
        
--         reward={
--             {p={{p19=5,index=1},{p20=1,index=2}}},
--             {p={{p19=5,index=1},{p20=1,index=2}}},
--             {p={{p19=5,index=1},{p20=1,index=2}}},
--             {p={{p19=5,index=1},{p20=1,index=2}}},
--             {p={{p19=5,index=1},{p20=1,index=2}}},
--         },
        
--         serverreward={
--             {props_p19=5,props_p20=1},
--             {props_p19=5,props_p20=1},
--             {props_p19=5,props_p20=1},
--             {props_p19=5,props_p20=1},
--             {props_p19=5,props_p20=1},
--         },
--     },
-- }
-- return sdzs