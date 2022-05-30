-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-09-28
-- --------------------------------------------------------------------
MergeserverModel = MergeserverModel or BaseClass()

function MergeserverModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
    
end

function MergeserverModel:config()
end

-- function MergeserverModel:setBaseData(data)  
	
-- end

-- function MergeserverModel:getBaseData()  
	
-- end



function MergeserverModel:setVotingStatus( flag ) --投票是否成功
	self.vote_status = flag
end

function MergeserverModel:getVotingStatus()
	if self.flag == nil then return end
	return self.vote_status
end

function MergeserverModel:setMainuiAction(status)
    GlobalEvent:getInstance():Fire(MergeserverEvent.vote_mergeAction_event, status)
end



function MergeserverModel:setResult(data)  -- 设置点数
	if data ~= nil or next(data) ~= nil then 
		self.result = {}
		self.result.flag = data.flag
		self.result.id = data.id
		self.result.agreepoints = data.agreepoints
		self.result.disagreepoints = data.disagreepoints
	end
end


function MergeserverModel:getResult()  -- 设置点数
	return self.result
end

function MergeserverModel:setCountDownTime(node,less_time)
    if tolua.isnull(node) then return end
    doStopAllActions(node)
    if less_time > 0 then
        self:setTimeFormatString(node,less_time)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(node)
                node:setString("00:00:00")
            else
                self:setTimeFormatString(node,less_time)
            end
        end))))
    else
        self:setTimeFormatString(node,less_time)
    end
end
function MergeserverModel:setTimeFormatString(node,time)
    if time > 0 then
        node:setString(TimeTool.GetTimeFormatDayIIIIIIII(time))
    else
        doStopAllActions(node)
        node:setString("00:00:00")
    end
end

function MergeserverModel:__delete()
end