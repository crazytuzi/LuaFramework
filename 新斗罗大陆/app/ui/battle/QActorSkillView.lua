
local QActorSkillView = class("QActorSkillView", function()
    return display.newNode()
end)

function QActorSkillView:ctor()

end

function QActorSkillView:setString(str)
    if self._ccbOwner == nil then
        local ccbFile = "ccb/Battle_Skil_name.ccbi"
        local proxy = CCBProxy:create()
        self._ccbOwner = {}        
        local ccbView = CCBuilderReaderLoad(ccbFile, proxy, self._ccbOwner)
        if ccbView == nil then
            assert(false, "load ccb file:" .. ccbFile .. " faild!")
        end
        self:addChild(ccbView)
        local label = self._ccbOwner.label_name
        local shadow = CCLabelTTF:create("", label:getFontName(), label:getFontSize())
        shadow:setColor(ccc3(0, 0, 0))
        shadow:setPositionX(label:getPositionX() + 2)
        shadow:setPositionY(label:getPositionY() - 2)
        label:getParent():addChild(shadow)
        label:retain()
        label:removeFromParent()
        shadow:getParent():addChild(label)
        label:release()
        self._label = label
        self._shadow = shadow

        if self._color then
            self._label:setColor(self._color)
        end
    end

    if self._label then
        self._label:setString(str)
    end
    if self._shadow then
        self._shadow:setString(str)
    end
end

function QActorSkillView:setColor(color)
    self._color = color
end

return QActorSkillView