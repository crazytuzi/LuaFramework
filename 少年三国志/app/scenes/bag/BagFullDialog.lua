local BagFullDialog = class("BagFullDialog",UFCCSModelLayer)

--注意添加json文件
--[[
    _type
]]
function BagFullDialog.show(_type, scenePack)
    local layer = BagFullDialog.new("ui_layout/bag_BagFullDialog.json",Colors.modeColor,_type, scenePack)
    uf_sceneManager:getCurScene():addChild(layer)
end

function BagFullDialog:ctor(json,color,_type,scenePack,...)
	self.super.ctor(self,...)
    self._scenePack = scenePack
    self:showAtCenter(true)
    self._type = _type
    self:_initWidgets()
    self:_initBtnEvent()
end

function BagFullDialog:_initWidgets( ... )
    local title = self:getLabelByName("Label_title")
    local image01 = self:getImageViewByName("Image_btn01")
    local image02 = self:getImageViewByName("Image_btn02")
    if self._type == G_Goods.TYPE_KNIGHT then
        title:setText(G_lang:get("LANG_BAG_KNIGHT_IS_FULL_TITLE"))
        image01:loadTexture(G_Path.getMiddleBtnTxt("quchushou.png"))
        image02:loadTexture(G_Path.getMiddleBtnTxt("quqianghua.png"))
    elseif self._type == G_Goods.TYPE_EQUIPMENT then
        title:setText(G_lang:get("LANG_BAG_EQUIPMENT_IS_FULL_TITLE"))
        image01:loadTexture(G_Path.getMiddleBtnTxt("chushouzhuangbei.png"))
        image02:loadTexture(G_Path.getMiddleBtnTxt("qufenjie.png"))
    elseif self._type == G_Goods.TYPE_TREASURE then
        title:setText(G_lang:get("LANG_BAG_TREASURE_IS_FULL_TITLE"))
        image01:loadTexture(G_Path.getMiddleBtnTxt("chushoubaowu.png"))
        image02:loadTexture(G_Path.getMiddleBtnTxt("baowuqianghua.png"))
    elseif self._type == G_Goods.TYPE_PET then
        title:setText(G_lang:get("LANG_BAG_PET_IS_FULL_TITLE"))
        image02:loadTexture(G_Path.getMiddleBtnTxt("qufenjie.png"))

        self:showWidgetByName("Button_01", false)
        local btn02 = self:getButtonByName("Button_02")
        if btn02 then
            btn02:setPositionX(btn02:getPositionX() - 120)
        end
    else
        assert("靠,传了什么类型 _type = %s",self._type)
    end
end

function BagFullDialog:_initBtnEvent()
    self:registerBtnClickEvent("Button_01",function()
        if self._type == G_Goods.TYPE_KNIGHT then
        elseif self._type == G_Goods.TYPE_EQUIPMENT then
        elseif self._type == G_Goods.TYPE_TREASURE then
        else
            assert("靠,传了什么类型 _type = %s",self._type)
            return
        end
        uf_sceneManager:replaceScene(require("app.scenes.bag.BagSellScene").new(self._type, nil, self._scenePack))
        -- self:animationToClose()
        end)

    self:registerBtnClickEvent("Button_02",function()
        local RecycleScene = require("app.scenes.recycle.RecycleScene")
        if self._type == G_Goods.TYPE_KNIGHT then
            uf_sceneManager:replaceScene(require("app.scenes.herofoster.HeroFosterScene").new())
        elseif self._type == G_Goods.TYPE_EQUIPMENT then
            uf_sceneManager:replaceScene(require("app.scenes.recycle.RecycleScene").new(nil, nil, 2, nil, self._scenePack))
        elseif self._type == G_Goods.TYPE_TREASURE then
            uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new())
        elseif self._type == G_Goods.TYPE_PET then
            uf_sceneManager:replaceScene(RecycleScene.new(nil, nil, RecycleScene.TYPE_RECYCLE_PET))
        else
            assert("靠,传了什么类型 _type = %s",self._type)
        end
        -- self:animationToClose()
        end)
end



function BagFullDialog:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")

    -- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    -- if appstoreVersion or IS_HEXIE_VERSION  then
    --     local img = self:getImageViewByName("Image_23")
    --     if img then
    --         img:loadTexture("ui/arena/xiaozhushou_hexie.png")
    --     end
    -- end
    GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_23"))
end
return BagFullDialog
