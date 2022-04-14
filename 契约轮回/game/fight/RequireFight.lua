-- 
-- @Author: LaoY
-- @Date:   2018-07-28 11:52:26
-- 

if LuaMemManager then
	old_require('game.fight.FightConfig')
else
	require('game.fight.FightConfig')
end
require ('game.fight.FightEvent')
require ('game.fight.SkillManager')
require ('game.fight.FightManager')
require ('game.fight.AutoFightManager')
require ('game.fight.FightData')

require ('game.fight.DamageText')
require ('game.fight.DamageConfig')

--技能相关
require('game.fight.SkillModel')
require('game.fight.SkillEvent')
require('game.fight.RevivePanel')
