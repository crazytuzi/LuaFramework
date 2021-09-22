local ContainerGang = {}

local var = {}

local pageKeys = {
	"info", "member", "depot", "pray", "list", "apply", "hongbao", "log",
}

local tabKeys = {
	--"info", "member", "depot", "pray", "list",
	"info", "member", "list",
}

-- 屏蔽祈祷
local noPray = false;

if noPray then
	pageKeys = {
		"info", "member", "depot", "list", "apply", "hongbao", "log",
	}
	tabKeys = {
		"info", "member", "depot", "list",
	}
end

local orignY = 415

local gapY = 80

local TAG_GUILD={
	TAG_GUILD_LIST = 1,
	TAG_GUILD_MEMBER = 2,
	TAG_GUILD_APPLY =3,
	TAG_GUILD_UPGRADE =4,
	TAG_GUILD_SHOP =5,
	TAG_GUILD_FUBEN =6,
	TAG_GUILD_PANEL_MAX =7,

	GUILD_TITLE_NONE=0,
	GUILD_TITLE_TYPE_OUT=100,
	GUILD_TITLE_TYPE_ENTERING=101,
	GUILD_TITLE_TYPE_NORMAL=102,
	GUILD_TITLE_TYPE_ADV=200,
	GUILD_TITLE_TYPE_VICEADMIN = 300,
	GUILD_TITLE_TYPE_ADMIN=1000,

	LIST_TYPE_ENTERING_MEMBER=100,
	LIST_TYPE_REAL_MEMBER=101,
}

local GUILD_TITLE = {
	[1000]="帮主",[300] = "副帮主", [200]="长老",[102]="普通会员",
}

local MEMBER_TYPE = {
 	ENTERING = 100,
 	REALMEMBER=101,
}

local GUILD_WAR_TIME = 1440;


local guildHint = {
	["info"] = {
		"<font color=#E7BA52 size=18>帮会说明</font>",
		'1．捐献金币或装备会增加帮会财富',
		'2．帮会财富满后自动升级；升级帮会后容纳人数减少',
		'3．每日通过捐献装备获得的帮会财富有上限',
		'4．捐献金币可获得帮会财富，捐献金币无每日上限',
		'5．连续14天无帮会成员在线，帮会自动解散',
	},

	["pray"] = {
		"<font color=#E7BA52 size=18>神树说明</font>",
		'  1.帮会神树提升的属性为个人属性',
		'  2.退出帮会后，神树属性加成的效果消失，神树等级保留',
		'  3.再次加入帮会属性才生效',
	},

	["hongbao"] = {
		"<font color=#E7BA52 size=18>帮会红包说明</font>",
		'1．所有本帮成员均可发放红包，也可参与抢红包',
		'2．所抢红包金额随机发放',
		'3．红包有效时间为：<font color=#ff0000>24小时</font>',
		'4．红包过期后剩余元宝通过邮件返还',
	},
}

local function createEditBox(param)
	local bindLabel = param.bindLabel
	local endCallFunc = param.endCallFunc
	local function onEdit(event,editBox)
		print("editBox:"..editBox:getName()..",event:"..event)
		if event == "began" then

		elseif event == "changed" then

		elseif event == "ended" then
		elseif event == "return" then
			endCallFunc()
		end
	end
	param.listener = onEdit
	local editBox = GameUtilSenior.addEditBoxTo(param)

	return editBox
end

--获取申请时间
local function getApplyTime(name)
	if name then
		for i,v in ipairs(var.mGuildApply) do
			if v.name == name then
				return v.entertime
			end
		end
	end
	return 0
end

local function getSortedMemebrs(memberType)
	local rankeMap = {}
	var.mAdvNum = 0
	local mGuild = GameSocket:getGuildByName(GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name))
	if not mGuild then return end
	local memberMap = mGuild.mRealMembers
	local enterMap  = mGuild.mEnteringMembers
	-- print("mGuild.mRealMembers", mGuild.mRealMembers)
	-- print("mGuild.mEnteringMembers", mGuild.mEnteringMembers)
	local listmap = {}
	if memberType == MEMBER_TYPE.REALMEMBER then
		listmap = memberMap
	elseif memberType == MEMBER_TYPE.ENTERING then
		listmap = enterMap
	end
	if not listmap then return end
	local member
	local onlineMebmber = {}
	local onlineNum = 0
	local totalNum = 0
	for k,v in pairs(listmap) do
		if memberType == MEMBER_TYPE.ENTERING or (memberType == MEMBER_TYPE.REALMEMBER and v.title > TAG_GUILD.GUILD_TITLE_TYPE_OUT) then
			member = {}
			if v.title ==200 then var.mAdvNum = var.mAdvNum+1 end
			member.com = v.title
			member.name    = v.nick_name
			member.title   = v.title
			member.level   = v.level
			member.online  = v.online
			member.gender  = v.gender
			member.job     = v.job
			member.guildpt = v.guildpt
			member.fight = v.fight
			member.entertime  = v.entertime
			table.insert(rankeMap,member)
			if member.online and member.online == 1 then
				table.insert(onlineMebmber,member)
			end
			
		end
	end
	totalNum = #rankeMap
	onlineNum = #onlineMebmber
	if var.showOnlineMember and memberType == MEMBER_TYPE.REALMEMBER then
		rankeMap = onlineMebmber
	end
	local compFunc = function(member1, member2)
		if member1.com == member2.com then
			return member1.level > member2.level
		else
			return member1.com > member2.com
		end
	end
	table.sort(rankeMap, compFunc )
	return rankeMap,onlineNum,totalNum
end

local function getSortedGuilds()
	local mGuildList = GameSocket.mGuildList
	local mGuilds = {}
	local compFunc = function(guild1,guild2)
		if guild1.mLevelGuild == guild2.mLevelGuild then
			return guild1.mMemberNumber > guild2.mMemberNumber
		else
			return guild1.mLevelGuild > guild2.mLevelGuild
		end
	end
	for k,v in pairs(mGuildList) do
		local guild = {}
		guild.mName			= v.mName
		guild.mMemberNumber	= v.mMemberNumber
		guild.mLeader			= v.mLeader
		guild.mLevelGuild		= v.mLevelGuild
		guild.entering			= v.entering
		guild.mWarStatus		= v.mWarStatus
		guild.mWarStartTime		= v.mWarStartTime
		guild.mGuildSeedId		= v.mGuildSeedId
		guild.chartIndex		= k
		table.insert(mGuilds, guild)
	end
	table.sort(mGuilds, compFunc )
	for i=1,#mGuilds do
		mGuilds[i].chartIndex = i
	end
	return mGuilds
end

local function getGuildByName(pName)
	for i=1,#var.mSortedGuilds do
		if var.mSortedGuilds[i].mName == pName then
			return var.mSortedGuilds[i]
		end
	end
	return nil
end

local function getMyGuildTitle()
	if GameCharacter._mainAvatar and GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name) ~= "" then
		return GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_title)
	end
	return TAG_GUILD.GUILD_TITLE_TYPE_OUT
end

local function hasGuild()
	if getMyGuildTitle() > TAG_GUILD.GUILD_TITLE_TYPE_ENTERING then
		return true;
	end
end

local function isGuildAdmin()
	if getMyGuildTitle() == TAG_GUILD.GUILD_TITLE_TYPE_ADMIN then
		return true;
	end
end

local function getMyGuildName()
	if GameCharacter._mainAvatar then
		local guildName = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
		if guildName then
			return guildName
		end
	end
	return nil
end

local function getMyGuildChart()
	if var.myGuildName and var.myGuildName ~= "" then
		for i,v in ipairs(var.mSortedGuilds) do
			if var.myGuildName == v.mName then
				return v.chartIndex
			end
		end
	end
	return ""
end

local function hideAllPages()
	local pageName
	for i,v in ipairs(pageKeys) do
		pageName = "xmlPage"..string.ucfirst(v)
		if var[pageName] then
			var[pageName]:hide()
			if pageName == "xmlPageInfo" then
				var[pageName]:getWidgetByName("edit_guild_notice"):hide()
			end
		end
	end
end
 -- page变量，初始化函数，刷新函数使用字符窜拼接
local function showPanelPage(key)
	if not (key and table.indexof(pageKeys, key))then return end
	hideAllPages()
	local pageName = "xmlPage"..string.ucfirst(key)
	local initFunc = "initPage"..string.ucfirst(key)
	local openFunc = "openPage"..string.ucfirst(key)
	if not var[pageName] and ContainerGang[initFunc] then
		ContainerGang[initFunc]()
	end
	if var[pageName] then
		if ContainerGang[openFunc] then
			ContainerGang[openFunc]()
		end
		var[pageName]:show()
	end
	var.mCurPageKey = key
end

local function pushTabButtons(sender, touchType)
	local key = sender.key
	if key == "pray" and var.mGuildLevel < 2 then
		return GameSocket:alertLocalMsg("帮会2级开启帮会祈祷", "alert")
	end
	local btnGuildTab, lblTitle
	local boxTab = var.xmlPanel:getWidgetByName("box_tab")
	if touchType == ccui.TouchEventType.ended then
		for _,v in ipairs(tabKeys) do
			btnGuildTab = boxTab:getWidgetByName("btn_guild_"..v)
			lblTitle = btnGuildTab:getWidgetByName("lbl_title")
			if key == v then
				btnGuildTab:setBrightStyle(ccui.BrightStyle.highlight)
				lblTitle:setColor(GameBaseLogic.getColor(0xeab065))
			else
				btnGuildTab:setBrightStyle(ccui.BrightStyle.normal)
				lblTitle:setColor(GameBaseLogic.getColor(0xb6aa9a))
			end
		end
		showPanelPage(key)
		var.mPrePageKey = key
	end
	if touchType == ccui.TouchEventType.canceled and var.mPrePageKey == key then
		sender:setBrightStyle(ccui.BrightStyle.highlight)
		sender:getChildByName("lbl_title"):setColor(GameBaseLogic.getColor(0xeab065))
	end
end

local function updateTabButtons()
	local hasGuild = hasGuild()
	local btnGuildTab
	local boxTab = var.xmlPanel:getWidgetByName("box_tab")
	for i,v in ipairs(tabKeys) do
		btnGuildTab = boxTab:getWidgetByName("btn_guild_"..v)
		if hasGuild then
			btnGuildTab:show():setPositionY(orignY - (i - 1) * gapY)
		else
			if v == "list" then
				btnGuildTab:show():setPositionY(orignY)
			else
				btnGuildTab:hide()
			end
		end
	end
end

local function initBoxTabs()
	local btnGuildTab

	-- var.xmlPanel:getWidgetByName("box_tab"):setLocalZOrder(100)
	local boxTab = var.xmlPanel:getWidgetByName("box_tab")
	boxTab:setLocalZOrder(100)
	for _,v in ipairs(tabKeys) do
		btnGuildTab = boxTab:getWidgetByName("btn_guild_"..v)
		btnGuildTab.key = v
		GUIFocusPoint.addUIPoint(btnGuildTab, pushTabButtons, true)
	end
	if noPray then
		var.xmlPanel:getWidgetByName("btn_guild_pray"):hide()
		var.xmlPanel:getWidgetByName("btn_guild_list"):pos(var.xmlPanel:getWidgetByName("btn_guild_pray"):getPosition())
	end

	local btnTabMember = var.xmlPanel:getWidgetByName("btn_guild_member")
	if not btnTabMember then return end
	GUIFocusDot.addRedPointToTarget(btnTabMember)
end

local function onPanelData(event)
	if event.type == "ContainerGang" then
		local data = GameUtilSenior.decode(event.data)
		if not data then return end
		if data.cmd =="createGuild" then
			-- ContainerGang.onPanelOpen()
		elseif data.cmd == "redPacket" then
			--帮会红包红点检测
			local btnTabMember = var.xmlPanel:getWidgetByName("btn_guild_member")
			if not btnTabMember then return end
			local redPoint = btnTabMember:getWidgetByName("redPoint")
			if redPoint then
				redPoint:setVisible(data.showRedPoint and true or false)
			end
		end
	end
end

local function onGetMyGuildName(event)
	var.myGuildName = getMyGuildName()
	if event.guildChanged then
		ContainerGang.onPanelOpen()
	end
end


local function createNumInputEditBox(params)
	if not (params and params.root and params.lblName and params.pName) then
		return
	end
	local updateFunc = params.updateFunc
	local lblEditBox = params.root:getWidgetByName(params.lblName):setString("")
	local imgEditbox = params.root:getWidgetByName(params.pName)
	local param = {
		parent = imgEditbox,
		color = 0xfddfae,
		fontSize = 18,
		inputMode = cc.EDITBOX_INPUT_MODE_NUMERIC,
		listener = nil, -- 监听函数
		bindLabel = lblEditBox,
		endCallFunc = function ()
			-- if inputText and tonumber(inputText) then
				if GameUtilSenior.isFunction(updateFunc) then
					updateFunc(tonumber(inputText))
				end
			-- end
		end
	}
	local mEditBox = createEditBox(param)
	return mEditBox
end

local function checkAndDismissGuild()
	local param = {
		name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "你确认解散帮会吗？帮会仓库内的所有东西将消失", btnConfirm = "确认",btnCancel ="取消",
		confirmCallBack = function ()
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "dismissGuild"}))
		end
	}
	GameSocket:dispatchEvent(param)
end

local function checkAndLeaveGuild()
	local param = {
		name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "主动退出帮会贡献之清零,你确认要退出帮会吗", btnConfirm = "确认",btnCancel ="取消",
		confirmCallBack = function ()
			GameSocket:LeaveGuild(var.myGuildName)
		end
	}
	GameSocket:dispatchEvent(param)
end

---------------------------------------以上为内部函数---------------------------------------
function ContainerGang.initView(event)
	var = {
		boxTab,
		xmlPanel,
		panelBg,

		mCurPageKey,
		mPrePageKey,

		--帮会列表相关
		mSortedGuilds = {},

		--帮会成员
		mAdvNum = 0,
		mGuildMembers = {},

		--帮会信息
		myGuildName,
		mGuildNotice = "",
		mDonateMoney = 1, --帮会捐献
		mGuildAssets,

		mGuildLevel = 0,

		isEditingNotice = false,

		--帮会申请
		mGuildApply = {},

		mSelectedApplicants = {},

		--帮会仓库
		mDepotJob = false,
		mDepotConvertible = false,
		myGuildPoint = 0,

		--帮会红包
		mHongBaoVcoin = 0,
		mHongBaoNum = 0,
		mHongBaoTime = 0,
		mHongBaoLogs = {},
		mHongBaoGot = 0,

		--帮会祈祷
		mGuildPrayIndex = 1,

		showOnlineMember = false,
	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerGang.uif")

	if var.xmlPanel then
		initBoxTabs()
		
		ContainerGang.updateGameMoney()

		cc.EventProxy.new(GameSocket, var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, onPanelData)
			:addEventListener(GameMessageCode.EVENT_GUILD_MSG, onGetMyGuildName)
		return var.xmlPanel
	end
end


--金币刷新函数
function ContainerGang:updateGameMoney()
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

function ContainerGang.onPanelOpen(extend)
	updateTabButtons()
	var.mSortedGuilds = getSortedGuilds()
	if hasGuild() then
		pushTabButtons(var.xmlPanel:getWidgetByName("btn_guild_info"), ccui.TouchEventType.ended)
		if extend then
			if extend.page == "apply" then
				showPanelPage("apply")
			elseif extend.page == "hongbao" then
				showPanelPage("hongbao")
			end
		end
	else
		pushTabButtons(var.xmlPanel:getWidgetByName("btn_guild_list"), ccui.TouchEventType.ended)
	end

	GameSocket:PushLuaTable("gui.ContainerGang.onPanelData",GameUtilSenior.encode({actionid = "checkRedPacket"}))
	local btnTabMember = var.xmlPanel:getWidgetByName("btn_guild_member")
	if not btnTabMember then return end
	-- GUIFocusDot.addRedPointToTarget(btnTabMember)
	local redPoint = btnTabMember:getChildByName("redPoint")
	if not redPoint then return end
	redPoint:setVisible(false)
end

function ContainerGang.onPanelClose()
	GameSocket.tipsMsg["tip_guild"] = {}
	var.mCurPageKey = nil
end

--------------------------------------帮会信息--------------------------------------
local MAX_DONATE_NUM = 21000;

local function updateGuildDonate(num)
	local editDonateMoney = var.xmlPageInfo:getWidgetByName("edit_donate_money")
	num = tonumber(editDonateMoney:getText())
	num = num or 0
	if num * 10000 > GameSocket.mCharacter.mGameMoney then
		num = math.floor(GameSocket.mCharacter.mGameMoney / 10000)
		if num > MAX_DONATE_NUM then num = MAX_DONATE_NUM end
	end
	if num < 1 then
		num = 1
	end
	var.mDonateMoney = num
	editDonateMoney:setText(var.mDonateMoney)
end

function ContainerGang.openPageInfo()
	updateGuildDonate(1)
	local guildName = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
	GameSocket:GetGuildInfo(guildName,0)
	GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "guildAssets"}))

	if getMyGuildTitle() >= TAG_GUILD.GUILD_TITLE_TYPE_VICEADMIN then
		var.xmlPageInfo:getWidgetByName("edit_guild_notice"):show()
	else
		var.xmlPageInfo:getWidgetByName("edit_guild_notice"):hide()
	end
end

function ContainerGang.initPageInfo()
	local pageInfoButtons = {
		"btn_applicant_list", "btn_guild_tips", "btn_donate_money", "btn_dismiss_guild"
	}

	local function pushPageInfoButton(sender)
		local btnName = sender:getName()
		if btnName == "btn_applicant_list" then
			showPanelPage("apply")
		elseif btnName == "btn_guild_tips" then

		elseif btnName == "btn_donate_money" then
			if var.mDonateMoney > 0 then
				GameSocket:PushLuaTable("gui.ContainerGang.onPanelData",GameUtilSenior.encode({actionid = "guildDonate",param = var.mDonateMoney}))
			end
		elseif btnName == "btn_dismiss_guild" then
			-- GameSocket:LeaveGuild(GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name))
			checkAndDismissGuild()
		end
	end

	local function updateGuildNotice()
		-- var.xmlPageInfo:getWidgetByName("lbl_guild_notice")
		local richNotice = var.xmlPageInfo:getWidgetByName("richNotice")
		if not var.isEditingNotice then richNotice:show() end
		richNotice:setRichLabel("<font color=#B2A58B>"..var.mGuildNotice.."</font>", "", 18)
	end

	local function updateGuildAssets()
		if not var.mGuildAssets then return end
		var.mGuildLevel = var.mGuildAssets.guildLevel
		var.xmlPageInfo:getWidgetByName("lbl_guild_level"):setString(var.mGuildAssets.guildLevel)
		var.xmlPageInfo:getWidgetByName("lbl_guild_level_1"):setString(var.mGuildAssets.guildLevel)
		var.xmlPageInfo:getWidgetByName("lbl_guild_treasure"):setString(var.mGuildAssets.guildExp)
		-- var.xmlPageInfo:getWidgetByName("lbl_maintenance_fund"):setString("维护资金："..var.mGuildAssets.opex.."/天")
		var.xmlPageInfo:getWidgetByName("lbl_maintenance_fund"):setString("")
		--var.xmlPageInfo:getWidgetByName("img_guild_exp_bar"):setPercent(var.mGuildAssets.guildExp, var.mGuildAssets.needExp)
		var.xmlPageInfo:getWidgetByName("lbl_guild_member"):setString(var.mGuildAssets.memberNum.."/"..var.mGuildAssets.memberMax)
	end

	local memberMax = 0
	local function updateGuildInfo()
		local guildName = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
		if guildName and guildName~="" then
			local pGuild = GameSocket:getGuildByName(guildName)
			if pGuild then
				var.myGuildName = guildName
				local mEnteringMembers = pGuild.mEnteringMembers
				local mMemberNumber = pGuild.mMemberNumber
				local mDesp = pGuild.mDesp
				var.mGuildNotice = pGuild.mNotice
				local mLeader = pGuild.mLeader
				local mLevelGuild = pGuild.mLevelGuild
				local mGuildExp = pGuild.mGuildExp
				local mRealMembers = pGuild.mRealMembers
				local guild_title = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_title)

				var.xmlPageInfo:getWidgetByName("lbl_guild_name"):setString(guildName)
				var.xmlPageInfo:getWidgetByName("lbl_guild_master"):setString(mLeader)
				var.mGuildLevel = mLevelGuild
				var.xmlPageInfo:getWidgetByName("lbl_guild_level"):setString(mLevelGuild)
				var.xmlPageInfo:getWidgetByName("lbl_guild_level_1"):setString(mLevelGuild)
				var.xmlPageInfo:getWidgetByName("lbl_guild_rank"):setString(getMyGuildChart())
				var.xmlPageInfo:getWidgetByName("lbl_maintenance_fund"):setString("")
				var.xmlPageInfo:getWidgetByName("lbl_guild_treasure"):setString(mGuildExp)

				memberMax = GameBaseLogic.getGuildMemberMax(mLevelGuild)
				--memberMax = 30
				local guildnum = pGuild.mMemberNumber < memberMax and pGuild.mMemberNumber or memberMax
				var.xmlPageInfo:getWidgetByName("lbl_guild_member"):setString(guildnum.."/"..memberMax)

				-- 首次创建帮会默认设置帮会公告和宣言
				if var.isFirstInSelfGuild and var.mGuildNotice =="" and guild_title == TAG_GUILD.GUILD_TITLE_TYPE_ADMIN then
					GameSocket:SetGuildInfo(guildName,"desp",GameConst.str_guildinfo)
					GameSocket:GetGuildInfo(guildName,0)
					var.isFirstInSelfGuild = false
				end
				updateGuildNotice()
			end
		end

		-- 解散帮会功能仅对会长有效
		var.xmlPageInfo:getWidgetByName("btn_dismiss_guild"):setVisible(isGuildAdmin() and true or false)
	end


	local function onPanelData(event)
		if event.type == "ContainerGang" then
			local data = GameUtilSenior.decode(event.data)
			if not data then return end
			if data.cmd =="guildAssets" then
				var.mGuildAssets = data
				updateGuildAssets()
			end
		end
	end

	var.xmlPageInfo = GUIAnalysis.load("ui/layout/ContainerGang_info.uif")
	if var.xmlPageInfo then
		GameUtilSenior.asyncload(var.xmlPageInfo, "page_guild_info_bg", "ui/image/page_guild_info_bg.jpg")
		var.xmlPageInfo:align(display.LEFT_BOTTOM, 40, 20):addTo(var.xmlPanel)

		-- 设置帮会经验条属性
		--[[
		local barGuildExp = var.xmlPageInfo:getWidgetByName("img_guild_exp_bar")
		local lblGuildExp = barGuildExp:getLabel()
		lblGuildExp:setFontSize(16)
		local lblRender = lblGuildExp:getVirtualRenderer()
		lblRender:setColor(GameBaseLogic.getColor(0xF7F0E2))
		lblRender:enableOutline(GameBaseLogic.getColor(0x000000),1)
		]]--
		local params = {
			root = var.xmlPageInfo,
			lblName = "lbl_donate_money",
			pName = "img_editbox_donate",
			updateFunc = updateGuildDonate
		}
		local editBoxDonate = createNumInputEditBox(params):setName("edit_donate_money")

		local lblGuildNotice = var.xmlPageInfo:getWidgetByName("lbl_guild_notice"):setString(""):setTouchEnabled(true)
		local pSize = lblGuildNotice:getContentSize()
		local richNotice = lblGuildNotice:getChildByName("richNotice")
		if not richNotice then
			richNotice = GUIRichLabel.new({size = cc.size(pSize.width - 30, 30),fontSize = 16, space=5,name = "taskDesp"})
			richNotice:setName("richNotice")
			richNotice:setColor(GameBaseLogic.getColor(0xfddfae))
			lblGuildNotice:addChild(richNotice)
		end
		richNotice:setRichLabel(var.mGuildNotice, "", 18)
		richNotice:align(display.LEFT_TOP, 0, pSize.height)

		local function onEdit(event,editBox)
			if event == "began" then
				var.isEditingNotice = true
			elseif event == "return" then
				if var.myGuildName then
					lblGuildNotice:show()
					-- lblGuildNotice:setString(editBox:getText())
					GameSocket:SetGuildInfo(var.myGuildName, "desp", editBox:getText())
					editBox:setText("")
					GameSocket:GetGuildInfo(var.myGuildName,0)
				end
				var.isEditingNotice = false
			end
		end

		local imgEditboxNotice = var.xmlPageInfo:getWidgetByName("img_notice_input_bg")
		imgEditboxNotice:setContentSize(cc.size(imgEditboxNotice:getContentSize().width,28))
		local param = {
			parent = imgEditboxNotice,
			color = 0xB2A58B,
			fontSize = 18,
			inputMode = cc.EDITBOX_INPUT_MODE_ANY,
			listener = onEdit, -- 监听函数
			bindLabel = lblGuildNotice,
		}

		local mEditBox = GameUtilSenior.addEditBoxTo(param):setName("edit_guild_notice"):setTouchEnabled(false)
		GUIFocusPoint.addUIPoint(lblGuildNotice, function ()
			richNotice:hide()
			mEditBox:setText(var.mGuildNotice)
			richNotice:setRichLabel("", "", 18)
			mEditBox:touchDownAction(mEditBox, ccui.TouchEventType.ended)
		end)

		var.xmlPageInfo:getWidgetByName("lbl_guild_exp"):hide()

		local btnPageInfo
		for _,v in ipairs(pageInfoButtons) do
			btnPageInfo = var.xmlPageInfo:getWidgetByName(v)
			GUIFocusPoint.addUIPoint(btnPageInfo, pushPageInfoButton)
		end

		local btnGuildTips = var.xmlPageInfo:getWidgetByName("btn_guild_tips"):setTouchEnabled(true):addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true, infoTable = guildHint["info"],})
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled  then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false })
			end
		end)

		cc.EventProxy.new(GameSocket, var.xmlPageInfo)
			:addEventListener(GameMessageCode.EVENT_GUILD_INFO, updateGuildInfo)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, onPanelData)
	end
end
--------------------------------------帮会成员--------------------------------------
function ContainerGang.openPageMember()
	GameSocket:ListGuildMember(GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name),TAG_GUILD.LIST_TYPE_REAL_MEMBER)
	GameSocket:PushLuaTable("gui.ContainerGang.onPanelData",GameUtilSenior.encode({actionid = "checkRedPacket"}))
end

function ContainerGang.initPageMember()

	local memberInfo
	local function pushMemberItem(sender)
		memberInfo = var.mGuildMembers[sender.tag]
		if memberInfo.name ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_name) then
			local param = {
				name = GameMessageCode.EVENT_SHOW_TIPS, str = "guildMember",data = sender.data, memberName = memberInfo.name, online = memberInfo.online
			}
			GameSocket:dispatchEvent(param)
		end
	end


	local labelColor
	local function updateMemberItem(item)
		if item.tag and var.mGuildMembers[item.tag] then
			memberInfo = var.mGuildMembers[item.tag]
			-- print("//////////////", GameUtilSenior.encode(memberInfo))
			if memberInfo.online == 1 then
				labelColor = GameBaseLogic.getColor4(0xC0AC8C)
			else
				labelColor = GameBaseLogic.getColor4(0x707070)
			end

			item:getWidgetByName("lbl_player_name"):setTextColor(labelColor):setString(memberInfo.name)
			item:getWidgetByName("lbl_player_job"):setTextColor(labelColor):setString(GameConst.job_name[memberInfo.job])
			item:getWidgetByName("lbl_player_post"):setTextColor(labelColor):setString(GUILD_TITLE[memberInfo.title])

			item:getWidgetByName("lbl_player_level"):setTextColor(labelColor):setString(memberInfo.level)
			item:getWidgetByName("lbl_player_contribution"):setTextColor(labelColor):setString(memberInfo.guildpt)
			item:getWidgetByName("lbl_player_fight"):setTextColor(labelColor):setString(memberInfo.fight)
			item:setTouchEnabled(true)
			item.data = memberInfo
			GUIFocusPoint.addUIPoint(item, pushMemberItem)
		end

	end

	local function updateMemberList(event)
		if event.memberType ~= MEMBER_TYPE.REALMEMBER then return end
		var.mGuildMembers,online,total = getSortedMemebrs(MEMBER_TYPE.REALMEMBER)
		-- print("//////////////////updateMemberList//////////////////", event.memberType, GameUtilSenior.encode(var.mGuildMembers))
		if var.mGuildMembers then
			local listMember = var.xmlPageMember:getWidgetByName("list_member")
			listMember:reloadData(#var.mGuildMembers, updateMemberItem, nil, false)
			local txtMemberNum = var.xmlPageMember:getWidgetByName("txtMemberNum")
			if txtMemberNum then
				txtMemberNum:setString(online.."/"..total)
			end
		end
	end

	local function onPanelData(event)
		if event.type == "ContainerGang" then
			local data = GameUtilSenior.decode(event.data)
			if data.cmd == "redPacket" then
				--帮会红包红点检测
				local btnGuildHongbao = var.xmlPanel:getWidgetByName("btn_guild_hongbao")
				if not btnGuildHongbao then return end
				if data.showRedPoint then
					GameUtilSenior.addHaloToButton(btnGuildHongbao, "btn_normal_light3")
				else
					btnGuildHongbao:removeChildByName("img_bln")
				end
			end
		end
	end

	var.xmlPageMember = GUIAnalysis.load("ui/layout/ContainerGang_member.uif")
	if var.xmlPageMember then
		GameUtilSenior.asyncload(var.xmlPageMember, "page_guild_member_bg", "ui/image/page_general_bg.jpg")
		var.xmlPageMember:align(display.LEFT_BOTTOM, 40, 20):addTo(var.xmlPanel)

		-- var.xmlPageMember:getWidgetByName("list_member"):setSliderVisible(false)

		local btnGuildHongbao = var.xmlPageMember:getWidgetByName("btn_guild_hongbao")--:hide()
		GUIFocusPoint.addUIPoint(btnGuildHongbao, function ()
			showPanelPage("hongbao")
		end)
		local checkBox = var.xmlPageMember:getChildByName("showOnline")
		if checkBox then
			var.showOnlineMember = checkBox:isSelected()
			checkBox:addClickEventListener(function ( sender )
				var.showOnlineMember = checkBox:isSelected()
				GameSocket:ListGuildMember(GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name), TAG_GUILD.LIST_TYPE_REAL_MEMBER)
			end)
		end
		cc.EventProxy.new(GameSocket, var.xmlPageMember)
			:addEventListener(GameMessageCode.EVENT_GUILD_MEMBER, updateMemberList)
			:addEventListener(GameMessageCode.EVENT_GUILD_MEMBER_CHANGE, function (event)
				GameSocket:ListGuildMember(GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name), TAG_GUILD.LIST_TYPE_REAL_MEMBER)
			end)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, onPanelData)
	end
end
--------------------------------------帮会仓库--------------------------------------
local pageDepotButtons = {
	"btn_guild_log", "btn_only_career", "btn_only_convertible"
}

function ContainerGang.updateGuildBag()
	local function donateItemToGuild(pos)
		-- print("donateItemToGuild",pos)
		local netItem = GameSocket:getNetItem(pos)
		if netItem and netItem.mTypeID > 0 then
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "donateItem", pos = pos, typeID = netItem.mTypeID}))
		end
	end

	local canDonateItem = {}
	local netItem, itemDef
	for pos = 0, GameConst.ITEM_BAG_SIZE + GameSocket.mBagSlotAdd - 1 do
		netItem = GameSocket:getNetItem(pos)
		if netItem then
			itemDef = GameSocket:getItemDefByID(netItem.mTypeID)
			if itemDef and GameBaseLogic.isEquipMent(itemDef.SubType) and itemDef.mEquipContribute > 0 and itemDef.mNeedParam >= 70 then
				if not (bit.band(netItem.mItemFlags, GameConst.ITEM_FLAG_BIND) > 0) then
					table.insert(canDonateItem, pos)
				end
			end
		end

	end

	local function updateBagItem(item)
		local itemPos = canDonateItem[item.tag]
		local param = {
			-- iconType = GameConst.ICONTYPE.DEPOT,
			tipsType = GameConst.TIPS_TYPE.GUILD,
			parent = item,
			pos = itemPos,
			doubleCall = function()
				-- print("callBack", itemPos)
				donateItemToGuild(itemPos)
			end,
			compare = true,
			customCallFunc = function()
				donateItemToGuild(itemPos)
			end,
			enmuItemType = 0,
		}
		GUIItem.getItem(param)
	end

	local function updateGuildBag()
		local listBag = var.xmlPageDepot:getWidgetByName("list_bag")
		listBag:reloadData(GameConst.ITEM_BAG_MAX, updateBagItem,nil,false)
	end
	updateGuildBag()
end

local function updateDepotCheckBox()
	var.xmlPageDepot:getWidgetByName("btn_only_career"):setBrightStyle(var.mDepotJob and ccui.BrightStyle.highlight or ccui.BrightStyle.normal)
	var.xmlPageDepot:getWidgetByName("btn_only_convertible"):setBrightStyle(var.mDepotConvertible and ccui.BrightStyle.highlight or ccui.BrightStyle.normal)
	GameSocket:GuildReperotry()
end

function ContainerGang.openPageDepot()
	local guildName = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
	-- local myName = GameCharacter._mainAvatar:NetAttr(GameConst.net_name)
	-- if guildName and guildName~="" then
	-- 	local guildMember = GameSocket:getGuildByName(guildName).mRealMembers
	-- 	if guildMember then
	-- 		for k,v in pairs(guildMember) do
	-- 			if v.nick_name == myName then
	-- 				var.myGuildPoint = v.guildpt
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- end

	var.mDepotJob = false
	var.mDepotConvertible = false
	updateDepotCheckBox()

	ContainerGang.updateGuildBag()
	-- GameSocket:GuildReperotry()
	GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "myGuildDonate"}))
end
function ContainerGang.initPageDepot()

	local myJob = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
	local function convertGuildItem(tag)

		local depotItem = var.depotItems[tag]
		if depotItem then
			-- print("convertGuildItem",tag,depotItem.pos, depotItem.typeID)
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "convertItem", pos = depotItem.pos, typeID = depotItem.typeID}))
		end
	end

	local function destoryGuildItem(tag)
		local depotItem = var.depotItems[tag]
		if depotItem then
			-- print("convertGuildItem",tag,depotItem.pos, depotItem.typeID)
			local itemName = "物品"
			local itemDef = GameSocket:getItemDefByID(depotItem.typeID)
			if itemDef then itemName = itemDef.mName end
			local mParam = {
				name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", lblConfirm = "确定摧毁"..itemName.."吗？",
				btnConfirm = "取消", btnCancel = "确定",
				cancelCallBack = function ()
					GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "destoryItem", pos = depotItem.pos, typeID = depotItem.typeID}))
				end
			}
			GameSocket:dispatchEvent(mParam)
		end
	end

	local depotItem
	local function updateDepotItem(item)
		depotItem = var.depotItems[item.tag]
		local param = {
			parent = item,
			doubleCall = function ()
				convertGuildItem(item.tag)
			end,
			compare = true,
			tipsType = GameConst.TIPS_TYPE.GUILD,
			enmuPos = 5,
			customCallFunc = function()
				convertGuildItem(item.tag)
			end,
			destoryCallFunc = function ()
				destoryGuildItem(item.tag)
				-- print("destoryGuildItem", item.tag)
			end,
			showBetter = true,
			enmuItemType = 0,
		}
		if getMyGuildTitle() >= TAG_GUILD.GUILD_TITLE_TYPE_VICEADMIN then
			param.enmuItemType = 4
		end
		if depotItem then
			param.typeId = depotItem.typeID
			param.mLevel = depotItem.level
			param.mZLevel= depotItem.zlevel
		end

		GUIItem.getItem(param)
	end

	local function updateGuildDepot(event)
		local items = event.data
		var.depotItems = {}
		local showFlag
		for i,v in ipairs(items) do
			showFlag = true
			-- print("updateGuildDepot", v.price, var.myGuildPoint)
			if var.mDepotConvertible and v.price > var.myGuildPoint then
				showFlag = false
			end

			if showFlag and var.mDepotJob then
				-- print("updateGuildDepot", v.job, myJob)
				if v.job ~= 0 and v.job ~= myJob then
					showFlag = false
				end
			end
			if showFlag then
				table.insert(var.depotItems, v)
			end
		end

		local defA, defB, lvA, lvB, equipTypeA, equipTypeB, jobA, jobB, genderA, genderB

		local function sortFunc(itemA, itemB)
			defA = GameSocket:getItemDefByID(itemA.typeID)
			defB = GameSocket:getItemDefByID(itemB.typeID)
			if not defA then
				lvA = 0
				jobA = 200
				equipTypeA = 10
				genderA = 300
			else
				lvA = defA.mNeedZsLevel * 1000 + defA.mNeedParam
				jobA = defA.mJob
				if jobA == 0 then jobA = 200 end
				equipTypeA = defA.mEquipType
				genderA = defA.mGender
				if genderA == 0 then genderA = 300 end
			end

			if not defB then
				lvB = 0
				jobB = 200
				equipTypeB = 0
				genderB = 300
			else
				lvB = defB.mNeedZsLevel * 1000 + defB.mNeedParam
				jobB = defB.mJob
				if jobB == 0 then jobB = 200 end
				equipTypeB = defB.mEquipType
				genderB = defB.mGender
				if genderB == 0 then genderB = 300 end
			end

			if lvA == lvB then
				if jobA == jobB then
					if equipTypeA == equipTypeB then
						return genderB < genderB
					else
						return equipTypeA < equipTypeB
					end
				else
					return jobA < jobB
				end
			else
				return lvA > lvB
			end
		end
		table.sort(var.depotItems, sortFunc)

		local listDepot = var.xmlPageDepot:getWidgetByName("list_depot")
		listDepot:reloadData(GameConst.GUILD_DEPOT_LENGTH, updateDepotItem)
	end

	local function pushPageDepotButton(sender)
		local btnName = sender:getName()
		if btnName == "btn_guild_log" then
			showPanelPage("log")
		elseif btnName == "btn_only_career" then
			var.mDepotJob = not var.mDepotJob
			updateDepotCheckBox()
		elseif btnName == "btn_only_convertible" then
			var.mDepotConvertible = not var.mDepotConvertible
			updateDepotCheckBox()
		end
	end

	local function onPanelData(event)
		if event.type == "ContainerGang" then
			local data = GameUtilSenior.decode(event.data)
			if not data then return end
			if data.cmd == "contribute" then
				var.xmlPageDepot:getWidgetByName("lbl_my_donate"):setString("我的贡献值："..data.contribute)
				var.myGuildPoint = data.contribute
			elseif data.cmd == "converSucceed" then
				ContainerGang.updateGuildBag()
			-- elseif data.cmd == "destorySucceed" then
			-- 	ContainerGang.updateGuildBag()
			end
		end
	end

	local function onItemChange(event)
		if var.mCurPageKey == "depot" and event and GameBaseLogic.IsPosInBag(event.pos) then
			ContainerGang.updateGuildBag()
		end
	end

	var.xmlPageDepot = GUIAnalysis.load("ui/layout/ContainerGang_depot.uif")
	if var.xmlPageDepot then
		GameUtilSenior.asyncload(var.xmlPageDepot, "page_guild_depot_bg", "ui/image/page_guild_depot_bg.jpg")
		var.xmlPageDepot:align(display.LEFT_BOTTOM, 40, 20):addTo(var.xmlPanel)

		local btnPageDepot
		for i,v in ipairs(pageDepotButtons) do
			btnPageDepot = var.xmlPageDepot:getWidgetByName(v):setTouchEnabled(true)
			if btnPageDepot then
				GUIFocusPoint.addUIPoint(btnPageDepot, pushPageDepotButton)
			end
		end

		cc.EventProxy.new(GameSocket, var.xmlPageDepot)
			:addEventListener(GameMessageCode.EVENT_GUILD_REPERTORY, updateGuildDepot)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, onPanelData)
			:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, onItemChange)
	end
end
--------------------------------------帮会祈祷--------------------------------------
local function initPrayCost()
	if var.xmlPagePray then
		var.xmlPagePray:getWidgetByName("lbl_pray_cost"):setString("")
	end
end

local function updateSelectedPray()
	local boxGuildPray, imgPrayFlagLight
	for i=1,12 do
		boxGuildPray = var.xmlPagePray:getWidgetByName("box_guild_pray"..i)
		if boxGuildPray then
			imgPrayFlagLight = boxGuildPray:getChildByName("img_pray_flag_light")
			imgPrayFlagLight:setVisible(i == var.mGuildPrayIndex)
		end
	end
end

function ContainerGang.openPagePray()
	GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "guildPrays"}))
	GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "myGuildDonate"}))
	initPrayCost()
	--var.mGuildPrayIndex = 0
	updateSelectedPray()
	GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "prayNeedDonate", index = 1}))
end


function ContainerGang.initPagePray()
	local prayFlagRes = {
		[1] = "img_attack_flag",
		[2] = "img_attack_max_flag",
		[3] = "img_ac_flag",
		[4] = "img_ac_max_flag",
		[5] = "img_mac_flag",
		[6] = "img_mac_max_flag",
		[7] = "img_hp_flag",
		[8] = "img_mp_flag",
		[9] = "img_holy_damage_flag",
		[10]= "img_tenacity_flag",
		[11]= "img_baoji_pres_flag",
		[12]= "img_baoji_prob_flag",
	}

	local pagePrayButtons = {
		"btn_left", "btn_right", "btn_begin_pray"
	}

	local function onUnlockPray(index)
		local boxGuildPray = var.xmlPagePray:getWidgetByName("box_guild_pray"..index)
		if not boxGuildPray then return end
		local imgPrayFlagLock = boxGuildPray:getChildByName("img_pray_flag_lock")

		-- if unlockSprite then unlockSprite:removeFromParent() end
		local unlockSprite = cc.Sprite:create()
			:align(display.CENTER, imgPrayFlagLock:getPositionX(), imgPrayFlagLock:getPositionY())
			:addTo(boxGuildPray)

		local animate = cc.AnimManager:getInstance():getPlistAnimate(4,65402,4,4,false,false,0,function(animate,shouldDownload)
							if animate then
								unlockSprite:runAction(cca.seq({
									cca.rep(animate,1),
									cca.removeSelf()
								}))
							end
							if shouldDownload==true then
								unlockSprite:release()
							end
						end,
						function(animate)
							unlockSprite:retain()
						end)

		
	end

	local prayAttrs = {}
	local lblPrayUnlock
	local function updateGuildPray(infos)
		-- print("updateGuildPray", GameUtilSenior.encode(infos))
		prayAttrs = {}

		local boxGuildPray
		for i,v in ipairs(infos) do
			boxGuildPray = var.xmlPagePray:getWidgetByName("box_guild_pray"..i)
			if v.attrValue and v.attrValue > 0 then
				boxGuildPray:getChildByName("lbl_pray_attr"):setString(v.attrName.."+"..v.attrValue)
			else
				boxGuildPray:getChildByName("lbl_pray_attr"):setString(v.attrName.."")
			end
			boxGuildPray:getChildByName("lbl_pray_unlock"):setString(v.lockedDesp)
			if boxGuildPray.locked and v.lockedDesp == "" then
				onUnlockPray(i)
			end
			boxGuildPray.locked = v.lockedDesp ~= ""
			boxGuildPray:getChildByName("img_pray_flag_lock"):setVisible(boxGuildPray.locked)
			local prayInfo = infos[i]
			if prayInfo then
				-- print("buildPrayAttrs",index, prayInfo.level, prayInfo.maxLevel);
				boxGuildPray:getChildByName("item_lv_num"):enableOutline(GameBaseLogic.getColor(0x000000), 1):setString(prayInfo.level)
			end
			table.insert(prayAttrs, {level = v.level, name = v.attrName, value = v.attrValue, attrNext = v.attrNext, maxLevel = v.maxLevel})
		end
		local totalLevel = 0;
		for i,v in ipairs(prayAttrs) do
			totalLevel = totalLevel + v.level
		end
		var.xmlPagePray:getWidgetByName("tree_lv_num"):setString(totalLevel)

		
	end

	local function buildPrayAttrs(index)
		local str = ""
		if not index then
			local totalLevel = 0;
			for i,v in ipairs(prayAttrs) do
				totalLevel = totalLevel + v.level
				str = str..v.name.."：<font color=#01c814>"..v.value.."</font><br>"
			end
			str = "<font color=#d0a124>神树等级：</font><font color=#01c814>"..totalLevel.."</font><br> <br><font color=#d0a124>属性加成：</font><br>"..str
		else
			local prayInfo = prayAttrs[index]
			if prayInfo then
				-- print("buildPrayAttrs",index, prayInfo.level, prayInfo.maxLevel);
				if prayInfo.level == prayInfo.maxLevel then
					str = "当前等级：<br>已满级"
				else
					str = "当前等级：<font color=#01c814>"..prayInfo.level.."</font><br>"..prayInfo.name.."：<font color=#01c814>+"..prayInfo.value.."</font><br>"

					if prayInfo.attrNext then
						str = str.."下一级别：<font color=#01c814>"..(prayInfo.level + 1).."</font><br>"..prayInfo.name.."：<font color=#01c814>+"..prayInfo.attrNext.."</font>"
					end
				end
			end
		end
		str =  "<font color=#fffaec>"..str.."</font>"
		return str
	end

	local function handlePrayAttrs(visible, index)
		local imgPrayAttrBg  = var.xmlPagePray:getWidgetByName("img_pray_attr_bg")
		imgPrayAttrBg:setVisible(visible)
		local strAttr = buildPrayAttrs(index)

		local richAttr = imgPrayAttrBg:getChildByName("rich_attr")
		if not richAttr then
			richAttr = GUIRichLabel.new({size = cc.size(180, 30), space=3,name = "prayAttrs",outline = {0, 0, 0,255, 1},})
				:setName("rich_attr")
				:addTo(imgPrayAttrBg)
		end

		local msgSize = richAttr:setRichLabel(strAttr, "prayAttrs", 16)

		imgPrayAttrBg:setContentSize(cc.size(msgSize.width + 20, msgSize.height + 20))
		richAttr:align(display.CENTER, msgSize.width * 0.5 + 10, msgSize.height * 0.5 + 10)

	end

	local function pushGuildPrayItem(sender)
		var.mGuildPrayIndex = sender.tag
		updateSelectedPray()
		GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "prayNeedDonate", index = var.mGuildPrayIndex}))
	end

	local function touchGuildPrayItem(sender, touchType)
		-- print()
		if touchType == ccui.TouchEventType.began then
			-- 显示属性tips
			handlePrayAttrs(true, sender.tag)
		elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled  then
			-- 隐藏属性tips
			handlePrayAttrs(false)
		end
	end

	local function onPanelData(event)
		if event.type == "ContainerGang" then
			local data = GameUtilSenior.decode(event.data)
			if not data then return end
			if data.cmd == "guildPrays" then
				updateGuildPray(data.infos)
			elseif data.cmd == "contribute" then
				var.xmlPagePray:getWidgetByName("lbl_my_donate"):setString(""..data.contribute)
			elseif data.cmd == "prayNeedDonate" then
				var.xmlPagePray:getWidgetByName("lbl_pray_cost"):setString(data.needDonate.."贡献值")
			end
		end
	end

	local function pageViewEvent(sender, eventType)
		local index = sender:getCurPageIndex()
		if eventType == ccui.PageViewEventType.turning then
			if index == 0 then
				var.xmlPagePray:getWidgetByName("lbl_guild_pray"):loadTexture("img_chujiqidao",ccui.TextureResType.plistType) --:setString("初级祈祷")
				var.xmlPagePray:getWidgetByName("btn_right"):show()
				var.xmlPagePray:getWidgetByName("btn_left"):hide()
			else
				var.xmlPagePray:getWidgetByName("lbl_guild_pray"):loadTexture("img_gaojiqidao",ccui.TextureResType.plistType)--:setString("高级祈祷")
				var.xmlPagePray:getWidgetByName("btn_right"):hide()
				var.xmlPagePray:getWidgetByName("btn_left"):show()
			end
		end
	end

	local function initPrayPageView()
		local prayPageView = var.xmlPagePray:getWidgetByName("page_pray")
		local modelGuildPray = var.xmlPagePray:getWidgetByName("model_guild_pray"):hide()

		local layout
		local pSize = prayPageView:getContentSize()
		local intervalX = 138
		local intervalY = 175
		local startX = (pSize.width - intervalX * 3) * 0.5
		local startY = pSize.height * 0.5 + intervalY * 0.5+20

		for i = 1 , 2 do
			layout = ccui.Layout:create()
			layout:setContentSize(pSize)
			prayPageView:addPage(layout)
		end

		local index, curPage, boxGuildPray, posX, posY
		local pageIndex = 0
		for i,v in ipairs(prayFlagRes) do
			index = i
			if i > 8 then index = index - 8 end
			if i == 9 then
				curPage = nil
				pageIndex = 1
				startY = pSize.height * 0.5
			end

			posX = startX + (index - 1) % 4 * intervalX
			posY = startY - math.floor((index - 1) / 4) * intervalY

			if not curPage then curPage = prayPageView:getPage(pageIndex) end
			if curPage then
				boxGuildPray = modelGuildPray:clone()
					:align(display.CENTER, posX, posY)
					:setName("box_guild_pray"..i)
					:setTouchEnabled(true)
					:addTo(curPage)
					:show()

				boxGuildPray.tag = i
				boxGuildPray:addClickEventListener(pushGuildPrayItem)

				boxGuildPray:addTouchEventListener(touchGuildPrayItem)

				boxGuildPray:getChildByName("img_pray_flag"):loadTexture(v, ccui.TextureResType.plistType)
			end
		end

		prayPageView:addEventListener(pageViewEvent)
	end

	local function pushPagePrayButton(pSender)
		local btnName = pSender:getName()
		if btnName == "btn_begin_pray" then
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "guildPray", index = var.mGuildPrayIndex}))
		elseif btnName == "btn_left" then
			var.xmlPagePray:getWidgetByName("page_pray"):scrollToPage(0)
		elseif btnName == "btn_right" then
			var.xmlPagePray:getWidgetByName("page_pray"):scrollToPage(1)
		end
	end


	var.xmlPagePray = GUIAnalysis.load("ui/layout/ContainerGang_pray.uif")
	if var.xmlPagePray then
		GameUtilSenior.asyncload(var.xmlPagePray, "page_guild_pray_bg", "ui/image/container_guild_pray_bg.jpg")
		var.xmlPagePray:align(display.LEFT_BOTTOM, 40, 20):addTo(var.xmlPanel)

		-- local imgPrayItem, imgPrayFlag
		-- for i,v in ipairs(prayFlagRes) do
		-- 	imgPrayItem = var.xmlPagePray:getWidgetByName("img_pray_item_"..i):setTouchEnabled(true)
		-- 	imgPrayFlag = var.xmlPagePray:getWidgetByName("img_pray_flag_"..i)
		-- 	imgPrayFlag:loadTexture(v, ccui.TextureResType.plistType)
		-- 	imgPrayItem.tag = i
		-- 	GUIFocusPoint.addUIPoint(imgPrayItem, pushGuildPrayItem)
		-- 	lblPrayAttr = imgPrayItem:getWidgetByName("lbl_pray_attr_"..i)
		-- 	lblPrayAttr:setString("")
		-- 	lblPrayUnlock = imgPrayItem:getWidgetByName("lbl_pray_unlock_"..i)
		-- 	if lblPrayUnlock then
		-- 		lblPrayUnlock:setString("")
		-- 	end
		-- end
		initPrayPageView()
		local imgGuildTree = var.xmlPagePray:getWidgetByName("img_guild_tree"):setTouchEnabled(true)
		--var.xmlPagePray:getWidgetByName("img_guild_tree_light"):hide()

		var.xmlPagePray:getWidgetByName("lbl_guild_pray_tips"):setString("说明："..guildHint["pray"][2]):hide()
		local Button_see = var.xmlPagePray:getWidgetByName("Button_see")
		Button_see:addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				-- 显示属性tips
				handlePrayAttrs(true)
				--var.xmlPagePray:getWidgetByName("img_guild_tree_light"):show()
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled  then
				-- 隐藏属性tips
				handlePrayAttrs(false)
				--var.xmlPagePray:getWidgetByName("img_guild_tree_light"):hide()
			end
		end)
		--imgGuildTree:addTouchEventListener(function (pSender, touchType)
		--	if touchType == ccui.TouchEventType.began then
		--		-- 显示属性tips
		--		handlePrayAttrs(true)
		--		--var.xmlPagePray:getWidgetByName("img_guild_tree_light"):show()
		--	elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled  then
		--		-- 隐藏属性tips
		--		handlePrayAttrs(false)
		--		--var.xmlPagePray:getWidgetByName("img_guild_tree_light"):hide()
		--	end
		--end)
		

		local btnPrayTips = var.xmlPagePray:getWidgetByName("btn_pray_tips"):setTouchEnabled(true):addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true, infoTable = guildHint["pray"]})
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled  then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false })
			end
		end)

		var.xmlPagePray:getWidgetByName("img_pray_attr_bg"):hide()--:loadTexture("img_tips_common_minibg", ccui.TextureResType.plistType)

		local btnPagePray
		for _,v in ipairs(pagePrayButtons) do
			btnPagePray = var.xmlPagePray:getWidgetByName(v)
			GUIFocusPoint.addUIPoint(btnPagePray, pushPagePrayButton)
		end

		var.xmlPagePray:getWidgetByName("btn_left"):setRotation(-180)
		-- local btnGuildPray = var.xmlPagePray:getWidgetByName("btn_guild_pray")
		-- GUIFocusPoint.addUIPoint(btnGuildPray, function (sender)
		-- 	GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "guildPray", index = var.mGuildPrayIndex}))
		-- end)


		cc.EventProxy.new(GameSocket, var.xmlPagePray)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, onPanelData)
	end
end

--------------------------------------帮会列表--------------------------------------
local pageListButtons = {
	"btn_create_guild", "btn_quit_guild", "btn_onekey_declare"
}

local OPERATE_STATE = {
	NULL = 1,
	ENTERING = 2,
	DECLAREWAR = 3,
}

function ContainerGang.openPageList()
	GameSocket:ListGuild(0)
	local btnQuitGuild = var.xmlPageList:getWidgetByName("btn_quit_guild")
	if hasGuild() then
		btnQuitGuild:show()
		var.xmlPageList:getWidgetByName("btn_create_guild"):hide()
		var.xmlPageList:getWidgetByName("btn_onekey_declare"):show()
		if isGuildAdmin() then
			btnQuitGuild:setTitleText("解散帮会")
		else
			btnQuitGuild:setTitleText("退出帮会")
		end
	else
		btnQuitGuild:hide()
		var.xmlPageList:getWidgetByName("btn_create_guild"):show()
		var.xmlPageList:getWidgetByName("btn_onekey_declare"):hide()
	end
end
function ContainerGang.initPageList()
	local guildInfo, myGuildTitle
	local function pushGuildItemButton(sender)
		guildInfo = var.mSortedGuilds[sender.tag]
		if not hasGuild() then
			if guildInfo.entering==1 then
				GameSocket:LeaveGuild(guildInfo.mName)
			else
				GameSocket:JoinGuild(guildInfo.mName, 0)
			end
		else
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "guildWar", guildId = guildInfo.mGuildSeedId}))
		end
	end

	local function updateGuildWarTime(sender)
		sender:show()
		local timeLeft = 0
		if sender.mWarStartTime > 0 then
			timeLeft = GUILD_WAR_TIME - (os.time() - sender.mWarStartTime)
		end
		if timeLeft < 0 then timeLeft = 0 end
		if timeLeft > 0 then
			timeLeft = GameUtilSenior.setTimeFormat(timeLeft * 1000 , 2)
			sender:setString("宣战("..timeLeft..")")
			sender:setColor(GameBaseLogic.getColor(0xff3e3e))
			sender.btnWar:hide()
		else
			sender:setColor(GameBaseLogic.getColor(0x30ff00))
			sender:setString("正常")
			sender:stopAllActions()
			if myGuildTitle >= TAG_GUILD.GUILD_TITLE_TYPE_VICEADMIN then
				if not sender.btnWar.myGuilde then
					sender.btnWar:show()
				end
				-- sender:hide()
			else
				sender.btnWar:hide()
			end
		end
	end

	-- local guildName = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
	local imgGuildRank, lblGuildWar, memberNum, memberMax

	local function updateGuildItem(item)
		guildInfo = var.mSortedGuilds[item.tag]
		if guildInfo then
			item:getWidgetByName("lbl_guild_name"):setString(guildInfo.mName)
			item:getWidgetByName("lbl_guild_level"):setString(guildInfo.mLevelGuild)
			item:getWidgetByName("lbl_guild_master"):setString(guildInfo.mLeader)

			-- local guildnum = guildInfo.mMemberNumber < guildInfo.mLevelGuild * 50 and guildInfo.mMemberNumber or guildInfo.mLevelGuild * 50
			memberMax = GameBaseLogic.getGuildMemberMax(guildInfo.mLevelGuild)
			--memberMax = 30
			memberNum = guildInfo.mMemberNumber < memberMax and guildInfo.mMemberNumber or memberMax

			item:getWidgetByName("lbl_guild_member"):setString(memberNum.."/"..memberMax)
			local btnGuildOperate = item:getWidgetByName("btn_guild_war"):hide()
			GUIFocusPoint.addUIPoint(btnGuildOperate, pushGuildItemButton)
			btnGuildOperate:setBright(GameCharacter._mainAvatar:NetAttr(GameConst.net_level)>= 40)
			btnGuildOperate.tag = item.tag
			lblGuildWar = item:getWidgetByName("lbl_guild_war"):hide()
			if not hasGuild() then
				btnGuildOperate:show()
				if guildInfo.entering==1 then
					btnGuildOperate:setTitleText("取消")
				else
					btnGuildOperate:setTitleText("申请")
				end
			else
				lblGuildWar:show()
				lblGuildWar.btnWar = btnGuildOperate
				lblGuildWar.mWarStartTime = guildInfo.mWarStartTime
				lblGuildWar.mWarStatus = guildInfo.mWarStatus
				-- print("updateGuildItem", item.tag, guildInfo.mWarStartTime, guildInfo.mWarStatus)
				updateGuildWarTime(lblGuildWar)
				lblGuildWar:stopAllActions()
				lblGuildWar:runAction(cca.repeatForever(cca.seq({
					-- cca.delay(1),
					cca.callFunc(updateGuildWarTime)
				})))
				btnGuildOperate:setTitleText("宣战")
			end

			btnGuildOperate.myGuilde = false
			if guildInfo.mName == getMyGuildName() and getMyGuildTitle() > TAG_GUILD.GUILD_TITLE_TYPE_OUT then
				btnGuildOperate.myGuilde = true
				btnGuildOperate:hide()
			end

			imgGuildRank = item:getChildByName("img_guild_rank")
			if guildInfo.chartIndex <4 then
				imgGuildRank:loadTexture("img_rank_flag"..guildInfo.chartIndex, ccui.TextureResType.plistType)
				imgGuildRank:show()
			else
				imgGuildRank:hide()
			end
			item:getWidgetByName("lbl_guild_rank"):setString(guildInfo.chartIndex)
			item:setSwallowTouches(false)
		end
	end

	local function updateGuildList()
		var.mSortedGuilds = getSortedGuilds()
		myGuildTitle = getMyGuildTitle()
		local listGuild = var.xmlPageList:getWidgetByName("list_guild")
		listGuild:reloadData(#var.mSortedGuilds, updateGuildItem, nil, false)
	end

	local function checkAndCreateGuild(str)
		local firstillegal = string.find(str,"[@%~%^%<%>]")
		if firstillegal then
			GameUtilSenior.showAlert("","名称中包含非法字符","确定")
			return
		end

		local vaild = false
		if str and str~="" and #str>0 then
			local clen,elen = GameUtilSenior.getStrLen(str)
			if (clen*2+elen)<11 then
				vaild = true
			end
		end
		if vaild then
			GameSocket:CreateGuild(str, 0)
			var.isFirstInSelfGuild = true
		else
			GameSocket:alertLocalMsg("帮会名称长度不符合要求！", "alert")
		end
	end

	local function pushPageListButton(sender)
		local btnName = sender:getName()
		if btnName == "btn_create_guild" then
			local param = {
				name = GameMessageCode.EVENT_SHOW_TIPS,
				str = "createGuild",
				noAutoClose = true,
				confirmCallBack = function (inputText)
					if GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_title)==TAG_GUILD.GUILD_TITLE_NONE then
						local mModels = GameSocket.mModels[GameCharacter._mainAvatar:NetAttr(GameConst.net_id)]
						local vip = GameSocket:getPlayerModel(srcid,5)
						-- if mModels and mModels[5] then vip =mModels[5] end
						if GameSocket.mCharacter.mVCoin < 1000 then
							if GameSocket:getServerParam(19)>0 then
								GameSocket:alertLocalMsg("创建帮会需要1000钻石！", "alert")
							else
								GameSocket:PushLuaTable("server.showChongzhi","check")
								GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS, str = "createGuild"})
							end
						elseif GameCharacter._mainAvatar:NetAttr(GameConst.net_level) < 70 then
							GameSocket:alertLocalMsg("创建帮会需要70级！", "alert")
						-- elseif vip < 2 then
						-- 	GameSocket:alertLocalMsg("创建帮会需要vip达到2级！", "alert")
						else
							checkAndCreateGuild(inputText)
							GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = "createGuild"})
						end
					else
						GameSocket:alertLocalMsg("当前已加入帮会，不能创建新帮会！", "alert")
					end
				end
			}
			GameSocket:dispatchEvent(param)
		elseif btnName == "btn_quit_guild" then
			if isGuildAdmin() then
				checkAndDismissGuild()
			else
				checkAndLeaveGuild()
			end
		elseif btnName == "btn_onekey_declare" then
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "guildWarAll"}))
		end
	end

	var.xmlPageList = GUIAnalysis.load("ui/layout/ContainerGang_list.uif")
	if var.xmlPageList then
		GameUtilSenior.asyncload(var.xmlPageList, "page_guild_list_bg", "ui/image/page_general_bg.jpg")
		var.xmlPageList:align(display.LEFT_BOTTOM, 40, 20):addTo(var.xmlPanel)

		-- var.xmlPageMember:getWidgetByName("list_guild"):setSliderVisible(false)

		local btnPageList
		for _,v in ipairs(pageListButtons) do
			btnPageList = var.xmlPageList:getWidgetByName(v)
			GUIFocusPoint.addUIPoint(btnPageList, pushPageListButton)
		end

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_GUILD_LIST, updateGuildList)
			:addEventListener(GameMessageCode.EVENT_GUILD_WAR_CHANGE, function ()
				GameSocket:ListGuild(0)
			end)
	end
end
--------------------------------------帮会申请列表--------------------------------------
function ContainerGang.openPageApply()
	var.mSelectedApplicants = {}

	GameSocket:ListGuildMember(GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name), TAG_GUILD.LIST_TYPE_ENTERING_MEMBER)

	local btnOnekeyRefuse = var.xmlPageApply:getWidgetByName("btn_onekey_refuse"):hide()
	local btnOnekeyAgree = var.xmlPageApply:getWidgetByName("btn_onekey_agree"):hide()

	local myTitle = getMyGuildTitle()
	if myTitle >= TAG_GUILD.GUILD_TITLE_TYPE_VICEADMIN then
		btnOnekeyRefuse:show()
	end
	if myTitle >= TAG_GUILD.GUILD_TITLE_TYPE_ADV then
		btnOnekeyAgree:show()
	end
end
function ContainerGang.initPageApply()

	local applyInfo

	local function pushApprovalButton(sender)
		local btnName = sender:getName()
		applyInfo = var.mGuildApply[sender.tag]
		if btnName == "btn_agree" then
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "agreeJoin", memberName = applyInfo.name}))
			-- GameSocket:ChangeGuildMemberTitle(var.myGuildName, applyInfo.name,1)
			-- GameSocket:ListGuildMember(var.myGuildName, TAG_GUILD.LIST_TYPE_REAL_MEMBER)
			-- GameSocket:alertLocalMsg("已同意玩家["..applyInfo.name.."]加入帮会！", "alert")
		elseif btnName == "btn_refuse" then
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "refuseJoin", memberName = applyInfo.name}))
			-- GameSocket:ChangeGuildMemberTitle(var.myGuildName,applyInfo.name,0)
			-- GameSocket:ListGuildMember(var.myGuildName, TAG_GUILD.LIST_TYPE_ENTERING_MEMBER)
			-- GameSocket:alertLocalMsg("已拒绝玩家["..applyInfo.name.."]加入帮会！", "alert")
		end
	end

	local function updateApplicantItem(sender)
		if sender.applicant and table.indexof(var.mSelectedApplicants, sender.applicant) then
			--sender:getWidgetByName("img_item_selected"):show()
			sender:getWidgetByName("img_guild_applicant_bg"):loadTexture("img_xuanzhongkuang", ccui.TextureResType.plistType)
		else
			--sender:getWidgetByName("img_item_selected"):hide()
			sender:getWidgetByName("img_guild_applicant_bg"):loadTexture("render_bg", ccui.TextureResType.plistType)
		end
		-- print("updateApplicantItem", GameUtilSenior.encode(var.mSelectedApplicants))
	end

	local function compFunc(memberA, memberB)
		return getApplyTime(memberA) > getApplyTime(memberB)
	end

	local function pushApplicantItem(sender)
		if table.indexof(var.mSelectedApplicants, sender.applicant) then
			table.removebyvalue(var.mSelectedApplicants, sender.applicant)
		else
			table.insert(var.mSelectedApplicants, sender.applicant)
		end

		table.sort(var.mSelectedApplicants, compFunc)

		-- updateApplicantItem(sender)
	end


	local btnAgree, btnRefuse, underline
	local function updateApplyItem(item)
		if item.tag and var.mGuildApply[item.tag] then
			applyInfo = var.mGuildApply[item.tag]
			-- print("//////////////", GameUtilSenior.encode(applyInfo))
			item:getWidgetByName("lbl_player_name"):setString(applyInfo.name)
			item:getWidgetByName("lbl_player_job"):setString(GameConst.job_name[applyInfo.job])
			item:getWidgetByName("lbl_player_level"):setString(applyInfo.level)
			item:getWidgetByName("lbl_player_fight"):setString(applyInfo.fight)
			btnAgree = item:getWidgetByName("btn_agree"):setTouchEnabled(true)
			if not btnAgree:getChildByTag(100) then
				underline = GameUtilSenior.addUnderLine(btnAgree, GameBaseLogic.getColor4f(tonumber("4ada13",16)), 1)
				underline:setTag(100)
			end
			btnAgree.tag = item.tag
			btnRefuse = item:getWidgetByName("btn_refuse"):setTouchEnabled(true)
			if not btnRefuse:getChildByTag(100) then
				underline = GameUtilSenior.addUnderLine(btnRefuse, GameBaseLogic.getColor4f(tonumber("4ada13",16)), 1)
				underline:setTag(100)
			end
			btnRefuse.tag = item.tag
			GUIFocusPoint.addUIPoint(btnAgree, pushApprovalButton)
			GUIFocusPoint.addUIPoint(btnRefuse, pushApprovalButton)
			item.applicant = applyInfo.name
			-- item:setTouchEnabled(true)
			-- GUIFocusPoint.addUIPoint(item, pushApplicantItem)
			-- updateApplicantItem(item)
		end
	end

	local function updateApplyList(event)
		if event.memberType ~= MEMBER_TYPE.ENTERING then return end
		var.mSelectedApplicants = {}
		var.mGuildApply = getSortedMemebrs(MEMBER_TYPE.ENTERING)
		if var.mGuildApply then
			local listApplicant = var.xmlPageApply:getWidgetByName("list_applicant")
			listApplicant:reloadData(#var.mGuildApply, updateApplyItem, nil, false)
		end
	end

	local function pushPageApplyButton(sender)
		local btnName = sender:getName()
		if btnName == "btn_onekey_refuse" then
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "refuseAll", applicants = var.mSelectedApplicants}))
		elseif btnName == "btn_onekey_agree" then
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "agreeAll", applicants = var.mSelectedApplicants}))
		end
	end


	var.xmlPageApply = GUIAnalysis.load("ui/layout/ContainerGang_apply.uif")
	if var.xmlPageApply then
		--GameUtilSenior.asyncload(var.xmlPageApply, "page_guild_apply_bg", "ui/image/page_general_bg.jpg")
		var.xmlPageApply:align(display.LEFT_BOTTOM, 40, 20):addTo(var.xmlPanel)

		GUIFocusPoint.addUIPoint(var.xmlPageApply:getWidgetByName("btn_onekey_refuse"), pushPageApplyButton)
		GUIFocusPoint.addUIPoint(var.xmlPageApply:getWidgetByName("btn_onekey_agree"), pushPageApplyButton)


		cc.EventProxy.new(GameSocket, var.xmlPageApply)
			:addEventListener(GameMessageCode.EVENT_GUILD_MEMBER, updateApplyList)
			:addEventListener(GameMessageCode.EVENT_GUILD_MEMBER_CHANGE, function (event)
				GameSocket:ListGuildMember(GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name), TAG_GUILD.LIST_TYPE_ENTERING_MEMBER)
			end)
	end
end
--------------------------------------帮会红包--------------------------------------
local MIN_HONGBAO_NUM = 10
local MAX_HONGBAO_NUM = 50
local MIN_HONGBAO_VCOIN = 1000
local MAX_HONGBAO_VCOIN = 2100000000

local function updateHongbaoVcoin(inputText)
	-- print("//////////////updateHongbaoVcoin//////////////", inputText)
	local editHongbaoVcoin = var.xmlPageHongbao:getWidgetByName("edit_hongbao_vcoin")
	inputText = tonumber(editHongbaoVcoin:getText())
	inputText = inputText or 0
	if inputText < MIN_HONGBAO_VCOIN then
		inputText = MIN_HONGBAO_VCOIN
	elseif inputText > MAX_HONGBAO_VCOIN then
		inputText = MAX_HONGBAO_VCOIN
	end
	var.mHongBaoVcoin = inputText
	editHongbaoVcoin:setText(var.mHongBaoVcoin)
end

local function updateHongbaoNum(inputText)
	local editHongbaoNum = var.xmlPageHongbao:getWidgetByName("edit_hongbao_num")
	inputText = tonumber(editHongbaoNum:getText())
	inputText = inputText or 0
	if inputText < MIN_HONGBAO_NUM then
		inputText = MIN_HONGBAO_NUM
	elseif inputText > MAX_HONGBAO_NUM then
		inputText = MAX_HONGBAO_NUM
	end
	var.mHongBaoNum = inputText
	editHongbaoNum:setText(var.mHongBaoNum)
end
function ContainerGang.openPageHongbao()
	GameSocket:reqGuildRedPacketLog()
	updateHongbaoVcoin(0)
	updateHongbaoNum(0)
	GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "hongbaoInfo"}))
end

function ContainerGang.initPageHongbao()
	local pageHongbaoButtons = {
		"btn_send_hongbao", "btn_grab_hongbao"
	}

	local function updateHongbaoInfo(data)
		var.xmlPageHongbao:getWidgetByName("lbl_hongbao_remain"):setString(data.numRemain)
		local lblHongBaoTime = var.xmlPageHongbao:getWidgetByName("lbl_hongbao_time"):setString(GameUtilSenior.setTimeFormat(data.timeRemain * 1000, 2))
		lblHongBaoTime:stopAllActions()
		var.mHongBaoTime = data.timeRemain
		lblHongBaoTime:runAction(cca.repeatForever(
			cca.seq({
				cca.delay(1),
				cca.callFunc(function (pSender)
					if var.mHongBaoTime > 0 then
						var.mHongBaoTime = var.mHongBaoTime - 1
						pSender:setString(GameUtilSenior.setTimeFormat(var.mHongBaoTime * 1000, 2))
					else
						pSender:stopAllActions()
					end
				end)
			})
		))
	end

	local function onGetHongBao(vcoin)
		var.mHongBaoGot:setString(vcoin)
		--local imgHongBaoGet = var.xmlPageHongbao:getWidgetByName("img_hongbao_get")
		--imgHongBaoGet:stopAllActions()
		--imgHongBaoGet:runAction(cca.seq({cca.show(), cca.delay(2), cca.hide()}))
	end

	local function onPanelData(event)
		if event.type == "ContainerGang" then
			local data = GameUtilSenior.decode(event.data)
			if not data then return end
			if data.cmd == "guildHongbao" then
				updateHongbaoInfo(data)
			elseif data.cmd == "getHongBao" then
				onGetHongBao(data.vcoin)
			elseif data.cmd == "redPacket" then
				--帮会红包红点检测
				local btnGrabHongBao = var.xmlPanel:getWidgetByName("btn_grab_hongbao")
				if not btnGrabHongBao then return end
				if data.showRedPoint then
					GameUtilSenior.addHaloToButton(btnGrabHongBao, "btn_normal_light3")
				else
					btnGrabHongBao:removeChildByName("img_bln")
				end
			end
		end
	end

	local function pushPageHongbaoButton(sender)
		local btnName = sender:getName()
		if btnName == "btn_send_hongbao" then
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "sendHongbao", vcoin = var.mHongBaoVcoin, num = var.mHongBaoNum}))
		elseif btnName == "btn_grab_hongbao" then
			GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "grabHongbao"}))
		end
	end

	local logData, strLog, imgItemHongbaoBg
	local function updateHongbaoLogItem(item)
		logData = var.mHongBaoLogs[item.tag]
		if logData.opCode == 0 then
			strLog = "发出"
		else
			strLog = "获得"
		end
		strLog = "<font color=#ffdb00>【<font color=#ffdb00>"..logData.sender.."</font>】"..strLog.."<font color=#ffdb00>"..logData.vcoin.."</font>元宝</font>"
		local richWidget = GUIRichLabel.new({size = cc.size(308, 50), fontSize = 18, space=10, name = "hongbaolog"})
		richWidget:setRichLabel(strLog,"",18)
		imgItemHongbaoBg = item:getWidgetByName("img_item_hongbao_bg")
		imgItemHongbaoBg:removeAllChildren()
		imgItemHongbaoBg:addChild(richWidget)
		richWidget:align(display.LEFT_CENTER, 10, imgItemHongbaoBg:getContentSize().height * 0.6)
	end

	local function updateListHongbaoLog()
		local listHongbao = var.xmlPageHongbao:getWidgetByName("list_hongbao")
		listHongbao:reloadData(#var.mHongBaoLogs, updateHongbaoLogItem)
	end

	local function onGuildHongBaoLogs(event)
		var.mHongBaoLogs = event.logs
		updateListHongbaoLog()
	end

	local function onGuildHongBaoLog(event)
		local log = event.log
		if log then
			table.insert(var.mHongBaoLogs, log)
			updateListHongbaoLog()
		end
	end

	var.xmlPageHongbao = GUIAnalysis.load("ui/layout/ContainerGang_hongbao.uif")
	if var.xmlPageHongbao then
		GameUtilSenior.asyncload(var.xmlPageHongbao, "page_guild_hongbao_bg", "ui/image/page_guild_hongbao_bg.jpg")
		var.xmlPageHongbao:align(display.LEFT_BOTTOM, 40, 20):addTo(var.xmlPanel)


		local params = {
			root = var.xmlPageHongbao,
			lblName = "lbl_hongbao_num",
			pName = "img_editbox_hongbao_num",
			updateFunc = updateHongbaoNum
		}
		local editBoxNum = createNumInputEditBox(params):setName("edit_hongbao_num")

		local params = {
			root = var.xmlPageHongbao,
			lblName = "lbl_hongbao_vcoin",
			pName = "img_editbox_hongbao_vcoin",
			updateFunc = updateHongbaoVcoin
		}
		local editBoxVcoin = createNumInputEditBox(params):setName("edit_hongbao_vcoin")

		local btnPageHongbao
		for _,v in ipairs(pageHongbaoButtons) do
			btnPageHongbao = var.xmlPageHongbao:getWidgetByName(v)
			if btnPageHongbao then
				GUIFocusPoint.addUIPoint(btnPageHongbao, pushPageHongbaoButton)
			end
		end
		local imgHongBaoGet = var.xmlPageHongbao:getWidgetByName("img_hongbao_get"):hide()

		var.mHongBaoGot = ccui.TextAtlas:create("0123456789", "image/typeface/num_36.png", 34, 40, "0")
			:addTo(imgHongBaoGet)
			:align(display.RIGHT_CENTER, 230,68)
			:setString(123456)

		var.mHongBaoLogs = {}


		local btnHongBaoTips = var.xmlPageHongbao:getWidgetByName("btn_hongbao_tips"):addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true, infoTable = guildHint["hongbao"],})
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled  then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false })
			end
		end)

		cc.EventProxy.new(GameSocket, var.xmlPageHongbao)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, onPanelData)
			:addEventListener(GameMessageCode.EVENT_GUILD_HONGBAO_LOGS, onGuildHongBaoLogs)
			:addEventListener(GameMessageCode.EVENT_GUILD_HONGBAO_LOG, onGuildHongBaoLog)
	end
end
--------------------------------------帮会日志--------------------------------------
function ContainerGang.openPageLog()
	-- print("////////openPageLog///////////")
	GameSocket:reqGuildItemLog()
end

function ContainerGang.initPageLog()
	local mGuildLogs = {}

	local logData, strLog, imgItemLogBg
	local function updateLogItem(item)
		logData = mGuildLogs[item.tag]
		-- print("updateLogItem",item.tag, logData.opCode)
		if logData.opCode == 0 then
			strLog = "捐献了"
		elseif logData.opCode == 1 then
			strLog = "兑换了"
		elseif logData.opCode == 2 then
			strLog = "摧毁了"
		end

		strLog = "<font color=#c0ac8c>"..logData.name..strLog.."<font color=#bc813a>【"..logData.itemName.."】</font></font>"
		local richWidget = GUIRichLabel.new({size = cc.size(308, 50), fontSize = 18, space=10, name = "hongbaolog"})
		richWidget:setRichLabel(strLog,"",18)
		imgItemLogBg = item:getWidgetByName("img_item_log_bg")
		imgItemLogBg:removeAllChildren()
		imgItemLogBg:addChild(richWidget)
		richWidget:align(display.LEFT_CENTER, 400, imgItemLogBg:getContentSize().height * 0.6)
		item:getWidgetByName("lbl_log_time"):setString(GameUtilSenior.formatDate(logData.time))
	end

	local function updateListLog()
		local listLog = var.xmlPageLog:getWidgetByName("list_log")
		listLog:reloadData(#mGuildLogs, updateLogItem)
	end

	local function onGuildItemLogs(event)
		mGuildLogs = event.logs
		-- print("onGuildItemLogs", GameUtilSenior.encode(mGuildLogs))
		updateListLog()
	end


	var.xmlPageLog = GUIAnalysis.load("ui/layout/ContainerGang_log.uif")
	if var.xmlPageLog then
		GameUtilSenior.asyncload(var.xmlPageLog, "page_guild_log_bg", "ui/image/page_guild_log_bg.jpg")
		var.xmlPageLog:align(display.LEFT_BOTTOM, 40, 20):addTo(var.xmlPanel)

		cc.EventProxy.new(GameSocket, var.xmlPageLog)
			:addEventListener(GameMessageCode.EVENT_GUILD_ITEM_LOGS, onGuildItemLogs)
	end
end
return ContainerGang