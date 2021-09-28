


local SubMapBuyMsgBox = class("SubMapBuyMsgBox", function (param)	
	return  require("utility.ShadeLayer").new()
end)


function SubMapBuyMsgBox:sendPreview()
	SubMapModel.sendPreview({
		callback = function()
			self:previewInit()
		end,
		errorCB = function ( ... )			
			self.errorCallBack()
			self:onClose()
			
		end})
end

function SubMapBuyMsgBox:sendBuy()
	SubMapModel.sendBuy({
		callback = function()
			self.removeListener()
			self:onClose()
		end,
		errorCB = function ( ... )
			self.errorCallBack()
			self:onClose()
			
		end
		})
end




function SubMapBuyMsgBox:previewInit()

	-- self.msgBoxEx = require("utility.MsgBoxEx").new({})
	local rowOneTable = {}
	local isBuy = ResMgr.createNomarlMsgTTF({text = "花费"}) --是否花费
	rowOneTable[#rowOneTable + 1] = isBuy
	local goldNum = ResMgr.createShadowMsgTTF({text = SubMapModel.getCost() .. "元宝",color = ccc3(255,210,0)}) --10元宝
	rowOneTable[#rowOneTable + 1] = goldNum
	local buyOne = ResMgr.createNomarlMsgTTF({text = "或消耗"})--购买一次
	rowOneTable[#rowOneTable + 1] = buyOne
	local fubenName =  ResMgr.createShadowMsgTTF({text = "1个" ,color = ccc3(58,209,73)})----某副本
	rowOneTable[#rowOneTable + 1] = fubenName

	local itemIcon = display.newSprite("#icon_qianggongling.png")
    rowOneTable[#rowOneTable + 1] = itemIcon

    local curNumTTF =  ResMgr.createShadowMsgTTF({text = "(当前拥有",color = ccc3(58,209,73) })----某副本
	rowOneTable[#rowOneTable + 1] = curNumTTF

	local curNum =  ResMgr.createShadowMsgTTF({text = SubMapModel.getQiangGongNum().."个)" ,color = ccc3(58,209,73)})----某副本
	rowOneTable[#rowOneTable + 1] = curNum

	--第二行
	local rowTwoTable = {}
	local todayBuy = ResMgr.createNomarlMsgTTF({text = "可重置该关卡的挑战次数"})	--可重置该关卡的挑战次数
	rowTwoTable[#rowTwoTable + 1] = todayBuy


	local rowAll = {rowOneTable,rowTwoTable}

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

function SubMapBuyMsgBox:onConfirm()
	if SubMapModel.isEnoughQiangGong() then
		self:sendBuy()
	else
		if  SubMapModel.isEnoughGold() then
			self:sendBuy()
		else
			show_tip_label("金币不足")
		end
	end
end

function SubMapBuyMsgBox:onClose()

	self:removeSelf()
end

function SubMapBuyMsgBox:ctor(param)
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")

	self.removeListener = param.removeListener
	-- self.aid = param.aid	
	self.errorCallBack = param.errorCallBack

	self:sendPreview()
	
end


return SubMapBuyMsgBox