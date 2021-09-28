--

local data_jinjie_jinjie = require("data.data_jinjie_jinjie")

local HeroJinJie = class("HeroJinJie", function (param)
    return require("utility.ShadeLayer").new()
end)

local PRIVIEW_OP = "1"
local JINJIE_OP = "2"

function HeroJinJie:sendRes(param)
    RequestHelper.getJinJieRes({
        callback = function(data)
            self:init(data)
        end,
        id = param.id,
        op = param.op
    })
end

function HeroJinJie:updateListData(leftData)

    local cellData = self.list[self.index]
    cellData["cls"] = leftData["cls"]
    cellData["level"] = leftData["lv"]
    cellData["star"] = leftData["star"]

    self.cls = leftData["cls"]
    if self.resID == 1 or self.resID == 2 then
        --如果是男主角 或女主角 则更新阶级
        game.player.m_class = leftData["cls"]
    end

end

function HeroJinJie:removeCard(removeList)
    -- print("remove ")
    -- dump(removeList)
    -- print("befffffffff "..#HeroModel.totalTable)
    -- dump(HeroModel.totalTable[2])
    --如果不为空
    if removeList ~= nil then

        for i = 1,#removeList do
            dump(removeList[i])
             for k = 1,#HeroModel.totalTable do
                -- print("kk")
                -- print("HeroModel.totalTable[k][]"..HeroModel.totalTable[k]["id"])
                if HeroModel.totalTable[k]["id"] == removeList[i] then
                    table.remove(HeroModel.totalTable,k)
                    break
                end
             end
        end        
    end
    -- print("afffffffff "..#HeroModel.totalTable)   
end


function HeroJinJie:init(data)
    -- PostNotice(NoticeKey.REMOVE_TUTOLAYER)
    -- ResMgr.removeMaskLayer()
    self.data = data
    print("jinjiedatata ")
    dump(data)
    local removeList = data["8"]

    self:removeCard(removeList)


    local leftData = data["2"]
    local leftResID = leftData["resId"]
    local leftCls = leftData["cls"]
    self.cls = leftCls

    self.resID = leftResID
    local heroStaticData = ResMgr.getCardData(leftResID)
    local job = heroStaticData["job"]
    ResMgr.refreshJobIcon(self._rootnode["left_job_icon"],job)    
    ResMgr.refreshJobIcon(self._rootnode["right_job_icon"],job)   
    


    local leftNameStr = heroStaticData["name"]
    if leftResID == 1 or leftResID == 2 then
        leftNameStr = game.player.m_name
    end
    local leftStarsNum = leftData["star"]

    local leftLv = leftData["lv"]
    self.lv = leftLv
    local leftBase = leftData["base"]

    --更新列表上的数据，将来更新的话
    self:updateListData(leftData)

    -- table.insert(leftBase,1,leftLv)

    --<<--- 左边板子上的内容
    self._rootnode["image"]:setDisplayFrame(ResMgr.getHeroFrame(leftResID, leftCls))



    ResMgr.refreshCardBg({
        sprite = self._rootnode["card_left"],
        star = leftStarsNum ,
        resType = ResMgr.HERO_BG_UI
    })

    --星级
    local starNum = leftStarsNum or 0
    for i = 1,5 do
        local star = self._rootnode["star"..i]
        if i > starNum then
            star:setVisible(false)
        else
            star:setVisible(true)
        end
    end
    --名字
    self.leftHeroName:setString(leftNameStr)
    self.leftHeroName:setColor(NAME_COLOR[starNum])


    -- self.leftHeroCls:setPosition(self.leftHeroName:getPositionX()+self.leftHeroName:getContentSize().width,self.leftHeroName:getPositionY())
    if leftCls == 0 then
        self.leftHeroCls:setVisible(false)
    else
        self.leftHeroCls:setVisible(true)
        self.leftHeroCls:setString("+"..leftCls)
        self.leftHeroCls:setPosition(self.leftHeroName:getPositionX() + self.leftHeroName:getContentSize().width,self.leftHeroName:getPositionY())
    end

    self.leftHeroCls:setPosition(self.leftHeroName:getPositionX()+self.leftHeroName:getContentSize().width,self.leftHeroName:getPositionY())



    self._rootnode["lvl"]:setString(leftLv)

    for i = 1,4 do
        self._rootnode["baseState"..i]:setString(leftBase[i])
    end
    -->>---

    --<<---右边板子上的内容
    local isReachLimit = false

    -- self.resId = leftResID

    local rightData = data["3"]
    -- dump(data["3"])

    if  rightData.base == nil  then

        isReachLimit = true
        -- local tip = require("utility.NormalBanner").new({tipContext="已经达到进阶上限"})
        --        self.boardNode:addChild(tip,1000000)
        -- show_tip_label("已经达到进阶上限")
        ResMgr.showErr(200007)
        self._rootnode["right_info"]:setVisible(false)
        self._rootnode["card_right"]:setVisible(false)
        self._rootnode["arrow"]:setVisible(false)
        self._rootnode["jingLianBtn"]:setVisible(false)
        self.costNum = 0
        self._rootnode["scrow_node"]:removeAllChildren()
    else

        self._rootnode["right_info"]:setVisible(true)
        self._rootnode["card_right"]:setVisible(true)
        self._rootnode["arrow"]:setVisible(true)
        self._rootnode["jingLianBtn"]:setVisible(true)
        local rightResID = rightData["resId"]
        local rightCls = rightData["cls"]
        local rightIconNameRes = ResMgr.getCardData(rightResID)["arr_body"][rightCls+1]
        local rightIconPath = ResMgr.getLargeImage(rightIconNameRes,ResMgr.HERO)

        local rightNameStr = ResMgr.getCardData(rightResID)["name"]
        if rightResID == 1 or rightResID == 2 then
            rightNameStr = game.player.m_name
        end

        local rightStarsNum = rightData["star"] or leftStarsNum

        ResMgr.refreshCardBg({
            sprite = self._rootnode["card_right"],
            star = rightStarsNum ,
            resType = ResMgr.HERO_BG_UI
        })

        local rightLv = rightData["lv"]
        local rightBase = rightData["base"]

        self._rootnode["rightimage"]:setDisplayFrame(ResMgr.getHeroFrame(rightResID, rightCls))
        --星级
        local starNum = rightStarsNum or 0
        for i = 1,5 do
            local star = self._rootnode["rightstar"..i]
            if i > starNum then
                star:setVisible(false)
            else
                star:setVisible(true)
            end
        end
        --名字
        self.rightHeroName:setString(rightNameStr)
        
        self.rightHeroName:setColor(NAME_COLOR[starNum])

        -- self.leftHeroCls:setPosition(self.leftHeroName:getPositionX()+self.leftHeroName:getContentSize().width,self.leftHeroName:getPositionY())
        if rightCls == 0 then
            self.rightHeroCls:setVisible(false)
        else
            self.rightHeroCls:setVisible(true)
            self.rightHeroCls:setString("+"..rightCls)
        end


        self._rootnode["rightLv"]:setString(rightLv)

        self.rightHeroCls:setPosition(self.rightHeroName:getPositionX()+self.rightHeroName:getContentSize().width,self.rightHeroName:getPositionY())

        for i = 1,4 do
            self._rootnode["right_state_"..i]:setString(rightBase[i])
        end

        -->>---
        self.costNum = data["5"]
        -- 	--
        local itemData = data["4"]
        self.notEnough = true

        self.costData = itemData



        -- print("dadadad" )
        -- dump(data)
        for i = 1 ,#itemData do
            local itemsResId = itemData[i]["id"]
            local itemsHaveNum = itemData[i]["n2"]
            local itemsNeedNum = itemData[i]["n1"]
            local itemType     = itemData[i]["t"]

            if itemsNeedNum > itemsHaveNum  then
                -- needColor = FONT_COLOR.RED
                -- requireColor = FONT_COLOR.RED
                self.notEnough = false
            end


        end


        local function createfuncCell(idx)
            local item = require("game.Hero.JinJieCell").new()
            print("creerer")
            return item:create({
                id = idx,
                listData = itemData,
                viewSize = self._rootnode["scrow_node"]:getContentSize()
            })
        end

        local function refreshFunc(cell,idx)
            cell:refresh(idx + 1)
        end


        self._rootnode["scrow_node"]:removeAllChildren()

        local itemList = require("utility.TableViewExt").new({
            size        = self._rootnode["scrow_node"]:getContentSize(), 
            createFunc  = createfuncCell,
            refreshFunc = refreshFunc,
            cellNum     = #itemData,
            cellSize    = require("game.Hero.JinJieCell").new():getContentSize()

        })
        -- itemList:setScale(3)
        self._rootnode["scrow_node"]:addChild(itemList)
    end

    self._rootnode["cost_silver"]:setString(self.costNum)



    -- 无法进阶
    if(data["1"] == 0 and data["3"].base == nil) then
        self._rootnode["jingLianBtn"]:setVisible(false)
        self._rootnode["right_info"]:setVisible(false)
        self._rootnode["card_right"]:setVisible(false)
        self._rootnode["cost_silver"]:setVisible(false)

        -- show_tip_label("已经达到进阶上限")
    end


end

function HeroJinJie:onExit()
    TutoMgr.removeBtn("herojinjielayer_kaishijinjie_btn")
    TutoMgr.removeBtn("herojinjielayer_back_btn")
end

function HeroJinJie:onEnter()
    TutoMgr.addBtn("herojinjielayer_kaishijinjie_btn",self._rootnode["jingLianBtn"])
    TutoMgr.addBtn("herojinjielayer_back_btn",self._rootnode["backBtn"])
    TutoMgr.active()
    self._rootnode["jingLianBtn"]:setEnabled(true)
end


function HeroJinJie:ctor(param)
    ResMgr.createBefTutoMask(self)
    print("jinjinijinininiinin")

    local FROM_LIST = 1 --从列表界面中进入
    local FROM_FORMATION = 2 --从阵容界面中进入
    self.removeListener = param.removeListener
    self.incomeType = param.incomeType
    print("self.income"..self.incomeType)
    self:setNodeEventEnabled(true)

    --	if self.incomeType == FROM_LIST then
    local listInfo = param.listInfo
    self.objId = listInfo.id
    print("self.objId"..self.objId)
    self.updateTableFunc = listInfo.updateTableFunc
    self.list = listInfo.listData
    self.index = listInfo.cellIndex
    self.resetList = listInfo.resetList
    self.upNumFunc = listInfo.upNumFunc--function(num) self:setCurNum(num)end}
    --	end


    --<<增加上下的框
    -- self.bottom = require("game.scenes.BottomLayer").new(true)
    -- self:addChild(self.bottom,1)

    -- self.top = require("game.scenes.TopLayer").new()
    -- self:addChild(self.top,1)
    -->

    local proxy = CCBProxy:create()
    self._rootnode = {}
    local node = CCBuilderReaderLoad("hero/hero_jinjie.ccbi", proxy, self._rootnode)--,self)   --CCSizeMake(display.width, display.height - self.bottom:getContentSize().height - self.top:getContentSize().height )
    -- local node = CCBuilderReaderLoad("hero/hero_jinjie.ccbi", proxy, self._rootnode,self,CCSizeMake(display.width, display.height - self.bottom:getContentSize().height - 72 ))
    -- node:setAnchorPoint(ccp(0.5,0))
    node:setPosition(display.width/2,display.height/2) --self.bottom:getContentSize().height)
    self:addChild(node)

    local curHeight = node:getContentSize().height
    local orHeight = 633
    local scale = curHeight / orHeight

    -- self._rootnode["card_left"]:setScale(self._rootnode["card_left"]:getScale() * scale)
    -- self._rootnode["card_right"]:setScale(self._rootnode["card_right"]:getScale() * scale)

    self.leftHeroName = ui.newTTFLabelWithShadow({
        text = "侠客",
        font = FONTS_NAME.font_fzcy,
        x = self._rootnode["left_info"]:getContentSize().width*0.3,
        y = self._rootnode["left_info"]:getContentSize().height*0.85,
        size = 20,
        align = ui.TEXT_ALIGN_LEFT
    })
    self._rootnode["left_info"]:addChild(self.leftHeroName)

    self.leftHeroCls = ui.newTTFLabelWithShadow({
        text = "+0",
        x = self.leftHeroName:getPositionX()+self.leftHeroName:getContentSize().width,
        y = self.leftHeroName:getPositionY(),
        font = FONTS_NAME.font_fzcy,
        size = 20,
        align = ui.TEXT_ALIGN_LEFT,
        color = NAME_COLOR[2]
    })

    self.leftHeroCls:setPosition(self.leftHeroName:getPositionX()+self.leftHeroName:getContentSize().width,self.leftHeroName:getPositionY())
    
    self._rootnode["left_info"]:addChild(self.leftHeroCls)


    self.rightHeroName = ui.newTTFLabelWithShadow({
        text = "侠客",
        font = FONTS_NAME.font_fzcy,
        x = self._rootnode["right_info"]:getContentSize().width*0.3,
        y = self._rootnode["right_info"]:getContentSize().height*0.85,
        size = 20,
        align = ui.TEXT_ALIGN_LEFT
    })
    self._rootnode["right_info"]:addChild(self.rightHeroName)

    self.rightHeroCls = ui.newTTFLabelWithShadow({
        text = "+0",
        x = self.rightHeroName:getPositionX()+self.rightHeroName:getContentSize().width,
        y = self.rightHeroName:getPositionY(),
        font = FONTS_NAME.font_fzcy,
        size = 20,
        align = ui.TEXT_ALIGN_LEFT,
        color = NAME_COLOR[2]
    })
    self.rightHeroCls:setPosition(self.rightHeroName:getPositionX()+self.rightHeroName:getContentSize().width,self.rightHeroName:getPositionY())
    self._rootnode["right_info"]:addChild(self.rightHeroCls)

    -- self.objId = param.id
    self.curOp = PRIVIEW_OP
    -- self.updateTableFunc = param.updateTableFunc
    self:sendRes({id = self.objId,op = self.curOp })


    if self.first ==nil then

        self.first = true
        self._rootnode["backBtn"]:addHandleOfControlEvent(function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
            if self.removeListener ~= nil then
                self.removeListener()
            end
            PostNotice(NoticeKey.REMOVE_TUTOLAYER)

            self:removeSelf()
        end,
            CCControlEventTouchUpInside)
        self._rootnode["jingLianBtn"]:setEnabled(false)
        self._rootnode["jingLianBtn"]:addHandleOfControlEvent(function(eventName,sender)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 



            local jinjieIndex = 2
            if self.resID == 1 or self.resID == 2 then
                jinjieIndex = 1
            end 
            -- self.cls
            local clsIndex = self.cls + 1
            local jinjieData = data_jinjie_jinjie[clsIndex]

            local limitLv= jinjieData.level[jinjieIndex]

            if self.lv < limitLv then
                local str = ResMgr.getMsg(9) .. limitLv .. ResMgr.getMsg(10)
                show_tip_label(str)
            else

                local playerSilver = game.player:getSilver()

                if self.notEnough == false then
                    -- show_tip_label("材料不足")
                    ResMgr.showErr(200018)
                else
                    if self.costNum > playerSilver then
                        -- show_tip_label("银币不足")
                         ResMgr.showErr(100005)
                    else
                        ResMgr.createMaskLayer(display.getRunningScene())

                        self._rootnode["jingLianBtn"]:setEnabled(false)  
                        self._rootnode["backBtn"]:setEnabled(false)
            -- ResMgr.delayFunc(1,function()
            --     self._rootnode["jingLianBtn"]:setEnabled(true) 
            -- end,self) 

                        self.curOp = JINJIE_OP
                        RequestHelper.getJinJieRes({
                            callback = function(data)

                                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                                PostNotice(NoticeKey.LOCK_BOTTOM)

                                local function createEndLayer()
                                    ResMgr.removeMaskLayer()


                                    local finLayer = require("game.Hero.HeroJinJieEndLayer").new({data = self.data,removeListener = function()
                                            self._rootnode["jingLianBtn"]:setEnabled(true) 
                                            self._rootnode["backBtn"]:setEnabled(true)
                                            PostNotice(NoticeKey.UNLOCK_BOTTOM)
                                        end})
                                    display:getRunningScene():addChild(finLayer,9999)
                                    GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_xiakejingjie))

                                    if(data["1"] == 0 and data["3"].base == nil) then
                                        self._rootnode["jingLianBtn"]:setVisible(false)
                                        self._rootnode["right_info"]:setVisible(false)
                                        self._rootnode["card_right"]:setVisible(false)
                                        self:init(data)
                                    else
                                        self:init(data)
                                        --调用上一层的更新列表函数
                                        if self.resetList then
                                            self.resetList()
                                        end
                                    end
                                end

                                local startArma = ResMgr.createArma({resType = ResMgr.UI_EFFECT,armaName = "xiakejinjie_qishou",frameFunc = createEndLayer})
                                startArma:setPosition(display.width/2,display.height/2)
                                display:getRunningScene():addChild(startArma,9999)
                                -- print("xiake jinjie")
                                dump(data)
                                game.player.m_silver = game.player.m_silver - self.costNum
                                PostNotice(NoticeKey.CommonUpdate_Label_Silver)
                                -- self.top:setSilver(game.player.m_silver)

                                game.player.m_class = data["2"].cls 

                                -- 广播 侠客进阶成功 (进阶到5级以上)
                                if data["2"] ~= nil and data["2"].cls > 5 then
                                    local heroInfo = ResMgr.getCardData(data["2"].resId)
                                    Broad_heroLevelUpData.heroName = heroInfo.name
                                    Broad_heroLevelUpData.type = heroInfo.type
                                    Broad_heroLevelUpData.star = heroInfo.star[data["2"].cls + 1] 
                                    Broad_heroLevelUpData.class = data["2"].cls 

                                    game.broadcast:showHeroLevelUp()
                                end

                            end,
                            id = self.objId,
                            op = self.curOp
                        })
                    end

                end

            end 
            

        end, CCControlEventTouchUpInside)
    end
end





return HeroJinJie