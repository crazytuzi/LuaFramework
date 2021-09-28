-- Filename：	GuildBottomSprite.lua
-- Author：		Cheng Liang
-- Date：		2013-12-21
-- Purpose：		获取军团 底图


module("GuildBottomSprite", package.seeall)


-- 按钮的Tag值
local Tag_Manager 		= 1001
local Tag_Member 		= 1002
local Tag_Chat 			= 1003
local Tag_Dynamic 		= 1004

-- 发光特效
local _animSprite 		= nil
local _isChatAnimationVisible = false

-- 切回到主界面
function closeAction(tag, item)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/main/MainBaseLayer"
	local main_base_layer = MainBaseLayer.create()
	MainScene.changeLayer(main_base_layer, "main_base_layer",MainBaseLayer.exit)
    MainScene.setMainSceneViewsVisible(true,true,true)
end

-- bottomMenuAction
function bottomMenuAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == Tag_Manager)then
		-- 管理
		require "script/ui/guild/GuildManagementLayer"
		GuildManagementLayer.showLayer()

	elseif(tag == Tag_Member)then
		-- 成员
		require "script/ui/guild/MemberListLayer"
		local memberListLayer = MemberListLayer.createLayer() 
		MainScene.changeLayer(memberListLayer, "memberListLayer")
	
	elseif(tag == Tag_Chat)then
		-- 聊天
		require "script/ui/chat/ChatMainLayer"
        ChatMainLayer.showChatLayer(3)
        setGuildChatItemAnimation(false)
    elseif(tag == Tag_Dynamic)then
		-- 动态
		print("Tag_DynamicTag_DynamicTag_Dynamic")
		require "script/ui/guild/GuildDynamicLayer"
		local guildDynamicLayer = GuildDynamicLayer.createLayer() 
		MainScene.changeLayer(guildDynamicLayer, "guildDynamicLayer")

	end
end

-- 军团聊天
function setGuildChatItemAnimation( isVisible )
	--print("isVisibleisVisibleisVisible",isVisible)
	_isChatAnimationVisible = isVisible

 --    if tolua.cast(_animSprite, "CCLayerSprite") ~= nil then
 --        _animSprite:setVisible(_isChatAnimationVisible)
	-- end

end

-- 创建底部
function createBottomSprite(isShowBackBtn)
	isShowBackBtn = isShowBackBtn or false
	
	local bottomSpite = CCSprite:create("images/guild/bg_bottom.png")
    bottomSpite:registerScriptHandler(onNodeEvent)
	local bottomSize = bottomSpite:getContentSize()
	local bottomMenuBar = CCMenu:create()
	bottomMenuBar:setPosition(ccp(0,0))
	bottomMenuBar:setTouchPriority(-400)
	bottomSpite:addChild(bottomMenuBar)

	local mineSigleInfo = GuildDataCache.getMineSigleGuildInfo()

	local btnPosArr = {0.3, 0.5, 0.7}
	if(isShowBackBtn == true)then
		btnPosArr = {0.1, 0.3, 0.5, 0.7, 0.9}
		if(tonumber(mineSigleInfo.member_type) == 1 or  tonumber(mineSigleInfo.member_type) == 2)then

		else
			btnPosArr = { 0.1, 0.2, 0.4, 0.6, 0.8,}
		end
	else
		if(tonumber(mineSigleInfo.member_type) == 1 or  tonumber(mineSigleInfo.member_type) == 2)then
			btnPosArr = { 0.2, 0.4, 0.6, 0.8, 0.9}
		else
			btnPosArr = {0.1, 0.3, 0.5, 0.7}
		end
	end

	
	if( tonumber(mineSigleInfo.member_type) == 1 or  tonumber(mineSigleInfo.member_type) == 2)then
		-- 管理
		local managerItem = CCMenuItemImage:create("images/guild/btn_manager_n.png","images/guild/btn_manager_h.png")
		managerItem:setAnchorPoint(ccp(0.5, 0.5))
		managerItem:registerScriptTapHandler(bottomMenuAction)
		managerItem:setPosition(ccp(bottomSize.width*btnPosArr[1], bottomSize.height*0.4))
		bottomMenuBar:addChild(managerItem, 1, Tag_Manager)
	end

	-- 成员
	local memberItem = CCMenuItemImage:create("images/guild/btn_member_n.png","images/guild/btn_member_h.png")
	memberItem:setAnchorPoint(ccp(0.5, 0.5))
	memberItem:registerScriptTapHandler(bottomMenuAction)
	memberItem:setPosition(ccp(bottomSize.width*btnPosArr[2], bottomSize.height*0.4))
	bottomMenuBar:addChild(memberItem, 1, Tag_Member)

	-- 聊天
	local chatItem = CCMenuItemImage:create("images/guild/btn_chat_n.png","images/guild/btn_chat_h.png")
	chatItem:setAnchorPoint(ccp(0.5, 0.5))
	chatItem:registerScriptTapHandler(bottomMenuAction)
	chatItem:setPosition(ccp(bottomSize.width*btnPosArr[3], bottomSize.height*0.4))
	bottomMenuBar:addChild(chatItem, 1, Tag_Chat)

	-- 发光特效
	_animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/chat/liaotian"), -1,CCString:create(""));
    _animSprite:setAnchorPoint(ccp(0.5,0.5))
    _animSprite:setPosition(ccp(chatItem:getContentSize().width*0.52,chatItem:getContentSize().height*0.55))
    _animSprite:setVisible(_isChatAnimationVisible)
    chatItem:addChild(_animSprite)

	-- 动态
	local danamicItem = CCMenuItemImage:create("images/guild/btn_dynamic_n.png","images/guild/btn_dynamic_h.png")
	danamicItem:setAnchorPoint(ccp(0.5, 0.5))
	danamicItem:registerScriptTapHandler(bottomMenuAction)
	danamicItem:setPosition(ccp(bottomSize.width*btnPosArr[4], bottomSize.height*0.4))
	bottomMenuBar:addChild(danamicItem, 1, Tag_Dynamic)

	if(isShowBackBtn == true)then
		-- 关闭
		local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
		closeMenuItem:setAnchorPoint(ccp(0.5, 0.5))
		closeMenuItem:registerScriptTapHandler(closeAction)
		closeMenuItem:setPosition(ccp(bottomSize.width*btnPosArr[5], bottomSize.height*0.4))
		bottomMenuBar:addChild(closeMenuItem)
	end

	return bottomSpite
end

function onNodeEvent(event)
	if (event == "enter") then
	elseif (event == "exit") then
        if isShowBackBtn == true then
            _animSprite = nil
        end
	end
end
