local transmitBoard = class("transmitBoard",require("src/TabViewLayer"))

function transmitBoard:ctor(parent,pageNum,datas)    
    self.parent = parent
    pageNum = pageNum - 1
    self.pageNum = pageNum
    self.playerLv = MRoleStruct:getAttr(ROLE_LEVEL)
    self.goMapId = 0
    self.mapX = 0
    self.mapY = 0
    self.lastTouch = {}

    local rightBg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(628, 38),
        cc.size(300, 501),
        4
    )

    local leftBg =  createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(32, 38),
        cc.size(590, 501),
        4
    )
    local rightMidBg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(637, 115),
        cc.size(282,375 ),
        4
    )
    local rightTitle = createScale9Sprite(self,"res/common/scalable/scale15.png",cc.p(777.5,515),cc.size(292,38))
    self.titleLab = createLabel(rightTitle,game.getStrByKey("great_drop_out"),cc.p(146,19),nil,20,true,nil,nil,MColor.yellow_gray)
    
    self:createDropIcon(nil,datas[pageNum][1].q_map_id)

    self.datas = datas

    if self.datas[pageNum] then
        local compare = function(a,b)
            if a.q_dtpx and b.q_dtpx then
                return a.q_dtpx < b.q_dtpx;
            elseif a.q_map_min_level==b.q_map_min_level then
                return a.q_map_id < b.q_map_id
            else
                return a.q_map_min_level<b.q_map_min_level
            end
        end
        table.sort(self.datas[pageNum],compare)
    end

    self.sel = {}
    self.selectIdx = 1
    self:createTableView(self , cc.size(590, 493 ),cc.p( 32, 41 ) , true )
    local btn1 = createMenuItem(self,"res/component/button/1.png",cc.p(704,79),function() self:go(1) end)
    createLabel(btn1,game.getStrByKey("find_path_go"),cc.p(69,29),nil,20,true,nil,nil,MColor.lable_yellow)
    self.btn1 = btn1
    local btn2 = createMenuItem(self,"res/component/button/1.png",cc.p(851,79),function() self:go(2) end)
    createLabel(btn2,game.getStrByKey("delivery_go"),cc.p(69,29),nil,20,true,nil,nil,MColor.lable_yellow)
    self.btn2 = btn2
end

function transmitBoard:showTip(temp)
    if self:isVisible() then
        local MpropOp = require "src/config/propOp"
        local protoId = temp
        local equipCanCompound = MpropOp.equipCanCompound(protoId)
        local actions = nil
        if equipCanCompound then
            actions = {}
            actions[#actions+1] = 
            {
                label = "合成",
                cb = function(act_params)
                    MequipCompound = require "src/layers/equipment/equipCompound"
                    local Manimation = require "src/young/animation"
                    Manimation:transit(
                    {
                        ref = getRunScene(),
                        node = MequipCompound.new({ protoId=protoId }),
                        --trend = "-",
                        zOrder = 200,
                        curve = "-",
                        swallow = true,
                    })
                end,
            }
        end
        
        local Mtips = require "src/layers/bag/tips"
        Mtips.new({ protoId = temp, actions = actions })
    end
end

function transmitBoard:createDropIcon(awards,mapID)
    if awards and #awards>0 then
        self.titleLab:setString(game.getStrByKey("great_drop_out"))
        local gNum = #awards
        self:createScroll(cc.size(285,367),cc.size(285,90*math.ceil(gNum/3)),cc.p(638,120))
        local posx,posy = 45,90*math.ceil(gNum/3)
        local Mprop = require( "src/layers/bag/prop" )
        if self.base_node then
            for i = 1, gNum do          
                -- local spr = createSprite(self.base_node,"res/common/bg/itemBg.png",cc.p(posx,posy-45))
                -- spr:setTag(i)

                local iconBtn = Mprop.new({
                    swallow = false ,
                    -- effect = true,
                    showBind =  awards[i].showBind,
                    isBind = awards[i].isBind ,
                    protoId = awards[i].id,                    
                  })
                iconBtn:setPosition(cc.p(posx,posy-45))
                self.base_node:addChild(iconBtn)
                local  listenner = cc.EventListenerTouchOneByOne:create()
                listenner:setSwallowTouches(false)
                listenner:registerScriptHandler(function(touch, event)
                    local pt = touch:getLocation()
                    local ptTemp = pt       
                    pt = iconBtn:getParent():convertToNodeSpace(pt)
                    if cc.rectContainsPoint(iconBtn:getBoundingBox(),pt) then
                        self.lastTouch[i] = iconBtn:getParent():convertToWorldSpace( ptTemp )     
                        return true
                    end
                    end,cc.Handler.EVENT_TOUCH_BEGAN )

                listenner:registerScriptHandler(function(touch,event)
                    local pt = touch:getLocation()
                    local theTouch = iconBtn:getParent():convertToWorldSpace( pt )
                    pt = iconBtn:getParent():convertToNodeSpace(pt)
                    if self.lastTouch and math.abs(self.lastTouch[i].x - theTouch.x) < 30 and math.abs(self.lastTouch[i].y - theTouch.y) < 30 then            
                        if cc.rectContainsPoint(iconBtn:getBoundingBox(),pt) then              
                            self:showTip(awards[i].id)
                        end
                    end
                end,cc.Handler.EVENT_TOUCH_ENDED)
                local eventDispatcher =  iconBtn:getEventDispatcher()
                eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, iconBtn)
                posx = posx + 95
                if i%3 == 0 then
                    posx = 45
                    posy = posy - 90
                end
            end
            self.scrollView:setContentOffset(cc.p(0,367-90*math.ceil(gNum/3)))
        end
    else
        local ds = getConfigItemByKey("MapInfo","q_map_id",mapID,"q_desinfo")   
        require("src/utf8")
        if ds then     
            local num = string.utf8len(ds)
            print(num/9,30*math.ceil(num/9))
            local off = math.max(30*math.ceil(num/12),367)
            self:createScroll(cc.size(285,367),cc.size(285,off),cc.p(638,120))
            self.titleLab:setString(game.getStrByKey("desc_text1"))
            if self.dsLab then
                removeFromParent(self.dsLab)
                self.dsLab = nil
            end        
            self.dsLab = createLabel(self.base_node,ds,cc.p(145,off-7),cc.p(0.5,1),22,true,nil,nil,MColor.lable_yellow,nil,280)
            self.scrollView:setContentOffset(cc.p(0,367-off))
            -- self.dsLab = require("src/RichText").new(self, cc.p(700,478), cc.size(220,367), cc.p(0, 1.0), 21, 19, MColor.black)
            -- self.dsLab:setAutoWidth()
            -- self.dsLab:addText(ds, MColor.lable_yellow,false)
            -- self.dsLab:format()
        end
    end
end

function transmitBoard:createScroll(size,nodeSize,pos,isneedSlide)
    if self.scrollView then
        self.base_node:removeAllChildren()
        self.base_node:setContentSize(nodeSize)
    else
        local scrollView = cc.ScrollView:create()
        if scrollView then
            scrollView:setViewSize(size)
            scrollView:setPosition(pos)
            scrollView:setScale(1)
            scrollView:ignoreAnchorPointForPosition(true)
            local node = cc.Node:create()
            self.base_node = node
            node:setContentSize(nodeSize)
            scrollView:setContainer(node)
            scrollView:updateInset()
            if isneedSlide then
                scrollView:addSlider("res/common/slider.png")
            end
            scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
            scrollView:setClippingToBounds(true)
            scrollView:setBounceable(true)
            scrollView:setDelegate()
            self:addChild(scrollView)
            self.scrollView = scrollView
        end
    end
end

function transmitBoard:go(way)
    if self.goMapId ~= 0 and self.mapX ~= 0 and self.mapY ~= 0 then
        if way == 1 then
            local tempData = { targetType = 4 , mapID =  self.goMapId ,  x = self.mapX  , y = self.mapY  }
            if __TASK then __TASK:findPath( tempData ) end
            __removeAllLayers()
        elseif way == 2 then
            local suiji = getConfigItemByKey("MapInfo","q_map_id",self.goMapId,"q_suiji")
            local shoewNeedData = { targetData = { mapID = self.goMapId , 
                                                   pos = { { x = self.mapX , y = self.mapY } } 
                                                 } ,  
                                    noTipShop = false ,
                                    q_done_event = 0 ,
                                    is_suiji = suiji,
                                  }
                               
            if __TASK:portalGo( shoewNeedData ) then
                __removeAllLayers(true)   
                DATA_Mission:setAutoPath(false)
                DATA_Mission.isStopFind = true  
                if G_MAINSCENE and G_MAINSCENE.map_layer then
                    G_MAINSCENE.map_layer:resetHangup()
                    if self.goMapId == G_MAINSCENE.map_layer.mapID then
                        __removeAllLayers()
                    end
                end
                return 
            end
        end
    end
end

function transmitBoard:checkInfo(mapid)    
    if self.parent and self.parent.tp and self.parent.tp[mapid] and self.parent.tp[mapid].x then
        local job = MRoleStruct:getAttr(ROLE_SCHOOL)
        local sex = MRoleStruct:getAttr(PLAYER_SEX) 
        local dropSetTab = {
            {7,8,9},
            {4,5,6}
        }
        local awards = {}
        local DropOp = require("src/config/DropAwardOp")
        local q_dropinfo = getConfigItemByKey("MapInfo","q_map_id",mapid,"q_dropinfo")
        local awardsConfig = DropOp:dropItem_ex(q_dropinfo)
        if awardsConfig and tablenums(awardsConfig) >0 then        
            local MpropOp = require "src/config/propOp"
            local num = 1
            for i=1, #awardsConfig do                
                -- if (math.floor(awardsConfig[i]["q_item"]/10000)%100) == job or (awardsConfig[i]["q_item"]/10000)%100 == 0 then
                if math.floor(awardsConfig[i]["q_group"]/100) == dropSetTab[sex][job] or awardsConfig[i]["q_group"] < 400 then    
                    awards[num] =
                    { 
                        id = awardsConfig[i]["q_item"] ,       -- 奖励ID
                        num = awardsConfig[i]["q_count"]   ,    -- 奖励个数
                        streng = awardsConfig[i]["q_strength"] ,   -- 强化等级
                        quality = awardsConfig[i]["q_quality"] ,   -- 品质等级
                        upStar = awardsConfig[i]["q_star"] ,     -- 升星等级
                        time = awardsConfig[i]["q_time"] ,     -- 限时时间
                        showBind = true,
                        isBind = tonumber(awardsConfig[i]["bdlx"] or 0) == 1,    
                        seq = MpropOp.quality(awardsConfig[i]["q_item"]),
                    }
                    num = num + 1
                end
            end
            table.sort(awards,function(a,b) return a.seq > b.seq end)                        
        end
        local x,y = self.parent.tp[mapid].x,self.parent.tp[mapid].y
        self.goMapId = mapid
        self.mapX = x
        self.mapY = y
        self:createDropIcon(awards,mapid) 
    end
end

function transmitBoard:tableCellTouched(table,cell)
    local data = self.datas[self.pageNum]
    local idx = cell:getIdx()+1
    local touchX,touchY = cell:getX(),cell:getY()
    for i=1,#data do
        local button = tolua.cast(cell:getChildByTag(i),"cc.Sprite")
        if button then
            local mapData = data[i] 
            -- local oldPath = cell:getChildByTag(i)
            if cc.rectContainsPoint(button:getBoundingBox(),cc.p(touchX,touchY)) and self:isVisible() then
                if self.playerLv < mapData.q_map_min_level then
                    self.btn1:setEnabled(false)
                    self.btn2:setEnabled(false)
                else
                    self.btn1:setEnabled(true)
                    self.btn2:setEnabled(true)
                end
                AudioEnginer.playTouchPointEffect()
                self:checkInfo(mapData.q_map_id)  
                self.sel[self.selectIdx]:setVisible(false)
                self.sel[i]:setVisible(true)
                self.selectIdx = i              
            end
        end
    end
end

function transmitBoard:cellSizeForTable(table,idx)
    return 132 ,572
end

function transmitBoard:numberOfCellsInTableView(table)
    return math.ceil(#self.datas[self.pageNum]/2)
end

function transmitBoard:tableCellAtIndex(tableView,idx)
    local data = self.datas[self.pageNum]
    local cell = tableView:dequeueCell()
    if cell == nil then
        cell = cc.TableViewCell:new()        
    else
        cell:removeAllChildren()
    end
    local posx,posy = 148,65
    for i=1+idx*2,(1+idx)*2 do
        if data[i] then
            local bottonPic = createSprite(cell,"res/common/table/cell33.png",cc.p(posx,posy))
            local bottonPicSize = bottonPic:getContentSize()
            bottonPic:setTag(i)
            createSprite(bottonPic,"res/mapui/mapName/"..data[i].q_map_id..".jpg",cc.p(bottonPicSize.width/2,bottonPicSize.height/2))            
            if self.playerLv and data[i].q_map_min_level and self.playerLv < data[i].q_map_min_level then
                createSprite(bottonPic,"res/common/table/cell33_cover.png",cc.p(bottonPicSize.width/2,bottonPicSize.height/2))
                createLabel(bottonPic,string.format(game.getStrByKey("level_open1"),data[i].q_map_min_level),cc.p(bottonPicSize.width-15,bottonPicSize.height-20),cc.p(1,0.5),20,true,nil,nil,MColor.red)
            end
            createSprite(bottonPic,"res/mapui/mapName/mapNameBg.png",cc.p(bottonPicSize.width/2,23))
            createLabel(bottonPic,data[i].q_map_name,cc.p(bottonPicSize.width/2,23),nil,20,true,nil,nil,MColor.lable_yellow)            
            posx = posx + 292
            self.sel[i] = createSprite(bottonPic,"res/common/table/cell33_sel.png",cc.p(bottonPicSize.width/2,bottonPicSize.height/2))
            if i ~= self.selectIdx then
                self.sel[i]:setVisible(false)
            else
                self:checkInfo(data[i].q_map_id) 
            end
        end
    end
    return cell
end



return transmitBoard