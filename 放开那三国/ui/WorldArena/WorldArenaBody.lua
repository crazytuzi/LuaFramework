-- FileName: WorldArenaBody.lua 
-- Author: licong 
-- Date: 15/7/7 
-- Purpose: 巅峰对决人物形象 

require "script/ui/guildBossCopy/ProgressBar"

WorldArenaBody = class("WorldArenaBody",function ()
	return CCSprite:create()
end)


function WorldArenaBody:ctor( ... )
	self._bodySprite 					= nil
	self._menuItem 						= nil
end


--[[
	@des:创建人物形象
	@parm:p_data 	数据
--]]
function WorldArenaBody:createWithData( p_data )
	local bodySprite = WorldArenaBody:new()
	bodySprite:initWithData( p_data )
	return bodySprite
end


--[[
	@des:初始化人物形象
	@parm:p_data 	数据
--]]
function WorldArenaBody:initWithData( p_data )
	-- print("p_data==>")
	-- print_t(p_data)

	self:setContentSize(CCSizeMake(150,220))

	self._bodySprite = nil
	local genderId = HeroModel.getSex(p_data.htid)
	if(genderId == 1)then
		-- 男
		if( p_data.index == 4)then
			-- 自己
			self._bodySprite = CCSprite:create("images/worldarena/nan.png")
		else
			self._bodySprite = XMLSprite:create("images/worldarena/effect/zhujue_nan1/zhujue_nan1")
		end
	else
		-- 女
		if( p_data.index == 4)then
			self._bodySprite = CCSprite:create("images/worldarena/nv.png")
		else
			self._bodySprite = XMLSprite:create("images/worldarena/effect/zhujue_nv1/zhujue_nv1")
		end
	end

	-- 人物形象
	self._bodySprite:setAnchorPoint(ccp(0.5,0.5))
	self:addChild(self._bodySprite,10)
	self._bodySprite:setPosition(ccp(self:getContentSize().width*0.5,self:getContentSize().height*0.5))

	-- 法阵
	-- if( p_data.index ~= 4)then
	-- 	-- 敌人法阵
	-- 	local fazhenSp = XMLSprite:create("images/worldarena/effect/fazhenred/fazhenred")
	-- 	fazhenSp:setAnchorPoint(ccp(0.5,0.5))
	-- 	self:addChild(fazhenSp)
	-- 	fazhenSp:setPosition(ccp(self:getContentSize().width*0.5,10))
	-- end

	-- 按钮
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	self:addChild(menu)
	menu:setTouchPriority(-405)

	local normalSp = CCSprite:create()
	normalSp:setContentSize(CCSizeMake(100,160))

	local selectSp = CCSprite:create()
	selectSp:setContentSize(CCSizeMake(100,160))

	self._menuItem = CCMenuItemSprite:create(normalSp, selectSp)
	self._menuItem:setAnchorPoint(ccp(0.5, 0.5))
	menu:addChild(self._menuItem,1,p_data.index)
	self._menuItem:setPosition(ccp(self:getContentSize().width*0.5, self:getContentSize().height*0.5))

	--第多少名
	local fontTab = {}
    fontTab[1] = CCRenderLabel:create(GetLocalizeStringBy("lic_1602"),g_sFontPangWa, 23,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    fontTab[1]:setColor(ccc3(0xff, 0xf6, 0x00))

    fontTab[2] = CCRenderLabel:create(p_data.rank,g_sFontPangWa, 23, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    fontTab[2]:setColor(ccc3(0xff, 0x00, 0x00))

    fontTab[3] = CCRenderLabel:create(GetLocalizeStringBy("lic_1603"),g_sFontPangWa, 23, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    fontTab[3]:setColor(ccc3(0xff, 0xf6, 0x00))

    local rankNode = BaseUI.createHorizontalNode(fontTab)
    rankNode:setAnchorPoint(ccp(0.5,0.5))
    rankNode:setPosition(ccp(self:getContentSize().width*0.5, self:getContentSize().height))
    self:addChild(rankNode,20)

    -- 添加称号
    if( p_data.title ~= nil and tonumber(p_data.title) > 0 )then
        require "script/ui/title/TitleUtil"
        local titleSprite = TitleUtil.createTitleNormalSpriteById(p_data.title)
        titleSprite:setAnchorPoint(ccp(0.5, 0.5))
        titleSprite:setPosition(ccp(rankNode:getContentSize().width*0.5, rankNode:getContentSize().height+15))
        rankNode:addChild(titleSprite)
    end

    -- 血条
    local hpSprite = ProgressBar:create("images/guild_boss_copy/red_bar.png", "images/guild_boss_copy/green_bar.png", nil, tonumber(p_data.hp_percent)/10000, false)
    hpSprite:setAnchorPoint(ccp(0.5,0.5))
    hpSprite:setPosition(ccp(self:getContentSize().width*0.5, rankNode:getPositionY()-20))
    self:addChild(hpSprite,20)
    hpSprite:setProgressLabelVisible( false )

    -- 名字
    local nameLabel = CCRenderLabel:create(p_data.uname,g_sFontName, 22, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    nameLabel:setColor(ccc3(0xff, 0xff, 0xff))
    nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setPosition(ccp(self:getContentSize().width*0.5, 0))
    self:addChild(nameLabel,20)

    -- 服务器名字
    local serNameLabel = CCRenderLabel:create(p_data.server_name,g_sFontName, 22, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    serNameLabel:setColor(ccc3(0xff, 0xff, 0xff))
    serNameLabel:setAnchorPoint(ccp(0.5,1))
    serNameLabel:setPosition(ccp(self:getContentSize().width*0.5, nameLabel:getPositionY()-nameLabel:getContentSize().height-2))
    self:addChild(serNameLabel,20)

    -- 战斗力
    local fontTab2 = {}
    fontTab2[1] = CCSprite:create("images/common/fight_value.png")

    fontTab2[2] = CCRenderLabel:create(tonumber(p_data.fight_force),g_sFontPangWa, 20, 1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    fontTab2[2]:setColor(ccc3(0x00, 0xff, 0x18))

    local fightNode = BaseUI.createHorizontalNode(fontTab2)
    fightNode:setAnchorPoint(ccp(0.5,1))
    fightNode:setPosition(ccp(nameLabel:getPositionX(), serNameLabel:getPositionY()-serNameLabel:getContentSize().height-2))
    self:addChild(fightNode,20)

    -- 自己特殊处理
    if( p_data.index == 4)then
		-- 自己不可点击
		self._menuItem:setEnabled(false)
		-- 名字隐藏
		nameLabel:setVisible(false)
		serNameLabel:setVisible(false)
		-- 战斗力隐藏
		fightNode:setVisible(false)

		rankNode:setPosition(ccp(self:getContentSize().width*0.5, self:getContentSize().height+100))
		hpSprite:setPosition(ccp(self:getContentSize().width*0.5, rankNode:getPositionY()-20))
	end

end


--[[
	@des 	:注册按钮回调
	@param 	:p_callbackFunc 
	@return :
--]]
function WorldArenaBody:registerScriptCallFunc(p_callbackFunc)
	if(p_callbackFunc ~= nil)then
		self._menuItem :registerScriptTapHandler(p_callbackFunc)
	end
end


--[[
	@des 	:刷新放法
	@param 	:p_callbackFunc 
	@return :
--]]
function WorldArenaBody:refreshCallFunc(p_data)

	self:removeAllChildrenWithCleanup(true)
	self:initWithData(p_data)

end

--[[
	@des 	:设置是否可点击
	@param 	:p_isEnabled 
	@return :
--]]
function WorldArenaBody:setMenuItemEnabled( p_isEnabled )
	self._menuItem:setEnabled(p_isEnabled)
end
































