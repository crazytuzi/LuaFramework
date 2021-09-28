local LotteryLayer = class("LotteryLayer", function() return cc.Layer:create() end)

local path = "res/lotteryEx/"

local SUMMON_TYPE_NORMAL = 1
local SUMMON_TYPE_SPECIAL = 2

function LotteryLayer:ctor()
	self.luck = 0
	local msgids = {LOTTERY_SC_SUMMON, LOTTERY_SC_RET, LOTTERY_SC_REFRESH, LOTTERY_SC_REWARD}
	require("src/MsgHandler").new(self, msgids)

	--g_msgHandlerInst:sendNetDataByFmtExEx(LOTTERY_CS_REQ, "i", G_ROLE_MAIN.obj_id)
	--addNetLoading(LOTTERY_CS_REQ, LOTTERY_SC_RET)

	local bg,closeBtn = createBgSprite(self, game.getStrByKey("wr_skill_book_way_lottery"), path.."28.png")
	G_TUTO_NODE:setTouchNode(closeBtn, TOUCH_LOTTERY_CLOSE)
	self.bg = bg

	createSprite(bg, "res/common/bg/line6.png", cc.p(bg:getContentSize().width/2, 30), cc.p(0.5, 0))

	--普通寻宝
	local normalBg = createSprite(bg, path.."10.png", cc.p(20, 21), cc.p(0, 0))
	self.normalBg = normalBg
	createSprite(normalBg, path.."3.png", cc.p(normalBg:getContentSize().width/2, 475), cc.p(0.5, 0))

	local effect = Effects:create(false)
    effect:playActionData("lotteryNormalBox", 9, 1.5, -1)
    normalBg:addChild(effect)
    effect:setAnchorPoint(cc.p(0.5, 0.5))
    effect:setPosition(getCenterPos(normalBg, 1, 67))
    addEffectWithMode(effect,1)

	--createSprite(normalBg, path.."bg.png", getCenterPos(normalBg), cc.p(0.5, 0.5))
	--createSprite(normalBg, path.."3.png", cc.p(normalBg:getContentSize().width/2, normalBg:getContentSize().height-30), cc.p(0.5, 1))
	local function checkNormalFunc()
		local layer = require("src/layers/lotteryEx/LotteryCheckLayer").new(true, self.checkData.normalData)
		Manimation:transit(
		{
			ref = self,
			node = layer,
			curve = "-",
			sp = cc.p(display.cx, display.cy),
			zOrder = 100,
			swallow = true,
		})
	end
	local ckeckNormalBtn = createTouchItem(normalBg, "res/component/button/48.png", cc.p(60, 500), checkNormalFunc)
	createLabel(ckeckNormalBtn, game.getStrByKey("preview"), getCenterPos(ckeckNormalBtn), cc.p(0.5, 0.5), 20, true)
	createTouchItem(normalBg, path.."16.png", cc.p(217, 332), checkNormalFunc)

	--至尊寻宝
	local specialBg = createSprite(bg, path.."9.png", cc.p(493, 21), cc.p(0, 0))
	self.specialBg = specialBg
	createSprite(specialBg, path.."2.png", cc.p(normalBg:getContentSize().width/2, 475), cc.p(0.5, 0))

	local effect = Effects:create(false)
    effect:playActionData("lotterySpecialBox", 9, 1.5, -1)
    specialBg:addChild(effect)
    effect:setAnchorPoint(cc.p(0.5, 0.5))
    effect:setPosition(getCenterPos(specialBg, 14, 34))
    addEffectWithMode(effect,1)

	createLabel(specialBg, game.getStrByKey("lotteryEx_tip_font"), cc.p(specialBg:getContentSize().width/2+100, 15), cc.p(0.5, 0), 20, true, nil, nil, MColor.lable_yellow)
	-- __createHelp(
	-- {
	-- 	parent = specialBg,
	-- 	str = require("src/config/PromptOp"):content(13),
	-- 	pos = cc.p(370,210),
	-- })

	local function checkSpecialFunc()
		local lv = MRoleStruct:getAttr(ROLE_LEVEL)
		for k,v in pairs(self.checkData.specialData) do
			if lv >= v.lv.lvMin and lv <= v.lv.lvMax then
				local layer = require("src/layers/lotteryEx/LotteryCheckLayer").new(false, v.data)
				Manimation:transit(
				{
					ref = self,
					node = layer,
					curve = "-",
					sp = cc.p(display.cx, display.cy),
					zOrder = 100,
					swallow = true,
				})

				break
			end
		end
		
	end
	local checkSpecialBtn = createTouchItem(specialBg, "res/component/button/48.png", cc.p(60, 500), checkSpecialFunc)
	createLabel(checkSpecialBtn, game.getStrByKey("preview"), getCenterPos(checkSpecialBtn), cc.p(0.5, 0.5), 20, true)
	createTouchItem(specialBg, path.."17.png", cc.p(229, 333), checkSpecialFunc)
	local richText = require("src/RichText").new(specialBg, cc.p(45, 140), cc.size(360, 25), cc.p(0, 0), 20, 20, MColor.lable_black)
    richText:addText(game.getStrByKey("lotteryEx_tip_font_reward"))
    richText:format()

    function createGraySprite(parent, res, pos, anchor, isGray)
    	local graySpr = GraySprite:create(res)
    	parent:addChild(graySpr)
    	graySpr:setAnchorPoint(anchor)
    	graySpr:setPosition(pos)
    	if isGray then
    		graySpr:addColorGray()
    	end

    	return graySpr
    end
	self.fontIcon = {}
	self.fontIcon[1] = createGraySprite(specialBg, path.."4.png", cc.p(40, 200), cc.p(0, 0.5), true)
	self.fontIcon[2] = createGraySprite(specialBg, path.."5.png", cc.p(100, 200), cc.p(0, 0.5), true)
	self.fontIcon[3] = createGraySprite(specialBg, path.."6.png", cc.p(160, 200), cc.p(0, 0.5), true)
	self.fontIcon[4] = createGraySprite(specialBg, path.."7.png", cc.p(220, 200), cc.p(0, 0.5), true)
	for i,v in ipairs(self.fontIcon) do
		local scale = 0.85
		v:setScale(scale)
		if i > 1 then
			v:setPosition(cc.p(self.fontIcon[i-1]:getPositionX()+self.fontIcon[i-1]:getContentSize().width*scale, 
				self.fontIcon[i-1]:getPositionY()))
		end
	end

	local function changeFunc()
		if self.luck >= 4 then
			--g_msgHandlerInst:sendNetDataByFmtExEx(LOTTERY_CS_REWARD, "i", G_ROLE_MAIN.obj_id)
			--addNetLoading(LOTTERY_CS_REWARD, LOTTERY_SC_REWARD)
		else
			if self.luckFreshCount then
				MessageBoxYesNo(nil, string.format(game.getStrByKey("lotteryEx_tip_font_refresh"), self.luckFreshCount), function() 
					--g_msgHandlerInst:sendNetDataByFmtExEx(LOTTERY_CS_REFRESH, "i", G_ROLE_MAIN.obj_id) 
					--addNetLoading(LOTTERY_CS_REFRESH, LOTTERY_SC_REFRESH)
					end, nil)
			end
		end
	end
	local changeBtn = createMenuItem(specialBg, path.."8.png", cc.p(405, 200), changeFunc)
	self.changeBtn = changeBtn
	self.changeBtn:setVisible(false)
	-- self.luckFreshFont = createLabel(changeBtn, game.getStrByKey("lotteryEx_refresh"), cc.p(changeBtn:getContentSize().width/2, changeBtn:getContentSize().height/2), cc.p(0.5, 0.5), 18, true)
	--self.luckFreshLabel = createLabel(changeBtn, "", cc.p(changeBtn:getContentSize().width/2, changeBtn:getContentSize().height/2-1), cc.p(0.5, 1), 16, true, nil, nil, MColor.yellow)
	self.luckGetFont = createLabel(changeBtn, game.getStrByKey("lotteryEx_get"), cc.p(changeBtn:getContentSize().width/2, changeBtn:getContentSize().height/2), cc.p(0.5, 0.5), 18, true, nil, nil, MColor.green)
	--self.luckGetFont:setVisible(false)
	--特效
	self.luckFreshEffect = tutoAddAnimation(changeBtn, cc.p(changeBtn:getContentSize().width/2, changeBtn:getContentSize().height/2), TUTO_ANIMATE_TYPE_BUTTON)
	self.luckFreshEffect:setContentSize(cc.size(200, 65))
	scaleToTarget(self.luckFreshEffect, changeBtn)
	--self.luckFreshEffect:setOpacity(0)

	--底部按钮
	--local bottomBg = createSprite(bg, path.."29.jpg", cc.p(bg:getContentSize().width/2, 15), cc.p(0.5, 0))
	--self.bottomBg = bottomBg
	-- local normalIcon = createPropIcon(normalBg, 5019, false, false, nil)
	-- normalIcon:setPosition(cc.p(normalBg:getContentSize().width/2-130, 100))
	-- normalIcon:setScale(0.5)
	-- createLabel(normalBg, 2, cc.p(normalBg:getContentSize().width/2-135, 110), cc.p(0, 0), 20, true, nil, nil, MColor.white)
	-- createLabel(normalBg, , cc.p(normalBg:getContentSize().width/2-120, 110), cc.p(0, 0), 20, true, nil, nil)
	local oneIcon = createSprite(normalBg, require("src/config/propOp").icon(5019), cc.p(specialBg:getContentSize().width/2-130, 105), cc.p(0.5, 0))
	oneIcon:setScale(0.7)
	createLabel(normalBg, "2", cc.p(specialBg:getContentSize().width/2-95, 110), cc.p(0, 0), 20, true)
	local function summonNormalFun()
		self.summonType = SUMMON_TYPE_NORMAL
		self.summonTime = 1
		self.summonSubType = 1
		self.summonYuanBao = 0
		
		self:summon()
	end
	local summonNormal = createMenuItem(normalBg, "res/component/button/4.png", cc.p(normalBg:getContentSize().width/2-100, 70), summonNormalFun)
	self.summonNormal = summonNormal
	G_TUTO_NODE:setTouchNode(summonNormal, TOUCH_LOTTERY_NORMAL)
	createLabel(summonNormal, game.getStrByKey("lotteryEx_btn_one"), cc.p(summonNormal:getContentSize().width/2, summonNormal:getContentSize().height/2), cc.p(0.5, 0.5), 20, true)

	-- local normalTenIcon = createPropIcon(normalBg, 5019, false, false, nil)
	-- normalTenIcon:setPosition(cc.p(normalBg:getContentSize().width/2+70, 100))
	-- normalTenIcon:setScale(0.5)
	-- createLabel(normalBg, 18, cc.p(normalBg:getContentSize().width/2+65, 110), cc.p(0, 0), 20, true, nil, nil, MColor.white)
	-- createLabel(normalBg, require("src/config/propOp").name(5019), cc.p(normalBg:getContentSize().width/2+90, 110), cc.p(0, 0), 20, true, nil, nil)
	local tenIcon = createSprite(normalBg, require("src/config/propOp").icon(5019), cc.p(normalBg:getContentSize().width/2+70, 105), cc.p(0.5, 0))
	tenIcon:setScale(0.7)
	createLabel(normalBg, "18", cc.p(normalBg:getContentSize().width/2+100, 110), cc.p(0, 0), 20, true)
	local function summonNormalTenFun()
		self.summonType = SUMMON_TYPE_NORMAL
		self.summonTime = 10
		self.summonSubType = 4
		self.summonYuanBao = 0
		
		self:summon()
	end
	local summonNormalTen = createMenuItem(normalBg, "res/component/button/4.png", cc.p(normalBg:getContentSize().width/2+100, 70), summonNormalTenFun)
	self.summonNormalTen = summonNormalTen
	createLabel(summonNormalTen, game.getStrByKey("lotteryEx_btn_ten"), cc.p(summonNormal:getContentSize().width/2, summonNormal:getContentSize().height/2), cc.p(0.5, 0.5), 20, true)
	createSprite(summonNormalTen, path.."20.png", cc.p(22, summonNormalTen:getContentSize().height), cc.p(0, 1))

	local oneIcon = createSprite(specialBg, "res/group/currency/3.png", cc.p(specialBg:getContentSize().width/2-130, 105), cc.p(0.5, 0))
	self.oneIcon = oneIcon
	oneIcon:setScale(0.7)
	self.oneLabel = createLabel(specialBg, "40", cc.p(specialBg:getContentSize().width/2-95, 110), cc.p(0, 0), 20, true)
	local function summonOneFun()
		self.summonType = SUMMON_TYPE_SPECIAL
		self.summonTime = 1
		self.summonSubType = 2
		self.summonYuanBao = 40

		self:summon()
	end
	local summonOneBtn = createMenuItem(specialBg, "res/component/button/4.png", cc.p(specialBg:getContentSize().width/2-100, 70), summonOneFun)
	G_TUTO_NODE:setTouchNode(summonOneBtn, TOUCH_LOTTERY_SPECIAL_1)
	self.summonOneBtn = summonOneBtn
	createLabel(summonOneBtn, game.getStrByKey("lotteryEx_btn_one"), getCenterPos(summonOneBtn), cc.p(0.5, 0.5), 20, true)
	local freeLabel = createLabel(summonOneBtn, "", cc.p(summonOneBtn:getContentSize().width/2, summonOneBtn:getContentSize().height+5), cc.p(0.5, 0), 20, true, nil, nil, MColor.yellow)
	freeLabel:setTag(101)

	local tenIcon = createSprite(specialBg, "res/group/currency/3.png", cc.p(specialBg:getContentSize().width/2+70, 105), cc.p(0.5, 0))
	tenIcon:setScale(0.7)
	createLabel(specialBg, "360", cc.p(specialBg:getContentSize().width/2+100, 110), cc.p(0, 0), 20, true)
	local function summonTenFun()
		local function yesFunc()
			self.summonType = SUMMON_TYPE_SPECIAL
			self.summonTime = 10
			self.summonSubType = 3
			self.summonYuanBao = 360

			self:summon()
		end

		if self.luck >= 4 then
			MessageBoxYesNo(nil, game.getStrByKey("lotteryEx_tip_reward"), function() 
					yesFunc()
				end, nil)
		else
			yesFunc()
		end
	end
	local summonTenBtn = createMenuItem(specialBg, "res/component/button/4.png", cc.p(specialBg:getContentSize().width/2+100, 70), summonTenFun)
	createLabel(summonTenBtn, game.getStrByKey("lotteryEx_btn_ten"), getCenterPos(summonTenBtn), cc.p(0.5, 0.5), 20, true)
	createSprite(summonTenBtn, path.."20.png", cc.p(22, summonTenBtn:getContentSize().height), cc.p(0, 1))
	--createLabel(summonTenBtn, game.getStrByKey("lotteryEx_btn_ten_money"), cc.p(summonTenBtn:getContentSize().width/2, summonTenBtn:getContentSize().height/2), cc.p(0.5, 1), 18, true, nil, nil, MColor.yellow)

	local Mcurrency = require "src/functional/currency"
	Mnode.addChild(
	{
		parent = bg,
		child = Mcurrency.new(
		{
			cate = PLAYER_INGOT,
			--bg = "res/common/19.png",
			color = MColor.lable_yellow,
		}),
		
		anchor = cc.p(0, 0.5),
		pos = cc.p(35, 600),
	})

	self:createCheckData()
	self:updateToolTip()

	SwallowTouches(self)

	self:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(self, SHOW_LOTTERY)
		elseif event == "exit" then
		end
	end)
end

function LotteryLayer:createCheckData()
	self.checkData = {}
	self.checkData.normalData = {}
	self.checkData.specialData = {}
	self.checkData.specialData[30] = {}
	self.checkData.specialData[40] = {}
	self.checkData.specialData[50] = {}
	self.checkData.specialData[60] = {}
	self.checkData.specialData[70] = {}
	self.checkData.specialData[30].lv = {lvMin=0, lvMax=39}
	self.checkData.specialData[40].lv = {lvMin=40, lvMax=49}
	self.checkData.specialData[50].lv = {lvMin=50, lvMax=59}
	self.checkData.specialData[60].lv = {lvMin=60, lvMax=69}
	self.checkData.specialData[70].lv = {lvMin=70, lvMax=100}
	self.checkData.specialData[30].data = {}
	self.checkData.specialData[40].data = {}
	self.checkData.specialData[50].data = {}
	self.checkData.specialData[60].data = {}
	self.checkData.specialData[70].data = {}

	-- local DropOp = require("src/config/DropAwardOp")
 --    --local dropItem = DropOp:dropItem(tonumber(self.fbData[index].tggd))
 --    for k,v in pairs(DropOp:dropItem(11))do
 --    	table.insert(self.checkData.normalData, v.q_item)
 --    end
 --    for k,v in pairs(DropOp:dropItem(4444423))do
 --    	table.insert(self.checkData.specialData[30].data, v.q_item)
 --    end
 --    for k,v in pairs(DropOp:dropItem(4444424))do
 --    	table.insert(self.checkData.specialData[40].data, v.q_item)
 --    end
 --    for k,v in pairs(DropOp:dropItem(4444425))do
 --    	table.insert(self.checkData.specialData[50].data, v.q_item)
 --    end
 --    for k,v in pairs(DropOp:dropItem(4444426))do
 --    	table.insert(self.checkData.specialData[60].data, v.q_item)
 --    end
 --    for k,v in pairs(DropOp:dropItem(4444427))do
 --    	table.insert(self.checkData.specialData[70].data, v.q_item)
 --    end

	local tab = getConfigItemByKey("DropAward") --require("src/config/DropAward")
	for i,v in ipairs(tab) do
		if v.q_id == 11 then
			table.insert(self.checkData.normalData, #self.checkData.normalData+1, v.q_item)
		elseif v.q_id == 4444413 then
			--table.insert(self.checkData.specialData[30].data, v.q_item)
		elseif v.q_id == 4444414 then
			--table.insert(self.checkData.specialData[40].data, v.q_item)
		elseif v.q_id == 4444415 then
			--table.insert(self.checkData.specialData[50].data, v.q_item)
		elseif v.q_id == 4444416 then
			--table.insert(self.checkData.specialData[60].data, v.q_item)
		elseif v.q_id == 4444417 then
			--table.insert(self.checkData.specialData[70].data, v.q_item)
		elseif v.q_id == 4444423 then
			table.insert(self.checkData.specialData[30].data, #self.checkData.specialData[30].data+1, v.q_item)
		elseif v.q_id == 4444424 then
			table.insert(self.checkData.specialData[40].data, #self.checkData.specialData[40].data+1, v.q_item)
		elseif v.q_id == 4444425 then
			table.insert(self.checkData.specialData[50].data, #self.checkData.specialData[50].data+1, v.q_item)
		elseif v.q_id == 4444426 then
			table.insert(self.checkData.specialData[60].data, #self.checkData.specialData[60].data+1, v.q_item)
		elseif v.q_id == 4444427 then
			table.insert(self.checkData.specialData[70].data, #self.checkData.specialData[70].data+1, v.q_item)
		end
	end
end

function LotteryLayer:summon()
	--g_msgHandlerInst:sendNetDataByFmtExEx(LOTTERY_CS_SUMMON, "ii", G_ROLE_MAIN.obj_id, self.summonSubType)
	--addNetLoading(LOTTERY_CS_SUMMON, LOTTERY_SC_SUMMON)

	local maskingLayer = createSwallowTouchesLayer(2)
	self:addChild(maskingLayer)
end

function LotteryLayer:createSummonShow()
	local layer = require("src/layers/lotteryEx/LotteryShowLayer").new(self, self.summonType == SUMMON_TYPE_NORMAL, self.data)
	self:addChild(layer)
end

function LotteryLayer:updateToolTip()
	if self.updateRichText then
		removeFromParent(self.updateRichText)
		self.updateRichText = nil
	end

	local richText = createRichText(self.updateButtonBg, cc.p(89, 15), cc.size(170, 25), cc.p(0.5, 0.5), true)
	local MPackStruct = require "src/layers/bag/PackStruct"
	local MPackManager = require "src/layers/bag/PackManager"
	local pack = MPackManager:getPack(MPackStruct.eBag)
	local num = pack:countByProtoId(5019)
	local numStr = num..""
	if num >= 2 then
		--numStr = num..""--"^c(green)"..num.."/2^"
		if self.redPointOne == nil then
			self.redPointOne = createSprite(self.summonNormal, "res/component/flag/red.png", cc.p(self.summonNormal:getContentSize().width-20, 5), cc.p(0.5, 0.5))
		end
	else
		if self.redPointOne then
			removeFromParent(self.redPointOne)
			self.redPointOne = nil
		end
		--numStr = num..""--"^c(red)"..num.."/2^"
	end

	if num >= 18 then
		--numStr = num..""--"^c(green)"..num.."/2^"
		if self.redPointTen == nil then
			self.redPointTen = createSprite(self.summonNormalTen, "res/component/flag/red.png", cc.p(self.summonNormal:getContentSize().width-20, 5), cc.p(0.5, 0.5))
		end
	else
		if self.redPointTen then
			removeFromParent(self.redPointTen)
			self.redPointTen = nil
		end
		--numStr = num..""--"^c(red)"..num.."/2^"
	end

	local toolTipStr = string.format(game.getStrByKey("lottery_exchange_toolTip"), numStr)
	local richText = require("src/RichText").new(self.normalBg, cc.p(20, 15), cc.size(200, 30), cc.p(0, 0), 22, 20, MColor.lable_yellow)
    richText:addText(toolTipStr)
    richText:format()

	self.updateRichText = richText
end

function LotteryLayer:updateLuckUI()
	log("self.luck = "..tostring(self.luck))
	log("self.luckId = "..tostring(self.luckId))
	log("self.luckCount = "..tostring(self.luckCount))
	log("self.luckFreshCount = "..tostring(self.luckFreshCount))
	log("self.luckTime = "..tostring(self.luckTime))
	if self.luckItem then
		removeFromParent(self.luckItem)
		self.luckItem = nil
	end

	if self.luckId then
		local Mprop = require("src/layers/bag/prop")
		self.luckItem = Mprop.new({cb = "tips", protoId = self.luckId, num = self.luckCount})
		self.specialBg:addChild(self.luckItem)
		self.luckItem:setAnchorPoint(cc.p(0.5, 0.5))
	    self.luckItem:setPosition(cc.p(325, 200))
	    self.luckItem:setScale(0.9)
	    createSprite(self.luckItem, "res/group/arrows/5.png", cc.p(-10, self.luckItem:getContentSize().height/2), cc.p(1, 0.5))
	end

	local function updateLuckFont()
		for i=1,4 do
	    	if self.luck >= (4/4 * i) then
	    		print("removeColorGray i = "..i)
	    		self.fontIcon[i]:removeColorGray()
	    	else
	    		if self.luckOld and self.luckOld < (4/4 * i) then

	    		end
	    		self.fontIcon[i]:addColorGray()
	    	end
	    end

	    if self.luck >= 4 then
	    	self.changeBtn:setVisible(true)
	    else
	    	self.changeBtn:setVisible(false)
	    end
	end
    updateLuckFont()

    local updateLuckTimeStr = function(passTime, passTimeTotal)
    	--log("test 1")
    	if self.luckTime and self.luckTimeLabel then
    		--log("test 2")
    		self.luckTime = self.luckTime - passTime
    		if self.luckTime < 0 then
    			self.luckTime = 0
    			self.luckTimeTipLabel:setVisible(false)
    			self.luckTimeLabel:setVisible(false)

    			self.luck = 0
    			updateLuckFont()

    		else
    			self.luckTimeTipLabel:setVisible(true)
    			self.luckTimeLabel:setVisible(true)
    		end
    		--log("test 3")
	    	local timeStr = string.format("%02d", math.floor(self.luckTime/3600))..":"..string.format("%02d", (math.floor(self.luckTime/60)%60))..":"..string.format("%02d", (self.luckTime%60))
	    	--dump(timeStr)
	    	self.luckTimeLabel:setString(timeStr)
	    end
   	end

    if self.luckTimeLabel == nil then
    	self.luckTimeTipLabel = createLabel(self.specialBg, game.getStrByKey("lotteryEx_tip_font_keep"), cc.p(45, 235), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_yellow)
    	self.luckTimeTipLabel:setVisible(false)
    	self.luckTimeLabel = createLabel(self.specialBg, "", cc.p(175, 235), cc.p(0, 0.5), 20, true, nil, nil, MColor.white)
    	startTimerActionEx(self, 1, true, updateLuckTimeStr)
    	if self.luckTime <= 0 then
			self.luckTime = 0
			self.luckTimeLabel:setVisible(false)
		end
    end

    local updateFreeTimeStr = function(passTime, passTimeTotal)
    	--log("test 1")
    	if self.freeTime and self.freeTimeLabel then
    		--log("test 2")
    		self.freeTime = self.freeTime - passTime
    		local removeChildByTag = function(tag)
    			if self.summonOneBtn:getChildByTag(tag) then
    				self.summonOneBtn:removeChildByTag(tag)
    			end
    		end
    		removeChildByTag(100)
    		removeChildByTag(101)
    		removeChildByTag(102)
    		if self.freeTime < 0 then
    			self.freeTime = 0
    			--self.freeTimeTipLabel:setVisible(false)
    			self.freeTimeLabel:setVisible(false)
    			self.freeTimeTipLabel:setVisible(false)
    -- 			local labelUp = createLabel(self.summonOneBtn, game.getStrByKey("lotteryEx_btn_one"), cc.p(self.summonOneBtn:getContentSize().width/2, self.summonOneBtn:getContentSize().height/2), cc.p(0.5, 0), 18, true)
				-- labelUp:setTag(100)
				local labelDown = createLabel(self.summonOneBtn, game.getStrByKey("lotteryEx_btn_one_no_money"), cc.p(self.summonOneBtn:getContentSize().width/2, 70), cc.p(0.5, 0), 20, true, nil, nil, MColor.yellow)
				labelDown:setTag(101)
				self.oneIcon:setVisible(false)
				self.oneLabel:setVisible(false)
				local redTag = createSprite(self.summonOneBtn, "res/component/flag/red.png", cc.p(self.summonOneBtn:getContentSize().width-20, 5), cc.p(0.5, 0.5))
				redTag:setTag(102)
				if TOPBTNMG then TOPBTNMG:showRedMG( "Lotter" , true ) end
    		else
    			--self.freeTimeTipLabel:setVisible(true)
    			self.freeTimeLabel:setVisible(true)
    			self.freeTimeTipLabel:setVisible(true)
    -- 			local labelUp = createLabel(self.summonOneBtn, game.getStrByKey("lotteryEx_btn_one"), cc.p(self.summonOneBtn:getContentSize().width/2, self.summonOneBtn:getContentSize().height/2+1), cc.p(0.5, 0), 18, true)
				-- labelUp:setTag(100)
				-- local labelDown = createLabel(self.summonOneBtn, game.getStrByKey("lotteryEx_btn_one_money"), cc.p(self.summonOneBtn:getContentSize().width/2, self.summonOneBtn:getContentSize().height/2-1), cc.p(0.5, 1), 18, true, nil, nil, MColor.yellow)
				-- labelDown:setTag(101)
				self.oneIcon:setVisible(true)
				self.oneLabel:setVisible(true)
				removeChildByTag(102)
				if TOPBTNMG then TOPBTNMG:showRedMG( "Lotter" , false ) end
    		end
    		--log("test 3")
	    	local timeStr = string.format("%02d", math.floor(self.freeTime/3600))..":"..string.format("%02d", (math.floor(self.freeTime/60)%60))..":"..string.format("%02d", (self.freeTime%60))
	    	--dump(timeStr)
	    	self.freeTimeLabel:setString(timeStr)
	    end
   	end

    if self.freeTimeLabel == nil then
    	--self.freeTimeTipLabel = createLabel(self.specialBg, game.getStrByKey("lotteryEx_btn_one_next_no_money"), cc.p(555-5, 15), cc.p(1, 0.5), 20, true, nil, nil, MColor.yellow)
    	--self.freeTimeTipLabel:setVisible(false)
    	self.freeTimeLabel = createLabel(self.specialBg, "", cc.p(55, 15), cc.p(0, 0), 20, true, nil, nil, MColor.white)
    	self.freeTimeTipLabel = createLabel(self.specialBg, game.getStrByKey("lotteryEx_time_free"), cc.p(145, 15), cc.p(0, 0), 20, true, nil, nil, MColor.lable_yellow)
    	updateFreeTimeStr(0)
    	startTimerActionEx(self, 1, true, updateFreeTimeStr)

    	if self.freeTime <= 0 then
			self.freeTime = 0
			self.freeTimeLabel:setVisible(false)
			self.freeTimeTipLabel:setVisible(false)
		end
    end
end

function LotteryLayer:addFontShowAction(node)
end

function LotteryLayer:createGetShow(id)
	local layer = cc.Layer:create()
	self:addChild(layer)
	local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.8))
	layer:addChild(masking)

	local light = cc.Sprite:create("res/layers/role/light.png")
    layer:addChild(light)
    light:setPosition(cc.p(display.cx, display.cy))
	light:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.1, 6)))

	local Mprop = require("src/layers/bag/prop")
	local icon = Mprop.new({protoId = id})
	layer:addChild(icon)
	icon:setAnchorPoint(cc.p(0.5, 0.5))
    icon:setPosition(cc.p(display.cx, display.cy))
    icon:setScale(0.1)

	icon:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.2, 2), cc.FadeIn:create(0.2)), cc.ScaleTo:create(0.2, 1.5), cc.CallFunc:create(function() createLabel(layer, "已领取至背包", cc.p(display.cx, display.cy-80), cc.p(0.5, 0.5), 28, true, nil, nil, MColor.white) end)))

	layer:runAction(cc.Sequence:create(cc.DelayTime:create(4), cc.FadeOut:create(1), cc.CallFunc:create(function() removeFromParent(layer) end)))

	local  listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(function(touch, event)
    		return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
    		removeFromParent(layer)
        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = layer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, layer)
end

function LotteryLayer:networkHander(buff, msgid)
	local switch = {
		[LOTTERY_SC_SUMMON] = function()
			print("get LOTTERY_SC_SUMMON")
			local summonType = buff:popInt()
			if summonType == 1 or summonType == 4 then
				self.summonType = SUMMON_TYPE_NORMAL
			elseif summonType == 2 or summonType == 3 then
				self.summonType = SUMMON_TYPE_SPECIAL
			end
			self.luckOld = self.luck
			self.luck = buff:popInt()
			self.luckTime = buff:popInt()
			self.freeTime = buff:popInt()
			--print("self.freeTime = "..tostring(self.freeTime))
			local num = buff:popInt()
			print("self.luck = "..tostring(self.luck))
			print("num = "..tostring(num))
			self.data = {}
			for i=1,num do
				local id = buff:popInt()
				local num = buff:popInt()
				table.insert(self.data, {id=id, num=num})
			end
			dump(self.data)

			self:createSummonShow()
			self:updateLuckUI()
			self:updateToolTip()
		end
		,
		[LOTTERY_SC_RET] = function()
			print("get LOTTERY_SC_RET")
			self.luck = buff:popInt()
			self.luckId = buff:popInt()
			self.luckCount = buff:popInt()
			self.luckFreshCount = buff:popInt()
			self.luckTime = buff:popInt()
			self.freeTime = buff:popInt()
			--print("self.freeTime = "..tostring(self.freeTime))

			self:updateLuckUI()
		end
		,
		[LOTTERY_SC_REFRESH] = function()
			print("get LOTTERY_SC_REFRESH")
			self.luckId = buff:popInt()
			self.luckCount = buff:popInt()
			self.luckFreshCount = buff:popInt()
			self.luck = buff:popInt()
			self.luckTime = buff:popInt()

			self:updateLuckUI()
		end
		,
		[LOTTERY_SC_REWARD] = function()
			print("get LOTTERY_SC_REWARD")
			self:createGetShow(self.luckId)
			self.luck = buff:popInt()
			self.luckTime = buff:popInt()
			self.luckId = buff:popInt()
			self.luckCount = buff:popInt()

			self:updateLuckUI()
		end
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return LotteryLayer