local Lplus = require("Lplus")
local StrategyBase = require("Main.Fly.FlyStrategy.StrategyBase")
local StandFly = Lplus.Extend(StrategyBase, "StandFly")
local ECGame = require("Main.ECGame")
local FlyModule = require("Main.Fly.FlyModule")
local EC = require("Types.Vector3")
local ECAirCraft = require("Main.Fly.FlyStrategy.ECAirCraft")
local ECPlayer = require("Model.ECPlayer")
local ECFxMan = require("Fx.ECFxMan")
local def = StandFly.define
StandFly.Commit()
return StandFly
