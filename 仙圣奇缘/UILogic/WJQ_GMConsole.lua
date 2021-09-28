--------------------------------------------------------------------------------------
-- 文件名:	Game_GMConsole.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2014-04-08 4:37
-- 版  本:	1.0
-- 描  述:	Game_GMConsole
-- 应  用:  
---------------------------------------------------------------------------------------

Game_GMConsole = class("Game_GMConsole")
Game_GMConsole.__index = Game_GMConsole

g_GMConsole_CheckListOpen = nil

local function _Temp(str)
	return str
end

function Game_GMConsole:initWnd()
end

function Game_GMConsole:closeWnd()
end

function Game_GMConsole:openWnd()
	local ImageView_GMConsolePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_GMConsolePNL"), "ImageView")
	local ImageView_ContentPNL = tolua.cast(ImageView_GMConsolePNL:getChildByName("ImageView_ContentPNL"), "ImageView")
	ImageView_ContentPNL:setTouchEnabled(true)
	local ListView_FunctionList = tolua.cast(ImageView_ContentPNL:getChildByName("ListView_FunctionList"), "ListView")
	local Button_Return = tolua.cast(self.rootWidget:getChildByName("Button_Return"), "Button")
	
	--增加伙伴
	local function AddCard()
		g_GMConsole_CheckListOpen = true
		g_ClientMsgTips:showMsgConfirm(_Temp("该调试功能已关闭，请添加魂魄后召唤卡牌"))
		
		local function AddCardByType()
			local nType = g_CheckListIndex
			g_MsgMgr:ignoreCheckWaitTime(true)
			if nType == 1 then
				-- local CSV_CardBase = g_DataMgr:getCsvConfig("CardBase")
				-- for key1, value1 in pairs(CSV_CardBase) do 
					-- for key2, value2 in pairs(value1) do
						-- local CSV_CardHunPo = g_DataMgr:getCsvConfigByOneKey("CardHunPo", key1)
						-- if value2.Class == nType and value2.StarLevel == CSV_CardHunPo.CardStarLevel then
							-- g_Hero:RequestGM(".additem card "..key1.." 1 "..CSV_CardHunPo.CardStarLevel.." 1")
						-- end
					-- end
				-- end
			elseif nType == 2 then
				-- for key1,value1 in pairs(CSV_CardBase) do 
					-- for key2, value2 in pairs(value1) do
						-- local CSV_CardHunPo = g_DataMgr:getCsvConfigByOneKey("CardHunPo", key1)
						-- if value2.Class == nType and value2.StarLevel == CSV_CardHunPo.CardStarLevel then
							-- g_Hero:RequestGM(".additem card "..key1.." 1 "..CSV_CardHunPo.CardStarLevel.." 1")
						-- end
					-- end
				-- end
			end
			g_MsgMgr:ignoreCheckWaitTime(nil)
		end
		local tbAddCardOption = 
		{
			[1] = _Temp("主角伙伴"),
			[2] = _Temp("Boss伙伴"),
		}
		local function onCloseWnd()
			g_GMConsole_CheckListOpen = false
		end
		g_ShowCheckListWnd(tbAddCardOption,1,_Temp("选择伙伴类型"),AddCardByType,onCloseWnd)
	end
	
	local Image_FunctionRowPNL1 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL1"), "ImageView")
	local Button_AddCard = tolua.cast(Image_FunctionRowPNL1:getChildByName("Button_AddCard"), "Button")
	local Label_FuncName = tolua.cast(Button_AddCard:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("增加伙伴"))
	g_SetBtnWithEvent(Button_AddCard, 1, AddCard, true, true)
	
	--增加装备
	local function AddEquip()
		g_GMConsole_CheckListOpen = true
		g_MsgMgr:ignoreCheckWaitTime(true)
		local function AddEquipByType()
			local nType = g_CheckListIndex
			g_MsgMgr:ignoreCheckWaitTime(true)
			if nType == 1 then
				local CSV_Equip = g_DataMgr:getCsvConfig("Equip")
				for key1,value1 in pairs(CSV_Equip) do 
					for key2, value2 in pairs(value1) do
						if value2.StarLevel == nType then
							g_Hero:RequestGM(".additem equip "..key1.." 1 "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 2 then
				local CSV_Equip = g_DataMgr:getCsvConfig("Equip")
				for key1,value1 in pairs(CSV_Equip) do 
					for key2, value2 in pairs(value1) do
						if value2.StarLevel == nType then
							g_Hero:RequestGM(".additem equip "..key1.." 1 "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 3 then
				local CSV_Equip = g_DataMgr:getCsvConfig("Equip")
				for key1,value1 in pairs(CSV_Equip) do 
					for key2, value2 in pairs(value1) do
						if value2.StarLevel == nType then
							g_Hero:RequestGM(".additem equip "..key1.." 1 "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 4 then
				local CSV_Equip = g_DataMgr:getCsvConfig("Equip")
				for key1,value1 in pairs(CSV_Equip) do 
					for key2, value2 in pairs(value1) do
						if value2.StarLevel == nType then
							g_Hero:RequestGM(".additem equip "..key1.." 1 "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 5 then
				local CSV_Equip = g_DataMgr:getCsvConfig("Equip")
				for key1,value1 in pairs(CSV_Equip) do 
					for key2, value2 in pairs(value1) do
						if value2.StarLevel == nType then
							g_Hero:RequestGM(".additem equip "..key1.." 1 "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 6 then
				local CSV_Equip = g_DataMgr:getCsvConfig("Equip")
				for key1,value1 in pairs(CSV_Equip) do 
					for key2, value2 in pairs(value1) do
						if value2.StarLevel == nType then
							g_Hero:RequestGM(".additem equip "..key1.." 1 "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 7 then
				local CSV_Equip = g_DataMgr:getCsvConfig("Equip")
				for key1,value1 in pairs(CSV_Equip) do 
					for key2, value2 in pairs(value1) do
						if value2.StarLevel == nType then
							g_Hero:RequestGM(".additem equip "..key1.." 1 "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 8 then
				local CSV_Equip = g_DataMgr:getCsvConfig("Equip")
				for key1,value1 in pairs(CSV_Equip) do 
					for key2, value2 in pairs(value1) do
						if value2.StarLevel == nType then
							g_Hero:RequestGM(".additem equip "..key1.." 1 "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 9 then
				local CSV_Equip = g_DataMgr:getCsvConfig("Equip")
				for key1,value1 in pairs(CSV_Equip) do 
					for key2, value2 in pairs(value1) do
						if value2.StarLevel == nType then
							g_Hero:RequestGM(".additem equip "..key1.." 1 "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 10 then
				local CSV_Equip = g_DataMgr:getCsvConfig("Equip")
				for key1,value1 in pairs(CSV_Equip) do 
					for key2, value2 in pairs(value1) do
						if value2.StarLevel == nType then
							g_Hero:RequestGM(".additem equip "..key1.." 1 "..value2.StarLevel.." 1")
						end
					end
				end
			end
			g_GMConsole_CheckListOpen = false
		end
		
		g_MsgMgr:ignoreCheckWaitTime(nil)
		local tbAddEquipOption = 
		{
			[1] = _Temp("一档逍遥套装"),
			[2] = _Temp("二档降魔套装"),
			[3] = _Temp("三档朱雀套装"),
			[4] = _Temp("四档白虎套装"),
			[5] = _Temp("五档玄武套装"),
			[6] = _Temp("六档青龙套装"),
			[7] = _Temp("七档玄奇套装"),
			[8] = _Temp("八档赤霄套装"),
			[9] = _Temp("九档通天套装"),
			[10] = _Temp("十档腾龙套装"),
		}
		local function onCloseWnd()
			g_GMConsole_CheckListOpen = false
		end
		g_ShowCheckListWnd(tbAddEquipOption,1,_Temp("选择伙伴类型"),AddEquipByType,onCloseWnd)
	end
	
	local Image_FunctionRowPNL1 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL1"), "ImageView")
	local Button_AddEquip = tolua.cast(Image_FunctionRowPNL1:getChildByName("Button_AddEquip"), "Button")
	local Label_FuncName = tolua.cast(Button_AddEquip:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("增加装备"))
	g_SetBtnWithEvent(Button_AddEquip, 1, AddEquip, true, true)

	--增加异兽
	local function AddFate()
		g_GMConsole_CheckListOpen = true
		local function AddFateByType()
			local nType = g_CheckListIndex
            --by wb
            local tmpTypeAry = 
            {
                [1] = {colortype = 2, level = 1},
                [2] = {colortype = 3, level = 1},
                [3] = {colortype = 4, level = 1},
                [4] = {colortype = 5, level = 1},
                [5] = {colortype = 2, level = 10},
                [6] = {colortype = 3, level = 10},
                [7] = {colortype = 4, level = 10},
                [8] = {colortype = 5, level = 10},
                [9] = {colortype = 6, level = 10}
            }

			g_MsgMgr:ignoreCheckWaitTime(true)
            local CSV_CardFate = g_DataMgr:getCsvConfig("CardFate")
			for key1,value1 in pairs(CSV_CardFate) do 
                local value2ary = g_DataMgr:getCsvConfig_SecondKeyTableData("CardFate",key1)
				for key2, value2 in pairs(value2ary) do
					if value1.ColorType == tmpTypeAry[nType].colortype and value2.Level == tmpTypeAry[nType].level then
						g_Hero:RequestGM(".additem fate "..key1.." 1 "..value2.Level.." 1")
					end
				end
			end

			g_MsgMgr:ignoreCheckWaitTime(nil)
			g_GMConsole_CheckListOpen = false
		end
		local tbAddFateOption = 
		{
			[1] = _Temp("绿色异兽1级"),
			[2] = _Temp("蓝色异兽1级"),
			[3] = _Temp("紫色异兽1级"),
			[4] = _Temp("金色异兽1级"),
			[5] = _Temp("绿色异兽10级"),
			[6] = _Temp("蓝色异兽10级"),
			[7] = _Temp("紫色异兽10级"),
			[8] = _Temp("金色异兽10级"),
			[9] = _Temp("逆天异兽")
		}
		local function onCloseWnd()
			g_GMConsole_CheckListOpen = false
		end
		g_ShowCheckListWnd(tbAddFateOption,1,_Temp("选择伙伴类型"),AddFateByType,onCloseWnd)
	end
	
	local Image_FunctionRowPNL1 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL1"), "ImageView")
	local Button_AddFate = tolua.cast(Image_FunctionRowPNL1:getChildByName("Button_AddFate"), "Button")
	local Label_FuncName = tolua.cast(Button_AddFate:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("增加命格"))
	g_SetBtnWithEvent(Button_AddFate, 1, AddFate, true, true)
	
	--增加魂魄
	local function AddHunPo()
		g_GMConsole_CheckListOpen = true
		g_MsgMgr:ignoreCheckWaitTime(true)
		local CSV_CardHunPo = g_DataMgr:getCsvConfig("CardHunPo")
		
		for key, value in pairs(CSV_CardHunPo) do 
			-- g_Hero:RequestGM(".additem god "..key.." "..value.MaxNum.." "..value.CardStarLevel.." 1")
			g_Hero:RequestGM(".additem god "..key.." 60 "..value.CardStarLevel.." 1")

		end
		g_MsgMgr:ignoreCheckWaitTime(nil)
	end
	
	local Image_FunctionRowPNL2 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL2"), "ImageView")
	local Button_AddHunPo = tolua.cast(Image_FunctionRowPNL2:getChildByName("Button_AddHunPo"), "Button")
	local Label_FuncName = tolua.cast(Button_AddHunPo:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("增加魂魄"))
	g_SetBtnWithEvent(Button_AddHunPo, 1, AddHunPo, true, true)
	
	--增加道具
	local function AddItem()
		g_GMConsole_CheckListOpen = true
		local function AddCardByType()
			local nType = g_CheckListIndex
			g_MsgMgr:ignoreCheckWaitTime(true)
			if nType == 1 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 0 and value2.SubType == 1 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 2 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 0 and value2.SubType == 2 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 3 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 2 and (value2.SubType == 5 or value2.SubType == 6) then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 4 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 0 and value2.SubType == 4 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 5 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 2 and value2.SubType == 5 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 6 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 2 and value2.SubType == 6 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 7 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 2 and value2.SubType == 7 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 8 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 2 and value2.SubType == 8 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 9 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 4 and value2.SubType == 9 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 10 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 2 and value2.SubType == 7 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 11 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 2 and value2.SubType == 11 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 12 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 3 and value2.SubType == 1 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 13 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 6 and value2.SubType == 3 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 14 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 2 and value2.SubType == 13 and value2.DropPackType == 2 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 15 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 2 and value2.SubType == 12 and value2.DropPackType == 1 then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			elseif nType == 16 then
				local CSV_ItemBase = g_DataMgr:getCsvConfig("ItemBase")
				for key1, value1 in pairs(CSV_ItemBase) do 
					for key2, value2 in pairs(value1) do
						if value2.Type == 2 and (value2.SubType == 14 or value2.SubType == 15 or value2.SubType == 16 or value2.SubType == 17) then
							g_Hero:RequestGM(".additem material "..key1.." "..value2.MaxNum.." "..value2.StarLevel.." 1")
						end
					end
				end
			end
			g_MsgMgr:ignoreCheckWaitTime(nil)
			g_GMConsole_CheckListOpen = false
		end
		local tbAddFateOption = 
		{
			[1] = _Temp("增加装备合成材料"),
			[2] = _Temp("增加丹药碎片"),
			[3] = _Temp("增加万能魂石和喇叭"),
			[4] = _Temp("增加重铸晶石"),
			[5] = _Temp("增加万能魂石"),
			[6] = _Temp("增加嘹亮的号角"),
			[7] = _Temp("增加装备合成材料包"),
			[8] = _Temp("增加装备卷轴包"),
			[9] = _Temp("增加装备整包"),
			[10] = _Temp("增加装备合成材料碎片"),
			[11] = _Temp("增加元神材料包"),
			[12] = _Temp("增加装备卷轴"),
			[13] = _Temp("伙伴经验道具"),
			[14] = _Temp("增加可选掉落礼包"),
			[15] = _Temp("增加随机掉落礼包"),
			[16] = _Temp("增加活动、功能货币"),
			
		}
		local function onCloseWnd()
			g_GMConsole_CheckListOpen = false
		end
		g_ShowCheckListWnd(tbAddFateOption, 1, _Temp("选择伙伴类型"), AddCardByType, onCloseWnd)
	end
	
	local Image_FunctionRowPNL2 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL2"), "ImageView")
	local Button_AddItem = tolua.cast(Image_FunctionRowPNL2:getChildByName("Button_AddItem"), "Button")
	local Label_FuncName = tolua.cast(Button_AddItem:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("增加道具"))
	g_SetBtnWithEvent(Button_AddItem, 1, AddItem, true, true)
	
	--增加元神
	local function AddCardSoul()
		g_GMConsole_CheckListOpen = true
		local function AddCardSoulByType()
			local nType = g_CheckListIndex
			g_MsgMgr:ignoreCheckWaitTime(true)
			if nType == 1 then
				local CSV_CardSoul = g_DataMgr:getCsvConfig("CardSoul")
				local nCount = 0
				for key1, value1 in pairs(CSV_CardSoul) do
					for key2, value2 in pairs(value1) do
						if value1.Class == 1 then
							local nStarLevel = math.random(1, 5)
							g_Hero:RequestGM(".additem soul "..key1.." ".."9999".." "..nStarLevel.." 1")
							nCount = nCount + 1
							if nCount >= 100 then
								break
							end
						end
					end
				end
			elseif nType == 2 then
				local CSV_CardSoul = g_DataMgr:getCsvConfig("CardSoul")
				local nCount = 0
				for key1, value1 in pairs(CSV_CardSoul) do 
					for key2, value2 in pairs(value1) do
						if value1.Class == 2 then
							local nStarLevel = math.random(1, 5)
							g_Hero:RequestGM(".additem soul "..key1.." ".."9999".." "..nStarLevel.." 1")
							nCount = nCount + 1
							if nCount >= 100 then
								break
							end
						end
					end
				end
			elseif nType == 3 then
				local CSV_CardSoul = g_DataMgr:getCsvConfig("CardSoul")
				local nCount = 0
				for key1, value1 in pairs(CSV_CardSoul) do 
					for key2, value2 in pairs(value1) do
						if value1.Class == 3 then
							local nStarLevel = math.random(1, 5)
							g_Hero:RequestGM(".additem soul "..key1.." ".."9999".." "..nStarLevel.." 1")
							nCount = nCount + 1
							if nCount >= 100 then
								break
							end
						end
					end
				end
			elseif nType == 4 then
				local CSV_CardSoul = g_DataMgr:getCsvConfig("CardSoul")
				local nCount = 0
				for key1, value1 in pairs(CSV_CardSoul) do 
					for key2, value2 in pairs(value1) do
						if value1.Class == 4 then
							local nStarLevel = math.random(1, 5)
							g_Hero:RequestGM(".additem soul "..key1.." ".."9999".." "..nStarLevel.." 1")
							nCount = nCount + 1
							if nCount >= 100 then
								break
							end
						end
					end
				end
			elseif nType == 5 then
				local CSV_CardSoul = g_DataMgr:getCsvConfig("CardSoul")
				local nCount = 0
				for key1, value1 in pairs(CSV_CardSoul) do 
					for key2, value2 in pairs(value1) do
						if value1.Class == 5 then
							local nStarLevel = math.random(1, 5)
							cclog("===========元神ID==========="..key1)
							cclog("===========元神星级==========="..nStarLevel)
							g_Hero:RequestGM(".additem soul "..key1.." ".."9999".." "..nStarLevel.." 1")
							nCount = nCount + 1
							if nCount >= 100 then
								break
							end
						end
					end
				end
			end
			g_MsgMgr:ignoreCheckWaitTime(nil)
			g_GMConsole_CheckListOpen = false
		end
		local tbAddCardSoulOption = 
		{
			[1] = _Temp("第一档次卡牌元神"),
			[2] = _Temp("第二档次卡牌元神"),
			[3] = _Temp("第三档次卡牌元神"),
			[4] = _Temp("第四档次卡牌元神"),
			[5] = _Temp("第五档次卡牌元神")
		}
		local function onCloseWnd()
			g_GMConsole_CheckListOpen = false
		end
		g_ShowCheckListWnd(tbAddCardSoulOption, 1, _Temp("选择元神类型"), AddCardSoulByType,onCloseWnd)
	end
	
	local Image_FunctionRowPNL2 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL2"), "ImageView")
	local Button_AddCardSoul = tolua.cast(Image_FunctionRowPNL2:getChildByName("Button_AddCardSoul"), "Button")
	local Label_FuncName = tolua.cast(Button_AddCardSoul:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("增加卡魂"))
	g_SetBtnWithEvent(Button_AddCardSoul, 1, AddCardSoul, true, true)
	
	--增加资源
	local function AddResource()
		g_GMConsole_CheckListOpen = true
		local function AddResourceByType()
			local nType = g_CheckListIndex
			g_MsgMgr:ignoreCheckWaitTime(true)
			--主角经验
			if nType == 1 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem exp 0 "..nValue.." 1 1")
				end
				local nAddExp = g_Hero:getMasterCardMaxExp() - g_Hero:getMasterCardExp() + 1
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的主角经验数值"), 99999999, onClickConfirm, onClickCancel, 99999999)
			--主角体力
			elseif nType == 2 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem energy 0 "..nValue.." 1 1")
				end
				local nAddEnergy = g_Hero:getMaxEnergy() - g_Hero:getEnergy()
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的体力数值"), 9999, onClickConfirm, onClickCancel, nAddEnergy)
			--主角元宝
			elseif nType == 3 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem coupons 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的元宝数值"), 999999, onClickConfirm, onClickCancel, 999999)
			--主角铜钱
			elseif nType == 4 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem golds 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的铜钱数值"), 999999999, onClickConfirm, onClickCancel, 999999999)
			--主角声望
			elseif nType == 5 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem prestige 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的声望数值"), 999999, onClickConfirm, onClickCancel, 999999)
			--主角阅历
			elseif nType == 6 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem knowledge 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的阅历数值"),999999999, onClickConfirm, onClickCancel, 999999999)
			elseif nType == 7 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem incense 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的香贡数值"), 999999, onClickConfirm, onClickCancel, 999999)
			elseif nType == 8 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem essence 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的灵力数值"), 9999, onClickConfirm, onClickCancel, 9999)
			elseif nType == 9 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem atimes 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的竞技场挑战次数"), 9999, onClickConfirm, onClickCancel, 9999)
			elseif nType == 10 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem heart 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的友情之心数值"), 9999, onClickConfirm, onClickCancel, 9999)
			elseif nType == 11 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem token 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的仙令数值"), 99999, onClickConfirm, onClickCancel, 99999)
			elseif nType == 12 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem card_exp_in_battle 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的伙伴经验数值"), 99999999, onClickConfirm, onClickCancel, 99999999)
			elseif nType == 13 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".sys set_vip_level "..nValue)
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的VIP等级"), 12, onClickConfirm, onClickCancel, 12)
			elseif nType == 14 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".additem dragon_ball 0 "..nValue.." 1 1")
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的神龙令(龙珠)数值"), 99999, onClickConfirm, onClickCancel, 99999)
			elseif nType == 15 then
				local function onClickConfirm(nValue)
					g_Hero:RequestGM(".sys add_ji_jing "..nValue)
				end
				g_ClientMsgTips:showConfirmInputNumber(_Temp("输入增加的基金数量"), 5000, onClickConfirm, onClickCancel, 10)
			end
			g_MsgMgr:ignoreCheckWaitTime(nil)
			g_GMConsole_CheckListOpen = false
		end
		local tbAddResourceOption = 
		{
			[1] = _Temp("主角经验"),
			[2] = _Temp("主角体力"),
			[3] = _Temp("主角元宝"),
			[4] = _Temp("主角铜钱"),
			[5] = _Temp("主角声望"),
			[6] = _Temp("主角阅历"),
			[7] = _Temp("主角香贡"),
			[8] = _Temp("主角灵力"),
			[9] = _Temp("竞技场挑战次数"),
			[10] = _Temp("友情点"),
			[11] = _Temp("仙令"),
			[12] = _Temp("卡牌经验"),
			[13] = _Temp("VIP等级"),
			[14] = _Temp("神龙令"),
			[15] = _Temp("加基金"),
		}
		local function onCloseWnd()
			g_GMConsole_CheckListOpen = false
		end
		g_ShowCheckListWnd(tbAddResourceOption,1,_Temp("选择增加的数值"),AddResourceByType,onCloseWnd)
	end
	
	local Image_FunctionRowPNL3 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL3"), "ImageView")
	local Button_AddResource = tolua.cast(Image_FunctionRowPNL3:getChildByName("Button_AddResource"), "Button")
	local Label_FuncName = tolua.cast(Button_AddResource:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("增加资源"))
	g_SetBtnWithEvent(Button_AddResource, 1, AddResource, true, true)
	
	--增加等级
	local function executeOtherFunc()
		local nAddExp = g_Hero:getMasterCardMaxExp() - g_Hero:getMasterCardExp() + 1
		cclog("=================g_Hero:getMasterCardMaxExp()=================="..g_Hero:getMasterCardMaxExp())
		cclog("=================g_Hero:getMasterCardMaxExp()=================="..g_Hero:getMasterCardExp())
		cclog("==================================="..nAddExp)
		g_Hero:RequestGM(".additem exp 0 "..nAddExp.." 1 1")
	end
	g_SetBtn(ImageView_ContentPNL,"Button_OtherFunc",executeOtherFunc, true)
	
	local Image_FunctionRowPNL3 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL3"), "ImageView")
	local Button_OtherFunc = tolua.cast(Image_FunctionRowPNL3:getChildByName("Button_OtherFunc"), "Button")
	local Label_FuncName = tolua.cast(Button_OtherFunc:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("升一级"))
	g_SetBtnWithEvent(Button_OtherFunc, 1, executeOtherFunc, true, true)
	
		--地图相关
	local function OpenAllMap()
		g_GMConsole_CheckListOpen = true
		local function executeSeletedFunc()
			local nType = g_CheckListIndex
			if nType == 1 then
				g_Hero:RequestGM(".openallmap 0")
				--g_backToReLogin()
			else
				g_Hero:RequestGM(".openallmap open_new_map "..nType*10)
			end
			g_WndMgr:reset(true)
			-- g_FormMsgSystem:SendFormMsg(FormMsg_ClientNet_LogOut, nil)
			g_GamePlatformSystem:OnClickGameLoginOut()
			g_GMConsole_CheckListOpen = false
		end
		local tbFunctionOption = 
		{
			[1] = _Temp("地图全开"),
			[2] = "10",
			[3] = "20",
		}
		local function onCloseWnd()
			g_GMConsole_CheckListOpen = false
		end
		g_ShowCheckListWnd(tbFunctionOption,1,_Temp("请选择功能"),executeSeletedFunc,onCloseWnd)
	end
	g_SetBtn(ImageView_ContentPNL,"Button_OpenMap",OpenAllMap, true)
	
	local Image_FunctionRowPNL3 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL3"), "ImageView")
	local Button_OpenMap = tolua.cast(Image_FunctionRowPNL3:getChildByName("Button_OpenMap"), "Button")
	local Label_FuncName = tolua.cast(Button_OpenMap:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("地图全开"))
	g_SetBtnWithEvent(Button_OpenMap, 1, OpenAllMap, true, true)
	
	--增加返回登陆
	local function Logout()
		-- g_WndMgr:reset()
		-- g_backToReLogin()
		-- g_FormMsgSystem:SendFormMsg(FormMsg_ClientNet_LogOut, nil)
		g_GamePlatformSystem:OnClickGameLoginOut()
	end
	
	local Image_FunctionRowPNL4 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL4"), "ImageView")
	local Button_Logout = tolua.cast(Image_FunctionRowPNL4:getChildByName("Button_Logout"), "Button")
	local Label_FuncName = tolua.cast(Button_Logout:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("注销登陆"))
	g_SetBtnWithEvent(Button_Logout, 1, Logout, true, true)
	
	--重新加载脚本
	local function ReloadLuaFile()
		if(not package.loaded["LuaScripts/Refresh.lua"] )then
			require("LuaScripts/Refresh.lua")
		end
		g_WndMgr:reset(true)
		LoadGamWndFile()
		g_WndMgr:openWnd("Game_Home")
		CCDirector:sharedDirector():replaceScene(mainWnd)
	end
	
	local Image_FunctionRowPNL4 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL4"), "ImageView")
	local Button_Refresh = tolua.cast(Image_FunctionRowPNL4:getChildByName("Button_Refresh"), "Button")
	local Label_FuncName = tolua.cast(Button_Refresh:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("刷新脚本"))
	g_SetBtnWithEvent(Button_Refresh, 1, ReloadLuaFile, true, true)
	
	--时间相关
	local function SetTime()
		g_GMConsole_CheckListOpen = true
		local function SetTimeByType()
			local nType = g_CheckListIndex
			g_MsgMgr:ignoreCheckWaitTime(true)
			--时间后移一天
			if nType == 1 then
				g_Hero:RequestGM(".sys next_day")
			--更改服务器时间
			elseif nType == 2 then
				local function onClickConfirm(strConfirmInputText)
					g_Hero:RequestGM("."..strConfirmInputText)
				end
				g_ClientMsgTips:showConfirmInput(_Temp("更改服务器时间(往后改)"), "date -s 2016-01-01 00:00:00", 60, onClickConfirm, nil, "date -s 2016-01-01 00:00:00")
			--打印服务器时间
			elseif nType == 3 then
				g_Hero:RequestGM(".date -t 2015-01-01 00:00:00")
			elseif nType == 4 then
				g_Hero:RequestGM(".sys net_log true")
			elseif nType == 5 then
				g_Hero:RequestGM(".sys net_log false")
			elseif nType == 6 then
				g_Hero:RequestGM(".sys quick_shop_cd true")
			elseif nType == 7 then
				g_Hero:RequestGM(".sys quick_shop_cd false")
			elseif nType == 8 then
				g_Hero:RequestGM(".sys battle_formula true")
			elseif nType == 9 then
				g_Hero:RequestGM(".sys battle_formula false")
			elseif nType == 10 then
				local function onClickConfirm(strValue)
					local nBegin, nEnd = string.find(strValue, "-")
					local nStrLen = string.len(strValue)
					local nDialogueID = tonumber(string.sub(strValue,1, nBegin-1))
					local nDialogueEvent = tonumber(string.sub(strValue, nEnd+1, nStrLen))
					g_DialogueData:showDialogueSequence(nDialogueID, nDialogueEvent)
				end
				g_ClientMsgTips:showConfirmInput(_Temp("输入对话的ID和DialogueEvent"), "1001-1", 20, onClickConfirm, nil)
			elseif nType == 11 then
				g_Hero:RequestGM(".sys next_30_day")
			elseif nType == 12 then
				g_Hero:RequestGM(".sys recharge 1")
			elseif nType == 13 then
				g_Hero:RequestGM(".sys recharge 3")
			elseif nType == 14 then
				g_Hero:RequestGM(".additem material ".."12".." ".."100".." ".."1".." 1")
			elseif nType == 15 then
				collectgarbage("collect")
			elseif nType == 16 then
				g_Hero:RequestGM(".sys swap_arena_rank 10")
			elseif nType == 17 then
				local nAddExp = g_Hero:getMasterCardMaxExp() - g_Hero:getMasterCardExp() + 1
				g_ClientMsgTips:showMsgConfirm(_Temp("经验上限====")..g_Hero:getMasterCardMaxExp().._Temp("当前经验====")..g_Hero:getMasterCardExp())
			elseif nType == 18 then
				g_Hero:RequestGM(".sys elapse_minute 60")
			elseif nType == 19 then 
				local name = ""--"战天灬雪碧" --封号玩家名称
				local hours = 1 --24*7--持续时间 最低一小时l 
				
				local function onClickConfirm(strConfirmInputText)
					
					name = strConfirmInputText
					
					local function onClick(txt)
						hours = txt or 1
						local msg = zone_pb.AddForbidLoginRole()
						msg.name = name
						msg.hours = 24 * hours
						g_MsgMgr:sendMsg(msgid_pb.MSGID_ADD_FORBID_LOGIN_ROLE, msg)
					end
					g_ClientMsgTips:showConfirmInput(_Temp("输入封印时间<最少一天 输入 1 就为一天>"), 1, nil, onClick, nil)
					
				end
				g_ClientMsgTips:showConfirmInput(_Temp("输入要封印的玩家名称"), "", nil, onClickConfirm, nil)
		
				
			elseif nType == 20 then 
			
				local function onClickConfirm(strConfirmInputText)
					local name = strConfirmInputText --取消封号玩家名称

					local msg = zone_pb.DelForbidLoginRole()
					msg.name = name
					g_MsgMgr:sendMsg(msgid_pb.MSGID_DEL_FORBID_LOGIN_ROLE, msg)
				end
				g_ClientMsgTips:showConfirmInput(_Temp("输入要解封的玩家名称"), "", nil, onClickConfirm, nil)
			elseif nType == 21 then
				g_Hero:RequestGM(".sys recharge 8")
			elseif nType == 22 then
				g_Hero:RequestGM(".sys recharge 9")
			elseif nType == 23 then
				g_Hero:RequestGM(".sys recharge 10")
			elseif nType == 24 then
				g_Hero:RequestGM(".sys recharge 11")
			elseif nType == 25 then
				g_Hero:RequestGM(".sys elapse_minute 30")
			elseif nType == 26 then
				g_Hero:RequestGM(".sys force_set_new_zone")
			elseif nType == 27 then
				g_Hero:RequestGM(".sys new_player_modify")
            elseif nType >= 28 and nType <= 33 then
                local charge = 101 + nType - 28
				g_Hero:RequestGM(".sys recharge "..charge)
            elseif nType >= 34 and nType <= 45 then
                local charge = 201 + nType - 34
				g_Hero:RequestGM(".sys recharge "..charge)
			elseif nType == 46 then
				local function onClickConfirm(strConfirmInputText)
					g_Hero:RequestGM("."..strConfirmInputText)
				end
				g_ClientMsgTips:showConfirmInput(_Temp("输入GM指令"), "", nil, onClickConfirm, nil)
            elseif nType >= 47 and nType <= 69 then
                local charge = 301 + nType - 47
				g_Hero:RequestGM(".sys recharge "..charge) 
			end
			g_MsgMgr:ignoreCheckWaitTime(nil)
			g_GMConsole_CheckListOpen = false
		end
		local tbSetTimeOption = 
		{
			[1] = _Temp("时间后移一天(重置活动)"),
			[2] = _Temp("更改服务器时间(往后改)"),
			[3] = _Temp("打印服务器时间"),
			[4] = _Temp("开服务器收发日志"),
			[5] = _Temp("关服务器收发日志"),
			[6] = _Temp("商店cd变5秒"),
			[7] = _Temp("商店cd还原"),
			[8] = _Temp("开属性公式日志"),
			[9] = _Temp("关属性公式日志"),
			[10] = _Temp("测试对话"),
			[11] = _Temp("服务器流逝30天"),
			[12] = _Temp("充值1"),
			[13] = _Temp("充值3"),
			[14] = _Temp("打印Lua占用的内存"),
			[15] = _Temp("清理Lua内存"),
			[16] = _Temp("竞技场打到10名"),
			[17] = _Temp("打印经验"),
			[18] = _Temp("时间后移一小时"),
			[19] = _Temp("封号"),
			[20] = _Temp("解封 号"),
			[21] = _Temp("充值8"),
			[22] = _Temp("充值普通月卡"),
			[23] = _Temp("充值高级月卡"),
			[24] = _Temp("充值基金"),
			[25] = _Temp("时间后移30分"),
			[26] = _Temp("设置新服"),
			[27] = _Temp("新号调试修改"),
            [28] = _Temp("越南美元1档"),
            [29] = _Temp("越南美元2档"),
            [30] = _Temp("越南美元3档"),
            [31] = _Temp("越南美元4档"),
            [32] = _Temp("越南美元5档"),
            [33] = _Temp("越南美元6档"),
            [34] = _Temp("越南电话卡1档"),
            [35] = _Temp("越南电话卡2档"),
            [36] = _Temp("越南电话卡3档"),
            [37] = _Temp("越南电话卡4档"),
            [38] = _Temp("越南电话卡5档"),
            [39] = _Temp("越南电话卡6档"),
            [40] = _Temp("越南电话卡7档"),
            [41] = _Temp("越南电话卡8档"),
            [42] = _Temp("越南电话卡初级月卡"),
            [43] = _Temp("越南电话卡高级月卡"),
            [44] = _Temp("越南电话卡基金"),
			[45] = _Temp("越南电话卡9档"),
			[46] = _Temp("输入GM指令"),
            [47] = _Temp("台湾充值60元宝"),
            [48] = _Temp("台湾充值600元宝"),
            [49] = _Temp("台湾充值1980元宝"),
            [50] = _Temp("台湾充值2980元宝"),
            [51] = _Temp("台湾充值5980元宝"),
            [52] = _Temp("台湾充值普通月卡"),
            [53] = _Temp("台湾充值高级月卡"),
            [54] = _Temp("台湾充值开服基金"),
            [55] = _Temp("台湾充值开服基金（第三方）"),
            [56] = _Temp("台湾充值100元宝"),
            [57] = _Temp("台湾充值200元宝"),
            [58] = _Temp("台湾充值300元宝"),
            [59] = _Temp("台湾充值400元宝"),
            [60] = _Temp("台湾充值700元宝"),
            [61] = _Temp("台湾充值800元宝"),
            [62] = _Temp("台湾充值900元宝"),
            [63] = _Temp("台湾充值1000元宝"),
            [64] = _Temp("台湾充值2000元宝"),
            [65] = _Temp("台湾充值2300元宝"),
            [66] = _Temp("台湾充值4000元宝"),
            [67] = _Temp("台湾充值6000元宝"),
            [68] = _Temp("台湾充值10000元宝"),
            [69] = _Temp("台湾充值20000元宝"),
		}
		local function onCloseWnd()
			g_GMConsole_CheckListOpen = false
		end
		g_ShowCheckListWnd(tbSetTimeOption,1,_Temp("选择元神类型"),SetTimeByType,onCloseWnd)
	end
	g_SetBtn(ImageView_ContentPNL,"Button_SetTime",SetTime, true)
	
	local Image_FunctionRowPNL4 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL4"), "ImageView")
	local Button_SetTime = tolua.cast(Image_FunctionRowPNL4:getChildByName("Button_SetTime"), "Button")
	local Label_FuncName = tolua.cast(Button_SetTime:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("设置时间"))
	g_SetBtnWithEvent(Button_SetTime, 1, SetTime, true, true)

	--自动测试 add by zgj
	local testTimeId = nil
	local function autoTest()
		bAutoTest = true
		local function table_iter(tb)
			local index = 0
			local ectypeID = g_Hero:getFinalClearEctypeID()
			local ectypeID = 1001
			for k,v in ipairs(tb) do
				if v.EctypeID == ectypeID then
					index = k
					break
				end
			end
			
		    local len = #tb
			return function ()
				index = index + 1
				if index <= len then 
		            return tb[index]
		        end
			end  
		end
		local tb = {}
		for k,v in pairs(ConfigMgr.MapEctypeSub) do
			table.insert(tb, v)
		end
		table.sort(tb, function (a, b)
			return tonumber(a.SubEctypeID) < tonumber(b.SubEctypeID) 
		end)
		local iter = table_iter(tb)
		g_MsgMgr:requestBattleInfo(iter().SubEctypeID)

		local function func()
	        local wnd = g_WndMgr:getWnd("Game_BatWin1")
			if wnd and bAutoTest then
				bAutoTest = false
		        g_Timer:pushTimer(3, function ()
		        	g_WndMgr:closeWnd("Game_BatWin1")
		        	 g_Timer:pushTimer(2, function ()
			        	g_MsgMgr:requestBattleInfo(iter().SubEctypeID)
			        	bAutoTest = true
			        end)	
		        end)	
			elseif g_WndMgr:getWnd("Game_BatFailed") then
				bAutoTest = false
			end
		end
		testTimeId = g_Timer:pushLoopTimer(1, func)
	end
	g_SetBtn(ImageView_ContentPNL,"Button_AutoTest",autoTest, true)
	
	local Image_FunctionRowPNL5 = tolua.cast(ListView_FunctionList:getChildByName("Image_FunctionRowPNL5"), "ImageView")
	local Button_AutoTest = tolua.cast(Image_FunctionRowPNL5:getChildByName("Button_AutoTest"), "Button")
	local Label_FuncName = tolua.cast(Button_AutoTest:getChildByName("Label_FuncName"), "Label")
	Label_FuncName:setText(_Temp("设置时间"))
	g_SetBtnWithEvent(Button_AutoTest, 1, autoTest, true, true)
end

function Game_GMConsole:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_GMConsolePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_GMConsolePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_GMConsolePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_GMConsole:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_GMConsolePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_GMConsolePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(ImageView_GMConsolePNL, actionEndCall, 1.05, 0.15, Image_Background)
end