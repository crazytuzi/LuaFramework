-- AchievementRewardDetailLayer

require "app.cfg.target_info"

local function _updateLabel(target, name, text, stroke, color)
    
    local label = target:getLabelByName(name)
    if stroke then
        label:createStroke(stroke, 1)
    end
    if color then
        label:setColor(color)
    end
    
    label:setText(text)
end

local function _updateImageView(target, name, texture, texType)
    
    local img = target:getImageViewByName(name)
    img:loadTexture(texture, texType)
    
end

local AchievementRewardDetailLayer = class("AchievementRewardDetailLayer", UFCCSModelLayer)

function AchievementRewardDetailLayer.create(...)
    return AchievementRewardDetailLayer.new("ui_layout/dailytask_AchievementRewardDetailLayer.json", Colors.modelColor, ...)
end

function AchievementRewardDetailLayer:ctor(_, _, rewardList, ...)
    
    AchievementRewardDetailLayer.super.ctor(self, ...)
    
    self._rewardList = rewardList
    
    -- 自适应屏幕高度，这里需要设置否则弹框的整体摆放位置会不对
    self:adapterWithScreen()
    
    -- 更新文本
    _updateLabel(self, "Label_desc", G_lang:get('LANG_ACHIEVEMENT_DETAIL_DESC'))
    
    -- 关闭按钮
    self:registerBtnClickEvent("Button_close", function()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end)
    
    self:enableAudioEffectByName("Button_close", false)

end

function AchievementRewardDetailLayer:onLayerEnter()
    
    -- 统计一下奖励的数量
    local curInfo = self._rewardList
    local target = target_info.get(curInfo.id)
    
    local goods = {}
    goods.add = function(goo, value)
        if goo then
            goods[#goods + 1] = goo
            goo.value = value
        end
    end

    goods.add(G_Goods.convert(target['reward_type1'], target['reward_value1'], target['reward_size1']), target['reward_value1'])
    goods.add(G_Goods.convert(target['reward_type2'], target['reward_value2'], target['reward_size2']), target['reward_value2'])
    goods.add(G_Goods.convert(target['reward_type3'], target['reward_value3'], target['reward_size3']), target['reward_value3'])
    
    local list = self:getPanelByName("Panel_list")
    local listview = CCSListViewEx:createWithPanel(list, LISTVIEW_DIR_VERTICAL)

    -- 分别设置创建方法和更新方法
    listview:setCreateCellHandler(function(list, index)
        -- 创建item
        local item = CCSItemCellBase:create("ui_layout/dailytask_AchievementRewardDetailCell.json")
        
        -- 头像现在需要响应事件用来显示详情
        item:registerWidgetTouchEvent("Image_icon", function(widget, state)
            -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
            if not (not state or state == 2) then
                return
            end
            
            require("app.scenes.common.dropinfo.DropInfo").show(goods[item:getCellIndex()+1].type, goods[item:getCellIndex()+1].value)
        end)
        
        return item
    end)

    listview:setUpdateCellHandler(function(list, index, cell)
        
        local good = goods[index+1]
        -- 头像
        _updateImageView(cell, "Image_icon", good.icon, UI_TEX_TYPE_LOCAL)
        
        -- 背景
        _updateImageView(cell, "Image_bg", G_Path.getEquipIconBack(good.quality), UI_TEX_TYPE_PLIST)
        
        -- 名称
        _updateLabel(cell, "Label_name", good.name, Colors.strokeBrown)
        
        -- 描述
        _updateLabel(cell, "Label_desc", good.desc)
        
        -- 数量
        _updateLabel(cell, "Label_num", 'x'..good.size, Colors.strokeBrown)
        
        -- 品级框
        _updateImageView(cell, "Image_frame", G_Path.getEquipColorImage(good.quality, good.type), UI_TEX_TYPE_PLIST)
        
    end)

    listview:initChildWithDataLength(#goods, 0.2)
    
end


return AchievementRewardDetailLayer

