--[[
    精要物品界面的精要icon,不可累加
]]

local NewJingyaoIcon = class("NewJingyaoIcon", BaseLayer)

NewJingyaoIcon.TYPE_UNEQUIPPED = 1
NewJingyaoIcon.TYPE_EQUIPPED = 2

function NewJingyaoIcon:ctor(id)
    self.super.ctor(self, id)
    self.id = id
    self.type = nil
    self.item = nil
    self:init("lua.uiconfig_mango_new.tianshu.JingYaoIcon")
end

function NewJingyaoIcon:initUI(ui)
	self.super.initUI(self, ui)

    --空白panel
    self.panel_empty = TFDirector:getChildByPath(ui, "panel_empty")
    --info panel
    self.panel_info = TFDirector:getChildByPath(ui, "panel_info")

    --点击按钮
    self.btn_icon = TFDirector:getChildByPath(ui, "btn_icon")
    self.btn_icon.logic = self
    --品质图标
	self.img_quality = TFDirector:getChildByPath(ui, 'img_quality')
    --精要icon图标
	self.img_icon  = TFDirector:getChildByPath(ui, 'img_icon')
    --名字
    self.txt_name = TFDirector:getChildByPath(ui, 'txt_name')
    --数量
    self.txt_num = TFDirector:getChildByPath(ui, "txt_num")

    --配标志
    self.img_pei = TFDirector:getChildByPath(ui, "img_pei")
    self.img_equiped = TFDirector:getChildByPath(ui, "img_equiped")
    --装备天书名
    -- self.txt_equipped_name = TFDirector:getChildByPath(self.img_pei, "txt_equiped_name")

    --选中框
    --self.img_selected = TFDirector:getChildByPath(ui, "img_selected_bg")

    self.img_selected = TFDirector:getChildByPath(ui, "img_xuanzhong")
    self.btn_hecheng = TFDirector:getChildByPath(ui, "btn_hec")
    self.btn_hecheng.logic = self

    self.txt_num1 = TFDirector:getChildByPath(ui, "txt_num1")
    self.txt_num2 = TFDirector:getChildByPath(ui, "txt_num2")
end

function NewJingyaoIcon:removeUI()
    self.super.removeUI(self)

    self.id = nil
    self.item = nil
    self.type = nil
end

function NewJingyaoIcon:setLogic( layer )
    self.logic = layer
end

function NewJingyaoIcon:setData(id, itemType, type, item)
    self.id = id
    self.type = type
    self.itemType = itemType
    self.item = item
    self:refreshUI()
end

function NewJingyaoIcon:setChoose(bChoose)
    self.img_selected:setVisible(bChoose)

    local jingyaoId = SkyBookManager:getJingyaoIdByPieceId(self.id)
    local bCan = SkyBookManager:isJingyaoCanHecheng(jingyaoId)

    if bCan then
        self.btn_hecheng:setGrayEnabled(false)
        self.btn_hecheng:setTouchEnabled(true)
    else
        self.btn_hecheng:setGrayEnabled(true)
        self.btn_hecheng:setTouchEnabled(false)
    end
end

function NewJingyaoIcon:refreshUI()
    CommonManager:removeRedPoint(self)

    if not self.id then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return
    end

    if not self.item then
        self.panel_empty:setVisible(true)
        self.panel_info:setVisible(false)
        return
    end

    self.panel_empty:setVisible(false)
    self.panel_info:setVisible(true)

    self.img_selected:setVisible(false)

    if self.itemType == 1 then
        self:freshSBStoneInfo()
    else
        self:freshSBStonePieceInfo()
    end
end

function NewJingyaoIcon:freshSBStoneInfo()
    self.txt_num:setVisible(true)
    self.txt_num1:setVisible(false)
    self.txt_num2:setVisible(false)

    if self.type == self.TYPE_UNEQUIPPED then
        self.img_icon:setTexture(self.item:GetTextrue())
        self.img_quality:setTexture(GetColorIconByQuality(self.item.quality))
        self.txt_name:setText(self.item.name)
    else
        local tempItem = ItemData:objectByID(self.item.id)
        self.img_icon:setTexture(tempItem:GetPath())
        self.img_quality:setTexture(GetColorIconByQuality(tempItem.quality))
        self.txt_name:setText(tempItem.name)
    end

    if self.type == self.TYPE_EQUIPPED then
        self.txt_num:setVisible(false)
    else
        if self.item.num and self.item.num ~= 0 then
            self.txt_num:setVisible(true)
            self.txt_num:setText(self.item.num)
        else
            self.txt_num:setVisible(false)       
        end
    end

    --装配
    if self.type == self.TYPE_UNEQUIPPED then
        self.img_pei:setVisible(false)
        self.img_equiped:setVisible(false)
    else
        local txt_equipped_name = nil
        if self.item.equipId and self.item.equipId ~= 0 then
            self.img_equiped:setVisible(true)
            self.img_pei:setVisible(false)
            txt_equipped_name = TFDirector:getChildByPath(self.img_equiped, "txt_equiped_name")
            local roleId = self.item.equipId
            local role = CardRoleManager:getRoleById(roleId)
            if role then
                txt_equipped_name:setVisible(true)
                txt_equipped_name:setText(role.name)
            end
        else
            self.img_pei:setVisible(true)
            self.img_equiped:setVisible(false)
            txt_equipped_name = TFDirector:getChildByPath(self.img_pei, "txt_equiped_name")
            txt_equipped_name:setVisible(true)
            local bookId = self.item.bookId
            local bookTemplate = ItemData:objectByID(bookId)
            if bookTemplate then
                local name = bookTemplate.name
                txt_equipped_name:setText(name)
            end
        end
    end

    local rewardItem = {itemid = self.item.id}
    Public:addPieceImg(self.img_icon,rewardItem,false)
end
function NewJingyaoIcon:freshSBStonePieceInfo()
    self.txt_num:setVisible(false)
    self.txt_num1:setVisible(true)
    self.txt_num2:setVisible(true)

    self.img_icon:setTexture(self.item:GetTextrue())
    self.img_quality:setTexture(GetColorIconByQuality(self.item.quality))
    self.txt_name:setText(self.item.name)

    local jingyaoId = SkyBookManager:getJingyaoIdByPieceId(self.item.id)
    local needNum = SkyBookManager:getJingyaoNeedPieceNum(jingyaoId)

    self.txt_num1:setText(self.item.num)
    self.txt_num2:setText("  /  " .. needNum)
    self.txt_num1:setColor(ccc3(255, 255, 255))

    if self.item.num < needNum then
        self.txt_num1:setColor(ccc3(97, 255, 20))
        CommonManager:removeRedPoint(self)
    else
        CommonManager:updateRedPoint(self, true, ccp(self:getSize().width / 2, self:getSize().height / 2 - 20))
    end

    --[[
    if self.item.num and self.item.num ~= 0 then
        self.txt_num:setVisible(true)
        self.txt_num:setText(self.item.num)
    else
        self.txt_num:setVisible(false)       
    end
    ]]
    self.img_pei:setVisible(false)
    self.img_equiped:setVisible(false)

    local rewardItem = {itemid = self.item.id}
    Public:addPieceImg(self.img_icon,rewardItem,true)
end

function NewJingyaoIcon:registerEvents()
	self.super.registerEvents(self)

    self.btn_icon:addMEListener(TFWIDGET_CLICK, audioClickfun(self.IconBtnClickHandle))
    self.btn_hecheng:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onHechengClickHandle))
end

function NewJingyaoIcon:removeEvents()
    self.super.removeEvents(self)
end

function NewJingyaoIcon:getId()
    return self.id
end

--点击icon
function NewJingyaoIcon.IconBtnClickHandle(sender)
    local self = sender.logic
    print("JingyaoMainLayer icon clicked, id = ", self.id, self.itemType)
    if self.itemType == 1 then
        Public:ShowItemTipLayer(self.id, EnumDropType.GOODS)
        return
    elseif self.itemType == 2 then
        self.logic:select(self.id)
    end
end

function NewJingyaoIcon.onHechengClickHandle(sender)
    local self = sender.logic

    print("jingyao piece hecheng clicked!")

    local jingyaoId = SkyBookManager:getJingyaoIdByPieceId(self.id)
    print("++++++++++target jingyaoId = ", jingyaoId)
    if SkyBookManager:isJingyaoCanHecheng(jingyaoId) then
        SkyBookManager:requestEssentialMerge(jingyaoId)
    else
        toastMessage(localizable.Tianshu_hecheng_text1)
    end
end

return NewJingyaoIcon