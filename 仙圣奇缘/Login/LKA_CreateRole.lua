Game_CreateCharacter1 = nil
local CreateDialogueID = 1
local strInputName = nil
local ChoosePartTag = nil
local Panel_Dialogue = nil
local bHideInput = true
local roleSex = 0

local function showInputName()
	local Image_Name = tolua.cast(Game_CreateCharacter1:getChildByName("Image_Name"), "ImageView")
	Image_Name:setVisible(true)

	local TextField_Name = tolua.cast(Image_Name:getChildByName("TextField_Name"), "TextField")
	strInputName = TextField_Name:getStringValue()

	if strInputName == "" then
		g_ClientMsgTips:showMsgConfirm(_T("请先输入角色的名称！"))
	else
		g_MsgMgr:requestCheckName(strInputName)
	end
end

function onRespCheckName(nTag)
	local Image_Name = tolua.cast(Game_CreateCharacter1:getChildByName("Image_Name"), "ImageView")
	if nTag == 0 then
		local TextField_Name = tolua.cast(Image_Name:getChildByName("TextField_Name"), "TextField")
		strInputName = TextField_Name:getStringValue()
	else
		local TextField_Name = tolua.cast(Image_Name:getChildByName("TextField_Name"), "TextField")
		TextField_Name:setText("")
		g_ClientMsgTips:showMsgConfirm(_T("名称已被其他人使用了！"))
	end
end
local timerId = nil

local function requestRandomName()
	--g_MsgMgr:requestRandomName()
	local function DynamicLabel(ftime, bover)
		if(bover)then
			showInputName()
			if timerId then 
				g_Timer:destroyTimerByID(timerId)
				timerId = nil
			end
		else
			if not bHideInput then
				return true
			elseif not g_MsgMgr.nSendMsgTime then
				showInputName()
				return true
			end
		end
	end
	timerId = g_Timer:pushLimtTimeTimer(g_MsgMgr.nWaitClearTime, DynamicLabel)
end

function onResponseRandomName(szName)
	if not Game_CreateCharacter1 then
		showCreateCharacter()
	else
		cclog("=======Game_CreateCharacter1 is exists========")
	end
	local Image_Name = tolua.cast(Game_CreateCharacter1:getChildByName("Image_Name"), "ImageView")
	local TextField_Name = tolua.cast(Image_Name:getChildByName("TextField_Name"), "TextField")
	
	
	if g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_zh_CN then
		TextField_Name:setMaxLength(7)
	elseif g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_cht_Taiwan then
		TextField_Name:setMaxLength(7)
	elseif g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_zh_AUDIT then
		TextField_Name:setMaxLength(7)
	else
		TextField_Name:setMaxLength(12)
	end
	
	local text = TextField_Name:getStringValue()
	TextField_Name:setText(szName)
	if bHideInput then
		showInputName()
	end
end


local function setCharacterWnd()
	--requestRandomName()
	local Image_ServerPNL = tolua.cast(Game_CreateCharacter1:getChildByName("Image_ServerPNL"), "ImageView")
	local Label_ServerName = tolua.cast(Image_ServerPNL:getChildByName("Label_ServerName"), "Label")
	local latelyAreaID = CCUserDefault:sharedUserDefault():getIntegerForKey("nCsvID", 0)
    if latelyAreaID == 0 then
	    _, latelyAreaID = g_DataMgr:getSeverInfoCsvNew()
	end
	local tbCurServer = g_DataMgr:getSeverInfoCsv(tonumber(latelyAreaID))
	Label_ServerName:setText(g_ServerList:GetLocalName())
	cclog("-------->setCharacterWnd()"..g_ServerList:GetLocalName())
end

local nRetryTimes = nil
local nRetry = 0
local function createRole()
	local Image_Name = tolua.cast(Game_CreateCharacter1:getChildByName("Image_Name"), "ImageView")
	local TextField_Name = tolua.cast(Image_Name:getChildByName("TextField_Name"), "TextField")
	local strInputName = TextField_Name:getStringValue()
	if not strInputName or strInputName == "" then return end
	g_MsgMgr:requestCreateRole(strInputName, ChoosePartTag)

	if CGamePlatform:SharedInstance().submitExtendDataEx then --G_SubmitData then
		local uid = g_MsgMgr:getZoneUin()
		local ilv = "1"
		local accname = strInputName
		local servername = g_ServerList:GetLocalName()
    	local nyuanbao = 50
    	CGamePlatform:SharedInstance():submitExtendDataEx(uid, accname, ilv, servername, nyuanbao, g_ServerList:GetLocalServerID(), 4)
    end

    if CGameDataAdTracking and CGameDataAdTracking.onRegister then
		CGameDataAdTracking:onRegister(g_GamePlatformSystem:GetAccount_PlatformID())
		cclog("CGameDataAdTracking:onRegister:"..g_GamePlatformSystem:GetAccount_PlatformID())
	end

    if CGameDataAdTracking and CGameDataAdTracking.onCreateRole then
        CGameDataAdTracking:onCreateRole(strInputName)
		cclog("CGameDataAdTracking:createRole:"..strInputName)
     end
end

local function setCharacterAnimation(CSV_PlayerCreate)

	local nCardID = CSV_PlayerCreate.CardID or 108
	local starLev = CSV_PlayerCreate.StarLevel or 1
	local CSV_CardBase = g_DataMgr:getCardBaseCsv(nCardID, starLev)
	local Panel_CardPos = tolua.cast(Game_CreateCharacter1:getChildByName("Panel_CardPos"), "Layout")
	local Image_Card = tolua.cast(Panel_CardPos:getChildByName("Image_Card"), "ImageView")
	local CCNode_Skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1, true)
	Image_Card:removeAllNodes()
	Image_Card:loadTexture(getUIImg("Blank"))
	Image_Card:setPositionXY(CSV_CardBase.Pos_X*Panel_CardPos:getScale()/0.6, CSV_CardBase.Pos_Y*Panel_CardPos:getScale()/0.6)
	Image_Card:addNode(CCNode_Skeleton)
	g_runSpineAnimation(CCNode_Skeleton, "idle", true)
end

local function selectSexAction(nTag)
	local Button_SelectSex1 = tolua.cast(Game_CreateCharacter1:getChildByName("Button_SelectSex1"), "Button")
	local Button_SelectSex2 = tolua.cast(Game_CreateCharacter1:getChildByName("Button_SelectSex2"), "Button")
	local actionMoveToSex1
	local actionMoveToSex1
	local nPos1 = Button_SelectSex1:getPosition()
	local nPos2 = Button_SelectSex2:getPosition()
	if nTag == 1 then
		actionMoveToSex1= CCMoveTo:create(0.2, ccp(925,nPos1.y))
		actionMoveToSex2= CCMoveTo:create(0.2, ccp(870,nPos2.y))
	else
		actionMoveToSex1= CCMoveTo:create(0.2, ccp(825,nPos1.y))
		actionMoveToSex2= CCMoveTo:create(0.2, ccp(950,nPos2.y))
	end
	actionMoveBy_PlayerEase1 =  CCEaseSineIn:create(actionMoveToSex1)
	actionMoveBy_PlayerEase2 =  CCEaseSineIn:create(actionMoveToSex2)
	Button_SelectSex1:runAction(actionMoveBy_PlayerEase1)
	Button_SelectSex2:runAction(actionMoveBy_PlayerEase2)
end

local function saiziAciton(widget)
	local actionRotateTo = CCRotateTo:create(0.3, -1440)
	widget:runAction(actionRotateTo)
end

function CheckRoleName(nzname)
	if g_LggV and g_LggV.LanguageVer and g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET then
		return true
	end

	local ress =  string.find(nzname, "%s")--%s	空白符

	local resp = string.find(nzname, "%p")--%p	标点字符

	local resc = string.find(nzname, "%c")--%c	控制字符	string.find("abcd\t\n","%c%c")

	return ( not ress and not resp  and not resc )
end



function showCreateCharacter()
	-- if g_ServerList:GetLocalName() == "" then --在前面没有选服务器 这里默认旋转第一个
	-- 	g_ServerList:SetLocalServerInfo(1)

	-- end

	Game_CreateCharacter1 = GUIReader:shareReader():widgetFromJsonFile("Game_CreateCharacter1.json")
	StartGameLayer:addWidget(Game_CreateCharacter1)

	Game_CreateCharacter1:setTouchEnabled(true)
	local Image_Name = tolua.cast(Game_CreateCharacter1:getChildByName("Image_Name"), "ImageView")
	
	local Button_StartGame = tolua.cast(Game_CreateCharacter1:getChildByName("Button_StartGame"), "Button")
	local function onPressed_Button_StartGame(pSender, nTag)
		if not Game_CreateCharacter1 then
			showCreateCharacter()
		else
			cclog("=======Game_CreateCharacter1 is exists========")
		end

		local TextField_Name = tolua.cast(Image_Name:getChildByName("TextField_Name"), "TextField")
		local text = TextField_Name:getStringValue()

		if CheckRoleName(text) == false then
			g_ClientMsgTips:showMsgConfirm(_T("角色名称只能为中文,英文,数字组成"))
			return
		end

		-- if containsEmoji(text) == true then
		-- 	g_ClientMsgTips:showMsgConfirm("角色名称不能为表情符号")
		-- 	return 
		-- end

		if string.len(text) > 31 then
			g_ClientMsgTips:showMsgConfirm(_T("角色名称不能超过30个字符"))
			return
		end

		if string.len(text) == 0 then
			g_ClientMsgTips:showMsgConfirm(_T("角色名称不能为空"))
			return
		end

		createRole()
		CCUserDefault:sharedUserDefault():setBoolForKey("IsAutoFight", true)
		CCUserDefault:sharedUserDefault():setIntegerForKey("nAccelerateSpeed", 1)
		CCUserDefault:sharedUserDefault():setIntegerForKey("ClickCount_ZhuanPan", 0)
		CCUserDefault:sharedUserDefault():setIntegerForKey("ClickCount_ShangXiang", 0)
		CCUserDefault:sharedUserDefault():setIntegerForKey("ClickCount_HuntFate", 0)
		CCUserDefault:sharedUserDefault():setIntegerForKey("ClickCount_GanWu", 0)
		CCUserDefault:sharedUserDefault():setIntegerForKey("ClickCount_BaXian", 0)
		CCUserDefault:sharedUserDefault():setIntegerForKey("ClickCount_JueXing", 0)
		CCUserDefault:sharedUserDefault():setIntegerForKey("ClickCount_DragonPray", 0)
	end
	g_SetBtnWithEvent(Button_StartGame, 1, onPressed_Button_StartGame, true)
	
	local Button_Shaizi = tolua.cast(Image_Name:getChildByName("Button_Shaizi"), "Button")
	local function onPressed_Button_Shaizi(pSender, nTag)
		saiziAciton(Button_Shaizi)
		g_MsgMgr:requestRandomName()
	end
	g_SetBtnWithEvent(Button_Shaizi, 1, onPressed_Button_Shaizi, true)

	local Button_SelectSex1 = tolua.cast(Game_CreateCharacter1:getChildByName("Button_SelectSex1"), "Button")
	local Button_SelectSex2 = tolua.cast(Game_CreateCharacter1:getChildByName("Button_SelectSex2"), "Button")

	local ButtonGroup = ButtonGroup:create()
	ButtonGroup:PushBack(Button_SelectSex1,nil ,function()
		ChoosePartTag = 1
		local tbMsg = g_DataMgr:getPlayerCreateCsv(ChoosePartTag)
		setCharacterAnimation(tbMsg)
		selectSexAction(1)
	end)
	ButtonGroup:PushBack(Button_SelectSex2, nil,function()
		ChoosePartTag = 2
		local tbMsg = g_DataMgr:getPlayerCreateCsv(ChoosePartTag)
		setCharacterAnimation(tbMsg)
		selectSexAction(0)
	end,false)

	--g_MsgMgr:requestRandomName()
	ButtonGroup:Click(1)
	setCharacterWnd()
	
	-- local TDdata =  CDataEvent:CteateDataEvent()
	-- TDdata:PushDataEvent("Step2", "S") --S or F, Success or Fail
	-- gTalkingData:onEvent(TDEvent_Type.Create, TDdata)
end


--检测是否有emoji表情 * @param source * @return 
function containsEmoji(source)
    local nlen = tonumber( string.len(source))
    local i = 1
    local shift = 1
	while i <=  nlen do
		local c = string.byte(source, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        else
        	if isEmojiCharacter(c) then
        		return true
        	end

        	shift = 3
			
        end
		i = i + shift
    end
 	return false 
end

--判断是否是Emoji * @param codePoint 比较的单个字符 * @return */ 
function isEmojiCharacter(codePoint) 
	return  (codePoint == 0x0) or 
			(codePoint == 0x9) or 
			(codePoint == 0xA) or 
			(codePoint == 0xD) or
			((codePoint >= 0x20) and (codePoint <= 0xD7FF)) or
			((codePoint >= 0xE000) and (codePoint <= 0xFFFD)) or
			((codePoint >= 0x10000) and (codePoint <= 0x10FFFF))
end
