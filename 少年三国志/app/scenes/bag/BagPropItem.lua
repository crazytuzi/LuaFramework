require("app.cfg.item_info")
local BagPropItem = class("BagPropItem",function()
    return CCSItemCellBase:create("ui_layout/bag_BagPropItem.json")
end)

local USE_BTN_NORMAL_POSY = 77 
local USE_BTN_INNORMAL_POSY = 112
local MULTI_USE_BTN_POSY = 50

function BagPropItem:ctor()
    self._useFunc = nil
    self._multiUseFunc = nil
    self._itemInfoFunc = nil
    self._itemImg = self:getImageViewByName("ImageView_item")
    self._itemButton = self:getButtonByName("Button_item")
    self._btnTextImg = self:getImageViewByName("ImageView_btntext")
    self._itemName = self:getLabelByName("Label_name")
    self._itemCount = self:getLabelByName("Label_itemNum")
    self._itemDescription = self:getLabelByName("Label_desc")
    self._useBtn = self:getButtonByName("Button_use")
    self._multiUseBtn = self:getButtonByName("Button_Multi_Use")
    self:registerBtnClickEvent("Button_use", function ( widget )
        self:setClickCell()
            if self._useFunc then self._useFunc() end
    end)  
    self:registerBtnClickEvent("Button_item", function ( widget )
            if self._itemInfoFunc then self._itemInfoFunc() end
    end) 
    self:registerBtnClickEvent("Button_Multi_Use", function ( widget )
        if self._multiUseFunc then self._multiUseFunc() end
    end)

    self._itemName:createStroke(Colors.strokeBlack,1)
    -- self._itemCount:createStroke(Colors.strokeBrown,1)

    self._itemName:setText("")
    self._itemDescription:setText("")
    self._itemCount:setText("")
    -- self:getLabelByName("Label_guoqiTag"):setText("")
    self:getLabelByName("Label_guoqi"):setText("")
    -- self:getLabelByName("Label_yiguoqi"):setText("")

end

function BagPropItem:setUseBtnClickEvent(fun)
    self._useFunc = fun
end
function BagPropItem:setMultiUseBtnClickEvent( func )
    self._multiUseFunc = func
end
function BagPropItem:setCheckItemInfoFunc(fun)
    self._itemInfoFunc = fun
end
--[[
    连接至其他模块
    1. 可使用；按钮：使用
    2. 去突破；按钮：去突破；
    3. 去精练；按钮：去精练；
    4. 去洗练；按钮：去洗练；
    5. 去武将光环；按钮：去光环；（这块以后要改，现在也没有这个系统）
    6. 连接至神秘商店；按钮：神秘商店；
    7. 链接至宝物精练；按钮：宝物精练
    8. 打开抽将；按钮：去抽卡
    10 去命星，三国志系统
    文字
    去突破
    去洗练
    去精炼
    去光环
    神秘商店
    宝物精炼
    去抽卡
    去化神
]]



function BagPropItem:updateCell(prop)
    local item = item_info.get(prop.id)
    if not item then
        return
    end

    -- 需要显示一键使用按钮的道具
    if item.item_type == 1 and item.batch_type == 1 then
        self._useBtn:setPositionY(USE_BTN_INNORMAL_POSY)
        self._multiUseBtn:setPositionY(MULTI_USE_BTN_POSY)
        self._multiUseBtn:setVisible(true)
        self._multiUseBtn:setVisible(item.use_type ~= 0)
    else
        self._useBtn:setPositionY(USE_BTN_NORMAL_POSY)
        self._multiUseBtn:setVisible(false)
    end

    self._itemName:setColor(Colors.qualityColors[item.quality])
    self._itemName:setText(item.name)
    self:getImageViewByName("ImageView_item_bg"):loadTexture(G_Path.getEquipIconBack(item.quality))
    self._itemCount:setText(prop.num)
    self._itemDescription:setText(item.directions)
    self._itemDescription:setColor(Colors.lightColors.DESCRIPTION)
    self._itemImg:loadTexture(G_Path.getItemIcon(item.res_id),UI_TEX_TYPE_LOCAL)
    self._itemButton:loadTextureNormal(G_Path.getEquipColorImage(item.quality,G_Goods.TYPE_ITEM))
    self._itemButton:loadTexturePressed(G_Path.getEquipColorImage(item.quality,G_Goods.TYPE_ITEM))
    --use_type == 0不显示
    self._useBtn:setVisible(item.use_type ~= 0 )

    -- if item.use_type == 1 then
    --     self._useBtn:loadTextureNormal("btn-small-red.png",UI_TEX_TYPE_PLIST)
    -- else
    --     self._useBtn:loadTextureNormal("btn-small-blue.png",UI_TEX_TYPE_PLIST)
    -- end

    self._btnTextImg:loadTexture(G_Path.getButtonTextureByItemType(item.use_type))
    --[[是否显示使用button
    local isShow = false
    for i,v in ipairs(BagConst.SHOW_BTN_USE) do
        if v == item.item_type then
            isShow = true
        end
    end
    self:showWidgetByName("Button_use",isShow)
    ]]

    --这里设置 使用按钮的文字

    
    --判断是否过期
    if item.destroy_time <= 0 then
        self:showWidgetByName("Panel_guoqi",false)
    else
        self:showWidgetByName("Panel_guoqi",true)
        local leftSeconds = G_ServerTime:getLeftSeconds(item.destroy_time)
        if leftSeconds > 0 then
            --截止时间
            self:showWidgetByName("Panel_guoqiTime",true)
            local date = G_ServerTime:getDateObject(item.destroy_time)
            --[[
                ["LANG_ACTIVITY_AWARD_TIME"]                 = "#month#-#day# #hour#:#min#",
            ]]
            local leftSecondsString = G_lang:get("LANG_BAG_ITEM_DEAD_TIME",{year=date.year,month=date.month,day=date.day,hour=date.hour})
            self:getLabelByName("Label_guoqi"):setText(leftSecondsString)
        else
            --
            self:getLabelByName("Label_guoqi"):setText(G_lang:get("LANG_BAG_ITEM_TIME_OUT"))
        end
    end
end

return BagPropItem





