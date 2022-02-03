-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      竖版伙伴装备信息面板
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
HeroMainTabEquipPanel = class("HeroMainTabEquipPanel", function()
    return ccui.Widget:create()
end)

local string_format = string.format
local controller = HeroController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local role_vo = RoleController:getInstance():getRoleVo()

--@power_click 那边传过来的战力node
function HeroMainTabEquipPanel:ctor(power_click)  
    self:config()
    self:layoutUI(power_click)
    self:registerEvents()
end
function HeroMainTabEquipPanel:config()
    --装备item 列表
    self.equip_item_list = {}

    self.equip_type_list = HeroConst.EquipPosList

    self.equip_icon_name_list = {
        [BackPackConst.item_type.WEAPON] = "hero_info_7",  --武器icon
        [BackPackConst.item_type.SHOE] = "hero_info_10",  --鞋子icon
        [BackPackConst.item_type.CLOTHES] = "hero_info_9",  --衣服icon 
        [BackPackConst.item_type.HAT] = "hero_info_8",  --裤子icon
        [5] = "hero_info_11", --武器icon--神器
        [6] = "hero_info_11", --武器icon
    }   

    --神器解锁条件
    self.artifact_lock_list = model.artifact_lock_list
end

function HeroMainTabEquipPanel:layoutUI(power_click)
    local csbPath = PathTool.getTargetCSB("hero/hero_main_tab_equip_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)
    --那边传过来的战力node()
    -- self.power_click = power_click
    self.tab_panel = self.root_wnd:getChildByName("tab_panel")

    self.equip_node_list = {}
    for i=1,6 do
        local equip_type = self.equip_type_list[i] or i
        self.equip_node_list[i] = self.tab_panel:getChildByName("equip_node"..i)

        local item = BackPackItem.new(false,true,nil,0.8,false)
        -- 引导需要
        item:setName("guidesign_equip_item_"..i)
        self.equip_node_list[i]:addChild(item,1)
        item:setPosition(cc.p(0,0))
        item:addCallBack(function() self:selectEquipByIndex(equip_type) end)
        local res= PathTool.getResFrame("hero",self.equip_icon_name_list[equip_type])
        local empty_icon = createImage(item:getRoot(), res,60,60, cc.p(0.5,0.5), true, 10, false)
        item.empty_icon = empty_icon
        if i >= 5 then
            -- item:setBackgroundOpacity(0)
        end
        self.equip_item_list[equip_type] = item
    end
    self.img_lock = {}
    self.lab_lock = {}
    self.img_box = {}
    self.img_bg = {}

    self.img_lock[1] = self.tab_panel:getChildByName("img_lock5")
    self.img_lock[1]:setScale(0.8)
    self.lab_lock[1] = self.tab_panel:getChildByName("lab_lock5")
    self.lab_lock[1]:setScale(0.8)
    self.img_box[1]  = self.tab_panel:getChildByName("artifacts_bg_1")
    self.img_box[1]:setScale(0.9)
    self.img_bg[1]  = self.tab_panel:getChildByName("equip_node5"):getChildByName("box_34")
    self.img_bg[1]:setScale(0.9)
    self.img_lock[2] = self.tab_panel:getChildByName("img_lock6")
    self.img_lock[2]:setScale(0.8)
    self.lab_lock[2] = self.tab_panel:getChildByName("lab_lock6")
    self.lab_lock[2]:setScale(0.8)
    self.img_box[2]  = self.tab_panel:getChildByName("artifacts_bg_2")
    self.img_box[2]:setScale(0.9)
    self.img_bg[2]  = self.tab_panel:getChildByName("equip_node6"):getChildByName("box_34")
    self.img_bg[2]:setScale(0.9)

    self.key_up_btn = self.tab_panel:getChildByName("key_up_btn")
    self.key_up_btn:getChildByName("label"):setString(TI18N("一键穿戴"))
    self.key_up_btn:setVisible(false)
    self.discharge_btn = self.tab_panel:getChildByName("discharge_btn")
    self.discharge_btn:getChildByName("label"):setString(TI18N("一键卸下"))
    self.discharge_btn:setVisible(false)
end

--事件
function HeroMainTabEquipPanel:registerEvents()
    registerButtonEventListener(self.key_up_btn, function() self:onClickKeyUpBtn()  end ,true)
    registerButtonEventListener(self.discharge_btn, function() self:onClickDischargeBtn()  end ,true)

    if self.hero_data_update_event == nil then
        self.hero_data_update_event = GlobalEvent:getInstance():Bind(HeroEvent.Hero_Data_Update, function(hero_vo)
            if not hero_vo or not self.hero_vo then return end
            if hero_vo.partner_id == self.hero_vo.partner_id then
                self:updateArtifactInfo(self.hero_vo)
            end
        end)
    end

    --英雄信息更新
    if self.hero_equip_update_event == nil then
        self.hero_equip_update_event = GlobalEvent:getInstance():Bind(HeroEvent.Equip_Update_Event, function()
            if not self.hero_vo then return end
            self:updateInfo(self.hero_vo)
            self:updateOneKeyBtnStatus()
        end)
    end
    --红点更新事件..英雄信息更新和 背包的信息更新 才能判断红点
    if self.hero_equip_redpoint_event == nil then
        self.hero_equip_redpoint_event = GlobalEvent:getInstance():Bind(HeroEvent.Equip_RedPoint_Event, function()
            if not self.hero_vo then return end
            self:updateRedPoint()
            self:updateOneKeyBtnStatus()
        end)
    end

    --神器信息
    if not self.update_artifact_event then 
        self.update_artifact_event = GlobalEvent:getInstance():Bind(HeroEvent.Artifact_Update_Event, function(vo)
            if not self.hero_vo then return end
            self:updateArtifactInfo(self.hero_vo)
        end)
    end
end

-- 更新一键穿戴/卸下按钮显示
function HeroMainTabEquipPanel:updateOneKeyBtnStatus(  )
    if self.hero_vo and self.hero_vo.eqm_list then
        -- 装备有红点时，或者没穿戴任何装备时，显示一键穿戴，否则显示一键卸下
        if self.is_btn_redpoint or tableLen(self.hero_vo.eqm_list) <= 0 then
            self.key_up_btn:setVisible(true)
            self.discharge_btn:setVisible(false)
        else
            self.key_up_btn:setVisible(false)
            self.discharge_btn:setVisible(true)
        end
    else
        self.key_up_btn:setVisible(false)
        self.discharge_btn:setVisible(false)
    end
end

--一键穿戴
function HeroMainTabEquipPanel:onClickKeyUpBtn()
    if not self.hero_vo then return end
    controller:sender11010(self.hero_vo.partner_id, 0)
end

-- 一键卸下
function HeroMainTabEquipPanel:onClickDischargeBtn(  )
    if not self.hero_vo then return end
    controller:sender11011(self.hero_vo.partner_id, 0)
end

--@ index 索引  如果是装备可以是装备类型 equip_type
function HeroMainTabEquipPanel:selectEquipByIndex(index)
    if not self.hero_vo then return end
    if index == 5 or index == 6 then
        --5 ,6 是神器的位置
        local pos = index - 4
        local equip_vo = self.hero_vo.artifact_list[pos]
        --策划要求 原本 6星解锁 改成 7星解锁 .原本6星的已有数据的保留
        if equip_vo == nil then
            local artifact_lock = self.artifact_lock_list[pos]
            if artifact_lock then
                if artifact_lock[1] == 'lev' then
                    if self.hero_vo.lev < artifact_lock[2] then
                        message(string_format( TI18N("英雄%s级解锁"),artifact_lock[2]))
                        return 
                    end
                elseif artifact_lock[1] == 'star' then
                    if self.hero_vo.star < artifact_lock[2] then
                        message(string_format( TI18N("英雄%s星解锁"),artifact_lock[2]))
                        return
                    end
                end
            end
        end
        
        -- local equip_vo = self.hero_vo.artifact_list[pos]
        --默认都是主神器 
        if equip_vo and next(equip_vo) ~=nil then 
            controller:openArtifactTipsWindow(true, equip_vo, PartnerConst.ArtifactTips.partner, self.hero_vo.partner_id, pos, self.lock_list[pos])
        else
            controller:openArtifactListWindow(true, pos, self.hero_vo.partner_id)
        end
    else
        local equip_type = index
        local equip_list = model:getHeroEquipList(self.hero_vo.partner_id)
        local equip_vo = equip_list[equip_type]
        if equip_vo ~= nil then
            controller:openEquipTips(true, equip_vo, PartnerConst.EqmTips.partner, self.hero_vo) 
        else
            controller:openEquipPanel(true,equip_type,self.hero_vo.partner_id)
        end
    end
end


function HeroMainTabEquipPanel:setData(hero_vo)
    if not hero_vo then return end
    self.hero_vo = hero_vo
    self:updateInfo(hero_vo)
    self:updateRedPoint()
    self:updateOneKeyBtnStatus()
end

function HeroMainTabEquipPanel:updateRedPoint()
    --按钮的红点
    local is_btn_redpoint = false
    --装备红点
    for i,equip_type in ipairs(self.equip_type_list) do
        local is_redpoint = self:updateEachEquipRedPoint(equip_type)
        if not is_btn_redpoint then
            is_btn_redpoint = is_redpoint
        end
    end

    if is_btn_redpoint then
        -- self.key_up_btn:setVisible(true)
        addRedPointToNodeByStatus(self.key_up_btn, is_btn_redpoint, 5, 5)
        -- if self.power_click then
        --     self.power_click:setVisible(false)
        -- end
    else
        addRedPointToNodeByStatus(self.key_up_btn, is_btn_redpoint, 5, 5)
        -- if self.power_click then
        --     self.power_click:setVisible(true)
        -- end
        -- self.key_up_btn:setVisible(false)
    end
    self.is_btn_redpoint = is_btn_redpoint
end

--更新圣器的红点
function HeroMainTabEquipPanel:updateArtifactRedPoint()
    --符文(神器) 红点
    if self.lock_list then
        for i,v in ipairs(self.artifact_lock_list) do
            if not self.lock_list[i] then
                local equip_vo = self.hero_vo.artifact_list[i]
                local is_redpoint = HeroCalculate.checkSingleArtifactRedPoint(equip_vo)
                local item = self.equip_item_list[i+4]
                -- item:showRedPoint(is_redpoint)
                addRedPointToNodeByStatus(self.img_box[i], is_redpoint, -1, -10)
                if self.img_box[i].red_point then
                    self.img_box[i].red_point:setScale(0.8 * 100/95)
                end
            else
                addRedPointToNodeByStatus(self.img_box[i], false)    
            end
        end
    end
end

--更新每一个装备红点
function HeroMainTabEquipPanel:updateEachEquipRedPoint(equip_type)
    local equip_list = model:getHeroEquipList(self.hero_vo.partner_id)
    local item = self.equip_item_list[equip_type]
    local is_redpoint = HeroCalculate.checkSingleHeroEachPosEquipRedPoint(equip_type, equip_list[equip_type])
    item:showRedPoint(is_redpoint)
    return is_redpoint
end

function HeroMainTabEquipPanel:updateInfo(hero_vo)
    if not hero_vo then return end
    --装备信息
    local equip_list = model:getHeroEquipList(hero_vo.partner_id)
    for i,_type in ipairs(self.equip_type_list) do
        local equip_vo = equip_list[_type]
        local item = self.equip_item_list[_type]
        if equip_vo then
            item:setData(equip_vo)
            if item.empty_icon then 
                item.empty_icon:setVisible(false)
            end
            item.equip_vo = equip_vo
        else
            item:setData()
            if item.empty_icon then 
                item.empty_icon:setVisible(true)
            end
            item.equip_vo = nil
            item:setBackgroundRes(PathTool.getResFrame("hero", "hero_info_32"))
        end
        -- item:setBackgroundRes(PathTool.getResFrame("hero", "hero_info_32"))
    end

    self:updateArtifactInfo(hero_vo)
end

--神器信息
function HeroMainTabEquipPanel:updateArtifactInfo( hero_vo )
    --解锁信息
    self.lock_list = {}
    for i,v in ipairs(self.artifact_lock_list) do
        self.img_lock[i]:setVisible(false)
        self.lab_lock[i]:setVisible(true)
        self.lab_lock[i]:setString("")
        local is_lock = true
        local item = self.equip_item_list[i+4]
        if v[1] == 'lev' then
            if hero_vo.lev >= v[2]  then
                --已解锁
                is_lock = false
                self.img_box[i]:setVisible(true)
                self.img_bg[i]:setVisible(true)
                if item then
                    item:setVisible(true)
                end
            else
                local max_lev = Config.PartnerData.data_partner_max_lev[self.hero_vo.bid]
                if max_lev and max_lev >= v[2] then
                    self.img_lock[i]:setVisible(true)
                    self.img_box[i]:setVisible(true)
                    self.img_bg[i]:setVisible(true)
                    if item then
                        item:setVisible(true)
                    end
                    self.lab_lock[i]:setString(v[2]..TI18N("级解锁"))
                else
                    self.img_box[i]:setVisible(false)
                    self.img_bg[i]:setVisible(false)
                    if item then
                        item:setVisible(false)
                    end
                end
            end
        elseif v[1] == 'star' then
            local max_star = Config.PartnerData.data_partner_max_star[self.hero_vo.bid]
            if max_star and max_star < v[2] then
                --策划要求不满星级的要隐藏
                self.img_box[i]:setVisible(false)
                self.img_bg[i]:setVisible(false)
                if item then
                    item:setVisible(false)
                end
            else
                self.img_box[i]:setVisible(true)
                self.img_bg[i]:setVisible(true)
                if self.img_box[i].red_point then
                    self.img_box[i].red_point:setVisible(false)
                end
                if item then
                    item:setVisible(true)
                end
                if hero_vo.star >= v[2] then
                    is_lock = false
                else
                    self.img_lock[i]:setVisible(true)
                    self.lab_lock[i]:setString(v[2]..TI18N("星解锁")) 
                end
            end
        end
        self.lock_list[i] = is_lock
    end
    --self.equip_item_list[5] [6] 是神器信息
    if hero_vo.artifact_list then
        for i=1,2 do
            local item = self.equip_item_list[i+4]
            local equip_vo = hero_vo.artifact_list[i]
            -- if not self.lock_list[i] and equip_vo then
            --策划要求 原本 6星解锁 改成 7星解锁 .原本6星的已有数据的保留
            if equip_vo then
                item:setData(equip_vo)
                if item.empty_icon then 
                    item.empty_icon:setVisible(false)
                end
                item.equip_vo = equip_vo
                self.img_lock[i]:setVisible(false)
                self.lab_lock[i]:setVisible(false)
                item:setBackgroundOpacity(255)
            else
                item:setData()
                if item.empty_icon then 
                    item.empty_icon:setVisible(true)
                end
                item:setBackgroundOpacity(0)
                item.equip_vo = nil
            end
        end
    end

    self:updateArtifactRedPoint()
end

function HeroMainTabEquipPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end


--移除
function HeroMainTabEquipPanel:DeleteMe()
    if self.hero_data_update_event then
        GlobalEvent:getInstance():UnBind(self.hero_data_update_event)
        self.hero_data_update_event = nil
    end
    if self.hero_equip_update_event then
        GlobalEvent:getInstance():UnBind(self.hero_equip_update_event)
        self.hero_equip_update_event = nil
    end
    if self.hero_equip_redpoint_event then
        GlobalEvent:getInstance():UnBind(self.hero_equip_redpoint_event)
        self.hero_equip_redpoint_event = nil
    end
    if self.update_artifact_event then
        GlobalEvent:getInstance():UnBind(self.update_artifact_event)
        self.update_artifact_event = nil
    end
end
