-- --------------------------------------------------------------------
-- 图鉴伙伴查看总览
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

CheckAllPanel = class("CheckAllPanel", function() 
	return ccui.Layout:create()
end)



function CheckAllPanel:ctor(data,is_pokedex)
    self.data = data
    self.point_list = {}
    self.skill_list = {}
    self.is_pokedex = is_pokedex or false
    self.size = cc.size(620,420)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
    self:setPosition(cc.p(self.size.width/2,self.size.height/2))

    self.scroll_width = 620
    self.scroll_height = 430
    self.max_height = 655
    self.all_scroll = createScrollView(self.scroll_width,self.scroll_height,13,10,panel,ccui.ScrollViewDir.vertical)
    self.all_scroll:setInnerContainerSize(cc.size(600,self.max_height))
    self:addChild(self.all_scroll)
    --宝可梦特色
    self:createHeroDesc()
    --宝可梦技能
    self:createHeroSkill()
    --来源途径
    self:createHeroSource()
	self:registerEvent()
end
function CheckAllPanel:registerEvent()
    -- body
end
function CheckAllPanel:createHeroDesc()
    local size = cc.size(623,250)
    self.desc_panel = ccui.Widget:create()
    self.desc_panel:setContentSize(size)
    self.all_scroll:addChild(self.desc_panel)
    self.desc_panel:setPosition(cc.p(self.scroll_width/2,self.max_height-125))
    self.max_height = self.max_height-145
    local res = PathTool.getResFrame("common","common_90024")
    local bg = createImage(self.desc_panel, res, size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
    bg:setContentSize(size)

    local res = PathTool.getResFrame("common","common_90025")
    local title_bg = createImage(self.desc_panel, res, self.size.width/2,200, cc.p(0.5,0), true, 0, true)
    title_bg:setContentSize(cc.size(617,44))
    -- title_bg:setCapInsets(cc.rect(170, 22, 1, 1))
    local res = PathTool.getResFrame("pokedex","pokedex_1")
    local icon = createImage(self.desc_panel, res, 15,195, cc.p(0,0), true, 1, false)
    local title = createLabel(26,Config.ColorData.data_color4[175],nil,75,205,"",self.desc_panel,0, cc.p(0,0))
    title:setString(TI18N("宝可梦特色"))

    self:updateRightMove()
end

function CheckAllPanel:updateRightMove()
    local data = self.data
    if not data then return end
    local r = data.hero_attr
    local x = 0 + r[1] * math.cos(72 * math.pi / 180)*2/3
    local x1 = 0 + r[2] * math.cos(72 * 2 * math.pi / 180)*2/3
    local x2 = 0 + r[3] * math.cos(72 * 3 * math.pi / 180)*2/3
    local x3 = -4 + r[4] * math.cos(72 * 4 * math.pi / 180)*2/3
    local x4 = 3 + r[5] * math.cos(72 * 5 * math.pi / 180)*2/3

    local y = 0 + r[1] * math.sin(72 * math.pi / 180)*2/3
    local y1 = 0 + r[2] * math.sin(72 * 2 * math.pi / 180)*2/3
    local y2 = 0 + r[3] * math.sin(72 * 3 * math.pi / 180)*2/3
    local y3 = -2 + r[4] * math.sin(72 * 4 * math.pi / 180)*2/3
    local y4 = -2 + r[5] * math.sin(72 * 5 * math.pi / 180)*2/3
    
    local point = {[1] = cc.p(math.floor(x), math.floor(y)), [2] = cc.p(math.floor(x1), math.floor(y1)), [3] = cc.p(math.floor(x2), math.floor(y2)), [4] = cc.p(math.floor(x3), math.floor(y3)), [5] = cc.p(math.floor(x4), math.floor(y4)) }
    if not self.right_bg then
        self.right_bg = createSprite(PathTool.getResFrame("pokedex", "pokedex_8"), 160,95 , self.desc_panel, cc.p(0.5, 0.5), LOADTEXT_PLIST)
        self.temp_sp = createSprite(PathTool.getResFrame("pokedex", "pokedex_9"),83,90, self.right_bg, cc.p(0.5, 0.5), LOADTEXT_PLIST)
     
        local temp_sp_1 = createSprite(PathTool.getResFrame("pokedex", "pokedex_10"),66,63,self.temp_sp, cc.p(0.5, 0.5), LOADTEXT_PLIST)
        -- local temp_sp_2 = createSprite(PathTool.getResFrame("pokedex", "pokedex_11"),127,127, self.temp_sp, cc.p(0.5, 0.5), LOADTEXT_PLIST)
    end
    -- if self.drawNode then 
    --     self.drawNode:removeAllChildren()
    --     self.drawNode = nil
    --     self.point_list = {}
    -- end
    if not self.drawNode then
        self.drawNode = cc.DrawNode:create()
        self.drawNode:setPosition(85, 85)
        self.drawNode:setRotation(51)
        self.drawNode:setAnchorPoint(cc.p(0.5, 0.5))
        self.right_bg:addChild(self.drawNode)

    end
    if self.drawNode then
        self.drawNode:clear()
        self.drawNode:drawPolygon(point, 5, cc.c4f(0, 0.75, 1, 1), 1, cc.c4f(0, 1, 0, 0))
    end
    if  not self.temp_sp_3 then
        self.temp_sp_3 = createSprite(PathTool.getResFrame("pokedex", "pokedex_11"),82,91, self.right_bg, cc.p(0.5, 0.5), LOADTEXT_PLIST)
    end
    local label_list = {[1] = TI18N("控制"),[2] = TI18N("生存"),[3] = TI18N("攻击"),[4] = TI18N("治疗"),[5] = TI18N("辅助")}
    local label_pos = {[1] = cc.p(100,4), [2] = cc.p(36,90), [3] = cc.p(-69,49), [4] = cc.p(-81,-65), [5] = cc.p(25,-92) }
    for i = 1, 5 do
        if not self.point_list[i] then
            local res = PathTool.getResFrame("pokedex","pokedex_28")
            local bg = createImage(self.drawNode, res, label_pos[i].x+2, label_pos[i].y - 1, cc.p(0.5,0.5), true, 0, false)
            bg:setRotation(-51)
            local label = createLabel(20,141,nil,label_pos[i].x, label_pos[i].y - 1,label_list[i],self.drawNode)
            label:setAnchorPoint(cc.p(0.5,0.5))
            label:setRotation(-50)
            local ponit_sp = createSprite(PathTool.getResFrame("pokedex","pokedex_27"),point[i].x,point[i].y,self.drawNode,cc.p(0.5,0.5),LOADTEXT_PLIST)
            -- ponit_sp:setScale(10)
            label.ponit_sp = ponit_sp
            self.point_list[i] = label
        end
        self.point_list[i]:setPosition(label_pos[i].x, label_pos[i].y - 1)
        self.point_list[i].ponit_sp:setPosition(point[i].x, point[i].y)
    end


    --关键词
    local res = PathTool.getResFrame("pokedex","pokedex_12")
    local bg = createImage(self.desc_panel, res, 440,100, cc.p(0.5,0.5), true, 0, true)
    bg:setContentSize(cc.size(285,143))
    bg:setCapInsets(cc.rect(43, 44, 1, 1))

    --三个关键词
    local label_list = {}
    for i=1,3 do
        local label =  createLabel(24,175,nil,395,120-(i-1)*32,"",self.desc_panel)
        label_list[i] = label
    end
    --位置
    local type = data.type or 1
    local str =PartnerConst.Hero_Type[type] or ""
    label_list[1]:setString(str..TI18N("宝可梦"))
    --流派
    local config = Config.PartnerData.data_pokedex[data.bid]
    if not config then return end
    local str =config.group_name or ""
    label_list[2]:setString(str)

    --宝可梦定位
    local str =data.hero_pos or ""
    label_list[3]:setString(str)
end
function CheckAllPanel:createHeroSkill()
    local size = cc.size(623,225)
    self.skill_panel = ccui.Widget:create()
    self.skill_panel:setContentSize(size)
    self.all_scroll:addChild(self.skill_panel)
    self.max_height = self.max_height-size.height
    self.skill_panel:setPosition(cc.p(self.scroll_width/2,self.max_height))
    
    local res = PathTool.getResFrame("common","common_90024")
    local bg = createImage(self.skill_panel, res, size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
    bg:setContentSize(size)

    local res = PathTool.getResFrame("common","common_90025")
    local title_bg = createImage(self.skill_panel, res, self.size.width/2,177, cc.p(0.5,0), true, 0, true)
    title_bg:setContentSize(cc.size(617,44))
    -- title_bg:setCapInsets(cc.rect(170, 22, 1, 1))
    local res = PathTool.getResFrame("pokedex","pokedex_2")
    local icon = createImage(self.skill_panel, res,  15,175, cc.p(0,0), true, 1, false)

    local title = createLabel(26,Config.ColorData.data_color4[175],nil,75,185,"",self.skill_panel,0, cc.p(0,0))
    title:setString(TI18N("宝可梦技能"))

    --2个技能
    local data = self.data
    local skill_list = {}
    if self.is_pokedex == true then
        skill_list = Config.PartnerData.data_pokedex[data.bid].show_skill
    else
        local skills = data.skills or {}
        local addition_skill = data.addition_skill or 0
        local addition_skill_1 = data.addition_skill2 or 0
        skill_list[1] = skills[2]
        skill_list[2] = addition_skill
        if addition_skill_1 ~= 0 then
            skill_list[3] = addition_skill_1
        end
    end
    
    for i=1, #skill_list do
        local vo = Config.SkillData.data_get_skill(skill_list[i])
        local is_lock = false 
        if i ~= 1 then 
            is_lock = true 
        end
        local skill = self:createSkillItem(vo, is_lock, i)
        self.skill_panel:addChild(skill)
        skill:setPosition(cc.p(210+(i-1)*150,100))
    end
end

function CheckAllPanel:createSkillItem(config,is_lock, index)
    if not config then return end
    local con = ccui.Widget:create()
    local size = cc.size(117,117)
    con:setContentSize(size)
    con:setTouchEnabled(true)
    con:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            TipsManager:getInstance():showSkillTips(config)
        end
    end)

    --背景
    local res = PathTool.getNormalSkillBg()
    local bg = createImage(con, res,  size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
    bg:setContentSize(size)
    
    local res = PathTool.getSkillRes(config.icon)
    local icon = createImage(con, res,  size.width/2,size.height/2, cc.p(0.5,0.5), false, 0, false)

    if is_lock == true then
        local black_bg = ccui.Layout:create()
        black_bg:setContentSize(cc.size(size.width-10,size.height-10))
        con:addChild(black_bg)
        black_bg:setPosition(cc.p(size.width/2,size.height/2))
        black_bg:setAnchorPoint(cc.p(0.5,0.5))
        showLayoutRect(black_bg,80)

        local res = PathTool.getResFrame("pokedex","pokedex_29")
        local lock_icon = createImage(con, res,  size.width/2,size.height/2+5, cc.p(0.5,0.5), true, 0, false)

        local label_bg = ccui.Layout:create()
        label_bg:setContentSize(cc.size(100,29))
        con:addChild(label_bg)
        label_bg:setPosition(cc.p(size.width/2,22))
        label_bg:setAnchorPoint(cc.p(0.5,0.5))
        
        showLayoutRect(label_bg,120)

        local label = createLabel(24,1,9,size.width/2,6,"",con,2, cc.p(0.5,0))
        local cost_config = nil
        if index == 2 then
            cost_config = Config.PartnerData.data_partner_const.skill_unlock
        else
            cost_config = Config.PartnerData.data_partner_const.skill_unlock_2
        end
        if cost_config then
            label:setString(string.format(TI18N("突破%s解锁"), cost_config.val))
        end
    end

    --类型
    local index = 1
    local is_multi = config.target_multi or 0
    if is_multi == 1 then 
        index =3
    end
    local res = PathTool.getResFrame("pokedex","txt_cn_pokedex_"..index)
    local skill_type = createImage(con, res,  0,85, cc.p(0,0), true, 10, false)

    --名字
    local name = createLabel(26,Config.ColorData.data_color4[175],nil,size.width/2,-30,"",con,0, cc.p(0.5,0))
    name:setString(config.name)

    return con
end

function CheckAllPanel:createHeroSource()
    local size = cc.size(623,170)
    self.source_panel = ccui.Widget:create()
    self.source_panel:setContentSize(size)
    self.all_scroll:addChild(self.source_panel)
    -- self.max_height = self.max_height-size.height
    self.source_panel:setPosition(cc.p(self.scroll_width/2,self.max_height-size.height-30))
   
    local res = PathTool.getResFrame("common","common_90024")
    local bg = createImage(self.source_panel, res, size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
    bg:setContentSize(size)

    local res = PathTool.getResFrame("common","common_90025")
    local title_bg = createImage(self.source_panel, res, self.size.width/2,121, cc.p(0.5,0), true, 0, true)
    title_bg:setContentSize(cc.size(617,44))
    -- title_bg:setCapInsets(cc.rect(170, 22, 1, 1))
    local res = PathTool.getResFrame("pokedex","pokedex_1")
    local icon = createImage(self.source_panel, res, 15,125, cc.p(0,0), true, 1, false)
    local title = createLabel(26,Config.ColorData.data_color4[175],nil,75,128,"",self.source_panel,0, cc.p(0,0))
    title:setString(TI18N("来源途径"))

    local source=  self.data.source or {}

    for i,v in pairs(source) do

        local source_config = Config.SourceData.data_source_data[v]
        if source_config then
            local str = source_config.name or ""
            local res = PathTool.getResFrame("","common_1018")
            local btn = createButton(self.source_panel, str, 100+(i-1)*170, 60, cc.size(160,64), res, 26, Config.ColorData.data_color4[1])
            btn:enableOutline(cc.c4b(0x47, 0x84, 0x25, 0xff),2)
            btn:addTouchEventListener(function(sender, event_type) 
                if event_type == ccui.TouchEventType.ended then
                    TipsController:getInstance():clickSourceBtn(source_config)
                end
            end)
        
        end
    end
end

function CheckAllPanel:DeleteMe()
	self:removeAllChildren()
    self:removeFromParent()
end