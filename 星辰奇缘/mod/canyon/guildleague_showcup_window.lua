-- 冠军联赛嗮奖杯装逼界面
-- 2016年11月18日
-- hzf

GuildLeagueShowCupWindow = GuildLeagueShowCupWindow or BaseClass(BaseWindow)

function GuildLeagueShowCupWindow:__init(model)
    self.model = model
    self.Mgr = GuildLeagueManager.Instance
    self.resList = {
        {file = AssetConfig.guildleague_showcupwindow, type = AssetType.Main}
        ,{file = AssetConfig.guildleague_texture, type = AssetType.Dep}
    }
    -- self.OnOpenEvent:Add(function() self:OnOpen() end)
    -- self.OnHideEvent:Add(function() self:OnHide() end)
end

function GuildLeagueShowCupWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildLeagueShowCupWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_showcupwindow))
    self.gameObject.name = "GuildLeagueShowCupWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.nameitem = self.transform:Find("Main/nameitem").gameObject
    self.nameCon = self.transform:Find("Main/NameGroup")

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseShowCupWindow()
    end)
    self:InitNameAnima()
end

function GuildLeagueShowCupWindow:InitNameAnima()
    local myname = StringHelper.ConvertStringTable("公会名字六个")
    self.nameCon.sizeDelta = Vector2(#myname*20, 40)
    local nameObjList = {}
    for i,v in ipairs(myname) do
        local textitem = GameObject.Instantiate(self.nameitem)
        textitem.transform:GetComponent(Text).text = v
        textitem.transform:SetParent(self.nameCon)
        textitem.transform.localScale = Vector3.one
        textitem.transform.anchoredPosition3D = Vector3(20 * (i - 1), 0 ,0)
        table.insert(nameObjList, textitem.transform)
    end

    for i,v in ipairs(nameObjList) do
        local endpos = v.localPosition
        v.anchoredPosition = v.localPosition + 13*(v.localPosition - Vector3(0, 20, 0))
        v.localScale = Vector3.one*5
        local func = function()
            Tween.Instance:MoveLocal(v.gameObject, endpos, 0.4, function() if i == #nameObjList then self:OnNameMoveEnd() end end, LeanTweenType.linear)
            -- Tween.Instance:MoveLocal(v.gameObject, endpos, 1.2, function() if i == #nameObjList then self:OnNameMoveEnd() end end, LeanTweenType.easeOutBack)
            Tween.Instance:Scale(v.gameObject, Vector3.one, 0.4, function()end, LeanTweenType.easeOutBack)
        end
        LuaTimer.Add(400*i, func)
    end
end

function GuildLeagueShowCupWindow:OnNameMoveEnd()
    -- body
end