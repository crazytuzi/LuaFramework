
-- --------------------------------------------------------------------
-- 
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      荣誉墙icon
-- <br/>2019年6月3日
-- --------------------------------------------------------------------
RoleHonorItem = class("RoleHonorItem", function() 
    return ccui.Layout:create()
end)

RoleHonorItem.Width = 104
RoleHonorItem.Height = 120

function RoleHonorItem:ctor(scale, can_click, click_delay, can_effect, not_swallow)
    self.scale = scale or 1
    self.can_click = can_click or false
    self.click_delay = self.click_delay
    self.last_click_time = 0 -- 最后一次点击的时间

    self.size = cc.size(HeroExhibitionItem.Width,HeroExhibitionItem.Height)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
    if self.can_click then
        self:setTouchEnabled(true)
    else
        self:setTouchEnabled(false)
    end
    self:setCascadeOpacityEnabled(true)
    self:setScale(self.scale)

    self.icon = createSprite(nil, self.size.width/2,self.size.height/2, self, cc.p(0.5,0.5), LOADTEXT_TYPE)

    self:registerEvent()
end



function RoleHonorItem:addCallBack(callback)
    self.callback = callback
end

function RoleHonorItem:setShowDefaultTips()
    self.is_show_default_tips = true
    if self.can_click == false then
        self.can_click = true
        self:registerEvent()
    end
    
end

function RoleHonorItem:registerEvent()
    if self.can_click == true then
        self:addTouchEventListener(function(sender, event_type) 
            customClickAction_2(self, event_type, self.scale)
            if event_type == ccui.TouchEventType.ended and self.can_click == true and self:checkItemClickDelayTime() then
                playButtonSound2()
                if self.is_show_default_tips then
                    if not self.config then 
                        TipsController:getInstance():openHonorIconTips(true, {config = self.config})
                    end
                else
                    if self.callback then
                        self.callback()
                    end
                end
                -- -- 引导需要
                -- if sender.guide_call_back ~= nil then
                --     sender.guide_call_back(sender)
                -- end
            end
        end)
    end
end

-- 判断是否有点击间隔时间的要求
function RoleHonorItem:checkItemClickDelayTime(  )
    if self.click_delay and self.click_delay > 0 then
        if math.abs(GameNet:getInstance():getTimeFloat() - self.last_click_time) < self.click_delay then
            return false
        else
            self.last_click_time = GameNet:getInstance():getTimeFloat()
            return true
        end
    else
        return true
    end
end

--@data 结构 {id = id }
function RoleHonorItem:setData(data)
    if data == nil then
        self.icon:setVisible(false)
    else
        self.icon:setVisible(true)
    end

    self.config = data.config 
    if self.config == nil then
        --容错
        self.config = Config.RoomFeatData.data_honor_icon_info[data.id]
    end
    if not self.config then return end

    self:setIcon(self.config.icon_res)
end

--设置显示特效
function RoleHonorItem:setShowEffect(status)
    if not self.config then return end
    if status then
        if self.config.effect_res == nil or self.config.effect_res == "" then
            self:showEffect(false)
        else
            self:showEffect(true, self.config.effect_res)
        end
    else
        self:showEffect(false)
    end
end

--==============================--
--desc:设置头像
--time:2019-01-24 09:31:58
--@head_icon:
--@return 
--==============================--
function RoleHonorItem:setIcon(icon_res)
    if icon_res == nil or icon_res == "" then return end
    local icon_res = tostring(icon_res)
    if self.record_icon_res == nil or self.record_icon_res ~= icon_res then
        self.record_icon_res = icon_res      
        local res = PathTool.getPlistImgForDownLoad("rolehonorwall/honorwarllicon", icon_res, false)
        loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
    end
end

--设置头像变化  
--@bool  true 变灰  false 原来颜色样子
function RoleHonorItem:setIconUnEnabled(bool)
    if self.icon then
        setChildUnEnabled(bool, self.icon)
    end
end

function RoleHonorItem:setShowLock(status)
    if status then
        if self.lock_icon == nil then
            local res = PathTool.getResFrame("common","common_90009")
            self.lock_icon =createImage(self, res, self.size.width/2, 70, cc.p(0.5,0.5),true,0,false)
        else
            self.lock_icon:setVisible(true)
        end
        self:setIconUnEnabled(true)
    else
        self:setIconUnEnabled(false)
        if self.lock_icon then
            self.lock_icon:setVisible(false)
        end
    end
end

function RoleHonorItem:showEffect(bool, effect_id)
    if bool == true then
        if self.play_effect == nil then
            self.play_effect = createEffectSpine(effect_id, cc.p(self.size.width/2,self.size.height/2), cc.p(0.5, 0.5), true, PlayerAction.action)
            self:addChild(self.play_effect, 1)
        end    
    else
        if self.play_effect then 
            self.play_effect:setVisible(false)
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    end
end


function RoleHonorItem:DeleteMe()
    self:showEffect(false)
    self:removeAllChildren()
    self:removeFromParent()
end