---
--- Created by  Administrator
--- DateTime: 2019/9/7 15:46
---
GodOrderTips = GodOrderTips or class("GodOrderTips", BasePanel)
local this = GodOrderTips

function GodOrderTips:ctor(parent_node, parent_panel)
    self.abName = "god"
    self.assetName = "GodOrderTips"
    self.layer = "UI"
    self.attrs = {}
    self.jumpItems = {}
    self.use_background = true
    self.click_bg_close = true
end

function GodOrderTips:dctor()
   -- GlobalEvent:RemoveTabListener(self.events)
    if self.itemicon then
        self.itemicon:destroy()
    end
    for i, v in pairs(self.attrs) do
        v:destroy()
    end
    self.attrs = {}
    for i, v in pairs(self.jumpItems) do
        v:destroy()
    end
    self.jumpItems = {}
end

function GodOrderTips:Open()
    GodOrderTips.super.Open(self)
end

function GodOrderTips:LoadCallBack()
    self.nodes = {
        "obj/name","obj/title1","GodOrderAttr","obj/attrObj/attrParent","obj/iconObj","obj/pathObj","obj/iconObj/itemName","obj/bg",
        "obj/pathObj/pathIconParent","GodOrderJumpItem","obj/iconObj/title2",
    }
    self:GetChildren(self.nodes)
    self.itemName = GetText(self.itemName)
    self.name = GetText(self.name)
    self.title2 = GetText(self.title2)
    self.viewRectTra = self.transform:GetComponent('RectTransform')
    SetSizeDelta(self.background_transform, 3000, 3000)
    self:InitUI()
    self:AddEvent()
    if self.is_need_setData  then
        self:SetData(self.id,self.star,self.parent_node,self.curStar)
    end
end

function GodOrderTips:SetData(id,star,parent,curStar)
    self.id = id
    self.star = star
    self.parent_node = parent
    self.curStar = curStar
    self.parentRectTra = self.parent_node:GetComponent('RectTransform')
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end

    local cfg = Config.db_god_star[tostring(id).."@"..tostring(star)]
    if not cfg then
        return
    end
    self.name.text = Config.db_god_star[tostring(id).."@"..tostring(star + 1)].name
   -- self:CreateIcon(cfg)
    self:InitItemsNuns(cfg)
    self:UpdateAttr(cfg)
    self:SetViewPosition()
end

--function GodOrderTips:SetViewInfo()
--
--end

function GodOrderTips:InitItemsNuns(cfg)
    local itemTab = String2Table(cfg.cost)
    local id = itemTab[1]
    local needNub = itemTab[2]
    local num = BagModel:GetInstance():GetItemNumByItemID(id);
    local color = "00FF1A"
    self.gainway = Config.db_item[id].gainway
    if num < needNub then
        color = "FF1200"
    end
    local itemName = Config.db_item[id].name
    self.itemName.text = string.format("%s       <color=#%s>%s/%s</color>",itemName,color,num,needNub)


end

function GodOrderTips:UpdateJump(jump)
    if not string.isempty(jump) and jump ~= "{}" then
        --local height = 94 + 25
        --self.jumpItemSettor = GoodsJumpItemSettor(self.pathIconParent)
        --self.jumpItemSettor:CreateJumpItems(jump, height)
        local jumpTbl = String2Table(jump)
        for k, v in pairs(jumpTbl) do
            self.jumpItems[#self.jumpItems+1] = GodOrderJumpItem(self.GodOrderJumpItem.gameObject,self.pathIconParent,"UI")
            self.jumpItems[#self.jumpItems]:ShowJumpInfo(v)
        end


     --   self.height = self.height + height
    end
end

function GodOrderTips:UpdateAttr(cfg)
    local baseTab =  String2Table(cfg.attrs)
    local nextKey = tostring(self.id).."@"..tostring(self.star + 1)
    local nextCfg = Config.db_god_star[nextKey]
    for i = 1, 5 do
        if #baseTab >= i  then
            local attrId = baseTab[i][1]
            local attrNum = baseTab[i][2]
            if nextCfg == nil then

            else
                local nextTab = String2Table(nextCfg.attrs)
                local nextNux = nextTab[i][2]
                if nextNux - attrNum == 0 then
                   -- self["baseAttrtex"..i].text = ""
                    --self["baseAttr"..i].text = ""

                else
                   -- self["baseAttr"..i].text = "+"..(nextNux - attrNum)
                    local attrName = enumName.ATTR[attrId]
                    local str = "+"..(nextNux - attrNum)
                   -- self["baseAttrtex"..i].text = attrName
                    local item = self.attrs[i]
                    if not item  then
                        item = GodOrderAttr(self.GodOrderAttr.gameObject,self.attrParent,"UI")
                        self.attrs[i] = item
                    end
                    item:SetData(attrName,str)

                end

            end

        else

        end
    end

    self:SetContentPos()
end

function GodOrderTips:SetContentPos()
    local attrLen = table.nums(self.attrs)
    if self.star < self.curStar then --已经激活
        --90 + 30

        SetSizeDeltaY(self.bg, (attrLen*30)+90)
        SetVisible(self.iconObj,false)
        SetVisible(self.pathObj,false)

    else
        SetLocalPositionY(self.iconObj,70 - (attrLen*25))
        SetVisible(self.iconObj,true)
       -- SetVisible(self.pathObj,true)
        if not string.isempty(self.gainway) and self.gainway ~= "{}" then
            self:UpdateJump(self.gainway)
            SetLocalPositionY(self.pathObj,GetLocalPositionY(self.iconObj) - 60)
            SetSizeDeltaY(self.bg, (attrLen*30)+280)
            SetVisible(self.pathObj,true)
        else
            SetSizeDeltaY(self.bg, (attrLen*30)+150)
            SetVisible(self.pathObj,false)
        end

    end
end

function GodOrderTips:InitUI()

end

function GodOrderTips:AddEvent()

end



function GodOrderTips:SetViewPosition()
    local parentWidth = 0
    local parentHeight = 0
    local spanX = 0
    local spanY = 0
    if self.parentRectTra.anchorMin.x == 0.5 then
        spanX = 10
        parentWidth = self.parentRectTra.sizeDelta.x / 2
        parentHeight = self.parentRectTra.sizeDelta.y / 2
    else
        parentWidth = self.parentRectTra.sizeDelta.x
        parentHeight = self.parentRectTra.sizeDelta.y
    end
    local myx = self.viewRectTra.sizeDelta.x
    local myy = self.viewRectTra.sizeDelta.y

    --local pos = self.parent.position
    --local x = pos.x * 100 + parentWidth + myx/2
    --local y = pos.y * 100 - parentHeight - myy/2
    local pos = self.parent_node.position
    local x = ScreenWidth / 2 + pos.x * 100 + parentWidth
    local y = pos.y * 100 - ScreenHeight / 2 - parentHeight
    local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    self.transform:SetParent(UITransform)
    SetLocalScale(self.transform, 1, 1, 1)

    --判断是否超出右边界
    if ScreenWidth - (x + parentWidth + self.viewRectTra.sizeDelta.x) < 10 then
        --spanX = ScreenWidth - (x + self.viewRectTra.sizeDelta.x + self.btnWidth)
        if self.parentRectTra.anchorMin.x == 0.5 then
            x = x - self.viewRectTra.sizeDelta.x - parentWidth * 2 - 20
        else
            x = x - self.viewRectTra.sizeDelta.x - parentWidth
        end

    end

    if ScreenHeight + y - self.viewRectTra.sizeDelta.y < 10 then
        spanY = ScreenHeight + y - self.viewRectTra.sizeDelta.y - 10
    end
    self.viewRectTra.anchoredPosition = Vector2(x + spanX, y - spanY)
end
