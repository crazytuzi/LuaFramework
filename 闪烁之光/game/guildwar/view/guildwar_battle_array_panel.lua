--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-19 17:37:30
-- @description    : 
		-- 阵容
---------------------------------
GuildwarBattleArrayPanel = class("GuildwarBattleArrayPanel", function()
    return ccui.Widget:create()
end)

local controller = GuildwarController:getInstance()
local model = controller:getModel()

function GuildwarBattleArrayPanel:ctor( )
    self.hero_item_list = {}
    
	self:configUI()
	self:register_event()
end

function GuildwarBattleArrayPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildwar/guildwar_battle_array_panel"))
	self.root_wnd:setPosition(0,0)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.bg_image = container:getChildByName("image_1")
    self.titile_bg = container:getChildByName("titile_bg")

    local title_label = container:getChildByName("title_label")
    title_label:setString(TI18N("对方阵容"))

    self.form_image = container:getChildByName("form_image")
    self.form_label = container:getChildByName("form_label")
    self.scrollCon = container:getChildByName("scrollCon")

    local image = container:getChildByName("image_2")
    local image_size = image:getContentSize()
    self.power = CommonNum.new(20, image, 0, 1, cc.p(0.5, 0.5))
    self.power:setPosition(image_size.width/2, image_size.height-7)

    local scrollCon_size = self.scrollCon:getContentSize()
    self.scroll_view_size = cc.size(scrollCon_size.width - 10, scrollCon_size.height)
    self.scroll_view = createScrollView(self.scroll_view_size.width,self.scroll_view_size.height,8,0,self.scrollCon,ccui.ScrollViewDir.horizontal)
end

--[[
	data.partner_list = {}
	data.rid
	data.srv_id
	data.power
	data.formation_type
	data.formation_lev
]]
function GuildwarBattleArrayPanel:setData( data, is_spec )
	data = data or {}

    self.power:setNum(data.power or 0)

	local temp_partner_vo = {}
	for k,v in pairs(data.partner_list) do
		local vo = HeroVo.New()
		vo:updateHeroVo(v)
		table.insert(temp_partner_vo,vo)
	end

	local p_list_size = #temp_partner_vo
    local scale = 0.87
    local total_width = p_list_size * HeroExhibitionItem.Width*scale + (p_list_size - 1) * 6
    local start_x = 0
    local max_width = math.max(total_width,self.scroll_view_size.width) 
    self.scroll_view:setInnerContainerSize(cc.size(max_width,self.scroll_view_size.height))

    for i,v in ipairs(temp_partner_vo) do
        local partner_item = HeroExhibitionItem.new(scale, false)
        partner_item:setPosition(start_x+HeroExhibitionItem.Width*scale*0.5+(i-1)*(HeroExhibitionItem.Width*scale+6), self.scroll_view_size.height*0.5)
        partner_item:setData(v,nil,is_spec)
        if v.rare_type and v.rare_type > 0 then
            partner_item:showRareType(v.rare_type)
        end
        table.insert(self.hero_item_list, partner_item)
        self.scroll_view:addChild(partner_item)
        --[[if data.rid and data.srv_id then
            partner_item:addCallBack(function(item)
                local vo = item:getData()
                if vo and next(vo) ~=nil then 
                    local partner_id = vo.partner_id
                    local rid = data.rid
                    local srv_id = data.srv_id
                    LookController:getInstance():sender11061(rid,srv_id,partner_id)
                end
            end)
        end--]]
    end

    if data.formation_type then
        local form_data = Config.FormationData.data_form_data[data.formation_type]
        if form_data then
            local form_lv = data.formation_lev or 1
            --self.form_label:setString(string.format("%s Lv.%d", form_data.name, form_lv))
            self.form_label:setString(form_data.name)
        end
        self.form_label:setVisible(true)
        self.form_image:setVisible(true)
        self.form_image:loadTexture(PathTool.getResFrame("form", "form_icon_"..data.formation_type), LOADTEXT_TYPE_PLIST)
    else
        self.form_label:setVisible(false)
        self.form_image:setVisible(false)
    end
end

function GuildwarBattleArrayPanel:setPanelContentSize( newsize )
    self:setContentSize(newsize)
    self.container:setContentSize(newsize)
    self.bg_image:setContentSize(newsize)
    self.titile_bg:setContentSize(cc.size(newsize.width-3, 44))
end

function GuildwarBattleArrayPanel:register_event(  )
end

function GuildwarBattleArrayPanel:DeleteMe(  )
    for k,v in pairs(self.hero_item_list) do
        v:DeleteMe()
    end
	if self.power then
        self.power:DeleteMe()
        self.power = nil
    end
end