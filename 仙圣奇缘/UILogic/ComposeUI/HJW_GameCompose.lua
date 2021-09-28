--------------------------------------------------------------------------------------
-- 文件名:	Game_Compose.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	技能（丹药）合成界面
-- 应  用:  
---------------------------------------------------------------------------------------
Game_Compose = class("Game_Compose")
Game_Compose.__index = Game_Compose

local typeName ={
	_T("生命上限"), _T("物理攻击"), _T("物理防御"), _T("生命上限") , _T("法术攻击"),
	_T("法术防御"), _T("生命上限"), _T("绝技攻击"), _T("绝技防御")
}

function Game_Compose:initWnd()
	--请求一次精英副本的数据
	if g_EctypeJY:isInit() then 
		g_EctypeJY:requestJYInfo()
	end
	--一键升级丹药响应
	local order = msgid_pb.MSGID_ONCE_LVUP_DANYAO_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestOnceComPoseDanYaoResponse))		
	if not self.rootWidget then return end
	local Image_ComposePNL = tolua.cast(self.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
	local Image_SkillEolutePNL = tolua.cast(Image_ComposePNL:getChildByName("Image_SkillEolutePNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_SkillEolutePNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_LevelUp = tolua.cast(Image_ContentPNL:getChildByName("Button_LevelUp"), "Button")
	local Image_Check = tolua.cast(Button_LevelUp:getChildByName("Image_Check"), "ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteCheck, 4)
	
	local Image_TruePNL = tolua.cast(Button_LevelUp:getChildByName("Image_TruePNL"), "ImageView")
	local BitmapLabel_FuncName = tolua.cast(Image_TruePNL:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
	local Image_Coins = tolua.cast(Image_TruePNL:getChildByName("Image_Coins"), "ImageView")
	g_AdjustWidgetsPosition({BitmapLabel_FuncName, Image_Coins})
	
	local Image_SkillMaterialPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_SkillMaterialPNL"), "ImageView")
	local Image_Light = tolua.cast(Image_SkillMaterialPNL:getChildByName("Image_Light"), "ImageView")
	Image_Light:removeAllNodes()
	
	local armatureLight, animationLight = g_CreateCoCosAnimationWithCallBacks("DanYaoLevelUp", nil, nil, 2, nil, true)
	armatureLight:setPosition(ccp(0,0))
	armatureLight:setScale(2)
	animationLight:playWithIndex(0)
	Image_Light:addNode(armatureLight, 0)
	self.armatureLight = armatureLight
	self.animationLight_ = animationLight
	for i = 1,3 do
		local Button_MaterialBase = tolua.cast(Image_SkillMaterialPNL:getChildByName("Button_MaterialBase"..i), "Button")
		local Image_Arrow = tolua.cast(Button_MaterialBase:getChildByName("Image_Arrow"), "ImageView")
		Image_Arrow:removeAllNodes()
		local armatureArrow, animationArrow = g_CreateCoCosAnimationWithCallBacks("DanYaoArrow", nil, nil, 2, nil, true)
		armatureArrow:setPosition(ccp(0,-20))
		Image_Arrow:addNode(armatureArrow, 0)
		animationArrow:playWithIndex(0)
	end
	
	local Image_MaterialPNL = tolua.cast(Image_ComposePNL:getChildByName("Image_MaterialPNL"), "ImageView")
	for i = 1,2 do
		local Image_ComposeNodePNL = tolua.cast(Image_MaterialPNL:getChildByName("Image_ComposeNodePNL"..i), "ImageView")
		local Button_Compose = tolua.cast(Image_ComposeNodePNL:getChildByName("Button_Compose"), "Button")
		local Image_Check = tolua.cast(Button_Compose:getChildByName("Image_Check"), "ImageView")
		local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
		g_SetBlendFuncSprite(ccSpriteCheck, 4)
	end
	
	local Image_ComposeTreePNL = tolua.cast(Image_MaterialPNL:getChildByName("Image_ComposeTreePNL"), "ImageView")
	for i = 1, 3 do
		local Button_TreeNode = tolua.cast(Image_ComposeTreePNL:getChildByName("Button_TreeNode"..i), "Button")
		local Image_Check = tolua.cast(Button_TreeNode:getChildByName("Image_Check"), "ImageView")
		local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
		g_SetBlendFuncSprite(ccSpriteCheck, 4)
	end

end

function Game_Compose:openWnd(param)

	if self.ectypeList_  then 	
		self:ectypeListShow(self.ectypeList_, ITEM_DROP_TYPE.PILL)
	end
	
	if not param then return end	

	
	self.formula_ = {}
	self.iconModeItem_ = {}
	if not self.rootWidget then return end
	local Image_ComposePNL = tolua.cast(self.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
	local Image_SkillEolutePNL = tolua.cast(Image_ComposePNL:getChildByName("Image_SkillEolutePNL"), "ImageView")
	Image_SkillEolutePNL:setTouchEnabled(true)
	Image_SkillEolutePNL:setPositionX(-270)
	
	self.tbCardData_ = param 
	self:activateUI()
	
	self.danYaoIndex_ = 1
	local tbCard = self.tbCardData_
	local skillIndex = tbCard.skillIndex --技能索引 
	local skillID = tbCard.ID --技能id
	local tbCardInfo = tbCard.cardInfo 
	local bLevel = tbCardInfo:getEvoluteLevel()--突破等级
	local tbDanyaoLv =  tbCardInfo:getDanyaoLvList() --丹药等级
	local tbDanyaoLevel = tbDanyaoLv[skillIndex]
	
	local danyaoLevel = tbDanyaoLevel[1]
	if danyaoLevel < bLevel then 
		danyaoLevel = bLevel 
	end 
	
	local cardEvoluteSkillCondition = g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition",skillID)
	local danyaoId = cardEvoluteSkillCondition["NeedDanYaoID1"]

	local cardEvoluteDanYao = g_DataMgr:getCsvConfigByTwoKey("CardEvoluteDanYao",danyaoId,danyaoLevel)
	
	local function upCompoundUI()
		self:compoundUI(cardEvoluteDanYao)
	end
	
	upCompoundUI()
	
	local frameColor = tbCardInfo:getSkillColorType(skillIndex)
	local icon = self:tipDanYaoIcon(frameColor,skillID,1,danyaoLevel)
	self:tipIndicate(1,icon,upCompoundUI)

end

function Game_Compose:closeWnd()
	--清零 不记录丹药星级品质
	g_ItemDropGuildFunc:setDanYaoStar(0)
end

function Game_Compose:itemDropGuide()
	
	local mapId = g_ItemDropGuildFunc:getClickMapID()
	local nTag = g_ItemDropGuildFunc:getClickTag()

	local tbParam = {
		nMapCsvID = mapId ,
		nEctypeCsvID = nTag,
	}

	if mapId == 1 then 
		local strClassName = "Game_SelectGameLevel1"
		g_WndMgr:showWnd(strClassName,tbParam)
	elseif mapId == 2 then 
		local strClassName = "Game_SelectGameLevel2"
		g_WndMgr:showWnd(strClassName,tbParam)
	else
		g_WndMgr:showWnd("Game_SelectGameLevel3",tbParam)
	end
end

----------------------------激活丹药----------------------------------
function Game_Compose:activateUI()
	local tbCard = self.tbCardData_
	local skillIndex = tbCard.skillIndex --技能索引 
	-- local skillName = tbCard.name	--技能名称
	local skillID = tbCard.ID --技能id
	local icon = tbCard.icon 
	
	if not self.rootWidget then return end 
	
	local tbCardInfo = tbCard.cardInfo 
	if not tbCardInfo then return end 
	
	local bLevel = tbCardInfo:getEvoluteLevel()--突破等级
	local frameColor = tbCardInfo:getSkillColorType(skillIndex)
	local skillLevel =  tbCardInfo:getSkillLevel(skillIndex) --技能等级
	local maxDanyaoLevel = tbCardInfo:getDanyaoMaxLevel()
	
	local nCardID = tbCardInfo:getServerId()--伙伴Id
		
	local tbDanyaoLv =  tbCardInfo:getDanyaoLvList() --丹药等级
	local tbDanyaoLevel = tbDanyaoLv[skillIndex]
	local cardEvoluteSkillCondition = g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition",skillID)
	
	local Image_ComposePNL = tolua.cast(self.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
	local Image_SkillEolutePNL = tolua.cast(Image_ComposePNL:getChildByName("Image_SkillEolutePNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_SkillEolutePNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Image_SkillMaterialPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_SkillMaterialPNL"),"ImageView")

	--技能图案 大按钮
	local Button_SkillBase = tolua.cast(Image_SkillMaterialPNL:getChildByName("Button_SkillBase"),"Button")
	
	local function onClick_Button_SkillBase(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local CSV_SkillBase = g_DataMgr:getSkillBaseCsv(skillID)
			local tbString = {}
			local tbSkillDesc = {}
			table.insert(tbSkillDesc, CSV_SkillBase.Name)
			table.insert(tbString, tbSkillDesc)

			tbSkillDesc = {}
			table.insert(tbSkillDesc, CSV_SkillBase.Desc)
			table.insert(tbString,tbSkillDesc)
		
			local tbPos = pSender:getWorldPosition()
			tbPos.x = tbPos.x
			tbPos.y = tbPos.y
			g_ClientMsgTips:showTip(tbString, tbPos, 5)
		end
	end
	
	Button_SkillBase:setTouchEnabled(true)
	Button_SkillBase:addTouchEventListener(onClick_Button_SkillBase)
	
	--技能图案 大按钮 底图
	local Image_ColorBase = tolua.cast(Button_SkillBase:getChildByName("Image_ColorBase"),"ImageView")
	Image_ColorBase:loadTexture(getUIImg("Frame_Evolute_DanYaoBase"..frameColor))
		
	local Image_MaterialFrame = tolua.cast(Image_ColorBase:getChildByName("Image_MaterialFrame"),"ImageView")
	Image_MaterialFrame:loadTexture(getUIImg("Frame_Evolute_DanYaoFrame"..frameColor))
	
	--技能图案
	local Panel_SkillIcon = tolua.cast(Image_ColorBase:getChildByName("Panel_SkillIcon"), "Layout")
	Panel_SkillIcon:setClippingEnabled(true)
	Panel_SkillIcon:setRadius(43)
	local Image_SkillIcon = tolua.cast(Panel_SkillIcon:getChildByName("Image_SkillIcon"), "ImageView")
	Image_SkillIcon:loadTexture(getIconImg(icon))

	local function materialOnTouch(pSender, tag)
		CGuidTips:removeFromParent()
		if skillLevel >= maxDanyaoLevel then  cclog("丹药到最高等级了") return end
		
		local wndInstance = g_WndMgr:getWnd("Game_Compose")
		if wndInstance and wndInstance.rootWidget then
			local Image_ComposePNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
			local Image_SkillEolutePNL = tolua.cast(Image_ComposePNL:getChildByName("Image_SkillEolutePNL"), "ImageView")
			local Image_ContentPNL = tolua.cast(Image_SkillEolutePNL:getChildByName("Image_ContentPNL"),"ImageView")
			local Image_SkillMaterialPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_SkillMaterialPNL"),"ImageView")
			
			for i = 1,3 do
				local Button_MaterialBase = tolua.cast(Image_SkillMaterialPNL:getChildByName("Button_MaterialBase"..i),"Button") 
				local Image_Check = tolua.cast(Button_MaterialBase:getChildByName("Image_Check"),"ImageView") 
				Image_Check:setVisible(false)
			end
			
			local Image_Check = tolua.cast(pSender:getChildByName("Image_Check"),"ImageView") 
			Image_Check:setVisible(true)
			g_CreateFadeInOutAction(Image_Check, 0.75, 100, 0.5)

			local danyaoLevel = tbDanyaoLevel[tag]
			if danyaoLevel < bLevel then danyaoLevel = bLevel end

			local function upCompoundUI()
				local danyaoId = cardEvoluteSkillCondition["NeedDanYaoID"..tag]
				local cardEvoluteDanYao = g_DataMgr:getCsvConfigByTwoKey("CardEvoluteDanYao",danyaoId,danyaoLevel)
				g_ItemDropGuildFunc:setDanYaoStar(cardEvoluteDanYao.ItemStarLevel1)
				wndInstance.danYaoIndex_ = tag
				wndInstance:compoundUI(cardEvoluteDanYao)
				
			end
			
			local icon = wndInstance:tipDanYaoIcon(frameColor,skillID,tag,danyaoLevel)
			wndInstance:tipIndicate(1,icon,upCompoundUI)
			upCompoundUI()
		end
	end
	
	for i = 1,3 do
		local danyaoLevel = tbDanyaoLevel[i]
		if danyaoLevel < bLevel then danyaoLevel = bLevel end 
		local danyaoId = cardEvoluteSkillCondition["NeedDanYaoID"..i] --第几个丹药
	
		local cardEvoluteDanYao = g_DataMgr:getCsvConfigByTwoKey("CardEvoluteDanYao",danyaoId,danyaoLevel)
		
		local Button_MaterialBase = tolua.cast(Image_SkillMaterialPNL:getChildByName("Button_MaterialBase"..i),"Button") 
		g_SetBtnWithGuideCheck(Button_MaterialBase, i, materialOnTouch, true, nil, nil, nil)
		
		local Image_Check = tolua.cast(Button_MaterialBase:getChildByName("Image_Check"),"ImageView") 
		Image_Check:setVisible(false)
		if i == 1 then  Image_Check:setVisible(true) end
		
		--未激活图案
		local Image_Sealed = tolua.cast(Button_MaterialBase:getChildByName("Image_Sealed"),"ImageView") 
		Image_Sealed:setVisible(false)
		--加号图案
		local Image_Add = tolua.cast(Button_MaterialBase:getChildByName("Image_Add"),"ImageView")
		Image_Add:setVisible(false) --加号图案
		--箭头
		local Image_Arrow = tolua.cast(Button_MaterialBase:getChildByName("Image_Arrow"),"ImageView")
		Image_Arrow:setVisible(false) --箭头
		--底图
		local Image_ColorBase = tolua.cast(Button_MaterialBase:getChildByName("Image_ColorBase"),"ImageView")
		Image_ColorBase:loadTexture(getUIImg("Frame_Evolute_DanYaoBase"..frameColor))
		--外框
		local Image_MaterialFrame = tolua.cast(Image_ColorBase:getChildByName("Image_MaterialFrame"),"ImageView") 
		Image_MaterialFrame:loadTexture(getUIImg("Frame_Evolute_DanYaoFrame"..frameColor))
		
		local Image_Icon = tolua.cast(Image_ColorBase:getChildByName("Image_Icon"),"ImageView")  
		Image_Icon:loadTexture(getIconImg(cardEvoluteDanYao.Icon))
		g_setImgShader(Image_Icon:getVirtualRenderer(),pszGreyFragSource)
		
		local danYaoLevel = tbDanyaoLevel[i]
		local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel)
		if strStateFlag == COMPOSE_STATE.Activate then --已激活
			Image_Arrow:setVisible(true) --箭头
			Image_Sealed:setVisible(false)
			g_setImgShader(Image_Icon:getVirtualRenderer(),pszNormalFragSource)
		else
			if skillLevel > bLevel then 
				Image_Sealed:setVisible(false)
				Image_Add:setVisible(false)
				g_setImgShader(Image_Icon:getVirtualRenderer(),pszNormalFragSource)
			elseif g_ComposeData:composeMaterailContrast(skillID,i,danYaoLevel) then 
				--总材料足够
				Image_Add:setVisible(true)
				g_CreateScaleInOutAction(Image_Add)
			end	
		end
	end

	local need = cardEvoluteSkillCondition.CoinsCostBase + cardEvoluteSkillCondition.CoinsCostGrow * skillLevel
	 --当前技能伤害
	local curSkill = cardEvoluteSkillCondition.DamageBase + cardEvoluteSkillCondition.DamageGrow * skillLevel
	
	--技能说明
	local Image_SkillNamePNL = tolua.cast(Image_ContentPNL:getChildByName("Image_SkillNamePNL"),"ImageView") 
	--技能名称
	local Label_SkillNameSource = tolua.cast(Image_SkillNamePNL:getChildByName("Label_SkillNameSource"),"Label") 
	Label_SkillNameSource:setText(tbCardInfo:getSkillNameWithSuffix(skillIndex,Label_SkillNameSource))
	--技能伤害（提升前）
	local Label_SkillDamageSource = tolua.cast(Image_SkillNamePNL:getChildByName("Label_SkillDamageSource"),"Label")  
	Label_SkillDamageSource:setText( _T("伤害").." +"..curSkill)
	g_SetCardNameColorByEvoluteLev(Label_SkillDamageSource, skillLevel)
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_SkillNameSource:setFontSize(18)
		Label_SkillDamageSource:setFontSize(18)
	end
	
	--技能名称
	local Label_SkillNameTarget = tolua.cast(Image_SkillNamePNL:getChildByName("Label_SkillNameTarget"),"Label")   
	Label_SkillNameTarget:setText(tbCardInfo:getSkillNameWithSuffix(skillIndex,Label_SkillNameTarget,1))
	

	--下一等级技能伤害
	local nextSkill =cardEvoluteSkillCondition.DamageBase + cardEvoluteSkillCondition.DamageGrow * (skillLevel+1)
	--技能伤害（提升后）
	local Label_SkillDamageTarget = tolua.cast(Image_SkillNamePNL:getChildByName("Label_SkillDamageTarget"),"Label")   
	Label_SkillDamageTarget:setText( _T("伤害").." +"..nextSkill)
	g_SetCardNameColorByEvoluteLev(Label_SkillDamageTarget, skillLevel+1)
	
	local Image_SkillTipPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_SkillTipPNL"),"ImageView") 
	local Label_SkillNameSource = tolua.cast(Image_SkillTipPNL:getChildByName("Label_SkillNameSource"),"Label") 
	
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_SkillNameTarget:setFontSize(18)
		Label_SkillDamageTarget:setFontSize(18)
	end
	
	--升级按钮 
	-- local Image_ContentPNL = tolua.cast(self.ImageView_SkillEolutePNL_:getChildByName("Image_ContentPNL"), "ImageView")
	local x = {360,200,520}
	local y = {620,360,360}
	local function onClickLevUP(pSender,eventType)
	    if eventType ==ccs.TouchEventType.ended then
			local bLeftShow = false
			local tips = _T("丹药未合成，点击前往合成")
			for i = 1,3 do
				local Button_MaterialBase = tolua.cast(Image_SkillMaterialPNL:getChildByName("Button_MaterialBase"..i),"Button")  
				local danYaoLevel = tbDanyaoLevel[i]
				local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel)
				if danYaoLevel < bLevel then danYaoLevel = bLevel end 
				if strStateFlag == COMPOSE_STATE.Activate then --已激活
				else
					if g_ComposeData:composeMaterailContrast(skillID,i,danYaoLevel) then 
						tips = _T("丹药可激活，点击激活丹药")
						CGuidTips:showGuidTip(self.rootWidget,tips,CCPointMake(x[i],y[i]),bLeftShow)
						return 
					else
						if i == 3 then  bLeftShow = true end
						CGuidTips:showGuidTip(self.rootWidget,tips,CCPointMake(x[i],y[i]),bLeftShow)
						return
					end	
				end
			end	
			
			CGuidTips:removeFromParent()

			if not g_CheckMoneyConfirm(need) then  return  end
			pSender:setTouchEnabled(false)
			--升级技能
			g_MsgMgr:OnceUpgradeSkillRequest(skillIndex,nCardID)
			
		end
	end
	
	local Button_LevelUp = tolua.cast(Image_ContentPNL:getChildByName("Button_LevelUp"), "Button")
	Button_LevelUp:setTouchEnabled(true)
	Button_LevelUp:addTouchEventListener(onClickLevUP)
	
	local Image_Check = tolua.cast(Button_LevelUp:getChildByName("Image_Check"), "ImageView")
	-- local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")

	local Image_TruePNL = tolua.cast(Button_LevelUp:getChildByName("Image_TruePNL"), "ImageView")
	local BitmapLabel_False = tolua.cast(Button_LevelUp:getChildByName("BitmapLabel_False"), "LabelBMFont")

	--消耗
	local BitmapLabel_NeedMoney = tolua.cast(Image_TruePNL:getChildByName("BitmapLabel_NeedMoney"), "LabelBMFont")
	BitmapLabel_NeedMoney:setText(need)
	g_SetLabelRed(BitmapLabel_NeedMoney,need > g_Hero:getCoins())	
	
	if skillLevel > bLevel then
		Image_SkillTipPNL:setVisible(true)
		Image_SkillNamePNL:setVisible(false)
		Image_TruePNL:setVisible(false)
		BitmapLabel_False:setVisible(true)
	else
		Image_SkillTipPNL:setVisible(false)
		Image_SkillNamePNL:setVisible(true)
		Image_TruePNL:setVisible(true)
		BitmapLabel_False:setVisible(false)
	end
	local param = { 
		need = need,
		image = Image_Check,
		button = Button_LevelUp,
		light = self.animationLight_,
		flag = g_ComposeData:danyaoAllActivate(skillLevel,bLevel,tbDanyaoLevel),
	}
	g_AnimationAlert(param)	
end
---------------------------------以上是激活丹药----------------------------------------

--------------------合成界面-----------------------------------------
function Game_Compose:compoundUI(cardEvoluteDanYao)
	self.tbCardEvoluteDanYao = cardEvoluteDanYao
	if not self.rootWidget then return end 
	
	if cardEvoluteDanYao then 
		g_ItemDropGuildFunc:setDanYaoStar(cardEvoluteDanYao.ItemStarLevel1)
	end
	
	local Image_ComposePNL = tolua.cast(self.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
	local Image_MaterialPNL = tolua.cast(Image_ComposePNL:getChildByName("Image_MaterialPNL"),"ImageView")
	Image_MaterialPNL:setVisible(true)
	Image_MaterialPNL:setTouchEnabled(true)
	for i = 1,3 do
		local Image_ComposeNodePNL1 = tolua.cast(Image_MaterialPNL:getChildByName("Image_ComposeNodePNL"..i),"ImageView")
		Image_ComposeNodePNL1:setVisible(false)
	end
	
	self:removeMaterialBox()

	local danyaoTypeName = { _T("武力"), _T("法术"), _T("绝技"), }
	local tbCardData = self.tbCardData_
	if not tbCardData then return end
	local skillIndex = tbCardData.skillIndex --技能索引

	local tbCard = tbCardData.cardInfo 
	local nCardID = tbCard:getServerId()--伙伴Id
	local tbDanyaoLv =  tbCard:getDanyaoLvList() --丹药等级
	local tbDanyaoLevel = tbDanyaoLv[skillIndex]
	local bLevel = tbCard:getEvoluteLevel()--突破等级
	local skillID = tbCardData.ID --技能id
	
	local skillLevel = tbCard:getSkillLevel(skillIndex) --技能等级
	
	local name = cardEvoluteDanYao.Name
	local desc = cardEvoluteDanYao.Desc

	local Image_ComposeNodePNL1 = tolua.cast(Image_MaterialPNL:getChildByName("Image_ComposeNodePNL1"),"ImageView")
	Image_ComposeNodePNL1:setVisible(true)

	local frameColor = tbCard:getSkillColorType(skillIndex)
	--物品名称
	local Label_TargetName = tolua.cast(Image_ComposeNodePNL1:getChildByName("Label_TargetName"),"Label")
	Label_TargetName:setText(name)
	g_SetWidgetColorBySLev(Label_TargetName,frameColor)
	--物品说明
	local Image_TargetInfoPNL = tolua.cast(Image_ComposeNodePNL1:getChildByName("Image_TargetInfoPNL"),"ImageView")
	local Image_DanYaoInfoPNL = tolua.cast(Image_TargetInfoPNL:getChildByName("Image_DanYaoInfoPNL"),"ImageView")
	
	local nType = cardEvoluteDanYao.Type % 3
	if nType == 0 then nType = 3 end
	
	local cardEvoluteSkillCondition = g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition",skillID)
	local danyaoId = cardEvoluteSkillCondition["NeedDanYaoID"..self.danYaoIndex_]
	local danYaoLevel = tbDanyaoLevel[self.danYaoIndex_]
	local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel,skillID,self.danYaoIndex_)
	local lv = danYaoLevel
	if strStateFlag == COMPOSE_STATE.Activate then --激活
		lv = lv - 1
	end
	
	local nextCardEvoluteDanYao = g_DataMgr:getCsvConfigByTwoKey("CardEvoluteDanYao",danyaoId,lv)
	local basePoints = cardEvoluteDanYao.BasePoints - nextCardEvoluteDanYao.BasePoints
	local mainProp = cardEvoluteDanYao.MainProp - nextCardEvoluteDanYao.MainProp
	
	--武力
	local Label_BasePoints = tolua.cast(Image_DanYaoInfoPNL:getChildByName("Label_BasePoints"),"Label")
	Label_BasePoints:setText(danyaoTypeName[nType].." "..cardEvoluteDanYao.BasePoints.." (+"..basePoints..")")
	
	local Label_HPMax = tolua.cast(Image_DanYaoInfoPNL:getChildByName("Label_HPMax"),"Label")
	Label_HPMax:setText(typeName[cardEvoluteDanYao.Type].." "..cardEvoluteDanYao.MainProp.." (+"..mainProp..")")
	
	--描述
	local Label_Desc = tolua.cast(Image_DanYaoInfoPNL:getChildByName("Label_Desc"),"Label")
	Label_Desc:setText(g_stringSize_PPPP(desc, 22, 410))
	
	local Image_Title2 = tolua.cast(Image_ComposeNodePNL1:getChildByName("Image_Title2"),"ImageView")
	local Label_MaterialLB = tolua.cast(Image_Title2:getChildByName("Label_MaterialLB"),"Label")

	--计算要消耗的材料数量
	local nItemDataNum = g_ComposeData:evoluteDanYaoItemTypeNum(cardEvoluteDanYao)
	
	local ccpointX = g_ComposeData:toolPosX(nItemDataNum)
	
	local function onComposeUp(pSender,eventType)
		if eventType ==ccs.TouchEventType.ended then
			for i = 1,nItemDataNum do
				local ItemID = cardEvoluteDanYao["ItemID"..i]
				local itemStarLev = cardEvoluteDanYao["ItemStarLevel"..i]
				local itemNum = cardEvoluteDanYao["ItemNum"..i] --要消耗多少材料
				if not g_ComposeData:danYaoNumContrast(ItemID,itemStarLev,itemNum) then 
					CGuidTips:showGuidTip(nil, _T("材料不足，点击前往收集材料"), CCPointMake(ccpointX[i],230),false)
					return 
				end
			end
			
			if not g_CheckMoneyConfirm(cardEvoluteDanYao.NeedMoney) then 
				return 
			end
			
			local danYaoLevel = tbDanyaoLevel[self.danYaoIndex_]
			local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel,skillID,self.danYaoIndex_)
		
			if strStateFlag == COMPOSE_STATE.NotActivate then --未激活
	
				if skillLevel > bLevel then 
					cclog("请先突破后在激活下一等级的丹药")
				else
					self:requestOnceComPoseDanYaoRequest(nCardID,skillIndex,self.danYaoIndex_,false)
				end
			else
				cclog("请先突破后在激活下一等级的丹药")
			end
			
		end
	end
	--合成按钮
	local Button_Compose = tolua.cast(Image_ComposeNodePNL1:getChildByName("Button_Compose"),"Button")
	Button_Compose:setTouchEnabled(true)
	Button_Compose:addTouchEventListener(onComposeUp)
	--消耗数值
	local BitmapLabel_NeedMoney = tolua.cast(Button_Compose:getChildByName("BitmapLabel_NeedMoney"),"LabelBMFont")
	BitmapLabel_NeedMoney:setText(cardEvoluteDanYao.NeedMoney)
	g_SetLabelRed(BitmapLabel_NeedMoney,cardEvoluteDanYao.NeedMoney > g_Hero:getCoins())	
	
	-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
	local BitmapLabel_NeedMoneyLB = tolua.cast(Button_Compose:getChildByName("BitmapLabel_NeedMoneyLB"),"LabelBMFont")
	local Image_Coins = tolua.cast(Button_Compose:getChildByName("Image_Coins"),"ImageView")
	-- g_AdjustWidgetsPosition({BitmapLabel_NeedMoneyLB, Image_Coins,BitmapLabel_NeedMoney})
	g_adjustWidgetsRightPosition({BitmapLabel_NeedMoney, Image_Coins})
	-- end

	local Image_Check = tolua.cast(Button_Compose:getChildByName("Image_Check"),"ImageView")
	local function notCompose()
		local danYaoLevel = tbDanyaoLevel[self.danYaoIndex_]
		local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel,skillID,self.danYaoIndex_)
		local nCount = 0
		for i = 1,nItemDataNum do
			local ItemID = cardEvoluteDanYao["ItemID"..i]
			local itemStarLev = cardEvoluteDanYao["ItemStarLevel"..i]
			local itemNum = cardEvoluteDanYao["ItemNum"..i] --要消耗多少材料
			if g_ComposeData:danYaoNumContrast(ItemID,itemStarLev,itemNum)
				and strStateFlag ==  COMPOSE_STATE.NotActivate then  --ActivateNot 未激活
				nCount = nCount + 1
			end
		end
		if skillLevel > bLevel then
			return false
		end
		return nCount == nItemDataNum
	end
	
	local param = { 
		need = cardEvoluteDanYao.NeedMoney,
		image = Image_Check,
		button = Button_Compose,
		flag = notCompose(),
	}
	g_AnimationAlert(param)	

	for i = 1,3 do
		local Button_MaterialBase = tolua.cast(Image_ComposeNodePNL1:getChildByName("Button_MaterialBase"..i),"Button")
		Button_MaterialBase:setTouchEnabled(false)
	end
	
	local function materiaTips(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			local tagIndex = pSender:getTag()
			local ItemID = cardEvoluteDanYao["ItemID"..tagIndex]
			local itemStarLev = cardEvoluteDanYao["ItemStarLevel"..tagIndex]
			local itemNum = cardEvoluteDanYao["ItemNum"..tagIndex] --要消耗多少材料
			
			if g_ComposeData:danYaoNumContrast(ItemID,itemStarLev,itemNum) then 
				cclog("材料足够")
				return 
			end
			
			if skillLevel > bLevel then 
				cclog("要突破先技能")
				return
			end
			
			local danYaoLevel = tbDanyaoLevel[self.danYaoIndex_]
			local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel,skillID,self.danYaoIndex_)
			if strStateFlag == COMPOSE_STATE.NotActivate then --未激活
				if skillLevel > bLevel then 
					return
				end
			else
				if skillLevel > bLevel then 
				else
					return
				end
			end
			Image_ComposeNodePNL1:setVisible(false)
			
			local itemBase = g_DataMgr:getCsvConfigByTwoKey("ItemBase",ItemID,itemStarLev)
			self.tbItemBase_ = itemBase
			local icon = self:materiaIcon(2,itemBase.ID,itemBase.StarLevel,"")
			self:tipIndicate(2,icon)
			--macro_pb.ITEM_TYPE_MATERIAL 材料
			g_MsgMgr:requestMaterialEctypeRequest(ItemID,itemStarLev,macro_pb.ITEM_TYPE_MATERIAL)
			
			local param = {
				materialId=ItemID,materialStarLevel=itemStarLev,name = itemBase.Name
			}
			self:dropOutCompound(param)
	
		end
	end
	
	local yangBaoComposeBtn = true
	local itemNumPrice = 0
	local csvCardDanYaoYuanBao = g_DataMgr:getCsvConfig("CardDanYaoYuanBao") 
	local tbX,y = g_ComposeData:iconPostionXY(nItemDataNum)
	for i = 1,nItemDataNum do
		local Button_MaterialBase = tolua.cast(Image_ComposeNodePNL1:getChildByName("Button_MaterialBase"..i),"Button")
		Button_MaterialBase:setTouchEnabled(true)
		Button_MaterialBase:addTouchEventListener(materiaTips)
		Button_MaterialBase:setTag(i)
		
		local itemStarLev = cardEvoluteDanYao["ItemStarLevel"..i]
		local ItemID = cardEvoluteDanYao["ItemID"..i]	--材料iD
		local CSV_ItemBase = g_DataMgr:getCsvConfigByTwoKey("ItemBase",ItemID, itemStarLev)
		
		local Image_Add = tolua.cast(Button_MaterialBase:getChildByName("Image_Add"),"ImageView")
		Image_Add:setVisible(false)
		
		local itemNum = cardEvoluteDanYao["ItemNum"..i] --要消耗多少材料
		local nCurNum = g_Hero:getItemNumByCsv(ItemID,itemStarLev) --背包里拥有多少材料
		
		--计算此丹药还差几个碎片
		local residue = 0
		if nCurNum < itemNum then 
			residue =  itemNum - nCurNum
		end
		

		local danYaoLevel = tbDanyaoLevel[self.danYaoIndex_]
		local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel)
		if strStateFlag == COMPOSE_STATE.NotActivate then --未激活
			if g_ComposeData:danYaoNumContrast(ItemID,itemStarLev,itemNum) then 	
				--丹药碎片足够
				Image_Add:setVisible(false)
				residue = 0 
			else
				Image_Add:setVisible(true)
				g_CreateScaleInOutAction(Image_Add)
			end
		else
			--技能等级     突破等级
			if skillLevel > bLevel then 
			else
				Image_Add:setVisible(false)
				residue = 0
			end
		end
		
		if skillLevel > bLevel then 
			Image_Add:setVisible(false)
		end
		
		local materialBox = g_WidgetModel.Image_EquipWorkFrag:clone()
		Button_MaterialBase:setPosition(ccp(tbX[i],y))
		Button_MaterialBase:setVisible(true)
		Button_MaterialBase:addChild(materialBox)
		table.insert(self.materialBox_,materialBox)
	
		local Image_EquipWorkMaterial  = tolua.cast(materialBox,"ImageView")
		Image_EquipWorkMaterial:loadTexture(getUIImg("FrameBack"..CSV_ItemBase.ColorType))
		
		local icon = getIconImg(CSV_ItemBase.Icon)
		local Image_Icon = tolua.cast(materialBox:getChildByName("Image_Icon"),"ImageView")
		Image_Icon:loadTexture(icon)
		
		local Image_Frame = tolua.cast(materialBox:getChildByName("Image_Frame"),"ImageView")
		Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
		
		local Label_NeedNum = tolua.cast(materialBox:getChildByName("Label_NeedNum"),"Label")
		Label_NeedNum:setText(nCurNum)
		
		local Label_NeedNumMax = tolua.cast(materialBox:getChildByName("Label_NeedNumMax"),"Label")
		Label_NeedNumMax:setText("/"..itemNum)
		
		g_adjustWidgetsRightPosition({Label_NeedNumMax,Label_NeedNum})

		-- 合成所需的元宝 = 当前丹药等级在CardDanYaoYuanBao脚本对应的FragYuanBaoPrice*剩余所需的碎片数量
		itemNumPrice = csvCardDanYaoYuanBao[danYaoLevel + 1].FragYuanBaoPrice * residue

	end
	
	
	--元宝合成
	local function onYuanBaoComposeUp(pSender,eventType)
		if eventType ==ccs.TouchEventType.ended then
			
			if not g_CheckYuanBaoConfirm(itemNumPrice, _T("您的元宝不足是否前往充值") ) then
				return 
			end
			local danYaoLevel = tbDanyaoLevel[self.danYaoIndex_]
			local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel,skillID,self.danYaoIndex_)
			if strStateFlag == COMPOSE_STATE.NotActivate then --未激活
				if skillLevel > bLevel then 
					cclog("请先突破后在激活下一等级的丹药")
				else
					local txt = string.format( _T("元宝合成需要花费%d元宝，是否合成？"),itemNumPrice)
					g_ClientMsgTips:showConfirm(txt, function() 
						self:requestOnceComPoseDanYaoRequest(nCardID,skillIndex,self.danYaoIndex_,true)
					end)
				end
			else
				cclog("请先突破后在激活下一等级的丹药")
			end
			
		end
	end
	
	--元宝合成按钮
	local Button_YuanBaoCompose = tolua.cast(Image_ComposeNodePNL1:getChildByName("Button_YuanBaoCompose"),"Button")
	--消耗数值
	local BitmapLabel_NeedYuanBao = tolua.cast(Button_YuanBaoCompose:getChildByName("BitmapLabel_NeedYuanBao"),"LabelBMFont")

	-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
	local BitmapLabel_FuncName = tolua.cast(Button_YuanBaoCompose:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")
	local Image_YuanBao = tolua.cast(Button_YuanBaoCompose:getChildByName("Image_YuanBao"),"ImageView")
	
	-- end
	
	local danYaoLevel = tbDanyaoLevel[self.danYaoIndex_]
	local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(danYaoLevel,skillLevel,skillID,self.danYaoIndex_)
	if strStateFlag == COMPOSE_STATE.NotActivate then --未激活
		if skillLevel > bLevel then 
			Button_YuanBaoCompose:setTouchEnabled(false)
			itemNumPrice = 0
		else
			if itemNumPrice <= 0 then 
				Button_YuanBaoCompose:setTouchEnabled(false)
			else
				Button_YuanBaoCompose:setTouchEnabled(true)
				Button_YuanBaoCompose:addTouchEventListener(onYuanBaoComposeUp)
			end
		end
	else
		Button_YuanBaoCompose:setTouchEnabled(false)
		itemNumPrice = 0
	end
	
	BitmapLabel_NeedYuanBao:setText(itemNumPrice)
	g_SetLabelRed(BitmapLabel_NeedYuanBao,itemNumPrice > g_Hero:getYuanBao())
	g_adjustWidgetsRightPosition({BitmapLabel_NeedYuanBao, Image_YuanBao})
end

function Game_Compose:removeMaterialBox()

	if self.materialBox_ then
		for i= 1,#self.materialBox_ do
			self.materialBox_[i]:removeFromParentAndCleanup(true)
		end
		self.materialBox_ = {}
	else
		self.materialBox_ = {}
	end
end

------------------------------------以上是合成界面------------------------------------------------


------------------------------碎片掉落界面---------------------------------------------
function Game_Compose:dropOutCompound(param)	
	local materialId = param.materialId
	local materialStarLevel = param.materialStarLevel
	local name = param.name
	
	local wndInstance = g_WndMgr:getWnd("Game_Compose")
	if wndInstance and wndInstance.rootWidget then
	
		-- local itemDropGuide = g_DataMgr:getCsvConfigByTwoKey("ItemDropGuide",materialId,materialStarLevel)
		
		local Image_ComposePNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
		local Image_MaterialPNL = tolua.cast(Image_ComposePNL:getChildByName("Image_MaterialPNL"),"ImageView")
		local Image_ComposeNodePNL3 = tolua.cast(Image_MaterialPNL:getChildByName("Image_ComposeNodePNL3"),"ImageView")
		Image_ComposeNodePNL3:setVisible(true)
		--材料名称
		local Label_TargetName = tolua.cast(Image_ComposeNodePNL3:getChildByName("Label_TargetName"),"Label")
		Label_TargetName:setText(name)
		
		--关卡
		local Image_EctypeInfoPNL = tolua.cast(Image_ComposeNodePNL3:getChildByName("Image_EctypeInfoPNL"),"ImageView")
		
		local ListView_EctypeList = tolua.cast(Image_EctypeInfoPNL:getChildByName("ListView_EctypeList"), "ListViewEx")
		self.LuaListView_EctypeList = Class_LuaListView:new()
		self.LuaListView_EctypeList:setListView(ListView_EctypeList)
		
		local Panel_EctypeItem = tolua.cast(g_WidgetModel.Panel_EctypeItem, "Layout")
		self.LuaListView_EctypeList:setModel(Panel_EctypeItem)
		
		local imgScrollSlider = ListView_EctypeList:getScrollSlider()
		if not g_tbScrollSliderXY.ListView_EctypeList_X then
			g_tbScrollSliderXY.ListView_EctypeList_X = imgScrollSlider:getPositionX()
		end
		imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_EctypeList_X - 3)
		
		--返回按钮
		local Button_Close = tolua.cast(Image_ComposeNodePNL3:getChildByName("Button_Close"),"Button")
		local function tips(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				
				local wndInstance = g_WndMgr:getWnd("Game_Compose")
				if wndInstance and wndInstance.rootWidget then
					
					local icon = self:materiaIcon(1,wndInstance.tbItemBase_.ID,wndInstance.tbItemBase_.StarLevel,"")
					wndInstance:tipIndicate(1,icon)
					wndInstance:compoundUI(self.tbCardEvoluteDanYao)
				
					local Image_ComposePNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
					local Image_MaterialPNL = tolua.cast(Image_ComposePNL:getChildByName("Image_MaterialPNL"),"ImageView")
					local Image_ComposeNodePNL3 = tolua.cast(Image_MaterialPNL:getChildByName("Image_ComposeNodePNL3"),"ImageView")
					Image_ComposeNodePNL3:setVisible(false)
				end
				
			end
		end
		Button_Close:setTouchEnabled(true)
		Button_Close:addTouchEventListener(tips)

		--返回
		local BitmapLabel_FuncName = tolua.cast(Button_Close:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")
		local Image_Coins = tolua.cast(Button_Close:getChildByName("Image_Coins"),"ImageView")
		-- g_AdjustWidgetsPosition({BitmapLabel_FuncName, Image_Coins},20)
	end
end

------------------------------以上是碎片掉落界面-----------------------------------------

-----------------------------升级技能 按钮回调 在消息协议响应中调用-------------
function Game_Compose:skillUpgrade(nCardID,nIndex)
	if not self.rootWidget then return end 
	-- 伙伴技能升级
	local tbCardInfo = g_Hero:getCardObjByServID(nCardID)
	local CSV_CardBase = tbCardInfo:getCsvBase()
    local nSkillID = CSV_CardBase["PowerfulSkillID"..nIndex]
    local nLevel = tbCardInfo:getStarLevel()
	
	local tbCard = self.tbCardData_
	local tbCardInfo = tbCard.cardInfo --丹药列表
	
	local tbDanyaoLv =  tbCardInfo:getDanyaoLvList() --丹药等级
	local tbDanyaoLevel = tbDanyaoLv[nIndex]

    local tbSkillCondition = g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition",nSkillID)
	-- 消耗技能材料
    for i = 1,3 do
		local cardEvoluteDanYao = g_DataMgr:getCsvConfigByTwoKey("CardEvoluteDanYao",tbSkillCondition["NeedDanYaoID"..i],tbDanyaoLevel[i])
		local itemCompose = g_DataMgr:getCsvConfigByTwoKey("ItemCompose",cardEvoluteDanYao["ItemID"..i],cardEvoluteDanYao["ItemStarLevel"..i])
        local nItemCsvID = tbSkillCondition["NeedItemID"..i]
	    local nCurNum = g_Hero:getItemNumByCsv(nItemCsvID, nLevel)
	    local nLeftNum = nCurNum - itemCompose["MaterialNum"..i] --碎片数量
	    g_Hero:setItemByCsvIdAndStar(nItemCsvID, nLevel, nLeftNum)
    end


    g_Hero:showTeamStrengthGrowAnimation()
	local Image_ComposePNL = tolua.cast(self.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
	local Image_SkillEolutePNL = tolua.cast(Image_ComposePNL:getChildByName("Image_SkillEolutePNL"), "ImageView")

	local Image_ContentPNL = tolua.cast(Image_SkillEolutePNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Image_SkillMaterialPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_SkillMaterialPNL"), "ImageView")
	local Button_SkillBase = tolua.cast(Image_SkillMaterialPNL:getChildByName("Button_SkillBase"), "Button")
	
	local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("IncenseStatue", nil, function() 
		g_WndMgr:closeWnd("Game_Compose")
	end, 5)
	Button_SkillBase:addNode(armature)
	userAnimation:playWithIndex(0)
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_Compose") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	DAN_YAO_S = true
	
end
---------------------
	
--一键升级丹药请求
function Game_Compose:requestOnceComPoseDanYaoRequest(cardid,skillIdx,danyaoIdx,isYuanbao)
	cclog("一键升级丹药请求")
	local msg = zone_pb.OnceComPoseDanYaoRequest() 
	msg.cardid = cardid  --伙伴id
	msg.skill_idx = skillIdx - 1 --技能id
	msg.danyao_idx = danyaoIdx - 1 --伙伴丹药索引
	msg.is_yuanbao =  isYuanbao --true表示用元宝合成
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ONCE_LVUP_DANYAO_REQUEST,msg)
	g_MsgNetWorkWarning:showWarningText()
end	

--一键升级丹药响应
function Game_Compose:requestOnceComPoseDanYaoResponse(tbMsg)
	cclog("---------requestOnceComPoseDanYaoResponse-------------")
	cclog("---------一键升级丹药响应-------------")
	local msgDetail = zone_pb.OnceComPoseDanYaoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	g_MsgNetWorkWarning:closeNetWorkWarning()
	
	local cardId = msgDetail.upgrade_cardid  --伙伴id
	local skillIndex = msgDetail.skill_index + 1 --技能
	local danyaoIdx = msgDetail.danyao_idx + 1 --伙伴丹药索引
	danyaoIdx = danyaoIdx % 3
	if danyaoIdx == 0 then danyaoIdx = 3 end
	
	local danyaoLv = msgDetail.danyao_lv  -- 伙伴丹药等级

	local updatedMoney = msgDetail.leave_money -- 剩余铜钱
	local leaveYuanbao = msgDetail.leave_yuanbao -- 剩余的元宝
	
	
	local yuanBao = g_Hero:getYuanBao() - leaveYuanbao
	if yuanBao > 0 then
		gTalkingData:onPurchase(TDPurchase_Type.TDP_COMPOSE_GOLD_DANYAO, 1, yuanBao)
	end
	
	--消耗的金钱
    g_Hero:setCoins(updatedMoney)
	g_Hero:setYuanBao(leaveYuanbao)
	
	local material = msgDetail.cost_material -- 消耗的材料
	local materialNum = material["material_num"] 
	local materialId = material["material_id"]	
	for i = 1,#material do
		local nServerID = material[i].material_id
		local nRemainNum = material[i].material_num
		g_Hero:setItemNum(nServerID, nRemainNum) 
	end
	
	local tbCard = self.tbCardData_
	local tbCardInfo = tbCard.cardInfo --丹药列表
	tbCardInfo:setDanyaoLvList(skillIndex, danyaoIdx, danyaoLv)
	
	if not self.rootWidget then return end 
	local Image_ComposePNL = tolua.cast(self.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
	local Image_SkillEolutePNL = tolua.cast(Image_ComposePNL:getChildByName("Image_SkillEolutePNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_SkillEolutePNL:getChildByName("Image_ContentPNL"),"ImageView") 
	local Image_SkillMaterialPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_SkillMaterialPNL"),"ImageView") 
	local Button_MaterialBase = tolua.cast(Image_SkillMaterialPNL:getChildByName("Button_MaterialBase"..danyaoIdx),"Button") 
	
	local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("XianMaiActivate", nil, nil, 5)
	armature:setPositionY(5)
	Button_MaterialBase:addNode(armature)
	userAnimation:playWithIndex(0)
	
	local Image_ColorBase = tolua.cast(Button_MaterialBase:getChildByName("Image_ColorBase"),"ImageView") 
	--外框
	local Image_Icon = tolua.cast(Image_ColorBase:getChildByName("Image_Icon"),"ImageView")  
	g_setImgShader(Image_Icon:getVirtualRenderer(),pszNormalFragSource)
	
	--加号图案
	local Image_Add = tolua.cast(Button_MaterialBase:getChildByName("Image_Add"),"ImageView")  
	Image_Add:setVisible(false)
	local Image_Sealed =  tolua.cast(Button_MaterialBase:getChildByName("Image_Sealed"),"ImageView")  
	Image_Sealed:setVisible(false)
	
	--箭头
	local Image_Arrow = tolua.cast(Button_MaterialBase:getChildByName("Image_Arrow"),"ImageView")
	Image_Arrow:setVisible(true) --箭头

	local skillIndex = tbCard.skillIndex --技能索引 
	local skillID = tbCard.ID --技能id
	local skillLevel =  tbCardInfo:getSkillLevel(skillIndex) --技能等级
	local cardEvoluteSkill = g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition",skillID)
	local need = cardEvoluteSkill.CoinsCostBase + cardEvoluteSkill.CoinsCostGrow * skillLevel
	
	local Button_LevelUp = tolua.cast(Image_ContentPNL:getChildByName("Button_LevelUp"), "Button")
	local Image_TruePNL = tolua.cast(Button_LevelUp:getChildByName("Image_TruePNL"), "ImageView")
	local BitmapLabel_NeedMoney = tolua.cast(Image_TruePNL:getChildByName("BitmapLabel_NeedMoney"), "LabelBMFont")
	BitmapLabel_NeedMoney:setText(need)
	g_SetLabelRed(BitmapLabel_NeedMoney,need > g_Hero:getCoins())	

	local bLevel = tbCardInfo:getEvoluteLevel()--突破等级
	local tbDanyaoLv =  tbCardInfo:getDanyaoLvList() --丹药等级
	local tbDanyaoLevel = tbDanyaoLv[skillIndex]
	
	local Image_Check = tolua.cast(Button_LevelUp:getChildByName("Image_Check"), "ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	local param = { 
		need = need,
		image = Image_Check,
		button = Button_LevelUp,
		light = self.animationLight_,
		flag = g_ComposeData:danyaoAllActivate(skillLevel,bLevel,tbDanyaoLevel,skillID,skillIndex),
	}
	g_AnimationAlert(param)	
	
	--刷新合成界面
	local cardEvoluteDanYao = self.tbCardEvoluteDanYao
	self:compoundUI(cardEvoluteDanYao)
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_Compose") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	DAN_YAO_S = true

end

function Game_Compose:tipDanYaoIcon(frameColor,skillID,nIndex,skillLevel)
	if self.iconUseItem_ then 
		self.iconUseItem_:removeFromParent()
		self.iconUseItem_ = nil
	end

	local iconUseItem =  tolua.cast(g_WidgetModel.Image_EquipWorkFrag:clone(),"ImageView")
	if nIndex == 1 then
		-- iconUseItem = tolua.cast(g_WidgetModel.Image_PackageIconUseItem:clone(),"ImageView")
		iconUseItem = tolua.cast(g_WidgetModel.EquipWorkMaterial:clone(),"ImageView")
	end

	local Label_NeedNum = tolua.cast(iconUseItem:getChildByName("Label_NeedNum"),"Label")
	Label_NeedNum:setVisible(false)	
	local Label_NeedNumMax = tolua.cast(iconUseItem:getChildByName("Label_NeedNumMax"),"Label")
	Label_NeedNumMax:setVisible(false)

	iconUseItem:loadTexture(getFrameBackGround(frameColor))
	iconUseItem:setPosition(ccp(0,0))
	iconUseItem:setScale(0.8)
	self.iconUseItem_ = iconUseItem

	local cardEvoluteSkill = g_DataMgr:getCsvConfigByOneKey("CardEvoluteSkillCondition",skillID)
	local danyaoId = cardEvoluteSkill["NeedDanYaoID"..nIndex] --第几个丹药
	local cardEvoluteDanYao = g_DataMgr:getCsvConfigByTwoKey("CardEvoluteDanYao",danyaoId,skillLevel)
	
	local Image_Icon = tolua.cast(iconUseItem:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(cardEvoluteDanYao.Icon))
	
	local Image_Frame = tolua.cast(iconUseItem:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getIconFrame(frameColor))
	return iconUseItem
end

function Game_Compose:materiaIcon(nIndex,id,starLevel,itemNum)
	nIndex = nIndex or 1
	local tbDrop = {}
	tbDrop.DropItemType = macro_pb.ITEM_TYPE_MATERIAL
	tbDrop.DropItemID = id
	tbDrop.DropItemStarLevel = starLevel
	tbDrop.DropItemNum = itemNum or ""

	local iconMode = g_CloneDropItemModel(tbDrop)
	iconMode:setScale(0.8)
	iconMode:setPosition(ccp(0,0))
	self.iconModeItem_[nIndex] = iconMode
	return iconMode
end

function Game_Compose:tipIndicate(nIndex,icon)
	if not self.rootWidget then return end
	local Image_ComposePNL = tolua.cast(self.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
	local Image_MaterialPNL = tolua.cast(Image_ComposePNL:getChildByName("Image_MaterialPNL"), "ImageView")
	local Image_ComposeTreePNL = tolua.cast(Image_MaterialPNL:getChildByName("Image_ComposeTreePNL"), "ImageView")

	local function click(pSender,eventType)
		if eventType ==ccs.TouchEventType.ended then
			local tag = pSender:getTag()
			local Button_TreeNode_tag = tolua.cast(Image_ComposeTreePNL:getChildByName("Button_TreeNode"..tag),"Button")
			local Image_Check = tolua.cast(Button_TreeNode_tag:getChildByName("Image_Check"), "ImageView")
			Image_Check:setVisible(true)
			
			local Image_ComposeNodePNL = tolua.cast(Image_MaterialPNL:getChildByName("Image_ComposeNodePNL"..tag), "ImageView")
			if tag == 2 then 
				Image_ComposeNodePNL:setVisible(false)
			else
				Image_ComposeNodePNL:setVisible(true)
			end

			for i = 1,3 do
				local Button_TreeNode_i = tolua.cast(Image_ComposeTreePNL:getChildByName("Button_TreeNode"..i),"Button")
				local Image_Check = tolua.cast(Button_TreeNode_i:getChildByName("Image_Check"), "ImageView")
				if i > tag then 
					local Image_ComposeNodePNL = tolua.cast(Image_MaterialPNL:getChildByName("Image_ComposeNodePNL"..i), "ImageView")
					Image_ComposeNodePNL:setVisible(false)
					Button_TreeNode_i:setTouchEnabled(false)
					Button_TreeNode_i:setVisible(false)
					Image_Check:setVisible(false)
					
					if self.iconModeItem_[tag+1] then 
						self.iconModeItem_[tag+1]:removeFromParent()
						self.iconModeItem_[tag+1] = nil
					end
				end
			end
		end
	end
	
	for i = 1,3 do
		local Button_TreeNode = tolua.cast(Image_ComposeTreePNL:getChildByName("Button_TreeNode"..i),"Button")
		Button_TreeNode:setTag(i)
		local Image_Check = tolua.cast(Button_TreeNode:getChildByName("Image_Check"), "ImageView")
		Image_Check:setVisible(false)
	end
	local flag = false
	for i = nIndex,3 do
		local Button_TreeNode = tolua.cast(Image_ComposeTreePNL:getChildByName("Button_TreeNode"..i),"Button")
		local Image_Check = tolua.cast(Button_TreeNode:getChildByName("Image_Check"), "ImageView")
		flag = false;
		if i == nIndex then 
			flag = true;
			if icon then  Button_TreeNode:addChild(icon) end
		end
		
		Image_Check:setVisible(flag)
		Button_TreeNode:setVisible(flag)
		Button_TreeNode:setTouchEnabled(flag)
		Button_TreeNode:addTouchEventListener(click)
		
	end	

end

--掉落副本 第二个参数 flag  标记为从丹药掉落的情况 进入此函数
function Game_Compose:ectypeListShow(ectypeList, itemType)

	local onUpdate_LuaListView_EctypeList = g_ItemDropGuildFunc:ectypeListShow(ectypeList, itemType)
	
	local wndInstance = g_WndMgr:getWnd("Game_Compose")
	if wndInstance then
		wndInstance.ectypeList_ = g_ItemDropGuildFunc:getEctypeListInfo()
		
		if not wndInstance.LuaListView_EctypeList then return end
		
		wndInstance.LuaListView_EctypeList:setUpdateFunc(onUpdate_LuaListView_EctypeList)
		
		local function onAdjust_LuaListView_EctypeList(Panel_EctypeItem, nIndex)
			wndInstance.nCurrentListViewIndex = nIndex
		end
		wndInstance.LuaListView_EctypeList:setAdjustFunc(onAdjust_LuaListView_EctypeList)
		
		local count = 0
		for key,value in ipairs(ectypeList) do
			if value.ectypeid > 0 then 
				count = count + 1
			end
		end
		wndInstance.LuaListView_EctypeList:updateItems(	count + 1, wndInstance.nCurrentListViewIndex or 1)
	end
	
end

function Game_Compose:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ComposePNL = tolua.cast(self.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ComposePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_Compose:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ComposePNL = tolua.cast(self.rootWidget:getChildByName("Image_ComposePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ComposePNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end