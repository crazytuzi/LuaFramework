local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")

local JingYingBuyMsgBox = class("JingYingBuyMsgBox", function(param)
	return require("utility.ShadeLayer").new()
end)

function JingYingBuyMsgBox:sendPreview()
end

function JingYingBuyMsgBox:sendBuy()
	RequestHelper.buyEliteTimes({
	callback = function(data)
		JingYingModel.buySuccess(data)
		if self.removeListener then
			self.removeListener()
		end
		self:removeSelf()
	end
	})
end

function JingYingBuyMsgBox:previewInit()
	local rowZeroTable = {}
	local isBuy = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@IsCost")
	})
	rowZeroTable[#rowZeroTable + 1] = isBuy
	local goldNum = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@Money", JingYingModel.getCost()),
	color = cc.c3b(255, 210, 0)
	})
	rowZeroTable[#rowZeroTable + 1] = goldNum
	local buyOne = ResMgr.createNomarlMsgTTF({
	text = common:getLanguageString("@BuyOne")
	})
	rowZeroTable[#rowZeroTable + 1] = buyOne
	local rowOneTable = {}
	local fubenName = ResMgr.createShadowMsgTTF({
	text = common:getLanguageString("@Elite"),
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
	text = JingYingModel.getBuyCnt(),
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
	text = JingYingModel.getLimit() - JingYingModel.getBuyCnt(),
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

function JingYingBuyMsgBox:onConfirm()
	if JingYingModel.getLimit() - JingYingModel.getBuyCnt() == 0 then
		ResMgr.showMsg(5)
	elseif JingYingModel.getGold() < JingYingModel.getCost() then
		ResMgr.showMsg(7)
	else
		self:sendBuy()
	end
end

function JingYingBuyMsgBox:onClose()
	self:removeSelf()
end

function JingYingBuyMsgBox:ctor(param)
	self.removeListener = param.removeListener
	self.aid = param.aid
	self:previewInit()
end

return JingYingBuyMsgBox