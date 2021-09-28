module ("NewActiveData", package.seeall)

local _activeData = nil

function setData( pData )
	-- body
	_activeData = pData
end

function getData()
	-- body
	return _activeData
end

--处理网络返回的活动数据 添加每条任务完成进度并排序
function dealData( pData )
	-- body
	if(table.isEmpty(pData))then
		return
	end
	for rewardKey,rewardValue in pairs(pData.config.reward)do
		if(tonumber(pData.taskInfo.num)>=tonumber(rewardValue.num))then
			rewardValue.status=0
		else
			rewardValue.status=1
		end
		rewardValue.id = rewardKey-1
	end
	for key,value in pairs(pData.taskInfo.rewarded)do
		for rewardKey,rewardValue in pairs(pData.config.reward)do
			if(tonumber(rewardKey)-1==tonumber(value))then
				rewardValue.status=2
				break
			end
		end
	end
	setData(pData)
end

function changeDataStatus( pIndex )
	-- body
	_activeData.config.reward[pIndex].status = 2
	table.insert(_activeData.taskInfo.rewarded,tostring(_activeData.config.reward[pIndex].id))
end

function isNewActiveOpen()
	-- body
	if(not table.isEmpty(_activeData))then
		return true
	else
		return false
	end
end

function getNewActiveId( ... )
	-- body
	if(not table.isEmpty(_activeData))then
		return tonumber(_activeData.config.id)
	else
		return 1
	end
end

function haveNewActiveTip( ... )
	-- body
	local haveTip = false
	if(_activeData==nil)then
		return false
	end
	for rewardKey,rewardValue in pairs(_activeData.config.reward)do
		if(rewardValue.status==0)then
			haveTip = true
			break
		end
	end
	return haveTip
end

function getFinisActiveNum( ... )
	-- body
end