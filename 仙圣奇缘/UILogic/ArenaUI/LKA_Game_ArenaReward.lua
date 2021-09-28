--------------------------------------------------------------------------------------
-- 文件名:	LKA_ArenaRewardReward.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_ArenaReward = class("Game_ArenaReward")
Game_ArenaReward.__index = Game_ArenaReward

Game_ArenaReward_Type = {
	ArenaReward = 1,
	ArenaRewardKuaFu = 2,
}

function Game_ArenaReward:initWnd()
end

function Game_ArenaReward:openWnd(nArenaRewardType)
	local Image_ArenaRewardPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRewardPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ArenaRewardPNL:getChildByName("Image_ContentPNL"), "ImageView")
	if nArenaRewardType == Game_ArenaReward_Type.ArenaReward then
		local CSV_ArenaDailyReward = g_DataMgr:getCsvConfig("ArenaDailyReward")
		for key, value in pairs(CSV_ArenaDailyReward) do
			if value.RankArea > 0 then
				local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", value.DropClientID)
				
				local nYuanBaoReward = 0
				local nTongQianReward = 0
				local nShengWangReward = 0
				for k, v in pairs (CSV_DropSubPackClient) do
					if v.DropItemType == 10 then --元宝
						nYuanBaoReward = v.DropItemNum
					elseif v.DropItemType == 11 then --铜钱
						nTongQianReward = v.DropItemNum/10000
					elseif v.DropItemType == 12 then --声望
						nShengWangReward = v.DropItemNum
					end
				end
				local ImageView_Reward = tolua.cast(Image_ContentPNL:getChildByName("ImageView_Reward"..value.RankArea), "ImageView")
				local Label_RewardDesc = tolua.cast(ImageView_Reward:getChildByName("Label_RewardDesc"), "Label")
				if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
					Label_RewardDesc:setFontSize(18)
				end
				Label_RewardDesc:setText(string.format(_T("每天%d声望, %d万铜钱, %d元宝"), nShengWangReward, nTongQianReward, nYuanBaoReward))
			end
		end
	elseif nArenaRewardType == Game_ArenaReward_Type.ArenaRewardKuaFu then
		local CSV_ArenaDailyRewardKuaFu = g_DataMgr:getCsvConfig("ArenaDailyRewardKuaFu")
		for key, value in pairs(CSV_ArenaDailyRewardKuaFu) do
			if value.RankArea > 0 then
				local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", value.DropPackClientID)
				
				local nDragonToken = 0
				local nTongQianReward = 0
				local nShengWangReward = 0
				for k, v in pairs (CSV_DropSubPackClient) do
					if v.DropItemType == 21 then --元宝
						nDragonToken = v.DropItemNum
					elseif v.DropItemType == 11 then --铜钱
						nTongQianReward = v.DropItemNum/10000
					elseif v.DropItemType == 12 then --声望
						nShengWangReward = v.DropItemNum
					end
				end
				local ImageView_Reward = tolua.cast(Image_ContentPNL:getChildByName("ImageView_Reward"..value.RankArea), "ImageView")
				local Label_RewardDesc = tolua.cast(ImageView_Reward:getChildByName("Label_RewardDesc"), "Label")
				if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
					Label_RewardDesc:setFontSize(18)
				end
				Label_RewardDesc:setText(string.format(_T("每天%d声望, %d万铜钱, %d神龙令"), nShengWangReward, nTongQianReward, nDragonToken))
			end
		end
	end
end

function Game_ArenaReward:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ArenaRewardPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRewardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ArenaRewardPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ArenaReward:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ArenaRewardPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRewardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ArenaRewardPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end