--[[
******角色详情*******
    -- by king
    -- 2015/4/27
]]

local RoleBook_Node = class("RoleBook_Node", BaseLayer)

CREATE_PANEL_FUN(RoleBook_Node)

function RoleBook_Node:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.role_new.booknode")
end


function RoleBook_Node:onShow()
    self.super.onShow(self)

      
    self:refreshUI()
end

function RoleBook_Node:refreshUI()
    if not self.isShow then
        return
    end

    if self.itemid then
        self.bagItem    = BagManager:getItemById(self.itemid)
    end
end

function RoleBook_Node:initUI(ui)
	self.super.initUI(self,ui)


    self.Num    = 0
    self.maxNum = 0


    self.txt_num        = TFDirector:getChildByPath(ui, 'txt_num')
    self.img_quality    = TFDirector:getChildByPath(ui, 'img_quality')
    self.img_equip      = TFDirector:getChildByPath(ui, 'img_equip')
    self.btn_chongzhi   = TFDirector:getChildByPath(ui, 'btn_chongzhi')
    self.btn_chongzhi.logic = self
    self.img_quality.logic = self

end

function RoleBook_Node:registerEvents(ui)
    self.super.registerEvents(self)


end


function RoleBook_Node:removeEvents()
    self.super.removeEvents(self)

end


function RoleBook_Node:setBookInfo(id, num)
    local bagItem = BagManager:getItemById(id)
    if bagItem == nil then
        print("该道具不存在背包 id =="..id)
        return
    end
    self.bagItem    = bagItem
    self.maxnum     = bagItem.num
    self:changeNum(num)
    -- print(bagItem.name .. " : ".. bagItem.num)
    print("bagItem.quality = ", bagItem.quality)
    if self.itemid ~= id then
        self.itemid = id

        local bgPic   = getBookBackgroud(bagItem.quality)
        self.img_quality:setTextureNormal(bgPic)
        self.img_equip:setTexture(bagItem:GetPath())
    end

end

function RoleBook_Node:changeNum( num )
    self.num = num
    if num == 0 then
        self.txt_num:setVisible(true)
        self.txt_num:setText(self.maxnum)
        self.btn_chongzhi:setVisible(false)
    else
        self.txt_num:setVisible(true)
        self.btn_chongzhi:setVisible(true)
        self.txt_num:setText(self.num .."/".. self.maxnum)
    end
    self.img_quality:addMEListener(TFWIDGET_CLICK, audioClickfun(self.IconBtnClickHandle))

    self.img_quality:addMEListener(TFWIDGET_TOUCHBEGAN, self.IconBtnTouchBeganHandle)
    self.img_quality:addMEListener(TFWIDGET_TOUCHMOVED, self.IconBtnTouchMovedHandle)
    self.img_quality:addMEListener(TFWIDGET_TOUCHENDED, self.IconBtnTouchEndedHandle)

 
    self.btn_chongzhi:addMEListener(TFWIDGET_CLICK, audioClickfun(self.DelBtnClickHandle))
    -- self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHBEGAN, self.DelBtnTouchBeganHandle)
    -- self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHMOVED, self.DelBtnTouchMovedHandle)
    -- self.btn_chongzhi:addMEListener(TFWIDGET_TOUCHENDED, self.DelBtnTouchEndedHandle)
end

function RoleBook_Node.IconBtnClickHandle(sender)
    local self = sender.logic

    if self.num >= self.maxnum then
        return
    end

    self:addBook(self ,1)

end

function RoleBook_Node.IconBtnTouchBeganHandle(sender)
    local self = sender.logic
    local times = 1
    local function onLongTouch()
        if self.num >= self.maxnum then
            return
        end

        self.isAdd = true

        local isConLongTouch = self:addBook(self, 1, true)
        TFDirector:removeTimer(self.longAddTouchTimerId)
        
        if isConLongTouch then
            if times < 6 then
                self.longAddTouchTimerId = TFDirector:addTimer(200, 1, nil, onLongTouch)
            else
                self.longAddTouchTimerId = TFDirector:addTimer(50, 1, nil, onLongTouch)
            end
            times = times + 1
        end
    end
    self.longAddTouchTimerId = TFDirector:addTimer(300, 1, nil, onLongTouch)
end

function RoleBook_Node.IconBtnTouchMovedHandle(sender)
    local self = sender.logic

    local v = ccpSub(sender:getTouchStartPos(), sender:getTouchMovePos())
    if v.y > 15 or v.y < -15 then
        TFDirector:removeTimer(self.longAddTouchTimerId)
    end

end

function RoleBook_Node.IconBtnTouchEndedHandle(sender)
    local self = sender.logic
    if (self.longAddTouchTimerId) then
        TFDirector:removeTimer(self.longAddTouchTimerId)
        self.longAddTouchTimerId = nil
    end

    if self.isAdd then
        -- self.logic:showAddCatFoodFly( self.id , self )
    end
    self.isAdd = false
end


function RoleBook_Node.DelBtnClickHandle(sender)
    local self = sender.logic
    if self.num == 0 then
        return
    end

    self.detelegate:RmoveBook(self)
end


function RoleBook_Node:addBook(book, addNum, bLongPress)
    if self.detelegate then
        local bookid = book.id
        return self.detelegate:AddBook(book, addNum, bLongPress)
    end

    return false
end

function RoleBook_Node:setDetelegate( logic )
    self.detelegate = logic
end

return RoleBook_Node
 