--[[
    Class name QSBParallel
    Create by julian 
--]]


local QSBNode = import("..QSBNode")
local QSBParallel = class("QSBParallel", QSBNode)

function QSBParallel:_execute(dt)    
    if self:getOptions().can_be_immuned == true then
        if self._target ~= nil and self._target:isDead() == false then
            if self._target:isImmuneStatus(self._skill:getBehaviorStatus()) then
                self:finished()
                return
            end
        end
    end

    local count = self:getChildrenCount()
    local isAllChildFinished = true
    for index = 1, count, 1 do
        local child = self:getChildAtIndex(index)
        if child:getState() == QSBNode.STATE_EXECUTING then
            child:visit(dt)
            isAllChildFinished = false
        elseif child:getState() == QSBNode.STATE_WAIT_START then
            -- options pass down
            local options = self:getOptions()
            if options.pass_key and type(options.pass_key) == "table" then
                local opt_tab = {}
                for _, v in ipairs(options.pass_key) do
                    if nil ~= options[v] then
                        opt_tab[v] = options[v]
                    end
                end
                table.merge(child:getOptions(), opt_tab)
            end
            
            child:start()
            child:visit(0)
            isAllChildFinished = false
        end
    end

    if isAllChildFinished == true then
        self:finished()
    end
    
end

return QSBParallel