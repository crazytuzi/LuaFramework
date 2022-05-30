-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      公会技能升级
-- <br/> 2020年4月11日
-- --------------------------------------------------------------------
GuildskillLevelUpPanel = GuildskillLevelUpPanel or BaseClass(BaseView)

local controller = GuildskillController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove

function GuildskillLevelUpPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "guildskill/guildskill_level_up_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single }
    }

    --消耗数据列表
    self.item_list = {}

    self.title_height = 60 --横条高度
end

function GuildskillLevelUpPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 

    self.main_panel = self.main_container:getChildByName("main_panel")
    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("技能升级"))
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.Image_22 = self.main_panel:getChildByName("Image_22")
    self.arrow = self.main_panel:getChildByName("arrow")

    self.icon_bg_sp = self.main_panel:getChildByName("icon_bg_sp")
    

    self.left_lev = self.main_container:getChildByName("left_lev")
    self.right_lev = self.main_container:getChildByName("right_lev")
    self.skill_key = self.main_container:getChildByName("skill_key")
    self.skill_key:setString(TI18N("当前效果:"))
    self.next_skill_key = self.main_container:getChildByName("next_skill_key")
    self.next_skill_key:setString(TI18N("下一等级:"))

    self.skill_desc = createRichLabel(20, Config.ColorData.data_new_color4[6], cc.p(0, 1), cc.p(168, 453), nil, nil, 460)

    self.next_skill_desc = createRichLabel(20, cc.c3b(0x24,0x90,0x03), cc.p(0, 1), cc.p(168, 318), nil, nil, 460)
    self.main_container:addChild(self.skill_desc)
    self.main_container:addChild(self.next_skill_desc)

    self.skill_node = self.main_container:getChildByName("skill_node")

    self.tips = self.main_container:getChildByName("tips")
    self.tips:setString("")
    self.skill_item = SkillItem.new(true,true,true,nil,nil,false)
    self.skill_node:addChild(self.skill_item)
    -- 消耗
    self.cost_bg_list = {}
    for i=1, 2 do
        local cost_bg = self.main_container:getChildByName("cost_bg_"..i)
        self.cost_bg_list[i] = {}
        self.cost_bg_list[i].cost_bg = cost_bg
        self.cost_bg_list[i].cost_icon = cost_bg:getChildByName("cost_icon")
        self.cost_bg_list[i].cost_txt = cost_bg:getChildByName("cost_txt")
    end


    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn_label = self.right_btn:getChildByName("label")
    self.right_btn_label:setString(TI18N("升 级"))

        --底部线
    local line_img = createImage(self.main_container, nil, 0, 0, cc.p(0,0.5), false, 1)
    -- line_img:setCapInsets(cc.rect(24, 24, 107, 89))
    line_img:setAnchorPoint(0.5,0)
    line_img:setScaleX(1.82)
    line_img:setPosition(cc.p(self.main_container:getContentSize().width/2, 18))

    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/pattern", "pattern_1")
    self.line_load = loadImageTextureFromCDN(line_img, bg_res, ResourcesType.single, self.line_load)
end

function GuildskillLevelUpPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,false,2)

    registerButtonEventListener(self.right_btn, handler(self, self.onClickRightBtn) ,true, 2)

end

--关闭
function GuildskillLevelUpPanel:onClickBtnClose()
    controller:openGuildskillLevelUpPanel(false)
end

--选择
function GuildskillLevelUpPanel:onClickRightBtn()
    if self.is_show_tips then
        message(self.is_show_tips)
        return
    end
    if self.career then
        controller:send23708(self.career)
        -- self:onClickBtnClose()
    end
end


--职业
function GuildskillLevelUpPanel:openRootWnd(career)
    local pvp_career_data = model:getPvpskillInfoByCareer(career)
    if not pvp_career_data then return end
    self.career = career
    self.left_lev:setString("Lv."..pvp_career_data.skill_lev)
    self.right_lev:setString("Lv."..(pvp_career_data.skill_lev + 1))

    local skill_lev = pvp_career_data.skill_lev
    if skill_lev <= 0 then
        skill_lev = 1
    end 
    local key = getNorKey(career, skill_lev)
    local pvp_skill_config = Config.GuildSkillData.data_pvp_skill_info(key)
    if pvp_skill_config then
        local skill_config = Config.SkillData.data_get_skill(pvp_skill_config.skill_id)
        self.skill_item:setData(skill_config)
        self.skill_item:showName(true,skill_config.name,nil,22,false,Config.ColorData.data_new_color4[6],PathTool.getResFrame("common","common_90003"),cc.size(168,31))
        
        if pvp_career_data.skill_lev == 0 then
            --表示要锁住
            self.skill_desc:setString(TI18N("无"))
            self.next_skill_desc:setString(skill_config.des)
        else
            self.skill_desc:setString(skill_config.des)
            local key = getNorKey(career, skill_lev + 1)
            local next_pvp_skill_config = Config.GuildSkillData.data_pvp_skill_info(key)
            if next_pvp_skill_config then
                local next_skill_config = Config.SkillData.data_get_skill(next_pvp_skill_config.skill_id)
                if next_skill_config then
                    self.next_skill_desc:setString(next_skill_config.des)
                end
            else
                self.next_skill_key:setVisible(false)
                self.next_skill_desc:setVisible(false)
                self.tips:setVisible(false)
                self.Image_22:setVisible(false)
                self.arrow:setVisible(false)
                self.right_lev:setVisible(false)
                self.right_btn:setVisible(false)
                for i,v in ipairs(self.cost_bg_list) do
                    v.cost_bg:setVisible(false)
                end
                self.tips_desc = createRichLabel(26, cc.c3b(0x64,0x32,0x23), cc.p(0.5, 0.5), cc.p(338, 77), nil, nil, 500)
                self.tips_desc:setString(TI18N("已经已达最大等级"))
                self.main_container:addChild(self.tips_desc)
                self.left_lev:setPositionX(338)
                return
            end
        end
        -- (bool,name,pos,fontSize, is_bg,fontColor,res_img,res_size)
        if pvp_career_data.skill_lev == 0 then
            local key = getNorKey(career, pvp_career_data.skill_lev)
            --如果技能还是 0级..需要还原一下
            pvp_skill_config = Config.GuildSkillData.data_pvp_skill_info(key)
            if not pvp_skill_config then return end
        end
        
        self:updateCostInfo(pvp_skill_config.loss)


        --判断是否满足升级条件
        local status = true
        for i,v in ipairs(pvp_career_data.attr_formation) do
            if v.lev < pvp_skill_config.need_lev then
                status = false
            end
        end
        if not status then
            local name = PartnerConst.Hero_Type[career] or ""
            self.is_show_tips = string_format(TI18N("需要每个%s属性达%s级"), name, pvp_skill_config.need_lev)
            self.tips:setString(self.is_show_tips )
            self.right_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
            setChildUnEnabled(true, self.right_btn)
        end
    end
end


function GuildskillLevelUpPanel:updateCostInfo( cost )
    for i=1,2 do
        local cost_data = cost[i]
        local cost_icon = self.cost_bg_list[i].cost_icon
        local cost_txt = self.cost_bg_list[i].cost_txt
        if cost_data then
            local bid = cost_data[1]
            local num = cost_data[2]
            local have_num = 0
            local item_config = Config.ItemData.data_get_data(bid)
            if item_config then
                cost_icon:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
                have_num = BackpackController:getInstance():getModel():getItemNumByBid(bid)
                cost_txt:setString(MoneyTool.GetMoneyString(have_num) .. "/" .. MoneyTool.GetMoneyString(num))
                if have_num >= num then
                    cost_txt:setTextColor(cc.c3b(255, 246, 228))
                else
                    cost_txt:setTextColor(cc.c3b(0xff,0x8b,0x8b))
                end
            end
        else
            cost_txt:setString("")
        end
    end 
end

function GuildskillLevelUpPanel:close_callback()

        if self.line_load  then
        self.line_load:DeleteMe()
    end
    self.line_load = nil

    if self.skill_item then
        self.skill_item:DeleteMe()
        self.skill_item = nil
    end

    controller:openGuildskillLevelUpPanel(false)
end