expeditionVo={}
function expeditionVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

-- info.at=troops   本次关卡攻击的坦克
-- info.ah              本次关卡攻击的英雄
-- info.kt               本次关卡击杀过的坦克
-- info.dt               自己死过的所有坦克
-- info.dh              自己死过的英雄 
-- info.user           本次关卡人员信息（{
--             "elite_challenge_name_1", -- 名字
--             "WeaponLv2.png", --头像
--             15,           --等级
--             100000,       --战斗力
--             },）

function expeditionVo:initWithData(tb)

	if tb~=nil then
	   self.atkName=tb.info.user[1]
	   self.atkPhoto=tb.info.user[2]
	   self.atkLv=tb.info.user[3]
	   self.atkPower=tb.info.user[4]
	   self.uid=tb.info.user[5]
	   self.atkTroops=tb.info.at
	   self.atkHero=tb.info.ah
	   self.deadTank=tb.info.dt
	   self.deadHero=tb.info.dh
	   self.killTank=tb.info.kt
	   self.eid=tb.eid
	   self.reward=tb.r
	end

end



