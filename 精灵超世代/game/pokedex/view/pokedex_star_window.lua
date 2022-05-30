-- --------------------------------------------------------------------
-- 图鉴星数等级提升展示面板
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
PokedexStarWindow = PokedexStarWindow or BaseClass(BaseView)

function PokedexStarWindow:__init( data)
    self.ctrl = PokedexController:getInstance()
    self.win_type = WinType.Mini
    self.layout_name = "hero/partner_star_up_window"
    self.title = TI18N("星数提升") or ""
    self.view_tag = ViewMgrTag.MSG_TAG
    self.attr_list ={}
    self.effect_cache_list = {}
    self.res_list = {
       
    }
    
    self.data = data
end

function PokedexStarWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.back_panel = self.main_container:getChildByName("back_panel")
    self.back_panel:setScale(display.getMaxScale())

    self.title_container = self.main_container:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    local res = PathTool.getResFrame("common","common_90011")
    local icon = createImage(self.main_container, res,245,350, cc.p(0.5,0), true, 0, false)
    icon:setScale(0.7)

    local res = PathTool.getResFrame("common", "common_90011")
    local icon_2 = createImage(self.main_container, res,430,350, cc.p(0.5, 0), true, 0, false)
    icon_2:setScale(0.7)

    self.old_star_label = createLabel(26,Config.ColorData.data_color4[1],nil,275,355,"",self.main_container,2, cc.p(0.5,0))
    self.new_star_label = createLabel(26,Config.ColorData.data_color4[1],nil,455,355,"",self.main_container,2, cc.p(0,0))
   
    local res = PathTool.getResFrame("common","common_30014")
    local arrow =  createImage(self.main_container, res,310,343, cc.p(0,0), true, 0, false)
  
    self.main_container:getChildByName("notice_label"):setString(TI18N("点击任意处关闭"))

    self:updateAttrList()
end

function PokedexStarWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            self.ctrl:openStarUpWindow(false)
        end
    end)
end

function PokedexStarWindow:openRootWnd()
    self:handleEffect(true)
end

function PokedexStarWindow:onEnterAnim()
end
--更新属性
function PokedexStarWindow:updateAttrList()
    if not self.data then return end
    local star_1 = self.data.old_star or 0
    local star_2 = self.data.new_star or 0
 
    local old_lev = math.max(0,self.data.old_lev)
    local old_config =  Config.PartnerData.data_pokedex_attr[old_lev]
    local next_lev = math.min(self.data.cur_lev, tableLen(Config.PartnerData.data_pokedex_attr))
    local new_config =  Config.PartnerData.data_pokedex_attr[next_lev]
    local config = Config.PartnerData.data_pokedex_attr
    local old_star = 0
    if old_config then
        old_star = old_config.star
    end
    self.old_star_label:setString(old_star)
    self.new_star_label:setString(new_config.star)

    -- local min_star = -1
    -- for i,v in pairs(config) do
    --     if v.star <=star_1 and v.next_star > star_1 then 
    --         old_config = v
    --         if v.next_star ~= 0 then
    --             new_config =  Config.PartnerData.data_pokedex_attr[v.next_star]
    --         end
    --         break
    --     end
    --     if min_star <0 then 
    --         min_star = v.star
    --     else
    --         min_star = math.min(min_star,v.star)
    --     end
    -- end

    if not old_config and not new_config then 
        old_config = {}
        --new_config =  Config.PartnerData.data_pokedex_attr[self.data.cur_lev]
    end

    if not new_config then return end
    -- if not old_config then return end
    local old_attr = {}
    if old_config then
        old_attr = old_config.attr or {}
    end
    local new_attr = new_config.attr or {}
    local list = {[1]=TI18N("生命："),[2]=TI18N("攻击："),[3]=TI18N("防御："),}
    local attr_list = {[1] = "hp_max", [2] = "atk", [3] = "def"}
    local value_list = {}
    if old_attr then
        for i, v in pairs(old_attr) do
            if v and v[1] and v[2] then
                value_list[v[1]] = v[2]
            end
        end
    end
    local new_value_list = {}
    if new_attr then
        for i, v in pairs(new_attr) do
            if v and v[1] and v[2] then
                new_value_list[v[1]] = v[2]
            end
        end
    end

    for i=1, 3 do 
        if not self.attr_list[i] then 
            self.attr_list[i] = {}

            local res = PathTool.getResFrame("common","common_90044")
            local bg = createImage(self.main_container, res,20,230-(i-1)*50, cc.p(0,0), true, 0, true)
            bg:setContentSize(cc.size(675,43))
            if i ~=1 then
                bg:setOpacity(160)
            end
            local now_label =createRichLabel(22, cc.c4b(0xff,0xee,0xac,0xff), cc.p(0,0), cc.p(195,290-i*50), 0, 0, 400)
            self.main_container:addChild(now_label) 
            local next_label = createRichLabel(22, cc.c4b(0x35,0xff,0x14,0xff), cc.p(0,0), cc.p(430,290-i*50), 0, 0, 400)
            self.main_container:addChild(next_label) 
            local res = PathTool.getResFrame("common","common_90017")
            local arrow =  createImage(self.main_container, res,330,240-(i-1)*50, cc.p(0,0), true, 0, false)
            self.attr_list[i].now_label = now_label
            self.attr_list[i].next_label = next_label
            self.attr_list[i].arrow = arrow
        end

        local name = list[i] or ""
        local value =0

        local attr_str = attr_list[i]
        if attr_str and value_list[attr_str] then
            value = value_list[attr_str] or 0
        end
        local str = name..value

        self.attr_list[i].now_label:setString(str)
        local next_value = 0
        -- if new_attr[attr_list[i]] and new_attr[attr_list[i]][2] then
        --     next_value = new_attr[attr_list[i]][2] or 0
        -- end
        local attr_str = attr_list[i]
        if attr_str and new_value_list[attr_str] then
            next_value = new_value_list[attr_str] or 0
        end

        
        self.attr_list[i].next_label:setString(next_value)
        self.attr_list[i].next_label:setVisible(true)
        self.attr_list[i].arrow:setVisible(true)
    end
end


function PokedexStarWindow:handleEffect(status,index)    
    if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
    else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[103],  cc.p(self.title_width*0.5, self.title_height*0.5), cc.p(0.5, 0.5), false, PlayerAction.action_7)
            self.title_container:addChild(self.play_effect)
        end
    end
end

function PokedexStarWindow:close_callback()
    self.ctrl:openStarUpWindow(false)
    self:handleEffect(false)

end
