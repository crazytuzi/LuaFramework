local CarryLayer = class("CarryLayer", require("src/layers/setting/BaseLayer"))

local path = "res/layers/battle/carry/"

function CarryLayer:ctor()
	self.activityName = "Envoy"
    self.mapid = 3100
    self.FbNodeTab = {}
	self.cfgData = getConfigItemByKey( "ActivityNormalDB", "q_id" )
	for k,v in pairs(self.cfgData) do
        if v.q_key == self.activityName then
            self.cfg = v
            break
        end
    end

	local title = self.cfg and self.cfg.q_name or ""
	local base_node = createBgSprite(self, title)
    local size = base_node:getContentSize()
    local base_bg = createScale9Frame(
        base_node,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(32, 38),
        cc.size(896, 500),
        5
    )
    self.bg = base_node

    createSprite(base_node, path .. "bg.jpg", cc.p(32, size.height - 103), cc.p(0 , 1))
    createSprite(base_node, path .. "shard.png", cc.p(32, size.height - 191), cc.p(0 , 1))

    self.btnCfg = {{name = "铁血炼狱(单倍泡点经验)", exp = "+1.5倍经验", costPropId = 6200029},
                   {name = "通天炼狱(双倍泡点经验)", exp = "+2倍经验", costPropId = 6200030 },
                   {name = "修罗炼狱(多倍泡点经验)", exp = "+3倍经验", costPropId = 6200031 },
                  }

    local posCfg = { {bossPos = cc.p(121 - 88, size.height - 103), propName = 169 - 88},
                     {bossPos = cc.p(413 - 88, size.height - 117), propName = 460 - 88},
                     {bossPos = cc.p(704 - 88, size.height - 108), propName = 751 - 88},
                    }

    local pack = MPackManager:getPack(MPackStruct.eBag)
    local MConfigProp = require "src/config/propOp"
    
    for i=1, #self.btnCfg do
        local itemData = self.btnCfg[i]
        local posData = posCfg[i]
        local tempNode = cc.Node:create()
        base_node:addChild(tempNode, 1, 200 + i)
        self.FbNodeTab[i] = tempNode

        local sprName = "res/layers/battle/carry/lv_" .. i ..".png"
        local bossSpr = GraySprite:create(sprName)
        tempNode:addChild(bossSpr)
        bossSpr:setAnchorPoint(cc.p(0, 1))
        bossSpr:setPosition(posData.bossPos)
        bossSpr:addColorGray()        
        tempNode.bossSpr = bossSpr
        
        local proNameBg = createSprite(tempNode, "res/common/bg/propNamebg.png", cc.p(posData.propName, 640 - 402), cc.p(0, 1))
        createLabel(proNameBg, game.getStrByKey("need_cost") .. "：", getCenterPos(proNameBg, -100, 0), cc.p(0, 0.5), 18):setColor(MColor.lable_yellow)

        local num = pack:countByProtoId(itemData.costPropId)
        local strName = MConfigProp.name(itemData.costPropId) .. "x1"
        local labLink = createLinkLabel(proNameBg, strName, getCenterPos(proNameBg, -30, 1), cc.p(0, 0.5), 18, true, nil, MColor.yellow, nil, function() 
            local Mtips = require "src/layers/bag/tips"
            Mtips.new(
            { 
                protoId = itemData.costPropId,
                pos = cc.p(0, 0),
            })
        end, true)
        labLink:setColor( (num > 0) and MColor.green or MColor.red)
        tempNode.costPropNameLab = labLink

        local tempBg1 = createScale9Sprite(tempNode, "res/common/scalable/14_0.png", cc.p(posData.propName - 15, 640 - 427),cc.size(243, 41),cc.p(0, 1))            
        local tempBg2 = createScale9Sprite(tempNode, "res/common/scalable/14_1.png", cc.p(posData.propName - 15, 640 - 427),cc.size(243, 41),cc.p(0, 1))
        local tempSelLight = createScale9Sprite(tempBg2, "res/common/scalable/14_2.png", getCenterPos(tempBg2),cc.size(220, 30),cc.p(0.5, 0.5))
        tempBg2:setVisible(false)
        tempNode.UnselFbNameBg = tempBg1
        tempNode.SelFbNameBg = tempBg2
        createSprite(tempNode, "res/common/scalable/14_3.png", cc.p(posData.propName + 107, 640 - 427- 7))

        local fbNameLab = createLabel(tempNode, itemData.name, cc.p(posData.propName + 107, 640 - 427 - 21), nil, 18)
        fbNameLab:setColor(MColor.lable_black)
        tempNode.fbNameLab = fbNameLab
    end
    self:chooseOneBtn(1)

    local btnState = DATA_Battle:getRedData( self.activityName) 

    self.gotoBtn = createMenuItem(self.bg, "res/component/button/50.png", cc.p(810, 85), function() self:gotoBtnCallBack() end)
    self.gotoBtn:setEnabled(false)

    self.btnLab = createLabel(self.gotoBtn, game.getStrByKey("join_activity"), getCenterPos(self.gotoBtn), nil, 22, true)
    
    local help = __createHelp(
    {
        parent = base_node,
        str = require("src/config/PromptOp"):content(71),
        pos = cc.p(900, 510),
        zorder = 200,
    })    

    local lv = self.cfg and self.cfg.q_level or 32
    createLabel(base_node, game.getStrByKey("bodyguard_lv") .."：", cc.p(740, 145), cc.p(0, 0.5),20,true)
    createLabel(base_node, "" ..lv, cc.p(840, 145), cc.p(0, 0.5),20,true):setColor(MColor.lable_black)

    local str = game.getStrByKey("empire_rule_3_title") .. "："
    createLabel(base_node, str, cc.p(86, 145), cc.p(0, 0.5), 20, true)

    local lab = createLabel(base_node, "炼狱中的怪物拥有高额经验。   ", cc.p(81 + 65, 145),cc.p(0, 0.5), 20, true)
    lab = createLabel(base_node, "活动时间：", cc.p(lab:getPosition() + lab:getContentSize().width +20, 145),cc.p(0, 0.5), 20, true)
    lab = createLabel(base_node, "每天10:00—22:00", cc.p(lab:getPosition() + lab:getContentSize().width +3, 145),cc.p(0, 0.5), 20, true)
    lab:setColor(MColor.lable_black)
    
    self:regeditTouchEvent()
    self:addProcEvent()
    
    local activityID = (self.cfg and self.cfg.q_activity_id or 2)
    g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN , "ActivityNormalCanJoin", { activityID = activityID } )
    local msgids = {ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN_RET}
    require("src/MsgHandler").new(self,msgids)
end

function CarryLayer:regeditTouchEvent( )
    SwallowTouches(self)

    local  listenner = cc.EventListenerTouchOneByOne:create()
    listenner:setSwallowTouches(false)
    listenner:registerScriptHandler(function(touch, event)
            return true
        end,cc.Handler.EVENT_TOUCH_BEGAN )
    listenner:registerScriptHandler(function(touch, event)
            local posCfg = {169 - 88, 460 - 88, 751 - 88}
            local pt = self.bg:convertTouchToNodeSpace(touch)
            for i=1, #self.btnCfg do
                local rect = cc.rect(posCfg[i] - 21, 640 - 402, 214 + 42, 300)
                if cc.rectContainsPoint(rect, pt) == true then
                    self:chooseOneBtn(i)
                    break
                end
            end
            return true
        end,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = self.bg:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.bg)    
end

function CarryLayer:addProcEvent()
    local MPackManager = require "src/layers/bag/PackManager"
    local pack = MPackManager:getPack(MPackStruct.eBag)  

    local tmp_node = cc.Node:create()
    local tmp_func = function(observable, event, pos, pos1, new_grid)
        if event == "-" or event == "+" or event == "=" then
            for i=1,#self.btnCfg do
                local tempCfg = self.btnCfg[i]
                if tempCfg.costPropId then
                    local newpropNum1 = pack:countByProtoId(tempCfg.costPropId)
                    if newpropNum1 > 0 then
                        if self.FbNodeTab[i] and self.FbNodeTab[i].costPropNameLab then
                            self.FbNodeTab[i].costPropNameLab:setColor( (newpropNum1 > 0) and MColor.green or MColor.red)
                        end
                    end
                end
            end
        end
    end

    tmp_node:registerScriptHandler(function(event)
        if event == "enter" then
            pack:register(tmp_func)
        elseif event == "exit" then
            pack:unregister(tmp_func)
        end
    end)
    self:addChild(tmp_node)    
end

function CarryLayer:cfgInfo(index)
    self.bg:removeChildByTag(5000)
    local bg = cc.Node:create()
    self.bg:addChild(bg,2, 5000)

    local tempWidth = 553
    local topHeight, offSetY = 495, 30
    local dropidCfg = {655,656,657}
    local DropOp = require("src/config/DropAwardOp")
    local gdItem = DropOp:getItemBySexAndSchool(dropidCfg[index] or 655)
    local propOP = require("src/config/propOp")
    local j = 1
    for m,n in pairs(gdItem) do
        if j > 7 then 
            break 
        end

        local Mprop = require "src/layers/bag/prop"
        local icon = Mprop.new(
        {
            protoId = tonumber(n.q_item),
            --num = tonumber(n.q_count),    
            swallow = true,
            cb = "tips",
            showBind = true,
            isBind = tonumber(n.bdlx or 0) == 1,
        })
        icon:setTag(9)
        bg:addChild(icon)
        icon:setPosition(cc.p(81 + (j - 1)  * 85  + 8 , 85))
        icon:setAnchorPoint(0, 0.5)
        icon:setScale(0.9)
        j = j + 1
    end
end

function CarryLayer:gotoBtnCallBack()
    if self:checkLev() then
        __GotoTarget( { ru = "a67", zzLevel = self.chooseLev})
    end
end

function CarryLayer:checkLev()
    local cfg = self.cfg
    if cfg and cfg.q_level > MRoleStruct:getAttr(ROLE_LEVEL) then
        TIPS( {str = string.format(game.getStrByKey("activity_begain_atLev"), cfg.q_level)} )
        return false
    end

    local mapInfo = getConfigItemByKey("MapInfo", "q_id")[self.mapid]
    if mapInfo and mapInfo.q_map_min_level and mapInfo.q_map_min_level > MRoleStruct:getAttr(ROLE_LEVEL) then
        local msg_item = getConfigItemByKeys( "clientmsg" , { "sth" , "mid" } , { 21000 , -1 } )
        local msgStr = string.format( msg_item.msg , tostring( mapInfo.q_map_min_level ) )
        TIPS( { type = msg_item.tswz , flag = msg_item.flag , str = msgStr })                    
        return false
    end   
    return true
end

function CarryLayer:chooseOneBtn(index)
    for i=1,#self.FbNodeTab do
        local tempNode = self.FbNodeTab[i]
        if tempNode then
            if i == index then
                tempNode.bossSpr:removeColorGray()
                tempNode.fbNameLab:setColor(MColor.white)
            else
                tempNode.bossSpr:addColorGray()
                tempNode.fbNameLab:setColor(MColor.lable_black)
            end
            tempNode.SelFbNameBg:setVisible(i == index )
            tempNode.UnselFbNameBg:setVisible(not (i == index))
        end
    end
    self.chooseLev = index
    self:cfgInfo(index)
end

function CarryLayer:networkHander(buff,msgid)
    local switch = 
    {
        [ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN_RET] = function()
            local t = g_msgHandlerInst:convertBufferToTable( "ActivityNormalCanJoinRet" , buff )    
            local retNum = t.canJoin
            --dump(retNum, "retNum")

            local str = game.getStrByKey("join_activity")
            if retNum == 1 then
                str = game.getStrByKey("join_activityLate")
            end
            
            if self.btnLab then
                self.btnLab:setString(str)
            end

            if self.gotoBtn then
                self.gotoBtn:setEnabled(retNum == 0)
            end
        end,
    }

    if switch[msgid] then
        switch[msgid]()
    end
end

return CarryLayer