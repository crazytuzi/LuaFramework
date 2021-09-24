local MoneyView=classGc(function(self)
	self:create()
end)

function MoneyView.create(self)
	self.m_rootNode=cc.Node:create()
	self.m_rootNode:retain()

	self:__initView()

	return self.m_rootNode
end
function MoneyView.destroy(self)
	self.m_rootNode:release()
	if self.m_nullNode~=nil then
		self.m_nullNode:release()
	end
end

function MoneyView.isShow(self)
	return self.m_rootNode:getParent()~=nil
end
function MoneyView.addInNode(self,_node)
	self:removeNode()
	_node:addChild(self.m_rootNode)

	self:updateView()
end
function MoneyView.removeNode(self)
	self.m_rootNode:removeFromParent(false)
end

function MoneyView.__initView(self)
	local winSize=cc.Director:getInstance():getWinSize()
	local mainSize=cc.size(416,40)
	local midY=625-mainSize.height*0.5

	-- 背景
	local mainFrameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png",cc.rect(10,0,1,33))
    mainFrameSpr:setPreferredSize(mainSize)
    mainFrameSpr:setPosition(winSize.width*0.5,midY)
    self.m_rootNode:addChild(mainFrameSpr)

    local nPosX=40
    -- 钻石
    local xianYuIcon=cc.Sprite:createWithSpriteFrameName("general_xianYu.png")
    xianYuIcon:setAnchorPoint(cc.p(1,0.5))
    xianYuIcon:setPosition(nPosX,mainSize.height*0.5+2)
    mainFrameSpr:addChild(xianYuIcon)

    self.m_xianYuLabel=_G.Util:createLabel("",22)
	self.m_xianYuLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_xianYuLabel:setPosition(nPosX+3,mainSize.height*0.5+2)
	mainFrameSpr:addChild(self.m_xianYuLabel,10)

	-- 元宝
	nPosX=nPosX+mainSize.width*0.33
    local yuanbaoIcon=cc.Sprite:createWithSpriteFrameName("general_gold.png")
    yuanbaoIcon:setAnchorPoint(cc.p(1,0.5))
    yuanbaoIcon:setPosition(nPosX,mainSize.height*0.5+2)
    mainFrameSpr:addChild(yuanbaoIcon)

	self.m_yuanBaoLabel=_G.Util:createLabel("",22)
	self.m_yuanBaoLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_yuanBaoLabel:setPosition(nPosX+3,mainSize.height*0.5+2)
	mainFrameSpr:addChild(self.m_yuanBaoLabel,10)

	-- 铜钱
	nPosX=nPosX+mainSize.width*0.33
    local goldIcon=cc.Sprite:createWithSpriteFrameName("general_tongqian.png")
    goldIcon:setAnchorPoint(cc.p(1,0.5))
    goldIcon:setPosition(nPosX,mainSize.height*0.5+2)
    mainFrameSpr:addChild(goldIcon)

	self.m_goldLabel=_G.Util:createLabel("",22)
	self.m_goldLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_goldLabel:setPosition(nPosX+3,mainSize.height*0.5+2)
	mainFrameSpr:addChild(self.m_goldLabel,10)
end

function MoneyView.updateGold(self,_szStr)
	self.m_goldLabel:setString(_szStr)
end
function MoneyView.updateYuanBao(self,_szStr)
	self.m_yuanBaoLabel:setString(_szStr)
end
function MoneyView.updateXianYu(self,_szStr)
	self.m_xianYuLabel:setString(_szStr)
end

function MoneyView.updateMoney(self,_szGold,_szYuanBao,_szXianYu)
	if not self:isShow() then return end

	self:updateGold(_szGold)
    self:updateYuanBao(_szYuanBao)
    self:updateXianYu(_szXianYu)
end

function MoneyView.updateView(self)
	if not self:isShow() then return end

	local gold,yuanBao,xianYu=self:getCurMoneyStr()
    self:updateMoney(gold,yuanBao,xianYu)
end

function MoneyView.getCurMoneyStr(self)
	local myProperty=_G.GPropertyProxy:getMainPlay()
    local gold=myProperty:getGold()
    local xianYu=myProperty:getRmb()
    local yuanBao=myProperty:getBindRmb()
    if gold>100000000 then
        gold=math.modf(gold*0.00000001).._G.Lang.number_Chinese["亿"]
    elseif gold>100000 then
        gold=math.modf(gold*0.0001).._G.Lang.number_Chinese["万"]
    end
    if yuanBao>100000000 then
        yuanBao=math.modf(yuanBao*0.00000001).._G.Lang.number_Chinese["亿"]
    elseif yuanBao>100000 then
        yuanBao=math.modf(yuanBao*0.0001).._G.Lang.number_Chinese["万"]
    end
    if xianYu>100000000 then
        xianYu=math.modf(xianYu*0.00000001).._G.Lang.number_Chinese["亿"]
    elseif xianYu>100000 then
        xianYu=math.modf(xianYu*0.0001).._G.Lang.number_Chinese["万"]
    end
    return gold,yuanBao,xianYu
end
return MoneyView