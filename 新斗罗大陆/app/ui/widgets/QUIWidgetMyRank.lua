--
-- Author: Qinyuanji
-- Date: 2014-11-20
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMyRank = class("QUIWidgetMyRank", QUIWidget)
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")
local QUnionAvatar = import("...utils.QUnionAvatar")

QUIWidgetMyRank.GAP = 20

function QUIWidgetMyRank:ctor(options)
	local ccbFile = "ccb/Widget_ArenaRank_client1.ccbi"
	local callBacks = {
	}
	QUIWidgetMyRank.super.ctor(self, ccbFile, callBacks, options)

	if options ~= nil then
		self:setInfo(options)
	end

	self._name1PosX = self._ccbOwner.nickName1:getPositionX()
end

-- 2 means two bar, 1 means one bar
function QUIWidgetMyRank:setFlag(flag)
	self._switch = flag
	-- self._ccbOwner.twoBar:setVisible(flag == 2 or flag == 3)
	-- self._ccbOwner.oneBar:setVisible(flag == 1)
end

function QUIWidgetMyRank:setInfo(options)
	self:hideAllElements()

	self._nightmarePassCount = options.myInfo.serverInfo.nightmareDungeonPassCount or 0
    local config = QStaticDatabase:sharedDatabase():getBadgeByCount(tonumber(self._nightmarePassCount))
    local badge = nil
    if config then
    	badge = CCTextureCache:sharedTextureCache():addImage(config.alphaicon)
    end

	self._ccbOwner.node_headPicture:removeAllChildren()
	-- unionAvatar is to indicate if this bar is for union avatar or user avatar
	if not options.myInfo.unionAvatar then
		local head = QUIWidgetAvatar.new(options.myInfo.avatar or remote.user.avatar)
		avatar:setSilvesArenaPeak(remote.user.championCount)
		self._ccbOwner.node_headPicture:addChild(head)
	else
		self._ccbOwner.node_headPicture:addChild(QUnionAvatar.new(options.myInfo.avatar))
	end
	if options.myInfo.rank then
		self._ccbOwner.myRank:setString(options.myInfo.rank)
		self._ccbOwner.myRank:setVisible(true) 
	else
		self._ccbOwner.NA:setVisible(true)
	end

	self._ccbOwner.threeBar:setVisible(false)
	self._ccbOwner.oneBar:setVisible(false)
	self._ccbOwner.twoBar:setVisible(false)
	if self._switch == 1 then
		self._ccbOwner.oneBar:setVisible(true)
		self._ccbOwner.level1:setString("LV." .. (options.myInfo.level or remote.user.level))
		self._ccbOwner.nickName1:setString(options.myInfo.name or remote.user.nickname)
		self._ccbOwner.badge1:removeAllChildren()
		if badge then
			if not string.find(self._description or "", "宗门等级") then
	        	self._ccbOwner.badge1:addChild(CCSprite:createWithTexture(badge))
				-- self._ccbOwner.nickName1:setPositionX(self._name1PosX)
	   --      else
    --     		self._ccbOwner.nickName1:setPositionX(self._name1PosX - 35)
	        end
		-- else
  --       	self._ccbOwner.nickName1:setPositionX(self._name1PosX - 30)
		end
	elseif self._switch == 4 then
		self._ccbOwner.threeBar:setVisible(true)
		self._ccbOwner.level3:setString("LV." .. (options.myInfo.level or 1))
		self._ccbOwner.nickName3:setString(options.myInfo.name or "")

		local value1 = options.myInfo.serverInfo.max_chapter
		local value2 = options.myInfo.serverInfo.max_chapter_progress or 0
		self._ccbOwner.name1:setString(options.myInfo.description or "")
		self._ccbOwner.value1:setString("第"..(value1 or 1).."章")
		self._ccbOwner.value1:setPositionX(10)
		self._ccbOwner.name2:setString("章节进度:")
		self._ccbOwner.value2:setString(value2.."%")
	elseif self._switch == 5 then
		self._ccbOwner.threeBar:setVisible(true)
		self._ccbOwner.level3:setString("LV." .. (options.myInfo.level or 1))
		self._ccbOwner.nickName3:setString(options.myInfo.name or "")

		local value1 = options.myInfo.serverInfo.consortiaBossTopDamage or 0
		local value2 = options.myInfo.serverInfo.consortiaBossFightCount or 0
		self._ccbOwner.name1:setString(options.myInfo.description or "")
		local num, word = q.convertLargerNumber(value1)
		self._ccbOwner.value1:setString(num..(word or ""))
		self._ccbOwner.value1:setPositionX(55)
		self._ccbOwner.name2:setString("攻击次数:")
		self._ccbOwner.value2:setString(value2)
		self._ccbOwner.name2:setPositionX(150)
		self._ccbOwner.value2:setPositionX(255)
		self._ccbOwner.badge3:removeAllChildren()
		if badge then
        	self._ccbOwner.badge3:addChild(CCSprite:createWithTexture(badge)) 
			-- self._ccbOwner.nickName3:setPositionX(self._name1PosX)      	
   --      else
   --      	self._ccbOwner.nickName3:setPositionX(self._name1PosX - 30)
        end
  --   elseif self._switch == 12 then
  --   	self._ccbOwner.num2:setString(options.myInfo.serverInfo.consortiaScore or "")
		-- self._ccbOwner.twoBar:setVisible(true)
		-- self._ccbOwner.star:setVisible(false)
		-- self._ccbOwner.level2:setString("LV." .. (options.myInfo.level or remote.user.level))
		-- self._ccbOwner.nickName2:setString(options.myInfo.name or remote.user.nickname)
		-- self._ccbOwner.description2:setString(options.myInfo.description or "")

	else
		self._ccbOwner.twoBar:setVisible(true)
		self._ccbOwner.star:setVisible(options.myInfo.showStar)
		self._ccbOwner.level2:setString("LV." .. (options.myInfo.level or remote.user.level))
		self._ccbOwner.nickName2:setString(options.myInfo.name or remote.user.nickname)
		self._ccbOwner.description2:setString(options.myInfo.description or "")
		if self._switch == 3 then
			
			if not options.myInfo.number or options.myInfo.number == 0 then
				self._ccbOwner.num2:setString("尚未通关关卡")
			else
				local waveInfo = remote.sunWar:getWaveInfoByWaveID( options.myInfo.number or 1, false) or {}
				local mapInfo = remote.sunWar:getMapInfoByMapID(waveInfo.chapter or 0) or {}
				self._ccbOwner.num2:setString(string.format("%s%d-%d",mapInfo.name or "尚未通关关卡", waveInfo.chapter or 0, waveInfo.index or 0))
			end
		elseif self._switch == 9 then
			local serverName = ""
			if remote.selectServerInfo then
           		serverName = remote.selectServerInfo.name
        	end
			self._ccbOwner.num2:setString(options.myInfo.number or serverName)
		elseif self._switch == 12 then
    		self._ccbOwner.num2:setString(options.myInfo.serverInfo.consortiaScore or "")
			self._ccbOwner.node_dragon_war:setVisible(true)

			local floor = options.myInfo.serverInfo.consortiaFloor
			local dragonId = options.myInfo.serverInfo.dragonId
			
			local floorIcon = QUIWidgetFloorIcon.new({isLarge = true})
			floorIcon:setInfo(floor, "unionDragonWar")
			self._ccbOwner.node_floor:removeAllChildren()
			self._ccbOwner.node_floor:setScale(0.33)
			self._ccbOwner.node_floor:addChild(floorIcon)

			local floorInfo = db:getUnionDragonConfigById(dragonId)
			self._ccbOwner.tf_floor_name:setString(floorInfo.name or "")
		elseif self._switch == 13 then
			local count = options.myInfo.serverInfo.sparFieldTotalStarCount
			local starConfig = QStaticDatabase:sharedDatabase():getSparFieldLevelByStarCount(count)
			if starConfig == nil then 
				starConfig = {}
			end
			self._ccbOwner.star:setVisible(true)
			self._ccbOwner.num2:setString((starConfig.lev or 0).."  ("..count.." ")
			self._ccbOwner.num2:setPositionX(self._ccbOwner.description2:getContentSize().width + self._ccbOwner.description2:getPositionX() )
			self._ccbOwner.star:setPositionX(self._ccbOwner.num2:getContentSize().width + self._ccbOwner.num2:getPositionX() + 7)
			self._ccbOwner.star:setPositionY(-31)
			self._ccbOwner.num2:setString((starConfig.lev or 0).."  ("..count.."     )")
		else
			self._ccbOwner.num2:setString(options.myInfo.number or 0)
		end
		
		if self._switch ~= 13 then
			local offset = self._ccbOwner.description2:getPositionX() + self._ccbOwner.description2:getContentSize().width
			if options.myInfo.showStar then
				self._ccbOwner.star:setPositionX(offset + QUIWidgetMyRank.GAP)
				offset = offset + self._ccbOwner.star:getContentSize().width
			end
			self._ccbOwner.num2:setPositionX(offset + QUIWidgetMyRank.GAP)
		end

		self._ccbOwner.badge2:removeAllChildren()
		if badge then
        	self._ccbOwner.badge2:addChild(CCSprite:createWithTexture(badge))
			-- self._ccbOwner.nickName2:setPositionX(self._name1PosX)
   --      else
   --      	self._ccbOwner.nickName2:setPositionX(self._name1PosX - 30)
        end
	end

	local rankChanged = 0
	if options.myInfo.lastRank and options.myInfo.rank then rankChanged = options.myInfo.lastRank - options.myInfo.rank end
	self._ccbOwner.yesterday:setVisible(rankChanged ~= 0)
	if rankChanged > 0 then
		self._ccbOwner.green_flag:setVisible(true)
		self._ccbOwner.green_rankChanged:setVisible(true)
		self._ccbOwner.green_rankChanged:setString(tostring(math.abs(rankChanged)))
	elseif rankChanged < 0 then
		self._ccbOwner.red_flag:setVisible(true)
		self._ccbOwner.red_rankChanged:setVisible(true)
		self._ccbOwner.red_rankChanged:setString(tostring(math.abs(rankChanged)))
	else
		self._ccbOwner.myInfo:setPositionX(-35)
	end
end

function QUIWidgetMyRank:hideAllElements()
	self._ccbOwner.green_flag:setVisible(false)
	self._ccbOwner.red_flag:setVisible(false)
	self._ccbOwner.green_rankChanged:setVisible(false)
	self._ccbOwner.red_rankChanged:setVisible(false)
	self._ccbOwner.yesterday:setVisible(false)
	self._ccbOwner.myRank:setVisible(false)
	self._ccbOwner.NA:setVisible(false)
	self._ccbOwner.node_dragon_war:setVisible(false)
end

function QUIWidgetMyRank:getContentHeight()
	return self._contentHeight
end

return QUIWidgetMyRank