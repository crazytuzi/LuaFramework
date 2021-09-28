local JJCBattleRecord = class("JJCBattleRecord", require ("src/TabViewLayer"))
local comPath = "res/jjc/"

function JJCBattleRecord:ctor(logs)
    if logs then
        self.itemNum = #logs
        self.itemData = logs
    else
        self.itemNum = 0
        self.itemData = {}
    end

    local root = createSprite(self,"res/common/bg/bg18.png",g_scrCenter)
    local root_size = root:getContentSize()
    createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )

    local title = createLabel(root, game.getStrByKey("battle_record"),cc.p(root_size.width/2,root_size.height-30),nil,24,true)
    local closeFunc = function() 
      root:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0), cc.CallFunc:create(function() removeFromParent(self) end)))  
    end
    local closeBtn = createTouchItem(root,"res/component/button/x2.png",cc.p(root_size.width - 40 ,root_size.height - 25),closeFunc)
    registerOutsideCloseFunc(root, function() removeFromParent(self) end)
    

    self:createTableView(root,cc.size(800,450),cc.p(28,20),true,true)
end


function JJCBattleRecord:cellSizeForTable(table,idx) 
    return 100,800
end

function JJCBattleRecord:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    
    local new = function (cell,idx)
        local i = self.itemNum-idx
        local posx,posy = 113.5,30
        local item = self.itemData[i]
        createSprite(cell, "res/common/table/cell11.png", cc.p(3,50), cc.p(0.0,0.5))
        local pic1,pic2 = "win","up"
        if item.res == false then
            pic1 = "fail"
            pic2 = "down"
        end
        createSprite(cell,"res/jjc/"..pic1..".png",cc.p(30,100),cc.p(0.5,1.0))
        if tostring(item.rank) == "0" then
            createLabel(cell, "——",cc.p(80,50), cc.p(0.5,0.5),18):setColor(MColor.red)
        else
            createSprite(cell,"res/jjc/"..pic2..".png",cc.p(80,60),cc.p(0.5,0.5))
            createLabel(cell, tostring(item.rank),cc.p(80,20), cc.p(0.5,0.5),18):setColor(MColor.red)
        end
        local iconBg = createSprite(cell,"res/common/bg/iconBg.png",cc.p(110,50),cc.p(0,0.5))
        if iconBg then iconBg:setScale(0.8) end
        createSprite(cell,"res/mainui/head/"..(item.sch+(item.sex-1)*3)..".png",cc.p(120,50),cc.p(0,0.5),nil,0.95)
        --createSprite(cell,"res/jjc/nameBg.png",cc.p(250,65),cc.p(0,0.5),nil)
        createLabel(cell, item.name, cc.p(340,65),cc.p(0.5,0.5),20,false,nil,nil,MColor.lable_black)

        local dates = os.date("*t",item.time)
        local str = string.format(game.getStrByKey("date_format"),dates.year,dates.month,dates.day,dates.hour,dates.min)
        createLabel(cell, str, cc.p(340,35),cc.p(0.5,0.5),18,false,nil,nil,MColor.lable_black)

        createSprite(cell,"res/jjc/combatPowerBg.png",cc.p(520,50),cc.p(0,0.5),nil)
        createSprite(cell,"res/common/misc/power_b.png",cc.p(520,50),cc.p(0,0.5),nil,0.8)
        local num = item.fight or 0
        local force = MakeNumbers:create("res/component/number/10.png",num,-5)
        local posx1,scale = 650,0.65
        if num < 1000 then
        elseif num < 10000 then
            posx1 = 635
        elseif num < 100000 then 
            posx1 = 635
        elseif num < 1000000 then 
            posx1 = 635 scale=0.5 
        else
            posx1 = 635 scale=0.5 
        end
        if force then
            force:setScale(scale)
            force:setPosition(cc.p(posx1,50))
            cell:addChild(force)
        end
    end

    log("index"..idx)
    if nil == cell then
       cell = cc.TableViewCell:new()   
       new(cell,idx)        
    else
        cell:removeAllChildren()
        new(cell,idx)
    end

    return cell
end

function JJCBattleRecord:numberOfCellsInTableView(table)
    return self.itemNum
end

function JJCBattleRecord:tableCellTouched(table,cell)
    -- local posx,posy = cell:getPosition()
    -- if not self.picked_bg then
    --     self.picked_bg = createSprite(table,"res/teamup/15.png",cc.p(posx,posy-2),cc.p(0,0),9)
    -- else
    --     self.picked_bg:setPosition(cc.p(posx,posy-2))
    -- end
    -- self.selectedPlayer = cell:getTag()
    -- local idx = cell:getIdx()
    -- if self.itemData[idx][5] ~= 0 then
    --     self.inviteOrApply:setString("申请入队")
    -- else
    --     self.inviteOrApply:setString("邀请入队")
    -- end
end

return JJCBattleRecord