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
    class name QSBSelectorByNumber
    create by wanghai
--]]

local QSBNode = import("..QSBNode")
local QSBSelectorByNumber = class("QSBSelectorByNumber", QSBNode)

function QSBSelectorByNumber:ctor(director, attacker, target, skill, options)
    QSBSelectorByNumber.super.ctor(self, director, attacker, target, skill, options)
    
    self._selectChild = nil
end

function QSBSelectorByNumber:_execute(dt)
    if self:getOptions().can_be_immuned == true then
        if self._target ~= nil and self._target:isDead() == false then
            if self._target:isImmuneStatus(self._skill:getBehaviorStatus()) then
                self:finished()
                return
            end
        end
    end

    if nil == self._options.number then
        self:finished()
        return
    end

    if nil == self._selectChild then
        local count = self:getChildrenCount()
        for i = 1, count do
            local child = self:getChildAtIndex(i)
            local childOptions = child:getOptions()
            if childOptions.flag == self._options.number then
                self._selectChild = child
                break
            end
        end
        if nil == self._selectChild then
            self:finished()
            return
        end
    else
        local state = self._selectChild:getState()
        if state == QSBNode.STATE_WAIT_START then
            self._selectChild:start()
            self._selectChild:visit(0)
        elseif state == QSBNode.STATE_EXECUTING then
            self._selectChild:visit(dt)
        elseif state == QSBNode.STATE_FINISHED then
            self:finished()
        end
    end
end

function QSBSelectorByNumber:revert()
    if nil ~= self._selectChild then
        self._selectChild:revert()
    end

    if self._state == QSBNode.STATE_FINISHED and self._revertable == true then
        self:_onRevert()
    end
end


function QSBSelectorByNumber:cancel()
    if self._state ~= QSBNode.STATE_EXECUTING then
        return
    end
    
    self:_onCancel()

    if nil ~= self._selectChild then
        self._selectChild:cancel()
    end

    self:finished()
end

function QSBSelectorByNumber:_onReset()
    self._selectChild = nil
end

return QSBSelectorByNumber

