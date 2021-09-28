
DramaActor = class("DramaActor", DramaAbs);

function DramaActor:_Init()
    --log(tostring(self) .. "___" .. self.__cname)
end

function DramaActor:_Begin(fixed)
    local t = self.config[DramaAbs.EvenType]
    local p1 = self.config[DramaAbs.EvenParam1]
    local p2 = self.config[DramaAbs.EvenParam2]
    if t == DramaEventType.EntityScene then
        self.actorGo = self:_GetSceneGo(p1[1])
        local animator = self.actorGo:GetComponent("Animator")
        animator:Play(p2[1], -1 , fixed and 1 or 0)
    elseif t == DramaEventType.EntityEffect then
        if fixed and not self:_IsDelayDetele() then return end
        local parent = nil
        local p2Len = #p2
        if p2Len ~= 0  and string.len(string.trim(p2[1])) > 0 then
            local roleType = p2[2]
            local r = DramaRole.GetDramaRole( p2[1] , roleType, self._hero)
            if not r then return end
            parent = r.transform
            if p2Len > 2 then
                local childrens = UIUtil.GetComponentsInChildren(parent, "Transform")
                parent = UIUtil.GetChildInComponents(childrens, p2[3])
            end
        end
        local actorGo = Resourcer.Get(p1[1], p1[2], parent)
        if not actorGo then
            actorGo = GameObject.New(p1[2])
        else
            self.actorGo = actorGo
        end
        Util.SetLocalPos(actorGo, Convert.PointFromConfig(p1[3], p1[4], p1[5]))
        self:_DelayDetele(actorGo)
        NGUITools.SetChildLayer(actorGo.transform, Layer.Default)
    end
end

function DramaActor:_Dispose()
    if self.actorGo and not self.isDelayDetele then
        Resourcer.Recycle(self.actorGo, false)
        self.actorGo = nil
    end
end
