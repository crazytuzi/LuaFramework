----------------------------
-- @Author: xhj@shiyue.com
-- @Date:   2020-4-10
-- @Description:   新人练武场
----------------------------
ActionPractiseTowerPanel =
    class(
    "ActionPractiseTowerPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = ActionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
function ActionPractiseTowerPanel:ctor(bid)
    self.holiday_bid = bid
    self:loadResources()
    self.top3_item_list = {}
end

function ActionPractiseTowerPanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("actionpractisetower", "actionpractisetower"), type = ResourcesType.plist},
    }
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(
        self.res_list,
        function()
            if self.configUI then
                self:configUI()
            end
            if self.register_event then
                self:register_event()
            end
        end
    )
end

function ActionPractiseTowerPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_practise_tower_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setPosition(-40, -80)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.image_bg = self.main_container:getChildByName("image_bg")
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/action", "txt_cn_pt")
    if not self.background_load then
        self.background_load = loadSpriteTextureFromCDN(self.image_bg, bg_res, ResourcesType.single, self.background_load)
    end
    
    self.title_lab = self.main_container:getChildByName("title_lab")
    self.title_lab:setString(TI18N("英灵武神殿"))
    self.rank_lab = self.main_container:getChildByName("rank_lab")
    
    self.pass_num = self.main_container:getChildByName("pass_num")
    
    self.btn_tips = self.main_container:getChildByName("btn_tips")
    self.fight_btn = self.main_container:getChildByName("fight_btn")
    self.btn_label = self.fight_btn:getChildByName("label")
    self.btn_label:setString(TI18N("前往挑战"))


    self.rank_container = self.main_container:getChildByName("rank_container")
    self.rank_container:getChildByName("rank_desc_label"):setString(TI18N("排行前三"))
    self.rank_top3_btn = self.rank_container:getChildByName("rank_btn")

    self.item_container = self.main_container:getChildByName("item_container")
    self.item_container:setScrollBarEnabled(false)

    self.time_label = createRichLabel(20, cc.c4b(0xff,0xfc,0xed,0xff), cc.p(1, 0.5), cc.p(690, 45),nil,nil,500)
    self.main_container:addChild(self.time_label)
    self.time_label:setString(TI18N("<div outline=2,#000000>活动已结束</div>"))

    controller:cs16603(self.holiday_bid)
    PractisetowerController:getInstance():sender29100()
end

function ActionPractiseTowerPanel:register_event()
    if not self.Updata_Data_Event then
        self.Updata_Data_Event =GlobalEvent:getInstance():Bind(PractisetowerEvent.Update_All_Data,function(data)
                self.pt_data = PractisetowerController:getInstance():getModel():getPractiseTowerData()
                self:setInitData()
            end
        )
    end

    if self.btn_tips then
        self.btn_tips:addTouchEventListener(function( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                TipsManager:getInstance():showCommonTips(Config.HolidayPractiseTowerData.data_const.rules.desc, sender:getTouchBeganPosition())
            end
        end)
    end

    registerButtonEventListener(self.fight_btn,function()
        self:clickFight()
    end,true,1)

    registerButtonEventListener(self.rank_top3_btn,function()
        PractisetowerController:getInstance():openRankWindow(true)
    end,true,1)
    
    if not self.Updata_My_Rank_Event then
        self.Updata_My_Rank_Event =GlobalEvent:getInstance():Bind(PractisetowerEvent.Update_My_rank,function()
            self.pt_data = PractisetowerController:getInstance():getModel():getPractiseTowerData()
            self:updateMyRank()
            -- if self.pt_data then
            --     self:updateTop3Info(self.pt_data.practise_role_rank)
            -- end
        end
        )
    end
end

function ActionPractiseTowerPanel:setVisibleStatus(bool)
    bool = bool or false
    if bool == true then
        PractisetowerController:getInstance():sender29107(1)
    end
    self:setVisible(bool)
end

function ActionPractiseTowerPanel:setInitData()
    if not self.pt_data then
        return
    end
   
    self:updateBossInfoByBossID()
    if self.pt_data.last_unixtime-GameNet:getInstance():getTime() <= 0 then
        doStopAllActions(self.time_label)
        self.time_label:setString(TI18N("<div outline=2,#000000>活动已结束</div>"))
    else
        local time = self.pt_data.last_unixtime-GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        commonCountDownTime(self.time_label, time, {callback = function(time) self:setTimeValFormatString(time) end})
    end
    

    self:updateTop3Info(self.pt_data.practise_role_rank)

    if self.pt_data.time>0 and self.pt_data.last_unixtime-GameNet:getInstance():getTime() >0 then
        addRedPointToNodeByStatus(self.fight_btn, true,5,5,nil,2)
    else
        addRedPointToNodeByStatus(self.fight_btn, false, 5, 5,nil,2)
    end
    
end

--开启的tips倒计时
function ActionPractiseTowerPanel:setTimeValFormatString(time)
    if time > 0 then
        local str = string_format("<div outline=2,#000000>剩余时间：</div><div fontcolor=#76e464 outline=2,#000000> %s</div>", TimeTool.GetTimeFormatDayIIIIIIII(time))
        self.time_label:setString(str)
    else
        self.time_label:setString(TI18N("<div outline=2,#000000>活动已结束</div>"))
    end
end

function ActionPractiseTowerPanel:updateTop3Info(rank_list)
    if rank_list == nil then return end
    for i=1,3 do
        local v = nil
        if rank_list[i] then
            v = rank_list[i]
        else
            v = {rank = i,is_nil = true}
        end
        
        if not self.top3_item_list[v.rank] then
            local item = self:createSingleRankItem(v.rank)
            self.rank_container:addChild(item)
            self.top3_item_list[v.rank] = item
        end
        local item = self.top3_item_list[v.rank]
        if item then
            item:setPosition(25,210 - (v.rank-1) * item:getContentSize().height)
            if v.is_nil == true then
                item.label:setString(TI18N("暂无"))
            else
                item.label:setString(v.name)
                item.value:setString((v.val or 0)..TI18N("层"))
            end
            
        end
    end
end

function ActionPractiseTowerPanel:createSingleRankItem(i)
	local container = ccui.Layout:create()
	container:setAnchorPoint(cc.p(0,1))
	container:setContentSize(cc.size(180,60))
	local sp = createSprite(PathTool.getResFrame("common","common_300"..i),30,60/2,container)
	sp:setScale(0.7)
	container.sp = sp
	local label = createLabel(20,1,nil,70,41,"",container)
	label:setAnchorPoint(cc.p(0,0.5))
	label:setTextColor(cc.c4b(0xff,0xff,0xff,0xff))

	local value = createLabel(20,1,nil,70,17,"",container)
	value:setAnchorPoint(cc.p(0,0.5))
	value:setTextColor(cc.c4b(0xff,0xcb,0x89,0xff))
	container.label = label
    container.value = value
	return  container
end


function ActionPractiseTowerPanel:clickFight()
    MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.PractiseTower)
end


function ActionPractiseTowerPanel:updateMyRank()
    if not self.pt_data then
        return
    end

    local rank = self.pt_data.role_rank
    if rank == 0 then
        rank = TI18N("未上榜")
    end
    self.rank_lab:setString(string_format(TI18N("当前排名：%s"),rank))
end

function ActionPractiseTowerPanel:updateBossInfoByBossID()
    if not self.pt_data then
        return
    end
  
    self:updateMyRank()
    self.pass_num:setString(string_format(TI18N("已通层数：%d层"),self.pt_data.id))

    local awardCfg = Config.HolidayPractiseTowerData.data_const.item_show
    if awardCfg then
        --奖励
        local data_list = awardCfg.val or {}
        local setting = {}
        setting.scale = 0.9
        setting.max_count = 4
        setting.is_center = true
        setting.show_effect_id = 263
        self.item_list = commonShowSingleRowItemList(self.item_container, self.item_list, data_list, setting)
    end
end


function ActionPractiseTowerPanel:DeleteMe()
    doStopAllActions(self.time_label)
    if self.background_load then
        self.background_load:DeleteMe()
        self.background_load = nil
    end
    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
 
    if self.Updata_Data_Event then
        GlobalEvent:getInstance():UnBind(self.Updata_Data_Event)
        self.Updata_Data_Event = nil
    end

    if self.Updata_My_Rank_Event then
        GlobalEvent:getInstance():UnBind(self.Updata_My_Rank_Event)
        self.Updata_My_Rank_Event = nil
    end
    
    if self.item_list then
        for i, v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
end
