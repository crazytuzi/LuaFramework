local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")

local HuoDongBuyMsgBox = class("HuoDongBuyMsgBox", function(param)
	return require("utility.ShadeLayer").new()
end)

function HuoDongBuyMsgBox:sendBuy()
	RequestHelper.buyActTimes({
	aid = self.aid,
	act = 2,
	callback = function(data)
		local huodongData = HuoDongFuBenModel.getFubenData(self.aid)
		huodongData.buyCnt = data.buyCnt
		huodongData.spend = data.spend
		HuoDongFuBenModel.setRestNum(self.aid, HuoDongFuBenModel.getRestNum(self.aid) + 1)
		game.player:setHuodongNum(game.player:getHuodongNum() + 1)
		self.buyData = data
		local curGold = self.buyData.gold
		game.player:setGold(curGold)
		PostNotice(NoticeKey.CommonUpdate_Label_Gold)
		if self.removeListener then
			self.removeListener()
		end
		self:removeSelf()
	end
	})
end

function HuoDongBuyMsgBox:previewInit(data)
	self.buyData = HuoDongFuBenModel.getFubenData(self.aid)
	local rowZeroTable = {}
	local isBuy = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@IsCost")
	})
	rowZeroTable[#rowZeroTable + 1] = isBuy
	local goldNum = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@Money", self.buyData.spend),
	color = cc.c3b(255, 210, 0)
	})
	rowZeroTable[#rowZeroTable + 1] = goldNum
	local buyOne = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@BuyOne")
	})
	rowZeroTable[#rowZeroTable + 1] = buyOne
	local rowOneTable = {}
	local fubenName = ResMgr.createShadowMsgTTF({
	text = data_huodongfuben_huodongfuben[self.aid].name,
	color = cc.c3b(255, 210, 0)
	})
	rowOneTable[#rowOneTable + 1] = fubenName
	local atkTime = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@AttackNumber")
	})
	rowOneTable[#rowOneTable + 1] = atkTime
	local rowTwoTable = {}
	local todayBuy = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@AlreadyBuy")
	})
	rowTwoTable[#rowTwoTable + 1] = todayBuy
	local buyNume = ResMgr.createShadowMsgTTF({
	text = self.buyData.buyCnt,
	color = cc.c3b(58, 209, 73)
	})
	rowTwoTable[#rowTwoTable + 1] = buyNume
	local buytime = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@Next")
	})
	rowTwoTable[#rowTwoTable + 1] = buytime
	local rowThreeTable = {}
	local youAre = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@YouAre")
	})
	rowThreeTable[#rowThreeTable + 1] = youAre
	local vipIcon, vipTTF = ResMgr.getVipIconTTF()
	rowThreeTable[#rowThreeTable + 1] = vipIcon
	rowThreeTable[#rowThreeTable + 1] = vipTTF
	local todayAble = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@UserBuy")
	})
	rowThreeTable[#rowThreeTable + 1] = todayAble
	local ableTime = ResMgr.createShadowMsgTTF({
	text = self.buyData.limit - self.buyData.buyCnt,
	color = cc.c3b(58, 209, 73)
	})
	rowThreeTable[#rowThreeTable + 1] = ableTime
	local ableCi = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@Next")
	})
	rowThreeTable[#rowThreeTable + 1] = ableCi
	local rowAll = {
	rowZeroTable,
	rowOneTable,
	rowTwoTable,
	rowThreeTable
	}
	local msg = require("utility.MsgBoxEx").new({
	resTable = rowAll,
	confirmFunc = function()
		self:onConfirm()
	end,
	closeFunc = function()
		self:onClose()
	end
	})
	self:addChild(msg)
end

function HuoDongBuyMsgBox:onConfirm()
	dump(self.buyData)
	if self.buyData.limit - self.buyData.buyCnt == 0 then
		ResMgr.showMsg(5)
	elseif self.buyData.gold < self.buyData.spend then
		ResMgr.showMsg(7)
	else
		self:sendBuy()
	end
end

function HuoDongBuyMsgBox:onClose()
	if self._closeFunc ~= nil then
		self._closeFunc()
	end
	self:removeSelf()
end

function HuoDongBuyMsgBox:ctor(param)
	self._closeFunc = param.closeFunc
	self.removeListener = param.removeListener
	self.aid = param.aid
	self:previewInit()
end

return HuoDongBuyMsgBox