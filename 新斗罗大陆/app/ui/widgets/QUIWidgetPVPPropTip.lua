-- @Author: xurui
-- @Date:   2019-04-12 12:04:43
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-08 15:46:46
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetPVPPropTip = class("QUIWidgetPVPPropTip", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QRichText = import("..utils.QRichText")


local DESC_DETAIL ="##A斗罗武魂##Y，##A图鉴##Y，##A头像框##Y，和##A援助魂师##Y属性继承"
local DESC_PROP ="##Y考古属性##A%s%##Y+图鉴##A%s%##Y+头像框##A%s%##Y+援助魂师继承##A%s%"
local DESC_PROP_TABLE ={"##Y主力PVP物理减伤：",
"##Y主力PVP物理加伤：",
"##Y主力PVP魔法减伤：",
"##Y主力PVP魔法加伤："}


function QUIWidgetPVPPropTip:ctor(options)
	local ccbFile = "ccb/Widget_pvp_info.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetPVPPropTip.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._originHeight = 80
    self._heroHead = {}
end

function QUIWidgetPVPPropTip:onEnter()
end

function QUIWidgetPVPPropTip:onExit()
end

function QUIWidgetPVPPropTip:setInfo(heroList, showTeam , add_propList)
    if showTeam and heroList.teamNum then
        self._ccbOwner.tf_title:setString(string.format("第%s队主力PVP属性加成", q.numToWord(heroList.teamNum)))
        self._ccbOwner.tf_title_sourse:setString(string.format("第%s队PVP属性来源", q.numToWord(heroList.teamNum)))
    else
        self._ccbOwner.tf_title:setString("主力PVP属性加成")
        self._ccbOwner.tf_title_sourse:setString("主力PVP属性来源")
    end

    local index = 0
    if q.isEmpty(heroList) == false then
        for i = 1, 4 do
            local heroInfos = heroList[i]
            if q.isEmpty(heroInfos) then
                self._ccbOwner["node_"..i]:setVisible(false)
                if self._heroHead[i] ~= nil then
                    self._heroHead[i]:removeFromParent()
                    self._heroHead[i] = nil
                end
            else
                index = index + 1

                --set head 
                if heroInfos.heroInfo then
                    if self._heroHead[i] == nil then
                        self._heroHead[i] = QUIWidgetHeroHead.new()
                        self._heroHead[i]:setScale(0.8)
                        self._ccbOwner["node_head_"..i]:addChild(self._heroHead[i])
                    end
                    self._heroHead[i]:setHeroInfo(heroInfos.heroInfo or {})
                end

                local prop = heroInfos.prop or {}
                self._ccbOwner["node_"..i]:setVisible(true)
                for key, value in pairs(prop) do
                    if self._ccbOwner[key.."_"..i] then
                        -- self._ccbOwner[key.."_"..i]:setString(string.format("+%s%%",math.floor(value*1000)/10))
                        self._ccbOwner[key.."_"..i]:setString(q.PropPercentHanderFun(value))
                    end
                end
            end
        end
    end
    self._originHeight = self._originHeight + index * 120

    self._ccbOwner.node_add_prop:setVisible(false)
    
    -- if index > 0 then
    --     self._originHeight = self._originHeight + 300
    --     self._ccbOwner.node_add_prop:setPositionY(-720 + (4 - index ) * 120)

    --     local rich_text = QRichText.new(DESC_DETAIL,nil,{defaultColor = ccc3(255, 216, 173),defaultSize = 20,stringType = 1})
    --     rich_text:setAnchorPoint(ccp(0.5,0.5))
    --     self._ccbOwner.node_desc_detail:addChild(rich_text)
    --     if not  q.isEmpty(add_propList) then
    --         QPrintTable(add_propList)
    --         for i=1,4 do
    --             if add_propList[i] then
    --                 local prop_value1 =add_propList[i][1] or 0
    --                 local prop_value2 =add_propList[i][2] or 0
    --                 local prop_value3 =add_propList[i][3] or 0
    --                 local prop_value4 =add_propList[i][4] or 0
    --                 local attr_desc ="##Y斗罗武魂##A" ..string.format("%0.1f%%", prop_value1*100).."##Y+图鉴##A"
    --                 ..string.format("%0.1f%%", prop_value2*100)..
    --                 "##Y+头像框##A"..string.format("%0.1f%%", prop_value3*100).."##Y+援助魂师继承##A"..string.format("%0.1f%%", prop_value4*100)
    --                 local str_ = DESC_PROP_TABLE[i]..attr_desc
    --                 local rich_text = QRichText.new(str_,nil,{defaultColor =ccc3(255, 216, 173),defaultSize = 20,stringType = 1})
    --                 rich_text:setAnchorPoint(ccp(0.5,0.5))
    --                  self._ccbOwner["node_desc_"..i]:addChild(rich_text)

    --             end

    --         end
    --     end
    -- end
end

function QUIWidgetPVPPropTip:getContentSize()
	return CCSize(720, self._originHeight)
end

return QUIWidgetPVPPropTip
