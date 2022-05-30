local data_soul_soul = require("data.data_soul_soul")
local data_item_item = require("data.data_item_item")
local data_error_error = require("data.data_error_error")

local SpiritConvertsLayer = class("SpiritConvertsLayer", function ()
	return require("utility.ShadeLayer").new()
end)

function SpiritConvertsLayer:ctor(param)
	self.callback = param.callback
	self.errorCallBack = param.errorCallBack
	self._spiritCtrl = require("game.Spirit.SpiritCtrl")
	self.showSpiritConvertsLayer = true
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("spirit/spirit_converts.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self:refreshData()
	self:refreshUI()
	
	--关闭
	self._rootnode.closeBtn:addHandleOfControlEvent(function ()
		self.isPageShow = false
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	self.selected = {
	[1] = false,
	[2] = false
	}
	
	local function choose(pos)
		if self.selected[pos] then
			self.selected[pos] = false
		else
			self.selected[pos] = true
		end
		for k, v in ipairs(self.selected) do
			if k == pos then
				self.selected[pos] = true
				self._rootnode["selectedFlag_" .. tostring(pos)]:setVisible(self.selected[pos])
			else
				self.selected[k] = false
				self._rootnode["selectedFlag_" .. tostring(k)]:setVisible(self.selected[k])
			end
		end
	end
	
	for i = 1, #self.selected do
		self._rootnode["chooseStarBtn_" .. tostring(i)]:registerScriptTapHandler(choose)
	end
	
	--10次转换
	self._rootnode.start10Btn:setTitleForState("召唤50次", CCControlStateNormal)
	self._rootnode.start10Btn:setTitleForState("召唤50次", CCControlStateHighlighted)
	self._rootnode.start10Btn:setTitleForState("召唤50次", CCControlStateDisabled)
	self._rootnode.start10Btn:setTitleForState("召唤50次", CCControlStateSelected)
	
	self._rootnode.start10Btn:addHandleOfControlEvent(function ()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local bHasOpen, prompt = OpenCheck.getOpenLevelById(OPENCHECK_TYPE.Zhenqi_ZhuanHuan, game.player:getLevel(), game.player:getVip())
		if not bHasOpen then
			show_tip_label(data_error_error[2300015].prompt)
			return
		end
		self:onCallTen()
	end,
	CCControlEventTouchUpInside)
	
	
	self._rootnode.exptoItemBtn:addHandleOfControlEvent(function ()
		self:expto()
	end,
	CCControlEventTouchUpInside)
	
	return self
end

function SpiritConvertsLayer:onEnter()
	self.isShowSpiritConvertsLayer = true
end

function SpiritConvertsLayer:onExit()
	self.isShowSpiritConvertsLayer = false
end

function SpiritConvertsLayer:onCallTen()
	local str
	if self.selected[1] == true then
		str = {4,5}
	elseif self.selected[2] == true then
		str = {5}
	end
	if str == nil then
		show_tip_label(data_error_error[2300014].prompt)
		return
	end
	local param = {}
	self._rootnode.start10Btn:setEnabled(false)
	self._spiritCtrl.converts(str, function (data)	
		if not self.isShowSpiritConvertsLayer or self.isShowSpiritConvertsLayer == false then
			return
		end
		self._rootnode.start10Btn:setEnabled(true)
		local tipLayer = require("game.Spirit.SpiritGetTip").new(data)
		self:addChild(tipLayer, 100)
		self:refreshData()
		self:refreshUI()
	end,
	self.callback,
	function (data)
		self._rootnode.start10Btn:setEnabled(true)
	end
	)
end

function SpiritConvertsLayer:refreshData()
	self.currExp = self._spiritCtrl.getConvertExp()
end

function SpiritConvertsLayer:refreshUI()
	if self.currExp then
		self._rootnode.curExpLabel:setString(self.currExp)
	end
	if self.currExp < 1000 then
		self._rootnode.exptoItemBtn:setEnabled(false)
	else
		self._rootnode.exptoItemBtn:setEnabled(true)
	end
	self._rootnode.expBar:setTextureRect(cc.rect(self._rootnode.expBar:getTextureRect().x, self._rootnode.expBar:getTextureRect().y, 603 * (self.currExp / 1000), 41))
end

function SpiritConvertsLayer:uiEnabled(flag)
	self._rootnode.resolveBtn:setEnabled(flag)
	self._rootnode.closeBtn:setEnabled(flag)
end

function SpiritConvertsLayer:expto()
	local itemData = {
	name = "大经验丹",
	needReputation = 1000,
	had = self.currExp,
	limitNum = math.floor(self.currExp / 1000)
	}
	local param = {}
	param.shopType = ZHENQIDAN_EXCHANGE_TYPE
	param.reputation = self.currExp
	param.itemData = itemData
	param.listener = function(num)
		self._spiritCtrl.resolves(num, function (data)
			if not self.isShowSpiritConvertsLayer or self.isShowSpiritConvertsLayer == false then
				return
			end
			self:refreshData()
			self:refreshUI()
			if data and #data >= 1 then
				game.runningScene:removeChildByTag(3000000)
				local tipLabel = require("game.Spirit.SpiritTips").new(#data)
				game.runningScene:addChild(tipLabel, 3000000)
			end
		end,
		self.callback)
	end
	local popup = require("game.Arena.ExchangeCountBox").new(param)
	game.runningScene:addChild(popup, 1000000)
end

return SpiritConvertsLayer