---
--- Created by  Administrator
--- DateTime: 2019/10/24 17:39
---
require('game.banner.RequireBanner')
BannerController = BannerController or class("BannerController", BaseController)
local BannerController = BannerController

function BannerController:ctor()
    BannerController.Instance = self
    self.model = BannerModel.GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()

end

function BannerController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function BannerController:GetInstance()
    if not BannerController.Instance then
        BannerController.new()
    end
    return BannerController.Instance
end

function BannerController:AddEvents()
    
   -- GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));


end

function BannerController:HandleSceneChange(sceneId)
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    if lv == 1 then
        -- lua_panelMgr:GetPanelOrCreate(BannerPanel):Open()
    end
end

function BannerController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
end

-- overwrite
function BannerController:GameStart()
    local function step()
        --local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        --if lv == 1 then
        --    lua_panelMgr:GetPanelOrCreate(BannerPanel):Open()
        --end
        local info = TaskModel:GetInstance():GetTask(self.model.taskId)
        if  info  and info.state == enum.TASK_STATE.TASK_STATE_FINISH then --完成
            -- lua_panelMgr:GetPanelOrCreate(BannerPanel):Open()
        end
        
        --logError(Table2String(info))

    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Low)
end