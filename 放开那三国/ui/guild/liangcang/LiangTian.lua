-- FileName: LiangTian.lua 
-- Author: licong 
-- Date: 14-11-6 
-- Purpose: 粮田类 

require "script/ui/guild/GuildDataCache"
require "script/ui/guild/liangcang/BarnData"

LiangTian = class("LiangTian", function ()
	return CCSprite:create()
end)

LiangTian.bgButton 				= nil -- 粮田背景
LiangTian.infoSprite          	= nil -- 粮田信息sprite
LiangTian.id          			= nil -- 粮田id

-------------------------------------私有函数--------------------------------
--[[
	@des 	:没有开启的粮田
	@param 	:p_id 粮田的数据
	@return :sprite
--]]
local notOpneLinagtan = function ( p_id )
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(93,60))

	-- 名字
	-- local nameStr = BarnData.getNameById(p_id)
	-- local nameLabel = CCRenderLabel:create(nameStr, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
 	-- nameLabel:setColor(ccc3(0xff,0xf6,0x00))
	-- nameLabel:setAnchorPoint(ccp(0.5,1))
	-- nameLabel:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height))
	-- retSprite:addChild(nameLabel)
	-- 锁
	local lockSp = CCSprite:create("images/guild/liangcang/lock.png")
	lockSp:setAnchorPoint(ccp(0.5,0))
	lockSp:setPosition(ccp(retSprite:getContentSize().width*0.5,0))
	retSprite:addChild(lockSp)

	-- 开启等级提示
	local fontTab = {}
    fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1328"), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab[1]:setColor(ccc3(0x00,0xff,0x18))
    local needLv = BarnData.getOpenLiangTianNeedLv(p_id)
    fontTab[2] = CCRenderLabel:create("LV." .. needLv, g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab[2]:setColor(ccc3(0xff,0xf6,0x00))
    fontTab[3] = CCRenderLabel:create(GetLocalizeStringBy("lic_1329"), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab[3]:setColor(ccc3(0x00,0xff,0x18))
    local fontNode = BaseUI.createHorizontalNode(fontTab)
    fontNode:setAnchorPoint(ccp(0.5,0))
	fontNode:setPosition(ccp(lockSp:getContentSize().width*0.5,0))
	lockSp:addChild(fontNode)

	return retSprite
end

--[[
	@des 	:已经开启的粮田
	@param 	:p_id 粮田的数据
	@return :sprite
--]]
local alreadyOpneLinagtan = function ( p_id )
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(93,40))

	-- 名字
	-- local nameStr = BarnData.getNameById(p_id)
	-- local nameLabel = CCRenderLabel:create(nameStr, g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
 	-- nameLabel:setColor(ccc3(0xff,0xf6,0x00))
	-- nameLabel:setAnchorPoint(ccp(0.5,1))
	-- nameLabel:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height))
	-- retSprite:addChild(nameLabel)

	-- 粮田等级
	-- 粮田累计最大采集次数
	local maxCollectNum = BarnData.getLiangTianCollectMaxNum()
	-- 剩余采集次数，当前等级，总经验
    local surplusCollectNum,curLv,curAllExp = GuildDataCache.getSurplusCollectNumAndExpLv(p_id)
    -- 粮田升级经验id
    local curExpId = BarnData.getLiangTianExpId(p_id)
    -- 当前等级，结余经验，下级需要经验
   	local a,realExpNum,needExpNum = LevelUpUtil.getLvByExp(curExpId,curAllExp)
   	-- 当前粮田的最大等级
   	local curMaxLv = BarnData.getLiangTianMaxLvNum( p_id )
   	-- 描述node
    local nodeArr = {}
    -- 等级
    local lvSp = CCSprite:create("images/common/lv.png")
    table.insert(nodeArr,lvSp)
    local lvFont = CCRenderLabel:create(curLv .. " ", g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvFont:setColor(ccc3(0xff, 0xf6, 0x00))
    table.insert(nodeArr,lvFont)
    -- 经验条
    local rate = 0
    local expStr = nil
    if( curLv < curMaxLv )then
		rate = realExpNum/needExpNum
		if(rate > 1)then
			rate = 1
		end
		expStr = realExpNum .. "/" .. needExpNum
	else
		rate = 1
		expStr = "Max"
	end
    -- expbg
    local bgProress = CCScale9Sprite:create("images/common/exp_bg.png")
	bgProress:setContentSize(CCSizeMake(120, 23))
	table.insert(nodeArr,bgProress)
	-- 蓝条
	local progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
	progressSp:setContentSize(CCSizeMake(120*rate, 23))
	progressSp:setAnchorPoint(ccp(0, 0.5))
	progressSp:setPosition(ccp(0, bgProress:getContentSize().height * 0.5))
	bgProress:addChild(progressSp)
	-- 经验值
	local expLabel = CCRenderLabel:create(expStr, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	expLabel:setColor(ccc3(0xff, 0xff, 0xff))
	expLabel:setAnchorPoint(ccp(0.5, 0.5))
	expLabel:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height*0.5))
	bgProress:addChild(expLabel)
	-- 提示
    local expNode = BaseUI.createHorizontalNode(nodeArr)
    expNode:setAnchorPoint(ccp(0.5,0.5))
    expNode:setPosition( retSprite:getContentSize().width*0.5 , retSprite:getContentSize().height)
    retSprite:addChild(expNode)

	-- 采集次数
	local collectNumLabel = CCRenderLabel:create( GetLocalizeStringBy("lic_1332",surplusCollectNum,maxCollectNum), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	collectNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
	collectNumLabel:setAnchorPoint(ccp(0.5, 0))
	collectNumLabel:setPosition(ccp(retSprite:getContentSize().width*0.5, 0))
	retSprite:addChild(collectNumLabel)

	return retSprite
end


-------------------------------------公用函数--------------------------------
--[[
	@des 	:创建一个粮田的方法
	@param 	:p_id 粮田的id
	@return :sprite
--]]
function LiangTian:create( p_id )
	local liantianSp = LiangTian:new()

	-- 粮田大小
	liantianSp:setContentSize(CCSizeMake(187,169))

	-- 粮田的id
	liantianSp.id = tonumber(p_id)
	-- 是否开启粮田
	local isOpen = BarnData.getLiangTianIsOpenById(liantianSp.id)

	-- 粮田背景
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	liantianSp:addChild(menu)

	-- 空白区域
	local item_sprite_n = CCSprite:create()
	item_sprite_n:setContentSize(CCSizeMake(90,80))
	local item_sprite_h = CCSprite:create()
	item_sprite_h:setContentSize(CCSizeMake(90,80))

	-- 粮田
	local file_n = nil
	local file_h = nil
	if(isOpen)then
		file_n = "images/guild/liangcang/liangtian/1_n.png"
		file_h = "images/guild/liangcang/liangtian/1_h.png"
	else
		file_n = "images/guild/liangcang/liangtian/1_hui.png"
		file_h = "images/guild/liangcang/liangtian/1_hui.png"
	end
	local liangtian_sprite_n = CCSprite:create(file_n)
	liangtian_sprite_n:setAnchorPoint(ccp(0.5, 0.5))
	liangtian_sprite_n:setPosition(ccp(item_sprite_n:getContentSize().width*0.5, item_sprite_n:getContentSize().height*0.5))
	item_sprite_n:addChild(liangtian_sprite_n)

	local liangtian_sprite_h = CCSprite:create(file_h)
	liangtian_sprite_h:setAnchorPoint(ccp(0.5, 0.5))
	liangtian_sprite_h:setPosition(ccp(item_sprite_h:getContentSize().width*0.5, item_sprite_h:getContentSize().height*0.5))
	item_sprite_h:addChild(liangtian_sprite_h)

	liantianSp.bgButton = CCMenuItemSprite:create(item_sprite_n, item_sprite_h)
	liantianSp.bgButton:setAnchorPoint(ccp(0.5, 0.5))
	liantianSp.bgButton:setPosition(ccp(liantianSp:getContentSize().width*0.5, liantianSp:getContentSize().height*0.5))
	menu:addChild(liantianSp.bgButton,1,liantianSp.id)

	-- 创建粮田上元素
	if(isOpen)then
		liantianSp.infoSprite = alreadyOpneLinagtan(liantianSp.id)
		liantianSp.infoSprite:setAnchorPoint(ccp(0.5,0))
		liantianSp.infoSprite:setPosition(ccp(liantianSp:getContentSize().width*0.5,-2))
	else
		liantianSp.infoSprite = notOpneLinagtan(liantianSp.id)
		liantianSp.infoSprite:setAnchorPoint(ccp(0.5,0.5))
		liantianSp.infoSprite:setPosition(ccp(liantianSp:getContentSize().width*0.5,liantianSp:getContentSize().height*0.5))
	end
	liantianSp:addChild(liantianSp.infoSprite)

	-- 粮田的序号
	local xuSp = CCSprite:create("images/guild/liangcang/xuhao.png")
	xuSp:setAnchorPoint(ccp(0,0.5))
	xuSp:setPosition(ccp(0,liantianSp:getContentSize().height*0.7))
	liantianSp:addChild(xuSp,100)
	local xuFont = CCRenderLabel:create(liantianSp.id, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    xuFont:setColor(ccc3(0xff, 0xf6, 0x00))
    xuFont:setAnchorPoint(ccp(0.5,0.5))
    xuFont:setPosition(xuSp:getContentSize().width*0.5,xuSp:getContentSize().height*0.5)
    xuSp:addChild(xuFont)

	return liantianSp
end


--[[
	@des 	:注册回调
	@param 	:p_callbackFunc 
	@return :
--]]
function LiangTian:registerScriptCallFunc(p_callbackFunc)
	if(p_callbackFunc ~= nil)then
		self.bgButton:registerScriptTapHandler(p_callbackFunc)
	end
end


--[[
	@des 	:粮田的刷新放法
	@param 	:p_callbackFunc 
	@return :
--]]
function LiangTian:refreshCallFunc()
	-- 刷新粮田上边的元素
	if( self.infoSprite ~= nil )then
		self.infoSprite:removeFromParentAndCleanup(true)
		self.infoSprite = nil
	end
	-- 是否开启粮田
	local isOpen = BarnData.getLiangTianIsOpenById(self.id)
	if(isOpen)then
		self.infoSprite = alreadyOpneLinagtan(self.id)
		self.infoSprite:setAnchorPoint(ccp(0.5,0))
		self.infoSprite:setPosition(ccp(self:getContentSize().width*0.5,-2))
	else
		self.infoSprite = notOpneLinagtan(self.id)
		self.infoSprite:setAnchorPoint(ccp(0.5,0.5))
		self.infoSprite:setPosition(ccp(self:getContentSize().width*0.5,self:getContentSize().height*0.5))
	end
	self:addChild(self.infoSprite)
end















