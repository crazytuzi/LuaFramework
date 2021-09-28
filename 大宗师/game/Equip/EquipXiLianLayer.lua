
local data_equipen_equipen = require("data.data_equipen_equipen")
local data_item_nature = require("data.data_item_nature")
local data_baptize_baptize = require("data.data_baptize_baptize")
local data_item_item = require("data.data_item_item")

local baseStateStr = {"生命","攻击","物防","法防","最终伤害","最终免伤"} --这玩意可前台写死了，有事找后台和策划
local baseStateIDs = {21,22,23,24,77,78}

local EquipXiLianLayer = class("EquipXiLianLayer", function ( param )
    display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")
    display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")

    display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
    return require("utility.ShadeLayer").new()
end)

function EquipXiLianLayer:sendRes()

--    print("res id"..self.objId)
    RequestHelper.sendEquipXiLianPropRes({
        id = self.objId,
        callback = function(data)
            self.data = data
            dump(self.data)
            if data["7"] then
                self._rootnode["cost_stone"]:setString("x"..data["7"])

                self.top:setGodNum(data["6"])
                self.top:setSilver(data["5"])
            else
                self._rootnode["cost_stone"]:setString("x"..data["5"])
            end

            self:update(self.data,true)
        end
    })

end

function EquipXiLianLayer:sendWashRes(num)


    RequestHelper.sendEquipXiLianRes({
        t = self.type,
        n = num,
        id = self.objId,
        callback = function(data)
            dump(data)

            self.data = data
            if data ~= nil then
                if(data["0"] == "") then
                    self._rootnode["ti_huan_btn"]:setVisible(true)
                end
                self._rootnode["cost_stone"]:setString("x"..data["7"])
                self.top:setGodNum(data["6"])
                self.top:setSilver(data["5"])
                self:update(self.data)
            end

        end

    })

end

function EquipXiLianLayer:init()
end

function EquipXiLianLayer:createParticle()
    local par = CCParticleSystemQuad:create("Particle/equip_xilian.plist")
    par:setBlendAdditive(false)
    par:setScale(1.5)
    -- par:setPosition(self.stateBg:getContentSize().width*-0,self.stateBg:getContentSize().height*-0)
    -- self.stateBg:addChild(par)
    self._rootnode["left_info"]:addChild(par)


end



function EquipXiLianLayer:ctor( param )
    local boardZorder = 10
    local cardZorder = 12
    self:setNodeEventEnabled(true)

    self.removeListener = param.removeListener
    local list = param.listData
    local _id = param._id
    self.lvl = list[_id+1]["level"]
    self.star = list[_id+1]["star"] or 0
    self.serveID = list[_id+1]["resId"]
    --服务器传过来的ID 用来发洗炼请求
    self.objId = list[_id+1]["_id"]

--    print("self.objid"..self.objId)

    --<<增加上下的框.
    self.bottom = require("game.scenes.BottomLayer").new(true)
    self:addChild(self.bottom,1)

    self.top = require("game.scenes.TopLayer").new()
    self:addChild(self.top,1)
    -->

    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("equip/equip_xilian.ccbi", proxy, self._rootnode,self,CCSizeMake(display.width, display.height - self.bottom:getContentSize().height - self.top:getContentSize().height ))
    node:setAnchorPoint(ccp(0.5,0))
    node:setPosition(display.width/2,self.bottom:getContentSize().height)
    self:addChild(node)
    self._rootnode["tag_close"]:addHandleOfControlEvent(function()
        self:removeSelf()
    end, CCControlEventTouchDown)

    --道具名称
    local nameStr = data_item_item[self.serveID]["name"]
    self._rootnode["item_name"]:setString(nameStr)
    self._rootnode["item_name"]:setColor(NAME_COLOR[self.star])

    self._rootnode["lv_icon"]:setPosition(self._rootnode["item_name"]:getPositionX() + self._rootnode["item_name"]:getContentSize().width+20,self._rootnode["item_name"]:getPositionY())

    self._rootnode["item_lv"]:setString(self.lvl)
    self._rootnode["item_lv"]:setPosition(self._rootnode["lv_icon"]:getPositionX() + self._rootnode["lv_icon"]:getContentSize().width+20,self._rootnode["lv_icon"]:getPositionY())


    local itemImage = self._rootnode["image"]
    itemImage:setDisplayFrame(ResMgr.getLargeFrame(ResMgr.ITEM,self.serveID))
    self._rootnode["card_left"]:setDisplayFrame(display.newSprite("#item_card_bg_" .. self.star .. ".png"):getDisplayFrame())

    for i = 1,5 do
        if i > self.star then
            self._rootnode["star"..i]:setVisible(false)
        else
            self._rootnode["star"..i]:setVisible(true)
        end
    end

    self.type = 1
    local function chosePrice(index)
        self.type = index
    end

    local function touchTab(tag)
        for j = 1,3 do
            if j == tag then
                self._rootnode["tab"..j]:selected()
                chosePrice(j)
            else
                self._rootnode["tab"..j]:unselected()
            end
        end
    end

    for i = 1,3 do
        self._rootnode["tab"..i]:addNodeEventListener(cc.MENU_ITEM_CLICKED_EVENT, touchTab)
    end

    touchTab(1)


    local lowSizeWidth = self._rootnode["down_icon_bg"]:getContentSize().width
    local lowSizeHeight = self._rootnode["down_icon_bg"]:getContentSize().height
    local lowerBg = self._rootnode["down_icon_bg"]

    local coinY = lowSizeHeight*0.27
    local offsetY = lowSizeHeight*0.25
    local offsetX = lowSizeWidth*0.12


    for i =1,3 do
        local startX = self._rootnode["huafei"..i]:getPositionX()+ self._rootnode["huafei"..i]:getContentSize().width*1.2 --lowSizeWidth*-0.3
        local costArr = data_baptize_baptize[i]["arr_silver"]
        for j =1 ,#costArr do
            if costArr[j] ~= 0 then
                local iconName = ""
                if j == 1 then --银币
                    iconName = "#icon_silver.png"
                elseif j == 2 then --金币
                    iconName = "#icon_gold.png"
                elseif j == 3 then --洗炼石
                    iconName = "#icon_xilianshi.png"
                end
                local icon = display.newSprite(iconName)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(startX,self._rootnode["huafei"..i]:getPositionY())
                startX = startX + icon:getContentSize().width*1.2
                lowerBg:addChild(icon)

                local coinNum = ui.newTTFLabel({
                    text = costArr[j],
                    color = FONT_COLOR.BLOOD_RED
                })
                coinNum:setPosition(startX,self._rootnode["huafei"..i]:getPositionY())
                coinNum:setAnchorPoint(ccp(0,0.5))
                startX = startX + offsetX
                lowerBg:addChild(coinNum)
            end
        end

    end

    local xilianOne = function()
        self:sendWashRes(1)
    end

    local xilianTen = function()
        print("Xi lian X10")
        self:sendWashRes(10)
    end

    local tiHuanFunc = function()
        RequestHelper.sendTiHuanEquipRes({
            callback = function(data)
                dump(data)
                self:update(data,true)
            end,
            id = self.objId
        })
    end

    self._rootnode["xi_lian_btn"]:addHandleOfControlEvent(function()

    -- self:removeSelf()
    --是否够洗炼一次的？
        xilianOne()
    end, CCControlEventTouchDown)

    self._rootnode["xi_lian_10_btn"]:addHandleOfControlEvent(function()
    -- self:removeSelf()
    --是否够洗炼一次的
        xilianTen()
    end, CCControlEventTouchDown)

    self._rootnode["ti_huan_btn"]:setVisible(false)
    self._rootnode["ti_huan_btn"]:addHandleOfControlEvent(function()
    -- self:removeSelf()
        tiHuanFunc()
    end, CCControlEventTouchDown)



    self:sendRes()

end

function EquipXiLianLayer:update(data,isFirst)
    print("xilianxilianxilianxilianxilian")
    dump(data)
    -- if data["0"] == "not enough item" then
    --     -- local notEnoughTip =require("utility.NormalBanner").new({tipContext = "洗炼石不足"})
    --     show_tip_label("洗炼石不足")
    -- elseif data["0"] == "not enough silver" then
    --     -- local notEnoughTip =require("utility.NormalBanner").new({tipContext = "银币不足"})
    --     show_tip_label("银币不足")
    -- elseif data["0"] == "not enough gold" then
    --     -- local notEnoughTip =require("utility.NormalBanner").new({tipContext = "金币不足"})
    --     show_tip_label("元宝不足")

    -- else

        local costArr = data_baptize_baptize[self.type]["arr_silver"]
        local costSilver = 0
        local costGold = 0
        for i = 1,#costArr do

            if costArr[i] ~= 0 then
                if i == 1 then --银币
                    costSilver = costSilver + costArr[i]
                elseif i == 2 then --金币
                    costGold = costGold + costArr[i]
                elseif i == 3 then --洗炼石
                end
            end

        end

        game.player.m_gold = game.player.m_gold - costGold
        game.player.m_silver = game.player.m_silver - costSilver


        --
        if isFirst ~= true then
            self:createParticle()
            self._rootnode["tip_down"]:setVisible(true)
        else
            self._rootnode["tip_down"]:setVisible(false)
        end

        local stateNames = data["1"]

        --剩余洗炼石数量

--        self._rootnode["cost_stone"]:setString(data["5"])
    -- print("dfd")
    -- dump(data)

        for i =1,5 do
            if i > #stateNames then
                --隐藏
                self._rootnode["stateName"..i]:setVisible(false)
                self._rootnode["curNum"..i]:setVisible(false)
                self._rootnode["addNum"..i]:setVisible(false)
                self._rootnode["maxNum"..i]:setVisible(false)
                self._rootnode["kuo"..i]:setVisible(false)

            else
                --显示
                self._rootnode["stateName"..i]:setVisible(true)
                self._rootnode["curNum"..i]:setVisible(true)
                self._rootnode["addNum"..i]:setVisible(true)
                self._rootnode["maxNum"..i]:setVisible(true)
                self._rootnode["kuo"..i]:setVisible(true)

                self._rootnode["stateName"..i]:setString(data_item_nature[stateNames[i]]["nature"])
                local baseNum = data["2"][i]
                if baseNum == 0 then
                    self._rootnode["curNum"..i]:setVisible(false)
                else
                    self._rootnode["curNum"..i]:setString(baseNum)
                end


                local curXiLianNum = data["3"][i]
                local befFuHao = ""
                if curXiLianNum >= 0 then
                    befFuHao = "+"
                else
                    befFuHao = "-"
                end
                self._rootnode["addNum"..i]:setString("("..befFuHao..curXiLianNum)



                local aftXiLianNum = data["4"][i]
                local aftFuHao = ""
                local aftColor = FONT_COLOR.RED
                if aftXiLianNum >=0 then
                    aftFuHao = "+"
                    aftColor = FONT_COLOR.GREEN
                end

                if isFirst ~= true then
                    self._rootnode["maxNum"..i]:setString(aftFuHao..aftXiLianNum)
                else
                    --每个属性可洗炼的最大上限值=item表（arr_begin）对应的属性值*（1+该装备的强化等级/10），四舍五入
                    --另外，arr_begin的数组对应的6个属性，和后端发给你的6个洗练属性是对应的。
                    local curState = stateNames[i]
                    local totalState = data_item_item[self.serveID]["arr_xilian"]
                    local totalStateNum = data_item_item[self.serveID]["arr_beginning"]

                    local stateNum = 0
                    for i =1 ,#totalState do
                        if curState == totalState[i] then
                            stateNum = totalStateNum[i]
                            break
                        end
                    end

                    local finalNum = math.floor(stateNum * (1 + self.lvl/10))
                    self._rootnode["maxNum"..i]:setString("最大"..finalNum)
                end
            end
        end
    -- end
end

function EquipXiLianLayer:onExit(  )
    -- body
    if self.removeListener ~= nil then
        self.removeListener()
    end
    display.removeSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")

end

return EquipXiLianLayer