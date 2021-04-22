-- @Author: xurui
-- @Date:   2016-08-30 11:28:19
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-20 11:54:58
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetChooseFramsAvatar = class("QUIWidgetChooseFramsAvatar", QUIWidgetAvatar)

function QUIWidgetChooseFramsAvatar:setInfo(params)
	self:getView():setScale(0.9)

	local avatarConfig = params.avatarConfig
	local avatar = avatarConfig.id or -1
	if params.avatarConfig then
		avatar = tonumber(avatar) or -1
		self._avatarId, self._frameId = remote.headProp:getAvatarFrameId(avatar)

		self:updateFrameBg()
		self:updateFrameBottom(self._frameId)
		self:updateAvatar(self._avatarId)
		self:updateFrame(self._frameId)
		self:showLock(avatarConfig.lock)
	end
	if params.addTitle ~= nil then
		self:setFrameTitle(params.addTitle, params.avatarConfig)
	end

	self._index = params.index
	if self._selectPosition ~= nil and self._selectPosition ~= 0 then
		self:showSettingSelect(self._selectPosition == params.index)
	end

	local avatarId, frameId = remote.headProp:getAvatarFrameId(remote.user.avatar)
	if frameId == nil or frameId == 0 then
		frameId = remote.headProp:getDefaultFrame().id
	end
	if frameId ~= nil then
		self:showSettingUse(frameId == avatar)
	end
	--self._ccbOwner.tf_frame_name:setVisible(true)
	--self._ccbOwner.tf_frame_name:setString(avatarConfig.desc or "")
end

-- 添加title
function QUIWidgetChooseFramsAvatar:setFrameTitle(state, framesInfo)
	if self._title ~= nil then
		self._title:removeFromParent()
		self._title = nil
	end
	if state == true then
		local ccbOwner = {}
	    self._title = CCBuilderReaderLoad("ccb/Widget_Rongyao_title.ccbi", CCBProxy:create(), ccbOwner)
	    local contentSize = self:getContentSize()
	    self._title:setPosition(ccp(contentSize.width+40, contentSize.height - 60))
		self:getView():addChild(self._title)

		local word = "普通头像框"
		if framesInfo.function_type == remote.headProp.FRAME_VIP_TYPE then
    		word = "VIP头像框"
		elseif framesInfo.function_type == remote.headProp.FRAME_ARENA_TYPE then
    		word = "斗魂场头像框"
		elseif framesInfo.function_type == remote.headProp.FRAME_GLORY_TYPE then
    		word = "大魂师赛头像框"
		elseif framesInfo.function_type == remote.headProp.FRAME_FIGHT_TYPE then
    		word = "地狱杀戮场头像框"
    	elseif framesInfo.function_type == remote.headProp.FRAME_ACTIVITY_TYPE then
    		word = "活动头像框"
    	elseif framesInfo.function_type == remote.headProp.FRAME_STORM_TYPE then
    		word = "索托斗魂场头像框"
    	elseif framesInfo.function_type == remote.headProp.FRAME_SANCTUARY_TYPE then
    		word = "全大陆精英赛头像框"
    	elseif framesInfo.function_type == remote.headProp.FRAME_SOTO_TEAM_TYPE then
    		word = "云顶之战头像框"
    	elseif framesInfo.function_type == remote.headProp.FRAME_COLLEGETRAIN_TYPE then
    		word = "史莱克学院头像框"
    	elseif framesInfo.function_type == remote.headProp.FRAME_SILVESARENA_PEAK_TYPE then
    		word = "西尔维斯巅峰赛头像框"
		end

		ccbOwner.tf_title_name:setString(word or "")
	end
end

function QUIWidgetChooseFramsAvatar:setSelectPosition(index)
	self._selectPosition = index
end

function QUIWidgetChooseFramsAvatar:getIndex()	
	return self._index
end

function QUIWidgetChooseFramsAvatar:showSettingSelect(state)
	self._ccbOwner.is_select:setVisible(state)
end

function QUIWidgetChooseFramsAvatar:showSettingUse(state)
	self._ccbOwner.node_setting_use:setVisible(state)
end

return QUIWidgetChooseFramsAvatar