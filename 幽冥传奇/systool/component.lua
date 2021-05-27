
Component = Component or BaseClass()

function Component:__init(depends)
    self.depends = depends or {}
end

function Component:GetDepends()
    return self.depends
end

function Component:GetTarget()
    return self.target
end

function Component:ExportMethods_(methods)
    self.exported_methods = methods
    local target = self.target
    local com = self
    for _, key in ipairs(methods) do
        if not target[key] then
            local m = com[key]
            target[key] = function(__, ...)
                return m(com, ...)
            end
        end
    end
    return self
end

function Component:Bind(target)
    self.target = target
    for _, class_ref in ipairs(self.depends) do
        if not target:CheckComponent(class_ref) then
            target:AddComponent(class_ref)
        end
    end
    self:onBind(target)
end

function Component:UnBind()
    if self.exported_methods then
        local target = self.target
        for _, key in ipairs(self.exported_methods) do
            target[key] = nil
        end
    end
    self:onUnbind()
end

function Component:onBind()
end

function Component:onUnbind()
end
