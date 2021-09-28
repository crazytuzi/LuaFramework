local ServerListLayer = class("ServerListLayer",UFCCSModelLayer)


function ServerListLayer.create(mail)
   return ServerListLayer.new("ui_layout/login_ServerListLayer.json", require("app.setting.Colors").modelColor)
end

function ServerListLayer:ctor()
    self.super.ctor(self)
    
    self._callback = nil
    self:_initViews()
    self:setClickClose(true)
    -- self:registerTouchEvent(false,true,0)
end

function ServerListLayer:setCallback(callback)
    self._callback = callback
end
    

function ServerListLayer:_onSelect(server)
    if self._callback ~= nil then
        self._callback(server)
    end
    self:animationToClose()
end
    

function ServerListLayer.updateServerIcon(imageView, status)
    if status and status ~= 1  and status ~= 7 then
        imageView:setVisible(true)
        --status: 游戏服类型，1-正常；2-新开；3-火爆；4-维护；5-停服；6-合服 ；7-即将开启
        if status == 2 then
            imageView:loadTexture(G_Path.getTextPath("dl_icon_new.png"))
        else
            imageView:loadTexture(G_Path.getTextPath("dl_icon_hot.png"))
        end

    else
        imageView:setVisible(false)
    end
end     

function ServerListLayer:_initViews()    
    self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_list"), LISTVIEW_DIR_VERTICAL)
    self._listView:setCreateCellHandler(function ( list, index)
        local cell =  CCSItemCellBase:create("ui_layout/login_ServerCell.json")
        cell:registerBtnClickEvent("Button_bg",  function() 
            self:_onSelect(cell.serverData)
        end)
        cell:registerBtnClickEvent("Button_bg2",  function() 

            self:_onSelect(cell.serverData2)
        end)
       -- cell:getLabelByName("Label_name"):createStroke(Colors.strokeBrown,1)
       -- cell:getLabelByName("Label_name2"):createStroke(Colors.strokeBrown,1)

        return cell
    end)
    
    local serverList = G_ServerList:getList()
    
    local function updateCell(cell, data1, data2) 
        cell.serverData = data1
        cell.serverData2 = data2 

        --data1
        cell:getLabelByName("Label_name"):setText(cell.serverData.name)        
        ServerListLayer.updateServerIcon(cell:getImageViewByName("Image_icon"), cell.serverData.status)

        --data2
        if data2 then
            cell:getButtonByName("Button_bg2"):setVisible(true)
            cell:getLabelByName("Label_name2"):setText(cell.serverData2.name)        
            ServerListLayer.updateServerIcon(cell:getImageViewByName("Image_icon2"), cell.serverData2.status)
        else
            cell:getButtonByName("Button_bg2"):setVisible(false)
        end
   
    end

    self._listView:setUpdateCellHandler(function ( list, index, cell)
        local rindex = index*2 + 1
        local data1 =  serverList[rindex]
        local data2 
        if rindex+1 <= #serverList then
           data2 = serverList[rindex+1]
        end 
        updateCell(cell, data1, data2)


    end)

    self._listView:initChildWithDataLength( math.ceil(#serverList/2))



    self:registerBtnClickEvent("Button_close",function()
        self:animationToClose()
    end)



    --last server logined
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_UPDATE_ROLE_LIST, handler(self,self._loadRoleList), self)

    self:_loadRoleList()
end


function ServerListLayer:_loadRoleList()
    local roleList = G_RoleService:getList()
    local serverList = G_ServerList:getList()
    local list = {}
    for i, info in ipairs(roleList) do 
        local serverId = info.serverId 
        local serverData =  G_ServerList:getServerById(serverId) 
        if serverData then
            info['serverData'] = serverData
            table.insert(list, info)
        end
    end
    self:_showRoleServers(list)
 
end


function ServerListLayer._updateRoleCell(cell, data1, data2) 
    cell.data = data1
    cell.data2 = data2 

    --data1
    cell:getLabelByName("Label_server_name"):setText(cell.data.serverData.name)     

    local role_name = cell.data.role_name
    if cell.data.level > 0 then
        role_name = role_name .. "(" .. G_lang:get("LANG_LEVEL_INFO_FORMAT", {levelValue=cell.data.level}) .. ")"
    end

    cell:getLabelByName("Label_role_name"):setText(role_name)        

    --data2
    if data2 then
        cell:getButtonByName("Button_bg2"):setVisible(true)
        cell:getLabelByName("Label_server_name2"):setText(cell.data2.serverData.name)   

        local role_name2 = cell.data2.role_name
        if cell.data2.level > 0 then
            role_name2 = role_name2 .. "(" .. G_lang:get("LANG_LEVEL_INFO_FORMAT", {levelValue=cell.data2.level}) .. ")"
        end
        cell:getLabelByName("Label_role_name2"):setText(role_name2)        
 
    else
        cell:getButtonByName("Button_bg2"):setVisible(false)
    end

end


function ServerListLayer:_showRoleServers(roleList)

    if self._roleListView ~= nil then
        self._roleListView:setUpdateCellHandler(function ( list, index, cell)
            local rindex = index*2 + 1
            local data1 =  roleList[rindex]
            local data2 
            if rindex+1 <= #roleList then
               data2 = roleList[rindex+1]
            end 
            ServerListLayer._updateRoleCell(cell, data1, data2)
        end)
        self._roleListView:initChildWithDataLength( math.ceil(#roleList/2))

        return
    end


    self._roleListView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_recent"), LISTVIEW_DIR_VERTICAL)
    self._roleListView:setCreateCellHandler(function ( list, index)
        local cell =  CCSItemCellBase:create("ui_layout/login_ServerRoleCell.json")
        cell:registerBtnClickEvent("Button_bg",  function() 
            self:_onSelect(cell.data.serverData)
        end)
        cell:registerBtnClickEvent("Button_bg2",  function() 
            self:_onSelect(cell.data2.serverData)
        end)

        return cell
    end)
    
    
 

    self._roleListView:setUpdateCellHandler(function ( list, index, cell)
        local rindex = index*2 + 1
        local data1 =  roleList[rindex]
        local data2 
        if rindex+1 <= #roleList then
           data2 = roleList[rindex+1]
        end 
        ServerListLayer._updateRoleCell(cell, data1, data2)


    end)

    self._roleListView:initChildWithDataLength( math.ceil(#roleList/2))


end

function ServerListLayer:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

function ServerListLayer:onLayerEnter()
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    self:closeAtReturn(true)
end

-- function ServerListLayer:onTouchEnd( xpos, ypos )
--     self:animationToClose()
--     return true
-- end



return ServerListLayer


