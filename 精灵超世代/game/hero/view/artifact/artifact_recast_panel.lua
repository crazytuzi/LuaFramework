-- --------------------------------------------------------------------
-- 竖版神器重铸面板
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
local string_format = string.format

ArtifactRecastPanel = class("ArtifactRecastPanel", function()
    return ccui.Widget:create()
end)
local table_insert = table.insert
function ArtifactRecastPanel:ctor(parent)
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function ArtifactRecastPanel:config()
    self.ctrl = HeroController:getInstance()
    self.model = self.ctrl:getModel()
    self.size = cc.size(644,800)
    self:setContentSize(self.size)
    self:setTouchEnabled(false)
    self.is_can_save =false
    self.need_list = {}
    self.is_send_proto = false
    self.base_list_left = {}
    self.base_list_right = {}
    self.skill_list_left = {}
    self.skill_list_right = {}
end
function ArtifactRecastPanel:layoutUI()

    local csbPath = PathTool.getTargetCSB("hero/artifact_recast_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.label_panel = ccui.Widget:create()
    self.label_panel:setContentSize(self.size)
    self.label_panel:setAnchorPoint(cc.p(0.5,0.5))
    self.label_panel:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self.root_wnd:addChild(self.label_panel)

    local bg_panel = self.main_panel:getChildByName("bg_panel")
    local title_1 = bg_panel:getChildByName("title_1")
    title_1:setString(TI18N("重铸前"))
    local title_2 = bg_panel:getChildByName("title_2")
    title_2:setString(TI18N("重铸后"))
    local cost_title = bg_panel:getChildByName("cost_title")
    cost_title:setString(TI18N("消耗"))
    local base_title_1 = bg_panel:getChildByName("base_title_1")
    base_title_1:setString(TI18N("基础属性"))
    local base_title_2 = bg_panel:getChildByName("base_title_2")
    base_title_2:setString(TI18N("基础属性"))
    local base_title_3 = bg_panel:getChildByName("base_title_3")
    base_title_3:setString(TI18N("符文技能"))
    local base_title_4 = bg_panel:getChildByName("base_title_4")
    base_title_4:setString(TI18N("符文技能"))

    --self.left_bg = bg_panel:getChildByName("Image_7")
    --self.right_bg = bg_panel:getChildByName("Image_9")
    self.explain_btn = self.main_panel:getChildByName("explain_btn")

    --名字
    local left_name = createLabel(26,cc.c4b(0x68,0x45,0x2a,0xff),nil,123,635,"",self.label_panel,1,cc.p(0.5,0))
    local right_name = createLabel(26,cc.c4b(0x68,0x45,0x2a,0xff),nil,546,635,"",self.label_panel,1,cc.p(0.5,0))

    local size =self.main_panel:getContentSize()
    self.left_item = BackPackItem.new(true,true,nil)
    self.left_item:setPosition(cc.p(166,692))
    self.left_item.artifact_name = left_name
    self.left_item.skill_list= {}
    self.left_item.offx = 166
    self.left_item.offy = 692
    self.main_panel:addChild(self.left_item)

    self.right_item = BackPackItem.new(true,true,nil)
    self.right_item:setPosition(cc.p(480,692))
    self.right_item.artifact_name = right_name
    self.right_item.skill_list= {}
    self.right_item.offx = 480
    self.right_item.offy = 692
    self.main_panel:addChild(self.right_item)

    self.cost_item = BackPackItem.new(true,true,nil,0.8)
    self.cost_item:setPosition(cc.p(125,65))
    self.main_panel:addChild(self.cost_item)

    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    local btn_size = self.ok_btn:getContentSize()
    self.ok_btn_label = createRichLabel(26, cc.c4b(255, 255, 255, 255), cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    self.ok_btn:addChild(self.ok_btn_label)
    self.ok_btn_label:setString(TI18N("<div outline=2,#C45A14>重铸</div>"))

    self.save_btn = self.main_panel:getChildByName("save_btn")
    self.save_btn:setTitleText(TI18N("保存"))
    local title = self.save_btn:getTitleRenderer()   
    title:enableOutline(cc.c4b(0x47, 0x84, 0x25, 0xff),2)
    self.save_btn:setVisible(false)
end


function ArtifactRecastPanel:setData(data, partner_id)
    self.data = data or {}
    self.item_config = data.config
    self.partner_id = partner_id or 0

    self.left_item:setData(data)
    self.right_item:setData(data)

    self.lock_data = SysEnv:getInstance():loadArtifactLockStatus() or {}

    -- 判断是否已经重铸但未保存
    self.is_can_save = false
    if self.data.extra_attr and next(self.data.extra_attr) ~= nil then
        self.is_can_save = true
        self.artifact_lock_data = self.lock_data[self.data.id] or {false, false, false}
    else
        self.artifact_lock_data = {false, false, false}
    end
    
    self:refreshOkBtnLabel()
    self:setBaseAttrInfo()
    self:setSkillInfo()
    self:updateBtn()
    self:updateGoodsList()
end

-- 基础属性
function ArtifactRecastPanel:setBaseAttrInfo(  )
    if not self.data or not self.data.attr or not self.item_config then return end
    local attr_num = 2
    local artifact_config = Config.PartnerArtifactData.data_artifact_data[self.item_config.id]
    local cur_star = self.data.enchant or 0 -- 当前星数
    if artifact_config[cur_star] then
        attr_num = math.min(artifact_config[cur_star].attr_num, 2)
    end

    for i,v in ipairs(self.data.attr) do
        if i > attr_num then break end        -- 超过2条属性不显示了,ui暂时不支持
        local attr_id = v.attr_id
        local attr_key = Config.AttrData.data_id_to_key[attr_id]
        local attr_val = v.attr_val/1000
        local attr_name = Config.AttrData.data_key_to_name[attr_key]
        if attr_name then
            if not self.base_list_left[i] then 
                self.base_list_left[i] = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0, 0.5), cc.p(20, 28), nil, nil, 380)
                self.left_bg:addChild(self.base_list_left[i])
            end
            local label = self.base_list_left[i]
            local _x = 30
            local _y = 410 - (i-1)*35
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
                local _y = 410 - (i-1)*35
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
            local _y = 410 - (i-1)*35
            label:setPosition(cc.p(_x, _y))
            label:setString(TI18N("随机属性"))
        end
    end
end

-- 神器技能
function ArtifactRecastPanel:setSkillInfo(  )
    if self.data == nil or self.data.extra == nil then return end

    local index = 1
    local cur_skills = {}
    local sort_func = SortTools.KeyLowerSorter("extra_k")
    table.sort(self.data.extra, sort_func)
    for i,value in ipairs(self.data.extra) do
        if value and value.extra_k and (value.extra_k == 1 or value.extra_k == 2 or value.extra_k == 8) then
            table.insert(cur_skills, value.extra_v)
            local config = Config.SkillData.data_get_skill(value.extra_v)
            if config then
                if not self.skill_list_left[index] then
                    local item = self:createSkillItem(self.left_bg, index)
                    self.skill_list_left[index] = item
                end

                local skill_item = self.skill_list_left[index]
                skill_item.skill:setData(config)
                skill_item.name:setString(config.name)
                skill_item.desc:setString(config.des)
                skill_item.random_icon:setVisible(false)
                skill_item.random_des:setVisible(false)

                local name_color = PartnerConst.SkillColor[config.level]
                name_color = name_color or cc.c3b(104,69,42)
                skill_item.name:setTextColor(name_color)

                local is_lock = self.artifact_lock_data[index] or false
                if is_lock then
                    skill_item.lock_btn:loadTextures(PathTool.getResFrame("artifact","artifact_1002"))
                else
                    skill_item.lock_btn:loadTextures(PathTool.getResFrame("artifact","artifact_1001"))
                end

                index = index + 1
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
    for i=1,index-1 do
        if not self.skill_list_right[i] then
            local item = self:createSkillItem(self.right_bg, i)
            self.skill_list_right[i] = item
        end
        local is_lock = self.artifact_lock_data[index] or false
        local skill_item = self.skill_list_right[i]
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
        end
    end
end

-- 刷新重铸后技能显示
function ArtifactRecastPanel:refreshRightSkillItem( index )
    local skill_item = self.skill_list_right[index]
    if skill_item then
        local is_lock = self.artifact_lock_data[index] or false
        if not is_lock then
            skill_item.skill:setData()
            skill_item.name:setVisible(false)
            skill_item.desc:setVisible(false)
            skill_item.lock_btn:setVisible(false)
            skill_item.random_icon:setVisible(true)
            skill_item.random_des:setVisible(true)
        else
            local skill_id = self.cur_skills[index]
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
        end
    end

    -- 花费显示
    self:refreshOkBtnLabel()
end

-- 刷新重铸按钮显示
function ArtifactRecastPanel:refreshOkBtnLabel(  )
    local lock_num = 0
    for k,v in pairs(self.artifact_lock_data) do
        if v == true then
            lock_num = lock_num + 1
        end
    end
    local cost_config = Config.PartnerArtifactData.data_artifact_recast[lock_num]
    if cost_config and cost_config.expend then
        local bid = cost_config.expend[1][1]
        local num = cost_config.expend[1][2]
        local icon_res = PathTool.getItemRes(bid)
        self.ok_btn_label:setString(string.format(TI18N("<img src='%s' scale=0.3 /><div outline=2,#C45A14>%d 重铸</div>"), icon_res, num))
    else
        self.ok_btn_label:setString(TI18N("<div outline=2,#C45A14>重铸</div>"))
    end
end

-- 创建一个技能item
function ArtifactRecastPanel:createSkillItem(parent, index)
    local item = {}
    local skill = SkillItem.new(true,true,true,0.8)
    parent:addChild(skill)
    local pos_y = 262 - (index-1)*105
    skill:setPosition(60, pos_y)
    local name = createLabel(22,cc.c4b(104,69,42,255),nil,110, pos_y+25,"",parent,1,cc.p(0,0))
    local desc = createRichLabel(20,cc.c4b(104,69,42,255),cc.p(0,1),cc.p(110, pos_y+20),0,nil,190)
    parent:addChild(desc)
    local btn_res = PathTool.getResFrame("artifact","artifact_1001")
    local lock_btn = createButton(parent, "", 25, pos_y+38, nil, btn_res)
    lock_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if not self.artifact_lock_data[index] and not self:checkSkillIsCanLock() then
                return
            end
            if self.artifact_lock_data[index] == true then
                self.artifact_lock_data[index] = false
                lock_btn:loadTextures(PathTool.getResFrame("artifact","artifact_1001"))
            else
                self.artifact_lock_data[index] = true
                lock_btn:loadTextures(PathTool.getResFrame("artifact","artifact_1002"))
            end
            self:refreshOkBtnLabel()
            if not self.is_can_save then -- 有重铸结果的不刷新右边技能显示
                self:refreshRightSkillItem(index)
            end
        end
    end)
    local icon_res = PathTool.getResFrame("artifact","artifact_1003")
    local random_icon = createSprite(icon_res, 60, pos_y, parent, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    local random_des = createLabel(24,cc.c4b(104,69,42,255),nil,110, pos_y,TI18N("随机技能"),parent,1,cc.p(0,0.5))
    item.skill = skill
    item.name = name
    item.desc = desc
    item.lock_status = false
    item.lock_btn = lock_btn
    item.random_icon = random_icon
    item.random_des = random_des
    return item
end

-- 判断是否能锁住技能（技能不能全部锁住，至少留一个不能锁）
function ArtifactRecastPanel:checkSkillIsCanLock(  )
    local skill_num = #self.cur_skills
    local lock_num = 0
    for k,v in pairs(self.artifact_lock_data) do
        if v == true then
            lock_num = lock_num + 1
        end
    end
    if lock_num >= (skill_num - 1) then
        message(TI18N("无法锁定全部技能"))
        return false
    end
    return true
end

--事件
function ArtifactRecastPanel:registerEvents()
    self.ok_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data and self.data.id then
                local skills = {}
                for k,skill_id in pairs(self.cur_skills) do
                    if self.artifact_lock_data[k] == true then
                        local temp = {}
                        temp.skill_id = skill_id
                        table.insert(skills, temp)
                    end
                end
                self.ctrl:sender11033(self.partner_id, self.data.id, skills)
            end
        end
    end)

    self.save_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.data and self.data.id then
                self.ctrl:sender11034(self.partner_id, self.data.id)
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

    if not self.recast_success_event then 
        self.recast_success_event = GlobalEvent:getInstance():Bind(HeroEvent.Artifact_Recast_Event,function()
            if not self.data or self.data.id == 0 then return end
            -- 保存技能锁定状态
            self.lock_data = self.lock_data or {}
            self.artifact_lock_data = self.artifact_lock_data or {false, false, false}
            self.lock_data[self.data.id] = self.artifact_lock_data
            SysEnv:getInstance():saveArtifactLockStatus(self.lock_data)

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

    if not self.recast_save_event then 
        self.recast_save_event = GlobalEvent:getInstance():Bind(HeroEvent.Artifact_Save_Event,function()
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

function ArtifactRecastPanel:updateBtn()
    --[[local size = self.root_wnd:getContentSize() 
    local offx = size.width/2
    if self.is_can_save == true then
        offx = size.width/2+120
        self.save_btn:setPosition(cc.p(size.width/2-120,54))
    end
    self.ok_btn:setPosition(cc.p(offx,54))--]]
    self.save_btn:setVisible(self.is_can_save)
end
function ArtifactRecastPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

--更新物品消耗
function ArtifactRecastPanel:updateGoodsList()
    if self.cost_item then
        local config = Config.PartnerArtifactData.data_artifact_data[self.item_config.id]
        local cur_star = self.data.enchant or 0
        if config[cur_star] and config[cur_star].ref_expend and next(config[cur_star].ref_expend) ~= nil then
            local bid = config[cur_star].ref_expend[1][1]
            local num = config[cur_star].ref_expend[1][2]
            local item_data = Config.ItemData.data_get_data(bid)
            self.cost_item:setData(item_data)
            self.cost_item:setDefaultTip()
            local have_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(bid)
            self.cost_item:setNeedNum(num, have_num)
        end
    end
end

function ArtifactRecastPanel:DeleteMe()
    if self.recast_success_event then 
        GlobalEvent:getInstance():UnBind(self.recast_success_event)
        self.recast_success_event = nil
    end
    if self.recast_save_event then 
        GlobalEvent:getInstance():UnBind(self.recast_save_event)
        self.recast_save_event = nil
    end
    if self.left_item then
        self.left_item:DeleteMe()
        self.left_item = nil
    end
    if self.right_item then
        self.right_item:DeleteMe()
        self.right_item = nil
    end
    if self.cost_item then
        self.cost_item:DeleteMe()
        self.cost_item = nil
    end

    self.is_send_proto = false
end



