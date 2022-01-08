--[[
    正品菊花
    前提：假设除战斗场景外，只能存在一个场景，即当前最多只能存在一个“非战斗”场景和一个“战斗场景，
    当不满足条件时，此类不可用

    --By: haidong.gan
    --2013/11/11
]]
local LoadingLayer = class("LoadingLayer", BaseLayer)

CREATE_PANEL_FUN(LoadingLayer)


function LoadingLayer:ctor(data)
    self.super.ctor(self,data)
end

function LoadingLayer:setType(showType)
    local blockUI = TFPanel:create();
    blockUI:setSize(CCSize(30000,30000));
    blockUI:setPosition(ccp(-15000,-15000));
    blockUI:setTouchEnabled(true);
    self:addLayer(blockUI);
    local skillEff = nil;
   if showType == 1 then
        ModelManager:addResourceFromFile(2, "loading_simple", 1)
        skillEff = ModelManager:createResource(2, "loading_simple")
    else 
        ModelManager:addResourceFromFile(2, "loading", 1)
        skillEff = ModelManager:createResource(2, "loading")

        blockUI:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID);
        blockUI:setBackGroundColorOpacity(178);
        blockUI:setBackGroundColor(ccc3(  0,   0,   0));
    end

    skillEff:setPosition(ccp(0, GameConfig.WS.height/2))
    -- skillEff:setPosition(ccp(effPosX, effPosY))
    -- skillEff:setAnimationFps(GameConfig.ANIM_FPS)
    ModelManager:setAnimationFps(skillEff, GameConfig.FPS*2)

    -- skillEff:playByIndex(index, -1, -1, 1)
    ModelManager:playWithNameAndIndex(skillEff, "", 0, 1, -1, -1)

    self:addChild(skillEff,2)
end

function LoadingLayer:initUI(ui)
	self.super.initUI(self,ui)


	-- self.img_loading 		= TFDirector:getChildByPath(ui, 'img_loading')
 --    local rotateBy = CCRotateBy:create(1/30, 360/60);
 --    local action =CCRepeatForever:create(rotateBy);
 --    self.img_loading:runAction(action);
 --    TFDirector:getChildByPath(ui, 'Panel'):setTouchEnabled(false);
end

-- 每次c++调用onEnter之后调用
function LoadingLayer:onEnter()

end
-- 每次c++调用onExit之后调用
function LoadingLayer:onExit()
    self:clearForCuurentScene()
end

function LoadingLayer:removeUI()
	self.super.removeUI(self);
	self.img_loading = nil;
end

function LoadingLayer:show(showType)
    -- print("LoadingLayer:show");
    showType = showType or 1;
    if not LoadingLayer.loadingCount then
        LoadingLayer.loadingCount = 0;
    end

    local loading = LoadingLayer.loading;

    if not loading then
        LoadingLayer.loadingCount = 0;
        loading = LoadingLayer:new();
        loading:setZOrder(500);
        loading:setName("LoadingLayer");
        loading:setType(showType);
        loading:setPosition(ccp(GameConfig.WS.width/2, 0))
        -- AlertManager:addLayer(loading,AlertManager.BLOCK);
    end
    if LoadingLayer.loadingCount == 0 then
        local currentScene = Public:currentScene();
        currentScene:addLayer(loading);
        -- AlertManager:show(loading);
        loading.toScene = currentScene;
    end

    LoadingLayer.loadingCount = LoadingLayer.loadingCount + 1;
    LoadingLayer.loading = loading;
end

function LoadingLayer:hide()
    -- print("LoadingLayer:hide");
    if not LoadingLayer.loadingCount or LoadingLayer.loadingCount == 0 then
        return true;
    end

    LoadingLayer.loadingCount = LoadingLayer.loadingCount - 1;

    if LoadingLayer.loadingCount == 0 then

        local loading = LoadingLayer.loading;
        if loading then
            loading.toScene:removeLayer(loading);
            LoadingLayer.loading = nil;
        end
        -- AlertManager:closeLayerByName("LoadingLayer");
        return true;
    end
end

function LoadingLayer:clearForCuurentScene()
    local isDone = self:hide();
    while not isDone do
        isDone = self:hide();
    end
end

return LoadingLayer;
