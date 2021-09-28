--------------------------------------------------------------------------------------
-- 文件名:	Main.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-13 9:37
-- 版  本:	1.0
-- 描  述:	游戏主界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

--主窗口类，如果不继承CBaseWnd则需要自己实现
--initWnd，openWnd，closeWnd，showWnd四个函数
Game_MainUI = class("Game_MainUI")
Game_MainUI.__index = Game_MainUI

BuZhenScale = {
	[1] = 0.76,
	[2] = 0.83,
	[3] = 0.9,
	[4] = 0.76,
	[5] = 0.83,
	[6] = 0.9,
	[7] = 0.76,
	[8] = 0.83,
	[9] = 0.9,
	[10] = 0.76,
	[11] = 0.83,
	[12] = 0.9
}

--服务端坐标转客户端
tbServerToClientPosConvert =
{
	7,4,1,8,5,2,9,6,3,10,11,12
}

--客户端坐标转服务端
tbClientToServerPosConvert =
{
	3,6,9,2,5,8,1,4,7,10,11,12
}
--当前选择的出战成员的Index
local currentMemberIndex = 1
local nAttOrder = nil
local function setBuZhenData(Button_Pos, nIndex)
	if(Button_Pos and nIndex)then
		local Panel_Pos = Button_Pos:getChildByName("Panel_Pos")
		if(Panel_Pos)then
			Panel_Pos:removeFromParentAndCleanup(true)
		end

        if nIndex < 10 then
            local tbCheckPos = g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[nIndex])
			local imageNormal = getBuZhenImg("Btn_Pos"..nIndex)
			local imageClick = getBuZhenImg("Btn_Pos"..nIndex.."_Click")
			local imageDisabled = getBuZhenImg("Btn_Pos"..nIndex.."_Disabled")
            if tbCheckPos then
                Button_Pos:loadTextures(imageNormal,imageClick,imageDisabled)
            else
                Button_Pos:loadTextures(imageDisabled,imageClick,imageDisabled)
            end
        end

		local tbCardBattle = g_Hero:getBattleCardByBuZhenPos(tbClientToServerPosConvert[nIndex])
		if(tbCardBattle)then
			local CSV_CardBase = tbCardBattle:getCsvBase()
			if(CSV_CardBase)then
				local nStarLevel = CSV_CardBase.StarLevel
				nAttOrder = nAttOrder + 1
				Panel_Pos = Layout:create()
				Panel_Pos:setName("Panel_Pos")
				Panel_Pos:setScale(BuZhenScale[nIndex])

				local posHpX = CSV_CardBase.HPBarX or 0
				local posHpY = CSV_CardBase.HPBarY or 0
				local Label_Name = Label:create()
				Label_Name:setText(tbCardBattle:getNameWithSuffix())
				Label_Name:setPosition(ccp(posHpX,posHpY+25))
				
				if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
					Label_Name:setFontSize(19)
				else
					Label_Name:setFontSize(22)
				end
				
				g_SetCardNameColorByEvoluteLev(Label_Name, tbCardBattle:getEvoluteLevel())
				Panel_Pos:addChild(Label_Name, 2)

				local ImageView_StarLevel = ImageView:create()
				local image = getIconStarLev(nStarLevel)
				ImageView_StarLevel:loadTexture(image)
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

                LabelAtlas_AttOrder:setProperty(string.format("%d",nAttOrder), "Char/LabelAltas_AttackOrder.png", 52,27,"1")

                --新增需求
                if(g_Hero:getBuZhenPosByIndex(1) == tbClientToServerPosConvert[nIndex])then--队长要额外加一个新图片
                    local Image_Leader = ImageView:create()
                    Image_Leader:loadTexture(getUIImg("LeaderFlag"))
                    Label_Name:addChild(Image_Leader)
                    Image_Leader:setPosition(ccp(-tbSize.width/2-20, 0))
                end
				LabelAtlas_AttOrder:setScale(1)
				LabelAtlas_AttOrder:setAnchorPoint(ccp(0.0,0.5))
				LabelAtlas_AttOrder:setPosition(ccp(tbSize.width/2+10,0))
				Label_Name:addChild(LabelAtlas_AttOrder)

				--小伙伴图案
				local Image_Card = ImageView:create()
				local CCNode_Skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1, true)
                Image_Card:removeAllNodes()
				Image_Card:loadTexture(getUIImg("Blank"))
				Image_Card:setPosition(ccp(CSV_CardBase.Pos_X, CSV_CardBase.Pos_Y))
				Image_Card:setScale(0.6)
				Image_Card:setAnchorPoint(ccp(0.5,0))
				Image_Card:setName("Image_Card")
                Image_Card:addNode(CCNode_Skeleton, 0, 1)
				g_runSpineAnimation(CCNode_Skeleton, "idle", true)
				Panel_Pos:addChild(Image_Card, 1)
				
				local Image_Shadow = ImageView:create()
				Image_Shadow:loadTexture(getUIImg("Shadow"))
				Image_Shadow:setPosition(ccp(0,0))
				Image_Shadow:setName("Image_Shadow")
				Panel_Pos:addChild(Image_Shadow, 0)

				Button_Pos:addChild(Panel_Pos, 1)
                Button_Pos:setZOrder(1000000)
			end

            Button_Pos:setTouchEnabled(true)
        else
            Button_Pos:setTouchEnabled(false)
		end
		
		local ImageView_CheckLight = Button_Pos:getChildByName("ImageView_CheckLight")
		if ImageView_CheckLight then
			ImageView_CheckLight:removeFromParentAndCleanup(true)
		end
		ImageView_CheckLight = ImageView:create()
		ImageView_CheckLight:setVisible(false)
        if nIndex > 9 then
		    ImageView_CheckLight:loadTexture(getBuZhenImg("Btn_Pos"..(nIndex-9).."_Check"))
            ImageView_CheckLight:setScaleX(-1)
        else
            ImageView_CheckLight:loadTexture(getBuZhenImg("Btn_Pos"..nIndex.."_Check"))
        end
		ImageView_CheckLight:setPosition(ccp(0,0))
		ImageView_CheckLight:setName("ImageView_CheckLight")
		
		Button_Pos:addChild(ImageView_CheckLight, 0)
	end
	
	
	
end

local function initCardBattle(Panel_Member, nIndex, nOpenPos)
	if(not Panel_Member or not nIndex)then
		return
	end
	
	local Panel_Stencl = tolua.cast(Panel_Member:getChildByName("Panel_Stencl"),  "Layout")
	local Image_Icon = tolua.cast(Panel_Stencl:getChildByName("Image_Icon"), "ImageView")
	
	local CheckBox_Member = tolua.cast(Panel_Member:getChildByName("CheckBox_Member"), "CheckBox")
	local ImageView_Base = tolua.cast(Panel_Member:getChildByName("ImageView_Base"), "ImageView")
	local LabelBMFont_Level = tolua.cast(Panel_Member:getChildByName("LabelBMFont_Level"), "LabelBMFont")
	local Label_LockLevel = tolua.cast(Panel_Member:getChildByName("Label_LockLevel"), "Label")
	--等级不够开启该格子
	if(nIndex > nOpenPos)then
		CheckBox_Member:setBright(false)
		Image_Icon:setTouchEnabled(false)
		Image_Icon:setVisible(false)
		LabelBMFont_Level:setVisible(false)
		Label_LockLevel:setVisible(true)

		local CSV_PlayerTudiPosConfig = g_DataMgr:getCsvConfigByOneKey("PlayerTudiPosConfig", nIndex)
		Label_LockLevel:setText(_T("Lv.")..CSV_PlayerTudiPosConfig.OpenLevel)
        ImageView_Base:loadTexture(getUIImg("Image_IconBack9_Lock"))
        CheckBox_Member:loadTextureBackGround(getUIImg("Image_IconBack9_BaseDefault"))
		return
	end
	
	CheckBox_Member:setBright(true)
	ImageView_Base:setTouchEnabled(true)
	local tbCardBattle = g_Hero:getBattleCardByIndex(nIndex)
	if(not tbCardBattle)then
		Image_Icon:setVisible(false)
		LabelBMFont_Level:setVisible(false)
		Label_LockLevel:setVisible(false)
        ImageView_Base:loadTexture(getUIImg("Image_IconBack9_Base1"))
        CheckBox_Member:loadTextureBackGround(getUIImg("Image_IconBack9_BaseDefault"))
	else
		local CSV_CardBase = tbCardBattle:getCsvBase()
		Image_Icon:setVisible(true)
		Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))
		LabelBMFont_Level:setText(_T("Lv.")..tbCardBattle:getLevel())
        LabelBMFont_Level:setVisible(true)
		Label_LockLevel:setVisible(false)

        ImageView_Base:loadTexture(getUIImg(string.format("Image_IconBack9_Base%d",tbCardBattle:getStarLevel())))
        CheckBox_Member:loadTextureBackGround(getCardBuZhenFrameByEvoluteLev(tbCardBattle:getEvoluteLevel()))
	end
end

--布阵界面更换队伍
function Game_MainUI:updateBuZhen(tbMsg)
	--更新头像
	local nOpenPos = g_DataMgr:getPlayerTudiPosConfigCsvOpenLevel()
	nAttOrder = 0
	--更新动画
	local Image_Buzhen = self.rootWidget:getChildByName("Image_Buzhen")
	for i=1,12 do
    	local Button_Pos = tolua.cast(Image_Buzhen:getChildByName("Button_Pos"..i), "Button")
		setBuZhenData(Button_Pos, i)
    end
	nAttOrder = nil
	self.nOpenPos = nOpenPos
	mainWnd:refreshHomeStatusBar()

    local Panel_CardOp = self.rootWidget:getChildByName("Panel_CardOp")
    Panel_CardOp:setVisible(false)
    for nIndex= 1, 6 do
        local Panel_Member = self.rootWidget:getChildByName("Panel_Member"..nIndex)
	    initCardBattle(Panel_Member, nIndex, self.nOpenPos)
    end
	
	if tbMsg.change_op == zone_pb.ChangeArrayType_Inquire then	--伙伴已经在阵上
		if g_WndMgr:isVisible("Game_CardSelect") then
			g_WndMgr:closeWnd("Game_CardSelect")
		end
		currentMemberIndex = tbMsg.array_card_list[1].index + 1
	    --当前选择的出战成员的
	    self:setHighBright(currentMemberIndex, true)
	elseif tbMsg.change_op == zone_pb.ChangeArrayType_Add then
        if g_WndMgr:isVisible("Game_CardSelect") then
			g_WndMgr:closeWnd("Game_CardSelect")
		end
	    currentMemberIndex = tbMsg.array_card_list[1].index + 1
	    --当前选择的出战成员的
	    self:setHighBright(currentMemberIndex, true)
    elseif tbMsg.change_op == zone_pb.ChangeArrayType_Move then
        moveBuZhenCard()
        self:setHighBright(currentMemberIndex, true)
    elseif tbMsg.change_op == zone_pb.ChangeArrayType_Del then
        local nIndex = tbMsg.array_card_list[1].index + 1
        if g_Hero:getBattleCardByIndex(nIndex) and nIndex == currentMemberIndex then
             self:setHighBright(currentMemberIndex, true)
        end
    elseif tbMsg.change_op == zone_pb.ChangeArrayType_SetLeader then
        self:setHighBright(currentMemberIndex, true)
	    currentMemberIndex = 1
	    --当前选择的出战成员的
	    self:setHighBright(1, true)
    end

    self:setMainTop()
    g_Hero:showTeamStrengthGrowAnimation()
end

function Game_MainUI:setMainTop()
	local Image_PlayerInfo = self.rootWidget:getChildByName("Image_PlayerInfo")

    local Label_Name = tolua.cast(Image_PlayerInfo:getChildByName("Label_Name"), "Label")
    Label_Name:setText(g_Hero:getMasterNameSuffix(Label_Name))
	
    local LabelAtlas_Sex = tolua.cast(Image_PlayerInfo:getChildByName("LabelAtlas_Sex"), "LabelAtlas")
    LabelAtlas_Sex:setValue(g_Hero:getMasterSex())
	
	g_AdjustWidgetsPosition({Label_Name, LabelAtlas_Sex}, 5)

	local Label_TeamStrengthLB = tolua.cast(Image_PlayerInfo:getChildByName("Label_TeamStrengthLB"), "Label")
	g_AdjustWidgetsPosition({LabelAtlas_Sex, Label_TeamStrengthLB}, 25)
	
	local BitmapLabel_TeamStrength = tolua.cast(Image_PlayerInfo:getChildByName("BitmapLabel_TeamStrength"), "LabelBMFont")
	BitmapLabel_TeamStrength:setText(g_Hero:getTeamStrength())
	
	g_AdjustWidgetsPosition({Label_TeamStrengthLB, BitmapLabel_TeamStrength}, 5)
	
	local Label_InitiativeLB = tolua.cast(Image_PlayerInfo:getChildByName("Label_InitiativeLB"), "Label")
	g_AdjustWidgetsPosition({BitmapLabel_TeamStrength, Label_InitiativeLB}, 25)
	
	local BitmapLabel_Initiative = tolua.cast(Image_PlayerInfo:getChildByName("BitmapLabel_Initiative"), "LabelBMFont")
	BitmapLabel_Initiative:setText(g_Hero:getTeamAttackPower())
	
	g_AdjustWidgetsPosition({Label_InitiativeLB, BitmapLabel_Initiative}, 5)
	
	local Label_RankLB = tolua.cast(Image_PlayerInfo:getChildByName("Label_RankLB"), "Label")
	g_AdjustWidgetsPosition({BitmapLabel_Initiative, Label_RankLB}, 25)
	
	local BitmapLabel_Rank = tolua.cast(Image_PlayerInfo:getChildByName("BitmapLabel_Rank"), "LabelBMFont")
	BitmapLabel_Rank:setText(tostring(g_Hero:getRank()))
	
	g_AdjustWidgetsPosition({Label_RankLB, BitmapLabel_Rank}, 5)
	
	local nWidth1 = Label_Name:getSize().width
	local nWidth2 = LabelAtlas_Sex:getSize().width
	local nWidth3 = Label_TeamStrengthLB:getSize().width
	local nWidth4 = BitmapLabel_TeamStrength:getSize().width
	local nWidth5 = Label_InitiativeLB:getSize().width
	local nWidth6 = BitmapLabel_Initiative:getSize().width
	local nWidth7 = Label_RankLB:getSize().width
	local nWidth8 = BitmapLabel_Rank:getSize().width
	
	Image_PlayerInfo:setSize(CCSizeMake(nWidth1+nWidth2+nWidth3+nWidth4+nWidth5+nWidth6+nWidth7+nWidth8+40, 45))
	
	local Label_RoleID = tolua.cast(Image_PlayerInfo:getChildByName("Label_RoleID"),"Label")
	Label_RoleID:setText(string.format(_T("角色Id:%d"), g_MsgMgr:getZoneUin()))
	g_AdjustWidgetsPosition({BitmapLabel_Rank, Label_RoleID}, 50)
	
	local function onCloseTip1(pSender, nTag)
		g_ClientMsgTips:closeTip()
	end
	
	g_SetBtnWithPressingEvent(Label_TeamStrengthLB, nil, g_OnShowTip, nil, onCloseTip1, true, 0.0)
	g_SetBtnWithPressingEvent(BitmapLabel_TeamStrength, nil, g_OnShowTip, nil, onCloseTip1, true, 0.0)
	
	g_SetBtnWithPressingEvent(Label_InitiativeLB, nil, g_OnShowTip, nil, onCloseTip1, true, 0.0)
	g_SetBtnWithPressingEvent(BitmapLabel_Initiative, nil, g_OnShowTip, nil, onCloseTip1, true, 0.0)
	
	g_SetBtnWithPressingEvent(Label_RankLB, nil, g_OnShowTip, nil, onCloseTip1, true, 0.0)
	g_SetBtnWithPressingEvent(BitmapLabel_Rank, nil, g_OnShowTip, nil, onCloseTip1, true, 0.0)
	
	--当前阵容 和选择阵容
	local Image_ZhenFaInfoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenFaInfoPNL"), "ImageView")
	local Button_ChangeZhenFa = tolua.cast(Image_ZhenFaInfoPNL:getChildByName("Button_ChangeZhenFa"), "Button")
	
	Button_ChangeZhenFa:setTouchEnabled(true)
    Button_ChangeZhenFa:addTouchEventListener(handler(self, self.openZhenXing))
	
	local curZhenFaId = g_Hero:getCurrentZhenFaCsvID()
	local tabZhenFaLev = g_Hero:getZhenFaLevel(curZhenFaId) --阵法等级

	local data = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhenfa",curZhenFaId, 1)
	
	--正常状态
	Button_ChangeZhenFa:loadTextureNormal(getIconImg(data.ZhenFaIcon))
	--点击下状态
	Button_ChangeZhenFa:loadTexturePressed(getIconImg(data.ZhenFaIcon))
	--禁用状态
	Button_ChangeZhenFa:loadTextureDisabled(getIconImg(data.ZhenFaIcon))
	
	--阵容名称
	local Label_ZhenFaName = tolua.cast(Image_ZhenFaInfoPNL:getChildByName("Label_ZhenFaName"), "Label")
	Label_ZhenFaName:setText(data.ZhenFaName)
	--阵容等级
	local Label_ZhenFaLevel = tolua.cast(Label_ZhenFaName:getChildByName("Label_ZhenFaLevel"), "Label")
	Label_ZhenFaLevel:setText(_T("Lv.")..tabZhenFaLev)
	
	Label_ZhenFaLevel:setPositionX(Label_ZhenFaName:getSize().width)
	
	local Label_ZhenFaProp = tolua.cast(Image_ZhenFaInfoPNL:getChildByName("Label_ZhenFaProp"), "Label")
	Label_ZhenFaProp:setText(g_Hero:getZhenFaPropString(curZhenFaId))
	
end

function Game_MainUI:openZhenXing()
    g_WndMgr:showWnd("Game_ZhenFaSelect")
end

function Game_MainUI:setHighBright(nIndex, bVisible)
	if not nIndex then return end
	local nPos = g_Hero:getBuZhenPosByIndex(nIndex)
	if(nPos)then
		local nStandIndex = tbServerToClientPosConvert[nPos]
		if nStandIndex then
			local Image_Buzhen = self.rootWidget:getChildByName("Image_Buzhen")
			local Button_Pos = tolua.cast(Image_Buzhen:getChildByName("Button_Pos"..nStandIndex), "Button")
			local ImageView_CheckLight = tolua.cast(Button_Pos:getChildByName("ImageView_CheckLight"), "ImageView")
			ImageView_CheckLight:setVisible(bVisible)
		end
		
		if bVisible then
		   self:setCheckBox(nIndex)
		end
	end
end

local function setWidgetStatus(widget, bVisible)
    widget:setTouchEnabled(bVisible)
    widget:setBright(bVisible)
end

function Game_MainUI:initCardOperation()
    local Panel_Stencl = tolua.cast(g_WidgetModel.Panel_Member:getChildByName("Panel_Stencl"),  "Layout")
	Panel_Stencl:setClippingEnabled(true)
	Panel_Stencl:setRadius(56)

    local Panel_CardOp = self.rootWidget:getChildByName("Panel_CardOp")
    local ImageView_FunctionList = Panel_CardOp:getChildByName("ImageView_FunctionList")
	local Image_FunctionArrow = Panel_CardOp:getChildByName("Image_FunctionArrow")
	
	local function onClickLevelUp(pSender, eventType)
	    if(eventType == ccs.TouchEventType.ended )then
			local tbCardBattle = g_Hero:getBattleCardByIndex(currentMemberIndex)
			if(not tbCardBattle)then return end
			g_WndMgr:openWnd("Game_Equip1", {nCardID = tbCardBattle:getServerId()})
        end
    end

    local Button_MemberFunction1 = ImageView_FunctionList:getChildByName("Button_MemberFunction1")
    Button_MemberFunction1:setTouchEnabled(true)
    Button_MemberFunction1:addTouchEventListener(onClickLevelUp)

    local function onClickChange(pSender, nTag)
		
		g_WndMgr:showWnd("Game_CardSelect", currentMemberIndex)
    end
    local Button_MemberFunction2 = ImageView_FunctionList:getChildByName("Button_MemberFunction2")
	g_SetBtnWithGuideCheck(Button_MemberFunction2, 3, onClickChange, true, nil, nil, nil)
	
	local function onClickBattleDown(pSender, eventType)
	    if(eventType == ccs.TouchEventType.ended )then
            g_MsgMgr:requestDeleteCard(currentMemberIndex-1)
        end
    end
    local Button_MemberFunction3 = ImageView_FunctionList:getChildByName("Button_MemberFunction3")
    Button_MemberFunction3:setTouchEnabled(true)
    Button_MemberFunction3:addTouchEventListener(onClickBattleDown)

    local function showWidget(nIndex)
        if nIndex == 1 then
			setWidgetStatus(Button_MemberFunction1, true)
            setWidgetStatus(Button_MemberFunction2, false)
			setWidgetStatus(Button_MemberFunction3, false)
        else
            if nIndex <= self.nOpenPos then
                if g_Hero:getBattleCardByIndex(nIndex) then
					setWidgetStatus(Button_MemberFunction1, true)
					setWidgetStatus(Button_MemberFunction2, true)
                    setWidgetStatus(Button_MemberFunction3, true)
                else
					
                    g_WndMgr:showWnd("Game_CardSelect", nIndex)
                end
            end
        end

        --self:setCheckBox(nIndex)
    end

    local function onClickSelectMember(pSender, nIndex)
		if(nIndex > self.nOpenPos)then return end 
		local nPosX = (710 + (nIndex-1)*100)
		if nIndex <= 4 then
			ImageView_FunctionList:setPositionX(nPosX)
		elseif nIndex == 5 then
			ImageView_FunctionList:setPositionX(nPosX-110)
		elseif nIndex == 6 then
			ImageView_FunctionList:setPositionX(nPosX-135)
		end
		Image_FunctionArrow:setPositionX(nPosX)
		
		
		if (not g_Hero:getBattleCardByIndex(nIndex)) then
			
			self:setCheckBox(nIndex)
			Panel_CardOp:setVisible(false)
			g_WndMgr:showWnd("Game_CardSelect", nIndex)
		
		else
			Panel_CardOp:setVisible(true)
			showWidget(nIndex)
			self:setHighBright(currentMemberIndex, false)
			currentMemberIndex = nIndex
			--当前选择的出战成员的
			self:setHighBright(nIndex, true)

			self:setCheckBox(nIndex)
		end
    end
	--出战伙伴
    for nIndex=1, 6 do
		local Panel_Member = self.rootWidget:getChildByName("Panel_Member"..nIndex)
		if not Panel_Member then
			Panel_Member = g_WidgetModel.Panel_Member:clone()
			self.rootWidget:addChild(Panel_Member, 7)
		end
		local Button_SelectMember = tolua.cast(Panel_Member:getChildByName("Button_SelectMember"), "Button")
        Panel_Member:setPositionXY(660 + 100*(nIndex-1), 15)
	    initCardBattle(Panel_Member, nIndex, self.nOpenPos)
        Panel_Member:setName("Panel_Member"..nIndex)
		g_SetBtnWithGuideCheck(Button_SelectMember, nIndex, onClickSelectMember, true, nil, nil, true)
    end

    local function onClickCardOp(pSender, eventType)
	    if(eventType == ccs.TouchEventType.ended )then
           pSender:setVisible(false)
	    end
    end
    Panel_CardOp:setTouchEnabled(true)
    Panel_CardOp:addTouchEventListener(onClickCardOp)
    Panel_CardOp:setVisible(false)
end

function Game_MainUI:setCheckBox(nIndex)
	for i = 1, 6 do
		local Panel_Member = self.rootWidget:getChildByName("Panel_Member"..i)
		local CheckBox_Member = tolua.cast(Panel_Member:getChildByName("CheckBox_Member"), "CheckBox")
		CheckBox_Member:setSelectedState(false)
	end
	local Panel_Member = self.rootWidget:getChildByName("Panel_Member"..nIndex)
	local CheckBox_Member = tolua.cast(Panel_Member:getChildByName("CheckBox_Member"), "CheckBox")
	CheckBox_Member:setSelectedState(true)
end

--初始化主界面的左上角顶层界面
function Game_MainUI:initMainBottom()
	local nOpenPos = g_DataMgr:getPlayerTudiPosConfigCsvOpenLevel()
	self.nOpenPos = nOpenPos
	self:initCardOperation()

	--初始化主界面的布阵情况
	local Image_Buzhen = self.rootWidget:getChildByName("Image_Buzhen")
	local HitWidget = nil
	local Panel_Pos = nil
	local nBegin = nil
	local BeginWidget = nil

	function moveBuZhenCard()
        if Panel_Pos then
            Panel_Pos:removeFromParent()
        end

		nBegin = nil
		HitWidget = nil
		Panel_Pos = nil
	end

	local function resetBuZhen()
		if(not HitWidget or not Panel_Pos)then
			return
		end

		HitWidget:setBrightStyle(BRIGHT_NORMAL)
		Panel_Pos:retain()
		Panel_Pos:removeFromParent()
		BeginWidget:addChild(Panel_Pos)
		--移动小伙伴放开的时候
		local Image_Card = tolua.cast(Panel_Pos:getChildByName("Image_Card"), "ImageView")
		Image_Card:setScale(0.6)
		Panel_Pos:setPosition(ccp(0,0))
		Panel_Pos:release()

		local CCNode_Skeleton = Image_Card:getNodeByTag(1)
        if CCNode_Skeleton then
            CCNode_Skeleton = tolua.cast(CCNode_Skeleton, "SkeletonAnimation")
            CCNode_Skeleton:activeUpdate()
        end

		nBegin = nil
		HitWidget = nil
		BeginWidget = nil
        Panel_Pos = nil
	end

	local posY_CheckLight = nil
	local nGuiBegin = 2
	local nGuidEnd = 5
	local function onPressed_Button_Pos(pSender, eventType)

		if eventType == ccs.TouchEventType.ended then
			local nIndex = pSender:getTag()
			if(not Panel_Pos)then
				return
			end

			if(HitWidget)then
				HitWidget:setBrightStyle(BRIGHT_NORMAL)
				local ImageView_CheckLight = tolua.cast(HitWidget:getChildByName("ImageView_CheckLight"), "ImageView")
				ImageView_CheckLight:setPositionY(posY_CheckLight)
                if HitWidget:getTag() > 9 then
				    ImageView_CheckLight:setScale(1.0)
                    ImageView_CheckLight:setScaleX(-1.0)
                else
                    ImageView_CheckLight:setScale(1.0)
                end

				local nEnd = HitWidget:getTag()
				local nBattleIndex = g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[nBegin])
				if(nBegin ~= nEnd )then
					g_MsgMgr:requestChangeCard(g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[nBegin]), g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[nEnd]))
				else
					resetBuZhen()
				end
			end
		elseif(eventType == ccs.TouchEventType.began)then
			HitWidget = pSender
			nBegin = pSender:getTag()
			BeginWidget = pSender
			if(Panel_Pos ~= pSender)then
				Panel_Pos = pSender:getChildByName("Panel_Pos")
				local ImageView_CheckLight = tolua.cast(HitWidget:getChildByName("ImageView_CheckLight"), "ImageView")
				posY_CheckLight = ImageView_CheckLight:getPositionY()
				ImageView_CheckLight:setPositionY(posY_CheckLight+5)

                if HitWidget:getTag() > 9 then
                    ImageView_CheckLight:setScale(1.05)
                    ImageView_CheckLight:setScaleX(-1.05)
                else
                    ImageView_CheckLight:setScale(1.05)
                end
				--移动小伙伴的时候
				if(Panel_Pos)then
					Panel_Pos:retain()
					Panel_Pos:removeFromParent()
					g_WndMgr:addChild(Panel_Pos)
					local Image_Card = tolua.cast(Panel_Pos:getChildByName("Image_Card"), "ImageView")
					Image_Card:setScale(0.6)

					local nPos = pSender:getTouchStartPos()
					Panel_Pos:setPosition(ccp(nPos.x, nPos.y))
					Panel_Pos:release()
				end
			end
		elseif(eventType == ccs.TouchEventType.moved)then
			local nPos = pSender:getTouchMovePos()
			if(Panel_Pos)then
				Panel_Pos:setPosition(ccp(nPos.x, nPos.y))
			end

			if not HitWidget then
                return
            end

			local children = Image_Buzhen:getChildren()
			if(children ~= nil)then
				for i = 0, children:count() -1 do
					local object = children:objectAtIndex(i)
					local widget = tolua.cast(object, "Widget")

					if(widget ~= nil and widget:hitTest(nPos)) then
                        local tbCheckPos = g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[widget:getTag()])
                        if not tbCheckPos then  return  end

						if(widget ~= HitWidget)then
							local ImageView_CheckLight = tolua.cast(HitWidget:getChildByName("ImageView_CheckLight"), "ImageView")
							ImageView_CheckLight:setPositionY(posY_CheckLight)
                            if HitWidget:getTag() > 9 then
                                ImageView_CheckLight:setScale(1.0)
                                ImageView_CheckLight:setScaleX(-1.0)
                            else
                                ImageView_CheckLight:setScale(1.0)
                            end
							if(HitWidget)then
								HitWidget:setBrightStyle(BRIGHT_NORMAL)
							end
							HitWidget = widget
							HitWidget:setBrightStyle(BRIGHT_HIGHLIGHT)
						else
							if widget == BeginWidget then
								local ImageView_CheckLight = tolua.cast(HitWidget:getChildByName("ImageView_CheckLight"), "ImageView")
								ImageView_CheckLight:setPositionY(posY_CheckLight+5)
								 if HitWidget:getTag() > 9 then
                                    ImageView_CheckLight:setScale(1.05)
                                    ImageView_CheckLight:setScaleX(-1.05)
                                else
                                    ImageView_CheckLight:setScale(1.05)
                                end
							end
						end
						break
					end
				end
			end
		else
			if(HitWidget)then
				HitWidget:setBrightStyle(BRIGHT_NORMAL)
			end
			if(HitWidget and Panel_Pos)then
				local nEnd = HitWidget:getTag()

				if(nBegin and nBegin ~= nEnd  )then
                    --说明放置无效位置
                    local tbCheckPos = g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[nEnd])
                    if not tbCheckPos then
                        resetBuZhen()
                        return
                    end

                    local nBattleIndex = g_Hero:getBuZhenPosByIndex(1)--队长的位置
					if(nBattleIndex == tbClientToServerPosConvert[nBegin] and nEnd > 9)then--说明队长要放到替补位置上面
						g_ClientMsgTips:showMsgConfirm(_T("队长不能成为替补！"))
						resetBuZhen()
					else
                        if(nBegin > 9 and nEnd < 10 )then --说明替补要去替换队长位置
						    local nIndex = tbClientToServerPosConvert[nEnd]
                            if(nIndex == nBattleIndex)then
                                g_ClientMsgTips:showMsgConfirm(_T("队长不能成为替补！"))
						        resetBuZhen()
                                return
                            end
                         end

						g_MsgMgr:requestChangeCard(g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[nBegin]), g_Hero:getCurZhenFaIndex(tbClientToServerPosConvert[nEnd]))
					end
				else
					resetBuZhen()
				end
			end
		end
	end

	nAttOrder = 0
	for i=1,12 do
    	local Button_Pos = tolua.cast(Image_Buzhen:getChildByName("Button_Pos"..i), "Button")
		Button_Pos:setTouchEnabled(true)
	    Button_Pos:addTouchEventListener(onPressed_Button_Pos)
		Button_Pos:setTag(i)
		setBuZhenData(Button_Pos, i)
    end
	nAttOrder = nil

	
    --上一个
	self:setHighBright(1, true)
	currentMemberIndex = 1
end

--加载UI控件和初始化
function Game_MainUI:initWnd(widget)
	--初始化主界面的左上角顶层界面
	local function initBackgroundAnimation()
		local wndInstantce = g_WndMgr:getWnd("Game_MainUI")
		if wndInstantce then
			local ImageView_Background = tolua.cast(wndInstantce.rootWidget:getChildByName("ImageView_Background"), "ImageView")
			g_InitBuZhenBackgroundAnimation(ImageView_Background)
		end
	end
	self.nTimerID_Game_MainUI_8 = g_Timer:pushTimer(0.05, initBackgroundAnimation)
	self:CreateLeaf()
	self:initMainBottom()
	
	local Image_YuanFenTip = tolua.cast(self.rootWidget:getChildByName("Image_YuanFenTip"), "ImageView")
	g_CreateScaleInOutAction(Image_YuanFenTip)
	local function onClick_Image_YuanFenTip(pSender, nTag)
		g_WndMgr:showWnd("Game_ZhenRong")
	end
	g_SetBtnWithEvent(Image_YuanFenTip, 0, onClick_Image_YuanFenTip, true)
	
	local ImageView_Background = tolua.cast(self.rootWidget:getChildByName("ImageView_Background"), "ImageView")
	ImageView_Background:loadTexture(getBackgroundPngImg("Buzhen_Main"))
	local ImageView_Prospect1 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect1"), "ImageView")
	ImageView_Prospect1:loadTexture(getBackgroundJpgImg("Buzhen_Prospect1"))
	local ImageView_Prospect2 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect2"), "ImageView")
	ImageView_Prospect2:loadTexture(getBackgroundJpgImg("Buzhen_Prospect2"))
end

function Game_MainUI:closeWnd()
	g_Timer:destroyTimerByID(self.nTimerID_Game_MainUI_1)
	g_Timer:destroyTimerByID(self.nTimerID_Game_MainUI_2)
	g_Timer:destroyTimerByID(self.nTimerID_Game_MainUI_3)
	g_Timer:destroyTimerByID(self.nTimerID_Game_MainUI_4)
	g_Timer:destroyTimerByID(self.nTimerID_Game_MainUI_5)
	g_Timer:destroyTimerByID(self.nTimerID_Game_MainUI_6)
	g_Timer:destroyTimerByID(self.nTimerID_Game_MainUI_7)
	g_Timer:destroyTimerByID(self.nTimerID_Game_MainUI_8)
	self.nTimerID_Game_MainUI_1 = nil
	self.nTimerID_Game_MainUI_2 = nil
	self.nTimerID_Game_MainUI_3 = nil
	self.nTimerID_Game_MainUI_4 = nil
	self.nTimerID_Game_MainUI_5 = nil
	self.nTimerID_Game_MainUI_6 = nil
	self.nTimerID_Game_MainUI_7 = nil
	self.nTimerID_Game_MainUI_8 = nil
	
	local ImageView_Background = tolua.cast(self.rootWidget:getChildByName("ImageView_Background"), "ImageView")
	ImageView_Background:loadTexture(getUIImg("Blank"))
	local ImageView_Prospect1 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect1"), "ImageView")
	ImageView_Prospect1:loadTexture(getUIImg("Blank"))
	local ImageView_Prospect2 = tolua.cast(ImageView_Background:getChildByName("ImageView_Prospect2"), "ImageView")
	ImageView_Prospect2:loadTexture(getUIImg("Blank"))
end

function Game_MainUI:destroyWnd()

end

function Game_MainUI:CreateLeaf()
	--父节点，起始位置，结束位置，播放次数,间隔时间 ,移动的时间，旋转时间，旋转角度1，反转角度2, 叶子图片类型（1-4)
	self.nTimerID_Game_MainUI_1 = g_CreateLeaf(self.rootWidget,ccp(500,1000),ccp(2000,0),-1,20)
	self.nTimerID_Game_MainUI_2 = g_CreateLeaf(self.rootWidget,ccp(2200,1000),ccp(100,-100),-1,30,25,5,-10,10,4,1)
	self.nTimerID_Game_MainUI_3 = g_CreateLeaf(self.rootWidget,ccp(0,500),ccp(1500,100),-1,40,35,5,-80,80,3,1)
	self.nTimerID_Game_MainUI_4 = g_CreateLeaf(self.rootWidget,ccp(1500,1000),ccp(100,300),-1,50,45,5,-50,50,2,1)
	self.nTimerID_Game_MainUI_5 = g_CreateLeaf(self.rootWidget,ccp(10000,800),ccp(500,400),-1,40,35,5,-100,100,4,1)
	self.nTimerID_Game_MainUI_6 = g_CreateLeaf(self.rootWidget,ccp(2500,1000),ccp(100,300),-1,55,45,5,-50,50,2,1)
	self.nTimerID_Game_MainUI_7 = g_CreateLeaf(self.rootWidget,ccp(2000,1000),ccp(500,400),-1,45,30,5,-100,100,1,1)
end

function Game_MainUI:openWnd()
	g_Hero:SetCardFlagPV(2)
    self:setMainTop()
    local Panel_CardOp = self.rootWidget:getChildByName("Panel_CardOp")
    Panel_CardOp:setVisible(false)
    local nOpenPos = g_DataMgr:getPlayerTudiPosConfigCsvOpenLevel()
	self.nOpenPos = nOpenPos
    
	for nIndex= 1, 6 do
        local Panel_Member = self.rootWidget:getChildByName("Panel_Member"..nIndex)
	    initCardBattle(Panel_Member, nIndex, self.nOpenPos)
    end

	nAttOrder = 0
	--更新动画
	local Image_Buzhen = self.rootWidget:getChildByName("Image_Buzhen")
	for i=1,12 do
		local Button_Pos = tolua.cast(Image_Buzhen:getChildByName("Button_Pos"..i), "Button")
		setBuZhenData(Button_Pos, i)
	end
	nAttOrder = nil
	
	--在进入选择阵法的时候在默认选择的伙伴脚下显示绿色底框
	self:setHighBright(currentMemberIndex, true)
end

function Game_MainUI:releaseWnd()
	
end