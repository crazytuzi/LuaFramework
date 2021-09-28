local CaiShenDialog = class("CaiShenDialog",UFCCSModelLayer)
require("app.cfg.activity_money_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
function CaiShenDialog.show()
    local layer = CaiShenDialog.new("ui_layout/activity_CaiShenDialog.json", Colors.modelColor)
    uf_sceneManager:getCurScene():addChild(layer)
end

CaiShenDialog.MAX_CAISHEN_COUNT = 6

function CaiShenDialog:ctor(json,color,...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    
    self:attachImageTextForBtn("Button_lingqu","Image_16")
    self:registerTouchEvent(false,true,0)
    self:setClickClose(true)

    self:registerBtnClickEvent("Button_lingqu",function()
        G_HandlersManager.activityHandler:sendWorship()
        self:close()
        end)

    local total_count = G_Me.activityData.caishen.total_count
    if total_count ~= 6 then
        self:getButtonByName("Button_lingqu"):setTouchEnabled(false)
    end
    local record = G_Me.activityData.caishen:getCaiShenRecord()
    if not record then
        return
    end
    
    local tipsLabel = self:getLabelByName("Label_tips")
    tipsLabel:setVisible(false)
    local size = tipsLabel:getContentSize()
    self._richText = CCSRichText:create(size.width+50, size.height+30)
    self._richText:setFontSize(tipsLabel:getFontSize())
    self._richText:setFontName(tipsLabel:getFontName())
    local x,y = tipsLabel:getPosition()
    local text = nil
    if total_count == CaiShenDialog.MAX_CAISHEN_COUNT then
        text = G_lang:get("LANG_PANZI_LING_QU_TIPS",{money=record.total_reward})
        self._richText:setPosition(ccp(x+10,y+30))
    else
        self._richText:setPosition(ccp(x+10,y+20))
        local leftTime = CaiShenDialog.MAX_CAISHEN_COUNT-total_count
        if leftTime == 1 then
            text = G_lang:get("LANG_PANZI_TIPS01",{money=record.total_reward})
        else
            text = G_lang:get("LANG_PANZI_TIPS",{money=record.total_reward,times=CaiShenDialog.MAX_CAISHEN_COUNT-total_count})
        end
    end
    self._richText:appendXmlContent(text)
    self._richText:reloadData()
    self:getImageViewByName("Image_qipao"):addChild(self._richText)

    self:showWidgetByName("ImageView_"..1, false)
    self:showWidgetByName("ImageView_"..2, false)
    self:showWidgetByName("ImageView_"..3, false)

    local _loadItem = function ( vType, value, size, index )
        if type(index) ~= "number" then 
            return 
        end

        local good = G_Goods.convert(vType, value, size)
        if not good then
            return
        end

        self:showWidgetByName("ImageView_"..index, true)

        local itemImage = self:getImageViewByName("ImageView_icon_"..index)
        local itemBgImage = self:getImageViewByName("ImageView_icon_bg_"..index)
        local qualityBtn = self:getButtonByName("Button_quality_"..index)
        itemImage:loadTexture(good.icon)
        itemBgImage:loadTexture(G_Path.getEquipIconBack(good.quality))
        qualityBtn:loadTextureNormal(G_Path.getEquipColorImage(good.quality,good.type))
        qualityBtn:loadTexturePressed(G_Path.getEquipColorImage(good.quality,good.type))

        self:registerBtnClickEvent("Button_quality_"..index,function()
            if not good then
               return
            end
            require("app.scenes.common.dropinfo.DropInfo").show(good.type,good.value) 
        end)

        self:getLabelByName("Label_count_"..index):createStroke(Colors.strokeBrown,1)
        self:getLabelByName("Label_count_"..index):setText("x" .. size)

        self:getLabelByName("Label_name_"..index):createStroke(Colors.strokeBrown,1)
        self:getLabelByName("Label_name_"..index):setText(good.name)
        self:getLabelByName("Label_name_"..index):setColor(Colors.qualityColors[good.quality])
    end

    local _loadReward = function ( reward, vType, value, size )
        if type(vType) ~= "number" or type(value) ~= "number" or type(size) ~= "number" or size < 1 then 
            _loadItem(G_Goods.TYPE_MONEY, 0, reward, 1)
        else
            _loadItem(G_Goods.TYPE_MONEY, 0, reward, 2)
            _loadItem(vType, value, size, 3)
        end
    end

    _loadReward(record.total_reward, record.type, record.value, record.size_show)
end

function CaiShenDialog:onLayerEnter()
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    EffectSingleMoving.run(self:getImageViewByName("Image_dianjijixu"), "smoving_wait", nil , {position = true} )

    GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_17"))
    -- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    -- if appstoreVersion or IS_HEXIE_VERSION  then 
    --     local img = self:getImageViewByName("Image_17")
    --     if img then
    --         img:loadTexture("ui/arena/xiaozhushou_hexie.png")
    --     end
    -- end
end

return CaiShenDialog

