--[[
--奖励大厅功能
--]]

local ContainerReward={}
local var = {}

local btnTabName ={
	"btn_tab_sign", "btn_tab_online", "btn_tab_fifteen"
}

function ContainerReward.initView()
	var = {
		xmlPanel,
		curXmlTab=nil,
		xmlBoss=nil,
		xmlOnline=nil,
		xmlTeHui=nil,
		xmlCDK=nil,

		bossData=nil,--全名BOSS数据
		bossGroup=1,--全名BOSS当前显示的组id
		xmlDaily = nil,
		dailyTabData = nil,
		xmlFifteen = nil,
		fifteenCeels = {},
		fifteenTabData = nil,
		fifteenNowSelect = nil,

		curFifTag=1,
		mSendText=nil,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerReward.uif")
	if var.xmlPanel then
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerReward.handlePanelData)
		ContainerReward.initTabs()
	end
	return var.xmlPanel
end

function ContainerReward.onPanelOpen(extend)
	if extend and extend.mParam and extend.mParam.tab  and GameUtilSenior.isNumber(extend.mParam.tab) then
		var.tablisth:setSelectedTab(extend.mParam.tab)
	end
end

function ContainerReward.onPanelClose()

end

function ContainerReward.handlePanelData(event)
	if event.type ~= "ContainerReward" then return end
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd =="daily" then
		if var.xmlDaily then
			if data.childCmd == "updateList" then
				ContainerReward.updateDailyTab(data.table,data.noReplace);
			elseif data.childCmd == "updateReceive" then
				ContainerReward.updateDailyReceive(data.receiveNum)
			elseif data.childCmd == "updatereceiveBtn" then
				ContainerReward.updateDailyReceiveBtn(data.receiveBtn)
			elseif data.childCmd == "updateListBtn" then
				ContainerReward.updateDailyOnceTab(data.state,data.tag)
			end
		end
	elseif data.cmd=="fifteen" then
		if var.xmlFifteen then
			if data.childCmd == "updateList" then
				ContainerReward.updateFifteenList(data.table,data.jumpNum);
			elseif data.childCmd == "updateListOnce" then
				ContainerReward.updateFifteenOnceData(data.state,data.tag)
			end
		end
	elseif data.cmd=="updateOnlineData" then--在线奖励
		ContainerReward.initOnlineList(data)
	end
end

--初始化页签
function ContainerReward.initTabs()
	local function pressTabH(sender)
		local tag = sender:getTag()
		if var.curXmlTab then var.curXmlTab:hide() end;
		if tag==1 then
			var.curXmlTab=ContainerReward.initFifteen();
		elseif tag==2 then
			ContainerReward.initOnline()
			var.curXmlTab= var.xmlOnline
		elseif tag==3 then
			var.curXmlTab=ContainerReward.initDaily();
		elseif tag==4 then
			--var.curXmlTab=ContainerReward.initCDK()
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "V8_ContainerJiaQunLiBao"})
		end
	end
	var.tablisth = var.xmlPanel:getWidgetByName("box_tab")

	for i,v in ipairs(btnTabName) do
		var.tablisth:getItemByIndex(i):setName(v)
	end
	
	-- var.boxTab:setSelectedTab(1)
	local hideIndex = {}
	local opened = GameSocket:checkFuncOpenedByID(20021)
	if not opened then
		table.insert(hideIndex,3)
	end
	local opened = GameSocket:checkFuncOpenedByID(20022)
	if not opened then
		table.insert(hideIndex,2)
	end
	local opened = GameSocket:checkFuncOpenedByID(20023)
	if not opened then
		table.insert(hideIndex,1)
	end
	--暂时不显示时装
	--table.insert(hideIndex,table.keyof(pageKeys,"fashion"))
	var.tablisth:hideTab(hideIndex)

	var.tablisth:addTabEventListener(pressTabH)
	var.tablisth:setSelectedTab(1)
	var.tablisth:setScaleEnabled(false)
	--var.tablisth:setTabRes("btn_new21","btn_new21_sel")
	var.tablisth:setTabColor(GameBaseLogic.getColor(0xc3ad88),GameBaseLogic.getColor(0xfddfae))
end

--------------------------------------------------------------在线奖励------------------------------------------------------------------
local despOnline ={
	[1]="<font color=#E7BA52 size=18>在线奖励说明：</font>",
	[2]="<font color=#f1e8d0>1、开服第一周:每周1个小时在线可累计增加30绑定元宝</font>",
	[3]="<font color=#f1e8d0>2、开服第二周:每周1个小时在线可累计增加40绑定元宝</font>",
	[4]="<font color=#f1e8d0>3、开服第三周以后:每周1个小时在线可累计增加50绑定元宝</font>",
	[5]="<font color=#f1e8d0>3、每周最大累计70小时在线时间</font>",
}
function ContainerReward.initOnline()
	if not var.xmlOnline then
		var.xmlOnline=GUIAnalysis.load("ui/layout/ContainerReward_online.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
   							:align(display.LEFT_BOTTOM,0,0)
   							:show()
   		GameUtilSenior.asyncload(var.xmlOnline, "onlineBg", "ui/image/ContainerReward/img_online_bg.jpg")
   		var.xmlOnline:getWidgetByName("lbl_desps"):setTouchEnabled(true):addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				ContainerReward.onlineDesp()
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then
				GDivDialog.handleAlertClose()
			end
		end)
		var.xmlOnline:getWidgetByName("btnAwardWeek"):addTouchEventListener(function (pSender,touchType)
			if touchType == ccui.TouchEventType.began then
				GameSocket:PushLuaTable("gui.AwardHall_online.handlePanelData",GameUtilSenior.encode({actionid = "reqOldWeekAward",params={}}))
			end
		end)
		-- ContainerReward.initOnlineList(nil)
	else
		var.xmlOnline:show()
	end
	GameSocket:PushLuaTable("gui.AwardHall_online.handlePanelData",GameUtilSenior.encode({actionid = "reqOnlineData",params={}}))
end

--初始化在线奖励列表
function ContainerReward.initOnlineList(data)
	local function updateOnlineList(item)
		local itemData = data.dataTable[item.tag]
		local btnLing = item:getWidgetByName("btnLing"):setTouchEnabled(true)
		btnLing:addTouchEventListener(function (sender,touchType)
			if touchType == ccui.TouchEventType.began then
				GameSocket:PushLuaTable("gui.AwardHall_online.handlePanelData",GameUtilSenior.encode({actionid = "reqOnlineAward",params={index=item.tag}}))
			end
		end)
		local labTime = item:getWidgetByName("labTime")
		-- local img_online_guang = item:getWidgetByName("img_online_guang"):setOpacity(255 * 0.5)
		local imgBox = item:getWidgetByName("img_online_box")
		local boxeff = imgBox:getWidgetByName("boxeff")
		local imgYlq = item:getWidgetByName("img_ylq"):pos(88.5,44)
		if not boxeff then
			boxeff = cc.Sprite:create():addTo(imgBox):pos(62.5,60):setName("boxeff")
		end
		if itemData.ling==1 then
			labTime:setVisible(false)
			btnLing:loadTextures("img_zaixianjiangli_bukelingqu.png", "img_zaixianjiangli_bukelingqu.png", "", ccui.TextureResType.plistType):setTouchEnabled(false)--已领取
			-- img_online_guang:setVisible(false)
			imgBox:setVisible(false)
			boxeff:setVisible(false)
			boxeff:stopAllActions()
			-- imgYlq:setVisible(true):getVirtualRenderer():setState(1)--灰态
			imgYlq:setVisible(true):loadTexture("img_online_ylq", ccui.TextureResType.plistType)
		else
			-- imgYlq:setVisible(false):getVirtualRenderer():setState(0)
			if data.onlineTime>=itemData.needTime then
				--imgYlq:setVisible(true):loadTexture("img_online_klq", ccui.TextureResType.plistType)
				labTime:setVisible(false)
				btnLing:loadTextures("btn_online_2", "btn_online_2", "", ccui.TextureResType.plistType)--可领取
				imgBox:setVisible(true)
				-- img_online_guang:setVisible(true)
				-- img_online_guang:stopAllActions()
				-- img_online_guang:runAction(cca.repeatForever(cca.seq({
				-- 		cca.scaleTo(0.5, 1.06),
				-- 		cca.scaleTo(0, 1.0),
				-- 	})
				-- ))
				local animate = cc.AnimManager:getInstance():getPlistAnimate(4,65095,4,3,false,false,0,function(animate,shouldDownload)
							if animate then
								boxeff:setVisible(true)
								boxeff:stopAllActions()
								boxeff:runAction(cca.seq({
									cca.rep(animate,10000),
									cca.removeSelf()
								}))
							end
							if shouldDownload==true then
								boxeff:release()
							end
						end,
						function(animate)
							boxeff:retain()
						end)
			else
				labTime:setVisible(true)
				btnLing:loadTextures("img_zaixianjiangli_bukelingqu.png", "img_zaixianjiangli_bukelingqu.png", "", ccui.TextureResType.plistType)--不可领取
				-- img_online_guang:setVisible(false)
				imgBox:setVisible(false)
				boxeff:setVisible(false)
				boxeff:stopAllActions()
				imgYlq:setVisible(false)
			end
		end
		local time = itemData.needTime-data.onlineTime--秒
		if time>0 then
			labTime:stopAllActions()
			labTime:setString(GameUtilSenior.setTimeFormat(time*1000,2))
			labTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
				time = time-1
				if time > 0 then
					labTime:setString(GameUtilSenior.setTimeFormat(time*1000,2))
				else
					labTime:stopAllActions()
					labTime:setVisible(false)
					btnLing:loadTextures("btn_online_2", "btn_online_2", "", ccui.TextureResType.plistType)--可领取
					imgBox:setVisible(true)
				end
			end)})))
		end
		-- print(data.onlineTime,itemData.needTime)
		-- item:getWidgetByName("labTime"):setString("在线"..(itemData.needTime/60).."分钟")
	end
	if not var.xmlOnline then return end
	local onlineList = var.xmlOnline:getWidgetByName("onlineList")
	onlineList:reloadData(#data.dataTable,updateOnlineList):setSliderVisible(false):setTouchEnabled(false)

	var.xmlOnline:getWidgetByName("weekAwardStr"):setString(data.weekAwardStr)
	var.xmlOnline:getWidgetByName("labOldWeek"):setString(data.oldWeekAward)
	var.xmlOnline:getWidgetByName("labWeek"):setString(data.newWeekAward)

	local labCount = var.xmlOnline:getWidgetByName("labOnlineTime")
	local time = data.onlineTime*1000
	labCount:stopAllActions()
	labCount:setString(GameUtilSenior.setTimeFormat(time,2))
	labCount:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
		time = time + 1000
		if time > 0 then
			labCount:setString(GameUtilSenior.setTimeFormat(time,2))
		else
			labCount:stopAllActions()
		end
	end)})))

	local btnLingWeek = var.xmlOnline:getWidgetByName("btnAwardWeek")
	if data.weekLing==1 then
		btnLingWeek:setTitleText("已领取"):setEnabled(false)
		btnLingWeek:removeChildByName("img_bln")
	else
		if data.oldWeekAward<=0 then
			btnLingWeek:setTitleText("领取"):setEnabled(false)
			btnLingWeek:removeChildByName("img_bln")
		else
			btnLingWeek:setTitleText("领取"):setEnabled(true)
			--GameUtilSenior.addHaloToButton(btnLingWeek, "btn_normal_light3")
		end
	end

end

function ContainerReward.onlineDesp()
	local mParam = {
		name = GameMessageCode.EVENT_PANEL_ON_ALERT,
		panel = "tips",
		infoTable = despOnline,
		visible = true,
	}
	GameSocket:dispatchEvent(mParam)
end
--------------------------------------------------------------在线奖励End------------------------------------------------------------------

function ContainerReward.createUiTable(parent,array)
	parent.ui = {};
	for _,v in ipairs(array) do
		local node = parent:getWidgetByName(v);
		if node then
			parent.ui[v] = node
		end
	end
	return parent.ui
end

--------------------------------------------------------------每日签到------------------------------------------------------------------

local daily_node = {"list_daily","lbl_daily_num","lbl_daily_title","lbl_daily_title_end","btn_daily_sign_in","lbl_daily_title","box_daily"}
function ContainerReward.initDaily()
	if not var.xmlDaily then
		var.xmlDaily=GUIAnalysis.load("ui/layout/ContainerReward_daily.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
							:align(display.LEFT_BOTTOM,0,-8)
							:show();
		GameUtilSenior.asyncload(var.xmlDaily, "box_daily", "ui/image/ContainerReward/img_ditu.jpg");
		ContainerReward.createUiTable(var.xmlDaily,daily_node);
	else
		var.xmlDaily:show();
	end
	GameSocket:PushLuaTable("gui.PanelDailySignIn.onPanelData", GameUtilSenior.encode({actionid = "init"}))
	return var.xmlDaily
end

function ContainerReward.updateDailyTab(data,noReplace)
	if data and GameUtilSenior.isTable(data) then
		var.dailyTabData = data;
		if not noReplace then
			var.xmlDaily.ui["list_daily"]:reloadData(table.nums(var.dailyTabData),function(subItem)
				local index = subItem.tag
				local needData = var.dailyTabData[index];
				local needDay = needData.day;
				local awardTab = needData.awards;
				local state = needData.state;

				subItem:getWidgetByName("lbl_daily_title_cell"):setString("累计签到"..needDay.."次")
				:setFontSize(22):setTextColor(GameBaseLogic.getColor(0xffd800)):enableOutline(GameBaseLogic.getColor(0x000000), 1);
				subItem:getWidgetByName("lbl_get_state"):setVisible(false);

				--subItem:getWidgetByName("btn_daily_receive"):setVisible(state==-1);
				--if state>=0 then subItem:getWidgetByName("img_daily_state"):loadTexture("img_daily_"..state,ccui.TextureResType.plistType) end
				if state == 0 then
					subItem:getWidgetByName("btn_daily_receive"):setTitleText("未达标"):setTitleColor(GameBaseLogic.getColor(0xf1ecc9)):setTouchEnabled(false)
					--subItem:getWidgetByName("lbl_get_state"):setVisible(true):setTextColor(GameBaseLogic.getColor(0xfcfc01)):setTitleText("未达标")
				elseif state == 1 then
					subItem:getWidgetByName("btn_daily_receive"):setTitleText("已领取"):setTitleColor(GameBaseLogic.getColor(0xf1ecc9)):setTouchEnabled(false)
					--subItem:getWidgetByName("lbl_get_state"):setVisible(true):setTextColor(GameBaseLogic.getColor(0xfcfc01)):setTitleText("已领取")
				else
					subItem:getWidgetByName("btn_daily_receive"):setTitleText("领取奖励"):setTouchEnabled(true)
				end
				subItem:getWidgetByName("btn_daily_receive"):addClickEventListener(function (sender)
					GameSocket:PushLuaTable("gui.PanelDailySignIn.onPanelData", GameUtilSenior.encode({actionid = "receiveCumulative",tag = index}))
				end)
				if awardTab then
					for i=1,5 do
						local modelItem = subItem:getWidgetByName("model_item_box_"..i);
						local awardOnce = awardTab[i];
						if awardOnce then
							awardOnce.parent = modelItem;
							GUIItem.getItem(awardOnce);
							modelItem:setSwallowTouches(false)
							modelItem:show();
						else
							modelItem:hide();
						end
					end
				end
			end)
		else
			var.xmlDaily.ui["list_daily"]:updateCellInView()
		end
	end
end

function ContainerReward.updateDailyOnceTab(state,tag)
	if state and tag and var.dailyTabData and var.dailyTabData[tag] then
		var.dailyTabData[tag].state = state;
		var.xmlDaily.ui["list_daily"]:updateCellInView()
	end
end

function ContainerReward.updateDailyReceive(receiveNum)
	local firstPosX = var.xmlDaily.ui["lbl_daily_title"]:getContentSize().width+var.xmlDaily.ui["lbl_daily_title"]:getPositionX()+15;
	var.xmlDaily.ui["lbl_daily_num"]:setString(receiveNum):setPositionX(firstPosX)
	:setFontSize(20):setTextColor(GameBaseLogic.getColor(0x18d129)):enableOutline(GameBaseLogic.getColor(0x000000), 1);
	firstPosX = firstPosX+var.xmlDaily.ui["lbl_daily_num"]:getContentSize().width+15;
	var.xmlDaily.ui["lbl_daily_title_end"]:setPositionX(firstPosX);
end

function ContainerReward.updateDailyReceiveBtn(receiveToday)
	local state = receiveToday and receiveToday>0
	var.xmlDaily.ui["btn_daily_sign_in"]:setTitleText(state and "已签到" or "签到"):setTouchEnabled(not state);
	if state then
		var.xmlDaily.ui["btn_daily_sign_in"]:loadTextures("btn_new2", "btn_new2", "", ccui.TextureResType.plistType):setTouchEnabled(false)
		:setContentSize(cc.size(108,45)):setScale9Enabled(true):setTitleColor(GameBaseLogic.getColor(0xffe08b))
		GUIAnalysis.attachEffect(var.xmlDaily.ui["btn_daily_sign_in"],"outline(7c2b03,1)")
	else
		var.xmlDaily.ui["btn_daily_sign_in"]:loadTextures("btn_qd", "btn_qd", "", ccui.TextureResType.plistType):setTouchEnabled(true)
		:setContentSize(cc.size(108,45)):setScale9Enabled(true)
	end
	var.xmlDaily.ui["btn_daily_sign_in"]:removeAllChildren()
	if not state then
		local pSize = var.xmlDaily.ui["btn_daily_sign_in"]:getContentSize()
		local effectSprite = cc.Sprite:create()
			:align(display.CENTER, 0.47 * pSize.width, 0.5 * pSize.height)
			:addTo(var.xmlDaily.ui["btn_daily_sign_in"])
			:setScale(1.8,0.7)
		local animate = cc.AnimManager:getInstance():getPlistAnimate(4, 65080, 4, 5,false,false,0,function(animate,shouldDownload)
							effectSprite:runAction(cca.repeatForever(animate))
							effectSprite:setScale(1.8,0.7)
							if shouldDownload==true then
								effectSprite:release()
							end
						end,
						function(animate)
							effectSprite:retain()
						end)
	end
	var.xmlDaily.ui["btn_daily_sign_in"]:addClickEventListener(function (sender)
		GameSocket:PushLuaTable("gui.PanelDailySignIn.onPanelData", GameUtilSenior.encode({actionid = "receiveToday"}))
	end)
end
--------------------------------------------------------------每日签到End------------------------------------------------------------------

--------------------------------------------------------------15日登录---------------------------------------------------------------------
local fifteen_node = {
	"model_cell_1",
	"list_fifteen",
	"img_bar_left",
	"img_bar",
	"img_bar_right",
	"img_sign_in_num",
	"img_receive_logo",
	"btn_receive",
	"img_receive_state",
	"model_item_box_1",
	"model_item_box_2",
	"model_item_box_3",
	"model_item_box_4",
	"model_item_box_5",
}

local fifteen_awards_type = {
	[1]  = "1.png",
	[2]  = "2.png",
	[3]  = "3.png",
	[4]  = "4.png",
	[5]  = "5.png",
	[6]  = "6.png",
	[7]  = "7.png",
	[8]  = "7.png",
	[9]  = "7.png",
	[10] = "7.png",
	[11] = "7.png",
	[12] = "7.png",
	[13] = "7.png",
	[14] = "7.png",
	[15] = "7.png",
}

function ContainerReward.initFifteen()
	if not var.xmlFifteen then
		var.xmlFifteen=GUIAnalysis.load("ui/layout/ContainerReward_fifteen.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
							:align(display.LEFT_BOTTOM,0,0)
							:show();
		GameUtilSenior.asyncload(var.xmlFifteen, "box_fifteen", "ui/image/ContainerReward/tab_fifteen_bg.jpg");
		ContainerReward.createUiTable(var.xmlFifteen,fifteen_node);
		var.xmlFifteen.ui["list_fifteen"]:setContentSize(cc.size(695,362))
			:setInnerContainerSize(cc.size(670,362))
			:setTouchEnabled(true)
			:setClippingEnabled(true)
			-- :setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
			:setDirection(ccui.ScrollViewDir.horizontal)
	  		:ignoreAnchorPointForPosition(true);
	  		-- :addClickEventListener(function ( ... )
	  		-- 	print(1123233243242)
	  		-- end)
		-- GUIFocusPoint.addUIPoint(var.xmlFifteen.ui["list_fifteen"], function (sender, touchType)
		-- 	print("0000000000000000000000", touchType)
		-- end)

	  	var.xmlFifteen.ui["model_cell_1"]:hide();
	  	var.fifteenCeels[1] = var.xmlFifteen.ui["model_cell_1"];
		
		GameUtilSenior.addEffect(var.xmlFifteen,"effectEquip",40,60003,{x=600,y=100},false,true)

	  	GameSocket:PushLuaTable("gui.PanelFifteenSignIn.onPanelData", GameUtilSenior.encode({actionid = "init"}))
	else
		var.xmlFifteen:show();
	end
	return var.xmlFifteen
end

local jumpPer = {0,12,22,32,42,52,62,72,82,93,100,100,100,100,100}

function ContainerReward.updateFifteenList(data,jumpNum)
	if data and GameUtilSenior.isTable(data) then
		var.fifteenTabData = data;
		local needJumpTag = nil;
		for tag,award in ipairs(data) do
			local needCell = var.fifteenCeels[tag];
			if not needCell then
				needCell = var.xmlFifteen.ui["model_cell_1"]:clone();
				needCell:setName("model_cell_"..tag);
				needCell:setAnchorPoint(cc.p(0.5,0.5));
				needCell:addTo(var.xmlFifteen.ui["img_bar"])
				needCell:getWidgetByName("btn_icon"):setTouchEnabled(true):setSwallowTouches(false)
				if var.fifteenCeels[tag-1] then
					local beforeCellPosX,beforeCellPosY = var.fifteenCeels[tag-1]:getPosition();
					local nowCellPosX = beforeCellPosX+needCell:getContentSize().width;
					needCell:setPosition(cc.p(nowCellPosX,beforeCellPosY));
				end
				needCell.tag = tag;
				var.fifteenCeels[tag] = needCell;
			end
			local state = award.state;
			ContainerReward.updateFifteenCell(tag)
			if not needJumpTag and state ==-1 then
				needJumpTag = tag;
			end
			if state==-1 then
				--GameUtilSenior.addHaloToButton(needCell:getWidgetByName("icon_bg"), "btn_normal_light11")
			else            --已领取和未达成的
				needCell:removeChildByName("img_bln")
				--GameUtilSenior.removeHaloToButton(needCell:getWidgetByName("icon_bg"), "btn_normal_light11")
			end
		end
		local cellsNum = table.nums(var.fifteenCeels);
		local needWidth = (cellsNum-1)*var.xmlFifteen.ui["model_cell_1"]:getContentSize().width;
		local barLength = needWidth+2*var.xmlFifteen.ui["model_cell_1"]:getPositionX();
		local rightbarPosX = var.xmlFifteen.ui["img_bar"]:getPositionX()+barLength;
		var.xmlFifteen.ui["img_bar"]:ignoreContentAdaptWithSize(false)
			:setContentSize(cc.size(barLength,var.xmlFifteen.ui["img_bar_left"]:getContentSize().height));
		var.xmlFifteen.ui["img_bar_right"]:setPositionX(rightbarPosX);
		var.xmlFifteen.ui["list_fifteen"]:setInnerContainerSize(cc.size(var.xmlFifteen.ui["img_bar"]:getPositionX()*2+barLength,var.xmlFifteen.ui["list_fifteen"]:getContentSize().height));
		needJumpTag = needJumpTag or 1;
		-- ContainerReward.updateFifteenAwardBox({["tag"]=needJumpTag});
		local needCell = var.fifteenCeels[needJumpTag];
		local cellPosX,cellPosY = needCell:getPosition()
		local needJumpPos = var.xmlFifteen.ui["list_fifteen"]:getInnerContainer():convertToNodeSpace(var.xmlFifteen.ui["img_bar"]:convertToWorldSpace(cc.p(cellPosX,cellPosY)));
		local innerSize = var.xmlFifteen.ui["list_fifteen"]:getInnerContainerSize();
		local perect = needJumpPos.x/innerSize.width*100;

		var.xmlFifteen.ui["list_fifteen"]:jumpToPercentHorizontal(jumpPer[jumpNum]);

		--ContainerReward.updateFifteenAwardBox({["tag"]=jumpNum});
	end
end

function ContainerReward.updateFifteenOnceData(state,tag)
	if state and tag and var.fifteenTabData and var.fifteenTabData[tag] then
		var.fifteenTabData[tag].state = state;
		ContainerReward.updateFifteenCell(tag,true)
	end
end

function ContainerReward.updateFifteenAwardBox(cell)
	-- print("11111111111111", cell.tag)
	var.xmlFifteen:getWidgetByName("img_sign_in_bg_font"):setVisible(false)
	var.xmlFifteen:getWidgetByName("btn_receive"):setVisible(false)
	
	local tag = cell.tag;
	var.fifteenNowSelect = tag;
	local needData = var.fifteenTabData[tag];
	local awardTab = needData.awards;
	local state = needData.state;
	local aType = needData.aType
	-- print("AAAAA",aType)
	--GameUtilSenior.asyncload(var.xmlFifteen, "img_award_bg", "ui/image/ContainerReward/tab_fifteen_"..fifteen_awards_type[aType]..".jpg");
	var.xmlFifteen.ui["img_receive_logo"]:loadTexture("txt_"..fifteen_awards_type[aType],ccui.TextureResType.plistType)
	-- var.xmlFifteen.ui["img_sign_in_num"]:loadTexture("img_fifteen_num_"..tag,ccui.TextureResType.plistType):setVisible(false)
	var.xmlFifteen.ui["img_sign_in_num"]:setVisible(false)
	--[[
	if not var.xmlFifteen.ui["dayNum"] then
		var.xmlFifteen.ui["dayNum"]= display.newBMFontLabel({font = "image/typeface/num_9.fnt",})
				:addTo(var.xmlFifteen)
				:align(display.CENTER, 120,315)
				:setString(tag)              --登录天数
	else
		var.xmlFifteen.ui["dayNum"]:setString(tag)
	end
	]]--
	var.fifteenCeels[var.curFifTag]:getWidgetByName("imgFifteenSelect"):setVisible(false)
	var.fifteenCeels[var.curFifTag]:getWidgetByName("lbl_day_num"):setColor(GameBaseLogic.getColor(0xfddfae))
	var.fifteenCeels[tag]:getWidgetByName("imgFifteenSelect"):setVisible(true)
	var.fifteenCeels[tag]:getWidgetByName("lbl_day_num"):setColor(GameBaseLogic.getColor(0xFF681E))
	var.curFifTag=tag
	if awardTab then
		for i=1,5 do
			local modelItem = var.xmlFifteen.ui["model_item_box_"..i]
			local awardOnce = awardTab[i];
			if awardOnce then
				awardOnce.parent = modelItem;
				GUIItem.getItem(awardOnce);
				modelItem:show();
			else
				modelItem:hide();
			end
		end
	end;

	if state>=0 then var.xmlFifteen.ui["img_receive_state"]:loadTexture("img_daily_"..state,ccui.TextureResType.plistType) end
	var.xmlFifteen.ui["btn_receive"]:setTouchEnabled(state==-1)
		:setVisible(state==-1)
		:addClickEventListener(function (sender)
			GameSocket:PushLuaTable("gui.PanelFifteenSignIn.onPanelData", GameUtilSenior.encode({actionid = "receive",tag = tag}))
		end);
end

function ContainerReward.updateFifteenCell(tag,updateBox)
	local needCell = var.fifteenCeels[tag] ;
	if needCell and var.fifteenTabData and var.fifteenTabData[tag] then
		local award =  var.fifteenTabData[tag];
		local state = award.state;
		local aType = award.aType
		-- needCell:getWidgetByName("icon_name"):ignoreContentAdaptWithSize(false)
		-- 	:setContentSize(cc.size(100,20));
		-- print("BBBBBBB",aType)
		needCell:getWidgetByName("lbl_day_num"):setString("第"..GameUtilSenior.numberToChinese(tag).."天");
		local bgButton = needCell:getWidgetByName("btn_icon");
		local iconName = needCell:getWidgetByName("icon_name");
		iconName:loadTexture("lbl_"..fifteen_awards_type[aType],ccui.TextureResType.plistType)
		bgButton.tag = tag;
		bgButton:loadTextureNormal("icon_"..fifteen_awards_type[aType],ccui.TextureResType.plistType)
			:loadTexturePressed("icon_"..fifteen_awards_type[aType],ccui.TextureResType.plistType)
			-- :setTouchEnabled(state~=0)
			-- :setBright(state~=0)
			:addClickEventListener(ContainerReward.updateFifteenAwardBox)
			:setSwallowTouches(false)

		needCell:getWidgetByName("img_award_state"):setVisible(state==1);
		needCell:show();
		needCell:removeChildByName("img_bln")
		if updateBox then
			ContainerReward.updateFifteenAwardBox({["tag"]=tag});
		end
	end
end

--------------------------------------------------------------15日登录End---------------------------------------------------------------------

--------------------------------------------------------------激活码兑换---------------------------------------------------------------------
function ContainerReward.initCDK()
	if not var.xmlCDK then
		var.xmlCDK=GUIAnalysis.load("ui/layout/ContainerReward_cdk.uif")
							:addTo(var.xmlPanel:getWidgetByName("tabBox"))
							:align(display.LEFT_BOTTOM,0,0)
							:show();
		GameUtilSenior.asyncload(var.xmlCDK, "cdkBg", "ui/image/ContainerReward/img_cdk_bg.jpg");
		-- ContainerReward.createUiTable(var.xmlCDK,daily_node);

		local label_input = var.xmlCDK:getWidgetByName("label_input_bg")
		var.mSendText = GameUtilSenior.newEditBox({
			image = "image/icon/null.png",
			size = label_input:getContentSize(),
			x = 0,
			y = 0,
			fontSize = 22,
			placeHolderSize = 22,
		})
		var.mSendText:setPlaceHolder(GameConst.str_input)
		var.mSendText:setString("")
		var.mSendText:setAnchorPoint(cc.p(0,0))
		label_input:addChild(var.mSendText,1,100)

		local btnCdk = var.xmlCDK:getWidgetByName("btnCdk")
		btnCdk:addClickEventListener(function ()
			local text = var.mSendText:getText()
			if string.len(text)>0 then
				if GameSocket:isBagFull() then
					return GameSocket:alertLocalMsg("背包已满，先清理再兑换！", "alert")
				end
				GameHttp:requestCDKey(text,var.xmlCDK)
				var.mSendText:setString(GameConst.str_input)
			else
				GameSocket:alertLocalMsg("请输入正确的激活码！", "alert")
			end
		end)
	else
		var.xmlCDK:show()
		var.mSendText:setString(GameConst.str_input)
	end
	-- var.mSendText:setString(GameConst.str_input)
	return var.xmlCDK
end

return ContainerReward