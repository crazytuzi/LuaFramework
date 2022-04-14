-- 
-- @Author: LaoY
-- @Date:   2018-08-15 15:26:01
-- 
MainUIView = MainUIView or class("MainUIView", BasePanel)
local this = MainUIView

function MainUIView:ctor()
    self.abName = "main"
    self.assetName = "MainUIView"
    self.layer = "Bottom"

    self.use_background = false
    self.change_scene_close = false
    self.use_open_sound = false
    
    self.award_item_list = {}

    self.model = MainModel:GetInstance();

    self.award_list = list()


    self.global_event_list = {}
    self.model_event_list = {}
end

function MainUIView:dctor()
    self:RemoveFlyAction()

    self:RemoveBloodEffect()

    if self.event_id_1 then
        GlobalEvent:RemoveListener(self.event_id_1)
        self.event_id_1 = nil
    end

    if self.event_id_2  then
        GlobalEvent:RemoveListener(self.event_id_2)
        self.event_id_2 = nil
    end

    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end

    if self.model_event_list then
        self.model:RemoveTabListener(self.model_event_list)
        self.model_event_list = {}
    end

    if self.role_update_list and self.role_data then
        for k, event_id in pairs(self.role_update_list) do
            self.role_data:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end

    self:StopTime()
    self.award_list:clear()
    
    if self.auto_fight_effect then
        self.auto_fight_effect:destroy()
        self.auto_fight_effect = nil
    end

    if self.auto_move_effect then
        self.auto_move_effect:destroy()
        self.auto_move_effect = nil
    end

    if self.main_debug_attr then
        self.main_debug_attr:destroy()
        self.main_debug_attr = nil
    end

    if self.main_top_left then
        self.main_top_left:destroy()
        self.main_top_left = nil
    end

    if self.main_middle_left then
        self.main_middle_left:destroy()
        self.main_middle_left = nil
    end

    if self.main_top_right then
        self.main_top_right:destroy()
        self.main_top_right = nil
    end

    if self.main_bottom then
        self.main_bottom:destroy()
        self.main_bottom = nil
    end

    if self.main_bottom then
        self.main_bottom:destroy()
        self.main_bottom = nil
    end

    if self.main_bottom_left then
        self.main_bottom_left:destroy()
        self.main_bottom_left = nil
    end

    if self.main_bottom_right then
        self.main_bottom_right:destroy()
        self.main_bottom_right = nil
    end
end

function MainUIView:Open()
    MainUIView.super.Open(self)
end

function MainUIView:LoadCallBack()
    self.transform:SetAsFirstSibling()
    if AppConfig.Debug then
        self.main_debug_attr = DebugAttr(self.transform)
        SetAlignType(self.main_debug_attr, bit.bor(AlignType.Left, AlignType.Null))
    end

    self.main_top_left = MainTopLeft(self.transform)
    self.main_middle_left = MainMiddleLeft(self.transform)
    self.main_top_right = MainTopRight(self.transform)

    self.main_bottom = MainUIBottom(self.transform)
    self.main_bottom_left = MainUIBottomLeft(self.transform)
    self.main_bottom_right = MainBottomRight(self.transform)
	
	
	

    SetAlignType(self.main_top_left, bit.bor(AlignType.Left, AlignType.Top))
    SetAlignType(self.main_middle_left, bit.bor(AlignType.Left, AlignType.Null))
    SetAlignType(self.main_top_right, bit.bor(AlignType.Right, AlignType.Top))

    SetAlignType(self.main_bottom_right, bit.bor(AlignType.Right, AlignType.Bottom))
    SetAlignType(self.main_bottom, bit.bor(AlignType.Null, AlignType.Bottom))
    SetAlignType(self.main_bottom_left, bit.bor(AlignType.Left, AlignType.Bottom))

	
	self.main_top_left:SetVisible(not PeakArenaModel:GetInstance():Is1v1Fight())
	self.main_middle_left:SetVisible(not PeakArenaModel:GetInstance():Is1v1Fight())
	self.main_top_right:SetVisible(not PeakArenaModel:GetInstance():Is1v1Fight())
	--SetVisible(self.main_top_left,PeakArenaModel:GetInstance():Is1v1Fight())
	--SetVisible(self.main_middle_left,PeakArenaModel:GetInstance():Is1v1Fight())
	--SetVisible(self.main_top_right,PeakArenaModel:GetInstance():Is1v1Fight())
	
    self:SetMiddleLeftVisibel()

    self:AddEvent()
        
    self:checkAdaptUI()
end


function MainUIView:checkAdaptUI()
    
    UIAdaptManager:GetInstance():AdaptUIForBangScreenLeft(self.main_middle_left)
    UIAdaptManager:GetInstance():AdaptUIForBangScreenRight(self.main_bottom_right)
    UIAdaptManager:GetInstance():AdaptUIForBangScreenBottom(self.main_bottom)

end


function MainUIView:AddEvent()
    local function call_back(param)
        if type(param) == "table" then
            --[[
                @param  param
                @param1 coord   场景坐标
                @param2 id      物品id
                @param3 num     物品数量
            --]]
            --self:FlyAwardItem(param)            
        else
            local uid = param
            local drop = SceneManager:GetInstance():GetObject(uid)
            if not drop then
                return
            end
            local info = drop.object_info
            --self:FlyAwardItem(info)            
            SceneManager:GetInstance():RemoveObject(uid, true)
        end
    end
    self.event_id_1 = GlobalEvent:AddListener(FightEvent.AccPickUp, call_back)

    local function call_back(ids)
        if  ids then
           -- SceneManager:GetInstance():RemoveObjectList(ids)
            for i, id in pairs(ids) do
                SceneManager:GetInstance():RemoveObject(id, true,true)
            end
        end
    end
    self.event_id_2 = GlobalEvent:AddListener(FightEvent.AccAutoPickUp, call_back)

    local function call_back()
        local effect = UIEffect(self.transform, 10501, false)
        effect:SetOrderIndex(101)
        effect:SetPosition(0,250)
    end
    self.global_event_list[#self.global_event_list+1] = GlobalEvent:AddListener(TaskEvent.FinishTask, call_back)

    if DungeonCtrl:GetInstance().isExpDungeon then
        local call_back_dungeon = function()
            if self.main_middle_left.gameObject and self.main_top_right.gameObject then
                self:HideUIInExpDungeon(true);
                GlobalSchedule:Stop(self.dungeonSchedule);
            end
        end
        self.dungeonSchedule = GlobalSchedule:Start(call_back_dungeon, 0.1, 1)
    end


    local function call_back()
        self:SetMiddleLeftVisibel()
    end
    self.model_event_list[#self.model_event_list+1] = self.model:AddListener(MainEvent.UpdateMidLeftVisible, call_back)

    self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    self.role_update_list = {}

    local function call_back()
        self:UpdateHp()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("hp", call_back)
    local function call_back()
        self:UpdateHp()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("hpmax", call_back)

end

function MainUIView:UpdateHp()
    if not self.role_data or not self.role_data.attr or not self.role_data.hp or not self.role_data.hpmax or not self.is_loaded then
        return
    end
    local value = self.role_data.hp / self.role_data.hpmax
    if value <= 0.1 and value > 0 then
        self:LoadBloodEffect()
    else
        self:RemoveBloodEffect()
    end
end

function MainUIView:LoadBloodEffect()
    if not self.blood_effect then
        self.blood_effect = UIEffect(self.transform, 10103, false)
        local scale_x = ScreenWidth/512
        local scale_y = ScreenHeight/256
        local config = {scale = Vector3(scale_x,scale_y,1)}
        self.blood_effect:SetConfig(config)
        self.blood_effect:SetOrderIndex(100)
    end
end

function MainUIView:RemoveBloodEffect()
    if self.blood_effect then
        self.blood_effect:destroy()
        self.blood_effect = nil
    end
end

function MainUIView:OpenCallBack()
    self:UpdateView()
end

function MainUIView:AddFlyAward(info)
    self.text_list:push(info)
    self:StartTime()
end

function MainUIView:StartTime()
    if self.time_id then
        return
    end
    local function step()
        if self.goods_cache_list.length <= 0 then
            return
        end
        local info = self.goods_cache_list:shift()
        self:FlyAwardItem(info)
    end
    self.time_id = GlobalSchedule:Start(step,0.1)
end

function MainUIView:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
    end
end

function MainUIView:FlyAwardItem(object_info)
    if not object_info then
        return
    end
    local award_item = AwardItem(self.transform)

    local size = LayerManager:GetInstance():GetUiCameraSize()
    size = { width = Screen.height, height = Screen.width }
    self.award_item_list[award_item] = true
    local x = object_info.coord.x
    local y = object_info.coord.y
    local start_vec = LayerManager:GetInstance():SceneWorldToScreenPoint(x / SceneConstant.PixelsPerUnit, y / SceneConstant.PixelsPerUnit)
    start_vec = LayerManager:GetInstance():UIViewportToWorldPoint(start_vec.x / SceneConstant.PixelsPerUnit, start_vec.y / SceneConstant.PixelsPerUnit)

    award_item:SetPosition(start_vec.x, start_vec.y)
    award_item:SetData(object_info.id, object_info.num)
    local bag = self.main_bottom_right:GetBagTransform()
    if not bag then
        return
    end
    local bag_x, bag_y = GetParentPosition(bag, self.transform)
    local end_vec = Vector2(bag_x, bag_y)

    local action = cc.MoveTo(0.2, start_vec.x, start_vec.y + 200, 0)
    action = cc.Sequence(action, cc.MoveTo(1.0, end_vec.x, end_vec.y, 0))
    local function end_call_back()
        award_item:destroy()
        self.award_item_list[award_item] = nil
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(award_item.transform)
    end
    local call_action = cc.CallFunc(end_call_back)
    action = cc.Sequence(action, call_action)
    cc.ActionManager:GetInstance():addAction(action, award_item.transform)
end

function MainUIView:RemoveFlyAction()
    for award_item, v in pairs(self.award_item_list) do
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(award_item.transform)
    end
    self.award_item_list = {}
end

function MainUIView:UpdateView()
    self:UpdateHp()
end

function MainUIView:CloseCallBack()

end

function MainUIView:HideUIInExpDungeon(bool)
    bool = bool or false
    if self.main_middle_left then
        self.main_middle_left.gameObject:SetActive(not bool);

    end

    if self.main_top_right then
        --self.main_top_right.gameObject:SetActive(not bool);
    end
end

function MainUIView:SetMiddleLeftVisibel()
    local is_boss = self.model.middle_left_bit_state:Contain(MainModel.MiddleLeftBitState.Boss)
    local is_dunge_boss = self.model.middle_left_bit_state:Contain(MainModel.MiddleLeftBitState.DungeonBoss)
    local flag =  self.model.middle_left_bit_state.value <= 0 or is_boss
    if self.main_middle_left then
        self.main_middle_left:SetVisible(flag)
        self.main_middle_left:UpdateBossInfo(is_boss , is_dunge_boss)
    end
end