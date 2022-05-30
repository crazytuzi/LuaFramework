local BaseScene = require("game.BaseScene")
local KuafuScene = class("SkillChooseScene", BaseScene)

local enumKuaFuShowType = {
xuanBa = 1,
baoMing = 2,
jueSai = 3,
zhanShi = 4
}
local enumXuanBaType = {
xuanBa_view = 1,
rankList_view = 2,
exchange_view = 3,
history_view = 4
}
local enumJueSaiType = {
baoMing_view = 1,
matchList_view = 2,
exchange_view = 3
}
local tabBottomName = {
{
"@kfs_xuanbasai",
"@kfs_paihangbang",
"@kfs_duihuan",
"@kfs_wangjiehuigu"
},
{
"@kfs_baoming",
"@kfs_juesaisaicheng",
"@kfs_duihuan"
},
{
"@kfs_juesaisaicheng",
"@kfs_duihuan"
},
{
"@kfs_wulinyinghao",
"@kfs_juesaisaicheng",
"@kfs_duihuan"
}
}
local viewLayer = {
{
{
layer = "game.kuafuzhan.xuanbaXuanbaLayer"
},
{
layer = "game.kuafuzhan.xuanbaRankListLayer"
},
{
layer = "game.kuafuzhan.xuanbaExchangeLayer"
},
{
layer = "game.kuafuzhan.xuanbaHistoryLayer"
}
},
{
{
layer = "game.kuafuzhan.raceApplyLayer"
},
{
layer = "game.kuafuzhan.raceCourseLayer"
},
{
layer = "game.kuafuzhan.xuanbaExchangeLayer"
}
},
{
{
layer = "game.kuafuzhan.raceCourseLayer"
},
{
layer = "game.kuafuzhan.xuanbaExchangeLayer"
}
},
{
{
layer = "game.kuafuzhan.xuanbaHistoryLayer",
data = 1
},
{
layer = "game.kuafuzhan.raceCourseLayer"
},
{
layer = "game.kuafuzhan.xuanbaExchangeLayer"
}
}
}
function KuafuScene:getCurViewLayer(viewType)
	if self.viewLayerTbl[self.viewType] then
		self.viewLayerTbl[self.viewType]:setVisible(false)
	end
	if not self.viewLayerTbl[viewType] then
		local layerdata = viewLayer[self.curKuaFuType][viewType]
		local layer = require(layerdata.layer).new({
		parent = self,
		size = self.viewSize,
		data = layerdata.data
		})
		self:addChild(layer)
		layer:setPositionY(self.getBottomHeight())
		self.viewLayerTbl[viewType] = layer
	end
	self.viewLayerTbl[viewType]:setVisible(true)
	self.viewLayerTbl[viewType]:initData()
	self.viewType = viewType
end

function KuafuScene:ctor(kuaFuState, needInit)
	KuafuScene.super.ctor(self, {
	subTopFile = "kuafu/kuafu_up_tab.ccbi",
	topFile = "public/top_frame_other.ccbi",
	isOther = true
	})
	
	ResMgr.removeBefLayer()
	
	--跨服战介绍
	self._rootnode.desc_Btn:addHandleOfControlEvent(function(sender, eventName)
		local text = ""
		for key, value in pairs(KuafuModel.getserverNames()) do
			text = text .. value .. "、"
		end
		local data_message_message = require("data.data_message_message")
		local desc = common:fill(data_message_message[38].text, text)
		local layer = require("game.SplitStove.SplitDescLayer").new(38, desc)
		CCDirector:sharedDirector():getRunningScene():addChild(layer, 1000)
	end,
	CCControlEventTouchUpInside)
	
	local viewHeight = self.getCenterHeight()
	self.viewSize = cc.size(display.width, viewHeight)
	kuaFuState = kuaFuState or enumKuafuState.xuanba
	self:resetKufuState(kuaFuState)
	self:setKuafuTitle(kuaFuState)
	KuafuModel.init(function(newState)
		self:performWithDelay(function()
			local scene = require("game.kuafuzhan.KuafuScene").new(newState)
			display.replaceScene(scene)
		end,
		1)
		show_tip_label(common:getLanguageString("@kuafuStateChangeTip"), 1)
	end,
	true)
	self.scheduler = require("framework.scheduler")
end

function KuafuScene:setKuafuTitle(kuaFuState)
	local data_kuafuzhanconfig_kuafuzhanconfig = require("data.data_kuafuzhanconfig_kuafuzhanconfig")
	local data = data_kuafuzhanconfig_kuafuzhanconfig[kuaFuState]
	if data.onthetittle == 1 then
		self._rootnode.kuafu_state_title:setString(data.lang)
		self._rootnode.kuafu_state_title:setVisible(true)
	else
		self._rootnode.kuafu_state_title:setVisible(false)
	end
end

function KuafuScene:resetKufuState(kuaFuState)
	self.kuaFuState = kuaFuState
	if self.kuaFuState == enumKuafuState.xuanba then
		self.curKuaFuType = enumKuaFuShowType.xuanBa
	elseif self.kuaFuState == enumKuafuState.apply then
		self.curKuaFuType = enumKuaFuShowType.baoMing
	elseif self.kuaFuState > enumKuafuState.apply and self.kuaFuState < enumKuafuState.zhanshi then
		self.curKuaFuType = enumKuaFuShowType.jueSai
	else
		self.curKuaFuType = enumKuaFuShowType.zhanShi
	end
	for key, layer in pairs(self.viewLayerTbl or {}) do
		self.viewLayerTbl:removeFromParentAndCleanup(true)
	end
	self.viewLayerTbl = {}
	self.viewLayerType = 0
	local btnTbl = {}
	for index = 1, 4 do
		if not tabBottomName[self.curKuaFuType][index] then
			self._rootnode["tab" .. index]:setVisible(false)
		else
			local name = common:getLanguageString(tabBottomName[self.curKuaFuType][index])
			if name then
				resetctrbtnString(self._rootnode["tab" .. index], name)
				table.insert(btnTbl, self._rootnode["tab" .. index])
			else
				self._rootnode["tab" .. index]:setVisible(false)
			end
		end
	end
	local function onTabBtn(tag)
		self:getCurViewLayer(tag)
	end
	CtrlBtnGroupAsMenu(btnTbl, function(idx)
		onTabBtn(idx)
	end)
	onTabBtn(1)
	self.timeNode = display.newNode()
	self:addChild(self.timeNode)
end

function KuafuScene:onEnter()
	game.runningScene = self
	KuafuScene.super.onEnter(self)
	GameAudio.playMainmenuMusic(true)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	local broadcastBg = self._rootnode.broadcast_tag
	if broadcastBg ~= nil then
		if game.broadcast:getParent() ~= nil then
			game.broadcast:removeFromParent(false)
		end
		broadcastBg:addChild(game.broadcast)
	end
	
	local function update(dt)
		local newState = KuafuModel.getKuafuState()
		if newState >= self.kuaFuState then
			self.kuaFuState = newState
			self:setKuafuTitle(newState)
			if self.viewLayerTbl[self.viewType] and self.viewLayerTbl[self.viewType].stateChanged then
				self.viewLayerTbl[self.viewType]:stateChanged(newState)
			end
		end
	end
	self.timeNode:schedule(update, 1)
end

function KuafuScene:onExit()
	KuafuScene.super.onExit(self)
	self.timeNode:stopAllActions()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return KuafuScene