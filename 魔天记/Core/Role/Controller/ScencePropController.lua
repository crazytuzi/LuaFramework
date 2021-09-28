require "Core.Role.Controller.AbsController";

require "Core.Role.ModelCreater.ScencePropModelCreater"

local ScenePropAction = require "Core.Role.Action.SceneProp.ScenePropAction"
local ScenePropTabooAction = require "Core.Role.Action.SceneProp.ScenePropTabooAction"
local ScenePropBaoXianAction = require "Core.Role.Action.SceneProp.ScenePropBaoXianAction"

--[[
 场景物品控制器  （条件出现，可点击,不可移动）

 资源路径 Assets\Roles\SceneProp\sprop_id\
 预设路径  Assets\Resources\Roles\sprop_id
]]

ScencePropController = class("ScencePropController", AbsController);

ScencePropController.CLICK_FUN_ID_0 = 0;
ScencePropController.CLICK_FUN_ID_1 = 1; -- 测试接口
ScencePropController.CLICK_FUN_ID_2 = 2
ScencePropController.CLICK_FUN_ID_3 = 3


function ScencePropController:New(prop_data)
    self = { };
    setmetatable(self, { __index = ScencePropController });
    self.roleType = ControllerType.SCENEPROP;
    self.id = prop_data.id;
    self:_Init(prop_data);
    self._blDie = false;

    return self;
end

function ScencePropController:_Init(prop_data)
    self.info = prop_data;
    self:_InitEntity(EntityNamePrefix.SCENEPROP .. self.info.id);
    self:SetLayer(Layer.NPC);
end
function ScencePropController:CheckLoadModel()
    if self._roleCreater or self._dispose then return end
    self:_LoadModel(ScencePropModelCreater)
end

function ScencePropController:_LoadModel(creater)
    local roleCreate = creater:New(self.info, self.transform, true, function(val) self:_OnLoadModelSource(val) end)
    self._roleCreater = roleCreate
end
function ScencePropController:_OnLoadModelSource(model)
	if model then model:SetScale(self.info.model_rate) end
end

function ScencePropController:_GetModern()
    return "Roles/SceneProp", self.info.model_id;
end

function ScencePropController:IsDie()
    return self._blDie;
end

function ScencePropController:Start()
    local a
    if self.info.click_fun_id == ScencePropController.CLICK_FUN_ID_2 then
        a = ScenePropTabooAction:New()
    elseif self.info.click_fun_id == ScencePropController.CLICK_FUN_ID_3 then
        a = ScenePropBaoXianAction:New()
    else
        a = ScenePropAction:New()
    end
    if (self:_CanDoAction()) then
        self:DoAction(a)
    end
end


function ScencePropController:_DisposeHandler()
    if not IsNil(self.gameObject) then GameObject.Destroy(self.gameObject) end
end
