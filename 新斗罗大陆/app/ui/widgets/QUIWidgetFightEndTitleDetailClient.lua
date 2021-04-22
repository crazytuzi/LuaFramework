--
-- zxs
-- 比分
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFightEndTitleDetailClient = class("QUIWidgetFightEndTitleDetailClient", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetFightEndTitleDetailClient:ctor(options)
	local ccbFile = "ccb/Widget_TopRecord_score.ccbi"
	local callBack = {
	}
	QUIWidgetFightEndTitleDetailClient.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetFightEndTitleDetailClient:setInfo(info)
    self._ccbOwner.sp_score1:setDisplayFrame(QSpriteFrameByKey("zhanbao_score", info.attackScore + 1))
    self._ccbOwner.sp_score2:setDisplayFrame(QSpriteFrameByKey("zhanbao_score", info.defenseScore + 1))
    self._ccbOwner.node_head1:removeAllChildren()
    self._ccbOwner.node_head2:removeAllChildren()

    local head1 = QUIWidgetAvatar.new(info.avatar1)
    local head2 = QUIWidgetAvatar.new(info.avatar2)
    self._ccbOwner.node_head1:addChild(head1)
    self._ccbOwner.node_head2:addChild(head2)
    head2:setScaleX(-1)


    self._ccbOwner.tf_name1:setString(info.name1)
    self._ccbOwner.tf_name2:setString(info.name2)
end

function QUIWidgetFightEndTitleDetailClient:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return size
end

return QUIWidgetFightEndTitleDetailClient

