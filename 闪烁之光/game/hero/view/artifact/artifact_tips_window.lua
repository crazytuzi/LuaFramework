-- --------------------------------------------------------------------
-- 竖版神器tips
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ArtifactTipsWindow = ArtifactTipsWindow or BaseClass(BaseView)

local string_format = string.format
local controller = HeroController:getInstance()
function ArtifactTipsWindow:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "hero/artifact_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("artifact","artifact"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Tips    
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.base_list = {}
    self.skill_list = {}
    self.tab_list = {}
end

function ArtifactTipsWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.container = self.main_panel:getChildByName("container")            -- 背景,需要动态设置尺寸
    self.container_init_size = self.container:getContentSize()

    -- 基础属性,名字,类型和评分等
    self.base_panel = self.container:getChildByName("base_panel")
    self.base_panel:getChildByName("score_title"):setString(TI18N("评分："))
    self.equip_item =  BackPackItem.new(true,true,nil,1,false)
    self.equip_item:setPosition(cc.p(72,68))
    self.base_panel:addChild(self.equip_item)
    self.name = self.base_panel:getChildByName("name")
    self.equip_type = self.base_panel:getChildByName("equip_type")
    self.power_label = CommonNum.new(1, self.base_panel, 1, - 2, cc.p(0, 0))
    self.power_label:setPosition(cc.p(230, 32))
    self.power_label:setNum(0)
    self.power_label:setScale(0.8)

    -- 基础属性
    self.baseattr_panel = self.container:getChildByName("baseattr_panel")
    self.baseattr_panel:getChildByName("label"):setString(TI18N("基础属性"))
    self.baseattr_panel_height = self.baseattr_panel:getContentSize().height

    -- 技能1容器
    self.skill_panel_1 = self.container:getChildByName("skill_panel_1")
    self.skill_panel_1:getChildByName("label"):setString(TI18N("符文技能"))
    self.skill_pre_btn = self.skill_panel_1:getChildByName("skill_pre_btn")
    self.skill_pre_btn:getChildByName("label"):setString(TI18N("技能预览"))

    -- 技能2容器
    self.skill_panel_2 = self.container:getChildByName("skill_panel_2")
    self.skill_panel_height = self.skill_panel_2:getContentSize().height

    -- 技能3容器
    self.skill_panel_3 = self.container:getChildByName("skill_panel_3")

    -- 按钮容器
    self.tab_panel = self.container:getChildByName("tab_panel")
    self.tab_panel_height = self.tab_panel:getContentSize().height
    local title_list ={[1]=TI18N("合成"),[2]=TI18N("重铸"),[3]=TI18N("分解"),[4]=TI18N("穿戴"),}
    for i=1,4 do 
        local btn = self.tab_panel:getChildByName("tab_btn_"..i)
        if btn then 
            self.tab_list[i] = btn
            btn:setTitleText(title_list[i])
            btn.index = i
        end
    end

    self.close_btn = self.container:getChildByName("close_btn")
end


function ArtifactTipsWindow:register_event()
    for i, btn in ipairs(self.tab_list) do
        btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                self:clickBtn(sender.index)
            end
        end)
    end
    
    if self.background then 
        self.background:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                controller:openArtifactTipsWindow(false)
            end
        end)
    end
    if self.close_btn then 
        self.close_btn:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                controller:openArtifactTipsWindow(false)
            end
        end)
    end

    registerButtonEventListener(self.skill_pre_btn, function (  )
        HeroController:getInstance():openArtifactSkillWindow(true)
    end, true)
end

function ArtifactTipsWindow:clickBtn(index)
    index = index or 1
    if index == PartnerConst.Artifact_Type.Source then
        if self.data and self.data.config then
            BackpackController:getInstance():openTipsSource( true, self.data.config)
        end
    elseif index == PartnerConst.Artifact_Type.Cloth then 
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner)
    elseif index == PartnerConst.Artifact_Type.Compose then 
        if self.open_type == PartnerConst.ArtifactTips.sell then
            --出售

            GuildmarketplaceController:getInstance():sender26901(self.data.id, 1, BackPackConst.Bag_Code.BACKPACK)
        else
            local config = Config.CityData.data_base[CenterSceneBuild.mall]
            if config == nil then return end
            local is_open = MainuiController:getInstance():checkIsOpenByActivate(config.activate)
            if is_open then
                ForgeHouseController:getInstance():openForgeHouseView(true, ForgeHouseConst.Tab_Index.Artifact)
            end
        end
    elseif index == PartnerConst.Artifact_Type.Recast then  
        controller:openArtifactRecastWindow(true, self.data, self.partner_id)
    elseif index == PartnerConst.Artifact_Type.Getoff then
        if self.is_off_tips then
            local str = TI18N("卸下该符文后，该符文栏将在7星开启，是否确定？")
            CommonAlert.show( str, TI18N("确定"), function()
                if self.data and self.data.id then
                    controller:sender11030(self.partner_id,self.artifact_pos,self.data.id,0)
                end  
            end, TI18N("取消"),nil,nil,nil,{title = TI18N("卸下提示")})
        else
            if self.data and self.data.id then
                controller:sender11030(self.partner_id,self.artifact_pos,self.data.id,0)
            end
        end
        
    elseif index == PartnerConst.Artifact_Type.Replace then
        controller:openArtifactListWindow(true,self.artifact_pos,self.partner_id)
    elseif index == PartnerConst.Artifact_Type.Upstar then
        --controller:openArtifactWindow(true,1,self.data,self.partner_id)
    elseif index == PartnerConst.Artifact_Type.Resolve then
        if self.data and self.data.config and self.data.config.id and self.data.enchant then
            local config = Config.PartnerArtifactData.data_artifact_resolve[self.data.config.id]
            if config and config[1] then
                local bid = config[1][1]
                local num = config[1][2]

                local msg = string.format(TI18N("分解此符文可以获得<img src=%s visible=true scale=0.35 />%d，是否继续？"),PathTool.getItemRes(bid),num)
                CommonAlert.show(
                    msg,
                    TI18N("确定"),
                    function()
                        controller:sender11035(self.data.id)
                    end,
                    TI18N("取消"),
                    nil,
                    CommonAlert.type.rich
                )
            else
                message(TI18N("无该符文配置数据"))
            end
        end
    end

    controller:openArtifactTipsWindow(false)
end

function ArtifactTipsWindow:openRootWnd(data, open_type, partner_id, pos, is_off_tips, setting)
    self.open_type = open_type or PartnerConst.ArtifactTips.backpack
    self.data = data or {}
    self.item_config = data.config
    self.partner_id = partner_id or 0
    self.artifact_pos = pos or 1
    self.is_off_tips = is_off_tips or false
    self.setting = setting or {}
    -- 动态设置位置
    local target_height = self.container_init_size.height

    -- 技能
    local show_skill_num = 0 -- 需要显示的技能数量
    if self.data and self.data.extra then
        local skill_num = 0
        for i,v in ipairs(self.data.extra) do
            if v.extra_k == 1 or v.extra_k == 2 or v.extra_k == 8 then
                skill_num = skill_num + 1
            end
        end

        show_skill_num = skill_num
        --[[if self.item_config then
            local artifact_config = Config.PartnerArtifactData.data_artifact_data[self.item_config.id]
            local cur_star = self.data.enchant -- 当前星数
            if artifact_config[cur_star] and artifact_config[cur_star].next_skill_star > 0 then
                show_skill_num = skill_num + 1
            end
        end--]]
    end

    local show_limit_info = false
    if self.data.limit_day then --每日限购
        show_limit_info = true
        target_height = target_height + 30
    end

    if show_skill_num < 1 then
        self.skill_panel_1:setVisible(false)
        target_height = target_height - self.skill_panel_height
    end
    if show_skill_num < 2 then
        self.skill_panel_2:setVisible(false)
        target_height = target_height - self.skill_panel_height
    end
    if show_skill_num < 3 then
        self.skill_panel_3:setVisible(false)
        target_height = target_height - self.skill_panel_height
    end

    -- 底部按钮
    if self.open_type == PartnerConst.ArtifactTips.partner then
        --target_height = target_height - 50
        self.tab_list[3]:setTitleText(TI18N("卸下")) 
        self.tab_list[3].index = PartnerConst.Artifact_Type.Getoff 
        self.tab_list[4]:setTitleText(TI18N("替换"))
        self.tab_list[4].index = PartnerConst.Artifact_Type.Replace 
    elseif self.open_type == PartnerConst.ArtifactTips.normal then
        target_height = target_height - self.tab_panel_height
        self.tab_panel:setVisible(false)
    elseif self.open_type == PartnerConst.ArtifactTips.buy then
        local height = self:addMarketplaceTime() or 0
        target_height = target_height + height + 10
        target_height = target_height - self.tab_panel_height
        self.tab_panel:setVisible(false)
    elseif self.open_type == PartnerConst.ArtifactTips.sell then
        self.tab_list[1]:setTitleText(TI18N("放入")) 
        self.tab_list[1]:setPositionX(211)
        self.tab_list[2]:setVisible(false)
        self.tab_list[3]:setVisible(false)
        self.tab_list[4]:setVisible(false)
        target_height = target_height - self.tab_panel_height/2 + 10
    end

    if target_height ~= self.container_init_size.height then
        self.container:setContentSize(cc.size(self.container_init_size.width, target_height))
        self.close_btn:setPositionY(target_height-25)
        self.base_panel:setPositionY(target_height-4)
        local y = target_height-4-self.base_panel:getContentSize().height
        if show_limit_info then
            self.show_limit_y = y - 20
            y = y - 30
        end

        self.baseattr_panel:setPositionY(y)
        y = y - self.baseattr_panel:getContentSize().height
        local x = 1
        if show_skill_num == 0 then
            self.tab_panel:setPositionY(y)
            y = y - 15
        elseif show_skill_num == 1 then
            self.skill_panel_1:setPositionY(y)
            y = self.skill_panel_1:getPositionY()-self.skill_panel_1:getContentSize().height
            self.tab_panel:setPositionY(y)
        elseif show_skill_num == 2 then
            self.skill_panel_1:setPositionY(y)
            self.skill_panel_2:setPositionY(self.skill_panel_1:getPositionY()-self.skill_panel_1:getContentSize().height)
            y = self.skill_panel_2:getPositionY()-self.skill_panel_height
            self.tab_panel:setPositionY(y)
        elseif show_skill_num == 3 then
            self.skill_panel_1:setPositionY(y)
            self.skill_panel_2:setPositionY(self.skill_panel_1:getPositionY()-self.skill_panel_1:getContentSize().height)
            self.skill_panel_3:setPositionY(self.skill_panel_2:getPositionY()-self.skill_panel_height)
            y = self.skill_panel_3:getPositionY()-self.skill_panel_height
            self.tab_panel:setPositionY(y)
        end

        if self.setting and self.setting.is_market_place and self.data.end_time and next(self.data.end_time) ~= nil then
            --因为有时间 肯定没有 self.tab_panel 的.所以y 收集的是最后一个技能的y
            --说明有时间
            self.market_time_label:setPositionY(y)
        end
    end

    self.score_val = 0 -- 符文评分（技能评分+属性评分）
    self:setBaseInfo()
    self:setBaseAttrInfo()
    self:setSkillInfo()
    self.power_label:setNum(self.score_val)
    --限购信息
    self:initLimitBuyInfo()
end


--限购信息
--data.limit_total_num = 限购最大数量
--data.limit_day  每日限购数量
--data.其他限购未加入
function ArtifactTipsWindow:initLimitBuyInfo()
    if not self.data then return end
    if self.data.limit_day then --每日限购
        local total_count = self.data.limit_total_num or 0
        local label = self:getLimitBuytLabel()
        if label then
            label:setString(string_format(TI18N("每日限购<div fontcolor=#249003>%s/%s</div>个"), self.data.limit_day, total_count))
        end
    end
end

function ArtifactTipsWindow:getLimitBuytLabel()
    if self.limit_buy_label == nil then
        local y = self.show_limit_y or 0
        self.limit_buy_label = createRichLabel(22, cc.c4b(0xff,0xee,0xdd,0xff), cc.p(0, 0.5), cc.p(13, y) ,nil,nil,1000)
        self.container:addChild(self.limit_buy_label)
    end
    return self.limit_buy_label
end

function ArtifactTipsWindow:addMarketplaceTime()
    if self.setting and self.setting.is_market_place and self.data.end_time and next(self.data.end_time) ~= nil then
        self.market_time_label = createRichLabel(24, cc.c4b(0xff,0x9b,0x1e,0xff), cc.p(0, 1), cc.p(17, -10000), 8, nil, 1000) 
        self.container:addChild(self.market_time_label)
        local time = self.data.end_time[1].end_unixtime or 0
        local count = self.data.end_time[1].end_num or 1
        local str 
        local time = time - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        if time <= 0 then
            str = string.format(TI18N("该物品已过期"))
        else
            str = string.format(TI18N("该物品于<div fontcolor=#249003>%s</div>后过期"), TimeTool.GetTimeFormatDayIIIIII(time))    
        end 
        self.market_time_label:setString(str)
        local size = self.market_time_label:getContentSize()
        return size.height
    end
end


--==============================--
--desc:设置基础信息
--time:2018-10-20 09:40:23
--@return 
--==============================--
function ArtifactTipsWindow:setBaseInfo()
    if self.data == nil or self.item_config == nil then return end
    local data = self.data

    --self.equip_item:setBaseData(self.item_config.id)
    self.equip_item:setData(data)

    local quality = 0
    if self.item_config.quality >= 0 and self.item_config.quality <= 5 then
        quality = self.item_config.quality
    end
    local background_res = PathTool.getResFrame("tips", "tips_"..quality)
    loadSpriteTexture(self.base_panel, background_res, LOADTEXT_TYPE_PLIST) 
    local color = BackPackConst.getEquipTipsColor(quality)
    self.name:setTextColor(color) 
    self.name:setString(self.item_config.name)

    self.equip_type:setString(TI18N("类型：")..self.item_config.type_desc)
end

--==============================--
--desc:设置基础属性
--time:2018-10-20 11:42:16
--@return 
--==============================--
function ArtifactTipsWindow:setBaseAttrInfo()
    if not self.data or not self.data.attr or not self.item_config then return end
    local artifact_config = Config.PartnerArtifactData.data_artifact_data[self.item_config.id]
    local attr_num = 2
    if artifact_config then
        attr_num = artifact_config.attr_num
    end

    local socre_data = Config.PartnerArtifactData.data_artifact_attr_score[self.item_config.id]

    local index = 1 
    for i,v in ipairs(self.data.attr) do
        if index > attr_num then break end
        local attr_id = v.attr_id
        local attr_key = Config.AttrData.data_id_to_key[attr_id]
        local attr_val = v.attr_val/1000
        local attr_name = Config.AttrData.data_key_to_name[attr_key]
        if attr_name then
            if not self.base_list[index] then 
                self.base_list[index] = createRichLabel(22, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0, 0.5), cc.p(20, 28), nil, nil, 380)
                self.baseattr_panel:addChild(self.base_list[index])
            end
            local label = self.base_list[index]
            local _x = 30 + (i-1) * 200
            label:setPositionX(_x)

            local icon = PathTool.getAttrIconByStr(attr_key)
            local is_per = PartnerCalculate.isShowPerByStr(attr_key)
            if is_per == true then
                attr_val = (attr_val/10).."%"
            end
            local attr_str = string_format("<img src='%s' scale=1 /> <div fontcolor=#c1b7ab> %s：</div><div fontcolor=#ffeedd>%s</div>", PathTool.getResFrame("common", icon), attr_name, attr_val)
            label:setString(attr_str)
            index = index + 1
        end

        if socre_data then
            self.score_val = self.score_val + socre_data[attr_key] or 0
        end
    end

    --[[if (index-1) < 2 then
        if artifact_config and artifact_config[cur_star] then
            if artifact_config[cur_star].next_attr_star > 0 then
                if not self.base_list[index] then 
                    self.base_list[index] = createRichLabel(22, cc.c4b(0xc1,0xb7,0xab,0xff), cc.p(0, 0.5), cc.p(20, 28), nil, nil, 380)
                    self.baseattr_panel:addChild(self.base_list[index])
                end
                local label = self.base_list[index]
                local _x = 30 + (index-1) * 200
                label:setPositionX(_x)
                label:setString(string_format(TI18N("<div fontcolor=#65df74>%d星解锁第%s属性</div>"), artifact_config[cur_star].next_attr_star, StringUtil.numToChinese(index)))
            end
        end
    end--]]
end

--==============================--
--desc:设置技能显示
--time:2018-10-20 07:13:45
--@return 
--==============================--
function ArtifactTipsWindow:setSkillInfo()
    if self.data == nil or self.data.extra == nil then return end
    local index = 1
    local const_config  =Config.PartnerArtifactData.data_artifact_const
    for i,value in ipairs(self.data.extra) do
        if value and value.extra_k and (value.extra_k == 1 or value.extra_k == 2 or value.extra_k == 8) then
            local config = Config.SkillData.data_get_skill(value.extra_v)
            if config then
                if not self.skill_list[index] then
                    local item = self:createSkillItem(i, self["skill_panel_"..index])
                    self.skill_list[index] = item
                end

                local skill_item = self.skill_list[index]
                skill_item.skill:showLockIcon(false)
                skill_item.skill:setData(config)
                skill_item.name:setString(config.name)
                skill_item.desc:setString(transformTextToShort(config.des, 34))
                skill_item.desc:setPositionY(90)

                local skill_lev = config.level or 1
                if const_config["skill_score_"..skill_lev] and const_config["skill_score_"..skill_lev].val then 
                    self.score_val = self.score_val + const_config["skill_score_"..skill_lev].val
                end
                index = index + 1
            end
        end
    end

    --[[if index <= 3 then
        local artifact_config = Config.PartnerArtifactData.data_artifact_data[self.item_config.id]
        local cur_star = self.data.enchant -- 当前星数
        if artifact_config and artifact_config[cur_star] then
            if artifact_config[cur_star].next_skill_star > 0 then
                if not self.skill_list[index] then
                    local item = self:createSkillItem(nil, self["skill_panel_"..index])
                    self.skill_list[index] = item
                end
                local skill_item = self.skill_list[index]
                skill_item.skill:showLockIcon(true)
                skill_item.desc:setString(string_format(TI18N("<div fontcolor=#65df74>%s星解锁</div>随机被动技能%d"), StringUtil.numToChinese(artifact_config[cur_star].next_skill_star), index))
                skill_item.desc:setPositionY(74)
            end
        end
    end--]]
end

--==============================--
--desc:创建技能显示单例
--time:2018-10-20 07:09:21
--@index:
--@parent:
--@return 
--==============================--
function ArtifactTipsWindow:createSkillItem(index, parent)
    local item = {}
    local skill = SkillItem.new(true,true,true,0.8)
    parent:addChild(skill)
    skill:setPosition(70, 62)
    local name = createLabel(24,cc.c4b(0xfe,0xee,0xba,0xff),nil,140, 96,"",parent,1,cc.p(0,0))
    local desc = createRichLabel(22,cc.c4b(0xff,0xee,0xdd,0xff),cc.p(0,1),cc.p(140, 88),4,nil,260)
    parent:addChild(desc)
    item.skill = skill
    item.name = name
    item.desc = desc
    return item
end

function ArtifactTipsWindow:close_callback()
    if self.power_label then
        self.power_label:DeleteMe()
        self.power_label = nil
    end
    if self.equip_item then
        self.equip_item:DeleteMe()
        self.equip_item = nil
    end
    for i,v in pairs(self.skill_list) do 
        if v.skill then 
            v.skill:DeleteMe()
        end
    end
    controller:openArtifactTipsWindow(false)
end
