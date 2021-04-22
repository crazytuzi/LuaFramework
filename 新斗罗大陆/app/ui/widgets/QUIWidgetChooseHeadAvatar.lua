-- @Author: xurui
-- @Last Modified by:   xurui
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetChooseHeadAvatar = class("QUIWidgetChooseHeadAvatar", QUIWidgetAvatar)

function QUIWidgetChooseHeadAvatar:setInfo(params)
	local avatarConfig
	local avatar
	if params.avatarConfig then
		avatarConfig = params.avatarConfig
		avatar = avatarConfig.id or -1
		avatar = tonumber(avatar) or -1
		self._avatarId, self._frameId = remote.headProp:getAvatarFrameId(avatar)

		self:updateFrameBg()
		self:updateFrameBottom(self._frameId)
		self:updateAvatar(self._avatarId)
		self:updateFrame(self._frameId)
		self:showLock(avatarConfig.lock)

		self._ccbOwner.tf_frame_name:setVisible(true)
		self._ccbOwner.tf_frame_name:setString(avatarConfig.desc or "")
	end
	self._ccbOwner.node_normalAvatar:setVisible(params.avatarConfig ~= nil)

	if params.addTitle ~= nil then
		self:setFrameTitle(params.addTitle, params.avatarConfig)
	end

	self._index = params.index
	if self._selectPosition ~= nil and self._selectPosition ~= 0 then
		self:showSettingSelect(self._selectPosition == params.index)
	end

	local avatarId, frameId = remote.headProp:getAvatarFrameId(remote.user.avatar)
	if avatarId ~= nil then
		local curId = avatarId == -1 and 74 or avatarId
		self:showSettingUse(curId == avatar)
	end
end

-- 添加title
function QUIWidgetChooseHeadAvatar:setFrameTitle(state, framesInfo)
	if self._title ~= nil then
		self._title:removeFromParent()
		self._title = nil
	end
	if state == true then
		local ccbOwner = {}
	    self._title = CCBuilderReaderLoad("ccb/Widget_Rongyao_title.ccbi", CCBProxy:create(), ccbOwner)
	    local contentSize = self:getContentSize()
	    self._title:setPosition(ccp(160, 97))
		self:getView():addChild(self._title)
		ccbOwner.tf_title_desc:setVisible(false)
		ccbOwner.tf_no:setVisible(false)

		local word = "基础头像"
		if framesInfo.function_type == remote.headProp.AVATAR_DEFAULT_TYPE then
    		word = "基础头像"
		elseif framesInfo.function_type == remote.headProp.AVATAR_HERO_TYPE then
    		word = "魂师头像"
		elseif framesInfo.function_type == remote.headProp.AVATAR_OTHER_TYPE then
			word = "其他头像"
		elseif framesInfo.function_type == remote.headProp.AVATAR_ACTIVITY_TYPE then
			word = "活动头像"
		elseif framesInfo.function_type == remote.headProp.AVATAR_HEORSKIN_TYPE then
			word = "皮肤头像"
		end
		ccbOwner.tf_title_name:setString(word or "")
	end
end

function QUIWidgetChooseHeadAvatar:setSelectPosition(index)
	self._selectPosition = index
end

function QUIWidgetChooseHeadAvatar:getIndex()	
	return self._index
end

function QUIWidgetChooseHeadAvatar:showSettingSelect(state)
	self._ccbOwner.node_setting_select:setVisible(state)
end

function QUIWidgetChooseHeadAvatar:showSettingUse(state)
	self._ccbOwner.node_setting_use:setVisible(state)
end

return QUIWidgetChooseHeadAvatar