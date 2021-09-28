local FactionMapLayer = class("FactionMapLayer", require ("src/TabViewLayer") )

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionMapLayer:ctor(factionData, parentBg, factionLayer)
	local msgids = {FACTION_SC_GETMSGRECORD_RET}
	require("src/MsgHandler").new(self,msgids)
 g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETMSGRECORD, "GetFactionMsgRecord", { factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID), lowNum=1, highNum=50 })
	self.factionData = factionData
	self.factionLayer = factionLayer
	self.canShowJoinGroup = true
	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode

    --local bg = createSprite(self, "res/common/bg/bg-6.png", cc.p(480, 290), cc.p(0.5, 0.5))
    local bg = cc.Node:create()
    bg:setPosition(cc.p(15, 23))
    bg:setContentSize(cc.size(930, 535))
    bg:setAnchorPoint(cc.p(0, 0))
    self:addChild(bg)

    local imageBg = createSprite(bg, path.."2.jpg", getCenterPos(bg), cc.p(0.5, 0.5))

	--local leftBg = createSprite(baseNode, pathCommon.."bg/bg8.png", cc.p(13, 25), cc.p(0, 0))
	--self.leftBg = leftBg
	--local rightBg = createSprite(baseNode, pathCommon.."bg/bg9.png", cc.p(335, 25), cc.p(0, 0))
	--self.rightBg = rightBg
	self.imgBg = imageBg
	local infoBg = createSprite(self, path.."min.png", cc.p(31, 39), cc.p(0, 0))
	self.infoBg = infoBg
	createSprite(infoBg, path.."titleNotice.png", cc.p(infoBg:getContentSize().width/2, 443), cc.p(0.5, 0))
	createSprite(infoBg, path.."titleInfo.png", cc.p(infoBg:getContentSize().width/2, 260), cc.p(0.5, 0))

	-- local titleBgTop = createSprite(infoBg, path.."title_min.png", cc.p(infoBg:getContentSize().width/2, 465), cc.p(0.5, 0))
	-- createLabel(titleBgTop, game.getStrByKey("faction_notice"), getCenterPos(titleBgTop), cc.p(0.5, 0.5), 22, true)

	-- local noticeBg = createSprite(infoBg, pathCommon.."bg/infoBg10.png", cc.p(infoBg:getContentSize().width/2, 380), cc.p(0.5, 0.5))
	-- self.noticeBg = noticeBg
	self.noticeTip = createLabel(infoBg, game.getStrByKey("faction_notice_tip"), cc.p(infoBg:getContentSize().width/2, 300), cc.p(0.5, 0), 16, false, nil, nil, MColor.red)
	--self.noticeTip = createMultiLineLabel(infoBg, game.getStrByKey("faction_notice_tip"), cc.p(infoBg:getContentSize().width/2, 310), cc.p(0.5, 0), 16, false, nil, nil, MColor.black, 180, 18, true)

	local edit_box_handler = function(strEventName,pSender)
        local edit = tolua.cast(pSender,"ccui.EditBox")

        if strEventName == "began" then --编辑框开始编辑时调用
        	log("began")
        elseif strEventName == "ended" then --编辑框完成时调用
        	log("ended")
        elseif strEventName == "return" then --编辑框return时调用
        	log("return")
     		local str = self.edit_box:getText()
     		dump(str)
	    	if string.len(str) > 0 then
	    		if string.utf8len(str) > 40 then
					TIPS({type =1 ,str = game.getStrByKey("master_input_num_error")})
		    	else
		    		str = checkShield(str)
	    		    g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_EDITCOMMENT, "EditComment", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID),comment=str})
                end
			end
			self.edit_box:setText("")
        elseif strEventName == "changed" then --编辑框内容改变时调用
        	log("changed")
        end
	end
	local edit_box = createEditBox(infoBg, nil, cc.p(infoBg:getContentSize().width/2, 375), cc.size(190, 90), MColor.white)
	self.edit_box = edit_box
	edit_box:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	edit_box:registerScriptEditBoxHandler(edit_box_handler)
	edit_box:setFontSize(18)

	-- local titleBgCenter = createSprite(infoBg, path.."title_min.png", cc.p(infoBg:getContentSize().width/2, 260), cc.p(0.5, 0))
	-- createLabel(titleBgCenter, game.getStrByKey("faction_info"), getCenterPos(titleBgCenter), cc.p(0.5, 0.5), 22, true)

	-- local function levelUpBtnFunc()
 --        local layer = require("src/layers/faction/FactionUpdateLayer").new(self.factionData, 1)
	-- 	dump(getCenterPos(self))
	-- 	Manimation:transit(
	-- 	{
	-- 		ref = self,
	-- 		node = layer,
	-- 		curve = "-",
	-- 		sp = getCenterPos(parentBg),
	-- 		ep = getCenterPos(parentBg),
	-- 		swallow = true,
	-- 	})
	-- end
	-- local levelUpBtn = createMenuItem(infoBg, "res/component/button/50.png", cc.p(infoBg:getContentSize().width/2-70, 40), levelUpBtnFunc)
	-- createLabel(levelUpBtn, game.getStrByKey("faction_update"), getCenterPos(levelUpBtn), nil, 22, true)

	local function knowledgeBtnFunc() 
    	local layer = require("src/layers/faction/FactionKnowLedgeListLayer").new(self.factionData)
		dump(getCenterPos(self))
		Manimation:transit(
		{
			ref = self,
			node = layer,
			curve = "-",
			sp = getCenterPos(parentBg),
			ep = getCenterPos(parentBg),
			swallow = true,
		})
	end
	local knowledgeBtn = createMenuItem(imageBg, "res/component/button/49.png", cc.p(820, 465), knowledgeBtnFunc)
	createLabel(knowledgeBtn, game.getStrByKey("faction_knowledge"), getCenterPos(knowledgeBtn), nil, 22, true)

	local function rightsBtnFunc() 
    	local layer = require("src/layers/faction/FactionRightsLayer").new(self.factionData)
		dump(getCenterPos(self))
		Manimation:transit(
		{
			ref = self,
			node = layer,
			curve = "-",
			sp = getCenterPos(parentBg),
			ep = getCenterPos(parentBg),
			swallow = true,
		})
	end
	local rightsBtn = createMenuItem(imageBg, "res/component/button/49.png", cc.p(670, 465), rightsBtnFunc)
	createLabel(rightsBtn, game.getStrByKey("faction_rights"), getCenterPos(rightsBtn), nil, 22, true)

	local function goBtnFunc() 
    	__GotoTarget( { ru = "a173" } )
	end
	--前往行会驻地的按钮
	local goBtn = createMenuItem(imageBg, "res/component/button/50.png", cc.p(565, 100), goBtnFunc)
	--local goBtn = createMenuItem(imageBg, "res/component/button/50.png", cc.p(self.infoBg:getContentSize().width/2, 55), goBtnFunc)
	goBtn:setEnabled(false)
	self.goBtn = goBtn
	createLabel(goBtn, game.getStrByKey("faction_go_place"), getCenterPos(goBtn), nil, 22, true)

	-- local function qifutaBtnFunc()
	-- 	self.factionLayer.menuFunc(2, nil, 1)
	-- end
	-- local qifutaBtn = createMenuItem(imageBg, "res/component/button/53.png", cc.p(430, 370), qifutaBtnFunc)
	-- createMultiLineLabel(qifutaBtn, game.getStrByKey("faction_qifuta"), cc.p(qifutaBtn:getContentSize().width/2, qifutaBtn:getContentSize().height-30), cc.p(0.5, 1), 22, true, nil, nil, MColor.lable_black, 30, 25, true)
	-- local qifutaBtnEx = createTouchItem(imageBg, "res/common/scalable/1.png", cc.p(510, 370), qifutaBtnFunc)
	-- scaleToSize(qifutaBtnEx, cc.size(70, 170))
	-- qifutaBtnEx:setOpacity(255*0.0)

	-- local function shopBtnFunc()
	-- 	self.factionLayer.menuFunc(2, nil, 2)
	-- end
	-- local shopBtn = createMenuItem(imageBg, "res/component/button/53.png", cc.p(70, 80), shopBtnFunc)
	-- createMultiLineLabel(shopBtn, game.getStrByKey("faction_baibaoge"), cc.p(shopBtn:getContentSize().width/2, shopBtn:getContentSize().height-30), cc.p(0.5, 1), 22, true, nil, nil, MColor.lable_black, 30, 25, true)
	-- local shopBtnEx = createTouchItem(imageBg, "res/common/scalable/1.png", cc.p(180, 60), shopBtnFunc)
	-- scaleToSize(shopBtnEx, cc.size(130, 90))
	-- shopBtnEx:setOpacity(255*0.0)

	-- local function bannerBtnFunc()
	-- 	self.factionLayer.menuFunc(2, nil, 4)
	-- end
	-- local bannerBtn = createMenuItem(imageBg, "res/component/button/53.png", cc.p(30, 230), bannerBtnFunc)
	-- createMultiLineLabel(bannerBtn, game.getStrByKey("faction_zhanqitai"), cc.p(bannerBtn:getContentSize().width/2, bannerBtn:getContentSize().height-30), cc.p(0.5, 1), 22, true, nil, nil, MColor.lable_black, 30, 25, true)
	-- local bannerBtnEx = createTouchItem(imageBg, "res/common/scalable/1.png", cc.p(120, 230), bannerBtnFunc)
	-- scaleToSize(bannerBtnEx, cc.size(130, 100))
	-- bannerBtnEx:setOpacity(255*0.0)

	-- local function fbBtnFunc()
	-- 	self.factionLayer.menuFunc(2, nil, 3)
	-- end
 --    local fbBtn = createMenuItem(imageBg, "res/component/button/53.png", cc.p(230, 275), fbBtnFunc)
	-- createMultiLineLabel(fbBtn, game.getStrByKey("faction_juyitang"), cc.p(fbBtn:getContentSize().width/2, fbBtn:getContentSize().height-30), cc.p(0.5, 1), 22, true, nil, nil, MColor.lable_black, 30, 25, true)
 --    local fbBtnEx = createTouchItem(imageBg, "res/common/scalable/1.png", cc.p(324, 280), fbBtnFunc)
	-- scaleToSize(fbBtnEx, cc.size(120, 80))
	-- fbBtnEx:setOpacity(255*0.0)

 --    local function ystFunc()
	-- 	self.factionLayer.menuFunc(2, nil, 5)
	-- end
	-- local ystBtn = createMenuItem(imageBg, "res/component/button/53.png", cc.p(550, 80), ystFunc)
	-- createMultiLineLabel(ystBtn, game.getStrByKey("faction_yishiting"), cc.p(ystBtn:getContentSize().width/2, ystBtn:getContentSize().height-30), cc.p(0.5, 1), 22, true, nil, nil, MColor.lable_black, 30, 25, true)
	-- local ystBtnEx = createTouchItem(imageBg, "res/common/scalable/1.png", cc.p(460, 100), ystFunc)
	-- scaleToSize(ystBtnEx, cc.size(130, 140))
	-- ystBtnEx:setOpacity(255*0.0)

--[[    local function notopenFunc()
		self.factionLayer.menuFunc(2, nil, 6)
	end
	local notopenBtn = createMenuItem(imageBg, "res/component/button/53.png", cc.p(110, 400), notopenFunc)
	createMultiLineLabel(notopenBtn, game.getStrByKey("faction_notopen"), cc.p(notopenBtn:getContentSize().width/2, notopenBtn:getContentSize().height-30), cc.p(0.5, 1), 22, true, nil, nil, MColor.lable_black, 30, 25, true)
]]	
    --local notopenBtnEx = createTouchItem(imageBg, "res/common/scalable/1.png", cc.p(460, 90), notopenFunc)
	--scaleToSize(notopenBtnEx, cc.size(130, 140))
	--notopenBtnEx:setOpacity(255*0.0)

	-- local function taskBtnFunc()
	-- 	self.factionLayer.menuFunc(2, nil, 4)
	-- end
	-- local taskBtn = createMenuItem(imageBg, "res/component/button/53.png", cc.p(535, 115), taskBtnFunc)
	-- createMultiLineLabel(taskBtn, game.getStrByKey("faction_task"), cc.p(taskBtn:getContentSize().width/2, taskBtn:getContentSize().height-30), cc.p(0.5, 1), 22, true, nil, nil, MColor.lable_black, 30, 25, true)

	-- local expBg = createSprite(self, getSpriteFrame("mainui/exp/exp_bg.png"), cc.p(parentBg:getContentSize().width/2, 0), cc.p(0.5, 0.0), 1)
	-- self.expBg = expBg

	if factionData.facLv <3  then
		createLabel(imageBg, game.getStrByKey("faction_place_tip" .. factionData.facLv), cc.p(565, 40), cc.p(0.5, 0), 20, false, nil, nil, MColor.lable_yellow)
	end
	__createHelp({parent=imageBg, str=game.getStrByKey('faction_help'), pos=cc.p(860, 30)})

	--进度条
	local progressBg = createSprite(imageBg, "res/component/progress/5.png", cc.p(565, 25), cc.p(0.5, 0.5))
	self.progressBg = progressBg
	self.progress = cc.ProgressTimer:create(cc.Sprite:create("res/component/progress/5-1.png"))  
	progressBg:addChild(self.progress)
    self.progress:setPosition(getCenterPos(progressBg))
    self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.progress:setAnchorPoint(cc.p(0.5, 0.5))
    self.progress:setBarChangeRate(cc.p(1, 0))
    self.progress:setMidpoint(cc.p(0, 1))
    self.progress:setPercentage(0)

    --createSprite(progressBg, getSpriteFrame("mainui/exp/exp_ex.png"), cc.p(progressBg:getContentSize().width/2 , 0), cc.p(0.5, 0.0))

    --进度
	self.progressLabel = createLabel(progressBg, game.getStrByKey("faction_exp").."：".."0 / 0", getCenterPos(progressBg, 0, 0), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.white)

	self:updateFactionInfo()
	if factionData.notice then
		self:updateNoticeInfo(factionData.notice)
	end
	self.load_data = {}
end

function FactionMapLayer:updateFactionInfo(factionData)
	if factionData then
		self.factionData = factionData
	end

	local x = 65
	local y = 220
	local addY = -25

	dump(self.factionData)
	if self.nameLabel == nil then
		self.nameLabel = createLabel(self.infoBg, "", cc.p(x, y), cc.p(0, 0), 18, true, nil, nil, MColor.lable_yellow)
	end
	y = y + addY

	if self.levelLabel == nil then
		self.levelLabel = createLabel(self.infoBg, "", cc.p(x, y), cc.p(0, 0), 18, true, nil, nil, MColor.lable_yellow)
	end
	y = y + addY

	if self.leaderLabel == nil then
		self.leaderLabel = createLabel(self.infoBg, "", cc.p(x, y), cc.p(0, 0), 18, true, nil, nil, MColor.lable_yellow)
	end
	y = y + addY

	if self.memberLabel == nil then
		self.memberLabel = createLabel(self.infoBg, "", cc.p(x, y), cc.p(0, 0), 18, true, nil, nil, MColor.lable_yellow)
	end
	y = y + addY

	if self.moneyLabel == nil then
		self.moneyLabel = createLabel(self.infoBg, "", cc.p(x, y), cc.p(0, 0), 18, true, nil, nil, MColor.lable_yellow)
	end
	y = y + addY

	if self.myMoneyLabel == nil then
		self.myMoneyLabel = createLabel(self.infoBg, "", cc.p(x, y), cc.p(0, 0), 18, true, nil, nil, MColor.lable_yellow)
	end

	self.nameLabel:setString(game.getStrByKey("faction_name")..self.factionData.name)
	self.levelLabel:setString(game.getStrByKey("faction_level_1")..self.factionData.facLv)
	self.leaderLabel:setString(game.getStrByKey("president_name")..self.factionData.leaderName)
	self.memberLabel:setString(game.getStrByKey("faction_man_num")..self.factionData.menberCount)
	self.moneyLabel:setString(game.getStrByKey("faction_wealth")..self.factionData.money)
	self.myMoneyLabel:setString(game.getStrByKey("my_devote")..self.factionData.myMoney)

	--根据工会ID和区服ID查询绑群、加群信息
	local serverID = require("src/login/LoginScene").serverId
	local nickName = require("src/login/LoginScene").myNickName
	local openID = sdkGetOpenId()
	local factionName = self.factionData.name
	local factionID = 0

	if self.factionData.id then
		factionID = self.factionData.id
	end

	--加入微信群的结果回调
	self.OnJoinWXGroupNotify = function(result, str)
		if result == 0 then
			if self.groupBtn then
				performWithDelay(self, function() 
				removeFromParent(self.groupBtn)
				self.groupBtn = nil
				createLabel(self.infoBg, game.getStrByKey("faction_group_wx_joinDone"), cc.p(self.infoBg:getContentSize().width/2, 55), nil, 18, true)
				print("suzhen OnJoinWXGroupNotify Success")
				end, 0.2)
			end
		else
			print("suzhen OnJoinWXGroupNotify Fail")
		end
	end

	--创建微信群的结果回调
	self.OnCreateWXGroupNotify = function(result, str)
		if result == 0 then
			if self.groupBtn then
				performWithDelay(self, function() 
				removeFromParent(self.groupBtn)
				self.groupBtn = nil
				createLabel(self.infoBg, game.getStrByKey("faction_group_wx_created"), cc.p(self.infoBg:getContentSize().width/2, 55), nil, 18, true)
				print("suzhen OnCreateWXGroupNotify Success")
				end, 0.2)
			end
		end
	end

	local function onWeixinGroupFuncChief()
		--会长来创建微信群
		weakCallbackTab.OnCreateWXGroupNotify = self.OnCreateWXGroupNotify
		sdkCreateWXGroup(string.format(factionID), factionName, nickName)
		print("suzhen onWeixinGroupFuncChief to create WXgroup , faction id is" .. factionID .. "factionName is " .. factionName .. "nickname is " .. nickName)
	end

	local function WeixinGroupFuncChief()
		if isWXInstalled() then
			onWeixinGroupFuncChief()
		else
			TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_noInstalledWX") })
		end
	end

	local function onWeixinGroupFunc()
		--非会长来加入微信群
		weakCallbackTab.OnJoinWXGroupNotify = self.OnJoinWXGroupNotify
		sdkJoinWXGroup(string.format(factionID), nickName)
		print("suzhen onWeixinGroupFunc to join WXgroup, factionID is " .. factionID .. "nickname is " .. nickName)
	end

	local function WeixinGroupFunc()
		if isWXInstalled() then
			onWeixinGroupFunc()
		else
			TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_noInstalledWX") })
		end
	end
	
	
	self.factionLayer.hasWXgroup = false
	--查询微信群绑定信息
	self.onQueryWXGroupInfo = function(result, str)
		local ret = require("json").decode(str)
		if result == 0 then
			self.factionLayer.hasWXgroup = true
			--查询到已经绑定或加入了微信群了，根据传入的openId来判断是否在已创建的微信群里面
			local txtHintWXGroup = nil
			if self.factionData.job == 4 then
        		--是会长，查询到目前有微信群
        		if ret.openIdList == "" then
        			self.factionLayer.isInWXgroup = false

        			--判断群里没有会长，是否已经解散了群
        			--local groupBtn = createMenuItem(self.infoBg, "res/component/button/66.png", cc.p(self.infoBg:getContentSize().width/2, 55), WeixinGroupFuncChief)
					--groupBtn:setEnabled(true)
					--self.groupBtn = groupBtn
					--createLabel(groupBtn, game.getStrByKey("faction_group_wx_create"), getCenterPos(groupBtn), nil, 22, true)
					--print("suzhen onQueryWXGroupInfo not in WXgroup , faction id is 4")
				else
					self.factionLayer.isInWXgroup = true
					setGameSetById(GAME_SET_ISINWXGROUP, 1, false)   
					--判断已经创建了微信群
					--print("suzhen onQueryWXGroupInfo in WXgroup , faction id is 4")
        		end
        		createLabel(self.infoBg, game.getStrByKey("faction_group_wx_created"), cc.p(self.infoBg:getContentSize().width/2, 55), nil, 18, true)
			else
				--不是会长，查询到目前有微信群
				if ret.openIdList == "" then
        			--判断群里没有，显示可以加入群的按钮
        			local groupBtn = createMenuItem(self.infoBg, "res/component/button/66.png", cc.p(self.infoBg:getContentSize().width/2, 55), WeixinGroupFunc)
					groupBtn:setEnabled(true)
					self.groupBtn = groupBtn
					createLabel(groupBtn, game.getStrByKey("faction_group_wx_join"), getCenterPos(groupBtn), nil, 22, true)
					--print("suzhen onQueryWXGroupInfo not in WXgroup , faction id is not 4")
				else
					setGameSetById(GAME_SET_ISINWXGROUP, 1, false)   
					--判断群里有会员本人，显示已经加入了微信群
					createLabel(self.infoBg, game.getStrByKey("faction_group_wx_joinDone"), cc.p(self.infoBg:getContentSize().width/2, 55), nil, 18, true)
					--print("suzhen onQueryWXGroupInfo in WXgroup , faction id is not 4")
        		end
			end
		elseif result == -10001 then
			--没有建群的权限
			--print("suzhen OnCreateWXGroupNotify Fail, have no permission to create wx group")
			TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_limitCreateGroup") })     
		elseif result == -10002 then
			--参数检查错误
			--print("suzhen OnCreateWXGroupNotify Fail, param is wrong")
			TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_wrongParamstr") })   
		elseif result == -10005 then
			--群ID已经存在了
			--print("suzhen OnCreateWXGroupNotify Fail, group id already exist")
			TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_groupIdExist") })     
		elseif result == -10006 then
			--建群数量超过上限
			--print("suzhen OnCreateWXGroupNotify Fail, group count overload")
			TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_limitCount") })
		elseif result == -10007 then
			--群ID不存在
			--print("suzhen OnCreateWXGroupNotify Fail, group id is not exist")
			--没有查询到绑定微信群
			if self.factionData.job == 4 then
        		--是会长，没有查询到目前有微信群，可以创建微信群
        		--print("suzhen onQueryWXGroupInfo no WXgroup , faction id is 4")
        		local groupBtn = createMenuItem(self.infoBg, "res/component/button/66.png", cc.p(self.infoBg:getContentSize().width/2, 55), WeixinGroupFuncChief)
				groupBtn:setEnabled(true)
				self.groupBtn = groupBtn
				createLabel(groupBtn, game.getStrByKey("faction_group_wx_create"), getCenterPos(groupBtn), nil, 22, true)
			else
				--不是会长，没有查询到目前有微信群，显示一个label告知无绑定，禁止任何操作
				createLabel(self.infoBg, game.getStrByKey("faction_group_wx_joinDone"), cc.p(self.infoBg:getContentSize().width/2, 55), nil, 18, true)
				--print("suzhen onQueryWXGroupInfo no WXgroup , faction id is not 4")
			end
        end
    end

	--绑定QQ群的结果回调
	 --self.OnBindQQGroupNotify = function(result, str)
		--绑群的回调不可靠，会立刻返回成功的结果，无意义

	 --end

	self.OnUnbindGroupNotify = function(result, str)
		if result == 0 then
			performWithDelay(self, function()
				if self.groupBtn then
					createLabel(self.infoBg, game.getStrByKey("faction_group_qq_unbindDone"), cc.p(self.infoBg:getContentSize().width/2, 55), nil, 18, true)
					removeFromParent(self.groupBtn)
					self.groupBtn = nil
				end
				TIPS({ type = 1  , str = game.getStrByKey("faction_group_qq_unbindDone") })
			end, 0.3)
		end
	end

	--此处发送GameSvr查询协议，根据服务器回传的群OpenID来查询群Key
	local function QQGroupFunc()
		local t = {}
		g_msgHandlerInst:sendNetDataByTableExEx(FACTION_OPENID_CS_GET, "FactionOpenIdGet", t)
		print("suzhen++++++++++ send FACTION_OPENID_CS_GET to request QQgroupOpenId from GameSvr")
	end

	local function QQGroupFuncChiefUnBind()
		weakCallbackTab.OnUnbindGroupNotify = self.OnUnbindGroupNotify
		sdkUnbindQQGroup(self.groupOpenId, self.factionData.id)
		local t = {}
		t.factionID = self.factionData.id
		t.openId = "0"
		g_msgHandlerInst:sendNetDataByTableExEx(FACTION_OPENID_CS_BIND, "FactionOpenIdBind", t)
	end

	local function onQQGroupFuncChief()
		--会长来绑定QQ群
		--weakCallbackTab.OnBindQQGroupNotify = self.OnBindQQGroupNotify
		local strSignature = string.format(openID .. "_1105148805_2aRld1Ct5WF2qSfR_" .. factionID .. "_" .. serverID)
		local signature = getMd5HexStr(strSignature)
		if self.groupBtn then
			removeFromParent(self.groupBtn)
			self.groupBtn = nil
			createLabel(self.infoBg, game.getStrByKey("faction_qqgroup_operationHint"), cc.p(self.infoBg:getContentSize().width/2, 55), nil, 18, true)
		end
		sdkBindQQGroup(factionID, factionName, serverID, signature)
		--print("suzhen QQGroupFuncChief, factionID is" .. factionID .. "factionName is " .. factionName .. "serverID is " .. serverID .. "signature is " .. signature)
	end
    
    local function QQGroupFuncChief()
    	if isQQInstalled() then
    		onQQGroupFuncChief()
    	else
    		TIPS({ type = 1  , str = game.getStrByKey("faction_qqgroup_noInstalledQQ") })
    	end
	end

	local function QQGroupFuncEx()
		--非会长来加入QQ群，根据这个key去加群，加群接口无回调函数，只能通过查询来获取结果
		if self.groupKey then
			if self.groupBtn then
				removeFromParent(self.groupBtn)
				self.groupBtn = nil
				createLabel(self.infoBg, game.getStrByKey("faction_qqgroup_operationHint"), cc.p(self.infoBg:getContentSize().width/2, 55), nil, 18, true)
			end
			sdkJoinQQGroup(self.groupKey)
		else
			print("suzhen QQGroupFunc, there is no groupKey")
		end
	end

	--行会成员加入Q群的时候查询的绑定QQ群的群OpenID
	self.OnQueryGroupKeyNotify = function(result, str)
		local ret = require("json").decode(str)
 	 	if ret.groupKey then
 			self.groupKey = ret.groupKey
 			print("suzhen QQ groupKey is " .. self.groupKey)
 	 	end
		if result == 0 then
			QQGroupFuncEx()
		end
	end

	onGetSvrOpenId = function( openId )
		if self.factionData.job ~= 4 then
			if openId ~= "0" then
				weakCallbackTab.OnQueryGroupKeyNotify = self.OnQueryGroupKeyNotify
				sdkQueryQQGroupKey(openId)
				print("suzhen++++++++++ get QQgroupOpenId from GameSvr, value is " .. openId)
			else
				TIPS({ type = 1  , str = game.getStrByKey("faction_qqgroup_noBindGroup") })    
			end
		else
			local t = {}
			t.factionID = self.factionData.id
			t.openId = self.groupOpenId
			g_msgHandlerInst:sendNetDataByTableExEx(FACTION_OPENID_CS_BIND, "FactionOpenIdBind", t)
		end
	end

    --查询QQ群绑定信息
    require("src/utf8")
    self.onQueryQQGroupInfo = function(result, str)
 		local ret = require("json").decode(str)
 	 	if ret.groupOpenId then
 			self.groupOpenId = ret.groupOpenId
 			self.groupName = hexDecode(ret.groupName)
 			if not string.isValidUtf8(self.groupName) then
                self.groupName = " "
 			end
 			print("suzhen QQ groupOpenId is " .. self.groupOpenId .. "QQ groupName is " .. self.groupName)
 	 	end

		if result == 0 then
			--查询到了绑定的QQ群
			if self.factionData.job == 4 then
        		--是会长，查询到目前有QQ群
        		QQGroupFunc()
				print("suzhen onQueryQQGroupInfo Success, faction job is 4")
				local groupBtn = createMenuItem(self.infoBg, "res/component/button/65.png", cc.p(self.infoBg:getContentSize().width/2, 55), QQGroupFuncChiefUnBind)
				groupBtn:setEnabled(true)
				self.groupBtn = groupBtn
				createLabel(groupBtn, game.getStrByKey("faction_group_qq_unbind"), getCenterPos(groupBtn), nil, 22, true)
			else
				--不是会长，查询到目前有QQ群
				print("suzhen onQueryQQGroupInfo Success, faction job is not 4")
				local strFaction = string.format("QQ群：" .. self.groupName)
				createLabel(self.infoBg, strFaction, cc.p(self.infoBg:getContentSize().width/2, 55), nil, 18, true)
				--createLabel(self.infoBg, game.getStrByKey("faction_group_qq_joinDone"), cc.p(self.infoBg:getContentSize().width/2, 55), nil, 22, true)
				if self.groupBtn then
					removeFromParent(self.groupBtn)
				end
			end
			
		elseif result == 2002 or result == 2003 or result == 2007 then
			--当前行会无绑定记录，或者未加入QQ群，或者绑定的QQ群已经被解散
			if self.factionData.job == 4 then
        		--是会长，没有查询到目前有QQ群，返回的任何错误都需要让会长去绑定QQ的指定群，需要拉起手机QQ客户端
        		print("suzhen onQueryQQGroupInfo Fail, faction job is 4, can bind group")
        		local groupBtn = createMenuItem(self.infoBg, "res/component/button/65.png", cc.p(self.infoBg:getContentSize().width/2, 55), QQGroupFuncChief)
				groupBtn:setEnabled(true)
				self.groupBtn = groupBtn
				createLabel(groupBtn, game.getStrByKey("faction_group_qq_bind"), getCenterPos(groupBtn), nil, 22, true)
			else
				if result == 2003 then
					--不是会长，有绑群，但是本人没加入
					print("suzhen onQueryQQGroupInfo Fail 2003, faction job is not 4, can not join group")
					local groupBtn = createMenuItem(self.infoBg, "res/component/button/65.png", cc.p(self.infoBg:getContentSize().width/2, 55), QQGroupFunc)
					groupBtn:setEnabled(true)
					self.groupBtn = groupBtn
					createLabel(groupBtn, game.getStrByKey("faction_group_qq_join"), getCenterPos(groupBtn), nil, 22, true)
				else
					--不是会长，行会没绑群，成员显示未绑定QQ群的提示，禁止任何其他操作
				 createLabel(groupBtn, game.getStrByKey("faction_group_qq_unbinded"), cc.p(self.infoBg:getContentSize().width/2, 55), nil, 22, true)
				end
			end
		end
	end

	--只有有工会的人才会涉及此功能，绑群功能的入口点
	if self.factionData.id and self.canShowJoinGroup then
		self.canShowJoinGroup = false
		self.platform = sdkGetPlatform()
    	if self.platform == 1 then
        	--WX平台
        	weakCallbackTab.onQueryWXGroupInfo = self.onQueryWXGroupInfo
        	sdkQueryWXGroupInfo(string.format(factionID), openID)
        	print("suzhen sdkQueryWXGroupInfo with factionid is" .. factionID .. "openID is " .. openID)
		elseif self.platform == 2 then
        	--QQ平台，调试中
         	local target = cc.Application:getInstance():getTargetPlatform()
			if target == cc.PLATFORM_OS_ANDROID then
		 		weakCallbackTab.onQueryQQGroupInfo = self.onQueryQQGroupInfo
         		sdkQueryQQGroupInfo(string.format(factionID), string.format(serverID))
         		print("suzhen sdkQueryQQGroupInfo with factionid is" .. factionID .. "serverID is " .. serverID)
			end
   		end
	end

	if self.factionData.facLv and self.factionData.facLv >= 3 then
		self.goBtn:setEnabled(true)
	end

	if G_MAINSCENE.mapId and G_MAINSCENE.mapId == 6017 then
		self.goBtn:setEnabled(false)
	end

	-- if self.factionData.facLv >= 3 then
	-- 	if self.placeTip then
	-- 		removeFromParent(self.placeTip)
	-- 		self.placeTip = nil
	-- 	end
	-- end

	if self.factionData.job >= 3 then
		self.noticeTip:setVisible(true)
		self.edit_box:setEnabled(true)
	else 
		self.noticeTip:setVisible(false)
		self.edit_box:setEnabled(false)
	end

	if self.factionData.notice then
		self:updateNoticeInfo(self.factionData.notice)
	end

	if self.factionData.facLv >= 9 then
		removeFromParent(self.progressBg)
		self.progressBg = nil
	else
		if self.progress then
			-- dump(self.factionData)
			-- dump(self.factionData.exp * 100 / self.factionData.expMax)
			self.progress:setPercentage(self.factionData.exp * 100 / self.factionData.expMax)
		end

		if self.progressLabel then
			self.progressLabel:setString(game.getStrByKey("faction_exp").."："..self.factionData.exp .. "/"..self.factionData.expMax)
		end
	end
end

function FactionMapLayer:updateNoticeInfo(str)
	if str and string.len(str) > 0 then
		if self.noticeLabel then
			removeFromParent(self.noticeLabel)
			self.noticeLabel = nil
		end

		local richText = require("src/RichText").new(self.infoBg, cc.p(self.infoBg:getContentSize().width/2-92, 435), cc.size(190, 90), cc.p(0, 1), 24, 18, MColor.lable_yellow)
	    richText:addText(str)
	    richText:format()
	    self.noticeLabel = richText
	end
end

function FactionMapLayer:addEventLabel()
	-- body
	if #self.load_data == 0 then
		return
	end
	local colorLayer =createSprite(self.imgBg, "res/faction/infobg.png",cc.p(575,410),cc.p(0.5,0.5))
	local node = Mnode.createColorLayer(
						{
							src = cc.c4b(0, 0, 0, 0),
							cSize = cc.size(550, 495),
						})
	node:setAnchorPoint(cc.p(0,0))
	node:setPosition(cc.p(300,0))
	local clipNode = cc.ClippingNode:create(node)
	
	self.imgBg:addChild(clipNode)
	
	local data = self.load_data[#self.load_data]
	-- local str = getConfigItemByKeys("clientmsg",{"sth","mid"},{7000,data.id})
	local msg = data[3]
	local label1  = createLabel( nil , cutRichText(msg),cc.p( 0 , 0 ) , cc.p(0 , 0 ) , 20 , nil , nil , nil , MColor.white )
    local realWidth = label1:getContentSize().width + 10



    
	-- clipNode:addChild(colorLayer)
	-- colorLayer:setAnchorPoint(cc.p(0,0))

    local label = require("src/RichText").new(clipNode,cc.p(575,410), cc.size(realWidth, 20), cc.p(0.5, 0.5), 20, 20, MColor.white)
    label:addText(msg)
	label:format()

	label:setPosition(cc.p(node:getContentSize().width+300+label:getContentSize().width/2,410))
	local action = cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create( 6 , cc.p(300-label:getContentSize().width/2,410) ), cc.CallFunc:create(function ( ... )
		label:setPosition(node:getContentSize().width+300+label:getContentSize().width/2,410)
	end)))

	label:runAction(action)
end

function FactionMapLayer:networkHander(buff, msgid)
	local switch = {
		[FACTION_SC_GETMSGRECORD_RET] = function()    
			log("get FACTION_SC_GETMSGRECORD_RET"..msgid)
			
            local t = g_msgHandlerInst:convertBufferToTable("GetFactionMsgRecordRet", buff) 
            
            self.load_data = {} 
			local num =  #t.records
			for i=1,num do 
				self.load_data[i] = {t.records[i].time, t.records[i].id}
				for k,v in pairs(require("src/config/clientmsg"))do
					if 7000 == v.sth and  self.load_data[i][2] == v.mid then
						local param_num = #t.records[i].params
						if v.fat and param_num == string.len(v.fat) then
							if v.mid == 5 then
                                local tt = {t.records[i].params[1], t.records[i].params[2], t.records[i].params[3], t.records[i].params[4]}
                                local numTp = tonumber(tt[2])
                                if numTp == 1 then
                                    tt[2] = game.getStrByKey("factionQFT_xiang1")
                                elseif numTp == 2 then
                                    tt[2] = game.getStrByKey("factionQFT_xiang2")
                                else
                                    tt[2] = game.getStrByKey("factionQFT_xiang3")
                                end

                                self.load_data[i][3] = string.format(v.msg, tt[1], tt[2], tt[3], tt[4])
                            else
                                local s = t.records[i].params
                                self.load_data[i][3] = string.format(v.msg,s[1],s[2],s[3],s[4],s[5],s[6],s[7],s[8],s[9],s[10])
                            end
						else
							self.load_data[i][3] = v.msg
						end
						--[[
                        local link_num = buff:readByFmt("c")
						for j=1,link_num do 
							--self.load_data[i][4] = {buff:readByFmt("iS")}
                            buff:readByFmt("iS")
						end
                        ]]
						break
					end
				end
			end	
			self:addEventLabel()
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end
return FactionMapLayer