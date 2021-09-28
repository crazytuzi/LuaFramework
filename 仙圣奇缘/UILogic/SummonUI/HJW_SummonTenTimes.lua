--------------------------------------------------------------------------------------
-- 文件名:	Game_SummonTenTimes
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2014-04-08 4:37
-- 版  本:	1.0
-- 描  述: 十连抽
-- 应  用:
---------------------------------------------------------------------------------------

Game_SummonTenTimes = class("Game_SummonTenTimes")
Game_SummonTenTimes.__index = Game_SummonTenTimes


function Game_SummonTenTimes:initWndAni()

	local y = {360,-360,360,-360,360,360,-360,-360,360,-360,360}
	for i = 1, 10 do
		local Image_SummonSlot =  tolua.cast(self.rootWidget:getChildByName("Image_SummonSlot"..i),"ImageView")
		local actionRotateTo = CCRotateBy:create(45,y[i])
		local actionForever = CCRepeatForever:create(actionRotateTo)
		Image_SummonSlot:runAction(actionForever)
	end

end

function Game_SummonTenTimes:initWnd(layerSummonTenTimes)
	-- self.tbIconObj = {}
	self:initView()
	self:initWndAni()
	self:fullScreenClick()
	
	local Image_Cover = tolua.cast(self.rootWidget:getChildByName("Image_Cover"), "ImageView")
	Image_Cover:loadTexture(getBackgroundPngImg("Summon_Ten"))
end

function Game_SummonTenTimes:closeWnd()
	self:removeClone()
	self.tbIconObj = nil
	
	local Image_Cover = tolua.cast(self.rootWidget:getChildByName("Image_Cover"), "ImageView")
	Image_Cover:loadTexture(getUIImg("Blank"))
end

function Game_SummonTenTimes:openWnd(param)
	if not param then return end
	
	self.CSV_DropItem = {}
	local func = nil 
	if param then
		self.callType = param.callType
		self.tabNeed = (param.tabNeed)[self.callType]
		func = param.func 
	end
    
    self:initSummonNeed()
    if func then 
		self.layout_:setTouchEnabled(false)
		func() 
	end 
end

--初始化当前召唤需要的道具
function Game_SummonTenTimes:initSummonNeed()
    local rootWidget = self.rootWidget
    local nTokenNum = 0
    local strTokenName = "无"
    local strTokenIcon = "无"
    local objItemToken = g_Hero:getItemByCsv(self.tabNeed.need_TokenID, self.tabNeed.need_TokenLevel)  --玩家代币
    if objItemToken ~= "无此道具" then
        nTokenNum = objItemToken:getNum()     --代币数量
        strTokenName = objItemToken:getName() --代币昵称
        strTokenIcon = "Icon_SummonToken1" --代币Icon
    end
	--普通召唤
	local Image_PriceCoins = tolua.cast(rootWidget:getChildByName("Image_PriceCoins"),"ImageView")
	Image_PriceCoins:setVisible(true)
	local Image_Price = tolua.cast(Image_PriceCoins:getChildByName("Image_Price"),"ImageView")
	local Label_Price = tolua.cast(Image_Price:getChildByName("Label_Price"),"Label")
    local Image_Icon = tolua.cast(Image_Price:getChildByName("Image_Icon"),"ImageView")
	Label_Price:setVisible(true)
	--高级召唤
	local Image_PriceCoupons = tolua.cast(rootWidget:getChildByName("Image_PriceCoupons"),"ImageView")
	Image_PriceCoupons:setVisible(false)
	local Image_Price = tolua.cast(Image_PriceCoupons:getChildByName("Image_Price"),"ImageView")
	local Label_Price2 = tolua.cast(Image_Price:getChildByName("Label_Price"),"Label")
    local Image_Icon2 = tolua.cast(Image_Price:getChildByName("Image_Icon"),"ImageView")
	Label_Price2:setVisible(false)
    
    if self.callType == 2 then --高级召唤
        Image_PriceCoins:setVisible(false)
		Image_PriceCoupons:setVisible(true)
		Label_Price:setVisible(false)
		Label_Price2:setVisible(true)
        Label_Price = Label_Price2
        Image_Icon = Image_Icon2
        strTokenIcon = "Icon_SummonToken2" --代币Icon
    end
    --代币足够则使用代币
    if nTokenNum >= self.tabNeed.need_TokenNumTen then
        Image_Icon:loadTexture(getUIImg(strTokenIcon))
        Label_Price:setText(self.tabNeed.need_TokenNumTen)
		g_SetLabelRed(Label_Price,self.tabNeed.need_TokenNumTen > nTokenNum)    
    else
        Image_Icon:loadTexture(getUIImg("Icon_PlayerInfo_YuanBao"))
        Label_Price:setText(self.tabNeed.need_tenExtractCost)
        g_SetLabelRed(Label_Price2,self.tabNeed.need_tenExtractCost > g_Hero:getYuanBao())
    end
end

--初始的时候先隐藏了所以物品Icon
function Game_SummonTenTimes:initView()
	local function getImageName(key)
		return self.rootWidget:getChildByName("Image_SummonPos"..key),"ImageView"
	end
	for i = 1,10 do
		local Image_SummonPos = tolua.cast(getImageName(i))
		Image_SummonPos:setVisible(false)
	end
end

--创建一个全屏点击事件
function Game_SummonTenTimes:fullScreenClick()
	local Panel_TouchLayer = tolua.cast(self.rootWidget:getChildByName("Panel_TouchLayer"), "Layout")
	if not Panel_TouchLayer then
		Panel_TouchLayer =  Layout:create()
		Panel_TouchLayer:setName("Panel_TouchLayer")
		Panel_TouchLayer:setSize(CCSize(1280,720))
		self.rootWidget:addChild(Panel_TouchLayer, 14)
	end
	
	local function pickupCreate(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
            local nTokenNum = 0
            local strTokenName = "无"
            local objItemToken = g_Hero:getItemByCsv(self.tabNeed.need_TokenID, self.tabNeed.need_TokenLevel)  --玩家代币
            if objItemToken ~= "无此道具" then
                nTokenNum = objItemToken:getNum()     --代币数量
                strTokenName = objItemToken:getName() --代币昵称
            end
            local flag
            local msg
            if nTokenNum >= self.tabNeed.need_TokenNumTen then
                local strSummon = "是否消耗%d个%s进行普通十连召唤？"
                if typeIndex == SUMMON_COUNT then
                    strSummon = "是否消耗%d个%s进行高级十连召唤？"
                end
                msg = string.format(_T(strSummon), self.tabNeed.need_TokenNumTen, strTokenName)
            else
                local function substitutionTips(costNum)
				    local txt = string.format(_T("召唤需要花费%d元宝, 您的元宝不足是否前往充值"), costNum)
				    if not g_CheckYuanBaoConfirm(costNum, txt) then
					    return false
				    end
				    return true
			    end 
                flag = substitutionTips(self.tabNeed.need_tenExtractCost,self.callType)
			    if not flag then return end
			    msg = string.format(_T("是否花费%d元宝召唤？"),self.tabNeed.need_tenExtractCost)
            end

			g_ClientMsgTips:showConfirm(msg, function()
				if not self.callType and self.callType <= 0 then 
					cclog("召唤类型为0 或者是空")
					return 
				end
				self:setImageCoverEnaled(false)
				self.layout_:setTouchEnabled(false)
				g_MsgMgr:requestSummonCard(self.callType, false,true)
				self.CSV_DropItem = {}
			end)
		end
	end
	Panel_TouchLayer:setTouchEnabled(true)
	Panel_TouchLayer:addTouchEventListener(pickupCreate)
	
	self.layout_ = Panel_TouchLayer
end

function Game_SummonTenTimes:setImageCoverEnaled(flag)
	for i = 1,10 do
		local Image_CoverGlass =  tolua.cast(self.rootWidget:getChildByName("Image_CoverGlass"..i),"ImageView")
		Image_CoverGlass:setTouchEnabled(flag)
	end
end

local tbDropSourceType = {
	[macro_pb.DS_SUMMONCARD_COPPER] = 1,--铜钱召唤伙伴
	[macro_pb.DS_SUMMONCARD_COUPONS] = 2,--元宝召唤伙伴
}

function Game_SummonTenTimes:addInfoMsgProcess(list)
    
	local Button_Return = tolua.cast(self.rootWidget:getChildByName("Button_Return"), "Button")
	Button_Return:setTouchEnabled(false)
	self:removeClone()
    local Image_SummonSlot =  tolua.cast(self.rootWidget:getChildByName("Image_SummonSlot1"),"ImageView")
	self.param = {
		list = list,
		nCount = 1,
		-- cfgId = tbDropData.cfgId
		smoothlyFunc = function(count) 
			local tbDropData = list[count]
			local nDropItemType = tbDropData.types--类型
			local nDropItemID = tbDropData.itemId --物品id
			local nDropItemCfgID = tbDropData.confingId --配置id
			local nDropItemStarLevel = tbDropData.starLevel --星级
			local itemLevel =	tbDropData.itemLevel --物品等级
			local ItemEvoluteLevel =	tbDropData.ItemEvoluteLevel --物品等级
			local nItemNum =	tbDropData.nItemNum --物品等级
			local function addView()
				local imageClone = self:itemInfoType(nDropItemCfgID,nDropItemStarLevel,nDropItemType,count,nDropItemID,nItemNum)
				local Image_SummonPos = tolua.cast(self.rootWidget:getChildByName("Image_SummonPos"..count), "ImageView")
				Image_SummonPos:removeAllChildren()
				Image_SummonPos:addChild(imageClone)
				Image_SummonPos:setVisible(true)
				if self.tbIconObj ~=nil then 
					table.insert(self.tbIconObj,imageClone)
				end
			end
			if count <= 10 then 
				local Image_AnimationPos = tolua.cast(self.rootWidget:getChildByName("Image_AnimationPos"..count), "ImageView")
				g_AnimationHaloAction(Image_AnimationPos, 1.5,addView)	
			end
		    if count == 10 then 
				Button_Return:setTouchEnabled(true)
				Button_Return:setZOrder(INT_MAX)
				self.layout_:setTouchEnabled(true) 
			end 
		end,
		pauseFunc = function(count) 
			local tbDropData = list[count]
			local nDropItemType = tbDropData.types--类型
			local nDropItemID = tbDropData.itemId --物品id
			local nDropItemCfgID = tbDropData.confingId --配置id
			local nDropItemStarLevel = tbDropData.starLevel --星级
			local itemLevel =	tbDropData.itemLevel --物品等级
			local ItemEvoluteLevel =	tbDropData.ItemEvoluteLevel --物品等级
			local nItemNum =	tbDropData.nItemNum 
			local cfgId = tbDropData.cfgId
			local strDropItemIcon,CSV_Data = getIconByType(nDropItemCfgID, nDropItemStarLevel, nDropItemType)
			local param = {
				nDropSourceType = tbDropSourceType[macro_pb.DS_SUMMONCARD_COUPONS],
				CSV_Data = CSV_Data,
				strItemIcon = strDropItemIcon,
				nItemID = nDropItemID,
				nItemType = nDropItemType,
				nItemEvoluteLevel = ItemEvoluteLevel,
				cfgId = cfgId,
				nItemNum = nItemNum,
				funcDisappearedCallBack = nil,
				funcEndCallBack = function() 
					local function addView()
						local imageClone = self:itemInfoType(nDropItemCfgID,nDropItemStarLevel,nDropItemType,count,nDropItemID,nItemNum)
						local Image_SummonPos = tolua.cast(self.rootWidget:getChildByName("Image_SummonPos"..count), "ImageView")
						Image_SummonPos:removeAllChildren()
						Image_SummonPos:addChild(imageClone)
						Image_SummonPos:setVisible(true)
						if self.tbIconObj ~= nil then 
							table.insert(self.tbIconObj,imageClone)
						end
						if count >= 10 then 
							self.layout_:setTouchEnabled(true)
							Button_Return:setTouchEnabled(true)
							Button_Return:setZOrder(INT_MAX)
							self:setImageCoverEnaled(true)
							return 
						end 
						self.param.nCount = count + 1
						self:summonTenAction(self.param)
					end
					local Image_AnimationPos = tolua.cast(self.rootWidget:getChildByName("Image_AnimationPos"..count), "ImageView")
					g_AnimationHaloAction(Image_AnimationPos, 1.5,addView)			
				end,
			}
			g_ShowSummonCardAnimation(param)
		end
	}
	
	self:summonTenAction(self.param)
	
    --更新当前需要的道具
    self:initSummonNeed()
end

function Game_SummonTenTimes:summonTenAction(param)
	local list = param.list
	local nTime  = 0
	local smoothlyFunc = param.smoothlyFunc 
	local pauseFunc = param.pauseFunc --暂停函数 点击后执行下一步 
    local nCount = param.nCount or 1
	local tbListInfo = list[nCount]
	local types = tbListInfo.types
    local function  sequence()
	    self:summonTenAction({
			smoothlyFunc = smoothlyFunc,
			pauseFunc = pauseFunc,
			nCount=	nCount,
			list = list
		})
    end

	if types == macro_pb.ITEM_TYPE_CARD or tbListInfo and tbListInfo.cfgId > 0  then --要暂停
		local delayTime = CCDelayTime:create(0.5)
		if nCount == 1 then 
			delayTime = CCDelayTime:create(0)
		end
		local action = sequenceAction({delayTime,CCCallFuncN:create(function() 
			if pauseFunc then  pauseFunc(nCount) end
		end)})
		self.rootWidget:runAction(action)	
	
	else
		nTime = nTime + 0.1
		local delayTime = CCDelayTime:create(nTime)
		local action = sequenceAction({delayTime,CCCallFuncN:create(function() 
			if smoothlyFunc then smoothlyFunc(nCount) end 
			nCount = nCount + 1
			if nCount > 10 then return end 
			sequence()
		end)})
		self.rootWidget:runAction(action)	
	end
	
end

function Game_SummonTenTimes:removeClone()
	if self.tbIconObj then
		for key,value in pairs(self.tbIconObj) do
			value:removeFromParentAndCleanup(true)
		end
		self.tbIconObj = {}
	else
		self.tbIconObj = {}
	end
end

function Game_SummonTenTimes:itemInfoType(confingId,starLevel,types,key,itemId,iItemNum)
	local icon, CSV_Data = getIconByType(confingId,starLevel,types)
	if not CSV_Data then return end
	local imageName = nil
	local itemModel = nil
	local nColorType = 1
	local name = CSV_Data.Name
	local Image_SummonSlot =  tolua.cast(self.rootWidget:getChildByName("Image_SummonSlot"..key),"ImageView")
	if types == macro_pb.ITEM_TYPE_CARD then 			--伙伴
		imageName = "Image_TenSummonCard"
		itemModel = g_WidgetModel[imageName]:clone()
		local Panel_Stencil = tolua.cast(itemModel:getChildByName("Panel_Stencil"), "Layout")
		local Panel_Card = tolua.cast(Panel_Stencil:getChildByName("Panel_Card"), "Layout")
		local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"),"ImageView")
		Image_Card:setVisible(true)

		local CCNode_Skeleton = g_CocosSpineAnimation(CSV_Data.SpineAnimation,1)
		Image_Card:loadTexture(getUIImg("Blank"))
		Image_Card:removeAllNodes()
		Image_Card:setPositionXY(CSV_Data.PotraitX, CSV_Data.PotraitY)
		Image_Card:addNode(CCNode_Skeleton)
		g_runSpineAnimation(CCNode_Skeleton, "idle", true)

		Panel_Card:setScale(CSV_Data.PotraitScale*1.48/100)
		
		nColorType = CSV_Data.StarLevel
		
		
	elseif types == macro_pb.ITEM_TYPE_EQUIP then 		--装备
		imageName = "Image_TenSummonEquip"
		itemModel = g_WidgetModel[imageName]:clone()

		local Image_EquipIcon = tolua.cast(itemModel:getChildByName("Image_EquipIcon"),"ImageView")
		Image_EquipIcon:loadTexture(icon)

		equipSacleAndRotate(Image_EquipIcon, CSV_Data.SubType)

		nColorType = CSV_Data.ColorType

	elseif types == macro_pb.ITEM_TYPE_FATE then 		--异兽
		imageName = "Image_TenSummonFate"
		itemModel = g_WidgetModel[imageName]:clone()

		local Image_FateIcon = tolua.cast(itemModel:getChildByName("Image_FateIcon"),"ImageView")
		Image_FateIcon:setPosition(ccp(0+CSV_Data.OffsetX, 5+CSV_Data.OffsetY))
		Image_FateIcon:loadTexture(icon)

		nColorType = CSV_Data.ColorType

	elseif types == macro_pb.ITEM_TYPE_CARD_GOD then 	--元神(魂魄)
		imageName = "Image_TenSummonHunPo"
		itemModel = g_WidgetModel[imageName]:clone()
		local starLevel = CSV_Data.CardStarLevel
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_Data.ID, CSV_Data.CardStarLevel)
		local Image_HunPo = tolua.cast(itemModel:getChildByName("Image_HunPo"),"ImageView")
		Image_HunPo:loadTexture(getUIImg("SummonHunPoBase"..starLevel))

		local Image_Cover = tolua.cast(Image_HunPo:getChildByName("Image_Cover"),"ImageView")
		Image_Cover:loadTexture(getUIImg("SummonHunPoCover"..starLevel))
		local spriteCover = SpriteCoverlipping(icon,getUIImg("SummonHunPoBase"..starLevel))
		if spriteCover ~= nil then
			Image_HunPo:removeAllNodes()
			Image_HunPo:addNode(spriteCover,1)
		end
		
		name = CSV_CardBase.Name
		nColorType = starLevel

	elseif types == macro_pb.ITEM_TYPE_MATERIAL then 	--ItemBase(道具)
		local itemTypes = CSV_Data.Type
		-- nColorType = CSV_Data.ColorType
		nColorType = CSV_Data.StarLevel

		if itemTypes == 0 then		--打造材料
			imageName = "Image_TenSummonMaterial"
			itemModel = g_WidgetModel[imageName]:clone()
			local Image_MaterialIcon = tolua.cast(itemModel:getChildByName("Image_MaterialIcon"),"ImageView")
			Image_MaterialIcon:loadTexture(icon)

		elseif itemTypes == 1 then	--技能碎片
			imageName = "Image_TenSummonSkillFrag"
			itemModel = g_WidgetModel[imageName]:clone()
			local Image_SkillFragIcon = tolua.cast(itemModel:getChildByName("Image_SkillFragIcon"),"ImageView")
			Image_SkillFragIcon:loadTexture(icon)

		elseif itemTypes == 2 then	--可使用道具
			imageName = "Image_TenSummonUseItem"
			itemModel = g_WidgetModel[imageName]:clone()

			local Image_UseItemIcon = tolua.cast(itemModel:getChildByName("Image_UseItemIcon"),"ImageView")
			Image_UseItemIcon:loadTexture(icon)
			
			local Image_IconTag = tolua.cast(itemModel:getChildByName("Image_IconTag"), "ImageView")
			if CSV_Data.SubType == NUM_ItemBaseSubType.EquipMaterialPack or CSV_Data.SubType == NUM_ItemBaseSubType.EquipFormulaPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_Data.StarLevel))
			elseif CSV_Data.SubType == NUM_ItemBaseSubType.SoulMaterialPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_SoulTag_"..CSV_Data.ColorType.."_"..CSV_Data.FormulaType))
			elseif CSV_Data.SubType == NUM_ItemBaseSubType.RandomPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_PackRandTag"..CSV_Data.ColorType))
			elseif CSV_Data.SubType == NUM_ItemBaseSubType.SelectedPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_PackSelectTag"..CSV_Data.ColorType))
			else
				Image_IconTag:setVisible(false)
			end

		elseif itemTypes == 3 then	--装备卷轴
			imageName = "Image_TenSummonFormula"
			itemModel = g_WidgetModel[imageName]:clone()

			local Image_EquipIcon = tolua.cast(itemModel:getChildByName("Image_EquipIcon"),"ImageView")
			Image_EquipIcon:loadTexture(icon)

			local Image_Base = tolua.cast(itemModel:getChildByName("Image_Base"),"ImageView")
			Image_Base:loadTexture(getUIImg("SummonBook"..CSV_Data.ColorType))

			equipSacleAndRotate(Image_EquipIcon,CSV_Data.FormulaType)
		elseif itemTypes == 4 then	--装备材料包
			imageName = "Image_TenSummonEquipPack"
			itemModel = g_WidgetModel[imageName]:clone()

			local Image_EquipIcon = tolua.cast(itemModel:getChildByName("Image_EquipIcon"),"ImageView")
			Image_EquipIcon:loadTexture(icon)

			local Image_Base = tolua.cast(itemModel:getChildByName("Image_Base"),"ImageView")
			Image_Base:loadTexture(getIconImg("ResourceItem_MaterialPack"..CSV_Data.ColorType))

			equipSacleAndRotate(Image_EquipIcon,CSV_Data.FormulaType)
		elseif itemTypes == 6 then	--增加经验道具

            imageName = "Image_TenSummonUseItem"
			itemModel = g_WidgetModel[imageName]:clone()

			local Image_UseItemIcon = tolua.cast(itemModel:getChildByName("Image_UseItemIcon"),"ImageView")
			Image_UseItemIcon:loadTexture(icon)
			
			local Image_IconTag = tolua.cast(itemModel:getChildByName("Image_IconTag"), "ImageView")
			if CSV_Data.SubType == NUM_ItemBaseSubType.EquipMaterialPack or CSV_Data.SubType == NUM_ItemBaseSubType.EquipFormulaPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_Data.StarLevel))
			elseif CSV_Data.SubType == NUM_ItemBaseSubType.SoulMaterialPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_SoulTag_"..CSV_Data.ColorType.."_"..CSV_Data.FormulaType))
			elseif CSV_Data.SubType == NUM_ItemBaseSubType.RandomPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_PackRandTag"..CSV_Data.ColorType))
			elseif CSV_Data.SubType == NUM_ItemBaseSubType.SelectedPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_PackSelectTag"..CSV_Data.ColorType))
			else
				Image_IconTag:setVisible(false)
			end
		end
	elseif types == macro_pb.ITEM_TYPE_SOUL then 		--元神
		imageName = "Image_TenSummonSoul"
		itemModel = g_WidgetModel[imageName]:clone()
		local icon = CSV_Data.SpineAnimation
		local starLevel = CSV_Data.StarLevel
		local Image_Soul = tolua.cast(itemModel:getChildByName("Image_Soul"),"ImageView")
		Image_Soul:loadTexture(getUIImg("SummonSoulBase"..starLevel))
		local spriteCover = SpriteCoverlipping(getIconImg(icon),getUIImg("SummonSoulBase"..starLevel))
		if spriteCover ~= nil then
			Image_Soul:removeAllNodes()
			Image_Soul:addNode(spriteCover,1)
		end

		local Image_Cover = tolua.cast(Image_Soul:getChildByName("Image_Cover"),"ImageView")
		Image_Cover:loadTexture(getUIImg("SummonSoulCover"..starLevel))
		
		local Image_SoulType = tolua.cast(itemModel:getChildByName("Image_SoulType"), "ImageView")
		if CSV_CardSoul.Class < 5 then
			Image_SoulType:loadTexture(getUIImg("Image_SoulTag_"..CSV_CardSoul.StarLevel.."_"..CSV_CardSoul.FatherLevel))
		else
			Image_SoulType:loadTexture(getEctypeIconResource("FrameEctypeNormalChar", CSV_CardSoul.StarLevel))
		end

		nColorType = starLevel
	end

	Image_SummonSlot:loadTexture(getUIImg("FateBaseA"..nColorType))
	
	
	local function onTouchItemTips(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
		
			self.CSV_DropItem.DropItemType = types
			self.CSV_DropItem.DropItemID = CSV_Data.ID
			self.CSV_DropItem.DropItemStarLevel = nColorType
			self.CSV_DropItem.DropItemNum = iItemNum
			self.CSV_DropItem.DropItemEvoluteLevel =0
			
			if next(self.CSV_DropItem) == nil then return end 
			g_ShowDropItemTip(self.CSV_DropItem)
		end
	end
	local Image_CoverGlass =  tolua.cast(self.rootWidget:getChildByName("Image_CoverGlass"..key),"ImageView")
	Image_CoverGlass:loadTexture(getUIImg("FateFrame"..nColorType))
	Image_CoverGlass:setTouchEnabled(false)
	-- Image_CoverGlass:setZOrder(15)
	Image_CoverGlass:addTouchEventListener(onTouchItemTips)
	if key == 10 then 
		self:setImageCoverEnaled(true)
	end
	--物品名称
	local Image_Name = tolua.cast(itemModel:getChildByName("Image_Name"),"ImageView")
	local Label_Name = tolua.cast(Image_Name:getChildByName("Label_Name"), "Label")

	if CSV_Data.Level and types == macro_pb.ITEM_TYPE_SOUL  then 		--元神
		Label_Name:setText(name.._T("Lv.")..CSV_Data.Level.." ".."×"..iItemNum)
	else
		Label_Name:setText(name.."×"..iItemNum)
	end
	
	Label_Name:setScale(0.9)
	g_SetWidgetColorBySLev(Label_Name, nColorType)

	return itemModel
end






