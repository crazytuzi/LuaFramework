local TipsInfoList2Scene = class("TipsInfoList2Scene",UFCCSBaseScene)

--@param firstData 当前二级目录所对应一级目录的条目
function TipsInfoList2Scene:ctor(cellIndex,pos,...)
    self.super.ctor(self,...)
    self._firstId = firstId
    self._list = require("app.scenes.tipsinfo.TipsInfoData").getListData1()

    -- 在第一的位置加一条战斗说明
    table.insert(self._list, 1, {id = 1000, title = G_lang:get("LANG_TIPS_FIGHT_TITLE"), icon = "icon/basic/103.png", stage_id = 15})

    self._cellIndex = cellIndex
    self._pos = pos
    self._mainLayer = CCSNormalLayer:create("ui_layout/tipsinfo_list2.json")

    self:addUILayerComponent("TipsInfoMainLayer", self._mainLayer,true)


    
    self._mainLayer:registerBtnClickEvent("Button_Back", function()
        self:onBackKeyEvent()
    end)
    
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedBar, true)
    self:adapterLayerHeight(self._mainLayer, nil, self._speedBar, 0, -56)
    self:registerKeypadEvent(true)
end

function TipsInfoList2Scene:onBackKeyEvent( ... )
     uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    return true
end

function TipsInfoList2Scene:onSceneEnter( ... )
    self:_init()
    if self._cellIndex and self._pos then
        self.listview:scrollToTopLeftCellIndex(self._cellIndex, self._pos, 0, function() end)
    end
    self.listview:setSpaceBorder(0, 40)
end


function TipsInfoList2Scene:_init()

    	local panel = self._mainLayer:getPanelByName("Panel_List2")
        self._mainLayer:adapterWidgetHeightWithOffset("Panel_List2", 0,70)
	self.listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	-- self.listview._list = dungeon_chapter_info.data
	self.listview:setCreateCellHandler( function(list, index)
		local cell = CCSItemCellBase:create("ui_layout/tipsinfo_list2_item.json")
                cell:setTouchEnabled(true)
                cell:registerCellClickEvent(function ( cell, index )
                    -- 如果是战斗说明
                    if index == 0 then
                        require("app.scenes.common.CommonHelpLayer").show(
                        {
                            {title = G_lang:get("LANG_TIPS_FIGHT_RULES_TITLE_1"), content = G_lang:get("LANG_TIPS_FIGHT_RULES_CONTENT_1")},
                            {title = G_lang:get("LANG_TIPS_FIGHT_RULES_TITLE_2"), content = G_lang:get("LANG_TIPS_FIGHT_RULES_CONTENT_2")},
                            {title = G_lang:get("LANG_TIPS_FIGHT_RULES_TITLE_3"), content = G_lang:get("LANG_TIPS_FIGHT_RULES_CONTENT_3")},
                            {title = G_lang:get("LANG_TIPS_FIGHT_RULES_TITLE_4"), content = G_lang:get("LANG_TIPS_FIGHT_RULES_CONTENT_4")},
                            {title = G_lang:get("LANG_TIPS_FIGHT_RULES_TITLE_5"), content = G_lang:get("LANG_TIPS_FIGHT_RULES_CONTENT_5")},
                            {title = G_lang:get("LANG_TIPS_FIGHT_RULES_TITLE_6"), content = G_lang:get("LANG_TIPS_FIGHT_RULES_CONTENT_6")},
                            {title = G_lang:get("LANG_TIPS_FIGHT_RULES_TITLE_7"), content = G_lang:get("LANG_TIPS_FIGHT_RULES_CONTENT_7")},
                        })
                        return
                    end

                    local pos = self.listview:getCellTopLeftOffset(index)
                     uf_sceneManager:replaceScene(require("app.scenes.tipsinfo.TipsInfoList3Scene").new(self._list[index+1].id,index,pos))
                 end)
		return cell
	end )

	self.listview:setUpdateCellHandler(handler(self, self._updateCell))
        if self._cellIndex then
            self.listview:initChildWithDataLength(#self._list)
        else
            self.listview:initChildWithDataLength(#self._list,0.2)
        end
end


function TipsInfoList2Scene:_updateCell(list, index, cell)
    cell:getImageViewByName("Image_Ico"):loadTexture(self._list[index+1].icon)

    local commentLabel = cell:getLabelByName("Label_Comment")
    if commentLabel then
        commentLabel:setText(self._list[index+1].title)
        if device.platform ~= "wp8" and device.platform ~= "winrt" then
            commentLabel:createStroke(ccc3(255,255,255), 2)
        end
    end

    cell:setTag(self._list[index+1].id)
end

return TipsInfoList2Scene
