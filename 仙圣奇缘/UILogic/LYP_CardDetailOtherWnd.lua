--------------------------------------------------------------------------------------
-- 文件名:	LYP_CardDetailWnd.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2014-11-17 15:15
-- 版  本:	1.0
-- 描  述:	伙伴详细他人界面
-- 应  用:  
---------------------------------------------------------------------------------------

local EnumCardGroupActiveType = {
	ENUM_CARD_GROUP_NOT_BIND = 0,
	ENUM_CARD_GROUP_NOT_ACTIVE = 1,
	ENUM_CARD_GROUP_ACTIVE = 2,
}

Game_CardDetailViewOther1 = class("Game_CardDetailViewOther1")
Game_CardDetailViewOther1.__index = Game_CardDetailViewOther1

function Game_CardDetailViewOther1:onClick_Image_Equip(pSender, eventType)
	if eventType == ccs.TouchEventType.ended then		
		local nEquipServerID = pSender:getTag()
		if nEquipServerID > 0 then --有装备
			local GameObj_Equip =  self.tbEquip[nEquipServerID]
			-- g_Hero:getEquipObjByServID(nEquipServerID)
			
			g_WndMgr:showWnd("Game_TipEquipView", GameObj_Equip)
		end
	end
end

function Game_CardDetailViewOther1:showEquipIcons(nIndex, tbCard, CSV_CardBase)
	local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
	local Image_Equip = Image_CardInfoPNL:getChildByName("Image_Equip"..nIndex)
    local Image_DefaultEquip = tolua.cast(Image_Equip:getChildByName("Image_DefaultEquip"), "ImageView")
	local Image_Add = tolua.cast(Image_DefaultEquip:getChildByName("Image_Add"), "ImageView")
	local ImageEuipeIcon = tolua.cast(Image_Equip:getChildByName("ImageEuipeIcon"), "ImageView")
	
    local nEquipServerID = tbCard:getEquipIDByPos(nIndex)
    if nEquipServerID > 0 then --有装备
		local tbEquip = self.tbEquip[nEquipServerID]
        local tbEquipBase = tbEquip:getCsvBase()
        Image_DefaultEquip:setVisible(false)

        local ImageEuipeIcon  =  tolua.cast(ImageEuipeIcon, "ImageView")
        ImageEuipeIcon:setVisible(true)

        local Image_Icon = tolua.cast(ImageEuipeIcon:getChildByName("Image_Icon"), "ImageView")
        Image_Icon:loadTexture(getIconImg(tbEquipBase.Icon))
		
		local Image_RefineLevel = tolua.cast(ImageEuipeIcon:getChildByName("Image_RefineLevel"),"ImageView")
		local rLevel = tbEquip:getRefineLev()
		if rLevel > 0 then 
			Image_RefineLevel:loadTexture(getUIImg("Icon_StarLevel"..rLevel))
			Image_RefineLevel:setVisible(true)
		else
			Image_RefineLevel:setVisible(false)
		end
		
		local BitmapLabel_StrengthenLevel = tolua.cast(ImageEuipeIcon:getChildByName("BitmapLabel_StrengthenLevel"), "LabelBMFont")
		BitmapLabel_StrengthenLevel:setFntFile(getEquipLevFont(tbEquipBase.ColorType))
		BitmapLabel_StrengthenLevel:setText(_T("Lv.")..tbEquip:getStrengthenLev())
		local imageName = nil
        if nIndex <= 2 then
			imageName = "FrameEquipBig"
        else
            imageName = "FrameEquipCircle"
        end
		ImageEuipeIcon:loadTexture(getUIImg(imageName..tbEquipBase.ColorType))

		local Image_Equip = tolua.cast(ImageEuipeIcon:getParent(), "ImageView")
        Image_Equip:setTag(nEquipServerID)
		Image_Equip:setTouchEnabled(true)
		Image_Equip:addTouchEventListener(handler(self, self.onClick_Image_Equip))
    else--无装备
        if nIndex == 1 then
			Image_DefaultEquip:loadTexture(getCardImg("Frame_Equip_DefaultEquip"..CSV_CardBase.Profession))
		end
		Image_DefaultEquip:setOpacity(50)
        Image_DefaultEquip:setVisible(true)
        ImageEuipeIcon:setVisible(false)
    end               
end

function Game_CardDetailViewOther1:registerPageViewEquipEvent()
    local function turningFunction(Panel_CardPage_Equip, nIndex)
		if not self.tbCardList then return end
        local tbCard = self.tbCardList[nIndex]
        local battleInfo = self.battleInfo[nIndex]
		local activeState = self.activeState[nIndex]
        if tbCard then         
            local CSV_CardBase = tbCard:getCsvBase()
            self.nCardID = tbCard:getServerId()
		
            self.Label_Name:setText(tbCard:getNameWithSuffix(self.Label_Name, self.leaderName))
            -- self.BitmapLabel_PersonalStrength:setText(tostring(tbCard:getCardStrength()))
            self.BitmapLabel_PersonalStrength:setText(tostring(battleInfo.fight_point))
			local starLv = 1
			for i = 1,CSV_CardBase.StarLevel - 1 do 
				starLv = starLv.."1"
			end
			
			self.AtlasLabel_StarLevel:setValue(starLv)
            --设置装备Icon
            for i=1, 6 do
                self:showEquipIcons(i, tbCard, CSV_CardBase)      
            end

            self:processCardDetail(tbCard, battleInfo, activeState)
            self.nCardIndex = nIndex
        end
    end

    local function updateFunction(Panel_CardPage_Equip, nIndex)
		if not self.tbCardList then return end
		Panel_CardPage_Equip:setVisible(true)
        local tbCard = self.tbCardList[nIndex]
        if tbCard then           
            local CSV_CardBase = tbCard:getCsvBase()
			local Panel_Card = tolua.cast(Panel_CardPage_Equip:getChildByName("Panel_Card"), "Layout")
			local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView")
            local CCNode_Skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1)
			Image_Card:removeAllNodes()
			Image_Card:loadTexture(getUIImg("Blank"))
			Image_Card:setPositionXY(CSV_CardBase.Pos_X*Panel_Card:getScale()/0.6, CSV_CardBase.Pos_Y*Panel_Card:getScale()/0.6)
            Image_Card:addNode(CCNode_Skeleton)
            g_runSpineAnimation(CCNode_Skeleton, "idle", true)
        end
    end

    self.LuaPageView_Card_Equip:registerClickEvent(turningFunction)
    self.LuaPageView_Card_Equip:registerUpdateFunction(updateFunction)
end

function Game_CardDetailViewOther1:registerPageViewFateEvent()
    local function turningFunction(Panel_CardPage_Fate, nIndex)
        local tbCard = self.tbCardList[nIndex]
		local battleInfo = self.battleInfo[nIndex]
		local activeState = self.activeState[nIndex]
        if tbCard then       
            self.nCardIndex = nIndex  
            local CSV_CardBase = tbCard:getCsvBase()
            self.nCardID = tbCard:getServerId()
			
            self.Label_Name:setText(tbCard:getNameWithSuffix(self.Label_Name))

            self.BitmapLabel_PersonalStrength:setText(tostring(battleInfo.fight_point))
            self:processCardDetail(tbCard, battleInfo, activeState)

            --设置异兽
            local Image_FatePNL = self.rootWidget:getChildByName("Image_FatePNL") 
            local tbFateIdList = tbCard:getFateIdList()
            local nFateExp = 0
            for nIndex = 1, 8 do
                local nFateID = tbFateIdList[nIndex]
                local tbFate = self.tbFate[nFateID]
				
				local Image_FateContentPNL = Image_FatePNL:getChildByName("Image_FateContentPNL")
				local Button_Fate = Image_FateContentPNL:getChildByName("Button_Fate"..nIndex)
				local Label_Name = tolua.cast(Button_Fate:getChildByName("Label_Name"), "Label")
                
                if tbFate then
                    local CSV_CardFate = g_DataMgr:getCardFateCsv(tbFate.fate_config_id, tbFate.fate_star_lv)
                    Label_Name:setVisible(true)
					Label_Name:setText(string.format(_T("%s Lv.%d"), CSV_CardFate.Name, tbFate.fate_star_lv))
					g_SetWidgetColorBySLev(Label_Name, CSV_CardFate.ColorType)
                    nFateExp = nFateExp + tbFate.fate_exp + CSV_CardFate.AddExp
					local Image_FateItem = Button_Fate:getChildByName("Image_FateItem")
					if not Image_FateItem then
						Image_FateItem = tolua.cast(g_WidgetModel.Image_FateItem:clone(),  "ImageView")
						Image_FateItem:setName("Image_FateItem")
						Image_FateItem:setPositionXY(0,0)
						local Panel_FateItem = tolua.cast(Image_FateItem:getChildByName("Panel_FateItem"), "Layout")
						Panel_FateItem:setClippingEnabled(true)
						Panel_FateItem:setRadius(92)
						Button_Fate:addChild(Image_FateItem, 0, nIndex)
					else
						Image_FateItem:setVisible(true)
					end
					
					local Image_FateItem = tolua.cast(Button_Fate:getChildByName("Image_FateItem"), "ImageView")
					Image_FateItem:loadTexture(getFateBaseAImg(CSV_CardFate.ColorType))

					local Image_Frame = tolua.cast(Image_FateItem:getChildByName("Image_Frame"), "ImageView")
					Image_Frame:loadTexture(getFateFrameImg(CSV_CardFate.ColorType))
					
					local Panel_FateItem = tolua.cast(Image_FateItem:getChildByName("Panel_FateItem"), "Layout")
					local Image_Fate = tolua.cast(Panel_FateItem:getChildByName("Image_Fate"), "ImageView")
					Image_Fate:setPosition(ccp(96+CSV_CardFate.OffsetX, 96+CSV_CardFate.OffsetY))
					Image_Fate:loadTexture(getIconImg(CSV_CardFate.Animation))
					
					local function onClick_Button_Fate(pSender, eventType)
						if eventType == ccs.TouchEventType.ended then
							g_WndMgr:showWnd("Game_TipDropItemFate", CSV_CardFate)
						end
					end
					
					Button_Fate:setTouchEnabled(true)
					Button_Fate:addTouchEventListener(onClick_Button_Fate)
                else
                    Label_Name:setVisible(false)
					local Image_FateItem = Button_Fate:getChildByName("Image_FateItem")
					if Image_FateItem then
						Image_FateItem:setVisible(false)
					end
                end
            end
			
			local Image_FateContentPNL = Image_FatePNL:getChildByName("Image_FateContentPNL")
			local Image_FateStreangth = Image_FateContentPNL:getChildByName("Image_FateStreangth")
            local Label_FateStreangth = tolua.cast(Image_FateStreangth:getChildByName("Label_FateStreangth"),"Label")
	        Label_FateStreangth:setText(nFateExp)
        end
    end

    local function updateFunction(Panel_CardPage_Fate, nIndex)
		Panel_CardPage_Fate:setVisible(true)
        local tbCard = self.tbCardList[nIndex]
        if tbCard then
            local CSV_CardBase = tbCard:getCsvBase()
			local Panel_Card = tolua.cast(Panel_CardPage_Fate:getChildByName("Panel_Card"), "Layout")
			local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView")
            local CCNode_Skeleton =  g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1)
			Image_Card:removeAllNodes()
			Image_Card:loadTexture(getUIImg("Blank"))
			Image_Card:setPositionXY(CSV_CardBase.Pos_X*Panel_Card:getScale()/0.6, CSV_CardBase.Pos_Y*Panel_Card:getScale()/0.6)
            Image_Card:addNode(CCNode_Skeleton)
            g_runSpineAnimation(CCNode_Skeleton, "idle", true)			
        end
    end

    self.LuaPageView_Card_Fate:registerClickEvent(turningFunction)
    self.LuaPageView_Card_Fate:registerUpdateFunction(updateFunction)
end

function Game_CardDetailViewOther1:processPageView()
    local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
    Image_CardInfoPNL:setVisible(true)
	
    local PageView_Card_Equip = tolua.cast(Image_CardInfoPNL:getChildByName("PageView_Card_Equip"), "PageView")
    PageView_Card_Equip:setClippingEnabled(true)
	
    local LuaPageView_Card_Equip = Class_LuaPageView:new() 
    LuaPageView_Card_Equip:setModel(self.Panel_CardPage_Equip, Image_CardInfoPNL:getChildByName("Button_ForwardPage"), Image_CardInfoPNL:getChildByName("Button_NextPage"), 0.5, 0.5)
    LuaPageView_Card_Equip:setPageView(PageView_Card_Equip)
    self.LuaPageView_Card_Equip = LuaPageView_Card_Equip
    self:registerPageViewEquipEvent()

    --异兽的
    local Image_FatePNL = self.rootWidget:getChildByName("Image_FatePNL") 
    Image_FatePNL:setVisible(false)
	local Image_FateContentPNL = Image_FatePNL:getChildByName("Image_FateContentPNL") 

    local PageView_Card_Fate = tolua.cast(Image_FatePNL:getChildByName("PageView_Card_Fate"), "PageView")
	PageView_Card_Fate:setClippingEnabled(true)
	
    local LuaPageView_Card_Fate = Class_LuaPageView:new()
    LuaPageView_Card_Fate:setModel(self.Panel_CardPage_Fate, Image_FateContentPNL:getChildByName("Button_ForwardPage"),  Image_FateContentPNL:getChildByName("Button_NextPage"), 0.5, 0.5)
    LuaPageView_Card_Fate:setPageView(PageView_Card_Fate)
    self.LuaPageView_Card_Fate = LuaPageView_Card_Fate
    self:registerPageViewFateEvent()
end

function Game_CardDetailViewOther1:processCheckBox()
    local CheckBox_EquipPackage = tolua.cast(self.rootWidget:getChildByName("CheckBox_EquipPackage"), "CheckBox")
    local CheckBox_ViewDetail = tolua.cast(self.rootWidget:getChildByName("CheckBox_ViewDetail"), "CheckBox")
    
    local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
    local Image_FatePNL = self.rootWidget:getChildByName("Image_FatePNL")
    local function setCardInfoVisible(bVisible)
        Image_CardInfoPNL:setVisible(bVisible)
        Image_FatePNL:setVisible(not bVisible)
    end

    local function onClickEquip()
    	self.LuaPageView_Card_Equip:setCurPageIndex(self.nCardIndex or 1)
	    self.LuaPageView_Card_Equip:updatePageView(#self.tbCardList)
        setCardInfoVisible(true)
    end

    local function onClickFate()
        setCardInfoVisible(false)
        self.LuaPageView_Card_Fate:setCurPageIndex(self.nCardIndex or 1)
	    self.LuaPageView_Card_Fate:updatePageView(#self.tbCardList)
    end

    self.checkBoxGroup = CheckBoxGroup:New()
    self.checkBoxGroup:PushBack(CheckBox_EquipPackage, onClickEquip)
    self.checkBoxGroup:PushBack(CheckBox_ViewDetail, onClickFate)
end

--等级属性
function Game_CardDetailViewOther1:setImage_LevelPNL(ListView_CardInfo, tbCard)
	local Image_LevelPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_LevelPNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_LevelPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
    
	local Label_Name = tolua.cast(Image_LevelPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(tbCard:getNameWithSuffix(Label_Name, self.leaderName))

    local Label_Level = tolua.cast(Image_LevelPNL:getChildByName("Label_Level"), "Label")
    Label_Level:setText(string.format(_T("Lv.%d"), tbCard:getLevel()))
	
	local Image_CardExp = tolua.cast(Image_LevelPNL:getChildByName("Image_CardExp"), "ImageView")
    local ProgressBar_CardExp = tolua.cast(Image_CardExp:getChildByName("ProgressBar_CardExp"), "LoadingBar")
    local nExpPrecent = tbCard:getCurExpPrecent()
	nExpPrecent = math.min(100, nExpPrecent)
    ProgressBar_CardExp:setPercent(nExpPrecent)
    local Label_CardExpPercent = tolua.cast(Image_LevelPNL:getChildByName("Label_CardExpPercent"), "Label") 
    Label_CardExpPercent:setText(nExpPrecent.."%")
end

--基础属性
local function setImage_BasePropPNL(ListView_CardInfo, tbCard)
	local Image_BasePropPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_BasePropPNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_BasePropPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	local Label_Health = tolua.cast(Image_BasePropPNL:getChildByName("Label_Health"),"Label")
	Label_Health:setText(tostring(tbCard:getHPMax()))
	
    local LblMagicPoint = tolua.cast(Image_BasePropPNL:getChildByName("Label_MagicPoint"),"Label")
	LblMagicPoint:setText(tostring(tbCard:getMagicPoints()))

	local LblForcePoint = tolua.cast(Image_BasePropPNL:getChildByName("Label_ForcePoint"),"Label")
	LblForcePoint:setText(tostring(tbCard:getForcePoints()))

    local LblSkillPoint = tolua.cast(Image_BasePropPNL:getChildByName("Label_SkillPoint"),"Label")
	LblSkillPoint:setText(tostring(tbCard:getSkillPoints()))
end

--技能升级和突破
local function setImage_SkillInfoPNL(ListView_CardInfo, tbCard, CSV_CardBase)
	local Image_SkillInfoPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_SkillInfoPNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_SkillInfoPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)

    local nEvoluteLevel = tbCard:getEvoluteLevel()--突破等级
    local nStarLevel = tbCard:getStarLevel()
	
    for nIndex = 1, 3 do
        local Button_Skill = Image_SkillInfoPNL:getChildByName("Button_Skill"..nIndex)
        local CSV_SkillBase = g_DataMgr:getSkillBaseCsv(CSV_CardBase["PowerfulSkillID"..nIndex])
		local nSkillLevel = tbCard:getSkillEvoluteSuffix(nIndex)
		--技能等级
		
		local txt = string.format("+%d", nSkillLevel)
		if nSkillLevel == 0 then txt = "" end
		
		local frameColor = tbCard:getSkillColorType(nIndex)
		
		local BitmapLabel_RefineLevel = tolua.cast(Button_Skill:getChildByName("BitmapLabel_RefineLevel"),"LabelBMFont")
		BitmapLabel_RefineLevel:setFntFile(getEquipLevFont(frameColor))
		BitmapLabel_RefineLevel:setText(txt)

		--外框
		local Image_Frame = tolua.cast(Button_Skill:getChildByName("Image_Frame"),"ImageView")
		Image_Frame:loadTexture(getUIImg("Frame_Evolute_DanYaoFrame"..frameColor))
		
		--技能图案
		local Panel_SkillIcon = tolua.cast(Button_Skill:getChildByName("Panel_SkillIcon"), "Layout")
		Panel_SkillIcon:setClippingEnabled(true)
		Panel_SkillIcon:setRadius(43)
		local Image_SkillIcon = tolua.cast(Panel_SkillIcon:getChildByName("Image_SkillIcon"), "ImageView")
        Image_SkillIcon:loadTexture(getIconImg(CSV_SkillBase.Icon))
		
		--点击技能按钮--函数
		local function onClickSkillIcon(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				local tbString = {}
				local tbSkillDesc = {}
				table.insert(tbSkillDesc, CSV_SkillBase.Name)
				table.insert(tbString, tbSkillDesc)

				tbSkillDesc = {}
				table.insert(tbSkillDesc, CSV_SkillBase.Desc)
				table.insert(tbString, tbSkillDesc)

				local tbPos = pSender:getWorldPosition()
				tbPos.x = 640
				tbPos.y = 360
				g_ClientMsgTips:showTip(tbString, tbPos, 5)
			end
		end	
		
        Button_Skill:setTag(nIndex)
        Button_Skill:setTouchEnabled(true)
        Button_Skill:addTouchEventListener(onClickSkillIcon)
	end
end

--境界
local function setImage_RealmPNL(ListView_CardInfo, tbCard)
	local Image_RealmPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_RealmPNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_RealmPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	local Label_RealmLevel = tolua.cast(Image_RealmPNL:getChildByName("Label_RealmLevel"),"Label")
	Label_RealmLevel:setText(tbCard:getRealmNameWithSuffix(Label_RealmLevel))
end

--命力
local function setImage_FatePNL(ListView_CardInfo, nFateExp)

    local Image_FatePNL = tolua.cast(ListView_CardInfo:getChildByName("Image_FatePNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_FatePNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	local Label_FateStrength = tolua.cast(Image_FatePNL:getChildByName("Label_FateStrength"),"Label")
	Label_FateStrength:setText(nFateExp)
end

--职业信息
local function setImage_ProfessionInfoPNL(ListView_CardInfo, CSV_CardBase)
    local Image_ProfessionInfoPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_ProfessionInfoPNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_ProfessionInfoPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
    local Label_Profession = tolua.cast(Image_ProfessionInfoPNL:getChildByName("Label_Profession"),"Label")
	Label_Profession:setText(_T("职业").." "..g_Profession[CSV_CardBase.Profession])
	
	local Label_ProfessionDesc = tolua.cast(Image_ProfessionInfoPNL:getChildByName("Label_ProfessionDesc"),"Label")
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_ProfessionDesc:setFontSize(16)
	end

	Label_ProfessionDesc:setText(g_ProfessionDesc[CSV_CardBase.Profession])
		
	local Image_PropBase = tolua.cast(Image_ProfessionInfoPNL:getChildByName("Image_PropBase"), "ImageView")
	-- Image_PropBase:setSize(CCSize(550,120))
	
end

--详细属性绝对值属性
local function setImage_PropDetailBasePNL(ListView_CardInfo, battleInfo)
	local Image_PropDetailBasePNL = tolua.cast(ListView_CardInfo:getChildByName("Image_PropDetailBasePNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_PropDetailBasePNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	--物攻
	local Label_PhyAttack = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_PhyAttack"),"Label")
	Label_PhyAttack:setText(battleInfo.phy_attack)
	
	--法攻
	local Label_MagAttack = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_MagAttack"),"Label")
	Label_MagAttack:setText(battleInfo.mag_attack)
	
	--绝攻
	local Label_SkillAttack = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_SkillAttack"),"Label")
	Label_SkillAttack:setText(battleInfo.skill_attack)
	
	--物防
	local Label_PhyDefence = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_PhyDefence"),"Label")
	Label_PhyDefence:setText(battleInfo.phy_defence)
	
	--法防
	local Label_MagDefence = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_MagDefence"),"Label")
	Label_MagDefence:setText(battleInfo.mag_defence)
	
	--绝防
	local Label_SkillDefence = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_SkillDefence"),"Label")
	Label_SkillDefence:setText(battleInfo.skill_defence)
end

--详细属性概率属性
local function setImage_PropDetailRatePNL(ListView_CardInfo, battleInfo)
	local Image_PropDetailRatePNL = tolua.cast(ListView_CardInfo:getChildByName("Image_PropDetailRatePNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_PropDetailRatePNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	--暴击
	local Label_CriticalChance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_CriticalChance"),"Label")
	Label_CriticalChance:setText(battleInfo.critical_chance)
	
	--必杀
	local Label_CriticalStrike = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_CriticalStrike"),"Label")
	Label_CriticalStrike:setText(battleInfo.critical_strike)
	
	--命中
	local Label_HitChance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_HitChance"),"Label")
	Label_HitChance:setText(battleInfo.hit_change)
	
	--破击
	local Label_PenetrateChance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_PenetrateChance"),"Label") 
	Label_PenetrateChance:setText(battleInfo.penetrate_chance)
	
	--韧性
	local Label_CriticalResistance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_CriticalResistance"),"Label")
	Label_CriticalResistance:setText(battleInfo.critical_resistance)
	
	--刚毅
	local Label_CriticalStrikeResistance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_CriticalStrikeResistance"),"Label")
	Label_CriticalStrikeResistance:setText(battleInfo.critical_strikeresistance)
	
	--闪避
	local Label_DodgeChance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_DodgeChance"),"Label")
	Label_DodgeChance:setText(battleInfo.dodge_chance)
	
	--格挡
	local Label_BlockChance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_BlockChance"),"Label")
	Label_BlockChance:setText(battleInfo.block_chance)
end

local function setCardGroupItem(ListView_CardInfo, activeState)
	if not activeState then 
		return
	end
	local CSV_CardGroup = g_DataMgr:getCardGroupCsv( activeState.group_id )
	local Image_CardGroupViewPNL = ListView_CardInfo:pushBackDefaultItem()
	g_SetBtnWithPressingEvent(Image_CardGroupViewPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)

	Image_CardGroupViewPNL:setPositionX(0)
	local Label_Name = tolua.cast(Image_CardGroupViewPNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(CSV_CardGroup.Name)
	
	local ImageView_Activate = tolua.cast(Image_CardGroupViewPNL:getChildByName("ImageView_Activate"),"ImageView")
	ImageView_Activate:setPositionX(Label_Name:getPositionX() + Label_Name:getContentSize().width + 10)

	if activeState.state == EnumCardGroupActiveType.ENUM_CARD_GROUP_ACTIVE then --已激活
		ImageView_Activate:loadTexture(getUIImg("CheckBox_Group_Check"))
	else
		ImageView_Activate:loadTexture(getUIImg("CheckBox_Group"))
	end

	local Label_Desc = tolua.cast(Image_CardGroupViewPNL:getChildByName("Label_Desc"),"Label")
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_Desc:setFontSize(16)
	end
	Label_Desc:setText(CSV_CardGroup.Desc)
end

local function setImage_CardGroupPNL(ListView_CardInfo, activeState)
    ListView_CardInfo = tolua.cast(ListView_CardInfo, "ListView")
    ListView_CardInfo:removeItem(12)
	ListView_CardInfo:removeItem(11)
	ListView_CardInfo:removeItem(10)
	ListView_CardInfo:removeItem(9)
	ListView_CardInfo:removeItem(8)
	
	--最多为 4 个组合
	for i = 1,4 do
		setCardGroupItem(ListView_CardInfo, activeState[i])
	end
end

function Game_CardDetailViewOther1:processCardDetail(GameObj_Card, battleInfo, activeState)
    if not self.nDetailCardID or self.nDetailCardID ~= self.nCardID then
        local Image_CardDetailPNL = self.rootWidget:getChildByName("Image_CardDetailPNL")
        local ListView_CardInfo = Image_CardDetailPNL:getChildByName("ListView_CardInfo")
        local CSV_CardBase = GameObj_Card:getCsvBase()

		self:setImage_LevelPNL(ListView_CardInfo, GameObj_Card)
        setImage_BasePropPNL(ListView_CardInfo, GameObj_Card)
        setImage_RealmPNL(ListView_CardInfo, GameObj_Card)
	
		local nFateExp = 0
		for key, value in pairs(self.tbFate) do
			if value.owner_card_id == GameObj_Card:getServerId() then 
				local CSV_CardFate = g_DataMgr:getCardFateCsv(value.fate_config_id, value.fate_star_lv)
				nFateExp = nFateExp + value.fate_exp + CSV_CardFate.AddExp	
			end
		end
        setImage_FatePNL(ListView_CardInfo, nFateExp)
        
		setImage_ProfessionInfoPNL(ListView_CardInfo, CSV_CardBase)
		
		setImage_PropDetailBasePNL(ListView_CardInfo, battleInfo)
		setImage_PropDetailRatePNL(ListView_CardInfo, battleInfo)
        
		setImage_SkillInfoPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)

		setImage_CardGroupPNL(ListView_CardInfo, activeState)
		 
		self.nDetailCardID = self.nCardID
    end
end

function Game_CardDetailViewOther1:closeWnd()
    self.nCardID = nil
    self.nDetailCardID = nil

    self.tbCardList = nil
    self.tbEquip = nil
    self.tbFate = nil
	
	g_Hero:setRestCardBattedata(nil) 
end

function Game_CardDetailViewOther1:initWnd()
	local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
	local Image_PersonalStrength = Image_CardInfoPNL:getChildByName("Image_PersonalStrength")
	
    self.BitmapLabel_PersonalStrength = tolua.cast(Image_PersonalStrength:getChildByName("BitmapLabel_PersonalStrength"), "LabelBMFont")
    self.Label_Name = tolua.cast(Image_CardInfoPNL:getChildByName("Label_Name"), "Label")
    self.AtlasLabel_StarLevel = tolua.cast(Image_CardInfoPNL:getChildByName("AtlasLabel_StarLevel"), "LabelAtlas")
	
	local Image_CardDetailPNL = self.rootWidget:getChildByName("Image_CardDetailPNL")
    local ListView_CardInfo = tolua.cast(Image_CardDetailPNL:getChildByName("ListView_CardInfo"), "ListView")
    local Image_CardGroupViewPNL = g_WidgetModel.Image_CardGroupViewPNL:clone()
	ListView_CardInfo:setItemModel(Image_CardGroupViewPNL)
	
	local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
	self.Panel_CardPage_Equip = tolua.cast(Image_CardInfoPNL:getChildByName("Panel_CardPage_Equip"), "Layout")
	self.Panel_CardPage_Equip:setVisible(false)
	
	local Image_FatePNL = self.rootWidget:getChildByName("Image_FatePNL")
    self.Panel_CardPage_Fate = tolua.cast(Image_FatePNL:getChildByName("Panel_CardPage_Fate"), "Layout")
	self.Panel_CardPage_Fate:setVisible(false)
	
    self:processPageView()
    self:processCheckBox()

    self:initEquipIcon(self.rootWidget)
	
	local Image_ListViewLight = tolua.cast(Image_CardDetailPNL:getChildByName("Image_ListViewLight"), "ImageView")
	g_CreateFadeInOutAction(Image_ListViewLight, 0, 150)
end
--装备
function Game_CardDetailViewOther1:initEquipIcon()
	local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
    for i = 1, 6 do
        local Image_Equip = Image_CardInfoPNL:getChildByName("Image_Equip"..i)
		local Image_DefaultEquip = tolua.cast(Image_Equip:getChildByName("Image_DefaultEquip"), "ImageView")
		if not Image_DefaultEquip then
			Image_DefaultEquip = ImageView:create()
			Image_DefaultEquip:setName("Image_DefaultEquip")
			Image_DefaultEquip:setPositionXY(0,0)
			if i == 1 then
				Image_DefaultEquip:loadTexture(getCardImg("Frame_Equip_DefaultEquip1"))
			else
				Image_DefaultEquip:loadTexture(getCardImg("Frame_Equip_DefaultEquip"..(i+4)))
			end
			Image_Equip:addChild(Image_DefaultEquip)
		end
		
		if i <= 2 then
			local ImageEuipeIcon = tolua.cast(Image_Equip:getChildByName("ImageEuipeIcon"), "ImageView")
			if not ImageEuipeIcon then
				ImageEuipeIcon = g_WidgetModel.Image_EuipeIconRect:clone()
				ImageEuipeIcon:setName("ImageEuipeIcon")
				ImageEuipeIcon:setPositionXY(0,0)
				Image_Equip:addChild(ImageEuipeIcon)
			end
        else
			local ImageEuipeIcon = tolua.cast(Image_Equip:getChildByName("ImageEuipeIcon"), "ImageView")
			if not ImageEuipeIcon then
				ImageEuipeIcon = g_WidgetModel.Image_EuipeIconCircle:clone()
				ImageEuipeIcon:setName("ImageEuipeIcon")
				ImageEuipeIcon:setPositionXY(0,0)
				Image_Equip:addChild(ImageEuipeIcon)
			end
        end
    end
end

function Game_CardDetailViewOther1:openWnd(arg)
	if g_bReturn then return end
	if not arg then return end
    self.tbCardList = {}
    self.tbEquip = {}
    self.tbFate = {}
	
	self.battleInfo = {}
	self.activeState = {}
	
    self.leaderName = arg[2].name
    local tbDetail = arg[2].detail

	if not tbDetail then return end
	
    for _,e in ipairs(tbDetail.equips) do
		local equipInfo = Class_Equip.new()
		local eid = equipInfo:initEquipData(e)
		self.tbEquip[eid] = equipInfo
	end

    for _,f in ipairs(tbDetail.fates) do
		self.tbFate[f.fate_id] = f
	end  

	
	--先排序一下
    table.sort(tbDetail.team_info, function(a,b) return a.pos < b.pos end)
    for k,v in ipairs(tbDetail.team_info) do
		local cardInfo = Class_Card.new()
		cardInfo:setBattleIndex(k) --查看好友伙伴的情况都是 好友出战的 出战才计算属性
		cardInfo:initCardData(v.data)
		table.insert(self.tbCardList, cardInfo)
		table.insert(self.battleInfo, v.battle_info)
		
		
		local activeState = v.active_state 
		local tbActiveState = {}
		for activeStateIndex = 1, #activeState do 
			local t = {}
			t.group_id = activeState[activeStateIndex].group_id
			t.state = activeState[activeStateIndex].state
			table.insert(tbActiveState, t)
		end
		table.insert(self.activeState, tbActiveState)
	end
	self.checkBoxGroup:Click(1)
	
end 