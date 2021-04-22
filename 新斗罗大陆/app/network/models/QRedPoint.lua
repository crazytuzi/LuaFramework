--
-- Author: Kumo.Wang
-- Date: Sat Mar  5 18:30:36 2016
-- 小红点数据管理

local QBaseModel = import("...models.QBaseModel")
local QRedPoint = class("QRedPoint",QBaseModel)

function QRedPoint:ctor()
	QRedPoint.super.ctor(self)

end

function QRedPoint:init()
	self.isShowGlyphRedPoint = true
	self.isShowRefineRedPoint = true
end

function QRedPoint:disappear()

end

function QRedPoint:loginEnd()

end


return QRedPoint
