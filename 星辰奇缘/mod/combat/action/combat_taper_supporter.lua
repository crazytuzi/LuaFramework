-- 多事件触发 接受收到通知再触发EventType.End事件
-- 只能注册EventType.End事件
TaperSupporter = TaperSupporter or BaseClass(CombatBaseAction)

function TaperSupporter:__init(brocastCtx)
    self.__ActionName = "TaperSupporter"
    self.queue = {}
end

function TaperSupporter:EmptyCheck() 
    if #self.queue == 0 then
        self:InvokeAndClear(CombatEventType.End)
    end
end

function TaperSupporter:Enqueue(eventType)
    table.insert(self.queue, eventType)
end

function TaperSupporter:Play() 
    if #self.queue > 0 then
        table.remove(self.queue, 1)
        if #self.queue == 0 then
            self:InvokeAndClear(CombatEventType.End)
        end
    else
        self:InvokeAndClear(CombatEventType.End)
    end
end
