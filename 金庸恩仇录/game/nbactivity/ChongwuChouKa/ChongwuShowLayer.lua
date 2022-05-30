local ChongwuShowLayer = class("ChongwuShowLayer", function()
	return require("utility.ShadeLayer").new()
end)

function ChongwuShowLayer:createStar()
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

function ChongwuShowLayer:luckInfo()
end

function ChongwuShowLayer:petAppear()
	local icon = self._rootnode.icon_tag
	icon:setScale(0.5)
	local frame = ResMgr.getLargeFrame(ResMgr.PET, self.id)
	icon:setDisplayFrame(frame)
	icon:runAction(transition.sequence({
	CCScaleTo:create(0.2, 1)
	}))
	local bgEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "petcard_anim_2",
	isRetain = true
	})
	local effectNode = self._rootnode.effect_tag
	local cntSize = effectNode:getContentSize()
	bgEffect:setPosition(cntSize.width / 2, cntSize.height / 2)
	effectNode:addChild(bgEffect)
	self:createStar()
end

function ChongwuShowLayer:onExit()
	ResMgr.ReleaseUIArmature("petcard_anim_1")
	ResMgr.ReleaseUIArmature("petcard_anim_2")
end

function ChongwuShowLayer:ctor(param)
	self:setNodeEventEnabled(true)
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_zhaomu))
	self.removeListener = param.removeListener
	self.buyListener = param.buyListener
	self:setNodeEventEnabled(true)
	local _type = param.showType
	local _leftTime = param.leftTime or 0
	local _cost = param.cost or 100
	self.scoreTable = param.scoreTable
	self.id = param.id
	local _petInfo = ResMgr.getPetData(self.id)
	self.petInfo = _petInfo
	self._star = _petInfo.star
	local bg = display.newSprite("ui/jpg_bg/zhaojiang_bg.jpg")
	bg:setScaleX(display.width / bg:getContentSize().width)
	bg:setScaleY(display.height / bg:getContentSize().height)
	bg:setPosition(display.cx, display.cy)
	self:addChild(bg)
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("huodong/Petcard_normal.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	if _type == 1 then
		self._rootnode.continue_tag:setVisible(true)
		self._rootnode.DetermineBtn:setVisible(false)
		self._rootnode.exitBtn:setVisible(true)
		if _leftTime > 0 then
			local tips = common:getLanguageString("@mianfei") .. _leftTime .. common:getLanguageString("@Next")
			self._rootnode.free_times:setVisible(true)
			self._rootnode.free_times:setString(tips)
			self._rootnode.coin_tag:setVisible(false)
		else
			self._rootnode.free_times:setVisible(false)
			self._rootnode.coinNumLbl01:setString(_cost)
			self._rootnode.coin_tag:setVisible(true)
		end
	else
		self._rootnode.continue_tag:setVisible(false)
		self._rootnode.DetermineBtn:setVisible(true)
		self._rootnode.exitBtn:setVisible(false)
	end
	self._rootnode.nameLbl:setString(_petInfo.name)
	self._rootnode.nameLbl:setColor(NAME_COLOR[self._star])
	
	local function exitFunc()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if self.removeListener ~= nil then
			self.removeListener()
		end
		self:removeSelf()
	end
	
	--退出
	self._rootnode.exitBtn:addHandleOfControlEvent(function(sender, eventName)
		exitFunc()
	end,
	CCControlEventTouchUpInside)
	
	--确定
	self._rootnode.DetermineBtn:addHandleOfControlEvent(function(sender, eventName)
		exitFunc()
	end,
	CCControlEventTouchUpInside)
	
	--继续抽卡
	self._rootnode.zaichouBtn:addHandleOfControlEvent(function(sender, eventName)
		if self.buyListener then
			self.buyListener()
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	local bgEffect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "petcard_anim_1",
	frameFunc = c_func(handler(self, ChongwuShowLayer.petAppear)),
	isRetain = false,
	finishFunc = function(...)
	end
	})
	local effectNode = self._rootnode.effect_tag
	local cntSize = effectNode:getContentSize()
	bgEffect:setPosition(cntSize.width / 2, cntSize.height / 2)
	effectNode:addChild(bgEffect)
	ResMgr.setControlBtnEvent(self._rootnode.chakanBtn, function()
		local layer = require("game.Pet.PetInfoLayer").new({
		petId = self.id,
		removeListener = function()
		end
		}, 3)
		self:addChild(layer, 100)
	end)
end

function ChongwuShowLayer:createLimitHeroDetail()
	local colorTable = {
	cc.c3b(255, 210, 0),
	cc.c3b(36, 255, 0),
	cc.c3b(255, 210, 0)
	}
	for i = 1, #self.scoreTable do
		local scoreTTF = ui.newTTFLabelWithShadow({
		text = self.scoreTable[i],
		size = 20,
		color = colorTable[i],
		shadowColor = display.COLOR_BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		self:arrPos(scoreTTF, self._rootnode["score" .. i])
		self._rootnode.limit_hero_node:addChild(scoreTTF)
	end
end

function ChongwuShowLayer:arrPos(ttf, node)
	ttf:setPosition(node:getPositionX() + node:getContentSize().width / 2, node:getPositionY() - 3)
end

return ChongwuShowLayer