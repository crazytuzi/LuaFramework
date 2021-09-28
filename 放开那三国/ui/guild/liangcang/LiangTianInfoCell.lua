-- FileName: LiangTianInfoCell.lua
-- Author: licong
-- Date: 14-12-2
-- Purpose: 粮田采集信息cell
require "script/ui/item/ItemUtil"

module("LiangTianInfoCell", package.seeall)

local strTab = {
    -- 1
    {
        type = "CCLabelTTF",
        text = GetLocalizeStringBy("lic_1384"),
        color = ccc3(0x78, 0x25, 0x00)
    },
    -- 2
    {
        type = "CCLabelTTF",
        text = GetLocalizeStringBy("lic_1385"),
        color = ccc3(0x78, 0x25, 0x00)
    },
    -- 3
    {
        type = "CCSprite",
        image = "images/common/liangcao.png"
    },
    -- 4
    {
        type = "CCLabelTTF",
        text = GetLocalizeStringBy("lic_1386"),
        color = ccc3(0x78, 0x25, 0x00)
    },
    -- 5
    {
        type = "CCLabelTTF",
        text = GetLocalizeStringBy("lic_1387"),
        color = ccc3(0x78, 0x25, 0x00)
    },
    -- 6
    {
        type = "CCLabelTTF",
        text = GetLocalizeStringBy("lic_1388"),
        color = ccc3(0x78, 0x25, 0x00)
    },
    -- 7
    {
        type = "CCLabelTTF",
        text = GetLocalizeStringBy("lic_1389"),
        color = ccc3(0x78, 0x25, 0x00)
    },
    -- 8
    {
        type = "CCLabelTTF",
        text = GetLocalizeStringBy("lic_1390"),
        color = ccc3(0x78, 0x25, 0x00)
    },
    -- 9
    {
        type = "CCSprite",
        image = "images/common/liangcao.png"
    },
    -- 10
    {
        type = "CCLabelTTF",
        text = GetLocalizeStringBy("fqq_056"),
        color = ccc3(0xe4, 0x00, 0xff)
    },
}

-- 创建采集信息单元格
function createCell( tCellValue )
    print("tCellValue==>")
    print_t(tCellValue)

    local tCell = CCTableViewCell:create()

    -- 背景
    local cellBg = CCScale9Sprite:create("images/common/bg/bg_9s_4.png")
    cellBg:setContentSize(CCSizeMake(577, 162))
    cellBg:setAnchorPoint(ccp(0.5,0))
    cellBg:setPosition(ccp(300,0))
    tCell:addChild(cellBg)

    -- 小图标
    local caiIcon = CCSprite:create("images/guild/liangcang/caiji_n.png")
    caiIcon:setAnchorPoint(ccp(0,0.5))
    caiIcon:setPosition(ccp(22,cellBg:getContentSize().height*0.5))
    cellBg:addChild(caiIcon)

    -- 采集时间
    require "script/utils/TimeUtil"
    require "script/ui/mail/MailData"
    print("xxxxx",tCellValue.time .. "0000")
    local timeInterval = TimeUtil.getIntervalByTimeDesString( tCellValue.time .. "0000" )
    local timeStr = MailData.getValidTime( timeInterval )
    local timeStrFont = CCRenderLabel:create(timeStr, g_sFontName, 24, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    timeStrFont:setAnchorPoint(ccp(0,1))
    timeStrFont:setColor(ccc3(0x78, 0x25, 0x00))
    timeStrFont:setPosition(ccp(134,cellBg:getContentSize().height-20))
    cellBg:addChild(timeStrFont)

    -- 小背景
    local textBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
    textBg:setContentSize(CCSizeMake(440, 100))
    textBg:setAnchorPoint(ccp(0,0))
    textBg:setPosition(ccp(112, 15))
    cellBg:addChild(textBg)

    -- 描述
    local textInfo = nil
    local propData = tCellValue.add_extra or {}
    local propData1 = propData.item or {}
    if( tonumber(tCellValue.add_level) > 0 )then
        textInfo = {
            width = 420, -- 宽度
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontName,      -- 默认字体
            labelDefaultSize = 18,          -- 默认字体大小
            lineAlignment = 2,
            linespace = 1, -- 行间距
            elements =
            {
                {
                    type = "CCLabelTTF",
                    text = tCellValue.uname,
                    color = ccc3(0xe4, 0x00, 0xff)
                },
                strTab[1],
                {
                    type = "CCLabelTTF",
                    text = tonumber(tCellValue.num),
                    color = ccc3(0x78, 0x25, 0x00)
                },
                strTab[2],
                strTab[3],
                {
                    type = "CCRenderLabel",
                    text = tonumber(tCellValue.add_grain),
                    color = ccc3(0x00, 0xe4, 0xff)
                },
                strTab[4],
                {
                    type = "CCRenderLabel",
                    text = tonumber(tCellValue.add_exp),
                    color = ccc3(0x00, 0xe4, 0xff)
                },
                strTab[5],
                strTab[6],
                {
                    type = "CCRenderLabel",
                    text = tonumber(tCellValue.add_level),
                    color = ccc3(0x00, 0xff, 0x18)
                },
                strTab[7],
                strTab[8],
                strTab[9],
                {
                    type = "CCRenderLabel",
                    text = tonumber(tCellValue.grain_output),
                    color = ccc3(0x00, 0xff, 0x18)
                },


            }
        }
    else
        textInfo = {
            width = 420, -- 宽度
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontName,      -- 默认字体
            labelDefaultSize = 18,          -- 默认字体大小
            lineAlignment = 2,
            linespace = 1, -- 行间距
            elements =
            {
                {
                    type = "CCLabelTTF",
                    text = tCellValue.uname,
                    color = ccc3(0xe4, 0x00, 0xff)
                },
                strTab[1],
                {
                    type = "CCLabelTTF",
                    text = tonumber(tCellValue.num),
                    color = ccc3(0x78, 0x25, 0x00)
                },
                strTab[2],
                strTab[3],
                {
                    type = "CCRenderLabel",
                    text = tonumber(tCellValue.add_grain),
                    color = ccc3(0x00, 0xe4, 0xff)
                },
                strTab[4],
                {
                    type = "CCRenderLabel",
                    text = tonumber(tCellValue.add_exp),
                    color = ccc3(0x00, 0xe4, 0xff)
                },
                strTab[5],
                strTab[10]
            }
        }
        --添加“额外获得+名字+图标+数量”
        for k,v in pairs(propData1) do
        	local itemInfo = DB_Item_normal.getDataById(k) or {}
            local imageName = itemInfo.icon_little
        	local element11 = {}
		    	element11.type = "CCRenderLabel"
		    	element11.text = itemInfo.name
		    	element11.color = ccc3(0xe4, 0x00, 0xff)
		    	table.insert(textInfo.elements,element11)
		    	local element12 = {}
		    	element12.type = "CCSprite"
		    	element12.image = "images/base/props/"..imageName
		    	table.insert(textInfo.elements,element12)
		    	local element13 = {}
		    	element13.type = "CCRenderLabel"
		    	element13.text = tonumber(v)
		    	element13.color = ccc3(0x00, 0xe4, 0xff)
		    	table.insert(textInfo.elements,element13)
        end
    end

    local label = LuaCCLabel.createRichLabel(textInfo)
    label:setAnchorPoint(ccp(0, 1))
    label:setPosition(ccp(10, textBg:getContentSize().height-5))
    textBg:addChild(label)

    -- local textInfo2 
    -- if( tonumber(tCellValue.add_level) <= 0 )then
        
    --     for k,v in pairs(propData1) do
    --         local itemInfo = DB_Item_normal.getDataById(k) or {}
    --         local imageName = itemInfo.icon_little
    --         textInfo2 = {
    --             width = 420, -- 宽度
    --             alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
    --             labelDefaultFont = g_sFontName,      -- 默认字体
    --             labelDefaultSize = 18,          -- 默认字体大小
    --             lineAlignment = 2,
    --             linespace = 1, -- 行间距
    --             elements =
    --             {
    --                 strTab[10],
    --                 {
    --                     type = "CCLabelTTF",
    --                     text = itemInfo.name,
    --                     color = ccc3(0xe4, 0x00, 0xff)
    --                 },
    --                 {
    --                     type = "CCSprite",
    --                     image = "images/common/liangcao.png"
    --                 },
    --                 {
    --                     type = "CCRenderLabel",
    --                     text = tonumber(v),
    --                     color = ccc3(0x00, 0xe4, 0xff)
    --                 },
    --             }
    --         }
    --     end
    -- end
    -- print("textInfo2~~~~")
    -- print_t(textInfo2)
    -- local label1 = LuaCCLabel.createRichLabel(textInfo2)
    -- label1:setAnchorPoint(ccp(0,1))
    -- label1:setPosition(ccp(label:getContentSize().width*0.35,label:getContentSize().height*0.5))
    -- label:addChild(label1)
    return tCell
end











