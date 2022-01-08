--[[
******角色详情*******
    -- by king
    -- 2015/4/17
]]

local RoleBook_Enchant = class("RoleBook_Enchant", BaseLayer)

-- local bookLevelDesc = {"普通","高级","专家","宗师","传说"}
local bookLevelDesc = EnumBookDescType

function RoleBook_Enchant:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.role_new.RoleBookLearn")
end

function RoleBook_Enchant:loadData(cardrole, bookIndex)
    self.firstDraw = true

    self.cardRole   = cardrole
    self.bookIndex  = bookIndex


    self.roleGmid   = cardrole.gmId

    -- 右边的区域是否显示 false 为隐藏
    self.rightAreaHide = false
end

function RoleBook_Enchant:onShow()
    self.super.onShow(self)


    self:refreshUI()
end

function RoleBook_Enchant:refreshUI()
    if not self.isShow then
        return
    end

    self.cardRole     = CardRoleManager:getRoleByGmid(self.roleGmid)
    self.bookOwnList  = BagManager:getItemByType(EnumGameItemType.Book)

    for i=30029, 30032 do
        local bagItem = BagManager:getItemById(i)
        print("id =", i)
            -- print("bagItem = ", bagItem)
        if bagItem and bagItem.num > 0 then
            print("bagItem.num = ", bagItem.num)
            -- self.bookOwnList:pushFront(bagItem)
            self.bookOwnList:insertAt(1, bagItem)
        end
    end

    local function soulcmp( soul1, soul2 )
            -- print("soul1 = ", soul1)
            -- print("soul2 = ", soul2)
            if soul1.type > soul2.type then
               return true
            end

            if soul1.kind == 4 and  soul2.kind == 4 then
                if soul1.quality <= soul2.quality then
                    return true;
                else
                    return false;
                end
            end

            if soul1.kind == 3 and soul2.kind ~= 3 then
                return true;
            elseif soul1.kind ~= 3 and  soul2.kind == 3 then
                return false;
            elseif soul1.kind == 3 and  soul2.kind == 3 then
                if soul1.quality <= soul2.quality then
                    return true;
                else
                    return false;
                end
            elseif soul1.quality <= soul2.quality then
                if soul1.id <= soul2.id then
                    return true
                end
                return true
            else
                return false
            end
    end

    self.bookOwnList:sort(soulcmp)

    self:setOriginalPosition()
    self:drawLeftArea()
    self:drawRightArea()
    self:drawList()
end

function RoleBook_Enchant:initUI(ui)
	self.super.initUI(self,ui)

    -- 勤学苦练
    self.img_qx_diag        = TFDirector:getChildByPath(ui, 'img_qx_diag')
    self.btn_qxkl           = TFDirector:getChildByPath(ui, 'btn_qxkl')
    self.btn_qxkl.logic     = self
    self.txt_bookname       = TFDirector:getChildByPath(ui, 'txt_bookname')
    self.txt_booklevel      = TFDirector:getChildByPath(ui, 'txt_booklevel')
    self.img_bookQuality    = TFDirector:getChildByPath(self.img_qx_diag, 'img_quality')
    self.img_equip          = TFDirector:getChildByPath(ui, 'img_equip')
    self.txt_bookdesc       = TFDirector:getChildByPath(ui, 'txt_bookdesc')

    self.img_bookQuality:setTouchEnabled(false)

    -- 属性描述
    self.node_AttributeList     = {}
    self.txt_AttributeNameList  = {}
    self.txt_AttributeValueList = {}
    for i=1,5 do
        self.node_AttributeList[i]          =  TFDirector:getChildByPath(ui, "panel_att" .. i)
        self.txt_AttributeNameList[i]       =  TFDirector:getChildByPath(self.node_AttributeList[i],"name")
        self.txt_AttributeValueList[i]      =  TFDirector:getChildByPath(self.node_AttributeList[i],"value")
        self.txt_AttributeValueList[i]:setColor(ccc3(0, 255, 0))
        self.node_AttributeList[i]:setVisible(false)
    end

    self.starList = {}
    for i=1,5 do
        self.starList[i]       = TFDirector:getChildByPath(ui, 'img_star'..i)
    end

    -- 右边的元素
    self.img_fumodiag  = TFDirector:getChildByPath(ui, 'img_fumodiag')
    self.img_fumodiag:setVisible(false)
    self:initRightArea(ui)


    -- 背包里面的书
    -- self.bookOwnList       = BagManager:getItemByType(EnumGameItemType.Book)

    -- print("bookList1 = ",self.bookOwnList)
    -- 要吞噬的书
    self.ChoosedList    = TFArray:new()



    -- 附魔相关
    self.ExpectedEnchantProgress        = 0  -- 附魔预期总经验
    self.ExpectedEnchantProgress_Remain = 0  -- 附魔之后剩余的经验
    self.ExpectedEnchantLevel           = 0  -- 附魔预期的等级

end

function RoleBook_Enchant:registerEvents(ui)
    self.super.registerEvents(self)

    self.btn_qxkl:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnQXKLClickHandle))
    self.btn_qx:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnQinXueClickHandle))
    self.btn_yjqx:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnYiJianQinXueClickHandle))


    self.MartialEnchantEventCallBak = function(event)
        --toastMessage("苦练成功")
        toastMessage(localizable.roleBook_enchant_kulian)
        self.ChoosedList:clear()
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(MartialManager.MSG_MartialEnchant ,self.MartialEnchantEventCallBak)
end


function RoleBook_Enchant:removeEvents()
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(MartialManager.MSG_MartialEnchant, self.MartialEnchantEventCallBak )
    self.MartialEnchantEventCallBak = nil
end


function RoleBook_Enchant.BtnQXKLClickHandle(sender)
    local self = sender.logic;
    if self.rightAreaHide == false then
        self:drawLeftArea()
        self:drawRightArea()
        self:resetPosition()
        self.rightAreaHide = true

        self.btn_qxkl:setTouchEnabled(not self.rightAreaHide)
        self.btn_qxkl:setGrayEnabled(self.rightAreaHide)
        self.img_fumodiag:setVisible(self.rightAreaHide)
    end
end


function RoleBook_Enchant:drawLeftArea()
  
    -- 武学等级
    local martialLevel = self.cardRole.martialLevel
    local martialList  = self.cardRole.martialList

    local bookIndex    = self.bookIndex

    local bookList     = MartialRoleConfigure:findByRoleIdAndMartialLevel(self.cardRole.id, martialLevel):getMartialTable()

    local bookInfo     = MartialData:objectByID(bookList[bookIndex])

    local bgPic        = getBookBackgroud(bookInfo.goodsTemplate.quality)
    local martialInstance = self.cardRole.martialList[bookIndex]


    print("RoleBook_Enchant:drawLeftArea martialInstance.enchantLevel = ", martialInstance.enchantLevel)
    self.txt_bookname:setText(bookInfo.goodsTemplate.name)
    -- self.txt_booklevel:setText(martialInstance.enchantLevel)
    self.txt_bookdesc:setText(bookInfo.goodsTemplate.details)
    self.img_bookQuality:setTextureNormal(bgPic)
    self.img_equip:setTexture(bookInfo.goodsTemplate:GetPath())

    
    if martialInstance.enchantLevel > 0 then
        self.txt_booklevel:setVisible(true)

        self.txt_booklevel:setText(bookLevelDesc[martialInstance.enchantLevel])
    else
        self.txt_booklevel:setVisible(false)
    end

    -- 绘制属性
    if 1 then
        local Attribute = bookInfo:getAttributeTable()
        local count = 0
        for i=1,EnumAttributeType.Max do
            if Attribute[i] then
                count = count + 1
                
                local attName  = AttributeTypeStr[i]
                local attValue = Attribute[i]
                local addValue = attValue * 0.1 * martialInstance.enchantLevel
                -- print("属性 ---", count)
                -- print(attName .. " = ", attValue)
                -- self.txt_AttributeNameList[count]:setText(attName)
                -- self.txt_AttributeValueList[count]:setText("+"..attValue .. " + " .. addValue)
                self.txt_AttributeNameList[count]:setText(attName.." +"..attValue)
                self.txt_AttributeValueList[count]:setText(" +" .. math.floor(addValue))

                if addValue > 0 then
                    self.txt_AttributeValueList[count]:setVisible(true)
                else
                    self.txt_AttributeValueList[count]:setVisible(false)
                end

                self.node_AttributeList[count]:setVisible(true)
            end
        end
        -- return
    end

    -- 绘制星级
    for i=1,5 do
        local star = self.starList[i]
        if star then
            if martialInstance.enchantLevel >= i then
                star:setVisible(true)
            else
                star:setVisible(false)
            end

        end
    end
end


function RoleBook_Enchant:drawRightArea()
    local martialLevel = self.cardRole.martialLevel
    local martialList  = self.cardRole.martialList

    local bookIndex    = self.bookIndex

    local bookList     = MartialRoleConfigure:findByRoleIdAndMartialLevel(self.cardRole.id, martialLevel):getMartialTable()

    -- local bookInfo     = MartialData:objectByID(bookList[bookIndex])

    local bookInfo        = ItemData:objectByID(bookList[bookIndex])
    local bgPic           = getBookBackgroud(bookInfo.quality)

    local martialInstance = self.cardRole.martialList[bookIndex]
    local img_bgtilte  = TFDirector:getChildByPath(self.img_fumodiag, "img_bgtilte")
    local img_quality  = TFDirector:getChildByPath(img_bgtilte, "img_quality")
    local img_equip    = TFDirector:getChildByPath(img_bgtilte, "img_equip")
    local txt_booklevel= TFDirector:getChildByPath(img_bgtilte, 'txt_booklevel')


    local txt_expdesc  = TFDirector:getChildByPath(img_bgtilte, "txt_expdesc")
    local txt_manji    = TFDirector:getChildByPath(img_bgtilte, 'txt_manji')
    local txt_expadd   = TFDirector:getChildByPath(img_bgtilte, 'txt_expadd')
    local bar_exp      = TFDirector:getChildByPath(img_bgtilte, 'bar_exp')

    local bgPic        = getBookBackgroud(bookInfo.quality)

    img_quality:setTextureNormal(bgPic)
    img_equip:setTexture(bookInfo:GetPath())

    -- txt_booklevel:setText("等级"..martialInstance.enchantLevel)
    txt_booklevel:setText(bookLevelDesc[martialInstance.enchantLevel])

    -- 
    if martialInstance.enchantLevel > 0 then
        txt_booklevel:setVisible(true)
    
    -- 没有附魔过
    else
        txt_booklevel:setVisible(false)
    end

    -- 是否满级
    local MartialList   = MartialEnchant:findByLevel(bookInfo.quality)

    -- print("RoleBook_Enchant:drawRightArea martialInstance = ",  martialInstance)
    -- print("RoleBook_Enchant:drawRightArea MartialList     = ",  MartialList)
    -- 计算等级是否超出
    if MartialList.maxLevel <= martialInstance.enchantLevel then
        -- MartialList.config
        bar_exp:setPercent(100)
        txt_manji:setVisible(true)
        --txt_manji:setText("已满级")
        txt_manji:setText(localizable.roleBook_enchant_max_level)        
        txt_expadd:setVisible(false)
        txt_expdesc:setVisible(false)

    -- 还没有满级
    else
        local needInfo = MartialList.config[martialInstance.enchantLevel + 1]
        bar_exp:setPercent((martialInstance.enchantProgress/needInfo.exp) * 100)
        txt_manji:setVisible(false)
        txt_expadd:setVisible(true)
        txt_expadd:setText("+0")
        txt_expdesc:setVisible(true)
        txt_expdesc:setText(martialInstance.enchantProgress.. " / " .. needInfo.exp)
    end

    img_quality:setTouchEnabled(false)
    img_equip:setScale(0.7)

    self.martialInstance             = martialInstance
    self.ExpectedEnchantProgress     = 0 --martialInstance.enchantProgress
    self.ExpectedEnchantProgressUsed = 0
    self.bookquality                 = bookInfo.quality
    self:RedrawCostTongYuanbao()
end

function RoleBook_Enchant:setOriginalPosition()

    if self.rightAreaHide == true then
        return
    end

    -- 居中
    local parent        = self.img_qx_diag:getParent()
    local sizeParent    = parent:getContentSize()
    local sizeImage     = self.img_qx_diag:getContentSize()
    local pos           = self.img_qx_diag:getPosition()

    local x = sizeParent.width/2
    local y = sizeParent.height/2

    self.img_qx_diag:setPosition(ccp(x,y))
    self.img_fumodiag:setPosition(ccp(x,y))
end

function RoleBook_Enchant:resetPosition()

    -- 居中
    local parent        = self.img_qx_diag:getParent()
    local sizeParent    = parent:getContentSize()
    local sizeImage     = self.img_qx_diag:getContentSize()
    local pos           = self.img_qx_diag:getPosition()

    local center_x = sizeParent.width/2
    local center_y = sizeParent.height/2
    local gap      = 20 -- 两个框的间隔


    local left_x   = center_x - gap / 2 - sizeImage.width / 2
    local right_x  = center_x + gap / 2 + sizeImage.width / 2

    -- self.img_qx_diag:setPosition(ccp(left_x,center_y))
    -- self.img_fumodiag:setPosition(ccp(right_x,center_y))

    -- 开启动画
    self:moveArea(self.img_qx_diag, ccp(left_x,center_y))
    self:moveArea(self.img_fumodiag, ccp(right_x,center_y))
end


function RoleBook_Enchant:moveArea(target_, toPos)
    local toastTween = {
      target = target_,
      {
        duration = 0.5,
        x = toPos.x,
        y = toPos.y
      },
      {
        duration = 0,
        onComplete = function() 
       end
      }
    }

TFDirector:toTween(toastTween);
end

function RoleBook_Enchant:initRightArea(ui)
    self.panel_list = TFDirector:getChildByPath(ui, 'panel_list')
    self.btn_qx     = TFDirector:getChildByPath(ui, 'btn_qx')
    self.btn_yjqx   = TFDirector:getChildByPath(ui, 'btn_yjqx')
    self.btn_qx.logic = self
    self.btn_yjqx.logic = self
end


function RoleBook_Enchant:drawList()
    local bookNum = self.bookOwnList:length()
    self.RowNum  = math.ceil(bookNum/3)
    self.BookNum = bookNum

    print("书的总数 = ", bookNum)
    print("列表行数 = ", self.RowNum)
    if self.tableView ~= nil then
        self.tableView:reloadData()
        self.tableView:setScrollToBegin(false)
        return
    end

    local  tableView =  TFTableView:create()
    tableView:setTableViewSize(self.panel_list:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLVERTICAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
    tableView:setPosition(ccp(0,0))
    self.tableView = tableView
    self.tableView.logic = self


    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, RoleBook_Enchant.cellSizeForTable)
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, RoleBook_Enchant.tableCellAtIndex)
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, RoleBook_Enchant.numberOfCellsInTableView)
    tableView:reloadData()

    -- self:addChild(self.tableView,1)
    self.panel_list:addChild(self.tableView,1)
end

function RoleBook_Enchant.cellSizeForTable(table, idx)
    return 100, 300
end

function RoleBook_Enchant.tableCellAtIndex(table, idx)
    local self = table.logic
    local cell = table:dequeueCell()
    local node = nil
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true

        for i=1,3 do
            -- local sign_node = createUIByLuaNew("lua.uiconfig_mango_new.role_new.booknode")
            local book_panel = require('lua.logic.rolebook.RoleBook_Node'):new()
            book_panel:setPosition(ccp((i-1)*100 + 10, 0))
            cell:addChild(book_panel)
            book_panel:setTag(100+i)
        end
    end

    --绘制每个节点
    for i=1,3 do
        local node = cell:getChildByTag(100+i)
        local WuXuePiceIndex = idx*3 + i
        node.WuXuePiceIndex  = WuXuePiceIndex
        local isVsible = false
        if WuXuePiceIndex > self.BookNum then
        else
            isVsible = true

            self:drawNode(node, WuXuePiceIndex)
        end

        node:setVisible(isVsible)
    end
    return cell
end

function RoleBook_Enchant.numberOfCellsInTableView(table)
    local self = table.logic

    return self.RowNum
end

function RoleBook_Enchant:drawNode(booknode, WuXuePiceIndex)

    local bookData = self.bookOwnList:objectAt(WuXuePiceIndex)

    booknode:setDetelegate(self)
    local book = self:findBookInChoosed(bookData.id)
    if book then
        booknode:setBookInfo(book.id ,book.num)
    else
        booknode:setBookInfo(bookData.id , 0)
    end
end

function RoleBook_Enchant.BtnQinXueClickHandle(sender)
    local  self = sender.logic
    local materials = {}
    local temp = 1
    local num  = 0
    local isHaveQualityJia = false

    for v in self.ChoosedList:iterator() do
        local tbl = {
            v.id,
            v.num
        }
        materials[temp] = tbl
        temp = temp + 1

        num  = v.num + num

        local item = ItemData:objectByID(v.id);
        if item.quality == QUALITY_JIA and item.type == 8 then
            isHaveQualityJia = true;
        end
    end

    if num > 0 then
        if isHaveQualityJia then
            CommonManager:showOperateSureLayer(
                function()
                    -- self.costTb = 100000000
                    if MainPlayer:isEnoughCoin(self.costTb, true) then
                        MartialManager:requestMartialEnchant(self.martialInstance, materials)
                        TFAudio.playEffect("sound/effect/chuangong-hunpoyidong.mp3",false)
                    end
                end,
                nil,
                {
                --msg =  "吞噬的秘籍中，存在甲品质的秘籍，若继续吞噬则这些秘籍将转换为经验值。\n是否确定继续传功？"
                msg =  localizable.roleBook_enchant_tips1,
                }
            )

        else
            -- self.costTb = 100000000
            if MainPlayer:isEnoughCoin(self.costTb, true) then
                MartialManager:requestMartialEnchant(self.martialInstance, materials)
                TFAudio.playEffect("sound/effect/chuangong-hunpoyidong.mp3",false)
            end
        end
    else
        --toastMessage("你还没有选择合成材料")
        toastMessage(localizable.roleBook_enchant_not_check)
    end
    
end

function RoleBook_Enchant.BtnYiJianQinXueClickHandle(sender)
    local self = sender.logic
    local num  = 0

    -- 判断是否已经是最高等级了

    local level         = self.bookquality--self.cardRole.martialLevel
    local MartialList   = MartialEnchant:findByLevel(level)

    local userVip =  MainPlayer:getVipLevel()
    local needVip =  VipData:getMinLevelDeclear(4000)

    if needVip and userVip < needVip then
        local msg =  stringUtils.format(localizable.vip_yiJianQianXue_not_enough,needVip);
        CommonManager:showOperateSureLayer(
                function()
                    PayManager:showPayLayer();
                end,
                nil,
                {
                --title = "提升VIP",
                title = localizable.common_vip_up,
                msg = msg,
                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                }
        )
        return
    end

    -- 计算等级是否超出
    if MartialList.maxLevel <= self.martialInstance.enchantLevel then
        --toastMessage("已经是最高等级，不能再勤学了")
        toastMessage(localizable.roleBook_enchant_max_qinxue)
        return
    end

    for v in self.bookOwnList:iterator() do
        num  = v.num + num
    end

    num  = 1
    if num > 0 then
        -- self.costYb = 10000000
        --local msg = "是否消耗"..self.costYb.."元宝进行一键勤学"
        local msg = stringUtils.format(localizable.roleBook_enchant_yijian,self.costYb)
        CommonManager:showOperateSureLayer(
            function()
                if MainPlayer:isEnoughSycee(self.costYb, true) then
                    local level         = self.cardRole.martialLevel
                    local curExp        = self.martialInstance.enchantProgress
                    MartialManager:requestMartialEnchantOneKey(self.martialInstance.roleId, self.martialInstance.position)
                    TFAudio.playEffect("sound/effect/chuangong-hunpoyidong.mp3",false)
                end
            end,
            function()
                AlertManager:close()
            end,
            {
            --title = "一键勤学",
            title = localizable.roleBook_enchant_yijian_tips,
            msg = msg,
            }
        )
    else
        --toastMessage("没有足够的书用于合成")
        toastMessage(localizable.roleBook_enchant_hecheng)
    end

end

function RoleBook_Enchant:findBookInChoosed(id)
    for v in self.ChoosedList:iterator() do
        if v.id == id then
            return v
        end
    end
end

function RoleBook_Enchant:AddBook(booknode, addNum, bLongPress)
    local bookid = booknode.itemid
    local book   = self:findBookInChoosed(bookid)
    if not book then
        book = {}
        book.id  = bookid
        book.num = 0
        self.ChoosedList:pushBack(book)
    end

    -- 
    local isConLongTouch = true

    local level         = self.bookquality--self.cardRole.martialLevel
    local MartialList   = MartialEnchant:findByLevel(level)

    -- 计算等级是否超出
    if MartialList.maxLevel <= self.martialInstance.enchantLevel then
        --toastMessage("已经是最高等级")
        toastMessage(localizable.roleBook_enchant_out_level)
        return false
    end

    if self.ExpectedEnchantLevel == MartialList.maxLevel then
        --toastMessage("已经达到最高等级")
        toastMessage(localizable.roleBook_enchant_out_level)
        return false
    end

    -- 该物品包含的经验
    local exp = booknode.bagItem.itemdata.provide_exp
    -- print("book = ", booknode.bagItem)
    self:UpdateEnchantExp(exp)

    book.num = book.num + 1

    booknode:changeNum(book.num)

    self:RedrawTopArea()

    -- local icon = booknode
    -- local pos  = icon:getParent():convertToWorldSpace(ccp(icon:getPosition().x - 25,icon:getPosition().y + 55))
    -- self:showFly(nil, pos)
    return isConLongTouch
end

function RoleBook_Enchant:RmoveBook(booknode)
    local id = booknode.itemid
    local item = ItemData:objectByID(id)
    if item == nil then
        print("该卡牌不存在 id =="..id)
        return
    end

    local book = self:findBookInChoosed(id)

    -- 属性的变化
    -- 该物品包含的经验
    local exp = booknode.bagItem.itemdata.provide_exp
    -- print("book = ", booknode.bagItem)
    self:UpdateEnchantExp(-exp)

    book.num = book.num - 1
    if book.num <= 0 then
        self.ChoosedList:removeObject(book)
    end


    booknode:changeNum(book.num)

    self:RedrawTopArea()

    --     local icon = booknode
    -- local pos  = icon:getParent():convertToWorldSpace(ccp(icon:getPosition().x - 25,icon:getPosition().y + 55))
    -- self:showFlyBack(nil, pos)
end

-- 更新预期的经验值
function RoleBook_Enchant:UpdateEnchantExp(exp)

    local level         = self.cardRole.martialLevel
    local curExp        = self.martialInstance.enchantProgress
    local bookLevel     = self.martialInstance.enchantLevel
    local MartialList   = MartialEnchant:findByLevel(self.bookquality)

    print("level",      level)
    print("bookLevel",  bookLevel)
    print("curExp",     curExp)
    -- print("MartialList", MartialList)

    print("增加这本书之前的经验 ：", self.ExpectedEnchantProgress)
    print("即将吞掉的经验值     ：", exp)
    -- 计算总的
    self.ExpectedEnchantProgress = self.ExpectedEnchantProgress + exp

    print("增加这本书的经验     ：", self.ExpectedEnchantProgress)
    if self.ExpectedEnchantProgress <= 0 then
        self.ExpectedEnchantProgress = 0
        print("去除经验--------")
        
        self.ExpectedEnchantLevel           = bookLevel     -- 附魔预期的等级
        self.ExpectedEnchantProgress_Remain = curExp         -- 附魔
        self.ExpectedEnchantProgressUsed    = 0
        return
    end

-- ├┄┄level=3,
-- ├┄┄enchant_level=3,
-- ├┄┄exp=120
    
    local needTotalExp  = 0
    local enchant_level = bookLevel
    local expRemain = self.ExpectedEnchantProgress + curExp 
    for i,v in ipairs(MartialList.config) do

        if bookLevel < v.enchant_level then
            print("升级第".. v.enchant_level .. "级")
            print("当前还有的经验： ", expRemain)
            print("升级所需经验  ： ", v.exp)
            local expRemain_ext = expRemain - v.exp
            if expRemain_ext >= 0 then
                enchant_level = v.enchant_level
                expRemain = expRemain_ext

                needTotalExp = needTotalExp + v.exp
            end
        end
    end

    
    self.ExpectedEnchantLevel           = enchant_level     -- 附魔预期的等级
    self.ExpectedEnchantProgress_Remain = expRemain         -- 附魔

    self.ExpectedEnchantProgressUsed = self.ExpectedEnchantProgress + 0
    -- 达到最高等级的时候 对余下的经验的处理
    if enchant_level == MartialList.maxLevel then

        print("已经达到最高等级,余下的经验 : ".. self.ExpectedEnchantProgress_Remain .. " 将被清空")

        self.ExpectedEnchantProgress_Remain = 0
        -- 实际用到的经验
        self.ExpectedEnchantProgressUsed = self.ExpectedEnchantProgress + 0 - expRemain
    end

    print("最高可以到达等级   ： ", MartialList.maxLevel)
    print("---------------------------------------------")
    print("当前等级           ： ", self.martialInstance.enchantLevel)
    print("预期可以达到的等级 ： ", self.ExpectedEnchantLevel)
    print("升级选中总经验     :  ", self.ExpectedEnchantProgress)
    print("升级需要使用的经验 :  ", self.ExpectedEnchantProgressUsed)
    print("余下的经验         :  ", self.ExpectedEnchantProgress_Remain)

end


function RoleBook_Enchant:RedrawTopArea()
    local img_bgtilte  = TFDirector:getChildByPath(self.img_fumodiag, "img_bgtilte")
    local txt_booklevel= TFDirector:getChildByPath(img_bgtilte, 'txt_booklevel')

    -- txt_booklevel:setText("预期等级:"..self.ExpectedEnchantLevel)

    txt_booklevel:setText(bookLevelDesc[self.ExpectedEnchantLevel])
    if self.ExpectedEnchantLevel > 0 then
        txt_booklevel:setVisible(true)
    else
        txt_booklevel:setVisible(false)
    end

    local txt_expdesc  = TFDirector:getChildByPath(img_bgtilte, "txt_expdesc")
    local txt_manji    = TFDirector:getChildByPath(img_bgtilte, 'txt_manji')
    local txt_expadd   = TFDirector:getChildByPath(img_bgtilte, 'txt_expadd')
    local bar_exp      = TFDirector:getChildByPath(img_bgtilte, 'bar_exp')


    -- local martialLevel  = self.cardRole.martialLevel
    local MartialList   = MartialEnchant:findByLevel(self.bookquality)
    print("MartialList = ", MartialList)

    local expectLevel   = self.ExpectedEnchantLevel


    -- 计算等级是否超出
    if MartialList.maxLevel <= expectLevel then
        -- MartialList.config
        bar_exp:setPercent(100)
        txt_manji:setVisible(true)
        --txt_manji:setText("已满级")
        txt_manji:setText(localizable.roleBook_enchant_max_level)
        txt_expadd:setVisible(false)
        txt_expdesc:setVisible(false)

    -- 还没有满级
    else

        -- if expectLevel == 0 then
        --     expectLevel = 1
        -- end
        -- 获取下一等级需要的相关数据
        expectLevel = expectLevel + 1

        local needInfo = MartialList.config[expectLevel]
        bar_exp:setPercent((self.ExpectedEnchantProgress_Remain/needInfo.exp) * 100)
        txt_manji:setVisible(false)
        txt_expadd:setVisible(true)
        txt_expadd:setText("+"..(self.ExpectedEnchantProgressUsed-0))
        txt_expdesc:setVisible(true)
        txt_expdesc:setText(self.ExpectedEnchantProgress_Remain.. " / " .. needInfo.exp)
    end

    self:RedrawCostTongbi()
end

function RoleBook_Enchant:RedrawCostTongbi()

    local addExp = self.ExpectedEnchantProgressUsed--self.martialInstance.enchantProgress

    local needTb = addExp * 100

    -- local needYb = addExp * 1

    local txt_cost_tb   = TFDirector:getChildByPath(self.img_fumodiag, 'txt_cost_tb')

    txt_cost_tb:setText(needTb)

    self.costTb = needTb
end

function RoleBook_Enchant:RedrawCostTongYuanbao()
    local level         = self.cardRole.martialLevel
    local curExp        = self.martialInstance.enchantProgress
    local MartialList   = MartialEnchant:findByLevel(self.bookquality)

    local needTotalExp  = 0
    for i,v in ipairs(MartialList.config) do
        -- if v.level > self.martialInstance.enchantLevel then
        if v.enchant_level > self.martialInstance.enchantLevel then
            needTotalExp = needTotalExp + v.exp
        end
    end


    local ownCurExp  = curExp
    -- for i,v in ipairs(MartialList.config) do
    --     if v.enchant_level <= self.martialInstance.enchantLevel then
    --         ownCurExp = ownCurExp + v.exp
    --     end
    -- end
    -- print("self.bookquality = ", self.bookquality)
    -- print("self.martialInstance.enchantLevel = ", self.martialInstance.enchantLevel)
    -- print('MartialList.config = ',MartialList.config)
    -- print("ownCurExp = ", ownCurExp)
    -- -- print("MartialList = ", MartialList)
    -- print("needTotalExp1 = ", needTotalExp)
    -- -- needTotalExp = needTotalExp - curExp
    if needTotalExp > 0 then 
        needTotalExp = needTotalExp - ownCurExp
    end

    -- print("curExp = ", curExp)
    -- print("needTotalExp2 = ", needTotalExp)

    local needYb = needTotalExp * 1

    local txt_cost_yb   = TFDirector:getChildByPath(self.img_fumodiag, 'txt_cost_yb')

    txt_cost_yb:setText(needYb)

    self.costYb = needYb
end

function RoleBook_Enchant:showFly( texture , pos)

    if not self.flyPic then
        play_chuangonghunpoyidong()

        local resPath = "effect/role_transfer_begin.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local flyPic = TFArmature:create("role_transfer_begin_anim")

        flyPic:setAnimationFps(GameConfig.ANIM_FPS)
        flyPic:setPosition(ccp(pos))
        flyPic:setScale(0.5)
        self:addChild(flyPic,100)
        flyPic:playByIndex(0, -1, -1, 1)
        self.flyPic = flyPic
        -- flyPic:addMEListener(TFARMATURE_COMPLETE,function()
        --     flyPic:removeMEListener(TFARMATURE_COMPLETE) 
        --     flyPic:removeFromParent()
        -- end)
        
        self.img_role = TFDirector:getChildByPath(self.img_fumodiag, "img_bgtilte")
        local topos = self.img_role:getParent():convertToWorldSpace(ccp(self.img_role:getPosition().x + 280,self.img_role:getPosition().y - self.img_role:getContentSize().height/2  + 300))
        topos = self:convertToNodeSpace(topos);

        local tox = topos.x
        local toy = topos.y
        local tween = 
        {
            target = flyPic,
            {
                ease = {type=TFEaseType.EASE_IN_OUT, rate=9},
                duration = 0.6,
                x = tox,
                y = toy,
                onComplete = function ()
             
                    local resPath = "effect/role_transfer_end.xml"
                    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                    local endPic = TFArmature:create("role_transfer_end_anim")

                    endPic:setAnimationFps(GameConfig.ANIM_FPS)
                    endPic:setPosition(ccp(tox,toy))

                    self:addChild(endPic,100)
                    
                    endPic:addMEListener(TFARMATURE_COMPLETE,function()
                        endPic:removeMEListener(TFARMATURE_COMPLETE) 
                        endPic:removeFromParent()
                    end)
                    endPic:playByIndex(0, -1, -1, 0)

                    flyPic:removeFromParentAndCleanup(true)
                    self.flyPic = nil  
                end,
            },
        }
        TFDirector:toTween(tween)
    end
end

function RoleBook_Enchant:showFlyBack( texture , pos)
    if not self.flyPic then
        play_chuangonghunpoyidong()

        self.img_role = TFDirector:getChildByPath(self.img_fumodiag, "img_bgtilte")
        local frompos = self.img_role:getParent():convertToWorldSpace(ccp(self.img_role:getPosition().x + 280,self.img_role:getPosition().y - self.img_role:getContentSize().height/2  + 300))
        frompos = self:convertToNodeSpace(frompos);

        local fromx = frompos.x
        local fromy = frompos.y

        local resPath = "effect/role_transfer_begin.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local flyPic = TFArmature:create("role_transfer_begin_anim")

        flyPic:setAnimationFps(GameConfig.ANIM_FPS)
        flyPic:setPosition(ccp(fromx,fromy))

        self:addChild(flyPic,100)
        flyPic:playByIndex(0, -1, -1, 1)
        self.flyPic = flyPic;  
        -- flyPic:addMEListener(TFARMATURE_COMPLETE,function()
        --     flyPic:removeMEListener(TFARMATURE_COMPLETE) 
        --     flyPic:removeFromParent()
        -- end)
        
        local tween = 
        {
            target = flyPic,
            {
                ease = {type=TFEaseType.EASE_IN_OUT, rate=8},
                duration = 0.4,
                x = pos.x,
                y = pos.y,
                onComplete = function ()
                    flyPic:removeFromParentAndCleanup(true)
                    flyPic = nil    
                    self.flyPic = nil           
                end,
            },
        }
        TFDirector:toTween(tween)
    end
end


return RoleBook_Enchant
 