tankSlotVo={
}

function tankSlotVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

--slotId:队列ID  itemId:物品ID  itemNum:物品数量 status:队列状态  st:开始生产时间 addTime:加入队列时间
function tankSlotVo:initData(slotId,itemId,itemNum,status,st,et,addTime,timeConsume)
     self.slotId=slotId
     self.itemId=itemId
     self.itemNum=itemNum
     self.status=status --1:生产中 2:等待中
     self.st=st
     self.et=et
     if newGuidMgr:isNewGuiding() then 
        self.et=self.et-1
     end
     self.addTime=addTime
     self.timeConsume=timeConsume
end