--------------------------------------------------------------------------------------
-- 文件名:	Game_CardLevelUp.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  伙伴升级
---------------------------------------------------------------------------------------

Game_CardLevelUp = class("Game_CardLevelUp")
Game_CardLevelUp.__index = Game_CardLevelUp

function Game_CardLevelUp:initWnd()
	local ImageView_CardLevelUpPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_CardLevelUpPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_CardLevelUpPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
    local ListView_CardLevelUp = tolua.cast(Image_ContentPNL:getChildByName("ListView_CardLevelUp"), "ListViewEx")
    local LuaListView_CardLevelUp = Class_LuaListView:new()
    self.LuaListView_CardLevelUp = LuaListView_CardLevelUp
	self:initListView_CardLevelUp()
    LuaListView_CardLevelUp:setListView(ListView_CardLevelUp)
	self:setButtonFilter()

end

function Game_CardLevelUp:openWnd(param)
    g_Hero:calcCurBattlePower()
	self.allitem = {} --保存选择增加经验的伙伴id和数量
	self.tiemTable = {} --保存定时器对象
	if param then
		self.itemId_ = param.id--要使用的物品id
		self.starLev_ = param.starLev --要使用的物品星级
		self.addValue_ = param.addValue or 0 --使用物品得到的经验
		self.nNum_ = param.num or 0 
	end
	
	local tbBattle = g_Hero:GetCardsList()
	
	self.tbBattle = {}
	
	for key,value in pairs(tbBattle) do
		if not value:checkIsLeader() then 
			table.insert(self.tbBattle,value) 
		end
	end
	self:selectCardType()
	
	if self.LuaListView_CardLevelUp then 
		self.LuaListView_CardLevelUp.widgetListView:setBounceEnabled(true)
	end
end

function Game_CardLevelUp:closeWnd()
	
	for key,value in pairs(self.tiemTable) do
		g_Timer:destroyTimerByID(value)
		value = nil
	end
	self.tiemTable = nil
	--向后台发送请求 
	self:requestUsetExpByUpdate()
	
	self.LuaListView_CardLevelUp:updateItems(0)
	self.itemId_ = nil 
	self.allitem = nil
	self.starLev_ = nil
	self.addValue_ = nil
	self.tbBattle = nil
	self.cardAll_ = nil
	self.nNum_ = nil
end

function Game_CardLevelUp:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_CardLevelUpPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_CardLevelUpPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_CardLevelUpPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_CardLevelUp:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_CardLevelUpPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_CardLevelUpPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(ImageView_CardLevelUpPNL, actionEndCall, 1.05, 0.15, Image_Background)
end

function Game_CardLevelUp:setButtonFilter()
	local ImageView_CardLevelUpPNL = tolua.cast(self.rootWidget:getChildByName("ImageView_CardLevelUpPNL"), "ImageView")
	local Button_Filter = tolua.cast(ImageView_CardLevelUpPNL:getChildByName("Button_Filter"), "Button")
	local function onClick(nTag)
		if self.tiemTable then 
			for key,value in pairs(self.tiemTable) do
				g_Timer:destroyTimerByID(value)
				value = nil
			end
			self.tiemTable = {}
		end
		self:selectCardType(nTag)
		self:initListView_CardLevelUp()
	end
	g_SetButtonFilter(Button_Filter,{{_T("全部"), _T("武圣"), _T("剑灵"), _T("飞羽"), _T("术师"), _T("将星")}, onClick})
end

function Game_CardLevelUp:selectCardType(typeTag)
	self.cardAll_ = {}
	if not typeTag or typeTag - 1 == 0 then
		self.cardAll_ = self.tbBattle
	else
		for key,value in pairs(self.tbBattle) do 
			local tTag = value:getCsvBase()
			if tTag.Profession+1==typeTag  then
		
				table.insert(self.cardAll_,value) 
			end
		end
	end
		
	local function sortHasSummonUnBattleCard(GameObj_CardA, GameObj_CardB)
		if GameObj_CardA.nBattleIndex ~= GameObj_CardB.nBattleIndex then
			return GameObj_CardA.nBattleIndex > GameObj_CardB.nBattleIndex
		end
		local nStarLevelA = GameObj_CardA:getStarLevel()
		local nStarLevelB = GameObj_CardB:getStarLevel()
		if nStarLevelA == nStarLevelB then
			local nEvoluteLevelA = GameObj_CardA:getEvoluteLevel()
			local nEvoluteLevelB = GameObj_CardB:getEvoluteLevel()
			if nEvoluteLevelA == nEvoluteLevelB then
				local nLevelA = GameObj_CardA:getLevel()
				local nLevelB = GameObj_CardB:getLevel()
				if nLevelA == nLevelB then
					return GameObj_CardA:getCsvBase().ID < GameObj_CardB:getCsvBase().ID
				else
					return nLevelA > nLevelB
				end
			else
				return nEvoluteLevelA > nEvoluteLevelB
			end
		else
			return nStarLevelA < nStarLevelB
		end
	
	end
	table.sort(self.cardAll_, sortHasSummonUnBattleCard)
	
	self.CardAllNum_ = #self.cardAll_
	local nMaxNum = math.floor((self.CardAllNum_ + 1)/2)
	self.LuaListView_CardLevelUp:updateItems(nMaxNum)
end

function Game_CardLevelUp:initListView_CardLevelUp()
	local nCount = 0
	local function onPressed_Button_CardItemLevelUp(pSender, eventType)
        if eventType == ccs.TouchEventType.ended then 
			local nIndex = pSender:getTag()
			local tbCard = self.cardAll_[nIndex]
			
			self.LuaListView_CardLevelUp.widgetListView:setBounceEnabled(false)
			
			if self.tiemTable[nIndex] ~= nil then 
				return 
			end
			if self.nNum_ == 0 then
				g_ClientMsgTips:showMsgConfirm(_T("道具使用完了"))
				return 
			end
			if tbCard:IsCardExpFull() then 
				g_ClientMsgTips:showMsgConfirm(_T("伙伴经验已满，无法继续升级"))
				return 
			end
			
			local nCurLevel = tbCard:getLevel()
			local nNewLevel = tbCard:getNewLvByAddExp(self.addValue_) --提升后的等级
			local nNewExp = tbCard:getExp() + self.addValue_
			
			if not self.allitem[tbCard.nServerID] then 
				self.allitem[tbCard.nServerID] = 1
			else
				self.allitem[tbCard.nServerID] = self.allitem[tbCard.nServerID] + 1
			end
			
			local LabelBMFont_Level = tolua.cast(pSender:getChildByName("LabelBMFont_Level"), "LabelBMFont")
			
			local Image_Exp = tolua.cast(pSender:getChildByName("Image_Exp"), "ImageView")
			local ProgressBar_Exp = tolua.cast(Image_Exp:getChildByName("ProgressBar_Exp"), "LoadingBar")
			local Label_ExpPercent = tolua.cast(Image_Exp:getChildByName("Label_ExpPercent"), "Label")
			local param1 = {
				nBeginPercent = tbCard:getCurExpPrecent(),	--开始时的百分比
				nEndPercent= tbCard:getNewExpPrecentByAddExp(self.addValue_),	--结束时的百分比
				nMaxCount = nNewLevel - nCurLevel,--进度条执行次数
				funcLoadingIntervalCall = function(nCurPercent)
					ProgressBar_Exp:setPercent(nCurPercent)
					Label_ExpPercent:setText(nCurPercent.."%")
				end,
				funcLoadingFullCall = function(nCount)
					LabelBMFont_Level:setText(_T("Lv.")..(nCurLevel + nCount))
				end,
				funcLoadingEndCall = function()
					g_Timer:destroyTimerByID(self.tiemTable[nIndex])
					self.tiemTable[nIndex] = nil
					
					if nNewExp >= tbCard:getMaxLevMaxExp() then
						Label_ExpPercent:setText(_T("已满级"))
					end
					LabelBMFont_Level:setText(_T("Lv.")..nNewLevel)
					tbCard:setLevel(nNewLevel)
					tbCard:setExp(nNewExp)
					nCount = nCount - 1
					
					if #self.tiemTable == nCount then
						self.LuaListView_CardLevelUp.widgetListView:setBounceEnabled(true)
					end		
				end
			}
			local nTimerID =  g_loadingBarAnimation(param1)
			self.tiemTable[nIndex] = nTimerID
			self.nNum_ = self.nNum_ - 1
			nCount = nCount + 1
		end
    end
	
	local function setButton_CardItemLevelUp(Button_CardItemLevelUp, nIndex)
		local tbCard = self.cardAll_[nIndex]
		local CSV_CardBase = tbCard:getCsvBase()
		--头像背景
		local Image_CardBase = tolua.cast(Button_CardItemLevelUp:getChildByName("Image_CardBase"), "ImageView")
		Image_CardBase:loadTexture(getCardBackByEvoluteLev(tbCard:getEvoluteLevel()))
		
		--头像边框
		local Image_Frame = tolua.cast(Image_CardBase:getChildByName("Image_Frame"), "ImageView")
		Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))

		--头像星级
		local Image_StarLevel = tolua.cast(Image_CardBase:getChildByName("Image_StarLevel"), "ImageView")
		Image_StarLevel:loadTexture(getIconStarLev(tbCard:getStarLevel()))
		
		--头像
		local Image_Icon = tolua.cast(Image_CardBase:getChildByName("Image_Icon"), "ImageView")
		Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation) )
		--等级 
		local LabelBMFont_Level = tolua.cast(Button_CardItemLevelUp:getChildByName("LabelBMFont_Level"), "LabelBMFont")
		LabelBMFont_Level:setText(_T("Lv.")..tbCard:getLevel())
		
		--伙伴名称
		local Label_Name = tolua.cast(Button_CardItemLevelUp:getChildByName("Label_Name"), "Label")
		Label_Name:setText(tbCard:getNameWithSuffix(Label_Name))

		--职业
		local AtlasLabel_Profession = tolua.cast(Button_CardItemLevelUp:getChildByName("AtlasLabel_Profession"), "LabelAtlas")
		AtlasLabel_Profession:setStringValue(CSV_CardBase.Profession)
		g_AdjustWidgetsPosition({Label_Name, AtlasLabel_Profession}, 10)
		
		--境界
		local Label_RealmName = tolua.cast(Button_CardItemLevelUp:getChildByName("Label_RealmName"), "Label")
		Label_RealmName:setText(tbCard:getRealmNameWithSuffix(Label_RealmName))
		
		--经验进度条
		local nExpPercent = tbCard:getCurExpPrecent()
		local Image_Exp = tolua.cast(Button_CardItemLevelUp:getChildByName("Image_Exp"), "ImageView")
		local ProgressBar_Exp = tolua.cast(Image_Exp:getChildByName("ProgressBar_Exp"), "LoadingBar")
		ProgressBar_Exp:setPercent(nExpPercent)
		--是否等于主角当前等级 
		local Label_ExpPercent = tolua.cast(Image_Exp:getChildByName("Label_ExpPercent"), "Label")
		if tbCard:IsCardExpFull() then 
			Label_ExpPercent:setText(_T("已满级"))
		else
			Label_ExpPercent:setText(nExpPercent.."%")
		end
		
		Button_CardItemLevelUp:setTouchEnabled(true)
		Button_CardItemLevelUp:addTouchEventListener(onPressed_Button_CardItemLevelUp)
		Button_CardItemLevelUp:setTag(nIndex)
	end
	
	local function updateListViewItem(Panel_CardItemLevelUp, nIndex)
		Panel_CardItemLevelUp:removeAllChildrenWithCleanup(true)
		local nBegin = (nIndex * 2 ) - 1
		if nBegin <= self.CardAllNum_ then
			local Button_CardItemLevelUp1 =  Panel_CardItemLevelUp:getChildByName("Button_CardItemLevelUp1")
			if not Button_CardItemLevelUp1 then
				Button_CardItemLevelUp1 = g_WidgetModel.Button_CardItemLevelUp1:clone()
				Button_CardItemLevelUp1:setName("Button_CardItemLevelUp1")
				Panel_CardItemLevelUp:addChild(Button_CardItemLevelUp1)
			end
			setButton_CardItemLevelUp(Button_CardItemLevelUp1, nBegin)
			Button_CardItemLevelUp1:setPositionXY(275,80)	 
          
			if nBegin + 1 <= self.CardAllNum_ then
				local Button_CardItemLevelUp2 =  Panel_CardItemLevelUp:getChildByName("Button_CardItemLevelUp2")
				if not Button_CardItemLevelUp2 then
					Button_CardItemLevelUp2 = g_WidgetModel.Button_CardItemLevelUp1:clone()
					Button_CardItemLevelUp2:setName("Button_CardItemLevelUp2")
					Panel_CardItemLevelUp:addChild(Button_CardItemLevelUp2)
				end
				setButton_CardItemLevelUp(Button_CardItemLevelUp2, nBegin+1)
				Button_CardItemLevelUp2:setPositionXY(835,80)
            else
				local Button_CardItemLevelUp2 = Panel_CardItemLevelUp:getChildByName("Button_CardItemLevelUp2")
                if Button_CardItemLevelUp2 then
                    Button_CardItemLevelUp2:removeFromParentAndCleanup(true)
                end
			end
		end
	end

    local Panel_CardItemLevelUp = Layout:create()
    Panel_CardItemLevelUp:setSize(CCSizeMake(1110, 160))
    self.LuaListView_CardLevelUp:setModel(Panel_CardItemLevelUp)
    self.LuaListView_CardLevelUp:setUpdateFunc(updateListViewItem)
end

--吃经验,升级
function Game_CardLevelUp:requestUsetExpByUpdate()
	if next(self.allitem)~= nil then 
		local rootMsg = zone_pb.UseItemRequest()
		rootMsg.item_id = self.itemId_
		for key,value in pairs(self.allitem) do 
			local itemInfo = zone_pb.UseItemInfo()
			itemInfo.object_id = key
			itemInfo.use_num = value
			table.insert(rootMsg.use_item_info, itemInfo)
		end
		g_MsgMgr:sendMsg(msgid_pb.MSGID_USE_ITEM_REQUEST,rootMsg)
	end
	
end