-- 战斗阶段未参与的玩家看到的界面, 该玩家有观战的资格，则可以进入战场观战

local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local CrossPVPTurnFlagLayer	= require("app.scenes.crosspvp.CrossPVPTurnFlagLayer")
local CrossPVPConst = require("app.const.CrossPVPConst")

local CrossPVPFightNotJoinLayer = class("CrossPVPFightNotJoinLayer", UFCCSNormalLayer)

function CrossPVPFightNotJoinLayer.create(...)
	return CrossPVPFightNotJoinLayer.new("ui_layout/crosspvp_CrossPVPFightNotJoinLayer.json", nil, ...)
end

function CrossPVPFightNotJoinLayer:ctor(json, param, ...)
	self._tItemList = nil

	self.super.ctor(self, json, param, ...)
end

function CrossPVPFightNotJoinLayer:onLayerLoad()
	self:_initView()
	self:_addSelectFields()
end

function CrossPVPFightNotJoinLayer:onLayerEnter()
	self:_initLayer()
	

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_OB_RIGHT_SUCC, self._onGetObRightSucc, self)
	
	-- 发送协议，看玩家是否有ob权限
	G_HandlersManager.crossPVPHandler:sendGetCrossPvpOb()
end

function CrossPVPFightNotJoinLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossPVPFightNotJoinLayer:adapterLayer()
	self:adapterWidgetHeight("Panel_Middle", "Panel_16", "", 0, 0)
end

function CrossPVPFightNotJoinLayer:_initView()
		-- 观战的条件描述
	local rankRequest = crosspvp_value_info.get(2).value
	local strTip = "(" .. G_lang:get("LANG_CROSS_PVP_WATCH_CONDITION", {rank = rankRequest}) .. ")"
	self:showTextWithLabel("Label_WatchTips3", strTip)

	CommonFunc._updateLabel(self, "Label_WatchTips1", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_WatchTips2", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_WatchTips3", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Title_Watch", {stroke=Colors.strokeBrown})

	self:showWidgetByName("Panel_CurField", false)
	self:showWidgetByName("Panel_CurScore", false)
	self:showWidgetByName("Panel_CurRank", false)
end

function CrossPVPFightNotJoinLayer:_initLayer()

	-- 比赛各阶段时间，通用组件
	local CrossPVPStageFlow = require("app.scenes.crosspvp.CrossPVPStageFlow")
	local stageLayer = CrossPVPStageFlow.create()
	local tParent = self:getImageViewByName("Image_Gray_Bg")
	if tParent and stageLayer then
		tParent:addNode(stageLayer)
		local tSize = tParent:getSize()
		stageLayer:setPositionX(stageLayer:getPositionX() + tSize.width/2)
		stageLayer:setPositionY(stageLayer:getPositionY() + tSize.height - 10)
	end
end

function CrossPVPFightNotJoinLayer:_addSelectFields()
	local panel = self:getPanelByName("Panel_Fields")
	local tLayer = CrossPVPTurnFlagLayer.create(panel, require("app.scenes.crosspvp.CrossPVPFieldItem"))
	self._tItemList = tLayer._items
end

function CrossPVPFightNotJoinLayer:_onGetObRightSucc(tData)
	if not tData then
		return
	end

	if self._tItemList then
		for i=1, CrossPVPConst.BATTLE_FIELD_NUM do
			local tItem = self._tItemList[i]
			if tItem and tItem.updateObButton then
				tItem:updateObButton(tData)
			end
		end
	end
end

return CrossPVPFightNotJoinLayer