local SanguozhiMainLayer = class("SanguozhiMainLayer",UFCCSNormalLayer)
require("app.cfg.main_growth_info")
local EffectNode = require("app.common.effects.EffectNode")
local SanguozhiPageViewItem = require("app.scenes.sanguozhi.SanguozhiPageViewItem")
function SanguozhiMainLayer.create(...)
    return SanguozhiMainLayer.new("ui_layout/sanguozhi_SanguozhiMainLayer.json",...)
end
--[[
	index 默认选中的
]]
function SanguozhiMainLayer:ctor(json,index,...)
	self._listData = {}
	self._listDataIndex = {}

	--当前正在显示的
	self._currentShowData = {}
	self._selectedIndex = index and index or 1
    self.super.ctor(self,...)
    self:_initListData()
    self:_initEvent()
    self:_initWidgets()
    self:_createStroke()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_MAIN_GROUTH_INFO, self._getInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USE_MAIN_GROUTH_INFO, self._useInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._bagDataChange, self)
    if G_Me.sanguozhiData:checkEnterSanguozhi() == false then

    	G_HandlersManager.sanguozhiHandler:sendGetMainGrouthInfo()
   	else
   		self:_refreshWidgets()
   	end 
end

function SanguozhiMainLayer:_initListData()
	local len = main_growth_info.getLength()
	for i=1,len do
		local data = main_growth_info.indexOf(i)
		table.insert(self._listData,data)
		self._listDataIndex[data.id] = data
	end
end

function SanguozhiMainLayer:_initEvent()
	self:registerBtnClickEvent("Button_back",function()
		self:onBackKeyEvent()
		end)
	self:registerBtnClickEvent("Button_attr",function()
		local stringList = {}
		local list = G_Me.sanguozhiData:getAttrList()
		if list ~= nil then
			for type,value in pairs(list) do
				local text = G_lang.getGrowthTypeName(type)
				-- text = text .. "+" ..value
				local data = {text=text,value=value}
				table.insert(stringList,data)
			end
		end
		require("app.scenes.sanguozhi.SanguozhiAttrLayer").show(stringList)
		end)
	self:registerBtnClickEvent("Button_dianliang",function()
		local lastId = G_Me.sanguozhiData:getLastUsedId()
		if self._iconList == nil or #self._iconList == 0 then
			return
		end
		local mxIcon = self._iconList[self._selectedIndex]
		if lastId == #self._listData then
			G_MovingTip:showMovingTip(G_lang:get("LANG_MING_XING_QUAN_DIAN_LIANG"))
			return
		end
		if mxIcon == nil or (mxIcon:getId() ~= self._selectedIndex*5) then
			return
		end  
		local count = G_Me.bagData:getSanguozhiFragmentCount()
		local data = self._listData[lastId+1]
		if count < data.cost_num then
			G_MovingTip:showMovingTip(G_lang:get("LANG_CAN_JUAN_NOT_ENOUGH"))
			return
		end

		if data.reward_type == 2 then
			self:_selectedAwardLayer(data.id)
			return
		end 
		self:setTouchEnabled(false)
		G_HandlersManager.sanguozhiHandler:sendUseMainGrouthInfo(data.id,0)
		end)
end

function SanguozhiMainLayer:_selectedAwardLayer(_id)
	local _callback = function(index)
		if self and self.setTouchEnabled then
			self:setTouchEnabled(false)
		end
		G_HandlersManager.sanguozhiHandler:sendUseMainGrouthInfo(_id,index)
	end
	require("app.scenes.sanguozhi.SanguozhiSelectAwardLayer").show(_id,_callback)
end

function SanguozhiMainLayer:_initWidgets()
	self._scrollView = self:getScrollViewByName("ScrollView_top")
	self._scrollView:setScrollEnable(true)
	self._mxButtonList = {
		self:getButtonByName("Button_mx01"),
		self:getButtonByName("Button_mx02"),
		self:getButtonByName("Button_mx03"),
		self:getButtonByName("Button_mx04"),
		self:getButtonByName("Button_mx05"),
	}

	self._attrLabel = self:getLabelByName("Label_attr")
	self._attrTagLabel = self:getLabelByName("Label_attrTag")
	self._canjuanNumLabel = self:getLabelByName("Label_canjuanNum")
	local appstoreVersion = (G_Setting:get("appstore_version") == "1")
	local panel = self:getPanelByName("Panel_knight")
	if not appstoreVersion and not IS_HEXIE_VERSION  then 
		local knightId = G_Me.bagData.knightsData:getMainKnightBaseId()
		require("app.cfg.knight_info")
		local knight = knight_info.get(knightId)
		local name = ""
		self._knight = EffectNode.new(knight.sex==1 and "effect_nan_create" or "effect_nv_create", 
		    function(event, frameIndex)
		        if event == "finish" then
	 	    
		        end
		    end
		)
		if knight.sex == 1 then
			--男
			self._knight:setPosition(ccp(50,-120))
		else
			--女
			self._knight:setPosition(ccp(30,-120))
		end
		-- self._knight:setOpacity(150)
		self._knight:play()
		
		panel:addNode(self._knight)
	else
		panel:setVisible(false)
	end

	-- 左翻页箭头
	self:registerBtnClickEvent("Button_Arrow_left", function(sender)
    	local nCurIndex = self._mPageView:getCurPageIndex()
    	local nPreIndex = nCurIndex - 1
    	if nPreIndex < 0 then
           nPreIndex = 0
    	end
    	self:showIconSelected(nPreIndex + 1)
    	self._mPageView:scrollToPage(nPreIndex)
	end)
	
	-- 右翻页箭头
	self:registerBtnClickEvent("Button_Arrow_right", function(sender)
		local nCurIndex = self._mPageView:getCurPageIndex()
		local nNextIndex = nCurIndex + 1
		local nPageCount = self._mPageView:getPageCount()
		if nNextIndex >= nPageCount then
           nNextIndex = nPageCount - 1
		end
		self:showIconSelected(nNextIndex + 1)
    	self._mPageView:scrollToPage(nNextIndex)
	end)
end

function SanguozhiMainLayer:_createStroke()
	self._attrLabel:createStroke(Colors.strokeBrown,1)
	self._attrTagLabel:createStroke(Colors.strokeBrown,1)
	self._canjuanNumLabel:createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_numTag"):createStroke(Colors.strokeBrown,1)
end

function SanguozhiMainLayer:_initScrollView()
	local SanguozhiMingXingIcon = require("app.scenes.sanguozhi.SanguozhiMingXingIcon")
	self._scrollView:removeAllChildrenWithCleanup(true)
	if self._listData == nil or #self._listData == 0 then
		return
	end
	--命星icon
	self._iconList = {}
	--有重叠，所以是负数
	local space = -5
	local scrollviewHeight = self._scrollView:getContentSize().height
	local _width = 0 --icon的宽度
	local lastId = G_Me.sanguozhiData:getLastUsedId()

	local len = math.ceil(#self._listData/5) 
	for i=1,len do
		local data = self._listData[i*5]
		if data then
			local mingXingIcon = SanguozhiMingXingIcon.new(data)
			table.insert(self._iconList,mingXingIcon)
			local _height = mingXingIcon:getContentSize().height
			_width = mingXingIcon:getContentSize().width
			mingXingIcon:setPosition(ccp(_width*(i-1)+i*space,(scrollviewHeight-_height)/2))
			if i == len then
				mingXingIcon:showGray(false)
			else
				mingXingIcon:showGray(self._listData[i*5+1].id > lastId)
			end
			mingXingIcon:setOnClickEvent(function()
				--切换icon
				self:showIconSelected(i)
				self._mPageView:scrollToPage(i - 1)
				end)
			self._scrollView:addChild(mingXingIcon)
		end
	end

	local _scrollViewWidth = _width*len+space*(len-1)
	self._scrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,self._scrollView:getContentSize().height))
	self:showIconSelected(self._selectedIndex)
end

function SanguozhiMainLayer:_initPageView()
	if self._mPageView == nil then
	    local panel = self:getPanelByName("Panel_mingxing")
	    self._mPageView = CCSNewPageViewEx:createWithLayout(panel)
	    self._mPageView:setPageCreateHandler(function ( page, index )
	        return CCSPageCellBase:create()
	    end)
	    self._mPageView:setPageTurnHandler(function ( page, index, cell )
	    	self:showIconSelected(index+1)
	    	local _page = self:_getCurrentPage()
	    	if _page and _page.pageItem then
	    		_page.pageItem:refreshWidgets()
	    	end
	    end)
	    self._mPageView:setPageUpdateHandler(function ( page, index, cell )
	        if cell and cell.removeAllChildren then
	        	cell:removeAllChildren()
	        end
	        local _t = {
	        	self._listData[index*5+1],
	        	self._listData[index*5+2],
	        	self._listData[index*5+3],
	        	self._listData[index*5+4],
	        	self._listData[index*5+5],
	    	}
	     --    --暂时随机1-5
	     	--取第一id
	     	local layout_id = 0
	     	if self._listData[index*5+1] then
	     		layout_id = self._listData[index*5+1].layout_id
	     	else
	     		layout_id = math.random(1,5)
	     	end
	        local pageItem = SanguozhiPageViewItem.new({type=layout_id,data=_t})
	        cell.pageItem = pageItem

	        cell:addChild(pageItem)
	    end)
	    local lastId = G_Me.sanguozhiData:getLastUsedId()
	    local count = math.ceil(#self._listData/5)
	    if lastId == #self._listData then
	    	self._mPageView:showPageWithCount(count,count-1)
	    else
	    	self._mPageView:showPageWithCount(count,math.ceil((lastId+1)/5)-1)
	    end
	end
end


function SanguozhiMainLayer:showIconSelected(index)
	self._selectedIndex = index
	if self._iconList == nil or #self._iconList == 0 then
		return
	end
	local lastId = G_Me.sanguozhiData:getLastUsedId()

	for i,icon in ipairs(self._iconList)do
		icon:showSelected(i == index)
		local data = self._listData[(i-1)*5+1]
		--最后一个点亮的id   icon的id
		icon:showGray(icon:getId() > (lastId+1))
		icon:showGray(math.ceil(icon:getId()/5) > (math.floor(lastId/5)+1))
	end

	if self._scrollView == nil then 
	    return
	end

	--按钮的宽度
	local buttonWidth = self._iconList[index]:getContentSize().width
	local innerContainer = self._scrollView:getInnerContainer()
	--计算选中按钮的位置是否超出了
	local position = innerContainer:convertToWorldSpace(ccp(self._iconList[index]:getPosition()))
	--滑动区域宽度
	local scrollAreaWidth = innerContainer:getContentSize().width- self._scrollView:getContentSize().width
	if position.x < 0 then
	    --需要位移
	    local percent = self._iconList[index]:getPositionX()/scrollAreaWidth
	    self._scrollView:scrollToPercentHorizontal(percent*100,0.3,false)
	    --因为position是世界坐标
	elseif math.abs(position.x) > self._scrollView:getContentSize().width + self._scrollView:getPositionX() - buttonWidth then
	    --需要位移
	    local percent = (math.abs(self._iconList[index]:getPositionX())-self._scrollView:getContentSize().width + buttonWidth)/scrollAreaWidth
	    self._scrollView:scrollToPercentHorizontal(100*percent,0.3,false)
	end

	self:_refreshBottomStates()
end


--在消息到来之后刷新widgets
function SanguozhiMainLayer:_refreshWidgets()
	local lastId = G_Me.sanguozhiData:getLastUsedId()
	--判断是否是4选1
	if lastId < #self._listData then
		local data = self._listData[lastId+1]
		self._selectedIndex = math.ceil((lastId + 1)/5)
	else
		self._selectedIndex = math.ceil(lastId/5)
	end
	self:_initScrollView()
	self:_initPageView()
end


function SanguozhiMainLayer:_refreshBottomStates()
	local lastId = G_Me.sanguozhiData:getLastUsedId()
	--判断底部状态
	if (lastId+1) > self._selectedIndex*5 then 
		--已点亮
		self:showWidgetByName("Panel_normal",false)
		self:showWidgetByName("Panel_unNormal",true)
		self:showWidgetByName("Image_weikaiqi",false)
		self:showWidgetByName("Image_yidianliang",true)
	elseif (lastId+1) < (self._selectedIndex-1)*5+1 then
		--未开启
		self:showWidgetByName("Panel_normal",false)
		self:showWidgetByName("Panel_unNormal",true)
		self:showWidgetByName("Image_weikaiqi",true)
		self:showWidgetByName("Image_yidianliang",false)
	else
		--正常状态
		self:showWidgetByName("Panel_normal",true)
		self:showWidgetByName("Panel_unNormal",false)
		--设置属性值
		local data = self._listData[lastId+1]
		if data then
			if data.important == 1 then
				self._attrLabel:setText(data.seen_directions)
			else

				self._attrLabel:setText(data.seen_directions)
			end
			local count = G_Me.bagData:getSanguozhiFragmentCount()
			local cost_num = data.cost_num
			self._canjuanNumLabel:setColor(cost_num > count and Colors.darkColors.TIPS_01 or Colors.darkColors.DESCRIPTION)
			-- self._canjuanNumLabel:setText(cost_num .. "/" .. count)
			self._canjuanNumLabel:setText(count .. "/" .. cost_num)
		end 
	end
end

function SanguozhiMainLayer:adapterLayer()
	self:adapterWidgetHeight("Panel_bottom","Panel_main","",0,0)
end

function SanguozhiMainLayer:onLayerLoad( ...  )
    self:registerKeypadEvent(true)
end

function SanguozhiMainLayer:onBackKeyEvent( ... )
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    return true
end
---------------------------START-------------------

function SanguozhiMainLayer:_getInfo(data)
	if data.ret == 1 then
		self:_refreshWidgets()

	end
end

function SanguozhiMainLayer:_useInfo(d)
	if d.ret == 1 then
		--添加点亮动画
		local _callback = function()
			local data = self._listDataIndex[d.id]
			if data then
				if data.reward_type == 0 then   --属性加成 播放动画
				else  -- = 1 or =2  道具奖励
					local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(d.awards)
					uf_notifyLayer:getModelNode():addChild(_layer)
				end

				if data.attribute_type ~= 0 then
					local text = G_lang.getGrowthTypeName(data.attribute_type)
					text = text .. " +" .. data.attribute_value
					text = G_lang:get("LANG_DIAN_LIANG_SUCCESS_ADD_ATTR",{attr=text})
					G_flyAttribute.doAddRichtext(G_lang:get("LANG_DIAN_LIANG_SUCCESS_TIPS",{name=data.name}),30,nil,Colors.strokeBrown,nil,30)
					G_flyAttribute.doAddRichtext(text,30,nil,Colors.strokeBrown,self:getButtonByName("Button_attr"),0)
					G_flyAttribute.play(function()
						if self.__EFFECT_FINISH_CALLBACK__ then 
        					self.__EFFECT_FINISH_CALLBACK__( )
    					end
    					if self and self.playAnimation and G_SceneObserver:getSceneName() == "SanguozhiMainScene" then
							self:playAnimation("Animation_scale",function() 
							end)
    					end
					end)
				else
					-- G_MovingTip:showMovingTip("点亮成功")
				end

				if data.function_type == 1 then
					-- body
					require("app.scenes.common.HeroQualityResult").showHeroQualityResult()
				end 
				if data.id == #self._listData then
					self:showIconSelected(math.ceil((data.id)/5))
				else
					self:showIconSelected(math.ceil((data.id+1)/5))
					if data.id%5 == 0 then
						--需要scrool to next
						local _index = self._mPageView:getCurPageIndex()
						if _index+1 < self._mPageView:getPageCount() then
							self._mPageView:scrollToPage(_index+1)
						end
					else
					end
				end
				self:setTouchEnabled(true)
			end
		end
		
		local _page = self:_getCurrentPage()
		if _page and _page.pageItem then
			_page.pageItem:startPlayEffect(self,d.id,_callback)
		end
	else
		self:setTouchEnabled(true)
	end
end

function SanguozhiMainLayer:_getCurrentPage()
	local _index = self._mPageView:getCurPageIndex()
	local _page = self._mPageView:getPage(_index);
	return _page
end

function SanguozhiMainLayer:_bagDataChange()
	-- local count = G_Me.bagData:getSanguozhiFragmentCount()
	-- print("self._selectedIndex = " .. self._selectedIndex)
	-- local cost_num = self._listData[self._selectedIndex].cost_num
	-- print(string.format("包裹变化 %d/%d",count,cost_num))
	-- -- self._canjuanNumLabel:setText(cost_num .. "/" .. count)
	-- self._canjuanNumLabel:setText(count .. "/" .. cost_num)
	-- self._canjuanNumLabel:setColor(cost_num > count and Colors.darkColors.TIPS_01 or Colors.darkColors.DESCRIPTION)
end

------------------------END-----------------------

function SanguozhiMainLayer:onLayerUnload(  )
	uf_eventManager:removeListenerWithTarget(self)
end

function SanguozhiMainLayer:onLayerEnter()
	G_GlobalFunc.flyIntoScreenLR({self:getWidgetByName("ScrollView_top"),self:getWidgetByName("Panel_mingxing")}, false, 0.2, 5, 100,
		function( )
			self:showWidgetByName("Panel_bottom",true)
	    end)
end

return SanguozhiMainLayer