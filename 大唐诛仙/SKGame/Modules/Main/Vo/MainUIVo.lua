--主界面各个Item对应的Vo
MainUIVo =BaseClass()


function MainUIVo:__init()
	self.pos = Vector3.Zero --显示位置
	self.posIdx = 0 --显示位置索引值（在第几个位置显示） 图标位置0：默认就存在于界面，位置固定
	self.id = "" --各个Item对应的唯一id
	self.state = MainUIConst.MainUIItemState.None
	self.limitLev = 0 --限制等级
	self.openTaskId = 0 --通过完成某任务开放
	self.moduleId = 0 --对应的系统模块ID
	self.isFadeIn = false --时候渐显（图标解锁时，由透明渐变到可见(过程1.3秒））
end

function MainUIVo:SetData(pos , posIdx , id , state , limitLev , openTaskId , moduleId , isFadeIn)
	self.pos = pos or Vector3.Zero
	self.posIdx = posIdx or 0
	self.id = id or ""
	self.state = state or MainUIConst.MainUIItemState.None
	self.limitLev = limitLev or 0
	self.openTaskId = openTaskId or 0
	self.moduleId = moduleId or 0
	if isFadeIn == nil then
		self.isFadeIn = false
	else
		self.isFadeIn = isFadeIn
	end
end

function MainUIVo:GetPosIdx()
	return self.posIdx
end

function MainUIVo:GetId()
	return self.id
end

function MainUIVo:SetState(state)
	if state then
		if state == MainUIConst.MainUIItemState.None then
			self.state = MainUIConst.MainUIItemState.None
		elseif state == MainUIConst.MainUIItemState.Open then
			self.state = MainUIConst.MainUIItemState.Open
		elseif state == MainUIConst.MainUIItemState.Close then
			self.state = MainUIConst.MainUIItemState.Close
		else
			self.state = MainUIConst.MainUIItemState.None
		end
	end
end

function MainUIVo:GetState()
	return self.state
end

function MainUIVo:GetLimitLev()
	return self.limitLev
end

function MainUIVo:GetOpenTaskId()
	return self.openTaskId
end

function MainUIVo:GetModuleId()
	return self.moduleId
end

function MainUIVo:__delete()

end


