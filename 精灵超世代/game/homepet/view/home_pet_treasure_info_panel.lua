--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年7月4日
-- @description    : 
        -- 萌宠珍品tips
---------------------------------
HomePetTreasureInfoPanel = HomePetTreasureInfoPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()
local model = controller:getModel()

function HomePetTreasureInfoPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
    }
    self.layout_name = "homepet/home_pet_treasure_info_panel"
end

function HomePetTreasureInfoPanel:open_callback(  )
      self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 

    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("物品名字"))

    self.icon = self.main_container:getChildByName("icon")
    self.name = self.main_container:getChildByName("name")

    self.item_scrollview = self.main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)
    self.item_scrollview_size = self.item_scrollview:getContentSize()
    self.item_scrollview_container = self.item_scrollview:getInnerContainer() 

    self.desc = createRichLabel(26, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,1), cc.p(100,0), 8, nil, 310)
    self.item_scrollview:addChild(self.desc)
end

function HomePetTreasureInfoPanel:register_event(  )
    registerButtonEventListener(self.background, function() controller:openHomePetTreasureInfoPanel(false) end,false, 2)
    registerButtonEventListener(self.close_btn, function() controller:openHomePetTreasureInfoPanel(false) end ,true, 2)
end

function HomePetTreasureInfoPanel:openRootWnd(setting)

    self.dic_have_treasure_id = model.dic_have_treasure_id or {}

    local setting = setting or {}
    self.item_config = setting.item_config or Config.ItemData.data_get_data(100004)
    if not self.item_config then return end
    self.title:setString(self.item_config.name)
    self.name:setString(self.item_config.use_desc)

    local head_icon 
    if self.dic_have_treasure_id[self.item_config.id] then
        --拥有
        head_icon = PathTool.getItemRes(self.item_config.icon, false)
    else
        --未拥有
        head_icon = PathTool.getTargetRes("homepet_item", self.item_config.icon,false,false)
    end

    if self.record_head_icon == nil or self.record_head_icon ~= head_icon then
        self.record_head_icon = head_icon
        loadSpriteTexture(self.icon, head_icon, LOADTEXT_TYPE)
    end

    self.desc:setString(self.item_config.desc)
    local size = self.desc:getContentSize()
    local max_height = math.max(self.item_scrollview_size.height, (size.height + 4))
    self.item_scrollview:setInnerContainerSize(cc.size(self.item_scrollview_size.width,max_height))
    self.desc:setPosition(5, max_height - 2 )

    if max_height == self.item_scrollview_size.height then
        self.item_scrollview:setTouchEnabled(false)
    else
        self.item_scrollview:setTouchEnabled(true)
    end
end


function HomePetTreasureInfoPanel:close_callback()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self.item_list = {}

    controller:openHomePetTreasureInfoPanel(false)
end