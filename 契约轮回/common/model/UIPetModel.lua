---
--- Created by R2D2.
--- DateTime: 2019/4/4 10:27
---
UIPetModel = UIPetModel or class("UIPetModel", UIModel)
local UIPetModel = UIPetModel

function UIPetModel:ctor(parent, petId, load_callback, isIdle)

    if isIdle == nil then
        self.isIdle = true
    else
        self.isIdle = isIdle
    end

    self:LoadModel(petId, load_callback)
end

function UIPetModel:dctor()

end

function UIPetModel:ReLoadData(petId, call_back)
    self:LoadModel(petId, call_back)
end

function UIPetModel:LoadModel(petId, call_back)
    self.abName = "model_pet_" .. petId
    self.assetName = "model_pet_" .. petId
    self.load_call_back = call_back

    if(self.isLoading) then
        self.waitLoading = true
    else
        self.isLoading = true
        UIPetModel.super.Load(self)
    end
end


function UIPetModel:LoadCallBack()

    if (self.waitLoading) then
        self.waitLoading = false
        self.isLoading = true
        UIPetModel.super.Load(self)
        return
    else
        self.isLoading = false
    end

    if self.isIdle then
        self:AddAnimation({ "show", "idle" }, false, "idle", 0)
    end


    if self.load_call_back then
        self.load_call_back()
    end
end