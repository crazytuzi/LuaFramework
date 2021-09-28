
DramaCamera = class("DramaCamera", DramaAbs);

function DramaCamera:_Init()
    --log(tostring(self) .. "___" .. self.__cname)
end

function DramaCamera:_Begin(fixed)
    if fixed then return end
    local t = self.config[DramaAbs.EvenType]
    --PrintTable(self.config, "DramaCamera.Begin: config=",Warning)
    local p1 = self.config[DramaAbs.EvenParam1]
    if t == DramaEventType.CameraPath or t == DramaEventType.CameraPoint then
        local isTGZ = PlayerManager.GetPlayerKind() == PlayerManager.CareerType.tgz
        local p2 = isTGZ and self.config[DramaAbs.EvenParam2] or nil
        if t == DramaEventType.CameraPath then
            if p2 and #p2 > 0 then p1 = p2 end
            self._camera:CameraPath(p1[1], nil)
            self._camera:PlayPath()
        else
            if p2 and #p2 > 5 then p1 = p2 end
            self._camera:LockPoint(Convert.PointFromConfig(p1[1], p1[2], p1[3]), Vector3(p1[4], p1[5], p1[6]))
        end
    elseif t == DramaEventType.CameraShake then
        self._camera:Shake(tonumber(p1[1]), nil, nil, true)
    end
end
