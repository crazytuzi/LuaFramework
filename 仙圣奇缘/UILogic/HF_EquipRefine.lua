--------------------------------------------------------------------------------------
-- 文件名:	HF_EquipRefine.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  flamehong
-- 日  期:	2014-10-28 17:42
-- 版  本:	1.0
-- 描  述:	合成界面
-- 应  用:  

--------------------------------------------------------------------------------------
Game_EquipRefine = class("Game_EquipRefine")
Game_EquipRefine.__index = Game_EquipRefine

local level = nil
local tbImage = {}

function Game_EquipRefine:initWnd()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_COMPOSE_EQUIP_RESPONSE,handler(self,self.ComposeEquip)) --装备合成响应
end

function Game_EquipRefine:openWnd(param)
	if param then 
		if param.nEquipID then  self.equipID_ = param.nEquipID end 
		if param.nLevel then level = param.nLevel end --卡牌等级
	end
	self:EquipShow(self.equipID_)
end

function Game_EquipRefine:closeWnd()
end


function Game_EquipRefine:EquipShow(equipId)
	local rootWidget = self.rootWidget
	if not rootWidget then return end
	if not equipId then return end
	
	local GameObj_Equip = g_Hero:getEquipObjByServID(equipId)
	--星级
	local rLevel = GameObj_Equip:getRefineLev()
	--强化等级
	local nStrengthenLev = GameObj_Equip:getStrengthenLev() 
	local equipPropFloor = GameObj_Equip:getEquipMainPropFloor()
	local nextMainProp = GameObj_Equip:getEquipMainPropNextStarLvFloor()
	local _, CSV_StarLvel = GameObj_Equip:getNextEquipStarLevel()
	--最大合成等级
	local maxRefineLv = GameObj_Equip:checkMaxRefineAndMaxStar() 
	--获取物品基本数据表
	local CSV_Equip = GameObj_Equip:getCsvBase();

	local colorType = CSV_Equip.ColorType
	local icon = CSV_Equip.Icon
	local subType = CSV_Equip.SubType
	local equipName = CSV_Equip.Name
	
	local propName = g_tbMainPropName[subType]
	--要合成的装备
	local ImageView_EquipRefinePNL = tolua.cast(rootWidget:getChildByName("ImageView_EquipRefinePNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_EquipRefinePNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Image_LuDing = tolua.cast(Image_ContentPNL:getChildByName("Image_LuDing"),"ImageView")
	--星级
	local Image_RefineLevelSource = tolua.cast(Image_ContentPNL:getChildByName("Image_RefineLevelSource"),"ImageView")
	Image_RefineLevelSource:setVisible(false)
	 
	local Image_EuipeIconCircle = tolua.cast(Image_LuDing:getChildByName("Image_EuipeIconCircle"),"ImageView")
	Image_EuipeIconCircle:loadTexture(getUIImg("FrameEquipCircle"..colorType))
	
	local Image_Icon = tolua.cast(Image_EuipeIconCircle:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getIconImg(icon))
	
	--装备的缩放和旋转角度 CSV_Equip.SubType 根据装备类型
	g_SetEquipSacle(Image_Icon,subType)
	
	--装备名称
	local Label_SourceName = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceName"),"Label")
	Label_SourceName:setText(equipName)
    g_SetWidgetColorBySLev(Label_SourceName,colorType)
	
	--装备等级
	local Label_SourceStrengthenLevel = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceStrengthenLevel"),"Label")
	Label_SourceStrengthenLevel:setText(_T("Lv.").." "..nStrengthenLev)
	--控件对齐方式
	g_AdjustWidgetsPosition({Label_SourceName,Label_SourceStrengthenLevel}, 5)
	
	--装备杀伤力
	local BitmapLabel_SourceMainProp = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_SourceMainProp"),"LabelBMFont")
	BitmapLabel_SourceMainProp:setText(equipPropFloor)
	
	--装备攻击类型
	local Label_SourceMainPropName = tolua.cast(Image_ContentPNL:getChildByName("Label_SourceMainPropName"),"Label")
	Label_SourceMainPropName:setText(propName)
	--控件对齐方式
	g_AdjustWidgetsPosition({BitmapLabel_SourceMainProp,Label_SourceMainPropName},-8)

	--下一等级属性预览
	local Label_TargetName = tolua.cast(Image_ContentPNL:getChildByName("Label_TargetName"),"Label")
	local Label_TargetStrengthenLevel = tolua.cast(Image_ContentPNL:getChildByName("Label_TargetStrengthenLevel"),"Label")
	local BitmapLabel_TargetMainProp = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_TargetMainProp"),"LabelBMFont")
	local Label_TargetMainPropName = tolua.cast(Image_ContentPNL:getChildByName("Label_TargetMainPropName"),"Label")
	local Image_RefineLevelTarget = tolua.cast(Image_ContentPNL:getChildByName("Image_RefineLevelTarget"),"ImageView")
	Image_RefineLevelTarget:setVisible(false)
	
	local Image_Arrow = tolua.cast(Image_ContentPNL:getChildByName("Image_Arrow"),"ImageView")
	
	if rLevel > 0 then 
		Image_RefineLevelSource:loadTexture(getUIImg("Icon_StarLevel"..rLevel))
		Image_RefineLevelSource:setVisible(true)
		
		Image_RefineLevelTarget:loadTexture(getUIImg("Icon_StarLevel"..rLevel))
		Image_RefineLevelTarget:setVisible(true)
	end
	
	local showFlag = true
	--合成到最大
	if maxRefineLv then 
		showFlag = false
		Image_RefineLevelTarget:setVisible(false)
	else
		local targetEquipName = CSV_StarLvel.Name
		local colorType = CSV_StarLvel.ColorType

		Label_TargetName:setText(targetEquipName)
		g_SetWidgetColorBySLev(Label_TargetName,colorType)

		Label_TargetStrengthenLevel:setText(_T("Lv.").." "..nStrengthenLev)
		g_AdjustWidgetsPosition({Label_TargetName,Label_TargetStrengthenLevel}, 5)--控件对齐方式
		
		BitmapLabel_TargetMainProp:setText(nextMainProp)
		Label_TargetMainPropName:setText(propName)
		g_AdjustWidgetsPosition({BitmapLabel_TargetMainProp,Label_TargetMainPropName},-8)
	end
	
	Label_TargetName:setVisible(showFlag)
	Label_TargetStrengthenLevel:setVisible(showFlag)
	BitmapLabel_TargetMainProp:setVisible(showFlag)
	Label_TargetMainPropName:setVisible(showFlag)
	Image_Arrow:setVisible(showFlag)
	
	self:materialShow(CSV_Equip,GameObj_Equip,equipId)
	
end

function Game_EquipRefine:materialShow(CSV_Equip,GameObj_Equip,nEquipID)
	local imageNum = 5
	local rootWidget = self.rootWidget
	if not rootWidget then return end
	local ImageView_EquipRefinePNL = tolua.cast(rootWidget:getChildByName("ImageView_EquipRefinePNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_EquipRefinePNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Button_Refine = tolua.cast(Image_ContentPNL:getChildByName("Button_Refine"),"Button")
	local BitmapLabel_NeedMoney_Refine = tolua.cast(Button_Refine:getChildByName("BitmapLabel_NeedMoney"),"LabelBMFont")
	
	local BitmapLabel_FuncName = tolua.cast(Button_Refine:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")
	local Image_Coins = tolua.cast(Button_Refine:getChildByName("Image_Coins"),"ImageView")
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		-- local size = 16
		-- BitmapLabel_FuncName:setScale(0.8)
	end
	
	
	local Button_YuanBaoHeCheng = tolua.cast(Image_ContentPNL:getChildByName("Button_YuanBaoHeCheng"),"Button")

	local BitmapLabel_FuncName_YuanBao = tolua.cast(Button_YuanBaoHeCheng:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")
	local Image_YuanBao = tolua.cast(Button_YuanBaoHeCheng:getChildByName("Image_YuanBao"),"ImageView")
	--缺少材料的数量 元宝数
	local BitmapLabel_NeedMoney = tolua.cast(Button_YuanBaoHeCheng:getChildByName("BitmapLabel_NeedMoney"),"LabelBMFont")


	local itemNum = 0 --缺少多少个材料
	local recipeNum = 0;--配方元宝数量
	local yanbao = 0
	local bEnable = false
	local price  = 0
	local nCount = 0
	local bMaterialEnough = false
	
	--最大合成等级
	local maxRefineLv = GameObj_Equip:checkMaxRefineAndMaxStar() 
	--当前装备的星级
	local equipStarLevel = GameObj_Equip:getStarLevel()
	if maxRefineLv then 
		g_SetButtonEnabled(Button_Refine, false, _T("已达上限"))
		g_SetButtonEnabled(Button_YuanBaoHeCheng, false, _T("已达上限"))
		for nIndex = 1,imageNum do
			local Button_Material = tolua.cast(Image_ContentPNL:getChildByName("Button_Material"..nIndex),"Button")
			-- Button_Material:removeAllChildren()
			local Image_Add = tolua.cast(Button_Material:getChildByName("Image_Add"),"ImageView")
			Image_Add:setVisible(false)
		end
		-- if tbImage then 
			-- for key = 1,#tbImage do 
				-- tbImage[key]:removeFromParentAndCleanup(true)
			-- end
		-- end
		-- tbImage = {}
	else

		local nCsvID = CSV_Equip.HeChengFormulaID
		local nStarLevel = CSV_Equip.HeChengFormulaStar
		local CSV_ItemBaseFormula = g_DataMgr:getCsvConfigByTwoKey("ItemBase", nCsvID, nStarLevel)
		local CSV_EquipHeChengMaterial = g_DataMgr:getEquipHeChengMaterialCsv(CSV_Equip.HeChengMaterialGroupID)
				
		local csvEquipHeChengYuanBao = g_DataMgr:getCsvConfig("EquipHeChengYuanBao") 
		for i = 1,imageNum do
			local param ={}
			param.widgetParent = Image_ContentPNL
			param.nNo = i --第几个位置
			if i == 1 then 
				param.nNeedNum = 1
				param.nCsvID = CSV_ItemBaseFormula.ID
				param.nStarLevel = CSV_ItemBaseFormula.StarLevel
				param.nMaterialName = "EquipWorkFormula"
				param.formulaType = CSV_ItemBaseFormula.FormulaType
			else
				local nIndex = i - 1
				param.nNeedNum = CSV_EquipHeChengMaterial["MaterialNum"..nIndex]--消耗数值,
				param.nCsvID = CSV_EquipHeChengMaterial["MaterialID"..nIndex]
				param.nStarLevel = CSV_EquipHeChengMaterial["MaterialStarLevel"..nIndex]
			end
			
			local image = g_SetMaterialBtn(param)
			table.insert(tbImage,image)
			
			if param.nCsvID > 0 then
				local nHasNum = g_Hero:getItemNumByCsv(param.nCsvID, param.nStarLevel)
				if nHasNum < param.nNeedNum then 
					if i == 1 then --卷轴
						recipeNum = (param.nNeedNum - nHasNum)  * csvEquipHeChengYuanBao[equipStarLevel].FormulaYuanBaoPrice
					else
						local num = param.nNeedNum - nHasNum
						itemNum = itemNum + math.max(num * 3 , 0) 
						yanbao = csvEquipHeChengYuanBao[equipStarLevel].FragYuanBaoPrice
					end
				end			
			end
		end

		--卷轴数量
		nCount = g_Hero:getItemNumByCsv(CSV_ItemBaseFormula.ID, CSV_ItemBaseFormula.StarLevel)
		--材料是否足够
		bMaterialEnough = g_CheckRefineMaterialByCsv(CSV_EquipHeChengMaterial)
		
		local strText = _T("铜钱合成")
		if g_Hero:getCoins() < CSV_EquipHeChengMaterial.NeedMoney then
			strText = _T("铜钱不足")
			g_SetLabelRed(BitmapLabel_NeedMoney,true)
		elseif nCount <= 0 or not bMaterialEnough then
			strText = _T("材料不足")
		else
			bEnable = true
			g_SetLabelRed(BitmapLabel_NeedMoney,false)
		end
		g_SetButtonEnabled(Button_Refine,bEnable,strText)
		price = recipeNum + (itemNum * yanbao)
		g_SetButtonEnabled(Button_YuanBaoHeCheng,price < g_Hero:getYuanBao(), _T("元宝合成"))
		

		BitmapLabel_NeedMoney_Refine:setText(CSV_EquipHeChengMaterial.NeedMoney)
	end
	
	local starLv = GameObj_Equip:getStarLevel()
	local equip = GameObj_Equip:getCsvEquip(starLv+1)
	
	local function onClickRefine(pSender, nTag)
		if nEquipID and nEquipID > 0 then
			if nCount <= 0 or not bMaterialEnough then
				g_ClientMsgTips:showMsgConfirm(_T("装备合成所需的材料不足"))
				return 
			elseif equip and level < equip.NeedLevel then  
				g_ClientMsgTips:showMsgConfirm(string.format(_T("该装备需要伙伴等级达到%d级才可以穿戴"), equip.NeedLevel))
				return 
			end
			
			--装备合成
			self:sendComposeEquipRequest(nEquipID,false)
		end
    end
	g_SetBtnWithGuideCheck(Button_Refine, 1, onClickRefine, bEnable)
	
	local function onClickYanBaoRefine(pSender, nTag)
	
		if not g_CheckYuanBaoConfirm(price,_T("您的元宝不足是否前往充值")) then return  end
		if equip and level < equip.NeedLevel then  
			g_ClientMsgTips:showMsgConfirm(string.format(_T("该装备需要伙伴等级达到%d级才可以穿戴"), equip.NeedLevel))
			return 
		end
		
		if GameObj_Equip:checkMaxRefineAndMaxStar() then  return end
		if price <= 0 then  return  end
		g_ClientMsgTips:showConfirm(string.format(_T("元宝合成需要花费%d元宝，是否合成？"), price), function() 
			--装备合成
			self:sendComposeEquipRequest(nEquipID,true)
		end)
	end
	
	-- by kakiwang
	-- g_SetBtnWithGuideCheck(Button_YuanBaoHeCheng, 1, onClickYanBaoRefine, price > 0)
	-- 元宝合成的功能效果不好，屏蔽
	Button_YuanBaoHeCheng:setVisible(false)
	Button_YuanBaoHeCheng:setTouchEnabled(false)

	BitmapLabel_NeedMoney:setText(price)
	g_SetLabelRed(BitmapLabel_NeedMoney,price > g_Hero:getYuanBao())
	
	g_adjustWidgetsRightPosition({BitmapLabel_NeedMoney_Refine, Image_Coins},2)
	g_adjustWidgetsRightPosition({BitmapLabel_NeedMoney, Image_YuanBao},2)
	
end


function Game_EquipRefine:refreshRefineWnd(nEquipID)
		
	local rootWidget = self.rootWidget
	if not rootWidget then return end
	
	local ImageView_EquipRefinePNL = tolua.cast(rootWidget:getChildByName("ImageView_EquipRefinePNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(ImageView_EquipRefinePNL:getChildByName("Image_ContentPNL"),"ImageView")
	local Image_LuDing = tolua.cast(Image_ContentPNL:getChildByName("Image_LuDing"),"ImageView")
	local Image_EuipeIconCircle = tolua.cast(Image_LuDing:getChildByName("Image_EuipeIconCircle"),"ImageView")
	local Image_Icon = tolua.cast(Image_EuipeIconCircle:getChildByName("Image_Icon"),"ImageView")
	
	g_ShowEquipDaZaoAnimation(Image_Icon)
	
	-- self:setRefineInfo(nEquipID)
	self:EquipShow(nEquipID)
end

--合成装备请求
function Game_EquipRefine:sendComposeEquipRequest(nEquipID,bFlag)
	local msg = zone_pb.ComposeEquipRequest()
	msg.equip_id = nEquipID
	msg.use_coupons = bFlag
	g_MsgMgr:sendMsg(msgid_pb.MSGID_COMPOSE_EQUIP_REQUEST,msg)
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_COMPOSE_EQUIP_REQUEST)
end

--合成
function Game_EquipRefine:ComposeEquip(tbMsg)
	cclog("-------ComposeEquip--------------")
	local msg = zone_pb.ComposeEquipResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))


	
 	local itemInfo = msg.material_info
	for i = 1,#itemInfo do 
		local cfgId = itemInfo[i].material_config_id	-- 材料的配置ID
		local mNum = itemInfo[i].material_num 		-- 材料的数量
		local starLevel = itemInfo[i].star_lv 			--材料的配置星级
		g_Hero:setItemByCsvIdAndStar(cfgId, starLevel, mNum)
	end
	
	--更新合成等级
	local tbEquip = g_Hero:getEquipObjByServID(msg.equip_id)
	tbEquip:setStarAndRefineLev(msg.star_lv)    

	
	if g_WndMgr:getWnd("Game_Equip1") then
		g_WndMgr:getWnd("Game_Equip1"):updateEquipIcon()
	end
	
	g_Hero:setCoins(msg.leave_money) --剩余铜钱
	--记录元宝消耗 不是元宝不会记录
	local yuanBao = g_Hero:getYuanBao() - msg.leave_coupons
	if yuanBao > 0 then
		gTalkingData:onPurchase(TDPurchase_Type.TDP_EQUIP_REFINE_RETAIN_LEVEL,1, yuanBao)	
	end
	g_Hero:setYuanBao( msg.leave_coupons) --剩余的元宝
	
	self:refreshRefineWnd(msg.equip_id)
	g_ErrorMsg:RelieveMsg(msgid_pb.MSGID_COMPOSE_EQUIP_REQUEST)
	
	
end


function Game_EquipRefine:showWndOpenAnimation(funcWndOpenAniCall)
	local ImageView_EquipRefinePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_EquipRefinePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(ImageView_EquipRefinePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_EquipRefine:showWndCloseAnimation(funcWndCloseAniCall)
	local ImageView_EquipRefinePNL = tolua.cast(self.rootWidget:getChildByName("ImageView_EquipRefinePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(ImageView_EquipRefinePNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

