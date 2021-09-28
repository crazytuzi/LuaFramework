--------------------------------------------------------------------------------------
-- 文件名:	HJW_GameShangXiang.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  
---------------------------------------------------------------------------------------

Game_ShangXiang1 = class("Game_ShangXiang1")
Game_ShangXiang1.__index = Game_ShangXiang1

function Game_ShangXiang1:initWnd()

	--上香响应
	local order = msgid_pb.MSGID_BURN_INCENSE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestBurnIncenseResponse))	

	--属性保存响应
	local order = msgid_pb.MSGID_SAVE_ATTRIBUTE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self,self.requestSaveAttributeNotifyResponse))	

	self.nCardID_ = nil;
	self.nCardLevel_ = nil;
	self.viewCardShangXing_ = nil
	
	self:LayoutTipsShow()
	self:cardInfo()
	
	self.onClickButton_Return = true
		
	local function onBtnClose(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then--离开事件
			if self.warning_ and self.warning_:isTouchEnabled() then
				g_ClientMsgTips:showMsgConfirm(_T("您还有属性没有保存，请保存或取消"))
			else
				g_WndMgr:closeWnd("Game_ShangXiang1")
			end
		end
	end
	
	local BtnClose = tolua.cast(self.rootWidget:getChildByName("Button_Return"),"Button")
	BtnClose:setTouchEnabled(true)
	BtnClose:addTouchEventListener(onBtnClose)
	
	local Button_GanWu = tolua.cast(self.rootWidget:getChildByName("Button_GanWu"),"Button")
	local function onPressed_Button_GanWu(pSender, nTag)
		g_EliminateSystem:RequestInspireCheckData()
	end
	g_SetBtnOpenCheckWithPressImage(Button_GanWu, 1, onPressed_Button_GanWu, true)
	
	local Button_ShangXiangGuide = tolua.cast(self.rootWidget:getChildByName("Button_ShangXiangGuide"), "Button")
	g_RegisterGuideTipButton(Button_ShangXiangGuide, nil)
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getBackgroundJpgImg("ShangXiang"))

    self.tabTokenNeed = {}
    local cfg_token_id
    local cfg_token_starlevel
    local cfg_token_num

    for i = 2 , 4 do
        self.tabTokenNeed[i] = {}
        if i == 2 then
            cfg_token_id = "shangxiang_baijin_token_id"
            cfg_token_starlevel = "shangxiang_baijin_token_starlevel"
            cfg_token_num = "shangxiang_baijin_token_num"            
        elseif i == 3 then
            cfg_token_id = "shangxiang_zuanshi_token_id"
            cfg_token_starlevel = "shangxiang_zuanshi_token_starlevel"
            cfg_token_num = "shangxiang_zuanshi_token_num"
        elseif i == 4 then
            cfg_token_id = "shangxiang_zhizun_token_id"
            cfg_token_starlevel = "shangxiang_zhizun_token_starlevel"
            cfg_token_num = "shangxiang_zhizun_token_num"
        end

        --上香代币ID
        self.tabTokenNeed[i].token_id = g_DataMgr:getGlobalCfgCsv(cfg_token_id)
        --上香代币星级
        self.tabTokenNeed[i].token_starlevel = g_DataMgr:getGlobalCfgCsv(cfg_token_starlevel)
        --上香代币数量
        self.tabTokenNeed[i].token_num = g_DataMgr:getGlobalCfgCsv(cfg_token_num)
    end
end

function Game_ShangXiang1:openWnd()
	
	self.CheckBoxGroup = CheckBoxGroup:New()
	self.ButtonGroup = ButtonGroup:create()
	
	self:shangXiangBtn()

	g_Hero:SetCardFlagPV(1) --加载所有伙伴

	local pageIndex = g_Hero:GetCardIndexByIDPV(self.nCardID_)
	local ammountForPv = g_Hero:GetCardAmmountForPV()
	
	self.viewCardShangXing_:setCurPageIndex(pageIndex)
	self.viewCardShangXing_:updatePageView(ammountForPv)
	
end

function Game_ShangXiang1:closeWnd()
	self.qualityIndex_ = nil
	self.CheckBoxGroup = nil
	self.ButtonGroup = nil
	self.nCardID_ = nil
	self.nCardLevel_ = nil
	if self.viewCardShangXing_ then
		self.viewCardShangXing_:ReleaseItemModle()
	end
	self.viewCardShangXing_ = nil
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getUIImg("Blank"))
end

function Game_ShangXiang1:destroyWnd()

end
--[[
	4种属性
	1：生命，2：武力，3：法术，4：绝技
]]
function Game_ShangXiang1:propertyBead()
	local wndInstance = g_WndMgr:getWnd("Game_ShangXiang1")
	if wndInstance and wndInstance.rootWidget then 
	
		local tbCard = g_Hero:getCardObjByServID(wndInstance.nCardID_)
		
		local csXiangData = tbCard:getCSXiangData()
		local accuPropValue = csXiangData:getAccuPropValue()
		
		if not wndInstance.nCardLevel_ then wndInstance.nCardLevel_ = 1 end 
		local cardIncense = g_DataMgr:getCsvConfigByOneKey("CardIncense",wndInstance.nCardLevel_)
		--key1:职业，key2:星级
		local CSV_CardBase = tbCard:getCsvBase()
		local starLevel = tbCard:getStarLevel()
		local ProfessionModuls = g_DataMgr:getCsvConfigByTwoKey("ProfessionModuls",CSV_CardBase.Profession,starLevel)
		
		local tbCardIncense = {
			cardIncense.HPMax,
			cardIncense.ForcePoints,
			cardIncense.MagicPoints,
			cardIncense.SkillPoints,
		}
		local tbModuls = {
			ProfessionModuls.incense_hpmax_moduls,
			ProfessionModuls.incense_forcepoints_moduls,
			ProfessionModuls.incense_magicpoints_moduls,
			ProfessionModuls.incense_skillpoints_moduls,
		}
		
		local indexTable = { 1,3,2,5 }
		local Image_ShangXiangPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ShangXiangPNL"),"ImageView")
		for i = 1,4 do
			
			local upperLimit = math.floor(tbCardIncense[i] * tbModuls[i] / g_BasePercent)
			
			local curPropValue = accuPropValue[i]
			
			local Image_ShangXiangPos =  tolua.cast(Image_ShangXiangPNL:getChildByName("Image_ShangXiangPos"..i),"ImageView")
			
			local Panel_AnimationContent = tolua.cast(Image_ShangXiangPos:getChildByName("Panel_AnimationContent"),"Layout")
			 --最新数值
			local Label_PropValue = tolua.cast(Image_ShangXiangPos:getChildByName("Label_PropValue"),"Label")
			Label_PropValue:setText(curPropValue)
			
			local colorType = csXiangData:getColorCalculate(curPropValue,upperLimit)
			g_SetWidgetColorBySLev(Label_PropValue,colorType)
			--上限值
			local Label_PropValueFull = tolua.cast(Image_ShangXiangPos:getChildByName("Label_PropValueFull"),"Label")
			Label_PropValueFull:setText("/"..upperLimit)
			g_SetWidgetColorBySLev(Label_PropValueFull,1)
			
			--圆形裁决
			Panel_AnimationContent:setClippingEnabled(true)
			Panel_AnimationContent:setRadius(70)
			Panel_AnimationContent:removeAllNodes()
			local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("ShangXiangFire", nil, function() 
			end, 5)
			local percent = curPropValue / upperLimit * 160
			armature:setPosition(ccp(55,percent))
			armature:setScale(2)
			
			armature:setAnchorPoint(ccp(0.5,1))
			Panel_AnimationContent:addNode(armature)
			userAnimation:playWithIndex(indexTable[i])
			
			local Button_ShangXiangPos =  tolua.cast(Image_ShangXiangPos:getChildByName("Button_ShangXiangPos"),"Button")
			g_SetBtnWithPressingEvent(Button_ShangXiangPos, i, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
		end
	end
end

function Game_ShangXiang1:sevenPropertyAction()
	local wndInstance = g_WndMgr:getWnd("Game_ShangXiang1")
	if wndInstance and wndInstance.rootWidget then 
		local Image_ShangXiangPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ShangXiangPNL"),"ImageView")

		for i = 1,4 do
			local Image_ShangXiangPos = tolua.cast(Image_ShangXiangPNL:getChildByName("Image_ShangXiangPos"..i),"ImageView")
			local Button_ShangXiangPos =  tolua.cast(Image_ShangXiangPos:getChildByName("Button_ShangXiangPos"),"Button")
			
			local armature1,userAnimation1 = g_CreateCoCosAnimationWithCallBacks("ShangXiangSucc", nil, function() 
			end, 5)
			armature1:setPositionY(3)
			Button_ShangXiangPos:addNode(armature1)
			userAnimation1:playWithIndex(0)
		end
	end
end

--上香功能
function Game_ShangXiang1:shangXiangBtn()
	local wndInstance = g_WndMgr:getWnd("Game_ShangXiang1")
	if wndInstance and wndInstance.rootWidget then 
		local Image_ShangXiangPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ShangXiangPNL"),"ImageView")
		local function onShangXiang(pSender, nTag)		
			local cardIncense = g_DataMgr:getCsvConfigByOneKey("CardIncense",wndInstance.nCardLevel_)
			local needMoney  = cardIncense.NeedMoney --铜钱
			local needIncense = cardIncense.NeedIncense --香供
			local tbNeed = {
				[2] = cardIncense.NeedYuanBao1, --
				[3] = cardIncense.NeedYuanBao2, --
				[4] = cardIncense.NeedYuanBao3, --
			}
			local function substitutionTips(costNum, qualityIndex)
				if qualityIndex == 1 then --消耗铜钱
					
					if not g_CheckMoneyConfirm(costNum, string.format(_T("上香需要消耗%d铜钱, 您的铜钱不足是否进行招财？"), costNum)) then
						return false
					end
				else
                    local objItemToken = g_Hero:getItemByCsv(self.tabTokenNeed[qualityIndex].token_id, self.tabTokenNeed[qualityIndex].token_starlevel)  --玩家代币
                    local nTokenNum = 0
                    if objItemToken ~= "无此道具" then
                        nTokenNum = objItemToken:getNum()     --代币数量
                    end
				    if nTokenNum < self.tabTokenNeed[qualityIndex].token_num then
					    if not g_CheckYuanBaoConfirm(costNum,string.format(_T("上香需要消耗%d元宝, 您的元宝不足是否前往充值?"), costNum)) then
						    return false
					    end
                    end
				end
				return true
			end
			
			local need = needMoney
			if wndInstance.qualityIndex_ ~= 1 then 
				need = tbNeed[wndInstance.qualityIndex_]
			end
			
			if not substitutionTips(need, wndInstance.qualityIndex_) then 
				return 
			end
		
			if needIncense > g_Hero:getIncense() then 
				g_ClientMsgTips:showMsgConfirm(_T("您的香贡不足，可以去感悟试试"))
				return 
			end
			wndInstance:requestBurnIncenseRequest(wndInstance.qualityIndex_,wndInstance.nCardID_)
		end
		local Button_ShangXiang = tolua.cast(Image_ShangXiangPNL:getChildByName("Button_ShangXiang"),"Button")
		g_SetBtnWithGuideCheck(Button_ShangXiang, 1, onShangXiang, true)
		Button_ShangXiang:setVisible(true)
		
		local Image_Check = tolua.cast(Button_ShangXiang:getChildByName("Image_Check"),"ImageView")
		wndInstance:saveOrCancel(false)
	end
end

--上香前需要消耗的资源 nLevel 是卡牌等级
function Game_ShangXiang1:itemNeed(flag, nIndex, nLevel)
	local cardIncense = g_DataMgr:getCsvConfigByOneKey("CardIncense",nLevel)
	local needMoney  = cardIncense.NeedMoney --铜钱
	local needIncense = cardIncense.NeedIncense --香供
	local tbNeed = {
		[2] = cardIncense.NeedYuanBao1, --
		[3] = cardIncense.NeedYuanBao2, --
		[4] = cardIncense.NeedYuanBao3, --
	}
	flag = flag or false
			
	local wndInstance = g_WndMgr:getWnd("Game_ShangXiang1")
	if wndInstance and wndInstance.rootWidget then 
		local Image_ShangXiangPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ShangXiangPNL"),"ImageView")
		--上香需要消耗的数值
		local Image_NeedResourcePNL = tolua.cast(Image_ShangXiangPNL:getChildByName("Image_NeedResourcePNL"),"ImageView")
		Image_NeedResourcePNL:setVisible(flag)
		
		if not flag then return end
		--铜钱
		local Button_NeedMoney = tolua.cast(Image_NeedResourcePNL:getChildByName("Button_NeedMoney"),"Button")

		local Label_NeedMoney = tolua.cast(Button_NeedMoney:getChildByName("Label_NeedMoney"),"Label")
		Label_NeedMoney:setText(needMoney)
		
		if needMoney then 
			g_SetLabelRed(Label_NeedMoney,needMoney > g_Hero:getCoins())	
		end
		--香供
		local Button_NeedIncense = tolua.cast(Image_NeedResourcePNL:getChildByName("Button_NeedIncense"),"Button")
		local Label_NeedIncense = tolua.cast(Button_NeedIncense:getChildByName("Label_NeedIncense"),"Label")
		Label_NeedIncense:setText(needIncense)
		
		if needIncense then
			g_SetLabelRed(Label_NeedIncense,needIncense > g_Hero:getIncense())
		end
		--元宝
		local Button_NeedYuanBao = tolua.cast(Image_NeedResourcePNL:getChildByName("Button_NeedYuanBao"),"Button")
        local Image_NeedYuanBao = tolua.cast(Button_NeedYuanBao:getChildByName("Image_NeedYuanBao"),"ImageView")
        Image_NeedYuanBao:setScale(0.8)
        Image_NeedYuanBao:loadTexture(getUIImg("Icon_PlayerInfo_YuanBao"))
		local Label_NeedYuanBao = tolua.cast(Button_NeedYuanBao:getChildByName("Label_NeedYuanBao"),"Label")
		Label_NeedYuanBao:setText(tbNeed[nIndex])

		nIndex = nIndex or 1
		if nIndex <= 1 then 
			Button_NeedMoney:setVisible(false)
			Button_NeedIncense:setVisible(true)
			Button_NeedYuanBao:setVisible(false)
			Button_NeedIncense:setPositionXY(0,0)
		else
			Button_NeedMoney:setVisible(false)
			Button_NeedIncense:setVisible(true)
			Button_NeedYuanBao:setVisible(true)
			if tbNeed[nIndex] then 
				g_SetLabelRed(Label_NeedYuanBao,tbNeed[nIndex] > g_Hero:getYuanBao())
			end
			Button_NeedIncense:setPositionXY(-100,0)
			Button_NeedYuanBao:setPositionXY(100,0)

            local objItemToken = g_Hero:getItemByCsv(self.tabTokenNeed[nIndex].token_id, self.tabTokenNeed[nIndex].token_starlevel)  --玩家代币
            if objItemToken ~= "无此道具" then
                local nTokenNum = objItemToken:getNum()     --代币数量
                local strTokenName = objItemToken:getName() --代币昵称
                local strTokenIcon = objItemToken:getIcon() --代币Icon

                if nTokenNum >= self.tabTokenNeed[nIndex].token_num then
                    Label_NeedYuanBao:setText(self.tabTokenNeed[nIndex].token_num)
                    g_SetLabelRed(Label_NeedYuanBao,self.tabTokenNeed[nIndex].token_num > nTokenNum)
                    Image_NeedYuanBao:loadTexture(getIconImg(strTokenIcon))
                    Image_NeedYuanBao:setScale(0.6)    
                end
            end
		end
	end
end

--上香完获得的数据
function Game_ShangXiang1:shangXiangValue(flag,propValue)
	flag = flag or false
	local wndInstance = g_WndMgr:getWnd("Game_ShangXiang1")
	if wndInstance and wndInstance.rootWidget then 
		local Image_ShangXiangPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ShangXiangPNL"),"ImageView")

		local Image_RandPropPNL = tolua.cast(Image_ShangXiangPNL:getChildByName("Image_RandPropPNL"),"ImageView")
		Image_RandPropPNL:setVisible(flag)
		
		if not propValue or not flag  then  return  end
		local tbCard = g_Hero:getCardObjByServID(wndInstance.nCardID_)
		local csXiangData = tbCard:getCSXiangData()

		for i = 1, 4 do
			local Image_RandProp =  tolua.cast(Image_RandPropPNL:getChildByName("Image_RandProp"..i),"ImageView")
			local BitmapLabel_PropValue = tolua.cast(Image_RandProp:getChildByName("BitmapLabel_PropValue"),"LabelBMFont")
			local value = propValue[i]
			local strText = "+"..value
			local colorTypeIndex = ccs.COLOR.LIME_GREEN
			local strImage = "Image_ArrowUp"
			local fntFile = "Char/Char_ShangXiang_Green.fnt"
			if tonumber(value) < 0 then 
				strText = value
				fntFile = "Char/Char_ShangXiang_Red.fnt"
				strImage = "Image_ArrowDown"
			elseif tonumber(value) == 0 then 
				fntFile = "Char/Char_ShangXiang_Grey.fnt"
			end
			BitmapLabel_PropValue:setFntFile(fntFile)
			BitmapLabel_PropValue:setText(strText)

			local Image_ArrowGuide = tolua.cast(Image_RandProp:getChildByName("Image_ArrowGuide"),"ImageView")
			Image_ArrowGuide:setVisible(true)
			
			if value == 0 then 
				Image_ArrowGuide:setVisible(false)
			end
			Image_ArrowGuide:loadTexture(getShangXiangImg(strImage) )

			-- Image_ArrowGuide:setPosition(ccp(70,0))
			Image_ArrowGuide:stopAllActions()
			Image_ArrowGuide:setPositionY(0)
			g_CreateUpAndDownAnimation(Image_ArrowGuide)

		end
	end
end

--保存 数据后的动画
function Game_ShangXiang1:saveAnimation(node)
	local wndInstance = g_WndMgr:getWnd("Game_ShangXiang1")
	if wndInstance and wndInstance.rootWidget then 
		local Image_ShangXiangPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ShangXiangPNL"),"ImageView")
		local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("IncenseStatue", nil, nil, 5)
		armature:setScale(1.5)
		armature:setPositionY(45)
		Image_ShangXiangPNL:addNode(armature, 999)
		userAnimation:playWithIndex(0)	
	end	
end

--保存和取消 按钮
function Game_ShangXiang1:saveOrCancel(flag)
	
	flag = flag or false
	if flag then 
		self.warning_:setTouchEnabled(true)
	else
		self.warning_:setTouchEnabled(false)
	end
	local function notShow()
		self:shangXiangValue(false,nil)
		self:shangXiangBtn()	
	end
	
	local Image_ShangXiangPNL = tolua.cast(self.rootWidget:getChildByName("Image_ShangXiangPNL"),"ImageView")
	--保存
	local function onConfirm(pSender, nTag)
		notShow()
		
		self:requestSaveAttributeNotifyRequest(self.nCardID_)
	end
	local Button_Confirm = tolua.cast(Image_ShangXiangPNL:getChildByName("Button_Confirm"),"Button")
	g_SetBtnWithGuideCheck(Button_Confirm, 1, onConfirm, true)
	Button_Confirm:setVisible(flag)
	
	--取消
	local function onCancel(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			notShow()
			self:QualityEnabled(true)
		end
	end
	local Button_Cancel = tolua.cast(Image_ShangXiangPNL:getChildByName("Button_Cancel"),"Button")
	Button_Cancel:setTouchEnabled(true)
	Button_Cancel:addTouchEventListener(onCancel)	
	Button_Cancel:setVisible(flag)
end

--选择要上香的品质
function Game_ShangXiang1:selectQuality()
	local wndInstance = g_WndMgr:getWnd("Game_ShangXiang1")
	if wndInstance and wndInstance.rootWidget then 
		local Image_ShangXiangPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ShangXiangPNL"),"ImageView")
		local Image_RandPropPNL = tolua.cast(Image_ShangXiangPNL:getChildByName("Image_RandPropPNL"),"ImageView")
		
		for nOptionIndex = 1,4 do
			local Button_Option = tolua.cast(Image_ShangXiangPNL:getChildByName("Button_Option"..nOptionIndex),"Button")
			local CheckBox_Option = tolua.cast(Button_Option:getChildByName("CheckBox_Option"),"CheckBox")
			wndInstance.CheckBoxGroup:PushBack(CheckBox_Option, function() end)
			CheckBox_Option:setTouchEnabled(false)
			wndInstance.ButtonGroup:PushBack(Button_Option, nil, function()
				wndInstance.CheckBoxGroup:CheckWithoutEvent(nOptionIndex)
				wndInstance.qualityIndex_ = nOptionIndex
				local flag = true
				if Image_RandPropPNL:isVisible() then 
					flag = false
				end
				wndInstance:itemNeed(flag, nOptionIndex, wndInstance.nCardLevel_)
			end)
		end
		wndInstance.ButtonGroup:Check(1)
	end
end

--选择要上香的品质
function Game_ShangXiang1:QualityEnabled(flag)
	local wndInstance = g_WndMgr:getWnd("Game_ShangXiang1")
	if wndInstance and wndInstance.rootWidget then 
		local Image_ShangXiangPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ShangXiangPNL"),"ImageView")
		local Image_RandPropPNL = tolua.cast(Image_ShangXiangPNL:getChildByName("Image_RandPropPNL"),"ImageView")
		for nOptionIndex = 1,4 do
			local Button_Option = tolua.cast(Image_ShangXiangPNL:getChildByName("Button_Option"..nOptionIndex),"Button")
			local CheckBox_Option =  tolua.cast(Button_Option:getChildByName("CheckBox_Option"),"CheckBox")
			CheckBox_Option:setTouchEnabled(false)
			Button_Option:setTouchEnabled(flag)
		end
	end
end

	

--伙伴信息 可滑动
function Game_ShangXiang1:cardInfo()
	local rootWidget = self.rootWidget
	local Panel_Stencil = tolua.cast(rootWidget:getChildByName("Panel_Stencil"),"Layout")
	Panel_Stencil:setClippingEnabled(true)
	Panel_Stencil:setRadius(153)
	
	local Image_NamePNL = tolua.cast(Panel_Stencil:getChildByName("Image_NamePNL"),"ImageView")
	
	local function onClickCard(widget, nIndex)
		
		local nIndex = self.viewCardShangXing_:getCurPageIndex()
		local nCardID = g_Hero:GetCardIDByIndexPV(nIndex)
		self.nCardID_ = nCardID

		local tbCard = g_Hero:getCardObjByServID(nCardID)
	
		local Label_Name =  tolua.cast(Image_NamePNL:getChildByName("Label_Name"),"Label")
		Label_Name:setText(tbCard:getNameWithSuffix(Label_Name))
		
		local Label_Level = tolua.cast(Image_NamePNL:getChildByName("Label_Level"),"Label")
		Label_Level:setText(_T("Lv.")..tbCard:getLevel())
		
		self.nCardLevel_ = tbCard:getLevel()
		
		--隐藏上香数据
		self:shangXiangValue(false,nil)
		-- --品质选择
		self:selectQuality()
		
		self:propertyBead()
	end
	
	local function setCardImgInfo(widget, nIndex)
		local nCardID = g_Hero:GetCardIDByIndexPV(nIndex)
		local tbCard = g_Hero:getCardObjByServID(nCardID)
		local CSV_CardBase = tbCard:getCsvBase()
		
		local Panel_Card = tolua.cast(widget:getChildByName("Panel_Card"), "Layout")
		local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"),"ImageView")
		local CCNode_Skeleton = g_CocosSpineAnimation(CSV_CardBase.SpineAnimation, 1)
		Image_Card:loadTexture(getUIImg("Blank"))
		Image_Card:removeAllNodes()
		Image_Card:setPositionXY(CSV_CardBase.PotraitX, CSV_CardBase.PotraitY)
		Image_Card:addNode(CCNode_Skeleton)
		g_runSpineAnimation(CCNode_Skeleton, "idle", true)
		Panel_Card:setScale(CSV_CardBase.PotraitScale*1.6/100)
		Panel_Card:setPositionY(190)
	end

	--增加page view效果
	local PageView_Card = tolua.cast(Panel_Stencil:getChildByName("PageView_Card"),"PageView")
	local Panel_CardPage = tolua.cast(PageView_Card:getChildByName("Panel_CardPage"),"Layout")

	local Button_ForwardPage = tolua.cast(rootWidget:getChildByName("Button_ForwardPage"),"Button")
	local Button_NextPage = tolua.cast(rootWidget:getChildByName("Button_NextPage"),"Button")
	
	local luaPViewCardShangXing = Class_LuaPageView.new()
	self.viewCardShangXing_ = luaPViewCardShangXing
	luaPViewCardShangXing:registerUpdateFunction(setCardImgInfo)
	luaPViewCardShangXing:registerClickEvent(onClickCard)
	

	
	luaPViewCardShangXing:setModel(Panel_CardPage, Button_ForwardPage, Button_NextPage, 0.70, 0.70)
	luaPViewCardShangXing:setPageView(PageView_Card)	

	
end

function Game_ShangXiang1:LayoutTipsShow()

	local warning =  Layout:create()
	self.rootWidget:addChild(warning,INT_MAX)
	warning:setSize(CCSize(550,400))
	warning:setPosition(ccp(370,100))
	local function tips()
		if self.warning_:isTouchEnabled() then
			g_ClientMsgTips:showMsgConfirm(_T("您还有属性没有保存，请保存或取消"))
		end
	end
	
	local function onTouch(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then--离开事件
			tips()
		elseif eventType == ccs.TouchEventType.began then --点击事件
		elseif eventType == ccs.TouchEventType.canceled then
			tips()
		end
	end
	warning:setTouchEnabled(false)
	warning:addTouchEventListener(onTouch)
	self.warning_ = warning
	
end


--上香请求
function Game_ShangXiang1:requestBurnIncenseRequest(burnType,cardId)
	cclog("----Game_ShangXiang1:requestBurnIncenseRequest-------")
	local rootMsg = zone_pb.BurnIncenseRequest()
	rootMsg.burn_type = burnType -- 上香类型
	rootMsg.card_id = cardId --// 上香的伙伴id
	g_MsgMgr:sendMsg(msgid_pb.MSGID_BURN_INCENSE_REQUEST, rootMsg)
end

--上香响应
function Game_ShangXiang1:requestBurnIncenseResponse(tbMsg)
	cclog("---------requestBurnIncenseResponse-------------")
	local msgDetail = zone_pb.BurnIncenseResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local updatedMoney = msgDetail.updated_money --// 剩余铜钱
	local updatedIncense =  msgDetail.updated_incense --// 剩余香贡
	local updatedCoupons = msgDetail.updated_coupons --// 剩余元宝
	local propValue = msgDetail.prop_value --// 上香得到的属性
	-- local cardId = msgDetail.card_id --// 上香的伙伴id
	
	local wndInstance = g_WndMgr:getWnd("Game_ShangXiang1")
	if wndInstance  then
		local yuanBao = g_Hero:getYuanBao() - updatedCoupons
		if yuanBao > 0 then 
			local itemType = nil
			if wndInstance.qualityIndex_ == 2 then 
				itemType = TDPurchase_Type.TDP_Platina_ShangXiang 
			elseif wndInstance.qualityIndex_ == 3 then
				itemType = TDPurchase_Type.TDP_Diamond_ShangXiang 
			elseif wndInstance.qualityIndex_ == 4 then
				itemType = TDPurchase_Type.TDP_Extreme_ShangXiang
			end
			--上香 付费点
			gTalkingData:onPurchase(itemType, 1, yuanBao)
		end
	end
	
	g_Hero:setYuanBao(updatedCoupons)
	g_Hero:setCoins(updatedMoney)
	g_Hero:setIncense(updatedIncense)
	
	local wndInstance = g_WndMgr:getWnd("Game_ShangXiang1")
	if wndInstance then
		if wndInstance.rootWidget then 
			local Image_ShangXiangPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_ShangXiangPNL"),"ImageView")
			local Button_ShangXiang = tolua.cast(Image_ShangXiangPNL:getChildByName("Button_ShangXiang"),"Button") 
			Button_ShangXiang:setTouchEnabled(false)	
			Button_ShangXiang:setVisible(false)

		    local Image_RandPropPNL = tolua.cast(Image_ShangXiangPNL:getChildByName("Image_RandPropPNL"),"ImageView")
            local flag = true
		    if Image_RandPropPNL:isVisible() then 
			    flag = false
		    end
            --刷新当前需要的货币
            wndInstance:itemNeed(flag, wndInstance.qualityIndex_, wndInstance.nCardLevel_)
		end
		wndInstance:shangXiangValue(true, propValue)
		wndInstance:saveOrCancel(true)--显示
		wndInstance:QualityEnabled(false)
	end 
end
	
	
--属性保存请求
function Game_ShangXiang1:requestSaveAttributeNotifyRequest(cardId)
	cclog("----Game_ShangXiang1:requestSaveAttributeNotifyRequest-------")
	local rootMsg = zone_pb.SaveAttributeRequest()
	rootMsg.card_id = cardId
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SAVE_ATTRIBUTE_REQUEST, rootMsg)
end

--属性保存响应
function Game_ShangXiang1:requestSaveAttributeNotifyResponse(tbMsg)
	cclog("---------requestSaveAttributeNotifyResponse-------------")
	local msgDetail = zone_pb.SaveAttributeNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local accuPropValue = msgDetail.accu_prop_value --// 上香保存后的累计属性
	local cardId =  msgDetail.card_id --// 上香的伙伴id

	self:saveAnimation(self.rootWidget) --保存动画

	local tbCard = g_Hero:getCardObjByServID(cardId)
	local csXiangData = tbCard:getCSXiangData()
	for i = 1,#accuPropValue do
		csXiangData:setAccuPropValue(i,accuPropValue[i])
	end

	tbCard:reCalculateShangXiangProps()
	
	self.nCardID_ = cardId
	
	self:propertyBead()
	self:sevenPropertyAction()
	
	self:QualityEnabled(true)
end

