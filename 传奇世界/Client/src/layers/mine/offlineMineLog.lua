local offlineMineLog = class("offlineMineLog",function() return cc.Layer:create() end )

function offlineMineLog:ctor(params)
	local bg = createSprite(self,"res/common/bg/bg52.png",g_scrCenter)
    local bgWidth,bgHeight = bg:getContentSize().width,bg:getContentSize().height

    createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(bgWidth/2,bgHeight/2 + 22),
        cc.size(443, 204),
        4,
        cc.p(0.5,0.5)
    )

    createSprite(bg,"res/common/bg/bg52-2.png",cc.p(bgWidth/2,bgHeight - 27))
    local box = {"boxCan1","unpassed_box1","boxUnable1"}
    self.boxNum = {0,0,0}
    self.bg = bg  
    self.data = {}
    self.tabId = {}
    self.lab = {}
    self.kaiguan = true
    self.kaiguan1 = true
    createLabel(bg,game.getStrByKey("offlineMine_show"),cc.p(bgWidth/2,bgHeight - 27),cc.p(0.5,0.5),22,true,nil,nil,MColor.label_yellow)
    createLabel(bg,game.getStrByKey("offlineMine_start"),cc.p(35,272),cc.p(0,0.5),22,true,nil,nil,MColor.lable_black)
    createLabel(bg,game.getStrByKey("offlineMine_prompt"),cc.p(35,232),cc.p(0,0.5),22,true,nil,nil,MColor.lable_black)
    createLabel(bg,game.getStrByKey("offlineMine_get"),cc.p(35,192),cc.p(0,0.5),22,true,nil,nil,MColor.lable_black)
    createLabel(bg,game.getStrByKey("offlineMine_get1"),cc.p(35,107),cc.p(0,0.5),22,true,nil,nil,MColor.lable_black)
    local callFun = function()
        if G_ROLE_MAIN then
            self:showAwards()
        else            
            removeFromParent(self)
        end
    end
    local btn = createTouchItem(bg,"res/component/button/2.png",cc.p(bgWidth/2, 49),callFun)
    createLabel(btn,game.getStrByKey("get_awards"),cc.p(btn:getContentSize().width/2, btn:getContentSize().height/2),cc.p(0.5,0.5),22,true,nil,nil,MColor.label_yellow)
    if params then
        local dates = os.date("*t",params.start)
        local dateStr = string.format(game.getStrByKey("date_format1"),dates.year,dates.month,dates.day,dates.hour,dates.min)                    
        createLabel(bg,dateStr,cc.p(180,272),cc.p(0,0.5),22,true,nil,nil,MColor.lable_black)
        local timeStr = string.format("%02d", math.floor(params.offTime/3600))..game.getStrByKey("hour")..string.format("%02d", (math.floor(params.offTime/60)%60))..game.getStrByKey("min")..string.format("%02d", (params.offTime%60))..game.getStrByKey("sec")
        createLabel(bg,timeStr,cc.p(180,232),cc.p(0,0.5),22,true,nil,nil,MColor.lable_black)
        local posx = 160
        if params.awardTab and #params.awardTab then
            for i = 1 ,#params.awardTab do
                if self.boxNum[params.awardTab[i].boxType] == 0 then            
                    createSprite(bg,"res/fb/defense/"..box[params.awardTab[i].boxType]..".png",cc.p(posx,182))
                    -- self.lab[params.awardTab[i].boxType] = createLabel(bg,"X"..tostring(self.boxNum[params.awardTab[i].boxType]),cc.p(posx+43,152),cc.p(0,0),20,true,nil,nil,MColor.white)
                    self.lab[params.awardTab[i].boxType] = Mnode.createLabel(
                    {
                        parent = bg,
                        src = "X"..tostring(self.boxNum[params.awardTab[i].boxType]),
                        size = 20,
                        color = MColor.white,
                        anchor = cc.p(0, 0),
                        pos = cc.p(posx+43,152),
                        zOrder = 20,
                        outline = false,
                    })
                    self.lab[params.awardTab[i].boxType]:enableOutline(cc.c4b(0,0,0,255),2)
                    posx = posx + 110                    
                end
                self.boxNum[params.awardTab[i].boxType] = self.boxNum[params.awardTab[i].boxType] + 1               
                if self.lab[params.awardTab[i].boxType] then
                    self.lab[params.awardTab[i].boxType]:setString("X"..tostring(self.boxNum[params.awardTab[i].boxType]))
                end
            end
        end
        self.data = params.awardTab
        createLabel(bg,params.exp,cc.p(150,107),cc.p(0,0.5),22,true,nil,nil,MColor.yellow)
    end
    SwallowTouches(bg)
end

function offlineMineLog:showAwards()
    AudioEnginer.playEffect("sounds/uiMusic/ui_treasure.mp3", false)
    local tabId = {}
    for k=1,#self.data do
        if self.data[k].itemID and self.data[k].num then
            local inTab = function()
                local tabTemp = {}
                tabTemp.id = self.data[k].itemID
                tabTemp.num = self.data[k].num
                tabTemp.q_default = getConfigItemByKey("propCfg","q_id",self.data[k].itemID,"q_default") or 1
                table.insert(tabId,tabTemp)
            end
            if #tabId > 0 then
                for i=1,#tabId do
                    if tabId[i].id == self.data[k].itemID then
                        tabId[i].num = tabId[i].num+self.data[k].num
                        break
                    end
                    if i == #tabId then
                        inTab()
                    end
                end
            else
                inTab()
            end
        end
    end
    table.sort(tabId, function(a , b ) return a.q_default > b.q_default  end)
    self.tabId = tabId
    self.number = #self.tabId
    local masking = cc.LayerColor:create(cc.c4b(0, 0, 0, 255*0.8))
    SwallowTouches(masking)
    self:addChild(masking)
    local smallBg = CreateSettleFrame(masking, cc.p(display.cx, display.cy + 50), 196, cc.p(0.5, 0.5))
    createSprite(masking, "res/common/shadow/award_title.png" , cc.p(masking:getContentSize().width/2 , display.cy + 104 ) , cc.p( 0.5 , 0 ) )
    self.masking = masking
    self.smallBg = smallBg
    performWithDelay(self.smallBg,function() self:showAtLast() end,0.0)
end

function offlineMineLog:showAtLast()
    self:createItemAction()
    createLabel(self, game.getStrByKey("offlineMine_auto_melting_sub_title_0"), cc.p(display.cx, display.cy + 67), nil, 18, nil, nil, nil, MColor.lable_black)
    createLabel(self, game.getStrByKey("offlineMine_auto_melting_sub_title_1"), cc.p(display.cx, display.cy - 103), nil, 18, nil, nil, nil, MColor.lable_black)
    local json = require("json")
    if getLocalRecordByKey(2, "auto_smelter_check_user_preference") == "" then
        setLocalRecordByKey(2, "auto_smelter_check_user_preference", json.encode({
            white = false
            , green = false
            , blue = false
            , purple = false
            , orange = false
        }))
    end
    local clickFunc = function(sender)
        sender:setTexture(sender:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1.png") and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png")
        setLocalRecordByKey(2, "auto_smelter_check_user_preference", json.encode({
            white = self.check_box_white:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , green = self.check_box_green:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , blue = self.check_box_blue:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , purple = self.check_box_purple:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
            , orange = self.check_box_orange:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png")
        }))
    end
    local checkBox_user_prefrence = json.decode(getLocalRecordByKey(2, "auto_smelter_check_user_preference"))
    local posX_checkBoxStart = display.cx - 273
    local posX_labelStart = display.cx - 238
    local posY_base = display.cy - 71
    local distance_between_check_box = 121
    self.check_box_white = createTouchItem(self, checkBox_user_prefrence.white and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png", cc.p(posX_checkBoxStart, posY_base), clickFunc)
    self.check_box_white:setAnchorPoint(cc.p(0, .5))
    local label_checkBox_white = createLabel(self, game.getStrByKey("set_auto_white"), cc.p(posX_labelStart, posY_base), cc.p(0, .5), 22, nil, nil, nil, MColor.drop_white)
    GetUIHelper():AddTouchEventListener(true, label_checkBox_white, nil, function() clickFunc(self.check_box_white) end)
    self.check_box_green = createTouchItem(self, checkBox_user_prefrence.green and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png", cc.p(posX_checkBoxStart + distance_between_check_box, posY_base), clickFunc)
    self.check_box_green:setAnchorPoint(cc.p(0, .5))
    local label_checkBox_green = createLabel(self, game.getStrByKey("set_auto_green"), cc.p(posX_labelStart + distance_between_check_box, posY_base), cc.p(0, .5), 22, nil, nil, nil, MColor.green)
    GetUIHelper():AddTouchEventListener(true, label_checkBox_green, nil, function() clickFunc(self.check_box_green) end)
    self.check_box_blue = createTouchItem(self, checkBox_user_prefrence.blue and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png", cc.p(posX_checkBoxStart + distance_between_check_box * 2, posY_base), clickFunc)
    self.check_box_blue:setAnchorPoint(cc.p(0, .5))
    local label_checkBox_blue = createLabel(self, game.getStrByKey("set_auto_blue"), cc.p(posX_labelStart + distance_between_check_box * 2, posY_base), cc.p(0, .5), 22, nil, nil, nil, MColor.blue)
    GetUIHelper():AddTouchEventListener(true, label_checkBox_blue, nil, function() clickFunc(self.check_box_blue) end)
    self.check_box_purple = createTouchItem(self, checkBox_user_prefrence.purple and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png", cc.p(posX_checkBoxStart + distance_between_check_box * 3, posY_base), clickFunc)
    self.check_box_purple:setAnchorPoint(cc.p(0, .5))
    local label_checkBox_purple = createLabel(self, game.getStrByKey("set_auto_purple"), cc.p(posX_labelStart + distance_between_check_box * 3, posY_base), cc.p(0, .5), 22, nil, nil, nil, MColor.purple)
    GetUIHelper():AddTouchEventListener(true, label_checkBox_purple, nil, function() clickFunc(self.check_box_purple) end)
    self.check_box_orange = createTouchItem(self, checkBox_user_prefrence.orange and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png", cc.p(posX_checkBoxStart + distance_between_check_box * 4, posY_base), clickFunc)
    self.check_box_orange:setAnchorPoint(cc.p(0, .5))
    local label_checkBox_orange = createLabel(self, game.getStrByKey("set_auto_orange"), cc.p(posX_labelStart + distance_between_check_box * 4, posY_base), cc.p(0, .5), 22, nil, nil, nil, MColor.orange)
    GetUIHelper():AddTouchEventListener(true, label_checkBox_orange, nil, function() clickFunc(self.check_box_orange) end)
    local function closeFunc()
        local checkBox_user_prefrence = json.decode(getLocalRecordByKey(2, "auto_smelter_check_user_preference"))
        local table_quality = {}
        for k, v in ipairs(require("src/config/propOp.lua").allQualityColors()) do
            if v == MColor.drop_white and checkBox_user_prefrence.white then
                table.insert(table_quality, k)
            end
            if v == MColor.green and checkBox_user_prefrence.green then
                table.insert(table_quality, k)
            end
            if v == MColor.blue and checkBox_user_prefrence.blue then
                table.insert(table_quality, k)
            end
            if v == MColor.purple and checkBox_user_prefrence.purple then
                table.insert(table_quality, k)
            end
            if v == MColor.orange and checkBox_user_prefrence.orange then
                table.insert(table_quality, k)
            end
        end
        if G_ROLE_MAIN then
            g_msgHandlerInst:sendNetDataByTableExEx(DIGMINE_CS_OFFMINE_REWARD, "DigOffMine", {quality = serialize(table_quality)})
        end
        removeFromParent(self.smallBg)
        removeFromParent(self.masking)
        removeFromParent(self)
    end
    local closeBtn = createMenuItem(self.smallBg, "res/component/button/2.png", cc.p(self.smallBg:getContentSize().width/2+5, -33), closeFunc)
    createLabel(closeBtn, game.getStrByKey("lotteryEx_sure"), cc.p(closeBtn:getContentSize().width/2, closeBtn:getContentSize().height/2), cc.p(0.5, 0.5), 22, true)
end

function offlineMineLog:createItemAction()
    self.posTab = {}
    local startX =  400-55*self.number+55
    if self.number > 9 then
        startX = -30
    end
    local startY = 340
    for i = 1 ,self.number do
        startY = 340 - math.floor((i-1)/9)*120            
        local k = i
        k = math.floor((i-1)%9)+1
        table.insert(self.posTab,{startX + (k)*104 - 20,startY})
    end
    local width = 583
    local height = 190
    local scrollView1 = cc.ScrollView:create()
    scrollView1:setViewSize(cc.size( width , height ) )
    scrollView1:setPosition( cc.p(  display.cx , display.cy + 7  ) )
    scrollView1:ignoreAnchorPointForPosition(false)
    local groupAwards =  __createAwardGroup(self.tabId, nil , 85 , nil , false )
    setNodeAttr( groupAwards , cc.p( 0 , 30 ) , cc.p( 0.5 , 0 ) )
    scrollView1:setContainer( groupAwards )
    scrollView1:updateInset()
    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL )
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    scrollView1:setDelegate()
    self:addChild(scrollView1)
    if groupAwards:getContentSize().width < width - 100 then
        scrollView1:setTouchEnabled( false )
        scrollView1:setContentOffset( cc.p( ( width - groupAwards:getContentSize().width )/2 , 40 ) )
    else
        scrollView1:setTouchEnabled( true )
    end  
end

return offlineMineLog