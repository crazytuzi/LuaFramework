local equipmentItem = require("app.scenes.equipment.cell.EquipmentListCell")

--local TreasureItem = require("app.scenes.treasureCulture.TreasureItem")
local EquipmentListFragmentLayer = class("EquipmentListFragmentLayer",UFCCSNormalLayer)
local EquipmentConst = require("app.const.EquipmentConst")

function EquipmentListFragmentLayer.create(...)
    return EquipmentListFragmentLayer.new("ui_layout/equipment_EquipmentFragmentListLayer.json", ...)
end

function EquipmentListFragmentLayer:ctor(...)
    
    self._listView = nil
    self._listData = {}
    --点击的cell用来刷新
    self._clickCell = nil
    self.super.ctor(self, ...)

end

function EquipmentListFragmentLayer:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BAG_FRAGMENT_COMPOUND, self._revFragmentCompound, self)
end


function EquipmentListFragmentLayer:updateView(curEquipId)
    self._listData = G_Me.bagData:getEquipmentFragmentList()
    if self._listView == nil then
        -- init list view
        self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_listViewContainer"), LISTVIEW_DIR_VERTICAL)
        self._listView:setCreateCellHandler(function ( list, index)
            return require("app.scenes.equipment.cell.EquipmentFragmentListCell").new()
        end)
    end
    -- G_HandlersManager.bagHandler:sendFragmentCompoundMsg(fragment.id)
    self._listView:setUpdateCellHandler(function ( list, index, cell)
    	local fragment = self._listData[index+1]
        if index < #self._listData then
            cell:updateData(fragment)
        end
        cell:setComposeFunc(function()
            self._clickCell = cell
            --先判断包裹
            local CheckFunc = require("app.scenes.common.CheckFunc")
            if CheckFunc.checkEquipmentFull() then
                return
            end
            -- 用于一键多次合成
            if (fragment.num / fragment_info.get(fragment.id).max_num) < 2 then
                G_HandlersManager.bagHandler:sendFragmentCompoundMsg(fragment.id)
            else
                local maxNum = G_Me.bagData:getMaxEquipmentNumByLevel(G_Me.userData.level)
                local currNum = G_Me.bagData.equipmentList:getCount()
                require("app.scenes.equipment.MultiComposeLayer").show(fragment, maxNum, currNum)
            end
        end)
        cell:setTogetButtonClickEvent(function()
            --返回的时候要传入selectType
            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_FRAGMENT, fragment.id, GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentMainScene", {2,fragment.id}))
        end)
        cell:setCheckFragmentInfoFunc(function()
            require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_FRAGMENT, fragment.id) 
            end)
    end)
  
    --定位到上次选中的碎片
    local curSelectFragment = 0
    if curEquipId and type(curEquipId) == "number" and curEquipId > 0 then
            --print("------------current quipid="..curEquipId)
            for key, value in pairs(self._listData) do 
                if curSelectFragment == 0 and value.id == curEquipId then 
                    curSelectFragment = key
                end
            end
    end

    if curSelectFragment > 0 then
        
        --print("------------current curSelectFragment="..curSelectFragment.."  #self._listData="..#self._listData)

        self._listView:reloadWithLength(#self._listData, curSelectFragment - 2, 0.2)

        --底层有BUG 定位不准确
        if curSelectFragment >= #self._listData-1 then
            self._listView:scrollToBottomRightCellIndex(#self._listData - 1, 0, -1, function() end)
        end

        local cell = self._listView:getCellByIndex(curSelectFragment - 1)
        if cell then
            cell:blurFragment(true)
        end
        self:callAfterDelayTime(3.0, nil, function ( ... )
            if cell and cell.blurFragment then 
                cell.blurFragment(cell, false)
            end
        end)
    else
        self._listView:reloadWithLength(#self._listData, 0, 0.2)

    end

end


function EquipmentListFragmentLayer:_revFragmentCompound(data)
    __LogTag("wkj","这里是装备合成的消息")
    --需要刷新
    if data.ret == 1 then
        local fragment = fragment_info.get(data.id)
        require("app.cfg.equipment_info")
        local equipment = equipment_info.get(fragment.fragment_value)
        G_MovingTip:showMovingTip(G_lang:get("LANG_EQYUOMENT_FRAGMENT_COMPOSE_SUCCESS",{num = data.num, name=equipment.name}))

        require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_EQUIPMENT, equipment.id) 


        --判断fragment数量
        local __fragment = G_Me.bagData.fragmentList:getItemByKey(data.id)
        --重新取一遍
        self._listData = G_Me.bagData:getEquipmentFragmentList()
        
        if __fragment == nil or __fragment["num"] == 0 then
            --移除
            if self._clickCell ~= nil then
                -- self._listView:removeChild(self._clickCell)
                self._listView:reloadWithLength(#self._listData,self._listView:getShowStart())
                self._clickCell = nil
            end
        else 
            --update
            if __fragment["num"] > fragment.max_num then
                self._clickCell:updateData(__fragment)
            else
                self._listView:reloadWithLength(#self._listData,self._listView:getShowStart())
            end
        end
    end
end
function EquipmentListFragmentLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end


return EquipmentListFragmentLayer
