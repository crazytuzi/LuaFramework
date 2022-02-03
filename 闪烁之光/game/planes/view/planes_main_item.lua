-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      位面冒险主界面 item
-- <br/>Create: 2019-11-26
-- --------------------------------------------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

PlanesMainItem = class("PlanesMainItem", function()
    return ccui.Widget:create()
end)

function PlanesMainItem:ctor()
    self:createRootWnd()
    self:registerEvent()
end

function PlanesMainItem:createRootWnd( )
    self.size = cc.size(223, 284)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("planes/planes_main_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    container:setSwallowTouches(false)
    self.con_size = container:getContentSize()
    self.container = container

    self.icon_sp = container:getChildByName("icon_sp")
    self.image_bg = container:getChildByName("image_bg")
    self.pos_node = container:getChildByName("pos_node")
    self.progress_bg = container:getChildByName("progress_bg")
    self.progress = self.progress_bg:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)
    self.progress_value = self.progress_bg:getChildByName("progress_value")
    self.progress_value:setString(0)

    self.name_txt = container:getChildByName("name_txt")
    self.camp_sp = container:getChildByName("camp_sp")
    self.tips_txt = container:getChildByName("tips_txt")
    self.tips_txt:setVisible(false)
    self.award_txt = container:getChildByName("award_txt")
    self.award_txt:setVisible(false)
end

function PlanesMainItem:registerEvent( )
    registerButtonEventListener(self.container, handler(self, self.onClickItem), true)

    -- 显示副本开启特效，并且进入副本场景
    if not self.show_open_effect_event then
        self.show_open_effect_event = GlobalEvent:getInstance():Bind(PlanesEvent.Dun_Open_Effect_Event, function ( data )
            if data and self.data and data.id == self.data.id then
                self.open_param = data
                self.tips_txt:setVisible(false)
                self.award_txt:setVisible(false)
                self:showDunOpenEffect(true)
            end
        end)
    end
end

function PlanesMainItem:onClickItem(  )
    if not self.data then return end
    if self.data.dun_status == PlanesConst.Dun_Status.Chose or self.data.dun_status == PlanesConst.Dun_Status.Select then
        _controller:sender23123(self.data.id)
        _controller:openPlanesDunInfoWindow(true, self.data.id)
    end
end

function PlanesMainItem:setData( data, index )
    if not data or not index then return end

    self.index = index

    -- 引导需要
    self.container:setName("guide_planes_item_" .. data.id)

    -- 从待选择变为已选择，需要先播放开启特效，再进入场景
    if self.data and self.data.dun_status == PlanesConst.Dun_Status.Chose and data.dun_status == PlanesConst.Dun_Status.Select then
        self.data = data
        return
    end

    self.data = data

    -- 名称
    self.name_txt:setString(data.name)
    
    self:updateInfo()
end

function PlanesMainItem:updateInfo(  )
    if not self.data then return end

    local dun_cfg = Config.SecretDunData.data_customs[self.data.id]
    if not dun_cfg then return end

    -- 阵营
    local res_path = self:getCampResPathById(dun_cfg.camp)
    loadSpriteTexture(self.camp_sp, res_path, LOADTEXT_TYPE_PLIST)

    -- 状态
    self.tips_txt:setVisible(false)
    self.award_txt:setVisible(false)
    self.progress_bg:setVisible(false)
    if self.lock_tips_txt then
        self.lock_tips_txt:setVisible(false)
    end
    self:handleEffect(false)
    local bg_res = PathTool.getResFrame("planes", "planes_main_1002", false, "planes_main")
    if self.data.dun_status == PlanesConst.Dun_Status.Chose then -- 待选择
        self.tips_txt:setString(TI18N("点击开启副本"))
        self.tips_txt:setVisible(true)
        --[[ self.award_txt:setString(dun_cfg.award_desc or "")
        self.award_txt:setVisible(true) ]]
    elseif self.data.dun_status == PlanesConst.Dun_Status.Select then -- 已选择
        self.progress_bg:setVisible(true)
        local cur_pro_val, max_pro_val = _model:getCurDunProgressVal()
        local percent = math.floor(cur_pro_val/max_pro_val*100)
        if percent > 100 then
            percent = 100
        end
        self.progress:setPercent(percent)
        self.progress_value:setString(percent .. "%")
        self:handleEffect(true, 1704)
    elseif self.data.dun_status == PlanesConst.Dun_Status.Close then -- 关闭
        self.tips_txt:setString(TI18N("已选择其他副本"))
        self.tips_txt:setVisible(true)
    elseif self.data.dun_status == PlanesConst.Dun_Status.Lock then -- 锁住
        bg_res = PathTool.getResFrame("planes", "planes_main_1003", false, "planes_main")
        self.tips_txt:setVisible(false)
        --[[ self.award_txt:setString(dun_cfg.award_desc or "")
        self.award_txt:setVisible(true) ]]
        if not self.lock_tips_txt then
            self.lock_tips_txt = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(self.con_size.width*0.5, 95))
            self.lock_tips_txt:setString(TI18N("<div href=xxx fontcolor=#ff5d5d outline=2,#490912>尚未开启</div>"))
            self.container:addChild(self.lock_tips_txt)
            self.lock_tips_txt:addTouchLinkListener(function(type, value, sender, pos)
                if self.callback then
                    self.callback(pos, self.index, self.data.id)
                end
            end, { "click", "href" })
        end
        self.lock_tips_txt:setVisible(true)
    end

    if not self.cur_bg_res or self.cur_bg_res ~= bg_res then
        self.cur_bg_res = bg_res
        self.image_bg:loadTexture(bg_res, LOADTEXT_TYPE_PLIST)
    end

    -- 图片
    if self.data.dun_res_id then
        local sp_path = _string_format("resource/planes/dun_img/dun_img_%s.png", self.data.dun_res_id)
        self.icon_sp_load = loadSpriteTextureFromCDN(self.icon_sp, sp_path, ResourcesType.single, self.icon_sp_load, nil, function (  )
            if self.icon_sp and not tolua.isnull(self.icon_sp) then
                if self.data and self.data.dun_status == PlanesConst.Dun_Status.Close then
                    setChildUnEnabled(true, self.icon_sp)
                else
                    setChildUnEnabled(false, self.icon_sp)
                end
            end
        end)
    end

    self:updateRedStatus()
end

-- 更新红点显示
function PlanesMainItem:updateRedStatus(  )
    if not self.data then return end
    -- 红点
    if (self.data.dun_status == PlanesConst.Dun_Status.Chose or self.data.dun_status == PlanesConst.Dun_Status.Select) and _model:checkIsCanGetAwardByDunId(self.data.id) then
        addRedPointToNodeByStatus(self.container, true, -23, -228)
    else
        addRedPointToNodeByStatus(self.container, false)
    end
end

function PlanesMainItem:handleEffect( status, effect_id )
    if status == true then
        if not tolua.isnull(self.pos_node) and self.play_effect == nil then
            self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[effect_id], cc.p(0,0), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.pos_node:addChild(self.play_effect)
        end
    else
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    end
end

-- 副本开启特效
function PlanesMainItem:showDunOpenEffect( status )
    if status == true then
        if self.lock_callback then
            self.lock_callback(true)
        end
        if not tolua.isnull(self.container) and self.open_effect == nil then
            local pos_x, pos_y = self.pos_node:getPosition()
            self.open_effect = createEffectSpine(Config.EffectData.data_effect_info[1703], cc.p(pos_x, pos_y), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self.onOpenEffectEnd))
            self.container:addChild(self.open_effect)
        elseif self.open_effect then
            self.open_effect:setToSetupPose()
            self.open_effect:setAnimation(0, PlayerAction.action, false)
        end
    else
        if self.open_effect then
            self.open_effect:clearTracks()
            self.open_effect:removeFromParent()
            self.open_effect = nil
        end
    end
end

function PlanesMainItem:onOpenEffectEnd(  )
    if self.open_param then
        self:updateInfo()
        delayOnce(function (  )
            if not self then return end
            if not self.open_param then return end
			local param = {}
            param.dun_id = self.open_param.id
            param.floor = self.open_param.floor
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.PlanesWar, param)
            self.open_param = nil
            if self.lock_callback then
                self.lock_callback(false)
            end
        end, 0.3)
    else
        self:updateInfo()
    end
end

function PlanesMainItem:addCallBack( callback )
    self.callback = callback
end

-- 锁屏回调（播放开启特效时，需要锁屏）
function PlanesMainItem:addLockScreenCallBack( callback )
    self.lock_callback = callback
end

-- 根据配置的阵营id获取对应资源
function PlanesMainItem:getCampResPathById( id )
    if id == HeroConst.CampType.eWater then
        return PathTool.getResFrame("planes", "planes_main_1007", false, "planes_main")
    elseif id == HeroConst.CampType.eFire then
        return PathTool.getResFrame("planes", "planes_main_1008", false, "planes_main")
    elseif id == HeroConst.CampType.eWind then
        return PathTool.getResFrame("planes", "planes_main_1009", false, "planes_main")
    elseif id == HeroConst.CampType.eLight then
        return PathTool.getResFrame("planes", "planes_main_1010", false, "planes_main")
    elseif id == HeroConst.CampType.eDark then
        return PathTool.getResFrame("planes", "planes_main_1011", false, "planes_main")
    else
        return PathTool.getResFrame("planes", "planes_main_1007", false, "planes_main")
    end
end

function PlanesMainItem:suspendAllActions(  )
	
end

function PlanesMainItem:DeleteMe()
    if self.show_open_effect_event then
        GlobalEvent:getInstance():UnBind(self.show_open_effect_event)
        self.show_open_effect_event = nil
    end
    if self.icon_sp_load then
        self.icon_sp_load:DeleteMe()
        self.icon_sp_load = nil
    end
    self:showDunOpenEffect(false)
    self:handleEffect(false)
    self:removeAllChildren()
	self:removeFromParent()
end