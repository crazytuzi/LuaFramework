--------------------------------------------------------------------------------------
-- 文件名:	LYP_EquipWnd.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	LYP
-- 日  期:	2014-10-28 4:37
-- 版  本:	1.0
-- 描  述:	游戏主界面的装备列表
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

Game_Equip1 = class("Game_Equip1")
Game_Equip1.__index = Game_Equip1

Game_Equip1.tbEquip1 ={
	Label_Level_ = "",
	ProgressBar_CardExp_ = "",
	Label_CardExpPercent_ = "",
	nExpPrecent = "",
}
--[[
类型1：武器 装备类型1-5
类型2：法袍 装备类型6
类型3：戒指 装备类型7
类型4：项链 装备类型8
类型5：奇物 装备类型9
类型6：战靴 装备类型10
]]
local tbEquipSubType = {1,1,1,1,1,2,3,4,5,6}
local nSize = nil
local cardClickIndex = 1

g_CurrentPageViewCardIndex = 1

local function onClickEquipIcon(pSender,eventType)
	if eventType ==ccs.TouchEventType.ended then
        local nEquipID = pSender:getTag()
        if nEquipID > 0 then
            local instance = g_WndMgr:getWnd("Game_Equip1")
			if instance then
				local tbCardData = {}
				tbCardData.nCardID =  instance.nCardID
				tbCardData.nEquipID = nEquipID
				tbCardData.tbPos = ccp(nSize.width/2,nSize.height/2)
				g_WndMgr:showWnd("Game_TipEquip", tbCardData)
			end
        end
    end
end

function Game_Equip1:checkEquip(nSubType)
    local tbCard = g_Hero:getCardObjByServID(self.nCardID)
    if tbCard and tbCard:getCsvBase().Profession == nSubType then
        return true
	end
	return false
end

function Game_Equip1:checkEquipLev(nNeedLevel)
    local tbCard = g_Hero:getCardObjByServID(self.nCardID)
    if tbCard and tbCard:getLevel() >= nNeedLevel then
        return true
	end
	return false
end

function Game_Equip1:setPackage()
    if not self.nCardPackageID 
		or self.nCardPackageID ~= self.nCardID then
       self.nCardPackageID = self.nCardID
       self:setEquipPackage()
    end
end

--等级属性
local function setImage_LevelPNL(ListView_CardInfo, tbCard)
	local Image_LevelPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_LevelPNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_LevelPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)

	local Label_Name = tolua.cast(Image_LevelPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(tbCard:getNameWithSuffix(Label_Name))

    local Label_Level = tolua.cast(Image_LevelPNL:getChildByName("Label_Level"), "Label")
    Label_Level:setText(string.format(_T("Lv.%d"), tbCard:getLevel()))
	Game_Equip1.tbEquip1.Label_Level_ = Label_Level
	
	local Image_CardExp = tolua.cast(Image_LevelPNL:getChildByName("Image_CardExp"), "ImageView")
    local ProgressBar_CardExp = tolua.cast(Image_CardExp:getChildByName("ProgressBar_CardExp"), "LoadingBar")
    local nExpPrecent = tbCard:getCurExpPrecent()
	nExpPrecent = math.min(100, nExpPrecent)
    ProgressBar_CardExp:setPercent(nExpPrecent)
	Game_Equip1.tbEquip1.ProgressBar_CardExp_ = ProgressBar_CardExp
	Game_Equip1.tbEquip1.nExpPrecent = nExpPrecent
	if nExpPrecent < 0 then nExpPrecent = 0 end
    local Label_CardExpPercent = tolua.cast(Image_CardExp:getChildByName("Label_CardExpPercent"), "Label")
    Label_CardExpPercent:setText(nExpPrecent.."%")
	Game_Equip1.tbEquip1.Label_CardExpPercent_ = Label_CardExpPercent
	
	local Button_AddExp = tolua.cast(Image_LevelPNL:getChildByName("Button_AddExp"), "Button")
	if tbCard:checkIsLeader() then 
		Button_AddExp:setTouchEnabled(false)
		Button_AddExp:setBright(false)
	else
		local function onAddExp(pSender,eventType)
			if eventType ==ccs.TouchEventType.ended then
				--增加经验
				local param = {
					cardInfo = tbCard
				}
				g_WndMgr:showWnd("Game_CardLevelUpSingle",param)
			end
		end
		Button_AddExp:setTouchEnabled(true)
		Button_AddExp:setBright(true)
		Button_AddExp:addTouchEventListener(onAddExp)
		
	end
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
local btnWidgetSkil_ = nil

local function setImage_SkillInfoPNL(ListView_CardInfo, tbCard, CSV_CardBase)
	local Image_SkillInfoPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_SkillInfoPNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_SkillInfoPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
    local bLevel = tbCard:getEvoluteLevel()--突破等级
    -- local nStarLev = tbCard:getStarLevel()	--星级
	local tbDanyaoLv =  tbCard:getDanyaoLvList() --丹药等级
	local maxDanyaoLevel = tbCard:getDanyaoMaxLevel() --丹药到最高等级
	
	-- 长按按钮显示技能Tip
	local function onPressing_Button_DanYaoSkill(pSender, nSkillIndex)
		local PowerfulSkillID = CSV_CardBase["PowerfulSkillID"..nSkillIndex]
		local CSV_SkillBase = g_DataMgr:getSkillBaseCsv(PowerfulSkillID)
		local tbString = {}
		local tbSkillDesc = {}
		table.insert(tbSkillDesc, CSV_SkillBase.Name)
		table.insert(tbString, tbSkillDesc)

		tbSkillDesc = {}
		table.insert(tbSkillDesc, CSV_SkillBase.Desc)
		table.insert(tbString, tbSkillDesc)

		local tbPos = pSender:getWorldPosition()
		tbPos.x = tbPos.x
		tbPos.y = tbPos.y + 160
		g_ClientMsgTips:showTip(tbString, tbPos, 3)
	end
	
	--点击技能按钮--函数
	local function onPressed_Button_DanYaoSkill(pSender, skillIndex)			
		local PowerfulSkillID = CSV_CardBase["PowerfulSkillID"..skillIndex]
		local csvSkillBase = g_DataMgr:getSkillBaseCsv(PowerfulSkillID)
		local skillId = csvSkillBase.ID --技能id
		local name = csvSkillBase.Name --技能名称
		local icon = csvSkillBase.Icon
		
		local skillLevel =  tbCard:getSkillLevel(skillIndex) --技能等级
		
		if skillLevel >= maxDanyaoLevel then 
			g_ClientMsgTips:showMsgConfirm(_T("丹药到最高等级了"))
			return
		end
		
		local function composShow()
			--技能图案按钮
			g_WndMgr:showWnd("Game_Compose",{ 
				ID = skillId, --技能id
				name = name, --技能名称
				icon = icon,
				cardInfo = tbCard,
				skillIndex = skillIndex --技能索引 
			})	
		
		end
		-- --添加一键技能升级-------------------------------
		local tbDanyaoLevel = tbDanyaoLv[skillIndex]
		local need,onekeyUpgradeFlag = g_ComposeData:OneKeyUpgradeByHintShow(tbDanyaoLevel,skillLevel,skillId,bLevel)
		if skillLevel > bLevel then
			composShow()
			return
		end
		if onekeyUpgradeFlag and need <= g_Hero:getCoins()  then 
			local tips = string.format(_T("花费%d铜钱可直接升级技能，是否升级?"),need)
			g_ClientMsgTips:showConfirmWnd(tips, function()
				btnWidgetSkil_ = pSender
				--点击确定
				g_MsgMgr:OnceUpgradeSkillRequest(pSender:getTag(),tbCard:getServerId())
			end,function() 
				--点击取消
				composShow()
			end)	
			return 
		end
		----------end  添加一键技能升级------------------------------------------
		composShow()
	end
	
	--当前伙伴技能等级 有三个技能
    for nIndex = 1, 3 do
		local PowerfulSkillID = CSV_CardBase["PowerfulSkillID"..nIndex]
        local tbSkillData = g_DataMgr:getSkillBaseCsv(PowerfulSkillID)
		 --技能id
		local skillID = tbSkillData.ID
		local skillIcon = tbSkillData.Icon
		--技能等级
		local skillLevel = tbCard:getSkillLevel(nIndex) 
		--技能突破后的等级
		local nSkillLevel = tbCard:getSkillEvoluteSuffix(nIndex)

		local Button_DanYaoSkill = Image_SkillInfoPNL:getChildByName("Button_DanYaoSkill"..nIndex)
		g_SetBtnWithPressingEventAndOpenCheck(Button_DanYaoSkill, nIndex, onPressing_Button_DanYaoSkill, onPressed_Button_DanYaoSkill, g_OnCloseTip, true, 0.25)
		
		--技能等级
		local txt = string.format("+%d", nSkillLevel)
		if nSkillLevel == 0 then txt = "" end
		
		local frameColor = tbCard:getSkillColorType(nIndex)
	
		local BitmapLabel_RefineLevel = tolua.cast(Button_DanYaoSkill:getChildByName("BitmapLabel_RefineLevel"),"LabelBMFont")
		BitmapLabel_RefineLevel:setFntFile(getEquipLevFont(frameColor))
		BitmapLabel_RefineLevel:setText(txt)
		--外框
		local Image_Frame = tolua.cast(Button_DanYaoSkill:getChildByName("Image_Frame"),"ImageView")
		Image_Frame:loadTexture(getUIImg("Frame_Evolute_DanYaoFrame"..frameColor))

		--技能图案
		local Panel_SkillIcon = tolua.cast(Button_DanYaoSkill:getChildByName("Panel_SkillIcon"), "Layout")
		Panel_SkillIcon:setClippingEnabled(true)
		Panel_SkillIcon:setRadius(43)
		local Image_SkillIcon = tolua.cast(Panel_SkillIcon:getChildByName("Image_SkillIcon"), "ImageView")
        Image_SkillIcon:loadTexture(getIconImg(skillIcon))
		
		local maxDanyaoLevel = tbCard:getDanyaoMaxLevel()
		local flag = g_CheckDanYaoUpgrade(tbDanyaoLv[nIndex],skillLevel,skillID,bLevel,maxDanyaoLevel)
		g_addUpgradeGuide(Button_DanYaoSkill, ccp(50, 50), 1.25, flag)
	end

    local Button_Evolute = tolua.cast(Image_SkillInfoPNL:getChildByName("Button_Evolute"),"Button")
	local Image_Check = tolua.cast(Button_Evolute:getChildByName("Image_Check"), "ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteCheck, 4)

    local function onClickEvolute(pSender, nTag)
		local nNeedLevel = tbCard:getCardEvolutePropCsv().NeedLevel
		if tbCard:getLevel() < nNeedLevel then
			g_ClientMsgTips:showMsgConfirm(string.format(_T("伙伴等级需要达到%d级方有能力进行突破"), nNeedLevel))
			return
		end
		
		if not g_CheckCardEvolute(tbCard) then
			for nIndex = 1,3 do
				if g_CheckCardEvoluteBySkillIndex(tbCard, nIndex) then
					local Button_DanYaoSkill = Image_SkillInfoPNL:getChildByName("Button_DanYaoSkill"..nIndex)
					local worldSpaceD = Button_DanYaoSkill:getParent():convertToWorldSpace(Button_DanYaoSkill:getPosition())
					CGuidTips:showGuidTip(nil,_T("需先升级方可突破"),worldSpaceD)
					return
				end
			end
		else
			--可以突破
			local instance = g_WndMgr:getWnd("Game_Equip1")
			if instance then
				g_WndMgr:getFormtbRootWidget("Game_UpgradeAnimation")
				g_MsgMgr:requestCardEvolute(instance.nCardID)
			end
		end
	end
	g_SetBtnWithOpenCheck(Button_Evolute, 1, onClickEvolute, true)

	Button_Evolute:stopAllActions()
	if g_CheckCardEvolute(tbCard) then 
		Image_Check:setVisible(true)
		Button_Evolute:loadTextureNormal(getUIImg("Btn_CommonYellow1"))
		Button_Evolute:loadTexturePressed(getUIImg("Btn_CommonYellow1_Press"))
		Button_Evolute:loadTextureDisabled(getUIImg("Btn_CommonYellow1_Disabled"))
		g_CreateFadeInOutAction(Image_Check, 0.75, 100, 0.5)
	else
		Image_Check:setVisible(false)
		Button_Evolute:loadTextureNormal(getUIImg("Btn_Common1"))
		Button_Evolute:loadTexturePressed(getUIImg("Btn_Common1_Press"))
		Button_Evolute:loadTextureDisabled(getUIImg("Btn_Common1_Disabled"))
	end
end
--[[
	技能升级动画
	btnWidgetSkil_ =保存的是当前点击的技能
]]
function Game_Equip1:upAnimation()
	if btnWidgetSkil_ and btnWidgetSkil_:isExsit() then 
		local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("XianMaiActivate", nil, nil, 5)
		armature:setPositionY(5)
		btnWidgetSkil_:addNode(armature,INT_MAX)
		userAnimation:playWithIndex(0)
		self.ckEquip:Click(2)
	end
end
--升星
local function setImage_StarUpPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
	local Image_StarUpPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_StarUpPNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_StarUpPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)

	local Image_HunPoNumBase = tolua.cast(Image_StarUpPNL:getChildByName("Image_HunPoNumBase"),"ImageView")
	local Image_CollectStatus = tolua.cast(Image_HunPoNumBase:getChildByName("Image_CollectStatus"),"ImageView")
	local ProgressBar_HunPoNumPercent = tolua.cast(Image_HunPoNumBase:getChildByName("ProgressBar_HunPoNumPercent"),"LoadingBar")

	local Button_StarUp = tolua.cast(Image_StarUpPNL:getChildByName("Button_StarUp"),"Button")
	local Image_Check = tolua.cast(Button_StarUp:getChildByName("Image_Check"),"ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteCheck, 4)
	
	local nHaveHunPoNum = 0
	local GameObj_HunPo = g_Hero:getHunPoObj(CSV_CardBase.StarUpHunPoID)
	if GameObj_HunPo then
		nHaveHunPoNum = GameObj_HunPo:getNum()
	end
	local nHaveMaterialNum = g_Hero:getItemNumByCsv(CSV_CardBase.ReplaceMaterialID, CSV_CardBase.ReplaceMaterialLevel)
	local nReplaceMaxNum = math.min(nHaveMaterialNum, CSV_CardBase.ReplaceMaterialMaxNum) --可替代的魂石数量
	local nCostHunPoNum = math.min(nHaveHunPoNum, CSV_CardBase.StarUpHunPoNum - nReplaceMaxNum) --消耗的魂魄数量
	
	local Label_CollectStatusFalse = tolua.cast(Image_StarUpPNL:getChildByName("Label_CollectStatusFalse"),"Label")
	local Label_CollectStatusTrue = tolua.cast(Image_StarUpPNL:getChildByName("Label_CollectStatusTrue"),"Label")
	local Label_CollectStatusFull = tolua.cast(Image_StarUpPNL:getChildByName("Label_CollectStatusFull"),"Label")
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_CollectStatusFalse:setFontSize(16)
	end
	
	if not g_CheckFuncCanOpenByWidgetName("Button_StarUp") then
		nCostHunPoNum = 0
		nReplaceMaxNum = 0
	end

	local nMaxStarLevel = g_DataMgr:getGlobalCfgCsv("max_card_star")
	local nStarLev = GameObj_Card:getStarLevel()
	if nStarLev < nMaxStarLevel then
		if (nCostHunPoNum + nReplaceMaxNum) >= CSV_CardBase.StarUpHunPoNum then
			local Label_NeedHunShi = tolua.cast(Label_CollectStatusTrue:getChildByName("Label_NeedHunShi"),"Label")
			local Label_NeedHunShiLB = tolua.cast(Label_CollectStatusTrue:getChildByName("Label_NeedHunShiLB"),"Label")
			local Label_NeedHunPoLB1 = tolua.cast(Label_CollectStatusTrue:getChildByName("Label_NeedHunPoLB1"),"Label")
			local Label_NeedHunPo = tolua.cast(Label_CollectStatusTrue:getChildByName("Label_NeedHunPo"),"Label")
			local Label_NeedHunPoLB2 = tolua.cast(Label_CollectStatusTrue:getChildByName("Label_NeedHunPoLB2"),"Label")
			
			Label_CollectStatusTrue:setVisible(true)
			Label_CollectStatusFalse:setVisible(false)
			Label_CollectStatusFull:setVisible(false)
			Label_NeedHunShi:setText(nReplaceMaxNum)
			Label_NeedHunPo:setText(nCostHunPoNum)
			
			local nWidth1 = Label_CollectStatusTrue:getSize().width
			local nWidth2 = Label_NeedHunShi:getSize().width
			local nWidth3 = Label_NeedHunShiLB:getSize().width
			local nWidth4 = Label_NeedHunPoLB1:getSize().width
			local nWidth5 = Label_NeedHunPo:getSize().width
			local nWidth6 = Label_NeedHunPoLB2:getSize().width
			Label_NeedHunShi:setPositionX(nWidth1)
			Label_NeedHunShiLB:setPositionX(nWidth1+nWidth2)
			Label_NeedHunPoLB1:setPositionX(nWidth1+nWidth2+nWidth3)
			Label_NeedHunPo:setPositionX(nWidth1+nWidth2+nWidth3+nWidth4)
			Label_NeedHunPoLB2:setPositionX(nWidth1+nWidth2+nWidth3+nWidth4+nWidth5)
			Label_CollectStatusTrue:setPositionX(-(nWidth1+nWidth2+nWidth3+nWidth4+nWidth5+nWidth6)/2-50)
			
			Image_CollectStatus:loadTexture(getCardImg("Tip_StarUpTrue"))
			ProgressBar_HunPoNumPercent:setPercent(100)
		else
			local Label_NeedHunShi = tolua.cast(Label_CollectStatusFalse:getChildByName("Label_NeedHunShi"),"Label")
			local Label_NeedHunShiLB = tolua.cast(Label_CollectStatusFalse:getChildByName("Label_NeedHunShiLB"),"Label")
			local Label_NeedHunPoLB1 = tolua.cast(Label_CollectStatusFalse:getChildByName("Label_NeedHunPoLB1"),"Label")
			local Label_NeedHunPo = tolua.cast(Label_CollectStatusFalse:getChildByName("Label_NeedHunPo"),"Label")
			local Label_NeedHunPoLB2 = tolua.cast(Label_CollectStatusFalse:getChildByName("Label_NeedHunPoLB2"),"Label")
			
			Label_CollectStatusTrue:setVisible(false)
			Label_CollectStatusFalse:setVisible(true)
			Label_CollectStatusFull:setVisible(false)
			Label_NeedHunShi:setText(nReplaceMaxNum)
			Label_NeedHunPo:setText(CSV_CardBase.StarUpHunPoNum - nCostHunPoNum - nReplaceMaxNum)
			
			local nWidth1 = Label_CollectStatusFalse:getSize().width
			local nWidth2 = Label_NeedHunShi:getSize().width
			local nWidth3 = Label_NeedHunShiLB:getSize().width
			local nWidth4 = Label_NeedHunPoLB1:getSize().width
			local nWidth5 = Label_NeedHunPo:getSize().width
			local nWidth6 = Label_NeedHunPoLB2:getSize().width
			Label_NeedHunShi:setPositionX(nWidth1)
			Label_NeedHunShiLB:setPositionX(nWidth1+nWidth2)
			Label_NeedHunPoLB1:setPositionX(nWidth1+nWidth2+nWidth3)
			Label_NeedHunPo:setPositionX(nWidth1+nWidth2+nWidth3+nWidth4)
			Label_NeedHunPoLB2:setPositionX(nWidth1+nWidth2+nWidth3+nWidth4+nWidth5)
			Label_CollectStatusFalse:setPositionX(-(nWidth1+nWidth2+nWidth3+nWidth4+nWidth5+nWidth6)/2-50)

			Image_CollectStatus:loadTexture(getCardImg("Tip_StarUpFalse"))
			ProgressBar_HunPoNumPercent:setPercent((nReplaceMaxNum + nCostHunPoNum)*100/CSV_CardBase.StarUpHunPoNum)
		end
	else
		Label_CollectStatusTrue:setVisible(false)
		Label_CollectStatusFalse:setVisible(false)
		Label_CollectStatusFull:setVisible(true)
		Image_CollectStatus:loadTexture(getCardImg("Tip_StarUpFull"))
		ProgressBar_HunPoNumPercent:setPercent(100)
	end

	local function hunPoBaseClick(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			--打开物品掉落界面
			local param = {
				nType = 3, 
				itemId = CSV_CardBase.StarUpHunPoID, 
				itemStar = GameObj_Card:getStarLevel(), 
				detailType = macro_pb.ITEM_TYPE_CARD_GOD, --魂魄
				name = CSV_CardBase.Name}
			g_WndMgr:showWnd("Game_ItemDropGuide",param)
		end
	end
	
	local Button_HunPoBase = tolua.cast(Image_StarUpPNL:getChildByName("Button_HunPoBase"),"Button")
	Button_HunPoBase:setTouchEnabled(true)
	Button_HunPoBase:addTouchEventListener(hunPoBaseClick)
	local Image_HunPo = tolua.cast(Button_HunPoBase:getChildByName("Image_HunPo"),"ImageView")
	local function onClickStarUp()
		if nStarLev < nMaxStarLevel then
			if (nCostHunPoNum + nReplaceMaxNum) >= CSV_CardBase.StarUpHunPoNum then
				local nCardID = GameObj_Card.nServerID
				
				
				
				local function onClickConfirm(itemType)
					--预加载窗口缓存防止卡顿
					g_WndMgr:getFormtbRootWidget("Game_UpgradeAnimation")
					g_MsgMgr:UpgradeStarRequest(nCardID, itemType)
				end
				
				local txt = string.format(_T("消耗%d个%s的魂魄和%d个万能魂石进行升星, 是否继续?"), nCostHunPoNum, CSV_CardBase.Name,nReplaceMaxNum)
				-- echoj("GameObj_HunPo",GameObj_HunPo.tbCsvBase,"CSV_CardBase",CSV_CardBase)
				g_WndMgr:showWnd("Game_ConfirmHunPo", {txt = txt, csvCardHunPo = CSV_CardBase, btnConfirm = onClickConfirm})
				
			else
				local tbWorldPos = Image_HunPo:getParent():convertToWorldSpace(Image_HunPo:getPosition())
				local txt = string.format(_T("需要再集齐%d个魂魄才可升星"), (CSV_CardBase.StarUpHunPoNum - nCostHunPoNum - nReplaceMaxNum) )
				CGuidTips:showGuidTip(nil, txt, tbWorldPos)
			end
		else
			g_ClientMsgTips:showMsgConfirm(_T("伙伴已经达到满星了"))
		end
	end
	g_SetBtnWithOpenCheck(Button_StarUp, 1, onClickStarUp, true)

	Button_StarUp:stopAllActions()
	if g_CheckCardStarUp(GameObj_Card) then 
		Image_Check:setVisible(true)
		Button_StarUp:loadTextureNormal(getUIImg("Btn_CommonYellow1"))
		Button_StarUp:loadTexturePressed(getUIImg("Btn_CommonYellow1_Press"))
		Button_StarUp:loadTextureDisabled(getUIImg("Btn_CommonYellow1_Disabled"))
		g_CreateFadeInOutAction(Image_Check, 0.75, 100, 0.5)
	else
		Image_Check:setVisible(false)
		Button_StarUp:loadTextureNormal(getUIImg("Btn_Common1"))
		Button_StarUp:loadTexturePressed(getUIImg("Btn_Common1_Press"))
		Button_StarUp:loadTextureDisabled(getUIImg("Btn_Common1_Disabled"))
	end
end

--境界
local function setImage_RealmPNL(ListView_CardInfo, tbCard)
	local Image_RealmPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_RealmPNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_RealmPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	local Label_RealmLevel = tolua.cast(Image_RealmPNL:getChildByName("Label_RealmLevel"),"Label")
	Label_RealmLevel:setText(tbCard:getRealmNameWithSuffix(Label_RealmLevel))

	local Button_JingJie = tolua.cast(Image_RealmPNL:getChildByName("Button_JingJie"),"Button")
	local Image_Check = tolua.cast(Button_JingJie:getChildByName("Image_Check"), "ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteCheck, 4)

	local function onClickJingJie(pSender, nTag)
		local instance = g_WndMgr:getWnd("Game_Equip1")
		if instance then
			g_WndMgr:openWnd("Game_CardDuJie", instance.nCardID)
		end
	end

	g_SetBtnWithOpenCheck(Button_JingJie, 1, onClickJingJie, true)

	Button_JingJie:stopAllActions()
	
	local bStatus, strStatusCode = g_CheckCardRealmUp(tbCard)
	if bStatus  then 
		Image_Check:setVisible(true)
		Button_JingJie:loadTextureNormal(getUIImg("Btn_CommonYellow1"))
		Button_JingJie:loadTexturePressed(getUIImg("Btn_CommonYellow1_Press"))
		Button_JingJie:loadTextureDisabled(getUIImg("Btn_CommonYellow1_Disabled"))
		g_CreateFadeInOutAction(Image_Check, 0.75, 100, 0.5)
	else
		Image_Check:setVisible(false)
		Button_JingJie:loadTextureNormal(getUIImg("Btn_Common1"))
		Button_JingJie:loadTexturePressed(getUIImg("Btn_Common1_Press"))
		Button_JingJie:loadTextureDisabled(getUIImg("Btn_Common1_Disabled"))
	end
	
end

--异兽
local function setImage_FatePNL(ListView_CardInfo, tbCard)
	local Image_FatePNL = tolua.cast(ListView_CardInfo:getChildByName("Image_FatePNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_FatePNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	local Label_FateStrength = tolua.cast(Image_FatePNL:getChildByName("Label_FateStrength"),"Label")
	Label_FateStrength:setText(tostring(tbCard:getFateExp()))

	local Button_YiShou = tolua.cast(Image_FatePNL:getChildByName("Button_YiShou"),"Button")
	local Image_Check = tolua.cast(Button_YiShou:getChildByName("Image_Check"), "ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteCheck, 4)

	local function onClickFate(pSender, nTag)
		local instance = g_WndMgr:getWnd("Game_Equip1")
		if instance then
			local tbMag = {}
			tbMag.nCardID = instance.nCardID
			g_WndMgr:openWnd("Game_CardFate1", tbMag)
		end
	end
	g_SetBtnWithOpenCheck(Button_YiShou, 0, onClickFate, true)
	
	Button_YiShou:stopAllActions()
	if g_CheckCardFateUpgrade(tbCard) then
		Image_Check:setVisible(true)
		Button_YiShou:loadTextureNormal(getUIImg("Btn_CommonYellow1"))
		Button_YiShou:loadTexturePressed(getUIImg("Btn_CommonYellow1_Press"))
		Button_YiShou:loadTextureDisabled(getUIImg("Btn_CommonYellow1_Disabled"))
		g_CreateFadeInOutAction(Image_Check, 0.75, 100, 0.5)
	else
		Image_Check:setVisible(false)
		Button_YiShou:loadTextureNormal(getUIImg("Btn_Common1"))
		Button_YiShou:loadTexturePressed(getUIImg("Btn_Common1_Press"))
		Button_YiShou:loadTextureDisabled(getUIImg("Btn_Common1_Disabled"))
	end
end

--职业信息
local function setImage_ProfessionInfoPNL(ListView_CardInfo, tbCard, CSV_CardBase)
    local Image_ProfessionInfoPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_ProfessionInfoPNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_ProfessionInfoPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
    local Label_Profession = tolua.cast(Image_ProfessionInfoPNL:getChildByName("Label_Profession"),"Label")
	Label_Profession:setText(_T("职业").." "..g_Profession[CSV_CardBase.Profession])

	local Label_ProfessionDesc = tolua.cast(Image_ProfessionInfoPNL:getChildByName("Label_ProfessionDesc"),"Label")
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_ProfessionDesc:setFontSize(16)
	end
	Label_ProfessionDesc:setText(g_ProfessionDesc[CSV_CardBase.Profession])
end

--详细属性绝对值属性
local function setImage_PropDetailBasePNL(ListView_CardInfo, tbCard)
	local Image_PropDetailBasePNL = tolua.cast(ListView_CardInfo:getChildByName("Image_PropDetailBasePNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_PropDetailBasePNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	local Label_PhyAttack = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_PhyAttack"),"Label")
	Label_PhyAttack:setText(tostring(tbCard:getPhyAttack()))

	local Label_MagAttack = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_MagAttack"),"Label")
	Label_MagAttack:setText(tostring(tbCard:getMagAttack()))

	local Label_SkillAttack = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_SkillAttack"),"Label")
	Label_SkillAttack:setText(tostring(tbCard:getSkillAttack()))

	local Label_PhyDefence = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_PhyDefence"),"Label")
	Label_PhyDefence:setText(tostring(tbCard:getPhyDefence()))

	local Label_MagDefence = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_MagDefence"),"Label")
	Label_MagDefence:setText(tostring(tbCard:getMagDefence()))

	local Label_SkillDefence = tolua.cast(Image_PropDetailBasePNL:getChildByName("Label_SkillDefence"),"Label")
	Label_SkillDefence:setText(tostring(tbCard:getSkillDefence()))
end

--详细属性概率属性
local function setImage_PropDetailRatePNL(ListView_CardInfo, tbCard)
	local Image_PropDetailRatePNL = tolua.cast(ListView_CardInfo:getChildByName("Image_PropDetailRatePNL"), "ImageView")
	g_SetBtnWithPressingEvent(Image_PropDetailRatePNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)

	local Label_CriticalChance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_CriticalChance"),"Label")
	Label_CriticalChance:setText(tbCard:getCriticalChance())

	local Label_CriticalStrike = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_CriticalStrike"),"Label")
	Label_CriticalStrike:setText(tbCard:getCriticalStrike())

	local Label_HitChance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_HitChance"),"Label")
	Label_HitChance:setText(tbCard:getHitChance())

	local Label_PenetrateChance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_PenetrateChance"),"Label")
	Label_PenetrateChance:setText(tbCard:getPenetrateChance())

	local Label_CriticalResistance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_CriticalResistance"),"Label")
	Label_CriticalResistance:setText(tbCard:getCriticalResistance())

	local Label_CriticalStrikeResistance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_CriticalStrikeResistance"),"Label")
	Label_CriticalStrikeResistance:setText(tbCard:getCriticalStrikeResistance())

	local Label_DodgeChance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_DodgeChance"),"Label")
	Label_DodgeChance:setText(tbCard:getDodgeChance())

	local Label_BlockChance = tolua.cast(Image_PropDetailRatePNL:getChildByName("Label_BlockChance"),"Label")
	Label_BlockChance:setText(tbCard:getBlockChance())
end

local function tips(Image_Condition, nCsvID, nStarLevel, nEvoluteLevel, strDesc)
    local function onPressed_Image_Condition(pSender, nTag)
	    local CSV_DropItem = {
		    DropItemType = macro_pb.ITEM_TYPE_CARD,
		    DropItemID = nCsvID,
		    DropItemStarLevel = nStarLevel,
		    DropItemNum = 0,
		    DropItemEvoluteLevel = nEvoluteLevel,
		    DropItemDesc = strDesc
	    }
	    g_WndMgr:showWnd("Game_TipDropItemCard", CSV_DropItem)
    end

    g_SetBtnWithEvent(Image_Condition, nil,  onPressed_Image_Condition, true)
end
--组合
-- local function setCardGroupItem(ListView_CardInfo, nCardGroupCsvID, GameObj_Card, nCardGroupIndex)
local function setCardGroupItem(ListView_CardInfo, nCardGroupCsvID)
	if not nCardGroupCsvID or nCardGroupCsvID == 0 then return end

	local CSV_CardGroup = g_DataMgr:getCardGroupCsv(nCardGroupCsvID)
	
	local Image_CardGroupPNL = ListView_CardInfo:pushBackDefaultItem()
	Image_CardGroupPNL:setPositionX(0)
	g_SetBtnWithPressingEvent(Image_CardGroupPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	local Label_Name = tolua.cast(Image_CardGroupPNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(CSV_CardGroup.Name)

	local ImageView_Activate = tolua.cast(Image_CardGroupPNL:getChildByName("ImageView_Activate"),"ImageView")
	ImageView_Activate:setPositionX(Label_Name:getPositionX() + Label_Name:getContentSize().width + 10)
    ImageView_Activate:loadTexture(getUIImg("CheckBox_Group"))
	
	local groupNum = {}
	for i = 1, 5 do
		local cardId = CSV_CardGroup["CardID"..i]
		if cardId ~= 0 then 
			table.insert(groupNum, cardId)
		end
		local Image_Condition = tolua.cast(Image_CardGroupPNL:getChildByName("Image_Condition"..i),"ImageView")
    	Image_Condition:setVisible(false)
--		setCardGroupCondition(Image_CardGroupPNL, cardId, i)
	end
    local groupFlag = false
	local groupFlagNum = 0
    for index = 1, #groupNum do 
        local nCsvID = groupNum[index]
        
		local Image_Condition = tolua.cast(Image_CardGroupPNL:getChildByName("Image_Condition"..index),"ImageView")
		Image_Condition:setVisible(true)
	  
	    local Image_Icon = tolua.cast(Image_Condition:getChildByName("Image_Icon"),"ImageView")
        local Image_Frame = tolua.cast(Image_Icon:getChildByName("Image_Frame"),"ImageView")
	  
		
	    local nStarLevel = 1;
	    local nEvoluteLevel = 1;
	    local GameObj_Card = g_Hero:getCardObjByCsvID(nCsvID)
	    if GameObj_Card then
		    nStarLevel = GameObj_Card:getStarLevel()
		    nEvoluteLevel = GameObj_Card:getEvoluteLevel()
			
		    Image_Icon:setColor(g_getColor(ccs.COLOR.WHITE))
		    Image_Frame:loadTexture(getCardFrameByEvoluteLev(nEvoluteLevel))

			groupFlagNum = groupFlagNum + 1
			groupFlag = true

	    else
		    local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(nCsvID)
		    nStarLevel = CSV_CardHunPo.CardStarLevel
		    nEvoluteLevel = 1
            Image_Icon:setColor(g_getColor(ccs.COLOR.DEEP_GREY))

			groupFlag = false
	    end
		
		ImageView_Activate:loadTexture(getUIImg("CheckBox_Group"))
		--所有缘分伙伴都拥有了
		if groupFlagNum == #groupNum then 
			ImageView_Activate:loadTexture(getUIImg("CheckBox_Group_Check"))
		end
		
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(nCsvID, nStarLevel)
		local strDesc = string.format(_T("需要拥有伙伴[%s]方可激活缘分属性"), CSV_CardBase.Name)
		if groupFlag then 
			strDesc = string.format(_T("伙伴[%s]已拥有, 其的激活条件已满足"), CSV_CardBase.Name)
		end
		tips(Image_Condition, nCsvID, nStarLevel, nEvoluteLevel, strDesc)
		
	    local CSV_CardBase = g_DataMgr:getCardBaseCsv(nCsvID, nStarLevel)
	    Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))

    end
	
	local Label_Desc = tolua.cast(Image_CardGroupPNL:getChildByName("Label_Desc"),"Label")
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_Desc:setFontSize(16)
	end
	Label_Desc:setText(CSV_CardGroup.Desc)
end

local function setImage_CardGroupPNL(ListView_CardInfo, CSV_CardBase)
    ListView_CardInfo:removeItem(12)
	ListView_CardInfo:removeItem(11)
	ListView_CardInfo:removeItem(10)
	ListView_CardInfo:removeItem(9)
	setCardGroupItem(ListView_CardInfo, CSV_CardBase.CardGroupID1)
	setCardGroupItem(ListView_CardInfo, CSV_CardBase.CardGroupID2)
	setCardGroupItem(ListView_CardInfo, CSV_CardBase.CardGroupID3)
	setCardGroupItem(ListView_CardInfo, CSV_CardBase.CardGroupID4)
end

function Game_Equip1:setImage_CardDetailPNL()
	
    if not self.nCardDetailID or self.nCardDetailID ~= self.nCardID then
        self.nCardDetailID = self.nCardID
		
        local GameObj_Card = g_Hero:getCardObjByServID(self.nCardID)
		if not GameObj_Card then return end

        local ListView_CardInfo = tolua.cast(self.Image_CardDetailPNL:getChildByName("ListView_CardInfo"), "ListView")
        local CSV_CardBase = GameObj_Card:getCsvBase()
	
		setImage_LevelPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
		setImage_BasePropPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
		setImage_SkillInfoPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
		setImage_StarUpPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
		setImage_RealmPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
		setImage_FatePNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
		setImage_ProfessionInfoPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
		setImage_PropDetailBasePNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
		setImage_PropDetailRatePNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
		
		setImage_CardGroupPNL(ListView_CardInfo, CSV_CardBase)
		
    end
end

--[[
	是否可以强化,是否强化到当前最大等级
	@return nNeedMoney 某一个装备要升级的铜钱
	@return tbEquipCurLevel --某卡牌穿着的装备等级
	@return maxLevel	--某卡牌穿着的装备等级 是否达到当前最大等级了 true 达到最大等级
]]
function Game_Equip1:equipStrengthenOrMaxLv(tbCard)
	local tbEquipCurLevel = {}
	local tbNeedMoney = {}
	local nNeedMoney = 0
	local equipNum = 0 --卡牌穿着的装备数量
	local maxLvEquipNum = 0 --当前最大等级装备的数量
	for i = 1,6 do 
		local nEquipID = tbCard:getEquipIDByPos(i)
		if nEquipID > 0 then 
			equipNum = equipNum + 1
			local GameObj_Equip = g_Hero:getEquipObjByServID(nEquipID)
			table.insert(tbEquipCurLevel,GameObj_Equip:getStrengthenLev())
			local CSV_EquipStrengthenCost = g_DataMgr:getEquipStrengthenCostCsv( GameObj_Equip:getStrengthenLev())
			local CSV_Equip = g_DataMgr:getCsvConfigByTwoKey("Equip",GameObj_Equip.nCsvID, GameObj_Equip:getStarLevel())
			nNeedMoney = math.floor(CSV_EquipStrengthenCost.StrengthenCost * CSV_Equip.StrengthenFactor/g_BasePercent)
			if GameObj_Equip:getStrengthenLev() >= GameObj_Equip:getEquipStrengthenCostCsvMaxLevelel() then 
				maxLvEquipNum = maxLvEquipNum + 1
			end
		end
	end
	local maxLevel = false
	if maxLvEquipNum >= equipNum then 
		maxLevel = true
	end	
	return nNeedMoney,tbEquipCurLevel,maxLevel
end
--[[
	计算一键强化需要消耗的铜钱
	@param tbCard 卡牌对象
	@param tbEquipCurLevel --某卡牌穿着的装备等级
	@return addNeed --某卡牌穿着的装备等级升级到某一等级的总铜钱消耗
]]
function Game_Equip1:oneKeyUpgreNeedSumTotal(tbCard,tbEquipCurLevel)
	local curCoins = g_Hero:getCoins()
	local addNeed = 0
	for i = 1,5 do --最大提升5个等级
		for nCount = 1,6 do 
			local nEquipID = tbCard:getEquipIDByPos(nCount)
			if nEquipID > 0 then 
				local GameObj_Equip = g_Hero:getEquipObjByServID(nEquipID)
				local curLevel = tbEquipCurLevel[nCount]
				if curLevel and GameObj_Equip then 
					local CSV_EquipStrengthenCost = g_DataMgr:getEquipStrengthenCostCsv( curLevel)
					local CSV_Equip = g_DataMgr:getCsvConfigByTwoKey("Equip",GameObj_Equip.nCsvID, GameObj_Equip:getStarLevel())
					local costNeed = math.ceil(CSV_EquipStrengthenCost.StrengthenCost * CSV_Equip.StrengthenFactor/g_BasePercent)
					if curCoins >= costNeed + addNeed and curLevel < GameObj_Equip:getEquipStrengthenCostCsvMaxLevelel() then
						addNeed = addNeed + costNeed
						curLevel = curLevel + 1
						tbEquipCurLevel[nCount] = curLevel
					end
				end
			end
		end
	end
	return addNeed

end

function Game_Equip1:initWnd()
	g_CurrentPageViewCardIndex = 1
	
	--一键全部强化
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_EQUIP_STRENGTHEN_ALL_RESPONSE, handler(self, self.requeStrengthOneKeyAllResponse))
	--伙伴分解
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_DECOMPOSE_CARD_RESPONSE, handler(self, self.requetDecomposeCardResponse))
	--合成后更新战斗力
	g_FormMsgSystem:RegisterFormMsg(FormMsg_Compose_Strength, handler(self, self.UpdatefightingCapacity))

	nSize = self.rootWidget:getSize()
    local function onClickEquipPos(pSender, nTag)
		if nTag > 0 then
			local tbCardData = {}
			tbCardData.nCardID =  self.nCardID
			tbCardData.nEquipID = nTag
			tbCardData.tbPos = ccp(nSize.width/2,nSize.height/2)  --pSender:getPosition()cc
			g_WndMgr:showWnd("Game_TipEquip", tbCardData)
		else
			local nPos = -nTag
			--增加物品 检索规则为，在可穿装备中，选一个品质最高的（脚本ColorType字段），
			--如果品质相同，则选取合成等级最高的，如果合成等级相同，则选取强化等级最高的。
			local tbEquip = g_Hero:getUndressEquipList()
			local tbDressEquip = nil
			for i=1, #tbEquip do
				local tbCurEquip = tbEquip[i]
				local tbEquipBase = tbCurEquip:getCsvBase()
				if tbEquipSubType[tbEquipBase.SubType] == nPos then
					if self:checkEquipLev(tbEquipBase.NeedLevel) and  (nPos > 1 or self:checkEquip(tbEquipBase.SubType)) then
						if not tbDressEquip then
							tbDressEquip = tbCurEquip
						else
							local tbDressEquipBase = tbDressEquip:getCsvBase()
							if tbDressEquipBase.ColorType < tbEquipBase.ColorType or
								tbDressEquip:getRefineLev() < tbCurEquip:getRefineLev() or
								tbDressEquip:getStrengthenLev() < tbCurEquip:getStrengthenLev()  then
								tbDressEquip = tbCurEquip
							end
						end
					end
				end
			end

			if tbDressEquip then
				--装备 请求
				g_MsgMgr:requestDressEquip(self.nCardID, nPos, tbDressEquip:getServerId())
			end
		end
    end
	
	local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
	
	local Image_TitlePNL = tolua.cast(self.rootWidget:getChildByName("Image_TitlePNL"), "ImageView")
	
	local function OnTouchOneKeyStrengthen(pSender, nTag)
		local tbCard = g_Hero:getCardObjByServID(self.nCardID)
		local nNeedMoney,tbEquipCurLevel,flagMaxLv = self:equipStrengthenOrMaxLv(tbCard)
		if flagMaxLv then 
			g_ShowSysTips({text = _T("装备已经达到当前最大等级了")})
			return 
		end
	
		local addNeed = self:oneKeyUpgreNeedSumTotal(tbCard,tbEquipCurLevel)
		if g_CheckMoneyConfirm(nNeedMoney) then
			g_ClientMsgTips:showConfirmWnd(string.format(_T("一键强化5级将消耗%d的铜钱，是否继续？"),addNeed), function() 
				self:requeStrengthOneKeyAllRequest(self.nCardID)
			end)
		end
	end
	-- local Button_OneKeyStrengthen = tolua.cast(Image_CardInfoPNL:getChildByName("Button_OneKeyStrengthen"),"Button") 
	local Button_OneKeyStrengthen = tolua.cast(Image_TitlePNL:getChildByName("Button_OneKeyStrengthen"),"Button") 
	g_SetBtnOpenCheckWithPressImage(Button_OneKeyStrengthen, 1, OnTouchOneKeyStrengthen, true)
	
	--传承
	local function onClick_Button_ChuanCheng(pSender, nTag)
		local GameObj_Card = g_Hero:getCardObjByServID(self.nCardID)
		if GameObj_Card:checkIsLeader() then
			g_ClientMsgTips:showMsgConfirm(_T("主角无法进行传承, 请选择其他伙伴"))
		else
			g_WndMgr:showWnd("Game_ChuanCheng", self.nCardID)
		end
	end
	
	-- local Button_ChuanCheng = tolua.cast(Image_CardInfoPNL:getChildByName("Button_ChuanCheng"),"Button") 
	local Button_ChuanCheng = tolua.cast(Image_TitlePNL:getChildByName("Button_ChuanCheng"),"Button") 
	g_SetBtnWithPressImage(Button_ChuanCheng, 1, onClick_Button_ChuanCheng, true, 1, 200)
	
	--分解
	local function onClick_Button_FenJie(pSender, nTag)
		local GameObj_Card = g_Hero:getCardObjByServID(self.nCardID)
		if GameObj_Card:checkIsLeader() then
			g_ClientMsgTips:showMsgConfirm(_T("主角无法被分解, 请选择其他伙伴"))
			return
		end
		if GameObj_Card:checkIsInBattle() then
			g_ClientMsgTips:showMsgConfirm(_T("出战中的伙伴无法被分解, 请先下阵"))
			return
		end
		local function onClick_Confirm()
			self:requestDecomposeCard(self.nCardID)
		end
		local txt = string.format(_T("分解伙伴可获得%d个将魂石，是否确认分解？"),GameObj_Card:getCsvBase().DecomposeJiangHun)
		g_ClientMsgTips:showConfirm(txt, onClick_Confirm, nil)
	end
	-- local Button_FenJie = tolua.cast(Image_CardInfoPNL:getChildByName("Button_FenJie"),"Button") 
	local Button_FenJie = tolua.cast(Image_TitlePNL:getChildByName("Button_FenJie"),"Button") 
	g_SetBtnOpenCheckWithPressImage(Button_FenJie, 1, onClick_Button_FenJie, true, nil, nil, 1, 200)

	-- local Image_TitlePNL = tolua.cast(self.rootWidget:getChildByName("Image_TitlePNL"), "ImageView")
	local x = 80
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		x = 40
	end
	
	local Image_WndName = tolua.cast(Image_TitlePNL:getChildByName("Image_WndName"), "ImageView")
	
	g_AdjustWidgetsPosition({Image_WndName,Button_OneKeyStrengthen,Button_ChuanCheng,Button_FenJie},10)

	local Image_FuncName = tolua.cast(Button_OneKeyStrengthen:getChildByName("Image_FuncName"), "ImageView")
	Image_FuncName:setPositionX(Button_OneKeyStrengthen:getSize().width/2)
	local Image_Check = tolua.cast(Button_OneKeyStrengthen:getChildByName("Image_Check"), "ImageView")
	Image_Check:setPositionX(Button_OneKeyStrengthen:getSize().width/2)

	local Image_FuncName = tolua.cast(Button_ChuanCheng:getChildByName("Image_FuncName"), "ImageView")
	Image_FuncName:setPositionX(Button_ChuanCheng:getSize().width/2)
	local Image_Check = tolua.cast(Button_ChuanCheng:getChildByName("Image_Check"), "ImageView")
	Image_Check:setPositionX(Button_ChuanCheng:getSize().width/2)
	
	local Image_FuncName = tolua.cast(Button_FenJie:getChildByName("Image_FuncName"), "ImageView")
	Image_FuncName:setPositionX(Button_FenJie:getSize().width/2)
	local Image_Check = tolua.cast(Button_FenJie:getChildByName("Image_Check"), "ImageView")
	Image_Check:setPositionX(Button_FenJie:getSize().width/2)

	
	--装备栏
    for i=1,6 do
		local Image_Equip = tolua.cast(Image_CardInfoPNL:getChildByName("Image_Equip"..i), "ImageView")
		Image_Equip.index = i
		g_SetBtnWithGuideCheck(Image_Equip, -i, onClickEquipPos, true, nil, nil, nil)
    end
	
    local Image_EquipPackagePNL = self.rootWidget:getChildByName("Image_EquipPackagePNL")
    local Image_CardDetailPNL = self.rootWidget:getChildByName("Image_CardDetailPNL")
	self.Image_CardDetailPNL = Image_CardDetailPNL   
	local function setCheckBoxData(bEnable)
        Image_EquipPackagePNL:setVisible(bEnable)
        Image_CardDetailPNL:setVisible(not bEnable)
    end
   
	local Image_ListViewLight = tolua.cast(Image_CardDetailPNL:getChildByName("Image_ListViewLight"), "ImageView")
	g_CreateFadeInOutAction(Image_ListViewLight, 0, 150, 0.85)
	local Image_ListViewLightChar = tolua.cast(Image_ListViewLight:getChildByName("Image_ListViewLightChar"), "ImageView")
	g_CreateScaleInOutAction(Image_ListViewLightChar)

	local CheckBox_EquipPackage = tolua.cast(Image_CardInfoPNL:getChildByName("CheckBox_EquipPackage"), "CheckBox")
	local CheckBox_ViewDetail = tolua.cast(Image_CardInfoPNL:getChildByName("CheckBox_ViewDetail"), "CheckBox")

    local function onClickShowPackage()
        setCheckBoxData(true)		
        self:setPackage()
		-- 单击装备按钮 显示详细信息界面是否有可以操作的提示
		local tbCard = g_Hero:getCardObjByServID(self.nCardID)
		if tbCard then
			local flag = g_CheckCardDanYao(tbCard)
			g_addUpgradeGuide(CheckBox_ViewDetail, ccp(80, 28), nil, flag)
		end
    end

    local function onClickShowDetail()
        setCheckBoxData(false)
		--详细信息
        self:setImage_CardDetailPNL()
		g_addUpgradeGuide(CheckBox_ViewDetail, ccp(80, 28), nil, false)
    end

    local ListView_CardInfo = tolua.cast(Image_CardDetailPNL:getChildByName("ListView_CardInfo"), "ListView")
    local Image_CardGroupPNL = g_WidgetModel.Image_CardGroupPNL:clone()
	ListView_CardInfo:setItemModel(Image_CardGroupPNL)

	
	local function onBasecoat(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			if g_PlayerGuide:checkIsInGuide() then return end
			ListView_CardInfo:jumpToBottom()
		end
	end
	Image_ListViewLight:setTouchEnabled(true)
	Image_ListViewLight:addTouchEventListener(onBasecoat)
	
    setCheckBoxData(true)

    self.ckEquip = CheckBoxGroup:New()
	-- 装备背包
    self.ckEquip:PushBack(CheckBox_EquipPackage, onClickShowPackage)
	-- 详细属性
    self.ckEquip:PushBack(CheckBox_ViewDetail, onClickShowDetail)

	--装备list(右边)
	local Image_EquipPackage = tolua.cast(Image_EquipPackagePNL:getChildByName("Image_EquipPackage"), "ImageView")
	Image_EquipPackage:removeAllChildren()
	self.LuaListView_EquipPackage = Class_LuaListView:create()
	self.LuaListView_EquipPackage:setListView(ListView_EquipPackage)
    self.LuaListView_EquipPackage:setDirection(LISTVIEW_DIR_VERTICAL)
    self.LuaListView_EquipPackage:setSize(CCSizeMake(504,504))
    self.LuaListView_EquipPackage:setPosition(ccp(-252,-252))
	Image_EquipPackage:addChild(self.LuaListView_EquipPackage.widgetListView, 10)
	self:registerListViewEvent()
	
	local imgScrollSlider = self.LuaListView_EquipPackage:getScrollSlider()
	if not g_tbScrollSliderXY.LuaListView_EquipPackage_X then
		g_tbScrollSliderXY.LuaListView_EquipPackage_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_EquipPackage_X + 10)
	
	local Image_PersonalStrength = tolua.cast(Image_CardInfoPNL:getChildByName("Image_PersonalStrength"), "ImageView")
    self.BitmapLabel_PersonalStrength = tolua.cast(Image_PersonalStrength:getChildByName("BitmapLabel_PersonalStrength"), "LabelBMFont")
    self.Label_Name = tolua.cast(Image_CardInfoPNL:getChildByName("Label_Name"), "Label")

    self.AtlasLabel_StarLevel = tolua.cast(Image_CardInfoPNL:getChildByName("AtlasLabel_StarLevel"), "LabelAtlas")
	
	local PageView_Card = tolua.cast(Image_CardInfoPNL:getChildByName("PageView_Card"), "PageView")
    PageView_Card:setClippingEnabled(true)
    self.Panel_CardPage = PageView_Card:getChildByName("Panel_CardPage")
    self.Panel_CardPage:retain()
	
	local LuaPageView_Card = Class_LuaPageView:new()
	LuaPageView_Card:setModel(self.Panel_CardPage, Image_CardInfoPNL:getChildByName("Button_ForwardPage"), Image_CardInfoPNL:getChildByName("Button_NextPage"), 0.5, 0.5)
    LuaPageView_Card:setPageView(PageView_Card)
    LuaPageView_Card:removeAllPages()
    self.LuaPageView_Card = LuaPageView_Card
	
    self:registerPageViewEvent()
    self:initEquipIcon()
end

function Game_Equip1:initEquipIcon()
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
			local Image_Add = ImageView:create()
			Image_Add:loadTexture(getUIImg("Image_Add"))
			Image_Add:setName("Image_Add")
			Image_Add:setPositionXY(0,0)
			g_CreateScaleInOutAction(Image_Add)
			Image_DefaultEquip:addChild(Image_Add)
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

	local Image_SymbolBlueLight = tolua.cast(Image_CardInfoPNL:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)

	local Image_SymbolOutside = tolua.cast(Image_CardInfoPNL:getChildByName("Image_SymbolOutside"), "ImageView")
	local Image_SymbolInside = tolua.cast(Image_CardInfoPNL:getChildByName("Image_SymbolInside"), "ImageView")

	local actionRotateTo_SymbolOutside = CCRotateBy:create(60, -360)
	local actionForever_SymbolOutside = CCRepeatForever:create(actionRotateTo_SymbolOutside)
	Image_SymbolOutside:runAction(actionForever_SymbolOutside)

	local actionRotateTo_SymbolInside = CCRotateBy:create(60, 360)
	local actionForever_SymbolInsidet = CCRepeatForever:create(actionRotateTo_SymbolInside)
	Image_SymbolInside:runAction(actionForever_SymbolInsidet)
end

function Game_Equip1:showEquipIcons(nIndex, tbCard, CSV_CardBase,levelAnimationFlag)
	if not nIndex then return end
	local wndInstance = g_WndMgr:getWnd("Game_Equip1")
	if wndInstance then
		local Image_CardInfoPNL = wndInstance.rootWidget:getChildByName("Image_CardInfoPNL")
		local Image_Equip = Image_CardInfoPNL:getChildByName("Image_Equip"..nIndex)
		local Image_DefaultEquip = tolua.cast(Image_Equip:getChildByName("Image_DefaultEquip"), "ImageView")
		local Image_Add = tolua.cast(Image_DefaultEquip:getChildByName("Image_Add"), "ImageView")
		local ImageEuipeIcon = tolua.cast(Image_Equip:getChildByName("ImageEuipeIcon"), "ImageView")
		
		local nEquipID = tbCard:getEquipIDByPos(nIndex)

		if nEquipID > 0 then --有装备
			
			local tbEquip =  g_Hero:getEquipObjByServID(nEquipID)
			if not tbEquip then return end
			local tbEquipBase = tbEquip:getCsvBase()
			Image_DefaultEquip:setVisible(false)

			ImageEuipeIcon:setVisible(true)
			
			local rLevel = tbEquip:getRefineLev()
			--装备星级
			local Image_RefineLevel  =  tolua.cast(ImageEuipeIcon:getChildByName("Image_RefineLevel"), "ImageView")
			Image_RefineLevel:setVisible(false)
			if rLevel > 0 then 
				Image_RefineLevel:loadTexture(getUIImg("Icon_StarLevel"..rLevel))
				Image_RefineLevel:setVisible(true)
			end
			
			local Image_Icon = tolua.cast(ImageEuipeIcon:getChildByName("Image_Icon"), "ImageView")
			Image_Icon:loadTexture(getIconImg(tbEquipBase.Icon))
			
			local BitmapLabel_StrengthenLevel = tolua.cast(ImageEuipeIcon:getChildByName("BitmapLabel_StrengthenLevel"), "LabelBMFont")
			BitmapLabel_StrengthenLevel:setFntFile(getEquipLevFont(tbEquipBase.ColorType))
			BitmapLabel_StrengthenLevel:setText(_T("Lv.")..tbEquip:getStrengthenLev())

			
			--是否播放等级升级动画
			local armature, userAnimation = nil,nil;
			if levelAnimationFlag then 
				armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("QiShuLevelUp", nil, nil, 5)
				armature:setPositionXY(0, 5)
				ImageEuipeIcon:getParent():addNode(armature, 100)
			end
			local imageName = "FrameEquipCircle";
			local pos = ccp(50, 50);
			local playIndex = 1;
			if nIndex <= 2 then
				imageName = "FrameEquipBig"
				pos = ccp(50, 90);
				playIndex = 2;
			end
			
			if userAnimation then
				userAnimation:playWithIndex(playIndex)
			end
			g_addUpgradeGuide(ImageEuipeIcon, pos, nil, g_CheckEquipUpgrade(tbEquip))
			ImageEuipeIcon:loadTexture(getUIImg(imageName..tbEquipBase.ColorType))

			ImageEuipeIcon:getParent():setTag(nEquipID)
		else--无装备
			if nIndex == 1 then
			   Image_DefaultEquip:loadTexture(getCardImg("Frame_Equip_DefaultEquip"..CSV_CardBase.Profession))
			end
			Image_DefaultEquip:setOpacity(50)
			Image_DefaultEquip:setVisible(true)
			local bHaveEquip = nil
			local tbEquip = g_Hero:getUndressEquipList()
			for i=1, #tbEquip do
				local tbEquipBase = tbEquip[i]:getCsvBase()
				 if tbEquipSubType[tbEquipBase.SubType] == nIndex then
					if wndInstance:checkEquipLev(tbEquipBase.NeedLevel) and  (nIndex > 1 or wndInstance:checkEquip(tbEquipBase.SubType)) then
						bHaveEquip = true
						break
					end
				end
			end

			if bHaveEquip then
			   Image_Add:setVisible(true)
			else
			   Image_Add:setVisible(false)
			end

			ImageEuipeIcon:setVisible(false)
			ImageEuipeIcon:getParent():setTag(-nIndex)
		end
	end
end

function Game_Equip1:registerPageViewEvent()
	local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
    local function turningFunction(widget, nIndex)
		g_CurrentPageViewCardIndex = nIndex
		self.CurrentPageViewCardIndex = nIndex
        local tbCard = g_Hero:getCardsInfoByIndex(nIndex)
        if tbCard then
            local CSV_CardBase = tbCard:getCsvBase()
            self.nCardID = tbCard:getServerId()
			self.Label_Name:setText(tbCard:getNameWithSuffix(self.Label_Name))
			
			local AtlasLabel_StarLevel = tolua.cast(Image_CardInfoPNL:getChildByName("AtlasLabel_StarLevel"), "LabelAtlas")
            AtlasLabel_StarLevel:setStringValue(g_tbStarLevel[tbCard:getStarLevel()])
            self.BitmapLabel_PersonalStrength:setText(tostring(tbCard:getCardStrength()))

            --设置装备Icon
            for i=1, 6 do
                self:showEquipIcons(i, tbCard, CSV_CardBase)
            end

            if self.ckEquip:getCheckIndex()== 2 then
                self:setImage_CardDetailPNL()
            end
			
			local tbSoundFileSuffix = string.split(CSV_CardBase.DialogueSound, "|")
			local nMax = #tbSoundFileSuffix
			local nSoundIndex = math.random(1, nMax)
			g_playSoundEffect("Sound/Dialogue/"..CSV_CardBase.SpineAnimation.."_"..tbSoundFileSuffix[nSoundIndex]..".mp3")
			
			local Image_ListViewLight = tolua.cast(self.Image_CardDetailPNL:getChildByName("Image_ListViewLight"), "ImageView")
			local Image_ListViewLightChar = tolua.cast(Image_ListViewLight:getChildByName("Image_ListViewLightChar"), "ImageView")
			if tbCard:checkIsLeader() then
				Image_ListViewLightChar:setVisible(false)
			else
				Image_ListViewLightChar:setVisible(true)
			end
			g_CreateScaleInOutAction(Image_ListViewLightChar)
        end
    end

    local function updateFunction(Panel_CardPage, nIndex)
        local tbCard = g_Hero:getCardsInfoByIndex(nIndex)
        if tbCard and Panel_CardPage and Panel_CardPage:isExsit() then
			local CSV_CardBase = tbCard:getCsvBase()
			local Panel_Card = tolua.cast(Panel_CardPage:getChildByName("Panel_Card"), "Layout")
			local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView")
			local CCNode_Skeleton =  g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1)
			Image_Card:removeAllNodes()
			Image_Card:loadTexture(getUIImg("Blank"))
			Image_Card:setPositionXY(CSV_CardBase.Pos_X*Panel_Card:getScale()/0.6, CSV_CardBase.Pos_Y*Panel_Card:getScale()/0.6)
            Image_Card:addNode(CCNode_Skeleton)
            g_runSpineAnimation(CCNode_Skeleton, "idle", true)
        end
    end

    self.LuaPageView_Card:registerClickEvent(turningFunction)
    self.LuaPageView_Card:registerUpdateFunction(updateFunction)
end

--装备背包
function Game_Equip1:registerListViewEvent()

    local function updateFunction(Panel_EuipeRow, nIndex)
		local tbEquip = g_Hero:getUndressEquipList()
        local nLen = #tbEquip
        local nBegin = (nIndex-1)*4
        for i =1, 4 do
            local nCurIndex = nBegin + i
            local tbCurEquip = tbEquip[nCurIndex]
            local Button_EquipIconBase = Panel_EuipeRow:getChildByName("Button_EquipIconBase"..i)
            Button_EquipIconBase:removeAllChildren()
            Button_EquipIconBase:addTouchEventListener(onClickEquipIcon)
            if tbCurEquip then
                local Image_PackageIconEquip = tolua.cast(g_WidgetModel.Image_PackageIconEquip:clone(), "ImageView")
				Image_PackageIconEquip:setScale(0.9)
                Button_EquipIconBase:addChild(Image_PackageIconEquip)

                Image_PackageIconEquip:loadTexture(getFrameBackGround(tbCurEquip:getColorType()))

                local Image_Icon = tolua.cast(Image_PackageIconEquip:getChildByName("Image_Icon"), "ImageView")
				Image_Icon:loadTexture(getIconImg(tbCurEquip:getCsvBase().Icon))

				equipSacleAndRotate(Image_Icon, tbCurEquip:getCsvBase().SubType)

                local widgetFrame = tolua.cast(Image_PackageIconEquip:getChildByName("Image_Frame"), "ImageView")
                widgetFrame:loadTexture(getIconFrame(tbCurEquip:getColorType()))
				
				local BitmapLabel_StrengthenLevel = tolua.cast(Image_PackageIconEquip:getChildByName("BitmapLabel_StrengthenLevel"), "LabelBMFont")
				BitmapLabel_StrengthenLevel:setFntFile(getEquipLevFont(tbCurEquip:getCsvBase().ColorType))
				BitmapLabel_StrengthenLevel:setText(_T("Lv.")..tbCurEquip:getStrengthenLev())
				
				local Image_Star = tolua.cast(Image_PackageIconEquip:getChildByName("Image_Star"), "ImageView")
				Image_Star:setVisible(tbCurEquip:getRefineLev() > 0)
				
				local BitmapLabel_RefineLevel = tolua.cast(Image_Star:getChildByName("BitmapLabel_RefineLevel"), "LabelBMFont")
				BitmapLabel_RefineLevel:setText(tbCurEquip:getRefineLev())
				BitmapLabel_RefineLevel:setVisible(tbCurEquip:getRefineLev() > 0)
				
                Button_EquipIconBase:setTag(tbCurEquip:getServerId())
            else
                Button_EquipIconBase:setTag(0)
            end
        end
    end

    self.LuaListView_EquipPackage:setModel(g_WidgetModel.PanelEuipeRow:clone())
    self.LuaListView_EquipPackage:setUpdateFunc(updateFunction)
end

function Game_Equip1:closeWnd()
	self.turning = nil
    self.nCardID = nil
    self.nCardPackageID = nil
    self.nCardDetailID = nil
	self.oldData = nil
	
	g_Timer:destroyTimerByID(self.EvoluteTimerId)
	self.EvoluteTimerId = nil
	g_Timer:destroyTimerByID(self.StarUpTimerId)
	self.StarUpTimerId = nil

	g_FormMsgSystem:UnRegistFormMsg(FormMsg_Compose_Strength)
end

function Game_Equip1:destroyWnd()
end

function Game_Equip1:setEquipIcon()
    local tbCardsAmmount = g_Hero:getCardsAmmount()
    self.LuaPageView_Card:updatePageView(tbCardsAmmount)
end

function Game_Equip1:setEquipPackage()
    g_Hero:calculateUndressEquipNum()
    local tbUndressEquipList = g_Hero:getUndressEquipList()
    local nLen = math.floor((#tbUndressEquipList+3)/4)
	-- echoj("vmath.max(10, nLen==========",math.max(10, nLen))
    self.LuaListView_EquipPackage:updateItems(math.max(10, nLen))
end


--[[
	突破
]]
function Game_Equip1:refreshEvoluteWnd(tbMsg)
	local nCardID = tbMsg.breach_cardid
	local nEvoluteLevel = tbMsg.breach_breachlv
	local nUpdateMoney = tbMsg.updated_money

	local tbCard = g_Hero:getCardObjByServID(nCardID)
	if not tbCard then return end

    local nOldStrengh =  tbCard:getCardStrength()
	--将升星前的属性保存
	local tbParams = {
		StarLevel_Source = tbCard:getStarLevel(), --星级
		EvoluteLevel = tbCard:getEvoluteLevel(), --突破等级
		EvoluteSuffix = tbCard:getEvoluteSuffix(), --突破等级后缀
		HpMax_Source = tbCard:getHPMax(), --生命
		ForcePoints_Source = tbCard:getForcePoints(),--武力
		MagicPoints_Source = tbCard:getMagicPoints(),--法术
		SkillPoints_Source = tbCard:getSkillPoints(),--绝技
	}

	cclog(" =======Game_Equip1:refreshEvoluteWnd============")

	tbCard:setEvoluteLevel(nEvoluteLevel)
	g_Hero:setCoins(nUpdateMoney)

    local tbCard = g_Hero:getCardObjByServID(self.nCardID)

	tbParams.tbCardTarget = tbCard
	tbParams.StarLevel_Target = tbCard:getStarLevel()
	tbParams.EvoluteLevel_Target = tbCard:getEvoluteLevel()
	tbParams.HPMax_Target = tbCard:getHPMax()
	tbParams.ForcePoints_Target = tbCard:getMagicPoints()
	tbParams.MagicPoints_Target = tbCard:getForcePoints()
	tbParams.SkillPoints_Target = tbCard:getSkillPoints()

	local function refreshWnd()
		local wndInstance = g_WndMgr:getWnd("Game_Equip1")
		if wndInstance then
			wndInstance.Label_Name:setText(tbCard:getNameWithSuffix(wndInstance.Label_Name))
			wndInstance.EvoluteTimerId = g_CreatePropDynamic(wndInstance.BitmapLabel_PersonalStrength, 0.75, nOldStrengh, tbCard:getCardStrength(), "%d", g_getColor(ccs.COLOR.LIME_GREEN), g_getColor(ccs.COLOR.WHITE))

			wndInstance.nCardDetailID = nil
			wndInstance:setImage_CardDetailPNL()
		end
	end

	--如果是出战伙伴则需要播放战斗力提升动画
	if tbCard:checkIsInBattle() then
		g_ShowUpgradeEventAnimation(2, 1, tbParams, handler(g_Hero, g_Hero.showTeamStrengthGrowAnimation), refreshWnd)
	else
		g_ShowUpgradeEventAnimation(2, 1, tbParams, nil, refreshWnd)
	end
	
	self.ckEquip:Click(self.ckEquip:getCheckIndex())
	
end

--升星
function Game_Equip1:showStarUpResponse(tbMsgDetail)
	local nCardID = tbMsgDetail.card_id
	local nStarLevel = tbMsgDetail.star_lv
	local nRemainHunPoID = tbMsgDetail.remain_hunpo_id
	local nRemainHunPoNum = tbMsgDetail.remain_hunpo_num
	local nRemainMaterialID = tbMsgDetail.remain_replace_id
	local nRemainMaterialNum = tbMsgDetail.remain_replace_num
	
	if nRemainHunPoID and nRemainHunPoNum then
		g_Hero:setHunPoNum(nRemainHunPoID, nRemainHunPoNum)
	end
	
	if nRemainMaterialID and nRemainMaterialNum then
		g_Hero:setItemNum(nRemainMaterialID, nRemainMaterialNum)
	end

	local tbCard = g_Hero:getCardObjByServID(nCardID)
	if not tbCard then return end

    local nOldStrengh = tbCard:getCardStrength()
	--将升星前的属性保存
	local tbParams = {
		StarLevel_Source = tbCard:getStarLevel(), --星级
		EvoluteLevel = tbCard:getEvoluteLevel(), --突破等级
		EvoluteSuffix = tbCard:getEvoluteSuffix(), --突破等级后缀
		HpMax_Source = tbCard:getHPMax(), --生命
		ForcePoints_Source = tbCard:getForcePoints(),--武力
		MagicPoints_Source = tbCard:getMagicPoints(),--法术
		SkillPoints_Source = tbCard:getSkillPoints(),--绝技
	}
	--设置伙伴星级
	tbCard:setStarLevel(nStarLevel)

	--升星动画
	local tbCard = g_Hero:getCardObjByServID(self.nCardID)
	local CSV_CardBase = tbCard:getCsvBase()

	local value = g_Hero:getHunPoObj(tbCard.nCsvID)
	local nHaveNum  = 0
	if value then
		nHaveNum = value.nNum or 0
	end
	local ListView_CardInfo = tolua.cast( self.Image_CardDetailPNL:getChildByName("ListView_CardInfo"), "ListView")
	local Image_StarUpPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_StarUpPNL"), "ImageView")
	local Image_HunPoNumBase = tolua.cast(Image_StarUpPNL:getChildByName("Image_HunPoNumBase"),"ImageView")
	local ProgressBar_HunPoNumPercent = tolua.cast(Image_HunPoNumBase:getChildByName("ProgressBar_HunPoNumPercent"),"LoadingBar")
	ProgressBar_HunPoNumPercent:setPercent(nHaveNum * 100 / CSV_CardBase.StarUpHunPoNum)
	
	tbParams.tbCardTarget = tbCard
	
	local Image_CardInfoPNL = self.rootWidget:getChildByName("Image_CardInfoPNL")
	
	local function refreshWnd()
		local AtlasLabel_StarLevel = tolua.cast(Image_CardInfoPNL:getChildByName("AtlasLabel_StarLevel"), "LabelAtlas")
		AtlasLabel_StarLevel:setStringValue(g_tbStarLevel[nStarLevel])
		
		self.StarUpTimerId = g_CreatePropDynamic(self.BitmapLabel_PersonalStrength, 0.75, nOldStrengh, tbCard:getCardStrength(), "%d", g_getColor(ccs.COLOR.LIME_GREEN), g_getColor(ccs.COLOR.WHITE))

		self.nCardDetailID = nil
		self:setImage_CardDetailPNL()
	end

	--如果是出战伙伴则需要播放战斗力提升动画
	if tbCard:checkIsInBattle() then
		g_ShowUpgradeEventAnimation(2, 2, tbParams, handler(g_Hero, g_Hero.showTeamStrengthGrowAnimation), refreshWnd)
	else
		g_ShowUpgradeEventAnimation(2, 2, tbParams, nil, refreshWnd)
	end
	
	self.ckEquip:Click(self.ckEquip:getCheckIndex())
end

function Game_Equip1:calcCardIndex(nCardID)
	local nIndex = 1
	while true do
        local tbCard = g_Hero:getCardsInfoByIndex(nIndex)
        if not tbCard then
            break
        end
        if tbCard:getServerId() == nCardID then
            break
        end
        nIndex = nIndex + 1
    end
	g_CurrentPageViewCardIndex = nIndex
    self.LuaPageView_Card:setCurPageIndex(nIndex)
end

--打开界面调用
function Game_Equip1:openWnd(tbCardID)

    if g_bReturn then
        self.nCardDetailID = nil
        self.nCardPackageID = nil
		--传承
		if CHANG_CHENG_S then 
			self.ckEquip:Click(self.ckEquip:getCheckIndex())
			local tbCard = g_Hero:getCardObjByServID(self.nCardID)
			if tbCard  then  
				local CSV_CardBase = tbCard:getCsvBase()
				for i = 1,6 do
					self:showEquipIcons(i,tbCard,CSV_CardBase)
				end
			end
			if tbCard and self.BitmapLabel_PersonalStrength then 
				self.BitmapLabel_PersonalStrength:setText(tostring(tbCard:getCardStrength()))
			end
			CHANG_CHENG_S = false
		end
		--记录是否渡劫成功了 
		if  DU_JIE_S then
			self.ckEquip:Click(self.ckEquip:getCheckIndex())
			local tbCard = g_Hero:getCardObjByServID(self.nCardID)	
			if tbCard and self.BitmapLabel_PersonalStrength then 
				self.BitmapLabel_PersonalStrength:setText(tostring(tbCard:getCardStrength()))
			end
			DU_JIE_S = false
		end
		
		--记录是否打开过妖兽界面
		if YI_SHOU_S then 
			self.ckEquip:Click(self.ckEquip:getCheckIndex())
			local tbCard = g_Hero:getCardObjByServID(self.nCardID)
			
			if tbCard and self.BitmapLabel_PersonalStrength then 
				self.BitmapLabel_PersonalStrength:setText(tostring(tbCard:getCardStrength()))
			end
			YI_SHOU_S = false
		end
		
		--记录丹药界面
		if DAN_YAO_S then
			self.ckEquip:Click(self.ckEquip:getCheckIndex())
			local tbCard = g_Hero:getCardObjByServID(self.nCardID)
			if tbCard and  self.BitmapLabel_PersonalStrength then 
				self.BitmapLabel_PersonalStrength:setText(tostring(tbCard:getCardStrength()))
			end
			DAN_YAO_S = false
		end
		
		return 
	end    
	
	if not tbCardID then--来自装备界面
		g_CurrentPageViewCardIndex = 1
		self.LuaPageView_Card:setCurPageIndex(g_CurrentPageViewCardIndex)
		self:setEquipIcon()
		self.ckEquip:Click(1)
	else
		self.nCardID = tbCardID.nCardID
		self:calcCardIndex(tbCardID.nCardID)
		self:setEquipIcon()
		self.ckEquip:Click(2)
	end

	g_Hero:calcCurBattlePower()
end

function Game_Equip1:updateFromMsg()
    local tbCard = g_Hero:getCardObjByServID(self.nCardID)
	local ListView_CardInfo = self.Image_CardDetailPNL:getChildByName("ListView_CardInfo")
	local CSV_CardBase = tbCard:getCsvBase()
	setImage_SkillInfoPNL(ListView_CardInfo, tbCard, CSV_CardBase)
end

function Game_Equip1:requeStrengthOneKeyAllRequest(cardid)
	--一键强化卡牌身上的装备
	local msg = zone_pb.StrengthOneKeyAllRequest()
	msg.cardid = cardid
	g_MsgMgr:sendMsg(msgid_pb.MSGID_EQUIP_STRENGTHEN_ALL_REQUEST, msg)
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_EQUIP_STRENGTHEN_ALL_REQUEST) 
end

function Game_Equip1:requeStrengthOneKeyAllResponse(tbMsg)
	cclog("================一键强化卡牌身上的装备返回==========")
	local msgDetail = zone_pb.StrengthOneKeyAllResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	tostring(msgDetail)
	
	local changedList = msgDetail.changed_list 	-- 改变的列表
	local updatedMoney = msgDetail.updated_money -- 剩余铜钱
	if #changedList <= 0 then  return end 
	g_Hero:setCoins(updatedMoney)
	
	local tbCard = g_Hero:getCardObjByServID(self.nCardID)
	if not tbCard or tbCard == nil then return end
	
	local CSV_CardBase = tbCard:getCsvBase()
	local pos = 0
	for i = 1,#changedList do 
		local pos =  changedList[i].pos + 1 							-- 装备的位置,0开始
		local equipId = changedList[i].equip_id 					-- 装备id
		local strengthLv = changedList[i].strength_lv 				--最终强化等级
		local tbMainEquip = g_Hero:getEquipObjByServID(equipId)
		tbMainEquip:setStrengthenLev(strengthLv)
		self:showEquipIcons(pos, tbCard, CSV_CardBase,true)
	end

	self.nCardDetailID = nil
	self:setImage_CardDetailPNL()
		
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_Equip1") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end

	self.BitmapLabel_PersonalStrength:setText(tostring(tbCard:getCardStrength()))
	if self.ckEquip:getCheckIndex() == 2 then 
		self.ckEquip:Click(2)
	end

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_EQUIP_STRENGTHEN_ALL_REQUEST, msgid_pb.MSGID_EQUIP_STRENGTHEN_ALL_RESPONSE)
end

--[[
	更新选择的装备
	强化，合成，升星，出售，卸下 
]] 
function Game_Equip1:updateEquipIcon()

	local wndInstance = g_WndMgr:getWnd("Game_Equip1")
	if wndInstance then
		--卡牌详细信息
		if wndInstance.ckEquip:getCheckIndex() == 2 then
			if not self.nCardID then return end 
			local GameObj_Card = g_Hero:getCardObjByServID(self.nCardID)
			local CSV_CardBase = GameObj_Card:getCsvBase()
			if not wndInstance.Image_CardDetailPNL then return end 
			local ListView_CardInfo = tolua.cast(wndInstance.Image_CardDetailPNL:getChildByName("ListView_CardInfo"), "ListView")
			setImage_LevelPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
			setImage_BasePropPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
			setImage_SkillInfoPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
			setImage_StarUpPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
			setImage_RealmPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
			setImage_FatePNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
			setImage_ProfessionInfoPNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
			setImage_PropDetailBasePNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
			setImage_PropDetailRatePNL(ListView_CardInfo, GameObj_Card, CSV_CardBase)
			
			setImage_CardGroupPNL(ListView_CardInfo, CSV_CardBase)
		else	
			--装备背包
			wndInstance:setEquipPackage() 
		end
		
		--刷新装备位置的状态
		local tbCard = g_Hero:getCardObjByServID(self.nCardID)
		if tbCard then  
			local CSV_CardBase = tbCard:getCsvBase()
			for nIndex = 1, 6 do
				wndInstance:showEquipIcons(nIndex,tbCard,CSV_CardBase)
			end
		end
		wndInstance.BitmapLabel_PersonalStrength:setText(tostring(tbCard:getCardStrength()))
		
	end
end

function Game_Equip1:refrehWnd(tbCard, nPos)
	
    if tbCard then
		local CSV_CardBase = tbCard:getCsvBase()
        self:showEquipIcons(nPos, tbCard, CSV_CardBase)
        self.BitmapLabel_PersonalStrength:setText(tostring(tbCard:getCardStrength()))
		self.nCardDetailID = nil
		
		self:setImage_CardDetailPNL()
		if self.ckEquip:getCheckIndex() == 1 then 
			self:setEquipPackage()
		end
    end
end

function Game_Equip1:UpdatefightingCapacity(context)
	if context and self.BitmapLabel_PersonalStrength and  self.BitmapLabel_PersonalStrength:isExsit() then
		self.BitmapLabel_PersonalStrength:setText(context.nend)
	end
end

function Game_Equip1:requestDecomposeCard(nCardID)
	cclog("================requestDecomposeCard=================")
	local tbMsg = zone_pb.DecomposeCardRequest()
	tbMsg.card_id = nCardID
	g_MsgMgr:sendMsg(msgid_pb.MSGID_DECOMPOSE_CARD_REQUEST, tbMsg)
end

function Game_Equip1:requetDecomposeCardResponse(tbMsg)
	cclog("================requetDecomposeCardResponse=================")
	local tbMsgDetail = zone_pb.DecomposeCardResponse()
	tbMsgDetail:ParseFromString(tbMsg.buffer)
	tostring(tbMsgDetail)
	g_Hero:decomposeCardSucc(tbMsgDetail.card_id)
	
	if g_CurrentPageViewCardIndex then
		self.LuaPageView_Card:setCurPageIndex(g_CurrentPageViewCardIndex-1)
		self:setEquipIcon()
	else
		self.LuaPageView_Card:setCurPageIndex(1)
		self:setEquipIcon()
	end
	
	if self.ckEquip:getCheckIndex() == 1 then
		self.ckEquip:Click(self.ckEquip:getCheckIndex())
	end
end



