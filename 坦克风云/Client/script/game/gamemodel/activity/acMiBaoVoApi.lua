acMiBaoVoApi = {}

function acMiBaoVoApi:getAcVo()
	return activityVoApi:getActivityVo("miBao")
end

function acMiBaoVoApi:getAdvanced()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.advanced
	end
	return nil
end

--拼合后得到的道具id
function acMiBaoVoApi:getPinHeId()
    local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.pinHeId
	end
	return 0
end

-- 碎片配置，获取碎片的需要个数
function acMiBaoVoApi:getPieceCfg()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.piecesCfg
	end
	return nil
end

function acMiBaoVoApi:getPieceCfgByIndex(index)
	local cfg = self:getPieceCfg()
	for k,v in pairs(cfg) do
		if tonumber(RemoveFirstChar(k)) == index then
			return k,v
		end
	end
	return nil
end

function acMiBaoVoApi:getPieceCfgForShow()
	return activityCfg.miBao
end

function acMiBaoVoApi:getPieceCfgForShowBySid(sid)
	local cfg = self:getPieceCfgForShow()
	for k,v in pairs(cfg) do
		if k == sid then
			return v
		end
	end
	return nil
end

function acMiBaoVoApi:getSelfPieces()
	local acVo = self:getAcVo()
	if acVo ~= nil then
		return acVo.pieces
	end
	return nil
end

function acMiBaoVoApi:setSelfPieces(pieces)
	local acVo = self:getAcVo()
	if acVo ~= nil then
		acVo.pieces = pieces
	end
end
-- 碎片的数量
function acMiBaoVoApi:getPieceNum(pieceId)
	local pieces = self:getSelfPieces()
	if pieces ~= nil and type(pieces)=="table" then
		for k,v in pairs(pieces) do
			if k == pieceId then
				return v
			end
		end
	end
	return 0
end

function acMiBaoVoApi:canReward()
	local pieceCfg = self:getPieceCfg()
	if pieceCfg == nil then
		return false
	end
	for k,v in pairs(pieceCfg) do
		if v ~= nil then
            if tonumber(self:getPieceNum(k)) < tonumber(v) then
           	  return false
           	end
		end
	end
	return true
end

-- 拼合成功之后的后续操作
function acMiBaoVoApi:afterPinHeSuccess(lastData)
	self:setSelfPieces(lastData)
	local vo = self:getAcVo()
	activityVoApi:updateShowState(vo)
	vo.stateChanged = true
end