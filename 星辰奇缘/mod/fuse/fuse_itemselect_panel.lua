FuseItemSelect = FuseItemSelect or BaseClass()

function FuseItemSelect:__init(main)
    self.main = main
    self.fuseMgr = self.main.fuseMgr
    self.panel = self.main.selectPanel
    self.originItem = self.main.originSelectItem
    self.con = self.main.petselectCon
    self.notips = self.main.nonitem
    self.okBtn = self.main.selectOkButton
    self.selectDescText = self.main.selectDescText
    self.currindex = 1
    self.currItem = nil
end

function FuseItemSelect:OpenSelectPanel(index)
    self.currindex = 1
    self.currItem = nil
    self.currindex = index
    local currselect = self.fuseMgr.needItem[index]
    local targetData = self.fuseMgr.targetData
    local backpackList = BackpackManager.Instance:GetItemByBaseid(targetData.base_id)
    -- BaseUtils.dump(backpackList,"lieb")
    self:ClearCon()
    for i,v in ipairs(backpackList) do
        -- if v.id == currselect or  then
            local itemdata = v
            local item = GameObject.Instantiate(self.originItem)
            UIUtils.AddUIChild(self.con.gameObject, item.gameObject)
            item.gameObject.name = itemdata.id
            local fun = function()
                self:item_click(item, itemdata)
            end
            if FuseManager.Instance:IsSelected(v.id) then
                -- fun()
            end
            item:GetComponent(Button).onClick:AddListener(fun)
            local slot = ItemSlot.New()
            UIUtils.AddUIChild(item.transform:FindChild("Item").gameObject, slot.gameObject)
            slot:SetAll(itemdata)

            item.transform:FindChild("Name"):GetComponent(Text).text = itemdata.name
            self:setitemattr(item, itemdata.attr)
        -- end
    end
    self:UpdateSelect()

    self.notips:SetActive(#backpackList <1)
    self.panel.gameObject:SetActive(true)

end

function FuseItemSelect:ClearCon()
    local childnum = self.main.petselectCon.childCount
    for i=1,childnum do
        GameObject.DestroyImmediate(self.main.petselectCon:GetChild(0).gameObject)
    end
end

function FuseItemSelect:item_click(item, data)
    FuseManager.Instance:SelectNeed(data.id, self.currindex)
    -- if self.currItem ~= nil then
    --     self.currItem.transform:Find("Select").gameObject:SetActive(false)
    -- end
    -- item.transform:Find("Select").gameObject:SetActive(true)
    self.currItem = item
    self:UpdateSelect()
end

function FuseItemSelect:setitemattr(item, attr)
    local attr_str = ""
    local skill_str = ""
    for k,v in pairs(attr) do
        if v.type == GlobalEumn.ItemAttrType.base then
            if v.name ~= KvData.attrname_skill then
                attr_str = attr_str..string.format("%s: +%s", KvData.attr_name[v.name], v.val)
            else
                skill_str = skill_str..string.format("[%s]", DataSkill.data_petSkill[string.format("%s_1", v.val)].name)
            end
        end
    end
    if attr_str == "" then
        item.transform:FindChild("Desc"):GetComponent(Text).text = TI18N("技能:")
        item.transform:FindChild("Skill"):GetComponent(Text).text = skill_str
    else
        item.transform:FindChild("Desc"):GetComponent(Text).text = attr_str
    end
end

function FuseItemSelect:UpdateSelect()
    local num = self.con.childCount
    for i=0, num - 1 do
        local go = self.con:GetChild(i)
        if FuseManager.Instance:IsSelected(tonumber(go.gameObject.name)) then
            go:Find("Select").gameObject:SetActive(true)
        else
            go:Find("Select").gameObject:SetActive(false)
        end
    end
end
