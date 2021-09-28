--------------------------------------------------------------------------------------
-- 文件名:	HJW_ArenaKuaFuRank.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  
-- 日  期:	2016-7-15 
-- 版  本:	1.0
-- 描  述:	跨服服战排行榜
-- 应  用:  
---------------------------------------------------------------------------------------
Game_ArenaKuaFuRank = class("Game_ArenaKuaFuRank")
Game_ArenaKuaFuRank.__index = Game_ArenaKuaFuRank

Game_ArenaKuaFuRank.onAdjustIndex = 1

function Game_ArenaKuaFuRank:initWnd()
	self.endRank = g_ArenaKuaFuData:getMaxRankNum()
	local Image_ArenaRankPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRankPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ArenaRankPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	local ListView_RankList = tolua.cast(Image_ContentPNL:getChildByName("ListView_RankList"), "ListViewEx")
	local Panel_RankItem = tolua.cast(ListView_RankList:getChildByName("Panel_RankItem"), "Layout")

	if Panel_RankItem and eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		 local Label_TeamStrengthenLB = Panel_RankItem:getChildAllByName("Label_TeamStrengthenLB")
		 local BitmapLabel_TeamStrength = Panel_RankItem:getChildAllByName("BitmapLabel_TeamStrength")
		 g_AdjustWidgetsPosition({Label_TeamStrengthenLB, BitmapLabel_TeamStrength}, 1)
	end
	
	self:registerListViewEvent(ListView_RankList, Panel_RankItem)
	
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ArenaKuaFuaRankListUpdate, handler(self, self.updateItemInfo))
	
end

function Game_ArenaKuaFuRank:openWnd()
	if g_bReturn  then   return   end
	--每次打开后刷新前20名的排名
	-- if next(g_ArenaKuaFuData:getPlayerList()) == nil then 
		g_ArenaKuaFuData:requestCrossRankList(1, 20)
	-- end
	
	self:updateItemInfo()

end

function Game_ArenaKuaFuRank:closeWnd()
	self.LuaListView_RankList:updateItems(0)
	Game_ArenaKuaFuRank.onAdjustIndex = 1
	g_ArenaKuaFuData:setViewPlayerKuaFuFlag(true)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_Summon_updateData)
end

function Game_ArenaKuaFuRank:updateItemInfo()
	local nlen = #self:rankList()
	self.LuaListView_RankList:updateItems(nlen, Game_ArenaKuaFuRank.onAdjustIndex)
end

function Game_ArenaKuaFuRank:rankList()
	return g_ArenaKuaFuData:getPlayerList()
end

function Game_ArenaKuaFuRank:registerListViewEvent(ListView_RankList, ListViewModel)
    self.LuaListView_RankList = Class_LuaListView:new()
    self.LuaListView_RankList:setListView(ListView_RankList)
    local function updateFunction(ListViewItem, nIndex)
        self:setListViewItem(ListViewItem, nIndex)
    end
	local function onAdjustListView(ListViewItem, nIndex)
		Game_ArenaKuaFuRank.onAdjustIndex = nIndex
    end
    self.LuaListView_RankList:setUpdateFunc(updateFunction)
    self.LuaListView_RankList:setAdjustFunc(onAdjustListView)
    self.LuaListView_RankList:setModel(ListViewModel)
end

function Game_ArenaKuaFuRank:setListViewItem(widget, nIndex)
	
	local rankListData = self:rankList()[nIndex]
	local star_level = rankListData.star_level
	local branch_level = rankListData.branch_level
	local vip_level = rankListData.vip_level
	local fight_point = rankListData.fight_point
	local rank = rankListData.rank
	local uin = rankListData.uin
	local name = rankListData.name
	local world_id = rankListData.world_id
	local card_id = rankListData.card_id
	local level = rankListData.level
	
	local Button_RankItem = tolua.cast(widget:getChildByName("Button_RankItem"), "Button")
	
	local LabelBMFont_Rank = tolua.cast(Button_RankItem:getChildByName("LabelBMFont_Rank"), "LabelBMFont")
	LabelBMFont_Rank:setText(nIndex)

	local Label_Name = tolua.cast(Button_RankItem:getChildByName("Label_Name"), "Label")
	name = name == "小语" and _T("小语") or name
	Label_Name:setText(getFormatSuffixLevel(name, g_GetCardEvoluteSuffixByEvoLev(branch_level))..".s"..world_id)
	g_SetCardNameColorByEvoluteLev(Label_Name, branch_level)
	
	local Label_Level = tolua.cast(Button_RankItem:getChildByName("Label_Level"), "Label")
	Label_Level:setText(_T("Lv.")..level)
	
	local tbWidget = {[1] = Label_Name,[2] = Label_Level}
	g_AdjustWidgetsPosition(tbWidget, 12)
	
	local BitmapLabel_TeamStrength = tolua.cast(Button_RankItem:getChildByName("BitmapLabel_TeamStrength"), "LabelBMFont")
	BitmapLabel_TeamStrength:setText(fight_point)
	
	local Image_TitleIcon = tolua.cast(Button_RankItem:getChildByName("Image_TitleIcon"), "ImageView")
	local rankIndx = g_ArenaKuaFuData:returnRankArea(rank)
	local CSV_ArenaDailyReward = self:getArenaKuaFuCsv(rankIndx)
	Image_TitleIcon:loadTexture(getArenaImg(CSV_ArenaDailyReward.ClassIcon))

	local Image_Head = tolua.cast(Button_RankItem:getChildByName("Image_Head"),"ImageView")	
	Image_Head:loadTexture(getCardBackByEvoluteLev(branch_level))
	
	local Image_Icon = tolua.cast(Image_Head:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getCardIconImg(card_id, star_level))
	
	local Image_Frame = tolua.cast(Image_Head:getChildByName("Image_Frame"),"ImageView")	
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(branch_level))
	
	local function onClick_Image_Head(pSender, nTag)
		if uin == g_MsgMgr:getUin() then 
			g_ShowSysTips({text = _T("这是你自己哟亲~")})
			return 
		end
		g_ArenaKuaFuData:setViewPlayerKuaFuFlag(false)
		-- g_MsgMgr:requestViewPlayer(uin)
		-- g_ArenaKuaFuData:requestCrossViewPlayerDetail(uin)
		g_ArenaKuaFuData:requestCrossViewPlayerBriefReq(uin)
		
	end
	g_SetBtn(widget, "Image_Head", onClick_Image_Head, true)
	
	local LabelBMFont_VipLevel = tolua.cast(Image_Head:getChildByName("LabelBMFont_VipLevel"),"LabelBMFont")	
	if vip_level then LabelBMFont_VipLevel:setText(_T("VIP")..vip_level) end

	
	if uin == g_MsgMgr:getUin() then
		Button_RankItem:loadTextureNormal(getUIImg("Frame_Arena_Item1"))
		Button_RankItem:loadTexturePressed(getUIImg("Frame_Arena_Item1"))
		Button_RankItem:loadTextureDisabled(getUIImg("Frame_Arena_Item1"))
	else
		Button_RankItem:loadTextureNormal(getUIImg("Frame_Arena_Item2"))
		Button_RankItem:loadTexturePressed(getUIImg("Frame_Arena_Item2"))
		Button_RankItem:loadTextureDisabled(getUIImg("Frame_Arena_Item2"))
	end

	self:adjustListRequest(nIndex)
	
end

function Game_ArenaKuaFuRank:adjustListRequest(index)
	if index == #self:rankList() and index < self.endRank then
		local num = #self:rankList() + 20 > self.endRank and self.endRank or #self:rankList() + 20
		--数据下发的时候都是少一条数据
		if #self:rankList() == self.endRank - 1  then return end
		g_ArenaKuaFuData:requestCrossRankList(#self:rankList() + 1, num) 
	end
end

function Game_ArenaKuaFuRank:getArenaKuaFuCsv(rankIndx)
	return g_DataMgr:getCsvConfig("ArenaDailyRewardKuaFu")[rankIndx]
end

function Game_ArenaKuaFuRank:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ArenaRankPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRankPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ArenaRankPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ArenaKuaFuRank:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ArenaRankPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRankPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ArenaRankPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end