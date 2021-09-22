GUITable = class("GUITable", function() 
	return ccui.Widget:create() 
end)
-- cc.SCROLLVIEW_DIRECTION_NONE = -1
-- cc.SCROLLVIEW_DIRECTION_HORIZONTAL = 0
-- cc.SCROLLVIEW_DIRECTION_VERTICAL = 1
-- cc.SCROLLVIEW_DIRECTION_BOTH  = 2

function GUITable:setModel(model)
	print("GUITable:setModel(model)")

	if self.model then
		self.model:release()
		self.model = nil
	end
	self:setTouchEnabled(true)
	self.model = model
	self.model:retain()
	self:setSwallowTouches(true)
	self.model:setSwallowTouches(false)
	self.model:setAnchorPoint(cc.p(0.5,0.5))

	self.act = true

	self.viewsize = self:getContentSize()
	self.tableview:setViewSize(self.viewsize)
	if self.slider then
		self.slider:setContentSize(cc.size(13,self.model:getContentSize().height))
		self.slider:align(display.CENTER_BOTTOM, self.direction*self.viewsize.width, self.direction*self.viewsize.height-self.model:getContentSize().height)
	end
	if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
		self.cellSize.width =  self.viewsize.width
		self.cellSize.height = self.model:getContentSize().height + self.listspace
		if self.sliderImgBg then
			self.sliderImgBg:setContentSize(14,self.viewsize.height)
				:align(display.CENTER_BOTTOM,self.viewsize.width,0)
		end
	else
		self.cellSize.height =  self.viewsize.height
		self.cellSize.width = self.model:getContentSize().width + self.listspace
		if self.sliderImgBg then
			self.sliderImgBg:setContentSize(14,self.viewsize.width)
				:align(display.CENTER_BOTTOM,0,0)
		end
	end
	-- self.tableview:setPosition(self.viewsize.width/2, self.viewsize.height/2)

	-- self.tableview:reloadData()

	return self
end

function GUITable:ctor(params)
	self._data = {}

	self.act = true
	print("tableview ctor ---------")
	self.cellSize = cc.size(200,20)
	self.viewsize = cc.size(200,200)
	self.sliderVisible = params.slider == nil and false or params.slider
	self.sliderEnable = false;

	self.tableview=cc.TableView:create(self.viewsize)
	-- self.tableview:setViewSize(self.viewsize)
	self.tableview:setDirection(params.direction)
	self:addChild(self.tableview)

	self._updateCellFunc = params.updateCellFunc

	self.listlen = params.listlen 
	self.celllen = params.celllen 
	self.listspace =params.listspace
	self.cellspace =params.cellspace

	self.direction = params.direction

	self.totalLength = self.listlen * self.celllen
	
	self._curIndex = 1;
	self._borderListener = nil;

	self.tableview:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	self.tableview:setDelegate()
	if self.sliderVisible then
		self.sliderImgBg = ccui.ImageView:create()
		self.sliderImgBg:loadTexture("img_slider_bg",ccui.TextureResType.plistType)
			:setScale9Enabled(true)
			:align(display.CENTER_BOTTOM,0,0)
			:setCapInsets(cc.rect(4,8,2,382-8*2))
			:setContentSize(10,self.viewsize.width)
			:setRotation(self.direction ==0 and 90 or 0)
			:addTo(self)

		local sliderImg = params.sliderImg or "img_slider" --13X56
		self.slider = ccui.ImageView:create()
			:loadTexture(sliderImg,ccui.TextureResType.plistType)
			:align(display.CENTER_BOTTOM,self.direction*self.viewsize.width,self.direction*self.viewsize.height)
			:setRotation(self.direction ==0 and 90 or 0)
			:setScale9Enabled(true)
			:setCapInsets(cc.rect(3,6,2,88-6*2))
			:setName("list_slider")
			:setContentSize(8,8)
			:addTo(self)
		self._sliderCount = 100;
		self.slider:runAction(cca.repeatForever(cca.seq(cca.callFunc(function()
			self._sliderCount = self._sliderCount - 1;
			self._sliderCount = GameUtilSenior.bound(-1, self._sliderCount, 100)
			self:_setSliderVisible(self._sliderCount>=0)
		end))))
	end

	cc(self):addNodeEventListener(cc.NODE_EVENT, function (event)
        if event.name == "exit" then

        	if self.model then
	            self.model:release()
				self.model = nil
			end
			print("GUITable exit !!!")

        end
    end)

	local function tableCellNumbers()
		return self.listlen
	end
	local function tableCellTouched(table,cell)	end
	local function setTableCellSize(view,idx)
		if self.listspace > 0 and idx == self.listlen-1 then
			return self.cellSize.width,self.cellSize.height - self.listspace
		end
		return self.cellSize.width,self.cellSize.height
	end
	local function scrollViewDidScroll(view)
		self._sliderCount = 100;
		-- if not self.sliderVisible or not self.sliderEnable then return end
		local offset = view:getContentOffset()
		if self.direction == cc.SCROLLVIEW_DIRECTION_HORIZONTAL then
			local max = math.max(self.listlen*self.cellSize.width,self.viewsize.width,self.viewsize.width+offset.x,self.viewsize.width-offset.x)
			if GameUtilSenior.isObjectExist(self.slider) then
				self.slider:setContentSize(cc.size(8,self.viewsize.width*self.viewsize.width/max))
				local percent = (self.listlen*self.cellSize.width+offset.x)/max
				local maxPercent = (self.listlen*self.cellSize.width-self.viewsize.width)/(self.listlen*self.cellSize.width)
				if percent<1-maxPercent then
					self.slider:setPositionX(self.viewsize.width-self.viewsize.width*self.viewsize.width/max)
				else
					if percent>1 then percent = 1 end
					self.slider:setPositionX((1-percent)*self.viewsize.width)			
				end
			end
			self._curIndex = self.celllen*(math.ceil(math.abs(self.listlen*self.cellSize.width+offset.x- self.viewsize.width)/self.cellSize.width)+1)
			self._curIndex = GameUtilSenior.bound(1, self._curIndex, self.totalLength)
			if self._borderListener then
				self._borderListener(offset.x/(self.viewsize.width-view:getContentSize().width))
			end
		elseif self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
			local max = math.max(self.listlen*self.cellSize.height,self.viewsize.height,self.viewsize.height+offset.y,self.viewsize.height-offset.y)
			if GameUtilSenior.isObjectExist(self.slider) then
				self.slider:setContentSize(cc.size(8,self.viewsize.height*self.viewsize.height/max))
				local percent = (self.listlen*self.cellSize.height+offset.y)/max
				local maxPercent = (self.listlen*self.cellSize.height-self.viewsize.height)/(self.listlen*self.cellSize.height)
				if percent<1-maxPercent then
					self.slider:setPositionY(self.viewsize.height*(1-self.viewsize.height/max))
				else
					if percent>1 then percent = 1 end
					self.slider:setPositionY((1-percent)*self.viewsize.height)
				end
			end
			-- self._curIndex = self.celllen*(math.ceil(math.abs(self.listlen*self.cellSize.height+offset.y- self.viewsize.height)/self.cellSize.height)+1)
			self._curIndex = math.ceil((self.viewsize.height - self:getContentSize().height+offset.y)/self.cellSize.height)*self.celllen
			self._curIndex = GameUtilSenior.bound(1, self._curIndex, self.totalLength)
			if self._borderListener then
				self._borderListener(1-offset.y/(self.viewsize.height-view:getContentSize().height))
			end
		end
	end
	local function scrollViewdidZoom(view)	end
	local function cellPressedBegan(table,cell)	end
	local function cellPressedEnd(table,cell)	end
	local function willRecycle(table,cell)	end
	local function updateCell(table,idx)---idx 从0开始
		local cell = table:dequeueCell()
		local index = 0
		local widget,modelclone,x,y,modelSize
		if cell then
			if not self.model then
				return cell
			end
			widget = cell:getChildByName("_widget")
			if not widget then
				widget = ccui.Widget:create()
				widget:setContentSize(self.cellSize)
				widget:setName("_widget")
				widget:addTo(cell)
				modelSize = self.model:getContentSize()

				for i=1,self.celllen do
					index = idx*self.celllen + i
					modelclone = self.model:clone()
					modelclone.tag = index
					modelclone:setVisible(index<=self.totalLength)
					if self.direction ==cc.SCROLLVIEW_DIRECTION_VERTICAL then
						x = modelSize.width/2 + (i-1) * ( self.cellspace + modelSize.width)
						y = self.cellSize.height/2 + self.listspace/2
					else
						x = modelSize.width/2 + self.listspace/2
						y = modelSize.height/2 + (self.celllen - i) * ( self.cellspace + modelSize.height)
					end
					modelclone:align(display.CENTER, x, y):setTag(i):addTo(widget)
					if index<= self.totalLength and self._updateCellFunc then
						modelclone:runAction(
							cca.cb(function(render)
								self._updateCellFunc(render)
								render:setSwallowTouches(false)
							end)
						)
					end
				end
				local widgetY = 0
				if idx == self.listlen-1 and self.listspace>0 then
					widgetY = - self.listspace
				end
				if (self.viewsize.height > idx * self.cellSize.height or self.viewsize.width > idx * self.cellSize.width) and not self.act then
					local placeAction,MoveAction
					if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
						widget:align(display.BOTTOM_LEFT, self.viewsize.width, widgetY)
						placeAction = cca.place(self.act and 0 or self.viewsize.width, widgetY)
						MoveAction =  cca.moveTo(self.cellSize.width/2048,0,widgetY)
					else
						widget:align(display.BOTTOM_LEFT, 0, -widgetY)
						placeAction = cca.place(0, self.act and 0 or -modelSize.height-widgetY)
						MoveAction =  cca.moveTo(self.cellSize.height/1024,0,widgetY)
					end
					widget:runAction(cca.seq({
							placeAction,
							cca.delay(idx*0.1),
							MoveAction
						})
					)
				else
					self.act=true
					widget:align(display.BOTTOM_LEFT, 0, widgetY)
				end
			else
				for i=1,self.celllen do

					index = idx * self.celllen + i
					modelclone = widget:getChildByTag(i)
					modelclone.tag = index
					modelclone:setVisible(index<=self.totalLength)

					if index <= self.totalLength and self._updateCellFunc then
						modelclone.tag = index
						modelclone:runAction(
							cca.cb(function(render)
								self._updateCellFunc(render)
								render:setSwallowTouches(false)
							end)
						)
					end
				end
				if idx == self.listlen-1 and self.listspace>0 then
					widget:align(display.BOTTOM_LEFT, 0,-self.listspace)
				else
					widget:align(display.BOTTOM_LEFT, 0,0)
				end
				-- local widgetY = 0
				-- if idx == self.listlen-1 and self.listspace>0 then
				-- 	widgetY = - self.listspace
				-- end
				-- if self.viewsize.height > idx * self.cellSize.height and not self.act then
				-- 	widget:align(display.BOTTOM_LEFT, self.viewsize.width, widgetY)
				-- 	widget:runAction(cca.seq({
				-- 			cca.place(self.act and 0 or self.viewsize.width, widgetY),
				-- 			cca.delay(idx*0.1),
				-- 			cca.moveTo(self.cellSize.width/2048,0,widgetY)
				-- 		})
				-- 	)
				-- else
				-- 	self.act=true
				-- 	widget:align(display.BOTTOM_LEFT, 0, widgetY)
				-- end
			end
		else
			cell = cc.TableViewCell:create()
			if self.model then
				widget = ccui.Widget:create()
				widget:setContentSize(self.cellSize)
				widget:setName("_widget")
				widget:addTo(cell)
				modelSize = self.model:getContentSize()
				for i=1,self.celllen do
					index = idx*self.celllen + i
					modelclone = self.model:clone()
					modelclone.tag = index
					modelclone:setVisible(index<=self.totalLength)
					if self.direction ==cc.SCROLLVIEW_DIRECTION_VERTICAL then
						x = modelSize.width/2 + (i-1) * ( self.cellspace + modelSize.width)
						y = self.cellSize.height/2 + self.listspace/2
					else
						x = modelSize.width/2 + self.listspace/2
						y = modelSize.height/2 + (self.celllen - i) * ( self.cellspace + modelSize.height)
					end
					modelclone:align(display.CENTER, x, y):setTag(i):addTo(widget)
					if index<= self.totalLength and self._updateCellFunc then
						modelclone:runAction(
							cca.cb(function(render)
								self._updateCellFunc(render)
								render:setSwallowTouches(false)
							end)
						)
					end
				end
				local widgetY = 0
				if idx == self.listlen-1 and self.listspace>0 then
					widgetY = - self.listspace
				end
				if (self.viewsize.height > idx * self.cellSize.height or self.viewsize.width > idx * self.cellSize.width) and not self.act then
					local placeAction,MoveAction
					if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
						widget:align(display.BOTTOM_LEFT, self.viewsize.width, widgetY)
						placeAction = cca.place(self.act and 0 or self.viewsize.width, widgetY)
						MoveAction =  cca.moveTo(self.cellSize.width/2048,0,widgetY)
					else
						widget:align(display.BOTTOM_LEFT, 0, -widgetY)
						placeAction = cca.place(0, self.act and 0 or -modelSize.height -widgetY)
						MoveAction =  cca.moveTo(self.cellSize.height/1024,0,widgetY)
					end
					widget:runAction(cca.seq({
							placeAction,
							cca.delay(idx*0.1),
							MoveAction
						})
					)
				else
					self.act=true
					widget:align(display.BOTTOM_LEFT, 0, widgetY)
				end
			end
		end
		return cell
	end
	self.tableview:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
	self.tableview:registerScriptHandler(scrollViewdidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)
	self.tableview:registerScriptHandler(setTableCellSize,cc.TABLECELL_SIZE_FOR_INDEX)
	self.tableview:registerScriptHandler(cellPressedBegan,cc.TABLECELL_HIGH_LIGHT)
	self.tableview:registerScriptHandler(cellPressedEnd,cc.TABLECELL_UNHIGH_LIGHT)
	self.tableview:registerScriptHandler(willRecycle,cc.TABLECELL_WILL_RECYCLE)
	self.tableview:registerScriptHandler(updateCell,cc.TABLECELL_SIZE_AT_INDEX)
	self.tableview:registerScriptHandler(tableCellTouched,cc.TABLECELL_TOUCHED)
	self.tableview:registerScriptHandler(tableCellNumbers,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	self.tableview:reloadData()
end

function GUITable:setSliderVisible(bool)
	if self.sliderEnable ~= bool then
		self.sliderEnable = bool
		if self.slider then	self.slider:setVisible(bool) end
		if self.sliderImgBg then self.sliderImgBg:setVisible(bool) end
	end
	return self
end
--内部使用
function GUITable:_setSliderVisible(bool)
	if self.sliderVisible ~= bool then 
		self.sliderVisible = bool
		if self.slider and self.sliderEnable then	self.slider:setVisible(bool) end
		if self.sliderImgBg and self.sliderEnable then self.sliderImgBg:setVisible(bool) end
	end
	return self
end

function GUITable:cellAtIndex(idx)
	return self.tableview:cellAtIndex(idx)
end

function GUITable:insertCellAtIndex(idx)
	self.tableview:insertCellAtIndex(idx)
	return self
end

function GUITable:removeAllData()
	self.totalLength = 0
	self.listlen = 0
	-- self.celllen = 0--不可设0
	self._curIndex = 0
	self.tableview:reloadData()
	return self
end

function GUITable:removeCellAtIndex(idx)
	self.tableview:removeCellAtIndex(idx)
	return self
end

--[[
	total: 总个数
	func: update单个model函数
	anim: 是否需要动画
	offsetX:进度条横向偏移
	offsetY:进度条竖向向偏移
]]

function GUITable:reloadData(total,func,offsetX,anim)

	if type(total)=="number" and type(func)=="function" then
		self.totalLength = total

		self.listlen = math.ceil(total/self.celllen)
		if type(anim) =="boolean" then self.act = not anim end
		
		if total == 0 and self.slider then 
			self.slider:hide()
		end
		if offsetX  and self.slider and self.sliderVisible then
			self.slider:setPositionX(self.viewsize.width + offsetX)
			if self.direction == 1 then
				self.sliderImgBg:setPositionX(self.viewsize.width + offsetX)
			end
		end
		-- if offsetY  and self.slider then  self.slider:setPositionY(offsetY) end

		self._updateCellFunc = func
		self.tableview:reloadData()
	end
	return self
end

function GUITable:setSliderOffset( offset )
	if type(offset) == "table" and offset.x and offset.y then
		if self.slider and self.sliderVisible then
			self.slider:setPositionX(self.viewsize.width + offset.x)
			self.slider:setPositionY(self.viewsize.height + offset.y)

			if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
				self.sliderImgBg:setPositionX(self.viewsize.width + offset.x)
				self.sliderImgBg:setPositionY(self.viewsize.height + offset.y)
			end
		end
	end
	return self
end

function GUITable:setAnimateEnabled( enabled )
	if self.act ~= enabled then
		self.act = enabled
	end
	return self
end

function GUITable:updateCellAtIndex(idx)
	self.tableview:updateCellAtIndex(idx)
	return self
end


function GUITable:getModelByIndex(index)--从1开始，只能返回可见区域内的model
	local model = nil
	local coloumn = math.ceil(index/self.celllen)-1
	local row = index%self.celllen == 0 and self.celllen or index%self.celllen
	if index <= self.totalLength and self.celllen>0 then
		local cell = self.tableview:cellAtIndex(coloumn)
		if cell then
			local _widget = cell:getChildByName("_widget")
			if _widget then
				model = _widget:getChildByTag(row)
			end
		end
	end
	return model
end

function GUITable:setContentOffsetInDuration( offset,duration )
	self.tableview:setContentOffsetInDuration(offset,duration)
	return self
end

function GUITable:setContentOffset( offset,animated )
	self.tableview:setContentOffset(offset,animated)
	return self
end

function GUITable:setClippingToBounds(enabled)
	self.tableview:setClippingToBounds(enabled)
	return self
end

function GUITable:setBounceEnabled(enabled)
	self.tableview:setBounceable(enabled)
	return self
end

function GUITable:setTouchEnabled(enabled)
	self.tableview:setTouchEnabled(enabled)
	return self
end

function GUITable:getContainer()
	return self.tableview:getContainer()
end

function GUITable:autoMoveToIndex(index)
	index = GameUtilSenior.bound(1, index, self.totalLength)
	--if type(index) == "number" and self._curIndex ~= index then
	if type(index) == "number" then
		if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
			local row = math.ceil(self.totalLength/self.celllen)--行数
			index = GameUtilSenior.bound(1,index, row)
			local lastPos = self.viewsize.height - (row-index+1) * self.cellSize.height --+ self.listspace
			lastPos = GameUtilSenior.bound(self.viewsize.height - self.tableview:getContentSize().height,lastPos,0)
			self.tableview:setContentOffsetInDuration({x=0,y= lastPos},0.2)
		else
			local col = math.ceil(self.totalLength/self.celllen)--列数
			index = GameUtilSenior.bound(0,index,col)
			local lastPos = (1-index) * self.cellSize.width + self.cellspace
			lastPos = GameUtilSenior.bound(self.viewsize.width - self.tableview:getContentSize().width,lastPos,0)
			self.tableview:setContentOffsetInDuration({x=lastPos, y=0},0.1)
		end
	end
	return self
end

function GUITable:moveToPreItem()
	local offset = self.tableview:getContentOffset()
	local offsetmin = self.tableview:minContainerOffset();
	local offsetmax = self.tableview:maxContainerOffset();
	if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
		local posY = offset.y + self.cellSize.height
		posY = math.ceil(posY/self.cellSize.height)*self.cellSize.height
		posY = GameUtilSenior.bound(offsetmin.y, posY, offsetmax.y)
		self.tableview:setContentOffsetInDuration({x=0, y=posY},0.1)
	else
		local posX = offset.x + self.cellSize.width
		posX = math.ceil(posX/self.cellSize.width)*self.cellSize.width
		posX = GameUtilSenior.bound(offsetmin.x, posX, offsetmax.x)
		self.tableview:setContentOffsetInDuration({x=posX, y=0},0.1)
	end
	return self
end

function GUITable:moveToNextItem()
	local offset = self.tableview:getContentOffset()
	local offsetmin = self.tableview:minContainerOffset();
	local offsetmax = self.tableview:maxContainerOffset();
	if self.direction == cc.SCROLLVIEW_DIRECTION_VERTICAL then
		local posY = offset.y - self.cellSize.height
		posY = math.ceil(posY/self.cellSize.height)*self.cellSize.height
		posY = GameUtilSenior.bound(offsetmin.y, posY, offsetmax.y)
		self.tableview:setContentOffsetInDuration({x=0, y=posY},0.1)
	else
		local posX = offset.x - self.cellSize.width
		posX = math.ceil(posX/self.cellSize.width)*self.cellSize.width
		posX = GameUtilSenior.bound(offsetmin.x, posX, offsetmax.x)
		self.tableview:setContentOffsetInDuration({x=posX, y=0},0.1)
	end
	return self
end

function GUITable:getCurIndex()
	return self._curIndex
end
--到达边缘调用函数
function GUITable:addBorderEventListener( cb )
	if type(cb) == "function" then
		self._borderListener = cb;
	end
end
function GUITable:getContentSize()
	return self.tableview:getViewSize()
end
function GUITable:setContentSize( size,y )
	if not y then
		self.tableview:setViewSize(size)
	else
		self.tableview:setViewSize(cc.size(size,y))
	end
	return self
end
function GUITable:getViewSize()
	return self.tableview:getViewSize()
end
function GUITable:setViewSize( size,y )
	if not y then
		self.tableview:setViewSize(size)
	else
		self.tableview:setViewSize(cc.size(size,y))
	end
	return self
end

-- function GUITable:setAnchorPoint(ap)
-- 	if ap.y >0 then
-- 		self.tableview:setPositionY(self.tableview:getPositionY()-ap.y*self:getContentSize().height)
-- 	end
-- 	if ap.x>0 then
-- 		self.tableview:setPositionX(self.tableview:getPositionX()-ap.x*self:getContentSize().width)
-- 	end
-- 	return self
-- end
function GUITable:bindData(data)
	if GameUtilSenior.isTable(data) then
		self._data = data
	end
	if not GameUtilSenior.isSame(data, self._data) then
		self:updateCellInView()
	end
end

function GUITable:updateCellInView()
	for i=1,self.listlen do
		local c = self.tableview:cellAtIndex(i-1)
		if c then
			local _widget = c:getChildByName("_widget")
			for j=1,self.celllen do
				local subItem = _widget:getChildByTag(j)
				if subItem then
					self._updateCellFunc(subItem)
				end
			end
		end
	end
end