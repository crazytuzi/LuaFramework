-- --------------------------------------------------------------------
-- 竖版神器信息面板
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ArtifactMessagePanel = class("ArtifactMessagePanel", function()
    return ccui.Widget:create()
end)

function ArtifactMessagePanel:ctor(parent)  
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function ArtifactMessagePanel:config()
    self.ctrl = HeroController:getInstance()
    self.size = cc.size(440,400)
    self:setContentSize(self.size)
    self.skill_list = {}
end
function ArtifactMessagePanel:layoutUI()

    local csbPath = PathTool.getTargetCSB("hero/artifact_message_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.top_panel = self.root_wnd:getChildByName("top_panel")
    self.bottom_panel = self.root_wnd:getChildByName("bottom_panel")
    self.label_panel = ccui.Widget:create()
    self.label_panel:setContentSize(self.size)
    self.label_panel:setAnchorPoint(cc.p(0.5,0.5))
    self.label_panel:setPosition(cc.p(self.size.width/2,self.size.height/2))
    self.root_wnd:addChild(self.label_panel)


    self.artifact_item = BackPackItem.new(true,true,nil,0.9)
    self.top_panel:addChild(self.artifact_item)
    self.artifact_item:setPosition(cc.p(66,58))

    self.name = self.top_panel:getChildByName("name")

    self.score =  self.top_panel:getChildByName("score")
    self.artifact_type = self.top_panel:getChildByName("type")
   
    -- self.desc_label = createRichLabel(24, Config.ColorData.data_color4[1], cc.p(0,0), cc.p(30,40), 0, 0, 400)
    -- self.label_panel:addChild(self.desc_label)
end


function ArtifactMessagePanel:setData(data)
    if not data then return end
    self.data = data

    local config = data.config

    if not config then return end
    self.artifact_item:setData(data)

    self.name:setString(config.name)
    local score = 0
    local const_config  =Config.PartnerArtifactData.data_artifact_const
    for key,value in pairs(data.extra) do
        if value and value.extra_k and value.extra_k <=2 then
            local skill_config = Config.SkillData.data_get_skill(value.extra_v)
            if skill_config then
                local skill_lev = skill_config.level or 1
                if const_config["skill_score_"..skill_lev] and const_config["skill_score_"..skill_lev].val then 
                    score = score + const_config["skill_score_"..skill_lev].val
                end
            end
        end
    end
    self.score:setString(TI18N("评分：")..score)

    local str = TI18N("副符文")
    if config.quality == 4 then 
        str = TI18N("主符文")
    end
    self.artifact_type:setString(TI18N("类型：")..str)

    self:updateSkillList()

    -- local desc = config.desc or ""
    -- self.desc_label:setString(desc)
end

function ArtifactMessagePanel:updateSkillList()
    if not self.data then return end
    local skill_list = self.data.extra or {}

    for key,value in pairs(skill_list) do
        if value and value.extra_k and value.extra_k <=2 then
            if not self.skill_list[key] then
                local item = self:createSkillItem(key)
                self.skill_list[key] = item
            end
            local skill_item = self.skill_list[key]
            local config = Config.SkillData.data_get_skill(value.extra_v)
            if config then
                skill_item.skill:setData(config)
                skill_item.name:setString(config.name)
                skill_item.desc:setString(config.des)
            end
        end
    end
end
function ArtifactMessagePanel:createSkillItem(index)
    local item = {}
    local skill = SkillItem.new(true,true,true,0.8)
    self.bottom_panel:addChild(skill)
    skill:setPosition(cc.p(75,205-(index-1)*135))
    local name = createLabel(22,cc.c4b(0xa8,0x38,0xbc,0xff),nil,135,227-(index-1)*135,"",self.bottom_panel,1,cc.p(0,0))

    local desc = createRichLabel(22,cc.c4b(0x68,0x45,0x2a,0xff),cc.p(0,1),cc.p(135,222-(index-1)*135),nil,nil,300)
    self.bottom_panel:addChild(desc)

    item.skill = skill
    item.name = name
    item.desc = desc

    return item
end
--事件
function ArtifactMessagePanel:registerEvents()
   
end

function ArtifactMessagePanel:setVisibleStatus(bool)
    self:setVisible(bool)
end



function ArtifactMessagePanel:DeleteMe()
    if self.artifact_item then 
        self.artifact_item:DeleteMe()
        self.artifact_item = nil
    end
    for i,v in pairs(self.skill_list) do 
        if v.skill then 
            v.skill:DeleteMe()
        end
    end

    self.skill_list = nil
end



