---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/18 15:32:33
-- @description: 大富翁格子item
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

MonopolyGridItem = class("MonopolyGridItem",function()
    return ccui.Layout:create()
end)

function MonopolyGridItem:ctor()
    self:configUI()
    self:registerEvent()
end

function MonopolyGridItem:configUI()
    self.size = cc.size(171, 93)
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("monopoly/monopoly_grid_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    self.image_bg = self.container:getChildByName("image_bg")
    self.image_bg:ignoreContentAdaptWithSize(true)
end

function MonopolyGridItem:registerEvent()
    if not self.update_evt_type_event then
        self.update_evt_type_event = GlobalEvent:getInstance():Bind(MonopolyEvent.Update_Grid_Evt_Type_Event,function (id, pos, evt_type)
            if self.data and self.data.step_id == id and self.data.index == pos then
                local new_data = {}
                new_data.evt_type = evt_type
                self.data:updateData(new_data)
                self:updateEvtType()
            end
        end)
    end
end

function MonopolyGridItem:setData(data)
    if not data then return end

    self.data = data

    local grid_path = self:getGridPathByResId(data.map_id, data.grid_res_id)
    self.grid_img_load = loadImageTextureFromCDN(self.image_bg, grid_path, ResourcesType.single, self.grid_img_load)

    if data.grid_index then
        local pos_x, pos_y = MonopolyTile.indexPixel(data.grid_index)
        self:setPosition(cc.p(pos_x, pos_y))
    end

    self:updateEvtType()
end

-- 更新事件类型
function MonopolyGridItem:updateEvtType()
    if not self.data then return end
    if self.evt_icon then
        self.evt_icon:stopAllActions()
        self.evt_icon:setVisible(false)
    end

    -- 事件icon
    if self.data.evt_type ~= MonopolyConst.Event_Type.Normal then
        local res_data = self.data.res_data or {}
        local res_type = res_data[1] or 1
        local res_name = res_data[2]

        if res_type == 1 and res_name then -- 图片
            local evt_path = self:getEvtPathByResId(res_name)
            if evt_path then
                if not self.evt_icon then
                    self.evt_icon = createSprite(nil, self.size.width*0.5, self.size.height*0.5, self.container, cc.p(0.5, 0), LOADTEXT_TYPE)
                end
                if self.data.offset then
                    local offset_x = self.data.offset[1] or 0
                    local offset_y = self.data.offset[2] or 0
                    self.evt_icon:setPosition(cc.p(self.size.width*0.5+offset_x, self.size.height*0.5+offset_y))
                end
                self.evt_icon:setVisible(true)
                self.evt_icon_load = loadSpriteTextureFromCDN(self.evt_icon, evt_path, ResourcesType.single, self.evt_icon_load)

                if self.data.show_ani == 1 then
                    local act_1 = cc.MoveBy:create(1.4, cc.p(0, 10))
                    local act_2 = cc.MoveBy:create(1.4, cc.p(0, -10))
                    self.evt_icon:runAction(cc.RepeatForever:create(cc.Sequence:create(act_1, act_2)))
                else
                    self.evt_icon:stopAllActions()
                end
            end
            self.evt_icon:setVisible(true)
            if self.evt_effect then
                self.evt_effect:clearTracks()
                self.evt_effect:removeFromParent()
                self.evt_effect = nil
                self.cur_effect_name = nil
            end
        elseif res_type == 2 and res_name then -- 特效
            if not self.cur_effect_name or self.cur_effect_name ~= res_name then
                self.cur_effect_name = res_name
                if self.evt_effect then
                    self.evt_effect:clearTracks()
                    self.evt_effect:removeFromParent()
                    self.evt_effect = nil
                end
                local offset_x = 0
                local offset_y = 0
                if self.data.offset then
                    offset_x = self.data.offset[1] or 0
                    offset_y = self.data.offset[2] or 0
                end
                self.evt_effect = createEffectSpine(res_name, cc.p(self.size.width*0.5+offset_x, self.size.height*0.5+offset_y), cc.p(0.5, 0.5), true, PlayerAction.action)
                self.container:addChild(self.evt_effect)
            end
            if self.evt_icon then
                self.evt_icon:stopAllActions()
                self.evt_icon:setVisible(false)
            end
        end
    else
        if self.evt_effect then
            self.evt_effect:clearTracks()
            self.evt_effect:removeFromParent()
            self.evt_effect = nil
        end
    end
end

-- 获取格子图标资源
function MonopolyGridItem:getGridPathByResId(map_id,  res_id)
    if map_id and res_id and res_id ~= "" then
        local map_cfg_data = Config.MonopolyMapsData.data_map_info[map_id]
        return _string_format("resource/monopoly/background/%d/%s.png", map_cfg_data.res_id, res_id)
    end
end

-- 获取格子事件资源
function MonopolyGridItem:getEvtPathByResId(res_id)
    if res_id and res_id ~= "" then
        return _string_format("resource/monopoly/evt/%s.png", res_id)
    end
end

-- -- 设置层级
function MonopolyGridItem:setItemLocalZOrder(zorder)
    self:setLocalZOrder(zorder)
end

-- 获取当前格子坐标
function MonopolyGridItem:getCurGridPos()
    if self.data then
        return MonopolyTile.indexTile(self.data.grid_index)
    end
end

function MonopolyGridItem:DeleteMe()
    if self.evt_icon_load then
        self.evt_icon_load:DeleteMe()
        self.evt_icon_load = nil
    end
    if self.grid_img_load then
        self.grid_img_load:DeleteMe()
        self.grid_img_load = nil
    end
    if self.evt_effect then
        self.evt_effect:clearTracks()
        self.evt_effect:removeFromParent()
        self.evt_effect = nil
    end
    if self.update_evt_type_event then
        GlobalEvent:getInstance():UnBind(self.update_evt_type_event)
        self.update_evt_type_event = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end