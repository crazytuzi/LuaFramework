--------------------------------------------------------------------------------------
-- 文件名:	ItemDropGuildFunc.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用: 掉落副本列表信息
---------------------------------------------------------------------------------------
ItemDropGuildFunc = class("ItemDropGuildFunc")
ItemDropGuildFunc.__index = ItemDropGuildFunc

ITEM_DROP_TYPE = {
	PILL = 1,
	MATERIAL = 2,
}

local function jyEctypePage(ectypeId)
	local csv_JY_Data = g_DataMgr:getCsvConfig("MapEctypeJingYing")
	for key,value in ipairs(csv_JY_Data) do 
		for key2,value2 in ipairs(value) do 
			if value2.EctypeID == ectypeId then 
				return value2,key,key2
			end
		end
	end 
end
--掉落副本列表
--掉落副本

function ItemDropGuildFunc:ectypeListShow(ectypeList, itemType)

	self:setEctypeListInfo(ectypeList)
	local function onUpdate_LuaListView_EctypeList(Panel_EctypeItem, nIndexKey)
		local Button_EctypeItem = tolua.cast(Panel_EctypeItem:getChildByName("Button_EctypeItem"),"Button")
		if not Button_EctypeItem then 
			Button_EctypeItem = tolua.cast(Panel_EctypeItem:getChildByName("Button_EctypeItemShopSecret"),"Button")
			Button_EctypeItem:setName("Button_EctypeItem")
		end
		--头像底框
		local Image_MonsterBase = tolua.cast(Button_EctypeItem:getChildByName("Image_MonsterBase"),"ImageView")
		--头像外框
		local Image_MonsterIconFrame = tolua.cast(Image_MonsterBase:getChildByName("Image_MonsterIconFrame"),"ImageView")
		--头像ICON
		local Image_Icon = tolua.cast(Image_MonsterBase:getChildByName("Image_Icon"),"ImageView")
		--关卡名称
		local Label_EctypeName = tolua.cast(Button_EctypeItem:getChildByName("Label_EctypeName"),"Label")
		--挑战次数
		local Label_FightNumsLB1 = tolua.cast(Button_EctypeItem:getChildByName("Label_FightNumsLB1"),"Label")
		--已经打过的次数
		local Label_FightNums = tolua.cast(Label_FightNumsLB1:getChildByName("Label_FightNums"),"Label")
		--能打多少次
		local Label_FightNumsLB2 = tolua.cast(Label_FightNumsLB1:getChildByName("Label_FightNumsLB2"),"Label")
		--图片文字（普通）
		local Image_MonsterIconChar = tolua.cast(Image_MonsterBase:getChildByName("Image_MonsterIconChar"), "ImageView")  
		--通关星级
		local AtlasLabel_StarLevel = tolua.cast(Image_MonsterBase:getChildByName("AtlasLabel_StarLevel"),"LabelAtlas")
		--锁 图案
		local Image_Lock = tolua.cast(Button_EctypeItem:getChildByName("Image_Lock"),"ImageView")
		--未开启
		local Label_Locked = tolua.cast(Button_EctypeItem:getChildByName("Label_Locked"),"Label")
	
		local function itemImageVisible()
			Image_MonsterIconChar:setVisible(false)
			AtlasLabel_StarLevel:setVisible(false)
			Label_FightNums:setVisible(false)
			Label_FightNumsLB2:setVisible(false)
			Label_FightNumsLB1:setVisible(true)
			Label_Locked:setVisible(false)
			Image_Lock:setVisible(false)
			Image_Icon:loadTexture(getBackgroundPngImg("ShenMiShangDian"))
			Image_Icon:setScale(0.4)
		end
	
		if itemType == ITEM_DROP_TYPE.PILL and nIndexKey == 1 then
			local function showShopPrestigeFunc(pSender, nTag)
				--丹药掉落里 第一个做为去声望商店的入口
				g_WndMgr:openWnd("Game_ShopPrestige")
			end
			g_SetBtnWithOpenCheck(Button_EctypeItem, 1, showShopPrestigeFunc, true)
			itemImageVisible()
			Label_FightNumsLB1:setText(_T("点击前往声望商店购买"))
			Label_EctypeName:setText(_T("声望商店"))
			return
		elseif itemType == ITEM_DROP_TYPE.MATERIAL and nIndexKey == 1 then
			local function showShopPrestigeFunc(pSender, nTag)
				g_WndMgr:openWnd("Game_ShopSecret")
			end
			Button_EctypeItem:setName("Button_EctypeItemShopSecret")
			g_SetBtnWithOpenCheck(Button_EctypeItem, 1, showShopPrestigeFunc, true)
			itemImageVisible()
			Label_FightNumsLB1:setText(_T("点击前往将魂商店购买"))
			Label_EctypeName:setText(_T("将魂商店"))
			return
		end
		local ectypeLst = ectypeList[nIndexKey - 1]
		local ectypeId = ectypeLst.ectypeid --副本ID
		local isOpen = ectypeLst.is_open --是不是已经开启
		local mapBattle = nil
		local nPage = 0
		local nIndex = 0
		local nFightNum = ectypeLst.att_num or 0
		
		--精英副本
		local nOpenLevel = g_CheckFuncCanOpenByWidgetName("Button_JingYingFuBen")
		
		--精英副本id
		if ectypeId >= ELITE_ECTYPE_START_ID then 
			mapBattle,nPage,nIndex = jyEctypePage(ectypeId)
			nFightNum = g_EctypeJY:getAttackNum(nPage,nIndex) 
		else
			mapBattle = g_DataMgr:getCsvConfigByOneKey("MapEctype",ectypeId)
			local tbStar = g_Hero:getEctypePassStar(ectypeId)
			if tbStar then
				nFightNum = tbStar.attack_num
			end
		end
		
		if not mapBattle then cclog("mapBattle 数据为空") return end 
		
		local function onClick(pSender,eventType)
			if eventType ==ccs.TouchEventType.ended then
				local nTag = pSender:getTag()
				local tbEctypeInfo = g_DataMgr:getMapEctypeCsv(nTag)
				self:setClickMapID(mapBattle.MapID)
				self:setClickTag(nTag)
				-- 掉落指引那里不需要判断体力，进去的界面有判断
				-- if(tbEctypeInfo.NeedEnergy > g_Hero:getEnergy() )then
					-- g_ClientMsgTips:showMsgConfirm("您的体力不足, 请稍后再试。")
					-- return
				-- end
				
				if( tbEctypeInfo.OpenLevel > g_Hero:getMasterCardLevel() )then
					g_ClientMsgTips:showMsgConfirm(string.format(_T("您需要%d级才能挑战该副本"), tbEctypeInfo.OpenLevel))
					return
				end

				local tbStar = g_Hero:getEctypePassStar(tbEctypeInfo.EctypeID)
				-- if tbStar and tbEctypeInfo.MaxFightNums <= nFightNum then
					-- g_ClientMsgTips:showMsgConfirm(string.format(_T("您挑战次数已满")))
					-- return
				-- end
				
				if isOpen == 0  then  
					g_ClientMsgTips:showMsgConfirm(string.format(_T("该副本还未开启")))
					return 
				end
				--精英副本id
				if ectypeId >= ELITE_ECTYPE_START_ID then 
					local _,nPage,nIndex = jyEctypePage(ectypeId)
					if nPage > 0 and nOpenLevel then 
						local csv_JY = g_DataMgr:getCsvConfigByTwoKey("MapEctypeJingYing", nPage,nIndex)
						g_WndMgr:showWnd("Game_EctypeJYDetail",csv_JY)
					else
						g_ClientMsgTips:showMsgConfirm(_T("该副本还未开启"))
					end
				else
					g_MsgMgr:requestEctypePassInfo(mapBattle.MapID)	
				end
		
			end
		end
		local Button_EctypeItem = tolua.cast(Panel_EctypeItem:getChildByName("Button_EctypeItem"),"Button")
		Button_EctypeItem:setTag(ectypeId)
		Button_EctypeItem:setTouchEnabled(true)
		Button_EctypeItem:addTouchEventListener(onClick)
		--头像底框
		Image_MonsterBase:loadTexture(getUIImg("FrameEctypeBack"..mapBattle.MonsterStarLevel))
		--头像外框
		Image_MonsterIconFrame:loadTexture(getUIImg("FrameEctype"..mapBattle.MonsterStarLevel))
		--头像ICON
		Image_Icon:loadTexture(getIconImg(mapBattle.BossPotrait) )
		Image_Icon:setScale(0.8)
		--关卡名称
		Label_EctypeName:setText(mapBattle.EctypeName)
		--挑战次数
		Label_FightNumsLB1:setText(_T("挑战次数:"))
		
		--已经打过的次数
		Label_FightNums:setText(nFightNum)
		--能打多少次
		Label_FightNumsLB2:setText("/"..mapBattle.MaxFightNums)

		Label_FightNums:setPositionX(Label_FightNumsLB1:getSize().width)
		Label_FightNumsLB2:setPositionX(Label_FightNumsLB1:getSize().width + Label_FightNums:getSize().width)
		
		--图片文字（普通）
		if (mapBattle.IsBoss == 1) or ectypeId >= ELITE_ECTYPE_START_ID then --为boss		
			Image_MonsterIconChar:loadTexture(getUIImg("FrameEctypeBossChar"..mapBattle.MonsterStarLevel) )
		else	
			Image_MonsterIconChar:loadTexture(getUIImg("FrameEctypeNormalChar"..mapBattle.MonsterStarLevel) )
		end
		
		--通关星级
		if (not tbStar or not g_tbStarLevel[tbStar.star]) then
			AtlasLabel_StarLevel:setVisible(false)
		else
			AtlasLabel_StarLevel:setVisible(true)
			AtlasLabel_StarLevel:setValue(g_tbStarLevel[tbStar.star] )	
		end	
		
		--未开启
		local openLockFlag = true
		local openLockedFlag = false
        if isOpen > 0  then 
            openLockFlag = false
            openLockedFlag = true
        end
        --精英
		if ectypeId >= ELITE_ECTYPE_START_ID and not nOpenLevel  then 
			openLockFlag = true
            openLockedFlag = false
		end

		Image_Lock:setVisible(openLockFlag)
		Label_Locked:setVisible(openLockFlag)
			
		Label_FightNumsLB1:setVisible(openLockedFlag)
		Label_FightNums:setVisible(openLockedFlag)
		Label_FightNumsLB2:setVisible(openLockedFlag)
	end
	return onUpdate_LuaListView_EctypeList
	
end

function ItemDropGuildFunc:ctor()
	self.clickMapID_ = 0
	self.clickTag_ = 0
	self.ectypeList_ = nil
	self.danYaoStar_ = 0
end

function ItemDropGuildFunc:getClickMapID()
	return self.clickMapID_
end

function ItemDropGuildFunc:setClickMapID(mapId)
	self.clickMapID_ = mapId
end

function ItemDropGuildFunc:getClickTag()
	return self.clickTag_
end

function ItemDropGuildFunc:setClickTag(tag)
	self.clickTag_ = tag
end

function ItemDropGuildFunc:setEctypeListInfo(data)
	self.ectypeList_ = data
end

function ItemDropGuildFunc:getEctypeListInfo()
	return self.ectypeList_
end
--[[
一品丹药碎片：20级 1
二品丹药碎片：30级 2
三品丹药碎片：45级 3
四品丹药碎片：75级 5
五品丹药碎片：120级 8
]]
--模拟声望商店第几页数字
local tbShopPrestigeCurPage = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 5,
	[5] = 8
}
function ItemDropGuildFunc:getDanYaoStarByIndex()
	if not self.danYaoStar_ or self.danYaoStar_ <= 0 then 
		return 0
	end
	return tbShopPrestigeCurPage[self.danYaoStar_]
end

function ItemDropGuildFunc:setDanYaoStar(star)
	self.danYaoStar_ = star
end


g_ItemDropGuildFunc = ItemDropGuildFunc.new()
