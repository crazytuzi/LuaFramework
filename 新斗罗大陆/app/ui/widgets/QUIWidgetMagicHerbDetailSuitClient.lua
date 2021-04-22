-- @Author: xurui
-- @Date:   2019-03-29 16:06:13
-- 仙品养成详情界面套装部分
--

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbDetailSuitClient = class("QUIWidgetMagicHerbDetailSuitClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")

function QUIWidgetMagicHerbDetailSuitClient:ctor(options)
	local ccbFile = "ccb/Widget_MagicHerb_Detail_SuitCell.ccbi"
    local callBacks = {}
    QUIWidgetMagicHerbDetailSuitClient.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetMagicHerbDetailSuitClient:onEnter()
end

function QUIWidgetMagicHerbDetailSuitClient:onExit()
end

function QUIWidgetMagicHerbDetailSuitClient:setInfo(info, magicHerbItemInfo, actorId)
    if magicHerbItemInfo then
        local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)
        self._ccbOwner.tf_suit_name:setString("百草集："..magicHerbConfig.type_name)

        local suitType = magicHerbConfig.type
        local suitMagicHerbSketchItemList = remote.magicHerb:getMaigcHerbSketchItemByType(suitType, 20)
        local secondKeyName = ""
        local tbl = {}
        for _, magicHerbSketchItem in ipairs(suitMagicHerbSketchItemList) do
            if magicHerbSketchItem
                and magicHerbSketchItem.name ~= magicHerbConfig.name
                and magicHerbSketchItem.name ~= secondKeyName then
                if secondKeyName == "" then
                    secondKeyName = magicHerbSketchItem.name
                end
                table.insert(tbl, magicHerbSketchItem)
            end
        end
        local index = 1
        while true do
            local node = self._ccbOwner["node_suit"..index]
            if node then
                local icon = QUIWidgetMagicHerbBox.new()
                if index == 1 then
                    icon:setInfo(info.sid) 
                else
                    icon:setSketchByItemId(tbl[index - 1].id) 
                end
                icon:hideSabc()
                icon:hideLevel()
                icon:hideStar()
                icon:setItemFrame(20)
                node:removeAllChildren()
                node:addChild(icon)
                index = index + 1
            else
                break
            end
        end

        local uiHeroModel
        local minAptitude = 9999
        local minBreed = 0
        if actorId then
            uiHeroModel = remote.herosUtil:getUIHeroByID(actorId)
        end

        if uiHeroModel then
            local suitSkill,_minAptitudeInSuit,_minBreedLvInSuit , magicHerbSuitConfig = uiHeroModel:getMagicHerbSuitSkill()
            if magicHerbSuitConfig then
                minAptitude = magicHerbSuitConfig.aptitude
                minBreed = magicHerbSuitConfig.breed
            end
        end

        local suitConfigList = remote.magicHerb:getMagicHerbSuitConfigsByType(suitType)

        if self._suitTF == nil then
            self._suitTF = QRichText.new(nil, 540, {lineSpacing= 6, stringType = 1})
            self._suitTF:setAnchorPoint(ccp(0, 1))
            self._ccbOwner.node_suit:addChild(self._suitTF)
            self._suitTF:setPosition(-265, -160)
        end
        local propConfig = {}
        local activateColor = COLORS.j
        local unactivateColor = COLORS.n
        for _, config in ipairs(suitConfigList) do
            local color = unactivateColor
            if minAptitude == config.aptitude and config.breed == minBreed then
                color = activateColor
            end
            local aptitude = config.aptitude
            local add = ""
            if config.breed == remote.magicHerb.BREED_LV_MAX then
                aptitude = APTITUDE.SS
            elseif config.breed > 0 then
                add = "+"..config.breed
            end

            local skillConfig = QStaticDatabase.sharedDatabase():getSkillByID(config.skill)
            local aptitudeInfo = QStaticDatabase:sharedDatabase():getSABCByQuality(aptitude)
            table.insert(propConfig, {oType = "font", content = "【"..aptitudeInfo.qc..add.."级".."】"..skillConfig.name.."："..skillConfig.description, size = 20, color = color})
            table.insert(propConfig, {oType = "wrap"})
            table.insert(propConfig, {oType = "wrap"})
        end
        self._suitTF:setString(propConfig)
        local suitTFHeight = self._suitTF:getContentSize().height
        local totalHeight = self._suitTF:getPositionY() - suitTFHeight + self._ccbOwner.node_suit:getPositionY()
        return totalHeight
    end
    return 0
end

function QUIWidgetMagicHerbDetailSuitClient:getContentSize()
	return CCSize(0, 0)
end

return QUIWidgetMagicHerbDetailSuitClient
