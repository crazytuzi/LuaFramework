--[[盛典]]--
local rite = class("riteLayer",function() return cc.Layer:create() end)

function rite:ctor()

	local theIndex = 0
    for k,v in pairs(DATA_Activity.riteData.cellData) do
        if v["modelID"] == 4 then
            theIndex = theIndex + 1
        elseif v["modelID"] == 6 then
        	theIndex = theIndex + 1
        end
    end

	local closeBtn = function()
        removeFromParent(self)
    end
    local spriteName = {}
    self.select_layers = {}
	local bg = createSprite(self,"res/layers/activity/bg.png",g_scrCenter)
	createSprite(bg,"res/layers/activity/barBg.png",cc.p(508,454))
	DATA_Activity.riteLayer = self
	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(60.5, 38),
        cc.size(178,330),
        5
    )
	createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(246, 38),
        cc.size(710,330),
        5
    )


	self.bg = bg
    local bgsize = bg:getContentSize()
    local title = createLabel(bg,game.getStrByKey("week_list"),cc.p(bgsize.width/2,bgsize.height-46),cc.p(0.5,0.5),26,true,nil,nil,MColor.lable_yellow)
    createTouchItem(bg,"res/component/button/X.png",cc.p(bgsize.width-70,bgsize.height-72),closeBtn)    
    local data = copyTable(DATA_Activity.riteData)
    
    local posx,posy = 953,309
    local tab_control = {}
    local tempNum = tablenums(data.cellData)

    local menuFunc = function(tag)
		if self.select_index == tag then
			return
		end		
		self.select_index = tag
		if spriteName then
			for k,v in pairs(self.select_layers) do
				if tag == k then
				elseif self.select_layers[k] then
					removeFromParent(self.select_layers[k])
					self.select_layers[k] = nil
					if self.tab_control[k] then
						self.tab_control[k].menu_item:unselected()
					end
				end
			end
			if not self.select_layers[tag] then
				-- self.select_layers[tag] = layers[tag].new(bg,tag)
				-- bg:addChild(self.select_layers[tag],125)		
				local itemData = nil
			    if data["cellData"] then
			        itemData = data["cellData"][ self.select_index ]
			    else
			        return
			    end
			    if not itemData then return end			    			    
			    self.select_layers[tag] = itemData.callback()
			    if self.select_layers[tag] then
			        bg:addChild( self.select_layers[tag] )
			    end
			end

			spriteName[tag]:setColor(MColor.lable_yellow)
			if spriteName[self.tagColor] and tag ~= self.tagColor then
				spriteName[self.tagColor]:setColor(MColor.lable_black)
			end
			self.tagColor = tag	
			title:setString(data.cellData[tag].desc)	
		end
	end
    
	for i = 1, tempNum do
		tab_control[i] = {}
		tab_control[i].menu_item = cc.MenuItemImage:create("res/common/TabControl/1.png", "res/common/TabControl/2.png")
		tab_control[i].menu_item:setPosition(cc.p(posx,posy))
		tab_control[i].menu_item:setAnchorPoint(cc.p(0,0.5))
		if tempNum < 2 then
			tab_control[i].menu_item:setVisible(false)
		end
		spriteName[i] = Mnode.createLabel(
		{
			src = tostring(data.cellData[i].desc),
			color = MColor.lable_black,
			size = 22,
		})
		local item_size = tab_control[i].menu_item:getContentSize()
		tab_control[i].menu_item:addChild(spriteName[i])
		if true then
			spriteName[i]:setMaxLineWidth(item_size.width/2)
			spriteName[i]:setLineSpacing(-7)
			spriteName[i]:setPosition(item_size.width/2+5, item_size.height/2)
		else
			spriteName[i]:setPosition(item_size.width/2, item_size.height/2)
		end

		tab_control[i].callback = menuFunc
		posy = posy + 116
	end
	self.tab_control = tab_control
	creatTabControlMenu(bg,tab_control,theIndex,200)
	self.select_index = 0
	self.tagColor = 1
	menuFunc(theIndex)
	self.menuFunc = menuFunc
	self.spriteName = spriteName

    registerOutsideCloseFunc( bg , closeBtn)
    SwallowTouches(self)

    self:registerScriptHandler(function(event)
        if event == "enter" then
        elseif event == "exit" then 
        	if DATA_Activity.riteLayer then
        	    DATA_Activity.riteLayer = nil
        	end
        end
    end)
end

function rite:changePage(pageNum,isCur)
	if pageNum then
		local data = copyTable(DATA_Activity.riteData)
		for k,v in pairs(data.cellData) do
			if k ~= pageNum then
				self.tab_control[k].menu_item:setVisible(false)
				-- removeFromParent(self.tab_control[k].menu_item)
				-- self.tab_control[k].menu_item = nil
				-- self.tab_control[k] = nil
				-- removeFromParent(self.spriteName[k])
				-- self.spriteName[k] = nil
			end
		end
		if isCur then
			self.tab_control[pageNum].menu_item:selected()
			self.menuFunc(pageNum)
		end
	end
end

return rite