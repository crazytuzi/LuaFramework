ShenShouHuanlingView = ShenShouHuanlingView or BaseClass(BaseRender)

function ShenShouHuanlingView:__init(instance, mother_view)
	self.is_cancel = false
    self.is_flush = false
    self.is_moving = false
	self.data = ShenShouData.Instance
	self:ListenEvent("OnClickDraw", BindTool.Bind(self.ClickDraw, self))
    self:ListenEvent("OnClickFlush", BindTool.Bind(self.ClickFlush, self))
    self:ListenEvent("ClickCancle", BindTool.Bind(self.ClickCancel, self))

    self.cell_list = {}
    for i = 1, GameEnum.SHENSHOU_MAX_RERFESH_ITEM_COUNT do
        self.cell_list[i] = DrawHuanLingItem.New(self:FindObj("item" .. i))
    end
    self.select_effect = self:FindObj("SelectEffect")

    self.all_score = self:FindVariable("all_score")
    self.cur_draw_times = self:FindVariable("cur_draw_times")
    self.spend_huanling = self:FindVariable("spend_huanling")
    self.spend_flush = self:FindVariable("spend_flush")
    self.get_draw_times = self:FindVariable("get_draw_times")
    self.in_anim_value = self:FindVariable("InAnim")
end

function ShenShouHuanlingView:__delete()
    self.data = nil
	self.all_score = nil
	self.cur_draw_times = nil
	self.spend_huanling = nil
	self.spend_flush = nil
	self.get_draw_times = nil
	self.in_anim_value = nil
	 self.select_effect = nil
	for k, v in pairs(self.cell_list) do
        if v then
            v:DeleteMe()
        end
    end
    self.cell_list = nil
end

function ShenShouHuanlingView:OpenCallBack()
	self.in_anim_value:SetValue(true)
    self:Flush()
	self:InitData()
end

function ShenShouHuanlingView:CloseCallBack()
	 if nil ~= self.rotate_timer then
        GlobalTimerQuest:CancelQuest(self.rotate_timer)
        ShenShouData.Instance:StartFloatingLabel()
    end
end

function ShenShouHuanlingView:OnFlush(param_t)
	local score = self.data:GetHuanLingScore()
	local huanling_draw_limit = self.data:GetHuanLingDrawLimit()
	local huanling_refresh_consume = self.data:GetHuanLingRefreshConsume()
	local huanling_get_draw = self.data:GetHuanLingDrawTime()
	local spend_score = self.data:GetHuanLingConsume(huanling_get_draw)
	self.all_score:SetValue(score)
	self.cur_draw_times:SetValue(huanling_draw_limit)
	self.get_draw_times:SetValue(huanling_get_draw)
    self.spend_flush:SetValue(huanling_get_draw < huanling_draw_limit and string.format(Language.ShenShou.SpendScore, huanling_refresh_consume) or Language.ShenShou.FreeFlush)
	self.spend_huanling:SetValue(string.format(Language.ShenShou.SpendScore, spend_score))

    if self.is_flush then
       self:InitData()
       self.is_flush = false
    end
    if self.is_cancel then
       self:InitData()
    end
end

function ShenShouHuanlingView:ClickCancel()
    self.is_cancel = not self.is_cancel
end

function ShenShouHuanlingView:ClickFlush()
    if self.is_moving == true then 
        SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.WaitFlushDone)
        return
    end
	ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_HUANLING_REFRESH)
    self.is_flush = true
end

function ShenShouHuanlingView:ClickDraw()
    local huanling_draw_limit = self.data:GetHuanLingDrawLimit()
    local huanling_get_draw = self.data:GetHuanLingDrawTime()
    if huanling_get_draw < huanling_draw_limit then
	   ShenShouCtrl.Instance:SendShenshouOperaReq(SHENSHOU_REQ_TYPE.SHENSHOU_REQ_TYPE_HUANLING_DRAW)
    else
        SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.FlushReward)
    end
end

function ShenShouHuanlingView:InitData()
	ShenShouData.Instance:StartFloatingLabel()
    self:SetDataView()
    self.in_anim_value:SetValue(true)
end

function ShenShouHuanlingView:SetDataView()
    local data = self.data:GetHuanLingList()

    if data and self.cell_list then
        for k, v in pairs(self.cell_list) do
            v:SetData(data[k])
        end
    end
end

function ShenShouHuanlingView:FlushAnimation()
    self.select_effect.gameObject:SetActive(true)
    local index = self.now_index or 1
    local speed_index = index
    local result_index = self.data:GetResultIndex()
    if self.is_cancel then
        if nil == self.cell_list[result_index] then return end
        local posx = self.cell_list[result_index].root_node.transform.position.x
        local posy = self.cell_list[result_index].root_node.transform.position.y
        local posz = self.cell_list[result_index].root_node.transform.position.z
        self.select_effect.transform.position = Vector3(posx, posy, posz)
        self.now_index = result_index

        if nil ~= self.rotate_timer then
            GlobalTimerQuest:CancelQuest(self.rotate_timer)
            self.is_moving = false
        end
        self:InitData()
        return
    else
        local loop_num = GameMath.Rand(2, 3)
        self.move_motion = function ()
            self.is_moving = true
            local quest = self.rotate_timer
            local quest_list = GlobalTimerQuest:GetRunQuest(quest)
            if nil == quest or nil == quest_list then return end
            if index == (loop_num * 14) + result_index then
                if nil == self.cell_list[result_index] then return end
                local posx = self.cell_list[result_index].root_node.transform.position.x
                local posy = self.cell_list[result_index].root_node.transform.position.y
                local posz = self.cell_list[result_index].root_node.transform.position.z
                self.select_effect.transform.position = Vector3(posx, posy, posz)
                self.now_index = result_index

                if nil ~= self.rotate_timer then
                    GlobalTimerQuest:CancelQuest(self.rotate_timer)
                    self.is_moving = false
                end
                 self:InitData()
                return
            else
            	self.in_anim_value:SetValue(false) 
                local read_index = ((index + 1) == 14 and 14) or ((index + 1) % 14 == 0 and 14) or ((index + 1) % 14)
                local posx = self.cell_list[read_index].root_node.transform.position.x
                local posy = self.cell_list[read_index].root_node.transform.position.y
                local posz = self.cell_list[read_index].root_node.transform.position.z
                self.select_effect.transform.position = Vector3(posx, posy, posz)
                -- 速度限制
                if index < speed_index + 3 then
                    quest_list[2] = 0.25 -- 0.1 0.25 0.1 0.08
                elseif speed_index + 3 <= index and index <= speed_index + 6 then
                    quest_list[2] = 0.1
                elseif index > ((loop_num * 14) + result_index) - 5 then
                    quest_list[2] = 0.2
                    if index > ((loop_num * 14) + result_index) - 2 then
                        quest_list[2] = 0.3
                    end
                else
                    quest_list[2] = 0.08
                end
                index = index + 1
            end
        end

        if nil ~= self.rotate_timer then
            GlobalTimerQuest:CancelQuest(self.rotate_timer)
        end
        self.rotate_timer = GlobalTimerQuest:AddRunQuest(self.move_motion, 0.1)
    end
end

------------------------------DrawHuanLingItem-------------------------------
DrawHuanLingItem = DrawHuanLingItem or BaseClass(BaseRender)

function DrawHuanLingItem:__init()
    self.item_name = self:FindVariable("item_name")
    self.show_get = self:FindVariable("show_get")

    self.item = self:FindObj("Item")
    self.item_cell = ItemCell.New()
    self.item_cell:SetInstanceParent(self.item)
end

function DrawHuanLingItem:__delete()
    if self.item_cell then
        self.item_cell:DeleteMe()
    end
end


function DrawHuanLingItem:SetData(data)
    local name = ItemData.Instance:GetItemName(data.item.item_id)
    self.item_cell:SetData(data.item)
    self.item_name:SetValue(name)
    if tonumber(data.draw) == 0 then
        self:ShowGet(false)
    else 
        self:ShowGet(true)
    end
end

function DrawHuanLingItem:ShowGet(enable)
    self.show_get:SetValue(enable)
end