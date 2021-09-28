--------------------------------------------------------------------------------------
-- 文件名:	HJW_ChuanCheng.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  传承
---------------------------------------------------------------------------------------

Game_ChuanCheng = class("Game_ChuanCheng")
Game_ChuanCheng.__index = Game_ChuanCheng

g_LuaListView_TargetList_Index = 1
function Game_ChuanCheng:initWnd()
	local Image_ChuanChengPNL = tolua.cast(self.rootWidget:getChildByName("Image_ChuanChengPNL"),"ImageView")
	local Button_ChuanChengGuide = tolua.cast(Image_ChuanChengPNL:getChildByName("Button_ChuanChengGuide"), "Button")
	g_RegisterGuideTipButtonWithoutAni(Button_ChuanChengGuide)
	
	g_LuaListView_TargetList_Index = 1
end

function Game_ChuanCheng:openWnd(nCardId)

	if nCardId then 
		self.selecteId = 0
		self.selectCardTag = {}
		self.cardId_ = nCardId 
		
		self.chuanChengCard = {}
		local nHasSummonBattleCount = g_Hero:getHasSummonCardListCount()
		for index = 1,nHasSummonBattleCount do 
			local tbCard = g_Hero:getHasSummonCardByIndex(index)
			--主角和传功者不显示
			if tbCard and tbCard.nServerID ~= 1 and tbCard.nServerID ~= self.cardId_ then 
				table.insert(self.chuanChengCard,tbCard)
			end
		end
		
		
		self:chuanChengZhe()
		self:receiver()
	end
   
end

function Game_ChuanCheng:closeWnd()
	
end

--传功者
function Game_ChuanCheng:chuanChengZhe()
	local rootWidget = self.rootWidget
	local Image_ChuanChengPNL = tolua.cast(rootWidget:getChildByName("Image_ChuanChengPNL"), "ImageView")
	local Image_ChuanChengSourcePNL = tolua.cast(Image_ChuanChengPNL:getChildByName("Image_ChuanChengSourcePNL"), "ImageView")
	
	local tbCard = g_Hero:getCardObjByServID(self.cardId_)
	self:CardInfo(Image_ChuanChengSourcePNL,true,tbCard)

end


--被传承者
function Game_ChuanCheng:receiver()

	local rootWidget = self.rootWidget
	local Image_ChuanChengPNL = tolua.cast(rootWidget:getChildByName("Image_ChuanChengPNL"), "ImageView")
	local Image_TargetPNL = tolua.cast(Image_ChuanChengPNL:getChildByName("Image_TargetPNL"), "ImageView")
	local ListView_TargetList = tolua.cast(Image_TargetPNL:getChildByName("ListView_TargetList"), "ListViewEx")

	local LuaListView_TargetList = Class_LuaListView:new()
    self.LuaListView_TargetList = LuaListView_TargetList
    LuaListView_TargetList:setListView(ListView_TargetList)
	
	local Button_ChuanCheng = tolua.cast(Image_ChuanChengPNL:getChildByName("Button_ChuanCheng"), "Button")
	local BitmapLabel_NeedYuanBao = tolua.cast(Button_ChuanCheng:getChildByName("BitmapLabel_NeedYuanBao"), "LabelBMFont")
	local inheritCardCost = g_DataMgr:getGlobalCfgCsv("inherit_card_cost")
	BitmapLabel_NeedYuanBao:setText(inheritCardCost)
	
	local btnFlag = true
	local function onButtonCreate(pSender, index)
		if next(self.selectCardTag) ~= nil then 
			self.selectCardTag = {}
			 btnFlag = false
			 self.selecteId = 0
		else
			self.selectCardTag[pSender:getTag()] = "SELECT"
			local tbCard = self.chuanChengCard[index]
			self.selecteId = tbCard.nServerID
			btnFlag = true
		end
		self:receiver()
		Button_ChuanCheng:setTouchEnabled(btnFlag)
		Button_ChuanCheng:setBright(btnFlag)

	end
	
	local flag = true
	local function updateListViewItem(widget, nIndex)
	
		local tbCard = self.chuanChengCard[nIndex]
	
		local Button_TargetItem = tolua.cast(widget:getChildByName("Button_TargetItem"), "Button")
		g_SetBtnWithGuideCheck(Button_TargetItem,nIndex, onButtonCreate, true, nil, nil, nil)
		
		self:CardInfo(Button_TargetItem,false,tbCard)
		
		local CheckBox_Flag = tolua.cast(Button_TargetItem:getChildByName("CheckBox_Flag"), "CheckBox")

		if self.selectCardTag and self.selectCardTag[nIndex]=="SELECT" then 
			CheckBox_Flag:setSelectedState(true)
			flag = true
		else
			if self.selecteId > 0 then 
				CheckBox_Flag:setSelectedState(false)
				flag = false
			else
				CheckBox_Flag:setSelectedState(false)
				flag = true
			end
		end
		CheckBox_Flag:setBright(flag)
		Button_TargetItem:setTouchEnabled(flag)
		Button_TargetItem:setBright(flag)

		
	end

	local function onAdjustListView(widget, nIndex)
		g_LuaListView_TargetList_Index = nIndex
    end
	   
	local Panel_TargetItem = ListView_TargetList:getChildByName("Panel_TargetItem")
	 -- self.LuaPageView_Card:registerClickEvent(unction)
	self.LuaListView_TargetList:setAdjustFunc(onAdjustListView)
	
    self.LuaListView_TargetList:setModel(Panel_TargetItem)
    self.LuaListView_TargetList:setUpdateFunc(updateListViewItem)
	g_LuaListView_TargetList_Index = g_LuaListView_TargetList_Index or 1
	self.LuaListView_TargetList:updateItems(#self.chuanChengCard, g_LuaListView_TargetList_Index)
	
	-- 如果传承者的星级大于被传承者的星级
	-- 客户端模拟检测一下看是否有可能出现传承后上香属性大于上限值的情况。
	-- 如果有，则记录其属性的类型。
	-- 然后提示错误“被传承者星级较低，传承后上香属性超出上限部分暂时无法使用，是否继续？”
	
	local function chuanChengFunc(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then	
			local txt = string.format( _T("伙伴传承需要花费%d元宝，您的元宝不够是否前往充值？"), inheritCardCost)
			if not g_CheckYuanBaoConfirm(inheritCardCost,txt) then 
				return 
			end
			
			local cardInfo1 = g_Hero:getCardObjByServID(self.cardId_)
			local cardInfo2 = g_Hero:getCardObjByServID(self.selecteId)
			local starLv1 =	cardInfo1:getStarLevel()
			local starLv2 =	cardInfo2:getStarLevel()
			local txt = ""
			-- if starLv1 > starLv2 or starLv2 > starLv1 then 
			if g_CardChuanChengData:shangXiangSpill(self.cardId_,self.selecteId) then 
			-- if starLv1 ~= starLv2 then 
				txt = _T("传承后上香属性超出上限部分暂时无法使用，是否继续？")
			else
				
				txt = string.format( _T("伙伴传承需要花费%d元宝，是否传承？"),inheritCardCost)
			end
			-- 伙伴传承需要花费XX元宝，是否传承？
			g_ClientMsgTips:showConfirm(txt, function() 
				g_CardChuanChengData:requestInheritCardRequest(self.cardId_,self.selecteId)
				CHANG_CHENG_S = true
			end)
			
		end
	end
	
	
	Button_ChuanCheng:setTouchEnabled(false)
	Button_ChuanCheng:setBright(false)
	Button_ChuanCheng:addTouchEventListener(chuanChengFunc)
	
end

--卡牌信息
function Game_ChuanCheng:CardInfo(widget,flag,tbCard)

	local Image_CardBase = tolua.cast(widget:getChildByName("Image_CardBase"), "ImageView")
	local Image_Frame = tolua.cast(Image_CardBase:getChildByName("Image_Frame"), "ImageView")
	local Image_Icon = tolua.cast(Image_CardBase:getChildByName("Image_Icon"), "ImageView")
	local Image_StarLevel = tolua.cast(Image_CardBase:getChildByName("Image_StarLevel"), "ImageView")
	
	if not tbCard then return end
	local CSV_CardBase = tbCard:getCsvBase()
	--头像背景
	Image_CardBase:loadTexture(getCardBackByEvoluteLev(tbCard:getEvoluteLevel()))
	--头像边框
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))
	--头像星级
	Image_StarLevel:loadTexture(getIconStarLev(tbCard:getStarLevel()))
	--头像
	Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation) )
	--卡牌名称 +1
	local Label_Name = tolua.cast(widget:getChildByName("Label_Name"), "Label")
	Label_Name:setText(tbCard:getNameWithSuffix(Label_Name))	
		
	--境界等级 1/8
	local Label_RealmName = tolua.cast(widget:getChildByName("Label_RealmName"), "Label")
	Label_RealmName:setText(tbCard:getRealmNameWithSuffix(Label_RealmName))
	
	--职业
	local AtlasLabel_Profession = tolua.cast(widget:getChildByName("AtlasLabel_Profession"), "LabelAtlas")
	AtlasLabel_Profession:setValue(CSV_CardBase.Profession)	
	
	--卡牌等级
	if flag then 
		local LabelBMFont_Level = tolua.cast(widget:getChildByName("LabelBMFont_Level"), "LabelBMFont")
		LabelBMFont_Level:setText(_T("Lv.")..tbCard:getLevel())
		-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			g_AdjustWidgetsPosition({Label_Name, AtlasLabel_Profession,LabelBMFont_Level},10)
		-- end
	else
		local Label_Level = tolua.cast(widget:getChildByName("Label_Level"), "Label")
		Label_Level:setText(_T("Lv.")..tbCard:getLevel())
		
		-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			g_AdjustWidgetsPosition({Label_Name, Label_Level},10)
		-- end
	end

end


function Game_ChuanCheng:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ChuanChengPNL = tolua.cast(self.rootWidget:getChildByName("Image_ChuanChengPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ChuanChengPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ChuanCheng:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ChuanChengPNL = tolua.cast(self.rootWidget:getChildByName("Image_ChuanChengPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ChuanChengPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end
