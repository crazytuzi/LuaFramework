--[[
    文件名: ActivityInviteFriendLayer.lua
	描述: 好友邀请页面, 模块Id为：ModuleSub.eExtraActivityInviteFriend
	效果图: 
	创建人: liaoyuangang
	创建时间: 2016.6.2
--]]

local ActivityInviteFriendLayer = class("ActivityInviteFriendLayer", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id

		cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
	}
]]
function ActivityInviteFriendLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 初始化页面控件
	self:initUI()

	if not self.mLayerData then  -- 证明是第一次进入该页面
		-- Todo  requestServerData 
	end
end

-- 获取恢复数据
function ActivityInviteFriendLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityInviteFriendLayer:initUI()
	-- Todo
end

return ActivityInviteFriendLayer

