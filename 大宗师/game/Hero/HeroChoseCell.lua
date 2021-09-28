


local HeroChoseCell = class("HeroChoseCell", function ()	
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
    display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
    display.addSpriteFramesWithFile("ui/ui_kongfu.plist", "ui/ui_kongfu.png")
	return CCTableViewCell:new() 
end)

local baseStateStr = {"生命","攻击","物防","法防","最终伤害","最终免伤"}

function HeroChoseCell:create(param)
    self.choseFunc = param.choseFunc
    self.choseTable = param.choseTable
    -- self.choseResId = param.choseResId
	
	self.list = param.list

    local viewSize = param.viewSize


	self.cellIndex = param.id or 1

	local proxy = CCBProxy:create()
    self._rootnode = {}

    local node = CCBuilderReaderLoad("hero/hero_qianghua_chose_cell.ccbi", proxy, self._rootnode)
    node:setPosition(viewSize.width * 0.5, self._rootnode["itemBg"]:getContentSize().height / 2)
    self:addChild(node)

    -- self.headIcon = self._rootnode["headIcon"]

    -- self.headIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)  
    --         if event.name == "began" then
    --         	self.createKongfuInfoLayer(self.cellIndex)
    --         return true   
    --         end
    --     end)
    -- self.headIcon:setTouchEnabled(true)

    -- self.lvNum = self._rootnode["lvNum"]

    -- self.tabSprite = self._rootnode["tabIcon"]

    -- self.kongfuName = self._rootnode["kongfuName"]

    -- self.starNum = self._rootnode["starNumSprite"]

    -- self.expNum = self._rootnode["expNum"]
    -- self.expNum:setString(0)

    self._rootnode["selIcon"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function(tag)
        self._rootnode["selIcon"]:setVisible(false)
        self._rootnode["unSelIcon"]:setVisible(true)
        self.data["isChosen"] = false
        print("unSel")

        self.choseFunc({op = 2,cellIndex = self.cellIndex})

    end,
    CCControlEventTouchUpInside)

    self._rootnode["unSelIcon"]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, function(tag)
        
        if self.choseFunc({op = 1,cellIndex = self.cellIndex}) then
            self._rootnode["unSelIcon"]:setVisible(false)
            self._rootnode["selIcon"]:setVisible(true)
            self.data["isChosen"] = true
            print("sel")
            --增加       
        end
       
    end,
    CCControlEventTouchUpInside)

    self.headIcon = self._rootnode["headIcon"]

    self.heroName = ui.newTTFLabelWithShadow({
        text = "",
        font = FONTS_NAME.font_haibao,
--        x = self._rootnode["tag_lv_bg"]:getContentSize().width/2 + self.headIcon:getContentSize().width + 20,
--        y = self:getContentSize().height*0.62,
        size = 30,
        align = ui.TEXT_ALIGN_LEFT 
        })
    self._rootnode["itemNameLabel"]:addChild(self.heroName)

    self:refresh(self.cellIndex)

    return self
end

function HeroChoseCell:changeStarNum(num)
	self.starNum:setDisplayFrame(display.newSpriteFrame(string.format("item_board_num_%d.png", num)))
	
end

function HeroChoseCell:beTouched()
	print(self.cellIndex)
	
end

function HeroChoseCell:refresh(idx)
	-- local NEI_GONG_TYPE = 5
	-- local WAI_GONG_TYPE = 6

	self.cellIndex = idx

	local data = self.list[idx]
    print("dump")
    -- dump(data)

    self.data = self.list[idx]
	
    self.objectId = data["_id"]
	local resId = data["resId"]
	local cls = data["cls"]
    local lv = data["level"]

    
    self._rootnode["lvLabel"]:setString(string.format("LV.%d", lv))

    if cls > 0 then
        self._rootnode["clsLabel"]:setString(string.format("+%d", cls))
    else
        self._rootnode["clsLabel"]:setString("")
    end
	local star = data["star"]
    self.heroName:setColor(NAME_COLOR[star])
	local name = ResMgr.getCardData(resId)["name"]

    

    self.heroName:setString(name)
    self.heroName:setPosition(self.heroName:getContentSize().width / 2, 0)

    self.curExp  = ResMgr.getCardData(resId)["exp"]
    self._rootnode["expNum"]:setString(self.curExp)

    for i = 1,5 do
        if i > star then
            self._rootnode["star"..i]:setVisible(false)
        else
            self._rootnode["star"..i]:setVisible(true)
        end
    end 
    
    local isChosen = self.data["isChosen"]

    if isChosen == true then
        self._rootnode["unSelIcon"]:setVisible(false)
        self._rootnode["selIcon"]:setVisible(true)
    else
        self.data["isChosen"] = false
        self._rootnode["selIcon"]:setVisible(false)
        self._rootnode["unSelIcon"]:setVisible(true)
    end

	-- 


	-- self:changeStarNum(star)
	-- self.kongfuName:setString(name)

	-- -- local cellIconPath = ResMgr.getIconImage(data_item_item[resId]["icon"],ResMgr.EQUIP)
	
	-- -- local cellSprite = display.newSprite(cellIconPath)

	-- -- self.headIcon:setDisplayFrame(cellSprite:getDisplayFrame())
    ResMgr.refreshIcon({itemBg = self.headIcon,id = resId,resType = ResMgr.HERO,cls = cls})
	
    --是什么职业
        local job = ResMgr.getCardData(resId)["job"]
        ResMgr.refreshJobIcon(self._rootnode["job_icon"],job)   
        self._rootnode["job_icon"]:setZOrder(100)
	-- -- self.headIcon:setPosition(self.headIcon:getContentSize().width/2,self.headIcon:getContentSize().height/2)





end

function HeroChoseCell:getContentSize()
	 return CCSizeMake(display.width * 0.93, 154)

end

function HeroChoseCell:onExit()
	-- display.removeSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
end

function HeroChoseCell:runEnterAnim(  )
	local delayTime = self.cellIndex*0.15
    local sequence = transition.sequence({
        CCCallFuncN:create(function ( )
            self:setPosition(CCPoint((self:getContentSize().width/2 + display.width/2),self:getPositionY()))
        end),
        CCDelayTime:create(delayTime),CCMoveBy:create(0.3, CCPoint(-(self:getContentSize().width/2 + display.width/2), 0))})
    self:runAction(sequence)
end



return HeroChoseCell



