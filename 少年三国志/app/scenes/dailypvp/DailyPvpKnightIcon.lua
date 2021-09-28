local DailyPvpKnightIcon = class("DailyPvpKnightIcon")
require("app.cfg.knight_info")


function DailyPvpKnightIcon:ctor(node,boardBg,iconBoard,heroIcon,numImg,vipImg,defeatImg,fightLabel,nameLabel,nameClr)
	self.node = node
	self.boardBg = boardBg
	self.iconBoard = iconBoard
	self.heroIcon = heroIcon
	self.numImg = numImg
	self.vipImg = vipImg
	self.defeatImg = defeatImg
	self.fightLabel = fightLabel
	self.nameLabel = nameLabel
	self.nameClr = nameClr
end

function DailyPvpKnightIcon.createKnightIcon(index,baseId,dressId,vip,name,nameClr,clid,cltm,clop)
	local node = Widget:create()
	local resId = G_Me.dressData:getDressedResidWithClidAndCltm(baseId,dressId,clid,cltm,clop)
	local knightInfo = knight_info.get(baseId)

	local boardBg = ImageView:create()
	boardBg:loadTexture("ui/zhengrong/kuang_zhu.png")
	node:addChild(boardBg,2)

	local iconBoard = Button:create()
	iconBoard:loadTextureNormal(G_Path.getEquipColorImage(knightInfo.quality,G_Goods.TYPE_KNIGHT))
	node:addChild(iconBoard,4)

	local heroIcon = ImageView:create()
	heroIcon:loadTexture(G_Path.getKnightIcon(resId))
	node:addChild(heroIcon,3)

	local numImg = ImageView:create()
	numImg:loadTexture("ui/text/txt/jzhlg_"..index..".png")
	numImg:setPositionXY(-45,-40)
	numImg:setScale(0.8)
	node:addChild(numImg,6)

	local vipImg = ImageView:create()
	vipImg:loadTexture("ui/chat/VIP.png")
	vipImg:setPositionXY(-45,40)
	node:addChild(vipImg,6)

	local defeatImg = ImageView:create()
	defeatImg:loadTexture("ui/text/txt/jzhlg_yijibai.png")
	defeatImg:setPositionXY(15,-15)
	defeatImg:setScale(0.8)
	node:addChild(defeatImg,8)
	defeatImg:setVisible(false)

	local fightLabel = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_FIGHTING"), 20, Colors.darkColors.DESCRIPTION, Colors.strokeBrown)
	fightLabel:setPositionXY(10,-35)
	node:addChild(fightLabel,6)
	fightLabel:setVisible(false)

	local nameLabel = GlobalFunc.createGameLabel(name, 20, nameClr, Colors.strokeBrown)
	nameLabel:setPositionXY(0,-60)
	node:addChild(nameLabel,7)

	return DailyPvpKnightIcon.new(node,boardBg,iconBoard,heroIcon,numImg,vipImg,defeatImg,fightLabel,nameLabel,nameClr)
end

function DailyPvpKnightIcon:active()
	self.boardBg:loadTexture("ui/zhengrong/selected_bg.png")
	self.fightLabel:setVisible(true)
end

function DailyPvpKnightIcon:defeated()
	local grayColor = ccc3(0xae, 0xae, 0xae) 
	self.boardBg:loadTexture("ui/zhengrong/kuang_zhu.png")
	self.fightLabel:setVisible(false)
	self.defeatImg:setVisible(true)

	self.boardBg:setColor(grayColor)
	self.heroIcon:setColor(grayColor)
	self.iconBoard:setColor(grayColor)
	self.numImg:setColor(grayColor)
	self.vipImg:setColor(grayColor)

	local nameClr = self.nameClr
	local mix = function ( clr1,clr2 )
		return ccc3((clr1.r+clr2.r)/2,(clr1.g+clr2.g)/2,(clr1.b+clr2.b)/2)
	end
	local dstClr = mix(nameClr,grayColor)
	self.nameLabel:setColor(dstClr)

	self.defeatImg:setScale(5.0)
	local scaleAction = CCScaleTo:create(0.3,1)
	self.defeatImg:runAction(CCEaseBackOut:create(scaleAction))
end

function DailyPvpKnightIcon:winFull()
	self.boardBg:loadTexture("ui/zhengrong/kuang_zhu.png")
	self.fightLabel:setVisible(false)
	self.defeatImg:setVisible(true)
	self.defeatImg:loadTexture("ui/text/txt/jzhlg_mansanchang.png")

	self.defeatImg:setScale(5.0)
	local scaleAction = CCScaleTo:create(0.3,1)
	self.defeatImg:runAction(CCEaseBackOut:create(scaleAction))
end

function DailyPvpKnightIcon:setBtnName(name)
	self.iconBoard:setTouchEnabled(true)
	self.iconBoard:setName(name)
end

return DailyPvpKnightIcon