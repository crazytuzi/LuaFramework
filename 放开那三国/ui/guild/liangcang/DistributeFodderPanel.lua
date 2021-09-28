-- Filename: DistributeFodderPanel.lua
-- Author: zhangqiang
-- Date: 2014-11-13
-- Purpsoe: 军团粮草分配界面

module("DistributeFodderPanel", package.seeall)

require "script/ui/guild/GuildDataCache"
require "script/ui/guild/liangcang/BarnData"

local kPanelSize = CCSizeMake(620,770)
local kShieldTouchPriority = -660
local kMenuTouchPriority = -666

local _shieldLayer = nil
local _midLabelTable = nil
local _shareInfo = nil

function init( ... )
	_shieldLayer = nil
	_midLabelTable = nil
	_shareInfo = nil
end

--[[
	pLabelData = {
		{
			str = string,
			font = string,
			size = int,
			color = ccc3,
			px = int
			py = int
			x = int,
			y = int,
		}
	}
--]]
function createLabel( pLabelData, pIsRender )
	local ret = {parent=CCSprite:create(), children={}}

	for k,v in ipairs(pLabelData) do
		local label = pIsRender == true and CCRenderLabel:create(v.str, v.font, v.size, 1, ccc3(0x00,0x00,0x00), type_shadow)
		                                 or CCLabelTTF:create(v.str, v.font, v.size)
		label:setColor(v.color)
		label:setAnchorPoint(ccp(v.px,v.py))
		label:setPosition(v.x, v.y)
		ret.parent:addChild(label)

		ret.children[k] = label
	end

	return ret
end

--[[
	pMenuItemData = {
		{
			str = string
			csize = CCSize  --按钮的拉伸大小
			ssize = int  --str的字体大小
			px = float
			py = float
			x  = int
			y  = ini
			tapCb = function
		}

	}
--]]
function createMenu( pMenuItemData )
	local ret = {parent=CCMenu:create(), children={}}
	ret.parent:setTouchPriority(kMenuTouchPriority)

	require "script/ui/replaceSkill/CreateUI"
	for k,v in ipairs(pMenuItemData) do
		local menuItem = CreateUI.createScale9MenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png", nil,
			                                           v.csize, v.str, v.ssize)
		menuItem:setAnchorPoint(ccp(v.px, v.py))
		menuItem:setPosition(v.x,v.y)
		menuItem:registerScriptTapHandler(v.tapCb)
		ret.parent:addChild(menuItem)
		ret.children[k] = menuItem
	end

	return ret
end

function createPanel( ... )
	local panel = CCScale9Sprite:create("images/battle/report/bg.png")
	panel:setPreferredSize(kPanelSize)

	--标题背景
	local panelTitle = CCSprite:create("images/formation/changeformation/titlebg.png")
	panelTitle:setAnchorPoint(ccp(0.5,0.5))
	panelTitle:setPosition(kPanelSize.width*0.5,kPanelSize.height-6)
	panel:addChild(panelTitle)

	--标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("zz_138"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(156,31)
	panelTitle:addChild(titleLabel)

	-- 第一行 每次分发粮饷后需要等待120个小时后才可再次分发，建议将军团粮仓存储较多粮草后再进行分发
	local needCd = BarnData.getShareFoodCd()
    local textInfo1 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1366",math.ceil(needCd/3600)),
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font1 = LuaCCLabel.createRichLabel(textInfo1)
 	font1:setAnchorPoint(ccp(0.5, 1))
 	font1:setPosition(ccp(panel:getContentSize().width*0.5,panel:getContentSize().height-55))
 	panel:addChild(font1)

	--二级背景
	local secondBg = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	secondBg:setPreferredSize(CCSizeMake(kPanelSize.width-82, 460))
	secondBg:setAnchorPoint(ccp(0.5,1))
	secondBg:setPosition(kPanelSize.width*0.5,font1:getPositionY()-font1:getContentSize().height-10)
	panel:addChild(secondBg)

	--剩余粮草
	local textInfo = {
     		width = 538, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontPangWa,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCRenderLabel", 
	            	text = GetLocalizeStringBy("lic_1370"),
	            	color = ccc3(0xff,0xe4,0x00)
	        	},
	        	{
	            	type = "CCRenderLabel", 
	            	text = string.formatBigNumber(_shareInfo[1].total),
	            	color = ccc3(0x00,0xff,0x18)
	        	},
	        	{
	            	type = "CCRenderLabel", 
	            	text = GetLocalizeStringBy("lic_1371"),
	            	color = ccc3(0xff,0xe4,0x00)
	        	}
	        }
	 	}
 	local font = LuaCCLabel.createRichLabel(textInfo)
 	font:setAnchorPoint(ccp(0.5, 1))
 	font:setPosition(ccp(secondBg:getContentSize().width*0.5,secondBg:getContentSize().height-10))
 	secondBg:addChild(font)

	--军团长官阶为1，对应数据为_shareInfo[2], _shareInfo[1]为当前剩余粮草数
	local midLabelData = {
		[1] = {str=GetLocalizeStringBy("zz_142"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=89, y=358},
		[2] = {str=string.formatBigNumber(_shareInfo[2].share), font=g_sFontName, size=23, color=ccc3(0xff,0xff,0xff), px=0.5, py=0, x=258, y=358},
		[3] = {str=GetLocalizeStringBy("zz_140"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=338, y=358},
		[4] = {str=GetLocalizeStringBy("zz_141",_shareInfo[2].num), font=g_sFontName, size=23, color=ccc3(0x00,0xff,0x18), px=0, py=0, x=413, y=358},

		[5] = {str=GetLocalizeStringBy("zz_143"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=89, y=291},
		[6] = {str=string.formatBigNumber(_shareInfo[3].share), font=g_sFontName, size=23, color=ccc3(0xff,0xff,0xff), px=0.5, py=0, x=258, y=291},
		[7] = {str=GetLocalizeStringBy("zz_140"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=338, y=291},
		[8] = {str=GetLocalizeStringBy("zz_141",_shareInfo[3].num), font=g_sFontName, size=23, color=ccc3(0x00,0xff,0x18), px=0, py=0, x=413, y=291},

		[9] = {str=GetLocalizeStringBy("zz_144"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=89, y=224},
		[10] = {str=string.formatBigNumber(_shareInfo[4].share), font=g_sFontName, size=23, color=ccc3(0xff,0xff,0xff), px=0.5, py=0, x=258, y=224},
		[11] = {str=GetLocalizeStringBy("zz_140"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=338, y=224},
		[12] = {str=GetLocalizeStringBy("zz_141",_shareInfo[4].num), font=g_sFontName, size=23, color=ccc3(0x00,0xff,0x18), px=0, py=0, x=413, y=224},

		[13] = {str=GetLocalizeStringBy("zz_145"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=89, y=157},
		[14] = {str=string.formatBigNumber(_shareInfo[5].share), font=g_sFontName, size=23, color=ccc3(0xff,0xff,0xff), px=0.5, py=0, x=258, y=157},
		[15] = {str=GetLocalizeStringBy("zz_140"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=338, y=157},
		[16] = {str=GetLocalizeStringBy("zz_141",_shareInfo[5].num), font=g_sFontName, size=23, color=ccc3(0x00,0xff,0x18), px=0, py=0, x=413, y=157},

		[17] = {str=GetLocalizeStringBy("zz_146"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=89, y=90},
		[18] = {str=string.formatBigNumber(_shareInfo[6].share), font=g_sFontName, size=23, color=ccc3(0xff,0xff,0xff), px=0.5, py=0, x=258, y=90},
		[19] = {str=GetLocalizeStringBy("zz_140"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=338, y=90},
		[20] = {str=GetLocalizeStringBy("zz_141",_shareInfo[6].num), font=g_sFontName, size=23, color=ccc3(0x00,0xff,0x18), px=0, py=0, x=413, y=90},

		[21] = {str=GetLocalizeStringBy("zz_147"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=89, y=23},
		[22] = {str=string.formatBigNumber(_shareInfo[7].share), font=g_sFontName, size=23, color=ccc3(0xff,0xff,0xff), px=0.5, py=0, x=258, y=23},
		[23] = {str=GetLocalizeStringBy("zz_140"), font=g_sFontName, size=23, color=ccc3(0xff,0xe4,0x00), px=0, py=0, x=338, y=23},
		[24] = {str=GetLocalizeStringBy("zz_141",_shareInfo[7].num), font=g_sFontName, size=23, color=ccc3(0x00,0xff,0x18), px=0, py=0, x=413, y=23},
	}
	_midLabelTable = createLabel(midLabelData, true)
	_midLabelTable.parent:setPosition(0,0)
	secondBg:addChild(_midLabelTable.parent)
	
	-- 第二行 军团职位会随着个人总贡献值的多少进行排名后自动变更（除军团长和副军团长）
    local textInfo2 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1368"),
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font2 = LuaCCLabel.createRichLabel(textInfo2)
 	font2:setAnchorPoint(ccp(0.5, 1))
 	font2:setPosition(ccp(panel:getContentSize().width*0.5, secondBg:getPositionY()-secondBg:getContentSize().height-10))
 	panel:addChild(font2)

 	-- 加入军团未满72小时的玩家无法获得粮草分发
 	local limitTime = BarnData.getShareLimitTime()
 	local limitTipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1590",math.floor(limitTime/3600)), g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    limitTipFont:setColor(ccc3(0x00, 0xff, 0x18))
    limitTipFont:setAnchorPoint(ccp(0.5,1))
    limitTipFont:setPosition(ccp(panel:getContentSize().width*0.5,font2:getPositionY()-font2:getContentSize().height-10))
    panel:addChild(limitTipFont)


 	local menuItemData = {}
 	-- 判断官职 军团长 副军团长才能发 0为平民，1为会长，2为副会长
    if( GuildDataCache.getMineMemberType() ~= 1 and GuildDataCache.getMineMemberType() ~= 2 )then  
    	-- 普通按钮显示关闭
    	menuItemData = {
			[1] = {str=GetLocalizeStringBy("lic_1369"), csize=CCSizeMake(168,65), ssize=30, px=0.5, py=0.5, x=310, y=57, tapCb=tapGoBackBtnCb},
		}
   	else
		--menu 确定按钮 返回按钮
		menuItemData = {
			[1] = {str=GetLocalizeStringBy("zz_148"), csize=CCSizeMake(168,65), ssize=30, px=0.5, py=0.5, x=185, y=57, tapCb=tapComfirmBtnCb},
			[2] = {str=GetLocalizeStringBy("zz_149"), csize=CCSizeMake(168,65), ssize=30, px=0.5, py=0.5, x=437, y=57, tapCb=tapGoBackBtnCb},
		}
	end
	local btnTable = createMenu(menuItemData)
	btnTable.parent:setPosition(0,0)
	panel:addChild(btnTable.parent)

	return panel
end


--[[
	@desc : 显示层
	@param:
	@ret  :
--]]
function showLayer( ... )
	init()

	local getShareInfoCb = function ( pRet )
		require "script/ui/guild/liangcang/BarnData"
		--存储粮草分发信息
		BarnData.setShareInfo(pRet)

		--更新当前军团粮草
		--pRet为数组
		_shareInfo = BarnData.getShareInfo()
		print("getShareInfo total",_shareInfo[1].total)
		GuildDataCache.setGuildGrainNum(tonumber(_shareInfo[1].total))

		-- 刷新粮仓界面粮草
		require "script/ui/guild/liangcang/LiangCangMainLayer"
		LiangCangMainLayer.refreshGuildGrainNum()

		_shieldLayer = CCLayerColor:create(ccc4(0,0,0,150))
		_shieldLayer:registerScriptHandler(onNodeEvent)
		local scene = CCDirector:sharedDirector():getRunningScene()
		_shieldLayer:setPosition(0,0)
		scene:addChild(_shieldLayer)

		local panel = createPanel()
		panel:setPosition(_shieldLayer:getContentSize().width*0.5,_shieldLayer:getContentSize().height*0.5)
		panel:setAnchorPoint(ccp(0.5,0.5))
		_shieldLayer:addChild(panel)
		setAdaptNode(panel)
	end
	require "script/ui/guild/liangcang/BarnService"
	BarnService.getShareInfo(getShareInfoCb)
end

--[[
	@desc : 层回调
	@param:
	@ret  :
--]]
function onNodeEvent( pEventType )
	if pEventType == "enter" then
		print("DistributeFodderPanel")
		_shieldLayer:registerScriptTouchHandler(touchCb, false, kShieldTouchPriority, true)
		_shieldLayer:setTouchEnabled(true)

	elseif pEventType == "exit" then
		_shieldLayer:unregisterScriptTouchHandler()
		_shieldLayer = nil

	else

	end
end

--[[
	@desc : 触摸回调
	@param:
	@ret  :
--]]
function touchCb( pEventType, pTouch )
	if pEventType == "began" then
		return true
	elseif pEventType == "moved" then

	elseif pEventType == "cancelled" then

	else
		-- "ended" 
	end
end

--[[
	@desc : 成功分发粮草后处理
	@param: pRet 后端返回的自己获得的粮草数
	@ret  :
--]]
function shareSuccessful( pRet )
	print("pRet",pRet)
	if( tostring(pRet) == "sharecd" )then
		-- 分粮处于cd之中
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1395"))
		return
    end
	--提示
	require "script/ui/tip/SingleTip"
	local job = nil
	if GuildDataCache.getMineMemberType() == 1 then --军团长
		job = GetLocalizeStringBy("zz_142")
	else
		-- GuildDataCache.getMineMemberType() == 2  --副军团长
		job = GetLocalizeStringBy("zz_143")
	end
	local fodderNum = tonumber(pRet[1])
	print("job",job,"string.formatBigNumber(fodderNum)",string.formatBigNumber(fodderNum))
	require "script/ui/tip/AnimationTip"
	AnimationTip.showTip(GetLocalizeStringBy("zz_150", job, string.formatBigNumber(fodderNum) ))

	-- 从当前军团粮草中减去分发的粮草
	print("all++",pRet[2])
	GuildDataCache.setGuildGrainNum(tonumber(pRet[2]))

	-- 设置粮草分发的cd
	GuildDataCache.setGuildShareNextTime(BTUtil:getSvrTimeInterval() + BarnData.getShareFoodCd())

	-- 刷新其它界面的总粮草数
	require "script/ui/guild/liangcang/LiangCangMainLayer"
	LiangCangMainLayer.refreshUIAfterShare()

	--退出分发界面
	tapGoBackBtnCb(nil,nil)
end

--[[
	@desc : 点击确认分发按钮回调
	@param:
	@ret  :
--]]
function tapComfirmBtnCb( pTag, pItem )

	-- 粮草不足 不让分
    -- 军团粮草
	local guildGrainNum = GuildDataCache.getGuildGrainNum()
	if(guildGrainNum <= 0)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1365"))
		return
    end
    -- 判断官职 军团长 副军团长才能发 0为平民，1为会长，2为副会长
    if( GuildDataCache.getMineMemberType() ~= 1 and GuildDataCache.getMineMemberType() ~= 2 )then  
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1327"))
		return
    end
    -- 判断cd
    -- 下次分粮时间
	local shareNextTime = GuildDataCache.getGuildShareNextTime()
    if( TimeUtil.getSvrTimeByOffset(0) < shareNextTime )then 
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1326"))
		return
    end

    -- 处于抢粮时间段之内不能分
    require "script/ui/guild/guildRobList/GuildRobData"
    local isIn = GuildRobData.isAllRobbing()
    if( isIn )then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1391"))
		return
    end

    -- 自己抢粮争夺战中不能分粮
    local isIn = GuildRobData.isRobbing()
    if( isIn )then
    	require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1357"))
		return
    end

	BarnService.share(shareSuccessful)
end

--[[
	@desc : 点击取消按钮回调
	@param:
	@ret  :
--]]
function tapGoBackBtnCb( pTag, pItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.map3")
	if(_shieldLayer ~= nil)then
		_shieldLayer:removeFromParentAndCleanup(true)
	end
end



