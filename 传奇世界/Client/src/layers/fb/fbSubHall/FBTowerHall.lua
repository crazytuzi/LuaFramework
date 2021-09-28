local FBTowerHall = class("FBTowerHall", function() return cc.Layer:create() end)
local PrizeLayer = class("PrizeLayer", require("src/TabViewLayer"))
local sweepRewardList = class("sweepRewardList", require("src/TabViewLayer"))
local comPath = "res/fb/tower/"
local MRoleStruct = require("src/layers/role/RoleStruct")
local sweepOneTime = 10
local MPropOp = require "src/config/propOp"

function FBTowerHall:ctor(index)
	--createReloadBtn("src/layers/fb/fbSubHall/FBTowerResult")
	--createReloadBtn("src/layers/fb/fbSubHall/FBTowerHall")
	--createReloadBtn("src/base/FBFlopLayer")

	--数据初始化
	self.friendNum = 0
	self.selFriendIdx = 0
	self.friendData = {}
	self.maxRestTime = 1

	self.netData = {maxTower = 0 , towerCd = 0, copyInfo = {}, copyStarPrizeNum = 0, sweepReward = {}}
	self.fbData = getConfigItemByKey("FBTower", "q_id")
	--dump(self.fbData)


	g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETCOPYTOWERDATA, "CopyGetTowerDataProtocol", {})
	addNetLoading(COPY_CS_GETCOPYTOWERDATA, COPY_SC_GETCOPYTOWERDATA_RET)
	--g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETFRIENDDATA,"CopyGetFriendDataProtocol", {})

	local msgids = {COPY_SC_GETCOPYTOWERDATA_RET, COPY_SC_CLEARINNERCDRET, COPY_SC_GETCOPYSTARPRIZE_RET, 
	                COPY_SC_VIPRESTCOPYCDRET, COPY_SC_STARTPROGRESSRET, COPY_SC_RESETTOWERCOPY,
	                COPY_SC_GETFRIENDDATARET, COPY_SC_FINISH_PROGRESS_ONE, COPY_SC_START_PROGRESS_ONE,
	                COPY_SC_NOTIFYPROREWARD, COPY_SC_GETPROREWARDLISTRET}
    require("src/MsgHandler").new(self,msgids)	

	local bg = createBgSprite(self, game.getStrByKey("fb_tianguan"))

	--local midBg = createSprite(bg , "res/common/bg/bg-6.png" , cc.p( 15, 25) , cc.p( 0 , 0 ))

	local towerbg = createSprite(bg, comPath .. "towBg.png", cc.p(32, 38), cc.p( 0 , 0 ))
	self.bg = towerbg

	local rightBg = createSprite(towerbg, "res/common/bg/infoBg11.png", cc.p(754, towerbg:getContentSize().height/2))
	
	self.rightCenter = getCenterPos(rightBg)
	local rightNode1 = cc.Node:create()
	rightBg:addChild(rightNode1,2)
	local rightNode2 = cc.Node:create()
	rightBg:addChild(rightNode2,2)

	self.rightNode1 = rightNode1
	self.rightNode2 = rightNode2
    
    createSprite(rightBg, COMMONPATH.."bg/titleLine.png", cc.p(self.rightCenter.x, 463), cc.p(0.5, 0.5))
    createSprite(self.bg, comPath.."line.png", cc.p(285, 75), nil , 2)
	
	self:addBottomBtn()
	self:addRightBtn()
	--self:testTowerResult()
end

function FBTowerHall:addBottomBtn()
	local fun1 = function()
		self:clearLocalTowerSweepInfo()
		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_PROGRESSALL, "ProgressAllCopyProtocol", {copyType = 2})
	end

	local fun2 = function()
		local func = function()
			if self.netData.curTower == 1 then
				TIPS( { str = "当前进度不需要重置通天塔!"})
				return
			elseif self.maxRestTime - self.netData.restTime <= 0 then
				TIPS( { str = "您已经没有重置次数!"})
				return			
			end
			g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_RESETTOWERCOPY, "CopyTowerProgressCtrlProtocol", {})
			addNetLoading(COPY_CS_RESETTOWERCOPY, COPY_SC_RESETTOWERCOPY)
		end
		local str = "是否重置通天塔？"
		MessageBoxYesNo(nil, str, func)
	end

	local fun3 = function()
		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_TOWER_PROGRESS_CONTROL, "CopyTowerProgressCtrlProtocol", {ctrlType = 1})
	end

	local fun4 = function()
		local func = function()
			g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_TOWER_PROGRESS_CONTROL, "CopyTowerProgressCtrlProtocol", {ctrlType = 2})
		end

		local str = "是否花费25元宝立即完成通天塔扫荡？"
		MessageBoxYesNo(nil, str, func)
	end

	local item = createMenuItem(self.bg, "res/component/button/49.png", cc.p(285 - 100, 38), fun1)
	createLabel(item, "一键扫荡", getCenterPos(item), nil, 22, true, 10)
	item:setEnabled(true)
	self.progressBtn = item

	local item = createMenuItem(self.bg, "res/component/button/49.png", cc.p(285 + 100, 38), fun2)
	local lab = createLabel(item, "重置(1/1)", getCenterPos(item), nil, 22, true, 10)
	self.restBtnLab = lab
	item:setEnabled(false)
	self.restBtn = item

	local str = game.getStrByKey("fb_leftTime") .. "0" .. game.getStrByKey("sec")
	local label = createLabel(self.bg, str, cc.p(15, 38), cc.p(0, 0.5), 20, true)
	self.sweepLabel = label

	local item = createMenuItem(self.bg, "res/component/button/49.png", cc.p(320, 38), fun3)
	createLabel(item, "停止扫荡", getCenterPos(item), nil, 22, true, 10)
	item:setVisible(false)
	self.stopSweep = item

	local item = createMenuItem(self.bg, "res/component/button/49.png", cc.p(480, 38), fun4)
	createLabel(item, "立即完成", getCenterPos(item), nil, 22, true, 10)
	item:setVisible(false)
	self.overSweep = item
end

function FBTowerHall:showBoxEff( )
	local tempData = self.netData.copyStarPrize
	local isShow = false
	for i=1, self.netData.copyStarPrizeNum do
		if tempData and tempData[i].copyStarIndex <= self.netData.maxTower then
			if tempData[i].prizeGotTag ~= 1 then
				isShow = true
				break
			end
		else
			break
		end
	end

	if self.BoxBtn then
		local tempNode = self.BoxBtn:getChildByTag(50)
		if tempNode then
			removeFromParent(tempNode)
		end		
		if isShow then
			local tempNode = cc.Node:create()
			self.BoxBtn:addChild(tempNode, 2, 50)
			setNodeAttr( tempNode, cc.p( self.BoxBtn:getContentSize().width/2 , self.BoxBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) )

			local eff = Effects:create(false)
			eff:playActionData( "gold" , 10 , 2 , -1 )
			addEffectWithMode(eff,1)
			tempNode:addChild( eff )
		end
	end
end

function FBTowerHall:addTowerLayer( )
	local hight = 420 - 30
	local layerBtnCfg = {{ pos = cc.p(80 , 165 - 83), star = { {65, 40}, {115, 70} } },
						 { pos = cc.p(280, 265 - 83), star = { { 100, 0} } },
						 { pos = cc.p(485, 265 - 83), star = { {0, 80} } },
						 { pos = cc.p(485, 440 - 83), star = { {-105, 0} } },
						 { pos = cc.p(280, 440 - 83), star = { {-65, 30}, {-115, 70} } },
						}
	local maxTower = (self.netData.curTower > self.netData.maxTower) and self.netData.curTower or self.netData.maxTower
	local num = maxTower > 5 and maxTower or 5
	local allLayerNum = self.netData.copyNum
	num = ((num % 5 > 0 and 1 or 0) + math.floor(num / 5))*5
	num = num < allLayerNum and num or allLayerNum

	local layerHeight, currTowerHeight = 0, 0
	local layer = cc.Layer:create()
	for i=1, num do
		local index = allLayerNum - i + 1
		local layerData = self.netData.copyInfo[index]
		local cfgIndex = math.floor(i % 5)
		cfgIndex = (cfgIndex == 0 and 5 or cfgIndex)
		local LayerCfg = layerBtnCfg[cfgIndex]
		local layerNum = i

		local offsetY = math.floor((i - 1) / 5) * hight
		local bgImgStr = comPath .. "layerBg.png"
		if layerNum == self.netData.curTower then
			bgImgStr = comPath .. "layerBg1.png"
		elseif layerNum > self.netData.curTower then
			bgImgStr = comPath .. "layerBg_un.png"
		end
		local btn = createSprite(layer, bgImgStr, cc.p(LayerCfg.pos.x ,LayerCfg.pos.y + offsetY))
		local btnSize = btn:getContentSize()

		local str = string.format(game.getStrByKey("fb_layer"), layerNum)
		createLabel(btn, str, cc.p(btnSize.width/2, 3), nil, 22, true):setColor(MColor.lable_yellow)

		--通关标识
	    -- if layerNum %5 == 0 then
	    -- 	local path = "res/fb/tower/box2.png"
	    -- 	if layerNum >= self.netData.curTower then
	    -- 		path = "res/fb/tower/box1.png"
	    -- 	end
	    -- 	local ret = createSprite(btn, path, getCenterPos(btn, -10, 32))
	    -- 	ret:setScale(0.83)
	    -- else
	    if layerNum < self.netData.curTower then
	    	createSprite(btn, comPath .. "status_2.png", getCenterPos(btn, 0, 24))
	    else
	    	createSprite(btn, comPath .. "status_1.png", getCenterPos(btn, 0, 24))
	    end

	    --当前挑战关特效
	    if layerNum == self.netData.curTower then
	    	local eff = Effects:create(false)
			eff:playActionData( "towerattack" , 10 , 2 , -1 )
			addEffectWithMode(eff, 3)
			btn:addChild( eff )
			eff:setAnchorPoint(cc.p(0.5, 0.5))
			eff:setPosition(cc.p(60, 40))
	    end

	    --路径
	    if layerNum < self.netData.curTower and layerNum ~= allLayerNum then
	    	for i=1,#LayerCfg.star do
	    		--dump(LayerCfg.star, "LayerCfg.star")
	    		local bg = createSprite(btn, comPath .. "star1.png", cc.p(56 + LayerCfg.star[i][1], 40 + LayerCfg.star[i][2]))
	    		if layerNum < self.netData.curTower then
	    			createSprite(bg, comPath .. "star2.png", getCenterPos(bg, 0 , 16))
	    		end
	    	end
	    end

	    local curLayer = self.netData.curTower
	    curLayer = curLayer < num and curLayer or num
	    if layerNum == curLayer then
	    	currTowerHeight = LayerCfg.pos.y + offsetY - 70
	    end

	    layerHeight = LayerCfg.pos.y + offsetY + 75
	end
	layer:setContentSize(cc.size(560, layerHeight))

	return layer, currTowerHeight 
end

function FBTowerHall:addRightBtn()
	local boxFunc = function()
		if not self.sPrizeLayer then
			self.sPrizeLayer = PrizeLayer.new(self)
			Manimation:transit(
			{
				ref = self.bg,
				node = self.sPrizeLayer,
				curve = "-",
				sp = getCenterPos(self.bg),
				zOrder = 200,
				swallow = true,
			})
		else
			self.sPrizeLayer:getTableView():reloadData()
		end
	end
	self.BoxBtn = createMenuItem(self.rightNode1, "res/fb/defense/boxCan1.png", cc.p(50, 140), boxFunc)
	createLabel(self.rightNode1, game.getStrByKey("fb_awardBox"), cc.p(215, 140-15), nil, 18):setColor(MColor.lable_black)
	local spr = createSprite(self.rightNode1, "res/group/arrows/17-1.png", cc.p(self.rightCenter.x, 140 - 15))
	spr:setScale(0.7)

	local item = createMenuItem(self.rightNode1, "res/component/button/2.png", cc.p(self.rightCenter.x, 45), function() self:gotoBattle() end)
	createLabel(item, "开始挑战", getCenterPos(item), nil, 22, true)
end

function FBTowerHall:currLayerInfo()
	--print("FBTowerHall:currLayerInfo begin")
	self.rightNode1:removeChildByTag(105)

	local tempBg = cc.Node:create()
	self.rightNode1:addChild(tempBg, 2 , 105)

	createLabel(tempBg, game.getStrByKey("fb_currLayer"), cc.p(self.rightCenter.x, 463), nil, 20):setColor(MColor.lable_yellow)

	local copyDbData = self.currentFbData
	if copyDbData then
		local layerNum = copyDbData.q_copyLayer or 1
		local offsetX1, offsetX2, offsetY1, offsetY2 = 20, 228, 405 + 15, 33
		local strCurLayer = string.format(game.getStrByKey("fb_layer"), layerNum)
		if self.netData.curTower > self.netData.copyNum then
			strCurLayer = game.getStrByKey("fb_isIntopLayer")
		end
		local strText = {{game.getStrByKey("fb_currPostion"), strCurLayer},
						 {game.getStrByKey("fb_suggestBattle"), "" .. (copyDbData.tjzdl or 0)},
						 {game.getStrByKey("fb_needLev"), "" .. (copyDbData.q_limit_level or 28)},						 
						}

		for i=1,#strText do
			createLabel(tempBg, strText[i][1], cc.p(offsetX1, offsetY1), cc.p(0, 0.5), 20, true):setColor(MColor.lable_yellow)
			local lab = createLabel(tempBg, strText[i][2], cc.p(offsetX1 + offsetX2, offsetY1), cc.p(1, 0.5), 20, true):setColor(MColor.white)
			if i == 3 then
				if MRoleStruct:getAttr(ROLE_LEVEL) < copyDbData.q_limit_level then
					lab:setColor(MColor.red)
				end
			end
			offsetY1 = offsetY1 - offsetY2			
		end

		createLabel(tempBg, game.getStrByKey("fb_awardText"), cc.p(offsetX1, offsetY1), cc.p(0, 0.5), 20):setColor(MColor.lable_yellow)
		local icon = nil
		local DropOp = require("src/config/DropAwardOp")

		local gdItem = DropOp:dropItem(tonumber(copyDbData.q_reward))
		local Mprop = require "src/layers/bag/prop"
		if gdItem then
			local cout = 1
			for m,n in pairs(gdItem) do
				if cout > 3 then 
					break
				end
				icon = Mprop.new(
				{
					protoId = tonumber(n.q_item),
					swallow = true,
					cb = "tips",
					showBind = true,
	            	isBind =  tonumber(n.bdlx or 0) == 1,					
				})
				icon:setPosition(cc.p(offsetX1 + (cout - 0.5) * 85, offsetY1 - 65))
				tempBg:addChild(icon)
				icon:setScale(0.98)
				cout = cout + 1
			end
		end
	end
	createSprite(tempBg, COMMONPATH .. "bg/infoBg11-3.png", cc.p(self.rightCenter.x, 190), cc.p(0.5,0.5))
	--print("FBTowerHall:currLayerInfo end")
end

function FBTowerHall:addScrollLayer()
	local width , height = 560 , 420 + 5
	local scrollBg = self.bg
	if scrollBg:getChildByTag(100) then
		scrollBg:removeChildByTag(100)
	end
    local scrollView1 = cc.ScrollView:create()
    local layerSize = nil
    scrollView1:setViewSize(cc.size( width , height ))
    scrollView1:setPosition( cc.p( 6 , 74 ) )
    scrollView1:setScale(1.0)
    scrollView1:ignoreAnchorPointForPosition(true)
    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    local layer,currTowerHeight = self:addTowerLayer()
    scrollView1:setContainer( layer )
    scrollView1:updateInset()
    --scrollView1:addSlider("res/common/slider.png")
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    scrollView1:setDelegate()

    scrollBg:addChild(scrollView1, 1 , 100)

    layerSize = layer:getContentSize()
    if layerSize.height - currTowerHeight > height then
    	scrollView1:setContentOffset( cc.p( 0 ,  -currTowerHeight) )
    else
    	scrollView1:setContentOffset( cc.p( 0 ,  height - layerSize.height ) )
    end
end

function FBTowerHall:changeBtnStatus()
	if self.netData.isSweeping then
		self.progressBtn:setVisible(false)
		self.restBtn:setVisible(false)

		self.sweepLabel:setVisible(true)
		self.stopSweep:setVisible(true)
		self.overSweep:setVisible(true)
	else
		self.progressBtn:setVisible(true)
		self.restBtn:setVisible(true)

		self.sweepLabel:setVisible(false)
		self.stopSweep:setVisible(false)
		self.overSweep:setVisible(false)		
	end

	if G_NO_OPEN_PAY then
		self.overSweep:setVisible(false)
		self.stopSweep:setPosition(cc.p(480, 38))
	end	

	local delFunc = function()
		if self.progressBtn then
			self.progressBtn:setEnabled(true)
		end

		if self.restBtn then
			if self.maxRestTime - self.netData.restTime <= 0 then
				self.restBtn:setEnabled(false)
			else
				self.restBtn:setEnabled(true)
			end
		end
	end

	performWithDelay(self, delFunc, 0.25)

	if self.restBtnLab then
		local timeLeft = (self.maxRestTime - self.netData.restTime) >= 0 and (self.maxRestTime - self.netData.restTime) or 0
		local str = string.format("重置(%d/1)", timeLeft)
		self.restBtnLab:setString(str)
	end
end

function FBTowerHall:gotoBattle()
	self:clearLocalTowerSweepInfo()
	if self.netData.curTower > self.netData.copyNum then
		TIPS({type = 1, str = game.getStrByKey("fb_TopLayer")})
	elseif self.selFriendIdx ~= 0 and self.friendData[self.selFriendIdx][7] > 0 then
		local yesCallback = function()
		   g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_CLEARFRITIME, "CopyClearFriendTimeProtocol", {friendSid = self.friendData[self.selFriendIdx][1]})
        end
		MessageBoxYesNo(game.getStrByKey("tip"),game.getStrByKey("task_d_b1")..self.friendData[self.selFriendIdx][8]..game.getStrByKey("fb_desc9"),yesCallback)
	else
		local copyDbData = self.currentFbData
	    if copyDbData then
			userInfo.lastFb = copyDbData.q_id
		 	setLocalRecordByKey(2, "subFbType", ""..userInfo.lastFb)
		 	userInfo.lastFbType = 3
		 	setLocalRecordByKey(2, "lastFbType", "3")

		 	if self.selFriendIdx == 0 then
		 		print("FRAME_SC_ENTITY_ENTER .. " .. 0)
		 		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol",{copyId = userInfo.lastFb, friendId = 0, isInCopy = 0})
				addNetLoading(COPY_CS_ENTERCOPY, FRAME_SC_ENTITY_ENTER)
		 	else
		 		local tempFriendId = self.friendData[self.selFriendIdx][1] or 0
		 		print("FRAME_SC_ENTITY_ENTER .. " .. tempFriendId)
		 		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_ENTERCOPY, "EnterCopyProtocol",{copyId = userInfo.lastFb, friendId = tempFriendId, isInCopy = 0})
				addNetLoading(COPY_CS_ENTERCOPY, FRAME_SC_ENTITY_ENTER)
			end
		end
	end	
end

function FBTowerHall:getLayerInfoByFbID(fbid)
	if not fbid then return 0, {} end

	for k,v in pairs(self.fbData) do
		if v.q_id == fbid then
			return v.q_copyLayer , v
		end
	end
	return 0, {}
end

function FBTowerHall:getLayerInfoByLayerNum( layerNum)
	if not layerNum then return self.fbData[1] end

	for k,v in pairs(self.fbData) do
		if v.q_copyLayer == layerNum then
			return v
		end
	end
	return self.fbData[1]
end

function FBTowerHall:sweepTower()
	if self.timeNode then
		self.timeNode:stopAllActions()
		removeFromParent(self.timeNode)
		self.timeNode = nil
	end

	local layerNum = self.netData.curTower
	if self.netData.isSweeping then
		layerNum = self.netData.nowSweepLayer
	end 	
	print("sweepTower", layerNum, tostring(self.netData.isSweeping))

    --如果打过最高层. 显示的信息是最高层的
    self.netData.curTower = (layerNum < 1) and 1 or layerNum
    local copyNum = self.netData.copyNum
    local tempCurTower = (self.netData.curTower > copyNum) and copyNum or self.netData.curTower
    self.currentFbData = self:getLayerInfoByLayerNum(tonumber(tempCurTower))
    
    self:changeBtnStatus()
	if self.netData.isSweeping then
		self.rightNode1:removeAllChildren()
		self:showSweepReward()
		self.BoxBtn = nil
		local layerNum = self.netData.maxCanSweepCopyLayer - self.netData.curTower
		layerNum = layerNum < 0 and 0 or layerNum

		local func = function(delTime)
			self.netData.sweepTime = self.netData.sweepTime - delTime
			if self.netData.sweepTime >= 0 then
				local timeNum = self.netData.sweepTime + layerNum * sweepOneTime
				local timeStr = game.getStrByKey("fb_leftTime") .. timeNum .. game.getStrByKey("sec")
				self.sweepLabel:setString(timeStr)
			end
		end

		self.timeNode = startTimerActionEx(self, 1, true, func)
		func(0)
	else
		if self.sweepList then
			removeFromParent(self.sweepList)
			self.sweepList = nil
		end

		if not self.BoxBtn then
			self:addRightBtn()
		end
		self:currLayerInfo()
		self:showBoxEff()
		--g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETFRIENDDATA,"CopyGetFriendDataProtocol", {})
	end

	self:addScrollLayer()
end

function FBTowerHall:showSweepReward()
	--dump(self.netData.sweepReward, "showSweepReward")
	if not self.sweepList then
		local sweepList = sweepRewardList.new(self)
		self.sweepList = sweepList
		self.rightNode2:addChild(sweepList)
	end
	self.sweepList:reloadData()
end

function FBTowerHall:testTowerResult()
	local towerEndData = {}
 	towerEndData.cardPrize = {64, 62, 63}
 	towerEndData.copyStar = 0
	towerEndData.fastName = ""
	towerEndData.fastTime = 0
	towerEndData.myTime = 0
	towerEndData.thisStar = 3
	towerEndData.thisTime = 7
	towerEndData.winPrize = 2
	towerEndData.awardData = {}
	towerEndData.isWin = true

	local ret = require("src/layers/fb/fbSubHall/FBTowerResult").new(towerEndData)
 	G_MAINSCENE:addChild(ret, 200)
end

function FBTowerHall:InitTowerSweepInfo()
	local strKey = "sweepTowerInfo" ..( userInfo.currRoleStaticId or 0 )
	if self.netData.isSweeping then
		local tempTable = getLocalRecordByKey(2, strKey, "{}")
		local tempSweepInfo = unserialize(tempTable)
		self.netData.sweepReward = self.netData.sweepReward or {}
		for k,v in pairs(tempSweepInfo) do
			local index = v.layerNum -- #self.netData.sweepReward + 1
			self.netData.sweepReward[index] = copyTable(v)
		end
	end
	--dump(self.netData.sweepReward, "InitTowerSweepInfo sweepReward")
end

function FBTowerHall:clearLocalTowerSweepInfo()
	local strKey = "sweepTowerInfo" ..( userInfo.currRoleStaticId or 0 )
	setLocalRecordByKey(2, strKey, "{}")
	self.netData.sweepReward = {}
end

function FBTowerHall:addSweepInfo(tempSweepInfo)
	local strKey = "sweepTowerInfo" ..( userInfo.currRoleStaticId or 0 )
	local str = getLocalRecordByKey(2, strKey, "{}")
	local recodeInfo = unserialize(str)
	for k,v in pairs(recodeInfo) do
		local index = v.layerNum -- #tempSweepInfo + 1
		tempSweepInfo[index] = copyTable(v)
	end
	str = serialize(tempSweepInfo)
	setLocalRecordByKey(2, strKey, str)
end

function FBTowerHall:networkHander(luabuffer, msgid)
	cclog("FBTowerHall:networkHander")
    local switch = {
        [COPY_SC_GETCOPYTOWERDATA_RET] = function() 
            cclog("COPY_SC_GETCOPYTOWERDATA_RET")
            local retTable = g_msgHandlerInst:convertBufferToTable("CopyGetTowerDataRetProtocol", luabuffer)

            --dump(retTable)
            self.netData ={}
            self.netData.totalStarNum = 0
            self.netData.copyInfo = {}
            
            local copyNum = retTable.copyNum
            self.netData.copyNum = copyNum

            local tempInfo = retTable.info
            for i = 1, copyNum do
            	self.netData.copyInfo[i] = {}
            	self.netData.copyInfo[i].fbID = tempInfo[i].copyId
            	self.netData.copyInfo[i].myBestTime = tempInfo[i].useTime
            	self.netData.copyInfo[i].bestTime = tempInfo[i].copyId
            	local fastInfo = tempInfo[i].info
            	
            	self.netData.copyInfo[i].bestName = ""
            	self.netData.copyInfo[i].bestBattle = 0
            	if fastInfo then
            		self.netData.copyInfo[i].bestTime = fastInfo.useTime or 0
            		if self.netData.copyInfo[i].bestTime > 0 then
		            	self.netData.copyInfo[i].bestName = fastInfo.name
		            	self.netData.copyInfo[i].bestBattle = fastInfo.battle            			
            		end
            	end
            	--self.netData.copyInfo[i].copyStar = tempInfo[i].getStarNum
            	--self.netData.totalStarNum = self.netData.totalStarNum + self.netData.copyInfo[i].copyStar
            end
            table.sort( self.netData.copyInfo, function(a, b) return a.fbID > b.fbID end)

            --现在变成了首通奖励
            self.netData.copyStarPrizeNum = retTable.starPrizeNum 
            local prizeInfo = retTable.starPrizeInfo
            self.netData.copyStarPrize = {}
            for i=1,self.netData.copyStarPrizeNum do
            	self.netData.copyStarPrize[i] = {}
            	self.netData.copyStarPrize[i].copyStarIndex = prizeInfo[i].starIndex
            	self.netData.copyStarPrize[i].prizeGotTag = prizeInfo[i].starNum
            end
            table.sort( self.netData.copyStarPrize, function(a, b) return a.copyStarIndex < b.copyStarIndex end)
	            
            self.netData.maxTower = retTable.maxLayer  --当前已通关的最大关数
			self.netData.curTower = retTable.curLayer  --当前能打到第几关
			self.netData.restTime = retTable.resetNum  --当前已经重置次数

			self.netData.isSweeping = retTable.nowProgress ~= 0 
			self.netData.sweepTime = retTable.nowProgressLeftTime
			self.netData.nowSweepLayer = 0
			self.netData.maxCanSweepCopyLayer = 0

			self.netData.maxCanSweepCopyLayer = self:getLayerInfoByFbID(retTable.maxCanProgressCopy)
			self.netData.nowSweepLayer = self:getLayerInfoByFbID(retTable.nowProgress)

        	print("netData", tostring(self.netData.isSweeping), tostring(retTable.maxCanProgressCopy), tostring(self.netData.nowSweepLayer), self.netData.curTower, self.netData.maxTower)

			DATA_Battle:setRedData( "TTT" , (self.netData.restTime == 0 ))

			--dump(self.netData, "self.netData")
			self:InitTowerSweepInfo()
			self:sweepTower()
        end,

        [COPY_SC_CLEARINNERCDRET] = function() 
            cclog("COPY_SC_CLEARINNERCDRET")

			self.netData.towerCd = 0
            self:addFbInfo()
        end,
        [COPY_SC_GETCOPYSTARPRIZE_RET] = function()
        	local retTable = g_msgHandlerInst:convertBufferToTable("CopyGetStarPrizeRetProtocol", luabuffer)

        	local roleid, starNum = retTable.roleId, retTable.prizeIndex
        	-- dump(starNum, "starNum")
        	-- dump(roleid, "roleid")
            for i=1, self.netData.copyStarPrizeNum do
            	if self.netData.copyStarPrize[i].copyStarIndex == starNum then
            		self.netData.copyStarPrize[i].prizeGotTag = 1
            		if self.sPrizeLayer then
            			self.sPrizeLayer:ChangeStarPrizeFlg(i)
            		end
            		break
            	end
            end
            self:showBoxEff()
        end,
        [COPY_SC_VIPRESTCOPYCDRET] = function ()
        	g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETCOPYTOWERDATA, "CopyGetTowerDataProtocol", {})
        end,
        [COPY_SC_STARTPROGRESSRET] = function ()
        	local retTable = g_msgHandlerInst:convertBufferToTable("StartProgressRetProtocol", luabuffer)
        	local fbid = retTable.copyId
        	local time = retTable.fastTime
        	local layerNum = self:getLayerInfoByFbID(fbid)
        	
        	print("COPY_SC_STARTPROGRESSRET:fbid = " .. fbid .. ",time = ".. time)
        	performWithDelay(self, function()
        							TIPS({str = string.format(game.getStrByKey("fb_sweepEnd"), layerNum)}) 
        							g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETCOPYTOWERDATA, "CopyGetTowerDataProtocol", {})
        							end,
							time)
        end,
        [COPY_SC_RESETTOWERCOPY] = function()
        	local retTable = g_msgHandlerInst:convertBufferToTable("CopyResetTowerCopyRetProtocol", luabuffer)
        	local roleid = retTable.roleId
    		local ret = retTable.result
    		print("ret .. ".. ret)
    		if ret == 0 then
				g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETCOPYTOWERDATA, "CopyGetTowerDataProtocol", {})
				addNetLoading(COPY_CS_GETCOPYTOWERDATA, COPY_SC_GETCOPYTOWERDATA_RET)
			elseif ret == -1 then
				TIPS( { str = "您已经没有重置次数!"})
			elseif ret == -2 then
				TIPS( { str = "当前进度不需要重置通天塔!"})
    		end
    	end,
    	
        [COPY_SC_FINISH_PROGRESS_ONE] = function()
        	local retTable = g_msgHandlerInst:convertBufferToTable("CopyTowerFinishProgressOneProtocol", luabuffer)
        	if retTable.copyType and retTable.copyType == 2 then
        		--dump(retTable)
        		local copyId = retTable.copyId or 0
        		self.netData.sweepTime = 0
        		local layerNum = self:getLayerInfoByFbID(copyId)
        	
        		self.netData.sweepReward = self.netData.sweepReward or {}
        		if layerNum ~= 0 then
        			local index = layerNum
        			self.netData.sweepReward[index] = {}
        			self.netData.sweepReward[index]["layerNum"] = layerNum
        			self.netData.sweepReward[index]["award"] = {}

	        		local tempReward = retTable.rewardInfo or {}
	        		for i,v in ipairs(tempReward) do
	        			local recode = {}
	        			recode.id = v.rewardId
	        			recode.num = v.rewardCount
	        			self.netData.sweepReward[index]["award"][i] = recode
	        		end
	        		self:addSweepInfo(self.netData.sweepReward)
	     --    		if layerNum == self.netData.maxCanSweepCopyLayer then
						-- g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETCOPYTOWERDATA, "CopyGetTowerDataProtocol", {})
						-- addNetLoading(COPY_CS_GETCOPYTOWERDATA, COPY_SC_GETCOPYTOWERDATA_RET)	        			
	     --    		end
	        	end
        	end
        end,
        [COPY_SC_START_PROGRESS_ONE] = function()
        	local retTable = g_msgHandlerInst:convertBufferToTable("CopyTowerStartProgressOneProtocol", luabuffer)
        	if retTable.copyType and retTable.copyType == 2 then
				local copyId = retTable.copyId or 0
        		local tempSweepLayerNum = self:getLayerInfoByFbID(copyId)
        		if tempSweepLayerNum ~= 0 then
	        		self.netData.nowSweepLayer = tempSweepLayerNum
	        		self.netData.isSweeping = true
	        		self.netData.sweepTime = retTable.leftTime or 0
	        		self:sweepTower(layerNum)
	        	end
        	end
        end,
        [COPY_SC_NOTIFYPROREWARD] = function()
        	g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETPROREWARDLIST,"GetProRewardListProtocol",{})
        end,
        [COPY_SC_GETPROREWARDLISTRET]= function()
	        local retTable = g_msgHandlerInst:convertBufferToTable("GetProRewardListRetProtocol", luabuffer)
			local timeNum = retTable.rewardCount
			
			local prizeItems = {}
			local tempSweepInfo = {}
			local tempAwardList = retTable.rewardList
			for i=1,timeNum do
			 	local fbNum = tempAwardList[i].rewardCount
			 	local tempData = tempAwardList[i].rewardList

			 	for j=1, fbNum do
			 		local fbId = tempData[j].copyID
			 		if fbId >= 3000 and fbId <= 3099 then
				 		local objNum = tempData[j].prizeNum
				 		local detailAward = tempData[j].info

				 		for m=1, objNum do
				 			local propId = detailAward[m].rewardId
				 			local Num = detailAward[m].rewardCount
				 			local bind = detailAward[m].bind
				 			--dump(bind, "retTable.rewardList")
				 			prizeItems[propId] = prizeItems[propId] or {}
				 			prizeItems[propId].num = (prizeItems[propId].num or 0) + Num
				 			prizeItems[propId].bind = bind
				 		end

		 				local index = self:getLayerInfoByFbID(fbId)
		 				if index > 0 then
			 				tempSweepInfo[index]= {}
			 				tempSweepInfo[index]["layerNum"] = index
			 				tempSweepInfo[index]["award"] = {}

			 				for m=1, objNum do
					 			local propId = detailAward[m].rewardId
					 			local Num = detailAward[m].rewardCount
					 			local recode = {}
			        			recode.id = propId
			        			recode.num = Num
			        			tempSweepInfo[index]["award"][m] = recode
					 		end
					 	end
				 	end
			 	end
			end

			self:addSweepInfo(tempSweepInfo)
			self:InitTowerSweepInfo()
			self:sweepTower()			

			local tempData = {}
			for k,v in pairs(prizeItems) do
				local index = #tempData + 1
				tempData[index] = {}
				tempData[index]["id"] = k
				tempData[index]["num"] = v.num
				tempData[index]["isBind"] = (v.bind == 1)
				tempData[index]["showBind"] = true
			end
			if #tempData > 0 then
				local func = function()
					g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETPROREWARD, "GetProRewardProtocol", {getTime = 0, copyID = 0, copyType = 2})
					g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETCOPYTOWERDATA, "CopyGetTowerDataProtocol", {})
				end
				Awards_Panel( { awards = tempData , award_tip23 = game.getStrByKey("fb_TowerSweepAward"), getCallBack = func} )
			end
        end,
    }

    if switch[msgid] then 
        switch[msgid]()
    end	
end

---------------------------------------------------------------------------------
function PrizeLayer:ctor(parent)
	self.slctPlayerIdx = 0
	self.parent = parent
	self.num = parent.netData.copyStarPrizeNum or 0
	self.data = parent.netData.copyStarPrize or {}
	self.totalStarNum = parent.netData.maxTower or 0 --parent.netData.totalStarNum or 0
	self:initAwardDropID()
	
	--parent:addChild(self,2)
	local bg = createSprite(self,"res/common/bg/bg27.png", g_scrCenter)
	--createSprite(bg,"res/common/bg/bg27-4.png", getCenterPos(bg, 0, -20),cc.p(0.5,0.5))
	createScale9Sprite( bg , "res/common/scalable/panel_inside_scale9.png", getCenterPos(bg, 0, -20), cc.size( 376 , 449 ) , cc.p(0.5 , 0.5 ) )
	createLabel(bg, game.getStrByKey("fb_starAwardTitle"), cc.p(201,503), nil, 24, true)
	local closeFunc = function()   
		self.parent.sPrizeLayer = nil 
		removeFromParent(self)
	end
	createTouchItem(bg,"res/component/button/x2.png",cc.p(bg:getContentSize().width - 35, bg:getContentSize().height - 25), closeFunc)
	self:createTableView(bg, cc.size(360,400), cc.p(21, 25), true)
	self:getTableView():setBounceable(true)

	local index = 1
	for i=1,#self.data do
		if self.data[i].prizeGotTag == 0 then
			index = i
			break
		end
	end
	local offsetY = -#self.data*145 + 400 + (index-1)* 145
	--print("offsetY1.. " .. offsetY)
	offsetY = offsetY > 0 and 0 or offsetY
	--print("offsetY2.. " .. offsetY)
	offsetY = (offsetY < -#self.data*145 + 400) and (-#self.data*145 + 400) or offsetY
	--print("offsetY3.. " .. offsetY)
	self:getTableView():setContentOffset(cc.p(0, offsetY))

	local str = string.format(game.getStrByKey("fb_currentStar"), self.totalStarNum)
	createLabel(bg, str, cc.p(22, 445), cc.p(0, 0.5), 20):setColor(MColor.lable_yellow)
	--createLabel(bg, , cc.p(360 - 50, 445), cc.p(0.5, 0.5), 20):setColor(MColor.lable_yellow)

	registerOutsideCloseFunc( bg, closeFunc )
    self:registerScriptHandler(function(event)
		if event == "enter" then
		elseif event == "exit" then
			self.parent.sPrizeLayer = nil 
		end
    end)
end

function PrizeLayer:initAwardDropID()
	local data = self.parent.fbData
	local item = data[3000].starprize
	--dump(item,"item")
	local data = unserialize(item)
	--dump(data)
	for i=1,#self.data do
		for k,v in pairs(data) do
			if self.data[i].copyStarIndex == tonumber(k) then
				self.data[i].awardId = tonumber(v)
			end
		end
		
	end
	--dump(self.data, "self.data")
end

function PrizeLayer:cellSizeForTable(table,idx) 
    return 145, 360
end

function PrizeLayer:numberOfCellsInTableView(table)
    return self.num
end

function PrizeLayer:tableCellTouched(table,cell)

end

function PrizeLayer:ChangeStarPrizeFlg(index)
	print("PrizeLayer:ChangeStarPrizeFlg .. " .. index)
	local cell = self:getTableView():cellAtIndex( index - 1)
	local cellData = self.data[index]
	if cell and cell.btn and cellData then
		if cell.btn and cell.sprFlg and cellData.prizeGotTag == 1 then
    		cell.btn:setVisible(false)
    		cell.sprFlg:setVisible(true)
		end
	end
end

function PrizeLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell() 
    if nil == cell then
       	cell = cc.TableViewCell:new()
    else
    	cell:removeAllChildren()
    end

    local cellData = self.data[idx + 1]
    local getFunc = function()
    	--dump(cellData.copyStarIndex, "cellData.copyStarIndex")
		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETCOPYSTARPRIZE, "CopyGetStarPrizeProtocol", {prizeIndex = cellData.copyStarIndex})
	end

    if cellData then
    	local bg = createSprite(cell, "res/common/table/cell26.png", cc.p(0, 5), cc.p(0, 0))
    	createLabel(bg, "通关", cc.p(15, 110), cc.p(0, 0.5), 20):setColor(MColor.lable_black)
		createLabel(bg, "" .. cellData.copyStarIndex , cc.p(75, 110), cc.p(0.5, 0.5), 20)
		createLabel(bg, "层可获得", cc.p(93, 110), cc.p(0, 0.5), 20):setColor(MColor.lable_black)

    	cell.btn = createMenuItem(bg, "res/component/button/48.png", cc.p(300, 50), getFunc)
    	createLabel(cell.btn, game.getStrByKey("get_lq"), getCenterPos(cell.btn), nil, 22, true)
    	cell.btn:setEnabled(self.totalStarNum >= cellData.copyStarIndex)

    	cell.sprFlg = createSprite(bg, "res/component/flag/18.png", cc.p(300, 50))
    	if cellData.prizeGotTag == 1 then
    		cell.btn:setVisible(false)
    		cell.sprFlg:setVisible(true)
    	else
    		cell.btn:setVisible(true)
    		cell.sprFlg:setVisible(false)
    	end
    	if cellData.awardId then
    		local DropOp = require("src/config/DropAwardOp")
			local gdItem = DropOp:dropItem(tonumber(cellData.awardId))
			local propOP = require("src/config/propOp")
			local myschool = MRoleStruct:getAttr(ROLE_SCHOOL)
			local mysex = MRoleStruct:getAttr(PLAYER_SEX)
			if gdItem then
				local i = 1
				for m,n in pairs(gdItem) do

					local limtSex = propOP.sexLimits(n.q_item)
					local schoolLimt = propOP.schoolLimits(n.q_item)
					if (schoolLimt == myschool or schoolLimt == 0)
		   				and (limtSex == mysex or limtSex == 0 ) then
						if i > 3 then break end
						local Mprop = require "src/layers/bag/prop"
						local icon = Mprop.new(
						{
							protoId = tonumber(n.q_item),
							num = tonumber(n.q_count),
							swallow = true,
							cb = "tips",
							showBind = true,
			            	isBind = tonumber(n.bdlx or 0) == 1,						
						})
						icon:setPosition(cc.p(12 + (i - 0.5) * 85, 50))
						bg:addChild(icon)
						icon:setScale(0.9)
						i = i + 1
					end
				end
			end				
		end
    end
    
    return cell
end

---------------------------------------------------------------------------------
function sweepRewardList:ctor(parent)
	self.parent = parent
	self.maxCanSweep = parent.netData.maxCanSweepCopyLayer or 0
	self.showData = {}
	createLabel(self, game.getStrByKey("fb_SweepInfo"), cc.p(parent.rightCenter.x , 463), nil, 20):setColor(MColor.lable_yellow)

	self:createTableView(self, cc.size(265, 380), cc.p(9, 60), true)
	self:getTableView():setBounceable(true)

	createSprite(self, COMMONPATH .. "bg/infoBg11-3.png", cc.p(parent.rightCenter.x , 55), cc.p(0.5,0.5))
	local layerNum = self.maxCanSweep or 0
	local str = string.format(game.getStrByKey("fb_canSweepLayer"), layerNum)
	createLabel(self, str, cc.p(parent.rightCenter.x, 32), nil, 18):setColor(MColor.yellow)

    self:registerScriptHandler(function(event)
		if event == "enter" then
		elseif event == "exit" then
			self.parent.sweepList = nil
		end
    end)
end

function sweepRewardList:cellSizeForTable(table,idx)
	local str = self:getStrByLayerIndex(idx + 1)
    local labHeight = createLabel(nil, str, cc.p(0, 0), cc.p(0, 1), 20, true, 2, nil, MColor.brown_gray, 1)

	local height = (labHeight:getContentSize().width > 260) and 50 or 25

    return height, 280
end

function sweepRewardList:numberOfCellsInTableView(table)
    return tablenums(self.showData)
end

function sweepRewardList:reloadData()
	local tempTab = copyTable( self.parent.netData.sweepReward or {} )
	self.showData = {}

	local i = 1
	for k,v in pairs(tempTab) do
		self.showData[i] = copyTable(v)
		i = i + 1
	end

	table.sort( self.showData, function(a, b) return a.layerNum < b.layerNum end)

	if self.maxCanSweep >= self.parent.netData.nowSweepLayer then
		self.showData[i] = {}
		self.showData[i].isSpecType = true
		self.showData[i].layerNum = self.parent.netData.nowSweepLayer
	end
	self:getTableView():reloadData()
	local height = self:getTableView():getContentSize().height
	--dump(height,"height")
	if height > 360 then
		self:getTableView():setContentOffset(cc.p(0, 0))
	end
end

function sweepRewardList:getStrByLayerIndex(index)
	local tempData = self.showData[index]
    if tempData then
    	if tempData.isSpecType then
    		return string.format("正在扫荡%d层", tempData.layerNum), tempData
    	else
	    	local str = string.format("扫荡%d层获得", tempData.layerNum)
	    	local count = 1
	    	for k,v in pairs(tempData.award) do
	    		local oneAwardStr = MPropOp.name(v.id) .. "x" .. v.num
	    		str = str .. oneAwardStr
	    		if count < tablenums(tempData.award) then
					str = str .. " " 
				end
	    		count = count + 1
	    	end
	    	return str, tempData
	    end
    end

    return ""
end

function sweepRewardList:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell() 
    if nil == cell then
       	cell = cc.TableViewCell:new()
    else
    	cell:stopAllActions()
    	cell:removeAllChildren()
    end

	local str, tempData = self:getStrByLayerIndex(idx + 1)
    local lab = createLabel(cell, str, cc.p(0, 0), cc.p(0, 0), 20, true, 2, nil, MColor.lable_yellow, 1, 260)
    if tempData and tempData.isSpecType then
    	cell.dianNum = -1
    	startTimerAction(cell, 0.5, true, function()
    		cell.dianNum  = cell.dianNum + 1
    		local tempNum = cell.dianNum % 4
    		local dianStr = ""
    		for i=1, tempNum do
    			dianStr = dianStr .. "."
    		end
    		lab:setString(str .. dianStr)
	    end)
    end

    return cell
end

return FBTowerHall