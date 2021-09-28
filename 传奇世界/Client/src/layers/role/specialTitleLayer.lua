local specialTitleLayer = class("specialTitleLayer", require("src/TabViewLayer"))
local MRoleStruct = require("src/layers/role/RoleStruct")
function specialTitleLayer:ctor(params)
    self.params=params
    local bg =  createScale9Sprite(self,"res/common/scalable/6.png",cc.p(display.cx,display.cy),cc.size(625,260),cc.p(0.5,0.5))
	registerOutsideCloseFunc(bg, function() removeFromParent(self) end, true)

    local sign = "res/layers/qqMember/qq.png"
    local str = game.getStrByKey("qq_game_center_start")
   
    self.tableNum=math.floor(tablenums(getConfigItemByKey("SpecialTitleDB", "q_id"))/3)
    
    self.titles={}
    for k,v in pairs(getConfigItemByKey("SpecialTitleDB", "q_id")) do
        
        if not self.titles[v.q_school] then
            self.titles[v.q_school]={}
        end
        self.titles[v.q_school][#self.titles[v.q_school]+1]=v
    end
    self.tableNum=math.min(self.tableNum,tablenums(self.titles[1]))

    self:createTableView(bg, cc.size(630, 206), cc.p(10, 16), true)
    local names={"等级","战士","法师","道士"}
    createLabel(bg, names[1], cc.p(78, 240), cc.p(0.5, 0.5), 22, true,nil,nil,MColor.lable_yellow)
    for i=2,4 do
       createLabel(bg, names[i], cc.p(66+153*(i-1), 240), cc.p(0.5, 0.5), 22, true,nil,nil,MColor.lable_yellow)
    end
    local minLv=getConfigItemByKey("SpecialTitleDB", "q_id",1,"q_lv") 
    local myLv=MRoleStruct:getAttr(ROLE_LEVEL)
    if self.params.static then
        myLv=self.params.datasource[ROLE_LEVEL]
    end
    local showPos=0
    for k,v in pairs(self.titles[1]) do
        if v.q_lv==myLv then
            showPos=k
        end
    end


    local pos=-(self.tableNum-(showPos)-3)*35
    pos=pos<-(self.tableNum-6)*35 and -(self.tableNum-6)*35 or pos
    if pos>0 then
        pos=0
    end
    startTimerAction(self,0.01, false, function() 
    self.m_tabView:setContentOffset(cc.p(0,pos))    
    end)

end
function specialTitleLayer:cellSizeForTable(table,idx) 
    return 35,650
end

function specialTitleLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
     if cell == nil then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end
    -- if nil == cell then
    --     cell = cc.TableViewCell:new() 
    --     print("nil == cell,idx="..idx)

    -- else
    --     print("nil ~= cell,idx="..idx)

    -- end
    local item=self.titles[1][idx+1]
    local lastItem=nil
    local nextItem=nil
    if idx~=0 then
        lastItem=self.titles[1][idx]
    end
    if idx<self.tableNum then

        nextItem=self.titles[1][idx+2]
    end
    local lv = item["q_lv"]
    local myLv=MRoleStruct:getAttr(ROLE_LEVEL)
    local isCurLv=true
    
    local lvBg=createScale9Sprite(cell,"res/common/scalable/16.png",cc.p(70, 20),cc.size(110,28),cc.p(0.5,0.5))
    local lvStr=""
    
    local lastExp=lastItem and lastItem.q_exp
    local lastLv =lastItem and lastItem.q_lv

    local nextExp=nextItem and nextItem.q_exp
    local nextLv =nextItem and nextItem.q_lv

    
    local nowExp=item.q_exp
    local xpPercent=math.floor(MRoleStruct:getAttr(PLAYER_XP)/MRoleStruct:getAttr(PLAYER_NEXT_XP)*100)
    if self.params.static then
        xpPercent=math.floor(self.params.datasource[PLAYER_XP]/self.params.datasource[PLAYER_NEXT_XP]*100)
        print("xpPercentxpPercentxpPercentxpPercent="..xpPercent)
        myLv=self.params.datasource[ROLE_LEVEL]
    end
    if lv==myLv   then
        if nowExp<=xpPercent then
            if nextLv and nextLv==myLv then
                if nextExp and nextExp>xpPercent then
                    lvStr=lv.."级"..nowExp.."%"
                    createSprite(cell,"res/common/arrow_specialtitle.png",cc.p(7,20),cc.p(0.5,0.5))
                    local rightArrow=createSprite(cell,"res/common/arrow_specialtitle.png",cc.p(597,20),cc.p(0.5,0.5))
                    rightArrow:setFlippedX(true)
                else
                    lvStr=lv.."级"..nowExp.."%"
                    isCurLv=false
                end
            else
                lvStr=lv.."级"..nowExp.."%"
                createSprite(cell,"res/common/arrow_specialtitle.png",cc.p(7,20),cc.p(0.5,0.5))
                local rightArrow=createSprite(cell,"res/common/arrow_specialtitle.png",cc.p(597,20),cc.p(0.5,0.5))
                rightArrow:setFlippedX(true)
            end
        else
            lvStr=lv.."级"..nowExp.."%"
            isCurLv=false
        end
    elseif (nextItem==nil and lv<=myLv) or (nextItem and nextItem.q_exp>xpPercent and nextLv==myLv and lv<myLv ) then
        lvStr=lv.."级"..nowExp.."%"
        createSprite(cell,"res/common/arrow_specialtitle.png",cc.p(7,20),cc.p(0.5,0.5))
        local rightArrow=createSprite(cell,"res/common/arrow_specialtitle.png",cc.p(597,20),cc.p(0.5,0.5))
        rightArrow:setFlippedX(true)

    else
        lvStr=lv.."级"..nowExp.."%"
        isCurLv=false
    end
    local titleColor=isCurLv and MColor.lable_yellow or MColor.lable_black
    local level=createLabel(cell,lvStr, cc.p(70, 20), cc.p(0.5, 0.5), 20, true,nil,nil,titleColor,11)
    for i=0,2 do
        local curItem=self.titles[i+1][idx+1]
        local nameBg=createScale9Sprite(cell,"res/common/scalable/16.png",cc.p(206+155*i, 20),cc.size(146,28),cc.p(0.5,0.5))
        local name = curItem.q_name
        local color = curItem.q_color
        local titleColor = MColor[color]
        
        local name1=createLabel(nameBg, name, cc.p(73, 14), cc.p(0.5, 0.5), 20, true,nil,nil,titleColor,20)
    end

    return cell
end

function specialTitleLayer:numberOfCellsInTableView(table)
   return self.tableNum
end
return specialTitleLayer