-- @Author: liaoxianbo
-- @Date:   2020-07-15 18:00:32
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-18 18:11:31

local QBaseModel = import("...models.QBaseModel")
local QShareSDK = class("QShareSDK", QBaseModel)
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QShareSDK.HERO = 1		--魂师
QShareSDK.SKIN = 2		--皮肤
QShareSDK.SKINTIRED = 3	--皮肤会倦
QShareSDK.COLLECT = 4	--成就收藏册

function QShareSDK:ctor(options)
    QShareSDK.super.ctor(self)
end

function QShareSDK:didappear()
	self:initData()
end

function QShareSDK:disappear()
	self:initData()
end

function QShareSDK:loginEnd()
end

function QShareSDK:initData( )
	self._allShareConfig = {}
end

function QShareSDK:checkIsOpen()
    return app:isNativeLargerEqualThan(1, 6, 1) and FinalSDK.showShare()
end

function QShareSDK:getShareConfigById(id,shareType)
	if q.isEmpty(self._allShareConfig) then
		local allShareConfig = db:getStaticByName("share")
		for _,v in pairs(allShareConfig) do
			table.insert(self._allShareConfig,v)
		end
	end

	for _,v in pairs(self._allShareConfig) do
		if v.type == shareType and v.conditions == id then
			return v
		end
	end

	return nil
end

function QShareSDK:getShareInfoById(id)
    if q.isEmpty(self._allShareConfig) then
        local allShareConfig = db:getStaticByName("share")
        for _,v in pairs(allShareConfig) do
            table.insert(self._allShareConfig,v)
        end
    end
    
    for _,v in pairs(self._allShareConfig) do
        if v.id == id then
            return v
        end
    end

    return nil
end
--[[
    截屏
    @param node 需要截屏的父节点
    @param imageName ,图片的保存名称
]]
function QShareSDK:screenShot(node, imageName)
    if node == nil then return end

    local oldPosition = ccp(node:getPosition())
    --the layer is just for excute autorender
    local layer = CCLayer:create()
    if layer.setNodeIsAutoBatchNode then
    	layer:setNodeIsAutoBatchNode(false)
    end
    node:addChild(layer)
    node:setPositionX(display.cx)
    node:setPositionY(display.cy)

    local render = CCRenderTexture:create(display.width, display.height)
    render:begin()
    node:visit()
    render:endToLua()

    layer:removeFromParent()


    render:saveToFile(imageName, kFmtJpg)
    render:onExit()

    node:setPositionX(oldPosition.x)
    node:setPositionY(oldPosition.y)
end

function QShareSDK:shareToSDK(success,fail )
    local request = {api = "SHARE_PICTURE"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        remote.user:addPropNumForKey("todayShareCount")
    end)
end

return QShareSDK