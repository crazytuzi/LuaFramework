-- Filename: DestinyUtil.lua
-- Author: zhz
-- Date: 2013-12-19
-- Purpose: 天命系统的一些方法

module ("DestinyUtil", package.seeall)


require "db/DB_Destiny"
require "db/DB_Break"
require "script/ui/destiny/DestinyData"
require "script/model/hero/HeroModel"
require "script/model/user/UserModel"
require "script/utils/BaseUI"

local IMG_PATH = "images/destney/"

-- 通过ID创建天命星座的按钮
function createStarItemById(id )

	print("id is 1"  , id )

	local destinyData--= DB_Destiny.getDataById(id)
	local colour= nil
	local item_btn
	local iconFile=nil
	local guanFile= nil
	local xhFile= nil
	-- or DestinyData.getUpDestiny()== nil 
	if(id== nil ) then
		item_btn = CCMenuItemImage:create(IMG_PATH.."destiny_grey.png",IMG_PATH.."destiny_grey.png")
		return item_btn
	end
	if(id == DestinyData.getCurDestiny() ) then
		if(not DestinyData.isBreakById(id) ) then
			destinyData= DB_Destiny.getDataById(id)
			local colour= destinyData.colour -- tonumber(lua_string_split(destinyData.attArr, "|")[1])
			print("colour  is : +++++++++++++   ", colour )
			-- 统帅-绿色  生命-绿色
			if(colour == 1 or colour == 6) then
				iconFile=  IMG_PATH.."destiny_blue.png"
				guanFile= IMG_PATH .. "effect/lvdou/lvdou"
				xhFile= IMG_PATH .. "effect/lvdouxh/lvdouxh"
			-- 武力-红色  攻击-红色
			elseif(colour==7 or colour == 9) then
				iconFile=  IMG_PATH.."destiny_red.png"
				guanFile=  IMG_PATH.."effect/hongguang/hongguang"
				xhFile= IMG_PATH .. "effect/hongxh/hongxh"

			-- 智力-黄色  法防-黄色	
			elseif(colour==8 or colour == 5) then
				iconFile = IMG_PATH.. "destiny_yellow.png"
				guanFile=  IMG_PATH.."effect/huangguang/huangguang"
				xhFile= IMG_PATH .. "effect/huangxh/huangxh"
			-- 物防-蓝色	
			elseif(colour== 4 ) then
				iconFile = IMG_PATH.."destiny_green.png"
				guanFile=  IMG_PATH.."effect/languang/languang"
				xhFile= IMG_PATH .. "effect/lanxh/lanxh"
			end
		else
			iconFile= IMG_PATH.."destiny_break_h.png"
			guanFile=  IMG_PATH.."effect/ziguang/ziguang"
		end
	elseif(id ==  DestinyData.getCurDestiny()+1) then 
		if(not DestinyData.isBreakById(id)) then
			iconFile= IMG_PATH.."destiny_grey.png"
			guanFile=  IMG_PATH.."effect/huiquan/huiquan"
		else
			iconFile= IMG_PATH.."destiny_break_n.png"
			guanFile=  IMG_PATH.."effect/huiquan/huiquan"
		end
	else
		if(DestinyData.isBreakById(id)) then
			iconFile = IMG_PATH.."destiny_break_n.png"
		else
			print("id is 2"  , id )
			iconFile = IMG_PATH.."destiny_grey.png"
		end	 
	end	


	-- print("guanEffect  is :  ",guanFile)
	item_btn= CCMenuItemImage:create(iconFile,iconFile)

	if(guanFile~= nil ) then
		local guanEffect =  CCLayerSprite:layerSpriteWithName(CCString:create(guanFile), -1,CCString:create(""))
		-- 适配
		guanEffect:setPosition(ccp(item_btn:getContentSize().width*0.5,item_btn:getContentSize().height*0.5))
		guanEffect:setAnchorPoint(ccp(0.5,0.5))
		item_btn:addChild(guanEffect,-1)
	end

	if(xhFile~= nil) then
		local xhEffect = CCLayerSprite:layerSpriteWithName(CCString:create(xhFile), -1,CCString:create(""))
		xhEffect:setPosition(ccp(item_btn:getContentSize().width*0.5,item_btn:getContentSize().height*0.5))
		xhEffect:setAnchorPoint(ccp(0.5,0.5))
		item_btn:addChild(xhEffect)
	end

	return item_btn
end

-- 获得前一个天命系统的
function getPreDestinyItem( )
	--得到当前天命信息
	--也就是最左边那个
	local destinyId= DestinyData.getCurDestiny()
	local item = createStarItemById(destinyId)
	return item 
end

-- 获得当前升级的天命星座
function getCurDestinyItem( )
	--得到中间天命的信息
	local destinyId= DestinyData.getUpDestiny()
	local item = createStarItemById(destinyId)
	return item 
end

-- 获得下一个升级的天命星座
function getAftDestinyItem( )
	local destinyId= DestinyData.getAftDestiny()
	print("id is 0"  , destinyId )
	local item = createStarItemById(destinyId)
	return item 
end

-- 得到当前玩家背景图 武将性别 1男，2女
function getCurHeroBg( )
	local heroBg=nil 
	local htid = UserModel.getAvatarHtid()
	--先分为男女，之后每种再分为进阶前和进阶后
	if(HeroModel.getSex(htid)==1 ) then
		if(DestinyData.getCurBreak() < 1) then
			-- 蓝色
			heroBg= CCSprite:create(IMG_PATH .. "boy_break_0.png")
		elseif(DestinyData.getCurBreak() >= 1 and DestinyData.getCurBreak() < 4)then
			-- 紫色
			heroBg=CCSprite:create(IMG_PATH.. "boy_break_1.png")
		elseif(DestinyData.getCurBreak() >= 4 and DestinyData.getCurBreak() < 6) then
			-- 橙色
			heroBg=CCSprite:create(IMG_PATH.. "boy_break_2.png")
		elseif(DestinyData.getCurBreak() >= 6) then
			-- 红色
			heroBg=CCSprite:create(IMG_PATH.. "boy_break_3.png")
		elseif(DestinyData.getCurBreak() >= 8) then
			-- 金色
			heroBg=CCSprite:create(IMG_PATH.. "boy_break_4.png")
		else
			heroBg = CCSprite:create()
		end
	elseif(HeroModel.getSex(htid)== 2) then
		if(DestinyData.getCurBreak() < 1) then
			-- 蓝色
			heroBg= CCSprite:create(IMG_PATH .. "girl_break_0.png")
		elseif(DestinyData.getCurBreak() >= 1 and DestinyData.getCurBreak() < 4)then
			-- 紫色
			heroBg=CCSprite:create(IMG_PATH.. "girl_break_1.png")
		elseif(DestinyData.getCurBreak() >= 4 and DestinyData.getCurBreak() < 6) then
			-- 橙色
			heroBg=CCSprite:create(IMG_PATH.. "girl_break_2.png")
		elseif(DestinyData.getCurBreak() >= 6) then
			-- 红色
			heroBg=CCSprite:create(IMG_PATH.. "girl_break_3.png")
		elseif (DestinyData.getCurBreak() >= 8) then
			-- 金色
			heroBg=CCSprite:create(IMG_PATH.. "girl_break_4.png")
		else
			heroBg = CCSprite:create()
		end
	end
	return heroBg
end

function getSealNode(  )
	local attArr= DestinyData.getUpProperty()
	-- attArr = 
	local sealContent={}
	for i=1, #attArr do 
		local propertyTable= lua_string_split(attArr[i],"|")
		local affixDesc, displayNum, realNum= ItemUtil.getAtrrNameAndNum(propertyTable[1], propertyTable[2])
		sealContent[i]= getSealSprite(affixDesc.displayName, displayNum)
	end
	local sealNode= BaseUI.createHorizontalNode(sealContent)
	return sealNode

end

function getSealSprite(displayName, displayNum )
	local content ={}
	content[1]=  CCSprite:create("images/common/bg/red_seal_bg.png")
--	local affixLabel= CCRenderLabel:create(displayName ,g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	local affixLabel= CCLabelTTF:create(displayName ,g_sFontName, 22)
	affixLabel:setColor(ccc3(0xff,0xff,0xff))
	affixLabel:setPosition(content[1]:getContentSize().width/2, content[1]:getContentSize().height/2)
	affixLabel:setAnchorPoint(ccp(0.5,0.5))
	content[1]:addChild(affixLabel)
--	content[2]=CCRenderLabel:create("+" .. displayNum .. "",g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	content[2]=CCLabelTTF:create("+" .. displayNum .. "",g_sFontName, 21)
	content[2]:setColor(ccc3(0x70,0xff,0x18))
	content[3]=CCLabelTTF:create(" ",g_sFontName, 21)--, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)

	local node = BaseUI.createHorizontalNode(content)
	return node 
end




