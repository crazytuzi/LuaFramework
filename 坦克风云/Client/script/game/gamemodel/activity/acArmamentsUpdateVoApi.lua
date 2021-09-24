acArmamentsUpdateVoApi = {

}

function acArmamentsUpdateVoApi:clearAll()

end

function acArmamentsUpdateVoApi:getAcVo()
	local vo
	vo = activityVoApi:getActivityVo("armamentsUpdate1")
	if vo==nil then
		vo = activityVoApi:getActivityVo("armamentsUpdate2")
	end
	return vo
end

function acArmamentsUpdateVoApi:updateData(data)
	local vo=self:getAcVo()
	vo:updateData(data)
	activityVoApi:updateShowState(vo)
end

function acArmamentsUpdateVoApi:canReward( ... )
	-- body
end

