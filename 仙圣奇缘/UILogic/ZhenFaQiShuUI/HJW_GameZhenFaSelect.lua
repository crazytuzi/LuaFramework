--------------------------------------------------------------------------------------
-- 文件名:	Game_ZhenFaSelect.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2014-12-02 21:06
-- 版  本:	1.0
-- 描  述:	阵法选择
-- 应  用:  
---------------------------------------------------------------------------------------
Game_ZhenFaSelect = class("Game_ZhenFaSelect")
Game_ZhenFaSelect.__index = Game_ZhenFaSelect

local function sortQiShuZhenfaCsv(CSV_QiShuZhenfaA, CSV_QiShuZhenfaB)
	return CSV_QiShuZhenfaA.SortRank < CSV_QiShuZhenfaB.SortRank
end


function Game_ZhenFaSelect:getQiShuZhenfaInSort(nSortRank)
	if not g_TableQiShuZhenfaCsvInSort then
		g_TableQiShuZhenfaCsvInSort = {}
		for k, v in pairs (ConfigMgr.QiShuZhenfa) do
			table.insert(g_TableQiShuZhenfaCsvInSort, v)
		end
		table.sort(g_TableQiShuZhenfaCsvInSort, sortQiShuZhenfaCsv)
	end
	
	local nSortRank = nSortRank or 0
	
    local tbCsv = g_TableQiShuZhenfaCsvInSort[nSortRank]
    if not tbCsv then
		cclog("===Game_ZhenFaSelect:getQiShuZhenfaInSort error ==="..nSortRank)
		return ConfigMgr.QiShuZhenfa_[0]
	end
	return tbCsv
end

function Game_ZhenFaSelect:initWnd()	
	
	local Image_ZhenFaSelectPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenFaSelectPNL"), "ImageView")
	local Image_ZhenFaSelectContentPNL = tolua.cast(Image_ZhenFaSelectPNL:getChildByName("Image_ZhenFaSelectContentPNL"), "ImageView")
	local Image_ZhenFaPNL = tolua.cast(Image_ZhenFaSelectContentPNL:getChildByName("Image_ZhenFaPNL"), "ImageView")
	local x,y = 0, 190
	local Button_ZhenFaItem1 = tolua.cast(Image_ZhenFaPNL:getChildByName("Button_ZhenFaItem1"), "Button")
	for i = 2,9 do
		if not tolua.cast(Image_ZhenFaPNL:getChildByName("Button_ZhenFaItem"..i), "Button") then 
			local Button_ZhenFaItem = Button_ZhenFaItem1:clone()
			Button_ZhenFaItem:setName("Button_ZhenFaItem"..i )
			Button_ZhenFaItem:setPosition(ccp(x,y))
			Image_ZhenFaPNL:addChild(Button_ZhenFaItem)
			x = x + 347
			if i % 3 == 0 then
				x = -347
				y = y - 165
			end
		end
	end
	
	-- local Image_ZhenFaSelectPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenFaSelectPNL"), "ImageView")
	local Image_Background = tolua.cast(Image_ZhenFaSelectPNL:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getBackgroundJpgImg("Background_QiShu"))
end

--请求当前阵法（选择阵法）
function Game_ZhenFaSelect:requestArraySelect(nZhenFaCsvID)
	local rootMsg = zone_pb.ArraySelectRequest()
	rootMsg.array_id = nZhenFaCsvID 
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ARRAY_SELECT_REQUEST, rootMsg)
end


function Game_ZhenFaSelect:onZhenFaSelectRefresh(tbMsg)

	local nSelectZhenFaCsvID = tbMsg.array_id
   
    if TbBattleReport then 
        local nCurrentZhenFaCsvID = g_Hero:getCurrentZhenFaCsvID()
        local tempPlayer = {}
        local tempPlayerSkillData = {}
        for nPos = 1, 9 do
            local GameFighter_Attacker = TbBattleReport.tbGameFighters_OnWnd[nPos]
            if GameFighter_Attacker then
                tempPlayer[nPos] = GameFighter_Attacker
                TbBattleReport.tbGameFighters_OnWnd[nPos] = nil

                tempPlayerSkillData[nPos] = TbBattleReport.tbSkillData[nPos]
                TbBattleReport.tbSkillData[nPos] = nil
            end
        end

        local tbZhenFa = g_DataMgr:getCsvConfig("QiShuZhenfa")
        local tbBattleList = g_Hero:getBattleCardList()
        local tbCurPos = g_DataMgr:getCsvConfig_SecondKeyTableData("QiShuZhenfa", nCurrentZhenFaCsvID)
        local tbTarget = g_DataMgr:getCsvConfig_SecondKeyTableData("QiShuZhenfa", nSelectZhenFaCsvID)
        for i =1, 5 do
            local tbCurBattle = tbBattleList[i]
            if tbCurBattle then
                local nPosIndex = tbCurBattle.nPosIdx
                if nPosIndex > 0 and nPosIndex < 6 and tbCurBattle.nServerID > 0 then
                    local nCurPos = tbCurPos[nPosIndex].BuZhenPosIndex
                    local nTargetPos = tbTarget[nPosIndex].BuZhenPosIndex
                    local GameFighter_Attacker = tempPlayer[nCurPos]
                    if GameFighter_Attacker then
                        TbBattleReport.tbGameFighters_OnWnd[nTargetPos] = GameFighter_Attacker
                        TbBattleReport.tbGameFighters_OnWnd[nTargetPos].nPos = nTargetPos

                        TbBattleReport.tbSkillData[nTargetPos] = tempPlayerSkillData[nCurPos]
                    end
                end
            end
        end
    end

	g_Hero:setCurrentZhenFaCsvID(nSelectZhenFaCsvID)
	
	local Image_ZhenFaSelectPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenFaSelectPNL"), "ImageView")
	local Image_ZhenFaSelectContentPNL = tolua.cast(Image_ZhenFaSelectPNL:getChildByName("Image_ZhenFaSelectContentPNL"), "ImageView")
	local Image_ZhenFaPNL = tolua.cast(Image_ZhenFaSelectContentPNL:getChildByName("Image_ZhenFaPNL"), "ImageView")
	
	if self.Button_ZhenFaItem_Check then
		local Button_ZhenFaIcon = self.Button_ZhenFaItem_Check:getChildByName("Button_ZhenFaIcon")
		local Image_Activated = Button_ZhenFaIcon:getChildByName("Image_Activated")
		if Image_Activated and Image_Activated:isVisible() == true then
			Image_Activated:setVisible(false)
			local Image_CheckCover = tolua.cast(self.Button_ZhenFaItem_Check:getChildByName("Image_CheckCover"), "ImageView")
			Image_CheckCover:setVisible(false)
		end
	end
	
	local CSV_ZhenFa = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhenfa", nSelectZhenFaCsvID, 1)
	self.Button_ZhenFaItem_Check = tolua.cast(Image_ZhenFaPNL:getChildByName("Button_ZhenFaItem"..CSV_ZhenFa.SortRank), "Button")
	
	local Button_ZhenFaIcon = self.Button_ZhenFaItem_Check:getChildByName("Button_ZhenFaIcon")
	local Image_Activated = Button_ZhenFaIcon:getChildByName("Image_Activated")
	if Image_Activated then
		Image_Activated:setVisible(true)
		local Image_CheckCover = tolua.cast(self.Button_ZhenFaItem_Check:getChildByName("Image_CheckCover"), "ImageView")
		Image_CheckCover:setVisible(true)
	end

    if TbBattleReport then 
        local instance = g_WndMgr:getWnd("Game_Battle")
        if instance then instance:refreshSelectZhenFa() end
    end
    g_Hero:refreshTeamMemberAddProps()
end

local function onPressed_Button_ZhenFaIcon(pSender, eventType)
	if eventType == ccs.TouchEventType.ended then
		local wndInstance = g_WndMgr:getWnd("Game_ZhenFaSelect")
		if wndInstance then
			local nTag = pSender:getTag()
			local CSV_ZhenFaTemp = wndInstance:getQiShuZhenfaInSort(nTag)
			local param = {
				CSV_QiShu = CSV_ZhenFaTemp,
				nQiShuID = CSV_ZhenFaTemp.ZhenFaID,
				nTipType = 1
			}
			g_WndMgr:showWnd("Game_TipQiShu", param)
		end
	end
end

local function onPressed_Button_Ativate(pSender, eventType)
	if eventType == ccs.TouchEventType.ended then
		local wndInstance = g_WndMgr:getWnd("Game_ZhenFaSelect")
		if wndInstance then
			local nTag = pSender:getTag()
			local CSV_ZhenFaTemp = wndInstance:getQiShuZhenfaInSort(nTag)
			local nCurrentZhenFaCsvID = g_Hero:getCurrentZhenFaCsvID()
			if CSV_ZhenFaTemp.ZhenFaID == nCurrentZhenFaCsvID then
				return 
			end
			
			--请求选择阵法
			wndInstance:requestArraySelect(CSV_ZhenFaTemp.ZhenFaID)
		end
	end
end
		
--阵法
function Game_ZhenFaSelect:set_Image_ZhenFaPNL()
	--阵法
	local Image_ZhenFaSelectPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenFaSelectPNL"), "ImageView")
	local Image_ZhenFaSelectContentPNL = tolua.cast(Image_ZhenFaSelectPNL:getChildByName("Image_ZhenFaSelectContentPNL"), "ImageView")
	local Image_ZhenFaPNL = tolua.cast(Image_ZhenFaSelectContentPNL:getChildByName("Image_ZhenFaPNL"), "ImageView")
	Image_ZhenFaPNL:setVisible(true)

	for nSortRank = 1,9 do
		local CSV_ZhenFa = self:getQiShuZhenfaInSort(nSortRank)
		local nZhenFaLevel = g_Hero:getZhenFaLevel(CSV_ZhenFa.ZhenFaID) --阵法等级
		
		local Button_ZhenFaItem = tolua.cast(Image_ZhenFaPNL:getChildByName("Button_ZhenFaItem"..nSortRank), "Button")
		Button_ZhenFaItem:setTag(nSortRank)
		local Button_Ativate = tolua.cast(Button_ZhenFaItem:getChildByName("Button_Ativate"), "Button")
		Button_Ativate:setTag(nSortRank)
		
		--阵法名称与等级 形式为括号中的（天门阵 Lv.1）
		local Label_ZhenFaName = tolua.cast(Button_ZhenFaItem:getChildByName("Label_ZhenFaName"), "Label")
		Label_ZhenFaName:setText(string.format(_T("%s Lv.%0d"), CSV_ZhenFa.ZhenFaName, nZhenFaLevel))
		
		local Label_ZhenFaProp = tolua.cast(Button_ZhenFaItem:getChildByName("Label_ZhenFaProp"), "Label")
		Label_ZhenFaProp:setText(g_Hero:getZhenFaPropString(CSV_ZhenFa.ZhenFaID))
		
		--阵法按钮 
		local Button_ZhenFaIcon = tolua.cast(Button_ZhenFaItem:getChildByName("Button_ZhenFaIcon"),"Button")
		Button_ZhenFaIcon:setTag(nSortRank)
		Button_ZhenFaIcon:setTouchEnabled(true)
		Button_ZhenFaIcon:addTouchEventListener(onPressed_Button_ZhenFaIcon)	
		
		local Image_CheckCover = tolua.cast(Button_ZhenFaItem:getChildByName("Image_CheckCover"), "ImageView")
		local BitmapLabel_OpenLevel = tolua.cast(Button_ZhenFaIcon:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
		local Image_Activated = tolua.cast(Button_ZhenFaIcon:getChildByName("Image_Activated"), "ImageView")
		Image_Activated:setVisible(false)

		local nCurrentZhenFaCsvID = g_Hero:getCurrentZhenFaCsvID()
		if nCurrentZhenFaCsvID == CSV_ZhenFa.ZhenFaID then
			Image_CheckCover:setVisible(true)
			Image_Activated:setVisible(true)
			self.Button_ZhenFaItem_Check = Button_ZhenFaItem
		end		
		
		--开启等级提示 形式为括号中的（主角xx级解锁）
		local Label_OpenLevelTip = tolua.cast(Button_ZhenFaItem:getChildByName("Label_OpenLevelTip"), "Label")
		
		local nMasterCardLevel = tonumber(g_Hero:getMasterCardLevel())--主角等级
		local nOpenLevel = tonumber(CSV_ZhenFa.OpenLevel)--阵法开启等级
		if nOpenLevel <= nMasterCardLevel then	
			Button_Ativate:setVisible(true)
			Button_Ativate:setTouchEnabled(true)
			Button_Ativate:addTouchEventListener(onPressed_Button_Ativate)
			
			Button_ZhenFaItem:setVisible(true)
			Button_ZhenFaItem:setTouchEnabled(true)
			Button_ZhenFaItem:addTouchEventListener(onPressed_Button_Ativate)	

			Button_ZhenFaIcon:loadTextures(getIconImg("Qishu_ZhenFa"..CSV_ZhenFa.ZhenFaID), getIconImg("Qishu_ZhenFa"..CSV_ZhenFa.ZhenFaID), getIconImg("Qishu_ZhenFa"..CSV_ZhenFa.ZhenFaID))
			
			Label_OpenLevelTip:setVisible(false)
			BitmapLabel_OpenLevel:setVisible(false)
		else
			Button_Ativate:setVisible(false)
			Button_ZhenFaItem:setVisible(false)
			Button_ZhenFaIcon:loadTextures(getUIImg("Frame_Qishu_Locker"), getUIImg("Frame_Qishu_Locker"), getUIImg("Frame_Qishu_Locker"))
			
			Image_Activated:setVisible(false)
			
			Label_OpenLevelTip:setVisible(true)
			local strTxt = string.format(_T("主角%d级解锁"), nOpenLevel)
			Label_OpenLevelTip:setText(strTxt)
			
			BitmapLabel_OpenLevel:setText(nOpenLevel)
			BitmapLabel_OpenLevel:setVisible(true)
		end
	end
	
end

function Game_ZhenFaSelect:openWnd()  	
	--阵法
	self:set_Image_ZhenFaPNL()
end

function Game_ZhenFaSelect:closeWnd()  
	local Image_ZhenFaSelectPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenFaSelectPNL"), "ImageView")
	local Image_Background = tolua.cast(Image_ZhenFaSelectPNL:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getUIImg("Blank"))
end

function Game_ZhenFaSelect:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ZhenFaSelectPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenFaSelectPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ZhenFaSelectPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ZhenFaSelect:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ZhenFaSelectPNL = tolua.cast(self.rootWidget:getChildByName("Image_ZhenFaSelectPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ZhenFaSelectPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end