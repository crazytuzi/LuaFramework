--------------------------------------------------------------------------------------
-- 文件名: LKA_CNoticeWnd.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 陆奎安
-- 日  期:    2013-4-5 9:37
-- 版  本:    1.0
-- 描  述:    公告界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

Game_Notice = class("Game_Notice")
Game_Notice.__index = Game_Notice
local title_pos = nil
function Game_Notice:setPageViewPanel(Panel_NoticePage, tb_strText, nIndex)
	local ScrollView_Notice = tolua.cast(Panel_NoticePage:getChildByName("ScrollView_Notice"), "ScrollView")
	local Label_NoticeTitleDesc = tolua.cast(Panel_NoticePage:getChildByName("Label_NoticeTitleDesc"), "Label")
    
    local curGongGao = self.mCurGongGao[nIndex]
    if not title_pos then
       title_pos = Label_NoticeTitleDesc:getPosition()
    end
    Label_NoticeTitleDesc:removeAllChildren()
    local width = gCreateColorLable(Label_NoticeTitleDesc, curGongGao["title"])
    local desc_x = title_pos.x - width/2
    local desc_y = title_pos.y - Label_NoticeTitleDesc:getContentSize().height/2
    Label_NoticeTitleDesc:setPosition(ccp(desc_x, desc_y))
    self.mContent_lable:setFontSize(curGongGao["contentfontsize"])
    local scrool_height = self.mContent_lable:getContentSize().height 
    for i = 1 ,#curGongGao["content"] do
        scrool_height = scrool_height + self.mContent_lable:getContentSize().height
    end

    --如果当前公告高度小于显示框的高度，则滑动区域大小等于显示框的高度
    if scrool_height < ScrollView_Notice:getContentSize().height then
        scrool_height = ScrollView_Notice:getContentSize().height
    end
    ScrollView_Notice:removeAllChildrenWithCleanup(true)
    ScrollView_Notice:setInnerContainerSize(CCSizeMake(ScrollView_Notice:getInnerContainerSize().width, scrool_height))
    ScrollView_Notice:setTouchEnabled(true)
	ScrollView_Notice:setBounceEnabled(true)
	ScrollView_Notice:setAnchorPoint(ccp(0,1))
	ScrollView_Notice:setPosition(ccp(0, 340))
    local content
    local content_x = self.mContent_lable:getPosition().x
    local content_y = scrool_height
    for i = 1 ,#curGongGao["content"] do
        if not ScrollView_Notice:getChildByTag(i) then
            content = tolua.cast(self.mContent_lable:clone(), "Label")
            content:removeAllChildren()
            content:setFontSize(curGongGao["contentfontsize"]) 
            gCreateColorLable(content, curGongGao["content"][i])
            content:setVisible(true) 
            content:setPosition(ccp(content_x, content_y - content:getContentSize().height*1.25))
            content:setTag(i)
		    content_y = content_y - content:getContentSize().height 
            ScrollView_Notice:addChild(content)
        end
	end
end

function Game_Notice:initLuaPageView()
	local Image_NoticePNL = tolua.cast(self.rootWidget:getChildByName("Image_NoticePNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_NoticePNL:getChildByName("Image_ContentPNL"), "ImageView")
    
	self.textPageIndex = ""
    if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET then
        self.mCurGongGao = gNoticeConfig_Vietnam
    elseif g_LggV.LanguageVer == eLanguageVer.LANGUAGE_cht_Taiwan then
		if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
			self.mCurGongGao = gNoticeConfig_Taiwan_SYL
		else
			self.mCurGongGao = gNoticeConfig_Taiwan
		end
	else
		if g_IsXiaoXiaoXianSheng ~= nil and g_IsXiaoXiaoXianSheng == true then
			if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then  --提审
				self.mCurGongGao = gNoticeConfig_China_XiaoXiaoXianSheng[1]
				self.mCurGongGao["content"] = {""}
			elseif g_strAndroidTS == "open" then
				self.mCurGongGao = gNoticeConfig_China_XiaoXiaoXianSheng[1]
				self.mCurGongGao["content"] = {""}
			else
				self.mCurGongGao = gNoticeConfig_China_XiaoXiaoXianSheng[1]
			end
		else
			if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then  --提审
				self.mCurGongGao = gNoticeConfig_China[1]
				self.mCurGongGao["content"] = {""}
			elseif g_strAndroidTS == "open" then
				self.mCurGongGao = gNoticeConfig_China[1]
				self.mCurGongGao["content"] = {""}
            elseif g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_VIVO 
                or g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_HUAWEI then 
                self.mCurGongGao = gNoticeConfig_shandang[1]
			else
				self.mCurGongGao = gNoticeConfig_China[1]
			end
		end
    end

	for i=1, #self.mCurGongGao do
		self.textPageIndex = self.textPageIndex.."2"
	end
	
	local function setPageView(Panel_NoticePage, nIndex)
		self:setPageViewPanel(Panel_NoticePage, tb_strText, nIndex)
	end
	
	local function setClickEvent(Panel_NoticePage, nIndex)
		local Value = ""
		for i=1, #self.mCurGongGao do
			if nIndex == i then
				Value = Value..1
			else
				Value = Value..2
			end
		end
		self.AtlasLabel_PageIndex:setStringValue(Value)
	end
	local PageView_Notice = tolua.cast(Image_ContentPNL:getChildByName("PageView_Notice"), "PageView")
	PageView_Notice:setTouchEnabled(false)
	
	local Panel_NoticePage = tolua.cast(PageView_Notice:getChildByName("Panel_NoticePage"), "Layout")
	if not Panel_NoticePage then
		return false
	end
	
	local Button_Right = Image_NoticePNL:getChildByName("Button_Right")
	local Button_Left = Image_NoticePNL:getChildByName("Button_Left")
    local ScrollView_Notice = tolua.cast(Panel_NoticePage:getChildByName("ScrollView_Notice"), "ScrollView")
	self.mContent_lable = tolua.cast(ScrollView_Notice:getChildByName("Label_Content"), "Label")
	
	self.LuaPageView_Notice = Class_LuaPageView.new() 	
	self.LuaPageView_Notice:registerClickEvent(setClickEvent)
	self.LuaPageView_Notice:registerUpdateFunction(setPageView)
	self.LuaPageView_Notice:setModel(Panel_NoticePage, Button_Left, Button_Right, 0.90, 0.90)
	self.LuaPageView_Notice:setPageView(PageView_Notice)
	self.LuaPageView_Notice:updatePageView(#self.mCurGongGao)

	return true
end

function Game_Notice:closeWnd()
	if self.LuaPageView_Notice then
		self.LuaPageView_Notice:ReleaseItemModle()
	end
	self.LuaPageView_Notice = nil
    self.mCurGongGao = nil
	
	cclog("=======Game_Notice:destroyWnd()========")
end


--初始化界面
function Game_Notice:initCNoticeWnd()
	--初始化pageView
	local Image_NoticePNL = tolua.cast(self.rootWidget:getChildByName("Image_NoticePNL"), "ImageView")
	self.AtlasLabel_PageIndex = tolua.cast(Image_NoticePNL:getChildByName("AtlasLabel_PageIndex"), "LabelAtlas")
    self.mCurGongGao = nil
    self.mContent_lable = nil
	self:initLuaPageView()
end

function Game_Notice:initWnd(widget)
	cclog("=========Game_Notice:initWnd==========")
	self:initCNoticeWnd() 
end
--显示主界面的伙伴详细介绍界面
--打开界面调用
function Game_Notice:openWnd()
    if g_bReturn  then  return  end
end
