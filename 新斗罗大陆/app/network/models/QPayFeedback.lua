--
-- Author: Kumo
-- Date: 2015-01-14 11:50:04
-- 充值反馈
--
local QBaseModel = import("...models.QBaseModel")
local QPayFeedback = class("QPayFeedback",QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")

function QPayFeedback:ctor(options)
    QPayFeedback.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QPayFeedback:init()
end

function QPayFeedback:loginEnd()
    self.isPaying = false
end

function QPayFeedback:disappear()
end

return QPayFeedback