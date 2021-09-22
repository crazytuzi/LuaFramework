local ContainerTable = {}
local var = {}
local lblhint = "1.角色等级低于世界等级3级可激活打怪经验加成\n\n2.野外BOSS等级跟随世界等级成长"
        -- qq：442398706 做好事 要留名
		-- CHART_TYPE_LEVEL_ALL=100,
		-- CHART_TYPE_LEVEL_WIR=101,
		-- CHART_TYPE_LEVEL_WIZ=102,
		-- CHART_TYPE_LEVEL_TAO=103,
		-- CHART_TYPE_GAMEMONEY=104,
		-- CHART_TYPE_ACHIEVE=105,
		-- CHART_TYPE_FIGHTPOINT_WIR=106,
		-- CHART_TYPE_FIGHTPOINT_WIZ=107,
		-- CHART_TYPE_FIGHTPOINT_TAO=108,
		-- CHART_TYPE_FIGHTPOINT_ALL=109,
		-- CHART_TYPE_BONUS_ALL=110,
		-- CHART_TYPE_WING_ALL = 111,
		-- CHART_TYPE_TIANGUAM_ALL = 112,
		-- CHART_TYPE_END=115,
		-- CHART_TYPE_NUM=16,
local despTable ={
	[1] = 	"<font color=#E7BA52 size=18>世界等级说明：</font>",
	[2] =	"1.角色等级低于世界等级3级可激活打怪经验加成",
    [3] =	"2.野外BOSS等级跟随世界等级成长",
}

function ContainerTable.initView(event)
	var = {
		xmlPanel,
		list_chart,
		curChartType,
		curSelectedIndex,
		curSelectedItem,
		Text_worldLv,
		-- xmlOperate,

	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerTable.uif")
	if var.xmlPanel then
		var.list_chart = var.xmlPanel:getWidgetByName("ListView_1")
		local btnDesp = var.xmlPanel:getWidgetByName("Button_ask")
		btnDesp:setTouchEnabled(true)
		btnDesp:addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				ContainerTable.Desp()
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then	
				GDivDialog.handleAlertClose()
			end
		end)
		-- local function prsShuoMing(sender)

		-- 	GameSocket:dispatchEvent({
		-- 		name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "hint", visible = true, lblAlert1 = "世界等级", lblAlert2 = lblhint,
		-- 		alertTitle = "关闭"
		-- 	})
		-- end
		-- GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName("btn_hint"),prsShuoMing)	

		--local tab_button	= var.xmlPanel:getWidgetByName("tab_button")
		--local Button_100	= tab_button:getChildByName("Button_100")
		--local Button_112	= tab_button:getChildByName("Button_112")

		--tab_button:addTabEventListener(ContainerTable.pushButton)
		-- tab_button:setTextColor(GameBaseLogic.getColor(0xD2B48C),GameBaseLogic.getColor(0xD2B48C))
		--tab_button:setTextColor("0xEADDBF", "0xEADDBF")
		--EADDBF,D2B48C,eab065,
		cc.EventProxy.new(GameSocket, var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_REQCHART_LIST, ContainerTable.handleChartList)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerTable.handlePanelData)
					
		ContainerTable.updateGameMoney()
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(pushTabButtons)
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
	end	
	return var.xmlPanel	
end


function pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	--var.curChartType = tonumber(string.sub(sender:getName(), 8,10))
	--print("pushButton var.curChartType:"..var.curChartType)
	if tag==1 then
		var.curChartType=100
	end
	if tag==2 then
		var.curChartType=109
	end
	if tag==3 then
		--var.curChartType=112
		--var.curChartType=113
		ContainerTable.showRechargeRank()
		return
	end
	if tag==4 then
		var.curChartType=108
	end
	if tag==5 then
		var.curChartType=111
	end
	if tag==6 then
		var.curChartType=112
	end
	if tag==7 then
		var.curChartType=109
	end
	if var.curChartType==112 then
		var.xmlPanel:getWidgetByName("Text_4"):setString("星级")	
	else
		var.xmlPanel:getWidgetByName("Text_4"):setString("等级")	
	end
	ContainerTable.set_rank()
	ContainerTable.acquireChartInfo()
end

--金币刷新函数
function ContainerTable:updateGameMoney()
	local panel = var.xmlPanel
	if panel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="big_title_yb_text",btn="big_title_yb_btn",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			{name="big_title_hmb_text",btn="big_title_hmb_btn",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			{name="big_title_jb_text",btn="big_title_jb_btn",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			{name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			if panel:getWidgetByName(v.name) then
				panel:getWidgetByName(v.name):setString(v.value)
				panel:getWidgetByName(v.btn):addClickEventListener( function (sender)
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
				end)
			end
		end
	end
end

function ContainerTable.Desp()
	local mParam = {
		name = GameMessageCode.EVENT_PANEL_ON_ALERT,
		panel = "tips", 
		infoTable = despTable,
		visible = true, 
	}
	GameSocket:dispatchEvent(mParam)
end
function ContainerTable.onPanelOpen(event)
	-- ContainerTable.acquireChartInfo()
	--local tab_button	= var.xmlPanel:getWidgetByName("tab_button")
	--local btnTab
	--if event.tab and type(event.tab) == "number" then
	--	btnTab = tab_button:getChildByName("Button_112")
	--else
	--	btnTab = tab_button:getChildByName("Button_100")
	--end
	--if var.curChartType then 
	--	tab_button:getChildByName("Button_"..var.curChartType):setBrightStyle(0)
	--end 
	
	--ContainerTable.pushButton(btnTab)
	--btnTab:setBrightStyle(1)
	--ContainerTable.setSelfRank()
end

function ContainerTable.pushButton(sender)
	var.curChartType = tonumber(string.sub(sender:getName(), 8,10))
	print("pushButton var.curChartType:"..var.curChartType)
	if var.curChartType==112 then
		var.xmlPanel:getWidgetByName("Text_4"):setString("星级")	
	else
		var.xmlPanel:getWidgetByName("Text_4"):setString("等级")	
	end
	ContainerTable.set_rank()
	ContainerTable.acquireChartInfo()
end

function ContainerTable.set_rank()
	if  GameCharacter._mainAvatar then 
		local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)

		if var.curChartType==job+6 or  var.curChartType==100 or var.curChartType==111 or var.curChartType == 112 then
			var.xmlPanel:getWidgetByName("lbl_selfRank"):setString( GameSocket.mChartData[var.curChartType] and GameSocket.mChartData[var.curChartType].chartRank or GameConst.str_not_in_rank)
		elseif  var.curChartType== 109 then
			var.xmlPanel:getWidgetByName("lbl_selfRank"):setString( GameSocket.mChartData[var.curChartType] and GameSocket.mChartData[var.curChartType].chartRank or GameConst.str_not_in_rank)
		else
			var.xmlPanel:getWidgetByName("lbl_selfRank"):setString(  GameConst.str_not_in_rank)
		end
	else
		var.xmlPanel:getWidgetByName("lbl_selfRank"):setString(  GameConst.str_not_in_rank)
	end 
end


function ContainerTable.acquireChartInfo()
	if GameSocket.mChartData[var.curChartType] then
		ContainerTable.handleChartList()
	else
		--var.xmlPanel:runAction(cca.callFunc(ContainerTable.setSelfRank))
		var.list_chart:hide()	
	end
	GameSocket:GetChartInfo(var.curChartType, 1)
end

function ContainerTable.handleChartList(event)
	local chartData = clone(GameSocket.mChartData[var.curChartType])
	print("var.curChartType:"..var.curChartType)
	local chartIndex = {}
	function updateItem(item)
		local tag		= chartIndex[item.tag]
		local param		= chartData[tag].param
		--print("param"..param)
		local name 		= chartData[tag].name
		local job 		= GameConst.job_name[chartData[tag].job]
		local lv 		= chartData[tag].lv
		local guild 	= chartData[tag].guild
		if chartData[tag].guild=="" then guild="无" else  guild =guild  end

		local lbl_listItem1 = item:getWidgetByName("Text_list1")
		lbl_listItem1:setString(tag)
		lbl_listItem1:show()
		local lbl_listItem2 = item:getWidgetByName("Text_list2")
		lbl_listItem2:setString(name)
		lbl_listItem2:show()
		local lbl_listItem3 = item:getWidgetByName("Text_list3")
		lbl_listItem3:setString(job)
		--lbl_listItem3:show()
		local lbl_listItem4 = item:getWidgetByName("Text_list4")
		lbl_listItem4:setString(lv)
		
		if var.curChartType==111 then
			lbl_listItem4:setString(param.."阶")
			
		elseif var.curChartType==112 then
			-- print(">>>>>>>>>>")
			var.xmlPanel:getWidgetByName("Text_4"):setString("星级")
			lbl_listItem4:setString(param.."星")
		elseif  var.curChartType== 109 then
			var.xmlPanel:getWidgetByName("Text_4"):setString("战力")
			lbl_listItem4:setString(param)	
		end
		---lbl_listItem4:setString(param)
		lbl_listItem4:show()
		local lbl_listItem5 = item:getWidgetByName("Text_list5")
		lbl_listItem5:setString(guild)	
		lbl_listItem5:show()

		local img_rank = item:getWidgetByName("img_rank")
		if tag <= 3 then
			img_rank:show():align(display.CENTER):pos(63.51,31.28):loadTexture("chart_"..tag, ccui.TextureResType.plistType)
			lbl_listItem1:hide()
		else
			img_rank:hide()
		end
		if tag==1 then 
			lbl_listItem2:setColor(GameBaseLogic.getColor(0xf09333))
			lbl_listItem3:setColor(GameBaseLogic.getColor(0xf09333))
			lbl_listItem4:setColor(GameBaseLogic.getColor(0xf09333))
			lbl_listItem5:setColor(GameBaseLogic.getColor(0xf09333))
			lbl_listItem2:setFontSize(22)
			lbl_listItem3:setFontSize(22)
			lbl_listItem4:setFontSize(22)
			lbl_listItem5:setFontSize(22)
		elseif tag==2 then 
			lbl_listItem2:setColor(GameBaseLogic.getColor(0x59aad3))
			lbl_listItem3:setColor(GameBaseLogic.getColor(0x59aad3))
			lbl_listItem4:setColor(GameBaseLogic.getColor(0x59aad3))
			lbl_listItem5:setColor(GameBaseLogic.getColor(0x59aad3))
			lbl_listItem2:setFontSize(21)
			lbl_listItem3:setFontSize(21)
			lbl_listItem4:setFontSize(21)
			lbl_listItem5:setFontSize(21)
		elseif tag==3 then 
			lbl_listItem2:setColor(GameBaseLogic.getColor(0xee6853))
			lbl_listItem3:setColor(GameBaseLogic.getColor(0xee6853))
			lbl_listItem4:setColor(GameBaseLogic.getColor(0xee6853))
			lbl_listItem5:setColor(GameBaseLogic.getColor(0xee6853))
			lbl_listItem2:setFontSize(20)
			lbl_listItem3:setFontSize(20)
			lbl_listItem4:setFontSize(20)
			lbl_listItem5:setFontSize(20)
		else 
			lbl_listItem2:setColor(GameBaseLogic.getColor(0xFFECDF))
			lbl_listItem3:setColor(GameBaseLogic.getColor(0xFFECDF))
			lbl_listItem4:setColor(GameBaseLogic.getColor(0xFFECDF))
			lbl_listItem5:setColor(GameBaseLogic.getColor(0xFFECDF))
		end 
		local img_highlight = item:getWidgetByName("img_highlight"):setVisible(false)
		item:setTouchEnabled(true)
		item:addClickEventListener(function ()
			local visible = not img_highlight:isVisible()
			img_highlight:setVisible(visible)
			if visible then
				if var.curSelectedItem then
					var.curSelectedItem:getWidgetByName("img_highlight"):hide()
				end
				var.curSelectedItem			= item
				var.curSelectedItem.name	= chartData[tag].name
				var.curSelectedItem.state	= chartData[tag].state
				var.curSelectedItem.lv		= chartData[tag].lv
				var.curSelectedIndex		= item.tag
			else
				var.curSelectedItem		= nil
				var.curSelectedIndex	= nil
			end
			if var.curSelectedItem and var.curSelectedItem.name then
				if var.curSelectedItem.name == GameBaseLogic.chrName then
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_avatar", from = "btn_main_rank"})
				else
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = chartData[tag]})
					-- var.xmlOperate= GUIFloatTips.showOperateTips(var.xmlOperate,var.xmlPanel,var.curSelectedItem.name)
				end
			else
				--GameSocket:alertLocalMsg("请选择玩家", "alert")
			end
		end)
	end
	
	if chartData then
		for i = 1, #chartData do
			table.insert(chartIndex, i)
		end
	end
	var.list_chart:reloadData(#chartIndex, updateItem)
	var.list_chart:show()
	

	ContainerTable.setSelfRank()
end
function ContainerTable.setSelfRank()
	ContainerTable.set_rank()
	if var.curChartType==109 then
		if GameSocket.mChartData[109] and GameSocket.mChartData[109][1] and GameSocket.mChartData[109][1].lv then 
			var.Text_worldLv=GameSocket.mChartData[109][1].param
			var.xmlPanel:getWidgetByName("Text_worldLv"):setString(var.Text_worldLv)
			var.xmlPanel:getWidgetByName("txt_woridlv"):setString("最高战力：")
			
		end 
	else 	
		if GameSocket.mChartData[100] and GameSocket.mChartData[100][1] and GameSocket.mChartData[100][1].lv then 
			var.Text_worldLv=GameSocket.mChartData[100][1].lv
			var.xmlPanel:getWidgetByName("Text_worldLv"):setString(var.Text_worldLv)
			var.xmlPanel:getWidgetByName("txt_woridlv"):setString("世界等级：")
			
		end 
	end
end
function ContainerTable.onPanelClose()
	
	GameSocket.mChartData = {}
	ContainerTable.handleChartList()

end

--充值排行
function ContainerTable.showRechargeRank()
	GameSocket:PushLuaTable("gui.ContainerSuperActivities.onPanelData",GameUtilSenior.encode({actionid = "updateRechargeData",params={}}))
end

function ContainerTable.handlePanelData(event)
	print("sadasdasd")
	local data = GameUtilSenior.decode(event.data)
	if data.cmd=="updateRechargeRankData" then
		ContainerTable.updateRechargeRankData(data)
	end
end

function ContainerTable.updateRechargeRankData(data)
	function updateItem(item)
		local tag = item.tag
		local lbl_listItem1 = item:getWidgetByName("Text_list1")
		lbl_listItem1:setString(tag)
		lbl_listItem1:show()
		local lbl_listItem2 = item:getWidgetByName("Text_list2")
		lbl_listItem2:setString(data.awards[tag].name)
		lbl_listItem2:show()
		local lbl_listItem3 = item:getWidgetByName("Text_list3")
		lbl_listItem3:setString("战士")
		--lbl_listItem3:show()
		local lbl_listItem4 = item:getWidgetByName("Text_list4")
		lbl_listItem4:setString("")
		
		---lbl_listItem4:setString(param)
		lbl_listItem4:show()
		local lbl_listItem5 = item:getWidgetByName("Text_list5")
		lbl_listItem5:setString("")	
		lbl_listItem5:show()

		local img_rank = item:getWidgetByName("img_rank")
		if tag <= 3 then
			img_rank:show():align(display.CENTER):pos(63.51,31.28):loadTexture("chart_"..tag, ccui.TextureResType.plistType)
			lbl_listItem1:hide()
		else
			img_rank:hide()
		end
		if tag==1 then 
			lbl_listItem2:setColor(GameBaseLogic.getColor(0xf09333))
			lbl_listItem3:setColor(GameBaseLogic.getColor(0xf09333))
			lbl_listItem4:setColor(GameBaseLogic.getColor(0xf09333))
			lbl_listItem5:setColor(GameBaseLogic.getColor(0xf09333))
			lbl_listItem2:setFontSize(22)
			lbl_listItem3:setFontSize(22)
			lbl_listItem4:setFontSize(22)
			lbl_listItem5:setFontSize(22)
		elseif tag==2 then 
			lbl_listItem2:setColor(GameBaseLogic.getColor(0x59aad3))
			lbl_listItem3:setColor(GameBaseLogic.getColor(0x59aad3))
			lbl_listItem4:setColor(GameBaseLogic.getColor(0x59aad3))
			lbl_listItem5:setColor(GameBaseLogic.getColor(0x59aad3))
			lbl_listItem2:setFontSize(21)
			lbl_listItem3:setFontSize(21)
			lbl_listItem4:setFontSize(21)
			lbl_listItem5:setFontSize(21)
		elseif tag==3 then 
			lbl_listItem2:setColor(GameBaseLogic.getColor(0xee6853))
			lbl_listItem3:setColor(GameBaseLogic.getColor(0xee6853))
			lbl_listItem4:setColor(GameBaseLogic.getColor(0xee6853))
			lbl_listItem5:setColor(GameBaseLogic.getColor(0xee6853))
			lbl_listItem2:setFontSize(20)
			lbl_listItem3:setFontSize(20)
			lbl_listItem4:setFontSize(20)
			lbl_listItem5:setFontSize(20)
		else 
			lbl_listItem2:setColor(GameBaseLogic.getColor(0xFFECDF))
			lbl_listItem3:setColor(GameBaseLogic.getColor(0xFFECDF))
			lbl_listItem4:setColor(GameBaseLogic.getColor(0xFFECDF))
			lbl_listItem5:setColor(GameBaseLogic.getColor(0xFFECDF))
		end
		var.xmlPanel:getWidgetByName("Text_4"):setString("")
		var.xmlPanel:getWidgetByName("Text_5"):setString("")
		var.xmlPanel:getWidgetByName("Text_worldLv"):setString("")
		var.xmlPanel:getWidgetByName("txt_woridlv"):setString("")
		if data.myRank<1 then
			var.xmlPanel:getWidgetByName("lbl_selfRank"):setString("未上榜")
		else
			var.xmlPanel:getWidgetByName("lbl_selfRank"):setString( data.myRank)
		end
		local img_highlight = item:getWidgetByName("img_highlight"):setVisible(false)
		item:setTouchEnabled(true)
		item:addClickEventListener(function ()
			local visible = not img_highlight:isVisible()
			img_highlight:setVisible(visible)
			if visible then
				if var.curSelectedItem then
					var.curSelectedItem:getWidgetByName("img_highlight"):hide()
				end
				var.curSelectedItem			= item
				var.curSelectedItem.name	= data.awards[tag].name
				var.curSelectedItem.state	= ""
				var.curSelectedItem.lv		= 0
				var.curSelectedIndex		= tag
			else
				var.curSelectedItem		= nil
				var.curSelectedIndex	= nil
			end
			if var.curSelectedItem and var.curSelectedItem.name then
				if var.curSelectedItem.name == GameBaseLogic.chrName then
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_avatar", from = "btn_main_rank"})
				else
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = data.awards[tag]})
					--var.xmlOperate= GUIFloatTips.showOperateTips(var.xmlOperate,var.xmlPanel,data.awards[tag].name)
				end
			else
				--GameSocket:alertLocalMsg("请选择玩家", "alert")
			end
		end)
	end
	local size = 0
	for i=1,#data.awards do
		if data.awards[i].name~="" then
			size = i
		end
	end
	var.list_chart:reloadData(size, updateItem)


end
--充值排行结束

return ContainerTable