-- FileName: GuildRobEnemyListCell.lua 
-- Author: licong 
-- Date: 14-11-15 
-- Purpose: 抢粮敌人列表cell


module("GuildRobEnemyListCell", package.seeall)

-- 创建仇人单元格
function createCell( tCellValue )
	print("tCellValue==>")
	print_t(tCellValue)

	local tCell = CCTableViewCell:create()

	-- 背景
	local cellBg = CCScale9Sprite:create("images/common/bg/bg_9s_4.png")
	cellBg:setContentSize(CCSizeMake(588, 188))
	cellBg:setAnchorPoint(ccp(0.5,0))
	cellBg:setPosition(ccp(300,0))
	tCell:addChild(cellBg)

	-- 小背景
	local textBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
	textBg:setContentSize(CCSizeMake(366, 136))
	textBg:setAnchorPoint(ccp(0,0.5))
	textBg:setPosition(ccp(30, cellBg:getContentSize().height*0.5))
	cellBg:addChild(textBg)

	-- 小图标
	local liangIcon = CCSprite:create("images/guild_rob_list/rob_liang.png")
	liangIcon:setAnchorPoint(ccp(0,0.5))
	liangIcon:setPosition(ccp(12,textBg:getContentSize().height*0.5))
	textBg:addChild(liangIcon)

	-- 被抢时间
	require "script/utils/TimeUtil"
	local startTimeStr = TimeUtil.getTimeToMin( tonumber(tCellValue.rob_time) )
	local robTimeStrFont = CCRenderLabel:create(startTimeStr, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    robTimeStrFont:setAnchorPoint(ccp(0,1))
    robTimeStrFont:setColor(ccc3(0x00, 0xff, 0x18))
    robTimeStrFont:setPosition(ccp(127,textBg:getContentSize().height-20))
    textBg:addChild(robTimeStrFont)
    -- 华丽的分割线
	local lineSprite = CCScale9Sprite:create("images/common/line01.png")
	lineSprite:setContentSize(CCSizeMake(235, 4))
	lineSprite:setAnchorPoint(ccp(0, 1))
	lineSprite:setPosition(ccp(120, robTimeStrFont:getPositionY()-robTimeStrFont:getContentSize().height-5))
	textBg:addChild(lineSprite)

	-- 描述 被【某某某】军团抢走xxx粮草
    local textInfo = {
        width = 200, -- 宽度
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        labelDefaultFont = g_sFontName,      -- 默认字体
        labelDefaultSize = 21,          -- 默认字体大小
        linespace = 13, -- 行间距
        defaultType = "CCRenderLabel",
        elements =
        {
            {
                text = GetLocalizeStringBy("lic_1321"),                     -- 文本内容
            },
            {
            	text = "【" .. tCellValue.guild_name .. "】",
            	color = ccc3(0x00, 0xe4, 0xff)
        	},
        	{
        		text = GetLocalizeStringBy("lic_1322")
        	},
        	{
        		text =  string.formatBigNumber(tCellValue.rob_grain),
        		color = ccc3(0x00, 0xff, 0x18),
                isWhole = true
        	},
        	{
        		text = GetLocalizeStringBy("lic_1323")
        	}
        }
 	}
 	local label = LuaCCLabel.createRichLabel(textInfo)
 	label:setAnchorPoint(ccp(0, 1))
 	label:setPosition(ccp(130, lineSprite:getPositionY()-lineSprite:getContentSize().height-15))
 	textBg:addChild(label)

 	-- 发起抢粮按钮
 	local menuBar = CCMenu:create()
    menuBar:setTouchPriority(-621)
	menuBar:setPosition(ccp(0, 0))
	menuBar:setAnchorPoint(ccp(0, 0))
	cellBg:addChild(menuBar)

    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
    normalSprite:setContentSize(CCSizeMake(160,64))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
    selectSprite:setContentSize(CCSizeMake(160,64))
    local robMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    robMenuItem:setAnchorPoint(ccp(1,0.5))
    robMenuItem:setPosition(ccp(cellBg:getContentSize().width-25, cellBg:getContentSize().height*0.55))
    robMenuItem:registerScriptTapHandler(robMenuItemCallback)
    menuBar:addChild(robMenuItem,1,tonumber(tCellValue.rob_time))
    local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1324"), g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
    itemfont1:setAnchorPoint(ccp(0.5,0.5))
    itemfont1:setColor(ccc3(0xff,0xe4,0x00))
    itemfont1:setPosition(ccp(robMenuItem:getContentSize().width*0.5,robMenuItem:getContentSize().height*0.5))
    robMenuItem:addChild(itemfont1)

    -- 可抢粮草
    local desFont = CCLabelTTF:create(GetLocalizeStringBy("lic_1325"), g_sFontName, 21)
    desFont:setAnchorPoint(ccp(0,0.5))
    desFont:setColor(ccc3(0x78, 0x25, 0x00))
    desFont:setPosition(ccp(407,48))
    cellBg:addChild(desFont)

    -- 可抢粮草数量
    local desNumFont = CCLabelTTF:create(string.formatBigNumber(tCellValue.rob_free), g_sFontName, 21)
    desNumFont:setAnchorPoint(ccp(0,0.5))
    desNumFont:setColor(ccc3(0xf4, 0x00, 0x00))
    desNumFont:setPosition(ccp(desFont:getPositionX()+desFont:getContentSize().width+3,desFont:getPositionY()))
    cellBg:addChild(desNumFont)


	return tCell
end

-- 发起抢粮按钮回调  tag 是被抢时间戳
function robMenuItemCallback( tag, itemBtn )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    print("robMenuItemCallback")

    require "script/ui/guild/guildRobList/GuildRobListLayer"
    require "script/ui/guild/guildRobList/GuildRobData"
    local guildInfo = GuildRobData.getRobEnemyInfoByRobTime(tag)
    local newInfo = {}
    newInfo.name = guildInfo.guild_name
    newInfo.guildId = guildInfo.guild_id
    newInfo.shelterTime = guildInfo.shelter_time
    GuildRobListLayer.rob(newInfo)
end












