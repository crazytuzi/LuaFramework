--CommonLayerModel.lua


local CommonLayerModel = class ("CommonLayerModel", function (  )
	return CCNode:create()
end)


function CommonLayerModel:ctor( ... )
	self._notice = nil 
	self._mainRoleInfo = nil 
	self._barRoleInfo = nil 
	self._dungeonRoleInfo = nil
        self._dungeonKongRoleInfo = nil
	self._shopRoleInfo = nil
	self._speedBar = nil 
	self._storyDungeonRoleInfo = nil
	self._knightDevelopTop = nil
    self._delayUpdate = false    
	uf_notifyLayer:addNode(self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SCENE_CHANGED, self._onReceiveSceneChanged, self)
end

function CommonLayerModel:getDelayUpdate(  )
	return self._delayUpdate 
end

function CommonLayerModel:setDelayUpdate( b )
	
	self._delayUpdate = b
end

function CommonLayerModel:_onReceiveSceneChanged( )
	--非战斗场景会刷新这个值

	local name = G_SceneObserver:getSceneName()
	
	if string.find(name, "BattleScene") == nil then
		self:setDelayUpdate(false)
	end
end

function CommonLayerModel:onExit(  )
	if self._notice then
		self._notice:release()
		self._notice = nil 
	end
	if self._mainRoleInfo then
		self._mainRoleInfo:release()
		self._mainRoleInfo = nil 
	end
	if self._barRoleInfo then
		self._barRoleInfo:release()
		self._barRoleInfo = nil 
	end
	if self._dungeonRoleInfo then
		self._dungeonRoleInfo:release()
		self._dungeonRoleInfo = nil 
	end
        if self._dungeonKongRoleInfo then
		self._dungeonKongRoleInfo:release()
		self._dungeonKongRoleInfo = nil 
	end
        
    if self._storyDungeonRoleInfo then
		self._storyDungeonRoleInfo:release()
		self._storyDungeonRoleInfo = nil 
	end
        
	if self._shopRoleInfo then
		self._shopRoleInfo:release()
		self._shopRoleInfo = nil 
	end
	if self._speedBar then
		self._speedBar:release()
		self._speedBar = nil 
	end
        
    if self._knightDevelopTop then 
    	self._knightDevelopTop:release()
    	self._knightDevelopTop = nil
    end
    
end

function CommonLayerModel:getKnightDevelopTopLayer( ... )
	if self._knightDevelopTop == nil then
	    self._knightDevelopTop = require("app.scenes.herofoster.KnightTopLayer").create()
	    self._knightDevelopTop:retain()
	end

	if self._knightDevelopTop:getParent() ~= nil then
		self._knightDevelopTop:removeFromParentAndCleanup(true)
	end

	return self._knightDevelopTop
end

function CommonLayerModel:getNoticeLayer(  )
	if self._notice == nil then
	    self._notice = require("app.scenes.common.NoticeComponent").create()
	    self._notice:retain()
	end

	if self._notice:getParent() ~= nil then
		self._notice:removeFromParentAndCleanup(true)
	end

	self._notice:setPosition(ccp(0, 0))
	return self._notice
end

function CommonLayerModel:getMainRoleInfoLayer(  )
	if self._mainRoleInfo == nil then
		self._mainRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_MAIN)
	    self._mainRoleInfo:retain()
	end

	if self._mainRoleInfo:getParent() ~= nil then
		self._mainRoleInfo:removeFromParentAndCleanup(true)
	end

	self._mainRoleInfo:stopAllActions()
	self._mainRoleInfo:setPosition(ccp(0, 0))
	return self._mainRoleInfo
end

function CommonLayerModel:getBarRoleInfoLayer(  )
	if self._barRoleInfo == nil then
		self._barRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_TOWER)
	    self._barRoleInfo:retain()
	end

	if self._barRoleInfo:getParent() ~= nil then
		self._barRoleInfo:removeFromParentAndCleanup(true)
	end

	self._barRoleInfo:stopAllActions()
	self._barRoleInfo:setPosition(ccp(0, 0))
	return self._barRoleInfo
end

function CommonLayerModel:getTreasureRobRoleInfoLayer(  )
	if self._robRoleInfo == nil then
		__LogTag("wkj","--------G_TopBarConst.TOPBAR_TREASURE_ROB = %s",G_TopBarConst.TOPBAR_TREASURE_ROB)
		self._robRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_TREASURE_ROB)
	    self._robRoleInfo:retain()
	end

	if self._robRoleInfo:getParent() ~= nil then
		self._robRoleInfo:removeFromParentAndCleanup(true)
	end

	self._robRoleInfo:stopAllActions()
	self._robRoleInfo:setPosition(ccp(0, 0))
	return self._robRoleInfo
end

function CommonLayerModel:getStrengthenRoleInfoLayer(  )
	if self._strengthenRoleInfo == nil then
		self._strengthenRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_STRENGTHEN)
	    self._strengthenRoleInfo:retain()
	end

	if self._strengthenRoleInfo:getParent() ~= nil then
		self._strengthenRoleInfo:removeFromParentAndCleanup(true)
	end

	self._strengthenRoleInfo:stopAllActions()
	self._strengthenRoleInfo:setPosition(ccp(0, 0))
	return self._strengthenRoleInfo
end


function CommonLayerModel:getShopRoleInfoLayer(  )
	if self._shopRoleInfo == nil then
		self._shopRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_SHOP)
	    self._shopRoleInfo:retain()
	end

	if self._shopRoleInfo:getParent() ~= nil then
		self._shopRoleInfo:removeFromParentAndCleanup(true)
	end

	self._shopRoleInfo:stopAllActions()
	self._shopRoleInfo:setPosition(ccp(0, 0))
	return self._shopRoleInfo
end

function CommonLayerModel:getFriendRoleInfoLayer(  )
	if self._friendRoleInfo == nil then
		self._friendRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_FRIEND)
	    self._friendRoleInfo:retain()
	end

	if self._friendRoleInfo:getParent() ~= nil then
		self._friendRoleInfo:removeFromParentAndCleanup(true)
	end

	self._friendRoleInfo:stopAllActions()
	self._friendRoleInfo:setPosition(ccp(0, 0))
	return self._friendRoleInfo
end

function CommonLayerModel:getLegionRoleInfoLayer(  )
	if self._legionRoleInfo == nil then
		self._legionRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_LEGION)
	    self._legionRoleInfo:retain()
	end

	if self._legionRoleInfo:getParent() ~= nil then
		self._legionRoleInfo:removeFromParentAndCleanup(true)
	end

	self._legionRoleInfo:stopAllActions()
	self._legionRoleInfo:setPosition(ccp(0, 0))
	return self._legionRoleInfo
end

function CommonLayerModel:getDungeonRoleInfoLayer(  )
	if self._dungeonRoleInfo == nil then
		self._dungeonRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_DUNGEON)
	    self._dungeonRoleInfo:retain()
	end

	if self._dungeonRoleInfo:getParent() ~= nil then
		self._dungeonRoleInfo:removeFromParentAndCleanup(true)
	end

	self._dungeonRoleInfo:stopAllActions()
	self._dungeonRoleInfo:setPosition(ccp(0, 0))
	return self._dungeonRoleInfo
end

function CommonLayerModel:getDungeonRoleKongInfoLayer(  )
	if self._dungeonKongRoleInfo == nil then
		self._dungeonKongRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_DUNGEON_KONG)
	    self._dungeonKongRoleInfo:retain()
	end

	if self._dungeonKongRoleInfo:getParent() ~= nil then
		self._dungeonKongRoleInfo:removeFromParentAndCleanup(true)
	end

	self._dungeonKongRoleInfo:stopAllActions()
	self._dungeonKongRoleInfo:setPosition(ccp(0, 0))
	return self._dungeonKongRoleInfo
end

function CommonLayerModel:getStoryDungeonRoleInfoLayer(  )
	if self._storyDungeonRoleInfo == nil then
		self._storyDungeonRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_STORYDUNGEON)
	    self._storyDungeonRoleInfo:retain()
	end

	if self._storyDungeonRoleInfo:getParent() ~= nil then
		self._storyDungeonRoleInfo:removeFromParentAndCleanup(true)
	end

	self._storyDungeonRoleInfo:stopAllActions()
	self._storyDungeonRoleInfo:setPosition(ccp(0, 0))
	return self._storyDungeonRoleInfo
end

function CommonLayerModel:getBagRoleInfoLayer(  )
	if self._bagRoleInfo == nil then
		self._bagRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_BAG)
	    self._bagRoleInfo:retain()
	end

	if self._bagRoleInfo:getParent() ~= nil then
		self._bagRoleInfo:removeFromParentAndCleanup(true)
	end

	self._bagRoleInfo:stopAllActions()
	self._bagRoleInfo:setPosition(ccp(0, 0))
	return self._bagRoleInfo
end

function CommonLayerModel:getSpeedbarLayer(  )
	if self._speedBar == nil then
		self._speedBar = require("app.scenes.common.SpeedBarComponent").create()
	    self._speedBar:retain()
	end

	if self._speedBar:getParent() ~= nil then
		self._speedBar:removeFromParentAndCleanup(true)
	end

	self._speedBar:stopAllActions()
	self._speedBar:setPosition(ccp(0, 0))
	return self._speedBar
end

function CommonLayerModel:getExDungeonRoleInfoLayer(  )
	if self._exDungeonRoleInfo == nil then
		self._exDungeonRoleInfo = require("app.scenes.common.RoleInfoUIComponent").create(G_TopBarConst.TOPBAR_EX_DUNGEON)
	    self._exDungeonRoleInfo:retain()
	end

	if self._exDungeonRoleInfo:getParent() ~= nil then
		self._exDungeonRoleInfo:removeFromParentAndCleanup(true)
	end

	self._exDungeonRoleInfo:stopAllActions()
	self._exDungeonRoleInfo:setPosition(ccp(0, 0))
	return self._exDungeonRoleInfo
end


return CommonLayerModel
