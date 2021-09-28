--------------------------------------------------------------------------------------
-- 文件名:	HJW_GameItemDropGuide.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  物品使用与合成
---------------------------------------------------------------------------------------

Game_ItemDropGuide = class("Game_ItemDropGuide")
Game_ItemDropGuide.__index = Game_ItemDropGuide
-- 2 表示合成界面 nType == 3 表示掉落界面
ComposeTypeDefine = {
	MATERIAL_TYPE = 2, --表示合成界面
	DEBRIS_TYPE = 3, --表示掉落界面
}
 -- macro_pb.ITEM_TYPE_CARD_GOD --魂魄 5
 -- macro_pb.ITEM_TYPE_MATERIAL --道具 6 
 -- macro_pb.ITEM_TYPE_SOUL	--元神 7
 
 
local nType_ = nil
local nItemId_ = nil
local nItemStar_ = nil
local detailType_ = nil --  7 元神
local itemName_ = nil

function Game_ItemDropGuide:initWnd()
	--请求一次精英副本的数据
	if g_EctypeJY:isInit() then 
		g_EctypeJY:requestJYInfo()
	end
	
end

function Game_ItemDropGuide:openWnd(param)
	
	if self.ectypeList_ then 	
		if not nItemId_ and param then 
			nItemId_ = param.itemId
			nItemStar_ = param.itemStar
		end
		
		local itemType = ITEM_DROP_TYPE.MATERIAL
		if nItemId_ >= 2011 and nItemId_ <= 2059 then 
			itemType = ITEM_DROP_TYPE.PILL
			g_ItemDropGuildFunc:setDanYaoStar(nItemStar_)
		end
		
		self:ectypeListShow(self.ectypeList_, itemType)
	end
	
	if param == nil then return end

	if self.iconModeItem_ then 
		for i = 1,#self.iconModeItem_ do 
			self.iconModeItem_[i]:removeFromParent()
		end
	end
	self.iconModeItem_ = {}

	--掉落副本信息
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ItemDropGuide_Drop,handler(self,self.showItemDrop))


	if param then
		nType_ = param.nType --表示在那个界面打开
		nItemId_ = param.itemId
		nItemStar_ = param.itemStar
		detailType_ = param.detailType or macro_pb.ITEM_TYPE_MATERIAL -- 5 魂魄， 7 元神
		itemName_ = param.name
	end
	
	echoj("----------------------------------ddddddd",nType_)
	
	local id,starLevel = 0,0 
	--判断物品是否在表里有配置
	local itemBase = nil
	if detailType_ == macro_pb.ITEM_TYPE_CARD_GOD then  --魂魄
		itemBase = g_DataMgr:getCsvConfigByOneKey("ItemDropGuideHunPo",nItemId_)
		if itemBase then
			id = itemBase.TargetID
		end
		local hunPo = g_DataMgr:getCsvConfigByOneKey("CardHunPo",nItemId_)
		starLevel = hunPo.CardStarLevel
		itemName_ = hunPo.Name
	elseif detailType_ == macro_pb.ITEM_TYPE_SOUL then --元神
		itemBase = g_DataMgr:getCsvConfigByTwoKey("ItemDropGuideSoul",nItemId_,nItemStar_)
		id = itemBase.TargetID
		starLevel = itemBase.TargetStarLevel
	else
		itemBase = g_DataMgr:getCsvConfigByTwoKey("ItemBase",nItemId_,nItemStar_)
		id = itemBase.ID
		starLevel = itemBase.StarLevel
		local itemCompose = g_DataMgr:getCsvConfigByTwoKey("ItemCompose",id,starLevel)
		self.tbItemCompose_ = itemCompose
	end
	
	if id == 0 and starLevel == 0 then  
		id,starLevel = nItemId_,nItemStar_ 
	end
	self.tbItemBase_  = itemBase
	
	local icon = self:materiaIcon(1,id,starLevel,"")
	self:tipIndicate(1,icon)
	
	if nType_ == ComposeTypeDefine.MATERIAL_TYPE then 
		self:debrisCompound()
	elseif nType_ == ComposeTypeDefine.DEBRIS_TYPE then 
		self.paramOutCompound = {
			materialId = nItemId_,materialStarLevel = nItemStar_,name = itemName_
		}
		g_MsgMgr:requestMaterialEctypeRequest(nItemId_,nItemStar_,detailType_)
	end
 
end

function Game_ItemDropGuide:closeWnd()
	if self.LuaListView_EctypeList then
		self.LuaListView_EctypeList:updateItems(0)
		self.LuaListView_EctypeList = nil
	end
	
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ItemDropGuide_Date)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ItemDropGuide_Drop)
	g_ItemDropGuildFunc:setDanYaoStar(0)
end

function Game_ItemDropGuide:openSelectGameLevel()
	local mapId = g_ItemDropGuildFunc:getClickMapID() or 1
	local nTag = g_ItemDropGuildFunc:getClickTag() 
	local tbParam = {
		nMapCsvID = mapId ,
		nEctypeCsvID = nTag,
	}
	if mapId >= 3 then 
		g_WndMgr:showWnd("Game_SelectGameLevel3",tbParam)
	elseif mapId == 1 then 
		local strClassName = "Game_SelectGameLevel"..mapId
		g_WndMgr:showWnd(strClassName,tbParam)
	elseif mapId == 2 then 
		local strClassName = "Game_SelectGameLevel"..mapId
		g_WndMgr:showWnd(strClassName, tbParam)
	end
end

function Game_ItemDropGuide:showItemDrop(ectypeList)
	self:dropOutCompound(self.paramOutCompound)
	local list = {}
	for i = 1,#ectypeList do
		local t = {}
		t.ectypeid = ectypeList[i].ectypeid 
		t.is_open = ectypeList[i].is_open 
		t.att_num = ectypeList[i].att_num
		table.insert(list,t)
	end
	
	local itemType = ITEM_DROP_TYPE.MATERIAL
	if nItemId_ >= 2011 and nItemId_ <= 2059 then 
		itemType = ITEM_DROP_TYPE.PILL
		g_ItemDropGuildFunc:setDanYaoStar(nItemStar_)
	end
	self:ectypeListShow(list, itemType)
end

--------------------合成界面-----------------------------------------
function Game_ItemDropGuide:debrisCompound()

	if self.formula_ then
		for i= 1,#self.formula_ do
			self.formula_[i]:removeFromParentAndCleanup(true)
		end
		self.formula_ = {}
	else
		self.formula_ = {}
	end
	local tbItemBase = self.tbItemBase_ 
	if not tbItemBase then cclog("tbItemBase 空值") return  end 
	local name = tbItemBase.Name
	local desc = tbItemBase.Desc
	local id = tbItemBase.ID
	
	local rootWidget = self.rootWidget
	local ImageView_ItemDropGuidePNL = tolua.cast(rootWidget:getChildByName("ImageView_ItemDropGuidePNL"),"ImageView")
	
	local Image_ComposeNodePNL2 = tolua.cast(ImageView_ItemDropGuidePNL:getChildByName("Image_ComposeNodePNL2"),"ImageView")
	Image_ComposeNodePNL2:setVisible(false)
	
	local Image_ComposeNodePNL1 = tolua.cast(ImageView_ItemDropGuidePNL:getChildByName("Image_ComposeNodePNL1"),"ImageView")
	Image_ComposeNodePNL1:setVisible(true)
	--物品名称
	local Label_TargetName = tolua.cast(Image_ComposeNodePNL1:getChildByName("Label_TargetName"),"Label")
	Label_TargetName:setText(name)
	--材料说明
	local Image_TargetInfoPNL = tolua.cast(Image_ComposeNodePNL1:getChildByName("Image_TargetInfoPNL"),"ImageView")
	local Image_MaterialInfoPNL = tolua.cast(Image_TargetInfoPNL:getChildByName("Image_MaterialInfoPNL"),"ImageView")
	
	--材料说明
	local Label_Desc = tolua.cast(Image_MaterialInfoPNL:getChildByName("Label_Desc"),"Label")
	if desc then 
		Label_Desc:setText(g_stringSize_insert(desc,"\n",22,420))
	end
	--星级
	local Image_StarLevel = tolua.cast(Image_MaterialInfoPNL:getChildByName("Image_StarLevel"),"ImageView")
	-- Image_StarLevel:loadTexture(getUIImg("Icon_StarLevel"..tbItemBase.ColorType))
	Image_StarLevel:loadTexture(getUIImg("Icon_StarLevel"..tbItemBase.StarLevel))
	
	
	local Image_Title2 = tolua.cast(Image_ComposeNodePNL1:getChildByName("Image_Title2"),"ImageView")
	local Label_MaterialLB = tolua.cast(Image_Title2:getChildByName("Label_MaterialLB"),"Label")
	Label_MaterialLB:setText(_T("材料碎片"))

	local nNum = 0
	local itemCompose = self.tbItemCompose_
	for i = 1,3 do
		local materialId = itemCompose["MaterialID"..i] --碎片
		if materialId > 0 then 
			nNum = nNum + 1
		end
	end
	self.materialCount = nNum
	--消耗
	local Image_NeedMoney = tolua.cast(Image_ComposeNodePNL1:getChildByName("Image_NeedMoney"),"ImageView")
	--花费（文字）
	local BitmapLabel_NeedMoneyLB = tolua.cast(Image_NeedMoney:getChildByName("BitmapLabel_NeedMoneyLB"),"LabelBMFont")
	--铜钱图案
	local Image_Coins = tolua.cast(Image_NeedMoney:getChildByName("Image_Coins"),"ImageView")
	--消耗数值
	local BitmapLabel_NeedMoney = tolua.cast(Image_NeedMoney:getChildByName("BitmapLabel_NeedMoney"),"LabelBMFont")
	BitmapLabel_NeedMoney:setText(itemCompose.NeedMoney)
	g_SetLabelRed(BitmapLabel_NeedMoney,itemCompose.NeedMoney > g_Hero:getCoins())	

	g_AdjustWidgetsPosition({BitmapLabel_NeedMoneyLB, Image_Coins, BitmapLabel_NeedMoney},2)
	
	local function notItemCompose(nIndex)
		local nCount = 0
		local materialId = itemCompose["MaterialID"..nIndex] --碎片
		local materialStarLevel = itemCompose["MaterialStarLevel"..nIndex] --碎片星级
		local materialNum = itemCompose["MaterialNum"..nIndex] --碎片数量
		local nCurNum = g_Hero:getItemNumByCsv(materialId,materialStarLevel) --背包里拥有多少材料
		if nCurNum >= materialNum then  nCount = nCount + 1 end
		return nCount == nNum
	end
	
	local ccpointX = g_ComposeData:getItemDropGuilePosX(nNum)

	local function onComposeUp(pSender,eventType)
		if eventType ==ccs.TouchEventType.ended then
			if nItemId_ == 991 and nItemStar_ == 1 then 
				cclog("一级晶石 不能合成") 
				g_ClientMsgTips:showMsgConfirm(_T("一级晶石不能合成"))
				return 
			end 
			for i = 1,nNum do 
				if not notItemCompose(i) then 
					CGuidTips:showGuidTip(nil,_T("材料不足,点击前往收集材料"),CCPointMake(ccpointX[i],230),bLeftShow)
					return 
				else
					if not g_CheckMoneyConfirm(itemCompose.NeedMoney) then  return  end
					local targetID =  itemCompose.TargetID
					local targetStarLevel = itemCompose.TargetStarLevel
					g_MsgMgr:requestComPoseItemRequest(targetID,targetStarLevel)
					return 
				end
			end
		end
	end
	
	--合成按钮
	local Button_Compose = tolua.cast(Image_ComposeNodePNL1:getChildByName("Button_Compose"),"Button")
	Button_Compose:setTouchEnabled(true)
	Button_Compose:addTouchEventListener(onComposeUp)
	local Image_Check = tolua.cast(Button_Compose:getChildByName("Image_Check"), "ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteCheck, 4)
	
	local BitmapLabel_FuncName = tolua.cast(Button_Compose:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")

	local function notCompose()
		for i = 1,nNum do 
			return notItemCompose(i) 
		end
	end
	
	local param = { 
		need = itemCompose.NeedMoney,
		image = Image_Check,
		button = Button_Compose,
		flag = notCompose(),
	}
	g_AnimationAlert(param)	
	
	for i = 1,3 do
		local Button_MaterialBase = tolua.cast(Image_ComposeNodePNL1:getChildByName("Button_MaterialBase"..i),"Button")
		Button_MaterialBase:setTouchEnabled(false)
		Button_MaterialBase:setVisible(true)
	end
	-- 一级晶石 不能合成 特殊处理
	if nItemId_ == 991 and nItemStar_ == 1 then 
		for i = 1,3 do
			local Button_MaterialBase = tolua.cast(Image_ComposeNodePNL1:getChildByName("Button_MaterialBase"..i),"Button")
			Button_MaterialBase:setVisible(false)
		end
	end 
	
	local tbX,y = g_ComposeData:iconPostionXY(nNum)
	for i = 1,nNum do
		local materialId = itemCompose["MaterialID"..i] --碎片
		local materialStarLevel = itemCompose["MaterialStarLevel"..i] --碎片星级
		local materialNum = itemCompose["MaterialNum"..i] --碎片数量
		local itemBase = g_DataMgr:getCsvConfigByTwoKey("ItemBase",materialId,materialStarLevel)

		local function materiaTips(pSender,eventType)
			if eventType ==ccs.TouchEventType.ended then
				
				local icon = self:materiaIcon(2,itemBase.ID,itemBase.StarLevel,"")
				self:tipIndicate(2,icon)
				
				self.paramOutCompound = {
					materialId=materialId,materialStarLevel=materialStarLevel,name = itemBase.Name
				}
				--macro_pb.ITEM_TYPE_MATERIAL 材料
		        g_MsgMgr:requestMaterialEctypeRequest(materialId,materialStarLevel,macro_pb.ITEM_TYPE_MATERIAL)
			end
		end
		local Button_MaterialBase = tolua.cast(Image_ComposeNodePNL1:getChildByName("Button_MaterialBase"..i),"Button")
		Button_MaterialBase:setPosition(ccp(tbX[i],y)) 
		Button_MaterialBase:setTouchEnabled(true)
		Button_MaterialBase:addTouchEventListener(materiaTips)
		
		local nCurNum = g_Hero:getItemNumByCsv(materialId,materialStarLevel) --背包里拥有多少材料
		
		Button_MaterialBase:removeAllChildren()
		
		local Image_EquipWorkFrag = g_WidgetModel.Image_EquipWorkFrag:clone()
		Button_MaterialBase:addChild(Image_EquipWorkFrag)
		table.insert(self.formula_, Image_EquipWorkFrag)

		local Image_EquipWorkFrag  = tolua.cast(Image_EquipWorkFrag,"ImageView")
		Image_EquipWorkFrag:loadTexture(getUIImg("FrameBack"..itemBase.ColorType))
		
		local icon = getIconImg(itemBase.Icon)
		
		local Image_Icon = tolua.cast(Image_EquipWorkFrag:getChildByName("Image_Icon"),"ImageView")
		Image_Icon:loadTexture(icon)
		
		local Image_Frame = tolua.cast(Image_EquipWorkFrag:getChildByName("Image_Frame"),"ImageView")
		Image_Frame:loadTexture(getIconFrame(itemBase.ColorType))
		
		local Label_NeedNum = tolua.cast(Image_EquipWorkFrag:getChildByName("Label_NeedNum"),"Label")
		Label_NeedNum:setText(nCurNum)
		
		local Label_NeedNumMax = tolua.cast(Image_EquipWorkFrag:getChildByName("Label_NeedNumMax"),"Label")
		Label_NeedNumMax:setText("/"..materialNum)
		
	end
end

------------------------------碎片掉落界面---------------------------------------------
function Game_ItemDropGuide:dropOutCompound(param)
	if not param then return end
	if not self.rootWidget then return end
	
	local name = param.name
	local ImageView_ItemDropGuidePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_ItemDropGuidePNL"),"ImageView")
	
	local Image_ComposeNodePNL1 = tolua.cast(ImageView_ItemDropGuidePNL:getChildByName("Image_ComposeNodePNL1"),"ImageView")
	Image_ComposeNodePNL1:setVisible(false)
	
	local Image_ComposeNodePNL2 = tolua.cast(ImageView_ItemDropGuidePNL:getChildByName("Image_ComposeNodePNL2"),"ImageView")
	Image_ComposeNodePNL2:setVisible(true)
	--材料名称
	local Label_TargetName = tolua.cast(Image_ComposeNodePNL2:getChildByName("Label_TargetName"),"Label")
	Label_TargetName:setText(name)

	--关卡
	local Image_EctypeInfoPNL = tolua.cast(Image_ComposeNodePNL2:getChildByName("Image_EctypeInfoPNL"),"ImageView")
	
	local ListView_EctypeList = tolua.cast(Image_EctypeInfoPNL:getChildByName("ListView_EctypeList"), "ListViewEx")
    self.LuaListView_EctypeList = Class_LuaListView:new()
    self.LuaListView_EctypeList:setListView(ListView_EctypeList)
	
	local Panel_EctypeItem = tolua.cast(g_WidgetModel.Panel_EctypeItem:clone(),"Layout")
	if Panel_EctypeItem then 
		self.LuaListView_EctypeList:setModel(Panel_EctypeItem)
	end
	local imgScrollSlider = ListView_EctypeList:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_EctypeList_DropGuide_X then
		g_tbScrollSliderXY.ListView_EctypeList_DropGuide_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_EctypeList_DropGuide_X - 6)

	local detailType = detailType_
	--按钮
	local Button_Close = tolua.cast(Image_ComposeNodePNL2:getChildByName("Button_Close"),"Button")
	local function tips(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			if nType_ == ComposeTypeDefine.MATERIAL_TYPE then 
				if self.iconModeItem_ then 
					for i = 1,#self.iconModeItem_ do
						self.iconModeItem_[i]:removeFromParent()
					end
					self.iconModeItem_ = {}
				end
				local id,starLevel = 0,0 
				if detailType == 6 then 
					id = self.tbItemBase_.TargetID
				elseif detailType == 7 then 
					id = self.tbItemBase_.TargetID
					starLevel = self.tbItemBase_.TargetStarLevel
				else
					id = self.tbItemBase_.ID
					starLevel = self.tbItemBase_.StarLevel
				end
				
				local icon = self:materiaIcon(1,self.tbItemBase_.ID,self.tbItemBase_.StarLevel,"")
				self:tipIndicate(1,icon)
				Image_ComposeNodePNL1:setVisible(true)
				Image_ComposeNodePNL2:setVisible(false)
			elseif nType_ == ComposeTypeDefine.DEBRIS_TYPE then
				 g_WndMgr:closeWnd("Game_ItemDropGuide")
			end
		end
	end
	Button_Close:setTouchEnabled(true)
	Button_Close:addTouchEventListener(tips)
	
end

function Game_ItemDropGuide:materiaIcon(nIndex,id,starLevel,itemNum)
	nIndex = nIndex or 1
	local detailType =  detailType_
	local tbDrop = {}
	if detailType == macro_pb.ITEM_TYPE_CARD_GOD then 
		tbDrop.DropItemType = macro_pb.ITEM_TYPE_CARD_GOD ----魂魄
		
	elseif detailType == macro_pb.ITEM_TYPE_SOUL then 
		tbDrop.DropItemType = macro_pb.ITEM_TYPE_SOUL ----元神
		tbDrop.DropItemStarLevel = starLevel or 0
	else
		tbDrop.DropItemType = macro_pb.ITEM_TYPE_MATERIAL --道具
		tbDrop.DropItemStarLevel = starLevel or 0
	end
	tbDrop.DropItemID = id
	tbDrop.DropItemNum = itemNum or ""

	local iconMode = g_CloneDropItemModel(tbDrop)
	iconMode:setScale(0.8)
	iconMode:setPosition(ccp(0,0))
	self.iconModeItem_[nIndex] = iconMode
	return iconMode
end

function Game_ItemDropGuide:tipIndicate(nIndex,icon)
	if not self.rootWidget then return end
	
	local ImageView_ItemDropGuidePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_ItemDropGuidePNL"), "ImageView")
	local Image_ComposeTreePNL = tolua.cast(ImageView_ItemDropGuidePNL:getChildByName("Image_ComposeTreePNL"), "ImageView")

	local function click(pSender,eventType)
		if eventType ==ccs.TouchEventType.ended then
			local tag = pSender:getTag()
			local Button_TreeNode_tag = tolua.cast(Image_ComposeTreePNL:getChildByName("Button_TreeNode"..tag),"Button")
			local Image_Check = tolua.cast(Button_TreeNode_tag:getChildByName("Image_Check"), "ImageView")
			Image_Check:setVisible(true)
	
			local Image_ComposeNodePNL = tolua.cast(ImageView_ItemDropGuidePNL:getChildByName("Image_ComposeNodePNL"..tag), "ImageView")
			Image_ComposeNodePNL:setVisible(true)
			
			for i = 1,2 do
				local Button_TreeNode_i = tolua.cast(Image_ComposeTreePNL:getChildByName("Button_TreeNode"..i),"Button")
				local Image_Check = tolua.cast(Button_TreeNode_i:getChildByName("Image_Check"), "ImageView")
				if i > tag then 
					local Image_ComposeNodePNL = tolua.cast(ImageView_ItemDropGuidePNL:getChildByName("Image_ComposeNodePNL"..i), "ImageView")
					Image_ComposeNodePNL:setVisible(false)
					
					Button_TreeNode_i:setTouchEnabled(false)
					Button_TreeNode_i:setVisible(false)
					Image_Check:setVisible(false)
					if self.iconModeItem_[tag + 1] then 
						self.iconModeItem_[tag+1]:removeFromParent()
						self.iconModeItem_[tag+1] = nil
					end
				end
			end
		end
	end
	
	for i = 1,2 do
		local Button_TreeNode = tolua.cast(Image_ComposeTreePNL:getChildByName("Button_TreeNode"..i),"Button")
		Button_TreeNode:setTag(i)
		local Image_Check = tolua.cast(Button_TreeNode:getChildByName("Image_Check"), "ImageView")
		local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
		g_SetBlendFuncSprite(ccSpriteCheck, 4)
		Image_Check:setVisible(false)
	end
	
	for i = nIndex,2 do
		local Button_TreeNode = tolua.cast(Image_ComposeTreePNL:getChildByName("Button_TreeNode"..i),"Button")
		local Image_Check = tolua.cast(Button_TreeNode:getChildByName("Image_Check"), "ImageView")
		if i == nIndex then 
			Image_Check:setVisible(true)
			Button_TreeNode:setVisible(true)
			if icon then 
				Button_TreeNode:addChild(icon)
			end
			if nType_ == 3 then --3 表示掉落界面
				Button_TreeNode:setTouchEnabled(false)
			else
				Button_TreeNode:setTouchEnabled(true)
				Button_TreeNode:addTouchEventListener(click)
			end
		else
			Button_TreeNode:setTouchEnabled(false)
			Button_TreeNode:setVisible(false)
			Image_Check:setVisible(false)
		end
	end	

end


--掉落副本
function Game_ItemDropGuide:ectypeListShow(ectypeList, itemType)
	local function listSort(one,two)
		if one.is_open > two.is_open then
			return one.is_open >  two.is_open
		elseif one.ectypeid < two.ectypeid then 
			return one.ectypeid < two.ectypeid
		end
	end
	table.sort(ectypeList, listSort)
	
	local wndInstance = g_WndMgr:getWnd("Game_ItemDropGuide")
	if wndInstance and wndInstance.LuaListView_EctypeList then 
		
		local onUpdate_LuaListView_EctypeList = g_ItemDropGuildFunc:ectypeListShow(ectypeList, itemType)
		wndInstance.ectypeList_ = g_ItemDropGuildFunc:getEctypeListInfo()
		wndInstance.LuaListView_EctypeList:setUpdateFunc(onUpdate_LuaListView_EctypeList)
		
		local function onAdjust_LuaListView_EctypeList(Panel_EctypeItem, nIndex)
			wndInstance.nCurrentListViewIndex = nIndex
		end
		wndInstance.LuaListView_EctypeList:setAdjustFunc(onAdjust_LuaListView_EctypeList)
		
		local count = 0
		for key,value in ipairs(ectypeList) do
			if value.ectypeid > 0 then 
				count = count + 1
			end
		end
		wndInstance.LuaListView_EctypeList:updateItems(count + 1, wndInstance.nCurrentListViewIndex or 1)
	end
end

function Game_ItemDropGuide:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_ItemDropGuidePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_ItemDropGuidePNL"), "ImageView")
	local Image_Background = tolua.cast(ImageView_ItemDropGuidePNL:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_ItemDropGuidePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ItemDropGuide:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_ItemDropGuidePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_ItemDropGuidePNL"), "ImageView")
	local Image_Background = tolua.cast(ImageView_ItemDropGuidePNL:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(ImageView_ItemDropGuidePNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end