local TAG_LEFT=1
local TAG_RIGHT=2
local UILingYao = classGc(view,function(self,_lyData,_myLyData,_heLyData)
	self.m_winSize=cc.Director:getInstance():getVisibleSize()
	self.m_lyData=_lyData
	self.m_myLyData=_myLyData
	self.m_heLyData=_heLyData
end)

function UILingYao.create(self)
	self.m_rootNode=cc.Node:create()

	self:__initView()

	return self.m_rootNode
end

function UILingYao.__initView(self)
	self.m_roundResSprArray={}
	self.m_roundResSprArray[TAG_LEFT]={}
	self.m_roundResSprArray[TAG_RIGHT]={}

	local tempX,tempY=170,525
	local tempWid=59
	for i=1,3 do
		local tempSpr=cc.Sprite:createWithSpriteFrameName("battle_lingyao_res_0.png")
		tempSpr:setPosition(tempX+(i-1)*tempWid,tempY)
		self.m_rootNode:addChild(tempSpr)

		self.m_roundResSprArray[TAG_LEFT][i]=tempSpr
	end

	for i=1,3 do
		local tempSpr=cc.Sprite:createWithSpriteFrameName("battle_lingyao_res_0.png")
		tempSpr:setPosition(self.m_winSize.width - tempX - (i-1)*tempWid,tempY)
		self.m_rootNode:addChild(tempSpr)

		self.m_roundResSprArray[TAG_RIGHT][i]=tempSpr
	end
end

function UILingYao.resetRoundView(self,_round)
	if self.m_headNode then
		self.m_headNode:removeFromParent(true)
		self.m_headNode=nil
	end

	self.m_headArray={}

	local tempNode=cc.Node:create()
	self.m_rootNode:addChild(tempNode)

	local curRound=_round
	local tempX,tempY=113,584
	local tempWid=165

	-- 左边
	local tempUid=_G.GPropertyProxy:getMainPlay():getUid()
	for i=1,2 do
		local nNode=cc.Node:create()
		nNode:setPosition(tempX+(i-1)*tempWid,tempY)
		tempNode:addChild(nNode)

		local oneData=self.m_myLyData[curRound][i]
		if oneData then
			local partnerCnf=_G.Cfg.partner_init[oneData.id]

			local headBackSpr=cc.Sprite:createWithSpriteFrameName("battle_lingyao_head.png")
			nNode:addChild(headBackSpr)

			local headSpr=cc.Sprite:createWithSpriteFrameName(string.format("h%d.png",partnerCnf.head_icon))
			headSpr:setPosition(37,37)
			headSpr:setScaleX(-1)
			headBackSpr:addChild(headSpr)

			local nameLabel=_G.Util:createLabel(partnerCnf.name,16)
			local nameSize=nameLabel:getContentSize()
			nameLabel:setPosition(88+nameSize.width*0.5,39)
			headBackSpr:addChild(nameLabel)

			local zoomBgSpr=cc.Sprite:createWithSpriteFrameName("partner_frombg.png")
			zoomBgSpr:setPosition(10,63)
			zoomBgSpr:setScale(0.85)
			headBackSpr:addChild(zoomBgSpr,10)

			local zoomBgSize=zoomBgSpr:getContentSize()
			local zoomSpr=cc.Sprite:createWithSpriteFrameName(string.format("partner_frombg%d.png",partnerCnf.country))
			zoomSpr:setPosition(zoomBgSize.width*0.5,zoomBgSize.height*0.5)
			zoomBgSpr:addChild(zoomSpr)

			local lvBgSpr=cc.Sprite:createWithSpriteFrameName("battle_lingyao_head_lv.png")
			lvBgSpr:setPosition(72,39)
			lvBgSpr:setScale(0.85)
			headBackSpr:addChild(lvBgSpr,10)

			local lvBgSize=lvBgSpr:getContentSize()
			local lvLabel=_G.Util:createLabel(tostring(oneData.lv),16)
			lvLabel:setPosition(lvBgSize.width*0.5,lvBgSize.height*0.5)
			lvBgSpr:addChild(lvLabel)

			local hpTimer=cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("battle_lingyao_hp_1.png"))
	        hpTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	        hpTimer:setBarChangeRate(cc.p(1,0))
	        hpTimer:setMidpoint(cc.p(0,0.5))
	        hpTimer:setPosition(110,19)
	        hpTimer:setPercentage(100)
	        headBackSpr:addChild(hpTimer)

	        local pIdx=tempUid..oneData.id
	        self.m_headArray[pIdx]={}
	        self.m_headArray[pIdx].maxHp=oneData.attr.hp
	        self.m_headArray[pIdx].timer=hpTimer
	        self.m_headArray[pIdx].hBg=headBackSpr
	        self.m_headArray[pIdx].node=nNode
	    -- else
	    -- 	local tempSpr=cc.Sprite:createWithSpriteFrameName("partner_noup.png")
	    -- 	tempSpr:setPosition(0,0)
	    -- 	nNode:addChild(tempSpr)
		end
	end

	-- 右边
	local tempUid=self.m_lyData.uid
	for i=1,2 do
		local nNode=cc.Node:create()
		nNode:setPosition(self.m_winSize.width - tempX - (i-1)*tempWid,tempY)
		nNode:setScaleX(-1)
		tempNode:addChild(nNode)

		local oneData=self.m_heLyData[curRound][i]
		if oneData then
			local partnerCnf=_G.Cfg.partner_init[oneData.id]

			local headBackSpr=cc.Sprite:createWithSpriteFrameName("battle_lingyao_head.png")
			nNode:addChild(headBackSpr)

			local headSpr=cc.Sprite:createWithSpriteFrameName(string.format("h%d.png",partnerCnf.head_icon))
			headSpr:setPosition(37,37)
			headSpr:setScaleX(-1)
			headBackSpr:addChild(headSpr)

			local nameLabel=_G.Util:createLabel(partnerCnf.name,16)
			local nameSize=nameLabel:getContentSize()
			nameLabel:setPosition(88+nameSize.width*0.5,39)
			nameLabel:setScaleX(-1)
			headBackSpr:addChild(nameLabel)

			local zoomBgSpr=cc.Sprite:createWithSpriteFrameName("partner_frombg.png")
			zoomBgSpr:setPosition(10,63)
			zoomBgSpr:setScale(0.85)
			headBackSpr:addChild(zoomBgSpr,10)

			local zoomBgSize=zoomBgSpr:getContentSize()
			local zoomSpr=cc.Sprite:createWithSpriteFrameName(string.format("partner_frombg%d.png",partnerCnf.country))
			zoomSpr:setPosition(zoomBgSize.width*0.5,zoomBgSize.height*0.5)
			zoomSpr:setScaleX(-1)
			zoomBgSpr:addChild(zoomSpr)

			local lvBgSpr=cc.Sprite:createWithSpriteFrameName("battle_lingyao_head_lv.png")
			lvBgSpr:setPosition(72,39)
			lvBgSpr:setScale(0.85)
			headBackSpr:addChild(lvBgSpr,10)

			local lvBgSize=lvBgSpr:getContentSize()
			local lvLabel=_G.Util:createLabel(tostring(oneData.lv),16)
			lvLabel:setPosition(lvBgSize.width*0.5-2,lvBgSize.height*0.5+2)
			lvLabel:setScaleX(-1)
			lvBgSpr:addChild(lvLabel)

			local hpTimer=cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("battle_lingyao_hp_1.png"))
	        hpTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	        hpTimer:setBarChangeRate(cc.p(1,0))
	        hpTimer:setMidpoint(cc.p(0,0.5))
	        hpTimer:setPosition(110,19)
	        hpTimer:setPercentage(100)
	        headBackSpr:addChild(hpTimer)

	        local pIdx=tempUid..oneData.id
	        self.m_headArray[pIdx]={}
	        self.m_headArray[pIdx].maxHp=oneData.attr.hp
	        self.m_headArray[pIdx].timer=hpTimer
	        self.m_headArray[pIdx].hBg=headBackSpr
	        self.m_headArray[pIdx].node=nNode
	    -- else
	    -- 	local tempSpr=cc.Sprite:createWithSpriteFrameName("partner_noup.png")
	    -- 	tempSpr:setPosition(0,0)
	    -- 	nNode:addChild(tempSpr)
		end
	end

	self.m_headNode=tempNode
end

function UILingYao.setHp(self,_pIdx,_hp)
	local tempT=self.m_headArray[_pIdx]
	if not tempT then
		print("UILingYao.setHp====>>>>>,",_pIdx)
		return
	end

	local maxHp=tempT.maxHp
	local curPercent=_hp/maxHp*100
	tempT.timer:setPercentage(curPercent)

	if _hp<=0 then
		local tempSpr=cc.Sprite:createWithSpriteFrameName("battle_lingyao_head_dead.png")
		-- tempSpr:setOpacity(220)
		tempSpr:setPosition(37,37)
		tempT.hBg:addChild(tempSpr)
		self.m_headArray[_pIdx]=nil
	end
end

function UILingYao.updateResult(self,_round,_res)
	local szImg1,szImg2
	if _res==1 then
		-- 我输了
		szImg1="battle_lingyao_res_2.png"
		szImg2="battle_lingyao_res_1.png"
	elseif _res==2 then
		-- 平手
		szImg1="battle_lingyao_res_3.png"
		szImg2="battle_lingyao_res_3.png"
	elseif _res==4 then
		-- 我赢了
		szImg1="battle_lingyao_res_1.png"
		szImg2="battle_lingyao_res_2.png"
	else
		print("lua error!!!!  UILingYao.updateResult ERROR!!!!! _res=",_res)
		return
	end

	if szImg1 and szImg2 then
		self.m_roundResSprArray[TAG_LEFT][_round]:setSpriteFrame(szImg1)
		self.m_roundResSprArray[TAG_RIGHT][_round]:setSpriteFrame(szImg2)
	end
end

return UILingYao