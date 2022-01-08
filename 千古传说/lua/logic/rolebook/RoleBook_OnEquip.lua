--[[
******角色详情*******
    -- by king
    -- 2015/4/17
]]

local RoleBook_OnEquip = class("RoleBook_OnEquip", BaseLayer)

function RoleBook_OnEquip:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.role_new.RoleBookOnEquip")
end

function RoleBook_OnEquip:loadData(cardrole, bookIndex, showType,levelIndex)
    self.firstDraw = true

    self.cardRole   = cardrole
    self.bookIndex  = bookIndex


    self.roleGmid   = cardrole.gmId

    self.showType   = showType
    self.levelIndex = levelIndex or 0
end

function RoleBook_OnEquip:onShow()
    self.super.onShow(self)

      
    self:refreshUI()
end

function RoleBook_OnEquip:refreshUI()
    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmid)
    

    
    self:drawRightAreaOnce()
    self:BrushShowType()
    self:drawLeftArea()
    self:addXieDeEffect("btn_common")

    -- if self.windowStatus == 0 then
    --     print("self.bookid = ", self.bookid)
    --     self.layer_hecheng:AddBook(self.bookid)
    --     self.windowStatus = 1
    --     -- self:drawLeftArea()
    --     -- self:openRightArea()
    --     -- -- self:drawRightAreaOnce()
    --     self:endPosition()
    --     -- self.layer_hecheng:setVisible(true)
    --     self.img_hechengdiag:setVisible(true)
    -- end
end

function  RoleBook_OnEquip:BrushShowType()
    if self.showType and self.showType == 1 then
        self.layer_hecheng:showBtnHeCheng(false)
    else
        self.layer_hecheng:showBtnHeCheng(true)
    end
end

function RoleBook_OnEquip:initUI(ui)
	self.super.initUI(self,ui)

    -- 勤学苦练
    self.img_qx_diag        = TFDirector:getChildByPath(ui, 'img_qx_diag')
    self.btn_qxkl           = TFDirector:getChildByPath(ui, 'btn_qxkl')
    self.btn_qxkl.logic     = self
    self.txt_bookname       = TFDirector:getChildByPath(ui, 'txt_bookname')
    self.txt_booknum        = TFDirector:getChildByPath(ui, 'txt_booknum')
    self.img_bookQuality    = TFDirector:getChildByPath(ui, 'img_quality')
    self.img_equip          = TFDirector:getChildByPath(ui, 'img_equip')
    self.txt_bookdesc       = TFDirector:getChildByPath(ui, 'txt_bookdesc')
    self.txt_warning        = TFDirector:getChildByPath(ui, 'txt_warning')
    self.img_bookQuality:setTouchEnabled(false)

    -- 合成相关
    self.img_hechengdiag       = TFDirector:getChildByPath(ui, 'img_hechengdiag')


    -- 属性描述
    self.node_AttributeList     = {}
    self.txt_AttributeNameList  = {}
    self.txt_AttributeValueList = {}
    for i=1,5 do
        self.node_AttributeList[i]          =  TFDirector:getChildByPath(ui, "panel_att" .. i)
        self.txt_AttributeNameList[i]       =  TFDirector:getChildByPath(self.node_AttributeList[i],"name")
        self.txt_AttributeValueList[i]      =  TFDirector:getChildByPath(self.node_AttributeList[i],"value")

        self.node_AttributeList[i]:setVisible(false)
    end


    -- self.windowStatus = 0 第一次进入 , 1 呼出了右边的界面
    self.windowStatus = 0


    
    self.img_equip:setScale(0.7)
end

function RoleBook_OnEquip:registerEvents(ui)
    self.super.registerEvents(self)

    self.btn_qxkl:addMEListener(TFWIDGET_CLICK, audioClickfun(self.BtnClickHandle))

    self.MartialSynthesisEventCallBak = function(event)
        self:refreshUI()
        self.layer_hecheng:popBook()
    end
    TFDirector:addMEGlobalListener(MartialManager.MSG_MartialSynthesis ,self.MartialSynthesisEventCallBak )

    self.MartialLearnEventCallBak = function(event)
        -- 直接就能学习的
        -- if self.windowStatus == 0 then
        --     AlertManager:close()
        -- else
        --     self:refreshUI()
        -- end
        AlertManager:close()
    end
    TFDirector:addMEGlobalListener(MartialManager.MSG_MartialLearn ,self.MartialLearnEventCallBak )
end


function RoleBook_OnEquip:removeEvents()
    self.super.removeEvents(self)



    TFDirector:removeMEGlobalListener(MartialManager.MSG_MartialSynthesis, self.MartialSynthesisEventCallBak )
    self.MartialSynthesisEventCallBak = nil

    TFDirector:removeMEGlobalListener(MartialManager.MSG_MartialLearn, self.MartialLearnEventCallBak )
    self.MartialLearnEventCallBak = nil
end



function RoleBook_OnEquip:drawRightAreaOnce()
    -- 重绘右边
    if self.layer_hecheng == nil then
        local RoleBook_Hecheng = require("lua.logic.rolebook.RoleBook_Hecheng"):new()
        RoleBook_Hecheng:setTag(10086)
        RoleBook_Hecheng:setZOrder(2)
        RoleBook_Hecheng:setPosition(ccp(-207, -281)) --415 533
        self.img_hechengdiag:addChild(RoleBook_Hecheng,200)

        self.layer_hecheng = RoleBook_Hecheng
    else
        self.layer_hecheng:redraw()
    end
end

function RoleBook_OnEquip:setHechengOutViewScrollView( value )
    if self.layer_hecheng == nil then
        return
    end
    if self.layer_hecheng.outputTableView then
        if value == true then
            if self.layer_hecheng.outputNum > 3 then
                self.layer_hecheng.outputTableView:setInertiaScrollEnabled(true)
            else
                self.layer_hecheng.outputTableView:setInertiaScrollEnabled(false)
            end
        else
            self.layer_hecheng.outputTableView:setInertiaScrollEnabled(value)
        end
    end
end


function RoleBook_OnEquip:setLeftOnMiddle()
    -- 居中
    local parent        = self.img_qx_diag:getParent()
    local sizeParent    = parent:getContentSize()
    local sizeImage     = self.img_qx_diag:getContentSize()
    local pos           = self.img_qx_diag:getPosition()

    local x = sizeParent.width/2
    local y = sizeParent.height/2

    self.img_qx_diag:setPosition(ccp(x,y))
    self.img_hechengdiag:setPosition(ccp(x,y))
end


function RoleBook_OnEquip:resetPosition()
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
    -- self.img_hechengdiag:setPosition(ccp(right_x,center_y))

    -- 开启动画
    self:moveArea(self.img_qx_diag, ccp(left_x,center_y))
    self:moveArea(self.img_hechengdiag, ccp(right_x,center_y))
end



function RoleBook_OnEquip:drawLeftArea()

    if self.cardRole == nil then
        -- toastMessage("self.cardRole is nil")
        return
    end

        -- 武学等级
    local martialLevel = self.cardRole.martialLevel + (self.levelIndex or 0)
    local martialList  = self.cardRole.martialList

    local bookIndex    = self.bookIndex

    
    -- print("self.cardRole = ", self.cardRole)
    --print("martialLevel = ", martialLevel)
    --print("martialList = ", martialList)
    --print("bookIndex = ", bookIndex)
    local bookListData     = MartialRoleConfigure:findByRoleIdAndMartialLevel(self.cardRole.id, martialLevel)

    local bookList     = bookListData:getMartialTable()

    -- for test
    -- bookList = {}
    -- print("bookList = ", bookList)
    -- for i=1,6 do
    --     bookList[i] = 61003
    -- end


    local bookInfo     = MartialData:objectByID(bookList[bookIndex])

    local bgPic        = getBookBackgroud(bookInfo.goodsTemplate.quality)


    self.bookid        = bookList[bookIndex]


    local num          = BagManager:getItemNumById( bookInfo.goodsTemplate.id )
    self.txt_bookname:setText(bookInfo.goodsTemplate.name)
    --self.txt_booknum:setText("拥有 "  .. num .. " 本")
    self.txt_booknum:setText(stringUtils.format(localizable.roleBook_equip_book,num))
    self.txt_bookdesc:setText(bookInfo.goodsTemplate.details)
    self.img_bookQuality:setTextureNormal(bgPic)
    self.img_equip:setTexture(bookInfo.goodsTemplate:GetPath())

    if 1 then
        local Attribute = bookInfo:getAttributeTable()
        local count = 0
        for i=1,EnumAttributeType.Max do
            if Attribute[i] then
                count = count + 1
                
                local attName  = AttributeTypeStr[i]
                local attValue = Attribute[i]

                -- self.txt_AttributeNameList[count]:setText(attName)
                -- self.txt_AttributeValueList[count]:setText(attValue)
                self.txt_AttributeNameList[count]:setText(attName.."  +"..attValue)
                self.txt_AttributeValueList[count]:setVisible(false)

                self.node_AttributeList[count]:setVisible(true)
            end
        end
        -- return
    end


    self.bookStatus = self:getBookStatus(bookInfo)
    -- self.bookStatus = 0

    self.btn_qxkl:setGrayEnabled(false)
    self.btn_qxkl:setTouchEnabled(true)

    -- 0 完全搞不出来
    -- 1 背包存在并且可以穿戴
    -- 2 背包存在并且不可以穿戴
    -- 3 可以合成并且可以穿戴
    -- 4 可以合成并且不可以穿戴
    if self.bookStatus == 1 then
        self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_xide.png")

    elseif self.bookStatus == 2 then
        self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_xide.png")

    elseif self.bookStatus == 3 then
        self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_hecheng.png")

    elseif self.bookStatus == 4 then
        self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_hecheng.png")

    elseif self.bookStatus == 0 then
        -- self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_hecheng.png")
        self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_hqtj.png")
    end 

    -- self.txt_warning:setVisible(false)
    -- if self.bookStatus == 2 or self.bookStatus == 4 then
    --     self.txt_warning:setVisible(true)
    --     local bookLevel = bookInfo.goodsTemplate.level
    --     self.txt_warning:setText("需求英雄等级："..bookLevel)
    -- end

    self.txt_warning:setVisible(false)
    local bookLevel = bookInfo.goodsTemplate.level
    print("该书穿戴等级：", bookLevel)
    print("该角色等级：  ", self.cardRole.level)
    
    if bookLevel > self.cardRole.level then
        self.txt_warning:setVisible(true)
        --self.txt_warning:setText("需求英雄等级："..bookLevel)
        self.txt_warning:setText(stringUtils.format(localizable.common_need_player_level, bookLevel))
    end

    -- if self.firstDraw == true then
    --     self.firstDraw = false
    if self.windowStatus == 0 then
        -- 左边居中 
        self:setLeftOnMiddle()

        -- 右边隐藏
        self.img_hechengdiag:setVisible(false)
    -- 
    else

        self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_xide.png")
        if self.bookStatus == 1 then
            -- self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_xide.png")

        elseif self.bookStatus == 2 then
            -- self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_xide.png")
        -- elseif self.bookStatus == 0 then

        else

            self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_hqtj.png")
            
            self.btn_qxkl:setGrayEnabled(true)
            self.btn_qxkl:setTouchEnabled(false)
        end 

    end


    --print("bookStatus =",self.bookStatus)
    -- -- 0 完全搞不出来
    -- -- 1 背包存在并且可以穿戴
    -- -- 2 背包存在并且不可以穿戴
    -- -- 3 可以合成并且可以穿戴
    -- -- 4 可以合成并且不可以穿戴
    -- if self.bookStatus == 1 then
    --     self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_xide.png")

    -- elseif self.bookStatus == 2 then
    --     self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_xide.png")

    -- elseif self.bookStatus == 3 then
    --     self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_hecheng.png")

    -- elseif self.bookStatus == 4 then
    --     self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_hecheng.png")

    -- elseif self.bookStatus == 0 then
    --     self.btn_qxkl:setTextureNormal("ui_new/rolebook/btn_hecheng.png")
    -- end

end

function RoleBook_OnEquip:drawRightArea()
end


function RoleBook_OnEquip:addXieDeEffect(effectName)

    if self.bookStatus == 1 and self.windowStatus == 1 then
        if self.effect == nil then
            print("addd effect")
            -- TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effectName..".xml")
            -- local effect = TFArmature:create(effectName.."_anim")
            -- effect:setAnimationFps(GameConfig.ANIM_FPS)
            -- effect:playByIndex(0, -1, -1, 1)
            ModelManager:addResourceFromFile(2, effectName, 1)
            local effect = ModelManager:createResource(2, effectName)
            effect:setAnimationFps(GameConfig.ANIM_FPS)
            ModelManager:playWithNameAndIndex(effect, "", 0, 1, -1, -1)
            -- self.btn_qxkl:addChild(effect , 100)
            self:addChild(effect , 100)
            effect:setPosition(ccp(270-13, 120-10))
            self.effect = effect
        end

    else

        if self.effect then
            self.effect:removeFromParent()
            self.effect = nil
        end
    end

end

function RoleBook_OnEquip:getBookStatus(bookInfo)
    
    -- 0 不存在
    -- 1 背包存在并且可以穿戴
    -- 2 背包存在并且不可以穿戴
    -- 3 可以合成并且可以穿戴
    -- 4 可以合成并且不可以穿戴
    local bookStatus = 0
    if self.showType and self.showType == 1 then
        return bookStatus
    end
    local roleLevel = self.cardRole.level
    local id        = bookInfo.goodsTemplate.id
    local bag       = BagManager:getItemById(id)
    local bookLevel = bookInfo.goodsTemplate.level

    -- 背包中存在
    if bag then
        bookStatus = 1
    else
        if MartialManager:isCanSynthesisById(id, 1) then
            bookStatus = 3
        end
    end

    -- 穿戴等级
    -- 有物品 才判断等级
    if bookLevel > roleLevel and bookStatus > 0 then
        bookStatus = bookStatus + 1
    end

    --print("RoleBook_OnEquip:getBookStatus = ", bookStatus)
    return bookStatus
end

function RoleBook_OnEquip:openRightArea()
    self:drawRightArea()
    self:resetPosition()

    self.img_hechengdiag:setVisible(true)
end


function RoleBook_OnEquip:moveArea(target_, toPos)
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

function RoleBook_OnEquip.BtnClickHandle(sender)
    local self = sender.logic;

    local status = self.bookStatus
   
    if self.windowStatus == 0 then
        self.windowStatus = 0

        if self.bookStatus == 1 then
            MartialManager:requestEquip_Ext(self.cardRole.gmId, self.bookid, self.bookIndex)
        elseif self.bookStatus == 2 then
            --toastMessage("角色等级不够，不能习得此书")
            toastMessage(localizable.roleBook_equip_level_notenough)
        else
            self.windowStatus =1
            self:drawLeftArea()
            self:openRightArea()
            self.layer_hecheng:AddBook(self.bookid)
            -- self.layer_hecheng:AddBook(61080)
            -- self.layer_hecheng:AddBook(61003)
            PlayerGuideManager:doGuide()
        end
        
    else
        if self.bookStatus == 1 then
            MartialManager:requestEquip_Ext(self.cardRole.gmId, self.bookid, self.bookIndex)
        elseif self.bookStatus == 2 then
            --toastMessage("角色等级不够，不能习得此书")
            toastMessage(localizable.roleBook_equip_level_notenough)
        end
    end
    -- 0 完全搞不出来
    -- 1 背包存在并且可以穿戴
    -- 2 背包存在并且不可以穿戴
    -- 3 可以合成并且可以穿戴
    -- 4 可以合成并且不可以穿戴
end


function RoleBook_OnEquip:endPosition()
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
    -- self.img_hechengdiag:setPosition(ccp(right_x,center_y))

    -- 开启动画
    self.img_qx_diag:setPosition(ccp(left_x,center_y))
    self.img_hechengdiag:setPosition(ccp(right_x,center_y))
end


return RoleBook_OnEquip
