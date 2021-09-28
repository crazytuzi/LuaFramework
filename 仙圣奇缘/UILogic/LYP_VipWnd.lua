--------------------------------------------------------------------------------------
-- 文件名:	LYP_ReChargeWnd.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2014-11-21 19:37
-- 版  本:	1.0
-- 描  述:	Vip界面
-- 应  用:   
---------------------------------------------------------------------------------------
Game_VIP = class("Game_VIP")
Game_VIP.__index = Game_VIP

local function onClick_Button_ShowReChage()
    g_WndMgr:openWnd("Game_ReCharge")
end

function Game_VIP:initWnd()
	self.cvs_VipLevelRightConfig_ = g_DataMgr:getCsvConfig("VipLevelRight")

	local Image_VIPPNL = tolua.cast(self.rootWidget:getChildByName("Image_VIPPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_VIPPNL:getChildByName("Image_ContentPNL"),"ImageView")
	
	local Button_ShowReChage = tolua.cast(Image_VIPPNL:getChildByName("Button_ShowReChage"), "Button")
	g_SetBtnWithEvent(Button_ShowReChage, 1, onClick_Button_ShowReChage, true)
	
	local Image_Check = tolua.cast(Button_ShowReChage:getChildByName("Image_Check"), "ImageView")
	local ccSpriteCheck = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSpriteCheck, 4)
	g_CreateFadeInOutAction(Image_Check, 0, 100, 0.5)
	
	local PageView_VIPLevelRights = tolua.cast(Image_ContentPNL:getChildByName("PageView_VIPLevelRights"),"PageView")
	PageView_VIPLevelRights:setVisible(true)
	PageView_VIPLevelRights:setClippingEnabled(true)
	
	local Button_ForwardPage = Image_VIPPNL:getChildByName("Button_ForwardPage")
	local Button_NextPage = Image_VIPPNL:getChildByName("Button_NextPage")
	local Panel_VIPLevelRightPage = PageView_VIPLevelRights:getChildByName("Panel_VIPLevelRightPage")
	Panel_VIPLevelRightPage:retain()
	
	local LuaPageView_VIPLevelRights = Class_LuaPageView:new()
	LuaPageView_VIPLevelRights:setModel(Panel_VIPLevelRightPage, Button_ForwardPage, Button_NextPage, 1.5, 1.5, true)
	LuaPageView_VIPLevelRights:setPageView(PageView_VIPLevelRights)
	LuaPageView_VIPLevelRights:registerUpdateFunction(handler(self,self.updatePageViewFunc))
	self.LuaPageView_VIPLevelRights = LuaPageView_VIPLevelRights

	local function freshCardFate(widget, nIndex)		
		local nIndex = self.LuaPageView_VIPLevelRights:getCurPageIndex()
		self:updateReCharge(nIndex)
	end
	LuaPageView_VIPLevelRights:registerClickEvent(freshCardFate)
	local nVipLev = g_VIPBase:getVIPLevelId()
	if nVipLev <= 0 then nVipLev = 1 end
	LuaPageView_VIPLevelRights:setCurPageIndex(nVipLev)
	
	local ImageView_Background1 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background1"), "ImageView")
	ImageView_Background1:loadTexture(getBackgroundJpgImg("Background_Money1"))
	local ImageView_Background2 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background2"), "ImageView")
	ImageView_Background2:loadTexture(getBackgroundPngImg("Background_Money2"))
	local ImageView_Background3 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background3"), "ImageView")
	ImageView_Background3:loadTexture(getBackgroundPngImg("Background_Money3"))
end 

function Game_VIP:updatePageViewFunc(Panel_VIPLevelRightPage, nVIPLevel)

    local bIsVIPRightOpen = (g_Hero:getVIPLevelID() >= nVIPLevel)
    local CSV_VipLevelRight = g_DataMgr:getCsvConfig_SecondKeyTableData("VipLevelRight",nVIPLevel)--self.cvs_VipLevelRightConfig_[nVIPLevel]

	
    local ListView_VIPLevelRightList = tolua.cast(Panel_VIPLevelRightPage:getChildByName("ListView_VIPLevelRightList"),"ListViewEx") 
	local Image_VipLevelRightRow = tolua.cast(ListView_VIPLevelRightList:getChildByName("Image_VipLevelRightRow"),"ImageView")
	
    local Panel_VipLevelRightRow = ListView_VIPLevelRightList:getChildByName("Panel_VipLevelRightRow")
    local LuaListView_VIPLevelRightList = Class_LuaListView:new()
    LuaListView_VIPLevelRightList:setListView(ListView_VIPLevelRightList)
    LuaListView_VIPLevelRightList:setModel(Image_VipLevelRightRow)
	
	local Image_VIPLevelRightItem1 = tolua.cast(Image_VipLevelRightRow:getChildByName("Image_VIPLevelRightItem1"),"ImageView")
	local Button_VIPLevelRightItem = tolua.cast(Image_VIPLevelRightItem1:getChildByName("Button_VIPLevelRightItem"),"Button")
	Button_VIPLevelRightItem:setVisible(false)
	
	local function onPressed_Button_VIPLevelRightItem(pSender, nTag)
		local nVipLev = nTag%100
		local nIndex = math.floor(nTag/100)
		local CSV_VipLevelRight = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("VipLevelRight",nVipLev,nIndex)--self.cvs_VipLevelRightConfig_[nVipLev]
		if CSV_VipLevelRight then
			g_ClientMsgTips:showMsgConfirm(CSV_VipLevelRight.VIPRightDesc)
		end
	end
	
    local function updateListViewFunc(Image_VipLevelRightRow, nRowIndex)
        local nBegin = (nRowIndex - 1) * 4
        for i = 1, 4 do		
            local nVIPRightType = nBegin + i
			
			local Image_VIPLevelRightItem = tolua.cast(Image_VipLevelRightRow:getChildByName("Image_VIPLevelRightItem"..i),"ImageView")
			local Image_VIPRightIcon = tolua.cast(Image_VIPLevelRightItem:getChildByName("Image_VIPRightIcon"),"Button")
			if Image_VIPRightIcon then
				if nVIPRightType <= #CSV_VipLevelRight then
					Image_VIPRightIcon:setVisible(true)
					self:setVipRight(Image_VIPRightIcon, CSV_VipLevelRight[nVIPRightType], bIsVIPRightOpen)
					g_SetBtnWithPressImage(Image_VIPRightIcon, nVIPRightType*100+nVIPLevel, onPressed_Button_VIPLevelRightItem, true, 1)
				else
					Image_VIPRightIcon:setVisible(false)
				end
			else
				if nVIPRightType <= #CSV_VipLevelRight then
					local BtnVIPLevelRightItem = tolua.cast(Button_VIPLevelRightItem:clone(),"Button")
					BtnVIPLevelRightItem:setVisible(true)
					Image_VIPLevelRightItem:addChild(BtnVIPLevelRightItem)
					BtnVIPLevelRightItem:setName("Image_VIPRightIcon")
					self:setVipRight(BtnVIPLevelRightItem, CSV_VipLevelRight[nVIPRightType], bIsVIPRightOpen)
					g_SetBtnWithPressImage(BtnVIPLevelRightItem, nVIPRightType*100+nVIPLevel, onPressed_Button_VIPLevelRightItem, true, 1)
				end
			end
        end
    end
	
    LuaListView_VIPLevelRightList:setUpdateFunc(updateListViewFunc)
    LuaListView_VIPLevelRightList:updateItems(math.floor((#CSV_VipLevelRight-1)/4)+1) 
end

function Game_VIP:setVipRight(Image_VIPRightIcon, CSV_VipLevelRight, bIsVIPRightOpen)
	
	local Image_Locker =  tolua.cast(Image_VIPRightIcon:getChildByName("Image_Locker"),"ImageView")
	Image_Locker:setVisible(not bIsVIPRightOpen)
	
	if not CSV_VipLevelRight.VIPRightIconBase or CSV_VipLevelRight.VIPRightIconBase == "" then
		Image_VIPRightIcon:setVisible(false)
		return 
	end
	
	local Label_VIPName =  tolua.cast(Image_VIPRightIcon:getChildByName("Label_VIPName"),"Label")
	Label_VIPName:setText(CSV_VipLevelRight.VIPRightName)
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_VIPName:setFontSize(17)
	end
	local CCNode_VIPName = tolua.cast(Label_VIPName:getVirtualRenderer(), "CCLabelTTF")
	CCNode_VIPName:disableShadow(true)

	local Label_Tip =  tolua.cast(Image_VIPRightIcon:getChildByName("Label_Tip"),"Label")
	Label_Tip:setText(CSV_VipLevelRight.VIPRightTip)
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_Tip:setFontSize(18)
	end
	local Image_Icon =  tolua.cast(Image_VIPRightIcon:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getImgByPath(CSV_VipLevelRight.VIPRightIconPath,CSV_VipLevelRight.VIPRightIcon))

	local Image_Check =  tolua.cast(Image_VIPRightIcon:getChildByName("Image_Check"),"ImageView")
	Image_Check:setVisible(true)
	Image_Check:loadTexture(getShopMallImg(CSV_VipLevelRight.VIPRightIconBase))
	

	
	g_setBtnLoadTexture(Image_VIPRightIcon,{
		normal = getShopMallImg(CSV_VipLevelRight.VIPRightIconBase),
		pressed = getShopMallImg(CSV_VipLevelRight.VIPRightIconBase),
		disabled = getShopMallImg(CSV_VipLevelRight.VIPRightIconBase),
	})
end

function Game_VIP:updateReCharge(willVipLevel)
	local Image_VIPPNL = tolua.cast(self.rootWidget:getChildByName("Image_VIPPNL"),"ImageView")
	--没有VIP等级 Image_NoVipPNL
	local Image_NoVipPNL = tolua.cast(Image_VIPPNL:getChildByName("Image_NoVipPNL"),"ImageView")
	--玩家无VIP等级，未激活的VIP页面 Image_HasVipNoActivatePNL
	local Image_HasVipNoActivatePNL = tolua.cast(Image_VIPPNL:getChildByName("Image_HasVipNoActivatePNL"),"ImageView")
	--玩家有VIP等级，已激活的VIP页面 Image_HasVipActivatePNL
	local Image_HasVipActivatePNL = tolua.cast(Image_VIPPNL:getChildByName("Image_HasVipActivatePNL"),"ImageView")

	if not willVipLevel then willVipLevel = 1 end
	local nVipLev = g_VIPBase:getVIPLevelId()
	if nVipLev <= 0 then 
		--还没有vip
		if willVipLevel > 1 then 
			Image_NoVipPNL:setVisible(false);
			Image_HasVipActivatePNL:setVisible(false);
			Image_HasVipNoActivatePNL:setVisible(true);
			self:noVipNoActivateInfoPNL(Image_HasVipNoActivatePNL,nVipLev,willVipLevel)
		else
			Image_HasVipNoActivatePNL:setVisible(false);
			Image_HasVipActivatePNL:setVisible(false);
			Image_NoVipPNL:setVisible(true);
			self:noVipInfoPNL(Image_NoVipPNL,nVipLev);
		end
	elseif nVipLev > 0 then 
		Image_NoVipPNL:setVisible(false)
		if willVipLevel > nVipLev then 
			Image_HasVipActivatePNL:setVisible(false);
			Image_HasVipNoActivatePNL:setVisible(true);
			self:noVipNoActivateInfoPNL(Image_HasVipNoActivatePNL,nVipLev,willVipLevel)
		else
			Image_HasVipNoActivatePNL:setVisible(false);
			Image_HasVipActivatePNL:setVisible(true);
			self:noVipActivateInfoPNL(Image_HasVipActivatePNL,nVipLev,willVipLevel)
		end

	end
	
end


function Game_VIP:closeWnd()
	self.cvs_VipLevelRightConfig_ = nil
	
	local ImageView_Background1 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background1"), "ImageView")
	ImageView_Background1:loadTexture(getUIImg("Blank"))
	local ImageView_Background2 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background2"), "ImageView")
	ImageView_Background2:loadTexture(getUIImg("Blank"))
	local ImageView_Background3 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background3"), "ImageView")
	ImageView_Background3:loadTexture(getUIImg("Blank"))
end

--显示主界面的伙伴详细介绍界面
function Game_VIP:openWnd()
    self:updateReCharge()
    self.LuaPageView_VIPLevelRights:updatePageView(#self.cvs_VipLevelRightConfig_)
end

--没有VIP等级 Image_NoVipPNL
function Game_VIP:noVipInfoPNL(Image_NoVipPNL,nVipLevel)
	local CSV_VipLevelRight = g_DataMgr:getCsvConfig_FirstKeyData("VipLevelRight",1)--self.cvs_VipLevelRightConfig_[1][1]
	local Label_Tip1 = tolua.cast(Image_NoVipPNL:getChildByName("Label_Tip1"),"Label")
	local CCNode_Tip1 = tolua.cast(Label_Tip1:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tip1:disableShadow(true)
	
	local Image_YuanBao = tolua.cast(Image_NoVipPNL:getChildByName("Image_YuanBao"),"ImageView")
	
	--多少钱开启VIP
	local Label_NeedCharge = tolua.cast(Image_NoVipPNL:getChildByName("Label_NeedCharge"),"Label")
	Label_NeedCharge:setText(string.format("%d",CSV_VipLevelRight.ExpMax))
	local CCNode_NeedCharge = tolua.cast(Label_NeedCharge:getVirtualRenderer(), "CCLabelTTF")
	CCNode_NeedCharge:disableShadow(true)
	
	local Label_Tip2 = tolua.cast(Image_NoVipPNL:getChildByName("Label_Tip2"),"Label")
	local CCNode_Tip2 = tolua.cast(Label_Tip2:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tip2:disableShadow(true)
	
	local Image_VIPLevel = tolua.cast(Image_NoVipPNL:getChildByName("Image_VIPLevel"),"ImageView")
	Image_VIPLevel:loadTexture(getShopMallImg("VIP"..nVipLevel+1))
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		local size = 18
		Label_Tip1:setFontSize(size)
		Image_YuanBao:setScale(0.8)
		Label_NeedCharge:setFontSize(size)
		Label_Tip2:setFontSize(size)
		Image_VIPLevel:setScale(0.8)
	
	end
	
	g_AdjustWidgetsPosition({Label_Tip1,Image_YuanBao,Label_NeedCharge,Label_Tip2,Image_VIPLevel}, 2)
end

--玩家无VIP等级，未激活的VIP页面 Image_HasVipNoActivatePNL
-- @param curVipLevel 当前玩家VIP等级
--@param willVipLevel 滑动到的VIP等级界面
function Game_VIP:noVipNoActivateInfoPNL(Image_HasVipNoActivatePNL,curVipLevel,willVipLevel)

	local CSV_VipLevelRight_willVipLevel =  g_DataMgr:getCsvConfig_FirstKeyData("VipLevelRight",willVipLevel)--self.cvs_VipLevelRightConfig_[willVipLevel][1]
	local willNedd = 0
	if CSV_VipLevelRight_willVipLevel then 
		willNedd = CSV_VipLevelRight_willVipLevel.ExpMax
	end
	
	local Label_Tip1 = tolua.cast(Image_HasVipNoActivatePNL:getChildByName("Label_Tip1"),"Label")
	local CCNode_Tip1 = tolua.cast(Label_Tip1:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tip1:disableShadow(true)
	
	local Label_VIPLevel = tolua.cast(Image_HasVipNoActivatePNL:getChildByName("Label_VIPLevel"),"Label")
	Label_VIPLevel:setText(_T("VIP")..curVipLevel)
	local CCNode_VIPLevel = tolua.cast(Label_VIPLevel:getVirtualRenderer(), "CCLabelTTF")
	CCNode_VIPLevel:disableShadow(true)
	
	local Label_Tip2 = tolua.cast(Image_HasVipNoActivatePNL:getChildByName("Label_Tip2"),"Label")
	local CCNode_Tip2 = tolua.cast(Label_Tip2:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tip2:disableShadow(true)
	
	local Image_YuanBao = tolua.cast(Image_HasVipNoActivatePNL:getChildByName("Image_YuanBao"),"ImageView")
	local Label_NeedCharge = tolua.cast(Image_HasVipNoActivatePNL:getChildByName("Label_NeedCharge"),"Label")
	Label_NeedCharge:setText(willNedd - g_Hero.tbMasterBase.nTotalChargeYuanBao)
	local CCNode_NeedCharge = tolua.cast(Label_NeedCharge:getVirtualRenderer(), "CCLabelTTF")
	CCNode_NeedCharge:disableShadow(true)
	
	local Label_Tip3 = tolua.cast(Image_HasVipNoActivatePNL:getChildByName("Label_Tip3"),"Label")
	local CCNode_Tip3 = tolua.cast(Label_Tip3:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tip3:disableShadow(true)
	
	local Image_VIPLevel = tolua.cast(Image_HasVipNoActivatePNL:getChildByName("Image_VIPLevel"),"ImageView")
	Image_VIPLevel:loadTexture(getShopMallImg("VIP"..willVipLevel))
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		local size = 18
		Label_Tip1:setFontSize(size)
		Label_VIPLevel:setFontSize(size)
		Label_Tip2:setFontSize(size)
		Image_YuanBao:setScale(0.8)
		Label_NeedCharge:setFontSize(size)
		Label_Tip3:setFontSize(size)
		Image_VIPLevel:setScale(0.8)
	
	end
	
	g_AdjustWidgetsPosition({Label_Tip1,Label_VIPLevel,Label_Tip2,Image_YuanBao,Label_NeedCharge,Label_Tip3,Image_VIPLevel}, 2)
end

--玩家有VIP等级，已激活的VIP页面 Image_HasVipActivatePNL
-- @param curVipLevel 当前玩家VIP等级
--@param willVipLevel 滑动到的VIP等级界面
function Game_VIP:noVipActivateInfoPNL(Image_HasVipActivatePNL,curVipLevel,willVipLevel)

	local Label_Tip1 = tolua.cast(Image_HasVipActivatePNL:getChildByName("Label_Tip1"),"Label")
	local CCNode_Tip1 = tolua.cast(Label_Tip1:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tip1:disableShadow(true)
	
	local Label_VIPLevel = tolua.cast(Image_HasVipActivatePNL:getChildByName("Label_VIPLevel"),"Label")
	Label_VIPLevel:setText(_T("VIP")..curVipLevel)
	local CCNode_VIPLevel = tolua.cast(Label_VIPLevel:getVirtualRenderer(), "CCLabelTTF")
	CCNode_VIPLevel:disableShadow(true)
	
	local Label_Tip2 = tolua.cast(Image_HasVipActivatePNL:getChildByName("Label_Tip2"),"Label")
	local CCNode_Tip2 = tolua.cast(Label_Tip2:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tip2:disableShadow(true)
	
	local Image_VIPLevel = tolua.cast(Image_HasVipActivatePNL:getChildByName("Image_VIPLevel"),"ImageView")
	Image_VIPLevel:loadTexture(getShopMallImg("VIP"..willVipLevel))
	
	local Label_Tip3 = tolua.cast(Image_HasVipActivatePNL:getChildByName("Label_Tip3"),"Label")
	local CCNode_Tip3 = tolua.cast(Label_Tip3:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tip3:disableShadow(true)

	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		local size = 18
		Label_Tip1:setFontSize(size)
		Label_VIPLevel:setFontSize(size)
		Label_Tip2:setFontSize(size)
		Label_Tip3:setFontSize(size)
		Image_VIPLevel:setScale(0.8)
	
	end
	g_AdjustWidgetsPosition({Label_Tip1,Label_VIPLevel,Label_Tip2,Image_VIPLevel,Label_Tip3}, 2)
end

function Game_VIP:ModifyWnd_viet_VIET()
    local Image_HasVipNoActivatePNL = tolua.cast(self.rootWidget:getChildAllByName("Image_HasVipNoActivatePNL"),"ImageView")
    Image_HasVipNoActivatePNL:setPositionX(-310)
    local Image_HasVipActivatePNL = tolua.cast(self.rootWidget:getChildAllByName("Image_HasVipActivatePNL"),"ImageView")
    Image_HasVipActivatePNL:setPositionX(-310)
    local Image_NoVipPNL = tolua.cast(self.rootWidget:getChildAllByName("Image_NoVipPNL"),"ImageView")
    Image_NoVipPNL:setPositionX(-310)
    --[[local Label_Tip1 = tolua.cast(Image_HasVipNoActivatePNL:getChildAllByName("Label_Tip1"), "Label")
    local Label_VIPLevel = tolua.cast(Image_HasVipNoActivatePNL:getChildAllByName("Label_VIPLevel"), "Label")
    local Label_Tip2 = tolua.cast(Image_HasVipNoActivatePNL:getChildAllByName("Label_Tip2"), "Label")
    local Image_YuanBao = tolua.cast(Image_HasVipNoActivatePNL:getChildAllByName("Image_YuanBao"), "ImageView")
    local Label_NeedCharge = tolua.cast(Image_HasVipNoActivatePNL:getChildAllByName("Label_NeedCharge"), "Label")
    local Label_Tip3 = tolua.cast(Image_HasVipNoActivatePNL:getChildAllByName("Label_Tip3"), "Label")
    local Image_VIPLevel = tolua.cast(Image_HasVipNoActivatePNL:getChildAllByName("Image_VIPLevel"), "ImageView")
    g_AdjustWidgetsPosition({Label_Tip1, Label_VIPLevel, Label_Tip2, Image_YuanBao, Label_NeedCharge, Label_Tip3, Image_VIPLevel},1)]]

end

