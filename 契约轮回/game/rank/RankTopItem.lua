RankTopItem = RankTopItem or class("RankRightItem", BaseCloneItem)

function RankTopItem:ctor(obj, parent_node, layer)
    RankTopItem.super.Load(self)
    self.model = RankModel:GetInstance()
end
function RankTopItem:dctor()
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
	if self.lvItem then
		self.lvItem:destroy()
		self.lvItem = nil
	end
end

function RankTopItem:LoadCallBack()
    self.nodes = {
        "nameObj/name",
        "nameObj/nameTitle",
        "click",
        "levelObj", "levelObj/level", "powerObj", "powerObj/power",
        "headBg/head", "rankImg", "nameBg", "headBg"
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.nameTex = GetText(self.name)
    self.nameTitleTex = GetText(self.nameTitle)
    -- self.head = GetImage(self.head)
    self.level = GetText(self.level)
    self.power = GetText(self.power)
    self.rankImg = GetImage(self.rankImg)
    self.nameBg = GetImage(self.nameBg)
    self.text_title_1_outline = self.nameTitle:GetComponent('Outline')
    self:AddEvent()
end

function RankTopItem:SetData(rankType, data)
    if not data then
        SetVisible(self.transform, false)
        return
    end
    self.data = data
    self.rankType = rankType
    self:InitUI()
end

function RankTopItem:InitUI()
    self.roleBase = self.data.base
    self.nameTex.text = self.roleBase.name
    self:SetType()

end

function RankTopItem:SetType()
	if self.lvItem then
		self.lvItem:destroy()
		self.lvItem = nil
	end
    if self.rankType == 1001 then
        --等级榜
        SetVisible(self.levelObj, true)
        SetVisible(self.powerObj, false)
        --local final_lv, is_under_top = GetLevelShow(self.roleBase.level)
        --if is_under_top then
            --final_lv = final_lv .. "级"
        --end
        --self.level.text = final_lv
		self.lvItem = LevelShowItem(self.levelObj)
		self.lvItem:SetData(22,self.roleBase.level,"ffffff", "74312A")
		
    elseif self.rankType == 1002 then
        --战力榜
        SetVisible(self.levelObj, false)
        SetVisible(self.powerObj, true)
        self.power.text = "CP:" .. self.data.sort
    elseif self.rankType == 1003 then
        SetVisible(self.levelObj, false)
        SetVisible(self.powerObj, true)
        local cfg = self.model:GetMountNumByID(self.data.sort)
        self.power.text = "Tier:" .. string.format("T%sS%s", cfg.order, cfg.level)

    elseif self.rankType == 1004 then
        SetVisible(self.levelObj, false)
        SetVisible(self.powerObj, true)
        local cfg = self.model:GetOffhandNumByID(self.data.sort)
        self.power.text = "Tier:" .. string.format("T%sS%s", cfg.order, cfg.level)
    elseif self.rankType == 1005 then
        SetVisible(self.levelObj, false)
        SetVisible(self.powerObj, true)
        self.power.text = "CP:" .. self.data.sort
    elseif self.rankType == 1006 then
        SetVisible(self.levelObj, false)
        SetVisible(self.powerObj, true)
        self.power.text = "CP:" .. self.data.sort
    elseif self.rankType == 1007 then
        SetVisible(self.levelObj, false)
        SetVisible(self.powerObj, true)
        self.power.text = "CP:" .. self.data.sort
    elseif self.rankType == 1008 then
        SetVisible(self.levelObj, false)
        SetVisible(self.powerObj, true)
        self.power.text = string.format("Benifit: %s/min",GetShowNumber(math.floor(self.data.sort)))
    end
    self:SetHead()
    self:SetTitle()
end

function RankTopItem:SetHead()
    local img1 = "rank_one"
    local img2 = "rank_1"
    if self.data.rank == 1 then
        img1 = "rank_one"
        img2 = "rank_1"
        SetLocalPosition(self.rankImg.transform, 114, -3.7)
    elseif self.data.rank == 2 then
        img1 = "rank_tow"
        img2 = "rank_2"
        SetLocalPosition(self.rankImg.transform, 113, -5)
        SetLocalPosition(self.headBg.transform, 111, 11)
    elseif self.data.rank == 3 then
        img1 = "rank_three"
        img2 = "rank_3"
        SetLocalPosition(self.headBg.transform, 118, 10)
    end
    lua_resMgr:SetImageTexture(self, self.rankImg, 'rank_image', img1, false)
    lua_resMgr:SetImageTexture(self, self.nameBg, 'rank_image', img2, true)
    --local career = self.roleBase.career
    --local wake = self.roleBase.wake
    --local db = Config.db_wake[career.."@"..wake]
    --local headNamePic = db.pic
    --lua_resMgr:SetImageTexture(self,self.head, 'main_image', headNamePic,true)
    if self.role_icon1 then
        self.role_icon1:destroy()
        self.role_icon1 = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    param["is_hide_frame"] = true
    param["size"] = 60
    param["uploading_cb"] = uploading_cb
    param["role_data"] = self.roleBase
    self.role_icon1 = RoleIcon(self.head)
    self.role_icon1:SetData(param)
end

function RankTopItem:SetTitle()
    local roleBase = self.data.base
    self.title_id = roleBase.figure.jobtitle and roleBase.figure.jobtitle.model
    self.title_id = self.title_id or 0
    local cur_config = Config.db_jobtitle[self.title_id]
    if not cur_config then
        self.nameTitleTex.text = ""
        return
    end
    self.nameTitleTex.text = cur_config.name
    local r, g, b, a = HtmlColorStringToColor(cur_config.color)
    SetOutLineColor(self.text_title_1_outline, r, g, b, a)
    self:UpdateTitelPos()
    --print2(cur_config.name)
end

function RankTopItem:UpdateTitelPos()
    local name_width = self.nameTex.preferredWidth
    local job_title_width = self.nameTitleTex.preferredWidth
    local name_x = job_title_width * 0.5
    local job_title_x = -name_width * 0.5 - name_x
    -- SetLocalPositionX(self.name, name_x)
    SetLocalPositionX(self.nameTitle, job_title_x)
end

function RankTopItem:AddEvent()
    function call_back()
        --查看信息RequireConfig
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.headBg)
        panel:Open(self.data.base)
    end
    AddClickEvent(self.click.gameObject, call_back)
end