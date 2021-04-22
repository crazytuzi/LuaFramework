

local QBaseModel = import("..models.QBaseModel")
local QHeroArray = class("QHeroArray",QBaseModel)


function QHeroArray:ctor()
	QHeroArray.super.ctor(self)
	cc.GameObject.extend(self)

    self:addComponent("components.behavior.EventProtocol"):exportMethods()
 
end

function QHeroArray:loginEnd(  )

end

--创建时初始化事件
function QHeroArray:didappear()
	QHeroArray.super.didappear(self)
   
end

function QHeroArray:disappear()
	QHeroArray.super.disappear(self)
end




return QHeroArray