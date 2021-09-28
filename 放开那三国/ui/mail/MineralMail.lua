-- FileName: MineralMail.lua 
-- Author: Li Cong 
-- Date: 13-8-27 
-- Purpose: function description of module 

require "script/ui/mail/MailData"
require "script/ui/mail/MailService"
require "script/ui/mail/Mail"
module("MineralMail", package.seeall)


--全局变量
local m_layerSize = nil
COMMON_PATH = "images/common/"					    			-- 公用图片主路径
-- local 全局变量
local mainLayer = nil
local content_bg = nil
local content_bgHeight = nil
-- 创建滑动列表
function createMineralMailTabView()
	-- cell的size
	local cellSize = { width = 570, height = 190 } 
	-- 得到全部邮件列表数据
	MailData.showMailData = MailData.getShowMailData(MailData.mineralData)
	print(GetLocalizeStringBy("key_1784")) 
	print_t(MailData.showMailData)
	require "script/ui/mail/MineralMailCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			-- 显示单元格的间距
			local interval = 10
			r = CCSizeMake(cellSize.width, (cellSize.height + interval))
		elseif (fn == "cellAtIndex") then
			r = MineralMailCell.createCell(MailData.showMailData[a1+1])
			-- r:setScale(g_fScaleX)
		elseif (fn == "numberOfCells") then
			r = #MailData.showMailData
		elseif (fn == "cellTouched") then
			-- print ("a1: ", a1, ", a2: ", a2)
			-- print ("cellTouched, index is: ", a1:getIdx())
		elseif (fn == "scroll") then
			-- print ("scroll, index is: ")
		else
			-- print (fn, " event is not handled.")
		end
		return r
	end)
	local height = content_bgHeight - 20*g_fScaleX
	mailTableView = LuaTableView:createWithHandler(handler, CCSizeMake(580,height/g_fScaleX))
	mailTableView:setBounceable(true)
	mailTableView:ignoreAnchorPointForPosition(false)
	mailTableView:setAnchorPoint(ccp(0.5, 1))
	local posY = content_bg:getContentSize().height-10
	mailTableView:setPosition(ccp(content_bg:getContentSize().width/2,posY))
	content_bg:addChild(mailTableView)
	-- 设置单元格升序排列
	mailTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	mailTableView:setTouchPriority(-130)
end



-- 初始化邮件
function initMailLayer( id )
		-- 公告栏大小
	require "script/ui/main/BulletinLayer"
    local upHeight = BulletinLayer.getLayerContentSize().height

	-- 邮件层layer大小
	m_layerSize = mainLayer:getContentSize()
	-- 邮件背景
	local mail_bg = BaseUI.createNoBorderViewBg(CCSizeMake(630,mainLayer:getContentSize().height))
	mail_bg:setAnchorPoint(ccp(0.5,1))
	mail_bg:setPosition(ccp(m_layerSize.width*0.5,mainLayer:getContentSize().height))
	mainLayer:addChild(mail_bg)
	mail_bg:setScale(g_fScaleX)
	-- 标题背景
	local title_bg = CCSprite:create(COMMON_PATH .. "title_bg.png")
	title_bg:setAnchorPoint(ccp(0.5,1))
	title_bg:setPosition(ccp(320*g_fScaleX,mainLayer:getContentSize().height-upHeight*g_fScaleX))
	mainLayer:addChild(title_bg)
	title_bg:setScale(g_fScaleX)

	-- 标题
	require "script/libs/LuaCCLabel" 
	local title_font = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("key_2874"), g_sFontPangWa, 35)
	title_font:setColor(ccc3( 0xff, 0xe4, 0x00))
	title_font:setPosition(ccp((title_bg:getContentSize().width-title_font:getContentSize().width)*0.5,16))
	title_bg:addChild(title_font)

	-- 关闭按钮
	local closeMenu = CCMenu:create()
	closeMenu:setPosition(ccp(0, 0))
	closeMenu:setAnchorPoint(ccp(0, 0))
	title_bg:addChild(closeMenu)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(1, 0.5))
	closeButton:setPosition(ccp(title_bg:getContentSize().width, title_bg:getContentSize().height*0.5+4 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	closeMenu:addChild(closeButton,1,tonumber(id))

	-- 内容背景
	content_bgHeight = mainLayer:getContentSize().height-title_bg:getContentSize().height*g_fScaleX-upHeight*g_fScaleX-40*g_fScaleX-MenuLayer.getHeight()
	content_bg = BaseUI.createContentBg(CCSizeMake(590,content_bgHeight/g_fScaleX))
	content_bg:setAnchorPoint(ccp(0.5,1))
	content_bg:setPosition(ccp(mainLayer:getContentSize().width*0.5,mainLayer:getContentSize().height-title_bg:getContentSize().height*g_fScaleX-upHeight*g_fScaleX-10*g_fScaleX))
	mainLayer:addChild(content_bg)
	content_bg:setScale(g_fScaleX)

	-- 创建邮件列表
	createMineralMailTabView()
end



-- 创建资源矿邮件
function createMineralMailLayer( id )
	mainLayer = CCLayer:create()

	MainScene.setMainSceneViewsVisible(true, false,true)

	local _bgSprite = CCScale9Sprite:create("images/main/module_bg.png")
	_bgSprite:setContentSize(CCSizeMake(mainLayer:getContentSize().width,mainLayer:getContentSize().height))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(mainLayer:getContentSize().width*0.5,mainLayer:getContentSize().height*0.5))
    mainLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fScaleX)

	mainLayer:registerScriptHandler(function ( eventType,node )
        if(eventType == "enter") then
           mailTableView = nil
        end
        if(eventType == "exit") then
            mailTableView = nil
        end
    end)
	-- 创建下一步UI
	local function createNext( ... )
		-- 初始化邮件层
		initMailLayer( id )
	end
	-- 初始化全部邮件数据 
	MailService.getMineralMailList(0,10,"true",createNext)
	
	return mainLayer
end


-- 关闭按钮回调
function closeButtonCallback( tag, item_obj )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	mainLayer:removeFromParentAndCleanup(true)
	mainLayer = nil
	-- 邮件背景的大小
	Mail.set_width = nil
	Mail.set_height = nil
	require "script/ui/active/mineral/MineralLayer"
	local mineralLayer = MineralLayer.createLayer(tag)
	MainScene.changeLayer(mineralLayer, "mineralLayer")
end

	































