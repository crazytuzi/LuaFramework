local data_huodongfuben_huodongfuben = require("data.data_huodongfuben_huodongfuben")


local JingYingBuyMsgBox = class("JingYingBuyMsgBox", function (param)	
	return  require("utility.ShadeLayer").new()
end)


function JingYingBuyMsgBox:sendPreview()
	-- RequestHelper.buyActTimes({
	-- 	aid = self.aid,
	-- 	act = 1,
	-- 	callback = function(data)
	-- 		self:previewInit(data)
	-- 	end
	-- 	})
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

	-- self.msgBoxEx = require("utility.MsgBoxEx").new({})
	local rowOneTable = {}
	local isBuy = ResMgr.createNomarlMsgTTF({text = "是否花费"}) --是否花费
	rowOneTable[#rowOneTable + 1] = isBuy
	local goldNum = ResMgr.createShadowMsgTTF({text = JingYingModel.getCost() .. "元宝",color = ccc3(255,210,0)}) --10元宝
	rowOneTable[#rowOneTable + 1] = goldNum
	local buyOne = ResMgr.createNomarlMsgTTF({text = "购买一次"})--购买一次
	rowOneTable[#rowOneTable + 1] = buyOne
	local fubenName =  ResMgr.createShadowMsgTTF({text = "精英副本" ,color = ccc3(255,210,0)})----某副本
	rowOneTable[#rowOneTable + 1] = fubenName
	local atkTime =  ResMgr.createNomarlMsgTTF({text = "攻打次数"})--攻打次数
	rowOneTable[#rowOneTable + 1] = atkTime

	--第二行
	local rowTwoTable = {}
	local todayBuy = ResMgr.createNomarlMsgTTF({text = "您今天已购买"})	--您今天已购买
	rowTwoTable[#rowTwoTable + 1] = todayBuy
	local buyNume = ResMgr.createShadowMsgTTF({text = JingYingModel.getBuyCnt(),color = ccc3(58,209,73)})
	rowTwoTable[#rowTwoTable + 1] = buyNume
	local buytime = ResMgr.createNomarlMsgTTF({text = "次"})	--次
	rowTwoTable[#rowTwoTable + 1] = buytime

	--第三行
	local rowThreeTable = {}
	local youAre = ResMgr.createNomarlMsgTTF({text = "你是"})--你是
	rowThreeTable[#rowThreeTable + 1] = youAre
	local vipIcon,vipTTF = ResMgr.getVipIconTTF() 	--VIP 
	rowThreeTable[#rowThreeTable + 1] = vipIcon
	rowThreeTable[#rowThreeTable + 1] = vipTTF

	local todayAble = ResMgr.createNomarlMsgTTF({text = "用户，今日可购买"})--用户，今日可购买
	rowThreeTable[#rowThreeTable + 1] = todayAble
	local ableTime = ResMgr.createShadowMsgTTF({text = JingYingModel.getLimit() - JingYingModel.getBuyCnt(),color = ccc3(58,209,73)})--n
	rowThreeTable[#rowThreeTable + 1] =ableTime
	local ableCi = ResMgr.createNomarlMsgTTF({text = "次"})--次
	rowThreeTable[#rowThreeTable + 1] = ableCi

	local rowAll = {rowOneTable,rowTwoTable,rowThreeTable}

	local msg = require("utility.MsgBoxEx").new({
		resTable = rowAll,
		confirmFunc = function() 
			self:onConfirm()
		end,
		closeFunc = function() 
			self:onClose()
		end
		})
	-- msg:setPosition(display.width/2, display.height/2)
	self:addChild(msg)

end

function JingYingBuyMsgBox:onConfirm()
	if JingYingModel.getLimit() - JingYingModel.getBuyCnt() == 0 then
		ResMgr.showMsg(5)
	else
		if JingYingModel.getGold()< JingYingModel.getCost() then
			ResMgr.showMsg(7)
		else
			self:sendBuy()
		end
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