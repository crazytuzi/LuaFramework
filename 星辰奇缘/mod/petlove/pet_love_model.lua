PetLoveModel = PetLoveModel or BaseClass(BaseModel)

function PetLoveModel:__init()
    self.pet_love_panel = nil
    self.pet_love_status_data = nil
    self.act_data = nil
    self.TimeoutClose = 0
    self.has_sign = 1
    self.cur_pet_base_id = 0
end


function PetLoveModel:__delete()

end

 --打开宠物情愿对话界面
function PetLoveModel:InitTalkUI(touchNpcData)
    self.touchNpcData = touchNpcData
    if self.pet_love_panel == nil then
        self.pet_love_panel = PetLoveTalkPanel.New(self)
    else
        self.pet_love_panel:update_info()
    end
    self.pet_love_panel:Show()
end

function PetLoveModel:CloseTalkUI()
    if self.pet_love_panel ~= nil then
        self.pet_love_panel:Hiden()
    end
end


function PetLoveModel:ButtonAction(action)
    if action == DialogEumn.ActionType.action4 then
        if self.pet_love_panel ~= nil then
            self.pet_love_panel:switchCon()
        end
    elseif action == DialogEumn.ActionType.action38 then
        PetLoveManager.Instance:request15610()
    end
end

-----------------------------从配置里面取出完整数据
--传入baseid获取宠物数据
function PetLoveModel:get_pet_cfg_data(base_id)
    for k, v in pairs(DataMeetPet.data_pet_list) do
        if v.pet_unit_id == base_id then
            return v
        end
    end
end