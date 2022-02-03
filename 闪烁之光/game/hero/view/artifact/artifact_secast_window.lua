--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-16 21:22:19
-- @description    : 
		-- 符文重铸
---------------------------------
ArtifactRecastWindow = ArtifactRecastWindow or BaseClass(BaseView)

local string_format = string.format
local table_insert = table.insert

function ArtifactRecastWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "hero/artifact_recast_panel"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("artifact", "artifact"), type = ResourcesType.plist},
	}

	self.ctrl = HeroController:getInstance()
    self.model = self.ctrl:getModel()
    self.is_can_save =false
    self.is_luck_recast = false -- 标识是否为幸运重铸
    self.need_list = {}
    self.base_list_left = {}
    self.base_list_right = {}
    self.skill_list_left = {}
    self.skill_list_right = {}
    self.select_luck_type = nil -- 1：普通道具  2：高级道具
    self.need_num = nil --需要消耗的好运宝珠数量
    self.need_num_2 = nil --需要消耗的高级好运宝珠数量
end

function ArtifactRecastWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 1) 

	main_container:getChildByName("win_title"):setString(TI18N("符文重铸"))

	local container = main_container:getChildByName("container")
    local cost_panel = container:getChildByName("cost_panel")
    self.cost_panel = cost_panel

    local title_1 = container:getChildByName("title_1")
    title_1:setString(TI18N("重铸前"))
    local title_2 = container:getChildByName("title_2")
    title_2:setString(TI18N("重铸后"))
    local base_title_1 = container:getChildByName("base_title_1")
    base_title_1:setString(TI18N("基础属性"))
    local base_title_2 = container:getChildByName("base_title_2")
    base_title_2:setString(TI18N("基础属性"))
    local base_title_3 = container:getChildByName("base_title_3")
    base_title_3:setString(TI18N("符文技能"))
    local base_title_4 = container:getChildByName("base_title_4")
    base_title_4:setString(TI18N("符文技能"))

    self.progress_bg = main_container:getChildByName("progress_bg")
    self.progress = self.progress_bg:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)
    self.progress_value = self.progress_bg:getChildByName("progress_label")
    self.progress_value:setString(0)

    self.left_bg = container:getChildByName("Image_7")
    self.right_bg = container:getChildByName("Image_9")
    self.name_txt = container:getChildByName("name_txt")
    self.pos_item = container:getChildByName("pos_item")

    local cost_bg_1 = cost_panel:getChildByName("cost_bg_1")
    cost_bg_1:setPositionX(207)
    local cost_bg_2 = cost_panel:getChildByName("cost_bg_2")
    cost_bg_2:setPositionX(467)
    local cost_bg_3 = cost_panel:getChildByName("cost_bg_3")
    cost_bg_3:setVisible(false)
    self.cost_bg = {cost_bg_1, cost_bg_2,cost_bg_3}

    local cost_icon_1 = cost_bg_1:getChildByName("cost_icon_1")
    local cost_icon_2 = cost_bg_2:getChildByName("cost_icon_2")
    local cost_icon_3 = cost_bg_3:getChildByName("cost_icon_3")
    self.cost_icon = {cost_icon_1, cost_icon_2,cost_icon_3}

    local cost_txt_1 = cost_bg_1:getChildByName("cost_txt_1")
    local cost_txt_2 = cost_bg_2:getChildByName("cost_txt_2")
    local cost_txt_3 = cost_bg_3:getChildByName("cost_txt_3")
    cost_txt_1:setString("")
    cost_txt_2:setString("")
    cost_txt_3:setString("")
    self.cost_txt = {cost_txt_1, cost_txt_2,cost_txt_3}

    self.explain_btn = main_container:getChildByName("explain_btn")
    self.close_btn = main_container:getChildByName("close_btn")
    self.save_btn = main_container:getChildByName("save_btn")
    self.save_btn:getChildByName("label"):setString(TI18N("保存"))
    self.reset_btn = main_container:getChildByName("reset_btn")
    self.reset_btn_label = self.reset_btn:getChildByName("label")
    self.reset_btn_label:setString(TI18N("重铸"))
    self.cancel_btn = main_container:getChildByName("cancel_btn")
    self.cancel_btn_label = self.cancel_btn:getChildByName("label")
    self.cancel_btn_label:setString(TI18N("重铸"))
    
    self.check_panel = main_container:getChildByName("check_panel")
    self.check_panel:setVisible(false)
    self.checkbox = self.check_panel:getChildByName("checkbox")
    self.check_panel:getChildByName("box_lab"):setString(TI18N("幸运重铸"))
    self.tips_btn = self.check_panel:getChildByName("tips_btn")
    
    self.item_node = BackPackItem.new(false, false, false)
    self.item_node:setPositionY(15)
    self.pos_item:addChild(self.item_node)
end

function ArtifactRecastWindow:adjustNodePos(  )
    if not self.item_config then return end

    -- 彩虹、闪烁符文显示幸运重铸的进度条
    if self.item_config.quality >= BackPackConst.quality.orange then
        if not self.tips_text then
            self.tips_text = createRichLabel(22, nil, cc.p(0.5, 0.5), cc.p(340, 230), nil, nil, 660)
            self.main_container:addChild(self.tips_text)

            local function clickLinkCallBack( _type, value )
                if _type == "href" then
                    self.ctrl:openArtifactSkillWindow(true, 1, 3)
                end
            end
            self.tips_text:addTouchLinkListener(clickLinkCallBack,{"href"})
        end
        self.cost_panel:setPositionY(162)
        self.progress_bg:setVisible(true)
        self.tips_text:setVisible(true)
    else
        self.cost_panel:setPositionY(124)
        self.progress_bg:setVisible(false)
        if self.tips_text then
            self.tips_text:setVisible(false)
        end
    end
end

-- 更新进度条显示
function ArtifactRecastWindow:updateProgressBar(  )
    if self.item_config and self.item_config.quality >= BackPackConst.quality.orange then
        local cur_count, max_count = self.model:getArtifactRecastCountByQuality(self.item_config.quality)
        -- 进度
        local percent = cur_count/max_count*100
        self.progress:setPercent(percent)
        self.progress_value:setString(string_format("%d/%d", cur_count, max_count))

        -- 提示
        if self.tips_text then
            local less_num = max_count - cur_count
            if less_num <= 0 and cur_count > 0 then
                self.reset_btn_label:setString(TI18N("必出稀有"))
                self.cancel_btn_label:setString(TI18N("必出稀有"))
                self.tips_text:setString(TI18N("<div fontcolor=955322>本次重铸必定出现稀有高级技能 </div><div href=xxx fontcolor=249003>查看技能</div>"))
                
                self:handleBtnEffect(true)
                if self.checkbox:isSelected() == true then
                    self.checkbox:setSelected(false)
                    self:checkLucType()
                end
            else
                if self.checkbox:isSelected() == false then
                    self:handleBtnEffect(false)
                end
                
                self.reset_btn_label:setString(TI18N("重铸"))
                self.cancel_btn_label:setString(TI18N("重铸"))
                local str = string_format(TI18N("<div fontcolor=955322>再重铸%d次必定出现稀有技能 </div><div href=xxx fontcolor=249003>查看技能</div>"), less_num)
                if self.checkbox:isSelected() == true then
                    if self.select_luck_type and self.select_luck_type == 2 then
                        str = string_format(TI18N("<div fontcolor=955322>本次必出双高级技能,再重铸%d次必出稀有技能 </div><div href=xxx fontcolor=249003>查看技能</div>"), less_num)
                    else
                        str = string_format(TI18N("<div fontcolor=955322>强力和稀有技能概率up,再重铸%d次必出稀有技能 </div><div href=xxx fontcolor=249003>查看技能</div>"), less_num)
                    end
                    
                end
                self.tips_text:setString(str)
            end
        end
    end
end

-- 幸运重铸特效
function ArtifactRecastWindow:handleEffect( status, pos )
    if status == true then
        if not tolua.isnull(self.main_container) and self.re_effect == nil then
            self.re_effect = createEffectSpine(Config.EffectData.data_effect_info[661], pos, cc.p(0.5, 0.5), false, PlayerAction.action)
            self.main_container:addChild(self.re_effect)
        elseif self.re_effect then
            self.re_effect:setToSetupPose()
            self.re_effect:setPosition(pos)
            self.re_effect:setAnimation(0, PlayerAction.action, false)
        end
    else
        if self.re_effect then
            self.re_effect:clearTracks()
            self.re_effect:removeFromParent()
            self.re_effect = nil
        end
    end
end

-- 幸运重铸按钮特效
function ArtifactRecastWindow:handleBtnEffect( status )
    if status == true then
        local world_pos = self.reset_btn:convertToWorldSpace(cc.p(0, 0))
        if self.is_can_save then
            world_pos = self.cancel_btn:convertToWorldSpace(cc.p(0, 0))
        end
        local local_pos = self.main_container:convertToNodeSpace(world_pos)

        local pos = cc.p(local_pos.x+85, local_pos.y+25)

        if not tolua.isnull(self.main_container) and self.btn_effect == nil then
            self.btn_effect = createEffectSpine(Config.EffectData.data_effect_info[1308], pos, cc.p(0.5, 0.5), true, PlayerAction.action)
            self.main_container:addChild(self.btn_effect)
        elseif self.btn_effect then
            self.btn_effect:setToSetupPose()
            self.btn_effect:setPosition(pos)
            self.btn_effect:setAnimation(0, PlayerAction.action, true)
        end
    else
        if self.btn_effect then
            self.btn_effect:clearTracks()
            self.btn_effect:removeFromParent()
            self.btn_effect = nil
        end
    end
end

function ArtifactRecastWindow:setData(data, partner_id)
    self.data = data or {}
    self.item_config = data.config
    self.partner_id = partner_id or 0

    self:adjustNodePos()

    self.item_node:setData(data)
    self.name_txt:setString(self.item_config.name)

    --self.lock_data = SysEnv:getInstance():loadArtifactLockStatus() or {}

    -- 判断是否已经重铸但未保存
    self.is_can_save = false
    if self.data.extra_attr and next(self.data.extra_attr) ~= nil then
        self.is_can_save = true
        --self.artifact_lock_data = self.lock_data[self.data.id] or {false, false, false}
    else
        --self.artifact_lock_data = {false, false, false}
    end

    if not self.need_num and not self.need_num_2 then
        self.need_num = 0
        self.need_num_2 = 0
        local lucky_artifact_ids_config = Config.PartnerArtifactData.data_artifact_const.lucky_artifact_ids
        if lucky_artifact_ids_config and lucky_artifact_ids_config.val then
            for k,v in pairs(lucky_artifact_ids_config.val) do
                if v[1] == self.item_config.id then
                    self.need_num = v[2]
                    break
                end
            end
        end

        local lucky_artifact_ids_config2 = Config.PartnerArtifactData.data_artifact_const.lucky_artifact_ids2
        if lucky_artifact_ids_config2 and lucky_artifact_ids_config2.val then
            for k,v in pairs(lucky_artifact_ids_config2.val) do
                if v[1] == self.item_config.id then
                    self.need_num_2 = v[2]
                    break
                end
            end
        end
    end
    
    
    self:setBaseAttrInfo()
    self:setSkillInfo()
    self:updateBtnShow()
    self:checkLucType()
    self:updateProgressBar()
end

-- 基础属性
function ArtifactRecastWindow:setBaseAttrInfo(  )
    if not self.data or not self.data.attr or not self.item_config then return end
    local attr_num = 2
    local artifact_config = Config.PartnerArtifactData.data_artifact_data[self.item_config.id]
    if artifact_config then
        attr_num = artifact_config.attr_num
    end

    for i,v in ipairs(self.data.attr) do
        if i > attr_num then break end        -- 超过2条属性不显示了,ui暂时不支持
        local attr_id = v.attr_id
        local attr_key = Config.AttrData.data_id_to_key[attr_id]
        local attr_val = v.attr_val/1000
        local attr_name = Config.AttrData.data_key_to_name[attr_key]
        if attr_name then
            if not self.base_list_left[i] then 
                self.base_list_left[i] = createRichLabel(24, cc.c4b(104,69,42,255), cc.p(0, 0.5), cc.p(20, 28), nil, nil, 380)
                self.left_bg:addChild(self.base_list_left[i])
            end
            local label = self.base_list_left[i]
            local _x = 30
            local _y = 375 - (i-1)*35
            label:setPosition(cc.p(_x, _y))

            local icon = PathTool.getAttrIconByStr(attr_key)
            local is_per = PartnerCalculate.isShowPerByStr(attr_key)
            if is_per == true then
                attr_val = (attr_val/10).."%"
            end
            local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#68452a> %s：</div><div fontcolor=#68452a>%s</div>", PathTool.getResFrame("common", icon), attr_name, attr_val)
            label:setString(attr_str)
        end
    end

    if self.is_can_save then
        -- 重铸过，未保存
        for i,v in ipairs(self.data.extra_attr) do
            if i > attr_num then break end 
            local attr_id = v.attr_id
            local attr_key = Config.AttrData.data_id_to_key[attr_id]
            local attr_val = v.attr_val/1000
            local attr_name = Config.AttrData.data_key_to_name[attr_key]
            if attr_name then
                if not self.base_list_right[i] then 
                    self.base_list_right[i] = createRichLabel(24, cc.c4b(104,69,42,255), cc.p(0, 0.5), cc.p(20, 28), nil, nil, 380)
                    self.right_bg:addChild(self.base_list_right[i])
                end
                local label = self.base_list_right[i]
                local _x = 30
                local _y = 375 - (i-1)*35
                label:setPosition(cc.p(_x, _y))

                local icon = PathTool.getAttrIconByStr(attr_key)
                local is_per = PartnerCalculate.isShowPerByStr(attr_key)
                if is_per == true then
                    attr_val = (attr_val/10).."%"
                end
                local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#68452a> %s：</div><div fontcolor=#68452a>%s</div>", PathTool.getResFrame("common", icon), attr_name, attr_val)
                label:setString(attr_str)
            end
        end
    else
        for i,v in ipairs(self.data.attr) do
            if i > attr_num then break end
            if not self.base_list_right[i] then 
                self.base_list_right[i] = createRichLabel(24, cc.c4b(104,69,42,255), cc.p(0, 0.5), cc.p(20, 28), nil, nil, 380)
                self.right_bg:addChild(self.base_list_right[i])
            end
            local label = self.base_list_right[i]
            local _x = 100
            local _y = 375 - (i-1)*35
            label:setPosition(cc.p(_x, _y))
            label:setString(TI18N("随机属性"))
        end
    end
end

-- 神器技能
function ArtifactRecastWindow:setSkillInfo(  )
    if self.data == nil or self.data.extra == nil then return end
    local skill_num = 0 -- 技能数量
    local artifact_config = Config.PartnerArtifactData.data_artifact_data[self.item_config.id]
    if artifact_config then
        skill_num = artifact_config.skill_num
    end
    local index = 1
    local cur_skills = {}
    local sort_func = SortTools.KeyLowerSorter("extra_k")
    table.sort(self.data.extra, sort_func)
    for k,v in pairs(self.skill_list_left) do
        self:setSkillItemVisible(false, v)
    end
    for i,value in ipairs(self.data.extra) do
        if value and value.extra_k and (value.extra_k == 1 or value.extra_k == 2 or value.extra_k == 8) then
            if #cur_skills <= skill_num then
                table.insert(cur_skills, value.extra_v)
                local config = Config.SkillData.data_get_skill(value.extra_v)
                if config then
                    if not self.skill_list_left[index] then
                        local item = self:createSkillItem(self.left_bg, index)
                        self.skill_list_left[index] = item
                    end

                    local skill_item = self.skill_list_left[index]
                    self:setSkillItemVisible(true, skill_item)
                    skill_item.skill:setData(config)
                    skill_item.name:setString(config.name)
                    skill_item.desc:setString(transformTextToShort(config.des, 36))
                    skill_item.random_icon:setVisible(false)
                    skill_item.random_des:setVisible(false)

                    local temp_lev = config.level
                    if config.client_lev and config.client_lev>0 then
                        temp_lev = config.client_lev
                    end

                    local name_color = PartnerConst.SkillColor[temp_lev]
                    name_color = name_color or cc.c3b(104,69,42)
                    skill_item.name:setTextColor(name_color)

                    --[[local is_lock = self.artifact_lock_data[index] or false
                    if is_lock then
                        skill_item.lock_btn:loadTextures(PathTool.getResFrame("artifact","artifact_1002"))
                    else
                        skill_item.lock_btn:loadTextures(PathTool.getResFrame("artifact","artifact_1001"))
                    end--]]
                    index = index + 1
                end
            end
        end
    end
    self.cur_skills = cur_skills

    -- 右侧
    local recast_skills = {}
    for i,value in ipairs(self.data.extra) do
        if value and value.extra_k and (value.extra_k == 3 or value.extra_k == 4 or value.extra_k == 9) then
            table.insert(recast_skills, value.extra_v)
        end
    end
    self.recast_skills = recast_skills
    local right_skill_num = skill_num
    -- 当没有重置技能则显示为最大数量的问号，有则显示为技能数量
    if next(recast_skills) ~= nil then
        right_skill_num = #recast_skills
    end
    if right_skill_num > skill_num then
        right_skill_num = skill_num
    end
    for k,v in pairs(self.skill_list_right) do
        self:setSkillItemVisible(false, v)
    end
    for i=1,right_skill_num do
        if not self.skill_list_right[i] then
            local item = self:createSkillItem(self.right_bg, i)
            self.skill_list_right[i] = item
        end

        local skill_id = recast_skills[i]
        local skill_item = self.skill_list_right[i]
        self:setSkillItemVisible(true, skill_item)
        skill_item.name:setVisible(true)
        skill_item.desc:setVisible(true)
        --skill_item.lock_btn:setVisible(false)
        skill_item.random_icon:setVisible(false)
        skill_item.random_des:setVisible(false)
        local config = Config.SkillData.data_get_skill(skill_id)
        if config then
            skill_item.skill:setTouchEnabled(true)
            skill_item.skill:setData(config)
            skill_item.name:setString(config.name)
            skill_item.desc:setString(transformTextToShort(config.des, 36))

            local temp_lev = config.level
            if config.client_lev and config.client_lev>0 then
                temp_lev = config.client_lev
            end
            local name_color = PartnerConst.SkillColor[temp_lev]
            name_color = name_color or cc.c3b(104,69,42)
            skill_item.name:setTextColor(name_color)

            -- 幸运重铸需要显示特效
            if self.is_luck_recast and self.model:checkIsUnusualSkillById(skill_id) then
                local world_pos = skill_item.skill:convertToWorldSpace(cc.p(0, 0))
                local local_pos = self.main_container:convertToNodeSpace(world_pos)
                self:handleEffect(true, cc.p(local_pos.x+SkillItem.Width*0.8*0.5, local_pos.y+SkillItem.Height*0.8*0.5))
                self.is_luck_recast = false
            end
        else
        	skill_item.skill:setData()
            skill_item.skill:setTouchEnabled(false)
            skill_item.name:setVisible(false)
            skill_item.desc:setVisible(false)
            --skill_item.lock_btn:setVisible(false)
            skill_item.random_icon:setVisible(true)
            skill_item.random_des:setVisible(true)
        end

        --local is_lock = self.artifact_lock_data[index] or false
        --[[local skill_item = self.skill_list_right[i]
        if (not is_lock and recast_skills[i]) or is_lock then 
            local skill_id = recast_skills[i]
            if is_lock then
                skill_id = cur_skills[i]
            end
            skill_item.name:setVisible(true)
            skill_item.desc:setVisible(true)
            skill_item.lock_btn:setVisible(false)
            skill_item.random_icon:setVisible(false)
            skill_item.random_des:setVisible(false)
            local config = Config.SkillData.data_get_skill(skill_id)
            if config then
                skill_item.skill:setData(config)
                skill_item.name:setString(config.name)
                skill_item.desc:setString(config.des)

                local name_color = PartnerConst.SkillColor[config.level]
                name_color = name_color or cc.c3b(104,69,42)
                skill_item.name:setTextColor(name_color)
            end
        else
            skill_item.skill:setData()
            skill_item.name:setVisible(false)
            skill_item.desc:setVisible(false)
            skill_item.lock_btn:setVisible(false)
            skill_item.random_icon:setVisible(true)
            skill_item.random_des:setVisible(true)
        end--]]
    end
end

-- 创建一个技能item
function ArtifactRecastWindow:createSkillItem(parent, index)
    local item = {}
    local skill = SkillItem.new(true,true,true,0.8)
    parent:addChild(skill)
    local pos_y = 207 - (index-1)*130
    skill:setPosition(60, pos_y)
    local name = createLabel(22,cc.c4b(104,69,42,255),nil,110, pos_y+25,"",parent,1,cc.p(0,0))
    local desc = createRichLabel(20,cc.c4b(104,69,42,255),cc.p(0,1),cc.p(110, pos_y+20),0,nil,180)
    parent:addChild(desc)
    local icon_res = PathTool.getResFrame("artifact","artifact_1003")
    local random_icon = createSprite(icon_res, 60, pos_y, parent, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    local random_des = createLabel(24,cc.c4b(104,69,42,255),nil,110, pos_y,TI18N("随机技能"),parent,1,cc.p(0,0.5))
    item.skill = skill
    item.name = name
    item.desc = desc
    item.random_icon = random_icon
    item.random_des = random_des
    return item
end

function ArtifactRecastWindow:setSkillItemVisible( status, item )
    item = item or {}
    for k,v in pairs(item) do
        v:setVisible(status)
    end
end

function ArtifactRecastWindow:register_event(  )
    -- 重铸
	registerButtonEventListener(self.reset_btn, function ( )
		if self.data and self.data.id and self.item_config then
            local skills = {}
            --[[for k,skill_id in pairs(self.cur_skills) do
                if self.artifact_lock_data[k] == true then
                    local temp = {}
                    temp.skill_id = skill_id
                    table.insert(skills, temp)
                end
            end--]]
            local luck_item = 0
            if self.checkbox:isSelected() then
                if self.select_luck_type and self.select_luck_type == 1 then
                    local lucky_item_id_config = Config.PartnerArtifactData.data_artifact_const.lucky_item_id
                    if lucky_item_id_config and lucky_item_id_config.val then
                        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(lucky_item_id_config.val)
                        if self.need_num and have_num< self.need_num then
                            BackpackController:getInstance():openTipsSource(true, lucky_item_id_config.val)
                            return
                        end
                    end
                    luck_item = 1
                elseif self.select_luck_type and self.select_luck_type == 2 then
                    local lucky_item_id_config2 = Config.PartnerArtifactData.data_artifact_const.lucky_item_id2
                    if lucky_item_id_config2 and lucky_item_id_config2.val then
                        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(lucky_item_id_config2.val)
                        if self.need_num_2 and have_num< self.need_num_2 then
                            BackpackController:getInstance():openTipsSource(true, lucky_item_id_config2.val)
                            return
                        end
                    end
                    luck_item = 2
                end
            end

            local cur_count, max_count = self.model:getArtifactRecastCountByQuality(self.item_config.quality)
            if cur_count >= max_count and cur_count > 0 then
                self.is_luck_recast = true -- 本次为幸运重铸
            end

            self.ctrl:sender11033(self.partner_id, self.data.id, skills,luck_item)
        end
	end)

    -- 保存重铸
	registerButtonEventListener(self.save_btn, function ( )
		if self.data and self.data.id then
            self.ctrl:sender11034(self.partner_id, self.data.id, 1)
        end
	end)

    -- 幸运重铸
    registerButtonEventListener(self.checkbox, function ( )
        if self.item_config and self.item_config.quality >= BackPackConst.quality.orange then
            local cur_count, max_count = self.model:getArtifactRecastCountByQuality(self.item_config.quality)
            local less_num = max_count - cur_count
            if less_num <= 0 and cur_count > 0 then
                self.checkbox:setSelected(false)
                message(TI18N("必出稀有,无需勾选"))
                return
            end
        end

        self:checkLucType()
        self:updateProgressBar()
        if self.checkbox:isSelected() == true then
            self:handleBtnEffect(true)
        else
            self:handleBtnEffect(false)
        end
        
    end)
    
    -- 取消重铸(改为继续重铸)
    registerButtonEventListener(self.cancel_btn, function ( )
        if self.data and self.data.id and self.item_config then
            local luck_item = 0
            if self.checkbox:isSelected() then
                if self.select_luck_type and self.select_luck_type == 1 then
                    local lucky_item_id_config = Config.PartnerArtifactData.data_artifact_const.lucky_item_id
                    if lucky_item_id_config and lucky_item_id_config.val then
                        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(lucky_item_id_config.val)
                        if self.need_num and have_num< self.need_num then
                            BackpackController:getInstance():openTipsSource(true, lucky_item_id_config.val)
                            return
                        end
                    end
                    luck_item = 1
                elseif self.select_luck_type and self.select_luck_type == 2 then
                    local lucky_item_id_config2 = Config.PartnerArtifactData.data_artifact_const.lucky_item_id2
                    if lucky_item_id_config2 and lucky_item_id_config2.val then
                        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(lucky_item_id_config2.val)
                        if self.need_num_2 and have_num< self.need_num_2 then
                            BackpackController:getInstance():openTipsSource(true, lucky_item_id_config2.val)
                            return
                        end
                    end
                    luck_item = 2
                end
            end
            
            local cur_count, max_count = self.model:getArtifactRecastCountByQuality(self.item_config.quality)
            if cur_count >= max_count and cur_count > 0 then
                self.is_luck_recast = true -- 本次为幸运重铸
            end
            
            self.ctrl:sender11033(self.partner_id, self.data.id, {},luck_item)
        end
    end)

    registerButtonEventListener(self.tips_btn, function ( param, sender )
		local config = Config.PartnerArtifactData.data_artifact_const.lucky_artifact_desc
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
    end)
    
	registerButtonEventListener(self.explain_btn, function ( param, sender )
		local config = Config.PartnerArtifactData.data_artifact_const.recast_rule
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
	end)

	registerButtonEventListener(self.close_btn, function ( )
		self.ctrl:openArtifactRecastWindow(false)
    end)
    
	registerButtonEventListener(self.background, function ( )
		self.ctrl:openArtifactRecastWindow(false)
	end)

	self:addGlobalEvent(HeroEvent.Artifact_Recast_Event, function (  )
		if not self.data or self.data.id == 0 then return end
        -- 保存技能锁定状态
        --[[self.lock_data = self.lock_data or {}
        self.artifact_lock_data = self.artifact_lock_data or {false, false, false}
        self.lock_data[self.data.id] = self.artifact_lock_data
        SysEnv:getInstance():saveArtifactLockStatus(self.lock_data)--]]

        if self.partner_id and self.partner_id ~= 0 then
            local artifact_list = self.model:getPartnerArtifactList(self.partner_id)
            for k,vo in pairs(artifact_list) do
                if vo.id == self.data.id then
                    self:setData(vo, self.partner_id)
                    break
                end
            end
        else
            local item_data = BackpackController:getModel():getBackPackItemById(self.data.id)
            self:setData(item_data, self.partner_id)
        end
	end)

	self:addGlobalEvent(HeroEvent.Artifact_Save_Event, function (  )
		if self.partner_id and self.partner_id ~= 0 then
            local artifact_list = self.model:getPartnerArtifactList(self.partner_id)
            for k,vo in pairs(artifact_list) do
                if vo.id == self.data.id then
                    self:setData(vo, self.partner_id)
                    break
                end
            end
        else
            local item_data = BackpackController:getModel():getBackPackItemById(self.data.id)
            self:setData(item_data, self.partner_id)
        end
	end)

    -- 重铸次数更新
    self:addGlobalEvent(HeroEvent.Artifact_Recast_Count_Event, function (  )
        self:updateProgressBar()
    end)

    self:addGlobalEvent(HeroEvent.Del_Hero_Event, function(list)
        if self.partner_id then
            for i,v in ipairs(list) do
                if self.partner_id == v.partner_id then
                    self.ctrl:openArtifactRecastWindow(false)
                end
            end
        end
    end)

    -- 重铸次数更新
    self:addGlobalEvent(HeroEvent.Artifact_Cost_Select_Event, function ( type )
        if type then
            self.select_luck_type = type
            self.checkbox:setSelected(true)
        else
            self.select_luck_type = nil
            self.checkbox:setSelected(false)
        end
        self:updateCostInfo()
        self:updateProgressBar()
    end)
end

function ArtifactRecastWindow:updateBtnShow(  )
	self.reset_btn:setVisible(not self.is_can_save)
	self.save_btn:setVisible(self.is_can_save)
    self.cancel_btn:setVisible(self.is_can_save)
    
    if self.checkbox:isSelected() == true then
        self:handleBtnEffect(false)
        self:handleBtnEffect(true)
    end
end


function ArtifactRecastWindow:checkLucType(  )
    if self.checkbox:isSelected() == true then
        if self.select_luck_type == nil then
            local lucky_item_id_config = Config.PartnerArtifactData.data_artifact_const.lucky_item_id
            local lucky_item_id_config2 = Config.PartnerArtifactData.data_artifact_const.lucky_item_id2
            local have_num = 0
            local have_num2 = 0
            if lucky_item_id_config and lucky_item_id_config2 then
                have_num = BackpackController:getInstance():getModel():getItemNumByBid(lucky_item_id_config.val)
                have_num2 = BackpackController:getInstance():getModel():getItemNumByBid(lucky_item_id_config2.val)
            end
            if self.need_num and self.need_num>0 and self.need_num_2 and self.need_num_2>0 then
                if have_num >= self.need_num and have_num2 >= self.need_num_2 then
                    self.checkbox:setSelected(false)
                    self.ctrl:openArtifactRecastCostPanel(true)
                    return
                elseif have_num2 >= self.need_num_2 then
                    self.select_luck_type = 2
                else
                    self.select_luck_type = 1
                end
            elseif self.need_num_2 and self.need_num_2>0 and have_num2 >= self.need_num_2 then
                self.select_luck_type = 2
            else
                self.select_luck_type = 1
            end
        end
    else
        self.select_luck_type = nil
    end
    
    self:updateCostInfo()
end


function ArtifactRecastWindow:updateCostInfo(  )
    if not self.data or not self.data.attr or not self.item_config then return end

    local is_show = false
    if self.need_num and self.need_num>0 or self.need_num_2 and self.need_num_2>0 then
        self.check_panel:setVisible(true)
        if self.checkbox:isSelected() == true then
            local cost_icon = self.cost_icon[3]
            local cost_txt = self.cost_txt[3]
            
            if cost_icon and cost_txt then
                local lucky_item_id_config = Config.PartnerArtifactData.data_artifact_const.lucky_item_id
                if self.select_luck_type and self.select_luck_type == 2 then
                    lucky_item_id_config = Config.PartnerArtifactData.data_artifact_const.lucky_item_id2
                end
                if lucky_item_id_config and lucky_item_id_config.val then
                    local item_config = Config.ItemData.data_get_data(lucky_item_id_config.val)
                    if item_config then
                        cost_icon:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)    
                    end
                    
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(lucky_item_id_config.val)
                    cost_txt:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. self.need_num)
                    if have_num >= self.need_num then
                        cost_txt:setTextColor(cc.c3b(255, 246, 228))
                    else
                        cost_txt:setTextColor(cc.c3b(253, 71, 71))
                    end
                end
            end
            is_show = true
        end
    else
        self.check_panel:setVisible(false)
    end

    local cost_bg = self.cost_bg[3]
    if cost_bg then
        cost_bg:setVisible(is_show)
    end
    
    local artifact_config = Config.PartnerArtifactData.data_artifact_data[self.item_config.id]
    if artifact_config and artifact_config.ref_expend then
        local pos_list_1 = {207,467}
        local pos_list_2 = {133,365}
    	for i=1,2 do
    		local cost_icon = self.cost_icon[i]
    		local cost_txt = self.cost_txt[i]
    		local cost_data = artifact_config.ref_expend[i]
    		if cost_data then
    			local bid = cost_data[1]
    			local num = cost_data[2]
    			local item_config = Config.ItemData.data_get_data(bid)
    			if item_config then
    				cost_icon:loadTexture(PathTool.getItemRes(bid), LOADTEXT_TYPE)
    				local have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
    				cost_txt:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(num))
                    if have_num >= num then
                        cost_txt:setTextColor(cc.c3b(255, 246, 228))
                    else
                        cost_txt:setTextColor(cc.c3b(253, 71, 71))
                    end
                end
    		else
    			cost_txt:setString("")
            end
            local cost_bg = self.cost_bg[i]
            if self.checkbox:isSelected() == true then
                cost_bg:setPositionX(pos_list_2[i])
            else
                cost_bg:setPositionX(pos_list_1[i])
            end
    	end
   	end
end

function ArtifactRecastWindow:openRootWnd( data, partner_id )
    -- 彩虹、闪烁符文请求一下重铸次数
    if data and data.config and data.config.quality >= BackPackConst.quality.orange then
        self.ctrl:sender11048()
    end
	self:setData(data, partner_id)
end

function ArtifactRecastWindow:close_callback(  )
	if self.item_node then
		self.item_node:DeleteMe()
		self.item_node = nil
	end
    self:handleEffect(false)
    self:handleBtnEffect(false)
	self.ctrl:openArtifactRecastWindow(false)
end