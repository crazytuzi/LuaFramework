acCustomRechargeRebateVo=activityVo:new()

function acCustomRechargeRebateVo:updateSpecialData(data)
	-- local vo=activityVoApi:getActivityVo("firstRecharge")
 --    if(vo and vo.hasData==true and activityVoApi:isStart(vo))then
 --        self.over=true
 --    else
 --        self.over=false
 --    end


    if(eventDispatcher:hasEventHandler("activity.firstRechargeComplete2",self.onActivityChangeListener)==false)then
        eventDispatcher:addEventListener("activity.firstRechargeComplete2",self.onActivityChangeListener)
    end
    if data.reward then
        local award=FormatItem(data.reward)
        if award and award[1] and award[1].num then
        	self.discount=award[1].num
        end
    end

end

function acCustomRechargeRebateVo:onActivityChangeListener(event,data)
    -- local vo=activityVoApi:getActivityVo("firstRecharge")
    -- local selfVo=acCustomRechargeRebateVoApi:getAcVo()
    -- if(vo and vo.hasData==true and activityVoApi:isStart(vo))then
    --     selfVo.over=true
    -- else
    --     selfVo.over=false
    -- end

    activityVoApi:getAllActivity()
    activityVoApi:updateUserDefault()
	activityVoApi.newNum = activityVoApi:newAcNum()
    activityVoApi:updateShowState(selfVo)
end
function acCustomRechargeRebateVo:clear()
    eventDispatcher:removeEventListener("activity.firstRechargeComplete2",self.onActivityChangeListener)
end