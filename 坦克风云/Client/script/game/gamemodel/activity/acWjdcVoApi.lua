acWjdcVoApi = {
	-- name="",
	questionData={},
	answerData={},
	costTime=0,
}

function acWjdcVoApi:showWjdcDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/activityAndNote/acWjdcDialog"
    local td=acWjdcDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("activity_"..self.getActiveName().."_title"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- function acWjdcVoApi:setActiveName(name)
-- 	self.name=name
-- end

function acWjdcVoApi:getActiveName()
	return "wjdc"
end

function acWjdcVoApi:getAcVo(activeName)
	if activeName==nil then
		activeName=self:getActiveName()
	end
	return activityVoApi:getActivityVo(activeName)
end

function acWjdcVoApi:getVersion()
	local acVo = self:getAcVo()
	if acVo and acVo.version then
		return acVo.version
	end
	return 1
end

function acWjdcVoApi:getRewardCfg()
	local reward={}
	local acVo = self:getAcVo()
	if acVo.activeCfg and acVo.activeCfg.reward and acVo.activeCfg.reward[1] then
		reward=FormatItem(acVo.activeCfg.reward[1]) or {}
	end
	return reward
end

function acWjdcVoApi:canReward(activeName)
	return false
end

function acWjdcVoApi:getTimeStr()
	local str = ""
	local vo=self:getAcVo()
	if vo then
		local timeStr=activityVoApi:getActivityTimeStr(vo.st, vo.et)
		str=timeStr
	end
	return str
end

function acWjdcVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acWjdcVoApi:updateSpecialData(data)
	local vo = self:getAcVo()
	if vo then
		vo:updateSpecialData(data)
	end
end

function acWjdcVoApi:socketReward(refreshFunc)
	local function callback(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			local acName=self:getActiveName()
			if sData and sData.data and sData.data[acName] then
				local acData=sData.data[acName]
				local vo=self:getAcVo()
				vo.over=true
				vo:updateData(acData)
				activityVoApi:updateShowState(vo)
			end
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	socketHelper:activeWjdcReward(callback)
end

function acWjdcVoApi:isShowIcon()
	local hadReward=true
	local vo=self:getAcVo()
	if vo and activityVoApi:isStart(vo)==true then
		if vo.v and vo.v==0 and vo.over==false then
			hadReward=false
		end
	end
	return hadReward
end

function acWjdcVoApi:getQuestionData()
	return self.questionData
end
function acWjdcVoApi:setQuestionData(questionData)
	self.questionData=questionData
end

function acWjdcVoApi:getAnswerData()
	return self.answerData
end
function acWjdcVoApi:setAnswerData(answerData)
	self.answerData=answerData
end

function acWjdcVoApi:getCostTime()
	return self.costTime
end
function acWjdcVoApi:setCostTime(costTime)
	self.costTime=costTime
end

function acWjdcVoApi:clearAll()
	-- self.name=""
	self.questionData={}
	self.answerData={}
	self.costTime=0
end


