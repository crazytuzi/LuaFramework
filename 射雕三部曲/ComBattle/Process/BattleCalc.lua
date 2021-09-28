--[[
    filename: ComBattle.Process.BattleCalc.lua
    description: 逻辑计算代理类(消除多线程与单线程调用区别)
    date: 2016.12.01

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]


local BattleCalc = class("BattleCalc", function()
    return {}
end)

function BattleCalc:ctor(params)
    self.battleLayer_ = params.battleLayer

    self.isThread_ = params.thread

    if self.isThread_ then
        require("ComLogic.common_func")
    end
end


function BattleCalc:init(params, callback)
    if self.isThread_ then
        self.core_ = BattleLogicCalc:getInstance()

        self.battleLayer_:onUpdate(function()
            self.core_:checkResult()
        end)

        self.core_:init(serialize(params), function(result)
            return callback(unseri(result))
        end)
    else
        self.core_ = require("ComLogic.LogicInterface").new()
        callback(self.core_:init(params))
    end
end


function BattleCalc:calc(params, callback)
    if self.isThread_ then
        self.core_:calc(serialize(params), function(result)
            return callback(unseri(result))
        end)
    else
        return callback(self.core_:calc(params))
    end
end


function BattleCalc:release()
    if self.isThread_ then
        self.core_:release()
    end
end

return BattleCalc
