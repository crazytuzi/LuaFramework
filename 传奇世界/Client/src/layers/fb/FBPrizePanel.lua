local FBPrizePanel = class("FBPrizePanel", require ("src/TabViewLayer"))

function FBPrizePanel:ctor(prizes)
    local addSprite = createSprite
    local addLabel = createLabel

	local bg = addSprite(self,"res/common/bg/bg18.png",cc.p(g_scrSize.width/2,g_scrSize.height/2))
    self.Bg = bg
    
    createLabel(self.Bg, game.getStrByKey("title_fb_rewards"),cc.p(425,500), cc.p(0.5,0.5),24,true)   
    createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )
	CreateListTitle(bg, cc.p(425,450), 790, 46, cc.p(0.5,0.5))
    addSprite(bg,"res/common/bg/bg12-1.png",cc.p(425,80),cc.p(0.5,0.5))
    --addSprite(bg, "res/fb/17.png", cc.p(bg:getContentSize().width / 2 , 470), cc.p(0.5,0.5))
    local closeFunc = function()   
        self.Bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() removeFromParent(self) end)))    
    end
    createTouchItem(bg,"res/component/button/x2.png",cc.p(bg:getContentSize().width - 35,bg:getContentSize().height - 30),closeFunc)
    
    self.prizes = prizes or {}
	self:createTableView(self.Bg, cc.size(810,340), cc.p(15,85),true)

	local getAll = function()
		cclog("getAll")
		g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETPROREWARD, "GetProRewardProtocol", {getTime = 0, copyID = 0})
	end
	createLabel(self.Bg, game.getStrByKey("fb_prizeDesc"),cc.p(40,50), cc.p(0.0,0.5),18)   
	createLabel(self.Bg, game.getStrByKey("fb_fbName"),cc.p(110,450), cc.p(0.5,0.5),22,true)   
	createLabel(self.Bg, game.getStrByKey("fb_prize"),cc.p(365,450), cc.p(0.5,0.5),22,true)   

    local menuitem = createMenuItem(bg,"res/component/button/50.png",cc.p(745,48),getAll)
    createLabel(menuitem, game.getStrByKey("fb_getAllPrize"),getCenterPos(menuitem), cc.p(0.5,0.5),18,true)

    -- local retToFBHall = function()
    --     local nd = require("src/layers/fb/FBHallView").new(1)
    --     getRunScene():addChild(nd,200,150)
    -- end
    -- local  menuitem= createMenuItem(bg,"res/component/button/50.png",cc.p(580,48),retToFBHall)
    -- createLabel(menuitem, game.getStrByKey("fb_returnToFbHall"),getCenterPos(menuitem), cc.p(0.5,0.5),18,true)

    bg:setScale(0.01)
    bg:runAction(cc.ScaleTo:create(0.2, 1))
    registerOutsideCloseFunc(bg,closeFunc,true)
    
    local msgids = {COPY_SC_GETPROREWARDRET}
    require("src/MsgHandler").new(self,msgids)
    self:registerScriptHandler(function(event)
        if event == "enter" then 
        elseif event == "exit" then
            if #self.prizes > 0 then
                local openList = function() 
                    g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETPROREWARDLIST,"GetProRewardListProtocol",{})
                end
                if G_MAINSCENE and not G_MAINSCENE:getChildByTag(617) then
                    local btn = G_MAINSCENE:createActivityIconData({priority= 30, 
                                            btnResName = "res/mainui/subbtns/fbsy.png",
                                            btnResLab = game.getStrByKey("title_fb_rewards"),
                                            btnCallBack = openList,
                                            btnZorder = 200})
                    userInfo.fbPrizeBtn = btn
                    userInfo.fbPrizeBtn:setTag(617)
                end
            end
        end
    end)
end

function FBPrizePanel:tableCellTouched(table,cell)
	-- local posx,posy = cell:getPosition()
 --    if self.selectedIndex and self.selectedIndex ~= cell:getIdx() and table:cellAtIndex(self.selectedIndex) then 
 --        local bg_sprite = tolua.cast(table:cellAtIndex(self.selectedIndex):getChildByTag(1),"cc.Sprite")
 --        bg_sprite:setTexture("chat/unselected.png")
 --        self:updateChatInfo()
 --    end
 --    self.selectedIndex = cell:getIdx()
 --    self:updateTopLabel()
 --    local bg_sprite = tolua.cast(cell:getChildByTag(1),"cc.Sprite")
 --    bg_sprite:setTexture("chat/selected.png")
end 


function FBPrizePanel:cellSizeForTable(table,idx) 
    return 100,810
end

function FBPrizePanel:numberOfCellsInTableView(table)
  	return #self.prizes
end

function FBPrizePanel:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    
    local constFunc = function(node)
        local data = require("src/config/FBSingle")
        local str = nil
        --单人剧情本
        for x=1,#data do
            if data[x].q_id == tonumber(self.prizes[idx+1][2]) then
                str = data[x].F1
                break
            end
        end

        --通天塔
        if not str then
            data = require("src/config/FBTower")
            for i=1, #data do
                if data[i].q_id == tonumber(self.prizes[idx+1][2]) then
                    str = game.getStrByKey("fb_tianguan") .. data[i].q_copyLayer .. game.getStrByKey("fb_ceng")
                    break
                end
            end
        end

        --守护公主
        if not str then
            str = game.getStrByKey("fb_shouhu")
        end

    	createSprite(node,"res/common/table/cell11.png",cc.p(15,0),cc.p(0.0,0.0))
        --createSprite(node,"res/fb/"..(100+xx)..".png",cc.p(100,50),cc.p(0.5,0.5))
        createLabel(node, str, cc.p(100,50), cc.p(0.5,0.5), 20, true):setColor(MColor.lable_yellow)
        local Mprop = require "src/layers/bag/prop"
        for i=1,self.prizes[idx+1][3] do       
            local icon = Mprop.new(
            {
                protoId = tonumber(self.prizes[idx+1][4][i][1] ),
                num = tonumber(self.prizes[idx+1][4][i][2]),
                --isBind = isBind,
                swallow = true,
                cb = "tips",
            })
            icon:setAnchorPoint(cc.p(0.0,0.5))
            icon:setPosition(cc.p(170+i*80,50))
            icon:setScale(0.8)
            node:addChild(icon)
        end
        --createSprite(node,require("src/config/propOp").icon(self.prizes[idx+1][4][i][1]),cc.p(150+i*80,50),cc.p(0.0,0.5))
        local func = function()
        	g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETPROREWARD, "GetProRewardProtocol", {getTime = self.prizes[idx+1][1], copyID = self.prizes[idx+1][2]})
        end
        local menuitem = createMenuItem(node,"res/component/button/50.png",cc.p(730,50),func)
        menuitem:setScale(0.8)
        createLabel(node, game.getStrByKey("fb_get"),cc.p(730,50), cc.p(0.5,0.5),18,true)
    end

    if nil == cell then
        cell = cc.TableViewCell:new()
        constFunc(cell)     
    else
    	cell:removeAllChildren()
    	constFunc(cell)
    end
    return cell
end

function FBPrizePanel:reloadList(prizes)
	self.prizes = prizes
	self:getTableView():reloadData()
end

function FBPrizePanel:networkHander(buff,msgid)
    local switch = {

        [COPY_SC_GETPROREWARDRET] = function() 
        	cclog("COPY_SC_GETPROREWARDRET")
            g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETPROREWARDLIST,"GetProRewardListProtocol",{})
        end,
    }

    if switch[msgid] then 
        switch[msgid]()
    end
end

return FBPrizePanel