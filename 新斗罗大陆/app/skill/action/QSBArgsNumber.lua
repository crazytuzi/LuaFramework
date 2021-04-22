--
--                             _ooOoo_
--                            o8888888o
--                            88" . "88
--                            (| -_- |)
--                            O\  =  /O
--                         ____/`---'\____
--                       .'  \\|     |//  `.
--                      /  \\|||  :  |||//  \
--                     /  _||||| -:- |||||-  \
--                     |   | \\\  -  /// |   |
--                     | \_|  ''\---/''  |   |
--                     \  .-\__  `-`  ___/-. /
--                   ___`. .'  /--.--\  `. . __
--                ."" '<  `.___\_<|>_/___.'  >'"".
--               | | :  `- \`.;`\ _ /`;.`/ - ` : | |
--               \  \ `-.   \_ __\ /__ _/   .-` /  /
--          ======`-.____`-.___\_____/___.-`____.-'======
--                             `=---='
--
------------------------ 佛祖保佑，不出bug ------------------------- 

--[[
    class name QSBArgsNumber
    create by wanghai
--]]

--[[
    返回一个数字
    is_attacker                 目标为攻击者
    is_attackee                 目标为被攻击者
    is_all_enemies              目标为所有的敌人
    stub_buff_id                根据buff id返回数字
    teammate_and_self           目标为队友包括自己
    buff_stacks                 返回buff的层数
--]]

local QSBNode = import("..QSBNode")
local QSBArgsNumber = class("QSBArgsNumber", QSBNode)

function QSBArgsNumber:ctor(director, attacker, target, skill, options)
    QSBArgsNumber.super.ctor(self, director, attacker, target, skill, options)

    self._byBuffStacksNumber = self._options.buff_stacks
    self._byStatusNumber = self._options.status_number
    self._isAttacker = self._options.is_attacker
    self._isAttackee = self._options.is_attackee
    self._isAllEnemies = self._options.is_all_enemies
    self._stubBuffId = self._options.stub_buff_id
    self._stubStatus = self._options.stub_status
    self._isTeammateAndSelf = self._options.teammate_and_self
end

function QSBArgsNumber:_execute(dt)
    local actors = nil
    if self._isAttacker == true then
        actors = {self._attacker}
    elseif self._isAttackee == true then
        actors = {self._target}
    elseif self._isAllEnemies == true then
        actors = app.battle:getAllMyEnemies(self._attacker)
    elseif self._isTeammateAndSelf == true then
        actors = app.battle:getMyTeammates(self._attacker, true)    
    elseif self._options.selectTargets ~= nil then
        actors = self._options.selectTargets
    elseif self._options.selectTarget ~= nil then 
        actor = {self._options.selectTarget}
    end
    
    local number = 0

    if self._byBuffStacksNumber == true then
        for _, actor in ipairs(actors) do
            local buffs = actor:getBuffs()
            local count = 0
            for k, buff in pairs(buffs) do
                if buff:getId() == self._stubBuffId then
                    count = count + 1
                end
            end
            number = number + count
        end
    end

    if self._byStatusNumber == true and self._stubStatus ~= nil then
        local count = 0
        for _, actor in ipairs(actors) do
            local isHave, num = actor:isUnderStatus(self._stubStatus, true) 
           count = count + num
        end
        number = count
    end

    self:finished({number = number})
end

return QSBArgsNumber

