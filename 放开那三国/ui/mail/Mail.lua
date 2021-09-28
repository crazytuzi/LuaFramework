-- FileName: Mail.lua 
-- Author: Li Cong 
-- Date: 13-8-20 
-- Purpose: function description of module 

require "script/model/user/UserModel"
require "script/utils/BaseUI"
require "script/ui/mail/MailService"
require "script/ui/mail/MailData"

module("Mail", package.seeall)

--全局变量
m_layerSize = nil
COMMON_PATH = "images/common/"					    			-- 公用图片主路径
IMG_PATH = "images/arena/"					    				-- 邮件图片主路径
set_height = nil           						
set_width = nil
-- local 全局变量
local m_mainLayer = nil

function initMailLayer( ... )
	-- 邮件层layer大小
	m_layerSize = m_mainLayer:getContentSize()
	-- 邮件背景
	local mail_bg = BaseUI.createNoBorderViewBg(CCSizeMake((m_layerSize.width-10),(m_layerSize.height+10)))
	mail_bg:setAnchorPoint(ccp(0.5,1))
	mail_bg:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height))
	mail_bg:setScale(1/MainScene.elementScale)
	m_mainLayer:addChild(mail_bg)
	-- 按钮背景
	local menu_bg = BaseUI.createTopMenuBg(CCSizeMake(m_layerSize.width/MainScene.elementScale, 96))
	menu_bg:setAnchorPoint(ccp(0.5,1))
	menu_bg:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height))
	m_mainLayer:addChild(menu_bg)
	-- 上分界线
	local topSeparator = CCSprite:create( COMMON_PATH .. "separator_top.png" )
	topSeparator:setAnchorPoint(ccp(0.5,1))
	topSeparator:setPosition(ccp(m_layerSize.width*0.5,m_layerSize.height))
	m_mainLayer:addChild(topSeparator)
	topSeparator:setScale(g_fScaleX/MainScene.elementScale)
	-- 内容背景
	content_bg = BaseUI.createContentBg(CCSizeMake((m_layerSize.width-50*MainScene.elementScale),(m_layerSize.height-131*MainScene.elementScale)))
	content_bg:setAnchorPoint(ccp(0.5,1))
	content_bg:setPosition(ccp(mail_bg:getContentSize().width*0.5,mail_bg:getContentSize().height-106*MainScene.elementScale))
	mail_bg:addChild(content_bg,10)
	set_height = m_layerSize.height-141*MainScene.elementScale
	set_width = m_layerSize.width-50*MainScene.elementScale
	--  创建竞技和排行按钮
	tabLayer = BaseUI.createTopTabLayer( { GetLocalizeStringBy("key_2299"), GetLocalizeStringBy("key_2353"), GetLocalizeStringBy("key_1837"), GetLocalizeStringBy("key_1288") },
	  	36,30,
	  	g_sFontPangWa,
	  	ccc3(0xff, 0xe4, 0x00),ccc3(0x48, 0x85, 0xb5) 
	)
	tabLayer:setPosition(ccp(0,0))
	tabLayer:setScale(1/MainScene.elementScale)
    m_mainLayer:addChild(tabLayer,2)
    -- 设置竞技和排行按钮位置
    -- 全部按钮位置
    tabLayer:buttonOfIndex(0):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(0):setPosition(ccp(4, m_layerSize.height-87*MainScene.elementScale))
	tabLayer:buttonOfIndex(0):setScale(MainScene.elementScale)
	-- 战斗按钮位置
	local x1 = tabLayer:buttonOfIndex(0):getPositionX()+156*MainScene.elementScale
	tabLayer:buttonOfIndex(1):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(1):setPosition(ccp(x1, m_layerSize.height-87*MainScene.elementScale))
	tabLayer:buttonOfIndex(1):setScale(MainScene.elementScale)
	-- 好友按钮位置
	local x2 = tabLayer:buttonOfIndex(1):getPositionX()+156*MainScene.elementScale
	tabLayer:buttonOfIndex(2):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(2):setPosition(ccp(x2, m_layerSize.height-87*MainScene.elementScale))
	tabLayer:buttonOfIndex(2):setScale(MainScene.elementScale)
	-- 系统按钮位置
	local x3 = tabLayer:buttonOfIndex(2):getPositionX()+156*MainScene.elementScale
	tabLayer:buttonOfIndex(3):setAnchorPoint(ccp(0,0))
	tabLayer:buttonOfIndex(3):setPosition(ccp(x3, m_layerSize.height-87*MainScene.elementScale))
	tabLayer:buttonOfIndex(3):setScale(MainScene.elementScale)
	-- 设置默认显示 
    require "script/ui/mail/AllMail"
    tabLayer:layerOfIndex(0):addChild( AllMail.createAllMail() )
    -- 按钮切换事件
	tabLayer:registerScriptTapHandler(function ( button,index )
		if (index == 0) then
			-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			tabLayer:layerOfIndex(0):addChild( AllMail.createAllMail() )
		elseif (index == 1) then
			-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			require "script/ui/mail/BattleMail"
            tabLayer:layerOfIndex(1):addChild( BattleMail.createBattleMail() )
        elseif (index == 2) then
        	-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			require "script/ui/mail/FriendMail"
            tabLayer:layerOfIndex(2):addChild( FriendMail.createFriendMail() )
        elseif (index == 3) then
        	-- 音效
			require "script/audio/AudioUtil"
			AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
			require "script/ui/mail/SystemMail"
            tabLayer:layerOfIndex(3):addChild( SystemMail.createSystemMail() )
        end
	end)
end


--  创建邮件层
function createMailLayer( ... )
	m_mainLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false,true)

	-- 初始化邮件层
	initMailLayer()

	return m_mainLayer
end


















































