require "luascript/script/config/gameconfig/playerCfg"
require "luascript/script/game/gamemodel/player/playerVo"
require "luascript/script/game/gamemodel/slot/buildingSlotVo"
require "luascript/script/game/gamemodel/slot/useItemSlotVo"


useItemSlotVoApi={
     allUseItemSlots={}
}

function useItemSlotVoApi:add(id,st,et) --添加队列

    local tmpSlot=useItemSlotVo:new()
    tmpSlot:initWithData(id,st,et)
    self.allUseItemSlots[id]=tmpSlot

    
end
function useItemSlotVoApi:clear()
    for k,v in pairs(self.allUseItemSlots) do
         v=nil
    end
    self.allUseItemSlots=nil
    self.allUseItemSlots={}

end
--获取所有队列
function useItemSlotVoApi:getAllSlots()
    
    return self.allUseItemSlots

end
--根据队列ID获取道具剩余时间
function useItemSlotVoApi:getLeftTimeById(id)
    local slotVo=self.allUseItemSlots[id]
    if slotVo~=nil then
        return (slotVo.et-base.serverTime)
    else
        return nil
    end

end

function useItemSlotVoApi:getSlotById(id)
    return self.allUseItemSlots[id]
end

function useItemSlotVoApi:remove(id)
    if self.allBuildingSlots[id]~=nil then
        self.allUseItemSlots[id]=nil
    end
end


function useItemSlotVoApi:tick()
    
    for k,v in pairs(self.allUseItemSlots) do
        local leftTime = self:getLeftTimeById(v.id)
        if leftTime<=0 then
            self.allUseItemSlots[tonumber(v.id)]=nil
        end
    end
    
end

function useItemSlotVoApi:getNumByState1()
    local num=0;
    for k,v in pairs(self.allUseItemSlots) do
        if v.id==6 or v.id==7 or v.id==8 or v.id==9 or v.id==10 then
            num=num+1
        end
    end
    
    return num;
end

function useItemSlotVoApi:getNumByState2()
    local num=0;
    for k,v in pairs(self.allUseItemSlots) do
        if v.id==11 or v.id==12 or v.id==13 or v.id==14 then
            num=num+1
        end
    end
    
    return num;

end
function useItemSlotVoApi:isShowState3()
    local isShow=false
    for k,v in pairs(self.allUseItemSlots) do
        local ppid="p"..v.id
        if propCfg[ppid].buffType==7 or propCfg[ppid].buffType==8 or propCfg[ppid].buffType==10 or propCfg[ppid].buffType==11 or propCfg[ppid].buffType==12 or propCfg[ppid].buffType==13 then
            isShow=true
        end
    end
    return isShow
end


