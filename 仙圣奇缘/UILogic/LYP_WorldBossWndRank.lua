--------------------------------------------------------------------------------------
-- 文件名:	LYP_WorldBossRank.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2014-11-20 9:37
-- 版  本:	1.0
-- 描  述:	召唤界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
Game_WorldBossRank = class("Game_WorldBossRank")
Game_WorldBossRank.__index = Game_WorldBossRank

function Game_WorldBossRank:initWnd()
	local Image_WorldBossRankPNL = tolua.cast(self.rootWidget:getChildByName("Image_WorldBossRankPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_WorldBossRankPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local ListView_WorldBossRankList = tolua.cast(Image_ContentPNL:getChildByName("ListView_WorldBossRankList"),"ListViewEx")
    local LuaListView_WorldBossRankList = Class_LuaListView:new()
    LuaListView_WorldBossRankList:setListView(ListView_WorldBossRankList)
    local Panel_WorldBossRankItem = ListView_WorldBossRankList:getChildByName("Panel_WorldBossRankItem")
    LuaListView_WorldBossRankList:setModel(Panel_WorldBossRankItem)
    LuaListView_WorldBossRankList:setUpdateFunc(handler(self, self.updateListViewItem))
    self.LuaListView_WorldBossRankList = LuaListView_WorldBossRankList
    g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BOSS_RANKLIST_RESPONSE, handler(self, self.requestRankDataResponse) )
	
	local imgScrollSlider = LuaListView_WorldBossRankList:getScrollSlider()
	if not g_tbScrollSliderXY.LuaListView_WorldBossRankList_X then
		g_tbScrollSliderXY.LuaListView_WorldBossRankList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_WorldBossRankList_X - 2)
end 

function Game_WorldBossRank:requestRankDataResponse(tbMsg)
	local msg = zone_pb.BossRankListResponse()
	msg:ParseFromString(tbMsg.buffer)
    cclog(tostring(msg))

	local wndInstance = g_WndMgr:getWnd("Game_WorldBossRank")
	if wndInstance then
		wndInstance.tbDamageInfo = wndInstance.tbDamageInfo or {}
		local tbBossDamage = msg.rank_list
		for i=1, #tbBossDamage do
			table.insert(wndInstance.tbDamageInfo, tbBossDamage[i])
		end
		
		wndInstance.LuaListView_WorldBossRankList:updateItems(#wndInstance.tbDamageInfo, wndInstance.nCurIndex)
	end
end

function Game_WorldBossRank:updateListViewItem(Panel_WorldBossRankItem, nIndex)
    if nIndex == #self.tbDamageInfo and nIndex < self.nMax then
        local nNext = math.min(nIndex+10, self.nMax)
        g_WBSystem:requestRankInfo(nIndex+1, nNext)
        self.nCurIndex = nIndex - 4
        return
    end
	
	local Button_WorldBossRankItem = tolua.cast(Panel_WorldBossRankItem:getChildByName("Button_WorldBossRankItem"), "Button")
	--local CSV_ActivityWorldBoss = g_DataMgr:getCsvConfigByOneKey("ActivityWorldBoss", self.nWorldBossCfgId)
    local tbDamage = self.tbDamageInfo[nIndex]
    local Label_Name = tolua.cast(Button_WorldBossRankItem:getChildByName("Label_Name"), "Label")
	Label_Name:setText(getFormatSuffixLevel(tbDamage.name, g_GetCardEvoluteSuffixByEvoLev(tbDamage.breachlv)))
    local tbSize = Label_Name:getContentSize()

    local Label_Level = tolua.cast(Button_WorldBossRankItem:getChildByName("Label_Level"), "Label")
    Label_Level:setText(string.format(_T("Lv.%d"), tbDamage.role_lv))
    Label_Level:setPositionX(-20+math.floor(tbSize.width/2))

    local Label_Damage = tolua.cast(Button_WorldBossRankItem:getChildByName("Label_Damage"), "Label")
    local nSortDamagePrecent = math.floor(tbDamage.damage/self.nBossMaxHp * 10000)
	local strDamagePrecent = string.format("%.2f", nSortDamagePrecent/100)
	Label_Damage:setText(_T("伤害")..tbDamage.damage.."("..strDamagePrecent.."%)")

    local LabelBMFont_Rank = tolua.cast(Button_WorldBossRankItem:getChildByName("LabelBMFont_Rank"), "LabelBMFont")
    LabelBMFont_Rank:setText(tostring(nIndex))

    local tbCard = g_DataMgr:getCardBaseCsv(tbDamage.card_cfg, tbDamage.card_star)
    local Image_Head = tolua.cast(Button_WorldBossRankItem:getChildByName("Image_Head"), "ImageView")
    Image_Head:loadTexture(getCardBackByEvoluteLev(tbDamage.breachlv))
    local Image_Frame = tolua.cast(Image_Head:getChildByName("Image_Frame"), "ImageView")
    Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbDamage.breachlv))
    local Image_Icon = tolua.cast(Image_Head:getChildByName("Image_Icon"), "ImageView")
    Image_Icon:loadTexture(getIconImg(tbCard.SpineAnimation))
    local LabelBMFont_VipLevel = tolua.cast(Image_Head:getChildByName("LabelBMFont_VipLevel"), "LabelBMFont")
    LabelBMFont_VipLevel:setText( string.format(_T("VIP%d"),tbDamage.vip_lev))
	
	local function onClick_Image_Head(pSender, nTag)
		g_MsgMgr:requestViewPlayer(tbDamage.uin)
	end
	g_SetBtnWithEvent(Image_Head, 1, onClick_Image_Head, true)

    local Label_DamageLB = tolua.cast(Button_WorldBossRankItem:getChildByName("Label_DamageLB"), "Label")
    --处理吉星
    if self.bScore then
        Label_Damage:setVisible(false)
        Label_DamageLB:setText(_T("今日吉星高照累计获得")..tbDamage.damage.._T("积分"))
    end

    if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
        Label_DamageLB:setFontSize(19)
        Label_Damage:setFontSize(19)
        g_AdjustWidgetsPosition({Label_DamageLB, Label_Damage}, 1)
    end
end

function Game_WorldBossRank:closeWnd()
    self.tbDamageInfo = nil
    self.nMax = nil
    self.nWorldBossCfgId = nil
    self.LuaListView_WorldBossRankList:updateItems(0)
end

--显示主界面的伙伴详细介绍界面
function Game_WorldBossRank:openWnd(tbData)
	if g_bReturn then return end
	if not tbData then return end

    --吉星用到
    self.bScore = tbData.bScore

    self.nBossMaxHp = tbData.nBossMaxHp or 1
    self.tbDamageInfo = tbData.tbBossRankInfo
    self.nMax = tbData.nMax
    self.nWorldBossCfgId = tbData.nWorldBossCfgId
	self.LuaListView_WorldBossRankList:updateItems(#self.tbDamageInfo)
end

function Game_WorldBossRank:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_WorldBossRankPNL = tolua.cast(self.rootWidget:getChildByName("Image_WorldBossRankPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_WorldBossRankPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_WorldBossRank:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_WorldBossRankPNL = tolua.cast(self.rootWidget:getChildByName("Image_WorldBossRankPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_WorldBossRankPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end