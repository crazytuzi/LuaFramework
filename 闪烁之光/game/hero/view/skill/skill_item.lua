-- --------------------------------------------------------------------
-- 竖版技能item
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

SkillItem = class("SkillItem", function() 
    return ccui.Layout:create()
end)

SkillItem.Width = 119
SkillItem.Height = 119

function SkillItem:ctor(play_start, click, is_show_tips, scale, show_lev, swallow_touch)
    self.play = play_start
    self.click = click
    self.is_show_tips = is_show_tips or false
    self.scale = scale or 1
    self.can_reset_name = true
    self.show_lev = show_lev or false

    self.size = cc.size(SkillItem.Width, SkillItem.Height)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
    if self.scale ~= 1 then
        self:setScale(self.scale)
    end

    self:configUI()

    if self.click == true then
        self:setTouchEnabled(true)
        self:registerEvent()
        self:setSwallowTouches(swallow_touch)
    end
end

function SkillItem:setClickInfo(setting)
    setting  = setting or {}
    self.clickScroll = setting.clickScroll or false --是否点击滚动
    self.click = setting.click or false --是否能点击
    if self.click == true then
        self:setTouchEnabled(true)
        self:registerEvent()
    end
    self.swallow_touch = setting.swallow_touch or false --是否吞噬
    if self.swallow_touch == true then
        self:setSwallowTouches(self.swallow_touch)
    end
end

function SkillItem:configUI()
    --背景
    local res = PathTool.getNormalSkillBg()
    self.background = createImage(self, res,  self.size.width/2, self.size.height/2, cc.p(0.5,0.5), true, 0, true)
    self.background:setContentSize(self.size)
    --技能skill -- createSprite(res, x, y, container, anchorPoint, type, zorder)
    self.item_icon = createSprite(nil,  self.size.width/2, self.size.height/2, self, cc.p(0.5,0.5), LOADTEXT_TYPE, 0)

    --技能等级
    if self.show_lev then
        local res = PathTool.getResFrame("common","common_2018")
        self.level_bg = createImage(self, res, 10,108, cc.p(0.5,0.5), true, 1, false)
        self.num_label = createLabel(20,cc.c4b(0x64,0x32,0x23,0xff),nil,8,107,"00",self,1, cc.p(0.5,0.5))
        self.num_label:setZOrder(1)
    end
end

function SkillItem:getSize()
    return self.size
end

function SkillItem:resetName(status)
    self.can_reset_name = status
end

function SkillItem:getData()
    return self.data
end
--==============================--
--desc:设置选中状态
--time:2017-07-03 09:07:12
--@status:
--@return 
--==============================--
function SkillItem:setSelected(status)
    if not self.select_bg and status == false then return end

    if not self.select_bg then 
        local res= PathTool.getSelectBg()
        self.select_bg = createImage(self, res, self.size.width/2,self.size.height/2, cc.p(0.5,0.5), true,1,true)
        self.select_bg:setContentSize(self.size)
        self.select_bg:setZOrder(1)
    end
    self.select_bg:setVisible(status)
end


function SkillItem:setTickSelected(status)
    if status then
        if self.lay_select == nil then
            self.lay_select = ccui.Layout:create()
            self.lay_select:setAnchorPoint(cc.p(0.5,0.5))
            self.lay_select:setContentSize(self.size)
            self.lay_select:setPosition(self.size.width/2, self.size.height/2) 
            self.lay_select:setTouchEnabled(false)
            showLayoutRect(self.lay_select, 150)
            local res = PathTool.getResFrame("common","common_1043")
            createImage(self.lay_select,res,self.size.width/2,self.size.height/2,cc.p(0.5,0.5),true,0,false)

            self:addChild(self.lay_select, 1)
        else
            self.lay_select:setVisible(true)
        end
    else
        if self.lay_select then
            self.lay_select:setVisible(false)
        end
    end
end

--==============================--
--desc:点击回调
--time:2017-07-03 08:02:23
--@callback:
--@return 
--==============================--
function SkillItem:addCallBack(callback)
    self.callback = callback
end

-- 特殊技能标识（元素圣殿用到，技能tips界面不显示一些东西）
function SkillItem:setTipsHideFlag( flag )
    self.tips_hide_flag = flag
end

-- 特殊显示技能tips中的释放回合数
function SkillItem:setSkillFirstCd( first_cd )
    self.first_cd = first_cd
end

-- 神器技能tips需要特殊显示
function SkillItem:setHallowsAtkVal( hallows_atk_val )
    self.hallows_atk_val = hallows_atk_val
end

--==============================--
--desc:注册相关事件
--time:2017-07-03 01:53:49
--@return 
--==============================--
function SkillItem:registerEvent()
    if self.click == true then
        self:addTouchEventListener(function(sender, event_type) 
            customClickAction(self, event_type, self.scale)

            if self.clickScroll then
                if event_type == ccui.TouchEventType.began then
                    self.touch_began = sender:getTouchBeganPosition()
                end    
            end
            if event_type == ccui.TouchEventType.ended then

                if self.clickScroll then
                    local touch_began = self.touch_began
                    local touch_end = sender:getTouchEndPosition()
                    if touch_began and touch_end and (math.abs(touch_end.x - touch_began.x) > 20 or math.abs(touch_end.y - touch_began.y) > 20) then 
                        --移动大于20了..表示本点击无效
                        return
                    end 

                end
                playButtonSound2()
                if self.btn_fun and (not self.data) then
                    self:btn_fun(self.add_btn_index)
                else
                    if self.is_show_tips == true then
                        if self.skill_config then
                            TipsManager:getInstance():showSkillTips(self.skill_config, self.is_unabled or false, false, self.tips_hide_flag or false, self.first_cd or 0, self.hallows_atk_val or 0)
                        elseif self.lock_tips then
                            message(self.lock_tips)
                        elseif self.none_tips then
                            message(self.none_tips)
                        end
                    end
                    if sender.guide_call_back ~= nil then
                        sender.guide_call_back(sender)
                    end
                    if self.callback then
                        self:callback()
                    end
                end
            end
        end)
    end
end

--==============================--
--desc:设置数据
--time:2018-05-16 03:21:17
--@data:
--@return 
--==============================--
function SkillItem:setData(data)
    self.data = data
    self:showRedPoint(false)
    if self.data == nil then
        self.skill_config = nil
        self.item_icon:setVisible(false)
        if self.num_label then
            self.num_label:setVisible(false)
        end
        self:showName(false)
        self.background_res_id = PathTool.getQualityBg(0)
        self.background:loadTexture(self.background_res_id, LOADTEXT_TYPE_PLIST)
        return
    else
        local id = data.skill_bid or  data.skill_id or data.bid
        local skill_config = Config.SkillData.data_get_skill(id)
        if not skill_config then return end
        self.skill_config = skill_config
        local skill_icon = PathTool.getSkillRes(skill_config.icon, false)
        self.item_icon:setVisible(true)
        loadSpriteTexture(self.item_icon, skill_icon, LOADTEXT_TYPE)

        local background_res_id = PathTool.getQualityBg(0)
        if skill_config.type == "passive_skill" then
            -- background_res_id = PathTool.getQualityBg(skill_config.level-1)
        end

        if self.background_res_id ~= background_res_id then
            self.background_res_id = background_res_id
            self.background:loadTexture(self.background_res_id, LOADTEXT_TYPE_PLIST)
        end

        -- 显示等级,现在只有天赋技能显示等级
        if self.show_lev and self.num_label then
            if skill_config.client_lev and skill_config.client_lev > 0 then
                self.num_label:setVisible(true)
                self.num_label:setString(skill_config.client_lev)
            elseif skill_config.level and skill_config.level > 0 then
                self.num_label:setVisible(true)
                self.num_label:setString(skill_config.level)
            else
                self.num_label:setVisible(false)
            end
        end

        if data and data.is_show_name and data.is_show_name == true then
            self:showName(true,skill_config.name)
        end
        self:showRecommondIcon(false)
        if data and data.is_recommend and data.is_recommend == true then 
            self:showRecommondIcon(true)
        end
        if data and data.is_learn and data.is_learn ==true then 
            self:showRecommondIcon(true,2)
        end

        -- 引导需要
        if data then
            if self.can_reset_name == true then
                self:setName("guidesign_skillitem_"..id)
            end
        end

        --是否觉醒天赋
        local partner_awakening_skill_config = Config.PartnerSkillData.data_partner_awakening_skill
        if partner_awakening_skill_config and partner_awakening_skill_config[id] then
            --是13星英雄 的觉醒天赋
            self:showAwakeningSkillIcon(true, partner_awakening_skill_config[id])
        else
            self:showAwakeningSkillIcon(false)
        end
    end 
    
    if data and data.is_touch and data.is_touch == true then 
        if self.callback then
            self:callback()
        end
        data.is_touch = false
    end
    if data and data.scale_value and type(data.scale_value) == "number" then 
        self.root_wnd:setScale(data.scale_value)
    end
end

function SkillItem:setGrayStatus(bool)
    local num = 255
    if bool == true then 
        num = 160
    end
    self.item_icon:setOpacity(num)
end

--变灰
function SkillItem:showUnEnabled(bool)
    setChildUnEnabled(bool, self.item_icon)
    setChildUnEnabled(bool, self.background)
    if self.level_bg then
        setChildUnEnabled(bool, self.level_bg)
    end
    self.is_unabled = bool
end
--锁
function SkillItem:showLockIcon(bool,str,tips)
    if bool == false and not self.artifact_lock then return end
    if not self.artifact_lock then 
        local res = PathTool.getResFrame("common","common_90009")
        self.artifact_lock = createImage(self, res, 60,60, cc.p(0.5,0.5), true, 1, false)

        self.lock_label = createLabel(22,cc.c4b(0xd9,0xcc,0xbb,0xff),cc.c4b(0x56,0x25,0x12,0xff),57,12,"",self,1, cc.p(0.5,0))
    end
    str = str or ""
    self.artifact_lock:setVisible(bool)
    self.lock_label:setVisible(bool)
    self.lock_label:setString(str)
    self.lock_tips = tips
end
--推荐标签
function SkillItem:showRecommondIcon(bool,qian_type)
    if bool == false and not self.recommond_icon then return end
    if not self.recommond_icon then 
        local res = PathTool.getResFrame("common","common_90015")

        -- self.recommond_icon = createImage(self,res,34,89,cc.p(0.5,0.5),true,10,true)
        self.recommond_icon = createSprite(res,34,89,self,cc.p(0.5,0.5),nil,2)
        self.recommond_label = createLabel(18,Config.ColorData.data_color4[1],cc.c4b(0x95,0x0f,0x00,0xff),29,25,"",self.recommond_icon,2, cc.p(0.5,0))
        self.recommond_label:setRotation(-45)
        
    end
    if bool == true then
        self.recommond_icon:setVisible(true)
        local qian_type = qian_type or 1
        local str 
        local res 
        if qian_type == 1 then
            str = TI18N("推荐")
            res = PathTool.getResFrame("common","common_30016") --紫色
            self.recommond_icon:setPosition(31,87)
            self.recommond_label:setPosition(31,37)
            self.recommond_label:enableOutline(cc.c4b(0x5c,0x1b,0x77,0xff), 2)
        elseif qian_type == 2 then
            str = TI18N("已领悟")
            res = PathTool.getResFrame("common","common_30013") --红色
            self.recommond_icon:setPosition(31,87)
            self.recommond_label:setPosition(31,37)
            self.recommond_label:enableOutline(cc.c4b(0x8e,0x2b,0x00,0xff), 2)
        elseif qian_type ==3 then
            str = TI18N("神器")
            res = PathTool.getResFrame("common","common_90015") --位置不同的红色
            self.recommond_icon:setPosition(34,89)
            self.recommond_label:setPosition(29,25)
            self.recommond_label:enableOutline(cc.c4b(0x95,0x0f,0x00,0xff), 2)
        elseif qian_type == 4 then
            str = TI18N("觉")
            res = PathTool.getResFrame("common","common_90015")--位置不同的红色
            self.recommond_icon:setPosition(34,89)
            self.recommond_label:setPosition(29,25)
            self.recommond_label:enableOutline(cc.c4b(0x95,0x0f,0x00,0xff), 2)
        elseif qian_type == 5 then
            str = TI18N("可领悟")
            res = PathTool.getResFrame("common","common_30015") --蓝色
            self.recommond_icon:setPosition(31,87)
            self.recommond_label:setPosition(31,37)
            self.recommond_label:enableOutline(cc.c4b(0x00,0x55,0x74,0xff), 2)
        else
            --无效类型 自行打印
            self.recommond_icon:setVisible(false)
            return    
        end
        loadSpriteTexture(self.recommond_icon, res, LOADTEXT_TYPE_PLIST)
        self.recommond_label:setString(str)
    else
        self.recommond_icon:setVisible(false)        
    end
    
end

-- 稀有标识
function SkillItem:showUnusualIcon( status ,type)--type 1：稀有  2：强力
    if status == false and not self.unusual_icon then return end
    if not self.unusual_icon then  
        self.unusual_icon = createSprite(nil,-6,123,self,cc.p(0,1),nil,2)
    end

    if status == true then
        local res = PathTool.getResFrame("common","txt_cn_common_unusual")
        if type and type == 2 then
            res = PathTool.getResFrame("common","txt_cn_common_unusual_2")
        end
        loadSpriteTexture(self.unusual_icon, res, LOADTEXT_TYPE_PLIST)
    end
    
    self.unusual_icon:setVisible(status)
end
-- 显示13星觉醒技能标志
function SkillItem:showAwakeningSkillIcon( status , partner_awakening_skill_config)
    if status == false and not self.awakening_icon then return end
    if not self.awakening_icon then  
        self.awakening_icon = createSprite(PathTool.getResFrame("common","common_1108"),60,127,self,cc.p(0.5,1),nil,2)
    end
    self.awakening_icon:setVisible(status)
    if partner_awakening_skill_config then
        if status then
            if self.skill_profession_icon == nil then
                self.skill_profession_icon = createSprite(nil,102,36,self,cc.p(0.5,1),nil,2)
                local res = PathTool.getPlistImgForDownLoad("bigbg/hero", "talent_profession")
                self.skill_profession_icon_item_load = loadSpriteTextureFromCDN(self.skill_profession_icon, res, ResourcesType.single, self.skill_profession_icon_item_load)
            end
            if self.skill_profession_label == nil then
                self.skill_profession_label = createLabel(20,cc.c3b(0xff,0xf6,0xcc),nil,14.5,17,"",self.skill_profession_icon,1, cc.p(0.5,0.5))
            end
            local limit_career = partner_awakening_skill_config.limit_career or {}
            local profession_name
            if limit_career and next(limit_career) ~= nil then
                --目前只有一个职业拿第一个
                profession_name = HeroConst.CareerName2[limit_career[1][1]] or TI18N("物")
            else
                profession_name = TI18N("物")
            end
            self.skill_profession_label:setString(profession_name)  
        end
    end
    if self.skill_profession_icon then
        self.skill_profession_icon:setVisible(status)
    end
end

--显示下方的名字
function SkillItem:showName(bool,name,pos,fontSize, is_bg,fontColor,res_img,res_size)
    if bool == false and not self.name then return end
    if not self.name then 
        if is_bg and self.name_bg == nil then
            local res = res_img or PathTool.getResFrame("common","common_2028")
            local resSize = res_size or cc.size(108,30)
            self.name_bg = createImage(self, res, 60,-32, cc.p(0.5,0), true, 0, true)
            self.name_bg:setContentSize(resSize)
            self.name_bg:setCapInsets(cc.rect(10, 14, 1, 1))
        end
        fontSize = fontSize or 24
        fontColor = fontColor or Config.ColorData.data_color4[156]
        self.name = createLabel(fontSize,fontColor,nil,60,-30,"",self,1, cc.p(0.5,0))
    end
    name = name or ""
    self.name:setString(name)
    self.name:setVisible(bool)
    if self.name_bg then
        self.name_bg:setVisible(bool)
    end
    if pos then 
        self.name:setPosition(pos)
        if self.name_bg then
            self.name_bg:setPosition(cc.p(pos.x,pos.y -2))
        end
    end
end
-- 修改名字颜色
function SkillItem:setNameColor( nameColor, outlineColor, outlineSize )
    if self.name then
        if nameColor then
            self.name:setTextColor(nameColor)
        end
        if outlineColor and outlineSize then
            self.name:enableOutline(outlineColor, outlineSize)
        end
    end
end
--加号
function SkillItem:showAddIcon(bool,index)
    if bool == false and not self.add_btn then return end
    self.add_btn_index = index
    if not self.add_btn then 
        local res = PathTool.getResFrame("common","common_90026")
        self.add_btn = createSprite(res, 60, 60, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
        -- self.add_btn = createButton(self.root_wnd, "", 60,60, nil, res)
        -- self.add_btn:addTouchEventListener(function(sender, event_type) 
        --  if event_type == ccui.TouchEventType.ended then
        --      playButtonSound2()
        --      if self.btn_fun then
        --          self:btn_fun(index)
        --      end
        --  end
        -- end)
    end
    self.add_btn:setVisible(bool)
end

function SkillItem:showLevel( status )
    self.show_lev = status
    if status == true then
        if not self.level_bg then
            self.level_bg = createImage(self, PathTool.getResFrame("common","common_2018"), 10,108, cc.p(0.5,0.5), true, 1, false)
        end
        if not self.num_label then
            self.num_label = createLabel(20,cc.c4b(0x64,0x32,0x23,0xff),nil,8,107,"00",self,1, cc.p(0.5,0.5))
            self.num_label:setZOrder(1)
        end
        self.level_bg:setVisible(true)
        self.num_label:setVisible(true)
    else
        if self.level_bg then
            self.level_bg:setVisible(false)
        end
        if self.num_label then
            self.num_label:setVisible(false)
        end
    end
end

-- 显示“无”
function SkillItem:showNoneText( status, none_tips )
    if status == true then
        if not self.none_txt then
            self.none_txt = createLabel(32, cc.c4b(255,236,178,255), nil, self.size.width/2, self.size.height/2, TI18N("无"), self, nil, cc.p(0.5, 0.5))
        end
        self.none_txt:setVisible(true)
    elseif self.none_txt then
        self.none_txt:setVisible(false)
    end
    self.none_tips = none_tips
end

--红点
function SkillItem:showRedPoint(bool)
    if self.skill_config and self.skill_config.next_id ==0 then 
        bool = false
    end
    if bool == false and not self.red_point then return end
    if not self.red_point then 
        local res = PathTool.getResFrame("common","common_1014")
        self.red_point = createImage(self,res,107,107,cc.p(0.5,0.5),true,10,false)
        self.red_point:setScale(0.7)
    end
    self.red_point:setVisible(bool)
end

-- 箭头红点红点
function SkillItem:showArrowRedPoint(bool)
    if bool == false and not self.arrow_red_point then return end
    if not self.arrow_red_point then 
        local res = PathTool.getResFrame("common","common_1086")
        self.arrow_red_point = createImage(self,res,103,100,cc.p(0.5,0.5),true,10,false)
        -- self.arrow_red_point:setScale(0.7)
    end
    self.arrow_red_point:setVisible(bool)
end
function SkillItem:setAddBtnFun(btn_fun)
    self.btn_fun = btn_fun
end

function SkillItem:isHaveData()
    if not self.data or next(self.data) ==nil then return false end

    return true
end

function SkillItem:getSkillConfig()
    return self.skill_config
end

function SkillItem:DeleteMe()
    if self.skill_profession_icon_item_load then
        self.skill_profession_icon_item_load:DeleteMe()
        self.skill_profession_icon_item_load = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end