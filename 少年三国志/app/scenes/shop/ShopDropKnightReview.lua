--招将预览
local ShopDropKnightReview = class("ShopDropKnightReview",UFCCSModelLayer)
require("app.cfg.knight_drop_info")
require("app.cfg.knight_info")
require("app.cfg.knight_pack_info")
--[[
    _type 1 表示良品
          2 表示极品
          4 魏
          5 蜀
          6 吴
          7 群雄
]]
function ShopDropKnightReview.create(_type)
    local showType = 1
    if _type ~= nil and type(_type) == "number" then
        showType = _type
    end
    return ShopDropKnightReview.new("ui_layout/shop_ShopDropKnightReview.json",require("app.setting.Colors").modelColor,_type)
end

function ShopDropKnightReview:ctor(json,color,_type,...)
    self._group = 0  --阵营抽将
    if _type > 3 then
        self._group = _type - 3
    end
    self.weiguoList={}
    self.weiguoIndexList = {}
    self.shuguoList={}
    self.shuguoIndexList={}

    self.wuguoList={}
    self.wuguoIndexList={}

    self.qunxiongList={}
    self.qunxiongIndexList={}
    
    self.weiguoListView = nil
    self.shuguoListView = nil
    self.wuguoListView = nil
    self.qunxiongListView = nil
    
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self._tabs = nil
    self._views = {}
    self._type = _type
    self:_initListViewData()
    self:_sortList()
    self:_setWidgets()
    self:enableAudioEffectByName("Button_close", false)
    self:registerBtnClickEvent("Button_close",function() 
        self:animationToClose() 
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
        end)
end

function ShopDropKnightReview:_setWidgets()
    self:_setCheckboxTouchEnabled()
    self._tabs = require("app.common.tools.Tabs").new(1, self, self._onCheckCallback)
    --[[因为self.qunxiongList等都是固定的，不会变动的]]
    self:_createTab("Panel_weiguo","CheckBox_weiguo","Label_weig_check",self.weiguoList,self.weiguoIndexList)
    self:_createTab("Panel_shuguo", "CheckBox_shuguo","Label_sg_check",self.shuguoList,self.shuguoIndexList)
    self:_createTab("Panel_wuguo", "CheckBox_wuguo","Label_wug_check",self.wuguoList,self.wuguoIndexList)
    self:_createTab("Panel_qunxiong", "CheckBox_qunxiong","Label_qx_check",self.qunxiongList,self.qunxiongIndexList)
    if self._group == 1 then
        self._tabs:checked("CheckBox_weiguo")
    elseif self._group == 2 then
        self._tabs:checked("CheckBox_shuguo")
    elseif self._group == 3 then
        self._tabs:checked("CheckBox_wuguo")
    elseif self._group == 4 then
        self._tabs:checked("CheckBox_qunxiong")
    else
        self._tabs:checked("CheckBox_weiguo")
    end
    local title = self:getImageViewByName("ImageView_title")
    if self._type == 1 then     
        title:loadTexture("ui/text/txt-title/zhanjiangzhaomuyulan.png",UI_TEX_TYPE_LOCAL)
    elseif self._type == 2 then
        title:loadTexture("ui/text/txt-title/shenjiangzhaomuyulan.png",UI_TEX_TYPE_LOCAL)
    else
        title:loadTexture(G_Path.getTitleTxt("zhaomuyulan.png"))
    end
end

function ShopDropKnightReview:_setCheckboxTouchEnabled()
    --表示阵营抽将
    if self._group ~= 0 then
        self:getWidgetByName("CheckBox_weiguo"):setTouchEnabled(self._group == 1)
        self:getWidgetByName("CheckBox_shuguo"):setTouchEnabled(self._group == 2)
        self:getWidgetByName("CheckBox_wuguo"):setTouchEnabled(self._group == 3)
        self:getWidgetByName("CheckBox_qunxiong"):setTouchEnabled(self._group == 4)
    end
end

--[[
    先遍历knight_drop_info
    通过 pack_id 关联knight_pack_info
]]
function ShopDropKnightReview:_initListViewData()
    for i=1,knight_drop_info.getLength() do
        local pack = knight_drop_info.indexOf(i)
        if self._type == pack.type then
            --[[每个卡包最多20个]]
            --通过 pack_id 关联knight_pack_info
            for k=1,20 do
                local packKey = string.format("pack%s_id",k)
                -- local packInfo = knight_pack_info.get(pack[packKey])
                local packInfo = nil
                if knight_drop_info.hasKey(packKey) then
                    packInfo = knight_pack_info.get(pack[packKey])
                end
                if packInfo == nil then
                    break
                end

                for j=1,20 do
                    local key = string.format("knight%s_id",j)
                    --local packInfo = knight_pack_info.get(pack.id)
                    --表示不存在knight  packInfo[key]实际是knight_pack_info里的knightId
                    if packInfo[key] == nil or packInfo[key] == 0 then
                        break
                    end
                    local knight = knight_info.get(packInfo[key])
                    --[[
                        1 魏国
                        2 蜀国
                        3 吴国
                        4 群雄
                    ]]
                    if knight.group == 1 then
                        if self.weiguoList[knight.id] == nil then
                            self.weiguoList[knight.id] = knight
                            self.weiguoIndexList[#self.weiguoIndexList+1] = knight.id
                        end
                    elseif knight.group == 2 then
                        if self.shuguoList[knight.id] == nil then
                            self.shuguoList[knight.id] = knight
                            self.shuguoIndexList[#self.shuguoIndexList+1] = knight.id
                        end
                    elseif knight.group == 3 then
                        if self.wuguoList[knight.id] == nil then
                            self.wuguoList[knight.id] = knight
                            self.wuguoIndexList[#self.wuguoIndexList+1] = knight.id
                        end
                    elseif knight.group == 4 then
                        if self.qunxiongList[knight.id] == nil then
                            self.qunxiongList[knight.id] = knight
                            self.qunxiongIndexList[#self.qunxiongIndexList+1] = knight.id
                        end
                    end

                end
            end
        end
    end
end

function ShopDropKnightReview:_sortList()
    --排序
    local sortFunc = function(a,b)
        local knightA = self.weiguoList[a]
        local knightB = self.weiguoList[b]
        if knightA.quality ~= knightB.quality then
            return knightA.quality > knightB.quality
        end
        if knightA.potential ~= knightB.potential then
            return knightA.potential > knightB.potential
        end
    end

    if #self.weiguoIndexList > 0 then
        table.sort(self.weiguoIndexList,sortFunc)
    end


    --排序
    sortFunc = function(a,b)
        local knightA = self.shuguoList[a]
        local knightB = self.shuguoList[b]
        if knightA.quality ~= knightB.quality then
            return knightA.quality > knightB.quality
        end
        if knightA.potential ~= knightB.potential then
            return knightA.potential > knightB.potential
        end
    end
    if #self.shuguoIndexList > 0 then
        table.sort(self.shuguoIndexList,sortFunc)
    end
    
    --排序
    sortFunc = function(a,b)
        local knightA = self.wuguoList[a]
        local knightB = self.wuguoList[b]
        if knightA.quality ~= knightB.quality then
            return knightA.quality > knightB.quality
        end
        if knightA.potential ~= knightB.potential then
            return knightA.potential > knightB.potential
        end
    end
    if #self.wuguoIndexList > 0 then
        table.sort(self.wuguoIndexList,sortFunc)
    end
    
    --排序
    sortFunc = function(a,b)
        local knightA = self.qunxiongList[a]
        local knightB = self.qunxiongList[b]
        if knightA.quality ~= knightB.quality then
            return knightA.quality > knightB.quality
        end
        if knightA.potential ~= knightB.potential then
            return knightA.potential > knightB.potential
        end
    end
    if #self.qunxiongIndexList > 0 then
        table.sort(self.qunxiongIndexList,sortFunc)
    end
end


--创建tab
function ShopDropKnightReview:_createTab(panelName, btnName,labelName,listData,indexListData)
    --此处self._views[btnName]为nil
    
    self._tabs:add(btnName, self._views[btnName],labelName)
end


--初始化tab的listview
function ShopDropKnightReview:_initTabHandler(panelName,btnName,indexListData,listData)
    if self._views[btnName] == nil then
        self._views[btnName] = CCSListViewEx:createWithPanel(self:getPanelByName(panelName), LISTVIEW_DIR_VERTICAL)
        --重新add一遍
        self._tabs:add(btnName, self._views[btnName])
        self._views[btnName]:setCreateCellHandler(function ( list, index)
            return require("app.scenes.shop.ShopDropKnightReviewItem").new()
        end)
        self._views[btnName]:setUpdateCellHandler(function(list,index,cell)  
            if cell ~= nil then
                cell:update(listData[indexListData[index*4+1]],listData[indexListData[index*4+2]],listData[indexListData[index*4+3]],listData[indexListData[index*4+4]])
            end
        end)
    end
    local length = #indexListData % 4 == 0 and #indexListData/4 or ((#indexListData-#indexListData%4)/4+1)
    self._views[btnName]:reloadWithLength(length,self._views[btnName]:getShowStart())
end

function ShopDropKnightReview:_onCheckCallback(name)
    print("选中name = " .. name)
    if name == "CheckBox_weiguo" then
        self:_initTabHandler("Panel_weiguo",name,self.weiguoIndexList,self.weiguoList)
    elseif name == "CheckBox_shuguo" then
        self:_initTabHandler("Panel_shuguo",name,self.shuguoIndexList,self.shuguoList)
    elseif name == "CheckBox_wuguo" then
        self:_initTabHandler("Panel_wuguo",name,self.wuguoIndexList,self.wuguoList)
    else
        self:_initTabHandler("Panel_qunxiong",name,self.qunxiongIndexList,self.qunxiongList)
    end
end

function ShopDropKnightReview:onLayerEnter()
    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_back"), "smoving_bounce")
    self:closeAtReturn(true)
end

return ShopDropKnightReview

