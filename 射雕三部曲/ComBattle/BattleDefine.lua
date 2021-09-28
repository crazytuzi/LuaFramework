--[[
    文件名：BattleDefine
	描述：战斗模块的通用函数、对象、配置
	创建人：luoyibo
	创建时间：2016.08.12
-- ]]

bd = {
-- public:
    -- 托管状态定义
    trusteeState = {
        eNormal            = 1, -- 正常
        eSpeedUp           = 2, -- 加速
        eSpeedUpAndTrustee = 3, -- 加速托管
    },
}


-- private:
bd.adapter   = require("ComBattle.Adapter.BattleAdapter")
bd.atom      = require("ComBattle.Atom.BattleAtom")
bd.func      = require("ComBattle.Common.BDFunction")
bd.CONST     = require("ComBattle.Common.BDConst")
bd.interface = require("ComBattle.Common.BDInterface")
bd.log       = require("ComBattle.Common.BDLog")
bd.assert    = require("ComBattle.Common.BDLog").assert
bd.event     = require("ComBattle.Common.BDEvent")
bd.ui_config = require("ComBattle.UICtrl.BDUIConfig")

require("Config.AttackModel")
require("Config.BuffModel")
require("Config.HeroModel")
require("Config.FashionModel")
require("Config.PetModel")
require("Config.IllusionModel")
require("Config.ZhenshouModel")
require("Config.ZhenshouStepupModel")

bd.data_config = {
    AttackModel = AttackModel,
    BuffModel = BuffModel,
    HeroModel = HeroModel,
    ZhenshouModel = ZhenshouModel,
}

-- tmp
bd.audio = bd.adapter.audio

return bd
