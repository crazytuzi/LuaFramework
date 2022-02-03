-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      位面冒险 事件显示
-- <br/>Create: 2019-12-04
-- --------------------------------------------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

PlanesEvtItem = PlanesEvtItem or BaseClass()

function PlanesEvtItem:__init(parent)
    self.parent = parent
	self:createRootWnd()
    self:registerEvent()
end

function PlanesEvtItem:createRootWnd( )
    self.size = cc.size(PlanesConst.Grid_Width, PlanesConst.Grid_Height)
	self.root_wnd = ccui.Widget:create()
	self.root_wnd:setAnchorPoint(cc.p(0.5, 0))
	self.root_wnd:setContentSize(self.size)
    
    self.parent:addChild(self.root_wnd)
end

function PlanesEvtItem:registerEvent( )

end

-- data 为 PlanesEvtVo is_hide:为新创建的事件，需要先隐藏，再播动画显示
function PlanesEvtItem:setData( data, is_hide )
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end

    if data ~= nil then
        self.data = data
        if self.update_self_event == nil then
            self.update_self_event = self.data:Bind(PlanesEvent.Update_Evt_Status_Event, function()
                self:updateEvtInfo()
            end)
        end
        self:updateEvtInfo(is_hide)
	end
end

function PlanesEvtItem:updateEvtInfo( is_hide )
    if not self.data then return end

    self.evt_cfg = self.data.config or {}

    if self.data.is_hide == 1 then -- 后端告知要隐藏
        self:setVisible(false)
        return
    else
        self:setVisible(not is_hide)
    end
    
    -- 图标或特效
    local res_info = {}
    if self.evt_cfg.type == PlanesConst.Evt_Type.Stage then -- 升降台,根据升降状态判断
        if self.data.platform == 1 then -- 升起来
            res_info = self.evt_cfg.res_1
        else
            res_info = self.evt_cfg.res_2
        end
    elseif self.evt_cfg.type == PlanesConst.Evt_Type.Stage then -- 开关，根据开关状态判断
        if self.data.switch == 0 then -- 关着显示资源1
            res_info = self.evt_cfg.res_1
        else
            res_info = self.evt_cfg.res_2
        end
    elseif self.data.status == PlanesConst.Evt_State.Down then -- 已完成
        res_info = self.evt_cfg.res_2
    else
        res_info = self.evt_cfg.res_1
    end
    if res_info and next(res_info) ~= nil then
        local res_type = res_info[1]
        local res_name = res_info[2]
        if not self.cur_res_name or self.cur_res_name ~= res_name then
            self.cur_res_name = res_name
            if self.evt_effect then
                self.evt_effect:clearTracks()
                self.evt_effect:removeFromParent()
                self.evt_effect = nil
            end
            if res_type == 1 then -- 图片
                local res_path = self:getEvtPathByResId(res_name)
                if not self.evt_icon_sp then
                    self.evt_icon_sp = createSprite(nil, self.size.width*0.5, self.size.height*0.5, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE)
                end
                self.evt_icon_sp:setVisible(true)
                if self.evt_cfg.reversal == 1 then -- 是否翻转
                    self.evt_icon_sp:setScaleX(-1)
                else
                    self.evt_icon_sp:setScaleX(1)
                end
                self.evt_sp_load = loadSpriteTextureFromCDN(self.evt_icon_sp, res_path, ResourcesType.single, self.evt_sp_load)
            elseif res_type == 2 then -- 特效
                self.evt_effect = createEffectSpine(res_name, cc.p(self.size.width*0.5, self.size.height*0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
                self.root_wnd:addChild(self.evt_effect)
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
                self:updateNameTxt(offset_x, offset_y)
            end
        else
            if res_type == 1 and self.evt_icon_sp then
                self.evt_icon_sp:setVisible(true)
            elseif res_type == 2 and self.evt_effect then
                self.evt_effect:setVisible(true)
            end
        end
    else
        if self.evt_icon_sp then
            self.evt_icon_sp:setVisible(false)
        end
        if self.name_txt then
            self.name_txt:setVisible(false)
        end
        if self.evt_effect then
            self.evt_effect:clearTracks()
            self.evt_effect:removeFromParent()
            self.evt_effect = nil
        end
        self.cur_res_name = nil
    end
end

function PlanesEvtItem:updateNameTxt( offset_x, offset_y )
    if self.evt_cfg.type ~= PlanesConst.Evt_Type.Normal and self.evt_cfg.type ~= PlanesConst.Evt_Type.Barrier then
        if not self.name_txt then
            self.name_txt = createLabel(18, 1, 2, 0, 10, "", self.root_wnd, 2, cc.p(0.5, 1))
        end
        self.name_txt:setLocalZOrder(99)
        self.name_txt:setString(self.evt_cfg.name)
        self.name_txt:setPosition(self.size.width*0.5+offset_x, offset_y)
        self.name_txt:setVisible(true)
    elseif self.name_txt then
        self.name_txt:setVisible(false)
    end
end

function PlanesEvtItem:setVisible( status )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end
end

function PlanesEvtItem:setPosition( pos_x, pos_y )
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setPosition(pos_x, pos_y-PlanesConst.Grid_Height*0.5)
    end
end

function PlanesEvtItem:setLocalZOrder( zorder )
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setLocalZOrder(zorder)
    end
end

-- 获取事件图标资源
function PlanesEvtItem:getEvtPathByResId( res_id )
	if res_id and res_id ~= "" then
        return _string_format("resource/planes/evt_icon/%s.png", res_id)
    end
end

-- 显示入场动画
function PlanesEvtItem:showEvtEnterAni( delay_time )
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

function PlanesEvtItem:showClickAni(  )
    local move_by_1 = cc.EaseBackOut:create(cc.MoveBy:create(0.1, cc.p(0, 20)))
    local move_by_2 = cc.EaseBackOut:create(cc.MoveBy:create(0.1, cc.p(0, -20)))
    local act_1 = cc.Spawn:create(move_by_1, cc.ScaleTo:create(0.1, 1.1))
    local act_2 = cc.Spawn:create(move_by_2, cc.ScaleTo:create(0.1, 0.9))
    self.root_wnd:runAction(cc.Sequence:create(act_1, act_2, (cc.ScaleTo:create(0.05, 1.0))))
end

function PlanesEvtItem:__delete()
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
    if self.evt_effect then
        self.evt_effect:clearTracks()
        self.evt_effect:removeFromParent()
        self.evt_effect = nil
    end
    if self.root_wnd:getParent() then
		self.root_wnd:removeAllChildren()
		self.root_wnd:removeFromParent()
	end
end