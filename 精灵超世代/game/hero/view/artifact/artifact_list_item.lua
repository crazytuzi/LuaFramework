
-- --------------------------------------------------------------------
-- 竖版神器子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ArtifactListItem = class("ArtifactListItem", function()
	return ccui.Widget:create()
end)

function ArtifactListItem:ctor(index)
	self.width = 600
    self.height = 114
	self.ctrl = HeroController:getInstance()
	self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(self.width,self.height))
    self:setAnchorPoint(cc.p(0.5, 0))
    self.index = index or 1
    self.skill_list = {}
    self.attr_list = {}
	self:configUI()
    self:registerEvent()
end

function ArtifactListItem:clickHandler( ... )
	if self.call_fun then
   		self:call_fun(self.vo)
   	end
end
function ArtifactListItem:addCallBack( value )
	self.call_fun =  value
end
--[[
@功能:创建视图
@参数:
@返回值:
]]
function ArtifactListItem:configUI()
    local res = PathTool.getResFrame("common","common_2040")
    local bg = createScale9Sprite(res, self.width/2, self.height/2, LOADTEXT_TYPE_PLIST, self)
    bg:setCapInsets(cc.rect(132, 0, 1, 114))
    bg:setContentSize(cc.size(self.width,self.height))
    --头像
    self.artifact_item = BackPackItem.new(true,true,nil,0.8)
    self:addChild(self.artifact_item)
    self.artifact_item:setPosition(cc.p(80,56))

    --self.name = createLabel(24,Config.ColorData.data_color4[156],nil,155,85,"name",self,2, cc.p(0,0))

    self.reset_btn = createImage(self, PathTool.getResFrame("hero","txt_cn_hero_info_37"), 444, 55, cc.p(0.5, 0.5), true)
    self.equip_btn = createImage(self, PathTool.getResFrame("hero","txt_cn_hero_info_38"), 542, 55, cc.p(0.5, 0.5), true)
    self.desc_label = createLabel(18,Config.ColorData.data_new_color4[15],Config.ColorData.data_new_color4[6],35,5,TI18N("选择"),self.equip_btn)
    self.desc_label:setAnchorPoint(cc.p(0.5,0.5))

    self.reset_btn:setTouchEnabled(true)
    self.equip_btn:setTouchEnabled(true)

    self.reset_btn:setVisible(false)
end

function ArtifactListItem:registerEvent()
    self.equip_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender,event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:clickHandler()
        end
    end)
    self.reset_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender,event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.vo then
                self.ctrl:openArtifactRecastWindow(true,self.vo)
            end
        end
    end)
end

function ArtifactListItem:setExtendData(partner_id)
    self.partner_id = partner_id
end

--[[
@功能:设置数据
@参数:
@返回值:
]]
function ArtifactListItem:setData( data)
    if data == nil then return end
    self.vo = data
    self.artifact_item:setData(data)
    if not data.config then return end
    --local name =data.config.name or ""

    --self.name:setString(name)
    --local quality = data.config.quality or 1
    --self.name:setTextColor(BackPackConst.quality_color[quality])

    -- 伙伴那边触发后者是背包触发
    if self.partner_id and self.partner_id ~= 0 then
        --self.reset_btn:setVisible(true)
        self.equip_btn:loadTexture(PathTool.getResFrame("hero","txt_cn_hero_info_38"), LOADTEXT_TYPE_PLIST)
    else
        --self.reset_btn:setVisible(false)
        self.equip_btn:loadTexture(PathTool.getResFrame("hero","txt_cn_hero_info_38"), LOADTEXT_TYPE_PLIST)
    end

    -- 属性
    for i,v in pairs(self.attr_list) do
        v:setString("")
    end
    local attr_list = data.attr
    local attr_num = 2
    local artifact_config = Config.PartnerArtifactData.data_artifact_data[data.config.id]
    local attr_num = 2
    if artifact_config then
        attr_num = artifact_config.attr_num
    end
    for i,v in ipairs(attr_list) do
        if i > attr_num then break end
        local attr_id = v.attr_id
        local attr_key = Config.AttrData.data_id_to_key[attr_id]
        local attr_val = v.attr_val/1000
        local attr_name = Config.AttrData.data_key_to_name[attr_key]
        if attr_name then
            if not self.attr_list[i] then
                self.attr_list[i] = createRichLabel(24, Config.ColorData.data_new_color4[9], cc.p(0, 0.5), cc.p(20, 28), nil, nil, 380)
                self:addChild(self.attr_list[i])
            end
            local label = self.attr_list[i]
            label:setPosition(cc.p(155+(i-1)*170,80))

            local icon = PathTool.getAttrIconByStr(attr_key)
            local is_per = PartnerCalculate.isShowPerByStr(attr_key)
            if is_per == true then
                attr_val = (attr_val/10).."%"
            else
                attr_val = changeBtValueForHeroAttr(attr_val, attr_key)
            end
            local attr_str = string.format("<img src='%s' scale=1 /> <div fontcolor=#ba39da> %s:</div><div fontcolor=#ba39da>%s</div>", PathTool.getResFrame("common", icon), attr_name, attr_val)
            label:setString(attr_str)
        end
    end

    --技能
    for i,v in pairs(self.skill_list) do
        v:setString("")
    end
    local skill_list = data.extra or {}
    local index = 1
    local code = cc.Application:getInstance():getCurrentLanguageCode()
    for i,v in pairs(skill_list) do
        if v and v.extra_k and (v.extra_k == 1 or v.extra_k == 2 or v.extra_k == 8) then
            if not self.skill_list[index] then 
                local label = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0,0), cc.p(110,35), 0, 0, 500)
                self:addChild(label)
                self.skill_list[index] = label
            end
            local skill_id = v.extra_v or 0
            local config = Config.SkillData.data_get_skill(skill_id)
            local str = ""
            if config then 
                str = string.format("【<div href=xxx>%s</div>】",config.name)
            end
            if code == "zh" then
                self.skill_list[index]:setPosition(cc.p(140+(index-1)*130,20))
            else
                self.skill_list[index]:setPosition(cc.p(140,35-(index-1)*25))
            end
            self.skill_list[index]:setString(str)
            self.skill_list[index]:addTouchLinkListener(function(type, value, sender)
                TipsManager:getInstance():showSkillTips(config)
            end, {"click","href"})    
            index = index +1
        end
    end
end

function ArtifactListItem:isHaveData()
	if self.vo then
		return true
	end
	return false
end

function ArtifactListItem:suspendAllActions()
end

function ArtifactListItem:getData( )
	return self.vo
end
function ArtifactListItem:DeleteMe()
    if self.artifact_item then 
        self.artifact_item:DeleteMe()
        self.artifact_item = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
    self.vo =nil
end


