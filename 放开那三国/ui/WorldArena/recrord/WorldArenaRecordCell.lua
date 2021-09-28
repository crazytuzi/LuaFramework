-- FileName: WorldArenaRecordCell.lua 
-- Author: licong 
-- Date: 15/7/4 
-- Purpose: 巅峰对决战报cell 


module("WorldArenaRecordCell", package.seeall)

require "db/DB_World_arena_email"
require "script/ui/WorldArena/reward/WorldArenaRewardData"

local _touchPriority = nil
--[[
	@des 	: 创建tableview cell
	@param 	: 
	@return : 
--]]
function createCell( p_data, p_type, p_touchPriority )
	-- print("p_type==>",p_type)
	-- print_t(p_data)

	_touchPriority = p_touchPriority 
	
 	local cell = CCTableViewCell:create()
    -- 背景
    local cellBg = CCScale9Sprite:create("images/common/bg/y_9s_bg.png")
    cellBg:setContentSize(CCSizeMake(565,170))
    cell:addChild(cellBg)

	-- 文字背景
	local textBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	textBg:setContentSize(CCSizeMake(540,110))
	textBg:setAnchorPoint(ccp(0.5,0))
	textBg:setPosition(ccp(cellBg:getContentSize().width*0.5,15))
	cellBg:addChild(textBg,1,1)

	-- 内容
	local textContent = nil
	if(p_type == 1)then
		textContent = getContiRecordSprie(p_data)
	else
		textContent = getMyRecordSprie(p_data)
	end
	textContent:setAnchorPoint(ccp(0.5,1))
	textContent:setPosition(ccp(textBg:getContentSize().width*0.5,textBg:getContentSize().height - 10 ))
	textBg:addChild(textContent)

	-- 名字
	local dbData = DB_World_arena_email.getDataById(p_data.id)
	local titleFont = CCRenderLabel:create(dbData.name, g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleFont:setColor(ccc3(0x00, 0xff, 0x18))
    titleFont:setAnchorPoint(ccp(0.5,1))
    titleFont:setPosition(ccp(cellBg:getContentSize().width*0.5,cellBg:getContentSize().height-10))
    cellBg:addChild(titleFont)

    -- 时间
    local timeStr = TimeUtil.getTimeFormatYMDHMS( tonumber(p_data.attack_time) )
    local timeFont = CCRenderLabel:create(timeStr, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    timeFont:setColor(ccc3(0x00, 0xff, 0x18))
    timeFont:setAnchorPoint(ccp(0,1))
    timeFont:setPosition(ccp(15,cellBg:getContentSize().height-15))
    cellBg:addChild(timeFont)

    return cell
end


--[[
	@des 	: 得到连杀战报
	@param 	: p_data
	@return : sprite
--]]
function getContiRecordSprie(p_data)
	local tab = {
		createContiRecordSprie1,
		createContiRecordSprie2,	
	}
	local retSprite = tab[p_data.id](p_data)
	return retSprite
end

--[[
	@des 	: 创建连杀战报1
	@param 	: p_data
	@return : sprite
--]]
function createContiRecordSprie1(p_data)
	local dbData = DB_World_arena_email.getDataById(p_data.id)
	local contentTab = string.split(dbData.content,"|")
	local nameColor,nameStrokeColor = getHeroNameColor(p_data.attacker_htid)

	local rewardData = WorldArenaRewardData.getCurKillReward(1,p_data.attacker_conti)
	local rewardTab = ItemUtil.getItemsDataByStr(nil,rewardData)
	local rewardStr = ""
	for k,v in pairs(rewardTab) do
		rewardStr = rewardStr .. v.num .. v.name
	end
	local richInfo = {
		touchPriority = _touchPriority,   -- menu的优先级
		width = 530, -- 宽度
	    alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	    labelDefaultFont = g_sFontName,      -- 默认字体
	    labelDefaultSize = 23,          -- 默认字体大小
	    defaultStrokeColor = ccc3(0xff,0xfb,0xd9),
	    elements =
	    {	
	    	{ type = "CCLabelTTF", 	    text = contentTab[1],  },
	    	{ type = "CCRenderLabel",   text = p_data.attacker_uname .. "(" .. p_data.attacker_server_name ..")",  color = nameColor, strokeColor = nameStrokeColor  },

	    	{ type = "CCLabelTTF", 		text = contentTab[2], },
	    	{ type = "CCRenderLabel",   text = p_data.attacker_conti,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[3], },
	    	{ type = "CCRenderLabel",   text = rewardStr,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[4], },
	    	{ type = "CCMenuItem",
              	newLine = false,
              	create = function()
              		local fontBtn = CCMenuItemFont:create( GetLocalizeStringBy("key_1076") )
              		fontBtn:setFontNameObj(g_sFontPangWa)
              		fontBtn:setFontSizeObj(23)
              		fontBtn:setColor(ccc3(0x00,0xff,0x18))
              		fontBtn:registerScriptTapHandler(function ( ... )
              			-- 查看战报
              			lookBattle( p_data.brid, p_data.result )
              		end)
                	return fontBtn
              	end 
            }
	    	
	    }
	}
	local retNode = LuaCCLabel.createRichLabel(richInfo)
	return retNode
end

--[[
	@des 	: 创建连杀战报2
	@param 	: p_data
	@return : sprite
--]]
function createContiRecordSprie2(p_data)
	local dbData = DB_World_arena_email.getDataById(p_data.id)
	local contentTab = string.split(dbData.content,"|")
	local nameColor1,nameStrokeColor1 = getHeroNameColor(p_data.attacker_htid)
	local nameColor2,nameStrokeColor2 = getHeroNameColor(p_data.defender_htid)

	local rewardData = WorldArenaRewardData.getCurKillReward(2,p_data.attacker_terminal_conti)
	local rewardTab = ItemUtil.getItemsDataByStr(nil,rewardData)
	local rewardStr = ""
	for k,v in pairs(rewardTab) do
		rewardStr = rewardStr .. v.num .. v.name
	end
	local richInfo = {
		touchPriority = _touchPriority,   -- menu的优先级
		width = 530, -- 宽度
	    alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	    labelDefaultFont = g_sFontName,      -- 默认字体
	    labelDefaultSize = 23,          -- 默认字体大小
	    defaultStrokeColor = ccc3(0xff,0xfb,0xd9),
	    elements =
	    {	
	    	{ type = "CCLabelTTF", 	    text = contentTab[1],  },
	    	{ type = "CCRenderLabel",   text = p_data.attacker_uname .. "(" .. p_data.attacker_server_name ..")",  color = nameColor1, strokeColor = nameStrokeColor1  },

	    	{ type = "CCLabelTTF", 		text = contentTab[2], },
	    	{ type = "CCRenderLabel",   text = p_data.defender_uname .. "(" .. p_data.defender_server_name ..")",  color = nameColor2, strokeColor = nameStrokeColor2  },

	    	{ type = "CCLabelTTF", text = contentTab[3], },
	    	{ type = "CCRenderLabel",   text = p_data.attacker_terminal_conti,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[4], },
	    	{ type = "CCRenderLabel",   text = rewardStr,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[5], },
	    	{ type = "CCMenuItem",
              	newLine = false,
              	create = function()
              		local fontBtn = CCMenuItemFont:create( GetLocalizeStringBy("key_1076") )
              		fontBtn:setFontNameObj(g_sFontPangWa)
              		fontBtn:setFontSizeObj(23)
              		fontBtn:setColor(ccc3(0x00,0xff,0x18))
              		fontBtn:registerScriptTapHandler(function ( ... )
              			-- 查看战报
              			lookBattle( p_data.brid, p_data.result )
              		end)
                	return fontBtn
              	end 
            }
	    	
	    }
	}
	local retNode = LuaCCLabel.createRichLabel(richInfo)
	return retNode
end


--[[
	@des 	: 得到我的战报
	@param 	: p_data
	@return : sprite
--]]
function getMyRecordSprie( p_data )
	local retSprite = nil
	local tab = {
		1,2,
		createMyRecordSprie3,
		createMyRecordSprie4,
		createMyRecordSprie5,
		createMyRecordSprie6,
		createMyRecordSprie7,
		createMyRecordSprie8,
		createMyRecordSprie9,	
	}
	local retSprite = tab[p_data.id](p_data)
	return retSprite
end

--[[
	@des 	: 创建我的战报3
	@param 	: p_data
	@return : sprite
--]]
function createMyRecordSprie3(p_data)
	local dbData = DB_World_arena_email.getDataById(p_data.id)
	local contentTab = string.split(dbData.content,"|")
	local nameColor,nameStrokeColor = getHeroNameColor(p_data.attacker_htid)

	local richInfo = {
		touchPriority = _touchPriority,   -- menu的优先级
		width = 530, -- 宽度
	    alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	    labelDefaultFont = g_sFontName,      -- 默认字体
	    labelDefaultSize = 23,          -- 默认字体大小
	    defaultStrokeColor = ccc3(0xff,0xfb,0xd9),
	    elements =
	    {	
	    	{ type = "CCLabelTTF", 	    text = contentTab[1],  },
	    	{ type = "CCRenderLabel",   text = p_data.attacker_uname .. "(" .. p_data.attacker_server_name ..")",  color = nameColor, strokeColor = nameStrokeColor  },

	    	{ type = "CCLabelTTF", 		text = contentTab[2], },

	    	{ type = "CCMenuItem",
              	newLine = false,
              	create = function()
              		local fontBtn = CCMenuItemFont:create( GetLocalizeStringBy("key_1076") )
              		fontBtn:setFontNameObj(g_sFontPangWa)
              		fontBtn:setFontSizeObj(23)
              		fontBtn:setColor(ccc3(0x00,0xff,0x18))
              		fontBtn:registerScriptTapHandler(function ( ... )
              			-- 查看战报
              			lookBattle( p_data.brid, p_data.result )
              		end)
                	return fontBtn
              	end 
            }
	    	
	    }
	}
	local retNode = LuaCCLabel.createRichLabel(richInfo)
	return retNode
end

--[[
	@des 	: 创建我的战报4
	@param 	: p_data
	@return : sprite
--]]
function createMyRecordSprie4(p_data)
	local dbData = DB_World_arena_email.getDataById(p_data.id)
	local contentTab = string.split(dbData.content,"|")
	local nameColor,nameStrokeColor = getHeroNameColor(p_data.defender_htid)

	local rewardData = WorldArenaRewardData.getCurKillReward(1,p_data.attacker_conti)
	-- print("createMyRecordSprie4 rewardData")
	-- print_t(rewardData)
	local rewardTab = ItemUtil.getItemsDataByStr(nil,rewardData)
	local rewardStr = ""
	for k,v in pairs(rewardTab) do
		rewardStr = rewardStr .. v.num .. v.name
	end
	local richInfo = {
		touchPriority = _touchPriority,   -- menu的优先级
		width = 530, -- 宽度
	    alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	    labelDefaultFont = g_sFontName,      -- 默认字体
	    labelDefaultSize = 23,          -- 默认字体大小
	    defaultStrokeColor = ccc3(0xff,0xfb,0xd9),
	    elements =
	    {	
	    	{ type = "CCLabelTTF", 	    text = contentTab[1],  },
	    	{ type = "CCRenderLabel",   text = p_data.defender_uname .. "(" .. p_data.defender_server_name ..")",  color = nameColor, strokeColor = nameStrokeColor  },

	    	{ type = "CCLabelTTF", 		text = contentTab[2], },
	    	{ type = "CCRenderLabel",   text = p_data.attacker_conti,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[3], },
	    	{ type = "CCRenderLabel",   text = rewardStr,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[4], },
	    	{ type = "CCRenderLabel",   text = p_data.defender_rank,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[5], },
	    	{ type = "CCMenuItem",
              	newLine = false,
              	create = function()
              		local fontBtn = CCMenuItemFont:create( GetLocalizeStringBy("key_1076") )
              		fontBtn:setFontNameObj(g_sFontPangWa)
              		fontBtn:setFontSizeObj(23)
              		fontBtn:setColor(ccc3(0x00,0xff,0x18))
              		fontBtn:registerScriptTapHandler(function ( ... )
              			-- 查看战报
              			lookBattle( p_data.brid, p_data.result )
              		end)
                	return fontBtn
              	end 
            }
	    	
	    }
	}
	local retNode = LuaCCLabel.createRichLabel(richInfo)
	return retNode
end


--[[
	@des 	: 创建我的战报5
	@param 	: p_data
	@return : sprite
--]]
function createMyRecordSprie5(p_data)
	local dbData = DB_World_arena_email.getDataById(p_data.id)
	local contentTab = string.split(dbData.content,"|")
	local nameColor,nameStrokeColor = getHeroNameColor(p_data.attacker_htid)

	local richInfo = {
		touchPriority = _touchPriority,   -- menu的优先级
		width = 530, -- 宽度
	    alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	    labelDefaultFont = g_sFontName,      -- 默认字体
	    labelDefaultSize = 23,          -- 默认字体大小
	    defaultStrokeColor = ccc3(0xff,0xfb,0xd9),
	    elements =
	    {	
	    	{ type = "CCLabelTTF", 	    text = contentTab[1],  },
	    	{ type = "CCRenderLabel",   text = p_data.attacker_uname .. "(" .. p_data.attacker_server_name ..")",  color = nameColor, strokeColor = nameStrokeColor  },

	    	{ type = "CCLabelTTF", 		text = contentTab[2], },
	    	{ type = "CCRenderLabel",   text = p_data.attacker_terminal_conti,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[3], },
	    	
	    	{ type = "CCMenuItem",
              	newLine = false,
              	create = function()
              		local fontBtn = CCMenuItemFont:create( GetLocalizeStringBy("key_1076") )
              		fontBtn:setFontNameObj(g_sFontPangWa)
              		fontBtn:setFontSizeObj(23)
              		fontBtn:setColor(ccc3(0x00,0xff,0x18))
              		fontBtn:registerScriptTapHandler(function ( ... )
              			-- 查看战报
              			lookBattle( p_data.brid, p_data.result )
              		end)
                	return fontBtn
              	end 
            }
	    	
	    }
	}
	local retNode = LuaCCLabel.createRichLabel(richInfo)
	return retNode
end

--[[
	@des 	: 创建我的战报6
	@param 	: p_data
	@return : sprite
--]]
function createMyRecordSprie6(p_data)
	local dbData = DB_World_arena_email.getDataById(p_data.id)
	local contentTab = string.split(dbData.content,"|")
	local nameColor,nameStrokeColor = getHeroNameColor(p_data.defender_htid)

	local richInfo = {
		touchPriority = _touchPriority,   -- menu的优先级
		width = 530, -- 宽度
	    alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	    labelDefaultFont = g_sFontName,      -- 默认字体
	    labelDefaultSize = 23,          -- 默认字体大小
	    defaultStrokeColor = ccc3(0xff,0xfb,0xd9),
	    elements =
	    {	
	    	{ type = "CCLabelTTF", 	    text = contentTab[1],  },
	    	{ type = "CCRenderLabel",   text = p_data.defender_uname .. "(" .. p_data.defender_server_name ..")",  color = nameColor, strokeColor = nameStrokeColor  },

	    	{ type = "CCLabelTTF", 		text = contentTab[2], },
	    	
	    	{ type = "CCMenuItem",
              	newLine = false,
              	create = function()
              		local fontBtn = CCMenuItemFont:create( GetLocalizeStringBy("key_1076") )
              		fontBtn:setFontNameObj(g_sFontPangWa)
              		fontBtn:setFontSizeObj(23)
              		fontBtn:setColor(ccc3(0x00,0xff,0x18))
              		fontBtn:registerScriptTapHandler(function ( ... )
              			-- 查看战报
              			lookBattle( p_data.brid, p_data.result )
              		end)
                	return fontBtn
              	end 
            }
	    	
	    }
	}
	local retNode = LuaCCLabel.createRichLabel(richInfo)
	return retNode
end

--[[
	@des 	: 创建我的战报7
	@param 	: p_data
	@return : sprite
--]]
function createMyRecordSprie7(p_data)
	local dbData = DB_World_arena_email.getDataById(p_data.id)
	local contentTab = string.split(dbData.content,"|")
	local nameColor,nameStrokeColor = getHeroNameColor(p_data.defender_htid)

	local rewardData = WorldArenaRewardData.getCurKillReward(1,p_data.attacker_conti)
	-- print("createMyRecordSprie7 rewardData")
	-- print_t(rewardData)
	local rewardTab = ItemUtil.getItemsDataByStr(nil,rewardData)
	local rewardStr = ""
	for k,v in pairs(rewardTab) do
		rewardStr = rewardStr .. v.num .. v.name
	end
	local richInfo = {
		touchPriority = _touchPriority,   -- menu的优先级
		width = 530, -- 宽度
	    alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	    labelDefaultFont = g_sFontName,      -- 默认字体
	    labelDefaultSize = 23,          -- 默认字体大小
	    defaultStrokeColor = ccc3(0xff,0xfb,0xd9),
	    elements =
	    {	
	    	{ type = "CCLabelTTF", 	    text = contentTab[1],  },
	    	{ type = "CCRenderLabel",   text = p_data.defender_uname .. "(" .. p_data.defender_server_name ..")",  color = nameColor, strokeColor = nameStrokeColor  },

	    	{ type = "CCLabelTTF", 		text = contentTab[2], },
	    	{ type = "CCRenderLabel",   text = p_data.attacker_conti,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[3], },
	    	{ type = "CCRenderLabel",   text = rewardStr,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[4], },

	    	{ type = "CCMenuItem",
              	newLine = false,
              	create = function()
              		local fontBtn = CCMenuItemFont:create( GetLocalizeStringBy("key_1076") )
              		fontBtn:setFontNameObj(g_sFontPangWa)
              		fontBtn:setFontSizeObj(23)
              		fontBtn:setColor(ccc3(0x00,0xff,0x18))
              		fontBtn:registerScriptTapHandler(function ( ... )
              			-- 查看战报
              			lookBattle( p_data.brid, p_data.result )
              		end)
                	return fontBtn
              	end 
            }
	    	
	    }
	}
	local retNode = LuaCCLabel.createRichLabel(richInfo)
	return retNode
end

--[[
	@des 	: 创建我的战报8
	@param 	: p_data
	@return : sprite
--]]
function createMyRecordSprie8(p_data)
	local dbData = DB_World_arena_email.getDataById(p_data.id)
	local contentTab = string.split(dbData.content,"|")
	local nameColor,nameStrokeColor = getHeroNameColor(p_data.defender_htid)

	local richInfo = {
		touchPriority = _touchPriority,   -- menu的优先级
		width = 530, -- 宽度
	    alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	    labelDefaultFont = g_sFontName,      -- 默认字体
	    labelDefaultSize = 23,          -- 默认字体大小
	    defaultStrokeColor = ccc3(0xff,0xfb,0xd9),
	    elements =
	    {	
	    	{ type = "CCLabelTTF", 	    text = contentTab[1],  },
	    	{ type = "CCRenderLabel",   text = p_data.defender_uname .. "(" .. p_data.defender_server_name ..")",  color = nameColor, strokeColor = nameStrokeColor  },

	    	{ type = "CCLabelTTF", text = contentTab[2], },
	    	{ type = "CCRenderLabel",   text = p_data.defender_rank,  color = ccc3(0x00,0xff,0x18),  strokeColor = ccc3(0x00,0x00,0x00)  },

	    	{ type = "CCLabelTTF", text = contentTab[3], },

	    	{ type = "CCMenuItem",
              	newLine = false,
              	create = function()
              		local fontBtn = CCMenuItemFont:create( GetLocalizeStringBy("key_1076") )
              		fontBtn:setFontNameObj(g_sFontPangWa)
              		fontBtn:setFontSizeObj(23)
              		fontBtn:setColor(ccc3(0x00,0xff,0x18))
              		fontBtn:registerScriptTapHandler(function ( ... )
              			-- 查看战报
              			lookBattle( p_data.brid, p_data.result )
              		end)
                	return fontBtn
              	end 
            }
	    	
	    }
	}
	local retNode = LuaCCLabel.createRichLabel(richInfo)
	return retNode
end

--[[
	@des 	: 创建我的战报9
	@param 	: p_data
	@return : sprite
--]]
function createMyRecordSprie9(p_data)
	local dbData = DB_World_arena_email.getDataById(p_data.id)
	local contentTab = string.split(dbData.content,"|")
	local nameColor,nameStrokeColor = getHeroNameColor(p_data.defender_htid)

	local richInfo = {
		touchPriority = _touchPriority,   -- menu的优先级
		width = 530, -- 宽度
	    alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	    labelDefaultFont = g_sFontName,      -- 默认字体
	    labelDefaultSize = 23,          -- 默认字体大小
	    defaultStrokeColor = ccc3(0xff,0xfb,0xd9),
	    elements =
	    {	
	    	{ type = "CCLabelTTF", 	    text = contentTab[1],  },
	    	{ type = "CCRenderLabel",   text = p_data.defender_uname .. "(" .. p_data.defender_server_name ..")",  color = nameColor, strokeColor = nameStrokeColor  },

	    	{ type = "CCLabelTTF", text = contentTab[2], },

	    	{ type = "CCMenuItem",
              	newLine = false,
              	create = function()
              		local fontBtn = CCMenuItemFont:create( GetLocalizeStringBy("key_1076") )
              		fontBtn:setFontNameObj(g_sFontPangWa)
              		fontBtn:setFontSizeObj(23)
              		fontBtn:setColor(ccc3(0x00,0xff,0x18))
              		fontBtn:registerScriptTapHandler(function ( ... )
              			-- 查看战报
              			lookBattle( p_data.brid, p_data.result )
              		end)
                	return fontBtn
              	end 
            }
	    	
	    }
	}
	local retNode = LuaCCLabel.createRichLabel(richInfo)
	return retNode
end


--[[
	@des 	: 得到玩家名字颜色
	@param 	: p_htid
	@return : 
--]]
function getHeroNameColor( p_htid )
	local name_color = nil
	local stroke_color = nil
	local genderId = HeroModel.getSex(p_htid)
	if( genderId == 2)then
		-- 女性玩家
		name_color = ccc3(0xf9,0x59,0xff)
		stroke_color = ccc3(0x00,0x00,0x00)
	elseif( genderId == 1)then
		-- 男性玩家 
		name_color = ccc3(0x00,0xe4,0xff)
		stroke_color = ccc3(0x00,0x00,0x00)
	else
		name_color = ccc3(0x00,0xe4,0xff)
		stroke_color = ccc3(0x00,0x00,0x00)
	end
	return name_color, stroke_color
end

--[[
	@des 	: 查看战报
	@param 	: 
	@return : 
--]]
function lookBattle( p_brid, p_result ) 
	local nextCallFun = function ( p_retData )
		-- 播放战斗
		require "script/battle/BattleLayer"
		require "script/ui/WorldArena/WorldArenaAfterBattle"
		if( tonumber(p_result) == 1)then
			isWin = true
		else
			isWin = false
		end
	 	local layer = WorldArenaAfterBattle.createLayer( -600, isWin, flyCallFun )
	    BattleLayer.showBattleWithString(p_retData, nil, layer, "zhiyanzhanchang.jpg","music11.mp3")
	end
	require "script/ui/WorldArena/recrord/WorldArenaRecordService"
	WorldArenaRecordService.getRecord(p_brid, nextCallFun)
end
