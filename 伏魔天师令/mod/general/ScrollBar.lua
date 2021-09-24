local ScrollBar=classGc(function(self,_scrollView,_isHideBar)
	self.m_isHideBar=_isHideBar
	self:__init(_scrollView)
end)

function ScrollBar.__init(self,_scrollView)
	if _scrollView==nil then return end
	self.m_scrollView=_scrollView
	self.m_scrollView:setBounceable(false)

	self:__initParameter()
	self:__initBarView()
end

function ScrollBar.__initParameter(self)
	-- 滚动条的偏移量
	self.m_barOffPos=self.m_barOffPos or {x=0,y=0}
	-- 滚动条的高度偏移量
	self.m_offMoveHeight=self.m_offMoveHeight or 0

	-- 底部箭头的偏移量
	self.m_dirOffPos=self.m_dirOffPos or {x=0,y=0}

	local viewSize=self.m_scrollView:getViewSize()
	local viewPos=cc.p(self.m_scrollView:getPosition())
	local viewHeight=viewSize.height
	local contentHeight=self.m_scrollView:getContentSize().height

	-- 底部箭头的位置
	local dirPosX=self.m_dirOffPos.x+viewPos.x+viewSize.width*0.5
	local dirPosY=self.m_dirOffPos.y+viewPos.y-2
	self.m_dirRealPos=cc.p(dirPosX,dirPosY)

	-- 滚动条的X初始位置
	self.m_barPosX=self.m_barOffPos.x+viewSize.width+viewPos.x
	-- 看不见的高度
	self.m_exceedHeight=contentHeight-viewHeight
	if self.m_exceedHeight==0 then
		-- 滚动条的高度
		self.m_barHeight=contentHeight+self.m_offMoveHeight
		-- Y最高位置
		self.m_barTopY=self.m_barOffPos.y+viewPos.y+self.m_barHeight*0.5
		-- Y最低位置
		self.m_barDownY=self.m_barTopY
		-- Y相差值
		self.m_barSubY=0
	else
		-- 滚动条的高度
		self.m_barHeight=viewHeight*viewHeight/contentHeight
		-- Y最高位置
		self.m_barTopY=self.m_barOffPos.y+viewPos.y+viewHeight-self.m_barHeight*0.5+self.m_offMoveHeight*0.5
		-- Y最低位置
		self.m_barDownY=self.m_barOffPos.y+viewPos.y+self.m_barHeight*0.5-self.m_offMoveHeight*0.5
		-- Y相差值
		self.m_barSubY=self.m_barTopY-self.m_barDownY
	end
	self.m_viewZOrder=self.m_scrollView:getLocalZOrder()
	self.m_parent=self.m_scrollView:getParent()
	if self.m_parent==nil then
		_G.Util:showTipsBox("请先设置ScbarView的parent")
		return
	end

	local function c()
		self:__updateBarSprPos()
		self:__showBarSprEffect()
	end

	if self.m_exceedHeight==0 then
		self.m_scrollView:unregisterScriptHandler(cc.SCROLLVIEW_SCRIPT_SCROLL)
	else
		if not self.m_scrollView:isTouchEnabled() then
			self.m_scrollView:setTouchEnabled(true)
		end
		self.m_scrollView:setDelegate()
		self.m_scrollView:registerScriptHandler(c,cc.SCROLLVIEW_SCRIPT_SCROLL)
	end

	self.ViewSize=viewSize

	-- local scrollContainer=self.m_scrollView:getContainer()
	-- if scrollContainer~=nil then
	-- 	scrollContainer:runAction(cc.Sequence:create(cc.MoveBy:create(0.01,cc.p(30,0)),
	-- 												cc.MoveBy:create(0.2,cc.p(-40,0)),
	-- 												cc.MoveBy:create(0.1,cc.p(10,0))))
	-- end
end

function ScrollBar.__initBarView(self)
	if self.m_parent==nil then return end

	if not self.m_isHideBar then
		self.m_barSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_slider.png")
		self.m_barSpr:setAnchorPoint(cc.p(0,0.5))
		self.m_barSpr:setOpacity(0)
		self.m_barSpr:setPreferredSize(cc.size(5,self.m_barHeight))
		self.m_parent:addChild(self.m_barSpr,self.m_viewZOrder)
	end

	-- self.m_dirSpr=cc.Sprite:createWithSpriteFrameName("general_down.png")
	-- self.m_dirSpr:setAnchorPoint(cc.p(0.5,1))
	-- self.m_dirSpr:setPosition(self.m_dirRealPos)
	-- self.m_parent:addChild(self.m_dirSpr)

	-- if self.m_exceedHeight==0 then
		-- self.m_dirSpr:setOpacity(0)
	-- end

	self:__updateBarSprPos()
end

function ScrollBar.__updateBarSprPos(self)
	if self.m_exceedHeight==0 then
		if self.m_barSpr==nil then return end
		self.m_barSpr:setPosition(self.m_barPosX,self.m_barTopY)
	else
		local offsetPos=self.m_scrollView:getContentOffset()
		local moveScale=math.abs(offsetPos.y)/self.m_exceedHeight

		if self.m_barSpr~=nil then
			local curPosY=moveScale*self.m_barSubY+self.m_barDownY
			self.m_barSpr:setPosition(self.m_barPosX,curPosY)
		end

		-- if moveScale<0.05 then
		-- 	self:__updateDirSprState(false)
		-- else
		-- 	self:__updateDirSprState(true)
		-- end
	end
end
function ScrollBar.__showBarSprEffect(self)
	if self.m_barSpr==nil then return end

	local function f()
		local hideAction=cc.FadeTo:create(0.4,0)
		hideAction:setTag(167)
		self.m_barSpr:runAction(hideAction)
	end
	
	local showAction=self.m_barSpr:getActionByTag(166)
	if showAction~=nil then
		return
	end
	local hideAction=self.m_barSpr:getActionByTag(167)
	if hideAction~=nil then
		self.m_barSpr:stopActionByTag(167)
	end
	
	local act1=cc.FadeTo:create(0.4,255)
	local act2=cc.DelayTime:create(1)
	local act3=cc.CallFunc:create(f)
	local showAction=cc.Sequence:create(act1,act2,act3)
	showAction:setTag(166)
	self.m_barSpr:runAction(showAction)
end

function ScrollBar.__updateDirSprState(self,_isShow)
	if self.m_noUpdateDirSpr then return end

	-- local curState=self.m_dirSpr:isVisible()
	if _isShow==curState then return end

	-- self.m_dirSpr:stopAllActions()
	-- if _isShow then
		-- self.m_dirSpr:runAction(cc.Sequence:create(cc.Show:create(),cc.FadeTo:create(0.2,255)))
	-- else
		-- self.m_dirSpr:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,0),cc.Hide:create()))
	-- end
end

-- ****************************
-- 滚动条的偏移量
-- 默认为 {x=0,y=0}(滚动条在scbarview的右边)
-- 例:{x=10,y=10},滚动条在基础上往右移动10,往上移动10
-- ****************************
function ScrollBar.setPosOff(self,_offPos)
	local subX=_offPos.x-self.m_barOffPos.x
	local subY=_offPos.y-self.m_barOffPos.y
	self.m_barOffPos=_offPos
	self.m_barPosX=self.m_barPosX+subX
	self.m_barTopY=self.m_barTopY+subY
	self.m_barDownY=self.m_barDownY+subY
	self:__updateBarSprPos()
end

-- ****************************
-- 滚动条的可移动范围
-- 默认为 0(scroolview 可移动范围与viessize的高度一致)
-- ****************************
function ScrollBar.setMoveHeightOff(self,_addHeight)
	if self.m_barSpr==nil then return end

	local addHeight=_addHeight-self.m_offMoveHeight
	self.m_offMoveHeight=_addHeight
	if self.m_exceedHeight>0 then
		self.m_barTopY=self.m_barTopY+addHeight*0.5
		self.m_barDownY=self.m_barDownY-addHeight*0.5
		self.m_barSubY=self.m_barSubY+addHeight
		self:__updateBarSprPos()
	else
		local curBarHeight=self.m_barHeight+_addHeight
		if curBarHeight>0 then
			self.m_barHeight=curBarHeight
			self.m_barSpr:setPreferredSize(cc.size(5,self.m_barHeight))
		end
	end
end

-- ****************************
-- 底部监听的偏移量
-- ****************************
function ScrollBar.setDirPosOff(self,_offPos)
	local subX=_offPos.x-self.m_dirOffPos.x
	local subY=_offPos.y-self.m_dirOffPos.y
	self.m_dirOffPos=_offPos
	self.m_dirRealPos.x=self.m_dirRealPos.x+subX
	self.m_dirRealPos.y=self.m_dirRealPos.y+subY

	-- self.m_dirSpr:setPosition(self.m_dirRealPos)
end

-- ****************************
-- 不显示底部箭头
-- ****************************
function ScrollBar.hideDirSpr(self)
	if self.m_noUpdateDirSpr then return end
	self.m_noUpdateDirSpr=true

	-- self.m_dirSpr:setVisible(false)
end


-- ****************************
-- 更新滚动条的数据
-- 当scbarview的viewsize、containersize改变时调用,以便重新计算滚动条的位置
-- ****************************
function ScrollBar.chuangeSize(self)
	if self.m_barSpr==nil then return end
	self:__initParameter()
	self:__updateBarSprPos()
	self.m_barSpr:setPreferredSize(cc.size(5,self.m_barHeight))
end

-- ****************************
-- 移除滚动条
-- ****************************
function ScrollBar.remove(self)
	if self.m_barSpr~=nil then
		self.m_barSpr:removeFromParent(true)
		self.m_barSpr=nil
	end
	-- if self.m_dirSpr~=nil then
		-- self.m_dirSpr:removeFromParent(true)
		-- self.m_dirSpr=nil
	-- end
end

-- ****************************
-- 重新绑定scbarview
-- 当scbarview被重新创建时可以调用此接口重新绑定scbarview
-- ****************************
function ScrollBar.resetScbarView(self,_scrollView)
	self:remove()
	self:__init(_scrollView)
end

return ScrollBar







