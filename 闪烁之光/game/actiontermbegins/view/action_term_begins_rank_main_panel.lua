-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--          开学极排行榜
-- <br/> 2019年8月30日
-- --------------------------------------------------------------------
ActiontermbeginsRankMainPanel = ActiontermbeginsRankMainPanel or BaseClass(BaseView)

local controller = ActiontermbeginsController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ActiontermbeginsRankMainPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "actiontermbegins/action_term_begins_rank_main_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }
    self.view_list = {}
end

function ActiontermbeginsRankMainPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.tab_container = self.main_panel:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("伤害排行"),
        [2] = TI18N("排行奖励")
    }
    self.tab_list = {}
    for i=1,2 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.title = tab_btn:getChildByName("title")
            object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            if tab_name_list[i] then
                object.title:setString(tab_name_list[i])
            end
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end
    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("伤害排行"))

    self.container = self.main_container:getChildByName("container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.top_label = self.main_panel:getChildByName("top_label")
    self.bottom_label = self.main_panel:getChildByName("bottom_label")
    self.top_label:setString(TI18N(""))
    self.bottom_label:setString(TI18N(""))
end

function ActiontermbeginsRankMainPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)

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

       -- 开学副本基础信息
    self:addGlobalEvent(ActiontermbeginsEvent.TERM_BEGINS_RANK_EVENT, function(data)
        if not data then return end
        if not self.view_list then return end
        self.scdata = data
        for k,panel in pairs(self.view_list) do
            if panel.setScdata then
                 panel:setScdata(data)
            end
        end
        self:changeIndexExtendInfo()
    end)

    
end

--关闭
function ActiontermbeginsRankMainPanel:onClickBtnClose()
    controller:openActiontermbeginsRankMainPanel(false)
end


-- 切换标签页
function ActiontermbeginsRankMainPanel:changeSelectedTab( index )
    if self.tab_object ~= nil and self.tab_object.index == index then return end
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.title:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
    end
    self.select_index = index

    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(false)
        else
            self.pre_panel:setVisible(false)
        end
    end
    self.pre_panel = self:createSubPanel(self.select_index)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        else
            self.pre_panel:setVisible(true)
        end
    end
    self.pre_panel:setData()

    self:changeIndexExtendInfo()
end

function ActiontermbeginsRankMainPanel:createSubPanel(index)
    local panel = self.view_list[index]
    if panel == nil then
       if index == 1 then--排行
            panel = ActiontermbeginsRankTabRank.new(self)
        elseif index == 2 then --奖励
            panel = ActiontermbeginsRankTabReward.new(self)
        end
        local size = self.container:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
        self.container:addChild(panel)
        self.view_list[index] = panel
    end
    return panel
end

--@level_id 段位
function ActiontermbeginsRankMainPanel:openRootWnd(setting)
    local setting = setting or {}
    self.select_index = setting.index or 1
    self.rank_type = setting.rank_type or RankConstant.RankType.sandybeach_boss_fight

    --
    if self.rank_type == RankConstant.RankType.termbegins then
        controller:sender26710()
    end
    self:extendInfo()
    -- controller:sender24930(index)
    self:changeSelectedTab(self.select_index)
end

function ActiontermbeginsRankMainPanel:extendInfo()
    if self.rank_type == RankConstant.RankType.termbegins then
        -- self.top_label:setString(TI18N("排名奖励在活动结束后通过邮件发放"))
        -- self.bottom_label:setString(string_format(TI18N("再提升%s伤害可获得下一阶段奖励"), self.scdata.next_power))
    else

    end
end

function ActiontermbeginsRankMainPanel:changeIndexExtendInfo()
    if self.rank_type == RankConstant.RankType.termbegins then
        if self.select_index == 1 then
            self.top_label:setVisible(false)
            self.bottom_label:setVisible(false)
        else
            self.top_label:setVisible(true)
            self.bottom_label:setVisible(true)
            self.top_label:setString(TI18N("排名奖励在活动结束后通过邮件发放"))
            if self.scdata then
                self.bottom_label:setString(string_format(TI18N("再提升%s伤害可获得下一阶段奖励"), self.scdata.next_power))
            end
        end
    else

    end
end


function ActiontermbeginsRankMainPanel:close_callback()
    if self.view_list then
        for i,v in pairs(self.view_list) do 
            if v and v["DeleteMe"] then
                v:DeleteMe()
            end
        end
    end
    self.view_list = nil
    controller:openActiontermbeginsRankMainPanel(false)
end
