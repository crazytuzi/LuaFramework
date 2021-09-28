require "Core.Role.AI.AbsAiController";
require "Core.Manager.Item.AutoFightManager"

AutoRestoreController = class("AutoRestoreController", AbsAiController)

function AutoRestoreController:New(role)
    self = { };
    setmetatable(self, { __index = AutoRestoreController });
    self:_Init(role);
    self:_AddListener();
    self:Pause();
    return self;
end


function AutoRestoreController:_DisposeHandler()
    self:_RemoveListener();
end

function AutoRestoreController:Start()
    if (self._timer == nil) then
        self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, 2, -1, false);
        self._timer:Start();
    end

    self.needBuyType = 0;
    if (self._checkBuyDrugtimer == nil) then
        self._checkBuyDrugtimer = Timer.New( function(val) self:_TryCheckToBuyDrug(val) end, 40, -1, false);
        self._checkBuyDrugtimer:Start();
    end

end

-- 停止
function AutoRestoreController:Stop()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end

    if (self._checkBuyDrugtimer) then
        self._checkBuyDrugtimer:Stop();
        self._checkBuyDrugtimer = nil;
    end

    self:_OnStopHandler()
end

function AutoRestoreController:_OnStopHandler()
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end

    if (self._checkBuyDrugtimer) then
        self._checkBuyDrugtimer:Stop();
        self._checkBuyDrugtimer = nil;
    end

end

function AutoRestoreController:_AddListener()
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, self._SceneStartHandler, self);
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_END, self._SceneEndHandler, self);
end

function AutoRestoreController:_RemoveListener()
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, self._SceneStartHandler, self);
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_END, self._SceneEndHandler, self);
end

function AutoRestoreController:_SceneStartHandler()
    self:Resume();
end

function AutoRestoreController:_SceneEndHandler()
    self:Pause();
end


function AutoRestoreController:_TryCheckToBuyDrug()

    if (not self.isPause) then

        self:_OnTimerHandler();
        if self.needBuyType ~= 0 then
            local heroCtr = PlayerManager.hero;
            if heroCtr ~= nil then
                if self.needBuyType == 1 then
                    AutoFightAiController.TryShowuse_DrugBuy("use_Drug_HP_id", true);
                elseif self.needBuyType == 2 then
                    AutoFightAiController.TryShowuse_DrugBuy("use_Drug_MP_id", true);
                end

            end
        end
    end

end



function AutoRestoreController:_CheckHP(role)
    local hp_pc = role.info.hp / role.info.hp_max;
    if (hp_pc < AutoFightManager.restoreHP) then
        local _cd = BackPackCDData.GetCDByTK(4, 1);
        if _cd == 0 then
            --  使用 指定 药品
            if AutoFightManager.use_Drug_HP_id ~= nil then
                local pb_item = BackpackDataManager.GetProductBySpid(AutoFightManager.use_Drug_HP_id);
                if pb_item ~= nil then
                    ProductTipProxy.TryUseProduct(pb_item, 1);
                    return true;
                else
                    -- 到这里就是说明没药吃
                    self.needBuyType = 1;
                end
            end
            --[[
            local res = BackpackDataManager.GetProductsByTypes2(4, 1);
            if (res[1]) then
                ProductTipProxy.TryUseProduct(res[1]);
                return true;
            end
            ]]
        end
    end
    return false;
end

function AutoRestoreController:_CheckMP(role)
    if (role.info.mp / role.info.mp_max < AutoFightManager.restoreMP) then
        local _cd = BackPackCDData.GetCDByTK(4, 2);
        if _cd == 0 then

            --  使用 指定 药品
            if AutoFightManager.use_Drug_MP_id ~= nil then
                local pb_item = BackpackDataManager.GetProductBySpid(AutoFightManager.use_Drug_MP_id);
                if pb_item ~= nil then
                    ProductTipProxy.TryUseProduct(pb_item, 1);
                    return true;

                else
                    -- 到这里就是说明没药吃
                    self.needBuyType = 2;

                end
            end

            --[[

            local res = BackpackDataManager.GetProductsByTypes2(4, 2);
            if (res[1]) then
                ProductTipProxy.TryUseProduct(res[1]);
                return true;
            end
            ]]
        end
    end
    return false;
end

function AutoRestoreController:_OnTimerHandler()
    local role = self._role;
    if (role and role.transform and(not role:IsDie())) then
        self.needBuyType = 0;
        if (not self:_CheckHP(role)) then
            self:_CheckMP(role)
        end
    end
end