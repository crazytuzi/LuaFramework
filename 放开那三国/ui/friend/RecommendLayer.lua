-- FileName: RecommendLayer.lua 
-- Author: Li Cong 
-- Date: 13-8-27 
-- Purpose: function description of module 

require "script/ui/friend/RecommendCell"
module("RecommendLayer", package.seeall)

local mainLayer = nil
local content_bg = nil
local editBox = nil
local m_layerSize = nil

-- 得到坐标
function getPos( i )
	local pos = nil
	if(i == 1)then
		pos = ccp(content_bg:getContentSize().width*0.5,content_bg:getContentSize().height-20 )
	elseif(i == 2)then
		pos = ccp(content_bg:getContentSize().width*0.5,content_bg:getContentSize().height-140)
	elseif(i == 3)then
		pos = ccp(content_bg:getContentSize().width*0.5,content_bg:getContentSize().height-260)
	elseif(i == 4)then
		pos = ccp(content_bg:getContentSize().width*0.5,content_bg:getContentSize().height-380)
	end
	return pos
end


-- 创建显示列表
function createCellList()
	-- 默认显示第一页
	-- print_t(FriendData.recomdFriendData)
	FriendData.setShowRecomdData( FriendData.recomdFriendData )
	-- print("123123")
	-- print_t(FriendData.showRecomdData)
	local showData = FriendData.getShowRecomdData(FriendData.showRecomdPage)
	-- print("123123")
	-- print_t(showData)
	for k,v in pairs(showData) do
		local cell_bg = RecommendCell.createCell(v)
		cell_bg:setAnchorPoint(ccp(0.5,1))
		cell_bg:setPosition(getPos(tonumber(k)))
		content_bg:addChild(cell_bg,1,tonumber(k))
	end
end


-- 创建好友层
function initRecommendLayer( ... )
	-- 搜索框
	local search_bg = BaseUI.createSearchBg(CCSizeMake(604,70))
	search_bg:setAnchorPoint(ccp(0.5,1))
	search_bg:setPosition(ccp(mainLayer:getContentSize().width*0.5,mainLayer:getContentSize().height-240*MainScene.elementScale))
	mainLayer:addChild(search_bg)
	search_bg:setScale(g_fScaleX)

	-- 搜索输入框
    local editBox_bg = CCScale9Sprite:create(FriendLayer.IMG_PATH .. "friend_search_bg.png")
    editBox_bg:setContentSize(CCSizeMake(416,47))
    -- 编辑框
    editBox = CCEditBox:create(CCSizeMake(406,47), editBox_bg)
    editBox:setMaxLength(40)
    editBox:setReturnType(kKeyboardReturnTypeDone)
    editBox:setInputFlag(kEditBoxInputFlagInitialCapsWord)
    editBox:setPlaceHolder(GetLocalizeStringBy("key_1716"))
    editBox:setFont(g_sFontName, 23)
    editBox:setFontColor(ccc3(0xc3,0xc3,0xc3))
    editBox:setAnchorPoint(ccp(0,0.5))
    editBox:setPosition(ccp(10,search_bg:getContentSize().height*0.5-2))
    search_bg:addChild(editBox)
    -- 搜索按钮
    local searchMenu = CCMenu:create()
    searchMenu:setPosition(ccp(0,0))
    search_bg:addChild(searchMenu)
    local searchMenuItem = CCMenuItemImage:create(FriendLayer.COMMON_PATH .. "btn/btn_blue_n.png",FriendLayer.COMMON_PATH .. "btn/btn_blue_h.png")
	searchMenuItem:setAnchorPoint(ccp(1,0.5))
	searchMenuItem:setPosition(ccp(search_bg:getContentSize().width-30, search_bg:getContentSize().height*0.5-2))
	searchMenu:addChild(searchMenuItem)
	-- 注册挑战回调
	searchMenuItem:registerScriptTapHandler(searchMenuItemCallFun)
	-- 阵容字体
	--兼容东南亚英文版
	local item_font
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	item_font = CCRenderLabel:create( GetLocalizeStringBy("key_2908") , g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    else
    	item_font = CCRenderLabel:create( GetLocalizeStringBy("key_2908") , g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    end
    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
    item_font:setAnchorPoint(ccp(0.5,0.5))
    item_font:setPosition(ccp(searchMenuItem:getContentSize().width*0.5,searchMenuItem:getContentSize().height*0.5))
   	searchMenuItem:addChild(item_font)

	-- 内容背景
	-- content_bg = BaseUI.createContentBg(CCSizeMake((m_layerSize.width-50),(m_layerSize.height-355*MainScene.elementScale)))
	-- content_bg:setAnchorPoint(ccp(0.5,1))
	-- content_bg:setPosition(ccp(mainLayer:getContentSize().width*0.5,search_bg:getPositionY()-search_bg:getContentSize().height*MainScene.elementScale-10*MainScene.elementScale))
	-- mainLayer:addChild(content_bg)

	content_bg = BaseUI.createContentBg(CCSizeMake(604, 615))
	content_bg:setAnchorPoint(ccp(0.5,1))
	content_bg:setPosition(ccp(mainLayer:getContentSize().width*0.5,search_bg:getPositionY()-search_bg:getContentSize().height*MainScene.elementScale-10*MainScene.elementScale))
	mainLayer:addChild(content_bg)
	content_bg:setScale(MainScene.elementScale)


	-- 创建显示列表
	createCellList()

	-- 创建更多好友按钮
	local moreMenu = BTSensitiveMenu:create()
	if(moreMenu:retainCount()>1)then
		moreMenu:release()
		moreMenu:autorelease()
	end
	moreMenu:setPosition(ccp(0,0))
	content_bg:addChild(moreMenu)
	local moreMenuItem = FriendLayer.createMoreButtonItem()
	moreMenuItem:setAnchorPoint(ccp(0.5,1))
    moreMenuItem:setPosition(ccp(content_bg:getContentSize().width*0.5,content_bg:getContentSize().height-500))
    moreMenu:addChild(moreMenuItem)
	-- 注册回调
	moreMenuItem:registerScriptTapHandler(moreMenuItemCallFun)

end


-- 搜索按钮回调
function searchMenuItemCallFun( ... )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local function createNext( dataRet )
		FriendData.setShowRecomdData( FriendData.searchFriendData )
		-- print("123123")
		-- print_t(FriendData.showRecomdData)
		FriendData.showRecomdPage = 1
		local showData = FriendData.getShowRecomdData(FriendData.showRecomdPage)
		-- print("123123")
		-- print_t(showData)
		-- 先移除
		for i = 1, 4 do
			if(content_bg:getChildByTag(i) ~= nil)then
				content_bg:removeChildByTag(i,true)
			end
		end
		-- 再创建
		for k,v in pairs(showData) do
			local cell_bg = RecommendCell.createCell(v)
			cell_bg:setAnchorPoint(ccp(0.5,1))
			cell_bg:setPosition(getPos(tonumber(k)))
			content_bg:addChild(cell_bg,1,tonumber(k))
		end
	end
 	local content = editBox:getText()
	FriendService.getRecomdByName(content,nil,nil,createNext)
end

-- 更多推荐好友按钮回调
function moreMenuItemCallFun( tag, item_obj )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- print(GetLocalizeStringBy("key_1661"))
	FriendData.showRecomdPage = FriendData.showRecomdPage + 1
	-- 判断是否有更多好友
	local isHave = FriendData.isHaveMore( FriendData.showRecomdPage )
	if(isHave)then
		local showData = FriendData.getShowRecomdData(FriendData.showRecomdPage)
		-- print("123123")
		-- print_t(showData)
		-- 先移除
		for i = 1, 4 do
			if(content_bg:getChildByTag(i) ~= nil)then
				content_bg:removeChildByTag(i,true)
			end
		end
		-- 再创建
		for k,v in pairs(showData) do
			local cell_bg = RecommendCell.createCell(v)
			cell_bg:setAnchorPoint(ccp(0.5,1))
			cell_bg:setPosition(getPos(tonumber(k)))
			content_bg:addChild(cell_bg,1,tonumber(k))
		end
	else
		require "script/ui/tip/AnimationTip"
		local str = GetLocalizeStringBy("key_2451")
		AnimationTip.showTip(str)
	end
end

-- 创建推荐好友层
function createRecommendLayer( ... )
	
	mainLayer = CCLayer:create()
	-- mainLayer = CCLayerColor:create(ccc4(255,255,255,0))
	m_layerSize = mainLayer:getContentSize()

	-- 创建下一步UI
	local function createNext( ... )
		-- 初始化
		initRecommendLayer()
	end
	FriendService.getRecomdFriends(createNext)

	return mainLayer
end














