


local Util = require "Zeus.Logic.Util"
local TreeView = require "Zeus.Logic.TreeView"
local ItemModel = require 'Zeus.Model.Item'
local DisplayUtil = require "Zeus.Logic.DisplayUtil"

local _M = {
    composeInfo = nil,itemshows_mar = nil,selectComposeCount = nil,selectComposeInfo = nil,itemNodes = nil,selectRootIndex = nil,
    selectSubIndex = nil,selectLeafIndex = nil
}
_M.__index = _M

local item_pos = {
    [3] = {
        {x = 26,y = 0},
        {x = 66,y = 0},
        {x = 128,y = 0},
    },
    [2] = {
        {x = 128,y = 0},
        {x = 196,y = 0},
    },
    [1] = {
        {x = 230,y = 0},
    }
}

local grid_pos = {}

function _M.getPropByCodes(codes)
    local list = GlobalHooks.DB.Find("CombineType", {})
    for i = 1,#list,1 do
        local prop = list[i]
        for j = 1,#codes,1 do
            if prop.TagetCode == codes[j] then
                return prop
            end
        end
    end
    return nil
end


local ui_names = {
    {name = "sp_type"},
    {name = "sp_type2"},
    {name = "cvs_typename"},
    {name = "cvs_subtype"},
    {name = "cvs_item"},
    {name = "sp_deatil"},
    {name = "detail_node"},
    {name = "ib_detail_icon"},
    {name = "lb_detail_name"},
    {name = "ib_detail_frame"},
    {name = "lb_use"},


    {name = "lb_combine_data"},
    {name = "lb_have_num"},
    {name = "cvs_single1"},
    {name = "cvs_single2"},
    {name = "cvs_single3"},
    {name = "btn_deplete_add" ,click = function(self)
        if self.selectComposeInfo then
            if self.selectComposeCount < self.selectComposeInfo.compProp.canComposeCount then
                self.selectComposeCount = self.selectComposeCount + 1
                self:changeMoney()  
            end
        end
    end},
    {name = "btn_deplete_reduce" ,click = function(self)
        if self.selectComposeInfo then
            if self.selectComposeCount > 1 then
                self.selectComposeCount = self.selectComposeCount - 1
                self:changeMoney()
            end
        end
    end},
    {name = "btn_deplete_max" ,click = function(self)
        if self.selectComposeInfo then
            self.selectComposeCount = self.selectComposeInfo.compProp.canComposeCount
            if self.selectComposeCount < 1 then
                self.selectComposeCount = 1
            end
            self:changeMoney()
        end
    end},
    {name = "ib_rmby"},
    {name = "lb_rmby_num"},
    {name = "lb_numberkey"},
    {name = "btn_combine",click = function(self)
        self:onCombineBtnClick()
    end}
}

local string_num = "%d/%d"

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.event_PointerClick = function()
                    ui.click(tbl)
                end
            end
        end
    end
end

local function getRootIndex(self,parentId)
    for i = 1,#self.listRootProp,1 do
        if (self.listRootProp[i].ID == parentId) then
            return i
        end
    end
    return 0
end

local function getRootID(self,index)
    return self.listRootProp[index].ID
end

local function setComponseItems(self,rootIndex,subIndex)
    self.listNodes = {}
    self.composeItemProps = nil
    local rootID = getRootID(self,rootIndex)
    local subValues = self.listSubProp[rootID]
    self.selectLeafIndex = 1
    if subValues then
        local subID = subValues[subIndex].ID
        local items = self.listLeafProp[subID]
        if items then
            self.composeItemProps = items
            self.sp_deatil.Scrollable:Reset(1,#items)
        end
    else
        self.sp_deatil.Scrollable:Reset(1,0)
    end

    self.selectLeafIndex = self:GetSelectItem()
    self:SetSelectItem(self.selectLeafIndex)
end

local function getCombinePropByCode(code)
    local combineProps = GlobalHooks.DB.Find('Combine',{})
    for k,v in pairs(combineProps) do
        if v.DestCode == code then
            return v
        end
    end
    return nil
end

local function getComposeInfo(self,composeProp)
    local combineProp = getCombinePropByCode(composeProp.TagetCode)
    if combineProp then
        local codes = {}
        local needCounts = {}
        if string.len(combineProp.SrcCode1) > 0 then
            table.insert(codes,combineProp.SrcCode1)
            table.insert(needCounts,combineProp.SrcCount1)
        end
        if string.len(combineProp.SrcCode2) > 0 then
            table.insert(codes,combineProp.SrcCode2)
            table.insert(needCounts,combineProp.SrcCount2)
        end
        if string.len(combineProp.SrcCode3) > 0 then
            table.insert(codes,combineProp.SrcCode3)
            table.insert(needCounts,combineProp.SrcCount3)
        end
        local maxCount = 0
        for i = 1,#codes,1 do
            local num = DataMgr.Instance.UserData.RoleBag:GetTemplateItemCount(codes[i])
            local count = math.floor(num / needCounts[i])
            if maxCount == 0 then
                maxCount = count
            end
            if count < maxCount then
                maxCount = count
            end
        end
        local useMoney = combineProp.CostGold
        local myMoney = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD)
        local canComposeCount = 0
        local totalUseMoney = useMoney
        for i = 1,maxCount,1 do
            if myMoney >= totalUseMoney then
                canComposeCount = canComposeCount + 1
                totalUseMoney = totalUseMoney + useMoney
            end
        end
        local value = {
            codes = codes,needCounts = needCounts,needMoney = useMoney,canComposeCount = canComposeCount,
        }
        return value
    else
        return nil
    end
end

local function clearAllCompose(self)
    for i = 1,3,1 do
        local ctrl = self["cvs_single"..i]
        local tb_single_num = ctrl:FindChildByEditName("tb_single_num",false)
        local ib_single_icon = ctrl:FindChildByEditName("ib_single_icon",false)
        tb_single_num.Text = ""
        if self.itemshows_mar[ctrl] then
            self.itemshows_mar[ctrl].Visible = false
        else
            self.itemshows_mar[ctrl] = Util.ShowItemShow(ib_single_icon, "", 0)
            self.itemshows_mar[ctrl].Visible = false
        end
        ctrl.Visible = false
    end
end

function _M:changeMoney()
    self.lb_rmby_num.Text = self.selectComposeInfo.compProp.needMoney * self.selectComposeCount
    for i = 1,3,1 do
        local ctrl = self["cvs_single"..i]
        if self.itemshows_mar[ctrl].Visible then
            local tb_single_num = ctrl:FindChildByEditName("tb_single_num",false)
            local num = DataMgr.Instance.UserData.RoleBag:GetTemplateItemCount(self.selectComposeInfo.compProp.codes[i])
            
            tb_single_num.Text = string.format(string_num,num,self.selectComposeInfo.compProp.needCounts[i]*self.selectComposeCount)
        end
    end
    self.lb_numberkey.Text = self.selectComposeCount
end

local function findNodeByIndex(self,index)
    for k,v in pairs(self.listNodes) do
        if(k.UserTag == index) then
            return k
        end
    end
    return nil
end

local function setDetailProp(self,prop)
    self.iconItemShow.IconID = prop.itemProp.Icon
    self.iconItemShow.Quality = prop.itemProp.Qcolor
    self.lb_detail_name.Text = prop.itemProp.Name
    self.sp_type2:Initialize(self.lb_use.Width, self.lb_use.Height, 1,1, self.lb_use,
        function(x, y, cell)
            cell.UnityRichText = prop.itemProp.Desc
            cell.Visible = true
        end,
        function()
        end
      )
    self.lb_combine_data.Text = prop.itemProp.Tips
    local curCount = DataMgr.Instance.UserData.RoleBag:GetTemplateItemCount(prop.itemProp.Code)
    self.lb_have_num.Text = string.format(Util.GetText(TextConfig.Type.ITEM, 'haveNum'), curCount)
    clearAllCompose(self)
    local pos = grid_pos[#prop.compProp.codes]
    for i = 1, #prop.compProp.codes, 1 do
        local ctrl = self["cvs_single" .. i]
        ctrl.Visible = true
        ctrl.X = pos[i]
        local tb_single_num = ctrl:FindChildByEditName("tb_single_num", false)
        local ib_dep_goicon = ctrl:FindChildByEditName("ib_dep_goicon", false)
        local itemProp = GlobalHooks.DB.Find('Items', prop.compProp.codes[i])
        
        self.itemshows_mar[ctrl].IconID = itemProp.Icon
        self.itemshows_mar[ctrl].Quality = itemProp.Qcolor
        self.itemshows_mar[ctrl].Visible = true
        local num = DataMgr.Instance.UserData.RoleBag:GetTemplateItemCount(prop.compProp.codes[i])
        if num >  prop.compProp.needCounts[i] then
            self.selectComposeCount =  math.floor(num / prop.compProp.needCounts[i])
            prop.compProp.canComposeCount = math.floor(num / prop.compProp.needCounts[i])
        else
            self.selectComposeCount = 1
            prop.compProp.canComposeCount = 1
        end

        tb_single_num.Text = string.format(string_num, num, prop.compProp.needCounts[i] * self.selectComposeCount)
        ib_dep_goicon.Visible =(num < prop.compProp.needCounts[i])
        ib_dep_goicon.Enable = true
        ib_dep_goicon.IsInteractive = true
        ib_dep_goicon.event_PointerClick = function()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, prop.compProp.codes[i])
        end
    end
    self.lb_rmby_num.Text = prop.compProp.needMoney * self.selectComposeCount
    self.lb_numberkey.Text = self.selectComposeCount
end

local function clickDetailNode(self,node)
    self.selectComposeCount = 1
    if (self.composeInfo[node.UserTag]) then
        if self.iconItemShow == nil then
            self.iconItemShow = Util.ShowItemShow(self.ib_detail_icon, "", 0)
        end    
        local prop = self.composeInfo[node.UserTag]
        setDetailProp(self,prop)
        self.selectComposeInfo = prop
    end
end

local string_format = "%s(<color=#00f012ff>%d</color>)"

local function initComposeItemNode(self,node,index)
    node.Visible = true
    local icon = node:FindChildByEditName("icon",false)
    local frame = node:FindChildByEditName("frame",false)
    local name = node:FindChildByEditName("name",false)
    local lb_detail_point = node:FindChildByEditName("lb_detail_point",false)
    if self.listNodes[node] == nil then
        self.listNodes[node] = Util.ShowItemShow(icon, "", 0)
        self.listNodes[node].IsSelected = false
    end
    local prop = self.composeItemProps[index]
    if prop == nil then
        return
    end
    local itemProp = GlobalHooks.DB.Find('Items',prop.TagetCode)
    self.listNodes[node].IconID = itemProp.Icon
	self.listNodes[node].Quality = itemProp.Qcolor
    node.UserTag = index
    self.listNodes[node].UserTag = index
    local value = getComposeInfo(self,prop)
    if value == nil then
        node.Visible = false
        return
    end
    name.Text = string.format(string_format,itemProp.Name,value.canComposeCount)
    self.composeInfo[node.UserTag] = {itemProp = itemProp,compProp = value,index = index}
    lb_detail_point.Visible = value.canComposeCount > 0
    if index == self.selectLeafIndex then
        self.listNodes[node].IsSelected = true
    else
        self.listNodes[node].IsSelected = false
    end
    node.event_PointerClick = function()
        for k,v in pairs(self.listNodes) do
            v.IsSelected = false
        end
        self.listNodes[node].IsSelected = true
        self.selectLeafIndex = node.UserTag
        clickDetailNode(self,node)
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('buttonClick')
    end
    
end

function _M:onCombineBtnClick()

    if self.selectComposeInfo and self.selectComposeInfo.compProp.canComposeCount > 0 then
        local num = tonumber(self.lb_numberkey.Text)
    
        local code = self.selectComposeInfo.itemProp.Code
        
        
        
        local destID = self.selectComposeInfo.itemProp.DestID
        
        local list = GlobalHooks.DB.Find("Combine", {})
        for k,v in pairs(list) do
            if v.DestCode == self.selectComposeInfo.itemProp.Code then
                destID = v.DestID
                break
            end
        end
        local code = self.selectComposeInfo.itemProp.Code
        local itemDatas = DataMgr.Instance.UserData.RoleBag:GetItemsByTemplateID(code)
        
        ItemModel.ItemCombineRequest(destID,num,0,function ()
            
            





            
                local ctrl = self["cvs_single"..1]
                Util.showUIEffect(self.itemshows_mar[ctrl],1)  
                
        
            




            
            for k,v in pairs(self.composeInfo) do
                local node = findNodeByIndex(self,k)
                if(node) and self.listNodes[node].UserTag == k then
                    initComposeItemNode(self,node,v.index)
                    
                    
                end
            end
            setDetailProp(self,self.selectComposeInfo)

            self.selectLeafIndex = self:GetSelectItem()
            self:SetSelectItem(self.selectLeafIndex)






			
            
            






        EventManager.Fire("Event.ItemCompose.ComposeSuccess",{})
		end)
    else
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ITEM, "unenoughMeta"))
    end
end

local function initTreeView(self)
    local list = GlobalHooks.DB.Find("CombineType", {})
    self.listRootProp = {}
    self.listSubProp = {}
    self.listLeafProp = {}
    for i, v in ipairs(list) do
        if v.ParentID == 0 then
            
            table.insert(self.listRootProp,v)
        elseif v.ID > 0 then
            
            if (self.listSubProp[v.ParentID] == nil) then
                self.listSubProp[v.ParentID] = {}
            end
            table.insert(self.listSubProp[v.ParentID],v)
        else
            if self.listLeafProp[v.ParentID] == nil then
                self.listLeafProp[v.ParentID] = {}
            end
            table.insert(self.listLeafProp[v.ParentID],v)
        end
    end
    local function rootCreateCallBack(index,node)
        node.Enable = true
        local lb_typename = node:FindChildByEditName("lb_typename",false)
        lb_typename.Text = self.listRootProp[index].ItemName
    end
    local function rootClickCallBack(node,visible)
        local tbt_open = node:FindChildByEditName("tbt_open",false)
        if visible then
            Util.HZSetImage(tbt_open, "#static_n/func/maininterface.xml|maininterface|93")
        else
            Util.HZSetImage(tbt_open, "#static_n/func/maininterface.xml|maininterface|89")
        end
        XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('buttonClick')
    end
    local rootValue = TreeView.CreateRootValue(self.cvs_typename,#self.listRootProp,rootCreateCallBack,rootClickCallBack)
    local subValues = {}
    local function subClickCallback(rootIndex,subIndex,node)
        local tbt_subtype = node:FindChildByEditName("tbt_subtype",false)
        if tbt_subtype.Visible == false then
            tbt_subtype.Visible = true
            setComponseItems(self,rootIndex,subIndex)
        end
        
    end
    local function subCreateCallback(rootIndex,subIndex,node)
        node.Enable = true
        local lb_subname = node:FindChildByEditName("lb_subname",false)
        lb_subname.Text = self.listSubProp[getRootID(self,rootIndex)][subIndex].ItemName
    end
    for k,v in pairs(self.listSubProp) do
        local rootIndex = getRootIndex(self,k)
        local subValue = TreeView.CreateSubValue(rootIndex ,self.cvs_subtype,#v,subClickCallback,subCreateCallback)
        table.insert(subValues,subValue)
    end
    self.treeView:setValues(rootValue,subValues)
    self.sp_type:AddNormalChild(self.treeView.view)
    self.treeView:setScrollPan(self.sp_type)
end

local function SetCostMaterial(self, CombineData, index, newHasCount)
    local node = self.cvs_single1
    if index == 2 then
        node = self.cvs_single2
    end
    if index == 3 then 
        node = self.cvs_single3
    end
    local matName = CombineData.compProp.codes[index]
    local matCount = CombineData.compProp.needCounts[index]

    local cvs_icon = node:FindChildByEditName('ib_single_icon', false)
    local lb_num = node:FindChildByEditName('tb_single_num', false)
    local btn_get = node:FindChildByEditName('ib_dep_goicon', false)

    local bag_data = DataMgr.Instance.UserData.RoleBag
    local vItem = bag_data:MergerTemplateItem(matName)

    local static_data = ItemModel.GetItemStaticDataByCode(matName)
    local item = Util.ShowItemShow(cvs_icon, static_data.Icon, static_data.Qcolor, 1)

    local x =(vItem and vItem.Num) or 0
    if newHasCount then
        x = newHasCount
    end
    local isLessItem = true
    if index == 1 then
        CombineData.hasCount1 = x
    else
        CombineData.hasCount2 = x
    end

    if x < matCount then

    else
        isLessItem = false

    end
    lb_num.Text = string.format(string_num, x, matCount * self.selectComposeCount)
    btn_get.Visible =(x < matCount)
    Util.NormalItemShowTouchClick(item, matName, isLessItem)
    if self.lb_numberkey ~= nil then
        self.lb_numberkey.Text = self.selectComposeCount
    end
end
 
local function InitComponent(self,tag,parent)
    self.menu = XmdsUISystem.CreateFromFile('xmds_ui/bag/combine.gui.xml')
    initControls(self.menu,ui_names,self)
    grid_pos[1] = {self.cvs_single2.X}      
    grid_pos[2] = {self.cvs_single1.X,self.cvs_single3.X}
    grid_pos[3] = {self.cvs_single1.X,self.cvs_single2.X,self.cvs_single3.X}
    self.cvs_item.Visible = false
    if(parent) then
        self.parent = parent
        parent:AddChild(self.menu)
    end
    local function funcCancel(node)
        local tbt_subtype = node:FindChildByEditName("tbt_subtype",false)
        tbt_subtype.Visible = false
    end
    self.treeView = TreeView.Create(3,0,self.sp_type.Size2D,TreeView.MODE_SINGLE,funcCancel)
    initTreeView(self)
    self.detail_node.Visible = false
    self.listNodes = {}
    self.itemNodes = {}
    self.composeInfo = {}
    self.sp_deatil:Initialize(self.detail_node.Width,self.detail_node.Height+15,0,1,self.detail_node,
        function(gx, gy, node)
            initComposeItemNode(self,node,gy + 1)
            self.itemNodes[gy + 1] = node
        end,
        function(node)
            node.Visible = true
        end
    )    
    self.lb_use.TextComponent.Anchor = TextAnchor.C_C
    self.itemshows_mar = {}
    self.lb_numberkey.Enable = true
    self.lb_numberkey.IsInteractive = true
    self.lb_numberkey.event_PointerClick = function()
        if self.selectComposeInfo then
            
            local view,numInput = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUINumberInput,0)
            local x = self.lb_numberkey.X + self.lb_numberkey.Parent.X + self.lb_numberkey.Parent.Parent.X + self.lb_numberkey.Parent.Parent.Parent.X
            local y = self.lb_numberkey.Y + self.lb_numberkey.Parent.Y + self.lb_numberkey.Parent.Parent.Y + self.lb_numberkey.Parent.Parent.Parent.Y
            local pos = {X = x,Y = y - 200}
            numInput:SetPos(pos)
            local function funcClickCallback(value)
                self.selectComposeCount = value
                self:changeMoney()
            end
            numInput:SetValue(1,self.selectComposeInfo.compProp.canComposeCount,self.selectComposeCount,funcClickCallback)
        end
    end

    
    local rootIndex = 1 
    local rootValue = self.listRootProp[1]
    local subIndex = nil
    local leafIndex = nil
    local subValue = nil
    if self.listSubProp[rootValue.ID] and #self.listSubProp[rootValue.ID] > 0 then
        subIndex = 1
        subValue = self.listSubProp[rootValue.ID][1]
        if self.listLeafProp[subValue.ID] and #self.listLeafProp[subValue.ID] > 0 then
            leafIndex = self:GetSelectItem()
        end
    end
    if (rootIndex and subIndex and leafIndex) then
        self.treeView:selectNode(rootIndex,subIndex,true)
        self.selectLeafIndex = leafIndex
        self:SetSelectItem(leafIndex)
    end
end

function _M:GetSelectItem()
    local selectNode = nil
    for k,v in pairs(self.listNodes) do
        local lb_detail_point = k:FindChildByEditName("lb_detail_point",false)
        if lb_detail_point.Visible == true then 
            if selectNode == nil or k.UserTag < selectNode.UserTag then
                selectNode = k
            end
        end
    end

    if selectNode ~= nil then
        return selectNode.UserTag
    end
    return 1
end

function _M:SetSelectItem(index)
    
    DisplayUtil.lookAt(self.sp_deatil,index)

    for k,v in pairs(self.listNodes) do
        if k.UserTag == index and v.UserTag == index  then
            v.IsSelected = true
            clickDetailNode(self,k)
        else    
            v.IsSelected = false
        end
    end
end

function _M:SetParam(param)
    local infos = string.split(param,"-")
    if #infos > 1 then
        local ID = tonumber(infos[1])
        local ParentID = tonumber(infos[2])
        if ID == 0 then
            
            local targetCode = infos[3]
            local leafProps = self.listLeafProp[ParentID]
            if leafProps then
                local leafIndex = nil
                local subIndex = nil
                local rootID = nil
                local rootIndex = nil
                for i = 1,#leafProps,1 do
                    if leafProps[i].TagetCode == targetCode then
                        
                        leafIndex = i
                        break
                    end
                end   
                for k,v in pairs(self.listSubProp) do
                    for i = 1,#v,1 do
                        if v[i].ID == ParentID then
                            subIndex = i
                            rootID = v[i].ParentID
                            break
                        end
                    end
                end
                for i = 1,#self.listRootProp,1 do
                    local prop = self.listRootProp[i]
                    if prop.ID == rootID then
                        
                        rootIndex = i
                        break
                    end
                end
                self.treeView:selectNode(rootIndex,subIndex,true)
                
                

                self.selectLeafIndex = self:GetSelectItem() 
                self:SetSelectItem(self.selectLeafIndex)
            end
        else
            if ParentID == 0 then
                
                for i = 1,#self.listRootProp,1 do
                    local prop = self.listRootProp[i]
                    if prop.ID == ID then
                        
                        self.treeView:selectNode(i)
                        break
                    end
                end
            else
                
                local subProps = self.listSubProp[ParentID]
                local rootIndex = nil
                local subIndex = nil
                if subProps then
                    for i = 1,#subProps,1 do
                        if subProps[i].ID == ID then
                            
                            subIndex = i
                            break;
                        end
                    end
                    for i = 1,#self.listRootProp,1 do
                        local prop = self.listRootProp[i]
                        if prop.ID == ParentID then
                            
                            rootIndex = i
                            break
                        end
                    end
                    self.treeView:selectNode(rootIndex,subIndex)
                end
            end
        end
    end
end

function _M:OnEnter()
    self.parent.Visible = true
    self.menu.Visible = true 
    if self.itemNodes then
        for k,v in pairs(self.itemNodes) do
            initComposeItemNode(self,v,k)
        end
        self.sp_deatil:RefreshShowCell()
    end

    self.selectLeafIndex = self:GetSelectItem()
    if self.selectLeafIndex and self.selectLeafIndex > 0 then
        self:SetSelectItem(self.selectLeafIndex)
    end

    GlobalHooks.Drama.Start("guide_compound", true)

    self.OnBuySuccess = function(evtName, param)
        local itemCode = param.itemCode
        local buyCount = param.buyCount
        local totalCount = param.totalCount

        if self.selectComposeInfo then
            local index = 1
            local matName = self.selectComposeInfo.compProp.codes[1]
            if self.selectComposeInfo.compProp.codes[2] == itemCode then
                index = 2
                matName = self.selectComposeInfo.compProp.codes[2]
            end
            if self.selectComposeInfo.compProp.codes[3] ==  itemCode then
                index = 3
                matName = self.selectComposeInfo.compProp.codes[3]
            end

            local num = DataMgr.Instance.UserData.RoleBag:GetTemplateItemCount(self.selectComposeInfo.compProp.codes[index])
            local canBuyTimes = math.floor(num / self.selectComposeInfo.compProp.needCounts[index])
            self.selectComposeInfo.compProp.canComposeCount = canBuyTimes
            self.selectComposeCount = canBuyTimes;
            SetCostMaterial(self, self.selectComposeInfo, index, totalCount)

            for k,v in pairs(self.composeInfo) do
                    local node = findNodeByIndex(self,k)
                    if(node) and self.listNodes[node].UserTag == k then
                        initComposeItemNode(self,node,v.index)
                        
                        
                    end
            end
            setDetailProp(self,self.selectComposeInfo)
        end
    end
    EventManager.Subscribe("Event.ShopMall.BuySuccess",self.OnBuySuccess)
end

function _M:CloseMenu()
    print("CloseMenu")
    self.parent.Visible = false
    EventManager.Unsubscribe("Event.ShopMall.BuySuccess",self.OnBuySuccess)
end

function _M.Create(tag,parent)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag,parent)
    return ret
end

return _M

