---
--- Created by  Administrator
--- DateTime: 2020/2/10 14:57
---
require("game.otherwelfare.RequireOtherWelfare")
OtherWelfareController = OtherWelfareController or class("OtherWelfareController", BaseController)
local OtherWelfareController = OtherWelfareController

function OtherWelfareController:ctor()
    OtherWelfareController.Instance = self
    self.model = OtherWelfareModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function OtherWelfareController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end


function OtherWelfareController:GameStart()
    local function step1()
        WelfareController:GetInstance():ReqeustMiscInfo()
    end
   GlobalSchedule:StartOnce(step1, Constant.GameStartReqLevel.Low)




   -- GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "sevenDay", true)

end

function OtherWelfareController:GetInstance()
    if not OtherWelfareController.Instance then
        OtherWelfareController.new()
    end
    return OtherWelfareController.Instance
end

function OtherWelfareController:AddEvents()
    local function call_back(code)
        self.model.emailBindState = code
    end
    GlobalEvent:AddListener(EventName.BindEmailState, call_back)
    
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(OtherWelfareComPanel):Open()
    end
    GlobalEvent:AddListener(OtherWelfareEvent.OpenRatingPanel, call_back)

    local function call_back()
       -- logError("绑定状态"..self.model.emailBindState)
       -- if self.model.emailBindState == 0 and self.model.miscInfo[4].is_get == false then
            lua_panelMgr:GetPanelOrCreate(OtherWelfareBindPanel):Open()
      --  end

    end
    GlobalEvent:AddListener(OtherWelfareEvent.OpenBindPanel, call_back)


    local function call_back()
        lua_panelMgr:GetPanelOrCreate(OtherWelfareSharePanel):Open()
    end
    GlobalEvent:AddListener(OtherWelfareEvent.OpenSharePanel, call_back)
    local function call_back(lv)
        if lv < OtherWelfareModel.openRatingLV then
            return
        end
        if lv == OtherWelfareModel.openRatingLV then
            if self.model.miscInfo[1] and self.model.miscInfo[1].is_open == true and self.model.miscInfo[1].is_get == false then
                GlobalEvent:Brocast(OtherWelfareEvent.OpenRatingPanel)
                GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "Rating", true)
            else
                GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "Rating", false)
            end
        end

    end
    RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", call_back)

    local function call_back()
        Notify.ShowText("Bound")
        --logError("綁定成功")
        self.model.emailBindState = 1
        --WelfareController:GetInstance():ReqeustMiscRewardInfo(4)
    end
    GlobalEvent:AddListener(EventName.BindEmailInfo,call_back)


    local function call_back()
        Notify.ShowText("Shared!")
        --logError("分享成功")
        WelfareController:GetInstance():ReqeustMiscRewardInfo(2)
    end
    GlobalEvent:AddListener(EventName.FbShareInfo,call_back)

    local function call_back()
        Notify.ShowText("Liked!")
        --logError("點贊成功")
        WelfareController:GetInstance():ReqeustMiscRewardInfo(3)
    end
    GlobalEvent:AddListener(EventName.DianZanInfo,call_back)

    --local function call_back()
    --
    --end
    --GlobalEvent:AddListener(OtherWelfareEvent.OpenOtherWelSubPanel,call_back)

end

function OtherWelfareController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
end

