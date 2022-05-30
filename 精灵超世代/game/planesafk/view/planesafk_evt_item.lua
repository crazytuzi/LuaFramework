-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      位面冒险 事件显示
-- <br/>Create: 2019-12-04
-- --------------------------------------------------------------------
local controller = PlanesafkController:getInstance()
local model = controller:getModel()
local string_format = string.format

PlanesafkEvtItem = PlanesafkEvtItem or BaseClass()

function PlanesafkEvtItem:__init(parent)
    self.parent = parent
    self:createRootWnd()
    self:registerEvent()
end

function PlanesafkEvtItem:createRootWnd( )
    self.size = cc.size(PlanesafkConst.Grid_Width, PlanesafkConst.Grid_Height)
    self.root_wnd = ccui.Widget:create()
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0))
    self.root_wnd:setContentSize(self.size)
    
    self.parent:addChild(self.root_wnd)
end



function PlanesafkEvtItem:registerEvent( )

end

--设置变暗
function PlanesafkEvtItem:setDarkBgIcon()
    if not self.data then return end
    if not self.bg_icon then return end
    if self.data.is_black == true then
        setChildDarkShader(true, self.bg_icon)--变暗
    else
        setChildDarkShader(false, self.bg_icon)--变暗
    end
end


function PlanesafkEvtItem:setData( data )
    self.data = data
    if self.data and self.data.is_hide == 0 then
        self.is_show = true
        self:removeRemoveEffect()
        if self.bg_icon == nil then
            self.bg_icon = createSprite(nil, self.size.width*0.5, 25, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE)
        else
            self.bg_icon:setVisible(true)
        end
        local res_id = model:getMapResID()
        if self.record_bg_res == nil or self.record_bg_res ~= res_id then
            self.record_bg_res = res_id
            local res = model:getBgPathByResId(res_id)
            self.bg_item_load = loadSpriteTextureFromCDN(self.bg_icon, res, ResourcesType.single, self.bg_item_load, nil, function()
                self:setDarkBgIcon()
            end)
        else
            self:setDarkBgIcon()
        end
            

        if self.data then
            if self.layer_bg == nil then
                self.layer_bg = ccui.Widget:create()
                self.layer_bg:setContentSize(self.size)
                self.layer_bg:setPosition(0, 0)
                self.layer_bg:setAnchorPoint(cc.p(0,0))
                self.layer_bg:setTouchEnabled(true)
                self.layer_bg:setSwallowTouches(false)
                self.layer_bg:addTouchEventListener(function( sender, event_type) self:onClickBtn(sender, event_type) end)
                self.root_wnd:addChild(self.layer_bg)
            else
                self.layer_bg:setVisible(true)
            end

            local cur_line, cur_index = model:getRolePos()
            if cur_index == self.data.index and cur_line == self.data.line then
                -- self:showRoleInfo(true)
                GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_Create_Role_Event)
                self:updateEvtInfo(false)
            else
                self:updateEvtInfo(true) 
            end
        else
            if self.layer_bg then
                self.layer_bg:setVisible(false)
            end
        end
    else
        if self.is_show then
            self:removeRemoveEffect()
            local res_id = model:getMapResID()
            local effec_id = self:getRemoveEvtIconBgEffectId(res_id)
            -- playEffectOnce(effec_id, 91, 40, self.root_wnd) 
            self.remove_effect_spine = createEffectSpine(effec_id, cc.p(91, 40), cc.p(0.5, 0.5), false, PlayerAction.action, function()
                self.remove_effect_spine:setVisible(false)
            end)
            self.root_wnd:addChild(self.remove_effect_spine)
            self.is_show = false
        end
        if self.bg_icon then
            self.bg_icon:setVisible(false)
        end
        if self.layer_bg then
            self.layer_bg:setVisible(false)
        end
    end
end

--移除 移除特效的spine
function PlanesafkEvtItem:removeRemoveEffect(  )
     if self.remove_effect_spine then
        self.remove_effect_spine:clearTracks()
        self.remove_effect_spine:removeFromParent()
        self.remove_effect_spine = nil
    end
end


function PlanesafkEvtItem:onClickBtn(sender, event_type)
    if not self.evt_cfg then return end
    if event_type == ccui.TouchEventType.began then
        self.touch_began_pos = sender:getTouchBeganPosition()
    elseif event_type == ccui.TouchEventType.ended then
        local touch_end = sender:getTouchEndPosition()
        if self.touch_began_pos and touch_end and (math.abs(touch_end.x - self.touch_began_pos.x) <= 20 and math.abs(touch_end.y - self.touch_began_pos.y) <= 20) then 

           controller:onHandlePlanesEvtById(self.evt_cfg.type, self.data)
        end 
    end
end

-- 显示角色信息角色
function PlanesafkEvtItem:showRoleInfo( )
    self:updateEvtInfo(false)
    if not self.layer_bg then return end
    if not self.map_role then
        self:showRoleShowEffect(true, PlayerAction.action_2)
    end
    self:removeRoleInfo(true)
    local look_id = model:getPlanesRoleLookId()
    local figure_cfg = Config.HomeData.data_figure[look_id]
    local effect_id = "H60001"
    if figure_cfg then
        effect_id = figure_cfg.look_id
    end
    self.map_role = createEffectSpine( effect_id, cc.p(0, 0), cc.p(0.5, 0), true, PlayerAction.idle )
    self.map_role:setScale(0.4)
    -- self.map_role:setTimeScale(1.6)
    self.layer_bg:addChild(self.map_role)
    self.map_role:setPosition(self.size.width*0.5, self.size.height*0.5)
end

function PlanesafkEvtItem:showRoleShowEffect(status, action)
    if status then
        local action = action or PlayerAction.action_1
        if self.role_show_effect == nil then
            self.role_show_effect = createEffectSpine("E27533", cc.p(90, 82), cc.p(0.5, 0.5), false, action , function()
                self.role_show_effect:setVisible(false)
            end)
            self.root_wnd:addChild(self.role_show_effect)
        else
            self.role_show_effect:setVisible(true)
            self.role_show_effect:setAnimation(0, action, false)
        end
    else
        if self.role_show_effect then
            self.role_show_effect:clearTracks()
            self.role_show_effect:removeFromParent()
            self.role_show_effect = nil
        end
    end
end

function PlanesafkEvtItem:removeRoleInfo(not_show)
     if self.map_role then
        self.map_role:clearTracks()
        self.map_role:removeFromParent()
        self.map_role = nil
        self.cur_look_id = nil
        if not not_show then
            self:showRoleShowEffect(true)
        end
    end
end

function PlanesafkEvtItem:updateEvtInfo(status, is_hide )
    if status then
        self:removeRoleInfo()
        if not self.layer_bg then return end
        if self.data.evt_config == nil then
            self.data.evt_config = Config.PlanesData.data_evt_info[self.data.evt_id]
        end
        self.evt_cfg = self.data.evt_config
        if not self.evt_cfg then return end

        local line = model:getRolePos()
        if self.evt_cfg.is_hide == 1 and self.data.is_black and self.data.line > line + 2 then
            self:hideEvtInfo()
            return
        end

        local  res_info = self.evt_cfg.res_1
        if res_info and next(res_info) ~= nil then
            local res_type = res_info[1]
            local res_name = res_info[2]
            if not self.cur_res_name or self.cur_res_name ~= res_name then
                self.cur_res_name = res_name
                self:removeEvtEffect()
                if res_type == 1 then -- 图片
                    local res_path = self:getEvtPathByResId(res_name)
                    if not self.evt_icon_sp then
                        self.evt_icon_sp = createSprite(nil, self.size.width*0.5, self.size.height*0.5, self.layer_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE, 2)
                    end
                    self.evt_icon_sp:setVisible(true)
                    if self.evt_cfg.reversal == 1 then -- 是否翻转
                        self.evt_icon_sp:setScaleX(-1)
                    else
                        self.evt_icon_sp:setScaleX(1)
                    end
                    self.evt_sp_load = loadSpriteTextureFromCDN(self.evt_icon_sp, res_path, ResourcesType.single, self.evt_sp_load, nil,function()
                        if self and self.data and self.data.is_black then
                            setChildDarkShader(true, self.evt_icon_sp)--变暗
                        else
                            setChildDarkShader(false, self.evt_icon_sp)--变回来
                        end
                    end)

                elseif res_type == 2 then -- 特效
                    local action = PlayerAction.action
                    if res_info[3] ~= nil then
                        action = res_info[3]
                    end
                    self.evt_effect = createEffectSpine(res_name, cc.p(self.size.width*0.5, self.size.height*0.5), cc.p(0.5, 0.5), true, action)
                    self.layer_bg:addChild(self.evt_effect, 2)
                    if self.data.is_black then
                        setChildDarkShader(true, self.evt_effect)--变暗
                    end
                    if self.evt_cfg.reversal == 1 then -- 是否翻转
                        self.evt_effect:setScaleX(-1)
                    else
                        self.evt_effect:setScaleX(1)
                    end
                    if self.evt_icon_sp then
                        self.evt_icon_sp:setVisible(false)
                    end
                end

                -- 位置偏移
                if self.evt_cfg.offset then
                    local offset_x = self.evt_cfg.offset[1] or 0
                    local offset_y = self.evt_cfg.offset[2] or 0
                    if self.evt_icon_sp then
                        self.evt_icon_sp:setPosition(self.size.width*0.5+offset_x, self.size.height*0.5+offset_y)
                    end
                    if self.evt_effect then
                        self.evt_effect:setPosition(self.size.width*0.5+offset_x, self.size.height*0.5+offset_y)
                    end
                end
            else
                if res_type == 1 and self.evt_icon_sp then
                    self.evt_icon_sp:setVisible(true)
                    if self and self.data and self.data.is_black then
                        setChildDarkShader(true, self.evt_icon_sp)--变暗
                    else
                        setChildDarkShader(false, self.evt_icon_sp)--变回来
                    end
                elseif res_type == 2 and self.evt_effect then
                    self.evt_effect:setVisible(true)
                    if self.data.is_black then
                        setChildDarkShader(true, self.evt_effect)--变暗
                    else
                        setChildDarkShader(false, self.evt_effect)--变回来
                    end
                end
            end
        else
            if self.evt_icon_sp then
                self.evt_icon_sp:setVisible(false)
            end
            self:removeEvtEffect()
            self.cur_res_name = nil
            self.evt_cfg = nil
        end
        --选中效果
        local line = model:getRolePos()
        if not self.data.is_black and self.data.line > line  then
            -- self:showSelectEvtInfo()
            self:showSelectEvtInfo()
        else
            if self.name_txt then
                self.name_txt:setVisible(false)
            end
            if self.fight_bg then
                self.fight_bg:setVisible(false)
            end

            if self.evt_icon_bg then
                doStopAllActions(self.evt_icon_bg)
                self.evt_icon_bg:setVisible(false)
            end
            if self.select_arrow_img then
                doStopAllActions(self.select_arrow_img)
                self.select_arrow_img:setVisible(false)
            end
        end
    else
        self:hideEvtInfo()
    end
end

--显示选中的事件
function PlanesafkEvtItem:showSelectEvtInfo()
    if self.evt_icon_bg == nil then
            self.evt_icon_bg = createSprite(nil, self.size.width*0.5, self.size.height*0.5, self.layer_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST,1)
        else
            self.evt_icon_bg:setVisible(true)
        end
        --doStopAllActions(self.evt_icon_bg)
        --local res_id = model:getMapResID()
        --local res, off_y = self:getSelectEvtIconBgPathByResId(res_id)
        --loadSpriteTexture(self.evt_icon_bg, res, LOADTEXT_TYPE_PLIST)
        --self.evt_icon_bg:setPositionY(off_y)
        --self.evt_icon_bg:setOpacity(100)
        --local fadein = cc.FadeIn:create(1)
        --local fadeout = cc.FadeTo:create(1.2, 100)
        --self.evt_icon_bg:runAction(cc.RepeatForever:create(cc.Sequence:create(fadein, fadeout)))
        
        if self.select_arrow_img == nil then
            local res = PathTool.getResFrame("planes_map","planesafk_01")
            self.select_arrow_img = createSprite(res, self.size.width*0.5, self.size.height*0.5 + 130, self.layer_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST,3)
        else
            self.select_arrow_img:setVisible(true)
        end
        doStopAllActions(self.select_arrow_img)
        local move_by_1 = cc.MoveTo:create(1, cc.p(self.size.width*0.5, self.size.height*0.5 + 180))
        local move_by_2 = cc.MoveTo:create(0.8, cc.p(self.size.width*0.5, self.size.height*0.5 + 130))

        self.select_arrow_img:runAction(cc.RepeatForever:create(cc.Sequence:create(move_by_1,move_by_2)))
        --名字
        self:updateNameTxt(offset_x, offset_y)
end
function PlanesafkEvtItem:hideEvtInfo()
    if self.evt_icon_sp then
        self.evt_icon_sp:setVisible(false)
    end
    if self.name_txt then
        self.name_txt:setVisible(false)
    end
    if self.fight_bg then
        self.fight_bg:setVisible(false)
    end
    if self.evt_icon_bg then
        doStopAllActions(self.evt_icon_bg)
        self.evt_icon_bg:setVisible(false)
    end
    if self.select_arrow_img then
        doStopAllActions(self.select_arrow_img)
        self.select_arrow_img:setVisible(false)
    end
    self:removeEvtEffect()
    self.cur_res_name = nil
    self.evt_cfg = nil
end

function PlanesafkEvtItem:updateNameTxt( offset_x, offset_y )
    if not self.evt_cfg then return end
    if self.evt_cfg.type == PlanesafkConst.Evt_Type.Monster or self.evt_cfg.type == PlanesafkConst.Evt_Type.Guard then

        if self.fight_bg == nil then
            self.fight_bg = ccui.Widget:create()
            self.layer_bg:addChild(self.fight_bg, 4)

            local res = PathTool.getResFrame("common","common_1158")
            --local power_bg = createScale9Sprite(res, self.size.width*0.5, 46,  LOADTEXT_TYPE_PLIST,self.fight_bg)
            --power_bg:setScale(10, 0.7)
            --power_bg:setCapInsets(cc.rect(68, 1, 1, 1))
            --power_bg:setContentSize(cc.size(200, 46))
            --local res = PathTool.getResFrame("common","common_2016")
            --local icon_bg = createSprite(res, 30, 45, self.fight_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            --icon_bg:setScale(0.7)
            
            self.fight_txt = createLabel(22, Config.ColorData.data_new_color4[1], Config.ColorData.data_new_color4[11], 100, 46, "", self.fight_bg, 2, cc.p(0.5, 0.5))

        else
            self.fight_bg:setVisible(true)
        end
        if self.data and self.data.combat_power then
            if self.data.combat_power == 0 then
                self.fight_txt:setString("???")
            else
                self.fight_txt:setString(string.format(TI18N("战力:%d"),changeBtValueForPower(self.data.combat_power)))
            end
        end

        if self.name_txt then
            self.name_txt:setVisible(false)
        end
    else
        if not self.name_txt then
            self.name_txt = createLabel(22, Config.ColorData.data_new_color4[1], Config.ColorData.data_new_color4[6], 0, 46, "", self.layer_bg, 2, cc.p(0.5, 0.5))
        else
            self.name_txt:setVisible(true)
        end
        self.name_txt:setLocalZOrder(99)
        self.name_txt:setString(self.evt_cfg.name)
        -- self.name_txt:setString("名字")
        self.name_txt:setPosition(self.size.width*0.5, 50)
        self.name_txt:setVisible(true)

        if self.fight_bg then
            self.fight_bg:setVisible(false)
        end
    end
end


function PlanesafkEvtItem:setVisible( status )
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end
end

function PlanesafkEvtItem:setPosition( pos_x, pos_y )
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setPosition(pos_x, pos_y-PlanesConst.Grid_Height*0.5)
    end
end

function PlanesafkEvtItem:setLocalZOrder( zorder )
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setLocalZOrder(zorder)
    end
end

-- 获取事件图标资源
function PlanesafkEvtItem:getEvtPathByResId( res_id )
    if res_id and res_id ~= "" then
        return string_format("resource/planes/evt_icon/%s.png", res_id)
    end
end

-- 获取事件图标资源和调整位置 y
function PlanesafkEvtItem:getSelectEvtIconBgPathByResId( res_id )
    if res_id == "11" then
        return PathTool.getResFrame("planes_map","planesafk_04"), 71
    elseif res_id == "12" then
        return PathTool.getResFrame("planes_map","planesafk_02"), 64
    else
        return PathTool.getResFrame("planes_map","planesafk_05"), 64
    end
end
-- 获取事件被一次的特效id 和位置
function PlanesafkEvtItem:getRemoveEvtIconBgEffectId(res_id )
    if res_id == "11" then
        return "E27601"
    elseif res_id == "12" then
        return "E27602"
    else
        return "E27603"
    end
end

-- 显示入场动画
function PlanesafkEvtItem:showEvtEnterAni( delay_time )
    if not tolua.isnull(self.root_wnd) then
        local pos_x, pos_y = self.root_wnd:getPosition()
        local callback = function (  )
            self.root_wnd:setOpacity(0)
            self.root_wnd:setVisible(true)
            self.root_wnd:setScale(0.1)
        end
        local fade_in = cc.FadeIn:create(0.4)
        local scale_to = cc.ScaleTo:create(0.4, 1)
        local delay_act = cc.DelayTime:create(delay_time+0.3)
        self.root_wnd:runAction(cc.Sequence:create(delay_act, cc.CallFunc:create(callback), cc.Spawn:create(fade_in, scale_to)))
    end
end

function PlanesafkEvtItem:showClickAni(  )
    local move_by_1 = cc.EaseBackOut:create(cc.MoveBy:create(0.1, cc.p(0, 20)))
    local move_by_2 = cc.EaseBackOut:create(cc.MoveBy:create(0.1, cc.p(0, -20)))
    local act_1 = cc.Spawn:create(move_by_1, cc.ScaleTo:create(0.1, 1.1))
    local act_2 = cc.Spawn:create(move_by_2, cc.ScaleTo:create(0.1, 0.9))
    self.root_wnd:runAction(cc.Sequence:create(act_1, act_2, (cc.ScaleTo:create(0.05, 1.0))))
end

function PlanesafkEvtItem:removeEvtEffect(  )
     if self.evt_effect then
        self.evt_effect:clearTracks()
        self.evt_effect:removeFromParent()
        self.evt_effect = nil
    end
end

function PlanesafkEvtItem:__delete()
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end
    if self.evt_sp_load then
        self.evt_sp_load:DeleteMe()
        self.evt_sp_load = nil
    end
    if self.bg_item_load then
        self.bg_item_load:DeleteMe()
        self.bg_item_load = nil
    end

    self:removeRemoveEffect()
    self:removeEvtEffect()
    self:showRoleShowEffect(false)
    if self.root_wnd:getParent() then
        self.root_wnd:removeAllChildren()
        self.root_wnd:removeFromParent()
    end
end