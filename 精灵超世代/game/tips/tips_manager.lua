TipsManager = TipsManager or BaseClass()

function TipsManager:getInstance()
    if not self.is_init then
        self.tips_list = {}
        self.delay = 0
        self.is_init = true
    end
    return self
end

function TipsManager:hideTips()
    for key, value in pairs(self.tips_list) do
        if value["close"] ~= nil then
            value:close()
            value = nil
        end
    end
    self.tips_list = {}
    GlobalEvent:getInstance():Fire(TipsEvent.TipsCloseEvent)
end

function TipsManager:ishideTips()
   return self.is_hide
end

--技能tips
function TipsManager:showSkillTips( skill_vo, is_lock, not_show_next, hide_flag, first_cd, hallows_atk_val )
    if type(skill_vo) == "number" then
      skill_vo = Config.SkillData.data_get_skill(skill_vo)
    end
    local skill_tips = SkillTips.New()
    skill_tips:open(skill_vo, is_lock, not_show_next, hide_flag, first_cd, hallows_atk_val)
    table.insert(self.tips_list,skill_tips)
    return skill_tips
end

-- 圣物技能tips
function TipsManager:showHalidomSkillTips( skill_id )
    local halidom_skill_tips = HalidomSkillTips.New()
    halidom_skill_tips:open(skill_id)
    table.insert(self.tips_list,halidom_skill_tips)
    return halidom_skill_tips
end

--带技能等级的技能tips
-- function TipsManager:showOtherSkillTips( skill_vo,is_pokex)
--     local skill_tips = SkillTips.New()
--     skill_tips:open(skill_vo, is_pokex)
--     table.insert(self.tips_list,skill_tips)
--     return skill_tips
-- end

--道具tips
--显示通用物品Tips
function TipsManager:showGoodsTips(item_bid,is_show_btn,is_special_source, setting) 
    local good_tips = BackpackTips.New()
    good_tips:open(item_bid,is_show_btn,is_special_source, setting)
    table.insert(self.tips_list,good_tips)
    return good_tips
end

--显示碎片合成
function TipsManager:showBackPackCompTips(status,base_id)
    if status == true then
        if not self.comp_tips then
            self.comp_tips = BackpackCompTips.New()
        end
        self.comp_tips:open(base_id)
    else
        if self.comp_tips then
            self.comp_tips:close()
            self.comp_tips = nil
        end
    end
end

--显示碎片合成选择/特殊的物品使用
function TipsManager:showCompChooseTips(status,base_id,view_type)
    if status == true then
      if not self.choose_tips then
        self.choose_tips = CompChooseTips.New()
      end
      self.choose_tips:open(base_id, view_type)
    else
      if self.choose_tips then
        self.choose_tips:close()
        self.choose_tips = nil
      end
    end
end

--显示周卡tips
function TipsManager:showWeekCardTips(status,data)
    if status == true then
      if not self.weekcard_tips then
        self.weekcard_tips = WeekCardTips.New()
      end
      self.weekcard_tips:open(data)
    else
      if self.weekcard_tips then
        self.weekcard_tips:close()
        self.weekcard_tips = nil
      end
    end
end

--战斗buff
function TipsManager:showBuffTips(vo, point, delay)
    local buff_tips = BattleBuffTips.New(delay)
    buff_tips:open()
    buff_tips:showTipsByVo(vo)
    self:adjustTipsPosition(buff_tips, point)
    table.insert(self.tips_list, buff_tips)
    return buff_tips
end

--战斗技能tips
function TipsManager:showBattleSkillTips(vo, offset_y,delay,parent)
    local skill_tips = BattleSkillTips.New(delay,parent,offset_y)
    skill_tips:open()
    skill_tips:setSkillInfo(vo,offset_y)
    self.is_hide = false
    table.insert(self.tips_list, skill_tips)
    return skill_tips
end

--战斗阵法tips
function TipsManager:showBattleTacticalTips(vo, delay, parent, form_info_2)
    local tactical_tips = BattleTacticalSTips.New(delay,parent)
    tactical_tips:open()
    tactical_tips:setTacticalInfo(vo, form_info_2)
    table.insert(self.tips_list, tactical_tips)
    return tactical_tips
end

--普通tips
--@is_middle 是否居中显示
function TipsManager:showCommonTips(tips, point, font_size,delay, width, is_middle)
   if self.common_tips ~= nil then
      self.common_tips:close()
      self.common_tips = nil
   end
   width = width or 400
   self.common_tips = CommonTips.New(delay)
   self.common_tips:open()
   self.common_tips:showTips(tips, width, (font_size or 24))
   self:adjustTipsPosition(self.common_tips, point, nil, is_middle)
   table.insert(self.tips_list, self.common_tips)
   return self.common_tips
end

-- 神界冒险的tips
function TipsManager:showAdventureBuffTips(buff_list, point, holiday_buff_list)
    if self.adventure_buff_tips then 
        self.adventure_buff_tips:close()
        self.adventure_buff_tips = nil
    end
   self.adventure_buff_tips = AdventureBuffTips.New(buff_list, holiday_buff_list)
   self.adventure_buff_tips:open()
   self.adventure_buff_tips:showTips()
   self:adjustTipsPosition(self.adventure_buff_tips, point)
   table.insert(self.tips_list, self.adventure_buff_tips)
   return self.adventure_buff_tips
end

function TipsManager:ShareTips(data, point,size, delay)
    if self.share_tips ~= nil then
        self.share_tips:close()
        self.share_tips = nil
    end
    self.share_tips = ShareTips.New(delay)
    self.share_tips:open()
    self.share_tips:showTips(data,size)
    self:adjustTipsPosition(self.share_tips, point)
    table.insert(self.tips_list, self.share_tips)
    return self.share_tips
end

--位置调整(现在某认为显示的tips的anchorPoint的为cc.p(0, 1)自己主动的去设)
function TipsManager:adjustTipsPosition(target, point, view_size, is_middle)
    local win_size = cc.size(SCREEN_WIDTH,SCREEN_HEIGHT)                 -- 父节点的尺寸
    local temp_size = view_size or target.root_wnd:getContentSize()      -- 对象的除此你,这里的对象都是0,0的锚点
    local size = cc.size(temp_size.width, temp_size.height)
    local offset_height = 10                                             -- 偏移值

    local parent = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
    local local_pos = parent:convertToNodeSpace(point)
    local start_x = local_pos.x
    local start_y = local_pos.y

    if start_x + size.width > win_size.width then
        start_x = win_size.width - size.width
    elseif start_x < size.width then
        start_x = start_x + 20
    end
    if is_middle then
        start_x = (win_size.width - size.width)/2
    end

    if start_y > win_size.height then
        start_y = win_size.height
    elseif start_y < size.height then
        start_y = start_y + size.height + 20
    end
    target:setPosition(start_x, start_y-display.getBottom())
--    if point.x + size.width + offset_height >= 0 then -- 显示左边
--         if point.y + size.height + offset_height > win_size.height then -- 显示下边
--             if point.y - offset_height - size.height > 0 then
--                 target:setPosition(point.x - size.width - offset_height , point.y - offset_height)
--             else --超出屏幕
--                 target:setPosition(point.x - size.width - offset_height , point.y - offset_height + math.abs(point.y - offset_height - size.height))
--             end
--         else
--             target:setPosition(point.x - size.width - offset_height , point.y + size.height + offset_height)
--         end
--    else  -- 显示右边
--        if point.y + size.height + offset_height > win_size.height then -- 显示下边
--            if point.y - offset_height - size.height > SCREEN_WIDTH then
--                target:setPosition(point.x + offset_height , point.y - offset_height)
--            else --超出屏幕
--               local posy =  point.y - offset_height + math.abs(point.y - offset_height - size.height)
--               if posy + size.height > display.height then
--                 target:setPosition(point.x + offset_height , posy-(math.abs(point.y - offset_height - size.height)))
--               else 
--                 target:setPosition(point.x + offset_height , point.y - offset_height + math.abs(point.y - offset_height - size.height))
--               end
               
--            end
--        else
--            target:setPosition(point.x + offset_height , point.y + size.height + offset_height)
--        end
--    end
end

--打开头像/头像框Tips  type 1--头像 2--头像框
function TipsManager:showFaceTips( type,data,touch_pos )
    local tips = RoleFaceTips.New()
    tips:setData(type,data)
    table.insert(self.tips_list,tips)
    if touch_pos then
        tips.main_container:setAnchorPoint(cc.p(0,0))
        self:adjustTipsPosition(tips.main_container, touch_pos, tips.main_container:getContentSize())
    end
    return tips
end

-- 打开精灵tips
function TipsManager:showElfinTips( elfin_bid, show_btn )
    local elfin_tips = ElfinTipsWindow.New()
    elfin_tips:open(elfin_bid, show_btn)
    table.insert(self.tips_list,elfin_tips)
    return elfin_tips
end

--@ 引导需要
function TipsManager:getCompTipsRoot(  )
  if self.comp_tips ~= nil then
      return self.comp_tips.root_wnd
  end
end