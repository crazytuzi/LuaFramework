-- @Author: xurui
-- @Date:   2018-08-15 17:05:06
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-17 17:36:16
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogMetalCityHelp = class("QUIDialogMetalCityHelp", QUIDialogBaseHelp)

local QListView = import("...views.QListView")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetBaseHelpTitle = import("..widgets.QUIWidgetBaseHelpTitle")
local QUIWidgetBaseHelpAward = import("..widgets.QUIWidgetBaseHelpAward")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetBaseHelpLine = import("..widgets.QUIWidgetBaseHelpLine")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QUIViewController = import("..QUIViewController")

--初始化
function QUIDialogMetalCityHelp:ctor(options)
	QUIDialogMetalCityHelp.super.ctor(self, options)

	self:setShowRule(true)
end

function QUIDialogMetalCityHelp:initData( options )
	-- body
	local options = self:getOptions() 
	self.info = options.info or {} 

	local myInfoDict = remote.metalCity:getMetalCityMyInfo()

	local curentFloorInfo = remote.metalCity:getMetalCityConfigByFloor((myInfoDict.metalNum or 0))

	local data = {}
	self._data = data

	local customStr = "尚未通关"
 	if q.isEmpty(curentFloorInfo) == false then
		local chapterStr = q.numToWord(curentFloorInfo.metalcity_chapter or 0)
		local floorStr = q.numToWord(curentFloorInfo.metalcity_floor or 0)
 		customStr = string.format("当前通关：第%s章 第%s层", chapterStr, floorStr)
 	end
	table.insert(data, {oType = "describe", customStr = customStr, info = {pos = ccp(30, -10), size = CCSizeMake(720, 35)}})
	table.insert(data,{oType = "empty", height = 10})

	table.insert(data,{oType = "describe", info = {
		helpType = "help_metalcity",
		}})
	table.insert(data,{oType = "empty", height = 10})

	table.insert(data,{oType = "describe", info = {
		helpType = "help_trap",
		}})
	
	local allSkills = remote.metalCity:getAllBossSkills()
	local skills = {}
	for _, value in pairs(allSkills) do
		skills[#skills+1] = value
	end
	table.sort(skills, function(a, b)
			local skill1 = tonumber(a)
			local skill2 = tonumber(b)
			if skill1 ~= skill2 then
				return skill1 < skill2
			else
				return false
			end
		end)


	for _, value in ipairs(skills) do
		table.insert(data, {oType = "award2", info = {skillId = value}})
	end
end

function QUIDialogMetalCityHelp:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache(itemData.oType)
	            if not item then
	            	if itemData.oType == "describe" then
	            		item = QUIWidgetHelpDescribe.new()
	            	elseif itemData.oType == "title" then
	            		item = QUIWidgetBaseHelpTitle.new()
	            	elseif itemData.oType == "award" then
	            		item = QUIWidgetBaseHelpAward.new()
					elseif itemData.oType == "award2" then
						item = self:getAllRankNode(itemData)
	            	elseif itemData.oType == "line" then
	            		item = QUIWidgetBaseHelpLine.new()
	            	elseif itemData.oType == "empty" then
	            		item = QUIWidgetQlistviewItem.new()
	            	end
	            	isCacheNode = false
	            end
	            if itemData.oType == "empty" then
	            	item:setContentSize(CCSizeMake(0, itemData.height))
	            elseif itemData.oType == "describe" then
	            	item:setInfo(itemData.info or {}, itemData.customStr)
	            elseif itemData.oType ~= "award2" then
	            	item:setInfo(itemData.info)
	            end
	           
	            info.item = item
	            info.size = item:getContentSize()
	            return isCacheNode
	        end,
	        curOriginOffset = 15,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else

		self._listViewLayout:reload({#self._data})
	end
end

function QUIDialogMetalCityHelp:getAllRankNode(itemData)
	local skillId = itemData.info.skillId
  	local skillInfo = QStaticDatabase:sharedDatabase():getSkillByID(skillId)
    local node = CCNode:create()

	local icon = QUIWidgetHeroSkillBox.new()
	icon:setScale(0.5)
    icon:setAnchorPoint(ccp(0, 0.5))
    icon:setPosition(50, -40)
    icon:setSkillID(skillId)
	icon:setLock(false)
	node:addChild(icon)

	local ttfName = CCLabelTTF:create("", global.font_default, 18)
	ttfName:setString(string.format("%s：%s", skillInfo.name, skillInfo.description))
	ttfName:setDimensions(CCSize(700, 80))
	ttfName:setHorizontalAlignment(kCCTextAlignmentLeft)
    -- ttfName:setVerticalAlignment(kCCVerticalTextAlignmentTop)
    ttfName:setAnchorPoint(ccp(0, 1))
    ttfName:setColor(ccc3(134,85,55))
    ttfName:setPosition(80, -15)
	node:addChild(ttfName)

	local height = icon:getContentSize().height - 50
	local ttfHeight = ttfName:getContentSize().height
	if ttfHeight > height then
		height = ttfHeight
	end

    node:setContentSize(CCSize(500, height))

    return node
end

function QUIDialogMetalCityHelp:showRule()
    app.sound:playSound("common_cancel")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMetalCityTutorialDialog", options = {}}, {isPopCurrentDialog = false})
end

return QUIDialogMetalCityHelp