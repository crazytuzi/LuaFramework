-- 主界面按钮消息管理
local GUIMinTipsManager = {}
local var = {}
local temp = {}

--type说明：1:聊 2:帮 3:易 4:友 5:邮 6:队 7:皇 8:活
-- local wordName = {"word_chat","word_guild","word_yi","word_friend","word_mail","word_group","word_huang","word_huo"}

local configTable={
	--["tip_red_packet"]={index = 1,	name="红包", imgName="null",  imgMode = "tip_red_packet", panelKey="main_guild",	page = "hongbao"},
	["tip_private"]={index = 2,	name="聊", imgName="word_chat",   panelKey="main_friend",	tab = 1},
	["tip_guild"]=	{index = 3,	name="帮", imgName="word_guild",  panelKey="main_guild",	tab = 2, page = "apply"},
	["tip_trade"]=	{index = 4,	name="易", imgName="word_yi",     tipsKey="confirm",},
	["tip_friend"]=	{index = 5,	name="友", imgName="word_friend", panelKey="panel_groupapply", },--好友申请
	["tip_mail"]=	{index = 6,	name="邮", imgName="word_mail",   panelKey="main_mail",	},
	["tip_group"]=	{index = 7,	name="队", imgName="word_group",  panelKey="panel_groupapply"},--组队申请
	["tip_king"]=	{index = 8,	name="皇", imgName="word_huang",  tipsKey="confirm",},
	["tip_activity"]={index = 9,name="活", imgName="word_huo",    panelKey="panel_acttip"},
}

function GUIMinTipsManager.prsItemClick(sender)
	local itemData = configTable[sender.key]
	if itemData then
		if itemData.panelKey then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = itemData.panelKey,key = sender.key, page = itemData.page})
			var.listData[sender.key] = nil
		elseif itemData.tipsKey then
			if sender.key =="tip_trade" then
				local traderName = GameSocket.tipsMsg["tip_trade"][1]--GameSocket.mTradeInviter
				if traderName then
					local param = {
						name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "["..traderName.."]请求与您交易",
						btnConfirm = "交易", btnCancel = "取消",
						confirmCallBack = function ()
							GameSocket:AgreeTradeInvite(traderName)
						end,
						cancelCallBack = function ()
							GameSocket:CloseTrade()
							GameSocket:PrivateChat(traderName, "["..GameBaseLogic.chrName.."]拒绝了您的交易请求")
						end
					}
					GameSocket:dispatchEvent(param)
					table.remove(GameSocket.tipsMsg[sender.key],1)
				end
			elseif sender.key =="tip_king" then
				local result = GameSocket.tipsMsg["tip_king"][1]--GameSocket.mTradeInviter
				if result then
					local param = {
						name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = result.msg,
						btnConfirm = "确定", btnCancel = "取消",
						confirmCallBack = function ()
							GameSocket:PushLuaTable(result.callFunc,result.book)
						end
					}
					table.remove(GameSocket.tipsMsg[sender.key],1)
					GameSocket:dispatchEvent(param)

				end
			end
			if #GameSocket.tipsMsg[sender.key]<1 then
				var.listData[sender.key] = nil
			end
		end
	end
	GUIMinTipsManager.updateButtonList()
end

function GUIMinTipsManager.updateTipsList(item)
	local idx = item.tag
	item:getWidgetByName("imgWord"):loadTexture(temp[idx].imgName, ccui.TextureResType.plistType)
	local btnMode = item:getWidgetByName("btnMode")
	if temp[idx].imgMode then
		btnMode:loadTextures(temp[idx].imgMode,temp[idx].imgMode,"",ccui.TextureResType.plistType)
		item:getWidgetByName("imgClick"):setVisible(false)
	else
		btnMode:loadTextures("btn_tip","btn_tip","",ccui.TextureResType.plistType)
		item:getWidgetByName("imgClick"):setVisible(true)
	end
	item:getWidgetByName("imgWord"):removeChildByName("spriteEffect")
	GameUtilSenior.addEffect(item:getWidgetByName("imgWord"),"spriteEffect",4,200000,{x=20,y=45},false,true)
	-- item:getWidgetByName("imgClick")
	btnMode.key=temp[idx].key
	GUIFocusPoint.addUIPoint(btnMode,GUIMinTipsManager.prsItemClick)
end

function GUIMinTipsManager.updateButtonList()
	temp = {}
	for k,v in pairs(var.listData) do
		v.key = k
		table.insert(temp,v)
	end
	table.sort(temp,function( A,B )
		return A.index<B.index
	end)
	var.tipsList:reloadData(#temp,GUIMinTipsManager.updateTipsList)
	var.tipsList:setPositionX(-560-(#temp*57)/2)
end

function GUIMinTipsManager.handleBottomHandler( event )
	if event.str then
		if configTable[event.str] then
			GameSocket.tipsMsg[event.str] = GameSocket.tipsMsg[event.str] or {}

			if not var.listData[event.str] and table.nums(GameSocket.tipsMsg[event.str])>0 then
				var.listData[event.str] = configTable[event.str]
				GUIMinTipsManager.updateButtonList()
			elseif var.listData[event.str] and table.nums(GameSocket.tipsMsg[event.str])==0 then
				var.listData[event.str] = nil
				GUIMinTipsManager.updateButtonList()
			end
		end
	end
end

function GUIMinTipsManager.init(tipsList)
	var = {
		tipsList=nil,
		listData = {},
	}
	if not var.tipsList then
		var.tipsList=tipsList
		var.tipsList:setTouchEnabled(false)
	end

	cc.EventProxy.new(GameSocket,tipsList)
		:addEventListener(GameMessageCode.EVENT_SHOW_BOTTOM,GUIMinTipsManager.handleBottomHandler)

	GUIMinTipsManager.initAfter()
end

function GUIMinTipsManager.initAfter()
	local update = false
	for k,v in pairs(configTable) do
		if GameUtilSenior.isTable(GameSocket.tipsMsg[k]) and table.nums(GameSocket.tipsMsg[k])>0 then
			var.listData[k] = v
			update = true
		end
	end
	if update then
		GUIMinTipsManager.updateButtonList()
	end
end

return GUIMinTipsManager