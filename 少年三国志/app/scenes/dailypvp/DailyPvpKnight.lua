local DailyPvpKnight = class("DailyPvpKnight")
require("app.cfg.daily_crosspvp_rank_title")
require("app.cfg.daily_crosspvp_face")

function DailyPvpKnight:ctor(node,nameImg,heroImg,heroShadow,heroNode,titleLabel,nameLabel,zhanliLabel,vipLevelImg)
	self.node = node
	self.nameImg = nameImg
	self.heroImg = heroImg
	self.heroShadow = heroShadow
	self.heroNode = heroNode
	self.titleLabel = titleLabel
	self.nameLabel = nameLabel
	self.zhanliLabel = zhanliLabel
	self.vipLevelImg = vipLevelImg
end

function DailyPvpKnight.createKnight(resId,hasShadow,titleId,name,nameClr,zhanli,vip,inBattle,flip)
	local node = Widget:create()
	local picPath = inBattle and G_Path.getBattleConfigImage("knight",resId..".png") or G_Path.getKnightPic(resId)
	local heroNode = Widget:create()
	node:addChild(heroNode,5)
	local sp = CCSpriteLighten:create(picPath)
	-- local sp = ImageView:create()
	-- sp:loadTexture(picPath)
	local config = decodeJsonFile(inBattle and G_Path.getBattleConfig("knight",resId.."_fight") or G_Path.getKnightPicConfig(resId))

	if hasShadow then
	    local shadow = CCSprite:create(  G_Path.getKnightShadow()  )
	    -- shadow:setPosition(ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y)))
	    heroNode:addNode(shadow, -3)    
	end

	if flip then
		sp:setScaleX(-1)
	end
	-- local posy = inBattle and tonumber(config.y) or tonumber(config.y) - 50
	sp:setPosition(ccp(flip and tonumber(config.x) or -tonumber(config.x), tonumber(config.y)))
	heroNode:addNode(sp)
	heroNode:setScale(inBattle and 0.8 or 0.4)

	local nameDi = ImageView:create()
	nameDi:loadTexture("ui/top/mrt_di_name.png")
	nameDi:setScale9Enabled(true)
	nameDi:setCapInsets(CCRectMake(94, 28, 1, 1))
	nameDi:setSize(CCSizeMake(188,94))
	node:addChild(nameDi,10)
	nameDi:setPositionXY(0,175)
	nameDi:setScale(0.8)

	local vipImg = ImageView:create()
	vipImg:loadTexture("ui/vip/vip_lv_vip.png")
	nameDi:addChild(vipImg)
	vipImg:setAnchorPoint(ccp(1,0.5))
	vipImg:setScale(0.7)
	vipImg:setPositionXY(-45,0)
	local vipLevelImg = ImageView:create()
	vipLevelImg:loadTexture("ui/vip/vip_lv_"..vip..".png")
	nameDi:addChild(vipLevelImg)
	vipLevelImg:setAnchorPoint(ccp(0,0.5))
	vipLevelImg:setPositionXY(-45,0)
	vipLevelImg:setScale(0.7)

	titleId = (titleId and titleId > 0) and titleId or 7
	local titleInfo = daily_crosspvp_rank_title.get(titleId)
	local titleLabel = GlobalFunc.createGameLabel(titleInfo.text, 22, Colors.qualityColors[titleInfo.quality], Colors.strokeBrown)
	nameDi:addChild(titleLabel)
	titleLabel:setAnchorPoint(ccp(0,0.5))
	titleLabel:setPositionXY(-10,0)
	local nameLabel = GlobalFunc.createGameLabel(name, 24, nameClr, Colors.strokeBrown)
	nameDi:addChild(nameLabel)
	nameLabel:setPositionXY(0,29)
	local zhanliLabel = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_ZHANLI")..GlobalFunc.ConvertNumToCharacter4(zhanli), 22, Colors.darkColors.DESCRIPTION, Colors.strokeBrown)
	nameDi:addChild(zhanliLabel)
	zhanliLabel:setPositionXY(0,-29)

	node:setCascadeOpacityEnabled(true)
	node:setCascadeColorEnabled(true)
	heroNode:setCascadeOpacityEnabled(true)
	heroNode:setCascadeColorEnabled(true)
	return DailyPvpKnight.new(node,nameDi,sp,shadow,heroNode,titleLabel,nameLabel,zhanliLabel,vipLevelImg)
end

function DailyPvpKnight:initReady(isLeader,ready)
	local leadImg = ImageView:create()
	local url = isLeader and "ui/text/txt/jzhlg_duizhang.png" or "ui/text/txt/jzhlg_zhunbei.png"
	ready = ready or isLeader
	leadImg:loadTexture(url)
	self.node:addChild(leadImg,10)
	leadImg:setPositionXY(0,45)
	leadImg:setVisible(ready)
	self.leadImg = leadImg

	self.heroNode:setScale(0.35)
	self.nameImg:setPosition(ccp(0,150))
end

function DailyPvpKnight:updateKnight(resId,titleId,name,nameClr,zhanli,vip,inBattle,flip)
	local picPath = inBattle and G_Path.getBattleConfigImage("knight",resId..".png") or G_Path.getKnightPic(resId)
	local parent = self.heroImg:getParent()
	local config = decodeJsonFile(inBattle and G_Path.getBattleConfig("knight",resId.."_fight") or G_Path.getKnightPicConfig(resId))
	self.heroImg:removeFromParentAndCleanup(true)
	self.heroImg = CCSpriteLighten:create(picPath)
	if flip then
		self.heroImg:setScaleX(-1)
	end
	parent:addNode(self.heroImg)
	if self.heroShadow then
		self.heroShadow:setPosition(ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y)))
	end
	local posx = tonumber(config.x)
	self.heroImg:setPosition(ccp(flip and -posx or posx, tonumber(config.y)))

	titleId = (titleId and titleId > 0) and titleId or 7
	local titleInfo = daily_crosspvp_rank_title.get(titleId)
	self.titleLabel:setText(titleInfo.text)
	self.titleLabel:setColor(Colors.qualityColors[titleInfo.quality])
	self.nameLabel:setText(name)
	self.nameLabel:setColor(nameClr)
	self.zhanliLabel:setText(G_lang:get("LANG_DAILY_ZHANLI")..GlobalFunc.ConvertNumToCharacter4(zhanli))
	self.vipLevelImg:loadTexture("ui/vip/vip_lv_"..vip..".png")
end

function DailyPvpKnight:updateReadyKnight(resId,titleId,name,nameClr,zhanli,vip,isLeader,ready)
	self:updateKnight(resId,titleId,name,nameClr,zhanli,vip,false,false)
	self.leadImg:setVisible(ready or isLeader)
	local url = isLeader and "ui/text/txt/jzhlg_duizhang.png" or "ui/text/txt/jzhlg_zhunbei.png"
	self.leadImg:loadTexture(url)
end

function DailyPvpKnight.getCenterPos(pos)
	return ccp(pos.x,pos.y+75)
end

function DailyPvpKnight.getRect(pos)
	local width = 120
	local height = 150
	return CCRectMake(pos.x-width/2,pos.y-20,width,height)
end

function DailyPvpKnight:initInFight(totalHp)
	-- local dizuo = ImageView:create()
	-- dizuo:loadTexture("dizuo_blue.png",UI_TEX_TYPE_PLIST)
	-- node:addChild(dizuo,3)
	-- dizuo:setPositionXY(0,0)

	-- local baseJson = decodeJsonFile(G_Path.getBattleConfig('base', "base_1"))
	-- -- local cardBase = CCSpriteLighten:create(G_Path.getBattleConfigImage('base', "base_1.png"))
	-- local cardBase = display.newSprite(G_Path.getBattleConfigImage('base', "base_1"))
	-- cardBase:setPosition(ccp(baseJson.x, baseJson.y))
	-- node:addChild(cardBase,3)
	-- self.cardBase = cardBase

	local DailyPvpHpSprite = require "app.scenes.dailypvp.DailyPvpHpSprite"
	local hpSprite = DailyPvpHpSprite.new(totalHp, totalHp)
	self.node:addNode(hpSprite,10)
	hpSprite:setPosition(ccp(0, 220))
	self.hpSprite = hpSprite

	self.hp = totalHp

	self:initHpAdd(0)
end

function DailyPvpKnight:resetHp(totalHp)
	self.hpSprite:resetHp(totalHp)
end

function DailyPvpKnight:hideDetail()
	self.nameImg:setVisible(false)
	if self.hpSprite then
		self.hpSprite:setVisible(false)
	end
	if self.face then
		self.face:setVisible(false)
	end
end

function DailyPvpKnight:showDetail()
	self.nameImg:setVisible(true)
	if self.hpSprite then
		self.hpSprite:setVisible(true)
	end
	if self.face then
		self.face:setVisible(true)
	end
end

function DailyPvpKnight:hideAll()
	self.node:setVisible(false)
end

function DailyPvpKnight:showAll()
	self.node:setVisible(true)
end

function DailyPvpKnight:resetScale()
	self.node:setScale(1)
end

function DailyPvpKnight:initHpAdd( damage )
	local displayNode = nil
	local fnt = G_Path.getBattleDamageLabelFont()
	-- if damage > 0 then
	--     fnt = G_Path.getBattleRecoverLabelFont()
	-- end
	
	-- damage = damage > 0 and "+"..damage
	
	if fnt then
	    displayNode = ui.newBMFontLabel({
	        text = tostring(damage),
	        font = fnt,
	        align = ui.TEXT_ALIGN_CENTER
	    })
	end
	displayNode:setPosition(ccp(0,250))
	self.node:addNode(displayNode,20)
	self.displayNode = displayNode
	displayNode:setVisible(false)
	self.displayNodePos = ccp(0,250)
end

function DailyPvpKnight:changeHp(damage)
	
	self.displayNode:setVisible(true)
	self.displayNode:setFntFile(damage>0 and G_Path.getBattleRecoverLabelFont() or G_Path.getBattleDamageLabelFont())
	damage = damage > 0 and "+"..damage or damage
	self.displayNode:setString(damage)
	self.displayNode:setScale(0.2)
	self.displayNode:setPositionXY(self.displayNodePos.x,self.displayNodePos.y-50)
	
	local seqArr = CCArray:create()
	seqArr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.15,1.2),CCMoveBy:create(0.15,ccp(0,50))))
	seqArr:addObject(CCDelayTime:create(0.2))
	seqArr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.15,0.2),CCMoveBy:create(0.15,ccp(0,50))))
	seqArr:addObject(CCCallFunc:create(function()
	    self.displayNode:setVisible(false)
	end))
	self.displayNode:runAction(CCSequence:create(seqArr))

	self.hpSprite:changeProgress(damage)
end

function DailyPvpKnight:changeHpHide(damage)
	self.displayNode:setVisible(false)
end

function DailyPvpKnight:showFace(good,index)
	local faceList = {}
	for i = 1 , daily_crosspvp_face.getLength() do 
		local v = daily_crosspvp_face.indexOf(i)
		if v.win_lose == good then
			table.insert(faceList,#faceList+1,v.face_id)
		end
	end
	if #faceList > 0 then
		local rand = math.floor(math.random()*#faceList)+1
		local faceId = faceList[rand]
		if self.face then
			self.face:removeFromParentAndCleanup(true)
			self.face = nil
		end
		local img = ImageView:create()
		img:loadTexture("ui/chat/face/"..faceId..".png")
		img:setAnchorPoint(ccp(0,0))
		img:setScale(0.1)
		local baseScale = CCScaleTo:create(0.18,0.8)
		local animeScale = CCEaseBounceOut:create(baseScale)
		self.node:addChild(img,10)
		img:setPositionXY(-20-100*(index*2-3),100)
		local seqArr = CCArray:create()
		seqArr:addObject(animeScale)
		-- seqArr:addObject(CCDelayTime:create(1.0))
		seqArr:addObject(CCMoveBy:create(0.15,ccp(0,2)))
		seqArr:addObject(CCMoveBy:create(0.3,ccp(0,-4)))
		seqArr:addObject(CCMoveBy:create(0.15,ccp(0,2)))
		seqArr:addObject(CCCallFunc:create(function()
			self.face:removeFromParentAndCleanup(true)
			self.face = nil
		end))
		img:runAction(CCSequence:create(seqArr))
		self.face = img
	end
end

return DailyPvpKnight