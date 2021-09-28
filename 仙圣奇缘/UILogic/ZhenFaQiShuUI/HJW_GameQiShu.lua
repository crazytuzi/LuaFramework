--------------------------------------------------------------------------------------
-- 文件名:	Game_QiShu.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2014-12-01 11:01
-- 版  本:	1.0
-- 描  述:	奇术--阵法，秘术
-- 应  用:  
---------------------------------------------------------------------------------------
Game_QiShu = class("Game_QiShu")
Game_QiShu.__index = Game_QiShu
local SUCCEED = 4

--显示奇术升级的引导箭头
function Game_QiShu:showUpgradeGuideAni()
	if self.nCurPageIndex == 1 then
		g_addUpgradeGuide(self.Button_ZhenFa, ccp(65, 15), nil, nil)
		g_addUpgradeGuide(self.Button_XinFa, ccp(65, 15), nil, g_CheckXinFa())
		g_addUpgradeGuide(self.Button_ZhanShu, ccp(65, 15), nil, g_CheckZhanShu())
	elseif self.nCurPageIndex == 2 then
		g_addUpgradeGuide(self.Button_ZhenFa, ccp(65, 15), nil, g_CheckZhenFa())
		g_addUpgradeGuide(self.Button_XinFa, ccp(65, 15), nil, nil)
		g_addUpgradeGuide(self.Button_ZhanShu, ccp(65, 15), nil, g_CheckZhanShu())
	elseif self.nCurPageIndex == 3 then
		g_addUpgradeGuide(self.Button_ZhenFa, ccp(65, 15), nil, g_CheckZhenFa())
		g_addUpgradeGuide(self.Button_XinFa, ccp(65, 15), nil, g_CheckXinFa())
		g_addUpgradeGuide(self.Button_ZhanShu, ccp(65, 15), nil, nil)
	end
end

local function sortQiShuZhenfaCsv(CSV_QiShuZhenfaA, CSV_QiShuZhenfaB)
	return CSV_QiShuZhenfaA.SortRank < CSV_QiShuZhenfaB.SortRank
end

function Game_QiShu:getQiShuZhenfaInSort(nSortRank)
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
		cclog("===Game_QiShu:getQiShuZhenfaInSort error ==="..nSortRank)
		return ConfigMgr.QiShuZhenfa_[0]
	end
	return tbCsv
end

--请求升级阵法
function Game_QiShu:requestZhenFaLevelUp(nZhenFaCsvID)
	local tbSendMsg = zone_pb.ArrayUpgradeRequest()
	tbSendMsg.arrayidx = nZhenFaCsvID - 1
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ARRAY_UPGRADE_REQUEST, tbSendMsg)
end

--请求升级心法
function Game_QiShu:requestXinFaLevelUp(nXinFaCsvID)
	local tbSendMsg = zone_pb.SecretUpgradeRequest()
	tbSendMsg.secretid = nXinFaCsvID
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SECRET_UPGRADE_REQUEST, tbSendMsg)
end

--刷新单个阵法
function Game_QiShu:refesh_Button_ZhenFaColumn(Button_ZhenFaItem, nSortRank)
	Button_ZhenFaItem:setTag(nSortRank)
	
	local CSV_ZhenFa = self:getQiShuZhenfaInSort(nSortRank)
	local nZhenFaCsvID = CSV_ZhenFa.ZhenFaID
	
	local nZhenFaLevel = g_Hero:getZhenFaLevel(nZhenFaCsvID)
	local Label_ZhenFaName = tolua.cast(Button_ZhenFaItem:getChildByName("Label_ZhenFaName"), "Label")
	Label_ZhenFaName:setText(CSV_ZhenFa.ZhenFaName.." ")
	
	local Label_ZhenFaLevel = tolua.cast(Label_ZhenFaName:getChildByName("Label_ZhenFaLevel"), "Label")
	Label_ZhenFaLevel:setText(_T("Lv.")..nZhenFaLevel)
	
	-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
	Label_ZhenFaLevel:setPositionX(Label_ZhenFaName:getSize().width)
	-- end
	
	local Label_ZhenFaProp = tolua.cast(Button_ZhenFaItem:getChildByName("Label_ZhenFaProp"), "Label")
	Label_ZhenFaProp:setText(g_Hero:getZhenFaPropString(nZhenFaCsvID))

	local function onClick_Button_LevelUp(pSender, nTag)
		local CSV_ZhenFaTemp = self:getQiShuZhenfaInSort(nTag)
		if g_Hero:checkZhenFaEnable(CSV_ZhenFaTemp.ZhenFaID) ~= SUCCEED then
			return
		end
		self:requestZhenFaLevelUp(CSV_ZhenFaTemp.ZhenFaID)
	end
	
	local Button_LevelUp = tolua.cast(Button_ZhenFaItem:getChildByName("Button_LevelUp"), "Button")
	local Button_ZhenFaIcon = tolua.cast(Button_ZhenFaItem:getChildByName("Button_ZhenFaIcon"), "Button")
	local BitmapLabel_OpenLevel = tolua.cast(Button_ZhenFaIcon:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
	local Label_OpenLevelTip = tolua.cast(Button_ZhenFaItem:getChildByName("Label_OpenLevelTip"), "Label")
	local Label_NeedXueShiLB = tolua.cast(Button_ZhenFaItem:getChildByName("Label_NeedXueShiLB"), "Label")
	local Image_Activated = tolua.cast(Button_ZhenFaIcon:getChildByName("Image_Activated"), "ImageView")
	Image_Activated:setVisible(g_Hero:checkZhenFaIsActivate(nZhenFaCsvID))
	if g_Hero:checkZhenFaRelease(nZhenFaCsvID) then --已解锁
		BitmapLabel_OpenLevel:setVisible(false)
		Label_OpenLevelTip:setVisible(false)
		Label_NeedXueShiLB:setVisible(true)
		
		local Label_NeedXueShi = tolua.cast(Label_NeedXueShiLB:getChildByName("Label_NeedXueShi"), "Label")
		Label_NeedXueShi:setText(g_Hero:getZhenFaNeedKnowledge(nZhenFaCsvID))
			
		-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_NeedXueShi:setPositionX(Label_NeedXueShiLB:getSize().width)
		-- end
		
		local bCheckZhenFaCost = g_Hero:checkZhenFaCost(nZhenFaCsvID)
		if bCheckZhenFaCost then
			g_setTextColor(Label_NeedXueShi,ccs.COLOR.BRIGHT_GREEN)
		else
			g_setTextColor(Label_NeedXueShi,ccs.COLOR.RED)
		end
		
		local bCheckZhenFaLevel = g_Hero:checkZhenFaLevel(nZhenFaCsvID)
		if bCheckZhenFaLevel then
			g_setTextColor(Label_ZhenFaLevel,ccs.COLOR.WHITE)
		else
			g_setTextColor(Label_ZhenFaLevel,ccs.COLOR.RED)
		end
		
		Button_LevelUp:setVisible(true)
		g_SetBtnWithGuideCheck(Button_LevelUp, nSortRank, onClick_Button_LevelUp, bCheckZhenFaCost and bCheckZhenFaLevel)
		g_SetBtnWithGuideCheck(Button_ZhenFaItem, nSortRank, onClick_Button_LevelUp, bCheckZhenFaCost and bCheckZhenFaLevel)

		Button_ZhenFaIcon:loadTextureNormal(getIconImg(CSV_ZhenFa.ZhenFaIcon))
		Button_ZhenFaIcon:loadTexturePressed(getIconImg(CSV_ZhenFa.ZhenFaIcon))
		Button_ZhenFaIcon:loadTextureDisabled(getIconImg(CSV_ZhenFa.ZhenFaIcon))
		Button_ZhenFaIcon:setBright(true)
		Button_ZhenFaIcon:setTouchEnabled(true)
		
		g_addUpgradeGuide(Button_LevelUp, ccp(55, 5), nil, g_CheckZhenFaItem(nZhenFaCsvID))
	else --未解锁
		BitmapLabel_OpenLevel:setVisible(true)
		BitmapLabel_OpenLevel:setText(CSV_ZhenFa.OpenLevel)
		Label_OpenLevelTip:setVisible(true)
		
		Label_OpenLevelTip:setText(string.format(_T("主角%d级解锁"), CSV_ZhenFa.OpenLevel))
		Label_NeedXueShiLB:setVisible(false)
		
		Button_LevelUp:setVisible(false)
		Button_LevelUp:setBright(false)
		Button_LevelUp:setTouchEnabled(false)
		
		Button_ZhenFaIcon:loadTextureNormal(getUIImg("Frame_Qishu_Locker"))
		Button_ZhenFaIcon:loadTexturePressed(getUIImg("Frame_Qishu_Locker"))
		Button_ZhenFaIcon:loadTextureDisabled(getUIImg("Frame_Qishu_Locker"))
		Button_ZhenFaIcon:setBright(false)
		Button_ZhenFaIcon:setTouchEnabled(false)
	end


	local function onClick_Button_ZhenFaIcon(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local nTag = pSender:getTag()
			local CSV_ZhenFa = self:getQiShuZhenfaInSort(nTag)
			local tbParam = {
				CSV_QiShu = CSV_ZhenFa,
				nQiShuID = CSV_ZhenFa.ZhenFaID,
				nTipType = 1
			}
			g_WndMgr:showWnd("Game_TipQiShu", tbParam)
		end
	end
	Button_ZhenFaIcon:setTag(nSortRank)
	Button_ZhenFaIcon:addTouchEventListener(onClick_Button_ZhenFaIcon)
end

--刷新一排阵法
function Game_QiShu:refesh_Image_ZhenFaRowPNL(Image_ZhenFaRowPNL, nRow)
	Image_ZhenFaRowPNL:setTag(nRow)
	local nCurBeginRow = (nRow - 1) * 3
	for nColumn = 1, 3 do
		local nSortRank = nCurBeginRow + nColumn
		local Button_ZhenFaItem = tolua.cast(Image_ZhenFaRowPNL:getChildByName("Button_ZhenFaItem"..nColumn), "Button")
		self:refesh_Button_ZhenFaColumn(Button_ZhenFaItem, nSortRank)
	end
end

--刷新阵法，不重新创建控件
function Game_QiShu:refresh_Image_ZhenFaPNL()

	local wndInstance = g_WndMgr:getWnd("Game_QiShu")
	if wndInstance then
		if not wndInstance.Image_ZhenFaPNL then return end 
		
		local nZhenFaListCount = g_Hero:getZhenFaListCount()
		local ListView_ZhenFaList = tolua.cast(wndInstance.Image_ZhenFaPNL:getChildByName("ListView_ZhenFaList"), "ListViewEx")
		for nSortRank = 1, nZhenFaListCount do
			local nRow = math.ceil(nSortRank/3)
			local Image_ZhenFaRowPNL = ListView_ZhenFaList:getChildByTag(nRow)
			local Button_ZhenFaItem = Image_ZhenFaRowPNL:getChildByTag(nSortRank)
			wndInstance:refesh_Button_ZhenFaColumn(Button_ZhenFaItem, nSortRank)
		end
	end
	
end

--重置阵法
function Game_QiShu:set_Image_ZhenFaPNL()
	local nRowCount = math.ceil(g_Hero:getZhenFaListCount()/3)
	cclog("============nRowCount=========="..nRowCount)
	self.LuaListView_ZhenFaList:updateItems(nRowCount)
end

--刷新单个心法
function Game_QiShu:refesh_Button_XinFaColumn(Button_XinFaItem, nXinFaCsvID)
	Button_XinFaItem:setTag(nXinFaCsvID)
	
	local CSV_QiShuSkill = g_Hero:getXinFaCsvBase(nXinFaCsvID)
	local nXinFaLevel = g_Hero:getXinFaLevel(nXinFaCsvID)
	local Label_XinFaName = tolua.cast(Button_XinFaItem:getChildByName("Label_XinFaName"), "Label")
	Label_XinFaName:setText(CSV_QiShuSkill.Name.." ")
	local Label_XinFaLevel = tolua.cast(Label_XinFaName:getChildByName("Label_XinFaLevel"), "Label")
	Label_XinFaLevel:setText(_T("Lv.")..nXinFaLevel)
	local Label_XinFaProp = tolua.cast(Button_XinFaItem:getChildByName("Label_XinFaProp"), "Label")
	Label_XinFaProp:setText(g_Hero:getXinFaPropString(nXinFaCsvID))
	Label_XinFaLevel:setPositionX(Label_XinFaName:getSize().width)

	local function onClick_Button_LevelUp(pSender, nXinFaCsvID)

		if g_Hero:checkXinFaEnable(nXinFaCsvID) < SUCCEED then
			return
		end
		
		self:requestXinFaLevelUp(nXinFaCsvID)
	end
	
	local Button_LevelUp = tolua.cast(Button_XinFaItem:getChildByName("Button_LevelUp"), "Button")
	local Button_XinFaIcon = tolua.cast(Button_XinFaItem:getChildByName("Button_XinFaIcon"), "Button")
	local BitmapLabel_OpenLevel = tolua.cast(Button_XinFaIcon:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
	local Label_OpenLevelTip = tolua.cast(Button_XinFaItem:getChildByName("Label_OpenLevelTip"), "Label")
	local Label_NeedXueShiLB = tolua.cast(Button_XinFaItem:getChildByName("Label_NeedXueShiLB"), "Label")
	
	if g_Hero:checkXinFaRelease(nXinFaCsvID) then --已解锁
		BitmapLabel_OpenLevel:setVisible(false)
		Label_OpenLevelTip:setVisible(false)
		Label_NeedXueShiLB:setVisible(true)
		
		local Label_NeedXueShi = tolua.cast(Label_NeedXueShiLB:getChildByName("Label_NeedXueShi"), "Label")
		Label_NeedXueShi:setText(g_Hero:getXinFaNeedKnowledge(nXinFaCsvID))
		
		Label_NeedXueShi:setPositionX(Label_NeedXueShiLB:getSize().width)
			
		local bCheckXinFaCost = g_Hero:checkXinFaCost(nXinFaCsvID)
		if bCheckXinFaCost then
			g_setTextColor(Label_NeedXueShi, ccs.COLOR.BRIGHT_GREEN)
		else
			g_setTextColor(Label_NeedXueShi, ccs.COLOR.RED)
		end
		
		local bCheckXinFaLevel = g_Hero:checkXinFaLevel(nXinFaCsvID)
		if bCheckXinFaLevel then
			g_setTextColor(Label_XinFaLevel, ccs.COLOR.WHITE)
		else
			g_setTextColor(Label_XinFaLevel, ccs.COLOR.RED)
		end
		
		g_SetBtnWithGuideCheck(Button_LevelUp, nXinFaCsvID, onClick_Button_LevelUp, bCheckXinFaCost and bCheckXinFaLevel)
		g_SetBtnWithGuideCheck(Button_XinFaItem, nXinFaCsvID, onClick_Button_LevelUp, bCheckXinFaCost and bCheckXinFaLevel)
		
		Button_XinFaIcon:loadTextureNormal(getIconImg(CSV_QiShuSkill.Icon))
		Button_XinFaIcon:loadTexturePressed(getIconImg(CSV_QiShuSkill.Icon))
		Button_XinFaIcon:loadTextureDisabled(getIconImg(CSV_QiShuSkill.Icon))
		Button_XinFaIcon:setBright(true)
		Button_XinFaIcon:setTouchEnabled(true)
	else
		BitmapLabel_OpenLevel:setVisible(true)
		BitmapLabel_OpenLevel:setText(CSV_QiShuSkill.OpenLevel)
		Label_OpenLevelTip:setVisible(true)
		
		Label_OpenLevelTip:setText(string.format(_T("主角%d级解锁"), CSV_QiShuSkill.OpenLevel))
		Label_NeedXueShiLB:setVisible(false)
		
		Button_LevelUp:setVisible(false)
		Button_LevelUp:setBright(false)
		Button_LevelUp:setTouchEnabled(false)
		
		Button_XinFaIcon:loadTextureNormal(getUIImg("Frame_Qishu_Locker"))
		Button_XinFaIcon:loadTexturePressed(getUIImg("Frame_Qishu_Locker"))
		Button_XinFaIcon:loadTextureDisabled(getUIImg("Frame_Qishu_Locker"))
		Button_XinFaIcon:setBright(false)
		Button_XinFaIcon:setTouchEnabled(false)
	end
	
	local function onClick_Button_XinFaIcon(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local tbParam = {
				CSV_QiShu = CSV_QiShuSkill,
				nQiShuID = nXinFaCsvID,
				nTipType = 2
			}
			g_WndMgr:showWnd("Game_TipQiShu", tbParam)
		end
	end
	Button_XinFaIcon:addTouchEventListener(onClick_Button_XinFaIcon)
end

--刷新单个战术
function Game_QiShu:refesh_Button_ZhanShuColumn(Button_ZhanShuItem, nZhanShuCsvID)
	Button_ZhanShuItem:setTag(nZhanShuCsvID)
	local CSV_ZhanShuSkill = g_DataMgr:getCsvConfig_FirstKeyData("QiShuZhanShu",nZhanShuCsvID)

	local nZhanShuLevel = g_Hero:getXinFaLevel(nZhanShuCsvID) or 1
	local Label_ZhanShuName = tolua.cast(Button_ZhanShuItem:getChildByName("Label_ZhanShuName"), "Label")
	Label_ZhanShuName:setText(CSV_ZhanShuSkill.ZhanShuName.." ")

	local Label_ZhanShuDesc = tolua.cast(Button_ZhanShuItem:getChildByName("Label_ZhanShuDesc"), "Label")
	
	local str_text = g_string_insert(CSV_ZhanShuSkill.ZhanShuDesc,"\n",20)
	Label_ZhanShuDesc:setText(str_text)
	
	local function onClick_Button_LevelUp(pSender, nZhanShuCsvID)
		if g_Hero:checkZhanShuEnable(nZhanShuCsvID) ~= 2 then 
			return
		end
		self:requestXinFaLevelUp(nZhanShuCsvID)
	end
	
	local Button_ZhanShuIcon = tolua.cast(Button_ZhanShuItem:getChildByName("Button_ZhanShuIcon"), "Button")
	local Button_LevelUp = tolua.cast(Button_ZhanShuItem:getChildByName("Button_LevelUp"), "Button")
	local Button_Activate = tolua.cast(Button_ZhanShuItem:getChildByName("Button_Activate"), "Button")
	local BitmapLabel_OpenLevel = tolua.cast(Button_ZhanShuIcon:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
	local Image_CheckCover = tolua.cast(Button_ZhanShuItem:getChildByName("Image_CheckCover"), "ImageView")
	local Image_Activated = tolua.cast(Button_ZhanShuIcon:getChildByName("Image_Activated"), "ImageView")
	Image_Activated:setVisible(false)
	Image_CheckCover:setVisible(false)
	local Label_OpenLevelTip = tolua.cast(Button_ZhanShuItem:getChildByName("Label_OpenLevelTip"), "Label")
	
	if g_Hero:checkZhanShuRelease(nZhanShuCsvID) then --已解锁
		BitmapLabel_OpenLevel:setVisible(false)
		Label_OpenLevelTip:setVisible(false)
		Button_Activate:setVisible(true)
		Button_LevelUp:setVisible(true)
		Button_LevelUp:setBright(true)
		Button_LevelUp:setTouchEnabled(true)

		Button_ZhanShuIcon:loadTextureNormal(getIconImg(CSV_ZhanShuSkill.ZhanShuIcon))
		Button_ZhanShuIcon:loadTexturePressed(getIconImg(CSV_ZhanShuSkill.ZhanShuIcon))
		Button_ZhanShuIcon:loadTextureDisabled(getIconImg(CSV_ZhanShuSkill.ZhanShuIcon))
		Button_ZhanShuIcon:setBright(true)
		Button_ZhanShuIcon:setTouchEnabled(true)
		
		g_addUpgradeGuide(Button_LevelUp, ccp(55, 5), nil, g_CheckZhenXin(nZhanShuCsvID))
	else
		Button_Activate:setVisible(false)
		Button_LevelUp:setVisible(false)
		BitmapLabel_OpenLevel:setVisible(true)
		BitmapLabel_OpenLevel:setText(CSV_ZhanShuSkill.OpenLevel)
		Label_OpenLevelTip:setVisible(true)
		
		Label_OpenLevelTip:setText(string.format(_T("主角%d级解锁"), CSV_ZhanShuSkill.OpenLevel))

		Button_LevelUp:setVisible(false)
		Button_LevelUp:setBright(false)
		Button_LevelUp:setTouchEnabled(false)
		
		Button_ZhanShuIcon:loadTextureNormal(getUIImg("Frame_Qishu_Locker"))
		Button_ZhanShuIcon:loadTexturePressed(getUIImg("Frame_Qishu_Locker"))
		Button_ZhanShuIcon:loadTextureDisabled(getUIImg("Frame_Qishu_Locker"))
		Button_ZhanShuIcon:setBright(false)
		Button_ZhanShuIcon:setTouchEnabled(false)
	end
	
	local function onClick_Button_XinFaIcon(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			self:TacticsSelectRequest(pSender:getTag())
		end
	end

	local function onClick_Button_LevelUp(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local tag = pSender:getTag()
			g_WndMgr:openWnd("Game_ZhenXin", tag)
		end
	end

	if self.curActivatedIndex == nZhanShuCsvID then
		Image_Activated:setVisible(true)
		Image_CheckCover:setVisible(true)
	end
	
	Button_Activate:setTag(nZhanShuCsvID)
	Button_Activate:addTouchEventListener(onClick_Button_XinFaIcon)
	Button_LevelUp:setTag(nZhanShuCsvID)
	Button_LevelUp:addTouchEventListener(onClick_Button_LevelUp)
end

--刷新一排心法
function Game_QiShu:refesh_Image_XinFaRowPNL(Image_XinFaRowPNL, nRow)
	Image_XinFaRowPNL:setTag(nRow)
	local nCurBeginRow = (nRow - 1) * 3
	for nColumn = 1, 3 do
		local nXinFaID = nCurBeginRow + nColumn
		local Button_XinFaItem = tolua.cast(Image_XinFaRowPNL:getChildByName("Button_XinFaItem"..nColumn), "Button")
		self:refesh_Button_XinFaColumn(Button_XinFaItem, nXinFaID, nColumn)
	end
end 
--刷新一排心法
function Game_QiShu:refesh_Image_ZhanShuPNL(Image_ZhanShuRowPNL, nRow)
	Image_ZhanShuRowPNL:setTag(nRow)
	local nCurBeginRow = (nRow - 1) * 3
	for nColumn = 1, 3 do
		local nZhanShuCsvID = nCurBeginRow + nColumn
		local Button_ZhanShuItem = tolua.cast(Image_ZhanShuRowPNL:getChildByName("Button_ZhanShuItem"..nColumn), "Button")
		self:refesh_Button_ZhanShuColumn(Button_ZhanShuItem, nZhanShuCsvID, nColumn)
	end
end

--刷新心法，不重新创建控件
function Game_QiShu:refresh_Image_XinFaPNL()
	local nXinFaListCount = g_Hero:getXinFaListCount()
	local ListView_XinFaList = tolua.cast(self.Image_XinFaPNL:getChildByName("ListView_XinFaList"), "ListViewEx")
	for nXinFaCsvID = 1, nXinFaListCount do
		local nRow = math.ceil(nXinFaCsvID/3)
		local Image_XinFaRowPNL = ListView_XinFaList:getChildByTag(nRow)
		local Button_XinFaItem = Image_XinFaRowPNL:getChildByTag(nXinFaCsvID)
		self:refesh_Button_XinFaColumn(Button_XinFaItem, nXinFaCsvID)
	end
end 
--刷新心法，不重新创建控件
function Game_QiShu:refresh_Image_ZhanShuPNL()
	local nXinFaListCount = g_DataMgr:getCsvConfig("QiShuZhanShu")
	local ListView_ZhanShuList = tolua.cast(self.Image_ZhanShuPNL:getChildByName("ListView_ZhanShuList"), "ListViewEx")
	for nXinFaCsvID = 1, #nXinFaListCount do
		local nRow = math.ceil(nXinFaCsvID/3)
		local Image_ZhanShuRowPNL = ListView_ZhanShuList:getChildByTag(nRow)
		local Button_ZhanShuItem = Image_ZhanShuRowPNL:getChildByTag(nXinFaCsvID)
		self:refesh_Button_ZhanShuColumn(Button_ZhanShuItem, nXinFaCsvID)
	end
end

--重置心法
function Game_QiShu:set_Image_XinFaPNL()
	local nRowCount = math.ceil(g_Hero:getXinFaListCount()/3)
	self.LuaListView_XinFaList:updateItems(nRowCount)
end
--重置心法
function Game_QiShu:set_Image_ZhanShu()
	local CSV_ZhanShuSkill = g_DataMgr:getCsvConfig("QiShuZhanShu")
	local nRowCount = math.ceil(#CSV_ZhanShuSkill/3)
	self.LuaListView_ZhanShuList:updateItems(nRowCount)
end

function Game_QiShu:closeWnd()
	self.curImage_Activated = nil
	
	local Image_QiShuPNL = tolua.cast(self.rootWidget:getChildByName("Image_QiShuPNL"), "ImageView")
	local Image_BackgroundInside = tolua.cast(Image_QiShuPNL:getChildByName("Image_BackgroundInside"), "ImageView")
	Image_BackgroundInside:loadTexture(getUIImg("Blank"))
end

--初始化界面，注册函数和self成员控件
function Game_QiShu:initWnd()
	local Image_QiShuPNL = tolua.cast(self.rootWidget:getChildByName("Image_QiShuPNL"),"ImageView")
	local Image_QiShuContentPNL = tolua.cast(Image_QiShuPNL:getChildByName("Image_QiShuContentPNL"),"ImageView")
	
	self.ButtonGroup_ = ButtonGroup:create()
	self.Button_ZhenFa = tolua.cast(Image_QiShuContentPNL:getChildByName("Button_ZhenFa"),"Button")
	self.Button_XinFa = tolua.cast(Image_QiShuContentPNL:getChildByName("Button_XinFa"),"Button")
	self.Image_ZhenFaPNL = tolua.cast(Image_QiShuContentPNL:getChildByName("Image_ZhenFaPNL"),"ImageView")
	self.Image_XinFaPNL = tolua.cast(Image_QiShuContentPNL:getChildByName("Image_XinFaPNL"),"ImageView")
	self.Button_ZhanShu = tolua.cast(Image_QiShuContentPNL:getChildByName("Button_ZhanShu"),"Button")
	self.Image_ZhanShuPNL = tolua.cast(Image_QiShuContentPNL:getChildByName("Image_ZhanShuPNL"),"ImageView")

	local function onCheck_Button_ZhenFa()
		self:set_Image_ZhenFaPNL()
		self.nCurPageIndex = 1
        self:showUpgradeGuideAni()
	end	
	self.ButtonGroup_:PushBack(self.Button_ZhenFa, self.Image_ZhenFaPNL, onCheck_Button_ZhenFa)
	
	local function onCheck_Button_XinFa(idx)
		self:set_Image_XinFaPNL()
		self.nCurPageIndex = 2
		self:showUpgradeGuideAni()
	end
	self.ButtonGroup_:PushBack(self.Button_XinFa, self.Image_XinFaPNL, onCheck_Button_XinFa)
	
	local function onCheck_Button_ZhanShu(idx)
		self.curActivatedIndex  = g_Hero:getCurZhanShuCsvID() or 1
		self:set_Image_ZhanShu()
		self.nCurPageIndex = 3
		self:showUpgradeGuideAni() 
	end
	self.ButtonGroup_:PushBack(self.Button_ZhanShu, self.Image_ZhanShuPNL, onCheck_Button_ZhanShu)
	
	local ListView_ZhenFaList = tolua.cast(self.Image_ZhenFaPNL:getChildByName("ListView_ZhenFaList"), "ListViewEx")
	local Image_ZhenFaRowPNL = tolua.cast(g_WidgetModel.Image_ZhenFaRowPNL:clone(), "ImageView")
    self.LuaListView_ZhenFaList = Class_LuaListView:new()
    self.LuaListView_ZhenFaList:setListView(ListView_ZhenFaList)
    self.LuaListView_ZhenFaList:setModel(Image_ZhenFaRowPNL)
	local function updateZhenFaList(Image_ZhenFaRowPNL, nRow)
		self:refesh_Image_ZhenFaRowPNL(Image_ZhenFaRowPNL, nRow)
	end
	self.LuaListView_ZhenFaList:setUpdateFunc(updateZhenFaList)
   
	local ListView_XinFaList = tolua.cast(self.Image_XinFaPNL:getChildByName("ListView_XinFaList"), "ListViewEx")
	local Image_XinFaRowPNL = tolua.cast(g_WidgetModel.Image_XinFaRowPNL:clone(), "ImageView")
    self.LuaListView_XinFaList = Class_LuaListView:new()
    self.LuaListView_XinFaList:setListView(ListView_XinFaList)
    self.LuaListView_XinFaList:setModel(Image_XinFaRowPNL)
	local function updateXinFaList(Image_XinFaRowPNL, nRow)
		self:refesh_Image_XinFaRowPNL(Image_XinFaRowPNL, nRow)
	end
	self.LuaListView_XinFaList:setUpdateFunc(updateXinFaList)
	
	local ListView_ZhanShuList = tolua.cast(self.Image_ZhanShuPNL:getChildByName("ListView_ZhanShuList"), "ListViewEx")
	local Image_ZhanShuRowPNL = tolua.cast(g_WidgetModel.Image_ZhanShuRowPNL:clone(), "ImageView")
	local function updateZhanShuList(Image_ZhanShuRowPNL, nRow)
		self:refesh_Image_ZhanShuPNL(Image_ZhanShuRowPNL, nRow)
	end
	self.LuaListView_ZhanShuList = registerListViewEvent(ListView_ZhanShuList,Image_ZhanShuRowPNL,updateZhanShuList)
	
	--注册升级阵法消息
	local order = msgid_pb.MSGID_ARRAY_UPGRADE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self, self.ArrayUpgradeResponse))
	
	--注册心法升级消息
	local order = msgid_pb.MSGID_SECRET_UPGRADE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self, self.SecretUpgradeResponse))
	local order1 = msgid_pb.MSGID_TACTICS_SELECT_RESPONSE
	g_MsgMgr:registerCallBackFunc(order1, handler(self, self.TacticsSelectResponse))
	
	local Image_QiShuPNL = tolua.cast(self.rootWidget:getChildByName("Image_QiShuPNL"), "ImageView")
	local Image_BackgroundInside = tolua.cast(Image_QiShuPNL:getChildByName("Image_BackgroundInside"), "ImageView")
	Image_BackgroundInside:loadTexture(getBackgroundJpgImg("Background_QiShu"))
end

function Game_QiShu:setFunctionOpen()
	if not self.rootWidget then return end
	local Image_QiShuPNL = tolua.cast(self.rootWidget:getChildByName("Image_QiShuPNL"),"ImageView")
	local Image_QiShuContentPNL = tolua.cast(Image_QiShuPNL:getChildByName("Image_QiShuContentPNL"),"ImageView")
	local Button_XinFa = tolua.cast(Image_QiShuContentPNL:getChildByName("Button_XinFa"),"Button")
	local Button_ZhanShu = tolua.cast(Image_QiShuContentPNL:getChildByName("Button_ZhanShu"),"Button")
	
	local bEnable_Button_XinFa = g_CheckFuncCanOpenByWidgetName(Button_XinFa:getName())
	if not bEnable_Button_XinFa then
		Button_XinFa:setTouchEnabled(false)
		Button_XinFa:setVisible(false)
	else
		Button_XinFa:setTouchEnabled(true)
		Button_XinFa:setVisible(true)
	end
	
	local bEnable_Button_ZhanShu = g_CheckFuncCanOpenByWidgetName(Button_ZhanShu:getName())
	if not bEnable_Button_ZhanShu then
		Button_ZhanShu:setTouchEnabled(false)
		Button_ZhanShu:setVisible(false)
	else
		Button_ZhanShu:setTouchEnabled(true)
		Button_ZhanShu:setVisible(true)
	end
	
	if not bEnable_Button_XinFa then
		g_HeadBar:setHeadBarPositionX(-350)
		return
	end
	
	if not bEnable_Button_ZhanShu then
		g_HeadBar:setHeadBarPositionX(-175)
		return
	end
	
	g_HeadBar:setHeadBarPositionX(0)
end

--打开界面
function Game_QiShu:openWnd()
	self.nCurPageIndex = self.nCurPageIndex or 1
	self:setFunctionOpen()
	self.ButtonGroup_:Click(self.nCurPageIndex)
end

--显示升级之后的光罩动画
function Game_QiShu:showQiShuLevelUpAni(widget)
	if not self.rootWidget then return end
	local function guideAnimationEndEvent()
		if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "QiShuLevelUp") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("QiShuLevelUp", nil, guideAnimationEndEvent, 5)
	local tbWorldPos = widget:getWorldPosition()
	armature:setPosition(tbWorldPos)
	self.rootWidget:addNode(armature, 100)
	userAnimation:playWithIndex(0)	
end

--阵法升级服务端回调函数
function Game_QiShu:ArrayUpgradeResponse(tbMsg)
	local tbMsgDetail = zone_pb.ArrayUpgradeResponse()
	tbMsgDetail:ParseFromString(tbMsg.buffer)
	
	local nZhenFaCsvID = tbMsgDetail.arrayidx + 1	--升级的阵法
	local nZhenFaLevel = tbMsgDetail.arraylv	--阵法等级
	local nRemainKnowledge = tbMsgDetail.updated_knowdge	--剩余阅历
	
	g_Hero:setZhenFaLevel(nZhenFaCsvID, nZhenFaLevel)
	g_Hero:setKnowledge(nRemainKnowledge)
	
	local wndInstance = g_WndMgr:getWnd("Game_QiShu")
	if wndInstance then
		wndInstance:setFunctionOpen()
		wndInstance:refresh_Image_ZhenFaPNL()
		local CSV_ZhenFa = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhenfa", nZhenFaCsvID, 1)
		local nSortRank = CSV_ZhenFa.SortRank
		local nRow = math.ceil(nSortRank/3)
		local ListView_ZhenFaList = tolua.cast(wndInstance.Image_ZhenFaPNL:getChildByName("ListView_ZhenFaList"), "ListViewEx")
		local Image_ZhenFaRowPNL = ListView_ZhenFaList:getChildByTag(nRow)
		local Button_ZhenFaItem = Image_ZhenFaRowPNL:getChildByTag(nSortRank)
		local Button_ZhenFaIcon = tolua.cast(Button_ZhenFaItem:getChildByName("Button_ZhenFaIcon"), "Button")
		
		wndInstance:showQiShuLevelUpAni(Button_ZhenFaIcon)
		wndInstance:showUpgradeGuideAni()
	end
	
	g_Hero:updateZhenFaProp(nZhenFaCsvID)
end

--心法升级服务端回调函数
function Game_QiShu:SecretUpgradeResponse(tbMsg)
	local tbMsgDetail = zone_pb.SecretUpgradeResponse()
	tbMsgDetail:ParseFromString(tbMsg.buffer)
	
	local nXinFaCsvID = tbMsgDetail.secretid  --心法索引下标
	local nXinFaLevel = tbMsgDetail.secretlv --心法等级
	local nRemainKnowledge = tbMsgDetail.updated_knowdge	--剩余阅历
	
	g_Hero:updateXinFaLevel(nXinFaCsvID, nXinFaLevel) --更新心法等级
	g_Hero:setKnowledge(nRemainKnowledge) --更新当前剩余多少阅历
	
	self:setFunctionOpen()
	self:refresh_Image_XinFaPNL()
	
	local nRow = math.ceil(nXinFaCsvID/3)
	local ListView_XinFaList = tolua.cast(self.Image_XinFaPNL:getChildByName("ListView_XinFaList"), "ListViewEx")
	local Image_XinFaRowPNL = ListView_XinFaList:getChildByTag(nRow)
	local Button_XinFaItem = Image_XinFaRowPNL:getChildByTag(nXinFaCsvID)
	local Button_XinFaIcon = tolua.cast(Button_XinFaItem:getChildByName("Button_XinFaIcon"), "Button")

	self:showQiShuLevelUpAni(Button_XinFaIcon)
	self:showUpgradeGuideAni()
	
	g_Hero:updateXinFaProp()
end

--发送战术索引
function Game_QiShu:TacticsSelectRequest(TacticsIndex)
	local rootMsg = zone_pb.TacticsSelectRequest()
	rootMsg.idx = TacticsIndex

	g_MsgMgr:sendMsg(msgid_pb.MSGID_TACTICS_SELECT_REQUEST,rootMsg)
end
--战术索引
function Game_QiShu:TacticsSelectResponse(tbMsg)
	local tbMsgDetail = zone_pb.TacticsSelectResponse()
	tbMsgDetail:ParseFromString(tbMsg.buffer)
	self.curActivatedIndex = tbMsgDetail.idx
	g_Hero:setCurZhanShuCsvID(tbMsgDetail.idx)
	self:refresh_Image_ZhanShuPNL()
	
	g_Hero:updateXinFaProp()
end

function Game_QiShu:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_QiShuPNL = tolua.cast(self.rootWidget:getChildByName("Image_QiShuPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_QiShuPNL, nil, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation(funcWndOpenAniCall)
end

function Game_QiShu:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_QiShuPNL = tolua.cast(self.rootWidget:getChildByName("Image_QiShuPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(Image_QiShuPNL, actionEndCall, 1.05, 0.15, Image_Background)
end