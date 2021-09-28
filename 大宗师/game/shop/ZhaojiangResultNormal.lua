--[[
 --
 -- add by vicky
 -- 2014.08.25
 --
--]]
--

local ZhaojiangResultNormal = class("ZhaojiangResultNormal", function()    
    return require("utility.ShadeLayer").new()
end)

 -- 星星动画
function ZhaojiangResultNormal:createStar()
 	display.addSpriteFramesWithFile("ui/ui_zhaojiangResult.plist", "ui/ui_zhaojiangResult.png")

 	for i = 1, 5 do
 		if self._star == i then 
 			self._rootnode["star_" .. i]:setVisible(true)
 		else
 			self._rootnode["star_" .. i]:setVisible(false)
 		end
 	end

 	local key = "star_" .. self._star .. "_"
 	for i = 1, self._star do
 		local star = self._rootnode[key .. i]
        star:setScale(3.5)
 		star:setDisplayFrame(display.newSprite("#star.png"):getDisplayFrame())
 		star:setVisible(false)
 	end

    for i = 1, self._star do 
        local star = self._rootnode[key .. i]

        star:runAction(transition.sequence({
            CCDelayTime:create((i - 1) * 0.2),
            CCCallFuncN:create(function(node)
                node:setVisible(true)
            end),
            CCScaleTo:create(0.2, 1.3)
        }))
    end
end

function ZhaojiangResultNormal:luckInfo()
    --


end


 -- 卡牌武将出现
 function ZhaojiangResultNormal:heroAppear(heroID)
 	--  武将图标
 	local icon = self._rootnode["icon_tag"]
 	icon:setScale(0.5)
    local frame = ResMgr.getLargeFrame(ResMgr.HERO, heroID)
    icon:setDisplayFrame(frame)
    icon:runAction(transition.sequence{
    	CCScaleTo:create(0.2, 1.0)
    	})

    -- 循环动画
    local bgEffect = ResMgr.createArma({
	    	resType = ResMgr.UI_EFFECT, 
	    	armaName = "xiakejinjie_xunhuan", 
	    	isRetain = true
    	})

	local effectNode = self._rootnode["effect_tag"]
	local cntSize = effectNode:getContentSize()
    bgEffect:setPosition(cntSize.width/2,cntSize.height/2)
    effectNode:addChild(bgEffect)

    self:createStar()
 end


 function ZhaojiangResultNormal:onExit()

    ResMgr.ReleaseUIArmature("xiakejinjie_xunhuan")
    ResMgr.ReleaseUIArmature("xiakejinjie_qishou")

    TutoMgr.removeBtn("zhaojiang_result_exit")
    if self.removeListener ~= nil then
        self.removeListener()
    end
    
    -- TutoMgr.active()
 end


 function ZhaojiangResultNormal:ctor(param)

    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_zhaomu))

    self.removeListener = param.removeListener

    self:setNodeEventEnabled(true)

 	local _type     = param.type
 	local _heroList = param.herolist
 	local _leftTime = param.leftTime or 0
 	local _zhaomulingNum = param.zhaomulingNum
    local _buyListener   = param.buyListener

    local _cost = param.cost or 280

    self.scoreTable = param.scoreTable

    local _heroInfo = ResMgr.getCardData(_heroList[1].id)
    self._star = _heroInfo.star[1]

--    self._buyHeroCallback = param.buyHeroCallback

    local bg = display.newSprite("ui/jpg_bg/zhaojiang_bg.jpg")
    bg:setScaleX(display.width / bg:getContentSize().width)
    bg:setScaleY(display.height / bg:getContentSize().height)
    bg:setPosition(display.cx, display.cy)
    self:addChild(bg)

 	self._rootnode = {}
 	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("shop/zhaojiang_normal.ccbi", proxy, self._rootnode)
	node:setPosition(display.width/2, display.height/2)
	self:addChild(node)

    self._rootnode["nameLbl"]:setString(_heroInfo.name)
    self._rootnode["nameLbl"]:setColor(NAME_COLOR[self._star])

    if self.scoreTable ~= nil then
        self._rootnode["limit_hero_node"]:setVisible(true)
        self:createLimitHeroDetail()
    else
        self._rootnode["limit_hero_node"]:setVisible(false)
    end


    if self._star < 4 then
    	self._rootnode["shareBtn"]:setVisible(false)
    	local exitBtn = self._rootnode["exitBtn"]
    	exitBtn:setPosition(display.width/2, exitBtn:getPositionY())
    end


    if _type == 4 then
        ---限时神将
        self._rootnode["zhaomuling_tag"]:setVisible(false)
        self._rootnode["coinNumLbl"]:setString(_cost)
    elseif _type == 3 then 
    	self._rootnode["zhaomuling_tag"]:setVisible(false)
    	self._rootnode["coinNumLbl"]:setString("280")

    else 
    	if _type == 1 then
    		self._rootnode["zhaomuling_tag"]:setVisible(true)
	    	self._rootnode["coin_tag"]:setVisible(false)
	    	self._rootnode["zhaomulingNumLabel"]:setString(_zhaomulingNum)
	    else
            self._rootnode["coin_tag"]:setVisible(true)
            self._rootnode["zhaomuling_tag"]:setVisible(false)
            self._rootnode["coinNumLbl"]:setString("80")
    	end
    	self._rootnode["leftTime_desc"]:setVisible(false)
    end

    if _leftTime == 0 then
        self._rootnode["getCardTipSprite"]:setString("              下次招募必得")
        self._rootnode["leftTimeLbl"]:setString("")
    else
        self._rootnode["getCardTipSprite"]:setString(tostring(string.format("再招 %d 次后,下次招募必得", _leftTime)))
    end

    -- 退出
    self._rootnode["exitBtn"]:addHandleOfControlEvent(
		function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
            self:removeFromParentAndCleanup(true)
            PostNotice(NoticeKey.CommonUpdate_Label_Gold)
            PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	    end, 
	    CCControlEventTouchUpInside)

    TutoMgr.addBtn("zhaojiang_result_exit",self._rootnode["exitBtn"])
    TutoMgr.active()
    --  继续招将
    self._rootnode["zhaojiangBtn"]:addHandleOfControlEvent(
    	function(eventName, sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
    		if (_type == 1 and _zhaomulingNum <= 0) then
    			show_tip_label("道具不足")
            elseif (_type == 2 and game.player:getGold() < 80) then
                show_tip_label("元宝不足")
    		elseif (_type == 3 and game.player:getGold() < 280) then
                show_tip_label("元宝不足")
            elseif (_type == 4 and game.player:getGold() < _cost) then
                show_tip_label("元宝不足")
            else
                -- self:removeSelf()
                _buyListener(_type, _, 1, self)
--		    		self:getOneHero()
    		end
    	end, 
    	CCControlEventTouchUpInside)

    -- self._rootnode["zhaojiangBtn"]:setEnabled(false)
    -- 开始动画
    local bgEffect = ResMgr.createArma({
	    	resType = ResMgr.UI_EFFECT, 
	    	armaName = "xiakejinjie_qishou", 
	    	frameFunc = c_func(handler(self, ZhaojiangResultNormal.heroAppear), _heroList[1].id),
	    	isRetain = false,
            finishFunc = function ( ... )
                -- self._rootnode["zhaojiangBtn"]:setEnabled(true)
            end
    	})

	local effectNode = self._rootnode["effect_tag"]
	local cntSize = effectNode:getContentSize()
    bgEffect:setPosition(cntSize.width/2,cntSize.height/2)
    effectNode:addChild(bgEffect)

--    dump(self._heroList[1])

    -- self._rootnode["chakanBtn"]:addHandleOfControlEvent(function()
    --     GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))

    -- end, CCControlEventTouchUpInside)
    
    ResMgr.setControlBtnEvent(self._rootnode["chakanBtn"],function()
        local layer = require("game.Hero.HeroInfoLayer").new({
            info = {
                resId = _heroList[1].id,
                objId = _heroList[1].objId
            }
        }, 3)
        game.runningScene:addChild(layer, 100)
        end)
 end

 function ZhaojiangResultNormal:createLimitHeroDetail()

    local colorTable = {ccc3(255, 210, 0),ccc3(36, 255, 0),ccc3(255, 210, 0)}

    for i = 1,#self.scoreTable do
        local scoreTTF = ui.newTTFLabelWithShadow({
            text = self.scoreTable[i],
            size = 20,
            color = colorTable[i],
            font = FONTS_NAME.font_fzcy,
            align = ui.TEXT_ALIGN_LEFT
        })
        self:arrPos(scoreTTF, self._rootnode["score"..i])
        self._rootnode["limit_hero_node"]:addChild(scoreTTF)
    end
 end

function ZhaojiangResultNormal:arrPos(ttf,node)
    ttf:setPosition(node:getPositionX()+node:getContentSize().width/2,node:getPositionY()-3)
end


 return ZhaojiangResultNormal
