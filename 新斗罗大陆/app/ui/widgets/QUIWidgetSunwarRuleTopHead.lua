--[[	
	文件名称：QUIWidgetSunwarRuleTopHead.lua
	创建时间：2016-03-12 16:30:11
	作者：nieming
	描述：QUIWidgetSunwarRuleTopHead
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSunwarRuleTopHead = class("QUIWidgetSunwarRuleTopHead", QUIWidget)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

--初始化
function QUIWidgetSunwarRuleTopHead:ctor(options)
	local ccbFile = "Widget_SunWar_Rule_1.ccbi"
	local callBacks = {
	}
	QUIWidgetSunwarRuleTopHead.super.ctor(self,ccbFile,callBacks,options)
	--代码
end

--describe：onEnter 
--function QUIWidgetSunwarRuleTopHead:onEnter()
	----代码
--end

--describe：onExit 
--function QUIWidgetSunwarRuleTopHead:onExit()
	----代码
--end

--describe：setInfo 

function QUIWidgetSunwarRuleTopHead:setInfo(info)
	--代码
	local mid = remote.sunWar:getMapIDWithLastWaveID() or 0
    local waveID = remote.sunWar:getLastPassedWave()
    if not waveID or waveID == 0 then
        waveID = remote.sunWar:getCurrentWaveID()
    end
    local waveInfo = remote.sunWar:getWaveInfoByWaveID( waveID )
    
    if mid < 1 then
        -- self._ccbOwner.curNotHaveAwards:setVisible(true)
        -- self._ccbOwner.curHaveAwards:setVisible(false)
        self._ccbOwner.tf_level:setString("尚无通关记录")
        -- self._ccbOwner.tf_name:setString("")
    else
        -- self._ccbOwner.curNotHaveAwards:setVisible(false)
        -- self._ccbOwner.curHaveAwards:setVisible(true)
        -- printTable(mapInfo)
        if waveInfo and waveInfo.index then
            self._ccbOwner.tf_level:setString(mid.."-"..waveInfo.index)
        else
            self._ccbOwner.tf_level:setString("")
        end
        
        -- self._ccbOwner.tf_name:setString(mapInfo.name)
        
        -- local i = 1
        -- while(true) do
        --     if mapInfo["reward_type_"..i] then
        --         self._ccbOwner["node_item_"..i]:removeAllChildren()
        --         self._ccbOwner["node_item_"..i]:addChild(self:_getIcon(mapInfo["reward_type_"..i], mapInfo["item_id_"..i]))
        --         self._ccbOwner["node_item_"..i]:setVisible(true)
        --         self._ccbOwner["tf_num_"..i]:setString(mapInfo["reward_num_"..i])
        --         self._ccbOwner["tf_num_"..i]:setVisible(true)
        --         i = i + 1
        --     else
        --         break
        --     end
        -- end
    end
	
end

-- function QUIWidgetSunwarRuleTopHead:_getIcon( type, id )
--     local info = remote.items:getWalletByType(type)
--     local node = nil
--     if info ~= nil and info.alphaIcon ~= nil then
--         local texture = CCTextureCache:sharedTextureCache():addImage(info.alphaIcon)
--         node = CCSprite:createWithTexture( texture )
--     else
--         node = QUIWidgetItemsBox.new({ccb = "small"})
--         node:setGoodsInfo(id, type, 0)
--         node:setScale(0.7)
--         -- local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(id)
--         -- if itemInfo == nil then return sprite end
--         -- local texture = CCTextureCache:sharedTextureCache():addImage(itemInfo.icon)
--         -- sprite = CCSprite:createWithTexture( texture )
--     end

--     return node
-- end

function QUIWidgetSunwarRuleTopHead:getContentSize()
	return self._ccbOwner.node_bg:getContentSize()
end

--describe：getContentSize 
--function QUIWidgetSunwarRuleTopHead:getContentSize()
	----代码
--end

return QUIWidgetSunwarRuleTopHead
