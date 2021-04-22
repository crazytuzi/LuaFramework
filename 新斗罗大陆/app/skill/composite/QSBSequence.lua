--[[
    Class name QSBSequence
    Create by julian 
--]]


local QSBNode = import("..QSBNode")
local QSBSequence = class("QSBSequence", QSBNode)

function QSBSequence:_execute(dt)
    if self:getOptions().can_be_immuned == true then
        if self._target ~= nil and self._target:isDead() == false then
            if self._target:isImmuneStatus(self._skill:getBehaviorStatus()) then
                self:finished()
                return
            end
        end
    end

    local forward_mode = self:getOptions().forward_mode

    if self._index == nil then
        self._index = 1
    end

    repeat 
        if self._index > self:getChildrenCount() then
            self:finished()
            break
        else
            local child = self:getChildAtIndex(self._index)
            if child:getState() == QSBNode.STATE_EXECUTING then
                child:visit(dt)
            elseif child:getState() == QSBNode.STATE_WAIT_START then
                child:start()
                child:visit(0)
            else
                self._index = self._index + 1
                if self._index > self:getChildrenCount() then
                    self:finished()
                    break
                end
                -- arguments pass down
                local args = child:getArguments()
                local next_child = self:getChildAtIndex(self._index)
                if args and next_child then
                    table.merge(next_child:getOptions(), args)
                end
                -- options pass down
                local options = child:getOptions()
                if options.pass_key and type(options.pass_key) == "table" then
                    local opt_tab = {}
                    for _, v in ipairs(options.pass_key) do
                        if nil ~= options[v] then
                            opt_tab[v] = options[v]
                        end
                    end
                    table.merge(next_child:getOptions(), opt_tab)
                end
            end

            if child:getState() ~= QSBNode.STATE_FINISHED then
                break
            end
        end
    until not forward_mode
end

function QSBSequence:_onReset()
    self._index = nil
end

return QSBSequence