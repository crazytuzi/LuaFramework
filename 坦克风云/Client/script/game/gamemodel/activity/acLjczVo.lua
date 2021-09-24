acLjczVo=activityVo:new()

function acLjczVo:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function acLjczVo:updateSpecialData(data)
    if data~=nil then
        if data._activeCfg then
            self.activeCfg=data._activeCfg
        end
        if data.r then --已经领取的充值档位
            self.r=data.r
        end
        if data.v then --当前已经充值的金币数
            self.v=data.v
        end
    end
end

-- --累计充值，活动期间不重置
-- local ljcz={
--    multiSelectType=true,
--    --新手绑定活动标识
--    isBind=true,
--    [1]={
--     _activeCfg=true,
--         type=1,
--         sortId=71,

--     --活动持续时间（单位：天）
--     lastDay=5,
    
--     --累计充值所需金币额度
--     cost={1000,2000,5000,10000,30000},
    
--     reward={
--         {p={{p20=1,index=1},{p13=1,index=2}}},      --1000金币档
--                 {p={{p20=3,index=1},{p12=1,index=2}}},
--                 {p={{p20=5,index=1},{p2=1,index=2}}},
--         {p={{p20=10,index=1},{p5=2,index=2}}},
--         {am={{exp=1000,index=1},{m24=1,index=2}}},  --30000金币档，奖励中会有装甲矩阵相关
--         },
    
--         serverreward={
--         {props_p20=1,props_p13=1},  --1000金币档
--                 {props_p20=3,props_p12=1},
--                 {props_p20=5,props_p2=1},
--                 {props_p20=10,props_p5=2},
--         {armor_exp=1000,armor_m24=1},   --30000金币档，奖励中有装甲矩阵相关
--         },
--     },
-- }
-- return ljcz