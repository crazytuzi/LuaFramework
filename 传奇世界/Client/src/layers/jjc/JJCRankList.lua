local JJCRankList = class("JJCRankList", require ("src/TabViewLayer"))
local comPath = "res/jjc/"

function JJCRankList:ctor(mode)
    self.page_index = 1
    self.mode = mode
    g_msgHandlerInst:sendNetDataByTableExEx(SINPVP_CS_GETRANK,"SinpvpGetRankProtocol",{rankPage = self.page_index})
    self.itemNum = 0
    self.itemData = {}
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
    local title = createLabel(root, game.getStrByKey("rank_list"),cc.p(root_size.width/2,root_size.height-30),nil,24,true)
    local closeFunc = function() 
      root:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0), cc.CallFunc:create(function() removeFromParent(self) end)))  
    end
    local closeBtn = createTouchItem(root,"res/component/button/x2.png",cc.p(root_size.width - 40 ,root_size.height - 25),closeFunc)
    registerOutsideCloseFunc(root, function() removeFromParent(self) end)
    
    self:createTableView(root,cc.size(800,450),cc.p(28,20),true,true)
	local msgids = {SINPVP_SC_GETRANK}
    require("src/MsgHandler").new(self,msgids)
end

function JJCRankList:cellSizeForTable(table,idx) 
    return 100,800
end

function JJCRankList:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    
    local new = function (cell,idx)
       -- cell:setTag(self.itemData[idx][1])
        local i = idx+1
        local posx,posy = 113.5,30
        local item = self.itemData[i]
        createSprite(cell, "res/common/table/cell11.png", cc.p(3,50), cc.p(0.0,0.5))
        if i <= 3 then
           -- createSprite(cell,"res/jjc/sunshine.png",cc.p(70,50),cc.p(0.5,0.5))
            createSprite(cell,"res/jjc/"..i..".png",cc.p(50,50),cc.p(0.5,0.5))
        else
            local rank= MakeNumbers:create("res/component/number/5.png",item[1],-10)
            rank:setPosition(cc.p(42,50))
            cell:addChild(rank)
        end
        local iconBg = createSprite(cell,"res/common/bg/iconBg.png",cc.p(130,50),cc.p(0,0.5))
        if iconBg then iconBg:setScale(0.8) end
        createSprite(cell,"res/mainui/head/"..(item[4]+(item[5]-1)*3)..".png",cc.p(140,50),cc.p(0,0.5),nil,0.95)
        --createSprite(cell,"res/jjc/nameBg.png",cc.p(250,50),cc.p(0,0.5),nil)
        createLabel(cell, item[3], cc.p(280,50),cc.p(0,0.5),20,false,nil,nil,MColor.lable_black)
        createSprite(cell,"res/jjc/combatPowerBg.png",cc.p(520,50),cc.p(0,0.5),nil)
        createSprite(cell,"res/common/misc/power_b.png",cc.p(520,50),cc.p(0,0.5),nil,0.8)
        local force = MakeNumbers:create("res/component/number/10.png",item[6],-5)
        local posx1,scale = 650,0.65
        if item[6] < 1000 then
        elseif item[6] < 10000 then
            posx1 = 635
        elseif item[6] < 100000 then 
            posx1 = 635
        elseif item[6] < 1000000 then 
            posx1 = 635 scale=0.5 
        else
            posx1 = 635 scale=0.5 
        end
        force:setScale(scale)
        force:setPosition(cc.p(posx1,50))
        cell:addChild(force)
    end

    log("index"..idx)
    -- if self.page_index*15 == (idx + 1 ) and self.page_index < 10 then
        -- self.page_index = self.page_index + 1

        -- g_msgHandlerInst:sendNetDataByFmtExEx(SINPVP_CS_GETRANK,"bic",self.mode,userInfo.currRoleId,self.page_index)
    -- end
    if nil == cell then
       cell = cc.TableViewCell:new()   
       new(cell,idx)        
    else
        cell:removeAllChildren()
        new(cell,idx)
    end

    return cell
end

function JJCRankList:numberOfCellsInTableView(table)
    return self.itemNum
end

function JJCRankList:tableCellTouched(table,cell)
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

function JJCRankList:networkHander(luabuffer,msgid)
	cclog("JJCBattleView:networkHander")
    local switch = {
        [SINPVP_SC_GETRANK] = function() 
            cclog("SINPVP_SC_GETRANK")
			local t = g_msgHandlerInst:convertBufferToTable("SinpvpGetRankRetProtocol", luabuffer)
            local itemNum = t.rankNum
            if itemNum  > 0 then
                self.itemNum = self.itemNum + itemNum
                for i=1,itemNum do
                    --排名 静态ID 名字 职业 性别 战斗力 武器 衣服 翅膀 血量 等级
					local info = t.rankTargetInfo[i]
					local item = {}
					local j = 1
					for k,v in pairs(info) do
						item[j] = v
						j = j + 1
					end
                    table.insert(self.itemData,item)
                end
                -- dump(self.itemData)
                local func = function(a,b)
                      return  a[1] <= b[1]
                 end
                table.sort(self.itemData,func)
                local offset =  self:getTableView():getContentOffset()    
                dump(offset)
                self:getTableView():reloadData()
                if self.page_index > 1 then
                    self:getTableView():setContentOffset(cc.p(offset.x,offset.y-100*itemNum)) 
                end
            end
        end,
    }

    if switch[msgid] then 
        switch[msgid]()
    end
end

return JJCRankList