
local RebelBossChooseGroupLayer = class("RebelBossChooseGroupLayer", UFCCSModelLayer)


local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local CrossWarMessageBox = require("app.scenes.crosswar.CrossWarMessageBox")

function RebelBossChooseGroupLayer.create(...)
	return RebelBossChooseGroupLayer.new("ui_layout/moshen_RebelBossChooseGroupLayer.json", Colors.modelColor, ...)
end

function RebelBossChooseGroupLayer:ctor(...)
	self.super.ctor(self, ...)
end

function RebelBossChooseGroupLayer:onLayerLoad(...)
	-- initialize buff descriptions of 4 groups
	self:_initBuffDesc()

	-- register button events
	for i = 1, 4 do
		local btnGroup = self:getButtonByName("Button_Group_" .. i)
		if btnGroup then
			btnGroup:setTag(i)
		end
		self:registerBtnClickEvent("Button_Group_" .. i, handler(self, self._onClickGroup))
	end

	EffectSingleMoving.run(self, "smoving_bounce")
	EffectSingleMoving.run(self:getWidgetByName("Image_Touch_To_Continue"), "smoving_wait", nil, {position = true})
end

function RebelBossChooseGroupLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

	-- register event listners
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_CHOOSE_GROUP_SUCC, self._onChooseGroupSucc, self)
end

function RebelBossChooseGroupLayer:onLayerExit(...)
	uf_eventManager:removeListenerWithTarget(self)
end

-- initialize buff descriptions of 4 groups
function RebelBossChooseGroupLayer:_initBuffDesc()
	local groupNum = rebel_boss_buff_info.getLength()

	for i = 1, groupNum do
		local buff = rebel_boss_buff_info.get(i).buff
		self:showTextWithLabel("Label_Buff_" .. i, buff)
		self:enableLabelStroke("Label_Buff_" .. i, Colors.strokeBrown, 2)
	end
end

-- click handler of the group buttons
function RebelBossChooseGroupLayer:_onClickGroup(widget)
	local nGroup = widget:getTag()
	local function onConfirm()
		G_HandlersManager.moshenHandler:sendSelectAttackRebelBossGroup(nGroup)
	end

	local function onCancel()
		
	end

	local RebelBossSystemBox = require("app.scenes.moshen.rebelboss.RebelBossSystemBox")
	RebelBossSystemBox.show(nGroup, onConfirm, onCancel)
end

-- handler of the "EVENT_CROSS_WAR_SELECT_GROUP" event
function RebelBossChooseGroupLayer:_onChooseGroupSucc()
	G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_WAR_JOIN_GROUP_SUCCESS"))

	-- group selected, pull the score match base info
	local tInitInfo = G_Me.moshenData:getInitializeInfo()
	local tBoss = tInitInfo._tBoss
    local nProduceTime = tBoss._nProduceTime
    G_HandlersManager.moshenHandler:sendChallengeRebelBoss(nProduceTime)
    self:animationToClose()
end


return RebelBossChooseGroupLayer