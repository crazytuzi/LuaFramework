--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年7月3日
-- @description    : 
        -- 萌宠收藏
---------------------------------
HomePetCollectionPanel = HomePetCollectionPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format

function HomePetCollectionPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("homepet_collection", "homepet_collection"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("homepet_eventinfo", "homepet_eventinfo"), type = ResourcesType.plist}
    }
    self.layout_name = "homepet/home_pet_collection_panel"

    --当前页数
    self.cur_page = 1
    --最大页数
    self.max_page = {}
    -- 当前选择的类型
    self.select_index =  HomepetConst.collection_tab_type.eTreasureType

    --珍品已获取记录
    self.dic_have_treasure_id = {}

    --选中的对象
    self.select_data = {}
end

function HomePetCollectionPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 

    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("收\n藏"))

    self.close_btn = self.main_container:getChildByName("close_btn")

    self.per_btn = self.main_container:getChildByName("per_btn")
    self.per_btn_lab = self.per_btn:getChildByName("label")
    self.per_btn_lab:setString(TI18N("上一页"))
    self.next_btn = self.main_container:getChildByName("next_btn")
    self.next_btn_lab = self.next_btn:getChildByName("label")
    self.next_btn_lab:setString(TI18N("下一页"))
    self.remove_btn = self.main_container:getChildByName("remove_btn")
    self.save_btn = self.main_container:getChildByName("save_btn")
    self.save_btn:setVisible(false)

    --页数信息
    self.page_label = self.main_container:getChildByName("page_label")

    self.tab_container = self.main_container:getChildByName("tab_container")

    self.tab_type_list = {
        [1] = HomepetConst.collection_tab_type.eTreasureType,
        [2] = HomepetConst.collection_tab_type.ePhotoType,
        [3] = HomepetConst.collection_tab_type.eLetterType
    }
    local tab_name_list = {
        [self.tab_type_list[1]] = TI18N("珍 品"),
        [self.tab_type_list[2]] = TI18N("相 册"),
        [self.tab_type_list[3]] = TI18N("书 信"),
    }
    --对应类型的lay
    self.lay_scrollview_list = {}
    self.lay_scrollview_list[self.tab_type_list[1]] = self.main_container:getChildByName("lay_scrollview_1")
    self.lay_scrollview_list[self.tab_type_list[2]] = self.main_container:getChildByName("lay_scrollview_2")
    self.lay_scrollview_list[self.tab_type_list[3]] = self.main_container:getChildByName("lay_scrollview_3")

    self.lay_scrollview_size = self.lay_scrollview_list[self.tab_type_list[1]]:getContentSize()
    --对应item的相关配置
    self.item_params_list = {}
    self.item_params_list[self.tab_type_list[1]] = {size = cc.size(136, 124), row = 5, col = 4 }
    self.item_params_list[self.tab_type_list[2]] = {size = cc.size(268, 189), row = 3, col = 2 } 
    self.item_params_list[self.tab_type_list[3]] = {size = cc.size(158, 206), row = 3, col = 3 } 

    --所有item的
    self.item_list = {}

    self.tab_list = {}
    for i=1,3 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then

            local object = {}
            object.select_bg = tab_btn:getChildByName('select_img')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('normal_img')
            object.title = tab_btn:getChildByName("label")
            object.title:enableOutline(cc.c4b(0x8c,0x4e,0x1c,0xff), 2)
            -- object.title:setTextColor(cc.c4b(0x8c,0x4e,0x1c,0xff))
            object.index = self.tab_type_list[i] or HomepetConst.collection_tab_type.eTreasureType
            if tab_name_list[object.index] then
                object.title:setString(tab_name_list[object.index])
            end
            object.tab_btn = tab_btn
            self.item_list[object.index] = {}
            self.tab_list[object.index] = object
        end
    end
end

function HomePetCollectionPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)

    registerButtonEventListener(self.per_btn, function() self:onPerBtn()  end ,true, 1)
    registerButtonEventListener(self.next_btn, function() self:onNextBtn()  end ,true, 1)
    registerButtonEventListener(self.remove_btn, function() self:onRemoveBtn()  end ,true, 1)
    registerButtonEventListener(self.save_btn, function() self:onSaveBtn()  end ,true, 1)


    for k, object in pairs(self.tab_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end

     --删除图片
    self:addGlobalEvent(HomepetEvent.HOME_PET_DELETE_PHOTO_EVENT, function(id)
        self:setDataByType(HomepetConst.collection_tab_type.ePhotoType)
        self:checkBtnStatus()
        --删除可能导致页数少了一页
        if self.cur_page > self.max_page[self.select_index] then
            self.cur_page = self.max_page[self.select_index]
        end
        if self.tab_type_list[self.select_index] == HomepetConst.collection_tab_type.ePhotoType then
            local data_list = self:updateList(self.select_index, self.cur_page)
            self:cleanSelectImg()
            if #data_list > 0 then
                local item = self.item_list[self.select_index][1]
                self.select_data[self.select_index] = data_list[1]
                if item and item.setSelectImgVisible then
                    item:setSelectImgVisible(true)
                end
            end
        end
    end)

     --删除日记
    self:addGlobalEvent(HomepetEvent.HOME_PET_DELETE_LETTER_EVENT, function(id)
        self:setDataByType(HomepetConst.collection_tab_type.eLetterType)
        self:checkBtnStatus()
        --删除可能导致页数少了一页
        if self.cur_page > self.max_page[self.select_index] then
            self.cur_page = self.max_page[self.select_index]
        end
        if self.tab_type_list[self.select_index] == HomepetConst.collection_tab_type.eLetterType then
            local data_list = self:updateList(self.select_index, self.cur_page)
             self:cleanSelectImg()
            if #data_list > 0 then
                local item = self.item_list[self.select_index][1]
                self.select_data[self.select_index] = data_list[1]
                if item and item.setSelectImgVisible then
                    item:setSelectImgVisible(true)
                end
            end
        end
    end)    
end

function HomePetCollectionPanel:onClosedBtn()
    controller:openHomePetCollectionPanel(false)
end

function HomePetCollectionPanel:cleanSelectImg()
    if self.item_list and self.item_list[self.select_index] then
        for i,v in ipairs(self.item_list[self.select_index]) do
            v:setSelectImgVisible(false)
        end
        self.select_data[self.select_index] = nil
    end
end

--上一页
function HomePetCollectionPanel:onPerBtn()
    if not self.item_data_list then return end
    local old_page = self.cur_page
    self.cur_page = self.cur_page - 1
    if self.cur_page < 1 then
        self.cur_page = 1
    end
    if old_page ~= self.cur_page then
        self:cleanSelectImg()
    end
    self:checkBtnStatus()
    self:updateList(self.select_index, self.cur_page)
end

--下一页
function HomePetCollectionPanel:onNextBtn()
    if not self.item_data_list then return end
    if not self.max_page[self.select_index] then return end
    local old_page = self.cur_page
    self.cur_page = self.cur_page + 1
    if self.cur_page > self.max_page[self.select_index] then
        self.cur_page = self.max_page[self.select_index]
    end
    if old_page ~= self.cur_page then
        self:cleanSelectImg()
    end
    self:checkBtnStatus()
    self:updateList(self.select_index, self.cur_page)
end

function HomePetCollectionPanel:checkBtnStatus()
    if self.max_page[self.select_index] == 1 then
        --只有 1页
        self:setUnEnabledBtn(true, self.per_btn,self.per_btn_lab)
        self:setUnEnabledBtn(true, self.next_btn,self.next_btn_lab)
    else
        if self.cur_page ==  1 then
            self:setUnEnabledBtn(true, self.per_btn,self.per_btn_lab)
            self:setUnEnabledBtn(false, self.next_btn,self.next_btn_lab)
        elseif  self.cur_page == self.max_page[self.select_index] then
            self:setUnEnabledBtn(false, self.per_btn,self.per_btn_lab)
            self:setUnEnabledBtn(true, self.next_btn,self.next_btn_lab)
        else
            self:setUnEnabledBtn(false, self.per_btn,self.per_btn_lab)
            self:setUnEnabledBtn(false, self.next_btn,self.next_btn_lab)
        end    
    end
    if self.page_label then
        local str = string_format(TI18N("%s/%s页"), self.cur_page, self.max_page[self.select_index])
        self.page_label:setString(str)
    end
end

function HomePetCollectionPanel:setUnEnabledBtn(bool, btn,btn_lab)
    setChildUnEnabled(bool,btn)
    btn:setTouchEnabled(not bool)
    if btn_lab then
        if bool == true then
            btn_lab:disableEffect(cc.LabelEffect.OUTLINE)
        else
            btn_lab:enableOutline(Config.ColorData.data_color4[264], 2)
        end    
    end
end

--移除
function HomePetCollectionPanel:onRemoveBtn()
    if self.select_data and self.select_data[self.select_index] then
        local confirm_handler = function()
            if self.tab_type_list[self.select_index] == HomepetConst.collection_tab_type.ePhotoType then
                controller:sender26113(BackPackConst.item_type.HOME_PET_PHOTO, self.select_data[self.select_index].id)
            elseif self.tab_type_list[self.select_index] == HomepetConst.collection_tab_type.eLetterType then
                controller:sender26113(BackPackConst.item_type.HOME_PET_LITTER, self.select_data[self.select_index].id)
            end
        end
        CommonAlert.show(TI18N("确定要删除吗？"),TI18N("删除"),confirm_handler,TI18N("取消"))
    else
        if self.tab_type_list[self.select_index] == HomepetConst.collection_tab_type.ePhotoType then
            message(TI18N("没有选中明信片"))
        else
            message(TI18N("没有选中信件"))
        end
    end
end

--保存
function HomePetCollectionPanel:onSaveBtn()

end

-- 切换标签页
function HomePetCollectionPanel:changeSelectedTab( index )
    if self.tab_object and self.tab_object.index == index then return end

    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        -- self.tab_object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        self.tab_object.title:enableOutline(cc.c4b(0x8c,0x4e,0x1c,0xff), 2)
        self.tab_object = nil
    end
    self.select_index = index
    self.tab_object = self.tab_list[index]

    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        -- self.tab_object.title:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
        self.tab_object.title:enableOutline(cc.c4b(0x97,0x6f,0x0f,0xff), 2)
    end

    --数据
    self.cur_page = 1
    self:checkBtnStatus()
    self:updateList(index, self.cur_page)

    if index == HomepetConst.collection_tab_type.eTreasureType then
        self.remove_btn:setVisible(false)
        self.save_btn:setVisible(false)
    else
        self.remove_btn:setVisible(true)
        self.save_btn:setVisible(false)
    end
end


--setting.index 选择页签  参考 HomepetConst.collection_tab_type
function HomePetCollectionPanel:openRootWnd(setting)
    local setting = setting or {}
    self.select_index = setting.index or HomepetConst.collection_tab_type.eTreasureType
    self:initData()
    self:changeSelectedTab(self.select_index)
end

function HomePetCollectionPanel:initData()
    if not self.tab_type_list then return end

    self.dic_have_treasure_id = model.dic_have_treasure_id or {}
    self.item_data_list = {}
    for _,index in ipairs(self.tab_type_list) do
        self:setDataByType(index)
    end
end

--@index 就是 self.tab_type_list
function HomePetCollectionPanel:setDataByType(index)
    local item_params = self.item_params_list[index]
    if item_params then  
        self.item_data_list[index] = {}
        if index == HomepetConst.collection_tab_type.eTreasureType then --珍品读表
            local config = Config.ItemData.data_treasure_info
            for item_id, v in pairs(config) do
                local item_config = Config.ItemData8.data_unit(item_id)
                if item_config then
                    table_insert(self.item_data_list[index], item_config)
                end
            end
        elseif index == HomepetConst.collection_tab_type.ePhotoType then --相片 --读背包
            local list = model.dic_photo_data or {}
            for k,v in pairs(list) do
                table_insert(self.item_data_list[index], v)
            end
        elseif index == HomepetConst.collection_tab_type.eLetterType then --日志读背包
            local list = model.dic_letter_data or {}
            for k,v in pairs(list) do
                table_insert(self.item_data_list[index], v)
            end
        end
        local page_count = item_params.row * item_params.col
        self.max_page[index] = math.ceil(#self.item_data_list[index]/page_count)
        if self.max_page[index] == 0 then
            self.max_page[index] = 1
        end
        if index == HomepetConst.collection_tab_type.eTreasureType then --珍品读表 then
            table_sort(self.item_data_list[index], function(a, b) return a.id > b.id end)
        else
            table_sort(self.item_data_list[index], function(a, b) return a.base_id > b.base_id end)
        end
    end
end

function HomePetCollectionPanel:updateList(index)
    if not self.item_data_list then return end
    if not self.item_data_list[index] then return end
    if not self.cur_page then return end
    for _,lay in pairs(self.lay_scrollview_list) do
        doStopAllActions(lay)
        lay:setVisible(false)
    end

    local item_params = self.item_params_list[index]
    if not item_params then return end

    local page_count = item_params.row * item_params.col
    local data_index = (self.cur_page - 1) * page_count 
    local data_list = {}
    for i=1,page_count do
        if self.item_data_list[index][i + data_index] then
            table_insert(data_list, self.item_data_list[index][i + data_index])
        else
            break
        end
    end
    self:updateItemList(index, data_list)
    return data_list
end


function HomePetCollectionPanel:updateItemList(index, data_list)    
    if not self.item_list[index] then return end
    local  layout = self.lay_scrollview_list[index]
    if not layout then return end

    local item_params = self.item_params_list[index]
    layout:setVisible(true)
    for i,v in ipairs(self.item_list[index]) do
        v:setVisible(false)
    end
    if #data_list == 0 then
        if self.tab_type_list[index] == HomepetConst.collection_tab_type.ePhotoType then
            commonShowEmptyIcon(layout, true, {text = TI18N("一个明信片都没有噢，快让宠物去旅行获取吧~")})
        elseif self.tab_type_list[index] == HomepetConst.collection_tab_type.eLetterType then
            commonShowEmptyIcon(layout, true, {text = TI18N("一个日记都没有噢，快让宠物去旅行获取吧~")})
            -- commonShowEmptyIcon(layout, true, {text = TI18N("一个日记都没有噢，快让宠物去旅行获取吧~")})
        end
        
        return
    else
        commonShowEmptyIcon(layout, false)
    end 

    local math_floor = math.floor

    local item_width = self.lay_scrollview_size.width/item_params.col
    local item_height = self.lay_scrollview_size.height/item_params.row

    local dealey = 0
    for i,v in ipairs(data_list) do
        local item = self.item_list[index][i]
        if item == nil then
            dealey = dealey + 1
            delayRun(layout,dealey / display.DEFAULT_FPS,function ()
                item = self:getNewItemByIndex(index)
                self.item_list[index][i] = item

                local row = math_floor((i-1)/item_params.col)
                local col = (i-1)%item_params.col

                local x = col * item_width + item_width * 0.5
                local y = self.lay_scrollview_size.height - (row * item_height + item_height * 0.5)
                item:setPosition(x, y)
                item:setData(v)
                item:addCallback(function() self:onClickItemIndex(index, i) end)
                layout:addChild(item)
            end)
        else
            item:setVisible(true)
            item:setData(v)
        end
        
    end
end

function HomePetCollectionPanel:getNewItemByIndex(index)
    if index == HomepetConst.collection_tab_type.eTreasureType then --珍品
        return  HomePetCollectionTreasureItem.new(self)
    elseif index == HomepetConst.collection_tab_type.ePhotoType then --相册
        return  HomePetCollectionPhotoItem.new()
    else--if index == HomepetConst.collection_tab_type.eLetterType then --书信
        return  HomePetCollectionLetterItem.new()
    end
end

function HomePetCollectionPanel:onClickItemIndex(index, i)
    if not self.cur_page then return end
    local item_params = self.item_params_list[index]
    if not item_params then return end
    local page_count = item_params.row * item_params.col
    local data_index = (self.cur_page - 1) * page_count 

    local item = self.item_list[index][i]
    local data = self.item_data_list[index][i + data_index]
    
    if not data then return end
    if index == HomepetConst.collection_tab_type.eTreasureType then --珍品
        if self.dic_have_treasure_id and self.dic_have_treasure_id[data.id] then
            controller:openHomePetTreasureInfoPanel(true, {item_config = data})
        end
    --elseif index == HomepetConst.collection_tab_type.ePhotoType then --相册  
    else--if index == HomepetConst.collection_tab_type.eLetterType then --书信
        if self.select_data[index] == nil or self.select_data[index].id ~= data.id then
            self:cleanSelectImg()
            self.select_data[index] = data
            item:setSelectImgVisible(true)
        else
            if data.config then
                local setting = {}
                setting.item_id = data.config.id
                setting.id = data.id
                controller:openHomePetEventInfoPanel(true, setting)
            end
        end
    end
end


function HomePetCollectionPanel:close_callback()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for _, list in ipairs(self.item_list) do
            for _,v in ipairs(list) do
                if v.DeleteMe then
                    v:DeleteMe()
                end
            end
        end
    end
    self.item_list = nil

    controller:openHomePetCollectionPanel(false)
end


-- 珍品子项
HomePetCollectionTreasureItem = class("HomePetCollectionTreasureItem", function()
    return ccui.Widget:create()
end)

function HomePetCollectionTreasureItem:ctor(parent)
    self.parent = parent
    self:configUI()
    self:register_event()
end

function HomePetCollectionTreasureItem:configUI()
    local csbPath = PathTool.getTargetCSB("homepet/home_pet_collection_treasure_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.size = self.root_wnd:getContentSize()
    self.root_wnd:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:setPosition(0, 0)
    self:addChild(self.root_wnd)

    self:setTouchEnabled(true)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.icon = self.main_container:getChildByName("icon")

    self.select_img = self.main_container:getChildByName("select_img")
    self:setSelectImgVisible(false)
end

function HomePetCollectionTreasureItem:register_event( )
    registerButtonEventListener(self.main_container, function() self:onSelectBtn()  end ,false, 1)
end

--选择
function HomePetCollectionTreasureItem:onSelectBtn()
    if not self.data then return end
    if self.callback then
        self.callback()
    end
end

function HomePetCollectionTreasureItem:addCallback(callback)
    self.callback = callback
end

--data 就是 item_config 萌宠道具表的数据
function HomePetCollectionTreasureItem:setData(data)
    if not data then return end
    self.data = data 

    local head_icon
    if self.parent and self.parent.dic_have_treasure_id and self.parent.dic_have_treasure_id[data.id] then
        --拥有
        head_icon = PathTool.getItemRes(self.data.icon, false)
    else
        --未拥有
        head_icon = PathTool.getTargetRes("homepet_item", self.data.icon,false,false)
    end

    if self.record_head_icon == nil or self.record_head_icon ~= head_icon then
        self.record_head_icon = head_icon
        loadSpriteTexture(self.icon, head_icon, LOADTEXT_TYPE)
    end
end

function HomePetCollectionTreasureItem:setSelectImgVisible(visible)
    self.select_img:setVisible(visible)
end

function HomePetCollectionTreasureItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end



-- 相片子项
HomePetCollectionPhotoItem = class("HomePetCollectionPhotoItem", function()
    return ccui.Widget:create()
end)

function HomePetCollectionPhotoItem:ctor()
    self:configUI()
    self:register_event()
end

function HomePetCollectionPhotoItem:configUI()
    local csbPath = PathTool.getTargetCSB("homepet/home_pet_collection_photo_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:setPosition(0, 0)
    self.size = self.root_wnd:getContentSize()
    self:addChild(self.root_wnd)

    self:setTouchEnabled(true)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.icon = self.main_container:getChildByName("icon")

    self.ssr_img = self.main_container:getChildByName("ssr_img")

    self.select_img = self.main_container:getChildByName("select_img")
    self:setSelectImgVisible(false)
end

function HomePetCollectionPhotoItem:setSelectImgVisible(visible)
    self.select_img:setVisible(visible)
end

function HomePetCollectionPhotoItem:register_event( )
    registerButtonEventListener(self.main_container, function() self:onSelectBtn()  end ,false, 1)
end

function HomePetCollectionPhotoItem:onSelectBtn()
    if not self.data then return end
    if self.callback then
        self.callback()
    end
end

function HomePetCollectionPhotoItem:addCallback(callback)
    self.callback = callback
end

--data 是goods_vo
function HomePetCollectionPhotoItem:setData(data)
    if not data then return end
    self.data = data

    local item_config = data.config
    if not item_config then return end
        -- quality
    local res = PathTool.getPlistImgForDownLoad("homepet_item", item_config.icon, true)
    if self.record_proto_img_res == nil or self.record_proto_img_res ~= res then
        self.record_proto_img_res = res
        self.item_load_proto_img_res = loadSpriteTextureFromCDN(self.icon, res, ResourcesType.single, self.item_load_proto_img_res) 
    end 

    local res_name = model:getHomepetResNameByQuality(item_config.quality)
    local ssr_res = PathTool.getResFrame("homepet_eventinfo","homepet_eventinfo_"..res_name)
    if self.record_ssr_res == nil or self.record_ssr_res ~= ssr_res then
        self.record_ssr_res = ssr_res
        loadSpriteTexture(self.ssr_img, ssr_res, LOADTEXT_TYPE_PLIST)
    end

end

function HomePetCollectionPhotoItem:DeleteMe()
    if self.item_load_proto_img_res then
        self.item_load_proto_img_res:DeleteMe()
        item_load_proto_img_res = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end


-- 书信子项
HomePetCollectionLetterItem = class("HomePetCollectionLetterItem", function()
    return ccui.Widget:create()
end)

function HomePetCollectionLetterItem:ctor()
    self:configUI()
    self:register_event()
end

function HomePetCollectionLetterItem:configUI( )
    local csbPath = PathTool.getTargetCSB("homepet/home_pet_collection_letter_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:setPosition(0, 0)
    self.size = self.root_wnd:getContentSize()
    self:addChild(self.root_wnd)

    self:setTouchEnabled(true)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.label = self.main_container:getChildByName("label")

    self.select_img = self.main_container:getChildByName("select_img")
    self:setSelectImgVisible(false)
end


function HomePetCollectionLetterItem:setSelectImgVisible(visible)
    self.select_img:setVisible(visible)
end

function HomePetCollectionLetterItem:register_event( )
    registerButtonEventListener(self.main_container, function() self:onSelectBtn()  end ,false, 1)
end

function HomePetCollectionLetterItem:onSelectBtn()
    if not self.data then return end
    if self.callback then
        self.callback()
    end
end

function HomePetCollectionLetterItem:addCallback(callback)
    self.callback = callback
end

function HomePetCollectionLetterItem:setData(data)
    if not data then return end
    self.data = data
    if data.config then
        self.label:setString(data.config.use_desc)
    end
end

function HomePetCollectionLetterItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end