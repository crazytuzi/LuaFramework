--------------------------------------------------------------------------------------
-- 文件名:	HJW_Game_CardHandBook.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2015-09-28
-- 版  本:	1.0
-- 描  述:	卡牌信息
-- 应  用:  
---------------------------------------------------------------------------------------

Game_CardHandBook = class("Game_CardHandBook")
Game_CardHandBook.__index = Game_CardHandBook

local SKILL_NUM = 3
local CARD_GROUP_MAX_NUM = 4
local CARD_GROUP_ICON_NUM = 5
local EQUIP_BOX_NUM = 6


function Game_CardHandBook:initWnd()
	
	local rootWidget = self.rootWidget
	if not rootWidget then return end
	
	local Image_CardInfoPNL = tolua.cast(rootWidget:getChildByName("Image_CardInfoPNL"), "ImageView")
		
	local PageView_Card = tolua.cast(Image_CardInfoPNL:getChildByName("PageView_Card"), "PageView")
	PageView_Card:setClippingEnabled(true)
	
	local Panel_CardPage = tolua.cast(PageView_Card:getChildByName("Panel_CardPage"), "PageView")
	Panel_CardPage:retain()
	
	local Button_ForwardPage = tolua.cast(Image_CardInfoPNL:getChildByName("Button_ForwardPage"), "Button")
	local Button_NextPage = tolua.cast(Image_CardInfoPNL:getChildByName("Button_NextPage"), "Button")
	
    local LuaPageView_Card_Equip = Class_LuaPageView:new() 
    LuaPageView_Card_Equip:setModel(Panel_CardPage, Button_ForwardPage,Button_NextPage, 0.5, 0.5)
    LuaPageView_Card_Equip:setPageView(PageView_Card)
	self.LuaPageView_Card_Equip = LuaPageView_Card_Equip
	
	local Image_CardDetailPNL = tolua.cast(rootWidget:getChildByName("Image_CardDetailPNL"), "ImageView")
	local ListView_CardInfo = tolua.cast(Image_CardDetailPNL:getChildByName("ListView_CardInfo"), "ListView")
	
	local Image_CardGroupPNL = g_WidgetModel.Image_CardGroupPNL:clone()
	ListView_CardInfo:setItemModel(Image_CardGroupPNL)
	
	local Image_CardDetailPNL = tolua.cast(rootWidget:getChildByName("Image_CardDetailPNL"), "ImageView")
	local Image_ListViewLight = tolua.cast(Image_CardDetailPNL:getChildByName("Image_ListViewLight"), "ImageView")
	g_CreateFadeInOutAction(Image_ListViewLight, 0, 150)
	
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

function Game_CardHandBook:openWnd(nCardID)
	-- if g_bReturn then return end
	if not nCardID then return  end 
	self.tbCardList = {}
	--出战的
	local nHasSummonBattleCount = g_Hero:getHasSummonBattleCardListCount()
	--未出战
	local nHasSummonUnBattleCount = g_Hero:getHasSummonUnBattleCardListCount()
	--未召唤
	local nUnSummonCount = g_Hero:getUnSummonCardListCount()
	local count = 1
	local unBattleCount = 0
	local unSummonCount = 0
	local cardId = 1
	for nIndex = 1,nHasSummonBattleCount+nHasSummonUnBattleCount+nUnSummonCount do 
		local tbCard = nil
		if nIndex <= nHasSummonBattleCount then
			tbCard = g_Hero:getHasSummonBattleCardByIndex(nIndex)
			if tbCard then 
				-- if  tbCard:getCardCsvID() == 1 then 
					table.insert(self.tbCardList ,tbCard)
					cardId = tbCard:getCardCsvID()
				-- end
			end
		elseif nIndex <= nHasSummonUnBattleCount then
			unBattleCount = unBattleCount + 1
			tbCard = g_Hero:getHasSummonUnBattleCardByIndex(unBattleCount)
			if tbCard then 
				table.insert(self.tbCardList ,tbCard)
				cardId = tbCard:getCardCsvID()
			end
		else
			unSummonCount = unSummonCount + 1
			tbCard = g_Hero:getUnSummonCardByIndex(unSummonCount)
			if tbCard then 
				table.insert(self.tbCardList ,tbCard)
				cardId = tbCard.ID
			end
		end
		if tbCard and cardId == nCardID then
			count = nIndex 
		end
	end
	self.LuaPageView_Card_Equip:setCurPageIndex(count)
	self:registerPageViewFateEvent(self.LuaPageView_Card_Equip)
	
end 

function Game_CardHandBook:closeWnd()

end

function Game_CardHandBook:registerPageViewFateEvent(LuaPageView_Card_Equip)
	
	local Image_CardInfoPNL = tolua.cast(self.rootWidget:getChildByName("Image_CardInfoPNL"), "ImageView")
	local Label_Name = tolua.cast(Image_CardInfoPNL:getChildByName("Label_Name"), "Label")
	local AtlasLabel_StarLevel = tolua.cast(Image_CardInfoPNL:getChildByName("AtlasLabel_StarLevel"), "LabelAtlas")

		--出战的
	local nHasSummonBattleCount = g_Hero:getHasSummonBattleCardListCount()
	--未出战
	local nHasSummonUnBattleCount = g_Hero:getHasSummonUnBattleCardListCount()
	--未召唤
	local nUnSummonCount = g_Hero:getUnSummonCardListCount()
	-- local cardId = 0
    local function turningFunction(Panel_CardPage, nIndex)
		local tbCard =  self.tbCardList[nIndex]
        if tbCard then    
			local cardId = 1
			local cardStarLv = 1
			if tbCard.getCardCsvID then 
				cardId = tbCard:getCardCsvID()
				cardStarLv = tbCard:getStarLevel()
			else
				cardId = tbCard.ID
				cardStarLv = tbCard.CardStarLevel
			end
			local cvsCardBase = g_DataMgr:getCsvConfigByOneKey("CardBase",cardId)
            Label_Name:setText(cvsCardBase.Name)
			local starLv = string.rep("1",cardStarLv)
			AtlasLabel_StarLevel:setValue(starLv)
			
			self:ListViewCardInfoShow(cvsCardBase,cardStarLv)
        end
    end

    local function updateFunction(Panel_CardPage, nIndex)
		local tbCard =  self.tbCardList[nIndex]
        if tbCard then    
			local cardId = 1
			if tbCard.getCardCsvID then 
				cardId = tbCard:getCardCsvID()
			else
				cardId = tbCard.ID
			end
			local cvsCardBase = g_DataMgr:getCsvConfigByOneKey("CardBase",cardId)		
			if not cvsCardBase then return end 
			
			local Panel_Card = Panel_CardPage:getChildByName("Panel_Card")
			local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView")
            local CCNode_Skeleton = g_CocosSpineAnimation(cvsCardBase.SpineAnimation, 1)
			Image_Card:removeAllNodes()
			Image_Card:loadTexture(getUIImg("Blank"))
			Image_Card:setPositionXY(cvsCardBase.Pos_X*Panel_Card:getScale()/0.6, cvsCardBase.Pos_Y*Panel_Card:getScale()/0.6)
            Image_Card:addNode(CCNode_Skeleton)
            g_runSpineAnimation(CCNode_Skeleton, "idle", true)
        end
    end

    LuaPageView_Card_Equip:registerClickEvent(turningFunction)
    LuaPageView_Card_Equip:registerUpdateFunction(updateFunction)
	-- LuaPageView_Card_Equip:updatePageView(g_Hero:getUnSummonCardListCount())
	LuaPageView_Card_Equip:updatePageView(#self.tbCardList)
end


function Game_CardHandBook:ListViewCardInfoShow(cvsCardBase,cardStarLv)
	local rootWidget = self.rootWidget
	if not rootWidget then return end
	local cardBaseInfo = cvsCardBase
	local cardTwoKeyInfo = cvsCardBase[cardStarLv]
	local Image_CardDetailPNL = tolua.cast(rootWidget:getChildByName("Image_CardDetailPNL"), "ImageView")
	local ListView_CardInfo = tolua.cast(Image_CardDetailPNL:getChildByName("ListView_CardInfo"), "ListView")
	
	self:setImageBasePropPNL(ListView_CardInfo,cardTwoKeyInfo)
	
	self:setImageProfessionInfoPNL(ListView_CardInfo,cardBaseInfo)

	self:setImageSkillInfoPNL(ListView_CardInfo,cardBaseInfo)
	
	self:setImageCardGroupPNL(ListView_CardInfo,cardBaseInfo)
	
	
end


function Game_CardHandBook:setImageBasePropPNL(ListView_CardInfo,cvsCardBase)
	local Image_BasePropPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_BasePropPNL"), "ImageView")
	--生命
	local Label_Health = tolua.cast(Image_BasePropPNL:getChildByName("Label_Health"), "Label")
	Label_Health:setText(cvsCardBase.BaseHPMax)
	--法术
	local Label_MagicPoint = tolua.cast(Image_BasePropPNL:getChildByName("Label_MagicPoint"), "Label")
	Label_MagicPoint:setText(cvsCardBase.MagicPoints)
	--武力
	local Label_ForcePoint = tolua.cast(Image_BasePropPNL:getChildByName("Label_ForcePoint"), "Label")
	Label_ForcePoint:setText(cvsCardBase.ForcePoints)
	--绝技
	local Label_SkillPoint = tolua.cast(Image_BasePropPNL:getChildByName("Label_SkillPoint"), "Label")
	Label_SkillPoint:setText(cvsCardBase.SkillPoints)
	
	g_SetBtnWithPressingEvent(Image_BasePropPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
end

function Game_CardHandBook:setImageProfessionInfoPNL(ListView_CardInfo,cardBaseInfo)
	local Image_ProfessionInfoPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_ProfessionInfoPNL"), "ImageView")
	--职业名称
	local Label_Profession = tolua.cast(Image_ProfessionInfoPNL:getChildByName("Label_Profession"), "Label")
	Label_Profession:setText(_T("职业").." "..g_Profession[cardBaseInfo.Profession])
	--职业描述
	local Label_ProfessionDesc = tolua.cast(Image_ProfessionInfoPNL:getChildByName("Label_ProfessionDesc"), "Label")
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_ProfessionDesc:setFontSize(16)
	end
	Label_ProfessionDesc:setText(g_ProfessionDesc[cardBaseInfo.Profession])
	
	g_SetBtnWithPressingEvent(Image_ProfessionInfoPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
end


function Game_CardHandBook:setImageSkillInfoPNL(ListView_CardInfo,cardBaseInfo)

	local Image_SkillInfoPNL = tolua.cast(ListView_CardInfo:getChildByName("Image_SkillInfoPNL"), "ImageView")
	for i = 1,SKILL_NUM do
		local csvSkillBase = g_DataMgr:getSkillBaseCsv(cardBaseInfo["PowerfulSkillID"..i])
		  
		local Button_Skill = tolua.cast(Image_SkillInfoPNL:getChildByName("Button_Skill"..i), "Button")
		
		local Image_Frame = tolua.cast(Button_Skill:getChildByName("Image_Frame"), "ImageView")
		Image_Frame:loadTexture(getUIImg("Frame_Evolute_DanYaoFrame1"))
		
		local Image_Cover = tolua.cast(Button_Skill:getChildByName("Image_Cover"), "ImageView")
		
		local Image_CoverShadow = tolua.cast(Button_Skill:getChildByName("Image_CoverShadow"), "ImageView")
		local Panel_SkillIcon = tolua.cast(Button_Skill:getChildByName("Panel_SkillIcon"), "Layout")
		Panel_SkillIcon:setClippingEnabled(true)
		Panel_SkillIcon:setRadius(43)
		
		local Image_SkillIcon = tolua.cast(Panel_SkillIcon:getChildByName("Image_SkillIcon"), "ImageView")
		Image_SkillIcon:loadTexture(getIconImg(csvSkillBase.Icon))
		
		--点击技能按钮--函数
		local function onClickSkillIcon(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				local tbString = {}
				local tbSkillDesc = {}
				table.insert(tbSkillDesc, csvSkillBase.Name)
				table.insert(tbString, tbSkillDesc)

				tbSkillDesc = {}
				table.insert(tbSkillDesc, csvSkillBase.Desc)
				table.insert(tbString, tbSkillDesc)

				local tbPos = pSender:getWorldPosition()
				tbPos.x = tbPos.x
				tbPos.y = tbPos.y + 160
				g_ClientMsgTips:showTip(tbString, tbPos, 3)
			end
		end	
		
        Button_Skill:setTag(i)
        Button_Skill:setTouchEnabled(true)
        Button_Skill:addTouchEventListener(onClickSkillIcon)		
	end
end

function Game_CardHandBook:setImageCardGroupPNL(ListView_CardInfo,cardBaseInfo)
	ListView_CardInfo:removeItem(6)
	ListView_CardInfo:removeItem(5)
	ListView_CardInfo:removeItem(4)
	ListView_CardInfo:removeItem(3)
	
	for cardGroupIndex = 1,CARD_GROUP_MAX_NUM do
	
		local groupID =  cardBaseInfo["CardGroupID"..cardGroupIndex]
		if groupID > 0 then 
			
			local Image_CardGroupPNL = ListView_CardInfo:pushBackDefaultItem()
			Image_CardGroupPNL:setPositionX(0)
			g_SetBtnWithPressingEvent(Image_CardGroupPNL, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
		
			local csvCardGroup = g_DataMgr:getCardGroupCsv(groupID)
			
			local Label_Name = tolua.cast(Image_CardGroupPNL:getChildByName("Label_Name"),"Label")
			Label_Name:setText(csvCardGroup.Name)
	
			local ImageView_Activate = tolua.cast(Image_CardGroupPNL:getChildByName("ImageView_Activate"),"ImageView")
			ImageView_Activate:setPositionX(Label_Name:getPositionX() + Label_Name:getContentSize().width + 10)
			
			local Label_Desc = tolua.cast(Image_CardGroupPNL:getChildByName("Label_Desc"),"Label")
			if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
				Label_Desc:setFontSize(16)
			end
			Label_Desc:setText(csvCardGroup.Desc)
	
			for i = 1,CARD_GROUP_ICON_NUM do 
	
				local Image_Condition = tolua.cast(Image_CardGroupPNL:getChildByName("Image_Condition"..i), "ImageView")
				Image_Condition:setVisible(false)
				
				local Image_Icon = tolua.cast(Image_Condition:getChildByName("Image_Icon"), "ImageView")
				local Image_Frame = tolua.cast(Image_Icon:getChildByName("Image_Frame"), "ImageView")
				Image_Frame:loadTexture(getCardFrameByEvoluteLev(1))
				
				local nStarLevel = 1
				local nEvoluteLevel = 1
				local cardId = csvCardGroup["CardID"..i]
				
				if cardId > 0 then 
					Image_Condition:setVisible(true)
					local GameObj_Card = g_Hero:getCardObjByCsvID(cardId)
					if GameObj_Card then
						nStarLevel = GameObj_Card:getStarLevel()
						nEvoluteLevel = GameObj_Card:getEvoluteLevel()
					else
						local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(cardId)
						nStarLevel = CSV_CardHunPo.CardStarLevel
					
					end
					
					local CSV_CardBase = g_DataMgr:getCardBaseCsv(cardId, nStarLevel)
					Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation))
					Image_Icon:setColor(g_getColor(ccs.COLOR.DEEP_GREY))
					
					local strDesc = string.format(_T("需要伙伴[%s]出战方可激活缘分属性"), CSV_CardBase.Name)
					
					local function onPressed_Image_Condition(pSender, nTag)
						local CSV_DropItem = {
							DropItemType = macro_pb.ITEM_TYPE_CARD,
							DropItemID = cardId,
							DropItemStarLevel = nStarLevel,
							DropItemNum = 0,
							DropItemEvoluteLevel = nEvoluteLevel,
							DropItemDesc = strDesc
						}
						g_WndMgr:showWnd("Game_TipDropItemCard", CSV_DropItem)
					end
					
					g_SetBtnWithEvent(Image_Condition, nil,  onPressed_Image_Condition, true)
					
				end
				
			end
		
		end
		
	end
	
end
