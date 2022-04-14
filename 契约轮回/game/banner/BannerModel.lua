---
--- Created by  Administrator
--- DateTime: 2019/10/24 17:39
---
BannerModel = BannerModel or class("BannerModel", BaseModel)
local BannerModel = BannerModel

BannerModel.taskId = 10000
function BannerModel:ctor()
    BannerModel.Instance = self
end

--- 初始化或重置
function BannerModel:Reset()

end

function BannerModel:GetInstance()
    if BannerModel.Instance == nil then
        BannerModel()
    end
    return BannerModel.Instance
end