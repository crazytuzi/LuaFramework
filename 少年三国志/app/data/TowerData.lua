local TowerData = class("TowerData")

function TowerData:ctor()
    self._queryTime = 0
    self._cleanup_time = 0
    self._towerInfo = nil
end

function TowerData:getCleanTime()
    return self._cleanup_time
end

function TowerData:setCleanTime(time)
    self._cleanup_time = time
end

function TowerData:setTowerInfo(data)
    self._towerInfo = data
    self._queryTime = os.time()
    self._cleanup_time = data.cleanup_time
    self._maxFloor = data.next_challenge - 1
end

function TowerData:setMaxFloor(floor)
     self._maxFloor = floor
end

function TowerData:getTowerInfo()
     return self._towerInfo
end

--默认0
function TowerData:getMaxFloor()
    return self._towerInfo.next_challenge - 1 or 0
end

return TowerData

