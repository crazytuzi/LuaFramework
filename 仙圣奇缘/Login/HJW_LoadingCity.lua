--------------------------------------------------------------------------------------
-- 文件名:	HJW_LoadingCity.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2015-06-30 
-- 版  本:	1.0
-- 描  述:	
-- 应  用: 
---------------------------------------------------------------------------------------
-- Game_LoadingCity = class("Game_LoadingCity", function() return CCScene:create() end)
Game_LoadingCity = class("Game_LoadingCity",function() return TouchGroup:create() end)
Game_LoadingCity.__index = Game_LoadingCity

local hundred = 100           
local flag = true
local rootLayout_ = nil
g_strAndroidTS = "close"   --安卓提审
g_strStandAloneGame = "close" --开启单机
g_bVersionTS_0_0_ = "正式" --苹果提审
g_NeelDisableVersion = "xiaoaoIOS_2.0.0"

function Game_LoadingCity:ctor()
	--add by zgj
	g_DbMgr:initBaseTable()
	g_SALMgr:creat()
	--over
	
	local order = msgid_pb.MSGID_LOGIN_STEP_OK
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestLoginStepOKResponse))
	self.endCount = 1

	--
	self.nMaxPage = 0
	self.nCurPage = 1
	self.nBegPage = 1
	self.nPrvPage = 1

	self.formInstance = nil
end


--创建界面逻辑对象
function Game_LoadingCity:CreateFormInstance()
	
	if g_Cfg.Platform  == kTargetWindows then --Windows
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			self.formInstance = VietLoadingForm:new()
		elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
			if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
				self.formInstance = TaiwaiLoadingForm_SYL:new()
			else
				self.formInstance = TaiwaiLoadingForm:new()
			end
		else
			if g_IsXiaoXiaoXianSheng then
				self.formInstance = XianShengQingYuanForm:new()
			elseif g_IsXianJianQiTan then
				self.formInstance = XianJianQiTanLoadingForm:new()
			else
				self.formInstance = AndroidLoadingForm:new()
			end
		end
	elseif g_Cfg.Platform  == kTargetAndroid then --Android
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			self.formInstance = VietLoadingForm:new()
		elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
			if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
				self.formInstance = TaiwaiLoadingForm_SYL:new()
			else
				self.formInstance = TaiwaiLoadingForm:new()
			end
		else
			if g_IsXiaoXiaoXianSheng then
				self.formInstance = XianShengQingYuanForm:new()
			elseif g_IsXianJianQiTan then
				self.formInstance = XianJianQiTanLoadingForm:new()
			else
				self.formInstance = AndroidLoadingForm:new()
			end
		end
	else --iOS越狱
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			self.formInstance = VietLoadingForm:new()
		elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
			if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
				self.formInstance = TaiwaiLoadingForm_SYL:new()
			else
				self.formInstance = TaiwaiLoadingForm:new()
			end
		else
			if g_IsXiaoXiaoXianSheng then
				self.formInstance = XianShengQingYuanForm:new()
			elseif g_IsXianJianQiTan then
				self.formInstance = XianJianQiTanLoadingForm:new()
			else
				self.formInstance = IOSLoadingForm:new()
			end
		end
	end

	self.formInstance:InitForm(self)
end


function Game_LoadingCity:initView()
	--在重新登录的时候 清空下 方便保存的星级 数量
	g_MapInfo.tbInfo = {}

	---
	self:CreateFormInstance()
	
	self.rootLayout = GUIReader:shareReader():widgetFromJsonFile("Game_LoadingCity.json")
	self.rootLayout:setTouchEnabled(true)
	self:addWidget(self.rootLayout)

	rootLayout_ = self.rootLayout
	
	self.formInstance:showGameLogo(self.rootLayout)
	
	local Image_LoadingCity = tolua.cast(self.rootLayout:getChildByName("Image_LoadingCity"), "ImageView")
	Image_LoadingCity:setVisible(true)
	
	local ProgressBar_LoadingCity = tolua.cast(Image_LoadingCity:getChildByName("ProgressBar_LoadingCity"), "LoadingBar")
	local Label_Percent = tolua.cast(Image_LoadingCity:getChildByName("Label_Percent"), "Label")
	Label_Percent:setText("0%")
	ProgressBar_LoadingCity:setPercent(0)
	
	local Button_EnterGame = tolua.cast(self.rootLayout:getChildByName("Button_EnterGame"), "Button")
	Button_EnterGame:setVisible(false)
	
	--掉落物品窗口 刷新
	local CSV_ActivityOnlineRechargeTimeReward = g_DataMgr:getCsvConfigByOneKey("ActivityOnlineRechargeTimeReward", 1)
	local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", CSV_ActivityOnlineRechargeTimeReward.DropClientID)

	local Image_GongGaoPNL2 = tolua.cast(self.rootLayout:getChildByName("Image_GongGaoPNL2"), "ImageView")
	for i = 1, #CSV_DropSubPackClient do
		local Image_DropResource = tolua.cast(Image_GongGaoPNL2:getChildByName("Image_DropResource"..i), "ImageView")
		local itemModel = g_CloneDropItemModel(CSV_DropSubPackClient[i])
		itemModel:setPositionXY(0,0)
		Image_DropResource:addChild(itemModel)
	end

	
	self.formInstance:showForm()
	self:pageTurning()

	--初始化 页面逻辑
	self.nMaxPage = 0
	while true do
		local WndName = "Image_GongGaoPNL"..(self.nMaxPage+1)
		local widget = self.rootLayout:getChildByName(WndName)
		if widget == nil then break end
		self.nMaxPage = self.nMaxPage + 1

		widget:setVisible(self.nCurPage == self.nMaxPage)
	end
	
	self:pageIndex()

	local Button_Next = tolua.cast(self.rootLayout:getChildByName("Button_Next"), "Button")
	local Button_Forward = tolua.cast(self.rootLayout:getChildByName("Button_Forward"), "Button")
	if Button_Next then
		Button_Next:setVisible(self.nCurPage < self.nMaxPage)
	end

	if Button_Forward then
		Button_Forward:setVisible(self.nCurPage > self.nBegPage)
	end
end

function Game_LoadingCity:RefreshLoadingForm()
	
	cclog("Game_LoadingCity:RefreshLoadingForm self.nPrvPage="..self.nPrvPage.." self.nCurPage="..self.nCurPage.." self.nMaxPage="..self.nMaxPage)
	local wgtName = "Image_GongGaoPNL"..self.nCurPage
	local Image_GongGaoPNL = tolua.cast(self.rootLayout:getChildByName(wgtName), "ImageView")

	wgtName = "Image_GongGaoPNL"..self.nPrvPage
	local Image_GongGaoOut = tolua.cast(self.rootLayout:getChildByName(wgtName), "ImageView")

	local ScrollView_Notice = tolua.cast(Image_GongGaoPNL:getChildByName("ScrollView_Notice"), "ScrollView")
	if ScrollView_Notice then
		ScrollView_Notice:setVisible(true)
	end

	if self.nCurPage == self.nPrvPage then
		Image_GongGaoPNL:setVisible(true)

	elseif Image_GongGaoOut ~= nil and Image_GongGaoPNL ~= nil then
		Image_GongGaoPNL:setVisible(true)
		Image_GongGaoOut:setVisible(true)
		Image_GongGaoOut:setCascadeOpacityEnabled(true)
		Image_GongGaoPNL:setCascadeOpacityEnabled(true)
		g_AnimationFadeOut(Image_GongGaoOut)
		g_AnimationFadeTo(Image_GongGaoPNL)
	end
end


function Game_LoadingCity:requestLoginStepOKResponse(tbMsg)
	g_MsgNetWorkWarning:closeNetWorkWarning()
	
	local msgDetail = zone_pb.LoginStepOK()
	msgDetail:ParseFromString(tbMsg.buffer)
	
	local flag = false
	local count = 0

	local function Percent()
		if rootLayout_ then 
			local Image_LoadingCity = tolua.cast(rootLayout_:getChildByName("Image_LoadingCity"), "ImageView")
			local ProgressBar_LoadingCity = tolua.cast(Image_LoadingCity:getChildByName("ProgressBar_LoadingCity"), "LoadingBar")
			local Label_Percent = tolua.cast(Image_LoadingCity:getChildByName("Label_Percent"), "Label")

			count = count + 10
			if count > hundred then 
				flag = true
				count = hundred
			end
			
			if ProgressBar_LoadingCity and ProgressBar_LoadingCity:isExsit() then
				ProgressBar_LoadingCity:setPercent(count)
			end
			
			if Label_Percent and Label_Percent:isExsit() then
				Label_Percent:setText(count.."%")
			end
			
			if flag then 
				flag = false
				rootLayout_:stopAllActions()
				
				if Image_LoadingCity and Image_LoadingCity:isExsit() then
					Image_LoadingCity:setVisible(false)
				end
				
				--进入游戏
				local function onClickLoadingHome(pSender,eventType)
					if eventType ==ccs.TouchEventType.ended then
						g_WndMgr:openWnd("Game_Home")
						CCDirector:sharedDirector():replaceScene(mainWnd)
						g_FormMsgSystem:SendFormMsg(FormMsg_MainForm_Refresh, nil)
					end
				end
				local Button_EnterGame = tolua.cast(rootLayout_:getChildByName("Button_EnterGame"), "Button")
				Button_EnterGame:setTouchEnabled(true)
				Button_EnterGame:setVisible(true)
				Button_EnterGame:addTouchEventListener(onClickLoadingHome)
				
			end
		end
	end
	
	local arrAct = CCArray:create()
	-- local DelayTime = CCDelayTime:create(1)
	local funcCall = CCCallFuncN:create(Percent)
	arrAct:addObject(funcCall)
	-- arrAct:addObject(DelayTime)
	local actionquence = CCSequence:create(arrAct)
	local Forever = CCRepeatForever:create(actionquence)
	self.rootLayout:runAction(Forever)
	
end

function Game_LoadingCity:ShowGameNotic()
	local wgtName = "Image_GongGaoPNL1"
	local Image_GongGaoPNL = tolua.cast(self.rootLayout:getChildByName(wgtName), "ImageView")
	local ScrollView_Notice = tolua.cast(Image_GongGaoPNL:getChildByName("ScrollView_Notice"), "ScrollView")
	local Label_NoticeTitleDesc = tolua.cast(Image_GongGaoPNL:getChildByName("Label_NoticeTitleDesc"), "Label")
	local ScrollView_Notice = tolua.cast(Image_GongGaoPNL:getChildByName("ScrollView_Notice"), "ScrollView")
	local Label_Content = tolua.cast(ScrollView_Notice:getChildByName("Label_Content1"), "Label")
    
	ScrollView_Notice:setBounceEnabled(true)
	ScrollView_Notice:setClippingEnabled(true)
	ScrollView_Notice:setAnchorPoint(ccp(0,1))
	ScrollView_Notice:setPosition(ccp(-400, 120))
	
    local curGongGao
    if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET then
        curGongGao = gNoticeConfig_Vietnam[1]
    elseif g_LggV.LanguageVer == eLanguageVer.LANGUAGE_cht_Taiwan then
		if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
			curGongGao = gNoticeConfig_Taiwan_SYL[1]
		else
			curGongGao = gNoticeConfig_Taiwan[1]
		end 
	else
		if g_IsXiaoXiaoXianSheng ~= nil and g_IsXiaoXiaoXianSheng == true then
			if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then  --提审
				curGongGao = gNoticeConfig_China_XiaoXiaoXianSheng[1]
				curGongGao["content"] = {""}
			elseif g_strAndroidTS == "open" then
				curGongGao = gNoticeConfig_China_XiaoXiaoXianSheng[1]
				curGongGao["content"] = {""}
			else
				curGongGao = gNoticeConfig_China_XiaoXiaoXianSheng[1]
			end
		else
			if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then  --提审
				curGongGao = gNoticeConfig_China[1]
				curGongGao["content"] = {""}
			elseif g_strAndroidTS == "open" then
				curGongGao = gNoticeConfig_China[1]
				curGongGao["content"] = {""}
            elseif g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_VIVO 
                or g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_HUAWEI then 
                curGongGao = gNoticeConfig_shandang[1]
			else
				curGongGao = gNoticeConfig_China[1]
			end
		end
    end

    local width = gCreateColorLable(Label_NoticeTitleDesc, curGongGao["title"])
    local desc_x = Label_NoticeTitleDesc:getPosition().x - width/2
    local desc_y = Label_NoticeTitleDesc:getPosition().y - Label_NoticeTitleDesc:getContentSize().height/2
    Label_NoticeTitleDesc:setPosition(ccp(desc_x, desc_y))
    Label_Content:setFontSize(curGongGao["contentfontsize"])
    local scrool_height = Label_Content:getContentSize().height/2 
    for i = 1 ,#curGongGao["content"] do
        scrool_height = scrool_height + Label_Content:getContentSize().height
    end

    --如果当前公告高度小于显示框的高度，则滑动区域大小等于显示框的高度
    if scrool_height < ScrollView_Notice:getContentSize().height then
        scrool_height = ScrollView_Notice:getContentSize().height
    end
    ScrollView_Notice:setInnerContainerSize(CCSizeMake(ScrollView_Notice:getInnerContainerSize().width, scrool_height))
    local content_x = Label_Content:getPosition().x
    local content_y = scrool_height
    local content
    for i = 1 ,#curGongGao["content"] do
        content = tolua.cast(Label_Content:clone(), "Label")
        content:removeAllChildren()
        content:setFontSize(curGongGao["contentfontsize"]) 
        gCreateColorLable(content, curGongGao["content"][i])
        content:setVisible(true) 
        content:setPosition(ccp(content_x, content_y - content:getContentSize().height*1.25))
		content_y = content_y - content:getContentSize().height 
        ScrollView_Notice:addChild(content)
	end
    
    Label_Content:setVisible(false)
	return true
end

function Game_LoadingCity:pageIndex()

	local sztb = ""
	for i = 1 , self.nMaxPage do
		if i == self.nCurPage then
			sztb = sztb.."1"
		else
			sztb = sztb.."2"
		end
	end
	local AtlasLabel_PageIndex = tolua.cast(self.rootLayout:getChildByName("AtlasLabel_PageIndex"), "LabelAtlas")
	AtlasLabel_PageIndex:setStringValue(sztb)
end

function Game_LoadingCity:pageTurning()

	local Button_Next = tolua.cast(self.rootLayout:getChildByName("Button_Next"), "Button")
	local Button_Forward = tolua.cast(self.rootLayout:getChildByName("Button_Forward"), "Button")
	LandRActionButton(Button_Next, nil, nil, nil, bIsNotFade)
	LandRActionButton(Button_Forward, nil, nil, nil, bIsNotFade)

	local function onClickNext(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then 
			Button_Forward:setVisible(true)
			self.nPrvPage = self.nCurPage
			self.nCurPage = self.nCurPage + 1
			if self.nCurPage >= self.nMaxPage then
				self.nCurPage = self.nMaxPage
				Button_Next:setVisible(false)
			end
			self:RefreshLoadingForm()
			self:pageIndex()
			
		end
	end
	Button_Next:setTouchEnabled(true)
	Button_Next:addTouchEventListener(onClickNext)
	
	
	local function onClickForward(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then 
			Button_Next:setVisible(true)

			self.nPrvPage = self.nCurPage
			self.nCurPage  = self.nCurPage - 1
			if self.nCurPage <= self.nBegPage then
				self.nCurPage = self.nBegPage
				Button_Forward:setVisible(false)
			end
			self:RefreshLoadingForm()
			self:pageIndex()
		end
	end
	
	Button_Forward:setTouchEnabled(true)
	Button_Forward:addTouchEventListener(onClickForward)
end


-----------------------------区分android iOS  NiTianJi 不同的loading界面----------
LoadingFormBase = class("LoadingFormBase")
LoadingFormBase.__index = LoadingFormBase

function LoadingFormBase:ctor()
	self.object = nil
end

function LoadingFormBase:InitForm(LoadingCity)
	self.object = LoadingCity
end

--派生类必须重载----------
function LoadingFormBase:showForm()
end


function LoadingFormBase:showGameLogo(wgt)
end

--------android-----------------
AndroidLoadingForm = class("AndroidLoadingForm",function() return LoadingFormBase:new() end)
AndroidLoadingForm.__index = AndroidLoadingForm

function AndroidLoadingForm:showGameLogo(wgt)
	for i = 1, 2 do
		local Image_GongGaoPNL = tolua.cast(wgt:getChildByName("Image_GongGaoPNL"..i), "ImageView")
		local Image_Logo = tolua.cast(Image_GongGaoPNL:getChildByName("Image_Logo"), "ImageView")
		Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
	end
end

function AndroidLoadingForm:showForm()
	self.object.nCurPage = 1
	if self.object:ShowGameNotic() then --有服务器公告从第一页显示
		self.object.nCurPage = 1
	end
	
	self.object.nBegPage = self.object.nCurPage
end


------------------ios-----------------
IOSLoadingForm = class("IOSLoadingForm",function() return LoadingFormBase:new() end)
IOSLoadingForm.__index = IOSLoadingForm


function IOSLoadingForm:showGameLogo(wgt)
	for i = 1, 2 do
		local Image_GongGaoPNL = tolua.cast(wgt:getChildByName("Image_GongGaoPNL"..i), "ImageView")
		local Image_Logo = tolua.cast(Image_GongGaoPNL:getChildByName("Image_Logo"), "ImageView")
		Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
	end
end

function IOSLoadingForm:showForm()

	self.object.nCurPage = 1
	if self.object:ShowGameNotic() then --有服务器公告从第一页显示
		self.object.nCurPage = 1
	end
	self.object.nBegPage = self.object.nCurPage
end


-----------------NiTianJi-------------------
XianShengQingYuanForm = class("XianShengQingYuanForm",function() return LoadingFormBase:new() end)
XianShengQingYuanForm.__index = XianShengQingYuanForm


function XianShengQingYuanForm:showGameLogo(wgt)
	for i = 1, 2 do
		local Image_GongGaoPNL = tolua.cast(wgt:getChildByName("Image_GongGaoPNL"..i), "ImageView")
		local Image_Logo = tolua.cast(Image_GongGaoPNL:getChildByName("Image_Logo"), "ImageView")
		Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XiaoXiaoXianSheng"))
	end
end

function XianShengQingYuanForm:showForm()

	self.object.nCurPage = 1
	if self.object:ShowGameNotic() then --有服务器公告从第一页显示
		self.object.nCurPage = 1
	end
	self.object.nBegPage = self.object.nCurPage
end

-----------------VIET-------------------
VietLoadingForm = class("VietLoadingForm",function() return LoadingFormBase:new() end)
VietLoadingForm.__index = VietLoadingForm


function VietLoadingForm:showGameLogo(wgt)
	for i = 1, 2 do
		local Image_GongGaoPNL = tolua.cast(wgt:getChildByName("Image_GongGaoPNL"..i), "ImageView")
		local Image_Logo = tolua.cast(Image_GongGaoPNL:getChildByName("Image_Logo"), "ImageView")
		Image_Logo:loadTexture(getStartGameImg("LoadingLogo_Viet"))
		Image_Logo:setScale(0.8)
		Image_Logo:setPositionXY(0,265)
	end
end

function VietLoadingForm:showForm()

	self.object.nCurPage = 1
	if self.object:ShowGameNotic() then --有服务器公告从第一页显示
		self.object.nCurPage = 1
	end
	self.object.nBegPage = self.object.nCurPage
end

-----------------Taiwan-------------------
TaiwaiLoadingForm = class("TaiwaiLoadingForm",function() return LoadingFormBase:new() end)
TaiwaiLoadingForm.__index = TaiwaiLoadingForm


function TaiwaiLoadingForm:showGameLogo(wgt)
	for i = 1, 2 do
		local Image_GongGaoPNL = tolua.cast(wgt:getChildByName("Image_GongGaoPNL"..i), "ImageView")
		local Image_Logo = tolua.cast(Image_GongGaoPNL:getChildByName("Image_Logo"), "ImageView")
		Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XYFML"))
		Image_Logo:setScale(0.8)
		Image_Logo:setPositionXY(0,265)
	end
end

function TaiwaiLoadingForm:showForm()

	self.object.nCurPage = 1
	if self.object:ShowGameNotic() then --有服务器公告从第一页显示
		self.object.nCurPage = 1
	end
	self.object.nBegPage = self.object.nCurPage
end

-----------------Taiwan神御灵-------------------
TaiwaiLoadingForm_SYL = class("TaiwaiLoadingForm_SYL",function() return LoadingFormBase:new() end)
TaiwaiLoadingForm_SYL.__index = TaiwaiLoadingForm_SYL


function TaiwaiLoadingForm_SYL:showGameLogo(wgt)
	for i = 1, 2 do
		local Image_GongGaoPNL = tolua.cast(wgt:getChildByName("Image_GongGaoPNL"..i), "ImageView")
		local Image_Logo = tolua.cast(Image_GongGaoPNL:getChildByName("Image_Logo"), "ImageView")
		Image_Logo:loadTexture(getStartGameImg("LoadingLogo_ShenYuLing"))
		Image_Logo:setScale(0.8)
		Image_Logo:setPositionXY(0,265)
	end
end

function TaiwaiLoadingForm_SYL:showForm()

	self.object.nCurPage = 1
	if self.object:ShowGameNotic() then --有服务器公告从第一页显示
		self.object.nCurPage = 1
	end
	self.object.nBegPage = self.object.nCurPage
end

-----------------XianJianQiTan-------------------
XianJianQiTanLoadingForm = class("XianJianQiTanLoadingForm",function() return LoadingFormBase:new() end)
XianJianQiTanLoadingForm.__index = XianJianQiTanLoadingForm


function XianJianQiTanLoadingForm:showGameLogo(wgt)
	for i = 1, 2 do
		local Image_GongGaoPNL = tolua.cast(wgt:getChildByName("Image_GongGaoPNL"..i), "ImageView")
		local Image_Logo = tolua.cast(Image_GongGaoPNL:getChildByName("Image_Logo"), "ImageView")
		Image_Logo:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
	end
end

function XianJianQiTanLoadingForm:showForm()

	self.object.nCurPage = 1
	if self.object:ShowGameNotic() then --有服务器公告从第一页显示
		self.object.nCurPage = 1
	end
	self.object.nBegPage = self.object.nCurPage
end