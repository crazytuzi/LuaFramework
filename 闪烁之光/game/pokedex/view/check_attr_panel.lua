-- --------------------------------------------------------------------
-- 图鉴伙伴查看总览
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

CheckAttrPanel = class("CheckAttrPanel", function() 
	return ccui.Layout:create()
end)



function CheckAttrPanel:ctor(data)
    self.data = data

    self.base_attr = {}
    self.other_attr = {}
    
    self.size = cc.size(645,420)
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
    self:setPosition(cc.p(self.size.width/2,self.size.height/2-10))
    --基础属性
    self:createAttrPanel()
    --其他属性
    self:createOtherAttr()
    self:updateAttrList()
	self:registerEvent()
end
function CheckAttrPanel:registerEvent()
    -- body
end

function CheckAttrPanel:createAttrPanel()
    local size = cc.size(623,426)
    self.attr_panel = ccui.Widget:create()
    self.attr_panel:setContentSize(size)
    self:addChild(self.attr_panel)
    self.attr_panel:setPosition(cc.p(self.size.width/2,230))
    local res = PathTool.getResFrame("common","common_90024")
    local bg = createImage(self.attr_panel, res, size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
    bg:setContentSize(size)

    local res = PathTool.getResFrame("common","common_90025")
    local title_bg = createImage(self.attr_panel, res,  size.width/2,378, cc.p(0.5,0), true, 0, true)
    title_bg:setContentSize(cc.size(617,44))
    -- title_bg:setCapInsets(cc.rect(170, 22, 1, 1))
    local res = PathTool.getResFrame("pokedex","pokedex_3")
    local icon = createImage(self.attr_panel, res, 15,375, cc.p(0,0), true, 1, false)
    local title = createLabel(26,Config.ColorData.data_color4[175],nil,75,385,"",self.attr_panel,0, cc.p(0,0))
    title:setString(TI18N("基础属性"))
end

function CheckAttrPanel:createOtherAttr()
    local size = self.attr_panel:getContentSize()
    local res = PathTool.getResFrame("common","common_90025")
    local title_bg = createImage(self.attr_panel, res,  size.width/2,150, cc.p(0.5,0), true, 0, true)
    title_bg:setContentSize(cc.size(617,44))
    -- title_bg:setCapInsets(cc.rect(170, 22, 1, 1))
    local res = PathTool.getResFrame("pokedex","pokedex_4")
    local icon = createImage(self.attr_panel, res, 15,147, cc.p(0,0), true, 1, false)
    local title = createLabel(26,Config.ColorData.data_color4[175],nil,75,157,"",self.attr_panel,0, cc.p(0,0))
    title:setString(TI18N("其他属性"))
end



function CheckAttrPanel:updateAttrList()
    local data = self.data 
    if not data then return end
    local attr_config = Config.PartnerData.data_partner_attr[data.bid]
    if not attr_config then return end
    local base_list = {[1]="hp_max",[2]="add_hp",[3]="atk",[4]="add_atk",[5]="def",[6]="add_def",[7]="speed"}
    local name_list = {[1]=TI18N("生命成长"),[2]=TI18N("攻击成长"),[3]=TI18N("防御成长"),}
    local icon_list = {[1]="22",[2]="37",[3]="21",[4]="37",[5]="23",[6]="37",[7]="38",}
    for i=1,7 do 
        local attr_name = base_list[i]
        local name = Config.AttrData.data_key_to_name[attr_name] or ""
        local value = attr_config[attr_name] or 0
        local res = icon_list[i]
        local is_show_line = false
        if i%2 ==0 then 
            name = name_list[math.ceil(i/2)]
            value = (math.ceil(value/10))/100
            is_show_line = true
        end
        if not self.base_attr[i] then 
            local offx =40+((i-1)%2)*300
            local offy = 370-(math.ceil(i/2)*38)
            local item = self:createOneAttr(cc.p(offx,offy),name,value,res,is_show_line)
            self.base_attr[i] = item
        end
    end

    local other_list = {[1]="crit_rate",[2]="crit_ratio",[3]="hit_magic",[4]="dodge_magic"}
    local icon_list = {[1]="39",[2]="43",[3]="40",[4]="42"}
    for i=1,4 do 
        local attr_name = other_list[i]
        local name = Config.AttrData.data_key_to_name[attr_name] or ""
        local value = attr_config[attr_name]/10 or 0
        local str = value.."%"
        local is_show_line = false
        if i%2 ==0 then 
            is_show_line = true 
        end
        if not self.other_attr[i] then 
            local offx =40+((i-1)%2)*300
            local offy = 150-(math.ceil(i/2)*40)
            local res = icon_list[i]
            local item = self:createOneAttr(cc.p(offx,offy),name,str,res,is_show_line)
            self.other_attr[i] = item
        end
    end
end
function CheckAttrPanel:createOneAttr(pos,name,value,icon_ress,is_show_line)

    if is_show_line then
        local res = PathTool.getResFrame("common","common_1016")
        local line =  createImage(self.attr_panel, res,pos.x-20,pos.y-5, cc.p(0.5,0), true, 0, true)
        line:setContentSize(cc.size(570,2))
    end

     local icon_res = PathTool.getResFrame("common","common_900"..icon_ress)
    local icon =  createImage(self.attr_panel, icon_res,pos.x,pos.y, cc.p(0,0), true, 0, false)
    local label1 =  createLabel(24,Config.ColorData.data_color4[175],nil,0,0,name,self.attr_panel,2, cc.p(0,0))
    label1:setPosition(cc.p(pos.x+30,pos.y))
    local label2 =  createLabel(24,Config.ColorData.data_color4[175],nil,0,0,value,self.attr_panel,2, cc.p(0,0))
    label2:setPosition(cc.p(pos.x+160,pos.y))
    return {name_label =label1,value_label =label2,icon=icon}
end
function CheckAttrPanel:DeleteMe()
	self:removeAllChildren()
    self:removeFromParent()
end
