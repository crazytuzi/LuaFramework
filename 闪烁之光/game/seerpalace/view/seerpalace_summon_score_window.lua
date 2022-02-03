-- --------------------------------------------------------------------
-- @author: yuanqi@shiyue.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      先知积分召唤
-- <br/> 2020年4月9日
-- --------------------------------------------------------------------
SeerpalaceSummonScoreWindow = SeerpalaceSummonScoreWindow or BaseClass(BaseView)
local controller = SeerpalaceController:getInstance()
local model = controller:getModel()
local string_format = string.format
function SeerpalaceSummonScoreWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self. _type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "seerpalace/seerpalace_summon_score_panel"
    self.summon_pos = {}
    self.summon_list = {}
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("seerpalace", "seerpalace"), type = ResourcesType.plist},
    }
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.need_vip_lev = 5
    local config = Config.RecruitHighData.data_seerpalace_const
    if config and config.recruit_vip and config.recruit_vip.val  then
        self.need_vip_lev = config.recruit_vip.val
    end
end

function SeerpalaceSummonScoreWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("星象占卜"))
    self.vip_label = self.main_container:getChildByName("vip_label")
    self.vip_label:setString(string_format(TI18N("VIP%d方可召唤"), self.need_vip_lev))

    self.item_config = Config.ItemData.data_get_data(SeerpalaceConst.Good_jifen)
    self.desc_label = self.main_panel:getChildByName("desc_label")
    self.desc_label:setString(TI18N("消耗星命卡牌可任选一系进行召唤，必出五星传说英雄"))

    local score_panel = self.main_container:getChildByName("score_panel")
    self.label = score_panel:getChildByName("label")
    self.icon = score_panel:getChildByName("icon")
    if self.item_config then
        self.desc_label:setString(string_format(TI18N("消耗%s可任选一系进行召唤，必出五星传说英雄"), self.item_config.name))
        local res = PathTool.getItemRes(self.item_config.icon)
        loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
    end
    self:updateCount()
    self.summon_btn = self.main_container:getChildByName("summon_btn")
    self.summon_label = self.summon_btn:getChildByName("label")
    self.summon_label:setString(TI18N("召唤"))
    setChildUnEnabled(true, self.summon_btn)
    self.summon_btn:setTouchEnabled(false)
    self.summon_label:disableEffect(cc.LabelEffect.OUTLINE)
    if self.role_vo and self.need_vip_lev <= self.role_vo.vip_lev then
        self.vip_label:setVisible(false)
    end

    for i = 1, 5 do
        local pos_node = self.main_container:getChildByName("pos_node_" .. i)
        if pos_node then
            delayRun(
                pos_node,
                i * 3 / 60,
                function()
                    local summon_icon = self.summon_list[i]
                    if not summon_icon then
                        summon_icon = SeerpalaceSummonScoreItem.new(handler(self, self._onClickSummonCard))
                        pos_node:addChild(summon_icon)
                        self.summon_list[i] = summon_icon
                    end
                    summon_icon:setIndex(i)
                end
            )
            self.summon_pos[i] = pos_node
        end
    end
end

-- 点击了卡牌
function SeerpalaceSummonScoreWindow:_onClickSummonCard(card)
    if self.select_card then
        self.select_card:setSelectStatus(false)
        self.select_card = nil
    end
    local comsume_item = card:getSummonCostItem()
    local cur_num = self.role_vo.predict_point
    if self.role_vo and self.need_vip_lev > self.role_vo.vip_lev then
        message(TI18N(string_format(TI18N("VIP%d方可召唤"), self.need_vip_lev)))
        setChildUnEnabled(true, self.summon_btn)
        self.summon_btn:setTouchEnabled(false)
        self.summon_label:disableEffect(cc.LabelEffect.OUTLINE)
    elseif comsume_item and comsume_item[2] and comsume_item[2] > cur_num then
        if self.item_config and self.item_config.name then
            message(string_format(TI18N("%s不足"), self.item_config.name))
        else
            message(TI18N("星命卡牌不足"))
        end
        setChildUnEnabled(true, self.summon_btn)
        self.summon_btn:setTouchEnabled(false)
        self.summon_label:disableEffect(cc.LabelEffect.OUTLINE)
    elseif card then
        self.select_card = card
        self.select_card:setSelectStatus(true)
        setChildUnEnabled(false, self.summon_btn)
        self.summon_btn:setTouchEnabled(true)
        self.summon_label:enableOutline(Config.ColorData.data_color4[264], 2)
    end
    self:updateButton()
end

-- 刷新召唤按钮文字显示
function SeerpalaceSummonScoreWindow:updateButton()
    self.vip_label:setVisible(false)
    if self.select_card then
        local comsume_item = self.select_card:getSummonCostItem()
        local cur_num = self.role_vo.predict_point
        if self.role_vo and self.need_vip_lev > self.role_vo.vip_lev then
            setChildUnEnabled(true, self.summon_btn)
            self.summon_btn:setTouchEnabled(false)
            self.summon_label:disableEffect(cc.LabelEffect.OUTLINE)
            self.select_card:setSelectStatus(false)
            self.select_card = nil
            self.vip_label:setVisible(true)
        elseif comsume_item and comsume_item[2] and comsume_item[2] > cur_num then
            setChildUnEnabled(true, self.summon_btn)
            self.summon_btn:setTouchEnabled(false)
            self.summon_label:disableEffect(cc.LabelEffect.OUTLINE)
            self.select_card:setSelectStatus(false)
            self.select_card = nil
        else
            setChildUnEnabled(false, self.summon_btn)
            self.summon_btn:setTouchEnabled(true)
            self.summon_label:enableOutline(Config.ColorData.data_color4[264], 2)
        end
    else
        if self.role_vo and self.need_vip_lev > self.role_vo.vip_lev then
            self.vip_label:setVisible(true)
        end
        setChildUnEnabled(true, self.summon_btn)
        self.summon_btn:setTouchEnabled(false)
        self.summon_label:disableEffect(cc.LabelEffect.OUTLINE)
    end
end

function SeerpalaceSummonScoreWindow:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.summon_btn, handler(self, self.onClickBtnSummon) ,true, 1)

    -- 积分资产更新
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
				if key == "predict_point" and self.label then
                    self.label:setString(value)
                    self:updateButton()
                elseif key == "vip_lev" then
                    self:updateButton()
                end
            end)
        end
    end

end

function SeerpalaceSummonScoreWindow:updateCount(  )
    if not self.label then return end
    local count = self.role_vo.predict_point
    self.label:setString(count)
end

--关闭
function SeerpalaceSummonScoreWindow:onClickBtnClose()
    controller:openSeerpalaceSummonScoreWindow(false)
end


-- 确定使用
function SeerpalaceSummonScoreWindow:onClickBtnSummon()
    if self.select_card then
        local group_id = self.select_card:getSummonGroupId()
        controller:requestSeerpalaceSummon(group_id)
    else
        message("请先选择一种卡牌")
    end
end

function SeerpalaceSummonScoreWindow:openRootWnd(setting)
    
end

function SeerpalaceSummonScoreWindow:setData(data)
    
end


function SeerpalaceSummonScoreWindow:close_callback()
    controller:openSeerpalaceSummonScoreWindow(false)
    for _,summon_item in pairs(self.summon_list) do
        summon_item:DeleteMe()
        summon_item = nil
    end
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end
end

---------------------------@ item
SeerpalaceSummonScoreItem = class("SeerpalaceSummonScoreItem", function()
    return ccui.Widget:create()
end)

function SeerpalaceSummonScoreItem:ctor(callback)
    self._clickCallBack = callback

    self._is_select = false -- 是否选中了
    self:configUI()
    self:register_event()
end

function SeerpalaceSummonScoreItem:configUI(  )
    self.size = cc.size(180, 196)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("seerpalace/seerpalace_summon_score_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.brand = container:getChildByName("brand")
    self.select = container:getChildByName("select")
    local score_panel = container:getChildByName("score_panel")
    self.icon = score_panel:getChildByName("icon")
    self.label = score_panel:getChildByName("label")
    local item_config = Config.ItemData.data_get_data(SeerpalaceConst.Good_jifen)
    if item_config then
        local res = PathTool.getItemRes(item_config.icon)
        loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
    end 
    self.select:setVisible(false)
end

function SeerpalaceSummonScoreItem:setIndex( index )
    self.index = index
    self.label:setString(tostring(self.need_score))
    local res = PathTool.getResFrame("seerpalace","seerpalace_brand_"..(self.index))
    loadSpriteTexture(self.brand, res, LOADTEXT_TYPE_PLIST)
    local group_id = SeerpalaceConst.Score_Index_To_GroupId[index]
    local config = Config.RecruitHighData.data_seerpalace_data[group_id]
    if config and config.item_once then
        self.summon_cost = config.item_once[1] -- 召唤所需道具id和数量
        self.group_id = group_id
    end
    if self.summon_cost and self.summon_cost[2] then
        self.label:setString(tostring(self.summon_cost[2]))
    end
end

-- 获取召唤所需道具id和数量
function SeerpalaceSummonScoreItem:getSummonCostItem()
    return self.summon_cost
end

-- 获取先知殿配置的组id
function SeerpalaceSummonScoreItem:getSummonGroupId()
    return self.group_id
end

function SeerpalaceSummonScoreItem:register_event()
    registerButtonEventListener(self.container, handler(self, self._onClickSummonLayer))
end

-- 点击选中
function SeerpalaceSummonScoreItem:_onClickSummonLayer()
    if self._is_select == false then
        if self._clickCallBack then
            self:_clickCallBack(self)
        end
    end
end

function SeerpalaceSummonScoreItem:setSelectStatus(status)
    if status == true then
        self.select:setVisible(true)
    else
        self.select:setVisible(false)
    end
    self._is_select = status
end

function SeerpalaceSummonScoreItem:DeleteMe()
    self.container:stopAllActions()
    self:removeAllChildren()
    self:removeFromParent()
end