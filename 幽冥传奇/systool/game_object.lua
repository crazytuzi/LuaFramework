GameObject = GameObject or {}

function GameObject.Extend(target)
    target.components = {}

    function target:CheckComponent(class_ref)
        return self.components[class_ref] ~= nil
    end

    function target:AddComponent(class_ref)
        local component = class_ref.New()
        self.components[class_ref] = component
        component:Bind(self)
        return component
    end

    function target:RemoveComponent(class_ref)
        local component = self.components[class_ref]
        if component then component:UnBind() end
        self.components[class_ref] = nil
    end

    function target:GetComponent(class_ref)
        return self.components[class_ref]
    end

    return target
end
