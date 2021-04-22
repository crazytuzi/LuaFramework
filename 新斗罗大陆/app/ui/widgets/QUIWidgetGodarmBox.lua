-- @Author: liaoxianbo
-- @Date:   2019-12-26 16:46:32
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-16 14:42:05
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodarmBox = class("QUIWidgetGodarmBox", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetHeroHeadStar = import("..widgets.QUIWidgetHeroHeadStar")
local QUIViewController = import("..QUIViewController")

QUIWidgetGodarmBox.MOUNT_EVENT_CLICK = "MOUNT_EVENT_CLICK"

function QUIWidgetGodarmBox:ctor(options)
	local ccbFile = "ccb/Widget_Godarm_box.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetGodarmBox.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._star = QUIWidgetHeroHeadStar.new({})
	self._ccbOwner.node_star:setScale(0.8)
	self._ccbOwner.node_star:addChild(self._star)

	self:resetAll()
end

function QUIWidgetGodarmBox:onEnter()
end

function QUIWidgetGodarmBox:onExit()
end

function QUIWidgetGodarmBox:resetAll()
	self._ccbOwner.node_level:setVisible(false)
	self._ccbOwner.node_star:setVisible(false)
	self._ccbOwner.node_plus:setVisible(false)
	self._ccbOwner.sp_red_tips:setVisible(false)
	self._ccbOwner.sp_select:setVisible(false)
	self._ccbOwner.tf_lock:setVisible(true)
	self._ccbOwner.sp_label:setVisible(false)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_pingzhi:removeAllChildren()
	self._ccbOwner.node_dress:setVisible(false)

	self:addSpriteFrame(self._ccbOwner.node_rect, QUIWidgetItemsBox.color_frame["default"][1])
end

function QUIWidgetGodarmBox:setHighlightedSelectState(state)
    if state == nil then state = false end
    
    self._ccbOwner.sp_select:setVisible(state)
end

--刷新格子
function QUIWidgetGodarmBox:refreshBox()
	self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if self._lockConfig.hero_level > self._heroInfo.level then
		self:resetAll()
		local lockStr = self._lockConfig.hero_level.."级\n开启"
		self._ccbOwner.tf_lock:setString(lockStr)
	else
		self:setMountInfo(self._heroInfo.zuoqi)
	end
end


function QUIWidgetGodarmBox:setNoWearTips()
	self:showRedTips(false)
	self._ccbOwner.tf_lock:setString("未装备")
	self._ccbOwner.node_plus:setVisible(false)
end

function QUIWidgetGodarmBox:setNoDressTips()
	self:showRedTips(false)
	self._ccbOwner.tf_lock:setVisible(false)
	self._ccbOwner.node_plus:setVisible(false)
	self._ccbOwner.node_talent:setVisible(true)
end

function QUIWidgetGodarmBox:setGrade(grade)
	self._star:setStar(grade+1)
end

function QUIWidgetGodarmBox:setLabel( path )
	if path then
		self._ccbOwner.sp_label:setVisible(true)
		QSetDisplaySpriteByPath(self._ccbOwner.sp_label,path)
	end
end
function QUIWidgetGodarmBox:setStarVisible(b)
	self._ccbOwner.node_star:setVisible(b)
end

function QUIWidgetGodarmBox:checkTips()
	local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self:showRedTips(uiHeroModel:checkHerosMountRedTips())
end

function QUIWidgetGodarmBox:showRedTips(b)
	self._ccbOwner.sp_red_tips:setVisible(b)
end

function QUIWidgetGodarmBox:setTipsScale(scale)
	self._ccbOwner.sp_red_tips:setScale(scale)
end

function QUIWidgetGodarmBox:isShowLevel(isVisible)
	self._ccbOwner.node_level:setVisible(isVisible)
end

function QUIWidgetGodarmBox:setGodarmInfo(godarmInfo)
	self:resetAll()
	self._godarmInfo = godarmInfo
	if self._godarmInfo == nil then
		self._ccbOwner.node_plus:setVisible(true)
		self._ccbOwner.tf_lock:setString("")
	else
		self._ccbOwner.tf_lock:setVisible(false)
		self:setGoodsInfo(self._godarmInfo)
		self._ccbOwner.node_level:setVisible(true)
		self._ccbOwner.tf_level:setString(self._godarmInfo.level)

		self._ccbOwner.node_star:setVisible(true)
		self:setGrade(self._godarmInfo.grade)

		local sabcInfo = db:getActorSABC(self._godarmInfo.id)
		if sabcInfo then
			self:showSabc(sabcInfo.lower)
		end
	end
end

function QUIWidgetGodarmBox:setGoodsInfo(godarmInfo)
	local godarmConfig = db:getCharacterByID(godarmInfo.id)
	if nil ~= godarmConfig then 
		self:setItemIcon(godarmConfig.icon)
	    local jobIconPath = remote.godarm:getGodarmJobPath(godarmConfig.label)
		self:setLabel(jobIconPath)		
		-- local color = remote.godarm:getColorByGodarmId(godarmInfo.id)
		-- local aptitudeColor = string.lower(color)
		-- self:setFrame(aptitudeColor)
		for _,value in ipairs(HERO_SABC) do
	        if value.aptitude == tonumber(godarmConfig.aptitude) then
	        	local colour = value.color or "default"
	        	self:addSpriteFrame(self._ccbOwner.node_rect, QUIWidgetItemsBox.color_frame[colour][1])
				break
	        end
	    end
	end
end

-- function QUIWidgetGodarmBox:setFrame(color)
--     local pathList = QResPath("soulSpirit_frame_"..color)
--     if pathList then
--         -- local frame = QSpriteFrameByPath(pathList[1])
--         -- if frame then
--         -- 	self._ccbOwner.node_rect:setVisible(true)
--         --     self._ccbOwner.node_rect:setSpriteFrame(frame)
--         -- end
-- 		self:addSpriteFrame(self._ccbOwner.node_rect, pathList[1])        
--     else
--     	local defpath =  QResPath("soulSpirit_frame_".."purple")
--     	self:addSpriteFrame(self._ccbOwner.node_rect, defpath[1])   
--     	-- QPrintTable(defpath)
--      --    local frame = QSpriteFrameByPath(defpath[1])
--      --    if frame then
--      --    	self._ccbOwner.node_rect:setVisible(true)
--      --        self._ccbOwner.node_rect:setSpriteFrame(frame)
--      --    end    	
--     end
-- end

function QUIWidgetGodarmBox:showSabc( quality )
	local icon = CCSprite:create(QResPath("itemBoxPingZhi_"..quality))
	if icon then
		if quality == "a+" or quality == "ss" then
			icon:setPositionX(5)
		end
		self._ccbOwner.node_pingzhi:addChild(icon)
	end
end

function QUIWidgetGodarmBox:addSpriteFrame(sp, frameName)
	if string.find(frameName, "%.plist") ~= nil then
		sp:setDisplayFrame(QSpriteFrameByPath(frameName))
	else
		local texture = CCTextureCache:sharedTextureCache():addImage(frameName)
		sp:setTexture(texture)
		local size = texture:getContentSize()
		local rect = CCRectMake(0, 0, size.width, size.height)
		sp:setTextureRect(rect)
	end
end

--设置icon
function QUIWidgetGodarmBox:setItemIcon(respath)
	if respath~=nil and #respath > 0 then
		local icon = CCSprite:create()
		self._ccbOwner.node_icon:addChild(icon)
		icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
		icon:setScale(1)
		local size = self._ccbOwner.sp_bg:getContentSize()
		icon:setScale(size.width/icon:getContentSize().width)
	end
end

--设置icon
function QUIWidgetGodarmBox:showDressMountLevel()
	self._ccbOwner.node_dress:setVisible(false)
	local grade
	if self._godarmInfo and self._godarmInfo.wearZuoqiInfo then
		grade = self._godarmInfo.wearZuoqiInfo.grade
	end
	if grade == nil then
		return
	end

	local iconPath = QResPath("mount_dress_star")[grade+1]
	if iconPath then
		local texture = CCTextureCache:sharedTextureCache():addImage(iconPath)
		self._ccbOwner.sp_dress_level:setTexture(texture)
		self._ccbOwner.node_dress:setVisible(true)
	end
end

function QUIWidgetGodarmBox:_onTriggerClick()
	local godarmId = nil
	if self._godarmInfo ~= nil then
		godarmtId = self._godarmInfo.zuoqiId
	end
	self:dispatchEvent({name = QUIWidgetGodarmBox.MOUNT_EVENT_CLICK, godarmId = godarmId})
end

function QUIWidgetGodarmBox:getContentSize()
end

return QUIWidgetGodarmBox
