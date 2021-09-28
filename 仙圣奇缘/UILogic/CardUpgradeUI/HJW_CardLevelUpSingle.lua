--------------------------------------------------------------------------------------
-- 文件名:	HJW_CardLevelUpSingle.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  伙伴升级
---------------------------------------------------------------------------------------

Game_CardLevelUpSingle = class("Game_CardLevelUpSingle")
Game_CardLevelUpSingle.__index = Game_CardLevelUpSingle

function Game_CardLevelUpSingle:initWnd()
	local Image_CardLevelUpSinglePNL = tolua.cast(self.rootWidget:getChildByName("Image_CardLevelUpSinglePNL"), "ImageView")
	local Image_Arrow = tolua.cast(Image_CardLevelUpSinglePNL:getChildByName("Image_Arrow"), "ImageView")
	g_CreateUpAndDownAnimation(Image_Arrow, 0.6)
		
	self:itemListShow()
end

function Game_CardLevelUpSingle:openWnd(param)
	self.tbCardInfo = nil
	self.CSV_ItemBase_ = nil
	if param then
		self.tbCardInfo = param.cardInfo
	end
	self.tbUserItem = {}
	self.tiemTable = nil
	self:cardInfoInit()
	self:expPropListInit()

end

function Game_CardLevelUpSingle:closeWnd()
	-- for key,value in pairs(self.tiemTable) do
		g_Timer:destroyTimerByID(self.tiemTable)
		self.tiemTable = nil
	-- end
	
	self.LuaListView_UseItemList:updateItems(0)

	--向后台发送请求 
	self:requestComUseItemRequest()
	
	self.tbUserItem = nil
	local wndEquip = g_WndMgr:getWnd("Game_Equip1")
	if wndEquip then 
		local propertyForm = 2 
		wndEquip.ckEquip:Click(propertyForm)
	end
	
end


function Game_CardLevelUpSingle:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_CardLevelUpSinglePNL = tolua.cast(self.rootWidget:getChildByName("Image_CardLevelUpSinglePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_CardLevelUpSinglePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_CardLevelUpSingle:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_CardLevelUpSinglePNL = tolua.cast(self.rootWidget:getChildByName("Image_CardLevelUpSinglePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_CardLevelUpSinglePNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

--卡牌信息
function Game_CardLevelUpSingle:cardInfoInit()
	local tbCard = self.tbCardInfo
	if not tbCard then return end
	if not tbCard.getCsvBase then return end 
	local CSV_CardBase = tbCard:getCsvBase()
	local rootWidget = self.rootWidget
	local Image_CardLevelUpSinglePNL = tolua.cast(rootWidget:getChildByName("Image_CardLevelUpSinglePNL"), "ImageView")
	
	local Image_LevelUpTargetPNL = tolua.cast(Image_CardLevelUpSinglePNL:getChildByName("Image_LevelUpTargetPNL"), "ImageView")
	--底框
	local Image_CardBase = tolua.cast(Image_LevelUpTargetPNL:getChildByName("Image_CardBase"), "ImageView")
	Image_CardBase:loadTexture(getCardBackByEvoluteLev(tbCard:getEvoluteLevel()))
	--外框
	local Image_Frame = tolua.cast(Image_CardBase:getChildByName("Image_Frame"), "ImageView")
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbCard:getEvoluteLevel()))
	--头像
	local Image_Icon = tolua.cast(Image_CardBase:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getIconImg(CSV_CardBase.SpineAnimation) )
	--星级
	local Image_StarLevel = tolua.cast(Image_CardBase:getChildByName("Image_StarLevel"), "ImageView")
	Image_StarLevel:loadTexture(getIconStarLev(tbCard:getStarLevel()))
	--卡牌名称 +突破等级
	local Label_Name = tolua.cast(Image_LevelUpTargetPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(tbCard:getNameWithSuffix(Label_Name))
	--等级
	local LabelBMFont_Level = tolua.cast(Image_LevelUpTargetPNL:getChildByName("LabelBMFont_Level"), "LabelBMFont")
	LabelBMFont_Level:setText(string.format(_T("Lv.%d"), tbCard:getLevel()))
	--卡牌类型
	local AtlasLabel_Profession = tolua.cast(Image_LevelUpTargetPNL:getChildByName("AtlasLabel_Profession"), "LabelAtlas")
	AtlasLabel_Profession:setStringValue(CSV_CardBase.Profession)
	-- g_AdjustWidgetsPosition({Label_Name, AtlasLabel_Profession}, 10)
	--进度条
	local Image_Exp = tolua.cast(Image_LevelUpTargetPNL:getChildByName("Image_Exp"), "ImageView")
	
	--进度条
	local ProgressBar_Exp = tolua.cast(Image_Exp:getChildByName("ProgressBar_Exp"), "LoadingBar")
	local nExpPrecent =  math.min(100, tbCard:getCurExpPrecent())
	if nExpPrecent < 0 then nExpPrecent = 0 end
	local txt = nExpPrecent
    ProgressBar_Exp:setPercent(nExpPrecent)
	--百分比数值
	local Label_ExpPercent = tolua.cast(Image_Exp:getChildByName("Label_ExpPercent"), "Label")
	Label_ExpPercent:setText(txt.."%")
	
	g_AdjustWidgetsPosition({Label_Name, AtlasLabel_Profession, LabelBMFont_Level},10)

end


function Game_CardLevelUpSingle:itemListShow()
	self.tbItemUserList = {}
	local tbItemList = g_Hero:getItemList()
	for k, v in pairs (tbItemList) do
		if v.tbCsvBase.Type == 6 then 
			local id =  v.tbCsvBase.ID
			local starLevel =  v.tbCsvBase.StarLevel
			local haveNum = g_Hero:getItemNumByCsv(id,starLevel)
			if haveNum >= 0 then 
				table.insert(self.tbItemUserList,{obj = tbItemList[k],csvBase = v.tbCsvBase})
			end
		end
	end
	
	local function ItemUserExeSort(one,two)
		if one.csvBase.ID == two.csvBase.ID then 
			return one.csvBase.StarLevel < two.csvBase.StarLevel
		else
			return one.csvBase.ID < two.csvBase.ID
		end
	end
	table.sort(self.tbItemUserList, ItemUserExeSort)
end
--经验道具
function Game_CardLevelUpSingle:expPropListInit()
	local nCount = #self.tbItemUserList

	local rootWidget = self.rootWidget
	local Image_CardLevelUpSinglePNL = tolua.cast(rootWidget:getChildByName("Image_CardLevelUpSinglePNL"), "ImageView")
	local Image_UseItemPNL = tolua.cast(Image_CardLevelUpSinglePNL:getChildByName("Image_UseItemPNL"), "ImageView")
	local ListView_UseItemList = tolua.cast(Image_UseItemPNL:getChildByName("ListView_UseItemList"), "ListViewEx")
	
    local LuaListView_UseItemList = Class_LuaListView:new()
    LuaListView_UseItemList:setListView(ListView_UseItemList)
	self.LuaListView_UseItemList = LuaListView_UseItemList

	local Panel_UseItem = tolua.cast(ListView_UseItemList:getChildByName("Panel_UseItem"), "Layout")
	local function updateListViewItem(widget, nIndex)
		local CSV_ItemBase = self.tbItemUserList[nIndex].csvBase
		self.CSV_ItemBase_ = CSV_ItemBase
		local haveNum = g_Hero:getItemNumByCsv(CSV_ItemBase.ID, CSV_ItemBase.StarLevel)
		local desc = CSV_ItemBase.Desc
		local name = CSV_ItemBase.Name
		local icon = CSV_ItemBase.Icon
		local obj = self.tbItemUserList[nIndex].obj
		local expItemServerId = obj:getServerId()
		local Button_UseItem = tolua.cast(widget:getChildByName("Button_UseItem"),"Button")
		--道具底框
		local Image_PackageIconUseItem = tolua.cast(Button_UseItem:getChildByName("Image_PackageIconUseItem"),"ImageView")
		Image_PackageIconUseItem:loadTexture(getFrameBackGround(CSV_ItemBase.ColorType))
		
		local Image_Icon = tolua.cast(Image_PackageIconUseItem:getChildByName("Image_Icon"),"ImageView")
		Image_Icon:loadTexture(getIconImg(icon))
		--道具外框
		local Image_Frame = tolua.cast(Image_PackageIconUseItem:getChildByName("Image_Frame"),"ImageView")
		Image_Frame:loadTexture(getIconFrame(CSV_ItemBase.ColorType))
		--道具数量
		local Label_HaveNum = tolua.cast(Image_PackageIconUseItem:getChildByName("Label_HaveNum"),"Label")
		Label_HaveNum:setText(haveNum)
		--道具名称
		local Label_Name = tolua.cast(Button_UseItem:getChildByName("Label_Name"),"Label")
		Label_Name:setText(name)
		g_SetWidgetColorBySLev(Label_Name, CSV_ItemBase.ColorType)
		--道具描述
		local Label_Desc = tolua.cast(Button_UseItem:getChildByName("Label_Desc"),"Label")
		Label_Desc:setText(g_stringSize_insert(desc,"\n",22,350))
		--使用按钮
		local Button_Use = tolua.cast(Button_UseItem:getChildByName("Button_Use"),"Button")
		local function onAddExp(pSender, nTag)
			local wndInstance = g_WndMgr:getWnd("Game_CardLevelUpSingle")
			if wndInstance then
				if wndInstance.tiemTable ~= nil then 
					cclog("动画还在进行中")
					return 
				end
				if haveNum == 0 then
					g_ClientMsgTips:showMsgConfirm( _T("道具使用完了") )
					return 
				end
				
				if not wndInstance.tbCardInfo then return end
				if wndInstance.tbCardInfo == {} then return end
				
				if wndInstance.tbCardInfo:IsCardExpFull() then 
					g_ClientMsgTips:showMsgConfirm( _T("伙伴经验已满，无法继续升级") )
					return 
				end
							
				local nCurLevel = wndInstance.tbCardInfo:getLevel()
				local nNewLevel = wndInstance.tbCardInfo:getNewLvByAddExp(CSV_ItemBase.AddValue) --提升后的等级
				local nNewExp = wndInstance.tbCardInfo:getExp() + CSV_ItemBase.AddValue
				if not wndInstance.tbUserItem[expItemServerId] then --转换为更为易懂的逻辑
					wndInstance.tbUserItem[expItemServerId] = 1
				else
					wndInstance.tbUserItem[expItemServerId] = wndInstance.tbUserItem[expItemServerId] + 1
				end
				
				local Image_CardLevelUpSinglePNL = tolua.cast(rootWidget:getChildByName("Image_CardLevelUpSinglePNL"), "ImageView")
				local Image_LevelUpTargetPNL = tolua.cast(Image_CardLevelUpSinglePNL:getChildByName("Image_LevelUpTargetPNL"), "ImageView")
				--等级
				local LabelBMFont_Level = tolua.cast(Image_LevelUpTargetPNL:getChildByName("LabelBMFont_Level"), "LabelBMFont")
				--进度条
				local Image_Exp = tolua.cast(Image_LevelUpTargetPNL:getChildByName("Image_Exp"), "ImageView")
				--进度条
				local ProgressBar_Exp = tolua.cast(Image_Exp:getChildByName("ProgressBar_Exp"), "LoadingBar")
				--百分比数值
				local Label_ExpPercent = tolua.cast(Image_Exp:getChildByName("Label_ExpPercent"), "Label")
				local param1 = {
					nBeginPercent = wndInstance.tbCardInfo:getCurExpPrecent(),	--开始时的百分比
					nEndPercent= wndInstance.tbCardInfo:getNewExpPrecentByAddExp(CSV_ItemBase.AddValue),	--结束时的百分比
					nMaxCount = nNewLevel - nCurLevel,--进度条执行次数
					funcLoadingIntervalCall = function(nCurPercent)
						ProgressBar_Exp:setPercent(nCurPercent)
						Label_ExpPercent:setText(nCurPercent.."%")
					end,
					funcLoadingFullCall = function(nCount)
						LabelBMFont_Level:setText(_T("Lv.")..(nCurLevel + nCount))
					end,
					funcLoadingEndCall = function()
						g_Timer:destroyTimerByID(wndInstance.tiemTable)
						wndInstance.tiemTable = nil
						
						if nNewExp >= wndInstance.tbCardInfo:getMaxLevMaxExp() then
							Label_ExpPercent:setText(_T("已满级"))
						end
						LabelBMFont_Level:setText(_T("Lv.")..nNewLevel)
				
						wndInstance.tbCardInfo:setLevel(nNewLevel)
						wndInstance.tbCardInfo:setExp(nNewExp)
					end
				}
	
				wndInstance.tiemTable =  g_loadingBarAnimation(param1)
				
				haveNum = haveNum - 1
				g_Hero:setItemNum(expItemServerId,haveNum)
				if haveNum == 0 then 
					wndInstance:itemListShow()
					wndInstance.LuaListView_UseItemList:updateItems(0)
					wndInstance:expPropListInit()
				else
					Label_HaveNum:setText(haveNum)
				end
			end
		end
		g_SetBtnWithGuideCheck(Button_Use, 1, onAddExp, true)
	end
    LuaListView_UseItemList:setModel(Panel_UseItem)
    LuaListView_UseItemList:setUpdateFunc(updateListViewItem)
	LuaListView_UseItemList:updateItems(nCount)
	
end

--使用物品请求
function Game_CardLevelUpSingle:requestComUseItemRequest()
	local rootMsg = zone_pb.ComUseItemRequest()
	if next(self.tbUserItem) ~= nil then 
		if not self.tbCardInfo then return end
		if not self.tbCardInfo.getServerId then return end
		for key,value in pairs(self.tbUserItem) do
			if key and key > 0 then
				local useItem = zone_pb.ComUseItem()
				useItem.item_id = key		-- 使用物品id
				useItem.use_num = value	-- 使用数量
				useItem.object_id = self.tbCardInfo:getServerId()
				table.insert(rootMsg.info,useItem)
			else
				cclog("有为空的========================")
			end
		end
		g_MsgMgr:sendMsg(msgid_pb.MSGID_COM_USE_ITEM_REQUEST,rootMsg)
		
		
		g_ErrorMsg:ListenMsg(msgid_pb.MSGID_COM_USE_ITEM_REQUEST)
		

	end
end

