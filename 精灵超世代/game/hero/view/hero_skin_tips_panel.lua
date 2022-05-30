-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      皮肤 --后端锋林  策划 小琴
-- <br/>Create: 2019年5月10日
-- --------------------------------------------------------------------
HeroSkinTipsPanel = HeroSkinTipsPanel or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local role_vo = RoleController:getInstance():getRoleVo()

local backpack_controller = BackpackController:getInstance()

function HeroSkinTipsPanel:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "hero/hero_skin_tips_panel"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.win_type = WinType.Tips  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 

    --属性item
    self.attr_item_list = {}
end

function HeroSkinTipsPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
        self.background:setSwallowTouches(false)
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.main_panel_size = self.main_panel:getContentSize()
    self.bg = self.main_panel:getChildByName("bg")
    self.bg_size = self.bg:getContentSize()
    self.container = self.main_panel:getChildByName("container")
    self.station_img = self.container:getChildByName("station_img")
    self.model_nodel = self.container:getChildByName("model_nodel")

    --属性
    self.attr_panel = self.container:getChildByName("attr_panel")
    self.attr_panel:getChildByName("label"):setString(TI18N("特殊属性"))

    self.name = self.container:getChildByName("name")
    self.close_btn = self.container:getChildByName("close_btn")


    self.scroll_view = self.container:getChildByName("scroll_view")
    self.scroll_view_y = self.scroll_view:getPositionY()
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_size = self.scroll_view:getContentSize()
    self.desc_label = createRichLabel(22, cc.c4b(0xe0,0xbf,0x98,0xff), cc.p(0, 1), cc.p(20, 64), 8, nil, 460) 
    self.scroll_view:addChild(self.desc_label)


    -- 按钮部分
    self.btn_list = {}
    self.tab_panel = self.container:getChildByName("tab_panel")
    self.tab_panel_y = self.tab_panel:getPositionY()
    self.tab_panel_height = self.tab_panel:getContentSize().height
    for i=1, 3 do
        local btn = self.tab_panel:getChildByName("tab_btn_"..i)
        if btn then
            local object = {}
            object.btn = btn
            object.label = btn:getTitleRenderer()
            self.btn_list[i] = object
        end
    end
end

function HeroSkinTipsPanel:register_event()
    registerButtonEventListener(self.close_btn, function() self:onClickCloseBtn() end ,true, 1) 
    registerButtonEventListener(self.background, function() self:onClickCloseBtn() end ,false, 0) 
end

--关闭
function HeroSkinTipsPanel:onClickCloseBtn()
    controller:openHeroSkinTipsPanel(false)
end


function HeroSkinTipsPanel:onTabBtn2()
    if not self.data then return end
    if not self.item_config then return end

end

--卸下和出售
function HeroSkinTipsPanel:onTabBtn1()
    if not self.data or not self.data.id or not self.item_config then return end

end
--穿戴和更换
function HeroSkinTipsPanel:onTabBtn3()
    if not self.data then return end
    if not self.item_config then return end
   
end

function HeroSkinTipsPanel:openRootWnd(data, cloth_type, partner)
    self.cloth_type = cloth_type or PartnerConst.EqmTips.normal
    self.data = data
    self.partner = partner
    if self.partner then
        self.partner_id = self.partner.partner_id
    end

    -- 因为传参不同,这边需要获取不同的配置数据
    local item_config = nil
    if type(data) == "number" then
        item_config = Config.ItemData.data_get_data(data)
    else
        if data.config then
            item_config = data.config
        else
            item_config = data
        end
    end
    self.item_config = item_config
    if self.item_config == nil then return end

    self:initData()

    if self.cloth_type == PartnerConst.EqmTips.backpack then
        self:updateBtnList()
    end
end

--==============================--
--desc:设置按钮显示
--time:2018-10-22 10:29:52
--@return 
--==============================--
function HeroSkinTipsPanel:updateBtnList()
    --按钮
    if not self.item_config then return end

    for k, object in pairs(self.btn_list) do
        if object.btn then
            object.btn:setVisible(false)
        end
    end

    local tips_btn = self.item_config.tips_btn or {}

    local btn_sum = tableLen(tips_btn)
    if btn_sum == 1 then        -- 如果只有1个按钮,按钮1移到按钮3的位置
        local object_1 = self.btn_list[1]
        local object_3 = self.btn_list[3] 
        if object_1.btn and object_3.btn then
            object_1.btn:setPositionX(object_3.btn:getPositionX())
        end
    end

    local index = 1
    for i, v in ipairs(tips_btn) do
        if index > 3 then break end
        local object = self.btn_list[i]
        if object and object.btn then
            local title = BackPackConst.tips_btn_title[v] or ""
            object.label:setString(title)
            object.btn:setVisible(true)
            object.btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    self:clickBtn(v)
                end
            end)
        end
        index = index + 1
    end
end 

function HeroSkinTipsPanel:clickBtn(index)
    if not self.item_config then return end
    if not self.skin_id then return end
    if index == BackPackConst.tips_btn_type.source then --来源
        if #self.item_config.source > 0 then
            backpack_controller:openTipsSource(true,self.data)
        else
            message(TI18N("暂时没有来源"))
        end
    elseif index == BackPackConst.tips_btn_type.goods_use then --普通物品使用
        local time = model:getHeroSkinInfoBySkinID(self.skin_id)
        if time ~= nil and time == 0 then
            --说明拥有该皮肤 并且是永久的
            local skin_info = Config.PartnerSkinData.data_skin_info
            if skin_info and skin_info[self.skin_id] then
                if self.item_config.client_effect[1] then
                    local item_id = self.item_config.client_effect[1][3] or Config.ItemData.data_assets_label2id.skin_debris
                    local item_config = Config.ItemData.data_get_data(item_id)
                    local icon_src = PathTool.getItemRes(item_config.icon)
                    local count = self.item_config.client_effect[1][4] or 0
                    local str = string_format(TI18N("当前您已永久拥有该皮肤，重复激活使用，将转化为 <img src='%s' scale=0.3 /><div fontcolor=#289b14> %s </div>，是否继续使用？"),icon_src, count)
                    local callback = function()
                        backpack_controller:sender10515(self.data.id or 0,1)
                    end
                    CommonAlert.show(str, TI18N("使用"), callback, TI18N("取消"),nil, CommonAlert.type.rich, nil, {title = TI18N("使用皮肤")}) 
                end
            end
        else
            backpack_controller:sender10515(self.data.id or 0,1)
        end
    end

    self:onClickCloseBtn()
end



function HeroSkinTipsPanel:initData()
    self.name:setString(self.item_config.name)
    --站台
    local station_res = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_skin_tips", false)
    if self.record_station_res == nil or self.record_station_res ~= station_res then
        self.record_station_res = station_res
        self.item_load = loadSpriteTextureFromCDN(self.station_img, station_res, ResourcesType.single, self.item_load) 
    end
    local skin_id = 101 
    if self.item_config.client_effect[1] then
        skin_id = self.item_config.client_effect[1][1] or 101
    end
    self.skin_id = skin_id
    self:updateSpine(skin_id)

    local reduce_height = self:updateAttrInfo(skin_id)

    -- 描述
    self.desc_label:setString(self.item_config.desc)
    local label_siez = self.desc_label:getContentSize()
    local max_height = math.max(label_siez.height, self.scroll_size.height)
    self.scroll_view:setInnerContainerSize(cc.size(self.scroll_size.width, max_height))
    self.desc_label:setPositionY(max_height-10)

    local height
    if self.cloth_type == PartnerConst.EqmTips.normal then
        -- 普通不显示按钮
        self.tab_panel:setVisible(false)
        height = self.main_panel_size.height - (reduce_height + 54)
        self.container:setPositionY(height + (reduce_height + 54) * 0.5)
    else
        self.tab_panel:setVisible(true)
        height = self.main_panel_size.height - reduce_height
        self.container:setPositionY(height + reduce_height  * 0.5)
    end

    self.scroll_view:setPositionY(self.scroll_view_y + reduce_height)
    self.tab_panel:setPositionY(self.tab_panel_y + reduce_height)

    self.bg:setContentSize(cc.size(self.main_panel_size.width, height))
    self.main_panel:setContentSize(cc.size(self.main_panel_size.width, height))
end


--更新模型,也是初始化模型
--@is_refresh  是否需要检测
function HeroSkinTipsPanel:updateSpine(skin_id)
    if self.record_spine_skin_id and self.record_spine_skin_id == skin_id then
        return
    end
    self.record_spine_skin_id = skin_id

    local fun = function()    
        if not self.spine then
            self.spine = BaseRole.new(BaseRole.type.skin, skin_id, nil, {})
            self.spine:setAnimation(0,PlayerAction.show,true) 
            self.spine:setCascade(true)
            self.spine:setPosition(cc.p(0,166))
            self.spine:setAnchorPoint(cc.p(0.5,0.5)) 
            -- self.spine:setScale(1)
            self.model_nodel:addChild(self.spine) 
            self.spine:setCascade(true)
            self.spine:setOpacity(0)
            self.spine:showShadowUI(true)
            local action = cc.FadeIn:create(0.2)
            self.spine:runAction(action)
        end
    end
    if self.spine then
        self.can_click_btn = false
        self.spine:setCascade(true)
        local action = cc.FadeOut:create(0.2)
        self.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                doStopAllActions(self.spine)
                self.spine:removeFromParent()
                self.spine = nil
                self.can_click_btn = true
                fun()
        end)))
    else
        fun()
    end
end

function HeroSkinTipsPanel:updateAttrInfo(skin_id)
    local skin_config = Config.PartnerSkinData.data_skin_info[skin_id]
    --减少的高度
    local reduce_height = 0
    if skin_config then
        local item_height = 40
        local size  = self.attr_panel:getContentSize()
        local x1 = size.width * 0.25
        local x2 = size.width * 0.75
-- skin_config.skin_attr = {{'atk',10},{'atk_per',10},{'atk_per',10}}
        if #skin_config.skin_attr <= 2 then
            reduce_height = 40
        end
        
        for i , v in ipairs(skin_config.skin_attr) do
            local row = math.floor((i-1)/2)
            local col = (i - 1) % 2
            local _x = 0
            local _y = size.height - (item_height * 0.5 + row * item_height)
            if col == 0 then
                _x = x1
            else
                _x = x2
            end
            if self.attr_item_list[i] == nil then
                self.attr_item_list[i] = self:createAttrItem(_x, _y)
            else
                self.attr_item_list[i].bg:setVisible(true)
                self.attr_item_list[i].key_label:setVisible(true)
            end
             local res, attr_name, attr_val = commonGetAttrInfoByKeyValue(v[1], v[2])
            local attr_str = string.format("<img src='%s' scale=1 /> %s + %s", res, attr_name, attr_val)
            self.attr_item_list[i].key_label:setString(attr_str)
        end
    end
    return reduce_height
end

--创建属性item
function HeroSkinTipsPanel:createAttrItem(x, y)
    local item = {}
    local size = cc.size(230, 35)
    local res = PathTool.getResFrame("common","common_90058")
    item.bg = createImage(self.attr_panel, res, x,y, cc.p(0.5, 0.5), true, 0, true)
    item.bg:setContentSize(size)
    item.bg:setOpacity(128)
    item.bg:setCapInsets(cc.rect(15, 15, 1, 1))
    item.key_label = createRichLabel(22, cc.c4b(0xe0,0xbf,0x98,0xff), cc.p(0, 0.5), cc.p(x - size.width * 0.5 + 10  , y), nil, nil, 380)
    self.attr_panel:addChild(item.key_label, 2)
    return item
end


function HeroSkinTipsPanel:close_callback()
    if self.spine then
        doStopAllActions(self.spine)
        self.spine:removeFromParent()
        self.spine = nil
    end

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    controller:openHeroSkinTipsPanel(false)
end
