

local data_item_item = require("data.data_item_item")


local CollectLayer = class("CollectLayer", function ()
	return require("utility.ShadeLayer").new()
end)



function CollectLayer:ctor(itemId,itemType)
	local colType = itemType or ResMgr.HERO

	local trName = ""
	if colType == ResMgr.HERO then
		trName = "侠客"
	else
		trName = "装备"
	end


	local proxy = CCBProxy:create()
    self._rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_collect.ccbi", proxy, self._rootnode)
	
    node:setPosition(display.width/2,display.height/2)
    self:addChild(node)

    local closeBtn = self._rootnode["closeBtn"]
    closeBtn:addHandleOfControlEvent(function()
     	    self:removeSelf()
    end, CCControlEventTouchUpInside)

    local headIcon = display.newSprite()
    headIcon:setPosition(self._rootnode["head_node"]:getContentSize().width/2,self._rootnode["head_node"]:getContentSize().height/2)
    self._rootnode["head_node"]:addChild(headIcon)

    -- self._rootnode["titleLabel"]:setString(trName.."关卡掉落信息")

    ResMgr.refreshIcon({itemBg = headIcon, id = itemId, resType = colType})


    self.iconName = ui.newTTFLabelWithShadow({
        text = "啦啦啦",
        font = FONTS_NAME.font_haibao,
        size = 28,
        align = ui.TEXT_ALIGN_LEFT 
        })
    self._rootnode["name"]:addChild(self.iconName)

    self.starNum = data_item_item[itemId]["quality"]
    local nameStr = data_item_item[itemId]["name"]
    self.iconName:setString(nameStr)
    self.iconName:setColor(NAME_COLOR[self.starNum])

    local colMsg = ui.newTTFLabel({
		text = "集齐" .. data_item_item[itemId].overlay .. "个碎片可合成"..trName ,
		size = 24,
		color = ccc3(87,53,34),
		})
	colMsg:setAnchorPoint(ccp(0, 0.5))
	self._rootnode["desc"]:addChild(colMsg)
	local boardBg = self._rootnode["inner_bg"]


	self._curLevel = {}

	local function createList()
		self._rootnode["not_loot"]:setVisible(false)
		local function createFunc(idx)
    		local item = require("game.Hero.HeroCollectCell").new()
		    return item:create({
		        id       = idx,
		        viewSize = CCSizeMake(boardBg:getContentSize().width, boardBg:getContentSize().height*0.95),	        
		        listData = data_item_item[itemId].output,
		        lvlData = self.lvlData
		    })
		end

		local function refreshFunc(cell, idx)
		    cell:refresh(idx+1)
		end

		local itemList = require("utility.TableViewExt").new({
		    size        =   self._rootnode["inner_bg"]:getContentSize(), --CCSizeMake(boardBg:getContentSize().width, self.getCenterHeightWithSubTop()),-- numBg:getContentSize().height - 20),
		    direction   = kCCScrollViewDirectionVertical,
		    createFunc  = createFunc,
		    refreshFunc = refreshFunc,
		    cellNum     = #(data_item_item[itemId].output),
		    cellSize    = require("game.Hero.HeroCollectCell").new():getContentSize(),
		})

		self._rootnode["inner_bg"]:addChild(itemList)
	end

	local function createNothingFont()
		self._rootnode["not_loot"]:setVisible(true)
	end

	--在这个地方获取整个战斗数据
	RequestHelper.getLevelList({
        id = bigMapID,
        callback = function(data)           	
            if data["0"] == "" then
            	self.lvlData = data 
            	if data_item_item[itemId].output ~= nil and #(data_item_item[itemId].output) ~= 0 then
	                createList()
	            else
	            	createNothingFont()
	            end
            else

            end

        end
    	}) 

end


return CollectLayer