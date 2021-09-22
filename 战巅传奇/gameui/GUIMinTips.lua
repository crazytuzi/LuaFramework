--
-- Author: Katou
-- Date: 2015-06-08 11:38:51
--底部弹出框消息
--
local GUIMinTips={}
local var = {}
local tipsInterVal = 70
local DO_NOT_SUB_TIP_COUNT = {"tip_mail","tip_bag_full"}--在这个里面的表示点击的时候不会减少消息的次数

local showTips = {
	["tip_mail"]="您刚刚收到一封邮件。",
	["tip_bag_full"]="您的背包已经满了。",
	["tip_equip"]="你获得了更好的装备。",
	["tip_friend"]="您有新的好友请求。",
	["tip_group"]="您有新的组队请求。",
	["tip_private"]="您收到了私聊请求。",
	["tip_trade"]="您收到了交易请求。",
	["tip_activity"]={
		[1]="快来泡点,站着把等级升了！",
		[2]="神威狱开启，大量极品装备等你！",
		[3]="快来参与蚩尤战场活动吧！",
		[4]="元宝BOSS出现，大量金币等着你！",
		[5]="快来参与擂台挑战活动吧！", 
		[6]="快来参加王城战吧！",
		[7]="地仙送豪礼，快来抢吧！",
		[8]="武林争霸已经开始，快来战斗吧！",
		[9]="玛雅神殿已经开启，快来升级吧！",
		[10]="夺宝奇兵已经开启，快来夺宝吧！",
		[11]="怪物攻城已经开启，快来消灭BOSS吧！",
	},
	["tip_car_robbed"]="您的镖车被劫了。",
	["tip_car_achieved"]="您可以领取镖车奖励了。",
}

function GUIMinTips.init(rightBottom)
	var = {
		updateIndex = 0,	
		rightBottom,
		panelEquipOpened,
		bottomTip,
		bottomName,
	}
	if rightBottom then
		var.rightBottom = rightBottom
		cc.EventProxy.new(GameSocket, rightBottom)
			-- :addEventListener(GameMessageCode.EVENT_SHOW_BOTTOM, GUIMinTips.handleBottomTips)
			:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, GUIMinTips.handleItemChange)
			:addEventListener(GameMessageCode.EVENT_PANEL_EQUIP_STATE, GUIMinTips.handlePanelEquipState)
			:addEventListener(GameMessageCode.EVENT_BAG_UNFULL, GUIMinTips.handleBagUnfull)
	end
end

function GUIMinTips.getTipsMsg()
	local index = 0
	local firstMsg
	if not var.bottomTip then
		for k,v in pairs(GameSocket.tipsMsg) do
			if index == 0 and #v>0 then
				firstMsg = k
			end	
			index = index + #v	
		end
		return firstMsg
	else
		return var.bottomName
	end	
end

function GUIMinTips.handleBottomTips(event)
	if event and event.str then
		if not GameSocket.tipsMsg[event.str] then return end

		local need2Delete = false
		if #GameSocket.tipsMsg[event.str] < 1 and var.bottomName and event.str == var.bottomName then
			need2Delete = true
		end

		if need2Delete then
			if GameUtilSenior.isObjectExist(var.bottomTip) then
				GUIMinTips.moveOtherTipsAward(var.bottomTip)
				var.bottomTip:removeFromParent()
				var.bottomTip=nil
				var.bottomName = nil
			end
		end

		if event.visible == false then
			GameSocket.tipsMsg[event.str] = {}
		end

		local firstMsg =  GUIMinTips.getTipsMsg()

		if not var.bottomTip and firstMsg and firstMsg ~= var.bottomName then
			-- var.bottomTip = var.rightBottom:getChildByName(firstMsg)
			var.bottomName = firstMsg
			var.bottomTip = GUIMinTips.getNewTipBtn(firstMsg)

			if showTips[firstMsg] then
				local lblmsgNum = var.bottomTip:getChildByName("lblmsgNum")
				if not lblmsgNum then
					lblmsgNum = ccui.Text:create("", FONT_NAME, 22):setColor(cc.c3b(200,200,0)):addTo(var.bottomTip,-1)
				end
				local width = lblmsgNum:getContentSize().width
				lblmsgNum:align(cc.ui.TEXT_VALIGN_CENTER, width+210, 22)
				lblmsgNum:setName("lblmsgNum")


				local imgTipBg = ccui.ImageView:create()
					:loadTexture("img_scrollBg",ccui.TextureResType.plistType)
					:setScaleX(0.7)
					:align(cc.ui.TEXT_VALIGN_CENTER, width+200, 22)
					:addTo(var.bottomTip,-2)
					:setName(firstMsg)
					:setTouchEnabled(true)
					:addClickEventListener(GUIMinTips.pushTipsBtn)

				-- if not event.noAction then
				-- 	local createAction = var.bottomTip:getActionByTag(1)
				-- 	local scaleAction = var.bottomTip:getActionByTag(2)
				-- 	if not createAction and not scaleAction then
				-- 		local scaleAction = cca.seq({cca.scaleTo(0.2, 1.5), cca.scaleTo(0.2, 1)})
				-- 		scaleAction:setTag(2)
				-- 		var.bottomTip:runAction(scaleAction)
				-- 	end
				-- end
				local mmsg = ""
				local msgParam = GameSocket.tipsMsg[firstMsg][1]
				if type(showTips[firstMsg]) == "string" then
					mmsg = showTips[firstMsg]
				elseif type(showTips[firstMsg]) == "table" then
					if msgParam.type then
						mmsg = showTips[firstMsg][msgParam.type]
					end
				end	
				lblmsgNum:setString(mmsg)

			end
		end	
	end
end

function GUIMinTips.getNewTipBtn(name)
	local btn = ccui.Button:create("tip_show", "", "", ccui.TextureResType.plistType):addTo(var.rightBottom):align(display.CENTER, -display.width-200, 80)
	btn:setName(name)
	btn:addClickEventListener(GUIMinTips.pushTipsBtn)

	local index = 0
	for k,v in pairs(GameSocket.tipsMsg) do
		if k ~= name and #v > 0 then index = index + 1 end 
	end

	local createAction = cca.seq({cca.sineOut(cca.moveBy(1, display.width*0.45 - index * tipsInterVal, 0)), cca.scaleTo(0.2, 1.5), cca.scaleTo(0.2, 1)})
	createAction:setTag(1)--startAction Tag id
	btn:runAction(createAction)
	return btn
end

function GUIMinTips.operateFuncs(btnName,msgParam)
	local funcs = {
		["tip_trade"] = function()
			local traderName = GameSocket.mTradeInviter
			local param = {
				name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", visible = true, lblConfirm = "["..traderName.."]请求与您交易",
				btnConfirm = "是", btnCancel = "否",
				confirmCallBack = function ()
					GameSocket:AgreeTradeInvite(traderName)
				end,
				cancelCallBack = function ()
					GameSocket:CloseTrade()
					GameSocket:PrivateChat(traderName, "["..GameCharacter._mainAvatar:NetAttr(GameConst.net_name).."]拒绝了您的交易请求")
				end
			}
			GameSocket:dispatchEvent(param)
		end,

		["tip_group"] = function()
			local param = {
				name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", visible = true,
				btnConfirm = "是", btnCancel = "否",
			}
			local msg = string.format("职业:%s,等级:%s,战:%d,性别:%s", GameConst.job_name[msgParam.job], msgParam.level, msgParam.power, GameConst.gender_name[msgParam.gender])
			if msgParam.msgType == "invite" then
				msg = msgParam.name.."邀请你加入队伍，信息："..msg

				param.confirmCallBack = function ()
					GameSocket:AgreeInviteGroup(msgParam.name, msgParam.group_id)
					UITimer.new({
						interval = 0.5,
						times = 1,
						onInterval = function ()
							GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_group"})
						end
						})
				end

				param.cancelCallBack = function ()
					GameSocket:PrivateChat(msgParam.name, "["..GameCharacter._mainAvatar:NetAttr(GameConst.net_name).."]的组队邀请被拒绝")
				end
			else
				msg = msgParam.name.."申请加入队伍,信息："..msg
				param.confirmCallBack = function ()
					GameSocket:AgreeJoinGroup(msgParam.name)
				end
				param.cancelCallBack = function ()
					GameSocket:PrivateChat(msgParam.name, "["..GameCharacter._mainAvatar:NetAttr(GameConst.net_name).."]队长拒绝了您的入队申请")
				end

			end
			param.lblConfirm = msg
			GameSocket:dispatchEvent(param)
		end,

		["tip_car_robbed"] = function()
			local param = {
				name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", visible = true, lblConfirm = "镖车被"..msgParam.name.."所劫，损失"..msgParam.robMoney.."金币",
				btnConfirm = "加为仇人", btnCancel = "否",
				confirmCallBack = function ()
					GameSocket:FriendChange(msgParam.name, 101)
				end
			}
			GameSocket:dispatchEvent(param)
		end,

		["tip_car_achieved"] = function()
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "menu_escort"})
		end,

		["tip_friend"] = function()
			local param = {
				name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", visible = true, lblConfirm = msgParam.."已添加您为好友，是否添加"..msgParam.."为好友？",
				btnConfirm = "是", btnCancel = "否",
				confirmCallBack = function ()
					GameSocket:FriendChange(msgParam, 100)
				end
			}
			GameSocket:dispatchEvent(param)
		end,
		["tip_mail"] = function()
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_mail"})
		end,
		["tip_activity"] = function()
			if msgParam.type == 10 then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "extend_activity"})							
			else
				local param = {
					name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", visible = true, lblConfirm = msgParam.msg,
					btnConfirm = "传送", btnCancel = "否",
					confirmCallBack = function ()
						if msgParam.flyId then
							GameSocket:DirectFly(msgParam.flyId)
						elseif msgParam.scriptAction then
							GameSocket:PushLuaTable(msgParam.scriptAction)
						end
					end
				}
				GameSocket:dispatchEvent(param)
			end
		end,

		["tip_bag_full"] = function()
			-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT,panel = "bagfull", visible = true})
		end,

	}
	if funcs[btnName] then funcs[btnName]() end
end

function GUIMinTips.pushTipsBtn(sender)
	local btnName = sender:getName()
	if not GameSocket.tipsMsg[btnName] or not GameSocket.tipsMsg[btnName][1] then
		local tartip = var.rightBottom:getWidgetByName(btnName)
		if tartip then
			var.rightBottom:getWidgetByName(btnName):runAction(cca.seq({cca.scaleTo(0.1, 1.5), cca.removeSelf()}))
			return
		end
	end
	local msgParam = GameSocket.tipsMsg[btnName][1]
	if btnName ~= "tip_equip" then
		if msgParam then
			GUIMinTips.operateFuncs(btnName,msgParam)

			if not table.indexof(DO_NOT_SUB_TIP_COUNT, btnName) then
				table.remove(GameSocket.tipsMsg[btnName], 1)
			end

			if type(msgParam) == "table" and msgParam.msgType == "invite" then
				for i,v in ipairs(GameSocket.tipsMsg[btnName]) do
					if v.msgType == "invite" then
						table.remove(GameSocket.tipsMsg[btnName],i)
					end
				end
			end

			if #GameSocket.tipsMsg[btnName] < 1 then
				if GameUtilSenior.isObjectExist(var.bottomTip) then
					GUIMinTips.moveOtherTipsAward(var.bottomTip)
					var.bottomTip:runAction(cca.seq({cca.scaleTo(0.1, 1.5), cca.cb(function(sender) 
						if var.bottomTip and sender == var.bottomTip then
							var.bottomTip=nil
							var.bottomName = nil
						end
					end), cca.removeSelf()}))
				end
				
				local firstMsg = GUIMinTips.getTipsMsg()
				GUIMinTips.handleBottomTips({str=firstMsg})
			else 
				if showTips[btnName] then
					local mmsg = ""
					local msgParam = GameSocket.tipsMsg[btnName][1]
					if type(showTips[btnName]) == "string" then
						mmsg = showTips[btnName]
					elseif type(showTips[btnName]) == "table" then
						if msgParam.type then
							mmsg = showTips[btnName][msgParam.type]
						end	
					end	
					if GameUtilSenior.isObjectExist(var.bottomTip) then
						var.bottomTip:getChildByName("lblmsgNum"):setString(mmsg)
					end
				end
			end
		end
	else
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "main_avatar"})
	end
end

function GUIMinTips.moveOtherTipsAward(sender)
	local senderPosX = sender:getPositionX()
	for k,v in pairs(GameSocket.tipsMsg) do
		if k ~= sender:getName() then
			local tipBtn = var.rightBottom:getWidgetByName(k)
			if tipBtn then
				if tipBtn:getPositionX() < senderPosX then
					tipBtn:runAction(cca.sineOut(cca.moveBy(0.2, tipsInterVal, 0)))
				end
			end
		end
	end
end

function GUIMinTips.update()
	if var.panelEquipOpened then return end
	if GameSocket.tipsMsg["tip_equip"] and #GameSocket.tipsMsg["tip_equip"] > 0 then
		var.updateIndex = var.updateIndex + 1
		if var.updateIndex > 9 then
			var.updateIndex = 0
			local curTime = os.time()

			for i,v in ipairs(GameSocket.tipsMsg["tip_equip"]) do
				if curTime - v.time > 10 then
					if GameSocket:check_better_item(v.itempos) then
						print("auto use equip")
						GameSocket:BagUseItem(v.itempos, v.typeid)
						GameSocket.tipsMsg["tip_equip"][i] = "better"
					else
						GameSocket.tipsMsg["tip_equip"][i] = "remove"
					end
				end
			end
			table.removebyvalue(GameSocket.tipsMsg["tip_equip"], "remove", true)
			if table.removebyvalue(GameSocket.tipsMsg["tip_equip"], "better", true) > 0 then
				GameSocket:alertLocalMsg("自动为您穿戴更好装备！","alert")
			end
			if #GameSocket.tipsMsg["tip_equip"] == 0 then
				if var.rightBottom:getWidgetByName("tip_equip") then
					var.rightBottom:getWidgetByName("tip_equip"):runAction(cca.seq({cca.scaleTo(0.1, 1.5), cca.removeSelf()}))
				end
				var.bottomTip = nil
				var.bottomName = nil
			end
		end
	end
end

function GUIMinTips.handleItemChange(event)
	if GameSocket.tipsMsg["tip_equip"] and #GameSocket.tipsMsg["tip_equip"] > 0 then
		for i,v in ipairs(GameSocket.tipsMsg["tip_equip"]) do
			if v.typeid == event.oldType and v.itempos == event.pos then
				table.remove(GameSocket.tipsMsg["tip_equip"], i)
			end
		end
		if #GameSocket.tipsMsg["tip_equip"] == 0 and var.rightBottom:getWidgetByName("tip_equip") then
			if	var.rightBottom:getWidgetByName("tip_equip") then
				var.rightBottom:getWidgetByName("tip_equip"):runAction(cca.seq({cca.scaleTo(0.1, 1.5), cca.removeSelf()}))
			end
			var.bottomTip = nil
			var.bottomName = nil
		end
	end
end

function GUIMinTips.handleBagUnfull(event)
	if GameSocket.tipsMsg["tip_bag_full"] and #GameSocket.tipsMsg["tip_bag_full"] >0 and var.rightBottom:getWidgetByName("tip_bag_full") then
		var.rightBottom:getWidgetByName("tip_bag_full"):runAction(cca.seq({cca.scaleTo(0.1, 1.5), cca.removeSelf(),cca.cb(function()
			GameSocket.tipsMsg["tip_bag_full"] = nil
		end)}))
		var.bottomTip = nil
		var.bottomName = nil
	end
end

function GUIMinTips.handlePanelEquipState(event)
	if event.opened then
		var.panelEquipOpened = true
	else
		var.panelEquipOpened = false
		if GameSocket.tipsMsg["tip_equip"] and #GameSocket.tipsMsg["tip_equip"] > 0 then
			for i,v in ipairs(GameSocket.tipsMsg["tip_equip"]) do
				if GameSocket:check_better_item(v.itempos) then
					GameSocket:BagUseItem(v.itempos, v.typeid)
				end
			end
			GameSocket.tipsMsg["tip_equip"] = {}
			GameSocket:alertLocalMsg("自动为您穿戴更好装备！","alert")
		end
		if var.rightBottom:getWidgetByName("tip_equip") then
			var.rightBottom:getWidgetByName("tip_equip"):runAction(cca.seq({cca.scaleTo(0.1, 1.5), cca.removeSelf()}))
			var.bottomTip = nil
			var.bottomName = nil
		end
	end
end

return GUIMinTips