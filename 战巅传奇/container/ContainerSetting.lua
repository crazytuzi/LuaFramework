local ContainerSetting = {}
local var = {}

local sysBtnName = {"btn_change_role", "btn_change_account", "btn_contact"}
local pages = {
	{
		{ checkbox = "ckbox1",	con = "SmartEatHP",		name="智能吃药"},
		{ checkbox = "ckbox2",	con = "SmartLowHP",		name="生命值低回城"},
		{ checkbox = "ckbox3",	con = "AutoPickDrug",	name="自动拾取药品"},
		{ checkbox = "ckbox4",	con = "AutoPickStaff",	name="自动拾取材料"},
		{ checkbox = "ckbox5",	con = "AutoPickEquip",	name="自动拾取装备"},
		{ checkbox = "ckbox6",	con = "SmartEatMP",		name="智能回魔"},
		{ checkbox = "ckbox7",	con = "AutoPickCoin",	name="自动拾取元宝"},
		{ checkbox = "ckbox8",	con = "AutoPickOther",	name="自动拾取其他"},
	},
	{
		{ checkbox = "cbox1",	con = "ShieldMonster",	name="屏蔽普通怪物"},
		{ checkbox = "cbox2",	con = "ShieldPet",		name="屏蔽战神和道士宝宝"},
		{ checkbox = "cbox3",	con = "ShieldWing",		name="屏蔽翅膀"},
		{ checkbox = "cbox4",	con = "ShieldGuild",	name="屏蔽本公会玩家"},
		{ checkbox = "cbox5",	con = "ShieldAllPlayer",name="屏蔽所有玩家"},
		{ checkbox = "cbox6",	con = "ShieldTitle",	name="屏蔽称号"},
		{ checkbox = "cbox7",	con = "ShieldShadow",	name="屏蔽影子"},
		{ checkbox = "cbox8",	con = "ShieldRedWaring",name="屏蔽全屏闪红"},
		{ checkbox = "cbox9",	con = "SwitchMusic",	name="屏蔽背景音乐"},
		{ checkbox = "cbox10",	con = "SwitchEffect",	name="屏蔽背景音效"},
		{ checkbox = "cbox11",	con = "ShieldAddFriend",name="拒绝他人加我好友"},--
		{ checkbox = "cbox12",	con = "CloseTrade",		name="拒绝他人向我发起交易"},
		{ checkbox = "cbox13",	con = "SaveEnergy",		name="开启节能模式"},
		{ checkbox = "cbox14",	con = "OpenRocker",		name="开启摇杆"},
	},
}

local percentKey ={
	["modelbox1"] = {con = "SmartEatHPPercent",	},
	["modelbox2"] = {con = "SmartLowHPPercent",	},
	["modelbox3"] = {con = "AutoPickEquipLevel",},
	["modelbox4"] = {con = "SmartEatMPPercent",	},
}

local transStone = {
	["回城石"] = 32010002,
	["随机传送石"] = 32010003,
}

function ContainerSetting.initView()
	var = {
		xmlPanel,
		pageinit = {},
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerSetting.uif")
	if var.xmlPanel then

		local function pushBtnGuide(sender)
			local tag = sender:getTag()
			var.xmlPanel:getWidgetByName("page1"):setVisible(tag == 1)
			var.xmlPanel:getWidgetByName("page2"):setVisible(tag == 2)
			ContainerSetting.refreshPage(tag)
			var.pageinit[tag] = true;
		end
		-- var.xmlPanel:getWidgetByName("pagebg1"):loadTexture("ui/image/img_setting_1.jpg",ccui.TextureResType.localType)
		-- var.xmlPanel:getWidgetByName("pagebg2"):loadTexture("ui/image/img_setting_2.jpg",ccui.TextureResType.localType)

		var.xmlPanel:getWidgetByName("page_tab"):addTabEventListener(pushBtnGuide)
		local function pushSysBtn(sender)
			local btn_name = sender:getName()
			if btn_name == sysBtnName[1] then
				GameBaseLogic.ExitToReSelect()
			elseif btn_name == sysBtnName[2] then
				GameBaseLogic.ExitToRelogin()
			elseif btn_name == sysBtnName[3] then
				GameBaseLogic.ShowExit()
			end
		end
		for i,v in ipairs(sysBtnName) do
			var.xmlPanel:getWidgetByName(v):addClickEventListener(pushSysBtn)
			local btn_change_role = var.xmlPanel:getWidgetByName(v)
			--GUIAnalysis.attachEffect(btn_change_role,"outline(076900,1)")
		end
		for k,v in pairs(percentKey) do
			local box = var.xmlPanel:getWidgetByName(k)
			if box then
				ContainerSetting.initPercentBox( box,k )
			end
		end

		if PLATFORM_BANSHU then
			var.xmlPanel:getWidgetByName("page_tab"):hideTab(2)
		end
		var.xmlPanel:getWidgetByName("page_tab"):setTabRes("tab_v4","tab_v4_sel",ccui.TextureResType.plistType)
		
			
		ContainerSetting.updateGameMoney()
		var.xmlPanel:getWidgetByName("box_tab"):setSelectedTab(1)
		var.xmlPanel:getWidgetByName("box_tab"):addTabEventListener(ContainerSetting.pushTabButtons)
		
		return var.xmlPanel
	end
end


function ContainerSetting.pushTabButtons(sender)
	local opened, level, funcName
	opened = true
	local tag = sender:getTag()
	var.xmlPanel:getWidgetByName("page1"):setVisible(tag == 1)
	var.xmlPanel:getWidgetByName("page2"):setVisible(tag == 2)
	ContainerSetting.refreshPage(tag)
	var.pageinit[tag] = true;
end

--金币刷新函数
function ContainerSetting:updateGameMoney()
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

function ContainerSetting.onPanelOpen()
	var.pageinit = {};
	var.xmlPanel:getWidgetByName("page_tab"):setSelectedTab(1)
	var.xmlPanel:getWidgetByName("lbl_name"):setString(GameCharacter._mainAvatar:NetAttr(GameConst.net_name))
	local job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
	local gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
	var.xmlPanel:getWidgetByName("lbl_job"):setString(GameConst.job_name[job])
	var.xmlPanel:getWidgetByName("lbl_lv"):setString(GameCharacter._mainAvatar:NetAttr(GameConst.net_level).."级")

	local id = (job-100) * 2 + gender - 199
	local head_key ={"new_main_ui_head.png","head_fzs","head_mfs","head_ffs","head_mds","head_fds"}
	var.xmlPanel:getWidgetByName("img_head"):setScale(1):loadTexture(head_key[id], ccui.TextureResType.plistType);

	local data = {"回城石","随机传送石"}
	ContainerSetting.initMultiSelectBtn(data,table.keyof(transStone,GameSetting.getConf("SmartLowHPItem")))
end

function ContainerSetting.refreshPage(curIndex)
	local btns = pages[curIndex]
	local b = nil
	local click = function( sender )
		GameSetting.setConf(sender.con,sender:isSelected())
	end
	for k,v in pairs(btns) do
		b =	var.xmlPanel:getWidgetByName(v.checkbox)
		b:setSelected(GameSetting.getConf(v.con))
		b.con = v.con
		b:addClickEventListener(click)
	end
end

function ContainerSetting.initMultiSelectBtn(data,selected)
	local modelmultichoose = var.xmlPanel:getWidgetByName("modelmultichoose")
	local btn_arrow_down = var.xmlPanel:getWidgetByName("btn_arrow_down")
	local choosebtns = {}
	local function clickArrow(sender)
		if not sender.show then
			sender.show = true
			for i,v in ipairs(choosebtns) do
				v:runAction(cca.seq({
					cca.show(),
					cca.place(63, 13 - (i-1)*27),
				}))
			end
		else
			sender.show = false
			for i,v in ipairs(choosebtns) do
				v:runAction(cca.seq({
					cca.place(63, 13),
					cca.cb(function(target) target:setVisible(target.tag ==1) end)
				}))
			end
		end
	end
	-- local selected = data[1]
	local function clickItem(sender)
		clickArrow(btn_arrow_down)
		if sender.tag>1 then
			selected = sender:getTitleText()
			choosebtns[sender.tag]:setTitleText(choosebtns[1]:getTitleText())
			choosebtns[1]:setTitleText(selected)
			if transStone[selected] then
				GameSetting.setConf("SmartLowHPItem", transStone[selected])
			end
		end
	end
	for i=1,#data do
		local btn = modelmultichoose:getWidgetByName("choose"..i)
		if btn then
			btn:setTitleText(data[i])
			table.insert(choosebtns,btn)
			btn.tag = i
			btn:setPosition(cc.p(63,13)):setVisible(i==1)
			btn:addClickEventListener(clickItem)
			if data[i] == selected then
				clickItem(btn)
			end
		end
	end
	btn_arrow_down.show = false
	btn_arrow_down:addClickEventListener(clickArrow)
end

function ContainerSetting.initCheckBtn(btn, btnName)
	local function pushCheckBtn(sender)
		sender.enabled = not sender.enabled
		GameSetting.setConf(btnName,sender.enabled)
	end
	btn.enabled = GameSetting.getConf(btnName)
	btn:addClickEventListener(pushCheckBtn)
end

function ContainerSetting.initPercentBox( widget,bindName )
	local btn_descrase = widget:getWidgetByName("btn_descrase")
	local lbl_percent = widget:getWidgetByName("lbl_percent")
	local btn_add = widget:getWidgetByName("btn_add")
	local formatStr = "%d%%"
	if percentKey[bindName] then
		widget.percent = GameSetting.getConf(percentKey[bindName].con)
		if not widget.percent then
			widget.percent = 60;
			GameSetting.setConf(percentKey[bindName].con, widget.percent)
		end
	end
	local setString = function()
		local str = ""
		if percentKey[bindName].con == "AutoPickEquipLevel" then
			widget.percent = GameUtilSenior.bound(0,widget.percent,180)
			if widget.percent>=100 then
				formatStr = "%d转";str = (widget.percent-90)/10;
			else
				formatStr = "%d级";str=widget.percent;
			end
		else
			widget.percent = GameUtilSenior.bound(10,widget.percent,90)
			str = widget.percent
		end
		lbl_percent:setString(string.format(formatStr,str))
	end
	local function click(sender)
		if sender:getName() == "btn_descrase" then
			widget.percent = widget.percent -10
		else
			widget.percent = widget.percent +10
		end
		setString()
		if percentKey[bindName] then
			GameSetting.setConf(percentKey[bindName].con, widget.percent)
		end
	end
	setString()
	btn_descrase:addClickEventListener(click)
	btn_add:addClickEventListener(click)
end

function ContainerSetting.onPanelClose()
	-- for m,n in pairs(pages) do
	-- 	if var.pageinit[m] then
	-- 		for k,v in pairs(n) do
	-- 			GameSetting.getConf(v.con,var.xmlPanel:getWidgetByName(v.checkbox):isSelected())
	-- 		end
	-- 	end
	-- end
	GameSetting.save()
end

return ContainerSetting