-- RecyclePreviewLayer

local RecyclePreviewLayer = class("RecyclePreviewLayer", UFCCSModelLayer)

RecyclePreviewLayer.LAYOUT_KNIGHT          = "ui_layout/recycle_recycleKnightPreviewLayer.json"
RecyclePreviewLayer.LAYOUT_EQUIPMENT       = "ui_layout/recycle_recycleEquipmentPreviewLayer.json"
RecyclePreviewLayer.LAYOUT_REBORN_KNIGHT   = "ui_layout/recycle_rebornKnightPreviewLayer.json"
RecyclePreviewLayer.LAYOUT_REBORN_TREASURE = "ui_layout/recycle_rebornTreasurePreviewLayer.json"
RecyclePreviewLayer.LAYOUT_PET             = "ui_layout/recycle_recyclePetPreviewLayer.json"
RecyclePreviewLayer.LAYOUT_PET_REBORN      = "ui_layout/recycle_rebornPetPreviewLayer.json"


function RecyclePreviewLayer.create(layout, ...)
    return RecyclePreviewLayer.new(layout, Colors.modelColor, ...)
end

function RecyclePreviewLayer:ctor(_, _, updates)
    
    RecyclePreviewLayer.super.ctor(self)
    
    self:adapterWithScreen()
    
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    
    self:closeAtReturn(true)

    -- 绑定关闭按钮
    local function _onClose()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end
    
    self:registerBtnClickEvent("Button_close", _onClose)
    self:registerBtnClickEvent("Button_cancel", _onClose)
    
    self:enableAudioEffectByName("Button_cancel", false)
    self:enableAudioEffectByName("Button_close", false)

    -- 提示文字加描边
    local labelTips = self:getLabelByName("Label_tips")
    if labelTips then
        labelTips:createStroke(Colors.strokeBrown, 1)
    end
    
    for i=1, #updates do
        local update = updates[i]
        self:updateLabel(update[1], update[2])
        self:updateImageView(update[1], update[2])
    end
    
end

function RecyclePreviewLayer:updateLabel(name, params, target)
    
    target = target or self
    
    local label = target:getLabelByName(name)
    if not label then return end
    
    if params.stroke ~= nil and label.createStroke then
        label:createStroke(params.stroke, 1)
    end
    
    if params.color ~= nil and label.setColor then
        label:setColor(params.color)
    end
    
    if params.text ~= nil and label.setText then
        label:setText(params.text)
    end
    
    if params.visible ~= nil and label.setVisible then
        label:setVisible(params.visible)
    end

end

function RecyclePreviewLayer:updateImageView(name, params, target)
    
    target = target or self
    
    local img = target:getImageViewByName(name)
    if not img then return end
    
    if params.texture ~= nil and img.loadTexture then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_PLIST)
    end
    
    if params.visible ~= nil and img.setVisible then
        img:setVisible(params.visible)
    end
    
end

function RecyclePreviewLayer:updateListView(listViewName, datas, target)
    
    target = target or self
    
    local list = target:getPanelByName(listViewName)
    assert(list, "Could not find the listView with name: "..listViewName)
    
    local listview = CCSListViewEx:createWithPanel(list, LISTVIEW_DIR_VERTICAL)
    
    -- 分别设置创建方法和更新方法
    listview:setCreateCellHandler(function(list, index)
        return CCSItemCellBase:create("ui_layout/recycle_recyclePreviewItemCell.json")
    end)
    
    listview:setUpdateCellHandler(function(list, index, cell)
        for i=1, 5 do
            local data = datas[index*5 + i]
            if data then
                for j=1, #data do
                    self:updateImageView(data[j][1]..i, data[j][2], cell)
                    self:updateLabel(data[j][1]..i, data[j][2], cell)
                end
            else
                self:updateImageView("ImageView_item"..i, {visible=false}, cell)
            end
        end
    end)

    listview:initChildWithDataLength(math.ceil(#datas/5))
    
end


return RecyclePreviewLayer

