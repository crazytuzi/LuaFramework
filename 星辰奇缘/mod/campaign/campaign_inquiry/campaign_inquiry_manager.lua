-- @author xhs(功能预告)
-- @date 2017年11月20日
CampaignInquiryManager = CampaignInquiryManager or BaseClass(BaseManager)

function CampaignInquiryManager:__init()
    if CampaignInquiryManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    CampaignInquiryManager.Instance = self
    self.model = CampaignInquiryModel.New()
    self.isRed = false
    self.currentQuest = nil
    self.questOver = nil
    self:InitHandler()
    self.onGetData = EventLib.New()
    self.onGetRate = EventLib.New()
    self.onReply = EventLib.New()
    self.getQuestStatus = EventLib.New()
    self.questChange = EventLib.New()
    self.clueStart = 1

end


function CampaignInquiryManager:RequestInitData()
    self:Send10200()
    self:Send20600()
end


function CampaignInquiryManager:InitHandler()
    self:AddNetHandler(20600, self.On20600)
    self:AddNetHandler(20601, self.On20601)
    self:AddNetHandler(20602, self.On20602)
    self:AddNetHandler(20603, self.On20603)
    self:AddNetHandler(10200, self.On10200)
end

function CampaignInquiryManager:__delete()

end


function CampaignInquiryManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function CampaignInquiryManager:OpenSelectWindow(args)
    self.model:OpenSelectWindow(args)
end

function CampaignInquiryManager:CloseWindow()
    self.model:CloseWindow()
end


function CampaignInquiryManager:CloseSelectWindow()
    self.model:CloseSelectWindow()
end



function CampaignInquiryManager:Send20600()
    Connection.Instance:send(20600)
    -- print("发送20600")
end


function CampaignInquiryManager:On20600(data)
    -- BaseUtils.dump(data,"20600")
    self.onGetData:Fire(data)
    self:CheckRed(data)
end


function CampaignInquiryManager:Send20601(data)
    Connection.Instance:send(20601,{inquiry_id = data.inquiry_id , answer = data.answer})
end


function CampaignInquiryManager:On20601(data)
    -- BaseUtils.dump(data, "答题返回")
    self.onReply:Fire(data)
end

function CampaignInquiryManager:Send20602(data)
    Connection.Instance:send(20602,{inquiry_id = data})
    -- print("发送20602"..data)
end


function CampaignInquiryManager:On20602(data)

    self.onGetRate:Fire(data)
end

function CampaignInquiryManager:Send20603(data)
    Connection.Instance:send(20603,{inquiry_id = data})
    -- print("发送20603"..data)
end


function CampaignInquiryManager:On20603(data)
    -- BaseUtils.dump(data)
end

function CampaignInquiryManager:Send10200()
    Connection.Instance:send(10200)
end

function CampaignInquiryManager:On10200(data)
    self:RefreshQuest(data)
end


function CampaignInquiryManager:RefreshQuest(data)

    local t = false

    local val = 0
    local target_val = 0
    local temp = DataCampInquiry.data_clue_info
    for k,v in pairs(data.quest_list) do
        for k,vv in pairs(DataCampInquiry.data_clue_info) do
            if vv.quest_id == v.id then
                t = true
                self.currentQuest = v.id
                self.currentclue = vv.id
                val = v.progress[1].value
                target_val = v.progress[1].target_val
                if val == target_val then
                    self.questOver = true
                else
                    self.questOver = false
                end
            end
        end
    end
    if t == true then
        self.getQuestStatus:Fire({questOver = self.questOver ,val = val,target_val = target_val})
        self:CheckRed()
    end
end

function CampaignInquiryManager:CheckRed(data)
    --print("------------------------------------执行了红点")

    if RoleManager.Instance.RoleData.lev < 30 then
        return
    end


    self.isRed = false
    if self.questOver == true then
        self.isRed = true
    end

    if data ~= nil and data.camp_inquiry[1] ~= nil then
        for k,v in pairs(data.camp_inquiry[1].clue_list) do
            if v.status == 3 then
                --if v.answer == DataQuestion.inquiry_questionGetFunc(DataCampInquiry.data_clue_info[v.id].question_id).answer then
                    self.isRed = true
                --end
            end
        end
    end
    -- print(self.isRed)
    -- CampaignManager.Instance.model:CheckRed(805)
    self.questChange:Fire()

end