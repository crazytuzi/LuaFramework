--[[
    Class name QAISelector
    Create by julian 
--]]

local QAIComposite = import("..base.QAIComposite")
local QAISelector = class("QAISelector", QAIComposite)

function QAISelector:_execute(arguments)
    local alternatively = (self:getOptions().alternatively and true) or false
    local randomly = (self:getOptions().randomly and true) or false

    if alternatively then
        local count = self:getChildrenCount()
        local arr = {}
        for index = 1, count, 1 do
            arr[index] = index
        end
        if randomly then
            for index = 1, count, 1 do
                local selected_index = app.random(index, count)
                if index ~= selected_index then
                    local tmp = arr[index]
                    arr[index] = arr[selected_index]
                    arr[selected_index] = tmp
                end
            end
        end
        for _index = 1, count, 1 do
            local index = arr[_index]
            local behavior = self:getChildAtIndex(index)
            if not alternatively or self._lastExecutedChild ~= behavior then
                if not alternatively or self._executingChild == nil or self._executingChild == behavior then
                    if behavior:visit(arguments) == true then
                        self._executingChild = behavior
                        return true
                    else
                        if alternatively and self._executingChild == behavior then
                            self._lastExecutedChild = behavior
                            self._executingChild = nil
                        end
                    end
                end
            end
        end
    else
        local count = self:getChildrenCount()
        local arr = {}
        for index = 1, count, 1 do
            arr[index] = index
        end
        if randomly then
            for index = 1, count, 1 do
                local selected_index = app.random(index, count)
                if index ~= selected_index then
                    local tmp = arr[index]
                    arr[index] = arr[selected_index]
                    arr[selected_index] = tmp
                end
            end
        end
        for _index = 1, count, 1 do
            local index = arr[_index]
            local behavior = self:getChildAtIndex(index)
            if behavior:visit(arguments) == true then
                return true
            end
        end
    end

    return false
end

return QAISelector