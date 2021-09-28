--------------------------------------------------------------------------------------
-- ÎÄ¼þÃû:	LKA_CArenaRank.lua
-- °æ  È¨:	(C)ÉîÛÚÃÀÌì»¥¶¯¿Æ¼¼ÓÐÏÞ¹«Ë¾
-- ´´½¨ÈË:  Â½¿ü°²
-- ÈÕ  ÆÚ:	2013-12-10 10:24
-- °æ  ±¾:	1.0
-- Ãè  Êö:	¾º¼¼³¡½çÃæ
-- Ó¦  ÓÃ:  ±¾Àý×ÓÊ¹ÓÃÒ»°ã·½·¨µÄÊµÏÖScene
---------------------------------------------------------------------------------------
Game_ArenaRank = class("Game_ArenaRank")
Game_ArenaRank.__index = Game_ArenaRank

g_ListView_RankList_Index = 1

local ArenaViewList = nil
local max_rank = 1
function Game_ArenaRank:setListViewItem(widget, nIndex)
	local Button_RankItem = tolua.cast(widget:getChildByName("Button_RankItem"), "Button")
	
	local LabelBMFont_Rank = tolua.cast(Button_RankItem:getChildByName("LabelBMFont_Rank"), "LabelBMFont")
	LabelBMFont_Rank:setText(nIndex)

	local Label_Name = tolua.cast(Button_RankItem:getChildByName("Label_Name"), "Label")
	if ArenaViewList[nIndex].role_name == "小语" then
		ArenaViewList[nIndex].role_name = _T("小语")
	end
	
	Label_Name:setText(getFormatSuffixLevel(ArenaViewList[nIndex].role_name, g_GetCardEvoluteSuffixByEvoLev(ArenaViewList[nIndex].breach_lv)))
	g_SetCardNameColorByEvoluteLev(Label_Name, ArenaViewList[nIndex].breach_lv)
	
	local BitmapLabel_TeamStrength = tolua.cast(Button_RankItem:getChildByName("BitmapLabel_TeamStrength"), "LabelBMFont")
	BitmapLabel_TeamStrength:setText(ArenaViewList[nIndex].fighting_point)
	
	local Label_Level = tolua.cast(Button_RankItem:getChildByName("Label_Level"), "Label")
	Label_Level:setText(_T("Lv.")..ArenaViewList[nIndex].role_lv)
	local tbWidget = {[1] = Label_Name,[2] = Label_Level}
	g_AdjustWidgetsPosition(tbWidget, 12)
	
	local Image_TitleIcon = tolua.cast(Button_RankItem:getChildByName("Image_TitleIcon"), "ImageView") 
	local Interval = getArenaIntervalValue(nIndex)
	local CSV_ArenaDailyReward = g_DataMgr:getArenaDailyRewardCsv(Interval)
	Image_TitleIcon:loadTexture(getArenaImg(CSV_ArenaDailyReward.ClassIcon))

	local id = ArenaViewList[nIndex].main_card_cfg_id
	local star = ArenaViewList[nIndex].main_card_star
	local breach_lv = ArenaViewList[nIndex].breach_lv
	--Í·Ïñ
	local Image_Head = tolua.cast(Button_RankItem:getChildByName("Image_Head"),"ImageView")	
	Image_Head:loadTexture(getCardBackByEvoluteLev(breach_lv))
	local Image_Icon = tolua.cast(Image_Head:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getCardIconImg(id,star))
	local Image_Frame = tolua.cast(Image_Head:getChildByName("Image_Frame"),"ImageView")	
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(breach_lv))
	local LabelBMFont_VipLevel = tolua.cast(Image_Head:getChildByName("LabelBMFont_VipLevel"),"LabelBMFont")	
	
	local function onClick_Image_Head(pSender, nTag)
		g_MsgMgr:requestViewPlayer(ArenaViewList[nIndex].role_uin)
	end
	
	g_SetBtn(widget, "Image_Head", onClick_Image_Head, true)
	
	local vip = ArenaViewList[nIndex].vip_lev 
	
	if vip then
		LabelBMFont_VipLevel:setText(_T("VIP")..vip)
	end
	if nIndex == #ArenaViewList and nIndex < max_rank then
		g_MsgMgr:requestArenaRankListRequest(#ArenaViewList + 1,math.min(max_rank, #ArenaViewList + 20)) 
	end
	
	if ArenaViewList[nIndex].role_uin == g_MsgMgr:getUin() then
		Button_RankItem:loadTextureNormal(getUIImg("Frame_Arena_Item1"))
		Button_RankItem:loadTexturePressed(getUIImg("Frame_Arena_Item1"))
		Button_RankItem:loadTextureDisabled(getUIImg("Frame_Arena_Item1"))
	else
		Button_RankItem:loadTextureNormal(getUIImg("Frame_Arena_Item2"))
		Button_RankItem:loadTexturePressed(getUIImg("Frame_Arena_Item2"))
		Button_RankItem:loadTextureDisabled(getUIImg("Frame_Arena_Item2"))
	end
end

------------initListViewListEx---------
function Game_ArenaRank:registerListViewEvent(ListView_RankList, ListViewModel)
    self.LuaListView_RankList = Class_LuaListView:new()
    self.LuaListView_RankList:setListView(ListView_RankList)
    local function updateFunction(ListViewItem, nIndex)
        self:setListViewItem(ListViewItem, nIndex)
    end
	local function onAdjustListView(ListViewItem, nIndex)
		g_ListView_RankList_Index = nIndex
    end
    self.LuaListView_RankList:setUpdateFunc(updateFunction)
    self.LuaListView_RankList:setAdjustFunc(onAdjustListView)
    self.LuaListView_RankList:setUpdateFunc(updateFunction)
    self.LuaListView_RankList:setModel(ListViewModel)
end

function Game_ArenaRank:initWnd()
	g_ListView_RankList_Index = 1
	
	local Image_ArenaRankPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRankPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ArenaRankPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	local ListView_RankList = tolua.cast(Image_ContentPNL:getChildByName("ListView_RankList"), "ListViewEx")
	local Panel_RankItem = tolua.cast(ListView_RankList:getChildByName("Panel_RankItem"), "Layout")

	if Panel_RankItem and eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		 local Label_TeamStrengthenLB = Panel_RankItem:getChildAllByName("Label_TeamStrengthenLB")
		 local BitmapLabel_TeamStrength = Panel_RankItem:getChildAllByName("BitmapLabel_TeamStrength")
		 g_AdjustWidgetsPosition({Label_TeamStrengthenLB, BitmapLabel_TeamStrength}, 1)
	end
	self:registerListViewEvent(ListView_RankList,Panel_RankItem)
	
	local imgScrollSlider = ListView_RankList:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_RankList_X then
		g_tbScrollSliderXY.ListView_RankList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_RankList_X - 2)
end

local function setRoleArenaInfo(nIndex,tbRankData)
	if not tbRankData or tbRankData == {} then
		return
	end
	ArenaViewList = ArenaViewList or {}
	ArenaViewList[tbRankData.rank] = {}
	ArenaViewList[tbRankData.rank].role_uin = tbRankData.role_uin
	ArenaViewList[tbRankData.rank].role_name = tbRankData.role_name
	ArenaViewList[tbRankData.rank].fighting_point = tbRankData.fighting_point
	ArenaViewList[tbRankData.rank].official_rank = tbRankData.official_rank
	ArenaViewList[tbRankData.rank].main_card_cfg_id = tbRankData.main_card_cfg_id
	ArenaViewList[tbRankData.rank].main_card_star = tbRankData.main_card_star
	ArenaViewList[tbRankData.rank].vip_lev = tbRankData.vip_lev
	ArenaViewList[tbRankData.rank].rank = tbRankData.rank
	ArenaViewList[tbRankData.rank].role_lv = tbRankData.role_lv
	ArenaViewList[tbRankData.rank].breach_lv = tbRankData.breach_lv
end

function UpdateArenaNotifyData(msgData)
	local rank_list = msgData.rank_list
	max_rank = msgData.max_rank
	if rank_list then
		for i,v in ipairs(rank_list) do
			setRoleArenaInfo(i,v)
		end
	end
end

function Game_ArenaRank:checkData()

	if not ArenaViewList then
		ArenaViewList = {}
		g_MsgMgr:requestArenaRankListRequest(1,20) 
		return false
	else
	end

	return true
end

function Game_ArenaRank:closeWnd()
	self.LuaListView_RankList:updateItems(0)
	ArenaViewList = nil
end


function Game_ArenaRank:openWnd()
	if g_bReturn  then  return  end
	local nlen = #ArenaViewList
	self.LuaListView_RankList:updateItems(nlen, g_ListView_RankList_Index)

end

function Game_ArenaRank:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ArenaRankPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRankPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ArenaRankPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ArenaRank:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ArenaRankPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRankPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ArenaRankPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end