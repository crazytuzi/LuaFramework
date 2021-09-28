NewbieGuideVo = BaseClass()

function NewbieGuideVo:__init(data)
	self.taskId = 0
	self.guideId = 0
	self.execCnt = 0 --某个引导的被执行次数
	self:Update(data)
end

function NewbieGuideVo:__delete()

end

function NewbieGuideVo:Update(data)
	self.taskId = data.taskId or 0
	self.guideId = data.guideId or 0
end

function NewbieGuideVo:AddExecCnt()
	self.execCnt = self.execCnt + 1
end

function NewbieGuideVo:GetTaskId()
	return self.taskId
end

function NewbieGuideVo:GetGuideId()
	return self.guideId
end

function NewbieGuideVo:GetExecCnt()
	return self.execCnt
end

function NewbieGuideVo:ToString()
	-- print("====== NewbieGuideVo taskId " , self.taskId , " guideId " , self.guideId)
end

