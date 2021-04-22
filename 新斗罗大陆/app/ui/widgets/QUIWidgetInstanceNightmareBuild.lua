local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInstanceNightmareBuild = class("QUIWidgetInstanceNightmareBuild", QUIWidget)
local QUIWidgetInstanceProgress = import("..widgets.QUIWidgetInstanceProgress")

QUIWidgetInstanceNightmareBuild.STATE_OPEN = "STATE_OPEN"
QUIWidgetInstanceNightmareBuild.STATE_CLOSE = "STATE_CLOSE"

QUIWidgetInstanceNightmareBuild.EVENT_SELECT_INDEX = "EVENT_SELECT_INDEX"

function QUIWidgetInstanceNightmareBuild:ctor(options)
	local ccbFile = "ccb/Widget_BigEliteEM_city.ccbi"
	local callbacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetInstanceNightmareBuild._onTriggerClick)},
	}
	QUIWidgetInstanceNightmareBuild.super.ctor(self, ccbFile, callbacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
    self._progress = QUIWidgetInstanceProgress.new()

    self._ccbOwner.node_progress:addChild(self._progress)
end

function QUIWidgetInstanceNightmareBuild:onEnter()
end

function QUIWidgetInstanceNightmareBuild:onExit()
	QUIWidgetInstanceNightmareBuild.super.onExit(self)
	self:removeAllEventListeners()
end

function QUIWidgetInstanceNightmareBuild:playLock()
    self._animationManager:runAnimationsForSequenceNamed("shitou1")
end

function QUIWidgetInstanceNightmareBuild:playAppear()
    self._animationManager:runAnimationsForSequenceNamed("chuxian")
end

function QUIWidgetInstanceNightmareBuild:playNormal()
    self._animationManager:runAnimationsForSequenceNamed("daiji")
end

function QUIWidgetInstanceNightmareBuild:playDisappear()
    self._animationManager:runAnimationsForSequenceNamed("xiaoshi")
end

function QUIWidgetInstanceNightmareBuild:playClose()
    self._animationManager:runAnimationsForSequenceNamed("shitou2")
end

--设置噩梦本ID
--renderIndex用于地图界面记住之前的位置，返回之后直接到该位置
function QUIWidgetInstanceNightmareBuild:setNightmareId(nightmareId, renderIndex)
	self._nightmareId = nightmareId
	self._renderIndex = renderIndex
    local nightmareInfo = remote.nightmare:getNightmareByNightmareId(nightmareId)
    local nightmareConfig = remote.nightmare:getConfigByNightmareId(nightmareId)
    if nightmareConfig.isLock == false then
        self._progress:setVisible(true)
        self._ccbOwner.tf_name2:setString(nightmareConfig.configs[1].instance_name)
        self._ccbOwner.tf_explanation2:setString("")

        local dungeonIcon = nightmareConfig.configs[1].dungeon_icon
        if dungeonIcon ~= nil then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/nightmare.plist")
            self._ccbOwner.sp_icon:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(dungeonIcon))
        end

        local currentProgress,totalCount = remote.nightmare:getProgressByNightmareId(nightmareId)
        -- self._ccbOwner.tf_star1:setString(currentProgress.."/"..totalCount)
        self._progress:updateProgress(currentProgress, totalCount)
        
        local _nightmareConfigs = nightmareConfig.configs
        if nightmareInfo ~= nil and nightmareInfo.passProgress == _nightmareConfigs[#_nightmareConfigs].int_dungeon_id then
            if remote.nightmare:getBattleId() == _nightmareConfigs[#_nightmareConfigs].instance_id then
                remote.nightmare:setBattleId(nil)
                self:playDisappear()
            else
                self:playClose()
            end
        else
            self:playNormal()
        end
    else
        self:playLock()
        self._progress:setVisible(false)
        self._ccbOwner.tf_name2:setString("")
        if nightmareConfig.configs[1].unlock_dungeon_id ~= nil then
            local dungeonConfig = remote.instance:getDungeonById(nightmareConfig.configs[1].unlock_dungeon_id)
            local name = dungeonConfig.instance_name
            name = string.split(name," ")
            if #name >= 2 then
                name = name[2]
            else
                name = dungeonConfig.instance_name
            end
            self._ccbOwner.tf_explanation2:setString(string.format("通关%s后开启",name))
        else
            self._ccbOwner.tf_explanation2:setString("即将开放")
        end
    end
end

-- --设置噩梦本ID
-- --renderIndex用于地图界面记住之前的位置，返回之后直接到该位置
-- function QUIWidgetInstanceNightmareMap:setNightmareId(nightmareId, renderIndex)
--     self._nightmareId = nightmareId
--     self._renderIndex = renderIndex
--     local nightmareInfo = remote.nightmare:getNightmareByNightmareId(nightmareId)
--     local nightmareConfig = remote.nightmare:getConfigByNightmareId(nightmareId)
--     self._ccbOwner.tf_number:setString(nightmareConfig.index)
--     local _nightmareConfigs = nightmareConfig.configs
--     if nightmareInfo ~= nil and nightmareInfo.passProgress == _nightmareConfigs[#_nightmareConfigs].int_dungeon_id then
--         if remote.nightmare:getBattleId() == _nightmareConfigs[#_nightmareConfigs].instance_id then
--             remote.nightmare:setBattleId(nil)
--             self:playDisappear()
--         else
--             self:playClose()
--         end
--     else
--         self:playNormal()
--     end

--     self._ccbOwner.tf_name:setString(_nightmareConfigs[1].instance_name)
--     local currentProgress,totalCount = remote.nightmare:getProgressByNightmareId(nightmareId)
--     self._ccbOwner.tf_progress:setString(currentProgress.."/"..totalCount)
--     self._ccbOwner.node_bar:setScaleX(currentProgress/totalCount)
-- end

function QUIWidgetInstanceNightmareBuild:_onTriggerClick()
    local nightmareInfo = remote.nightmare:getNightmareByNightmareId(self._nightmareId)
    local nightmareConfig = remote.nightmare:getConfigByNightmareId(self._nightmareId)
    if nightmareConfig.isLock == true then
        return
    end
    local _nightmareConfigs = nightmareConfig.configs
    self:dispatchEvent({name = QUIWidgetInstanceNightmareBuild.EVENT_SELECT_INDEX, renderIndex = self._renderIndex, nightmareId = self._nightmareId})
end

return QUIWidgetInstanceNightmareBuild