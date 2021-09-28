
--------------------------------------------------------------------------------------
-- 文件名:	HJW_GameSaoDang.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  
---------------------------------------------------------------------------------------

Game_SaoDang = class("Game_SaoDang")
Game_SaoDang.__index = Game_SaoDang

function Game_SaoDang:initWnd()
	local Image_SaoDangPNL = tolua.cast(self.rootWidget:getChildByName("Image_SaoDangPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_SaoDangPNL:getChildByName("Image_ContentPNL"),"ImageView")
	self.Image_SaoDangItemPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_SaoDangItemPNL"),"ImageView")
	self.Image_SaoDangItemPNL:setVisible(false)

	local Image_ShuZhiPNL = tolua.cast(self.Image_SaoDangItemPNL:getChildByName("Image_ShuZhiPNL"),"ImageView")
	--获得铜钱 文字
	local Label_TongQianLB = tolua.cast(Image_ShuZhiPNL:getChildByName("Label_TongQianLB"),"Label")
	Label_TongQianLB:setScale(0)
	--获得经验 文字
	local Label_JingYanLB = tolua.cast(Image_ShuZhiPNL:getChildByName("Label_JingYanLB"),"Label")
	Label_JingYanLB:setScale(0)
	--获得阅历 文字
	local Label_XueShiLB = tolua.cast(Image_ShuZhiPNL:getChildByName("Label_XueShiLB"),"Label")
	Label_XueShiLB:setScale(0)
end

function Game_SaoDang:openWnd(param)
	if not param then return end --防止打开空界面

	local id = 0
	local sweepResult = nil
	local sweepTimes = 0
	self.pageId_ = 0
	self.idxId_ = 0
	self.types_ = ECTYPE_TYPE.COMMON_ECTYPE
	if param then 
		id =  param.id --扫荡子关卡id
		sweepResult = param.sweepResult --战斗数据
		sweepTimes = param.sweepTimes --战斗数据
		self.pageId_ = param.pageId
		self.idxId_ = param.idxId 
		self.types_ = param.types 
	end

	local Image_SaoDangPNL = tolua.cast(self.rootWidget:getChildByName("Image_SaoDangPNL"),"ImageView")
	self.Button_Return = tolua.cast(Image_SaoDangPNL:getChildByName("Button_Return"),"ImageView")
	if g_PlayerGuide:checkIsInGuide() then --引导中关闭按钮开始锁住，避免发生问题
		self.Button_Return:setTouchEnabled(false)
	else
		self.Button_Return:setTouchEnabled(true)
	end
	
	local Image_ContentPNL = tolua.cast(Image_SaoDangPNL:getChildByName("Image_ContentPNL"),"ImageView")
	local ScrollView_SaoDangList = tolua.cast(Image_ContentPNL:getChildByName("ScrollView_SaoDangList"),"ScrollView")

	ScrollView_SaoDangList:scrollToTop(0.1,true)
	self.scrollView = ScrollView_SaoDangList

	self.expNum = 0
	self.cardExp = 0

	self.nMasterCardLevel = 0
	self.nMasterCardExp = 0
	
	self:sweepData(id,sweepResult,sweepTimes)

end

function Game_SaoDang:closeWnd()
	if self.scrollView then 
		self.scrollView:removeAllChildren()
		self.scrollView = nil
	end
	
    g_Hero:addTeamMemberExpWithHeroEvent(self.cardExp, self.nMasterCardLevel, self.nMasterCardExp)
	self.cardExp = 0
	self.nMasterCardLevel = 0
	self.nMasterCardExp = 0
end

function Game_SaoDang:destroyWnd()
end

--移动ScrollView 动画
function Game_SaoDang:moveScrollView(sweepResult)
	if not sweepResult then 
		SendError("扫荡数据为空=========")
		return 
	end
	
	local allSweepStepCount = #sweepResult
	local y = self.allHeight
	local scaleToCount = 1
	local offset = 0
	for i = 1,allSweepStepCount do
		local tbDropList = sweepResult[i].drop_result.drop_lst
		local tbList = {}
		local tbNotExp = {}
		for i=1, #tbDropList do
			local tbDropItem = tbDropList[i]
			local nType = tbDropItem.drop_item_type
			if(nType == macro_pb.ITEM_TYPE_MASTER_EXP)then --主角经验
				--副本里面不会产出ITEM_TYPE_MASTER_EXP的值
				--self.expNum = self.expNum + tbDropItem.drop_item_num 
			elseif nType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then --出战卡牌经验
				self.cardExp = self.cardExp + tbDropItem.drop_item_num 
				self.nMasterCardLevel = tbDropItem.lv 
				self.nMasterCardExp = tbDropItem.exp 
			else
				g_Hero:addDropItem(tbDropItem)
			end
		end
	end
	
	local function infoClone(nIndex)
		cclog("===============infoClone==============="..nIndex)
		local tbItem = {}
		local Image_SaoDangItemPNL = self.Image_SaoDangItemPNL:clone()
		Image_SaoDangItemPNL:setVisible(true)
		Image_SaoDangItemPNL:setPosition(ccp(450, y))
		y = y - 300
		self.scrollView:addChild(Image_SaoDangItemPNL)
		local Image_BiaoTiPNL = tolua.cast(Image_SaoDangItemPNL:getChildByName("Image_BiaoTiPNL"),"ImageView")
		-- Image_BiaoTiPNL:setVisible(true)
		local Label_CountLB1 = tolua.cast(Image_BiaoTiPNL:getChildByName("Label_CountLB1"),"Label")
		local Label_Count = tolua.cast(Label_CountLB1:getChildByName("Label_Count"),"Label")
		local Label_CountLB2 = tolua.cast(Label_CountLB1:getChildByName("Label_CountLB2"),"Label")
		
		local Image_ShuZhiPNL = tolua.cast(Image_SaoDangItemPNL:getChildByName("Image_ShuZhiPNL"),"ImageView")
		--获得铜钱 文字
		local Label_TongQianLB = tolua.cast(Image_ShuZhiPNL:getChildByName("Label_TongQianLB"),"Label")
		--获取铜钱 数字
		local Label_TongQian = tolua.cast(Label_TongQianLB:getChildByName("Label_TongQian"),"Label")
		--获得经验 文字
		local Label_JingYanLB = tolua.cast(Image_ShuZhiPNL:getChildByName("Label_JingYanLB"),"Label")
		--获取经验 数字
		local Label_JingYan = tolua.cast(Label_JingYanLB:getChildByName("Label_JingYan"),"Label")
		--获得阅历 文字
		local Label_XueShiLB = tolua.cast(Image_ShuZhiPNL:getChildByName("Label_XueShiLB"),"Label")
		--获取阅历 数字
		local Label_XueShi = tolua.cast(Label_XueShiLB:getChildByName("Label_XueShi"),"Label")
		
		
		if nIndex > allSweepStepCount then 
			Label_CountLB1:setText("")
			Label_Count:setText(_T("扫荡结束"))
			--需要修改
			if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
				Label_CountLB1:setPositionX(-40)			
			end
			
			Label_CountLB2:setText("")
			Label_TongQianLB:setVisible(false)
			Label_JingYanLB:setVisible(false)
			Label_XueShiLB:setVisible(false)
			
			self.Button_Return:setTouchEnabled(true)
			if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventEnd", "Game_SaoDang") then
				cclog("=================ActionEventEnd====================")
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
			cclog("sao dang "..nIndex.." "..allSweepStepCount)
			return 
		end

        local tbDropExpGolds = {}
        local tbDropExp = {}
		local tbDropList = sweepResult[nIndex].drop_result.drop_lst
		-- g_Hero:addDropList(tbDropList) --往背包里面增加物品
		for k = 1 ,#tbDropList do          
			local dropType = tbDropList[k].drop_item_type
			local dropConfigId = tbDropList[k].drop_item_config_id
			local dropStarLv = tbDropList[k].drop_item_star_lv
			local dropLv = tbDropList[k].drop_item_lv
			local dropNum = tbDropList[k].drop_item_num
			local dropBlv = tbDropList[k].drop_item_blv
            if dropType > 7 then                       
                tbDropExp.dropNum = tbDropExpGolds[dropType]  or 0
			    tbDropExpGolds[dropType]  = tbDropExp.dropNum + dropNum 
			elseif  dropType > 0 and dropType <= 7 then 
				tbItem[dropType] = tbItem[dropType] or {}
				tbItem[dropType][dropConfigId] = tbItem[dropType][dropConfigId] or {}
			 
				local nDropTatolNum = tbItem[dropType][dropConfigId][dropStarLv]
				if not nDropTatolNum  then 			
					nDropTatolNum = 0
				end

				nDropTatolNum = nDropTatolNum + dropNum
				tbItem[dropType][dropConfigId][dropStarLv] = nDropTatolNum
				
			end
		end
  
        --设置钱 阅历等
        local nTongQian = tbDropExpGolds[macro_pb.ITEM_TYPE_GOLDS ] or 0
        Label_TongQian:setText(tostring(nTongQian))
        local nJingYan = tbDropExpGolds[macro_pb.ITEM_TYPE_CARDEXPINBATTLE] or 0
        Label_JingYan:setText(tostring(nJingYan))
        local nXueShi = tbDropExpGolds[macro_pb.ITEM_TYPE_KNOWLEDGE ] or 0
        Label_XueShi:setText(tostring(nXueShi))
		
		Label_Count:setText(nIndex)
				

		--需要修改
		if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			Label_TongQianLB:setFontSize(18)
			Label_TongQianLB:setPositionX(-380)
			Label_JingYanLB:setFontSize(18)
			Label_XueShiLB:setFontSize(18)
			Label_TongQian:setFontSize(18)
			Label_JingYan:setFontSize(18)
			Label_XueShi:setFontSize(18)
			Label_CountLB1:setPositionX(-100)
			Label_Count:setPositionX( Label_CountLB1:getSize().width+10)
			-- Label_XueShiLB:setPositionX(200)
		end
		
		Label_TongQian:setPositionX(Label_TongQianLB:getSize().width)
		Label_JingYan:setPositionX(Label_JingYanLB:getSize().width)
		Label_XueShi:setPositionX(Label_XueShiLB:getSize().width)
		
		g_AdjustWidgetsPosition({Label_TongQianLB, Label_JingYanLB, Label_XueShiLB},260)
		
		local tbDropDetail = {}
	   
        for key, value in pairs(tbItem) do
            for dropid, tbStar in pairs(value) do
				local tbDrop = {}
				tbDrop.DropItemType = key
                tbDrop.DropItemID = dropid
                
                for dropStarLv, dropNum in pairs(tbStar) do
					tbDrop.DropItemStarLevel = dropStarLv
					tbDrop.DropItemNum = dropNum
                    if dropNum > 0 then 
                        table.insert(tbDropDetail,tbDrop)
                    end
                end
            end
        end
		
		local tbIcon = {}
		local function list()
			local Image_DropItemPNL = tolua.cast(Image_SaoDangItemPNL:getChildByName("Image_DropItemPNL"),"ImageView")
			local ListView_DropItemList = tolua.cast(Image_DropItemPNL:getChildByName("ListView_DropItemList"), "ListViewEx")
			self.LuaListView_DropItemList:setListView(ListView_DropItemList)
			local Panel_DropItem = ListView_DropItemList:getChildByName("Panel_DropItem")
			
			local function updateFunction(widget, nIndex)
				if not tbDropDetail or next(tbDropDetail) == nil then cclog("error   sao dang  error") return end
		
				local dropType = tbDropDetail[nIndex]
				local itemModel = g_CloneDropItemModel(dropType)
				if itemModel then
					itemModel:setScale(0)
					itemModel:setPosition(ccp(60,60))
					widget:addChild(itemModel)
					table.insert(tbIcon,itemModel)
				end
			end
			self.LuaListView_DropItemList:setModel(Panel_DropItem)
			self.LuaListView_DropItemList:setUpdateFunc(updateFunction)
			
			local imgScrollSlider = self.LuaListView_DropItemList:getScrollSlider()
			if not g_tbScrollSliderXY.LuaListView_DropItemList_SaoDao_X then
				g_tbScrollSliderXY.LuaListView_DropItemList_SaoDao_X = imgScrollSlider:getPositionX()
			end
			imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_DropItemList_SaoDao_X - 3)
			
			self.LuaListView_DropItemList:updateItems(#tbDropDetail)

			local sweepStepCount = 1
			
			local function sweepStepMove(items,falge)
			
			cclog("==========sweepStepMove=====infoClone==============="..nIndex)
				local function moveView()
					scaleToCount = scaleToCount + 1
					local sweepStep = scaleToCount
					if sweepStep < allSweepStepCount + 1 then 
						sweepStep = sweepResult[scaleToCount].sweep_step
					end
					infoClone(sweepStep)
					local allOff = (100 / allSweepStepCount) - 2
					self.scrollView:scrollToPercentVertical(math.ceil(offset),0.5,true)
					offset = offset + allOff + (scaleToCount / 2)
				end
				
				local array = {}
				local scaleTo = CCScaleTo:create(0.1,1.2)
				local scaleToTow = CCScaleTo:create(0.1,1)
				table.insert(array,scaleTo)
				table.insert(array,scaleToTow)
			
				if #tbDropDetail == sweepStepCount then table.insert(array,CCCallFuncN:create(moveView)) end
				local action = sequenceAction(array)
				if #tbIcon > 0 and tbIcon[sweepStepCount] then 
					tbIcon[sweepStepCount]:runAction(action)
				else
					moveView()
				end
				sweepStepCount = sweepStepCount + 1
			end

			local Image_SaoDangPNL = tolua.cast(self.rootWidget:getChildByName("Image_SaoDangPNL"),"ImageView")
			local tAction = {}
			for i = 1,#tbDropDetail do 
				local t = {}
				t = CCCallFuncN:create(sweepStepMove)
				table.insert(tAction,t)
				
				t =  CCDelayTime:create(0.1)
				table.insert(tAction,t)
			end
			if next(tAction) then 
				local action = sequenceAction(tAction)
				Image_SaoDangPNL:runAction(action)
			else
				sweepStepMove()
			end
		end
				
		self:textScaleTo(Label_TongQianLB,function() 
			self:textScaleTo(Label_JingYanLB,function() 
				self:textScaleTo(Label_XueShiLB,function()
					list()
				end)
			end)
		end)
	end
	if not sweepResult[1].sweep_step then return end 
	infoClone(sweepResult[1].sweep_step)
end

function Game_SaoDang:sweepData(id,sweepResult,sweepTimes)
	
	if self.types_ == ECTYPE_TYPE.COMMON_ECTYPE then
		local eId = g_DataMgr:getCsvConfigByOneKey("MapEctypeSub",id).EctypeID
		g_Hero:setEctypePassNum(eId,sweepTimes) --通过次数
	elseif self.types_ == ECTYPE_TYPE.ELITE_ECTYPE then  
		g_EctypeJY:setAttackNum(self.pageId_,self.idxId_,sweepTimes)
	end
	
	self.LuaListView_DropItemList = Class_LuaListView:new()

	local sweepResultCount = #sweepResult + 1
	self.allHeight = 300 * sweepResultCount

	local size = self.scrollView:getInnerContainerSize()
	-- ScrollView_SaoDangList:setTouchEnabled(true)
	self.scrollView:setBounceEnabled(true)
	self.scrollView:setClippingEnabled(true)
	self.scrollView:setInnerContainerSize(CCSizeMake(size.width,self.allHeight))
	self.scrollView:scrollToTop(0.1,true)
	
	self:moveScrollView(sweepResult)
end

function Game_SaoDang:textScaleTo(text,func)
	local scaleTo = CCScaleTo:create(0.1,1.1)
	local scaleToTow = CCScaleTo:create(0.1,1)
	local action = sequenceAction({scaleTo,scaleToTow,CCCallFuncN:create(func)})
	text:runAction(action)
end

function Game_SaoDang:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_SaoDangPNL = tolua.cast(self.rootWidget:getChildByName("Image_SaoDangPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_SaoDangPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_SaoDang:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_SaoDangPNL = tolua.cast(self.rootWidget:getChildByName("Image_SaoDangPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_SaoDangPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end
