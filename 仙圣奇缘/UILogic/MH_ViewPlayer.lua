Game_ViewPlayer = class("Game_ViewPlayer")
Game_ViewPlayer.__index = Game_ViewPlayer

local playerInfo = nil
local nAttOrder = 0

local nRobotCount = 1000

local function checkCurZhenFaIndex(nPos)
    if nPos >  9 then return nPos - 10 + 6 end

    local tbZhenFa = playerInfo.detail.tbZhenFa
    for i=1, #tbZhenFa do
        if tbZhenFa[i].BuZhenPosIndex == nPos then
            return tbZhenFa[i].ZhenXinID
        end
    end
end

local function setBuZhenData(Button_Pos, nIndex)
	local Panel_Pos = Button_Pos:getChildByName("Panel_Pos")
	if(Panel_Pos)then
		Panel_Pos:removeFromParentAndCleanup(true)
	end
    
    if nIndex < 10 then
		local image = getBuZhenImg("Btn_Pos"..nIndex.."_Click")
		local imageDisabled = getBuZhenImg("Btn_Pos"..nIndex.."_Disabled")
        if checkCurZhenFaIndex(tbClientToServerPosConvert[nIndex]) then
            Button_Pos:loadTextures(image,image,imageDisabled)
        else
            Button_Pos:loadTextures(imageDisabled,image,imageDisabled)
        end
    end

	local pi = nil
	local leader = false
	for _,v in ipairs(playerInfo.detail.team_info) do
        local nCurPos = v.pos
		
        if nCurPos >= 6 then
            nCurPos = nCurPos - 6 + 10
        else
            nCurPos = playerInfo.detail.tbZhenFa[v.pos].BuZhenPosIndex
        end

		if nCurPos  == tbClientToServerPosConvert[nIndex] then
			pi = v.data
			leader = v.leader
			break
        end
	end
	if not pi then return end
	local CSV_CardBase = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("CardBase", pi.configid, pi.star_lv)
	nAttOrder = nAttOrder + 1
	
	Panel_Pos = Layout:create()
	Panel_Pos:setName("Panel_Pos")
	Panel_Pos:setScale(BuZhenScale[nIndex])
	
	local posHpX = CSV_CardBase.HPBarX or 0
	local posHpY = CSV_CardBase.HPBarY or 0
	local Label_Name = Label:create()

    if CSV_CardBase.ID == 3001 or CSV_CardBase.ID == 3002 then	--是主角卡g_Hero.otherLeaderName
        Label_Name:setText(getFormatSuffixLevel(playerInfo.name, g_GetCardEvoluteSuffixByEvoLev(pi.breachlv)))
		g_SetCardNameColorByEvoluteLev(Label_Name, pi.breachlv)
	else
		Label_Name:setText(g_GetCardNameWithSuffix(CSV_CardBase, pi.breachlv, Label_Name))
	end

	Label_Name:setPosition(ccp(posHpX,posHpY+25))
	Label_Name:setFontSize(22)
	Panel_Pos:addChild(Label_Name, 2)
	
	local ImageView_StarLevel = ImageView:create()
	-- ImageView_StarLevel:loadTexture(getIconStarLev(pi.star_lv+1))
	ImageView_StarLevel:loadTexture(getIconStarLev(pi.star_lv))
	ImageView_StarLevel:setPositionXY(posHpX, posHpY-5)
	ImageView_StarLevel:setScale(0.9)
	Panel_Pos:addChild(ImageView_StarLevel, 2)
	
	local LabelAtlas_AttOrder = LabelAtlas:create()
	local tbSize = Label_Name:getContentSize()
    if(nIndex > 9)then --替补
        if nAttOrder < 6 then
            nAttOrder = 6
        end
	end
    LabelAtlas_AttOrder:setProperty(string.format("%d",nAttOrder), "Char/LabelAltas_AttackOrder.png", 52, 27,"1")
	
    if leader then
		local Image_Leader = ImageView:create()
		Image_Leader:loadTexture(getUIImg("LeaderFlag"))
		Label_Name:addChild(Image_Leader)
		Image_Leader:setPosition(ccp(-tbSize.width/2-20, 0))
	end

	LabelAtlas_AttOrder:setScale(1)
	LabelAtlas_AttOrder:setAnchorPoint(ccp(0.0,0.5))
	LabelAtlas_AttOrder:setPosition(ccp(tbSize.width/2+10,0))
	Label_Name:addChild(LabelAtlas_AttOrder)

	local posX = CSV_CardBase.Pos_X or 0
	local posY = CSV_CardBase.Pos_Y or 0
	
	local Image_Card = ImageView:create()
	local CCNode_Skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1) 
	Image_Card:removeAllNodes()
	Image_Card:setScale(0.6)
	Image_Card:setAnchorPoint(ccp(0.5,0))
	Image_Card:setPosition(ccp(posX,posY))
	Image_Card:setName("Image_Card")
	Image_Card:addNode(CCNode_Skeleton )
	g_runSpineAnimation(CCNode_Skeleton, "idle", true)
	Panel_Pos:addChild(Image_Card, 1)
	
	local ImageView_Shadow = ImageView:create()
	ImageView_Shadow:loadTexture(getUIImg("Shadow"))
	ImageView_Shadow:setPosition(ccp(0,0))
	Panel_Pos:addChild(ImageView_Shadow, 0)
	
	Button_Pos:addChild(Panel_Pos)
end

function Game_ViewPlayer:RelationRmFriend()
	self.BitmapLabel_FuncName:setText(_T("添加好友"))
	local function onPressed_Button_AddOrDelFriend(pSender, nTag)
		local title = string.format( _T("向[%s]打招呼"), tostring(playerInfo.name))
		g_ClientMsgTips:showConfirmInput(title, _T("您好，我可以加您为好友吗？"), 20, function(str)
			g_MsgMgr:requestRelationAddFriend({uin=playerInfo.uin, msg=str})
			g_SetBtnEnable(self.Button_AddOrDelFriend, false)
		end)
	end
	g_SetBtnWithEvent(self.Button_AddOrDelFriend, 1, onPressed_Button_AddOrDelFriend, true)
end

function Game_ViewPlayer:initWnd()
	self.Button_AddOrDelFriend = tolua.cast(self.rootWidget:getChildByName("Button_AddOrDelFriend"), "Button")
	
	local function onPressed_Button_AddOrDelFriend(pSender, nTag)
		if playerInfo.is_friend then
			g_ClientMsgTips:showConfirm(string.format(_T("是否确认删除好友[%s]？"), tostring(playerInfo.name)), function()
				g_MsgMgr:requestRelationRmFriend(playerInfo.uin)
			end)
		else
			local title = string.format( _T("向[%s]打招呼"), tostring(playerInfo.name)) 
			g_ClientMsgTips:showConfirmInput(title, _T("您好，我可以加您为好友吗？"), 20, function(str)
				g_MsgMgr:requestRelationAddFriend({uin=playerInfo.uin, msg=str})
			end)
		end
	end
	g_SetBtnWithEvent(self.Button_AddOrDelFriend, 1, onPressed_Button_AddOrDelFriend, true)
	

	self.Button_ViewMember = tolua.cast(self.rootWidget:getChildByName("Button_ViewMember"), "Button")
	local function onPressed_Button_ViewMember(pSender, nTag)
		g_WndMgr:openWnd("Game_CardDetailViewOther1", {1, playerInfo})
	end
	g_SetBtnWithEvent(self.Button_ViewMember, 1, onPressed_Button_ViewMember, true)

	self.Button_ViewProfile = tolua.cast(self.rootWidget:getChildByName("Button_ViewProfile"), "Button")
	local function onPressed_Button_ViewProfile(pSender, nTag)
		g_WndMgr:showWnd("Game_ViewProfile1", playerInfo)
	end
	g_SetBtnWithEvent(self.Button_ViewProfile, 1, onPressed_Button_ViewProfile, true)
	
	self.Button_QieCuo = tolua.cast(self.rootWidget:getChildByName("Button_QieCuo"), "Button")
	local function onPressed_Button_QieCuo(pSender, nTag)
        if self.bKuaFu ~=nil and self.bKuaFu ==  true then
		    g_MsgMgr:requestViewPlayerPk_KuaFu(playerInfo.uin)
        else
            g_MsgMgr:requestViewPlayerPk(playerInfo.uin)
        end
	end
	g_SetBtnWithOpenCheck(self.Button_QieCuo, 1, onPressed_Button_QieCuo, true)
	
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		self.Button_AddOrDelFriend:setPositionX(870)
		self.Button_QieCuo:setVisible(false)
		local Image_MainBottom = tolua.cast(self.rootWidget:getChildByName("Image_MainBottom"), "ImageView")
		Image_MainBottom:setPositionX(1430)
	else
	
	end
	
	local Image_PlayerInfo = self.rootWidget:getChildByName("Image_PlayerInfo")
	
	local Label_TeamStrengthLB = Image_PlayerInfo:getChildByName("Label_TeamStrengthLB")
	local BitmapLabel_TeamStrength = Image_PlayerInfo:getChildByName("BitmapLabel_TeamStrength")
	local function onCloseTip1(pSender, nTag)
		g_ClientMsgTips:closeTip()
	end
	g_SetBtnWithPressingEvent(Label_TeamStrengthLB, nil, g_OnShowTip, nil, onCloseTip1, true, 0.0)
	g_SetBtnWithPressingEvent(BitmapLabel_TeamStrength, nil, g_OnShowTip, nil, onCloseTip1, true, 0.0)
	
	local Label_InitiativeLB = Image_PlayerInfo:getChildByName("Label_InitiativeLB")
	local BitmapLabel_Initiative = Image_PlayerInfo:getChildByName("BitmapLabel_Initiative")
	local function onCloseTip2(pSender, nTag)
		g_ClientMsgTips:closeTip()
	end
	g_SetBtnWithPressingEvent(Label_InitiativeLB, nil, g_OnShowTip, nil, onCloseTip2, true, 0.0)
	g_SetBtnWithPressingEvent(BitmapLabel_Initiative, nil, g_OnShowTip, nil, onCloseTip2, true, 0.0)
	
	local Label_RankLB = Image_PlayerInfo:getChildByName("Label_RankLB")
	local BitmapLabel_Rank = Image_PlayerInfo:getChildByName("BitmapLabel_Rank")
	local function onCloseTip3(pSender, nTag)
		g_ClientMsgTips:closeTip()
	end
	g_SetBtnWithPressingEvent(Label_RankLB, nil, g_OnShowTip, nil, onCloseTip3, true, 0.0)
	g_SetBtnWithPressingEvent(BitmapLabel_Rank, nil, g_OnShowTip, nil, onCloseTip3, true, 0.0)

	self.BitmapLabel_FuncName = tolua.cast(self.Button_AddOrDelFriend:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	self.Button_Pos = {}
	
	local Image_Buzhen = tolua.cast(self.rootWidget:getChildByName("Image_Buzhen"), "ImageView")
	for i=1,12 do
		local btn = tolua.cast(Image_Buzhen:getChildByName("Button_Pos"..i),"Button")
		btn:setTouchEnabled(false)
		table.insert(self.Button_Pos, btn)
	end
	
	local function initBackgroundAnimation()
		local wndInstantce = g_WndMgr:getWnd("Game_ViewPlayer")
		if wndInstantce then
			local ImageView_Background = tolua.cast(wndInstantce.rootWidget:getChildByName("ImageView_Background"), "ImageView")
			g_InitBuZhenBackgroundAnimation(ImageView_Background)
		end
	end
	self.nTimerID_Game_ViewPlayer_1 =  g_Timer:pushTimer(1, initBackgroundAnimation)
	
	local ImageView_Background = tolua.cast(self.rootWidget:getChildByName("ImageView_Background"), "ImageView")
	ImageView_Background:loadTexture(getBackgroundPngImg("Buzhen_Main"))
	local ImageView_Prospect1 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect1"), "ImageView")
	ImageView_Prospect1:loadTexture(getBackgroundJpgImg("Buzhen_Prospect1"))
	local ImageView_Prospect2 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect2"), "ImageView")
	ImageView_Prospect2:loadTexture(getBackgroundJpgImg("Buzhen_Prospect2"))
end

function onViewPlayer(info)
	playerInfo = {}
	playerInfo.uin = info.uin
	playerInfo.viplv = info.viplv
	if info.name == "小语" then
		info.name = _T("小语")
	end
	playerInfo.name = info.name
	playerInfo.sex = info.sex
	playerInfo.lv = info.lv
	playerInfo.fighting = info.fighting
	playerInfo.industry = info.industry
	playerInfo.profession = info.profession
	playerInfo.area = info.area
	playerInfo.signature = info.signature
	playerInfo.is_friend = info.is_friend
	playerInfo.main_card_id = info.main_card_id
	playerInfo.main_card_slv = info.main_card_slv
	g_MsgMgr:requestViewPlayerDetail(info.uin)
end


function onKuaFuViewPlayer(info)

	local brief_info = info.brief_info

	playerInfo = {}
	playerInfo.uin = brief_info.uin
	playerInfo.viplv = brief_info.viplv
	if brief_info.name == "小语" then
		brief_info.name = _T("小语")
	end
	playerInfo.name = brief_info.name
	playerInfo.sex = brief_info.sex
	playerInfo.lv = brief_info.lv
	playerInfo.fighting = brief_info.fighting
	playerInfo.industry = brief_info.industry
	playerInfo.profession = brief_info.profession
	playerInfo.area = brief_info.area
	playerInfo.signature = brief_info.signature
	playerInfo.is_friend = brief_info.is_friend
	playerInfo.main_card_id = brief_info.main_card_id
	playerInfo.main_card_slv = brief_info.main_card_slv
	
	g_ArenaKuaFuData:requestCrossViewPlayerDetail(brief_info.uin)
end


function Game_ViewPlayer:closeWnd()
	for i,v in ipairs(self.Button_Pos) do
		local Panel_Pos = v:getChildByName("Panel_Pos")
		if(Panel_Pos)then
			Panel_Pos:removeFromParentAndCleanup(true)
		end
	end

	g_Timer:destroyTimerByID(self.nTimerID_Game_ViewPlayer_1)
	self.nTimerID_Game_ViewPlayer_1 = nil
	
	g_Hero:setRestCardBattedata(nil)
	playerInfo = nil
	
	local ImageView_Background = tolua.cast(self.rootWidget:getChildByName("ImageView_Background"), "ImageView")
	ImageView_Background:loadTexture(getUIImg("Blank"))
	local ImageView_Prospect1 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect1"), "ImageView")
	ImageView_Prospect1:loadTexture(getUIImg("Blank"))
	local ImageView_Prospect2 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect2"), "ImageView")
	ImageView_Prospect2:loadTexture(getUIImg("Blank"))
end

function Game_ViewPlayer:openWnd(Msgdetail)
	if not Msgdetail then return end
	if not playerInfo then return end

    local detail  = Msgdetail[1]

	
	playerInfo.detail = {}
	playerInfo.detail.rank = detail.rank
	playerInfo.detail.team_info = {}
	playerInfo.detail.equips = {}
    playerInfo.detail.fates = detail.fates

    if Msgdetail[2] ~= nil and Msgdetail[2] == true then 
        self.bKuaFu =  true
    end

	self.tttt = {}
	
    playerInfo.detail.tbZhenFa =g_DataMgr:getCsvConfig_SecondKeyTableData("QiShuZhenfa", detail.cur_method_id)
	local initiative = 0
	local tbTeamInfoActiveState = {}
	for i,v in ipairs(detail.team_info) do
		local ti = {
			pos = v.pos, 
			data = v.info,
			battle_info = v.battle_info,
			active_state =	v.active_state,
			leader = i==1
		}
		table.insert(playerInfo.detail.team_info, ti)
		--保存了其他玩家的出战卡牌 
		g_Hero:setRestCardBatte(i,v.pos,v.info.configid)
	end

	initiative = detail.total_pre_attack

	for _,v in ipairs(detail.equips) do table.insert(playerInfo.detail.equips, v) end
	
	local Image_PlayerInfo = self.rootWidget:getChildByName("Image_PlayerInfo")
	local Label_Name = tolua.cast(Image_PlayerInfo:getChildByName("Label_Name"), "Label")
    Label_Name:setText(playerInfo.name)
    local LabelAtlas_Sex = tolua.cast(Image_PlayerInfo:getChildByName("LabelAtlas_Sex"), "LabelAtlas")
    LabelAtlas_Sex:setValue(playerInfo.sex == 1 and 1 or 2)
	g_AdjustWidgetsPosition({Label_Name, LabelAtlas_Sex}, 5)

	local Label_TeamStrengthLB = tolua.cast(Image_PlayerInfo:getChildByName("Label_TeamStrengthLB"), "Label")
	g_AdjustWidgetsPosition({LabelAtlas_Sex, Label_TeamStrengthLB}, 25)
	local BitmapLabel_TeamStrength = tolua.cast(Image_PlayerInfo:getChildByName("BitmapLabel_TeamStrength"), "LabelBMFont")
	-- BitmapLabel_TeamStrength:setText(playerInfo.fighting)
	BitmapLabel_TeamStrength:setText(detail.total_fight_point)
	
	g_AdjustWidgetsPosition({Label_TeamStrengthLB, BitmapLabel_TeamStrength}, 5)
	
	local Label_InitiativeLB = tolua.cast(Image_PlayerInfo:getChildByName("Label_InitiativeLB"), "Label")
	g_AdjustWidgetsPosition({BitmapLabel_TeamStrength, Label_InitiativeLB}, 25)
	local BitmapLabel_Initiative = tolua.cast(Image_PlayerInfo:getChildByName("BitmapLabel_Initiative"), "LabelBMFont")
	BitmapLabel_Initiative:setText(initiative)
	g_AdjustWidgetsPosition({Label_InitiativeLB, BitmapLabel_Initiative}, 5)
	
	local Label_RankLB = tolua.cast(Image_PlayerInfo:getChildByName("Label_RankLB"), "Label")
	g_AdjustWidgetsPosition({BitmapLabel_Initiative, Label_RankLB}, 25)
	local BitmapLabel_Rank = tolua.cast(Image_PlayerInfo:getChildByName("BitmapLabel_Rank"), "LabelBMFont")
	BitmapLabel_Rank:setText(playerInfo.detail.rank)
	g_AdjustWidgetsPosition({Label_RankLB, BitmapLabel_Rank}, 5)
	
	local nWidth1 = Label_Name:getSize().width
	local nWidth2 = LabelAtlas_Sex:getSize().width
	local nWidth3 = Label_TeamStrengthLB:getSize().width
	local nWidth4 = BitmapLabel_TeamStrength:getSize().width
	local nWidth5 = Label_InitiativeLB:getSize().width
	local nWidth6 = BitmapLabel_Initiative:getSize().width
	local nWidth7 = Label_RankLB:getSize().width
	local nWidth8 = BitmapLabel_Rank:getSize().width
	local nWidth = nWidth1+nWidth2+nWidth3+nWidth4+nWidth5+nWidth6+nWidth7+nWidth8
	
	Image_PlayerInfo:setSize(CCSizeMake(nWidth+40, 45))
	
	local Label_RoleID = tolua.cast(Image_PlayerInfo:getChildByName("Label_RoleID"),"Label")
	if playerInfo.uin <= nRobotCount then
		Label_RoleID:setText(string.format(_T("角色Id:%d"), g_ServerList:GetLocalServerID()*1000000 + playerInfo.uin))
	else
		Label_RoleID:setText(string.format(_T("角色Id:%d"), playerInfo.uin))
	end
	g_AdjustWidgetsPosition({BitmapLabel_Rank, Label_RoleID}, 50)
	
	self.BitmapLabel_FuncName:setText(playerInfo.is_friend and _T("删除好友") or _T("添加好友"))
	
	nAttOrder = 0
	for i,v in ipairs(self.Button_Pos) do
		setBuZhenData(v, i)
	end
    nAttOrder = nil
	
	if g_ArenaKuaFuData.getViewPlayerKuaFuFlag then 
		self.Button_AddOrDelFriend:setVisible(g_ArenaKuaFuData:getViewPlayerKuaFuFlag())
	end
	
end