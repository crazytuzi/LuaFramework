local __textUreCache=cc.Director:getInstance():getTextureCache()
local __SFCache=cc.SpriteFrameCache:getInstance()
local __FileUtil=_G.FilesUtil

local EFFECT_TYPE_ARRAY={
	[_G.Const.CONST_GOODS_EQUIP]=true,
	[_G.Const.CONST_GOODS_WEAPON]=true,
	[_G.Const.CONST_GOODS_MAGIC]=true,
	[_G.Const.CONST_GOODS_MOUNT]=true,
	[_G.Const.CONST_GOODS_HOLIDAY]=true,
	[_G.Const.CONST_GOODS_ZHENFA]=true,
}
local M={}

M.TYPE_SPRITE=1
M.TYPE_BUTTON=2
function M.__init(self)
	self.m_textureLoadArray={}
	self.m_nodeLoadArray={}
end
function M.clear(self)
	self:__init()
	__textUreCache:unbindAllImageAsync()
end
function M.addTextureLoad(self,_szPath)
	if self.m_textureLoadArray[_szPath] then return end

	local function nLoadBack(_texture)
		if _texture==nil then return end
		self:textureLoadBack(_szPath,_texture)
	end

	__textUreCache:addImageAsync(_szPath,nLoadBack)
end
function M.textureLoadBack(self,_szPath,_texture)
	local nodeArray=self.m_nodeLoadArray[_szPath]
	if nodeArray==nil then return end

	self.m_nodeLoadArray[_szPath]=nil

	for node,tempT in pairs(nodeArray) do
		if tempT.type==self.TYPE_SPRITE then
			node:setTexture(_texture)
		elseif tempT.type==self.TYPE_BUTTON then
			node:loadTextureNormal(_szPath,0)
		end
		self:handleNodeArgs(node,tempT.type,tempT.data)
		node:unregisterScriptHandler()
	end
end
function M.handleNodeArgs(self,_loadNode,_type,_data)
	if _data==nil then return end

	if _data.pos~=nil then
		_loadNode:setPosition(_data.pos)
	end
	if _data.isGray~=nil then
		_loadNode:setGray()
	end
	if _data.tag~=nil then
		_loadNode:setTag(_data.tag)
	end
	if _type==self.TYPE_BUTTON then
		if _data.listener then
			_loadNode:addTouchEventListener(_data.listener)
		end
		if _data.isGoods then
			_loadNode:setTouchActionType(_G.Const.kCButtonTouchTypeGray)
		end
	elseif _type==self.TYPE_SPRITE then
		if _data.rect~=nil then
			_loadNode:setTextureRect(_data.rect)
		end
	end
	if _data.isGoods then
		self:addGoodsEffect(_loadNode,_data.goodsCnf,_data.goodsCount)
	end
end
function M.addNodeLoad(self,_szPath,_node,_type,_data)
	if self.m_nodeLoadArray[_szPath]==nil then
		self.m_nodeLoadArray[_szPath]={}
	end

	local curNodeArray=self.m_nodeLoadArray[_szPath]
	if curNodeArray[_node]~=nil then return end

	local tempT={
		type=_type,
		data=_data
	}
	curNodeArray[_node]=tempT

	local function nNodeEvent(event)
		if event=="cleanup" then
			curNodeArray[_node]=nil
		end
    end
	_node:registerScriptHandler(nNodeEvent)

	self:addTextureLoad(_szPath)
end
function M.addSpriteLoad(self,_szPath,_node,_data)
	self:addNodeLoad(_szPath,_node,self.TYPE_SPRITE,_data)
end
function M.addButtonLoad(self,_szPath,_node,_data)
	self:addNodeLoad(_szPath,_node,self.TYPE_BUTTON,_data)
end



function M.createNormalSpr(self,_szPath,_data)
	local tempSpr=gc.GraySprite:create()
	self:addNodeLoad(_szPath,tempSpr,self.TYPE_SPRITE,_data)
	return tempSpr
end
function M.createNormalBtn(self,_szPath,_listener,_tag)
	local tempBtn=gc.CButton:create()
	self:addButtonLoad(_szPath,tempBtn,{listener=_listener,tag=_tag})
	return tempBtn
end

function M.getDropIconPath(self,_iconSkin)
	local iconPath=string.format("drop_%s.png",tostring(_iconSkin))
    if not __SFCache:getSpriteFrame(iconPath) then
        iconPath="0.png"
    end
    return iconPath
end
function M.getIconPath(self,_iconSkin,_isSkillIcon)
	if _isSkillIcon then
		local iconPath=string.format("icon/s%s.png",tostring(_iconSkin))
		if __FileUtil:check(iconPath)==false then
			iconPath="icon/s101.png"
		end
		return iconPath
	else
		local iconPath=string.format("%s.png",tostring(_iconSkin))
	    if not __SFCache:getSpriteFrame(iconPath) then
	        iconPath="0.png"
	    end
	    return iconPath
	end
end
function M.createGoodsSpr(self,_goodsNode,_goodsNum)
	local szPath=self:getIconPath(_goodsNode.icon)
	local tempNode=gc.GraySprite:createWithSpriteFrameName(szPath)
	local nData={isGoods=true,goodsCnf=_goodsNode,goodsCount=_goodsNum}
	self:handleNodeArgs(tempNode,self.TYPE_SPRITE,nData)
	-- self:addNodeLoad(szPath,tempNode,self.TYPE_SPRITE,nData)

	return tempNode
end
function M.createGoodsBtn(self,_goodsNode,_listener,_tag,_goodsNum)
	local tempNode=gc.CButton:create()
	local szPath=self:getIconPath(_goodsNode.icon)

	local nData={listener=_listener,tag=_tag,isGoods=true,goodsCnf=_goodsNode,goodsCount=_goodsNum}
	tempNode:loadTextureNormal(szPath)
	self:handleNodeArgs(tempNode,self.TYPE_BUTTON,nData)
	-- self:addNodeLoad(szPath,tempNode,self.TYPE_BUTTON,nData)

	return tempNode
end
function M.createHeadSpr(self,_icon,_color,_starNum)
	local goodsCnf={icon=_icon,name_color=_color,type=_G.Const.CONST_GOODS_MOUNT,star=_starNum}
	return self:createGoodsSpr(goodsCnf)
end
function M.createHeadBtn(self,_icon,_color,_starNum,_listener,_tag)
	local goodsCnf={icon=_icon,name_color=_color,type=_G.Const.CONST_GOODS_MOUNT,star=_starNum}
	return self:createGoodsBtn(goodsCnf,_listener,_tag)
end
function M.createSkillSpr(self,_icon)
	local tempNode=gc.GraySprite:create()
	local szPath=self:getIconPath(_icon,true)
	self:addNodeLoad(szPath,tempNode,self.TYPE_SPRITE)
	return tempNode
end
function M.createSkillBtn(self,_icon,_listener,_tag)
	local tempNode=gc.CButton:create()
	local szPath=self:getIconPath(_icon,true)

	local nData={listener=_listener,tag=_tag}
	self:addNodeLoad(szPath,tempNode,self.TYPE_BUTTON,nData)

	return tempNode
end

local function lGoodsTempFun(_node)
	_node:setPosition(-37,37)
end
function M.addGoodsEffect(self,_node,_goodsNode,_goodsNum)
	if _goodsNode==nil or _goodsNode.name_color==nil then return end
	
	local nameColor=_goodsNode.name_color
	local goodsType=_goodsNode.type
	local isHasEffect=goodsType and EFFECT_TYPE_ARRAY[goodsType] or false
    nameColor=(nameColor<1 or nameColor>7) and 1 or nameColor

    local nodeSize=_node:getContentSize()
    local framSpr=cc.Sprite:createWithSpriteFrameName("ui_goods_fram_"..tostring(nameColor)..".png")
    framSpr:setPosition(nodeSize.width*0.5,nodeSize.height*0.5)
    _node:addChild(framSpr,-1)

    if isHasEffect and nameColor>=4 and nameColor<=7 then
        local effectSpr=cc.Sprite:create()
        effectSpr:setPosition(nodeSize.width*0.5,nodeSize.height*0.5)
        _node:addChild(effectSpr,1)

        local pAnimate=_G.AnimationUtil:getGoodsEffectAnimate(nameColor)
        local action=cc.RepeatForever:create(pAnimate)
        effectSpr:runAction(action)
    end

    if _goodsNum~=nil and _goodsNum~=1 then
        local szCount
        if _goodsNum>100000 then
            szCount=string.format("%d万",math.modf(_goodsNum*0.0001))
        else
            szCount=tostring(_goodsNum)
        end
        local numLabel=_G.Util:createLabel(szCount,18)
        numLabel:setAnchorPoint(cc.p(1,0))
        numLabel:setPosition(nodeSize.width*0.5+32,nodeSize.height*0.5-38)
        _node:addChild(numLabel,5)
    end
end

M:__init()
_G.ImageAsyncManager=M
