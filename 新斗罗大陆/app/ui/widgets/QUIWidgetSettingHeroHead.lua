-- @Author: xurui
-- @Date:   2016-08-27 17:21:58
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-23 16:06:52
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetSettingHeroHead = class("QUIWidgetSettingHeroHead", QUIWidgetHeroHead)

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetSettingHeroHead:setInfo(params)
	self:getView():setScale(0.9)

	self._isTransform = params.isTransform or false
	if params.actorId then
		local heros = remote.herosUtil:getHeroByID(params.actorId) or {}
		self:setHeroSkinId(params.skinId)
		self:setHero(params.actorId, nil, params.index)
		self:setBreakthrough()
		self:setGodSkillShowLevel(0)
	end
	if params.addTitle ~= nil then
		self:setHeroHeadTitle(params.addTitle, params.actorId)
	end
	if self._selectPosition ~= nil and self._selectPosition ~= 0 then
		self:showSettingSelect(self._selectPosition == params.index)
	end

	if params.isSkin then
		local isActioveSkin = remote.heroSkin:checkSkinIsActivation(params.actorId, params.skinId)
		if not isActioveSkin then
			self._isGary = true
			makeNodeFromNormalToGray(self._ccbOwner.node_heroHead)	
		elseif self._isGary then
			self._isGary = false
			makeNodeFromGrayToNormal(self._ccbOwner.node_heroHead)		
		end
	else
		if params.isTransform then
			self._isGary = false
			makeNodeFromGrayToNormal(self._ccbOwner.node_heroHead)
		elseif remote.herosUtil:checkHeroHavePast(params.actorId) == false then
			self._isGary = true
			makeNodeFromNormalToGray(self._ccbOwner.node_heroHead)
		elseif self._isGary then
			self._isGary = false
			makeNodeFromGrayToNormal(self._ccbOwner.node_heroHead)
		end
	end

	if remote.user.defaultSkinId ~= nil and remote.user.defaultSkinId ~= 0 and params.skinId ~= 0 then
		self:showSettingUse(remote.user.defaultSkinId == params.skinId)
	elseif remote.user.defaultActorId ~= nil then
		self:showSettingUse(remote.user.defaultActorId == params.actorId)
	end	

end

function QUIWidgetSettingHeroHead:getIsTransform( )
	return self._isTransform
end
-- 添加title
function QUIWidgetSettingHeroHead:setHeroHeadTitle(state, actorId)
	if self._title ~= nil then
		self._title:removeFromParent()
		self._title = nil
	end
	if state == true then
		local ccbOwner = {}
	    self._title = CCBuilderReaderLoad("ccb/Widget_Rongyao_title.ccbi", CCBProxy:create(), ccbOwner)
	    local contentSize = self:getContentSize()
	    self._title:setPosition(ccp(contentSize.width+70, contentSize.height - 90))
		self:getView():addChild(self._title)

		local currentAptitude = db:getCharacterByID(actorId).aptitude
		for _, value in pairs(HERO_SABC) do
			if value.aptitude == currentAptitude then
	    		ccbOwner.tf_title_name:setString(value.qc.."级展示魂师")
			end
		end
	end
end

function QUIWidgetSettingHeroHead:setBreakthrough()
	if self._actorId == nil then return end
	self._ccbOwner.sp_break:setVisible(false)
	
	local aptitudeInfo = db:getActorSABC(self._actorId)
  	local breakLevel = aptitudeInfo.breakLevel or 1
  	local iconPath = QResPath("head_rect_frame")[breakLevel+1]
	if not iconPath then
		iconPath = QResPath("head_rect_frame_normal")
	end
	local texture = CCTextureCache:sharedTextureCache():addImage(iconPath)
	if texture then
		self._ccbOwner.sp_break:setVisible(true)
		self._ccbOwner.sp_break:setTexture(texture)
	end
end

function QUIWidgetSettingHeroHead:setSelectPosition(index)
	self._selectPosition = index
end

function QUIWidgetSettingHeroHead:getIndex()	
	return self._index
end

function QUIWidgetSettingHeroHead:getContentSize()	
	local contentSize = self._ccbOwner.sprite_back:getContentSize()	
	local height = contentSize.height + 70
	return CCSize(contentSize.width, height)
end

function QUIWidgetSettingHeroHead:showSettingSelect(state)
	self._ccbOwner.node_setting_select:setVisible(state)
end

function QUIWidgetSettingHeroHead:showSettingUse(state)
	self._ccbOwner.node_setting_use:setVisible(state)
end

return QUIWidgetSettingHeroHead