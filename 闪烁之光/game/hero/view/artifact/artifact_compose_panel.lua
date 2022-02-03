-- --------------------------------------------------------------------
-- 竖版神器合成面板
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
local string_format = string.format

ArtifactComposePanel = class("ArtifactComposePanel", function()
    return ccui.Widget:create()
end)

function ArtifactComposePanel:ctor(partner)
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function ArtifactComposePanel:config()
    self.ctrl = HeroController:getInstance()
    self.model = self.ctrl:getModel()
    self.size = cc.size(644,800)
    self:setContentSize(self.size)
    self:setTouchEnabled(false)
    self.select_item =0
    self.arrow_list = {}
    self.left_attr_labels = {}
    self.left_skill_labels = {}
    self.right_attr_labels = {}
    self.right_skill_labels = {}
    self.middle_attr_labels = {}
    self.middle_skill_labels = {}
    self.chose_item_list = {}
end
function ArtifactComposePanel:layoutUI()

    local csbPath = PathTool.getTargetCSB("hero/artifact_compose_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.label_panel = ccui.Widget:create()
    self.label_panel:setContentSize(self.size)
    self.label_panel:setAnchorPoint(cc.p(0.5,0.5))
    self.label_panel:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self.root_wnd:addChild(self.label_panel)

    self.max_panel = self.main_panel:getChildByName("max_panel")
    self.max_panel:setVisible(false)
    self.bg_panel = self.main_panel:getChildByName("bg_panel")
    
    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.ok_btn_label = createRichLabel(24, cc.c4b(0x68,0x45,0x2a,0xff), cc.p(0.5, 0.5), cc.p(84,32))
    self.ok_btn:addChild(self.ok_btn_label)

    self.explain_btn = self.main_panel:getChildByName("explain_btn")
    self.tips_label = self.max_panel:getChildByName("tips_label")
    self.tips_label:setString(TI18N("已达最大星级"))

    local attr_panel = self.main_panel:getChildByName("attr_panel")
    self.attr_panel = attr_panel
    local attr_label = attr_panel:getChildByName("atttr_label")
    attr_label:setString(TI18N("升星效果"))
    self.score_label = self.max_panel:getChildByName("score_label")
    for i=1,5 do
        local arrow = attr_panel:getChildByName("arrow_"..i)
        if arrow then
            self.arrow_list[i] = arrow
        end
    end
end

function ArtifactComposePanel:setData(data, partner_id)
    if not data then return end
    self.data = data or {}
    self.item_config = data.config
    self.partner_id = partner_id or 0

    if not self.item_config then return end

    -- 判断是否达到最大星级
    local cur_star = self.data.enchant
    local artifact_config = Config.PartnerArtifactData.data_artifact_data[self.item_config.id]
    if not artifact_config or not artifact_config[cur_star] then return end
    self.artifact_config = artifact_config

    local max_star = tableLen(artifact_config) - 1
    local is_max = cur_star >= max_star
    self.is_max = is_max -- 是否达到最大星级
    self.max_panel:setVisible(is_max)
    self.bg_panel:setVisible(not is_max)
    self.ok_btn:setVisible(not is_max)
    for k,arrow in pairs(self.arrow_list) do
        arrow:setVisible(not is_max)
    end

    local size =self.main_panel:getContentSize()
    if is_max then
        if not self.max_item then
            local max_name = createLabel(26,cc.c4b(0x68,0x45,0x2a,0xff),nil,322,690,"",self.label_panel,1,cc.p(0.5,0))

            self.max_item = BackPackItem.new(true,true,nil,0.9)
            self.max_item:setPosition(cc.p(size.width/2,630))
            self.main_panel:addChild(self.max_item)
            self.max_item.artifact_name = max_name
            self.max_item.skill_list= {}
            self.max_item.offx = size.width/2
            self.max_item.offy = 630
        end
        self.max_item:setData(self.data)
        self.max_item.artifact_name:setString(self.item_config.name or "")
    else
        -- 升星花费
        local star_expend = artifact_config[cur_star].star_expend[1] or {}
        local icon_res = PathTool.getItemRes(star_expend[1] or 1)
        local money = star_expend[2] or 0
        local aaa = MoneyTool.GetMoneyString(money)
        self.ok_btn_label:setString(string_format(TI18N("<img src='%s' scale=0.3 /><div fontcolor=#ffffff outline=2,#C45A14>%s 升星</div>"), icon_res, MoneyTool.GetMoneyString(money, false)))

        if not self.left_item then
            local left_name = createLabel(26,cc.c4b(0x68,0x45,0x2a,0xff),nil,132,690,"",self.label_panel,1,cc.p(0.5,0))

            self.left_item = BackPackItem.new(true,true,nil,0.9)
            self.left_item:setPosition(cc.p(size.width/2-190,630))
            self.main_panel:addChild(self.left_item)
            self.left_item.artifact_name = left_name
            self.left_item.skill_list= {}
            self.left_item.offx = size.width/2-190
            self.left_item.offy = 630
        end
        self.left_item:setData(self.data)
        self.left_item.artifact_name:setString(self.item_config.name or "")

        if not self.right_item then
            local right_name = createLabel(26,cc.c4b(0x68,0x45,0x2a,0xff),nil,512,690,"",self.label_panel,1,cc.p(0.5,0))

            self.right_item = BackPackItem.new(true,true,nil,0.9)
            self.right_item:setPosition(cc.p(size.width/2+190,630))
            self.right_item.artifact_name = right_name
            self.right_item.skill_list= {}
            self.right_item.offx = size.width/2+190
            self.right_item.offy = 630
            self.main_panel:addChild(self.right_item)
        end
        local right_item_data = deepCopy(self.data)
        right_item_data.enchant = right_item_data.enchant + 1
        self.right_item:setData(right_item_data)
        --self.right_item:setStarNum(cur_star+1)
        self.right_item.artifact_name:setString(self.item_config.name or "")

        if not self.end_item then
            local end_name = createLabel(26,cc.c4b(0x68,0x45,0x2a,0xff),nil,322,200,TI18N("放入符文"),self.label_panel,1,cc.p(0.5,0))

            self.end_item = BackPackItem.new(true,true,nil,0.9)
            self.end_item:setPosition(cc.p(size.width/2,145))
            self.end_item.skill_list= {}
            self.end_item.offx = size.width/2
            self.end_item.offy = 145
            self.end_item:showAddIcon(true)
            self.end_item.artifact_name = end_name
            self.main_panel:addChild(self.end_item)
            self.end_item:showAddIcon(true,2)
            self.end_item:addBtnCallBack(function()
                local param = {}
                param.id = self.data.id
                param.bid = self.item_config.id
                param.max_num = self.artifact_config[self.data.enchant].star_num
                param.chose_list = self.chose_item_list or {}
                self.ctrl:openArtifactChoseWindow(true, param, handler(self, self._onChoseCallBack))
            end)
        end
        self.end_item:setData(self.data)
        self.end_item:setEquipJie(false)
        self.need_num = self.artifact_config[cur_star].star_num
        self.end_item:setNeedNum(self.need_num, 0)
        self.end_item:setItemIconUnEnabled(true)
    end
    if self.max_item then
        self.max_item:setVisible(is_max)
        self.max_item.artifact_name:setVisible(is_max)
    end
    if self.left_item then
        self.left_item:setVisible(not is_max)
        self.left_item.artifact_name:setVisible(not is_max)
    end
    if self.right_item then
        self.right_item:setVisible(not is_max)
        self.right_item.artifact_name:setVisible(not is_max)
    end
    if self.end_item then
        self.end_item:setVisible(not is_max)
        self.end_item.artifact_name:setVisible(not is_max)
    end

    for k,label in pairs(self.left_attr_labels) do
        label:setVisible(false)
    end
    for k,label in pairs(self.left_skill_labels) do
        label:setVisible(false)
    end
    for k,label in pairs(self.right_attr_labels) do
        label:setVisible(false)
    end
    for k,label in pairs(self.right_skill_labels) do
        label:setVisible(false)
    end
    for k,label in pairs(self.middle_attr_labels) do
        label:setVisible(false)
    end
    for k,label in pairs(self.middle_skill_labels) do
        label:setVisible(false)
    end

    self.chose_item_list = {}
    self.middle_index = 1
    self.arrow_num = 0
    self:setBaseAttrInfo(is_max)
    self:setSkillInfo(is_max)

    if not is_max then
        for k,arrow in pairs(self.arrow_list) do
            arrow:setVisible(k <= self.arrow_num)
        end
    end
end

function ArtifactComposePanel:_onChoseCallBack( item_list )
    self.chose_item_list = item_list
    self.end_item:setNeedNum(self.need_num, #item_list)
    if #item_list >= self.need_num then
        self.end_item:setItemIconUnEnabled(false)
    else
        self.end_item:setItemIconUnEnabled(true)
    end
end

-- 基础属性
function ArtifactComposePanel:setBaseAttrInfo( is_max )
    if not self.data or not self.data.attr or not self.item_config then return end
    local attr_num = 2
    local artifact_config = Config.PartnerArtifactData.data_artifact_data[self.item_config.id]
    local cur_star = self.data.enchant or 0 -- 当前星数
    if artifact_config[cur_star] then
        attr_num = math.min(artifact_config[cur_star].attr_num, 2)
    end
    if is_max then
        local index = 1
        for i,v in ipairs(self.data.attr) do
            if i <= attr_num then
                local attr_id = v.attr_id
                local attr_key = Config.AttrData.data_id_to_key[attr_id]
                local attr_val = v.attr_val/1000
                local attr_name = Config.AttrData.data_key_to_name[attr_key]
                if attr_name then
                    if not self.middle_attr_labels[i] then 
                        self.middle_attr_labels[i] = createRichLabel(24, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0.5, 0.5), cc.p(20, 28), nil, nil, 380)
                        self.attr_panel:addChild(self.middle_attr_labels[i])
                    end
                    local label = self.middle_attr_labels[i]
                    label:setVisible(true)
                    local _x = 311.5
                    local _y = 224 - (i-1)*50
                    label:setPosition(cc.p(_x, _y))

                    local icon = PathTool.getAttrIconByStr(attr_key)
                    local is_per = PartnerCalculate.isShowPerByStr(attr_key)
                    if is_per == true then
                        attr_val = (attr_val/10).."%"
                    end
                    local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#68452a> %s：</div><div fontcolor=#68452a>%s</div>", PathTool.getResFrame("common", icon), attr_name, attr_val)
                    label:setString(attr_str)
                    index = index + 1
                end
            end
        end
        self.middle_index = index
    else
        -- 左侧
        for i,v in ipairs(self.data.attr) do
            if i <= attr_num then
                local attr_id = v.attr_id
                local attr_key = Config.AttrData.data_id_to_key[attr_id]
                local attr_val = v.attr_val/1000
                local attr_name = Config.AttrData.data_key_to_name[attr_key]
                if attr_name then
                    if not self.left_attr_labels[i] then 
                        self.left_attr_labels[i] = createRichLabel(24, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0.5, 0.5), cc.p(20, 28), nil, nil, 380)
                        self.attr_panel:addChild(self.left_attr_labels[i])
                    end
                    local label = self.left_attr_labels[i]
                    label:setVisible(true)
                    local _x = 156
                    local _y = 224 - (i-1)*50
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
        end

        -- 右侧
        local cur_star = self.data.enchant
        local attr_config = Config.PartnerArtifactData.data_artifact_attr[self.item_config.id]
        if attr_config and attr_config[cur_star+1] then
            local config = attr_config[cur_star+1]
            local right_index = 1
            for i,v in ipairs(self.data.attr) do
                if i <= attr_num then
                    local attr_id = v.attr_id
                    local attr_key = Config.AttrData.data_id_to_key[attr_id]
                    local attr_val = 0
                    local attr_name = Config.AttrData.data_key_to_name[attr_key]
                    for key,value in pairs(config) do
                        if key == attr_key then
                            attr_val = value
                            break
                        end
                    end
                    if attr_name then
                        if not self.right_attr_labels[i] then 
                            self.right_attr_labels[i] = createRichLabel(24, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0.5, 0.5), cc.p(20, 28), nil, nil, 380)
                            self.attr_panel:addChild(self.right_attr_labels[i])
                        end
                        local label = self.right_attr_labels[i]
                        label:setVisible(true)
                        local _x = 467
                        local _y = 224 - (i-1)*50
                        label:setPosition(cc.p(_x, _y))

                        local icon = PathTool.getAttrIconByStr(attr_key)
                        local is_per = PartnerCalculate.isShowPerByStr(attr_key)
                        if is_per == true then
                            attr_val = (attr_val/10).."%"
                        end
                        local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#68452a> %s：</div><div fontcolor=#68452a>%s</div>", PathTool.getResFrame("common", icon), attr_name, attr_val)
                        label:setString(attr_str)
                        right_index = right_index + 1
                        self.arrow_num = self.arrow_num + 1
                    end
                end
            end
            self.right_atte_index = right_index
        end
        local lock_attr_num = self.artifact_config[cur_star+1].attr_num - #self.data.attr
        if lock_attr_num > 0 then -- 下一星级有可以解锁的属性
            local right_index = self.right_atte_index
            for i=1, lock_attr_num do
                if not self.right_attr_labels[right_index] then
                    self.right_attr_labels[right_index] = createRichLabel(24, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0.5, 0.5), cc.p(20, 28), nil, nil, 380)
                    self.attr_panel:addChild(self.right_attr_labels[right_index])
                end
                local label = self.right_attr_labels[right_index]
                label:setVisible(true)
                local _x = 467
                local _y = 224 - (#self.data.attr+i-1)*50
                label:setPosition(cc.p(_x, _y))
                label:setString(string_format(TI18N("<div fontcolor=#249003 href=xxx>解锁第%s属性</div>"), StringUtil.numToChinese(#self.data.attr+i)))
                right_index = right_index + 1
                self.arrow_num = self.arrow_num + 1
            end
        end

        self.attr_num = #self.data.attr + lock_attr_num
    end
end

-- 神器技能
function ArtifactComposePanel:setSkillInfo( is_max )
    if is_max then
        if self.data == nil or self.data.extra == nil then return end
        local index = self.middle_index
        local score = 0
        local const_config = Config.PartnerArtifactData.data_artifact_const
        for i,value in ipairs(self.data.extra) do
            if value and value.extra_k and (value.extra_k == 1 or value.extra_k == 2 or value.extra_k == 8) then
                local config = Config.SkillData.data_get_skill(value.extra_v)
                if config then
                    if not self.middle_skill_labels[i] then
                        self.middle_skill_labels[i] = createRichLabel(24, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0.5, 0.5), cc.p(20, 28), nil, nil, 380)
                        self.attr_panel:addChild(self.middle_skill_labels[i])
                    end

                    local label = self.middle_skill_labels[i]
                    label:setVisible(true)
                    local _x = 311.5
                    local _y = 224 - (index-1)*50
                    label:setPosition(cc.p(_x, _y))

                    local attr_str = string_format("<div fontcolor=#249003 href=%d>【%s】</div>", config.bid, config.name)
                    label:setString(attr_str)
                    label:addTouchLinkListener(handler(self, self._onClickSkillLabel),{"href"})

                    local skill_lev = config.level or 1
                    if const_config["skill_score_"..skill_lev] and const_config["skill_score_"..skill_lev].val then 
                        score = score + const_config["skill_score_"..skill_lev].val
                    end

                    index = index + 1
                end
            end
        end
        self.score_label:setString(string_format(TI18N("评分:%d"), score))
    else
        -- 左侧
        self.attr_num = self.attr_num or 0
        if self.data ~= nil and self.data.extra ~= nil then
            local index_flag = 1
            for i,value in ipairs(self.data.extra) do
                if value and value.extra_k and (value.extra_k == 1 or value.extra_k == 2 or value.extra_k == 8) then
                    local config = Config.SkillData.data_get_skill(value.extra_v)
                    if config then
                        if not self.left_skill_labels[index_flag] then
                            self.left_skill_labels[index_flag] = createRichLabel(24, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0.5, 0.5), cc.p(20, 28), nil, nil, 380)
                            self.attr_panel:addChild(self.left_skill_labels[index_flag])
                        end

                        local label = self.left_skill_labels[index_flag]
                        label:setVisible(true)
                        local _x = 156
                        local _y = 224 - (self.attr_num+index_flag-1)*50
                        label:setPosition(cc.p(_x, _y))

                        local attr_str = string_format("<div fontcolor=#249003 href=%d>【%s】</div>", config.bid, config.name)
                        label:setString(attr_str)
                        label:addTouchLinkListener(handler(self, self._onClickSkillLabel),{"href"})
                        index_flag = index_flag + 1
                    end
                end
            end
        end

        -- 右侧
        local cur_skill_num = 0
        if self.data ~= nil and self.data.extra ~= nil then
            local index = 1
            for i,value in ipairs(self.data.extra) do
                if value and value.extra_k and (value.extra_k == 1 or value.extra_k == 2 or value.extra_k == 8) then
                    local config = Config.SkillData.data_get_skill(value.extra_v)
                    if config then
                        if not self.right_skill_labels[index] then
                            self.right_skill_labels[index] = createRichLabel(24, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0.5, 0.5), cc.p(20, 28), nil, nil, 380)
                            self.attr_panel:addChild(self.right_skill_labels[index])
                        end

                        local label = self.right_skill_labels[index]
                        label:setVisible(true)
                        local _x = 467
                        local _y = 224 - (self.attr_num+index-1)*50
                        label:setPosition(cc.p(_x, _y))

                        local attr_str = string_format("<div fontcolor=#249003 href=%d>【%s】</div>", config.bid, config.name)
                        label:setString(attr_str)
                        label:addTouchLinkListener(handler(self, self._onClickSkillLabel),{"href"})

                        index = index + 1
                        cur_skill_num = cur_skill_num + 1
                        self.arrow_num = self.arrow_num + 1
                    end
                end
            end
            self.right_skill_index = index
        end

        -- 是否有下级解锁的技能
        local cur_star = self.data.enchant
        local lock_skill_num = self.artifact_config[cur_star+1].skill_num - cur_skill_num
        if lock_skill_num > 0 then
            local right_index = self.right_skill_index
            for i=1, lock_skill_num do
                if not self.right_skill_labels[right_index] then
                    self.right_skill_labels[right_index] = createRichLabel(24, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0.5, 0.5), cc.p(20, 28), nil, nil, 380)
                    self.attr_panel:addChild(self.right_skill_labels[right_index])
                end
                local label = self.right_skill_labels[right_index]
                label:setVisible(true)
                local _x = 467
                local _y = 224 - (self.attr_num+cur_skill_num+i-1)*50
                label:setPosition(cc.p(_x, _y))
                label:setString(string_format(TI18N("<div fontcolor=#249003 href=xxx>解锁第%s被动技能</div>"), StringUtil.numToChinese(cur_skill_num+i)))
                right_index = right_index + 1
                self.arrow_num = self.arrow_num + 1
            end
        end
    end
end

function ArtifactComposePanel:_onClickSkillLabel( type, value )
    if type == "href" then
        local skill_id = value
        local skill_config = Config.SkillData.data_get_skill(skill_id)
        if skill_config then 
            TipsManager:getInstance():showSkillTips(skill_config)
        end
    end
end

--事件
function ArtifactComposePanel:registerEvents()
    self.ok_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data then
                local artifact_id = self.data.id
                local expends = {}
                for k,id in pairs(self.chose_item_list) do
                    local temp = {}
                    temp.artifact_id = id
                    table.insert(expends, temp)
                end
                if #expends < self.need_num then
                    message(TI18N("材料不足"))
                else
                    self.ctrl:sender11032(self.partner_id,artifact_id,expends)
                end
            end
        end
    end)

    self.explain_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local config = Config.PartnerArtifactData.data_artifact_const.artifact_rule
            if config then
                TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
            end
        end
    end)

    -- 神器更新
    if not self.compose_success_event then 
        self.compose_success_event = GlobalEvent:getInstance():Bind(HeroEvent.Artifact_UpStar_Event,function()
            if not self.data or not self.data.id then return end
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
    end
end

function ArtifactComposePanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function ArtifactComposePanel:DeleteMe()
    if self.left_item then 
        self.left_item:DeleteMe()
        self.left_item = nil
    end
    if self.right_item then 
        self.right_item:DeleteMe()
        self.right_item = nil
    end
    if self.end_item then 
        self.end_item:DeleteMe()
        self.end_item = nil
    end
    if self.compose_success_event then 
        GlobalEvent:getInstance():UnBind(self.compose_success_event)
        self.compose_success_event = nil
    end
end



