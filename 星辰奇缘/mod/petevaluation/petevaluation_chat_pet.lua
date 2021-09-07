PetEvaluationChatExtPet = PetEvaluationChatExtPet or BaseClass(ChatExtPet)


function PetEvaluationChatExtPet:SetList(myList)
     self.myList = myList
     self.headLoaderList = {}

end

function PetEvaluationChatExtPet:__delete()
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
end

function PetEvaluationChatExtPet:Refresh(list)
    BaseUtils.dump(self.myList,"宠物列表")
    local count = 0
    for i,data in ipairs(self.myList) do
        count = i
        local tab = self.itemTab[i]
        if data.type == "Pet" then
            local pet = data.data
            tab["childData"] = nil
            tab["petData"] = pet
            tab["rideData"] = nil
            tab["nameTxt"].text = pet.base.name
            tab["levTxt"].text = string.format(TI18N("等级:%s"), pet.lev)
            local loaderId = tab["headImg"].gameObject:GetInstanceID()
            if self.headLoaderList[loaderId] == nil then
                self.headLoaderList[loaderId] = SingleIconLoader.New(tab["headImg"].gameObject)
            end
            self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,pet.base.head_id)
            -- tab["headImg"].sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(pet.base.head_id), tostring(pet.base.head_id))
            tab["match"] = string.format("%%[%s%%]", pet.base.name)
            tab["append"] = string.format("[%s]", pet.base.name)
            tab["send"] = string.format("{pet_2,%s}", pet.base.id)
        elseif data.type == "Ride" then
            local ride = BaseUtils.copytab(data.data)
            local baseData = ride.base
            -- if ride.transformation_id ~= nil and ride.transformation_id ~= 0 then
            --     baseData = DataMount.data_ride_data[ride.transformation_id]
            -- end
            tab["childData"] = nil
            tab["rideData"] = ride
            tab["petData"] = nil
            tab["nameTxt"].text = baseData.name
            tab["levTxt"].text = string.format(TI18N("等级:%s"), ride.lev)
            tab["headImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.headride, tostring(baseData.head_id))
            tab["match"] = string.format("%%[%s%%]", baseData.name)
            tab["append"] = string.format("[%s]", baseData.name)


            tab["send"] = string.format("{ride_2,%s}", baseData.base_id)
        elseif data.type == "Child" then
            local child = BaseUtils.copytab(data.data)
            local name = string.format(TI18N("%s的子女"), self:GetChildName(child))

            tab["childData"] = child
            tab["rideData"] = nil
            tab["petData"] = nil
            tab["nameTxt"].text = name
            tab["levTxt"].text = string.format(TI18N("等级:%s"), child.lev)
            tab["headImg"].sprite = self.mainPanel.assetWrapper:GetSprite(AssetConfig.childhead, string.format("%s%s", child.classes_type, child.sex))
            tab["match"] = string.format("%%[%s%%]", name)
            tab["append"] = string.format("[%s]", name)

            tab["send"] = string.format("{child_2,%s}", child.base_id)
        end
        tab["gameObject"]:SetActive(true)
    end
    -- 多出来的隐藏
    local allLen = #self.itemTab
    for i = count + 1, allLen do
        local tab = self.itemTab[i]
        tab["gameObject"]:SetActive(false)
    end
end