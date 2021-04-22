-- @Author: zhouxiaoshu
-- @Date:   2019-04-26 15:43:53
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-05 14:18:08
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogConsortiaWarBuff = class("QUIDialogConsortiaWarBuff", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogConsortiaWarBuff:ctor(options)
	local ccbFile = "ccb/Dialog_UnionWar_addition.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogConsortiaWarBuff.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.btn_close)
	self._ccbOwner.frame_tf_title:setString("摧毁战旗")
	self:updateInfo()
end

function QUIDialogConsortiaWarBuff:viewDidAppear()
	QUIDialogConsortiaWarBuff.super.viewDidAppear(self)

end

function QUIDialogConsortiaWarBuff:viewWillDisappear()
  	QUIDialogConsortiaWarBuff.super.viewWillDisappear(self)

end

function QUIDialogConsortiaWarBuff:updateInfo()
	for hallId = 1, 4 do
		local hallConfig = remote.consortiaWar:getHallConfigByHallId(hallId)
		local str = string.format("已攻破敌方%s，%s", hallConfig.name, hallConfig.prop_name or "")
		local richText = QRichText.new({}, 430)
		richText:setAnchorPoint(ccp(0, 1))
	    self._ccbOwner["node_content"..hallId]:addChild(richText)

		local hallInfo = remote.consortiaWar:getEnemyHallInfoByHallId(hallId)
		if hallInfo.isBreakThrough then
			richText:setString({
		        {oType = "font", content = "（已激活）", size = 20, color = GAME_COLOR_LIGHT.property},
				{oType = "font", content = str, size = 20, color = GAME_COLOR_LIGHT.stress},
		    })
		else
			richText:setString({
		        {oType = "font", content = "（未激活）", size = 20, color = GAME_COLOR_LIGHT.normal},
				{oType = "font", content = str, size = 20, color = GAME_COLOR_LIGHT.normal},
		    })
		end
	end
end

function QUIDialogConsortiaWarBuff:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogConsortiaWarBuff:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogConsortiaWarBuff
