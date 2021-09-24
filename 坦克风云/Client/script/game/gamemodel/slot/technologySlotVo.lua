technologySlotVo={}

function technologySlotVo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function technologySlotVo:initData(tid,st,et,status,addTime,tc,slotid,hid)
   self.tid=tid
   self.st=st
   self.et=et
   self.status=status  --1:正在升级队列 2:等待队列
   self.addTime=addTime
   self.timeConsume=tc --生产需要的时长
   self.slotid=slotid --生产队列id
   self.hid=hid --是否发过军团求助请求
end