--------------------------------------------------------------------------------------
-- 文件名:	MapWorld.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-13 9:37
-- 版  本:	1.0
-- 描  述:	游戏主界面之伙伴主界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

Game_Ectype = class("Game_Ectype")
Game_Ectype.__index = Game_Ectype

function Game_Ectype:getMaxOpenMapCsvID()
	local nFinalClearMapID = g_Hero:getFinalClearMapID()
	if nFinalClearMapID < #g_DataMgr:getCsvConfig("MapBase") then
		local nFinalClearEctypeID = g_Hero:getFinalClearEctypeID()
		if nFinalClearEctypeID > 0 then
			local CSV_MapEctype_Next = g_DataMgr:getMapEctypeCsv(nFinalClearEctypeID + 1)
			if CSV_MapEctype_Next.EctypeID == 0 or g_Hero:getEctypePassStar(CSV_MapEctype_Next.EctypeID) then --说明已经是最后一关了
				local CSV_MapBase_Next = g_DataMgr:getMapBaseCsv(nFinalClearMapID + 1)
				if CSV_MapBase_Next.MapLevel <= g_DataMgr:getGlobalCfgCsv("max_open_map_lev") then
					nFinalClearMapID = nFinalClearMapID + 1
				end
			end
		end
	end
	-- 分析过了，不可能返回非法值
	return nFinalClearMapID
end
	
function Game_Ectype:showGame_EctypeList(nMapBaseCsvID)
	if not self.rootWidget or not self.rootWidget:isExsit() then return end
	g_WndMgr:showWnd("Game_EctypeList", nMapBaseCsvID)
	g_MsgNetWorkWarning:closeNetWorkWarning()
end

local function onClick_Button_Map(pSender, nMapBaseCsvID)
	local CSV_MapBase = g_DataMgr:getMapBaseCsv(nMapBaseCsvID)
	if (CSV_MapBase.MapLevel > g_Hero:getMasterCardLevel() )then
		g_ClientMsgTips:showMsgConfirm(string.format(_T("您需要达到%d级才可以进入该地图的副本"), CSV_MapBase.MapLevel))
		return
	end

	local wndInstance = g_WndMgr:getWnd("Game_Ectype")
	if wndInstance then
		if wndInstance.nMaxOpenMapCsvID and g_EctypeListSystem:GetEctypeDataIsExist(nMapBaseCsvID) == false then --g_EctypeListSystem:GetEctypeDataIsExist(nMapBaseCsvID) == false
			g_MsgMgr:requestEctypePassInfo(nMapBaseCsvID)
		else
			local wndInstance = g_WndMgr:getWnd("Game_Ectype")
			if wndInstance then
				wndInstance:showGame_EctypeList(nMapBaseCsvID)
			end
		end
		--g_MsgMgr:requestEctypePassInfo(nMapBaseCsvID)
	end
end

function Game_Ectype:initButton_Map(Button_Map, nMapBaseCsvID)
	local CSV_MapBase = g_DataMgr:getMapBaseCsv(nMapBaseCsvID)
	Button_Map:loadTextureNormal(getMapImg(CSV_MapBase.Icon))
	Button_Map:loadTexturePressed(getMapImg(CSV_MapBase.Icon))
	Button_Map:loadTextureDisabled(getMapImg(CSV_MapBase.Icon))
	Button_Map:setPositionXY(CSV_MapBase.Pos_X, CSV_MapBase.Pos_Y)
	Button_Map:setTouchEnabled(true)
    Button_Map:setAlphaTouchEnable(true)
	local Image_Check = tolua.cast(Button_Map:getChildByName("Image_Check"), "ImageView")
	Image_Check:loadTexture(getMapImg(CSV_MapBase.Icon.."_Click"))
	
	g_SetBtnGuideCheckWithPressImage(Button_Map, nMapBaseCsvID, onClick_Button_Map, true, false, 3, nil, true)
end

function Game_Ectype:initMapNameBase(Image_NameBase, nMapBaseCsvID)
	--创建了该控件说明地图已解锁
	local CSV_MapBase = g_DataMgr:getMapBaseCsv(nMapBaseCsvID)
	Image_NameBase:setPositionXY(CSV_MapBase.NameBaseX, CSV_MapBase.NameBaseY)
	
	--是否已经开启
	local Image_LockerPNL = tolua.cast(Image_NameBase:getChildByName("Image_LockerPNL"), "ImageView")
	local Label_OpenLevel = tolua.cast(Image_NameBase:getChildByName("Label_OpenLevel"), "Label")
	local Image_Name = tolua.cast(Image_NameBase:getChildByName("Image_Name"), "ImageView")
	local BitmapLabel_StarRecord = tolua.cast(Image_NameBase:getChildByName("BitmapLabel_StarRecord"), "LabelBMFont")
	local Image_X = tolua.cast(Image_NameBase:getChildByName("Image_X"), "ImageView")
	local Image_Star = tolua.cast(Image_NameBase:getChildByName("Image_Star"), "ImageView")
	
	Image_Name:loadTexture(getMapImg(CSV_MapBase.CharImage))
	
	if CSV_MapBase.MapLevel > g_Hero:getMasterCardLevel() then --玩家等级未达到
		Image_LockerPNL:setVisible(true)
		Label_OpenLevel:setVisible(true)
		Label_OpenLevel:setText(CSV_MapBase.MapLevel.._T("级"))
		
		Image_Name:setPositionX(-Image_Name:getSize().width/2+10)
		
		BitmapLabel_StarRecord:setVisible(false)
		Image_X:setVisible(false)
		Image_Star:setVisible(false)
		g_SetBlendFuncWidget(Image_LockerPNL, 1)
		
		local nWidth1 = Image_Name:getSize().width
		local nWidth2 = Label_OpenLevel:getSize().width
		Image_Name:setPositionX(-(nWidth1+nWidth2)/2+5)
		g_AdjustWidgetsPosition({Image_Name, Label_OpenLevel}, 5)
	else
		Image_LockerPNL:setVisible(false)
		Label_OpenLevel:setVisible(false)
		
		local nStarRecord = g_MapInfo:getMapIdStarNum(nMapBaseCsvID)
		if nStarRecord <= 0 then
			Image_Name:setPositionX(-Image_Name:getSize().width/2+10)
			BitmapLabel_StarRecord:setVisible(false)
			Image_X:setVisible(false)
			Image_Star:setVisible(false)
		else
			BitmapLabel_StarRecord:setText(nStarRecord)
			BitmapLabel_StarRecord:setVisible(true)
			Image_X:setVisible(true)
			Image_Star:setVisible(true)
			
			local nWidth1 = Image_Name:getSize().width
			local nWidth2 = Image_Star:getSize().width
			local nWidth3 = Image_X:getSize().width
			local nWidth4 = BitmapLabel_StarRecord:getSize().width
			Image_Name:setPositionX(-(nWidth1+nWidth2+nWidth3+nWidth4)/2+35)
			g_AdjustWidgetsPosition({Image_Name, Image_Star})
			g_AdjustWidgetsPosition({Image_Star, Image_X})
			g_AdjustWidgetsPosition({Image_X, BitmapLabel_StarRecord})
		end
		
		self.Image_World:removeAllNodes()
		if nMapBaseCsvID == self.nMaxOpenMapCsvID then
			local armature, userAnimation = g_CreateCoCosAnimation("ExclamationMark", nil, 6)
			armature:setScale(1.25)
			armature:setPositionXY(CSV_MapBase.NameBaseX, CSV_MapBase.NameBaseY)
			self.Image_World:addNode(armature, 5)
			userAnimation:playWithIndex(0)
		end
	end
end
	
-- 某个地图居中
function Game_Ectype:scrollMaxOpenMapToCenter(nMaxOpenMapCsvID)
	local objInnerContainer = self.ScrollView_World:getInnerContainer()
	local CSV_MapBase = g_DataMgr:getMapBaseCsv(nMaxOpenMapCsvID)
	local nPosX = CSV_MapBase.Pos_X
	if nPosX > 640 then
		nPosX = 640 - nPosX
		local tbSize = objInnerContainer:getSize()
		if nPosX < 1280 - tbSize.width then
			nPosX = 1280 - tbSize.width
		end
		objInnerContainer:setPositionXY(nPosX, 0)
	else
		objInnerContainer:setPositionXY(0, 0)
	end
end

function Game_Ectype:createButton_Map(nMapBaseCsvID)
	local strButton_Map = "Button_Map"..nMapBaseCsvID
	local Button_Map_Clone = tolua.cast(self.Image_World:getChildByName(strButton_Map), "Button")
	
	if(not Button_Map_Clone)then
		local Button_Map = tolua.cast(self.Image_World:getChildByName("Button_Map1"), "Button")
		Button_Map_Clone = tolua.cast(Button_Map:clone(), "Button")
		Button_Map_Clone:setName(strButton_Map)
		self.Image_World:addChild(Button_Map_Clone)
	end
	self:initButton_Map(Button_Map_Clone, nMapBaseCsvID)
end

function Game_Ectype:createImage_NameBase(nMapBaseCsvID)
	local strMap_NameBase = "Image_NameBase"..nMapBaseCsvID
	local Image_NameBase_Clone = tolua.cast(self.Image_World:getChildByName(strMap_NameBase), "ImageView")
	if(not Image_NameBase_Clone)then
		local Image_NameBase = tolua.cast(self.Image_World:getChildByName("Image_NameBase1"), "ImageView")
		Image_NameBase_Clone = tolua.cast(Image_NameBase:clone(), "Button")
		Image_NameBase_Clone:setName(strMap_NameBase)
		self.Image_World:addChild(Image_NameBase_Clone)
	end
	self:initMapNameBase(Image_NameBase_Clone, nMapBaseCsvID)
end

function Game_Ectype:initMapContent()
	local Button_Map = tolua.cast(self.Image_World:getChildByName("Button_Map1"), "Button")
	self:initButton_Map(Button_Map, 1)
	
	local Image_NameBase = tolua.cast(self.Image_World:getChildByName("Image_NameBase1"), "ImageView")
	self:initMapNameBase(Image_NameBase, 1)
	
	self.nMaxOpenMapCsvID = self:getMaxOpenMapCsvID()
	
	-- nMapBaseCsvID不可能是非法
	for nMapBaseCsvID = 2, self.nMaxOpenMapCsvID do
		self:createButton_Map(nMapBaseCsvID)
		self:createImage_NameBase(nMapBaseCsvID)
	end
	
	if not self.bScrollLock then --第一次打开界面的时候才需要定位
		self.bScrollLock = true
		self:scrollMaxOpenMapToCenter(self.nMaxOpenMapCsvID)
	end
end

local function requestJingYingInfo()
	g_EctypeJY:requestJYInfo()
end

--初始化主界面的伙伴详细介绍界面
function Game_Ectype:initWnd()
	
	--地图窗口
	local Panel_World = self.rootWidget:getChildByName("Panel_World")
	Panel_World:setVisible(true)
	Panel_World:setTouchEnabled(true)
	
	self.ScrollView_World = tolua.cast(Panel_World:getChildByName("ScrollView_World"),"ScrollView")
	self.ScrollView_World:setTouchEnabled(true)
	self.ScrollView_World:setSize(VisibleRect:getVisibleRect().size)
	
	self.Image_World = self.ScrollView_World:getChildByName("Image_World")
	self.Image_World1 = tolua.cast(self.Image_World:getChildByName("Image_World1"),"ImageView")
	self.Image_World2 = tolua.cast(self.Image_World:getChildByName("Image_World2"),"ImageView")
	self.Image_World3 = tolua.cast(self.Image_World:getChildByName("Image_World3"),"ImageView")
	self.Image_World4 = tolua.cast(self.Image_World:getChildByName("Image_World4"),"ImageView")
	self.Image_World5 = tolua.cast(self.Image_World:getChildByName("Image_World5"),"ImageView")

	local Image_JingYingFuBen = tolua.cast(self.rootWidget:getChildByName("Image_JingYingFuBen"), "ImageView")
	local Button_JingYingFuBen = tolua.cast(Image_JingYingFuBen:getChildByName("Button_JingYingFuBen"),"Button")
    g_SetBtnOpenCheckWithPressImage(Button_JingYingFuBen, 1, requestJingYingInfo, true)
end

--关闭窗口
function Game_Ectype:closeWnd()
	g_unloadEffect()
	--副本界面已经释放了，没必要重新调
	--g_RemoveAllBattlePlistResource()
    --为了释放jpg内存
	self.Image_World1:loadTexture(getUIImg("Blank"))
	self.Image_World2:loadTexture(getUIImg("Blank"))
	self.Image_World3:loadTexture(getUIImg("Blank"))
	self.Image_World4:loadTexture(getUIImg("Blank"))
	self.Image_World5:loadTexture(getUIImg("Blank"))
end

--显示主界面的伙伴详细介绍界面
function Game_Ectype:openWnd()

    self.Image_World1:loadTexture(getBackgroundJpgImg("World1"))
	self.Image_World2:loadTexture(getBackgroundJpgImg("World2"))
	self.Image_World3:loadTexture(getBackgroundJpgImg("World3"))
	self.Image_World4:loadTexture(getBackgroundJpgImg("World4"))
	self.Image_World5:loadTexture(getBackgroundJpgImg("World5"))
	
	self:initMapContent()
end



