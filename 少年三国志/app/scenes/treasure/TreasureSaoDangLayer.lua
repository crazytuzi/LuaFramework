local TreasureSaoDangLayer = class("TreasureSaoDangLayer",UFCCSNormalLayer)

local SaoDangItem = require("app.scenes.treasure.cell.TreasureSaoDangItem")
local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.treasure_compose_info")
require("app.cfg.treasure_fragment_info")
function TreasureSaoDangLayer.create(index,fragment_id,userList)
	local layer = TreasureSaoDangLayer.new("ui_layout/treasure_TreasureSaoDangLayer.json",index,fragment_id,userList)
	return layer
end


--[[
	index  抢夺的index
	fragment_id
	userList 抢夺列表的玩家list，用于回传
]]
function TreasureSaoDangLayer:ctor(_,index,fragment_id,userList)
	--是否扫荡结束
	self._saodangFinish = false

    self._upgradeList = {}
	self._listData = {}
	self.super.ctor(self)
	self._robResult = false
	self._index = index
	self._fragment_id = fragment_id
	self._composeId = nil   --用于传入夺宝界面定位
	local fragemt = treasure_fragment_info.get(self._fragment_id)
	if fragemt then
		self._composeId = fragemt.compose_id
	end

	self:registerBtnClickEvent("Button_finish",function()
		if not self._saodangFinish then
			--扫荡未结束
			return
		end
		
        self:_hitLevelup()
		if self._robResult then
			uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.treasure.TreasureComposeScene").new(nil,nil,self._composeId))
			
		else
			uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.treasure.TreasureRobScene").new(self._fragment_id,userList))
		end
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_TREASURE_FRAGMENT_SUCCESS, nil, false,self._fragment_id)
	end)

	self:registerBtnClickEvent("Button_Back", function()
		self:_hitLevelup()
		if self._robResult then
			uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.treasure.TreasureComposeScene").new(nil,nil,self._composeId))
			
		else
			uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.treasure.TreasureRobScene").new(self._fragment_id,userList))
		end
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ROB_TREASURE_FRAGMENT_SUCCESS, nil, false,self._fragment_id)
	end)

	self:attachImageTextForBtn("Button_finish","Image_39")
	self:getButtonByName("Button_finish"):setTouchEnabled(false)
end


function TreasureSaoDangLayer:_setListView()
	if self._listView == nil then
		local panel = self:getPanelByName("Panel_listview")
		self._listView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
		self._listView:setCreateCellHandler(function ()
	        return SaoDangItem.new()
	    end)
	    self._listView:setUpdateCellHandler(function ( list, index, cell)
	    	cell:updateSaoDangItem(self._listData[index+1])
	        end)
	    self._listView:setBouncedEnable(false)
	end
	self._listView:reloadWithLength(#self._listData,0)
end

function TreasureSaoDangLayer:onLayerEnter()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_SAO_DANG, self._onSaoDangResult, self)
     uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USER_LEVELUP, self._onReceiveLevelUpdate, self)
	self:adapterWidgetHeight("Panel_listview","Image_3","",0,100)
	self:_setListView()
	G_HandlersManager.treasureRobHandler:sendFastRob(self._index)
end

function TreasureSaoDangLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

function TreasureSaoDangLayer:_onSaoDangResult(data)
	if not data or data.ret ~= 1 then
		self._saodangFinish = true
		self:getButtonByName("Button_finish"):setTouchEnabled(true)

		return
	end
	self._saodangFinish = false
	if not self._listData then
		self._listData = {}
	end

	for i=1,data.battle_times do
		local t = {
			id = data.base_id,
			battle_times = i,
			break_reason = data.break_reason,
			rob_result = data.rob_result[i],
			turnover = data.turnover_rewards[i],
			awardList = data.rewards[i].rewards
		}
		self._robResult = data.rob_result[i]
		table.insert(self._listData,t)
	end
	if self._timerHandler == nil then
		self._index = 0
		self._timerHandler = G_GlobalFunc.addTimer(0.01, function()
			if self._index ~= nil then
				self._index = self._index + 1
			end
		   if self and self._listView and self._listData then
		   	self._listView:reloadWithLength(self._index,0)
		   	self._listView:scrollToTopLeftCellIndex(self._index,0, 0, function() end)
		   end
		   if self._index == #self._listData then
		   		--扫荡结束
		   		self._saodangFinish = true
		   		self:getButtonByName("Button_finish"):setTouchEnabled(true)
		   		GlobalFunc.removeTimer(self._timerHandler)
		   		self._timerHandler = nil
		   		if self._robResult then
		   			self.effectNode = EffectNode.new("effect_around2", function(event, frameIndex)
		   			        end)     
		   			self.effectNode:setScale(1.7) 
		   			self.effectNode:play()
		   			local pt = self.effectNode:getPositionInCCPoint()
		   			self.effectNode:setPosition(ccp(pt.x, pt.y))
		   			self:getWidgetByName("Button_finish"):addNode(self.effectNode)
		   		end
		   end
		end)
	end
	-- self._listView:reloadWithLength(#self._listData,0)
end

function TreasureSaoDangLayer:onLayerUnload()
	if self._timerHandler then
	    GlobalFunc.removeTimer(self._timerHandler)
	    self._timerHandler = nil
	end
end

function TreasureSaoDangLayer:_onReceiveLevelUpdate( oldLevel, newLevel )
    if type(oldLevel) ~= "number" or type(newLevel) ~= "number" then 
        return 
    end

    self._upgradeList = self._upgradeList or {}
    table.insert(self._upgradeList, 1, {level1 = oldLevel, level2 = newLevel})
end

function TreasureSaoDangLayer:_hitLevelup( ... )
    if not self._upgradeList or #self._upgradeList < 1 then 
        return 
    end


    local upgradePair = self._upgradeList[1]
    if type(upgradePair) == "table" then 
    	uf_funcCallHelper:callAfterFrameCount(2, function ( ... )
    		require("app.scenes.common.CommonLevelupLayer").show(upgradePair.level1, upgradePair.level2)
    		 uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FINISH_PLAY_FIGHTEND)
    	end)        
    end
    self._upgradeList = {}
end

return TreasureSaoDangLayer