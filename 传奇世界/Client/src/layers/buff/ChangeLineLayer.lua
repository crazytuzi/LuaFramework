local ChangeLineLayer = class("ChangeLineLayer",function() return cc.Layer:create() end )

function ChangeLineLayer:ctor()
	local func = function(tag)
		if tag ~= self.select_index then
			g_msgHandlerInst:sendNetDataByTable(FRAME_CS_SWITCHLINE, "FrameSwitchLineProtocol", {line=tag})
		end
		removeFromParent(self)
    end
    local menus = {}
    local temp_line = MRoleStruct:getAttr(PLAYER_LINE)
    if temp_line then
    	self.start_posy = 250
    	local qu =  math.floor(temp_line/10000)
	   	temp_line = temp_line - qu*10000
	   	local cur_qu = temp_line/1000
    	local total_line = math.floor(temp_line/100)
	    for i=1,total_line do
	    	menus[i] = {""..i.." "..game.getStrByKey("line"),i,func}
	    end
	   	self.column = 4--math.ceil(#menus/6)
	   	self.ceil_x = 130
	   	self.font_size = 20
	   	--self.res = "res/component/button/51"
	   	self.select_index = temp_line - total_line*100
	   	menus[self.select_index][4] = true
		self.row = math.ceil(#menus/self.column)
		self.size = cc.size(480,320)--cc.size(self.ceil_x*self.column,self.row*65+50)
		self.bg = createScale9Sprite(self,"res/common/scalable/6.png",cc.p(display.cx,display.cy),self.size,cc.p(0.0,1.0))
	    if qu >= 1 then
    		self:addQuMenus(qu)
    	end
	    self:addMenus(menus)
	    if G_MAINSCENE then 
			G_MAINSCENE:addChild(self,254)
		end
		self.bg:setScale(0.01)
	    self.bg:runAction(cc.ScaleTo:create(0.15, 1))
	    self:setPosition(cc.p(-260,222))
	    registerOutsideCloseFunc( self.bg , function() removeFromParent(self) end,true )
	    local cur_str = ""
	    if qu >= 1 and qu <= 3 then
	    	cur_str = game.getStrByKey("cur_line")..self:getMapName(qu)..self.select_index..game.getStrByKey("line")
	    else
	    	cur_str = game.getStrByKey("cur_line")..self.select_index..game.getStrByKey("line")
	    end
	    createLabel(self.bg,cur_str,cc.p(30, 285), cc.p(0,0.5), self.font_size,true)
	 end

end

function ChangeLineLayer:addQuMenus(qu_num)
	self.start_posy = 200
	local posx,posy = 90,235
	local line = createSprite(self.bg,"res/common/bg/bg2-1.png",cc.p(240,260),cc.p(0.5,0.0))
	line:setScale(1.32,1)
	
	for i=1,3 do
		local func = function()
			g_msgHandlerInst:sendNetDataByTable(FRAME_CS_SWITCHLINE, "FrameSwitchLineProtocol", {line=i})
			removeFromParent(self)
	    end
		local item = createMenuItem(self.bg,"res/component/button/60_sel.png",cc.p(posx,posy),func)
		local item_size = item:getContentSize()
		createLabel(item,self:getMapName(i),cc.p(item_size.width/2, item_size.height/2), nil, self.font_size,true)
		posx = posx + 150
	end
end

function ChangeLineLayer:addMenus(params)
	local temp = #params
	local scrollView = cc.ScrollView:create()
	local sizeY = 200+65*(math.floor((temp-13)/4)+1)
	local line = createSprite(self.bg,"res/common/bg/bg2-1.png",cc.p(240,self.start_posy-5),cc.p(0.5,0.0))
	line:setScale(1.32,1)
    if nil ~= scrollView then
        scrollView:setViewSize(cc.size(480,210))
        scrollView:setPosition(cc.p(0,self.start_posy-5))
        scrollView:setScale(1.0)
 		scrollView:setAnchorPoint(cc.p(0.0, 1.0))
    	scrollView:ignoreAnchorPointForPosition(false)
        local node = cc.Node:create()
        self.node = node
        scrollView:setContainer(node)
     
        scrollView:setContentSize(cc.size(480,sizeY))

        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
        --scrollView:setClippingToBounds(true)
        scrollView:setBounceable(true)
        self.bg:addChild(scrollView)
        self.scrollView = scrollView
    end

	self.font_size = self.font_size or 20
	self.res = self.res or "res/component/button/60"
	local posx,posy = self.ceil_x/2+15*(self.column-1),170+65*(math.floor((temp-13)/4)+1)
	for i=1,temp do 
		local func = function() 
			if params[i][3] then
			 	params[i][3](params[i][2])
			end
		end
		local item
		if params[i][4] == true then
			item = createMenuItem(self.node,self.res.."_sel.png",cc.p(posx,posy),func)
		else
			item = createMenuItem(self.node,self.res..".png",cc.p(posx,posy),func)
		end
		local item_size = item:getContentSize()
		local label_item = createLabel(item,params[i][1],cc.p(item_size.width/2, item_size.height/2), nil, self.font_size,true)
		if label_item and params[i][4] == true then
			label_item:setColor(MColor.green)
		end
		if i%self.column == 0 then
			posy = posy - 65
			posx =  self.ceil_x/2+15*(self.column-1)
		else 
			posx = posx + item_size.width + 10
		end
	end
	scrollView:setContentOffset(cc.p(0,210-sizeY))
end

function ChangeLineLayer:getMapName(qu_num,mapid)
	local map_strs = {"落霞岛","夕霞岛","桃花岛"}
	local map_name = nil
	local map_id = mapid or G_MAINSCENE.mapId
	if (not qu_num) and G_MAINSCENE.map_layer and (not G_MAINSCENE.map_layer:isHideMode())  then
		local temp_line = MRoleStruct:getAttr(PLAYER_LINE)
	    if temp_line then
	    	qu_num =  math.floor(temp_line/10000)
		end
	end
	if qu_num and qu_num >= 1 and  map_strs[qu_num] then
		map_name = map_strs[qu_num]
	end
	if (not map_name) then
		map_name = ""
		if G_MAINSCENE then
			map_name = getConfigItemByKey("MapInfo","q_map_id",map_id,"q_map_name")
		end
	end
	return map_name 
end 


return ChangeLineLayer 