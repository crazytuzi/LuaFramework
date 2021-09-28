local BabyRefreshLayer = class("BabyRefreshLayer", function() return cc.Layer:create() end)

local path = "res/baby/"
local RET_SUCESS = 1
local RET_FAILED = 2
local RET_DOWN = 3

function BabyRefreshLayer:ctor(data)
	self.data = data
	self.school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)
	self.materialNumCost = 1
	self.materialNum = 0
	self.materialId = 1106
	self.moneyCost = 100000
	self.isShowMessageBox = true--getLocalRecord("babyRefreshConfirm") or true

	local msgids = {BABY_SC_CHANGEQUALITY_RET}
	require("src/MsgHandler").new(self, msgids)

	local bg = createSprite(self, "res/common/4-1.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	local bgImage = createSprite(bg, path.."8.png", cc.p(bg:getContentSize().width/2, 40), cc.p(0.5, 0))
	--local titileBg = createSprite(bg, "res/common/1.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height-5), cc.p(0.5, 0.5))
	createLabel(bg, game.getStrByKey("baby_refresh"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-38), cc.p(0.5, 0.5), 24, true)

	function closeFunc()
		removeFromParent(self)
	end
	local closeBtn = createMenuItem(bg, "res/common/13.png", cc.p(bg:getContentSize().width-20 ,bg:getContentSize().height-20), closeFunc)
	closeBtn:setScale(0.8)

	local levelBg = createSprite(bg, path.."7.png", cc.p(bg:getContentSize().width/2, 210), cc.p(0.5, 0))
	self.levelBg = levelBg
	local help = __createHelp(
	{
		parent = bg,
		str = require("src/config/PromptOp"):content(21),
		pos = cc.p(100, 90),
	})
	self.levelTitle = createSprite(levelBg, path.."level_ex_"..self.data.quality..".png", cc.p(levelBg:getContentSize().width/2, 120), cc.p(0.5, 0), nil, 1)

	function refreshFunc()
		log("refreshFunc")

		function yesCallback() 
			self:addEffect()
			startTimerAction(self, 0.5, false, function() 
					--g_msgHandlerInst:sendNetDataByFmtExEx(BABY_CS_CHANGEQUALITY, "ic", G_ROLE_MAIN.obj_id, 0)
					--addNetLoading(BABY_CS_CHANGEQUALITY, BABY_SC_CHANGEQUALITY_RET)
				end)
		end

		if self.isShowMessageBox then
			self:messageBox(nil, game.getStrByKey("baby_refresh_tip"), yesCallback, nil, nil, nil, game.getStrByKey("ping_btn_no_more"))
		else
			yesCallback()
		end
	end
	local refreshBtn = createMenuItem(bg, "res/component/button/4.png", cc.p(585, 90), refreshFunc)
	self.refreshBtn = refreshBtn
	createLabel(refreshBtn, game.getStrByKey("baby_refresh_button"), getCenterPos(refreshBtn), cc.p(0.5, 0.5), 22, true)

	createLabel(bg, game.getStrByKey("baby_refresh_material"), cc.p(245, 130), cc.p(0, 0), 20, true, nil, nil, MColor.white)
	local icon = createPropIcon(bg, self.materialId, true, false)
	self.icon = icon
	icon:setScale(0.8)
	icon:setAnchorPoint(cc.p(0.5, 0))
	icon:setPosition(cc.p(365, 130))
	self.materialLabel = createLabel(bg, "", cc.p(410, 140), cc.p(0, 0.5), 22, true)

	-- createLabel(bg, game.getStrByKey("baby_refresh_monney"), cc.p(225, 90), cc.p(0, 0.5), 20, true, nil, nil, MColor.white)
	-- self.moneyLabel = createLabel(bg, "", cc.p(320, 90), cc.p(0, 0.5), 22, true)

	self:updateData()

	registerOutsideCloseFunc(bg, closeFunc)
	--self:addEffect(true)
end

function BabyRefreshLayer:updateData()
	self:updateUI()
end

function BabyRefreshLayer:updateUI()
	local bag = MPackManager:getPack(MPackStruct.eBag)
	self.materialNum = bag:countByProtoId(self.materialId)

	local color = MColor.green
	if self.materialNum >= self.materialNumCost then
		color = MColor.green
	else
		color = MColor.red
	end
	self.materialLabel:setString(self.materialNumCost.."/"..self.materialNum)
	self.materialLabel:setColor(color)

	-- local MRoleStruct = require("src/layers/role/RoleStruct")
	-- local money = MRoleStruct:getAttr(PLAYER_MONEY)
	-- if money > self.moneyCost then
	-- 	color = MColor.green
	-- else
	-- 	color = MColor.red
	-- end
	-- self.moneyLabel:setString(self.moneyCost)
	-- self.moneyLabel:setColor(color)

	self.levelTitle:setTexture(path.."level_ex_"..self.data.quality..".png")
	self:addAttInfo()
end

function BabyRefreshLayer:addAttInfo()
	self.levelBg:removeChildByTag(10)

	local attRecord = getConfigItemByKeys("BabyQualityDB", {"q_level", "q_school"}, {self.data.quality, self.school})
	dump(attRecord)
	local attNode = createAttNode(attRecord, 20, MColor.green)
	self.levelBg:addChild(attNode)
	--attNode:setAnchorPoint(cc.p(0, 1))
	attNode:setPosition(cc.p(80, 10))
	attNode:setTag(10)
	dump(attNode:getContentSize())
end

function BabyRefreshLayer:addEffect(isUp)
	if isUp then
		local animate = Effects:create(true)
		animate:setCleanCache()
		animate:playActionData("babyState", 14, 1, 1)
		self.levelBg:addChild(animate)
		animate:setPosition(getCenterPos(self.levelBg))
	else
		local animate = Effects:create(true)
		animate:setCleanCache()
		animate:playActionData("babyRefresh", 7, 0.8, 1)
		self.icon:addChild(animate)
		animate:setPosition(getCenterPos(self.icon))

		-- startTimerAction(self, 0.5, false, function() 
		-- 		local maskLayer = createMaskingLayer(1.5)
		-- 		self:addChild(maskLayer)
		-- 	end)
	end
end

function BabyRefreshLayer:messageBox(title, text, yesCallback, noCallback, yesText, noText, checkText)
	local retSprite = cc.Sprite:create("res/common/5.png")
	local titleBg = createSprite(retSprite, "res/common/1.png", cc.p(retSprite:getContentSize().width/2, retSprite:getContentSize().height - 38))
	createLabel(titleBg, game.getStrByKey("tip"), cc.p(titleBg:getContentSize().width/2, titleBg:getContentSize().height/2), nil, 22, true)

	local contentRichText = require("src/RichText").new(retSprite, cc.p(retSprite:getContentSize().width/2, retSprite:getContentSize().height/2 + 40), cc.size(retSprite:getContentSize().width-90, 60), cc.p(0.5, 0.5), 25, 20, MColor.white)
	contentRichText:addText(text, MColor.white)
	contentRichText:format()

	local funcYes = function()
		local removeFunc = function()
		    if retSprite then
		        removeFromParent(retSprite)
		        retSprite = nil
		    end
		end
		if yesCallback then
			yesCallback()
		end
		if retSprite then
			retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0), cc.CallFunc:create(removeFunc)))	
		end
	end

	local funcNo = function()
		local removeFunc = function()
		    if retSprite then
		        removeFromParent(retSprite)
		        retSprite = nil
		    end
		end
		if noCallback then
			noCallback()
		end
		if retSprite then
			retSprite:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0), cc.CallFunc:create(removeFunc)))	
		end
	end

	local menuItem = createMenuItem(retSprite,"res/component/button/15.png",cc.p(126,90),funcYes)
	if not yesText then
		createSprite(menuItem, "res/common/7.png", cc.p(82,26))
	else
		createLabel(menuItem,yesText,cc.p(82,26),nil,21,true)
	end
	if G_TUTO_NODE then G_TUTO_NODE:setTouchNode(menuItem, TOUCH_CONFIRM_YES) end

	local menuItem = createMenuItem(retSprite,"res/component/button/14.png",cc.p(346,90),funcNo)
	if not noText then
		createSprite(menuItem, "res/common/8.png", cc.p(82,26))
	else
		createLabel(menuItem,noText,cc.p(82,26),nil,21,true)
	end

	Director:getRunningScene():addChild(retSprite,10000)
	retSprite:setPosition(cc.p(display.cx, display.cy))

	local checkBoxCallBack = function()
		if self.checkBox then
			if self.checkBox:getChildByTag(10) == nil then
				local check = createSprite(self.checkBox, "res/component/checkbox/2.png", getCenterPos(self.checkBox), cc.p(0.5, 0.5))
				check:setTag(10)
				self.isShowMessageBox = false
			else
				self.checkbox:removeChildByTag(10)
				self.isShowMessageBox = true
			end
		end
		setLocalRecord("babyRefreshConfirm", self.isShowMessageBox)
	end
	self.checkBox = createTouchItem(retSprite, "res/component/checkbox/1.png", cc.p(retSprite:getContentSize().width/2-50, 35), checkBoxCallBack)
	createLabel(self.checkBox, game.getStrByKey("ping_btn_no_more"), getCenterPos(self.checkBox, 30), cc.p(0, 0.5), 20, true, nil, nil, MColor.white)

	SwallowTouches(retSprite)

	if G_TUTO_NODE then G_TUTO_NODE:setShowNode(retSprite, SHOW_CONFIRM) end
	retSprite:registerScriptHandler(function(event)
		if event == "enter" then
			G_TUTO_NODE:setShowNode(retSprite, SHOW_CONFIRM)
		elseif event == "exit" then

		end
	end)
	retSprite:setScale(0.01)
    retSprite:runAction(cc.ScaleTo:create(0.1, 1))
end

function BabyRefreshLayer:networkHander(buff, msgid)
	local switch = {
		[BABY_SC_CHANGEQUALITY_RET] = function()
			log("get BABY_SC_CHANGEQUALITY_RET")
			local ret = buff:popChar()
			local newQuality = buff:popChar()
			
			if ret == RET_SUCESS then
				self.data.quality = newQuality
				local qualityName = getConfigItemByKeys("BabyQualityDB", {"q_level", "q_school"}, {self.data.quality, self.school}, "q_name")
				self:getParent():updateQuality(self.data.quality)
				startTimerAction(self, 1, false, function() TIPS({type=1, str=string.format(game.getStrByKey("baby_quality_success"), qualityName)}) end) 
				startTimerAction(self, 0, false, function() self:addEffect(true) end) 
			elseif ret == RET_FAILED then
				TIPS({type=1, str=game.getStrByKey("baby_quality_failed")})--MessageBox(game.getStrByKey("baby_quality_failed"))
			elseif ret == RET_DOWN then
				self.data.quality = newQuality
				local qualityName = getConfigItemByKeys("BabyQualityDB", {"q_level", "q_school"}, {self.data.quality, self.school},  "q_name")
				TIPS({type=1, str=string.format(string.format(game.getStrByKey("baby_quality_down"), qualityName))})--MessageBox(string.format(game.getStrByKey("baby_quality_down"), qualityName))
				self:getParent():updateQuality(self.data.quality)
			end

			self:updateData()
		end
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return BabyRefreshLayer