---
--- Created by  Administrator
--- DateTime: 2020/2/10 14:58
---
OtherWelfareModel = OtherWelfareModel or class("OtherWelfareModel", BaseModel)
local OtherWelfareModel = OtherWelfareModel

OtherWelfareModel.openRatingLV = 150 --評論開啟等級
function OtherWelfareModel:ctor()
    OtherWelfareModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function OtherWelfareModel:Reset()
    self.emailBindState = 0 --         --0未綁定  1已綁定
    self.miscInfo = {}
    self.redPoints = {}
end

function OtherWelfareModel:GetInstance()
    if OtherWelfareModel.Instance == nil then
        OtherWelfareModel()
    end
    return OtherWelfareModel.Instance
end

--	 type  1=評論; 2分享 3点赞 ; 4=綁定
--	 is_open
--	 is_get
function OtherWelfareModel:DealMiscInfo(data)

    --ffh 审核服屏蔽
    if LoginModel.IsIOSExamine then
        return
    end

    if not data  then
        return
    end
    local isOpenFb = falsea
    for i, v in pairs(data.welfares) do
        self.miscInfo[v.type] = v
    end
    local lv = RoleInfoModel:GetInstance():GetMainRoleLevel() or 0
    --評論
    if self.miscInfo[1].is_open and self.miscInfo[1].is_get == false and lv >= OtherWelfareModel.openRatingLV   then
        GlobalEvent:Brocast(OtherWelfareEvent.OpenRatingPanel)
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "Rating", true)
    else
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "Rating", false)
    end
    local isShow = self.miscInfo[4].is_open or self.miscInfo[2].is_open or self.miscInfo[3].is_open

    if self.miscInfo[4].is_open and self.miscInfo[4].is_get == false then
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "bind",true)
    else
        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "bind", false)
    end


    

    GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "Share", self.miscInfo[2].is_open or self.miscInfo[3].is_open)


    --if self.emailBindState == 0 then --未綁定
    --    if self.miscInfo[3].is_open and self.miscInfo[3].is_get == false then
    --        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "otherWelfare", true)
    --    else
    --        GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "otherWelfare", false)
    --    end
    --else --已經綁定
    --
    --end
    --- PlatformManager:GetInstance():TakePhoto(type,file_name,width,height,quality)
    
end

function OtherWelfareModel:SetRewardState(data)
    local mType = data.type
    if self.miscInfo[mType] then
        self.miscInfo[mType].is_get = true
    end
end

function OtherWelfareModel:GetRewardCfg(type)
    local cfg = Config.db_game["welfare_misc"]
    if not cfg then
        return nil
    end
    local rewardTab = String2Table(cfg.val)[1]
    if not rewardTab then
        return nil
    end
    for i = 1, #rewardTab do
        if type == rewardTab[i][1] then
            return rewardTab[i][2]
        end
    end
    return nil
end


function OtherWelfareModel:CheckRedPoint()

    local lv = RoleInfoModel:GetInstance():GetMainRoleLevel() or 0
    --評論

    self.redPoints[1] = false --綁定
    self.redPoints[2] = false -- 評論
    self.redPoints[3] = false; --點贊 分享
    if self.miscInfo[1].is_open and self.miscInfo[1].is_get == false and lv >= OtherWelfareModel.openRatingLV then
        self.redPoints[2] = true
    end
    if self.miscInfo[4].is_open and self.miscInfo[4].is_get == false  then
        self.redPoints[1] = true
    --else
    --    if self.miscInfo[2].is_open and self.miscInfo[2].is_get == false  then
    --        self.redPoints[1] = true
    --    end
    --    if self.miscInfo[3].is_open and self.miscInfo[3].is_get == false  then
    --        self.redPoints[1] = true
    --    end
    end

        if self.miscInfo[2].is_open and self.miscInfo[2].is_get == false  then
            self.redPoints[3] = true
        end
        if self.miscInfo[3].is_open and self.miscInfo[3].is_get == false  then
            self.redPoints[3] = true
        end

    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "Rating", self.redPoints[2])
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "Share", self.redPoints[3])
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "bind", self.redPoints[1])
end